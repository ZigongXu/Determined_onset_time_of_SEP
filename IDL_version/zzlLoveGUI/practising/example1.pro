;PRO example1
	tlb= WIDGET_base(title= '直接图像法')
	wdraw = widget_draw(tlb,xsize=200,ysize=200)
	widget_control, tlb,/realize
	widget_control,wdraw, get_value= ddraw
	help, ddraw
	wset,ddraw
	tvscl,dist(200)
	cgplot,sin(findgen(100)/100*!pi),color='blue'
end              