/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE TESOURARIA
// OBJETIVO...: LANCAMENTOS DE DEPOSITOS
// ANALISTA...:
// PROGRAMADOR: LUCINEIDE VILAR POSSEBOM
// INICIO.....: NOVEMBRO DE 1997
// OBS........:
// ALTERACOES.:
function ts203

#include "inkey.ch"
#include "setcurs.ch"

BANCO->(Dbsetorder(3))

/////////////////////////////////////////////////////////////////////////////
// MANUTENCAO DOS LANCAMENTOS DE CHEQUES PRE-DATADOS ________________________

DEPOSITO->(qview({{"dtoc(data)/Data"                    ,2},;
                  {"Codigo/C¢d."                        ,1},;
                  {"left(Historico,25)/Historico"       ,0},;
                  {"Valor_ch()/Cheque"                   ,0},;
                  {"Valor_es()/Especie"                  ,0}},"P",;
                  {NIL,"i_203a",NIL,NIL},;
                   NIL,"<I>ncluir  <C>onsultar  <A>lterar   <E>xcluir  "))

return ""

function Valor_ch
return transf(valor_ch1+valor_ch2,"@R 999,999.99")

function Valor_es
return transf(valor_es1+valor_es2,"@R 999,999.99")


function i203top
   DEPOSITO->(dbsetorder(2))
   DEPOSITO->(dbseek(XDATA))
return
function i203bot
   DEPOSITO->(dbsetorder(2))
   DEPOSITO->(qseekn(XDATA))
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAR NOME DO BANCO ________________________________________

function i_203b
  BANCO->(Dbseek(DEPOSITO->Banco))
return left(BANCO->Descricao,36)

/////////////////////////////////////////////////////////////////////////////
// FUNCAO DE CONTROLE PRINCIPAL ANTES DE PROCESSAR A TECLA ACIONADA _________

function i_203a

   local nCURSOR := setcursor(1)

   parameters cOPCAO

   cOPCAO := upper(chr(cOPCAO))

   //if cOPCAO $ "AE" .and. DEPOSITO->Data < CONFIG->Data_atual
   //   qmensa("Data encerrada. Permissao Negada!","B")
   //   return .F.
   //endif

   //if cOPCAO == "I" .and. CONFIG->Data_ant < CONFIG->Data_atual
   //   qmensa("Data Encerrada. Permissao Negada!","B")
   //   return.F.
   //endif



   if cOPCAO $ "IAEC"
      qlbloc(08,11,"B203A","QBLOC.GLO")
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
   local bESCAPE := {||empty(fData).or.(XNIVEL==2.and.!XFLAG).or.;
                       (XNIVEL==2.and.lastkey()==27).or.;
                       (XNIVEL==2.and.cOPCAO=="A".and.!XFLAG)}

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"

      XNIVEL := 1

      qrsay ( XNIVEL++ , DEPOSITO->Codigo            )
      qrsay ( XNIVEL++ , dtoc(DEPOSITO->Data)        )
      qrsay ( XNIVEL++ , DEPOSITO->Docto             )
      qrsay ( XNIVEL++ , DEPOSITO->Banco             ) ; BANCO->(Dbseek(DEPOSITO->Banco))
      qrsay ( XNIVEL++ , left(BANCO->Descricao,20)   )
      qrsay ( XNIVEL++ , DEPOSITO->Cod_caixa         ) ; BANCO->(Dbseek(DEPOSITO->Cod_caixa))
      qrsay ( XNIVEL++ , left(BANCO->Descricao,20)   )
      qrsay ( XNIVEL++ , DEPOSITO->Valor_ch1 , "@E 9,999,999.99"  )
      qrsay ( XNIVEL++ , DEPOSITO->Valor_ch2 , "@E 9,999,999.99"  )
      qrsay ( XNIVEL++ , DEPOSITO->Valor_es1 , "@E 9,999,999.99"  )
      qrsay ( XNIVEL++ , DEPOSITO->Valor_es2 , "@E 9,999,999.99"  )
      qrsay ( XNIVEL++ , left(DEPOSITO->Historico,20))

   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exclusao()      ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || NIL                                           },NIL          })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDATA, "99/99/9999"             ) } ,"DATA"      })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDOCTO, "@!"                    ) } ,"DOCTO"     })
   aadd(aEDICAO,{{ || view_banco(-1,0,@fBANCO)                      },"BANCO"      })
   aadd(aEDICAO,{{ || NIL                                           },NIL          })
   aadd(aEDICAO,{{ || view_banco(-1,0,@fCOD_CAIXA)                  },"COD_CAIXA"  })
   aadd(aEDICAO,{{ || NIL                                           },NIL          })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fVALOR_CH1, "@E 9,999,999.99"   ) } ,"VALOR_CH1" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fVALOR_CH2, "@E 9,999,999.99"   ) } ,"VALOR_CH2" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fVALOR_ES1, "@E 9,999,999.99"   ) } ,"VALOR_ES1" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fVALOR_ES2, "@E 9,999,999.99"   ) } ,"VALOR_ES2" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fHISTORICO, "@!S20"             ) } ,"HISTORICO" })
   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   DEPOSITO->(qpublicfields())

   iif(cOPCAO=="I",DEPOSITO->(qinitfields()),DEPOSITO->(qcopyfields()))

   XNIVEL := 2
   XFLAG  := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; DEPOSITO->(qreleasefields()) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif

   if DEPOSITO->(iif(cOPCAO=="I",qappend(),qrlock())) .and. CONFIG->(qrlock())

      // AQUI INCREMENTA CODIGO DA INCLUSAO DO CHEQUE _____________________

      if cOPCAO == "I"
         replace CONFIG->Cod_dep with CONFIG->Cod_dep+1
         qmensa("C¢digo Gerado: "+strzero(CONFIG->Cod_dep,5),"B")
         fCODIGO := strzero(CONFIG->Cod_dep,5)
      endif

      // AGORA GRAVA E DESTRAVA ARQUIVO _____________________________________

      //fDATA := XDATA

      DEPOSITO->(qreplacefields())
