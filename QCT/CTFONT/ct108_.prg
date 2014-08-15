/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE CONTABILIDADE
// OBJETIVO...: MANUTENCAO DE TIPOS CONTABEIS
// ANALISTA...: IN SUNG CHANG
// PROGRAMADOR: O MESMO
// INICIO.....: ABRIL DE 1997
// OBS........:
// ALTERACOES.:
function ct108

TIPOCONT->(qview({{"transform(Codigo,'@R 99.9999')/C¢digo" ,1},;
                  {"c108b()/Descri‡„o"                     ,2}},"P",;
                  {NIL,"c108a",NIL,NIL},;
                   NIL,q_msg_acesso_usr()))
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA DESLOCAR EM ARVORE A DESCRICAO DOS PRODUTOS __________________

function c108b
   local cDESCRICAO := TIPOCONT->Descricao + "    "
   do case
      case len(alltrim(TIPOCONT->Codigo)) == 2 ; cDESCRICAO := TIPOCONT->Descricao
      case len(alltrim(TIPOCONT->Codigo)) == 6 ; cDESCRICAO := "  "+TIPOCONT->Descricao
   endcase
return cDESCRICAO

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function c108a
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))
   if cOPCAO $ XUSRA
      qlbloc(03,05,"B108A","QBLOC.GLO",1)
      qmensa(qabrev(cOPCAO,"IA",{"Inclus„o... <ESC - Cancela>","Altera‡„o... <ESC - Cancela>"}))
      i_edicao()
   endif
   setcursor(nCURSOR)
return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA ____________________________________

