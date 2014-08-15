/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO COMERCIAL
// OBJETIVO...: Configuracao de Layout de Nota Fiscal
// ANALISTA...: Eduardo Borio
// PROGRAMADOR:
// INICIO.....:
// OBS........:
// ALTERACOES.:

function cl805
LAYOUT->(qview({{"Codigo/Codigo"               ,0},;
             {"Descricao/Descricao"            ,0}},"P",;
             {NIL,"c805a",NIL,NIL},;
             NIL,q_msg_acesso_usr()))

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function c805a

   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO $ XUSRA

      qlbloc(05,00,"B805A","QBLOC.GLO",1)
      qmensa(qabrev(cOPCAO,"IA",{"Inclus„o... <ESC - Cancela>","Altera‡„o... <ESC - Cancela>"}))
      i_edicao()

   endif

   setcursor(nCURSOR)

return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA ____________________________________

static function i_edicao()

   local lCONF   := .F.
   local aEDICAO := {}
   local bESCAPE := {||empty(fCODIGO).or.(XNIVEL==1.and.!XFLAG).or.!empty(fCODIGO).and.Lastkey()==27.or.;
                       (XNIVEL==1.and.cOPCAO=="A".and.!XFLAG)}

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"
      XNIVEL := 1
      qrsay ( XNIVEL++ , LAYOUT->Codigo     )
      qrsay ( XNIVEL++ , LAYOUT->Descricao  )
      qrsay ( XNIVEL++ , LAYOUT->Num_nf_lin,"9"  )
      qrsay ( XNIVEL++ , LAYOUT->Num_nf_Col,"999"  )
      qrsay ( XNIVEL++ , LAYOUT->Saida_lin,"9"  )
      qrsay ( XNIVEL++ , LAYOUT->Saida_Sai,"99"  )
      qrsay ( XNIVEL++ , LAYOUT->Saida_Ent,"999"  )
      qrsay ( XNIVEL++ , LAYOUT->Cfop_lin,"9"  )
      qrsay ( XNIVEL++ , LAYOUT->Cfop_desc,"99"  )
      qrsay ( XNIVEL++ , LAYOUT->Cfop_cod,"99"  )
      qrsay ( XNIVEL++ , LAYOUT->Ie_sub_tri,"99"  )
      qrsay ( XNIVEL++ , LAYOUT->Razao_lin,"9"  )
      qrsay ( XNIVEL++ , LAYOUT->Razao,"99"  )
      qrsay ( XNIVEL++ , LAYOUT->Cnpj,"999"  )
      qrsay ( XNIVEL++ , LAYOUT->Data_emiss,"999"  )
      qrsay ( XNIVEL++ , LAYOUT->Ender_lin,"9"  )
      qrsay ( XNIVEL++ , LAYOUT->Endereco,"99"  )
      qrsay ( XNIVEL++ , LAYOUT->Bairro,"99"  )
      qrsay ( XNIVEL++ , LAYOUT->Cep,"999"  )
      qrsay ( XNIVEL++ , LAYOUT->Data_saida,"999"  )
   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || qgetx(-1,0,@fCODIGO ,"99")                         },"CODIGO"  })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDESCRICAO,"@!")                       },"DESCRICAO" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fNUM_NF_LIN,"9" )                      },"DESCRICAO" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fNUM_NF_COL,"999")                     },"DESCRICAO" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fSAIDA_LIN ,"9")                       },"DESCRICAO" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fSAIDA_SAI ,"99")                      },"DESCRICAO" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fSAIDA_ENT ,"999")                     },"DESCRICAO" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fCFOP_LIN  ,"9" )                      },"DESCRICAO" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fCFOP_DESC ,"99")                      },"DESCRICAO" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fCFOP_COD  ,"99")                      },"DESCRICAO" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fIE_SUB_TRI,"999")                     },"DESCRICAO" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fRAZAO_LIN ,"9" )                      },"DESCRICAO" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fRAZAO     ,"99")                      },"DESCRICAO" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fCNPJ      ,"999")                     },"DESCRICAO" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDATA_EMISS,"999")                     },"DESCRICAO" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fENDER_LIN ,"9" )                      },"DESCRICAO" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fENDERECO  ,"99")                      },"DESCRICAO" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fBAIRRO    ,"99")                      },"DESCRICAO" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fCEP       ,"999")                     },"DESCRICAO" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDATA_SAIDA,"999")                     },"DESCRICAO" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fMUNIC_LIN ,"9" )                      },"DESCRICAO" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fMUNICIPIO ,"99")                      },"DESCRICAO" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fFONE      ,"99")                      },"DESCRICAO" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fUF        ,"99")                      },"DESCRICAO" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fINSC_ESTAD,"999")                     },"DESCRICAO" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fHORA_SAIDA,"999")                     },"DESCRICAO" })

   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   LAYOUT->(qpublicfields())
   iif(cOPCAO=="I",LAYOUT->(qinitfields()),LAYOUT->(qcopyfields()))

   XNIVEL  := 1
   XFLAG   := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; LAYOUT->(qreleasefields()) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif

   if LAYOUT->(iif(cOPCAO=="I",qappend(),qrlock()))


      // AQUI INCREMENTA CODIGO DO CLIENTE __________________________________

      LAYOUT->(qreplacefields())

   else

      if empty(LAYOUT->Codigo) .and. empty(LAYOUT->Descricao)
         LAYOUT->(dbdelete())
      endif

      iif(cOPCAO=="I",qm1(),qm2())

   endif

   dbunlockall()

   if cOPCAO == "I" ; keyboard "I" ; endif

return

/////////////////////////////////////////////////////////////////////////////
// CRITICA DE EDICAO ________________________________________________________

static function i_critica ( cCAMPO )

   local zTMP

   if ! XFLAG ; return .T. ; endif

   do case

      case cCAMPO == "DESCRICAO"
           if empty(fDESCRICAO) ; return .F. ; endif
   endcase

return .T.


/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXCLUIR VENDEDORA  ___________________________________________

static function i_exclusao
   if qconf("Confirma exclus„o deste(a) Layout ?")
      if LAYOUT->(qrlock())
         LAYOUT->(dbdelete())
         LAYOUT->(qunlock())
      else
         qm3()
      endif
   endif
return
