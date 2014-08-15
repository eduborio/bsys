/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE TESOURARIA
// OBJETIVO...: LANCAMENTOS DE PAGAMENTOS A VISTA
// ANALISTA...:
// PROGRAMADOR: Eduardo Borio
// INICIO.....: Setembro de 2006
// OBS........:
// ALTERACOES.:
function ts214

#include "inkey.ch"
#include "setcurs.ch"

private sBLOC1  := qlbloc("B207B","QBLOC.GLO")

BANCO->(Dbsetorder(3))
CCUSTO->(Dbsetorder(4))

/////////////////////////////////////////////////////////////////////////////
// MANUTENCAO DOS LANCAMENTOS DE CHEQUES PRE-DATADOS ________________________

AD_VIAG->(qview({{"Codigo/C¢d."                         ,1},;
                  {"Data/Data"                          ,2},;
                  {"left(Favorecido,25)/Nome"           ,3},;
                  {"Valor/Valor"                    ,0}},"P",;
                  {NIL,"i_214a",NIL,NIL},;
                  {"DATA==XDATA",{||i214top()},{||i214bot()}},;
                  "<I>ncluir <C>onsultar <A>lterar  <E>xcluir"))

return ""

function i214top
   AD_VIAG->(Dbsetorder(2))
   AD_VIAG->(dbseek(dtos(XDATA)))
return

function i214bot
   AD_VIAG->(Dbsetorder(2))
   AD_VIAG->(qseekn(dtos(XDATA)))
return



/////////////////////////////////////////////////////////////////////////////
// FUNCAO DE CONTROLE PRINCIPAL ANTES DE PROCESSAR A TECLA ACIONADA _________

