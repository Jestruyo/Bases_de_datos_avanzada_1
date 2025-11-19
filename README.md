# Laboratorio 1 · Almacenamiento y validación de XML en Oracle

Este proyecto crea un entorno reproducible con Docker para desarrollar el laboratorio de **Bases de Datos Avanzadas I** enfocado en la recuperación, validación y almacenamiento de ficheros XML en Oracle.

## Requisitos previos

- Docker Desktop 4.x (o Docker Engine 20.10+)
- `docker compose` (plugin oficial)
- Al menos 8 GB de RAM libres para ejecutar Oracle XE
- Cliente SQL compatible (SQL\*Plus, SQLcl o SQL Developer)

## Puesta en marcha

1. Levanta los contenedores:

   ```bash
   docker compose up -d
   ```

2. Espera a que el servicio `oracle-xe` aparezca como `healthy`:

   ```bash
   docker compose ps
   ```

3. Abre una shell dentro del contenedor para trabajar con las herramientas preinstaladas (SQL\*Plus):

   ```bash
   docker compose exec oracle-xe bash
   ```

   Verás un prompt similar a `oracle@hostname:/opt/oracle>`. Desde ahí podrás ejecutar SQL\*Plus y manejar los scripts sin instalar nada en el host.

Los scripts de inicialización (`docker/oracle/init-sql/*.sql`) desbloquean el esquema `HR`, crean el usuario `hr_xml_lab` y conceden los privilegios necesarios para trabajar con XML DB. Si necesitas copiar archivos desde el host al contenedor, usa `docker cp` o monta un volumen adicional.

### Cargar datos de ejemplo en el esquema HR

Las imágenes recientes de Oracle XE no siempre incluyen las tablas de ejemplo. Si al conceder privilegios ves errores `ORA-00942`, siembra los datos mínimos ejecutando, dentro del contenedor, lo siguiente:

```bash
sqlplus hr/hr@XEPDB1 @scripts/00_seed_hr_sample.sql
```

Ese script crea `HR.LOCATIONS`, `HR.DEPARTMENTS` y `HR.EMPLOYEES` con un pequeño juego de datos suficiente para el laboratorio.

## Flujo recomendado para el laboratorio

1. **Registrar el esquema XML y preparar la tabla:**

   Dentro de la shell del contenedor:

   ```sql
   @scripts/01_register_xml_schema.sql
   ```

   Este script registra el esquema en XDB y crea la tabla `employee_department_xml` validada contra él.

2. **Generar el fichero XML de empleados y departamentos:**

   ```sql
   @scripts/02_generate_hr_xml.sql
   ```

   Se genera el fichero `docs/xml/employee_department_sample.xml` con una consulta que combina `HR.EMPLOYEES`, `HR.DEPARTMENTS` y `HR.LOCATIONS` mediante `XMLELEMENT`, `XMLFOREST`, `XMLAGG` y `XMLATTRIBUTES`.

