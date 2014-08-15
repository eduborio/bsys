/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: FOLHA DE PAGAMENTO
// OBJETIVO...: RELATORIO DE MEDIA DE EVENTOS POR PERIODO
// ANALISTA...: LUCINEIDE VILAR POSSEBOM
// PROGRAMADOR: A MESMA
// INICIO.....: AGOSTO DE 1999
// OBS........:
// ALTERACOES.:

#define K_MAX_LIN 52

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local bESCAPE := {||(XNIVEL==1 .and. !XFLAG) .or. lastkey()==27}

private cANOMES          // referencia para buscar lancamentos
private cMATRI           // matricula do funcionario
private cCOND            // condicao principal de loop
private nMES    := 0
private nPROV   := 0
private nALIQ   := 0
private nSALARIO:= 0
private aEVENTOS:= {}
private aEDICAO := {}    // vetor para os campos de entrada de dados

SITUA->(dbSetFilter({|| Anomes == XANOMES},"Anomes == XANOMES"))
TBIF->(dbSetFilter({|| Anomes == XANOMES},"Anomes == XANOMES"))

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || view_fun(-1,0,@cMATRI)}                , "MATRI" })
aadd(aEDICAO,{{ || NIL },NIL}) // nome do funcionario

do while .T.

   qlbloc(5,0,"B507A","QBLOC.GLO")
   XNIVEL     := 1
   XFLAG      := .T.
   cMATRI     := space(6)

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

   cANOMES := XANOMES

   if empty(cMATRI)
      DIV_CUST->(Dbsetorder(2))
      DIV_CUST->(dbgotop())
      DIV_CUST->(dbseek(cANOMES))
      cCOND := "! DIV_CUST->(eof()) .and. DIV_CUST->Anomes == cANOMES"
   else
      DIV_CUST->(Dbsetorder(2))
      DIV_CUST->(dbgotop())
      if ! DIV_CUST->(dbseek(cANOMES+cMATRI))
         qmensa("N„o existem lan‡amentos !","B")
         return .F.
      endif
      cCOND := "! DIV_CUST->(eof()) .and. DIV_CUST->Matricula == cMATRI .and. DIV_CUST->Anomes == cANOMES"
   endif

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impressao

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif

   // LOOP DE IMPRESSAO _____________________________________________________

   cMAT   := DIV_CUST->Matricula
   cCENTRO:= DIV_CUST->Centro
   lPRI   := .T.
   nHORAS := nSALARIO := nTOT_HORAS := nTOT_PERC := nTOT_VAL := 0
   nRECNO := tHORAS := nTOT_OUTR := nOUTROS := nREC := 0

   do while &cCOND .and. qcontprn()

      qmensa("Imprimnindo ... Aguarde ... ")

      qgirabarra()

      if ! qlineprn() ; return ; endif

      if XPAGINA == 0 .or. prow() > K_MAX_LIN
         @ prow(),pcol() say XCOND0
         qpageprn()
         qcabecprn("RELATORIO DA FOLHA DE PAGAMENTO POR CENTRO DE CUSTO",80)
         if XPAGINA > 1
            @ prow()  ,08 say left(FUN->Nome,40)
            @ prow()  ,55 say "SALARIO ---> " + transform(SITUA->Salario,"@R 9,999,999.99")
            @ prow()+2,00 say "CENTRO DE CUSTO -> " + CCUSTO->Codigo + " - " + CCUSTO->Descricao
            @ prow()+1,00 say ""
            @ prow()+1,00 say "     EVENTO                                HORAS             VALOR    PERCENTUAL"
            @ prow()+1,00 say ""
         endif
      endif

      if cMAT == DIV_CUST->Matricula

         nREC:=DIV_CUST->(recno())
         i_tot_even()
         DIV_CUST->(dbgoto(nREC))

         if cCENTRO <> DIV_CUST->Centro
           cCENTRO := DIV_CUST->Centro
           CCUSTO->(dbseek(DIV_CUST->Centro))
           @ prow()+2,00 say "CENTRO DE CUSTO -> " + CCUSTO->Codigo + " - " + CCUSTO->Descricao
           @ prow()+1,00 say "     EVENTO                                HORAS             VALOR    PERCENTUAL"
           @ prow()+1,00 say ""
         endif

         FUN->(dbseek(DIV_CUST->Matricula))
         CCUSTO->(dbseek(DIV_CUST->Centro))
         EVENT->(dbseek(DIV_CUST->Evento))
         SITUA->(dbseek(DIV_CUST->Matricula))
         nSALARIO := SITUA->Salario
         nTOT_HORAS   := ( DIV_CUST->Tot_mes * nSALARIO )

         if lPRI

            nRECNO := DIV_CUST->(recno())
            nPROV  := 0
            i_prov()  // soma proventos de lancamento
            DIV_CUST->(dbgoto(nRECNO))
            EVENT->(dbseek(DIV_CUST->Evento))

            @ prow()+1,00 say replicate("-",80)
            @ prow()+1,00 say DIV_CUST->Matricula
            @ prow()  ,08 say left(FUN->Nome,40)
            @ prow()  ,55 say "SALARIO ---> " + transform(SITUA->Salario,"@R 9,999,999.99")
            @ prow()+2,00 say "CENTRO DE CUSTO -> " + CCUSTO->Codigo + " - " + CCUSTO->Descricao
            @ prow()+1,00 say ""
            @ prow()+1,00 say "     EVENTO                                HORAS             VALOR    PERCENTUAL"
            @ prow()+1,00 say ""

            @ prow()  ,00 say DIV_CUST->Evento + " - " + left(EVENT->Descricao,30)
            if DIV_CUST->Percentual <> 0
               @ prow() ,42 say "  - "
               nRECNO := DIV_CUST->(recno())
               DIV_CUST->(dbseek(XANOMES+FUN->Matricula+CCUSTO->Codigo+"301"))
               tHORAS := DIV_CUST->Horas
               DIV_CUST->(dbgoto(nRECNO))
               nTOT := ( (tHORAS * nSALARIO)*(DIV_CUST->Percentual)/100)
            elseif DIV_CUST->Horas <> 0
               @ prow()  ,42 say transform(DIV_CUST->Horas,"@R 999.99") + " Hs"
               nTOT := (DIV_CUST->Horas * nSALARIO)
            else
               @ prow() ,42 say "  - "
               nRECNO := DIV_CUST->(recno())
               DIV_CUST->(dbseek(XANOMES+FUN->Matricula+CCUSTO->Codigo+"301"))
               tHORAS := DIV_CUST->Horas
               DIV_CUST->(dbgoto(nRECNO))
               nTOT := ( (tHORAS * nSALARIO)*(nALIQ/100))
            endif
            @ prow()  ,57 say transform(nTOT,"@R 999,999.99")
            if ( nLOC := ascan(aEVENTOS,{|aVal| aVal[1] == DIV_CUST->Evento})) <> 0
               nPERC := ( (nTOT * 100) / aEVENTOS[nLOC,2])
            endif
            @ prow()  ,72 say transform(nPERC,"@R 999.99") + " %"
            if DIV_CUST->Percentual <> 0 .or. ( DIV_CUST->Horas == 0 .and. DIV_CUST->Percentual == 0 )
               nTOT_OUTR += nPERC
               nOUTROS   += nTOT
            else
               nTOT_PERC += nPERC
               nTOT_VAL  += nTOT
            endif

            lPRI := .F.

         else
            @ prow()+1,00 say DIV_CUST->Evento + " - " + left(EVENT->Descricao,30)
            if DIV_CUST->Percentual <> 0
               @ prow() ,42 say "  - "
               nRECNO := DIV_CUST->(recno())
               DIV_CUST->(dbseek(XANOMES+FUN->Matricula+CCUSTO->Codigo+"301"))
               tHORAS := DIV_CUST->Horas
               DIV_CUST->(dbgoto(nRECNO))
               nTOT := ( (tHORAS * nSALARIO)*(DIV_CUST->Percentual)/100)
            elseif DIV_CUST->Horas <> 0
               @ prow()  ,42 say transform(DIV_CUST->Horas,"@R 999.99") + " Hs"
               nTOT := (DIV_CUST->Horas * nSALARIO)
            else
               @ prow() ,42 say "  - "
               nRECNO := DIV_CUST->(recno())
               DIV_CUST->(dbseek(XANOMES+FUN->Matricula+CCUSTO->Codigo+"301"))
               tHORAS := DIV_CUST->Horas
               DIV_CUST->(dbgoto(nRECNO))
               nTOT := ( (tHORAS * nSALARIO)*(nALIQ/100))
            endif
            @ prow()  ,57 say transform(nTOT,"@R 999,999.99")
            if ( nLOC := ascan(aEVENTOS,{|aVal| aVal[1] == DIV_CUST->Evento})) <> 0
               nPERC := ( (nTOT * 100) / aEVENTOS[nLOC,2])
            endif
            @ prow()  ,72 say transform(nPERC,"@R 999.99") + " %"
            if DIV_CUST->Percentual <> 0 .or. ( DIV_CUST->Horas == 0 .and. DIV_CUST->Percentual == 0 )
               nTOT_OUTR += nPERC
               nOUTROS   += nTOT
            else
               nTOT_PERC += nPERC
               nTOT_VAL  += nTOT
            endif
         endif

         nHORAS+= DIV_CUST->Horas

      else
         @ prow()+2,0  say padc("TOTAL",80,"-")
         @ prow()+1,0  say"      (%)       OUTROS (%)     Hs./Mes     HORAS NORMAIS   OUTROS(HORAS NORMAIS)"
         @ prow()+1,04 say transform(nTOT_PERC, "@R 999.99") + " %"
         @ prow()  ,17 say transform(nTOT_OUTR, "@R 999.99") + " %"
         @ prow()  ,32 say transform(nHORAS, "@R 999.99")
         @ prow()  ,46 say transform(nTOT_VAL, "@R 999,999.99")
         @ prow()  ,63 say transform(nOUTROS, "@R 999,999.99")
        @ prow()+1,0 say ""
        nHORAS := nTOT_PERC := nTOT_OUTR := nTOT_VAL := nOUTROS := 0
        lPRI := .T.
        cMAT := DIV_CUST->Matricula
        cCENTRO := DIV_CUST->Centro
        loop                                 // pois aqui ja pulou o registro
      endif
      
      DIV_CUST->(dbskip())

   enddo

   if nHORAS <> 0

      @ prow()+2,0  say padc("TOTAL",80,"-")
      @ prow()+1,0  say"      (%)       OUTROS (%)     Hs./Mes     HORAS NORMAIS   OUTROS(HORAS NORMAIS)"
      @ prow()+1,04 say transform(nTOT_PERC, "@R 999.99") + " %"
      @ prow()  ,17 say transform(nTOT_OUTR, "@R 999.99") + " %"
      @ prow()  ,32 say transform(nHORAS, "@R 999.99")
      @ prow()  ,46 say transform(nTOT_VAL, "@R 999,999.99")
      @ prow()  ,63 say transform(nOUTROS, "@R 999,999.99")

   endif

   qstopprn()

