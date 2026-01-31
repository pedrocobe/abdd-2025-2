-- -----------------------------------------------
-- Script de configuración SymmetricDS
-- Implementación de replicación de datos bidireccional
-- entre nodos PostgreSQL y MySQL
-- -----------------------------------------------

-- 1. GRUPOS DE NODOS (regiones geográficas)
INSERT INTO sym_node_group (node_group_id, description) 
VALUES ('america-store', 'Nodo principal - continente americano')
ON CONFLICT (node_group_id) DO NOTHING;

INSERT INTO sym_node_group (node_group_id, description) 
VALUES ('europe-store', 'Nodo secundario - continente europeo')
ON CONFLICT (node_group_id) DO NOTHING;

-- 2. ENLACES DE COMUNICACIÓN (sincronización en ambas direcciones)
-- W = Wait - el destino solicita los datos mediante PULL
INSERT INTO sym_node_group_link 
  (source_node_group_id, target_node_group_id, data_event_action) 
VALUES ('america-store', 'europe-store', 'W')
ON CONFLICT (source_node_group_id, target_node_group_id) DO UPDATE SET data_event_action = 'W';

INSERT INTO sym_node_group_link 
  (source_node_group_id, target_node_group_id, data_event_action) 
VALUES ('europe-store', 'america-store', 'W')
ON CONFLICT (source_node_group_id, target_node_group_id) DO UPDATE SET data_event_action = 'W';

-- 3. CANALES DE DATOS (separación lógica por tipo de información)
INSERT INTO sym_channel 
  (channel_id, processing_order, max_batch_size, enabled, description)
VALUES ('products_channel', 10, 10000, 1, 'Sincronizacion de catalogo de productos')
ON CONFLICT (channel_id) DO NOTHING;

INSERT INTO sym_channel 
  (channel_id, processing_order, max_batch_size, enabled, description)
VALUES ('inventory_channel', 20, 10000, 1, 'Sincronizacion de stock e inventarios')
ON CONFLICT (channel_id) DO NOTHING;

INSERT INTO sym_channel 
  (channel_id, processing_order, max_batch_size, enabled, description)
VALUES ('customers_channel', 30, 10000, 1, 'Sincronizacion de registros de clientes')
ON CONFLICT (channel_id) DO NOTHING;

INSERT INTO sym_channel 
  (channel_id, processing_order, max_batch_size, enabled, description)
VALUES ('promotions_channel', 40, 10000, 1, 'Sincronizacion de ofertas y descuentos')
ON CONFLICT (channel_id) DO NOTHING;

-- 4. TRIGGERS DE CAPTURA (detectan cambios en tablas)
INSERT INTO sym_trigger 
  (trigger_id, source_table_name, channel_id, last_update_time, create_time)
VALUES ('products_trigger', 'products', 'products_channel', current_timestamp, current_timestamp)
ON CONFLICT (trigger_id) DO NOTHING;

INSERT INTO sym_trigger 
  (trigger_id, source_table_name, channel_id, last_update_time, create_time)
VALUES ('inventory_trigger', 'inventory', 'inventory_channel', current_timestamp, current_timestamp)
ON CONFLICT (trigger_id) DO NOTHING;

INSERT INTO sym_trigger 
  (trigger_id, source_table_name, channel_id, last_update_time, create_time)
VALUES ('customers_trigger', 'customers', 'customers_channel', current_timestamp, current_timestamp)
ON CONFLICT (trigger_id) DO NOTHING;

INSERT INTO sym_trigger 
  (trigger_id, source_table_name, channel_id, last_update_time, create_time)
VALUES ('promotions_trigger', 'promotions', 'promotions_channel', current_timestamp, current_timestamp)
ON CONFLICT (trigger_id) DO NOTHING;

-- 5. ROUTERS (definen dirección del flujo de datos)
INSERT INTO sym_router 
  (router_id, source_node_group_id, target_node_group_id, router_type, create_time, last_update_time)
VALUES ('america_to_europe', 'america-store', 'europe-store', 'default', current_timestamp, current_timestamp)
ON CONFLICT (router_id) DO NOTHING;

INSERT INTO sym_router 
  (router_id, source_node_group_id, target_node_group_id, router_type, create_time, last_update_time)
VALUES ('europe_to_america', 'europe-store', 'america-store', 'default', current_timestamp, current_timestamp)
ON CONFLICT (router_id) DO NOTHING;

-- 6. ASOCIACIÓN TRIGGER-ROUTER (qué tablas van a qué destinos)
INSERT INTO sym_trigger_router 
  (trigger_id, router_id, initial_load_order, last_update_time, create_time)
VALUES ('products_trigger', 'america_to_europe', 100, current_timestamp, current_timestamp)
ON CONFLICT (trigger_id, router_id) DO NOTHING;

INSERT INTO sym_trigger_router 
  (trigger_id, router_id, initial_load_order, last_update_time, create_time)
VALUES ('products_trigger', 'europe_to_america', 100, current_timestamp, current_timestamp)
ON CONFLICT (trigger_id, router_id) DO NOTHING;

INSERT INTO sym_trigger_router 
  (trigger_id, router_id, initial_load_order, last_update_time, create_time)
VALUES ('inventory_trigger', 'america_to_europe', 200, current_timestamp, current_timestamp)
ON CONFLICT (trigger_id, router_id) DO NOTHING;

INSERT INTO sym_trigger_router 
  (trigger_id, router_id, initial_load_order, last_update_time, create_time)
VALUES ('inventory_trigger', 'europe_to_america', 200, current_timestamp, current_timestamp)
ON CONFLICT (trigger_id, router_id) DO NOTHING;

INSERT INTO sym_trigger_router 
  (trigger_id, router_id, initial_load_order, last_update_time, create_time)
VALUES ('customers_trigger', 'america_to_europe', 300, current_timestamp, current_timestamp)
ON CONFLICT (trigger_id, router_id) DO NOTHING;

INSERT INTO sym_trigger_router 
  (trigger_id, router_id, initial_load_order, last_update_time, create_time)
VALUES ('customers_trigger', 'europe_to_america', 300, current_timestamp, current_timestamp)
ON CONFLICT (trigger_id, router_id) DO NOTHING;

INSERT INTO sym_trigger_router 
  (trigger_id, router_id, initial_load_order, last_update_time, create_time)
VALUES ('promotions_trigger', 'america_to_europe', 400, current_timestamp, current_timestamp)
ON CONFLICT (trigger_id, router_id) DO NOTHING;

INSERT INTO sym_trigger_router 
  (trigger_id, router_id, initial_load_order, last_update_time, create_time)
VALUES ('promotions_trigger', 'europe_to_america', 400, current_timestamp, current_timestamp)
ON CONFLICT (trigger_id, router_id) DO NOTHING;
