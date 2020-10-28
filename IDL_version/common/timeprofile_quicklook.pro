
;Name: timeprofile_quicklook
;Purpose : an quicklook procedure to have an glance on the particle temporary intensities including e and P in STA,STB,L1
;
;Parameter explanination and syntax
;           event_num
;
;Modification history
;2017.6.20  start editing by xuzigong 
;2017.6.****; replace by another version at 20110308 using two days' data
;2017.6.29  add the 'event_num' parameter for the user using it outside???not completed
;
;;----
pro timeprofile_quicklook
  ;-----
  
  ;---
  ;L1,electron ,wind
  ;
  energy_define
  color_define
  common energy_block
  common color_block
  dummy=label_date(date_format='%H:%I')
  cgdisplay,1200,800
  set_plot,'ps'
  device,filename='/Users/zigongxu/Documents/work/myWork2_GCS_releasetime/image/20110308/20110307_08.eps',/portrait,yoffset=1,/inch,xsize=7,ysize=8
  !p.multi=[6,2,3]
;  ;--------
;  electron_L1_name=dialog_pickfile(title='electron_wind',filter='*.cdf',path='/Users/zigongxu/Documents/work/myWork2_GCS_releasetime/data')
;  proton_l1_name=dialog_pickfile(title='proton_SOHO_high',filter='*.SL2',path='/Users/zigongxu/Documents/work/myWork2_GCS_releasetime/data')
;  ;proton_l1_low_name=dialog_pickfile(title='proton_SOHO_low',path='/Users/zigongxu/Documents/work/myWork2_GCS_releasetime/data')
;  electron_STA_name=dialog_pickfile(title='electron_STA',filter='*.dat',path='/Users/zigongxu/Documents/work/myWork2_GCS_releasetime/data')
;  electron_STB_name=dialog_pickfile(title='electron_STB',filter='*.dat',path='/Users/zigongxu/Documents/work/myWork2_GCS_releasetime/data')
;  proton_STA_name_low=dialog_pickfile(title='proton_STA_low',filter='*.txt',path='/Users/zigongxu/Documents/work/myWork2_GCS_releasetime/data')
; ; proton_STA_name_high=dialog_pickfile(title='proton_STA_high',filter='*.1m',path='/Users/zigongxu/Documents/work/myWork2_GCS_releasetime/data')
;  proton_STB_name_low=dialog_pickfile(title='proton_STB_low',filter='*.txt',path='/Users/zigongxu/Documents/work/myWork2_GCS_releasetime/data')
;;  proton_STB_name_high=dialog_pickfile(title='proton_STB_high',filter='*.1m',path='/Users/zigongxu/Documents/work/myWork2_GCS_releasetime/data')
;----------------------
;
electron_L1_name='/Users/zigongxu/Documents/work/myWork2_GCS_releasetime/data/20110308/particle/wi_sfsp_3dp_20110307_v01.cdf'
proton_l1_name='/Users/zigongxu/Documents/work/myWork2_GCS_releasetime/data/20110308/particle/LED11066.SL2'
electron_STA_name='/Users/zigongxu/Documents/work/myWork2_GCS_releasetime/data/20110308/particle/sept_ahead_ele_asun_2011_066_1min_l2_v03.dat'
electron_STB_name='/Users/zigongxu/Documents/work/myWork2_GCS_releasetime/data/20110308/particle/sept_behind_ele_asun_2011_066_1min_l2_v03.dat'
proton_STA_name_low='/Users/zigongxu/Documents/work/myWork2_GCS_releasetime/data/20110308/particle/H_summed_ahead_2011_066_level1_11.txt'
; proton_STA_name_high=dialog_pickfile(title='proton_STA_high',filter='*.1m',path='/Users/zigongxu/Documents/work/myWork2_GCS_releasetime/data')
proton_STB_name_low='/Users/zigongxu/Documents/work/myWork2_GCS_releasetime/data/20110308/particle/H_summed_behind_2011_066_level1_11.txt'

;- wind e
id = CDF_OPEN(electron_l1_name)
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
cgplot,Epoch_jul,smooth(reform(flux[0,*]),5,/nan),xstyle=1,xtickformat='label_date',/ylog,ystyle=1,yrange=[1e-7,1e-1],$
  title='wind electron',xrange=[julday(3,7,2011,18,0,0),julday(3,8,2011,9,0,0)]
