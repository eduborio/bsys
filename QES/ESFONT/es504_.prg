/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE ESTOQUES
// OBJETIVO...: RELATORIO DE ORDENS DE SERVICO
// ANALISTA...: LUCINEIDE VILAR POSSEBOM
// PROGRAMADOR: LUCINEIDE VILAR POSSEBOM
// INICIO.....: JULHO DE 1999
// OBS........:
// ALTERACOES.:
function es504

#define K_MAX_LIN 55

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local bESCAPE  := {||(XNIVEL==1 .and. !XFLAG).or.lastkey()==27}

private cTITULO                               // titulo do relatorio

private bFILTRO                               // code block de filtro
private aEDICAO := {}                         // vetor para os campos de entrada de dados
private cOS     := space(5)                   // codigo da O.S. para impressao
private nTOT_GER := 0
private lPRI
private dDT_INI                // data inicial na faixa
private dDT_FIM                // data final na faixa

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || view_os(-1,0,@cOS ,"99999"                   )} ,"OS"      })
aadd(aEDICAO,{{ || qgetx(-1,0,@dDT_INI    ,"@D"      )},"DT_INI"})
aadd(aEDICAO,{{ || qgetx(-1,0,@dDT_FIM    ,"@D"      )},"DT_FIMF"})

do while .T.

   qlbloc(5,0,"B504A","QBLOC.GLO",1)
   XNIVEL  := 1
   XFLAG   := .T.
   cOS     := space(5)
   dDT_INI    := ctod("")
   dDT_FIM    := qfimmes(dDT_INI)

   // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; dbcloseall() ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   if ( i_inicializacao() , i_impressao() , NIL )

enddo

/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA _____________________________________________

static function i_critica ( cCAMPO )

   do case
      case cCAMPO == "OS"
           if empty(cOS)
              qrsay(XNIVEL+1,"*** Todas as O.S.'s ***")
           else
              if ! OS->(dbseek(cOS))
                 qmensa("Ordem de servi‡o n„o encontrada !","B")
                 return .F.
              endif
           endif
      case cCAMPO == "DT_INI"

           if empty(dDT_INI) ; return .F. ; endif
           dDT_FIM := qfimmes(dDT_INI)
           qrsay(XNIVEL+1,dDT_FIM)

      case cCAMPO == "DT_FIM"

           if empty(dDT_FIM) ; return .F. ; endif
           if dDT_INI > cDT_FIM
              qmensa("Data Inicial n„o pode ser maior que a Data Final !","B")
              return .F.
           endif

   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // CRIA TITULO DO RELATORIO ______________________________________________

   cTITULO := "RELATORIO DE ORDENS DE SERVICO"
   
   // SELECIONA ORDEM DO ARQUIVO CODIGOS_____________________________________

   qmensa("")

   // ESTABELECE RELACOES ENTRE ARQUIVOS ____________________________________

   REQUISIC->(dbsetorder(5)) // NUMERO DA O.S.
   REQUISIC->(dbgotop())

   PROD->(dbsetorder(4))     // CODIGO REDUZIDO

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impressao


   if ! empty(cOS)
      OS->(DbSetFilter({|| OS->Codigo == cOS }, 'OS->Codigo == cOS'))
//    if ! REQUISIC->(dbseek(OS->Codigo))
//       qmensa("N„o foram realizadas requisi‡oes para esta O.S.","B")
//       OS->(Dbsetfilter())
//       return
//    endif
   else
      OS->(dbgotop())
