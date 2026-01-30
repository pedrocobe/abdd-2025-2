# ============================================
# SymmetricDS Engine Configuration - EUROPA
# ============================================
#
# INSTRUCCIONES PARA EL ESTUDIANTE:
# Este archivo es similar al de América pero para el nodo Europa (MySQL).
# 
# IMPORTANTE: En una configuración multi-master bidireccional,
# la configuración de triggers, routers y canales típicamente
# se define SOLO en el nodo raíz (América) y se propaga automáticamente
# a los nodos secundarios.
#
# Sin embargo, si deseas configurar algo específico para Europa,
# puedes hacerlo aquí.
#
# ============================================

# --------------------------------------------
# Opción 1: Configuración Mínima (RECOMENDADO)
# --------------------------------------------
# En la mayoría de los casos, este archivo puede estar vacío o tener
# configuración mínima, ya que el nodo Europa heredará la configuración
# del nodo América a través del proceso de registro.

# Si dejas este archivo vacío o solo con comentarios, SymmetricDS
# utilizará la configuración propagada desde América.


# --------------------------------------------
# Opción 2: Configuración Específica (OPCIONAL)
# --------------------------------------------
# Si necesitas configuración específica para Europa (ej: filtros,
# transformaciones específicas para MySQL), puedes agregarla aquí.

# Ejemplo de transformación específica para MySQL:
# Si necesitas transformar BOOLEAN (PostgreSQL) a TINYINT (MySQL)
# SymmetricDS lo hace automáticamente, pero puedes personalizar:

# insert into sym_transform_table (
#   transform_id, source_node_group_id, target_node_group_id,
#   transform_point, source_table_name, target_table_name,
#   update_action, delete_action
# ) values (
#   'products_transform', 'america-store', 'europe-store',
#   'LOAD', 'products', 'products',
#   'UPDATE_COL', 'DEL_ROW'
# );


# --------------------------------------------
# Configuración de Triggers para MySQL
# --------------------------------------------
# Si quieres definir triggers específicos para MySQL
# (aunque no es necesario en configuración estándar)

# Los triggers para capturar cambios en MySQL se crearán automáticamente
# basándose en la configuración del nodo América.


# ============================================
# GUÍA PARA EL ESTUDIANTE:
#
# Para una replicación bidireccional estándar:
# 1. Define TODA la configuración en america.properties (nodo raíz)
# 2. Deja europe.properties vacío o con configuración mínima
# 3. Europa heredará automáticamente la configuración al registrarse
#
# Esto simplifica la gestión y evita conflictos de configuración.
#
# RECURSOS:
# - Ver docs/SYMMETRICDS_GUIDE.md para más detalles
# - Documentación oficial: https://www.symmetricds.org/docs
#
# ============================================

-- Este archivo puede estar vacío para configuración estándar
-- La configuración se propagará desde el nodo América

-- Si necesitas configuración específica, agrégala aquí:

