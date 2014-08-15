
function qconf ( cMENSAGEM )

   local sMENS, cCHAR , nSETCURSOR := setcursor(1)

   if ! empty(cMENSAGEM)
      sMENS := qsbloc(24,11,24,79)
      qmensa(cMENSAGEM)
   endif

   qsay(24,73," (S/N)")

   //iif ( XMOUSEOK , qmousecu(1) , NIL )

   setpos(24,79)
   tone(1000,1)

   clear typeahead

   do while .T.

      cCHAR := upper(chr(qinkey()))

      do case
         case cCHAR $ "S+"
              cCHAR := .T.
              exit
         case cCHAR $ "N-" .or. ( lastkey() == 23 .and. XFLAG == .F. )
              cCHAR := .F.
              exit
      endcase

      //if XMOUSEOK .and. qmouseli() == 24 .and. ;
      //                  qmouseco() > 74  .and. ;
      //                  qmouseco() < 78  .and. ;
      //                  qmousebo() == 1
      //   do while .T.
      //      if qmousebo() == 0 ; exit ; endif
      //   enddo
      //   do case
       //     case qmouseco() == 75 ; cCHAR := .T. ; exit
       //     case qmouseco() == 77 ; cCHAR := .F. ; exit
       //  endcase
      //endif

   enddo

   //iif ( XMOUSEOK , qmousecu(0) , NIL )

   setcursor(nSETCURSOR)

   if ! empty(cMENSAGEM)
      qrbloc(24,11,sMENS)
   endif

return cCHAR


