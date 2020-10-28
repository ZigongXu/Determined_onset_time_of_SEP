;procedure to reduce SOHO data to level 1
;


pro pre_for_SOHO_level_0_5,event_num,save_dir=save_dir,data_dir=data_dir

if not keyword_set(save_dir) then save_dir='/Volumes/Science_dat/work_2/'+event_num+'/SOHO'
if not keyword_set(data_dir) then data_dir='/Volumes/Science_dat/work_2/'+event_num+'/SOHO_0.5'

name_list=file_search(data_dir,'*fts')
for i=0,n_elements(name_list)-1 do begin
  reduce_level_1,name_list[i],savedir=save_dir
endfor


end

