CREATE OR REPLACE FUNCTION f_get_insptype_for_brkey_inspkey (
    v_brkey   IN inspevnt.brkey%TYPE,
    v_inspkey IN inspevnt.inspkey%TYPE
) RETURN 
inspevnt.insptype%TYPE IS
    functionresult inspevnt.insptype%TYPE;
-- %return the INSPEVNT.INSPTYPE value (A or I) for a combination of BRKEY and INSPKEY     
-- %author C. Golledge, Auctor - 20230202
-- null checks added by ARMarshall, ARM LLC - 20230203
-- these error numbers for RAISE_APPLICATION_ERROR are arbitrary in the allowed range -20000 to -20999.
-- %param v_brkey - the brkey for which INSPTYPE Is needed
-- %param v_inspkey  - the inspkey of the particular inspection for the bridge based on BRKEY


BEGIN

    if (v_brkey is null) THEN

    RAISE_APPLICATION_ERROR(-20980,q'[The BRKEY argument cannot be NULL for FUNCTION f_get_insptype_for_brkey_inspkey ]');
    end if;

    if (v_inspkey is null) THEN

    RAISE_APPLICATION_ERROR(-20985,q'[The INSPKEY argument cannot be NULL for FUNCTION f_get_insptype_for_brkey_inspkey ]');
    end if;

    SELECT
        i.insptype
    INTO functionresult
    FROM
        inspevnt i
    WHERE
            i.brkey = v_brkey
        AND i.inspkey = v_inspkey;

    RETURN ( functionresult );
EXCEPTION
    WHEN no_data_found THEN
        RETURN NULL;
    WHEN OTHERS THEN
        RAISE;
END f_get_insptype_for_brkey_inspkey;
/
