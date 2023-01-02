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


#### 2022-12-27

------------------------------------------  

Created a script to generate table ***VALIDATION_WARNING***,

Create statement  is derived from this section of the script:

            /*
            Insert into PON_DICT (TABLE_NAME,PK,REQUIRED,COL_ORDER,COL_NAME,DATA_TYPE,LENGTH,SCALE,DEF_VALUE,ID,FORCE_DEF) values ('VALIDATION_WARNING',3,1,1,'VALIDATION_WARNING_GD','VARCHAR',32,null,'REPLACE(NEWID(), ''-'','''')',0,1);
            Insert into PON_DICT (TABLE_NAME,PK,REQUIRED,COL_ORDER,COL_NAME,DATA_TYPE,LENGTH,SCALE,DEF_VALUE,ID,FORCE_DEF) values ('VALIDATION_WARNING',0,0,2,'TABLE_NAME','VARCHAR',100,null,null,0,1);
            Insert into PON_DICT (TABLE_NAME,PK,REQUIRED,COL_ORDER,COL_NAME,DATA_TYPE,LENGTH,SCALE,DEF_VALUE,ID,FORCE_DEF) values ('VALIDATION_WARNING',0,0,3,'COL_NAME','VARCHAR',100,null,null,0,1);
            Insert into PON_DICT (TABLE_NAME,PK,REQUIRED,COL_ORDER,COL_NAME,DATA_TYPE,LENGTH,SCALE,DEF_VALUE,ID,FORCE_DEF) values ('VALIDATION_WARNING',0,0,4,'ROW_PK','VARCHAR',32,null,null,0,1);
            Insert into PON_DICT (TABLE_NAME,PK,REQUIRED,COL_ORDER,COL_NAME,DATA_TYPE,LENGTH,SCALE,DEF_VALUE,ID,FORCE_DEF) values ('VALIDATION_WARNING',0,0,5,'INPUT_VALUE','VARCHAR',3999,null,null,0,1);
            Insert into PON_DICT (TABLE_NAME,PK,REQUIRED,COL_ORDER,COL_NAME,DATA_TYPE,LENGTH,SCALE,DEF_VALUE,ID,FORCE_DEF) values ('VALIDATION_WARNING',0,0,6,'PON_APP_USERS_GD','VARCHAR',32,null,null,0,1);
            Insert into PON_DICT (TABLE_NAME,PK,REQUIRED,COL_ORDER,COL_NAME,DATA_TYPE,LENGTH,SCALE,DEF_VALUE,ID,FORCE_DEF) values ('VALIDATION_WARNING',0,0,7,'VALIDATION_DATE','DATETIME',null,null,null,0,1);
            Insert into PON_DICT (TABLE_NAME,PK,REQUIRED,COL_ORDER,COL_NAME,DATA_TYPE,LENGTH,SCALE,DEF_VALUE,ID,FORCE_DEF) values ('VALIDATION_WARNING',0,0,8,'VALIDATION_SOURCE_GENERIC','VARCHAR',100,null,null,0,1);
            Insert into PON_DICT (TABLE_NAME,PK,REQUIRED,COL_ORDER,COL_NAME,DATA_TYPE,LENGTH,SCALE,DEF_VALUE,ID,FORCE_DEF) values ('VALIDATION_WARNING',0,0,9,'VALIDATION_SOURCE_SPECIFIC','VARCHAR',1000,null,null,0,1);
            Insert into PON_DICT (TABLE_NAME,PK,REQUIRED,COL_ORDER,COL_NAME,DATA_TYPE,LENGTH,SCALE,DEF_VALUE,ID,FORCE_DEF) values ('VALIDATION_WARNING',0,0,10,'VALIDATION_MESSAGE','VARCHAR',3999,null,null,0,1);
            */

