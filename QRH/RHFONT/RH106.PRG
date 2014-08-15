/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: FOLHA DE PAGAMENTO
// OBJETIVO...: MANUTENCAO DE GUIAS DE GRPS
// ANALISTA...: CARLOS EDUARDO RABELLO NUNES
// PROGRAMADOR: O MESMO
// INICIO.....: SETEMBRO DE 1996
// OBS........:
// ALTERACOES.:

/////////////////////////////////////////////////////////////////////////////
// MANUTENCAO DE GRPS _______________________________________________________

GRPS->(dbSetFilter({|| Anomes == xANOMES},'Anomes == xANOMES'))

GRPS->(qview({{"Codigo/C¢digo"      ,1},;
              {"Descricao/Descri‡„o",2}},"P",;
              {NIL,"c106a",NIL,NIL},;
               NIL,q_msg_acesso_usr()))
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function c106a
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))
   if cOPCAO $ XUSRA
      qlbloc(5,0,"B106A","QBLOC.GLO",1)
      qmensa(qabrev(cOPCAO,"IA",{"Inclus„o... <ESC - Cancela>","Altera‡„o... <ESC - Cancela>"}))
      i_edicao()
   endif
   setcursor(nCURSOR)
return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA ____________________________________

static function i_edicao
   local lCONF, nSOMA
   local aEDICAO := {}
   local bESCAPE := {||empty(fCODIGO).or.(XNIVEL==1.and.!XFLAG).or.(!empty(fCODIGO) .and. XNIVEL==2 .and. Lastkey()==27) .or.;
                       (XNIVEL==2.and.cOPCAO=="A".and.!XFLAG)}

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"
      XNIVEL := 1
      qrsay ( XNIVEL++ , GRPS->Codigo    )
      qrsay ( XNIVEL++ , GRPS->Descricao )
      qrsay ( XNIVEL++ , GRPS->Cod_fpas  )
      qrsay ( XNIVEL++ , GRPS->Cod_terc  )
      qrsay ( XNIVEL++ , GRPS->Cod_sat,"9,9")
      qrsay ( XNIVEL++ , GRPS->Cod_gps   )
      qrsay ( XNIVEL++ , GRPS->Perc_filan ,"@E 999.99")
      qrsay ( XNIVEL++ , GRPS->Endereco  )
      qrsay ( XNIVEL++ , GRPS->Bairro    )
      qrsay ( XNIVEL++ , GRPS->Telefone  )
      qrsay ( XNIVEL++ , GRPS->Cgm       ) ; CGM->(dbseek(GRPS->Cgm))
      qrsay ( XNIVEL++ , CGM->Municipio + "/" + CGM->Estado )
      qrsay ( XNIVEL++ , GRPS->Cep       )
      qrsay ( XNIVEL++ , GRPS->Cgc       )
      qrsay ( XNIVEL++ , GRPS->Cei       )
      qrsay ( XNIVEL++ , GRPS->Terc_01   , "@E 99.99" )
      qrsay ( XNIVEL++ , GRPS->Terc_02   , "@E 99.99" )
      qrsay ( XNIVEL++ , GRPS->Terc_03   , "@E 99.99" )
      qrsay ( XNIVEL++ , GRPS->Terc_04   , "@E 99.99" )
      qrsay ( XNIVEL++ , GRPS->Terc_05   , "@E 99.99" )
      qrsay ( XNIVEL++ , GRPS->Terc_06   , "@E 99.99" )
      qrsay ( XNIVEL++ , GRPS->Terc_07   , "@E 99.99" )
      qrsay ( XNIVEL++ , GRPS->Terc_08   , "@E 99.99" )
      qrsay ( XNIVEL++ , GRPS->Terc_09   , "@E 99.99" )
      qrsay ( XNIVEL++ , GRPS->Terc_10   , "@E 99.99" )
      qrsay ( XNIVEL++ , GRPS->Terc_11   , "@E 99.99" )
      qrsay ( XNIVEL++ , GRPS->Perc_terc , "@E 99.99" )
      qrsay ( XNIVEL++ , GRPS->Perc_empr , "@E 99.99" )
      qrsay ( XNIVEL++ , GRPS->Perc_acid , "@E 99.99" )
      qrsay ( XNIVEL++ , GRPS->Perc_prol , "@E 99.99" )
      qrsay ( XNIVEL++ , GRPS->Perc_auto , "@E 99.99" )
      qrsay ( XNIVEL++ , GRPS->Mensa_1 )
      qrsay ( XNIVEL++ , GRPS->Mensa_2 )
      nSOMA := GRPS->TERC_01+GRPS->TERC_02+GRPS->TERC_03+GRPS->TERC_04+GRPS->TERC_05
      nSOMA += GRPS->TERC_06+GRPS->TERC_07+GRPS->TERC_08+GRPS->TERC_09+GRPS->TERC_10+GRPS->TERC_11
      qsay(16,71,nSOMA,"@E 99.99")
   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || qgetx(-1,0,@fCODIGO   ,"@!",NIL,cOPCAO=="I")},"CODIGO"   })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDESCRICAO,"@!"     ,NIL,.T.)   },"DESCRICAO"})
   aadd(aEDICAO,{{ || view_fpas(-1,0,@fCOD_FPAS)                  },"COD_FPAS" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fCOD_TERC ,"9999",NIL,.T.)      },"COD_TERC" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fCOD_SAT  ,"9,9",NIL,.T.)       },"COD_SAT"  })
   aadd(aEDICAO,{{ || view_pagto(-1,0,@fCOD_GPS)                   },"COD_GPS"  })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fPERC_FILAN  ,"@E 999.99",NIL,.T.)},"PERC_FILAN"})

   aadd(aEDICAO,{{ || qgetx(-1,0,@fENDERECO ,"@!",NIL,.T.)        },"ENDERECO" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fBAIRRO   ,"@!",NIL,.T.)        },"BAIRRO"   })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fTELEFONE ,"@!",NIL,.T.)        },"TELEFONE" })
   aadd(aEDICAO,{{ || view_cgm(-1,0,@fCGM)                        },"CGM"      })
   aadd(aEDICAO,{{ || NIL },NIL}) // descricao da municipio (cgm)
   aadd(aEDICAO,{{ || qgetx(-1,0,@fCEP       ,"99999999",NIL,.T.) },"CEP"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@fCGC       ,"@!",NIL,.T.)       },"CGC"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@fCEI       ,"@!",NIL,.T.)       },"CEI"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@fTERC_01  ,"@E 99.99",NIL,.T.)  },"TERC_01"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@fTERC_02  ,"@E 99.99",NIL,.T.)  },"TERC_02"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@fTERC_03  ,"@E 99.99",NIL,.T.)  },"TERC_03"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@fTERC_04  ,"@E 99.99",NIL,.T.)  },"TERC_04"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@fTERC_05  ,"@E 99.99",NIL,.T.)  },"TERC_05"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@fTERC_06  ,"@E 99.99",NIL,.T.)  },"TERC_06"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@fTERC_07  ,"@E 99.99",NIL,.T.)  },"TERC_07"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@fTERC_08  ,"@E 99.99",NIL,.T.)  },"TERC_08"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@fTERC_09  ,"@E 99.99",NIL,.T.)  },"TERC_09"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@fTERC_10  ,"@E 99.99",NIL,.T.)  },"TERC_10"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@fTERC_11  ,"@E 99.99",NIL,.T.)  },"TERC_11"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@fPERC_TERC,"@E 99.99",NIL,.T.)  },"PERC_TERC"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@fPERC_EMPR,"@E 99.99",NIL,.T.)  },"PERC_EMPR"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@fPERC_ACID,"@E 99.99",NIL,.T.)  },"PERC_ACID"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@fPERC_PROL,"@E 99.99",NIL,.T.)  },"PERC_PROL"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@fPERC_AUTO,"@E 99.99",NIL,.T.)  },"PERC_AUTO"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@fMENSA_1  ,"@!",NIL,.T.)        },"MENSA_1"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@fMENSA_2  ,"@!",NIL,.T.)        },"MENSA_2"})
   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   GRPS->(qpublicfields())
   iif(cOPCAO=="I",GRPS->(qinitfields()),GRPS->(qcopyfields()))
   XNIVEL := 1
   XFLAG := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; GRPS->(qreleasefields()) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif

   if GRPS->(iif(cOPCAO=="I",qappend(),qrlock()))
      fANOMES := XANOMES
      GRPS->(qreplacefields())
      GRPS->(qunlock())
   else
      iif(cOPCAO=="I",qm1(),qm2())
   endif

