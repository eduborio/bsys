/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE TESOURARIA
// OBJETIVO...: ANTECIPACAO DA DATA DO MOVIMENTO
// ANALISTA...: LUCINEIDE VILAR POSSEBOM
// PROGRAMADOR: LUCINEIDE VILAR POSSEBOM
// INICIO.....: JANEIRO DE 1998
// OBS........:
// ALTERACOES.:
function ts404

// DECLARACAO DE VARIAVEIS __________________________________________________

local aEDICAO   := {}
local lCONF     := .F.

private bESCAPE := {||(XNIVEL==1 .and. !XFLAG .or. lastkey()=27.and.XNIVEL==1)}

private cDATA   := CONFIG->Data_atual

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

qlbloc(5,0,"B404A","QBLOC.GLO",1)

qmensa("<Pressione ESC para Cancelar>")

aadd(aEDICAO,{{ || qgetx(-1,0,@cDATA ,"@D" ) },"DATA" })

aadd(aEDICAO,{{ || lCONF := qconf("Confirma antecipacao da data do movimento ?") },"CONF"})

// INICIALIZACAO DE CAMPOS E TELA ___________________________________________

XNIVEL := 1

qrsay ( XNIVEL++ , cDATA )

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
      replace CONFIG->Data_ant with cDATA
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
   endcase

return .T.
