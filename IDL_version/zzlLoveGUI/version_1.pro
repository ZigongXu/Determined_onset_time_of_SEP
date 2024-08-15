pro quit_event,event
	common Version_block,event_num,Eruption_time,Start_day,end_day,back_start_time,back_end_time,solar_wind_speed,smooth_num,data_path
	widget_control,event.top,get_uvalue=state
	widget_control,event.top,/destroy
	data_dir=data_path
	save,state,filename=data_dir+event_num+'/'+event_num+'.sav'
	print,'state has been saved'
	ptr_free,state
end
pro clean_event,event
	common Version_block
	widget_control,event.top,get_uvalue=state
	data_dir=data_path
	save,state,filename=data_dir+event_num+'/'+event_num+'.sav'
		;help,*state
	;print,(*state).energy_channel__soho
	state1=ptr_new({soho_draw:(*state).soho_draw,STAproton_draw:(*state).STAproton_draw,STBproton_draw:(*state).STBproton_draw,STBelectron_draw:(*state).STBelectron_draw,STAelectron_draw:(*state).STAelectron_draw,wind_draw:(*state).wind_draw,$
		energy_channel_soho:(*state).energy_channel_soho,$
		energy_channel_wind:(*state).energy_channel_wind,$
		energy_channel_STA_proton:(*state).energy_channel_STA_proton,$
		energy_channel_STB_proton:(*state).energy_channel_STB_proton,$
		energy_channel_STA_electron:(*state).energy_channel_STA_electron,$
		energy_channel_STB_electron:(*state).energy_channel_STB_electron})
	;print,'==='
	ptr_free,state
	widget_control,event.top,set_uvalue=state1
	;widget_control,event.top,get_uvalue=state
	print,'reset over, please continue you analysis in another event =>'

end
pro soho_event,event
	print,'now processing soho proton'
	restore,'/Users/xuzigong/CodeSpace/Git/Determined_onset_time_of_SEP/IDL_version/common/constant_define.sav'
	energy_name=['15.4MeV','18.9MeV','23.3meV','29.1MeV','36.4MeV','45.6MeV','57.4MeV','72.0MeV','90.5MeV','108.0MeV']	
	common Version_block
	set_plot,'x'
	widget_control,event.top,get_uvalue=state
	widget_control,event.id,get_uvalue=eventvalue
	widget_control,(*state).soho_draw,get_value=soho_drawID
	wset,soho_drawID
	;draw_soho,
	;help,eventvaluie
	if string(eventvalue) eq 'quicklook' then begin
	quicklook_soho_proton,event_num,soho_data=soho_data,soho_jul=soho_jul,energy_channel=(*state).energy_channel_soho,$
		start_day=start_day,end_day=end_day,Eruption_time=Eruption_time
	if not tag_exist(*state,'soho_data') then begin
		*state=create_struct((*state),'soho_data',soho_data,'soho_jul',soho_jul)
	endif
	endif else begin
	;quicklook_soho_proton,event_num,soho_data=soho_data,soho_jul=soho_jul,/extract_data,start_day=start_day,end_day=end_day,$
	;	energy_channel=(*state).energy_channel_soho
	soho_data=(*state).soho_data
	soho_jul= (*state).soho_jul
	IMF=length_of_IMF(solar_wind_speed,l_au=len)
	list=['IMF length ='+string(len,format='(F5.2)')+'AU']
	;print,(*state).energy_channel_soho
	onset=make_array(10,/string)
	if not tag_Exist(*state,'soho_onset') then *state=create_struct(*state,'soho_onset',onset)
	for i=0,N_Elements(energy_name)-1 do begin
	;	print,any2jul(back_start_time),any2jul(back_end_time)
		if (*state).energy_channel_soho[i] eq 1 then begin
		temp=find_onset_time(soho_jul,reform(soho_data[i,*]),background=[any2jul(back_start_time),any2jul(back_end_time)],position=pos,time=20,color=mycolor1[i],/pline)	
		temp2=jul2any(temp,/ccsds)
		list=[list,energy_name[i]+'   '+temp2]
		onset[i]=temp2
		widget_control,eventvalue,set_value=list; here , eventvalue equal to the num of text buget
		vline,temp,color=mycolor1[i],linestyle=1
		endif else begin
		onset[i]='invalid'
		endelse
	endfor
	(*state).soho_onset=onset
	endelse
	;help,list
	;widget_control,event.top,set_uvalue=state
	;ptr_free,state
end

pro wind_event,event
	print,'now processing wind processing'
	restore,'/Users/zigongxu/Documents/work/myWork2_GCS_releasetime/code/common/constant_define.sav'
	energy_name=['27.0KeV','40.1KeV','66.2KeV','108.4KeV','181.8KeV','309.5KeV','516.8KeV']
	common Version_block
	set_plot,'x'
	widget_control,event.top,get_uvalue=state
	widget_control,event.id,get_uvalue=eventvalue
	widget_control,(*state).wind_draw,get_value=WIND_drawID
	wset,wind_drawID
	;draw_soho,
	help,eventvalue
	if string(eventvalue) eq 'quicklook' then begin
	quicklook_wind_electron,event_num,wind_data=wind_data,wind_jul=wind_jul,energy_channel=(*state).energy_channel_wind,$
		start_day=start_day,end_day=end_day,Eruption_time=Eruption_time
	if not tag_exist(*state,'wind_data') then begin
		*state=create_struct((*state),'wind_data',wind_data,'wind_jul',wind_jul)
	endif
	endif else begin
	;quicklook_soho_proton,event_num,soho_data=soho_data,soho_jul=soho_jul,/extract_data,start_day=start_day,end_day=end_day,$
	;	energy_channel=(*state).energy_channel_soho
	wind_data=(*state).wind_data
	wind_jul= (*state).wind_jul
	IMF=length_of_IMF(solar_wind_speed,l_au=len)
	list=['IMF length ='+string(len,format='(F5.2)')+'AU']
	;print,(*state).energy_channel_wind
	onset=make_array(7,/string)
	if not tag_Exist(*state,'wind_onset') then *state=create_struct(*state,'wind_onset',onset)
	for i=0,N_Elements(energy_name)-1 do begin
	;	print,any2jul(back_start_time),any2jul(back_end_time)
		if (*state).energy_channel_wind[i] eq 1 then begin
		temp=find_onset_time(wind_jul,reform(wind_data[i,*]),background=[any2jul(back_start_time),any2jul(back_end_time)],position=pos,time=20,color=mycolor1[i],/pline)	
		temp2=jul2any(temp,/ccsds)
		list=[list,energy_name[i]+'   '+temp2]
		onset[i]=temp2
		widget_control,eventvalue,set_value=list; here , eventvalue equal to the num of text buget
		vline,temp,color=mycolor1[i],linestyle=1
		endif else begin
		onset[i]='invalid'
		endelse
	endfor
	(*state).wind_onset=onset
	endelse
	;help,list
	;widget_control,event.top,set_uvalue=state
	;ptr_free,state
end

pro STAproton_event,event
	print,'now processing STEREO A proton'
	restore,'/Users/zigongxu/Documents/work/myWork2_GCS_releasetime/code/common/constant_define.sav'
	energy_name=['1.8-3.6MeV','4.0-6.0MeV','6.0-10.0MeV','10.0-15.0MeV','13.6-15.1MeV','14.9-17.1MeV','17.0-19.3MeV','20.8-23.8MeV','23.8-26.4MeV','26.3-29.7MeV'$
		,'29.5-33.4MeV','33.4-35.8MeV','35.5-40.5MeV','40.0-60.0MeV','60.0-100.0MeV']
	common Version_block
	set_plot,'x'
	widget_control,event.top,get_uvalue=state
	widget_control,event.id,get_uvalue=eventvalue
	widget_control,(*state).STAproton_draw,get_value=STAproton_drawID
	wset,STAproton_drawID
	;draw_soho,
	if string(eventvalue) eq 'quicklook' then begin
	quicklook_STA_proton,event_num,STALET_data=STALET_data,STALET_jul=STALET_jul,STAHET_data=STAHET_data,STAHET_jul= STAHET_jul,$
		energy_channel=(*state).energy_channel_STA_proton,$
		start_day=start_day,end_day=end_day,Eruption_time=Eruption_time[0],smooth_num=smooth_num[0]
	;help,staHET_data,STALET_data,STAlet_jul,STAHET_jul
	if not tag_exist(*state,'STALET_data') then begin
		*state=create_struct((*state),'STALET_data',STAlet_data,'STALET_jul',STALET_jul)
	endif
	if not tag_exist(*state,'STAHET_data') then begin
		*state=create_struct((*state),'STAHET_data',STAHet_data,'STAHET_jul',STAHET_jul)
	endif
	endif else begin
	;quicklook_soho_proton,event_num,soho_data=soho_data,soho_jul=soho_jul,/extract_data,start_day=start_day,end_day=end_day,$
	;	energy_channel=(*state).energy_channel_soho
	(*state).STALET_data[where((*state).STALET_data lt 1e-10)]=!values.f_nan
	(*state).STAHET_data[where((*state).STAHET_data lt 1e-10)]=!values.f_nan
	STALET_data=(*state).STALET_data
	STAHET_data=(*state).STAHET_data
	STALET_jul= (*state).STALET_jul
	STAHET_jul= (*state).STAHET_jul
	IMF=length_of_IMF(solar_wind_speed,l_au=len)
	list=['IMF length ='+string(len,format='(F5.2)')+'AU']
	;print,(*state).energy_channel_wind
	onset=make_array(15,/string)
	if not tag_Exist(*state,'STAproton_onset') then *state=create_struct(*state,'STAproton_onset',onset)
	for i=0,N_Elements(energy_name)-1 do begin
	;	print,any2jul(back_start_time),any2jul(back_end_time)
		if (*state).energy_channel_STA_proton[i] eq 1 then begin
		print,back_start_time,back_end_time
		;STAproton_data[i,*]=smooth((*state).STAproton_data[i,*],smooth_num[0],/nan,/edge_truncate)
		if i le 3 then begin
		temp=find_onset_time(STALET_jul,smooth(reform(STALET_data[i,*]),smooth_num[0],/nan,/edge_truncate),background=[any2jul(back_start_time),any2jul(back_end_time)],position=pos,time=40,color=mycolor1[i],/pline)	
		endif
		if i gt 3 then begin
		help,STAHET_JUL
		temp=find_onset_time(STAHET_jul,smooth(reform(STAHET_data[i-4,*]),smooth_num[0],/nan,/edge_truncate),background=[any2jul(back_start_time),any2jul(back_end_time)],position=pos,time=40,color=mycolor1[i],/pline)	
		endif
		temp2=jul2any(temp,/ccsds)
		list=[list,energy_name[i]+'   '+temp2]
		onset[i]=temp2
		widget_control,eventvalue,set_value=list; here , eventvalue equal to the num of text buget
		vline,temp,color=mycolor1[i],linestyle=1
		endif else begin
		onset[i]='invalid'
		endelse
	endfor
	(*state).STAproton_onset=onset
	endelse
	;help,list
	;widget_control,event.top,set_uvalue=state
	;ptr_free,state
