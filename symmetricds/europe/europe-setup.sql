-- ===============================
-- TRIGGERS (EUROPA)
-- ===============================
insert into sym_trigger (
    trigger_id,
    source_table_name,
    channel_id,
    last_update_time,
    create_time
) values
('products', 'products', 'products', current_timestamp, current_timestamp);

-- ===============================
-- ROUTERS (EUROPA → AMERICA)
-- ===============================
insert into sym_router (
    router_id,
    source_node_group_id,
    target_node_group_id,
    router_type,
    create_time,
    last_update_time
) values
('to-america', 'europe', 'america', 'default', current_timestamp, current_timestamp);

-- ===============================
-- TRIGGER ROUTER
-- ===============================
insert into sym_trigger_router (
    trigger_id,
    router_id,
    initial_load_order,
    create_time,
    last_update_time
) values
('products', 'to-america', 100, current_timestamp, current_timestamp);
