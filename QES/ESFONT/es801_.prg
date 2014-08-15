/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE COMPRAS
// OBJETIVO...: CONFIGURACAO GERAL DO SISTEMA
// ANALISTA...:
// PROGRAMADOR:
// INICIO.....: NOVEMBRO DE 1996
// OBS........:
// ALTERACOES.:
function es801

// DECLARACAO DE VARIAVEIS __________________________________________________

local aEDICAO   := {}
local lCONF     := .F.

private bESCAPE      := { || XNIVEL == 1 .and. !XFLAG .or. XNIVEL == 1 .and. Lastkey()==27 }
private nCOD_ORDEM   := CONFIG->Cod_ordem
private nCOD_ACAB    := CONFIG->Cod_acab
private nTIPO_FAT    := CONFIG->Tipo_fat
private sBLOC1  := qlbloc("B801B","QBLOC.GLO")

qmensa("<Pressione ESC para Cancelar>")

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qgetx(-1,0,@nCOD_ORDEM               ) },"COD_ORDEM" })
aadd(aEDICAO,{{ || qgetx(-1,0,@nCOD_ACAB                ) },"COD_ACAB"  })
aadd(aEDICAO,{{ || qesco(-1,0,@nTIPO_FAT ,sBLOC1        ) } ,"TIPO_FAT"})
aadd(aEDICAO,{{ || lCONF := qconf("Confirma altera‡„o ?") },"CONF"      })

// INICIALIZACAO DE CAMPOS E TELA ___________________________________________

qlbloc(05,00,"B801A","QBLOC.GLO",1)

XNIVEL := 1
XFLAG  := .T.

qrsay(XNIVEL++,strzero(CONFIG->Cod_ordem,5))
qrsay(XNIVEL++,strzero(CONFIG->Cod_acab,5))
qrsay(XNIVEL++,qabrev(CONFIG->Tipo_fat,"123456789A", {"Comercial","Industrial","Servi‡os","Tele-Vendas","Transportes","Concretagem","Loja","Acessoria","Fabrica","Industria"}))

XNIVEL := 1

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
      CONFIG->Cod_ordem   := nCOD_ORDEM
      CONFIG->Cod_acab    := nCOD_ACAB
      CONFIG->Tipo_fat    := nTIPO_FAT
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
      case cCAMPO == "COD_ORDEM"
           if  nCOD_ORDEM < 0 ; return .F. ; endif
           qrsay(XNIVEL,strzero(nCOD_ORDEM,5))
      case cCAMPO == "COD_ACAB"
           if  nCOD_ACAB < 0 ; return .F. ; endif
           qrsay(XNIVEL,strzero(nCOD_ACAB,5))
      case cCAMPO == "TIPO_FAT"
           if empty(nTIPO_FAT) ; return .F. ; endif
           qrsay(XNIVEL,qabrev(nTIPO_FAT,"123456789A", {"Comercial","Industrial","Servi‡os","Tele-Vendas","Transportes","Concretagem","Loja","Acessoria","Fabrica","Industria"}))
   endcase
return .T.
