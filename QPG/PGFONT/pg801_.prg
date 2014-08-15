/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE CONTAS A PAGAR
// OBJETIVO...: CONFIGURACAO GERAL DO SISTEMA
// ANALISTA...:
// PROGRAMADOR:
// INICIO.....: NOVEMBRO DE 1996
// OBS........:
// ALTERACOES.:
function pg801

// DECLARACAO DE VARIAVEIS __________________________________________________

local aEDICAO   := {}
local lCONF     := .F.
qmensa("<ESC - Cancela>")
private bESCAPE := { || XNIVEL == 1 .and. !XFLAG .or. XNIVEL == 1 .and. Lastkey()==27}
private nCOD_FORN := CONFIG->Cod_forn
private nCOD_ESP  := CONFIG->Cod_esp
private nCOD_SER  := CONFIG->Cod_ser
private nCOD_PAG  := CONFIG->Cod_pag
private nTIPO_FAT:= CONFIG->Tipo_fat
private sBLOC1  := qlbloc("B801B","QBLOC.GLO")

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qgetx(-1,0,@nCOD_FORN                ) },"COD_FORN" })
aadd(aEDICAO,{{ || qgetx(-1,0,@nCOD_ESP                 ) },"COD_ESP"  })
aadd(aEDICAO,{{ || qgetx(-1,0,@nCOD_SER                 ) },"COD_SER"  })
aadd(aEDICAO,{{ || qgetx(-1,0,@nCOD_PAG                 ) },"COD_PAG"  })
aadd(aEDICAO,{{ || qesco(-1,0,@nTIPO_FAT ,sBLOC1        ) } ,"TIPO_FAT"})
aadd(aEDICAO,{{ || lCONF := qconf("Confirma altera‡„o ?") },"CONF"     })

// INICIALIZACAO DE CAMPOS E TELA ___________________________________________

qlbloc(05,00,"B801A","QBLOC.GLO",1)
XNIVEL := 1
XFLAG  := .T.

qrsay(XNIVEL++,strzero(CONFIG->Cod_forn,5))
qrsay(XNIVEL++,strzero(CONFIG->Cod_esp,2))
qrsay(XNIVEL++,strzero(CONFIG->Cod_ser,2))
qrsay(XNIVEL++,strzero(CONFIG->Cod_pag,7))
qrsay(XNIVEL++,qabrev(CONFIG->Tipo_fat,"1234", {"Servi‡os","Transportes","Embalagens","Nenhum"}))

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
      CONFIG->Cod_forn := nCOD_FORN
      CONFIG->Cod_esp  := nCOD_ESP
      CONFIG->Cod_ser  := nCOD_SER
      CONFIG->Cod_pag  := nCOD_PAG
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
      case cCAMPO == "COD_FORN"
           if  nCOD_FORN < 0 ; return .F. ; endif
           qrsay(XNIVEL,strzero(nCOD_FORN,5))
      case cCAMPO == "COD_ESP"
           if nCOD_ESP < 0  ; return .F. ; endif
           qrsay(XNIVEL,strzero(nCOD_ESP,2))
      case cCAMPO == "COD_SER"
           if nCOD_SER < 0 ; return .F. ; endif
           qrsay(XNIVEL,strzero(nCOD_SER,2))
      case cCAMPO == "COD_PAG"
           if nCOD_PAG < 0 ; return .F. ; endif
           qrsay(XNIVEL,strzero(nCOD_PAG,7))
      case cCAMPO == "TIPO_FAT"
           if empty(nTIPO_FAT) ; return .F. ; endif
           qrsay(XNIVEL,qabrev(nTIPO_FAT,"1234", {"Servi‡os","Transportes","Embalagens","Nenhum"}))
   endcase
return .T.
