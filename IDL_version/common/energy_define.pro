function Energy,E
  return,E^(-2.0)*E
end
function Energy2,E
  return,E^(-2.0)
end

pro energy_define
  ;just a common block define the energy 
  common energy_block,E_het_up,E_het_low,E_let_up,E_let_low,E_sept_up,E_sept_low,E_sept,E_let,E_het,P_soho_low,P_soho_high
  
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
  
  P_SOHO_Low=[1.7,2.0,2.4,3.0,3.7,4.7,5.7,7.2,9.1,11]; in unit MeV
  P_SOHO_High=[15.4,18.9,23.3,29.1,36.4,45.6,57.4,72.0,90.5,108.0]; in unit Mev
end
