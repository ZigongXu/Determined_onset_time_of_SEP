


;Name: Analysis_1
;Purpose : WIND electron analysis, for  20110321
;
;Parameter explanation:
;         multi_day: /multi_day, means that the temporary intensity profile can not be described using one day data
;
;Modification history:
;
;2017.6.29 replace common by restore; standardize their output format; add fitting result  in fitting map 
;2017.7.3  add outside door and keyword background_xrange,xrange,eruption_time and many other keywords
;          used as a common procedure
;2017.7.20 10:50 add the choosing procession circularly ; add arrow to indicate the position of eruption time
;2017.7.27  plot in eps

pro analysis_1,event_num,xrange=xrange,$
  background_xrange=background_xrange,eruption_time=eruption_time,$
  IMF_length=IMF_length,wind_yrange=wind_yrange,Point_num_onset=Point_num_onset,fitting_range=fitting_range,$
  smooth_num=smooth_num,$
  fit_plot_yrange=fit_plot_yrange,fit_plot_xrange=fit_plot_xrange,$
  data_dir=data_dir,result_dir=result_dir,multi_day=multi_day
  restore,'/Users/zigongxu/Documents/work/myWork2_GCS_releasetime/code/common/constant_define.sav'
   
  if not keyword_set(wind_yrange) then wind_yrange=[1e-7,1e-1]
  
  if not keyword_set(point_num_onset) then point_num_onset=20
  
  ;if not keyword_set(fitting_range) then fitting_range=bindgen(5)+1
  
  if not keyword_set(smooth_num) then smooth_num=1
  
  if not keyword_set(fit_plot_yrange) then fit_plot_yrange=[]
   
  if not keyword_set(fit_plot_xrange) then fit_plot_xrange=[]
 
  if not keyword_set(data_dir) then data_dir='/Users/zigongxu/Documents/work/myWork2_GCS_releasetime/data/'
  
  if not keyword_set(result_dir) then result_dir='/Users/zigongxu/Documents/work/myWork2_GCS_releasetime/result/'
  
  

  dummy=label_date(date_format='%H:%I')
  ;set_plot,'x'
  ;cgdisplay,1200,800,wid=1,retain=2
 ; data_dir='/Users/zigongxu/Documents/work/myWork2_GCS_releasetime/data/'
if keyword_set(multi_day) then begin
  electron_l1_name=file_search(data_dir+event_num+'/particle','wi_sfsp*.cdf')
endif else begin 
  electron_L1_name=file_search(data_dir+event_num+'/particle','wi_sfsp*'+event_num+'*.cdf');/wi_sfsp_3dp_20110307_v01.cdf'
endelse
;- wind e
id = CDF_OPEN(electron_l1_name[0])
inq = CDF_inquire(id)
nvars=inq.nvars
nzvars=inq.nzvars
maxrec=inq.maxrec
var1=CDF_varinq(id,0); data_type='CDF_EPOCH'
name_var1=var1.NAME
CDF_varget,id,name_var1,Epoch,rec_count=maxrec; in CDF_Epoch type
;CDF_varget1,id,name_var1,Epoch  ; CDF_varget1 get only one data
Epoch_jul=CDF_EPOCH_TOJULDAYS(Epoch); In Julday for plot
;Epoch_str=CDF_ENCODE_EPOCH(Epoch)
;Result = CDF_VARNUM( Id, VarName [, IsZVar] ) :find the num of VarName
var2=CDF_varinq(id,0,/zvariable)
name_var2=var2.NAME
var3=CDF_varinq(id,1,/zvariable)
name_var3=var3.NAME
Var4=CDF_varinq(id,2,/zvariable)
name_var4=var4.NAME
;dummy=label_date(date_format='%H:%I:%S')
cdf_varget,id,name_var3,flux,rec_count=maxrec
cdf_varget,id,name_var4,energy_wind_e

if keyword_set(multi_day) then begin 
  for i=1, N_elements(electron_l1_name)-1 do begin 
    id = CDF_OPEN(electron_l1_name[i])
    inq = CDF_inquire(id)
    nvars=inq.nvars
    nzvars=inq.nzvars
    maxrec=inq.maxrec
    var1=CDF_varinq(id,0); data_type='CDF_EPOCH'
    name_var1=var1.NAME
    CDF_varget,id,name_var1,Epoch1,rec_count=maxrec; in CDF_Epoch type
    ;CDF_varget1,id,name_var1,Epoch  ; CDF_varget1 get only one data
    Epoch_jul1=CDF_EPOCH_TOJULDAYS(Epoch1); In Julday for plot
    ;Epoch_str=CDF_ENCODE_EPOCH(Epoch)
    ;Result = CDF_VARNUM( Id, VarName [, IsZVar] ) :find the num of VarName
    var2=CDF_varinq(id,0,/zvariable)
    name_var2=var2.NAME
    var3=CDF_varinq(id,1,/zvariable)
    name_var3=var3.NAME
    Var4=CDF_varinq(id,2,/zvariable)
    name_var4=var4.NAME
    cdf_varget,id,name_var3,flux1,rec_count=maxrec
    flux=[[flux],[flux1]]
    Epoch_jul=[[Epoch_jul],[Epoch_jul1]]
  endfor
endif

;-----
Wind_velocity=calculate_velocity(energy_wind_e,unit='ev',particle='electron',light_speed=beta_e)
if not keyword_set(IMF_length) then begin
  IMF_length=1.2*AU
  print,'you should offer the real IMF length calculated from solar wind speed'
