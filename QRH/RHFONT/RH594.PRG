/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE IMPRESSAO RELOGIO PONTO
// OBJETIVO...: LISTAGEM DE FUNCIONARIOS C/ HORARIO DE SAIDA/ENTRADA
// ANALISTA...: ANDRE SANTOS
// PROGRAMADOR: O MESMO
// INICIO.....: FEVEREIRO 2000
// OBS........:
// ALTERACOES.: 

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG .or. lastkey()==27)}

CADPONTO->(dbsetrelation('FUN', {|| Matricula},'Matricula'))
CADPONTO->(dbsetrelation('LANC',{|| Matricula},'Matricula'))

qlbloc(06,00,"B594A","QBLOC.GLO")

private cTITULO          // titulo do relatorio
private cPERI            // Periodo inicial
private cPERF            // Periodo final      
private cMATRICULA       // Matricula do funcionario para filtragem
private aEDICAO := {}    // vetor para os campos de entrada de dados

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qgetx(-1,0,@cPERI,'99/99/9999')  } , "PERI"   })
aadd(aEDICAO,{{ || qgetx(-1,0,@cPERF,'99/99/9999')  } , "PERF"  })


do while .T.

   cPERI = space(10)
   cPERF = space(10)
   XNIVEL  := 1
   XFLAG   := .T.
   cORDEM  := " "
   cTIPO   := " "
   cFILIAL := "    "

   // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; dbcloseall() ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ); loop   ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   cPERF = substr(cPERF,7,4) + substr(cPERF,4,2) + substr(cPERF,1,2)  //iguala variavel p/ formato do arquivo CADPONTO
   cPERI = substr(cPERI,7,4) + substr(cPERI,4,2) + substr(cPERI,1,2)  // idem intem anterior

   @ 23,20 say cPERI
   @ 24,20 say cPERF

   inkey(0)

   if ( i_inicializacao() , i_impressao() , NIL )

   CADPONTO->(dbgotop())

*   qmensa("")

enddo

/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA _____________________________________________

static function i_critica ( cCAMPO )

   do case
      case cCAMPO == "PERF"
      case cCAMPO == 'PERI'
   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // DEFINE VARIAVEL DE COMPACTACAO ________________________________________

*   iif(cMODELO=="2",cCOMPAC:="XCOND2",cCOMPAC:="XCOND1")

   // CRIA TITULO DO RELATORIO ______________________________________________

   cTITULO := "LISTAGEM GERAL DE FUNCIONARIOS ENTRADA/SAIDA: "   // + iif(empty(cFILIAL),"TODOS",cFILIAL)


   // ESTABELECE RELACOES ENTRE ARQUIVOS ____________________________________

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impressao

   local cMODELO := '3'

   local nMAXLIN := iif(cMODELO=="3",53,60)

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif

   zMATRICULA = CADPONTO->Matricula

*   CADPONTO->(dbsetfilter({|| Data > cPERI .and. Data < cPERF}, 'Data > cPERI .and. Data < cPERF'))

*   zMATRICULA = CADPONTO->Matricula

   do while ! CADPONTO->(eof())  // condicao principal de loop


*      if zMATRICULA <> CADPONTO->Matricula
*         FUN->(dbseek(CADPONTO->Matricula))
*         SITUA->(dbseek(CADPONTO->Matricula))
*      endif


      zDATA = substr(CADPONTO->Data,7,2) + '/' + substr(CADPONTO->Data,5,2) + '/' + substr(CADPONTO->Data,3,2)

      if ! qlineprn() ; exit ; endif

      if XPAGINA == 0 .or. prow() > nMAXLIN .or. zMATRICULA <> CADPONTO->Matricula
         qpageprn()
*         eject
         qcabecprn(cTITULO,80)
         @ prow()+1,0 say 'Funcionario.......:' + space(3) + FUN->Nome
         @ prow()+1,0 say "MATRICULA     DATA       ENTRADA   SAIDA       "
         @ prow()+1,0 say replicate("-",80)
      endif
   
      qmensa("Imprimindo Funcionario.:"  + space(2) + CADPONTO->Matricula + '  Data:  ' + cPERI + space(2) + cPERF)

      if CADPONTO->Data >= cPERI .and. CADPONTO->Data <= cPERF
         @ prow()+1,0 say space(1) + CADPONTO->Matricula + space(06) + zDATA + space(06) + CADPONTO->Horaent + space(4) + CADPONTO->Horasai
      endif

      zMATRICULA = CADPONTO->Matricula
      CADPONTO->(dbskip())

   enddo

   qstopprn()

return
