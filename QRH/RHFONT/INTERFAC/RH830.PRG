
/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: FOLHA DE PAGAMENTO
// OBJETIVO...: CONFIGURACAO DA INTERFACE COM A CONTABILIDADE
// ANALISTA...: CARLOS EDUARDO RABELLO NUNES
// PROGRAMADOR: O MESMO
// INICIO.....: SETEMBRO DE 1996
// OBS........:
// ALTERACOES.:

/////////////////////////////////////////////////////////////////////////////
// ABRE ARQUIVO ART_SALD.DBF DA INTERQUADRAM _____________________________

// fu_abre_plan()

/////////////////////////////////////////////////////////////////////////////
// MANUTENCAO DE CENTRO DE CUSTOS ___________________________________________

EVCONT->(qview({{"Evento/Evento"               ,1},;
                {"f830a()/Descri‡„o"           ,0},;
                {"ct_convcod(Contad)/Cta.Deb." ,0},;
                {"ct_convcod(Contac)/Cta.Cred.",0}},"P",;
                {NIL,"c830a",NIL,NIL},;
                 NIL,"ESC/ALT-P/ <I>nc. <A>lt. <C>on. <E>xc. Im<P>orta"))
return

/////////////////////////////////////////////////////////////////////////////
// BUSCA E PLOTA DESCRICAO DO EVENTO ________________________________________

function f830a
   EVENT->(dbseek(EVCONT->Evento))
return(left(EVENT->Descricao,30))

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function c830a
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))
   if cOPCAO == "P"
      i_importa()
   endif
   if cOPCAO $ XUSRA
      qlbloc(10,06,"B830A","QBLOC.GLO",1)
      qmensa(qabrev(cOPCAO,"IA",{"Inclus„o...","Altera‡„o..."}))
      i_edicao()
   endif
   setcursor(nCURSOR)
   select EVCONT
return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IMPORTACAO DE CONFIGURACAO DE OUTRA EMPRESA __________________

