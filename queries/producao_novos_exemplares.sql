
WITH parameters AS (
    SELECT
        NULL :: DATE AS start_date,
        NULL :: DATE AS end_date
)

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
where (i.jsonb->'metadata'->>'createdDate')::timestamp between (start_date FROM parameters) and (end_date FROM parameters)
GROUP BY
    Ano_Mes,
    Usuario
ORDER BY Ano_Mes DESC, Usuario;