//      DEPOSITO->(dbgotop())

      if cOPCAO == "I" .and. MOV_CAIX->(qappend())
         replace MOV_CAIX->Data with fDATA
         replace MOV_CAIX->Cod_banco with fBANCO
         replace MOV_CAIX->Historico with "DEPOSITO BANCARIO"
         replace MOV_CAIX->Saida     with ( fVALOR_CH1 + fVALOR_CH2 + fVALOR_ES1 + fVALOR_ES2 )
         replace MOV_CAIX->Num_docto with fDOCTO
         replace MOV_CAIX->Internal  with "DPST"+fCODIGO
      endif

      if cOPCAO == "A"
         MOV_CAIX->(Dbsetorder(2))
         if MOV_CAIX->(Dbseek("DPST"+DEPOSITO->Codigo)) .and. MOV_CAIX->(Qrlock())
            replace MOV_CAIX->Data with fDATA
            replace MOV_CAIX->Cod_banco with fBANCO
            replace MOV_CAIX->Historico with "DEPOSITO BANCARIO"
            replace MOV_CAIX->Saida     with ( fVALOR_CH1 + fVALOR_CH2 + fVALOR_ES1 + fVALOR_ES2 )
            replace MOV_CAIX->Num_docto with fDOCTO
            MOV_CAIX->(qunlock())
         endif

      endif


      if cOPCAO == "I" .and. MOV_BANC->(qappend())
         replace MOV_BANC->Data with fDATA
         replace MOV_BANC->Data_comp with fDATA
         replace MOV_BANC->Cod_banco with fBANCO
         replace MOV_BANC->Historico with "DEPOSITO BANCARIO"
         replace MOV_BANC->Entrada   with ( fVALOR_CH1 + fVALOR_CH2 + fVALOR_ES1 + fVALOR_ES2 )
         replace MOV_BANC->Num_docto with fDOCTO
         replace MOV_BANC->Concilia  with "0"
         replace MOV_BANC->Internal  with "DPST"+fCODIGO

      endif


      if cOPCAO == "A"
         MOV_BANC->(Dbsetorder(4))
         if MOV_BANC->(dbseek("DPST"+DEPOSITO->Codigo)) .and. MOV_BANC->(qrlock())
            replace MOV_BANC->Data with fDATA
            replace MOV_BANC->Data_comp with fDATA
            replace MOV_BANC->Cod_banco with fBANCO
            replace MOV_BANC->Historico with "DEPOSITO BANCARIO"
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

//      case cCAMPO == "VALOR_CH1"
//           if empty(fVALOR_CH1) ; return .F. ; endif

//      case cCAMPO == "VALOR_CH2"
//           if empty(fVALOR_CH2) ; return .F. ; endif

//      case cCAMPO == "VALOR_ES1"
//           if empty(fVALOR_ES1) ; return .F. ; endif

//      case cCAMPO == "VALOR_ES2"
//           if empty(fVALOR_ES2) ; return .F. ; endif

   endcase

return .T.

static function i_exclusao

   if QConf("Confirma exclusao deste Deposito?","B")
      MOV_BANC->(Dbsetorder(4))
      if MOV_BANC->(Dbseek("DPST"+DEPOSITO->Codigo))
         MOV_BANC->(Qrlock())
         MOV_BANC->(Dbdelete())
         MOV_BANC->(Qunlock())
      endif

      MOV_CAIX->(Dbsetorder(2))
      if MOV_CAIX->(Dbseek("DPST"+DEPOSITO->Codigo))
         MOV_CAIX->(Qrlock())
         MOV_CAIX->(Dbdelete())
         MOV_CAIX->(Qunlock())
      endif

      DEPOSITO->(Qrlock())
      DEPOSITO->(Dbdelete())
      DEPOSITO->(Qunlock())
   endif
return

