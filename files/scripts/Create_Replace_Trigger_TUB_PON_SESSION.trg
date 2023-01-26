CREATE OR REPLACE TRIGGER Tub_Pon_Session
  BEFORE INSERT ON Kdot_Blp.Pon_Session
  FOR EACH ROW
/*
  This trigger  generates an entry in PON_SESSION when a user connects and an ASP.NET Session is created.  It uses either the INCOMING session_Key integer or a value taken from an Oracle SEQUENCE for SESSION_KEY.  I found that this was misbehaving when I wrapped the call with a 'transaction' so it has been updated.  Every session for every user should appear in PON_SESSION with a STARTED_ON and (after logout) ENDED_ON. 
  The pon_session_gd value is taken directly from the website's Session object.
*/
BEGIN
  SELECT CASE
           WHEN :New.Pon_Session_Key IS NULL OR :New.Pon_Session_Key <= 0 THEN
            s_Pon_Session.Nextval
           ELSE
            :New.Pon_Session_Key
         END
  --- CALLING ROUTINE MUST PROVIDE A VALID WEB SESSION ID e.g. Session.SessionID in asp.net
  /*  ,CASE
    When Trim( NVL( :New.Pon_Session_Gd,''))  = '' THEN
     Rawtohex(Sys_Guid()) -- so it is a string
    ELSE
     :New.Pon_Session_Gd
  END*/
    INTO :New.Pon_Session_Key /*, :New.Pon_Session_Gd*/
    FROM Dual;
  -- for more formatting info, see this: http://www.morganslibrary.org/reference/convert_func.html  
  Dbms_Output.Put_Line('New PON_SESSION record with session ID: ' ||
                       :New.Pon_Session_Key || ' - Session GUID: (' ||
                       :New.Pon_Session_Gd || ') created for user ' ||
                       :new.userkey || ' at ' ||
                       to_Char(sysdate, 'YYYY-MM-DD HH24:MI:SS.SSSSS'));

EXCEPTION
  WHEN No_Data_Found THEN
    NULL;
  WHEN OTHERS THEN
    RAISE;
END;
/
