
function doy2jul,year,doy
;name d2m
;purpose: the inverse function of doy, return the julday 
;modify history
;2017.6.20
temp=anytim(strcompress(string(year))+'01/01 00:00:00',/mjd)
temp.mjd+=(fix(doy)-1)
temp.time+=(doy-fix(doy))*86400000.D
result=anytim(temp,/utc_ext)
return,julday(result.month,result.day,result.year,result.hour,result.minute,result.second)
end
