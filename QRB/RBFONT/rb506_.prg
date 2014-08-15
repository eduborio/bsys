/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO DA USIMIX
// OBJETIVO...: EMISSAO DE BLOQUETO BANCARIO AVULSO
// ANALISTA...: EDUARDO AUGUSTO BORIO
// PROGRAMADOR: EDUARDO AUGUSTO BORIO
// INICIO.....: JULHO DE 2001
// OBS........:
// ALTERACOES.:

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

function rb506
local   bESCAPE := {|| (XNIVEL==1 .and. !XFLAG) .or. lastkey()==27 }

private sBLOC1  := qlbloc("B501B","QBLOC.GLO") // Ordem Codigo ou Razao

private aEDICAO := {}    // vetor para os campos de entrada de dados
private dDATA_VENC := ""
private dDATA_DOC  := ""
private dDATA_PROC := ""
private cNUM_DOC   := space(8)
private nVAL_DOC   := 0
private nDESC      := 0
private nOUT_DED   := 0
private nMORA      := 0
private nOUT_ACR   := 0
private nVAL_COB   := 0
private cRAZAO     := space(50)
private cENDERECO  := space(50)
private cMUNICIPIO := space(50)


private cLINHA1 := space(40)
private cLINHA2 := space(40)
private cLINHA3 := space(40)


// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qgetx(-1,0,@dDATA_DOC                        )} ,"dDATA_DOC" })
aadd(aEDICAO,{{ || qgetx(-1,0,@dDATA_VENC                       )} ,"dDATA_VENC" })
aadd(aEDICAO,{{ || qgetx(-1,0,@cNUM_DOC,"99999999"              )} ,"NUM_DOC" })
aadd(aEDICAO,{{ || qgetx(-1,0,@cLINHA1,"@!"                     )} ,"LINHA1" })
aadd(aEDICAO,{{ || qgetx(-1,0,@nVAL_DOC,"@E 9,999,999.99"       )} ,"VAL_DOC" })
aadd(aEDICAO,{{ || qgetx(-1,0,@cLINHA2,"@!"                     )} ,"LINHA2" })
aadd(aEDICAO,{{ || qgetx(-1,0,@nDESC,"@E 9,999,999.99"          )} ,"DESC" })
aadd(aEDICAO,{{ || qgetx(-1,0,@cLINHA3,"@!"                     )} ,"LINHA3" })
aadd(aEDICAO,{{ || qgetx(-1,0,@nOUT_DED,"@E 9,999,999.99"       )} ,"OUT_DED" })
aadd(aEDICAO,{{ || qgetx(-1,0,@nMORA   ,"@E 9,999,999.99"       )} ,"MORA" })
aadd(aEDICAO,{{ || qgetx(-1,0,@nOUT_ACR,"@E 9,999,999.99"       )} ,"OUT_ACR" })
aadd(aEDICAO,{{ || qgetx(-1,0,@cRAZAO,"@!"                      )} ,"RAZAO" })
aadd(aEDICAO,{{ || qgetx(-1,0,@cENDERECO,"@!"                   )} ,"ENDERECO" })
aadd(aEDICAO,{{ || qgetx(-1,0,@cMUNICIPIO,"@!"                  )} ,"MUNICIPIO" })

do while .T.

   qlbloc(5,0,"B514A","QBLOC.GLO")

   XNIVEL  := 1
   XFLAG   := .T.

   cLINHA1 := space(40)
   cLINHA2 := space(40)
   cLINHA3 := space(40)
   dDATA_VENC := ctod("")
   dDATA_DOC  := ctod("")
   cNUM_DOC   := space(8)
   nVAL_DOC   := 0
   nDESC      := 0
   nOUT_DED   := 0
   nMORA      := 0
   nOUT_ACR   := 0
   nVAL_COB   := 0
   cRAZAO     := space(50)
   cENDERECO  := space(50)
   cMUNICIPIO := space(50)

   // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; dbcloseall() ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ); loop   ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   i_impressao()

   qmensa("")

enddo

/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA _____________________________________________

static function i_critica ( cCAMPO )

   do case
      case cCAMPO == "OUT_DED"
           nVAL_COB := nVAL_DOC - nDESC

   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impressao

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif

    @ prow()  ,00 say XCOND1
    @ prow()+2,00 say ""

    @ prow()  ,05 say "Pagavel em qualquer agencia bancaria ate o vencimento"
    @ prow()  ,00 say XCOND0


    @ prow()  ,53 say dtoc(dDATA_VENC)
    @ prow()  ,00 say XCOND1
    @ prow()+3,05 say dtoc(dDATA_DOC)
    @ prow()  ,20 say cNUM_DOC

    @ prow()  ,00 say XCOND0
    @ prow()+1,55 say transform(nVAL_DOC, "@E 999,999.99")
    @ prow()  ,00 say XCOND1

    @ prow()  ,00 say XCOND0
    @ prow()+2,55 say transform(nDESC, "@E 999,999.99")
    @ prow()  ,00 say XCOND1

    @ prow()+1,05 say cLINHA1
    @ prow()+1,05 say cLINHA2
    @ prow()+1,05 say clINHA3

    @ prow()  ,00 say XCOND0
    @ prow()+3,55 say "" //transform(nVAL_DOC-nDESC, "@E 999,999.99")
    @ prow()  ,00 say XCOND1

    @ prow()  ,05 say cRAZAO
    @ prow()+1,05 say cENDERECO
    @ prow()+1,05 say cMUNICIPIO
    @ prow()  ,00 say XCOND0


   qstopprn()

return
