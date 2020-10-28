function create_gif_STEREO,dir=dir,telescope=tele,type=type,gif_name=gif_name,min=min,max=max
;name: create_gif_stereo
;Purpose : as the title say
;parameter explanation:
;       dir
;       telescope
;       type
;       gif_nae
;       min: the range of bytscl after alog10, in other word, the contrast of the photo
;       max
;  
  ;dir='/Users/zigongxu/Documents/work/myWork2_GCS_releasetime/data/20100814/STEREO_level_1.1/b/cor2'
  name=file_search(dir,'*fts')
  if (type ne 'cor2') then begin 
     im=sccreadfits(name[0],hdr)
  endif else begin
     if strmid(file_basename(name[0]),11,2) ne '08' then im=sccreadfits(name[0],hdr) else im=sccreadfits(name[1],hdr)
  endelse
  tag_08=strmid(file_basename(name),11,2)
  where_08=where(tag_08 eq '08')
  im_08=sccreadfits(name[where_08[0]],hdr_08)
  ;gif_name='/Users/zigongxu/Documents/work/myWork2_GCS_releasetime/Stereo_a.gif'
  ;gif_name='/Users/zigongxu/Documents/work/myWork2_GCS_releasetime/Stereo_b.gif'
 ; set_plot,'ps'
  set_plot,'x'
  cgdisplay,512,512
  !p.multi=0
  for i =1,n_elements(name)-1 do begin
   ; if (strmid(file_basename(name[i]),11,2) eq '08') then continue
    im1=sccreadfits(name[i],hdr1)
    if strmid(file_basename(name[i]),11,2) ne '08' then begin
      ;plot_image,bytscl(alog10(im1-im),min=min,max=max)
      plot_image,bytscl((im1-im);,min=min,max=max)

  print,max((im1-im)),min((im1-im)),N_elements(where((im1-im) lt 0))

    endif else begin 
      if name[i] eq name[where_08[0]] then begin
         ;plot_image,bytscl(alog10(im1-im),min=min,max=max)
         plot_image,bytscl((im1-im),min=min,max=max)

  print,max((im1-im)),min((im1-im))

         print,'you should give a background data of 08'
      endif else begin
         ;plot_image,bytscl(alog10(im1-im_08),min=min,max=max)
         plot_image,bytscl((im1-im_08),min=min,max=max)

  print,max((im1-im_08)),min((im1-im_08)),N_elements(where((im1-im_08) lt 0))

      endelse
    endelse    
    ;xyouts,0.2,0.14,'STA'+strmid(FILE_BASENAME(NAME[I]),0,15),/NORMAL,charsize=1.5
    xyouts,0.45,0.03,tele+strmid(FILE_BASENAME(NAME[I]),0,15),/NORMAL,charsize=1.5
    WRITE_GIF, Gif_name, TVRD(), DELAY_TIME=0.5, /MULTIPLE, REPEAT_COUNT = 0
    print,file_basename(name[i])
    ;im=im1
  endfor
  WRITE_GIF, Gif_name, /CLOSE
  return,1
end

function create_gif_soho,dir=dir,gif_dir=gif_dir,min=min,max=max
;name: create_gif_soho
;purpose
;parameter explanation
;modification history
;xuzigong 2017.6.25 15:30
;-c2
c2_filename=file_search(dir,'25*',count=count)
if (count ne 0) then begin
gif_name=gif_dir+'/SOHO_c2.gif'
cgdisplay,512,512
im=lasco_readfits(c2_filename[0],hdr)
for i=1, n_elements(c2_filename)-1 do begin
  img=lasco_readfits(c2_filename[i],head)
  ;plot_image,bytscl(alog10(img-im),min=min,max=max);,title=strmid(hdr1.DATE_OBS,10);,charsize=1.5
  plot_image,bytscl((img-im),min=min,max=max);,title=strmid(hdr1.DATE_OBS,10);,charsize=1.5

  print,max((img-im)),min((img-im)),N_elements(where((img-im) lt 0))
 
  xyouts,0.4,0.03,'SOHO_c2 '+head.DATE_OBS,/normal,charsize=1.5
  write_gif,gif_name,TVRD(),DELAY_TIME=0.5,/MULTIPLE, REPEAT_count=0
  print,file_basename(c2_filename[i])
