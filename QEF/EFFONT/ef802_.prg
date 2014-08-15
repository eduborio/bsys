/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: FOLHA DE PAGAMENTO
// OBJETIVO...: CONFIGURACAO GERAL DO SISTEMA
// ANALISTA...: LUIS ANTONIO ORLANDO PEREIRA
// PROGRAMADOR: IN SUNG CHANG
// INICIO.....: JUNHO DE 1994
// OBS........:
// ALTERACOES.:

function ef802

// DECLARACAO DE VARIAVEIS __________________________________________________

local aEDICAO := {}
local lCONF   := .F.
local sBLOC1  := qlbloc("B802B","QBLOC.GLO")
local sBLOC2  := qlbloc("B802C","QBLOC.GLO")
local sBLOC3  := qlbloc("B802D","QBLOC.GLO")
local sBLOC4  := qlbloc("B802E","QBLOC.GLO")
local sBLOC5  := qlbloc("B802F","QBLOC.GLO")

private bESCAPE   := {||(XNIVEL==1 .and. !XFLAG .or. lastkey()=27.and.XNIVEL==1) }

private cTIPOEMP     := CONFIG->Tipoemp
private cNIVEL_EMP   := CONFIG->Nivel_emp
private cUSA_VEND    := CONFIG->Usa_vend
private cIPI_DESC    := CONFIG->Ipi_desc       // Se os impostos de IPI vai ser por descendio ou por mes
private cTRIB_SINC   := CONFIG->Trib_sinc
private nPERC_SLP    := CONFIG->Perc_slp
private nPERC_SUBTR  := CONFIG->Perc_subtr
private nLIM_ME_C    := CONFIG->Lim_me_c
private nLIM_ME_F    := CONFIG->Lim_me_f
private cCONF_TRIB   := CONFIG->Conf_trib
private cI_EST_ST    := CONFIG->I_est_st
private cTIPO_EST    := CONFIG->Tipo_est
private cISS         := CONFIG->Iss
private cEXIGE_CUSTO := CONFIG->Exig_ccust

private cPIC1      := "@E 999,999.99"

qmensa("<ESC - Cancela>")

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

qlbloc(5,0,"B802A","QBLOC.GLO",1)

aadd(aEDICAO,{{ || qesco(-1,0,@cTIPOEMP   ,sBLOC1     ) } ,"TIPOEMP"   })
aadd(aEDICAO,{{ || qesco(-1,0,@cNIVEL_EMP ,sBLOC4     ) } ,"NIVEL_EMP" })
aadd(aEDICAO,{{ || qesco(-1,0,@cUSA_VEND  ,sBLOC2     ) } ,"USA_VEND"  })
aadd(aEDICAO,{{ || qesco(-1,0,@cTIPO_EST  ,sBLOC5     ) } ,"TIPO_EST"  })
aadd(aEDICAO,{{ || qesco(-1,0,@cISS       ,sBLOC2     ) } ,"ISS"       })
aadd(aEDICAO,{{ || qesco(-1,0,@cIPI_DESC  ,sBLOC3     ) } ,"IPI_DESC"  })
aadd(aEDICAO,{{ || qesco(-1,0,@cTRIB_SINC ,sBLOC2     ) } ,"TRIB_SINC" })
aadd(aEDICAO,{{ || qgetx(-1,0,@nPERC_SLP  ,"@E 999.99") } ,"PERC_SLP"  })
aadd(aEDICAO,{{ || qgetx(-1,0,@nPERC_SUBTR,"@E 999.99") } ,"PERC_SUBTR"})
aadd(aEDICAO,{{ || qgetx(-1,0,@nLIM_ME_C  ,cPIC1      ) } ,"LIM_ME_C"  })
aadd(aEDICAO,{{ || qgetx(-1,0,@nLIM_ME_F  ,cPIC1      ) } ,"LIM_ME_F"  })
aadd(aEDICAO,{{ || qgetx(-1,0,@cCONF_TRIB ,"@!@S22"   ) } ,"CONF_TRIB" })
aadd(aEDICAO,{{ || qgetx(-1,0,@cI_EST_ST  ,"@!"       ) } ,"I_EST_ST"  })
aadd(aEDICAO,{{ || qesco(-1,0,@cEXIGE_CUSTO ,sBLOC3   ) } ,"EXIGE_CUSTO"})

aadd(aEDICAO,{{ || lCONF := qconf("Confirma altera‡„o ?") },"CONF"})

// INICIALIZACAO DE CAMPOS E TELA ___________________________________________

XNIVEL := 1

qrsay ( XNIVEL++ , qabrev(cTIPOEMP  ,"1234567890",{"Com‚rcio","Com‚rcio com Subst.Trib.",;
                                                 "M quina Registradora","Ind£stria",;
                                                 "Ind£stria com Subst.Trib.","Prestadora de Servi‡os",;
                                                 "Ind. Com. e Prest.Servi‡os","M q.Registradora 3 Deptos",;
                                                 "Regime Simplificado",;
                                                 "Regime Simplificado com IPI"}))

