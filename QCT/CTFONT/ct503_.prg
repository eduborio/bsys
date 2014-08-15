
/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE CONTABILIDADE
// OBJETIVO...: EMISSAO DO CADASTRO DE CENTROS DE CUSTO
// ANALISTA...:
// PROGRAMADOR: IN SUNG CHANG
// INICIO.....: JANEIRO DE 1997
// OBS........:
// ALTERACOES.:
function ct503

#define K_MAX_LIN 52

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG) .or. lastkey() = 27}

private sBLOCO1 := qlbloc("B503B","QBLOC.GLO") // ordem de impressao

private cTITULO                // titulo do relatorio
private cORDEM  := "1"         // ordem de impressao (codigo/descricao)
private aEDICAO := {}          // vetor para os campos de entrada de dados

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qesco(-1,0,@cORDEM,sBLOCO1) } , "ORDEM" })

do while .T.

   qlbloc(5,0,"B503A","QBLOC.GLO")
   XNIVEL   := 1
   XFLAG    := .T.
   cCENTRO  := space(10)
   cTIPOREL := " "

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
      case cCAMPO == "ORDEM"
           qrsay(XNIVEL,qabrev(cORDEM,"12",{"C¢digo","Descri‡„o"}))
   endcase
return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // CONSTROI VARIAVEL "cTITULO" ___________________________________________

   cTITULO := "RELACAO DO CADASTRO DE CENTROS DE CUSTO ORDENADO POR "

   // SELECIONA ORDEM DO ARQUIVO CCUSTO _____________________________________

   do case
      case cORDEM == "1"
           CCUSTO->(dbsetorder(1)) // codigo
           cTITULO += "CODIGO"
      case cORDEM == "2"
           CCUSTO->(dbsetorder(2)) // descricao
           cTITULO += "DESCRICAO"
   endcase

   CCUSTO->(dbgotop())
   qmensa()

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impressao

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif

   qmensa("imprimindo...")

   do while ! CCUSTO->(eof()) .and. qcontprn()     // condicao principal de loop

      do case
         case cORDEM == "1"
              qmensa("Conta: "+CCUSTO->Codigo+" / "+CCUSTO->Descricao)
         case cORDEM == "2"
              qmensa(CCUSTO->Descricao+" / "+"Conta: "+CCUSTO->Codigo)
      endcase

      if ! qlineprn() ; return ; endif

      if XPAGINA == 0 .or. prow() > K_MAX_LIN
         qpageprn()
         qcabecprn(cTITULO,80)
         do case
            case cORDEM == "1"
                 @ prow()+1,0         say "CODIGO"
                 @ prow()  ,pcol()+8  say "DESCRICAO"

            case cORDEM == "2"
                 @ prow()+1,0         say "DESCRICAO"
                 @ prow()  ,pcol()+43 say "CODIGO"
         endcase

         @ prow()+1,0        say replicate("-",80)
      endif

      do case
         case cORDEM == "1"
              @ prow()+1,0         say CCUSTO->Codigo
              do case
                 case len(alltrim(CCUSTO->Codigo)) == 2 ; @ prow()  ,pcol()+6  say CCUSTO->Descricao
                 case len(alltrim(CCUSTO->Codigo)) == 4 ; @ prow()  ,pcol()+6  say "  "+CCUSTO->Descricao
                 case len(alltrim(CCUSTO->Codigo)) == 8 ; @ prow()  ,pcol()+6  say "    "+CCUSTO->Descricao
              endcase
         case cORDEM == "2"
              do case
                 case len(alltrim(CCUSTO->Codigo)) == 2 ; @ prow()  ,pcol()+6  say CCUSTO->Descricao
                 case len(alltrim(CCUSTO->Codigo)) == 4 ; @ prow()  ,pcol()+6  say "  "+CCUSTO->Descricao
                 case len(alltrim(CCUSTO->Codigo)) == 8 ; @ prow()  ,pcol()+6  say "    "+CCUSTO->Descricao
              endcase
              @ prow()  ,pcol()+10 say CCUSTO->Codigo
      endcase

      CCUSTO->(dbskip())

   enddo

   qstopprn()
   qmensa()

return

