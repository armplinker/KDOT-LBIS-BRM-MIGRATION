prompt Importing table PON_FILTERS...
set feedback off
set define off
DELETE FROM PON_FILTERS WHERE FILTERKEY IN (16754, 16755, 16756);
COMMIT WORK;

insert into PON_FILTERS (FILTERKEY, USERKEY, NAME, ACCESSFILTER, SHARED, CONTEXT, SQL_FILTER, NOTES, FILTER_TYPE, WHERE_CLAUSE, EDITED_MANUALLY, PONTIS_STANDARD_IND, PON_FILTERS_GD, PON_APP_USERS_GD, SQL_ORDERBY, CREATEUSERKEY, CREATEDATETIME, MODTIME, GROUP_SHARED, ISACTIVE)
values (16754, '1', 'LBIS - Border Bridges Nebraska', 0, 1, 'Inspection', 'SELECT b.brkey,
       b.bridge_gd AS key_,
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
 WHERE extb.AGENCY=''NB'' -- Nebraska
 ORDER BY 1', 'Nebraska Border Bridges', 2, null, 1, 'F', '6F3CE058AC834335BA02B096E1B65F04', 'B330B38925654E468AE8E883F62A0E82', null, null, null, SYSDATE, 0, 1);

insert into PON_FILTERS (FILTERKEY, USERKEY, NAME, ACCESSFILTER, SHARED, CONTEXT, SQL_FILTER, NOTES, FILTER_TYPE, WHERE_CLAUSE, EDITED_MANUALLY, PONTIS_STANDARD_IND, PON_FILTERS_GD, PON_APP_USERS_GD, SQL_ORDERBY, CREATEUSERKEY, CREATEDATETIME, MODTIME, GROUP_SHARED, ISACTIVE)
values (16755, '1', 'LBIS - Border Bridges Oklahoma', 0, 1, 'Inspection', 'SELECT b.brkey,
       b.bridge_gd AS key_,
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
 WHERE AGENCY=''OK'' -- Oklahoma
 ORDER BY 1', 'Oklahoma Border Bridges', 2, null, 1, 'F', '92769801049542269CD5E198F93CF18E', 'B330B38925654E468AE8E883F62A0E82', null, null, null, SYSDATE, 0, 1);

insert into PON_FILTERS (FILTERKEY, USERKEY, NAME, ACCESSFILTER, SHARED, CONTEXT, SQL_FILTER, NOTES, FILTER_TYPE, WHERE_CLAUSE, EDITED_MANUALLY, PONTIS_STANDARD_IND, PON_FILTERS_GD, PON_APP_USERS_GD, SQL_ORDERBY, CREATEUSERKEY, CREATEDATETIME, MODTIME, GROUP_SHARED, ISACTIVE)
values (16756, '1', 'LBIS - Border Bridges Missouri', 0, 1, 'Inspection', 'SELECT b.brkey,
       b.bridge_gd AS key_,
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
 WHERE AGENCY=''MO'' -- Missouri
 ORDER BY 1', 'Missouri Border Bridges', 2, null, 1, 'F', '363224A019434664939BCBC290F4D893', 'B330B38925654E468AE8E883F62A0E82', null, null, null, SYSDATE, 0, 1);

prompt Done.
