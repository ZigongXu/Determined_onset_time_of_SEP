function read_STEREO_different_img_cor2,name_cor2,back_name,hdr_cor2=hdr_cor2,cor2_name_all=cor2_name_all
;Name:read_STEREO_differnt_img_cor2
;Purpose
;Modification history:
;2017.7.22 17:02  first edit

name_tag=strmid(file_basename(cor2_name_all),11,2) 
if strmid(file_basename(name_cor2),11,2) ne '08' then begin
	return,bytscl(alog10(sccreadfits(name_cor2,hdr_cor2)-sccreadfits(back_name)),min=-12,max=-10)
endif else begin
	temp=where(name_tag eq '08')
	if name_cor2 eq Cor2_name_all[temp[0]] then begin
		print,'you should offer an data file as the background of 08 data-2017.7.22-need to be improved as message in near future'
		back_08_name=back_name
	endif  else begin
         	back_08_name=Cor2_name_all[temp[0]]
	endelse
	return,bytscl(alog10(sccreadfits(name_cor2,hdr_cor2)-sccreadfits(back_08_name)),min=-12,max=-10)
endelse
end

function make_thename_identical,STA_cor2=STA_cor2,STB_cor2=STB_cor2

;;make STA and STB has the same name
;
;modification:
;2018.06.20  fix a bug in the first loop
temp_STA=strmid(file_basename(STA_cor2),0,15)
temp_STB=strmid(file_basename(STB_cor2),0,15)
i=0
j=0
a=[] & b=[]
;---
;;
makethemagain: ;print,'do it twice'
;---GOTO symbol.
;---fix bug 2018.06.20
while ((i lt N_elements(temp_STA)) or (j lt N_elements(temp_sTB))) do begin
  ;----bug fix model
  ;-------------------------------------------
    if j ge N_elements(temp_sTB) then begin
        a=[a,STA_cor2[i]]
        b=[b,file_dirname(STB_cor2[j-1])+'/'+file_basename(STA_cor2[i])]
        i+=1      
      continue
    endif
    if i ge N_elements(temp_STB) then begin
        a=[a,file_dirname(STA_cor2[i-1])+'/'+file_basename(STB_cor2[j])]
        b=[b,STB_Cor2[j]]
        j+=1
      continue
    endif
  ;---this is bug when i or j eq the temp_STB or temp_STA. 
  ;The reason caused this bug is the different of STB and STA and that different occured on the last file.
  ;----
    if temp_STA[i] eq temp_STB[j] then begin
      a=[a,STA_cor2[i]]
      b=[b,STB_cor2[j]]
      i+=1
      j+=1
      continue
    endif
    if temp_STA[i] lt temp_STB[j] then begin
      ;小的一边数据多，指针增加，大的，等待匹配
      a=[a,STA_cor2[i]]
      
      b=[b,file_dirname(STB_cor2[j])+'/'+file_basename(STA_cor2[i])]
      i+=1
      continue
    endif
    if temp_STB[j] lt temp_STA[i] then begin
      a=[a,file_dirname(STA_cor2[i])+'/'+file_basename(STB_cor2[j])]
      b=[b,STB_Cor2[j]]
      j+=1
      continue
    endif
endwhile

if n_elements(a) ne n_elements(b) then GOTO, makethemagain
STA_cor2=a
STB_cor2=b 
return,1
end

;----------------

function  Cor2_c2,STA_cor2_dir,STB_cor2_dir,SOHO_dir,STA_EUVI_dir,STB_EUVI_dir,background=background,start_time=start_time,end_time=end_time,event_num=event_num,tag=tag
;
;;
;
; Notice: the 08 data can not be the background
;Modification history: 
;2017.7.22 16:04 corrected the bug of the bad image quality when we use 08 data as the background--the revise method is that we should not use it as background and we should use 08 data as background for the 08 data.Just apply to STEREO A/B Cor2
;
if n_params() ne 5 then begin
  print,'the parameter number is incorrect, please restart'
  return,-1
endif

if ~Keyword_set(background) then begin 
  print,'you need to provide background time'
  return,-1
endif

if  ~keyword_set(start_time) then begin
  print,'you need to provide start time'
  return,-1
endif

if ~Keyword_set(end_time) then begin
  print,'you need to provide end time'
  return,-1
endif

if ~keyword_set(event_num) then begin
  print,'you need to provide event number(like 20110308)'
  return,-1
endif

