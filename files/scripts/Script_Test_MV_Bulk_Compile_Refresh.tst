PL/SQL Developer Test script 3.0
85
DECLARE

  CURSOR curMVCompileNames IS 
  SELECT amv.MVIEW_NAME            
  FROM ALL_MVIEWS amv
 WHERE amv.owner = 'KDOT_BLP'
   and amv.COMPILE_STATE = 'NEEDS_COMPILE';
          
  CURSOR curMVValidNames IS 
  SELECT LISTAGG( amv.MVIEW_NAME , q'[,]') WITHIN GROUP (ORDER BY CASE
  WHEN UPPER(amv.mview_name) = 'MV_LATEST_INSPECTION' THEN
  '1'
  ELSE
  CASE
  WHEN UPPER(amv.mview_name) LIKE 'MV_LATEST%' THEN
  '2' || UPPER(amv.mview_name)
  ELSE
  3 || UPPER(amv.mview_name)
  END
  END) AS VALID_MVIEW_NAMES
  FROM ALL_MVIEWS amv
  WHERE amv.owner = 'KDOT_BLP'
  and amv.COMPILE_STATE = 'VALID';
  
  
v_MVN1 VARCHAR2(32767);


BEGIN

  DBMS_OUTPUT.PUT_LINE(q'[Get the MV names where compile state = 'NEEDS_COMPILE']');

  OPEN curMVCompileNames;
  FETCH  curMVCompileNames 
    INTO v_MVN1;
     
     IF NOT (V_MVN1 IS NULL) THEN
       
     DBMS_OUTPUT.PUT_LINE(q'[RECOMPILING INVALID MVIEW ]' || v_MVN1 );
     
  WHILE (curMVCompileNames%FOUND) LOOP
    BEGIN
      --v_MVN1:=q'[']'|| v_MVN1 || q'[']';
      --dbms_MVIEW.refresh(list=> v_MVN1 ,atomic_refresh=>  false, parallelism=> 4, method=> '?');

      EXECUTE IMMEDIATE q'[ALTER MATERIALIZED VIEW ]' ||'  ' ||  V_MVN1 || '  ' || q'[ COMPILE]' ||'  ';
      -- refresh each one on a schedule tomorrow at 3AM and every night thereafter at 3AM      
      EXECUTE IMMEDIATE  q'[ALTER MATERIALIZED VIEW ]' ||'  ' ||  V_MVN1 || '  ' || q'[
                REFRESH FORCE COMPLETE   
                START WITH TRUNC(SYSDATE+1) + 3/24  
                NEXT (SYSDATE+1) + 3/24 ]';
    END;
    FETCH curMVCompileNames
      INTO v_MVN1;
  END LOOP;
END IF;

  CLOSE curMVCompileNames;

  v_MVN1 := '';

  DBMS_OUTPUT.PUT_LINE(q'[Get the MV names where compile state = 'VALID']');

  OPEN curMVValidNames;
  FETCH  curMVValidNames 
    INTO v_MVN1;
     IF NOT (V_MVN1 IS NULL) THEN
  DBMS_OUTPUT.PUT_LINE(v_MVN1);
  WHILE (curMVValidNames%FOUND) LOOP
    BEGIN
    --   v_MVN1:=q'[']'|| v_MVN1 || q'[']';
    
    -- refresh them all right now
     dbms_MVIEW.refresh(list=> v_MVN1 , atomic_refresh=>  false, parallelism=> 4, method=> '?');

    END;
    FETCH curMVValidNames
      INTO v_MVN1;
  END LOOP;
END IF;
  CLOSE curMVValidNames;

END;

 
0
1
curMVCompileNames
