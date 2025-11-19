# Guía de Ejecución: Taller de Índices y Restricciones

Esta guía te ayudará a ejecutar el taller de índices y restricciones paso a paso usando Docker y Oracle XE.

## Requisitos Previos

- Docker Desktop instalado y ejecutándose
- Docker Compose instalado
- Al menos 8 GB de RAM disponibles
- Terminal o línea de comandos

## Paso 1: Levantar el Contenedor Oracle

Abre una terminal en la raíz del proyecto y ejecuta:

```bash
cd /Users/conbjtrujillo/Projects/Personal/Bases_de_datos_avanzada_1
docker compose up -d
```

Espera a que el contenedor esté completamente iniciado (esto puede tomar 2-5 minutos). Verifica el estado:

```bash
docker compose ps
```

El contenedor debe mostrar estado `healthy`. Si no está listo, espera unos minutos más.

## Paso 2: Preparar el Esquema HR

### Opción A: Desde el Host (Recomendado)

Copia los scripts al contenedor y ejecuta la preparación:

```bash
# Copiar scripts al contenedor
docker cp ./scripts oracle-xml-lab:/opt/oracle/scripts

# Entrar al contenedor
docker compose exec oracle-xe bash

# Dentro del contenedor, preparar el esquema HR
sqlplus hr/hr@XEPDB1 <<EOF
@/opt/oracle/scripts/00_seed_hr_sample.sql
EXIT;
EOF
```

### Opción B: Desde SQL Developer (Alternativa)

Si prefieres usar SQL Developer:

1. Abre SQL Developer
2. Crea una nueva conexión:
   - **Nombre**: HR
   - **Usuario**: hr
   - **Contraseña**: hr
   - **Tipo**: Básico
   - **Hostname**: localhost
   - **Puerto**: 1521
   - **SID**: XEPDB1
3. Conecta y ejecuta el script `scripts/00_seed_hr_sample.sql`

## Paso 3: Verificar que las Tablas Existen

Dentro del contenedor o desde SQL Developer, ejecuta:

```sql
-- Verificar tablas
SELECT table_name FROM user_tables WHERE table_name IN ('EMPLOYEES', 'DEPARTMENTS', 'LOCATIONS');

-- Verificar datos
SELECT COUNT(*) FROM employees;
SELECT COUNT(*) FROM departments;
```

Deberías ver:
- 3 empleados
- 2 departamentos
- 2 ubicaciones

## Paso 4: Ejecutar los Scripts del Taller

### ⚠️ IMPORTANTE: Diferencia entre ejecutar desde bash y desde SQL*Plus

**Si estás en bash (fuera de SQL*Plus):**
```bash
sqlplus hr/hr@XEPDB1 @01_consultar_indices.sql
```

**Si ya estás dentro de SQL*Plus (prompt SQL>):**
```sql
@01_consultar_indices.sql
-- O con la ruta completa:
@/opt/oracle/scripts/taller_indices/01_consultar_indices.sql
```

### Opción A: Desde dentro de SQL*Plus (Ya conectado)

Si ya estás conectado a SQL*Plus como usuario HR:

```sql
-- Cambiar al directorio de los scripts (si es necesario)
-- Primero verifica dónde estás:
HOST pwd

-- Si necesitas cambiar de directorio, sal de SQL*Plus y vuelve a entrar
-- O usa la ruta completa:

@/opt/oracle/scripts/taller_indices/01_consultar_indices.sql
@/opt/oracle/scripts/taller_indices/02_desactivar_restricciones.sql
@/opt/oracle/scripts/taller_indices/03_insertar_tuplas_invalidas.sql
@/opt/oracle/scripts/taller_indices/00_limpiar_datos_invalidos.sql
@/opt/oracle/scripts/taller_indices/04_reactivar_restricciones.sql
@/opt/oracle/scripts/taller_indices/05_crear_departments2.sql
@/opt/oracle/scripts/taller_indices/06_transacciones_y_rollback.sql
```

**Para salir de SQL*Plus y volver a bash:**
```sql
EXIT;
```

### Opción B: Ejecutar Scripts Individuales desde Bash

Desde dentro del contenedor (en bash, NO en SQL*Plus):

```bash
# Asegúrate de estar en el directorio correcto
cd /opt/oracle/scripts/taller_indices

# Ejecutar cada script en orden (esto abre SQL*Plus, ejecuta el script y sale)
sqlplus hr/hr@XEPDB1 @01_consultar_indices.sql
sqlplus hr/hr@XEPDB1 @02_desactivar_restricciones.sql
sqlplus hr/hr@XEPDB1 @03_insertar_tuplas_invalidas.sql
sqlplus hr/hr@XEPDB1 @00_limpiar_datos_invalidos.sql
sqlplus hr/hr@XEPDB1 @04_reactivar_restricciones.sql
sqlplus hr/hr@XEPDB1 @05_crear_departments2.sql
sqlplus hr/hr@XEPDB1 @06_transacciones_y_rollback.sql
```

