/* SELECT json_object('id'          VALUE employee_id,
                   'name'        VALUE first_name || ' ' || last_name,
                   'hireDate'    VALUE hire_date,
                   'pay'         VALUE salary,
                   'contactInfo' VALUE json_object('mail'  VALUE email,
                                                   'phone' VALUE phone_number)
                                       FORMAT JSON) 
  FROM employees
  WHERE salary > 15000; */
  
/*  SELECT LISTAGG(last_name, '; ')
         WITHIN GROUP (ORDER BY hire_date, last_name) "Emp_list",
       MIN(hire_date) "Earliest"
  FROM employees
  WHERE department_id = 30;*/
  
 WITH CTE AS   (
   SELECT  chr(13)||chr(10) || LISTAGG( q'[']'|| LOWER(utc.COLUMN_NAME) || q'[']'
   || q'[ VALUE ]' || utc.COLUMN_NAME || chr(13)||chr(10), q'[ , ]' ) "JSON_COLS"  
  FROM USER_TAB_COLS utc 
  WHERE utc.TABLE_NAME='KDOTBLP_DOCUMENTS' 
  ORDER BY utc.COLUMN_ID  )
 SELECT q'[SELECT JSON_OBJECT( ]' ||   "CTE"."JSON_COLS"  || q'[ ) ]' as json_object
 FROM CTE;
  
