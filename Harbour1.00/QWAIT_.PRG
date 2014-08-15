
function qwait
   local nCURSOR := setcursor(1)
   local sBLOC := qsbloc(24,11,24,79)
   //if XMOUSEOK
   //   qmensa("Qualquer tecla ou bot„o do mouse para voltar...")
   //else
      qmensa("Qualquer tecla para voltar...")
   //endif
   setpos(24,79)
   //iif ( XMOUSEOK , qmousecu(1) , NIL )
   do while .T.
      if qinkey() <> 0 ; exit ; endif
  //    if XMOUSEOK .and. qmousebo() <> 0 ; exit ; endif
   enddo
   //iif ( XMOUSEOK , qmousecu(0) , NIL )
   qrbloc(24,11,sBLOC)
   setcursor(nCURSOR)
return

