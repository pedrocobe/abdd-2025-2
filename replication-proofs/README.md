Estudiante: Freddy Marcelo Bravo Ponce

1. Descripción del Proyecto
Este proyecto demuestra la implementación de un sistema de replicación de datos bidireccional y heterogéneo utilizando SymmetricDS. Se conectan dos nodos geográficamente distribuidos con motores de base de datos distintos:

Nodo América (Matriz): PostgreSQL corriendo en un contenedor Docker.

Nodo Europa (Sucursal): MySQL corriendo en un contenedor Docker.

2. Stack Tecnológico Utilizado
Motores de DB: PostgreSQL 16 y MySQL 8.0.

Middleware de Replicación: SymmetricDS 3.16.

Virtualización: Docker y Docker Compose.

Herramientas de Gestión: DBeaver y Terminal (PowerShell).

3. Guía de Comandos y Pruebas (Ciclo CRUD)
A continuación, se detallan los comandos ejecutados para validar la sincronización de datos entre los nodos.

A. Operaciones de Inserción (Create)
Para demostrar la captura de datos, se insertaron registros en ambos nodos:

En Postgres (América):

PowerShell
docker exec -it postgres-america psql -U symmetricds -d globalshop -c "INSERT INTO products (product_id, product_name, category, base_price, is_active) VALUES ('ULEAM-001', 'Laptop Ingenieria', 'Hardware', 1150.00, true); SELECT * FROM products WHERE product_id = 'ULEAM-001';"
En MySQL (Europa):

PowerShell
docker exec -it mysql-europe mysql -u symmetricds -psymmetricds globalshop -e "INSERT INTO customers (customer_id, email, full_name, country, is_premium) VALUES ('CUST-EU-001', 'ventas.europa@mail.com', 'Lucas Muller', 'España', 1); SELECT * FROM customers WHERE customer_id = 'CUST-EU-001';"
B. Operaciones de Actualización (Update)
Se modificaron los registros para validar que los triggers capturen los cambios:

Actualización en Postgres:

PowerShell
docker exec -it postgres-america psql -U symmetricds -d globalshop -c "UPDATE products SET base_price = 1299.99 WHERE product_id = 'ULEAM-001'; SELECT product_name, base_price FROM products WHERE product_id = 'ULEAM-001';"
Actualización en MySQL:

PowerShell
docker exec -it mysql-europe mysql -u symmetricds -psymmetricds globalshop -e "UPDATE customers SET email = 'lucas.muller.vip@mail.com' WHERE customer_id = 'CUST-EU-001'; SELECT full_name, email FROM customers WHERE customer_id = 'CUST-EU-001';"
C. Operaciones de Eliminación (Delete)
Validación de la propagación de borrados para mantener la integridad:

Borrado en Postgres:

PowerShell
docker exec -it postgres-america psql -U symmetricds -d globalshop -c "DELETE FROM products WHERE product_id = 'ULEAM-001'; SELECT count(*) FROM products WHERE product_id = 'ULEAM-001';"
Borrado en MySQL:

PowerShell
docker exec -it mysql-europe mysql -u symmetricds -psymmetricds globalshop -e "DELETE FROM customers WHERE customer_id = 'CUST-EU-001'; SELECT count(*) FROM customers WHERE customer_id = 'CUST-EU-001';"
4. Conclusiones Técnicas

Independencia de Motor: Se logró la comunicación exitosa entre Postgres y MySQL, superando las diferencias de sintaxis y tipos de datos.

Captura de Cambios (CDC): El uso de disparadores (triggers) permite que la replicación sea casi en tiempo real sin intervención manual.

Arquitectura Robusta: La solución es escalable para más nodos, ideal para empresas con múltiples sucursales que requieren consistencia de datos.