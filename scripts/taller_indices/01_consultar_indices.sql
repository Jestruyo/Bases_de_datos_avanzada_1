-- =====================================================
-- TALLER: Índices y Restricciones en Oracle
-- Script 01: Consultar índices disponibles
-- =====================================================
-- Ejecutar como usuario HR
SET ECHO ON
SET FEEDBACK ON
SET PAGESIZE 100
SET LINESIZE 200

PROMPT ============================================
PROMPT CONSULTA DE ÍNDICES EN TABLA EMPLOYEES
PROMPT ============================================

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

PROMPT ============================================
PROMPT COLUMNAS DE LOS ÍNDICES EN EMPLOYEES
PROMPT ============================================

SELECT 
    ic.index_name,
    ic.column_name,
    ic.column_position,
    ic.descend
FROM 
    user_ind_columns ic
WHERE 
    ic.table_name = 'EMPLOYEES'
ORDER BY 
    ic.index_name, ic.column_position;

PROMPT ============================================
PROMPT CONSULTA DE ÍNDICES EN TABLA DEPARTMENTS
PROMPT ============================================

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

PROMPT ============================================
PROMPT COLUMNAS DE LOS ÍNDICES EN DEPARTMENTS
PROMPT ============================================

SELECT 
    ic.index_name,
    ic.column_name,
    ic.column_position,
    ic.descend
FROM 
    user_ind_columns ic
WHERE 
    ic.table_name = 'DEPARTMENTS'
ORDER BY 
    ic.index_name, ic.column_position;

PROMPT ============================================
PROMPT RESTRICCIONES EN EMPLOYEES
PROMPT ============================================

SELECT 
    constraint_name,
    constraint_type,
    table_name,
    status,
    search_condition
FROM 
    user_constraints
WHERE 
    table_name = 'EMPLOYEES'
ORDER BY 
    constraint_type, constraint_name;

PROMPT ============================================
PROMPT RESTRICCIONES EN DEPARTMENTS
PROMPT ============================================

SELECT 
    constraint_name,
    constraint_type,
    table_name,
    status,
    search_condition
FROM 
    user_constraints
WHERE 
    table_name = 'DEPARTMENTS'
ORDER BY 
    constraint_type, constraint_name;

PROMPT ============================================
PROMPT FIN DE CONSULTA DE ÍNDICES
PROMPT ============================================

