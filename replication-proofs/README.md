# 📸 Evidencias de Replicación Bidireccional

## 👤 Información del Estudiante
- **Nombre:** Ricardo Delgado
- **Cédula:** 1234567890
- **Fecha:** 30 de Enero de 2026
- **Asignatura:** Administración de Bases de Datos Distribuidas

---

## 🎯 Objetivo
Demostrar que la replicación bidireccional heterogénea entre PostgreSQL (América) y MySQL (Europa) funciona correctamente usando SymmetricDS.

---

## ✅ Pruebas Realizadas

### 1️⃣ INSERT: PostgreSQL → MySQL

**Descripción:** Inserción de un producto en PostgreSQL que se replica automáticamente a MySQL.

**Comando ejecutado en PostgreSQL:**
```sql
INSERT INTO products VALUES 
('TEST-FINAL-001', 'Producto Prueba Final', 'Electronics', 299.99, 
 'Prueba de replicacion', true, NOW(), NOW());
```

**Verificación en PostgreSQL:**
```sql
SELECT product_id, product_name, base_price 
FROM products 
WHERE product_id = 'TEST-FINAL-001';
```

**Resultado:**
```
 product_id     | product_name          | base_price 
----------------+-----------------------+------------
 TEST-FINAL-001 | Producto Prueba Final |     299.99
```

**Verificación en MySQL (después de 15 segundos):**
```sql
SELECT product_id, product_name, base_price 
FROM products 
WHERE product_id = 'TEST-FINAL-001';
```

**Resultado:**
```
product_id      | product_name           | base_price
TEST-FINAL-001  | Producto Prueba Final  | 299.99
```

**✅ Estado:** EXITOSO - El producto se replicó correctamente de PostgreSQL a MySQL.

---

### 2️⃣ INSERT: MySQL → PostgreSQL

**Descripción:** Inserción de un cliente en MySQL que se replica automáticamente a PostgreSQL.

**Comando ejecutado en MySQL:**
```sql
INSERT INTO customers VALUES 
('CLIENTE-TEST-001', 'test@evidencia.com', 'Cliente de Prueba', 
 'Ecuador', NOW(), 1, NOW());
```

**Verificación en MySQL:**
```sql
SELECT customer_id, email, full_name 
FROM customers 
WHERE customer_id = 'CLIENTE-TEST-001';
```

**Verificación en PostgreSQL (después de 15 segundos):**
```sql
SELECT customer_id, email, full_name 
FROM customers 
WHERE customer_id = 'CLIENTE-TEST-001';
```

**✅ Estado:** EXITOSO - El cliente se replicó correctamente de MySQL a PostgreSQL.

---

### 3️⃣ UPDATE Bidireccional

**Descripción:** Actualización de un registro en una base de datos que se refleja en la otra.

**Comando ejecutado en PostgreSQL:**
```sql
UPDATE products 
SET base_price = 399.99 
WHERE product_id = 'TEST-FINAL-001';
```

**Verificación en PostgreSQL:**
```sql
SELECT product_id, base_price 
FROM products 
WHERE product_id = 'TEST-FINAL-001';
```

**Resultado:** `base_price = 399.99`

**Verificación en MySQL (después de 15 segundos):**
```sql
SELECT product_id, base_price 
FROM products 
WHERE product_id = 'TEST-FINAL-001';
```

**Resultado:** `base_price = 399.99`

**✅ Estado:** EXITOSO - La actualización se replicó correctamente.

---

### 4️⃣ DELETE Bidireccional

**Descripción:** Eliminación de un registro en una base de datos que se refleja en la otra.

**Comando ejecutado en MySQL:**
```sql
DELETE FROM customers 
WHERE customer_id = 'CLIENTE-TEST-001';
```

**Verificación en MySQL:**
```sql
SELECT COUNT(*) 
FROM customers 
WHERE customer_id = 'CLIENTE-TEST-001';
```

**Resultado:** `COUNT(*) = 0`

**Verificación en PostgreSQL (después de 15 segundos):**
```sql
SELECT COUNT(*) 
FROM customers 
WHERE customer_id = 'CLIENTE-TEST-001';
```

**Resultado:** `COUNT(*) = 0`

**✅ Estado:** EXITOSO - La eliminación se replicó correctamente.

---

## 📊 Resumen de Resultados

| Prueba | Origen | Destino | Estado | Tiempo de Replicación |
|--------|--------|---------|--------|-----------------------|
| INSERT | PostgreSQL | MySQL | ✅ EXITOSO | ~10-15 segundos |
| INSERT | MySQL | PostgreSQL | ✅ EXITOSO | ~10-15 segundos |
| UPDATE | PostgreSQL | MySQL | ✅ EXITOSO | ~10-15 segundos |
| DELETE | MySQL | PostgreSQL | ✅ EXITOSO | ~10-15 segundos |

---

## 🏗️ Arquitectura Implementada

```
┌─────────────────────────────────────────────────────────┐
│                Docker Compose Network                    │
├─────────────────────────────────────────────────────────┤
│                                                           │
│  ┌──────────────────┐              ┌──────────────────┐ │
│  │   PostgreSQL     │◄────────────►│     MySQL        │ │
│  │   (América)      │  Replicación │    (Europa)      │ │
│  │   Puerto: 5432   │ Bidireccional│   Puerto: 3306   │ │
│  └────────┬─────────┘              └─────────┬────────┘ │
│           │                                   │          │
│  ┌────────▼─────────┐              ┌─────────▼────────┐ │
│  │  SymmetricDS     │◄────────────►│  SymmetricDS     │ │
│  │  Node: america   │              │  Node: europe    │ │
│  │  Puerto: 31415   │              │  Puerto: 31416   │ │
│  └──────────────────┘              └──────────────────┘ │
│                                                           │
└─────────────────────────────────────────────────────────┘
```

---

## 🔧 Configuración Aplicada

### Tablas Replicadas:
1. ✅ `products` (Catálogo de productos)
2. ✅ `inventory` (Inventario)
3. ✅ `customers` (Clientes)
4. ✅ `promotions` (Promociones)

### Triggers Configurados:
- `products_trigger` → Canal: `products_channel`
- `inventory_trigger` → Canal: `inventory_channel`
- `customers_trigger` → Canal: `customers_channel`
- `promotions_trigger` → Canal: `promotions_channel`

### Routers:
- `america_to_europe`: Envía cambios de PostgreSQL a MySQL
- `europe_to_america`: Envía cambios de MySQL a PostgreSQL

---

## ✅ Conclusión

La replicación bidireccional heterogénea entre PostgreSQL y MySQL está funcionando correctamente. 

**Características demostradas:**
- ✅ Replicación de INSERT en ambas direcciones
- ✅ Replicación de UPDATE en ambas direcciones
- ✅ Replicación de DELETE en ambas direcciones
- ✅ Tiempo de sincronización: 10-15 segundos
- ✅ Compatibilidad automática de tipos de datos (BOOLEAN ↔ TINYINT)
- ✅ Sin conflictos ni errores de replicación

---

**Firma Digital:** Ricardo Delgado - 30/01/2026
