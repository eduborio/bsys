
/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: FOLHA DE PAGAMENTO
// OBJETIVO...: LANCAMENTOS EM LOTE PARA OS FUNCIONARIOS
// ANALISTA...: CARLOS EDUARDO RABELLO NUNES
// PROGRAMADOR: IDEM
// INICIO.....: JUNHO DE 1994
// OBS........:
// ALTERACOES.:

SITUA->(dbSetFilter({|| Anomes == XANOMES},"Anomes == XANOMES"))

private cAMBIENTE := rh_escolhe_amb() // "MS","AD","DT","FR","PV"
private cANOMES   := qanomes(XDATASYS)
private cFIXA := "N"

if empty(cAMBIENTE) ; return ; endif
if Lastkey() == 27; Return; Endif

i_inic_203()

return

// FUNCAO PARA INICIALIZACAO E ENTRADA DE DADOS _____________________________

static function i_inic_203
   local cEVENTO

   // LOOP PARA EVENTOS _____________________________________________________

   do while .T.
      if Lastkey() == 27
         Keyboard chr(32)
         private cAMBIENTE := rh_escolhe_amb() // "MS","AD","DT","FR","PV"
         private cANOMES   := qanomes(XDATASYS)
         private cFIXA := "N"

         if empty(cAMBIENTE) ; return ; endif
         if Lastkey() ==27; return; endif
         i_inic_203()
      Endif

      qlbloc(5,0,"B203A","QBLOC.GLO")
      qsay(07,04,cAMBIENTE)
      cEVENTO := "   "

      view_event(7,17,@cEVENTO)
      if val(cEVENTO) == 0 ; exit ; endif
      qsay(7,17,cEVENTO:=strzero(val(cEVENTO),3))

      if EVENT->(dbseek(cEVENTO))
         qsay(07,23,EVENT->Descricao)
         qesco(07,73,@cFIXA,XSN)
         iif(empty(cFIXA),cFIXA:="N",)
         qsay(07,73,qabrev(cFIXA,"SN",{"SIM","NŽO"}))
         i_lanca_eventos()
         loop
      endif

      qmensa("Evento n„o cadastrado !","B")

   enddo
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA LANCAR OS EVENTOS PARA VARIOS FUNCIONARIOS ___________________

static function i_lanca_eventos
   local cPICT, cMATRICULA, nVALOR, nSOMAMAT := nSOMAVAL := 0

   do case
      case EVENT->Tipo == "3"
           cPICT := "@E 999,999.99"
           qmensa("Lan‡amento de VALOR...")
      case EVENT->Tipo == "4"
           cPICT := "@E       999.9999"
           qmensa("Lan‡amento de FRA€ŽO...")
   endcase

   do while .T.
      cMATRICULA := "      "
      nVALOR     := 0

      view_fun(18,06,@cMATRICULA)
      if val(cMATRICULA) == 0 ; exit ; endif
      qsay(18,06,cMATRICULA := strzero(val(cMATRICULA),6))

      if ! FUN->(dbseek(cMATRICULA))
         qmensa("Funcionario n„o encontrado !","B") ; loop
      endif

      if ! SITUA->(dbseek(cMATRICULA))
         qmensa("Sem registro no arquivo SITUA !","B") ; loop
      endif

      if FUN->Situacao == "H"
         qmensa("Funcionario Homologado !","B") ; loop
      endif

      if cAMBIENTE $ SITUA->Trav
         qmensa("Funcionario Travado !","B") ; loop
      endif

      if cAMBIENTE $ SITUA->Bloq
         qmensa("Funcionario Bloqueado !","B") ; loop
      endif

      if FUN->Data_Adm > qfimmes(XDATASYS)
         qmensa("Funcionario admitido em mes posterior !","B") ; loop
      endif
      
      qsay(18,15,left(FUN->Nome,30))

      if EVENT->Tipo $ "34"
         qgetx(18,59,@nVALOR,cPICT,NIL,.T.)
      endif

      if LANC->(dbseek(cANOMES+cMATRICULA+cAMBIENTE+EVENT->Evento))
         C_TMP := LANC->(qrlock())
      else
         C_TMP := LANC->(qappend())
      endif

      if C_TMP
         replace LANC->Anomes    with cANOMES
         replace LANC->Matricula with cMATRICULA
         replace LANC->Ambiente  with cAMBIENTE
         replace LANC->Evento    with EVENT->Evento
         replace LANC->Fixa      with iif(cFIXA=="S",.T.,.F.)
         do case
            case EVENT->Tipo == "3" ; LANC->Valor  := nVALOR
            case EVENT->Tipo == "4" ; LANC->Fracao := nVALOR
         endcase
         LANC->(qunlock())
      else
         qm1()
         loop
      endif

      scrol_sl(10,06,18,73,1,"S")
      qsay(18,13,"³")
      qsay(18,56,"³")

      nSOMAMAT += val(cMATRICULA)
      nSOMAVAL += nVALOR

      qsay(20,05,str(nSOMAMAT,7))
      if EVENT->Tipo $ "34"
         qsay(20,59,transform(nSOMAVAL,cPICT))
      endif

   enddo

return NIL