end
pro STBproton_event,event
	restore,'/Users/zigongxu/Documents/work/myWork2_GCS_releasetime/code/common/constant_define.sav'
	energy_name=['1.8-3.6MeV','4.0-6.0MeV','6.0-10.0MeV','10.0-15.0MeV','13.6-15.1MeV','14.9-17.1MeV','17.0-19.3MeV','20.8-23.8MeV','23.8-26.4MeV','26.3-29.7MeV'$
		,'29.5-33.4MeV','33.4-35.8MeV','35.5-40.5MeV','40.0-60.0MeV','60.0-100.0MeV']
	common Version_block
	set_plot,'x'
	widget_control,event.top,get_uvalue=state
	widget_control,event.id,get_uvalue=eventvalue
	widget_control,(*state).STBproton_draw,get_value=STBproton_drawID
	wset,STBproton_drawID
	;draw_soho,
	if string(eventvalue) eq 'quicklook' then begin
	quicklook_STB_proton,event_num,STBLET_data=STBLET_data,STBLET_jul=STBLET_jul,STBHET_data=STBHET_Data,STBHET_jul= STBHET_jul,energy_channel=(*state).energy_channel_STB_proton,$
		start_day=start_day,end_day=end_day,Eruption_time=Eruption_time[0],smooth_num=smooth_num[0]
	help,stBLET_data,STBHET_data
	if not tag_exist(*state,'STBHET_data') then begin
		*state=create_struct((*state),'STBHET_data',STBHET_data,'STBHET_jul',STBHET_jul)
	endif
	if not tag_exist(*state,'STBLET_data') then begin
		*state = create_struct((*state),'STBLET_data',STBLET_data,'STBLET_jul',STBLET_jul)
	endif
	endif else begin
	;quicklook_soho_proton,event_num,soho_data=soho_data,soho_jul=soho_jul,/extract_data,start_day=start_day,end_day=end_day,$
	;	energy_channel=(*state).energy_channel_soho

	;print,smooth_num
	STBHET_data=(*state).STBHET_data
	STBLET_data=(*state).STBLET_data
	STBHET_data[where(STBHET_data lt 1e-10)]=!values.f_nan
	STBLET_data[where(STBLET_data lt 1e-10)]=!values.f_nan
	STBHET_jul= (*state).STBHET_jul
	STBLET_jul= (*state).STBLET_jul
	IMF=length_of_IMF(solar_wind_speed,l_au=len)
	list=['IMF length ='+string(len,format='(F5.2)')+'AU']
	;print,(*state).energy_channel_wind
	onset=make_array(15,/string)
	if not tag_Exist(*state,'STBproton_onset') then *state=create_struct(*state,'STBproton_onset',onset)
	for i=0,N_Elements(energy_name)-1 do begin
	;	print,any2jul(back_start_time),any2jul(back_end_time)
		if (*state).energy_channel_STB_proton[i] eq 1 then begin
		print,back_start_time,back_end_time
		if i le 3 then begin
		temp=find_onset_time(STBLET_jul,smooth(reform(STBLET_data[i,*]),smooth_num[0],/nan,/edge_truncate),background=[any2jul(back_start_time),any2jul(back_end_time)],position=pos,time=20,color=mycolor1[i],/pline)	
		endif
		if i gt 3 then begin
		temp=find_onset_time(STBHET_jul,smooth(reform(STBHET_data[i-4,*]),smooth_num[0],/nan,/edge_truncate),background=[any2jul(back_start_time),any2jul(back_end_time)],position=pos,time=20,color=mycolor1[i],/pline)	
		endif
		temp2=jul2any(temp,/ccsds)
		list=[list,energy_name[i]+'   '+temp2]
		onset[i]=temp2
		widget_control,eventvalue,set_value=list; here , eventvalue equal to the num of text buget
		vline,temp,color=mycolor1[i],linestyle=1
		endif else begin
		onset[i]='invalid'
		endelse
	endfor
	(*state).STBproton_onset=onset
	endelse
	;help,list
end
pro STAelectron_event,event
	print,'now processing STEREO A electron'
	common Version_block
	restore,'/Users/zigongxu/Documents/work/myWork2_GCS_releasetime/code/common/constant_define.sav'
	energy_name=['45.0-55.0KeV','55.0-65.0KeV','65.0-75.0KeV','75.0-85.0KeV','85.0-105.KeV','105.0-125.KeV','125.0-145.KeV','145.0-165.KeV','165.0-195.KeV',$
	'195.0-225.KeV','225.0-255.KeV','255.0-295.KeV','295.0-335.KeV','335.0-375.KeV','375.0-425.KeV']
	set_plot,'x'
	widget_control,event.top,get_uvalue=state
	widget_control,event.id,get_uvalue=eventvalue
	widget_control,(*state).STAelectron_draw,get_value=STAelectron_drawID
	wset,STAelectron_drawID
	;draw_soho,
	if string(eventvalue) eq 'quicklook' then begin
	quicklook_STA_electron,event_num,STAelectron_data=STAelectron_data,STAelectron_jul=STAelectron_jul,energy_channel=(*state).energy_channel_STA_electron,$
		start_day=start_day,end_day=end_day,Eruption_time=Eruption_time[0],smooth_num=smooth_num[0]
	help,staelectron_data
	if not tag_exist(*state,'STAelectron_data') then begin
		*state=create_struct((*state),'STAelectron_data',STAelectron_data,'STAelectron_jul',STAelectron_jul)
	endif
	endif else begin
	;(*state).STAelectron_data[where((*state).STAelectron_data lt 1e-10)]=!values.f_nan; a bug, make the value little than 1e-10 equal !nan
	STAelectron_data=(*state).STAelectron_data
	STAelectron_data[where(STAelectron_data lt 1e-10)]=!values.f_nan
	STAelectron_jul= (*state).STAelectron_jul
	IMF=length_of_IMF(solar_wind_speed,l_au=len)
	list=['IMF length ='+string(len,format='(F5.2)')+'AU']
	;print,(*state).energy_channel_wind
	onset=make_array(15,/string)
	if not tag_Exist(*state,'STAelectron_onset') then *state=create_struct(*state,'STAelectron_onset',onset)
	for i=0,N_Elements(energy_name)-1 do begin
	;	print,any2jul(back_start_time),any2jul(back_end_time)
		if (*state).energy_channel_STA_electron[i] eq 1 then begin
		print,back_start_time,back_end_time
		temp=find_onset_time(STAelectron_jul,smooth(reform(STAelectron_data[i,*]),smooth_num[0],/nan,/edge_truncate),background=[any2jul(back_start_time),any2jul(back_end_time)],position=pos,time=40,color=mycolor1[i],/pline)	

		temp2=jul2any(temp,/ccsds)
		list=[list,energy_name[i]+'   '+temp2]
		onset[i]=temp2
		widget_control,eventvalue,set_value=list; here , eventvalue equal to the num of text buget
		vline,temp,color=mycolor1[i],linestyle=1
		endif else begin
		onset[i]='invalid'
		endelse
	endfor
	(*state).STAelectron_onset=onset
	endelse
	;help,list
	;widget_control,event.top,set_uvalue=state
	;ptr_free,state

end

pro STBelectron_event, event
	print,'now processing STEREO B electron'
	common Version_block
	restore,'/Users/xuzigong/CodeSpace/Git/Determined_onset_time_of_SEP/IDL_version/common/constant_define.sav'
	energy_name=['45.0-55.0KeV','55.0-65.0KeV','65.0-75.0KeV','75.0-85.0KeV','85.0-105.KeV','105.0-125.KeV','125.0-145.KeV','145.0-165.KeV','165.0-195.KeV',$
	'195.0-225.KeV','225.0-255.KeV','255.0-295.KeV','295.0-335.KeV','335.0-375.KeV','375.0-425.KeV']
	set_plot,'x'
	widget_control,event.top,get_uvalue=state
	widget_control,event.id,get_uvalue=eventvalue
	widget_control,(*state).STBelectron_draw,get_value=STBelectron_drawID
	wset,STBelectron_drawID
	;draw_soho,
	if string(eventvalue) eq 'quicklook' then begin
	quicklook_STB_electron,event_num,STBelectron_data=STBelectron_data,STBelectron_jul=STBelectron_jul,energy_channel=(*state).energy_channel_STB_electron,$
		start_day=start_day,end_day=end_day,Eruption_time=Eruption_time[0],smooth_num=smooth_num[0]
	help,stBelectron_data
	if not tag_exist(*state,'STBelectron_data') then begin
		*state=create_struct((*state),'STBelectron_data',STBelectron_data,'STBelectron_jul',STBelectron_jul)
	endif
	endif else begin
	(*state).STBelectron_data[where((*state).STBelectron_data lt 1e-10)]=!values.f_nan
	STBelectron_data=(*state).STBelectron_data
	STBelectron_jul= (*state).STBelectron_jul
	IMF=length_of_IMF(solar_wind_speed,l_au=len)
	list=['IMF length ='+string(len,format='(F5.2)')+'AU']
	;print,(*state).energy_channel_wind
	onset=make_array(15,/string)
	if not tag_Exist(*state,'STBelectron_onset') then *state=create_struct(*state,'STBelectron_onset',onset)
	for i=0,N_Elements(energy_name)-1 do begin
	;	print,any2jul(back_start_time),any2jul(back_end_time)
		if (*state).energy_channel_STB_electron[i] eq 1 then begin
		print,back_start_time,back_end_time

		temp=find_onset_time(STBelectron_jul,smooth(reform(STBelectron_data[i,*]),smooth_num[0],/nan,/edge_truncate),background=[any2jul(back_start_time),any2jul(back_end_time)],position=pos,time=20,color=mycolor1[i],/pline)	

		temp2=jul2any(temp,/ccsds)
		list=[list,energy_name[i]+'   '+temp2]
		onset[i]=temp2
		widget_control,eventvalue,set_value=list; here , eventvalue equal to the num of text buget
		vline,temp,color=mycolor1[i],linestyle=1
		endif else begin
		onset[i]='invalid'
		endelse
	endfor
	(*state).STBelectron_onset=onset
	endelse
end

pro Version_1_event, event
	common Version_block, event_num,Eruption_time,Start_day,end_day,back_start_time,back_end_time,solar_wind_speed,data_path
	widget_control,event.top,GET_uvalue = state
;	print,event.ID

	widget_control, event.ID, get_uvalue = eventVal
	help,event
	if eventVal ne !NULL then begin
	print,eventval
	Case eventVal of
		"Event Num" : begin
						widget_control,event.id,get_value=event_num
						print,event_num
					end
		"Eruption time": begin
						widget_control,event.id,get_value=eruption_time
						print,eruption_time
						end
		"Start Day":begin
						widget_control,event.id,get_value = start_day
						print,start_day
						end
		"End Day" : begin
						widget_control,event.id,get_value = end_day
						print,end_day
					end
		"solar wind speed":	begin
							widget_control,event.id,get_value = solar_wind_speed
							print,solar_wind_speed
						;	widget_control,event.id,set_value = solar_wind_speed
							end
	endcase

	endif
end

pro Energy_channel_event_soho,event
	widget_control,event.top,GET_uvalue = state
	print,event.select 
	widget_control,event.id,get_value=energy
	help,state
	if event.select eq 1 then begin
		case energy of 
			'15.4MeV':(*state).energy_channel_soho[0]=1
			'18.9MeV':(*state).energy_channel_soho[1]=1
			'23.3MeV':(*state).energy_channel_soho[2]=1
			'29.1MeV':(*state).energy_channel_soho[3]=1
			'36.4MeV':(*state).energy_channel_soho[4]=1
			'45.6MeV':(*state).energy_channel_soho[5]=1
			'57.4MeV':(*state).energy_channel_soho[6]=1
			'72.0MeV':(*state).energy_channel_soho[7]=1
			'90.5MeV':(*state).energy_channel_soho[8]=1
			'108.0MeV':(*state).energy_channel_soho[9]=1
		endcase
	endif
	if event.select eq 0 then begin
		case energy of 
			'15.4MeV':(*state).energy_channel_soho[0]=0
			'18.9MeV':(*state).energy_channel_soho[1]=0
			'23.3MeV':(*state).energy_channel_soho[2]=0
			'29.1MeV':(*state).energy_channel_soho[3]=0
			'36.4MeV':(*state).energy_channel_soho[4]=0
			'45.6MeV':(*state).energy_channel_soho[5]=0
			'57.4MeV':(*state).energy_channel_soho[6]=0
			'72.0MeV':(*state).energy_channel_soho[7]=0
			'90.5MeV':(*state).energy_channel_soho[8]=0
			'108.0MeV':(*state).energy_channel_soho[9]=0
		endcase

	endif
	;print,(*state).energy_channel_soho
