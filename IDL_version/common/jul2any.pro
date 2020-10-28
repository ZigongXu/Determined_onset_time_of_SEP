;Name: jul2any
;
;Purpose: in order to print time in file in an standard format like utc/ints/ etc used in anytim.pro
;
; Input: julday,extra
;       :julday : the time from temporal intensity plot using label_date
;       :any keywords using in anytim.pro
;

function jul2any,julday,_REF_EXTRA=extra
  min_julian = -31776
  max_julian = 1827933925
  if (julday gt max_julian or julday lt min_julian) then return,-1
  caldat,julday,month,day,year,hour,min,second 
 ; year=abs(year)
  result = {YEAR: year,  $
    MONTH:  month,  $
    DAY:  day,  $
    HOUR: hour,  $
    MINUTE: min,  $
    SECOND: fix(second), $
    MILLISECOND: (second-fix(second))*1000}
  return,anytim(result,_extra=extra)
 end