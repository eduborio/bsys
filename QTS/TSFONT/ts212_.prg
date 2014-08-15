/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE TESOURARIA
// OBJETIVO...: LANCAMENTOS DE AVISOS BANCARIOS
// ANALISTA...: Eduardo Borio
// PROGRAMADOR: Eduardo Borio
// INICIO.....: Setembro de 2006
// OBS........:
// ALTERACOES.:
function ts212

#include "inkey.ch"
#include "setcurs.ch"

private sBLOC1  := qlbloc("B212B","QBLOC.GLO")

BANCO->(Dbsetorder(3))
CCUSTO->(Dbsetorder(4))

/////////////////////////////////////////////////////////////////////////////
// MANUTENCAO DOS LANCAMENTOS DE RESGATES DE APLICACOES______________________

RESG_FIN->(qview({{"Codigo/C¢d."                        ,1},;
                  {"i_212b()/Banco"                     ,0},;
                  {"i_212c()/Instituicao"               ,0},;
                  {"Valor/Valor"                        ,0},;
                  {"left(Historico,31)/Historico"       ,0}},"P",;
                  {NIL,"i_212a",NIL,NIL},;
                  {"Data==XDATA",{||i212top()},{||i212bot()}},;
                  "<I>ncluir  <C>onsultar   <A>lterar   <E>xcluir"))

return ""

function i212top
   RESG_FIN->(Dbsetorder(2))
   RESG_FIN->(dbseek(dtos(XDATA)))
return

function i212bot
   RESG_FIN->(Dbsetorder(2))
   RESG_FIN->(qseekn(dtos(XDATA)))
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAR NOME DO BANCO ________________________________________

function i_212b
  BANCO->(Dbseek(RESG_FIN->Cod_Banco))
return left(BANCO->Descricao,20)

function i_212c
  INSTITU->(Dbseek(RESG_FIN->Cod_inst))
return left(INSTITU->Nome,20)


/////////////////////////////////////////////////////////////////////////////
// FUNCAO DE CONTROLE PRINCIPAL ANTES DE PROCESSAR A TECLA ACIONADA _________

