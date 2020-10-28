
;
;call exmaple:IDL> prep_for_special_event,'20110804'
;
;
pro prep_for_special_event,event_num,_extra=_extra
  a_cor1_dir='/Volumes/Science_dat/work_2/'+event_num+'/STEREO/secchi/L0/a/seq/cor1'
  a_cor2_dir='/Volumes/Science_dat/work_2/'+event_num+'/STEREO/secchi/L0/a/img/cor2'
  b_cor1_dir='/Volumes/Science_dat/work_2/'+event_num+'/STEREO/secchi/L0/b/seq/cor1'
  b_cor2_dir='/Volumes/Science_dat/work_2/'+event_num+'/STEREO/secchi/L0/b/img/cor2'
  a_EUVI_dir='/Volumes/Science_dat/work_2/'+event_num+'/STEREO/secchi/L0/a/img/euvi'
  b_EUVI_dir='/Volumes/Science_dat/work_2/'+event_num+'/STEREO/secchi/L0/b/img/euvi'
  save_dir  ='/Volumes/Science_dat/work_2/'+event_num+'/STEREO_level_1.1'
  
  if not file_test('/Volumes/Science_dat/work_2/'+event_num+'/STEREO_level_1.1/a') then begin
        spawn,'mkdir /Volumes/Science_dat/work_2/'+event_num+'/STEREO_level_1.1/a'
        spawn,'mkdir /Volumes/Science_dat/work_2/'+event_num+'/STEREO_level_1.1/b'
        spawn,'mkdir /Volumes/Science_dat/work_2/'+event_num+'/STEREO_level_1.1/a/cor1'
        spawn,'mkdir /Volumes/Science_dat/work_2/'+event_num+'/STEREO_level_1.1/a/cor2'
        spawn,'mkdir /Volumes/Science_dat/work_2/'+event_num+'/STEREO_level_1.1/a/EUVI'
        spawn,'mkdir /Volumes/Science_dat/work_2/'+event_num+'/STEREO_level_1.1/b/cor1'
        spawn,'mkdir /Volumes/Science_dat/work_2/'+event_num+'/STEREO_level_1.1/b/cor2'
        spawn,'mkdir /Volumes/Science_dat/work_2/'+event_num+'/STEREO_level_1.1/b/EUVI'
  endif

  my_prep_for_stereo,a_cor1_dir,a_cor2_dir,b_cor1_dir,b_cor2_dir,a_EUVI_dir,b_EUVI_dir,save_dir,_extra=_extra
  if file_test('/Volumes/Science_dat/work_2/'+event_num+'/SOHO_0.5') then pre_for_SOHO_level_0_5,event_num
  quicklook_CME,event_num
end
