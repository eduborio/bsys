/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE CONTAS A RECEBER
// OBJETIVO...: LISTAGEM DE CONTAS A RECEBER POR CLIENTES
// ANALISTA...: EDUARDO BORIO
// PROGRAMADOR: EDUARDO BORIO
// INICIO.....: MARCO DE 1997
// OBS........:
function rb509

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

//fu_abre_cli1()

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
   SETOR->(dbseek(cSETOR))
   cTITULO := "LISTAGEM DE CONTAS A RECEBER - " + iif(empty(cSETOR),"TODOS SETORES",SETOR->Descricao)

   //RECEBER->(dbsetfilter({||iif(!empty(cCLIENTE),Cod_cli == cCLIENTE,Cod_cli != "00000").and.iif(!empty(cSITUA),Situacao == cSITUA,Situacao!="00").and.iif(!empty(cSETOR),Setor == cSETOR,Setor!="00000").and. RECEBER->Data_emiss >= dDATA_INI.and. RECEBER->Data_Emiss <= dDATA_FIM  }))
   //RECEBIDO->(dbsetfilter({||iif(!empty(cCLIENTE),Cod_cli == cCLIENTE,Cod_cli != "00000").and.iif(!empty(cSITUA),Situacao == cSITUA,Situacao!="00").and.iif(!empty(cSETOR),Setor == cSETOR,Setor!="00000").and. RECEBIDO->Data_Emiss >= dDATA_INI .and. RECEBIDO->Data_Emiss <= dDATA_FIM }))

   RECEBER->(dbsetfilter({||iif(!empty(cCLIENTE),Cod_cli == cCLIENTE,Cod_cli != "00000").and.iif(!empty(cSITUA),Situacao == cSITUA,Situacao!="00").and.iif(!empty(cSETOR),Setor == cSETOR,Setor!="00000").and. RECEBER->Data_emiss <= dDATA_FIM  }))
   RECEBIDO->(dbsetfilter({||iif(!empty(cCLIENTE),Cod_cli == cCLIENTE,Cod_cli != "00000").and.iif(!empty(cSITUA),Situacao == cSITUA,Situacao!="00").and.iif(!empty(cSETOR),Setor == cSETOR,Setor!="00000").and. RECEBIDO->Data_emiss <= dDATA_FIM .and. RECEBIDO->Data_pagto > dDATA_FIM  }))



  // RECEBER->(dbsetorder(10))  // RAZAO DO CLIENTE
  // RECEBER->(dbgotop())
   qmensa("")

return .T.

static function i_impressao

   if ! Quse(XDRV_RB,"FI509A",{"FI509A"},"E")
      qmensa("Nao foi possivel abrir Arquivo temporario... Tente Novamente!","BL")
      return .f.
   endif

   FI509A->(__dbzap())

   if ! qinitprn() ; return  ; endif

   if XLOCALIMP == "X"
      i_impre_xls()
   else
      i_impre_prn()
   endif

return


