/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE CONTAS A PAGAR/RECEBER
// OBJETIVO...: MANUTENCAO DE FORNECEDORES
// ANALISTA...:
// PROGRAMADOR:
// INICIO.....: NOVEMBRO DE 1996
// OBS........:
// ALTERACOES.:

function pg101

PLAN->(dbsetorder(3))  // codigo reduzido

FORN->(qview({{"Codigo/C¢digo"                ,1},;
              {"left(Razao,47)/Raz„o"         ,2},;
              {"fu_conv_cgccpf(CGCCPF)/CNPJ",3}},"P",;
              {NIL,"c101a",NIL,NIL},;
               NIL,q_msg_acesso_usr()))

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function c101a
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))
   if cOPCAO $ XUSRA
      qlbloc(5,0,"B101A","QBLOC.GLO",1)
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
   local bESCAPE := {||empty(fCGCCPF).or.(XNIVEL==2.and.!XFLAG).or.!empty(fCGCCPF).and.XNIVEL==2.and.Lastkey()==27.or.;
                       (XNIVEL==2.and.cOPCAO=="A".and.!XFLAG)}

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"
      XNIVEL := 1
      qrsay ( XNIVEL++ , FORN->Codigo    )
      qrsay ( XNIVEL++ , fu_conv_cgccpf( FORN->Cgccpf ) )
      qrsay ( XNIVEL++ , FORN->Inscricao )
      qrsay ( XNIVEL++ , FORN->Razao     )
      qrsay ( XNIVEL++ , FORN->Fantasia  )
                                                                                                     qrsay ( XNIVEL++ , FORN->End_ent   )
      qrsay ( XNIVEL++ , FORN->Cgm_ent   ) ; CGM->(dbseek(FORN->Cgm_ent))
      qrsay ( XNIVEL++ , CGM->Municipio )
      qrsay ( XNIVEL++ , CGM->Estado    )
      qrsay ( XNIVEL++ , FORN->Cep_ent , "@R 99.999-999" )

      qrsay ( XNIVEL++ , FORN->End_cob   )
      qrsay ( XNIVEL++ , FORN->Cgm_cob   ) ; CGM->(dbseek(FORN->Cgm_cob))
      qrsay ( XNIVEL++ , CGM->Municipio )
      qrsay ( XNIVEL++ , CGM->Estado    )
      qrsay ( XNIVEL++ , FORN->Cep_cob , "@R 99.999-999" )

      qrsay ( XNIVEL++ , FORN->Cod_Rep  ) ; REPRES->(dbseek(FORN->Cod_rep))
      qrsay ( XNIVEL++ , left(REPRES->Razao,41))

      qrsay ( XNIVEL++ , FORN->Fone1     )
      qrsay ( XNIVEL++ , FORN->Ramal1    )
      qrsay ( XNIVEL++ , FORN->Fone2     )
      qrsay ( XNIVEL++ , FORN->Ramal2    )
      qrsay ( XNIVEL++ , FORN->Fone_venda)
      qrsay ( XNIVEL++ , FORN->Ramal_vend)
      qrsay ( XNIVEL++ , FORN->Fax       )
      qrsay ( XNIVEL++ , FORN->Foner     )
      qrsay ( XNIVEL++ , FORN->Contato_c )
      qrsay ( XNIVEL++ , FORN->Contato_f )
      qrsay ( XNIVEL++ , FORN->Conta_cont, "@R 99999-9"           ) ; PLAN->(Dbseek(FORN->Conta_cont))
      qrsay ( XNIVEL++ , iif(FORN->Conta_cont <> space(6),PLAN->Descricao," "))

      qrsay ( XNIVEL++ , FORN->Filial    ) ; FILIAL->(dbseek(FORN->Filial))
      qrsay ( XNIVEL++ , left(FILIAL->Razao,50))
   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || NIL                                                 },"CODIGO"    })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fCGCCPF       ,"@R 99.999.999/9999-99") },"CGCCPF"    })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fINSCRICAO    ,"@!")                    },"INSCRICAO" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fRAZAO        ,"@!"   ,"!empty(@)",.T.) },"RAZAO"     })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fFANTASIA     ,"@!")                    },"FANTASIA"  })

   aadd(aEDICAO,{{ || qgetx(-1,0,@fEND_ENT      ,"@!")                    },"END_ENT"   })
   aadd(aEDICAO,{{ || view_cgm(-1,0,@fCGM_ENT)                            },"CGM_ENT"   })
   aadd(aEDICAO,{{ || NIL                                                 },NIL         })
   aadd(aEDICAO,{{ || NIL                                                 },NIL         })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fCEP_ENT      ,"@R 99.999-999")         },"CEP_ENT"   })

   aadd(aEDICAO,{{ || qgetx(-1,0,@fEND_COB      ,"@!")                    },"END_COB"   })
   aadd(aEDICAO,{{ || view_cgm(-1,0,@fCGM_COB)                            },"CGM_COB"   })
   aadd(aEDICAO,{{ || NIL                                                 },NIL         })
   aadd(aEDICAO,{{ || NIL                                                 },NIL         })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fCEP_COB      ,"@R 99.999-999")         },"CEP_COB"   })

   aadd(aEDICAO,{{ || view_repres(-1,0,@fCOD_REP)                         },"COD_REP"   })
   aadd(aEDICAO,{{ || NIL                                                 },NIL         })

   aadd(aEDICAO,{{ || qgetx(-1,0,@fFONE1        ,"@!")                    },"FONE1"     })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fRAMAL1       ,"@!")                    },"RAMAL1"    })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fFONE2        ,"@!")                    },"FONE2"     })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fRAMAL2       ,"@!")                    },"RAMAL2"    })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fFONE_VENDA   ,"@!")                    },"FONE_VENDA"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@fRAMAL_VEND   ,"@!")                    },"RAMAL_VEND"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@fFAX          ,"@!")                    },"FAX"       })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fFONER        ,"@!")                    },"FONER"     })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fCONTATO_C    ,"@!")                    },"CONTATO_C" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fCONTATO_F    ,"@!")                    },"CONTATO_F" })
   aadd(aEDICAO,{{ || view_plan(-1,0,@fCONTA_CONT ,"@R 99999-9")          },"CONTA_CONT"})
   aadd(aEDICAO,{{ || NIL                                                 },NIL         })
   aadd(aEDICAO,{{ || view_filial(-1,0,@fFILIAL)                          },"FILIAL"    })
   aadd(aEDICAO,{{ || NIL                                                 },NIL         })

   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   FORN->(qpublicfields())
   iif(cOPCAO=="I",FORN->(qinitfields()),FORN->(qcopyfields()))

   XNIVEL  := 2
   XFLAG   := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; FORN->(qreleasefields()) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif

   if ! quse(XDRV_CP,"CONFIG",{},,"PROV")
      qmensa("N„o foi possivel abrir CONFIG.DBF do Compras !","B")
      return .F.
   endif

   if cOPCAO == "I" .and. PROV->(qrlock())
      replace PROV->Cod_forn with PROV->Cod_forn + 1
      qrsay ( 1 , fCODIGO := strzero(PROV->Cod_forn,5) )
      qmensa("C¢digo Gerado: "+fCODIGO,"B")
      PROV->(qunlock())
   endif

   PROV->(dbclosearea())

   select FORN

   if FORN->(iif(cOPCAO=="I",qappend(),qrlock()))

      // AGORA GRAVA E DESTRAVA ARQUIVO _____________________________________

      FORN->(qreplacefields())

   else

      if empty(FORN->Codigo) .and. empty(FORN->Razao) .and. empty(FORN->Cgccpf)
         FORN->(dbdelete())
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

      case cCAMPO == "CODIGO" .and. cOPCAO == "I"

           if FORN->(dbseek(fCODIGO))
              qmensa("Fornecedor j  cadastrado !","B")
              return .F.
           endif

      case cCAMPO == "CGCCPF"

           zTMP := .T.

           qrsay(XNIVEL,fu_conv_cgccpf(fCGCCPF) )
           do case
              case len(alltrim(fCGCCPF)) == 14
                   zTMP := qcheckcgc(fCGCCPF)
              case len(alltrim(fCGCCPF)) == 11
                   zTMP := qcheckcpf(fCGCCPF)
              otherwise
                   zTMP := .F.
           endcase

           if ! zTMP
              qmensa("CGC inv lido !","B")
              return .F.
           endif

           return i_check_cgc_dup()

      case cCAMPO == "CONTA_CONT"
           if ! empty(fCONTA_CONT)
              if ! PLAN->(dbseek(fCONTA_CONT))
                 qmensa("C¢digo da Conta Cont bil n„o encontrada !","B")
                 fCONTA_CONT := space(7)
                 return .F.
              endif
              qrsay(XNIVEL+1,left(PLAN->Descricao,38))
           endif

      case cCAMPO == "CGM_COB"

           if ! CGM->(dbseek(fCGM_COB))
              qmensa("Cgm n„o encontrado !","B")
              return .F.
           endif

           qrsay(XNIVEL+1,CGM->Municipio)
           qrsay(XNIVEL+2,CGM->Estado)

      case cCAMPO == "CGM_ENT"

           if ! CGM->(dbseek(fCGM_ENT))
              qmensa("Cgm n„o encontrado !","B")
              return .F.
           endif

           qrsay(XNIVEL+1,CGM->Municipio)
           qrsay(XNIVEL+2,CGM->Estado)

      case cCAMPO == "CEP_ENT"

           if len(alltrim(fCEP_ENT)) <> 8
              qmensa("C.E.P. incorreto !","B")
              return .F.
           endif

           if cOPCAO == "I"
              fEND_COB := fEND_ENT
              fCGM_COB := fCGM_ENT
              fCEP_COB := fCEP_ENT
           endif

      case cCAMPO == "CEP_COB"

           if len(alltrim(fCEP_COB)) <> 8
              qmensa("C.E.P. incorreto !","B")
              return .F.
           endif

      case cCAMPO == "COD_REP"

           if ! empty(fCOD_REP)

              if ! REPRES->(dbseek(fCOD_REP:=strzero(val(fCOD_REP),5)))
                 qmensa("Representante n„o encontrada !","B")
                 return .F.
              endif
              qrsay(XNIVEL+1,left(REPRES->Razao,41))

           endif

      case cCAMPO == "FILIAL"

           if ! FILIAL->(dbseek(fFILIAL))
              qmensa("Filial n„o encontrada !","B")
              return .F.
           endif

           qrsay(XNIVEL+1,left(FILIAL->Razao,50))


   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// CHECAR CGC DUPLICADO _____________________________________________________

