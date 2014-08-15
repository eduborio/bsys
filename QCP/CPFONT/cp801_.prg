
/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE COMPRAS
// OBJETIVO...: CONFIGURACAO GERAL DO SISTEMA
// ANALISTA...:
// PROGRAMADOR:
// INICIO.....: NOVEMBRO DE 1996
// OBS........:
// ALTERACOES.:

// DECLARACAO DE VARIAVEIS __________________________________________________

function cp801

local aEDICAO   := {}
local lCONF     := .F.

private bESCAPE     := { || XNIVEL == 1 .and. !XFLAG .or. XNIVEL == 1 .and. Lastkey()==27}
private cMES        := right(CONFIG->Anomes,2)
private cANO        := left(CONFIG->Anomes,4)
private nCOD_FORN   := CONFIG->Cod_forn
private nCOD_PROD   := CONFIG->Cod_prod
private nCOD_COMP   := CONFIG->Cod_comp
private nCOD_PEDIDO := CONFIG->Cod_pedido
private nCOD_SER    := CONFIG->Cod_ser
private nCOD_ESP    := CONFIG->Cod_esp
private nCOD_UNI    := CONFIG->Cod_uni

qmensa("<Pressione ESC para Cancelar>")

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qgetx(-1,0,@cMES ,"@99"              ) },"MES" })
aadd(aEDICAO,{{ || qgetx(-1,0,@cANO ,"@9999"            ) },"ANO" })
aadd(aEDICAO,{{ || qgetx(-1,0,@nCOD_FORN                ) },"COD_FORN"  })
aadd(aEDICAO,{{ || qgetx(-1,0,@nCOD_PROD                ) },"COD_PROD"  })
aadd(aEDICAO,{{ || qgetx(-1,0,@nCOD_COMP                ) },"COD_COMP"  })
aadd(aEDICAO,{{ || qgetx(-1,0,@nCOD_PEDIDO              ) },"COD_PEDIDO"})
aadd(aEDICAO,{{ || qgetx(-1,0,@nCOD_SER                 ) },"COD_SER"})
aadd(aEDICAO,{{ || qgetx(-1,0,@nCOD_ESP                 ) },"COD_ESP"})
aadd(aEDICAO,{{ || qgetx(-1,0,@nCOD_UNI                 ) },"COD_UNI"})
aadd(aEDICAO,{{ || lCONF := qconf("Confirma altera‡„o ?") },"CONF"      })

// INICIALIZACAO DE CAMPOS E TELA ___________________________________________

qlbloc(05,00,"B801A","QBLOC.GLO",1)

XNIVEL := 1
XFLAG  := .T.

qrsay ( XNIVEL++ , cMES )
qrsay ( XNIVEL++ , cANO )
qrsay(XNIVEL++,strzero(CONFIG->Cod_forn,5))
qrsay(XNIVEL++,strzero(CONFIG->Cod_prod,5))
qrsay(XNIVEL++,strzero(CONFIG->Cod_comp,5))
qrsay(XNIVEL++,strzero(CONFIG->Cod_pedido,5))
qrsay(XNIVEL++,strzero(CONFIG->Cod_ser,2))
qrsay(XNIVEL++,strzero(CONFIG->Cod_esp,2))
qrsay(XNIVEL++,strzero(CONFIG->Cod_uni,3))

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
      CONFIG->Anomes     := cANO+cMES
      CONFIG->Cod_forn   := nCOD_FORN
      CONFIG->Cod_prod   := nCOD_PROD
      CONFIG->Cod_comp   := nCOD_COMP
      CONFIG->Cod_pedido := nCOD_PEDIDO
      CONFIG->Cod_ser    := nCOD_SER
      CONFIG->Cod_esp    := nCOD_ESP
      CONFIG->Cod_uni    := nCOD_UNI
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
      case cCAMPO == "MES"
           if empty(cMES) ; return .F. ; endif
           if val(cMES) > 13 .or. val(cMES) < 0
              return .F.
           endif
           qrsay(XNIVEL,qnomemes(val(cMES)))
      case cCAMPO == "ANO"
           if empty(cANO) ; return .F. ; endif
           if val(cANO) < 1995
              qmensa("Ano deve ser maior que 1994 ?","B")
              return .F.
           endif
      case cCAMPO == "COD_FORN"
           if  nCOD_FORN < 0 ; return .F. ; endif
           qrsay(XNIVEL,strzero(nCOD_FORN,5))
      case cCAMPO == "COD_PROD"
           if nCOD_PROD < 0  ; return .F. ; endif
           qrsay(XNIVEL,strzero(nCOD_PROD,5))
      case cCAMPO == "COD_COMP"
           if nCOD_COMP < 0  ; return .F. ; endif
           qrsay(XNIVEL,strzero(nCOD_COMP,5))
      case cCAMPO == "COD_PEDIDO"
           if nCOD_PEDIDO < 0  ; return .F. ; endif
           qrsay(XNIVEL,strzero(nCOD_PEDIDO,5))
      case cCAMPO == "COD_SER"
           if nCOD_SER < 0  ; return .F. ; endif
           qrsay(XNIVEL,strzero(nCOD_SER,2))
      case cCAMPO == "COD_ESP"
           if nCOD_ESP < 0  ; return .F. ; endif
           qrsay(XNIVEL,strzero(nCOD_ESP,2))
      case cCAMPO == "COD_UNI"
           if nCOD_UNI < 0  ; return .F. ; endif
           qrsay(XNIVEL,strzero(nCOD_UNI,3))
   endcase
return .T.