static function i_importa
   local bESCAPE := {||empty(cEMPRESA).or.(XNIVEL==1.and.!XFLAG)}

   private cCAMINHO1             // diretorio atual
   private cCAMINHO2             // diretorio importado
   private aEDICAO  := {}        // vetor para os campos
   private cEMPRESA := space(3)  // empresa cedente do plano
   private lCONF                 // flag de confirmacao
   private cEMPFILT              // string auxiliar para filtro

  // ABRE ARQUIVO QINST.DBF (CONTROLE DE EMPRESAS) E FILTRA _________________

   quse(XDRV_SH,"QINST",{"QINST1","QINST2"},"R")

   cEMPFILT := "000-" + XEMPRESA

   QINST->(dbSetFilter({|| ! Empresa $ cEMPFILT}, '! Empresa $ cEMPFILT'))

   // CRIACAO DO VETOR DE BLOCOS ____________________________________________

   aadd(aEDICAO,{{ || view_qinst(-1,0,@cEMPRESA )},"EMPRESA"  })
   aadd(aEDICAO,{{ || lCONF := qconf("Confirma importa‡„o ?" )},NIL })

   qlbloc(5,0,"B830B","QBLOC.GLO")
   
   qmensa()
   cEMPRESA := space(3)
   XNIVEL   := 1
   XFLAG    := .T.

   // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; QINST->(dbclosearea()) ; select EVCONT ; return ; endif
      if ! i_critica2( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   cCAMINHO1 := alltrim(XDRV_RH)
   cCAMINHO2 := alltrim(QINST->Drv_rh)

   if ! lCONF ; return .F. ; endif

   qmensa("Copiando arquivos. Aguarde...")

   copy file &(cCAMINHO1+"EVCONT.DBF")   to &(cCAMINHO1+"EVCONT.OLD")

   EVCONT->(dbclosearea())

   copy file &(cCAMINHO2+"EVCONT.DBF")   to &(cCAMINHO1+"EVCONT.DBF")
   copy file &(cCAMINHO2+"CO_EVENT.NTX") to &(cCAMINHO1+"CO_EVENT.NTX")

   quse(XDRV_RH,"EVCONT",{"CO_EVENT"})

   QINST->(dbclosearea())

return .T.

/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA _____________________________________________

static function i_critica2 ( cCAMPO )
   do case
      case cCAMPO == "EMPRESA"
           if QINST->(dbseek(cEMPRESA:=strzero(val(cEMPRESA),3)))
              qrsay(XNIVEL,cEMPRESA)
              qrsay(XNIVEL+1,left(QINST->Razao,40))
           else
              qmensa("Empresa n„o cadastrada !","B")
              return .F.
           endif
   endcase
return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA ____________________________________

static function i_edicao
   local lCONF
   local aEDICAO := {}
   local bESCAPE := {||empty(fEVENTO).or.(XNIVEL==1.and.!XFLAG)}

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"
      XNIVEL := 1
      qrsay(XNIVEL++,EVCONT->Evento) ; EVENT->(dbseek(EVCONT->Evento))
      qrsay(XNIVEL++,EVENT->Descricao)
      qrsay(XNIVEL++,transform(EVCONT->Contad,"@R 9.99.99.99.9999-9")) ; PLAN->(dbseek(EVCONT->Contad)) // MUDEI NO DIA 14/05/97, ESTAVA ASSIM 9.99.99.99.9999
      qrsay(XNIVEL++,left(PLAN->Descricao,35)) // MUDEI NO DIA 14/05/97, ESTAV ASSIM PLAN->Nome
      qrsay(XNIVEL++,transform(EVCONT->Contac,"@R 9.99.99.99.9999-9")) ; PLAN->(dbseek(EVCONT->Contac)) // MUDEI NO DIA 14/05/97, ESTAVA ASSIM 9.99.99.99.9999
      qrsay(XNIVEL++,left(PLAN->Descricao,35))  // MUDEI NO DIA 14/05/97, ESTAV ASSIM PLAN->Nome
   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{|| view_event(-1,0,@fEVENTO )},"EVENTO"})
   aadd(aEDICAO,{{|| NIL },NIL}) // descricao do evento
   aadd(aEDICAO,{{|| view_pliq(-1,0,@fContad  )},"CONTAD" })
   aadd(aEDICAO,{{|| NIL },NIL}) // descricao da conta debito
   aadd(aEDICAO,{{|| view_pliq(-1,0,@fContac  )},"CONTAC" })
   aadd(aEDICAO,{{|| NIL },NIL}) // descricao da conta credito
   aadd(aEDICAO,{{|| lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // continua em loop se for inclusao ______________________________________

   do while .T.

   // INICIALIZACAO DA EDICAO _______________________________________________

   if cOPCAO == "I" ; qlbloc(10,6,"B830A","QBLOC.GLO",1) ; endif

   // INICIALIZACAO DA EDICAO _______________________________________________

   EVCONT->(qpublicfields())
   iif(cOPCAO=="I",EVCONT->(qinitfields()),EVCONT->(qcopyfields()))
   XNIVEL := 1
   XFLAG  := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; EVCONT->(qreleasefields()) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif

   if EVCONT->(iif(cOPCAO=="I",qappend(),qrlock()))
      EVCONT->(qreplacefields())
      EVCONT->(qunlock())
   else
      iif(cOPCAO=="I",qm1(),qm2())
   endif

   if cOPCAO <> "I"
      return
   endif

   enddo

return

/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA _____________________________________________

static function i_critica ( cCAMPO )
   do case
      case cCAMPO == "EVENTO" .and. cOPCAO == "I"
           fEVENTO := strzero(val(fEVENTO),3)
           if ! EVENT->(dbseek(fEVENTO))
              qmensa("Evento n„o cadastrado !","B")
              return .F.
           endif
           if EVCONT->(dbseek(fEVENTO))
              qmensa("Evento j  incluido !","B")
              return .F.
           endif
           qrsay(XNIVEL+1,EVENT->Descricao)
      case cCAMPO == "CONTAD"
           if empty(fCONTAD)
              qrsay(XNIVEL  ,space(15))
              qrsay(XNIVEL+1,space(35))
           else
              qrsay(XNIVEL,fCONTAD,"@R 9.99.99.99.9999-9") // MUDEI NO DIA 14/05/97, ESTAVA ASSIM 9.99.99.99.9999
              if ! PLAN->(dbseek(fCONTAD))
                 qmensa("Conta d‚bito n„o encontrada !","B")
                 return .F.
              endif
              qrsay(XNIVEL+1,left(PLAN->Descricao,35)) // MUDEI NO DIA 14/05/97, ESTAV ASSIM PLAN->Nome
           endif
      case cCAMPO == "CONTAC"
           if empty(fCONTAC)
              qrsay(XNIVEL  ,space(15))
              qrsay(XNIVEL+1,space(35))
           else
              qrsay(XNIVEL,fCONTAC,"@R 9.99.99.99.9999-9") // MUDEI NO DIA 14/05/97, ESTAVA ASSIM 9.99.99.99.9999
              if ! PLAN->(dbseek(fCONTAC))
                 qmensa("Conta cr‚dito n„o encontrada !","B")
                 return .F.
              endif
              qrsay(XNIVEL+1,left(PLAN->Descricao,35))  // MUDEI NO DIA 14/05/97, ESTAV ASSIM PLAN->Nome
           endif
   endcase
return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXCLUIR EVENTO DO EVCONT.DBF _________________________________

function i_exclusao
   if ! qconf("Confirma exclus„o ?")
      return
   endif

   if EVCONT->(qrlock())
      EVCONT->(dbdelete())
      EVCONT->(dbunlock())
   else
      qm3()
   endif

   dbunlockall()
   dbcommitall()

return NIL