function i_214a

   local nCURSOR := setcursor(1)

   parameters cOPCAO

   cOPCAO := upper(chr(cOPCAO))

   //if cOPCAO $ "AE" .and. AD_VIAG->Data < CONFIG->Data_atual
   //   qmensa("Data encerrada. Permissao Negada!","B")
   //   return .F.
   //endif

   //if cOPCAO == "I" .and. CONFIG->Data_ant < CONFIG->Data_atual
   //   qmensa("Data Encerrada. Permissao Negada!","B")
   //   return.F.
   //endif



   if cOPCAO $ "IAMCE"
      qlbloc(08,03,"B214A","QBLOC.GLO",1)
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
   local bESCAPE := {||empty(fTIPOCONT).or.(XNIVEL==2.and.!XFLAG).or.;
                       (XNIVEL==2.and.lastkey()==27).or.;
                       (XNIVEL==2.and.cOPCAO=="A".and.!XFLAG)}

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"

      XNIVEL := 1

      qrsay ( XNIVEL++ , AD_VIAG->Codigo            )
      qrsay ( XNIVEL++ , AD_VIAG->Tipocont          ) ; TIPOCONT->(Dbseek(AD_VIAG->Tipocont))
      qrsay ( XNIVEL++ , left(TIPOCONT->Descricao,15))
      qrsay ( XNIVEL++ , AD_VIAG->Data              )
      qrsay ( XNIVEL++ , AD_VIAG->Centro            ) ; CCUSTO->(Dbseek(AD_VIAG->Centro))
      qrsay ( XNIVEL++ , left(CCUSTO->Descricao,15))
      qrsay ( XNIVEL++ , AD_VIAG->Filial            ) ; FILIAL->(Dbseek(AD_VIAG->Filial))
      qrsay ( XNIVEL++ , left(FILIAL->Razao,15))
      qrsay ( XNIVEL++ , AD_VIAG->Data_ini              )
      qrsay ( XNIVEL++ , AD_VIAG->Data_fim              )
      qrsay ( XNIVEL++ , AD_VIAG->Cgm_des               ) ; CGM->(Dbseek(AD_VIAG->Cgm_des))
      qrsay ( XNIVEL++ , CGM->Municipio                 )
      qrsay ( XNIVEL++ , CGM->Estado                    )

      qrsay ( XNIVEL++ , AD_VIAG->Valor     , "@E 999,999.99"  )
      qrsay ( XNIVEL++ , qabrev(AD_VIAG->Forma,"COE", {"Cheque","Ordem","Esp‚cie"}))
      qrsay ( XNIVEL++ , AD_VIAG->Banco             ) ; BANCO->(Dbseek(AD_VIAG->Banco))
      qrsay ( XNIVEL++ , left(BANCO->Descricao,10)   )
      qrsay ( XNIVEL++ , AD_VIAG->Num_cheque        )
      qrsay ( XNIVEL++ , AD_VIAG->Cod_fav           )
      qrsay ( XNIVEL++ , left(AD_VIAG->Favorecido,50)        )
      qrsay ( XNIVEL++ , left(AD_VIAG->Historico,40))

   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   if cOPCAO == "M"
      if ! qconf("Confirma emissao do Cheque??") ; return .F. ; endif

      i_cheque()

   endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || NIL                                           },NIL          })
   aadd(aEDICAO,{{ || view_tipo(-1,0,@fTIPOCONT)                    },"TIPOCONT"   })
   aadd(aEDICAO,{{ || NIL                                           },NIL          })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDATA, "@D")                      },"DATA"       })
   aadd(aEDICAO,{{ || view_ccusto(-1,0,@fCENTRO)                    },"CENTRO"     })
   aadd(aEDICAO,{{ || NIL                                           },NIL          })
   aadd(aEDICAO,{{ || view_filial(-1,0,@fFILIAL)                    },"FILIAL"     })
   aadd(aEDICAO,{{ || NIL                                           },NIL          })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDATA_INI, "@D")                  },"DATA_INI"   })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDATA_FIM, "@D")                  },"DATA_FIM"   })
   aadd(aEDICAO,{{ || view_cgm(-1,0,@fCGM_DES  )                    },"CGM_DES"    })
   aadd(aEDICAO,{{ || NIL                                           },NIL          })
   aadd(aEDICAO,{{ || NIL                                           },NIL          })

   aadd(aEDICAO,{{ || qgetx(-1,0,@fVALOR    , "@E 9,999,999.99"   ) } ,"VALOR"     })
   aadd(aEDICAO,{{ || qesco(-1,0,@fFORMA ,sBLOC1                   )} ,"FORMA"     })
   aadd(aEDICAO,{{ || view_banco(-1,0,@fBANCO)                      },"BANCO"      })
   aadd(aEDICAO,{{ || NIL                                           },NIL          })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fNUM_CHEQUE                     ) } ,"NUM_CHEQUE"})
   aadd(aEDICAO,{{ || view_Fun(-1,0,@fCOD_FAV)                  },"COD_FAV"      })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fFAVORECIDO , "@!S40"              ) } ,"FAVORECIDO"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@fHISTORICO , "@!@S40"           ) } ,"HISTORICO" })
   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   AD_VIAG->(qpublicfields())

   iif(cOPCAO=="I",AD_VIAG->(qinitfields()),AD_VIAG->(qcopyfields()))

   XNIVEL := 2
   XFLAG  := .T.
   fDATA  := XDATA

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; AD_VIAG->(qreleasefields()) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif

   if AD_VIAG->(iif(cOPCAO=="I",qappend(),qrlock())) .and. CONFIG->(qrlock())

      // AQUI INCREMENTA CODIGO DA INCLUSAO DO CHEQUE _____________________

      if cOPCAO == "I"
         replace CONFIG->Cod_adian with CONFIG->Cod_adian+1
         qmensa("C¢digo Gerado: "+strzero(CONFIG->Cod_adian,5),"B")
         fCODIGO := strzero(CONFIG->Cod_adian,5)
      endif

      // AGORA GRAVA E DESTRAVA ARQUIVO _____________________________________

      fDATA := XDATA

      AD_VIAG->(qreplacefields())

      if fFORMA $ "CO"

         if cOPCAO == "I" .and. MOV_BANC->(qappend())
            replace MOV_BANC->Data with fDATA
            replace MOV_BANC->Cod_banco with fBANCO
            replace MOV_BANC->Historico with "ADIANT. VIAGEM" + iif(! empty(fNUM_CHEQUE), " CH. " + fNUM_CHEQUE, "") + " - "+left(AD_VIAG->Favorecido,25)
            replace MOV_BANC->Saida     with fVALOR
            replace MOV_BANC->Concilia  with "0"
            replace MOV_BANC->Internal  with "ADVG"+fCODIGO
         endif

         if cOPCAO == "A"
            MOV_BANC->(Dbsetorder(4))
            if MOV_BANC->(dbseek("ADVG"+AD_VIAG->Codigo)) .and. MOV_BANC->(qrlock())
               replace MOV_BANC->Data with fDATA
               replace MOV_BANC->Cod_banco with fBANCO
               replace MOV_BANC->Historico with "ADIANT. VIAGEM" + iif(! empty(fNUM_CHEQUE), " CH. " + fNUM_CHEQUE, "") + " - "+left(AD_VIAG->Favorecido,25)
               replace MOV_BANC->Saida     with fVALOR
               replace MOV_BANC->Num_docto with ""//left(fDUPLICATA,6)
               replace MOV_BANC->Concilia  with "0"
               MOV_BANC->(Qunlock())
            endif
         endif


      elseif fFORMA $ "E"

         if cOPCAO == "I" .and. MOV_CAIX->(qappend())
            replace MOV_CAIX->Data with fDATA
            replace MOV_CAIX->Cod_banco with fBANCO
            replace MOV_CAIX->Historico with "ADIANT. VIAGEM" + iif(! empty(fNUM_CHEQUE), " CH. " + fNUM_CHEQUE, "") + " - "+left(AD_VIAG->Favorecido,25)
            replace MOV_CAIX->Saida     with fVALOR
            replace MOV_CAIX->Num_docto with ""//left(fDUPLICATA,6)
            replace MOV_CAIX->Internal  with "ADVG"+fCODIGO
         endif

         if cOPCAO == "A"
            MOV_CAIX->(Dbsetorder(2))
            if MOV_CAIX->(Dbseek("ADVG"+AD_VIAG->Codigo)) .and. MOV_CAIX->(Qrlock())
               replace MOV_CAIX->Data with fDATA
               replace MOV_CAIX->Cod_banco with fBANCO
               replace MOV_CAIX->Historico with "ADIANT. VIAGEM" + iif(! empty(fNUM_CHEQUE), " CH. " + fNUM_CHEQUE, "") + " - "+left(AD_VIAG->Favorecido,25)
               replace MOV_CAIX->Saida     with fVALOR
               replace MOV_CAIX->Num_docto with ""//left(fDUPLICATA,6)
               MOV_CAIX->(qunlock())
            endif
         endif


      endif

   else
      iif(cOPCAO=="I",qm1(),qm2())
   endif

   if TALOES->Ultimo_ch >= TALOES->Inter_fina   // grava ultimo numero do cheque, e verifica se o talao terminou
      if TALOES->(qrlock())
         TALOES->(Dbdelete())  // quando o talao acaba o registro e' excluido
      endif
   else
      if TALOES->(qrlock())
         replace TALOES->Ultimo_ch with (val(fNUM_CHEQUE) + 1)
      endif
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

      case cCAMPO == "VALOR"

           if fVALOR == 0 ; return .F. ; endif

      case cCAMPO == "BANCO"

           if empty(fBANCO) ; return .F. ; endif

           if ! BANCO->(dbseek(fBANCO:=strzero(val(fBANCO),5)))
               qmensa("Banco n„o Cadastrado !","B")
               return .F.
           endif

           qrsay(XNIVEL+1,left(BANCO->Descricao,20))
           if cOPCAO == "I"
              if fBANCO <> "99999"
                 TALOES->(dbsetorder(2))  // codigo do banco
                 TALOES->(dbgotop())

                 if TALOES->(dbseek(fBANCO))
                    fNUM_CHEQUE := strzero(TALOES->Ultimo_ch)
                 else
                   qmensa("N„o Existe Tal„o Cadastrado para este Banco !","B")
                   XNIVEL := 40 // para sair do loop principal
                   return .F.
                 endif
              endif
           endif


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
           if fFORMA = "E"
              fBANCO := "99999"
           endif

      case  cCAMPO == "COD_FAV"


           if ! FUN->(dbseek(fCOD_FAV:=strzero(val(fCOD_FAV),6)))
               qmensa("Funcionario n„o Cadastrado !","B")
               qmensa("")
           else
               fFAVORECIDO := left(FUN->Nome,40)
               qrsay(XNIVEL+1,left(FUN->Nome,40))

           endif

      case  cCAMPO == "CGM_DES"


           if ! CGM->(dbseek(fCGM_DES))
               qmensa("Municipio n„o Cadastrado !","B")
               qmensa("")
           else
               qrsay(XNIVEL+1,left(CGM->Municipio,30))
               qrsay(XNIVEL+2,CGM->Estado)

           endif



   endcase

