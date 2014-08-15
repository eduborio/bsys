/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: FOLHA DE PAGAMENTO
// OBJETIVO...: CORRECAO DE NOTA FISCAL
// ANALISTA...: LUIS ANTONIO ORLANDO PEREIRA
// PROGRAMADOR: IN SUNG CHANG
// INICIO.....: MAIO DE 1996
// OBS........:
// ALTERACOES.:
function ef533

#define K_MAX_LIN 52

#include "ef.ch"

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG) .or. (XNIVEL==1 .and. lastkey()==27)}

private sBLOCO1 := qlbloc("B533B","QBLOC.GLO")  // Sua/Nossa
private sBLOCO2 := qlbloc("B533C","QBLOC.GLO")  // Marca/Desmarca

private aEDICAO := {}                           // vetor para os campos de entrada de dados

private cCOD_1  , cCOD_2  , cCOD_3  , cCOD_4  , cCOD_5  , cCOD_6  , cCOD_7  , cCOD_8  , cCOD_9  , cCOD_10
private cCOD_11 , cCOD_12 , cCOD_13 , cCOD_14 , cCOD_15 , cCOD_16 , cCOD_17 , cCOD_18 , cCOD_19 , cCOD_20
private cCOD_21 , cCOD_22 , cCOD_23 , cCOD_24 , cCOD_25 , cCOD_26 , cCOD_27 , cCOD_28 , cCOD_29 , cCOD_30
private cCOD_31 , cCOD_32 , cCOD_33 , cCOD_34 , cCOD_35 , cCOD_36

private cRET_1  , cRET_2  , cRET_3  , cRET_4  , cRET_5  , cRET_6  , cRET_7  , cRET_8  , cRET_9  , cRET_10
private cRET_11 , cRET_12 , cRET_13 , cRET_14 , cRET_15 , cRET_16 , cRET_17 , cRET_18 , cRET_19 , cRET_20
private cRET_21 , cRET_22 , cRET_23 , cRET_24 , cRET_25 , cRET_26 , cRET_27 , cRET_28 , cRET_29 , cRET_30
private cRET_31 , cRET_32 , cRET_33 , cRET_34 , cRET_35 , cRET_36

private cDESC_32 , cDESC_33 , cDESC_34 , cDESC_35 , cDESC_36

