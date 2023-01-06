DELETE FROM STRUCTURE_UNIT WHERE STRUCTURE_UNIT.BRKEY LIKE '#%';

DELETE FROM STRUCTURE_UNIT
 WHERE NOT EXISTS
 (SELECT 1
          FROM BRIDGE
         WHERE BRIDGE.BRIDGE_GD = STRUCTURE_UNIT.BRIDGE_GD); -- should be 0

DELETE FROM USERSTRUNIT WHERE USERSTRUNIT.BRKEY LIKE '#%';

DELETE FROM USERSTRUNIT
 WHERE NOT EXISTS
 (SELECT 1
          FROM BRIDGE
         WHERE BRIDGE.BRIDGE_GD = USERSTRUNIT.BRIDGE_GD); -- should be 0

DELETE FROM USERSTRUNIT
 WHERE NOT EXISTS
 (SELECT 1
          FROM STRUCTURE_UNIT
         WHERE STRUCTURE_UNIT.STRUCTURE_UNIT_GD = USERSTRUNIT.STRUCTURE_UNIT_GD); -- should everntually be 0   
               
COMMIT WORK; 

MERGE INTO USERSTRUNIT tgt
USING (select brkey,
              strunitkey,
              createdatetime,
              createuserkey,
              modtime,
              userkey,
              
              structure_unit_gd,
              bridge_gd
         from STRUCTURE_UNIT
        WHERE BRKEY NOT LIKE '#%') src
ON (src.STRUCTURE_UNIT_GD = tgt.STRUCTURE_UNIT_GD)
WHEN NOT MATCHED THEN
  INSERT
    (brkey,
     strunitkey,
     createdatetime,
     createuserkey,
     modtime,
     userkey,
    
     structure_unit_gd,
     bridge_gd)
  VALUES
    (src.brkey,
     src.strunitkey,
     src.createdatetime,
     src.createuserkey,
     src.modtime,
     src.userkey,
     
     src.structure_unit_gd,
     src.bridge_gd);
 
-- make a duplicate

DROP TABLE KDOTBLP_STRUCTURE_UNIT PURGE;

CREATE TABLE KDOTBLP_STRUCTURE_UNIT AS
  SELECT t.*
    FROM USERSTRUNIT t
   WHERE EXISTS (SELECT 1
            FROM USERSTRUNIT
           INNER JOIN STRUCTURE_UNIT
              ON USERSTRUNIT.STRUCTURE_UNIT_GD =
                 STRUCTURE_UNIT.STRUCTURE_UNIT_GD)  
   ORDER BY 1, 2;
   



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
