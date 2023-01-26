create or replace view V_BRIDGES_WITH_OS_INSPECTIONS AS
SELECT itypes.bridge_gd,
       itypes.inspevnt_gd,
       itypes.os_inspdate,
       itypes.spinsptype,
       pd.shortdesc as DESCRIPTION,
       itypes.rn
  FROM (SELECT i2.bridge_gd AS key_,
               i2.inspevnt_gd,
               i2.bridge_gd,
               ki.spinsptype,
               row_number() OVER(PARTITION BY i2.bridge_gd ORDER BY i2.oslastinsp DESC) AS rn,
               CASE
                 WHEN i2.oslastinsp IS NOT NULL THEN
                  i2.oslastinsp
                 ELSE
                  i2.inspdate
               END AS os_inspdate
          FROM inspevnt i2
         inner join kdotblp_inspections ki
            on i2.inspevnt_gd = ki.inspevnt_gd
         WHERE f_is_yes(i2.osinspdone) = 1) itypes
  left outer join paramtrs pd
    on to_char(itypes.spinsptype) = to_char(pd.parmvalue)
   and pd.table_name = 'kdotblp_inspections'
   and pd.field_name = 'spinsptype';
   
