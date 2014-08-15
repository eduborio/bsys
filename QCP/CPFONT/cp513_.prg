/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE COMPRAS
// OBJETIVO...: RELATORIO DE COMPRAS POR COMPRADOR
// ANALISTA...: LUCINEIDE VILAR POSSEBOM WIECZORKOVSKI
// PROGRAMADOR: A MESMA
// INICIO.....: SETEMBRO DE 1999
// OBS........:
// ALTERACOES.:

function cp513

#define K_MAX_LIN 55

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local bESCAPE  := {||(XNIVEL==1 .and. !XFLAG).or.lastkey()==27}

private sBLOC1 := qlbloc("B513B","QBLOC.GLO") // ordem de impressao

private cTITULO                               // titulo do relatorio

private bFILTRO                               // code block de filtro
private bFILTRO1                              // code block de filtro
private aEDICAO := {}                         // vetor para os campos de entrada de dados
private cFILIAL
private cCOMP
private nTOTAL

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || view_comprador(-1,0,@cCOMP,"99999"           ) } ,"COMP"})
aadd(aEDICAO,{{ || NIL },NIL }) // descricao do comprador
aadd(aEDICAO,{{ || view_filial(-1,0,@cFILIAL,"9999"            ) } ,"FILIAL"  })
aadd(aEDICAO,{{ || NIL },NIL }) // descricao da filial
aadd(aEDICAO,{{ || qgetx(-1,0,@dDATA_INI     ,"@!"     ,NIL,NIL) } ,"DATA_INI"})
aadd(aEDICAO,{{ || qgetx(-1,0,@dDATA_FIM     ,"@!"     ,NIL,NIL) } ,"DATA_FIM"})

do while .T.

   qlbloc(5,0,"B513A","QBLOC.GLO",1)
   XNIVEL  := 1
   XFLAG   := .T.
   cFILIAL := space(04)
   cCOMP   := space(05)
   dDATA_INI := ctod("01/" + right(qanomes(date()),2) + "/" + left(qanomes(date()),4))
   dDATA_FIM := qfimmes(dDATA_INI)
   nTOTAL    := 0

   PEDIDO->(dbSetFilter())

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
      case cCAMPO == "COMP"
           if empty(cCOMP) ; return .F. ; endif

           qrsay(XNIVEL,cCOMP:=strzero(val(cCOMP),5))
           if ! CAD_COMP->(dbseek(cCOMP))
              qmensa("Comprador n„o encontrado !","B")
              return .F.
           endif
           qrsay(XNIVEL+1,left(CAD_COMP->Nome,28))

      case cCAMPO == "FILIAL"
           if empty(cFILIAL)
              qrsay(XNIVEL+1,"*** Todas as Filiais ***")
           else
              qrsay(XNIVEL,cFILIAL:=strzero(val(cFILIAL),4))
              if ! FILIAL->(dbseek(cFILIAL))
                 qmensa("Filial n„o encontrada !","B")
                 return .F.
              endif
              qrsay(XNIVEL+1,left(FILIAL->RAZAO,28))
           endif

      case cCAMPO == "DATA_INI"
           if empty(dDATA_INI) ; return .F. ; endif
           dDATA_FIM := qfimmes(dDATA_INI)
           qrsay(XNIVEL+1,dDATA_FIM)

      case cCAMPO == "DATA_FIM"
           if empty(dDATA_FIM) ; return .F. ; endif
           if dDATA_INI > dDATA_FIM
              qmensa("Data Inicial n„o pode ser maior que a Data Final !","B")
              return .F.
           endif
   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // CRIA TITULO DO RELATORIO ______________________________________________

   cTITULO := "PEDIDOS DE COMPRA POR COMPRADOR - " + dtoc(dDATA_INI) + " ATE " + dtoc(dDATA_FIM)
   
   // SELECIONA ORDEM DO ARQUIVO CODIGOS_____________________________________

   qmensa("")

   bFILTRO := { || PEDIDO->Data_ped >= dDATA_INI .and. PEDIDO->Data_ped <= dDATA_FIM .and. PEDIDO->Comprador == cCOMP}

   // ESTABELECE RELACOES ENTRE ARQUIVOS ____________________________________

   PEDIDO->(dbsetorder(1))

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impressao

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif

   PEDIDO->(dbgotop())


   do while ! PEDIDO->(eof()) .and. qcontprn()

      if ! empty(cFILIAL)
         if PEDIDO->Filial <> cFILIAL
            PEDIDO->(dbskip())
            loop
          endif
      endif

      if ! qlineprn() ; exit ; endif

      qgirabarra()
               
      qmensa("Pedido: " + transform(PEDIDO->Codigo,"@R 99999/9999 ") + "Filial: " + alltrim(PEDIDO->Filial))

      if ! empty(cFILIAL)
         if alltrim(PEDIDO->Filial) <> cFILIAL
            exit
         endif
      endif

      if eval(bFILTRO)

         if XPAGINA == 0 .or. prow() > K_MAX_LIN
            qpageprn()
            @ prow(),pcol() say XCOND0
            qcabecprn(cTITULO,80)
            @ prow()+1,0 say "COMPRADOR : " + CAD_COMP->Codigo + "-" + CAD_COMP->Nome
            @ prow()+1,0 say replicate("-",80)
            @ prow()+1,0 say "Pedido          Fornecedor                                     Valor   Comprador"
            @ prow()+1,0 say replicate("-",80)
            @ prow(),pcol() say XCOND1
         endif

         FILIAL->(dbseek(alltrim(PEDIDO->Filial)))

         @ prow()+1,0   say transform(PEDIDO->Codigo,"@R 99999/9999")   ; FORN->(dbseek(PEDIDO->Cod_forn))
         @ prow()  ,25  say FORN->Razao
         @ prow()  ,100 say transform(PEDIDO->Val_liq,"@E 999,999,999.99")
         @ prow()  ,125 say PEDIDO->Comprador

         nTOTAL += PEDIDO->Val_liq

      endif

      PEDIDO->(dbskip())

   enddo

   @ prow()+1,00 say replicate("=",135)
   @ prow()+1,91 say "TOTAL: " + transform(nTOTAL,"@E 9,999,999,999.99")

   qstopprn()

return
