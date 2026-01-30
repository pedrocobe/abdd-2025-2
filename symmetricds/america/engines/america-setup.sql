-- ============================================
-- 1. DEFINIR GRUPOS DE NODOS
-- ============================================
insert into sym_node_group (node_group_id, description) 
values ('america-store', 'Stores in America region');

insert into sym_node_group (node_group_id, description) 
values ('europe-store', 'Stores in Europe region');

-- ============================================
-- 2. DEFINIR ENLACES ENTRE GRUPOS (Bidireccional)
-- ============================================
-- América → Europa
insert into sym_node_group_link 
  (source_node_group_id, target_node_group_id, data_event_action) 
values ('america-store', 'europe-store', 'W');

-- Europa → América
insert into sym_node_group_link 
  (source_node_group_id, target_node_group_id, data_event_action) 
values ('europe-store', 'america-store', 'W');

-- ============================================
-- 3. DEFINIR CANALES
-- ============================================
-- Canal para productos
insert into sym_channel 
  (channel_id, processing_order, max_batch_size, enabled, description)
values ('products_channel', 10, 10000, 1, 'Channel for products catalog');

-- Canal para inventario
insert into sym_channel 
  (channel_id, processing_order, max_batch_size, enabled, description)
values ('inventory_channel', 20, 10000, 1, 'Channel for inventory data');

-- Canal para clientes
insert into sym_channel 
  (channel_id, processing_order, max_batch_size, enabled, description)
values ('customers_channel', 30, 10000, 1, 'Channel for customer data');

-- Canal para promociones
insert into sym_channel 
  (channel_id, processing_order, max_batch_size, enabled, description)
values ('promotions_channel', 40, 10000, 1, 'Channel for promotions');

-- ============================================
-- 4. DEFINIR TRIGGERS (Captura de cambios)
-- ============================================
-- Trigger para products
insert into sym_trigger 
  (trigger_id, source_table_name, channel_id, 
   last_update_time, create_time)
values ('products_trigger', 'products', 'products_channel', 
   current_timestamp, current_timestamp);

-- Trigger para inventory
insert into sym_trigger 
  (trigger_id, source_table_name, channel_id, 
   last_update_time, create_time)
values ('inventory_trigger', 'inventory', 'inventory_channel', 
   current_timestamp, current_timestamp);

-- Trigger para customers
insert into sym_trigger 
  (trigger_id, source_table_name, channel_id, 
   last_update_time, create_time)
values ('customers_trigger', 'customers', 'customers_channel', 
   current_timestamp, current_timestamp);

-- Trigger para promotions
insert into sym_trigger 
  (trigger_id, source_table_name, channel_id, 
   last_update_time, create_time)
values ('promotions_trigger', 'promotions', 'promotions_channel', 
   current_timestamp, current_timestamp);

-- ============================================
-- 5. DEFINIR ROUTERS (Enrutamiento de datos)
-- ============================================
-- Router América → Europa

insert into sym_router 
  (router_id, source_node_group_id, target_node_group_id, 
   router_type, create_time, last_update_time)
values ('america_to_europe', 'america-store', 'europe-store', 
   'default', current_timestamp, current_timestamp);

-- Router Europa → América
insert into sym_router 
  (router_id, source_node_group_id, target_node_group_id, 
   router_type, create_time, last_update_time)
values ('europe_to_america', 'europe-store', 'america-store', 
   'default', current_timestamp, current_timestamp);

-- ============================================
-- 6. VINCULAR TRIGGERS CON ROUTERS
-- ============================================
-- Products: América → Europa
insert into sym_trigger_router 
  (trigger_id, router_id, initial_load_order, 
   last_update_time, create_time)
values ('products_trigger', 'america_to_europe', 100, 
   current_timestamp, current_timestamp);

-- Products: Europa → América
insert into sym_trigger_router 
  (trigger_id, router_id, initial_load_order, 
   last_update_time, create_time)
values ('products_trigger', 'europe_to_america', 100, 
   current_timestamp, current_timestamp);

-- Inventory: América → Europa
insert into sym_trigger_router 
  (trigger_id, router_id, initial_load_order, 
   last_update_time, create_time)
values ('inventory_trigger', 'america_to_europe', 200, 
   current_timestamp, current_timestamp);

-- Inventory: Europa → América
insert into sym_trigger_router 
  (trigger_id, router_id, initial_load_order, 
   last_update_time, create_time)
values ('inventory_trigger', 'europe_to_america', 200, 
   current_timestamp, current_timestamp);

-- Customers: América → Europa
insert into sym_trigger_router 
  (trigger_id, router_id, initial_load_order, 
   last_update_time, create_time)
values ('customers_trigger', 'america_to_europe', 300, 
   current_timestamp, current_timestamp);

-- Customers: Europa → América
insert into sym_trigger_router 
  (trigger_id, router_id, initial_load_order, 
   last_update_time, create_time)
values ('customers_trigger', 'europe_to_america', 300, 
   current_timestamp, current_timestamp);

-- Promotions: América → Europa
insert into sym_trigger_router 
  (trigger_id, router_id, initial_load_order, 
   last_update_time, create_time)
values ('promotions_trigger', 'america_to_europe', 400, 
   current_timestamp, current_timestamp);

-- Promotions: Europa → América
insert into sym_trigger_router 
  (trigger_id, router_id, initial_load_order, 
   last_update_time, create_time)
values ('promotions_trigger', 'europe_to_america', 400, 
   current_timestamp, current_timestamp);