/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO DA USIMIX
// OBJETIVO...: LISTAGEM DE PRODUTOS / CODIGO ASSOCIADO
// ANALISTA...: LUIS ANTONIO ORLANDO PEREIRA
// PROGRAMADOR: LUCINEIDE VILAR POSSEBOM
// INICIO.....: DEZEMBRO DE 1997
// OBS........:
// ALTERACOES.:


function cl531
#define K_MAX_LIN 60

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG) .or. empty(cORDEM)}

private sBLOC1 := qlbloc("B531B","QBLOC.GLO") // ordem de impressao

private cTITULO                   // titulo do relatorio
private cORDEM                    // ordem de impressao (codigo/descricao)
private bFILTRO                   // code block de filtro
private aEDICAO := {}             // vetor para os campos de entrada de dados

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qesco(-1,0,@cORDEM,sBLOC1)  } , "ORDEM" })

do while .T.

   qlbloc(5,0,"B531A","QBLOC.GLO",1)
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

   cTITULO := "LISTAGEM DA TABELA DE PRECOS COMERCIAL "

   // SELECIONA ORDEM DO ARQUIVO CODIGOS_____________________________________

   do case
      case cORDEM == "1" ; PROD->(dbsetorder(1)) // codigo
      case cORDEM == "2" ; PROD->(dbsetorder(2)) // descricao
   endcase

   qmensa("")

   // CRIA MACRO DE FILTRO __________________________________________________

   bFILTRO := { || .T. }

   // ESTABELECE RELACOES ENTRE ARQUIVOS ____________________________________

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
         qcabecprn(cTITULO,80)
         @ prow()+1,0 say "DESCRICAO                                  UN   PRECO ATACADO      PRECO VAREJO"
         @ prow()+1,0 say replicate("-",80)
      endif

      if eval(bFILTRO)
     //    @ prow()+1,0  say PROD->Codigo
         @ prow()+1 ,0 say left(PROD->Descricao,40)
         UNIDADE->(dbseek(PROD->Unidade))
         @ prow()  ,43 say UNIDADE->Sigla
         @ prow()  ,48 say transform(PROD->Preco_at,"@E 999,999.99" )
         @ prow()  ,65 say transform(PROD->Preco_vr,"@E 999,999.99" )

      endif

      PROD->(dbskip())

   enddo

   qstopprn()

return
