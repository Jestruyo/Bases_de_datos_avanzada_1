-- =====================================================
-- TALLER: Índices y Restricciones en Oracle
-- Script 05: Crear departments2 y trabajar con transacciones
-- =====================================================
-- Ejecutar como usuario HR
SET ECHO ON
SET FEEDBACK ON
SET SERVEROUTPUT ON

PROMPT ============================================
PROMPT CREANDO TABLA DEPARTMENTS2 COMO DUPLICADO
PROMPT ============================================

-- Eliminar la tabla si ya existe
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE departments2 CASCADE CONSTRAINTS';
    DBMS_OUTPUT.PUT_LINE('Tabla departments2 eliminada si existía');
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN
            RAISE;
        END IF;
END;
/

-- Crear departments2 como copia de departments
CREATE TABLE departments2 AS
SELECT * FROM departments;

PROMPT Tabla departments2 creada exitosamente

PROMPT ============================================
PROMPT VERIFICANDO ESTRUCTURA DE DEPARTMENTS2
PROMPT ============================================

SELECT 
    column_name,
    data_type,
    data_length,
    nullable
FROM 
    user_tab_columns
WHERE 
    table_name = 'DEPARTMENTS2'
ORDER BY 
    column_id;

PROMPT ============================================
PROMPT INSERTANDO TRES TUPLAS EN DEPARTMENTS2
PROMPT ============================================

-- Insertar primera tupla
INSERT INTO departments2 (department_id, department_name, manager_id, location_id)
VALUES (30, 'Recursos Humanos', NULL, 1000);
DBMS_OUTPUT.PUT_LINE('✓ Tupla 1 insertada: ID=30, Recursos Humanos');

-- Insertar segunda tupla
INSERT INTO departments2 (department_id, department_name, manager_id, location_id)
VALUES (40, 'Ventas', NULL, 1100);
DBMS_OUTPUT.PUT_LINE('✓ Tupla 2 insertada: ID=40, Ventas');

-- Insertar tercera tupla
INSERT INTO departments2 (department_id, department_name, manager_id, location_id)
VALUES (50, 'Tecnología', NULL, 1000);
DBMS_OUTPUT.PUT_LINE('✓ Tupla 3 insertada: ID=50, Tecnología');

COMMIT;

PROMPT ============================================
PROMPT VERIFICANDO CONTENIDO DE DEPARTMENTS2
PROMPT ============================================

SELECT * FROM departments2 ORDER BY department_id;

PROMPT ============================================
PROMPT CONSULTA DESPUÉS DE CERRAR SESIÓN
PROMPT ============================================
PROMPT Para verificar que los datos persisten después
PROMPT de cerrar sesión, ejecuta:
PROMPT   SELECT * FROM departments2 ORDER BY department_id;
PROMPT ============================================

