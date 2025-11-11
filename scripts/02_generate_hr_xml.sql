SET SERVEROUTPUT ON

DECLARE
  l_document CLOB;
BEGIN
  SELECT XMLSERIALIZE(
           CONTENT
             XMLELEMENT(
               "employees",
               XMLATTRIBUTES('http://example.com/hr/employees' AS "xmlns"),
               XMLAGG(
                 XMLELEMENT(
                   "employee",
                   XMLFOREST(
                     e.employee_id AS "employeeId",
                     e.first_name AS "firstName",
                     e.last_name AS "lastName",
                     e.email AS "email",
                     e.phone_number AS "phoneNumber",
                     TO_CHAR(e.hire_date, 'YYYY-MM-DD') AS "hireDate",
                     e.job_id AS "jobId",
                     TO_CHAR(
                       e.salary,
                       '9999990D00',
                       'NLS_NUMERIC_CHARACTERS=''.,'''
                     ) AS "salary"
                   ),
                   XMLELEMENT(
                     "department",
                     XMLFOREST(
                       d.department_id AS "departmentId",
                       d.department_name AS "departmentName"
                     ),
                     XMLELEMENT(
                       "location",
                       XMLFOREST(
                         NVL(l.city, 'UNKNOWN') AS "city",
                         NVL(l.country_id, 'UN') AS "countryId"
                       )
                     )
                   )
                 )
               )
             )
           AS CLOB INDENT SIZE = 2
         )
    INTO l_document
    FROM hr.employees e
    JOIN hr.departments d ON d.department_id = e.department_id
    LEFT JOIN hr.locations l ON l.location_id = d.location_id
   ORDER BY e.employee_id;

  DBMS_XSLPROCESSOR.clob2file(
    cl      => l_document,
    flocation => 'LAB_DOCS',
    fname     => 'employee_department_sample.xml',
    csid      => NLS_CHARSET_ID('AL32UTF8')
  );

  DBMS_OUTPUT.put_line('Documento guardado en docs/xml/employee_department_sample.xml');
END;
/
