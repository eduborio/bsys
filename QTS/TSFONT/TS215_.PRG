/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE TESOURARIA
// OBJETIVO...: LANCAMENTOS DE PAGAMENTOS A VISTA
// ANALISTA...:
// PROGRAMADOR: Eduardo Borio
// INICIO.....: Setembro de 2006
// OBS........:
// ALTERACOES.:
function ts215

#include "inkey.ch"
#include "setcurs.ch"

private sBLOC1  := qlbloc("B207B","QBLOC.GLO")

BANCO->(Dbsetorder(3))
CCUSTO->(Dbsetorder(4))

/////////////////////////////////////////////////////////////////////////////
// MANUTENCAO DOS LANCAMENTOS DE CHEQUES PRE-DATADOS ________________________

PRES_CON->(qview({{"Codigo/C¢d."                        ,1},;
                  {"Data/Data"           ,2},;
                  {"left(Favorecido,25)/Nome"           ,3},;
                  {"Valor/Valor"                        ,0}},"P",;
                  {NIL,"i_215a",NIL,NIL},;
                  {"Data==XDATA",{||i215top()},{||i215bot()}},;
                  "<I>ncluir <C>onsultar <A>lterar  <E>xcluir Im<p>rimir"))

return ""

function i215top
   PRES_CON->(Dbsetorder(2))
   PRES_CON->(dbseek(dtos(XDATA)))
return

function i215bot
   PRES_CON->(Dbsetorder(2))
   PRES_CON->(qseekn(dtos(XDATA)))
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO DE CONTROLE PRINCIPAL ANTES DE PROCESSAR A TECLA ACIONADA _________

