CREATE OR REPLACE PACKAGE Kdot_Blp_Rep IS

    ------------------------------------------------------------------------------------------
    -- Project # 7722.106 - KDOT BLP Pontis Implementation
    -- @2007 Copyright: Cambridge Systematics, Inc

    -- Author  : AMARSHALL
    -- Created : 5/16/2005
    -- Updated : 12/6/2007
    -- Purpose : Report generator package for inspection schedule compliance, arrears, notify etc
    ------------------------------------------------------------------------------------------

    -- Public type declarations
    --type <TypeName> is <Datatype>;

    --  array of individual bridgegroup entries
    TYPE Vbridgegrouparray IS VARRAY(250) OF Bridge.Bridgegroup%TYPE;

    -- bridges that are overdue to be inspected, or
    -- bridges that are coming up to be inspected, depending on the SQL!
    SUBTYPE Vbridgescursor IS Kdot_Blp_Util.Vrefcursor; -- will be RETURNING  v_Overdue_Or_Scheduled_Bridges%ROWTYPE;

    -- mailing addresses taken from COPTION entry - inherently must be <=OPTIONVAL string length
    SUBTYPE Email_Address_Type IS Kdot_Blp_Util.Email_Address_Type; --COPTIONS.OPTIONVAL%TYPE;
    -- an array of these...
    TYPE Address_List_Type IS VARRAY(500) OF Email_Address_Type;

    -- Public constant declarations
    --<ConstantName> constant <Datatype> := <Value>;
    g_Daysinmonth CONSTANT PLS_INTEGER := 31;

    -- default window for reports is 90 days
    g_Defaultthreshold CONSTANT PLS_INTEGER := 90;

    -- Public variable declarations
    --<VariableName> <Datatype>;
    g_Emailbodylineslimit PLS_INTEGER := 5000;

    -- what differentiates email addresses in a list? assume semicolon
    g_Email_Delim CHAR(1) := ';';

    -- ALL groups, bridges NBI inspections due for more than 90 days overdue
    PROCEDURE p_Nbi_90days_Overdue(Pcur IN OUT Vbridgescursor);

    PROCEDURE p_Nbi_Report_Refcursor(Pbridgegroups   IN VARCHAR2
                                    ,Preporttype     IN PLS_INTEGER
                                    , -- in arrears
                                     Plowerthreshold IN PLS_INTEGER
                                    ,Pcur            IN OUT Vbridgescursor);

    -- Public function and procedure declarations
    --function <FunctionName>(<Parameter> <Datatype>) return <Datatype>;

    PROCEDURE p_Gen_Sched_Detail_Reports(Puserid           IN Pon_App_Users.Userid%TYPE := 'PONTIS'
                                        ,Pbridgegroups     IN VARCHAR2
                                        , --BRIDGE.BRIDGEGROUP%TYPE := '*',
                                         Preporttype       IN PLS_INTEGER := 1
                                        ,Pinspectiontype   IN PLS_INTEGER := 1
                                        ,Plowerthreshold   IN PLS_INTEGER := 31
                                        ,Pupperthreshold   IN PLS_INTEGER := -1
                                        ,Pdaysmonthsflag   IN VARCHAR2 := 'D'
                                        ,Pstartday1flag    IN VARCHAR2 := 'Y'
                                        ,Psortorder        IN PLS_INTEGER := 1
                                        ,Pemailaddresslist IN OUT VARCHAR2
                                        ,Pemailsender      IN VARCHAR2 := 'KDOT.BLP@ks.gov'
                                        ,Poutputtarget     IN PLS_INTEGER := 1
                                        ,Pjobid            IN PLS_INTEGER := -1
                                        ,Pcur              IN OUT Vbridgescursor
                                        ,Psqlfilter        IN VARCHAR2 := '');

    -- routine to turn text list with delimiters into a parsed collection
    PROCEDURE p_Parse_Bridgegroups(Pbridgegroups      IN VARCHAR2
                                  ,Pbridgegroupsarray OUT Vbridgegrouparray);
    PROCEDURE p_Parse_Email_Addresses(Pemailaddresslist IN VARCHAR2
                                     ,Paddresslistarray OUT Address_List_Type);
    PROCEDURE p_Add_Cols_To_Retrieve_By_Type(The_Sqlstring       IN OUT VARCHAR2
                                            ,The_Reporttype      IN PLS_INTEGER
                                            ,The_Diff_Months_Col IN VARCHAR2
                                            ,The_Nextinsp_Col    IN VARCHAR2
                                            ,The_Lower_Threshold IN PLS_INTEGER := 31
                                            ,The_Upper_Threshold IN PLS_INTEGER := -1
                                            ,The_Daysmonths_Flag IN VARCHAR2 := 'D');
    PROCEDURE p_Prepare_Orderby(The_Orderbystring     OUT VARCHAR2
                               ,The_Reporttype        IN PLS_INTEGER
                               ,The_Sortorder         IN PLS_INTEGER := 0
                               ,The_Inspectiondatecol IN VARCHAR2);

    -- DOCUMENT RELATED PROCEDURES

    PROCEDURE p_Retrieve_Documents(Pbrkey            IN Bridge.Brkey%TYPE
                                  ,Pinspkey          IN Inspevnt.Inspkey%TYPE
                                  ,Pdoc_Type_Key     IN Kdotblp_Documents.Doc_Type_Key%TYPE
                                  ,Pdoc_subType_Key     IN Kdotblp_Documents.Doc_Subtype_Key%TYPE
                                  ,Pdoc_Status       IN Kdotblp_Documents.Doc_Status%TYPE
                                  ,Psource_File_Name IN Kdotblp_Documents.Source_File_Name%TYPE
                                  ,Ptarget_File_Name IN Kdotblp_Documents.Target_File_Name%TYPE
                                  ,Crsdocumentrow    OUT SYS_REFCURSOR);

