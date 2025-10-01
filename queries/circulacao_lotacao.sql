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
SELECT distinct 
	to_char(
        date_trunc('month', (l.loan_date)),
        'YYYY-MM'
    ) AS data_emprestimo,
	(u.jsonb->'customFields'->>'stocking')   "Lotação",
	count(*) "Total empréstimos"

from  folio_circulation.loan__t__ l 
    LEFT JOIN folio_users.users__ u  ON u.id = l.user_id 
    left join folio_inventory.item__t__ i2 on i2.id = l.item_id 
    left join folio_inventory.holdings_record__t__ ht on ht.id= i2.holdings_record_id 
    left join folio_inventory.instance__t__ i on i.id = ht.instance_id 
    left join folio_inventory.service_point__t__ sp on sp.id =l.checkout_service_point_id 
    left join folio_inventory.material_type__t__ mt on mt.id = i2.material_type_id

WHERE l.loan_date BETWEEN start_date AND end_date
  AND (u.jsonb->'customFields'->>'link')     LIKE '%' || punidade_organizacional || '%'
  AND (u.jsonb->'customFields'->>'stocking') LIKE '%' || plotacao || '%'
  AND (u.jsonb->'customFields'->>'position') LIKE '%' || pposicao || '%'
  
group by data_emprestimo, (u.jsonb->'customFields'->>'stocking')   
ORDER BY data_emprestimo  desc, (u.jsonb->'customFields'->>'stocking') ,
"

$$
LANGUAGE SQL
STABLE
PARALLEL SAFE;