function i_215a

   local nCURSOR := setcursor(1)

   parameters cOPCAO

   cOPCAO := upper(chr(cOPCAO))

   //if cOPCAO $ "AE" .and. PRES_CON->Data < CONFIG->Data_atual
   // /  qmensa("Data encerrada. Permissao Negada!","B")
   //   return .F.
   //endif

   //if cOPCAO == "I" .and. CONFIG->Data_ant < CONFIG->Data_atual
   //   qmensa("Data Encerrada. Permissao Negada!","B")
   //   return.F.
   //endif

   if cOPCAO == "P" ; i_impressao() ; endif


   if cOPCAO $ "IAMCE"
      qlbloc(05,00,"B215A","QBLOC.GLO",1)
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
   local bESCAPE := {||(XNIVEL==2.and.lastkey()==27).or.;
                       (XNIVEL==2.and.cOPCAO=="A".and.!XFLAG)}

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"

      XNIVEL := 1

      qrsay ( XNIVEL++ , PRES_CON->Codigo            )
      qrsay ( XNIVEL++ , PRES_CON->Cod_projet        ) ; PROJET->(Dbseek(PRES_CON->Cod_Projet))
      qrsay ( XNIVEL++ , left(PROJET->Descricao,17)  ) ; EVENTOS->(Dbseek(PROJET->Cod_eve))
      qrsay ( XNIVEL++ , left(EVENTOS->Nome,12)      )

      qrsay ( XNIVEL++ , PRES_CON->Tipocont          ) ; TIPOCONT->(Dbseek(PRES_CON->Tipocont))
      qrsay ( XNIVEL++ , left(TIPOCONT->Descricao,15))
      qrsay ( XNIVEL++ , PRES_CON->Data              )

      qrsay ( XNIVEL++ , PRES_CON->Cgm_des               ) ; CGM->(Dbseek(PRES_CON->Cgm_des))
      qrsay ( XNIVEL++ , CGM->Municipio                 )
      qrsay ( XNIVEL++ , CGM->Estado                    )

      qrsay ( XNIVEL++ , PRES_CON->Data_ini              )
      qrsay ( XNIVEL++ , PRES_CON->Data_fim              )

      qrsay ( XNIVEL++ , PRES_CON->Combust , "@E 99,999.99"  ) //Combustivel
      qrsay ( XNIVEL++ , PRES_CON->Pecas   , "@E 99,999.99"  ) //Frete
      qrsay ( XNIVEL++ , PRES_CON->Lubrific, "@E 99,999.99"  ) //Limpeza


      qrsay ( XNIVEL++ , PRES_CON->Aliment , "@E 99,999.99"  ) //Alimenta‡Æo
      qrsay ( XNIVEL++ , PRES_CON->Manut   , "@E 99,999.99"  ) //Manutencao
      qrsay ( XNIVEL++ , PRES_CON->Medic   , "@E 99,999.99"  ) //Medicamentos

      qrsay ( XNIVEL++ , PRES_CON->Hosped  , "@E 99,999.99"  ) // Hospedagem
      qrsay ( XNIVEL++ , PRES_CON->Pneus   , "@E 99,999.99"  ) // Estacionamento
      qrsay ( XNIVEL++ , PRES_CON->Cartao  , "@E 99,999.99"  ) // Cartao Telefonico

      qrsay ( XNIVEL++ , PRES_CON->Passagem, "@E 99,999.99"  ) //Passagem
      qrsay ( XNIVEL++ , PRES_CON->Materiais, "@E 99,999.99" ) //Materiais
      qrsay ( XNIVEL++ , PRES_CON->Vales   , "@E 99,999.99"  ) //Vales


      qrsay ( XNIVEL++ , PRES_CON->Taxi    , "@E 99,999.99"  ) //Taxi
      qrsay ( XNIVEL++ , PRES_CON->Pedagio , "@E 99,999.99"  ) //Pedagio
      qrsay ( XNIVEL++ , PRES_CON->Outros  , "@E 99,999.99"  ) //Outros

      AD_VIAG->(Dbsetorder(1))
      qrsay ( XNIVEL++ , PRES_CON->Cod_Ad1 ) ; AD_VIAG->(Dbseek(PRES_CON->Cod_ad1))
      qrsay ( XNIVEL++ , dtoc(AD_VIAG->Data)   )
      qrsay ( XNIVEL++ , left(AD_VIAG->Favorecido,30)   )
      qrsay ( XNIVEL++ , AD_VIAG->Valor  , "@E 999,999.99"  )

      qrsay ( XNIVEL++ , PRES_CON->Cod_Ad2 ) ; AD_VIAG->(Dbseek(PRES_CON->Cod_ad2))
      qrsay ( XNIVEL++ , dtoc(AD_VIAG->Data)   )
      qrsay ( XNIVEL++ , left(AD_VIAG->Favorecido,30)   )
      qrsay ( XNIVEL++ , AD_VIAG->Valor  , "@E 999,999.99"  )

      qrsay ( XNIVEL++ , PRES_CON->Cod_Ad3 ) ; AD_VIAG->(Dbseek(PRES_CON->Cod_ad3))
      qrsay ( XNIVEL++ , dtoc(AD_VIAG->Data)   )
      qrsay ( XNIVEL++ , left(AD_VIAG->Favorecido,30)   )
      qrsay ( XNIVEL++ , AD_VIAG->Valor  , "@E 999,999.99"  )

      qrsay ( XNIVEL++ , PRES_CON->Despesas  , "@E 999,999.99"  )
      qrsay ( XNIVEL++ , PRES_CON->Adiant    , "@E 999,999.99"  )
      qrsay ( XNIVEL++ , PRES_CON->Valor     , "@E 999,999.99"  )

      qrsay ( XNIVEL++ , qabrev(PRES_CON->Forma,"COE", {"Cheque","Ordem","Esp‚cie"}))
      qrsay ( XNIVEL++ , PRES_CON->Banco             ) ; BANCO->(Dbseek(PRES_CON->Banco))
      qrsay ( XNIVEL++ , left(BANCO->Descricao,10)   )
      qrsay ( XNIVEL++ , PRES_CON->Num_cheque        )
      qrsay ( XNIVEL++ , PRES_CON->Cod_fav           )
      qrsay ( XNIVEL++ , left(PRES_CON->Favorecido,25)        )

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
   aadd(aEDICAO,{{ || view_Proj(-1,0,@fCod_projet)                  },"PROJET"   })
   aadd(aEDICAO,{{ || NIL                                           },NIL          })
   aadd(aEDICAO,{{ || NIL                                           },NIL          })

   aadd(aEDICAO,{{ || view_tipo(-1,0,@fTIPOCONT)                    },"TIPOCONT"   })
   aadd(aEDICAO,{{ || NIL                                           },NIL          })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDATA, "@D")                      },"DATA"       })
   aadd(aEDICAO,{{ || view_cgm(-1,0,@fCGM_DES  )                    },"CGM_DES"    })
   aadd(aEDICAO,{{ || NIL                                           },NIL          })
   aadd(aEDICAO,{{ || NIL                                           },NIL          })

   aadd(aEDICAO,{{ || qgetx(-1,0,@fDATA_INI, "@D")                  },"DATA_INI"   })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDATA_FIM, "@D")                  },"DATA_FIM"   })

   aadd(aEDICAO,{{ || qgetx(-1,0,@fCOMBUST    , "@E 99,999.99"   ) } ,"OUTCOISA"     })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fPECAS      , "@E 99,999.99"   ) } ,"OUTCOISA"     }) //Frete
   aadd(aEDICAO,{{ || qgetx(-1,0,@fLUBRIFIC   , "@E 99,999.99"   ) } ,"OUTCOISA"     }) //Limpeza


   aadd(aEDICAO,{{ || qgetx(-1,0,@fALIMENT    , "@E 99,999.99"   ) } ,"OUTCOISA"     }) //Alimentacao
   aadd(aEDICAO,{{ || qgetx(-1,0,@fMANUT      , "@E 99,999.99"   ) } ,"OUTCOISA"     }) //Manutencao
   aadd(aEDICAO,{{ || qgetx(-1,0,@fMEDIC      , "@E 99,999.99"   ) } ,"OUTCOISA"     }) //Medicamentos

   aadd(aEDICAO,{{ || qgetx(-1,0,@fHOSPED     , "@E 99,999.99"   ) } ,"OUTCOISA"     }) //Hospedagem
   aadd(aEDICAO,{{ || qgetx(-1,0,@fPNEUS      , "@E 99,999.99"   ) } ,"OUTCOISA"     }) //Estacionamento
   aadd(aEDICAO,{{ || qgetx(-1,0,@fCARTAO     , "@E 99,999.99"   ) } ,"OUTCOISA"     }) //Cartao Telefonico

   aadd(aEDICAO,{{ || qgetx(-1,0,@fPASSAGEM   , "@E 99,999.99"   ) } ,"OUTCOISA"     }) //Passagem
   aadd(aEDICAO,{{ || qgetx(-1,0,@fMATERIAIS  , "@E 99,999.99"   ) } ,"OUTCOISA"     }) //Materiais
   aadd(aEDICAO,{{ || qgetx(-1,0,@fVALES      , "@E 99,999.99"   ) } ,"OUTCOISA"     }) //Vales

   aadd(aEDICAO,{{ || qgetx(-1,0,@fTAXI       , "@E 99,999.99"   ) } ,"OUTCOISA"     }) //Taxi
   aadd(aEDICAO,{{ || qgetx(-1,0,@fPEDAGIO    , "@E 99,999.99"   ) } ,"OUTCOISA"     }) //Pedagio
   aadd(aEDICAO,{{ || qgetx(-1,0,@fOUTROS     , "@E 99,999.99"   ) } ,"OUTCOISA"     }) //Outros

   aadd(aEDICAO,{{ || view_adiant(-1,0,@fCOD_AD1)                    },"COD_AD1"   })
   aadd(aEDICAO,{{ || NIL                                           },NIL          })
   aadd(aEDICAO,{{ || NIL                                           },NIL          })
   aadd(aEDICAO,{{ || NIL                                           },NIL          })

   aadd(aEDICAO,{{ || view_adiant(-1,0,@fCOD_AD2)                    },"COD_AD2"   })
   aadd(aEDICAO,{{ || NIL                                           },NIL          })
   aadd(aEDICAO,{{ || NIL                                           },NIL          })
   aadd(aEDICAO,{{ || NIL                                           },NIL          })

   aadd(aEDICAO,{{ || view_adiant(-1,0,@fCOD_AD3)                    },"COD_AD3"   })
   aadd(aEDICAO,{{ || NIL                                           },NIL          })
   aadd(aEDICAO,{{ || NIL                                           },NIL          })
   aadd(aEDICAO,{{ || NIL                                           },NIL          })

   aadd(aEDICAO,{{ || NIL                                           },NIL          })
   aadd(aEDICAO,{{ || NIL                                           },NIL          })
   aadd(aEDICAO,{{ || NIL                                           },NIL          })



   aadd(aEDICAO,{{ || qesco(-1,0,@fFORMA ,sBLOC1                   )} ,"FORMA"     })
   aadd(aEDICAO,{{ || view_banco(-1,0,@fBANCO)                      },"BANCO"      })
   aadd(aEDICAO,{{ || NIL                                           },NIL          })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fNUM_CHEQUE                     ) } ,"NUM_CHEQUE"})
   aadd(aEDICAO,{{ || view_Fun(-1,0,@fCOD_FAV)                  },"COD_FAV"      })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fFAVORECIDO , "@!S40"              ) } ,"FAVORECIDO"})
   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   PRES_CON->(qpublicfields())

   iif(cOPCAO=="I",PRES_CON->(qinitfields()),PRES_CON->(qcopyfields()))

   XNIVEL := 2
   XFLAG  := .T.
   fDATA  := XDATA

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; PRES_CON->(qreleasefields()) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif

   if PRES_CON->(iif(cOPCAO=="I",qappend(),qrlock())) .and. CONFIG->(qrlock())

      // AQUI INCREMENTA CODIGO DA INCLUSAO DO CHEQUE _____________________

      if cOPCAO == "I"
         replace CONFIG->Cod_pres with CONFIG->Cod_pres+1
         qmensa("C¢digo Gerado: "+strzero(CONFIG->Cod_pres,5),"B")
         fCODIGO := strzero(CONFIG->Cod_pres,5)
      endif

      // AGORA GRAVA E DESTRAVA ARQUIVO _____________________________________

      fDATA := XDATA

      PRES_CON->(qreplacefields())

   //   if fFORMA $ "CO"
   //
   //      if cOPCAO == "I" .and. MOV_BANC->(qappend())
   //         replace MOV_BANC->Data with fDATA
   //         replace MOV_BANC->Cod_banco with fBANCO
   //         replace MOV_BANC->Historico with "PREST. CONTAS/AD. VIAGEM" + iif(! empty(fNUM_CHEQUE), " CH. " + fNUM_CHEQUE, "") + " - "+left(PRES_CON->Favorecido,25)
   //         replace MOV_BANC->Saida     with fVALOR
   //         replace MOV_BANC->Concilia  with "0"
   //         replace MOV_BANC->Internal  with "PRES"+fCODIGO
   //      endif
   //
   //      if cOPCAO == "A"
   //         MOV_BANC->(Dbsetorder(4))
   //         if MOV_BANC->(dbseek("PRES"+PRES_CON->Codigo)) .and. MOV_BANC->(qrlock())
   //            replace MOV_BANC->Data with fDATA
   //            replace MOV_BANC->Cod_banco with fBANCO
   //            replace MOV_BANC->Historico with "PREST. CONTAS/AD. VIAGEM" + iif(! empty(fNUM_CHEQUE), " CH. " + fNUM_CHEQUE, "") + " - "+left(PRES_CON->Favorecido,25)
   //            replace MOV_BANC->Saida     with fVALOR
   //            replace MOV_BANC->Num_docto with ""//left(fDUPLICATA,6)
   //            replace MOV_BANC->Concilia  with "0"
   //            MOV_BANC->(Qunlock())
   //         endif
   //      endif
   //

   //   elseif fFORMA $ "E"
   //
   //      if cOPCAO == "I" .and. MOV_CAIX->(qappend())
   //         replace MOV_CAIX->Data with fDATA
   //         replace MOV_CAIX->Cod_banco with fBANCO
   //         replace MOV_CAIX->Historico with "PREST. CONTAS/AD. VIAGEM" + " - "+left(PRES_CON->Favorecido,25)
   //         replace MOV_CAIX->Saida     with fVALOR
   // //        replace MOV_CAIX->Num_docto with ""//left(fDUPLICATA,6)
   //         replace MOV_CAIX->Internal  with "PRES"+fCODIGO
   //      endif
   //
   //      if cOPCAO == "A"
   //         MOV_CAIX->(Dbsetorder(2))
   //         if MOV_CAIX->(Dbseek("PRES"+PRES_CON->Codigo)) .and. MOV_CAIX->(Qrlock())
   //            replace MOV_CAIX->Data with fDATA
   //            replace MOV_CAIX->Cod_banco with fBANCO
   //            replace MOV_CAIX->Historico with "PREST. CONTAS/AD. VIAGEM" + " - "+left(PRES_CON->Favorecido,25)
   ////            replace MOV_CAIX->Saida     with fVALOR
   ////            replace MOV_CAIX->Num_docto with ""//left(fDUPLICATA,6)
   ////            MOV_CAIX->(qunlock())
   ////         endif
   ////      endif
   ////
   ////
   //   endif

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

      case cCAMPO == "PROJET"


           if ! PROJET->(dbseek(fCOD_PROJET:=strzero(val(fCOD_PROJET),5)))
               qmensa("Stande n„o Cadastrado !","B")
               qmensa("")

           else

               qrsay(XNIVEL+1,left(PROJET->Descricao,15))
               if EVENTOS->(Dbseek(PROJET->Cod_eve))
                  qrsay(XNIVEL+2,left(EVENTOS->Nome,12))

               endif

           endif

      case cCAMPO == "COD_AD1"

           fADIANT := 0
           if ! AD_VIAG->(dbseek(fCOD_AD1:=strzero(val(fCOD_AD1),5)))
               qmensa("Adiantamento n„o Cadastrado !","B")
               qmensa("")

           else
               qrsay(XNIVEL+1,dtoc(AD_VIAG->Data))
               qrsay(XNIVEL+2,left(AD_VIAG->Favorecido,30))
               qrsay(XNIVEL+3,AD_VIAG->Valor,"@E 999,999.99")
               fADIANT := AD_VIAG->Valor

           endif




      case cCAMPO == "COD_AD2"

           if ! AD_VIAG->(dbseek(fCOD_AD2:=strzero(val(fCOD_AD2),5)))
               qmensa("Adiantamento n„o Cadastrado !","B")
               qmensa("")

           else

               qrsay(XNIVEL+1,dtoc(AD_VIAG->Data))
               qrsay(XNIVEL+2,left(AD_VIAG->Favorecido,30))
               qrsay(XNIVEL+3,AD_VIAG->Valor,"@E 999,999.99")
               fADIANT += AD_VIAG->Valor


           endif

      case cCAMPO == "COD_AD3"

           if ! AD_VIAG->(dbseek(fCOD_AD3:=strzero(val(fCOD_AD3),5)))
               qmensa("Adiantamento n„o Cadastrado !","B")
               qmensa("")

           else

               qrsay(XNIVEL+1,dtoc(AD_VIAG->Data))
               qrsay(XNIVEL+2,left(AD_VIAG->Favorecido,30))
               qrsay(XNIVEL+3,AD_VIAG->Valor,"@E 999,999.99")
               fADIANT += AD_VIAG->Valor


           endif

           i_soma_desp()
           qrsay(XNIVEL+4,fDESPESAS,"@E 999,999.99")
           qrsay(XNIVEL+5,fADIANT  ,"@E 999,999.99")

           fVALOR := fADIANT - fDESPESAS
           qrsay(XNIVEL+6,fVALOR  ,"@E 999,999.99")






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
               fFAVORECIDO := left(FUN->Nome,35)
               qrsay(XNIVEL+1,left(FUN->Nome,35))

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

   if POS_CHEQ->(Dbseek(PRES_CON->Banco))

      if ! qinitprn() ; return ; endif

      @ prow()+1,val(POS_CHEQ->Valor) say "## " + transform(PRES_CON->Valor,"@E 999,999.99") + " ##"

      cEXTENSO := qextenso(PRES_CON->Valor)
      nTAM := len(cEXTENSO)

      @ prow()+2,val(POS_CHEQ->Extenso)      say iif( nTAM > val(POS_CHEQ->Linha) , left(cEXTENSO, val(POS_CHEQ->Linha) ) , cEXTENSO  )

      if nTAM > val(POS_CHEQ->Linha)
         @ prow()+1,val(POS_CHEQ->Extenso)-6   say substr( cEXTENSO, val(POS_CHEQ->Linha)+1, nTAM )
      else
         @ prow()+1,0 say ""
      endif

      @ prow()+2,val(POS_CHEQ->Nominal) say PRES_CON->Favorecido
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

   if QConf("Confirma exclusao desta Presta‡Æo de Contas?","B")
      PRES_CON->(Qrlock())
      PRES_CON->(Dbdelete())
      PRES_CON->(Qunlock())
   endif
