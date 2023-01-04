 SELECT ut.TABLE_NAME,pt.table_name
            FROM USER_TABLES ut
            JOIN PON_TABLE pt
            ON  ut.TABLE_NAME LIKE pt.TABLE_NAME || '%_T'
            ORDER BY ut.TABLE_NAME;
