;name: analysis_5
;purpose: STEREO A/B proton analysis
;
;parameter explanation:
;         STAB_data_day_range=[], if /multi_day exists, there should be STAB_data_day_range to pick the original STEREO A/B high energy proton data 
;
;
;Modification history:
;
;2017.6.29  add the data validation check
;           add the check of existence of STB_let_onset_time
;2017.7.6   add keyword STAB_data_day_range,see explanation before
;            change the year of STA/B HET,{STB_HET_jul=julday(strmid(event_num,4,2),day[area],strmid(event_num,0,4),strmid(time[area],0,2),strmid(time[area],2,2))}

  
  
pro analysis_4,event_num,xrange=xrange,$
  background_xrange=background_xrange,eruption_time=eruption_time,$
  STA_low_yrange=STA_low_yrange,STB_Low_yrange=STB_low_yrange,STA_high_yrange,STB_high_yrange,$
  IMF_length=IMF_length,STA_fitting_range=STA_fitting_range,STB_fitting_range=STB_fitting_range,$
  Point_num_onset=Point_num_onset,smooth_num=smooth_num,$
  STA_fit_plot_yrange=STA_fit_plot_yrange,STA_fit_plot_xrange=STA_fit_plot_xrange,STB_fit_plot_yrange=STB_fit_plot_yrange,STB_fit_plot_xrange=STB_fit_plot_xrange,$
  result_dir=result_dir,data_dir=data_dir,multi_day=multi_day,STAB_data_day_range=STAB_data_day_range
  
  restore,'/Users/zigongxu/Documents/work/myWork2_GCS_releasetime/code/common/constant_define.sav'

  if not keyword_set(STA_low_yrange) then STA_low_yrange=[1e-5,1e3]
  if not keyword_set(STB_Low_yrange) then STB_low_yrange=[5e-5,5e4]
  if not keyword_set(STA_high_yrange) then STA_high_yrange=[1e-4,1e2]
  if not keyword_set(STB_high_yrange) then STB_high_yrange=[1e-4,1e2]
  
  let_velocity=calculate_velocity(E_let,unit='MeV',particle='proton',light_speed=let_beta)  
  Het_velocity=calculate_velocity(E_het,unit='mev',particle='proton',light_speed=het_beta)
  if not keyword_set(IMF_length) then begin
    IMF_length=1.2 *Au
    print,'you should offer the real IMF length calculated from solar wind speed'
  endif
  let_travel_time=IMF_length/let_velocity
  het_travel_time=IMF_length/het_velocity
  
  if not keyword_set(Point_num_onset) then point_num_onset=20
  ;if not keyword_set(STA_fitting_range) then STA_fitting_range=[0,1,2,4,6,8,10,12,14]
  ;if not keyword_set(STB_fitting_range) then STB_fitting_range=[0,1,2,3,4,6,8,10,12,14]
  if not keyword_set(smooth_num) then smooth_num=1
  if not keyword_set(STB_fit_plot_yrange) then STB_fit_plot_yrange=[]
  if not keyword_set(STB_fit_plot_xrange) then STB_fit_plot_xrange=[]
  if not keyword_set(STA_fit_plot_yrange) then STA_fit_plot_yrange=[]
  if not keyword_set(STA_fit_plot_xrange) then STA_fit_plot_xrange=[]
  if not keyword_set(data_dir) then data_dir='/Users/zigongxu/Documents/work/myWork2_GCS_releasetime/data/'
  if not keyword_set(result_dir) then result_dir='/Users/zigongxu/Documents/work/myWork2_GCS_releasetime/result/'

  STEREO_high_proton_partof_filename=strmid(event_num,2,2)+STAB_proton_name[fix((strmid(event_num,4,2)))-1]
  doy_name=doy(strmid(event_num,0,4)+'-'+strmid(event_num,4,2)+'-'+strmid(event_num,6,2)); data type :int
  str_doy_name=strtrim(doy_name,2); remove all blank space
  data_dir='/Users/zigongxu/Documents/work/myWork2_GCS_releasetime/data/'
  
  dummy=label_date(date_format='%H:%I')
 ; cgdisplay,1200,800,wid=5
  ;set_plot,'ps'
  ;device,filename='/Users/zigongxu/Documents/work/myWork2_GCS_releasetime/image/20110308/20110307_08.eps',/portrait,yoffset=1,/inch,xsize=7,ysize=8
 ; !p.multi=[2,2,1]
  

