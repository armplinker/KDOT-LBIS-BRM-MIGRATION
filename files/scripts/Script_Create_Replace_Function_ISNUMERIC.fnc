CREATE OR REPLACE FUNCTION ISNUMERIC(p_string IN VARCHAR2)
  RETURN NUMBER IS
  /*
  ARMarshall, ARM_LLC - 20230103 - added WHEN OTHERS RAISE clause to EXCEPTION handler
  added NVL(p_string,'_') to make a real missing value string
  */
  v_IsIt_A_Number NUMBER;
  --NOT_A_NUMBER    EXCEPTION;
  --PRAGMA EXCEPTION_INIT(NOT_A_NUMBER, -1722);

BEGIN
  v_IsIt_A_Number := TO_NUMBER(nvl(p_string, '_')) ;
  RETURN 1;
EXCEPTION
  --WHEN NOT_A_NUMBER THEN
  -- ARMarshall, ARM_LLC - added this EXCEPTION pragma to permit testing from direct SQL.
  -- RETURN 0;
  WHEN INVALID_NUMBER THEN
    RETURN 0;
  WHEN VALUE_ERROR THEN
    -- ARMarshall, ARM LLC 20220817 - confirmed this is the right exception in procedural code like this function.  Use INVALID_NUMBER in direct SQL statements
    RETURN 0;
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20000,SQLERRM);
END ISNUMERIC;
/
