/*select USERID,
       ki.BRKEY,
       ki.INSPKEY,
       ki.CREATEDATETIME,
       ki.MODTIME,
       ki.USERKEY
  FROM KDOTBLP_INSPECTIONS ki
 INNER JOIN PON_APP_USERS
    ON (ki.USERKEY = PON_APP_USERS.PON_APP_USERS_GD)
 WHERE NOT EXISTS
 (SELECT 1 FROM INSPEVNT WHERE INSPEVNT.INSPEVNT_GD = ki.INSPEVNT_GD);
 */
DELETE
  FROM KDOTBLP_INSPECTIONS ki
 WHERE NOT EXISTS
 (SELECT 1 FROM INSPEVNT i WHERE i.INSPEVNT_GD = ki.INSPEVNT_GD );
