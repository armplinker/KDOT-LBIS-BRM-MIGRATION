SELECT b.bridge_gd as key_,
       b.brkey,
       b.bridge_id "Bridge ID",
       b.district "District",
       b.county "County",
       b.facility "Facility Carried",
       b.featint "Feature Intersected",
       b.owner "Own",
       b.custodian "Maint",
       b.bridgegroup,
       b.yearbuilt "Built",
       mv.inspdate,
       mv.lastinsp,
       mv.insptype,
       NVL(trim(b.srstatus), '_') as srstatus,
       b.bridge_gd /* same as key_ - may be removed eventually */
  from bridge b
  left outer join (select r2.*
                     from roadway r2
                    where r2.on_under = '1'
                       or (r2.bridge_gd not in
                          (select r3.bridge_gd
                              from roadway r3
                             where r3.on_under = '1') and
                          (r2.on_under = '2' or r2.on_under = 'A'))) r1
    on (b.bridge_gd = r1.bridge_gd)
  left outer join kdotblp_bridge kb
    on (b.bridge_gd = kb.bridge_gd)
  left outer join userrway ur
    on (r1.roadway_gd = ur.roadway_gd)
  left outer join (Select *
                     from (select i3.*,
                                  row_number() over(partition by i3.bridge_gd order by i3.inspdate, i3.createdatetime desc) rn
                             from inspevnt i3) i2
                    where i2.rn = 1) i1
    ON (b.bridge_gd = i1.bridge_gd)
  left outer join mv_latest_nbi_inspection mv
    on (i1.inspevnt_gd = mv.inspevnt_gd)
  left outer join kdotblp_inspections ki
    on (i1.inspevnt_gd = ki.inspevnt_gd)
  left outer join structure_unit su
    on (su.bridge_gd = b.bridge_gd)
  left outer join userstrunit us
    on (su.structure_unit_gd = us.structure_unit_gd)
 where NVL(trim(b.srstatus), '_') <> ('0')
 ORDER BY 1