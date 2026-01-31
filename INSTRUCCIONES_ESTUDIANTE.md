# 📝 INSTRUCCIONES PARA EL ESTUDIANTE

## ¿Qué debo hacer?

Este examen evalúa tu capacidad para configurar una arquitectura de replicación bidireccional entre bases de datos heterogéneas usando Docker y SymmetricDS.

## 🎯 Tareas a Completar

### 1. Crear `docker-compose.yml` (40 puntos)

**Debes crear desde CERO** un archivo llamado `docker-compose.yml` en la raíz del proyecto que incluya:

#### Servicios requeridos:
- ✅ **postgres-america**: Base de datos PostgreSQL
  - Imagen: `postgres:15`
  - Puerto: `5432`
  - Variables de entorno para BD `globalshop`
  - Montar: `./init-db/postgres:/docker-entrypoint-initdb.d`

- ✅ **mysql-europe**: Base de datos MySQL
  - Imagen: `mysql:8.0`
  - Puerto: `3306`
  - Variables de entorno para BD `globalshop`
  - Montar: `./init-db/mysql:/docker-entrypoint-initdb.d`

- ✅ **symmetricds-america**: Nodo SymmetricDS para PostgreSQL
  - Imagen: `jumpmind/symmetricds:3.16`
  - Puerto: `31415`
  - Montar: `./symmetricds/america:/opt/symmetric-ds/engines/america`
  - Debe depender de `postgres-america`

- ✅ **symmetricds-europe**: Nodo SymmetricDS para MySQL
  - Imagen: `jumpmind/symmetricds:3.16`
  - Puerto: `31416`
  - Montar: `./symmetricds/europe:/opt/symmetric-ds/engines/europe`
  - Debe depender de `mysql-europe` y `symmetricds-america`

#### Otros elementos:
- ✅ Una red compartida (ej: `globalshop-network`)
- ✅ Volúmenes para persistencia de datos

**Recursos**: Consulta `docs/SYMMETRICDS_GUIDE.md` para ejemplos.

---

### 2. Configurar `symmetricds/america/symmetric.properties` (15 puntos)

**Debes completar** el archivo `symmetricds/america/symmetric.properties` con:

#### Campos obligatorios:
```properties
# Identificación
engine.name=              # Ejemplo: america
group.id=                 # Ejemplo: america-store
external.id=              # Ejemplo: 001

# Conexión PostgreSQL
db.driver=                # org.postgresql.Driver
db.url=                   # jdbc:postgresql://postgres-america:5432/globalshop
db.user=                  # symmetricds
db.password=              # symmetricds

# Configuración HTTP
http.enable=true
http.port=                # 31415

# Este es el nodo RAÍZ
registration.url=         # Dejar VACÍO o comentado

# Habilitar jobs
start.push.job=true
start.pull.job=true
start.route.job=true
start.heartbeat.job=true

# Auto configuración
auto.register=true
auto.reload=true
```

**⚠️ IMPORTANTE**: Este nodo NO debe tener `registration.url` porque es el nodo raíz.

---

### 3. Configurar `symmetricds/america/engines/america.properties` (15 puntos)

**Debes escribir SQL** en el archivo `symmetricds/america/engines/america.properties` que configure:

#### SQL requerido:

```sql
-- 1. Definir grupos de nodos (2 grupos)
insert into sym_node_group (node_group_id, description) 
values ('america-store', 'America region');

insert into sym_node_group (node_group_id, description) 
values ('europe-store', 'Europe region');

-- 2. Enlaces bidireccionales
insert into sym_node_group_link 
  (source_node_group_id, target_node_group_id, data_event_action) 
values ('america-store', 'europe-store', 'W');

insert into sym_node_group_link 
  (source_node_group_id, target_node_group_id, data_event_action) 
values ('europe-store', 'america-store', 'W');

-- 3. Definir canales (4 canales, uno por tabla)
-- products_channel, inventory_channel, customers_channel, promotions_channel

-- 4. Definir triggers (4 triggers, uno por tabla)
-- products_trigger, inventory_trigger, customers_trigger, promotions_trigger

-- 5. Definir routers (2 routers bidireccionales)
-- america_to_europe, europe_to_america

-- 6. Vincular triggers con routers (sym_trigger_router)
-- Cada trigger debe estar vinculado a ambos routers
```

