DROP FUNCTION IF EXISTS producao_novos_exemplares;

CREATE FUNCTION producao_novos_exemplares(
    start_date date DEFAULT '2000-01-01',
    end_date date DEFAULT '2050-01-01'
)
RETURNS TABLE(
    Usuario text,
    AnoMes text,
    Total text)
AS $$

select 
    (u.jsonb->'personal'->>'firstName' || ' ' || (u.jsonb->'personal'->>'lastName')) AS Usuario,
    to_char(
	    date_trunc('month', (i.jsonb->'metadata'->>'createdDate')::timestamp),
	    'YYYY-MM'
	) AS AnoMes,
    (i.jsonb->'metadata'->>'createdByUserId') AS createdby,
    COUNT(*) AS Total
FROM folio_inventory.item__ i
LEFT JOIN folio_users.users__ u
       ON u.id = (i.jsonb->'metadata'->>'createdByUserId')::uuid
GROUP BY
    AnoMes,
    createdby,
    Usuario
where (i.jsonb->'metadata'->>'createdDate')::timestamp between start_date and end_date
ORDER BY AnoMes DESC, Usuario;
$$
LANGUAGE SQL
STABLE
PARALLEL SAFE;


