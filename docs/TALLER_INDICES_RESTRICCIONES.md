# Taller: Índices y Restricciones en Oracle

## Descripción de la Actividad

En esta actividad trabajamos con los índices y restricciones del esquema HR (Human Resources) que se instala por defecto con Oracle 11g. Utilizamos SQL Developer y SQL*Plus para realizar las tareas, incluyendo el código SQL correspondiente.

---

## 1. Iniciar sesión con el usuario HR

### Procedimiento

Para iniciar sesión con el usuario HR en SQL Developer:

1. Abre SQL Developer
2. Crea una nueva conexión con los siguientes parámetros:
   - **Nombre de conexión**: HR
   - **Nombre de usuario**: hr
   - **Contraseña**: hr (o la contraseña configurada en tu instalación)
   - **Tipo de conexión**: Básico
   - **Nombre del host**: localhost (o la IP del servidor)
   - **Puerto**: 1521
   - **SID**: XEPDB1 (para Oracle XE) o el SID correspondiente

3. Haz clic en "Probar" para verificar la conexión
4. Haz clic en "Conectar" para establecer la sesión

### Captura de Pantalla

*[Incluir captura de pantalla de SQL Developer mostrando la conexión exitosa al usuario HR]*

---

## 2. Consultar los índices disponibles en las tablas employees y departments

### Procedimiento

Ejecutamos el script `01_consultar_indices.sql` que consulta:

- Índices de la tabla `EMPLOYEES`
- Columnas de los índices de `EMPLOYEES`
- Índices de la tabla `DEPARTMENTS`
- Columnas de los índices de `DEPARTMENTS`
- Restricciones de ambas tablas

### Código SQL Ejecutado

```sql
-- Consulta de índices en EMPLOYEES
SELECT 
    i.index_name,
    i.index_type,
    i.table_name,
    i.uniqueness,
    i.status,
    i.tablespace_name
FROM 
    user_indexes i
WHERE 
    i.table_name = 'EMPLOYEES'
ORDER BY 
    i.index_name;

-- Consulta de índices en DEPARTMENTS
SELECT 
    i.index_name,
    i.index_type,
    i.table_name,
    i.uniqueness,
    i.status,
    i.tablespace_name
FROM 
    user_indexes i
WHERE 
    i.table_name = 'DEPARTMENTS'
ORDER BY 
    i.index_name;
```

### Resultados Esperados

**Índices en EMPLOYEES:**
- `EMPLOYEES_PK`: Índice PRIMARY KEY en `employee_id` (único, activo)

**Índices en DEPARTMENTS:**
- `DEPARTMENTS_PK`: Índice PRIMARY KEY en `department_id` (único, activo)

### Análisis

Los índices encontrados son principalmente índices creados automáticamente por Oracle para las restricciones PRIMARY KEY. Estos índices:
- Son de tipo `NORMAL` (B-tree)
- Tienen unicidad `UNIQUE`
- Están en estado `VALID`
- Mejoran el rendimiento de las consultas que utilizan estas columnas en cláusulas WHERE o JOIN

### Captura de Pantalla

*[Incluir captura de pantalla mostrando los resultados de la consulta de índices]*

---

## 3. Desactivar las restricciones de estas tablas del esquema HR

### Procedimiento

Ejecutamos el script `02_desactivar_restricciones.sql` que desactiva todas las restricciones (PRIMARY KEY, FOREIGN KEY, UNIQUE, CHECK) de las tablas `EMPLOYEES` y `DEPARTMENTS`.

### Código SQL Ejecutado

```sql
-- Desactivar restricciones de EMPLOYEES
BEGIN
    FOR rec IN (
        SELECT constraint_name 
        FROM user_constraints 
        WHERE table_name = 'EMPLOYEES'
        AND constraint_type IN ('P', 'R', 'U', 'C')
    ) LOOP
        EXECUTE IMMEDIATE 'ALTER TABLE employees DISABLE CONSTRAINT ' || rec.constraint_name;
    END LOOP;
END;
/

-- Desactivar restricciones de DEPARTMENTS
BEGIN
    FOR rec IN (
        SELECT constraint_name 
        FROM user_constraints 
        WHERE table_name = 'DEPARTMENTS'
        AND constraint_type IN ('P', 'R', 'U', 'C')
    ) LOOP
        EXECUTE IMMEDIATE 'ALTER TABLE departments DISABLE CONSTRAINT ' || rec.constraint_name;
    END LOOP;
END;
/
```

