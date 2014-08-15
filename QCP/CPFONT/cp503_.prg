/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE COMPRAS
// OBJETIVO...: RELATORIO DE COMPRAS P. FAMILIA DE MATERIAIS
// ANALISTA...: LUCINEIDE VILAR POSSEBOM
// PROGRAMADOR: A MESMA
// INICIO.....: JULHO DE 1999
// OBS........:
// ALTERACOES.:

function cp503

#define K_MAX_LIN 47

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local bESCAPE  := {||(XNIVEL==1 .and. !XFLAG).or.lastkey()==27}

private sBLOC1 := qlbloc("B503B","QBLOC.GLO") // ordem de impressao

private cTITULO                               // titulo do relatorio

private bFILTRO                               // code block de filtro
private aEDICAO    := {}                      // vetor para os campos de entrada de dados
private cGRUPO_MAT := ""
private cGRUPO_PEC := ""
private cGRUPO_OUT := ""
private lTEM    := .F.

PROD->(dbsetorder(6)) // codigo do sub-grupo

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || view_prod2(-1,0,@cGRUPO_MAT ,"99"                )} ,"GRUPO_MAT"   })
aadd(aEDICAO,{{ || NIL },NIL }) // descricao da grupo de produtos
aadd(aEDICAO,{{ || view_prod2(-1,0,@cGRUPO_PEC ,"99"                )} ,"GRUPO_PEC"   })
aadd(aEDICAO,{{ || NIL },NIL }) // descricao da grupo de produtos
aadd(aEDICAO,{{ || view_prod2(-1,0,@cGRUPO_OUTC ,"99"               )} ,"GRUPO_OUT"   })
aadd(aEDICAO,{{ || NIL },NIL }) // descricao da grupo de produtos
aadd(aEDICAO,{{ || qgetx(-1,0,@dDATA_INI     ,"@!"     ,NIL,NIL) } ,"DATA_INI"})
aadd(aEDICAO,{{ || qgetx(-1,0,@dDATA_FIM     ,"@!"     ,NIL,NIL) } ,"DATA_FIM"})

