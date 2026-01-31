# Evidencias de replicación

Este documento describe las capturas generadas para validar la replicación bidireccional entre PostgreSQL (América) y MySQL (Europa) con SymmetricDS. Las pruebas se realizaron con Docker Compose y validan INSERT, UPDATE y DELETE en ambos sentidos.

## Capturas incluidas

1. INSERT PostgreSQL -> MySQL
   - Archivo: `01_insert_pg_to_mysql.png`
   - Proceso: inserción de un producto en PostgreSQL y verificación del registro en MySQL.

2. INSERT MySQL -> PostgreSQL
   - Archivo: `02_insert_mysql_to_pg.png`
   - Proceso: inserción de un cliente en MySQL y verificación del registro en PostgreSQL.

3. UPDATE bidireccional
   - Archivo: `03_update_bidirectional.png`
   - Proceso: actualización de un producto en PostgreSQL y verificación del cambio en MySQL.

4. DELETE bidireccional
   - Archivo: `04_delete_bidirectional.png`
   - Proceso: eliminación de un cliente en MySQL y verificación de ausencia en PostgreSQL.

## Procedimiento resumido

1. Verificación de contenedores activos con `docker compose ps`.
2. INSERT PostgreSQL -> MySQL (producto `CAP-PG-001`).
3. INSERT MySQL -> PostgreSQL (cliente `CAP-MY-001`).
4. UPDATE PostgreSQL -> MySQL (producto `CAP-PG-001`).
5. DELETE MySQL -> PostgreSQL (cliente `CAP-MY-001`).

Cada captura muestra el comando ejecutado y la verificación en la base de datos de destino.