function i_212a

   local nCURSOR := setcursor(1)

   parameters cOPCAO

   cOPCAO := upper(chr(cOPCAO))

   //if cOPCAO $ "AE" .and. RESG_FIN->Data < CONFIG->Data_atual
   //   qmensa("Data Encerrada. Acesso proibido!","B")
   //   return.F.
   //endif

   //if cOPCAO == "I" .and. CONFIG->Data_ant < CONFIG->Data_atual
   //   qmensa("Data Encerrada. Permissao Negada!","B")
   //   return.F.
   //endif



   if cOPCAO $ XUSRA
      qlbloc(08,08,"B212A","QBLOC.GLO",1)
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

      qrsay ( XNIVEL++ , RESG_FIN->Codigo            )
      qrsay ( XNIVEL++ , RESG_FIN->Docto             )
      qrsay ( XNIVEL++ , RESG_FIN->Cod_Banco         ) ; BANCO->(Dbseek(RESG_FIN->Cod_Banco))
      qrsay ( XNIVEL++ , left(BANCO->Descricao,20)   )
      qrsay ( XNIVEL++ , RESG_FIN->Cod_inst          ) ; INSTITU->(Dbseek(RESG_FIN->Cod_inst))
      qrsay ( XNIVEL++ , left(INSTITU->Nome,20)   )
      qrsay ( XNIVEL++ , left(RESG_FIN->Historico,40))
      qrsay ( XNIVEL++ , RESG_FIN->Centro            ) ; CCUSTO->(Dbseek(RESG_FIN->Centro))
      qrsay ( XNIVEL++ , left(CCUSTO->Descricao,15))
      qrsay ( XNIVEL++ , RESG_FIN->Tipocont          ) ; TIPOCONT->(Dbseek(RESG_FIN->Tipocont))
      qrsay ( XNIVEL++ , left(TIPOCONT->Descricao,15))
      qrsay ( XNIVEL++ , RESG_FIN->Valor     , "@E 9,999,999.99"  )

   endif

   // CONSULTA  ______________________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || NIL                                           },NIL          })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDOCTO, "@!"                    ) } ,"DOCTO"     })

   aadd(aEDICAO,{{ || view_banco(-1,0,@fCOD_BANCO)                  },"BANCO"      })
   aadd(aEDICAO,{{ || NIL                                           },NIL          })

   aadd(aEDICAO,{{ || view_inst(-1,0,@fCOD_INST)                   },"INSTITU"      })
   aadd(aEDICAO,{{ || NIL                                           },NIL          })


   aadd(aEDICAO,{{ || qgetx(-1,0,@fHISTORICO , "@!@S40"           ) } ,"HISTORICO" })

   aadd(aEDICAO,{{ || view_ccusto(-1,0,@fCENTRO)                    },"CENTRO"     })
   aadd(aEDICAO,{{ || NIL                                           },NIL          })

   aadd(aEDICAO,{{ || view_tipo(-1,0,@fTIPOCONT)                    },"TIPOCONT"   })
   aadd(aEDICAO,{{ || NIL                                           },NIL          })

   aadd(aEDICAO,{{ || qgetx(-1,0,@fVALOR    , "@E 9,999,999.99"   ) } ,"VALOR"     })

   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   RESG_FIN->(qpublicfields())

   iif(cOPCAO=="I",RESG_FIN->(qinitfields()),RESG_FIN->(qcopyfields()))

   XNIVEL := 2
   XFLAG  := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; RESG_FIN->(qreleasefields()) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif

   fDATA_CONT := XDATA

   if RESG_FIN->(iif(cOPCAO=="I",qappend(),qrlock())) .and. CONFIG->(qrlock())

      // AQUI INCREMENTA CODIGO DA INCLUSAO DO CHEQUE _____________________

      if cOPCAO == "I"
         replace CONFIG->Cod_resg with CONFIG->Cod_resg+1
         qmensa("C¢digo Gerado: "+strzero(CONFIG->Cod_resg,5),"B")
         fCODIGO := strzero(CONFIG->Cod_resg,5)
      endif

      // AGORA GRAVA E DESTRAVA ARQUIVO _____________________________________

      fDATA := XDATA

      RESG_FIN->(qreplacefields())

      if cOPCAO == "I" .and. MOV_BANC->(qappend())
         replace MOV_BANC->Data with fDATA
         replace MOV_BANC->Cod_banco with fCOD_BANCO
         replace MOV_BANC->Historico with "RESGATE DE APLICACAO - "+rtrim(fHISTORICO)
         replace MOV_BANC->Num_docto with fDOCTO
         replace MOV_BANC->Concilia  with "0"
         replace MOV_BANC->Entrada   with fVALOR
         replace MOV_BANC->Internal  with "RESG"+fCODIGO
      endif

      if cOPCAO == "I" .and. MOV_FIN->(qappend())
         replace MOV_FIN->Data with fDATA
         replace MOV_FIN->Cod_inst  with fCod_inst
         replace MOV_FIN->Historico with "RESGATE DE APLICACAO - "+rtrim(fHISTORICO)
         replace MOV_FIN->Num_docto with fDOCTO
         replace MOV_FIN->Concilia  with "0"
         replace MOV_FIN->Saida     with fVALOR
         replace MOV_FIN->Internal  with "RESG"+fCODIGO
      endif


      if cOPCAO == "A"
         MOV_BANC->(dbsetorder(4))
         if MOV_BANC->(Dbseek("RESG"+RESG_FIN->Codigo))
            if MOV_BANC->(qrlock())
               replace MOV_BANC->Data with fDATA
               replace MOV_BANC->Cod_banco with fCOD_BANCO
               replace MOV_BANC->Historico with "RESGATE DE APLICACAO - "+rtrim(fHISTORICO)
               replace MOV_BANC->Num_docto with fDOCTO
               replace MOV_BANC->Concilia  with "0"
               replace MOV_BANC->Entrada   with fVALOR
               MOV_BANC->(qunlock())
            endif
         endif
      endif

      if cOPCAO == "A"
         MOV_FIN->(dbsetorder(4))
         if MOV_FIN->(Dbseek("RESG"+RESG_FIN->Codigo))
            if MOV_FIN->(qrlock())
               replace MOV_FIN->Data with fDATA
               replace MOV_FIN->Cod_banco with fCOD_INST
               replace MOV_FIN->Historico with "RESGATE DE APLICACAO - "+rtrim(fHISTORICO)
               replace MOV_FIN->Num_docto with fDOCTO
               replace MOV_FIN->Concilia  with "0"
               replace MOV_FIN->Saida     with fVALOR
               MOV_FIN->(qunlock())
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

      case cCAMPO == "CENTRO"

           if empty(fCENTRO) ; return .F. ; endif

           if ! CCUSTO->(dbseek(fCENTRO))
               qmensa("Centro de Custo n„o Cadastrada !","B")
               return .F.
           endif

           qrsay(XNIVEL+1,left(CCUSTO->Descricao,20))

      case cCAMPO == "BANCO"

           if empty(fCOD_BANCO) ; return .F. ; endif

           if ! BANCO->(dbseek(fCOD_BANCO:=strzero(val(fCOD_BANCO),5)))
               qmensa("Banco n„o Cadastrado !","B")
               return .F.
           endif

           if empty(BANCO->Conta_cont)
              qmensa("Banco n„o possui Conta Cont bil Cadastrada !! Verifique...","B")
           endif

           qrsay(XNIVEL+1,left(BANCO->Descricao,20))

      case cCAMPO == "INSTITU"

           if empty(fCOD_INST) ; return .F. ; endif

           if ! INSTITU->(dbseek(fCOD_INST:=strzero(val(fCOD_INST),5)))
               qmensa("Banco n„o Cadastrado !","B")
               return .F.
           endif

           if empty(INSTITU->Conta_cont)
              qmensa("Institui‡Æo n„o possui Conta Cont bil Cadastrada !! Verifique...","B")
           endif

           qrsay(XNIVEL+1,left(INSTITU->Nome,20))



      case cCAMPO == "TIPOCONT"

           if empty(fTIPOCONT) ; return .F. ; endif

           if ! TIPOCONT->(dbseek(fTIPOCONT))
               qmensa("Tipo Cont bil n„o Cadastrado !","B")
               return .F.
           endif

           qrsay(XNIVEL+1,left(TIPOCONT->Descricao,20))


   endcase

return .T.

static function i_exclusao

   if QConf("Confirma exclusao deste Resgate  de Aplica‡Æo Financeira?","B")
      MOV_BANC->(Dbsetorder(4))
      if MOV_BANC->(Dbseek("RESG"+RESG_FIN->Codigo))
         MOV_BANC->(Qrlock())
         MOV_BANC->(Dbdelete())
         MOV_BANC->(Qunlock())
      endif

      MOV_FIN->(Dbsetorder(4))
      if MOV_FIN->(Dbseek("RESG"+RESG_FIN->Codigo))
         MOV_FIN->(Qrlock())
         MOV_FIN->(Dbdelete())
         MOV_FIN->(Qunlock())
      endif


      RESG_FIN->(Qrlock())
      RESG_FIN->(Dbdelete())
      RESG_FIN->(Qunlock())
   endif
return