private cEMPRESA
private cENDERECO
private dDATA_REL
private cTIPO_REL
private cNOTA
private cSERIE
private dDATA_NOTA
private nIMP

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

   qlbloc(5,0,"B533A","QBLOC.GLO",1)

   aadd(aEDICAO,{{ || qgetx(-1,0,@cEMPRESA    ,"@!"               ,NIL,NIL) } ,"EMPRESA"  })
   aadd(aEDICAO,{{ || qgetx(-1,0,@cENDERECO   ,"@!"               ,NIL,NIL) } ,"ENDERECO" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@dDATA_REL   ,"@D"               ,NIL,NIL) } ,"DATA_REL" })
   aadd(aEDICAO,{{ || qesco(-1,0,@cTIPO_REL   ,sBLOCO1                    ) } ,"TIPO_REL" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@cNOTA       ,"@!"               ,NIL,NIL) } ,"NOTA"     })
   aadd(aEDICAO,{{ || qgetx(-1,0,@cSERIE      ,"@!"               ,NIL,NIL) } ,"SERIE"    })
   aadd(aEDICAO,{{ || qgetx(-1,0,@dDATA_NOTA  ,"@D"               ,NIL,NIL) } ,"DATA_NOTA"})
   aadd(aEDICAO,{{ || qesco(-1,0,@cCOD_1      ,sBLOCO2                    ) } ,"COD_1"    })
   aadd(aEDICAO,{{ || qesco(-1,0,@cCOD_2      ,sBLOCO2                    ) } ,"COD_2"    })
   aadd(aEDICAO,{{ || qesco(-1,0,@cCOD_3      ,sBLOCO2                    ) } ,"COD_3"    })
   aadd(aEDICAO,{{ || qesco(-1,0,@cCOD_4      ,sBLOCO2                    ) } ,"COD_4"    })
   aadd(aEDICAO,{{ || qesco(-1,0,@cCOD_5      ,sBLOCO2                    ) } ,"COD_5"    })
   aadd(aEDICAO,{{ || qesco(-1,0,@cCOD_6      ,sBLOCO2                    ) } ,"COD_6"    })
   aadd(aEDICAO,{{ || qesco(-1,0,@cCOD_7      ,sBLOCO2                    ) } ,"COD_7"    })
   aadd(aEDICAO,{{ || qesco(-1,0,@cCOD_8      ,sBLOCO2                    ) } ,"COD_8"    })
   aadd(aEDICAO,{{ || qesco(-1,0,@cCOD_9      ,sBLOCO2                    ) } ,"COD_9"    })
   aadd(aEDICAO,{{ || qesco(-1,0,@cCOD_10     ,sBLOCO2                    ) } ,"COD_10"   })
   aadd(aEDICAO,{{ || qesco(-1,0,@cCOD_11     ,sBLOCO2                    ) } ,"COD_11"   })
   aadd(aEDICAO,{{ || qesco(-1,0,@cCOD_12     ,sBLOCO2                    ) } ,"COD_12"   })
   aadd(aEDICAO,{{ || qesco(-1,0,@cCOD_13     ,sBLOCO2                    ) } ,"COD_13"   })
   aadd(aEDICAO,{{ || qesco(-1,0,@cCOD_14     ,sBLOCO2                    ) } ,"COD_14"   })
   aadd(aEDICAO,{{ || qesco(-1,0,@cCOD_15     ,sBLOCO2                    ) } ,"COD_15"   })
   aadd(aEDICAO,{{ || qesco(-1,0,@cCOD_16     ,sBLOCO2                    ) } ,"COD_16"   })
   aadd(aEDICAO,{{ || qesco(-1,0,@cCOD_17     ,sBLOCO2                    ) } ,"COD_17"   })
   aadd(aEDICAO,{{ || qesco(-1,0,@cCOD_18     ,sBLOCO2                    ) } ,"COD_18"   })
   aadd(aEDICAO,{{ || qesco(-1,0,@cCOD_19     ,sBLOCO2                    ) } ,"COD_19"   })
   aadd(aEDICAO,{{ || qesco(-1,0,@cCOD_20     ,sBLOCO2                    ) } ,"COD_20"   })
   aadd(aEDICAO,{{ || qesco(-1,0,@cCOD_21     ,sBLOCO2                    ) } ,"COD_21"   })
   aadd(aEDICAO,{{ || qesco(-1,0,@cCOD_22     ,sBLOCO2                    ) } ,"COD_22"   })
   aadd(aEDICAO,{{ || qesco(-1,0,@cCOD_23     ,sBLOCO2                    ) } ,"COD_23"   })
   aadd(aEDICAO,{{ || qesco(-1,0,@cCOD_24     ,sBLOCO2                    ) } ,"COD_24"   })
   aadd(aEDICAO,{{ || qesco(-1,0,@cCOD_25     ,sBLOCO2                    ) } ,"COD_25"   })
   aadd(aEDICAO,{{ || qesco(-1,0,@cCOD_26     ,sBLOCO2                    ) } ,"COD_26"   })
   aadd(aEDICAO,{{ || qesco(-1,0,@cCOD_27     ,sBLOCO2                    ) } ,"COD_27"   })
   aadd(aEDICAO,{{ || qesco(-1,0,@cCOD_28     ,sBLOCO2                    ) } ,"COD_28"   })
   aadd(aEDICAO,{{ || qesco(-1,0,@cCOD_29     ,sBLOCO2                    ) } ,"COD_29"   })
   aadd(aEDICAO,{{ || qesco(-1,0,@cCOD_30     ,sBLOCO2                    ) } ,"COD_30"   })
   aadd(aEDICAO,{{ || qesco(-1,0,@cCOD_31     ,sBLOCO2                    ) } ,"COD_31"   })
   aadd(aEDICAO,{{ || qesco(-1,0,@cCOD_32     ,sBLOCO2                    ) } ,"COD_32"   })
   aadd(aEDICAO,{{ || qesco(-1,0,@cCOD_33     ,sBLOCO2                    ) } ,"COD_33"   })
   aadd(aEDICAO,{{ || qesco(-1,0,@cCOD_34     ,sBLOCO2                    ) } ,"COD_34"   })
   aadd(aEDICAO,{{ || qesco(-1,0,@cCOD_35     ,sBLOCO2                    ) } ,"COD_35"   })
   aadd(aEDICAO,{{ || qesco(-1,0,@cCOD_36     ,sBLOCO2                    ) } ,"COD_36"   })
   aadd(aEDICAO,{{ || qgetx(-1,0,@nIMP        ,"99"               ,NIL,NIL) } ,"IMP"      })

