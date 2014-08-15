/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE TESOURARIA
// OBJETIVO...: LANCAMENTOS DE CHEQUES DEVOLVIDOS
// ANALISTA...:
// PROGRAMADOR: EDUARDO AUGUSTO BORIO
// INICIO.....: MAIO DE 2001
// OBS........:
// ALTERACOES.:
function ts209

#include "inkey.ch"
#include "setcurs.ch"

BANCO->(Dbsetorder(3))

/////////////////////////////////////////////////////////////////////////////
// MANUTENCAO DOS LANCAMENTOS DE CHEQUES PRE-DATADOS ________________________

CHEQ_DEV->(qview({{"dtoc(Data)/Data"                    ,2},;
                  {"Codigo/C¢d."                        ,1},;
                  {"Banco/Banco"                        ,0},;
                  {"i_209b()/Descricao"                  ,0},;
                  {"Valor_ch1/Cheque"                   ,0}},"P",;
                  {NIL,"i_209a",NIL,NIL},;
                   NIL,"<I>ncluir   <C>onsultar    <E>xcluir   <A>lterar"))

return ""

function i209top
   CHEQ_DEV->(dbsetorder(2))
   CHEQ_DEV->(dbseek(XDATA))
return
function i209bot
   CHEQ_DEV->(dbsetorder(2))
   CHEQ_DEV->(qseekn(XDATA))
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAR NOME DO BANCO ________________________________________

function i_209b
  BANCO->(Dbseek(CHEQ_DEV->Banco))
return left(BANCO->Descricao,36)

/////////////////////////////////////////////////////////////////////////////
// FUNCAO DE CONTROLE PRINCIPAL ANTES DE PROCESSAR A TECLA ACIONADA _________

function i_209a

   local nCURSOR := setcursor(1)

   parameters cOPCAO

   cOPCAO := upper(chr(cOPCAO))

   //if cOPCAO $ "AE" .and. CHEQ_DEV->Data < CONFIG->Data_atual
   //   qmensa("Data Encerrada. Acesso proibido!","B")
   //   return.F.
   //endif

   //if cOPCAO == "I" .and. CONFIG->Data_ant < CONFIG->Data_atual
   //   qmensa("Data Encerrada. Permissao Negada!","B")
   //   return.F.
   //endif


   if cOPCAO $ "IEAC"
      qlbloc(08,11,"B209A","QBLOC.GLO",1)
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

      qrsay ( XNIVEL++ , CHEQ_DEV->Codigo            )
      qrsay ( XNIVEL++ , CHEQ_DEV->Data              )
      qrsay ( XNIVEL++ , CHEQ_DEV->Docto             )
      qrsay ( XNIVEL++ , CHEQ_DEV->Banco             ) ; BANCO->(Dbseek(CHEQ_DEV->Banco))
      qrsay ( XNIVEL++ , left(BANCO->Descricao,20)   )
      qrsay ( XNIVEL++ , CHEQ_DEV->Cod_caixa         ) ; BANCO->(Dbseek(CHEQ_DEV->Cod_caixa))
      qrsay ( XNIVEL++ , left(BANCO->Descricao,20)   )
      qrsay ( XNIVEL++ , CHEQ_DEV->Valor_ch1 , "@E 9,999,999.99"  )

   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif


   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || NIL                                           },NIL          })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDATA , "99/99/9999"            ) } ,"DATA"      })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDOCTO, "@!"                    ) } ,"DOCTO"     })
   aadd(aEDICAO,{{ || view_banco(-1,0,@fBANCO)                      },"BANCO"      })
   aadd(aEDICAO,{{ || NIL                                           },NIL          })
   aadd(aEDICAO,{{ || view_banco(-1,0,@fCOD_CAIXA)                  },"COD_CAIXA"  })
   aadd(aEDICAO,{{ || NIL                                           },NIL          })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fVALOR_CH1, "@E 9,999,999.99"   ) } ,"VALOR_CH1" })
   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   CHEQ_DEV->(qpublicfields())

   iif(cOPCAO=="I",CHEQ_DEV->(qinitfields()),CHEQ_DEV->(qcopyfields()))

   XNIVEL := 2
   XFLAG  := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; CHEQ_DEV->(qreleasefields()) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif

   if CHEQ_DEV->(iif(cOPCAO=="I",qappend(),qrlock())) .and. CONFIG->(qrlock())

      // AQUI INCREMENTA CODIGO DA INCLUSAO DO CHEQUE _____________________

      if cOPCAO == "I"
         replace CONFIG->Cod_dev with CONFIG->Cod_dev+1
         qmensa("C¢digo Gerado: "+strzero(CONFIG->Cod_dev,5),"B")
         fCODIGO := strzero(CONFIG->Cod_dev,5)
      endif

      // AGORA GRAVA E DESTRAVA ARQUIVO _____________________________________

