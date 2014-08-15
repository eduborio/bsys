/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE COMPRAS
// OBJETIVO...: MANUTENCAO DE FORNECEDOR
// ANALISTA...:
// PROGRAMADOR:
// INICIO.....: NOVEMBRO DE 1996
// OBS........:
// ALTERACOES.:

function cp101

private cALIAS
private cTIPO := "1"
PLAN->(dbsetorder(3))
do while .T.

   qsay(3,45,"       ")

   qlbloc(5,0,"B101B","QBLOC.GLO")

   qmensa("Escolha o tipo de manuten‡„o...")

   if empty ( cTIPO := qachoice(8,20,qlbloc("B101C","QBLOC.GLO"),cTIPO,1) ) ; return ; endif

   qsay(3,45,iif(cTIPO=="1","[ATIVO]","[MORTO]"))

   iif (cTIPO == "1", cALIAS := "FORN" , cALIAS := "FORN" + cTIPO )
   //  cALIAS := "FORN" + cTIPO

   (cALIAS)->(qview({{"Codigo/C¢digo"               ,1},;
                    {"left(Razao,47)/Raz„o"         ,2},;
                    {"fu_conv_cgccpf(CGCCPF)/CNPJ",3}},"P",;
                    {NIL,"c101a",NIL,NIL},;
                    NIL,;
                    iif(cTIPO=="1",q_msg_acesso_usr()+"<T>ransf.","ALT-O, ALT-P, <C>onsulta, <T>ransf.")))