end

pro Energy_channel_event_wind,event
	widget_control,event.top,GET_uvalue = state
	print,event.select 
	widget_control,event.id,get_value=energy
	help,state
	if event.select eq 1 then begin
		case energy of 
			'27.0KeV' :(*state).energy_channel_wind[0]=1
			'40.1KeV' :(*state).energy_channel_wind[1]=1
			'66.2KeV' :(*state).energy_channel_wind[2]=1
			'108.4KeV':(*state).energy_channel_wind[3]=1
			'181.8KeV':(*state).energy_channel_wind[4]=1
			'309.5KeV':(*state).energy_channel_wind[5]=1
			'516.8KeV':(*state).energy_channel_wind[6]=1
		endcase
	endif
	if event.select eq 0 then begin
		case energy of 
			'27.0KeV' :(*state).energy_channel_wind[0]=0
			'40.1KeV' :(*state).energy_channel_wind[1]=0
			'66.2KeV' :(*state).energy_channel_wind[2]=0
			'108.4KeV':(*state).energy_channel_wind[3]=0
			'181.8KeV':(*state).energy_channel_wind[4]=0
			'309.5KeV':(*state).energy_channel_wind[5]=0
			'516.8KeV':(*state).energy_channel_wind[6]=0
		endcase

	endif
	;print,(*state).energy_channel_soho
end

pro Energy_channel_event_STA_proton,event
	widget_control,event.top,GET_uvalue = state
	print,event.select 
	widget_control,event.id,get_value=energy
	help,state
	if event.select eq 1 then begin
		case energy of 
			'1.8-3.6MeV'  :(*state).energy_channel_STA_proton[0]=1
			'4.0-6.0MeV'  :(*state).energy_channel_STA_proton[1]=1
			'6.0-10.0MeV' :(*state).energy_channel_STA_proton[2]=1
			'10.0-15.0MeV':(*state).energy_channel_STA_proton[3]=1
			'13.6-15.1MeV':(*state).energy_channel_STA_proton[4]=1
			'14.9-17.1MeV':(*state).energy_channel_STA_proton[5]=1
			'17.0-19.3MeV':(*state).energy_channel_STA_proton[6]=1
			'20.8-23.8MeV':(*state).energy_channel_STA_proton[7]=1
			'23.8-26.4MeV':(*state).energy_channel_STA_proton[8]=1
			'26.3-29.7MeV':(*state).energy_channel_STA_proton[9]=1
			'29.5-33.4MeV':(*state).energy_channel_STA_proton[10]=1
			'33.4-35.8MeV':(*state).energy_channel_STA_proton[11]=1
			'35.5-40.5MeV':(*state).energy_channel_STA_proton[12]=1
			'40.0-60.0MeV':(*state).energy_channel_STA_proton[13]=1
			'60.0-100.0MeV':(*state).energy_channel_STA_proton[14]=1
		endcase
	endif
	if event.select eq 0 then begin
		case energy of 
			'1.8-3.6MeV'  :(*state).energy_channel_STA_proton[0]=0
			'4.0-6.0MeV'  :(*state).energy_channel_STA_proton[1]=0
			'6.0-10.0MeV' :(*state).energy_channel_STA_proton[2]=0
			'10.0-15.0MeV':(*state).energy_channel_STA_proton[3]=0
			'13.6-15.1MeV':(*state).energy_channel_STA_proton[4]=0
			'14.9-17.1MeV':(*state).energy_channel_STA_proton[5]=0
			'17.0-19.3MeV':(*state).energy_channel_STA_proton[6]=0
			'20.8-23.8MeV':(*state).energy_channel_STA_proton[7]=0
			'23.8-26.4MeV':(*state).energy_channel_STA_proton[8]=0
			'26.3-29.7MeV':(*state).energy_channel_STA_proton[9]=0
			'29.5-33.4MeV':(*state).energy_channel_STA_proton[10]=0
			'33.4-35.8MeV':(*state).energy_channel_STA_proton[11]=0
			'35.5-40.5MeV':(*state).energy_channel_STA_proton[12]=0
			'40.0-60.0MeV':(*state).energy_channel_STA_proton[13]=0
			'60.0-100.0MeV':(*state).energy_channel_STA_proton[14]=0
		endcase
	endif
	;print,(*state).energy_channel_soho
end

pro Energy_channel_event_STA_electron,event
	widget_control,event.top,GET_uvalue = state
	print,event.select 
	widget_control,event.id,get_value=energy
	help,state
	if event.select eq 1 then begin
		case energy of 
			'45.0-55.0KeV' 	 :(*state).energy_channel_STA_electron[0]=1
			'55.0-65.0KeV' 	 :(*state).energy_channel_STA_electron[1]=1
			'65.0-75.0KeV' 	 :(*state).energy_channel_STA_electron[2]=1
			'75.0-85.0KeV' 	 :(*state).energy_channel_STA_electron[3]=1
			'85.0-105.0KeV'  :(*state).energy_channel_STA_electron[4]=1
			'105.0-125.0KeV'  :(*state).energy_channel_STA_electron[5]=1
			'125.0-145.0KeV'  :(*state).energy_channel_STA_electron[6]=1
			'145.0-165.0KeV'  :(*state).energy_channel_STA_electron[7]=1
			'165.0-195.0KeV'  :(*state).energy_channel_STA_electron[8]=1
			'195.0-225.0KeV'  :(*state).energy_channel_STA_electron[9]=1
			'225.0-255.0KeV'  :(*state).energy_channel_STA_electron[10]=1
			'255.0-295.0KeV'  :(*state).energy_channel_STA_electron[11]=1
			'295.0-335.0KeV'  :(*state).energy_channel_STA_electron[12]=1
			'335.0-375.0KeV'  :(*state).energy_channel_STA_electron[13]=1
			'375.0-425.0KeV'  :(*state).energy_channel_STA_electron[14]=1
		endcase
	endif
	if event.select eq 0 then begin
		case energy of 
			'45.0-55.0KeV' 	 :(*state).energy_channel_STA_electron[0]=0
			'55.0-65.0KeV' 	 :(*state).energy_channel_STA_electron[1]=0
			'65.0-75.0KeV' 	 :(*state).energy_channel_STA_electron[2]=0
			'75.0-85.0KeV' 	 :(*state).energy_channel_STA_electron[3]=0
			'85.0-105.0KeV'  :(*state).energy_channel_STA_electron[4]=0
			'105.0-125.0KeV'  :(*state).energy_channel_STA_electron[5]=0
			'125.0-145.0KeV'  :(*state).energy_channel_STA_electron[6]=0
			'145.0-165.0KeV'  :(*state).energy_channel_STA_electron[7]=0
			'165.0-195.0KeV'  :(*state).energy_channel_STA_electron[8]=0
			'195.0-225.0KeV'  :(*state).energy_channel_STA_electron[9]=0
			'225.0-255.0KeV'  :(*state).energy_channel_STA_electron[10]=0
			'255.0-295.0KeV'  :(*state).energy_channel_STA_electron[11]=0
			'295.0-335.0KeV'  :(*state).energy_channel_STA_electron[12]=0
			'335.0-375.0KeV'  :(*state).energy_channel_STA_electron[13]=0
			'375.0-425.0KeV'  :(*state).energy_channel_STA_electron[14]=0
		endcase
	endif
	;print,(*state).energy_channel_soho
end

pro Energy_channel_event_STB_proton,event
	widget_control,event.top,GET_uvalue = state
	print,event.select 
	widget_control,event.id,get_value=energy
	help,state
	if event.select eq 1 then begin
		case energy of 
			'1.8-3.6MeV'  :(*state).energy_channel_STB_proton[0]=1
			'4.0-6.0MeV'  :(*state).energy_channel_STB_proton[1]=1
			'6.0-10.0MeV' :(*state).energy_channel_STB_proton[2]=1
			'10.0-15.0MeV':(*state).energy_channel_STB_proton[3]=1
			'13.6-15.1MeV':(*state).energy_channel_STB_proton[4]=1
			'14.9-17.1MeV':(*state).energy_channel_STB_proton[5]=1
			'17.0-19.3MeV':(*state).energy_channel_STB_proton[6]=1
			'20.8-23.8MeV':(*state).energy_channel_STB_proton[7]=1
			'23.8-26.4MeV':(*state).energy_channel_STB_proton[8]=1
			'26.3-29.7MeV':(*state).energy_channel_STB_proton[9]=1
			'29.5-33.4MeV':(*state).energy_channel_STB_proton[10]=1
			'33.4-35.8MeV':(*state).energy_channel_STB_proton[11]=1
			'35.5-40.5MeV':(*state).energy_channel_STB_proton[12]=1
			'40.0-60.0MeV':(*state).energy_channel_STB_proton[13]=1
			'60.0-100.0MeV':(*state).energy_channel_STB_proton[14]=1
		endcase
	endif
	if event.select eq 0 then begin
		case energy of 
			'1.8-3.6MeV'  :(*state).energy_channel_STB_proton[0]=0
			'4.0-6.0MeV'  :(*state).energy_channel_STB_proton[1]=0
			'6.0-10.0MeV' :(*state).energy_channel_STB_proton[2]=0
			'10.0-15.0MeV':(*state).energy_channel_STB_proton[3]=0
			'13.6-15.1MeV':(*state).energy_channel_STB_proton[4]=0
			'14.9-17.1MeV':(*state).energy_channel_STB_proton[5]=0
			'17.0-19.3MeV':(*state).energy_channel_STB_proton[6]=0
			'20.8-23.8MeV':(*state).energy_channel_STB_proton[7]=0
			'23.8-26.4MeV':(*state).energy_channel_STB_proton[8]=0
			'26.3-29.7MeV':(*state).energy_channel_STB_proton[9]=0
			'29.5-33.4MeV':(*state).energy_channel_STB_proton[10]=0
			'33.4-35.8MeV':(*state).energy_channel_STB_proton[11]=0
			'35.5-40.5MeV':(*state).energy_channel_STB_proton[12]=0
			'40.0-60.0MeV':(*state).energy_channel_STB_proton[13]=0
			'60.0-100.0MeV':(*state).energy_channel_STB_proton[14]=0
		endcase
	endif
	;print,(*state).energy_channel_soho
end

