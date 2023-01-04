/*ERROR D6: Failed Creating Foreign Key [ALTER TABLE USERBRDG ADD CONSTRAINT FK_USERBRDG_14_BRIDGE FOREIGN KEY (BRIDGE_GD) REFERENCES BRIDGE (BRIDGE_GD) ON DELETE CASCADE;ORA-02298: cannot validate (KDOT_BLP.FK_USERBRDG_14_BRIDGE) - parent keys not found
ERROR D6: Failed Creating Foreign Key [ALTER TABLE USERINSP ADD CONSTRAINT FK_USERINSP_46_INSPEVNT FOREIGN KEY (INSPEVNT_GD) REFERENCES INSPEVNT (INSPEVNT_GD) ON DELETE CASCADE;ORA-02298: cannot validate (KDOT_BLP.FK_USERINSP_46_INSPEVNT) - parent keys not found
ERROR D6: Failed Creating Foreign Key [ALTER TABLE USERSTRUNIT ADD CONSTRAINT FK_USERSTRU_103_STRUCTUR FOREIGN KEY (STRUCTURE_UNIT_GD) REFERENCES STRUCTURE_UNIT (STRUCTURE_UNIT_GD) ON DELETE CASCADE;ORA-02298: cannot validate (KDOT_BLP.FK_USERSTRU_103_STRUCTUR) - parent keys not found
 */
/*
select ub.brkey, ub.bridge_gd, b.brkey, b.bridge_gd
  from userbrdg ub
  left outer join bridge b
    on ub.bridge_gd = b.bridge_gd
 WHERE b.BRIDGE_GD IS NULL
 ORDER BY 1;

select ub.brkey, ub.bridge_gd, b.brkey, b.bridge_gd
  from userbrdg ub
 right outer join bridge b
    on ub.bridge_gd = b.bridge_gd
 WHERE ub.BRIDGE_GD IS NULL
 ORDER BY ub.brkey;


 

select ui.brkey, ui.bridge_gd, ui.inspkey, ui.inspevnt_gd, i.brkey, i.bridge_gd, i.inspkey, i.inspevnt_gd, i.inspdate
  from userinsp ui
 left outer join inspevnt i
    on ui.bridge_gd = i.bridge_gd 
and ui.inspevnt_gd = i.Inspevnt_Gd
 WHERE i.BRIDGE_GD IS NULL or i.INSPEVNT_GD IS NULL
 ORDER BY ui.brkey, ui.inspkey ;


select ui.brkey, ui.bridge_gd, ui.inspkey, ui.inspevnt_gd, i.brkey, i.bridge_gd, i.inspkey, i.inspevnt_gd, i.inspdate
  from userinsp ui
 right outer join inspevnt i
    on ui.bridge_gd = i.bridge_gd 
and ui.inspevnt_gd = i.Inspevnt_Gd
 WHERE ui.BRIDGE_GD IS NULL or ui.INSPEVNT_GD IS NULL
 ORDER BY i.brkey, i.inspkey, i.inspdate DESC;
 */

select ub.brkey, ub.bridge_gd, b.brkey, b.bridge_gd
  from KDOTBLP_BRIDGE ub
  left outer join bridge b
    on ub.bridge_gd = b.bridge_gd
 WHERE b.BRIDGE_GD IS NULL
 ORDER BY 1;

select ub.brkey, ub.bridge_gd, b.brkey, b.bridge_gd
  from KDOTBLP_BRIDGE ub
 right outer join bridge b
    on ub.bridge_gd = b.bridge_gd
 WHERE ub.BRIDGE_GD IS NULL
 ORDER BY ub.brkey;

select ui.brkey,
       ui.bridge_gd,
       ui.inspkey,
       ui.inspevnt_gd,
       i.brkey,
       i.bridge_gd,
       i.inspkey,
       i.inspevnt_gd,
       i.inspdate
  from KDOTBLP_INSPECTIONS ui
  left outer join inspevnt i
    on ui.bridge_gd = i.bridge_gd
   and ui.inspevnt_gd = i.Inspevnt_Gd
 WHERE i.BRIDGE_GD IS NULL
    or i.INSPEVNT_GD IS NULL
 ORDER BY ui.brkey, ui.inspkey;

select ui.brkey,
       ui.bridge_gd,
       ui.inspkey,
       ui.inspevnt_gd,
       i.brkey,
       i.bridge_gd,
       i.inspkey,
       i.inspevnt_gd,
       i.inspdate
  from KDOTBLP_INSPECTIONS ui
 right outer join inspevnt i
    on ui.bridge_gd = i.bridge_gd
   and ui.inspevnt_gd = i.Inspevnt_Gd
 WHERE ui.BRIDGE_GD IS NULL
    or ui.INSPEVNT_GD IS NULL
 ORDER BY i.brkey, i.inspkey, i.inspdate DESC;

select us.brkey,
       us.bridge_gd,
       us.strunitkey,
       us.structure_unit_gd,
       stru.brkey,
       stru.bridge_gd,
       stru.strunitkey,
       stru.structure_unit_gd
  from USERSTRUNIT us
  left outer join STRUCTURE_UNIT stru
    on us.bridge_gd = stru.bridge_gd
   and us.structure_unit_gd = stru.structure_unit_gd
 WHERE stru.BRIDGE_GD IS NULL
    or stru.structure_unit_gd IS NULL
 ORDER BY us.brkey, us.strunitkey;

select us.brkey,
       us.bridge_gd,
       us.strunitkey,
       us.structure_unit_gd,
       stru.brkey,
       stru.bridge_gd,
       stru.strunitkey,
       stru.structure_unit_gd
  from USERSTRUNIT us
 right outer join STRUCTURE_UNIT stru
    on us.bridge_gd = stru.bridge_gd
   and us.structure_unit_gd = stru.structure_unit_gd
 WHERE stru.BRIDGE_GD IS NULL
    or stru.structure_unit_gd IS NULL
 ORDER BY stru.brkey, stru.strunitkey;
