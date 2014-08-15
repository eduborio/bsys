
/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: ESTOQUE
// OBJETIVO...: SELECAO DO MES E DO ANO DO MOVIMENTO
// ANALISTA...: IN SUNG CHANG
// PROGRAMADOR: IN SUNG CHANG
// INICIO.....: JUNHO DE 1994
// OBS........:
// ALTERACOES.:
function es802

// DECLARACAO DE VARIAVEIS __________________________________________________

local aEDICAO   := {}
local lCONF     := .F.

private bESCAPE := {||(XNIVEL==1 .and. !XFLAG .or. lastkey()=27.and.XNIVEL==1)}

private cMES    := right(CONFIG->Anomes,2)
private cANO    := left(CONFIG->Anomes,4)

qmensa("<Pressione ESC para Cancelar>")

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

qlbloc(5,0,"B802A","QBLOC.GLO",1)

aadd(aEDICAO,{{ || qgetx(-1,0,@cMES ,"@99" ) },"MES" })
aadd(aEDICAO,{{ || qgetx(-1,0,@cANO ,"@9999" ) },"ANO" })

aadd(aEDICAO,{{ || lCONF := qconf("Confirma mes e ano para movimento ?") },"CONF"})

// INICIALIZACAO DE CAMPOS E TELA ___________________________________________

XNIVEL := 1

qrsay ( XNIVEL++ , cMES )
qrsay ( XNIVEL++ , cANO )

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
      replace CONFIG->Anomes   with cANO+cMES
      CONFIG->(qunlock())
   else
      qmensa("N„o foi poss¡vel alterar a configura‡„o, tente novamente","B")
   endif
endif

CONFIG->(dbclosearea())

return

/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA _____________________________________________

static function i_critica ( cCAMPO )

   local sBLOC := qsbloc(11,37,11,47)

   do case
      case cCAMPO == "MES"
           if empty(cMES) ; return .F. ; endif
           if val(cMES) > 13 .or. val(cMES) < 0
              return .F.
           endif
           qrsay(XNIVEL,qnomemes(val(cMES)))
      case cCAMPO == "ANO"
           if empty(cANO) ; return .F. ; endif
           if !XFLAG
             qrsay(XNIVEL-1,cMES := strzero(val(cMES),2))
             qrbloc(11,37,sBLOC)
           endif
   endcase

return .T.

