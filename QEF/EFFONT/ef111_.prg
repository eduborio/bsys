
/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE ESCRITA FISCAL
// OBJETIVO...: MANUTENCAO DE CODIGOS DE PRODUTOS (ICMS-PR)
// ANALISTA...: IN SUNG CHANG
// PROGRAMADOR: O MESMO
// INICIO.....: ABRIL DE 1997
// OBS........:
// ALTERACOES.:

function ef111
COD_PROD->(qview({{"transform(Codigo,'@R 99.99-9')/C¢digo" ,1},;
                  {"c111b()/Descri‡„o"                     ,2}},"P",;
                  {NIL,"c111a",NIL,NIL},;
                   NIL,q_msg_acesso_usr()))
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA DESLOCAR EM ARVORE A DESCRICAO DOS PRODUTOS __________________

function c111b
   local cDESCRICAO := COD_PROD->Descricao + "    "
   do case
      case len(alltrim(COD_PROD->Codigo)) == 2 ; cDESCRICAO := COD_PROD->Descricao
      case len(alltrim(COD_PROD->Codigo)) == 5 ; cDESCRICAO := "  "+COD_PROD->Descricao
   endcase
return cDESCRICAO

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function c111a
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))
   if cOPCAO $ XUSRA
      qlbloc(09,10,"B111A","QBLOC.GLO",1)
      qmensa(qabrev(cOPCAO,"IA",{"Inclus„o... <ESC - Cancela>","Altera‡„o... <ESC - Cancela>"}))
      i_edicao()
   endif
   setcursor(nCURSOR)
return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA ____________________________________

static function i_edicao
   local aEDICAO := {}
   local bESCAPE := {||empty(fCODIGO).or.(XNIVEL==1.and.!XFLAG).or.!empty(fCODIGO).and.Lastkey()==27.or.;
                       (XNIVEL==1.and.cOPCAO=="A".and.!XFLAG)}
   private nTIPO := 0
   private lCONF

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"
      XNIVEL := 1
      qrsay ( XNIVEL++ , COD_PROD->Codigo , "@R 99.99-9" )
      qrsay ( XNIVEL++ , COD_PROD->Descricao )
   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || qgetx(-1,0,@fCODIGO       ,"@R 99.99-9")              },"CODIGO"    })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDESCRICAO    ,"@!")                      },"DESCRICAO" })
   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   COD_PROD->(qpublicfields())
   iif(cOPCAO=="I",COD_PROD->(qinitfields()),COD_PROD->(qcopyfields()))

   XNIVEL := 1
   XFLAG  := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; COD_PROD->(qreleasefields()) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif

   if COD_PROD->(iif(cOPCAO=="I",qappend(),qrlock()))
      COD_PROD->(qreplacefields())
   else
      iif(cOPCAO=="I",qm1(),qm2())
   endif

   dbunlockall()

   if cOPCAO == "I" ; keyboard "I" ; endif

return

/////////////////////////////////////////////////////////////////////////////
// CRITICA DE EDICAO ________________________________________________________

static function i_critica ( cCAMPO )

   if ! XFLAG ; return .T. ; endif

   do case

      case cCAMPO == "CODIGO"

           if cOPCAO == "I"
              i_tipo_inc()
           else
              nTIPO := 2
           endif

           if nTIPO == 1
              if ! COD_PROD->(dbseek(left(fCODIGO,2))) .and. cOPCAO == "I"
                 qmensa("Grupo n„o cadastrado !","B")
                 fCODIGO := ""
                 return .F.
              endif
              if COD_PROD->(dbseek(fCODIGO)) .and. cOPCAO == "I"
                 qmensa("C¢digo de Produto j  cadastrado !","B")
                 fCODIGO := ""
                 return .F.
              endif
           else
              if cOPCAO == "I"
                 if COD_PROD->(dbseek(fCODIGO))
                    qmensa("Grupo j  cadastrado !","B")
                    fCODIGO := ""
                    return .F.
                 endif
              endif
           endif

   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXCLUIR PRODUTO ______________________________________________

static function i_exclusao
   if qconf("Confirma exclus„o deste C¢digo de Produto ?")
      if COD_PROD->(qrlock())
         COD_PROD->(dbdelete())
         COD_PROD->(qunlock())
      else
         qm3()
      endif
   endif
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHER TIPO DE INCLUSAO ____________________________________

static function i_tipo_inc
   nTIPO := alert("Voce est  incluindo...",{"C¢DIGO DE PRODUTO","GRUPO"})
return