static function i_check_cgc_dup

   local lFLAG, nRESP

   local nRECNO := FORN->(recno())

   local nORDER := FORN->(indexord())

   FORN->(dbsetorder(3)) // muda para cgc...

   lFLAG := FORN->(dbseek(fCGCCPF))

   if cOPCAO == "A" .and. fCODIGO == FORN->Codigo
      lFLAG := .F.
   endif

   FORN->(dbsetorder(nORDER)) // retorna ao original...

   if ! lFLAG

      FORN->(dbgoto(nRECNO))

   else

      do while .T.

         nRESP := alert("CGC DUPLICADO !",{"Corrigir","Aceitar","Localizar"})

         do case
            case nRESP == 1
                 FORN->(dbgoto(nRECNO))
                 return .F.
            case nRESP == 2
                 FORN->(dbgoto(nRECNO))
                 return .T.
            case nRESP == 3 // para acionar bESCAPE...
                 XNIVEL := -1
                 return .T.
            otherwise
                 loop
         endcase

      enddo

   endif

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXCLUIR FORNECEDOR ___________________________________________

static function i_exclusao
   if qconf("Confirma exclus„o deste Fornecedor  ?")
      if FORN->(qrlock())
         FORN->(dbdelete())
         FORN->(qunlock())
      else
         qm3()
      endif
   endif
return

