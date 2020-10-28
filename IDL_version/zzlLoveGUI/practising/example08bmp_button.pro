pro L1, event
	result=DIALOG_MESSAGE('Welcome using L1',/information)
end

pro STA,event
	result=DIALOG_MESSAGE('Welcome using STEREO A',/information)
end

Pro STB, event
	result=DIALOG_message('Welcome using STEREO B',/information)
end

pro exitprocedure,event
	widget_control,event.top,/destroy
end

pro example08bmp_button
	mybase = WIDGET_BASE(Xsize=500,ysize=600,title='myBase')
	Mybutton = WIDGET_BUTTON(MyBase, Value='button.bmp',/bitmap,event_pro='L1',xsize=300,ysize=150,xoffset=100,yoffset=30)
	Mybutton = WIDGET_BUTTON(MyBase, Value='button.bmp',/bitmap,event_pro='STA',xsize=300,ysize=150,xoffset=100,yoffset=200)
	Mybutton = WIDGET_BUTTON(MyBase, Value='button.bmp',/bitmap,event_pro='STA',xsize=300,ysize=150,xoffset=100,yoffset=400)
	Mybutton = WIDGET_BUTTON(MyBase, Value ='Exit',Event_pro='exitprocedure',xsize=100,ysize=30,xoffset=200,yoffset=540)
	WIDGET_CONTROL,MyBase,/Realize
	Xmanager,'example08bmp_button',MyBase
end