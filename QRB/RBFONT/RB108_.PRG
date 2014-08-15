/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE CONTAS A RECEBER
// OBJETIVO...: MANUTENCAO DE AGENCIAS CEDENTES
// ANALISTA...:
// PROGRAMADOR: EDUARDO BORIO
// INICIO.....: OUTUBRO DE 2008
// OBS........:
// ALTERACOES.:

function rb108

LAYOUT->(qview({{"Codigo/C¢digo"                ,1},;
               {"Descricao/Descri‡„o"           ,2}},"P",;
               {NIL,"c108a",NIL,NIL},;
                 NIL,q_msg_acesso_usr()))

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function c108a
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))
   if cOPCAO $ XUSRA
      qlbloc(05,10,"B108A","QBLOC.GLO",1)
      qmensa(qabrev(cOPCAO,"IA",{"Inclus„o... <ESC - Cancela>","Altera‡„o... <ESC - Cancela>"}))
      i_edicao()
   endif
   setcursor(nCURSOR)
return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA ____________________________________

static function i_edicao
   local lCONF   := .F.
   local aEDICAO := {}
   local bESCAPE := {||empty(fCODIGO).or.(XNIVEL==1.and.!XFLAG).or.!empty(fCODIGO).and.Lastkey()==27.or.;
                       (XNIVEL==1.and.cOPCAO=="A".and.!XFLAG)}

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"
      XNIVEL := 1
      qrsay ( XNIVEL++ , LAYOUT->Codigo     )
      qrsay ( XNIVEL++ , LAYOUT->Descricao  )
      qrsay ( XNIVEL++ , LAYOUT->Carteira   )
      qrsay ( XNIVEL++ , LAYOUT->Ag_cede    )
      qrsay ( XNIVEL++ , LAYOUT->Conta_cede )
      qrsay ( XNIVEL++ , LAYOUT->Ag_cob     )
      qrsay ( XNIVEL++ , transform(LAYOUT->Perc_Juros,"@E 99.99"  )  )
      qrsay ( XNIVEL++ , transform(LAYOUT->Perc_Multa,"@E 99.99"  )  )
      qrsay ( XNIVEL++ , LAYOUT->Dias_prot,"99")
      qrsay ( XNIVEL++ , LAYOUT->Msg_prot)

   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || qgetx(-1,0,@fCODIGO       ,"@!")                    },"CODIGO"     })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDESCRICAO    ,"@!")                    },"DESCRICAO"  })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fCARTEIRA     ,"99"       )              },"N"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@fAG_CEDE                  )              },"N"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@fCONTA_CEDE               )              },"N"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@fAG_COB                   )              },"N"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@fPERC_JUROS   ,"@E 99.99"   )            },"N"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@fPERC_MULTA   ,"@E 99.99"   )            },"N"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDIAS_PROT    ,"99"   )            },"N"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@fMSG_PROT    ,"@!")                      },"N"  })

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

      // AGORA GRAVA E DESTRAVA ARQUIVO _____________________________________

   if LAYOUT->(iif(cOPCAO=="I",qappend(),qrlock()))

      LAYOUT->(qreplacefields())

   else

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
// FUNCAO PARA EXCLUIR AGENCIAS CEDENTES ___________________________________

static function i_exclusao
   if qconf("Confirma exclus„o desta Agˆncia Cedente ?")
      if LAYOUT->(qrlock())
         LAYOUT->(dbdelete())
         LAYOUT->(qunlock())
      else
         qm3()
      endif
   endif
return

