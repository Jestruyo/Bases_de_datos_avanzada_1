-- Ejecutar después de registrar el esquema y crear la tabla employee_department_xml
SET SERVEROUTPUT ON
SET FEEDBACK ON

BEGIN
  INSERT INTO employee_department_xml (payload)
  VALUES (
    XMLTYPE(
      q'~<employees xmlns="http://example.com/hr/employees">
            <employee>
              <employeeId>200</employeeId>
              <firstName>Jennifer</firstName>
              <lastName>Whalen</lastName>
              <email>jwhalen@example.com</email>
              <phoneNumber>515.123.4444</phoneNumber>
              <hireDate>2003-09-17</hireDate>
              <jobId>AD_ASST</jobId>
              <salary>4400.00</salary>
              <department>
                <departmentId>10</departmentId>
                <departmentName>Administration</departmentName>
                <location>
                  <city>Seattle</city>
                  <countryId>US</countryId>
                </location>
              </department>
            </employee>
          </employees>~'
    )
  );
  DBMS_OUTPUT.put_line('Inserción válida completada.');
END;
/

COMMIT;

DECLARE
  e_schema_error EXCEPTION;
  PRAGMA EXCEPTION_INIT(e_schema_error, -31061);
BEGIN
  INSERT INTO employee_department_xml (payload)
  VALUES (
    XMLTYPE(
      q'~<employees xmlns="http://example.com/hr/employees">
            <employee>
              <employeeId>201</employeeId>
              <lastName>Hartstein</lastName>
              <email>shartstein@example.com</email>
              <hireDate>2004-02-17</hireDate>
              <jobId>MK_MAN</jobId>
              <salary>13000.00</salary>
              <department>
                <departmentId>20</departmentId>
                <!-- Falta departmentName para provocar error de validación -->
                <location>
                  <city>Toronto</city>
                  <countryId>CA</countryId>
                </location>
              </department>
            </employee>
          </employees>~'
    )
  );
  COMMIT;
EXCEPTION
  WHEN e_schema_error THEN
    DBMS_OUTPUT.put_line('Error esperado por violación del esquema XML: ' || SQLERRM);
    ROLLBACK;
  WHEN OTHERS THEN
    DBMS_OUTPUT.put_line('Error capturado durante la inserción inválida: ' || SQLERRM);
    ROLLBACK;
END;
/

