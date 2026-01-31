-- 1. Grupos de nodos
INSERT INTO sym_node_group (node_group_id, description) VALUES ('america-store', 'America region');
INSERT INTO sym_node_group (node_group_id, description) VALUES ('europe-store', 'Europe region');

-- 2. Enlaces bidireccionales (W = Wait/Write)
INSERT INTO sym_node_group_link (source_node_group_id, target_node_group_id, data_event_action) VALUES ('america-store', 'europe-store', 'W');
INSERT INTO sym_node_group_link (source_node_group_id, target_node_group_id, data_event_action) VALUES ('europe-store', 'america-store', 'W');

-- 3. Canales (uno por tabla)
INSERT INTO sym_channel (channel_id, processing_order, max_batch_size, enabled, description) VALUES ('products-channel', 1, 1000, 1, 'Products');
INSERT INTO sym_channel (channel_id, processing_order, max_batch_size, enabled, description) VALUES ('inventory-channel', 2, 1000, 1, 'Inventory');
INSERT INTO sym_channel (channel_id, processing_order, max_batch_size, enabled, description) VALUES ('customers-channel', 3, 1000, 1, 'Customers');
INSERT INTO sym_channel (channel_id, processing_order, max_batch_size, enabled, description) VALUES ('promotions-channel', 4, 1000, 1, 'Promotions');

-- 4. Triggers (uno por tabla)
INSERT INTO sym_trigger (trigger_id, source_table_name, channel_id, sync_on_insert, sync_on_update, sync_on_delete, create_time, last_update_time) 
VALUES ('products-trigger', 'products', 'products-channel', 1, 1, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO sym_trigger (trigger_id, source_table_name, channel_id, sync_on_insert, sync_on_update, sync_on_delete, create_time, last_update_time) 
VALUES ('inventory-trigger', 'inventory', 'inventory-channel', 1, 1, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO sym_trigger (trigger_id, source_table_name, channel_id, sync_on_insert, sync_on_update, sync_on_delete, create_time, last_update_time) 
VALUES ('customers-trigger', 'customers', 'customers-channel', 1, 1, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO sym_trigger (trigger_id, source_table_name, channel_id, sync_on_insert, sync_on_update, sync_on_delete, create_time, last_update_time) 
VALUES ('promotions-trigger', 'promotions', 'promotions-channel', 1, 1, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- 5. Routers bidireccionales
INSERT INTO sym_router (router_id, source_node_group_id, target_node_group_id, router_type, description) 
VALUES ('america-to-europe', 'america-store', 'europe-store', 'default', 'America to Europe');

INSERT INTO sym_router (router_id, source_node_group_id, target_node_group_id, router_type, description) 
VALUES ('europe-to-america', 'europe-store', 'america-store', 'default', 'Europe to America');

-- 6. Vincular triggers a routers (bidireccional)
INSERT INTO sym_trigger_router (trigger_id, router_id, enabled, initial_load_order, create_time, last_update_time) 
VALUES ('products-trigger', 'america-to-europe', 1, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
INSERT INTO sym_trigger_router (trigger_id, router_id, enabled, initial_load_order, create_time, last_update_time) 
VALUES ('products-trigger', 'europe-to-america', 1, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO sym_trigger_router (trigger_id, router_id, enabled, initial_load_order, create_time, last_update_time) 
VALUES ('inventory-trigger', 'america-to-europe', 1, 2, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
INSERT INTO sym_trigger_router (trigger_id, router_id, enabled, initial_load_order, create_time, last_update_time) 
VALUES ('inventory-trigger', 'europe-to-america', 1, 2, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO sym_trigger_router (trigger_id, router_id, enabled, initial_load_order, create_time, last_update_time) 
VALUES ('customers-trigger', 'america-to-europe', 1, 3, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
INSERT INTO sym_trigger_router (trigger_id, router_id, enabled, initial_load_order, create_time, last_update_time) 
VALUES ('customers-trigger', 'europe-to-america', 1, 3, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO sym_trigger_router (trigger_id, router_id, enabled, initial_load_order, create_time, last_update_time) 
VALUES ('promotions-trigger', 'america-to-europe', 1, 4, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
INSERT INTO sym_trigger_router (trigger_id, router_id, enabled, initial_load_order, create_time, last_update_time) 
VALUES ('promotions-trigger', 'europe-to-america', 1, 4, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
