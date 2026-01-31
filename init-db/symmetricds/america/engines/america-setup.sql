-- =========================================================
-- AMERICA SETUP (PostgreSQL) - FIXED / IDEMPOTENTE
-- Objetivo: asegurar que el nodo America permita el registro del nodo Europe
--           y que exista la configuración base (grupos, links, canales, triggers, routers).
--
-- Cómo ejecutar (desde tu PC, ejemplo):
--   docker exec -i postgres-america psql -U symmetricds -d globalshop < america-setup.sql
-- =========================================================

-- 1) DEFINIR GRUPOS DE NODOS
INSERT INTO sym_node_group (node_group_id, description, create_time, last_update_time)
VALUES
  ('america-store', 'Stores in America region', current_timestamp, current_timestamp),
  ('europe-store',  'Stores in Europe region',  current_timestamp, current_timestamp)
ON CONFLICT (node_group_id) DO NOTHING;

-- 2) DEFINIR ENLACES ENTRE GRUPOS (BIDIRECCIONAL)
--    Esto es lo que te faltaba en la BD (sym_node_group_link estaba vacío).
INSERT INTO sym_node_group_link
  (source_node_group_id, target_node_group_id, data_event_action,
   sync_config_enabled, sync_sql_enabled, is_reversible, create_time, last_update_time)
VALUES
  ('america-store', 'europe-store',  'W', 1, 1, 1, current_timestamp, current_timestamp),
  ('europe-store',  'america-store', 'W', 1, 1, 1, current_timestamp, current_timestamp)
ON CONFLICT (source_node_group_id, target_node_group_id) DO NOTHING;

-- 3) DEFINIR CANALES
INSERT INTO sym_channel
  (channel_id, processing_order, max_batch_size, enabled, description, create_time, last_update_time)
VALUES
  ('products',    10, 10000, 1, 'Channel for products catalog', current_timestamp, current_timestamp),
  ('inventory',   20, 10000, 1, 'Channel for inventory data',   current_timestamp, current_timestamp),
  ('customers',   30, 10000, 1, 'Channel for customer data',    current_timestamp, current_timestamp),
  ('promotions',  40, 10000, 1, 'Channel for promotions',       current_timestamp, current_timestamp)
ON CONFLICT (channel_id) DO NOTHING;

-- 4) DEFINIR TRIGGERS
INSERT INTO sym_trigger
  (trigger_id, source_table_name, channel_id, create_time, last_update_time)
VALUES
  ('trg_products',    'products',    'products',   current_timestamp, current_timestamp),
  ('trg_inventory',   'inventory',   'inventory',  current_timestamp, current_timestamp),
  ('trg_customers',   'customers',   'customers',  current_timestamp, current_timestamp),
  ('trg_promotions',  'promotions',  'promotions', current_timestamp, current_timestamp)
ON CONFLICT (trigger_id) DO NOTHING;

-- 5) DEFINIR ROUTERS
INSERT INTO sym_router
  (router_id, source_node_group_id, target_node_group_id, router_type, create_time, last_update_time)
VALUES
  ('america_to_europe', 'america-store', 'europe-store',  'default', current_timestamp, current_timestamp),
  ('europe_to_america', 'europe-store',  'america-store', 'default', current_timestamp, current_timestamp)
ON CONFLICT (router_id) DO NOTHING;

-- 6) VINCULAR TRIGGERS CON ROUTERS
INSERT INTO sym_trigger_router
  (trigger_id, router_id, enabled, initial_load_order, create_time, last_update_time)
VALUES
  ('trg_products',   'america_to_europe', 1, 1, current_timestamp, current_timestamp),
  ('trg_products',   'europe_to_america', 1, 1, current_timestamp, current_timestamp),

  ('trg_inventory',  'america_to_europe', 1, 1, current_timestamp, current_timestamp),
  ('trg_inventory',  'europe_to_america', 1, 1, current_timestamp, current_timestamp),

  ('trg_customers',  'america_to_europe', 1, 1, current_timestamp, current_timestamp),
  ('trg_customers',  'europe_to_america', 1, 1, current_timestamp, current_timestamp),

  ('trg_promotions', 'america_to_europe', 1, 1, current_timestamp, current_timestamp),
  ('trg_promotions', 'europe_to_america', 1, 1, current_timestamp, current_timestamp)
ON CONFLICT (trigger_id, router_id) DO NOTHING;