/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impre_prn

   local nMAXLIN := 55
   local lTEM := .F.
   local dVENC   := ctod("")
   local aREC := {}   //Array de Contas a Receber e Recebidas
   local asREC := {}  //Array indexada de cntas a Receber e Recebidas

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   qmensa("imprimindo...")
   
   nTOT_DIA    := 0
   nTOT        := 0
   nCONT       := 0


   //cCLI_ATU := RECEBER->Cod_cli
   //dVENC    := RECEBER->Data_venc
   RECEBER->(Dbgotop())
   Do While ! RECEBER->(Eof())
      //aadd(aREC,{RECEBER->Data_emiss,left(RECEBER->Fatura,9),RECEBER->Cod_cli,RECEBER->Data_venc,strzero(RECEBER->Data_venc - RECEBER->Data_emiss,4),RECEBER->Valor_liq,left(RECEBER->HIstorico,35) })
      if FI509A->(qappend())
         replace  FI509A->Data_emiss with RECEBER->Data_emiss
         replace  FI509A->Fatura     with left(RECEBER->Fatura,9)
         replace  FI509A->Cod_cli    with RECEBER->Cod_cli
         replace  FI509A->Data_venc  with RECEBER->Data_venc
         replace  FI509A->Dias       with strzero(RECEBER->Data_venc - RECEBER->Data_emiss,4)
         replace  FI509A->Valor_liq  with RECEBER->valor_liq
         replace  FI509A->Historico  with left(RECEBER->Historico,35)
      endif
      lTEM := .T.
      RECEBER->(Dbskip())
   enddo

   RECEBIDO->(Dbgotop())
   Do While ! RECEBIDO->(Eof())
     // aadd(aREC,{RECEBIDO->Data_Emiss,left(RECEBIDO->Fatura,9),RECEBIDO->Cod_cli,RECEBIDO->Data_venc,strzero(RECEBIDO->Data_venc - RECEBIDO->Data_emiss,4),RECEBIDO->Valor_liq,left(RECEBIDO->HIstorico,35) })
      if FI509A->(qappend())
         replace  FI509A->Data_emiss with RECEBIDO->Data_emiss
         replace  FI509A->Fatura     with left(RECEBIDO->Fatura,9)
         replace  FI509A->Cod_cli    with RECEBIDO->Cod_cli
         replace  FI509A->Data_venc  with RECEBIDO->Data_venc
         replace  FI509A->Dias       with strzero(RECEBIDO->Data_venc - RECEBIDO->Data_emiss,4)
         replace  FI509A->Valor_liq  with RECEBIDO->valor_liq
         replace  FI509A->Historico  with left(RECEBIDO->Historico,35)
      endif

      lTEM := .T.
      RECEBIDO->(Dbskip())
   enddo

   FI509A->(dbcommit())
   FI509A->(dbgotop())

   //asREC := asort(aREC,,,{|x,y| x[1] < y[1] })

   if lTEM
   dVENC    := FI509A->Data_emiss
   nCONT := 1
   do while ! FI509A->(eof())

      if ! qlineprn() ; exit ; endif

      @ prow(),pcol() say XCOND1

      if XPAGINA == 0 .or. prow() > K_MAX_LIN
         qpageprn()
         qcabecprn(cTITULO,123)
         @ prow()+1, 0 say "EMISSAO     FATURA    VENCIM.    CLIENTE                             PRAZO    VALOR     HISTORICO"
         @ prow()+1, 0 say replicate("-",123)
      endif

      @ prow()+1,00  say dtoc(FI509A->Data_emiss)
      @ prow()  ,12  say FI509A->Fatura ; CLI1->(Dbseek(FI509A->Cod_cli))
      @ prow()  ,22  say dtoc(FI509A->Data_venc)
      @ prow()  ,33  say left(CLI1->Razao,35)
      @ prow()  ,69  say FI509A->Dias
      @ prow()  ,76  say transform(FI509A->Valor_liq, "@E 999,999.99")
      @ prow()  ,88  say FI509A->Historico

      nTOT_DIA := nTOT_DIA + FI509A->Valor_liq
      nTOT := nTOT + FI509A->Valor_liq
      nTOT_CLI += FI509A->Valor_liq

      FI509A->(dbskip())

      if FI509A->Data_emiss <> dVENC
         @ prow()+1,0 say XAENFAT + "Total do dia................. " + transform(nTOT_DIA, "@E 999,999.99") + XDENFAT
         nTOT_DIA := 0
         dVENC := FI509A->Data_emiss
      endif

   enddo

   if nTOT_DIA <> 0
      @ prow()+1,0 say XAENFAT + "Total do dia................. " + transform(nTOT_DIA, "@E 999,999.99") + XDENFAT
      nTOT_DIA := 0
      dVENC := FI509A->Data_emiss
   endif

   @ prow()+1, 0 say replicate("-",123)
   @ prow()+1,0 say XAENFAT +       "Total Geral............... " + transform(nTOT, "@E 99,999,999.99") + XDENFAT

   qstopprn()
   endif
   RECEBER->(Dbclearfilter())
   RECEBIDO->(Dbclearfilter())

   FI509A->(__dbzap())
   FI509A->(dbclosearea())

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO (formato Excel)

