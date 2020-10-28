function length_of_IMF,wind_speed,latitude=latitude,l_Au=len
;m/s
;according to the equation (4.3) in C.li's PHD paper,we calculate the imf length
;edit by xuzigong 2016/5/12
;modification history
;2017.08.22  latitude should be 0  
;2017.9.26   make latitude as keyword and set default number 0
if not keyword_set(latitude) then latitude = 0
r0=1.49597871D11 ; unit m=1AU
A=14.713D  ;+-0.0941 degree /d
B=-2.396D  ;+-0.188 degree/d
c=-1.787D  ;+-0.253 degree/d
omega=A+B*(sin(latitude))^2+C*(sin(latitude))^4  ;degree/d
;omega=1.7D-4
;omega=omega*!Pi/180.
omega=omega*!Pi/180./86400.            ;rad /s, rotation speed of sun at certain latitude
length=(r0/2.)*sqrt(1+(omega*r0/wind_speed)^2)+$
  (wind_speed/(2.D*omega))*alog((omega*r0/wind_speed)+sqrt(1+$
  (omega*r0/wind_speed)^2))
len=length/r0
return,length
;???
end