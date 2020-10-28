function month2num,month,inverse=inverse
;Name: month2num
;
;Purpose: find the number of one certain month, like 9 is Sep
;
;Modified history:
;2017.10.25  First edit by xuzigong
;
restore,'/Users/zigongxu/Documents/work/myWork2_GCS_releasetime/code/common/constant_define.sav'
month_type_one=['JAN','FEB','MAR','APR','MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC']
month_type_two=strupcase(['January','February','March','April','May','June','July','August','September','October',$
'November','December'])
;print,month
for i =0,11 do begin
	temp=where(strupcase(month) eq month_type_one[i])
	if temp[0] ne -1 then month[temp] = i+1
	temp=where(strupcase(month) eq month_type_two[i])
	if temp[0] ne -1 then month[temp] = i+1

endfor
return,month
end