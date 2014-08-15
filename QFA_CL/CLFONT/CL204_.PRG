/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO COMERCIAL
// OBJETIVO...: LANCAMENTO DE CONH DE FRETE
// ANALISTA...: EDUARDO BORIO
// PROGRAMADOR: EDUARDO BORIO
// INICIO.....: MAIO DE 2006
// OBS........:
// ALTERACOES.:

function cl204
private sBLOC1 := XSN

FRETE->(qview({{"dtoc(Dt_emissao)/Emissao"       ,2},;
             {"Num_fatura/Conhecimento"     ,1},;
             {"i_204cli()/Cliente"          ,0},;
             {"i_204frn()/Fornecedor"       ,0}},"P",;
             {NIL,"c204a",NIL,NIL},;
             NIL,q_msg_acesso_usr()))


function i_204cli
   CLI1->(dbseek(FRETE->Cod_cli))
return left(CLI1->Razao,25)

function i_204frn
   FORN->(dbseek(FRETE->Cod_forn))
return left(FORN->Razao,25)


/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function c204a

   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO $ XUSRA

      qlbloc(5,0,"B204A","QBLOC.GLO",1)
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
   local bESCAPE := {||empty(fDT_EMISSAO).or.(XNIVEL==2.and.!XFLAG).or.!empty(fDT_EMISSAO).and.Lastkey()==27.or.;
                       (XNIVEL==2.and.cOPCAO=="A".and.!XFLAG)}

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"
      XNIVEL := 1
      qrsay ( XNIVEL++ , FRETE->Codigo     )
      qrsay ( XNIVEL++ , dtoc(FRETE->Dt_emissao) )
      qrsay ( XNIVEL++ , dtoc(FRETE->Dt_lanc) )
      qrsay ( XNIVEL++ , FRETE->Num_fatura,"999999")
      qrsay ( XNIVEL++ , FRETE->Especie); ESPECIE->(dbseek(FRETE->Especie))
      qrsay ( XNIVEL++ , ESPECIE->Descricao)
      qrsay ( XNIVEL++ , FRETE->Serie); SERIE->(dbseek(FRETE->Serie))
      qrsay ( XNIVEL++ , left(SERIE->Descricao,12))
      qrsay ( XNIVEL++ , FRETE->Cod_cli); CLI1->(dbseek(FRETE->Cod_cli))
      qrsay ( XNIVEL++ , left(CLI1->Razao,35))
      qrsay ( XNIVEL++ , FRETE->Cod_forn); FORN->(dbseek(FRETE->Cod_forn))
      qrsay ( XNIVEL++ , left(FORN->Razao,35))
      qrsay ( XNIVEL++ , FRETE->Cfop,"@R 9.999"); CFOP->(dbseek(FRETE->Cfop))
      qrsay ( XNIVEL++ , left(CFOP->Nat_desc,35))
      qrsay ( XNIVEL++ , FRETE->Tipocont,"999999"); TIPOCONT->(dbseek(FRETE->Tipocont))
      qrsay ( XNIVEL++ , left(TIPOCONT->Descricao,35))
      qrsay ( XNIVEL++ , FRETE->Vlr_total,"@E 99,999.99")
      qrsay ( XNIVEL++ , FRETE->Base_icm,"@E 99,999.99")
      qrsay ( XNIVEL++ , FRETE->Vlr_NF,"@E 999,999.99")

      qrsay ( XNIVEL++ , FRETE->Aliq_icm,"@E 99.99")
      qrsay ( XNIVEL++ , FRETE->Vlr_icm,"@E 99,999.99")
      qrsay ( XNIVEL++ , qabrev(FRETE->Faz_inter,"SN",{"Sim","NÆo"}))
      qrsay ( XNIVEL++ , dtoc(FRETE->Dt_venc) )




   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || NIL                                                 },"CODIGO"  })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDT_EMISSAO,"@D")                       },"DT_EMISSAO"    })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDT_LANC,"@D")                       },"DT_LANC"    })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fNUM_FATURA,"999999")                   },"NUM_FATURA"   })
   aadd(aEDICAO,{{ || view_especie(-1,0,@fESPECIE,"99")                          },"ESPECIE"   })
   aadd(aEDICAO,{{ || NIL },NIL }) // razao do cliente
   aadd(aEDICAO,{{ || view_serie(-1,0,@fSERIE,"99")                          },"SERIE"   })
   aadd(aEDICAO,{{ || NIL },NIL }) // razao do cliente


   aadd(aEDICAO,{{ || view_cli2(-1,0,@fCOD_CLI                          )} ,"COD_CLI"      })
   aadd(aEDICAO,{{ || NIL },NIL }) // razao do cliente

   aadd(aEDICAO,{{ || view_forn(-1,0,@fCOD_FORN                          )} ,"COD_FORN"      })
   aadd(aEDICAO,{{ || NIL },NIL }) // razao do cliente

   aadd(aEDICAO,{{ || view_cfop(-1,0,@fCFOP                          )} ,"CFOP"      })
   aadd(aEDICAO,{{ || NIL },NIL }) // razao do cliente

   aadd(aEDICAO,{{ || view_tipocont(-1,0,@fTIPOCONT,"999999"                          )} ,"TIPOCONT"      })
   aadd(aEDICAO,{{ || NIL },NIL }) // razao do cliente

   aadd(aEDICAO,{{ || qgetx(-1,0,@fVLR_TOTAL,"@E 99,999.99")                   },"VLR_TOTAL"   })

   aadd(aEDICAO,{{ || qgetx(-1,0,@fBASE_ICM,"@E 99,999.99")                   },"BASE_ICM"   })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fVLR_NF,"@E 999,999.99")                   },"VLR_TOTAL"   })

   aadd(aEDICAO,{{ || qgetx(-1,0,@fALIQ_ICM,"@E 99.99")                   },"ALIQ_ICM"   })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fVLR_ICM,"@E 99,999.99")                },"VLR_ICM"   })
   aadd(aEDICAO,{{ || qesco(-1,0,@fFAZ_INTER,sBLOC1                    )}   ,"FAZ_INTER"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDT_VENC,"@D")                       },"DT_VENC"    })






   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   FRETE->(qpublicfields())
   iif(cOPCAO=="I",FRETE->(qinitfields()),FRETE->(qcopyfields()))

   XNIVEL  := 2
   XFLAG   := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; FRETE->(qreleasefields()) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif

   if CONFIG->(qrlock()) .and. FRETE->(iif(cOPCAO=="I",qappend(),qrlock()))


      // AQUI INCREMENTA CODIGO DO CLIENTE __________________________________

      if cOPCAO == "I"
         replace CONFIG->Cod_frete with CONFIG->Cod_frete + 1
         qrsay ( 1 , fCODIGO := strzero(CONFIG->Cod_frete,6) )
         qmensa("C¢digo Gerado: "+fCODIGO,"B")
         if fFAZ_INTER == "N"
            fPAGAR := .T.
            fCONTABIL := .T.
            fFISCAL   := .T.
         endif

      endif
      fCODIGO:=strzero(val(fCODIGO),5)

      FRETE->(qreplacefields())

   else

      if empty(FRETE->Codigo) .and. empty(FRETE->Nome)
         FRETE->(dbdelete())
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
   local nReg   := 0
   local nIndex := 0

   if ! XFLAG ; return .T. ; endif

   do case

      case cCAMPO == "NOME"
           if empty(fDT_EMISSAO) ; return .F. ; endif

      case cCAMPO == "NUM_FATURA"
           fESPECIE    := "17"
           fTIPOCONT   := "100006"
           fSERIE      := "41"
           fINTERFACE  := "S"

           if empty(fNUM_FATURA) ; return .F. ; endif
           qrsay(XNIVEL,fNUM_FATURA := strzero(val(fNUM_FATURA),6))

      case cCAMPO == "ESPECIE"

           if empty(fESPECIE) ; return .F. ; endif
           qrsay(XNIVEL,fESPECIE:=strzero(val(fESPECIE),2))
           if ! ESPECIE->(dbseek(fESPECIE))
              qmensa("Especie n„o encontrada !","B")
              return .F.
           endif
           qrsay(XNIVEL+1,left(ESPECIE->Descricao,40))

      case cCAMPO == "SERIE"

           if empty(fSERIE) ; return .F. ; endif
           qrsay(XNIVEL,fSERIE:=strzero(val(fSERIE),2))
           if ! SERIE->(dbseek(fSERIE))
              qmensa("Serie n„o encontrada !","B")
              return .F.
           endif
           qrsay(XNIVEL+1,left(SERIE->Descricao,12))


      case cCAMPO == "COD_CLI"



           if empty(fCOD_CLI) ; return .F. ; endif
           qrsay(XNIVEL,fCOD_CLI:=strzero(val(fCOD_CLI),5))
           if ! CLI1->(dbseek(fCOD_CLI))
              qmensa("Cliente n„o encontrado !","B")
              return .F.
           endif
           qrsay(XNIVEL+1,left(CLI1->Razao,40))

      case cCAMPO == "COD_FORN"

           if empty(fCOD_FORN) ; return .F. ; endif
           qrsay(XNIVEL,fCOD_FORN:=strzero(val(fCOD_FORN),5))
           if ! FORN->(dbseek(fCOD_FORN))
              qmensa("Fornecedor n„o encontrado !","B")
              return .F.
           endif

           nReg := FRETE->(Recno())
           nIndex := FRETE->(IndexOrd())

           FRETE->(dbsetorder(4))
           if FRETE->(dbseek(fNUM_FATURA+fCOD_FORN))
              qmensa("Frete ja lancado. Data de Emissao.: "+dtoc(FRETE->dt_emissao)+".","BL")
              return .F.
           endif

           FRETE->(dbsetorder(nIndex))
           FRETE->(dbgoto(nReg))

           qrsay(XNIVEL+1,left(FORN->Razao,40))

      case cCAMPO == "CFOP"

           if empty(fCFOP) ; return .F. ; endif
           qrsay(XNIVEL,fCFOP,"@R 9.999")
           if ! CFOP->(dbseek(fCFOP))
              qmensa("Natureza da opera‡Æo n„o encontrada !","B")
              return .F.
           endif
           qrsay(XNIVEL+1,left(CFOP->Nat_desc,40))

      case cCAMPO == "TIPOCONT"

           if empty(fTIPOCONT) ; return .F. ; endif
           qrsay(XNIVEL,fTIPOCONT,"999999")
           if ! TIPOCONT->(dbseek(fTIPOCONT))
              qmensa("Tipo Cont bil n„o encontrado !","B")
              return .F.
           endif
           qrsay(XNIVEL+1,left(TIPOCONT->Descricao,40))

      case cCAMPO == "ALIQ_ICM"
           fVLR_ICM := fBASE_ICM * (fALIQ_ICM/100)

      case cCAMPO == "FAZ_INTER"
           if empty(fFAZ_INTER) ; return .F. ; endif
           qrsay(XNIVEL,qabrev(fFAZ_INTER,"SN",{"Sim","N„o"}))


   endcase

return .T.


/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXCLUIR VENDEDORA  ___________________________________________

static function i_exclusao
   if qconf("Confirma exclus„o deste(a) Conhecimento de Frete(a) ?")
      if FRETE->(qrlock())
         FRETE->(dbdelete())
         FRETE->(qunlock())
      else
         qm3()
      endif
   endif
return
