/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE TESOURARIA
// OBJETIVO...: LANCAMENTOS DE DEPOSITOS NAo IDENTIFICADOS
// ANALISTA...:
// PROGRAMADOR: EDUARDO BORIO
// INICIO.....: MARCO 2011
// OBS........:
// ALTERACOES.:
function ts217

#include "inkey.ch"
#include "setcurs.ch"

BANCO->(Dbsetorder(3))

/////////////////////////////////////////////////////////////////////////////
// MANUTENCAO DOS LANCAMENTOS DE CHEQUES PRE-DATADOS ________________________

DEP_NIDT->(qview({{"dtoc(data)/Data"                    ,2},;
                  {"Codigo/C¢d."                        ,1},;
                  {"left(Historico,25)/Historico"       ,0},;
                  {"Valor()/Valor"                     ,0}},"P",;
                  {NIL,"i_217a",NIL,NIL},;
                   NIL,"<I>ncluir  <C>onsultar  <A>lterar   <E>xcluir  "))

return ""

function Valor
return transf(valor,"@R 999,999.99")


function i217top
   DEP_NIDT->(dbsetorder(2))
   DEP_NIDT->(dbseek(XDATA))
return
function i217bot
   DEP_NIDT->(dbsetorder(2))
   DEP_NIDT->(qseekn(XDATA))
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAR NOME DO BANCO ________________________________________

function i_217b
  BANCO->(Dbseek(DEP_NIDT->Banco))
return left(BANCO->Descricao,36)

/////////////////////////////////////////////////////////////////////////////
// FUNCAO DE CONTROLE PRINCIPAL ANTES DE PROCESSAR A TECLA ACIONADA _________

function i_217a

   local nCURSOR := setcursor(1)

   parameters cOPCAO

   cOPCAO := upper(chr(cOPCAO))

   //if cOPCAO $ "AE" .and. DEP_NIDT->Data < CONFIG->Data_atual
   //   qmensa("Data encerrada. Permissao Negada!","B")
   //   return .F.
   //endif

   //if cOPCAO == "I" .and. CONFIG->Data_ant < CONFIG->Data_atual
   //   qmensa("Data Encerrada. Permissao Negada!","B")
   //   return.F.
   //endif



   if cOPCAO $ "IAEC"
      qlbloc(08,11,"B217A","QBLOC.GLO")
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

      qrsay ( XNIVEL++ , DEP_NIDT->Codigo            )
      qrsay ( XNIVEL++ , dtoc(DEP_NIDT->Data)        )
      qrsay ( XNIVEL++ , DEP_NIDT->Docto             )
      qrsay ( XNIVEL++ , DEP_NIDT->Banco             ) ; BANCO->(Dbseek(DEP_NIDT->Banco))
      qrsay ( XNIVEL++ , left(BANCO->Descricao,20)   )
      //qrsay ( XNIVEL++ , DEP_NIDT->Cod_caixa         ) ; BANCO->(Dbseek(DEP_NIDT->Cod_caixa))
      //qrsay ( XNIVEL++ , left(BANCO->Descricao,20)   )
      qrsay ( XNIVEL++ , DEP_NIDT->Valor , "@E 9,999,999.99"  )
      qrsay ( XNIVEL++ , left(DEP_NIDT->Historico,20))

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
   //aadd(aEDICAO,{{ || view_banco(-1,0,@fCOD_CAIXA)                  },"COD_CAIXA"  })
   //aadd(aEDICAO,{{ || NIL                                           },NIL          })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fVALOR, "@E 9,999,999.99"       ) } ,"VALOR" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fHISTORICO, "@!S20"             ) } ,"HISTORICO" })
   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   DEP_NIDT->(qpublicfields())

   iif(cOPCAO=="I",DEP_NIDT->(qinitfields()),DEP_NIDT->(qcopyfields()))

   XNIVEL := 2
   XFLAG  := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; DEP_NIDT->(qreleasefields()) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif

   if DEP_NIDT->(iif(cOPCAO=="I",qappend(),qrlock())) .and. CONFIG->(qrlock())

      // AQUI INCREMENTA CODIGO DA INCLUSAO DO CHEQUE _____________________

      if cOPCAO == "I"
         replace CONFIG->Cod_depni with CONFIG->Cod_depni+1
         qmensa("C¢digo Gerado: "+strzero(CONFIG->Cod_depni,5),"B")
         fCODIGO := strzero(CONFIG->Cod_depni,5)
      endif

      // AGORA GRAVA E DESTRAVA ARQUIVO _____________________________________

      //fDATA := XDATA

      DEP_NIDT->(qreplacefields())

      if cOPCAO == "I" .and. MOV_BANC->(qappend())
         replace MOV_BANC->Data with fDATA
         replace MOV_BANC->Data_comp with fDATA
         replace MOV_BANC->Cod_banco with fBANCO
         replace MOV_BANC->Historico with fHistorico
         replace MOV_BANC->Entrada   with fValor
         replace MOV_BANC->Num_docto with fDOCTO
         replace MOV_BANC->Concilia  with "0"
         replace MOV_BANC->Internal  with "DPNI"+fCODIGO

      endif


      if cOPCAO == "A"
         MOV_BANC->(Dbsetorder(4))
         if MOV_BANC->(dbseek("DPNI"+DEP_NIDT->Codigo)) .and. MOV_BANC->(qrlock())
            replace MOV_BANC->Data with fDATA
            replace MOV_BANC->Data_comp with fDATA
            replace MOV_BANC->Cod_banco with fBANCO
            replace MOV_BANC->Historico with fHistorico
            replace MOV_BANC->Entrada   with fVALOR
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

   if QConf("Confirma exclusao deste Deposito nao identificado?","B")
      MOV_BANC->(Dbsetorder(4))
      if MOV_BANC->(Dbseek("DPNI"+DEP_NIDT->Codigo))
         MOV_BANC->(Qrlock())
         MOV_BANC->(Dbdelete())
         MOV_BANC->(Qunlock())
      endif

      DEP_NIDT->(Qrlock())
      DEP_NIDT->(Dbdelete())
      DEP_NIDT->(Qunlock())
   endif
return

