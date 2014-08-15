/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE CONTABILIDADE
// OBJETIVO...: EMISSAO DO CADASTRO DE HISTORICOS
// ANALISTA...: LUIS ANTONIO ORLANDO PEREIRA
// PROGRAMADOR: CARLOS EDUARDO RABELLO NUNES
// INICIO.....: JUNHO DE 1995
// OBS........:
// ALTERACOES.:
function ct502

#define K_MAX_LIN 52


// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG) .or. lastkey() = 27}

private sBLOCO1 := qlbloc("B502B","QBLOC.GLO") // ordem de impressao

private cTITULO                // titulo do relatorio
private cORDEM  := "1"         // ordem de impressao (codigo/descricao)
private aEDICAO := {}          // vetor para os campos de entrada de dados

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qesco(-1,0,@cORDEM,sBLOCO1) } , "ORDEM" })

do while .T.

   qlbloc(5,0,"B502A","QBLOC.GLO")
   XNIVEL := 1
   XFLAG  := .T.
   cCENTRO := cLOCAL := space(10)
   cTIPOREL := " "
   nTOTAL := 0

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

   cTITULO := "RELACAO DO CADASTRO DE HISTORICOS ORDENADO POR "

   // SELECIONA ORDEM DO ARQUIVO HIST _______________________________________

   do case
      case cORDEM == "1"
           HIST->(dbsetorder(01)) // codigo
           cTITULO += "CODIGO"
      case cORDEM == "2"
           HIST->(dbsetorder(02)) // descricao
           cTITULO += "DESCRICAO"
   endcase

   HIST->(dbgotop())
   qmensa()

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impressao

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif
   qmensa("imprimindo...")

   do while ! HIST->(eof()) .and. qcontprn()     // condicao principal de loop

      do case
         case cORDEM == "1"
              qmensa("C¢digo: "+HIST->Codigo+" / "+LEFT(HIST->Descricao,50))
         case cORDEM == "2"
              qmensa(LEFT(HIST->Descricao,50)+" / "+"C¢digo: "+HIST->Codigo)
      endcase

      if ! qlineprn() ; return ; endif

      if XPAGINA == 0 .or. prow() > K_MAX_LIN
         qpageprn()
         qcabecprn(cTITULO,80)
         do case
            case cORDEM == "1"
                 @ prow()+1,0         say "CODIGO"
                 @ prow()  ,pcol()+4  say "DESCRICAO"
            case cORDEM == "2"
                 @ prow()+1,0         say "DESCRICAO"
                 @ prow()  ,pcol()+54 say "CODIGO"
         endcase

         @ prow()+1,0 say replicate("-",80)
      endif

      do case
         case cORDEM == "1"
              @ prow()+1,1         say HIST->Codigo
              @ prow()  ,pcol()+6  say HIST->Descricao
         case cORDEM == "2"
              @ prow()+1,0         say HIST->Descricao
              @ prow()  ,pcol()+15 say HIST->Codigo
      endcase

      HIST->(dbskip())

   enddo

   qstopprn()
   qmensa()

return

