/*select brkey  FROM KDOTBLP_BRIDGE kb 
WHERE NOT EXISTS (SELECT 1 FROM BRIDGE b WHERE b.BRIDGE_GD=kb.BRIDGE_GD);
*/
DELETE FROM KDOTBLP_BRIDGE kb
 WHERE NOT EXISTS (SELECT 1 FROM BRIDGE b WHERE b.BRIDGE_GD = kb.BRIDGE_GD);

MERGE INTO KDOTBLP_BRIDGE tgt
USING (SELECT bridge_gd,
              brkey,
              createuserkey,
              createdatetime,
              userkey,
              modtime
         FROM BRIDGE) src
ON (src.BRIDGE_GD = tgt.BRIDGE_GD)
WHEN NOT MATCHED THEN
  INSERT
    (bridge_gd, brkey, createuserkey, createdatetime, userkey, modtime)
  VALUES
    (src.bridge_gd,
     src.brkey,
     src.createuserkey,
     src.createdatetime,
     src.userkey,
     src.modtime);
