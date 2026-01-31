-- ============================================
-- SymmetricDS Configuration - AMÉRICA (ROOT NODE)
-- ============================================
-- Configuración de replicación bidireccional
-- PostgreSQL (América) <-> MySQL (Europa)
-- Este script se ejecuta automáticamente al iniciar
-- ============================================

-- ============================================
-- 1. DEFINIR GRUPOS DE NODOS
-- ============================================
INSERT INTO sym_node_group (node_group_id, description) 
VALUES ('america-store', 'Stores in America region')
ON CONFLICT (node_group_id) DO NOTHING;

INSERT INTO sym_node_group (node_group_id, description) 
VALUES ('europe-store', 'Stores in Europe region')
ON CONFLICT (node_group_id) DO NOTHING;

-- ============================================
-- 2. DEFINIR ENLACES ENTRE GRUPOS (Bidireccional)
-- ============================================
INSERT INTO sym_node_group_link 
  (source_node_group_id, target_node_group_id, data_event_action) 
VALUES ('america-store', 'europe-store', 'P')
ON CONFLICT (source_node_group_id, target_node_group_id) DO NOTHING;

INSERT INTO sym_node_group_link 
  (source_node_group_id, target_node_group_id, data_event_action) 
VALUES ('europe-store', 'america-store', 'P')
ON CONFLICT (source_node_group_id, target_node_group_id) DO NOTHING;

-- ============================================
-- 3. DEFINIR CANALES DE SINCRONIZACIÓN
-- ============================================
INSERT INTO sym_channel 
  (channel_id, processing_order, max_batch_size, enabled, description)
VALUES ('products_channel', 10, 10000, 1, 'Channel for products catalog')
ON CONFLICT (channel_id) DO NOTHING;

INSERT INTO sym_channel 
  (channel_id, processing_order, max_batch_size, enabled, description)
VALUES ('inventory_channel', 20, 10000, 1, 'Channel for inventory data')
ON CONFLICT (channel_id) DO NOTHING;

INSERT INTO sym_channel 
  (channel_id, processing_order, max_batch_size, enabled, description)
VALUES ('customers_channel', 30, 10000, 1, 'Channel for customer data')
ON CONFLICT (channel_id) DO NOTHING;

INSERT INTO sym_channel 
  (channel_id, processing_order, max_batch_size, enabled, description)
VALUES ('promotions_channel', 40, 10000, 1, 'Channel for promotions')
ON CONFLICT (channel_id) DO NOTHING;

-- ============================================
-- 4. DEFINIR TRIGGERS (Captura de cambios)
-- ============================================
INSERT INTO sym_trigger 
  (trigger_id, source_table_name, channel_id, last_update_time, create_time)
VALUES ('products_trigger', 'products', 'products_channel', 
   CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT (trigger_id) DO NOTHING;

INSERT INTO sym_trigger 
  (trigger_id, source_table_name, channel_id, last_update_time, create_time)
VALUES ('inventory_trigger', 'inventory', 'inventory_channel', 
   CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT (trigger_id) DO NOTHING;

INSERT INTO sym_trigger 
  (trigger_id, source_table_name, channel_id, last_update_time, create_time)
VALUES ('customers_trigger', 'customers', 'customers_channel', 
   CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT (trigger_id) DO NOTHING;

INSERT INTO sym_trigger 
  (trigger_id, source_table_name, channel_id, last_update_time, create_time)
VALUES ('promotions_trigger', 'promotions', 'promotions_channel', 
   CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT (trigger_id) DO NOTHING;

-- ============================================
-- 5. DEFINIR ROUTERS (Enrutamiento de datos)
-- ============================================
INSERT INTO sym_router 
  (router_id, source_node_group_id, target_node_group_id, router_type, create_time, last_update_time)
VALUES ('america_to_europe', 'america-store', 'europe-store', 
   'default', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT (router_id) DO NOTHING;

INSERT INTO sym_router 
  (router_id, source_node_group_id, target_node_group_id, router_type, create_time, last_update_time)
VALUES ('europe_to_america', 'europe-store', 'america-store', 
   'default', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT (router_id) DO NOTHING;

-- ============================================
-- 6. VINCULAR TRIGGERS CON ROUTERS
-- ============================================
INSERT INTO sym_trigger_router 
  (trigger_id, router_id, initial_load_order, last_update_time, create_time)
VALUES ('products_trigger', 'america_to_europe', 100, 
   CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT (trigger_id, router_id) DO NOTHING;

INSERT INTO sym_trigger_router 
  (trigger_id, router_id, initial_load_order, last_update_time, create_time)
VALUES ('products_trigger', 'europe_to_america', 100, 
   CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT (trigger_id, router_id) DO NOTHING;

INSERT INTO sym_trigger_router 
  (trigger_id, router_id, initial_load_order, last_update_time, create_time)
VALUES ('inventory_trigger', 'america_to_europe', 200, 
   CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT (trigger_id, router_id) DO NOTHING;

INSERT INTO sym_trigger_router 
  (trigger_id, router_id, initial_load_order, last_update_time, create_time)
VALUES ('inventory_trigger', 'europe_to_america', 200, 
   CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT (trigger_id, router_id) DO NOTHING;

INSERT INTO sym_trigger_router 
  (trigger_id, router_id, initial_load_order, last_update_time, create_time)
VALUES ('customers_trigger', 'america_to_europe', 300, 
   CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT (trigger_id, router_id) DO NOTHING;

INSERT INTO sym_trigger_router 
  (trigger_id, router_id, initial_load_order, last_update_time, create_time)
VALUES ('customers_trigger', 'europe_to_america', 300, 
   CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT (trigger_id, router_id) DO NOTHING;

INSERT INTO sym_trigger_router 
  (trigger_id, router_id, initial_load_order, last_update_time, create_time)
VALUES ('promotions_trigger', 'america_to_europe', 400, 
   CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT (trigger_id, router_id) DO NOTHING;

INSERT INTO sym_trigger_router 
  (trigger_id, router_id, initial_load_order, last_update_time, create_time)
VALUES ('promotions_trigger', 'europe_to_america', 400, 
   CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT (trigger_id, router_id) DO NOTHING;

-- ============================================
-- 7. REGISTRAR NODO EUROPA (permitir conexión)
-- ============================================
INSERT INTO sym_node (node_id, node_group_id, external_id, sync_enabled, created_at_node_id)
VALUES ('002', 'europe-store', '002', 1, '001')
ON CONFLICT (node_id) DO NOTHING;

INSERT INTO sym_node_security (node_id, node_password, registration_enabled, registration_time, initial_load_enabled, initial_load_time, created_at_node_id)
VALUES ('002', 'changeme', 1, CURRENT_TIMESTAMP, 1, CURRENT_TIMESTAMP, '001')
ON CONFLICT (node_id) DO NOTHING;

-- ============================================
-- FIN DE CONFIGURACIÓN
-- ============================================
