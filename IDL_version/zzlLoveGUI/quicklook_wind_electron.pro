pro quicklook_wind_electron,event_num,wind_data=wind_data,wind_jul=wind_jul,Eruption_time=Eruption_time,start_day=start_day,end_day=end_day,$
    data_dir=data_dir,result_dir=result_dir,energy_channel=energy_channel
	;Name: subsoho_proton_draw
	;Purpose: sub function of version_1 widget
  ;explanation
	;modification history
  ;
	;2017.9.22, xuzigong
  ;2017.9.24 first version, only the high energy channel involverd

;
;
  restore,'/Users/zigongxu/Documents/work/myWork2_GCS_releasetime/code/common/constant_define.sav'
  if not keyword_set(data_dir) then data_dir='/Users/zigongxu/Documents/work/myWork2_GCS_releasetime/data/'  
  if not keyword_set(result_dir) then result_dir='/Users/zigongxu/Documents/work/myWork2_GCS_releasetime/result/'
  ;travel_time=IMF_length/velocity ; in second 
  if (doy(end_day)-doy(start_day) ge 1)then multi_day= 1 else multi_day=0
  if not keyword_set(energy_channel) then begin
    print,'I need energy channel'
    energy_channel=[1,1,1,1,1,1,1]
  endif

  dummy=label_date(date_format='%H:%I')
  doy_name=doy(strmid(event_num,0,4)+'-'+strmid(event_num,4,2)+'-'+strmid(event_num,6,2)); data type :int
  str_doy_name=strtrim(doy_name,2); remove all blank space

;high energy 
if not keyword_set(wind_data) then begin
   if keyword_set(multi_day) then begin
     electron_l1_name=file_search(data_dir+event_num+'/particle','wi_sfsp*.cdf')
   endif else begin 
     electron_L1_name=file_search(data_dir+event_num+'/particle','wi_sfsp*'+event_num+'*.cdf');/wi_sfsp_3dp_20110307_v01.cdf'
   endelse
   ;- wind e
   id = CDF_OPEN(electron_l1_name[0])
   inq = CDF_inquire(id)
   nvars=inq.nvars
   nzvars=inq.nzvars
   maxrec=inq.maxrec
   var1=CDF_varinq(id,0); data_type='CDF_EPOCH'
   name_var1=var1.NAME
   CDF_varget,id,name_var1,Epoch,rec_count=maxrec; in CDF_Epoch type
   ;CDF_varget1,id,name_var1,Epoch  ; CDF_varget1 get only one data
   Epoch_jul=CDF_EPOCH_TOJULDAYS(Epoch); In Julday for plot
   ;Epoch_str=CDF_ENCODE_EPOCH(Epoch)
   ;Result = CDF_VARNUM( Id, VarName [, IsZVar] ) :find the num of VarName
   var2=CDF_varinq(id,0,/zvariable)
   name_var2=var2.NAME
   var3=CDF_varinq(id,1,/zvariable)
   name_var3=var3.NAME
   Var4=CDF_varinq(id,2,/zvariable)
   name_var4=var4.NAME
   ;dummy=label_date(date_format='%H:%I:%S')
   cdf_varget,id,name_var3,flux,rec_count=maxrec
   cdf_varget,id,name_var4,energy_wind_e
   if keyword_set(multi_day) then begin 
     for i=1, N_elements(electron_l1_name)-1 do begin 
       id = CDF_OPEN(electron_l1_name[i])
       inq = CDF_inquire(id)
       nvars=inq.nvars
       nzvars=inq.nzvars
       maxrec=inq.maxrec
       var1=CDF_varinq(id,0); data_type='CDF_EPOCH'
       name_var1=var1.NAME
       CDF_varget,id,name_var1,Epoch1,rec_count=maxrec; in CDF_Epoch type
       ;CDF_varget1,id,name_var1,Epoch  ; CDF_varget1 get only one data
       Epoch_jul1=CDF_EPOCH_TOJULDAYS(Epoch1); In Julday for plot
       ;Epoch_str=CDF_ENCODE_EPOCH(Epoch)
       ;Result = CDF_VARNUM( Id, VarName [, IsZVar] ) :find the num of VarName
       var2=CDF_varinq(id,0,/zvariable)
       name_var2=var2.NAME
       var3=CDF_varinq(id,1,/zvariable)
       name_var3=var3.NAME
       Var4=CDF_varinq(id,2,/zvariable)
       name_var4=var4.NAME
       cdf_varget,id,name_var3,flux1,rec_count=maxrec
       flux=[[flux],[flux1]]
       Epoch_jul=[[Epoch_jul],[Epoch_jul1]]
     endfor
   endif
   ;Wind_velocity=calculate_velocity(energy_wind_e,unit='ev',particle='electron',light_speed=beta_e)
   
   Wind_data = flux
   ;help,soho_data
   wind_jul=Epoch_jul
endif else begin
   flux = wind_data
   Epoch_jul = wind_jul
   flux[where(flux lt 1e-10)] = !values.F_nan
endelse
cgplot,Epoch_jul,reform(flux[0,*]),xstyle=1,xtickformat='label_date',/ylog,ystyle=1,$
  yrange=[10.^(floor(alog10(max_except(flux,except_range_small=1e-10,/min,/nan)))),10.^(ceil(alog10(max(flux,/nan))))],$
      title='wind electron',xtitle='time(start from'+start_day+')',xrange=[any2jul(start_day),any2jul(end_day)],/nodata,charsize=0.8
;print,energy_channel
temp=where(energy_Channel eq 1)
if temp[0] ne -1 then begin
  foreach i,where(energy_channel eq 1) do begin
    cgplot,Epoch_jul,reform(flux[i,*]),/over,color=mycolor1[i],symsize=0.1,psym=1
  endforeach
endif
vline,any2jul(eruption_time),linestyle=1,color='black'
end
