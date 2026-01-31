#!/bin/bash
# Script para configurar la replicación de SymmetricDS
# Este script se ejecuta automáticamente después de que todos los servicios estén listos

set -e

echo "============================================"
echo "Configurando SymmetricDS para replicación"
echo "============================================"

# Esperar un poco más para asegurar estabilidad
sleep 10

# Ejecutar la configuración principal
echo "Ejecutando configure-symmetricds.sql..."
psql -h postgres-america -U symmetricds -d globalshop -f /configure-symmetricds.sql || true

# Registrar y habilitar el nodo Europa
echo "Registrando el nodo Europa..."
psql -h postgres-america -U symmetricds -d globalshop << 'EOSQL'
-- Insertar nodo Europa si no existe
INSERT INTO sym_node (node_id, node_group_id, external_id, sync_enabled, sync_url, created_at_node_id)
VALUES ('europe-001', 'europe-store', 'europe-001', 1, 'http://symmetricds-europe:31416/sync/europe', 'america-001')
ON CONFLICT (node_id) DO UPDATE SET sync_enabled = 1;

-- Habilitar registro e initial load
UPDATE sym_node_security SET registration_enabled = 1, initial_load_enabled = 1 
WHERE node_id = 'europe-001';

-- Insertar en security si no existe
INSERT INTO sym_node_security (node_id, node_password, registration_enabled, registration_time, initial_load_enabled, initial_load_time, created_at_node_id)
SELECT 'europe-001', 'symmetricds', 1, current_timestamp, 1, current_timestamp, 'america-001'
WHERE NOT EXISTS (SELECT 1 FROM sym_node_security WHERE node_id = 'europe-001');

-- Mostrar estado
SELECT 'Nodos configurados:' AS info;
SELECT node_id, node_group_id, sync_enabled FROM sym_node;

SELECT 'Seguridad de nodos:' AS info;
SELECT node_id, registration_enabled, initial_load_enabled FROM sym_node_security;

SELECT 'Triggers configurados:' AS info;
SELECT trigger_id, source_table_name, channel_id FROM sym_trigger;
EOSQL

echo "============================================"
echo "Configuración completada exitosamente!"
echo "============================================"
