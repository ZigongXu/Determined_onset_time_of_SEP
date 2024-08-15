pro Subprocedure,event
	result=DIALOG_MESSAGE('HAPPY you!',/information)
end

pro chapter07BaseWidget
	myBase = WIDGET_BASE(Xsize =500, Ysize=400,TITLE='Mybase')
	mybutton= WIDGET_BUTTON(MyBase, Value='Welcome',EVENT_PRO='Subprocedure',xsize=100,ysize=40,Xoffset=200,yoffset=60)
	WIDGET_control,Mybase, /realize
	Xmanager,'Chapter07BaseWidget',Mybase
end