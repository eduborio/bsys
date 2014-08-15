
/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE CONTABILIDADE
// OBJETIVO...: MANUTENCAO DE NATUREZA DE CONTAS
// ANALISTA...: IN SUNG CHANG
// PROGRAMADOR: O MESMO
// INICIO.....: JANEIRO DE 1997
// OBS........:
// ALTERACOES.:

function ct105
NAT_CONT->(qview({{"Codigo/C¢digo"             ,1},;
                  {"Sigla/Sigla"               ,2},;
                  {"Descricao/Descri‡„o"       ,3}},"P",;
                  {NIL,"c105a",NIL,NIL            },;
                   NIL,q_msg_acesso_usr()))

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function c105a

   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO $ XUSRA
      qlbloc(08,12,"B105A","QBLOC.GLO",1)
      qmensa(qabrev(cOPCAO,"IA",{"Inclus„o... <ESC - Cancela>","Altera‡„o... <ESC - Cancela>"}))
      i_edicao()
   endif

   setcursor(nCURSOR)

return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA ____________________________________

static function i_edicao

   local lCONF   := .F.
   local aEDICAO := {}
   local bESCAPE := {||empty(fSIGLA).or.(XNIVEL==2.and.!XFLAG).or. (!empty(fSIGLA) .and. XNIVEL==2 .and. !XFLAG .or. !empty(fSIGLA) .and. XNIVEL==2 .and. Lastkey()==27) .or.;
                       (XNIVEL==2.and.cOPCAO=="A".and.!XFLAG)}
   local nREC

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"
      XNIVEL := 1
      qrsay ( XNIVEL++ , NAT_CONT->Codigo     )
      qrsay ( XNIVEL++ , NAT_CONT->Sigla      )
      qrsay ( XNIVEL++ , NAT_CONT->Descricao  )
   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || NIL                               },"CODIGO"    })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fSIGLA,"@!")          },"SIGLA"     })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDESCRICAO,"@!")      },"DESCRICAO" })

   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   NAT_CONT->(qpublicfields())
   iif(cOPCAO=="I",NAT_CONT->(qinitfields()),NAT_CONT->(qcopyfields()))

   XNIVEL := 2
   XFLAG  := .T.

   if cOPCAO == "I"
      fFATOR := 1
   endif

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; NAT_CONT->(qreleasefields()) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif

     // AGORA INCREMENTA CODIGO DO COMPRADOR ________________________________

   if CONFIG->(qrlock()) .and. NAT_CONT->(iif(cOPCAO=="I",qappend(),qrlock()))

      if cOPCAO == "I"
         replace CONFIG->Cod_nat_ct with CONFIG->Cod_nat_ct + 1
         qrsay ( 1 , fCODIGO := strzero(CONFIG->Cod_nat_ct,3) )
         qmensa("C¢digo Gerado: "+fCODIGO,"B")
      endif

      // AGORA GRAVA E DESTRAVA ARQUIVO _____________________________________

      NAT_CONT->(qreplacefields())
      NAT_CONT->(dbgotop())

   endif

   dbunlockall()

   if cOPCAO == "I" ; keyboard "I" ; endif

return

/////////////////////////////////////////////////////////////////////////////
// CRITICA DE EDICAO ________________________________________________________

static function i_critica ( cCAMPO )

   local nREC

   if ! XFLAG ; return .T. ; endif

   qmensa()

   do case

      case cCAMPO == "SIGLA"
           if empty(fSIGLA) ; return .F. ; endif

      case cCAMPO == "DESCRICAO"
           if empty(fDESCRICAO) ; return .F. ; endif

   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXCLUIR NATUREZA _____________________________________________

static function i_exclusao
   if qconf("Confirma exclus„o deste Natureza ?")
      if NAT_CONT->(qrlock())
         NAT_CONT->(dbdelete())
         NAT_CONT->(qunlock())
      else
         qm3()
      endif
   endif
return

