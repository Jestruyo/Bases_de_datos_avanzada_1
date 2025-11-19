-- =====================================================
-- TALLER: Índices y Restricciones en Oracle
-- Script 04: Reactivar restricciones
-- =====================================================
-- IMPORTANTE: Este script intentará reactivar las
-- restricciones. Si hay datos inválidos, algunas
-- restricciones fallarán al reactivarse.
-- Ejecutar como usuario HR
SET ECHO ON
SET FEEDBACK ON
SET SERVEROUTPUT ON

PROMPT ============================================
PROMPT INTENTANDO REACTIVAR RESTRICCIONES
PROMPT ============================================

-- Intentar reactivar restricciones de DEPARTMENTS
PROMPT Reactivando restricciones de DEPARTMENTS...
BEGIN
    FOR rec IN (
        SELECT constraint_name 
        FROM user_constraints 
        WHERE table_name = 'DEPARTMENTS'
        AND constraint_type IN ('P', 'R', 'U', 'C')
        AND status = 'DISABLED'
    ) LOOP
        BEGIN
            EXECUTE IMMEDIATE 'ALTER TABLE departments ENABLE CONSTRAINT ' || rec.constraint_name;
            DBMS_OUTPUT.PUT_LINE('✓ Restricción reactivada: ' || rec.constraint_name);
        EXCEPTION
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('✗ Error al reactivar ' || rec.constraint_name || ': ' || SQLERRM);
                DBMS_OUTPUT.PUT_LINE('  Razón: Existen datos que violan esta restricción');
        END;
    END LOOP;
END;
/

-- Intentar reactivar restricciones de EMPLOYEES
PROMPT Reactivando restricciones de EMPLOYEES...
BEGIN
    FOR rec IN (
        SELECT constraint_name 
        FROM user_constraints 
        WHERE table_name = 'EMPLOYEES'
        AND constraint_type IN ('P', 'R', 'U', 'C')
        AND status = 'DISABLED'
    ) LOOP
        BEGIN
            EXECUTE IMMEDIATE 'ALTER TABLE employees ENABLE CONSTRAINT ' || rec.constraint_name;
            DBMS_OUTPUT.PUT_LINE('✓ Restricción reactivada: ' || rec.constraint_name);
        EXCEPTION
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('✗ Error al reactivar ' || rec.constraint_name || ': ' || SQLERRM);
                DBMS_OUTPUT.PUT_LINE('  Razón: Existen datos que violan esta restricción');
        END;
    END LOOP;
END;
/

PROMPT ============================================
PROMPT ESTADO FINAL DE RESTRICCIONES
PROMPT ============================================

SELECT 
    table_name,
    constraint_name,
    constraint_type,
    status
FROM 
    user_constraints
WHERE 
    table_name IN ('EMPLOYEES', 'DEPARTMENTS')
ORDER BY 
    table_name, constraint_type, constraint_name;

PROMPT ============================================
PROMPT NOTA: Si algunas restricciones no se pudieron
PROMPT reactivar, es porque existen datos que las
PROMPT violan. Debes eliminar o corregir esos datos
PROMPT antes de poder reactivar las restricciones.
PROMPT ============================================

