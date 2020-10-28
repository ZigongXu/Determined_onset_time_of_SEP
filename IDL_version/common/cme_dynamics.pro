function get_CME_height,result,release_time,zero_time_point=zero_time_point,lun=lun,polynominal=polynominal
;;
;Name :get_height
;purpos : get the height at onset_time
;
time=release_time[where(release_time ne '-1')]
if time[0] eq '-1' then begin 
   printf,lun,-1,0,format='(2f-10.0)'
   return,0  
endif
if not keyword_set(polynominal) then begin 
  height=result[0]+result[1]*(anytim(time)-zero_time_point)
endif else begin
  if polynominal eq 2 then begin
    x=anytim(time)-zero_time_point
    height=result[0]+result[1]*x+result[2]*x^2
  endif
endelse

if keyword_set(lun) then begin 
  for i =0,n_elements(time)-1 do begin
     printf,lun,time[i],height[i]
  endfor
endif
;height_2=height[where(height gt 0 and height lt 40)]
return,height

end
pro plot_release_time,release_time,zero_time_point=zero_time_point,_extra=_extra
;;
;
;
time=release_time[where(release_time ne '-1')]

vline,anytim(time)-zero_time_point,_extra=_extra
end

function input_particle_result,lun,onset=onset,travel_time=travel_time,release=release,num=num
;
;
;Modification history
;#### who knows the start editting time
;2017.7.21 add the quality tag at the time data and quality equals 1 means this release time is the useful data we picked when analysis and 0 means useless
;
;
;
if not keyword_set(num) then begin
  print,'you need to offer the number of lines you want to read'
  return,-1
endif

 str=''
  for i=0,num-1 do begin
    readf,lun,str
    temp=strsplit(str,' ',/extract)
    if (double(strmid(temp[1],0,9)) ge 2010 and double(temp[4]) eq 1) then onset[i]=temp[1] else onset[i]='-1'
    ;//this is a case code just for this work-2017.7.21
    travel_time[i]=double(temp[2])
    if (double(strmid(temp[3],0,9)) ge 2010 and double(temp[4]) eq 1) then release[i]=temp[3] else release[i]='-1'
  endfor
  return,1
end
;-------------------------------
function pick_file,name
;Name
;purpose: pick up file pair we wanted and need to re-analysis after analysis of GCS 
;
t1=strmid(name,14,/reverse)
i=0
result=[]
while (i lt n_elements(t1)) do begin 
  for j=i+1, n_elements(t1)-1 do begin
    if t1[j] eq t1[i] then begin
      result=[[result],[name[i],name[j]]]
      break
    endif
  endfor
  i+=1
endwhile
return,result
end

function h_front_reverse,h,ratio,half_angle
;subroutine compute h_front_reverse, no need to use
half_angle=half_angle/180D*!pi
return,[[h],[h*((1+ratio)/(1-ratio^2)*(1+sin(half_angle))/cos(half_angle))]]
end
;
;;
;;
pro CME_dynamics,event_num,result_dir=result_dir,image_dir=image_dir,polynominal=polynominal

;
;Name: CME_dynamcis
;Purpose : use to plot the height image after analysis_[1~5]
;;
;Explanation:
;       polynominal : int means the degree of poly_fit( dault !null,means the linear fit)
;Cataloge: Common
;
;Modification history
;**** start
;2017.7.24 add the fiiting of a polynominal
;
;

restore,'/Users/zigongxu/Documents/work/myWork2_GCS_releasetime/code/common/constant_define.sav'
;H_front=height*((1+ratio)/(1-ratio^2)*(1+sin(half_angle))/cos(half_angle))  ApJ,653,763

if not keyword_set(result_dir) then result_dir='/Users/zigongxu/Documents/work/myWork2_GCS_releasetime/result/'
if not keyword_set(image_dir) then image_dir='/Users/zigongxu/Documents/work/myWork2_GCS_releasetime/image/'+event_num+'/'

;save image as height fitting map and result.
prefix_name='result_CME'
result_name=pick_file(file_search(result_dir+event_num,prefix_name+'*.dat'))


set_plot,'ps'
device,filename=image_dir+'height_fitting_map.eps',xsize=6,ysize=8,xoffset=1,yoffset=1,/inches
;cgdisplay,800,800
!p.multi=0
;2017.7.23 note: codes I wrote before can be used for 2 or 3 pair of Cor2C2/Co2C3 data. beautiful! cool
for i =0,N_elements(result_name[0,*])-1 do begin
  
