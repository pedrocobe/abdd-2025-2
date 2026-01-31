# Evidencias de Replicación PostgreSQL ↔ MySQL

**Estudiante:** Jordy Bravo Veliz
**Nivel:** Cuarto Nivel – Paralelo A
**Fecha:** 29 de enero de 2026
**Asignatura:** Administración de Bases de Datos Distribuidas

---


📸 **Evidencia:** `01_docker_compose_ps.png`

Esta captura muestra todos los contenedores en estado **UP (healthy)**.

---

## 🔗 Configuración de Replicación

### Nodos Registrados

Se verificó el registro correcto de ambos nodos en SymmetricDS:

* `america-store` (PostgreSQL)
* `europe-store` (MySQL)

📸 **Evidencias:**

* `evidencia_nodos.png`
* `evidencia_rep_nodos.png`

---

### Triggers y Enlaces de Replicación

Las siguientes tablas están configuradas para replicación:

* `products`
* `inventory`
* `customers`
* `promotions`

📸 **Evidencia:** `triggers_configurados.png`

Además, se comprobó la existencia de enlaces bidireccionales entre los grupos de nodos:

* América → Europa
* Europa → América

📸 **Evidencia:** `evidencia_replicacion_nodos.png`

---

## 🔄 Evidencias de Replicación

### 1️⃣ Replicación INSERT (PostgreSQL → MySQL)

**Operación realizada en PostgreSQL:**

```sql
INSERT INTO products (product_id, product_name, category, base_price, description, is_active)
VALUES ('P-DEF-OK', 'Producto Final', 'TEST', 11.11, 'Funciona', true);
```

**Resultado:**
El producto fue replicado automáticamente en MySQL.

📸 **Evidencia:** `replicacion_en_tabla_mysql.png`

---

### 2️⃣ Replicación INSERT (MySQL → PostgreSQL)

**Operación realizada en MySQL:**

```sql
INSERT INTO products (product_id, product_name, category, base_price, description, is_active)
VALUES ('P-CAP-002', 'Desde MySQL', 'TEST', 55.55, 'cap2', true);
```

**Resultado:**
El registro aparece correctamente en PostgreSQL.

📸 **Evidencia:** `02_replicacion_en_tabla_postgres.png`

---

### 3️⃣ Replicación DELETE (MySQL → PostgreSQL)

**Operación realizada en MySQL:**

```sql
DELETE FROM customers WHERE customer_id = 'EVIDENCIA-02';
```

**Resultado:**
El cliente fue eliminado tanto en MySQL como en PostgreSQL.

📸 **Evidencia:** `delete.png`

---

## 📊 Verificación de Batches de Replicación

Se verificó la generación y procesamiento de batches mediante las tablas internas de SymmetricDS.

**Tabla revisada:**

* `sym_outgoing_batch`
* `sym_incoming_batch`

📸 **Evidencia:** `batches_de_replicacion.png`

Los estados `OK` confirman que los cambios fueron transmitidos correctamente entre nodos.

---

## ✅ Conclusiones

A partir de las evidencias presentadas, se concluye que:

* La replicación entre PostgreSQL y MySQL funciona correctamente
* Se soportan operaciones **INSERT** y **DELETE**
* Los nodos SymmetricDS están correctamente configurados y sincronizados
* La replicación es automática y consistente

---

## 🛠️ Tecnologías Utilizadas

* PostgreSQL 15
* MySQL 8.0
* SymmetricDS 3.16
* Docker & Docker Compose
* PowerShell

---

**Estado del proyecto:** ✅ Funcional
**Evidencias entregadas:** Completas
