/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE COMPRAS
// OBJETIVO...: MANUTENCAO DE REPRESENTANTE COMERCIAL
// ANALISTA...:
// PROGRAMADOR:
// INICIO.....: NOVEMBRO DE 1996
// OBS........:
// ALTERACOES.:

function cp114

FABRICA->(qview({{"Codigo/C¢digo"              ,1},;
              {"left(Razao,47)/Raz„o"         ,2},;
              {"fu_conv_cgccpf(CGCCPF)/C.G.C.",3}},"P",;
              {NIL,"c114a",NIL,NIL},;
               NIL,q_msg_acesso_usr()))

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function c114a
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))
   if cOPCAO $ XUSRA
      qlbloc(6,0,"B114A","QBLOC.GLO",1)
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
      qrsay ( XNIVEL++ , FABRICA->Codigo    )

      qrsay ( XNIVEL++ , fu_conv_cgccpf( FABRICA->Cgccpf ) )

      qrsay ( XNIVEL++ , FABRICA->Inscricao )
      qrsay ( XNIVEL++ , FABRICA->Razao     )
      qrsay ( XNIVEL++ , FABRICA->Fantasia  )

      qrsay ( XNIVEL++ , FABRICA->End_ent   )
      qrsay ( XNIVEL++ , FABRICA->Cgm_ent   ) ; CGM->(dbseek(FABRICA->Cgm_ent))
      qrsay ( XNIVEL++ , CGM->Municipio )
      qrsay ( XNIVEL++ , CGM->Estado    )
      qrsay ( XNIVEL++ , FABRICA->Cep_ent , "@R 99.999-999" )

      qrsay ( XNIVEL++ , FABRICA->Fone1     )
      qrsay ( XNIVEL++ , FABRICA->Ramal1    )
      qrsay ( XNIVEL++ , FABRICA->Fone2     )
      qrsay ( XNIVEL++ , FABRICA->Ramal2    )
      qrsay ( XNIVEL++ , FABRICA->Fax       )
      qrsay ( XNIVEL++ , FABRICA->Contato_c )
      qrsay ( XNIVEL++ , FABRICA->Contato_f )
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

   aadd(aEDICAO,{{ || qgetx(-1,0,@fFONE1        ,"@!")                    },"FONE1"     })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fRAMAL1       ,"@!")                    },"RAMAL1"    })

   aadd(aEDICAO,{{ || qgetx(-1,0,@fFONE2        ,"@!")                    },"FONE2"     })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fRAMAL2       ,"@!")                    },"RAMAL2"    })

   aadd(aEDICAO,{{ || qgetx(-1,0,@fFAX          ,"@!")                    },"FAX"       })

   aadd(aEDICAO,{{ || qgetx(-1,0,@fCONTATO_C    ,"@!")                    },"CONTATO_C" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fCONTATO_F    ,"@!")                    },"CONTATO_F" })

   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   FABRICA->(qpublicfields())
   iif(cOPCAO=="I",FABRICA->(qinitfields()),FABRICA->(qcopyfields()))

   XNIVEL  := 2
   XFLAG   := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; FABRICA->(qreleasefields()) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif

   if CONFIG->(qrlock()) .and. FABRICA->(iif(cOPCAO=="I",qappend(),qrlock()))

      // AQUI INCREMENTA CODIGO DO REPRESENTANTE _____________________________

      if cOPCAO == "I"
         replace CONFIG->Cod_fabric with CONFIG->Cod_fabric + 1
         qrsay ( 1 , fCODIGO := strzero(CONFIG->Cod_fabric,5) )
         qmensa("C¢digo Gerado: "+fCODIGO,"B")
      endif

      // AGORA GRAVA E DESTRAVA ARQUIVO _____________________________________

      FABRICA->(qreplacefields())

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

           if FABRICA->(dbseek(fCODIGO))
              qmensa("Fabricante j  cadastrado !","B")
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
              qmensa("CNPJ inv lido !","B")
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


   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// CHECAR CGC DUPLICADO _____________________________________________________

static function i_check_cgc_dup

   local lFLAG, nRESP

   local nRECNO := FABRICA->(recno())

   local nORDER := FABRICA->(indexord())

   FABRICA->(dbsetorder(3)) // muda para cgc...

   lFLAG := FABRICA->(dbseek(fCGCCPF))

   if cOPCAO == "A" .and. fCODIGO == FABRICA->Codigo
      lFLAG := .F.
   endif

   FABRICA->(dbsetorder(nORDER)) // retorna ao original...

   if ! lFLAG

      FABRICA->(dbgoto(nRECNO))

   else

      do while .T.

         nRESP := alert("CNPJ DUPLICADO !",{"Corrigir","Aceitar","Localizar"})

         do case
            case nRESP == 1
                 FABRICA->(dbgoto(nRECNO))
                 return .F.
            case nRESP == 2
                 FABRICA->(dbgoto(nRECNO))
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
   if qconf("Confirma exclus„o deste Fabricante ?")
      if FABRICA->(qrlock())
         FABRICA->(dbdelete())
         FABRICA->(qunlock())
      else
         qm3()
      endif
   endif
return