static function i_impre_xls
   local nMAXLIN := 55
   local lTEM := .F.
   local dVENC   := ctod("")
   local aREC := {}   //Array de Contas a Receber e Recebidas
   local asREC := {}  //Array indexada de cntas a Receber e Recebidas

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   qmensa("imprimindo...")
   
   nTOT_DIA    := 0
   nTOT        := 0
   nCONT       := 0


   //cCLI_ATU := RECEBER->Cod_cli
   //dVENC    := RECEBER->Data_venc
   RECEBER->(Dbgotop())
   Do While ! RECEBER->(Eof())
      //aadd(aREC,{RECEBER->Data_Emiss,left(RECEBER->Fatura,9),RECEBER->Cod_cli,RECEBER->Data_venc,strzero(RECEBER->Data_venc - RECEBER->Data_emiss,4),RECEBER->Valor_liq,left(RECEBER->HIstorico,35) })
      if FI509A->(qappend())
         replace  FI509A->Data_emiss with RECEBER->Data_emiss
         replace  FI509A->Fatura     with left(RECEBER->Fatura,9)
         replace  FI509A->Cod_cli    with RECEBER->Cod_cli
         replace  FI509A->Data_venc  with RECEBER->Data_venc
         replace  FI509A->Dias       with strzero(RECEBER->Data_venc - RECEBER->Data_emiss,4)
         replace  FI509A->Valor_liq  with RECEBER->valor_liq
         replace  FI509A->Historico  with left(RECEBER->Historico,35)
      endif

      lTEM := .T.
      RECEBER->(Dbskip())
   enddo

   RECEBIDO->(Dbgotop())
   Do While ! RECEBIDO->(Eof())
      //aadd(aREC,{RECEBIDO->Data_Emiss,left(RECEBIDO->Fatura,9),RECEBIDO->Cod_cli,RECEBIDO->Data_venc,strzero(RECEBIDO->Data_venc - RECEBIDO->Data_emiss,4),RECEBIDO->Valor_liq,left(RECEBIDO->HIstorico,35) })
      if FI509A->(qappend())
         replace  FI509A->Data_emiss with RECEBIDO->Data_emiss
         replace  FI509A->Fatura     with left(RECEBIDO->Fatura,9)
         replace  FI509A->Cod_cli    with RECEBIDO->Cod_cli
         replace  FI509A->Data_venc  with RECEBIDO->Data_venc
         replace  FI509A->Dias       with strzero(RECEBIDO->Data_venc - RECEBIDO->Data_emiss,4)
         replace  FI509A->Valor_liq  with RECEBIDO->valor_liq
         replace  FI509A->Historico  with left(RECEBIDO->Historico,35)
      endif

      lTEM := .T.
      RECEBIDO->(Dbskip())
   enddo

   FI509A->(dbcommit())
   FI509A->(dbgotop())

   //asREC := asort(aREC,,,{|x,y| x[1] < y[1] })

   if lTEM
   dVENC    := FI509A->Data_emiss
   nCONT := 1
   do while ! FI509A->(eof())

      if ! qlineprn() ; exit ; endif

      //@ prow(),pcol() say XCOND1

      if XPAGINA == 0 //.or. prow() > K_MAX_LIN
         qpageprn()
         @ prow()+1, 0 say chr(9)+chr(9)+chr(9)+cTITULO
         @ prow()+1, 0 say "EMISSAO"+chr(9)+"FATURA"+chr(9)+"VENCIMENTO"+chr(9)+"CLIENTE"+chr(9)+"PRAZO"+chr(9)+"VALOR"+chr(9)+"HISTORICO"
         @ prow()+1, 0 say ""
      endif

      @ prow()+1,00  say dtoc(FI509A->Data_emiss)+chr(9)
      @ prow()  ,pcol()  say FI509A->Fatura+chr(9) ; CLI1->(Dbseek(FI509A->Cod_cli))
      @ prow()  ,pcol()  say " "+dtoc(FI509A->data_venc)+chr(9)
      @ prow()  ,pcol()  say left(CLI1->Razao,35)+chr(9)
      @ prow()  ,pcol()  say FI509A->Dias+chr(9)
      @ prow()  ,pcol()  say transform(FI509A->Valor_liq, "@E 999,999.99")+chr(9)
      @ prow()  ,pcol()  say FI509A->Historico

      nTOT_DIA := nTOT_DIA + FI509A->Valor_liq
      nTOT := nTOT + FI509A->Valor_liq
      nTOT_CLI += FI509A->Valor_liq

      FI509A->(dbskip())

      if FI509A->data_emiss <> dVENC
         @ prow()+1,0 say chr(9)+chr(9)+chr(9)+"Total do dia" +chr(9)+chr(9)+ transform(nTOT_DIA, "@E 999,999.99")
         nTOT_DIA := 0
         dVENC := FI509A->Data_emiss
      endif

   enddo

   if nTOT_DIA <> 0
      @ prow()+1,0 say chr(9)+chr(9)+chr(9)+"Total do dia" +chr(9)+chr(9)+ transform(nTOT_DIA, "@E 999,999.99")
      nTOT_DIA := 0
      dVENC := FI509A->Data_emiss
   endif

   @ prow()+1, 0 say ""
   @ prow()+1,0 say chr(9)+chr(9)+chr(9)+"Total Geral" +chr(9)+chr(9)+ transform(nTOT, "@E 999,999.99")


   qstopprn()
   endif
   RECEBER->(Dbclearfilter())
   RECEBIDO->(Dbclearfilter())

   FI509A->(__dbzap())
   FI509A->(dbclosearea())


return

