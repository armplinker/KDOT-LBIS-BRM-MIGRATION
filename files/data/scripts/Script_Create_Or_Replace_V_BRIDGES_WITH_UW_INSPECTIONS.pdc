create or replace view V_BRIDGES_WITH_UW_INSPECTIONS AS
SELECT itypes.bridge_gd,
       itypes.inspevnt_gd,
       itypes.uw_inspdate,
       itypes.uwinsptype,
       pd.shortdesc as DESCRIPTION,
       itypes.rn
  FROM (SELECT i2.bridge_gd AS key_,
               i2.inspevnt_gd,
               i2.bridge_gd,
               ki.uwinsptype,               
               row_number() OVER(PARTITION BY i2.bridge_gd ORDER BY i2.uwlastinsp DESC) AS rn,
               CASE
                 WHEN i2.uwlastinsp IS NOT NULL THEN
                  i2.uwlastinsp
                 ELSE
                  i2.inspdate
               END AS uw_inspdate
          FROM inspevnt i2
         inner join kdotblp_inspections ki
            on i2.inspevnt_gd = ki.inspevnt_gd
         WHERE f_is_yes(i2.uwinspdone) = 1) itypes
  left outer join paramtrs pd
    on to_char(itypes.uwinsptype) = to_char(pd.parmvalue)
   and pd.table_name = 'kdotblp_inspections'
   and pd.field_name = 'uwinsptype';
   
