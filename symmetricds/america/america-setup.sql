-- ===============================
-- NODE GROUPS
-- ===============================
insert into sym_node_group (node_group_id) values ('america-store');
insert into sym_node_group (node_group_id) values ('europe-store');

-- ===============================
-- NODE GROUP LINKS (BIDIRECTIONAL)
-- ===============================
insert into sym_node_group_link 
(source_node_group_id, target_node_group_id, data_event_action) 
values ('america-store', 'europe-store', 'W');

insert into sym_node_group_link 
(source_node_group_id, target_node_group_id, data_event_action) 
values ('europe-store', 'america-store', 'P');

-- ===============================
-- CHANNELS
-- ===============================
insert into sym_channel (channel_id, processing_order, max_batch_size)
values ('products', 1, 100000);

insert into sym_channel (channel_id, processing_order, max_batch_size)
values ('inventory', 2, 100000);

insert into sym_channel (channel_id, processing_order, max_batch_size)
values ('customers', 3, 100000);

insert into sym_channel (channel_id, processing_order, max_batch_size)
values ('promotions', 4, 100000);

-- ===============================
-- TRIGGERS
-- ===============================
insert into sym_trigger 
(trigger_id, source_table_name, channel_id, last_update_time)
values ('products', 'products', 'products', current_timestamp);

insert into sym_trigger 
(trigger_id, source_table_name, channel_id, last_update_time)
values ('inventory', 'inventory', 'inventory', current_timestamp);

insert into sym_trigger 
(trigger_id, source_table_name, channel_id, last_update_time)
values ('customers', 'customers', 'customers', current_timestamp);

insert into sym_trigger 
(trigger_id, source_table_name, channel_id, last_update_time)
values ('promotions', 'promotions', 'promotions', current_timestamp);

-- ===============================
-- ROUTERS
-- ===============================
insert into sym_router (router_id, source_node_group_id, target_node_group_id, router_type)
values ('to-europe', 'america-store', 'europe-store', 'default');

insert into sym_router (router_id, source_node_group_id, target_node_group_id, router_type)
values ('to-america', 'europe-store', 'america-store', 'default');

-- ===============================
-- TRIGGER ROUTERS
-- ===============================
insert into sym_trigger_router (trigger_id, router_id)
values ('products', 'to-europe');

insert into sym_trigger_router (trigger_id, router_id)
values ('inventory', 'to-europe');

insert into sym_trigger_router (trigger_id, router_id)
values ('customers', 'to-europe');

insert into sym_trigger_router (trigger_id, router_id)
values ('promotions', 'to-europe');

insert into sym_trigger_router (trigger_id, router_id)
values ('products', 'to-america');

insert into sym_trigger_router (trigger_id, router_id)
values ('inventory', 'to-america');

insert into sym_trigger_router (trigger_id, router_id)
values ('customers', 'to-america');

insert into sym_trigger_router (trigger_id, router_id)
values ('promotions', 'to-america');
