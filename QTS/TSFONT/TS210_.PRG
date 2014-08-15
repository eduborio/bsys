/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE TESOURARIA
// OBJETIVO...: LANCAMENTOS DE CHEQUES DEVOLVIDOS
// ANALISTA...:
// PROGRAMADOR: EDUARDO AUGUSTO BORIO
// INICIO.....: MAIO DE 2001
// OBS........:
// ALTERACOES.:
function ts210

#include "inkey.ch"
#include "setcurs.ch"

BANCO->(Dbsetorder(3))

/////////////////////////////////////////////////////////////////////////////
// MANUTENCAO DOS LANCAMENTOS DE CHEQUES PRE-DATADOS ________________________

ESTORNO->(qview({{"dtoc(Data)/Data"                    ,2},;
                 {"Codigo/C¢d."                        ,1},;
                  {"Banco/Banco"                        ,0},;
                  {"i_210b()/Descricao"                  ,0},;
                  {"Valor_ch1/Valor"                   ,0}},"P",;
                  {NIL,"i_210a",NIL,NIL},;
                   NIL,"<I>ncluir/<C>onsultar"))

return ""

function i210top
   ESTORNO->(dbsetorder(2))
   ESTORNO->(dbseek(dtos(XDATA)))
return
function i210bot
   ESTORNO->(dbsetorder(2))
   ESTORNO->(qseekn(dtos(XDATA)))
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAR NOME DO BANCO ________________________________________

function i_210b
  BANCO->(Dbseek(ESTORNO->Banco))
return left(BANCO->Descricao,36)

/////////////////////////////////////////////////////////////////////////////
// FUNCAO DE CONTROLE PRINCIPAL ANTES DE PROCESSAR A TECLA ACIONADA _________

function i_210a

   local nCURSOR := setcursor(1)

   parameters cOPCAO

   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO $ "IC"
      qlbloc(08,11,"B210A","QBLOC.GLO",1)
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
   local bESCAPE := {||(XNIVEL==2.and.!XFLAG).or.;
                       (XNIVEL==2.and.lastkey()==27).or.;
                       (XNIVEL==2.and.cOPCAO=="A".and.!XFLAG)}

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"

      XNIVEL := 1

      qrsay ( XNIVEL++ , ESTORNO->Codigo            )
      qrsay ( XNIVEL++ , ESTORNO->Data              )
//      qrsay ( XNIVEL++ , ESTORNO->Docto             )
      qrsay ( XNIVEL++ , ESTORNO->Banco             ) ; BANCO->(Dbseek(ESTORNO->Banco))
      qrsay ( XNIVEL++ , left(BANCO->Descricao,20)   )
      qrsay ( XNIVEL++ , ESTORNO->Cod_caixa         ) ; BANCO->(Dbseek(ESTORNO->Cod_caixa))
      qrsay ( XNIVEL++ , left(BANCO->Descricao,20)   )
      qrsay ( XNIVEL++ , ESTORNO->Valor_ch1 , "@E 9,999,999.99"  )

   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || NIL                                           },NIL          })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDATA, "99/99/9999"             ) } ,"DATA"      })
   aadd(aEDICAO,{{ || view_banco(-1,0,@fBANCO)                      },"BANCO"      })
   aadd(aEDICAO,{{ || NIL                                           },NIL          })
   aadd(aEDICAO,{{ || view_banco(-1,0,@fCOD_CAIXA)                  },"COD_CAIXA"  })
   aadd(aEDICAO,{{ || NIL                                           },NIL          })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fVALOR_CH1, "@E 9,999,999.99"   ) } ,"VALOR_CH1" })
   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   ESTORNO->(qpublicfields())

   iif(cOPCAO=="I",ESTORNO->(qinitfields()),ESTORNO->(qcopyfields()))

   XNIVEL := 2
   XFLAG  := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; ESTORNO->(qreleasefields()) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif

   if ESTORNO->(iif(cOPCAO=="I",qappend(),qrlock())) .and. CONFIG->(qrlock())

      // AQUI INCREMENTA CODIGO DA INCLUSAO DO CHEQUE _____________________

      if cOPCAO == "I"
         replace CONFIG->Cod_est with CONFIG->Cod_est+1
         qmensa("C¢digo Gerado: "+strzero(CONFIG->Cod_est,5),"B")
         fCODIGO := strzero(CONFIG->Cod_est,5)
      endif

      // AGORA GRAVA E DESTRAVA ARQUIVO _____________________________________

