-- ============================================
-- SymmetricDS - Configuración de Replicación Bidireccional
-- ============================================

-- ESPERAR A QUE SYMMETRICDS CREE LAS TABLAS INTERNAS
DO $$
BEGIN
  FOR i IN 1..120 LOOP
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'sym_node') THEN
      EXIT;
    END IF;
    PERFORM pg_sleep(1);
  END LOOP;
END$$;

-- ============================================
-- 1. DEFINIR GRUPO DE NODOS
-- ============================================
INSERT INTO sym_node_group (node_group_id, description) 
VALUES ('america-store', 'GlobalShop Network') 
ON CONFLICT DO NOTHING;

-- ============================================
-- 2. REGISTRAR NODOS
-- ============================================
INSERT INTO sym_node (node_id, node_group_id, external_id, symmetric_version)
VALUES ('001', 'america-store', '001', '3.16')
ON CONFLICT DO NOTHING;

INSERT INTO sym_node (node_id, node_group_id, external_id, symmetric_version)
VALUES ('002', 'america-store', '002', '3.16')
ON CONFLICT DO NOTHING;

-- ============================================
-- 3. CREAR ENLACE BIDIRECCIONAL
-- ============================================
-- Sincronización dentro del mismo grupo
INSERT INTO sym_node_group_link (source_node_group_id, target_node_group_id, data_event_action)
VALUES ('america-store', 'america-store', 'W')
ON CONFLICT DO NOTHING;

-- ============================================
-- 4. CONFIGURAR TRIGGERS - TABLA CUSTOMERS
-- ============================================
INSERT INTO sym_trigger (trigger_id, source_table_name, channel_id, reload_channel_id, sync_on_insert, sync_on_update, sync_on_delete, create_time, last_update_time)
VALUES ('trig_customers', 'customers', 'default', 'reload', 1, 1, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT DO NOTHING;

-- ============================================
-- 5. CONFIGURAR TRIGGERS - TABLA PRODUCTS
-- ============================================
INSERT INTO sym_trigger (trigger_id, source_table_name, channel_id, reload_channel_id, sync_on_insert, sync_on_update, sync_on_delete, create_time, last_update_time)
VALUES ('trig_products', 'products', 'default', 'reload', 1, 1, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT DO NOTHING;

-- ============================================
-- 6. CONFIGURAR TRIGGERS - TABLA INVENTORY
-- ============================================
INSERT INTO sym_trigger (trigger_id, source_table_name, channel_id, reload_channel_id, sync_on_insert, sync_on_update, sync_on_delete, create_time, last_update_time)
VALUES ('trig_inventory', 'inventory', 'default', 'reload', 1, 1, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT DO NOTHING;

-- ============================================
-- 7. CONFIGURAR TRIGGERS - TABLA PROMOTIONS
-- ============================================
INSERT INTO sym_trigger (trigger_id, source_table_name, channel_id, reload_channel_id, sync_on_insert, sync_on_update, sync_on_delete, create_time, last_update_time)
VALUES ('trig_promotions', 'promotions', 'default', 'reload', 1, 1, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT DO NOTHING;

-- ============================================
-- 8. CREAR RUTAS DE REPLICACIÓN BIDIRECCIONAL
-- ============================================
-- Ruta 001 -> 002
INSERT INTO sym_router (router_id, source_node_group_id, target_node_group_id, router_type, create_time, last_update_time)
VALUES ('route_001_to_002', 'america-store', 'america-store', 'default', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT DO NOTHING;

-- Ruta 002 -> 001
INSERT INTO sym_router (router_id, source_node_group_id, target_node_group_id, router_type, create_time, last_update_time)
VALUES ('route_002_to_001', 'america-store', 'america-store', 'default', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT DO NOTHING;

-- ============================================
-- 9. MAPEAR TRIGGERS A RUTAS
-- ============================================
-- Customers
INSERT INTO sym_trigger_router (trigger_id, router_id, create_time, last_update_time)
VALUES ('trig_customers', 'route_001_to_002', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT DO NOTHING;

INSERT INTO sym_trigger_router (trigger_id, router_id, create_time, last_update_time)
VALUES ('trig_customers', 'route_002_to_001', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT DO NOTHING;

-- Products
INSERT INTO sym_trigger_router (trigger_id, router_id, create_time, last_update_time)
VALUES ('trig_products', 'route_001_to_002', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT DO NOTHING;

INSERT INTO sym_trigger_router (trigger_id, router_id, create_time, last_update_time)
VALUES ('trig_products', 'route_002_to_001', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT DO NOTHING;

-- Inventory
INSERT INTO sym_trigger_router (trigger_id, router_id, create_time, last_update_time)
VALUES ('trig_inventory', 'route_001_to_002', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT DO NOTHING;

INSERT INTO sym_trigger_router (trigger_id, router_id, create_time, last_update_time)
VALUES ('trig_inventory', 'route_002_to_001', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT DO NOTHING;

-- Promotions
INSERT INTO sym_trigger_router (trigger_id, router_id, create_time, last_update_time)
VALUES ('trig_promotions', 'route_001_to_002', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT DO NOTHING;

INSERT INTO sym_trigger_router (trigger_id, router_id, create_time, last_update_time)
VALUES ('trig_promotions', 'route_002_to_001', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT DO NOTHING;

-- ============================================
-- 10. CREAR CANALES DE SINCRONIZACIÓN
-- ============================================
INSERT INTO sym_channel (channel_id, processing_order, max_batch_size, enabled, description)
VALUES ('default', 1, 1000, 1, 'Canal de replicación por defecto')
ON CONFLICT DO NOTHING;

INSERT INTO sym_channel (channel_id, processing_order, max_batch_size, enabled, description)
VALUES ('reload', 10, 1000, 1, 'Canal para recargas completas')
ON CONFLICT DO NOTHING;

-- ============================================
-- CONFIGURACIÓN COMPLETADA
-- ============================================
\echo '================================================='
\echo 'SymmetricDS configurado correctamente'
\echo 'Replicación bidireccional habilitada'
\echo '================================================='
