# GlobalShop - Sistema de Replicación de Datos Distribuido

## Estudiante
- **Nombre:** Robert Alejandro Garcia Reyes
- **Cédula:** 1724724461
- **Fecha:** 30/01/2026


## Descripción del Proyecto

Este proyecto implementa un sistema de replicación de datos bidireccional utilizando **SymmetricDS**. El objetivo es mantener sincronizados los datos entre dos regiones geográficas:

- **América**: Base de datos PostgreSQL con catálogo de productos, inventario, clientes y promociones
- **Europa**: Base de datos MySQL con la misma estructura de datos para independencia regional

## Arquitectura General

El sistema está orquestado con **Docker Compose** y consta de los siguientes componentes:

### Servidores de Base de Datos

1. **postgres-america** (Puerto 5432)
   - Motor: PostgreSQL 17
   - Almacena datos de la región América
   - Base de datos: `globalshop`

2. **mysql-europe** (Puerto 3306)
   - Motor: MySQL 8.0
   - Almacena datos de la región Europa
   - Base de datos: `globalshop`

### Motores de Replicación SymmetricDS

3. **symmetricds-america** (Puerto 31415)
   - Nodo maestro/coordinador
   - Conecta con PostgreSQL
   - Recibe y procesa cambios de Europa

4. **symmetricds-europe** (Puerto 31416)
   - Nodo esclavo/registrado
   - Conecta con MySQL
   - Se registra automáticamente con el nodo de América
   - Sincroniza cambios de forma bidireccional

## Estructura de Datos

### Tablas Principales

La estructura de datos es idéntica en ambas bases de datos:

- **products**: Catálogo global de productos con categorías y precios
- **inventory**: Control de existencias por región y almacén
- **customers**: Base de clientes globalizada con datos de país y estado premium
- **promotions**: Promociones aplicables por región con fechas y descuentos

## Cómo Funciona la Replicación

La replicación se realiza a través de **triggers y tablas de control** en cada base de datos:

1. Cuando se modifica un registro en la tabla `products`, `inventory`, `customers` o `promotions` en América
2. SymmetricDS detecta el cambio a través de su mecanismo de captura
3. El cambio se empuja (push) hacia Europa
4. SymmetricDS en Europa aplica el cambio en MySQL
5. El mismo proceso ocurre en sentido inverso para cambios en Europa

## Evidencia de Funcionamiento

En la carpeta [replication-proofs/](replication-proofs/) se incluyen capturas de pantalla que demuestran:

### Capturas Incluidas

Las siguientes capturas muestran evidencia de la replicación exitosa:

1. **Estado de Conexión**
   - Muestra que ambos motores SymmetricDS están corriendo y conectados
   - Verificación de que el nodo Europa se registró correctamente en América

2. **Datos en PostgreSQL (América)**
   - Consultas ejecutadas en la base de datos de América
   - Productos, inventario, clientes y promociones visibles
   - Timestamps de creación y actualización

3. **Datos en MySQL (Europa)**
   - Mismos registros replicados en la base de datos MySQL
   - Confirmación de que los datos se sincronizaron correctamente
   - Integridad de datos entre ambas regiones

4. **Cambios Replicados**
   - Inserciones nuevas apareciendo en ambas bases de datos
   - Actualizaciones propagándose automáticamente
   - Logs de sincronización mostrando transferencias exitosas

## Configuración Clave

### Variables de Conexión

Las configuraciones en `symmetric.properties` especifican:

- **América**: Conector PostgreSQL con auto-registro habilitado
- **Europa**: Conector MySQL con URL de registro hacia América
- Puertos HTTP diferenciados para evitar conflictos
- Credenciales de base de datos consistentes

### Triggers y Control

Se incluyen triggers automáticos en ambas bases para:
- Actualizar campos `updated_at` automáticamente
- Registrar cambios en tablas de control de SymmetricDS
- Garantizar consistencia transaccional

## Verificación de Replicación

Para verificar que la replicación está funcionando:

```sql
-- En PostgreSQL (América)
SELECT * FROM products;
SELECT * FROM inventory;

-- En MySQL (Europa)
SELECT * FROM products;
SELECT * FROM inventory;

-- Comparar que los datos sean idénticos

Tecnologías Utilizadas

''' SymmetricDS 3.16: Motor de replicación de datos '''

PostgreSQL 17: Base de datos relacional (América)

MySQL 8.0: Base de datos relacional (Europa)

Docker Compose: Orquestación de contenedores

SQL: Scripts de inicialización de esquemas

'''Conclusión'''

Este proyecto demuestra la viabilidad de mantener múltiples bases de datos distribuidas geográficamente con sincronización automática en tiempo real, permitiendo que cada región sea independiente pero con datos globalmente consistentes.