### Resultados

Todas las restricciones se desactivan exitosamente. Al consultar el estado:

```sql
SELECT 
    table_name,
    constraint_name,
    constraint_type,
    status
FROM 
    user_constraints
WHERE 
    table_name IN ('EMPLOYEES', 'DEPARTMENTS');
```

El campo `status` muestra `DISABLED` para todas las restricciones.

### ¿Qué ocurre y por qué?

Al desactivar las restricciones:
- **Las restricciones dejan de validar los datos**: Oracle no verificará si los datos cumplen las reglas definidas
- **Los índices asociados pueden mantenerse o eliminarse**: Dependiendo del tipo de restricción
- **Se pueden insertar datos inválidos**: Esto es útil para migraciones o cargas masivas de datos

### Captura de Pantalla

*[Incluir captura de pantalla mostrando las restricciones desactivadas]*

---

## 4. Insertar tuplas en ambas tablas que no cumplan las restricciones establecidas aunque se encuentran desactivadas

### Procedimiento

Ejecutamos el script `03_insertar_tuplas_invalidas.sql` que inserta múltiples tuplas que violarían las restricciones si estuvieran activas.

### Código SQL Ejecutado

```sql
-- Insertar departamento con ID duplicado
INSERT INTO departments (department_id, department_name, manager_id, location_id)
VALUES (10, 'Departamento Duplicado', NULL, NULL);

-- Insertar departamento con nombre NULL
INSERT INTO departments (department_id, department_name, manager_id, location_id)
VALUES (999, NULL, NULL, NULL);

-- Insertar empleado con ID duplicado
INSERT INTO employees (employee_id, first_name, last_name, email, phone_number, hire_date, job_id, salary, manager_id, department_id)
VALUES (200, 'Juan', 'Duplicado', 'JDUPLICADO', '555.123.4567', DATE '2020-01-01', 'AD_ASST', 5000, NULL, NULL);

-- Insertar empleado con salary negativo
INSERT INTO employees (employee_id, first_name, last_name, email, phone_number, hire_date, job_id, salary, manager_id, department_id)
VALUES (997, 'Salario', 'Negativo', 'SNEGATIVO', '555.123.4570', DATE '2020-01-01', 'AD_ASST', -1000, NULL, NULL);
```

### Resultados

Todas las inserciones se completan exitosamente porque las restricciones están desactivadas. Las tuplas insertadas incluyen:

**En DEPARTMENTS:**
- ID duplicado (violaría PRIMARY KEY)
- Nombre NULL (violaría NOT NULL)
- Location_id inexistente (violaría FOREIGN KEY)

**En EMPLOYEES:**
- ID duplicado (violaría PRIMARY KEY)
- Last_name NULL (violaría NOT NULL)
- Email NULL (violaría NOT NULL)
- Salary negativo (violaría CHECK)
- Department_id inexistente (violaría FOREIGN KEY)

### ¿Qué ocurre y por qué?

Las inserciones se realizan exitosamente porque:
- **Las restricciones están desactivadas**: Oracle no valida los datos contra las reglas
- **Los datos se almacenan físicamente**: Aunque violen las reglas de integridad
- **Esto puede causar problemas futuros**: Si intentamos reactivar las restricciones sin limpiar estos datos

### Captura de Pantalla

*[Incluir captura de pantalla mostrando las inserciones exitosas y los datos inválidos]*

---

## 5. Volver a establecer las restricciones

### Procedimiento

Ejecutamos el script `04_reactivar_restricciones.sql` que intenta reactivar todas las restricciones. Si hay datos inválidos, algunas restricciones fallarán.

### Código SQL Ejecutado

