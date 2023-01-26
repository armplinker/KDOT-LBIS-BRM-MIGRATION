with cte as
 (select brkey,
         inspkey,
         inspevnt_gd,
         modtime,
         row_number() OVER(PARTITION BY BRKEY, INSPKEY ORDER BY MODTIME DESC) as RN
    from kdotblp_inspections
   where bridge_gd in ('0C231D500C7F40E38111F9DB0F48B011',
                       '3157B63FC3414A98BE0956D5BBAEF6E8',
                       '3E0BB7D254E741A49D53C16FD1AB18C2',
                       '4B8EE48FCB394403B5D002F9EB952D6E',
                       '4E7C516579C5481E8282048462A4BCB1',
                       '73282316A79340C9B6349B7C97AD2B59',
                       '7BFA829CE6054AC68806245CCADDFBAA',
                       '894F2684B07D4C6D9E3BE4A93DBF60FF',
                       '8E6D8C95044F4EA09C0FEFABD39E1DC3',
                       'C0ED77345EBA4CC38A3F86F8DE64890B',
                       'C6CB5801375F4E53A5538D0BB86D0E04',
                       'E3A6B21E8AB54981818EA979DE8A0CB7')
   order by 1, 2)
SELECT ki.BRKEY, ki.INSPKEY, ki.INSPEVNT_GD, cte.rn
  FROM KDOTBLP_INSPECTIONS ki
 INNER JOIN CTE
    ON (ki.INSPEVNT_GD = CTE.INSPEVNT_GD AND CTE.RN > 1);
