# BRM Migration progress notes
 
   
## LAST UPDATES: ARMarshall, ARM LLC - 20221221 
  
### GENERAL COMMENTS ABOUT THE UPGRADE SCRIPT(S)

PON_CONCAT calls might be better formed using LISTAGG available in Oracle 12C+

see this>   [Oracle LISTAGG documentation](https://docs.oracle.com/cd/E11882_01/server.112/e41084/functions089.htm#SQLRF30030 "Oracle LISTAGG documentation")                

            SELECT LISTAGG('T.'|| DICT.COLUMN_NAME ,',') 
            WITHIN GROUP (ORDER BY DICT.COLUMN_ID) "DELIM_COL_LIST"
                                                FROM USER_TAB_COLS DICT                                     
                                                GROUP BY DICT.TABLE_NAME 
                                                HAVING DICT.TABLE_NAME = 'BRIDGE'
                                                ORDER BY DICT.TABLE_NAME
#### TO EXPORT THE DATABASE
            C:\oracle\instantclient_21_7>expdp kdot_blp/Einstein345@localhost:1521/xepdb1 directory=KDOT_DP_DIR dumpfile=KDOT_BLP20221220SQL.dmp schemas=('KDOT_BLP') logfile=KDOT_BLP20221220SQL.log

### TO SEE THE DDL FROM DATAPUMP DMP FILE
Burleson Consulting says:
[Show SQL From Dump FIle](http://www.dba-oracle.com/t_convert_expdp_dmp_file_sql.htm "Creating the SQL from a DATAPUMP import file")

### PROGRESS NOTES

------------------------------------------  
#### 2022-08-17
------------------------------------------  


-- ARMarshall, ARM LLC 20220817 - named the block where the globals are set to SET_GLOBALS_FOR_RUN  
-- ARMarshall, ARM LLC 20220817 - added PURGE to all DROP TABLE instances, including those constructed in loops.  
 
-- ARMarshall, ARM LLC 20220817 -  all these calls to PON_CONCAT use the old CURSOR loop way - probably should use 12C LISTAGG or possibly XMLAGG functions if the string result is > 4000 characters
-- leaving them alone.   

            ...  
            ...  
            ...  
    
            SELECT PON_CONCAT(CURSOR(SELECT 'T.' || DICT.COL_NAME || ' = S.' || DICT.COL_NAME
                                        FROM PON_DICT DICT
                                        WHERE DICT.TABLE_NAME = X.TABLE_NAME 
                                        AND ACTIVE_PK = 1
                                        ORDER BY DICT.COL_ORDER)
                                ,' AND ')
            INTO V_MATCH_COLS
            FROM DUAL; 
 
------------------------------------------  
#### 2022-08-18
------------------------------------------  

-- 20220818 - ARMarshall, ARM LLC - initial review, added globals to preserve datadict and paramtrs tables for KDOT LBIS 9 (BrM 5.3) database  
-- 20220818 - ARMarshall, ARM LLC - corrected minor typos as encountered  

------------------------------------------  
#### 2022-12-20
------------------------------------------  

-- 202221220 - code example for BLP tables that are backed up SEPARATELY in addition to whatever the main script does   

These tables are:    
- COPTIONS  
- DATADICT  
- PON_COPTIONS  
- PARAMTRS  
- KDOTBLP_ATTRIBUTE_DESCRIPTOR  

 
        BEGIN
            -- if the setting is true, make a backup of the table before doing anything else!
                IF GET_VAR('SAVEAGENCYSYSTABLES') = 1 THEN
                    DECLARE
                    
                    V_X VARCHAR2(64):=RAWTOHEX(SYS_GUID()); 

                    BEGIN
                        
                        BEGIN
                            EXECUTE IMMEDIATE q'[DROP TABLE PARAMTRS]'||V_X || q'[ PURGE]';
                        EXCEPTION
                                WHEN OTHERS THEN NULL;  -- do not report if the table does not exist
                        END;

                        BEGIN
                            
                            EXECUTE IMMEDIATE q'[CREATE TABLE PARAMTRS]'||V_X|| q'[ AS SELECT parms.* FROM PARAMTRS psrc ORDER BY parms.TABLE_NAME, parms.FIELD_NAME, parms.PARMVALUE]' ;

                        EXCEPTION
                            WHEN OTHERS THEN RAISE;
                        END;
                    END;
                END IF;
                 
        
        // do stuff here..  
        ...  
        ...  
        ...  

         
        EXCEPTION
            WHEN OTHERS THEN RAISE;
            END;
        /
            


-- 20221220 - added option to print cursor detail for debugging purposes which should be set to 0 normally  

-- IN PROCEDURE REV and anywhere else, examine this to determine if SQL strings or other materials should be echoed to the log
-- set it at the top in this case to TRUE so it prints

        INSERT INTO PON_GLOB_VAR (VARI, VAR_VALUE) VALUES ('PRINT_DETAILS', 1); 
        
-- where REV is invoked*
        
        IF GET_VAR('PRINT_DETAILS') = 1 THEN
            REV(V_CUR,1); 
        ELSE
            REV(V_CUR);
        END IF;

------------------------------------------  
#### 2022-12-21
------------------------------------------  


-- ARMarshall, ARM LLC 20221221 - 
        Status
        - table VALIDATION_WARNINGS is missing,
        - tables PON_APP_ROLES and PON_PROGRAM have an extra column
        - table USERINSP is nowhere to be found but there is an old one we can rename and quantify.


after imports, it may be necessary to recompile the KDOT_BLP schema wholesale, like this (connected with DBA privileges e.g. SYS):

            SQL>CONNECT SYS/xxxxx@localhost:1521/xepdb1 as SYSDBA;  
            SQL>EXECUTE UTL_RECOMP.RECOMP_PARALLEL(4,'KDOT_BLP');  


#### 2022-12-22

------------------------------------------  

