/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE TESOURARIA
// OBJETIVO...: LANCAMENTOS DE RENDIMENTO DE APLICACOES
// ANALISTA...: Eduardo Borio
// PROGRAMADOR: Eduardo Borio
// INICIO.....: Setembro de 2006
// OBS........:
// ALTERACOES.:
function ts213

#include "inkey.ch"
#include "setcurs.ch"

private sBLOC1  := qlbloc("B213B","QBLOC.GLO")

BANCO->(Dbsetorder(3))
CCUSTO->(Dbsetorder(4))

/////////////////////////////////////////////////////////////////////////////
// MANUTENCAO DOS LANCAMENTOS DE CHEQUES PRE-DATADOS ________________________

REND_FIN->(qview({{"Codigo/C¢d."                        ,1},;
                  {"i_213b()/Banco"                     ,0},;
                  {"i_213c()/Instituicao"               ,0},;
                  {"Valor/Valor"                        ,0},;
                  {"left(Historico,31)/Historico"       ,0}},"P",;
                  {NIL,"i_213a",NIL,NIL},;
                  {"Data==XDATA",{||i213top()},{||i213bot()}},;
                  "<I>ncluir  <C>onsultar   <A>lterar   <E>xcluir"))

return ""

function i213top
   REND_FIN->(Dbsetorder(2))
   REND_FIN->(dbseek(dtos(XDATA)))
return
function i213bot
   REND_FIN->(Dbsetorder(2))
   REND_FIN->(qseekn(dtos(XDATA)))
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAR NOME DO BANCO ________________________________________

function i_213b
  BANCO->(Dbseek(REND_FIN->Cod_Banco))
return left(BANCO->Descricao,20)

function i_213c
  INSTITU->(Dbseek(REND_FIN->Cod_inst))
return left(INSTITU->Nome,20)


/////////////////////////////////////////////////////////////////////////////
// FUNCAO DE CONTROLE PRINCIPAL ANTES DE PROCESSAR A TECLA ACIONADA _________

