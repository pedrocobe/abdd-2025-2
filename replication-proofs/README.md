# Evidencias de Replicación Bidireccional SymmetricDS

## Estudiante
- **Javier Zamora Zambrano**
- **1314186527**
- **01/30/2026** [Fecha de pruebas]

## Descripción del Proyecto

Este proyecto implementa replicación heterogénea bidireccional entre PostgreSQL y MySQL utilizando SymmetricDS 3.16. Se demuestra la sincronización de datos entre dos nodos geográficamente distribuidos:
- **Nodo America**: PostgreSQL (Node ID: 001, puerto 5432)
- **Nodo Europe**: MySQL (Node ID: 002, puerto 3306)

---

## 📸 Capturas de Pantalla Requeridas

Este directorio contiene las 4 evidencias obligatorias de replicación bidireccional entre PostgreSQL (América) y MySQL (Europa).

### 1️⃣ `01_insert_pg_to_mysql.png`
**Descripción:** INSERT de PostgreSQL hacia MySQL

### 2️⃣ `02_insert_mysql_to_pg.png`
**Descripción:** INSERT de MySQL hacia PostgreSQL


### 3️⃣ `03_update_bidireccional.png`
**Descripción:** UPDATE replicado bidireccionalmente

### 4️⃣ `04_delete_bidireccional.png`
**Descripción:** DELETE replicado bidireccionalmente


---

## 🎓 Notas para el Profesor

**Sistema implementado:**
- Replicación heterogénea: PostgreSQL 15 ↔ MySQL 8.0
- Motor: SymmetricDS 3.16
- Arquitectura: Multi-master bidireccional
- Tablas replicadas: 4 (products, inventory, customers, promotions)
- Sincronización: Automática mediante triggers

**Características demostradas:**
1. ✅ Replicación INSERT en ambas direcciones
2. ✅ Replicación UPDATE con conversión de tipos
3. ✅ Replicación DELETE sincronizada
4. ✅ Conversión automática PostgreSQL BOOLEAN ↔ MySQL TINYINT

**Tiempo promedio de replicación:** 10-15 segundos

