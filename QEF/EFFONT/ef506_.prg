
/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE ESCRITA FISCAL
// OBJETIVO...: LISTAGEM DE CODIGOS MAQUINA REGISTRADORA
// ANALISTA...: LUIS ANTONIO ORLANDO PEREIRA
// PROGRAMADOR: IN SUNG CHANG
// INICIO.....: FEVEREIRO DE 1995
// OBS........:
// ALTERACOES.:
function ef506

#define K_MAX_LIN 55

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local bESCAPE  := {||(XNIVEL==1 .and. !XFLAG) .or. empty(cORDEM)}

private sBLOC1 := qlbloc("B506B","QBLOC.GLO")    // ordem de impressao

private cTITULO                                  // titulo do relatorio
private cORDEM                                   // ordem de impressao (codigo/descricao)
private bFILTRO                                  // code block de filtro
private aEDICAO := {}                            // vetor para os campos de entrada de dados

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qesco(-1,0,@cORDEM,sBLOC1)  } , "ORDEM" })

do while .T.

   qlbloc(5,0,"B506A","QBLOC.GLO",1)
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

enddo

/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA _____________________________________________

static function i_critica ( cCAMPO )
   local nMES, nANO
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

   cTITULO := "LISTAGEM GERAL DE CODIGOS DE MAQUINA REGISTRADORA"

   // SELECIONA ORDEM DO ARQUIVO CLI ________________________________________

   do case
      case cORDEM == "1" ; MAQ->(dbsetorder(1)) // codigo
      case cORDEM == "2" ; MAQ->(dbsetorder(2)) // descricao
   endcase

   qmensa("")

   // CRIA MACRO DE FILTRO __________________________________________________

   bFILTRO := { || .T. }

   // ESTABELECE RELACOES ENTRE ARQUIVOS ____________________________________

   select MAQ

   MAQ->(dbgotop())

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impressao

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif

   do while ! MAQ->(eof()) .and. qcontprn()     // condicao principal de loop

      qmensa("Imprimindo MAQuto: "+MAQ->Maq_Cod+" / Descricao: "+MAQ->Maq_Desc)

      if ! qlineprn() ; exit ; endif

      if XPAGINA == 0 .or. prow() > K_MAX_LIN
         qpageprn()
         qcabecprn(cTITULO,80)
         @ prow()+1,0 say "CODIGO         DESCRICAO "
         @ prow()+1,0 say replicate("-",80)
      endif

      if eval(bFILTRO)

         @ prow()+1,0 say MAQ->Maq_Cod + space(13) + MAQ->Maq_Desc

      endif

      MAQ->(dbskip())

   enddo

   qstopprn()

return
