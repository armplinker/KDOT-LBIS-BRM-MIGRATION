PL/SQL Developer Test script 3.0
16
begin
  -- Call the function
  -- :result := ISNUMERIC(p_string => :p_string);
  -- i.INSPKEY, i.INSPUSRGUID,
  SELECT i.BRKEY,
         i.INSPKEY,
         NVL(i.INSPUSRGUID, 'XXX') as INSPUSRGUID,
         i.INSPUSRKEY,
         (SELECT pau.PON_APP_USERS_GD
            FROM PON_APP_USERS pau
           WHERE to_char(pau.USERKEY) = to_char(i.USERKEY))
    into :brkey, :inspkey, :curr_inspusrguid, :curr_inspusrkey, :result
    FROM INSPEVNT i
   WHERE i.INSPUSRGUID IS NULL
      OR ISNUMERIC(i.INSPUSRGUID) = 1;
end;
6
result
0
5
p_string
0
-5
brkey
1
52120046000B019
5
inspkey
1
PNBD
5
curr_inspusrguid
1
XXX
5
curr_inspusrkey
1
5858
3
0
