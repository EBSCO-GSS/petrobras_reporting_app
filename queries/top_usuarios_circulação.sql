--metadb:function top_usuarios_circulacao

DROP FUNCTION IF EXISTS top_usuarios_circulacao;

CREATE FUNCTION top_usuarios_circulacao(
    start_date date DEFAULT '2020-01-01',
    end_date date DEFAULT '2050-01-01'
)
RETURNS TABLE(
    Usuario text,
    Total text)
AS $$
SELECT 
    COALESCE(
        (u.jsonb->'personal'->>'firstName' || ' ' || (u.jsonb->'personal'->>'lastName')),
        'TOTAL'
    ) AS Usuario,
    COUNT(l.id) AS Total
FROM folio_circulation.loan__ l
LEFT JOIN folio_users.users__ u
       ON u.id = (l.jsonb->>'userId')::uuid
WHERE (l.jsonb->>'loanDate')::date BETWEEN start_date AND end_date
GROUP BY ROLLUP(
    (u.jsonb->'personal'->>'firstName' || ' ' || (u.jsonb->'personal'->>'lastName'))
)
ORDER BY 
    CASE WHEN (u.jsonb->'personal'->>'firstName' || ' ' || (u.jsonb->'personal'->>'lastName')) IS NULL THEN 1 ELSE 0 END,
    Total DESC, 
    Usuario;


$$
LANGUAGE SQL
STABLE
PARALLEL SAFE;
