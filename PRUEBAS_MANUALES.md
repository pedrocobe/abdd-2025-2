# Pruebas de Replicación - Comandos Manuales

## Estado Actual
- Docker Compose: 4 contenedores (PostgreSQL, MySQL, SymmetricDS-America, SymmetricDS-Europe) están Up y Healthy
- Bases de datos: creadas y configuradas
- Tablas de negocio: products, inventory, customers, promotions en ambas BDs
- SymmetricDS: configurado con canales, triggers y routers

## Instrucciones para Capturar Evidencias

### 1. INSERT PostgreSQL → MySQL
```bash
# Terminal 1: Conectar a PostgreSQL
docker exec -it postgres-america psql -U symmetricds -d globalshop

# Dentro del psql:
INSERT INTO products (product_id, product_name, category, base_price, description, is_active, created_at, updated_at) 
VALUES ('DEMO-001','Producto Demo','Demo',99.99,'Producto de Demostración',true,NOW(),NOW());

SELECT * FROM products WHERE product_id = 'DEMO-001';
```

```bash
# Terminal 2: Verificar en MySQL
docker exec -it mysql-europe mysql -u symmetricds -psymmetricds globalshop

# Dentro de mysql:
SELECT * FROM products WHERE product_id = 'DEMO-001';
```

### 2. INSERT MySQL → PostgreSQL
```bash
# Terminal 1: Conectar a MySQL
docker exec -it mysql-europe mysql -u symmetricds -psymmetricds globalshop

# Dentro de mysql:
INSERT INTO customers (customer_id, email, full_name, country, registration_date, is_premium, last_purchase_date) 
VALUES ('DEMO-CUST','demo@test.com','Cliente Demo','España',NOW(),1,NOW());

SELECT * FROM customers WHERE customer_id = 'DEMO-CUST';
```

```bash
# Terminal 2: Verificar en PostgreSQL
docker exec -it postgres-america psql -U symmetricds -d globalshop

# Dentro del psql:
SELECT * FROM customers WHERE customer_id = 'DEMO-CUST';
```

### 3. UPDATE Bidireccional
```bash
# Terminal 1: UPDATE en PostgreSQL
docker exec -it postgres-america psql -U symmetricds -d globalshop

# Dentro del psql:
UPDATE products SET base_price = 149.99 WHERE product_id = 'DEMO-001';
SELECT product_id, base_price FROM products WHERE product_id = 'DEMO-001';
```

```bash
# Terminal 2: Verificar en MySQL
docker exec -it mysql-europe mysql -u symmetricds -psymmetricds globalshop

# Dentro de mysql:
SELECT product_id, base_price FROM products WHERE product_id = 'DEMO-001';
```

### 4. DELETE Bidireccional
```bash
# Terminal 1: DELETE en MySQL
docker exec -it mysql-europe mysql -u symmetricds -psymmetricds globalshop

# Dentro de mysql:
DELETE FROM customers WHERE customer_id = 'DEMO-CUST';
SELECT COUNT(*) FROM customers WHERE customer_id = 'DEMO-CUST';
```

```bash
# Terminal 2: Verificar en PostgreSQL
docker exec -it postgres-america psql -U symmetricds -d globalshop

# Dentro del psql:
SELECT COUNT(*) FROM customers WHERE customer_id = 'DEMO-CUST';
```

## Nota Importante
Las imágenes deben capturar:
1. El comando INSERT/UPDATE/DELETE ejecutado en una BD
2. El resultado de la verificación en la otra BD
3. Ambas consultas SELECT en la captura (confirmar replicación)

