
;procedure to process STEREO data from level 0.5(raw data) to levevl 1 using Secchi_prep.pro
;
;
;
;Inpur example: a_cor1_dir='/Volumes/Science_dat/work_2/20110308/STEREO/secchi/L0/a/seq/cor1'
;               a_cor2_dir='/Volumes/Science_dat/work_2/20110308/STEREO/secchi/L0/a/img/cor2'
;               b_cor1_dir='/Volumes/Science_dat/work_2/20110308/STEREO/secchi/L0/b/seq/cor1'
;               b_cor2_dir='/Volumes/Science_dat/work_2/20110308/STEREO/secchi/L0/b/img/cor2'
;               a_EUVI_dir='/Volumes/Science_dat/work_2/20110308/STEREO/secchi/L0/a/img/euvi'
;               b_EUVI_dir='/Volumes/Science_dat/work_2/20110308/STEREO/secchi/L0/b/img/euvi'
;               save_dir  ='/Volumes/Science_dat/work_2/20110308/STEREO_level_1.1'
;               
;Modification history:
;2017.7.11 add keyword EUVI as the tag of preparation only for EUVI data
;2017.9.20 add check mechanism for the lack of data like STB; Usage: make dir B equals vacancy
;


pro my_prep_for_stereo,a_cor1_dir,a_cor2_dir,b_cor1_dir,b_cor2_dir,a_EUVI_dir,b_EUVI_dir,save_dir,EUVI=EUVI
  ;----STA cor1
  ;dir='/Volumes/asxzg/data_work2/secchi/L0/a/seq/cor1/20100814'
  
  if Keyword_set(EUVI) then goto,EUVI_START
  
  name=file_search(a_cor1_dir,'*fts') 
  i=0
  yes=0
  while (i lt n_elements(name) and (name[0] ne '')) do begin
    while ((~yes)and(i+2 lt N_elements(name))) do begin
      name_temp=[name[i],name[i+1],name[i+2]]
      name_temp2=float(strmid(file_basename(name_temp),9,6))
      dt1=name_temp2[1]-name_temp2[0]
      dt2=name_temp2[2]-name_temp2[1]
      if (dt1 lt 60 ) and (dt2 lt 60) then yes=1 else i+=1
    endwhile
    print,file_basename(name_temp)
    i=i+3
    yes=0
    ;------
    ;process level 0 and save them
    ;normalised to 1 seconde exporstion time and put smask on for cor1 seq data
    ;seq data
    secchi_prep,name_temp,hdr,im,/polariz_on,/rotate_on,/PRECOMMCORRECT_ON,/rotinterp_on,/silent,smask_on=1,outsize=512
    ; save_dir='/Users/zigongxu/Documents/work/myWork2_GCS_releasetime/data/20100814/STEREO_level_1.1/a/cor1'
    sccwritefits,save_dir+'/a/cor1/'+file_basename(name_temp[0]),im,hdr
  endwhile
  
  print,'-----STA cor1 is over'
  wait,2
 
  ;----STB cor1
  ;dir='/Volumes/asxzg/data_work2/secchi/L0/b/seq/cor1/20100814'
  
  name=file_search(b_cor1_dir,'*fts')
  i=0
  yes=0
  while (i lt n_elements(name) and (name[0] ne '')) do begin
    while ((~yes)and(i+2 lt N_elements(name))) do begin
      name_temp=[name[i],name[i+1],name[i+2]]
      name_temp2=float(strmid(file_basename(name_temp),9,6))
      dt1=name_temp2[1]-name_temp2[0]
      dt2=name_temp2[2]-name_temp2[1]
      if (dt1 lt 60 ) and (dt2 lt 60) then yes=1 else i+=1
    endwhile
    print,file_basename(name_temp)
    i=i+3
    yes=0
    ;------
    ;process level 0 and save them
    ;normalised to 1 seconde exporstion time and put smask on for cor1 seq data
    ;seq data
    secchi_prep,name_temp,hdr,im,/polariz_on,/rotate_on,/PRECOMMCORRECT_ON,/rotinterp_on,/silent,smask_on=1,outsize=512
    ;save_dir='/Users/zigongxu/Documents/work/myWork2_GCS_releasetime/data/20100814/STEREO_level_1.1/b/cor1'
    sccwritefits,save_dir+'/b/cor1/'+file_basename(name_temp[0]),im,hdr
  endwhile
  
  print,'---------------STB cor1 is over'
  wait,2
  ;--cor 2 STA,STB
  ;
  ;dir='/Volumes/asxzg/data_work2/secchi/L0/a/img/cor2/20100814'
  name_a=file_search(a_cor2_dir,'*fts')
  ;save_dir='/Users/zigongxu/Documents/work/myWork2_GCS_releasetime/data/20100814/STEREO_level_1.1/a/cor2'
  if (name_a[0] ne '') then begin
  for i=0,n_elements(name_a)-1 do begin
    secchi_prep,name_a[i],head_a,image_a,/rotate_on,/PRECOMMCORRECT_ON,/rotinterp_on,/silent,outsize=512,smask_on=1
    sccwritefits,save_dir+'/a/cor2/'+file_basename(name_a[i]),image_a,head_a
  endfor
  endif
  ;dir='/Volumes/asxzg/data_work2/secchi/L0/b/img/cor2/20100814'
  name_b=file_search(b_cor2_dir,'*fts')
  ;save_dir_b='/Users/zigongxu/Documents/work/myWork2_GCS_releasetime/data/20100814/STEREO_level_1.1/b/cor2'
  if (name_b[0] ne '') then begin
  for i =0,n_elements(name_b)-1 do begin
    secchi_prep,name_b[i],head_b,image_b,/rotate_on,/PRECOMMCORRECT_ON,/rotinterp_on,/silent,outsize=512,smask_on=1
    sccwritefits,save_dir+'/b/cor2/'+file_basename(name_b[i]),image_b,head_b
  endfor
  endif
  ;----EUVI
  EUVI_START: print,'just process EUVI data'
  
  name_EUVI_a=file_search(a_EUVI_dir,'*fts')
  if name_EUVI_a[0] ne '' then begin
  secchi_prep,name_EUVI_a,head,image,/PRECOMMCORRECT_ON,outsize=512,/silent,$
    savepath=save_dir+'/a/EUVI',/write_fts
  endif
  name_EUVI_b=file_search(b_EUVI_dir,'*fts')
  if name_euvi_b[0] ne '' then begin
  secchi_prep,name_EUVI_b,head,image,/PRECOMMCORRECT_ON,outsize=512,/silent,$
    savepath=save_dir+'/b/EUVI',/write_fts
  endif
  print,'all is over'
  
end


