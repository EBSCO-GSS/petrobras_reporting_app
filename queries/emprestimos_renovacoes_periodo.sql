--metadb:function emprestimos_renovacoes_periodo

DROP FUNCTION IF EXISTS emprestimos_renovacoes_periodo;

CREATE FUNCTION emprestimos_renovacoes_periodo(
    start_date date DEFAULT '2020-01-01',
    end_date date DEFAULT '2050-01-01'    
)
RETURNS TABLE(
    "Data Empréstimo" text,
    "Tipologia" text,
    "Total" bigint
)
AS $$
SELECT
    to_char(date_trunc('month', l.loan_date), 'YYYY-MM') AS "Data Empréstimo",
    CASE 
        WHEN l.action IN ('renewed') THEN 'Renovação'
        WHEN l.action IN ('checkedout', 'checkedOutThroughOverride') THEN 'Empréstimo'
        ELSE l.action
    END AS "Tipologia",
    COUNT(*) AS "Total"
FROM folio_circulation.loan__t__ l
WHERE l.action IN ('renewed','checkedout','checkedOutThroughOverride')
  AND l.loan_date BETWEEN start_date AND end_date
GROUP BY 
    to_char(date_trunc('month', l.loan_date), 'YYYY-MM'),
    CASE 
        WHEN l.action IN ('renewed') THEN 'Renovação'
        WHEN l.action IN ('checkedout', 'checkedOutThroughOverride') THEN 'Empréstimo'
        ELSE l.action
    END
ORDER BY 
    "Data Empréstimo" DESC, 
    "Tipologia";
$$
LANGUAGE SQL
STABLE
PARALLEL SAFE;
