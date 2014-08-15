/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE CONTAS A RECEBER
// OBJETIVO...: LISTAGEM DE CONTAS A RECEBER POR CLIENTES
// ANALISTA...: EDUARDO BORIO
// PROGRAMADOR: EDUARDO BORIO
// INICIO.....: MARCO DE 1997
// OBS........:
function rb503

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
private cDOC        := space(2)
private cSETOR      := space(5)

fu_abre_cli1()

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qgetx(-1,0,@dDATA_INI                     ) } ,"DATA_INI"  })
aadd(aEDICAO,{{ || qgetx(-1,0,@dDATA_FIM                     ) } ,"DATA_FIM"  })
aadd(aEDICAO,{{ || view_cli(-1,0,@cCLIENTE                   ) } ,"CLIENTE"   })
aadd(aEDICAO,{{ || NIL                                         } , NIL        }) // nome do cliente
aadd(aEDICAO,{{ || view_situa(-1,0,@cSITUA                   ) } ,"SITUA"     })
aadd(aEDICAO,{{ || NIL                                         } , NIL        }) // nome do fornecedor
aadd(aEDICAO,{{ || view_set(-1,0,@cSETOR                     ) } ,"SETOR"     })
aadd(aEDICAO,{{ || NIL                                         } , NIL        }) // nome do cliente
aadd(aEDICAO,{{ || view_doc(-1,0,@cDOC                       ) } ,"DOC"       })
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
   cDOC       := space(2)
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

      case cCAMPO == "DOC"

           qrsay(XNIVEL,strzero(val(cDOC),2))

           if empty(cDOC)
              qrsay(XNIVEL+1, "Todos os Documentos.......")
           else
              if ! TIPO_DOC->(Dbseek(cDOC:=strzero(val(cDOC),2)))
                 qmensa("Tipo de Documento n„o Cadastrado","B")
                 return .F.
              else
                 qrsay(XNIVEL+1,left(TIPO_DOC->Descricao,30))
              endif
           endif

      case cCAMPO == "SETOR"

           qrsay(XNIVEL,cSETOR)

           if empty(cSETOR)
              qrsay(XNIVEL+1, "Todos os Setores.......")
           else
              if ! SETOR->(Dbseek(cSETOR:=strzero(val(cSETOR),5)))
                 qmensa("Setor n„o Cadastrado","B")
                 return .F.
              else
                 qrsay(XNIVEL+1,left(SETOR->Descricao,30))
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

   RECEBER->(dbsetfilter({||iif(!empty(cCLIENTE),Cod_cli == cCLIENTE,Cod_cli != "00000").and.iif(!empty(cSITUA),Situacao == cSITUA,Situacao!="00").and.iif(!empty(cSETOR),Setor == cSETOR,Setor!="00000").and. iif(!empty(cDOC),Tipo_doc == cDOC,Tipo_Doc!="99")  .and. RECEBER->Data_venc >= dDATA_INI .and. RECEBER->Data_venc <= dDATA_FIM }))


   RECEBER->(dbsetorder(10))  // RAZAO DO CLIENTE
   RECEBER->(dbgotop())
   qmensa("")

return .T.

