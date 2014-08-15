/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE CONTAS A PAGAR
// OBJETIVO...: LISTAGEM DE CONTAS A PAGAR
// ANALISTA...: Eduardo Borio
// PROGRAMADOR:
// INICIO.....: MARCO DE 1997
// OBS........:
function pg501

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
private cFORN       := space(5)
private cSITUA      := space(2)
private cSETOR      := space(5)
private cFORN_ATU   := space(5)
private nTOT_FORN   := 0

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qgetx(-1,0,@dDATA_INI                     ) } ,"DATA_INI"  })
aadd(aEDICAO,{{ || qgetx(-1,0,@dDATA_FIM                     ) } ,"DATA_FIM"  })
aadd(aEDICAO,{{ || view_forn(-1,0,@cFORN                     ) } ,"FORN"      })
aadd(aEDICAO,{{ || NIL                                         } , NIL        }) // nome do fornecedor
aadd(aEDICAO,{{ || view_situa(-1,0,@cSITUA                   ) } ,"SITUA"    })
aadd(aEDICAO,{{ || NIL                                         } , NIL        }) // nome do fornecedor
aadd(aEDICAO,{{ || view_set(-1,0,@cSETOR                     ) } ,"SETOR"    })
aadd(aEDICAO,{{ || NIL                                         } , NIL        }) // nome do fornecedor

do while .T.

   qlbloc(05,0,"B501A","QBLOC.GLO",1)

   XNIVEL     := 1
   XFLAG      := .T.
   dDATA_INI  := ctod("")
   dDATA_FIN  := ctod("")
   cFORN      := space(5)
   cSITUA     := space(2)
   cSETOR     := space(5)
   cFORN_ATU  := space(5)

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

           qrsay(XNIVEL,strzero(val(cFORN),5))

           if empty(cFORN)
              qrsay(XNIVEL+1, "Todos os Fornecedores.......")
           else
              if ! FORN->(Dbseek(cFORN:=strzero(val(cFORN),5)))
                 qmensa("Fornecedor n„o Cadastrado","B")
                 return .F.
              else
                 qrsay(XNIVEL+1,left(FORN->Razao,30))
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

   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // DEFINE VARIAVEL DE COMPACTACAO ________________________________________

   // CRIA TITULO DO RELATORIO ______________________________________________

   cTITULO := "LISTAGEM DE CONTAS A PAGAR"

   if ! empty(cFORN)
      PAGAR->(dbsetorder(11))  // COD_FORN
      qmensa("")
   else
      PAGAR->(dbsetorder(2))  // DATA_VENC
      qmensa("")
   endif

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impressao

   local nMAXLIN := 65
   local dVENC   := ctod("")

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif
   qmensa("imprimindo...")
   
   nTOT_DIA    := 0
   nTOT        := 0

   if ! empty(cFORN)
      PAGAR->(Dbseek(cFORN))
   else
      PAGAR->(Dbsetorder(2))
      PAGAR->(dbgotop())
   endif

   cFORN_ATU := PAGAR->Cod_forn
   dVENC     := PAGAR->Data_venc

   do while ! PAGAR->(eof())  .and. qcontprn()  // condicao principal de loop

      if PAGAR->Data_venc < dDATA_INI .or. PAGAR->Data_venc > dDATA_FIM
         PAGAR->(Dbskip(1))
         loop
      endif

      if ! empty(cFORN) .and. PAGAR->Cod_forn <> cFORN
         PAGAR->(Dbskip(1))
         loop
      endif

      if ! empty(cSITUA) .and. PAGAR->Situacao <> cSITUA
         PAGAR->(Dbskip())
         loop
      endif

      if ! empty(cSETOR) .and. PAGAR->Setor <> cSETOR
         PAGAR->(Dbskip())
         loop
      endif

      if ! qlineprn() ; exit ; endif

      @ prow(),pcol() say XCOND1

      if XPAGINA == 0 .or. prow() > K_MAX_LIN
         qpageprn()
         qcabecprn(cTITULO,123)
         if ! empty(cFORN)
            @ prow()+1, 0 say "Fornecedor....... " + iif(FORN->(Dbseek(PAGAR->Cod_forn)) , FORN->Razao , )
            @ prow()+1, 0 say "DT. VCTO   DT.EMISS     DOCTO       VALOR    HISTORICO                                                 CENTRO DE CUSTO"
         else
            @ prow()+1, 0 say "DT. VCTO   DT.EMISS     DOCTO       VALOR    FORNECEDOR                                             HISTORICO         "
         endif
         @ prow()+1, 0 say replicate("-",123)
      endif

      @ prow()+1,00  say dtoc(PAGAR->Data_venc)
      @ prow()  ,11  say dtoc(PAGAR->Data_emiss)
      @ prow()  ,22  say left(PAGAR->Fatura,9)
      @ prow()  ,31  say transform(PAGAR->Valor_liq, "@E 99,999,999.99")

      if ! empty(cFORN)
         CCUSTO->(Dbsetorder(4))
         @ prow()  ,45  say left(PAGAR->Historico,36)
         @ prow() ,85 say iif(CCUSTO->(Dbseek(PAGAR->Centro)), left(CCUSTO->Descricao,25) , " " )
      else
         FORN->(Dbseek(PAGAR->Cod_forn))
         @ prow() ,45 say left(FORN->Razao,38)
         @ prow() ,85  say left(PAGAR->Historico,38)
      endif

      nTOT := nTOT + PAGAR->Valor_liq
      nTOT_DIA := nTOT_DIA + PAGAR->Valor_liq
      nTOT_FORN += PAGAR->Valor_liq

      PAGAR->(dbskip())

      if ! PAGAR->(eof()) .and. PAGAR->Data_venc <> dVENC
         @ prow()+1,0 say "Total do dia.................. " + transform(nTOT_DIA, "@E 99,999,999.99")
         @ prow()+1,0 say ""

         nTOT_DIA := 0
         dVENC := PAGAR->Data_venc
      endif

   enddo

   if nTOT_DIA <> 0
      @ prow()+1,0 say "Total do dia.................. " + transform(nTOT_DIA, "@E 99,999,999.99")
      nTOT_DIA := 0
      dVENC := PAGAR->Data_venc
   endif

   @ prow()+1, 0 say replicate("-",123)
   @ prow()+1,0 say   "Total Geral.................. " + transform(nTOT, "@E 99,999,999.99")

   qstopprn(.F.)

return