3. **Validar el XML con una herramienta externa:**

   - Esquema: `docs/xml/employee_department.xsd`
   - Documento: `docs/xml/employee_department_sample.xml`
   - Herramientas sugeridas: [https://www.freeformatter.com/xml-validator-xsd.html](https://www.freeformatter.com/xml-validator-xsd.html) o [https://www.liquid-technologies.com/online-xml-validator](https://www.liquid-technologies.com/online-xml-validator)

4. **Insertar XML válido e intentar uno inválido:**

   ```sql
   @scripts/03_insert_xml_samples.sql
   ```

   Verás un mensaje de inserción exitosa y, a continuación, un error controlado que confirma que el segundo XML no cumple con el esquema. Si repites el script y quieres partir de cero, ejecuta `TRUNCATE TABLE employee_department_xml;`.

## Secuencia completa de comandos

### Preparación en el host

```bash
cd /Users/conbjtrujillo/Projects/Personal/Bases_de_datos_avanzada_1
docker compose up -d
docker compose exec oracle-xe bash -lc "mkdir -p /opt/oracle/lab"
docker cp ./scripts oracle-xml-lab:/opt/oracle/lab/
docker cp ./docs oracle-xml-lab:/opt/oracle/lab/
```

### Configuración inicial en el contenedor

```bash
docker compose exec oracle-xe bash
# dentro del contenedor
sqlplus / as sysdba <<'EOF'
ALTER SESSION SET CONTAINER = XEPDB1;
CREATE OR REPLACE DIRECTORY LAB_DOCS AS '/opt/oracle/lab/docs/xml';
GRANT READ, WRITE ON DIRECTORY LAB_DOCS TO hr_xml_lab;
GRANT READ, WRITE ON DIRECTORY LAB_DOCS TO hr;
EXIT;
EOF

sqlplus hr/hr@XEPDB1 @scripts/00_seed_hr_sample.sql
sqlplus hr_xml_lab/hr_xml_lab_pwd@XEPDB1 @01_register_xml_schema.sql
```

### Ejecución de los ejercicios

```bash
# Aún dentro del contenedor
sqlplus hr_xml_lab/hr_xml_lab_pwd@XEPDB1 @02_generate_hr_xml.sql
sqlplus hr_xml_lab/hr_xml_lab_pwd@XEPDB1 @03_insert_xml_samples.sql
exit  # para salir del contenedor
```

### Copia y validación del XML en el host

```bash
docker cp oracle-xml-lab:/opt/oracle/lab/docs/xml/employee_department_sample.xml ./docs/xml/
xmllint --noout --schema docs/xml/employee_department.xsd docs/xml/employee_department_sample.xml
```

### Limpieza (opcional)

```bash
docker compose down
# Si quieres borrar los datos persistidos
docker volume rm bases_de_datos_avanzada_1_oracle-data
```

   La primera inserción debe completarse correctamente y la segunda provocará un error controlado por incumplir el esquema.

## Taller: Índices y Restricciones en Oracle

Este proyecto también incluye un taller completo sobre índices y restricciones en Oracle utilizando el esquema HR.

### Ubicación de los Scripts

Los scripts del taller se encuentran en `scripts/taller_indices/`:

- `01_consultar_indices.sql`: Consulta índices en employees y departments
- `02_desactivar_restricciones.sql`: Desactiva restricciones de ambas tablas
- `03_insertar_tuplas_invalidas.sql`: Inserta tuplas que violan restricciones
- `00_limpiar_datos_invalidos.sql`: Limpia datos inválidos antes de reactivar restricciones
- `04_reactivar_restricciones.sql`: Reactiva las restricciones
- `05_crear_departments2.sql`: Crea departments2 e inserta tuplas
- `06_transacciones_y_rollback.sql`: Ejemplos de transacciones, COMMIT y ROLLBACK
- `07_archivos_redo.sql`: Consultas sobre archivos Redo Log
- `MASTER.sql`: Script maestro que ejecuta todos los pasos en secuencia

### Documentación

La documentación completa del taller está disponible en `docs/TALLER_INDICES_RESTRICCIONES.md` e incluye:

- Explicaciones detalladas de cada paso
- Código SQL ejecutado
- Análisis de resultados
- Respuestas a las preguntas del taller
- Ejemplos prácticos de transacciones y archivos Redo

### Ejecución del Taller

```bash
# Desde SQL*Plus como usuario HR
sqlplus hr/hr@XEPDB1 @scripts/taller_indices/MASTER.sql

# O ejecutar scripts individuales
sqlplus hr/hr@XEPDB1 @scripts/taller_indices/01_consultar_indices.sql
```

Para más detalles, consulta `scripts/taller_indices/README.md`.

## Organización del repositorio

- `docker-compose.yml`: Orquesta Oracle XE con inicialización automática.
- `docker/oracle/init-sql/`: Scripts ejecutados al arrancar el contenedor (desbloqueo de HR, creación de usuario).
- `scripts/`: Ejercicios del laboratorio (semilla de datos HR, registro de esquema, consulta SQL/XML, inserciones).
  - `scripts/taller_indices/`: Scripts del taller de índices y restricciones.
- `docs/xml/`: Esquema XML y ficheros generados.
- `docs/screenshots/`: Carpeta sugerida para capturas usadas en la memoria.
- `docs/TALLER_INDICES_RESTRICCIONES.md`: Documentación completa del taller de índices y restricciones.