```sql
-- Reactivar restricciones de DEPARTMENTS
BEGIN
    FOR rec IN (
        SELECT constraint_name 
        FROM user_constraints 
        WHERE table_name = 'DEPARTMENTS'
        AND status = 'DISABLED'
    ) LOOP
        BEGIN
            EXECUTE IMMEDIATE 'ALTER TABLE departments ENABLE CONSTRAINT ' || rec.constraint_name;
        EXCEPTION
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        END;
    END LOOP;
END;
/
```

### Resultados Esperados

Si hay datos inválidos, algunas restricciones fallarán con errores como:
- `ORA-02437`: No se puede validar la restricción - se encontraron datos inválidos
- `ORA-02299`: No se puede validar la restricción - se encontraron filas duplicadas

### Solución

Antes de reactivar las restricciones, debemos limpiar los datos inválidos ejecutando `00_limpiar_datos_invalidos.sql`:

```sql
-- Eliminar datos inválidos
DELETE FROM departments WHERE department_id IN (999, 998);
DELETE FROM employees WHERE employee_id IN (999, 998, 997, 996);
COMMIT;
```

Luego, al ejecutar el script de reactivación, todas las restricciones se activarán correctamente.

### ¿Qué ocurre y por qué?

- **Si no hay datos inválidos**: Las restricciones se reactivan exitosamente
- **Si hay datos inválidos**: Oracle intenta validar los datos existentes y falla si encuentra violaciones
- **Oracle valida todos los datos**: No solo los nuevos, sino todos los existentes en la tabla

### Captura de Pantalla

*[Incluir captura de pantalla mostrando el proceso de reactivación y los errores (si los hay)]*

---

## 6. Crear un duplicado de la tabla departments, llamada departments2

### Procedimiento

Ejecutamos el script `05_crear_departments2.sql` que crea una copia completa de la tabla `departments`.

### Código SQL Ejecutado

```sql
-- Crear departments2 como copia de departments
CREATE TABLE departments2 AS
SELECT * FROM departments;
```

### Resultados

La tabla `departments2` se crea con:
- La misma estructura que `departments`
- Todos los datos de `departments` copiados
- Sin restricciones ni índices (solo la estructura y datos)

### ¿Qué ocurre y por qué?

- **CREATE TABLE AS SELECT**: Crea una nueva tabla con la estructura y datos de la consulta
- **No copia restricciones**: Solo copia la estructura de columnas y los datos
- **No copia índices**: Los índices deben crearse manualmente si se necesitan

### Captura de Pantalla

*[Incluir captura de pantalla mostrando la creación de departments2 y su estructura]*

---

## 7. Insertar tres tuplas en dicha tabla

### Procedimiento

Continuamos con el script `05_crear_departments2.sql` que inserta tres nuevas tuplas en `departments2`.

### Código SQL Ejecutado

```sql
-- Insertar primera tupla
INSERT INTO departments2 (department_id, department_name, manager_id, location_id)
VALUES (30, 'Recursos Humanos', NULL, 1000);

-- Insertar segunda tupla
INSERT INTO departments2 (department_id, department_name, manager_id, location_id)
VALUES (40, 'Ventas', NULL, 1100);

-- Insertar tercera tupla
INSERT INTO departments2 (department_id, department_name, manager_id, location_id)
VALUES (50, 'Tecnología', NULL, 1000);

COMMIT;
```

### Resultados

Las tres tuplas se insertan exitosamente:
- Departamento 30: Recursos Humanos
- Departamento 40: Ventas
- Departamento 50: Tecnología

### Captura de Pantalla

*[Incluir captura de pantalla mostrando las tres tuplas insertadas]*

---

## 8. Cerrar sesión

### Procedimiento

En SQL Developer:
1. Clic derecho en la conexión HR
2. Seleccionar "Cerrar"
3. O simplemente cerrar SQL Developer

### Captura de Pantalla

*[Incluir captura de pantalla mostrando el cierre de sesión]*

---

## 9. Consultar la tabla departments2

### Procedimiento

Después de cerrar sesión, reconectamos como usuario HR y consultamos `departments2`.

### Código SQL Ejecutado

