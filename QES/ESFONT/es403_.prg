/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: ESTOQUE
// OBJETIVO...: TRANSFERENCIA DE PRODUTOS ENTRE O.S.
// ANALISTA...: LUCINEIDE VILAR POSSEBOM
// PROGRAMADOR: A MESMA
// INICIO.....: AGOSTO DE 1999
// OBS........:
// ALTERACOES.:

// DECLARACAO DE VARIAVEIS __________________________________________________

function es403
local aEDICAO   := {}
local lCONF     := .F.
private cREQ_ORI  := space(5)
private cREQ_DES  := space(5)
private cOS

private bESCAPE := {||(XNIVEL==1 .and. !XFLAG .or. lastkey()=27.and.XNIVEL==1)}

qmensa("<Pressione ESC para Cancelar>")

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

qlbloc(5,0,"B403A","QBLOC.GLO",1)

aadd(aEDICAO,{{ || view_requi(15,48,@cREQ_ORI                        )} ,"REQ_ORI"       })
aadd(aEDICAO,{{ || view_requi(17,48,@cREQ_DES                        )} ,"REQ_DES"       })

aadd(aEDICAO,{{ || lCONF := qconf("Confirma transferˆncia ?") },"CONF"})

// INICIALIZACAO DE CAMPOS E TELA ___________________________________________

XNIVEL := 1

qrsay ( XNIVEL++ , cREQ_ORI )
qrsay ( XNIVEL++ , cREQ_DES )

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

   REQUISIC->(Dbgotop())

   if REQUISIC->(dbseek(cREQ_DES)) .and. REQUISIC->(qrlock())
      replace REQUISIC->Nr_os   with cOS
      REQUISIC->(qunlock())
   else
      qmensa("N„o foi poss¡vel alterar, tente novamente","B")
   endif

   REQUISIC->(Dbgotop())

   if REQUISIC->(dbseek(cREQ_ORI)) .and. REQUISIC->(qrlock())
      replace REQUISIC->Nr_os   with space(5)
      REQUISIC->(qunlock())
   else
      qmensa("N„o foi poss¡vel alterar, tente novamente","B")
   endif

endif

return

/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA _____________________________________________

static function i_critica ( cCAMPO )

   do case
      case cCAMPO == "REQ_ORI"

           qrsay(XNIVEL,cREQ_ORI)

           if ! REQUISIC->(dbseek(cREQ_ORI))
              qmensa("Requisi‡„o de Origem n„o encontrada !","B")
              return .F.
           endif

           if empty(REQUISIC->Nr_os)
              qmensa("Requisi‡„o de Origem n„o possui nr. de O.S.","B")
              return .F.
           else
              cOS := REQUISIC->Nr_os
           endif

      case cCAMPO == "REQ_DES"

           qrsay(XNIVEL,cREQ_DES)

           if ! REQUISIC->(dbseek(cREQ_DES))
              qmensa("Requisi‡„o de Destino n„o encontrada !","B")
              return .F.
           endif
           if cREQ_DES == cREQ_ORI
              qmensa("As requisi‡oes devem ser diferentes !","B")
              return .F.
           endif

   endcase

return .T.