; read data and analysis
    if strmid(file_basename(result_name[0,i]),11,6) eq 'Cor2C2' then cor2c2=result_name[0,i]
    if strmid(file_basename(result_name[1,i]),11,6) eq 'Cor2C3' then cor2c3=result_name[1,i]
    fmt='A,A,X,F,F,F,F,F,F,I'
    readcol,cor2c2,format=fmt,time_soho_cor2c2,time_stab_cor2c2,longitude_cor2c2,latitude_cor2c2,tilt_cor2c2,height_cor2c2,ratio_cor2c2,half_angle_cor2c2,quality_cor2c2
    h_result_cor2c2=height_cor2c2[where(quality_cor2c2 ne 22)]
    god=where(time_soho_cor2c2 ne '-1')
    check=where(time_soho_cor2c2 eq '-1')
    if check[0] ne -1 then time_soho_cor2c2[where(time_soho_cor2c2 eq '-1')]=strmid(time_soho_cor2c2[god[0]],0,11)+time_Stab_cor2c2[where(time_soho_cor2c2 eq '-1')]
    zero_time_point=min([anytim(time_soho_cor2c2),anytim(strmid(time_soho_cor2c2,0,11)+time_stab_cor2c2)])-600D  ;utime second since 1-jan-1979
    time_result_cor2c2=anytim(time_soho_cor2c2[where(quality_cor2c2 ne 22)])-zero_time_point
    ;print,time_result_cor2c2 
    cgplot,time_result_cor2c2,h_result_cor2c2,psym=2,color='blue',xtitle='second from '+anytim(zero_time_point,/ccsds),ytitle='height/R_sun',$
      title='Lasco/C2/C3--STEREO/cor2('+strmid(file_basename(result_name[0,i]),14,11,/reverse)+')',charsize=0.8,xrange=[-1200,max(time_result_cor2c2)+2000]
    pline,1,linestyle=1,color='black'
    
    readcol,cor2c3,format=fmt,time_soho_cor2c3,time_stab_cor2c3,longitude_cor2c3,latitude_cor2c3,tilt_cor2c3,height_cor2c3,ratio_cor2c3,half_angle_cor2c3,quality_cor2c3
    h_result_cor2c3=height_cor2c3[where(quality_cor2c3 ne 22)]
     god=where(time_soho_cor2c3 ne '-1')
     check=where(time_soho_cor2c3 eq '-1')
    if check[0] ne -1 then time_soho_cor2c3[where(time_soho_cor2c3 eq '-1')]=strmid(time_soho_cor2c3[god[0]],0,11)+time_Stab_cor2c3[where(time_soho_cor2c3 eq '-1')]
    zero_time_point=min([anytim(time_soho_cor2c3),anytim(strmid(time_soho_cor2c3,0,11)+time_stab_cor2c3)])-600D  ;utime second since 1-jan-1979
    time_result_cor2c3=anytim(time_soho_cor2c3[where(quality_cor2c3 ne 22)])-zero_time_point
   ; print,time_result_cor2c3 
    cgplot,time_result_cor2c3,h_result_cor2c3,psym=2,color='green',/over
        
    time_final=[time_result_cor2c2,time_result_cor2c3] &h_final=[h_result_cor2c2,h_result_cor2c3]
    quality_final=[quality_cor2c2[where(quality_cor2c2 ne 22)],quality_cor2c3[where(quality_cor2c3 ne 22)]]
 if not keyword_set(polynominal) then begin
    fit_result=linfit(time_final,h_final,measure_errors=SQRT(ABS(h_final)),sigma=error)
    temp=findgen(10000)/10000D*(max(time_final)+3200)-1200
    cgplot,temp,fit_result[0]+temp*fit_result[1],color='red',linestyle=2,/over
    cgtext,0.7,0.2,/normal,'CME speed:'+strtrim(string(fit_result[1]*R_sun/1000D,format='(F10.3)'),2) + ' km/s',charsize=0.8
    time_R_sun=anytim((1-fit_result[0])/fit_result[1] + zero_time_point,/ccsds)
    openw,lun_R_sun,'/Users/zigongxu/Documents/work/myWork2_GCS_releasetime/result/CME_start_time.dat',/get_lun,/append
    printf,lun_R_sun,event_num,time_R_sun,fit_result[1]*R_sun/1000D,0,0,format='(2A-25,F-25.3,2I-25)'
    free_lun,lun_R_sun
  endif else begin
    fit_result=linfit(time_final,h_final,measure_errors=SQRT(ABS(h_final)),sigma=error)
    temp=findgen(10000)/10000D*(max(time_final)+3200)-1200
    cgplot,temp,fit_result[0]+temp*fit_result[1],color='purple',linestyle=2,/over
    cgtext,0.7,0.3,/normal,'CME speed:'+strtrim(string(fit_result[1]*R_sun/1000D,format='(F10.3)'),2) + ' km/s',charsize=0.8,color='purple'
         
      fit_result=Poly_fit(time_final,h_final,polynominal,Measure_errors=h_final/10.,sigma=error)
      temp=findgen(10000)/10000D*(max(time_final)+3200)-1200
      cgplot,temp,fit_result[0]+temp*fit_result[1]+temp*temp*fit_result[2],color='red',linestyle=2,/over
      cgtext,0.7,0.25,/normal,'CME speed:'+strtrim(string((fit_result[1]+fit_result[2]*20000)*R_sun/1000D,format='(F10.3)'),2) + ' km/s',charsize=0.8
      cgtext,0.7,0.2,/normal,'CME speed:'+strtrim(string(fit_result[1]*R_sun/1000D,format='(F10.3)'),2) + ' km/s',charsize=0.8
      cgtext,0.7,0.17,/normal,'Accelerate is :'+strtrim(string(fit_result[2]*R_sun/1000D,format='(F10.3)'),2)+ ' km/s^2',charsize=0.8
      ;add 2017.7.24
      ;  
      
      time_R_sun=anytim(temp[where(abs(fit_result[0]+temp*fit_result[1]+temp*temp*fit_result[2] - 1) eq min(abs(fit_result[0]+temp*fit_result[1]+temp*temp*fit_result[2] - 1)))]+zero_time_point,/ccsds)
      openw,lun_R_sun,'/Users/zigongxu/Documents/work/myWork2_GCS_releasetime/result/CME_start_time.dat',/get_lun,/append
      printf,lun_R_sun,event_num,time_R_sun,(fit_result[1]+fit_result[2]*20000)*R_sun/1000D,2,fit_result[2]*R_sun/1000D,format='(2A-25,F-25.3,I-25,f-25.3)'
      free_lun,lun_R_sun
      ;add at 2017.7.30
    endelse
  
    ; read data from particle result
    ;first L1(SOHO proton and electron)
    L1_data=result_dir+event_num+'/result.dat'
    openr,lun,/get_lun,L1_data
    a=''
    readf,lun,a
    readf,lun,a
    wind_onset_time=make_array(7,/string)
    wind_travel_time=make_array(7,/double)
    wind_release_time_TSA=make_array(7,/string)
    skip=0D
    temp=input_particle_result(lun,onset=wind_onset_time,travel_time=wind_travel_time,release=wind_release_time_TSA,num=7)
  ;  print,wind_onset_time,wind_travel_time,wind_release_time_TSA 
    for i= 0,4 do begin
    readf,lun,a
    endfor
    SOHO_onset_time=make_array(10,/string)
    SOHO_travel_time=make_array(10,/double)
    SOHO_release_time_TSA=make_array(10,/string)
    temp=input_particle_result(lun,onset=SOHO_onset_time,travel_time=SOHO_travel_time,release=SOHO_release_time_TSA,num=10)
  ;  print,soho_onset_time,soho_travel_time,soho_release_time_TSA
    free_lun,lun
    ;---
    openr,lun,/get_lun,result_dir+event_num+'/result3.dat'
    for i =0,2 do begin
      readf,lun,a
    endfor
    STA_e_onset_time=make_array(15,/string)
    STA_e_travel_time=make_array(15,/double)
    STA_e_release_time_TSA=make_array(15,/string)
    STB_e_onset_time=make_array(15,/string)
    stb_e_travel_time=make_array(15,/double)
    stb_e_release_time_TSA=make_array(15,/string)
    temp=input_particle_result(lun,onset=STA_e_onset_time,travel=STA_e_travel_time,release=STA_e_release_time_TSA,num=15)
    for i= 0,3 do begin
      readf,lun,a
    endfor
    temp=input_particle_result(lun,onset=STB_e_onset_time,travel=STB_e_travel_time,release=STB_e_release_time_TSA,num=15)
    free_lun,lun
    ;--------
    openr,lun,/get_lun,result_dir+event_num+'/result4.dat'
    for i= 0,2 do begin
      readf,lun,a
    endfor
    STA_p_onset_time=make_array(15,/string)
    STA_p_travel_time=make_array(15,/double)
    STA_p_release_time_TSA=make_array(15,/string)
    STB_p_onset_time=make_array(15,/string)
    stb_p_travel_time=make_array(15,/double)
    stb_p_release_time_TSA=make_array(15,/string)
    temp=input_particle_result(lun,onset=STA_p_onset_time,travel=STA_p_travel_time,release=STA_p_release_time_TSA,num=15)
    for i= 0,3 do begin
      readf,lun,a
    endfor
    temp=input_particle_result(lun,onset=STB_p_onset_time,travel=STB_p_travel_time,release=STB_p_release_time_TSA,num=15)
    free_lun,lun
    
    openw,lun,/get_lun,result_dir+event_num+'/result_height.dat'
    printf,lun,'WIND proton'
    height_CME_releasetime=get_CME_height(fit_result,wind_release_time_TSA,zero_time_point=zero_time_point,lun=lun,polynominal=polynominal)
    ;printf,lun,wind_release_time_TSA[where(wind_release_time_TSA ne '-1')],height_CME_releasetime
    plot_release_time,wind_release_time_TSA,zero_time_point=zero_time_point,color=mycolor1[0]
    cgtext,0.7,0.6,color=mycolor1[0],charsize=0.8,'Wind Electron:('+string(min(height_CME_releasetime),format='(F-7.2)')+string(max(height_CME_releasetime),format='(F-6.2)')+')',/normal
    printf,lun,'SOHO proton'
    height_CME_releasetime=get_CME_height(fit_result,soho_release_time_TSA,zero_time_point=zero_time_point,lun=lun,polynominal=polynominal)
    ;printf,lun,soho_release_time_TSA[where(soho_release_time_TSA ne '-1')],height_CME_releasetime
    plot_release_time,soho_release_time_TSA,zero_time_point=zero_time_point,color=mycolor1[1]
    cgtext,0.7,0.57,color=mycolor1[1],charsize=0.8,'SOHO proton:('+string(min(height_CME_releasetime),format='(F-7.2)')+string(max(height_CME_releasetime),format='(F-6.2)')+')',/normal
    printf,lun,'STEREO A electron'
    height_CME_releasetime=get_CME_height(fit_result,STA_e_release_time_TSA,zero_time_point=zero_time_point,lun=lun,polynominal=polynominal)
    ;printf,lun,STA_e_release_time_TSA[where(STA_e_release_time_TSA ne '-1')],height_CME_releasetime
    plot_release_time,STA_e_release_time_TSA,zero_time_point=zero_time_point,color=mycolor1[5]
    cgtext,0.7,0.54,color=mycolor1[5],charsize=0.8,'STEREO A Electron:('+string(min(height_CME_releasetime),format='(F-7.2)')+string(max(height_CME_releasetime),format='(F-6.2)')+')',/normal
    printf,lun,'STEREO B electron'
    height_CME_releasetime=get_CME_height(fit_result,STB_e_release_time_TSA,zero_time_point=zero_time_point,lun=lun,polynominal=polynominal)
   ; printf,lun,STB_e_release_time_TSA[where(STB_e_release_time_TSA ne '-1')],height_CME_releasetime
    
    plot_release_time,STB_e_release_time_TSA,zero_time_point=zero_time_point,color=mycolor1[6]
    cgtext,0.7,0.51,color=mycolor1[6],charsize=0.8,'STEREO B Electron:('+string(min(height_CME_releasetime),format='(F-7.2)')+string(max(height_CME_releasetime),format='(F-6.2)')+')',/normal
    printf,lun,'STEREO A proton'
    height_CME_releasetime=get_CME_height(fit_result,STA_p_release_time_TSA,zero_time_point=zero_time_point,lun=lun,polynominal=polynominal)
   
  ;  printf,lun,STA_p_release_time_TSA[where(STA_p_release_time_TSA ne '-1')],height_CME_releasetime

    plot_release_time,STA_p_release_time_TSA,zero_time_point=zero_time_point,color=mycolor1[7]
    cgtext,0.7,0.48,color=mycolor1[7],charsize=0.8,'STEREO A Proton:('+string(min(height_CME_releasetime),format='(F-7.2)')+string(max(height_CME_releasetime),format='(F-6.2)')+')',/normal
    printf,lun,'STEREO B proton'
    height_CME_releasetime=get_CME_height(fit_result,STB_p_release_time_TSA,zero_time_point=zero_time_point,lun=lun,polynominal=polynominal)
    
;    printf,lun,STB_p_release_time_TSA[where(STB_p_release_time_TSA ne '-1')],height_CME_releasetime
    plot_release_time,STB_p_release_time_TSA,zero_time_point=zero_time_point,color=mycolor1[8]
    cgtext,0.7,0.45,color=mycolor1[8],charsize=0.8,'STEREO B Proton:('+string(min(height_CME_releasetime),format='(F-7.2)')+string(max(height_CME_releasetime),format='(F-6.2)')+')',/normal
    free_lun,lun
endfor
device,/close
end