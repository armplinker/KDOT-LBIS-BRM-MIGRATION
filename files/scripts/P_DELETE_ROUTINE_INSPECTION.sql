CREATE OR REPLACE PROCEDURE p_delete_routine_inspection (
    v_brkey    IN VARCHAR2,
    v_inspkey  IN VARCHAR2,
    v_reason   IN VARCHAR2,
    v_username IN VARCHAR2,
    v_errmsg   OUT VARCHAR2
) IS 
--variable declaration
    ls_insptype          inspevnt.insptype%TYPE;
    ls_inspevnt_gd       inspevnt.inspevnt_gd%TYPE;
    ls_message           VARCHAR2(4000);
    ls_recipient         VARCHAR2(512);
    ls_subject           VARCHAR2(255);
    ls_dbname            VARCHAR2(30);
    ls_rowsdeleted       INT;
    ls_emailfailed       BOOLEAN;
    ls_kdotblp_documents VARCHAR2(4000);
BEGIN
    --get KDOTBLP document list
    ls_kdotblp_documents := f_get_kdotblp_documents(
                                                   v_brkey,
                                                   v_inspkey
                            );

   --get inspevnt_gd on basis of brKey and inspkey
    ls_inspevnt_gd := f_get_inspevnt_gd_for_brkey_inspkey(
                                                         v_brkey,
                                                         v_inspkey
                      );

    --delete records on basis of InspEvnt_GD
    
    --KDOTBLP_DOCUMENTS
    DELETE FROM kdotblp_documents
    WHERE
        inspevnt_gd = ls_inspevnt_gd;
        
    --PON_ASSESSMENT
    DELETE FROM pon_assessment
    WHERE
        inspevnt_gd = ls_inspevnt_gd;
        
        --PON_ELEM_INSP
    DELETE FROM pon_elem_insp
    WHERE
        inspevnt_gd = ls_inspevnt_gd;
        
        --PON_INSP_STATUS_LOG
    DELETE FROM pon_insp_status_log
    WHERE
        inspevnt_gd = ls_inspevnt_gd;
        
        --PON_INSP_WORKCAND
    DELETE FROM pon_insp_workcand
    WHERE
        inspevnt_gd = ls_inspevnt_gd;

    --KDOTBLP_INSPECTIONS
    DELETE FROM kdotblp_inspections
    WHERE
        inspevnt_gd = ls_inspevnt_gd;    
        
    DELETE FROM inspevnt
    WHERE
        inspevnt_gd = ls_inspevnt_gd;

    --check count for confirmation of deletion - whether deleted or not
    -- this rowcount should be 0 or 1.  Greater than 1 is a problem?
    
    IF ( SQL%rowcount > 0 ) THEN
        ls_rowsdeleted := SQL%rowcount;
        --dbms_output.put_line(ls_rowsdeleted);
    END IF;

    COMMIT;

--Send email
    ls_recipient := kdot_blp_util.f_get_coption_value(
                                                     'KDOT_BLP_DATAMANAGER_EMAIL',
                                                     'KBLP_INBOX@ksdot.org'
                    );

------------------------------------------------- SUBBLOCK Get_DB_Name
    << get_db_name >> BEGIN
        SELECT
            upper(
                nvl(
                    TRIM(sys_context(
                        q'[USERENV]', q'[DB_NAME]'
                    )), 'UNK DB'
                )
            )
        INTO ls_dbname -- database name
        FROM
            dual;

    EXCEPTION
        WHEN OTHERS THEN
            RAISE;
    END get_db_name;

    --dbms_output.put_line(ls_dbname);
    ------------------------------------------------- END SUBBLOCK
        --ls_recipient := q'[repalp@auctor.com]';
    ls_subject := 'Bridge inspection deleted by '
                  || v_username
                  || ', deleted from database '
                  || ls_dbname
                  || ', deleted on '
                  || to_char(
                            sysdate,
                            'DD-MM-YYYY HH:MM:SS'
                     );

    ls_message := 'Bridge inspection deleted from ' || ls_dbname;
    ls_message := ls_message || kdot_blp_util.crlf;
    ls_message := ls_message
                  || 'Details : '
                  || kdot_blp_util.crlf
                  || ' BrKey:'
                  || v_brkey
                  || kdot_blp_util.crlf
                  || ' InspKey:'
                  || v_inspkey
                  || kdot_blp_util.crlf
                  || ' Reason for delete:'
                  || v_reason
                  || kdot_blp_util.crlf;

    IF ( ls_kdotblp_documents IS NOT NULL ) THEN
        ls_message := ls_message
                      || 'KDOTBLP Document details :'
                      || kdot_blp_util.crlf
                      || ls_kdotblp_documents;
    END IF;
    --dbms_output.put_line(ls_subject);
    --dbms_output.put_line(ls_message);
  
-- BEGIN email
    BEGIN
        ls_emailfailed := kdot_blp_util.f_email(
                                               ls_recipient,
                                               ls_message,
                                               ls_subject
                          );
        IF (
            ls_emailfailed = true
            AND ls_rowsdeleted > 0
        ) THEN
            v_errmsg := 'Bridge Inspection deleted successfully but Administrator email send attempt failed';
            kdot_blp_util.p_log('Mail send failed because an exception was raised in f_sendmail ' || sqlerrm);
        ELSIF (
            ls_rowsdeleted > 0
            AND ls_emailfailed = false
        ) THEN
            v_errmsg := 'Bridge Inspection Deleted Successfully';
        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            RAISE;
    END;

    --dbms_output.put_line(v_errmsg);
EXCEPTION
    WHEN OTHERS THEN
        BEGIN
            RAISE;
        END;
END p_delete_routine_inspection;
/