if ~keyword_set(tag) then begin
  tag1='Cor2C2'
endif else begin
  tag1='Cor2C2_'+tag
endelse

restore,'/Users/zigongxu/Documents/work/myWork2_GCS_releasetime/code/common/constant_define.sav',/ver


STA_cor2=file_search(STA_cor2_dir,'*fts')
STB_cor2=file_search(STB_cor2_dir,'*fts')
r=make_thename_identical(STA_cor2=STA_cor2,STB_cor2=STB_cor2)
obs_time_STA_cor2=make_array(n_elements(STA_cor2),/double)
obs_time_STB_cor2=make_array(n_elements(STB_cor2),/double)

SOHO_c2=file_search(SOHO_dir,'25*')
obs_time_SoHO_c2=make_array(n_elements(soho_c2),/double)
STA_EUVI=file_search(STA_EUVI_dir,'*fts')
STB_EUVI=file_search(STB_EUVI_dir,'*fts')


;----------------------------find the right time to fitting 
obs_time_STA_cor2=julday(strmid(file_basename(STA_cor2),4,2),strmid(file_basename(STA_cor2),6,2),strmid(file_basename(STA_cor2),0,4),$
  strmid(file_basename(STA_cor2),9,2),strmid(file_basename(STA_cor2),11,2),strmid(file_basename(STA_cor2),13,2))
obs_time_STB_cor2=julday(strmid(file_basename(STB_cor2),4,2),strmid(file_basename(STB_cor2),6,2),strmid(file_basename(STB_cor2),0,4),$
  strmid(file_basename(STB_cor2),9,2),strmid(file_basename(STB_cor2),11,2),strmid(file_basename(STB_cor2),13,2))
  
obs_time_STA_EUVI=julday(strmid(file_basename(STA_EUVI),4,2),strmid(file_basename(STA_EUVI),6,2),strmid(file_basename(STA_EUVI),0,4),$
  strmid(file_basename(STA_EUVI),9,2),strmid(file_basename(STA_EUVI),11,2),strmid(file_basename(STA_EUVI),13,2))
obs_time_STB_EUVI=julday(strmid(file_basename(STB_EUVI),4,2),strmid(file_basename(STB_EUVI),6,2),strmid(file_basename(STB_EUVI),0,4),$
  strmid(file_basename(STB_EUVI),9,2),strmid(file_basename(STB_EUVI),11,2),strmid(file_basename(STB_EUVI),13,2))


for i =0,n_elements(SOHO_c2)-1 do begin
  ;----soho time convert
  t=lasco_readfits(SOHO_c2[i],hdr,/no_img,/silent)
  obs_time_SOHO_c2[i]=any2jul(str2utc(hdr.DATE_OBS))
  ;  print,header.DATE_obs
endfor

time_range=where(obs_time_STA_cor2 ge start_time and obs_time_STA_cor2 le end_time)

x=make_array(N_elements(time_range),/string);STA name
y=make_array(N_elements(time_range),/string) ;STB name
z=make_array(N_elements(time_range),/string) ;SOHO  name
EUVI_sta=make_array(N_elements(time_range),/string); STA euvi
EUVI_STB=make_array(N_elements(time_range),/string); STB, euvi
j=0
foreach i,time_range do begin
  x[j]=STA_cor2[i]
  y[j]=STB_cor2[i]
  temp=abs(obs_time_SOHO_c2 - obs_time_STA_cor2[i])
  dif=min(temp,pos)
  if (dif*86400D lt 600) then z[j]=SOHO_c2[pos] else z[j]='-1'
  t=min(abs(obs_time_STA_EUVI - obs_time_STA_cor2[i])*86400D,pos,/nan)
  EUVI_STA[j] =STA_EUVI[pos]
  t=min(abs(obs_time_STB_EUVI - obs_time_STA_cor2[i])*86400D,pos,/nan)
  EUVI_STB[j] = STB_EUVI[pos]
  j+=1
endforeach
t=min(abs(obs_time_STA_cor2 - background)*86400D,pos,/nan)
back_x=STA_cor2[pos]
t=min(abs(obs_time_STB_cor2 - background)*86400D,pos,/nan)
back_y=STB_cor2[pos]
t=min(abs(obs_time_SOHO_c2 - background)*86400D,pos,/nan)
back_z=SOHO_c2[pos]
if strmid(file_basename(back_x),11,2) eq '08' or strmid(file_basename(back_y),11,2) eq '08' then begin
	message,'you can not put this file as background,change you background time(not equal **08'
