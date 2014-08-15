/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE TESOURARIA
// OBJETIVO...: LANCAMENTOS DE TRANSFERENCIAS ENTRE BANCOS
// ANALISTA...:
// PROGRAMADOR: LUCINEIDE VILAR POSSEBOM
// INICIO.....: NOVEMBRO DE 1997
// OBS........:
// ALTERACOES.:
function ts205

#include "inkey.ch"
#include "setcurs.ch"

BANCO->(Dbsetorder(3))

/////////////////////////////////////////////////////////////////////////////
// MANUTENCAO DOS LANCAMENTOS DE TRANSFERENCIA ENTRE BANCOS ________________

TRAN_BCO->(qview({{"Codigo/C¢d."                        ,1},;
                  {"i_205b()/Origem"                    ,0},;
                  {"i_205c()/Destino"                   ,0},;
                  {"Valor/Valor"                        ,0}},"P",;
                  {NIL,"i_205a",NIL,NIL},;
                  {"Data==XDATA",{||i205top()},{||i205bot()}},;
                  "<I>ncluir    <C>onsultar  <E>xcluir  "))

return ""

function i205top
   TRAN_BCO->(Dbsetorder(2))
   TRAN_BCO->(dbseek(dtos(XDATA)))
return
function i205bot
   TRAN_BCO->(Dbsetorder(2))
   TRAN_BCO->(qseekn(dtos(XDATA)))
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAR NOME DO BANCO DE ORIGEM _____________________________

function i_205b
  BANCO->(Dbseek(TRAN_BCO->Banco_orig))
return left(BANCO->Descricao,25)

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAR NOME DO BANCO DE DESTINO _____________________________

function i_205c
  BANCO->(Dbseek(TRAN_BCO->Banco_dest))
return left(BANCO->Descricao,25)

/////////////////////////////////////////////////////////////////////////////
// FUNCAO DE CONTROLE PRINCIPAL ANTES DE PROCESSAR A TECLA ACIONADA _________

function i_205a

   local nCURSOR := setcursor(1)

   parameters cOPCAO

   cOPCAO := upper(chr(cOPCAO))

   //if cOPCAO $ "AE" .and. TRAN_BCO->Data < CONFIG->Data_atual
   //   qmensa("Data encerrada. Permissao Negada!","B")
   //   return .F.
   //endif

   //if cOPCAO == "I" .and. CONFIG->Data_ant < CONFIG->Data_atual
   //   qmensa("Data Encerrada. Permissao Negada!","B")
   //   return.F.
   //endif



   if cOPCAO $ "IEC"
      qlbloc(08,02,"B205A","QBLOC.GLO",1)
      qmensa(qabrev(cOPCAO,"IA",{"Inclus„o...","Altera‡„o..."}))
      i_edicao()
   endif

   setcursor(nCURSOR)

return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO DE BROWSE _________________________________________________________