which translates to this:

            DROP TABLE VALIDATION_WARNING;

            CREATE TABLE VALIDATION_WARNING 
            (
            VALIDATION_WARNING_GD VARCHAR2(32) NOT NULL,
            TABLE_NAME VARCHAR2(100) NOT NULL,
            COL_NAME VARCHAR2(100) NOT NULL,
            ROW_PK VARCHAR2(32) NOT NULL,
            INPUT_VALUE VARCHAR2(3999 CHAR) NOT NULL,
            PON_APP_USERS_GD VARCHAR2(32) NOT NULL,
            VALIDATION_DATE DATE NOT NULL,
            VALIDATION_SOURCE_GENERIC VARCHAR2(100) NOT NULL,
            VALIDATION_SOURCE_SPECIFIC VARCHAR2(1000) NOT NULL,
            VALIDATION_MESSAGE VARCHAR2(3999 CHAR) NOT NULL);

and these constraints on table ***VALIDATION_WARNING*** are also taken fronm the upgrade script:

            ALTER TABLE VALIDATION_WARNING ADD CONSTRAINT PK_VALIDATION_WARNING PRIMARY KEY ("VALIDATION_WARNING_GD") using index tablespace PONT_TBL;

            ALTER TABLE VALIDATION_WARNING ADD CONSTRAINT FK_VALIDATION_WARNING_USERS FOREIGN KEY (PON_APP_USERS_GD) REFERENCES PON_APP_USERS (PON_APP_USERS_GD) ON DELETE CASCADE;