for i=1,6 do begin
  cgplot,Epoch_jul,smooth(flux[i,*],10,/nan,/edge_truncate),/over,color=mycolor[i],psym=1,symsize=0.1
  ;cgtext,0.2,0.2+i*0.05,strcompress(string(energy_wind_e[i])),/normal,color=mycolor[i]
endfor
electron_L1_name='/Users/zigongxu/Documents/work/myWork2_GCS_releasetime/data/20110308/particle/wi_sfsp_3dp_20110308_v01.cdf'
id = CDF_OPEN(electron_l1_name)
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
for i=0,6 do begin
  cgplot,Epoch_jul,smooth(flux[i,*],10,/nan,/edge_truncate),/over,color=mycolor[i],psym=1,symsize=0.1,/noerase
  ;cgtext,0.2,0.2+i*0.05,strcompress(string(energy_wind_e[i])),/normal,color=mycolor[i]
endfor
vline,julday(3,7,2011,20,0,0),linestyle=2
; 
; 
; 
;soho P   
fmt='f,f,f,x,f,f,f,f,f,f,f,f,f,f'
readcol,proton_L1_name,format=fmt,year,day,Htime,PH1,PH2,Ph3,PH4,PH5,PH6,PH7,PH8,PH9,PH10
;readcol,LED_name,format=fmt,Ltime,PL1,PL2,PL3,PL4,PL5,PL6,PL7,PL8,PL9,PL10
P_soho=[transpose(PH1),transpose(PH2),transpose(PH3),transpose(PH4),transpose(PH5),transpose(PH6),transpose(PH7),transpose(PH8),transpose(PH9),transpose(PH10)]
;PL=[transpose(PL1),transpose(PL2),transpose(PL3),transpose(PL4),transpose(PL5),transpose(PL6),transpose(PL7),transpose(PL8),transpose(PL9),transpose(PL10)]
SOHO_Htime_jul=doy2jul(year,day+htime/86400000D)
cgplot,soho_Htime_jul,p_soho[i,*],/nodata,xstyle=1,ystyle=1,yrange=[1e-5,1e3],/ylog,xtickformat='label_date',title='SOHO_proton',xrange=[julday(3,7,2011,18,0,0),julday(3,8,2011,9,0,0)]
for i =0,9 do begin
 cgplot,SOHO_Htime_jul,smooth(P_soho[i,*],10,/nan,/edge_truncate),/over,color=mycolor[i],symsize=0.1,psym=1
; cgtext,0.2,0.2+i*0.05,strcompress(string( P_SOHO_Low[i])),/normal,color=mycolor[i]
endfor
proton_l1_name='/Users/zigongxu/Documents/work/myWork2_GCS_releasetime/data/20110308/particle/LED11067.SL2'
fmt='f,f,f,x,f,f,f,f,f,f,f,f,f,f'
readcol,proton_L1_name,format=fmt,year,day,Htime,PH1,PH2,Ph3,PH4,PH5,PH6,PH7,PH8,PH9,PH10
;readcol,LED_name,format=fmt,Ltime,PL1,PL2,PL3,PL4,PL5,PL6,PL7,PL8,PL9,PL10
P_soho=[transpose(PH1),transpose(PH2),transpose(PH3),transpose(PH4),transpose(PH5),transpose(PH6),transpose(PH7),transpose(PH8),transpose(PH9),transpose(PH10)]
;PL=[transpose(PL1),transpose(PL2),transpose(PL3),transpose(PL4),transpose(PL5),transpose(PL6),transpose(PL7),transpose(PL8),transpose(PL9),transpose(PL10)]
SOHO_Htime_jul=doy2jul(year,day+htime/86400000D)
;cgplot,soho_Htime_jul,p_soho[i,*],/nodata,xstyle=1,ystyle=1,yrange=[1e-5,1e3],/ylog,xtickformat='label_date',title='SOHO_proton'
for i =0,9 do begin
  cgplot,SOHO_Htime_jul,smooth(P_soho[i,*],10,/nan,/edge_truncate),/over,color=mycolor[i],symsize=0.1,psym=1,/noerase
  ; cgtext,0.2,0.2+i*0.05,strcompress(string( P_SOHO_Low[i])),/normal,color=mycolor[i]
endfor
;vline,julday(3,7,2011,20,0,0),linestyle=2