Para el script de archivos Redo (requiere privilegios SYSDBA):

```bash
sqlplus / as sysdba @/opt/oracle/scripts/taller_indices/07_archivos_redo.sql
```

### Opción C: Ejecutar Script Maestro desde Bash

```bash
cd /opt/oracle/scripts/taller_indices
sqlplus hr/hr@XEPDB1 @MASTER.sql
```

### Opción D: Desde SQL Developer

1. Abre cada script en SQL Developer
2. Ejecuta cada uno en orden (F5 o botón "Run Script")
3. Toma capturas de pantalla de los resultados

## Paso 5: Seguir el Documento del Taller

Abre el archivo `docs/TALLER_INDICES_RESTRICCIONES.md` y sigue cada sección:

1. **Sección 1**: Iniciar sesión con usuario HR (ya hecho)
2. **Sección 2**: Consultar índices → Ejecuta `01_consultar_indices.sql`
3. **Sección 3**: Desactivar restricciones → Ejecuta `02_desactivar_restricciones.sql`
4. **Sección 4**: Insertar tuplas inválidas → Ejecuta `03_insertar_tuplas_invalidas.sql`
5. **Sección 5**: Reactivar restricciones → Ejecuta `00_limpiar_datos_invalidos.sql` primero, luego `04_reactivar_restricciones.sql`
6. **Sección 6-7**: Crear departments2 → Ejecuta `05_crear_departments2.sql`
7. **Sección 8-9**: Cerrar y reconectar → Cierra y vuelve a abrir la sesión, luego consulta departments2
8. **Sección 10**: Transacciones → Ejecuta `06_transacciones_y_rollback.sql`
9. **Sección 11**: Rollback → Ya incluido en el script anterior
10. **Sección 12**: Archivos Redo → Ejecuta `07_archivos_redo.sql` como SYSDBA

## Comandos Útiles

### Ver logs del contenedor
```bash
docker compose logs oracle-xe
```

### Entrar al contenedor
```bash
docker compose exec oracle-xe bash
```

### Ejecutar SQL directamente desde el host
```bash
docker compose exec oracle-xe sqlplus hr/hr@XEPDB1
```

### Detener el contenedor
```bash
docker compose down
```

### Detener y eliminar datos (limpieza completa)
```bash
docker compose down -v
```

## Solución de Problemas

### Error: "ORA-01017: invalid username/password"

El usuario HR puede no estar desbloqueado. Ejecuta:

```bash
docker compose exec oracle-xe sqlplus / as sysdba <<EOF
ALTER SESSION SET CONTAINER = XEPDB1;
ALTER USER hr IDENTIFIED BY hr ACCOUNT UNLOCK;
EXIT;
EOF
```

### Error: "ORA-00942: table or view does not exist"

Las tablas no existen. Ejecuta el script de semilla:

```bash
docker compose exec oracle-xe sqlplus hr/hr@XEPDB1 @/opt/oracle/scripts/00_seed_hr_sample.sql
```

### El contenedor no inicia

Verifica que Docker tenga suficientes recursos:
- Al menos 8 GB de RAM disponibles
- Espacio suficiente en disco

### No puedo conectarme desde SQL Developer

Verifica que:
- El puerto 1521 esté disponible
- El contenedor esté en estado `healthy`
- Estés usando el SID correcto: `XEPDB1`

## Estructura de Archivos en el Contenedor

Una vez dentro del contenedor, los scripts estarán en:

```
/opt/oracle/scripts/
├── 00_seed_hr_sample.sql
├── 01_register_xml_schema.sql
├── 02_generate_hr_xml.sql
├── 03_insert_xml_samples.sql
└── taller_indices/
    ├── 00_limpiar_datos_invalidos.sql
    ├── 01_consultar_indices.sql
    ├── 02_desactivar_restricciones.sql
    ├── 03_insertar_tuplas_invalidas.sql
    ├── 04_reactivar_restricciones.sql
    ├── 05_crear_departments2.sql
    ├── 06_transacciones_y_rollback.sql
    ├── 07_archivos_redo.sql
    └── MASTER.sql
```

## Próximos Pasos

1. ✅ Levantar el contenedor
2. ✅ Preparar el esquema HR
3. ✅ Ejecutar los scripts del taller
4. 📸 Tomar capturas de pantalla de cada paso
5. 📝 Completar la documentación con las capturas

¡Listo para comenzar el taller!

