
/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: ESCRITA FISCAL
// OBJETIVO...: MANUTENCAO DE CODIGOS DE SAIDA PARA MAQ. REGISTRADORA
// ANALISTA...: LUIS ANTONIO
// PROGRAMADOR: IN SUNG CHANG
// INICIO.....: FEVEREIRO DE 1995
// OBS........:
// ALTERACOES.:
function ef106

/////////////////////////////////////////////////////////////////////////////
// MANUTENCAO DE CODIGOS DE MAQUINA RESGISTRADORA____________________________

MAQ->(qview({{"Maq_Cod/C¢digo"     ,1} ,;
              {"Maq_Desc/Descri‡„o" ,2}},"P",;
              {NIL,"i_106a",NIL,NIL},;
              NIL,q_msg_acesso_usr()))
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function i_106a

   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO $ XUSRA
      qlbloc(9,10,"B106A","QBLOC.GLO",1)
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
   local bESCAPE := {||empty(fMAQ_COD).or.(XNIVEL==1.and.!XFLAG).or.!empty(fMAQ_COD).and.Lastkey()==27.and.XNIVEL==2.or.;
                       (XNIVEL==1.and.lastkey()==27).or.;
                       (XNIVEL==2.and.cOPCAO=="A".and.!XFLAG)}

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"

      XNIVEL := 1
      qrsay ( XNIVEL++ , MAQ->Maq_Cod  , "@R 99" )
      qrsay ( XNIVEL++ , MAQ->Maq_Desc           )

   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || qgetx(-1,0,@fMAQ_COD  ,"@R 99",NIL,cOPCAO=="I")},"MAQ_COD" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fMAQ_DESC ,"@!"                   )},"MAQ_DESC"})
   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   MAQ->(qpublicfields())

   iif(cOPCAO=="I",MAQ->(qinitfields()),MAQ->(qcopyfields()))

   XNIVEL := 1
   XFLAG := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; MAQ->(qreleasefields()) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif

   if MAQ->(iif(cOPCAO=="I",qappend(),qrlock()))
      MAQ->(qreplacefields())
      MAQ->(qunlock())
   else
      iif(cOPCAO=="I",qm1(),qm2())
   endif

return

/////////////////////////////////////////////////////////////////////////////
// CRITICAS NA DESCIDA ______________________________________________________

static function i_critica ( cCAMPO )

   iif ( cCAMPO == NIL , cCAMPO := "" , NIL )

   do case
      case cCAMPO == "MAQ_COD" .and. cOPCAO == "I"
           qrsay(XNIVEL,fMAQ_CODI:=strzero(val(fMAQ_COD),2))
           if MAQ->(dbseek(fMAQ_COD))
              qmensa("Codigo M quina Registradora j  cadastrado !","B")
              return .F.
           endif
   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXCLUIR CODIGOS FISCAIS_______________________________________

static function i_exclusao

   if qconf("Confirma exclus„o do Registro ?")
      if MAQ->(qrlock())
         MAQ->(dbdelete())
         MAQ->(qunlock())
      else
         qm3()
      endif
   endif

return
