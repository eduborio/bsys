/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO COMERCIO
// OBJETIVO...: LISTAGEM DE VENDEDORES
// ANALISTA...: EDUARDO BORIO
// PROGRAMADOR: EDUARDO BORIO
// INICIO.....: SETEMBRO DE 2002
// OBS........:
// ALTERACOES.:

function cl502
#define K_MAX_LIN 60

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG) .or. empty(cORDEM)}

private sBLOC1 := qlbloc("B502B","QBLOC.GLO") // ordem de impressao

private cTITULO                   // titulo do relatorio
private cORDEM                    // ordem de impressao (codigo/descricao)
private bFILTRO                   // code block de filtro
private aEDICAO := {}             // vetor para os campos de entrada de dados

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qesco(-1,0,@cORDEM,sBLOC1)  } , "ORDEM" })

do while .T.

   qlbloc(5,0,"B502A","QBLOC.GLO",1)
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
           qrsay(XNIVEL,qabrev(cORDEM,"12",{"C¢digo","Nome"}))
   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // CRIA TITULO DO RELATORIO ______________________________________________

   cTITULO := "LISTAGEM GERAL DE VENDEDORES "

   // SELECIONA ORDEM DO ARQUIVO CODIGOS_____________________________________

   do case
      case cORDEM == "1" ; VEND->(dbsetorder(1)) // codigo
      case cORDEM == "2" ; VEND->(dbsetorder(2)) // nome
   endcase

   qmensa("")

   // CRIA MACRO DE FILTRO __________________________________________________


   // ESTABELECE RELACOES ENTRE ARQUIVOS ____________________________________

   VEND->(dbgotop())

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impressao

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif

   do while ! VEND->(eof())   // condicao principal de loop

      qmensa("Imprimindo Produto..: " + VEND->Codigo + " / Nome: "+VEND->Nome)

      if ! qlineprn() ; exit ; endif

      if XPAGINA == 0 .or. prow() > K_MAX_LIN
         qpageprn()
         qcabecprn(cTITULO,80)
         @ prow()+1,0 say "CODIGO  NOME                                              "
         @ prow()+1,0 say replicate("-",80)
      endif

      @ prow()+1,0 say VEND->Codigo + space(03) + VEND->Nome


      VEND->(dbskip())

   enddo

   qstopprn()

return
