--metadb:function monografias_petrobras_sem_electronico

DROP FUNCTION IF EXISTS monografias_petrobras_sem_electronico;

CREATE FUNCTION monografias_petrobras_sem_electronico()
RETURNS TABLE(
    id text, 
    title text,
    material_type text,
    total bigint
)
AS $$
SELECT 
    i.id, 
    i.jsonb->>'title' AS title,
    mt.name AS material_type,
    COUNT(*) AS total
FROM folio_inventory.item__t__ i2
LEFT JOIN folio_inventory.holdings_record__t__ ht 
       ON ht.id = i2.holdings_record_id 
LEFT JOIN folio_inventory.instance__ i 
       ON i.id = ht.instance_id 
LEFT JOIN folio_inventory.material_type__t__ mt 
       ON mt.id = i2.material_type_id
-- Expand contributors array
LEFT JOIN LATERAL jsonb_array_elements(i.jsonb->'contributors') AS contrib ON TRUE
LEFT JOIN folio_inventory.contributor_name_type__t__ ct 
       ON ct.id = (contrib->>'contributorNameTypeId')::uuid
WHERE i.__current 
  AND i2.__current 
  AND mt.name IN ('LIVRO', 'BOOK', 'MONOG')
  AND ct.name ILIKE '%Corporate%'
  AND contrib->>'name' ILIKE '%Petrobras%'
  -- exclude instances that have any electronicAccess elements
  AND (
       i.jsonb->'electronicAccess' IS NULL 
       OR jsonb_array_length(i.jsonb->'electronicAccess') = 0
      )
GROUP BY 
    i.id,
    i.jsonb->>'title',
    mt.name
ORDER BY  2,3
$$
LANGUAGE SQL
STABLE
PARALLEL SAFE;
