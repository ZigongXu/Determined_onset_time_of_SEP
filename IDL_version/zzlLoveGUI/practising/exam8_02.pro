pro Subprocedure, Event
	If tag_names(event,/Structure_name) eq 'WIDGET_kILL_REQUEST' THEN begin
	print,'窗口退出'
	WIDGET_CONTROL, event.top,/destroy
	endif

	if Tag_names(event,/structure_name) eq 'WIDGET_TLB_MOVE' then print, EVEnt.x,event.y,format="('窗口被移动到(',I3,',',I3,')')"
	if TAG_names(event,/STRUCTURE_name) eq 'WIDGET_TLE_ICONIFY' then begin 
		if event.ICONIFIED eq 1 then print,'窗口最小化' else print,'窗口恢复'
	endif
	IF tag_names(event,/STRUcture_name) eq 'WIDGET_BASE' then print, event.x,event.y, format="('窗口大小改变为（‘,I3,',',I3,')')"
end

pro exam8_02
	myBase = WIDGET_BASE(xsize=500,ysize=400,title='MyBase',EVENT_PRO='Subprocedure',/TLB_KILL_REQUEST_EVENTS,$
		/TLB_MOVE_EVENTS,/TLB_SIZE_EVENTS,/TLB_ICONIFY_EVENTS)
	widget_control,myBase, /realize
	Xmanager,'exam8_02',EVENT_Handler='Subprocedure',mybase
end