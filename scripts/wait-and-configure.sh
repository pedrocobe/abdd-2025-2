#!/bin/bash
# Script para esperar a que SymmetricDS inicie y luego configurar la replicación

echo "Esperando 60 segundos para que SymmetricDS América esté completamente inicializado..."
sleep 60

echo "Configurando la replicación en PostgreSQL..."

# Conectar a PostgreSQL y ejecutar la configuración
PGPASSWORD=symmetricds psql -h postgres-america -U symmetricds -d globalshop << 'EOSQL'

-- Verificar si ya existe la configuración
DO $$
BEGIN
    -- Verificar si el grupo europe-store ya existe
    IF NOT EXISTS (SELECT 1 FROM sym_node WHERE node_id = 'europe-001') THEN
        
        -- Registrar el nodo Europa para aceptar su registro
        INSERT INTO sym_node (node_id, node_group_id, external_id, sync_enabled, sync_url, created_at_node_id)
        VALUES ('europe-001', 'europe-store', 'europe-001', 1, 'http://symmetricds-europe:31416/sync/europe', 'america-001');
        
        INSERT INTO sym_node_security (node_id, node_password, registration_enabled, registration_time, initial_load_enabled, initial_load_time, created_at_node_id)
        VALUES ('europe-001', 'symmetricds', 1, current_timestamp, 1, current_timestamp, 'america-001');
        
        RAISE NOTICE 'Nodo Europa registrado exitosamente';
    ELSE
        RAISE NOTICE 'El nodo Europa ya está registrado';
    END IF;
END $$;

-- Mostrar estado de los nodos
SELECT 'Nodos registrados:' AS info;
SELECT node_id, node_group_id, sync_enabled FROM sym_node;

SELECT 'Seguridad de nodos:' AS info;
SELECT node_id, registration_enabled, initial_load_enabled FROM sym_node_security;

EOSQL

echo "Configuración completada."
