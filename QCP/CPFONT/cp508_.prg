/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE COMPRAS
// OBJETIVO...: RELATORIO DE POR FILIAL E FORNECEDOR
// ANALISTA...: IN SUNG CHANG
// PROGRAMADOR: IN SUNG CHANG
// INICIO.....: JULHO DE 1997
// OBS........:
// ALTERACOES.:

function cp508

#define K_MAX_LIN 55

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local bESCAPE  := {||(XNIVEL==1 .and. !XFLAG).or.lastkey()==27}

private sBLOC1 := qlbloc("B508B","QBLOC.GLO") // ordem de impressao

private cTITULO                               // titulo do relatorio

private bFILTRO                               // code block de filtro
private bFILTRO1                              // code block de filtro
private aEDICAO := {}                         // vetor para os campos de entrada de dados
private cFILIAL
private cCOD_FORN
private nTOTAL

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || view_filial(-1,0,@cFILIAL,"9999"            ) } ,"FILIAL"  })
aadd(aEDICAO,{{ || NIL },NIL }) // descricao da filial
aadd(aEDICAO,{{ || view_forn(-1,0,@cCOD_FORN,"99999"           ) } ,"COD_FORN"})
aadd(aEDICAO,{{ || NIL },NIL }) // descricao do fornecedor
aadd(aEDICAO,{{ || qgetx(-1,0,@dDATA_INI     ,"@!"     ,NIL,NIL) } ,"DATA_INI"})
aadd(aEDICAO,{{ || qgetx(-1,0,@dDATA_FIM     ,"@!"     ,NIL,NIL) } ,"DATA_FIM"})

do while .T.

   qlbloc(5,0,"B508A","QBLOC.GLO",1)
   XNIVEL  := 1
   XFLAG   := .T.
   cFILIAL := space(04)
   cCOD_FORN := space(05)
   dDATA_INI := ctod("01/" + right(qanomes(date()),2) + "/" + left(qanomes(date()),2))
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
      case cCAMPO == "FILIAL"
           if empty(cFILIAL) ; return .F. ; endif

           qrsay(XNIVEL,cFILIAL:=strzero(val(cFILIAL),4))
           if ! FILIAL->(dbseek(cFILIAL))
              qmensa("Filial n„o encontrado !","B")
              return .F.
           endif
           qrsay(XNIVEL+1,left(FILIAL->RAZAO,28))

      case cCAMPO == "COD_FORN"
           if empty(cCOD_FORN) ; return .F. ; endif

           qrsay(XNIVEL,cCOD_FORN:=strzero(val(cCOD_FORN),5))
           if ! FORN->(dbseek(cCOD_FORN))
              qmensa("Fornecedor n„o encontrado !","B")
              return .F.
           endif
           qrsay(XNIVEL+1,left(FORN->Razao,28))

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

   cTITULO := "RELATORIO DE PEDIDOS DE: " + dtoc(dDATA_INI) + " ATE " + dtoc(dDATA_FIM)
   
   // SELECIONA ORDEM DO ARQUIVO CODIGOS_____________________________________

   qmensa("")

   bFILTRO := { || PEDIDO->Data_ped >= dDATA_INI .and. PEDIDO->Data_ped <= dDATA_FIM }

   // ESTABELECE RELACOES ENTRE ARQUIVOS ____________________________________

   PEDIDO->(dbsetorder(6)) // DATA  DO PEDIDO

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impressao

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif

   @ prow(),pcol() say XCOND0

   PEDIDO->(dbgotop())
   PEDIDO->(dbseek(dtos(dDATA_INI)),.T.)

   do while ! PEDIDO->(eof()) .and. qcontprn()

      if ! qlineprn() ; exit ; endif

      qgirabarra()
               
      qmensa("Aguarde Filtrando os Pedidos da Filial: " + cFILIAL + " do Fornecedor: " + cCOD_FORN)

      if eval(bFILTRO) .and. alltrim(PEDIDO->Filial)==cFILIAL .and. PEDIDO->Cod_forn==cCOD_FORN
         if LANC->(dbseek(PEDIDO->Codigo))
            do while ! LANC->(eof()) .and. PEDIDO->Codigo == LANC->Cod_ped

               qgirabarra()

               if XPAGINA == 0 .or. prow() > K_MAX_LIN
                  qpageprn()
                  qcabecprn(cTITULO,80)
                  @ prow()+1,0 say "FILIAL....: " + FILIAL->Razao
                  @ prow()+1,0 say "FORNECEDOR: " + FORN->Razao
                  @ prow()+1,0 say replicate("-",80)
                  @ prow()+1,0 say "  Data     Pedido                                              Valor   Comprador"
                  @ prow()+1,0 say replicate("-",80)
               endif

               qmensa("Pedido: " + transform(PEDIDO->Codigo,"@R 99999/99") )

               @ prow()+1,0 say dtoc(PEDIDO->Data_ped) + "  " +;
                                transform(PEDIDO->Codigo,"@R 99999/99") + space(39) +;
                                transform(LANC->Preco*LANC->Quant,"@E 9,999,999.99") + "    " +;
                                PEDIDO->Comprador

               nTOTAL += LANC->Preco * LANC->Quant

               LANC->(dbskip())

            enddo

         endif
      endif
      PEDIDO->(dbskip())
   enddo

   @ prow()+1,0 say replicate("=",80)
   @ prow()+1,49 say "TOTAL: " + transform(nTOTAL,"@E 99,999,999.99")

   qstopprn()

return
