/* ARMarshall, ARM LLC - 20230205 - 

a script to  check every value of SQL _FILTER in PON_FILTERS with a regular expression that confirms basic syntax correctness
usage:  Execute this SQL in a SQL window while connected to a BLP database
Any records that are returned with a 1 for compliant confom to the basic requirement:
a) must include SELECT b.bridge_gd as key_
b) must include .... b.brkey somewhere
c) must use the alias b. for bridge

Caveats:
Does not actually test the syntax for correctness
Case-sensitivity is ignored.

Other:

Use  the script Script_Check_Desktop_SQL.pdc to exercise every filter and show the # of records expected (no user access filter applied)
Any records returning 0 rows may have SQL errors.



*/

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
