 /////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO COMERCIO
// OBJETIVO...: CONFIGURACAO GERAL DO SISTEMA
// ANALISTA...: LUIS ANTONIO ORLANDO PEREIRA
// PROGRAMADOR: O MESMO
// INICIO.....: OUTUBRO DE 1995
// OBS........:
// ALTERACOES.:

// DECLARACAO DE VARIAVEIS __________________________________________________

function cl801
local aEDICAO := {}
local lCONF := .F.

private bESCAPE   := { || XNIVEL == 1 .and. !XFLAG .or. XNIVEL == 1 .and. Lastkey()==27 }
private cANO_REF  := CONFIG->Ano_ref
private nCOD_CLI  := CONFIG->Cod_cli
private nN_BLOQ   := CONFIG->N_bloq
private nCOD_VEND := CONFIG->Cod_vend
private nCOD_FAT  := CONFIG->Cod_fat
private nMODELO_FAT := CONFIG->Modelo_fat
private nMODELO_2  := CONFIG->Modelo_2
private nESTOQUE  := CONFIG->Estoque
private sBLOC1  := qlbloc("B801B","QBLOC.GLO")
private sBLOC2  := qlbloc("B801C","QBLOC.GLO")
private nPULO   := CONFIG->Pulo
private nINI_NOTA   := CONFIG->Ini_Nota
private cTPO_VEND  := CONFIG->Tpo_vend
private cTPO_DESP  := CONFIG->Tpo_desp

qmensa("<Pressione ESC para Cancelar>")

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qgetx(-1,0,@cANO_REF ,"9999")  },"ANO_REF"     })
aadd(aEDICAO,{{ || qgetx(-1,0,@nPULO    ,"99")  },"PULO"     })
aadd(aEDICAO,{{ || qgetx(-1,0,@nCOD_CLI ,"99999") },"COD_CLI"     })
aadd(aEDICAO,{{ || qgetx(-1,0,@nCOD_VEND,"99999") },"COD_VEND"    })
aadd(aEDICAO,{{ || qgetx(-1,0,@nCOD_FAT,"999999") },"COD_FAT"     })
aadd(aEDICAO,{{ || qesco(-1,0,@nESTOQUE,XSN     ) },"ESTOQUE"     })
aadd(aEDICAO,{{ || qesco(-1,0,@nMODELO_FAT,sBLOC1)},"MODELO_FAT"  })
aadd(aEDICAO,{{ || qesco(-1,0,@nMODELO_2 ,sBLOC2)},"MODELO_2"  })
aadd(aEDICAO,{{ || qgetx(-1,0,@nN_BLOQ ,"99999999999999") },"N_BLOQ"     })
aadd(aEDICAO,{{ || qgetx(-1,0,@nINI_NOTA      ,"99")  },"INI_NOTA"     })
aadd(aEDICAO,{{ || view_tipocont(-1,0,@cTPO_VEND      ,"999999")  },"TPO_VEND"     })
aadd(aEDICAO,{{ || NIL  },NIL     })
aadd(aEDICAO,{{ || view_tipocont(-1,0,@cTPO_DESP      ,"999999")  },"TPO_DESP"     })
aadd(aEDICAO,{{ || NIL  },NIL     })


aadd(aEDICAO,{{ || lCONF := qconf("Confirma altera‡„o ?") },"CONF"})

// INICIALIZACAO DE CAMPOS E TELA ___________________________________________

XNIVEL := 1
qrsay ( XNIVEL++ , cANO_REF  , "9999"   )
qrsay ( XNIVEL++ , nPULO     , "99"   )
qrsay ( XNIVEL++ , nCOD_CLI  , "99999"  )
qrsay ( XNIVEL++ , nCOD_VEND , "99999"  )
qrsay ( XNIVEL++ , nCOD_FAT  , "999999" )
qrsay (XNIVEL++,qabrev(CONFIG->Estoque,"SN", {"Sim","Nao"}))
qrsay (XNIVEL++,qabrev(CONFIG->Modelo_fat,"1234567890ABC", {"Mantraco do Brasil","Perfilizia","Sol e Gelo","TEKSY","GRES - Marmores","Almeida Madeireira","Almeida Materiais de Construcao","Jurua","Buba MAster","Plastifama","RN Comercial Ltda.","ECO BRASIL","Outro"}))
qrsay (XNIVEL++,qabrev(CONFIG->Modelo_2,"1234567890AC", {"DSE Do Brasil","Remoplast","Bells","Smart Wood Export","S. Kikumoto","Morgan Woods","Clari Agua Mineral","J.V.M. - Moveis","MS Work - Importacao","Etiquerama","ATOL IMOVEIS LTDA","Outro"}))