//      fDATA := XDATA

      ESTORNO->(qreplacefields())
      ESTORNO->(dbgotop())

      if cOPCAO == "I" .and. MOV_CAIX->(qappend())
         replace MOV_CAIX->Data with fDATA
         replace MOV_CAIX->Cod_banco with "99999"
         replace MOV_CAIX->Historico with "ESTORNO DE DEPOSITO"
         replace MOV_CAIX->Entrada   with (fVALOR_CH1)
         replace MOV_CAIX->Internal  with "ESDP"+fCODIGO
      endif

      if cOPCAO == "A"
         MOV_CAIX->(Dbsetorder(2))
         if MOV_CAIX->(Dbseek("ESDP"+ESTORNO->Codigo)) .and. MOV_CAIX->(Qrlock())
            replace MOV_CAIX->Data with fDATA
            replace MOV_CAIX->Cod_banco with fBANCO
            replace MOV_CAIX->Historico with "ESTORNO DEPOSITO"
            replace MOV_CAIX->Saida     with ( fVALOR_CH1 + fVALOR_CH2 + fVALOR_ES1 + fVALOR_ES2 )
            replace MOV_CAIX->Num_docto with fDOCTO
            MOV_CAIX->(qunlock())
         endif

      endif


      if cOPCAO == "I" .and. MOV_BANC->(qappend())
         replace MOV_BANC->Data with fDATA
         replace MOV_BANC->Data_comp with fDATA
         replace MOV_BANC->Cod_banco with fBANCO
         replace MOV_BANC->Historico with "ESTORNO DE DEPOSITO"
         replace MOV_BANC->Saida     with ( fVALOR_CH1 )
         replace MOV_BANC->Concilia  with "0"
         replace MOV_BANC->Internal  with "ESDP"+fCODIGO
      endif

      if cOPCAO == "A"
         MOV_BANC->(Dbsetorder(4))
         if MOV_BANC->(dbseek("ESDP"+ESTORNO->Codigo)) .and. MOV_BANC->(qrlock())
            replace MOV_BANC->Data with fDATA
            replace MOV_BANC->Data_comp with fDATA
            replace MOV_BANC->Cod_banco with fBANCO
            replace MOV_BANC->Historico with "ESTORNO DEPOSITO"
            replace MOV_BANC->Entrada   with ( fVALOR_CH1 + fVALOR_CH2 + fVALOR_ES1 + fVALOR_ES2 )
            replace MOV_BANC->Num_docto with fDOCTO
            replace MOV_BANC->Concilia  with "0"
            MOV_BANC->(Qunlock())
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

   if QConf("Confirma exclusao deste Estorno Deposito?","B")
      MOV_BANC->(Dbsetorder(4))
      if MOV_BANC->(Dbseek("ESDP"+ESTORNO->Codigo))
         MOV_BANC->(Qrlock())
         MOV_BANC->(Dbdelete())
         MOV_BANC->(Qunlock())
      endif

      MOV_CAIX->(Dbsetorder(2))
      if MOV_CAIX->(Dbseek("ESDP"+ESTORNO->Codigo))
         MOV_CAIX->(Qrlock())
         MOV_CAIX->(Dbdelete())
         MOV_CAIX->(Qunlock())
      endif

      ESTORNO->(Qrlock())
      ESTORNO->(Dbdelete())
      ESTORNO->(Qunlock())
   endif
return

