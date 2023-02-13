CREATE OR REPLACE FUNCTION f_Is_Primarykey_Col(The_Table_Name  User_Tab_Cols.Table_Name%TYPE,
                                               The_Column_Name User_Tab_Cols.Column_Name%TYPE,
                                               The_Owner       User_Cons_Columns.Owner%TYPE := USER)
/*
    for a given table and column, for the given schema / table owner, 
    return the position of the column in the defined primary key constraint, or 0 if not found
    
    As a tiny benefit the value returned if > 0 is the ordinal position of the column in the constraint, should the primary key be a multi-part key
    
    usage: SELECT f_Is_Primarykey_Col('table', 'column','some_user') from dual;
    
    if it is part of a constraint then RowNum will be >0.  For a GUID PK, ROWNUM will be 1, but for a multi-part PK, say BRKEY,INSPKEY, it will be > 0
      ARMarshall, ARM__LLC - 20230212 - changed this to use RowNum>0, which means a row was returned, which means the column is the single PK or part of the PK for the table
  */
 RETURN PLS_INTEGER IS
  Ispk PLS_INTEGER := 0; -- assume NOT (part of) the primary key
Begin
  -- if the_owner = USER, check user_constraints and user_cons_columns to see if the column is (part of) the primary key for the table
  If the_owner = USER Then
     SELECT Cols.Position
      INTO Ispk
      FROM User_Constraints Cons, User_Cons_Columns Cols
     WHERE Cols.Table_Name = Upper(TRIM(The_Table_Name))
       AND Cons.Constraint_Type = 'P'
       AND Cons.Constraint_Name = Cols.Constraint_Name
       AND Cols.Column_Name = Upper(TRIM(The_Column_Name))
          -- AND Cons.Owner = Upper(TRIM(The_Owner))
       AND Rownum > 0; -- want True Or False, so Any, including for multi-part PK,  means yes
   
  ELSE
     -- if this function is called to check the PK for a user table/column that is other than a SCHEMA owner table/column, search ALL_CONSTRAINTS,
 
    SELECT Cols.Position
      INTO Ispk
      FROM All_Constraints Cons, All_Cons_Columns Cols
     WHERE Cols.Table_Name = Upper(TRIM(The_Table_Name))
       AND Cons.Constraint_Type = 'P'
       AND Cons.Constraint_Name = Cols.Constraint_Name
       AND Cols.Column_Name = Upper(TRIM(The_Column_Name))
       AND Cons.Owner = Upper(TRIM(The_Owner))
       AND Rownum > 0; -- want True Or False, so Any, including for multi-part PK,  means yes
  End If;
  
  RETURN Ispk; -- boolean variant could return  ( NVL(ISPK,-1) > 0 )

EXCEPTION
  WHEN No_Data_Found THEN
    RETURN 0; -- means either the table has no PK or this column is not part of the PK
  -- boolean variant would return  FALSE 
  WHEN OTHERS THEN
    RAISE; -- means uh-oh - permissions issue, etc.
END f_Is_Primarykey_Col;
/