endif
; have gotten the name of three telescope
;---

openw,lun,'/Users/zigongxu/Documents/work/myWork2_GCS_releasetime/result/'+event_num+'/result_CME_'+tag1+'.dat',/get_lun,width=400
;tag=systim()
;hms_name='Cor2C2_'+strmid(tag,0,2)+strmid(tag,12,2)+strmid(tag,15,2)
printf,lun,'CME '+jul2any(start_time,/ccsds)+'--'+jul2any(end_time,/ccsds)+'   generated at  '+jul2any(systime(/jul),/ccsds)

;printf,lun,
printf,lun,'Time_SOHO','Time_STA/B','tele','longitude','latitude','Tilt','height','ratio','half angle','quality',format='(A-25,A-15,A-10,5A-10,A-15,A-10)'

for i=0,N_elements(x)-1 do begin
  ;  if z[i] ne '-1' then begin
  ;    ttt=lasco_readfits(z[i],head,/no_img,/silent)
  ;    print,file_basename(x[i]),file_basename(y[i]),head.DATE_OBS
  ;  endif
  ;
  if (z[i] eq '-1') then begin
    imEUVI_STA=bytscl(alog10(rebin(sccreadfits(EUVI_STA[i],hdr_EUVI_STA),512,512)),min=0,max=4.5)
    imEUVI_STB=bytscl(alog10(rebin(sccreadfits(EUVI_STB[i],hdr_EUVI_STB),512,512)),min=0,max=4.5)
    ;-----2017.7.22
    if file_exist(x[i]) then begin
        imsTA=read_STEREO_different_img_cor2(x[i],back_x,hdr_cor2=hdr_STA,cor2_name_all=STA_cor2)
;	imSTA=bytscl(alog10(sccreadfits(x[i],hdr_STA)-sccreadfits(back_x)),min=-13,max=-9)
    endif else begin
 	imSTA=read_STEREO_different_img_cor2(y[i],back_y,hdr_cor2=hdr_STA,cor2_name_all=STB_cor2)
;	imSTA=bytscl(alog10(sccreadfits(y[i],hdr_STA)-sccreadfits(back_y)),min=-13,max=-9)
    endelse
    
    if file_exist(y[i]) then begin
;       imSTB=bytscl(alog10(sccreadfits(y[i],hdr_STB)-sccreadfits(back_y)),min=-13,max=-9)
	imSTB=read_STEREO_different_img_cor2(y[i],back_y,hdr_cor2=hdr_STB,cor2_name_all=STB_cor2) 
   endif else begin
	imSTB=read_STEREO_different_img_cor2(x[i],back_x,hdr_cor2=hdr_STB,cor2_name_all=STA_cor2)
;       imSTB=bytscl(alog10(sccreadfits(x[i],hdr_STB)-sccreadfits(back_x)),min=-13,max=-9)
    endelse 
    print,'no corresponding SOHO data'
    rtsccguicloud_revised,imSTA,imSTB,hdr_STA,hdr_STB,imeuvia=imEUVI_STA,hdreuvia=hdr_EUVI_STA,imeuvib=imEUVI_STB,hdreuvib=hdr_EUVI_STB,$
      swire=swire,sgui=sgui,ocout=oc
    
    READ, quality, PROMPT='quality(1 means good; 2 means bad) '
    soho_replace_time=strmid(file_basename(x[i]),0,4)+'-'+strmid(file_basename(x[i]),4,2)+'-'+strmid(file_basename(x[i]),6,2)+'T'+$
      strmid(file_basename(x[i]),9,2)+':'+strmid(file_basename(x[i]),11,2)+':'+strmid(file_basename(x[i]),13,2)
    printf,lun,soho_replace_time,strmid(file_basename(x[i]),9,2)+':'+strmid(file_basename(x[i]),11,2)+':'+strmid(file_basename(x[i]),13,2),$
      'Cor2/C2',sgui.lon*rad2deg,sgui.lat*rad2deg,sgui.rot*rad2deg,sgui.hgt,sgui.rat,sgui.han*rad2deg,quality,format='(A-25,A-15,A-10,5F-10.3,F-15.3,I-10)'
    save,sgui,swire,oc,description='GCS result at SOHO time'+strmid(file_basename(x[i]),0,15),$
      filename='/Users/zigongxu/Documents/work/myWork2_GCS_releasetime/result/'+event_num+'/GCS_result/'+strmid(file_basename(x[i]),0,15)+tag1+'.sav'
      
  endif
  if (z[i] ne '-1') then begin
  
    imEUVI_STA=bytscl(alog10(rebin(sccreadfits(EUVI_STA[i],hdr_EUVI_STA),512,512)),min=0,max=4.5)
    ; did not use SCC_bytscl.pro
    imEUVI_STB=bytscl(alog10(rebin(sccreadfits(EUVI_STB[i],hdr_EUVI_STB),512,512)),min=0,max=4.5)
    
    imsoho=rebin(bytscl(alog10(lasco_readfits(z[i],hdr_soho)-lasco_readfits(back_z)),min=-12,max=-10),512,512)
    if file_exist(x[i]) then begin
    	imSTA=read_STEREO_different_img_cor2(x[i],back_x,hdr_cor2=hdr_STA,cor2_name_all=STA_cor2)
	 ; imSTA=bytscl(alog10(sccreadfits(x[i],hdr_STA)-sccreadfits(back_x)),min=-13,max=-9)
    endif else begin
	imSTA=read_STEREO_different_img_cor2(y[i],back_y,hdr_cor2=hdr_STA,cor2_name_all=STB_cor2)
      ;imSTA=bytscl(alog10(sccreadfits(y[i],hdr_STA)-sccreadfits(back_y)),min=-13,max=-9)
    endelse
    if file_exist(y[i]) then begin
	imSTB=read_STEREO_different_img_cor2(y[i],back_y,hdr_cor2=hdr_STB,cor2_name_all=STB_cor2)	