pro Energy_channel_event_STB_electron,event
	widget_control,event.top,GET_uvalue = state
	print,event.select 
	widget_control,event.id,get_value=energy
	help,state
	if event.select eq 1 then begin
		case energy of 
			'45.0-55.0KeV' 	 :(*state).energy_channel_STB_electron[0]=1
			'55.0-65.0KeV' 	 :(*state).energy_channel_STB_electron[1]=1
			'65.0-75.0KeV' 	 :(*state).energy_channel_STB_electron[2]=1
			'75.0-85.0KeV' 	 :(*state).energy_channel_STB_electron[3]=1
			'85.0-105.0KeV'	 :(*state).energy_channel_STB_electron[4]=1
			'105.0-125.0KeV'  :(*state).energy_channel_STB_electron[5]=1
			'125.0-145.0KeV'  :(*state).energy_channel_STB_electron[6]=1
			'145.0-165.0KeV'  :(*state).energy_channel_STB_electron[7]=1
			'165.0-195.0KeV'  :(*state).energy_channel_STB_electron[8]=1
			'195.0-225.0KeV'  :(*state).energy_channel_STB_electron[9]=1
			'225.0-255.0KeV'  :(*state).energy_channel_STB_electron[10]=1
			'255.0-295.0KeV'  :(*state).energy_channel_STB_electron[11]=1
			'295.0-335.0KeV'  :(*state).energy_channel_STB_electron[12]=1
			'335.0-375.0KeV'  :(*state).energy_channel_STB_electron[13]=1
			'375.0-425.0KeV'  :(*state).energy_channel_STB_electron[14]=1

		endcase
	endif
	if event.select eq 0 then begin
		case energy of 
			'45.0-55.0KeV' 	  :(*state).energy_channel_STB_electron[0]=0
			'55.0-65.0KeV' 	  :(*state).energy_channel_STB_electron[1]=0
			'65.0-75.0KeV' 	  :(*state).energy_channel_STB_electron[2]=0
			'75.0-85.0KeV' 	  :(*state).energy_channel_STB_electron[3]=0
			'85.0-105.0KeV'	  :(*state).energy_channel_STB_electron[4]=0
			'105.0-125.0KeV'   :(*state).energy_channel_STB_electron[5]=0
			'125.0-145.0KeV'   :(*state).energy_channel_STB_electron[6]=0
			'145.0-165.0KeV'   :(*state).energy_channel_STB_electron[7]=0
			'165.0-195.0KeV'   :(*state).energy_channel_STB_electron[8]=0
			'195.0-225.0KeV'   :(*state).energy_channel_STB_electron[9]=0
			'225.0-255.0KeV'   :(*state).energy_channel_STB_electron[10]=0
			'255.0-295.0KeV'   :(*state).energy_channel_STB_electron[11]=0
			'295.0-335.0KeV'   :(*state).energy_channel_STB_electron[12]=0
			'335.0-375.0KeV'   :(*state).energy_channel_STB_electron[13]=0
			'375.0-425.0KeV'   :(*state).energy_channel_STB_electron[14]=0
		endcase

	endif
	;print,(*state).energy_channel_soho
end
pro save_soho_event,event
	common Version_block
	widget_control,event.top,get_uvalue=state
	widget_control,event.ID,get_uvalue=soho_save_dir
	if not file_exist('/Users/zigongxu/Documents/work/myWork2_GCS_releasetime/image/'+event_num) then begin
		spawn,'mkdir /Users/zigongxu/Documents/work/myWork2_GCS_releasetime/image/'+event_num
	endif
	name = dialog_pickfile(/write,file='soho_flux.eps',path='/Users/zigongxu/Documents/work/myWork2_GCS_releasetime/image/'+event_num)
	widget_control,soho_save_dir,set_value=name
	window_name=!D.name
	set_plot,'ps'
	device,filename=name,xsize=7,ysize=4,/inches,xoffset=1,yoffset=1
	quicklook_soho_proton,event_num,energy_channel=(*state).energy_channel_soho,start_day=start_day,end_day=end_day,eruption_time=eruption_time
	device,/close_file
	set_plot,window_name
end
pro save_wind_event,event
	common Version_block
	widget_control,event.top,get_uvalue=state
	widget_control,event.ID,get_uvalue=wind_save_dir
	if not file_exist('/Users/zigongxu/Documents/work/myWork2_GCS_releasetime/image/'+event_num) then begin
		spawn,'mkdir /Users/zigongxu/Documents/work/myWork2_GCS_releasetime/image/'+event_num
	endif
	name = dialog_pickfile(/write,file='wind_flux.eps',path='/Users/zigongxu/Documents/work/myWork2_GCS_releasetime/image/'+event_num)
	widget_control,wind_save_dir,set_value=name
	window_name=!D.name
	set_plot,'ps'
	device,filename=name,xsize=7,ysize=4,/inches,xoffset=1,yoffset=1
	quicklook_wind_electron,event_num,energy_channel=(*state).energy_channel_wind,start_day=start_day,end_day=end_day,eruption_time=eruption_time;,smooth_num=smooth_num[0]
	device,/close_file
	set_plot,window_name
end
pro save_STAproton_event,event
	common Version_block
	widget_control,event.top,get_uvalue=state
	widget_control,event.ID,get_uvalue=STAproton_save_dir
	if not file_exist('/Users/zigongxu/Documents/work/myWork2_GCS_releasetime/image/'+event_num) then begin
		spawn,'mkdir /Users/zigongxu/Documents/work/myWork2_GCS_releasetime/image/'+event_num
	endif
	name = dialog_pickfile(/write,file='STAproton_flux.eps',path='/Users/zigongxu/Documents/work/myWork2_GCS_releasetime/image/'+event_num)
	widget_control,STAproton_save_dir,set_value=name
	window_name=!D.name
	set_plot,'ps'
	device,filename=name,xsize=7,ysize=4,/inches,xoffset=1,yoffset=1
	quicklook_STA_proton,event_num,energy_channel=(*state).energy_channel_STA_proton,start_day=start_day,end_day=end_day,eruption_time=eruption_time,smooth_num=smooth_num[0]
	device,/close_file
	set_plot,window_name
end
pro save_STAelectron_event,event
	common Version_block
	widget_control,event.top,get_uvalue=state
	widget_control,event.ID,get_uvalue=STAelectron_save_dir
	if not file_exist('/Users/zigongxu/Documents/work/myWork2_GCS_releasetime/image/'+event_num) then begin
		spawn,'mkdir /Users/zigongxu/Documents/work/myWork2_GCS_releasetime/image/'+event_num
	endif
	name = dialog_pickfile(/write,file='STAelectron_flux.eps',path='/Users/zigongxu/Documents/work/myWork2_GCS_releasetime/image/'+event_num)
	widget_control,STAelectron_save_dir,set_value=name
	window_name=!D.name
	set_plot,'ps'
	device,filename=name,xsize=7,ysize=4,/inches,xoffset=1,yoffset=1
	quicklook_STA_electron,event_num,energy_channel=(*state).energy_channel_STA_electron,start_day=start_day,end_day=end_day,eruption_time=eruption_time,smooth_num=smooth_num[0]
	device,/close_file
	set_plot,window_name
end
pro save_STBproton_event,event
	common Version_block
	widget_control,event.top,get_uvalue=state
	widget_control,event.ID,get_uvalue=STBproton_save_dir
	if not file_exist('/Users/zigongxu/Documents/work/myWork2_GCS_releasetime/image/'+event_num) then begin
		spawn,'mkdir /Users/zigongxu/Documents/work/myWork2_GCS_releasetime/image/'+event_num
	endif
	name = dialog_pickfile(/write,file='STBproton_flux.eps',path='/Users/zigongxu/Documents/work/myWork2_GCS_releasetime/image/'+event_num)
	widget_control,STBproton_save_dir,set_value=name
	window_name=!D.name
	set_plot,'ps'
	device,filename=name,xsize=7,ysize=4,/inches,xoffset=1,yoffset=1
	quicklook_STB_proton,event_num,energy_channel=(*state).energy_channel_STB_proton,start_day=start_day,end_day=end_day,eruption_time= eruption_time,smooth_num=smooth_num[0]
	device,/close_file
	set_plot,window_name
end
pro save_STBelectron_event,event
	common Version_block
	widget_control,event.top,get_uvalue=state
	widget_control,event.ID,get_uvalue=STBelectron_save_dir
	if not file_exist('/Users/zigongxu/Documents/work/myWork2_GCS_releasetime/image/'+event_num) then begin
		spawn,'mkdir /Users/zigongxu/Documents/work/myWork2_GCS_releasetime/image/'+event_num
	endif
	name = dialog_pickfile(/write,file='STBelectron_flux.eps',path='/Users/zigongxu/Documents/work/myWork2_GCS_releasetime/image/'+event_num)
	widget_control,STBelectron_save_dir,set_value=name
	window_name=!D.name
	set_plot,'ps'
	device,filename=name,xsize=7,ysize=4,/inches,xoffset=1,yoffset=1
	quicklook_STB_electron,event_num,energy_channel=(*state).energy_channel_STB_electron,start_day=start_day,end_day=end_day,eruption_time=eruption_time,smooth_num=smooth_num[0]
	device,/close_file
	set_plot,window_name
end

