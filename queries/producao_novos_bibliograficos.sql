DROP FUNCTION IF EXISTS producao_novos_bibliograficos;

CREATE FUNCTION producao_novos_bibliograficos(
    start_date date DEFAULT '2000-01-01',
    end_date date DEFAULT '2050-01-01'
)
RETURNS TABLE(
    Usuario text,
    AnoMes text,
    Total numeric)
AS $$
select 
    (u.jsonb->'personal'->>'firstName' || ' ' || (u.jsonb->'personal'->>'lastName')) AS patron,
    to_char(
	    date_trunc('month', (i.jsonb->'metadata'->>'createdDate')::timestamp),
	    'YYYY-MM'
	) AS created_month,
    COUNT(*) AS total
FROM folio_inventory.instance__ i
LEFT JOIN folio_users.users__ u
       ON u.id = (i.jsonb->'metadata'->>'createdByUserId')::uuid
GROUP BY
    created_month,
    patron
where (i.jsonb->'metadata'->>'createdDate')::timestamp between start_date and end_date
ORDER BY created_month DESC, patron
$$
LANGUAGE SQL
STABLE
PARALLEL SAFE;


