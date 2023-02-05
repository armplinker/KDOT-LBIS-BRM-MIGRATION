select pf.*, pf.rowid
  from pon_filters pf
 where pf.filterkey > 15000
   and pf.accessfilter = 0
   and shared = 1
   AND not (regexp_like(lower(trim(pf.sql_filter)),
                        q'[^.*SELECT.*(b\.bridge_gd +as +key_).*(b\.brkey).*FROM( *| *
* *)(bridge +b).*(ORDER +BY +(1|b\.brkey))*.*((/* *#END# *\*/)*).*\Z]',
                        'inm'))
 order by pf.filterkey;