pro save_result_event,event
	;used for all result save button
	restore,'/Users/zigongxu/Documents/work/myWork2_GCS_releasetime/code/common/constant_define.sav'
	common Version_block
	widget_control,event.top,get_uvalue=state
	widget_control,event.id,get_uvalue=eventvalue
	if not file_exist('/Users/zigongxu/Documents/work/myWork2_GCS_releasetime/result/'+event_num) then begin
		spawn,'mkdir /Users/zigongxu/Documents/work/myWork2_GCS_releasetime/result/'+event_num
		spawn,'mkdir /Users/zigongxu/Documents/work/myWork2_GCS_releasetime/result/'+event_num+'/GCS_result'
	endif
	case eventvalue of
	"save_soho_result": begin
							name = dialog_pickfile(/write,file='result_soho.dat',path='/Users/zigongxu/Documents/work/myWork2_GCS_releasetime/result/'+event_num)
							velocity=calculate_velocity(P_soho_high,unit='MeV',particle='proton',light_speed=light_speed)
							IMF=length_of_IMF(solar_wind_speed,l_au=len)
							openw,lun,name,/get_lun
							printf,lun,'SOHO result from TSA and VDA(date: '+event_num+');Updata in '+systime()
  							printf,lun,'Energy(MeV)','Onset_time','travel time(solar speed)','Release time(+8.3 min)','quality',format='(4A-25,A-20)'

  							for i=0,N_elements((*state).energy_channel_soho)-1 do begin 
      							if (*state).energy_channel_soho[i] eq 1 then begin
      								release_time=jul2any(any2jul((*state).soho_onset[i])-IMF/velocity[i]/86400D + 8.33/1440D,/ccsds)
        							printf,lun,P_soho_high[i],(*state).soho_onset[i],IMF/velocity[i],release_time,1,format='(F-25.4,A-25,F-25.4,A-25,I-20)'
      							endif else begin
        						printf,lun,P_soho_high[i],(*state).soho_onset[i],IMF/velocity[i],'Invalid',0,format='(F-25.4,A-25,F-25.4,A-25,I-20)'
        						endelse
  							endfor
  							free_lun,lun
  						end

  	"save_wind_result": begin
  							name = dialog_pickfile(/write,file='result_wind.dat',path='/Users/zigongxu/Documents/work/myWork2_GCS_releasetime/result/'+event_num)
							velocity=calculate_velocity(wind_energy,unit='KeV',particle='electron',light_speed=light_speed)
							IMF=length_of_IMF(solar_wind_speed,l_au=len)
							openw,lun,name,/get_lun
							printf,lun,'wind electron result from TSA and VDA(date: '+event_num+');Updata in '+systime()
  							printf,lun,'Energy(keV)','Onset_time','travel time(solar speed)','Release time(+8.3 min)','quality',format='(4A-25,A-20)'

  							for i=0,N_elements((*state).energy_channel_wind)-1 do begin 
      							if (*state).energy_channel_wind[i] eq 1 then begin
      								release_time=jul2any(any2jul((*state).wind_onset[i])-IMF/velocity[i]/86400D + 8.33/1440D,/ccsds)
        							printf,lun,wind_energy[i],(*state).wind_onset[i],IMF/velocity[i],release_time,1,format='(F-25.4,A-25,F-25.4,A-25,I-20)'
      							endif else begin
        						printf,lun,wind_energy[i],(*state).wind_onset[i],IMF/velocity[i],'Invalid',0,format='(F-25.4,A-25,F-25.4,A-25,I-20)'
        						endelse
  							endfor
  							free_lun,lun
  						end
  	"save_STAproton_result":begin
   							name = dialog_pickfile(/write,file='result_STAproton.dat',path='/Users/zigongxu/Documents/work/myWork2_GCS_releasetime/result/'+event_num)
							  velocity=calculate_velocity(STEREO_proton,unit='MeV',particle='proton',light_speed=light_speed)
							  IMF=length_of_IMF(solar_wind_speed,l_au=len)
							  openw,lun,name,/get_lun
							  printf,lun,'STEREO A proton result from TSA and VDA(date: '+event_num+');Updata in '+systime()
  							printf,lun,'Energy(MeV)','Onset_time','travel time(solar speed)','Release time(+8.3 min)','quality',format='(4A-25,A-20)'
  							print,(*state).energy_channel_STA_proton
  							for i=0,N_elements((*state).energy_channel_STA_proton)-1 do begin 

      							if (*state).energy_channel_STA_proton[i] eq 1 then begin
      								release_time=jul2any(any2jul((*state).STAproton_onset[i])-IMF/velocity[i]/86400D + 8.33/1440D,/ccsds)
        							printf,lun,STEREO_proton[i],(*state).STAproton_onset[i],IMF/velocity[i],release_time,1,format='(F-25.4,A-25,F-25.4,A-25,I-20)'
      							endif else begin
        						printf,lun,STEREO_proton[i],(*state).STAproton_onset[i],IMF/velocity[i],'Invalid',0,format='(F-25.4,A-25,F-25.4,A-25,I-20)'
        						endelse
  							endfor
  							free_lun,lun
  						end
  	"save_STBproton_result":begin
    						name = dialog_pickfile(/write,file='result_STBproton.dat',path='/Users/zigongxu/Documents/work/myWork2_GCS_releasetime/result/'+event_num)
							  velocity=calculate_velocity(STEREO_proton,unit='MeV',particle='proton',light_speed=light_speed)
							  IMF=length_of_IMF(solar_wind_speed,l_au=len)
							  openw,lun,name,/get_lun
							  printf,lun,'STEREO B proton result from TSA and VDA(date: '+event_num+');Updata in '+systime()
  							printf,lun,'Energy(MeV)','Onset_time','travel time(solar speed)','Release time(+8.3 min)','quality',format='(4A-25,A-20)'
  							print,(*state).energy_channel_STB_proton
  							for i=0,N_elements((*state).energy_channel_STB_proton)-1 do begin 

      							if (*state).energy_channel_STB_proton[i] eq 1 then begin
      								release_time=jul2any(any2jul((*state).STBproton_onset[i])-IMF/velocity[i]/86400D + 8.33/1440D,/ccsds)
        							printf,lun,STEREO_proton[i],(*state).STBproton_onset[i],IMF/velocity[i],release_time,1,format='(F-25.4,A-25,F-25.4,A-25,I-20)'
      							endif else begin
        						printf,lun,STEREO_proton[i],(*state).STBproton_onset[i],IMF/velocity[i],'Invalid',0,format='(F-25.4,A-25,F-25.4,A-25,I-20)'
        						endelse
  							endfor
  							free_lun,lun

  						end
  	"save_STAelectron_result":begin
  	             name = dialog_pickfile(/write,file='result_STAelectron.dat',path='/Users/zigongxu/Documents/work/myWork2_GCS_releasetime/result/'+event_num)
                velocity=calculate_velocity(STEREO_electron,unit='KeV',particle='electron',light_speed=light_speed)
                IMF=length_of_IMF(solar_wind_speed,l_au=len)
                openw,lun,name,/get_lun
                printf,lun,'STEREO A electron result from TSA and VDA(date: '+event_num+');Updata in '+systime()
  							printf,lun,'Energy(KeV)','Onset_time','travel time(solar speed)','Release time(+8.3 min)','quality',format='(4A-25,A-20)'
  							print,(*state).energy_channel_STA_electron
  							for i=0,N_elements((*state).energy_channel_STA_electron)-1 do begin 
      							if (*state).energy_channel_STA_electron[i] eq 1 then begin

      								;print,(*state).STAelectron_onset[i]
      								temp=(any2jul((*state).STAelectron_onset[i])-IMF/velocity[i]/86400D + 8.33/1440D)
      								caldat,temp,a1,a2,a3,a4,a5,a6
      								;print,a1,a2,a3,a4,a5,a6
      								release_time=jul2any(temp,/ccsds)
        							printf,lun,STEREO_electron[i],(*state).STAelectron_onset[i],IMF/velocity[i],release_time,1,format='(F-25.4,A-25,F-25.4,A-25,I-20)'
      							endif else begin
        						printf,lun,STEREO_electron[i],(*state).STAelectron_onset[i],IMF/velocity[i],'Invalid',0,format='(F-25.4,A-25,F-25.4,A-25,I-20)'
        						endelse
  							endfor
  							free_lun,lun

  						end
  	"save_STBelectron_result":begin
  	   				  name = dialog_pickfile(/write,file='result_STBelectron.dat',path='/Users/zigongxu/Documents/work/myWork2_GCS_releasetime/result/'+event_num)
                velocity=calculate_velocity(STEREO_electron,unit='KeV',particle='electron',light_speed=light_speed)
                IMF=length_of_IMF(solar_wind_speed,l_au=len)
                openw,lun,name,/get_lun
							  printf,lun,'STEREO B electron result from TSA and VDA(date: '+event_num+');Updata in '+systime()
  							printf,lun,'Energy(KeV)','Onset_time','travel time(solar speed)','Release time(+8.3 min)','quality',format='(4A-25,A-20)'
  							print,(*state).energy_channel_STB_electron
  							for i=0,N_elements((*state).energy_channel_STB_electron)-1 do begin 
      							if (*state).energy_channel_STB_electron[i] eq 1 then begin
      								release_time=jul2any(any2jul((*state).STBelectron_onset[i])-IMF/velocity[i]/86400D + 8.33/1440D,/ccsds)
        							printf,lun,STEREO_electron[i],(*state).STBelectron_onset[i],IMF/velocity[i],release_time,1,format='(F-25.4,A-25,F-25.4,A-25,I-20)'
      							endif else begin
        						printf,lun,STEREO_electron[i],(*state).STBelectron_onset[i],IMF/velocity[i],'Invalid',0,format='(F-25.4,A-25,F-25.4,A-25,I-20)'
        						endelse
  							endfor
  							free_lun,lun  	
  						end
 	endcase
end

pro background_soho_event,event
	common Version_block, event_num,Eruption_time,Start_day,end_day,back_start_time,back_end_time,solar_wind_speed,data_path

	widget_control,event.top,get_uvalue=state
	widget_control,event.ID,get_uvalue=event_state

	if event_state eq 'background start time' then begin
			widget_control,event.id,get_value=x
			;print,x
			widget_control,(*state).soho_draw,get_value=drawID
			wset,drawID
			vline,any2jul(x),linestyle=2,color='red'
			back_start_time=x
			end
	if event_state eq 'background end time' then begin
			widget_control,event.id,get_value=x
			widget_control,(*state).soho_draw,get_value=drawID
			wset,drawID
			vline,any2jul(x),linestyle=2,color='red'
			back_end_time=x
			end;
end
pro background_wind_event,event
	common Version_block, event_num,Eruption_time,Start_day,end_day,back_start_time,back_end_time,solar_wind_speed,data_path

	widget_control,event.top,get_uvalue=state
	widget_control,event.ID,get_uvalue=event_state

	if event_state eq 'background start time' then begin
			widget_control,event.id,get_value=x
			;print,x
			widget_control,(*state).wind_draw,get_value=drawID
			wset,drawID
			vline,any2jul(x),linestyle=2,color='red'
			back_start_time=x
			end
	if event_state eq 'background end time' then begin
			widget_control,event.id,get_value=x
			widget_control,(*state).wind_draw,get_value=drawID
			wset,drawID
			vline,any2jul(x),linestyle=2,color='red'
			back_end_time=x
			end;
end
pro background_STAproton_event,event
	common Version_block, event_num,Eruption_time,Start_day,end_day,back_start_time,back_end_time,solar_wind_speed,data_path

	widget_control,event.top,get_uvalue=state
	widget_control,event.ID,get_uvalue=event_state

	if event_state eq 'background start time' then begin
			widget_control,event.id,get_value=x
			;print,x
			widget_control,(*state).STAproton_draw,get_value=drawID
			wset,drawID
			vline,any2jul(x),linestyle=2,color='red'
			back_start_time=x
			end
	if event_state eq 'background end time' then begin
			widget_control,event.id,get_value=x
			widget_control,(*state).STAproton_draw,get_value=drawID
			wset,drawID
			vline,any2jul(x),linestyle=2,color='red'
			back_end_time=x
			end;
end
pro background_STAelectron_event,event
	common Version_block, event_num,Eruption_time,Start_day,end_day,back_start_time,back_end_time,solar_wind_speed,data_path

	widget_control,event.top,get_uvalue=state
	widget_control,event.ID,get_uvalue=event_state

	if event_state eq 'background start time' then begin
			widget_control,event.id,get_value=x
			;print,x
			widget_control,(*state).STAelectron_draw,get_value=drawID
			wset,drawID
			vline,any2jul(x),linestyle=2,color='red'
			back_start_time=x
			end
	if event_state eq 'background end time' then begin
			widget_control,event.id,get_value=x
			widget_control,(*state).STAelectron_draw,get_value=drawID
			wset,drawID
			vline,any2jul(x),linestyle=2,color='red'
			back_end_time=x
			end;
end

pro background_STBproton_event,event
	common Version_block, event_num,Eruption_time,Start_day,end_day,back_start_time,back_end_time,solar_wind_speed,data_path

	widget_control,event.top,get_uvalue=state
	widget_control,event.ID,get_uvalue=event_state

	if event_state eq 'background start time' then begin
			widget_control,event.id,get_value=x
			;print,x
			widget_control,(*state).STBproton_draw,get_value=drawID
			wset,drawID
			vline,any2jul(x),linestyle=2,color='red'
			back_start_time=x
			end
	if event_state eq 'background end time' then begin
			widget_control,event.id,get_value=x
			widget_control,(*state).STBproton_draw,get_value=drawID
			wset,drawID
			vline,any2jul(x),linestyle=2,color='red'
			back_end_time=x
			end;
end
pro background_STBelectron_event,event
	common Version_block, event_num,Eruption_time,Start_day,end_day,back_start_time,back_end_time,solar_wind_speed,data_path
	widget_control,event.top,get_uvalue=state
	widget_control,event.ID,get_uvalue=event_state
	if event_state eq 'background start time' then begin
			widget_control,event.id,get_value=x
			;print,x
			widget_control,(*state).STBelectron_draw,get_value=drawID
			wset,drawID
			vline,any2jul(x),linestyle=2,color='red'
			back_start_time=x
			end
	if event_state eq 'background end time' then begin
			widget_control,event.id,get_value=x
			widget_control,(*state).STBelectron_draw,get_value=drawID
			wset,drawID
			vline,any2jul(x),linestyle=2,color='red'
			back_end_time=x
			end;
end
pro smooth_event,event
	common Version_block, event_num,Eruption_time,Start_day,end_day,back_start_time,back_end_time,solar_wind_speed,smooth_num
	widget_control,event.id,get_value=smooth_num
	smooth_num = smooth_num[0]
	help, smooth_num
	print,smooth_num[0]
