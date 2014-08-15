/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE TESOURARIA
// OBJETIVO...: LANCAMENTOS DE REFORCO DE CAIXA
// ANALISTA...:
// PROGRAMADOR:
// INICIO.....: JANEIRO DE
// OBS........:
// ALTERACOES.:
function ts202

#include "inkey.ch"
#include "setcurs.ch"

BANCO->(Dbsetorder(3))

/////////////////////////////////////////////////////////////////////////////
// MANUTENCAO DOS LANCAMENTOS DE CHEQUES PRE-DATADOS ________________________

REF_CAIX->(qview({{"dtoc(Data)/Data"                    ,2},;
                  {"Codigo/C¢d."                        ,0},;
                  {"i_202b()/Banco"                     ,0},;
                  {"Docto/Documento"                    ,0},;
                  {"Valor/Valor"                        ,0}},"P",;
                  {NIL,"i_202a",NIL,NIL},;
                   NIL,"<I>nclui  <A>ltera  <C>onsulta  <E>xclui  "))

return ""

function i202top
   REF_CAIX->(dbsetorder(2))
   REF_CAIX->(dbseek(XDATA))
return
function i202bot
   REF_CAIX->(dbsetorder(2))
   REF_CAIX->(qseekn(XDATA))
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAR NOME DO BANCO ________________________________________

function i_202b
  BANCO->(Dbseek(REF_CAIX->Cod_banco))
return left(BANCO->Descricao,40)

/////////////////////////////////////////////////////////////////////////////
// FUNCAO DE CONTROLE PRINCIPAL ANTES DE PROCESSAR A TECLA ACIONADA _________