```sql
-- Reconectar como usuario HR
-- Luego ejecutar:
SELECT * FROM departments2 ORDER BY department_id;
```

### Resultados

Los datos están disponibles porque se hizo `COMMIT` antes de cerrar la sesión. La consulta muestra:
- Todos los departamentos originales de `departments`
- Las tres nuevas tuplas insertadas (30, 40, 50)

### ¿Qué ocurre y por qué?

- **Los datos persisten**: El `COMMIT` guarda los cambios permanentemente en la base de datos
- **Los datos están disponibles para todas las sesiones**: Cualquier usuario con permisos puede consultarlos
- **La persistencia es independiente de la sesión**: Los datos están en el disco, no en la memoria de la sesión

### Captura de Pantalla

*[Incluir captura de pantalla mostrando la consulta después de reconectar]*

---

## 10. Crear un bloque anónimo en Oracle que indique el comienzo y finalización de una transacción sobre la tabla departments2

### Procedimiento

Ejecutamos el script `06_transacciones_y_rollback.sql` que contiene bloques anónimos con transacciones.

### Código SQL Ejecutado

```sql
DECLARE
    v_count_before NUMBER;
    v_count_after NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== INICIO DE TRANSACCIÓN ===');
    
    -- Contar registros antes
    SELECT COUNT(*) INTO v_count_before FROM departments2;
    DBMS_OUTPUT.PUT_LINE('Registros antes: ' || v_count_before);
    
    -- Insertar un nuevo departamento
    INSERT INTO departments2 (department_id, department_name, manager_id, location_id)
    VALUES (60, 'Investigación', NULL, 1000);
    DBMS_OUTPUT.PUT_LINE('✓ Departamento insertado: ID=60');
    
    -- Contar registros después de la inserción
    SELECT COUNT(*) INTO v_count_after FROM departments2;
    DBMS_OUTPUT.PUT_LINE('Registros después de INSERT: ' || v_count_after);
    
    -- Confirmar la transacción
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('=== TRANSACCIÓN CONFIRMADA (COMMIT) ===');
    
END;
/
```

### Resultados

El bloque muestra:
- El inicio de la transacción
- El conteo de registros antes y después
- La confirmación con COMMIT
- El final de la transacción

### ¿Qué ocurre y por qué?

- **Una transacción comienza**: Con la primera sentencia DML (INSERT, UPDATE, DELETE)
- **Los cambios son temporales**: Hasta que se ejecuta COMMIT o ROLLBACK
- **COMMIT confirma los cambios**: Los datos se guardan permanentemente
- **El bloque anónimo puede contener múltiples operaciones**: Todas dentro de la misma transacción

### Captura de Pantalla

*[Incluir captura de pantalla mostrando la ejecución del bloque anónimo y su salida]*

---

## 11. ¿Cómo se puede deshacer una transacción en Oracle? Pon un ejemplo práctico

### Explicación

En Oracle, una transacción se puede deshacer usando:

1. **ROLLBACK**: Deshace todos los cambios desde el último COMMIT
2. **ROLLBACK TO SAVEPOINT**: Deshace cambios hasta un punto específico (savepoint)

### Ejemplo Práctico 1: ROLLBACK Completo

```sql
-- Ejemplo de ROLLBACK
DECLARE
    v_count_before NUMBER;
    v_count_after NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== INICIO DE TRANSACCIÓN CON ROLLBACK ===');
    
    -- Contar registros antes
    SELECT COUNT(*) INTO v_count_before FROM departments2;
    DBMS_OUTPUT.PUT_LINE('Registros antes: ' || v_count_before);
    
    -- Insertar un nuevo departamento
    INSERT INTO departments2 (department_id, department_name, manager_id, location_id)
    VALUES (70, 'Departamento Temporal', NULL, 1100);
    DBMS_OUTPUT.PUT_LINE('✓ Departamento insertado: ID=70');
    
    -- Contar registros después de la inserción
    SELECT COUNT(*) INTO v_count_after FROM departments2;
    DBMS_OUTPUT.PUT_LINE('Registros después de INSERT: ' || v_count_after);
    
    -- Deshacer la transacción
    ROLLBACK;
    DBMS_OUTPUT.PUT_LINE('=== TRANSACCIÓN DESHECHA (ROLLBACK) ===');
    
    -- Verificar que el rollback se realizó
    SELECT COUNT(*) INTO v_count_after FROM departments2;
    DBMS_OUTPUT.PUT_LINE('Registros después de ROLLBACK: ' || v_count_after);
    DBMS_OUTPUT.PUT_LINE('NOTA: El departamento ID=70 NO existe porque se hizo ROLLBACK');
    
END;
/
```