;       imSTB=bytscl(alog10(sccreadfits(y[i],hdr_STB)-sccreadfits(back_y)),min=-13,max=-9)
    endif else begin
	imSTB=read_STEREO_different_img_cor2(x[i],back_x,hdr_cor2=hdr_STB,cor2_name_al=STB_cor2)
    ;   imSTB=bytscl(alog10(sccreadfits(x[i],hdr_STB)-sccreadfits(back_x)),min=-13,max=-9)
    endelse
    
    print,file_basename(x[i]),file_basename(y[i]),hdr_soho.DATE_OBS
    rtsccguicloud_revised,imSTA,imSTB,hdr_STA,hdr_STB,imeuvia=imEUVI_STA,hdreuvia=hdr_EUVI_STA,$
      imeuvib=imEUVI_STB,hdreuvib=hdr_EUVI_STB,imlasco=imsoho,hdrlasco=hdr_soho,swire=swire,sgui=sgui,ocout=oc
    ;//deleted part
    if sgui.quit eq 1 then begin
      free_lun,lun
      print,'you quit this process'
      openr,lun,'/Users/zigongxu/Documents/work/myWork2_GCS_releasetime/result/'+event_num+'/result_CME_'+tag1+'.dat',/get_lun,/delete
      free_lun,lun
      return,0
    endif
    ;;///
    READ, quality, PROMPT='quality(1 means good; 2 means bad) '
    printf,lun,hdr_soho.DATE_OBS,strmid(file_basename(x[i]),9,2)+':'+strmid(file_basename(x[i]),11,2)+':'+strmid(file_basename(x[i]),13,2),$
      'Cor2/C2',sgui.lon*rad2deg,sgui.lat*rad2deg,sgui.rot*rad2deg,sgui.hgt,sgui.rat,sgui.han*rad2deg,quality,format='(A-25,A-15,A-10,5F-10.3,F-15.3,I-10)'
    ;--------------------
    ; just one time. if you want twice,
    save,sgui,swire,oc,description='GCS result at SOHO time'+hdr_soho.DATE_OBS,$
      filename='/Users/zigongxu/Documents/work/myWork2_GCS_releasetime/result/'+event_num+'/GCS_result/'+strmid(file_basename(x[i]),0,15)+tag1+'.sav'
    ;----------------------
  endif
endfor
printf,lun,'======================================= finished'
free_lun,lun
return,1
end
;--------------------------------------------------------
function Cor2_c3, STA_cor2_dir,STB_cor2_dir,SOHO_dir,STA_EUVI_dir,STB_EUVI_dir,background=background,start_time=start_time,end_time=end_time,event_num=event_num,tag=tag

if n_params() ne 5 then begin
  print,'the parameter number is incorrect, please restarte'
  return,-1
endif