function i_202a

   local nCURSOR := setcursor(1)

   parameters cOPCAO

   cOPCAO := upper(chr(cOPCAO))

   //if cOPCAO $ "AE" .and. REF_CAIX->Data < CONFIG->Data_atual
   //   qmensa("Data Encerrada. Permissao Negada!","B")
   //   return.F.
   //endif

   //if cOPCAO == "I" .and. CONFIG->Data_ant < CONFIG->Data_atual
   //   qmensa("Data Encerrada. Permissao Negada!","B")
   //   return.F.
   //endif


   if cOPCAO $ "ICAE"
      qlbloc(08,04,"B202A","QBLOC.GLO",1)
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
   local bESCAPE := {||empty(fDATA).or.(XNIVEL==2.and.!XFLAG).or.;
                       (XNIVEL==2.and.lastkey()==27).or.;
                       (XNIVEL==2.and.cOPCAO=="A".and.!XFLAG)}

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"

      XNIVEL := 1

      qrsay ( XNIVEL++ , REF_CAIX->Codigo            )
      qrsay ( XNIVEL++ , REF_CAIX->Data              )
      qrsay ( XNIVEL++ , REF_CAIX->Docto             )
      qrsay ( XNIVEL++ , REF_CAIX->Cod_Banco         ) ; BANCO->(Dbseek(REF_CAIX->Cod_banco))
      qrsay ( XNIVEL++ , left(BANCO->Descricao,15)   )
      qrsay ( XNIVEL++ , REF_CAIX->Cod_caixa         ) ; BANCO->(Dbseek(REF_CAIX->Cod_caixa))
      qrsay ( XNIVEL++ , REF_CAIX->Valor     , "@E 9,999,999.99"  )
      qrsay ( XNIVEL++ , REF_CAIX->Num_cheque        )
      qrsay ( XNIVEL++ , REF_CAIX->Favorecido        )

   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || NIL                                           },NIL          })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDATA  , "99/99/9999"           ) } ,"DATA"      })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDOCTO , "@!"                   ) } ,"DOCTO"     })
   aadd(aEDICAO,{{ || view_banco(-1,0,@fCOD_BANCO)                  },"COD_BANCO"  })
   aadd(aEDICAO,{{ || NIL                                           },NIL          })
   aadd(aEDICAO,{{ || view_banco(-1,0,@fCOD_CAIXA)                  },"COD_CAIXA"  })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fVALOR    , "@E 9,999,999.99"   ) } ,"VALOR"     })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fNUM_CHEQUE , "9999999"         ) } ,"NUM_CHEQUE"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@fFAVORECIDO , "@!"              ) } ,"FAVORECIDO"})
   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   REF_CAIX->(qpublicfields())

   iif(cOPCAO=="I",REF_CAIX->(qinitfields()),REF_CAIX->(qcopyfields()))

   XNIVEL := 2
   XFLAG  := .T.
   fCOD_CAIXA := CONFIG->Caixa

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; REF_CAIX->(qreleasefields()) ; return ; endif
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
         replace TALOES->Ultimo_ch with ( val(fNUM_CHEQUE) + 1 )
      endif
   endif

   if REF_CAIX->(iif(cOPCAO=="I",qappend(),qrlock())) .and. CONFIG->(qrlock())

      // AQUI INCREMENTA CODIGO DA INCLUSAO DO CHEQUE _____________________

      if cOPCAO == "I"
         replace CONFIG->Cod_ref_cx with CONFIG->Cod_ref_cx+1
         qmensa("C¢digo Gerado: "+strzero(CONFIG->Cod_ref_cx,5),"B")
         fCODIGO := strzero(CONFIG->Cod_ref_cx,5)
      endif

      // AGORA GRAVA E DESTRAVA ARQUIVO _____________________________________

      //fDATA := XDATA

      REF_CAIX->(qreplacefields())
      //REF_CAIX->(dbgotop())

      if cOPCAO == "I" .and. MOV_CAIX->(qappend())
         replace MOV_CAIX->Data with fDATA
         replace MOV_CAIX->Data_comp with fDATA
         replace MOV_CAIX->Cod_banco with fCOD_BANCO
         replace MOV_CAIX->Form_pgto with fFORM_PGTO
         replace MOV_CAIX->Historico with "REFORCO DE CAIXA" + iif(! empty(fNUM_CHEQUE), " CH. NR. " + fNUM_CHEQUE, "")
         replace MOV_CAIX->Entrada   with fVALOR
         replace MOV_CAIX->Num_docto with fDOCTO
         replace MOV_CAIX->Internal  with "RFCX"+fCODIGO
      endif

      if cOPCAO == "A"
         MOV_CAIX->(Dbsetorder(2))
         if MOV_CAIX->(dbseek("RFCX"+REF_CAIX->Codigo))
            if MOV_CAIX->(Qrlock())
               replace MOV_CAIX->Data with fDATA
               replace MOV_CAIX->Cod_banco with fCOD_BANCO
               replace MOV_CAIX->Historico with "REFORCO DE CAIXA"
               replace MOV_CAIX->Entrada   with fVALOR
               replace MOV_CAIX->Num_docto with fDOCTO
            endif
            MOV_CAIX->(qunlock())
         endif
         MOV_CAIX->(Dbsetorder(1))
      endif


      if cOPCAO == "I" .and. MOV_BANC->(qappend())
         replace MOV_BANC->Data with fDATA
         replace MOV_BANC->Data_comp with fDATA
         replace MOV_BANC->Cod_banco with fCOD_BANCO
         replace MOV_BANC->Form_pgto with fFORM_PGTO
         replace MOV_BANC->Historico with "REFORCO DE CAIXA" + iif(! empty(fNUM_CHEQUE), " CH. NR. " + fNUM_CHEQUE, "")
         replace MOV_BANC->Saida     with fVALOR
         replace MOV_BANC->Num_docto with fDOCTO
         replace MOV_BANC->Concilia  with "0"
         replace MOV_BANC->Internal  with "RFCX"+fCODIGO
      endif

      if cOPCAO == "A"
         MOV_BANC->(dbsetorder(4))
         if MOV_BANC->(Dbseek("RFCX"+REF_CAIX->Codigo))
            if MOV_BANC->(qrlock())
               replace MOV_BANC->Data      with fDATA
               replace MOV_BANC->Data_comp with fDATA
               replace MOV_BANC->Cod_banco with fCOD_BANCO
               replace MOV_BANC->Form_pgto with fFORM_PGTO
               replace MOV_BANC->Historico with "REFORCO DE CAIXA" + iif(! empty(fNUM_CHEQUE), " CH. NR. " + fNUM_CHEQUE, "")
               replace MOV_BANC->Saida     with fVALOR
               replace MOV_BANC->Num_docto with fDOCTO
               replace MOV_BANC->Concilia  with "0"
            endif
         endif
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

      case cCAMPO == "COD_BANCO"

           if empty(fCOD_BANCO) ; return .F. ; endif

           if ! BANCO->(dbseek(fCOD_BANCO:=strzero(val(fCOD_BANCO),5)))
               qmensa("Banco n„o Cadastrado !","B")
               return .F.
           endif

           qrsay(XNIVEL+1,left(BANCO->Descricao,20))

           TALOES->(dbsetorder(2))  // codigo do banco
           TALOES->(dbgotop())

           if cOPCAO == "I"
              if TALOES->(dbseek(fCOD_BANCO))
                 fNUM_CHEQUE := str(TALOES->Ultimo_ch,7)
              else
                 qmensa("N„o Existe Tal„o Cadastrado para este Banco !","B")
                 XNIVEL := 40 // para sair do loop principal
                 return .F.
              endif
           endif

      case cCAMPO == "COD_CAIXA"

           if empty(fCOD_CAIXA) ; return .F. ; endif

           if ! BANCO->(dbseek(fCOD_CAIXA:=strzero(val(fCOD_CAIXA),5)))
               qmensa("Codigo do Caixa n„o Cadastrado !","B")
               return .F.
           endif

   endcase

return .T.

static function i_exclusao

   if QConf("Confirma exclusao deste Reforco de Caixa?","B")
      MOV_BANC->(Dbsetorder(4))
      if MOV_BANC->(Dbseek("RFCX"+REF_CAIX->Codigo))
         MOV_BANC->(Qrlock())
         MOV_BANC->(Dbdelete())
         MOV_BANC->(Qunlock())
      endif

      MOV_CAIX->(Dbsetorder(2))
      if MOV_CAIX->(Dbseek("RFCX"+REF_CAIX->Codigo))
         MOV_CAIX->(Qrlock())
         MOV_CAIX->(Dbdelete())
         MOV_CAIX->(Qunlock())
      endif

      REF_CAIX->(Qrlock())
      REF_CAIX->(Dbdelete())
      REF_CAIX->(Qunlock())
   endif
return
