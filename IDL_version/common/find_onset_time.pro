function find_onset_time,jul,flux,background=background,position=pos,time=time,color=color,pline=pline
; Name: find_onset_time
; Purpose: find the onset time based on the background user supplied
; Modification history
; 2017.6.21 21:00
; Parameter define: background=[a,b];
; pos is the position of onset time
; 2017.7.20 add keyword pline 
; 2017.10.27 add a method for poor quality data
area=where( jul gt background[0] and jul lt background[1])
;print,where(finite(flux[area])eq 1)
;print,n_elements(where(finite(flux[area])eq 1))

flux[where(flux lt 1e-12)]=!values.f_nan
;-----------------
condition=where(finite(flux[area])eq 1)
if condition[0] eq -1 then begin
	print,'I(I am a function) will find the backgroud from data more earlier, you can neglect this channel if you dont like it'
	pos=where(finite(flux) and jul lt background[0])
	ave=flux[pos[-1]]
	sigma=ave/100D
endif

if n_elements(condition) eq 1 and condition[0] ne -1 then begin
	print,'you should expand the backgroud time or confirm use only one data as background'
	temp=flux[area]
	ave=temp[where(finite(temp)eq 1)]
	ave =ave[0]
	sigma= ave/100D
endif 
if n_elements(condition) gt 1 then begin
	sigma=stddev(flux[area],/nan)
	ave=mean(flux[area],/nan)
	if (sigma lt ave/100D) then sigma = ave/100D
endif
;----------------
print,'sigma   ',sigma,'ave  ',ave
if ~keyword_set(time) then time=10 
num_sigma=2D
if keyword_set(pline) then pline,ave+num_sigma*sigma,linestyle=2,color=color
potential_result=where(flux ge ave+num_sigma*sigma and jul gt background[1])
;print,max(flux,/nan)
;help,ave,sigma 
;print,n_elements(where(flux ge ave+num_sigma*sigma))
;print,potential_result
foreach pos,potential_result do begin
  if ((pos+time) ge n_elements(flux)) or (pos eq -1)  then return,-1 
  if (mean(flux[pos:pos+time],/nan) gt ave+num_sigma*sigma) and(max_except(flux[pos:pos+time],/min,except_range_small=1e-10,/nan) ge (ave+(num_sigma-1)*sigma)) then return,jul[pos]
endforeach
return,-1
end