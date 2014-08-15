/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO COMERCIAL
// OBJETIVO...: MANUTENCAO DE VENDEDORES
// ANALISTA...:
// PROGRAMADOR: EDUARDO BORIO
// INICIO.....: ABRIL DE 1997
// OBS........:
// ALTERACOES.:

function cl131

REP_GRUP->(qview({{"Codigo/Codigo"               ,1},;
             {"left(Descricao,40)/Descricao"     ,2}},"P",;
             {NIL,"c131a",NIL,NIL},;
             NIL,q_msg_acesso_usr()))
             
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function c131a

   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO $ XUSRA

      qlbloc(5,0,"B131A","QBLOC.GLO",1)
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
      qrsay ( XNIVEL++ , REP_GRUP->Codigo     )
      qrsay ( XNIVEL++ , REP_GRUP->Descricao  )

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

   REP_GRUP->(qpublicfields())
   iif(cOPCAO=="I",REP_GRUP->(qinitfields()),REP_GRUP->(qcopyfields()))

   XNIVEL  := 2
   XFLAG   := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; REP_GRUP->(qreleasefields()) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif

   if CONFIG->(qrlock()) .and. REP_GRUP->(iif(cOPCAO=="I",qappend(),qrlock()))


      // AQUI INCREMENTA CODIGO DO CLIENTE __________________________________

      if cOPCAO == "I"
         replace CONFIG->Cod_grurep with CONFIG->Cod_grurep + 1
         qrsay ( 1 , fCODIGO := strzero(CONFIG->Cod_grurep,5))
         qmensa("C¢digo Gerado: "+fCODIGO,"B")
      endif

      REP_GRUP->(qreplacefields())

   else

      if empty(REP_GRUP->Codigo) .and. empty(REP_GRUP->Descricao)
         REP_GRUP->(dbdelete())
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
   if qconf("Confirma exclus„o dest(a) Grupo de representantes ?")

      if ITEN_GRU->(Qflock())

         Do While ! ITEN_GRU->(Eof()) .and. ITEN_GRU->Cod_grup == REP_GRUP->Codigo
            ITEN_GRU->(dbdelete())
            ITEN_GRU->(dbskip())
         enddo
         ITEN_GRU->(qunlock())

      endif


      if REP_GRUP->(qrlock())
         REP_GRUP->(dbdelete())
         REP_GRUP->(qunlock())
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


 ITEN_GRU->(qview({{"Cod_repres/Cod."                                        ,1},;
                  {"f131a()/Descri‡„o"                                       ,0}},;
                  "10002179S",;
                  {NIL,"f131d",NIL,NIL},;
                  {"ITEN_GRU->Cod_grup == REP_GRUP->Codigo",{||f131top()},{||f131bot()}},;
                  "..."))
return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IR PARA O INICIO DOS DADOS FILTRADOS _________________________

function f131top
   ITEN_GRU->(dbsetorder(1))
   ITEN_GRU->(dbseek(REP_GRUP->Codigo))
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IR PARA O FINAL DOS DADOS FILTRADOS __________________________

function f131bot
   ITEN_GRU->(dbsetorder(1))
   ITEN_GRU->(qseekn(REP_GRUP->Codigo))
return

/////////////////////////////////////////////////////////////////////////////
// RETORNA A DESCRICAO DO PRODUTO __________________________________________

function f131a
   local cDESCRICAO := space(30)
   if ! empty(ITEN_GRU->Cod_repres)
      REPRES->(dbseek(ITEN_GRU->Cod_repres))
      cDESCRICAO := left(REPRES->Razao,30)
   endif
return cDESCRICAO


function f131d

   local nCURSOR := setcursor(1)
   parameters cOPCAO

   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO $ XUSRA
      qlbloc(06,00,"B131B","QBLOC.GLO",1)
      i_edicao_iten()
   endif

   setcursor(nCURSOR)

return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO DE BROWSE _________________________________________________________

static function i_edicao_iten

   local lCONF
   local aEDICAO := {}
   local bESCAPE := {||empty(fCOD_REPRES).or.(XNIVEL==1.and.!XFLAG).or.;
                       (XNIVEL==1.and.lastkey()==27).or.;
                       (XNIVEL==2.and.cOPCAO=="A".and.!XFLAG)}


   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"

      XNIVEL := 1
      qrsay ( XNIVEL++ , ITEN_GRU->Cod_repres            , "@R 99999") ; REPRES->(dbseek(ITEN_GRU->Cod_repres,5))
      qrsay ( XNIVEL++ , left(REPRES->Descricao,40)                 )

   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exc_itens_pr() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || view_repres(-1,0,@fCOD_REPRES                ) } ,"COD_REPRES"  })
   aadd(aEDICAO,{{ || NIL                                            } ,NIL         })


   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   ITEN_GRU->(qpublicfields())

   iif(cOPCAO=="I",ITEN_GRU->(qinitfields()),ITEN_GRU->(qcopyfields()))

   XNIVEL := 1

   XFLAG  := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; ITEN_GRU->(qreleasefields()) ; return ; endif
      if ! i_crit2( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   if ! lCONF ; return ; endif

   // GRAVACAO ______________________________________________________________

   if REP_GRUP->(qrlock()) .and. ITEN_GRU->(iif(cOPCAO=="I",qappend(),qrlock()))
      if cOPCAO == "I"
         fCOD_GRUP := fCODIGO
      endif

      ITEN_GRU->(qreplacefields())
      ITEN_GRU->(qunlock())

   else
      iif(cOPCAO=="I",qm1(),qm2())

   endif

return

// CRITICAS NA DESCIDA ______________________________________________________

static function i_crit2 ( cCAMPO )

   qmensa("")

   iif ( cCAMPO == NIL , cCAMPO := "" , NIL )
   if ! XFLAG; return .t.; endif
   do case

      case cCAMPO == "COD_REPRES"
           qrsay(XNIVEL,fCOD_REPRES:=strzero(val(fCOD_REPRES),5))

           if ! REPRES->(dbseek(fCOD_REPRES))
              qmensa("Representante n„o encontrado !","B")
              return .F.
           endif

           qrsay ( XNIVEL+1 , left(REPRES->Razao,38) )

   endcase

return .T.

static function i_exc_itens_pr

   if qconf("Confirma exclus„o do Produto ?")

      if ITEN_GRU->(qrlock())
         ITEN_GRU->(dbdelete())
         ITEN_GRU->(qunlock())
      else
         qm3()
      endif
   endif

return



static function i_atu_lanc

// LOOP PRINCIPAL ___________________________________________________________

setcolor("W/B")


 ITEN_GRU->(qview({{"Cod_repres/Cod."                                        ,1},;
                  {"f131a()/Descri‡„o"                                       ,0}},;
                  "10002179S",;
                  {NIL,NIL,NIL,NIL},;
                  {"ITEN_GRU->Cod_grup == REP_GRUP->Codigo",{||f131top()},{||f131bot()}},;
                  "..."))
return ""


