/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO COMERCIO
// OBJETIVO...: CONFIGURACAO DE PREVISAO DE PRODUCAO DE CONCRETO
// ANALISTA...: LUIS ANTONIO ORLANDO PEREIRA
// PROGRAMADOR: O MESMO
// INICIO.....: OUTUBRO DE 1995
// OBS........:
// ALTERACOES.:

//fu_abre_ccusto()

function cl804
NFAT->(qview({{"Filial"            ,1},;
              {"i_804x()/Descri‡„o",0},;
              {"Previsao"          ,0}},"P",;
              {NIL,"c804a",NIL,NIL},;
              NIL,q_msg_acesso_usr()))
return

function i_804x
   FILIAL->(dbseek(NFAT->Filial))
return left(FILIAL->Razao,40)

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function c804a
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))
   if cOPCAO $ XUSRA
      qlbloc(10,12,"B804A","QBLOC.GLO",1)
      qmensa(qabrev(cOPCAO,"IA",{"Inclus„o...","Altera‡„o..."}))
      i_edicao()
   endif
   setcursor(nCURSOR)
return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA ____________________________________

static function i_edicao
   local lCONF
   local aEDICAO := {}
   local bESCAPE := {||empty(fFILIAL).or.(XNIVEL==1.and.!XFLAG)}

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"
      XNIVEL := 1
      qrsay ( XNIVEL++ , NFAT->Filial ) ; FILIAL->(dbseek(NFAT->Filial))
      qrsay ( XNIVEL++ , left(FILIAL->Razao,40) )
      qrsay ( XNIVEL++ , NFAT->Previsao , "99999" )
   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || view_filial(-1,0,@fFILIAL)     },"FILIAL" })
   aadd(aEDICAO,{{ || NIL                            },NIL      })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fPREVISAO,"99999") },"PREVISAO" })
   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   NFAT->(qpublicfields())
   iif(cOPCAO=="I",NFAT->(qinitfields()),NFAT->(qcopyfields()))
   XNIVEL := 1
   XFLAG  := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; NFAT->(qreleasefields()) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif

   if NFAT->(iif(cOPCAO=="I",qappend(),qrlock()))
      NFAT->(qreplacefields())
      NFAT->(qunlock())
   else
      iif(cOPCAO=="I",qm1(),qm2())
   endif

return

/////////////////////////////////////////////////////////////////////////////
// CRITICA DE EDICAO ________________________________________________________

static function i_critica ( cCAMPO )

   if ! XFLAG ; return .T. ; endif

   do case

      case cCAMPO == "FILIAL"

           if FILIAL->(dbseek(fFILIAL))
              qrsay(XNIVEL+1,left(FILIAL->Razao,40))
           else
              qmensa("Filial n„o encontrado !","B")
              return .F.
           endif

           if cOPCAO == "I" .and. NFAT->(dbseek(fFILIAL))
              qmensa("Config. do Filial j  cadastrado !","B")
              return .F.
           endif

   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXCLUIR FILIAL _______________________________________________

static function i_exclusao
   if qconf("Confirma exclus„o deste Filial ?")
      if NFAT->(qrlock())
         NFAT->(dbdelete())
         NFAT->(qunlock())
      else
         qm3()
      endif
   endif
return

