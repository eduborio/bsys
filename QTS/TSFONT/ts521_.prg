/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE TESOURARIA
// OBJETIVO...: RELATORIO DE CONTAS A RECEBER/RECEBIDO
// ANALISTA...:
// PROGRAMADOR: EDUARDO AUGUSTO BORIO
// INICIO.....: FEVEREIRO DE 2003
// OBS........:

function ts521

#define K_MAX_LIN 52

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG .or. lastkey()==27)}

local  cCONT := 1

private cTITULO          // titulo do relatorio
private cCLI := space(5)            // Codigo do cliente
private cTIPO := space(1)

private dDATA_INI        // define data inicial para impressao
private dDATA_FIM        // define datao final para impressao
private aEDICAO := {}    // vetor para os campos de entrada de dados
private nTOT    := 0
private nTOT_DIA:= 0
private nTOT_GER:= 0
sBLOC1 :=  qlbloc("B521B","QBLOC.GLO",1)

fu_abre_cli1()

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qesco(-1,0,@cTIPO , sBLOC1              ) } ,"TIPO"     })
aadd(aEDICAO,{{ || qgetx(-1,0,@dDATA_INI                   ) } ,"DATA_INI" })
aadd(aEDICAO,{{ || qgetx(-1,0,@dDATA_FIM                   ) } ,"DATA_FIM" })
aadd(aEDICAO,{{ || view_cli(-1,0,@cCLI                     ) } ,"CLI" })
aadd(aEDICAO,{{ || NIL                                       } ,  NIL  })

do while .T.

   qlbloc(05,0,"B521A","QBLOC.GLO",1)

   XNIVEL  := 1
   XFLAG   := .T.
   dDATA_INI  := ctod("")
   dDATA_FIN  := ctod("")
   cCLI  := space(5)
   cTIPO := space(1)

   // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; dbcloseall() ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ); loop   ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   if ( i_inicializacao() , i_impressao() , NIL )

   qmensa("")

enddo

/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA _____________________________________________

static function i_critica ( cCAMPO )

   do case

      case cCAMPO == "DATA_INI"
           if empty(dDATA_INI) ; return .F. ; endif
           dDATA_FIM := qfimmes(dDATA_INI)
           qrsay(XNIVEL+1,dDATA_FIM)

      case cCAMPO == "DATA_FIM"
           if empty(dDATA_FIM) ; return .F. ; endif
           if dDATA_INI > dDATA_FIM
              qmensa("Data Inicial n„o pode ser maior que a Data Final !","B")
              return .F.
           endif

      case cCAMPO == "CLI"

           qrsay(XNIVEL,cCLI)

           if empty(cCLI)
              qrsay(XNIVEL++, "Todos os Clientes.......")
           else
              if ! CLI1->(Dbseek(cCLI:=strzero(val(cCLI),5)))
                 qmensa("Cliente n„o Cadastrado","B")
                 return .F.
              else
                 qrsay(XNIVEL++,left(CLI1->Razao,30))
              endif
           endif
      case cCAMPO == "TIPO"

           qrsay(XNIVEL,qabrev(cTIPO,"EV",{"Emissao","Vencimento"}))

   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // DEFINE VARIAVEL DE COMPACTACAO ________________________________________

   // CRIA TITULO DO RELATORIO ______________________________________________

   cTITULO := "LISTAGEM DE DUPLICATAS DESCONTADAS " + dtoc(dDATA_INI) + " a " + dtoc(dDATA_FIM)
   if cTIPO == "E"
      RECEBIDO->(dbsetfilter({||iif(!empty(cCLI),Cod_cli==cCLI,Cod_cli!="00000").and.RECEBIDO->Data_emiss>=dDATA_INI.and.RECEBIDO->Data_Emiss<=dDATA_FIM.and.RECEBIDO->Tipo == "6"}, 'iif(!empty(cCLI),Cod_cli == cCLI,cod_cli != "00000").and.RECEBIDO->Data_emiss>=dDATA_INI.and.RECEBIDO->Data_emiss<=dDATA_FIM.and.RECEBIDO->Tipo == "6"'))
   else
      RECEBIDO->(dbsetfilter({||iif(!empty(cCLI),Cod_cli==cCLI,Cod_cli!="00000").and.RECEBIDO->Data_venc>=dDATA_INI.and.RECEBIDO->Data_venc<=dDATA_FIM.and.RECEBIDO->Tipo == "6"}, 'iif(!empty(cCLI),Cod_cli == cCLI,cod_cli != "00000").and.RECEBIDO->Data_venc>=dDATA_INI.and.RECEBIDO->Data_venc<=dDATA_FIM.and.RECEBIDO->Tipo == "6"'))
   endif
   qmensa("")

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impressao

   local nMAXLIN := 55

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif
   qmensa("imprimindo...")
   if cTIPO == "E"
      RECEBIDO->(dbsetorder(4))
   else
      RECEBIDO->(dbsetorder(2))
   endif
   RECEBIDO->(dbgotop())

   XPAGINA  := 0
   nTOT_DIA := 0
   nTOT     := 0

   dVENC := RECEBIDO->Data_pagto
   
   do while ! RECEBIDO->(eof()) .and. qcontprn()  // condicao principal de loop

       if ! qlineprn() ; exit ; endif

       if XPAGINA == 0 .or. prow() > K_MAX_LIN
          qpageprn()
          @ prow(),pcol() say XCOND0
          qcabecprn(cTITULO,80)
          @ prow(),pcol() say XCOND1
          @ prow()+1, 0 say "EMISSAO    VENCIMENTO  DUPLICATA        CLIENTE                                      VALOR  POSICAO                DESCONTADA"
          @ prow(),pcol() say XCOND0
          @ prow()+1, 0 say replicate("-",80)
          @ prow(),pcol() say XCOND1
       endif

       @ prow()+1,00  say dtoc(RECEBIDO->Data_emiss)
       @ prow()  ,11  say dtoc(RECEBIDO->Data_venc)
       @ prow()  ,23  say RECEBIDO->Fatura

       CLI1->(dbseek(RECEBIDO->Cod_cli))
       @ prow()  ,40  say left(CLI1->Razao,35)
       @ prow()  ,78  say transform(RECEBIDO->Valor_liq, "@E 9,999,999.99")

       SITUA->(dbseek(RECEBIDO->Situacao))
       @ prow()  ,92  say left(SITUA->Descricao,20)
       @ prow()  ,115  say dtoc(RECEBIDO->Data_pagto)

       nTOT_DIA := nTOT_DIA + RECEBIDO->Valor_liq
       nTOT := nTOT + RECEBIDO->Valor_liq
       nTOT_GER := nTOT_GER + RECEBIDO->Valor_liq

       RECEBIDO->(dbskip())

   enddo

   if nTOT <> 0

      @ prow(), pcol() say XCOND0
      @ prow()+1, 0 say replicate("-",80)
      @ prow(), pcol() say XCOND1
      @ prow()+1,58 say "Total descontado...> "+transform(nTOT, "@E 9,999,999.99")
   endif

   qstopprn()

return