proton_l1_name='/Users/zigongxu/Documents/work/myWork2_GCS_releasetime/data/20110308/particle/HED11066.SL2'
fmt='f,f,f,x,f,f,f,f,f,f,f,f,f,f'
readcol,proton_L1_name,format=fmt,year,day,Htime,PH1,PH2,Ph3,PH4,PH5,PH6,PH7,PH8,PH9,PH10
;readcol,LED_name,format=fmt,Ltime,PL1,PL2,PL3,PL4,PL5,PL6,PL7,PL8,PL9,PL10
P_soho=[transpose(PH1),transpose(PH2),transpose(PH3),transpose(PH4),transpose(PH5),transpose(PH6),transpose(PH7),transpose(PH8),transpose(PH9),transpose(PH10)]
;PL=[transpose(PL1),transpose(PL2),transpose(PL3),transpose(PL4),transpose(PL5),transpose(PL6),transpose(PL7),transpose(PL8),transpose(PL9),transpose(PL10)]
SOHO_Htime_jul=doy2jul(year,day+htime/86400000D)
;cgplot,soho_Htime_jul,p_soho[i,*],/nodata,xstyle=1,ystyle=1,yrange=[1e-5,1e3],/ylog,xtickformat='label_date',title='SOHO_proton'
for i =0,9 do begin
  cgplot,SOHO_Htime_jul,smooth(P_soho[i,*],10,/nan,/edge_truncate),/over,color=mycolor[i+9],symsize=0.1,psym=1,/noerase
  ; cgtext,0.2,0.2+i*0.05,strcompress(string( P_SOHO_Low[i])),/normal,color=mycolor[i]
endfor
proton_l1_name='/Users/zigongxu/Documents/work/myWork2_GCS_releasetime/data/20110308/particle/HED11067.SL2'
fmt='f,f,f,x,f,f,f,f,f,f,f,f,f,f'
readcol,proton_L1_name,format=fmt,year,day,Htime,PH1,PH2,Ph3,PH4,PH5,PH6,PH7,PH8,PH9,PH10
;readcol,LED_name,format=fmt,Ltime,PL1,PL2,PL3,PL4,PL5,PL6,PL7,PL8,PL9,PL10
P_soho=[transpose(PH1),transpose(PH2),transpose(PH3),transpose(PH4),transpose(PH5),transpose(PH6),transpose(PH7),transpose(PH8),transpose(PH9),transpose(PH10)]
;PL=[transpose(PL1),transpose(PL2),transpose(PL3),transpose(PL4),transpose(PL5),transpose(PL6),transpose(PL7),transpose(PL8),transpose(PL9),transpose(PL10)]
SOHO_Htime_jul=doy2jul(year,day+htime/86400000D)
;cgplot,soho_Htime_jul,p_soho[i,*],/nodata,xstyle=1,ystyle=1,yrange=[1e-5,1e3],/ylog,xtickformat='label_date',title='SOHO_proton'
for i =0,9 do begin
  cgplot,SOHO_Htime_jul,smooth(P_soho[i,*],10,/nan,/edge_truncate),/over,color=mycolor[i+9],symsize=0.1,psym=1,/noerase
  ; cgtext,0.2,0.2+i*0.05,strcompress(string( P_SOHO_Low[i])),/normal,color=mycolor[i]
endfor
vline,julday(3,7,2011,20,0,0),linestyle=2
;
;STA e
fmt_sept='D,x,x,x,x,x,f,f,f,f,f,f,f,f,f,f,f,f,f,f'
readcol,electron_STA_name,format=fmt_sept,eleA_jul,STAE1,STAE2,STAE3,STAE4,STAE5,STAE6,STAE7,STAE8,STAE9,STAE10,STAE11,STAE12,STAE13,STAE14
STA_E=[transpose(temporary(STAE1)),transpose(temporary(STAE2)),transpose(temporary(STAE3)),transpose(temporary(STAE4)),transpose(temporary(STAE5)),transpose(temporary(STAE6)),transpose(temporary(STAE7)),transpose(temporary(STAE8)),transpose(temporary(STAE9)),$
  transpose(temporary(STAE10)),transpose(temporary(STAE11)),transpose(temporary(STAE12)),transpose(temporary(STAE13)),transpose(temporary(STAE14))]
  
cgplot,eleA_jul,sta_e[1,*],/nodata,/ylog,xtickformat='label_date',xstyle=1,ystyle=1,yrange=[5e-2,5e4],title='STA electron',xrange=[julday(3,7,2011,18,0,0),julday(3,8,2011,9,0,0)]
for i=0,13 do begin
  cgplot,eleA_jul,smooth(sta_e[i,*],15,/nan,/edge_truncate),/over,color=mycolor[i],psym=1,symsize=0.1
 ; cgtext,0.2,0.2+0.05*i,strcompress(string(E_sept[i])),color=mycolor[i],/normal
