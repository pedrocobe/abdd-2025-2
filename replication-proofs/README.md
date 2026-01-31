# 📸 Pruebas de Replicación Bidireccional

Este directorio contiene las **capturas de pantalla** que demuestran el funcionamiento correcto de la replicación bidireccional entre PostgreSQL (América) y MySQL (Europa) utilizando SymmetricDS.

## 📋 Descripción

Las imágenes documentan las pruebas de replicación en ambas direcciones para las operaciones:
- **INSERT**: Inserción de nuevos registros
- **UPDATE**: Actualización de registros existentes
- **DELETE**: Eliminación de registros

## 🔄 Pruebas Realizadas

### 1️⃣ Prueba INSERT: PostgreSQL → MySQL

**Archivos:**
- [`01_insert_pg_mysql.png`](01_insert_pg_mysql.png) - Inserción de datos en PostgreSQL (América)
- [`01_insert_verificar_mysql.png`](01_insert_verificar_mysql.png) - Verificación de la replicación en MySQL (Europa)

**Descripción:** Se insertan nuevos registros en la base de datos PostgreSQL y se verifica que estos datos se repliquen automáticamente hacia MySQL.

---

### 2️⃣ Prueba INSERT: MySQL → PostgreSQL

**Archivos:**
- [`02_insert_mysql_pg.png`](02_insert_mysql_pg.png) - Inserción de datos en MySQL (Europa)
- [`02_insert_verificar_pg.png`](02_insert_verificar_pg.png) - Verificación de la replicación en PostgreSQL (América)

**Descripción:** Se insertan nuevos registros en la base de datos MySQL y se verifica que estos datos se repliquen automáticamente hacia PostgreSQL.

---

### 3️⃣ Prueba UPDATE Bidireccional: PostgreSQL → MySQL

**Archivos:**
- [`03_update_bidireccional_pg.png`](03_update_bidireccional_pg.png) - Actualización de datos en PostgreSQL
- [`03_update_bi_verificar_mysql.png`](03_update_bi_verificar_mysql.png) - Verificación de la actualización en MySQL

**Descripción:** Se actualizan registros existentes en PostgreSQL y se confirma que los cambios se propagan correctamente a MySQL.

---

### 4️⃣ Prueba DELETE Bidireccional: MySQL → PostgreSQL

**Archivos:**
- [`04_delete_bidireccional_mysql.png`](04_delete_bidireccional_mysql.png) - Eliminación de datos en MySQL
- [`04_delete_bi_verificar_pg.png`](04_delete_bi_verificar_pg.png) - Verificación de la eliminación en PostgreSQL

**Descripción:** Se eliminan registros en MySQL y se verifica que la eliminación se replique correctamente hacia PostgreSQL.

---

## ✅ Qué Demuestran Estas Pruebas

Las capturas de pantalla en este directorio evidencian que:

1. **Replicación Bidireccional Funcional**: Los datos se sincronizan en ambas direcciones (PostgreSQL ↔ MySQL)
2. **Operaciones Completas DML**: Todas las operaciones (INSERT, UPDATE, DELETE) se replican correctamente
3. **Heterogeneidad**: La replicación funciona entre diferentes motores de bases de datos (PostgreSQL y MySQL)
4. **Sincronización Automática**: Los cambios se propagan sin intervención manual
5. **Integridad de Datos**: Los datos replicados mantienen su consistencia en ambos sistemas

## 📊 Tablas Replicadas

Las pruebas se realizaron sobre las siguientes tablas del esquema `globalshop`:

- `products` - Catálogo de productos
- `inventory` - Control de inventario por región
- `customers` - Clientes globales
- `promotions` - Promociones y descuentos

## 🔧 Herramientas Utilizadas

- **PostgreSQL 15**: Base de datos de la región América
- **MySQL 8.0**: Base de datos de la región Europa
- **SymmetricDS 3.16**: Motor de replicación bidireccional
- **Docker Compose**: Orquestación de contenedores

## 📝 Notas Importantes

- Las pruebas se ejecutaron después de confirmar que ambos nodos SymmetricDS estaban registrados y sincronizados
- Se verificó la ausencia de conflictos de replicación
- Los timestamps se actualizan automáticamente durante las operaciones
- La replicación se realiza a nivel lógico, no a nivel físico

---

**Fecha de las pruebas:** Enero 2026  
**Contexto:** Examen Práctico - Administración de Bases de Datos Distribuidas
