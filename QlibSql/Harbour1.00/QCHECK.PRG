
/////////////////////////////////////////////////////////////////////////////
// CHECA CPF ________________________________________________________________

function qcheckcpf ( cCPF )

   local nCONT := nTOT := nREST := nRESULT := 0

   // RETIRA PONTUACAO ______________________________________________________

   cCPF := strtran(cCPF,"-","")
   cCPF := strtran(cCPF,"/","")
   cCPF := strtran(cCPF,".","")
   cCPF := alltrim(cCPF)

   if len(cCPF) <> 11 ; return .F. ; endif

   // VERIFICA SE E TOTALMENTE NUMERICO _____________________________________

   for nCONT = 1 to 11
      if subs(cCPF,nCONT,1) < '0' .or. subs(cCPF,nCONT,1) > '9'
         return .F.
      endif
   next

   // INICIO DO CALCULO _____________________________________________________

   nTOT += val(subs(cCPF,1,1)) * 10
   nTOT += val(subs(cCPF,2,1)) * 09
   nTOT += val(subs(cCPF,3,1)) * 08
   nTOT += val(subs(cCPF,4,1)) * 07
   nTOT += val(subs(cCPF,5,1)) * 06
   nTOT += val(subs(cCPF,6,1)) * 05
   nTOT += val(subs(cCPF,7,1)) * 04
   nTOT += val(subs(cCPF,8,1)) * 03
   nTOT += val(subs(cCPF,9,1)) * 02

   nREST   := mod(nTOT,11)
   nRESULT := 11 - nREST

   if nRESULT > 9
      nRESULT := 0
   Endif

   if nRESULT = val(subs(cCPF,10,1))

     nTOT    := 0
     nREST   := 0
     nRESULT := 0

     nTOT += val(subs(cCPF, 1,1)) * 11
     nTOT += val(subs(cCPF, 2,1)) * 10
     nTOT += val(subs(cCPF, 3,1)) * 09
     nTOT += val(subs(cCPF, 4,1)) * 08
     nTOT += val(subs(cCPF, 5,1)) * 07
     nTOT += val(subs(cCPF, 6,1)) * 06
     nTOT += val(subs(cCPF, 7,1)) * 05
     nTOT += val(subs(cCPF, 8,1)) * 04
     nTOT += val(subs(cCPF, 9,1)) * 03
     nTOT += val(subs(cCPF,10,1)) * 02

     nREST   := mod(nTOT,11)
     nRESULT := 11 - nREST

     if nRESULT > 9
        nRESULT := 0
     endif

     if nRESULT <> val(subs(cCPF,11,1))
        return .F.
     endif

   else

     return .F.

   endif

return .T.


/////////////////////////////////////////////////////////////////////////////
// CHECA CGC ________________________________________________________________

function qcheckcgc ( cCGC )

   local nCONT := nTOT := nREST := nRESULT := 0

   // RETIRA PONTUACAO ______________________________________________________

   cCGC := strtran(cCGC,"-","")
   cCGC := strtran(cCGC,"/","")
   cCGC := strtran(cCGC,".","")
   cCGC := alltrim(cCGC)

   if len(cCGC) <> 14 ; return .F. ; endif

   // VERIFICA SE E TOTALMENTE NUMERICO _____________________________________

   for nCONT = 1 to 14
      if subs(cCGC,nCONT,1) < '0' .or. subs(cCGC,nCONT,1) > '9'
         return .F.
      endif
   next

   // INICIO DO CALCULO _____________________________________________________

   nTOT += val(subs(cCGC, 1,1)) * 5
   nTOT += val(subs(cCGC, 2,1)) * 4
   nTOT += val(subs(cCGC, 3,1)) * 3
   nTOT += val(subs(cCGC, 4,1)) * 2
   nTOT += val(subs(cCGC, 5,1)) * 9
   nTOT += val(subs(cCGC, 6,1)) * 8
   nTOT += val(subs(cCGC, 7,1)) * 7
   nTOT += val(subs(cCGC, 8,1)) * 6
   nTOT += val(subs(cCGC, 9,1)) * 5
   nTOT += val(subs(cCGC,10,1)) * 4
   nTOT += val(subs(cCGC,11,1)) * 3
   nTOT += val(subs(cCGC,12,1)) * 2

   nREST   := mod(nTOT,11)
   nRESULT := 11 - nREST

   if nRESULT > 9
      nRESULT := 0
   endif

   if nRESULT = val(subs(cCGC,13,1))

      nTOT    := 0
      nREST   := 0
      nRESULT := 0

      nTOT += val(substr(cCGC, 1,1)) * 6
      nTOT += val(substr(cCGC, 2,1)) * 5
      nTOT += val(substr(cCGC, 3,1)) * 4
      nTOT += val(substr(cCGC, 4,1)) * 3
      nTOT += val(substr(cCGC, 5,1)) * 2
      nTOT += val(substr(cCGC, 6,1)) * 9
      nTOT += val(substr(cCGC, 7,1)) * 8
      nTOT += val(substr(cCGC, 8,1)) * 7
      nTOT += val(substr(cCGC, 9,1)) * 6
      nTOT += val(substr(cCGC,10,1)) * 5
      nTOT += val(substr(cCGC,11,1)) * 4
      nTOT += val(substr(cCGC,12,1)) * 3
      nTOT += val(substr(cCGC,13,1)) * 2

      nREST   := mod(nTOT,11)
      nRESULT := 11 - nREST

      if nRESULT > 9
         nRESULT := 0
      endif

      if nRESULT <> val(subs(cCGC,14,1))
         return .F.
      endif

   else

      return .F.

   endif

return .T.

/////////////////////////////////////////////////////////////////////////////
// CHECA PIS ________________________________________________________________

function qcheckpis ( cPIS )

   local nCONT := nTOT := nREST := nRESULT := 0

   // RETIRA PONTUACAO ______________________________________________________

   cPIS := strtran(cPIS,"-","")
   cPIS := strtran(cPIS,"/","")
   cPIS := strtran(cPIS,".","")
   cPIS := alltrim(cPIS)

   if len(cPIS) <> 11 ; return .F. ; endif

   // VERIFICA SE E TOTALMENTE NUMERICO _____________________________________

   for nCONT = 1 to 11
      if subs(cPIS,nCONT,1) < '0' .or. subs(cPIS,nCONT,1) > '9'
         return .F.
      endif
   next

   // INICIO DO CALCULO _____________________________________________________

   nTOT += val(subs(cPIS, 1,1)) * 3
   nTOT += val(subs(cPIS, 2,1)) * 2
   nTOT += val(subs(cPIS, 3,1)) * 9
   nTOT += val(subs(cPIS, 4,1)) * 8
   nTOT += val(subs(cPIS, 5,1)) * 7
   nTOT += val(subs(cPIS, 6,1)) * 6
   nTOT += val(subs(cPIS, 7,1)) * 5
   nTOT += val(subs(cPIS, 8,1)) * 4
   nTOT += val(subs(cPIS, 9,1)) * 3
   nTOT += val(subs(cPIS,10,1)) * 2

   nREST   := mod(nTOT,11)
   nRESULT := 11 - nREST

   if nREST == 0
      nRESULT := 0
   endif

   if str(nRESULT,1) <> right(cPIS,1)

      return .F.

   endif

return .T.

