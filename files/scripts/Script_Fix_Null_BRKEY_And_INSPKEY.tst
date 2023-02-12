PL/SQL Developer Test script 3.0
379
DECLARE
  ls_TN1           USER_TAB_COLS.TABLE_NAME%TYPE; -- VARCHAR2(128)
  ls_execSQL       VARCHAR2(32767); -- this is the limit inside a procedure, NOT for SQL
  ls_mergeFragment VARCHAR2(32767);
  CURSOR curBrkeyTables is
    WITH CTE AS
     (SELECT DISTINCT TABLE_NAME
        from USER_TAB_COLS utc
       INNER JOIN USER_OBJECTS uo
          ON (utc.TABLE_NAME = uo.OBJECT_NAME)
       where utc.COLUMN_NAME = 'BRKEY'
         AND utc.TABLE_NAME <> 'BRIDGE'
          AND utc.TABLE_NAME NOT LIKE 'MV_%'
          AND utc.TABLE_NAME NOT LIKE '%_MV'
         AND utc.TABLE_NAME NOT LIKE '%_TEMP'
         AND utc.TABLE_NAME NOT LIKE '%_T'
         AND utc.TABLE_NAME NOT LIKE '%_KT'
         AND utc.TABLE_NAME NOT LIKE 'ARC_%'
         AND utc.TABLE_NAME NOT LIKE '%_AR'
         AND utc.TABLE_NAME NOT LIKE '%_BACKUP'
         AND utc.TABLE_NAME NOT LIKE '%_NEW_%'
         AND utc.TABLE_NAME NOT LIKE '%_NEW'
         AND utc.TABLE_NAME NOT LIKE '%_RENAMED'
         AND utc.TABLE_NAME NOT LIKE '%_TRANSFORM'
         AND utc.TABLE_NAME NOT LIKE '%_202%'
         and uo.OBJECT_TYPE = 'TABLE'
      INTERSECT
      SELECT DISTINCT TABLE_NAME
        from USER_TAB_COLS utc
       INNER JOIN USER_OBJECTS uo
          ON (utc.TABLE_NAME = uo.OBJECT_NAME)
       where utc.COLUMN_NAME = 'BRIDGE_GD'
         AND utc.TABLE_NAME <> 'BRIDGE'
          AND utc.TABLE_NAME NOT LIKE 'MV_%'
          AND utc.TABLE_NAME NOT LIKE '%_MV'
         AND utc.TABLE_NAME NOT LIKE '%_TEMP'
         AND utc.TABLE_NAME NOT LIKE '%_T'
         AND utc.TABLE_NAME NOT LIKE '%_KT'
         AND utc.TABLE_NAME NOT LIKE 'ARC_%'
         AND utc.TABLE_NAME NOT LIKE '%_AR'
         AND utc.TABLE_NAME NOT LIKE '%_BACKUP'
         AND utc.TABLE_NAME NOT LIKE '%_NEW_%'
         AND utc.TABLE_NAME NOT LIKE '%_NEW'
         AND utc.TABLE_NAME NOT LIKE '%_RENAMED'
         AND utc.TABLE_NAME NOT LIKE '%_RENAMED_%'
         AND utc.TABLE_NAME NOT LIKE '%_TRANSFORM'
         AND utc.TABLE_NAME NOT LIKE '%_202%'
         and uo.OBJECT_TYPE = 'TABLE'
      MINUS
      -- exclude materialized views that may have PREBUILT tables.
      SELECT DISTINCT utc.TABLE_NAME
        from USER_TAB_COLS utc
       INNER JOIN USER_OBJECTS uo
          ON (utc.TABLE_NAME = uo.OBJECT_NAME and uo.OBJECT_TYPE = 'TABLE')
       INNER JOIN ALL_MVIEWS amv
          ON utc.TABLE_NAME = amv.MVIEW_NAME)
    SELECT DISTINCT cte.TABLE_NAME
      FROM CTE
     group by cte.TABLE_NAME
     ORDER BY 1;
     
  -- INSPEVNT source to update tables with INSPKEY column
  CURSOR curInspkeyTables IS
    WITH CTE AS
     (SELECT DISTINCT TABLE_NAME
        from USER_TAB_COLS utc
       INNER JOIN USER_OBJECTS uo
          ON (utc.TABLE_NAME = uo.OBJECT_NAME)
       where utc.COLUMN_NAME = 'INSPKEY'
         AND utc.TABLE_NAME <> 'INSPEVNT'
          AND utc.TABLE_NAME NOT LIKE 'MV_%'
          AND utc.TABLE_NAME NOT LIKE '%_MV'
         AND utc.TABLE_NAME NOT LIKE '%_TEMP'
         AND utc.TABLE_NAME NOT LIKE '%_T'
         AND utc.TABLE_NAME NOT LIKE '%_KT'
         AND utc.TABLE_NAME NOT LIKE 'ARC_%'
         AND utc.TABLE_NAME NOT LIKE '%_AR'
         AND utc.TABLE_NAME NOT LIKE '%_BACKUP'
         AND utc.TABLE_NAME NOT LIKE '%_NEW_%'
         AND utc.TABLE_NAME NOT LIKE '%_NEW'
         AND utc.TABLE_NAME NOT LIKE '%_RENAMED'
         AND utc.TABLE_NAME NOT LIKE '%_TRANSFORM'
         AND utc.TABLE_NAME NOT LIKE '%_202%'
         and uo.OBJECT_TYPE = 'TABLE'
      INTERSECT
      SELECT DISTINCT TABLE_NAME
        from USER_TAB_COLS utc
       INNER JOIN USER_OBJECTS uo
          ON (utc.TABLE_NAME = uo.OBJECT_NAME)
       where utc.COLUMN_NAME = 'INSPEVNT_GD'
         AND utc.TABLE_NAME <> 'INSPEVNT'
          AND utc.TABLE_NAME NOT LIKE 'MV_%'
          AND utc.TABLE_NAME NOT LIKE '%_MV'
         AND utc.TABLE_NAME NOT LIKE '%_TEMP'
         AND utc.TABLE_NAME NOT LIKE '%_T'
         AND utc.TABLE_NAME NOT LIKE '%_KT'
         AND utc.TABLE_NAME NOT LIKE 'ARC_%'
         AND utc.TABLE_NAME NOT LIKE '%_AR'
         AND utc.TABLE_NAME NOT LIKE '%_BACKUP'
         AND utc.TABLE_NAME NOT LIKE '%_NEW_%'
         AND utc.TABLE_NAME NOT LIKE '%_NEW'
         AND utc.TABLE_NAME NOT LIKE '%_RENAMED'
         AND utc.TABLE_NAME NOT LIKE '%_RENAMED_%'
         AND utc.TABLE_NAME NOT LIKE '%_TRANSFORM'
         AND utc.TABLE_NAME NOT LIKE '%_202%'
         and uo.OBJECT_TYPE = 'TABLE'
      MINUS
      -- exclude materialized views that may have PREBUILT tables.
      SELECT DISTINCT utc.TABLE_NAME
        from USER_TAB_COLS utc
       INNER JOIN USER_OBJECTS uo
          ON (utc.TABLE_NAME = uo.OBJECT_NAME and uo.OBJECT_TYPE = 'TABLE')
       INNER JOIN ALL_MVIEWS amv
          ON utc.TABLE_NAME = amv.MVIEW_NAME)
    SELECT DISTINCT cte.TABLE_NAME
      FROM CTE
     group by cte.TABLE_NAME
     ORDER BY 1;
     
     
  -- STRUCTURE_UNIT   
  CURSOR curStrUnitkeyTables IS
    WITH CTE AS
     (SELECT DISTINCT TABLE_NAME
        from USER_TAB_COLS utc
       INNER JOIN USER_OBJECTS uo
          ON (utc.TABLE_NAME = uo.OBJECT_NAME)
       where utc.COLUMN_NAME = 'STRUNITKEY'
         AND utc.TABLE_NAME <> 'STRUCTURE_UNIT'
          AND utc.TABLE_NAME NOT LIKE 'MV_%'
          AND utc.TABLE_NAME NOT LIKE '%_MV'
         AND utc.TABLE_NAME NOT LIKE '%_TEMP'
         AND utc.TABLE_NAME NOT LIKE '%_T'
         AND utc.TABLE_NAME NOT LIKE '%_KT'
         AND utc.TABLE_NAME NOT LIKE 'ARC_%'
         AND utc.TABLE_NAME NOT LIKE '%_AR'
         AND utc.TABLE_NAME NOT LIKE '%_BACKUP'
         AND utc.TABLE_NAME NOT LIKE '%_NEW_%'
         AND utc.TABLE_NAME NOT LIKE '%_NEW'
         AND utc.TABLE_NAME NOT LIKE '%_RENAMED'
         AND utc.TABLE_NAME NOT LIKE '%_TRANSFORM'
         AND utc.TABLE_NAME NOT LIKE '%_202%'
         and uo.OBJECT_TYPE = 'TABLE'
      INTERSECT
      SELECT DISTINCT TABLE_NAME
        from USER_TAB_COLS utc
       INNER JOIN USER_OBJECTS uo
          ON (utc.TABLE_NAME = uo.OBJECT_NAME)
       where utc.COLUMN_NAME = 'STRUCTURE_UNIT_GD'
         AND utc.TABLE_NAME <> 'STRUCTURE_UNIT'
          AND utc.TABLE_NAME NOT LIKE 'MV_%'
          AND utc.TABLE_NAME NOT LIKE '%_MV'
         AND utc.TABLE_NAME NOT LIKE '%_TEMP'
         AND utc.TABLE_NAME NOT LIKE '%_T'
         AND utc.TABLE_NAME NOT LIKE '%_KT'
         AND utc.TABLE_NAME NOT LIKE 'ARC_%'
         AND utc.TABLE_NAME NOT LIKE '%_AR'
         AND utc.TABLE_NAME NOT LIKE '%_BACKUP'
         AND utc.TABLE_NAME NOT LIKE '%_NEW_%'
         AND utc.TABLE_NAME NOT LIKE '%_NEW'
         AND utc.TABLE_NAME NOT LIKE '%_RENAMED'
         AND utc.TABLE_NAME NOT LIKE '%_RENAMED_%'
         AND utc.TABLE_NAME NOT LIKE '%_TRANSFORM'
         AND utc.TABLE_NAME NOT LIKE '%_202%'
         and uo.OBJECT_TYPE = 'TABLE'
      MINUS
      -- exclude materialized views that may have PREBUILT tables.
      SELECT DISTINCT utc.TABLE_NAME
        from USER_TAB_COLS utc
       INNER JOIN USER_OBJECTS uo
          ON (utc.TABLE_NAME = uo.OBJECT_NAME and uo.OBJECT_TYPE = 'TABLE')
       INNER JOIN ALL_MVIEWS amv
          ON utc.TABLE_NAME = amv.MVIEW_NAME)
    SELECT DISTINCT cte.TABLE_NAME
      FROM CTE
     group by cte.TABLE_NAME
     ORDER BY 1;
   
  -- and  ON_UNDER  
  CURSOR curOn_UnderTables IS
    WITH CTE AS
     (SELECT DISTINCT TABLE_NAME
        from USER_TAB_COLS utc
       INNER JOIN USER_OBJECTS uo
          ON (utc.TABLE_NAME = uo.OBJECT_NAME)
       where utc.COLUMN_NAME = 'ON_UNDER'
         AND utc.TABLE_NAME <> 'ROADWAY'
          AND utc.TABLE_NAME NOT LIKE 'MV_%'
          AND utc.TABLE_NAME NOT LIKE '%_MV'
         AND utc.TABLE_NAME NOT LIKE '%_TEMP'
         AND utc.TABLE_NAME NOT LIKE '%_T'
         AND utc.TABLE_NAME NOT LIKE '%_KT'
         AND utc.TABLE_NAME NOT LIKE 'ARC_%'
         AND utc.TABLE_NAME NOT LIKE '%_AR'
         AND utc.TABLE_NAME NOT LIKE '%_BACKUP'
         AND utc.TABLE_NAME NOT LIKE '%_NEW_%'
         AND utc.TABLE_NAME NOT LIKE '%_NEW'
         AND utc.TABLE_NAME NOT LIKE '%_RENAMED'
         AND utc.TABLE_NAME NOT LIKE '%_TRANSFORM'
         AND utc.TABLE_NAME NOT LIKE '%_202%'
         and uo.OBJECT_TYPE = 'TABLE'
      INTERSECT
      SELECT DISTINCT TABLE_NAME
        from USER_TAB_COLS utc
       INNER JOIN USER_OBJECTS uo
          ON (utc.TABLE_NAME = uo.OBJECT_NAME)
       where utc.COLUMN_NAME = 'ROADWAY_GD'
         AND utc.TABLE_NAME <> 'ROADWAY'
          AND utc.TABLE_NAME NOT LIKE 'MV_%'
          AND utc.TABLE_NAME NOT LIKE '%_MV'
         AND utc.TABLE_NAME NOT LIKE '%_TEMP'
         AND utc.TABLE_NAME NOT LIKE '%_T'
         AND utc.TABLE_NAME NOT LIKE '%_KT'
         AND utc.TABLE_NAME NOT LIKE 'ARC_%'
         AND utc.TABLE_NAME NOT LIKE '%_AR'
         AND utc.TABLE_NAME NOT LIKE '%_BACKUP'
         AND utc.TABLE_NAME NOT LIKE '%_NEW_%'
         AND utc.TABLE_NAME NOT LIKE '%_NEW'
         AND utc.TABLE_NAME NOT LIKE '%_RENAMED'
         AND utc.TABLE_NAME NOT LIKE '%_RENAMED_%'
         AND utc.TABLE_NAME NOT LIKE '%_TRANSFORM'
         AND utc.TABLE_NAME NOT LIKE '%_202%'
         and uo.OBJECT_TYPE = 'TABLE'
      MINUS
      -- exclude materialized views that may have PREBUILT tables.
      SELECT DISTINCT utc.TABLE_NAME
        from USER_TAB_COLS utc
       INNER JOIN USER_OBJECTS uo
          ON (utc.TABLE_NAME = uo.OBJECT_NAME and uo.OBJECT_TYPE = 'TABLE')
       INNER JOIN ALL_MVIEWS amv
          ON utc.TABLE_NAME = amv.MVIEW_NAME)
    SELECT DISTINCT cte.TABLE_NAME
      FROM CTE
     group by cte.TABLE_NAME
     ORDER BY 1;
  