do while .T.

   XNIVEL := 1
   XFLAG  := .T.

   cCOD_1  := cCOD_2  := cCOD_3  := cCOD_4  := cCOD_5  := cCOD_6  := cCOD_7  := cCOD_8  := cCOD_9  := cCOD_10 := "D"
   cCOD_11 := cCOD_12 := cCOD_13 := cCOD_14 := cCOD_15 := cCOD_16 := cCOD_17 := cCOD_18 := cCOD_19 := cCOD_20 := "D"
   cCOD_21 := cCOD_22 := cCOD_23 := cCOD_24 := cCOD_25 := cCOD_26 := cCOD_27 := cCOD_28 := cCOD_29 := cCOD_30 := "D"
   cCOD_31 := cCOD_32 := cCOD_33 := cCOD_34 := cCOD_35 := cCOD_36 := "D"

   cRET_1  := cRET_2  := cRET_3  := cRET_4  := cRET_5  := cRET_6  := cRET_7  := cRET_8  := cRET_9  := cRET_10 := space(52)
   cRET_11 := cRET_12 := cRET_13 := cRET_14 := cRET_15 := cRET_16 := cRET_17 := cRET_18 := cRET_19 := cRET_20 := space(52)
   cRET_21 := cRET_22 := cRET_23 := cRET_24 := cRET_25 := cRET_26 := cRET_27 := cRET_28 := cRET_29 := cRET_30 := space(52)
   cRET_31 := cRET_32 := cRET_33 := cRET_34 := cRET_35 := cRET_36 := space(52)

   cDESC_31 := cDESC_32 := cDESC_33 := cDESC_34 := cDESC_35 := cDESC_36 := space(20)

   cEMPRESA   := space(40)
   cENDERECO  := space(40)
   dDATA_REL  := date()
   cTIPO_REL  := "S"
   cNOTA      := "        "
   cSERIE     := "   "
   dDATA_NOTA := ctod("")
   nIMP       := 3

   // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; dbcloseall() ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   if ! qconf("Confirma impress„o ?")
      return
   endif

   i_impressao()

enddo

/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA _____________________________________________

