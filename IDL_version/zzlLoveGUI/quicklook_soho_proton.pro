pro quicklook_soho_proton,event_num,soho_data=soho_data,soho_jul=soho_jul,Eruption_time=Eruption_time,start_day=start_day,end_day=end_day,$
    data_dir=data_dir,result_dir=result_dir,energy_channel=energy_channel
	;Name: subsoho_proton_draw
	;Purpose: sub function of version_1 widget
  ;explanation
	;modification history
  ;
	;2017.9.22, xuzigong
  ;2017.9.24 first version, only the high energy channel involverd
  ;2017.10.19  if the data are given, so, we just use it directly rather than read it from file repeatly
;
;
  restore,'/Users/zigongxu/Documents/work/myWork2_GCS_releasetime/code/common/constant_define.sav'
  if not keyword_set(data_dir) then data_dir='/Users/zigongxu/Documents/work/myWork2_GCS_releasetime/data/'  
  if not keyword_set(result_dir) then result_dir='/Users/zigongxu/Documents/work/myWork2_GCS_releasetime/result/'
    
  velocity=calculate_velocity(P_soho_high,unit='MeV',particle='proton',light_speed=beta) 
  if (doy(end_day)-doy(start_day) ge 1)then multi_day= 1 else multi_day=0
  if not keyword_set(energy_channel) then begin
    print,'I need energy channel'
    energy_channel=[1,1,1,1,1,1,1,1,1,1]
  endif

  dummy=label_date(date_format='%H:%I')
  doy_name=doy(strmid(event_num,0,4)+'-'+strmid(event_num,4,2)+'-'+strmid(event_num,6,2)); data type :int
  str_doy_name=strtrim(doy_name,2); remove all blank space

;high energy 

if not keyword_set(soho_data) then begin
  if multi_day then begin
    proton_h1_name=file_search(data_dir+event_num+'/particle','HED*.SL2')
  endif else begin
    proton_h1_name=file_search(data_dir+event_num+'/particle','HED*'+str_doy_name+'.SL2')
  endelse
  fmt='f,f,f,x,f,f,f,f,f,f,f,f,f,f'
  if multi_day then begin 
    readcol,proton_h1_name[0],format=fmt,year,day,Htime,PH1,PH2,Ph3,PH4,PH5,PH6,PH7,PH8,PH9,PH10,/silent
    P_soho=[transpose(temporary(PH1)),transpose(temporary(PH2)),transpose(temporary(PH3)),transpose(temporary(PH4)),transpose(temporary(PH5)),transpose(temporary(PH6)),transpose(temporary(PH7)),$
      transpose(temporary(PH8)),transpose(temporary(PH9)),transpose(temporary(PH10))]
    SOHO_Htime_jul=doy2jul(year,day+htime/86400000D)
    for i =1,n_elements(proton_h1_name)-1 do begin
      readcol,proton_h1_name[i],format=fmt,year,day,Htime,PH1,PH2,Ph3,PH4,PH5,PH6,PH7,PH8,PH9,PH10,/silent
      P_soho1=[transpose(temporary(PH1)),transpose(temporary(PH2)),transpose(temporary(PH3)),transpose(temporary(PH4)),transpose(temporary(PH5)),transpose(temporary(PH6)),transpose(temporary(PH7)),$
        transpose(temporary(PH8)),transpose(temporary(PH9)),transpose(temporary(PH10))]
      SOHO_Htime_jul1=doy2jul(year,day+htime/86400000D)
      P_soho=[[P_soho],[P_soho1]]
      SOHO_Htime_jul=[SOHO_Htime_jul,SOHO_Htime_jul1]
    endfor
  endif else begin
    readcol,proton_h1_name[0],format=fmt,year,day,Htime,PH1,PH2,Ph3,PH4,PH5,PH6,PH7,PH8,PH9,PH10,/silent
    P_soho=[transpose(temporary(PH1)),transpose(temporary(PH2)),transpose(temporary(PH3)),transpose(temporary(PH4)),transpose(temporary(PH5)),transpose(temporary(PH6)),transpose(temporary(PH7)),$
      transpose(temporary(PH8)),transpose(temporary(PH9)),transpose(temporary(PH10))]
    SOHO_Htime_jul=doy2jul(year,day+htime/86400000D)
  endelse

soho_data=P_soho
;help,soho_data
soho_jul=SOHO_Htime_jul
endif  else begin
p_soho = soho_data
soho_Htime_jul = soho_jul

endelse
;if keyword_set(extract_data) then return
;yrange=[10.^(floor(alog10(max_except(soho_data,except_range_small=1e-10,/min,/nan)))),10.^(ceil(alog10(max(soho_data))))]
;print,(floor(alog10(max_except(soho_data,except_range_small=1e-10,/min,/nan))))
;print,yrange
cgplot,soho_Htime_jul,p_soho[0,*],xstyle=1,ystyle=1,yrange=[10.^(floor(alog10(max_except(soho_data,except_range_small=1e-10,/min,/nan)))),10.^(ceil(alog10(max(soho_data)))+1)],$
  /ylog,xtickformat='label_date',title='SOHO_proton',xrange=[any2jul(start_day),any2jul(end_day)],xtitle='time(start from'+start_day+')',/nodata,charsize=0.8
print,energy_channel
temp=where(energy_Channel eq 1)
if temp[0] ne -1 then begin
  foreach i,where(energy_channel eq 1) do begin
    cgplot,SOHO_Htime_jul,smooth(P_soho[i,*],10,/nan,/edge_truncate),/over,color=mycolor1[i],symsize=0.1,psym=1
  endforeach
endif
vline,any2jul(eruption_time[0]),linestyle=1,color='black'
end
