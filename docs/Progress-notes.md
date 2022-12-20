# BRM Migration progress notes
## ARMarshall, ARM LLC - 20221220 
### PON_CONCAT calls might be better formed using LISTAGG available in Oracle 12C+
`SELECT LISTAGG('T.'|| DICT.COLUMN_NAME ,',') 
WITHIN GROUP (ORDER BY DICT.COLUMN_ID) "DELIM_COL_LIST"
                                     FROM USER_TAB_COLS DICT                                     
                                     GROUP BY DICT.TABLE_NAME 
                                     HAVING DICT.TABLE_NAME = 'BRIDGE'
                                     ORDER BY DICT.TABLE_NAME`
see                     
[Link](https://docs.oracle.com/cd/E11882_01/server.112/e41084/functions089.htm#SQLRF30030 "Oracle LISTAGG documentation")                

###
N