//    if ! REQUISIC->(dbseek(OS->Codigo))
//       qmensa("N„o foram realizadas requisi‡oes !","B")
//       return
//    endif
   endif

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif

   do while ! OS->(eof()) .and. qcontprn()

      cCOD_OS := OS->Codigo

      do while ! REQUISIC->(eof()) .and. REQUISIC->Nr_os == OS->Codigo

         if REQUISIC->Dt_requisic < dDT_INI .and. REQUISIC->Dt_requisic > dDT_FIM
            REQUISIC->(dbskip())
            loop
         endif

         if ! qlineprn() ; exit ; endif

         qgirabarra()

         if XPAGINA == 0   .or. prow() > K_MAX_LIN
            @ prow(),pcol() say XCOND0
            qpageprn()
            qcabecprn(cTITULO,80)
            @ prow()+1,00  say "ORDEM DE SERVICO: " + OS->Codigo
            @ prow()+1,00  say "Descricao: " + OS->Descricao
            @ prow()  ,65 say "Placa: " + OS->Placa
            @ prow()+1,00  say "Modelo: " + OS->Modelo
            @ prow()  ,25 say "Chassis: " + OS->Chassis

         endif
            nlin := prow() + 4
        if OS->Codigo == cCOD_OS   .and.  nlin < K_MAX_LIN
            @ prow()+1,00 say replicate("-",80)
            @ prow()+1,00 say "Data"
            @ prow()  ,11 say "Prod."
            @ prow()  ,17 say "Descricao"
            @ prow()  ,43 say "Quantidade"
            @ prow()  ,56 say "Unitario"
            @ prow()  ,69 say "Total"
            @ prow()+1,00 say replicate("-",80)

            cCOD_OS := OS->Codigo

         endif

         if ITENS_RQ->(dbseek(REQUISIC->Codigo))

            @ prow()+1,00 say dtoc(REQUISIC->Dt_requisi)

            nTOTAL := 0

            do while ! ITENS_RQ->(eof()) .and. ITENS_RQ->Cod_req == REQUISIC->Codigo

               PROD->(dbseek(ITENS_RQ->Cod_produt))

               @ prow() ,11 say ITENS_RQ->Cod_produt
               @ prow() ,17 say left(PROD->Descricao,15)
               @ prow() ,43 say transform(ITENS_RQ->Quantidade,"@E 9999999999")
               @ prow() ,54 say transform(ITENS_RQ->Vl_unitari,"@E 9,999,999.99")
               @ prow() ,67 say transform((ITENS_RQ->Quantidade*ITENS_RQ->Vl_unitari),"@E 99,999,999.99")

               nTOTAL += (ITENS_RQ->Quantidade * ITENS_RQ->Vl_unitari)

               ITENS_RQ->(dbskip())
               @ prow()+1,00 say ""

               if prow() > K_MAX_LIN
                     @ prow(),pcol() say XCOND0
                     qpageprn()
                     qcabecprn(cTITULO,80)
                     @ prow()+1,00 say replicate("-",80)
                     @ prow()+1,00 say "Data"
                     @ prow()  ,11 say "Prod."
                     @ prow()  ,17 say "Descricao"
                     @ prow()  ,43 say "Quantidade"
                     @ prow()  ,56 say "Unitario"
                     @ prow()  ,69 say "Total"
                     @ prow()+1,00 say replicate("-",80)
                      @ prow()+1 ,00 say dtoc(REQUISIC->Dt_requisi)  + "  (Continua‡ao...) "
                     loop


               endif

            enddo


            @ prow()+1,00 say padr("Total dos produtos",65,".")
            @ prow()  ,67 say transform(nTOTAL,"@E 99,999,999.99")

            nTOT_GER += nTOTAL

         endif

         REQUISIC->(dbskip())

         cCOD_OS := REQUISIC->Nr_os

      enddo

      do while ! PEDIDO->(eof())

         if PEDIDO->Nr_os <> OS->Codigo
            PEDIDO->(dbskip())
            loop
         endif

         if PEDIDO->Data_ped < dDT_INI .and. PEDIDO->Data_ped > dDT_FIM
            PEDIDO->(dbskip())
            loop
         endif

         if ! qlineprn() ; exit ; endif

         qgirabarra()

         if XPAGINA == 0   .or. prow() > K_MAX_LIN
            @ prow(),pcol() say XCOND0
            qpageprn()
            qcabecprn(cTITULO,80)
            @ prow()+1,00  say "ORDEM DE SERVICO: " + OS->Codigo
            @ prow()+1,00  say "Descricao: " + OS->Descricao
            @ prow()  ,65 say "Placa: " + OS->Placa
            @ prow()+1,00  say "Modelo: " + OS->Modelo
            @ prow()  ,25 say "Chassis: " + OS->Chassis
         endif

        nlin := prow() + 4

        if OS->Codigo == cCOD_OS   .and.  nlin < K_MAX_LIN
            @ prow()+1,00 say replicate("-",80)
            @ prow()+1,00 say "Data"
            @ prow()  ,11 say "Prod."
            @ prow()  ,17 say "Descricao"
            @ prow()  ,43 say "Quantidade"
            @ prow()  ,56 say "Unitario"
            @ prow()  ,69 say "Total"
            @ prow()+1,00 say replicate("-",80)

            cCOD_OS := OS->Codigo

         endif

         if LANC->(dbseek(PEDIDO->Codigo))

            @ prow()+1,00 say dtoc(PEDIDO->Data_ped)

            nTOTAL := 0

            do while ! LANC->(eof()) .and. LANC->Cod_ped == PEDIDO->Codigo

               PROD->(dbseek(LANC->Cod_prod))

               @ prow() ,11 say LANC->Cod_prod
               @ prow() ,17 say left(PROD->Descricao,15)
               @ prow() ,43 say transform(LANC->Quant,"@E 9999999999")
               @ prow() ,54 say transform(LANC->Preco,"@E 9,999,999.99")
               @ prow() ,67 say transform((LANC->Quant*LANC->Preco),"@E 99,999,999.99")

               nTOTAL += (LANC->Quant * LANC->Preco)

               LANC->(dbskip())
               @ prow()+1,00 say ""

               if prow() > K_MAX_LIN
                     @ prow(),pcol() say XCOND0
                     qpageprn()
                     qcabecprn(cTITULO,80)
                     @ prow()+1,00 say replicate("-",80)
                     @ prow()+1,00 say "Data"
                     @ prow()  ,11 say "Prod."
                     @ prow()  ,17 say "Descricao"
                     @ prow()  ,43 say "Quantidade"
                     @ prow()  ,56 say "Unitario"
                     @ prow()  ,69 say "Total"
                     @ prow()+1,00 say replicate("-",80)
                      @ prow()+1 ,00 say dtoc(PEDIDO->Data_ped)  + "  (Continua‡ao...) "
                     loop
               
               endif

            enddo
         
            @ prow()+1,00 say padr("Total dos produtos",65,".")
            @ prow()  ,67 say transform(nTOTAL,"@E 99,999,999.99")

            nTOT_GER += nTOTAL

         endif

         PEDIDO->(dbskip())

         cCOD_OS := PEDIDO->Nr_os

      enddo

      OS->(dbskip())


   enddo

   @ prow()+1,00 say XCOND0 + replicate("=",80) + XCOND1
   @ prow()+1,00 say padr("Total Geral",65,".")
   @ prow()  ,67 say transform(nTOT_GER,"@E 9,999,999.99")

  qstopprn()

return
