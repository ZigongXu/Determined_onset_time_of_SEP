
pro define_color_for_GCS_gif
  ;called after GCS fitting
  ;name: define_color_for_GCS_gif
  ;purpose: a color table in which 255=green for GCS wire plot
  common color_code,r,g,b
  r=bindgen(256)
  r[255]=0
  g=bindgen(256)
  b=bindgen(256)
  b[255]=0
end
function made_gif_sta,gif_sta,sgui,swire,delay_time=delay_time
  ;name:made_gif_STA
  ;purpose: make a stereo a gif figure
  common  color_code
  tvlct,r,g,b
  if ~keyword_set(delay_time) then delay_time=0.5
  sgui.ima=bytscl(sgui.ima,top=254)
  sgui.ima[where(swire.sa.im eq 1.0)]=255
  Write_gif,gif_sta,sgui.ima,r,g,b,DELAY_TIME=delay_time,/MULTIPLE, REPEAT_count=0
  return,1
end
function made_gif_stb,gif_stb,sgui,swire,delay_time=delay_time
  ;name: made_gif_stb
  ;purpose: make a stereo B gif figure
  common  color_code
  tvlct,r,g,b
  if ~keyword_set(delay_time) then delay_time=0.5
  sgui.imb=bytscl(sgui.imb,top=254)
  sgui.imb[where(swire.sb.im eq 1.0)]=255
  write_gif,gif_stb,sgui.imb,r,g,b,DELAY_TIME=delay_time,/MULTIPLE, REPEAT_count=0
  return,1
end

function made_gif_soho,gif_soho,sgui,swire,delay_time=delay_time
  ;name:made_gif_soho
  ;purpose: make a soho gif figure
  common  color_code
  tvlct,r,g,b
  if ~keyword_set(delay_time) then delay_time=0.5
  if ~tag_exist(swire,'slasco') then return,-1
  sgui.imlasco=bytscl(sgui.imlasco,top=254)
  sgui.imlasco[where(swire.slasco.im eq 1.0)]=255
  write_gif,gif_soho,sgui.imlasco,r,g,b,DELAY_TIME=delay_time,/MULTIPLE, REPEAT_count=0
  return,1
end

pro gif_gcs,event_num,delay_time=delay_time,tag=tag
  ;Name: gif_gcs
  ;
  ;
  ;Purpose: this is special gif made procedure when you finish you GCS fitting process using analysis_5.pro?
  ;
  ;
  ;catalogue:
  ;~~/common
  ;
  ;Modification history:
  ;xuzigong 2017.6.27 15:58
  ;2017.7.3  change the original name create_gif_GCS to gif_gcs and remember that the name of procedure should not consist capital letter because the compile reason 
  ;
  ;
  ;
  COMPILE_OPT IDL2
  define_color_for_GCS_gif
  common color_code,r,g,b
  if ~keyword_set(delay_time) then delay_time=50
  if ~keyword_set(tag) then tag=''
  tvlct,r,g,b
  dir='/Users/zigongxu/Documents/work/myWork2_GCS_releasetime/result/'+event_num+'/GCS_result'
  name_list_Cor2C2=file_search(dir,'*Cor2C2*'+tag+'*sav')
  if name_list_Cor2C2[0] eq '' then return
  name_list_Cor2C3=file_search(dir,'*Cor2C3*'+tag+'*sav')
  if name_list_cor2C3[0] eq '' then return
  gif_STA_Cor2C2='/Users/zigongxu/Documents/work/myWork2_GCS_releasetime/image/'+event_num+'/CME_fitting_map/STA_Cor2C2_'+tag+'.gif'
  gif_STB_Cor2C2='/Users/zigongxu/Documents/work/myWork2_GCS_releasetime/image/'+event_num+'/CME_fitting_map/STB_Cor2C2_'+tag+'.gif'
  gif_SOHO_Cor2C2='/Users/zigongxu/Documents/work/myWork2_GCS_releasetime/image/'+event_num+'/CME_fitting_map/SOHO_Cor2C2_'+tag+'.gif'
  
  for i=0,n_elements(name_list_Cor2C2)-1 do begin
    restore,name_list_Cor2C2[i]
    t=made_gif_sta(gif_sta_cor2c2,sgui,swire,delay_time=delay_time)
    delvar,sgui,swire
  endfor
  write_gif,gif_STA_Cor2C2,/close
  for i=0,n_elements(name_list_Cor2C2)-1 do begin
    restore,name_list_Cor2C2[i]
    t=made_gif_stb(gif_stb_cor2c2,sgui,swire,delay_time=delay_time)
    delvar,sgui,swire
  endfor
  write_gif,gif_STB_Cor2C2,/close
  for i=0,n_elements(name_list_Cor2C2)-1 do begin
    restore,name_list_Cor2C2[i]
    t=made_gif_soho(gif_soho_cor2c2,sgui,swire,delay_time=delay_time)
    delvar,sgui,swire
  endfor
  write_gif,gif_SOHO_Cor2C2,/close
  
  if not file_exist('/Users/zigongxu/Documents/work/myWork2_GCS_releasetime/image/'+event_num+'/CME_fitting_map') then begin
    spawn,'mkdir /Users/zigongxu/Documents/work/myWork2_GCS_releasetime/image/'+event_num+'/CME_fitting_map'
  endif 

  gif_STA_cor2c3='/Users/zigongxu/Documents/work/myWork2_GCS_releasetime/image/'+event_num+'/CME_fitting_map/STA_Cor2C3_'+tag+'.gif'
  gif_STB_cor2c3='/Users/zigongxu/Documents/work/myWork2_GCS_releasetime/image/'+event_num+'/CME_fitting_map/STB_Cor2C3_'+tag+'.gif'
  gif_SOHO_cor2c3='/Users/zigongxu/Documents/work/myWork2_GCS_releasetime/image/'+event_num+'/CME_fitting_map/SOHO_Cor2C3_'+tag+'.gif'
  
  for i=0,n_elements(name_list_Cor2C3)-1 do begin
    restore,name_list_Cor2C3[i]
    t=made_gif_sta(gif_sta_cor2c3,sgui,swire,delay_time=delay_time)
    delvar,sgui,swire
  endfor
  write_gif,gif_STA_Cor2C3,/close
  for i=0,n_elements(name_list_Cor2C3)-1 do begin
    restore,name_list_Cor2C3[i]
    t=made_gif_stb(gif_stb_Cor2C3,sgui,swire,delay_time=delay_time)
    delvar,sgui,swire
  endfor
  write_gif,gif_STB_cor2C3,/close
  for i=0,n_elements(name_list_Cor2C3)-1 do begin
    restore,name_list_Cor2C3[i]
    t=made_gif_soho(gif_soho_Cor2C3,sgui,swire,delay_time=delay_time)
    delvar,sgui,swire
  endfor
  write_gif,gif_SOHO_Cor2C3,/close
end


