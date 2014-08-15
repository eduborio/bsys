
function q_msg_acesso_usr
   local cMENSA := "ESC/ALT-P/ALT-O/"
   iif ( "I" $ XUSRA , cMENSA += "<I>nc/" , NIL )
   iif ( "A" $ XUSRA , cMENSA += "<A>lt/" , NIL )
   iif ( "C" $ XUSRA , cMENSA += "<C>on/" , NIL )
   iif ( "E" $ XUSRA , cMENSA += "<E>xc"  , NIL )
return cMENSA

function q_back_field
   XFLAG := .F.
   keyboard chr(23)  // CTRL-W
return

