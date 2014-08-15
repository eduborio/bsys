
#include "inkey.ch"

function qachoice ( nLIN, nCOL , sBLOC , cSTART , nSHADOW )
   local nQUANTL, nQUANTC, nCONTL, nCONTC, cCHAR, nCONT
   local nLINI := nLINF := nCOLI := nCOLF := 0
   local nLINX, nKEY, cOPCOES := ""

   setpos(25,00)
   clear typeahead

   qrbloc(nLIN,nCOL,sBLOC,nSHADOW)

   // CALCULA QUANTIDADE DE LINHAS E COLUNAS ________________________________

   nQUANTL := val(left(sBLOC,2))
   nQUANTC := val(subs(sBLOC,3,3)) + 1

   // CALCULA INICIO DA BARRA DE ESCOLHA ____________________________________

   for nCONTL := nLIN to nLIN+nQUANTL-1
       for nCONTC := nCOL to nCOL+nQUANTC-1
           cCHAR := chrsc_sl(nCONTL,nCONTC,"S")
           if isdigit(cCHAR) .or. isalpha(cCHAR)
              nLINI := nLINX := nCONTL
              exit
           endif
       next
       if nLINI <> 0 ; exit ; endif
   next

   // CALCULA FINAL DA BARRA DE ESCOLHA _____________________________________

   for nCONTL := nLIN+nQUANTL-1 to nLIN step -1
       for nCONTC := nCOL+nQUANTC-1 to nCOL step -1
           cCHAR := chrsc_sl(nCONTL,nCONTC,"S")
           if isdigit(cCHAR) .or. isalpha(cCHAR)
              nLINF := nCONTL
              exit
           endif
       next
       if nLINF <> 0 ; exit ; endif
   next

   nCOLI := nCOL+1
   nCOLF := nCOL+nQUANTC-2

   for nCONT := nLINI to nLINF
       cOPCOES += chrsc_sl(nCONT,nCOLI+1,"S")
   next

   if cSTART <> NIL
      nCONT := at(cSTART,cOPCOES)
      if ! empty(cSTART) .and. nCONT <> 0
         nLINX := nLINI + nCONT - 1
      endif
   endif

   do while .T.
      qinver(nLINX,nCOLI,nCOLF-nCOLI+1)
      //iif ( XMOUSEOK , qmousecu(1) , NIL )
      do while (nKEY := qinkey()) == 0
         //if XMOUSEOK .and. qmouseco() >= nCOLI .and. qmouseco() <= nCOLF
          //  if qmouseli() >= nLINI .and. qmouseli() <= nLINF
          //     qmousecu(0)
               qinver(nLINX,nCOLI,nCOLF-nCOLI+1)
          //     nLINX := qmouseli()
               qinver(nLINX,nCOLI,nCOLF-nCOLI+1)
         //      qmousecu(1)
         //      if qmousebo() == 1
         //         do while .T.
         //            if qmousebo() == 0 ; exit ; endif
         //         enddo
         //         nKEY := K_ENTER
         //         exit
         //      endif
         //   endif
         //endif
         //if XMOUSEOK .and. qmousebo() == 2
         //   do while .T.
         //      if qmousebo() == 0 ; exit ; endif
         //   enddo
         //   //keyboard chr(K_ESC)
         //   keyboard chr(K_CTRL_W)
         //endif
      enddo
      //iif ( XMOUSEOK , qmousecu(0) , NIL )

      //if nKEY == K_ESC ; return "" ; endif
      if nKEY == K_CTRL_W .or. nKEY == K_ESC ; return "" ; endif

      qinver(nLINX,nCOLI,nCOLF-nCOLI+1)
      do case
         case nKEY == K_DOWN .or. nKEY == K_RIGHT
              nLINX++
              iif(nLINX>nLINF,nLINX:=nLINI,NIL)
         case nKEY == K_UP   .or. nKEY == K_LEFT
              nLINX--
              iif(nLINX<nLINI,nLINX:=nLINF,NIL)
         case nKEY == K_ENTER
              qinver(nLINX,nCOLI,nCOLF-nCOLI+1)
              exit
         case upper(chr(nKEY)) $ cOPCOES
              nCONT := at(upper(chr(nKEY)),cOPCOES)
              nLINX := nLINI + nCONT - 1
      endcase
   enddo

return chrsc_sl(nLINX,nCOLI+1,"S")

