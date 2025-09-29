--metadb:function emprestimos_vigentes

DROP FUNCTION IF EXISTS emprestimos_vigentes;

CREATE FUNCTION emprestimos_vigentes()
RETURNS TABLE(
    item_barcode text,
    item_effective_shelving_order text,
    usuario_barcode text,
    usuario_nome text,
    departamento text,
    posicao text,
    ponto_servico_checkout text,
    itemid text,
    item_estado text,
    data_emprestimo text,
    data_devolucao text,
    tipo_material text)
AS $$

SELECT distinct i.title, 
    i2.barcode, 
    i2.effective_shelving_order,
    (u.jsonb->>'barcode') AS patron_barcode,
    (u.jsonb->'personal'->>'firstName' || ' ' || (u.jsonb->'personal'->>'lastName')) AS patron,
    (u.jsonb->'customFields'->>'link') as Departamento, 
    (u.jsonb->'customFields'->>'position') as Posicao,
    sp.discovery_display_name  as checkout_sp,
    l.item_id,
    l.item_status ,
    l.loan_date ,
    l.due_date ,
    mt.name as material_type
    
from  folio_circulation.loan__t__ l 
    LEFT JOIN folio_users.users__ u  ON u.id = l.user_id 
    left join folio_inventory.item__t__ i2 on i2.id = l.item_id 
    left join folio_inventory.holdings_record__t__ ht on ht.id= i2.holdings_record_id 
    left join folio_inventory.instance__t__ i on i.id = ht.instance_id 
    left join folio_inventory.service_point__t__ sp on sp.id =l.checkout_service_point_id 
    left join folio_inventory.material_type__t__ mt on mt.id = i2.material_type_id

WHERE l.due_date > now() 
and l.item_status ='Checked out' 
and l.action='checkedout' 

ORDER BY l.loan_date  desc, patron


$$
LANGUAGE SQL
STABLE
PARALLEL SAFE;
