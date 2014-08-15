////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE ESCRITA FISCAL
// OBJETIVO...: GR-PR
// ANALISTA...: IN SUNG CHANG
// PROGRAMADOR: IN SUNG CHANG
// INICIO.....: ABRIL DE 1997
// OBS........:
// ALTERACOES.:
// ALTERACOES.:
function ef524

#define K_MAX_LIN 55

#include "ef.ch"

// VERIFICA SE FOI EXECUTADOS AS APURACOES ATNTES DE EMITIR ESTA OPCAO _____

private nVAL_REC := 0
private nVAL_BASE  := 0
private nALIQUOTA  := 0


// DECLARACAO E INICIALIZACAO DE VARIAVEIS _________________________________

private bESCAPE := {||(XNIVEL==1 .and. !XFLAG .or. lastkey()=27.and.XNIVEL==1) }

private aEDICAO := {}               // vetor para os campos de entrada de dados

private cPIC1   := "@E 999,999.99"

private cRAZAO     := space(50)
private cENDERECO  := space(50)
private cINSCR_EST := space(15)
private cCGCCPF    := space(18)
private cCGM       := space(6)
private cTELEFONE  := space(11)

private cRAZAO_DES := space(50)
private cCGM_DES   := "      "
private cINSCR_DES := space(18)

private cCOD_REC   := "1015        "
private dDATA_VENC := ctod("")
private cDOCUMENTO := space(11)
private cPLACA     := space(11)
private cCOD_PROD  := space(5)
private nVAL_MULTA := 0
private nVAL_ACRES := 0
private nVAL_JUROS := 0
private cOBS       := space(150)

private cFILIAL    := space(4)

// CRIACAO DO VETOR DE BLOCOS ______________________________________________

   aadd(aEDICAO,{{ || view_filial(-1,0,@cFILIAL                      ,NIL,NIL) } ,"FILIAL"   })
   aadd(aEDICAO,{{ || NIL                                                  } ,NIL        })
   aadd(aEDICAO,{{ || qgetx(-1,0,@cRAZAO     ,"@!"                   ,NIL,NIL) } ,"RAZAO"    })
   aadd(aEDICAO,{{ || qgetx(-1,0,@cENDERECO  ,"@!"                   ,NIL,NIL) } ,"ENDERECO" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@cINSCR_EST ,"@!"                   ,NIL,NIL) } ,"INSCR_EST"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@cCGCCPF    ,"@R 99.999.999/9999-99",NIL,NIL) } ,"CGCCPF"   })
   aadd(aEDICAO,{{ || view_cgm(-1,0,@cCGM                            ,NIL,NIL) } ,"CGM"      })
   aadd(aEDICAO,{{ || NIL                                                  } ,NIL        })
   aadd(aEDICAO,{{ || qgetx(-1,0,@cTELEFONE  ,"@!"                   ,NIL,NIL) } ,"TELEFONE" })

   aadd(aEDICAO,{{ || qgetx(-1,0,@cRAZAO_DES ,"@!"                   ,NIL,NIL) } ,"RAZAO_DES"})
   aadd(aEDICAO,{{ || view_cgm(-1,0,@cCGM_DES                        ,NIL,NIL) } ,"CGM_DES"  })
   aadd(aEDICAO,{{ || NIL                                                  } ,NIL        })
   aadd(aEDICAO,{{ || qgetx(-1,0,@cINSCR_DES ,"@!"                   ,NIL,NIL) } ,"INSCR_DES"})

   aadd(aEDICAO,{{ || qgetx(-1,0,@cCOD_REC   ,"@!"                   ,NIL,NIL) } ,"COD_REC"  })
   aadd(aEDICAO,{{ || qgetx(-1,0,@dDATA_VENC ,"@D"                   ,NIL,NIL) } ,"DATA_VENC"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@cDOCUMENTO ,"@!"                   ,NIL,NIL) } ,"DOCUMENTO"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@nVAL_BASE  ,"@E 9,999,999.99"      ,NIL,NIL) } ,"VAL_BASE" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@nALIQUOTA  ,"@E 999.99"            ,NIL,NIL) } ,"ALIQUOTA" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@cPLACA     ,"@!"                   ,NIL,NIL) } ,"PLACA"    })
   aadd(aEDICAO,{{ || view_prod(-1,0,@cCOD_PROD                      ,NIL,NIL) } ,"COD_PROD" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@nVAL_REC   ,"@E 999,999.99"        ,NIL,NIL) } ,"VAL_REC"  })
   aadd(aEDICAO,{{ || qgetx(-1,0,@nVAL_MULTA ,"@E 999,999.99"        ,NIL,NIL) } ,"VAL_MULTA"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@nVAL_ACRES ,"@E 999,999.99"        ,NIL,NIL) } ,"VAL_ACRES"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@nVAL_JUROS ,"@E 999,999.99"        ,NIL,NIL) } ,"VAL_JUROS"})

   aadd(aEDICAO,{{ || qgetx(-1,0,@cOBS       ,"@!@S51"                   ) } ,"OBS"      })

