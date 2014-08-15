/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE TESOURARIA
// OBJETIVO...: SELECAO DA DATA DO MOVIMENTO
// ANALISTA...: LUIS ANTONIO ORLANDO PEREIRA
// PROGRAMADOR: LUCINEIDE VILAR POSSEBOM
// INICIO.....: ABRIL DE 1997
// OBS........:
// ALTERACOES.:

// DECLARACAO DE VARIAVEIS __________________________________________________

function ts802

local aEDICAO   := {}
local lCONF     := .F.

private bESCAPE := {||(XNIVEL==1 .and. !XFLAG .or. lastkey()=27.and.XNIVEL==1)}

private cDATA   := CONFIG->Data

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

qlbloc(5,0,"B803A","QBLOC.GLO",1)

aadd(aEDICAO,{{ || qgetx(-1,0,@cDATA ,"@D" ) },"DATA" })

aadd(aEDICAO,{{ || lCONF := qconf("Confirma data do movimento ?") },"CONF"})

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
      replace CONFIG->Data with cDATA
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
