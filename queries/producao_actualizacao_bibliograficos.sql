--metadb:function producao_actualizacao_bibliograficos
DROP FUNCTION IF EXISTS producao_actualizacao_bibliograficos;

CREATE FUNCTION producao_actualizacao_bibliograficos(
    start_date date DEFAULT '2000-01-01',
    end_date date DEFAULT '2050-01-01'
)
RETURNS TABLE(
    Usuario text,
    AnoMes text,
    Total text)
AS $$
SELECT
    (u.jsonb->'personal'->>'firstName' || ' ' || (u.jsonb->'personal'->>'lastName')) AS Usuario,
    to_char(
	    date_trunc('month', (i.jsonb->'metadata'->>'updatedDate')::date),
	    'YYYY-MM'
	) AS AnoMes,
    COUNT(DISTINCT i.id ) AS Total
FROM folio_inventory.instance__ i
LEFT JOIN folio_users.users__ u
       ON u.id = (i.jsonb->'metadata'->>'updatedByUserId')::uuid
where (i.jsonb->'metadata'->>'updatedDate')::date between start_date and end_date
GROUP BY
    AnoMes,
    Usuario
ORDER BY AnoMes DESC, Usuario
$$
LANGUAGE SQL
STABLE
PARALLEL SAFE;


