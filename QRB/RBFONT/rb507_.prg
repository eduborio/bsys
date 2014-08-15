/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE CONTAS A RECEBER
// OBJETIVO...: LISTAGEM DE CONTAS A RECEBER POR CLIENTES
// ANALISTA...:
// PROGRAMADOR:
// INICIO.....: MARCO DE 1997
// OBS........:
function rb507

#define K_MAX_LIN 52

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG .or. lastkey()==27)}

local  cCONT := 1

private cTITULO          // titulo do relatorio
private dDATA_INI        // define data inicial para impressao
private dDATA_FIM        // define datao final para impressao
private aEDICAO     := {}    // vetor para os campos de entrada de dados
private nTOT        := 0
private nTOT_DIA    := 0
private cCLIENTE    := space(5)
private cCLI_ATU   := space(5)
private nTOT_CLI   := 0
private cSITUA      := space(2)
private cSETOR      := space(5)
fu_abre_cli1()

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qgetx(-1,0,@dDATA_INI                     ) } ,"DATA_INI"  })
aadd(aEDICAO,{{ || qgetx(-1,0,@dDATA_FIM                     ) } ,"DATA_FIM"  })
aadd(aEDICAO,{{ || view_cli(-1,0,@cCLIENTE                   ) } ,"CLIENTE"   })
aadd(aEDICAO,{{ || NIL                                         } , NIL        }) // nome do cliente
aadd(aEDICAO,{{ || view_situa(-1,0,@cSITUA                   ) } ,"SITUA"    })
aadd(aEDICAO,{{ || NIL                                         } , NIL        }) // nome do fornecedor
aadd(aEDICAO,{{ || view_set(-1,0,@cSETOR                     ) } ,"SETOR"     })
aadd(aEDICAO,{{ || NIL                                         } , NIL        }) // nome do cliente

do while .T.

   qlbloc(05,0,"B503A","QBLOC.GLO",1)

   XNIVEL     := 1
   XFLAG      := .T.
   dDATA_INI  := ctod("")
   dDATA_FIN  := ctod("")
   cCLIENTE   := space(5)
   cCLI_ATU   := space(5)
   cSITUA     := space(2)
   cSETOR     := space(5)

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

      case cCAMPO == "CLIENTE"

           qrsay(XNIVEL,strzero(val(cCLIENTE),5))

           if empty(cCLIENTE)
              qrsay(XNIVEL+1, "Todos os Clientes.......")
           else
              if ! CLI1->(Dbseek(cCLIENTE:=strzero(val(cCLIENTE),5)))
                 qmensa("Cliente n„o Cadastrado","B")
                 return .F.
              else
                 qrsay(XNIVEL+1,left(CLI1->Razao,30))
              endif
           endif

      case cCAMPO == "SITUA"

           qrsay(XNIVEL,strzero(val(cSITUA),2))

           if empty(cSITUA)
              qrsay(XNIVEL+1, "Todas as Situa‡”es.......")
           else
              if ! SITUA->(Dbseek(cSITUA:=strzero(val(cSITUA),2)))
                 qmensa("Situa‡„o n„o Cadastrada","B")
                 return .F.
              else
                 qrsay(XNIVEL+1,left(SITUA->Descricao,30))
              endif
           endif
      case cCAMPO == "SETOR"

           qrsay(XNIVEL,cSETOR)

           if empty(cSETOR)
              qrsay(XNIVEL++, "Todos os Setores.......")
           else
              if ! SETOR->(Dbseek(cSETOR:=strzero(val(cSETOR),5)))
                 qmensa("Setor n„o Cadastrado","B")
                 return .F.
              else
                 qrsay(XNIVEL++,left(SETOR->Descricao,30))
              endif
           endif

   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // DEFINE VARIAVEL DE COMPACTACAO ________________________________________

   // CRIA TITULO DO RELATORIO ______________________________________________

   cTITULO := "LISTAGEM DE CONTAS A RECEBER POR CLIENTE"

   RECEB2->(dbsetfilter({||iif(!empty(cCLIENTE),Cod_cli == cCLIENTE,Cod_cli != "00000").and.iif(!empty(cSITUA),Situacao == cSITUA,Situacao!="00").and.iif(!empty(cSETOR),Setor == cSETOR,Setor!="00000") }, 'iif(!empty(cCLIENTE),Cod_cli == cCLIENTE,cod_cli != "00000").and.iif(!empty(cSITUA),Situacao == cSITUA,Situacao!="00").and.iif(!empty(cSETOR),Setor == cSETOR,Setor!="00000")'))
   RECEB2->(dbsetorder(10))  // RAZAO DO CLIENTE
   RECEB2->(dbgotop())


return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impressao

   local nMAXLIN := 55
   local dVENC   := ctod("")

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif
   qmensa("imprimindo...")
   
   nTOT_DIA    := 0
   nTOT        := 0

   do while ! RECEB2->(eof())  .and. qcontprn()  // condicao principal de loop

      if RECEB2->Data_pagto < dDATA_INI .or. RECEB2->Data_pagto > dDATA_FIM
         RECEB2->(Dbskip())
         loop
      endif

      if ! qlineprn() ; exit ; endif

      @ prow(),pcol() say XCOND1

      if XPAGINA == 0 .or. prow() > K_MAX_LIN
         qpageprn()
         qcabecprn(cTITULO,123)
         @ prow()+1, 0 say "VENCIMENTO  FATURA    RECEBIDO   CLIENTE                             PRAZO    VALOR     HISTORICO"
         @ prow()+1, 0 say replicate("-",123)
      endif

      @ prow()+1,00  say dtoc(RECEB2->Data_venc)
      @ prow()  ,12  say left(RECEB2->Fatura,9) ; CLI1->(Dbseek(RECEB2->Cod_cli))
      @ prow()  ,22  say dtoc(RECEB2->Data_pagto)
      @ prow()  ,33  say left(CLI1->Razao,35)
      @ prow()  ,69  say strzero(RECEB2->Data_venc - RECEB2->Data_Emiss , 4)
      @ prow()  ,76  say transform(RECEB2->Valor, "@E 999,999.99")
      @ prow()  ,88  say left(RECEB2->Historico,35)

      nTOT_DIA := nTOT_DIA + RECEB2->Valor
      nTOT := nTOT + RECEB2->Valor
      nTOT_CLI += RECEB2->Valor

      RECEB2->(dbskip())

      if ! RECEB2->(eof()) .and. RECEB2->Data_pagto <> dVENC
         @ prow()+1,0 say XAENFAT + "Total do dia................. " + transform(nTOT_DIA, "@E 999,999.99") + XDENFAT
         nTOT_DIA := 0
         dVENC := RECEB2->Data_pagto
      endif

   enddo

   if nTOT_DIA <> 0
      @ prow()+1,0 say XAENFAT + "Total do dia................. " + transform(nTOT_DIA, "@E 999,999.99") + XDENFAT
      nTOT_DIA := 0
      dVENC := RECEB2->Data_pagto
   endif

   @ prow()+1, 0 say replicate("-",123)
   @ prow()+1,0 say XAENFAT +       "Total Geral............... " + transform(nTOT, "@E 99,999,999.99") + XDENFAT

   qstopprn()

return