do while .T.

   XNIVEL := 1
   XFLAG  := .T.

   // SEGUNDO LOOP PARA ENTRADA DOS DADOS __________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; dbcloseall() ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   if ( i_inicializacao() , i_impressao() , NIL )

   qmensa("")

enddo

////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA ____________________________________________

static function i_critica ( cCAMPO )

   qmensa("")

   do case
      case cCAMPO == "FILIAL"
           if ! FILIAL->(dbseek(cFILIAL))
              qmensa("Filial n„o encontrada !","B")
              return .F.
           endif
           qrsay ( XNIVEL+1 , left(FILIAL->Razao,27))
           dDATA_INI := ctod("01/" + right(XANOMES,2) + "/" + left(XANOMES,4))
              if IMP->(dbseek(K_ICM + dtos(dDATA_INI) + dtos(qfimmes(dDATA_INI)) + alltrim(cFILIAL)))
                 if IMP->Apurado_e == .F. .or. IMP->Apurado_s == .F.
                   alert("Existem os lan‡amentos n„o Apuradas.; Por favor execute as apura‡”es !")
                   return .F.
                 endif
              endif

           cRAZAO := left(FILIAL->Razao,50)
           qrsay ( XNIVEL+2 , left(FILIAL->Razao,50))

           cENDERECO := FILIAL->Endereco
           qrsay ( XNIVEL+3 , FILIAL->Endereco)

           cINSCR_EST := transform(alltrim(qtiraponto(FILIAL->Insc_estad)),"@R 999.99999-99")
           qrsay ( XNIVEL+4 ,transform(alltrim(qtiraponto(FILIAL->Insc_estad)),"@R 999.99999-99") )

           cCGCCPF := FILIAL->Cgccpf
           qrsay ( XNIVEL+5 , transform(FILIAL->Cgccpf,"@R 99.999.999/9999-99"))

           cCGM := FILIAL->Cgm
           qrsay ( XNIVEL+6 , FILIAL->Cgm)

           cTELEFONE := FILIAL->Telefone
           qrsay ( XNIVEL+8 , FILIAL->Telefone)    //Alterado por Eduardo


      case cCAMPO == "CGM"
           if ! CGM->(dbseek(cCGM))
              qmensa("Municipio n„o encontrado !","B")
              return .F.
           endif
           qrsay ( XNIVEL+1 , left(CGM->Municipio,27) + "/" + CGM->Estado )
      case cCAMPO == "CGM_DES"
           if ! empty(cCGM_DES)
              if ! CGM->(dbseek(cCGM_DES))
                 qmensa("Municipio n„o encontrado !","B")
                 return .F.
              endif
              qrsay ( XNIVEL+1 , left(CGM->Municipio,27) + "/" + CGM->Estado )
           endif
      case cCAMPO == "COD_PROD"
           if ! empty(cCOD_PROD)
              if ! COD_PROD->(dbseek(cCOD_PROD))
                 qmensa("C¢digo de Produto n„o encontrado !","B")
                 return .F.
              endif
           endif
      case cCAMPO == "COD_REC"
           nVAL_REC  := IMP->Gr_pr
           nVAL_BASE := IMP->Val_base
           nALIQUOTA := IMP->Aliq_spl * 100

           if val(CONFIG->Anomes) < 200302
              if nVAL_REC <= 41.29
                 nVAL_REC := 41.29
              endif
           endif

           if CONFIG->Tipo_est == "D"
              nVAL_REC := IMP->Gr_pr
           endif

   endcase

