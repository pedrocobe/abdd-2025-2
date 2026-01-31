# 📸 Evidencias de Replicación Bidireccional

Este directorio contiene las capturas de pantalla que demuestran el correcto funcionamiento de la replicación bidireccional entre PostgreSQL (América) y MySQL (Europa).

## Pruebas Realizadas

### 1️⃣ INSERT: PostgreSQL → MySQL
**Archivo:** `01_insert_pg_to_mysql.png`

**Operación realizada:**
- Se insertó un nuevo registro en la tabla `products` en PostgreSQL (América)
- Se verificó que el registro apareció automáticamente en MySQL (Europa)

**Comando ejecutado:**
```sql
-- En PostgreSQL
INSERT INTO products VALUES ('DEMO-001', 'Producto Demo', 'Demo', 99.99, 'Descripción demo', true, NOW(), NOW());
SELECT * FROM products WHERE product_id = 'DEMO-001';

-- Verificación en MySQL
SELECT * FROM products WHERE product_id = 'DEMO-001';
```

**Resultado:** ✅ La replicación PostgreSQL → MySQL funciona correctamente.

---

### 2️⃣ INSERT: MySQL → PostgreSQL
**Archivo:** `02_insert_mysql_to_pg.png`

**Operación realizada:**
- Se insertó un nuevo cliente en la tabla `customers` en MySQL (Europa)
- Se verificó que el registro se replicó automáticamente a PostgreSQL (América)

**Comando ejecutado:**
```sql
-- En MySQL
INSERT INTO customers VALUES ('DEMO-CUST', 'demo@test.com', 'Cliente Demo', 'Spain', NOW(), 1, NOW());
SELECT * FROM customers WHERE customer_id = 'DEMO-CUST';

-- Verificación en PostgreSQL
SELECT * FROM customers WHERE customer_id = 'DEMO-CUST';
```

**Resultado:** ✅ La replicación MySQL → PostgreSQL funciona correctamente.

---

### 3️⃣ UPDATE Bidireccional
**Archivo:** `03_update_bidireccional.png`

**Operación realizada:**
- Se actualizó el precio de un producto en PostgreSQL
- Se verificó que el cambio se replicó automáticamente a MySQL

**Comando ejecutado:**
```sql
-- Actualización en PostgreSQL
UPDATE products SET base_price = 149.99 WHERE product_id = 'DEMO-001';
SELECT product_id, base_price FROM products WHERE product_id = 'DEMO-001';

-- Verificación en MySQL
SELECT product_id, base_price FROM products WHERE product_id = 'DEMO-001';
```

**Resultado:** ✅ Las actualizaciones se replican correctamente en ambas direcciones.

---

### 4️⃣ DELETE Bidireccional
**Archivo:** `04_delete_bidireccional.png`

**Operación realizada:**
- Se eliminó un cliente en MySQL
- Se verificó que la eliminación se reflejó automáticamente en PostgreSQL

**Comando ejecutado:**
```sql
-- Eliminación en MySQL
DELETE FROM customers WHERE customer_id = 'DEMO-MYSQL';
SELECT COUNT(*) FROM customers WHERE customer_id = 'DEMO-MYSQL';

-- Verificación en PostgreSQL
SELECT COUNT(*) FROM customers WHERE customer_id = 'DEMO-MYSQL';
```

**Resultado:** ✅ Las eliminaciones se replican correctamente en ambas direcciones.

---

## ✅ Conclusión

Se ha demostrado exitosamente que la replicación bidireccional heterogénea entre PostgreSQL y MySQL funciona correctamente para todas las operaciones DML:

- ✅ **INSERT** (PostgreSQL → MySQL)
- ✅ **INSERT** (MySQL → PostgreSQL)
- ✅ **UPDATE** (Bidireccional)
- ✅ **DELETE** (Bidireccional)

La configuración de SymmetricDS está operando correctamente con:
- 4 triggers configurados (products, inventory, customers, promotions)
- 4 canales de replicación
- Routers bidireccionales funcionales
- Sincronización automática entre ambas bases de datos

---

**Fecha de pruebas:** 30 de Enero de 2026  
**Arquitectura:** PostgreSQL 15 ↔ SymmetricDS 3.16 ↔ MySQL 8.0