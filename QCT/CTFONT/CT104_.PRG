/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE CONTABILIDADE
// OBJETIVO...: MANUTENCAO DE FILIAL
// ANALISTA...:
// PROGRAMADOR:
// INICIO.....: JANEIRO DE 1997
// OBS........:
// ALTERACOES.:
//             {"fu_conv_cgccpf(CGCCPF)/C.G.C.",3}},"P",;
function ct104

private sBLOC1  := qlbloc("B104B","QBLOC.GLO")
private cPICT

FILIAL->(qview({{"Codigo/C¢digo"               ,1},;
               {"left(Razao,40)/Raz„o"         ,2},;
               {"c104b()/Cidade"               ,0}},"P",;
               {NIL,"c104a",NIL,NIL},;
                NIL,q_msg_acesso_usr()))

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function c104a
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))
   if cOPCAO $ XUSRA
      qlbloc(08,0,"B104A","QBLOC.GLO",1)
      qmensa(qabrev(cOPCAO,"IA",{"Inclus„o... <ESC - Cancela>","Altera‡„o... <ESC - Cancela>"}))
      i_edicao()
   endif
   setcursor(nCURSOR)
return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA RETORNAR A CIDADE ____________________________________________

function c104b
   CGM->(dbseek(FILIAL->Cgm))
return left(CGM->Municipio,26)

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA ____________________________________

