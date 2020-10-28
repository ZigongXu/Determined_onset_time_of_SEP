
;name: analysis_2
;purpose: SOHO proton analysise
;
;parameter explanition:
;           
;           
;           /is_SOHO_low_energy_need,  plot SOHO low energy proton flux curve. otherwise, not plot
;;         multi_day: /multi_day, means that the temporary intensity profile can not be described using one day data

;Modification history:
;
;2017.6.29 replace common by restore; standardize their output format; add fitting result  in fitting map
;2017.7.3  9:48    add outside door and keyword background_xrange,xrange,eruption_time and many other keywords
;          used as a common procedure
;2017.7.5  11:10  add multi_day as a keyword for multi day data
;
;
;
pro analysis_2,event_num,xrange=xrange,$
  background_xrange=background_xrange,eruption_time=eruption_time,IMF_length=IMF_length,$
  soho_yrange=soho_yrange,Point_num_onset=Point_num_onset,fitting_range=fitting_range,$
  smooth_num=smooth_num,$
  fit_plot_yrange=fit_plot_yrange,fit_plot_xrange=fit_plot_xrange,$
  result_dir=result_dir,data_dir=data_dir,is_SOHO_low_energy_need=is_soho_low_energy_need,multi_day=multi_day
  
  
  restore,'/Users/zigongxu/Documents/work/myWork2_GCS_releasetime/code/common/constant_define.sav'
  if not keyword_set(data_dir) then data_dir='/Users/zigongxu/Documents/work/myWork2_GCS_releasetime/data/'  
  if not keyword_set(result_dir) then result_dir='/Users/zigongxu/Documents/work/myWork2_GCS_releasetime/result/'
    
  velocity=calculate_velocity(P_soho_high,unit='MeV',particle='proton',light_speed=beta) 
  if not keyword_set(IMF_length) then begin
    IMF_length=1.2*AU
    print,'you should offer the real IMF length calculated from solar wind speed'
  endif
  travel_time=IMF_length/velocity ; in second

  if not keyword_set(soho_yrange) then soho_yrange=[1e-5,1e3]   
  if not keyword_set(point_num_onset) then point_num_onset=20  
  if not keyword_set(smooth_num) then smooth_num=1  
 ; if not keyword_set(fitting_range) then fitting_range=bindgen(7)
  if not keyword_set(fit_plot_yrange) then fit_plot_yrange=[0,200]  
  if not keyword_set(fit_plot_xrange) then fit_plot_xrange=[1,10]  
  if not keyword_set(is_SOHO_low_energy_need) then is_SOHO_low_energy_need=1
   
  dummy=label_date(date_format='%H:%I')
 ; cgdisplay,1200,800,wid=2
 ; !p.multi=[2,2,1]
  doy_name=doy(strmid(event_num,0,4)+'-'+strmid(event_num,4,2)+'-'+strmid(event_num,6,2)); data type :int
  str_doy_name=strtrim(doy_name,2); remove all blank space
  
  if keyword_set(multi_day) then begin 
    proton_l1_name=file_search(data_dir+event_num+'/particle','LED*.SL2')
  endif else begin
    proton_l1_name=file_search(data_dir+event_num+'/particle','LED*'+str_doy_name+'.SL2')
  endelse
  
  ;soho P
  if keyword_set(multi_day) then begin
    fmt='f,f,f,x,f,f,f,f,f,f,f,f,f,f'
    readcol,proton_L1_name[0],format=fmt,year,day,Htime,PH1,PH2,Ph3,PH4,PH5,PH6,PH7,PH8,PH9,PH10,/silent
    P_soho=[transpose(temporary(PH1)),transpose(temporary(PH2)),transpose(temporary(PH3)),transpose(temporary(PH4)),transpose(temporary(PH5)),transpose(temporary(PH6)),transpose(temporary(PH7)),$
      transpose(temporary(PH8)),transpose(temporary(PH9)),transpose(temporary(PH10))]
    SOHO_Htime_jul=doy2jul(year,day+htime/86400000D)
    for i =1,n_elements(proton_l1_name)-1 do begin
      readcol,proton_L1_name[i],format=fmt,year,day,Htime,PH1,PH2,Ph3,PH4,PH5,PH6,PH7,PH8,PH9,PH10,/silent
      P_soho1=[transpose(temporary(PH1)),transpose(temporary(PH2)),transpose(temporary(PH3)),transpose(temporary(PH4)),transpose(temporary(PH5)),transpose(temporary(PH6)),transpose(temporary(PH7)),$
        transpose(temporary(PH8)),transpose(temporary(PH9)),transpose(temporary(PH10))]
      SOHO_Htime_jul1=doy2jul(year,day+htime/86400000D)
      P_soho=[[P_soho],[P_soho1]]
      SOHO_Htime_jul=[SOHO_Htime_jul,SOHO_Htime_jul1]
    endfor
  endif else begin
  fmt='f,f,f,x,f,f,f,f,f,f,f,f,f,f'
  readcol,proton_L1_name[0],format=fmt,year,day,Htime,PH1,PH2,Ph3,PH4,PH5,PH6,PH7,PH8,PH9,PH10,/silent
  P_soho=[transpose(temporary(PH1)),transpose(temporary(PH2)),transpose(temporary(PH3)),transpose(temporary(PH4)),transpose(temporary(PH5)),transpose(temporary(PH6)),transpose(temporary(PH7)),$
    transpose(temporary(PH8)),transpose(temporary(PH9)),transpose(temporary(PH10))]
  SOHO_Htime_jul=doy2jul(year,day+htime/86400000D)
  endelse
  
  cgplot,soho_Htime_jul,p_soho[0,*],/nodata,xstyle=1,ystyle=1,yrange=soho_yrange,/ylog,xtickformat='label_date',title='SOHO_proton',xrange=xrange
  
  if (is_SOHO_low_energy_need eq 1) then begin
  for i =0,9,2 do begin
    cgplot,SOHO_Htime_jul,smooth(P_soho[i,*],10,/nan,/edge_truncate),/over,color=mycolor1[i],symsize=0.1,psym=1
    ; cgtext,0.2,0.2+i*0.05,strcompress(string( P_SOHO_Low[i])),/normal,color=mycolor[i]
  endfor
  endif
  
  vline,eruption_time,linestyle=2
 ;----
  if keyword_set(multi_day) then begin
    proton_h1_name=file_search(data_dir+event_num+'/particle','HED*.SL2')
  endif else begin
    proton_h1_name=file_search(data_dir+event_num+'/particle','HED*'+str_doy_name+'.SL2')
  endelse
  fmt='f,f,f,x,f,f,f,f,f,f,f,f,f,f'
  if keyword_set(multi_day) then begin 
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
 
  ;cgplot,soho_Htime_jul,p_soho[i,*],/nodata,xstyle=1,ystyle=1,yrange=soho_yrange,/ylog,xtickformat='label_date',title='SOHO_proton'
  soho_onset_time=make_array(10,/double)
  soho_release_time=make_array(10,/double)
  
  for i =0,9 do begin  
    flux=smooth(P_soho[i,*],smooth_num,/nan,/edge_truncate)
    soho_onset_time[i]=find_onset_time(soho_htime_jul,flux,background=background_xrange,position=pos,time=Point_num_onset,color=mycolor1[i-9])
    soho_release_time[i]=soho_onset_time[i]-travel_time[i]/86400D + 8.33/1440D

  endfor
  
  if not keyword_set(fitting_range) then begin
    print,'you should offer the fitting range of SOHO proton[0~9]'
    fitting_range=bindgen(10)
  endif
   if fitting_range[0] eq 100 then goto, No_enhancement_in_SOHO
  
  foreach i,fitting_range do begin
    flux=smooth(P_soho[i,*],smooth_num,/nan,/edge_truncate)
    cgplot,SOHO_Htime_jul,flux,/over,color=mycolor1[i-9],symsize=0.1,psym=1,/noerase
    xxxxxx=find_onset_time(soho_htime_jul,flux,background=background_xrange,position=pos,time=Point_num_onset,color=mycolor1[i-9],/pline)
    vline,soho_onset_time[i],linestyle=2,color=mycolor1[i-9]
    cgplots,soho_onset_time[i],flux[pos],psym=6,color=mycolor1[i-9],symsize=1.5,thick=1.2
    print,jul2any(soho_onset_time[i],/ccsds)
    ; cgtext,0.2,0.2+i*0.05,strcompress(string( P_SOHO_Low[i])),/normal,color=mycolor[i]
  endforeach
  

  
  x=1/beta[fitting_range]
  y=(SOHO_onset_time[fitting_range]-eruption_time)*86400D/60.
  cgplot,x,y,psym=2,color='red',yrange=fit_plot_yrange,xrange=fit_plot_xrange
  result=ladfit(x[sort(x)],y[sort(x)],absdev=error)
  length_VDA=result[1]*light_speed*60/AU
  tempx=1+findgen(100)/100.*(15)
  cgplot,tempx,result[0]+result[1]*tempx,/over,color='blue'
  r_from_VDA=jul2any(eruption_time+result[0]/1440D +8.33/1440D,/ccsds)
  cgtext,0.8,0.15,string(length_vda,format='(F-8.4)')+' AU(Ladfit)',color='blue',/normal
  cgtext,0.8,0.1,r_from_vda,color='blue',/normal
  
  
  x=1/beta[fitting_range]
  y=(SOHO_onset_time[fitting_range]-eruption_time)*86400D/60.
  ;cgplot,x,y,psym=2,color='red',yrange=fit_plot_yrange,xrange=fit_plot_xrange
  result=linfit(x,y,measure_errors=SQRT(ABS(Y)),sigma=error)
  length_VDA=result[1]*light_speed*60/AU
  tempx=findgen(100)/100.*(15)
  cgplot,tempx,result[0]+result[1]*tempx,/over,color='green'
  r_from_VDA=jul2any(eruption_time+result[0]/1440D +8.33/1440D,/ccsds)
  cgtext,0.8,0.25,string(length_vda,format='(F8.4)')+' AU',color='green',/normal
  cgtext,0.8,0.2,r_from_vda,color='green',/normal
  
   No_enhancement_in_SOHO:
  openu,lun,result_dir+event_num+'/result.dat',/get_lun,width=400;,/append
  
  skip_lun,lun,11,/lines
  printf,lun,'-----------------------'
  printf,lun,'SOHO result from TSA and VDA(date: '+event_num+');Updata in '+systim()
  printf,lun,'Energy(MeV)','Onset_time','travel time(Sec=1.2Au/V)','Release time(+8.3 min)','quality',format='(4A-25,A-20)'
  for i=0,9 do begin 
      if where(fitting_range eq i) ne -1 then begin
        printf,lun,P_soho_high[i],jul2any(Soho_onset_time[i],/ccsds),travel_time[i],jul2any(soho_release_time[i],/ccsds),1,format='(F-25.4,A-25,F-25.4,A-25,I-20)'

      endif else begin
        printf,lun,P_soho_high[i],jul2any(Soho_onset_time[i],/ccsds),travel_time[i],jul2any(soho_release_time[i],/ccsds),0,format='(F-25.4,A-25,F-25.4,A-25,I-20)'
      endelse
  endfor
  if fitting_range[0] eq 100 or N_elements(fitting_range) eq 1 then error=[0,0]&r_from_VDA=0 &length_VDA=0
  slope=error[1]*light_speed*60/AU
  printf,lun,'result from linfit_VDA:',r_from_VDA,'; length=',length_VDA,'Au (',error[0],slope,')',format='(A-25,2A,F-8.4,A,F-8.3,"min",F-8.3,"AU",A)'
  free_lun,lun
  
 
  
 end