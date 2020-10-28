function calculate_velocity,ey,unit=unit,particle=particle,light_speed=light_speed
;consider the relativity character of electrons
;return M/s
 ;print,n_params()
if N_params() ne 1 then begin
  print,'the function has illegal paramaters'
  return ,0
endif
if not keyword_set(unit) then unit='EV'
if not keyword_set(particle) then particle='electron'
 mass_e=9.10938215D-31;unit  kg  electron
 mass_p=1.672621637D-27;unit kg   proton
 ey_unit=1.60217653D-19; J  ,1 eV
 unit=strupcase(unit)
 particle=strlowcase(particle)
 c=2.99792458D8 ;unit m
 return_ey=ey
 case unit of 
    'KEV': return_ey=ey*1000D*ey_unit
    'MEV': return_ey=ey*1E6*ey_unit
    else : return_ey=ey*ey_unit
 endcase
 ;print,sqrt(2.0*27*ey_unit/mass_e)
;  case particle of 
;    'electron': return,sqrt(ey*2/mass_e)
;    'proton': return,sqrt(ey*2/mass_a)   
;    else:return,0
; endcase
 case particle of 
    'electron': begin 
       gama=return_ey/(mass_e*c^2)+1D
       light_speed=sqrt(1.-(1/gama^2)) ;in unit C(light speed)
       return, sqrt(1.- (1/gama^2))*c  ;unit m/s
       end
    'proton': begin
        gama=return_ey/(mass_p*c^2)+1D
        light_speed=sqrt(1.-(1/gama^2)) ;in unit C (light speed)
        return, sqrt(1.-(1/gama^2))*c  ;unit m/s
        end
    else:return,0
 endcase
end