qrsay ( XNIVEL++ , qabrev(cNIVEL_EMP,"AB", {"Micro Empresa","Pequena Empresa"}))
qrsay ( XNIVEL++ , qabrev(cUSA_VEND ,"12", {"Sim","N„o"}))
qrsay ( XNIVEL++ , qabrev(cTIPO_EST ,"ABCD", {"Faixa A","Faixa B","Faixa C","Regime Normal"}))
qrsay ( XNIVEL++ , qabrev(cISS ,"12", {"Sim","N„o"}))
qrsay ( XNIVEL++ , qabrev(cIPI_DESC ,"SN", {"Sim","N„o"}))
qrsay ( XNIVEL++ , qabrev(cTRIB_SINC,"12", {"Sim","N„o"}))
qrsay ( XNIVEL++ , nPERC_SLP , "@E 999.99"   )
qrsay ( XNIVEL++ , nPERC_SUBTR,"@E 999.99"   )
qrsay ( XNIVEL++ , nLIM_ME_C , cPIC1         )
qrsay ( XNIVEL++ , nLIM_ME_F , cPIC1         )
qrsay ( XNIVEL++ , left(cCONF_TRIB,22), "@!" )
qrsay ( XNIVEL++ , cI_EST_ST , "@!"          )
qrsay ( XNIVEL++ , qabrev(cEXIGE_CUSTO ,"SN", {"Sim","N„o"}))

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

      replace CONFIG->Tipoemp    with  cTIPOEMP
      replace CONFIG->Nivel_emp  with  cNIVEL_EMP
      replace CONFIG->Usa_vend   with  cUSA_VEND
      replace CONFIG->Tipo_est   with  cTIPO_EST
      replace CONFIG->Iss        with  cISS
      replace CONFIG->Ipi_desc   with  cIPI_DESC
      replace CONFIG->Trib_sinc  with  cTRIB_SINC
      replace CONFIG->Perc_slp   with  nPERC_SLP
      replace CONFIG->Perc_subtr with  nPERC_SUBTR
      replace CONFIG->Lim_me_c   with  nLIM_ME_C
      replace CONFIG->Lim_me_f   with  nLIM_ME_F
      replace CONFIG->Conf_trib  with  cCONF_TRIB
      replace CONFIG->I_est_st   with  cI_EST_ST
      replace CONFIG->Exig_ccust with  cEXIGE_CUSTO

      CONFIG->(qunlock())
   else
      qmensa("Nao foi possivel alterar a configura‡„o, tente novamente","B")
   endif
endif

CONFIG->(dbclosearea())

return

/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA _____________________________________________

static function i_critica ( cCAMPO )
   do case
      case cCAMPO == "TIPOEMP"
           if empty(cTIPOEMP) ; return .F. ; endif
           qrsay(XNIVEL,qabrev(cTIPOEMP,"1234567890",{"Com‚rcio","Com‚rcio com Subst.Trib.",;
                                                    "M quina Registradora","Ind£stria",;
                                                    "Ind£stria com Subst.Trib.","Prestadora de Servi‡os",;
                                                    "Ind. Com. e Prest.Servi‡os","M q.Registradora 3 Deptos",;
                                                    "Regime Simplificado",;
                                                    "Regime Simplificado com IPI"}))

      case cCAMPO == "NIVEL_EMP"
           if empty(cNIVEL_EMP) ; return .F. ; endif
           qrsay(XNIVEL,qabrev(cNIVEL_EMP,"AB",{"Micro Empresa","Pequena Empresa"}))

      case cCAMPO == "USA_VEND"
           if empty(cUSA_VEND) ; return .F. ; endif
           qrsay(XNIVEL,qabrev(cUSA_VEND,"12",{"Sim","N„o"}))

      case cCAMPO == "TIPO_EST"
           if empty(cTIPO_EST) ; return .F. ; endif
           qrsay(XNIVEL,qabrev(cTIPO_EST,"ABCD",{"Faixa A","Faixa B","Faixa C","Regime Normal"}))

      case cCAMPO == "ISS"
           if empty(cISS) ; return .F. ; endif
           qrsay(XNIVEL,qabrev(cISS,"12",{"Sim","N„o"}))

      case cCAMPO == "TRIB_SINC"
           if empty(cTRIB_SINC) ; return .F. ; endif
           qrsay(XNIVEL,qabrev(cTRIB_SINC,"12",{"Sim","N„o"}))

      case cCAMPO == "IPI_DESC"
           if empty(cIPI_DESC)   ; return .F. ; endif
           qrsay(XNIVEL,qabrev(cIPI_DESC,"SN",{"Sim","N„o"}))

      case cCAMPO == "EXIGE_CUSTO"
           if empty(cEXIGE_CUSTO)   ; return .F. ; endif
           qrsay(XNIVEL,qabrev(cEXIGE_CUSTO,"SN",{"Sim","N„o"}))
   endcase
return .T.

