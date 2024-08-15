pro quicklook_STA_electron,event_num,STAelectron_data=STAelectron_data,STAelectron_jul=STAelectron_jul,Eruption_time=Eruption_time,STArt_day=STArt_day,end_day=end_day,$
    data_dir=data_dir,result_dir=result_dir,energy_channel=energy_channel,smooth_num=smooth_num
	;Name: subsoho_proton_draw
	;Purpose: sub function of version_1 widget
  ;explanation
	;modification history
  ;
	;2017.10.16, xuzigong
  ;2017.10.16 first version, only the high energy channel involverd
  ;2017.10.19 if data are given, then used it, do not read repeatly
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
  

if not keyword_set(STAelectron_data) then begin
 fmt_sept='D,x,x,x,x,x,f,f,f,f,f,f,f,f,f,f,f,f,f,f,f'
 if keyword_set(multi_day) then begin
   electron_STA_name=file_search(data_dir+event_num+'/particle','sept_ahead*1min*.dat')
   readcol,electron_STA_name[0],format=fmt_sept,eleA_jul,STAE1,STAE2,STAE3,STAE4,STAE5,STAE6,STAE7,STAE8,STAE9,STAE10,STAE11,STAE12,STAE13,STAE14,STAE15,/silent
   STA_E=[transpose(temporary(STAE1)),transpose(temporary(STAE2)),transpose(temporary(STAE3)),transpose(temporary(STAE4)),transpose(temporary(STAE5)),transpose(temporary(STAE6)),transpose(temporary(STAE7)),transpose(temporary(STAE8)),transpose(temporary(STAE9)),$
     transpose(temporary(STAE10)),transpose(temporary(STAE11)),transpose(temporary(STAE12)),transpose(temporary(STAE13)),transpose(temporary(STAE14)),transpose(temporary(STAE15))]
   for i =1,N_elements(electron_STA_name)-1 do begin
     readcol,electron_STA_name[i],format=fmt_sept,eleA_jul_1,STAE1,STAE2,STAE3,STAE4,STAE5,STAE6,STAE7,STAE8,STAE9,STAE10,STAE11,STAE12,STAE13,STAE14,STAE15,/silent
     STA_E_1=[transpose(temporary(STAE1)),transpose(temporary(STAE2)),transpose(temporary(STAE3)),transpose(temporary(STAE4)),transpose(temporary(STAE5)),transpose(temporary(STAE6)),transpose(temporary(STAE7)),transpose(temporary(STAE8)),transpose(temporary(STAE9)),$
       transpose(temporary(STAE10)),transpose(temporary(STAE11)),transpose(temporary(STAE12)),transpose(temporary(STAE13)),transpose(temporary(STAE14)),transpose(temporary(STAE15))]
     STA_E=[[STA_E],[STA_E_1]]
     eleA_jul=[eleA_jul,eleA_jul_1]
   endfor
 endif else begin 
  electron_STA_name=file_search(data_dir+event_num+'/particle','sept_ahead*'+str_doy_name+'*1min*.dat')
  readcol,electron_STA_name[0],format=fmt_sept,eleA_jul,STAE1,STAE2,STAE3,STAE4,STAE5,STAE6,STAE7,STAE8,STAE9,STAE10,STAE11,STAE12,STAE13,STAE14,STAE15,/silent
  STA_E=[transpose(temporary(STAE1)),transpose(temporary(STAE2)),transpose(temporary(STAE3)),transpose(temporary(STAE4)),transpose(temporary(STAE5)),transpose(temporary(STAE6)),transpose(temporary(STAE7)),transpose(temporary(STAE8)),transpose(temporary(STAE9)),$
    transpose(temporary(STAE10)),transpose(temporary(STAE11)),transpose(temporary(STAE12)),transpose(temporary(STAE13)),transpose(temporary(STAE14)),transpose(temporary(STAE15))]
  endelse 

  STA_E[where(STA_E lt 1e-10)] = !values.F_nan
  ;print,STA_E
  STAelectron_data=STA_E
  STAelectron_jul = eleA_jul
  help,sta_e
  help,eleA_jul

endif else begin
;print,STA_E
  STA_E = STAelectron_data
  eleA_jul = STAelectron_jul
  STA_E[where(STA_E lt 1e-10)] = !values.F_nan
endelse
;help,STAproton_data
;---------------------
;print,max_except(STA_E,except_range_small=1e-10,/min,/nan)
;print,sta_e
yrange=[10.^(floor(alog10(max_except(STA_E,except_range_small=1e-10,/min,/nan)))),10.^(ceil(alog10(max(STA_E,/nan))))]
print,yrange
print,jul2any(eleA_jul[1000],/ccsds),eruption_time,any2jul(eruption_time)
cgplot,eleA_jul,STA_E[0,*],/nodata,xstyle=1,ystyle=1,xtickformat='label_date',/ylog,yrange=yrange,title='STA electron',$
  xrange=[any2jul(Start_day),any2jul(end_day)],xtitle='time(Start from'+Start_day+')',charsize=0.8
temp = where(energy_channel eq 1)
if temp[0] ne -1 then begin
    foreach i,where(energy_channel eq 1) do begin
      cgplot,eleA_jul,smooth(STA_E[i,*],smooth_num,/nan,/edge_truncate),/over,color=mycolor1[i],symsize =0.1,psym =1
    endforeach
endif
vline,any2jul(eruption_time),linestyle=1,color='black'
end