endfor
electron_STA_name='/Users/zigongxu/Documents/work/myWork2_GCS_releasetime/data/20110308/particle/sept_ahead_ele_asun_2011_067_1min_l2_v03.dat'
readcol,electron_STA_name,format=fmt_sept,eleA_jul,STAE1,STAE2,STAE3,STAE4,STAE5,STAE6,STAE7,STAE8,STAE9,STAE10,STAE11,STAE12,STAE13,STAE14
STA_E=[transpose(temporary(STAE1)),transpose(temporary(STAE2)),transpose(temporary(STAE3)),transpose(temporary(STAE4)),transpose(temporary(STAE5)),transpose(temporary(STAE6)),transpose(temporary(STAE7)),transpose(temporary(STAE8)),transpose(temporary(STAE9)),$
  transpose(temporary(STAE10)),transpose(temporary(STAE11)),transpose(temporary(STAE12)),transpose(temporary(STAE13)),transpose(temporary(STAE14))]
  
;cgplot,eleA_jul,sta_e[1,*],/nodata,/ylog,xtickformat='label_date',xstyle=1,ystyle=1,yrange=[5e-2,5e4],title='STA electron',xrange=[julday(3,7,2011,19,0,0),julday(3,8,2011,9,0,0)]
for i=0,13 do begin
  cgplot,eleA_jul,smooth(sta_e[i,*],15,/nan),/over,color=mycolor[i],psym=1,symsize=0.1
  ; cgtext,0.2,0.2+0.05*i,strcompress(string(E_sept[i])),color=mycolor[i],/normal
endfor
vline,julday(3,7,2011,20,0,0),linestyle=2

;STB e
readcol,electron_STB_name,format=fmt_sept,eleB_jul,STBE1,STBE2,STBE3,STBE4,STBE5,STBE6,STBE7,STBE8,STBE9,STBE10,STBE11,STBE12,STBE13,STBE14
STB_E=[transpose(temporary(STBE1)),transpose(temporary(STBE2)),transpose(temporary(STBE3)),transpose(temporary(STBE4)),transpose(temporary(STBE5)),transpose(temporary(STBE6)),transpose(temporary(STBE7)),transpose(temporary(STBE8)),transpose(temporary(STBE9)),$
    transpose(temporary(STBE10)),transpose(temporary(STBE11)),transpose(temporary(STBE12)),transpose(temporary(STBE13)),transpose(temporary(STBE14))]
cgplot,eleB_jul,stb_e[1,*],/nodata,/ylog,xtickformat='label_date',xstyle=1,ystyle=1,yrange=[5e-2,5e4],title='STB electron',xrange=[julday(3,7,2011,18,0,0),julday(3,8,2011,9,0,0)]
for i=0,13 do begin
  cgplot,eleB_jul,smooth(stb_e[i,*],15,/nan,/edge_truncate),/over,color=mycolor[i],psym=1,symsize=0.1
 ; cgtext,0.2,0.2+0.05*i,strcompress(string(E_sept[i])),color=mycolor[i],/normal
endfor
electron_STB_name='/Users/zigongxu/Documents/work/myWork2_GCS_releasetime/data/20110308/particle/sept_behind_ele_asun_2011_067_1min_l2_v03.dat'
readcol,electron_STB_name,format=fmt_sept,eleB_jul,STBE1,STBE2,STBE3,STBE4,STBE5,STBE6,STBE7,STBE8,STBE9,STBE10,STBE11,STBE12,STBE13,STBE14
STB_E=[transpose(temporary(STBE1)),transpose(temporary(STBE2)),transpose(temporary(STBE3)),transpose(temporary(STBE4)),transpose(temporary(STBE5)),transpose(temporary(STBE6)),transpose(temporary(STBE7)),transpose(temporary(STBE8)),transpose(temporary(STBE9)),$
  transpose(temporary(STBE10)),transpose(temporary(STBE11)),transpose(temporary(STBE12)),transpose(temporary(STBE13)),transpose(temporary(STBE14))]