STA_LET_onset_time=make_array(4,/double)
STA_let_release_time=make_array(4,/double)

fmt_LET='f,f,x,x,x,x,x,f,f,f,f'
if keyword_set(multi_day) then begin
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
  readcol,proton_STA_name_low[0],format=fmt_let,year,day,PLET1,PLET2,PLET3,PLET4,/silent
endelse

if not keyword_set(STA_fitting_range) then begin
  print,'you should offer the fitting range of STEREO A proton'
  STA_fitting_range=bindgen(15)
endif

if (PLET1 ne !NULL) then begin
  lackof_STALET=0
  STA_LET=[transpose(temporary(PLET1)),transpose(temporary(PLET2)),transpose(temporary(PLET3)),transpose(temporary(PLET4))]
  STA_let_jul=doy2jul(year,day) 
  for i =0,3 do begin
    flux=smooth(STA_let[i,*],smooth_num,/nan,/edge_truncate)
    STA_let_onset_time[i]=find_onset_time(STA_let_jul,flux,background=background_xrange,position=pos,time=Point_num_onset,color=mycolor1[i])
    STA_let_release_time[i]=STA_let_onset_time[i]-let_travel_time[i]/86400D + 8.33/1440D
  endfor
  if STA_fitting_range[0] eq 100 then goto,No_enhancement_A_1
  cgplot,sta_let_jul,sta_let[0,*],/nodata,xstyle=1,ystyle=1,xtickformat='label_date',/ylog,yrange=STA_low_yrange,title='STA energetic proton',xrange=xrange
  check=where(STA_fitting_range lt 4)
  foreach i,STA_fitting_range[where(STA_fitting_range lt 4)] do begin
    if check[0] eq -1 then break
    flux=smooth(STA_let[i,*],smooth_num,/nan,/edge_truncate)
    cgplot,STA_let_jul,flux,/over,color=mycolor1[i],psym=1,symsize=0.1,/noerase
    xxxxxxx=find_onset_time(STA_let_jul,flux,background=background_xrange,position=pos,time=Point_num_onset,color=mycolor1[i],/pline)
    vline,STA_let_onset_time[i],linestyle=2,color=mycolor1[i]
    cgplots,STA_let_onset_time[i],flux[pos],psym=6,color=mycolor1[i],symsize=1.5,thick=1.2
    print,jul2any(STA_let_onset_time[i],/ccsds)
  endforeach
  
endif else begin
  lackof_STALET=1
  print,'STEREO A low energy proton data missed'
endelse
;STA high P
No_enhancement_A_1:

if not file_test(data_dir+event_num+'/processed_STA_HET.sav') then begin
  ;2017.6.29 maybe this line will be improved latter
    proton_STA_name_high=file_search(data_dir+event_num+'/particle','AeH'+STEREO_high_proton_partof_filename+'.1m')
    fmt_HET='x,x,x,f,a,x,x,x,x,x,x,d,x,d,x,d,x,d,x,d,x,d,x,d,x,d,x,d,x,d,x,d,x'
    readcol,proton_STA_name_high[0],format=fmt_HET,day,time,P1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,/silent
    save,filename=data_dir+event_num+'/processed_STA_HET.sav',day,time,p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11
endif
restore,data_dir+event_num+'/processed_STA_HET.sav'
;---
if keyword_set(multi_day) then begin
  ;  only valid to the same month data
  if not keyword_set(STAB_data_day_range) then area=where(day le strmid(event_num,6,2) and day ge double(strmid(event_num,6,2))-1) else area=where(day le STAB_data_day_range[1] and day ge STAB_data_day_range[0])
 ; area=where(day le strmid(event_num,6,2) and day ge double(strmid(event_num,6,2))-1)
