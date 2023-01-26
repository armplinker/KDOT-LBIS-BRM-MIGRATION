CREATE OR REPLACE FUNCTION f_Get_Pon_App_Users_Gd_For_Userkey(The_Userkey Pon_App_Users.Userkey%TYPE)
  RETURN PON_APP_USERS.PON_APP_USERS_GD%Type IS
/*
-- FOR A GIVEN PON_APP_USERS_GD, RETURN THE USERKEY FROM PON_APP_USERS_GD\
-- RETURNS -1 IF NULL OR NOT FOUND
-- complementary function to f_get_USERKEY_For_PON_APP_USERS_GD
-- created bt ARMarshall, ARM LLC , 20230123 - as part of BrM DB Migration 6.x 2023
*/ 
 Functionresult     VARCHAR2(32);
  Lex_Null_Userkey_Failed EXCEPTION;

BEGIN
 
  IF The_Userkey IS NULL
  THEN
    RAISE Lex_Null_Userkey_Failed;
  END IF;
  
  SELECT Nvl(pau.PON_APP_USERS_GD,'?') -- '' indicates MISSING - FIX
    INTO Functionresult
    FROM Pon_App_Users Pau
   WHERE Pau.Userkey = The_Userkey; -- need the brkey for below, but these should be checking against the GUID
  IF (Functionresult = '?')
  THEN
    Functionresult := NULL;
    Kdot_Blp_Util.p_Log(q'[NULL PON_APP_USERS_GD SET TO '?' FOR PON_APP_USERS.USERKEY = ]' ||
                        Nvl(The_Userkey, -1));
  END IF;
   RETURN(Functionresult);
  -- EXCEPTION HANDLERS BELOW HERE
EXCEPTION
  WHEN Lex_Null_Userkey_Failed THEN
    Kdot_Blp_Util.p_Log(q'[PARAMETER The_Userkey (PON_APP_USERS.USERKEY)) IS NULL - NOT ALLOWED ]');
  WHEN No_Data_Found THEN
    BEGIN
      Functionresult := -1; -- indicates MISSING - FIX -
      Kdot_Blp_Util.p_Log(q'[MISSING PON_APP_USERS_GD SET TO '?' FOR PON_APP_USERS.USERKEY = ]' ||
                           Nvl(The_Userkey, -1)  || Utl_Tcp.Crlf ||
                          q'[Value of PON_APP_USERS_GD set to ]' ||
                          NVL(Functionresult,'NULL') ); -- indicates MISSING - FIX -);
    END;
  WHEN OTHERS THEN
    BEGIN
      RAISE; -- this maybe should use one of the exceptions defined in the packag KDOT_BLP_ERRORS...
    END;
    RETURN(Functionresult);
END f_Get_Pon_App_Users_Gd_For_Userkey;
/