return .T.

////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO __________________________

static function i_inicializacao

dDATA_INI := ctod("01/" + right(XANOMES,2) + "/" + left(XANOMES,4))
if IMP->(dbseek(K_ICM + dtos(dDATA_INI) + dtos(qfimmes(dDATA_INI)) + alltrim(cFILIAL)))
   if IMP->Apurado_e == .F. .or. IMP->Apurado_s == .F.
      alert("Existem os lan‡amentos n„o Apuradas.; Por favor execute as apura‡”es !")
      return .F.
   endif
else
   return .F.
endif


return .T.

////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO _________________________

static function i_impressao


   // INICIALIZA PROCESSO DE IMPRESSAO _____________________________________

   if !qinitprn() ; return ; endif

   // IMPRESSSAO GR-PR _____________________________________________________

   // POSICIONA NO MUNICIPIO E ESTADO DA EMPRESA ______________________________

   CGM->(dbseek(cCGM))

   @ prow(),pcol() say XCOND0

   @ prow()+2,63 say cCOD_REC
   @ prow()+2,05 say cRAZAO
   @ prow()  ,63 say left(dtoc(dDATA_VENC),6) + right(dtoc(dDATA_VENC),4)
   @ prow()+2,05 say cENDERECO
   @ prow()  ,63 say cINSCR_EST
   @ prow()+2,05 say CGM->Municipio + "/" + CGM->Estado
   @ prow()  ,41 say cTELEFONE
   @ prow()  ,63 say XCOND1 + transform(cCGCCPF,"@R 99.999.999/9999-99") + XCOND0
   @ prow()+2,63 say right(XANOMES,2) + "/" + left(XANOMES,4)

   @ prow()+1,05 say cRAZAO_DES
   @ prow()+1,63 say cDOCUMENTO

   CGM->(dbseek(cCGM_DES))
   @ prow()+1,05 say CGM->Municipio + "/" + CGM->Estado
   @ prow()  ,41 say cINSCR_DES

   CGM->(dbseek(cCGM))

   @ prow()+1,64 say transform(CGM->Cod_icms,"@R 9999-9") + "   " + transform(cCOD_PROD,"@R 9999-9")

// if nVAL_BASE <> 0
   if CONFIG->Tipo_est $ "ABC"
      @ prow()+2,05 say transform(nVAL_BASE,"@E 9,999,999.99") + space(15) + transform(nALIQUOTA,"@E 999.99") + "   " + cPLACA
      @ prow()  ,65 say transform(nVAL_REC,"@E 999,999.99")
   else
      @ prow()+2,65 say transform(nVAL_REC,"@E 999,999.99")
   endif

   @ prow()+2,65 say transform(nVAL_MULTA,"@E 999,999.99")

   @ prow()+2,05 say Substr(cOBS,01,50)
   @ prow()  ,65 say transform(nVAL_ACRES,"@E 999,999.99")

   @ prow()+1,05 say Substr(cOBS,51,50)

   @ prow()+1,05 say Substr(cOBS,101,50)
   @ prow()  ,65 say transform(nVAL_JUROS,"@E 999,999.99")
   @ prow()+2,65 say transform(nVAL_REC+nVAL_MULTA+nVAL_ACRES+nVAL_JUROS,"@E 999,999.99")

   @ prow()+9,00 say ""
  
   qstopprn(.F.)

return
