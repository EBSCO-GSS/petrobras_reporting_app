--metadb:function producao_ocultos_staff

DROP FUNCTION IF EXISTS producao_ocultos_staff;

CREATE FUNCTION producao_ocultos_staff(
    start_date date DEFAULT '2020-01-01',
    end_date date DEFAULT '2050-01-01'
)
RETURNS TABLE(
    Usuario text,
    Ano_Mes text,
    Total text)
AS $$
SELECT
    (u.jsonb->'personal'->>'firstName' || ' ' || (u.jsonb->'personal'->>'lastName')) AS Usuario,
    to_char(
        date_trunc('month', (i.jsonb->'metadata'->>'updatedDate')::timestamp),
        'YYYY-MM'
    ) AS Ano_Mes,
    COUNT(distinct i.id) AS total
FROM folio_inventory.instance__ i
LEFT JOIN folio_users.users__ u
       ON u.id = (i.jsonb->'metadata'->>'updatedByUserId')::uuid
WHERE (i.jsonb->>'staffSuppress')::boolean =true
and  (i.jsonb->'metadata'->>'updatedDate')::timestamp between start_date and end_date
and i.__current
GROUP BY
    Ano_Mes,
    Usuario
ORDER BY Ano_Mes DESC, Usuario
$$
LANGUAGE SQL
STABLE
PARALLEL SAFE;
