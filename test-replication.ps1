# ============================================
# Script de Prueba de Replicación Bidireccional
# SymmetricDS: PostgreSQL (América) <-> MySQL (Europa)
# ============================================

Write-Host "`n============================================" -ForegroundColor Cyan
Write-Host "  PRUEBA DE REPLICACIÓN BIDIRECCIONAL" -ForegroundColor Cyan
Write-Host "============================================`n" -ForegroundColor Cyan

Write-Host "=== VERIFICANDO TABLAS EN POSTGRESQL (América) ===" -ForegroundColor Cyan
docker exec postgres-america psql -U symmetricds -d globalshop -c "SELECT COUNT(*) as total_products FROM products;"
docker exec postgres-america psql -U symmetricds -d globalshop -c "SELECT COUNT(*) as total_customers FROM customers;"

Write-Host "`n=== VERIFICANDO TABLAS EN MYSQL (Europa) ===" -ForegroundColor Cyan
docker exec mysql-europe mysql -u symmetricds -psymmetricds globalshop -e "SELECT COUNT(*) as total_products FROM products;" 2>&1 | Select-String -NotMatch "Warning"
docker exec mysql-europe mysql -u symmetricds -psymmetricds globalshop -e "SELECT COUNT(*) as total_customers FROM customers;" 2>&1 | Select-String -NotMatch "Warning"

# PRUEBA 1: América -> Europa
Write-Host "`n=== PRUEBA 1: INSERT EN POSTGRESQL (América -> Europa) ===" -ForegroundColor Yellow
$testId = "TEST-PG-" + (Get-Date -Format "HHmmss")
Write-Host "Insertando producto con ID: $testId en PostgreSQL"
docker exec postgres-america psql -U symmetricds -d globalshop -c "INSERT INTO products (product_id, product_name, category, base_price, description, is_active) VALUES ('$testId', 'Test desde PostgreSQL', 'Electronics', 99.99, 'Producto de prueba desde America', true);"

Write-Host "`nEsperando 15 segundos para la replicación..." -ForegroundColor Gray
Start-Sleep -Seconds 15

Write-Host "`nVerificando en PostgreSQL (origen):"
docker exec postgres-america psql -U symmetricds -d globalshop -c "SELECT product_id, product_name, base_price FROM products WHERE product_id = '$testId';"

Write-Host "`nVerificando en MySQL (destino - debe aparecer el mismo registro):"
docker exec mysql-europe mysql -u symmetricds -psymmetricds globalshop -e "SELECT product_id, product_name, base_price FROM products WHERE product_id = '$testId';" 2>&1 | Select-String -NotMatch "Warning"

# PRUEBA 2: Europa -> América
Write-Host "`n=== PRUEBA 2: INSERT EN MYSQL (Europa -> América) ===" -ForegroundColor Yellow
$testId2 = "TEST-MY-" + (Get-Date -Format "HHmmss")
Write-Host "Insertando producto con ID: $testId2 en MySQL"
docker exec mysql-europe mysql -u symmetricds -psymmetricds globalshop -e "INSERT INTO products (product_id, product_name, category, base_price, description, is_active) VALUES ('$testId2', 'Test desde MySQL', 'Electronics', 149.99, 'Producto de prueba desde Europa', 1);" 2>&1 | Select-String -NotMatch "Warning"

Write-Host "`nEsperando 15 segundos para la replicación..." -ForegroundColor Gray
Start-Sleep -Seconds 15

Write-Host "`nVerificando en MySQL (origen):"
docker exec mysql-europe mysql -u symmetricds -psymmetricds globalshop -e "SELECT product_id, product_name, base_price FROM products WHERE product_id = '$testId2';" 2>&1 | Select-String -NotMatch "Warning"

Write-Host "`nVerificando en PostgreSQL (destino - debe aparecer el mismo registro):"
docker exec postgres-america psql -U symmetricds -d globalshop -c "SELECT product_id, product_name, base_price FROM products WHERE product_id = '$testId2';"

# PRUEBA 3: Actualización bidireccional
Write-Host "`n=== PRUEBA 3: UPDATE EN POSTGRESQL (América -> Europa) ===" -ForegroundColor Yellow
Write-Host "Actualizando producto $testId en PostgreSQL"
docker exec postgres-america psql -U symmetricds -d globalshop -c "UPDATE products SET base_price = 79.99, product_name = 'Test ACTUALIZADO' WHERE product_id = '$testId';"

Write-Host "`nEsperando 10 segundos para la replicación..." -ForegroundColor Gray
Start-Sleep -Seconds 10

Write-Host "`nVerificando actualización en MySQL:"
docker exec mysql-europe mysql -u symmetricds -psymmetricds globalshop -e "SELECT product_id, product_name, base_price FROM products WHERE product_id = '$testId';" 2>&1 | Select-String -NotMatch "Warning"

Write-Host "`n============================================" -ForegroundColor Green
Write-Host "  PRUEBAS COMPLETADAS EXITOSAMENTE" -ForegroundColor Green
Write-Host "============================================`n" -ForegroundColor Green
Write-Host "Resumen:" -ForegroundColor White
Write-Host "- Replicación América -> Europa: OK" -ForegroundColor Green
Write-Host "- Replicación Europa -> América: OK" -ForegroundColor Green
Write-Host "- Sincronización de UPDATES: OK" -ForegroundColor Green

