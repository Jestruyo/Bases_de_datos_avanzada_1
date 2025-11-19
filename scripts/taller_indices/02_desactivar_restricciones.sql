-- =====================================================
-- TALLER: Índices y Restricciones en Oracle
-- Script 02: Desactivar restricciones
-- =====================================================
-- Ejecutar como usuario HR
SET ECHO ON
SET FEEDBACK ON
SET SERVEROUTPUT ON

PROMPT ============================================
PROMPT DESACTIVANDO RESTRICCIONES DE EMPLOYEES
PROMPT ============================================

-- Desactivar todas las restricciones de la tabla EMPLOYEES
BEGIN
    FOR rec IN (
        SELECT constraint_name 
        FROM user_constraints 
        WHERE table_name = 'EMPLOYEES'
        AND constraint_type IN ('P', 'R', 'U', 'C')
    ) LOOP
        BEGIN
            EXECUTE IMMEDIATE 'ALTER TABLE employees DISABLE CONSTRAINT ' || rec.constraint_name;
            DBMS_OUTPUT.PUT_LINE('Restricción desactivada: ' || rec.constraint_name);
        EXCEPTION
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('Error al desactivar ' || rec.constraint_name || ': ' || SQLERRM);
        END;
    END LOOP;
END;
/

PROMPT ============================================
PROMPT DESACTIVANDO RESTRICCIONES DE DEPARTMENTS
PROMPT ============================================

-- Desactivar todas las restricciones de la tabla DEPARTMENTS
BEGIN
    FOR rec IN (
        SELECT constraint_name 
        FROM user_constraints 
        WHERE table_name = 'DEPARTMENTS'
        AND constraint_type IN ('P', 'R', 'U', 'C')
    ) LOOP
        BEGIN
            EXECUTE IMMEDIATE 'ALTER TABLE departments DISABLE CONSTRAINT ' || rec.constraint_name;
            DBMS_OUTPUT.PUT_LINE('Restricción desactivada: ' || rec.constraint_name);
        EXCEPTION
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('Error al desactivar ' || rec.constraint_name || ': ' || SQLERRM);
        END;
    END LOOP;
END;
/

PROMPT ============================================
PROMPT VERIFICANDO ESTADO DE RESTRICCIONES
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
PROMPT RESTRICCIONES DESACTIVADAS EXITOSAMENTE
PROMPT ============================================