return

/////////////////////////////////////////////////////////////////////////////
// CRITICAS NA DESCIDA ______________________________________________________

static function i_critica ( cCAMPO )
   local nSOMA
   iif ( cCAMPO == NIL , cCAMPO := "" , NIL )
   do case
      case cCAMPO == "CODIGO" .and. cOPCAO == "I"
           if GRPS->(dbseek(xANOMES + fCODIGO))
              qmensa("G.R.P.S. j  cadastrada !","B")
              return .F.
           endif
      case cCAMPO == "CGM"
           if ! CGM->(dbseek(fCGM))
              qmensa("CGM n„o encontrado !","B")
              return .F.
           endif
           qrsay(XNIVEL+1,CGM->Municipio+"/"+CGM->Estado)
      case cCAMPO == "COD_FPAS"
           if ! FPAS->(dbseek(fCOD_FPAS))
              qmensa("C¢digo FPAS n„o encontrado !","B")
              return .F.
           endif

      case cCAMPO == "TERC_11"
           nSOMA := fTERC_01+fTERC_02+fTERC_03+fTERC_04+fTERC_05
           nSOMA += fTERC_06+fTERC_07+fTERC_08+fTERC_09+fTERC_10+fTERC_11
           qsay(16,71,nSOMA,"@E 99.99")
           fPERC_TERC := nSOMA
   endcase
return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXCLUIR GRPS _________________________________________________

static function i_exclusao
   if qconf("Confirma exclus„o desta G.R.P.S. ?")
      if GRPS->(qrlock())
         GRPS->(dbdelete())
         GRPS->(qunlock())
      else
         qm3()
      endif
   endif
return

