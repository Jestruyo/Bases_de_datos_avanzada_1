-- =====================================================
-- TALLER: Índices y Restricciones en Oracle
-- Script 00: Limpiar datos inválidos
-- =====================================================
-- Este script elimina los datos inválidos insertados
-- en el script 03 para poder reactivar las restricciones
-- Ejecutar como usuario HR
SET ECHO ON
SET FEEDBACK ON
SET SERVEROUTPUT ON

PROMPT ============================================
PROMPT LIMPIANDO DATOS INVÁLIDOS DE DEPARTMENTS
PROMPT ============================================

-- Eliminar departamentos con IDs duplicados o inválidos
DELETE FROM departments WHERE department_id IN (999, 998);
DBMS_OUTPUT.PUT_LINE('✓ Datos inválidos eliminados de departments');

-- Eliminar departamento con nombre NULL si existe
DELETE FROM departments WHERE department_name IS NULL;
DBMS_OUTPUT.PUT_LINE('✓ Departamentos con nombre NULL eliminados');

PROMPT ============================================
PROMPT LIMPIANDO DATOS INVÁLIDOS DE EMPLOYEES
PROMPT ============================================

-- Eliminar empleados con IDs duplicados o inválidos
DELETE FROM employees WHERE employee_id IN (999, 998, 997, 996);
DBMS_OUTPUT.PUT_LINE('✓ Datos inválidos eliminados de employees');

-- Eliminar empleados con last_name NULL
DELETE FROM employees WHERE last_name IS NULL;
DBMS_OUTPUT.PUT_LINE('✓ Empleados con last_name NULL eliminados');

-- Eliminar empleados con email NULL
DELETE FROM employees WHERE email IS NULL;
DBMS_OUTPUT.PUT_LINE('✓ Empleados con email NULL eliminados');

-- Eliminar empleados con salary negativo
DELETE FROM employees WHERE salary < 0;
DBMS_OUTPUT.PUT_LINE('✓ Empleados con salary negativo eliminados');

COMMIT;

PROMPT ============================================
PROMPT VERIFICANDO ESTADO DE LAS TABLAS
PROMPT ============================================

SELECT COUNT(*) AS total_departments FROM departments;
SELECT COUNT(*) AS total_employees FROM employees;

PROMPT ============================================
PROMPT DATOS LIMPIADOS. Ahora puedes ejecutar
PROMPT el script 04 para reactivar las restricciones.
PROMPT ============================================

