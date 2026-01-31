# Guía de Solución de Problemas (Troubleshooting)

Esta guía te ayudará a diagnosticar y resolver problemas comunes con la configuración de SymmetricDS.

## 📋 Índice

1. [Problemas Comunes de Inicio](#problemas-comunes-de-inicio)
2. [Problemas de Conectividad](#problemas-de-conectividad)
3. [Problemas de Replicación](#problemas-de-replicación)
4. [Problemas de Base de Datos](#problemas-de-base-de-datos)
5. [Comandos de Diagnóstico](#comandos-de-diagnóstico)

---

## Problemas Comunes de Inicio

### ❌ Error: "Contenedor de SymmetricDS se reinicia constantemente"

**Síntomas:**
```bash
$ docker-compose ps
symmetricds-america    Restarting
```

**Causas posibles:**
1. Error en la configuración de `symmetric.properties`
2. No puede conectar a la base de datos
3. Puerto ya en uso

**Solución:**

1. Ver los logs:
```bash
docker-compose logs symmetricds-america
```

2. Verificar errores comunes:
```bash
# Error típico: "Connection refused"
# Significa que la BD no está lista o la URL es incorrecta

# Error típico: "Port already in use"
# Significa que el puerto 31415 está ocupado
```

3. Verificar configuración:
```bash
# Revisar que db.url esté correcta
# Para PostgreSQL:
db.url=jdbc:postgresql://postgres-america:5432/globalshop

# Para MySQL:
db.url=jdbc:mysql://mysql-europe:3306/globalshop
```

4. Verificar que la base de datos esté lista:
```bash
# PostgreSQL
docker exec postgres-america pg_isready

# MySQL
docker exec mysql-europe mysqladmin ping
```

---

### ❌ Error: "Cannot connect to database"

**Síntomas:**
```
ERROR: Connection to postgres-america:5432 refused
```

**Solución:**

1. Verificar que el contenedor de BD esté corriendo:
```bash
docker-compose ps
```

2. Verificar la red de Docker:
```bash
docker network ls
docker network inspect examen-abdd-2025-2_globalshop-network
```

3. Verificar credenciales:
```bash
# Probar conexión manual
docker exec postgres-america psql -U symmetricds -d globalshop -c "SELECT 1;"
docker exec mysql-europe mysql -u symmetricds -psymmetricds globalshop -e "SELECT 1;"
```

4. Esperar a que la BD esté completamente iniciada:
```bash
# Agregar depends_on y healthcheck en docker-compose.yml
services:
  symmetricds-america:
    depends_on:
      postgres-america:
        condition: service_healthy
```

---

### ❌ Error: "Table sym_node does not exist"

**Síntomas:**
```
ERROR: relation "sym_node" does not exist
```

**Causa:**
SymmetricDS no ha creado sus tablas internas.

**Solución:**

1. Verificar que el usuario tenga permisos:
```sql
-- PostgreSQL
GRANT ALL PRIVILEGES ON DATABASE globalshop TO symmetricds;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO symmetricds;

-- MySQL
GRANT ALL PRIVILEGES ON globalshop.* TO 'symmetricds'@'%';
FLUSH PRIVILEGES;
```

2. Reiniciar SymmetricDS:
```bash
docker-compose restart symmetricds-america
```

3. Ver logs para confirmar que se crearon las tablas:
```bash
docker-compose logs symmetricds-america | grep "Creating tables"
```

---

## Problemas de Conectividad

### ❌ Error: "Registration failed"

**Síntomas:**
```
ERROR: Registration to http://symmetricds-america:31415/sync/america failed
```

**Causas:**
1. El nodo América no está corriendo
2. La URL de registro es incorrecta
3. Problema de red entre contenedores

**Solución:**

1. Verificar que el nodo América esté corriendo:
```bash
docker-compose ps symmetricds-america
```

2. Verificar la URL de registro en `europe/symmetric.properties`:
```properties
# Debe apuntar al contenedor y puerto correcto
registration.url=http://symmetricds-america:31415/sync/america
```

3. Probar conectividad entre contenedores:
```bash
docker exec symmetricds-europe ping symmetricds-america
docker exec symmetricds-europe curl http://symmetricds-america:31415/
```

4. Verificar que los puertos estén expuestos:
```yaml
# En docker-compose.yml
symmetricds-america:
  ports:
    - "31415:31415"
```

---

### ❌ Error: "Node not found"

**Síntomas:**
```
ERROR: Node with external_id '002' not found
```

**Causa:**
El nodo Europa no se registró correctamente con América.

**Solución:**

1. Verificar que el `group.id` coincida en ambos nodos:
```properties
# america/symmetric.properties
group.id=america-store

# europe/symmetric.properties  
group.id=europe-store  # Debe estar definido en américa
```

2. Verificar que los grupos estén definidos en `america.properties`:
```sql
insert into sym_node_group (node_group_id, description) 
values ('america-store', 'America region');

insert into sym_node_group (node_group_id, description) 
values ('europe-store', 'Europe region');
```

3. Limpiar y reiniciar:
```bash
# Detener todo
docker-compose down -v

# Levantar solo las BDs primero
docker-compose up -d postgres-america mysql-europe

# Esperar 10 segundos, luego levantar SymmetricDS
sleep 10
docker-compose up -d symmetricds-america symmetricds-europe
```

---

## Problemas de Replicación

### ❌ Error: "Data not replicating"

**Síntomas:**
- Insertas datos en PostgreSQL pero no aparecen en MySQL
- No hay errores en los logs

**Diagnóstico:**

1. Verificar que los triggers existan:
```sql
-- PostgreSQL
SELECT * FROM sym_trigger;

-- Verificar que los triggers reales estén creados
SELECT tgname FROM pg_trigger WHERE tgname LIKE '%sym%';
```

2. Verificar que haya datos capturados:
```sql
SELECT * FROM sym_data ORDER BY create_time DESC LIMIT 10;
```

3. Verificar batches pendientes:
```sql
SELECT * FROM sym_outgoing_batch 
WHERE status != 'OK' 
ORDER BY create_time DESC;
```

**Soluciones:**

**A. No hay triggers:**
```sql
-- Forzar creación de triggers
INSERT INTO sym_trigger (trigger_id, source_table_name, channel_id, 
  sync_on_insert, sync_on_update, sync_on_delete,
  last_update_time, create_time)
VALUES ('products_trigger', 'products', 'products_channel',
  1, 1, 1,
  current_timestamp, current_timestamp);

-- Luego sincronizar triggers
-- SymmetricDS creará los triggers automáticamente
```

**B. No hay routers configurados:**
```sql
-- Verificar routers
SELECT * FROM sym_router;

-- Verificar trigger_router
SELECT * FROM sym_trigger_router;
```

**C. Batches con errores:**
```sql
-- Ver el error
SELECT batch_id, sql_message, error_flag 
FROM sym_outgoing_batch 
WHERE error_flag = 1;

-- Reenviar batch
UPDATE sym_outgoing_batch 
SET status = 'NE', error_flag = 0 
WHERE batch_id = [BATCH_ID];
```

---

### ❌ Error: "Replication loop detected"

**Síntomas:**
```
WARNING: Circular reference detected, skipping
```

**Causa:**
Los cambios se están replicando infinitamente entre nodos.

**Solución:**

SymmetricDS maneja esto automáticamente con `source_node_id`. Si ves este error:

1. Verificar que `auto.register=true` en ambos nodos
2. Verificar que cada nodo tenga un `external.id` único
3. No modificar manualmente las tablas `sym_*`

---

### ❌ Error: "Conflict detected"

**Síntomas:**
```
WARN: Conflict detected on table products, row id=PROD-001
```

**Causa:**
El mismo registro fue modificado en ambos nodos simultáneamente.

**Solución:**

1. Por defecto, SymmetricDS usa "last write wins"
2. Puedes configurar resolución personalizada:

```properties
# En symmetric.properties
conflict.resolver=last_write_wins  # Default
# O:
conflict.resolver=manual  # Requiere intervención
```

3. Ver conflictos:
```sql
SELECT * FROM sym_conflict 
ORDER BY create_time DESC;
```

---

## Problemas de Base de Datos

### ❌ Error: "Boolean type mismatch"

**Síntomas:**
```
ERROR: Column 'is_active' type mismatch: PostgreSQL BOOLEAN vs MySQL TINYINT
```

**Causa:**
PostgreSQL usa `BOOLEAN`, MySQL usa `TINYINT(1)`.

**Solución:**

SymmetricDS maneja esto automáticamente. Si hay problemas:

1. Usar TINYINT(1) en MySQL:
```sql
is_active TINYINT(1) DEFAULT 1
```

2. Usar transformaciones si es necesario:
```sql
INSERT INTO sym_transform_table (
  transform_id, source_table_name, target_table_name,
  transform_point, column_policy
) VALUES (
  'bool_transform', 'products', 'products',
  'LOAD', 'SPECIFIED'
);

INSERT INTO sym_transform_column (
  transform_id, source_column_name, target_column_name,
  transform_type, transform_expression
) VALUES (
  'bool_transform', 'is_active', 'is_active',
  'bsh', 'value ? 1 : 0'
);
```

---

### ❌ Error: "Foreign key constraint violation"

**Síntomas:**
```
ERROR: Foreign key constraint failed on table 'inventory'
```

**Causa:**
Se está intentando insertar en `inventory` antes que en `products`.

**Solución:**

1. Usar `initial_load_order` en `sym_trigger_router`:
```sql
-- Products primero (orden 100)
INSERT INTO sym_trigger_router (trigger_id, router_id, initial_load_order)
VALUES ('products_trigger', 'america_to_europe', 100);

-- Inventory después (orden 200)
INSERT INTO sym_trigger_router (trigger_id, router_id, initial_load_order)
VALUES ('inventory_trigger', 'america_to_europe', 200);
```

2. Usar canales con diferentes `processing_order`.

---

## Comandos de Diagnóstico

### Verificar Estado General

```bash
# Ver todos los contenedores
docker-compose ps

# Ver logs en tiempo real
docker-compose logs -f

# Ver solo errores
docker-compose logs | grep ERROR

# Ver métricas de un contenedor
docker stats symmetricds-america
```

### Verificar Configuración de SymmetricDS

```sql
-- Ver nodos registrados
SELECT node_id, node_group_id, external_id, sync_enabled 
FROM sym_node;

-- Ver grupos de nodos
SELECT * FROM sym_node_group;

-- Ver enlaces entre grupos
SELECT * FROM sym_node_group_link;

-- Ver canales
SELECT channel_id, processing_order, enabled 
FROM sym_channel 
ORDER BY processing_order;

-- Ver triggers
SELECT trigger_id, source_table_name, channel_id 
FROM sym_trigger;

-- Ver routers
SELECT router_id, source_node_group_id, target_node_group_id, router_type 
FROM sym_router;

-- Ver vinculación trigger-router
SELECT t.trigger_id, t.source_table_name, tr.router_id, tr.initial_load_order
FROM sym_trigger t
JOIN sym_trigger_router tr ON t.trigger_id = tr.trigger_id
ORDER BY tr.initial_load_order;
```

### Verificar Actividad de Replicación

```sql
-- Datos pendientes de sincronizar
SELECT COUNT(*) as pending_changes 
FROM sym_data 
WHERE data_id NOT IN (SELECT data_id FROM sym_data_event);

-- Batches recientes
SELECT batch_id, node_id, status, create_time, byte_count, data_event_count
FROM sym_outgoing_batch 
ORDER BY create_time DESC 
LIMIT 20;

-- Batches con error
SELECT batch_id, node_id, status, error_flag, sql_message
FROM sym_outgoing_batch 
WHERE error_flag = 1;

-- Estadísticas por tabla
SELECT trigger_hist_id, source_table_name, 
       COUNT(*) as event_count
FROM sym_data
GROUP BY trigger_hist_id, source_table_name;
```

### Limpiar y Reiniciar

```bash
# Detener todo y limpiar volúmenes
docker-compose down -v

# Limpiar imágenes huérfanas
docker system prune -f

# Reconstruir desde cero
docker-compose up -d --build

# Reiniciar solo SymmetricDS
docker-compose restart symmetricds-america symmetricds-europe
```

### Pruebas Manuales

```bash
# Test 1: Insertar en PostgreSQL
docker exec postgres-america psql -U symmetricds -d globalshop -c "
INSERT INTO products VALUES ('TEST-001', 'Test', 'Test', 99.99, 'Test', true, NOW(), NOW());
"

# Esperar 10 segundos
sleep 10

# Test 2: Verificar en MySQL
docker exec mysql-europe mysql -u symmetricds -psymmetricds globalshop -e "
SELECT * FROM products WHERE product_id='TEST-001';
"
```

---

## Checklist de Verificación

Antes de ejecutar el script de validación, verifica:

### ✅ Docker Compose
- [ ] Archivo `docker-compose.yml` existe
- [ ] Todos los servicios están definidos
- [ ] Puertos están correctamente mapeados
- [ ] Redes están configuradas
- [ ] Volúmenes están montados

### ✅ Configuración América
- [ ] `symmetric.properties` tiene todos los campos completos
- [ ] `db.url` apunta a `postgres-america:5432`
- [ ] `http.port=31415`
- [ ] `registration.url` está vacío
- [ ] `america.properties` tiene la configuración SQL

### ✅ Configuración Europa
- [ ] `symmetric.properties` tiene todos los campos completos
- [ ] `db.url` apunta a `mysql-europe:3306`
- [ ] `http.port=31416`
- [ ] `registration.url` apunta a América
- [ ] `europe.properties` existe (puede estar vacío)

### ✅ Bases de Datos
- [ ] PostgreSQL está corriendo
- [ ] MySQL está corriendo
- [ ] Puedes conectar a ambas bases de datos
- [ ] Las 4 tablas existen en ambas

### ✅ SymmetricDS
- [ ] Ambos nodos están corriendo
- [ ] No hay errores en los logs
- [ ] Las tablas `sym_*` existen
- [ ] Los triggers están creados

---

## Recursos Adicionales

- [Documentación Oficial - Troubleshooting](https://www.symmetricds.org/docs/troubleshooting)
- [FAQ SymmetricDS](https://www.symmetricds.org/faq)
- [GitHub Issues](https://github.com/JumpMind/symmetric-ds/issues)

---

## 💡 Tips Finales

1. **Siempre revisa los logs primero**: `docker-compose logs`
2. **Espera suficiente tiempo**: La replicación puede tardar 5-10 segundos
3. **Verifica la red**: Los contenedores deben poder comunicarse
4. **Un paso a la vez**: Primero las BDs, luego América, luego Europa
5. **Documenta tus cambios**: Si algo funciona, anota qué hiciste

¡Buena suerte! 🚀