**Recursos**: Consulta `docs/SYMMETRICDS_GUIDE.md` sección "Ejemplos de Configuración" para SQL completo.

---

### 4. Configurar `symmetricds/europe/symmetric.properties` (20 puntos)

**Debes completar** el archivo `symmetricds/europe/symmetric.properties` con:

#### Campos obligatorios:
```properties
# Identificación
engine.name=              # Ejemplo: europe
group.id=                 # europe-store (debe coincidir con el definido en américa)
external.id=              # Ejemplo: 002

# Conexión MySQL
db.driver=                # com.mysql.cj.jdbc.Driver
db.url=                   # jdbc:mysql://mysql-europe:3306/globalshop?allowPublicKeyRetrieval=true&useSSL=false
db.user=                  # symmetricds
db.password=              # symmetricds

# Configuración HTTP
http.enable=true
http.port=                # 31416 (DIFERENTE a américa)

# REGISTRARSE contra América
registration.url=         # http://symmetricds-america:31415/sync/america

# Habilitar jobs
start.push.job=true
start.pull.job=true
start.route.job=true
start.heartbeat.job=true

# Auto configuración
auto.register=true
auto.reload=true
```

**⚠️ CRÍTICO**: El `registration.url` DEBE apuntar al nodo América.

---

### 5. Configurar `symmetricds/europe/engines/europe.properties` (10 puntos)

Este archivo puede estar **vacío** o contener solo comentarios, ya que la configuración se hereda del nodo América.

Opcionalmente puedes agregar comentarios explicando esto:
```sql
-- La configuración se propaga desde el nodo América
-- Este archivo puede estar vacío
```

---

## 🚀 Cómo Probar tu Solución

### 1. Levantar la arquitectura
```bash
docker-compose up -d
```

### 2. Verificar que todo esté corriendo
```bash
docker-compose ps
# Debes ver 4 contenedores en estado "Up"
```

### 3. Ver logs (si hay problemas)
```bash
docker-compose logs -f
# O específicos:
docker-compose logs symmetricds-america
docker-compose logs symmetricds-europe
```

### 4. Esperar a que todo inicie
Espera **al menos 2 minutos** para que:
- Las bases de datos se inicialicen
- SymmetricDS cree sus tablas
- El nodo Europa se registre en América

### 5. Probar manualmente (opcional)
```bash
# Insertar en PostgreSQL
docker exec postgres-america psql -U symmetricds -d globalshop -c "
INSERT INTO products VALUES ('TEST-001', 'Test Product', 'Test', 99.99, 'Test', true, NOW(), NOW());
"

# Esperar 10 segundos
sleep 10

# Verificar en MySQL
docker exec mysql-europe mysql -u symmetricds -psymmetricds globalshop -e "
SELECT * FROM products WHERE product_id='TEST-001';
"
```

Si ves el producto en MySQL, ¡funciona! 🎉

---

## 📤 Qué Entregar

Debes entregar un archivo ZIP con el nombre `apellido_nombre_examen_abdd.zip` que contenga:

1. ✅ `docker-compose.yml`
2. ✅ `symmetricds/america/symmetric.properties`
3. ✅ `symmetricds/america/engines/america.properties`
4. ✅ `symmetricds/europe/symmetric.properties`
5. ✅ `symmetricds/europe/engines/europe.properties`
6. ✅ Captura de pantalla mostrando:
   - Los 4 contenedores corriendo (`docker-compose ps`)
   - Una prueba exitosa de replicación

---

## 📊 Cómo se Califica

Tu examen será calificado **automáticamente** con un script que verifica:

### Sección 1: Docker Compose (40 puntos)
- Archivo existe y es válido
- 4 servicios definidos correctamente
- Red configurada
- Volúmenes montados
- Puertos correctos