//      fDATA := XDATA

      CHEQ_DEV->(qreplacefields())

      if cOPCAO == "I" .and. MOV_CAIX->(qappend())
         replace MOV_CAIX->Data with fDATA
         replace MOV_CAIX->Cod_banco with fBANCO
         replace MOV_CAIX->Historico with "CHEQUE DEVOLVIDO"
         replace MOV_CAIX->Entrada   with (fVALOR_CH1)
         replace MOV_CAIX->Num_docto with fDOCTO
         replace MOV_CAIX->Internal  with "CHDV"+fCODIGO
      endif

      if cOPCAO == "A"
         MOV_CAIX->(Dbsetorder(2))
         if MOV_CAIX->(dbseek("CHDV"+CHEQ_DEV->Codigo))
            if MOV_CAIX->(Qrlock())
               replace MOV_CAIX->Data with fDATA
               replace MOV_CAIX->Cod_banco with fBANCO
               replace MOV_CAIX->Historico with "CHEQUE DEVOLVIDO"
               replace MOV_CAIX->Entrada   with (fVALOR_CH1)
               replace MOV_CAIX->Num_docto with fDOCTO
            endif
            MOV_CAIX->(qunlock())
         endif
         MOV_CAIX->(Dbsetorder(1))
      endif

      if cOPCAO == "I" .and. MOV_BANC->(qappend())
         replace MOV_BANC->Data with fDATA
         replace MOV_BANC->Data_comp with fDATA
         replace MOV_BANC->Cod_banco with fBANCO
         replace MOV_BANC->Historico with "CHEQUE DEVOLVIDO"
         replace MOV_BANC->Saida     with ( fVALOR_CH1 )
         replace MOV_BANC->Num_docto with fDOCTO
         replace MOV_BANC->Concilia  with "0"
         replace MOV_BANC->Internal  with "CHDV"+fCODIGO
      endif

      if cOPCAO == "A"
         MOV_BANC->(dbsetorder(4))
         if MOV_BANC->(Dbseek("CHDV"+CHEQ_DEV->Codigo))
            if MOV_BANC->(qrlock())
               replace MOV_BANC->Data with fDATA
               replace MOV_BANC->Data_comp with fDATA
               replace MOV_BANC->Cod_banco with fBANCO
               replace MOV_BANC->Historico with "CHEQUE DEVOLVIDO"
               replace MOV_BANC->Saida     with ( fVALOR_CH1 )
               replace MOV_BANC->Num_docto with fDOCTO
               replace MOV_BANC->Concilia  with "0"
            endif
         endif
      endif


   else
      iif(cOPCAO=="I",qm1(),qm2())
   endif

   dbunlockall()

return

/////////////////////////////////////////////////////////////////////////////
// CRITICAS NA DESCIDA ______________________________________________________

static function i_critica ( cCAMPO )

   local nDIA := 0

   qmensa("")

   iif ( cCAMPO == NIL , cCAMPO := "" , NIL )

   do case

      case cCAMPO == "BANCO"

           if empty(fBANCO) ; return .F. ; endif

           if ! BANCO->(dbseek(fBANCO:=strzero(val(fBANCO),5)))
               qmensa("Banco n„o Cadastrado !","B")
               return .F.
           endif

           qrsay(XNIVEL+1,left(BANCO->Descricao,20))

      case cCAMPO == "COD_CAIXA"

           if empty(fCOD_CAIXA) ; return .F. ; endif

           if ! BANCO->(dbseek(fCOD_CAIXA:=strzero(val(fCOD_CAIXA),5)))
               qmensa("Codigo do Caixa n„o Cadastrado !","B")
               return .F.
           endif

           qrsay(XNIVEL+1,left(BANCO->Descricao,20))


   endcase

return .T.

static function i_exclusao

   if QConf("Confirma exclusao deste Cheque Devolvido?","B")
      MOV_BANC->(Dbsetorder(4))
      if MOV_BANC->(Dbseek("CHDV"+CHEQ_DEV->Codigo))
         MOV_BANC->(Qrlock())
         MOV_BANC->(Dbdelete())
         MOV_BANC->(Qunlock())
      endif

      MOV_CAIX->(Dbsetorder(2))
      if MOV_CAIX->(Dbseek("CHDV"+CHEQ_DEV->Codigo))
         MOV_CAIX->(Qrlock())
         MOV_CAIX->(Dbdelete())
         MOV_CAIX->(Qunlock())
      endif

      CHEQ_DEV->(Qrlock())
      CHEQ_DEV->(Dbdelete())
      CHEQ_DEV->(Qunlock())
   endif
return

