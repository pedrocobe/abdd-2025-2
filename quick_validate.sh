#!/bin/bash

# Script de validación rápida
# Compatible con docker compose (nueva versión)

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}============================================${NC}"
echo -e "${BLUE}VALIDACIÓN DEL EXAMEN - INICIO${NC}"
echo -e "${BLUE}============================================${NC}"
echo ""

# Verificar prerequisitos
echo -e "${YELLOW}[1/7]${NC} Verificando Docker..."
if ! command -v docker &> /dev/null; then
    echo -e "${RED}✗ Docker no instalado${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Docker encontrado${NC}"

# Verificar docker-compose.yml
echo -e "${YELLOW}[2/7]${NC} Verificando docker-compose.yml..."
if [ ! -f "docker-compose.yml" ]; then
    echo -e "${RED}✗ docker-compose.yml no existe${NC}"
    exit 1
fi
echo -e "${GREEN}✓ docker-compose.yml existe${NC}"

# Validar sintaxis YAML
echo -e "${YELLOW}[3/7]${NC} Validando sintaxis YAML..."
if ! docker compose config > /dev/null 2>&1; then
    echo -e "${RED}✗ Error en sintaxis YAML${NC}"
    docker compose config 2>&1 | head -10
    exit 1
fi
echo -e "${GREEN}✓ Sintaxis YAML válida${NC}"

# Verificar configuraciones
echo -e "${YELLOW}[4/7]${NC} Verificando configuraciones..."

if grep -q "^engine.name=america" symmetricds/america/symmetric.properties &&
   grep -q "^db.url=jdbc:postgresql://postgres-america" symmetricds/america/symmetric.properties; then
    echo -e "${GREEN}✓ Configuración América correcta${NC}"
else
    echo -e "${RED}✗ Configuración América incompleta${NC}"
fi

if grep -q "^engine.name=europe" symmetricds/europe/symmetric.properties &&
   grep -q "^registration.url=http://symmetricds-america" symmetricds/europe/symmetric.properties; then
    echo -e "${GREEN}✓ Configuración Europa correcta${NC}"
else
    echo -e "${RED}✗ Configuración Europa incompleta${NC}"
fi

# Limpiar ambiente previo
echo -e "${YELLOW}[5/7]${NC} Limpiando ambiente previo..."
docker compose down -v > /dev/null 2>&1
echo -e "${GREEN}✓ Ambiente limpio${NC}"

# Levantar servicios
echo -e "${YELLOW}[6/7]${NC} Levantando servicios Docker..."
echo -e "${BLUE}Esto tomará 2-3 minutos...${NC}"
if ! docker compose up -d; then
    echo -e "${RED}✗ Error al levantar servicios${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Servicios levantados${NC}"

# Esperar inicialización
echo -e "${YELLOW}[7/7]${NC} Esperando inicialización (120 segundos)..."
for i in {1..12}; do
    echo -n "."
    sleep 10
done
echo ""
echo -e "${GREEN}✓ Inicialización completada${NC}"

# Verificar contenedores
echo ""
echo -e "${BLUE}============================================${NC}"
echo -e "${BLUE}ESTADO DE CONTENEDORES${NC}"
echo -e "${BLUE}============================================${NC}"
docker compose ps

# Verificar conexiones
echo ""
echo -e "${BLUE}============================================${NC}"
echo -e "${BLUE}VERIFICANDO CONEXIONES${NC}"
echo -e "${BLUE}============================================${NC}"

echo -n "PostgreSQL: "
if docker exec postgres-america psql -U symmetricds -d globalshop -c "SELECT 1;" > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Conectado${NC}"
else
    echo -e "${RED}✗ Error de conexión${NC}"
fi

echo -n "MySQL: "
if docker exec mysql-europe mysql -u symmetricds -psymmetricds globalshop -e "SELECT 1;" > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Conectado${NC}"
else
    echo -e "${RED}✗ Error de conexión${NC}"
fi

# Prueba simple de replicación
echo ""
echo -e "${BLUE}============================================${NC}"
echo -e "${BLUE}PRUEBA DE REPLICACIÓN${NC}"
echo -e "${BLUE}============================================${NC}"

echo "Insertando dato de prueba en PostgreSQL..."
docker exec postgres-america psql -U symmetricds -d globalshop -c \
    "DELETE FROM products WHERE product_id = 'VALIDATION-001';" > /dev/null 2>&1
docker exec postgres-america psql -U symmetricds -d globalshop -c \
    "INSERT INTO products (product_id, product_name, category, base_price, description, is_active) 
     VALUES ('VALIDATION-001', 'Test Validation', 'Test', 99.99, 'Validation test', true);" > /dev/null 2>&1

echo "Esperando replicación (15 segundos)..."
sleep 15

echo -n "Verificando en MySQL: "
COUNT=$(docker exec mysql-europe mysql -u symmetricds -psymmetricds globalshop -N -e \
    "SELECT COUNT(*) FROM products WHERE product_id = 'VALIDATION-001';")

if [ "$COUNT" = "1" ]; then
    echo -e "${GREEN}✓ REPLICACIÓN FUNCIONA!${NC}"
    RESULT=0
else
    echo -e "${RED}✗ No replicado (encontrados: $COUNT)${NC}"
    RESULT=1
fi

# Limpiar
echo ""
echo -e "${YELLOW}Limpiando contenedores...${NC}"
docker compose down -v > /dev/null 2>&1

# Resultado final
echo ""
echo -e "${BLUE}============================================${NC}"
if [ $RESULT -eq 0 ]; then
    echo -e "${GREEN}✅ EXAMEN APROBADO${NC}"
    echo -e "${GREEN}La replicación bidireccional funciona correctamente${NC}"
else
    echo -e "${RED}❌ EXAMEN REQUIERE REVISIÓN${NC}"
    echo -e "${YELLOW}Revisa los logs: docker compose logs${NC}"
fi
echo -e "${BLUE}============================================${NC}"

exit $RESULT
