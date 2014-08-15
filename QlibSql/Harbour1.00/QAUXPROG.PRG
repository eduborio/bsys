
/////////////////////////////////////////////////////////////////////////////
// PERMITE VER VARIAVEIS DO SISTEMA _________________________________________

#include "inkey.ch"

function q_aux_prog
   local cTECLA
   set key K_ALT_V to
   tone(1000,2)
   cTECLA := upper(chr(qinkey(0)))
   do case
      case cTECLA == "V" ; i_ver_var()
      case cTECLA == "X" ; i_ver_255()
      case cTECLA == "P" ; i_ver_pub()
      case cTECLA == "M" ; i_ver_mem()
      case cTECLA == "S" ; i_ver_sit()
   endcase
   set key K_ALT_V to q_aux_prog
return

/////////////////////////////////////////////////////////////////////////////
// MODULO PRINCIPAL PARA VISUALIZACAO DE VARIAVEIS __________________________

static function i_ver_var
   local sBLOC := qsbloc(0,0,4,79)
   local cCOR := setcolor("W+/N")
   private cVAR

   @ 0,0 clear to 4,79

   do while .T.
      cVAR := space(70)
      @ 01,02 get cVAR picture "@!"
      read
      if lastkey() == K_ESC ; exit ; endif
      cVAR := alltrim(cVAR)
      i_calc_var()
   enddo

   setcolor(cCOR)
   qrbloc(0,0,sBLOC)
return

/////////////////////////////////////////////////////////////////////////////
// CALCULA O RESULTADO DA VARIAVEL E MOSTRA NA TELA _________________________

static function i_calc_var
   local lPONTO := .F.
   local cTYPE, zRESULT, cLEN := ""

   if "." == left(cVAR,1)
      lPONTO := .T.
      cVAR   := subs(cVAR,2)
   endif

   cTYPE := type("&cVAR.")

   if "U" $ cTYPE .and. ! lPONTO
      qsay(3,2,"n„o foi possivel inspecionar esta variavel !")
      return
   endif

   zRESULT := &cVAR.

   do case
      case cTYPE == "C" ; cLEN    := alltrim(str(len(zRESULT)))
      case cTYPE == "N" ; zRESULT := str(zRESULT)
      case cTYPE == "D" ; zRESULT := dtoc(zRESULT)
      case cTYPE == "L" ; zRESULT := iif(zRESULT,".T.",".F.")
      case cTYPE == "A" ; zRESULT := "{...}"
   endcase

   @ 3,0 clear to 4,79

   qsay ( 3 , 2 , iif(empty(cLEN),"",cLEN+"/") + cTYPE + " => " + zRESULT , NIL , 112 )

return

/////////////////////////////////////////////////////////////////////////////
// VER OS CARACTERES 255 NA TELA ____________________________________________

static function i_ver_255
   local nLIN, nCOL, sTELA := qsbloc(0,0,24,79), nCONT := 1
   local getlist:= {}
   do while .T.
      //nLIN := seekl_sl(chr(255),1,"S")
      //nCOL := seekc_sl(chr(255),1,"S")
      getlist := seekb_sl(chr(255),1,"S")
      nLIN := getList[1,1]
      nCOL := getList[1,2]
      if nLIN == 99 ; exit ; endif
      qsay(nLIN,nCOL,chr(1))
      qsay(0,0,strzero(nCONT++,2))
   enddo
   qwait()
   qrbloc(0,0,sTELA)
return

/////////////////////////////////////////////////////////////////////////////
// VER VARIAVEIS PUBLICAS ___________________________________________________

static function i_ver_pub
return

/////////////////////////////////////////////////////////////////////////////
// VER MEMORIA DISPONIVEL ___________________________________________________

static function i_ver_mem
return

/////////////////////////////////////////////////////////////////////////////
// VER SITUACAO DOS OUTROS SISTEMAS _________________________________________

static function i_ver_sit
return

