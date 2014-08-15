/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE TESOURARIA
// OBJETIVO...: LANCAMENTOS DE RECEBIMENTOS A VISTA
// ANALISTA...:
// PROGRAMADOR: EDUARDO BORIO
// INICIO.....: NOVEMBRO DE 1998
// OBS........:
// ALTERACOES.:
function ts208

#include "inkey.ch"
#include "setcurs.ch"

private sBLOC1  := qlbloc("B208B","QBLOC.GLO")

BANCO->(Dbsetorder(3))
CCUSTO->(Dbsetorder(4))

/////////////////////////////////////////////////////////////////////////////
// MANUTENCAO DOS LANCAMENTOS DE CHEQUES PRE-DATADOS ________________________

REC_VIST->(qview({{"dtoc(data)/Data"                    ,2},;
                  {"Codigo/C¢d."                        ,1},;
                  {"left(Historico,30)/Historico"       ,0},;
                  {"Duplicata/Duplicata"                ,0},;
                  {"Valor/Valor"                        ,0}},"P",;
                  {NIL,"i_208a",NIL,NIL},;
                   NIL,"<I>ncluir/<C>onsultar/<E>xcluir/<A>lterar"))

return ""

function i208top
   REC_VIST->(Dbsetorder(2))
   REC_VIST->(dbseek(XDATA))
return
function i208bot
   REC_VIST->(Dbsetorder(2))
   REC_VIST->(qseekn(XDATA))
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAR NOME DO BANCO ________________________________________

function i_208b
  TIPOCONT->(Dbseek(REC_VIST->Tipocont))
return left(TIPOCONT->Descricao,42)

/////////////////////////////////////////////////////////////////////////////
// FUNCAO DE CONTROLE PRINCIPAL ANTES DE PROCESSAR A TECLA ACIONADA _________

function i_208a

   local nCURSOR := setcursor(1)

   parameters cOPCAO

   cOPCAO := upper(chr(cOPCAO))

   //if cOPCAO $ "AE" .and. REC_VIST->Data < CONFIG->Data_atual
   //   qmensa("Data encerrada. Permissao Negada!","B")
   //   return .F.
   //endif

   //if cOPCAO == "I" .and. CONFIG->Data_ant < CONFIG->Data_atual
   //   qmensa("Data Encerrada. Permissao Negada!","B")
   //   return.F.
   //endif



   if cOPCAO $ "ICEA"
      qlbloc(08,03,"B208A","QBLOC.GLO",1)
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

      qrsay ( XNIVEL++ , REC_VIST->Codigo            )
      qrsay ( XNIVEL++ , REC_VIST->Data              )

      qrsay ( XNIVEL++ , REC_VIST->cod_plan          ) ; PLAN_FIN->(Dbseek(REC_VIST->cod_plan))
      qrsay ( XNIVEL++ , left(PLAN_FIN->Descricao,30))

      PLAN->(dbsetorder(3))
      qrsay ( XNIVEL++ , REC_VIST->conta_cont       ) ; PLAN->(Dbseek(REC_VIST->conta_cont))
      qrsay ( XNIVEL++ , left(PLAN->Descricao,30))


      qrsay ( XNIVEL++ , REC_VIST->Duplicata         )
      qrsay ( XNIVEL++ , REC_VIST->Valor     , "@E 9,999,999.99"  )
      qrsay ( XNIVEL++ , qabrev(REC_VIST->Forma,"COE", {"Cheque","Ordem","Esp‚cie"}))
      qrsay ( XNIVEL++ , REC_VIST->Cod_fav           )

      qrsay ( XNIVEL++ , left(REC_VIST->Favorecido,40))
      qrsay ( XNIVEL++ , left(REC_VIST->Historico,40))

   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || NIL                                           },NIL          })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDATA                            )},"DATA"       })


   aadd(aEDICAO,{{ || view_planfinrec(-1,0,@fCOD_PLAN)              },"COD_PLAN"   })
   aadd(aEDICAO,{{ || NIL                                           },NIL          })

   aadd(aEDICAO,{{ || view_plan(-1,0,@fCONTA_CONT)                  },"CONTA_CONT" })
   aadd(aEDICAO,{{ || NIL                                           },NIL          })


   aadd(aEDICAO,{{ || qgetx(-1,0,@fDUPLICATA                       )},"DUPLICATA"  })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fVALOR    , "@E 9,999,999.99"    )},"VALOR"      })
   aadd(aEDICAO,{{ || qesco(-1,0,@fFORMA ,sBLOC1                   )},"FORMA"      })
   aadd(aEDICAO,{{ || view_cli(-1,0,@fCOD_FAV)                  },"COD_FAV"      })

   aadd(aEDICAO,{{ || qgetx(-1,0,@fFAVORECIDO , "@!S40"               )},"FAVORECIDO" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fHISTORICO , "@!@S40"            )},"HISTORICO"  })
   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   REC_VIST->(qpublicfields())

   iif(cOPCAO=="I",REC_VIST->(qinitfields()),REC_VIST->(qcopyfields()))

   XNIVEL := 2
   XFLAG  := .T.
