#!/bin/bash

# ============================================
# Script de Validación Automática
# Examen: Replicación Bidireccional con SymmetricDS
# ============================================

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Contadores
TESTS_PASSED=0
TESTS_FAILED=0
TOTAL_TESTS=0

# Variables de configuración
POSTGRES_CONTAINER="postgres-america"
MYSQL_CONTAINER="mysql-europe"
SYMMETRICDS_AMERICA="symmetricds-america"
SYMMETRICDS_EUROPE="symmetricds-europe"
DB_NAME="globalshop"
WAIT_TIME=10

# ============================================
# Funciones auxiliares
# ============================================

print_header() {
    echo -e "${BLUE}============================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}============================================${NC}"
}

print_test() {
    echo -e "${YELLOW}[TEST] $1${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
    ((TESTS_PASSED++))
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
    ((TESTS_FAILED++))
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

wait_for_sync() {
    print_info "Esperando $WAIT_TIME segundos para que la replicación se complete..."
    sleep $WAIT_TIME
}

# ============================================
# Validaciones de prerequisitos
# ============================================

validate_prerequisites() {
    print_header "VALIDANDO PREREQUISITOS"
    ((TOTAL_TESTS+=4))
    
    # Verificar Docker
    print_test "Verificando Docker..."
    if command -v docker &> /dev/null; then
        print_success "Docker está instalado"
    else
        print_error "Docker no está instalado"
        exit 1
    fi
    
    # Verificar Docker Compose
    print_test "Verificando Docker Compose..."
    if command -v docker compose &> /dev/null || docker compose version &> /dev/null; then
        print_success "Docker Compose está disponible"
    else
        print_error "Docker Compose no está disponible"
        exit 1
    fi
    
    # Verificar que los contenedores estén corriendo
    print_test "Verificando contenedor PostgreSQL..."
    if docker ps | grep -q "$POSTGRES_CONTAINER"; then
        print_success "Contenedor PostgreSQL está corriendo"
    else
        print_error "Contenedor PostgreSQL no está corriendo"
        print_info "Ejecuta: docker compose up -d"
        exit 1
    fi
    
    print_test "Verificando contenedor MySQL..."
    if docker ps | grep -q "$MYSQL_CONTAINER"; then
        print_success "Contenedor MySQL está corriendo"
    else
        print_error "Contenedor MySQL no está corriendo"
        print_info "Ejecuta: docker compose up -d"
        exit 1
    fi
}

# ============================================
# Validar conectividad de bases de datos
# ============================================

validate_db_connectivity() {
    print_header "VALIDANDO CONECTIVIDAD A BASES DE DATOS"
    ((TOTAL_TESTS+=2))
    
    print_test "Conectando a PostgreSQL..."
    if docker exec $POSTGRES_CONTAINER psql -U symmetricds -d $DB_NAME -c "SELECT 1;" &> /dev/null; then
        print_success "Conexión a PostgreSQL exitosa"
    else
        print_error "No se puede conectar a PostgreSQL"
        exit 1
    fi
    
    print_test "Conectando a MySQL..."
    if docker exec $MYSQL_CONTAINER mysql -u symmetricds -psymmetricds $DB_NAME -e "SELECT 1;" &> /dev/null; then
        print_success "Conexión a MySQL exitosa"
    else
        print_error "No se puede conectar a MySQL"
        exit 1
    fi
}

# ============================================
# Validar SymmetricDS
# ============================================

validate_symmetricds() {
    print_header "VALIDANDO NODOS SYMMETRICDS"
    ((TOTAL_TESTS+=2))
    
    print_test "Verificando nodo SymmetricDS América..."
    if docker ps | grep -q "$SYMMETRICDS_AMERICA"; then
        print_success "Nodo SymmetricDS América está corriendo"
    else
        print_error "Nodo SymmetricDS América no está corriendo"
        exit 1
    fi
    
    print_test "Verificando nodo SymmetricDS Europa..."
    if docker ps | grep -q "$SYMMETRICDS_EUROPE"; then
        print_success "Nodo SymmetricDS Europa está corriendo"
    else
        print_error "Nodo SymmetricDS Europa no está corriendo"
        exit 1
    fi
}

# ============================================
# Test 1: Replicación INSERT (PostgreSQL -> MySQL)
# ============================================

test_insert_postgres_to_mysql() {
    print_header "TEST 1: INSERT PostgreSQL → MySQL"
    ((TOTAL_TESTS+=4))
    
    # Limpiar datos de prueba previos
    docker exec $POSTGRES_CONTAINER psql -U symmetricds -d $DB_NAME -c \
        "DELETE FROM products WHERE product_id = 'TEST-PG-001';" &> /dev/null || true
    docker exec $MYSQL_CONTAINER mysql -u symmetricds -psymmetricds $DB_NAME -e \
        "DELETE FROM products WHERE product_id = 'TEST-PG-001';" &> /dev/null || true
    
    # Insertar en PostgreSQL
    print_test "Insertando producto en PostgreSQL..."
    docker exec $POSTGRES_CONTAINER psql -U symmetricds -d $DB_NAME -c \
        "INSERT INTO products (product_id, product_name, category, base_price, description, is_active) 
         VALUES ('TEST-PG-001', 'Test Product from PostgreSQL', 'Test', 99.99, 'Test replication', true);"
    
    if [ $? -eq 0 ]; then
        print_success "Producto insertado en PostgreSQL"
    else
        print_error "Error al insertar en PostgreSQL"
        return
    fi
    
    # Esperar replicación
    wait_for_sync
    
    # Verificar en MySQL
    print_test "Verificando replicación en MySQL..."
    RESULT=$(docker exec $MYSQL_CONTAINER mysql -u symmetricds -psymmetricds $DB_NAME -N -e \
        "SELECT COUNT(*) FROM products WHERE product_id = 'TEST-PG-001';")
    
    if [ "$RESULT" = "1" ]; then
        print_success "Producto replicado correctamente a MySQL"
    else
        print_error "Producto NO replicado a MySQL (encontrados: $RESULT)"
        return
    fi
    
    # Verificar datos
    print_test "Verificando integridad de datos..."
    NAME=$(docker exec $MYSQL_CONTAINER mysql -u symmetricds -psymmetricds $DB_NAME -N -e \
        "SELECT product_name FROM products WHERE product_id = 'TEST-PG-001';")
    
    if [ "$NAME" = "Test Product from PostgreSQL" ]; then
        print_success "Datos replicados correctamente"
    else
        print_error "Datos incorrectos (nombre: $NAME)"
    fi
}

# ============================================
# Test 2: Replicación INSERT (MySQL -> PostgreSQL)
# ============================================

test_insert_mysql_to_postgres() {
    print_header "TEST 2: INSERT MySQL → PostgreSQL"
    ((TOTAL_TESTS+=4))
    
    # Limpiar datos de prueba previos
    docker exec $MYSQL_CONTAINER mysql -u symmetricds -psymmetricds $DB_NAME -e \
        "DELETE FROM products WHERE product_id = 'TEST-MY-001';" &> /dev/null || true
    docker exec $POSTGRES_CONTAINER psql -U symmetricds -d $DB_NAME -c \
        "DELETE FROM products WHERE product_id = 'TEST-MY-001';" &> /dev/null || true
    
    # Insertar en MySQL
    print_test "Insertando producto en MySQL..."
    docker exec $MYSQL_CONTAINER mysql -u symmetricds -psymmetricds $DB_NAME -e \
        "INSERT INTO products (product_id, product_name, category, base_price, description, is_active) 
         VALUES ('TEST-MY-001', 'Test Product from MySQL', 'Test', 149.99, 'Test replication', 1);"
    
    if [ $? -eq 0 ]; then
        print_success "Producto insertado en MySQL"
    else
        print_error "Error al insertar en MySQL"
        return
    fi
    
    # Esperar replicación
    wait_for_sync
    
    # Verificar en PostgreSQL
    print_test "Verificando replicación en PostgreSQL..."
    RESULT=$(docker exec $POSTGRES_CONTAINER psql -U symmetricds -d $DB_NAME -t -A -c \
        "SELECT COUNT(*) FROM products WHERE product_id = 'TEST-MY-001';")
    
    if [ "$RESULT" = "1" ]; then
        print_success "Producto replicado correctamente a PostgreSQL"
    else
        print_error "Producto NO replicado a PostgreSQL (encontrados: $RESULT)"
        return
    fi
    
    # Verificar datos
    print_test "Verificando integridad de datos..."
    NAME=$(docker exec $POSTGRES_CONTAINER psql -U symmetricds -d $DB_NAME -t -A -c \
        "SELECT product_name FROM products WHERE product_id = 'TEST-MY-001';")
    
    if [ "$NAME" = "Test Product from MySQL" ]; then
        print_success "Datos replicados correctamente"
    else
        print_error "Datos incorrectos (nombre: $NAME)"
    fi
}

# ============================================
# Test 3: Replicación UPDATE (PostgreSQL -> MySQL)
# ============================================

test_update_postgres_to_mysql() {
    print_header "TEST 3: UPDATE PostgreSQL → MySQL"
    ((TOTAL_TESTS+=3))
    
    # Actualizar en PostgreSQL
    print_test "Actualizando producto en PostgreSQL..."
    docker exec $POSTGRES_CONTAINER psql -U symmetricds -d $DB_NAME -c \
        "UPDATE products SET base_price = 79.99, product_name = 'UPDATED from PostgreSQL' 
         WHERE product_id = 'TEST-PG-001';"
    
    if [ $? -eq 0 ]; then
        print_success "Producto actualizado en PostgreSQL"
    else
        print_error "Error al actualizar en PostgreSQL"
        return
    fi
    
    # Esperar replicación
    wait_for_sync
    
    # Verificar en MySQL
    print_test "Verificando actualización en MySQL..."
    PRICE=$(docker exec $MYSQL_CONTAINER mysql -u symmetricds -psymmetricds $DB_NAME -N -e \
        "SELECT base_price FROM products WHERE product_id = 'TEST-PG-001';")
    
    if [ "$PRICE" = "79.99" ]; then
        print_success "Precio actualizado correctamente en MySQL"
    else
        print_error "Precio NO actualizado en MySQL (precio: $PRICE)"
        return
    fi
    
    print_test "Verificando nombre actualizado..."
    NAME=$(docker exec $MYSQL_CONTAINER mysql -u symmetricds -psymmetricds $DB_NAME -N -e \
        "SELECT product_name FROM products WHERE product_id = 'TEST-PG-001';")
    
    if [[ "$NAME" == *"UPDATED from PostgreSQL"* ]]; then
        print_success "Nombre actualizado correctamente en MySQL"
    else
        print_error "Nombre NO actualizado en MySQL (nombre: $NAME)"
    fi
}

# ============================================
# Test 4: Replicación UPDATE (MySQL -> PostgreSQL)
# ============================================

test_update_mysql_to_postgres() {
    print_header "TEST 4: UPDATE MySQL → PostgreSQL"
    ((TOTAL_TESTS+=3))
    
    # Actualizar en MySQL
    print_test "Actualizando producto en MySQL..."
    docker exec $MYSQL_CONTAINER mysql -u symmetricds -psymmetricds $DB_NAME -e \
        "UPDATE products SET base_price = 119.99, product_name = 'UPDATED from MySQL' 
         WHERE product_id = 'TEST-MY-001';"
    
    if [ $? -eq 0 ]; then
        print_success "Producto actualizado en MySQL"
    else
        print_error "Error al actualizar en MySQL"
        return
    fi
    
    # Esperar replicación
    wait_for_sync
    
    # Verificar en PostgreSQL
    print_test "Verificando actualización en PostgreSQL..."
    PRICE=$(docker exec $POSTGRES_CONTAINER psql -U symmetricds -d $DB_NAME -t -A -c \
        "SELECT base_price FROM products WHERE product_id = 'TEST-MY-001';")
    
    if [ "$PRICE" = "119.99" ]; then
        print_success "Precio actualizado correctamente en PostgreSQL"
    else
        print_error "Precio NO actualizado en PostgreSQL (precio: $PRICE)"
        return
    fi
    
    print_test "Verificando nombre actualizado..."
    NAME=$(docker exec $POSTGRES_CONTAINER psql -U symmetricds -d $DB_NAME -t -A -c \
        "SELECT product_name FROM products WHERE product_id = 'TEST-MY-001';")
    
    if [[ "$NAME" == *"UPDATED from MySQL"* ]]; then
        print_success "Nombre actualizado correctamente en PostgreSQL"
    else
        print_error "Nombre NO actualizado en PostgreSQL (nombre: $NAME)"
    fi
}

# ============================================
# Test 5: Replicación DELETE (PostgreSQL -> MySQL)
# ============================================

test_delete_postgres_to_mysql() {
    print_header "TEST 5: DELETE PostgreSQL → MySQL"
    ((TOTAL_TESTS+=2))
    
    # Eliminar en PostgreSQL
    print_test "Eliminando producto en PostgreSQL..."
    docker exec $POSTGRES_CONTAINER psql -U symmetricds -d $DB_NAME -c \
        "DELETE FROM products WHERE product_id = 'TEST-PG-001';"
    
    if [ $? -eq 0 ]; then
        print_success "Producto eliminado en PostgreSQL"
    else
        print_error "Error al eliminar en PostgreSQL"
        return
    fi
    
    # Esperar replicación
    wait_for_sync
    
    # Verificar eliminación en MySQL
    print_test "Verificando eliminación en MySQL..."
    RESULT=$(docker exec $MYSQL_CONTAINER mysql -u symmetricds -psymmetricds $DB_NAME -N -e \
        "SELECT COUNT(*) FROM products WHERE product_id = 'TEST-PG-001';")
    
    if [ "$RESULT" = "0" ]; then
        print_success "Producto eliminado correctamente en MySQL"
    else
        print_error "Producto NO eliminado en MySQL (encontrados: $RESULT)"
    fi
}

# ============================================
# Test 6: Replicación DELETE (MySQL -> PostgreSQL)
# ============================================

test_delete_mysql_to_postgres() {
    print_header "TEST 6: DELETE MySQL → PostgreSQL"
    ((TOTAL_TESTS+=2))
    
    # Eliminar en MySQL
    print_test "Eliminando producto en MySQL..."
    docker exec $MYSQL_CONTAINER mysql -u symmetricds -psymmetricds $DB_NAME -e \
        "DELETE FROM products WHERE product_id = 'TEST-MY-001';"
    
    if [ $? -eq 0 ]; then
        print_success "Producto eliminado en MySQL"
    else
        print_error "Error al eliminar en MySQL"
        return
    fi
    
    # Esperar replicación
    wait_for_sync
    
    # Verificar eliminación en PostgreSQL
    print_test "Verificando eliminación en PostgreSQL..."
    RESULT=$(docker exec $POSTGRES_CONTAINER psql -U symmetricds -d $DB_NAME -t -A -c \
        "SELECT COUNT(*) FROM products WHERE product_id = 'TEST-MY-001';")
    
    if [ "$RESULT" = "0" ]; then
        print_success "Producto eliminado correctamente en PostgreSQL"
    else
        print_error "Producto NO eliminado en PostgreSQL (encontrados: $RESULT)"
    fi
}

# ============================================
# Test 7: Replicación de múltiples tablas
# ============================================

test_multiple_tables() {
    print_header "TEST 7: REPLICACIÓN DE MÚLTIPLES TABLAS"
    ((TOTAL_TESTS+=8))
    
    # Test Inventory
    print_test "Insertando inventario en PostgreSQL..."
    docker exec $POSTGRES_CONTAINER psql -U symmetricds -d $DB_NAME -c \
        "INSERT INTO inventory (inventory_id, product_id, region, quantity, warehouse_code) 
         VALUES ('TEST-INV-001', 'PROD-USA-001', 'AMERICA', 500, 'TEST-WH');" &> /dev/null
    
    wait_for_sync
    
    RESULT=$(docker exec $MYSQL_CONTAINER mysql -u symmetricds -psymmetricds $DB_NAME -N -e \
        "SELECT COUNT(*) FROM inventory WHERE inventory_id = 'TEST-INV-001';")
    
    if [ "$RESULT" = "1" ]; then
        print_success "Inventory replicado (PostgreSQL → MySQL)"
    else
        print_error "Inventory NO replicado (PostgreSQL → MySQL)"
    fi
    
    # Test Customer
    print_test "Insertando cliente en MySQL..."
    docker exec $MYSQL_CONTAINER mysql -u symmetricds -psymmetricds $DB_NAME -e \
        "INSERT INTO customers (customer_id, email, full_name, country, is_premium) 
         VALUES ('TEST-CUST-001', 'test@email.com', 'Test Customer', 'Spain', 1);" &> /dev/null
    
    wait_for_sync
    
    RESULT=$(docker exec $POSTGRES_CONTAINER psql -U symmetricds -d $DB_NAME -t -A -c \
        "SELECT COUNT(*) FROM customers WHERE customer_id = 'TEST-CUST-001';")
    
    if [ "$RESULT" = "1" ]; then
        print_success "Customer replicado (MySQL → PostgreSQL)"
    else
        print_error "Customer NO replicado (MySQL → PostgreSQL)"
    fi
    
    # Test Promotion
    print_test "Insertando promoción en PostgreSQL..."
    docker exec $POSTGRES_CONTAINER psql -U symmetricds -d $DB_NAME -c \
        "INSERT INTO promotions (promotion_id, promotion_name, discount_percentage, start_date, end_date, applicable_regions) 
         VALUES ('TEST-PROMO-001', 'Test Promotion', 20.00, '2026-01-01', '2026-12-31', 'GLOBAL');" &> /dev/null
    
    wait_for_sync
    
    RESULT=$(docker exec $MYSQL_CONTAINER mysql -u symmetricds -psymmetricds $DB_NAME -N -e \
        "SELECT COUNT(*) FROM promotions WHERE promotion_id = 'TEST-PROMO-001';")
    
    if [ "$RESULT" = "1" ]; then
        print_success "Promotion replicado (PostgreSQL → MySQL)"
    else
        print_error "Promotion NO replicado (PostgreSQL → MySQL)"
    fi
    
    # Limpiar datos de prueba
    print_test "Limpiando datos de prueba..."
    docker exec $POSTGRES_CONTAINER psql -U symmetricds -d $DB_NAME -c \
        "DELETE FROM inventory WHERE inventory_id = 'TEST-INV-001';" &> /dev/null
    docker exec $MYSQL_CONTAINER mysql -u symmetricds -psymmetricds $DB_NAME -e \
        "DELETE FROM customers WHERE customer_id = 'TEST-CUST-001';" &> /dev/null
    docker exec $POSTGRES_CONTAINER psql -U symmetricds -d $DB_NAME -c \
        "DELETE FROM promotions WHERE promotion_id = 'TEST-PROMO-001';" &> /dev/null
    
    wait_for_sync
    
    # Verificar limpieza
    INV_CLEAN=$(docker exec $MYSQL_CONTAINER mysql -u symmetricds -psymmetricds $DB_NAME -N -e \
        "SELECT COUNT(*) FROM inventory WHERE inventory_id = 'TEST-INV-001';")
    CUST_CLEAN=$(docker exec $POSTGRES_CONTAINER psql -U symmetricds -d $DB_NAME -t -A -c \
        "SELECT COUNT(*) FROM customers WHERE customer_id = 'TEST-CUST-001';")
    PROMO_CLEAN=$(docker exec $MYSQL_CONTAINER mysql -u symmetricds -psymmetricds $DB_NAME -N -e \
        "SELECT COUNT(*) FROM promotions WHERE promotion_id = 'TEST-PROMO-001';")
    
    if [ "$INV_CLEAN" = "0" ]; then
        print_success "DELETE inventory replicado correctamente"
    else
        print_error "DELETE inventory NO replicado"
    fi
    
    if [ "$CUST_CLEAN" = "0" ]; then
        print_success "DELETE customer replicado correctamente"
    else
        print_error "DELETE customer NO replicado"
    fi
    
    if [ "$PROMO_CLEAN" = "0" ]; then
        print_success "DELETE promotion replicado correctamente"
    else
        print_error "DELETE promotion NO replicado"
    fi
}

# ============================================
# Resumen Final
# ============================================

print_summary() {
    print_header "RESUMEN DE VALIDACIÓN"
    
    echo -e "${BLUE}Total de pruebas: $TOTAL_TESTS${NC}"
    echo -e "${GREEN}Pruebas exitosas: $TESTS_PASSED${NC}"
    echo -e "${RED}Pruebas fallidas: $TESTS_FAILED${NC}"
    
    PERCENTAGE=$((TESTS_PASSED * 100 / TOTAL_TESTS))
    echo -e "${BLUE}Porcentaje de éxito: $PERCENTAGE%${NC}"
    
    echo ""
    
    if [ $TESTS_FAILED -eq 0 ]; then
        echo -e "${GREEN}============================================${NC}"
        echo -e "${GREEN}  ¡FELICIDADES! TODAS LAS PRUEBAS PASARON${NC}"
        echo -e "${GREEN}============================================${NC}"
        echo -e "${GREEN}La replicación bidireccional funciona correctamente${NC}"
        echo -e "${GREEN}Calificación: 100/100${NC}"
        return 0
    else
        echo -e "${RED}============================================${NC}"
        echo -e "${RED}  ALGUNAS PRUEBAS FALLARON${NC}"
        echo -e "${RED}============================================${NC}"
        echo -e "${YELLOW}Revisa los logs de SymmetricDS:${NC}"
        echo -e "${YELLOW}  docker logs $SYMMETRICDS_AMERICA${NC}"
        echo -e "${YELLOW}  docker logs $SYMMETRICDS_EUROPE${NC}"
        echo ""
        echo -e "${YELLOW}Calificación máxima posible: 50/100${NC}"
        return 1
    fi
}

# ============================================
# Ejecución Principal
# ============================================

main() {
    clear
    print_header "VALIDACIÓN AUTOMÁTICA - EXAMEN ABDD"
    echo -e "${BLUE}Sistema de E-commerce con Replicación Bidireccional${NC}"
    echo ""
    
    validate_prerequisites
    validate_db_connectivity
    validate_symmetricds
    
    echo ""
    print_info "Iniciando pruebas de replicación..."
    echo ""
    
    test_insert_postgres_to_mysql
    test_insert_mysql_to_postgres
    test_update_postgres_to_mysql
    test_update_mysql_to_postgres
    test_delete_postgres_to_mysql
    test_delete_mysql_to_postgres
    test_multiple_tables
    
    echo ""
    print_summary
}

# Ejecutar
main
exit $?