static function i_critica ( cCAMPO )

   do case

      case cCAMPO == "TIPO_REL"
           if empty(cTIPO_REL); return .F.; endif
           qrsay(XNIVEL,qabrev(cTIPO_REL,"SN",{"Sua","Nossa"}))

      case cCAMPO == "COD_1"
           if empty(cCOD_1); return .F.; endif
           qrsay(XNIVEL,qabrev(cCOD_1,"MD",{"M","D"}))
           if cCOD_1 == "M"
              qgetx(22,16,@cRET_1 ,"@!")
           endif
      case cCAMPO == "COD_2"
           if empty(cCOD_2); return .F.; endif
           qrsay(XNIVEL,qabrev(cCOD_2,"MD",{"M","D"}))
           if cCOD_2 == "M"
              qgetx(22,16,@cRET_2 ,"@!")
           endif
      case cCAMPO == "COD_3"
           if empty(cCOD_3); return .F.; endif
           qrsay(XNIVEL,qabrev(cCOD_3,"MD",{"M","D"}))
           if cCOD_3 == "M"
              qgetx(22,16,@cRET_3 ,"@!")
           endif
      case cCAMPO == "COD_4"
           if empty(cCOD_4); return .F.; endif
           qrsay(XNIVEL,qabrev(cCOD_4,"MD",{"M","D"}))
           if cCOD_4 == "M"
              qgetx(22,16,@cRET_4 ,"@!")
           endif
      case cCAMPO == "COD_5"
           if empty(cCOD_5); return .F.; endif
           qrsay(XNIVEL,qabrev(cCOD_5,"MD",{"M","D"}))
           if cCOD_5 == "M"
              qgetx(22,16,@cRET_5 ,"@!")
           endif
      case cCAMPO == "COD_6"
           if empty(cCOD_6); return .F.; endif
           qrsay(XNIVEL,qabrev(cCOD_6,"MD",{"M","D"}))
           if cCOD_6 == "M"
              qgetx(22,16,@cRET_6 ,"@!")
           endif
      case cCAMPO == "COD_7"
           if empty(cCOD_7); return .F.; endif
           qrsay(XNIVEL,qabrev(cCOD_7,"MD",{"M","D"}))
           if cCOD_7 == "M"
              qgetx(22,16,@cRET_7 ,"@!")
           endif
      case cCAMPO == "COD_8"
           if empty(cCOD_8); return .F.; endif
           qrsay(XNIVEL,qabrev(cCOD_8,"MD",{"M","D"}))
           if cCOD_8 == "M"
              qgetx(22,16,@cRET_8 ,"@!")
           endif
      case cCAMPO == "COD_9"
           if empty(cCOD_9); return .F.; endif
           qrsay(XNIVEL,qabrev(cCOD_9,"MD",{"M","D"}))
           if cCOD_9 == "M"
              qgetx(22,16,@cRET_9 ,"@!")
           endif
      case cCAMPO == "COD_10"
           if empty(cCOD_10); return .F.; endif
           qrsay(XNIVEL,qabrev(cCOD_10,"MD",{"M","D"}))
           if cCOD_10 == "M"
              qgetx(22,16,@cRET_10 ,"@!")
           endif
      case cCAMPO == "COD_11"
           if empty(cCOD_11); return .F.; endif
           qrsay(XNIVEL,qabrev(cCOD_11,"MD",{"M","D"}))
           if cCOD_11 == "M"
              qgetx(22,16,@cRET_11 ,"@!")
           endif
      case cCAMPO == "COD_12"
           if empty(cCOD_12); return .F.; endif
           qrsay(XNIVEL,qabrev(cCOD_12,"MD",{"M","D"}))
           if cCOD_12 == "M"
              qgetx(22,16,@cRET_12 ,"@!")
           endif
      case cCAMPO == "COD_13"
           if empty(cCOD_13); return .F.; endif
           qrsay(XNIVEL,qabrev(cCOD_13,"MD",{"M","D"}))
           if cCOD_13 == "M"
              qgetx(22,16,@cRET_13 ,"@!")
           endif
      case cCAMPO == "COD_14"
           if empty(cCOD_14); return .F.; endif
           qrsay(XNIVEL,qabrev(cCOD_14,"MD",{"M","D"}))
           if cCOD_14 == "M"
              qgetx(22,16,@cRET_14 ,"@!")
           endif
      case cCAMPO == "COD_15"
           if empty(cCOD_15); return .F.; endif
           qrsay(XNIVEL,qabrev(cCOD_15,"MD",{"M","D"}))
           if cCOD_15 == "M"
              qgetx(22,16,@cRET_15 ,"@!")
           endif
      case cCAMPO == "COD_16"
           if empty(cCOD_16); return .F.; endif
           qrsay(XNIVEL,qabrev(cCOD_16,"MD",{"M","D"}))
           if cCOD_16 == "M"
              qgetx(22,16,@cRET_16 ,"@!")
           endif
      case cCAMPO == "COD_17"
           if empty(cCOD_17); return .F.; endif
           qrsay(XNIVEL,qabrev(cCOD_17,"MD",{"M","D"}))
           if cCOD_17 == "M"
              qgetx(22,16,@cRET_17 ,"@!")
           endif
      case cCAMPO == "COD_18"
           if empty(cCOD_18); return .F.; endif
           qrsay(XNIVEL,qabrev(cCOD_18,"MD",{"M","D"}))
           if cCOD_18 == "M"
              qgetx(22,16,@cRET_18 ,"@!")
           endif
      case cCAMPO == "COD_19"
           if empty(cCOD_19); return .F.; endif
           qrsay(XNIVEL,qabrev(cCOD_19,"MD",{"M","D"}))
           if cCOD_19 == "M"
              qgetx(22,16,@cRET_19 ,"@!")
           endif
      case cCAMPO == "COD_20"
           if empty(cCOD_20); return .F.; endif
           qrsay(XNIVEL,qabrev(cCOD_20,"MD",{"M","D"}))
           if cCOD_20 == "M"
              qgetx(22,16,@cRET_20 ,"@!")
           endif
      case cCAMPO == "COD_21"
           if empty(cCOD_21); return .F.; endif
           qrsay(XNIVEL,qabrev(cCOD_21,"MD",{"M","D"}))
           if cCOD_21 == "M"
              qgetx(22,16,@cRET_21 ,"@!")
           endif
      case cCAMPO == "COD_22"
           if empty(cCOD_22); return .F.; endif
           qrsay(XNIVEL,qabrev(cCOD_22,"MD",{"M","D"}))
           if cCOD_22 == "M"
              qgetx(22,16,@cRET_22 ,"@!")
           endif
      case cCAMPO == "COD_23"
           if empty(cCOD_23); return .F.; endif
           qrsay(XNIVEL,qabrev(cCOD_23,"MD",{"M","D"}))
           if cCOD_23 == "M"
              qgetx(22,16,@cRET_23 ,"@!")
           endif
      case cCAMPO == "COD_24"
           if empty(cCOD_24); return .F.; endif
           qrsay(XNIVEL,qabrev(cCOD_24,"MD",{"M","D"}))
           if cCOD_24 == "M"
              qgetx(22,16,@cRET_24 ,"@!")
           endif
      case cCAMPO == "COD_25"
           if empty(cCOD_25); return .F.; endif
           qrsay(XNIVEL,qabrev(cCOD_25,"MD",{"M","D"}))
           if cCOD_25 == "M"
              qgetx(22,16,@cRET_25 ,"@!")
           endif
      case cCAMPO == "COD_26"
           if empty(cCOD_26); return .F.; endif
           qrsay(XNIVEL,qabrev(cCOD_26,"MD",{"M","D"}))
           if cCOD_26 == "M"
              qgetx(22,16,@cRET_26 ,"@!")
           endif
      case cCAMPO == "COD_27"
           if empty(cCOD_27); return .F.; endif
           qrsay(XNIVEL,qabrev(cCOD_27,"MD",{"M","D"}))
           if cCOD_27 == "M"
              qgetx(22,16,@cRET_27 ,"@!")
           endif
      case cCAMPO == "COD_28"
           if empty(cCOD_28); return .F.; endif
           qrsay(XNIVEL,qabrev(cCOD_28,"MD",{"M","D"}))
           if cCOD_28 == "M"
              qgetx(22,16,@cRET_28 ,"@!")
           endif
      case cCAMPO == "COD_29"
           if empty(cCOD_29); return .F.; endif
           qrsay(XNIVEL,qabrev(cCOD_29,"MD",{"M","D"}))
           if cCOD_29 == "M"
              qgetx(22,16,@cRET_29 ,"@!")
           endif
      case cCAMPO == "COD_30"
           if empty(cCOD_30); return .F.; endif
           qrsay(XNIVEL,qabrev(cCOD_30,"MD",{"M","D"}))
           if cCOD_30 == "M"
              qgetx(22,16,@cRET_30 ,"@!")
           endif
      case cCAMPO == "COD_31"
           if empty(cCOD_31); return .F.; endif
           qrsay(XNIVEL,qabrev(cCOD_31,"MD",{"M","D"}))
           if cCOD_31 == "M"
              qgetx(22,16,@cRET_31 ,"@!")
           endif
      case cCAMPO == "COD_32"
           if empty(cCOD_32); return .F.; endif
           qrsay(XNIVEL,qabrev(cCOD_32,"MD",{"M","D"}))
           if cCOD_32 == "M"
              qgetx(20,33,@cDESC_32 ,"@!")
              qgetx(22,16,@cRET_32 ,"@!")
           endif
      case cCAMPO == "COD_33"
           if empty(cCOD_33); return .F.; endif
           qrsay(XNIVEL,qabrev(cCOD_33,"MD",{"M","D"}))
           if cCOD_33 == "M"
              qgetx(20,59,@cDESC_33 ,"@!")
              qgetx(22,16,@cRET_33 ,"@!")
           endif
      case cCAMPO == "COD_34"
           if empty(cCOD_34); return .F.; endif
           qrsay(XNIVEL,qabrev(cCOD_34,"MD",{"M","D"}))
           if cCOD_34 == "M"
              qgetx(21,07,@cDESC_34 ,"@!")
              qgetx(22,16,@cRET_34 ,"@!")
           endif
      case cCAMPO == "COD_35"
           if empty(cCOD_35); return .F.; endif
           qrsay(XNIVEL,qabrev(cCOD_35,"MD",{"M","D"}))
           if cCOD_35 == "M"
              qgetx(21,33,@cDESC_35 ,"@!")
              qgetx(22,16,@cRET_35 ,"@!")
           endif
      case cCAMPO == "COD_36"
           if empty(cCOD_36); return .F.; endif
           qrsay(XNIVEL,qabrev(cCOD_36,"MD",{"M","D"}))
           if cCOD_36 == "M"
              qgetx(21,59,@cDESC_36 ,"@!")
              qgetx(22,16,@cRET_36 ,"@!")
           endif

   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impressao

   local cLINHA1 := "*" + replicate("-",131) + "*"
   local cLINHA2 := "|" + space(131) + "|"
   local cLINHA3 := "*" + replicate("=",131) + "*"

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   for nCONTX = 1 to nIMP

       if ! qinitprn() ; return ; endif

       @ prow()+1,0   say XCOND1
       @ prow()+1,0   say cLINHA3
       @ prow()+1,0   say "|" + XCOND0 + XAEXPAN + "CORRECAO DE NOTA FISCAL" + XDEXPAN + XCOND1 + space(52) + "|"
       @ prow()+1,0   say cLINHA3
       @ prow()+1,0   say "|" + space(83) + "+---         CARIMBO PADRONIZADO         ---+   |"
       @ prow()+1,0   say "| " + "Curitiba, " + str(day(dDATA_REL),2) + " de " + alltrim(qnomemes(dDATA_REL)) +;
                          " de " + str(year(dDATA_REL),4)
       @ prow()  ,132 say "|"
       @ prow()+1,0   say cLINHA2
       @ prow()+1,0   say "|" + " Para a " + cEMPRESA
       @ prow()  ,132 say "|"
       @ prow()+1,0   say "|        " + cENDERECO
       @ prow()  ,132 say "|"
       @ prow()+1,0   say cLINHA2
       @ prow()+1,0   say "| Prezado(s) Sr.(es)                                                                                                                |"
       @ prow()+1,0   say "|" + space(83) + "+---                                     ---+   |"
       @ prow()+1,0   say "|" + space(34) + "Ref.: Conferencia de Documento Fiscal e Comunicacao de Incorrecoes                               |"
       @ prow()+1,0   say cLINHA2
       @ prow()+1,0   say "|" + space(34) + iif( cTIPO_REL == "S" , "Sua" , "Nossa" ) + " Nota Fiscal No. " + cNOTA + " Serie " + cSERIE + " de " + dtoc(dDATA_NOTA)
       @ prow()  ,132 say "|"
       @ prow()+1,0   say cLINHA2
       @ prow()+1,0   say "|" + space(6) + "Em face do que determina a legislacao fiscal vigente, vimos pela presente comunicar-lhe(s) que a Nota Fiscal em referencia   |"
       @ prow()+1,0   say "| contem a(s) irregularidade(s) que abaixo apontamos, cuja correcao solicitamos seja providenciada imediatamente.                   |"
       @ prow()+1,0   say "| +------+-----------------------+ +------+---------------------+ +------+-----------------------+ +------+-----------------------+ |"
       @ prow()+1,0   say "| |CODIGO|     ESPECIFICACAO     | |CODIGO|    ESPECIFICACAO    | |CODIGO|      ESPECIFICACAO    | |CODIGO|      ESPECIFICACAO    | |"
       @ prow()+1,0   say "| +---+--+-----------------------+ +---+--+---------------------+ +---+--+-----------------------+ +---+--+-----------------------+ |"
       @ prow()+1,0   say "| |" + iif(cCOD_1=="M"," X ","   ") + "|01|Razao Social           | |" + iif(cCOD_10=="M"," X ","   ") + "|10|Data da Emissao      | |" + iif(cCOD_19=="M"," X ","   ") + "|19|Valor do IPI           | |" + iif(cCOD_28=="M"," X ","   ") + "|28|Termo de Isencao do ICM| |"
       @ prow()+1,0   say "| +---+--+-----------------------+ +---+--+---------------------+ +---+--+-----------------------+ +---+--+-----------------------+ |"
       @ prow()+1,0   say "| |" + iif(cCOD_2=="M"," X ","   ") + "|02|Endereco               | |" + iif(cCOD_11=="M"," X ","   ") + "|11|Data da Saida        | |" + iif(cCOD_20=="M"," X ","   ") + "|20|Base de Calculo do IPI | |" + iif(cCOD_29=="M"," X ","   ") + "|29|Peso - Liquido/Bruto   | |"
       @ prow()+1,0   say "| +---+--+-----------------------+ +---+--+---------------------+ +---+--+-----------------------+ +---+--+-----------------------+ |"
       @ prow()+1,0   say "| |" + iif(cCOD_3=="M"," X ","   ") + "|03|Municipio              | |" + iif(cCOD_12=="M"," X ","   ") + "|12|Unidade (Produto)    | |" + iif(cCOD_21=="M"," X ","   ") + "|21|Valor Total da Nota    | |" + iif(cCOD_30=="M"," X ","   ") + "|30|Volume - Marca/No./Qtd.| |"
       @ prow()+1,0   say "| +---+--+-----------------------+ +---+--+---------------------+ +---+--+-----------------------+ +---+--+-----------------------+ |"
       @ prow()+1,0   say "| |" + iif(cCOD_4=="M"," X ","   ") + "|04|Estado                 | |" + iif(cCOD_13=="M"," X ","   ") + "|13|Quantidade(Produto)  | |" + iif(cCOD_22=="M"," X ","   ") + "|22|Aliquota do ICM        | |" + iif(cCOD_31=="M"," X ","   ") + "|31|Rasuras                | |"
       @ prow()+1,0   say "| +---+--+-----------------------+ +---+--+---------------------+ +---+--+-----------------------+ +---+--+-----------------------+ |"
       @ prow()+1,0   say "| |" + iif(cCOD_5=="M"," X ","   ") + "|05|No. de Inscr. no CGC   | |" + iif(cCOD_14=="M"," X ","   ") + "|14|Descricao dos Produto| |" + iif(cCOD_23=="M"," X ","   ") + "|23|Valor do ICM           | |" + iif(cCOD_32=="M"," X ","   ") + "|32|"+cDESC_32+"   | |"
       @ prow()+1,0   say "| +---+--+-----------------------+ +---+--+---------------------+ +---+--+-----------------------+ +---+--+-----------------------+ |"
       @ prow()+1,0   say "| |" + iif(cCOD_6=="M"," X ","   ") + "|06|No. de Inscr. Estadual | |" + iif(cCOD_15=="M"," X ","   ") + "|15|Preco Unitario       | |" + iif(cCOD_24=="M"," X ","   ") + "|24|Base de Calculo do ICM | |" + iif(cCOD_33=="M"," X ","   ") + "|33|"+cDESC_33+"   | |"
       @ prow()+1,0   say "| +---+--+-----------------------+ +---+--+---------------------+ +---+--+-----------------------+ +---+--+-----------------------+ |"
       @ prow()+1,0   say "| |" + iif(cCOD_7=="M"," X ","   ") + "|07|Natureza da Operacao   | |" + iif(cCOD_16=="M"," X ","   ") + "|16|Valor dos Produtos   | |" + iif(cCOD_25=="M"," X ","   ") + "|25|Nome do Transportador  | |" + iif(cCOD_34=="M"," X ","   ") + "|34|"+cDESC_34+"   | |"
       @ prow()+1,0   say "| +---+--+-----------------------+ +---+--+---------------------+ +---+--+-----------------------+ +---+--+-----------------------+ |"
       @ prow()+1,0   say "| |" + iif(cCOD_8=="M"," X ","   ") + "|08|Cod. Fiscal da Operacao| |" + iif(cCOD_17=="M"," X ","   ") + "|17|Classificacao Fiscal | |" + iif(cCOD_26=="M"," X ","   ") + "|26|End. do Transportador  | |" + iif(cCOD_35=="M"," X ","   ") + "|35|"+cDESC_35+"   | |"
       @ prow()+1,0   say "| +---+--+-----------------------+ +---+--+---------------------+ +---+--+-----------------------+ +---+--+-----------------------+ |"
       @ prow()+1,0   say "| |" + iif(cCOD_9=="M"," X ","   ") + "|09|Via de Transporte      | |" + iif(cCOD_18=="M"," X ","   ") + "|18|Aliquota do IPI      | |" + iif(cCOD_27=="M"," X ","   ") + "|27|Termo de Isencao do IPI| |" + iif(cCOD_36=="M"," X ","   ") + "|36|"+cDESC_36+"   | |"
       @ prow()+1,0   say "| +---+--+-----------------------+ +---+--+---------------------+ +---+--+-----------------------+ +---+--+-----------------------+ |"
       @ prow()+1,0   say "| +-----------------+-------------------------------------------------------------------------------------------------------------+ |"
       @ prow()+1,0   say "| |   CODIGOS COM   |                                     RETIFICACOES A SEREM CONSIDERADAS                                       | |"
       @ prow()+1,0   say "| | IRREGULARIDADE  |                                                                                                             | |"
       @ prow()+1,0   say "| +-----------------+-------------------------------------------------------------------------------------------------------------+ |"
       for nCONT = 1 to 36
           if &("cCOD_"+alltrim(str(nCONT))) == "M"
              @ prow()+1,0   say "| |        " + strzero(nCONT,2) + "       | " + &("cRET_"+alltrim(str(nCONT)))
              @ prow()  ,130 say "| |"
           endif
       next
       @ prow()+1,0   say "| +-----------------+-------------------------------------------------------------------------------------------------------------+ |"
       @ prow()+1,0   say cLINHA2
       @ prow()+1,0   say "|" + space(6) + "Para evitar-se qualquer sancao fiscal, solicitamos acusarem o recebimento desta na copia que a acompanha, devendo a via de V.|"
       @ prow()+1,0   say "| Sa.(s) ficar arquivada juntamente com a Nota Fiscal em questao.                                                                   |"
       @ prow()+1,0   say "|" + space(6) + "Sem outro motivo para o momento, subscrevemo-nos.                                                                            |"
       @ prow()+1,0   say cLINHA2
       @ prow()+1,0   say "| +-------- ACUSAMOS O RECEBIMENTO DA 1a. VIA --------+                                        Atenciosamente                       |"
       @ prow()+1,0   say "| |                                                   |                                                                             |"
       @ prow()+1,0   say "| | _________________________________________________ |                                                                             |"
       @ prow()+1,0   say "| |                   LOCAL E DATA                    |                                                                             |"
       @ prow()+1,0   say "| |                                                   |                                                                             |"
       @ prow()+1,0   say "| | _________________________________________________ |                                ________________________________             |"
       @ prow()+1,0   say "| |               CARIMBO E ASSINATURA                |                                      CARIMBO E ASSINATURA                   |"
       @ prow()+1,0   say "| +---------------------------------------------------+                                                                             |"
       @ prow()+1,0   say "+-----------------------------------------------------------------------------------------------------------------------------------+"

       qstopprn()

   next

return
