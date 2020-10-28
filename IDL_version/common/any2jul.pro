function any2jul,anytime,_extra=extra

;name: any2jul
;purpose: function used to convert from any to julday; the inverse function of jul2any
;modification history
;xuzigong 2017.6.25 18:50

result=anytim(anytime,/utc_ext)
return,julday(result.month,result.day,result.year,result.hour,result.minute,result.second+result.millisecond/1000D)
end
