

pro analysis_goes,event_num,xrange=xrange,$
  background_xrange=background_xrange,eruption_time=eruption_time,IMF_length=IMF_length,$
  goes_yrange=goes_yrange,Point_num_onset=Point_num_onset,fitting_range=fitting_range,$
  smooth_num=smooth_num,$
  fit_plot_yrange=fit_plot_yrange,fit_plot_xrange=fit_plot_xrange,$
  result_dir=result_dir,data_dir=data_dir,is_SOHO_low_energy_need=is_soho_low_energy_need,multi_day=multi_day
; name: supplement_goes
;Purpose :goes proton data as a supplement of SOHo
;prupose
;Modification history:
; 2017.7.25 start edit
restore,'/Users/zigongxu/Documents/work/myWork2_GCS_releasetime/code/common/constant_define.sav'
dummy=label_date(date_format='%H:%I')


goes_name_1m='/Users/zigongxu/Documents/work/myWork2_GCS_releasetime/data/20110308/particle/g15_epead_p17ew_1m_20110301_20110331.csv'
goes_name_5m='/Users/zigongxu/Documents/work/myWork2_GCS_releasetime/data/20110308/particle/g15_epead_p17ew_1m_20110301_20110331.csv'

FMT ='A,A,X,X,F,F,X,X,F,F,X,X,F,F,X,X,F,F,X,X,F,F,X,X,F,F,X,X,F,F,X,X,F,F,X,X,F,F,X,X,F,F,X,X,F,F,X,X,F,F,X,X,F,F,X,X,F,F'
FMT_1m ='A,A,X,X,F,X,X,F,X,X,F,X,X,F,X,X,F,X,X,F,X,X,F,X,X,F,X,X,F,X,X,F,X,X,F,X,X,F,X,X,F,X,X,F'

readcol,goes_name_1m, $
  F=FMT_1m,time1,time2,p1B,p1A,p2B,p2A,p3B,p3A,p4b,p4A,p5B,p5A,p6B,$
  p6A,p7B,p7A
; readcol,goes_name_5m, $
;    F=FMT,time1,time2,p1B,p1B_cor,p1A,p1A_cor,p2B,p2B_cor,p2A,p2A_cor,p3B,p3B_cor,p3A,p3A_cor,p4b,p4B_cor,p4A,p4A_cor,p5B,p5B_cor,p5A,p5A_cor,p6B,$
;    p6b_cor,p6A,p6A_cor,p7B,p7B_cor,p7A,p7a_cor
goes_time_utc=str2utc(transpose(strjoin([transpose(time1),transpose(time2)],' ')),/external)
;gloss: 使用 transpose的原因是time是一个一维数组，每个都有时间，改为列向量，再加在转置。否则不对的
temp=julday(goes_time_utc.month,goes_time_utc.day,goes_time_utc.year,goes_time_utc.hour,goes_time_utc.minute,goes_time_utc.second)
area=where(temp gt julday(3,7,2011,0,0,0) and temp lt julday(3,9,2011,0,0,0))
;goes_pB_cor=[transpose(temporary(p1B_cor[area])),transpose(temporary(p2B_cor[area])),transpose(temporary(p3B_cor[area])),transpose(temporary(p4B_cor[area])),transpose(temporary(p5B_cor[area])),transpose(temporary(p6B_cor[area])),transpose(temporary(P7B_cor[area]))]
goes_pB=[transpose(temporary(p1B[area])),transpose(temporary(p2B[area])),transpose(temporary(p3B[area])),transpose(temporary(p4B[area])),transpose(temporary(p5B[area])),transpose(temporary(p6B[area])),transpose(temporary(P7B[area]))]
;goes_pA_cor=[transpose(temporary(p1A_cor[area])),transpose(temporary(p2A_cor[area])),transpose(temporary(p3A_cor[area])),transpose(temporary(p4A_cor[area])),transpose(temporary(p5A_cor[area])),transpose(temporary(p6A_cor[area])),transpose(temporary(P7A_cor[area]))]
goes_pA=[transpose(temporary(p1A[area])),transpose(temporary(p2A[area])),transpose(temporary(p3A[area])),transpose(temporary(p4A[area])),transpose(temporary(p5A[area])),transpose(temporary(p6A[area])),transpose(temporary(P7A[area]))]
goes_time_utc=str2utc(transpose(strjoin([transpose(time1[area]),transpose(time2[area])],' ')),/external)
goes_time_jul=temp[area]
set_plot,'x'
dummy=label_date(date_format='%H:%I')

cgplot,goes_time_jul,smooth(goes_pb[0,*],10,/nan),color=mycolor[0],xtickformat='label_date',yrange=[1e-4,1000],/ylog,xrange=[julday(3,7,2011,19,0,0),julday(3,8,2011,9,0,0)]
for i =0,6 do begin 
 cgplot,goes_time_jul,smooth(goes_pb[i,*],10,/nan),color=mycolor[2*i],xtickformat='label_date',/over
endfor
 ;cgplot,goes_time_jul,goes_pb[2,*],color=mycolor[2],xtickformat='label_date',/over
end