static function i_edicao
   local lCONF   := .F.
   local aEDICAO := {}
   local bESCAPE := {||empty(fTIPO_INSC).or.(XNIVEL==2.and.!XFLAG).or.(!empty(fTIPO_INSC) .and. XNIVEL==2 .and. Lastkey()==27) .or.;
                       (XNIVEL==2.and.cOPCAO=="A".and.!XFLAG)}

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"
      XNIVEL := 1

      qrsay ( XNIVEL++ , FILIAL->Codigo    )

      qrsay ( XNIVEL++, qabrev(FILIAL->Tipo_insc,"123", {"CNPJ","CEI","CPF"}))

      qrsay ( XNIVEL++ , fu_conv_cgccpf( FILIAL->Cgccpf ) )

      qrsay ( XNIVEL++ , FILIAL->Cod_int)

      qrsay ( XNIVEL++ , FILIAL->Insc_estad)
      qrsay ( XNIVEL++ , FILIAL->Insc_munic)
      qrsay ( XNIVEL++ , FILIAL->Insc_ST)

      qrsay ( XNIVEL++ , FILIAL->Razao     )
      qrsay ( XNIVEL++ , FILIAL->Fantasia  )

      qrsay ( XNIVEL++ , FILIAL->Endereco  )
      qrsay ( XNIVEL++ , str(FILIAL->Numero,5))
      qrsay ( XNIVEL++ , FILIAL->Compl     )

      qrsay ( XNIVEL++ , FILIAL->Bairro    )

      qrsay ( XNIVEL++ , FILIAL->Telefone  )
      qrsay ( XNIVEL++ , FILIAL->Fax       )

      qrsay ( XNIVEL++ , FILIAL->Cgm       ) ; CGM->(dbseek(FILIAL->Cgm))
      qrsay ( XNIVEL++ , CGM->Municipio )


      qrsay ( XNIVEL++ , CGM->Estado    )
      qrsay ( XNIVEL++ , FILIAL->Cep , "@R 99.999-999" )

      qrsay ( XNIVEL++ , FILIAL->Contador)
      qrsay ( XNIVEL++ , FILIAL->Crc     )
      qrsay ( XNIVEL++ , FILIAL->Cpf_contad)

   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || NIL                                                 },"CODIGO"    })
   aadd(aEDICAO,{{ || qesco(-1,0,@fTIPO_INSC    ,sBLOC1                  )} ,"TIPO_INSC"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@fCGCCPF       ,"@!"                    )},"CGCCPF"    })

   aadd(aEDICAO,{{ || qgetx(-1,0,@fCOD_INT      ,"@!")                    },"COD_INT"})

   aadd(aEDICAO,{{ || qgetx(-1,0,@fINSC_ESTAD   ,"@!")                    },"INSC_ESTAD"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@fINSC_MUNIC   ,"@!")                    },"INSC_MUNIC"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@fINSC_ST      ,"@!")                    },"INSC_ST"})

   aadd(aEDICAO,{{ || qgetx(-1,0,@fRAZAO        ,"@!"   ,"!empty(@)",.T.) },"RAZAO"     })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fFANTASIA     ,"@!")                    },"FANTASIA"  })

   aadd(aEDICAO,{{ || qgetx(-1,0,@fENDERECO     ,"@!")                    },"ENDERECO"  })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fNUMERO       ,"99999")                 },"NUMERO"    })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fCOMPL        ,"@!")                    },"COMPL"     })

   aadd(aEDICAO,{{ || qgetx(-1,0,@fBAIRRO       ,"@!")                    },"BAIRRO"    })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fTELEFONE     ,"@!")                    },"TELEFONE"  })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fFAX          ,"@!")                    },"FAX"       })

   aadd(aEDICAO,{{ || view_cgm(-1,0,@fCGM)                                },"CGM"       })
   aadd(aEDICAO,{{ || NIL                                                 },NIL         })
   aadd(aEDICAO,{{ || NIL                                                 },NIL         })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fCEP          ,"@R 99.999-999")         },"CEP"       })

   aadd(aEDICAO,{{ || qgetx(-1,0,@fCONTADOR     ,"@!")                    },"CONTADOR"  })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fCRC          ,"@!")                    },"CRC"       })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fCPF_CONTAD   ,"@!")                    },"CPF"       })

   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   FILIAL->(qpublicfields())
   iif(cOPCAO=="I",FILIAL->(qinitfields()),FILIAL->(qcopyfields()))

   XNIVEL  := 2
   XFLAG   := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; FILIAL->(qreleasefields()) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif

   if CONFIG->(qrlock()) .and. FILIAL->(iif(cOPCAO=="I",qappend(),qrlock()))

      // AQUI INCREMENTA CODIGO DO FILIALECEDOR _______________________________

      if cOPCAO == "I"
         replace CONFIG->Cod_filial with CONFIG->Cod_filial + 1
         qrsay ( 1 , fCODIGO := strzero(CONFIG->Cod_filial,4) )
         qmensa("C¢digo Gerado: "+fCODIGO,"B")
      endif

      // AGORA GRAVA E DESTRAVA ARQUIVO _____________________________________

      if fTIPO_INSC == "2"
         fCGCCPF := strzero(val(fCGCCPF),14)
      endif

      FILIAL->(qreplacefields())

   else

      if empty(FILIAL->Codigo) .and. empty(FILIAL->Razao) .and. empty(FILIAL->Cgccpf)
         FILIAL->(dbdelete())
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

           if FILIAL->(dbseek(fCODIGO))
              qmensa("Filial j  cadastrado !","B")
              return .F.
           endif

      case cCAMPO == "TIPO_INSC"
           if empty(fTIPO_INSC) ; return .F. ; endif
           qrsay(XNIVEL,qabrev(fTIPO_INSC,"123",{"CNPJ","CEI","CPF"}))

      case cCAMPO == "CGCCPF"

           zTMP := .T.

           do case
              case fTIPO_INSC == "1"
                   zTMP := qcheckcgc(fCGCCPF)
              case fTIPO_INSC == "3"
                   zTMP := qcheckcpf(fCGCCPF)
              otherwise
                   zTMP := .F.
           endcase

           if ! zTMP .and. fTIPO_INSC <> "2"
              qmensa("CGC inv lido !","B")
              return .F.
           endif

      case cCAMPO == "CGM"

           if ! CGM->(dbseek(fCGM))
              qmensa("Cgm n„o encontrado !","B")
              return .F.
           endif

           qrsay(XNIVEL+1,CGM->Municipio)
           qrsay(XNIVEL+2,CGM->Estado)


      case cCAMPO == "CEP"

           if len(alltrim(fCEP)) <> 8
              qmensa("C.E.P. incorreto !","B")
              return .F.
           endif

      case cCAMPO == "CPF"

           if ! qcheckcpf(fCPF_CONTAD)
              qmensa("CPF do Contador Invalido!","BL")
              return .F.
           endif

   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// CHECAR CGC DUPLICADO _____________________________________________________

static function i_check_cgc_dup

   local lFLAG, nRESP

   local nRECNO := FILIAL->(recno())

   local nORDER := FILIAL->(indexord())

   FILIAL->(dbsetorder(3)) // muda para cgc...

   lFLAG := FILIAL->(dbseek(fCGCCPF))

   if cOPCAO == "A" .and. fCODIGO == FILIAL->Codigo
      lFLAG := .F.
   endif

   FILIAL->(dbsetorder(nORDER)) // retorna ao original...

   if ! lFLAG

      FILIAL->(dbgoto(nRECNO))

   else

      do while .T.

         nRESP := alert("CGC DUPLICADO !",{"Corrigir","Aceitar","Localizar"})

         do case
            case nRESP == 1
                 FILIAL->(dbgoto(nRECNO))
                 return .F.
            case nRESP == 2
                 FILIAL->(dbgoto(nRECNO))
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
// FUNCAO PARA EXCLUIR FILIALECEDOR ___________________________________________

static function i_exclusao
   if qconf("Confirma exclus„o desta Filial ?")
      if FILIAL->(qrlock())
         FILIAL->(dbdelete())
         FILIAL->(qunlock())
      else
         qm3()
      endif
   endif
return

