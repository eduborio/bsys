
/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: FOLHA DE PAGAMENTO
// OBJETIVO...: CONFIGURACAO DOS EVENTOS
// ANALISTA...: CARLOS EDUARDO RABELLO NUNES
// PROGRAMADOR: O MESMO
// INICIO.....: SETEMBRO DE 1996
// OBS........:
// ALTERACOES.:

EVCFG->(qview({{"Evento/Evento"      ,1},;
               {"f803a()/Descri‡„o"  ,0},;
               {"Tipo/Tipo"          ,0},;
               {"f803b()/Referˆncia" ,0}},"P",;
               {NIL,"c803a",NIL,NIL},;
                NIL,q_msg_acesso_usr()))
return

/////////////////////////////////////////////////////////////////////////////
// BUSCA E PLOTA DESCRICAO DO EVENTO ________________________________________

function f803a
   EVENT->(dbseek(EVCFG->Evento))
return(EVENT->Descricao)

/////////////////////////////////////////////////////////////////////////////
// PLOTA VALOR TRANSFORMADO _________________________________________________

function f803b
return(transform(EVCFG->Ref,"@E 99,999,999.9999"))

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function c803a
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))
   if cOPCAO $ XUSRA
      qlbloc(11,13,"B803A","QBLOC.GLO",1)
      qmensa(qabrev(cOPCAO,"IA",{"Inclus„o... <ESC - Cancela>","Altera‡„o... <ESC - Cancela>"}))
      i_edicao()
   endif
   setcursor(nCURSOR)
return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA ____________________________________

static function i_edicao
   local lCONF
   local aEDICAO := {}
   local bESCAPE := {||empty(fEVENTO).or.(XNIVEL==1.and.!XFLAG).or.!empty(fEVENTO).and.Lastkey()==27.or.;
                       (XNIVEL==2.and.cOPCAO=="A".and.!XFLAG)}

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"
      XNIVEL := 1
      qrsay(XNIVEL++,EVCFG->Evento    ) ; EVENT->(dbseek(EVCFG->Evento))
      qrsay(XNIVEL++,EVENT->Descricao)
      qrsay(XNIVEL++,EVCFG->Tipo      )
      qrsay(XNIVEL++,transform(EVCFG->Ref,"@E 99,999,999.9999"))
   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   if cOPCAO == "I"
      aadd(aEDICAO,{{ || view_event(-1,0,@fEVENTO,"@!" ) } ,"EVENTO" })
   else
      aadd(aEDICAO,{{ || NIL } ,NIL}) // quando alteracao, codigo nao editavel
   endif

   aadd(aEDICAO,{{ || NIL } ,NIL}) // descricao do evento
   aadd(aEDICAO,{{ || qgetx(-1,0,@fTIPO     ,"@!"                ) } ,"TIPO"   })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fREF      ,"@E 99,999,999.9999") } ,"REF"    })
   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   EVCFG->(qpublicfields())
   iif(cOPCAO=="I",EVCFG->(qinitfields()),EVCFG->(qcopyfields()))
   XNIVEL  := 1
   XFLAG   := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; EVCFG->(qreleasefields()) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif

   if EVCFG->(iif(cOPCAO=="I",qappend(),qrlock()))
      EVCFG->(qreplacefields())
      EVCFG->(qunlock())
   else
      iif(cOPCAO=="I",qm1(),qm2())
   endif

return

/////////////////////////////////////////////////////////////////////////////
// CRITICAS NA DESCIDA ______________________________________________________

static function i_critica ( cCAMPO )
   iif ( cCAMPO == NIL , cCAMPO := "" , NIL )
   do case
      case cCAMPO == "EVENTO" .and. cOPCAO == "I"
           qrsay(XNIVEL,fEVENTO := strzero(val(fEVENTO),3))
           if ! EVENT->(dbseek(fEVENTO))
              qmensa("Evento n„o cadastrado !","B")
              return .F.
           endif
           if EVCFG->(dbseek(fEVENTO))
              qmensa("Evento j  configurado !","B")
              return .F.
           endif
           qrsay(XNIVEL+1,EVENT->Descricao)
   endcase
return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXCLUIR CARGO ________________________________________________

static function i_exclusao
   if qconf("Confirma exclus„o deste evento ?")
      if EVCFG->(qrlock())
         EVCFG->(dbdelete())
         EVCFG->(qunlock())
      else
         qm3()
      endif
   endif
return

