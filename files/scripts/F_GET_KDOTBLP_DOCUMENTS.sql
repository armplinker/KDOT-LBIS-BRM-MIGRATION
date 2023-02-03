create or replace FUNCTION f_get_kdotblp_documents(v_brkey   IN inspevnt.brkey%TYPE,
                                                   v_inspkey IN inspevnt.inspkey%TYPE)
  RETURN VARCHAR2 IS
  functionresult VARCHAR2(4000);
  -- C. Golledge, Auctor - 20230202
  -- for a combination of BRKEY and INSPKEY, return a comma-separated list of KDOTBLP_DOCUMENTS related to the inspection
  -- null checks added by ARMarshall, ARM LLC - 20230203
  -- truncated result to 3999 if excessive BEFORE assigning to return variable functionresult.
  -- these error numbers for RAISE_APPLICATION_ERROR are arbitrary in the allowed range -20000 to -20999.
BEGIN
  if (v_brkey is null) THEN
    RAISE_APPLICATION_ERROR(-20980,
                            q'[The BRKEY argument cannot be NULL for FUNCTION f_get_insptype_for_brkey_inspkey ]');
  end if;
  if (v_inspkey is null) THEN
    RAISE_APPLICATION_ERROR(-20985,
                            q'[The INSPKEY argument cannot be NULL for FUNCTION f_get_insptype_for_brkey_inspkey ]');
  end if;
  SELECT SUBSTR(LISTAGG(source_file_name || CHR(9) || target_file_name,
                        CHR(13) || CHR(10)) WITHIN
                GROUP(ORDER BY target_file_name),
                1,
                3999) doc_list
    INTO functionresult
    FROM kdotblp_documents
   WHERE brkey = v_brkey
     AND inspkey = v_inspkey;
  RETURN(functionresult);
EXCEPTION
  WHEN no_data_found THEN
    RETURN NULL;
  WHEN OTHERS THEN
    RAISE;
END f_get_kdotblp_documents;
/