endfor
  WRITE_GIF,Gif_name,/close
endif
;-c3
c3_filename=file_search(dir,'35*',count=count)
if (count ne 0) then begin
  gif_name=gif_dir+'/SOHO_c3.gif'
  cgdisplay,512,512
  im=lasco_readfits(c3_filename[0],hdr)
  for i =1, n_elements(c3_filename)-1 do begin
    img=lasco_readfits(c3_filename[i],head)
    ;plot_image,bytscl(alog10(img-im),min=min,max=max);,title=strmid(hdr1.DATE_OBS,10);,charsize=1.5
    plot_image,bytscl((img-im),min=min,max=max);,title=strmid(hdr1.DATE_OBS,10);,charsize=1.5
   
    print,max((img-im)),min((img-im)),N_elements(where((img-im) lt 0))
   
    xyouts,0.4,0.03,'SOHO_c3 '+head.DATE_OBS,/normal,charsize=1.5
    write_gif,gif_name,TVRD(),DELAY_TIME=0.5,/MULTIPLE, REPEAT_count=0
    print,file_basename(c3_filename[i])
  endfor
  write_gif,gif_name,/close
endif
return ,1
end
pro quicklook_CME_,event_num

;name: quicklook_CME
;purpose: a quicklook function of CME including SOHO/lascl and STEREO and create GIF 
;
;function including ；
;       create_gif_soho
;       create_gif_stereo
;cataloge
;   ? common
;
;Modification history: 
;xuzigong 2017.6.25
;2017.6.29  add event_num and copy them all to commmon cataloge; just save one file named quicklook_cme
;
;future improvement
; add time range?
;
;time=20110308 events
loadct,0
!p.multi=0
STA_cor2_dir='/Volumes/Science_dat/work_2/'+event_num+'/STEREO_level_1.1/a/cor2'
STA_cor1_dir='/Volumes/Science_datwork_2//'+event_num+'/STEREO_level_1.1/a/cor1'
STB_cor2_dir='/Volumes/Science_dat/work_2/'+event_num+'/STEREO_level_1.1/b/cor2'
STB_cor1_dir='/Volumes/Science_dat/work_2/'+event_num+'/STEREO_level_1.1/b/cor1'
;---this is a changeable part
save_dir='/Users/zigongxu/Documents/work/myWork2_GCS_releasetime/image/'+event_num
save_dir_STA_cor2_gif=save_dir+'/STA_cor2.gif'
save_dir_STA_cor1_gif=save_dir+'/STA_cor1.gif'
save_dir_STB_cor2_gif=save_dir+'/STB_cor2.gif'
save_dir_STB_cor1_gif=save_dir+'/STB_cor1.gif'
t=create_gif_stereo(dir=sta_cor2_dir,telescope='STA',type='cor2',gif_name=save_dir_STA_cor2_gif,min=-1e-8,max=1e-8)
t=create_gif_stereo(dir=sta_cor1_dir,telescope='STA',type='cor1',gif_name=save_dir_STA_cor1_gif,min=-1e-8,max=1e-8)
t=create_gif_stereo(dir=stb_cor2_dir,telescope='STB',type='cor2',gif_name=save_dir_stb_cor2_gif,min=-1e-8,max=1e-8)
t=create_gif_stereo(dir=stb_cor1_dir,telescope='STB',type='cor1',gif_name=save_dir_stb_cor1_gif,min=-1e-8,max=1e-8)
;----
SOHO_dir='/Volumes/Science_dat/work_2/'+event_num+'/SOHO'
soho_gif_dir='/Users/zigongxu/Documents/work/myWork2_GCS_releasetime/image/'+event_num
t=create_gif_soho(dir=SOHO_dir,gif_dir=soho_gif_dir,min=-1e-10,max=1e-10)
end
