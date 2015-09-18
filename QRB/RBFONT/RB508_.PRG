/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE CONTAS A RECEBER
// OBJETIVO...: LISTAGEM DE CONTAS A RECEBER
// ANALISTA...: EDUARDO BORIO
// PROGRAMADOR:
// INICIO.....: OUTUBRO DE 2003
// OBS........:
function rb508

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
private cCLI       := space(5)
private cSETOR      := space(5)
private cSITUA      := space(2)
private cDOC        := space(2)
private cCLI_ATU   := space(5)
private nTOT_FORN   := 0

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qgetx(-1,0,@dDATA_INI                      )} ,"DATA_INI"  })
aadd(aEDICAO,{{ || qgetx(-1,0,@dDATA_FIM                      )} ,"DATA_FIM"  })
aadd(aEDICAO,{{ || view_cli(-1,0,@cCLI                        )} ,"FORN"      })
aadd(aEDICAO,{{ || NIL                                         } , NIL        }) // nome do Cliente
aadd(aEDICAO,{{ || view_situa(-1,0,@cSITUA                    )} ,"SITUA"    })
aadd(aEDICAO,{{ || NIL                                         } , NIL        }) // nome do Cliente
aadd(aEDICAO,{{ || view_set(-1,0,@cSETOR                      )} ,"SETOR"    })
aadd(aEDICAO,{{ || NIL                                         } , NIL        }) // nome do Cliente
aadd(aEDICAO,{{ || view_doc(-1,0,@cDOC                        )} ,"DOC"    })
aadd(aEDICAO,{{ || NIL                                         } , NIL        }) // nome do Cliente



