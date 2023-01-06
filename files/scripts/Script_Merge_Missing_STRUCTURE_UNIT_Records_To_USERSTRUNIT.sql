MERGE INTO KDOTBLP_STRUCTURE_UNIT tgt
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
