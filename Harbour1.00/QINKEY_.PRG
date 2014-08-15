
function qinkey( nSecs )
   
   local nKEY        // INKEY() value to return
   local bKEYBLOCK   // Code block retrieved and performed for nKey, if any

   iif ( nSecs == NIL , nSecs := 0.01 , NIL )

   nKEY := inkey( nSecs )

   if ( bKEYBLOCK := setkey( nKEY ) ) != NIL
      eval( bKEYBLOCK, procname( 2 ), procline( 2 ) )
   endif

return nKEY

