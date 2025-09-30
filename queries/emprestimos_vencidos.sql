--metadb:function emprestimos_vencidos

DROP FUNCTION IF EXISTS emprestimos_vencidos;

CREATE FUNCTION emprestimos_vencidos(
    start_date date DEFAULT '2020-01-01',
    end_date date DEFAULT '2050-01-01'    
)
RETURNS TABLE(
    title text,
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
    data_devolucao_esperada text,
    data_devolucao_efectiva text,
    tipo_material text)
AS $$


SELECT distinct 
    i.title, 
    i2.barcode as item_barcode, 
    i2.effective_shelving_order as item_effective_shelving_order,
    (u.jsonb->>'barcode') AS usuario_barcode,
    (u.jsonb->'personal'->>'firstName' || ' ' || (u.jsonb->'personal'->>'lastName')) AS usuario_nome,
    (u.jsonb->'customFields'->>'link') as Departamento, 
    (u.jsonb->'customFields'->>'position') as Posicao,
    sp.discovery_display_name  as ponto_servico_checkout,
    l.item_id as itemid,
    l.item_status as item_estado,
    l.loan_date as data_emprestimo ,
    l.due_date as data_devolucao_esperada,
    l.return_date as data_devolucao_efectiva,
    mt.name as tipo_material
    
from  folio_circulation.loan__t__ l 
    LEFT JOIN folio_users.users__ u  ON u.id = l.user_id 
    left join folio_inventory.item__t__ i2 on i2.id = l.item_id 
    left join folio_inventory.holdings_record__t__ ht on ht.id= i2.holdings_record_id 
    left join folio_inventory.instance__t__ i on i.id = ht.instance_id 
    left join folio_inventory.service_point__t__ sp on sp.id =l.checkout_service_point_id 
    left join folio_inventory.material_type__t__ mt on mt.id = i2.material_type_id

WHERE l.item_status <>'Checked out' 
and  l.return_date between start_date and end_date    
ORDER BY data_devolucao_efectiva  desc, usuario_nome
$$
LANGUAGE SQL
STABLE
PARALLEL SAFE;
