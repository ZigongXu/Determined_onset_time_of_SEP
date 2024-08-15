pro quicklook_STB_electron,event_num,STBelectron_data=STBelectron_data,STBelectron_jul=STBelectron_jul,Eruption_time=Eruption_time,Start_day=Start_day,end_day=end_day,$
    data_dir=data_dir,result_dir=result_dir,energy_channel=energy_channel,smooth_num=smooth_num
	;Name: subsoho_proton_draw
	;Purpose: sub function of version_1 widget
  ;explanation
	;modification history
  ;
	;2017.9.22, xuzigong
  ;2017.9.24 first version, only the high energy channel involverd

;
;
  ;help,start_day
  restore,'/Users/zigongxu/Documents/work/myWork2_GCS_releasetime/code/common/constant_define.sav'
  if not keyword_set(data_dir) then data_dir='/Users/zigongxu/Documents/work/myWork2_GCS_releasetime/data/'  
  if not keyword_set(result_dir) then result_dir='/Users/zigongxu/Documents/work/myWork2_GCS_releasetime/result/'

  ;travel_time=IMF_length/velocity ; in second 
  ;print,end_day
  ;print,smooth_num
  ;smooth_num=long(smooth_num)
  print,'----',smooth_num
  help,smooth_num
  if (doy(end_day)-doy(start_day) ge 1)then multi_day= 1 else multi_day=0

  if not keyword_set(energy_channel) then begin
    print,'I need energy channel'
    energy_channel=[1,1,1,1,1,1,1,1,1,1,1,1,1,1]
  endif
  dummy=label_date(date_format='%H:%I')
  doy_name=doy(strmid(event_num[0],0,4)+'-'+strmid(event_num[0],4,2)+'-'+strmid(event_num[0],6,2)); data type :int
  str_doy_name=strtrim(doy_name,2); remove all blank space
  

if not keyword_set(STBelectron_data) then begin

 fmt_sept='D,x,x,x,x,x,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f'
 if keyword_set(multi_day) then begin
   electron_STB_name=file_search(data_dir+event_num+'/particle','sept_behind*1min*.dat')
   readcol,electron_STB_name[0],format=fmt_sept,eleB_jul,STBE1,STBE2,STBE3,STBE4,STBE5,STBE6,STBE7,STBE8,STBE9,STBE10,STBE11,STBE12,STBE13,STBE14,STBE15,/silent
   STB_E=[transpose(temporary(STBE1)),transpose(temporary(STBE2)),transpose(temporary(STBE3)),transpose(temporary(STBE4)),transpose(temporary(STBE5)),transpose(temporary(STBE6)),transpose(temporary(STBE7)),transpose(temporary(STBE8)),transpose(temporary(STBE9)),$
     transpose(temporary(STBE10)),transpose(temporary(STBE11)),transpose(temporary(STBE12)),transpose(temporary(STBE13)),transpose(temporary(STBE14)),transpose(temporary(STBE15))]
   for i =1,N_elements(electron_STB_name)-1 do begin
     readcol,electron_STB_name[i],format=fmt_sept,eleB_jul_1,STBE1,STBE2,STBE3,STBE4,STBE5,STBE6,STBE7,STBE8,STBE9,STBE10,STBE11,STBE12,STBE13,STBE14,STBE15,/silent
     STB_E_1=[transpose(temporary(STBE1)),transpose(temporary(STBE2)),transpose(temporary(STBE3)),transpose(temporary(STBE4)),transpose(temporary(STBE5)),transpose(temporary(STBE6)),transpose(temporary(STBE7)),transpose(temporary(STBE8)),transpose(temporary(STBE9)),$
       transpose(temporary(STBE10)),transpose(temporary(STBE11)),transpose(temporary(STBE12)),transpose(temporary(STBE13)),transpose(temporary(STBE14)),transpose(temporary(STBE15))]
     STB_E=[[STB_E],[STB_E_1]]
     eleB_jul=[eleB_jul,eleB_jul_1]
   endfor
 endif else begin 
  electron_STB_name=file_search(data_dir+event_num+'/particle','sept_behind*'+str_doy_name+'*1min*.dat')
  readcol,electron_STB_name[0],format=fmt_sept,eleB_jul,STBE1,STBE2,STBE3,STBE4,STBE5,STBE6,STBE7,STBE8,STBE9,STBE10,STBE11,STBE12,STBE13,STBE14,STBE15,/silent
  STB_E=[transpose(temporary(STBE1)),transpose(temporary(STBE2)),transpose(temporary(STBE3)),transpose(temporary(STBE4)),transpose(temporary(STBE5)),transpose(temporary(STBE6)),transpose(temporary(STBE7)),transpose(temporary(STBE8)),transpose(temporary(STBE9)),$
    transpose(temporary(STBE10)),transpose(temporary(STBE11)),transpose(temporary(STBE12)),transpose(temporary(STBE13)),transpose(temporary(STBE14)),transpose(temporary(STBE15))]
  endelse 

  STB_E[where(STB_E lt 1e-10)] = !values.F_nan
  STBelectron_data=STB_E
  STBelectron_jul = eleB_jul

endif else begin
     
  STB_E = STBelectron_data
  eleB_jul = STBelectron_jul
  STB_E[where(STB_E lt 1e-10)] = !values.F_nan

endelse
;help,STBproton_data
;---------------------
yrange=[10.^(floor(alog10(max_except(STB_E,except_range_small=1e-10,/min,/nan)))),10.^(ceil(alog10(max(STB_E,/nan))))]
cgplot,eleB_jul,STB_E[0,*],/nodata,xstyle=1,ystyle=1,xtickformat='label_date',/ylog,yrange=yrange,title='STB electron',$
  xrange=[any2jul(Start_day),any2jul(end_day)],xtitle='time(Start from'+Start_day+')',charsize=0.8
temp = where(energy_channel eq 1)
if temp[0] ne -1 then begin
    foreach i,where(energy_channel eq 1) do begin
      cgplot,eleB_jul,smooth(STB_E[i,*],smooth_num,/nan,/edge_truncate),/over,color=mycolor1[i],symsize =0.1,psym =1
    endforeach
endif
vline,any2jul(eruption_time),linestyle=1,color='black'
end
