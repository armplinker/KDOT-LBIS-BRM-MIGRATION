select pf.filterkey,
       pf.name,
       nvl(1, 0) as compliant,
       pf.sql_filter,
       pf.rowid
  FROM PON_FILTERS pf
 WHERE pf.filterkey >= 15000
   and pf.accessfilter = 0
   and pf.shared = 1
   and (regexp_like(lower(trim(pf.sql_filter)),
                    q'[^.*SELECT.*(b\.bridge_gd +as +key_).*(b\.brkey).*FROM( *| *
* *)(bridge +b).*(ORDER +BY +(1|b\.brkey))*.*((/* *#END# *\*/)*).*\Z]',
                    'inm'));
