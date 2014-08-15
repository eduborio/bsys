/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE TESOURARIA
// OBJETIVO...: LANCAMENTOS DE AVISOS BANCARIOS
// ANALISTA...:
// PROGRAMADOR: Eduardo Borio
// INICIO.....: NOVEMBRO DE 1997
// OBS........:
// ALTERACOES.:

function ts204
#include "inkey.ch"
#include "setcurs.ch"

private sBLOC1  := qlbloc("B204B","QBLOC.GLO")

BANCO->(Dbsetorder(3))
CCUSTO->(Dbsetorder(4))

/////////////////////////////////////////////////////////////////////////////
// MANUTENCAO DOS LANCAMENTOS DE CHEQUES PRE-DATADOS ________________________

AVIS_BAN->(qview({{"dtoc(Data)/Data"                    ,2},;
                  {"Codigo/C¢d."                        ,1},;
                  {"Ent_Sai/E/S"                        ,0},;
                  {"left(Historico,31)/Historico"       ,0},;
                  {"Valor/Valor"                        ,0}},"P",;
                  {NIL,"i_204a",NIL,NIL},;
                   NIL,"<I>ncluir  <C>onsultar   <A>lterar   <E>xcluir"))

return ""

function i204top
   AVIS_BAN->(Dbsetorder(2))
   AVIS_BAN->(dbseek(XDATA))
return
function i204bot
   AVIS_BAN->(Dbsetorder(2))
   AVIS_BAN->(qseekn(XDATA))
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAR NOME DO BANCO ________________________________________

function i_204b
  BANCO->(Dbseek(AVIS_BAN->Banco))
return left(BANCO->Descricao,20)

/////////////////////////////////////////////////////////////////////////////
// FUNCAO DE CONTROLE PRINCIPAL ANTES DE PROCESSAR A TECLA ACIONADA _________

function i_204a

   local nCURSOR := setcursor(1)

   parameters cOPCAO

   cOPCAO := upper(chr(cOPCAO))

//   if cOPCAO $ "AE" .and. AVIS_BAN->Data < CONFIG->Data_atual
//      qmensa("Data Encerrada. Acesso proibido!","B")
//      return.F.
//   endif

//   if cOPCAO == "I" .and. CONFIG->Data_ant < CONFIG->Data_atual
//      qmensa("Data Encerrada. Permissao Negada!","B")
//      return.F.
//   endif



   if cOPCAO $ XUSRA
      qlbloc(08,08,"B204A","QBLOC.GLO",1)
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

      qrsay ( XNIVEL++ , AVIS_BAN->Codigo            )
      qrsay ( XNIVEL++ , AVIS_BAN->Data              )
      qrsay ( XNIVEL++ , AVIS_BAN->Docto             )
      qrsay ( XNIVEL++ , AVIS_BAN->Banco             ) ; BANCO->(Dbseek(AVIS_BAN->Banco))
      qrsay ( XNIVEL++ , left(BANCO->Descricao,20)   )

      PLAN_FIN->(dbsetorder(3))
      qrsay ( XNIVEL++ , AVIS_BAN->Cod_plan          ) ; PLAN_FIN->(Dbseek(AVIS_BAN->Cod_plan))
      qrsay ( XNIVEL++ , iif(!empty(AVIS_BAN->Cod_plan),left(PLAN_FIN->Descricao,20),"") )

      qrsay ( XNIVEL++ , left(AVIS_BAN->Historico,40))
      qrsay ( XNIVEL++ , qabrev(AVIS_BAN->Ent_sai,"ES", {"Entrada","Sa¡da"}))
      PLAN->(dbsetorder(3))
      qrsay ( XNIVEL++ , AVIS_BAN->Conta_cont          ) ; PLAN->(Dbseek(AVIS_BAN->conta_cont))
      qrsay ( XNIVEL++ , left(PLAN->Descricao,15))
      qrsay ( XNIVEL++ , AVIS_BAN->Valor     , "@E 9,999,999.99"  )

   endif

   // CONSULTA  ______________________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || NIL                                           },NIL          })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDATA , "99/99/9999"            ) } ,"DATA"      })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDOCTO, "@!"                    ) } ,"DOCTO"     })

   aadd(aEDICAO,{{ || view_banco(-1,0,@fBANCO)                      },"BANCO"      })
   aadd(aEDICAO,{{ || NIL                                           },NIL          })

   aadd(aEDICAO,{{ || view_planfin(-1,0,@fCOD_PLAN)                 },"COD_PLAN"   })
   aadd(aEDICAO,{{ || NIL                                           },NIL          })

   aadd(aEDICAO,{{ || qgetx(-1,0,@fHISTORICO , "@!@S40"           ) } ,"HISTORICO" })

   aadd(aEDICAO,{{ || qesco(-1,0,@fENT_SAI ,sBLOC1                 )} ,"ENT_SAI"   })