end

pro save_allimage_event,event
	widget_control,event.top,get_uvalue=state
	common Version_block, event_num,Eruption_time,Start_day,end_day,back_start_time,back_end_time,solar_wind_speed,smooth_num
	
	set_plot,'ps'
	filename = dialog_pickfile(/write,file=event_num+'.eps',path='/Users/zigongxu/Documents/work/myWork2_GCS_releasetime/image/'+event_num)
	device,filename=filename,/portrait,yoffset=2,/inch,xsize=7,ysize=7
	!p.multi=[6,2,3]

	quicklook_soho_proton,event_num,soho_data=(*state).soho_data,soho_jul=(*state).soho_jul,energy_channel=(*state).energy_channel_soho,$
		start_day=start_day,end_day=end_day,Eruption_time=Eruption_time
	quicklook_wind_electron,event_num,wind_data=(*state).wind_data,wind_jul=(*state).wind_jul,energy_channel=(*state).energy_channel_wind,$
		start_day=start_day,end_day=end_day,Eruption_time=Eruption_time
	quicklook_STA_proton,event_num,STALET_data=(*state).STALET_data,STALET_jul=(*state).STALET_jul,STAHET_data=(*state).STAHET_data,STAHET_jul= (*state).STAHET_jul,$
		energy_channel=(*state).energy_channel_STA_proton,start_day=start_day,end_day=end_day,Eruption_time=Eruption_time[0],smooth_num=smooth_num[0]
	quicklook_STA_electron,event_num,STAelectron_data=(*state).STAelectron_data,STAelectron_jul=(*state).STAelectron_jul,energy_channel=(*state).energy_channel_STA_electron,$
		start_day=start_day,end_day=end_day,Eruption_time=Eruption_time[0],smooth_num=smooth_num[0]
	quicklook_STB_proton,event_num,STBLET_data=(*state).STBLET_data,STBLET_jul=(*state).STBLET_jul,STBHET_data=(*state).STBHET_Data,STBHET_jul= (*state).STBHET_jul,energy_channel=(*state).energy_channel_STB_proton,$
		start_day=start_day,end_day=end_day,Eruption_time=Eruption_time[0],smooth_num=smooth_num[0]
	quicklook_STB_electron,event_num,STBelectron_data=STBelectron_data,STBelectron_jul=STBelectron_jul,energy_channel=(*state).energy_channel_STB_electron,$
		start_day=start_day,end_day=end_day,Eruption_time=Eruption_time[0],smooth_num=smooth_num[0]
	!p.multi=0
	device,/close_file
	set_plot,'x'
end
Pro Version_1
	;
	;
	;Modification history: 
	;2017.9.21 xuzigong
	;2018.06.12; change the size of window to fit a small screen
	common Version_block, event_num,Eruption_time,Start_day,end_day,back_start_time,back_end_time,solar_wind_speed,smooth_num,data_path
	data_path='./data/'
  data_dir=data_path
	smooth_num = '0'
	solar_wind_speed ='400000'
	wxy=get_screen_size()
	;group_leader = widget_base(map =0)
	;widget_control,group_leader,/realize

	wbase = widget_base(/column,/BASE_ALIGN_TOP,xoffset=wxy[0]/10,units=0,/scroll,scr_xsize=0.85*wxy[0],scr_ysize = 0.95*wxy[1]);,group_leader=group_leader)

	wtB0 = widget_base(wbase,/row,/frame)
	row1 = widget_label(wtb0,value='Event Num:')
	wTopText = WIDGET_text(wtb0,/editable,uvalue='Event Num',value='20100814',event_pro='Version_1_event',/all_events)
	row2 = Widget_label(wtb0,value = 'Eruption time')
	wTopText2 = widget_text(wtb0,/editable,uvalue='Eruption time',value='2010-08-14T10:00:00',event_pro='Version_1_event',/all_events)
	row3 = widget_label(wtb0,value='Start Day')
	wTopText3 = widget_text(wtb0,/editable,uvalue = 'Start Day',value='2010-08-14T00:00:00',event_pro='Version_1_event',/all_events)
	row4 =widget_label(wtb0,value='End Day')
	wTopText4 = widget_text(wtb0,/editable,uvalue ='End Day',value='2010-08-14T23:59:59',event_pro='Version_1_event',/all_events)

	solar_wind= widget_label(wtb0,value='solar wind speed(m/s)')
 	solar_wind_text = widget_text(wtb0,value=solar_wind_speed,uvalue='solar wind speed',/editable)

 	wTopbutton_clean  = widget_button(wtb0,value='clean',event_pro='clean_event')

	
;----------------------------
	wTB = widget_tab(wbase,/align_top); leader
;---------------
	wT1 = WIDGET_BASE(wTB,title='L1',/column)

	wlabel1 = WIDGET_label(wT1,value='Soho proton')
	wbase_soho = widget_base(wT1,/row,/frame)
	wbase_subsoho = widget_base(wbase_soho,/frame,/column)
	soho = widget_button(wbase_subsoho,value='quicklook',uvalue='quicklook',event_pro='soho_event')
	onset = widget_button(wbase_subsoho,value='onset time',uvalue='onset_time',event_pro='soho_event')
	channel_base_label = widget_label(wbase_subsoho,value='energy channel')
	channel_base = widget_base(wbase_subsoho,/frame,/nonexclusive,/column,/scroll,scr_xsize=150,scr_ysize=300)
	;---
	channel_shoh_1 =widget_button(channel_base,value ='15.4MeV',event_pro='energy_channel_event_soho')
	channel_shoh_2 =widget_button(channel_base,value ='18.9MeV',event_pro='energy_channel_event_soho')
	channel_shoh_3 =widget_button(channel_base,value ='23.3MeV',event_pro='energy_channel_event_soho')
	channel_shoh_4 =widget_button(channel_base,value ='29.1MeV',event_pro='energy_channel_event_soho')
	channel_shoh_5 =widget_button(channel_base,value ='36.4MeV',event_pro='energy_channel_event_soho')
	channel_shoh_6 =widget_button(channel_base,value ='45.6MeV',event_pro='energy_channel_event_soho')
	channel_shoh_7 =widget_button(channel_base,value ='57.4MeV',event_pro='energy_channel_event_soho')
	channel_shoh_8 =widget_button(channel_base,value ='72.0MeV',event_pro='energy_channel_event_soho')
	channel_shoh_9 =widget_button(channel_base,value ='90.5MeV',event_pro='energy_channel_event_soho')
	channel_shoh_10 =widget_button(channel_base,value ='108.0MeV',event_pro='energy_channel_event_soho')
	;---
	sub_soho_draw = widget_base(wbase_soho,/column)
	soho_draw = widget_draw(sub_soho_draw,xsize=0.4*wxy[0],ysize=wxy[1]/3D,/retain,units=0);,/button_events,event_pro='background_event')
	soho_draw_save_dir = widget_text(sub_soho_draw,uvalue='',/editable)
	soho_draw_save= widget_button(sub_soho_draw,value='save',uvalue ='save',event_pro='save_soho_event')
	widget_control,soho_draw_save,set_uvalue=soho_draw_save_dir
 	
 	background = widget_base(sub_soho_draw,/row)
 	background_label = widget_label(background,value='select background',uvalue ='background');,event_pro='background_event')
 	background_start = widget_text(background,value='2010-08-14T10:00:00',uvalue='background start time',/editable,event_pro= 'background_soho_event')
 	background_label_2= widget_label(background,value='-')
 	background_end    = widget_text(background,value='2010-08-14T10:30:00',uvalue ='background end time',/editable,event_pro = 'background_soho_event')
 	sub_soho_result = widget_base(wbase_soho,/column,/frame)
 	;print,0.3*wxy[1]
 	sub_soho_result_text = widget_text(sub_soho_result,value='',editable=0,xsize=40,ysize=20,/scroll)
 	;print,wxy
 	sub_soho_result_save = widget_button(sub_soho_result,value='save',uvalue='save_soho_result',event_pro='save_result_event')
 	widget_control,onset,set_uvalue = sub_soho_result_text
	;--------------------WIND ------------------
	;--------------------WIND-------------------
	wlabel1 = WIDGET_label(wT1,value='WIND electron')
	wbase_wind = widget_base(wT1,/row,/frame)
	wbase_subwind = widget_base(wbase_wind,/frame,/column)
	wind = widget_button(wbase_subwind,value='quicklook',uvalue='quicklook',event_pro='wind_event')
	WIND_onset = widget_button(wbase_subwind,value='onset time',uvalue='onset_time',event_pro='wind_event')
	channel_base_label = widget_label(wbase_subwind,value='energy channel')
	channel_base = widget_base(wbase_subwind,/frame,/nonexclusive,/column,/scroll,scr_xsize=150,scr_ysize=300)
	;---
	channel_wind_1 =widget_button(channel_base,value ='27.0KeV' ,event_pro='energy_channel_event_wind')
	channel_wind_2 =widget_button(channel_base,value ='40.1KeV' ,event_pro='energy_channel_event_wind')
	channel_wind_3 =widget_button(channel_base,value ='66.2KeV' ,event_pro='energy_channel_event_wind')
	channel_wind_4 =widget_button(channel_base,value ='108.4KeV',event_pro='energy_channel_event_wind')
	channel_wind_5 =widget_button(channel_base,value ='181.8KeV',event_pro='energy_channel_event_wind')
	channel_wind_6 =widget_button(channel_base,value ='309.5KeV',event_pro='energy_channel_event_wind')
	channel_wind_7 =widget_button(channel_base,value ='516.8KeV',event_pro='energy_channel_event_wind')
	;---
	sub_wind_draw = widget_base(wbase_wind,/column)
	wind_draw = widget_draw(sub_wind_draw,xsize=0.4*wxy[0],ysize=wxy[1]/3D,/retain,units=0);,/button_events,event_pro='background_event')
	wind_draw_save_dir = widget_text(sub_wind_draw,uvalue='',/editable)
	wind_draw_save= widget_button(sub_wind_draw,value='save',uvalue ='save',event_pro='save_wind_event')
	widget_control,wind_draw_save,set_uvalue=wind_draw_save_dir
 	
 	background = widget_base(sub_wind_draw,/row)
 	background_label = widget_label(background,value='select background',uvalue ='background');,event_pro='background_event')
 	background_start = widget_text(background,value='2010-08-14T10:00:00',uvalue='background start time',/editable,event_pro= 'background_wind_event')
 	background_label_2= widget_label(background,value='-')
 	background_end    = widget_text(background,value='2010-08-14T10:30:00',uvalue ='background end time',/editable,event_pro = 'background_wind_event')
 	sub_wind_result = widget_base(wbase_wind,/column,/frame)

 	sub_wind_result_text = widget_text(sub_wind_result,value='',editable=0,xsize=40,ysize=20,/scroll)
 	;print,wxy
 	sub_wind_result_save = widget_button(sub_wind_result,value='save',uvalue='save_wind_result',event_pro='save_result_event')
 	widget_control,WIND_onset,set_uvalue = sub_wind_result_text