do while .T.

   qlbloc(05,0,"B503A","QBLOC.GLO",1)

   XNIVEL     := 1
   XFLAG      := .T.
   dDATA_INI  := ctod("")
   dDATA_FIN  := ctod("")
   cCLI      := space(5)
   cSETOR      := space(5)
   cSITUA     := space(2)
   cDOC       := space(2)
   cCLI_ATU  := space(5)

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

      case cCAMPO == "FORN"

           qrsay(XNIVEL,strzero(val(cCLI),5))

           if empty(cCLI)
              qrsay(XNIVEL+1, "Todos os Clientes.......")
           else
              if ! CLI1->(Dbseek(cCLI:=strzero(val(cCLI),5)))
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

           qrsay(XNIVEL,strzero(val(cSETOR),2))

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


   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // DEFINE VARIAVEL DE COMPACTACAO ________________________________________

   // CRIA TITULO DO RELATORIO ______________________________________________

   cTITULO := "LISTAGEM DE CONTAS A RECEBER"

   if ! empty(cCLI)
      RECEBER->(dbsetorder(08))  // Cod_cli
      qmensa("")
   else
      RECEBER->(dbsetorder(2))  // DATA_VENC
      qmensa("")
   endif

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

      RECEBER->(dbsetfilter({|| RECEBER->Data_venc >= dDATA_INI .and. RECEBER->Data_venc <= dDATA_FIM .and.  iif(!empty(cCLI), RECEBER->Cod_cli == cCLI,Cod_cli!="00000") }))
      RECEBER->(Dbsetorder(8))
      RECEBER->(dbgotop())

   cCLI_ATU  := RECEBER->Cliente+RECEBER->Cod_cli
   dVENC     := RECEBER->Data_venc

   do while ! RECEBER->(eof())  .and. qcontprn()  // condicao principal de loop

      //if RECEBER->Data_venc < dDATA_INI .or. RECEBER->Data_venc > dDATA_FIM
      //   RECEBER->(Dbskip())
      //   loop
      //endif

      if ! empty(cCLI) .and. RECEBER->Cod_cli <> cCLI
         RECEBER->(Dbskip())
         loop
      endif

      if ! empty(cSITUA) .and. RECEBER->Situacao <> cSITUA
         RECEBER->(Dbskip())
         loop
      endif

      if ! empty(cSETOR) .and. RECEBER->Setor <> cSETOR
         RECEBER->(Dbskip())
         loop
      endif

      if mod(RECEBER->(Recno()),75) == 1
         if ! qlineprn() ; exit ; endif
      endif

      @ prow(),pcol() say XCOND1

      if XPAGINA == 0 .or. prow() > K_MAX_LIN
         qpageprn()
         qcabecprn(cTITULO,123)
         if ! empty(cCLI)
            @ prow()+1, 0 say "Cliente....... " + iif(CLI1->(Dbseek(RECEBER->Cod_cli)) , CLI1->Razao , )
            @ prow()+1, 0 say "DT. VCTO   DT.EMISS     DOCTO       VALOR    HISTORICO                                                 CENTRO DE CUSTO"
         else
            @ prow()+1, 0 say "DT. VCTO   DT.EMISS     DOCTO       VALOR    CLIENTE                                             HISTORICO         "
         endif
         @ prow()+1, 0 say replicate("-",123)
      endif

      @ prow()+1,00  say dtoc(RECEBER->Data_venc)
      @ prow()  ,11  say dtoc(RECEBER->Data_emiss)
      @ prow()  ,22  say left(RECEBER->Fatura,9)
      @ prow()  ,31  say transform(RECEBER->Valor_liq, "@E 99,999,999.99")

      if ! empty(cCLI)
         CCUSTO->(Dbsetorder(4))
         @ prow()  ,45  say strtran(left(RECEBER->Historico,36),'"',"")
         @ prow() ,85 say iif(CCUSTO->(Dbseek(RECEBER->Centro)), left(CCUSTO->Descricao,25) , " " )
      else
         CLI1->(Dbseek(RECEBER->Cod_cli))
         @ prow() ,45 say left(CLI1->Razao,38)
         @ prow() ,85  say strtran(left(RECEBER->Historico,38),'"',"")
      endif

      nTOT := nTOT + RECEBER->Valor_liq
      nTOT_DIA := nTOT_DIA + RECEBER->Valor_liq
      nTOT_FORN += RECEBER->Valor_liq

      RECEBER->(dbskip())

      if ! RECEBER->(eof()) .and. RECEBER->cliente+RECEBER->Cod_cli <> cCLI_ATU
         @ prow()+1,0 say XAENFAT + "Total do Cliente............... " + transform(nTOT_DIA, "@E 99,999,999.99") + XDENFAT
         nTOT_DIA := 0
         cCLI_ATU := RECEBER->Cliente+RECEBER->Cod_cli
      endif

   enddo

   if nTOT_DIA <> 0
      @ prow()+1,0 say XAENFAT + "Total do CLiente................. " + transform(nTOT_DIA, "@E 99,999,999.99") + XDENFAT
      nTOT_DIA := 0
      cCLI_ATU := RECEBER->cliente+RECEBER->Cod_cli
   endif

   @ prow()+1, 0 say replicate("-",123)
   @ prow()+1,0 say XAENFAT +       "Total Geral............... " + transform(nTOT, "@E 99,999,999.99") + XDENFAT

   qstopprn(.F.)

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO (Modelo Excel)

