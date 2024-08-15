Pro L1,event
	Result=Dialog_message('This is L1',/information)
end

pro STA,event
	Result= DIalog_message('This is STEREO A',/information)
end

pro STB,event
	result=Dialog_message('This is STEREO B',/information)
end

pro ExitProcedure, event
	WIDGET_control,event.top,/destroy
end

pro chapter07PushButtonWidget
	myBase = widget_base(xsize=500,ysize=400,title='Mybase')
	Mybutton = Widget_button(mybase,Value='L1',Event_pro='L1',xsize=100,ysize=30,xoffset=200,yoffset=50)
	mybutton = Widget_button(mybase,Value='STA',Event_pro='STA',xsize=100,ysize=30,xoffset=200,yoffset=100)
	mybutton = Widget_button(Mybase,Value='STB',Event_pro='STB',xsize=100,ysize=30,xoffset=200,yoffset=150)
	Mybutton = Widget_button(MYbase,Value='Exit',Event_pro='ExitProcedure',xsize=100,ysize=30,xoffset=200,Yoffset=200)
	Widget_control, Mybase,/realize
	Xmanager,'Chapter07PushButtonWidget',MyBase
end