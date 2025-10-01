--metadb:function circulacao_v2

DROP FUNCTION IF EXISTS circulacao_v2;

CREATE FUNCTION circulacao_v2(
    start_date date DEFAULT '2020-01-01',
    end_date date DEFAULT '2050-01-01'   
    punidade_organizacional text DEFAULT '',
    plotacao  text DEFAULT '',
    pposicao  text DEFAULT ''
)
RETURNS TABLE(
    data_emprestimo text,
    ponto_servico text,
    unidade_organizacional text,
    lotacao text,
    Posicao text,
    grupo text,
    tipo_material text,
    "Total empréstimos" text
    )
AS $$

SELECT  
    to_char(
        date_trunc('month', (l.loan_date)),
        'YYYY-MM'
    ) AS data_emprestimo,
    sp.discovery_display_name  as ponto_servico,
    (u.jsonb->'customFields'->>'link') as unidade_organizacional, 
    (u.jsonb->'customFields'->>'stocking') as lotacao, 
    (u.jsonb->'customFields'->>'position') as Posicao,
    g.desc as grupo,
    mt.name as tipo_material,
    count(*) as "Total empréstimos"
    
from  folio_circulation.loan__t__ l 
    LEFT JOIN folio_users.users__ u  ON u.id = l.user_id 
    left join folio_inventory.item__ i2 on i2.id = l.item_id 
    left join folio_inventory.holdings_record__ ht on ht.id= i2.holdingsrecordid 
    left join folio_inventory.instance__ i on i.id = ht.instanceid 
    left join folio_inventory.service_point__t__ sp on sp.id =l.checkout_service_point_id 
    left join folio_inventory.material_type__t__ mt on mt.id = i2.materialtypeid
    left join folio_users.groups__t__ g on g.id  = (u.jsonb->>'patronGroup')::uuid

WHERE i2.__current
  and l.loan_date between start_date and end_date
  (u.jsonb->'customFields'->>'link') LIKE '%' || punidade_organizacional || '%'
  (u.jsonb->'customFields'->>'stocking') LIKE '%' || plotacao || '%'
  (u.jsonb->'customFields'->>'position') LIKE '%' || pposicao || '%'
group by data_emprestimo, ponto_servico, tipo_material, unidade_organizacional, lotacao, Posicao, grupo
ORDER BY data_emprestimo  desc, ponto_servico, unidade_organizacional

$$
LANGUAGE SQL
STABLE
PARALLEL SAFE;
