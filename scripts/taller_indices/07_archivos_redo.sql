-- =====================================================
-- TALLER: Índices y Restricciones en Oracle
-- Script 07: Archivos Redo y Modos de Funcionamiento
-- =====================================================
-- Ejecutar como usuario con privilegios SYSDBA o DBA
-- NOTA: Algunas consultas requieren privilegios elevados
SET ECHO ON
SET FEEDBACK ON
SET SERVEROUTPUT ON

PROMPT ============================================
PROMPT INFORMACIÓN SOBRE ARCHIVOS REDO
PROMPT ============================================
PROMPT Los archivos Redo Log almacenan todas las
PROMPT operaciones de modificación de datos para
PROMPT permitir la recuperación de la base de datos.
PROMPT ============================================

-- Consultar información sobre los grupos de Redo Log
PROMPT Consultando grupos de Redo Log...
SELECT 
    group#,
    thread#,
    sequence#,
    bytes/1024/1024 AS size_mb,
    members,
    status,
    archived,
    first_change#,
    next_change#
FROM 
    v$log
ORDER BY 
    group#;

-- Consultar los archivos miembros de Redo Log
PROMPT Consultando archivos miembros de Redo Log...
SELECT 
    group#,
    member,
    bytes/1024/1024 AS size_mb,
    status
FROM 
    v$logfile
ORDER BY 
    group#, member;

-- Consultar el modo de funcionamiento de la base de datos
PROMPT Consultando modo de funcionamiento de la base de datos...
SELECT 
    log_mode,
    database_role,
    flashback_on,
    force_logging
FROM 
    v$database;

PROMPT ============================================
PROMPT EJEMPLO PRÁCTICO: GENERAR ACTIVIDAD REDO
PROMPT ============================================

-- Como usuario HR, generar actividad que se registre en Redo Log
PROMPT Generando actividad en la base de datos...
PROMPT (Esta actividad se registrará en los archivos Redo)

-- Realizar múltiples operaciones DML
BEGIN
    FOR i IN 1..100 LOOP
        INSERT INTO departments2 (department_id, department_name, manager_id, location_id)
        VALUES (1000 + i, 'Dept Redo ' || i, NULL, 1000);
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('✓ 100 inserciones realizadas');
END;
/

COMMIT;

PROMPT ============================================
PROMPT CONSULTANDO ESTADÍSTICAS DE REDO
PROMPT ============================================

-- Consultar estadísticas de Redo generado en la sesión actual
SELECT 
    name,
    value
FROM 
    v$mystat s,
    v$statname n
WHERE 
    s.statistic# = n.statistic#
    AND n.name = 'redo size';

PROMPT ============================================
PROMPT INFORMACIÓN SOBRE ARCHIVOS REDO LOG
PROMPT ============================================
PROMPT 
PROMPT ¿Qué son los archivos Redo en Oracle?
PROMPT ----------------------------------------
PROMPT Los archivos Redo Log son archivos que registran
PROMPT todas las operaciones de modificación de datos
PROMPT (INSERT, UPDATE, DELETE) y cambios en la estructura
PROMPT de la base de datos. Oracle utiliza estos archivos
PROMPT para:
PROMPT   1. Recuperación ante fallos (crash recovery)
PROMPT   2. Recuperación de medios (media recovery)
PROMPT   3. Replicación de datos (Data Guard)
PROMPT   4. Análisis de cambios (LogMiner)
PROMPT 
PROMPT Modos de funcionamiento según archivos Redo:
PROMPT ---------------------------------------------
PROMPT 1. NOARCHIVELOG: Los Redo Log se sobrescriben
PROMPT    - No se pueden recuperar datos después de un fallo
PROMPT    - Solo permite recuperación hasta el último backup
PROMPT    - Modo por defecto en instalaciones básicas
PROMPT 
PROMPT 2. ARCHIVELOG: Los Redo Log se archivan antes de
PROMPT    sobrescribirse
PROMPT    - Permite recuperación completa hasta cualquier punto
PROMPT    - Necesario para backups en caliente (hot backup)
PROMPT    - Requerido para Data Guard y replicación
PROMPT    - Permite recuperación point-in-time
PROMPT 
PROMPT Ejemplo práctico:
PROMPT ------------------
PROMPT En modo ARCHIVELOG, si la base de datos falla a las
PROMPT 14:00, puedes recuperar todos los datos hasta las
PROMPT 13:59 usando los archivos Redo Log archivados.
PROMPT 
PROMPT En modo NOARCHIVELOG, solo puedes recuperar hasta
PROMPT el último backup completo realizado.
PROMPT ============================================

-- Limpiar datos de ejemplo
DELETE FROM departments2 WHERE department_id >= 1000;
COMMIT;

PROMPT Datos de ejemplo eliminados.

