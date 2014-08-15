
#include "inkey.ch"

function qcalc
   local sBLOC := qsbloc(11,56,24,79)
   local nCURSOR := setcursor(0)
   qlbloc(11,56,"CALCULA",XDRV_SH+"QSBLOC.GLO")
   set decimals to 4
   i_calc()
   set decimals to 2
   qrbloc(11,56,sBLOC)
   setcursor(nCURSOR)
return

static function i_calc
   local cVISOR  := ""
   local cPARCE1 := "0"
   local cPARCE2 := "0"
   local cOPERAC := "+"
   local lPONTO  := .F.
   local cMACRO  := "0+val(cRESULT)"
   local nTECLA, cTECLA, zTMP
   private nFIXDEC := 4
   private nVISDEC := 4

   setpos(13,77)

   do while .T.

      nTECLA := qinkey(0)
      cTECLA := upper(chr(nTECLA))

      if nTECLA == K_ENTER
         cTECLA := "="
      endif

      do case

         // FIXA DECIMAIS ___________________________________________________

         case cTECLA == "D"
              i_fixdec()
              keyboard "C"  // aciona clear quando fixa decimais...

         // CLEAR ___________________________________________________________

         case cTECLA == "C"
              cVISOR  := ""
              cPARCE1 := "0"
              cPARCE2 := "0"
              cOPERAC := "+"
              qsay(13,58," ")
              i_visor(cPARCE1)

         // RETORNA O VISOR PARA O APLICATIVO _______________________________

         case cTECLA == "R"
              if ! cVISOR == "0"
                 keyboard (cVISOR)
              endif
              exit

         // NUMERACAO PADRAO ________________________________________________

         case cTECLA >= "0" .and. cTECLA <= "9"
              if cPARCE1+cOPERAC == "0+"
                 qsay(13,58," ")
              endif
              if cPARCE2 == "0"
                 cPARCE2 := cTECLA
              else
                 cPARCE2 += cTECLA
              endif

              zTMP := len(cPARCE2) - rat(".",cPARCE2)
              if zTMP > nFIXDEC .and. lPONTO
                 nVISDEC := zTMP
              endif

              iif(cPARCE2=="00",cPARCE2:="0",NIL)
              i_visor(cPARCE2)
              cVISOR := cPARCE2

         // PONTO DECIMAL ___________________________________________________

         case cTECLA == "." .and. ! lPONTO
              lPONTO := .T.
              cPARCE2 += "."
              i_visor(cPARCE2)
              cVISOR := cPARCE2

         // OPERADORES ARITMETICOS E IGUALDADE ______________________________

         case cTECLA $ "+-*/^="
              if cPARCE1+cOPERAC == "0+" .and. cTECLA <> "=" .and. cPARCE2 == "0"
                 cPARCE1 := cVISOR
                 cOPERAC := cTECLA
              endif
              if ! cPARCE2 == "0"
                 nVISDEC := nFIXDEC
                 cMACRO  := cPARCE1 + cOPERAC + cPARCE2
                 cVISOR  := cPARCE1 := alltrim(str(&cMACRO))
                 i_visor(cPARCE1)
                 cPARCE2 := "0"
                 lPONTO  := .F.
              endif
              qsay(13,58,cTECLA)
              if cTECLA == "="
                 cPARCE1 := "0"
                 cOPERAC := "+"
              else
                 cOPERAC := cTECLA
              endif

         // BACKSPACE _______________________________________________________

         case nTECLA == K_BS .and. ! cPARCE2 == "0"
              cVISOR := cPARCE2 := left(cPARCE2,len(cPARCE2)-1)
              if empty(cPARCE2)
                 cVISOR := cPARCE2 := "0"
              endif
              zTMP := len(cPARCE2) - rat(".",cPARCE2)
              if nVISDEC > nFIXDEC .and. lPONTO
                 nVISDEC := zTMP
              endif

//              @ 00,00 say cPARCE2
//              @ 01,00 say zTMP
//              @ 02,00 say nVISDEC

              i_visor(cPARCE2)

         // ESC RETORNA PARA O APLICATIVO ___________________________________

         case nTECLA == K_ESC
              exit
      endcase
   enddo
return

static function i_visor ( zVALOR )
   local cMASCARA
   if nVISDEC == 0
      cMASCARA := "999,999,999,999"
   else
      cMASCARA := "999,999,999,999." + replicate("9",nVISDEC)
   endif
   zVALOR := val(zVALOR)
   zVALOR := transform(zVALOR,cMASCARA)
   zVALOR := alltrim(zVALOR)
   qsay(13,60,padl(zVALOR,18))
return

static function i_fixdec
   local getlist := {}
   setcursor(1)
   @ 21,62 get nFIXDEC picture "9" range 0,5
   read
   nVISDEC := nFIXDEC
   set decimals to nFIXDEC
   setcursor(0)
return