;cgplot,eleB_jul,stb_e[1,*],/nodata,/ylog,xtickformat='label_date',xstyle=1,ystyle=1,yrange=[5e-2,5e4],title='STB electron',xrange=[julday(3,7,2011,19,0,0),julday(3,8,2011,9,0,0)]
for i=0,13 do begin
  cgplot,eleB_jul,smooth(stb_e[i,*],15,/nan,/edge_truncate),/over,color=mycolor[i],psym=1,symsize=0.1
  ; cgtext,0.2,0.2+0.05*i,strcompress(string(E_sept[i])),color=mycolor[i],/normal
endfor

vline,julday(3,7,2011,20,0,0),linestyle=2
;STA low p
fmt_LET='f,f,x,x,x,x,x,f,f,f,f'
readcol,proton_STA_name_low,format=fmt_let,year,day,PLET1,PLET2,PLET3,PLET4
STA_LET=[transpose(temporary(PLET1)),transpose(temporary(PLET2)),transpose(temporary(PLET3)),transpose(temporary(PLET4))]
STA_let_jul=doy2jul(year,day)
cgplot,sta_let_jul,sta_let[0,*],/nodata,xstyle=1,ystyle=1,xtickformat='label_date',/ylog,yrange=[1e-5,1e3],title='STA energy proton',xrange=[julday(3,7,2011,18,0,0),julday(3,8,2011,9,0,0)]
for i =0,3 do begin
  cgplot,STA_let_jul,smooth(STA_LET[i,*],15,/nan,/edge_truncate),/over,color=mycolor[i],psym=1,symsize=0.1
 ; cgtext,0.2,0.2+0.05*i,strcompress(string(E_let[i])),color=mycolor[i],/normal
endfor
proton_STA_name_low='/Users/zigongxu/Documents/work/myWork2_GCS_releasetime/data/20110308/particle/H_summed_ahead_2011_067_level1_11.txt'
readcol,proton_STA_name_low,format=fmt_let,year,day,PLET1,PLET2,PLET3,PLET4
STA_LET=[transpose(temporary(PLET1)),transpose(temporary(PLET2)),transpose(temporary(PLET3)),transpose(temporary(PLET4))]
STA_let_jul=doy2jul(year,day)
;cgplot,sta_let_jul,sta_let[0,*],/nodata,xstyle=1,ystyle=1,xtickformat='label_date',/ylog,yrange=[1e-5,1e3],title='STA proton',xrange=[julday(3,7,2011,19,0,0),julday(3,8,2011,9,0,0)]
for i =0,3 do begin
  cgplot,STA_let_jul,smooth(STA_LET[i,*],15,/nan,/edge_truncate),/over,color=mycolor[i],psym=1,symsize=0.1,/noerase
  ; cgtext,0.2,0.2+0.05*i,strcompress(string(E_let[i])),color=mycolor[i],/normal
endfor


;STA high P
if not file_test('/Users/zigongxu/Documents/work/myWork2_GCS_releasetime/data/20110308/processed_STA_HET.sav') then begin 
  proton_STA_name_high='/Users/zigongxu/Documents/work/myWork2_GCS_releasetime/data/20110308/particle/AeH11Mar.1m'
  fmt_HET='x,x,x,f,a,x,x,x,x,x,x,d,x,d,x,d,x,d,x,d,x,d,x,d,x,d,x,d,x,d,x,d,x'
  readcol,proton_STA_Hname,format=fmt_HET,day,time,P1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11
  save,filename='/Users/zigongxu/Documents/work/myWork2_GCS_releasetime/data/20110308/processed_STA_HET.sav',day,time,p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11
endif
restore,'/Users/zigongxu/Documents/work/myWork2_GCS_releasetime/data/20110308/processed_STA_HET.sav',/ver
area=where(day ge 7 and day le 8)
STA_HET_jul=julday(3,day[area],2011,strmid(time[area],0,2),strmid(time[area],2,2))
STA_HET=[transpose(temporary(p1[area])),transpose(temporary(p2[area])),transpose(temporary(p3[area])),transpose(temporary(p4[area])),transpose(temporary(p5[area])),transpose(temporary(p6[area])),transpose(temporary(p7[area])),transpose(temporary(p8[area])),transpose(temporary(p9[area])),transpose(temporary(p10[area])),transpose(temporary(p11[area]))]
;cgplot,STA_HET_jul,STA_HET[0,*],xtickformat='label_date',/ylog,xstyle=1,ystyle=1,xrange=[julday(3,7,2011,19,0,0),julday(3,8,2011,9,0,0)],title='STA high energy proton',yrange=[1e-4,1e-1],/nodata
 
for i=0,10 do begin
  cgplot,STA_HET_jul,smooth(STA_HET[i,*],15,/nan,/edge_truncate),color=mycolor[i+4],psym=1,symsize=0.1,/over