return

////////////////////////////////////////////////////////////
// FUNCAO PARA SOMAR PROVENTOS DO FUNCIONARIO (P/INSS)______
function i_prov
   do while ! DIV_CUST->(eof()) .and. DIV_CUST->Matricula == cMAT
      EVENT->(dbseek(DIV_CUST->Evento))
      if EVENT->Finalidade == "P"
         nPROV += (DIV_CUST->Horas * nSALARIO)
      endif
      DIV_CUST->(dbskip())
   enddo
   // VERIFICA NA TABELA DE INSS A ALIQUOTA DE DESCONTO
   if nPROV > TBIF->if_teto
      nALIQ := 0
   else
     for nCONT := 2 to 5
         if nPROV >= 0 .and. nPROV <= TBIF->If_lim1
            nALIQ := TBIF->If_ali1
            exit
         endif
         if nPROV >= (&("TBIF->If_lim"+str(nCONT-1,1))+0.01) .and. nPROV <= &("TBIF->If_lim"+str(nCONT+1,1))
            nALIQ := &("TBIF->If_ali"+str(nCONT,1))
            exit
         endif
     next
   endif

return


////////////////////////////////////////////////////////////////////////
// FUNCAO UTILIZADA PARA TOTALIZAR OS EVENTOS POR FUNCIONARIO __________
function i_tot_even

