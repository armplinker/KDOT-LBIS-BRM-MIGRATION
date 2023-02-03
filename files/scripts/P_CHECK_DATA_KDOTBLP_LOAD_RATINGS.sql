create or replace PROCEDURE p_check_data_kdotblp_load_ratings (
    v_brkey   IN VARCHAR2,
    v_inspkey IN VARCHAR2,
    v_count   OUT INT
) IS 
--variable declaration
    ls_message     VARCHAR2(4000);
    ls_recipient   VARCHAR2(512);
    recordcount    INT;
    recordcount1   INT;
    ls_subject     VARCHAR2(255);
    ls_dbname      VARCHAR2(30);
    ls_emailfailed BOOLEAN;
 
   -- C. Golledge, Auctor - 20230202
    -- for a combination of BRKEY and INSPKEY, see if there are any load ratings entries that have this combination
    -- null checks added by ARMarshall, ARM LLC - 20230203
    -- these error numbers for RAISE_APPLICATION_ERROR are arbitrary in the allowed range -20000 to -20999.
BEGIN
   
    if (v_brkey is null) THEN
   
    RAISE_APPLICATION_ERROR(-20980,q'[The BRKEY argument cannot be NULL for FUNCTION f_get_insptype_for_brkey_inspkey ]');
    end if;
    
    if (v_inspkey is null) THEN
     
    RAISE_APPLICATION_ERROR(-20985,q'[The INSPKEY argument cannot be NULL for FUNCTION f_get_insptype_for_brkey_inspkey ]');
    end if;
    
-- check data is present in KDOTBLP_LOAD_RATINGS
    SELECT
        COUNT(*)
    INTO v_count
    FROM
        kdotblp_load_ratings
    WHERE
            brkey = v_brkey
        AND inspkey = v_inspkey;

    --dbms_output.put_line(recordcount);
    IF ( v_count > 0 ) THEN
    --Send mail
        Ls_Recipient := Kdot_Blp_Util.f_Get_Coption_Value('KDOT_BLP_DATAMANAGER_EMAIL'
                                                     ,'KBLP_INBOX@ksdot.org');
        --ls_recipient := q'[repalp@auctor.com]';

        ls_subject := 'Bridge Inspection Deletion';
        ls_message := 'A request to delete an inspection was made, but that request was rejected because there are load ratings associated with BRKEY '
                      || v_brkey
                      || ' and INSPKEY '
                      || v_inspkey;
        --dbms_output.put_line(ls_subject);
        --dbms_output.put_line(ls_message);
        IF ( kdot_blp_util.f_email(ls_recipient, ls_message, ls_subject) ) THEN
            kdot_blp_util.p_log('Mail send failed because an exception was raised in f_sendmail ' || sqlerrm);
        END IF;

    END IF;
    
    -- ARM - Added exception block
    
EXCEPTION
    WHEN no_data_found THEN
          NULL; -- do nothing! 
    WHEN OTHERS THEN
        RAISE;

END p_check_data_kdotblp_load_ratings;
/
