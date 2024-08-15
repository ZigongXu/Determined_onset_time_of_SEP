pro quicklook_STA_proton,event_num,STALET_data=STALET_data,STALET_jul=STALET_jul,$
    STAHET_data=STAHET_data,STAHET_jul = STAHET_jul,$
    Eruption_time=Eruption_time,start_day=start_day,end_day=end_day,$
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
if not keyword_set(STALET_data) then begin
  if not keyword_set(energy_channel) then begin
    print,'I need energy channel'
    energy_channel=[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]
  endif
  dummy=label_date(date_format='%H:%I')
  doy_name=doy(strmid(event_num[0],0,4)+'-'+strmid(event_num[0],4,2)+'-'+strmid(event_num[0],6,2)); data type :int
  str_doy_name=strtrim(doy_name,2); remove all blank space
  fmt_LET='f,f,x,x,x,x,x,f,f,f,f'

  if multi_day then begin
    proton_STA_name_low=file_search(data_dir+event_num+'/particle','H*ahead*.txt')
  
    readcol,proton_STA_name_low[0],format=fmt_let,year,day,PLET1,PLET2,PLET3,PLET4,/silent
    for i =1,N_elements(proton_STA_name_low)-1 do begin
      readcol,proton_STA_name_low[i],format=fmt_let,year1,day1,PLET11,PLET21,PLET31,PLET41,/silent
      year=[year,year1]
      day=[day,day1]
      PLET1=[PLET1,PLET11]
      PLET2=[PLET2,PLET21]
      PLET3=[PLET3,PLET31]
      PLET4=[PLET4,PLET41]
    endfor
  endif else begin
    proton_STA_name_low=file_search(data_dir+event_num+'/particle','H*ahead*'+str_doy_name+'*.txt')
    ;print,proton_STA_name_low
    readcol,proton_STA_name_low[0],format=fmt_let,year,day,PLET1,PLET2,PLET3,PLET4,/silent
  endelse

  STAlet_jul=doy2jul(year,day) 
  STALET_data=[transpose(temporary(PLET1)),transpose(temporary(PLET2)),transpose(temporary(PLET3)),transpose(temporary(PLET4))]

;--------------------

  STEREO_high_proton_partof_filename=strmid(event_num[0],2,2)+STAB_proton_name[fix((strmid(event_num[0],4,2)))-1]
;print,stereo_high_proton_partof_filename
  if not file_test(data_dir+event_num+'/processed_STA_HET.sav') then begin
  ;2017.6.29 maybe this line will be improved latter
      proton_STA_name_high=file_search(data_dir+event_num+'/particle','AeH'+STEREO_high_proton_partof_filename+'.1m')
      fmt_HET='x,f,a,f,a,x,x,x,x,x,x,d,x,d,x,d,x,d,x,d,x,d,x,d,x,d,x,d,x,d,x,d,x'
      readcol,proton_STA_name_high[0],format=fmt_HET,year,month,day,time,P1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,/silent
      jul=julday(month2num(month),day,year,long(strmid(time,0,2)),long(strmid(time,2,2)),0)
      save,filename=data_dir+event_num+'/processed_STA_HET.sav',jul,p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11
      a=dialog_message('remember,if you change the start day and end day,especially extend their range,to remove older sav data.'+$
          'if not you may have troubles')
  endif
  restore,data_dir+event_num+'/processed_STA_HET.sav'
;---

  area=where(jul ge any2jul(start_day[0]) and jul le any2jul(end_day[0]))

  STAHET_jul=jul[area]
  STAHET_data=[transpose(temporary(p1[area])),transpose(temporary(p2[area])),transpose(temporary(p3[area])),transpose(temporary(p4[area])),transpose(temporary(p5[area])),$
    transpose(temporary(p6[area])),transpose(temporary(p7[area])),transpose(temporary(p8[area])),transpose(temporary(p9[area])),transpose(temporary(p10[area])),transpose(temporary(p11[area]))]
endif

STALET_data[where(STALET_data lt 1e-10)] = !values.F_nan
STAHET_data[where(STAHET_data lt 1e-10)] = !values.F_nan

;print,strmid(event_num,4,2),day[area],strmid(event_num,0,4),strmid(time[area],0,2),strmid(time[area],2,2)

;help,STAproton_data
;---------------------
yrange=[10.^(floor(alog10(max_except(STAHET_data,except_range_small=1e-10,/min,/nan)))),10.^(ceil(alog10(max(STALET_data,/nan))))]
cgplot,STALET_jul,STALET_data[0,*],/nodata,xstyle=1,ystyle=1,xtickformat='label_date',/ylog,yrange=yrange,title='STA proton',$
  xrange=[any2jul(start_day),any2jul(end_day)],xtitle='time(start from'+start_day+')',charsize=0.8
temp = where(energy_channel eq 1)
if temp[0] ne -1 then begin
    foreach i,where(energy_channel eq 1) do begin
      if i le 3 then cgplot,STALET_jul,smooth(staLET_data[i,*],smooth_num,/nan,/edge_truncate),/over,color=mycolor1[i],symsize =0.1,psym =1
      if i gt 3 then cgplot,STAHET_jul,smooth(staHET_data[i-4,*],smooth_num,/nan,/edge_truncate),/over,color=mycolor1[i],symsize =0.1,psym =1
    endforeach
endif
vline,any2jul(eruption_time),linestyle=1,color='black'
end
