/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO COMERCIAL
// OBJETIVO...: MANUTENCAO DE VENDEDORES
// ANALISTA...:
// PROGRAMADOR: EDUARDO BORIO
// INICIO.....: SETEMBRO de 2009
// OBS........:
// ALTERACOES.:

function cl127

ROTA->(qview({{"Codigo/Codigo"               ,1},;
             {"left(Descricao,40)/Descricao"     ,2}},"P",;
             {NIL,"c127a",NIL,NIL},;
             NIL,q_msg_acesso_usr()))
             
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function c127a

   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO $ XUSRA

      qlbloc(5,0,"B127A","QBLOC.GLO",1)
      qmensa(qabrev(cOPCAO,"IA",{"Inclus„o... <ESC - Cancela>","Altera‡„o... <ESC - Cancela>"}))
      i_edicao()

   endif

   setcursor(nCURSOR)

return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA ____________________________________

static function i_edicao()

   local lCONF   := .F.
   local aEDICAO := {}
   local bESCAPE := {||empty(fDESCRICAO).or.(XNIVEL==2.and.!XFLAG).or.!empty(fDESCRICAO).and.Lastkey()==27.or.;
                       (XNIVEL==2.and.cOPCAO=="A".and.!XFLAG)}

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"
      XNIVEL := 1
      qrsay ( XNIVEL++ , ROTA->Codigo     )
      qrsay ( XNIVEL++ , ROTA->Descricao  )

      if cOPCAO == "C"
         i_atu_lanc()
         keyboard chr(27)
      endif

   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || NIL                                                 },"CODIGO"   })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDESCRICAO,"@!")                         },"DESCRICAO"})

   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   ROTA->(qpublicfields())
   iif(cOPCAO=="I",ROTA->(qinitfields()),ROTA->(qcopyfields()))

   XNIVEL  := 2
   XFLAG   := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; ROTA->(qreleasefields()) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif

   if CONFIG->(qrlock()) .and. ROTA->(iif(cOPCAO=="I",qappend(),qrlock()))


      // AQUI INCREMENTA CODIGO DO CLIENTE __________________________________

      if cOPCAO == "I"
         replace CONFIG->Cod_rota with CONFIG->Cod_rota + 1
         qrsay ( 1 , fCODIGO := strzero(CONFIG->Cod_rota,5))
         qmensa("C¢digo Gerado: "+fCODIGO,"B")
      endif

      ROTA->(qreplacefields())

   else

      if empty(ROTA->Codigo) .and. empty(ROTA->Descricao)
         ROTA->(dbdelete())
      endif

      iif(cOPCAO=="I",qm1(),qm2())

   endif

   dbunlockall()

   if cOPCAO == "I" ; keyboard "I" ; endif

   i_proc_item()
return

/////////////////////////////////////////////////////////////////////////////
// CRITICA DE EDICAO ________________________________________________________

static function i_critica ( cCAMPO )

   local nREG,nINDEX := 0

   if ! XFLAG ; return .T. ; endif

   do case

      case cCAMPO == "COD_GRUPO"


   endcase

return .T.



static function i_exclusao
   if qconf("Confirma desta Rota?")

      if ROTA_ABR->(Qflock())

         Do While ! ROTA_ABR->(Eof()) .and. ROTA_ABR->Cod_rota == ROTA->Codigo
            ROTA_ABR->(dbdelete())
            ROTA_ABR->(dbskip())
         enddo
         ROTA_ABR->(qunlock())

      endif


      if ROTA->(qrlock())
         ROTA->(dbdelete())
         ROTA->(qunlock())
      else
         qm3()
      endif
   endif
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DOS PRODUTOS _______________________________

static function i_proc_item

// LOOP PRINCIPAL ___________________________________________________________

setcolor("W/B")


 ROTA_ABR->(qview({{"Bairro/Bairro"                                       ,0}},;
                  "10002179S",;
                  {NIL,"f127d",NIL,NIL},;
                  {"ROTA_ABR->Cod_rota == ROTA->Codigo",{||f127top()},{||f127bot()}},;
                  "..."))
return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IR PARA O INICIO DOS DADOS FILTRADOS _________________________

function f127top
   ROTA_ABR->(dbsetorder(1))
   ROTA_ABR->(dbseek(ROTA->Codigo))
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IR PARA O FINAL DOS DADOS FILTRADOS __________________________

function f127bot
   ROTA_ABR->(dbsetorder(1))
   ROTA_ABR->(qseekn(ROTA->Codigo))
return

function f127d

   local nCURSOR := setcursor(1)
   parameters cOPCAO

   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO $ XUSRA
      qlbloc(06,00,"B127B","QBLOC.GLO",1)
      i_edicao_iten()
   endif

   setcursor(nCURSOR)

return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO DE BROWSE _________________________________________________________

static function i_edicao_iten

   local lCONF
   local aEDICAO := {}
   local bESCAPE := {||empty(fBAIRRO).or.(XNIVEL==1.and.!XFLAG).or.;
                       (XNIVEL==1.and.lastkey()==27)}



   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"

      XNIVEL := 1
      qrsay ( XNIVEL++ , ROTA_ABR->Bairro        , "@!")

   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exc_itens_pr() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || qgetx(-1,0,@fBAIRRO ,"@!"                         ) } ,"BAIRRO"  })
   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   ROTA_ABR->(qpublicfields())

   iif(cOPCAO=="I",ROTA_ABR->(qinitfields()),ROTA_ABR->(qcopyfields()))

   XNIVEL := 1

   XFLAG  := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; ROTA_ABR->(qreleasefields()) ; return ; endif
      if ! i_crit2( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   if ! lCONF ; return ; endif

   // GRAVACAO ______________________________________________________________

   if ROTA->(qrlock()) .and. ROTA_ABR->(iif(cOPCAO=="I",qappend(),qrlock()))
      if cOPCAO == "I"
         fCOD_ROTA := fCODIGO
      endif

      ROTA_ABR->(qreplacefields())
      ROTA_ABR->(qunlock())

   else
      iif(cOPCAO=="I",qm1(),qm2())

   endif

return

// CRITICAS NA DESCIDA ______________________________________________________

static function i_crit2 ( cCAMPO )
local nINDEX := 0
local nREG := 0

   qmensa("")

   iif ( cCAMPO == NIL , cCAMPO := "" , NIL )
   if ! XFLAG; return .t.; endif
   do case
      case cCAMPO == "BAIRRO"

           if cOPCAO == "I"
              nREG   := ROTA_ABR->(Recno())
              nINDEX := ROTA_ABR->(IndexOrd())
              ROTA_ABR->(dbsetorder(2))

              if ROTA_ABR->(dbseek(fBAIRRO))
                 qmensa("Bairro ja Incluido em outra ROTA!","BL")
                 return .F.
              endif

              ROTA_ABR->(dbsetorder(nINDEX))
              ROTA_ABR->(dbgoto(nREG))
           endif



   endcase

return .T.

static function i_exc_itens_pr

   if qconf("Confirma exclus„o do Bairro ?")

      if ROTA_ABR->(qrlock())
         ROTA_ABR->(dbdelete())
         ROTA_ABR->(qunlock())
      else
         qm3()
      endif
   endif

return



static function i_atu_lanc

// LOOP PRINCIPAL ___________________________________________________________

setcolor("W/B")


 ROTA_ABR->(qview({{"BAirro/Bairro."                                        ,1}},;
                  "10002179S",;
                  {NIL,NIL,NIL,NIL},;
                  {"ROTA_ABR->Cod_rota == ROTA->Codigo",{||f127top()},{||f127bot()}},;
                  "..."))
return ""