BEGIN
  -- fix the BRKEY values
  ls_mergeFragment := q'[ ( SELECT b.BRKEY, b.BRIDGE_GD FROM BRIDGE b ) src 
                      ON ( tgt.BRIDGE_GD = src.BRIDGE_GD ) 
                        WHEN MATCHED THEN 
                        UPDATE SET tgt.BRKEY=src.BRKEY ]';
  OPEN curBrkeyTables;
  FETCH curBrkeyTables
    INTO ls_TN1;
  IF (ls_TN1 IS NOT NULL) THEN
    WHILE (curBrkeyTables%FOUND) LOOP
      BEGIN
        -- Execute immediate MERGE statement:
        ls_execSQL := q'[MERGE INTO ]' || q'[ ]' || ls_tn1 || q'[ ]' ||
                      q'[ tgt 
                      USING ]' || ls_mergeFragment;
        DBMS_OUTPUT.PUT_LINE(q'[COMMAND: ]' || ls_execSQL);
        execute immediate ls_ExecSQL;
      EXCEPTION
        WHEN OTHERS THEN
          BEGIN
            DBMS_OUTPUT.PUT_LINE(q'[COMMAND FAILED: ]' || ls_execSQL ||
                                 q'[ < ]' || SQLCODE || q'[ ]' || SQLERRM ||
                                 q'[ > ]');
            FETCH curBrkeyTables
              INTO ls_TN1;
            CONTINUE; -- just keep going and resolve problems later.
          END;
      END;
      FETCH curBrkeyTables
        INTO ls_TN1;
    END LOOP;
  END IF;
  CLOSE curBrkeyTables;
  -- fix the INSPKEY values;
  ls_mergeFragment := q'[ ( SELECT i.INSPKEY,  i.INSPEVNT_GD FROM INSPEVNT i ) src 
                      ON ( tgt.INSPEVNT_GD = src.INSPEVNT_GD )    WHEN MATCHED THEN 
                        UPDATE SET tgt.INSPKEY=src.INSPKEY ]';
  OPEN curInspkeyTables;
  FETCH curInspkeyTables
    INTO ls_TN1;
  IF (ls_TN1 IS NOT NULL) THEN
    WHILE (curInspkeyTables%FOUND) LOOP
      BEGIN
        -- Execute immediate MERGE statement:
        ls_execSQL := q'[MERGE INTO ]' || q'[ ]' || ls_tn1 || q'[ ]' ||
                      q'[ tgt 
                      USING ]' || ls_mergeFragment;
        DBMS_OUTPUT.PUT_LINE(q'[COMMAND: ]' || ls_execSQL);
        execute immediate ls_ExecSQL;
      EXCEPTION
        WHEN OTHERS THEN
          BEGIN
            DBMS_OUTPUT.PUT_LINE(q'[COMMAND FAILED: ]' || ls_execSQL ||
                                 q'[ < ]' || SQLCODE || q'[ ]' || SQLERRM ||
                                 q'[ > ]');
            FETCH curInspkeyTables
              INTO ls_TN1;
            CONTINUE; -- just keep going and resolve problems later.
          END;
      END;
      FETCH curInspkeyTables
        INTO ls_TN1;
    END LOOP;
  END IF;
  CLOSE curInspkeyTables;
  -- fix the STRUNITKEY values;
  ls_mergeFragment := q'[ ( SELECT su.STRUNITKEY, su.STRUCTURE_UNIT_GD FROM STRUCTURE_UNIT su ) src 
                      ON ( tgt.STRUCTURE_UNIT_GD  = src.STRUCTURE_UNIT_GD )    WHEN MATCHED THEN 
                        UPDATE SET tgt.STRUNITKEY = src.STRUNITKEY ]';
  OPEN curStrunitKeyTables;
  FETCH curStrunitKeyTables
    INTO ls_TN1;
  IF (ls_TN1 IS NOT NULL) THEN
    WHILE (curStrunitKeyTables%FOUND) LOOP
      BEGIN
        -- Execute immediate MERGE statement:
        ls_execSQL := q'[MERGE INTO ]' || q'[ ]' || ls_tn1 || q'[ ]' ||
                      q'[ tgt 
                      USING ]' || ls_mergeFragment;
        DBMS_OUTPUT.PUT_LINE(q'[COMMAND: ]' || ls_execSQL);
        execute immediate ls_ExecSQL;
      EXCEPTION
        WHEN OTHERS THEN
          BEGIN
            DBMS_OUTPUT.PUT_LINE(q'[COMMAND FAILED: ]' || ls_execSQL ||
                                 q'[ < ]' || SQLCODE || q'[ ]' || SQLERRM ||
                                 q'[ > ]');
            FETCH curInspkeyTables
              INTO ls_TN1;
            CONTINUE; -- just keep going and resolve problems later.
          END;
      END;
      FETCH curStrunitKeyTables
        INTO ls_TN1;
    END LOOP;
  END IF;
  CLOSE curStrunitKeyTables;
  -- fix the ON_UNDER values;
  ls_mergeFragment := q'[ ( SELECT rw.ON_UNDER, rw.ROADWAY_GD FROM ROADWAY rw ) src 
                      ON ( tgt.ROADWAY_GD  = src.ROADWAY_GD )    WHEN MATCHED THEN 
                        UPDATE SET tgt.ON_UNDER = src.ON_UNDER ]';
  OPEN curOn_UnderTables; 
  FETCH curOn_UnderTables
    INTO ls_TN1;
  IF (ls_TN1 IS NOT NULL) THEN
    WHILE (curOn_UnderTables%FOUND) LOOP
      BEGIN
        -- Execute immediate MERGE statement:
        ls_execSQL := q'[MERGE INTO ]' || q'[ ]' || ls_tn1 || q'[ ]' ||
                      q'[ tgt 
                      USING ]' || ls_mergeFragment;
        DBMS_OUTPUT.PUT_LINE(q'[COMMAND: ]' || ls_execSQL);
        execute immediate ls_ExecSQL;
      EXCEPTION
        WHEN OTHERS THEN
          BEGIN
            DBMS_OUTPUT.PUT_LINE(q'[COMMAND FAILED: ]' || ls_execSQL ||
                                 q'[ < ]' || SQLCODE || q'[ ]' || SQLERRM ||
                                 q'[ > ]');
            FETCH curOn_UnderTables
              INTO ls_TN1;
            CONTINUE; -- just keep going and resolve problems later.
          END;
      END;
      FETCH curOn_UnderTables
        INTO ls_TN1;
    END LOOP;
  END IF;
  CLOSE curOn_UnderTables;
  
  
  COMMIT; -- for all of the work.  This could be done column-by-column


EXCEPTION
  WHEN OTHERS THEN
    BEGIN
      ROLLBACK; -- rollback all of the work.  This could be done column-by-column
      RAISE_APPLICATION_ERROR(-20999,
                              q'[ ERROR: ]' || SQLCODE || q'[ ]' || SQLERRM);
    END;
END;
0
1
ls_execSQL
