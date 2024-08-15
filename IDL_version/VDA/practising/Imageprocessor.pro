Pro Imageprocessor

	wxy = get_screen_size()
	drawx = wxy[0]*0.8
	drawy = wxy[0]*0.8

	;--
	title='imageProcessor'

	Wtop = widget_base(title= title, /row, mbar = menubar)

	wfilemenu = widget_button(menubar, value = '文件',/menu,event_pro='')
	wopen = widget_button(wfilemenu, value='打开',uname='open')
	wsave = widget_button(wfilemenu, value='保存',uname='save')
	wexit = widget_button(wfilemenu, value='退出',uname='exit',/separator)

	wtoolsbase = widget_base(wtop,/column, event_Pro='')
	wsmooth = widget_button(wtoolsbase,value='Smooth',uname='smooth')
	wusmask = widget_button(wtoolsbase,value='Unsharp Mask',uname='umask')
	wthresh = widget_slider(wtoolsbase,title='Threshold',min=-255,max=255,value=0,uname='thresh')
	wscale  = widget_slider(wtoolsbase,title='Scale', min=0,max=255,value=0,uname='scale')
	wbscale = widget_button(wtoolsbase,value='Grey',uname='bscale')
	wloadct = widget_button(wtoolsbase,value='Load Color Table',uname='loadct')
	wrevert = widget_button(wtoolsbase,value='Revert',uname='revert')
	wtext   = widget_text(wtoolsbase,/All_events,/editable,value='',uname='text')
	wmessage = widget_text(wtoolsbase,value='',uname='message')

	wdraw = widget_draw( wtop,uname='draw',xsize=drawx,ysize=drawy,retain=2,/fram,$
		event_pro='imageprocess_draw')
	xy= widget_info(wtop,/geo)
	offsetxy= (wxy - [xy.scr_xsize,xy.scr_ysize])/2
	widget_control, wtop, xoffset=offsetxy[0],yoffset= offsetxy[1]
	widget_control, wtop,/realize
end
