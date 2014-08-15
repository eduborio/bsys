
// INCLUIR AQUI AS VARIAVEIS DE AMBIENTE DO INICIO DO PROGRAMA USIMIX.PRG

set inte on
set confirm on
set delete on
set bell off
set date brit
set scor off
set key 10 to q_back_field

// DEFINE VARIAVEIS PUBLICAS DO SISTEMA _____________________________________

private XVIEWCOLOR := "N/GR"
private XCOR_MENSA := 15
private XREFRESH   := 1000
private XMOUSEOK   := .F.
private XTIMEA     := XTIMER := XTIMEF := XTIMEU := 1


private cEMP := space(3)
private cPATH
private cMAT := 0

clear

@ 12,10 say "Matricula:"
qgetx(12,25,@cMAT,"9999")

@ 15,10 say "Empresa:"
qgetx(15,25,@cEMP,"999")


if ! qconf()
   return
endif


cPATH := "\QSYS_G\QRH\E" + cEMP + "\"

quse(cPATH,"PROV",{"PROV"},"E")

PROV->(dbgotop())
do while !PROV->(eof())
   replace PROV->Nova with strzero(cMAT,6)
   cMAT++
   PROV->(dbskip())
enddo

quse(cPATH,"SITUA",NIL,"E")
quse(cPATH,"DEPE",NIL,"E")
quse(cPATH,"BASE",NIL,"E")
quse(cPATH,"BENEF",NIL,"E")
quse(cPATH,"LANC",NIL,"E")

SITUA->(dbgotop())

do while ! SITUA->(eof())
   if PROV->(dbseek(SITUA->Matricula))
      replace SITUA->Matricula with PROV->Nova
   endif

   SITUA->(dbskip())
enddo

DEPE->(dbgotop())

do while ! DEPE->(eof())
   if PROV->(dbseek(DEPE->Matricula))
      replace DEPE->Matricula with PROV->Nova
   endif

   DEPE->(dbskip())
enddo

BASE->(dbgotop())

do while ! BASE->(eof())
   if PROV->(dbseek(BASE->Matricula))
      replace BASE->Matricula with PROV->Nova
   endif

   BASE->(dbskip())
enddo

BENEF->(dbgotop())

do while ! BENEF->(eof())
   if PROV->(dbseek(BENEF->Matricula))
      replace BENEF->Matricula with PROV->Nova
   endif

   BENEF->(dbskip())
enddo

LANC->(dbgotop())

do while ! LANC->(eof())
   if PROV->(dbseek(LANC->Matricula))
      replace LANC->Matricula with PROV->Nova
   endif

   LANC->(dbskip())
enddo

return
