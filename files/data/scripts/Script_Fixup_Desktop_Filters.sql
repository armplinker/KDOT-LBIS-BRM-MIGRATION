prompt Importing table PON_FILTERS...
set feedback off
set define off

prompt select t.*, t.rowid from PON_FILTERS t where t.filterkey > 15000 and shared=1 and accessfilter=0 and lower(context)='inspection' order by 1

delete from pon_filters t where t.filterkey > 15000 and shared=1 and accessfilter=0 and lower(context)='inspection';
commit work;

insert into PON_FILTERS (FILTERKEY, USERKEY, NAME, ACCESSFILTER, SHARED, CONTEXT, SQL_FILTER, NOTES, FILTER_TYPE, WHERE_CLAUSE, EDITED_MANUALLY, PONTIS_STANDARD_IND, PON_FILTERS_GD, PON_APP_USERS_GD, SQL_ORDERBY, CREATEUSERKEY, CREATEDATETIME, MODTIME, GROUP_SHARED, ISACTIVE)
values (16501, '1', 'LBIS Condition summary', 0, 1, 'Inspection', 'SELECT
       b.bridge_gd AS key_,
       b.brkey,
       b.bridge_id,
       v.lpa_bridge_id,
       v.feature_intersected,
       b.district,
       b.county,
       v.place,
       v.length_in_ft,
       v.built,
       v.inspdate,
       v.insptype,
       v.deck,
       v.super,
       v.sub,
       v.culv,
       v.chan,
       v.suff_rate,
       v.nbi_rating,
       v.hbrr_eligibility,
       v.bridge_condition,
       v.g_f_p,
       b.bridgegroup,
       b.bridge_gd /* same as key_ - may be removed eventually */
  FROM bridge b inner join V_CONDITION_SUMMARY_LAYOUT v
  ON (b.bridge_gd=v.bridge_gd)
 ORDER BY 1', 'Condition summary', 2, null, 1, 'F', 'F700E6425D9146879DE08ABBDFFFEA92', 'B330B38925654E468AE8E883F62A0E82', null, null, null, to_date('12-01-2023 12:44:30', 'dd-mm-yyyy hh24:mi:ss'), 0, 1);

insert into PON_FILTERS (FILTERKEY, USERKEY, NAME, ACCESSFILTER, SHARED, CONTEXT, SQL_FILTER, NOTES, FILTER_TYPE, WHERE_CLAUSE, EDITED_MANUALLY, PONTIS_STANDARD_IND, PON_FILTERS_GD, PON_APP_USERS_GD, SQL_ORDERBY, CREATEUSERKEY, CREATEDATETIME, MODTIME, GROUP_SHARED, ISACTIVE)
values (16502, '1', 'LBIS Material and Type of Main Span', 0, 1, 'Inspection', 'SELECT
b.bridge_gd AS key_,
b.Brkey,
b.Bridge_Id AS Bridge_Id,
b.Strucname AS Lpa_Bridge_Id,
       b.Featint   AS Feature_Intersected,
       Pd.Shortdesc AS District,
       Pc.Shortdesc AS County,
       Pl.Shortdesc AS Place,
      Lpad(to_char(to_number(f_safe_decimal( Nvl(b.Length,-1), 2, 12, ''N'',''N'')  ),''999,990.90'') ,12 )  AS "LENGTH (FT)",
       b.Yearbuilt  AS Built,
       b.Facility   AS Facility_Carried,
       CASE
         WHEN b.userkey1 is null or b.userkey1 = ''-1'' THEN
          ''Missing''
         ELSE
          Kdml.NBI_Material_Code || ''-'' || Kdml.NBI_Design_Code || '' : '' || Kdml.Kdot_Matl_Design_Code || ''-'' || Kdml.Kdot_Matl_Design_Label
       END AS KDOT_Design,
       Mt.Shortdesc AS Material,
       Ds.Shortdesc AS Design,
       b.bridge_gd
  FROM Bridge b,
       Paramtrs                       Pd,
       Paramtrs                       Pc,
       Paramtrs                       Po,
       Paramtrs                       Pm,
       Paramtrs                       Pl,
       Paramtrs                       Mt,
       Paramtrs                       Ds,
       Kdotblp_Design_Material_Lookup Kdml
 WHERE ( Pc.Table_Name = ''bridge''
   AND Pc.Field_Name = ''county''
   AND Pc.Parmvalue = b.County
   AND Pl.Table_Name = ''bridge''
   AND Pl.Field_Name = ''placecode''
   AND Pl.Parmvalue = b.Placecode
   AND Pd.Table_Name = ''bridge''
   AND Pd.Field_Name = ''district''
   AND Pd.Parmvalue = b.District
   AND Po.Table_Name = ''bridge''
   AND Po.Field_Name = ''custodian''
   AND Po.Parmvalue = b.Owner
   AND Pm.Table_Name = ''bridge''
   AND Pm.Field_Name = ''custodian''
   AND Pm.Parmvalue = b.Custodian
   AND Mt.Table_Name = ''bridge''
   AND Mt.Field_Name = ''materialmain''
   AND Mt.Parmvalue = b.Materialmain
   AND Ds.Table_Name = ''bridge''
   AND Ds.Field_Name = ''designmain''
   AND Ds.Parmvalue = b.Designmain
   AND Kdml.Kdot_Matl_Design_Key(+) = b.Userkey1)
   ORDER BY 1', 'Material and type of main span', 2, null, 1, 'F', '597655243BA14E30B7CD5F091A9E595B', 'B330B38925654E468AE8E883F62A0E82', null, null, null, to_date('12-01-2023 12:44:30', 'dd-mm-yyyy hh24:mi:ss'), 0, 1);

insert into PON_FILTERS (FILTERKEY, USERKEY, NAME, ACCESSFILTER, SHARED, CONTEXT, SQL_FILTER, NOTES, FILTER_TYPE, WHERE_CLAUSE, EDITED_MANUALLY, PONTIS_STANDARD_IND, PON_FILTERS_GD, PON_APP_USERS_GD, SQL_ORDERBY, CREATEUSERKEY, CREATEDATETIME, MODTIME, GROUP_SHARED, ISACTIVE)
values (16505, '1', 'LBIS Bridges with under roadways', 0, 1, 'Inspection', 'SELECT
       b.bridge_gd AS key_
      ,b.Brkey 
      ,b.Bridge_Id    AS Bridge_Id
      ,b.Strucname  AS Lpa_Bridge_Id
      ,b.Featint    AS Feature_Intersected
      ,Pd.Shortdesc AS District
      ,Pc.Shortdesc AS County
      ,Ppc.Shortdesc AS Place
      ,Round(Nvl(b.Length ,-1),2) AS Meters
      ,Nvl(b.Yearbuilt,-1) AS Built
      ,b.Facility AS Facility_Carried
      ,b.Bridge_Gd
  FROM Bridge   b
      ,Paramtrs Pd
      ,Paramtrs Pc
      ,Paramtrs Po
      ,Paramtrs Pm
      ,Paramtrs Ppc
 WHERE Pc.Table_Name = ''bridge''
   AND Pc.Field_Name = ''county''
   AND Pc.Parmvalue = b.County
   AND Ppc.Table_Name = ''bridge''
   AND Ppc.Field_Name = ''placecode''
   AND Ppc.Parmvalue = b.Placecode
   AND Pd.Table_Name = ''bridge''
   AND Pd.Field_Name = ''district''
   AND Pd.Parmvalue = b.District
   AND Po.Table_Name = ''bridge''
   AND Po.Field_Name = ''custodian''
   AND Po.Parmvalue = b.Owner
   AND Pm.Table_Name = ''bridge''
   AND Pm.Field_Name = ''custodian''
   AND Pm.Parmvalue = b.Custodian
   AND b.Bridge_Gd IN
       (SELECT DISTINCT rw.Bridge_gd FROM Roadway rw WHERE rw.On_Under <> ''1'')', 'Bridges with under roadways', 2, null, 1, 'F', '5A7A2FA3F55B4E04A8C8630AB82C6EC5', 'B330B38925654E468AE8E883F62A0E82', null, null, null, to_date('12-01-2023 12:44:30', 'dd-mm-yyyy hh24:mi:ss'), 0, 1);

insert into PON_FILTERS (FILTERKEY, USERKEY, NAME, ACCESSFILTER, SHARED, CONTEXT, SQL_FILTER, NOTES, FILTER_TYPE, WHERE_CLAUSE, EDITED_MANUALLY, PONTIS_STANDARD_IND, PON_FILTERS_GD, PON_APP_USERS_GD, SQL_ORDERBY, CREATEUSERKEY, CREATEDATETIME, MODTIME, GROUP_SHARED, ISACTIVE)
values (16506, '1', 'LBIS * Default', 0, 1, 'Inspection', 'SELECT
       b.bridge_gd AS key_,
       b.Brkey,
       b.Bridge_Id   AS Bridge_Id,
       b.Strucname   AS Lpa_Bridge_Id,
       b.Facility    AS Facility_Carried,
       b.Featint     AS Feature_Intersected,
       i.Lastinsp    AS Last_Nbi_Insp_Date,
       i.Inspdate    AS Nbi_Insp_Date,
       i.Insptype    as Insptype,
       b.Bridgegroup AS Bridge_Group,
       b.bridge_gd /* same as key_ - may be removed eventually */
  FROM Bridge b
 INNER JOIN (SELECT i1.Bridge_GD,
                    I1.Inspevnt_GD,
                    Row_Number() Over(PARTITION BY i1.Bridge_GD ORDER BY I1.Inspdate DESC) Rn
               FROM Inspevnt I1
              where i1.Insptype = ''I'') Mv
    ON b.bridge_GD = mv.bridge_GD
   AND Mv.Rn = 1
 INNER JOIN Inspevnt i
    ON i.INSPEVNT_GD = mv.INSPEVNT_GD
 ORDER BY 1', 'Default', 2, null, 1, 'F', 'A4B7B448EFC74C839F3D4BC7449C9586', 'B330B38925654E468AE8E883F62A0E82', null, null, null, to_date('12-01-2023 12:44:30', 'dd-mm-yyyy hh24:mi:ss'), 0, 1);

insert into PON_FILTERS (FILTERKEY, USERKEY, NAME, ACCESSFILTER, SHARED, CONTEXT, SQL_FILTER, NOTES, FILTER_TYPE, WHERE_CLAUSE, EDITED_MANUALLY, PONTIS_STANDARD_IND, PON_FILTERS_GD, PON_APP_USERS_GD, SQL_ORDERBY, CREATEUSERKEY, CREATEDATETIME, MODTIME, GROUP_SHARED, ISACTIVE)
values (16508, '1', 'LBIS Bridges with expired sufficiency ratings', 0, 1, 'Inspection', 'SELECT b.bridge_gd as key_,
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
       NVL(trim(b.srstatus), ''_'') as srstatus,
       b.bridge_gd /* same as key_ - may be removed eventually */
  from bridge b
  left outer join (select r2.*
                     from roadway r2
                    where r2.on_under = ''1''
                       or (r2.bridge_gd not in
                          (select r3.bridge_gd
                              from roadway r3
                             where r3.on_under = ''1'') and
                          (r2.on_under = ''2'' or r2.on_under = ''A''))) r1
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
 where NVL(trim(b.srstatus), ''_'') <> (''0'')
 ORDER BY 1', 'Bridges with expired sufficiency ratings', 2, null, 1, 'F', '6DF3283D32E449BE913320C80D727961', 'B330B38925654E468AE8E883F62A0E82', null, null, null, to_date('12-01-2023 12:44:30', 'dd-mm-yyyy hh24:mi:ss'), 0, 1);

insert into PON_FILTERS (FILTERKEY, USERKEY, NAME, ACCESSFILTER, SHARED, CONTEXT, SQL_FILTER, NOTES, FILTER_TYPE, WHERE_CLAUSE, EDITED_MANUALLY, PONTIS_STANDARD_IND, PON_FILTERS_GD, PON_APP_USERS_GD, SQL_ORDERBY, CREATEUSERKEY, CREATEDATETIME, MODTIME, GROUP_SHARED, ISACTIVE)
values (16509, '1', 'LBIS Bridges with no inspections', 0, 1, 'Inspection', 'SELECT
       b.bridge_gd AS key_,
       b.Brkey,
       b.bridge_id  AS Bridge_ID,
       b.strucname  as LPA_Bridge_ID,
       pd.shortdesc as District,
       pc.shortdesc as County,
       b.facility   AS Facility_Carried,
       b.featint    as Feature_Intersected,
       po.shortdesc as Own,
       pm.shortdesc as Maint,
       b.yearbuilt  as Built,
       b.bridge_gd /* same as key_ - may be removed eventually */
  FROM bridge b, paramtrs pd, paramtrs pc, paramtrs po, paramtrs pm
 WHERE pc.table_name = ''bridge''
   AND pc.field_name = ''county''
   AND pc.parmvalue = b.county
   AND pd.table_name = ''bridge''
   AND pd.field_name = ''district''
   AND pd.parmvalue = b.district
   AND po.table_name = ''bridge''
   AND po.field_name = ''custodian''
   AND po.parmvalue = b.owner
   AND pm.table_name = ''bridge''
   AND pm.field_name = ''custodian''
   AND pm.parmvalue = b.custodian
   AND NOT EXISTS
 (select i.brkey from inspevnt i where i.bridge_gd = b.bridge_gd)
 ORDER BY 1;', 'Bridges with no inspections', 2, null, 1, 'F', 'CEA49B55BF344582BF3B31919CBD66C1', 'B330B38925654E468AE8E883F62A0E82', null, null, null, to_date('12-01-2023 12:44:30', 'dd-mm-yyyy hh24:mi:ss'), 0, 1);

insert into PON_FILTERS (FILTERKEY, USERKEY, NAME, ACCESSFILTER, SHARED, CONTEXT, SQL_FILTER, NOTES, FILTER_TYPE, WHERE_CLAUSE, EDITED_MANUALLY, PONTIS_STANDARD_IND, PON_FILTERS_GD, PON_APP_USERS_GD, SQL_ORDERBY, CREATEUSERKEY, CREATEDATETIME, MODTIME, GROUP_SHARED, ISACTIVE)
values (16510, '1', 'LBIS Inspector and latest inspection date', 0, 1, 'Inspection', 'SELECT
       b.bridge_gd AS key_,
       b.Brkey,
       b.strucname  as LPA_Bridge_ID,
       i.inspname   as Inspector,
       i.lastinsp   as LAST_INSP_DATE,
       i.inspkey    as INSPKEY,
       pj.shortdesc as Inspection_Status,
       pt.shortdesc as Inspection_Type,
       pd.shortdesc as District,
       pc.shortdesc as County,
       b.facility   AS Facility_Carried,
       b.featint    as Feature_Intersected,
       b.yearbuilt  as Built,
       b.bridge_gd
  FROM bridge   b,
       inspevnt i,
       paramtrs pd,
       paramtrs pc,
       paramtrs pj,
       paramtrs pt
 WHERE pc.table_name = ''bridge''
   AND pc.field_name = ''county''
   AND pc.parmvalue = b.county
   AND pd.table_name = ''bridge''
   AND pd.field_name = ''district''
   AND pd.parmvalue = b.district
   AND pj.table_name = ''inspevnt''
   AND pj.field_name = ''inspstat''
   AND pj.parmvalue = i.inspstat
   AND pt.table_name = ''inspevnt''
   AND pt.field_name = ''insptype''
   AND pt.parmvalue = i.insptype
   AND (i.brkey = b.Brkey)
   and (i.inspkey =
       (select max(j.inspkey)
           from inspevnt j
          where j.brkey = b.Brkey
            and j.inspdate = (select max(k.inspdate)
                                from inspevnt k
                               where k.brkey = b.Brkey)))', 'Inspector and inspection date', 2, null, 1, 'F', 'A45D15BED9FE4CD8AE50AF42B7407F21', 'B330B38925654E468AE8E883F62A0E82', null, null, null, to_date('12-01-2023 12:44:30', 'dd-mm-yyyy hh24:mi:ss'), 0, 1);

insert into PON_FILTERS (FILTERKEY, USERKEY, NAME, ACCESSFILTER, SHARED, CONTEXT, SQL_FILTER, NOTES, FILTER_TYPE, WHERE_CLAUSE, EDITED_MANUALLY, PONTIS_STANDARD_IND, PON_FILTERS_GD, PON_APP_USERS_GD, SQL_ORDERBY, CREATEUSERKEY, CREATEDATETIME, MODTIME, GROUP_SHARED, ISACTIVE)
values (16512, '1', 'LBIS Bridges with QCQA inspections', 0, 1, 'Inspection', 'SELECT
       b.bridge_gd AS key_,
       b.Brkey,
       b.bridge_id          AS Bridge_ID,
       b.strucname          as LPA_Bridge_ID,
       b.bridgegroup,
       v.feature,
       b.district,
       b.county,
       v.place,
       v.year_built,
       v.inspdate           as RECORD_DATE,
       v.lastinsp           as LAST_ROUT_INSP,
       v.inspector,
       v.inspkey,
       v.deck,
       v.deck_qaqc,
       v.DKMM,
       v.super,
       v.super_qaqc,
       v.sub,
       v.sub_qaqc,
       v.culv,
       v.culv_qaqc,
       v.chan,
       v.chan_qaqc,
       v.length_ft,
       v.length_ft_qaqc,
       v.aroadwidth_ft,
       v.aroadwidth_ft_qaqc,
       v.vclrinv_ft,
       v.vclrinv_ft_qaqc,
       v.hclrinv_ft,
       v.hclrinv_ft_qaqc,
       v.design,
       v.design_qaqc,
       v.material,
       v.material_qaqc,
       v.sr,
       v.sr_ok_qaqc,
       v.nbi_rating,
       v.nbi_rating_qaqc,
       v.hbrr_status,
       b.bridge_gd /* same as key_ - may be removed eventually */
  FROM bridge b inner join v_qaqc_condition_sumry_layout v
  on (b.bridge_gd=v.bridge_gd)
  ORDER BY 1', 'Bridges with QCQA inspections showing data comparisons', 2, null, 1, 'F', '870EF7B5D9EC40E6BFF0DFCE6F25BE49', 'B330B38925654E468AE8E883F62A0E82', null, null, null, to_date('12-01-2023 12:44:30', 'dd-mm-yyyy hh24:mi:ss'), 0, 1);

insert into PON_FILTERS (FILTERKEY, USERKEY, NAME, ACCESSFILTER, SHARED, CONTEXT, SQL_FILTER, NOTES, FILTER_TYPE, WHERE_CLAUSE, EDITED_MANUALLY, PONTIS_STANDARD_IND, PON_FILTERS_GD, PON_APP_USERS_GD, SQL_ORDERBY, CREATEUSERKEY, CREATEDATETIME, MODTIME, GROUP_SHARED, ISACTIVE)
values (16514, '1', 'LBIS Bridges with locked inspections', 0, 1, 'Inspection', 'SELECT
       b.bridge_gd AS key_,
       b.Brkey,
       b.bridge_id  AS Bridge_ID,
       b.strucname  as LPA_Bridge_ID,
       pd.shortdesc as District,
       pc.shortdesc as County,
       b.facility   AS Facility_Carried,
       b.featint    as Feature_Intersected,
       po.shortdesc as Own,
       pm.shortdesc as Maint,
       b.yearbuilt  as Built,
       b.bridge_gd /* same as key_ - may be removed eventually */
  FROM bridge b, paramtrs pd, paramtrs pc, paramtrs po, paramtrs pm
 WHERE (pc.table_name = ''bridge'' AND pc.field_name = ''county'' AND
       pc.parmvalue = b.county AND pd.table_name = ''bridge'' AND
       pd.field_name = ''district'' AND pd.parmvalue = b.district AND
       po.table_name = ''bridge'' AND po.field_name = ''custodian'' AND
       po.parmvalue = b.owner AND pm.table_name = ''bridge'' AND
       pm.field_name = ''custodian'' AND pm.parmvalue = b.custodian AND
       exists (SELECT 1
                 from INSPEVNT i
                where i.BRKEY = b.Brkey
                  and i.inspstat = ''4''))
 ORDER BY 1', 'Locked bridges w/ Inspector and inspection date', 2, null, 1, 'F', '066F20917C574969B0EE18F1F9F37898', 'B330B38925654E468AE8E883F62A0E82', null, null, null, to_date('12-01-2023 12:44:30', 'dd-mm-yyyy hh24:mi:ss'), 0, 1);

insert into PON_FILTERS (FILTERKEY, USERKEY, NAME, ACCESSFILTER, SHARED, CONTEXT, SQL_FILTER, NOTES, FILTER_TYPE, WHERE_CLAUSE, EDITED_MANUALLY, PONTIS_STANDARD_IND, PON_FILTERS_GD, PON_APP_USERS_GD, SQL_ORDERBY, CREATEUSERKEY, CREATEDATETIME, MODTIME, GROUP_SHARED, ISACTIVE)
values (16515, '1', 'LBIS Bridges with Annual Routine Inspection', 0, 1, 'Inspection', 'SELECT
       b.bridge_gd AS key_,
       b.Brkey,
       bridge_id    AS Bridge_ID,
       b.strucname  as LPA_Bridge_ID,
       pd.shortdesc as District,
       pc.shortdesc as Material_Main_43A,
       po.shortdesc as Design_Main_43B,
       facility     AS Facility_Carried,
       featint      as Feature_Intersected,
       i.inspname   as Inspector,
       i.lastinsp   as LAST_INSP_DATE,
       i.brinspfreq as Inspection_Freq,
       yearbuilt    as Year_Built,
       bridgegroup  as Bridge_Group,
       b.bridge_gd /* same as key_ - may be removed eventually */
  FROM bridge   b,
       inspevnt i,
       paramtrs pd,
       paramtrs pc,
       paramtrs po,
       paramtrs pm
 WHERE pc.table_name = ''bridge''
   AND pc.field_name = ''materialmain''
   AND pc.parmvalue = b.materialmain
   AND pd.table_name = ''bridge''
   AND pd.field_name = ''district''
   AND pd.parmvalue = b.district
   AND po.table_name = ''bridge''
   AND po.field_name = ''designmain''
   AND po.parmvalue = b.designmain
   AND pm.table_name = ''bridge''
   AND pm.field_name = ''custodian''
   AND pm.parmvalue = b.custodian
   AND (i.brinspfreq = ''12'')
   AND (i.brkey = b.Brkey)
   and (i.inspkey =
       (select max(j.inspkey)
           from inspevnt j
          where j.brkey = b.Brkey
            and j.inspdate = (select max(k.inspdate)
                                from inspevnt k
                               where k.brkey = b.Brkey)))', 'Bridges with Annual Inspections', 2, null, 1, 'F', '83A27DA1EF1C408C8615A78095BEA602', 'B330B38925654E468AE8E883F62A0E82', null, null, null, to_date('12-01-2023 12:44:30', 'dd-mm-yyyy hh24:mi:ss'), 0, 1);

insert into PON_FILTERS (FILTERKEY, USERKEY, NAME, ACCESSFILTER, SHARED, CONTEXT, SQL_FILTER, NOTES, FILTER_TYPE, WHERE_CLAUSE, EDITED_MANUALLY, PONTIS_STANDARD_IND, PON_FILTERS_GD, PON_APP_USERS_GD, SQL_ORDERBY, CREATEUSERKEY, CREATEDATETIME, MODTIME, GROUP_SHARED, ISACTIVE)
values (16556, null, 'LBIS Bridges changed or created today', 0, 1, 'Inspection', 'SELECT
       b.bridge_gd AS key_,
       b.Brkey,
       b.Bridge_Id   AS Bridge_Id,
       b.Strucname   AS Lpa_Bridge_Id,
       Pd.Shortdesc  AS District,
       Pc.Shortdesc  AS Material_Main_43a,
       Po.Shortdesc  AS Design_Main_43b,
       b.Facility    AS Facility_Carried,
       b.Featint     AS Feature_Intersected,
       i.Inspname    AS Inspector,
       i.Lastinsp    AS Last_Insp_Date,
       b.Yearbuilt   AS Built,
       b.Bridgegroup AS Bridge_Group,
       b.Bridge_Gd /* same as key_ - may be removed eventually */
  FROM Bridge b
  LEFT OUTER JOIN Inspevnt i
    ON i.Bridge_Gd = b.Bridge_Gd
  LEFT OUTER JOIN Paramtrs Pd
    ON Pd.Parmvalue = b.District
   AND Pd.Table_Name = ''bridge''
   AND Pd.Field_Name = ''district''
  LEFT OUTER JOIN Paramtrs Pc
    ON Pc.Parmvalue = b.Materialmain
   AND Pc.Table_Name = ''bridge''
   AND Pc.Field_Name = ''materialmain''
  LEFT OUTER JOIN Paramtrs Po
    ON Po.Parmvalue = b.Designmain
   AND Po.Table_Name = ''bridge''
   AND Po.Field_Name = ''designmain''
  LEFT OUTER JOIN Paramtrs Pm2
    ON Pm2.Parmvalue = b.Owner
   AND Pm2.Table_Name = ''bridge''
   AND Pm2.Field_Name = ''owner''
  LEFT OUTER JOIN Paramtrs Pm
    ON Pm.Parmvalue = b.Custodian
   AND Pm.Table_Name = ''bridge''
   AND Pm.Field_Name = ''custodian''
 WHERE (i.Inspkey =
       (SELECT MAX(j.Inspkey)
           FROM Inspevnt j
          WHERE j.Bridge_Gd = b.Bridge_Gd
            AND j.Inspdate = (SELECT MAX(k.Inspdate)
                                FROM Inspevnt k
                               WHERE k.Bridge_Gd = b.Bridge_Gd)))
   AND (Trunc(b.Createdatetime) >= Trunc(SYSDATE) OR
       Trunc(b.Modtime) >= Trunc(SYSDATE))
       ORDER BY 1', null, 2, null, 1, 'F', 'E78D189027A44455BB2B3F91E01CEEEC', null, null, null, null, to_date('12-01-2023 12:44:30', 'dd-mm-yyyy hh24:mi:ss'), 0, 1);

insert into PON_FILTERS (FILTERKEY, USERKEY, NAME, ACCESSFILTER, SHARED, CONTEXT, SQL_FILTER, NOTES, FILTER_TYPE, WHERE_CLAUSE, EDITED_MANUALLY, PONTIS_STANDARD_IND, PON_FILTERS_GD, PON_APP_USERS_GD, SQL_ORDERBY, CREATEUSERKEY, CREATEDATETIME, MODTIME, GROUP_SHARED, ISACTIVE)
values (16611, '1', 'LBIS Structures with fracture critical reports', 0, 1, 'Inspection', 'SELECT
       b.bridge_gd   AS key_,
       b.Brkey,
       b.bridge_id   AS Bridge_ID,
       b.strucname   as LPA_Bridge_ID,
       pd.shortdesc  as District,
       pc.shortdesc  as Material_Main_43A,
       po.shortdesc  as Design_Main_43B,
       b.facility    AS Facility_Carried,
       b.featint     as Feature_Intersected,
       i.inspname    as Inspector,
       i.lastinsp    as LAST_INSP_DATE,
       b.yearbuilt   as Built,
       b.bridgegroup as Bridge_Group,
       b.bridge_gd /* same as key_ - may be removed eventually */
  FROM bridge   b,
       inspevnt i,
       paramtrs pd,
       paramtrs pc,
       paramtrs po,
       paramtrs pm
 WHERE pc.table_name = ''bridge''
   AND pc.field_name = ''materialmain''
   AND pc.parmvalue = b.materialmain
   AND pd.table_name = ''bridge''
   AND pd.field_name = ''district''
   AND pd.parmvalue = b.district
   AND po.table_name = ''bridge''
   AND po.field_name = ''designmain''
   AND po.parmvalue = b.designmain
   AND pm.table_name = ''bridge''
   AND pm.field_name = ''custodian''
   AND pm.parmvalue = b.custodian
   AND (i.brkey = b.Brkey)
   and (i.inspkey =
       (select max(j.inspkey)
           from inspevnt j
          where j.brkey = b.Brkey
            and j.inspdate = (select max(k.inspdate)
                                from inspevnt k
                               where k.brkey = b.Brkey)))
   AND EXISTS (SELECT 1
          FROM kdotblp_documents
         WHERE brkey = b.Brkey
           AND doc_type_key = ''11'')', 'Structures with fracture critical reports', 2, null, 1, 'F', 'C609E585BB8246E6965C9346823AD042', 'B330B38925654E468AE8E883F62A0E82', null, null, null, to_date('12-01-2023 12:44:30', 'dd-mm-yyyy hh24:mi:ss'), 0, 1);

insert into PON_FILTERS (FILTERKEY, USERKEY, NAME, ACCESSFILTER, SHARED, CONTEXT, SQL_FILTER, NOTES, FILTER_TYPE, WHERE_CLAUSE, EDITED_MANUALLY, PONTIS_STANDARD_IND, PON_FILTERS_GD, PON_APP_USERS_GD, SQL_ORDERBY, CREATEUSERKEY, CREATEDATETIME, MODTIME, GROUP_SHARED, ISACTIVE)
values (16612, '1', 'LBIS Structures with underwater inspection reports', 0, 1, 'Inspection', 'SELECT
       b.bridge_gd   AS key_,
       b.Brkey,
       b.bridge_id   AS Bridge_ID,
       b.strucname   as LPA_Bridge_ID,
       pd.shortdesc  as District,
       pc.shortdesc  as Material_Main_43A,
       po.shortdesc  as Design_Main_43B,
       b.facility    AS Facility_Carried,
       b.featint     as Feature_Intersected,
       i.inspname    as Inspector,
       i.lastinsp    as LAST_INSP_DATE,
       b.yearbuilt   as Built,
       b.bridgegroup as Bridge_Group,
       b.bridge_gd /* same as key_ - may be removed eventually */
  FROM bridge   b,
       inspevnt i,
       paramtrs pd,
       paramtrs pc,
       paramtrs po,
       paramtrs pm
 WHERE pc.table_name = ''bridge''
   AND pc.field_name = ''materialmain''
   AND pc.parmvalue = b.materialmain
   AND pd.table_name = ''bridge''
   AND pd.field_name = ''district''
   AND pd.parmvalue = b.district
   AND po.table_name = ''bridge''
   AND po.field_name = ''designmain''
   AND po.parmvalue = b.designmain
   AND pm.table_name = ''bridge''
   AND pm.field_name = ''custodian''
   AND pm.parmvalue = b.custodian
   AND (i.brkey = b.Brkey)
   and (i.inspkey =
       (select max(j.inspkey)
           from inspevnt j
          where j.brkey = b.Brkey
            and j.inspdate = (select max(k.inspdate)
                                from inspevnt k
                               where k.brkey = b.Brkey)))
   AND EXISTS (SELECT 1
          FROM kdotblp_documents
         WHERE brkey = b.Brkey
           AND doc_type_key = ''12'')', 'Structures with underwater inspection reports', 2, null, 1, 'F', 'FD36CAFA12C348718174A6AB261B16D6', 'B330B38925654E468AE8E883F62A0E82', null, null, null, to_date('12-01-2023 12:44:30', 'dd-mm-yyyy hh24:mi:ss'), 0, 1);

insert into PON_FILTERS (FILTERKEY, USERKEY, NAME, ACCESSFILTER, SHARED, CONTEXT, SQL_FILTER, NOTES, FILTER_TYPE, WHERE_CLAUSE, EDITED_MANUALLY, PONTIS_STANDARD_IND, PON_FILTERS_GD, PON_APP_USERS_GD, SQL_ORDERBY, CREATEUSERKEY, CREATEDATETIME, MODTIME, GROUP_SHARED, ISACTIVE)
values (16613, '1', 'LBIS Structures with special inspection reports', 0, 1, 'Inspection', 'SELECT
       b.bridge_gd   AS key_,
       b.Brkey,
       b.bridge_id   AS Bridge_ID,
       b.strucname   as LPA_Bridge_ID,
       pd.shortdesc  as District,
       pc.shortdesc  as Material_Main_43A,
       po.shortdesc  as Design_Main_43B,
       b.facility    AS Facility_Carried,
       b.featint     as Feature_Intersected,
       i.inspname    as Inspector,
       i.lastinsp    as LAST_INSP_DATE,
       b.yearbuilt   as Built,
       b.bridgegroup as Bridge_Group,
       b.bridge_gd /* same as key_ - may be removed eventually */
  FROM bridge   b,
       inspevnt i,
       paramtrs pd,
       paramtrs pc,
       paramtrs po,
       paramtrs pm
 WHERE pc.table_name = ''bridge''
   AND pc.field_name = ''materialmain''
   AND pc.parmvalue = b.materialmain
   AND pd.table_name = ''bridge''
   AND pd.field_name = ''district''
   AND pd.parmvalue = b.district
   AND po.table_name = ''bridge''
   AND po.field_name = ''designmain''
   AND po.parmvalue = b.designmain
   AND pm.table_name = ''bridge''
   AND pm.field_name = ''custodian''
   AND pm.parmvalue = b.custodian
   AND (i.brkey = b.Brkey)
   and (i.inspkey =
       (select max(j.inspkey)
           from inspevnt j
          where j.brkey = b.Brkey
            and j.inspdate = (select max(k.inspdate)
                                from inspevnt k
                               where k.brkey = b.Brkey)))
   AND EXISTS (SELECT 1
          FROM kdotblp_documents
         WHERE brkey = b.Brkey
           AND doc_type_key = ''13'')', 'Structures with special inspection reports', 2, null, 1, 'F', 'B6FA18E5B91744E3B1E6EEE8C79097A0', 'B330B38925654E468AE8E883F62A0E82', null, null, null, to_date('12-01-2023 12:44:31', 'dd-mm-yyyy hh24:mi:ss'), 0, 1);

insert into PON_FILTERS (FILTERKEY, USERKEY, NAME, ACCESSFILTER, SHARED, CONTEXT, SQL_FILTER, NOTES, FILTER_TYPE, WHERE_CLAUSE, EDITED_MANUALLY, PONTIS_STANDARD_IND, PON_FILTERS_GD, PON_APP_USERS_GD, SQL_ORDERBY, CREATEUSERKEY, CREATEDATETIME, MODTIME, GROUP_SHARED, ISACTIVE)
values (16614, '1', 'LBIS Structures with scour reports', 0, 1, 'Inspection', 'SELECT
       b.bridge_gd   AS key_,
       b.Brkey,
       b.bridge_id   AS Bridge_ID,
       b.strucname   as LPA_Bridge_ID,
       pd.shortdesc  as District,
       pc.shortdesc  as Material_Main_43A,
       po.shortdesc  as Design_Main_43B,
       b.facility    AS Facility_Carried,
       b.featint     as Feature_Intersected,
       i.inspname    as Inspector,
       i.lastinsp    as LAST_INSP_DATE,
       b.yearbuilt   as Built,
       b.bridgegroup as Bridge_Group,
       b.bridge_gd /* same as key_ - may be removed eventually */
  FROM bridge   b,
       inspevnt i,
       paramtrs pd,
       paramtrs pc,
       paramtrs po,
       paramtrs pm
 WHERE pc.table_name = ''bridge''
   AND pc.field_name = ''materialmain''
   AND pc.parmvalue = b.materialmain
   AND pd.table_name = ''bridge''
   AND pd.field_name = ''district''
   AND pd.parmvalue = b.district
   AND po.table_name = ''bridge''
   AND po.field_name = ''designmain''
   AND po.parmvalue = b.designmain
   AND pm.table_name = ''bridge''
   AND pm.field_name = ''custodian''
   AND pm.parmvalue = b.custodian
   AND (i.brkey = b.Brkey)
   and (i.inspkey =
       (select max(j.inspkey)
           from inspevnt j
          where j.brkey = b.Brkey
            and j.inspdate = (select max(k.inspdate)
                                from inspevnt k
                               where k.brkey = b.Brkey)))
   AND EXISTS (SELECT 1
          FROM kdotblp_documents
         WHERE brkey = b.Brkey
           AND doc_type_key = ''50'')', 'Structures with scour reports', 2, null, 1, 'F', '159543F081AC40EA9934B3708B46EBE4', 'B330B38925654E468AE8E883F62A0E82', null, null, null, to_date('12-01-2023 12:44:31', 'dd-mm-yyyy hh24:mi:ss'), 0, 1);

insert into PON_FILTERS (FILTERKEY, USERKEY, NAME, ACCESSFILTER, SHARED, CONTEXT, SQL_FILTER, NOTES, FILTER_TYPE, WHERE_CLAUSE, EDITED_MANUALLY, PONTIS_STANDARD_IND, PON_FILTERS_GD, PON_APP_USERS_GD, SQL_ORDERBY, CREATEUSERKEY, CREATEDATETIME, MODTIME, GROUP_SHARED, ISACTIVE)
values (16615, '1', 'LBIS Structures with critical inspection findings', 0, 1, 'Inspection', 'SELECT
       b.bridge_gd   AS key_,
       b.Brkey,
       b.bridge_id   AS Bridge_ID,
       b.strucname   as LPA_Bridge_ID,
       pd.shortdesc  as District,
       pc.shortdesc  as Material_Main_43A,
       po.shortdesc  as Design_Main_43B,
       b.facility    AS Facility_Carried,
       b.featint     as Feature_Intersected,
       i.inspname    as Inspector,
       i.lastinsp    as LAST_INSP_DATE,
       b.yearbuilt   as Built,
       b.bridgegroup as Bridge_Group,
       b.bridge_gd /* same as key_ - may be removed eventually */
  FROM bridge   b,
       inspevnt i,
       paramtrs pd,
       paramtrs pc,
       paramtrs po,
       paramtrs pm
 WHERE pc.table_name = ''bridge''
   AND pc.field_name = ''materialmain''
   AND pc.parmvalue = b.materialmain
   AND pd.table_name = ''bridge''
   AND pd.field_name = ''district''
   AND pd.parmvalue = b.district
   AND po.table_name = ''bridge''
   AND po.field_name = ''designmain''
   AND po.parmvalue = b.designmain
   AND pm.table_name = ''bridge''
   AND pm.field_name = ''custodian''
   AND pm.parmvalue = b.custodian
   AND (i.brkey = b.Brkey)
   and (i.inspkey =
       (select max(j.inspkey)
           from inspevnt j
          where j.brkey = b.Brkey
            and j.inspdate = (select max(k.inspdate)
                                from inspevnt k
                               where k.brkey = b.Brkey)))
   AND EXISTS (SELECT 1
          FROM kdotblp_documents
         WHERE brkey = b.Brkey
           AND doc_type_key = ''15'')', 'Structures with critical inspection findings', 2, null, 1, 'F', '2FE51CBA8D2F466183E14A47663B0B19', 'B330B38925654E468AE8E883F62A0E82', null, null, null, to_date('12-01-2023 12:44:31', 'dd-mm-yyyy hh24:mi:ss'), 0, 1);

insert into PON_FILTERS (FILTERKEY, USERKEY, NAME, ACCESSFILTER, SHARED, CONTEXT, SQL_FILTER, NOTES, FILTER_TYPE, WHERE_CLAUSE, EDITED_MANUALLY, PONTIS_STANDARD_IND, PON_FILTERS_GD, PON_APP_USERS_GD, SQL_ORDERBY, CREATEUSERKEY, CREATEDATETIME, MODTIME, GROUP_SHARED, ISACTIVE)
values (16616, '1', 'LBIS Structures with load ratings forms', 0, 1, 'Inspection', 'SELECT
       b.bridge_gd   AS key_,
       b.Brkey,
       b.bridge_id   AS Bridge_ID,
       b.strucname   as LPA_Bridge_ID,
       pd.shortdesc  as District,
       pc.shortdesc  as Material_Main_43A,
       po.shortdesc  as Design_Main_43B,
       b.facility    AS Facility_Carried,
       b.featint     as Feature_Intersected,
       i.inspname    as Inspector,
       i.lastinsp    as LAST_INSP_DATE,
       b.yearbuilt   as Built,
       b.bridgegroup as Bridge_Group,
       b.bridge_gd /* same as key_ - may be removed eventually */
  FROM bridge   b,
       inspevnt i,
       paramtrs pd,
       paramtrs pc,
       paramtrs po,
       paramtrs pm
 WHERE pc.table_name = ''bridge''
   AND pc.field_name = ''materialmain''
   AND pc.parmvalue = b.materialmain
   AND pd.table_name = ''bridge''
   AND pd.field_name = ''district''
   AND pd.parmvalue = b.district
   AND po.table_name = ''bridge''
   AND po.field_name = ''designmain''
   AND po.parmvalue = b.designmain
   AND pm.table_name = ''bridge''
   AND pm.field_name = ''custodian''
   AND pm.parmvalue = b.custodian
   AND (i.brkey = b.Brkey)
   and (i.inspkey =
       (select max(j.inspkey)
           from inspevnt j
          where j.brkey = b.Brkey
            and j.inspdate = (select max(k.inspdate)
                                from inspevnt k
                               where k.brkey = b.Brkey)))
   AND EXISTS (SELECT 1
          FROM kdotblp_documents kd
         WHERE kd.bridge_gd = b.bridge_gd
           AND kd.doc_type_key = ''60'')
 ORDER BY 1;', 'Structures with load ratings forms', 2, null, 1, 'F', '223E43E78E61415987276AF4A6D2A3B8', 'B330B38925654E468AE8E883F62A0E82', null, null, null, to_date('12-01-2023 12:44:31', 'dd-mm-yyyy hh24:mi:ss'), 0, 1);

insert into PON_FILTERS (FILTERKEY, USERKEY, NAME, ACCESSFILTER, SHARED, CONTEXT, SQL_FILTER, NOTES, FILTER_TYPE, WHERE_CLAUSE, EDITED_MANUALLY, PONTIS_STANDARD_IND, PON_FILTERS_GD, PON_APP_USERS_GD, SQL_ORDERBY, CREATEUSERKEY, CREATEDATETIME, MODTIME, GROUP_SHARED, ISACTIVE)
values (16617, '1', 'LBIS Structures with existing plans', 0, 1, 'Inspection', 'SELECT
       b.bridge_gd   AS key_,
       b.Brkey,
       b.bridge_id   AS Bridge_ID,
       b.strucname   as LPA_Bridge_ID,
       pd.shortdesc  as District,
       pc.shortdesc  as Material_Main_43A,
       po.shortdesc  as Design_Main_43B,
       b.facility    AS Facility_Carried,
       b.featint     as Feature_Intersected,
       i.inspname    as Inspector,
       i.lastinsp    as LAST_INSP_DATE,
       b.yearbuilt   as Built,
       b.bridgegroup as Bridge_Group,
       b.bridge_gd /* same as key_ - may be removed eventually */
  FROM bridge   b,
       inspevnt i,
       paramtrs pd,
       paramtrs pc,
       paramtrs po,
       paramtrs pm
 WHERE pc.table_name = ''bridge''
   AND pc.field_name = ''materialmain''
   AND pc.parmvalue = b.materialmain
   AND pd.table_name = ''bridge''
   AND pd.field_name = ''district''
   AND pd.parmvalue = b.district
   AND po.table_name = ''bridge''
   AND po.field_name = ''designmain''
   AND po.parmvalue = b.designmain
   AND pm.table_name = ''bridge''
   AND pm.field_name = ''custodian''
   AND pm.parmvalue = b.custodian
   AND (i.brkey = b.Brkey)
   and (i.inspkey =
       (select max(j.inspkey)
           from inspevnt j
          where j.brkey = b.Brkey
            and j.inspdate = (select max(k.inspdate)
                                from inspevnt k
                               where k.brkey = b.Brkey)))
   AND EXISTS (SELECT 1
          FROM kdotblp_documents
         WHERE brkey = b.Brkey
           AND doc_type_key = ''17'')
 ORDER BY 1;', 'Structures with existing plans', 2, null, 1, 'F', 'B870D3EB548B45D5B6F5C1FE6A789985', 'B330B38925654E468AE8E883F62A0E82', null, null, null, to_date('12-01-2023 12:44:31', 'dd-mm-yyyy hh24:mi:ss'), 0, 1);

insert into PON_FILTERS (FILTERKEY, USERKEY, NAME, ACCESSFILTER, SHARED, CONTEXT, SQL_FILTER, NOTES, FILTER_TYPE, WHERE_CLAUSE, EDITED_MANUALLY, PONTIS_STANDARD_IND, PON_FILTERS_GD, PON_APP_USERS_GD, SQL_ORDERBY, CREATEUSERKEY, CREATEDATETIME, MODTIME, GROUP_SHARED, ISACTIVE)
values (16711, '1', 'LBIS * Structures with FC inspections', 0, 1, 'Inspection', 'SELECT
       b.bridge_gd   AS key_,
       b.Brkey,
       b.Bridge_Id AS Bridge_Id,
       b.Strucname AS Lpa_Bridge_Id,
       b.Featint AS Feature_Intersected,
       I1.Inspdate,
       vu.fc_Inspdate,
       vu.fcinsptype,
       vu.description,
       f_Lbl(b.District, ''bridge'', ''district'') AS District,
       f_Lbl(b.County, ''bridge'', ''county'') AS County,
       f_Lbl(b.Placecode, ''bridge'', ''placecode'') AS Place,
       Round(b.Length, 2) AS Feet,
       Trunc(b.Yearbuilt) AS Built,
       b.Facility AS Facility_Carried,
       I1.Inspevnt_Gd,
       b.bridge_gd /* same as key_ - may be removed eventually */
  FROM Bridge b
  LEFT OUTER JOIN Inspevnt I1
    ON (b.Bridge_Gd = I1.Bridge_Gd)
 INNER JOIN (SELECT * FROM V_BRIDGES_WITH_FC_INSPECTIONS ) vu
    ON (b.BRIDGE_GD =vu.BRIDGE_GD And I1.Inspevnt_Gd = vu.Inspevnt_Gd AND vu.Rn = 1)
  WHERE LOWER(TRIM(b.BRIDGEGROUP)) NOT IN
       (SELECT LOWER(TRIM(keb.bridgegroup)) FROM KDOTBLP_EXCLUDED_BRIDGEGROUPS keb)
   AND (1 = 1)
 ORDER BY 1;', 'Structures with FC inspections', 2, null, 1, 'F', '7D8F54EA7C2C4235966ABBBDE66E1459', 'B330B38925654E468AE8E883F62A0E82', null, null, null, to_date('12-01-2023 12:44:31', 'dd-mm-yyyy hh24:mi:ss'), 0, 1);

insert into PON_FILTERS (FILTERKEY, USERKEY, NAME, ACCESSFILTER, SHARED, CONTEXT, SQL_FILTER, NOTES, FILTER_TYPE, WHERE_CLAUSE, EDITED_MANUALLY, PONTIS_STANDARD_IND, PON_FILTERS_GD, PON_APP_USERS_GD, SQL_ORDERBY, CREATEUSERKEY, CREATEDATETIME, MODTIME, GROUP_SHARED, ISACTIVE)
values (16712, '1', 'LBIS * Structures with UW inspections', 0, 1, 'Inspection', 'SELECT
       b.bridge_gd   AS key_,
       b.Brkey,
       b.Bridge_Id AS Bridge_Id,
       b.Strucname AS Lpa_Bridge_Id,
       b.Featint AS Feature_Intersected,
       I1.Inspdate,
       vu.Uw_Inspdate,
       vu.uwinsptype,
       vu.description,
       f_Lbl(b.District, ''bridge'', ''district'') AS District,
       f_Lbl(b.County, ''bridge'', ''county'') AS County,
       f_Lbl(b.Placecode, ''bridge'', ''placecode'') AS Place,
       Round(b.Length, 2) AS Feet,
       Trunc(b.Yearbuilt) AS Built,
       b.Facility AS Facility_Carried,
       I1.Inspevnt_Gd,
       b.bridge_gd /* same as key_ - may be removed eventually */
  FROM Bridge b
  LEFT OUTER JOIN Inspevnt I1
    ON (b.Bridge_Gd = I1.Bridge_Gd)
 INNER JOIN (SELECT * FROM V_BRIDGES_WITH_UW_INSPECTIONS ) vu
    ON (b.BRIDGE_GD =vu.BRIDGE_GD And I1.Inspevnt_Gd = vu.Inspevnt_Gd AND vu.Rn = 1)
  WHERE LOWER(TRIM(b.BRIDGEGROUP)) NOT IN
       (SELECT LOWER(TRIM(keb.bridgegroup)) FROM KDOTBLP_EXCLUDED_BRIDGEGROUPS keb)
   AND (1 = 1)
 ORDER BY 1;', 'Structures with UW inspections', 2, null, 1, 'F', '370A3C8AC6A846A7B1B7802952F5E1AC', 'B330B38925654E468AE8E883F62A0E82', null, null, null, to_date('12-01-2023 12:44:31', 'dd-mm-yyyy hh24:mi:ss'), 0, 1);

insert into PON_FILTERS (FILTERKEY, USERKEY, NAME, ACCESSFILTER, SHARED, CONTEXT, SQL_FILTER, NOTES, FILTER_TYPE, WHERE_CLAUSE, EDITED_MANUALLY, PONTIS_STANDARD_IND, PON_FILTERS_GD, PON_APP_USERS_GD, SQL_ORDERBY, CREATEUSERKEY, CREATEDATETIME, MODTIME, GROUP_SHARED, ISACTIVE)
values (16713, '1', 'LBIS * Structures with OS inspections', 0, 1, 'Inspection', 'SELECT b.bridge_gd AS key_,
       b.Brkey,
       b.Bridge_Id AS Bridge_Id,
       b.Strucname AS Lpa_Bridge_Id,
       b.Featint AS Feature_Intersected,
       I1.Inspdate,
       vbase.OS_Inspdate,
       vbase.spinsptype,
       vbase.description,
       f_Lbl(b.District, ''bridge'', ''district'') AS District,
       f_Lbl(b.County, ''bridge'', ''county'') AS County,
       f_Lbl(b.Placecode, ''bridge'', ''placecode'') AS Place,
       Round(b.Length, 2) AS Feet,
       Trunc(b.Yearbuilt) AS Built,
       b.Facility AS Facility_Carried,
       I1.Inspevnt_Gd,
       b.Bridge_Gd /* same as key_ - may be removed eventually */
  FROM Bridge b
  LEFT OUTER JOIN Inspevnt i1
    ON (b.bridge_gd = i1.bridge_gd)
 INNER JOIN (SELECT vu.* FROM V_BRIDGES_WITH_OS_INSPECTIONS vu) vbase
    ON (b.BRIDGE_GD = vbase.BRIDGE_GD And
       I1.Inspevnt_Gd = vbase.Inspevnt_Gd AND vbase.Rn = 1)
 WHERE LOWER(TRIM(b.BRIDGEGROUP)) NOT IN
       (SELECT LOWER(TRIM(keb.bridgegroup))
          FROM KDOTBLP_EXCLUDED_BRIDGEGROUPS keb)
   AND (1 = 1)
 ORDER BY 1', 'Structures with OS inspections', 2, null, 1, 'F', 'BEA9B2DB4A864B528C4DFE99708D5CFC', 'B330B38925654E468AE8E883F62A0E82', null, null, null, to_date('12-01-2023 12:44:31', 'dd-mm-yyyy hh24:mi:ss'), 0, 1);

insert into PON_FILTERS (FILTERKEY, USERKEY, NAME, ACCESSFILTER, SHARED, CONTEXT, SQL_FILTER, NOTES, FILTER_TYPE, WHERE_CLAUSE, EDITED_MANUALLY, PONTIS_STANDARD_IND, PON_FILTERS_GD, PON_APP_USERS_GD, SQL_ORDERBY, CREATEUSERKEY, CREATEDATETIME, MODTIME, GROUP_SHARED, ISACTIVE)
values (16715, '5868', 'Local - Railroads', 0, 1, 'inspection', null, 'Owner or Custodian = RailRoad (27)', 1, 'where bridge.owner in (''27'') and bridge.custodian in (''27'')', 0, 'F', '390E370F282744BDAD60AA0AEE9331CC', '84A15942D4B749EF9C7A0AAC460081AE', null, null, null, to_date('12-01-2023 12:44:31', 'dd-mm-yyyy hh24:mi:ss'), 0, 1);

insert into PON_FILTERS (FILTERKEY, USERKEY, NAME, ACCESSFILTER, SHARED, CONTEXT, SQL_FILTER, NOTES, FILTER_TYPE, WHERE_CLAUSE, EDITED_MANUALLY, PONTIS_STANDARD_IND, PON_FILTERS_GD, PON_APP_USERS_GD, SQL_ORDERBY, CREATEUSERKEY, CREATEDATETIME, MODTIME, GROUP_SHARED, ISACTIVE)
values (16750, '1', 'LBIS - FC Ever Required Since 2012', 0, 1, 'Inspection', 'SELECT
       b.bridge_gd AS key_,
       b.Brkey,
       b.Bridge_Id AS Bridge_Id,
       b.Strucname AS Lpa_Bridge_Id,
       b.Featint AS Feature_Intersected,
       f_Get_Nbilabel_Fromcode(''bridge'', ''district'', b.District) AS District,
       f_Get_Nbilabel_Fromcode(''bridge'', ''county'', b.County) AS County,
       f_Get_Nbilabel_Fromcode(''bridge'', ''placecode'', b.Placecode) AS Place,
       b.Length AS Feet,
       b.Yearbuilt AS Built,
       b.Facility AS Facility_Carried,
       b.bridge_gd /* same as key_ - may be removed eventually */
  FROM Bridge b
 INNER JOIN v_Fc_Ever_Reqd_Since_2012 v
    ON b.Bridge_Gd = v.Bridge_Gd
 WHERE (1 = 1)
 ORDER BY 1', 'Shows bridges where a FC inspection was ever required since 2012', 2, null, 1, 'F', '416CD39900C946209C3890F0A61BE762', 'B330B38925654E468AE8E883F62A0E82', null, null, null, to_date('12-01-2023 12:44:31', 'dd-mm-yyyy hh24:mi:ss'), 0, 1);

insert into PON_FILTERS (FILTERKEY, USERKEY, NAME, ACCESSFILTER, SHARED, CONTEXT, SQL_FILTER, NOTES, FILTER_TYPE, WHERE_CLAUSE, EDITED_MANUALLY, PONTIS_STANDARD_IND, PON_FILTERS_GD, PON_APP_USERS_GD, SQL_ORDERBY, CREATEUSERKEY, CREATEDATETIME, MODTIME, GROUP_SHARED, ISACTIVE)
values (16751, '1', 'LBIS - NBI Export', 0, 1, 'Inspection', 'SELECT
       b.bridge_gd AS key_,
       b.Brkey,
       b.Bridge_Id AS Bridge_Id,
       f_lbl(b.district, ''bridge'', ''district'') AS District,
       b.Facility AS Facility_Carried,
       b.Featint AS Feature_Intersected,
       i.Lastinsp AS Last_Insp_Date,
       i.Inspdate AS NBI_Insp_Date,
       b.Bridgegroup AS Bridge_Group,
       mv.inspevnt_gd,
       i.insptype b.bridge_gd /* same as key_ - may be removed eventually */
  FROM Bridge b
 INNER JOIN (SELECT b.Bridge_GD,
                    I1.Inspevnt_GD,
                    Row_Number() Over(PARTITION BY b.Bridge_GD ORDER BY I1.Inspdate DESC) Rn
               FROM Inspevnt I1
              INNER JOIN Bridge b
                 ON I1.Bridge_GD = b.Bridge_GD) Mv
    ON b.bridge_GD = mv.bridge_GD
   AND Mv.Rn = 1
 INNER JOIN Inspevnt i
    ON i.INSPEVNT_GD = mv.INSPEVNT_GD
 WHERE LOWER(TRIM(b.BRIDGEGROUP)) NOT IN
       (SELECT LOWER(TRIM(keb.bridgegroup))
          FROM KDOTBLP_EXCLUDED_BRIDGEGROUPS keb)
   AND NOT EXISTS (SELECT 1
          FROM KDOTBLP_EXCLUDED_STRUCTURES kexcl
         WHERE kexcl.BRIDGE_GD = b.BRIDGE_GD)
   AND (1 = 1)
 ORDER BY 1', 'NBI export filter to remove Bridge Groups that we don''t submit', 2, null, 1, 'F', 'F648101991FB42018A21F019C242EC2F', 'B330B38925654E468AE8E883F62A0E82', null, null, null, to_date('12-01-2023 12:44:31', 'dd-mm-yyyy hh24:mi:ss'), 0, 1);

insert into PON_FILTERS (FILTERKEY, USERKEY, NAME, ACCESSFILTER, SHARED, CONTEXT, SQL_FILTER, NOTES, FILTER_TYPE, WHERE_CLAUSE, EDITED_MANUALLY, PONTIS_STANDARD_IND, PON_FILTERS_GD, PON_APP_USERS_GD, SQL_ORDERBY, CREATEUSERKEY, CREATEDATETIME, MODTIME, GROUP_SHARED, ISACTIVE)
values (16753, '1', 'LBIS - Off System Bridges', 0, 1, 'Inspection', 'SELECT
       b.bridge_gd AS key_,
       b.Brkey,
       b.bridge_id  AS Bridge_ID,
       b.strucname  AS LPA_Bridge_ID,
       b.featint    AS Feature_Intersected,
       pd.shortdesc AS District,
       pc.shortdesc AS County,
       pl.shortdesc AS Place,
       b.yearbuilt  AS Built,
       b.facility   AS Facility_Carried,
       b.bridge_gd /* same as key_ - may be removed eventually */
  FROM bridge   b,
       paramtrs pd,
       paramtrs pc,
       paramtrs po,
       paramtrs pm,
       paramtrs pl
 WHERE pc.table_name = ''bridge''
   AND pc.field_name = ''county''
   AND pc.parmvalue = b.county
   AND pl.table_name = ''bridge''
   AND pl.field_name = ''placecode''
   AND pl.parmvalue = b.placecode
   AND pd.table_name = ''bridge''
   AND pd.field_name = ''district''
   AND pd.parmvalue = b.district
   AND po.table_name = ''bridge''
   AND po.field_name = ''custodian''
   AND po.parmvalue = b.owner
   AND pm.table_name = ''bridge''
   AND pm.field_name = ''custodian''
   AND pm.parmvalue = b.custodian
   AND b.Brkey IN (select mv.brkey from MV_OFF_SYSTEM_BRIDGES mv)', 'Off System Bridge List 2017', 2, null, 1, 'F', '0AE94C7B91834E47B9CCB3D4357F6035', 'B330B38925654E468AE8E883F62A0E82', null, null, null, null, 0, 0);

insert into PON_FILTERS (FILTERKEY, USERKEY, NAME, ACCESSFILTER, SHARED, CONTEXT, SQL_FILTER, NOTES, FILTER_TYPE, WHERE_CLAUSE, EDITED_MANUALLY, PONTIS_STANDARD_IND, PON_FILTERS_GD, PON_APP_USERS_GD, SQL_ORDERBY, CREATEUSERKEY, CREATEDATETIME, MODTIME, GROUP_SHARED, ISACTIVE)
values (16754, '1', 'LBIS - Border Bridges Nebraska', 0, 1, 'Inspection', 'SELECT
       b.bridge_gd AS key_,
       b.Brkey,
       b.bridge_id,
       EXTB.agency,
       b.nstatecode,
       kdot_blp.f_get_paramtrs_equiv(''bridge'', ''county'', b.county) AS County,
       b.bridgegroup AS bridgegroup,
       b.featint AS Feature_Crossed,
       b.location AS Location,
       b.bb_pct AS bb_pct,
       b.bb_brdgeid AS bb_brdgeid,
       i.inspdate AS Inspdate,
       i.date_entered AS Record_Date,
       i.inspname AS Inspector,
       b.bridge_gd /* same as key_ - may be removed eventually */
  FROM bridge b
 inner join EXTERNAL_AGENCY_BRIDGES EXTB
    ON b.BRIDGE_GD = EXTB.BRIDGE_GD
 INNER JOIN mv_latest_inspection mv
    ON b.bridge_gd = mv.bridge_gd
 INNER JOIN INSPEVNT i
    ON b.bridge_gd = i.bridge_gd
   and mv.inspevnt_gd = i.inspevnt_gd
 WHERE extb.AGENCY=''NB'' /* Nebraska */
 ORDER BY 1', 'Nebraska Border Bridges', 2, null, 1, 'F', '6F3CE058AC834335BA02B096E1B65F04', 'B330B38925654E468AE8E883F62A0E82', null, null, null, to_date('12-01-2023 12:44:31', 'dd-mm-yyyy hh24:mi:ss'), 0, 1);

insert into PON_FILTERS (FILTERKEY, USERKEY, NAME, ACCESSFILTER, SHARED, CONTEXT, SQL_FILTER, NOTES, FILTER_TYPE, WHERE_CLAUSE, EDITED_MANUALLY, PONTIS_STANDARD_IND, PON_FILTERS_GD, PON_APP_USERS_GD, SQL_ORDERBY, CREATEUSERKEY, CREATEDATETIME, MODTIME, GROUP_SHARED, ISACTIVE)
values (16755, '1', 'LBIS - Border Bridges Oklahoma', 0, 1, 'Inspection', 'SELECT
       b.bridge_gd AS key_,
       b.Brkey,
       b.bridge_id,
       EXTB.agency,
       b.nstatecode,
       kdot_blp.f_get_paramtrs_equiv(''bridge'', ''county'', b.county) AS County,
       b.bridgegroup AS bridgegroup,
       b.featint AS Feature_Crossed,
       b.location AS Location,
       b.bb_pct AS bb_pct,
       b.bb_brdgeid AS bb_brdgeid,
       i.inspdate AS Inspdate,
       i.date_entered AS Record_Date,
       i.inspname AS Inspector,
       b.bridge_gd /* same as key_ - may be removed eventually */
  FROM bridge b
 inner join EXTERNAL_AGENCY_BRIDGES EXTB
    ON b.BRIDGE_GD = EXTB.BRIDGE_GD
 INNER JOIN mv_latest_inspection mv
    ON b.bridge_gd = mv.bridge_gd
 INNER JOIN INSPEVNT i
    ON b.bridge_gd = i.bridge_gd
   and mv.inspevnt_gd = i.inspevnt_gd
 WHERE AGENCY=''OK'' /* Oklahoma */
 ORDER BY 1', 'Oklahoma Border Bridges', 2, null, 1, 'F', '92769801049542269CD5E198F93CF18E', 'B330B38925654E468AE8E883F62A0E82', null, null, null, to_date('12-01-2023 12:44:31', 'dd-mm-yyyy hh24:mi:ss'), 0, 1);

insert into PON_FILTERS (FILTERKEY, USERKEY, NAME, ACCESSFILTER, SHARED, CONTEXT, SQL_FILTER, NOTES, FILTER_TYPE, WHERE_CLAUSE, EDITED_MANUALLY, PONTIS_STANDARD_IND, PON_FILTERS_GD, PON_APP_USERS_GD, SQL_ORDERBY, CREATEUSERKEY, CREATEDATETIME, MODTIME, GROUP_SHARED, ISACTIVE)
values (16756, '1', 'LBIS - Border Bridges Missouri', 0, 1, 'Inspection', 'SELECT
       b.bridge_gd AS key_,
       b.Brkey,
       b.bridge_id,
       EXTB.agency,
       b.nstatecode,
       kdot_blp.f_get_paramtrs_equiv(''bridge'', ''county'', b.county) AS County,
       b.bridgegroup AS bridgegroup,
       b.featint AS Feature_Crossed,
       b.location AS Location,
       b.bb_pct AS bb_pct,
       b.bb_brdgeid AS bb_brdgeid,
       i.inspdate AS Inspdate,
       i.date_entered AS Record_Date,
       i.inspname AS Inspector,
       b.bridge_gd /* same as key_ - may be removed eventually */
  FROM bridge b
 inner join EXTERNAL_AGENCY_BRIDGES EXTB
    ON b.BRIDGE_GD = EXTB.BRIDGE_GD
 INNER JOIN mv_latest_inspection mv
    ON b.bridge_gd = mv.bridge_gd
 INNER JOIN INSPEVNT i
    ON b.bridge_gd = i.bridge_gd
   and mv.inspevnt_gd = i.inspevnt_gd
 WHERE AGENCY=''MO'' /* Missouri */
 ORDER BY 1', 'Missouri Border Bridges', 2, null, 1, 'F', '363224A019434664939BCBC290F4D893', 'B330B38925654E468AE8E883F62A0E82', null, null, null, to_date('12-01-2023 12:44:31', 'dd-mm-yyyy hh24:mi:ss'), 0, 1);

insert into PON_FILTERS (FILTERKEY, USERKEY, NAME, ACCESSFILTER, SHARED, CONTEXT, SQL_FILTER, NOTES, FILTER_TYPE, WHERE_CLAUSE, EDITED_MANUALLY, PONTIS_STANDARD_IND, PON_FILTERS_GD, PON_APP_USERS_GD, SQL_ORDERBY, CREATEUSERKEY, CREATEDATETIME, MODTIME, GROUP_SHARED, ISACTIVE)
values (16781, '1', 'LBIS - NBI Export - TESTING', 0, 1, 'Inspection', 'SELECT
       b.bridge_gd as key_,
       b.brkey,
       b.Bridge_Id AS Bridge_Id,
       f_lbl(b.district, ''bridge'', ''district'') AS District,
       b.Facility AS Facility_Carried,
       b.Featint AS Feature_Intersected,
       i.Lastinsp AS Last_Insp_Date,
       i.Inspdate AS NBI_Insp_Date,
       b.Bridgegroup AS Bridge_Group,
       mv.inspevnt_gd,
       b.bridge_gd  /* same as key_ - may be removed eventually */

  FROM Bridge b
 INNER JOIN (SELECT b.Bridge_GD,
                    I1.Inspevnt_GD,
                    Row_Number() Over(PARTITION BY b.Bridge_GD ORDER BY I1.Inspdate DESC) Rn
               FROM Inspevnt I1
              INNER JOIN Bridge b
                 ON I1.Bridge_GD = b.Bridge_GD) Mv
    ON b.bridge_GD = mv.bridge_GD
   AND Mv.Rn = 1
 INNER JOIN Inspevnt i
    ON i.INSPEVNT_GD = mv.INSPEVNT_GD
 WHERE LOWER(TRIM(b.BRIDGEGROUP)) NOT IN
       (SELECT LOWER(TRIM(keb.bridgegroup))
          FROM KDOTBLP_EXCLUDED_BRIDGEGROUPS keb)
   AND NOT EXISTS (SELECT 1
          FROM KDOTBLP_EXCLUDED_STRUCTURES kexcl
         WHERE kexcl.BRIDGE_GD = b.BRIDGE_GD)
   AND ROWNUM <= 10
   AND (1=1)
 ORDER BY 1', null, 2, null, 1, 'F', 'F51F91E6D2364B10812F1C4FA36F1731', 'B330B38925654E468AE8E883F62A0E82', null, null, null, null, 0, 0);

insert into PON_FILTERS (FILTERKEY, USERKEY, NAME, ACCESSFILTER, SHARED, CONTEXT, SQL_FILTER, NOTES, FILTER_TYPE, WHERE_CLAUSE, EDITED_MANUALLY, PONTIS_STANDARD_IND, PON_FILTERS_GD, PON_APP_USERS_GD, SQL_ORDERBY, CREATEUSERKEY, CREATEDATETIME, MODTIME, GROUP_SHARED, ISACTIVE)
values (16785, '1', 'LBIS - Bridges with load rating data', 0, 1, 'Inspection', 'SELECT b.bridge_gd                AS key_,
       b.Brkey,
       b.bridge_id                "Bridge ID",
       b.strucname                LPA_Bridge_ID,
       i.Lastinsp                 "LAST_INSP_DATE",
       Rat.Load_Rating_Date       "LATEST_RATING_DATE",
       pm.shortdesc               method,
       Rat.Controlling_Element    "CONTROLLING_ELEMENT",
       Rat.Load_Rating_Lead_Firm  "LEAD FIRM",
       Rat.Load_Rating_Consultant "CONSULTANT",
       b.Bridgegroup              "BRIDGE_GROUP",
       Pd.Shortdesc               District,
       b.Facility                 Facility_Carried,
       b.Featint                  Feature_Intersected,
       b.bridge_gd /*may remove*/
  FROM Bridge b
 INNER JOIN Mv_Latest_Inspection Mv
    ON b.Bridge_Gd = Mv.Bridge_Gd
 INNER JOIN Inspevnt i
    ON Mv.Inspevnt_Gd = i.Inspevnt_Gd
 INNER JOIN Kdotblp_Load_Ratings Rat
    ON b.Bridge_Gd = Rat.Bridge_Gd
   AND i.Inspevnt_Gd = Rat.Inspevnt_Gd

   And Rat.Load_Rating_Date =
       (SELECT MAX(Rat2.Load_Rating_Date)
          FROM Kdotblp_Load_Ratings Rat2
         WHERE Rat2.Bridge_Gd = b.Bridge_Gd)
  LEFT OUTER JOIN Paramtrs Pd
    ON (Pd.Table_Name = ''bridge'' AND Pd.Field_Name = ''district'' AND
       Pd.Parmvalue = b.District)
  LEFT OUTER JOIN Paramtrs Pm
    ON (Pm.Table_Name = ''bridge'' AND Pm.Field_Name = ''ortype'' AND
       Pm.Parmvalue = rat.rating_method)
 WHERE LOWER(TRIM(b.BRIDGEGROUP)) NOT IN
       (SELECT LOWER(TRIM(keb.bridgegroup))
          FROM KDOTBLP_EXCLUDED_BRIDGEGROUPS keb)
   AND EXISTS (SELECT 1
          FROM Kdotblp_Load_Ratings Klr
         WHERE Klr.Bridge_Gd = b.Bridge_Gd)
 ORDER BY 1', null, 2, null, 1, 'F', '964E49F761F44BD299020292D5883B57', 'B330B38925654E468AE8E883F62A0E82', null, null, null, to_date('12-01-2023 12:44:31', 'dd-mm-yyyy hh24:mi:ss'), 0, 1);

insert into PON_FILTERS (FILTERKEY, USERKEY, NAME, ACCESSFILTER, SHARED, CONTEXT, SQL_FILTER, NOTES, FILTER_TYPE, WHERE_CLAUSE, EDITED_MANUALLY, PONTIS_STANDARD_IND, PON_FILTERS_GD, PON_APP_USERS_GD, SQL_ORDERBY, CREATEUSERKEY, CREATEDATETIME, MODTIME, GROUP_SHARED, ISACTIVE)
values (16790, '1', 'LBIS - Find-A-Bridge List', 0, 1, 'Inspection', 'SELECT
       b.bridge_gd AS key_,
       b.Brkey,
       b.bridge_gd,
       b.Bridge_Id      AS Bridge_Id,
       b.Strucname      AS Lpa_Bridge_Id,
       b.Bridgegroup    AS Bridgegroup,
       i.Inspname       AS Inspector,
       i.Lastinsp       AS Last_Insp_Date,
       i.Inspdate       AS Nbi_Last_Insp,
       b.Createdatetime AS Created,
       Pau.Userkey      AS Create_Userkey,
       Pau.Userid       AS Created_By
  FROM Bridge b
  LEFT OUTER JOIN Pon_App_Users Pau
    ON Pau.Pon_App_Users_GD = b.Createuserkey
 INNER JOIN (SELECT b.Bridge_GD,
                    I1.Inspevnt_GD,
                    Row_Number() Over(PARTITION BY b.Bridge_GD ORDER BY I1.Inspdate DESC) Rn
               FROM Inspevnt I1
              INNER JOIN Bridge b
                 ON I1.Bridge_GD = b.Bridge_GD) Mv
    ON b.bridge_GD = mv.bridge_GD
   AND Mv.Rn = 1
 INNER JOIN Inspevnt i
    ON i.INSPEVNT_GD = mv.INSPEVNT_GD
 ORDER BY 1', 'For this one, leave bridge_gd at the start of the result row so it can be used to look up bridges by BRIDGE_GD', 1, null, 1, 'F', '44B9EDC6ABE446D38E529AA2C2F4E3C6', 'B330B38925654E468AE8E883F62A0E82', null, null, null, to_date('12-01-2023 12:44:31', 'dd-mm-yyyy hh24:mi:ss'), 0, 1);

insert into PON_FILTERS (FILTERKEY, USERKEY, NAME, ACCESSFILTER, SHARED, CONTEXT, SQL_FILTER, NOTES, FILTER_TYPE, WHERE_CLAUSE, EDITED_MANUALLY, PONTIS_STANDARD_IND, PON_FILTERS_GD, PON_APP_USERS_GD, SQL_ORDERBY, CREATEUSERKEY, CREATEDATETIME, MODTIME, GROUP_SHARED, ISACTIVE)
values (16791, '1', 'LBIS - Pin and Hanger Contract Bridges', 0, 1, 'Inspection', null, 'Pin & Hanger contract bridges', 2, 'where bridge.userkey6 = ''0''', 1, 'F', 'D171102CD8A6429EB59C686E062704E1', 'B330B38925654E468AE8E883F62A0E82', null, null, null, to_date('12-01-2023 12:44:31', 'dd-mm-yyyy hh24:mi:ss'), 0, 1);

insert into PON_FILTERS (FILTERKEY, USERKEY, NAME, ACCESSFILTER, SHARED, CONTEXT, SQL_FILTER, NOTES, FILTER_TYPE, WHERE_CLAUSE, EDITED_MANUALLY, PONTIS_STANDARD_IND, PON_FILTERS_GD, PON_APP_USERS_GD, SQL_ORDERBY, CREATEUSERKEY, CREATEDATETIME, MODTIME, GROUP_SHARED, ISACTIVE)
values (16795, '1', 'LBIS - Bridges with problematic BRIDGEGROUP', 0, 1, 'Inspection', 'SELECT
       b.bridge_gd AS key_
      ,b.Brkey
      ,b.Bridge_Id AS Bridge_Id
      ,b.Strucname AS Lpa_Bridge_Id
      ,b.Bridgegroup AS Bridge_Group
      ,f_Lbl(b.District, ''bridge'', ''district'') AS District
      ,f_Lbl(b.County, ''bridge'', ''county'') AS County
      ,f_Lbl(b.Placecode, ''bridge'', ''placecode'') AS Placecode
      ,b.Yearbuilt AS Built
      ,b.Designmain Nbi_43a
      ,b.Materialmain Nbi_43b
      ,b.Userkey1 AS Kdot_Design_Code
      ,f_Get_Kdot_Md_Lbl_Fr_Codes(b.Userkey1, b.Materialmain, b.Designmain) AS Kdot_Design
      ,b.Mainspans
      ,b.Appspans
      ,b.Bridge_Gd /* same as key_ - may be removed eventually */
  FROM Bridge b
 WHERE Lower(TRIM(b.Bridgegroup)) = ''unassigned''
    OR ((Trunc(b.Createdatetime) >= Add_Months(SYSDATE, -12) OR
        Trunc(b.Modtime) >= Add_Months(SYSDATE, -12)) AND
        (b.Bridgegroup IS NULL OR b.Bridgegroup = '''' OR
        b.Bridgegroup = ''-1'' OR NOT EXISTS
         (SELECT 1
            FROM Paramtrs p
           WHERE p.Field_Name = ''bridgegroup''
             AND Lower(TRIM(p.Shortdesc)) = Lower(TRIM(b.Bridgegroup))
             AND f_Is_Yes(p.Isactive) = 1)))
             ORDER BY 1; /* required as last ORDER BY */', 'Shows any bridges witha  questionable BRIDGEGROUP value - NULL, blank, -1 or does not exist in PARAMTRS', 1, null, 1, 'F', '2ED874CCDA774E3ABAD667FA2B26ADC5', 'B330B38925654E468AE8E883F62A0E82', null, null, null, to_date('12-01-2023 12:44:31', 'dd-mm-yyyy hh24:mi:ss'), 0, 1);

commit work;

prompt Done.
