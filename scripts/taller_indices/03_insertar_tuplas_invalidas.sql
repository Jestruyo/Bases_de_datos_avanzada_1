-- =====================================================
-- TALLER: Índices y Restricciones en Oracle
-- Script 03: Insertar tuplas que no cumplen restricciones
-- =====================================================
-- IMPORTANTE: Este script debe ejecutarse DESPUÉS de 
-- desactivar las restricciones (script 02)
-- Ejecutar como usuario HR
SET ECHO ON
SET FEEDBACK ON
SET SERVEROUTPUT ON

PROMPT ============================================
PROMPT INSERTANDO TUPLAS INVÁLIDAS EN DEPARTMENTS
PROMPT (Con restricciones desactivadas)
PROMPT ============================================

-- Intentar insertar un departamento con ID duplicado (violaría PRIMARY KEY)
PROMPT Intentando insertar departamento con ID duplicado...
INSERT INTO departments (department_id, department_name, manager_id, location_id)
VALUES (10, 'Departamento Duplicado', NULL, NULL);
DBMS_OUTPUT.PUT_LINE('✓ Insertado: Departamento con ID duplicado (10)');

-- Intentar insertar un departamento con nombre NULL (violaría NOT NULL)
PROMPT Intentando insertar departamento con nombre NULL...
INSERT INTO departments (department_id, department_name, manager_id, location_id)
VALUES (999, NULL, NULL, NULL);
DBMS_OUTPUT.PUT_LINE('✓ Insertado: Departamento con nombre NULL');

-- Intentar insertar un departamento con location_id inexistente (violaría FOREIGN KEY)
PROMPT Intentando insertar departamento con location_id inexistente...
INSERT INTO departments (department_id, department_name, manager_id, location_id)
VALUES (998, 'Departamento con Location Inválida', NULL, 99999);
DBMS_OUTPUT.PUT_LINE('✓ Insertado: Departamento con location_id inexistente (99999)');

PROMPT ============================================
PROMPT INSERTANDO TUPLAS INVÁLIDAS EN EMPLOYEES
PROMPT (Con restricciones desactivadas)
PROMPT ============================================

-- Intentar insertar un empleado con ID duplicado (violaría PRIMARY KEY)
PROMPT Intentando insertar empleado con ID duplicado...
INSERT INTO employees (employee_id, first_name, last_name, email, phone_number, hire_date, job_id, salary, manager_id, department_id)
VALUES (200, 'Juan', 'Duplicado', 'JDUPLICADO', '555.123.4567', DATE '2020-01-01', 'AD_ASST', 5000, NULL, NULL);
DBMS_OUTPUT.PUT_LINE('✓ Insertado: Empleado con ID duplicado (200)');

-- Intentar insertar un empleado con last_name NULL (violaría NOT NULL)
PROMPT Intentando insertar empleado con last_name NULL...
INSERT INTO employees (employee_id, first_name, last_name, email, phone_number, hire_date, job_id, salary, manager_id, department_id)
VALUES (999, 'Sin', NULL, 'SINAPELLIDO', '555.123.4568', DATE '2020-01-01', 'AD_ASST', 5000, NULL, NULL);
DBMS_OUTPUT.PUT_LINE('✓ Insertado: Empleado con last_name NULL');

-- Intentar insertar un empleado con email NULL (violaría NOT NULL)
PROMPT Intentando insertar empleado con email NULL...
INSERT INTO employees (employee_id, first_name, last_name, email, phone_number, hire_date, job_id, salary, manager_id, department_id)
VALUES (998, 'Sin', 'Email', NULL, '555.123.4569', DATE '2020-01-01', 'AD_ASST', 5000, NULL, NULL);
DBMS_OUTPUT.PUT_LINE('✓ Insertado: Empleado con email NULL');

-- Intentar insertar un empleado con salary negativo (violaría CHECK)
PROMPT Intentando insertar empleado con salary negativo...
INSERT INTO employees (employee_id, first_name, last_name, email, phone_number, hire_date, job_id, salary, manager_id, department_id)
VALUES (997, 'Salario', 'Negativo', 'SNEGATIVO', '555.123.4570', DATE '2020-01-01', 'AD_ASST', -1000, NULL, NULL);
DBMS_OUTPUT.PUT_LINE('✓ Insertado: Empleado con salary negativo (-1000)');

-- Intentar insertar un empleado con department_id inexistente (violaría FOREIGN KEY)
PROMPT Intentando insertar empleado con department_id inexistente...
INSERT INTO employees (employee_id, first_name, last_name, email, phone_number, hire_date, job_id, salary, manager_id, department_id)
VALUES (996, 'Departamento', 'Inexistente', 'DINEXIST', '555.123.4571', DATE '2020-01-01', 'AD_ASST', 5000, NULL, 99999);
DBMS_OUTPUT.PUT_LINE('✓ Insertado: Empleado con department_id inexistente (99999)');

PROMPT ============================================
PROMPT VERIFICANDO INSERCIONES
PROMPT ============================================

SELECT COUNT(*) AS total_departments FROM departments;
SELECT COUNT(*) AS total_employees FROM employees;

PROMPT ============================================
PROMPT CONSULTA DE DEPARTMENTS CON DATOS INVÁLIDOS
PROMPT ============================================

SELECT * FROM departments ORDER BY department_id;

PROMPT ============================================
PROMPT CONSULTA DE EMPLOYEES CON DATOS INVÁLIDOS
PROMPT ============================================

SELECT employee_id, first_name, last_name, email, salary, department_id 
FROM employees 
ORDER BY employee_id;

COMMIT;

PROMPT ============================================
PROMPT NOTA: Las tuplas se insertaron porque las
PROMPT restricciones están desactivadas. Si se
PROMPT reactivan, estas tuplas causarían errores.
PROMPT ============================================