local tHORAS

   do while ! DIV_CUST->(eof()) .and. DIV_CUST->Anomes == XANOMES .and. DIV_CUST->Matricula == cMAT
      if DIV_CUST->Percentual <> 0
         nRECNO := DIV_CUST->(recno())
         DIV_CUST->(dbseek(XANOMES+FUN->Matricula+CCUSTO->Codigo+"301"))
         tHORAS := DIV_CUST->Horas
         DIV_CUST->(dbgoto(nRECNO))
         if ( nLOC := ascan(aEVENTOS,{|aVal| aVal[1] == DIV_CUST->Evento}) ) <> 0
            aEVENTOS[nLOC,2] += tHORAS
         else
            aadd(aEVENTOS,{ DIV_CUST->Evento , tHORAS } )
         endif
      elseif DIV_CUST->Horas <> 0
         if ( nLOC := ascan(aEVENTOS,{|aVal| aVal[1] == DIV_CUST->Evento})) <> 0
            aEVENTOS[nLOC,2] += DIV_CUST->Horas
         else
            aadd(aEVENTOS,{DIV_CUST->Evento,DIV_CUST->Horas})
         endif
      else
         nRECNO := DIV_CUST->(recno())
         DIV_CUST->(dbseek(XANOMES+FUN->Matricula+CCUSTO->Codigo+"301"))
         tHORAS := DIV_CUST->Horas
         DIV_CUST->(dbgoto(nRECNO))
         if ( nLOC := ascan(aEVENTOS,{|aVal| aVal[1] == DIV_CUST->Evento})) <> 0
            aEVENTOS[nLOC,2] += tHORAS
         else
            aadd(aEVENTOS,{DIV_CUST->Evento,tHORAS})
         endif
      endif
      DIV_CUST->(dbskip())
   enddo
return