endif
travel_time=IMF_length/Wind_velocity
wind_onset_time=make_array(7,/double)
for i=0,6 do begin
  flux_t=smooth(flux[i,*],smooth_num,/nan,/edge_truncate)
  Wind_onset_time[i]=find_onset_time(Epoch_jul,flux_t,background=background_xrange,position=pos,time=Point_num_onset)
  if (Wind_onset_time[i] eq -1) then print,'you analysis is wrong or this channel doest have enhancement'
endfor

release_time=wind_onset_time-travel_time/86400D + 8.33/1440D ; 8.33 ,corresponding to light travel time

if not keyword_set(fitting_range) then begin
  print,'you should offer the fitting range of WIND electron'
  fitting_range=bindgen(7)
endif

if fitting_range[0] eq 100 then goto,No_enhancement
  ;plot part-----------------
  if keyword_set(fitting_range) then begin
  ;  !p.multi=[2,2,1] 
    cgplot,Epoch_jul,smooth(reform(flux[0,*]),5,/nan),xstyle=1,xtickformat='label_date',/ylog,ystyle=1,yrange=wind_yrange,$
      title='wind electron',xrange=xrange,/nodata
    if !y.type eq 1 then begin
      yrange_arrow_eruption=10^!y.crange[1]
      Yrange_arrow_eruption_1=10^(!y.crange[1]+(!y.crange[1]-!y.crange[0])/100)
    endif else begin
      yrange_arrow_eruption=!y.crange
      yrange_arrow_eruption_1=!y.crange*1.01
    endelse
    foreach i,fitting_range do begin
      flux_t=smooth(flux[i,*],smooth_num,/nan,/edge_truncate)
      cgplot,Epoch_jul,flux_t,/over,color=mycolor1[i],psym=1,symsize=0.1
      xxxxxx=find_onset_time(Epoch_jul,flux_t,background=background_xrange,position=pos,time=Point_num_onset,/pline)
      vline,wind_onset_time[i],linestyle=0,color=mycolor1[i]
      print,jul2any(wind_onset_time[i],/ccsds)
      cgplots,Wind_onset_time[i],flux_t[pos],psym=2,symsize=3,color=mycolor1[i]
    endforeach
    vline,eruption_time,linestyle=2
    cgarrow,eruption_time,yrange_arrow_eruption_1,eruption_time,yrange_arrow_eruption,/data,hsize=!d.x_size/256,$
      hthick=0.5,color=cgcolor('black')
endif

  ;-------------

x=1/beta_e[fitting_range]
y=(Wind_onset_time[fitting_range]-eruption_time)*86400D/60.
cgplot,x,y,psym=2,color='red',yrange=fit_plot_yrange,xrange=fit_plot_xrange
result=ladfit(x[sort(x)],y[sort(x)],absdev=error)
length_VDA=result[1]*light_speed*60/AU
tempx=1+findgen(100)/100.*(4)
cgplot,tempx,result[0]+result[1]*tempx,/over,color='blue'
r_from_VDA=jul2any(eruption_time+result[0]/1440D +8.33/1440D,/ccsds)

cgtext,0.8,0.25,string(length_vda,format='(F-8.4)')+' AU(Ladfit)',color='blue',/normal
cgtext,0.8,0.2,r_from_vda,color='blue',/normal

No_enhancement:

openw,lun,result_dir+event_num+'/result.dat',/get_lun,width=400
printf,lun,'WIND electron result from TSA and VDA(date:'+event_num+' )'+'generated on '+systim()
printf,lun,'energy_wind(eV)','onset_time','travel time','release time','quality',format='(A-20,A-25,A-20,A-25,A-20)'
for i =0,6 do begin
  if where(fitting_range eq i) ne -1 then begin
  printf,lun,energy_wind_e[i],jul2any(wind_onset_time[i],/ccsds),travel_time[i],jul2any(release_time[i],/ccsds),1,format='(f-20.5,A-25,f-20.5,A-25,I-20)'
  endif else begin
  printf,lun,energy_wind_e[i],jul2any(wind_onset_time[i],/ccsds),travel_time[i],jul2any(release_time[i],/ccsds),0,format='(f-20.5,A-25,f-20.5,A-25,I-20)'
  endelse
endfor
if fitting_range[0] eq 100 or N_elements(fitting_range) eq 1 then error=[0,0]&r_from_VDA=0 &length_VDA=0
printf,lun,'result from ladfit_VDA:',r_from_VDA,error,'; length=',length_VDA,format='(A-25,A,"(",F-8.4,"min)",A,F-8.3,"AU")'

if N_elements(fitting_range) ge 2 then begin 
x=1/beta_e[fitting_range]
y=(Wind_onset_time[fitting_range]-eruption_time)*86400D/60.
;cgplot,x,y,psym=2,color='red'
result=linfit(x,y,measure_errors=SQRT(ABS(Y)),sigma=error)
length_VDA=result[1]*light_speed*60/AU
tempx=1+findgen(100)/100.*(4)
cgplot,tempx,result[0]+result[1]*tempx,/over,color='green'
r_from_VDA=jul2any(eruption_time+result[0]/1440D +8.33/1440D,/ccsds)

cgtext,0.8,0.15,string(length_vda,format='(F-8.4)')+' AU(Linfit)',color='green',/normal
cgtext,0.8,0.1,r_from_vda,color='green',/normal
endif
if fitting_range[0] eq 100 or N_elements(fitting_range) eq 1 then error=[0,0]&r_from_VDA=0 &length_VDA=0
slope=error[1]*light_speed*60/AU
printf,lun,'result from linfit_VDA: ',r_from_VDA,'; length=',length_VDA,error[0],slope,format='(A-25,2A,F-8.4,"(",F-8.3,"min",F-8.3,"AU)")'

free_lun,lun

; 
; 
; 

end



