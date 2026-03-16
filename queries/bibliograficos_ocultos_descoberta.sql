--metadb:function producao_ocultos_descoberta

DROP FUNCTION IF EXISTS producao_ocultos_descoberta;

CREATE FUNCTION producao_ocultos_descoberta(
    start_date date DEFAULT '2020-01-01',
    end_date date DEFAULT '2050-01-01'
)
RETURNS TABLE(
    Usuario text,
    Ano_Mes text,
    Total text)
AS $$
SELECT
    COALESCE(
        to_char(
            date_trunc('month', (i.jsonb->'metadata'->>'updatedDate')::date),
            'YYYY-MM'
        ),
        'GRAND TOTAL'
    ) AS Ano_Mes,
    COALESCE(
        (u.jsonb->'personal'->>'firstName' || ' ' || (u.jsonb->'personal'->>'lastName')),
        'SUBTOTAL'
    ) AS Usuario,
    COUNT(DISTINCT i.id) AS total
FROM folio_inventory.instance__ i
LEFT JOIN folio_users.users__ u
       ON u.id = (i.jsonb->'metadata'->>'updatedByUserId')::uuid
WHERE (i.jsonb->>'discoverySuppress')::boolean = true
  AND (i.jsonb->'metadata'->>'updatedDate')::date BETWEEN start_date AND end_date
  AND i.__current
GROUP BY ROLLUP (
    to_char(
        date_trunc('month', (i.jsonb->'metadata'->>'updatedDate')::date),
        'YYYY-MM'
    ),
    (u.jsonb->'personal'->>'firstName' || ' ' || (u.jsonb->'personal'->>'lastName'))
)
ORDER BY
    to_char(
        date_trunc('month', (i.jsonb->'metadata'->>'updatedDate')::date),
        'YYYY-MM'
    ) DESC NULLS LAST,
    (u.jsonb->'personal'->>'firstName' || ' ' || (u.jsonb->'personal'->>'lastName')) NULLS LAST;
$$
LANGUAGE SQL
STABLE
PARALLEL SAFE;
