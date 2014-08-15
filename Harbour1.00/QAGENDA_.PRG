
#include "inkey.ch"

function qagenda
   local sBLOC := qsbloc(00,00,18,28)
   local nCURSOR := setcursor(0)
   qlbloc(00,00,"CALEND",XDRV_SH+"QSBLOC.GLO")
   i_calend()
   qrbloc(00,00,sBLOC)
   setcursor(nCURSOR)
return

static function i_calend
   local nTECLA, cTECLA
   private dFOCO := date()

   set color to GR/B
   COR := "W/G"
   dFOCO := date()
   qsay(17,08,date())

   do while .T.
      monta_c()
      nTECLA := inkey(0)
      cTECLA := upper(chr(nTECLA))
      do case
         case nTECLA == K_ESC       ; exit
         case nTECLA == K_ENTER     ; edit_agenda()
         case nTECLA == K_RIGHT     ; dFOCO := dFOCO + 1
         case nTECLA == K_LEFT      ; dFOCO := dFOCO - 1
         case nTECLA == K_DOWN      ; dFOCO := dFOCO + 7
         case nTECLA == K_UP        ; dFOCO := dFOCO - 7
         case nTECLA == K_PGDN      ; dFOCO := dFOCO + 30
         case nTECLA == K_PGUP      ; dFOCO := dFOCO - 30
         case nTECLA == K_CTRL_PGDN ; dFOCO := dFOCO + 365
         case nTECLA == K_CTRL_PGUP ; dFOCO := dFOCO - 365
         case cTECLA == "H"         ; dFOCO := date()
         case cTECLA == "D"         ; dFOCO := i_pega_data(dFOCO)
         case cTECLA $ "+-"
              qsay(17,21,iif(cTECLA=="+","+     ","-     "))
              nDIAS := 0
              @ 17,23 get nDIAS picture "9999"
              read
              iif(cTECLA=="-",nDIAS*=-1,NIL)
              dFOCO := date() + nDIAS
      endcase
   enddo
return

static function i_pega_data ( dDATA )
   qgetx(17,20,@dDATA)
return dDATA

static function edit_agenda

/*
     save screen to TELA_AGEN
     store COR to CORAGEN
     store "B/GR" to COR
     set color to &COR
//     @ 01,29 say CENTRA(51,"Anota‡”es em "+CENTRO_C(0,DIA_C))
     use AGENDA index AGENDA
     seek dtos(DIA_C)
     if found()
        store AGENDA to TEXTO_AGE
     else
        store " " to TEXTO_AGE
     endif
     TEXTO_AGE = memoedit(TEXTO_AGE,02,29,22,79)
     store CORAGEN to COR
     set COLO to &COR
     if lastkey() <> 27
        if eof()
           append blank
           replace DATA with dtos(DIA_C),AGENDA with TEXTO_AGE
        else
           replace AGENDA with TEXTO_AGE
        endif
     endif
     restore screen from TELA_AGEN
     */

return

static function monta_c

   private nLIN, nCOL

   DIAM = dFOCO - day(dFOCO) - DOW(dFOCO-day(dFOCO)) + 1
   store 1 to DIATAB,nCOL
   store 5 to nLIN
   @ 1,1 say CENTRO_C(27,dFOCO)
   do while DIATAB < 43
      do case
         case month(DIAM)<>month(dFOCO)
              diad()
         case month(DIAM) = month(dFOCO)
              set COLO to B/GR
              do while month(DIAM) = month(dFOCO)
                 diad()
              enddo
              set COLO to GR/B
      endcase
   enddo

   qsay(17,02,dFOCO-ctod("01/01/"+substr(dtos(dFOCO),1,4))+1,"999")
   qsay(17,21,(date()-dFOCO),"999999")
return

static function diad
     @ nLIN,nCOL say day(DIAM)
     DIATAB := DIATAB + 1
     DIAM := DIAM + 1
     nCOL += 4
     if nCOL > 26
        nCOL := 1
        nLIN += 2
     endif
return

static function centro_c ( CAMP , DATA_C )
   local C1, C2, MESCOR, TEXTO

   MESCOR := "Janeiro  FevereiroMar‡o    Abril    Maio     Junho    Julho    Agosto   Setembro Outubro  Novembro Dezembro "
   TEXTO  := substr(dtos(DATA_C),7,2) + " de " + trim(substr(MESCOR,(month(DATA_C)-1)*9+1,9)) + " de " + substr(dtos(DATA_C),1,4)

   if len(TEXTO) < CAMP
      C1 = int ((CAMP-len(TEXTO))/2)
      C2 = CAMP - len(TEXTO) - C1
      TEXTO := replicate(" ",C1) + TEXTO + replicate(" ",C2)
   endif

return TEXTO

static func stuff
para cl_string, cl_start, cl_len, cl_replace
return substr(cl_string,1,cl_start-1) + cl_replace +;
       substr(cl_string,cl_start+cl_len)

