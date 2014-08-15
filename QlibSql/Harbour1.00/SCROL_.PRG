function scrol_sl(nTOP,nLEFT,nBOT,nRIGHT,nQTD,cSTR)
local sBLOC
  sBLOC := qsbloc(nTOP+nQTD,nLEFT,nBOT,nRIGHT)
  
  setcleara(cSTR)
  clear_sl(07,14,21,65)   // limpa area central


return  qrbloc(nTOP,nLEFT,sBLOC)
