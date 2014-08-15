
/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: FOLHA DE PAGAMENTO
// OBJETIVO...: MANUTENCAO DE LINHAS PARA VALE TRANSPORTE
// ANALISTA...: CARLOS EDUARDO RABELLO NUNES
// PROGRAMADOR: O MESMO
// INICIO.....: SETEMBRO DE 1996
// OBS........:
// ALTERACOES.:

/////////////////////////////////////////////////////////////////////////////
// MANUTENCAO DE VALE _______________________________________________________

VALE->(dbSetFilter({|| Anomes == XANOMES},'Anomes == XANOMES'))

VALE->(qview({{"Codigo/C¢digo"                     ,1},;
              {"Descricao/Descri‡„o"               ,2},;
              {"transform(Valor,'@E 999.99')/Valor",0}},"P",;
              {NIL,"c104a",NIL,NIL},;
               NIL,q_msg_acesso_usr()))
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE VALE TRANSPORTE ___________________________

function c104a
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))
   if cOPCAO $ XUSRA
      qlbloc(12,16,"B104A","QBLOC.GLO",1)
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
   local bESCAPE := {||empty(fCODIGO).or.(XNIVEL==1.and.!XFLAG).or.;
                    (XNIVEL==2.and.cOPCAO=="A".and.!XFLAG).or.lastkey()=27}

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"
      XNIVEL := 1
      qrsay(XNIVEL++,VALE->Codigo   )
      qrsay(XNIVEL++,VALE->Descricao)
      qrsay(XNIVEL++,transform(VALE->Valor,"@E 999.99"))
   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || NIL },NIL}) // codigo nao pode ser editado
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDESCRICAO,"@!"       ) } ,"DESCRICAO"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@fVALOR    ,"@E 999.99") } ,"VALOR"    })
   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   VALE->(qpublicfields())
   iif(cOPCAO=="I",VALE->(qinitfields()),VALE->(qcopyfields()))
   XNIVEL := 1
   XFLAG := .T.

   if cOPCAO == "I"
      fCODIGO := strzero(CONFIG->Vale + 1,2)
   endif

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; VALE->(qreleasefields()) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif

   if VALE->(iif(cOPCAO=="I",qappend(),qrlock()))
      fANOMES := XANOMES
      VALE->(qreplacefields())
      VALE->(qunlock())

      CONFIG->(qrlock())
      CONFIG->Vale := val(fCODIGO)
      CONFIG->(qunlock())
   else
      iif(cOPCAO=="I",qm1(),qm2())
   endif

return

/////////////////////////////////////////////////////////////////////////////
// CRITICAS NA DESCIDA ______________________________________________________

static function i_critica ( cCAMPO )
   iif ( cCAMPO == NIL , cCAMPO := "" , NIL )
   if XFLAG
      do case
         case XNIVEL = 1 .and. cOPCAO == "I"
              qrsay(XNIVEL,fCODIGO)
      endcase
   endif
return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXCLUIR VALE TRANSPORTE ______________________________________

static function i_exclusao
   if qconf("Confirma exclus„o deste Vale Tranporte ?")
      if VALE->(qrlock())
         VALE->(dbdelete())
         VALE->(qunlock())
      else
         qm3()
      endif
   endif
return