endif else begin
  area=where(day eq strmid(event_num,6,2))
endelse
STA_HET_jul=julday(strmid(event_num,4,2),day[area],strmid(event_num,0,4),strmid(time[area],0,2),strmid(time[area],2,2))

;---
STA_HET=[transpose(temporary(p1[area])),transpose(temporary(p2[area])),transpose(temporary(p3[area])),transpose(temporary(p4[area])),transpose(temporary(p5[area])),transpose(temporary(p6[area])),transpose(temporary(p7[area])),transpose(temporary(p8[area])),transpose(temporary(p9[area])),transpose(temporary(p10[area])),transpose(temporary(p11[area]))]
STA_het_onset_time=make_array(11,/double)
STA_het_release_time=make_array(11,/double) 

for i=0,10 do begin
  flux=smooth(STA_het[i,*],smooth_num,/nan,/edge_truncate)
  STA_het_onset_time[i]=find_onset_time(STA_het_jul,flux,background=background_xrange,position=pos,time=Point_num_onset,color=mycolor2[i-4])
  STA_het_release_time[i]=STA_het_onset_time[i]-het_travel_time[i]/86400D + 8.33/1440D
endfor



if STA_fitting_range[0] eq 100 then goto,No_enhancement_A_2

if lackof_STALET then cgplot,STA_HET_jul,STA_HET[0,*],xtickformat='label_date',/ylog,xstyle=1,ystyle=1,xrange=xrange,title='STA high energy proton',yrange=STA_high_yrange,/nodata
check=where(STA_fitting_range ge 4)
foreach i,STA_fitting_range[where(STA_fitting_range ge 4)]-4 do begin
  if check[0] eq -1 then break
  flux=smooth(STA_het[i,*],smooth_num,/nan,/edge_truncate)
  cgplot,STA_HET_jul,flux,color=mycolor2[i-4],psym=1,symsize=0.1,/over
  xxxxxx=find_onset_time(STA_het_jul,flux,background=background_xrange,position=pos,time=Point_num_onset,color=mycolor2[i-4],/pline)
  vline,sta_het_onset_time[i],linestyle=2,color=mycolor2[i-4]
  cgplots,sta_het_onset_time[i],flux[pos],psym=6,symsize=1.5,thick=2,color=mycolor2[i-4]
  print,jul2any(STA_het_onset_time[i],/ccsds)
endforeach
vline,eruption_time,linestyle=2
;----
if (STA_let_onset_time ne !NULL) then begin
  beta=[let_beta,het_beta]  ;you can modify the energy range you used to fit release time
  STA_onset_time=[STA_let_onset_time,STA_het_onset_time]
endif else begin
  beta=[het_beta]
  STA_onset_time=[STA_het_onset_time]
endelse

x=1/beta[STA_fitting_range]
y=(STA_onset_time[STA_fitting_range]-eruption_time)*86400D/60. ;in minute
cgplot,x,y,psym=2,color='red',yrange=STA_fit_plot_yrange
if n_elements(STA_fitting_range) ge 2 then begin
  result=linfit(x,y,measure_errors=SQRT(ABS(Y)),sigma=error)
  length_VDA=result[1]*light_speed*60/AU
  tempx=findgen(100)/100.*(15)
  cgplot,tempx,result[0]+result[1]*tempx,/over,color='green'
  r_from_VDA=jul2any(eruption_time+result[0]/1440D +8.33/1440D,/ccsds)
  cgtext,0.8,0.25,string(length_vda,format='(F-8.4)')+' AU',color='green',/normal
  cgtext,0.8,0.2,r_from_vda,color='green',/normal
endif
;will put this part in a individual procedure 
;---
No_enhancement_A_2:
openw,lun,result_dir+event_num+'/result4.dat',/get_lun,width=400;,/append

;skip_lun,lun,12,/lines
printf,lun,'-----------------------'
printf,lun,' STA high and low energy result from TSA and VDA(date: '+event_num+');Updata in '+systim()
printf,lun,'Energy(MeV)','Onset_time','travel time(Sec=1.2Au/V)','Release time(+8.3 min)','quality',format='(4A-25,A-20)'