-- added the table PON_MOBILE_ERRORS, using these statenents from the script

            Insert into PON_DICT (TABLE_NAME,PK,REQUIRED,COL_ORDER,COL_NAME,DATA_TYPE,LENGTH,SCALE,DEF_VALUE,ID,FORCE_DEF) values ('PON_MOBILE_ERRORS',3,1,1,'PON_MOBILE_ERRORS_GD','VARCHAR',32,null,'REPLACE(NEWID(), ''-'','''')',0,1);
            Insert into PON_DICT (TABLE_NAME,PK,REQUIRED,COL_ORDER,COL_NAME,DATA_TYPE,LENGTH,SCALE,DEF_VALUE,ID,FORCE_DEF) values ('PON_MOBILE_ERRORS',0,1,2,'PON_APP_USERS_GD','VARCHAR',32,null,null,0,1);
            Insert into PON_DICT (TABLE_NAME,PK,REQUIRED,COL_ORDER,COL_NAME,DATA_TYPE,LENGTH,SCALE,DEF_VALUE,ID,FORCE_DEF) values ('PON_MOBILE_ERRORS',0,1,3,'DATE_REPORTED','DATETIME',null,null,null,0,1);
            Insert into PON_DICT (TABLE_NAME,PK,REQUIRED,COL_ORDER,COL_NAME,DATA_TYPE,LENGTH,SCALE,DEF_VALUE,ID,FORCE_DEF) values ('PON_MOBILE_ERRORS',0,1,4,'DATA','VARCHAR',4000,null,null,0,1);
            Insert into PON_DICT (TABLE_NAME,PK,REQUIRED,COL_ORDER,COL_NAME,DATA_TYPE,LENGTH,SCALE,DEF_VALUE,ID,FORCE_DEF) values ('PON_MOBILE_ERRORS',0,1,5,'ORDER_NUM','SMALLINT',null,null,null,0,1);

and the create statement looks like:

            CONNECT KDOT_BLP/********************@localhost:1521/xepdb1 AS NORMAL

            SET SERVEROUTPUT ON
            spool C:\git\repos\KDOT-LBIS-BRM-MIGRATION\stages\6.0\out\Create_Table_PON_MOBILE_ERRORS-20221227T1646.log

            drop table PON_MOBILE_ERRORS purge;

            create table PON_MOBILE_ERRORS 
            ( PON_MOBILE_ERRORS_GD VARCHAR2(32) DEFAULT ('REPLACE(NEWID(), ''-'')')  NOT NULL,
            PON_APP_USERS_GD VARCHAR2(32) NOT NULL ,
            DATE_REPORTED DATE DEFAULT (SYSDATE)  NOT NULL,
            DATA VARCHAR2(4000 CHAR),
            ORDER_NUM INTEGER 
            );            
            ALTER TABLE PON_MOBILE_ERRORS ADD CONSTRAINT PK_PON_MOBILE_ERRORS PRIMARY KEY ("PON_MOBILE_ERRORS_GD") using index tablespace PONT_TBL;

Added the column ACTIVE_DIRECTORY_ROLE (CHAR(1)) to PON_APP_USERS_ROLES  



Recreated USERINSP and USERBRDG and USERRWAY as   

      SELECT * FROM KDOTBLP_BRIDGE, KDOTBLP_INSPECTIONS, KDOTBLP_ROADWAYS,   

to ensure USERSTRUNIT had an entry for every bridge **(SQL manipulation)**  
Added KDOT agency tables KDOTBLP_BRIDGE, KDOTBLP_INSPECTIONS, KDOTBLP_ROADWAYS, KDOTBLP_LOAD_RATINGS  
to the upgrade script near line  

Added a script GenUserTables to make dummy copies of USERBRGD and USER INSP so the upgrade script won't choke
Discovered some orphan records in KDOTBLP_INSPECTIONS that needed to be cleaned out

            -- fixup for KDOTBLP_INSPECTIONS - these FK were not being enforced as of 12/27/2022 - must be to avoid ORPHANS in KDOTBLP_INSPECTIONS when a parent INSPEVNT record is removed
            alter table KDOTBLP_INSPECTIONS
            drop constraint FK_KDOT_INSP_INSPEVNT_GD;

            alter table KDOTBLP_INSPECTIONS
            add constraint FK_KDOT_INSP_INSPEVNT_GD foreign key (INSPEVNT_GD)
            references INSPEVNT (INSPEVNT_GD) on delete cascade
            enable
            novalidate;

The bridges involved (and the inspections INSPKEY values along with the # of duplicates) were
 
| BRKEY           | INSPKEY | MODTIME               | HITS |
|---|:---:|:---:|---:|
| 000000000630360 | GPIO    | 2/10/2020 12:27:00 PM | 2    |
| 000000000630370 | VAXU    | 2/10/2020 12:27:00 PM | 2    |
| 000000000890625 | RHOA    | 2/17/2022 08:39:42 AM | 5    |
| 414301052550076 | CXJU    | 8/27/2021 11:49:30 AM | 2    |
| 414301052550076 | QLEB    | 2/10/2020 12:27:00 PM | 2    |
| 427950895521H9C | TECQ    | 2/17/2022 10:33:42 AM | 4    |
| 42795089552D10C | VYOV    | 2/17/2022 10:37:16 AM | 2    |
| 430400876401010 | BCAF    | 3/6/2020 10:55:29 AM  | 2    |
| 430400876401010 | PRRL    | 2/17/2022 09:05:49 AM | 3    |
| 530400870000098 | RMUN    | 2/17/2022 09:44:25 AM | 3    |
| 530400870000098 | UCPG    | 3/6/2020 01:10:21 PM  | 2    |
| 5304008700MCR10 | EBVY    | 3/6/2020 02:14:01 PM  | 2    |
| 5304008700MCR10 | EUPQ    | 6/28/2022 08:54:16 AM | 2    |
| 5304008700MCR20 | IYUL    | 6/28/2022 09:02:01 AM | 2    |
| 5304008700MCR20 | UATA    | 3/9/2020 12:16:44 PM  | 2    |
| 5304008700MCR30 | IMKC    | 8/16/2021 09:47:27 AM | 3    |
| 5304008700MCR40 | NIIM    | 8/16/2021 09:48:23 AM | 4    |
| 5304008700MCR40	| NIIM	| 8/16/2021 09:48:23 AM	| 4    | 
 



As of 20221227, there were no orphan records in USERRWAY or USERSTRUNIT  

#### 2022-12-28  

------------------------------------------  

Made sure the BrM-specific table PON_PROGRAM has the column INCLUDE_WORK_CANDIDATES CHAR(1) DEFAULT ('T') - apparently not in KDOT_BLP PRODUCTION
Working on script to fix INSPUSRGUID where either null or not a GUID already. WIP


#### 2023-01-02  

------------------------------------------  

 Added dedicated procedure to create and drop KDOTBLP Portal tables, registered in table KDOTBLP_PORTAL_TABLES, and incorporated the same proc into the upgrade script itself.   
 An optional setting in the upgrade script will kill these temp tables at the end of the upgrade process - the default is 0 to NOT drop them.

 Looks like:  

                CREATE OR REPLACE PROCEDURE BACKUP_KDOTBLP_PORTAL_TABLES AS

                -- THIS PROCEDURE MAKES A BACKUP WITH A UNIQUE NAME  ENDING IN _KT
                -- FOR  ANY TABLES REGISTERED IN TABLE KDOTBLP_PORTAL_TABLES
                -- ALSO INCORPORATED DIRECTLY IN OracleBRM6.sql

                -- ARMarshall, ARM_LLC - 20230102 - created (and in OracleBRM6.sql)

                TYPE R_CURSOR IS REF CURSOR;
                CUR R_CURSOR;

                V_Q      VARCHAR2(4000);
                V_SUFFIX VARCHAR2(36) := q'[_]' || HEXTORAW(SYS_GUID()) || q'[_KT]';
                V_TN     VARCHAR2(128);

                BEGIN

                -- commented out for stand-alone
                --IF GET_VAR('SAVEAGENCYSYSTABLES') = 1 THEN
                OPEN CUR FOR
                    SELECT TABLE_NAME FROM KDOTBLP_PORTAL_TABLES ORDER BY PROCESSING_ORDER;
                LOOP
                    FETCH CUR
                    INTO V_TN;
                    EXIT WHEN CUR%NOTFOUND;
                
                    DBMS_OUTPUT.PUT_LINE(q'[Archiving KDOT Portal Table ]' || V_TN ||
                                        q'[ TO ]' || V_TN || V_SUFFIX || q'[...]');
                
                    V_Q := TRIM(q'[CREATE TABLE ]' || TRIM(V_TN || V_SUFFIX) ||
                                q'[ AS SELECT * FROM ]' || TRIM(V_TN));
                    BEGIN
                    EXECUTE IMMEDIATE V_Q;
                    DBMS_OUTPUT.PUT_LINE(q'[Table ]' || V_TN || q'[ archived OK]');
                    EXCEPTION
                    WHEN OTHERS THEN
                        DBMS_OUTPUT.PUT_LINE(q'[ERROR ARCHIVING TABLE: ]' || V_Q ||
                                            q'[: ]' || SQLERRM);
                    END;
                
                END LOOP;
                CLOSE CUR;
                -- commented out for stand-alone 
                -- END IF;
                EXCEPTION
                WHEN OTHERS THEN
                    BEGIN
                    RAISE_APPLICATION_ERROR(-20000, SQLERRM);
                    END;
                END;


and the drop procedure looks like:  


            CREATE OR REPLACE PROCEDURE DROP_KDOTBLP_BACKUP_TABLES AS
            -- THIS PROCEDURE DROPS ANY TABLES WITH NAMES ENDING IN _KT
            -- EXTRACTED FROM OracleBRM6.sql
            -- ARMarshall, ARM_LLC - 20230102 - created (and in OracleBRM6.sql)
            --DECLARE

                v_TN1 VARCHAR2(30);
                v_q VARCHAR2(4000 CHAR);
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

                            v_q := 'DROP TABLE ' || V_TN1 || ' PURGEX';
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
            END;
