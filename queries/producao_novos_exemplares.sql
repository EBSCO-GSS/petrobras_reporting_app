--metadb:function producao_novos_exemplares

DROP FUNCTION IF EXISTS producao_novos_exemplares;

CREATE FUNCTION producao_novos_exemplares(
    start_date date DEFAULT '2020-01-01',
    end_date date DEFAULT '2050-01-01'
)
RETURNS TABLE(
    Usuario text,
    Ano_Mes text,
    Total number)
AS $$
select 
    (u.jsonb->'personal'->>'firstName' || ' ' || (u.jsonb->'personal'->>'lastName')) AS Usuario,
    to_char(
	    date_trunc('month', (i.jsonb->'metadata'->>'createdDate')::timestamp),
	    'YYYY-MM'
	) AS Ano_Mes,
    COUNT(*) AS Total
FROM folio_inventory.item__ i
LEFT JOIN folio_users.users__ u
       ON u.id = (i.jsonb->'metadata'->>'createdByUserId')::uuid
where (i.jsonb->'metadata'->>'createdDate')::timestamp between start_date and end_date
GROUP BY
    Ano_Mes,
    Usuario
ORDER BY Ano_Mes DESC, Usuario
$$
LANGUAGE SQL
STABLE
PARALLEL SAFE;