function i_213a

   local nCURSOR := setcursor(1)

   parameters cOPCAO

   cOPCAO := upper(chr(cOPCAO))

   //if cOPCAO $ "AE" .and. REND_FIN->Data < CONFIG->Data_atual
   //   qmensa("Data Encerrada. Acesso proibido!","B")
   //   return.F.
   //endif

   //if cOPCAO == "I" .and. CONFIG->Data_ant < CONFIG->Data_atual
   //   qmensa("Data Encerrada. Permissao Negada!","B")
   //   return.F.
   //endif



   if cOPCAO $ XUSRA
      qlbloc(08,08,"B213A","QBLOC.GLO",1)
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

      qrsay ( XNIVEL++ , REND_FIN->Codigo            )
      qrsay ( XNIVEL++ , REND_FIN->Docto             )
      qrsay ( XNIVEL++ , REND_FIN->Cod_Banco         ) ; BANCO->(Dbseek(REND_FIN->Cod_Banco))
      qrsay ( XNIVEL++ , left(BANCO->Descricao,20)   )
      qrsay ( XNIVEL++ , REND_FIN->Cod_inst          ) ; INSTITU->(Dbseek(REND_FIN->Cod_inst))
      qrsay ( XNIVEL++ , left(INSTITU->Nome,20)   )
      qrsay ( XNIVEL++ , left(REND_FIN->Historico,40))
      qrsay ( XNIVEL++ , REND_FIN->Centro            ) ; CCUSTO->(Dbseek(REND_FIN->Centro))
      qrsay ( XNIVEL++ , left(CCUSTO->Descricao,15))
      qrsay ( XNIVEL++ , REND_FIN->Tipocont          ) ; TIPOCONT->(Dbseek(REND_FIN->Tipocont))
      qrsay ( XNIVEL++ , left(TIPOCONT->Descricao,15))
      qrsay ( XNIVEL++ , REND_FIN->Valor     , "@E 9,999,999.99"  )

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

   REND_FIN->(qpublicfields())

   iif(cOPCAO=="I",REND_FIN->(qinitfields()),REND_FIN->(qcopyfields()))

   XNIVEL := 2
   XFLAG  := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; REND_FIN->(qreleasefields()) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif

   fDATA_CONT := XDATA

   if REND_FIN->(iif(cOPCAO=="I",qappend(),qrlock())) .and. CONFIG->(qrlock())

      // AQUI INCREMENTA CODIGO DA INCLUSAO DO CHEQUE _____________________

      if cOPCAO == "I"
         replace CONFIG->Cod_rend with CONFIG->Cod_rend+1
         qmensa("C¢digo Gerado: "+strzero(CONFIG->Cod_rend,5),"B")
         fCODIGO := strzero(CONFIG->Cod_rend,5)
      endif

      // AGORA GRAVA E DESTRAVA ARQUIVO _____________________________________

      fDATA := XDATA

      REND_FIN->(qreplacefields())

      if cOPCAO == "I" .and. MOV_BANC->(qappend())
         replace MOV_BANC->Data with fDATA
         replace MOV_BANC->Cod_banco with fCOD_BANCO
         replace MOV_BANC->Historico with "RENDIMENTO DE APLICACAO - "+rtrim(fHISTORICO)
         replace MOV_BANC->Num_docto with fDOCTO
         replace MOV_BANC->Concilia  with "0"
         replace MOV_BANC->Entrada   with fVALOR
         replace MOV_BANC->Internal  with "REND"+fCODIGO
      endif

     // if cOPCAO == "I" .and. MOV_FIN->(qappend())
     //    replace MOV_FIN->Data with fDATA
     //    replace MOV_FIN->Cod_inst  with fCod_inst
     //    replace MOV_FIN->Historico with "RENDIMENTO DE APLICACAO - "+rtrim(fHISTORICO)
    //     replace MOV_FIN->Num_docto with fDOCTO
    //     replace MOV_FIN->Concilia  with "0"
    //     replace MOV_FIN->Entrada   with fVALOR
    //     replace MOV_FIN->Internal  with "REND"+fCODIGO
    //  endif


      if cOPCAO == "A"
         MOV_BANC->(dbsetorder(4))
         if MOV_BANC->(Dbseek("REND"+REND_FIN->Codigo))
            if MOV_BANC->(qrlock())
               replace MOV_BANC->Data with fDATA
               replace MOV_BANC->Cod_banco with fCOD_BANCO
               replace MOV_BANC->Historico with "RENDIMENTO DE APLICACAO - "+rtrim(fHISTORICO)
               replace MOV_BANC->Num_docto with fDOCTO
               replace MOV_BANC->Concilia  with "0"
               replace MOV_BANC->Entrada   with fVALOR
               MOV_BANC->(qunlock())
            endif
         endif
      endif

      //if cOPCAO == "A"
      //   MOV_FIN->(dbsetorder(4))
      //   if MOV_FIN->(Dbseek("REND"+REND_FIN->Codigo))
      //      if MOV_FIN->(qrlock())
      //         replace MOV_FIN->Data with fDATA
      //         replace MOV_FIN->Cod_banco with fCOD_INST
      //         replace MOV_FIN->Historico with "RENDIMENTO DE APLICACAO - "+rtrim(fHISTORICO)
      //         replace MOV_FIN->Num_docto with fDOCTO
      //         replace MOV_FIN->Concilia  with "0"
      //         replace MOV_FIN->Entrada   with fVALOR
     //          MOV_FIN->(qunlock())
      //      endif
      //   endif
     // endif



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

   if QConf("Confirma exclusao deste Rendimento de Aplica‡Æo Financeira?","B")
      MOV_BANC->(Dbsetorder(4))
      if MOV_BANC->(Dbseek("REND"+REND_FIN->Codigo))
         MOV_BANC->(Qrlock())
         MOV_BANC->(Dbdelete())
         MOV_BANC->(Qunlock())
      endif

      //MOV_FIN->(Dbsetorder(4))
      //if MOV_FIN->(Dbseek("REND"+REND_FIN->Codigo))
      //   MOV_FIN->(Qrlock())
      //   MOV_FIN->(Dbdelete())
      //   MOV_FIN->(Qunlock())
      //endif


      REND_FIN->(Qrlock())
      REND_FIN->(Dbdelete())
      REND_FIN->(Qunlock())
   endif
return