**Resultado**: El departamento con ID=70 no se guarda porque se ejecutó ROLLBACK antes de COMMIT.

### Ejemplo Práctico 2: ROLLBACK TO SAVEPOINT

```sql
-- Ejemplo con SAVEPOINT
DECLARE
    v_count NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== EJEMPLO CON SAVEPOINT ===');
    
    -- Insertar primer departamento
    INSERT INTO departments2 (department_id, department_name, manager_id, location_id)
    VALUES (80, 'Departamento A', NULL, 1000);
    DBMS_OUTPUT.PUT_LINE('✓ Departamento A insertado: ID=80');
    
    -- Crear un punto de guardado (savepoint)
    SAVEPOINT sp1;
    DBMS_OUTPUT.PUT_LINE('✓ SAVEPOINT creado: sp1');
    
    -- Insertar segundo departamento
    INSERT INTO departments2 (department_id, department_name, manager_id, location_id)
    VALUES (90, 'Departamento B', NULL, 1100);
    DBMS_OUTPUT.PUT_LINE('✓ Departamento B insertado: ID=90');
    
    -- Volver al savepoint (deshacer solo el segundo INSERT)
    ROLLBACK TO SAVEPOINT sp1;
    DBMS_OUTPUT.PUT_LINE('✓ ROLLBACK TO SAVEPOINT sp1 ejecutado');
    DBMS_OUTPUT.PUT_LINE('  NOTA: Solo se deshizo el departamento ID=90');
    DBMS_OUTPUT.PUT_LINE('        El departamento ID=80 sigue insertado');
    
    -- Confirmar la transacción (solo el primer INSERT)
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('✓ COMMIT ejecutado');
    
END;
/
```

**Resultado**: Solo el departamento con ID=80 se guarda. El ID=90 se deshizo con ROLLBACK TO SAVEPOINT.

### Captura de Pantalla

*[Incluir captura de pantalla mostrando los ejemplos de ROLLBACK y sus resultados]*

---

## 12. ¿Qué son los archivos de Redo en Oracle? ¿Qué modo de funcionamiento podemos observar en la base de datos atendiendo a estos ficheros? Pon un ejemplo

### ¿Qué son los archivos Redo?

Los **archivos Redo Log** son archivos que registran todas las operaciones de modificación de datos (INSERT, UPDATE, DELETE) y cambios en la estructura de la base de datos. Oracle utiliza estos archivos para:

1. **Recuperación ante fallos (Crash Recovery)**: Si la base de datos se cierra inesperadamente, Oracle usa los Redo Logs para recuperar los cambios no guardados
2. **Recuperación de medios (Media Recovery)**: Si se pierde un archivo de datos, se puede restaurar desde backup y aplicar los Redo Logs
3. **Replicación de datos (Data Guard)**: Los Redo Logs se envían a bases de datos en standby para mantenerlas sincronizadas
4. **Análisis de cambios (LogMiner)**: Se pueden analizar los Redo Logs para ver qué cambios se hicieron y cuándo

### Modos de Funcionamiento

Oracle puede operar en dos modos según el manejo de los archivos Redo:

#### 1. Modo NOARCHIVELOG

- **Características**:
  - Los Redo Logs se sobrescriben cíclicamente
  - No se archivan antes de sobrescribirse
  - Solo permite recuperación hasta el último backup completo
  - Modo por defecto en instalaciones básicas

- **Ventajas**:
  - Menor uso de espacio en disco
  - No requiere configuración adicional
  - Adecuado para bases de datos de desarrollo o prueba