//   aadd(aEDICAO,{{ || view_ccusto(-1,0,@fCENTRO)                    },"CENTRO"     })
//   aadd(aEDICAO,{{ || NIL                                           },NIL          })

   aadd(aEDICAO,{{ || view_plan(-1,0,@fConta_cont)                    },"CONTA_CONT"   })
   aadd(aEDICAO,{{ || NIL                                           },NIL          })

   aadd(aEDICAO,{{ || qgetx(-1,0,@fVALOR    , "@E 9,999,999.99"   ) } ,"VALOR"     })

   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   AVIS_BAN->(qpublicfields())

   iif(cOPCAO=="I",AVIS_BAN->(qinitfields()),AVIS_BAN->(qcopyfields()))

   XNIVEL := 2
   XFLAG  := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; AVIS_BAN->(qreleasefields()) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif

   fDATA_CONT := XDATA

   if AVIS_BAN->(iif(cOPCAO=="I",qappend(),qrlock())) .and. CONFIG->(qrlock())

      // AQUI INCREMENTA CODIGO DA INCLUSAO DO CHEQUE _____________________

      if cOPCAO == "I"
         replace CONFIG->Cod_aviso with CONFIG->Cod_aviso+1
         qmensa("C¢digo Gerado: "+strzero(CONFIG->Cod_aviso,5),"B")
         fCODIGO := strzero(CONFIG->Cod_aviso,5)
      endif

      // AGORA GRAVA E DESTRAVA ARQUIVO _____________________________________

//      fDATA := XDATA

      AVIS_BAN->(qreplacefields())

      if cOPCAO == "I" .and. MOV_BANC->(qappend())
         replace MOV_BANC->Data with fDATA
         replace MOV_BANC->Data_comp with fDATA
         replace MOV_BANC->Cod_banco with fBANCO
         replace MOV_BANC->Historico with fHISTORICO
         replace MOV_BANC->Num_docto with fDOCTO
         replace MOV_BANC->Concilia  with "0"
         if fENT_SAI = "E"
            replace MOV_BANC->Entrada with fVALOR
            replace MOV_BANC->Saida   with 0
         else
            replace MOV_BANC->Saida   with fVALOR
            replace MOV_BANC->Entrada with 0
         endif
         replace MOV_BANC->Internal  with "AVBC"+fCODIGO
      endif

      if cOPCAO == "A"
         MOV_BANC->(dbsetorder(4))
         if MOV_BANC->(Dbseek("AVBC"+AVIS_BAN->Codigo))
            if MOV_BANC->(qrlock())
               replace MOV_BANC->Data with fDATA
               replace MOV_BANC->Data_comp with fDATA
               replace MOV_BANC->Cod_banco with fBANCO
               replace MOV_BANC->Historico with fHISTORICO
               replace MOV_BANC->Num_docto with fDOCTO
               replace MOV_BANC->Concilia  with "0"
               if fENT_SAI = "E"
                  replace MOV_BANC->Entrada with fVALOR
                  replace MOV_BANC->Saida   with 0
               else
                  replace MOV_BANC->Saida   with fVALOR
                  replace MOV_BANC->Entrada with 0
               endif
               MOV_BANC->(qunlock())
            endif
         endif
      endif


   else
      iif(cOPCAO=="I",qm1(),qm2())
   endif

   dbunlockall()

   if cOPCAO == "I" ; keyboard "I" ; endif

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

      case cCAMPO == "HISTORICO"

           if empty(fHISTORICO) ; return .F. ; endif


      case cCAMPO == "CENTRO"

           if empty(fCENTRO) ; return .F. ; endif

           if ! CCUSTO->(dbseek(fCENTRO))
               qmensa("Centro de Custo n„o Cadastrada !","B")
               return .F.
           endif

           qrsay(XNIVEL+1,left(CCUSTO->Descricao,20))

      case cCAMPO == "BANCO"

           if empty(fBANCO) ; return .F. ; endif

           if ! BANCO->(dbseek(fBANCO:=strzero(val(fBANCO),5)))
               qmensa("Banco n„o Cadastrado !","B")
               return .F.
           endif

           if empty(BANCO->Conta_cont)
              qmensa("Banco n„o possui Conta Cont bil Cadastrada !! Verifique...","B")
           endif

           qrsay(XNIVEL+1,left(BANCO->Descricao,20))

      case cCAMPO == "COD_PLAN"

           if ! empty(fCOD_PLAN)
              qrsay(XNIVEL,fCOD_PLAN := strzero(val(fCOD_PLAN),5))
              PLAN_FIN->(dbsetorder(3))
              if ! PLAN_FIN->(dbseek(fCOD_PLAN))
                 qmensa("Conta Financeira n„o encontrada !","B")
                 return .F.
              endif
              qrsay(XNIVEL+1,left(PLAN_FIN->Descricao,45))
           else
              qmensa("Campo Obrigatorio!!","BL")
              return .F.
           endif


      case cCAMPO == "CONTA_CONT"

           if empty(fCONTA_CONT) ; return .F. ; endif
           PLAN->(dbsetorder(3))

           if ! PLAN->(dbseek(fCONTA_CONT))
               qmensa("Conta Cont bil n„o Cadastrada !","B")
               return .F.
           endif

           qrsay(XNIVEL+1,left(PLAN->Descricao,20))

      case cCAMPO == "ENT_SAI"
           if empty(fENT_SAI) ; return .F. ; endif
           qrsay(XNIVEL,qabrev(fENT_SAI,"ES",{"Entrada","Sa¡da"}))

   endcase

return .T.

static function i_exclusao

   if QConf("Confirma exclusao deste Aviso Bancario?","B")
      MOV_BANC->(Dbsetorder(4))
      if MOV_BANC->(Dbseek("AVBC"+AVIS_BAN->Codigo))
         MOV_BANC->(Qrlock())
         MOV_BANC->(Dbdelete())
         MOV_BANC->(Qunlock())
      endif

      AVIS_BAN->(Qrlock())
      AVIS_BAN->(Dbdelete())
      AVIS_BAN->(Qunlock())
   endif
return

