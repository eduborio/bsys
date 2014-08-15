/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: FOLHA DE PAGAMENTO
// OBJETIVO...: ALTERACAO DO PERIODO DE TRABALHO
// ANALISTA...: CARLOS EDUARDO RABELLO NUNES
// PROGRAMADOR: O MESMO
// INICIO.....: SETEMBRO DE 1996
// OBS........:
// ALTERACOES.:

private cDATASYS := XDATASYS
private cTECLA , cSENHA := ""

// SOLICITA SENHA __________________________________________________________
qmensa("<ESC - Cancela>")
setpos(15,40)
setcolor(atcsc_sl(row(),col()))
do while .T.
   cTECLA := upper(chr(qinkey(0)))
   if lastkey() == 13 .or. lastkey() == 27 ; return ; endif
   if (lastkey() == 8 .or. lastkey() == 19) .and. len(cSENHA) > 0
      cSENHA := left(cSENHA,len(cSENHA)-1)
      qsay(15,col()-1," ")
      setpos(15,col()-1)
   elseif len(cSENHA) < 6 .and. asc(cTECLA) > 32
      cSENHA += cTECLA
      ?? "*"
   endif
   if len(cSENHA) == 6
      exit
   endif
enddo

if empty(cSENHA) .or. cSENHA != "301264"
   return
endif

XNIVEL := 1
qgetx(-1,0,@cDATASYS)

//  if cDATASYS < ctod("01/01/97")                // foi liberada sob autorizacao do claudio 24/03/97
//     qmensa("Esta vers„o n„o processa datas anteriores a 01/01/97 !!","B")
//     return
//  endif

qrsay(2,qnomemes(month(cDATASYS)))
qrsay(3,str(year(cDATASYS),4))

if cDATASYS > qfimmes(XDATA_ATUAL)
   qmensa("Esta op‡„o n„o permite abertura de novo mˆs, somente a op‡„o 810 !!","B")
   return
endif

if qconf("Confirma transferˆncia para este periodo ?")
   if cDATASYS == XDATASYS
      qmensa("Imposs¡vel transferir para o mesmo mˆs !!","B")
      return
   endif

   if CONFIG->(qrlock())
      XANOMES := qanomes(cDATASYS)

      SITUA->(dbSetFilter({|| Anomes == XANOMES},"Anomes == XANOMES"))

      if SITUA->(eof())
         qmensa("Sem dados para este mˆs !!","B")
         return
      endif

      replace CONFIG->Datasys    with cDATASYS

      replace CONFIG->Verif_grps with .F.

      CONFIG->(qunlock())
   endif
else
   return
endif

FUN->(dbgotop())

qmensa("Aguarde...Preparando arquivos para per¡odo desejado...")

do while ! FUN->(eof())
   qgirabarra()
   if SITUA->(dbseek(FUN->Matricula))
      if FUN->(qrlock())
         replace FUN->Situacao with SITUA->Situacao
      endif
   else
      if FUN->(qrlock())
         replace FUN->Situacao with "H"
      endif
   endif

   FUN->(dbskip())
enddo

return
