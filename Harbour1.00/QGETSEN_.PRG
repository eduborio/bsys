
/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR GET INVISIVEL _______________________________________

function qgetsenha ( nLIN , nCOL , nLEN )

   local cSENHA  := ""
   local cTECLA  := ""
   local nCURSOR := setcursor(1)

   setpos(nLIN,nCOL)
   setcolor(atcsc_sl(nLIN,nCOL))

   do while .T.
      cTECLA := upper(chr(qinkey(0)))
      if lastkey() == 13 .or. lastkey() == 27 ; exit ; endif
      if (lastkey() == 8 .or. lastkey() == 19) .and. len(cSENHA) > 0
         cSENHA := left(cSENHA,len(cSENHA)-1)
         qsay(nLIN,col()-1," ")
         setpos(nLIN,col()-1)
      elseif len(cSENHA) < nLEN .and. asc(cTECLA) > 32
         cSENHA += cTECLA
         ?? "þ"
      endif
   enddo

   setcursor(nCURSOR)

return pad(cSENHA,nLEN)

