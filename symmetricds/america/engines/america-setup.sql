-- SymmetricDS setup for America (nombre de ejemplo)
-- Inserciones básicas para que el sistema tenga los objetos necesarios

INSERT INTO sym_node_group (node_group_id, description) VALUES ('america-store','America store');
INSERT INTO sym_node_group (node_group_id, description) VALUES ('europe-store','Europe store');

-- enlaces bidireccionales entre grupos
INSERT INTO sym_node_group_link (source_node_group_id, target_node_group_id) VALUES ('america-store','europe-store');
INSERT INTO sym_node_group_link (source_node_group_id, target_node_group_id) VALUES ('europe-store','america-store');

-- canales y triggers (ejemplos abbreviados)
INSERT INTO sym_channel (channel_id, description) VALUES ('products','Canal para products');
INSERT INTO sym_channel (channel_id, description) VALUES ('inventory','Canal para inventory');
INSERT INTO sym_channel (channel_id, description) VALUES ('customers','Canal para customers');
INSERT INTO sym_channel (channel_id, description) VALUES ('promotions','Canal para promotions');

-- triggers para tablas de negocio
INSERT INTO sym_trigger (trigger_id, source_table_name, channel_id, sync_on_insert, sync_on_update, sync_on_delete) VALUES ('trg_products','products','products',1,1,1);
INSERT INTO sym_trigger (trigger_id, source_table_name, channel_id, sync_on_insert, sync_on_update, sync_on_delete) VALUES ('trg_inventory','inventory','inventory',1,1,1);
INSERT INTO sym_trigger (trigger_id, source_table_name, channel_id, sync_on_insert, sync_on_update, sync_on_delete) VALUES ('trg_customers','customers','customers',1,1,1);
INSERT INTO sym_trigger (trigger_id, source_table_name, channel_id, sync_on_insert, sync_on_update, sync_on_delete) VALUES ('trg_promotions','promotions','promotions',1,1,1);

-- routers y asignaciones (ejemplos)
INSERT INTO sym_router (router_id, source_node_group_id) VALUES ('router_all','america-store');
INSERT INTO sym_trigger_router (trigger_id, router_id) VALUES ('trg_products','router_all');
INSERT INTO sym_trigger_router (trigger_id, router_id) VALUES ('trg_inventory','router_all');
INSERT INTO sym_trigger_router (trigger_id, router_id) VALUES ('trg_customers','router_all');
INSERT INTO sym_trigger_router (trigger_id, router_id) VALUES ('trg_promotions','router_all');


-- Fin del script de setup para America
-- Fin del script de setup para America
