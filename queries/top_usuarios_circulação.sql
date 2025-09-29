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
    (u.jsonb->'personal'->>'firstName' || ' ' || (u.jsonb->'personal'->>'lastName')) AS Usuario,
    COUNT(l.id) AS Total
FROM folio_circulation.loan__ l
LEFT JOIN folio_users.users__ u
       ON u.id = (l.jsonb->>'userId')::uuid
WHERE (l.jsonb->>'loanDate')::timestamp  BETWEEN start_date and end_date
GROUP BY Usuario
ORDER BY Total DESC, Usuario;


$$
LANGUAGE SQL
STABLE
PARALLEL SAFE;
