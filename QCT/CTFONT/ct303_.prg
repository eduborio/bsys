
/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE CAIXA
// OBJETIVO...: CONSULTA EQUILIBRIO
// ANALISTA...: LUIS ANTONIO ORLANDO PEREIRA
// PROGRAMADOR: O MESMO
// INICIO.....: JANEIRO DE 1994
// OBS........:
// ALTERACOES.:
function ct303

local nDB, nCR, nCONT

local nSOMADB := nSOMACR := 0

local cPIC := "@E 9,999,999,999.99"

local sBLOC := qsbloc(5,0,23,79)

qlbloc(5,0,"B303A","QBLOC.GLO")

for nCONT := 1 to 12
    nDB := CONFIG->&("DB"+strzero(nCONT,2))
    nCR := CONFIG->&("CR"+strzero(nCONT,2))

    nSOMADB += nDB
    nSOMACR += nCR

    qsay(nCONT+8,18,abs(nDB),cPIC)

    qsay(nCONT+8,37,abs(nCR),cPIC)

    nCR := abs(nCR)

    do case
       case nDB == nCR ; qsay(nCONT+8,58,"Equilibrado")
       case nDB >  nCR ; qsay(nCONT+8,58,"Faltam cr‚ditos...")
       case nDB <  nCR ; qsay(nCONT+8,58,"Faltam d‚bitos...")
    endcase
next

qsay(22,18,abs(nSOMADB),cPIC)
qsay(22,37,abs(nSOMACR),cPIC)

qwait()

qrbloc(5,0,sBLOC)

return

