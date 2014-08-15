/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO COMERCIAL
// OBJETIVO...: MANUTENCAO DE TRANSPORTADORA
// ANALISTA...:
// PROGRAMADOR: EDUARDO AUGUSTO BORIO
// INICIO.....: FEVEREIRO DE 2000
// OBS........:
// ALTERACOES.:

function cl106
TRANSP->(qview({{"Codigo/Codigo"         ,1},;
             {"Cgccpf/CGCCPF"            ,3},;
             {"Inscricao/Inscri‡„o"      ,0},;
             {"left(Razao,30)/Raz„o"              ,2}},"P",;
             {NIL,"c106a",NIL,NIL},;
              NIL,q_msg_acesso_usr()))

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function c106a

   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO $ XUSRA
      qlbloc(7,0,"B106A","QBLOC.GLO",1)
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
   local bESCAPE := {||empty(fCGCCPF).or.(XNIVEL==2.and.!XFLAG).or.!empty(fCGCCPF).and.Lastkey()==27.or.;
                       (XNIVEL==2.and.cOPCAO=="A".and.!XFLAG)}

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"

      XNIVEL := 1

      qrsay ( XNIVEL++ , TRANSP->Codigo                    )
      qrsay ( XNIVEL++ , fu_conv_cgccpf(TRANSP->Cgccpf)    )
      qrsay ( XNIVEL++ , TRANSP->Inscricao                 )
      qrsay ( XNIVEL++ , TRANSP->Razao                     )
      qrsay ( XNIVEL++ , TRANSP->Fantasia                  )
      qrsay ( XNIVEL++ , TRANSP->Endereco                  )
      qrsay ( XNIVEL++ , TRANSP->Cgm                       ) ; CGM->(dbseek(TRANSP->Cgm))
      qrsay ( XNIVEL++ , CGM->Municipio                    )
      qrsay ( XNIVEL++ , transform(TRANSP->Cep, "@R 99999-999"))
      qrsay ( XNIVEL++ , TRANSP->Fone1                     )
      qrsay ( XNIVEL++ , TRANSP->Ramal1                    )
      qrsay ( XNIVEL++ , TRANSP->Fone2                     )
      qrsay ( XNIVEL++ , TRANSP->Ramal2                    )
      qrsay ( XNIVEL++ , TRANSP->Fax                       )
      qrsay ( XNIVEL++ , TRANSP->Placa                     )
      qrsay ( XNIVEL++ , TRANSP->Contato_c                 )
      qrsay ( XNIVEL++ , TRANSP->Contato_f                 )
      qrsay ( XNIVEL++ , TRANSP->email                     )

   endif
   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || NIL                                                   },"CODGIO"    })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fCGCCPF   ,"@R 99.999.999/9999-99")       },"CGCCPF"    })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fINSCRICAO,"@!")                          },"INSCRICAO" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fRAZAO    ,"@!")                          },"RAZAO"     })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fFANTASIA ,"@!")                          },"FANTASIA"  })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fENDERECO ,"@!")                          },"ENDERECO"  })
   aadd(aEDICAO,{{ || view_cgm(-1,0,@fCGM)                                  },"CGM"       })
   aadd(aEDICAO,{{ || NIL                                                   },NIL         })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fCEP   ,"@R 99999-999")                   },"CEP"       })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fFONE1 ,"@!")                             },"FONE1"     })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fRAMAL1,"@!")                             },"RAMAL1"    })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fFONE2 ,"@!")                             },"FONE2"     })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fRAMAL2,"@!")                             },"RAMAL2"    })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fFAX,"@!")                                },"FAX"       })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fPLACA,"@!")                              },"PLACA"     })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fCONTATO_C,"@!")                          },"CONTATO_C" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fCONTATO_F,"@!")                          },"CONTATO_F" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@femail)                                   },"EMAIL" })

   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   TRANSP->(qpublicfields())
   iif(cOPCAO=="I",TRANSP->(qinitfields()),TRANSP->(qcopyfields()))

   XNIVEL := 2
   XFLAG  := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; TRANSP->(qreleasefields()) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif

   if CONFIG->(qrlock()) .and. TRANSP->(iif(cOPCAO=="I",qappend(),qrlock()))

      // AQUI INCREMENTA CODIGO DO TRANSP __________________________________

      if cOPCAO == "I"
         replace CONFIG->Cod_tran with CONFIG->Cod_tran + 1
         qrsay ( 1 , fCODIGO := strzero(CONFIG->Cod_tran,5) )
         qmensa("C¢digo Gerado: "+fCODIGO,"B")
      endif

      TRANSP->(qreplacefields())
      TRANSP->(dbgotop())

   else
      iif(cOPCAO=="I",qm1(),qm2())
   endif

   dbunlockall()

   if cOPCAO == "I" ; keyboard "I" ; endif

return

/////////////////////////////////////////////////////////////////////////////
// CRITICA DE EDICAO ________________________________________________________

static function i_critica ( cCAMPO )

   if ! XFLAG ; return .T. ; endif

   do case

      case cCAMPO == "CGM"

           if ! CGM->(dbseek(fCGM))
              qmensa("Cgm n„o encontrado !","B")
              return .F.
           endif

           qrsay(XNIVEL+1,CGM->Municipio)

   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXCLUIR TRANSPORTADORA _______________________________________

static function i_exclusao
   if qconf("Confirma exclus„o desta Transportadora ?")
      if TRANSP->(qrlock())
         TRANSP->(dbdelete())
         TRANSP->(qunlock())
      else
         qm3()
      endif
   endif
return
