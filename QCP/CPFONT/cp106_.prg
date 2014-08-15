
/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE COMPRAS
// OBJETIVO...: MANUTENCAO DE ESPECIE
// ANALISTA...: IN SUNG CHANG
// PROGRAMADOR: IN SUNG CHANG
// INICIO.....: NOVEMBRO DE 1996
// OBS........:
// ALTERACOES.:

/////////////////////////////////////////////////////////////////////////////
// MANUTENCAO DE CODIGOS FISCAIS_____________________________________________

function cp106

ESPECIE->(qview({{"Codigo/C¢digo"       ,1} ,;
                 {"Descricao/Descri‡„o" ,2}},"P",;
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
      qlbloc(9,18,"B106A","QBLOC.GLO",1)
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
   local bESCAPE := {||empty(fDESCRICAO).or.(XNIVEL==2.and.!XFLAG).or.!empty(fDESCRICAO).and.Lastkey()==27.or.;
                       (XNIVEL==2.and.cOPCAO=="A".and.!XFLAG)}

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"
      XNIVEL := 1
      qrsay ( XNIVEL++ , ESPECIE->Codigo    )
      qrsay ( XNIVEL++ , ESPECIE->Descricao )
   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || NIL                                           },"CODIGO"    })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDESCRICAO ,"@!"                ) } ,"DESCRICAO" })

   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   ESPECIE->(qpublicfields())

   iif(cOPCAO=="I",ESPECIE->(qinitfields()),ESPECIE->(qcopyfields()))

   XNIVEL := 2
   XFLAG := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; ESPECIE->(qreleasefields()) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif

   if CONFIG->(qrlock()) .and. ESPECIE->(iif(cOPCAO=="I",qappend(),qrlock()))
      // AQUI INCREMENTA CODIGO DO FORNECEDOR _______________________________

      if cOPCAO == "I"
         replace CONFIG->Cod_esp with CONFIG->Cod_esp + 1
         qrsay ( 1 , fCODIGO := strzero(CONFIG->Cod_esp,2) )
         qmensa("C¢digo Gerado: "+fCODIGO,"B")
      endif

      ESPECIE->(qreplacefields())
      ESPECIE->(qunlock())

   else
      iif(cOPCAO=="I",qm1(),qm2())
   endif

return

/////////////////////////////////////////////////////////////////////////////
// CRITICAS NA DESCIDA ______________________________________________________

static function i_critica ( cCAMPO )

   qmensa("")

   iif ( cCAMPO == NIL , cCAMPO := "" , NIL )

   do case
      case cCAMPO == "CODIGO" .and. cOPCAO == "I"
           if ESPECIE->(dbseek(fCODIGO))
              qmensa("Esp‚cie j  cadastrado !","B")
              return .F.
           endif
   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXCLUIR CODIGOS FISCAIS_______________________________________

static function i_exclusao

   if qconf("Confirma exclus„o desta Esp‚cie ?")
      if ESPECIE->(qrlock())
         ESPECIE->(dbdelete())
         ESPECIE->(qunlock())
      else
         qm3()
      endif
   endif

return