if ~Keyword_set(background) then begin
  print,'you need to provide background time'
  return,-1
endif

if  ~keyword_set(start_time) then begin
  print,'you need to provide start time'
  return,-1
endif

if ~Keyword_set(end_time) then begin
  print,'you need to provide end time'
  return,-1
endif

if ~keyword_set(event_num) then begin 
  print,'you need to provide event number(like 20110308)'
  return,-1
endif

if ~keyword_set(tag) then begin 
  tag1='Cor2C3'
endif else begin 
  tag1='Cor2C3_'+tag
endelse
restore,'/Users/zigongxu/Documents/work/myWork2_GCS_releasetime/code/common/constant_define.sav',/ver

STA_cor2=file_search(STA_cor2_dir,'*fts')
STB_cor2=file_search(STB_cor2_dir,'*fts')
r=make_thename_identical(STA_cor2=STA_cor2,STB_cor2=STB_cor2)

obs_time_STA_cor2=make_array(n_elements(STA_cor2),/double)
obs_time_STB_cor2=make_array(n_elements(STB_cor2),/double)

SOHO_c3=file_search(SOHO_dir,'35*')
obs_time_SOHO_c3=make_array(n_elements(SOHO_C3),/double)
STA_EUVI=file_search(STA_EUVI_dir,'*fts')
STB_EUVI=file_search(STB_EUVI_dir,'*fts')

;----------------------------find the right time to fitting 
for i =0,n_elements(SOHO_c3)-1 do begin
  ;----soho time convert
  t=lasco_readfits(SOHO_c3[i],hdr,/no_img,/silent)
  obs_time_SOHO_c3[i]=any2jul(str2utc(hdr.DATE_OBS))
  ;  print,header.DATE_obs
endfor
;---
obs_time_STA_cor2=julday(strmid(file_basename(STA_cor2),4,2),strmid(file_basename(STA_cor2),6,2),strmid(file_basename(STA_cor2),0,4),$
  strmid(file_basename(STA_cor2),9,2),strmid(file_basename(STA_cor2),11,2),strmid(file_basename(STA_cor2),13,2))
obs_time_STB_cor2=julday(strmid(file_basename(STB_cor2),4,2),strmid(file_basename(STB_cor2),6,2),strmid(file_basename(STB_cor2),0,4),$
  strmid(file_basename(STB_cor2),9,2),strmid(file_basename(STB_cor2),11,2),strmid(file_basename(STB_cor2),13,2))
  
obs_time_STA_EUVI=julday(strmid(file_basename(STA_EUVI),4,2),strmid(file_basename(STA_EUVI),6,2),strmid(file_basename(STA_EUVI),0,4),$
  strmid(file_basename(STA_EUVI),9,2),strmid(file_basename(STA_EUVI),11,2),strmid(file_basename(STA_EUVI),13,2))
obs_time_STB_EUVI=julday(strmid(file_basename(STB_EUVI),4,2),strmid(file_basename(STB_EUVI),6,2),strmid(file_basename(STB_EUVI),0,4),$
  strmid(file_basename(STB_EUVI),9,2),strmid(file_basename(STB_EUVI),11,2),strmid(file_basename(STB_EUVI),13,2))



time_range=where(obs_time_STA_cor2 ge start_time and obs_time_STA_cor2 le end_time)

x=make_array(N_elements(time_range),/string);STA name
y=make_array(N_elements(time_range),/string) ;STB name
z=make_array(N_elements(time_range),/string) ;SOHO  name
EUVI_sta=make_array(N_elements(time_range),/string); STA euvi
EUVI_STB=make_array(N_elements(time_range),/string); STB, euvi
j=0
foreach i,time_range do begin
  x[j]=STA_cor2[i]
  y[j]=STB_cor2[i]
  temp=abs(obs_time_SOHO_c3 - obs_time_STA_cor2[i])
  dif=min(temp,pos)
  if (dif*86400D lt 600) then z[j]=SOHO_c3[pos] else z[j]='-1'
  t=min(abs(obs_time_STA_EUVI - obs_time_STA_cor2[i])*86400D,pos,/nan)
  EUVI_STA[j] =STA_EUVI[pos]
  t=min(abs(obs_time_STB_EUVI - obs_time_STA_cor2[i])*86400D,pos,/nan)
  EUVI_STB[j] = STB_EUVI[pos]
  j+=1
