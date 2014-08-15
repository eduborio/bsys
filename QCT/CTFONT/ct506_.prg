
/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE CONTABILIDADE
// OBJETIVO...: EMISSAO DO CADASTRO MNEUMONICOS
// ANALISTA...:
// PROGRAMADOR: ANDERSON EDUARDO DE LIMA
// INICIO.....: MARCO DE 1997
// OBS........:
// ALTERACOES.:
function ct506

#define K_MAX_LIN 52

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG) .or. lastkey() = 27}

private sBLOCO1 := qlbloc("B506B","QBLOC.GLO") // ordem de impressao

private cTITULO                // titulo do relatorio
private cORDEM  := "1"         // ordem de impressao (codigo/razao)
private aEDICAO := {}          // vetor para os campos de entrada de dados

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qesco(-1,0,@cORDEM,sBLOCO1) } , "ORDEM" })

do while .T.

   qlbloc(5,0,"B506A","QBLOC.GLO")
   XNIVEL   := 1
   XFLAG    := .T.

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
           qrsay(XNIVEL,qabrev(cORDEM,"12",{"C¢digo","Raz„o"}))
   endcase
return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // CONSTROI VARIAVEL "cTITULO" ___________________________________________

   cTITULO := "RELACAO DO CADASTRO DE MNEUMONICOS ORDENADO POR "

   // SELECIONA ORDEM DO ARQUIVO CCUSTO _____________________________________

   do case
      case cORDEM == "1"
           MNEUMO->(dbsetorder(1)) // codigo
           cTITULO += "CODIGO"
      case cORDEM == "2"
           MNEUMO->(dbsetorder(2)) // descricao
           cTITULO += "DESCRICAO"
   endcase

   MNEUMO->(dbgotop())
   qmensa()

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impressao

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif

   qmensa("imprimindo...")

   do while ! MNEUMO->(eof()) .and. qcontprn()     // condicao principal de loop

      do case
         case cORDEM == "1"
              qmensa(alltrim(MNEUMO->Codigo)+" / "+MNEUMO->Descricao)
         case cORDEM == "2"
              qmensa(MNEUMO->Descricao+" / "+alltrim(MNEUMO->Codigo))
      endcase

      if ! qlineprn() ; return ; endif

      if XPAGINA == 0 .or. prow() > K_MAX_LIN
         qpageprn()
         qcabecprn(cTITULO,80)
         do case
            case cORDEM == "1"   //                1         2         3         4         5
                                 //123456 123456789012345678901234567890123456789012345678901234567890
                 @ prow()+1,0 say "Cod...    Descricao..............................."
            case cORDEM == "2"
                 @ prow()+1,0 say "Descricao...............................    Cod..."
         endcase

         @ prow()+1,0        say replicate("-",80)
      endif

      do case
         case cORDEM == "1"
              @ prow()+1,0 say MNEUMO->Codigo+"    "+MNEUMO->Descricao
         case cORDEM == "2"
              @ prow()+1,0 say MNEUMO->Descricao+"    "+MNEUMO->Codigo
      endcase

      MNEUMO->(dbskip())

   enddo

   qstopprn()
   qmensa()

return

