/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: FOLHA DE PAGAMENTO
// OBJETIVO...: RELATORIO DE MEDIA DE EVENTOS POR PERIODO
// ANALISTA...: LUCINEIDE VILAR POSSEBOM
// PROGRAMADOR: A MESMA
// INICIO.....: JULHO DE 1999
// OBS........:
// ALTERACOES.:

#define K_MAX_LIN 52

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local bESCAPE := {||(XNIVEL==1 .and. !XFLAG) .or. lastkey()==27}

private cPERI            // periodo inicial
private cPERF            // periodo final
private cANOMES          // referencia para buscar lancamentos
private cEVENT           // evento
private cMATRI           // matricula do funcionario
private cCOND            // condicao principal de loop
private nMES    := 0
private aEDICAO := {}    // vetor para os campos de entrada de dados

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || view_fun(-1,0,@cMATRI)}                , "MATRI" })
aadd(aEDICAO,{{ || NIL },NIL}) // nome do funcionario
aadd(aEDICAO,{{ || qgetx(-1,0,@cPERI,"@R 99/9999")}       , "PERI" })
aadd(aEDICAO,{{ || qgetx(-1,0,@cPERF,"@R 99/9999")}       , "PERF" })
aadd(aEDICAO,{{ || view_event(-1,0,@cEVENT)}               , "EVENT" })
aadd(aEDICAO,{{ || NIL },NIL}) // descricao do evento

do while .T.

   qlbloc(5,0,"B506A","QBLOC.GLO")
   XNIVEL     := 1
   XFLAG      := .T.
   cEVENT     := space(3)
   cMATRI     := space(6)
   cPERI := cPERF := space(6)

   // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; dbcloseall() ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   if ( i_inicializacao() , i_impressao() , NIL )

   qmensa()

enddo

/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA _____________________________________________

static function i_critica ( cCAMPO )
   do case
      case cCAMPO == "EVENT"
           if ! empty(cEVENT)
              if ! EVENT->(dbseek(cEVENT))
                 qmensa("Evento n„o Cadastrado !!","B")
                 return .F.
              else
                 qrsay(XNIVEL+1,left(EVENT->Descricao,30))
              endif
           endif

      case cCAMPO == "MATRI"
           if empty(cMATRI)
              qrsay(XNIVEL+1,"*** Todos os funcionarios***")
           else
              if ! FUN->(dbseek(cMATRI:=strzero(val(cMATRI),6)))
                 qmensa("Funcionario n„o Cadastrado !!","B")
                 return .F.
              else
                 qrsay(XNIVEL+1,left(FUN->Nome,25))
              endif
           endif

   endcase
return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // SELECIONA ORDEM DO ARQUIVO CADFUN _____________________________________

   qmensa()

   // ESTABELECE RELACOES ENTRE ARQUIVOS ____________________________________

   cANOMES := qanomes(ctod("01/"+left(cPERI,2)+"/"+right(cPERI,4)))

   if empty(cMATRI)
      LANC->(Dbsetorder(2))
      LANC->(dbgotop())
      if ! LANC->(dbseek(cANOMES+cEVENT))
         qmensa("N„o existem lan‡amentos neste per¡odo para este evento !","B")
         return .F.
      endif
      cCOND := "! LANC->(eof()) .and. LANC->Anomes == cANOMES .and. LANC->Evento == cEVENT"
   else
      LANC->(Dbsetorder(3))
      LANC->(dbgotop())
      if ! LANC->(dbseek(cMATRI+cANOMES+cEVENT))
         qmensa("N„o existem lan‡amentos neste per¡odo para este evento !","B")
         return .F.
      endif
      cCOND := "! LANC->(eof()) .and. LANC->Matricula == cMATRI .and. LANC->Anomes == cANOMES .and. LANC->Evento == cEVENT"
   endif

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impressao

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif

   // LOOP DE IMPRESSAO _____________________________________________________

   nCONT   := 0 // contador para realizar media aritimetica
   nFRACAO := 0 // valor da fracao do evento

   cDAT1 := ctod("01/"+left(cPERI,2)+"/"+right(cPERI,4))
   cDAT2 := ctod("01/"+left(cPERF,2)+"/"+right(cPERF,4))
   if cDAT1 <> cDAT2
      cVEZES := ((cDAT2 - cDAT1) / 30) + 1  // quantos meses
   else
      cVEZES := 1
   endif

   for nCONTA := 1 to cVEZES

      if empty(cMATRI)
         LANC->(dbseek(cANOMES+cEVENT))
      else
         LANC->(dbseek(cMATRI+cANOMES+cEVENT))
      endif

      do while &cCOND .and. qcontprn()

         qmensa("Processando ... Aguarde ... ")

         qgirabarra()

         if LANC->Fracao <> 0
            nFRACAO += LANC->Fracao
            nCONT++
         endif

         LANC->(dbskip())

      enddo

      if nMES > 12
         cANOMES := qanomes(ctod("01/"+left(cPERF,2)+"/"+right(cPERF,4)))
      else
         nMES := val(left(cPERI,2)) + 1
         cANOMES := qanomes(ctod("01/"+str(nMES,2)+"/"+right(cPERI,4)))
      endif

   next

   if ! qlineprn() ; return ; endif

   if XPAGINA == 0 .or. prow() > K_MAX_LIN
      qpageprn()
      qcabecprn("MEDIA DE EVENTOS POR PERIODO",80)
   endif

   @ prow()+1,0 say "FUNCIONARIO  -> " + iif(empty(cMATRI),"Todos os funcionarios",left(FUN->Nome,30))
   @ prow()+1,0 say "EVENTO       -> " + cEVENT + " - " + EVENT->Descricao
   @ prow()+1,0 say "PERIODO      -> " + left(cPERI,2)+"/"+right(cPERI,4) + " a " + left(cPERF,2) +"/"+right(cPERF,4)
   @ prow()+1,0 say "MEDIA        -> " + transform(nFRACAO,"@R 99,999.99") + "   / " + transform(nCONT,"@R 9999") + "  =  " + transform(nFRACAO/nCONT,"@R 9,999,999.99")
   @ prow()+1,0 say replicate("-",80)

   qstopprn()

return