static function i_impressao

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
   local dVENC   := ctod("")

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   qmensa("imprimindo...")
   
   nTOT_DIA    := 0
   nTOT        := 0


   cCLI_ATU := RECEBER->Cod_cli
   dVENC    := RECEBER->Data_venc

   do while ! RECEBER->(eof())  .and. qcontprn()  // condicao principal de loop

      //if RECEBER->Data_venc < dDATA_INI .or. RECEBER->Data_venc > dDATA_FIM
      //   RECEBER->(Dbskip())
      //  loop
      // endif

      if ! qlineprn() ; exit ; endif

      @ prow(),pcol() say XCOND1

      if XPAGINA == 0 .or. prow() > K_MAX_LIN
         qpageprn()
         qcabecprn(cTITULO,123)
         @ prow()+1, 0 say "VENCIMENTO  FATURA    EMISSAO    CLIENTE                             PRAZO    VALOR     HISTORICO"
         @ prow()+1, 0 say replicate("-",123)
      endif

      @ prow()+1,00  say dtoc(RECEBER->Data_venc)
      @ prow()  ,12  say left(RECEBER->Fatura,9) ; CLI1->(Dbseek(RECEBER->Cod_cli))
      @ prow()  ,22  say dtoc(RECEBER->Data_Emiss)
      @ prow()  ,33  say left(CLI1->Razao,35)
      @ prow()  ,69  say strzero(RECEBER->Data_venc - RECEBER->Data_Emiss , 4)
      @ prow()  ,76  say transform(RECEBER->Valor_liq, "@E 999,999.99")
      @ prow()  ,88  say strtran(left(RECEBER->Historico,35),'"','')

      nTOT_DIA := nTOT_DIA + RECEBER->Valor_liq
      nTOT := nTOT + RECEBER->Valor_liq
      nTOT_CLI += RECEBER->Valor_liq

      RECEBER->(dbskip())

      if ! RECEBER->(eof()) .and. RECEBER->Data_venc <> dVENC
         @ prow()+1,0 say XAENFAT + "Total do dia................. " + transform(nTOT_DIA, "@E 999,999.99") + XDENFAT
         nTOT_DIA := 0
         dVENC := RECEBER->Data_venc
      endif

   enddo

   if nTOT_DIA <> 0
      @ prow()+1,0 say XAENFAT + "Total do dia................. " + transform(nTOT_DIA, "@E 999,999.99") + XDENFAT
      nTOT_DIA := 0
      dVENC := RECEBER->Data_venc
   endif

   @ prow()+1, 0 say replicate("-",123)
   @ prow()+1,0 say XAENFAT +       "Total Geral............... " + transform(nTOT, "@E 99,999,999.99") + XDENFAT

   qstopprn()

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO (formato Excel)

static function i_impre_xls

   local nMAXLIN := 55
   local dVENC   := ctod("")

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   qmensa("imprimindo...")
   
   nTOT_DIA    := 0
   nTOT        := 0


   cCLI_ATU := RECEBER->Cod_cli
   dVENC    := RECEBER->Data_venc

   do while ! RECEBER->(eof())  .and. qcontprn()  // condicao principal de loop

     // if RECEBER->Data_venc < dDATA_INI .or. RECEBER->Data_venc > dDATA_FIM
     //    RECEBER->(Dbskip())
     //    loop
     // endif

      if ! qlineprn() ; exit ; endif

      @ prow(),pcol() say XCOND1

      if XPAGINA == 0 .or. prow() > K_MAX_LIN
         qpageprn()
         @ prow()+1, 0 say chr(9)+chr(9)+chr(9)+cTITULO + " 503"
         @ prow()+1, 0 say "Vencimento"+Chr(9)+"Fatura"+chr(9)+"Emissao"+Chr(9)+"Cliente"+chr(9)+"Prazo"+chr(9)+"Valor"+Chr(9)+"Historico"
      endif

      @ prow()+1,00  say dtoc(RECEBER->Data_venc)
      @ prow()  ,pcol()  say chr(9)+left(RECEBER->Fatura,9) ; CLI1->(Dbseek(RECEBER->Cod_cli))
      @ prow()  ,pcol()  say chr(9)+dtoc(RECEBER->Data_Emiss)
      @ prow()  ,pcol()  say chr(9)+left(CLI1->Razao,35)
      @ prow()  ,pcol()  say chr(9)+strzero(RECEBER->Data_venc - RECEBER->Data_Emiss , 3)
      @ prow()  ,pcol()  say chr(9)+transform(RECEBER->Valor_liq, "@E 999,999.99")
      @ prow()  ,pcol()  say chr(9)+strtran(left(RECEBER->Historico,35),'"','')

      nTOT_DIA := nTOT_DIA + RECEBER->Valor_liq
      nTOT := nTOT + RECEBER->Valor_liq
      nTOT_CLI += RECEBER->Valor_liq

      RECEBER->(dbskip())

      if ! RECEBER->(eof()) .and. RECEBER->Data_venc <> dVENC
         @ prow()+1,0 say chr(9)+chr(9)+chr(9)+chr(9)+ "Total do dia" +chr(9)+ transform(nTOT_DIA, "@E 999,999.99")
         @ prow()+1, 0 say ""

         nTOT_DIA := 0
         dVENC := RECEBER->Data_venc
      endif

   enddo

   if nTOT_DIA <> 0
      @ prow()+1,0 say chr(9)+chr(9)+chr(9)+chr(9)+ "Total do dia" +chr(9)+ transform(nTOT_DIA, "@E 999,999.99")
      nTOT_DIA := 0
      dVENC := RECEBER->Data_venc
   endif

   @ prow()+1,0 say chr(9)+chr(9)+chr(9)+chr(9)+ "Total Geral" +chr(9)+ transform(nTOT, "@E 9,999,999.99")


   qstopprn()

return

