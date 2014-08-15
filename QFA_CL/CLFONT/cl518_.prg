/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO DA USIMIX
// OBJETIVO...: EMISSAO DE ETIQUETAS P/ MALA DIRETA
// ANALISTA...: LUIS ANTONIO ORLANDO PEREIRA
// PROGRAMADOR: LUIS ANTONIO ORLANDO PEREIRA
// INICIO.....: OUTUBRO DE 1995
// OBS........:
// ALTERACOES.:

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

function cl518
local   bESCAPE := {|| (XNIVEL==1 .and. !XFLAG) .or. lastkey()==27 }

private sBLOC1  := qlbloc("B501B","QBLOC.GLO") // Ordem Codigo ou Razao

private aEDICAO := {}    // vetor para os campos de entrada de dados
private cLINHA1
private cLINHA2
private cLINHA3
private cLINHA4
//private nQUANT


// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qgetx(-1,0,@cLINHA1)   } , "LINHA1" })
aadd(aEDICAO,{{ || qgetx(-1,0,@cLINHA2)   } , "LINHA2" })
aadd(aEDICAO,{{ || qgetx(-1,0,@cLINHA3)   } , "LINHA3" })
aadd(aEDICAO,{{ || qgetx(-1,0,@cLINHA4)   } , "LINHA4" })
//aadd(aEDICAO,{{ || qgetx(-1,0,@nQUANT )   } , "QUANT" })

do while .T.

   qlbloc(5,0,"B518A","QBLOC.GLO")

   XNIVEL  := 1
   XFLAG   := .T.
   cLINHA1 := space(20)
   cLINHA2 := space(20)
   cLINHA3 := space(20)
   cLINHA4 := space(20)
  // nQUANT := 0

   // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; dbcloseall() ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ); loop   ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   i_impressao()

   qmensa("")

enddo

/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA _____________________________________________

static function i_critica ( cCAMPO )

   do case
      case cCAMPO == "LINHA1"

   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impressao
   local zLINHA1:=zLINHA2:=zLINHA3:=zLINHA4:=space(20)
   local nCONT := 1
   zLINHA1 := cLINHA1
   zLINHA2 := cLINHA2
   zLINHA3 := cLINHA3
   zLINHA4 := cLINHA4


   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif
   @ prow()+2,00 say ""
   do while nCONT <= 15
      if ! qlineprn() ; exit ; endif
       @ prow(),pcol() say XCOND1
       @ prow()+1,00 say zLINHA1 +"       "+ zLINHA1+"      "+ zLINHA1+"      "+ zLINHA1+"      "+ zLINHA1+"      "+ zLINHA1+"      "+ zLINHA1+"      "+ zLINHA1+"      "+ zLINHA1+"      "+ zLINHA1
       @ prow()+1,00 say zLINHA2 +"       "+ zLINHA2+"      "+ zLINHA2+"      "+ zLINHA2+"      "+ zLINHA2+"      "+ zLINHA2+"      "+ zLINHA2+"      "+ zLINHA2+"      "+ zLINHA2+"      "+ zLINHA2
       @ prow()+1,00 say zLINHA3 +"       "+ zLINHA3+"      "+ zLINHA3+"      "+ zLINHA3+"      "+ zLINHA3+"      "+ zLINHA3+"      "+ zLINHA3+"      "+ zLINHA3+"      "+ zLINHA3+"      "+ zLINHA3
       @ prow()+1,00 say zLINHA4 +"       "+ zLINHA4+"      "+ zLINHA4+"      "+ zLINHA4+"      "+ zLINHA4+"      "+ zLINHA4+"      "+ zLINHA4+"      "+ zLINHA4+"      "+ zLINHA4+"      "+ zLINHA4

       if nCONT == 1 .or. nCONT == 3 .or. nCONT ==5.or. nCONT ==7.or. nCONT ==9.or. nCONT ==11.or. nCONT ==13.or. nCONT ==15
            @ prow()+1,00 say""
       endif
       nCONT++
 enddo

   qstopprn()

return