return .T.
////////////////////////////////////////////////////////////////////////////
// FUNCAO UTILIZADA PARA IMPRESSAO DO CHEQUE ______________________________
static function i_cheque()

   local cEXTENSO

   if POS_CHEQ->(Dbseek(AD_VIAG->Banco))

      if ! qinitprn() ; return ; endif

      @ prow()+1,val(POS_CHEQ->Valor) say "## " + transform(AD_VIAG->Valor,"@E 999,999.99") + " ##"

      cEXTENSO := qextenso(AD_VIAG->Valor)
      nTAM := len(cEXTENSO)

      @ prow()+2,val(POS_CHEQ->Extenso)      say iif( nTAM > val(POS_CHEQ->Linha) , left(cEXTENSO, val(POS_CHEQ->Linha) ) , cEXTENSO  )

      if nTAM > val(POS_CHEQ->Linha)
         @ prow()+1,val(POS_CHEQ->Extenso)-6   say substr( cEXTENSO, val(POS_CHEQ->Linha)+1, nTAM )
      else
         @ prow()+1,0 say ""
      endif

      @ prow()+2,val(POS_CHEQ->Nominal) say AD_VIAG->Favorecido
      @ prow()+3,val(POS_CHEQ->Cidade)  say iif( CGM-> (Dbseek("041000"))    , left(CGM->Municipio,10) , space(10) )
      @ prow()  ,val(POS_CHEQ->Dia)     say left(dtoc(XDATASYS),2)
      @ prow()  ,val(POS_CHEQ->Mes)     say qnomemes(XDATASYS)
      @ prow()  ,val(POS_CHEQ->Ano)     say right(dtoc(XDATASYS),2)

      @ prow()+3,0 say ""

      qstopprn()
   else
      qmensa("N„o existe lay-out de cheques ...","B")
      return .F.
   endif
return

static function i_exclusao

   if QConf("Confirma exclusao deste Adiantamento de Viagem?","B")
      MOV_BANC->(Dbsetorder(4))
      if MOV_BANC->(Dbseek("ADVG"+AD_VIAG->Codigo))
         MOV_BANC->(Qrlock())
         MOV_BANC->(Dbdelete())
         MOV_BANC->(Qunlock())
      endif

      MOV_CAIX->(Dbsetorder(2))
      if MOV_CAIX->(Dbseek("ADVG"+AD_VIAG->Codigo))
         MOV_CAIX->(Qrlock())
         MOV_CAIX->(Dbdelete())
         MOV_CAIX->(Qunlock())
      endif

      AD_VIAG->(Qrlock())
      AD_VIAG->(Dbdelete())
      AD_VIAG->(Qunlock())
   endif
return


