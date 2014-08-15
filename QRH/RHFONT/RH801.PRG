/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: FOLHA DE PAGAMENTO
// OBJETIVO...: CONFIGURACAO GERAL DO SISTEMA
// ANALISTA...: CARLOS EDUARDO RABELLO NUNES
// PROGRAMADOR: O MESMO
// INICIO.....: SETEMBRO DE 1996
// OBS........:
// ALTERACOES.:

// DECLARACAO DE VARIAVEIS __________________________________________________

local aEDICAO := {}
local lCONF   := .F.
local sBLOCO1 := qlbloc("B801B","QBLOC.GLO") // informada/gerada
local sBLOCO2 := qlbloc("B801C","QBLOC.GLO") // centesimal ou hora:minuto

private bESCAPE := { || XNIVEL == 1 .and. !XFLAG .or. lastkey()==27}

private cTIPO_MAT   := CONFIG->Tipo_mat
private cPROXMAT    := CONFIG->Matricula+1
private cSINC_SAL   := CONFIG->Sinc_sal
private cAUTO_MS    := CONFIG->Auto_ms
private cBFGTS      := CONFIG->Banco_fgts
private cCFGTS      := CONFIG->Conta_fgts
private cTIPO_CC    := CONFIG->Tipo_cc
private cCNAE       := CONFIG->Cnae
private cAGSAL      := CONFIG->Agenc_sal
private cCCSAL      := CONFIG->Conta_sal
private nDIAS_CTR   := CONFIG->Dias_ctr
private cGR_SIMPLES := CONFIG->Gr_simples
private cFC_HORA    := CONFIG->Fc_hora
private cALIQ       := CONFIG->Aliq
private cDATASYS
qmensa("<ESC - Cancela>")
if empty(CONFIG->Datasys) .and. empty(CONFIG->Data_atual)
   cDATASYS := ctod("")
   qmensa("Informe o in¡cio do Sistema:","B")
   qgetx(24,40,@cDATASYS,"@D")
   cDATASYS := qfimmes(cDATASYS)
   if CONFIG->(qrlock())
      replace CONFIG->Datasys    with cDATASYS
      replace CONFIG->Data_atual with cDATASYS
   else
      qmensa("N„o foi poss¡vel abrir o arquivo CONFIG.DBF !","B")
      return
   endif
   qmensa("")
endif

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qesco(-1,0,@cTIPO_MAT,sBLOCO1 ) },"TIPO_MAT"   })
aadd(aEDICAO,{{ || qgetx(-1,0,@cPROXMAT ,"999999") },"PROXMAT"    })
aadd(aEDICAO,{{ || qesco(-1,0,@cSINC_SAL,XSN     ) },"SINC_SAL"   })
aadd(aEDICAO,{{ || qesco(-1,0,@cAUTO_MS ,XSN     ) },"AUTO_MS"    })
aadd(aEDICAO,{{ || view_banco(-1,0,@cBFGTS       ) },"BFGTS"      })
aadd(aEDICAO,{{ || NIL },""})
aadd(aEDICAO,{{ || qgetx(-1,0,@cCFGTS   ,"@!"    ) },"CFGTS"      })
aadd(aEDICAO,{{ || qgetx(-1,0,@cTIPO_CC,"9"      ) },"TIPO_CC"    })
aadd(aEDICAO,{{ || view_cnae(-1,0,@cCNAE         ) },"CNAE"       })
aadd(aEDICAO,{{ || NIL },""})
aadd(aEDICAO,{{ || qgetx(-1,0,@cAGSAL   ,"@!"    ) },"AGSAL"      })
aadd(aEDICAO,{{ || qgetx(-1,0,@cCCSAL   ,"@!"    ) },"CCSAL"      })
aadd(aEDICAO,{{ || qgetx(-1,0,@nDIAS_CTR,"99"    ) },"DIAS_CTR"   })
aadd(aEDICAO,{{ || qesco(-1,0,@cGR_SIMPLES,XSN   ) },"GR_SIMPLES" })
aadd(aEDICAO,{{ || qesco(-1,0,@cFC_HORA ,sBLOCO2 ) },"FC_HORA"    })
aadd(aEDICAO,{{ || qesco(-1,0,@cALIQ ,XSN        ) },"ALIQ"    })
aadd(aEDICAO,{{ || lCONF := qconf("Confirma altera‡„o ?") },"CONF"})

// INICIALIZACAO DE CAMPOS E TELA ___________________________________________

