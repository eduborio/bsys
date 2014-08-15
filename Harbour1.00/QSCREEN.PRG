
function qsbloc ( nTOP , nLEFT , nBOTTOM , nRIGHT )
   local sRET := ""
   sRET += strzero(nBOTTOM-nTOP,2)
   sRET += strzero(nRIGHT-nLEFT,3)
   sRET += savescreen(nTOP,nLEFT,nBOTTOM,nRIGHT)
return sRET

function qrbloc ( nTOP , nLEFT , sBLOCO , nSHADOW )
   local nLIN1, nLIN2, nCOL1, nCOL2
   local nBOTTOM := nTOP + val(left(sBLOCO,2))
   local nRIGHT  := nLEFT + val(subs(sBLOCO,3,3))

   restscreen(nTOP,nLEFT,nBOTTOM,nRIGHT,subs(sBLOCO,6))

   iif ( nSHADOW == NIL , nSHADOW := 0 , NIL )
   if nSHADOW == 1
      nLIN1 := nTOP + val(left(sBLOCO,2)) + 1
      nCOL1 := nLEFT + 2
      nLIN2 := nLIN1
      nCOL2 := nLEFT + val(subs(sBLOCO,3,3)) + 2
      color_sl(nLIN1,nCOL1,nLIN2,nCOL2,7,"S")
      nLIN1 := ++nTOP
      nCOL1 := nLEFT + val(subs(sBLOCO,3,3)) + 1
      nLIN2 := nTOP + val(left(sBLOCO,2))
      nCOL2 := nCOL1 + 1
      color_sl(nLIN1,nCOL1,nLIN2,nCOL2,7,"S")
   endif
return

function qlbloc ( nTOP , nLEFT , cBLOC , cGLO , nSHADOW )
   local sRET := ""

   seekb_sl("L")
   do case
      case valtype(nTOP) == "N" .and.   empty(cGLO)
           qrbloc(nTOP,nLEFT,memoread(cBLOC),nSHADOW)
      case valtype(nTOP) == "N" .and. ! empty(cGLO)
           qrbloc(nTOP,nLEFT,qreadglo(cBLOC,cGLO),nSHADOW)
      case valtype(nTOP) == "C" .and.   empty(nLEFT)
           sRET := memoread(nTOP)
      case valtype(nTOP) == "C" .and. ! empty(nLEFT)
           sRET := qreadglo(nTOP,nLEFT)
   endcase
return sRET

function qreadglo ( cBLOC , cGLO )
   local cTMP, nHANDLE, cBUFFER, nQUANT, nCONT, nPOINTER := nLENGHT := 0

   // ABRE O ARQUIVO DE BLOCOS ______________________________________________

   if (nHANDLE := fopen(cGLO,0)) < 0  // 0=reading
      return ""
   endif

   // LE A QUANTIDADE DE BLOCOS NO ARQUIVO __________________________________

   cBUFFER := space(3)

   fread(nHANDLE,@cBUFFER,len(cBUFFER))

   // AGORA PROCURA O BLOCO SELECIONADO _____________________________________

   nQUANT := val(cBUFFER)

   for nCONT := 1 to nQUANT
       cBUFFER := space(18)
       fread(nHANDLE,@cBUFFER,len(cBUFFER))
       if left(cBUFFER,8) == pad(cBLOC,8)
          nPOINTER := val(subs(cBUFFER,9,6))
          cBUFFER  := space(val(right(cBUFFER,4)))
          exit
       endif
   next

   // NAO ENCONTROU OU LE O BLOCO ENCONTRADO ________________________________

   if nPOINTER == 0
      cBUFFER := ""
   else
      fseek(nHANDLE,nPOINTER)
      fread(nHANDLE,@cBUFFER,len(cBUFFER))
   endif

   fclose(nHANDLE)

   i_prot_adic()

return cBUFFER

/////////////////////////////////////////////////////////////////////////////
// QINVER COM COORDENADAS ___________________________________________________

function qinverc ( nTOP , nLEFT , nBOTTOM , nRIGHT )
   //local nCONT
   //for nCONT := nTOP to nBOTTOM
   //    qinver(nCONT,nLEFT,nRIGHT-nLEFT+1)
  // next

   InvertWin(nTOP,nLEFT,nBOTTOM,nRIGHT) //,InvertAttr(Screenattr(nLIN,nCOL)))



return

