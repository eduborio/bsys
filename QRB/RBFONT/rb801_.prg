/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE CONTAS A RECEBER
// OBJETIVO...: CONFIGURACAO GERAL DO SISTEMA
// ANALISTA...:
// PROGRAMADOR:
// INICIO.....: NOVEMBRO DE 1996
// OBS........:
// ALTERACOES.:
function rb801

// DECLARACAO DE VARIAVEIS __________________________________________________

local aEDICAO   := {}
local lCONF     := .F.

private bESCAPE  := { || XNIVEL == 1 .and. !XFLAG .or. XNIVEL == 1 .and. Lastkey() ==27 }
private nCOD_REC := CONFIG->Cod_rec
private nCOD_LOT := CONFIG->Num_lote
private nTIPO_FAT:= CONFIG->Tipo_fat
private sBLOC1  := qlbloc("B801B","QBLOC.GLO")


// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qgetx(-1,0,@nCOD_REC                 ) },"COD_REC"  })
aadd(aEDICAO,{{ || qgetx(-1,0,@nCOD_LOT                 ) },"COD_LOT"  })
aadd(aEDICAO,{{ || qesco(-1,0,@nTIPO_FAT ,sBLOC1        ) } ,"TIPO_FAT"})
aadd(aEDICAO,{{ || lCONF := qconf("Confirma altera‡„o ?") },"CONF"     })

// INICIALIZACAO DE CAMPOS E TELA ___________________________________________

qlbloc(05,00,"B801A","QBLOC.GLO",1)
XNIVEL := 1
XFLAG  := .T.

qrsay(XNIVEL++,strzero(CONFIG->Cod_rec,7))
qrsay(XNIVEL++,strzero(CONFIG->Num_lote,5))
qrsay(XNIVEL++,qabrev(CONFIG->Tipo_fat,"123456789A", {"Comercial","Industrial","Servi‡os","Tele-Vendas","Transportes","Concretagem","Loja","Acessoria","Fabrica","Industria"}))

XNIVEL := 1
qmensa("<ESC - Cancela>")
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
      CONFIG->Cod_rec := nCOD_REC
      CONFIG->Num_lote:= nCOD_LOT
      CONFIG->Tipo_fat:= nTIPO_FAT
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
      case cCAMPO == "COD_REC"
           if nCOD_REC < 0 ; return .F. ; endif
           qrsay(XNIVEL,strzero(nCOD_REC,7))
      case cCAMPO == "COD_LOT"
           if nCOD_LOT < 0 ; return .F. ; endif
           qrsay(XNIVEL,strzero(nCOD_LOT,5))

      case cCAMPO == "TIPO_FAT"
           if empty(nTIPO_FAT) ; return .F. ; endif
           qrsay(XNIVEL,qabrev(nTIPO_FAT,"123456789A", {"Comercial","Industrial","Servi‡os","Tele-Vendas","Transportes","Concretagem","Loja","Acessoria","Fabrica","Industria"}))

   endcase

return .T.
