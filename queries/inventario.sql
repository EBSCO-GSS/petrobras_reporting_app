--metadb:function inventario

DROP FUNCTION IF EXISTS inventario;

CREATE FUNCTION inventario(
    desc_nota_inventario text DEFAULT '2024',
    tipo_material text DEFAULT 'monog',
    plocalizacao text DEFAULT ''
)
RETURNS TABLE(
    barcode text,
    status text,
    localizacao text,
    material_type text,
    title text,
    chamado text,
    effectiveShelvingOrder text,
    autor text,
    "Tipologia Autor" text,
    "Nota de inventário" text
    )
AS $$
SELECT DISTINCT 
    i.jsonb->>'barcode' AS barcode,
    i.jsonb->'status'->>'name' AS status,
    l.name AS localizacao, 
    mt.name AS material_type,
    i2.jsonb->>'title' AS title, 
    i.jsonb->>'itemLevelCallNumber' AS chamado,
    i.jsonb->>'effectiveShelvingOrder' AS effectiveShelvingOrder,
    contrib->>'name'  AS autor,
    contrib->>'contributorTypeText' AS "Tipologia Autor",
    note->>'note' AS "Nota de inventário"
FROM folio_inventory.item i
LEFT JOIN folio_inventory.material_type__t__ mt 
       ON mt.id = i.materialtypeid 
INNER JOIN folio_inventory.holdings_record__t__ ht 
       ON ht.id = (i.jsonb->>'holdingsRecordId')::uuid
INNER JOIN folio_inventory.instance i2 
       ON i2.id = ht.instance_id
INNER JOIN folio_inventory.location__t__ l 
       ON l.id = i.effectivelocationid 
LEFT JOIN LATERAL jsonb_array_elements(i2.jsonb->'contributors') AS contrib ON TRUE
LEFT JOIN LATERAL jsonb_array_elements(i.jsonb->'notes') AS note ON TRUE
LEFT JOIN folio_inventory.item_note_type__t__ nt 
       ON nt.id = (note->>'itemNoteTypeId')::uuid
WHERE note->>'itemNoteTypeId' = '57a435dd-b89a-4cdd-ab80-c236dd28f979'
  AND i.__current 
  AND i2.__current
  and note->>'note' LIKE '%' || desc_nota_inventario || '%'
  and localizacao LIKE '%' || plocalizacao || '%'
  and material_type LIKE '%' || tipo_material || '%'
$$
LANGUAGE SQL
STABLE
PARALLEL SAFE;