XNIVEL := 1
qrsay ( XNIVEL++ , qabrev(cTIPO_MAT,"IG",{"Informada","Gerada"}) )
qrsay ( XNIVEL++ , cPROXMAT ,"999999" )
qrsay ( XNIVEL++ , qabrev(cSINC_SAL,"SN",{"Sim","N„o"}) )
qrsay ( XNIVEL++ , qabrev(cAUTO_MS,"SN",{"Sim","N„o"}) )
BANCO->(dbseek(cBFGTS))
qrsay ( XNIVEL++ , cBFGTS )
qrsay ( XNIVEL++ , BANCO->Descricao)
qrsay ( XNIVEL++ , cCFGTS )
qrsay ( XNIVEL++ , cTIPO_CC )
qrsay ( XNIVEL++ , cCNAE )
CNAE->(dbseek(cCNAE))
qrsay ( XNIVEL++ , left(CNAE->Descricao,63) )
qrsay ( XNIVEL++ , cAGSAL )
qrsay ( XNIVEL++ , cCCSAL )
qrsay ( XNIVEL++ , nDIAS_CTR , "99" )
qrsay ( XNIVEL++ , qabrev(cGR_SIMPLES,"SN",{"Sim","N„o"}))
qrsay ( XNIVEL++ , qabrev(cFC_HORA,"CH",{"Centesimal","Hora:Minuto"}) )
qrsay ( XNIVEL++ , qabrev(cALIQ,"SN",{"Sim","N„o"}))

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
      replace CONFIG->Tipo_mat   with cTIPO_MAT
      replace CONFIG->Matricula  with cPROXMAT-1
      replace CONFIG->Sinc_sal   with cSINC_SAL
      replace CONFIG->Auto_ms    with cAUTO_MS
      replace CONFIG->Banco_fgts with cBFGTS
      replace CONFIG->Conta_fgts with cCFGTS
      replace CONFIG->Tipo_cc    with cTIPO_CC
      replace CONFIG->Cnae       with cCNAE
      replace CONFIG->Agenc_sal  with cAGSAL
      replace CONFIG->Conta_sal  with cCCSAL
      replace CONFIG->Dias_ctr   with nDIAS_CTR
      replace CONFIG->Gr_simples with cGR_SIMPLES
      replace CONFIG->Fc_hora    with cFC_HORA
      replace CONFIG->Aliq       with cALIQ

      CONFIG->(qunlock())
   else
      qmensa("Nao foi possivel alterar a configura‡„o, tente novamente","B")
   endif
endif
return

/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA _____________________________________________

static function i_critica ( cCAMPO )
   do case
      case cCAMPO == "TIPO_MAT"
           if empty(cTIPO_MAT) ; return .F. ; endif
           qrsay ( XNIVEL , qabrev(cTIPO_MAT,"IG",{"Informada","Gerada"}) )
      case cCAMPO == "SINC_SAL"
           if empty(cSINC_SAL) ; return .F. ; endif
           qrsay ( XNIVEL , qabrev(cSINC_SAL,"SN",{"Sim","N„o"}) )
      case cCAMPO == "AUTO_MS"
           if empty(cAUTO_MS) ; return .F. ; endif
           qrsay ( XNIVEL , qabrev(cAUTO_MS,"SN",{"Sim","N„o"}) )
      case cCAMPO == "BFGTS"
           if ! BANCO->(dbseek(cBFGTS)) ; return .F. ; endif
           qrsay ( XNIVEL+1 , BANCO->Descricao )
      case cCAMPO == "CNAE"
           if ! CNAE->(dbseek(cCNAE)) ; return .F. ; endif
           qrsay ( XNIVEL+1 , left(CNAE->Descricao,63) )
      case cCAMPO == "GR_SIMPLES"
           if empty(cGR_SIMPLES) ; return .F. ; endif
           qrsay ( XNIVEL , qabrev(cGR_SIMPLES,"SN",{"Sim","N„o"}) )
      case cCAMPO == "FC_HORA"
           if empty(cFC_HORA) ; return .F. ; endif
           qrsay ( XNIVEL , qabrev(cFC_HORA,"CH",{"Centesimal","Hora:Minuto"}) )
      case cCAMPO == "ALIQ"
           if empty(cALIQ) ; return .F. ; endif
           qrsay ( XNIVEL , qabrev(cALIQ,"SN",{"Sim","N„o"}) )

   endcase
return .T.

