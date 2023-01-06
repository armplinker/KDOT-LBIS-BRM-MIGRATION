CREATE OR REPLACE PROCEDURE DROP_KDOTBLP_BACKUP_TABLES AS
-- THIS PROCEDURE DROPS ANY TABLES WITH NAMES ENDING IN _KT
-- EXTRACTED FROM OracleBRM6.sql
-- this proc is intended to be run standalone at any time to to drop and purge (permanently remove) all tables with name extension _KT
-- left over from an upgrade script run
-- usage:  
-- SQL>EXEC DROP_KDOTBLP_BACKUP_TABLES;
-- SQL>/
-- ARMarshall, ARM_LLC - 20230102 - created (and in OracleBRM6.sql)
--DECLARE

    v_TN1 VARCHAR2(128 BYTE);
    v_q VARCHAR2(32767);
    CURSOR curColData IS
             SELECT ut.TABLE_NAME
            FROM USER_TABLES ut
            JOIN KDOTBLP_PORTAL_TABLES kt
            ON  ut.TABLE_NAME LIKE kt.TABLE_NAME || '%_KT'
            ORDER BY ut.TABLE_NAME;
BEGIN
    --IF  GET_VAR('KDOT_TABLE_CLEANUP') = '1' THEN
        /** H.1.1 | Start a loop through the cursor to create a dynamic drop process  **/
        
      
 
       OPEN curColData;
        FETCH curColData INTO v_TN1;
        WHILE (curColData%FOUND)
        LOOP
            BEGIN

              DBMS_OUTPUT.PUT_LINE('Cleaning up KDOTBLP PORTAL TABLES (_KT) tables -' || V_TN1);

                v_q := 'DROP TABLE ' || V_TN1 || ' PURGE';
                execute immediate v_q;
            EXCEPTION WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('ERROR F1: Dropping KDOTBLP PORTAL TABLES (_KT) Table [' || v_q || ']; ' || SQLERRM);
            END;
            FETCH curColData INTO v_TN1;
        END LOOP;
        CLOSE curColData;
   -- END IF;
--INSERT INTO PROFILING(PLACE, END_TIME) VALUES ('DROP TEMP KDOTBLP PORTAL TABLES (_KT)',  CURRENT_TIMESTAMP);

  EXCEPTION

  WHEN OTHERS THEN
    BEGIN
       RAISE_APPLICATION_ERROR(-20000, SQLERRM);

    END;
END DROP_KDOTBLP_BACKUP_TABLES;
/