END Kdot_Blp_Rep;
/
CREATE OR REPLACE PACKAGE BODY Kdot_Blp_Rep IS

    ------------------------------------------------------------------------------------------
    -- Project # 7722.106 - KDOT BLP Pontis Implementation
    -- @2007 Copyright: Cambridge Systematics, Inc

    -- Author  : AMARSHALL
    -- Created : 5/16/2005
    -- Updated : 12/6/2007
    -- Purpose : Report generator package for inspection schedule compliance, arrears, notify etc
    -- Modified: 04/12/2013 by Ed Lewis
    ------------------------------------------------------------------------------------------

    -- Private type declarations
    --type <TypeName> is <Datatype>;

    -- Private constant declarations
    --<ConstantName> constant <Datatype> := <Value>;

    -- Private variable declarations
    --<VariableName> <Datatype>;

    -- Function and procedure implementations
    /*
    function <FunctionName>(<Parameter> <Datatype>) return <Datatype> is
      <LocalVariable> <Datatype>;
    begin
      <Statement>;
      return(<Result>);
    end;
    */

    PROCEDURE Raisex(Err_In IN INTEGER := SQLCODE
                    ,Msg_In IN VARCHAR2 := NULL) IS
    BEGIN
        Kdot_Blp_Errpkg.Raisex(Err_In, Msg_In);
    END Raisex;

    PROCEDURE Assert(Condition_In       IN BOOLEAN
                    ,Message_In         IN VARCHAR2
                    ,Raise_Exception_In IN BOOLEAN := TRUE
                    ,Exception_In       IN VARCHAR2
                     
                            := 'VALUE_ERROR') IS
    BEGIN
        Kdot_Blp_Errpkg.Assert(Condition_In
                              ,Message_In
                              ,Raise_Exception_In
                              ,Exception_In);
    END Assert;

    PROCEDURE p_Add_Bridgegroups_To_Where(The_Sqlstring    IN OUT VARCHAR2
                                         ,The_Bridgegroups IN Vbridgegrouparray) IS
    
        i PLS_INTEGER;
    
    BEGIN
        <<control_Loop>>
        LOOP
            BEGIN
                IF The_Bridgegroups IS NULL
                THEN
                    -- get out!
                    EXIT;
                END IF;
            
                The_Sqlstring := The_Sqlstring || ' ('; -- begin x or y or z WHERE token
            
                IF The_Bridgegroups.Count > 0
                THEN
                    FOR i IN 1 .. The_Bridgegroups.Count
                    LOOP
                        The_Sqlstring := The_Sqlstring ||
                                         ' v1.BRIDGEGROUP = ' ||
                                         Kdot_Blp_Util.Sq(The_Bridgegroups(i));
                    
                        -- if we have more than 1 group to process, append OR
                        IF The_Bridgegroups.Count > 1
                           AND i < The_Bridgegroups.Count
                        THEN
                            The_Sqlstring := The_Sqlstring || '  OR  ';
                        END IF;
                    END LOOP;
                END IF;
            END;
            The_Sqlstring := The_Sqlstring || ' ) AND ';
            -- always!!!
            EXIT WHEN TRUE;
        
        END LOOP Control_Loop;
    END p_Add_Bridgegroups_To_Where;

    PROCEDURE p_Add_Cols_To_Retrieve_By_Type(The_Sqlstring       IN OUT VARCHAR2
                                            ,The_Reporttype      IN PLS_INTEGER
                                            ,The_Diff_Months_Col IN VARCHAR2
                                            ,The_Nextinsp_Col    IN VARCHAR2
                                            ,The_Lower_Threshold IN PLS_INTEGER := 31
                                            ,The_Upper_Threshold IN PLS_INTEGER := -1
                                            ,The_Daysmonths_Flag IN VARCHAR2 := 'D') IS
        Ls_Eval_Function VARCHAR2(80);
        Ll_Low           PLS_INTEGER;
        Ll_High          PLS_INTEGER;
    
    BEGIN
    
        IF The_Reporttype = 1
        THEN
            --Notify Report
            Ls_Eval_Function := ' kdot_blp_util.f_period_overdue';
        ELSIF The_Reporttype = 2
        THEN
            --Upcoming Report
            Ls_Eval_Function := ' kdot_blp_util.f_period_coming_due';
        ELSIF The_Reporttype = 3
        THEN
            --Arrears Report
            Ls_Eval_Function := ' kdot_blp_util.f_days_overdue';
        END IF;
    
        -- at least one of these must be a good threshold value...
        -- if empty, all null or <=0 then raise an exception
        IF (The_Lower_Threshold IS NULL OR The_Lower_Threshold <= 0)
           AND (The_Upper_Threshold IS NULL OR The_Upper_Threshold <= 0)
        THEN
            Kdot_Blp_Errpkg.Raisex(Kdot_Blp_Errors.En_Bad_Threshold
                                  ,'Upper and lower date thresholds are invalid');
        END IF;
    
        IF The_Lower_Threshold IS NULL
        THEN
            Ll_Low := -1;
        ELSE
            Ll_Low := The_Lower_Threshold;
        END IF;
    
        IF The_Upper_Threshold IS NULL
        THEN
            Ll_High := -1;
        ELSE
            Ll_High := The_Upper_Threshold;
        END IF;
    
        IF The_Reporttype = 1
           OR The_Reporttype = 2
        THEN
            The_Sqlstring := The_Sqlstring || The_Diff_Months_Col ||
                             ' IS NOT NULL AND ' || Ls_Eval_Function || '( ' ||
                             The_Nextinsp_Col || ' ,' || To_Char(Ll_Low) || ' ,' ||
                             To_Char(Ll_High) || ', ' ||
                             Kdot_Blp_Util.Sq(The_Daysmonths_Flag) ||
                             ' ) IS NOT NULL ';
        ELSE
            -- the_reportType = 3 = Arrears Report
            -- uses the_upper_threshold; the_lower_threshold is not necessary
            The_Sqlstring := The_Sqlstring || The_Diff_Months_Col ||
                             ' IS NOT NULL AND ' || Ls_Eval_Function || '( ' ||
                             The_Nextinsp_Col || ' ,' || To_Char(Ll_High) ||
                             ' ) IS NOT NULL ';
        END IF;
    
    EXCEPTION
        WHEN Kdot_Blp_Errors.Exc_Bad_Threshold THEN
            Raisex(Kdot_Blp_Errors.En_Bad_Threshold
                  ,'p_add_cols_to_retrieve_by_typ');
        WHEN OTHERS THEN
            RAISE;
        
    END p_Add_Cols_To_Retrieve_By_Type;

    PROCEDURE p_Prepare_Orderby(The_Orderbystring     OUT VARCHAR2
                               ,The_Reporttype        IN PLS_INTEGER
                               ,The_Sortorder         IN PLS_INTEGER := 0
                               ,The_Inspectiondatecol IN VARCHAR2) IS
    
        Ls_Sort          VARCHAR2(80); -- becomes for example, v1.NEXTINSP ASC
        Ls_Orderbystring VARCHAR2(400);
    
    BEGIN
        /*
        -- sorts -
            0 - ORDER BY v1.BRIDGEGROUP ASC, v1.COUNTY, v1.PLACECODE, v1.STRUCT_NUM ASC ';
            1 - ORDER BY v1.BRIDGEGROUP ASC, v1.COUNTY, v1.PLACECODE, Inspection due date ASC , v1.STRUCT_NUM ASC ';
            2 - ORDER BY v1.BRIDGEGROUP ASC, v1.COUNTY, v1.PLACECODE, Inspection due date DESC , v1.STRUCT_NUM ASC ';
            3 - ORDER BY v1.BRIDGEGROUP ASC, Inspection due date ASC , v1.COUNTY, v1.PLACECODE, v1.STRUCT_NUM ASC ';
            4 - ORDER BY v1.BRIDGEGROUP ASC, Inspection due date DESC , v1.COUNTY, v1.PLACECODE, Inspection due date ASC , v1.STRUCT_NUM ASC ';
        */
        -- determine if inspection dates sort from today up to future or from today
        -- down from most distant future, or from today to most distant past
        CASE The_Sortorder
            WHEN 0 THEN
                -- just in administrative order
                Ls_Orderbystring := ' ORDER BY v1.BRIDGEGROUP ASC,' ||
                                    ' v1.COUNTY, v1.PLACECODE, v1.STRUCT_NUM ASC ';
            WHEN 1 THEN
                Ls_Sort          := TRIM(The_Inspectiondatecol || ' ASC ');
                Ls_Orderbystring := ' ORDER BY v1.BRIDGEGROUP ASC, ' ||
                                    ' v1.COUNTY, v1.PLACECODE, ' || Ls_Sort ||
                                    ',  v1.STRUCT_NUM ASC ';
            WHEN 2 THEN
                Ls_Sort          := TRIM(The_Inspectiondatecol || ' DESC ');
                Ls_Orderbystring := ' ORDER BY v1.BRIDGEGROUP ASC, ' ||
                                    ' v1.COUNTY, v1.PLACECODE, ' || Ls_Sort ||
                                    ',  v1.STRUCT_NUM ASC ';
            WHEN 3 THEN
                Ls_Sort          := TRIM(The_Inspectiondatecol || ' ASC');
                Ls_Orderbystring := ' ORDER BY v1.BRIDGEGROUP ASC, ' ||
                                    Ls_Sort ||
                                    ', v1.COUNTY, v1.PLACECODE, ' ||
                                    ' v1.STRUCT_NUM ASC ';
            WHEN 4 THEN
                Ls_Sort          := TRIM(The_Inspectiondatecol || ' DESC');
                Ls_Orderbystring := ' ORDER BY v1.BRIDGEGROUP ASC, ' ||
                                    Ls_Sort ||
                                    ', v1.COUNTY, v1.PLACECODE, ' ||
                                    ' v1.STRUCT_NUM ASC ';
            ELSE
                Ls_Orderbystring := ' ORDER BY v1.BRIDGEGROUP ASC,' ||
                                    ' v1.COUNTY, v1.PLACECODE, v1.STRUCT_NUM ASC ';
        END CASE;
    
        The_Orderbystring := ' ' || TRIM(Ls_Orderbystring);
    
    END p_Prepare_Orderby;

    PROCEDURE p_Prepare_Email_Detail(The_Reporttype     IN PLS_INTEGER := 1
                                    ,The_Inspectiontype IN PLS_INTEGER := 1
                                    ,The_Daysmonthsflag IN VARCHAR2 := 'M'
                                    ,The_Startday1flag  IN VARCHAR2 := 'Y'
                                    ,The_Record         IN v_Overdue_Or_Scheduled_Bridges%ROWTYPE
                                    ,The_Message_Line   OUT VARCHAR2)
    
     IS
    
        Ll_Period       PLS_INTEGER;
        Ls_Diff         VARCHAR2(12);
        Ls_Message_Line VARCHAR2(255);
    
    BEGIN
    
        Ll_Period := 0;
    
        IF The_Reporttype = 1
        THEN
            -- 1 = NOTIFY, 2 = UPCOMING, 3 = ARREARS
            CASE The_Inspectiontype
                WHEN 1 THEN
                    IF Upper(The_Daysmonthsflag) = 'M'
                    THEN
                        Ll_Period := Kdot_Blp_Util.f_Months_Overdue(The_Record.Nextinsp
                                                                   ,-1
                                                                   ,The_Startday1flag);
                    ELSE
                        Ll_Period := Kdot_Blp_Util.f_Days_Overdue(The_Record.Nextinsp
                                                                 ,The_Startday1flag);
                    END IF;
                WHEN 2 THEN
                    IF Upper(The_Daysmonthsflag) = 'M'
                    THEN
                        Ll_Period := Kdot_Blp_Util.f_Months_Overdue(The_Record.Uwnextdate
                                                                   ,-1
                                                                   ,The_Startday1flag);
                    ELSE
                        Ll_Period := Kdot_Blp_Util.f_Days_Overdue(The_Record.Uwnextdate
                                                                 ,The_Startday1flag);
                    END IF;
                WHEN 3 THEN
                    IF Upper(The_Daysmonthsflag) = 'M'
                    THEN
                        Ll_Period := Kdot_Blp_Util.f_Months_Overdue(The_Record.Fcnextdate
                                                                   ,-1
                                                                   ,The_Startday1flag);
                    ELSE
                        Ll_Period := Kdot_Blp_Util.f_Days_Overdue(The_Record.Fcnextdate
                                                                 ,The_Startday1flag);
                    END IF;
                WHEN 4 THEN
                    IF Upper(The_Daysmonthsflag) = 'M'
                    THEN
                        Ll_Period := Kdot_Blp_Util.f_Months_Overdue(The_Record.Osnextdate
                                                                   ,-1
                                                                   ,The_Startday1flag);
                    ELSE
                        Ll_Period := Kdot_Blp_Util.f_Days_Overdue(The_Record.Osnextdate
                                                                 ,The_Startday1flag);
                    END IF;
                ELSE
                    IF Upper(The_Daysmonthsflag) = 'M'
                    THEN
                        Ll_Period := The_Record.Nbi_Diff_Months;
                    ELSE
                        Ll_Period := Kdot_Blp_Util.f_Days_Overdue(The_Record.Nextinsp
                                                                 ,The_Startday1flag);
                    END IF;
            END CASE;
        
        ELSIF The_Reporttype = 2
        THEN
            -- 2 = UPCOMING Report
            CASE The_Inspectiontype
                WHEN 1 THEN
                    IF Upper(The_Daysmonthsflag) = 'M'
                    THEN
                        Ll_Period := Kdot_Blp_Util.f_Months_Overdue(The_Record.Nextinsp
                                                                   ,-1
                                                                   ,The_Startday1flag);
                    ELSE
                        Ll_Period := Kdot_Blp_Util.f_Days_Coming_Due(The_Record.Nextinsp
                                                                    ,The_Startday1flag);
                    END IF;
                WHEN 2 THEN
                    IF Upper(The_Daysmonthsflag) = 'M'
                    THEN
                        Ll_Period := Kdot_Blp_Util.f_Months_Overdue(The_Record.Uwnextdate
                                                                   ,-1
                                                                   ,The_Startday1flag);
                    ELSE
                        Ll_Period := Kdot_Blp_Util.f_Days_Coming_Due(The_Record.Uwnextdate
                                                                    ,The_Startday1flag);
                    END IF;
                WHEN 3 THEN
                    IF Upper(The_Daysmonthsflag) = 'M'
                    THEN
                        Ll_Period := Kdot_Blp_Util.f_Months_Overdue(The_Record.Fcnextdate
                                                                   ,-1
                                                                   ,The_Startday1flag);
                    ELSE
                        Ll_Period := Kdot_Blp_Util.f_Days_Coming_Due(The_Record.Fcnextdate
                                                                    ,The_Startday1flag);
                    END IF;
                WHEN 4 THEN
                    IF Upper(The_Daysmonthsflag) = 'M'
                    THEN
                        Ll_Period := Kdot_Blp_Util.f_Months_Overdue(The_Record.Osnextdate
                                                                   ,-1
                                                                   ,The_Startday1flag);
                    ELSE
                        Ll_Period := Kdot_Blp_Util.f_Days_Coming_Due(The_Record.Osnextdate
                                                                    ,The_Startday1flag);
                    END IF;
                ELSE
                    IF Upper(The_Daysmonthsflag) = 'M'
                    THEN
                        Ll_Period := The_Record.Nbi_Diff_Months;
                    ELSE
                        Ll_Period := Kdot_Blp_Util.f_Days_Coming_Due(The_Record.Nextinsp
                                                                    ,The_Startday1flag);
                    END IF;
            END CASE;
        
        ELSE
            -- Arrears Report
            CASE The_Inspectiontype
                WHEN 1 THEN
                    IF Upper(The_Daysmonthsflag) = 'M'
                    THEN
                        Ll_Period := Kdot_Blp_Util.f_Months_Overdue(The_Record.Nextinsp
                                                                   ,-1
                                                                   ,The_Startday1flag);
                    ELSE
                        Ll_Period := Kdot_Blp_Util.f_Days_Overdue(The_Record.Nextinsp
                                                                 ,The_Startday1flag);
                    END IF;
                WHEN 2 THEN
                    IF Upper(The_Daysmonthsflag) = 'M'
                    THEN
                        Ll_Period := Kdot_Blp_Util.f_Months_Overdue(The_Record.Uwnextdate
                                                                   ,-1
                                                                   ,The_Startday1flag);
                    ELSE
                        Ll_Period := Kdot_Blp_Util.f_Days_Overdue(The_Record.Uwnextdate
                                                                 ,The_Startday1flag);
                    END IF;
                WHEN 3 THEN
                    IF Upper(The_Daysmonthsflag) = 'M'
                    THEN
                        Ll_Period := Kdot_Blp_Util.f_Months_Overdue(The_Record.Fcnextdate
                                                                   ,-1
                                                                   ,The_Startday1flag);
                    ELSE
                        Ll_Period := Kdot_Blp_Util.f_Days_Overdue(The_Record.Fcnextdate
                                                                 ,The_Startday1flag);
                    END IF;
                WHEN 4 THEN
                    IF Upper(The_Daysmonthsflag) = 'M'
                    THEN
                        Ll_Period := Kdot_Blp_Util.f_Months_Overdue(The_Record.Osnextdate
                                                                   ,-1
                                                                   ,The_Startday1flag);
                    ELSE
                        Ll_Period := Kdot_Blp_Util.f_Days_Overdue(The_Record.Osnextdate
                                                                 ,The_Startday1flag);
                    END IF;
                ELSE
                    IF Upper(The_Daysmonthsflag) = 'M'
                    THEN
                        Ll_Period := The_Record.Nbi_Diff_Months;
                    ELSE
                        Ll_Period := Kdot_Blp_Util.f_Days_Overdue(The_Record.Nextinsp
                                                                 ,The_Startday1flag);
                    END IF;
            END CASE;
        END IF;
    
        Ls_Diff := To_Char(Ll_Period, '9,990');
    
        /****** ORIGINAL MESSAGE LINE PROGRAMMED BY ALLEN *******/
        /*    ls_message_line := LPAD(the_record.STRUCT_NUM, 15, ' ') || ' / ' ||
        the_record.COUNTY || ' / ' || the_record.PLACECODE || ' / ' ||
        RPAD(SUBSTR(TRIM(SUBSTR(the_record.FEATINT, 1, 12)) || ' / ' ||
                    TRIM(substr(the_record.FACILITY, 1, 12)), 1, 24), 24, ' ') || ' / '; */
    
        Ls_Message_Line := Lpad(The_Record.Struct_Num, 15, ' ') ||
                           '    ||  ' ||
                           Rpad(The_Record.Strucname, 15, '_') ||
                           '    ||  ' ||
                           Rpad(Rtrim(Upper(The_Record.Featint)), 20, '_') ||
                           '    ||  ' ||
                           Rpad(Rtrim(Upper(The_Record.Facility)), 20, '_') ||
                           '    ||  ';
        /*RPAD(SUBSTR(TRIM(SUBSTR(the_record.FEATINT, 1, 20)) || '   ||   ' ||
        TRIM(substr(the_record.FACILITY, 1, 20)), 1, 24), 24, ' ') || '  ||  ';*/
        /*RPAD(SUBSTR(TRIM(SUBSTR(the_record.FEATINT, 1, 20)) || '   ||   ' ||
        TRIM(substr(the_record.FACILITY, 1, 20)), 1, 24), 24, ' ') || '  ||  ';  */
        CASE The_Inspectiontype
            WHEN 1 THEN
                -- NBI
                Ls_Message_Line := Ls_Message_Line ||
                                   To_Char(The_Record.Lastinsp
                                          ,'MM/DD/YYYY') || '  ||  ' ||
                                   To_Char(The_Record.Nextinsp
                                          ,'MM/DD/YYYY') || ' || ' ||
                                   Ls_Diff || '    ||  ' ||
                                   Nvl(The_Record.Brinspfreq, -1);
            WHEN 2 THEN
                -- UW
                Ls_Message_Line := Ls_Message_Line ||
                                   To_Char(The_Record.Uwlastinsp
                                          ,'MM/DD/YYYY') || ' || ' ||
                                   To_Char(The_Record.Uwnextdate
                                          ,'MM/DD/YYYY') || ' || ' ||
                                   Ls_Diff || '    ||  ' ||
                                   Nvl(The_Record.Uwinspfreq, -1);
            WHEN 3 THEN
                -- FC
                Ls_Message_Line := Ls_Message_Line ||
                                   To_Char(The_Record.Fclastinsp
                                          ,'MM/DD/YYYY') || ' || ' ||
                                   To_Char(The_Record.Fcnextdate
                                          ,'MM/DD/YYYY') || ' || ' ||
                                   Ls_Diff || '    ||  ' ||
                                   Nvl(The_Record.Fcinspfreq, -1);
            WHEN 4 THEN
                -- OS
                Ls_Message_Line := Ls_Message_Line ||
                                   To_Char(The_Record.Oslastinsp
                                          ,'MM/DD/YYYY') || ' || ' ||
                                   To_Char(The_Record.Osnextdate
                                          ,'MM/DD/YYYY') || ' || ' ||
                                   Ls_Diff || '    ||  ' ||
                                   Nvl(The_Record.Osinspfreq, -1);
            ELSE
                Ls_Message_Line := Ls_Message_Line ||
                                   To_Char(The_Record.Lastinsp
                                          ,'MM/DD/YYYY') || ' || ' ||
                                   To_Char(The_Record.Nextinsp
                                          ,'MM/DD/YYYY') || ' || ' ||
                                   Ls_Diff || '    ||  ' ||
                                   Nvl(The_Record.Brinspfreq, -1);
        END CASE;
    
        The_Message_Line := Ls_Message_Line;
    
    EXCEPTION
        WHEN Kdot_Blp_Errors.Exc_Gen_Message_Line_Failed THEN
            Raisex(Kdot_Blp_Errors.En_Gen_Message_Line_Failed);
        WHEN OTHERS THEN
            RAISE;
        
    END p_Prepare_Email_Detail;

    PROCEDURE p_Gen_Sched_Detail_Reports(Puserid           IN Pon_App_Users.Userid%TYPE := 'PONTIS'
                                        ,Pbridgegroups     IN VARCHAR2
                                        , --BRIDGE.BRIDGEGROUP%TYPE := '*',
                                         Preporttype       IN PLS_INTEGER := 1
                                        ,Pinspectiontype   IN PLS_INTEGER := 1
                                        ,Plowerthreshold   IN PLS_INTEGER := 31
                                        ,Pupperthreshold   IN PLS_INTEGER := -1
                                        ,Pdaysmonthsflag   IN VARCHAR2 := 'D'
                                        ,Pstartday1flag    IN VARCHAR2 := 'Y'
                                        ,Psortorder        IN PLS_INTEGER := 1
                                        ,Pemailaddresslist IN OUT VARCHAR2
                                        ,Pemailsender      IN VARCHAR2 := 'KDOT.BLP@ks.gov'
                                        ,Poutputtarget     IN PLS_INTEGER := 1
                                        ,Pjobid            IN PLS_INTEGER := -1
                                        ,Pcur              IN OUT Vbridgescursor
                                        ,Psqlfilter        IN VARCHAR2 := '') IS
    
        /*
        - Procedure retrieves records from the bridge database.
        - Threshold criteria determines whether the bridge last inspection fall into the
          category of 1) Overdue or 2) Upcoming as desired.
        - Reports are always divided into overdue and upcoming.
        - Thresholds eliminate unwanted noise.
        - Reports can be for NBI, UNDERWATER, FRACTURE CRITICAL, or OTHER SPECIAL inspection type.
        - Reports can be run statewide with * for the bridgegroup argument or for a particular bridgegroup.
        
        Reports are sorted by
                BRIDGEGROUP
                COUNTY
                PLACECODE
                BRIDGE_ID (STRUCT_NUM)
                DATE DUE ( ALWAYS ASCENDING MEANING MOST IMMINENT SHOW UP FIRST)
                OVERDUE ( ASCENDING, MEANING MOST OVERDUE SHOWS FIRST)
                 or      (DESCENDING, MEANING JUST MISSED FIRST, MOST OVERDUE LAST)
        
        Parameters:
                 pUserID IN USERS.USERID%TYPE - captured from web request or supplied by job. Currently not being used.
        
                 pBridgegroup IN pBridgegroup      IN vBridgeGroupArray, --BRIDGE.BRIDGEGROUP%TYPE := '*'
        
                              if *, values are taken from user BRIDGEGROUP values found in WHERE clause in USERACC, or not
                              applied at all if user has global access.  A user may not request a BRIDGEGROUP for which they
                              have no viewing privileges.
                              NB - THIS IS AN ARRAY OF BRIDGE GROUP INDIVIDUAL ENTRIES
        
                 pReportType IN PLS_INTEGER,               <<< DEFAULT IS 1
                             1=NOTIFY
                             2=UPCOMING
                             3=ARREARS
        
                 pInspectionType IN PLS_INTEGER,            <<< DEFAULT IS 1
                             1 = NBI
                             2 = UW
                             3 = FC
                             4 = OS
        
                 pLowerThreshold  IN PLS_INTEGER,            <<< IF NOT SPECIFIED, TAKEN FROM COPTIONS, OR IF NOT FOUND IN COPTIONS,
                                                                HARDWIRED DEFAULT gi_overdue_threshold, gi_upcoming_threshold
                                                                DEFINED IN PACKAGE KDOT_BLP_UTIL
                                                                and used in FUNCTION f_past_due or f_coming_due and variants
                 pUpperThreshold  IN PLS_INTEGER,            <<< IF NOT SPECIFIED, TAKEN FROM COPTIONS, OR IF NOT FOUND IN COPTIONS,
                                                                HARDWIRED DEFAULT gi_overdue_threshold, gi_upcoming_threshold
                                                                DEFINED IN PACKAGE KDOT_BLP_UTIL
                                                                and used in FUNCTION f_past_due or f_coming_due and variants
        
                 pDaysMonthsFlag IN VARCHAR2, - D or M for Days or Months
        
                 pSortOrder  IN PLS_INTEGER,
                      -- sorts -
                      0 - ORDER BY v1.BRIDGEGROUP ASC, v1.COUNTY, v1.PLACECODE, v1.STRUCT_NUM ASC ';
                      1 - ORDER BY v1.BRIDGEGROUP ASC, v1.COUNTY, v1.PLACECODE, Inspection due date ASC , v1.STRUCT_NUM ASC ';
                      2 - ORDER BY v1.BRIDGEGROUP ASC, v1.COUNTY, v1.PLACECODE, Inspection due date DESC , v1.STRUCT_NUM ASC ';
                      3 - ORDER BY v1.BRIDGEGROUP ASC, Inspection due date ASC , v1.COUNTY, v1.PLACECODE, v1.STRUCT_NUM ASC ';
                      4 - ORDER BY v1.BRIDGEGROUP ASC, Inspection due date DESC , v1.COUNTY, v1.PLACECODE, Inspection due date ASC , v1.STRUCT_NUM ASC ';
        
        
                 pEmailAddressList IN VARCHAR2(4000),       <<< may be empty, uses list for each bridgegroup to be processed, or overridden here
                 pEmailSender      IN VARCHAR2    := ' KDOT.BLP@ks.gov',
                                   this is the address sending all mail from KDOT BLP ( probably should be a real mailbox for reply reasons)
        
                 pOutputTarget IN PLS_INTEGER,              <<< DEFAULT IS 1
                            1 - Email,
                            2 - MESSAGE LOG (KDOT_BLP_UTIL_MSG_LOG)
                            3 - DBMS_OUTPUT (view/print....)
                            4 - ROWSET ( CURSOR, TO DO ) - Preformatted text source for a calling report (lets report format the rowset)
                            5 - XMLROWSET ( TO DO LATER ) - Preformatted XML document source for a calling report (lets report format the XML rowset)
        
                 pJobID IN PLS_INTEGER                      <<< DETERMINED BY ORACLE JOB RUNNER...,.
        */
    
        -- locals holding either the parm or the lookup
        -- NB, if bridgegroup values are full 30 chars,
        -- ls_bridgegroups local cannot accommodate more than 4000/30 BRIDGEGROUPS (like 133 or so!!!
        --ls_USERID             All_Users.Username%TYPE;
        Ls_Bridgegroups_Array Vbridgegrouparray := Vbridgegrouparray(); -- set to empty
        Ls_Insptypelabel      VARCHAR2(40);
        Ll_Threshold_Days     PLS_INTEGER;
        Ls_Orderbystring      VARCHAR2(400);
        Ls_Emailaddress       Email_Address_Type;
        Ls_Senderemailaddress Email_Address_Type;
        Ls_Default_Replyto    Email_Address_Type;
    
        Ls_Message_Line VARCHAR2(400);
        Ls_Subject      VARCHAR2(255);
        Ls_Email_List   Address_List_Type := Address_List_Type();
        --lv_parse_result        KDOT_BLP_UTIL.generic_list_type := KDOT_BLP_UTIL.generic_list_type(); -- initialize to EMPTY ( not null );
        Ls_Header              VARCHAR2(8192); -- really big...
        Ll_Days                PLS_INTEGER;
        Ls_Overdue_Or_Upcoming VARCHAR2(80);
        Ls_Window              VARCHAR2(40); -- e.g.60-90 >90 <30 etc.
        Ls_Diffcol             VARCHAR2(40) := 'v1.nbi_diff_months';
        Ls_Sched_Date_Col      VARCHAR2(40) := 'v1.NEXTINSP';
        Lb_Debug               BOOLEAN := FALSE; -- off by default! Set TRUE to limit processing to the first bridgegroup
        Ls_Printdate           VARCHAR2(40);
        Ll_Recordcount         PLS_INTEGER := 0;
        Ll_Cnt                 PLS_INTEGER := 0;
        Ll_Grp_Cnt             PLS_INTEGER := 0;
        Ll_Print_Limit         PLS_INTEGER := 200;
        --Crlf                   VARCHAR2(2) := Chr(13) || Chr(10);
        Ll_Linewidth           PLS_INTEGER := 132;
        Lb_Newgroup            BOOLEAN := TRUE;
        Ls_Rest                Coptions.Optionval%TYPE;
    
        -- cursor of bridges
        Lcur_Bridges        Vbridgescursor;
        Ls_Sqlstring        VARCHAR2(8192);
        Ls_Countsqlstring   VARCHAR2(8192);
        Ls_Last_Bridgegroup Bridge.Bridgegroup%TYPE;
    
        -- bridge record type for view
        l_Bridge_Record v_Overdue_Or_Scheduled_Bridges%ROWTYPE;
    
        -- for mail
        Mailer_Connect Utl_Smtp.Connection;
        Mailhost       Coptions.Optionval%TYPE;
        --ls_context     VARCHAR2(80) := 'p_gen_sched_detail_reports';
    
        -- <<MainBlock>>
    BEGIN
    
        <<control_Loop>>
        LOOP
            BEGIN
                SELECT To_Char(SYSDATE, 'DY, DD MON YYYY HH24:MI:SS ') ||
                       Nvl(Kdot_Blp_Util.f_Get_Coption_Value('TIMEZONE')
                          ,'CST')
                INTO Ls_Printdate
                FROM Dual;
            
                /*
                -- CAPTURE AND VALIDATE PARMS
                
                -- CAPTURE USER
                -- call p_getUSERKEYFORUSERID
                
                -- GET BRIDGEGROUPS FOR USER (retrieve, if any, parse out BRIDGEGROUP)
                -- call p_genBridgeGroupWhereClause - returns a tested WHERE clause, used in p_genRowsetXYZ, uses USERKEY from p_getUSERKEYFORUSERID
                
                -- CAPTURE email distros for the BRIDGEGROUPS, or if no BRIDGEGROUP restriction, arrears/upcoming
                -- distro list for database (IMPORTANT:  email distros are not USER based - either ubiquitous or by BRIDGEGROUP)
                -- call p_genEmailList, uses BRIDGEGROUP value (or the global *)
                
                -- FORMULATE ROWSET
                -- call p_genRowsetXYZ
                
                -- PROCESS ROWSET IN ORDER, EMITTING GROUP HEADERS, COUNTY HEADERS, PLACE CODE HEADERS, THEN BRIDGE DETAIL, WITH BRIDGES
                -- SORTED BY INSPECTION
                -- call p_genReportBody
                -- AND
                -- TODO - call p_genReportXMLDocument
                
                -- Create Output
                -- call p_genOutput
                
                -- EXCEPTIONS:
                   EXC_NULL_USERID -- Cannot proceed, user is NULL
                   EXC_INVALID_USER -- Cannot proceed, user is UNKNOWN/NOT FOUND
                   EXC_NULL_BRIDGEGROUP -- Cannot proceed, BRIDGEGROUP is NULL
                   EXC_INVALID_BRIDGEGROUP -- Cannot proceed, BRIDGEGROUP is UNKNOWN/NOT FOUND
                   EXC_NULL_REPORTTYPE
                   EXC_INVALID_REPORTTYPE
                   EXC_NULL_INSPECTIONTYPE
                   EXC_INVALID_INSPECTIONTYPE
                   EXC_NULL_SORTORDER
                   EXC_INVALID_SORTORDER
                   EXC_NULL_THRESHOLDDAYS
                   EXC_INVALID_THRESHOLDDAYS
                   EXC_ROWSET_ERROR  -- SQL generated an exception
                   EXC_OUTPUT_FAILED -- Could not create the output
                */
            
                -- pUserID parameter is not currently being used.
            
                -- email sender (FROM)
                IF Pemailsender IS NULL
                THEN
                    -- find a default send-to address for this report
                    Ls_Senderemailaddress := Kdot_Blp_Util.f_Get_Coption_Value('KDOT_BLP_MANAGER_EMAIL'
                                                                              ,' KDOT.BLP@ks.gov');
                ELSE
                    Ls_Senderemailaddress := Pemailsender;
                END IF;
            
                Ls_Default_Replyto := Nvl(Kdot_Blp_Util.f_Get_Coption_Value('KDOT_BLP_EMAIL_DEFAULT_REPLY_TO')
                                         ,Ls_Senderemailaddress);
            
                -- email recipients
                IF Pemailaddresslist IS NULL
                THEN
                    -- find a default send-to address for this report
                    Pemailaddresslist := Kdot_Blp_Util.f_Get_Coption_Value('KDOT_BLP_MANAGER_EMAIL'
                                                                          ,' KDOT.BLP@ks.gov');
                END IF;
            
                -- make an array collection of bridgegroups
                p_Parse_Bridgegroups(Pbridgegroups, Ls_Bridgegroups_Array);
            
                Ll_Threshold_Days := Plowerthreshold;
            
                p_Parse_Email_Addresses(Pemailaddresslist, Ls_Email_List);
            
                -- Sort Order
                IF Pinspectiontype = 1
                THEN
                    Ls_Insptypelabel  := 'ROUTINE NBI';
                    Ls_Diffcol        := 'v1.nbi_diff_months';
                    Ls_Sched_Date_Col := 'v1.NEXTINSP';
                ELSIF Pinspectiontype = 2
                THEN
                    Ls_Insptypelabel  := 'UNDERWATER';
                    Ls_Diffcol        := 'v1.uw_diff_months';
                    Ls_Sched_Date_Col := 'v1.UWNEXTDATE';
                ELSIF Pinspectiontype = 3
                THEN
                    Ls_Insptypelabel  := 'FRACTURE CRITICAL';
                    Ls_Diffcol        := 'v1.fc_diff_months';
                    Ls_Sched_Date_Col := 'v1.FCNEXTDATE';
                ELSIF Pinspectiontype = 4
                THEN
                    Ls_Insptypelabel  := 'OTHER SPECIAL';
                    Ls_Diffcol        := 'v1.os_diff_months';
                    Ls_Sched_Date_Col := 'v1.OSNEXTDATE';
                ELSE
                    -- DEFAULT IS 1
                    Ls_Insptypelabel  := 'ROUTINE NBI';
                    Ls_Diffcol        := 'v1.nbi_diff_months';
                    Ls_Sched_Date_Col := 'v1.NEXTINSP';
                END IF;
            
                --- stub to start out
                Ls_Sqlstring := ' SELECT * ' ||
                                ' FROM v_overdue_or_scheduled_bridges v1 ' ||
                                ' WHERE ';
                /*
                        -- add a bridgegroup whereclause if required
                        IF ls_bridgegroups_array.COUNT > 0 THEN
                          p_add_bridgegroups_to_WHERE(ls_SQLString, ls_bridgegroups_array);
                        end if;
                
                */ -- add the inspection type columns etc.
                -- here is where we set the threshold using pLowerThreshold
                p_Add_Cols_To_Retrieve_By_Type(Ls_Sqlstring
                                              ,Preporttype
                                              ,Ls_Diffcol
                                              ,Ls_Sched_Date_Col
                                              ,Plowerthreshold
                                              ,Pupperthreshold
                                              ,Pdaysmonthsflag);
            
                --SJH 10/30/2007
                IF (Psqlfilter IS NULL OR Length(TRIM(Psqlfilter)) = 0)
                THEN
                    Ls_Sqlstring := Ls_Sqlstring;
                ELSE
                    Ls_Sqlstring := Ls_Sqlstring || ' and v1.brkey in (' ||
                                    Psqlfilter || ')';
                END IF;
            
                -- add ORDER BY
                p_Prepare_Orderby(Ls_Orderbystring
                                 ,Preporttype
                                 ,Psortorder
                                 ,Ls_Sched_Date_Col);
            
                -- add ORDER BY to SQL (insurance blank)
                Ls_Sqlstring := Ls_Sqlstring || ' ' || Ls_Orderbystring;
            
                -- don't email the report if count(*) = 0
                Ls_Countsqlstring := REPLACE(Ls_Sqlstring
                                            ,'SELECT * '
                                            ,'SELECT count(*) ');
            
                EXECUTE IMMEDIATE Ls_Countsqlstring
                    INTO Ll_Recordcount;
            
                OPEN Lcur_Bridges FOR Ls_Sqlstring;
            
                IF Poutputtarget = 4
                THEN
                    -- STOP, RETURN ROWSET THROUGH REF CURSOR
                    Pcur := Lcur_Bridges;
                    EXIT Control_Loop;
                END IF;
            
                -- END OF WORK IF REF_CURSOR OPTION  (4)
            
                IF Poutputtarget = 1
                   AND Ll_Recordcount > 0
                THEN
                    BEGIN
                        -- initiate email conversation, if email is the target (1)
                        Ll_Print_Limit := g_Emailbodylineslimit; -- lines of email
                        IF Kdot_Blp_Util.f_Tcp_Connect(Mailer_Connect
                                                      ,Mailhost)
                        THEN
                            -- true means failed!
                            EXIT Control_Loop;
                        END IF;
                        Ls_Emailaddress := Pemailaddresslist;
                    
                        -- figure out what the window label should look like
                        IF Plowerthreshold > 0
                           AND Pupperthreshold > 0
                        THEN
                            IF Plowerthreshold = Pupperthreshold
                            THEN
                                Ls_Window := TRIM(To_Char(Plowerthreshold
                                                         ,'9,990')); --
                            ELSE
                                Ls_Window := '>=' ||
                                             TRIM(To_Char(Plowerthreshold
                                                         ,'9,990')) ||
                                             ' & <= ' ||
                                             TRIM(To_Char(Pupperthreshold
                                                         ,'9,990'));
                            END IF;
                        ELSIF (Plowerthreshold <= 0 OR
                              Plowerthreshold IS NULL)
                              AND Pupperthreshold > 0
                        THEN
                            Ls_Window := ' >= ' ||
                                         TRIM(To_Char(Pupperthreshold
                                                     ,'9,990'));
                        ELSIF (Pupperthreshold <= 0 OR
                              Pupperthreshold IS NULL)
                              AND Plowerthreshold > 0
                        THEN
                            Ls_Window := ' < ' ||
                                         TRIM(To_Char(Plowerthreshold
                                                     ,'9,990'));
                        END IF;
                    
                        IF Preporttype = 1
                        THEN
                            -- Notify Report
                            --ls_subject := 'Arrears Report of Bridges Overdue (' || ls_window || ') for ' || ls_InspTypeLabel || ' Inspection';
                            Ls_Subject := 'KDOT BLP Local Agency Bridgegroup:' || ' ' ||
                                          Pbridgegroups || ' - ' ||
                                          'Notify Report of Bridges Overdue (' ||
                                          Ls_Window || ' ) for ' ||
                                          Ls_Insptypelabel || ' Inspection';
                        ELSIF Preporttype = 2
                        THEN
                            -- Upcoming Report
                            -- ls_subject := 'Report of Bridges Coming Up for ' || ls_InspTypeLabel || ' Inspection';
                            Ls_Subject := 'KDOT BLP Local Agency Bridgegroup:' || ' ' ||
                                          Pbridgegroups || ' - ' ||
                                          'Report of Bridges Coming Up for ' ||
                                          Ls_Insptypelabel || ' Inspection';
                        ELSIF Preporttype = 3
                        THEN
                            -- Arrears Report
                            Ls_Subject := 'KDOT BLP Local Agency Bridgegroup:' || ' ' ||
                                          Pbridgegroups || ' - ' ||
                                          'Report of Bridges Overdue (' ||
                                          Ls_Window || ' ) for ' ||
                                          Ls_Insptypelabel || ' Inspection';
                        END IF;
                    
                        -- initiate conversation
                        Utl_Smtp.Helo(Mailer_Connect, Mailhost);
                        Utl_Smtp.Mail(Mailer_Connect, Pemailsender);
                    
                        IF Ls_Email_List.Count > 1
                        THEN
                            FOR Ith IN Ls_Email_List.First .. Ls_Email_List.Last
                            LOOP
                                Utl_Smtp.Rcpt(Mailer_Connect
                                             ,Ls_Email_List(Ith));
                            END LOOP;
                        ELSE
                            Utl_Smtp.Rcpt(Mailer_Connect, Ls_Email_List(1));
                        END IF;
                    
                    EXCEPTION
                        WHEN OTHERS THEN
                            RAISE;
                        
                    END;
                    -- make body of message
                
                    -- format a nice header for the e-mail message
                    /* BASED ON
                    KDOT_BLP_UTIL.gen_mail_header(ls_subject,
                                                  ls_EMailaddress,
                                                  pEmailSender,
                                                  ls_header);
                    */
                
                    -- start the message ...
                    Utl_Smtp.Open_Data(Mailer_Connect);
                
                    Ls_Header := 'Date: ' || Ls_Printdate;
                    Utl_Smtp.Write_Data(Mailer_Connect
                                       ,Ls_Header || Utl_Tcp.Crlf);
                
                    Ls_Senderemailaddress := Nvl(Kdot_Blp_Util.f_Get_Coption_Value('KDOT_BLP_MANAGER_EMAIL')
                                                ,' KDOT.BLP@ks.gov');
                
                    Ls_Header := 'From: ' ||
                                 Nvl(Pemailsender, Ls_Senderemailaddress);
                    Utl_Smtp.Write_Data(Mailer_Connect
                                       ,Ls_Header || Utl_Tcp.Crlf);
                
                    Ls_Header := 'Reply-To: ' || Ls_Default_Replyto;
                    Utl_Smtp.Write_Data(Mailer_Connect
                                       ,Ls_Header || Utl_Tcp.Crlf);
                
                    Ls_Header := 'To: ' || Nvl(Ls_Emailaddress, 'nobody');
                    Utl_Smtp.Write_Data(Mailer_Connect
                                       ,Ls_Header || Utl_Tcp.Crlf);
                
                    Ls_Header := 'Subject: ' ||
                                 Nvl(Ls_Subject, '<no subject>');
                    Utl_Smtp.Write_Data(Mailer_Connect
                                       ,Ls_Header || Utl_Tcp.Crlf);
                
                    Ls_Header := 'CC: ';
                    Utl_Smtp.Write_Data(Mailer_Connect
                                       ,Ls_Header || Utl_Tcp.Crlf);
                
                    Ls_Header := 'BCC: ';
                    Utl_Smtp.Write_Data(Mailer_Connect
                                       ,Ls_Header || Utl_Tcp.Crlf);
                
                    -- headers
                
                    -- start body with a blank line.
                    Utl_Smtp.Write_Data(Mailer_Connect, Utl_Tcp.Crlf);
                
                    -- make a label!!
                    IF Ll_Days < 0
                    THEN
                        Ls_Overdue_Or_Upcoming := ' Overdue';
                    ELSE
                        IF Upper(Pdaysmonthsflag) <> 'M'
                        THEN
                            Ls_Overdue_Or_Upcoming := ' Days ';
                        ELSE
                            Ls_Overdue_Or_Upcoming := ' Months ';
                        END IF;
                    END IF;
                
                    -- NOT cursor, print to email
                    Ls_Message_Line := Rpad('=', Ll_Linewidth, '=');
                
                    Utl_Smtp.Write_Data(Mailer_Connect
                                       ,Ls_Message_Line || Utl_Tcp.Crlf);
                    Utl_Smtp.Write_Data(Mailer_Connect
                                       ,Ls_Message_Line || Utl_Tcp.Crlf);
                
                    /*        ls_message_line := 'TO ALL RECIPIENTS: PLEASE DO NOT REPLY TO THIS MESSAGE.';
                              UTL_SMTP.Write_Data(mailer_connect, ls_message_line || UTL_TCP.CRLF);
                              ls_message_line := 'It was auto-generated by the KDOT Bureau of Local Projects Bridge';
                              UTL_SMTP.Write_Data(mailer_connect, ls_message_line || UTL_TCP.CRLF);
                              ls_message_line := 'Inspection Compliance Tracking System. You may contact Bridge ';
                              UTL_SMTP.Write_Data(mailer_connect, ls_message_line || UTL_TCP.CRLF);
                              ls_message_line := 'Inspection Program Management at the KDOT Bureau of Local Projects';
                              UTL_SMTP.Write_Data(mailer_connect, ls_message_line || UTL_TCP.CRLF);
                              ls_message_line := 'for further information about this report.';
                              UTL_SMTP.Write_Data(mailer_connect, ls_message_line || UTL_TCP.CRLF);
                    */
                    Ls_Message_Line := Nvl(Kdot_Blp_Util.f_Get_Coption_Value('KDOT_BLP_EMAIL_DONOTREPLY')
                                          ,'Please do not replay to this message.  It was auto-generated by the KDOT BLP Bridge Inspection Compliance Tracking System.' ||
                                           '  You may contact Bridge Inspection Program Management at the KDOT Bureau of Local Projects for further information about this report.');
                
                    Ls_Message_Line := Kdot_Blp_Util.f_Wordwrap(Ls_Message_Line
                                                               ,100
                                                               ,Ls_Rest);
                    Utl_Smtp.Write_Data(Mailer_Connect
                                       ,Ls_Message_Line || Utl_Tcp.Crlf);
                
                    -- Loop until the do not reply message is fully printed
                    WHILE TRUE
                    LOOP
                        Ls_Message_Line := Kdot_Blp_Util.f_Wordwrap(Ls_Rest
                                                                   ,100
                                                                   ,Ls_Rest);
                        Utl_Smtp.Write_Data(Mailer_Connect
                                           ,Ls_Message_Line ||
                                            Utl_Tcp.Crlf);
                    
                        IF Ls_Rest IS NULL
                           OR Ls_Message_Line IS NULL
                        THEN
                            EXIT;
                        END IF;
                    END LOOP;
                
                    Ls_Message_Line := Rpad('=', Ll_Linewidth, '=');
                    Utl_Smtp.Write_Data(Mailer_Connect
                                       ,Ls_Message_Line || Utl_Tcp.Crlf);
                    Utl_Smtp.Write_Data(Mailer_Connect
                                       ,Ls_Message_Line || Utl_Tcp.Crlf);
                
                    Utl_Smtp.Write_Data(Mailer_Connect
                                       ,' ' || Utl_Tcp.Crlf);
                
                    -- Diagnostic header
                    Utl_Smtp.Write_Data(Mailer_Connect
                                       ,' ' || Utl_Tcp.Crlf);
                
                    -- is it future or past? format header accordingly
                    IF Preporttype = 1
                    THEN
                        --Notify Report
                        Ls_Message_Line := 'Notify Report of Bridges Overdue for ' ||
                                           Ls_Insptypelabel ||
                                           ' Inspection';
                        Utl_Smtp.Write_Data(Mailer_Connect
                                           ,Ls_Message_Line ||
                                            Utl_Tcp.Crlf);
                        Ls_Message_Line := Rpad('Criteria (' ||
                                                Ls_Overdue_Or_Upcoming ||
                                                ') : '
                                               ,20
                                               ,' ') || Ls_Window ||
                                           Ls_Overdue_Or_Upcoming ||
                                           'Overdue';
                        Utl_Smtp.Write_Data(Mailer_Connect
                                           ,Ls_Message_Line ||
                                            Utl_Tcp.Crlf);
                    ELSIF Preporttype = 2
                    THEN
                        -- Upcoming Report
                        Ls_Message_Line := 'Inspection Schedule Report of Bridges Coming Due for ' ||
                                           Ls_Insptypelabel ||
                                           ' Inspection';
                        Utl_Smtp.Write_Data(Mailer_Connect
                                           ,Ls_Message_Line ||
                                            Utl_Tcp.Crlf);
                    
                        Ls_Message_Line := Rpad('Criteria (' ||
                                                Ls_Overdue_Or_Upcoming ||
                                                '): '
                                               ,20
                                               ,' ') || ' Due in ' ||
                                           Ls_Window ||
                                           Ls_Overdue_Or_Upcoming;
                        Utl_Smtp.Write_Data(Mailer_Connect
                                           ,Ls_Message_Line ||
                                            Utl_Tcp.Crlf);
                    ELSIF Preporttype = 3
                    THEN
                        -- Arrears Report
                        Ls_Message_Line := 'Report of Bridges Overdue for ' ||
                                           Ls_Insptypelabel ||
                                           ' Inspection';
                        Utl_Smtp.Write_Data(Mailer_Connect
                                           ,Ls_Message_Line ||
                                            Utl_Tcp.Crlf);
                        Ls_Message_Line := Rpad('Criteria (' ||
                                                Ls_Overdue_Or_Upcoming ||
                                                ') : '
                                               ,20
                                               ,' ') || Ls_Window ||
                                           Ls_Overdue_Or_Upcoming ||
                                           'Overdue';
                        Utl_Smtp.Write_Data(Mailer_Connect
                                           ,Ls_Message_Line ||
                                            Utl_Tcp.Crlf);
                    END IF;
                
                    Utl_Smtp.Write_Data(Mailer_Connect
                                       ,Rpad('Report Run Date    :'
                                            ,20
                                            ,' ') || ' ' || Ls_Printdate ||
                                        Utl_Tcp.Crlf);
                    Utl_Smtp.Write_Data(Mailer_Connect
                                       ,Rpad('Report Sort        :'
                                            ,20
                                            ,' ') || ' ' ||
                                        TRIM(Ls_Orderbystring) ||
                                        Utl_Tcp.Crlf);
                    Ls_Message_Line := Rpad('=', Ll_Linewidth, '=');
                    Utl_Smtp.Write_Data(Mailer_Connect
                                       ,Ls_Message_Line || Utl_Tcp.Crlf);
                    Utl_Smtp.Write_Data(Mailer_Connect
                                       ,' ' || Utl_Tcp.Crlf);
                
                END IF;
            
                Ls_Last_Bridgegroup := '';
            
                IF Ll_Recordcount > 0
                THEN
                    <<read_Loop>>
                    LOOP
                    
                        FETCH Lcur_Bridges
                            INTO l_Bridge_Record;
                    
                        EXIT WHEN Lcur_Bridges%NOTFOUND OR(Ll_Cnt =
                                                           Ll_Print_Limit);
                    
                        Ll_Cnt := Ll_Cnt + 1;
                    
                        IF Poutputtarget = 1
                        THEN
                            -- new bridge group?
                            IF Ll_Cnt = 1
                            THEN
                                -- FIRST RECORD
                                BEGIN
                                    -- reset indicator, accumulator
                                    Ls_Last_Bridgegroup := l_Bridge_Record.Bridgegroup;
                                    Ll_Grp_Cnt          := 0;
                                END;
                                Lb_Newgroup := TRUE;
                            END IF;
                        
                            IF Ll_Cnt > 1
                               AND (Ls_Last_Bridgegroup <>
                               l_Bridge_Record.Bridgegroup)
                            THEN
                            
                                BEGIN
                                    Utl_Smtp.Write_Data(Mailer_Connect
                                                       ,' ' ||
                                                        Utl_Tcp.Crlf);
                                    Ls_Message_Line := Rpad('='
                                                           ,Ll_Linewidth
                                                           ,'=');
                                
                                    Utl_Smtp.Write_Data(Mailer_Connect
                                                       ,Ls_Message_Line ||
                                                        Utl_Tcp.Crlf);
                                
                                    -- add count of bridges in this group to email
                                    Utl_Smtp.Write_Data(Mailer_Connect
                                                       ,'# of bridges: ' ||
                                                        To_Char(Ll_Grp_Cnt
                                                               ,'9,990') ||
                                                        Utl_Tcp.Crlf);
                                    Utl_Smtp.Write_Data(Mailer_Connect
                                                       ,Ls_Message_Line ||
                                                        Utl_Tcp.Crlf);
                                
                                    Utl_Smtp.Write_Data(Mailer_Connect
                                                       ,' ' ||
                                                        Utl_Tcp.Crlf);
                                    Utl_Smtp.Write_Data(Mailer_Connect
                                                       ,' ' ||
                                                        Utl_Tcp.Crlf);
                                    Lb_Newgroup := TRUE;
                                END;
                            
                            END IF;
                        
                            -- add group header to email
                            IF Lb_Newgroup
                            THEN
                                Ls_Message_Line := 'Bridge Group: ' ||
                                                   l_Bridge_Record.Bridgegroup;
                                Utl_Smtp.Write_Data(Mailer_Connect
                                                   ,Ls_Message_Line ||
                                                    Utl_Tcp.Crlf);
                                Utl_Smtp.Write_Data(Mailer_Connect
                                                   ,Rpad('='
                                                        ,Ll_Linewidth
                                                        ,'=') ||
                                                    Utl_Tcp.Crlf);
                            
                                -- COLUMN HEADERS
                            
                                /****** ORIGINAL MESSAGE LINE PROGRAMMED BY ALLEN *******/
                                /*              ls_message_line := RPAD('Bridge    ', 15, ' ') || '  ' ||
                                'County' || ' ' || RPAD('Place', 8, ' ') ||
                                RPAD('Featint / Facility', 24, ' ') ||
                                '   Last Insp. ' || '  Scheduled' ||
                                '    ' || ls_overdue_or_upcoming ||
                                '   Freq. ';*/
                            
                                Ls_Message_Line := Rpad('FHWA Bridge #    '
                                                       ,22
                                                       ,' ') || ' ||  ' ||
                                                   Rpad('LPA Bridge ID    '
                                                       ,22
                                                       ,' ') || ' ||  ' ||
                                                   Rpad('Feature Intersected  '
                                                       ,32
                                                       ,' ') || ' ||  ' ||
                                                   Rpad('Facility Carried    '
                                                       ,30
                                                       ,' ') || ' ||  ' ||
                                                   Rpad(' Last Insp. '
                                                       ,12
                                                       ,' ') || ' ||  ' ||
                                                   Rpad(' Scheduled '
                                                       ,10
                                                       ,' ') || '  ||  ' ||
                                                   '   ' ||
                                                   Ls_Overdue_Or_Upcoming ||
                                                   ' ||  ' ||
                                                   '  Frequency ';
                            
                                Utl_Smtp.Write_Data(Mailer_Connect
                                                   ,Ls_Message_Line ||
                                                    Utl_Tcp.Crlf);
                            
                                Ls_Message_Line := Rpad('='
                                                       ,Ll_Linewidth
                                                       ,'=');
                            
                                Utl_Smtp.Write_Data(Mailer_Connect
                                                   ,Ls_Message_Line ||
                                                    Utl_Tcp.Crlf);
                            
                                Lb_Newgroup         := FALSE;
                                Ls_Last_Bridgegroup := l_Bridge_Record.Bridgegroup;
                                Ll_Grp_Cnt          := 0;
                            
                            END IF;
                        
                        END IF; -- output target
                    
                        Ll_Grp_Cnt := Ll_Grp_Cnt + 1;
                        /*
                        p_prepare_email_detail needs
                                                   the_ReportType     IN PLS_INTEGER := 1,
                                                   the_InspectionType IN PLS_INTEGER := 1,
                                                   the_DaysMonthsFlag IN VARCHAR2 := 'M',
                                                   the_startDay1FLAG IN VARCHAR2 := 'Y' ,
                                                   the_record         IN v_overdue_or_scheduled_bridges%ROWTYPE,
                                                   the_message_line   OUT VARCHAR2
                        */
                        p_Prepare_Email_Detail(Preporttype
                                              ,Pinspectiontype
                                              ,Pdaysmonthsflag
                                              ,Pstartday1flag
                                              ,l_Bridge_Record
                                              ,Ls_Message_Line);
                    
                        IF Lb_Debug
                        THEN
                            Dbms_Output.Enable(1000000);
                            Dbms_Output.Put_Line(Ls_Message_Line);
                        END IF;
                    
                        IF Poutputtarget = 1
                        THEN
                            -- add to email
                            Utl_Smtp.Write_Data(Mailer_Connect
                                               ,Ls_Message_Line ||
                                                Utl_Tcp.Crlf);
                        END IF;
                    
                    END LOOP Read_Loop;
                END IF; -- ll_recordCount > 0
            
                CLOSE Lcur_Bridges;
                -- swallow close session failure
                BEGIN
                
                    IF Poutputtarget = 1
                       AND Ll_Recordcount > 0
                    THEN
                        -- All done, send the email
                        -- add count of bridges in this group to email
                        Utl_Smtp.Write_Data(Mailer_Connect
                                           ,' ' || Utl_Tcp.Crlf);
                        Ls_Message_Line := Rpad('=', Ll_Linewidth, '=');
                        Utl_Smtp.Write_Data(Mailer_Connect
                                           ,Ls_Message_Line ||
                                            Utl_Tcp.Crlf);
                        Utl_Smtp.Write_Data(Mailer_Connect
                                           ,'# of bridges: ' ||
                                            To_Char(Ll_Grp_Cnt, '9,990') ||
                                            Utl_Tcp.Crlf);
                        Utl_Smtp.Write_Data(Mailer_Connect
                                           ,Ls_Message_Line ||
                                            Utl_Tcp.Crlf);
                        Utl_Smtp.Write_Data(Mailer_Connect
                                           ,' ' || Utl_Tcp.Crlf);
                        Utl_Smtp.Write_Data(Mailer_Connect
                                           ,' ' || Utl_Tcp.Crlf);
                        Ls_Message_Line := Rpad('=', Ll_Linewidth, '=');
                        Utl_Smtp.Write_Data(Mailer_Connect
                                           ,Ls_Message_Line ||
                                            Utl_Tcp.Crlf);
                        Utl_Smtp.Write_Data(Mailer_Connect
                                           ,'# of bridges meeting criteria in all groups: ' ||
                                            To_Char(Ll_Cnt, '99,990') ||
                                            Utl_Tcp.Crlf);
                        Ls_Message_Line := Rpad('=', Ll_Linewidth, '=');
                        Utl_Smtp.Write_Data(Mailer_Connect
                                           ,Ls_Message_Line ||
                                            Utl_Tcp.Crlf);
                        Utl_Smtp.Close_Data(Mailer_Connect);
                        Utl_Smtp.Quit(Mailer_Connect); -- close email, send
                        EXIT Control_Loop;
                    END IF;
                EXCEPTION
                    WHEN OTHERS THEN
                        RAISE;
                        --EXIT Control_Loop;
                END;
            
                EXIT Control_Loop;
            END;
        
        END LOOP Control_Loop;
    
    EXCEPTION
        WHEN OTHERS THEN
            RAISE;
            --kdot_blp_errpkg.raisex( SQLCODE, 'Exception raised in ' + ls_Context);
    
    END p_Gen_Sched_Detail_Reports;

    PROCEDURE p_Nbi_90days_Overdue(Pcur IN OUT Vbridgescursor) IS
    BEGIN
        p_Nbi_Report_Refcursor('Bridge Group 1', 1, 90, Pcur);
    END p_Nbi_90days_Overdue;

    PROCEDURE p_Parse_Email_Addresses(Pemailaddresslist IN VARCHAR2
                                     ,Paddresslistarray OUT Address_List_Type) IS
    
        i               PLS_INTEGER;
        Lv_Parsed_List  Kdot_Blp_Util.Generic_List_Type;
        Ls_Emailaddress VARCHAR2(8000);
    
    BEGIN
        Paddresslistarray := Address_List_Type();
    
        IF Pemailaddresslist IS NOT NULL
        THEN
            Ls_Emailaddress := Pemailaddresslist;
            Kdot_Blp_Util.p_Parse_List(Ls_Emailaddress
                                      ,g_Email_Delim
                                      ,500
                                      ,Lv_Parsed_List);
            IF Ls_Emailaddress IS NULL
            THEN
                Raisex(Kdot_Blp_Errors.En_Bad_Arguments);
            END IF;
        
            IF Lv_Parsed_List.Count > 0
            THEN
                FOR i IN 1 .. Lv_Parsed_List.Count
                LOOP
                    Paddresslistarray.Extend;
                    Paddresslistarray(Paddresslistarray.Count) := Lv_Parsed_List(i);
                END LOOP;
            END IF;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            RAISE;
    END p_Parse_Email_Addresses;

    PROCEDURE p_Parse_Bridgegroups(Pbridgegroups      IN VARCHAR2
                                  ,Pbridgegroupsarray OUT Vbridgegrouparray) IS
    
        Lv_Parsed_List  Kdot_Blp_Util.Generic_List_Type;
        Ls_Bridgegroups VARCHAR2(8000);
        i               PLS_INTEGER;
    
    BEGIN
        Pbridgegroupsarray := Vbridgegrouparray();
        Ls_Bridgegroups    := Pbridgegroups;
        Kdot_Blp_Util.p_Parse_List(Ls_Bridgegroups
                                  ,','
                                  ,500
                                  ,Lv_Parsed_List);
    
        IF Ls_Bridgegroups IS NULL
        THEN
            Raisex(Kdot_Blp_Errors.En_Bad_Arguments);
        END IF;
    
        IF Lv_Parsed_List.Count > 0
        THEN
            FOR i IN 1 .. Lv_Parsed_List.Count
            LOOP
                Pbridgegroupsarray.Extend;
                Pbridgegroupsarray(Pbridgegroupsarray.Count) := Lv_Parsed_List(i);
            END LOOP;
        
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            RAISE;
    END p_Parse_Bridgegroups;

    -- prototype procedure p_NBI_report_refCursor
    PROCEDURE p_Nbi_Report_Refcursor(Pbridgegroups   IN VARCHAR2
                                    ,Preporttype     IN PLS_INTEGER
                                    , -- in arrears =1, future = 2
                                     Plowerthreshold IN PLS_INTEGER
                                    ,Pcur            IN OUT Vbridgescursor) IS
    
        Ls_Dummy_Email_List VARCHAR2(1) := '';
    
    BEGIN
        p_Gen_Sched_Detail_Reports(NULL
                                  ,Pbridgegroups
                                  ,Preporttype
                                  ,1
                                  ,Plowerthreshold
                                  ,NULL
                                  , -- don't have a date window - just any down to lower threshold and no earlier
                                   'D'
                                  , -- by days overdue
                                   'Y'
                                  , -- start on day 1
                                   0
                                  ,Ls_Dummy_Email_List
                                  ,NULL
                                  ,4
                                  ,NULL
                                  ,Pcur
                                  ,'');
    
    END p_Nbi_Report_Refcursor;

    -- DOCUMENTS RELATED
    PROCEDURE p_Retrieve_Documents(Pbrkey            IN Bridge.Brkey%TYPE
                                  ,Pinspkey          IN Inspevnt.Inspkey%TYPE
                                  ,Pdoc_Type_Key     IN Kdotblp_Documents.Doc_Type_Key%TYPE
                                  ,Pdoc_Subtype_Key  IN Kdotblp_Documents.Doc_Subtype_Key%TYPE
                                  ,Pdoc_Status       IN Kdotblp_Documents.Doc_Status%TYPE
                                  ,Psource_File_Name IN Kdotblp_Documents.Source_File_Name%TYPE
                                  ,Ptarget_File_Name IN Kdotblp_Documents.Target_File_Name%TYPE
                                  ,Crsdocumentrow    OUT SYS_REFCURSOR) IS
    
        Sqlstmt      VARCHAR2(8000);
        Where_Clause VARCHAR2(1024) := ''; -- EMPTY, NOT NULL IN THIS CASE, since we are concatenating
        /*lsBRKEY            BRIDGE.BRKEY%TYPE;
        lsINSPKEY          INSPEVNT.INSPKEY%TYPE;
        lsDOC_TYPE_KEY     KDOTBLP_DOCUMENTS.DOC_TYPE_KEY%TYPE;
        lsdoc_subtype_key   KDOTBLP_DOCUMENTS.doc_subtype_key%TYPE;
        lsDOC_STATUS       KDOTBLP_DOCUMENTS.DOC_STATUS%TYPE;
        lsTARGET_FILE_NAME KDOTBLP_DOCUMENTS.TARGET_FILE_NAME%TYPE;*/
    
    BEGIN
        -- STUB
        Sqlstmt := 'WITH t_binds ' || ' AS ( SELECT :v_brkey as bv_brkey, ' ||
                   ' :v_inspkey AS bv_inspkey, ' ||
                   ' :v_doc_type_key AS bv_doc_type_key, ' ||
                   ' :v_doc_subtype_key AS bv_doc_subtype_key, ' ||
                   ' :v_doc_status AS bv_doc_status, ' ||
                   ' :v_source_file_name AS bv_source_file_name, ' ||
                   ' :v_target_file_name as bv_target_file_name ' ||
                   ' FROM dual) ' || ' SELECT kd.doc_key,' ||
                   'kd.doc_type_key, ' || 'NVL(f_lbl(' || 'kd.doc_type_key' || ',' ||
                   Kdot_Blp_Util.Sq('kdotblp_documents') || ',' ||
                   Kdot_Blp_Util.Sq('doc_type_key') || '),' ||
                   Kdot_Blp_Util.Sq('') || ') AS doc_type_key_label ,' ||
                   'kd.sdoc_subtype_key, ' || 'NVL(f_lbl(' ||
                   'kd.doc_subtype_key' || ',' ||
                   Kdot_Blp_Util.Sq('kdotblp_documents') || ',' ||
                   Kdot_Blp_Util.Sq('doc_subtype_key') || '),' ||
                   Kdot_Blp_Util.Sq('') || ') AS doc_subtype_keyy_label ,' ||
                   'kd.brkey,
kd.inspkey,
kd.source_file_name,
kd.target_file_name,
COALESCE(kd.thumb_file_name, ' ||
                   Kdot_Blp_Util.Sq('~/SupportDocuments/DefaultImages/adobe-reader.png') || -- default file is to assume PDF here
                   ') AS thumb_file_name,' || ' NVL(kd.doc_title,kd.source_file_name) as doc_title ,
 NVL(kd.mime_type,' ||
                   Kdot_Blp_Util.Sq('application/pdf') || -- default is to assume PDF for mime type too
                   ') as mime_type,
kd.file_size_bytes,
kd.uploaded_by,
(SELECT pau1.USERID FROM PON_APP_USERS pau1 WHERE pau1.userkey=kd.uploaded_by) as UPLOAD_USERID,
kd.uploaded_at,
kd.updated_by,
(SELECT pau2.USERID FROM PON_APP_USERS pau2 WHERE pau2.userkey=kd.updated_by) as UPDATE_USERID,
kd.updated_at,
kd.deleted_by,
(SELECT pau3.USERID FROM PON_APP_USERS pau3 WHERE pau3.userkey=kd.deleted_by) as DELETE_USERID,
kd.deleted_at,
kd.doc_status,' || 'NVL(f_lbl(' || 'kd.doc_status' || ',' ||
                   Kdot_Blp_Util.Sq('kdotblp_documents') || ',' ||
                   Kdot_Blp_Util.Sq('doc_status') || '),' ||
                   Kdot_Blp_Util.Sq('') || ') AS doc_status_label ,' ||
                   ' kd.notes, ' ||
                   ' COALESCE( kd.updated_at, kd.uploaded_at, sysdate )as datesortkey ' ||
                   ' from KDOTBLP_DOCUMENTS kd, ' || ' t_binds ' ||
                   ' WHERE kd.doc_key IS NOT NULL ';
    
        -- CONSTRUCT A WHERE CLAUSE
    
        -- the next criteria permits us to get all the documents for a bridge.  All bridges if null.
        IF (Pbrkey IS NOT NULL)
        THEN
            Where_Clause := Where_Clause || ' AND kd.BRKEY = bv_brkey';
        END IF;
    
        -- the next criteria permits us to get all the documents for a bridge associated with an inspection.
        IF (Pinspkey IS NOT NULL)
        THEN
            Where_Clause := Where_Clause || ' AND kd.INSPKEY = bv_inspkey';
        END IF;
    
        -- the next criteria permits us to get all the documents by doc_type_key e.g. 21
        IF (Pdoc_Type_Key IS NOT NULL)
        THEN
            Where_Clause := Where_Clause ||
                            ' AND kd.DOC_TYPE_KEY = bv_doc_type_key';
        END IF;
    
        -- the next criteria permits us to get all the documents by SCOUR_TYPE_KEY e.g. 3 Amended Plans or whatever (see PARAMTRS)
        IF (Pdoc_Subtype_Key IS NOT NULL)
        THEN
            Where_Clause := Where_Clause ||
                            ' AND kd.doc_subtype_keyY = bv_doc_subtype_key';
        END IF;
    
        -- the next criteria permits us to get all the documents by DOC_STATUS - TYPICALLY 1 FOR ACTIVE
    
        IF (Pdoc_Status IS NOT NULL)
        THEN
            Where_Clause := Where_Clause ||
                            ' AND kd.DOC_STATUS = bv_DOC_STATUS';
        END IF;
    
        -- the next criteria permits us to get all the documents by the original file name as stored in the repo
        IF (Psource_File_Name IS NOT NULL)
        THEN
            Where_Clause := Where_Clause ||
                            ' AND kd.SOURCE_FILE_NAME = bv_SOURCE_FILE_NAME';
        END IF;
    
        -- the next criteria permits us to get all the documents by the calculated file name as stored in the repo
        IF (Ptarget_File_Name IS NOT NULL)
        THEN
            Where_Clause := Where_Clause ||
                            ' AND kd.TARGET_FILE_NAME = bv_TARGET_FILE_NAME';
        END IF;
    
        -- construct SQL statement and append the WHERE clause (if any)
        Sqlstmt := Sqlstmt || ' ' || Where_Clause;
    
        -- open the cursor and return result set using parameter values if applicable
        OPEN Crsdocumentrow FOR Sqlstmt
            USING Pbrkey, Pinspkey, Pdoc_Type_Key, Pdoc_Subtype_Key, Pdoc_Status, Psource_File_Name, Ptarget_File_Name;
    
    END p_Retrieve_Documents;

BEGIN
    g_Emailbodylineslimit := 5000;
    -- Initialization
    g_Email_Delim := Kdot_Blp_Util.f_Get_Coption_Value('KDOT_BLP_EMAIL_DELIM'
                                                      ,';');
    NULL;
END Kdot_Blp_Rep;
/
