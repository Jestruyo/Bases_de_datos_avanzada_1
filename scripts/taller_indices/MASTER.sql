-- =====================================================
-- TALLER: Índices y Restricciones en Oracle
-- Script MASTER: Ejecuta todos los scripts en secuencia
-- =====================================================
-- IMPORTANTE: Este script ejecuta todos los pasos del taller
-- Ejecutar como usuario HR
SET ECHO ON
SET FEEDBACK ON
SET SERVEROUTPUT ON

PROMPT ============================================
PROMPT TALLER: ÍNDICES Y RESTRICCIONES EN ORACLE
PROMPT ============================================
PROMPT Este script ejecutará todos los pasos del taller
PROMPT en orden secuencial.
PROMPT ============================================
PROMPT 

PROMPT Paso 1: Consultar índices...
@@01_consultar_indices.sql

PROMPT 
PROMPT Paso 2: Desactivar restricciones...
@@02_desactivar_restricciones.sql

PROMPT 
PROMPT Paso 3: Insertar tuplas inválidas...
@@03_insertar_tuplas_invalidas.sql

PROMPT 
PROMPT Paso 4: Limpiar datos inválidos...
@@00_limpiar_datos_invalidos.sql

PROMPT 
PROMPT Paso 5: Reactivar restricciones...
@@04_reactivar_restricciones.sql

PROMPT 
PROMPT Paso 6: Crear departments2 e insertar tuplas...
@@05_crear_departments2.sql

PROMPT 
PROMPT Paso 7: Ejemplos de transacciones y rollback...
@@06_transacciones_y_rollback.sql

PROMPT 
PROMPT ============================================
PROMPT TALLER COMPLETADO
PROMPT ============================================
PROMPT 
PROMPT NOTA: Para consultar archivos Redo, ejecuta
PROMPT el script 07_archivos_redo.sql como SYSDBA
PROMPT ============================================

