--metadb:function circulacao_v2

DROP FUNCTION IF EXISTS circulacao_v2;

CREATE FUNCTION circulacao_v2(
    start_date date DEFAULT '2020-01-01',
    end_date date DEFAULT '2050-01-01',
    --punidade_organizacional text DEFAULT '',
    --plotacao  text DEFAULT '',
    --pposicao  text DEFAULT ''
)
RETURNS TABLE(
    data_emprestimo text,
    ponto_servico text,
    unidade_organizacional text,
    lotacao text,
    posicao text,
    grupo text,
    tipo_material text,
    "Total empréstimos" bigint
)
AS $$
SELECT  
    to_char(
        date_trunc('month', l.loan_date),
        'YYYY-MM'
    ) AS data_emprestimo,
    sp.discovery_display_name  AS ponto_servico,
    u.jsonb->'customFields'->>'link'      AS unidade_organizacional, 
    u.jsonb->'customFields'->>'stocking'  AS lotacao, 
    u.jsonb->'customFields'->>'position'  AS posicao,
    g.desc AS grupo,
    mt.name AS tipo_material,
    COUNT(*) AS "Total empréstimos"
FROM folio_circulation.loan__t__ l 
LEFT JOIN folio_users.users__ u  
       ON u.id = l.user_id 
LEFT JOIN folio_inventory.item__ i2 
       ON i2.id = l.item_id 
LEFT JOIN folio_inventory.holdings_record__ ht 
       ON ht.id = i2.holdingsrecordid 
LEFT JOIN folio_inventory.instance__ i 
       ON i.id = ht.instanceid 
LEFT JOIN folio_inventory.service_point__t__ sp 
       ON sp.id = l.checkout_service_point_id 
LEFT JOIN folio_inventory.material_type__t__ mt 
       ON mt.id = i2.materialtypeid
LEFT JOIN folio_users.groups__t__ g 
       ON g.id = (u.jsonb->>'patronGroup')::uuid
WHERE i2.__current
  AND l.loan_date BETWEEN start_date AND end_date
  --AND (u.jsonb->'customFields'->>'link')     LIKE '%' || punidade_organizacional || '%'
  --AND (u.jsonb->'customFields'->>'stocking') LIKE '%' || plotacao || '%'
  -AND (u.jsonb->'customFields'->>'position') LIKE '%' || pposicao || '%'
GROUP BY 
    data_emprestimo, 
    ponto_servico, 
    tipo_material, 
    unidade_organizacional, 
    lotacao, 
    posicao, 
    grupo
ORDER BY data_emprestimo DESC, ponto_servico, unidade_organizacional
$$
LANGUAGE SQL
STABLE
PARALLEL SAFE;
