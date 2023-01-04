CREATE OR REPLACE VIEW V_OVERDUE_OR_SCHEDULED_BRIDGES AS

-- VIEW DEPENDS ON MATERIALIZED VIEW MV_LATEST_INSPECTION.  Create that first.

SELECT
       b.brkey,
       b.strucname,
       b.BRIDGEGROUP,
       b.struct_num,
       b.county,
       b.placecode,
       b.featint,
       b.facility,
       b.owner,
       i.inspdate,
       NVL(i.scourcrit, '?') AS scourcrit,
       i.brinspfreq,
       i.lastinsp,
       i.nextinsp,
       Months_between( i.nextinsp, SYSDATE ) AS nbi_diff_months,
       i.uwinspreq, i.uwinspfreq, i.uwlastinsp, i.uwnextdate,
       CASE
            WHEN i.uwinspreq = 'Y' OR i.uwinspreq = '1' THEN Months_between( i.uwnextdate, SYSDATE )
            ELSE
                NULL
       END AS uw_diff_months,
       i.fcinspreq, i.fcinspfreq, i.fclastinsp, i.fcnextdate,
       CASE
            WHEN  i.fcinspreq = 'Y' OR i.fcinspreq = '1' THEN Months_between( i.fcnextdate, SYSDATE )
            ELSE
                NULL
       END AS fc_diff_months,
       i.osinspreq, i.osinspfreq, i.oslastinsp, i.osnextdate,
       CASE
            WHEN i.osinspreq =  'Y' OR i.osinspreq =  '1' THEN Months_between( i.osnextdate, SYSDATE )
            ELSE
                NULL
       END AS os_diff_months
FROM
      bridge b, inspevnt i, roadway r
WHERE
      b.brkey = i.brkey
AND
      b.OWNER IN ('2','02','3','03','4','04','11','12','25','32')
AND
      r.BRKEY = b.BRKEY
AND
      r.ON_UNDER = ( SELECT MIN(R2.ON_UNDER) FROM ROADWAY R2 WHERE R2.BRKEY = b.BRKEY )
AND
      i.inspkey = ( SELECT mv.inspkey FROM mv_latest_inspection mv WHERE mv.brkey = i.brkey )
AND
      i.oppostcl <> 'K';