return

static function i_soma_desp
  fDESPESAS := (fCOMBUST + fALIMENT + fHOSPED + fPASSAGEM + fTAXI + fPECAS + fMANUT + fPNEUS + fMATERIAIS + fPEDAGIO + fLUBRIFIC + fVALES + fOUTROS+fMEDIC+fCARTAO)


return

static Function i_impressao
  local cPIC := "@E 99,999.99"
  QInitPrn()

//  if XPAGINA == 0 .or. prow() > 50
//     qpageprn()
//     @ prow(),pcol() say XCOND1
     qcabecprn("Presta‡Æo de Contas - "+left(PRES_CON->Favorecido,50),136)
//     @ prow(),pcol() say XCOND1
//  endif

  @ prow()+1,  0     say "Codigo.: " + PRES_CON->Codigo
  @ prow()  , 20     say "Projeto.: " + PRES_CON->Cod_projet+" - "   ; PROJET->(Dbseek(PRES_CON->Cod_Projet))
  @ prow()  , pcol() say left(PROJET->Descricao,25)                  ; EVENTOS->(Dbseek(PROJET->Cod_eve))
  @ prow()  , pcol() say "     Evento.: "+ left(EVENTOS->Nome,25)

  @ prow()+1,  0     say "Data.: "+dtoc(PRES_CON->Data)  ; CGM->(Dbseek(PRES_CON->Cgm_des))
  @ prow()  , pcol() say "   Destino.: "+CGM->Municipio+" /"+CGM->Estado

  

  @ prow()+1, 0      say "Inicio da Viagem.: "+dtoc(PRES_CON->Data_ini)
  @ prow()  , pcol() say "        Fim da Viagem.: "+ dtoc(PRES_CON->Data_fim)

  @ prow()+2, 0      say "Combustivel.: "+ transf(PRES_CON->Combust , cPIC)
  @ prow()  , 40     say "Frete.......: "+transf(PRES_CON->Pecas    , cPIC)
  @ prow()  , 80     say "Limpeza.....: "+transf(PRES_CON->Lubrific , cPIC)

  @ prow()+1,  0     say "Alimenta‡Æo.: "+transf(PRES_CON->Aliment  , cPIC)
  @ prow()  , 40     say "Manuten‡Æo..: "+transf(PRES_CON->Manut    , cPIC)
  @ prow()  , 80     say "Medicamentos: "+transf(PRES_CON->Medic    , cPIC)

  @ prow()+1 , 0     say "Hospedagem..: "+transf(PRES_CON->Hosped   , cPIC)
  @ prow()  , 40     say "Estacionam..: "+transf(PRES_CON->Pneus    , cPIC)
  @ prow()  , 80     say "Cartao Tel..: "+transf(PRES_CON->Cartao   , cPIC)


  @ prow()+1, 0      say "Passagens...: "+transf(PRES_CON->Passagem , cPIC)
  @ prow()  , 40     say "Materiais...: "+transf(PRES_CON->Materiais, cPIC)
  @ prow()  , 80     say "Vales.......: "+transf(PRES_CON->Vales    , cPIC)


  @ prow()+1, 0      say "Taxi........: "+transf(PRES_CON->Taxi     , cPIC)
  @ prow()  ,40      say "Pedagio.....: "+transf(PRES_CON->Pedagio  , cPIC)
  @ prow()  ,80      say "Outros......: "+transf(PRES_CON->Outros   , cPIC)

  @ prow()+2, 0      say "Adiantamentos.: " ; AD_VIAG->(Dbsetorder(1))
  @ prow()+1, 0      say "Codigo.: "+PRES_CON->Cod_Ad1  ; AD_VIAG->(Dbseek(PRES_CON->Cod_ad1))
  @ prow()  , pcol() say "    Data.: "+dtoc(AD_VIAG->Data)
  @ prow()  , pcol() say "    Nome.: "+left(AD_VIAG->Favorecido,30)
  @ prow()  , pcol() say "    Valor: "+transf(AD_VIAG->Valor  , "@E 999,999.99")

  @ prow()+1, 0      say "Codigo.: "  +PRES_CON->Cod_Ad2  ; AD_VIAG->(Dbseek(PRES_CON->Cod_ad2))
  @ prow()  , pcol() say "    Data.: "+dtoc(AD_VIAG->Data)
  @ prow()  , pcol() say "    Nome.: "+left(AD_VIAG->Favorecido,30)
  @ prow()  , pcol() say "    Valor: "+transf(AD_VIAG->Valor  , "@E 999,999.99")

  @ prow()+1, 0      say "Codigo.: "  +PRES_CON->Cod_Ad3  ; AD_VIAG->(Dbseek(PRES_CON->Cod_ad3))
  @ prow()  , pcol() say "    Data.: "+dtoc(AD_VIAG->Data)
  @ prow()  , pcol() say "    Nome.: "+left(AD_VIAG->Favorecido,30)
  @ prow()  , pcol() say "    Valor: "+transf(AD_VIAG->Valor  , "@E 999,999.99")

  @ prow()+2, 0      say "Despesas.: "+transf(PRES_CON->Despesas,  "@E 999,999.99")
  @ prow()  , 40     say "Adiantamentos.: "+transf(PRES_CON->Adiant  ,  "@E 999,999.99")
  @ prow()  , 80     say "Total.: "+transf(PRES_CON->Valor   ,  "@E 999,999.99")

  @ prow()+2, 0      say "Forma de Pagamento.: "+qabrev(PRES_CON->Forma,"COE", {"Cheque","Ordem","Esp‚cie"})
  @ prow()+1, 0      say "Banco.: "+PRES_CON->Banco+" - "              ; BANCO->(Dbseek(PRES_CON->Banco))
  @ prow()  ,pcol()  say left(BANCO->Descricao,20)
  @ prow()  ,pcol()  say "    Nr. do Cheque.: "+ PRES_CON->Num_cheque


 qstopprn()

return




