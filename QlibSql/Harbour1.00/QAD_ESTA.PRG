
// CONTROLES DO ADMIN
// CONSULTA ESTATISTICA

function qad_esta
local sBLOC := qsbloc(05,00,23,79)
local dINICIO, dFINAL, cUSRNUM

if ! quse("","QLOGIN",{"QLOGIN1","QLOGIN2","QLOGIN3"}) ; return .F. ; endif

qlbloc(5,0,"CONSTAT",XDRV_SH+"QSBLOC.GLO")

do while .T.
   qmensa("Preencha os dados ou <ESC> para sair...")
   QLOGIN->(dbseek(XEMPRESA))
   dINICIO := QLOGIN->Datalog
   QLOGIN->(qseekn(XEMPRESA))
   QLOGIN->(dbskip(-1))
   dFINAL  := QLOGIN->Datalog
   cUSRNUM := "   "
   qgetx(18,12,@dINICIO)
   if lastkey() == 27 ; exit ; endif
   qgetx(20,12,@dFINAL)
   qgetx(22,12,@cUSRNUM)
   QUSERS->(ordsetfocus(2))
   if QUSERS->(dbseek(cUSRNUM))
      qsay(22,18,substr(qdecri(QUSERS->Identific),11,10))
   endif
   QUSERS->(ordsetfocus(1))
   i_cons_stat ( dINICIO , dFINAL , cUSRNUM )
enddo

QLOGIN->(dbclosearea())
qrbloc(5,0,sBLOC)
return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A PESQUISA ESTATISTICA ______________________________

static function i_cons_stat ( dINICIO , dFINAL , cUSRNUM )
   local aSTAT := array(9)  // vetor com estatistica (tempo)
   local aATIV := array(24) // vetor com atividade de horarios
   local aPROG := {}        // vetor com progs utilizados
   local nQREC := 0         // quantidade de registros executados
   local nQABT := 0         // quantidade de registros abortados
   local nDIAS := 0         // dias efetivamente trabalhados
   local dUDIA := ctod("")  // ultimo dia p/ verificar mudanca de data
   local cSUSR := ""        // codigos dos usuarios
   local nTMP               // variavel temporaria
   local nCONT              // utilizada como contador
   local nTOTS              // total de segundos
   local cMAIOR := "     "  // horario de maior atividade
   local cMENOR := "     "  // horario de menor atividade
   local cMAIS  := "   "    // prog. mais utilizado
   local cMENOS := "   "    // prog. menos utilizado

   afill(aSTAT,0)
   afill(aATIV,0)

   if ! empty(cUSRNUM)
      QLOGIN->(dbsetfilter({||Usrnum==cUSRNUM},"Usrnum==cUSRNUM"))
   endif

   QLOGIN->(dbseek(XEMPRESA+dtos(dINICIO),.T.))

   qmensa("Realizando calculos de atividade...")
   do while ! QLOGIN->(eof()) .and. QLOGIN->Datalog <= dFINAL .and. QLOGIN->Empresa == XEMPRESA

      qgirabarra()

      if ! QLOGIN->Usrnum $ cSUSR
         cSUSR += QLOGIN->Usrnum + "/"
      endif

      nTMP := val(left(QLOGIN->Prog,1))
      if nTMP <> 0 .and. ! empty(QLOGIN->Inicio) .and. ! empty(QLOGIN->Final)
         aSTAT[nTMP] += secs(qdifhora(QLOGIN->Inicio,QLOGIN->Final))
      endif

      if empty(QLOGIN->Final)
         nQABT++
      endif

      i_check_ativ(aATIV)
      i_check_prog(aPROG)

      if QLOGIN->Datalog <> dUDIA
         dUDIA := QLOGIN->Datalog
         nDIAS++
      endif

      nQREC++
      QLOGIN->(dbskip())
   enddo

   // REALIZA CALCULOS COMPLEMENTARES _______________________________________

   cSUSR := strtran(cSUSR,"/","")

   for nCONT := 1 to 24
       aATIV[nCONT] := strzero(aATIV[nCONT],5) + strzero(nCONT,2)
   next
   aATIV := asort(aATIV)
   for nCONT := 1 to 24
       if val(left(aATIV[nCONT],5)) <> 0
          cMENOR := right(aATIV[nCONT],2)
          cMENOR += "~" + strzero(val(cMENOR)+1,2)
          exit
       endif
   next
   cMAIOR := right(aATIV[24],2)
   cMAIOR += "~" + strzero(val(cMAIOR)+1,2)

   if ! empty(aPROG)
      aPROG  := asort(aPROG,,,{|x,y|x[2]<y[2]})
      cMAIS  := aPROG[len(aPROG),1]
      cMENOS := aPROG[1,1]
   endif

   // MOSTRA PARTE ESTATISTICA NO CENTRO DO QUADRO __________________________

   nTOTS := 0
   aeval(aSTAT,{|x|nTOTS+=x})

   for nCONT := 1 to 9
       nTMP := aSTAT[nCONT]/nTOTS*100
       qsay(7+nCONT,23,pad(replicate("þ",nTMP/100*41),41))
       qsay(7+nCONT,67,nTMP,"999")
       qsay(7+nCONT,73,left(tstring(aSTAT[nCONT]),5))
   next

   // MOSTRA DADOS NA PARTE DE BAIXO DO QUADRO ______________________________

   qsay(18,43,nDIAS,"9999")
   qsay(19,43,len(cSUSR)/3,"999")
   qsay(20,43,nQREC,"99999")
   qsay(21,43,cMAIS)
   qsay(22,43,cMENOS)

   qsay(18,69,nQABT,"99999")
   qsay(19,69,nQABT/nQREC*100,"99999")
   qsay(20,69,cMAIOR)
   qsay(21,69,cMENOR)
   qsay(22,69,left(qcenthora(nTOTS/3600/nDIAS),5))

   if ! empty(cUSRNUM)
      QLOGIN->(dbclearfilter(NIL))
   endif
return

/////////////////////////////////////////////////////////////////////////////
// CHECA E ATUALIZA VETOR DE ATIVIDADE NOS HORARIOS DO DIA __________________

static function i_check_ativ ( aATIV )
   local nINICIO := secs(QLOGIN->Inicio)
   local nFINAL  := secs(QLOGIN->Final)
   local nCONT, nHORA

   if empty(nINICIO) .or. empty(nFINAL) .or. nFINAL < nINICIO
      return .T.
   endif

   for nCONT := nINICIO to nFINAL step 60   // de 1 em 1 minutos
       nHORA := val(left(tstring(nCONT),2))
       if nHORA <> 0
          aATIV[nHORA]++
       endif
   next

return .T.

/////////////////////////////////////////////////////////////////////////////
// CHECA E ATUALIZA VETOR COM PROG'S UTILIZADOS _____________________________

static function i_check_prog ( aPROG )
   local cPROG := QLOGIN->Prog
   local nPOINT

   if empty(cPROG) ; return .F. ; endif

   if (nPOINT := ascan(aPROG,{|x|x[1]==cPROG})) == 0
      aadd(aPROG,{cPROG,1})
   else
      aPROG[nPOINT,2]++
   endif

return .T.