endforeach
t=min(abs(obs_time_STA_cor2 - background)*86400D,pos,/nan)
back_x=STA_cor2[pos]
t=min(abs(obs_time_STB_cor2 - background)*86400D,pos,/nan)
back_y=STB_cor2[pos]
t=min(abs(obs_time_SOHO_c3 - background)*86400D,pos,/nan)
back_z=SOHO_c3[pos]
; have gotten the name of three telescope
;---
openw,lun,'/Users/zigongxu/Documents/work/myWork2_GCS_releasetime/result/'+event_num+'/result_CME_'+tag1+'.dat',/get_lun,width=400

printf,lun,'CME '+jul2any(start_time,/ccsds)+'--'+jul2any(end_time,/ccsds)+'   generated at  '+jul2any(systime(/jul),/ccsds)

;printf,lun,
printf,lun,'Time_SOHO','Time_STA/B','tele','longitude','latitude','Tilt','height','ratio','half angle','quality',format='(A-25,A-15,A-10,5A-10,A-15,A-10)'

for i=0,N_elements(x)-1 do begin
  ;  if z[i] ne '-1' then begin
  ;    ttt=lasco_readfits(z[i],head,/no_img,/silent)
  ;    print,file_basename(x[i]),file_basename(y[i]),head.DATE_OBS
  ;  endif
  ;
  if (z[i] eq '-1') then begin
    imEUVI_STA=bytscl(alog10(rebin(sccreadfits(EUVI_STA[i],hdr_EUVI_STA),512,512)),min=0,max=4.5)
    imEUVI_STB=bytscl(alog10(rebin(sccreadfits(EUVI_STB[i],hdr_EUVI_STB),512,512)),min=0,max=4.5)
    
    if file_exist(x[i]) then begin
	imsTA=read_stereo_different_img_cor2(x[i],back_x,hdr_cor2=hdr_STA,cor2_name_all=STA_cor2)
	 ; imSTA=bytscl(alog10(sccreadfits(x[i],hdr_STA)-sccreadfits(back_x)),min=-13,max=-9)
    endif else begin
	imSTA=read_STEREO_different_img_cor2(y[i],back_y,hdr_cor2=hdr_STA,cor2_name_all=STB_cor2)
 ;     imSTA=bytscl(alog10(sccreadfits(y[i],hdr_STA)-sccreadfits(back_y)),min=-13,max=-9)
    endelse
    if file_exist(y[i]) then begin
     	imSTB=read_STEREO_different_img_cor2(y[i],back_y,hdr_cor2=hdr_STB,cor2_name_all=STB_cor2)
	;  imSTB=bytscl(alog10(sccreadfits(y[i],hdr_STB)-sccreadfits(back_y)),min=-13,max=-9)
    endif else begin
	imSTB=read_STEREO_different_img_cor2(x[i],back_x,hdr_cor2=hdr_STB,cor2_name_all=STA_cor2)
 ;      imSTB=bytscl(alog10(sccreadfits(x[i],hdr_STB)-sccreadfits(back_x)),min=-13,max=-9)
    endelse
    print,'no corresponding SOHO data'
    rtsccguicloud_revised,imSTA,imSTB,hdr_STA,hdr_STB,imeuvia=imEUVI_STA,hdreuvia=hdr_EUVI_STA,imeuvib=imEUVI_STB,hdreuvib=hdr_EUVI_STB,$
      swire=swire,sgui=sgui,ocout=oc
    READ, quality, PROMPT='quality(1 means good; 2 means bad) '
    soho_replace_time=strmid(file_basename(x[i]),0,4)+'-'+strmid(file_basename(x[i]),4,2)+'-'+strmid(file_basename(x[i]),6,2)+'T'+$
      strmid(file_basename(x[i]),9,2)+':'+strmid(file_basename(x[i]),11,2)+':'+strmid(file_basename(x[i]),13,2)
    printf,lun,soho_replace_time,strmid(file_basename(x[i]),9,2)+':'+strmid(file_basename(x[i]),11,2)+':'+strmid(file_basename(x[i]),13,2),$
      'Cor2/C3',sgui.lon*rad2deg,sgui.lat*rad2deg,sgui.rot*rad2deg,sgui.hgt,sgui.rat,sgui.han*rad2deg,quality,format='(A-25,A-15,A-10,5F-10.3,F-15.3,I-10)'
    save,sgui,swire,oc,description='GCS result at SOHO time'+strmid(file_basename(x[i]),0,15),$
      filename='/Users/zigongxu/Documents/work/myWork2_GCS_releasetime/result/'+event_num+'/GCS_result/'+strmid(file_basename(x[i]),0,15)+tag1+'.sav'
      
  endif
  if (z[i] ne '-1') then begin
  
    imEUVI_STA=bytscl(alog10(rebin(sccreadfits(EUVI_STA[i],hdr_EUVI_STA),512,512)),min=0,max=4.5)
    ; did not use SCC_bytscl.pro
    imEUVI_STB=bytscl(alog10(rebin(sccreadfits(EUVI_STB[i],hdr_EUVI_STB),512,512)),min=0,max=4.5)
    
    imsoho=rebin(bytscl(alog10(lasco_readfits(z[i],hdr_soho)-lasco_readfits(back_z)),min=-12,max=-10),512,512)
    if file_exist(x[i]) then begin
 	imSTA=read_STEREO_different_img_cor2(x[i],back_x,hdr_cor2=hdr_STA,cor2_name_all=STA_cor2) 
