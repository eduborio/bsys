
#include "inkey.ch"

// cTMP = controle

// "I" insere caracter f9
// "P" passa para o proximo campo
// "G" grava tudo e retorna
// "A" abandona edicao

/////////////////////////////////////////////////////////////////////////////
// MANUTENCAO DE MACROS DE TECLADO __________________________________________

function qmacros

   local nCONT, aVET := {}

   qmensa("Tecle <F9> para opera‡”es especiais")

   private cTMP := ""

   if ! quse("","QCONFIG") ; return .F. ; endif

   qlbloc(5,0,"MACRO1",XDRV_SH+"QSBLOC.GLO")

   for nCONT := 1 to 7
       aadd(aVET,alltrim(&("QCONFIG->Macro"+str(nCONT,1))))
   next

   for nCONT := 1 to 7
       qsay(7+(nCONT*2),15,aVET[nCONT])
   next

   for nCONT := 1 to 7
       aVET[nCONT] := i_edita(nCONT,aVET[nCONT])
       if cTMP $ "GA" ; exit ; endif
   next

   if cTMP <> "A" .and. qconf("Confirma grava‡„o das macros ?") .and. QCONFIG->(qrlock())

      for nCONT := 1 to 7

          replace &("QCONFIG->Macro"+str(nCONT,1)) with aVET[nCONT]

      next

      i_aciona_macros()

   endif

   QCONFIG->(dbclosearea())

return

/////////////////////////////////////////////////////////////////////////////
// EDITA MACRO INDIVIDUAL ___________________________________________________

static function i_edita ( nPOS , cMACRO )

   local nCHAR
   local nLIN := 7 + (nPOS*2)
   local nCOL := 15 + len(cMACRO)

   do while .T.

      setpos(nLIN,nCOL)

      nCHAR := qinkey(0)

      do case

         case nCHAR == K_F9

              i_f9()

              do case

                 case cTMP == "I"

                      qsay(nLIN,nCOL,chr(nCHAR))
                      cMACRO += chr(nCHAR)
                      nCOL++

                 case cTMP == "L"

                      qsay(nLIN,nCOL:=15,space(60))
                      cMACRO := ""

                 case cTMP $ "PGA"

                      return cMACRO

              endcase

         otherwise

              if len(cMACRO) < 60

                 qsay(nLIN,nCOL,chr(nCHAR))
                 cMACRO += chr(nCHAR)
                 nCOL++

              endif

      endcase

   enddo

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA CONTROLES ESPECIAIS DE EDICAO ________________________________

static function i_f9

   local sBLOC1 := qsbloc(8,49,14,78)
   local sBLOC2 := qlbloc("MACRO2",XDRV_SH+"QSBLOC.GLO")

   qesco(8,49,@cTMP,sBLOC2,1)

   qrbloc(8,49,sBLOC1)

return