static function i_edicao

   local lCONF := .F.
   local aEDICAO := {}
   local bESCAPE := {||empty(fDOCTO).or.(XNIVEL==2.and.!XFLAG).or.;
                       (XNIVEL==2.and.lastkey()==27).or.;
                       (XNIVEL==2.and.cOPCAO=="A".and.!XFLAG)}

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"

      XNIVEL := 1

      qrsay ( XNIVEL++ , TRAN_BCO->Codigo            )
      qrsay ( XNIVEL++ , TRAN_BCO->Docto             )

      qrsay ( XNIVEL++ , TRAN_BCO->Banco_orig        ) ; BANCO->(Dbseek(TRAN_BCO->Banco_orig))
      qrsay ( XNIVEL++ , left(BANCO->Descricao,15)   )

      qrsay ( XNIVEL++ , TRAN_BCO->Banco_dest        ) ; BANCO->(Dbseek(TRAN_BCO->Banco_dest))
      qrsay ( XNIVEL++ , left(BANCO->Descricao,15)   )

      qrsay ( XNIVEL++ , TRAN_BCO->Valor     , "@E 9,999,999.99"  )

      qrsay ( XNIVEL++ , TRAN_BCO->Form_pgto         ) ; FORM_PGT->(Dbseek(TRAN_BCO->Form_pgto))
      qrsay ( XNIVEL++ , left(FORM_PGT->Descricao,20))

      qrsay ( XNIVEL++ , TRAN_BCO->Nr_cheque   , "9999999")

      qrsay ( XNIVEL++ , left(TRAN_BCO->Favorecido,45))

   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || NIL                                           },NIL          })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDOCTO, "@!")                     },"DOCTO"      })

   aadd(aEDICAO,{{ || view_banco(-1,0,@fBANCO_ORIG)                 },"BANCO_ORIG" })
   aadd(aEDICAO,{{ || NIL                                           },NIL          })

   aadd(aEDICAO,{{ || view_banco(-1,0,@fBANCO_DEST)                 },"BANCO_DEST" })
   aadd(aEDICAO,{{ || NIL                                           },NIL          })

   aadd(aEDICAO,{{ || qgetx(-1,0,@fVALOR    , "@E 9,999,999.99"   ) } ,"VALOR"     })

   aadd(aEDICAO,{{ || view_form(-1,0,@fFORM_PGTO)                   },"FORM_PGTO"  })
   aadd(aEDICAO,{{ || NIL                                           },NIL          })

   aadd(aEDICAO,{{ || qgetx(-1,0,@fNR_CHEQUE, "9999999")            },"NR_CHEQUE"  })

   aadd(aEDICAO,{{ || qgetx(-1,0,@fFAVORECIDO, "@!")                },"FAVORECIDO" })

   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   TRAN_BCO->(qpublicfields())

   iif(cOPCAO=="I",TRAN_BCO->(qinitfields()),TRAN_BCO->(qcopyfields()))

   XNIVEL := 2
   XFLAG  := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; TRAN_BCO->(qreleasefields()) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif

   if TALOES->Ultimo_ch >= TALOES->Inter_fina   // grava ultimo numero do cheque, e verifica se o talao terminou
      if TALOES->(qrlock())
         TALOES->(Dbdelete())  // quando o talao acaba o registro e' excluido
      endif
   else
      if TALOES->(qrlock())
         replace TALOES->Ultimo_ch with (val(fNR_CHEQUE) + 1)
      endif
   endif

   if TRAN_BCO->(iif(cOPCAO=="I",qappend(),qrlock())) .and. CONFIG->(qrlock())

      // AQUI INCREMENTA CODIGO DA INCLUSAO DO CHEQUE _____________________

      if cOPCAO == "I"
         replace CONFIG->Cod_transf with CONFIG->Cod_transf+1
         qmensa("C¢digo Gerado: "+strzero(CONFIG->Cod_transf,5),"B")
         fCODIGO := strzero(CONFIG->Cod_transf,5)
      endif

      // AGORA GRAVA E DESTRAVA ARQUIVO _____________________________________

      fDATA := XDATA

      TRAN_BCO->(qreplacefields())

      if cOPCAO == "I"

         MOV_BANC->(qappend())  // origem

         replace MOV_BANC->Data with fDATA
         replace MOV_BANC->Data_comp with fDATA
         replace MOV_BANC->Cod_banco with fBANCO_ORIG
         replace MOV_BANC->Form_pgto with fFORM_PGTO
         replace MOV_BANC->Historico with "TRANSFERENCIA ENTRE BANCOS" + iif(! empty(fNR_CHEQUE), " CH. NR. " + fNR_CHEQUE, "")
         replace MOV_BANC->Saida     with fVALOR
         replace MOV_BANC->Num_docto with fDOCTO
         replace MOV_BANC->Concilia  with "0"
         replace MOV_BANC->Internal  with "TRBC"+fCODIGO


         MOV_BANC->(qappend())    // destino

         replace MOV_BANC->Data with fDATA
         replace MOV_BANC->Data_comp with fDATA
         replace MOV_BANC->Cod_banco with fBANCO_DEST
         replace MOV_BANC->Form_pgto with fFORM_PGTO
         replace MOV_BANC->Historico with "TRANSFERENCIA ENTRE BANCOS" + iif(! empty(fNR_CHEQUE), " CH. NR. " + fNR_CHEQUE, "")
         replace MOV_BANC->Entrada   with fVALOR
         replace MOV_BANC->Num_docto with fDOCTO
         replace MOV_BANC->Concilia  with "0"
         replace MOV_BANC->Internal  with "TRBC"+fCODIGO


      endif

   else
      iif(cOPCAO=="I",qm1(),qm2())
   endif

   dbunlockall()

