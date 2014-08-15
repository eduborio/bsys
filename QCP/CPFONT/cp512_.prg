////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO DA USIMIX
// OBJETIVO...: LISTAGEM DE PRODUTOS - FABRICANTE/MARCA
// ANALISTA...: LUIS ANTONIO ORLANDO PEREIRA
// PROGRAMADOR: PAULO FOGACA
// INICIO.....: OUTUBRO DE 1995
// OBS........:
// ALTERACOES.:

function cp512

#define K_MAX_LIN 60

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG) .or. lastkey()==27}

private sBLOC1 := qlbloc("B507B","QBLOC.GLO") // ordem de impressao


private cPROD :=Space(5)
private cTITULO                   // titulo do relatorio
private cORDEM                    // ordem de impressao (codigo/descricao)
private bFILTRO                   // code block de filtro
private aEDICAO := {}             // vetor para os campos de entrada de dados
private cGRUPO  := ""

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || view_prod2(-1,0,@cGRUPO,"99")},"GRUPO"  })
aadd(aEDICAO,{{ || NIL },NIL }) // descricao da grupo de produtos
aadd(aEDICAO,{{ || qesco(-1,0,@cORDEM,sBLOC1)  } , "ORDEM" })

do while .T.

   qlbloc(5,0,"B512A","QBLOC.GLO",1)
   XNIVEL := 1
   XFLAG  := .T.
   cORDEM := " "
   cGRUPO     := space(2)

   // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; dbcloseall() ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   if ( i_inicializacao() , i_impressao() , NIL )

   qmensa("")

enddo

/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA _____________________________________________

static function i_critica ( cCAMPO )

   do case
      case cCAMPO == "GRUPO"
           PROD->(dbsetorder(1)) // codigo
           if empty(cGRUPO)
              qrsay(XNIVEL+1,"*** Todas as familias ***")
              return .T.
           endif
           if len(alltrim(cGRUPO)) > 2 .or. len(alltrim(cGRUPO)) < 2
              qmensa("Informe somente a familia dos produtos !","B")
              return .F.
           endif
           if ! empty(cGRUPO)
              if ! PROD->(dbseek(cGRUPO))
                 qmensa("Familia de Produto n„o encontrado !","B")
                 return .F.
              endif
              qrsay(XNIVEL+1,left(PROD->Descricao,30))
           else
              return .F.
           endif
      case cCAMPO == "ORDEM"
           if empty(cORDEM) ; return .F. ; endif
           qrsay(XNIVEL,qabrev(cORDEM,"12",{"C¢digo","Descric„o"}))
   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // CRIA TITULO DO RELATORIO ______________________________________________

   cTITULO := "LISTAGEM GERAL DE PRODUTOS, PRECO DE CUSTO E QUANTIDADE "

   // SELECIONA ORDEM DO ARQUIVO CODIGOS_____________________________________

   do case
      case cORDEM == "1" ; PROD->(dbsetorder(1)) // codigo
      case cORDEM == "2" ; PROD->(dbsetorder(2)) // descricao
   endcase

   qmensa("")

   // ESTABELECE RELACOES ENTRE ARQUIVOS ____________________________________

   PROD->(dbgotop())

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impressao

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif

   do while ! PROD->(eof())   // condicao principal de loop

      if ! empty(cGRUPO)
         if left(PROD->Codigo,2) <> cGRUPO
            PROD->(dbskip())
            loop
         endif
      endif

      cPROD := right(PROD->Codigo,5)

      qmensa("Imprimindo Produto..: " + PROD->Codigo + " / Descricao: "+PROD->Descricao)

      if ! qlineprn() ; exit ; endif

      if XPAGINA == 0 .or. prow() > K_MAX_LIN
         qpageprn()
         qcabecprn(cTITULO,80)
         @ prow()+1,0 say "CODIGO      DESCRICAO                                          PRECO DE CUSTO"
         @ prow()+1,0 say replicate("-",80)
      endif

      INVENT->(dbsetorder(4))
      INVENT->(dbgotop())

      cQUANT := 0

      if INVENT->(dbseek(cPROD))

         while ! INVENT->(eof()) .and. INVENT->Cod_prod == right(PROD->Codigo,5)
            cQUANT += INVENT->Quant_atu
            INVENT->(dbskip())
         enddo

         @ prow()+1,0 say left(PROD->Cod_fabr,6) + space(03) + left(PROD->Descricao,34) + space(22) + transform(PROD->Preco_cust,"@E 9,999,999.99")

      endif

      PROD->(dbskip())

   enddo

   qstopprn()

return