- **Desventajas**:
  - No permite recuperación point-in-time
  - Pérdida de datos si ocurre un fallo después del último backup
  - No permite backups en caliente (hot backup)

#### 2. Modo ARCHIVELOG

- **Características**:
  - Los Redo Logs se archivan antes de sobrescribirse
  - Permite recuperación completa hasta cualquier punto en el tiempo
  - Necesario para backups en caliente
  - Requerido para Data Guard y replicación

- **Ventajas**:
  - Recuperación completa hasta cualquier momento
  - Permite backups mientras la base de datos está en uso
  - Necesario para entornos de producción críticos

- **Desventajas**:
  - Requiere más espacio en disco para los archivos archivados
  - Requiere configuración y monitoreo del proceso ARCH
  - Puede afectar el rendimiento si no está bien configurado

### Consultar el Modo Actual

```sql
-- Consultar el modo de funcionamiento
SELECT 
    log_mode,
    database_role,
    flashback_on,
    force_logging
FROM 
    v$database;
```

### Ejemplo Práctico

**Escenario**: Base de datos en modo ARCHIVELOG

1. **Backup completo a las 00:00**
2. **A las 10:00**: Se insertan 1000 registros importantes
3. **A las 14:00**: Fallo del disco que contiene los archivos de datos

**En modo ARCHIVELOG**:
- Se restaura el backup de las 00:00
- Se aplican todos los Redo Logs archivados desde las 00:00 hasta las 14:00
- **Resultado**: Se recuperan todos los datos, incluyendo los 1000 registros insertados a las 10:00

**En modo NOARCHIVELOG**:
- Se restaura el backup de las 00:00
- Solo se pueden aplicar los Redo Logs que aún no se han sobrescrito
- **Resultado**: Se pierden los datos insertados después del backup (los 1000 registros)

### Consultar Información de Redo Logs

```sql
-- Consultar grupos de Redo Log
SELECT 
    group#,
    thread#,
    sequence#,
    bytes/1024/1024 AS size_mb,
    members,
    status,
    archived
FROM 
    v$log
ORDER BY 
    group#;

-- Consultar archivos miembros de Redo Log
SELECT 
    group#,
    member,
    bytes/1024/1024 AS size_mb,
    status
FROM 
    v$logfile
ORDER BY 
    group#, member;
```

### Captura de Pantalla

*[Incluir captura de pantalla mostrando la consulta del modo de funcionamiento y los archivos Redo Log]*

---

## Resumen de Aprendizajes

### Índices
- Los índices mejoran el rendimiento de las consultas
- Oracle crea índices automáticamente para PRIMARY KEY y UNIQUE
- Los índices pueden consultarse en las vistas `USER_INDEXES` y `USER_IND_COLUMNS`

### Restricciones
- Las restricciones garantizan la integridad de los datos
- Se pueden desactivar temporalmente para operaciones de mantenimiento
- Al reactivar, Oracle valida todos los datos existentes
- Tipos de restricciones: PRIMARY KEY, FOREIGN KEY, UNIQUE, CHECK, NOT NULL

### Transacciones
- Una transacción agrupa múltiples operaciones como una unidad atómica
- COMMIT confirma los cambios permanentemente
- ROLLBACK deshace todos los cambios desde el último COMMIT
- SAVEPOINT permite deshacer solo parte de una transacción

### Archivos Redo
- Registran todas las operaciones de modificación
- Permiten recuperación ante fallos
- Modo ARCHIVELOG permite recuperación completa
- Modo NOARCHIVELOG solo permite recuperación hasta el último backup

---

## Archivos Entregables

1. **Scripts SQL**: Todos los scripts ejecutados están en `scripts/taller_indices/`
2. **Documentación**: Este documento con todas las explicaciones
3. **Capturas de Pantalla**: Incluidas en `docs/screenshots/taller_indices/` (a agregar)

---

## Referencias

- Oracle Database Documentation: [https://docs.oracle.com/en/database/](https://docs.oracle.com/en/database/)
- Oracle SQL Developer User's Guide
- Oracle Database Concepts - Redo Log Files
- Oracle Database Concepts - Transactions