//   fDATA  := XDATA

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; REC_VIST->(qreleasefields()) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif

   if REC_VIST->(iif(cOPCAO=="I",qappend(),qrlock())) .and. CONFIG->(qrlock())

      // AQUI INCREMENTA CODIGO DA INCLUSAO DO CHEQUE _____________________

      if cOPCAO == "I"
         replace CONFIG->Cod_rec_vi with CONFIG->Cod_rec_vi+1
         qmensa("C¢digo Gerado: "+strzero(CONFIG->Cod_rec_vi,5),"B")
         fCODIGO := strzero(CONFIG->Cod_rec_vi,5)
      endif

      // AGORA GRAVA E DESTRAVA ARQUIVO _____________________________________

  //    fDATA := XDATA

      REC_VIST->(qreplacefields())

      if cOPCAO == "I" .and. MOV_CAIX->(qappend())
         replace MOV_CAIX->Data with fDATA
         replace MOV_CAIX->Historico with "RECEBIMENTOS A VISTA"
         replace MOV_CAIX->Entrada   with fVALOR
         replace MOV_CAIX->Num_docto with left(fDUPLICATA,6)
         replace MOV_CAIX->Internal  with "RCVS"+fCODIGO
      endif

      if cOPCAO == "A"
         MOV_CAIX->(Dbsetorder(2))
         if MOV_CAIX->(Dbseek("RCVS"+REC_VIST->Codigo)) .and. MOV_CAIX->(Qrlock())
            replace MOV_CAIX->Data with fDATA
            replace MOV_CAIX->Historico with "RECEBIMENTOS A VISTA"
            replace MOV_CAIX->Entrada   with fVALOR
            replace MOV_CAIX->Num_docto with left(fDUPLICATA,6)
            MOV_CAIX->(qunlock())
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

      case cCAMPO == "FORM_PGTO"

           if empty(fFORM_PGTO) ; return .F. ; endif

           if ! FORM_PGT->(dbseek(fFORM_PGTO:=strzero(val(fFORM_PGTO),5)))
               qmensa("Forma de Pagamento n„o Cadastrada !","B")
               return .F.
           endif

           qrsay(XNIVEL+1,left(FORM_PGT->Descricao,20))

      case cCAMPO == "TIPOCONT"

           if empty(fTIPOCONT) ; return .F. ; endif

           if ! TIPOCONT->(dbseek(fTIPOCONT))
               qmensa("Tipo Cont bil n„o Cadastrado !","B")
               return .F.
           endif

           qrsay(XNIVEL+1,left(TIPOCONT->Descricao,20))


      case cCAMPO == "CONTA_CONT"

           if empty(fCONTA_CONT) ; return .F. ; endif

           PLAN->(dbsetorder(3))
           if ! PLAN->(dbseek(fCONTA_CONT))
               qmensa("Conta Cont bil n„o Cadastrada !","B")
               return .F.
           endif

           qrsay(XNIVEL+1,left(PLAN->Descricao,30))


      case cCAMPO == "COD_PLAN"

           if ! empty(fCOD_PLAN)
              qrsay(XNIVEL,fCOD_PLAN := strzero(val(fCOD_PLAN),5))
              PLAN_FIN->(dbsetorder(3))
              if ! PLAN_FIN->(dbseek(fCOD_PLAN))
                 qmensa("Conta Financeira n„o encontrada !","B")
                 return .F.
              endif
              qrsay(XNIVEL+1,left(PLAN_FIN->Descricao,30))
           else
              qmensa("Campo Obrigatorio!!","BL")
              return .F.
           endif


      case cCAMPO == "SERIE"

           if empty(fSERIE) ; return .F. ; endif

           if ! SERIE->(dbseek(fSERIE))
               qmensa("S‚rie n„o Cadastrada !","B")
               return .F.
           endif

           qrsay(XNIVEL+1,left(SERIE->Descricao,10))

      case cCAMPO == "ESPECIE"

           if empty(fESPECIE) ; return .F. ; endif

           if ! ESPECIE->(dbseek(fESPECIE))
               qmensa("Esp‚cie n„o Cadastrada !","B")
               return .F.
           endif

           qrsay(XNIVEL+1,left(ESPECIE->Descricao,10))

      case cCAMPO == "FILIAL"

           if empty(fFILIAL) ; return .F. ; endif

           if ! FILIAL->(dbseek(fFILIAL))
               qmensa("Filial n„o Cadastrada !","B")
               return .F.
           endif

           qrsay(XNIVEL+1,left(FILIAL->Razao,20))

      case cCAMPO == "CENTRO"

           if empty(fCENTRO) ; return .F. ; endif

           if ! CCUSTO->(dbseek(fCENTRO))
               qmensa("Centro de Custo n„o Cadastrada !","B")
               return .F.
           endif

           qrsay(XNIVEL+1,left(CCUSTO->Descricao,20))

      case cCAMPO == "FORMA"
           if empty(fFORMA) ; return .F. ; endif
           qrsay(XNIVEL,qabrev(fFORMA,"COE",{"Cheque","Ordem","Especie"}))

      case cCAMPO == "COD_FAV"


           if ! CLI1->(dbseek(fCOD_FAV:=strzero(val(fCOD_FAV),5)))
               qmensa("Cliente n„o Cadastrado !","B")
               qmensa("")
           else
               fFAVORECIDO := CLI1->Razao
               qrsay(XNIVEL+1,left(CLI1->Razao,40))

           endif


   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXCLUIR BANCO ________________________________________________

return

static function i_exclusao

   if QConf("Confirma exclusao deste Recebimento a Vista?","B")

      MOV_CAIX->(Dbsetorder(2))
      if MOV_CAIX->(Dbseek("RCVS"+REC_VIST->Codigo))
         MOV_CAIX->(Qrlock())
         MOV_CAIX->(Dbdelete())
         MOV_CAIX->(Qunlock())
      endif

      REC_VIST->(Qrlock())
      REC_VIST->(Dbdelete())
      REC_VIST->(Qunlock())
   endif
return

