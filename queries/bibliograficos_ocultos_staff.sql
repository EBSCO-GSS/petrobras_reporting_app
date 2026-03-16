--metadb:function producao_ocultos_staff
DROP FUNCTION IF EXISTS producao_ocultos_staff;
CREATE FUNCTION producao_ocultos_staff(
    start_date date DEFAULT '2020-01-01',
    end_date date DEFAULT '2050-01-01'
)
RETURNS TABLE(
    Usuario text,
    Ano_Mes text,
    Total bigint)
AS $$
SELECT
    CASE
        WHEN GROUPING(
            (u.jsonb->'personal'->>'firstName' || ' ' || (u.jsonb->'personal'->>'lastName'))
        ) = 1
        THEN 'GRAND TOTAL'
        ELSE (u.jsonb->'personal'->>'firstName' || ' ' || (u.jsonb->'personal'->>'lastName'))
    END AS Usuario,
    CASE
        WHEN GROUPING(to_char(
            date_trunc('month', (i.jsonb->'metadata'->>'updatedDate')::date),
            'YYYY-MM'
        )) = 1
        THEN 'SUBTOTAL'
        ELSE to_char(
            date_trunc('month', (i.jsonb->'metadata'->>'updatedDate')::date),
            'YYYY-MM'
        )
    END AS Ano_Mes,
    COUNT(DISTINCT i.id) AS total
FROM folio_inventory.instance__ i
LEFT JOIN folio_users.users__ u
       ON u.id = (i.jsonb->'metadata'->>'updatedByUserId')::uuid
WHERE (i.jsonb->>'staffSuppress')::boolean = true
  AND (i.jsonb->'metadata'->>'updatedDate')::date BETWEEN start_date AND end_date
  AND i.__current
GROUP BY ROLLUP (
    (u.jsonb->'personal'->>'firstName' || ' ' || (u.jsonb->'personal'->>'lastName')),
    to_char(
        date_trunc('month', (i.jsonb->'metadata'->>'updatedDate')::date),
        'YYYY-MM'
    )
)
ORDER BY
    (u.jsonb->'personal'->>'firstName' || ' ' || (u.jsonb->'personal'->>'lastName')) NULLS LAST,
    to_char(
        date_trunc('month', (i.jsonb->'metadata'->>'updatedDate')::date),
        'YYYY-MM'
    ) DESC NULLS LAST;
$$
LANGUAGE SQL
STABLE
PARALLEL SAFE;