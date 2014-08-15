/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO DA USIMIX
// OBJETIVO...: LISTAGEM DE PRODUTOS / CODIGO ASSOCIADO
// ANALISTA...: LUIS ANTONIO ORLANDO PEREIRA
// PROGRAMADOR: LUCINEIDE VILAR POSSEBOM
// INICIO.....: DEZEMBRO DE 1997
// OBS........:
// ALTERACOES.:

function cp521

#define K_MAX_LIN 60

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG) .or. empty(cORDEM)}

private sBLOC1 := qlbloc("B511B","QBLOC.GLO") // ordem de impressao

private cTITULO                   // titulo do relatorio
private cORDEM                    // ordem de impressao (codigo/descricao)
private bFILTRO                   // code block de filtro
private aEDICAO := {}             // vetor para os campos de entrada de dados

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qesco(-1,0,@cORDEM,sBLOC1)  } , "ORDEM" })

do while .T.

   qlbloc(5,0,"B511A","QBLOC.GLO",1)
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

   cTITULO := "LISTAGEM DE PRODUTOS C/ CUSTO em Dolar e Renminbi"

   // SELECIONA ORDEM DO ARQUIVO CODIGOS_____________________________________

   do case
      case cORDEM == "1" ; PROD->(dbsetorder(3)) // codigo
      case cORDEM == "2" ; PROD->(dbsetorder(2)) // descricao
   endcase

   qmensa("")

   // CRIA MACRO DE FILTRO __________________________________________________

   bFILTRO := { || .T. }

   // ESTABELECE RELACOES ENTRE ARQUIVOS ____________________________________

   PROD->(dbgotop())

return .T.

static function i_impressao

   if ! qinitprn() ; return ; endif

   if XLOCALIMP == "X"
      i_impre_xls()
   else
      i_impre_prn()
   endif



return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impre_prn

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   do while ! PROD->(eof())   // condicao principal de loop

      qmensa("Imprimindo Produto..: " + PROD->Codigo + " / Descricao: "+PROD->Descricao)

      //if ! qlineprn() ; exit ; endif

      if XPAGINA == 0 .or. prow() > K_MAX_LIN
         qpageprn()
         qcabecprn(cTITULO,134)
         @ prow()+1,0 say "REF.      REF2.     DESCRICAO                               Peso            Preco Custo         Preco Venda"
         @ prow()+1,0 say replicate("-",134)
      endif

      if eval(bFILTRO)
         @ prow()+1,0  say PROD->Cod_ass
         @ prow()  ,10 say left(PROD->Cod_fabr,7)
         @ prow()  ,20 say left(PROD->Descricao,30)
         @ prow()  ,54 say transf(PROD->Peso,"@E 9999999.999")
         @ prow()  ,77 say transf(PROD->Preco_cust  ,"@E 999,999.99")
         @ prow()  ,97 say transf(PROD->Preco_cons  ,"@E 999,999.99")
      endif

      PROD->(dbskip())

   enddo

   qstopprn(.f.)

return

static function i_impre_xls

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   do while ! PROD->(eof())   // condicao principal de loop

      //qmensa("Imprimindo Produto..: " + PROD->Codigo + " / Descricao: "+PROD->Descricao)

      //if ! qlineprn() ; exit ; endif

      if XPAGINA == 0
         qpageprn()
         @ prow()+1,0 say chr(9)+chr(9)+cTITULO+" 521"
         @ prow()+1,0 say "Ref."+chr(9)+"Ref2."+chr(9)+"Descricao"+chr(9)+"Peso"+chr(9)+"Preco Custo"+chr(9)+"Preco Venda"
         @ prow()+1,0 say ""
      endif

      if right(PROD->Codigo,5) == "     "
         PROD->(dbskip())
         loop
      endif

      @ prow()+1,0      say PROD->Cod_ass
      @ prow()  ,pcol() say chr(9)+left(PROD->Cod_fabr,7)
      @ prow()  ,pcol() say chr(9)+left(PROD->Descricao,30)
      @ prow()  ,pcol() say chr(9)+transf(PROD->Peso,"@E 999999.999")
      @ prow()  ,pcol() say chr(9)+transf(PROD->Preco_Cust,"@E 99,999,999.99")
      @ prow()  ,pcol() say chr(9)+transf(PROD->Preco_cons,"@E 99,999,999.99")

      PROD->(dbskip())

   enddo

   qstopprn(.F.)

return