;    imSTA=bytscl(alog10(sccreadfits(x[i],hdr_STA)-sccreadfits(back_x)),min=-13,max=-9)
    endif else begin
	imSTA=read_STEREO_different_img_cor2(y[i],back_y,hdr_cor2=hdr_STA,cor2_name_all=STB_cor2)
;      imSTA=bytscl(alog10(sccreadfits(y[i],hdr_STA)-sccreadfits(back_y)),min=-13,max=-9)
    endelse
    if file_exist(y[i]) then begin
	imSTB=read_STEREO_different_img_cor2(y[i],back_y,hdr_cor2=hdr_STB,cor2_name_all=STB_cor2)
 ;      imSTB=bytscl(alog10(sccreadfits(y[i],hdr_STB)-sccreadfits(back_y)),min=-13,max=-9)
    endif else begin
	imSTB=read_STEREO_different_img_cor2(x[i],back_x,hdr_cor2=hdr_STB,cor2_name_all=STA_cor2)
     ;  imSTB=bytscl(alog10(sccreadfits(x[i],hdr_STB)-sccreadfits(back_x)),min=-13,max=-9)
    endelse    
    print,file_basename(x[i]),file_basename(y[i]),hdr_soho.DATE_OBS
    rtsccguicloud_revised,imSTA,imSTB,hdr_STA,hdr_STB,imeuvia=imEUVI_STA,hdreuvia=hdr_EUVI_STA,$
      imeuvib=imEUVI_STB,hdreuvib=hdr_EUVI_STB,imlasco=imsoho,hdrlasco=hdr_soho,swire=swire,sgui=sgui,ocout=oc
     
    ;//deleted part
    if sgui.quit eq 1 then begin
      free_lun,lun
      openr,lun,'/Users/zigongxu/Documents/work/myWork2_GCS_releasetime/result/'+event_num+'/result_CME_'+tag1+'.dat',/get_lun,/delete
      free_lun,lun
      return,0
    endif
    ;;///
    READ, quality, PROMPT='quality(1 means good; 2 means bad) '
    printf,lun,hdr_soho.DATE_OBS,strmid(file_basename(x[i]),9,2)+':'+strmid(file_basename(x[i]),11,2)+':'+strmid(file_basename(x[i]),13,2),$
      'Cor2/C3',sgui.lon*rad2deg,sgui.lat*rad2deg,sgui.rot*rad2deg,sgui.hgt,sgui.rat,sgui.han*rad2deg,quality,format='(A-25,A-15,A-10,5F-10.3,F-15.3,I-10)'
    ;--------------------
    ; just one time. if you want twice,
    save,sgui,swire,oc,description='GCS result at SOHO time'+hdr_soho.DATE_OBS,$
      filename='/Users/zigongxu/Documents/work/myWork2_GCS_releasetime/result/'+event_num+'/GCS_result/'+strmid(file_basename(x[i]),0,15)+tag1+'.sav'
    ;----------------------
  endif
endfor

printf,lun,'======================================= finished'
free_lun,lun

return,1
end


;---------------------