### Sección 2: Configuración América (30 puntos)
- `symmetric.properties` completo
- Conexión a PostgreSQL correcta
- `america.properties` con SQL correcto
- Grupos, canales, triggers y routers definidos

### Sección 3: Configuración Europa (30 puntos)
- `symmetric.properties` completo
- Conexión a MySQL correcta
- `registration.url` apunta a América
- Puerto correcto y diferente

### Sección 4: BONUS - Funcionalidad (20 puntos extra)
Si tu solución funciona correctamente:
- Contenedores inician sin errores
- Bases de datos aceptan conexiones
- SymmetricDS crea sus tablas
- Nodo Europa se registra en América

**Nota máxima**: 100/100 (base 100 + bonus puede dar hasta 120)

---

## 📚 Recursos Disponibles

### Documentación Incluida
- `README.md` - Enunciado completo del problema
- `docs/SYMMETRICDS_GUIDE.md` - **LEER PRIMERO** - Guía completa con ejemplos
- `docs/TROUBLESHOOTING.md` - Solución de problemas comunes

### Documentación Externa
- [SymmetricDS Documentation](https://www.symmetricds.org/docs)
- [Docker Compose Reference](https://docs.docker.com/compose/)

---

## ⏰ Tiempo Estimado

- **Lectura de documentación**: 30 minutos
- **Configuración de docker-compose**: 30 minutos
- **Configuración de SymmetricDS**: 60 minutos
- **Pruebas y debugging**: 30 minutos
- **TOTAL**: 2.5 - 3 horas

---

## ❓ Preguntas Frecuentes

### ¿Puedo usar internet y documentación?
**Sí**, este es un examen de libro abierto. Puedes consultar cualquier recurso.

### ¿Debo crear las bases de datos?
**No**, los scripts de inicialización ya están creados en `init-db/`.

### ¿Debo crear las tablas?
**No**, las tablas ya se crean automáticamente al iniciar las bases de datos.

### ¿Qué tablas debo replicar?
Las 4 tablas: `products`, `inventory`, `customers`, `promotions`.

### ¿Cómo sé si está funcionando?
Ejecuta pruebas manuales o espera a que el profesor ejecute el script de validación.

### ¿Puedo pedir ayuda?
Puedes preguntar sobre el **enunciado** o **errores técnicos** (Docker, conexiones), pero no sobre la **solución** directa.

### Mi contenedor se reinicia constantemente, ¿qué hago?
1. Ver logs: `docker-compose logs [servicio]`
2. Buscar el error específico
3. Consultar `docs/TROUBLESHOOTING.md`
4. Verificar sintaxis de archivos de configuración

### ¿Qué significa "W" en data_event_action?
- **W** = Wait/Write - Espera y sincroniza los datos
- **P** = Push - Solo empuja datos
- **I** = Ignore - Ignora los datos

### ¿Debo configurar transformaciones de datos?
**No**, SymmetricDS maneja automáticamente las diferencias entre PostgreSQL y MySQL (ej: BOOLEAN vs TINYINT).

---

## ✅ Checklist Final

Antes de entregar, verifica:

- [ ] `docker-compose.yml` existe y tiene los 4 servicios
- [ ] `symmetricds/america/symmetric.properties` está completo
- [ ] `symmetricds/america/engines/america.properties` tiene SQL
- [ ] `symmetricds/europe/symmetric.properties` está completo
- [ ] `registration.url` en Europa apunta a América
- [ ] Puertos son correctos (5432, 3306, 31415, 31416)
- [ ] Los 4 contenedores inician sin errores
- [ ] Has probado al menos una inserción manual

---

## 🎯 Consejo Final

**Lee primero `docs/SYMMETRICDS_GUIDE.md` completo** antes de empezar a configurar. Contiene todos los ejemplos que necesitas.

¡Buena suerte! 🚀

---

**¿Dudas?** Consulta primero `docs/TROUBLESHOOTING.md`