;------------------WIND
;------------------STA_proton_start-----------------------------

	wT2 = WIDGET_BASE(wTB,title='STA',/column,uvalue='STA_tab')
	;help, wT2 
	wlabel2 = WIDGET_label(wT2,value='STA proton(warning: the data should be in the same month)')

	wbase_STAproton = widget_base(wT2,/row,/frame)
	wbase_subSTAproton = widget_base(wbase_STAproton,/frame,/column)
	STAproton = widget_button(wbase_subSTAproton,value='quicklook',uvalue='quicklook',event_pro='STAproton_event')
	STAproton_onset = widget_button(wbase_subSTAproton,value='onset time',uvalue='onset_time',event_pro='STAproton_event')
	STAproton_smooth =widget_base(wbase_subSTAproton,/row)
	;--------
	STAproton_smooth_button = widget_label(STAproton_smooth,value='smooth')
	STAproton_smooth_text = widget_text(STAproton_smooth,value=smooth_num,uvalue='STA_proton_smooth',/editable,event_pro='smooth_event',/all_events)
	widget_control,STAproton_smooth_button,get_uvalue=STA_proton_smooth_text
	;---------
	channel_base_label = widget_label(wbase_subSTAproton,value='energy channel')
	channel_base_all = widget_base(wbase_subSTAproton,/row,/scroll,scr_ysize=300,scr_xsize=250)
	channel_base1 = widget_base(channel_base_all,/frame,/nonexclusive,/column)
	;---
	channel_STAproton_1 =widget_button(channel_base1,value  ='1.8-3.6MeV',  event_pro='energy_channel_event_STA_proton')
	channel_STAproton_2 =widget_button(channel_base1,value  ='4.0-6.0MeV',  event_pro='energy_channel_event_STA_proton')
	channel_STAproton_3 =widget_button(channel_base1,value  ='6.0-10.0MeV', event_pro='energy_channel_event_STA_proton')
	channel_STAproton_4 =widget_button(channel_base1,value  ='10.0-15.0MeV',event_pro='energy_channel_event_STA_proton')
	channel_STAproton_5 =widget_button(channel_base1,value  ='13.6-15.1MeV',event_pro='energy_channel_event_STA_proton')
	channel_STAproton_6 =widget_button(channel_base1,value  ='14.9-17.1MeV',event_pro='energy_channel_event_STA_proton')
	channel_STAproton_7 =widget_button(channel_base1,value  ='17.0-19.3MeV',event_pro='energy_channel_event_STA_proton')
	channel_STAproton_8 =widget_button(channel_base1,value  ='20.8-23.8MeV',event_pro='energy_channel_event_STA_proton')

	channel_base2 = widget_base(channel_base_all,/frame,/nonexclusive,/column)

	channel_STAproton_9 =widget_button(channel_base2,value  ='23.8-26.4MeV',event_pro='energy_channel_event_STA_proton')
	channel_STAproton_10 =widget_button(channel_base2,value ='26.3-29.7MeV',event_pro='energy_channel_event_STA_proton')
	channel_STAproton_11 =widget_button(channel_base2,value ='29.5-33.4MeV',event_pro='energy_channel_event_STA_proton')
	channel_STAproton_12 =widget_button(channel_base2,value ='33.4-35.8MeV',event_pro='energy_channel_event_STA_proton')
	channel_STAproton_13 =widget_button(channel_base2,value ='35.5-40.5MeV',event_pro='energy_channel_event_STA_proton')
	channel_STAproton_14 =widget_button(channel_base2,value ='40.0-60.0MeV',event_pro='energy_channel_event_STA_proton')
	channel_STAproton_15 =widget_button(channel_base2,value ='60.0-100.0MeV',event_pro='energy_channel_event_STA_proton')
	;---
	sub_STAproton_draw = widget_base(wbase_STAproton,/column)
	STAproton_draw = widget_draw(sub_STAproton_draw,xsize=0.4*wxy[0],ysize=wxy[1]/3D,/retain,/renderer,units=0);,/button_events,event_pro='background_event')
	STAproton_draw_save_dir = widget_text(sub_STAproton_draw,uvalue='',/editable)
	STAproton_draw_save= widget_button(sub_STAproton_draw,value='save',uvalue ='save',event_pro='save_STAproton_event')
	widget_control,STAproton_draw_save,set_uvalue=STAproton_draw_save_dir
 	
 	background = widget_base(sub_STAproton_draw,/row)
 	background_label = widget_label(background,value='select background',uvalue ='background');,event_pro='background_event')
 	background_start = widget_text(background,value='2010-08-14T10:00:00',uvalue='background start time',/editable,event_pro= 'background_STAproton_event')
 	background_label_2= widget_label(background,value='-')
 	background_end    = widget_text(background,value='2010-08-14T10:30:00',uvalue ='background end time',/editable,event_pro = 'background_STAproton_event')
 	sub_STAproton_result = widget_base(wbase_STAproton,/column,/frame)
 	;print,0.3*wxy[1]
 	sub_STAproton_result_text = widget_text(sub_STAproton_result,value='',editable=0,xsize=40,ysize=20,/scroll)
 	;print,wxy
 	sub_STAproton_result_save = widget_button(sub_STAproton_result,value='save',uvalue='save_STAproton_result',event_pro='save_result_event')
 	widget_control,STAproton_onset,set_uvalue = sub_STAproton_result_text
;-----------------STA_proton_end--------------------------------------
;-----------------STA_electron_start---------------------------------

	wlabel2 = WIDGET_label(wT2,value='STA electron(warning: the data should be in the same month)')

	wbase_STAelectron = widget_base(wT2,/row,/frame)
	wbase_subSTAelectron = widget_base(wbase_STAelectron,/frame,/column)
	STAelectron = widget_button(wbase_subSTAelectron,value='quicklook',uvalue='quicklook',event_pro='STAelectron_event')
	STAelectron_onset = widget_button(wbase_subSTAelectron,value='onset time',uvalue='onset_time',event_pro='STAelectron_event')
	STAelectron_smooth =widget_base(wbase_subSTAelectron,/row)
	;--------
	STAelectron_smooth_button = widget_label(STAelectron_smooth,value='smooth')
	STAelectron_smooth_text = widget_text(STAelectron_smooth,value=smooth_num,uvalue='STA_proton_smooth',/editable,event_pro='smooth_event',/all_events)
	widget_control,STAelectron_smooth_button,get_uvalue=STA_electron_smooth_text
	;---------
	channel_base_label = widget_label(wbase_subSTAelectron,value='energy channel')

	channel_base_all = widget_base(wbase_subSTAelectron,/row,/scroll,scr_ysize=300,scr_xsize=250)

	channel_base1 = widget_base(channel_base_all,/frame,/nonexclusive,/column)

	;---
	channel_STAelectron_1 =widget_button(channel_base1,value  ='45.0-55.0KeV' 	,event_pro='energy_channel_event_STA_electron')
	channel_STAelectron_2 =widget_button(channel_base1,value  ='55.0-65.0KeV' 	,event_pro='energy_channel_event_STA_electron')
	channel_STAelectron_3 =widget_button(channel_base1,value  ='65.0-75.0KeV' 	,event_pro='energy_channel_event_STA_electron')
	channel_STAelectron_4 =widget_button(channel_base1,value  ='75.0-85.0KeV' 	,event_pro='energy_channel_event_STA_electron')
	channel_STAelectron_5 =widget_button(channel_base1,value  ='85.0-105.0KeV' 	,event_pro='energy_channel_event_STA_electron')
	channel_STAelectron_6 =widget_button(channel_base1,value  ='105.0-125.0KeV' ,event_pro='energy_channel_event_STA_electron')
	channel_STAelectron_7 =widget_button(channel_base1,value  ='125.0-145.0KeV' ,event_pro='energy_channel_event_STA_electron')
	channel_STAelectron_8 =widget_button(channel_base1,value  ='145.0-165.0KeV' ,event_pro='energy_channel_event_STA_electron')

	channel_base2 = widget_base(channel_base_all,/frame,/nonexclusive,/column)
	channel_STAelectron_9 =widget_button(channel_base2,value  ='165.0-195.0KeV' ,event_pro='energy_channel_event_STA_electron')
	channel_STAelectron_10 =widget_button(channel_base2,value ='195.0-225.0KeV' ,event_pro='energy_channel_event_STA_electron')
	channel_STAelectron_11 =widget_button(channel_base2,value ='225.0-255.0KeV' ,event_pro='energy_channel_event_STA_electron')
	channel_STAelectron_12 =widget_button(channel_base2,value ='255.0-295.0KeV' ,event_pro='energy_channel_event_STA_electron')
	channel_STAelectron_13 =widget_button(channel_base2,value ='295.0-335.0KeV' ,event_pro='energy_channel_event_STA_electron')
	channel_STAelectron_14 =widget_button(channel_base2,value ='335.0-375.0KeV' ,event_pro='energy_channel_event_STA_electron')
	channel_STAelectron_15 =widget_button(channel_base2,value ='375.0-425.0KeV' ,event_pro='energy_channel_event_STA_electron')
	;---
	sub_STAelectron_draw = widget_base(wbase_STAelectron,/column)
	STAelectron_draw = widget_draw(sub_STAelectron_draw,xsize=0.4*wxy[0],ysize=wxy[1]/3D,/retain,/renderer,units=0);,/button_events,event_pro='background_event')
	STAelectron_draw_save_dir = widget_text(sub_STAelectron_draw,uvalue='',/editable)
	STAelectron_draw_save= widget_button(sub_STAelectron_draw,value='save',uvalue ='save',event_pro='save_STAelectron_event')
	widget_control,STAelectron_draw_save,set_uvalue=STAelectron_draw_save_dir
 	
 	background = widget_base(sub_STAelectron_draw,/row)
 	background_label = widget_label(background,value='select background',uvalue ='background');,event_pro='background_event')
 	background_start = widget_text(background,value='2010-08-14T10:00:00',uvalue='background start time',/editable,event_pro= 'background_STAelectron_event')
 	background_label_2= widget_label(background,value='-')
 	background_end    = widget_text(background,value='2010-08-14T10:30:00',uvalue ='background end time',/editable,event_pro = 'background_STAelectron_event')
 	sub_STAelectron_result = widget_base(wbase_STAelectron,/column,/frame)
 	;print,0.3*wxy[1]
 	sub_STAelectron_result_text = widget_text(sub_STAelectron_result,value='',editable=0,xsize=40,ysize=20,/scroll)
 	;print,wxy
 	sub_STAelectron_result_save = widget_button(sub_STAelectron_result,value='save',uvalue='save_STAelectron_result',event_pro='save_result_event')
 	widget_control,STAelectron_onset,set_uvalue = sub_STAelectron_result_text

