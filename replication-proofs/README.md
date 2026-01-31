# Evidencias de Replicacion Bidireccional

## Estudiante
- **Nombre:** Elkin Vicente Delgado Licoa
- **Cedula:** 1313713131
- **Fecha:** 31 de enero de 2026

## Descripci�n de Capturas

### 01_arquitectura.png
Muestra los 4 contenedores corriendo correctamente con `docker ps`.
- postgres-america (puerto 5432)
- mysql-europe (puerto 3306)
- symmetricds-america (puerto 31415) - Nodo ROOT
- symmetricds-europe (puerto 31416) - Nodo CLIENT

### 02_insert_pg_mysql.png
Insercion de un producto en PostgreSQL que se replico a MySQL.
- Producto ID: EVIDENCIA-01
- Nombre: Producto de Evidencia
- Precio: 199.99
- Tiempo de replicacion: ~10 segundos

### 03_insert_mysql_pg.png
Insercion de un cliente en MySQL que se replico a PostgreSQL.
- Cliente ID: EVIDENCIA-02
- Email: test@evidencia.com
- Tiempo de replicacion: ~10 segundos

### 04_update.png
Actualizacion del precio del producto desde PostgreSQL.
- Producto: EVIDENCIA-01
- Precio anterior: 199.99  Precio nuevo: 299.99
- Se verifico que el cambio llego a MySQL

### 05_delete.png
Eliminacion del cliente desde MySQL.
- Se elimino EVIDENCIA-02 desde MySQL
- Se verifico que desaparecio de PostgreSQL

## Notas Adicionales

Durante las pruebas tuve que esperar como 60-90 segundos despues de levantar los contenedores para que SymmetricDS terminara de configurarse. Al principio penso que no funcionaba pero solo era cuestion de esperar.

Tambion me encontro con un error de permisos en MySQL (necesitaba el privilegio PROCESS) que tuve que solucionar agregando los grants en el script de inicializacion.

La parte mas complicada fue entender como funcionan los triggers y routers de SymmetricDS, pero una vez que entendi la logica todo empezo a funcionar.

## Conclusion

La replicacion bidireccional heterogonea entre PostgreSQL y MySQL est� funcionando correctamente:
-  INSERT: PostgreSQL  MySQL
-  INSERT: MySQL  PostgreSQL  
-  UPDATE: Bidireccional
-  DELETE: Bidireccional

Los cambios se propagan en aproximadamente 10 segundos. El sistema usa SymmetricDS como middleware que captura cambios mediante triggers (CDC - Change Data Capture) y los transmite via HTTP.

Esto demuestra que es posible mantener datos sincronizados entre bases de datos de distintos fabricantes, aunque hay que tener en cuenta que la replicacion es asincrona, osea que no hay consistencia inmediata (es un sistema tipo BASE, no ACID estricto).
