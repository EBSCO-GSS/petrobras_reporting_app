--metadb:function emprestimos_vencidos

DROP FUNCTION IF EXISTS emprestimos_vencidos;

CREATE FUNCTION emprestimos_vencidos(
    start_date date DEFAULT '2020-01-01',
    end_date date DEFAULT '2050-01-01'    
)
RETURNS TABLE(
    "Data Empréstimo" text,
    "Tipologia" text,
    "Total" text)
AS $$

SELECT
    to_char(date_trunc('month', l.loan_date), 'YYYY-MM') AS data_emprestimo,
    l.action as "Tipologia",
    COUNT(*) AS "Total"

from folio_circulation.loan__t__ l
where l.action in ('renewed','checkedout','checkedOutThroughOverride')
and  l.loan_date between start_date and end_date    
GROUP BY 
    to_char(date_trunc('month', l.loan_date), 'YYYY-MM'),
    l.action
ORDER BY 
    data_emprestimo DESC, 
    "Tipologia" 

$$
LANGUAGE SQL
STABLE
PARALLEL SAFE;
