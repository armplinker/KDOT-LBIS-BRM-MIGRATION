PL/SQL Developer Test script 3.0
38
/*CLEAR

SET SERVEROUTPUT ON SIZE UNLIMITED
SET TERMOUT ON
SET ECHO ON

WHENEVER SQLERROR CONTINUE */

DECLARE
lts_start  TIMESTAMP;
intvl_elapsed_time INTERVAL DAY TO SECOND;
intvl_total_time INTERVAL DAY TO SECOND;
begin

DBMS_OUTPUT.PUT_LINE('Start time (SYSDATE) : ' || TO_CHAR(SYSDATE, 'MM-DD-YYYY HH24:MI:SS.SS'));   

SELECT SYSTIMESTAMP INTO lts_start FROM DUAL;
 
  for testRec in (select utc.table_name, utc.column_name, utc.column_id,    f_is_primarykey_col( utc.table_name, utc.column_name )  as Is_PrimaryKey_Col 
     from user_tab_cols utc where utc.table_name in ('BRIDGE','INSPEVNT', 'ROADWAY', 'STRUCTURE_UNIT','KDOTBLP_BRIDGE','KDOTBLP_INSPECTIONS', 'USERRWAY','USERSTRUNIT', 'KDOTBLP_ATTRIBUTE_DESCRIPTOR')
     ORDER BY 1,3 ) LOOP
    
   intvl_elapsed_time:= ( systimestamp - lts_Start );
     
    DBMS_OUTPUT.PUT_LINE('Column ID: '|| to_Char(testRec.Column_id, 'fm0000' ) ||
     ' --- Table: ' || testRec.TABLE_NAME ||
     ' --- Column: ' || testRec.COLUMN_NAME ||
     ' ---  Primary key: ' || 
       case when  testRec.Is_PrimaryKey_Col >= 1 then 'T' ELSE 'F' END ||
     ' --- Elapsed Time: ' || /* LPAD(EXTRACT(HOUR FROM testRec.Elapsed_Time), 2, '0') || ':' ||*/ LPAD(EXTRACT(MINUTE FROM  intvl_elapsed_time), 2, '0')||':'|| LPAD(EXTRACT(SECOND FROM  intvl_elapsed_time), 5, '0'));
    
    END LOOP;

SELECT SYSTIMESTAMP - lts_start INTO intvl_total_time FROM DUAL;

DBMS_OUTPUT.PUT_LINE('Total Runtime (Interval Day To Second) : ' ||/* LPAD(EXTRACT(HOUR FROM lts_total_time), 2, '0') || ':' ||*/ LPAD(EXTRACT(MINUTE FROM intvl_total_time), 2, '0')||':'|| LPAD(EXTRACT(SECOND FROM intvl_total_time), 5, '0'));     
end;
--/
0
0
