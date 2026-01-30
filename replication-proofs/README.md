# Pruebas de Replicación Bidireccional con SymmetricDS

Este documento presenta las pruebas de replicación de datos entre dos nodos distribuidos:
- **Nodo América**: PostgreSQL en `postgres-america:5432`
- **Nodo Europa**: MySQL en `mysql-europe:3306`

Ambos nodos están sincronizados mediante SymmetricDS, permitiendo replicación de cambios en ambas direcciones.

---

## 📊 Capturas de Prueba

### 1️⃣ `01_insert_pg_to_mysql.png`
**Descripción**: Inserción desde PostgreSQL (América) → MySQL (Europa)

**Proceso**:
- Se inserta un nuevo producto en la base de datos de PostgreSQL (América)
- SymmetricDS captura el cambio en tiempo real
- El registro se replica automáticamente a MySQL (Europa)
- La captura muestra el mismo producto existiendo en ambas bases de datos

**Tabla afectada**: `products`

**Resultado**: ✅ Replicación unidireccional America → Europe exitosa

---

### 2️⃣ `02_insert_mysql_to_pg.png`
**Descripción**: Inserción desde MySQL (Europa) → PostgreSQL (América)

**Proceso**:
- Se inserta un nuevo producto en la base de datos de MySQL (Europa)
- SymmetricDS detecta el cambio
- El registro se replica hacia PostgreSQL (América)
- La captura confirma que el producto aparece en ambas bases de datos

**Tabla afectada**: `products`

**Resultado**: ✅ Replicación unidireccional Europe → America exitosa

---

### 3️⃣ `03_update_bidireccional.png`
**Descripción**: Actualización de registro desde cualquier nodo

**Proceso**:
- Se modifica un registro en una de las bases de datos (cambio de nombre, precio, etc.)
- SymmetricDS propaga la actualización al nodo remoto
- Ambas bases de datos mantienen datos consistentes
- La captura muestra la actualización replicada correctamente

**Tabla afectada**: `products` (campo actualizado)

**Resultado**: ✅ Sincronización de actualizaciones bidireccional exitosa

---

### 4️⃣ `04_delete_bidireccional.png`
**Descripción**: Eliminación de registro desde cualquier nodo

**Proceso**:
- Se elimina un registro en una de las bases de datos
- SymmetricDS captura la operación DELETE
- El registro eliminado se remueve del nodo remoto
- La captura confirma la coherencia de datos en ambas bases

**Tabla afectada**: `products`

**Resultado**: ✅ Sincronización de eliminaciones bidireccional exitosa

---

## 🔄 Configuración de Replicación

### Tablas Replicadas
- `products` - Catálogo de productos
- `inventory` - Inventario y stock
- `customers` - Información de clientes
- `promotions` - Promociones y descuentos

### Canales Configurados
| Canal | Descripción | Orden |
|-------|-------------|-------|
| `products_channel` | Replicación de productos | 10 |
| `inventory_channel` | Replicación de inventario | 20 |
| `customers_channel` | Replicación de clientes | 30 |
| `promotions_channel` | Replicación de promociones | 40 |

### Routers Bidireccionales
- `america_to_europe`: America → Europe
- `europe_to_america`: Europe → America

---

## ✅ Conclusión

Las pruebas demuestran que la replicación bidireccional funciona correctamente:
- ✅ Inserciones se sincronizan en ambas direcciones
- ✅ Actualizaciones se propagan automáticamente
- ✅ Eliminaciones mantienen la coherencia
- ✅ Los datos permanecen sincronizados entre PostgreSQL y MySQL
- ✅ SymmetricDS maneja correctamente ambos tipos de bases de datos

**Estado Final**: Sistema de replicación distribuida **FUNCIONAL**
