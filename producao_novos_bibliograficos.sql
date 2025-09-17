select 
    (u.jsonb->'personal'->>'firstName' || ' ' || (u.jsonb->'personal'->>'lastName')) AS patron,
    to_char(
	    date_trunc('month', (i.jsonb->'metadata'->>'createdDate')::timestamp),
	    'YYYY-MM'
	) AS created_month,
    (i.jsonb->'metadata'->>'createdByUserId') AS createdby,
    COUNT(*) AS total
FROM folio_inventory.instance__ i
LEFT JOIN folio_users.users__ u
       ON u.id = (i.jsonb->'metadata'->>'createdByUserId')::uuid
GROUP BY
    created_month,
    createdby,
    patron
ORDER BY created_month DESC, patron;