// if cOPCAO == "I" ; keyboard "I" ; endif

return

/////////////////////////////////////////////////////////////////////////////
// CRITICAS NA DESCIDA ______________________________________________________

static function i_critica ( cCAMPO )

   local nDIA := 0

   qmensa("")

   iif ( cCAMPO == NIL , cCAMPO := "" , NIL )

   do case

      case cCAMPO == "VALOR"

           if fVALOR == 0 ; return .F. ; endif

      case cCAMPO == "BANCO_ORIG"

           if empty(fBANCO_ORIG) ; return .F. ; endif

           if ! BANCO->(dbseek(fBANCO_ORIG:=strzero(val(fBANCO_ORIG),5)))
               qmensa("Banco n„o Cadastrado !","B")
               return .F.
           endif

           qrsay(XNIVEL+1,left(BANCO->Descricao,15))

      case cCAMPO == "BANCO_DEST"

           if empty(fBANCO_DEST) ; return .F. ; endif

           if ! BANCO->(dbseek(fBANCO_DEST:=strzero(val(fBANCO_DEST),5)))
               qmensa("Banco n„o Cadastrado !","B")
               return .F.
           endif

           qrsay(XNIVEL+1,left(BANCO->Descricao,15))

      case cCAMPO == "FORM_PGTO"

           if empty(fFORM_PGTO) ; return .F. ; endif

           if ! FORM_PGT->(dbseek(fFORM_PGTO:=strzero(val(fFORM_PGTO),5)))
               qmensa("Forma de Pagamento n„o Cadastrada !","B")
               return .F.
           endif

           qrsay(XNIVEL+1,left(FORM_PGT->Descricao,15))

           if left(FORM_PGT->Descricao,6) == "CHEQUE"

              TALOES->(dbsetorder(2))  // codigo do banco
              TALOES->(dbgotop())
              if TALOES->(dbseek(fBANCO_ORIG))
                 fNR_CHEQUE := strzero(TALOES->Ultimo_ch,7)
              else
                qmensa("N„o Existe Tal„o Cadastrado para este Banco !","B")
                XNIVEL := 40 // para sair do loop principal
                return .F.
              endif

           else
              XNIVEL := XNIVEL+2
           endif

   endcase

return .T.

static function i_exclusao

   if QConf("Confirma exclusao deste Deposito?","B")
      MOV_BANC->(Dbsetorder(4))
      if MOV_BANC->(Dbseek("TRBC"+TRAN_BCO->Codigo))
         MOV_BANC->(Qrlock())
         MOV_BANC->(Dbdelete())
         MOV_BANC->(Qunlock())
      endif

      MOV_BANC->(Dbsetorder(4))
      if MOV_BANC->(Dbseek("TRBC"+TRAN_BCO->Codigo))
         MOV_BANC->(Qrlock())
         MOV_BANC->(Dbdelete())
         MOV_BANC->(Qunlock())
      endif

      TRAN_BCO->(Qrlock())
      TRAN_BCO->(Dbdelete())
      TRAN_BCO->(Qunlock())
   endif
return