enddo

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function c101a
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))
   iif(cOPCAO=="T",i_transf(),)
   if (cOPCAO $ XUSRA .and. cTIPO == "1") .or. ( cOPCAO == "C" .and. cTIPO == "2" )
   //if cOPCAO $ XUSRA
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
   local bESCAPE := {||empty(fCGCCPF).or.(XNIVEL==2.and.!XFLAG).or.!empty(fCGCCPF) .and. Lastkey()==27 .or.;
                       (XNIVEL==2.and.cOPCAO=="A".and.!XFLAG)}

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"
      XNIVEL := 1
      qrsay ( XNIVEL++ , (cALIAS)->Codigo                   )
      qrsay ( XNIVEL++ , fu_conv_cgccpf( (cALIAS)->Cgccpf ) )
      qrsay ( XNIVEL++ , (cALIAS)->Inscricao                )
      qrsay ( XNIVEL++,qabrev((cALIAS)->QUALIF,"SN",{"Qualificado","N„o Qualificado"}))

      qrsay ( XNIVEL++ , (cALIAS)->Tipo                     ) ; TIPO->(dbseek((cALIAS)->Tipo))
      qrsay ( XNIVEL++ , left(TIPO->Descricao,19)           )
      qrsay ( XNIVEL++ , (cALIAS)->Nivel                    )


      qrsay ( XNIVEL++ , (cALIAS)->Razao                    )
      qrsay ( XNIVEL++ , (cALIAS)->Fantasia                 )

      qrsay ( XNIVEL++ , (cALIAS)->End_ent                  )
      qrsay ( XNIVEL++ , (cALIAS)->Cgm_ent                  ) ; CGM->(dbseek((cALIAS)->Cgm_ent))
      qrsay ( XNIVEL++ , CGM->Municipio                     )
      qrsay ( XNIVEL++ , CGM->Estado                        )
      qrsay ( XNIVEL++ , (cALIAS)->Cep_ent ,"@R 99.999-999" )
      qrsay ( XNIVEL++ , (cALIAS)->Bairro_ent               )

      qrsay ( XNIVEL++ , (cALIAS)->End_cob                  )
      qrsay ( XNIVEL++ , (cALIAS)->Cgm_cob                  ) ; CGM->(dbseek((cALIAS)->Cgm_cob))
      qrsay ( XNIVEL++ , CGM->Municipio                     )
      qrsay ( XNIVEL++ , CGM->Estado                        )
      qrsay ( XNIVEL++ , (cALIAS)->Cep_cob ,"@R 99.999-999" )
      qrsay ( XNIVEL++ , (cALIAS)->Bairro_cob               )

      qrsay ( XNIVEL++ , (cALIAS)->Cod_Rep                  ) ; REPRES->(dbseek((cALIAS)->Cod_rep))
      qrsay ( XNIVEL++ , left(REPRES->Razao,41)             )

      qrsay ( XNIVEL++ , (cALIAS)->Fone1                    )
      qrsay ( XNIVEL++ , (cALIAS)->Ramal1                   )
      qrsay ( XNIVEL++ , (cALIAS)->Fone2                    )
      qrsay ( XNIVEL++ , (cALIAS)->Ramal2                   )
      qrsay ( XNIVEL++ , (cALIAS)->Fone_venda               )
      qrsay ( XNIVEL++ , (cALIAS)->Ramal_vend               )
      qrsay ( XNIVEL++ , (cALIAS)->Fax                      )
      qrsay ( XNIVEL++ , (cALIAS)->Foner                    )
      qrsay ( XNIVEL++ , (cALIAS)->Contato_c                )
      qrsay ( XNIVEL++ , (cALIAS)->Contato_f                )

      qrsay ( XNIVEL++ , (cALIAS)->Conta_cont,"@R 99999-9"  ) ; PLAN->(Dbseek((cALIAS)->Conta_cont))
      qrsay ( XNIVEL++ , iif((cALIAS)->Conta_cont <> space(6),PLAN->Descricao," "))

      qrsay ( XNIVEL++ , (cALIAS)->Filial                   ) ; FILIAL->(dbseek((cALIAS)->Filial))
      qrsay ( XNIVEL++ , left(FILIAL->Razao,50)             )
   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________
   SBLOC1 := qlbloc("B101D","GBLOC.GLO",1)
   aadd(aEDICAO,{{ || NIL                                                 },"CODIGO"    })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fCGCCPF       ,"@R 99.999.999/9999-99") },"CGCCPF"    })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fINSCRICAO    ,"@!")                    },"INSCRICAO" })

   aadd(aEDICAO,{{ || qesco(-1,0,@fQUALIF,XSN        )                    },"QUALIF"    })
   aadd(aEDICAO,{{ || view_tip2(-1,0,@fTIPO          )                    },"TIPO"      })
   aadd(aEDICAO,{{ || NIL                                                 },NIL         })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fNIVEL        ,"@!")                    },"NIVEL"  })


   aadd(aEDICAO,{{ || qgetx(-1,0,@fRAZAO        ,"@!"   ,"!empty(@)",.T.) },"RAZAO"     })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fFANTASIA     ,"@!")                    },"FANTASIA"  })

   aadd(aEDICAO,{{ || qgetx(-1,0,@fEND_ENT      ,"@!")                    },"END_ENT"   })
   aadd(aEDICAO,{{ || view_cgm(-1,0,@fCGM_ENT)                            },"CGM_ENT"   })
   aadd(aEDICAO,{{ || NIL                                                 },NIL         })
   aadd(aEDICAO,{{ || NIL                                                 },NIL         })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fCEP_ENT      ,"@R 99.999-999")         },"CEP_ENT"   })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fBAIRRO_ENT      ,"@!")                 },"BAIRRO_ENT"})

   aadd(aEDICAO,{{ || qgetx(-1,0,@fEND_COB      ,"@!")                    },"END_COB"   })
   aadd(aEDICAO,{{ || view_cgm(-1,0,@fCGM_COB)                            },"CGM_COB"   })
   aadd(aEDICAO,{{ || NIL                                                 },NIL         })
   aadd(aEDICAO,{{ || NIL                                                 },NIL         })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fCEP_COB      ,"@R 99.999-999")         },"CEP_COB"   })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fBAIRRO_COB     ,"@!")                  },"BAIRRO_COB"})

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

   if CONFIG->(qrlock()) .and. FORN->(iif(cOPCAO=="I",qappend(),qrlock()))

      // AQUI INCREMENTA CODIGO DO FORNECEDOR _______________________________

      if cOPCAO == "I"
         replace CONFIG->Cod_forn with CONFIG->Cod_forn + 1
         qrsay ( 1 , fCODIGO := strzero(CONFIG->Cod_forn,5) )
         qmensa("C¢digo Gerado: "+fCODIGO,"B")
      endif

      // AGORA GRAVA E DESTRAVA ARQUIVO _____________________________________

      FORN->(qreplacefields())

   else

      if empty(FORN->Codigo) .and. empty(FORN->Razao) .and. empty(FORN->Cgccpf)
         FORN->(dbdelete())
      endif

      iif(cOPCAO=="I",qm1(),qm2())

   endif

   select FORN

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

      case cCAMPO == "QUALIF"
           qrsay(XNIVEL,qabrev(fQUALIF,"SN",{"Qualificado","N„o Qualificado"}))

      case cCAMPO == "CONTA_CONT"
           if ! empty(fCONTA_CONT)
              if ! PLAN->(dbseek(fCONTA_CONT))
                 qmensa("C¢digo da Conta Cont bil n„o encontrada !","B")
                 fCONTA_CONT := space(7)
                 return .F.
              endif
              qrsay(XNIVEL+1,left(PLAN->Descricao,38))
           else
               quse(XDRV_CL,"CONFIG",,,"CFGFAT")
               if CFGFAT->Modelo_fat == "1"
                  qmensa("C¢digo da Conta Cont bil Obrigat¢rio!","B")
                  CFGFAT->(dbclosearea())

                  return .F.
               endif
               CFGFAT->(dbclosearea())

           endif

      case cCAMPO == "CGCCPF"

           zTMP := .T.

           qrsay(XNIVEL,fu_conv_cgccpf(fCGCCPF) )
           do case
              case len(alltrim(fCGCCPF)) == 14
                   if val(left(fCGCCPF,12)) == 0 .and. val(right(fCGCCPF,2)) <= 99
                      zTMP := .T.
                   else
                      zTMP := qcheckcgc(fCGCCPF)
                   Endif
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

      case cCAMPO == "BAIRRO_ENT"

           if cOPCAO $ "IA"
              fEND_COB    := fEND_ENT
              fCGM_COB    := fCGM_ENT
              fCEP_COB    := fCEP_ENT
              fBAIRRO_COB := fBAIRRO_ENT
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

      case cCAMPO == "TIPO"

           if ! TIPO->(dbseek(fTIPO))
              qmensa("Tipo n„o encontrado !","B")
              return .F.
           endif

           qrsay(XNIVEL+1,left(TIPO->Descricao,19))


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
   if qconf("Confirma exclus„o deste Fornecedor ?")
      if FORN->(qrlock())
         FORN->(dbdelete())
         FORN->(qunlock())
      else
         qm3()
      endif
   endif
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA TRANSFERENCIA ENTRE ARQUIVOS "FORN" E "FORN2" ______________

static function i_transf

   if ! qconf("Confirma transferencia para o arquivo "+iif(cTIPO=="1","morto","ativo")+" ?")
      return
   endif

   fu_transf(cTIPO,"FORN",(cALIAS)->Codigo)

return