static function i_impre_xls

   local nMAXLIN := 55
   local dVENC   := ctod("")

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   qmensa("imprimindo...")
   
   nTOT_DIA    := 0
   nTOT        := 0

   RECEBER->(dbsetfilter({||RECEBER->Data_venc >= dDATA_INI .and. RECEBER->Data_venc <= dDATA_FIM .and. iif(!empty(cCLI),RECEBER->Cod_cli == cCLI,Cod_cli!="00000") }))
   RECEBER->(Dbsetorder(8))
   RECEBER->(dbgotop())

   cCLI_ATU  := RECEBER->Cliente + RECEBER->Cod_cli
   dVENC     := RECEBER->Data_venc

   do while ! RECEBER->(eof()) // condicao principal de loop

      if ! empty(cCLI) .and. RECEBER->Cod_cli <> cCLI
         RECEBER->(Dbskip())
         loop
      endif

      if mod(RECEBER->(Recno()),150) == 1
         if ! qlineprn() ; exit ; endif
      endif

      @ prow(),pcol() say XCOND1

      if XPAGINA == 0 //.or. prow() > K_MAX_LIN
         qpageprn()
         @ prow()+1,0 say chr(9)+Chr(9)+chr(9)+chr(9)+cTITULO
         if ! empty(cCLI)
            @ prow()+1, 0 say chr(9)+Chr(9)+chr(9)+chr(9)+"Cliente" +chr(9)+ iif(CLI1->(Dbseek(RECEBER->Cod_cli)) , CLI1->Razao , )
            @ prow()+1, 0 say "Vencimento"+chr(9)+"Emissao"+chr(9)+"Documento"+chr(9)+"Valor"+chr(9)+"Historico"+chr(9)+"Centro de Custo"
         else
            @ prow()+1, 0 say "Vencimento"+chr(9)+ "Emissao" +chr(9)+ "Documento"  +chr(9)+ "Valor"  +chr(9)+ "Cliente" +chr(9)+ "Historico"+chr(9)+"Banco"+chr(9)+"Tipo Boleto"+Chr(9)+ "Representante"
         endif
      endif
	  
	  CLI1->(dbseek(RECEBER->cod_cli))
	  REPRES->(dbseek(CLI1->cod_repres))

      @ prow()+1,00  say dtoc(RECEBER->Data_venc)
      @ prow()  ,pcol()  say chr(9)+dtoc(RECEBER->Data_emiss)
      @ prow()  ,pcol()  say chr(9)+left(RECEBER->Fatura,9)
      @ prow()  ,pcol()  say chr(9)+transform(RECEBER->Valor_liq, "@E 99,999,999.99")
	 

      if ! empty(cCLI)
         CCUSTO->(Dbsetorder(4))
         @ prow()  ,pcol()  say chr(9)+ strtran(left(RECEBER->Historico,36),'"','')
         @ prow() ,pcol() say chr(9)+iif(CCUSTO->(Dbseek(RECEBER->Centro)), left(CCUSTO->Descricao,25) , " " )
      else
         CLI1->(Dbseek(RECEBER->Cod_cli))
         @ prow() ,pcol() say chr(9)+left(CLI1->Razao,38)
         @ prow() ,pcol()  say chr(9)+strtran(left(RECEBER->Historico,38),'"','')
		 @ prow()  ,pcol()  say chr(9)+i_mantraBank()
         @ prow()  ,pcol()  say chr(9)+i_mantraBoleto()
	     @ prow()  ,pcol()  say chr(9)+left(REPRES->Razao,25)
      endif

      nTOT := nTOT + RECEBER->Valor_liq
      nTOT_DIA := nTOT_DIA + RECEBER->Valor_liq
      nTOT_FORN += RECEBER->Valor_liq

      RECEBER->(dbskip())

      if ! RECEBER->(eof()) .and. RECEBER->Cliente + RECEBER->Cod_cli <> cCLI_ATU
         @ prow()+1,0 say chr(9)+chr(9) + "Total do Cliente" + chr(9)+ transform(nTOT_DIA, "@E 99,999,999.99")
         @ prow()+1,0 say ""
         nTOT_DIA := 0
         cCLI_ATU := RECEBER->cliente+ RECEBER->Cod_cli
      endif

   enddo

   if nTOT_DIA <> 0
      @ prow()+1,0 say chr(9)+chr(9) + "Total do Cliente" + chr(9)+ transform(nTOT_DIA, "@E 99,999,999.99")
      nTOT_DIA := 0
      cCLI_ATU := RECEBER->Cliente + RECEBER->Cod_cli
   endif

   @ prow()+1,0 say chr(9)+chr(9) + "Total Geral" + chr(9)+ transform(nTOT, "@E 99,999,999.99")

   qstopprn(.F.)

return

static function i_MantraBank
local cRet := "    "
   if BANCO->(dbseek(RECEBER->Cod_Banco))
      cRet := rtrim(BANCO->Banco)

      if cRet == "0356"
         cRET := "REAL"
      endif
	  
	  if cRet == "0033"
         cRET := "SANT"
      endif

      if cRet == "0001"
         cRET := "BB"
      endif

      if cRet == "0341"
         cRET := "ITAU"
      endif

      if cRet == "0399"
         cRET := "HSBC"
      endif
	  
	  if cRet == "0246"
         cRET := "ABC"
      endif

   else
      cRet := "    "
   endif

return cRet

