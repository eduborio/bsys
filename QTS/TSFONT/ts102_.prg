/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DA TESOURARIA
// OBJETIVO...: MANUTENCAO DE TALONARIO
// ANALISTA...:
// PROGRAMADOR: LUCINEIDE VILAR POSSEBOM
// INICIO.....: FEVEREIRO DE 1997
// OBS........:
// ALTERACOES.:
function ts102

BANCO->(Dbsetorder(3)) // ordem de codigo

TALOES->(qview({{"Codigo/C¢digo"                ,1},;
                {"c102a()/Banco"                ,0},;
                {"Num_Cheque/Nr. Cheques"       ,0}},"P",;
                {NIL,"c102b",NIL,NIL},;
                 NIL,q_msg_acesso_usr()))

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAR NOME DO BANCO  _______________________________________

function c102a
   BANCO->(dbseek(TALOES->Cod_banco))
return BANCO->Descricao

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function c102b
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))
   if cOPCAO $ XUSRA
      qlbloc(9,12,"B102A","QBLOC.GLO",1)
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
   local bESCAPE := {||empty(fCOD_BANCO).or.(XNIVEL==1.and.!XFLAG).or.!empty(fCOD_BANCO).and.Lastkey()==27.or.;
                       (XNIVEL==1.and.cOPCAO=="A".and.!XFLAG)}

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"
      XNIVEL := 1
      qrsay ( XNIVEL++ , TALOES->Codigo                               )
      qrsay ( XNIVEL++ , TALOES->Cod_banco                            ) ; BANCO->(dbseek(TALOES->Cod_banco))
      qrsay ( XNIVEL++ , left(BANCO->Descricao,30)                    )
      qrsay ( XNIVEL++ , TALOES->Num_cheque,"@E 9999"                 )
      qrsay ( XNIVEL++ , transform(TALOES->Inter_prim,"@E 9999999"   ))
      qrsay ( XNIVEL++ , transform(TALOES->Inter_fina,"@E 9999999"   ))
   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || NIL                                                  },NIL          })
   aadd(aEDICAO,{{ || view_banco(-1,0,@fCOD_BANCO)                         },"COD_BANCO"  })
   aadd(aEDICAO,{{ || NIL                                                  },NIL          })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fNUM_CHEQUE   ,"@E 9999")                },"NUM_CHEQUE" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fINTER_PRIM   ,"@E 9999999")             },"INTER_PRIM" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fINTER_FINA   ,"@E 9999999")             },"INTER_FINA" })

   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   TALOES->(qpublicfields())
   iif(cOPCAO=="I",TALOES->(qinitfields()),TALOES->(qcopyfields()))

   XNIVEL  := 2
   XFLAG   := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; TALOES->(qreleasefields()) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif

   if TALOES->(iif(cOPCAO=="I",qappend(),qrlock())) .and. CONFIG->(qrlock())

      // AQUI INCREMENTA CODIGO DO TALOES ____________________________________

      if cOPCAO == "I"
         replace CONFIG->Cod_talao with CONFIG->Cod_talao+1
         qmensa("C¢digo Gerado: "+strzero(CONFIG->Cod_TALAO,5),"B")
         fCODIGO := strzero(CONFIG->Cod_TALAO,5)
         fULTIMO_CH := fINTER_PRIM
      endif

      // AGORA GRAVA E DESTRAVA ARQUIVO _____________________________________

      TALOES->(qreplacefields())

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
      case cCAMPO == "COD_BANCO"

           if empty(fCOD_BANCO) ; return .F. ; endif

           if ! BANCO->(dbseek(fCOD_BANCO:=strzero(val(fCOD_BANCO),5)))
               qmensa("Banco n„o Cadastrado !","B")
               return .F.
           endif

           qrsay(XNIVEL+1,left(BANCO->Descricao,30))

      case cCAMPO == "INTER_PRIM"

           if empty(fINTER_PRIM) ; return .F. ; endif
           fINTER_FINA := fINTER_PRIM + (fNUM_CHEQUE - 1)

   endcase

return .T.

///////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXCLUIR TALOES ________________________________________________

static function i_exclusao
   if qconf("Confirma exclus„o deste Tal„o ?")
      if TALOES->(qrlock())
         TALOES->(dbdelete())
         TALOES->(qunlock())
      else
         qm3()
      endif
   endif
return
