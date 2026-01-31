-- Mismo contenido que engines/america-setup.sql pero ubicado en la raíz del engine
-- SymmetricDS will pick up SQL files located alongside the engine properties

INSERT INTO sym_node_group (node_group_id, description) VALUES ('america-store','America store');
INSERT INTO sym_node_group (node_group_id, description) VALUES ('europe-store','Europe store');

INSERT INTO sym_node_group_link (source_node_group_id, target_node_group_id) VALUES ('america-store','europe-store');
INSERT INTO sym_node_group_link (source_node_group_id, target_node_group_id) VALUES ('europe-store','america-store');

INSERT INTO sym_channel (channel_id, description) VALUES ('products','Canal para products');
INSERT INTO sym_channel (channel_id, description) VALUES ('inventory','Canal para inventory');
INSERT INTO sym_channel (channel_id, description) VALUES ('customers','Canal para customers');
INSERT INTO sym_channel (channel_id, description) VALUES ('promotions','Canal para promotions');

INSERT INTO sym_trigger (trigger_id, source_table_name, channel_id, sync_on_insert, sync_on_update, sync_on_delete) VALUES ('trg_products','products','products',1,1,1);
INSERT INTO sym_trigger (trigger_id, source_table_name, channel_id, sync_on_insert, sync_on_update, sync_on_delete) VALUES ('trg_inventory','inventory','inventory',1,1,1);
INSERT INTO sym_trigger (trigger_id, source_table_name, channel_id, sync_on_insert, sync_on_update, sync_on_delete) VALUES ('trg_customers','customers','customers',1,1,1);
INSERT INTO sym_trigger (trigger_id, source_table_name, channel_id, sync_on_insert, sync_on_update, sync_on_delete) VALUES ('trg_promotions','promotions','promotions',1,1,1);

INSERT INTO sym_router (router_id, source_node_group_id) VALUES ('router_all','america-store');
INSERT INTO sym_trigger_router (trigger_id, router_id) VALUES ('trg_products','router_all');
INSERT INTO sym_trigger_router (trigger_id, router_id) VALUES ('trg_inventory','router_all');
INSERT INTO sym_trigger_router (trigger_id, router_id) VALUES ('trg_customers','router_all');
INSERT INTO sym_trigger_router (trigger_id, router_id) VALUES ('trg_promotions','router_all');

INSERT INTO sym_node (node_id, node_group_id, external_id, sync_enabled, created_at)
VALUES ('america-001','america-store','001',1, NOW());

INSERT INTO sym_node_host (node_id, host_name, ip_address, created_at)
VALUES ('america-001', 'postgres-america', '127.0.0.1', NOW());
