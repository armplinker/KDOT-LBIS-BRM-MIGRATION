SELECT b.Brkey,
       b.bridge_gd       AS key_,
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
       b.bridge_gd
  FROM bridge   b,
       inspevnt i,
       paramtrs pd,
       paramtrs pc,
       paramtrs po,
       paramtrs pm
 WHERE pc.table_name = 'bridge'
   AND pc.field_name = 'materialmain'
   AND pc.parmvalue = b.materialmain
   AND pd.table_name = 'bridge'
   AND pd.field_name = 'district'
   AND pd.parmvalue = b.district
   AND po.table_name = 'bridge'
   AND po.field_name = 'designmain'
   AND po.parmvalue = b.designmain
   AND pm.table_name = 'bridge'
   AND pm.field_name = 'custodian'
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
           AND doc_type_key = '12')
