
/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE CONTABILIDADE
// OBJETIVO...: MANUTENCAO DE CENTRO DE CUSTOS
// ANALISTA...:
// PROGRAMADOR: IN SUNG CHANG
// INICIO.....: JANEIRO DE 1997
// OBS........:
// ALTERACOES.:
function ct103

CCUSTO->(qview({{"transform(Codigo,'@R 99.99.9999')/C¢digo" ,1},;
                {"c103b()/Descri‡„o"                        ,2}},"P",;
                {NIL,"c103a",NIL,NIL},;
                 NIL,q_msg_acesso_usr()))
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA DESLOCAR EM ARVORE A DESCRICAO DOS CENTROS DE CUSTO __________

function c103b
   local cDESCRICAO := CCUSTO->Descricao + "    "
   do case
      case len(alltrim(CCUSTO->Codigo)) == 2 ; cDESCRICAO := CCUSTO->Descricao
      case len(alltrim(CCUSTO->Codigo)) == 4 ; cDESCRICAO := "  "+CCUSTO->Descricao
      case len(alltrim(CCUSTO->Codigo)) == 8 ; cDESCRICAO := "    "+CCUSTO->Descricao
   endcase
return cDESCRICAO

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function c103a
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))
   if cOPCAO $ XUSRA
      qlbloc(10,10,"B103A","QBLOC.GLO",1)
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
   local bESCAPE := {||empty(fCODIGO).or.(XNIVEL==1.and.!XFLAG).or. (!empty(fCODIGO) .and. XNIVEL==1 .and. !XFLAG .or. !empty(fCODIGO) .and. XNIVEL==1 .and. Lastkey()==27) .or.;
                       (XNIVEL==1.and.cOPCAO=="A".and.!XFLAG)}

   private nTIPO := 0

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"
      XNIVEL := 1
      qrsay ( XNIVEL++ , CCUSTO->Codigo , "@R 99.99.9999" )
      qrsay ( XNIVEL++ , CCUSTO->Descricao )
      qrsay ( XNIVEL++ , CCUSTO->Responsave)
   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || qgetx(-1,0,@fCODIGO       ,"@R 99.99")                },"CODIGO"     })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDESCRICAO    ,"@!")                      },"DESCRICAO"  })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fRESPONSAVE   ,"@!")                      },"RESPONSAVE" })

   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   CCUSTO->(qpublicfields())
   iif(cOPCAO=="I",CCUSTO->(qinitfields()),CCUSTO->(qcopyfields()))

   XNIVEL := 1
   XFLAG  := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; CCUSTO->(qreleasefields()) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif

   if CONFIG->(qrlock()) .and. CCUSTO->(iif(cOPCAO=="I",qappend(),qrlock()))

      // AQUI INCREMENTA CODIGO DO CCUSTOUTO __________________________________

      if cOPCAO == "I"
         if len(alltrim(fCODIGO)) == 8
            replace CONFIG->Cod_ccusto with val(right(fCODIGO,4))
            qrsay ( 1 , transform(fCODIGO,"@R 99.99.9999") )
            qmensa("C¢digo Gerado: "+fCODIGO,"B")
         endif
      endif

      CCUSTO->(qreplacefields())

   else
      iif(cOPCAO=="I",qm1(),qm2())
   endif

   dbunlockall()

   if cOPCAO == "I" ; keyboard "I" ; endif

return

/////////////////////////////////////////////////////////////////////////////
// CRITICA DE EDICAO ________________________________________________________

static function i_critica ( cCAMPO )

   local nREC

   if ! XFLAG ; return .T. ; endif

   do case

      case cCAMPO == "CODIGO"
           do case
              case len(alltrim(fCODIGO)) == 2
                   if cOPCAO == "I"
                      if CCUSTO->(dbseek(fCODIGO))
                         qmensa("Superior j  cadastrado !","B")
                         fCODIGO := ""
                         return .F.
                      endif
                   endif

              case len(alltrim(fCODIGO)) == 4

                   if cOPCAO == "I"
                      i_tipo_inc()
                   else
                      nTIPO := 2
                   endif

                   if nTIPO == 1
                      fCODIGO := alltrim(fCODIGO) + strzero(CONFIG->Cod_ccusto+1,4)
                      if ! CCUSTO->(dbseek(left(fCODIGO,4))) .and. cOPCAO == "I"
                         qmensa("Sub-grupo n„o cadastrado !","B")
                         fCODIGO := ""
                         return .F.
                      endif
                      if CCUSTO->(dbseek(fCODIGO)) .and. cOPCAO == "I"
                         qmensa("Centro de Custo j  cadastrado !","B")
                         fCODIGO := ""
                         return .F.
                      endif
                   else
                      if cOPCAO == "I"
                         if CCUSTO->(dbseek(fCODIGO))
                            qmensa("Sub-grupo j  cadastrado !","B")
                            fCODIGO := ""
                            return .F.
                         endif
                         if ! CCUSTO->(dbseek(left(fCODIGO,2)))
                            qmensa("Grupo n„o cadastrado !","B")
                            fCODIGO := ""
                            return .F.
                         endif
                      endif
                   endif

           endcase

   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXCLUIR CCUSTOUTO ______________________________________________

static function i_exclusao
   if qconf("Confirma exclus„o deste Centro de Custo ?")
      if CCUSTO->(qrlock())
         CCUSTO->(dbdelete())
         CCUSTO->(qunlock())
      else
         qm3()
      endif
   endif
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHER TIPO DE INCLUSAO ____________________________________

static function i_tipo_inc
   nTIPO := alert("Voce est  incluindo...",{"CENTRO","INTERMEDIARIO"})
return
