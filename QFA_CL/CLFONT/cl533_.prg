/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO DA USIMIX
// OBJETIVO...: LISTAGEM DE PRODUTOS / CODIGO ASSOCIADO
// ANALISTA...: EDUARDO BORIO
// PROGRAMADOR: EDUARDO BORIO
// INICIO.....: DEZEMBRO DE 1997
// OBS........:
// ALTERACOES.:

function cl533
#define K_MAX_LIN 60

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG) .or. empty(cORDEM)}

private sBLOC1 := qlbloc("B533B","QBLOC.GLO") // ordem de impressao

private cTITULO                   // titulo do relatorio
private cORDEM                    // ordem de impressao (codigo/descricao)
private bFILTRO                   // code block de filtro
private aEDICAO := {}             // vetor para os campos de entrada de dados

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qesco(-1,0,@cORDEM,sBLOC1)  } , "ORDEM" })

do while .T.

   qlbloc(5,0,"B533A","QBLOC.GLO",1)
   XNIVEL := 1
   XFLAG  := .T.
   cORDEM := " "

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
      case cCAMPO == "ORDEM"
           if empty(cORDEM) ; return .F. ; endif
           qrsay(XNIVEL,qabrev(cORDEM,"12",{"C¢digo","Descric„o"}))
   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // CRIA TITULO DO RELATORIO ______________________________________________

   cTITULO := "LISTAGEM DA TABELA DE PRECOS DISTRIBUIDORA "

   // SELECIONA ORDEM DO ARQUIVO CODIGOS_____________________________________

   do case
      case cORDEM == "1" ; PROD->(dbsetorder(4)) // codigo
      case cORDEM == "2" ; PROD->(dbsetorder(2)) // descricao
   endcase

   qmensa("")

   // CRIA MACRO DE FILTRO __________________________________________________

   bFILTRO := { || .T. }

   // ESTABELECE RELACOES ENTRE ARQUIVOS ____________________________________
   INVENT->(dbsetorder(4))
   INVENT->(dbgotop())
   PROD->(dbgotop())

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impressao

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif

   do while ! PROD->(eof())   // condicao principal de loop

      qmensa("Imprimindo Produto..: " + PROD->Codigo + " / Descricao: "+PROD->Descricao)

      if ! qlineprn() ; exit ; endif

      if XPAGINA == 0 .or. prow() > K_MAX_LIN
         qpageprn()
         @ prow(),0 say XCOND0
         qcabecprn(cTITULO,80)
         @ prow()+1,0 say XCOND1 + "CODIGO DESCRICAO                                                            COD. FABRIC.        PRECO UNITARIO   PRECO DA CAIXA"
         @ prow()+1,0 say replicate("-",130)
      endif

      INVENT->(dbseek(right(PROD->Codigo,5)))
      if eval(bFILTRO)
         if right(PROD->Codigo,5) <> "     " .and. INVENT->Quant_atu > 0
            @ prow()+1,0 say right(PROD->Codigo,5)
            @ prow()  ,8 say PROD->Descricao
            @ prow()  ,73 say PROD->Cod_Fabr
            @ prow()  ,90 say transform(PROD->Preco_1, "@E 999,999.99" )
            @ prow()  ,108 say transform(PROD->Preco_cx,  "@E 999,999.99" )
         endif
      endif

      PROD->(dbskip())

   enddo

   qstopprn()

return
