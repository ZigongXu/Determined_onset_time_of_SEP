
function Energy,E
  return,E^(-2.0)*E
end
function Energy2,E
  return,E^(-2.0)
end

pro  constant_define
;

;---------energy_define
E_het_up=[15.1,17.1,19.3,23.8,26.4,29.7,33.4,35.8,40.5,60.0,100.0]
E_het_low=[13.6,14.9,17.0,20.8,23.8,26.3,29.5,33.4,35.5,40.0,60.0] ;in unit MeV
;for LET
E_let_up=[3.6,6.0,10.0,15.0]
E_let_low=[1.8,4.0,6.0,10.0]; in unit MeV
;SEPT
E_SEPT_UP=[55.0,65.0,75.0,85.0,105.0,125.0,145.0,165.0,195.0,225.0,255.0,295.0,335.0,375.0,425.0]
E_SEPT_low=[45.0,55.0,65.0,75.0,85.0,105.0,125.0,145.0,165.0,195.0,225.0,255.0,295.0,335.0,375.0] ;in unit KeV

;---- calcuated in index 2
E_sept=QSIMP('Energy',E_Sept_low,E_sept_up)/QSIMP('Energy2',E_sept_low,E_sept_up)
E_let=QSIMP('Energy',E_let_low,E_let_up)/QSIMP('Energy2',E_let_low,E_let_up)
E_het=QSIMP('Energy',E_het_low,E_het_up)/QSIMP('Energy2',E_het_low,E_het_up)
STEREO_proton=[E_let,E_het]
STEREO_electron= E_sept
P_SOHO_Low= [1.7,2.0,2.4,3.0,3.7,4.7,5.7,7.2,9.1,11]; in unit MeV
P_SOHO_High=[15.4,18.9,23.3,29.1,36.4,45.6,57.4,72.0,90.5,108.0]; in unit Mev

wind_energy=['27.0KeV','40.1KeV','66.2KeV','108.4KeV','181.8KeV','309.5KeV','516.8KeV']

;----------------parameter_define

AU=1.49597871D11 ;unit m
light_speed=2.99792458D8 ;unit m
rad2deg=180/!pi
R_sun=6.955D8 ;unit m
;---------------
;--------color_define
mycolor1=['black', 'magenta', 'green', 'cyan', 'blue', $
  'red', 'yellow', 'orange', 'olive', 'purple','Maroon','Brown','Red', 'Orange','tan','Gold',$
  'olive','yellow','green yellow','lawn Green','forest green','dark green',$
  'aquamarine','cyan','sky blue','navy','Powder Blue','violet',$
  'violet red','blue violet','pink']
myColor2=['Maroon','Brown','Red', 'Orange','tan','Gold',$
  'olive','yellow','green yellow','lawn Green','forest green','dark green',$
  'aquamarine','cyan','sky blue','navy','Powder Blue','violet',$
  'violet red','blue violet','pink']
;--------color_define

;--STEREO high proton name
STAB_proton_name=['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec']
;-----------------------
event_list=['20100814','20110308','20110321','20110607','20110804','20110923','20111126','20120123','20120127','20120307','20120313',$
  '20120517','20120527','20120616','20120712','20120717','20120723','20120901','20120928']
solar_wind_velocity=[434.13,389.7,352.17,398.88,344.03,406.45,408.40,446.99,522.56,382.52,558.36,365.06,364.93,371.51,413.53,498.06,443.22,$
    309.98,411.21]*1e3
temp={str1,event_num:'',velocity:0D,IMF_length:0D}
solar_wind=replicate(temp,19)
for i =0,N_elements(event_list)-1 do begin
  solar_wind[i].event_num=event_list[i]
  solar_wind[i].velocity=solar_wind_velocity[i]
  solar_wind[i].IMF_length=length_of_imf(solar_wind_velocity[i],latitude=0)
endfor
;---------------------
delvar,event_list
delvar,solar_wind_velocity
;
GOES_energy=['2.5','6.5','11.6','30.6','63.1','165','433'];MeV
save,filename='/Users/zigongxu/Documents/work/myWork2_GCS_releasetime/code/common/constant_define.sav',/VARIABLES,DESCRIPTION='parameter,energy,color define'

end

