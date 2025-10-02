--metadb:function circulacao_lotacao

DROP FUNCTION IF EXISTS circulacao_lotacao;

CREATE FUNCTION circulacao_lotacao(
    start_date date DEFAULT '2020-01-01',
    end_date date DEFAULT '2050-01-01',
    punidade_organizacional text DEFAULT '',
    plotacao  text DEFAULT '',
    pposicao  text DEFAULT ''
)
RETURNS TABLE(
    data_emprestimo text,
    "Lotação" text,
    "Total empréstimos" bigint
)
AS $$
SELECT
    to_char(date_trunc('month', l.loan_date), 'YYYY-MM') AS data_emprestimo,
    u.jsonb->'customFields'->>'stocking' AS "Lotação",
    COUNT(*) AS "Total empréstimos"
FROM folio_circulation.loan__t__ l 
LEFT JOIN folio_users.users__ u  
       ON u.id = l.user_id 
LEFT JOIN folio_inventory.item__t__ i2 
       ON i2.id = l.item_id 
LEFT JOIN folio_inventory.holdings_record__t__ ht 
       ON ht.id = i2.holdings_record_id 
LEFT JOIN folio_inventory.instance__t__ i 
       ON i.id = ht.instance_id 
LEFT JOIN folio_inventory.service_point__t__ sp 
       ON sp.id = l.checkout_service_point_id 
LEFT JOIN folio_inventory.material_type__t__ mt 
       ON mt.id = i2.material_type_id
WHERE l.loan_date BETWEEN start_date AND end_date
  AND (u.jsonb->'customFields'->>'link')     LIKE '%' || punidade_organizacional || '%'
  AND (u.jsonb->'customFields'->>'stocking') LIKE '%' || plotacao || '%'
  AND (u.jsonb->'customFields'->>'position') LIKE '%' || pposicao || '%'
GROUP BY 
    to_char(date_trunc('month', l.loan_date), 'YYYY-MM'),
    u.jsonb->'customFields'->>'stocking'
ORDER BY 
    data_emprestimo DESC, 
    u.jsonb->'customFields'->>'stocking';
$$
LANGUAGE SQL
STABLE
PARALLEL SAFE;