qrsay ( XNIVEL++ , nN_BLOQ  , "99999999999999"  )
qrsay ( XNIVEL++ , nINI_NOTA     , "99"   )
qrsay ( XNIVEL++ , cTPO_VEND                    ) ;TIPOCONT->(dbseek(cTPO_VEND))
qrsay ( XNIVEL++ , left(TIPOCONT->Descricao,18) )
qrsay ( XNIVEL++ , cTPO_DESP                    ) ; TIPOCONT->(dbseek(cTPO_DESP))
qrsay ( XNIVEL++ , left(TIPOCONT->Descricao,18) )



XNIVEL := 1
XFLAG  := .T.

// LOOP PARA ENTRADA DOS DADOS ______________________________________________

do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
   eval ( aEDICAO [XNIVEL,1] )
   if eval ( bESCAPE ) ; return ; endif
   if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
   iif ( XFLAG , XNIVEL++ , XNIVEL-- )
enddo

// GRAVACAO _________________________________________________________________

if lCONF
   if CONFIG->(qrlock())
      replace CONFIG->Ano_ref  with cANO_REF
      replace CONFIG->Cod_cli  with nCOD_CLI
      replace CONFIG->Cod_vend with nCOD_VEND
      replace CONFIG->Cod_fat  with nCOD_FAT
      replace CONFIG->Estoque  with nESTOQUE
      replace CONFIG->Modelo_fat with nMODELO_FAT
      replace CONFIG->Modelo_2 with nMODELO_2
      replace CONFIG->N_bloq   with nN_BLOQ
      replace CONFIG->Pulo     with nPULO
      replace CONFIG->Ini_Nota with nINI_NOTA
      replace CONFIG->Tpo_vend with cTPO_VEND
      replace CONFIG->Tpo_desp with cTPO_DESP
      CONFIG->(qunlock())
   else
      qm2()
   endif
endif
return

/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA _____________________________________________

static function i_critica ( cCAMPO )
   local cANO, cMES
   do case
      case cCAMPO == "ANO_REF"
           if val(cANO_REF) < 1990 ; return .F. ; endif
      case cCAMPO == "COD_CLI"
           if nCOD_CLI <= 0 ; return .F. ; endif
      case cCAMPO == "COD_VEND"
           if nCOD_VEND <= 0 ; return .F. ; endif
      case cCAMPO == "ESTOQUE"
           if empty(nESTOQUE); return .F. ; endif
           qrsay (XNIVEL,qabrev(CONFIG->Estoque,"SN", {"Sim","Nao"}))
      case cCAMPO == "MODELO_FAT"
           if empty(nMODELO_FAT) ; return .F. ; endif
           qrsay(XNIVEL,qabrev(nMODELO_FAT,"1234567890ABC", {"Mantraco do Brasil","Perfilizia","Sol e Gelo","TEKSY","GRES Marmores","Almeida Madeireira","Almeida Materiais de Construcao","Jurua","Buba Master","Plastifama","RN Comercial Ltda.","ECO BRASIL","Outro"}))
      case cCAMPO == "MODELO_2"
           if empty(nMODELO_2) ; return .F. ; endif
           qrsay(XNIVEL,qabrev(nMODELO_2,"1234567890AC", {"DSE Do Brasil","Remoplast","Bells","Smart Wood export","S. Kikumoto","Morgan Woods","Clari Agua Mineral","J.V.M. - Moveis","MS Work - Importacao","Etiquerama","ATOL IMOVEIS LTDA","Outro"}))

      case cCAMPO == "TPO_VEND"
           qrsay(XNIVEL,cTPO_VEND := strzero(val(cTPO_VEND),6))
           if ! TIPOCONT->(dbseek(cTPO_VEND))
              qmensa("Tipo Contabil n„o encontrado !","B")
              return .F.
           endif

           qrsay(XNIVEL+1,left(TIPOCONT->Descricao,18))

      case cCAMPO == "TPO_DESP"
           qrsay(XNIVEL,cTPO_DESP := strzero(val(cTPO_DESP),6))
           if ! TIPOCONT->(dbseek(cTPO_DESP))
              qmensa("Tipo Contabil n„o encontrado !","B")
              return .F.
           endif

           qrsay(XNIVEL+1,left(TIPOCONT->Descricao,18))



   endcase
return .T.