endfor
vline,julday(3,7,2011,20,0,0),linestyle=2
;STB Low p
fmt_LET='f,f,x,x,x,x,x,f,f,f,f'
readcol,proton_STB_name_low,format=fmt_let,year,day,PLET1,PLET2,PLET3,PLET4
STB_LET=[transpose(temporary(PLET1)),transpose(temporary(PLET2)),transpose(temporary(PLET3)),transpose(temporary(PLET4))]

STB_let_jul=doy2jul(year,day)
cgplot,stB_let_jul,stB_let[0,*],/nodata,xstyle=1,ystyle=1,xtickformat='label_date',/ylog,yrange=[1e-5,1e3],title='STB energy proton',xrange=[julday(3,7,2011,18,0,0),julday(3,8,2011,9,0,0)]
for i =0,3 do begin
  cgplot,STB_let_jul,smooth(STB_LET[i,*],15,/nan,/edge_truncate),/over,color=mycolor[i],psym=1,symsize=0.1,/noerase
  ; cgtext,0.2,0.2+0.05*i,strcompress(string(E_let[i])),color=mycolor[i],/normal
endfor
proton_STB_name_low='/Users/zigongxu/Documents/work/myWork2_GCS_releasetime/data/20110308/particle/H_summed_behind_2011_067_level1_11.txt'
readcol,proton_STB_name_low,format=fmt_let,year,day,PLET1,PLET2,PLET3,PLET4
STB_LET=[transpose(temporary(PLET1)),transpose(temporary(PLET2)),transpose(temporary(PLET3)),transpose(temporary(PLET4))]

STB_let_jul=doy2jul(year,day)
;cgplot,stB_let_jul,stB_let[0,*],/nodata,xstyle=1,ystyle=1,xtickformat='label_date',/ylog,yrange=[1e-5,1e3],title='STB proton',xrange=[julday(3,7,2011,19,0,0),julday(3,8,2011,9,0,0)]
for i =0,3 do begin
  cgplot,STB_let_jul,smooth(STB_LET[i,*],15,/nan,/edge_truncate),/over,color=mycolor[i],psym=1,symsize=0.1,/noerase
  ; cgtext,0.2,0.2+0.05*i,strcompress(string(E_let[i])),color=mycolor[i],/normal
endfor
;-
;STB high P
if not file_test('/Users/zigongxu/Documents/work/myWork2_GCS_releasetime/data/20110308/processed_STB_HET.sav') then begin 
  proton_STB_name_high='/Users/zigongxu/Documents/work/myWork2_GCS_releasetime/data/20110308/particle/BeH11Mar.1m'
  fmt_HET='x,x,x,f,a,x,x,x,x,x,x,d,x,d,x,d,x,d,x,d,x,d,x,d,x,d,x,d,x,d,x,d,x'
  readcol,proton_STA_Hname,format=fmt_HET,day,time,P1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11
  save,filename='/Users/zigongxu/Documents/work/myWork2_GCS_releasetime/data/20110308/processed_STB_HET.sav',day,time,p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11
endif
restore,'/Users/zigongxu/Documents/work/myWork2_GCS_releasetime/data/20110308/processed_STB_HET.sav',/ver
area=where(day ge 7 and day le 8)
STB_HET_jul=julday(3,day[area],2011,strmid(time[area],0,2),strmid(time[area],2,2))
STB_HET=[transpose(temporary(p1[area])),transpose(temporary(p2[area])),transpose(temporary(p3[area])),transpose(temporary(p4[area])),transpose(temporary(p5[area])),transpose(temporary(p6[area])),transpose(temporary(p7[area])),transpose(temporary(p8[area])),transpose(temporary(p9[area])),transpose(temporary(p10[area])),transpose(temporary(p11[area]))]
;cgplot,STB_HET_jul,STB_HET[0,*],xtickformat='label_date',/ylog,xstyle=1,ystyle=1,xrange=[julday(3,7,2011,19,0,0),julday(3,8,2011,9,0,0)],title='STB high energy proton',/nodata,yrange=[1e-4,1e1]

for i=0,10 do begin
  cgplot,STB_HET_jul,smooth(STB_HET[i,*],15,/nan,/edge_truncate),color=mycolor[i+4],psym=1,symsize=0.1,/over
endfor
vline,julday(3,7,2011,20,0,0),linestyle=2
;---
device,/close_file
end