do while .T.

   qlbloc(5,0,"B503A","QBLOC.GLO",1)

   XNIVEL  := 1
   XFLAG   := .T.

   cGRUPO     := space(4)
   dDATA_INI  := ctod("01/" + right(qanomes(date()),2) + "/" + left(qanomes(date()),4))
   dDATA_FIM  := qfimmes(dDATA_INI)

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
      case cCAMPO == "GRUPO_MAT"
           PROD->(dbsetorder(1)) // codigo
           if len(alltrim(cGRUPO_MAT)) > 2 .or. len(alltrim(cGRUPO_MAT)) < 2
              qmensa("Informe a familia de materiais !","B")
              return .F.
           endif
           if ! empty(cGRUPO_MAT)
              if ! PROD->(dbseek(cGRUPO_MAT))
                 qmensa("Familia de Materiais n„o encontrado !","B")
                 return .F.
              endif
              qrsay(XNIVEL+1,left(PROD->Descricao,25))
           else
              return .F.
           endif

      case cCAMPO == "GRUPO_PEC"
           PROD->(dbsetorder(1)) // codigo

           if len(alltrim(cGRUPO_PEC)) > 2 .or. len(alltrim(cGRUPO_PEC)) < 2
              qmensa("Informe a familia de pe‡as !","B")
              return .F.
           endif

           if ! empty(cGRUPO_PEC)
              if ! PROD->(dbseek(cGRUPO_PEC))
                 qmensa("Familia de Pe‡as n„o encontrado !","B")
                 return .F.
              endif
              qrsay(XNIVEL+1,left(PROD->Descricao,25))
           else
              return .F.
           endif

      case cCAMPO == "GRUPO_OUT"
           PROD->(dbsetorder(1)) // codigo
           if len(alltrim(cGRUPO_OUT)) > 2 .or. len(alltrim(cGRUPO_OUT)) < 2
              qmensa("Informe a familia de pe‡as !","B")
              return .F.
           endif
           if ! empty(cGRUPO_OUT)
              if ! PROD->(dbseek(cGRUPO_OUT))
                 qmensa("Familia de Pe‡as n„o encontrado !","B")
                 return .F.
              endif
              qrsay(XNIVEL+1,left(PROD->Descricao,25))
           else
              return .F.
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

   cTITULO := "RELATORIO DE COMPRAS POR FAMILIA DE PRODUTOS DE: " + dtoc(dDATA_INI) + " ATE " + dtoc(dDATA_FIM)
   
   // SELECIONA ORDEM DO ARQUIVO CODIGOS_____________________________________

   qmensa("")

   bFILTRO := { || PEDIDO->Data_ped >= dDATA_INI .and. PEDIDO->Data_ped <= dDATA_FIM }

   // ESTABELECE RELACOES ENTRE ARQUIVOS ____________________________________

   PEDIDO->(dbsetorder(6)) // data_ped
   PEDIDO->(dbgotop())
   set softseek on
   PEDIDO->(dbseek(dtos(dDATA_INI)))
   set softseek off

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impressao

   local cPIC   := "@E 999,999.99"
   local nTOT_PEC := nTOT_MAT := nTOT_OUT := 0

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif

   if ! qlineprn() ; return ; endif

   qgirabarra()

   do while ! PEDIDO->(eof())

      qgirabarra()

      if XPAGINA == 0 .or. prow() > K_MAX_LIN
         qpageprn()
         qcabecprn(cTITULO,80)
         PROD->(dbsetorder(6))
         PROD->(dbseek(cGRUPO_MAT))
         @ prow()+1,0 say padc("FAMILIA DE MATERIAIS : " + alltrim(PROD->Descricao),80," ")
         PROD->(dbseek(cGRUPO_PEC))
         @ prow()+1,0 say padc("FAMILIA DE PECAS     : " + alltrim(PROD->Descricao),80," ")
         PROD->(dbseek(cGRUPO_OUT))
         @ prow()+1,0 say padc("FAMILIA DE OUTROS    : " + alltrim(PROD->Descricao),80," ")
         @ prow()+1,0 say "Nota Fiscal  Fornecedor                           Materiais      Pe‡as     Outros"
         @ prow()+1,0 say replicate("-",80)
      endif

      if eval(bFILTRO)

         LANC->(dbsetorder(1))
         LANC->(dbgotop())
         LANC->(dbseek(PEDIDO->Codigo))
         PROD->(dbsetorder(4)) // codigo

         lTEM := .F.
         lMAT := .F.
         lPEC := .F.
         lOUT := .F.

         do while ! LANC->(eof()) .and. LANC->Cod_ped == PEDIDO->Codigo
            if PROD->(dbseek(LANC->Cod_prod))
               if left(PROD->Codigo,2) == cGRUPO_MAT
                  lTEM := .T.
                  lMAT := .T.
               elseif left(PROD->Codigo,2) == cGRUPO_PEC
                  lTEM := .T.
                  lPEC := .T.
               elseif left(PROD->Codigo,2) == cGRUPO_OUT
                  lTEM := .T.
                  lOUT := .T.
               endif

            endif
            LANC->(dbskip())
         enddo

         if lTEM
            @ prow()+1,0  say PEDIDO->Numero_nf ; FORN->(dbseek(PEDIDO->Cod_forn))
            @ prow()  ,13 say left(FORN->Razao,35)
            if lMAT
               @ prow()  ,48 say transform(PEDIDO->Val_liq,cPIC)
               nTOT_MAT += PEDIDO->Val_liq
            endif
            if lPEC
               @ prow()  ,60 say transform(PEDIDO->Val_liq,cPIC)
               nTOT_PEC += PEDIDO->Val_liq
            endif
            if lOUT
               @ prow()  ,71 say transform(PEDIDO->Val_liq,cPIC)
               nTOT_OUT += PEDIDO->Val_liq
            endif
            lTEM := .F.
         endif

      endif

      PEDIDO->(dbskip())

   enddo

   @ prow()+1,0  say replicate("-",80)
   @ prow()+1,0  say padr("TOTAL DE COMPRAS DO PERIODO",40,".")
   @ prow()  ,48 say transform(nTOT_MAT,"@E 9,999,999.99")
   @ prow()  ,58 say transform(nTOT_PEC,"@E 9,999,999.99")
   @ prow()  ,69 say transform(nTOT_OUT,"@E 9,999,999.99")

   qstopprn()

return
