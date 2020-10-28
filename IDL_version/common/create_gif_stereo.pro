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
;Modification history:
; 2017.9.20  first edited as an individual file
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
      plot_image,bytscl(alog10(im1-im),min=min,max=max)
    endif else begin 
      if name[i] eq name[where_08[0]] then begin
         plot_image,bytscl(alog10(im1-im),min=min,max=max)
         print,'you should give a background data of 08'
      endif else begin
         plot_image,bytscl(alog10(im1-im_08),min=min,max=max)
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