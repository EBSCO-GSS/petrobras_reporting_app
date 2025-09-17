DROP FUNCTION IF EXISTS producao_actualizacao_exemplares;

CREATE FUNCTION producao_actualizacao_exemplares(
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
        date_trunc('month', (i.jsonb->'metadata'->>'updatedDate')::timestamp),
        'YYYY-MM'
    ) AS AnoMes,
    i.jsonb->'metadata'->>'updatedByUserId' AS updatedby,
    COUNT(*) AS Total
FROM folio_inventory.item__ i
LEFT JOIN folio_users.users__ u
       ON u.id = (i.jsonb->'metadata'->>'updatedByUserId')::uuid
WHERE (i.jsonb->'metadata'->>'updatedDate') IS NOT NULL
GROUP BY
    AnoMes,
    updatedby,
    Usuario
where (i.jsonb->'metadata'->>'updatedDate')::timestamp between start_date and end_date    
ORDER BY AnoMes DESC, Usuario;


$$
LANGUAGE SQL
STABLE
PARALLEL SAFE;


