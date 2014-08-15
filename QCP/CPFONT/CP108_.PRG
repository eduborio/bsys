/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE COMPRAS
// OBJETIVO...: MANUTENCAO DE REPRESENTANTE COMERCIAL
// ANALISTA...:
// PROGRAMADOR:
// INICIO.....: NOVEMBRO DE 1996
// OBS........:
// ALTERACOES.:

function cp108

REPRES->(qview({{"Codigo/C¢digo"              ,1},;
              {"left(Razao,47)/Raz„o"         ,2},;
              {"fu_conv_cgccpf(CGCCPF)/C.G.C.",3}},"P",;
              {NIL,"c108a",NIL,NIL},;
               NIL,q_msg_acesso_usr()))

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function c108a
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))
   if cOPCAO $ XUSRA
      qlbloc(6,0,"B108A","QBLOC.GLO",1)
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
      qrsay ( XNIVEL++ , REPRES->Codigo    )

      qrsay ( XNIVEL++ , fu_conv_cgccpf( REPRES->Cgccpf ) )

      qrsay ( XNIVEL++ , REPRES->Inscricao )
      qrsay ( XNIVEL++ , REPRES->Razao     )
      qrsay ( XNIVEL++ , REPRES->Fantasia  )

      qrsay ( XNIVEL++ , REPRES->Cod_resp) ; RESP_REP->(dbseek(REPRES->Cod_resp))
      qrsay ( XNIVEL++ , RESP_REP->Nome )

      qrsay ( XNIVEL++ , REPRES->End_ent   )
      qrsay ( XNIVEL++ , REPRES->Cgm_ent   ) ; CGM->(dbseek(REPRES->Cgm_ent))
      qrsay ( XNIVEL++ , CGM->Municipio )
      qrsay ( XNIVEL++ , CGM->Estado    )
      qrsay ( XNIVEL++ , REPRES->Cep_ent , "@R 99.999-999" )

      qrsay ( XNIVEL++ , REPRES->End_cob   )
      qrsay ( XNIVEL++ , REPRES->Cgm_cob   ) ; CGM->(dbseek(REPRES->Cgm_cob))
      qrsay ( XNIVEL++ , CGM->Municipio )
      qrsay ( XNIVEL++ , CGM->Estado    )
      qrsay ( XNIVEL++ , REPRES->Cep_cob , "@R 99.999-999" )

      qrsay ( XNIVEL++ , REPRES->Fone1     )
      qrsay ( XNIVEL++ , REPRES->Ramal1    )
      qrsay ( XNIVEL++ , REPRES->Fone2     )
      qrsay ( XNIVEL++ , REPRES->Ramal2    )
      qrsay ( XNIVEL++ , REPRES->Fax       )
      qrsay ( XNIVEL++ , REPRES->Foner     )
      qrsay ( XNIVEL++ , REPRES->Contato_c )
      qrsay ( XNIVEL++ , REPRES->Contato_f )
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
   aadd(aEDICAO,{{ || view_resp(-1,0,@fCod_resp)                          },"RESP"      })
   aadd(aEDICAO,{{ || NIL                                                 },NIL         })


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

   aadd(aEDICAO,{{ || qgetx(-1,0,@fFONE1        ,"@!")                    },"FONE1"     })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fRAMAL1       ,"@!")                    },"RAMAL1"    })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fFONE2        ,"@!")                    },"FONE2"     })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fRAMAL2       ,"@!")                    },"RAMAL2"    })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fFAX          ,"@!")                    },"FAX"       })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fFONER        ,"@!")                    },"FONER"     })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fCONTATO_C    ,"@!")                    },"CONTATO_C" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fCONTATO_F    ,"@!")                    },"CONTATO_F" })

   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   REPRES->(qpublicfields())
   iif(cOPCAO=="I",REPRES->(qinitfields()),REPRES->(qcopyfields()))

   XNIVEL  := 2
   XFLAG   := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; REPRES->(qreleasefields()) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif

   if CONFIG->(qrlock()) .and. REPRES->(iif(cOPCAO=="I",qappend(),qrlock()))

      // AQUI INCREMENTA CODIGO DO REPRESENTANTE _____________________________

      if cOPCAO == "I"
         replace CONFIG->Cod_rep with CONFIG->Cod_rep + 1
         qrsay ( 1 , fCODIGO := strzero(CONFIG->Cod_rep,5) )
         qmensa("C¢digo Gerado: "+fCODIGO,"B")
      endif

      // AGORA GRAVA E DESTRAVA ARQUIVO _____________________________________

      REPRES->(qreplacefields())

   endif

   dbunlockall()

   if cOPCAO == "I" ; keyboard "I" ; endif

return


// CRITICA DE EDICAO ________________________________________________________

static function i_critica ( cCAMPO )

   local zTMP

   if ! XFLAG ; return .T. ; endif

   do case

      case cCAMPO == "CODIGO" .and. cOPCAO == "I"

           if REPRES->(dbseek(fCODIGO))
              qmensa("Representante j  cadastrado !","B")
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

      case cCAMPO == "CGM_COB"

           if ! CGM->(dbseek(fCGM_COB))
              qmensa("Cgm n„o encontrado !","B")
              return .F.
           endif

           qrsay(XNIVEL+1,CGM->Municipio)
           qrsay(XNIVEL+2,CGM->Estado)

      case cCAMPO == "RESP"

           if ! empty(fCod_Resp)
              qrsay(XNIVEL,fCod_resp := strzero(val(fCod_resp),5))
           endif


           if ! RESP_REP->(dbseek(fCod_resp))
              qmensa("Responsavel n„o encontrado !","B")
              return .F.
           endif

           qrsay(XNIVEL+1,RESP_REP->Nome)


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

   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// CHECAR CGC DUPLICADO _____________________________________________________

static function i_check_cgc_dup

   local lFLAG, nRESP

   local nRECNO := REPRES->(recno())

   local nORDER := REPRES->(indexord())

   REPRES->(dbsetorder(3)) // muda para cgc...

   lFLAG := REPRES->(dbseek(fCGCCPF))

   if cOPCAO == "A" .and. fCODIGO == REPRES->Codigo
      lFLAG := .F.
   endif

   REPRES->(dbsetorder(nORDER)) // retorna ao original...

   if ! lFLAG

      REPRES->(dbgoto(nRECNO))

   else

      do while .T.

         nRESP := alert("CGC DUPLICADO !",{"Corrigir","Aceitar","Localizar"})

         do case
            case nRESP == 1
                 REPRES->(dbgoto(nRECNO))
                 return .F.
            case nRESP == 2
                 REPRES->(dbgoto(nRECNO))
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
// FUNCAO PARA EXCLUIR REPRESENTANTE _______________________________________

static function i_exclusao
   if qconf("Confirma exclus„o deste Representante ?")
      if REPRES->(qrlock())
         REPRES->(dbdelete())
         REPRES->(qunlock())
      else
         qm3()
      endif
   endif
return