pro analysis_5,event_num,background=background,start_time=start_time,end_time=end_time,GCS_data_save=GCS_data_save
;;
;
;;name:analysis_5
;
;call example:
;     
;explanation:
;   quality tag:
;   11:means the most beautiful image and the most precise result
;   1: the second best data quality
;   2: the second worst data quality, the uncertainty is bigger then 1; much bigger than 11; probably bigger than 0 or smaller than 0;
;      no lack of data
;   0: lack of data,SOHO lack ,while STEREO is exsit;like this; it means the result has large uncertainty
;   22: means the result can not be used in other analysis
;       
;
;purpose: CME fitting one by one and save the result image and result_cme.data
;modification history:
;start xuzigong 2017.6.27?
;
;2017.6.29, add keywords: background,start_time, and end_time and their check code 
;2017.6.30  add the judgement of data miss
;2017.7.3   add the keyword GCS_data_Save
;2017.7.21  add the process that delete the data file when we quit the GCS GUI
;2017.7.25  when SOHO data was absent,use STEREO time as SOHO time, replacing '-1'
;
;---------------------------------


COMPILE_OPT IDL2
temp=jul2any(systime(/jul),/ccsds)
tag=strmid(temp,2,2)+strmid(temp,5,2)+strmid(temp,8,2)+strmid(temp,10,3)+strmid(temp,14,2)
;tag='1240'

if not keyword_set(GCS_data_save) then GCS_data_save='/Volumes/Science_dat/work_2/'

STA_cor2_dir=GCS_data_save+event_num+'/STEREO_level_1.1/a/cor2'
STA_cor1_dir=GCS_data_save+event_num+'/STEREO_level_1.1/a/cor1'
STB_cor2_dir=GCS_data_save+event_num+'/STEREO_level_1.1/b/cor2'
STB_cor1_dir=GCS_data_save+event_num+'/STEREO_level_1.1/a/cor1'
SOHO_dir=GCS_data_save+event_num+'/SOHO'
;---EUVI  need to be prepared
STA_EUVI_dir=GCS_data_save+event_num+'/STEREO_level_1.1/a/euvi'
STB_EUVI_dir=GCS_data_save+event_num+'/STEREO_level_1.1/b/euvi'
;
;STA_cor2_obs_time=
;print,file_basename(STA_cor2)
STA_cor1=file_search(STA_cor1_dir,'*fts')
obs_time_STA_cor1=make_array(N_elements(STA_cor1),/double)
;print,'-----------'
;print,file_basename(STB_cor2)
;print,'-----------'
STB_cor1=file_search(STB_cor1_dir,'*fts')
obs_time_STB_cor1=make_array(n_elements(STB_cor1),/double)
;print,'---------
for i =0,n_elements(SOHO_c2)-1 do begin
;----soho time convert
   t=lasco_readfits(SOHO_c2[i],hdr,/no_img,/silent)
   obs_time_SOHO_c2[i]=any2jul(str2utc(hdr.DATE_OBS))
 ;  print,header.DATE_obs
 endfor
;----
obs_time_STA_cor1=julday(strmid(file_basename(STA_cor1),4,2),strmid(file_basename(STA_cor1),6,2),strmid(file_basename(STA_cor1),0,4),$
  strmid(file_basename(STA_cor1),9,2),strmid(file_basename(STA_cor1),11,2),strmid(file_basename(STA_cor1),13,2))
obs_time_STB_cor1=julday(strmid(file_basename(STB_cor1),4,2),strmid(file_basename(STB_cor1),6,2),strmid(file_basename(STB_cor1),0,4),$
  strmid(file_basename(STB_cor1),9,2),strmid(file_basename(STB_cor1),11,2),strmid(file_basename(STB_cor1),13,2))
;-----------
if ~keyword_set(background) then begin
  print,'warning: there is not a background time,you should supply background=background'
  background=julday(3,7,2010,19,45,0)
endif

if ~keyword_set(start_time) then begin
  print,'warning: there is not a start time,you should supply start_time=*****'
  start_time=julday(3,7,2011,19,50,0)
endif
if ~keyword_set(end_time) then begin
  print,'warning: there is not a edn time,you should supply end_time=*****'
  end_time=julday(3,7,2011,22,0,0)
endif

result=Cor2_c2(STA_cor2_dir,STB_cor2_dir,SOHO_dir,STA_EUVI_dir,STB_EUVI_dir,background=background,start_time=start_time,end_time=end_time,event_num=event_num,tag=tag)

result=Cor2_c3(STA_cor2_dir,STB_cor2_dir,SOHO_dir,STA_EUVI_dir,STB_EUVI_dir,background=background,start_time=start_time,end_time=end_time,event_num=event_num,tag=tag)

gif_gcs,event_num,delay_time=50,tag=tag

end


