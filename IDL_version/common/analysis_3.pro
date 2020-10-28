;name : analysis_3
;Purpose: STEREO A/B electron analysis
;
;Modification history:
;
;2017.6.29 replace common by restore; standardize their output format; add fitting result  in fitting map
;
;Notice :
;2017.6.29 14:57  the lack of STEREO electron data cause this analysis failed
;2017.7.3  11:12    add outside door and keyword background_xrange,xrange,eruption_time and many other keywords
;          used as a common procedure
;
pro analysis_3,event_num,xrange=xrange,$
  background_xrange=background_xrange,eruption_time=eruption_time,$
  STA_yrange=STA_yrange,STB_yrange=STB_yrange,$
  IMF_length=IMF_length,$
  Point_num_onset=Point_num_onset,fitting_range_A=fitting_range_A,fitting_range_B=fitting_range_B,$
  smooth_num=smooth_num,$
  fit_plot_yrange=fit_plot_yrange,fit_plot_xrange=fit_plot_xrange,$
  result_dir=result_dir,data_dir=data_dir,multi_day=multi_day


  ;.com energy_define
  restore,'/Users/zigongxu/Documents/work/myWork2_GCS_releasetime/code/common/constant_define.sav'

  if not keyword_set(STA_yrange) then STA_yrange=[1,10e5]
  if not keyword_set(STB_yrange) then STB_yrange=[5e-2,5e4]
  
  velocity=calculate_velocity(E_sept,unit='kev',particle='electron',light_speed=beta)
  if not keyword_set(IMF_length) then begin
    IMF_length=1.2 *Au
    print,'you should offer the real IMF length calculated from solar wind speed'
  endif
  travel_time=IMF_length/Velocity
  
  if not keyword_set(Point_num_onset) then point_num_onset=20
 ; if not keyword_set(fitting_range) then fitting_range=[0,2,4,6,8,10,12,14]
  if not keyword_set(smooth_num) then smooth_num=1
  if not keyword_set(fit_plot_yrange) then fit_plot_yrange=[0,100]
  if not keyword_set(fit_plot_xrange) then fit_plot_xrange=[1,10]
  if not keyword_set(data_dir) then data_dir='/Users/zigongxu/Documents/work/myWork2_GCS_releasetime/data/'
  if not keyword_set(result_dir) then result_dir='/Users/zigongxu/Documents/work/myWork2_GCS_releasetime/result/'
  
  
  dummy=label_date(date_format='%H:%I')
 ; cgdisplay,1200,800,wid=3
 ; !p.multi=[2,2,1]
  doy_name=doy(strmid(event_num,0,4)+'-'+strmid(event_num,4,2)+'-'+strmid(event_num,6,2)); data type :int
  str_doy_name=strtrim(doy_name,2); remove all blank space 
 
 ;STA_e
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
  
  STA_E_onset_time=make_array(15,/double)
  STA_E_release_time=make_array(15,/double) 
  for i=0,14 do begin
    flux=smooth(sta_e[i,*],smooth_num,/nan,/edge_truncate)
    STA_E_onset_time[i]=find_onset_time(eleA_jul,flux,background=background_xrange,position=pos,time=Point_num_onset,color=mycolor1[i-9])
    STA_E_release_time[i]=STA_E_onset_time[i]-travel_time[i]/86400D + 8.33/1440D
  endfor

  if not keyword_set(fitting_range_a) then begin
    print,'you should offer the fiting range of STEREO A electron,the number you use'
    fitting_range_A=bindgen(15)
  endif
  
   if fitting_range_a[0] eq 100 then goto, No_enhancement_in_A
  
  cgplot,eleA_jul,sta_e[1,*],/nodata,/ylog,xtickformat='label_date',xstyle=1,ystyle=1,yrange=STA_yrange,title='STA electron',xrange=xrange
  foreach i,fitting_range_a do begin
    flux=smooth(sta_e[i,*],smooth_num,/nan,/edge_truncate)
    cgplot,eleA_jul,flux,/over,color=mycolor1[i-9],psym=1,symsize=0.1
    xxxxx=find_onset_time(eleA_jul,flux,background=background_xrange,position=pos,time=Point_num_onset,color=mycolor1[i-9],/pline)
    vline,STA_E_Onset_time[i],linestyle=2,color=mycolor1[i-9]
    cgplots,STA_E_onset_time[i],flux[pos],psym=6,color=mycolor1[i-9],thick=1.5
    print,jul2any(STA_E_onset_time[i],/ccsds)
  endforeach
   vline,eruption_time,linestyle=1
  
   x=1/beta[fitting_range_A]
   y=(STA_E_onset_time[fitting_range_A]-eruption_time)*86400D/60  ; minute
   cgplot,x,y,psym=2,color='red',yrange=fit_plot_yrange,xrange=fit_plot_xrange
  if N_elements(fitting_range_A) ge 2 then begin
  result=linfit(x,y,measure_errors=SQRT(ABS(Y)),sigma=error)
  ;result=ladfit(x[sort(x)],y[sort(x)])
  length_VDA=result[1]*light_speed*60/AU
  tempx=findgen(100)/100.*(10)
  cgplot,tempx,result[0]+result[1]*tempx,/over,color='green'
  r_from_VDA=jul2any(eruption_time+result[0]/1440D +8.33/1440D,/ccsds)
  cgtext,0.8,0.25,string(length_vda,format='(F-9.4)')+' AU',color='green',/normal
  cgtext,0.8,0.2,r_from_vda,color='green',/normal
  endif
  ;
  No_enhancement_in_A:
  ;
  openw,lun,result_dir+event_num+'/result3.dat',/get_lun,width=400
  printf,lun,'---------------------------------------'
  printf,lun,'STEREO A electron result from TSA and VDA(date: '+event_num+');Updata in '+systim()
  printf,lun,'Energy(KeV)','Onset_time','travel time(Sec=1.2Au/V)','Release time(+8.3 min)','quality',format='(4A-25,A-20)'
  for i=0,14 do begin 
    if where(fitting_range_A eq i) ne -1 then begin
      printf,lun,E_sept[i],jul2any(STA_E_onset_time[i],/ccsds),travel_time[i],jul2any(STA_e_release_time[i],/ccsds),1,format='(F-25.4,A-25,F-25.4,A-25,I-20)'
    endif else begin
      printf,lun,E_sept[i],jul2any(STA_E_onset_time[i],/ccsds),travel_time[i],jul2any(STA_e_release_time[i],/ccsds),0,format='(F-25.4,A-25,F-25.4,A-25,I-20)'
    endelse
  endfor
  if fitting_range_A[0] eq 100 or N_elements(fitting_range_A) eq 1 then error=[0,0]&r_from_VDA=0 &length_VDA=0
  slope=error[1]*light_speed*60/AU
  printf,lun,'result from linfit_VDA:',r_from_VDA,'; length=',length_VDA,'Au (',error[0],slope,')',format='(A-25,2A,F-7.4,A,F-8.3,"min",F-8.3,"AU",A)'
  free_lun,lun


  ;
  print,'---------------------------------'
  cgdisplay,wid=4,1200,800
  ;STB e
  
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
  stb_e_onset_time=make_array(15,/double)
  stb_e_release_time=make_array(15,/double)
  for i=0,14 do begin
    flux=smooth(stb_e[i,*],smooth_num,/nan,/edge_truncate)
    stb_e_onset_time[i]=find_onset_time(eleb_jul,flux,background=background_xrange,position=pos,time=Point_num_onset,color=mycolor1[i-9])
    stb_e_release_time[i]=stb_e_onset_time[i]- travel_time[i]/86400D + 8.33/1440D
  endfor
  
  if not keyword_set(fitting_range_b) then begin
    print,'you should offer the fitting range of STEREO B electron
    fitting_range_b=bindgen(15)
  endif
  
  if fitting_range_b[0] eq 100 then goto, No_enhancement_in_B 
  
  cgplot,eleB_jul,stb_e[1,*],/nodata,/ylog,xtickformat='label_date',xstyle=1,ystyle=1,yrange=STB_yrange,title='STB electron',xrange=xrange
  foreach i,fitting_range_b do begin
    flux=smooth(stb_e[i,*],smooth_num,/nan,/edge_truncate)
    cgplot,eleB_jul,flux,/over,color=mycolor1[i-9],psym=1,symsize=0.1
    xxxxxx=find_onset_time(eleb_jul,flux,background=background_xrange,position=pos,time=Point_num_onset,color=mycolor1[i-9],/pline)
    print,jul2any(stb_e_onset_time[i],/ccsds)
    vline,stb_e_onset_time[i],linestyle=2,color=mycolor1[i-9]
    cgplots,stb_e_onset_time[i],flux[pos],psym=6,color=mycolor1[i-9],symsize=1.5,thick=1.5
  endforeach
  vline,eruption_time,linestyle=1
  ;-----
  if (N_elements(fitting_range_B) lt 2) then begin 
    x=1/beta[fitting_range_B]
    ;-----
    y=(stb_e_onset_time[fitting_range_B]-eruption_time)*84600D/60D ;min
    cgplot,x,y,psym=2,color='red',xrange=fit_plot_xrange,yrange=fit_plot_yrange
    length_vda=-1
    r_from_VDA='-1'
    cgtext,0.8,0.25,'no SEP event',/normal
    cgtext,0.8,0.2,r_from_vda,color='green',/normal
  endif else begin
    x=1/beta[fitting_range_B]
    ;-----
    y=(stb_e_onset_time[fitting_range_B]-eruption_time)*84600D/60D ;min
    cgplot,x,y,psym=2,color='red',xrange=fit_plot_xrange,yrange=fit_plot_yrange
    result=linfit(x,y,measure_errors=sqrt(abs(y)),sigma=error)
    length_vda=result[1]*light_speed*60/AU
    tempx=findgen(100)/100.*(10)
    cgplot,tempx,result[0]+result[1]*tempx,/over,color='green'
    r_from_VDA=jul2any(eruption_time+result[0]/1440D +8.33/1440D,/ccsds)
    cgtext,0.8,0.25,string(length_vda,format='(F-9.4)')+' AU',color='green',/normal
    cgtext,0.8,0.2,r_from_vda,color='green',/normal
  endelse
  ;tag of no enhancement
  No_enhancement_in_B:
  ;
  openu,lun,result_dir+event_num+'/result3.dat',/get_lun,width=400,/append
  printf,lun,'---------------------------------------'
  printf,lun,'STEREO B electron result from TSA and VDA(date:'+event_num+');Updata in '+systim()
  printf,lun,'Energy(KeV)','Onset_time','travel time(Sec=1.2Au/V)','Release time(+8.3 min)','quality',format='(4A-25,4A-20)'
  for i=0,14 do begin 
      if where(fitting_range_B eq i) ne -1 then begin 
        printf,lun,E_sept[i],jul2any(STB_E_onset_time[i],/ccsds),travel_time[i],jul2any(STB_e_release_time[i],/ccsds),1,format='(F-25.4,A-25,F-25.4,A-25,I-20)'
      endif else begin
        printf,lun,E_sept[i],jul2any(STB_E_onset_time[i],/ccsds),travel_time[i],jul2any(STB_e_release_time[i],/ccsds),0,format='(F-25.4,A-25,F-25.4,A-25,I-20)'
      endelse
  endfor
  if fitting_range_B[0] eq 100 or N_elements(fitting_range_B) eq 1 then error=[0,0]&r_from_VDA=0 &length_VDA=0
  slope=error[1]*light_speed*60/AU
  printf,lun,'result from linfit_VDA:',r_from_VDA,'; length=',length_VDA,'Au (',error[0],slope,')',format='(A-25,2A,F-7.4,A,F-8.3,"min",F-8.3,"AU",A)'
  free_lun,lun

end