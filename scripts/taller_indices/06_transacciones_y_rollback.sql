-- =====================================================
-- TALLER: Índices y Restricciones en Oracle
-- Script 06: Transacciones y Rollback
-- =====================================================
-- Ejecutar como usuario HR
SET ECHO ON
SET FEEDBACK ON
SET SERVEROUTPUT ON

PROMPT ============================================
PROMPT EJEMPLO 1: BLOQUE ANÓNIMO CON TRANSACCIÓN
PROMPT ============================================

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
    
    -- Verificar que el commit se realizó
    SELECT COUNT(*) INTO v_count_after FROM departments2;
    DBMS_OUTPUT.PUT_LINE('Registros después de COMMIT: ' || v_count_after);
    
END;
/

PROMPT ============================================
PROMPT EJEMPLO 2: ROLLBACK DE TRANSACCIÓN
PROMPT ============================================

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

PROMPT ============================================
PROMPT EJEMPLO 3: ROLLBACK CON SAVEPOINT
PROMPT ============================================

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
    
    -- Verificar resultado final
    SELECT COUNT(*) INTO v_count FROM departments2 WHERE department_id IN (80, 90);
    DBMS_OUTPUT.PUT_LINE('Departamentos 80 y 90 encontrados: ' || v_count);
    DBMS_OUTPUT.PUT_LINE('  (Debería ser 1, solo el 80)');
    
END;
/

PROMPT ============================================
PROMPT VERIFICANDO ESTADO FINAL DE DEPARTMENTS2
PROMPT ============================================

SELECT * FROM departments2 ORDER BY department_id;

PROMPT ============================================
PROMPT RESUMEN DE TRANSACCIONES
PROMPT ============================================
PROMPT 1. COMMIT: Confirma todos los cambios
PROMPT 2. ROLLBACK: Deshace todos los cambios desde el último COMMIT
PROMPT 3. ROLLBACK TO SAVEPOINT: Deshace cambios hasta un punto específico
PROMPT ============================================

