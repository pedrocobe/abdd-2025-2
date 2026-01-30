-- Node Groups
insert into sym_node_group (node_group_id, description) values ('america-store', 'America region');
insert into sym_node_group (node_group_id, description) values ('europe-store', 'Europe region');

-- Node Group Links (bidirectional replication with 'P' for Push)
insert into sym_node_group_link (source_node_group_id, target_node_group_id, data_event_action) values ('america-store', 'europe-store', 'P');
insert into sym_node_group_link (source_node_group_id, target_node_group_id, data_event_action) values ('europe-store', 'america-store', 'P');

-- Register the Europe node to allow registration
insert into sym_node (node_id, node_group_id, external_id, sync_enabled) values ('002', 'europe-store', '002', 1);
insert into sym_node_security (node_id, node_password, registration_enabled, initial_load_enabled) values ('002', 'symmetricds', 1, 1);

-- Channels
insert into sym_channel (channel_id, processing_order, max_batch_size, enabled, description) values ('products_channel', 10, 1000, 1, 'Channel for Products');
insert into sym_channel (channel_id, processing_order, max_batch_size, enabled, description) values ('inventory_channel', 20, 1000, 1, 'Channel for Inventory');
insert into sym_channel (channel_id, processing_order, max_batch_size, enabled, description) values ('customers_channel', 30, 1000, 1, 'Channel for Customers');
insert into sym_channel (channel_id, processing_order, max_batch_size, enabled, description) values ('promotions_channel', 40, 1000, 1, 'Channel for Promotions');

insert into sym_trigger (trigger_id, source_table_name, channel_id, last_update_time, create_time) values ('products_trigger', 'products', 'products_channel', current_timestamp, current_timestamp);
insert into sym_trigger (trigger_id, source_table_name, channel_id, last_update_time, create_time) values ('inventory_trigger', 'inventory', 'inventory_channel', current_timestamp, current_timestamp);
insert into sym_trigger (trigger_id, source_table_name, channel_id, last_update_time, create_time) values ('customers_trigger', 'customers', 'customers_channel', current_timestamp, current_timestamp);
insert into sym_trigger (trigger_id, source_table_name, channel_id, last_update_time, create_time) values ('promotions_trigger', 'promotions', 'promotions_channel', current_timestamp, current_timestamp);

insert into sym_router (router_id, source_node_group_id, target_node_group_id, router_type, create_time, last_update_time) values ('america_to_europe', 'america-store', 'europe-store', 'default', current_timestamp, current_timestamp);
insert into sym_router (router_id, source_node_group_id, target_node_group_id, router_type, create_time, last_update_time) values ('europe_to_america', 'europe-store', 'america-store', 'default', current_timestamp, current_timestamp);

insert into sym_trigger_router (trigger_id, router_id, initial_load_order, last_update_time, create_time) values ('products_trigger', 'america_to_europe', 100, current_timestamp, current_timestamp);
insert into sym_trigger_router (trigger_id, router_id, initial_load_order, last_update_time, create_time) values ('products_trigger', 'europe_to_america', 100, current_timestamp, current_timestamp);
insert into sym_trigger_router (trigger_id, router_id, initial_load_order, last_update_time, create_time) values ('inventory_trigger', 'america_to_europe', 200, current_timestamp, current_timestamp);
insert into sym_trigger_router (trigger_id, router_id, initial_load_order, last_update_time, create_time) values ('inventory_trigger', 'europe_to_america', 200, current_timestamp, current_timestamp);
insert into sym_trigger_router (trigger_id, router_id, initial_load_order, last_update_time, create_time) values ('customers_trigger', 'america_to_europe', 300, current_timestamp, current_timestamp);
insert into sym_trigger_router (trigger_id, router_id, initial_load_order, last_update_time, create_time) values ('customers_trigger', 'europe_to_america', 300, current_timestamp, current_timestamp);
insert into sym_trigger_router (trigger_id, router_id, initial_load_order, last_update_time, create_time) values ('promotions_trigger', 'america_to_europe', 400, current_timestamp, current_timestamp);
insert into sym_trigger_router (trigger_id, router_id, initial_load_order, last_update_time, create_time) values ('promotions_trigger', 'europe_to_america', 400, current_timestamp, current_timestamp);