;-----------------STA_electron_end----------------------------------
;-----------------STB_proton_end-----------------------------------

	wT3 = WIDGET_BASE(wTB,title='STB',/column,uvalue='STB_tab')
	;help, wT2 
	wlabel3 = WIDGET_label(wT3,value='STB proton(warning: the data should be in the same month)')

	wbase_STBproton = widget_base(wT3,/row,/frame)
	wbase_subSTBproton = widget_base(wbase_STBproton,/frame,/column)
	STBproton = widget_button(wbase_subSTBproton,value='quicklook',uvalue='quicklook',event_pro='STBproton_event')
	STBproton_onset = widget_button(wbase_subSTBproton,value='onset time',uvalue='onset_time',event_pro='STBproton_event')
	STBproton_smooth =widget_base(wbase_subSTBproton,/row)
	;--------
	STBproton_smooth_button = widget_label(STBproton_smooth,value='smooth')
	STBproton_smooth_text = widget_text(STBproton_smooth,value=smooth_num,uvalue='STB_proton_smooth',/editable,event_pro='smooth_event',/all_events)
	widget_control,STBproton_smooth_button,get_uvalue=STB_proton_smooth_text
	;---------
	channel_base_label = widget_label(wbase_subSTBproton,value='energy channel')

	channel_base_all = widget_base(wbase_subSTBproton,/row,/scroll,scr_ysize=300,scr_xsize=250)

	channel_base1 = widget_base(channel_base_all,/frame,/nonexclusive,/column)
	;---
	channel_STBproton_1 =widget_button(channel_base1,value  ='1.8-3.6MeV',  event_pro='energy_channel_event_STB_proton')
	channel_STBproton_2 =widget_button(channel_base1,value  ='4.0-6.0MeV',  event_pro='energy_channel_event_STB_proton')
	channel_STBproton_3 =widget_button(channel_base1,value  ='6.0-10.0MeV', event_pro='energy_channel_event_STB_proton')
	channel_STBproton_4 =widget_button(channel_base1,value  ='10.0-15.0MeV',event_pro='energy_channel_event_STB_proton')
	channel_STBproton_5 =widget_button(channel_base1,value  ='13.6-15.1MeV',event_pro='energy_channel_event_STB_proton')
	channel_STBproton_6 =widget_button(channel_base1,value  ='14.9-17.1MeV',event_pro='energy_channel_event_STB_proton')
	channel_STBproton_7 =widget_button(channel_base1,value  ='17.0-19.3MeV',event_pro='energy_channel_event_STB_proton')
	channel_STBproton_8 =widget_button(channel_base1,value  ='20.8-23.8MeV',event_pro='energy_channel_event_STB_proton')

	channel_base2 = widget_base(channel_base_all,/frame,/nonexclusive,/column)

	channel_STBproton_9 =widget_button(channel_base2,value  ='23.8-26.4MeV',event_pro='energy_channel_event_STB_proton')
	channel_STBproton_10 =widget_button(channel_base2,value ='26.3-29.7MeV',event_pro='energy_channel_event_STB_proton')
	channel_STBproton_11 =widget_button(channel_base2,value ='29.5-33.4MeV',event_pro='energy_channel_event_STB_proton')
	channel_STBproton_12 =widget_button(channel_base2,value ='33.4-35.8MeV',event_pro='energy_channel_event_STB_proton')
	channel_STBproton_13 =widget_button(channel_base2,value ='35.5-40.5MeV',event_pro='energy_channel_event_STB_proton')
	channel_STBproton_14 =widget_button(channel_base2,value ='40.0-60.0MeV',event_pro='energy_channel_event_STB_proton')
	channel_STBproton_15 =widget_button(channel_base2,value ='60.0-100.0MeV',event_pro='energy_channel_event_STB_proton')
	;---
	sub_STBproton_draw = widget_base(wbase_STBproton,/column)
	STBproton_draw = widget_draw(sub_STBproton_draw,xsize=0.4*wxy[0],ysize=wxy[1]/3D,/retain,/renderer,units=0);,/button_events,event_pro='background_event')
	STBproton_draw_save_dir = widget_text(sub_STBproton_draw,uvalue='',/editable)
	STBproton_draw_save= widget_button(sub_STBproton_draw,value='save',uvalue ='save',event_pro='save_STBproton_event')
	widget_control,STBproton_draw_save,set_uvalue=STBproton_draw_save_dir
 	
 	background = widget_base(sub_STBproton_draw,/row)
 	background_label = widget_label(background,value='select background',uvalue ='background');,event_pro='background_event')
 	background_start = widget_text(background,value='2010-08-14T10:00:00',uvalue='background start time',/editable,event_pro= 'background_STBproton_event')
 	background_label_2= widget_label(background,value='-')
 	background_end    = widget_text(background,value='2010-08-14T10:30:00',uvalue ='background end time',/editable,event_pro = 'background_STBproton_event')
 	sub_STBproton_result = widget_base(wbase_STBproton,/column,/frame)
 	;print,0.3*wxy[1]
 	sub_STBproton_result_text = widget_text(sub_STBproton_result,value='',editable=0,xsize=40,ysize=20,/scroll)
 	;print,wxy
 	sub_STBproton_result_save = widget_button(sub_STBproton_result,value='save',uvalue='save_STBproton_result',event_pro='save_result_event')
 	widget_control,STBproton_onset,set_uvalue = sub_STBproton_result_text



;----------------STB_proton_end------------------------------------
;----------------STB_electron_start--------------------------------
	;help, wT2 
	wlabel3 = WIDGET_label(wT3,value='STB electron(warning: the data should be in the same month)')

	wbase_STBelectron = widget_base(wT3,/row,/frame)
	wbase_subSTBelectron = widget_base(wbase_STBelectron,/frame,/column)
	STBelectron = widget_button(wbase_subSTBelectron,value='quicklook',uvalue='quicklook',event_pro='STBelectron_event')
	STBelectron_onset = widget_button(wbase_subSTBelectron,value='onset time',uvalue='onset_time',event_pro='STBelectron_event')
	STBelectron_smooth =widget_base(wbase_subSTBelectron,/row)
	;--------
	STBelectron_smooth_button = widget_label(STBelectron_smooth,value='smooth')
	STBelectron_smooth_text = widget_text(STBelectron_smooth,value=smooth_num,uvalue='STB_electron_smooth',/editable,event_pro='smooth_event',/all_events)
	widget_control,STBelectron_smooth_button,get_uvalue=STB_electron_smooth_text
	;---------
	channel_base_label = widget_label(wbase_subSTBelectron,value='energy channel')

	channel_base_all = widget_base(wbase_subSTBelectron,/row,/scroll,scr_ysize=300,scr_xsize=250)
	channel_base = widget_base(channel_base_all,/frame,/nonexclusive,/column)
	;---
	channel_STBelectron_1 =widget_button(channel_base,value  ='45.0-55.0KeV',event_pro='energy_channel_event_STB_electron')
	channel_STBelectron_2 =widget_button(channel_base,value  ='55.0-65.0KeV',event_pro='energy_channel_event_STB_electron')
	channel_STBelectron_3 =widget_button(channel_base,value  ='65.0-75.0KeV', event_pro='energy_channel_event_STB_electron')
	channel_STBelectron_4 =widget_button(channel_base,value  ='75.0-85.0KeV', event_pro='energy_channel_event_STB_electron')
	channel_STBelectron_5 =widget_button(channel_base,value  ='85.0-105.0KeV',event_pro='energy_channel_event_STB_electron')
	channel_STBelectron_6 =widget_button(channel_base,value  ='105.0-125.0KeV',event_pro='energy_channel_event_STB_electron')
	channel_STBelectron_7 =widget_button(channel_base,value  ='125.0-145.0KeV',event_pro='energy_channel_event_STB_electron')
	channel_STBelectron_8 =widget_button(channel_base,value  ='145.0-165.0KeV',event_pro='energy_channel_event_STB_electron')

	channel_base = widget_base(channel_base_all,/frame,/nonexclusive,/column)
	channel_STBelectron_9 =widget_button(channel_base,value  ='165.0-195.0KeV',event_pro='energy_channel_event_STB_electron')
	channel_STBelectron_10 =widget_button(channel_base,value ='195.0-225.0KeV',event_pro='energy_channel_event_STB_electron')
	channel_STBelectron_11 =widget_button(channel_base,value ='225.0-255.0KeV',event_pro='energy_channel_event_STB_electron')
	channel_STBelectron_12 =widget_button(channel_base,value ='255.0-295.0KeV',event_pro='energy_channel_event_STB_electron')
	channel_STBelectron_13 =widget_button(channel_base,value ='295.0-335.0KeV',event_pro='energy_channel_event_STB_electron')
	channel_STBelectron_14 =widget_button(channel_base,value ='335.0-375.0KeV',event_pro='energy_channel_event_STB_electron')
	channel_STBelectron_15 =widget_button(channel_base,value ='375.0-425.0KeV',event_pro='energy_channel_event_STB_electron')

	;---
	sub_STBelectron_draw = widget_base(wbase_STBelectron,/column)
	STBelectron_draw = widget_draw(sub_STBelectron_draw,xsize=0.4*wxy[0],ysize=wxy[1]/3D,/retain,/renderer,units=0);,/button_events,event_pro='background_event')
	STBelectron_draw_save_dir = widget_text(sub_STBelectron_draw,uvalue='',/editable)
	STBelectron_draw_save= widget_button(sub_STBelectron_draw,value='save',uvalue ='save',event_pro='save_STBelectron_event')
	widget_control,STBelectron_draw_save,set_uvalue=STBelectron_draw_save_dir
 	
 	background = widget_base(sub_STBelectron_draw,/row)
 	background_label = widget_label(background,value='select background',uvalue ='background');,event_pro='background_event')
 	background_start = widget_text(background,value='2010-08-14T10:00:00',uvalue='background start time',/editable,event_pro= 'background_STBelectron_event')
 	background_label_2= widget_label(background,value='-')
 	background_end    = widget_text(background,value='2010-08-14T10:30:00',uvalue ='background end time',/editable,event_pro = 'background_STBelectron_event')
 	sub_STBelectron_result = widget_base(wbase_STBelectron,/column,/frame)
 	;print,0.3*wxy[1]
 	sub_STBelectron_result_text = widget_text(sub_STBelectron_result,value='',editable=0,xsize=40,ysize=20,/scroll)
 	;print,wxy
 	sub_STBelectron_result_save = widget_button(sub_STBelectron_result,value='save',uvalue='save_STBelectron_result',event_pro='save_result_event')
 	widget_control,STBelectron_onset,set_uvalue = sub_STBelectron_result_text

;----------------STB_electron_end---------------------------------
;----------------CME fitting analysis---------------------------

;------------------------------------
	
	wtB1 = widget_base(wbase,/frame,/row)
	done_button = widget_button(wtb1,value='Done',event_pro='quit_event')
	save_allimage_button  = widget_button(wtb1,value='save_allimage',event_pro='save_allimage_event')
	energy_channel_initial_soho=[0,0,0,0,0,0,0,0,0,0]
	energy_channel_initial_wind=[0,0,0,0,0,0,0]
	energy_channel_initial_STA_proton=[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
	energy_channel_initial_STB_proton=[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
	energy_channel_initial_STA_electron=[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
	energy_channel_initial_STB_electron=[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]

	data=0&jul=0&onset=0
	;if file_exist(data_dir+event_num+'/'+event_num+'.dat') then begin
	;	restore,data_dir+event_num+'/'+event_num+'.dat',/ver 
	;endif else begin
	state=ptr_new({soho_draw:soho_draw,STAproton_draw:STAproton_draw,STBproton_draw:STBproton_draw,STBelectron_draw:STBelectron_draw,STAelectron_draw:STAelectron_draw,wind_draw:wind_draw,energy_channel_soho:energy_channel_initial_soho,$
		energy_channel_wind:energy_channel_initial_wind,$
		energy_channel_STA_proton:energy_channel_initial_STA_proton,$
		energy_channel_STB_proton:energy_channel_initial_STB_proton,$
		energy_channel_STA_electron:energy_channel_initial_STA_electron,$
		energy_channel_STB_electron:energy_channel_initial_STB_electron});,soho_data:data,soho_jul:jul,soho_onset:onset[0]})
	widget_control,wbase,set_uvalue=state
	widget_control,wbase,/realize
	xmanager,'Version_1',wbase,/no_block;,group_leader=group_leader
    
   ; ptr_free,state
	;subbase1=widget_base(wbase,/row)
	;draw = widget_draw(subbase1,event_pro='draw_event',/button_events,retain=2,xsize=400,ysize=400)
	;draw2 = widget_draw(subbase1,event_pro='draw_event',xsize=400,ysize=400)
	;state={draw:draw,draw2:draw2}
	;widget_control,wbase,set_uvalue=state

	;b_quit = widget_button(wbase,Value='quit',event_pro='quit_event')
	;widget_control,wbase,/realize
	;xmanager,'Version_1',wbase
end