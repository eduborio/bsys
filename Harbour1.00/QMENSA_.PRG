
function qmensa ( cSTRING , cCONTROL )
   local sBLOC := qsbloc(24,11,24,79)

   iif ( empty(cCONTROL) , cCONTROL := "" , nil )

   iif ( empty(cSTRING) , cSTRING := "" , nil )

   cSTRING := pad(cSTRING,69)

   qsay(24,0,"Mensagens: "+cSTRING,NIL,XCOR_MENSA)

   iif ( "B" $ cCONTROL , qbeep() , nil )
   iif ( "T" $ cCONTROL .or. "B" $ cCONTROL , inkey(2.5) , nil )
   iif ( "R" $ cCONTROL , qrbloc(24,11,sBLOC) , NIL )
   iif ( "L" $ cCONTROL , qmensa("") , nil )

return

// SIGNIFICADOS DE "cCONTROL"

// B - BEEP
// T - TEMPO DE ESPERA
// L - LIMPA A MENSAGEM
// R - RESTAURA A MENSAGEM ANTERIOR