static function i_edicao
   local aEDICAO := {}
   local bESCAPE := {||empty(fCODIGO).or.(XNIVEL==1.and.!XFLAG).or.;
                    (!empty(fCODIGO) .and. XNIVEL==1 .and. !XFLAG .or. !empty(fCODIGO) .and. XNIVEL==1 .and. Lastkey()==27) .or.;
                       (XNIVEL==1.and.cOPCAO=="A".and.!XFLAG)}
   local nREC

   local sBLOC1 := qlbloc("B108B","QBLOC.GLO")   // Motivo
   local sBLOC2 := qlbloc("B108C","QBLOC.GLO")   // Nota fiscal
   local sBLOC3 := qlbloc("B108D","QBLOC.GLO")
   local sBLOC4 := qlbloc("B108E","QBLOC.GLO")
   local sBLOC6 := qlbloc("B108G","QBLOC.GLO")
   local sBLOC7 := qlbloc("B108H","QBLOC.GLO")

   private nTIPO := 0
   private lCONF1
   private lCONF2

   PLAN->(dbsetorder(3))

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"
      XNIVEL := 1
      qrsay ( XNIVEL++ , TIPOCONT->Codigo , "@R 99.9999" )
      qrsay ( XNIVEL++ , TIPOCONT->Descricao )
      qrsay ( XNIVEL++ , qabrev(TIPOCONT->Motivo,"123",{"Recebimento","Pagamento","Ambos"}))
      qrsay ( XNIVEL++ , qabrev(TIPOCONT->Nota_fisc,"12",{"Obrigat¢ria","Facultativa"}))
      qrsay ( XNIVEL++ , qabrev(TIPOCONT->Aviso_cob,"12",{"Obrigat¢rio","Facultativo"}))
      qrsay ( XNIVEL++ , qabrev(TIPOCONT->Regime_ope,"12",{"Caixa","Competˆncia"}))

      qrsay ( XNIVEL++ , qabrev(TIPOCONT->Cont_pr_dv,"12",{"Informada","Cadastro Auxiliar"}))
      qrsay ( XNIVEL++ , TIPOCONT->Ct_ct_p_dv,"@R 99999-9" ) ; PLAN->(dbseek(TIPOCONT->Ct_ct_p_dv))
      qrsay ( XNIVEL++ , iif(!empty(PLAN->Reduzido),PLAN->Descricao,"") )
      qrsay ( XNIVEL++ , qabrev(TIPOCONT->Cont_pr_cr,"12",{"Informada","Cadastro Auxiliar"}))
      qrsay ( XNIVEL++ , TIPOCONT->Ct_ct_p_cr,"@R 99999-9" ) ; PLAN->(dbseek(TIPOCONT->Ct_ct_p_cr))
      qrsay ( XNIVEL++ , iif(!empty(PLAN->Reduzido),PLAN->Descricao,"") )
      qrsay ( XNIVEL++ , TIPOCONT->Hist_l_pr )
      qrsay ( XNIVEL++ , TIPOCONT->Hist_l_1)
      qrsay ( XNIVEL++ , TIPOCONT->Hist_l_2)

      qrsay ( XNIVEL++ , qabrev(TIPOCONT->Conta_liq,"12",{"Informada","Cadastro Auxiliar"}))
      qrsay ( XNIVEL++ , TIPOCONT->Ct_ct_liq,"@R 99999-9" ) ; PLAN->(dbseek(TIPOCONT->Ct_ct_liq))
      qrsay ( XNIVEL++ , iif(!empty(PLAN->Reduzido),PLAN->Descricao,"") )
      qrsay ( XNIVEL++ , TIPOCONT->Hi_l_liq1 )
      qrsay ( XNIVEL++ , qabrev(TIPOCONT->Conta_l2,"12",{"Informada","Cadastro Auxiliar"}))
      qrsay ( XNIVEL++ , TIPOCONT->Ct_ct_l2,"@R 99999-9" ) ; PLAN->(dbseek(TIPOCONT->Ct_ct_l2))
      qrsay ( XNIVEL++ , iif(!empty(PLAN->Reduzido),PLAN->Descricao,"") )
      qrsay ( XNIVEL++ , TIPOCONT->Hi_l_liq2 )

   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || qgetx(-1,0,@fCODIGO       ,"@R 99")                   },"CODIGO"    })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDESCRICAO    ,"@!")                      },"DESCRICAO" })
   aadd(aEDICAO,{{ || qesco(-1,0,@fMOTIVO       ,sBLOC1                   ) },"MOTIVO"    })
   aadd(aEDICAO,{{ || qesco(-1,0,@fNOTA_FISC    ,sBLOC2                   ) },"NOTA_FISC" })
   aadd(aEDICAO,{{ || qesco(-1,0,@fAVISO_COB    ,sBLOC3                   ) },"AVISO_COB" })
   aadd(aEDICAO,{{ || qesco(-1,0,@fREGIME_OPE   ,sBLOC4                   ) },"REGIME_OPE"})

   aadd(aEDICAO,{{ || qesco(-1,0,@fCONT_PR_DV   ,sBLOC6                   ) },"CONT_PR_DV"})
   aadd(aEDICAO,{{ || view_pllanc(-1,0,@fCT_CT_P_DV)                        },"CT_CT_P_DV"})
   aadd(aEDICAO,{{ || NIL                                                   } ,NIL        })
   aadd(aEDICAO,{{ || qesco(-1,0,@fCONT_PR_CR   ,sBLOC6                   ) },"CONT_PR_CR"})
   aadd(aEDICAO,{{ || view_pllanc(-1,0,@fCT_CT_P_CR)                        },"CT_CT_P_CR"})
   aadd(aEDICAO,{{ || NIL                                                   } ,NIL        })
   aadd(aEDICAO,{{ || view_hist(-1,0,@fHIST_L_PR  ,"999")                   },"HIST_L_PR" })
   aadd(aEDICAO,{{ || view_hist(-1,0,@fHIST_L_1   ,"999")                   },"HIST_L_1"})
   aadd(aEDICAO,{{ || view_hist(-1,0,@fHIST_L_2   ,"999")                   },"HIST_L_2"})

   aadd(aEDICAO,{{ || qesco(-1,0,@fCONTA_LIQ    ,sBLOC6                   ) },"CONTA_LIQ" })
   aadd(aEDICAO,{{ || view_pllanc(-1,0,@fCT_CT_LIQ)                         },"CT_CT_LIQ" })
   aadd(aEDICAO,{{ || NIL                                                   } ,NIL        })
   aadd(aEDICAO,{{ || view_hist(-1,0,@fHI_L_LIQ1   ,"999")                  },"HI_L_LIQ1"})
   aadd(aEDICAO,{{ || qesco(-1,0,@fCONTA_L2    ,sBLOC6                   ) },"CONTA_L2" })
   aadd(aEDICAO,{{ || view_pllanc(-1,0,@fCT_CT_L2)                         },"CT_CT_L2" })
   aadd(aEDICAO,{{ || NIL                                                   } ,NIL        })
   aadd(aEDICAO,{{ || view_hist(-1,0,@fHI_L_LIQ2   ,"999")                  },"HI_L_LIQ2"})

   aadd(aEDICAO,{{ || lCONF1 := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" de Lan‡amentos Complementares ?") },"COMPLEM"})
   aadd(aEDICAO,{{ || lCONF2 := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   TIPOCONT->(qpublicfields())
   iif(cOPCAO=="I",TIPOCONT->(qinitfields()),TIPOCONT->(qcopyfields()))

   XNIVEL := 1
   XFLAG  := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; TIPOCONT->(qreleasefields()) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF2 ; return ; endif

   if CONFIG->(qrlock()) .and. TIPOCONT->(iif(cOPCAO=="I",qappend(),qrlock()))

      // AQUI INCREMENTA CODIGO DO PRODUTO __________________________________

      if cOPCAO == "I"
         if len(alltrim(fCODIGO)) == 6
            replace CONFIG->Cod_tipo with val(right(fCODIGO,4))
            qmensa("C¢digo Gerado: "+fCODIGO,"B")
         endif
      endif

      TIPOCONT->(qreplacefields())

   else
      iif(cOPCAO=="I",qm1(),qm2())
   endif

   dbunlockall()

   if cOPCAO == "I" ; keyboard "I" ; endif

return

/////////////////////////////////////////////////////////////////////////////
// CRITICA DE EDICAO ________________________________________________________

static function i_critica ( cCAMPO )

   local nREC

   if ! XFLAG ; return .T. ; endif


   do case

      case cCAMPO == "CODIGO"
           if cOPCAO == "I"
              i_tipo_inc()
           else
              nTIPO := 2
           endif

           if nTIPO == 1
              fCODIGO := alltrim(fCODIGO) + strzero(CONFIG->Cod_tipo+1,4)
              qrsay ( 1 , transform(fCODIGO,"@R 99.9999") )
              qmensa("C¢digo Gerado: "+fCODIGO,"B")
              if ! TIPOCONT->(dbseek(left(fCODIGO,2))) .and. cOPCAO == "I"
                 qmensa("Tipo n„o cadastrado !","B")
                 fCODIGO := ""
                 return .F.
              endif
              if TIPOCONT->(dbseek(fCODIGO)) .and. cOPCAO == "I"
                 qmensa("Tipo Cont bel j  cadastrado !","B")
                 fCODIGO := ""
                 return .F.
              endif
           else
              if cOPCAO == "I"
                 if TIPOCONT->(dbseek(fCODIGO))
                    qmensa("Tipo j  cadastrado !","B")
                    fCODIGO := ""
                    return .F.
                 endif
              endif
           endif

      case cCAMPO == "DESCRICAO"
           if empty(fDESCRICAO) ; return .F. ; endif
           if len(alltrim(fCODIGO)) == 2
              XNIVEL := 24
           endif

      case cCAMPO == "MOTIVO"
           qrsay(XNIVEL,qabrev(fMOTIVO,"123",{"Recebimento","Pagamento","Ambos"}))

      case cCAMPO == "NOTA_FISC"
           qrsay(XNIVEL,qabrev(fNOTA_FISC,"12",{"Obrigat¢ria","Facultativa"}))

      case cCAMPO == "AVISO_COB"
           qrsay(XNIVEL,qabrev(fAVISO_COB,"12",{"Obrigat¢rio","Facultativo"}))

      case cCAMPO == "REGIME_OPE"
           qrsay(XNIVEL,qabrev(fREGIME_OPE,"12",{"Caixa","Competˆncia"}))
           if fREGIME_OPE == "1"
              if fMOTIVO == "2"  // regime de caixa com motivo == de pagamento
                 XNIVEL := 15
              else
                 XNIVEL := 19
              endif
           endif

      case cCAMPO == "CONT_PR_DV"
           qrsay(XNIVEL,qabrev(fCONT_PR_DV,"12",{"Informada","Cadastro Auxiliar"}))
           if fCONT_PR_DV == "2"
              fCT_CT_P_DV := space(6)
              XNIVEL := 9
           endif

      case cCAMPO == "CT_CT_P_DV"
           if ! empty(fCT_CT_P_DV)
              if ! ct_dig_ok(fCT_CT_P_DV)
                 qmensa("Digito verificador invalido !","B")
                 return .F.
              endif
              qrsay(XNIVEL,fCT_CT_P_DV,"@R 99999-9")
              if ! PLAN->(dbseek(fCT_CT_P_DV))
                 qmensa("Conta n„o encontrada !","B")
                 return .F.
              endif
              qrsay(XNIVEL+1,PLAN->Descricao)
           endif

      case cCAMPO == "CONT_PR_CR"
           qrsay(XNIVEL,qabrev(fCONT_PR_CR,"12",{"Informada","Cadastro Auxiliar"}))
           if fCONT_PR_CR == "2"
              fCT_CT_P_CR := space(6)
              XNIVEL := 12
           endif

      case cCAMPO == "CT_CT_P_CR"
           if ! empty(fCT_CT_P_CR)
              if ! ct_dig_ok(fCT_CT_P_CR)
                 qmensa("Digito verificador invalido !","B")
                 return .F.
              endif
              qrsay(XNIVEL,fCT_CT_P_CR,"@R 99999-9")
              if ! PLAN->(dbseek(fCT_CT_P_CR))
                 qmensa("Conta n„o encontrada !","B")
                 return .F.
              endif
              qrsay(XNIVEL+1,PLAN->Descricao)
           endif

      case cCAMPO == "HIST_L_PR"
           if empty(fHIST_L_PR) ; return .F. ; endif
           if ! HIST->(dbseek(fHIST_L_PR:=strzero(val(fHIST_L_PR),3)))
              qmensa("Hist¢rico n„o existente...","B")
              return .F.
           endif
           if fMOTIVO == "1"
              XNIVEL += 1
           endif

      case cCAMPO == "HIST_L_1"
           if empty(fHIST_L_1) ; return .F. ; endif
           if ! HIST->(dbseek(fHIST_L_1:=strzero(val(fHIST_L_1),3)))
              qmensa("Hist¢rico n„o existente...","B")
              return .F.
           endif
           if fMOTIVO $ "234" .and. fREGIME_OPE == "2"
              XNIVEL += 9
           endif

      case cCAMPO == "HIST_L_2"
           if ! HIST->(dbseek(fHIST_L_2:=strzero(val(fHIST_L_2),3)))
              qmensa("Hist¢rico n„o existente...","B")
              return .F.
           endif
           XNIVEL := 23

      case cCAMPO == "CONTA_LIQ"
           qrsay(XNIVEL,qabrev(fCONTA_LIQ,"12",{"Informada","Cadastro Auxiliar"}))
           if fREGIME_OPE = "1" .and. fCONTA_LIQ = "2"
              qmensa("Regime de Caixa, deve informar a Conta !","B")
              return .F.
           endif
           if fCONTA_LIQ == "2"
              fCT_CT_LIQ := space(6)
              XNIVEL := 17
           endif

      case cCAMPO == "CT_CT_LIQ"
           if ! empty(fCT_CT_LIQ)
              if ! ct_dig_ok(fCT_CT_LIQ)
                 qmensa("Digito verificador invalido !","B")
                 return .F.
              endif
              qrsay(XNIVEL,fCT_CT_LIQ,"@R 99999-9")
              if ! PLAN->(dbseek(fCT_CT_LIQ))
                 qmensa("Conta n„o encontrada !","B")
                 return .F.
              endif
              qrsay(XNIVEL+1,PLAN->Descricao)
           endif

      case cCAMPO == "CONTA_L2"
           qrsay(XNIVEL,qabrev(fCONTA_L2,"12",{"Informada","Cadastro Auxiliar"}))
           if fCONTA_L2 == "2"
              fCT_CT_LIQ := space(6)
              XNIVEL := 21
           endif

      case cCAMPO == "CT_CT_L2"
           if ! empty(fCT_CT_L2)
              if ! ct_dig_ok(fCT_CT_L2)
                 qmensa("Digito verificador invalido !","B")
                 return .F.
              endif
              qrsay(XNIVEL,fCT_CT_L2,"@R 99999-9")
              if ! PLAN->(dbseek(fCT_CT_L2))
                 qmensa("Conta n„o encontrada !","B")
                 return .F.
              endif
              qrsay(XNIVEL+1,PLAN->Descricao)
           endif

      case cCAMPO == "HI_L_LIQ1"
           if empty(fHI_L_LIQ1) ; return .F. ; endif
           if ! HIST->(dbseek(fHI_L_LIQ1:=strzero(val(fHI_L_LIQ1),3)))
              qmensa("Hist¢rico n„o existente...","B")
              return .F.
           endif
           if fMOTIVO == "2"
              XNIVEL += 4
           endif

      case cCAMPO == "COMPLEM"
           if lCONF1
              i_tela_2()
              XNIVEL := 24
           endif

      case cCAMPO == "HI_COMP1"
           if empty(fHI_COMP1)
              nNIVEL := 57
              return .T.
           endif
           if ! HIST->(dbseek(fHI_COMP1:=strzero(val(fHI_COMP1),3)))
              qmensa("Hist¢rico n„o existente...","B")
              return .F.
           endif


      case cCAMPO == "CT_LIQ_1"
           qrsay(nNIVEL,qabrev(fCT_LIQ_1,"12",{"Informada","Cadastro Auxiliar"}))
           if fCT_LIQ_1 == "2"
              nNIVEL := 4
           endif


      case cCAMPO == "FU_COMP1"
           qrsay (nNIVEL,qabrev(fFU_COMP1,"1234567",{"Dedutora da Partida",;
                                                     "Redutora da Contrapartida",;
                                                     "Corre‡„o",;
                                                     "D‚bito",;
                                                     "Cr‚dito",;
                                                     "Acr‚scimo de Liquida‡„o",;
                                                     "Decr‚scimo de Liquidacao"}))
      case cCAMPO == "HI_COMP2"
           if empty(fHI_COMP2)
              nNIVEL := 57
              return .T.
           endif
           if ! HIST->(dbseek(fHI_COMP2:=strzero(val(fHI_COMP2),3)))
              qmensa("Hist¢rico n„o existente...","B")
              return .F.
           endif

      case cCAMPO == "CT_LIQ_2"
           qrsay(nNIVEL,qabrev(fCT_LIQ_2,"12",{"Informada","Cadastro Auxiliar"}))
           if fCT_LIQ_2 == "2"
              nNIVEL := 8
           endif

      case cCAMPO == "FU_COMP2"
           qrsay ( nNIVEL , qabrev(fFU_COMP2,"1234567",{"Dedutora da Partida",;
                                                        "Redutora da Contrapartida",;
                                                        "Corre‡„o",;
                                                        "D‚bito",;
                                                        "Cr‚dito",;
                                                        "Acr‚scimo de Liquida‡„o",;
                                                        "Decr‚scimo de Liquidacao"}))
      case cCAMPO == "HI_COMP3"
           if empty(fHI_COMP3)
              nNIVEL := 57
              return .T.
           endif
           if ! HIST->(dbseek(fHI_COMP2:=strzero(val(fHI_COMP2),3)))
              qmensa("Hist¢rico n„o existente...","B")
              return .F.
           endif


      case cCAMPO == "CT_LIQ_3"
           qrsay(nNIVEL,qabrev(fCT_LIQ_3,"12",{"Informada","Cadastro Auxiliar"}))
           if fCT_LIQ_3 == "2"
              nNIVEL := 12
           endif

      case cCAMPO == "FU_COMP3"
           qrsay ( nNIVEL , qabrev(fFU_COMP3,"1234567",{"Dedutora da Partida",;
                                                        "Redutora da Contrapartida",;
                                                        "Corre‡„o",;
                                                        "D‚bito",;
                                                        "Cr‚dito",;
                                                        "Acr‚scimo de Liquida‡„o",;
                                                        "Decr‚scimo de Liquidacao"}))
      case cCAMPO == "HI_COMP4"
           if empty(fHI_COMP4)
              nNIVEL := 57
              return .T.
           endif
           if ! HIST->(dbseek(fHI_COMP4:=strzero(val(fHI_COMP4),3)))
              qmensa("Hist¢rico n„o existente...","B")
              return .F.
           endif

      case cCAMPO == "CT_LIQ_4"
           qrsay(nNIVEL,qabrev(fCT_LIQ_4,"12",{"Informada","Cadastro Auxiliar"}))
           if fCT_LIQ_4 == "2"
              nNIVEL := 16
           endif

      case cCAMPO == "FU_COMP4"
           qrsay ( nNIVEL , qabrev(fFU_COMP4,"1234567",{"Dedutora da Partida",;
                                                        "Redutora da Contrapartida",;
                                                        "Corre‡„o",;
                                                        "D‚bito",;
                                                        "Cr‚dito",;
                                                        "Acr‚scimo de Liquida‡„o",;
                                                        "Decr‚scimo de Liquidacao"}))
      case cCAMPO == "HI_COMP5"
           if empty(fHI_COMP5)
              nNIVEL := 57
              return .T.
           endif
           if ! HIST->(dbseek(fHI_COMP5:=strzero(val(fHI_COMP5),3)))
              qmensa("Hist¢rico n„o existente...","B")
              return .F.
           endif

      case cCAMPO == "CT_LIQ_5"
           qrsay(nNIVEL,qabrev(fCT_LIQ_5,"12",{"Informada","Cadastro Auxiliar"}))
           if fCT_LIQ_5 == "2"
              nNIVEL := 20
           endif

      case cCAMPO == "FU_COMP5"
           qrsay ( nNIVEL , qabrev(fFU_COMP5,"1234567",{"Dedutora da Partida",;
                                                        "Redutora da Contrapartida",;
                                                        "Corre‡„o",;
                                                        "D‚bito",;
                                                        "Cr‚dito",;
                                                        "Acr‚scimo de Liquida‡„o",;
                                                        "Decr‚scimo de Liquidacao"}))
      case cCAMPO == "HI_COMP6"
           if empty(fHI_COMP6)
              nNIVEL := 57
              return .T.
           endif
           if ! HIST->(dbseek(fHI_COMP6:=strzero(val(fHI_COMP6),3)))
              qmensa("Hist¢rico n„o existente...","B")
              return .F.
           endif


      case cCAMPO == "CT_LIQ_6"
           qrsay(nNIVEL,qabrev(fCT_LIQ_6,"12",{"Informada","Cadastro Auxiliar"}))
           if fCT_LIQ_6 == "2"
              nNIVEL := 24
           endif

      case cCAMPO == "FU_COMP6"
           qrsay ( nNIVEL , qabrev(fFU_COMP6,"1234567",{"Dedutora da Partida",;
                                                        "Redutora da Contrapartida",;
                                                        "Corre‡„o",;
                                                        "D‚bito",;
                                                        "Cr‚dito",;
                                                        "Acr‚scimo de Liquida‡„o",;
                                                        "Decr‚scimo de Liquidacao"}))
      case cCAMPO == "HI_COMP7"
           if empty(fHI_COMP7)
              nNIVEL := 57
              return .T.
           endif
           if ! HIST->(dbseek(fHI_COMP7:=strzero(val(fHI_COMP7),3)))
              qmensa("Hist¢rico n„o existente...","B")
              return .F.
           endif

      case cCAMPO == "CT_LIQ_7"
           qrsay(nNIVEL,qabrev(fCT_LIQ_7,"12",{"Informada","Cadastro Auxiliar"}))
           if fCT_LIQ_7 == "2"
              nNIVEL := 28
           endif

      case cCAMPO == "FU_COMP7"
           qrsay ( nNIVEL , qabrev(fFU_COMP7,"1234567",{"Dedutora da Partida",;
                                                        "Redutora da Contrapartida",;
                                                        "Corre‡„o",;
                                                        "D‚bito",;
                                                        "Cr‚dito",;
                                                        "Acr‚scimo de Liquida‡„o",;
                                                        "Decr‚scimo de Liquidacao"}))
      case cCAMPO == "HI_COMP8"
           if empty(fHI_COMP8)
              nNIVEL := 57
              return .T.
           endif
           if ! HIST->(dbseek(fHI_COMP8:=strzero(val(fHI_COMP8),3)))
              qmensa("Hist¢rico n„o existente...","B")
              return .F.
           endif

      case cCAMPO == "CT_LIQ_8"
           qrsay(nNIVEL,qabrev(fCT_LIQ_8,"12",{"Informada","Cadastro Auxiliar"}))
           if fCT_LIQ_8 == "2"
              nNIVEL := 32
           endif

      case cCAMPO == "FU_COMP8"
           qrsay ( nNIVEL , qabrev(fFU_COMP8,"1234567",{"Dedutora da Partida",;
                                                        "Redutora da Contrapartida",;
                                                        "Corre‡„o",;
                                                        "D‚bito",;
                                                        "Cr‚dito",;
                                                        "Acr‚scimo de Liquida‡„o",;
                                                        "Decr‚scimo de Liquidacao"}))
      case cCAMPO == "HI_COMP9"
           if empty(fHI_COMP9)
              nNIVEL := 57
              return .T.
           endif
           if ! HIST->(dbseek(fHI_COMP9:=strzero(val(fHI_COMP9),3)))
              qmensa("Hist¢rico n„o existente...","B")
              return .F.
           endif

      case cCAMPO == "CT_LIQ_9"
           qrsay(nNIVEL,qabrev(fCT_LIQ_9,"12",{"Informada","Cadastro Auxiliar"}))
           if fCT_LIQ_9 == "2"
              nNIVEL := 36
           endif

      case cCAMPO == "FU_COMP9"
           qrsay ( nNIVEL , qabrev(fFU_COMP9,"1234567",{"Dedutora da Partida",;
                                                        "Redutora da Contrapartida",;
                                                        "Corre‡„o",;
                                                        "D‚bito",;
                                                        "Cr‚dito",;
                                                        "Acr‚scimo de Liquida‡„o",;
                                                        "Decr‚scimo de Liquidacao"}))
      case cCAMPO == "HI_COMP10"
           if empty(fHI_COMP10)
              nNIVEL := 57
              return .T.
           endif
           if ! HIST->(dbseek(fHI_COMP10:=strzero(val(fHI_COMP10),3)))
              qmensa("Hist¢rico n„o existente...","B")
              return .F.
           endif

      case cCAMPO == "CT_LIQ_10"
           qrsay(nNIVEL,qabrev(fCT_LIQ_10,"12",{"Informada","Cadastro Auxiliar"}))
           if fCT_LIQ_10 == "2"
              nNIVEL := 40
           endif

      case cCAMPO == "FU_COMP10"
           qrsay ( nNIVEL , qabrev(fFU_COMP10,"1234567",{"Dedutora da Partida",;
                                                        "Redutora da Contrapartida",;
                                                        "Corre‡„o",;
                                                        "D‚bito",;
                                                        "Cr‚dito",;
                                                        "Acr‚scimo de Liquida‡„o",;
                                                        "Decr‚scimo de Liquidacao"}))
      case cCAMPO == "HI_COMP11"
           if empty(fHI_COMP11)
              nNIVEL := 57
              return .T.
           endif
           if ! HIST->(dbseek(fHI_COMP11:=strzero(val(fHI_COMP11),3)))
              qmensa("Hist¢rico n„o existente...","B")
              return .F.
           endif

      case cCAMPO == "CT_LIQ_11"
           qrsay(nNIVEL,qabrev(fCT_LIQ_11,"12",{"Informada","Cadastro Auxiliar"}))
           if fCT_LIQ_11 == "2"
              nNIVEL := 44
           endif

      case cCAMPO == "FU_COMP11"
           qrsay ( nNIVEL , qabrev(fFU_COMP11,"1234567",{"Dedutora da Partida",;
                                                        "Redutora da Contrapartida",;
                                                        "Corre‡„o",;
                                                        "D‚bito",;
                                                        "Cr‚dito",;
                                                        "Acr‚scimo de Liquida‡„o",;
                                                        "Decr‚scimo de Liquidacao"}))
      case cCAMPO == "HI_COMP12"
           if empty(fHI_COMP12)
              nNIVEL := 57
              return .T.
           endif
           if ! HIST->(dbseek(fHI_COMP12:=strzero(val(fHI_COMP12),3)))
              qmensa("Hist¢rico n„o existente...","B")
              return .F.
           endif


      case cCAMPO == "CT_LIQ_12"
           qrsay(nNIVEL,qabrev(fCT_LIQ_12,"12",{"Informada","Cadastro Auxiliar"}))
           if fCT_LIQ_12 == "2"
              nNIVEL := 48
           endif

      case cCAMPO == "FU_COMP12"
           qrsay ( nNIVEL , qabrev(fFU_COMP12,"1234567",{"Dedutora da Partida",;
                                                        "Redutora da Contrapartida",;
                                                        "Corre‡„o",;
                                                        "D‚bito",;
                                                        "Cr‚dito",;
                                                        "Acr‚scimo de Liquida‡„o",;
                                                        "Decr‚scimo de Liquidacao"}))
      case cCAMPO == "HI_COMP13"
           if empty(fHI_COMP13)
              nNIVEL := 57
              return .T.
           endif
           if ! HIST->(dbseek(fHI_COMP13:=strzero(val(fHI_COMP13),3)))
              qmensa("Hist¢rico n„o existente...","B")
              return .F.
           endif

      case cCAMPO == "CT_LIQ_13"
           qrsay(nNIVEL,qabrev(fCT_LIQ_13,"12",{"Informada","Cadastro Auxiliar"}))
           if fCT_LIQ_13 == "2"
              nNIVEL := 52
           endif

      case cCAMPO == "FU_COMP13"
           qrsay ( nNIVEL , qabrev(fFU_COMP13,"1234567",{"Dedutora da Partida",;
                                                        "Redutora da Contrapartida",;
                                                        "Corre‡„o",;
                                                        "D‚bito",;
                                                        "Cr‚dito",;
                                                        "Acr‚scimo de Liquida‡„o",;
                                                        "Decr‚scimo de Liquidacao"}))
   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXCLUIR PRODUTO ______________________________________________

static function i_exclusao
   if qconf("Confirma exclus„o deste Tipo Cont bel ?")
      if TIPOCONT->(qrlock())
         TIPOCONT->(dbdelete())
         TIPOCONT->(qunlock())
      else
         qm3()
      endif
   endif
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHER TIPO DE INCLUSAO ____________________________________

static function i_tipo_inc
   nTIPO := alert("Voce est  incluindo...",{"TIPO CONTABIL","TIPO"})
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA ____________________________________

static function i_tela_2

   local aEDICAO2 := {}

   local sBLOC1 := qlbloc("B108G","QBLOC.GLO")
   local sBLOC2 := qlbloc("B108H","QBLOC.GLO")

   private nNIVEL

   XNIVEL := nNIVEL

   // MONTA DADOS NA TELA ___________________________________________________

   qlbloc(03,05,"B108F","QBLOC.GLO",1)

   if cOPCAO <> "I"
      nNIVEL := 1
      qrsay ( nNIVEL++ , TIPOCONT->Hi_comp1 )
      qrsay ( nNIVEL++ , qabrev(TIPOCONT->Ct_liq_1,"12",{"Informada","Cadastro Auxiliar"}))
      qrsay ( nNIVEL++ , TIPOCONT->Ct_comp1,"@R 99999-9" )
      qrsay ( nNIVEL++ , qabrev(TIPOCONT->Fu_comp1,"1234567",{"Dedutora da Partida",;
                                                            "Redutora da Contrapartida",;
                                                            "Corre‡„o",;
                                                            "D‚bito",;
                                                            "Cr‚dito",;
                                                            "Acr‚scimo de Liquida‡„o",;
                                                            "Decr‚scimo de Liquidacao"}))
      qrsay ( nNIVEL++ , TIPOCONT->Hi_comp2 )
      qrsay ( nNIVEL++ , qabrev(TIPOCONT->Ct_liq_2,"12",{"Informada","Cadastro Auxiliar"}))
      qrsay ( nNIVEL++ , TIPOCONT->Ct_comp2,"@R 99999-9" )
      qrsay ( nNIVEL++ , qabrev(TIPOCONT->Fu_comp2,"1234567",{"Dedutora da Partida",;
                                                            "Redutora da Contrapartida",;
                                                            "Corre‡„o",;
                                                            "D‚bito",;
                                                            "Cr‚dito",;
                                                            "Acr‚scimo de Liquida‡„o",;
                                                            "Decr‚scimo de Liquidacao"}))
      qrsay ( nNIVEL++ , TIPOCONT->Hi_comp3 )
      qrsay ( nNIVEL++ , qabrev(TIPOCONT->Ct_liq_3,"12",{"Informada","Cadastro Auxiliar"}))
      qrsay ( nNIVEL++ , TIPOCONT->Ct_comp3,"@R 99999-9" )
      qrsay ( nNIVEL++ , qabrev(TIPOCONT->Fu_comp3,"1234567",{"Dedutora da Partida",;
                                                            "Redutora da Contrapartida",;
                                                            "Corre‡„o",;
                                                            "D‚bito",;
                                                            "Cr‚dito",;
                                                            "Acr‚scimo de Liquida‡„o",;
                                                            "Decr‚scimo de Liquidacao"}))
      qrsay ( nNIVEL++ , TIPOCONT->Hi_comp4 )
      qrsay ( nNIVEL++ , qabrev(TIPOCONT->Ct_liq_4,"12",{"Informada","Cadastro Auxiliar"}))
      qrsay ( nNIVEL++ , TIPOCONT->Ct_comp4,"@R 99999-9" )
      qrsay ( nNIVEL++ , qabrev(TIPOCONT->Fu_comp4,"1234567",{"Dedutora da Partida",;
                                                            "Redutora da Contrapartida",;
                                                            "Corre‡„o",;
                                                            "D‚bito",;
                                                            "Cr‚dito",;
                                                            "Acr‚scimo de Liquida‡„o",;
                                                            "Decr‚scimo de Liquidacao"}))
      qrsay ( nNIVEL++ , TIPOCONT->Hi_comp5 )
      qrsay ( nNIVEL++ , qabrev(TIPOCONT->Ct_liq_5,"12",{"Informada","Cadastro Auxiliar"}))
      qrsay ( nNIVEL++ , TIPOCONT->Ct_comp5,"@R 99999-9" )
      qrsay ( nNIVEL++ , qabrev(TIPOCONT->Fu_comp5,"1234567",{"Dedutora da Partida",;
                                                            "Redutora da Contrapartida",;
                                                            "Corre‡„o",;
                                                            "D‚bito",;
                                                            "Cr‚dito",;
                                                            "Acr‚scimo de Liquida‡„o",;
                                                            "Decr‚scimo de Liquidacao"}))
      qrsay ( nNIVEL++ , TIPOCONT->Hi_comp6 )
      qrsay ( nNIVEL++ , qabrev(TIPOCONT->Ct_liq_6,"12",{"Informada","Cadastro Auxiliar"}))
      qrsay ( nNIVEL++ , TIPOCONT->Ct_comp6,"@R 99999-9" )
      qrsay ( nNIVEL++ , qabrev(TIPOCONT->Fu_comp6,"1234567",{"Dedutora da Partida",;
                                                            "Redutora da Contrapartida",;
                                                            "Corre‡„o",;
                                                            "D‚bito",;
                                                            "Cr‚dito",;
                                                            "Acr‚scimo de Liquida‡„o",;
                                                            "Decr‚scimo de Liquidacao"}))
      qrsay ( nNIVEL++ , TIPOCONT->Hi_comp7 )
      qrsay ( nNIVEL++ , qabrev(TIPOCONT->Ct_liq_7,"12",{"Informada","Cadastro Auxiliar"}))
      qrsay ( nNIVEL++ , TIPOCONT->Ct_comp7,"@R 99999-9" )
      qrsay ( nNIVEL++ , qabrev(TIPOCONT->Fu_comp7,"1234567",{"Dedutora da Partida",;
                                                            "Redutora da Contrapartida",;
                                                            "Corre‡„o",;
                                                            "D‚bito",;
                                                            "Cr‚dito",;
                                                            "Acr‚scimo de Liquida‡„o",;
                                                            "Decr‚scimo de Liquidacao"}))
      qrsay ( nNIVEL++ , TIPOCONT->Hi_comp8 )
      qrsay ( nNIVEL++ , qabrev(TIPOCONT->Ct_liq_8,"12",{"Informada","Cadastro Auxiliar"}))
      qrsay ( nNIVEL++ , TIPOCONT->Ct_comp8,"@R 99999-9" )
      qrsay ( nNIVEL++ , qabrev(TIPOCONT->Fu_comp8,"1234567",{"Dedutora da Partida",;
                                                            "Redutora da Contrapartida",;
                                                            "Corre‡„o",;
                                                            "D‚bito",;
                                                            "Cr‚dito",;
                                                            "Acr‚scimo de Liquida‡„o",;
                                                            "Decr‚scimo de Liquidacao"}))
      qrsay ( nNIVEL++ , TIPOCONT->Hi_comp9 )
      qrsay ( nNIVEL++ , qabrev(TIPOCONT->Ct_liq_9,"12",{"Informada","Cadastro Auxiliar"}))
      qrsay ( nNIVEL++ , TIPOCONT->Ct_comp9,"@R 99999-9" )
      qrsay ( nNIVEL++ , qabrev(TIPOCONT->Fu_comp9,"1234567",{"Dedutora da Partida",;
                                                            "Redutora da Contrapartida",;
                                                            "Corre‡„o",;
                                                            "D‚bito",;
                                                            "Cr‚dito",;
                                                            "Acr‚scimo de Liquida‡„o",;
                                                            "Decr‚scimo de Liquidacao"}))
      qrsay ( nNIVEL++ , TIPOCONT->Hi_comp10 )
      qrsay ( nNIVEL++ , qabrev(TIPOCONT->Ct_liq_10,"12",{"Informada","Cadastro Auxiliar"}))
      qrsay ( nNIVEL++ , TIPOCONT->Ct_comp10,"@R 99999-9" )
      qrsay ( nNIVEL++ , qabrev(TIPOCONT->Fu_comp10,"1234567",{"Dedutora da Partida",;
                                                            "Redutora da Contrapartida",;
                                                            "Corre‡„o",;
                                                            "D‚bito",;
                                                            "Cr‚dito",;
                                                            "Acr‚scimo de Liquida‡„o",;
                                                            "Decr‚scimo de Liquidacao"}))
      qrsay ( nNIVEL++ , TIPOCONT->Hi_comp11 )
      qrsay ( nNIVEL++ , qabrev(TIPOCONT->Ct_liq_11,"12",{"Informada","Cadastro Auxiliar"}))
      qrsay ( nNIVEL++ , TIPOCONT->Ct_comp11,"@R 99999-9" )
      qrsay ( nNIVEL++ , qabrev(TIPOCONT->Fu_comp11,"1234567",{"Dedutora da Partida",;
                                                            "Redutora da Contrapartida",;
                                                            "Corre‡„o",;
                                                            "D‚bito",;
                                                            "Cr‚dito",;
                                                            "Acr‚scimo de Liquida‡„o",;
                                                            "Decr‚scimo de Liquidacao"}))
      qrsay ( nNIVEL++ , TIPOCONT->Hi_comp12 )
      qrsay ( nNIVEL++ , qabrev(TIPOCONT->Ct_liq_12,"12",{"Informada","Cadastro Auxiliar"}))
      qrsay ( nNIVEL++ , TIPOCONT->Ct_comp12,"@R 99999-9" )
      qrsay ( nNIVEL++ , qabrev(TIPOCONT->Fu_comp12,"1234567",{"Dedutora da Partida",;
                                                            "Redutora da Contrapartida",;
                                                            "Corre‡„o",;
                                                            "D‚bito",;
                                                            "Cr‚dito",;
                                                            "Acr‚scimo de Liquida‡„o",;
                                                            "Decr‚scimo de Liquidacao"}))
      qrsay ( nNIVEL++ , TIPOCONT->Hi_comp13 )
      qrsay ( nNIVEL++ , qabrev(TIPOCONT->Ct_liq_13,"12",{"Informada","Cadastro Auxiliar"}))
      qrsay ( nNIVEL++ , TIPOCONT->Ct_comp13,"@R 99999-9" )
      qrsay ( nNIVEL++ , qabrev(TIPOCONT->Fu_comp13,"1234567",{"Dedutora da Partida",;
                                                            "Redutora da Contrapartida",;
                                                            "Corre‡„o",;
                                                            "D‚bito",;
                                                            "Cr‚dito",;
                                                            "Acr‚scimo de Liquida‡„o",;
                                                            "Decr‚scimo de Liquidacao"}))
   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO2,{{ || view_hist(-1,0,@fHI_COMP1     ,"999")                 },"HI_COMP1"  })
   aadd(aEDICAO2,{{ || qesco(-1,0,@fCT_LIQ_1     ,sBLOC1                   ) },"CT_LIQ_1"  })
   aadd(aEDICAO2,{{ || view_pllanc(-1,0,@fCT_COMP1)                          },"CT_COMP1"  })
   aadd(aEDICAO2,{{ || qesco(-1,0,@fFU_COMP1     ,sBLOC2                   ) },"FU_COMP1"  })

   aadd(aEDICAO2,{{ || view_hist(-1,0,@fHI_COMP2     ,"999")                 },"HI_COMP2"  })
   aadd(aEDICAO2,{{ || qesco(-1,0,@fCT_LIQ_2     ,sBLOC1                   ) },"CT_LIQ_2"  })
   aadd(aEDICAO2,{{ || view_pllanc(-1,0,@fCT_COMP2)                          },"CT_COMP2"  })
   aadd(aEDICAO2,{{ || qesco(-1,0,@fFU_COMP2     ,sBLOC2                   ) },"FU_COMP2"  })

   aadd(aEDICAO2,{{ || view_hist(-1,0,@fHI_COMP3     ,"999")               },"HI_COMP3"  })
   aadd(aEDICAO2,{{ || qesco(-1,0,@fCT_LIQ_3     ,sBLOC1                   ) },"CT_LIQ_3"  })
   aadd(aEDICAO2,{{ || view_pllanc(-1,0,@fCT_COMP3)                          },"CT_COMP3"  })
   aadd(aEDICAO2,{{ || qesco(-1,0,@fFU_COMP3     ,sBLOC2                   ) },"FU_COMP3"  })

   aadd(aEDICAO2,{{ || view_hist(-1,0,@fHI_COMP4     ,"999")                 },"HI_COMP4"  })
   aadd(aEDICAO2,{{ || qesco(-1,0,@fCT_LIQ_4     ,sBLOC1                   ) },"CT_LIQ_4"  })
   aadd(aEDICAO2,{{ || view_pllanc(-1,0,@fCT_COMP4)                          },"CT_COMP4"  })
   aadd(aEDICAO2,{{ || qesco(-1,0,@fFU_COMP4     ,sBLOC2                   ) },"FU_COMP4"  })

   aadd(aEDICAO2,{{ || view_hist(-1,0,@fHI_COMP5     ,"999")                 },"HI_COMP5"  })
   aadd(aEDICAO2,{{ || qesco(-1,0,@fCT_LIQ_5     ,sBLOC1                   ) },"CT_LIQ_5"  })
   aadd(aEDICAO2,{{ || view_pllanc(-1,0,@fCT_COMP5)                          },"CT_COMP5"  })
   aadd(aEDICAO2,{{ || qesco(-1,0,@fFU_COMP5     ,sBLOC2                   ) },"FU_COMP5"  })

   aadd(aEDICAO2,{{ || view_hist(-1,0,@fHI_COMP6     ,"999")                 },"HI_COMP6"  })
   aadd(aEDICAO2,{{ || qesco(-1,0,@fCT_LIQ_6     ,sBLOC1                   ) },"CT_LIQ_6"  })
   aadd(aEDICAO2,{{ || view_pllanc(-1,0,@fCT_COMP6)                          },"CT_COMP6"  })
   aadd(aEDICAO2,{{ || qesco(-1,0,@fFU_COMP6     ,sBLOC2                   ) },"FU_COMP6"  })

   aadd(aEDICAO2,{{ || view_hist(-1,0,@fHI_COMP7     ,"999")                 },"HI_COMP7"  })
   aadd(aEDICAO2,{{ || qesco(-1,0,@fCT_LIQ_7     ,sBLOC1                   ) },"CT_LIQ_7"  })
   aadd(aEDICAO2,{{ || view_pllanc(-1,0,@fCT_COMP7)                          },"CT_COMP7"  })
   aadd(aEDICAO2,{{ || qesco(-1,0,@fFU_COMP7     ,sBLOC2                   ) },"FU_COMP7"  })

   aadd(aEDICAO2,{{ || view_hist(-1,0,@fHI_COMP8     ,"999")                 },"HI_COMP8"  })
   aadd(aEDICAO2,{{ || qesco(-1,0,@fCT_LIQ_8     ,sBLOC1                   ) },"CT_LIQ_8"  })
   aadd(aEDICAO2,{{ || view_pllanc(-1,0,@fCT_COMP8)                          },"CT_COMP8"  })
   aadd(aEDICAO2,{{ || qesco(-1,0,@fFU_COMP8     ,sBLOC2                   ) },"FU_COMP8"  })

   aadd(aEDICAO2,{{ || view_hist(-1,0,@fHI_COMP9     ,"999")                 },"HI_COMP9"  })
   aadd(aEDICAO2,{{ || qesco(-1,0,@fCT_LIQ_9     ,sBLOC1                   ) },"CT_LIQ_9"  })
   aadd(aEDICAO2,{{ || view_pllanc(-1,0,@fCT_COMP9)                          },"CT_COMP9"  })
   aadd(aEDICAO2,{{ || qesco(-1,0,@fFU_COMP9     ,sBLOC2                   ) },"FU_COMP9"  })

   aadd(aEDICAO2,{{ || view_hist(-1,0,@fHI_COMP10     ,"999")                 },"HI_COMP10"  })
   aadd(aEDICAO2,{{ || qesco(-1,0,@fCT_LIQ_10     ,sBLOC1                   ) },"CT_LIQ_10"  })
   aadd(aEDICAO2,{{ || view_pllanc(-1,0,@fCT_COMP10)                          },"CT_COMP10"  })
   aadd(aEDICAO2,{{ || qesco(-1,0,@fFU_COMP10     ,sBLOC2                   ) },"FU_COMP10"  })

   aadd(aEDICAO2,{{ || view_hist(-1,0,@fHI_COMP11     ,"999")                 },"HI_COMP11"  })
   aadd(aEDICAO2,{{ || qesco(-1,0,@fCT_LIQ_11     ,sBLOC1                   ) },"CT_LIQ_11"  })
   aadd(aEDICAO2,{{ || view_pllanc(-1,0,@fCT_COMP11)                          },"CT_COMP11"  })
   aadd(aEDICAO2,{{ || qesco(-1,0,@fFU_COMP11     ,sBLOC2                   ) },"FU_COMP11"  })

   aadd(aEDICAO2,{{ || view_hist(-1,0,@fHI_COMP12     ,"999")                 },"HI_COMP12"  })
   aadd(aEDICAO2,{{ || qesco(-1,0,@fCT_LIQ_12     ,sBLOC1                   ) },"CT_LIQ_12"  })
   aadd(aEDICAO2,{{ || view_pllanc(-1,0,@fCT_COMP12)                          },"CT_COMP12"  })
   aadd(aEDICAO2,{{ || qesco(15,47,@fFU_COMP12     ,sBLOC2                   ) },"FU_COMP12"  })

   aadd(aEDICAO2,{{ || view_hist(-1,0,@fHI_COMP13     ,"999")                 },"HI_COMP13"  })
   aadd(aEDICAO2,{{ || qesco(-1,0,@fCT_LIQ_13     ,sBLOC1                   ) },"CT_LIQ_13"  })
   aadd(aEDICAO2,{{ || view_pllanc(-1,0,@fCT_COMP13)                          },"CT_COMP13"  })
   aadd(aEDICAO2,{{ || qesco(15,47,@fFU_COMP13     ,sBLOC2                   ) },"FU_COMP13"  })

   nNIVEL := 1
   XFLAG  := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while nNIVEL >= 1 .and. nNIVEL <= len(aEDICAO2)
      XNIVEL := nNIVEL
      eval ( aEDICAO2[nNIVEL,1] )
      if ! i_critica( aEDICAO2[nNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , nNIVEL++ , nNIVEL-- )
   enddo
