/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE ESTOQUES
// OBJETIVO...: RELATORIO DE ORDENS DE SERVICO
// ANALISTA...: EDUARDO BORIO
// PROGRAMADOR: EDUARDO BORIO
// INICIO.....: DEZEMBRO DE 2002
// OBS........:
// ALTERACOES.:
function es405

#define K_MAX_LIN 55

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local bESCAPE  := {||(XNIVEL==1 .and. !XFLAG).or.lastkey()==27}

private cTITULO                               // titulo do relatorio

private bFILTRO                               // code block de filtro
private aEDICAO := {}                         // vetor para os campos de entrada de dados
private cOS     := space(5)                   // codigo da O.S. para impressao
private nTOT_GER   := 0
private nMAT_PRIM  := 0
private nINSUMOS   := 0
private nEMBALAG   := 0
private nSALARIOS  := 0
private nIMPOSTOS  := 0
private nLUZ       := 0
private nAGUA      := 0
private nTEL       := 0
private nFRETES    := 0
private nCOND      := 0
private nLIMPEZA   := 0
private nESCRITORIO:= 0
private nOUTROS    := 0
private nTOTAL     := 0
private nQUANTIDADE:= 0
private nCUSTO     := 0
private lPRI
private dDT_INI                // data inicial na faixa
private dDT_FIM                // data final na faixa

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qgetx(-1,0,@nMAT_PRIM ,"@E 999,999.99" )} ,"MAT_PRIM" })
aadd(aEDICAO,{{ || qgetx(-1,0,@nINSUMOS  ,"@E 999,999.99" )} ,"INSUMOS" })
aadd(aEDICAO,{{ || qgetx(-1,0,@nEMBALAG  ,"@E 999,999.99" )} ,"EMBALAG" })
aadd(aEDICAO,{{ || qgetx(-1,0,@nSALARIOS ,"@E 999,999.99" )} ,"SALARIOS" })
aadd(aEDICAO,{{ || qgetx(-1,0,@nIMPOSTOS ,"@E 999,999.99" )} ,"SALARIOS" })
aadd(aEDICAO,{{ || qgetx(-1,0,@nLUZ      ,"@E 999,999.99" )} ,"LUZ" })
aadd(aEDICAO,{{ || qgetx(-1,0,@nAGUA     ,"@E 999,999.99" )} ,"AGUA" })
aadd(aEDICAO,{{ || qgetx(-1,0,@nTEL      ,"@E 999,999.99" )} ,"TEL" })
aadd(aEDICAO,{{ || qgetx(-1,0,@nFRETES   ,"@E 999,999.99" )} ,"FRETES" })
aadd(aEDICAO,{{ || qgetx(-1,0,@nCOND     ,"@E 999,999.99" )} ,"COND" })
aadd(aEDICAO,{{ || qgetx(-1,0,@nLIMPEZA  ,"@E 999,999.99" )} ,"LIMPEZA" })
aadd(aEDICAO,{{ || qgetx(-1,0,@nESCRITORIO,"@E 999,999.99")} ,"ESCRITORIO"})
aadd(aEDICAO,{{ || qgetx(-1,0,@nOUTROS    ,"@E 999,999.99")} ,"OUTROS"})
aadd(aEDICAO,{{ || NIL } ,NIL})

aadd(aEDICAO,{{ || qgetx(-1,0,@nQUANTIDADE  ,"@R 99999999")} ,"QUANTIDADE"})
aadd(aEDICAO,{{ || NIL } ,NIL})

do while .T.

   qlbloc(5,0,"B405A","QBLOC.GLO",1)
   XNIVEL  := 1
   XFLAG   := .T.
   cOS     := space(5)
   dDT_INI    := ctod("")
   dDT_FIM    := qfimmes(dDT_INI)
   nMAT_PRIM  := 0
   nINSUMOS   := 0
   nEMBALAG   := 0
   nSALARIOS  := 0
   nIMPOSTOS  := 0
   nLUZ       := 0
   nAGUA      := 0
   nTEL       := 0
   nFRETES    := 0
   nCOND      := 0
   nLIMPEZA   := 0
   nESCRITORIO:= 0
   nOUTROS    := 0
   nTOTAL     := 0
   nQUANTIDADE:= 0
   nCUSTO     := 0

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
      case cCAMPO == "OUTROS"
          nTOTAL :=  (nMAT_PRIM+nINSUMOS+nEMBALAG+nSALARIOS+nIMPOSTOS+nLUZ+nAGUA+nTEL+nFRETES+nCOND+nLIMPEZA+nESCRITORIO+nOUTROS)
          qrsay(XNIVEL+1,nTOTAL,"@E 999,999,999.99")

      case cCAMPO == "QUANTIDADE"
          nCUSTO := (nTOTAL / nQUANTIDADE)
          qrsay(XNIVEL+1,nCUSTO,"@E 999,999.99")

   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // CRIA TITULO DO RELATORIO ______________________________________________

   cTITULO := "EMISSAO DE PLANILHA DE CUSTOS"
   
   // SELECIONA ORDEM DO ARQUIVO CODIGOS_____________________________________

   qmensa("")

   // ESTABELECE RELACOES ENTRE ARQUIVOS ____________________________________

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impressao


   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif
//   if ! qlineprn() ; exit ; endif

   qgirabarra()

   if XPAGINA == 0   .or. prow() > K_MAX_LIN
      @ prow(),pcol() say XCOND0
      qpageprn()
      qcabecprn(cTITULO,80)
   endif

   @ prow()+1,00 say "MATERIA PRIMA.......: "+ transform(nMAT_PRIM  ,"@E 999,999.99")
   @ prow()+1,00 say "INSUMOS.............: "+ transform(nINSUMOS   ,"@E 999,999.99")
   @ prow()+1,00 say "EMBALAGENS..........: "+ transform(nEMBALAG   ,"@E 999,999.99")
   @ prow()+1,00 say "SALARIOS............: "+ transform(nSALARIOS  ,"@E 999,999.99")
   @ prow()+1,00 say "IMPOSTOS............: "+ transform(nIMPOSTOS  ,"@E 999,999.99")
   @ prow()+1,00 say "LUZ.................: "+ transform(nLUZ       ,"@E 999,999.99")
   @ prow()+1,00 say "AGUA................: "+ transform(nAGUA      ,"@E 999,999.99")
   @ prow()+1,00 say "TELEFONE............: "+ transform(nTEL       ,"@E 999,999.99")
   @ prow()+1,00 say "FRETES..............: "+ transform(nFRETES    ,"@E 999,999.99")
   @ prow()+1,00 say "CONDUCAO............: "+ transform(nCOND      ,"@E 999,999.99")
   @ prow()+1,00 say "MAT LIMPEZA.........: "+ transform(nLIMPEZA   ,"@E 999,999.99")
   @ prow()+1,00 say "MAT ESCRITORIO......: "+ transform(nESCRITORIO,"@E 999,999.99")
   @ prow()+1,00 say "OUTROS CUSTOS.......: "+ transform(nOUTROS    ,"@E 999,999.99")

   @ prow()+2,00 say "TOTAL...............: "+ transform(nTOTAL    ,"@E 9,999,999.99")
   @ prow()+1,00 say "QUATIDADE TOTAL PRODUZIDA.: "+ transform(nQUANTIDADE  ,"@R 99999999")

   @ prow()+1,00 say "CUSTO UNITARIO......: "+ transform(nCUSTO  ,"@E 999,999.99")


  qstopprn()

return
