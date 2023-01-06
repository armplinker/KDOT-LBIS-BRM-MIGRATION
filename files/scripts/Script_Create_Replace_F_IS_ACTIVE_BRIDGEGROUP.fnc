create or replace function F_IS_ACTIVE_BRIDGEGROUP(pBridgeGroup IN VARCHAR2)
  return pls_integer is
  FunctionResult pls_integer := 0; -- not active if NULL.
begin
  -- for a given bridgegroup argument, if it is in this list then it is INACTIVE
  -- otherwise apparently an ACTIVE group
  -- returns PLS_INTEGER - default is 0 - not active if NULL.
  -- usage: if F_IS_ACTIVE_BRIDGEGROUP(x)=1  then do something with it because it is active or
  -- usage: if F_IS_ACTIVE_BRIDGEGROUP(x)=0  then do something with it because it is INactive
  if (pBridgeGroup is not null) THEN
    FunctionResult := CASE
                        WHEN UPPER(TRIM(NVL(pBridgeGroup, 'UNASSIGNED'))) IN
                             ('UNASSIGNED',
                              'CLOSED',
                              'PERM CLOSED',
                              'PERM CLOSED',
                              'PEDESTRIAN',
                              'PRIVATE',
                              'RAILROAD',
                              'REMOVED',
                              'RESERVED',
                              'TOO SHORT',
                              'TRANSFERRED',
                              'BORDER BRIDGES') THEN
                         0 -- INACTIVE OR NOT SET OR WHATEVER, NOT ACTIVE
                        ELSE
                         1 -- OK
                      END;
  END IF;
  return(FunctionResult);
end F_IS_ACTIVE_BRIDGEGROUP;
/
