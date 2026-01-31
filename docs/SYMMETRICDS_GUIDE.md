# Guía Completa de SymmetricDS

Esta guía te ayudará a entender y configurar SymmetricDS para la replicación bidireccional heterogénea.

## 📚 Índice

1. [Conceptos Básicos](#conceptos-básicos)
2. [Arquitectura de SymmetricDS](#arquitectura-de-symmetricds)
3. [Configuración Paso a Paso](#configuración-paso-a-paso)
4. [Ejemplos de Configuración](#ejemplos-de-configuración)
5. [Comandos Útiles](#comandos-útiles)

## Conceptos Básicos

### ¿Qué es SymmetricDS?

SymmetricDS es una herramienta de código abierto para sincronización de datos y replicación de bases de datos. Soporta:
- Replicación bidireccional (multi-master)
- Bases de datos heterogéneas (PostgreSQL ↔ MySQL, Oracle, SQL Server, etc.)
- Sincronización en tiempo real
- Resolución automática de conflictos

### Conceptos Clave

#### 1. **Node (Nodo)**
Un nodo representa una instancia de base de datos que participa en la replicación.
- Cada nodo tiene un identificador único (`external.id`)
- Pertenece a un grupo de nodos (`group.id`)

#### 2. **Node Group (Grupo de Nodos)**
Agrupa nodos con características similares o que comparten datos.
- Ejemplo: `america-store`, `europe-store`
- Los grupos facilitan la configuración de replicación entre múltiples nodos

#### 3. **Channel (Canal)**
Los canales organizan las tablas en categorías lógicas y controlan:
- El orden de sincronización
- El tamaño de los lotes
- La prioridad de procesamiento

#### 4. **Trigger**
Los triggers capturan cambios (INSERT, UPDATE, DELETE) en las tablas.
- SymmetricDS crea automáticamente triggers en tus tablas
- Los cambios se almacenan en tablas internas (`sym_data`)

#### 5. **Router**
Los routers determinan a qué nodos se envían los datos capturados.
- **default**: Envía todos los datos a todos los nodos del grupo destino
- **column**: Filtra datos basándose en valores de columnas
- **bsh**: Usa scripts BeanShell para lógica personalizada

#### 6. **Trigger Router**
Vincula triggers con routers, determinando qué datos capturados se envían por qué rutas.

## Arquitectura de SymmetricDS

```
┌─────────────────────────────────────────────────────┐
│                    Nodo América                      │
│  ┌────────────────────────────────────────────────┐ │
│  │          Base de Datos (PostgreSQL)            │ │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐    │ │
│  │  │ products │  │inventory │  │customers │    │ │
│  │  └────┬─────┘  └────┬─────┘  └────┬─────┘    │ │
│  │       │ triggers     │             │           │ │
│  └───────┼──────────────┼─────────────┼───────────┘ │
│          │              │             │              │
│  ┌───────▼──────────────▼─────────────▼───────────┐ │
│  │         SymmetricDS Engine América             │ │
│  │  ┌─────────┐  ┌─────────┐  ┌──────────┐      │ │
│  │  │ Capture │→ │  Route  │→ │   Push   │      │ │
│  │  └─────────┘  └─────────┘  └─────┬────┘      │ │
│  │  ┌─────────┐  ┌─────────┐        │           │ │
│  │  │  Load   │← │  Pull   │←───────┘           │ │
│  │  └────┬────┘  └─────────┘                     │ │
│  └───────┼───────────────────────────────────────┘ │
└──────────┼─────────────────────────────────────────┘
           │ HTTP/HTTPS
           │
┌──────────▼─────────────────────────────────────────┐
│                    Nodo Europa                      │
│  ┌───────┬───────────────────────────────────────┐ │
│  │       │    SymmetricDS Engine Europa          │ │
│  │  ┌────▼────┐  ┌─────────┐  ┌──────────┐      │ │
│  │  │  Pull   │→ │  Load   │→ │ Database │      │ │
│  │  └─────────┘  └─────────┘  └─────┬────┘      │ │
│  │  ┌─────────┐  ┌─────────┐        │           │ │
│  │  │  Push   │← │  Route  │←───────┘           │ │
│  │  └─────────┘  └─────────┘  ┌─────────┐       │ │
│  │                             │ Capture │       │ │
│  └─────────────────────────────┴────┬────┴───────┘ │
│                                      │ triggers     │
│  ┌───────────────────────────────────▼──────────┐  │
│  │           Base de Datos (MySQL)              │  │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐  │  │
│  │  │ products │  │inventory │  │customers │  │  │
│  │  └──────────┘  └──────────┘  └──────────┘  │  │
│  └──────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────┘
```

## Configuración Paso a Paso

### Paso 1: Configurar docker-compose.yml

```yaml
version: '3.8'

services:
  # Base de datos PostgreSQL (América)
  postgres-america:
    image: postgres:15
    container_name: postgres-america
    environment:
      POSTGRES_DB: globalshop
      POSTGRES_USER: symmetricds
      POSTGRES_PASSWORD: symmetricds
    ports:
      - "5432:5432"
    volumes:
      - ./init-db/postgres:/docker-entrypoint-initdb.d
      - postgres-data:/var/lib/postgresql/data
    networks:
      - globalshop-network

  # Base de datos MySQL (Europa)
  mysql-europe:
    image: mysql:8.0
    container_name: mysql-europe
    environment:
      MYSQL_DATABASE: globalshop
      MYSQL_USER: symmetricds
      MYSQL_PASSWORD: symmetricds
      MYSQL_ROOT_PASSWORD: rootpassword
    ports:
      - "3306:3306"
    volumes:
      - ./init-db/mysql:/docker-entrypoint-initdb.d
      - mysql-data:/var/lib/mysql
    networks:
      - globalshop-network

  # SymmetricDS Nodo América
  symmetricds-america:
    image: jumpmind/symmetricds:3.16
    container_name: symmetricds-america
    environment:
      - SYMMETRIC_HOME=/opt/symmetric-ds
    ports:
      - "31415:31415"
    volumes:
      - ./symmetricds/america:/opt/symmetric-ds/engines/america
    depends_on:
      - postgres-america
    networks:
      - globalshop-network

  # SymmetricDS Nodo Europa
  symmetricds-europe:
    image: jumpmind/symmetricds:3.16
    container_name: symmetricds-europe
    environment:
      - SYMMETRIC_HOME=/opt/symmetric-ds
    ports:
      - "31416:31416"
    volumes:
      - ./symmetricds/europe:/opt/symmetric-ds/engines/europe
    depends_on:
      - mysql-europe
      - symmetricds-america
    networks:
      - globalshop-network

networks:
  globalshop-network:
    driver: bridge

volumes:
  postgres-data:
  mysql-data:
```

### Paso 2: Configurar symmetric.properties (América)

```properties
# Identificación del nodo
engine.name=america
group.id=america-store
external.id=001

# Conexión a PostgreSQL
db.driver=org.postgresql.Driver
db.url=jdbc:postgresql://postgres-america:5432/globalshop
db.user=symmetricds
db.password=symmetricds

# Este es el nodo raíz (no necesita registration.url)
registration.url=

# Configuración de servicios
sync.url=http://symmetricds-america:31415/sync/america
http.enable=true
http.port=31415

# Habilitar jobs
start.push.job=true
start.pull.job=true
start.route.job=true
start.heartbeat.job=true

# Auto configuración
auto.register=true
auto.reload=true
```

### Paso 3: Configurar symmetric.properties (Europa)

```properties
# Identificación del nodo
engine.name=europe
group.id=europe-store
external.id=002

# Conexión a MySQL
db.driver=com.mysql.cj.jdbc.Driver
db.url=jdbc:mysql://mysql-europe:3306/globalshop?allowPublicKeyRetrieval=true&useSSL=false
db.user=symmetricds
db.password=symmetricds

# Registrarse contra el nodo América
registration.url=http://symmetricds-america:31415/sync/america

# Configuración de servicios
sync.url=http://symmetricds-europe:31416/sync/europe
http.enable=true
http.port=31416

# Habilitar jobs
start.push.job=true
start.pull.job=true
start.route.job=true
start.heartbeat.job=true

# Auto configuración
auto.register=true
auto.reload=true
```

### Paso 4: Configurar Tablas de SymmetricDS (america.properties)

Este archivo contiene SQL que se ejecuta al iniciar el nodo:

```sql
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
```

## Comandos Útiles

### Docker Commands

```bash
# Levantar todos los servicios
docker-compose up -d

# Ver logs de un servicio
docker-compose logs -f symmetricds-america
docker-compose logs -f symmetricds-europe

# Ver estado de contenedores
docker-compose ps

# Reiniciar un servicio
docker-compose restart symmetricds-america

# Detener todos los servicios
docker-compose down

# Detener y eliminar volúmenes
docker-compose down -v
```

### Database Commands

```bash
# Conectar a PostgreSQL
docker exec -it postgres-america psql -U symmetricds -d globalshop

# Conectar a MySQL
docker exec -it mysql-europe mysql -u symmetricds -psymmetricds globalshop

# Ver tablas de SymmetricDS en PostgreSQL
docker exec -it postgres-america psql -U symmetricds -d globalshop -c "\dt sym_*"

# Ver tablas de SymmetricDS en MySQL
docker exec -it mysql-europe mysql -u symmetricds -psymmetricds globalshop -e "SHOW TABLES LIKE 'sym_%';"
```

### Verificación de Replicación

```sql
-- En cualquier base de datos, ver estado de los nodos
SELECT node_id, node_group_id, external_id, sync_enabled, sync_url 
FROM sym_node;

-- Ver datos pendientes de sincronización
SELECT * FROM sym_outgoing_batch 
WHERE status != 'OK' 
ORDER BY create_time DESC;

-- Ver errores de sincronización
SELECT * FROM sym_outgoing_batch 
WHERE error_flag = 1;

-- Ver triggers instalados
SELECT * FROM sym_trigger;

-- Ver routers configurados
SELECT * FROM sym_router;
```

## Flujo de Datos

1. **Captura**: Cuando hay un INSERT/UPDATE/DELETE en una tabla, el trigger de SymmetricDS lo captura
2. **Almacenamiento**: El cambio se guarda en `sym_data`
3. **Routing**: El router determina a qué nodos enviar el cambio
4. **Batching**: Los cambios se agrupan en lotes (`sym_outgoing_batch`)
5. **Push**: El nodo origen envía los lotes al nodo destino
6. **Pull**: El nodo destino también puede solicitar cambios
7. **Load**: El nodo destino aplica los cambios en su base de datos
8. **Acknowledge**: El nodo destino confirma la recepción

## Resolución de Conflictos

SymmetricDS usa por defecto "last write wins" (el último que escribe gana):
- Se basa en el timestamp del cambio
- El cambio más reciente sobrescribe el anterior
- Se puede configurar resolución personalizada

## Consideraciones de Rendimiento

- **Batch Size**: Controla cuántos cambios se envían por lote
- **Push/Pull Frequency**: Frecuencia de sincronización (default: 5 segundos)
- **Channels**: Usa canales separados para controlar el orden
- **Initial Load**: Puede ser costoso, considera hacerlo fuera de horas pico

## Referencias

- [Documentación Oficial SymmetricDS](https://www.symmetricds.org/docs)
- [GitHub SymmetricDS](https://github.com/JumpMind/symmetric-ds)
- [Docker Hub - SymmetricDS](https://hub.docker.com/r/jumpmind/symmetricds)
