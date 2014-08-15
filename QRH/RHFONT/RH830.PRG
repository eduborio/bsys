/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: FOLHA DE PAGAMENTO
// OBJETIVO...: CONFIGURACAO DA INTERFACE COM A CONTABILIDADE
// ANALISTA...: LUCINEIDE VILAR POSSEBOM WIECZORKOVSKI
// PROGRAMADOR: A MESMA
// INICIO.....: SETEMBRO DE 1996
// OBS........:
// ALTERACOES.:

PLAN->(dbsetorder(3)) // codigo reduzido
CCUSTO->(dbsetorder(1))

/////////////////////////////////////////////////////////////////////////////
// MANUTENCAO DE CENTRO DE CUSTOS ___________________________________________

EVCONT->(qview({{"Evento/Evento"                             ,1},;
                {"f830a()/Descri‡„o"                         ,0},;
                {"ct_convcod(Cont_db)/D‚bito"                ,0},;
                {"ct_convcod(Cont_cr)/Cr‚dito"               ,0},;
                {"transform(CCusto,'@R 99.99.9999')/Centro"  ,0}},"P",;
                {NIL,"c830a",NIL,NIL},;
                 NIL,"ESC/ALT-P/ <I>nc. <A>lt. <C>on. <E>xc. Im<P>orta"))
return

/////////////////////////////////////////////////////////////////////////////
// BUSCA E PLOTA DESCRICAO DO EVENTO ________________________________________

function f830a
   EVENT->(dbseek(EVCONT->Evento))
return(left(EVENT->Descricao,42))

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
      qmensa(qabrev(cOPCAO,"IA",{"Inclus„o... <ESC - Cancela>","Altera‡„o... <ESC - Cancela>"}))
      i_edicao()
   endif
   setcursor(nCURSOR)
   select EVCONT
return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IMPORTACAO DE CONFIGURACAO DE OUTRA EMPRESA __________________

static function i_importa
   local bESCAPE := {||empty(cEMPRESA).or.(XNIVEL==1.and.!XFLAG .or. !empty(cEMPRESA) .and. XNIVEL==1 .and.lastkey()==27)}

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
      qrsay(XNIVEL++,transform(EVCONT->Cont_db,"@R 99999-9")) ; PLAN->(dbseek(EVCONT->Cont_db))
      qrsay(XNIVEL++,left(PLAN->Descricao,35))
      qrsay(XNIVEL++,transform(EVCONT->Cont_cr,"@R 99999-9")) ; PLAN->(dbseek(EVCONT->Cont_cr))
      qrsay(XNIVEL++,left(PLAN->Descricao,35))
      qrsay(XNIVEL++,transform(EVCONT->Ccusto,"@R 99.99.9999")) ; CCUSTO->(dbseek(EVCONT->Ccusto))
      qrsay(XNIVEL++,left(CCUSTO->Descricao,35))
   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{|| view_event(-1,0,@fEVENTO )},"EVENTO"})
   aadd(aEDICAO,{{|| NIL },NIL}) // descricao do evento
   aadd(aEDICAO,{{|| view_pliq(-1,0,@fCont_db  )},"CONT_DB" })
   aadd(aEDICAO,{{|| NIL },NIL}) // descricao da conta debito
   aadd(aEDICAO,{{|| view_pliq(-1,0,@fCont_cr  )},"CONT_CR" })
   aadd(aEDICAO,{{|| NIL },NIL}) // descricao da conta credito
   aadd(aEDICAO,{{|| view_ccusto(-1,0,@fCcusto )},"CCUSTO"  })
   aadd(aEDICAO,{{|| NIL },NIL}) // descricao do centro de custo

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
           qrsay(XNIVEL+1,EVENT->Descricao)
      case cCAMPO == "CONT_DB"
           if empty(fCONT_DB)
              qrsay(XNIVEL  ,space(15))
              qrsay(XNIVEL+1,space(35))
           else
              if ! PLAN->(dbseek(fCONT_DB))
                 qmensa("Conta d‚bito n„o encontrada !","B")
                 return .F.
              endif
              qrsay(XNIVEL,fCONT_DB,"@R 99999-9")
              qrsay(XNIVEL+1,left(PLAN->Descricao,35))
           endif
      case cCAMPO == "CONT_CR"
           if empty(fCONT_CR)
              qrsay(XNIVEL  ,space(15))
              qrsay(XNIVEL+1,space(35))
           else
              if ! PLAN->(dbseek(fCONT_CR))
                 qmensa("Conta cr‚dito n„o encontrada !","B")
                 return .F.
              endif
              qrsay(XNIVEL,fCONT_CR,"@R 99999-9")
              qrsay(XNIVEL+1,left(PLAN->Descricao,35))
           endif
      case cCAMPO == "CENTRO"
           if CCUSTO->(dbseek(fCENTRO))
              if empty(fCENTRO)
                 qmensa("Centro de Custo n„o Anal¡tico !!","B")
                 return .F.
              endif
              qrsay ( XNIVEL+1 , CCUSTO->Descricao )
           else
              qmensa("Centro de Custo n„o encontrado !","B")
              return .F.
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
