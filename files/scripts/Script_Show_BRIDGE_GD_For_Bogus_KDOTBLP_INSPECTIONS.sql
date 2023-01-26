select bridge_gd, brkey, inspkey, count(*) from userinsp 
group by bridge_gd, brkey, inspkey
having count(*)>1
order by 1,3
