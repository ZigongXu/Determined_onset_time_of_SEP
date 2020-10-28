
;NAME : ms2jul

;PURPOSE: this function returns the julday data using in plot of a data given in the form month,day,year,ms in days

;INput: month,day,year,ms

;MODIFICATION HISTORY:
; 2017.6.3  created xuzigong
Function ms2jul,month,day,year,ms

second=(ms mod 60000)/1000D ; in second
minute=fix(ms/60000) mod 60 ; in mimute
hour=fix(ms/3600000)     ; in houe
return,julday(month,day,year,hour,minute,second)
end