CREATE OR REPLACE PACKAGE "KDOT_BLP_BRM_UTIL" IS
    -- For f_random_float() and f_random_integer()
    m  CONSTANT NUMBER := 100000000; /* initial conditions */
    M1 CONSTANT NUMBER := 10000; /* (for best results) */
    b  CONSTANT NUMBER := 31415821; /*                    */
    a NUMBER; /* seed */

    Cs_BrM_Admin_Group_Codes VARCHAR2(255) := q'[|3|15003|15503|]';

    Cs_BrM_Missing_Values CONSTANT VARCHAR2(80) := '|!|_|>|<|#|&|/|~|+|}|{|?|@|-1|-2|-3|-4|-5|-6|-7|-8|-9|-10|-11|-12|-13|';

    Gs_Default_Userkey Pon_App_Users.Userkey%TYPE;
    Gs_Default_Userid  Pon_App_Users.Userid%TYPE;

    --------------------------------------------------------------------------------
    -- Utility functions, that could be moved to a more generic package

    --------------------------------------------------------------------------------
    PROCEDURE Pl( --ARM 1/8/2002 lots of work here to improve word wrap behavior and so on.  If used judiciously with reasonable input lines, this procedure
                 -- will format over-long messages pretty nicely to fit on a variable widht screen output.
                 Str       IN VARCHAR2
                ,Len       IN PLS_INTEGER := 80
                ,Expand_In IN BOOLEAN := TRUE);
    -- Return the time formatted rather precisely
    FUNCTION f_Now(p_Fmt IN VARCHAR2 := q'[YYYY-MM-DD HH24:MI:SS]')
        RETURN VARCHAR2;

    FUNCTION Sq(String_Arg IN VARCHAR2) -- enclose striung in quotes
     RETURN VARCHAR2;

    FUNCTION Dq(String_Arg IN VARCHAR2) -- enclose in double quotes (typically Oracle object names )
     RETURN VARCHAR2;

    FUNCTION f_Get_Table_Owner(Name_In IN Sys.All_Tables.Table_Name%TYPE)
        RETURN Sys.All_Tables.Owner%TYPE;

    FUNCTION f_Get_View_Owner(Name_In IN Sys.All_Views.View_Name%TYPE)
        RETURN Sys.All_Views.Owner%TYPE;

    FUNCTION Istable(The_Table IN Sys.All_Tables.Table_Name%TYPE)
        RETURN BOOLEAN;

    FUNCTION Istableorview(The_Table IN Sys.All_Tables.Table_Name%TYPE)
        RETURN BOOLEAN;

    FUNCTION f_Is_Table(Name_In IN Sys.All_Tables.Table_Name%TYPE)
        RETURN BOOLEAN;

    FUNCTION f_Is_View(Name_In IN Sys.All_Views.View_Name%TYPE) RETURN BOOLEAN;

    -- print a CLOB to DBMS_OUTPUT - may be ugly line breaks
    PROCEDURE p_Print_Clob(p_Clob IN CLOB);

    PROCEDURE Count_Rows_For_Table(The_String_In    IN VARCHAR2
                                  ,The_Where_Clause IN VARCHAR2
                                  ,The_Mode         IN VARCHAR2
                                  ,The_Count        OUT PLS_INTEGER
                                  ,The_Error        OUT BOOLEAN);

    FUNCTION f_Any_Rows_Exist(The_Stringarg_In IN VARCHAR2
                             ,The_Where_Clause IN VARCHAR2) RETURN BOOLEAN;

    /* VARIANT - Pass well-formed SQL statement, get count back - RETURNS TRUE on FAILURE (bad SQL)
    || Pass a (presumably  valid ) SELECT statement with SELECT 1  as a string, get back 1 if any exist, 0 if none, returns TRUE on failure
    || can take a SELECT of any complexity up to 500 chars in length
    || During development, test SQL in an SQL before using in code
    || This variant does not use a where clause...
    || usage: select fw.any_rows_in_table( 'SELECT 1 FROM BRIDGE b, ELEMINSP e WHERE b,BRKEY ='||fw.sq('AAQ') || ' AND b.brkey = e.elemkey ', rows_exist ) from DUAL;
    */
    FUNCTION f_Any_Rows_Exist(The_Stringarg_In IN VARCHAR2) RETURN BOOLEAN;

    FUNCTION Random RETURN PLS_INTEGER;

    -- Used by f_random_integer() and f_random_float()
    FUNCTION Mult(p IN NUMBER
                 ,q IN NUMBER) RETURN NUMBER;

    -- Returns an integer between [0, r-1]
    FUNCTION f_Random_Integer(r IN NUMBER) RETURN NUMBER;

    -- Returns random real between [0, 1] 
    FUNCTION f_Random_Float RETURN NUMBER;

    FUNCTION f_Random(p_Lowerlim IN PLS_INTEGER := 0
                     ,Numdigits  IN PLS_INTEGER) RETURN PLS_INTEGER;

    FUNCTION Random(Numdigits IN PLS_INTEGER) RETURN PLS_INTEGER;

    -- Returns TRUE if the passed varchar2 is NULL or (after trimming) has length zero
    -- The 'ns' in 'f_ns' stands for 'Not String'.
    FUNCTION f_Ns(Psi_String IN VARCHAR2) RETURN BOOLEAN;

    FUNCTION f_Numbers_Differ(Oldnum1           IN VARCHAR2
                             ,Newnum2           IN VARCHAR2
                             ,Precision_Limit   IN DOUBLE PRECISION := NULL
                             ,Notify_On_Missing IN BOOLEAN := TRUE)
        RETURN BOOLEAN;

    -- Returns 'TRUE' or 'FALSE' so Boolean values can be displayed as strings
    FUNCTION f_Boolean_To_String(p_Boolean IN BOOLEAN) RETURN VARCHAR2;

    FUNCTION Isnumbertest(p_Teststring IN VARCHAR2) RETURN BOOLEAN;

    PROCEDURE Isnumber(p_Stringvalue     IN VARCHAR2
                      ,p_Messagetext     IN VARCHAR2
                      ,p_Raise_Exception IN BOOLEAN := TRUE
                      ,p_Exception       IN VARCHAR2 := 'VALUE_ERROR');

    PROCEDURE Istrue(p_Testvalue       IN BOOLEAN
                    ,p_Messagetext     IN VARCHAR2
                    ,p_Raise_Exception IN BOOLEAN := TRUE
                    ,p_Exception       IN VARCHAR2 := 'VALUE_ERROR');

    PROCEDURE Isnotnull(p_Stringvalue     IN VARCHAR2
                       ,p_Messagetext     IN VARCHAR2
                       ,p_Raise_Exception IN BOOLEAN := TRUE
                       ,p_Exception       IN VARCHAR2 := 'VALUE_ERROR');

    PROCEDURE Isnotnull(p_Datevalue       IN DATE
                       ,p_Messagetext     IN VARCHAR2
                       ,p_Raise_Exception IN BOOLEAN := TRUE
                       ,p_Exception       IN VARCHAR2 := 'VALUE_ERROR');

    PROCEDURE Isnotnull(p_Numbervalue     IN NUMBER
                       ,p_Messagetext     IN VARCHAR2
                       ,p_Raise_Exception IN BOOLEAN := TRUE
                       ,p_Exception       IN VARCHAR2 := 'VALUE_ERROR');

    PROCEDURE Isnotnull(p_Testvalue       IN BOOLEAN
                       ,p_Messagetext     IN VARCHAR2
                       ,p_Raise_Exception IN BOOLEAN := TRUE
                       ,p_Exception       IN VARCHAR2 := 'VALUE_ERROR');

    -- assert that string argument is a number, or raise exception
    PROCEDURE Isnumber(p_Teststring      IN VARCHAR2
                      ,p_Messagetext     IN VARCHAR2 := ''
                      ,p_Raise_Exception IN BOOLEAN := TRUE
                      ,p_Exception       IN VARCHAR2 := 'VALUE_ERROR');

    FUNCTION Isnumber(The_Token_In IN VARCHAR2) RETURN BOOLEAN;

    FUNCTION f_Is_Bridge_GD(p_Bridge_GD IN Bridge.Bridge_GD%TYPE)
    -- Returns TRUE if the passed string is a valid BRIDGE_GD
     RETURN BOOLEAN;

    FUNCTION f_Get_BrM_Admin_Group_Codes RETURN VARCHAR2;

    -- Returns the pon_app_users.userkey that corresponds to the (Oracle) 'user',
    -- if any, else returns the minimum userkey (so at least it's valid)
    FUNCTION f_Get_Users_Userkey RETURN VARCHAR2;
    -- this variable is for INSERTS to the table DATASYNC_CHANGE_LOG, column status
    --gs_default_exchange_log_status   ds_exchange_status.status_label%TYPE;

    FUNCTION f_Get_p_a_Users_Gd_For_Userid(p_Userid IN Pon_App_Users.Userid%TYPE)
        RETURN Pon_App_Users.Pon_App_Users_GD%TYPE;

    FUNCTION f_Get_p_a_Users_Gd_For_Userkey(p_Userkey IN Pon_App_Users.Userkey%TYPE)
        RETURN Pon_App_Users.Pon_App_Users_GD%TYPE;

    FUNCTION f_Get_Userkey_For_Orauser(The_User IN VARCHAR2)
    -- Allen 7/27/2001
     RETURN Pon_App_Users.Userkey%TYPE;

    FUNCTION f_Bridge_Exists_For_Bridge_GD(p_Bridge_GD IN Bridge.Bridge_GD%TYPE)
        RETURN BOOLEAN;

    FUNCTION f_Bridge_Exists_For_Brkey(p_Brkey IN Bridge.Brkey%TYPE)
        RETURN BOOLEAN;

    FUNCTION f_Bridge_Exists_For_Bridge_Id(p_Bridge_Id IN Bridge.Bridge_Id%TYPE)
        RETURN BOOLEAN;

    -- cannot be called from sql without converting the boolean return
    FUNCTION f_Bridge_Exists(p_Bridge_GD IN Bridge.Bridge_GD%TYPE)
        RETURN BOOLEAN;

    -- callable from SQL:
    FUNCTION f_Sql_Bridge_Exists(p_Bridge_GD IN Bridge.Bridge_GD%TYPE)
        RETURN INTEGER;

    FUNCTION f_Gen_Pontis_Inspkey(p_Brkey IN Bridge.Brkey%TYPE)
        RETURN Inspevnt.Inspkey%TYPE; -- VARCHAR(4)

    FUNCTION f_Get_On_Under_Rank(p_On_Under IN Roadway.On_Under%TYPE)
        RETURN PLS_INTEGER;

    FUNCTION f_Gen_BrM_Inspkey_4_Bridge_Gd(p_Bridge_GD IN Bridge.Bridge_GD%TYPE)
        RETURN Inspevnt.Inspkey%TYPE;

    FUNCTION f_Gen_BrM_Inspkey_4_Brkey(p_Brkey IN Bridge.Brkey%TYPE)
        RETURN Inspevnt.Inspkey%TYPE;

    FUNCTION f_Gen_BrM_On_Under(p_Bridge_GD IN Bridge.Bridge_GD%TYPE)
        RETURN Roadway.On_Under%TYPE;

    FUNCTION f_Gen_Pontis_On_Under(p_Brkey IN Bridge.Brkey%TYPE)
        RETURN Roadway.On_Under%TYPE;

    FUNCTION f_Get_Last_Insp_By_Type(p_Bridge_GD IN Bridge.Bridge_GD%TYPE
                                    ,p_Insptype  IN VARCHAR := NULL)
        RETURN Inspevnt.Inspevnt_GD%TYPE;

    -- 32 character key used for BRIDGE.DOCREFKEY for example, or any other place a unique key is needed.
    -- depends on pontis_rowkey_seq sequence.

    FUNCTION f_Gen_Pontis_Rkey RETURN VARCHAR2; -- because for 12.2 the length of object names is <=128

    FUNCTION f_Get_Nbi_Cd_Fr_Kdot_Unit_Type(v_Unit_Type Userstrunit.Unit_Type%TYPE)
        RETURN PLS_INTEGER;

    -- gets comma separated list of KDOT codes back.
    -- should be 1 string of possibly several values that have to be parsed by the calling routine
    /*
    FUNCTION f_Get_Kdotcode_From_Nbilookup(p_Table_Name IN User_Tables.Table_Name%TYPE
                                          ,p_Field_Name IN User_Tab_Cols.Column_Name%TYPE
                                          ,p_Nbi_Code   IN Nbilookup.Nbi_Code%TYPE)
        RETURN VARCHAR2;*/

   /* FUNCTION Recode_Designload(
                               -- Allen 5/17/2001
                               --pDesignLoad_Type, pDesignLoad_KDOT ON USERBRDG
                               -- CHANGE USERBRDG table NAME IF NECESSARY
                               -- Anchored by %TYPE
                               -- Added exception handling, messages to explain problemn
                               -- returns null if it fails - test for null in calling trigger
                               
                               -- arguments
                               Pdesignload_Type IN Userbrdg.Designload_Type%TYPE
                              ,Pdesignload_Kdot IN Userbrdg.Designload_Kdot%TYPE
                              ,Pnullallowed     IN BOOLEAN) RETURN NUMBER;*/

    FUNCTION f_Get_Bridge_Gd_For_Bridge_Id(p_Bridge_Id IN Bridge.Bridge_Id%TYPE)
        RETURN Bridge.Bridge_GD%TYPE; -- VARCHAR2(32)

    FUNCTION f_Get_Bridge_Gd_For_Brkey(p_Brkey IN Bridge.Brkey%TYPE)
        RETURN Bridge.Bridge_GD%TYPE;
    -- VARCHAR2(32)
    FUNCTION f_Get_Insp_Gd_4_Brkey_Inspkey(p_Brkey   IN Bridge.Brkey%TYPE
                                          ,p_Inspkey IN Inspevnt.Inspkey%TYPE) -- no default
     RETURN Inspevnt.Inspevnt_GD%TYPE;

    FUNCTION f_Get_Rway_Gd_For_Brkey_On_Und(p_Brkey    IN Bridge.Brkey%TYPE
                                           ,p_On_Under IN Roadway.On_Under%TYPE := q'[1]') -- default to ON record - first of 2.
    
     RETURN Roadway.Roadway_GD%TYPE; -- VARCHAR2(32);

    FUNCTION f_Get_Str_Unit_Gd_For_Br_Sunit(p_Brkey      IN Bridge.Brkey%TYPE
                                           ,p_Strunitkey IN Structure_Unit.Strunitkey%TYPE := 1) -- default to ON record - first of 2.
     RETURN Structure_Unit.Structure_Unit_GD%TYPE; -- VARCHAR2(32);

    FUNCTION f_Inspection_Exists(p_Inspevnt_GD IN Inspevnt.Inspevnt_GD%TYPE)
        RETURN BOOLEAN;

    FUNCTION f_Insp_Exists_Brkey_Inspkey(p_Brkey   IN Bridge.Brkey%TYPE
                                        ,p_Inspkey IN Inspevnt.Inspkey%TYPE)
        RETURN BOOLEAN;
    FUNCTION f_Sql_Ins_Exists_Brkey_Inspkey(p_Brkey   IN Bridge.Brkey%TYPE
                                           ,p_Inspkey IN Inspevnt.Inspkey%TYPE)
        RETURN PLS_INTEGER;

    -- function returns true if the user is assigned to an active administrator role in PON_APP_USERS_ROLES (with join to PON_APP_ROLES)
    -- or current USER is the schema OWNER and therefore permitted to be an application administrator
    FUNCTION f_Is_Administrator(p_Pon_App_Users_GD IN Pon_App_Users.Pon_App_Users_GD%TYPE
                               ,p_Schema_Owner_Ok  IN BOOLEAN := FALSE)
        RETURN BOOLEAN;

    FUNCTION f_Sql_Is_Administrator(p_Pon_App_Users_GD IN Pon_App_Users.Pon_App_Users_GD%TYPE)
        RETURN PLS_INTEGER;

    -- checks to see if the userkey is in the table PON_APP_USERS_ROLES with an active rolekey of administrator (3, 15003, 15503 as of 2016-05-02)
    FUNCTION f_Sql_Is_Administrator(p_Userid          IN Pon_App_Users.Userid%TYPE
                                   ,p_Schema_Owner_Ok IN BOOLEAN := FALSE)
        RETURN PLS_INTEGER;

    -- checks to see if the userkey is in the table PON_APP_USERS_ROLES with an active rolekey of administrator (3, 15003, 15503 as of 2016-05-02)
    FUNCTION f_Sql_Is_Administrator(p_Userkey         IN Pon_App_Users.Userkey%TYPE
                                   ,p_Schema_Owner_Ok IN BOOLEAN := FALSE)
        RETURN PLS_INTEGER;

END KDOT_BLP_BrM_UTIL;
/
CREATE OR REPLACE PACKAGE BODY "KDOT_BLP_BRM_UTIL" IS
    --------------------------------------------------------------------------------
    -- Utility functions, that could be moved to a more generic package

    --------------------------------------------------------------------------------

    PROCEDURE Pl( --ARM 1/8/2002 lots of work here to improve word wrap behavior and so on.  If used judiciously with reasonable input lines, this procedure
                 -- will format over-long messages pretty nicely to fit on a variable widht screen output.
                 Str       IN VARCHAR2
                ,Len       IN PLS_INTEGER := 80
                ,Expand_In IN BOOLEAN := TRUE)
    -- print line to console, wrapper for DBMS_OUTPUT.PUT_LINE
     IS
        v_Len       PLS_INTEGER := Least(Len, 255);
        v_Tokenlen  PLS_INTEGER;
        v_Str       VARCHAR2(5000);
        Ll_Crlf_Pos PLS_INTEGER;
        v_Blankpos  PLS_INTEGER := 0;
    BEGIN
        IF Length(Str) > v_Len -- only for overlong lines
        THEN
            Ll_Crlf_Pos := Instr(Str, Utl_Tcp.Crlf);
        
            IF Ll_Crlf_Pos = 0
            THEN
                -- no CR/LF
                v_Str      := Substr(Str, 1, v_Len); -- part 1 is the length from 1 to 80
                v_Blankpos := Instr(v_Str, ' ', -1, 1); --starting at end, back to first blank
            
                IF v_Blankpos > 0
                THEN
                    -- found a blank
                    IF v_Blankpos > v_Len
                    THEN
                        v_Str      := Substr(Str, 1, v_Len);
                        v_Tokenlen := Length(v_Str);
                    ELSE
                        -- chop off at blankpos -1
                        v_Str      := Substr(Str, 1, v_Blankpos); -- so, printable is from 1 to the blank, -1
                        v_Tokenlen := v_Blankpos; --start AFTER the BLANK
                    END IF;
                ELSE
                    -- no blank encountered
                    v_Str      := Substr(Str, 1, v_Len);
                    v_Tokenlen := Length(v_Str);
                END IF;
            ELSE
                -- chop at closest cr/lf
                IF Ll_Crlf_Pos > v_Len
                THEN
                    v_Str      := Substr(Str, 1, v_Len);
                    v_Tokenlen := Length(v_Str);
                ELSE
                    v_Str      := Substr(Str, 1, Ll_Crlf_Pos - 1); -- strip cr/lf, since this is a PUT_LINE (with implied CR/LF)
                    v_Tokenlen := Ll_Crlf_Pos; --start AFTER the CR/LF
                END IF;
            END IF;
        
            Dbms_Output.Put_Line(v_Str);
            -- recursion, print remainder of line
        
            Pl(Substr(Str, v_Tokenlen + 1), v_Len, Expand_In);
        ELSE
            Ll_Crlf_Pos := Instr(Str, Utl_Tcp.Crlf);
        
            IF Ll_Crlf_Pos > 0
            THEN
                Dbms_Output.Put_Line(Substr(Str, Ll_Crlf_Pos - 1));
            ELSE
                Dbms_Output.Put_Line(Str);
            END IF;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            IF Expand_In
            THEN
                Dbms_Output.Enable(1000000);
            ELSE
                RAISE;
            END IF;
        
            Dbms_Output.Put_Line(v_Str);
    END Pl;

    -- Return the time formatted rather precisely
    FUNCTION f_Now(p_Fmt IN VARCHAR2 := q'[YYYY-MM-DD HH24:MI:SS]')
        RETURN VARCHAR2 IS
    BEGIN
        RETURN To_Char(SYSDATE, p_Fmt);
    END f_Now;

    FUNCTION Sq(String_Arg IN VARCHAR2) -- enclose striung in quotes
     RETURN VARCHAR2 IS
        Ls_Temp VARCHAR2(4000);
        --   ARMarshall, CS, 1/15/2001. Changed sq and dq functions to have 4K string buffers, max for VARCHAR2 variables
    BEGIN
        Ls_Temp := TRIM(q'[']' || String_Arg || q'[']');
        RETURN Ls_Temp;
    END Sq;

    FUNCTION Dq(String_Arg IN VARCHAR2) -- enclose in double quotes (typically Oracle object names )
     RETURN VARCHAR2 IS
        Ls_Temp VARCHAR2(4000);
        --   ARMarshall, CS, 1/15/2001. Changed sq and dq functions to have 4K string buffers, max for VARCHAR2 variables
    BEGIN
        Ls_Temp := TRIM(q'["]' || String_Arg || q'["]');
        RETURN Ls_Temp;
    END Dq;

    FUNCTION f_Get_Table_Owner(Name_In IN Sys.All_Tables.Table_Name%TYPE)
        RETURN Sys.All_Tables.Owner%TYPE IS
        Ls_Result Sys.All_Tables.Owner%TYPE;
    BEGIN
        SELECT Owner
        INTO Ls_Result
        FROM Sys.All_Tables
        WHERE Table_Name = Upper(Name_In);
    
        RETURN Ls_Result;
    EXCEPTION
        WHEN Too_Many_Rows THEN
            RETURN 'XMULTIPLE_REFSX';
        WHEN No_Data_Found THEN
            RETURN NULL;
        WHEN OTHERS THEN
            RETURN NULL;
    END;

    FUNCTION f_Get_View_Owner(Name_In IN Sys.All_Views.View_Name%TYPE)
        RETURN Sys.All_Views.Owner%TYPE IS
        Ls_Result Sys.All_Views.Owner%TYPE;
    BEGIN
        SELECT Owner
        INTO Ls_Result
        FROM Sys.All_Views
        WHERE View_Name = Upper(Name_In);
    
        RETURN Ls_Result;
    EXCEPTION
        WHEN Too_Many_Rows THEN
            RETURN 'XMULTIPLE_REFSX';
        WHEN No_Data_Found THEN
            RETURN NULL;
        WHEN OTHERS THEN
            RETURN NULL;
    END f_Get_View_Owner;

    FUNCTION Istable(The_Table IN Sys.All_Tables.Table_Name%TYPE)
        RETURN BOOLEAN -- FALSE MEANS NOT A TABLE!!
     IS
        Ls_Dummy Sys.All_Tables.Table_Name%TYPE;
    BEGIN
        SELECT Table_Name
        INTO Ls_Dummy
        FROM Sys.All_Tables
        WHERE Table_Name = Upper(TRIM(The_Table));
    
        IF Ls_Dummy IS NOT NULL
        THEN
            RETURN TRUE;
        END IF;
    EXCEPTION
        WHEN Too_Many_Rows THEN
            RETURN TRUE; -- too many is okay, but impossible.
        WHEN No_Data_Found THEN
            RETURN FALSE;
        WHEN OTHERS THEN
            RETURN FALSE;
    END Istable;

    FUNCTION Istableorview(The_Table IN Sys.All_Tables.Table_Name%TYPE)
        RETURN BOOLEAN -- FALSE MEANS NOT A TABLE!!
     IS
        Ls_Dummy Sys.All_Tables.Table_Name%TYPE;
    BEGIN
        -- first see if it is a table, then check if it is a view.
        IF NOT Istable(The_Table)
        THEN
            SELECT View_Name
            INTO Ls_Dummy
            FROM Sys.All_Views
            WHERE View_Name = Upper(TRIM(The_Table));
        
            IF Ls_Dummy IS NOT NULL
            THEN
                RETURN TRUE;
            END IF;
        ELSE
            RETURN TRUE;
        END IF;
    EXCEPTION
        WHEN Too_Many_Rows THEN
            RETURN TRUE; -- too many is okay, but impossible.
        WHEN No_Data_Found THEN
            RETURN FALSE;
        WHEN OTHERS THEN
            RETURN FALSE;
    END Istableorview;
    FUNCTION f_Is_Table(Name_In IN Sys.All_Tables.Table_Name%TYPE)
        RETURN BOOLEAN IS
        Ls_Retval Sys.All_Tables.Owner%TYPE;
        Lb_Result BOOLEAN := FALSE;
    BEGIN
        Ls_Retval := f_Get_Table_Owner(Name_In);
    
        IF Ls_Retval IS NOT NULL
        THEN
            Lb_Result := TRUE;
        END IF;
    
        RETURN Lb_Result;
    END f_Is_Table;

    FUNCTION f_Is_View(Name_In IN Sys.All_Views.View_Name%TYPE) RETURN BOOLEAN IS
        Ls_Retval Sys.All_Views.Owner%TYPE;
        Lb_Result BOOLEAN := FALSE;
    BEGIN
        Ls_Retval := f_Get_View_Owner(Name_In);
    
        IF Ls_Retval IS NOT NULL
        THEN
            Lb_Result := TRUE;
        END IF;
    
        RETURN Lb_Result;
    END f_Is_View;
    -- print a CLOB to the CONSOLE
    PROCEDURE p_Print_Clob(p_Clob IN CLOB) AS
        l_Offset NUMBER DEFAULT 1;
    BEGIN
        LOOP
            EXIT WHEN l_Offset > Dbms_Lob.Getlength(p_Clob);
            Dbms_Output.Put_Line(Dbms_Lob.Substr(p_Clob, 255, l_Offset));
            l_Offset := l_Offset + 255;
        END LOOP;
    END;

    /* COUNT_ROWS_FOR_TABLE
    || PASS well formed SQL string, or list of 1:N tables, comma separated, optional where_clause, mode ANY  or COUNT , get COUNT or 1,0 back - returns TRUE ON FAILURE in the_error
    || where clause is arbitrarily complex, logic must match table list
    || can take a view name
    || after call, arg the_count holds the # of rows
    ||  usage: select fw.count_rows_for_table( 'BRIDGE b, ELEMINSP e', 'b,BRKEY ='||sq('AAQ') || ' AND b.brkey = e.elemkey ', the_count) from DUAL;
    */
    PROCEDURE Count_Rows_For_Table(The_String_In    IN VARCHAR2
                                  ,The_Where_Clause IN VARCHAR2
                                  ,The_Mode         IN VARCHAR2
                                  ,The_Count        OUT PLS_INTEGER
                                  ,The_Error        OUT BOOLEAN) IS
        Lc_Cur       PLS_INTEGER := Dbms_Sql.Open_Cursor;
        Ll_Retval    PLS_INTEGER := 0; -- return value from EXECUTE_AND_FETCH
        Ls_Sqlstring VARCHAR2(2000);
        --   Ll_Count       PLS_INTEGER := 0;
        Ls_Table_Token Sys.All_Tables.Table_Name%TYPE;
        Ll_Startpos    PLS_INTEGER := 1;
        Ll_Endpos      PLS_INTEGER := 0;
        /* Known Oracle Errors */
        Invalid_Sql_Statement EXCEPTION;
        PRAGMA EXCEPTION_INIT(Invalid_Sql_Statement, -00900);
        Table_Does_Not_Exist EXCEPTION;
        PRAGMA EXCEPTION_INIT(Table_Does_Not_Exist, -00942);
        /* User Exceptions */
        -- none
    
    BEGIN
        LOOP
            The_Error := TRUE; -- assume failure.
        
            /* either count or  ANY directive */
            -- Hoyt 02/15/2002 Added upper()
            IF Instr(Upper(TRIM(The_String_In)), 'SELECT ', 1) = 0
            THEN
                -- incoming string does not contain SELECT
                IF Upper(The_Mode) = 'ANY'
                THEN
                    Ls_Sqlstring := 'SELECT 1 FROM  ';
                ELSE
                    Ls_Sqlstring := 'SELECT COUNT(*) FROM  ';
                END IF;
            
                Ll_Startpos := 1; -- 1, 9, etc.
                Ll_Endpos   := Instr(TRIM(The_String_In), ',', 1);
            
                IF Ll_Endpos > 0
                THEN
                    -- at least 1 comma found...
                    LOOP
                        -- parse table list, extract all names, check if valid table or view
                        -- if we cannot retrieve anything using SUBSTR from the string, return a dash which will cause fail in ISTABLE
                    
                        Ls_Table_Token := TRIM(Nvl(Substr(TRIM(The_String_In)
                                                         ,Ll_Startpos
                                                         ,Ll_Endpos -
                                                          Ll_Startpos)
                                                  ,'-'));
                    
                        -- is the argument a valid table ?
                        IF NOT Istableorview(Ls_Table_Token) -- ALlen Marshall, CS - 2003.03.31 - allow a view to work too
                        THEN
                            RAISE Table_Does_Not_Exist; -- an Oracle error.
                        END IF;
                    
                        Ll_Startpos := Ll_Endpos + 1;
                    
                        IF Ll_Startpos < Length(The_String_In)
                        THEN
                            Ll_Endpos := Nvl(Instr(The_String_In
                                                  ,','
                                                  ,Ll_Startpos
                                                  ,1)
                                            ,0);
                        
                            IF Ll_Endpos = 0
                            THEN
                                -- no more commas (arguments)
                                Ll_Endpos := Length(TRIM(The_String_In)) + 1;
                            END IF;
                        ELSE
                            EXIT;
                        END IF;
                    END LOOP;
                ELSE
                    -- is the argument a valid table ?
                    IF NOT Istableorview(TRIM(The_String_In)) -- ALlen Marshall, CS - 2003.03.31 - allow a view to work too
                    THEN
                        RAISE Table_Does_Not_Exist;
                    END IF;
                END IF;
            END IF; -- IN String was not a SQL Statement (NO SELECT )
        
            -- fixup where if necessary.
        
            IF The_Where_Clause IS NOT NULL
               AND Length(TRIM(The_Where_Clause)) > 0
            THEN
                IF Instr(Upper(The_Where_Clause), 'WHERE') = 0
                THEN
                    -- word WHERE not found, concatenate clause to WHERE
                    Ls_Sqlstring := Ls_Sqlstring || The_String_In ||
                                    ' WHERE ' || Nvl(The_Where_Clause, ' ');
                ELSE
                    -- use WHERE CLAUSE AS IS
                    Ls_Sqlstring := Ls_Sqlstring || The_String_In || ' ' ||
                                    Nvl(The_Where_Clause, ' ');
                END IF;
            ELSE
                -- no where clause to use
                Ls_Sqlstring := Ls_Sqlstring || ' ' || The_String_In;
            END IF;
        
            -- OK - done putting together a SELECT statement
        
            -- PARSE SQL String to see if SYNTAX is right, raises exception if not
            BEGIN
                -- parse block starts
                Dbms_Sql.Parse(Lc_Cur, Ls_Sqlstring, Dbms_Sql.Native);
            EXCEPTION
                WHEN OTHERS THEN
                    BEGIN
                        RAISE;
                        EXIT;
                    END;
            END;
        
            -- associate column  with argument
            BEGIN
                Dbms_Sql.Define_Column(Lc_Cur, 1, The_Count);
            EXCEPTION
                WHEN OTHERS THEN
                    --                err.handle( SQLCODE, 'DBMS_SQL.Define_Column call failed',FALSE, TRUE );
                    EXIT;
            END;
        
            -- execute SQL in cursor
            BEGIN
                Ll_Retval := Dbms_Sql.Execute_And_Fetch(Lc_Cur);
            EXCEPTION
                WHEN OTHERS THEN
                    --                err.handle( SQLCODE, 'DBMS_SQL.EXECUTE call failed',FALSE, TRUE );
                    EXIT;
            END;
        
            -- something (a row) was fetched
            -- Get value into count argument
            -- if the_count NOT <0 , that's okay. In other words, if FALSE, we succeeded.
            BEGIN
                Dbms_Sql.Column_Value(Lc_Cur, 1, The_Count);
            EXCEPTION
                WHEN OTHERS THEN
                    --                err.handle( SQLCODE, 'DBMS_SQL.COLUMN_VALUE call failed',FALSE, TRUE );
                    EXIT;
            END;
        
            IF The_Mode = 'ANY'
            THEN
                The_Count := Ll_Retval; -- why? Because if RETVAL = 1, then a row came back, no
                -- matter whether COUNT(*) or SELECT 1 was fired
            END IF;
        
            The_Error := FALSE; -- success
            EXIT WHEN TRUE;
        END LOOP;
    
        -- Always close when finished to avoid ORA-1000 (too many cursors)
        IF Dbms_Sql.Is_Open(Lc_Cur)
        THEN
            Dbms_Sql.Close_Cursor(Lc_Cur);
        END IF;
    EXCEPTION
        WHEN Table_Does_Not_Exist THEN
            BEGIN
                -- TIDY
                IF Dbms_Sql.Is_Open(Lc_Cur)
                THEN
                    Dbms_Sql.Close_Cursor(Lc_Cur);
                END IF;
            
                The_Count := SQLCODE;
                Dbms_Output.Put_Line('Table does not exist processing count_rows_for_table - SQL was ' ||
                                     Nvl(Ls_Sqlstring, '?'));
                --                   err.HANDLE( sqlcode, 'Table does not exist processing count_rows_for_table - SQL was ' ||  NVL( ls_SQLString, '?') , FALSE, TRUE );
            END;
        WHEN Invalid_Sql_Statement THEN
            BEGIN
                -- TIDY
                IF Dbms_Sql.Is_Open(Lc_Cur)
                THEN
                    Dbms_Sql.Close_Cursor(Lc_Cur);
                END IF;
            
                The_Count := SQLCODE;
                Pl('Invalid SQL statement processing count_rows_for_table');
                Pl('SQL was ' || Nvl(Ls_Sqlstring, '?'));
                --err.HANDLE( sqlcode, 'Invalid SQL statement processing count_rows_for_table - SQL was ' ||  NVL( ls_SQLString , '?'), FALSE, TRUE  );
            END;
        WHEN OTHERS THEN
            BEGIN
                -- TIDY
                IF Dbms_Sql.Is_Open(Lc_Cur)
                THEN
                    Dbms_Sql.Close_Cursor(Lc_Cur);
                END IF;
            
                The_Count := SQLCODE;
                Pl('Unknown error encountered in count_rows_for_table');
                Pl('SQL was ' || Nvl(Ls_Sqlstring, '?'));
                --err.HANDLE( sqlcode, 'Unknown error encountered in count_rows_for_table - SQL was ' ||  NVL( ls_SQLString, '?'  ), FALSE, TRUE  );
            END;
    END Count_Rows_For_Table;
    FUNCTION f_Any_Rows_Exist(The_Stringarg_In IN VARCHAR2
                             ,The_Where_Clause IN VARCHAR2) RETURN BOOLEAN IS
        Ll_Count      PLS_INTEGER := 0;
        Lb_Failed     BOOLEAN := TRUE;
        Lb_Rows_Exist BOOLEAN := FALSE;
    BEGIN
        Count_Rows_For_Table(The_Stringarg_In
                            ,The_Where_Clause
                            ,'ANY'
                            ,Ll_Count
                            ,Lb_Failed); -- FAILED = TRUE
    
        IF NOT Lb_Failed
        THEN
            Lb_Rows_Exist := (Nvl(Ll_Count, 0) > 0);
        ELSE
            Lb_Rows_Exist := NULL;
        END IF;
        COMMIT;
        RETURN Lb_Rows_Exist; -- IF ll_count IS >=0, then we succeed - check rows exist to see if any rows match criteria
    EXCEPTION
        WHEN OTHERS THEN
            BEGIN
                ROLLBACK;
                Lb_Rows_Exist := NULL; -- so, if we get null back, then we know the call failed.
                RETURN Lb_Rows_Exist;
            END;
        
    END f_Any_Rows_Exist;

    /* VARIANT - Pass well-formed SQL statement, get count back - RETURNS TRUE on FAILURE (bad SQL)
    || Pass a (presumably  valid ) SELECT statement with SELECT 1  as a string, get back 1 if any exist, 0 if none, returns TRUE on failure
    || can take a SELECT of any complexity up to 500 chars in length
    || During development, test SQL in an SQL before using in code
    || This variant does not use a where clause...
    || usage: select fw.any_rows_in_table( 'SELECT 1 FROM BRIDGE b, ELEMINSP e WHERE b,BRKEY ='||fw.sq('AAQ') || ' AND b.brkey = e.elemkey ', rows_exist ) from DUAL;
    */
    FUNCTION f_Any_Rows_Exist(The_Stringarg_In IN VARCHAR2) RETURN BOOLEAN IS
        Ll_Count      PLS_INTEGER := 0;
        Lb_Failed     BOOLEAN := TRUE;
        Lb_Rows_Exist BOOLEAN := FALSE;
    BEGIN
        Count_Rows_For_Table(The_Stringarg_In
                            ,NULL
                            ,'ANY'
                            ,Ll_Count
                            ,Lb_Failed); -- FAILED = TRUE
    
        IF NOT Lb_Failed
        THEN
            Lb_Rows_Exist := (Nvl(Ll_Count, 0) > 0);
        ELSE
            Lb_Rows_Exist := NULL;
        END IF;
        COMMIT;
        RETURN Lb_Rows_Exist; -- IF ll_count IS >=0, then we succeed - check rows exist to see if any rows match criteria
    EXCEPTION
        WHEN OTHERS THEN
            BEGIN
                ROLLBACK;
                Lb_Rows_Exist := NULL; -- so, if we get null back, then we know the call failed.
                RETURN Lb_Rows_Exist;
            END;
    END f_Any_Rows_Exist;

    FUNCTION Random RETURN PLS_INTEGER IS
    BEGIN
        RETURN Trunc(Dbms_Random.Value(1, 9));
    END Random;

    -- Used by f_random_integer() and f_random_float()
    FUNCTION Mult(p IN NUMBER
                 ,q IN NUMBER) RETURN NUMBER IS
        P1 NUMBER;
        P0 NUMBER;
        Q1 NUMBER;
        Q0 NUMBER;
    BEGIN
        P1 := Trunc(p / M1);
        P0 := MOD(p, M1);
        Q1 := Trunc(q / M1);
        Q0 := MOD(q, M1);
        RETURN(MOD((MOD(P0 * Q1 + P1 * Q0, M1) * M1 + P0 * Q0), m));
    END Mult;

    -- Returns an integer between [0, r-1]
    FUNCTION f_Random_Integer(r IN NUMBER) RETURN NUMBER IS
    BEGIN
        /*  -- Generate a random number and set it to be the new seed 
        a := MOD(Mult(a, b) + 1, m);
        -- Convert it to integer between [0, r-1] and return it 
        RETURN(Trunc((Trunc(a / M1) * r) / M1));*/
        RETURN Round(Dbms_Random.Value(0, r), 0);
    END f_Random_Integer;

    -- Returns random real between [0, 1] 
    FUNCTION f_Random_Float RETURN NUMBER IS
    BEGIN
        /*  -- Generate a random number and set it to be the new seed 
        a := MOD(Mult(a, b) + 1, m);
        -- Return it
        RETURN(a / m);*/
        RETURN Dbms_Random.Value(0, 1);
    END f_Random_Float;

    FUNCTION f_Random(p_Lowerlim IN PLS_INTEGER := 0
                     ,Numdigits  IN PLS_INTEGER) RETURN PLS_INTEGER IS
    BEGIN
        RETURN Round(Dbms_Random.Value(p_Lowerlim
                                      ,Power(10
                                            ,Greatest(1
                                                     ,Least(Numdigits, 9))))
                    ,0);
    END;

    FUNCTION Random(Numdigits IN PLS_INTEGER) RETURN PLS_INTEGER IS
    BEGIN
        RETURN f_Random(Numdigits => Numdigits);
    END;
    -- Returns TRUE if the passed varchar2 is NULL or (after trimming) has length zero
    -- The 'ns' in 'f_ns' stands for 'Not String'.
    FUNCTION f_Ns(Psi_String IN VARCHAR2) RETURN BOOLEAN IS
    BEGIN
        IF Psi_String IS NULL
        THEN
            RETURN TRUE; -- It is NOT a string
        END IF;
    
        IF Length(TRIM(Psi_String)) = 0
        THEN
            RETURN TRUE; -- It is NOT a string again
        END IF;
    
        -- It isn't NULL, and it has at least one non-blank, so it's a string
        RETURN FALSE;
    END f_Ns;

    FUNCTION f_Numbers_Differ(Oldnum1           IN VARCHAR2
                             ,Newnum2           IN VARCHAR2
                             ,Precision_Limit   IN DOUBLE PRECISION := NULL
                             ,Notify_On_Missing IN BOOLEAN := TRUE)
        RETURN BOOLEAN IS
    
        --    Created 8/13/2014 by ARMarshall, Allen R. Marshall Consulting LLC -
        --    http://allenrmarshall-consulting-llc.com
        --    mailto://armarshall@allenrmarshall-consulting-llc.com
        --    added
        --    This function accepts 4 arguments, the 3rd of which defaults to NULL (0) and the 4th defaults to TRUE (always notify if new value goes to missing).
        --    If the two test values differ enough by pct., or absolutely if the new one is 0( more than the precision_limit) the function returns TRUE, FALSE otherwise.
        --    This can be used anywhere we want to determine if two numbers are different and we want to set the precision for each situation.  
        --    Updated:
        --    ARMarshall, 20180819 - added protection for divide by zero and also now willOPTIONALLY notify if the new value goes to NULL or the magic -1 BrM missing value
    
        Lf_Difference DOUBLE PRECISION := 0.0;
        -- TODO - use the exceptions package
        Invalid_Args EXCEPTION;
        Invalid_Args_Val PLS_INTEGER := -20000; -- was erroring out at -21500...changed to -20000
        Divide_By_Zero EXCEPTION;
        PRAGMA EXCEPTION_INIT(Invalid_Args, -20000); -- was erroring out at -21500...changed to -20000
        PRAGMA EXCEPTION_INIT(Divide_By_Zero, -1476);
    
    BEGIN
        IF (Notify_On_Missing)
        THEN
            IF Newnum2 IS NULL
               OR Instr(Cs_BrM_Missing_Values, Newnum2) > 0 -- if it quacks like a duck, quack back.  Probably has gone missing
            THEN
                RETURN TRUE;
            END IF;
        END IF;
    
        -- assert no null arguments have gotten here.
        IF (Oldnum1 IS NULL OR Newnum2 IS NULL)
        THEN
            Raise_Application_Error(Invalid_Args_Val
                                   ,'one or both of the OLD and NEW VALUE arguments to the function f_numbers_differ is NULL.  NULL is not the same as 0.  Comparison has failed.'
                                   ,TRUE);
        END IF;
    
        -- assert all arguments are numbers
        IF NOT (Isnumber(Oldnum1) AND Isnumber(Newnum2))
        THEN
            Raise_Application_Error(Invalid_Args_Val
                                   ,'one or both of the OLD and NEW VALUE arguments to the function f_numbers_differ is not a number!'
                                   ,TRUE);
        END IF;
    
        IF (Nvl(Precision_Limit, 0) <= 0)
        THEN
            Raise_Application_Error(Invalid_Args_Val
                                   ,'PRECISION_LIMIT argument to the function f_numbers_differ IS ZERO or NEGATIVE'
                                   ,TRUE);
        END IF;
    
        -- try to see if the percentage change is > than the limit but only do this if the divisor is non-zero
        IF (Newnum2 <> 0)
        THEN
            Lf_Difference := Abs(1.0 - (Oldnum1 / Newnum2));
        ELSE
            -- otherwise just look at the absolute change (from 0 to something in either direction)
            Lf_Difference := Abs(Nvl(Oldnum1, 0) - Nvl(Newnum2, 0));
        END IF;
    
        RETURN Lf_Difference > Nvl(Precision_Limit, 0);
    
    EXCEPTION
        WHEN Divide_By_Zero THEN
            RETURN TRUE;
        WHEN OTHERS THEN
            RAISE;
    END f_Numbers_Differ;

    -- Returns 'TRUE' or 'FALSE' so Boolean values can be displayed as strings
    FUNCTION f_Boolean_To_String(p_Boolean IN BOOLEAN) RETURN VARCHAR2 IS
        Lb_Boolean VARCHAR2(5);
    BEGIN
        IF p_Boolean
        THEN
            Lb_Boolean := 'TRUE';
        ELSE
            Lb_Boolean := 'FALSE';
        END IF;
    
        RETURN Lb_Boolean;
    END f_Boolean_To_String;

    FUNCTION Isnumbertest(p_Teststring IN VARCHAR2) RETURN BOOLEAN IS
        Ll_Numtest NUMBER;
    BEGIN
        Ll_Numtest := p_Teststring; -- raises an exception if this fails, which means the Token is not a number
        RETURN TRUE;
    EXCEPTION
        WHEN Value_Error THEN
            -- must be a string or NAN - return false
            RETURN FALSE;
        WHEN OTHERS THEN
            RAISE;
    END Isnumbertest;

    PROCEDURE Isnumber(p_Stringvalue     IN VARCHAR2
                      ,p_Messagetext     IN VARCHAR2
                      ,p_Raise_Exception IN BOOLEAN := TRUE
                      ,p_Exception       IN VARCHAR2 := 'VALUE_ERROR') IS
    
    BEGIN
        IF NOT Isnumbertest(p_Stringvalue) -- is true
           OR p_Stringvalue IS NULL
        THEN
            Pl('Assertion Failure!');
            Pl(p_Messagetext);
            Pl('');
        
            IF p_Raise_Exception
            THEN
                EXECUTE IMMEDIATE 'BEGIN RAISE ' || p_Exception || '; END;';
            END IF;
        END IF;
    END Isnumber;

    PROCEDURE Istrue(p_Testvalue       IN BOOLEAN
                    ,p_Messagetext     IN VARCHAR2
                    ,p_Raise_Exception IN BOOLEAN := TRUE
                    ,p_Exception       IN VARCHAR2 := 'VALUE_ERROR') IS
    BEGIN
        IF NOT p_Testvalue -- is true
           OR p_Testvalue IS NULL
        THEN
            Pl('Assertion Failure!');
            Pl(p_Messagetext);
            Pl('');
        
            IF p_Raise_Exception
            THEN
                EXECUTE IMMEDIATE 'BEGIN RAISE ' || p_Exception || '; END;';
            END IF;
        END IF;
    END Istrue;

    PROCEDURE Isnotnull(p_Stringvalue     IN VARCHAR2
                       ,p_Messagetext     IN VARCHAR2
                       ,p_Raise_Exception IN BOOLEAN := TRUE
                       ,p_Exception       IN VARCHAR2 := 'VALUE_ERROR') IS
    BEGIN
        Istrue(p_Stringvalue IS NOT NULL
              ,p_Messagetext
              ,p_Raise_Exception
              ,p_Exception);
    END Isnotnull;

    PROCEDURE Isnotnull(p_Datevalue       IN DATE
                       ,p_Messagetext     IN VARCHAR2
                       ,p_Raise_Exception IN BOOLEAN := TRUE
                       ,p_Exception       IN VARCHAR2 := 'VALUE_ERROR') IS
    BEGIN
        Istrue(p_Datevalue IS NOT NULL
              ,p_Messagetext
              ,p_Raise_Exception
              ,p_Exception);
    END Isnotnull;

    PROCEDURE Isnotnull(p_Numbervalue     IN NUMBER
                       ,p_Messagetext     IN VARCHAR2
                       ,p_Raise_Exception IN BOOLEAN := TRUE
                       ,p_Exception       IN VARCHAR2 := 'VALUE_ERROR') IS
    BEGIN
        Istrue(p_Numbervalue IS NOT NULL
              ,p_Messagetext
              ,p_Raise_Exception
              ,p_Exception);
    END Isnotnull;

    PROCEDURE Isnotnull(p_Testvalue       IN BOOLEAN
                       ,p_Messagetext     IN VARCHAR2
                       ,p_Raise_Exception IN BOOLEAN := TRUE
                       ,p_Exception       IN VARCHAR2 := 'VALUE_ERROR') IS
    BEGIN
        Istrue(p_Testvalue IS NOT NULL
              ,p_Messagetext
              ,p_Raise_Exception
              ,p_Exception);
    END Isnotnull;

    -- assert that string argument is a number, or raise exception
    PROCEDURE Isnumber(p_Teststring      IN VARCHAR2
                      ,p_Messagetext     IN VARCHAR2 := ''
                      ,p_Raise_Exception IN BOOLEAN := TRUE
                      ,p_Exception       IN VARCHAR2 := 'VALUE_ERROR') IS
    
        Lb_Test BOOLEAN := FALSE;
    
    BEGIN
    
        Lb_Test := Isnumbertest(p_Teststring);
    
        Istrue(Lb_Test, p_Messagetext, p_Raise_Exception, p_Exception);
    END Isnumber;

    FUNCTION Isnumber(The_Token_In IN VARCHAR2) RETURN BOOLEAN IS
        Ll_Numtest NUMBER;
    BEGIN
        Ll_Numtest := The_Token_In; -- raise exception if this fails
        RETURN TRUE;
    EXCEPTION
        WHEN Value_Error THEN
            -- must be a string, so wrap with quotes
            RETURN FALSE;
        WHEN OTHERS THEN
            RAISE;
    END Isnumber;

    FUNCTION f_Is_Bridge_GD(p_Bridge_GD IN Bridge.Bridge_GD%TYPE)
    -- Returns TRUE if the passed string is a valid BRIDGE_GD
     RETURN BOOLEAN IS
        RESULT Bridge.Bridge_GD%TYPE;
    
    BEGIN
    
        SELECT Br.Bridge_GD
        INTO RESULT
        FROM Bridge Br
        WHERE Br.Bridge_GD = p_Bridge_GD;
    
        IF f_Ns(RESULT)
        THEN
            RETURN TRUE;
        END IF;
    EXCEPTION
        WHEN No_Data_Found THEN
            RETURN FALSE;
        WHEN OTHERS THEN
            RAISE;
    END f_Is_Bridge_GD;

    FUNCTION f_Get_BrM_Admin_Group_Codes RETURN VARCHAR2 IS
    BEGIN
    
        RETURN Cs_BrM_Admin_Group_Codes;
    
    END f_Get_BrM_Admin_Group_Codes;

    -- Returns the pon_app_users.userkey that corresponds to the (Oracle) 'user',
    -- if any, else returns the minimum userkey (so at least it's valid)
    FUNCTION f_Get_Users_Userkey RETURN VARCHAR2 IS
        Ls_Userkey Pon_App_Users.Userkey%TYPE; -- Length of bridge_id in Pontis
        Ls_Context Kdot_Blp_Types.Context_String_Type := 'f_get_users_userkey()';
    BEGIN
        -- See if there is a userkey corresponding to (Oracle) 'user'
        BEGIN
            SELECT Userkey
            INTO Ls_Userkey
            FROM Pon_App_Users
            WHERE Upper(Userid) = USER;
        
            RETURN Ls_Userkey;
        EXCEPTION
            WHEN No_Data_Found THEN
                -- Just take the minimum userkey
                BEGIN
                    SELECT MIN(Userkey) INTO Ls_Userkey FROM Pon_App_Users; -- probably 1
                
                    RETURN Ls_Userkey;
                EXCEPTION
                    WHEN OTHERS THEN
                        -- Variant 2 so we can return NULL
                        Dbms_Output.Put_Line(Ls_Context +
                                             ': Failed to get the min( USERKEY )!');
                        RETURN NULL;
                END;
            WHEN OTHERS THEN
                -- Variant 2 so we can return NULL
                Dbms_Output.Put_Line(Ls_Context +
                                     ': Failed to get the USERKEY corresponding to USER ' || USER);
                RETURN NULL;
        END;
    
        -- If we hit this, then something is seriously wrong with our
        -- exception-handling theory
        RETURN NULL;
    END f_Get_Users_Userkey;
    -- this variable is for INSERTS to the table DATASYNC_CHANGE_LOG, column status
    --gs_default_exchange_log_status   ds_exchange_status.status_label%TYPE;

    FUNCTION f_Get_p_a_Users_Gd_For_Userid(p_Userid IN Pon_App_Users.Userid%TYPE)
        RETURN Pon_App_Users.Pon_App_Users_GD%TYPE IS
        RESULT Pon_App_Users.Pon_App_Users_GD%TYPE;
    BEGIN
        SELECT Pau.Pon_App_Users_GD
        INTO RESULT
        FROM Pon_App_Users Pau
        WHERE Upper(TRIM(Pau.Userid)) = Upper(TRIM(p_Userid));
        RETURN RESULT;
    EXCEPTION
        WHEN No_Data_Found THEN
            RETURN NULL;
        WHEN OTHERS THEN
            RAISE;
    END f_Get_p_a_Users_Gd_For_Userid;

    FUNCTION f_Get_p_a_Users_Gd_For_Userkey(p_Userkey IN Pon_App_Users.Userkey%TYPE)
        RETURN Pon_App_Users.Pon_App_Users_GD%TYPE IS
        RESULT Pon_App_Users.Pon_App_Users_GD%TYPE;
    BEGIN
        SELECT Pau.Pon_App_Users_GD
        INTO RESULT
        FROM Pon_App_Users Pau
        WHERE Pau.Userkey = p_Userkey;
        RETURN RESULT;
    EXCEPTION
        WHEN No_Data_Found THEN
            RETURN NULL;
        WHEN OTHERS THEN
            RAISE;
    END f_Get_p_a_Users_Gd_For_Userkey;

    FUNCTION f_Get_Userkey_For_Orauser(The_User IN VARCHAR2)
    -- Allen 7/27/2001
     RETURN Pon_App_Users.Userkey%TYPE IS
        ---------------------------------------------------------------------------------------
        -- function f_get_userkey_for_orauser
        ---------------------------------------------------------------------------------------
        -- Function returns a userkey FROM pon_app_users for an arbitrary Oracle USER or a
        -- default userkey , which is a default set in
        -- sms2k_insp_pg.gs_default_userkey, if USER not found in the USERS table.
        -- That userkey must be in USERS even if it is a default to prevent
        -- referential integrity errors Assumption: DEFAULT USERID = 'DEFAULT' in
        -- USERS table. See gs_default_userid and gs_default_userkey
    
        -- Usage: select get_userkey_for_orauser() from dual;
        ---------------------------------------------------------------------------------------
        -- Allen R. Marshall, Cambridge Systematics
        -- Created 5/2001
        -- Revised: 7/23/2001 - (ARM) added comments
        -- Revised: 7/27/2001 - moved into this package.
        -- Revised: 1/2/2002 - simplified structure to rely on NO_DATA_FOUND exception
        -- removed a variable. Still relies on existence of a default row in USERS
        ---------------------------------------------------------------------------------------
    
        v_User Pon_App_Users.Userkey%TYPE := Gs_Default_Userkey;
        -- Exception when cannot find a legitimate userid for a record - ARM 7/27/2001
        No_Userid_Found EXCEPTION;
        PRAGMA EXCEPTION_INIT(No_Userid_Found, -20009);
    BEGIN
        -- for logged in USER, find a userkey, or use the default userkey of 9999 if none found
        --ARM 1/20/2001 removed NVL(userkey,'NOTFOUND')
        BEGIN
            SELECT Userkey
            INTO v_User
            FROM Pon_App_Users u
            WHERE Upper(u.Userid) = Nvl(Upper(The_User), USER); -- ARM 7/26/2001 just to be sure...
        EXCEPTION
            WHEN No_Data_Found
            -- No data, try finding a default userkey using the default userid
             THEN
                BEGIN
                    SELECT Userkey
                    INTO v_User
                    FROM Pon_App_Users u
                    WHERE Upper(u.Userid) = Upper(Gs_Default_Userid);
                EXCEPTION
                    -- this means the default userid is missing from the USERS table so no key can be
                    -- determined.  Function returns NULL.
                
                    WHEN No_Data_Found THEN
                        RAISE No_Userid_Found;
                    WHEN OTHERS THEN
                        RAISE;
                END;
            WHEN OTHERS THEN
                RAISE;
        END;
    
        -- send back the userkey value
        RETURN v_User;
    EXCEPTION
        WHEN No_Userid_Found THEN
            Raise_Application_Error(SQLCODE
                                   ,'Unable to lookup userkey for Oracle user = ' ||
                                    The_User -- ARM 1/2/2002 NOT USER
                                    );
            RETURN NULL;
        WHEN OTHERS THEN
            RAISE;
    END f_Get_Userkey_For_Orauser;

    FUNCTION f_Bridge_Exists_For_Bridge_GD(p_Bridge_GD IN Bridge.Bridge_GD%TYPE)
        RETURN BOOLEAN IS
        --        Lb_Bridge_Exists BOOLEAN := FALSE;
        Ll_Count PLS_INTEGER := 0;
        -- Ls_Context Kdot_Blp_Types.Context_String_Type := 'f_Bridge_Exists_For_Bridge_GD()';
    
    BEGIN
    
        SELECT 1
        INTO Ll_Count
        FROM Bridge
        WHERE bridge.bridge_GD = p_Bridge_GD;
    
        RETURN(Ll_Count > 0);
    EXCEPTION
        WHEN No_Data_Found THEN
            RETURN FALSE;
        
        WHEN OTHERS THEN
            RAISE;
    END f_Bridge_Exists_For_Bridge_GD;

    FUNCTION f_Bridge_Exists_For_Brkey(p_Brkey IN Bridge.Brkey%TYPE)
        RETURN BOOLEAN IS
        -- Lb_Bridge_Exists BOOLEAN := FALSE;
        -- Ls_Context       Kdot_Blp_Types.Context_String_Type := 'f_Bridge_Exists_Brkey()';
        Ls_Bridge_GD Bridge.Bridge_GD%TYPE;
    
    BEGIN
        Ls_Bridge_GD := f_Get_Bridge_Gd_For_Brkey(p_Brkey);
        RETURN f_Bridge_Exists_For_Bridge_GD(Ls_Bridge_GD);
    
    END f_Bridge_Exists_For_Brkey;

    FUNCTION f_Bridge_Exists_For_Bridge_Id(p_Bridge_Id IN Bridge.Bridge_Id%TYPE)
        RETURN BOOLEAN IS
        Ls_Bridge_GD Bridge.Bridge_GD%TYPE;
    
    BEGIN
        Ls_Bridge_GD := f_Get_Bridge_Gd_For_Bridge_Id(p_Bridge_Id);
        RETURN f_Bridge_Exists_For_Bridge_GD(Ls_Bridge_GD);
    END f_Bridge_Exists_For_Bridge_Id;

    -- cannot be called from sql without converting the boolean return
    FUNCTION f_Bridge_Exists(p_Bridge_GD IN Bridge.Bridge_GD%TYPE)
        RETURN BOOLEAN IS
    BEGIN
        RETURN f_Bridge_Exists_For_Bridge_GD(p_Bridge_GD);
    
    END f_Bridge_Exists;

    -- callable from SQL:
    FUNCTION f_Sql_Bridge_Exists(p_Bridge_GD IN Bridge.Bridge_GD%TYPE)
        RETURN INTEGER IS
    BEGIN
        RETURN CASE WHEN f_Bridge_Exists_For_Bridge_GD(p_Bridge_GD) THEN 1 ELSE 0 END;
    END f_Sql_Bridge_Exists;

    -- generate an inspkey ( 4 letters ) for a given BRKEY
    -- no obscenity check.

    FUNCTION f_Gen_BrM_Inspkey_4_Bridge_Gd(p_Bridge_GD IN Bridge.Bridge_GD%TYPE)
        RETURN Inspevnt.Inspkey%TYPE IS
        Ll_Tries   PLS_INTEGER := 0;
        Ls_Inspkey VARCHAR2(4) := 'XXXX';
        Ll_Hits    PLS_INTEGER := 0;
        Exc_No_Inspkey_Generated EXCEPTION;
        En_No_Inspkey_Generated PLS_INTEGER := -20998;
    
        PRAGMA EXCEPTION_INIT(Exc_No_Inspkey_Generated, -20998);
    
    BEGIN
        WHILE (Ll_Tries <= 1000)
        LOOP
        
            Ls_Inspkey := Dbms_Random.String('U', 4);
        
            SELECT 1
            INTO Ll_Hits
            FROM Inspevnt i
            WHERE i.bridge_GD = p_Bridge_GD
            AND Upper(i.Inspkey) = Ls_Inspkey; -- will raise NO_DATA_FOUND which is benign in this case and means the INSPKEY does not exist for the BRIDGE
        
            IF Ll_Hits = 0
            THEN
                EXIT;
            END IF;
        
            Ll_Tries := Ll_Tries + 1;
        
            Ls_Inspkey := NULL;
        
        END LOOP;
    
        -- we should never get here
        IF (f_Ns(Ls_Inspkey))
        THEN
            RAISE Exc_No_Inspkey_Generated;
        END IF;
    
        RETURN Ls_Inspkey;
    
    EXCEPTION
    
        WHEN No_Data_Found THEN
            -- no hit on the SELECT - must not exist in INSPEVNT
            RETURN Ls_Inspkey;
        
        WHEN Exc_No_Inspkey_Generated THEN
            Raise_Application_Error(En_No_Inspkey_Generated
                                   ,q'[Unable to generate an INSPKEY after 1000 tries!]'
                                   ,TRUE);
        WHEN OTHERS THEN
            RAISE;
    END f_Gen_BrM_Inspkey_4_Bridge_Gd;

    FUNCTION f_Gen_BrM_Inspkey_4_Brkey(p_Brkey IN Bridge.Brkey%TYPE)
        RETURN Inspevnt.Inspkey%TYPE IS
    BEGIN
        RETURN f_Gen_BrM_Inspkey_4_Bridge_Gd(f_Get_Bridge_Gd_For_Brkey(p_Brkey));
    END f_Gen_BrM_Inspkey_4_Brkey;

    FUNCTION f_Gen_Pontis_Inspkey(p_Brkey IN Bridge.Brkey%TYPE)
        RETURN Inspevnt.Inspkey%TYPE -- VARCHAR(4)
     IS
        Ls_Bridge_GD Bridge.Bridge_GD%TYPE;
    BEGIN
        Ls_Bridge_GD := f_Get_Bridge_Gd_For_Brkey(p_Brkey);
        IF Ls_Bridge_GD IS NOT NULL
        THEN
            RETURN f_Gen_BrM_Inspkey_4_Bridge_Gd(Ls_Bridge_GD);
        ELSE
            RETURN NULL;
        END IF;
    END f_Gen_Pontis_Inspkey;

    FUNCTION f_Get_On_Under_Rank(p_On_Under IN Roadway.On_Under%TYPE)
        RETURN PLS_INTEGER IS
        RESULT PLS_INTEGER;
    BEGIN
        SELECT Decode(Upper(TRIM(p_On_Under))
                     ,'1'
                     ,1 -- on record is rank 1
                     ,'2'
                     ,2
                     ,'A' -- the second record when more than 2 under records for abridge
                     ,2
                     ,'B' -- third etc.
                     ,3
                     ,'C'
                     ,4
                     ,'D'
                     ,5
                     ,'E'
                     ,6
                     ,'F'
                     ,7
                     ,'G'
                     ,8
                     ,'H'
                     ,9
                     ,'I'
                     ,10
                     ,'J'
                     ,11
                     ,'K'
                     ,12
                     ,'L'
                     ,13
                     ,'M'
                     ,14
                     ,'N'
                     ,15
                     ,'O'
                     ,16
                     ,'P'
                     ,17
                     ,'Q'
                     ,18
                     ,'R'
                     ,19
                     ,'S'
                     ,20
                     ,'T'
                     ,21
                     ,'U'
                     ,22
                     ,'V'
                     ,23
                     ,'W'
                     ,24
                     ,'X'
                     ,25
                     ,'Y'
                     ,26
                     ,'Z'
                     ,27
                     ,'22'
                     ,88
                     ,99)
        INTO RESULT
        FROM Dual;
        RETURN RESULT;
    END f_Get_On_Under_Rank;

    FUNCTION f_Gen_BrM_On_Under(p_Bridge_GD IN Bridge.Bridge_GD%TYPE)
        RETURN Roadway.On_Under%TYPE IS
        Ll_Tries         PLS_INTEGER := 0;
        Ls_On_Under      VARCHAR2(2) := 'XX'; -- test value, returned if OKAY      
        Lb_Rowexists     BOOLEAN := TRUE;
        Base_Ascii_Val   PLS_INTEGER := 65; -- A=65, 65+0 = A
        Ascii_Char_Range PLS_INTEGER := 25; -- A-Z
        No_Inspkey_Found EXCEPTION;
        -- these 2-char values are not okay to generate randomly in this domain - exclude
        Cs_Excluded_Values CONSTANT VARCHAR2(255) := '|22|24|90|92|93|94|96|97|98|99|10|30|50|51|70|';
        /* usage in ksbms_apply_changes - exclude the constants below
                   THEN
                      ls_on_under := '22';
                 ELSIF ls_feat_cross_type = '4'
                 THEN
                      ls_on_under := '24';
                 -- Hoyt 08/07/2002 Per NAC's email, on_under = feat_cross_type for these values
                 ELSIF ls_feat_cross_type IN
                               ('90', '92', '93', '94', '96', '97', '98', '99')
                 THEN
                      ls_on_under := ls_feat_cross_type;
                 ELSIF ls_feat_cross_type IN ('10', '30', '50', '51', '70')
        */
    BEGIN
        LOOP
            -- through, try to create 2 character ON_UNDER VALUE
            BEGIN
                -- Adapted from RANDOM_NUMBERFUNC in BMS_UTIL
                -- use GREATEST( 0, X ) to ensure result is > 0
                -- use LEAST( to_char(sysdate, 'DD') , 25 )  to ensure result is between 0 and 25
                --  ENGLISH ASCII DEPENDENCY - NOT PORTABLE OVERSEAS, BUT SO WHAT?
                /*      random_char :=    CHR (  first_num
                                             + start_ascii_val)
                                     || CHR (  second_num
                                             + start_ascii_val)
                                     || CHR (  third_num
                                             + start_ascii_val)
                                     || CHR (  fourth_num
                                             + start_ascii_val);
                */
            
                -- always two characters
                SELECT Chr(Greatest(0
                                   ,Least(Round((Random(2) / 100) *
                                                Ascii_Char_Range
                                               ,0))) + Base_Ascii_Val) ||
                       Chr(Greatest(0
                                   ,Least(Round(((100 - Random(2)) / 100) *
                                                Ascii_Char_Range
                                               ,0))) + Base_Ascii_Val)
                INTO Ls_On_Under
                FROM Dual;
            EXCEPTION
                WHEN No_Data_Found THEN
                
                    Raise_Application_Error(-20998
                                           ,'get_pontis_inspkey(): no_data_found!' ||
                                            Utl_Tcp.Crlf ||
                                            Dbms_Utility.Format_Error_Backtrace
                                           ,TRUE);
                WHEN OTHERS THEN
                    Raise_Application_Error(-20999
                                           ,'get_pontis_inspkey(): others!' ||
                                            Utl_Tcp.Crlf ||
                                            Dbms_Utility.Format_Error_Backtrace
                                           ,TRUE);
                
            END;
        
            -- test for uniqueness of BRKEY amd test value in table INSPEVNT ...
            -- Allen 06.21.2001 - f_any_rows_exist returns TRUE if found.
            -- All exceptions are raised in the called store procedure count_rows_for_table in PONTIS_UTIL
            -- see if in not allowed or a row already exists in ROADWAY
            Lb_Rowexists := Instr(Cs_Excluded_Values
                                 ,'|' || Ls_On_Under || '|') > 0 OR
                            f_Any_Rows_Exist('ROADWAY'
                                            ,'BRIDGE_GD = ' ||
                                             Sq(p_Bridge_GD) ||
                                             ' and ON_UNDER = ' ||
                                             Sq(Ls_On_Under));
            -- check if done..
            -- value not in excluded list
            -- no ON_UNDER exists in ROADWAY for this BRIDGE_GD
            -- OR, unhappily, we are > 100 tries
        
            EXIT WHEN(Lb_Rowexists = FALSE) OR(Ll_Tries > 100);
            -- increment counter for attempts to generate INSPKEY
            Ll_Tries := Ll_Tries + 1;
        END LOOP;
    
        IF Lb_Rowexists
           OR Ll_Tries > 100
        THEN
            -- failed after 100 attempts, or exited due to EXCEPTION!
            Ls_On_Under := NULL;
        END IF;
    
        RETURN Ls_On_Under;
    EXCEPTION
        WHEN OTHERS THEN
            RAISE;
    END f_Gen_BrM_On_Under;

    FUNCTION f_Gen_Pontis_On_Under(p_Brkey IN Bridge.Brkey%TYPE)
        RETURN Roadway.On_Under%TYPE IS
        Ls_Bridge_GD Bridge.Bridge_GD%TYPE;
    BEGIN
        Ls_Bridge_GD := f_Get_Bridge_Gd_For_Brkey(p_Brkey);
        RETURN f_Gen_BrM_On_Under(Ls_Bridge_GD);
    END f_Gen_Pontis_On_Under;

    FUNCTION f_Get_Last_Insp_By_Type(p_Bridge_GD IN Bridge.Bridge_GD%TYPE
                                    ,p_Insptype  IN VARCHAR := NULL)
        RETURN Inspevnt.Inspevnt_GD%TYPE IS
    
        -- variables
        Ls_Result   Inspevnt.Inspevnt_GD%TYPE;
        Ls_Context  Kdot_Blp_Types.Context_String_Type := q'[f_Get_Last_Insp_By_Type()]';
        Ls_Insptype VARCHAR2(2);
        -- exceptions
        Invalid_Inspection_Type EXCEPTION;
        En_Invalid_Inspection_Type PLS_INTEGER := -20999;
        PRAGMA EXCEPTION_INIT(Invalid_Inspection_Type, -20999);
    
    BEGIN
    
        IF Upper(p_Insptype) IS NOT NULL
           AND
           Instr(q'[|NB|FC|UW|OS|]', q'[|]' || Upper(p_Insptype) || q'[|]') = 0 -- no match
        THEN
            -- invalid type code not in set.
            RAISE Invalid_Inspection_Type;
        END IF;
    
        Ls_Insptype := Upper(TRIM(p_Insptype)); -- might be null
        $if cc_control.cc_debug_Mode $Then
        Dbms_Output.Put_Line(q'[Looking for INSPTYPE: ]' || Ls_Insptype);
        $end
    
        WITH Cte AS
         (SELECT I1.Inspevnt_GD
                ,Row_Number() Over(PARTITION BY I1.Bridge_GD ORDER BY I1.Inspdate DESC) Rn
          FROM Inspevnt I1
          WHERE I1.Bridge_GD = p_Bridge_GD
          AND ((p_Insptype IS NULL AND (1 = 1)) OR
                (Ls_Insptype = 'NB' AND (Nvl(I1.Nbinspdone, '0') = '1') OR
                Ls_Insptype = 'UW' AND (Nvl(I1.Uwinspdone, '0') = '1') OR
                Ls_Insptype = 'OS' AND (Nvl(I1.Osinspdone, '0') = '1') OR
                Ls_Insptype = 'FC' AND (Nvl(I1.Fcinspdone, '0') = '1'))))
        SELECT Cte.Inspevnt_GD INTO Ls_Result FROM Cte WHERE Rn = 1;
    
        RETURN Ls_Result;
    
    EXCEPTION
        WHEN No_Data_Found THEN
            RETURN NULL;
        WHEN Invalid_Inspection_Type THEN
            Raise_Application_Error(En_Invalid_Inspection_Type
                                   ,q'[An invalid inspection type was requested: ]' ||
                                    Upper(p_Insptype) ||
                                    q'[ in function ]' || Ls_Context
                                   ,TRUE);
        WHEN OTHERS THEN
            RAISE;
    END f_Get_Last_Insp_By_Type;

    -- 32 character key used for BRIDGE.DOCREFKEY for example, or any other place a unique key is needed.
    -- depends on pontis_rowkey_seq sequence.

    FUNCTION f_Gen_Pontis_Rkey RETURN VARCHAR2 IS
    BEGIN
        RETURN Sys_Guid();
    END f_Gen_Pontis_Rkey;

    FUNCTION f_Get_Nbi_Cd_Fr_Kdot_Unit_Type(v_Unit_Type Userstrunit.Unit_Type%TYPE)
        RETURN PLS_INTEGER IS
    
        -- take type, return NBI code ??
        Retval PLS_INTEGER;
    BEGIN
        SELECT Decode(v_Unit_Type
                     ,NULL
                     ,NULL
                     ,1
                     ,19
                     ,2
                     ,11
                     ,3
                     ,11
                     ,4
                     ,12
                     ,11
                     ,19
                     ,12
                     ,19
                     ,21
                     ,19
                     ,22
                     ,7
                     ,31
                     ,4
                     ,32
                     ,2
                     ,33
                     ,5
                     ,34
                     ,3
                     ,35
                     ,3
                     ,36
                     ,2
                     ,37
                     ,2
                     ,38
                     ,2
                     ,41
                     ,19
                     ,42
                     ,19
                     ,43
                     ,19
                     ,51
                     ,1
                     ,52
                     ,1
                     ,53
                     ,1
                     ,61
                     ,9
                     ,62
                     ,10
                     ,63
                     ,10
                     ,71
                     ,18
                     ,72
                     ,19
                     ,73
                     ,1
                     ,83
                     ,5
                     ,84
                     ,3
                     ,85
                     ,3
                     ,86
                     ,2
                     ,87
                     ,2
                     ,88
                     ,2
                     ,89
                     ,4
                     ,97
                     ,0
                     ,98
                     ,0)
        INTO Retval
        FROM Dual;
        RETURN Retval;
    
    EXCEPTION
        WHEN OTHERS THEN
            RAISE;
        
    END f_Get_Nbi_Cd_Fr_Kdot_Unit_Type;
    /*   -- gets comma separated list of KDOT codes back.
        -- should be 1 string of possibly several values that have to be parsed by the calling routine
    
        FUNCTION f_Get_Kdotcode_From_Nbilookup(p_Table_Name IN User_Tables.Table_Name%TYPE
                                              ,p_Field_Name IN User_Tab_Cols.Column_Name%TYPE
                                              ,p_Nbi_Code   IN Nbilookup.Nbi_Code%TYPE)
            RETURN VARCHAR2 IS
            v_Kdot_Codes VARCHAR2(1024);
        BEGIN
            --SELECT LISTAGG(last_name, '; ')
            --       WITHIN GROUP (ORDER BY hire_date, last_name) "Emp_list",
            SELECT Listagg(TRIM(Upper(Kdot_Code)), ',') Within GROUP(ORDER BY Nbi_Code, Kdot_Code)
            INTO v_Kdot_Codes
            FROM Nbilookup
            WHERE Upper(Table_Name) = Upper(p_Table_Name)
            AND Upper(Field_Name) = Upper(p_Field_Name)
            AND Upper(Nbi_Code) = Upper(p_Nbi_Code);
            RETURN v_Kdot_Codes;
        EXCEPTION
            WHEN Too_Many_Rows THEN
                RETURN 'multiple';
            WHEN No_Data_Found THEN
                RETURN NULL;
            WHEN OTHERS THEN
                RAISE;
        END f_Get_Kdotcode_From_Nbilookup;
    */
  /*  FUNCTION Recode_Designload(
                               -- Allen 5/17/2001
                               --pDesignLoad_Type, pDesignLoad_KDOT ON USERBRDG
                               -- CHANGE USERBRDG table NAME IF NECESSARY
                               -- Anchored by %TYPE
                               -- Added exception handling, messages to explain problemn
                               -- returns null if it fails - test for null in calling trigger
                               
                               -- arguments
                               Pdesignload_Type IN Userbrdg.Designload_Type%TYPE
                              ,Pdesignload_Kdot IN Userbrdg.Designload_Kdot%TYPE
                              ,Pnullallowed     IN BOOLEAN) RETURN NUMBER IS
        -- variables
        New_Designload Bridge.Designload%TYPE; -- char(1) as of Pontis 4.0
        -- change the next declaration to assign a different
        -- default return code
        Missing_Designload Bridge.Designload%TYPE := NULL;
        --'X' returned from function indicates exception raised
        --'X' cannot be a good value for designload....
        Bad_Designload Bridge.Designload%TYPE := 'X';
        -- exceptions
        Null_Designload_Type    EXCEPTION;
        Invalid_Designload_Type EXCEPTION;
        Null_Designload_Kdot    EXCEPTION;
        Invalid_Designload_Kdot EXCEPTION;
        Invalid_Result          EXCEPTION;
    BEGIN
        -- Allen 5/17/2001 change
        \*
           Validate inputs
           We must have a valid Designload_KDOT and pDesignLoad_Type
           designload >=0 and not null
           type in the magic numbers (string) 1-7 and not null
        *\
        -- Check KDOT designload values
        IF Pdesignload_Kdot IS NULL
        THEN
            RAISE Null_Designload_Kdot;
        END IF;
    
        IF Pdesignload_Kdot <= 0
        THEN
            RAISE Invalid_Designload_Kdot;
        END IF;
    
        -- Check KDOT designload types
        IF Pdesignload_Type IS NULL
        THEN
            RAISE Null_Designload_Type;
        END IF;
    
        IF Pdesignload_Type NOT IN ('1', '2', '3', '4', '5', '6', '7')
        THEN
            RAISE Invalid_Designload_Type;
        END IF;
    
        -- initialize design load result new_DesignLoad to NULL
        New_Designload := Missing_Designload;
    
        -- Recode rules
        -- If  pDesignLoad_KDOT is less than 13.5 set this item to 1;
        -- If  :NEW.pDesignLoad_Type is 1 or 2 or 4 and pDesignLoad_KDOT is  >= 13.5 and < 18, set this item to 2;
        -- If  :NEW.pDesignLoad_Type is 3 or 5 and pDesignLoad_KDOT is >=13.5 and < 18, set this item to 3;
        -- If :NEW.pDesignLoad_Type is 1, 2 or 4 and pDesignLoad_KDOT  is >= 18, set this item to 4;
        -- If :NEW.pDesignLoad_Type is 3 and pDesignLoad_KDOT is  >= 18 and < 22.5, set this item to 5;
        -- If :NEW.pDesignLoad_Type is 5 and pDesignLoad_KDOT is >= 18 and < 22.5, set this item to 6;
        -- If :NEW.pDesignLoad_Type is equal to 7, set this item to 7;
        -- If :NEW.pDesignLoad_Type is equal to 6, set this item to 8;
        -- If :NEW.pDesignLoad_Type  is 3 or 5 and pDesignLoad_KDOT is >= 22.5, set this item to 9;
    
        -- first see if in the 'outliers' 6,7
        IF Pdesignload_Type IN ('6', '7')
        THEN
            IF Pdesignload_Type = '7'
            THEN
                New_Designload := '7';
            ELSE
                New_Designload := '8';
            END IF;
        ELSE
            -- design load type not in 6,7, check by load range
            -- >0 only
            IF Pdesignload_Kdot > 0
               AND Pdesignload_Kdot < 13.5
            THEN
                New_Designload := '1';
            ELSIF Pdesignload_Kdot >= 13.5
                  AND Pdesignload_Kdot < 18
            THEN
                IF Pdesignload_Type IN ('1', '2', '4')
                THEN
                    New_Designload := '2';
                ELSIF Pdesignload_Type IN ('3', '5')
                THEN
                    New_Designload := '3';
                END IF;
            ELSIF Pdesignload_Kdot >= 18
            THEN
                IF (Pdesignload_Type IN ('1', '2', '4'))
                THEN
                    New_Designload := '4';
                ELSE
                    -- for types not in 1,2,4, decide by value of designload
                    IF Pdesignload_Kdot < 22.5
                    THEN
                        IF Pdesignload_Type = '3'
                        THEN
                            New_Designload := '5';
                        ELSIF Pdesignload_Type = '5'
                        THEN
                            New_Designload := '6';
                        END IF;
                    ELSE
                        -- >= 22.5
                        IF Pdesignload_Type IN ('3', '5')
                        THEN
                            New_Designload := '9';
                        END IF;
                    END IF;
                END IF;
            ELSE
                -- fell through, not allowed
                RAISE Invalid_Result;
            END IF;
        END IF;
    
        -- see if we got a value, raise error invalid_result if null or <=0
        -- if pNullAllowed is TRUE then NULL is OK as a result
        -- negative numbers are never OK as a result
    
        IF ((New_Designload IS NULL AND NOT Pnullallowed) OR
           To_Number(New_Designload) <= 0)
        THEN
            RAISE Invalid_Result;
        END IF;
    
        -- Success!
        RETURN(New_Designload);
    EXCEPTION
        -- TODO - KDOT Specific exception handlers
        WHEN Null_Designload_Type THEN
            BEGIN
                Raise_Application_Error(-20000
                                       ,'NULL Design Load Type passed to function recode_designload');
                RETURN(Bad_Designload);
            END;
        WHEN Invalid_Designload_Type THEN
            BEGIN
                Raise_Application_Error(-20000
                                       ,'INVALID (not in 1-7) Design Load Type passed to function recode_designload');
                RETURN(Bad_Designload);
            END;
        WHEN Null_Designload_Kdot THEN
            BEGIN
                Raise_Application_Error(-20000
                                       ,'NULL Design Load Value passed to function recode_designload');
                RETURN(Bad_Designload);
            END;
        WHEN Invalid_Designload_Kdot THEN
            BEGIN
                Raise_Application_Error(-20000
                                       ,'INVALID (<=0) Design Load Value passed to function recode_designload');
                RETURN(Bad_Designload);
            END;
        WHEN Invalid_Result THEN
            BEGIN
                Raise_Application_Error(-20000
                                       ,'INVALID result (NULL or <=0) for BRIDGE.DESIGNLOAD calculated by function recode_designload');
                RETURN(Bad_Designload);
            END;
        WHEN OTHERS THEN
            BEGIN
                Raise_Application_Error(-20000
                                       ,'Unable to determine recoded value for BRIDGE.DESIGNLOAD - ' ||
                                        SQLERRM);
                RETURN(Bad_Designload);
            END;
    END Recode_Designload;
*/
    -- ARMArshall, ARM LLC - 20190326 -renamed parameter to p_Bridge_Id
    FUNCTION f_Get_Bridge_Gd_For_Bridge_Id(p_Bridge_Id IN Bridge.Bridge_Id%TYPE)
        RETURN Bridge.Bridge_GD%TYPE -- VARCHAR2(32)
     IS
        RESULT Bridge.Bridge_GD%TYPE;
    BEGIN
        SELECT Br.Bridge_GD
        INTO RESULT
        FROM Bridge Br
        WHERE Br.Bridge_Id = p_Bridge_Id;
        RETURN RESULT;
    END f_Get_Bridge_Gd_For_Bridge_Id;

    FUNCTION f_Get_Bridge_Gd_For_Brkey(p_Brkey IN Bridge.Brkey%TYPE)
        RETURN Bridge.Bridge_GD%TYPE -- VARCHAR2(32)
     IS
        RESULT Bridge.Bridge_GD%TYPE;
    BEGIN
        SELECT Br.Bridge_GD
        INTO RESULT
        FROM Bridge Br
        WHERE Br.Brkey = p_Brkey;
        RETURN RESULT;
    END f_Get_Bridge_Gd_For_Brkey;

    FUNCTION f_Get_Insp_Gd_4_Brkey_Inspkey(p_Brkey   IN Bridge.Brkey%TYPE
                                          ,p_Inspkey IN Inspevnt.Inspkey%TYPE) -- no default
     RETURN Inspevnt.Inspevnt_GD%TYPE IS
        RESULT Inspevnt.Inspevnt_GD%TYPE;
    BEGIN
        SELECT Ins.Inspevnt_GD
        INTO RESULT
        FROM Inspevnt Ins
        WHERE Ins.Brkey = p_Brkey
        AND Ins.Inspkey = p_Inspkey;
        RETURN RESULT;
    
    END f_Get_Insp_Gd_4_Brkey_Inspkey;

    FUNCTION f_Get_Rway_Gd_For_Brkey_On_Und(p_Brkey    IN Bridge.Brkey%TYPE
                                           ,p_On_Under IN Roadway.On_Under%TYPE := q'[1]') -- default to ON record - first of 2.
        --F_GET_RWAY_GD_FOR_BRKEY_ON_UND
     RETURN Roadway.Roadway_GD%TYPE -- VARCHAR2(32)
     IS
        RESULT Roadway.Roadway_GD%TYPE;
    BEGIN
        SELECT Rw.Roadway_GD
        INTO RESULT
        FROM Roadway Rw
        WHERE Rw.Brkey = p_Brkey
        AND Rw.On_Under = p_On_Under;
        RETURN RESULT;
    END f_Get_Rway_Gd_For_Brkey_On_Und;

    FUNCTION f_Get_Str_Unit_Gd_For_Br_Sunit(p_Brkey      IN Bridge.Brkey%TYPE
                                           ,p_Strunitkey IN Structure_Unit.Strunitkey%TYPE := 1) -- default to ON record - first of 2.
     RETURN Structure_Unit.Structure_Unit_GD%TYPE -- VARCHAR2(32)
     IS
        RESULT Structure_Unit.Structure_Unit_GD%TYPE;
    BEGIN
        SELECT Structure_Unit_GD
        INTO RESULT
        FROM Structure_Unit Su
        WHERE Su.Brkey = p_Brkey
        AND Su. Strunitkey = p_Strunitkey;
    
        RETURN RESULT;
    
    END f_Get_Str_Unit_Gd_For_Br_Sunit;

    FUNCTION f_Inspection_Exists(p_Inspevnt_GD IN Inspevnt.Inspevnt_GD%TYPE)
        RETURN BOOLEAN IS
        Ll_Count PLS_INTEGER;
    
    BEGIN
    
        SELECT 1
        INTO Ll_Count
        FROM Inspevnt Ins
        WHERE Ins.Inspevnt_GD = p_Inspevnt_GD;
    
        RETURN CASE WHEN Ll_Count = 1 THEN TRUE ELSE FALSE END;
    
    EXCEPTION
        WHEN No_Data_Found THEN
            RETURN FALSE;
        WHEN OTHERS THEN
            RAISE;
    END f_Inspection_Exists;

    FUNCTION f_Insp_Exists_Brkey_Inspkey(p_Brkey   IN Bridge.Brkey%TYPE
                                        ,p_Inspkey IN Inspevnt.Inspkey%TYPE)
        RETURN BOOLEAN IS
        Lb_Inspection_Exists BOOLEAN := FALSE;
        Ls_Context           Kdot_Blp_Types.Context_String_Type := 'f_Inspection_Exists_Brkey_Inspkey()';
    BEGIN
        LOOP
            IF f_Ns(p_Brkey)
            THEN
                Pl('NULL or empty BRKEY passed to ' || Ls_Context);
                RETURN FALSE;
            END IF;
        
            IF f_Ns(p_Inspkey)
            THEN
                Pl('NULL or empty INSPKEY passed to ' || Ls_Context);
                RETURN FALSE;
            END IF;
        
            Lb_Inspection_Exists := f_Inspection_Exists(f_Get_Insp_Gd_4_Brkey_Inspkey(p_Brkey
                                                                                      
                                                                                     ,p_Inspkey));
        
            EXIT WHEN TRUE;
        END LOOP;
    
        RETURN Lb_Inspection_Exists;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN NULL;
    END f_Insp_Exists_Brkey_Inspkey;

    FUNCTION f_Sql_Ins_Exists_Brkey_Inspkey(p_Brkey   IN Bridge.Brkey%TYPE
                                           ,p_Inspkey IN Inspevnt.Inspkey%TYPE)
        RETURN PLS_INTEGER IS
    BEGIN
        RETURN CASE WHEN f_Insp_Exists_Brkey_Inspkey(p_Brkey, p_Inspkey) THEN 1 ELSE 0 END;
    
    END f_Sql_Ins_Exists_Brkey_Inspkey;

    -- function returns true if the user is assigned to an active administrator role in PON_APP_USERS_ROLES (with join to PON_APP_ROLES)
    -- or current USER is the schema OWNER and therefore permitted to be an application administrator
    FUNCTION f_Is_Administrator(p_Pon_App_Users_GD IN Pon_App_Users.Pon_App_Users_GD%TYPE
                               ,p_Schema_Owner_Ok  IN BOOLEAN := FALSE)
        RETURN BOOLEAN IS
    
        Ll_Admin_Group PLS_INTEGER := 0;
        -- Ls_Admin_Group_Codes VARCHAR2(255);
        Ll_Schema_Owner_Ok PLS_INTEGER := CASE
                                              WHEN p_Schema_Owner_Ok THEN
                                               1
                                              ELSE
                                               0
                                          END;
    BEGIN
        -- ARMarshall, ARM LLC - 20160502 - changed here to check for role membership
        -- specify conditions for email to be sent
        <<check_User_Admin_Role>>
        BEGIN
        
            --Ls_Admin_Group_Codes := f_Get_BrM_Admin_Group_Codes();
        
            SELECT 1
            INTO Ll_Admin_Group
            FROM Dual
            WHERE (Ll_Schema_Owner_Ok = 1 AND
                  USER = Sys_Context(q'[USERENV]', q'[CURRENT_SCHEMA]')) -- SCHEMA OWNER IS RUNNING THIS
            OR EXISTS (SELECT 1
                   FROM Pon_App_Users_Roles Paur
                   INNER JOIN Pon_App_Roles Par
                   ON Paur.Pon_App_Roles_GD = Par.Pon_App_Roles_GD
                   WHERE Paur.Pon_App_Users_GD = p_Pon_App_Users_GD
                   AND Instr(f_Get_BrM_Admin_Group_Codes()
                           ,q'[|]' || Par.Rolekey || q'[|]') > 0 -- these correspond to Administrator rolekey values
                   AND Par.Status = 1); -- these 3  are the roles that correspond to administrators for BLP.  Some are not defined for design in PON_APP_ROLES as of 2017-02-23, but 3 is always the admin in BrM
        
            RETURN TRUE;
        
        EXCEPTION
            WHEN No_Data_Found THEN
                RETURN FALSE;
            WHEN OTHERS THEN
                RAISE;
        END Check_User_Admin_Role;
    
    EXCEPTION
        WHEN OTHERS THEN
            RAISE;
    END f_Is_Administrator;

    FUNCTION f_Sql_Is_Administrator(p_Pon_App_Users_GD IN Pon_App_Users.Pon_App_Users_GD%TYPE)
        RETURN PLS_INTEGER IS
    BEGIN
        RETURN CASE WHEN f_Is_Administrator(p_Pon_App_Users_GD) THEN 1 ELSE 0 END;
    END f_Sql_Is_Administrator;

    -- checks to see if the userkey is in the table PON_APP_USERS_ROLES with an active rolekey of administrator (3, 15003, 15503 as of 2016-05-02)
    FUNCTION f_Sql_Is_Administrator(p_Userid          IN Pon_App_Users.Userid%TYPE
                                   ,p_Schema_Owner_Ok IN BOOLEAN := FALSE)
        RETURN PLS_INTEGER IS
    
        Ls_Pon_App_Users_GD Pon_App_Users.Pon_App_Users_GD%TYPE;
    
    BEGIN
        Ls_Pon_App_Users_GD := f_Get_p_a_Users_Gd_For_Userid(p_Userid);
    
        RETURN CASE WHEN f_Is_Administrator(Ls_Pon_App_Users_GD, FALSE) THEN 1 ELSE 0 END;
    EXCEPTION
        WHEN OTHERS THEN
            RAISE;
    END f_Sql_Is_Administrator;

    -- checks to see if the userkey is in the table PON_APP_USERS_ROLES with an active rolekey of administrator (3, 15003, 15503 as of 2016-05-02)
    FUNCTION f_Sql_Is_Administrator(p_Userkey         IN Pon_App_Users.Userkey%TYPE
                                   ,p_Schema_Owner_Ok IN BOOLEAN := FALSE)
        RETURN PLS_INTEGER IS
        Ls_Pon_App_Users_GD Pon_App_Users.Pon_App_Users_GD%TYPE;
    
    BEGIN
    
        Ls_Pon_App_Users_GD := f_Get_p_a_Users_Gd_For_Userkey(p_Userkey);
    
        RETURN CASE WHEN f_Is_Administrator(Ls_Pon_App_Users_GD
                                           ,p_Schema_Owner_Ok) THEN 1 ELSE 0 END;
    EXCEPTION
        WHEN OTHERS THEN
            RAISE;
    END f_Sql_Is_Administrator;

BEGIN
    -- initialize

    -- make sure there is a user with USERID PONTIS in the Pontis PON_APP_USERS table -- gotta be
    IF Gs_Default_Userid IS NULL
    THEN
        Gs_Default_Userid := 'PONTIS';
    END IF;

    IF Gs_Default_Userkey IS NULL
    THEN
        Gs_Default_Userkey := f_Get_Userkey_For_Orauser(Gs_Default_Userid); -- normally 1
    END IF;

END KDOT_BLP_BrM_UTIL;
/