for i=0,3 do begin
  if where(STA_fitting_range eq i) ne -1 then begin 
  printf,lun,E_let[i],jul2any(sta_let_onset_time[i],/ccsds),let_travel_time[i],jul2any(STA_let_release_time[i],/ccsds),1,format='(F-25.4,A-25,F-25.4,A-25,I-20)'
  endif else begin
  printf,lun,E_let[i],jul2any(sta_let_onset_time[i],/ccsds),let_travel_time[i],jul2any(STA_let_release_time[i],/ccsds),0,format='(F-25.4,A-25,F-25.4,A-25,I-20)'
  endelse
endfor

for i =0,10 do begin 
  if where(STA_fitting_range eq i+4) ne -1 then begin
  printf,lun,E_het[i],jul2any(sta_het_onset_time[i],/ccsds),het_travel_time[i],jul2any(STA_het_release_time[i],/ccsds),1,format='(F-25.4,A-25,F-25.4,A-25,I-20)'
  endif else begin
  printf,lun,E_het[i],jul2any(sta_het_onset_time[i],/ccsds),het_travel_time[i],jul2any(STA_het_release_time[i],/ccsds),0,format='(F-25.4,A-25,F-25.4,A-25,I-20)'
  endelse
endfor  
if STA_fitting_range[0] eq 100 or N_elements(STA_fitting_range) eq 1 then error=[0,0] &r_from_VDA=0 &length_VDA=0
slope=error[1]*light_speed*60/AU
printf,lun,'result from linfit_VDA:',r_from_VDA,'; length=',length_VDA,'Au (',error[0],slope,')',format='(A-35,2A,F-8.4,A,F-8.3,"min",F-8.3,"AU",A)'
free_lun,lun

print,'--------------------------'
cgdisplay,wid=6,1200,800
;STB Low p
STB_LET_onset_time=make_array(4,/double)
STB_let_release_time=make_array(4,/double)
fmt_LET='f,f,x,x,x,x,x,f,f,f,f'
if keyword_set(multi_day) then begin
  proton_STB_name_low=file_search(data_dir+event_num+'/particle','H*behind*.txt')
  readcol,proton_STB_name_low[0],format=fmt_let,year,day,PLET1,PLET2,PLET3,PLET4,/silent
  for  i=1,n_elements(proton_STB_name_low)-1 do begin
    readcol,proton_STB_name_low[i],format=fmt_let,year1,day1,PLET11,PLET21,PLET31,PLET41,/silent
    year=[year,year1]
    day=[day,day1]
    PLET1=[PLET1,PLET11]
    PLET2=[PLET2,PLET21]
    PLET3=[PLET3,PLET31]
    PLET4=[PLET4,PLET41]
  endfor
endif else begin
  proton_STB_name_low=file_search(data_dir+event_num+'/particle','H*behind*'+str_doy_name+'*.txt')
  readcol,proton_STB_name_low[0],format=fmt_let,year,day,PLET1,PLET2,PLET3,PLET4,/silent
endelse


if not keyword_set(STB_fitting_range) then begin
  print,'you should offer the fitting range of STEREO B proton'
  STB_fitting_range=bindgen(15)
endif

if (PLET1 ne !NULL) then begin
lackof_STBLET=0
STB_LET=[transpose(temporary(PLET1)),transpose(temporary(PLET2)),transpose(temporary(PLET3)),transpose(temporary(PLET4))]
STB_let_jul=doy2jul(year,day)

for i =0,3 do begin
  flux=smooth(STB_let[i,*],smooth_num,/nan,/edge_truncate)
  STB_let_onset_time[i]=find_onset_time(STB_let_jul,flux,background=background_xrange,position=pos,time=Point_num_onset,color=mycolor1[i])
  STB_let_release_time[i]=STB_let_onset_time[i]-let_travel_time[i]/86400D + 8.33/1440D
endfor

