# Ejecuta esto en PowerShell (Windows) desde la carpeta donde está este archivo.
# 1) Arranque limpio
docker compose down -v
docker compose up -d

# 2) Cargar configuración SymmetricDS (setup) en las bases
Get-Content .\symmetricds\america\engines\america-setup.sql | docker exec -i postgres-america psql -U symmetricds -d globalshop
Get-Content .\symmetricds\europe\engines\europe-setup.sql   | docker exec -i mysql-europe mysql -usymmetricds -psymmetricds globalshop

# 3) Verificación rápida: deben salir filas
docker exec -it postgres-america psql -U symmetricds -d globalshop -c "select trigger_id, source_table_name from sym_trigger;"
docker exec -it postgres-america psql -U symmetricds -d globalshop -c "select source_node_group_id, target_node_group_id from sym_node_group_link;"

# 4) Prueba de replicación 
docker exec -it postgres-america psql -U symmetricds -d globalshop -c "insert into products (product_id, product_name, category, base_price, description, is_active) values ('P-OK-001','Producto Replicado OK','TEST',20.00,'Setup cargado',true);"
docker exec -it mysql-europe mysql -usymmetricds -psymmetricds globalshop -e "select product_id, product_name, base_price from products where product_id='P-OK-001';"
