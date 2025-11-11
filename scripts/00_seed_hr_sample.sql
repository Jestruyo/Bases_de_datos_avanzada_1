-- Ejecutar como usuario HR dentro de XEPDB1
SET ECHO ON
SET FEEDBACK ON
SET SERVEROUTPUT ON

BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE locations CASCADE CONSTRAINTS';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE != -942 THEN
      RAISE;
    END IF;
END;
/

CREATE TABLE locations (
  location_id    NUMBER CONSTRAINT locations_pk PRIMARY KEY,
  street_address VARCHAR2(40),
  postal_code    VARCHAR2(12),
  city           VARCHAR2(30) CONSTRAINT location_city_nn NOT NULL,
  state_province VARCHAR2(25),
  country_id     CHAR(2)
);

INSERT INTO locations VALUES (1000, '2004 Charade Rd', '98199', 'Seattle', 'Washington', 'US');
INSERT INTO locations VALUES (1100, '460 Bloor St.', 'M5S 1X8', 'Toronto', 'Ontario', 'CA');

BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE departments CASCADE CONSTRAINTS';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE != -942 THEN
      RAISE;
    END IF;
END;
/

CREATE TABLE departments (
  department_id   NUMBER(4) CONSTRAINT departments_pk PRIMARY KEY,
  department_name VARCHAR2(30) CONSTRAINT dept_name_nn NOT NULL,
  manager_id      NUMBER(6),
  location_id     NUMBER(4) CONSTRAINT dept_location_fk REFERENCES locations(location_id)
);

INSERT INTO departments VALUES (10, 'Administration', 200, 1000);
INSERT INTO departments VALUES (20, 'Marketing', 201, 1100);

BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE employees CASCADE CONSTRAINTS';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE != -942 THEN
      RAISE;
    END IF;
END;
/

CREATE TABLE employees (
  employee_id   NUMBER(6) CONSTRAINT employees_pk PRIMARY KEY,
  first_name    VARCHAR2(20),
  last_name     VARCHAR2(25) CONSTRAINT emp_last_name_nn NOT NULL,
  email         VARCHAR2(25) CONSTRAINT emp_email_nn NOT NULL,
  phone_number  VARCHAR2(20),
  hire_date     DATE CONSTRAINT emp_hire_date_nn NOT NULL,
  job_id        VARCHAR2(10) CONSTRAINT emp_job_nn NOT NULL,
  salary        NUMBER(8,2) CONSTRAINT emp_salary_ck CHECK (salary > 0),
  manager_id    NUMBER(6),
  department_id NUMBER(4) CONSTRAINT emp_dept_fk REFERENCES departments(department_id)
);

INSERT INTO employees VALUES (200, 'Jennifer', 'Whalen', 'JWHALEN', '515.123.4444', DATE '2003-09-17', 'AD_ASST', 4400, 101, 10);
INSERT INTO employees VALUES (201, 'Michael', 'Hartstein', 'MHARTSTE', '515.123.5555', DATE '1996-02-17', 'MK_MAN', 13000, 100, 20);
INSERT INTO employees VALUES (202, 'Pat', 'Fay', 'PFAY', '603.123.6666', DATE '2005-08-17', 'MK_REP', 6000, 201, 20);

COMMIT;

