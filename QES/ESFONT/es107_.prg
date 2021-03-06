/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE ESTOQUE
// OBJETIVO...: MANUTENCAO DE VENDEDORAS
// ANALISTA...:
// PROGRAMADOR: LUCINEIDE VILAR POSSEBOM
// INICIO.....: JULHO DE 1997
// OBS........:
// ALTERACOES.:
function es107

VEND->(qview({{"Codigo/Codigo"               ,1},;
             {"Nome/Nome"                    ,2}},"P",;
             {NIL,"c107a",NIL,NIL},;
             NIL,q_msg_acesso_usr()))

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function c107a

   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO $ XUSRA

      qlbloc(10,8,"B107A","QBLOC.GLO",1)
      qmensa(qabrev(cOPCAO,"IA",{"Inclus�o... <ESC - Cancela>","Altera��o... <ESC - Cancela>"}))
      i_edicao()

   endif

   setcursor(nCURSOR)

return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA ____________________________________

static function i_edicao()

   local lCONF   := .F.
   local aEDICAO := {}
   local bESCAPE := {||empty(fNOME).or.(XNIVEL==1.and.!XFLAG).or.!empty(fNOME).and.Lastkey()==27.or.;
                       (XNIVEL==1.and.cOPCAO=="A".and.!XFLAG)}

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"
      XNIVEL := 1
      qrsay ( XNIVEL++ , VEND->Codigo     )
      qrsay ( XNIVEL++ , left(VEND->Nome,40))
   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || NIL                                                 },"CODIGO"  })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fNOME,"@!@S40")                         },"NOME"    })

   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus�o","altera��o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   VEND->(qpublicfields())
   iif(cOPCAO=="I",VEND->(qinitfields()),VEND->(qcopyfields()))

   XNIVEL  := 2
   XFLAG   := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; VEND->(qreleasefields()) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif

   if CONFIG->(qrlock()) .and. VEND->(iif(cOPCAO=="I",qappend(),qrlock()))

      // AQUI INCREMENTA CODIGO DA ORDEM DE COMPRA  _________________________

      if cOPCAO == "I"
         replace CONFIG->Cod_vend with CONFIG->Cod_vend + 1
         qrsay ( 1 , fCODIGO := strzero(CONFIG->Cod_vend,3) )
         qmensa("C�digo Gerado: "+fCODIGO,"B")

      endif

      // AGORA GRAVA E DESTRAVA ARQUIVO _____________________________________

      VEND->(qreplacefields())

   else

      if empty(VEND->Codigo)
         VEND->(dbdelete())
      endif

      iif(cOPCAO=="I",qm1(),qm2())

   endif

   dbunlockall()

   if cOPCAO == "I" ; keyboard "I" ; endif

return

/////////////////////////////////////////////////////////////////////////////
// CRITICA DE EDICAO ________________________________________________________

static function i_critica ( cCAMPO )

   local zTMP

   if ! XFLAG ; return .T. ; endif

   do case

      case cCAMPO == "NOME"
           if empty(fNOME) ; return .F. ; endif
   endcase

return .T.


/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXCLUIR VENDEDORA  ___________________________________________

static function i_exclusao
   if qconf("Confirma exclus�o deste(a) Vendedor(a) ?")
      if VEND->(qrlock())
         VEND->(dbdelete())
         VEND->(qunlock())
      else
         qm3()
      endif
   endif
return