if STB_fitting_range[0] eq 100 then goto, No_enhancement_B_1
;
cgplot,stB_let_jul,stB_let[0,*],/nodata,xstyle=1,ystyle=1,xtickformat='label_date',/ylog,yrange=STB_low_yrange,title='STB energetic proton',xrange=xrange
check=where(STB_fitting_range lt 4)
foreach i,STB_fitting_range[where(STB_fitting_range lt 4)] do begin
  if check[0] eq -1 then break
  flux=smooth(STB_let[i,*],smooth_num,/nan,/edge_truncate)
  cgplot,STB_let_jul,flux,/over,color=mycolor1[i],psym=1,symsize=0.1,/noerase
  xxxxx=find_onset_time(STB_let_jul,flux,background=background_xrange,position=pos,time=Point_num_onset,color=mycolor1[i],/pline)
  vline,STB_let_onset_time[i],linestyle=2,color=mycolor1[i]
  cgplots,STB_let_onset_time[i],flux[pos],psym=6,color=mycolor1[i],symsize=1.5,thick=1.2
  print,jul2any(STB_let_onset_time[i],/ccsds)
endforeach
endif else begin
  lackof_STBLET=1
  print,'STEREO B low energy proton data missed'
endelse
;-
;
;STB high P
No_enhancement_B_1:

if not file_test(data_dir+event_num+'/processed_STB_HET.sav') then begin
  proton_STB_name_high=file_search(data_dir+event_num+'/particle','BeH'+STEREO_high_proton_partof_filename+'.1m')
  fmt_HET='x,x,x,f,a,x,x,x,x,x,x,d,x,d,x,d,x,d,x,d,x,d,x,d,x,d,x,d,x,d,x,d,x'
  readcol,proton_STB_name_high[0],format=fmt_HET,day,time,P1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,/silent
  save,filename=data_dir+event_num+'/processed_STB_HET.sav',day,time,p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11
endif

restore,data_dir+event_num+'/processed_STB_HET.sav'

if keyword_set(multi_day) then begin
  if not keyword_set(STAB_data_day_range) then area=where(day le strmid(event_num,6,2) and day ge double(strmid(event_num,6,2))-1) else area=where(day le STAB_data_day_range[1] and day ge STAB_data_day_range[0]) 
endif else begin 
  area=where(day eq strmid(event_num,6,2))
endelse

STB_HET_jul=julday(strmid(event_num,4,2),day[area],strmid(event_num,0,4),strmid(time[area],0,2),strmid(time[area],2,2))

STB_HET=[transpose(temporary(p1[area])),transpose(temporary(p2[area])),transpose(temporary(p3[area])),transpose(temporary(p4[area])),transpose(temporary(p5[area])),transpose(temporary(p6[area])),$
  transpose(temporary(p7[area])),transpose(temporary(p8[area])),transpose(temporary(p9[area])),transpose(temporary(p10[area])),transpose(temporary(p11[area]))]
STB_het_onset_time=make_array(11,/double)
STB_het_release_time=make_array(11,/double) 
 
for i=0,10 do begin
  flux=smooth(STB_het[i,*],smooth_num,/nan,/edge_truncate)
  STB_het_onset_time[i]=find_onset_time(STB_het_jul,flux,background=background_xrange,position=pos,time=Point_num_onset,color=mycolor2[i-4])
  STB_het_release_time[i]=STB_het_onset_time[i]-het_travel_time[i]/86400D + 8.33/1440D
endfor

if STB_fitting_range[0] eq 100 then goto,No_enhancement_B_2

if lackof_STBLET then cgplot,STB_HET_jul,STB_HET[0,*],xtickformat='label_date',/ylog,xstyle=1,ystyle=1,xrange=xrange,title='STB high energy proton',/nodata,yrange=STB_high_yrange
check=where(STB_fitting_range ge 4)
foreach i,STB_fitting_range[where(STB_fitting_range ge 4)]-4 do begin
  if check[0] eq '-1' then break
  flux=smooth(STB_het[i,*],smooth_num,/nan,/edge_truncate)
  cgplot,STB_HET_jul,flux,color=mycolor2[i-4],psym=1,symsize=0.1,/over
  xxxxxx=find_onset_time(STB_het_jul,flux,background=background_xrange,position=pos,time=Point_num_onset,color=mycolor2[i-4],/pline)
  vline,STB_het_onset_time[i],linestyle=2,color=mycolor2[i-4]
  cgplots,STB_het_onset_time[i],flux[pos],psym=6,symsize=1.5,thick=2,color=mycolor2[i-4]
  print,jul2any(STB_het_onset_time[i],/ccsds)
endforeach
vline,eruption_time,linestyle=2
;----
if (STB_let_onset_time ne !NULL) then begin
  beta=[let_beta,het_beta]  ;you can modify the energy range you used to fit release time
  STB_onset_time=[STB_let_onset_time,STB_het_onset_time] 
endif else begin
  beta=[het_beta]
  STB_onset_time=[STB_het_onset_time]
endelse

x=1/beta[STB_fitting_range]
y=(STB_onset_time[STB_fitting_range]-eruption_time)*86400D/60. ;in minute
cgplot,x,y,psym=2,color='red',yrange=STB_fit_plot_yrange,xrange=STB_fit_plot_xrange
if N_elements(STB_fitting_range) ge 2 then begin
result=linfit(x,y,measure_errors=SQRT(ABS(Y)),sigma=error)
length_VDA=result[1]*light_speed*60/AU
tempx=findgen(100)/100.*(10)
cgplot,tempx,result[0]+result[1]*tempx,/over,color='green'
r_from_VDA=jul2any(eruption_time+result[0]/1440D +8.33/1440D,/ccsds)
cgtext,0.8,0.25,string(length_vda,format='(F-8.4)')+' AU',color='black',/normal
cgtext,0.8,0.2,r_from_vda,color='black',/normal
endif

No_enhancement_B_2:

openu,lun,result_dir+event_num+'/result4.dat',/get_lun,width=400,/append
printf,lun,'-----------------------'
printf,lun,' STB high and low energy proton data result from TSA and VDA(date: '+event_num+');Updata in '+systim()
printf,lun,'Energy(MeV)','Onset_time','travel time(Sec=1.2Au/V)','Release time(+8.3 min)','quality',format='(4A-25,A-20)'

for i=0,3 do begin
  if where(STB_fitting_range eq i) ne -1 then begin
  printf,lun,E_let[i],jul2any(STB_let_onset_time[i],/ccsds),let_travel_time[i],jul2any(STB_let_release_time[i],/ccsds),1,format='(F-25.4,A-25,F-25.4,A-25,I-20)'
  endif else begin
  printf,lun,E_let[i],jul2any(STB_let_onset_time[i],/ccsds),let_travel_time[i],jul2any(STB_let_release_time[i],/ccsds),0,format='(F-25.4,A-25,F-25.4,A-25,I-20)'
  endelse
endfor
for i =0,10 do begin
  if where(STB_fitting_range eq i+4) ne -1 then begin
  printf,lun,E_het[i],jul2any(STB_het_onset_time[i],/ccsds),het_travel_time[i],jul2any(STB_het_release_time[i],/ccsds),1,format='(F-25.4,A-25,F-25.4,A-25,I-20)'
  endif else begin
  printf,lun,E_het[i],jul2any(STB_het_onset_time[i],/ccsds),het_travel_time[i],jul2any(STB_het_release_time[i],/ccsds),0,format='(F-25.4,A-25,F-25.4,A-25,I-20)'
  endelse
endfor
if STB_fitting_range[0] eq 100 or N_elements(STB_fitting_range) eq 1 then error=[0,0] &r_from_VDA=0 & length_VDA=0
slope=error[1]*light_speed*60/AU
printf,lun,'result from linfit_VDA:',r_from_VDA,'; length=',length_VDA,'Au (',error[0],slope,')',format='(A-25,2A,F-8.4,A,F-7.3,"min",F-7.3,"AU",A)'
free_lun,lun

end
