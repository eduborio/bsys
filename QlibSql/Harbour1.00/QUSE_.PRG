
function quse ( cPATH , cFILE , aNTX , cMODE , cALIAS,cVIA,cSQL)

   //#include "qrdd.ch"
	
   local nCONT
   local RDD := "DBFCDX"
   //local cSQL := ""
   //local RDD := rdd_name(1)

   if cVIA == "QRDD"

      if cFILE != NIL
         cFILE := alltrim(cFILE)
      endif

      if cSQL == NIL .or. empty(cSQL)
         cSQL := "select * from "+cFILE
      endif

      if cAlias != nil
         cALIAS := alltrim(cALIAS)
      endif

   else
   
       //i_prot_adic()

       cPATH := alltrim(cPATH)
       cFILE := alltrim(cFILE)

       iif ( empty(cMODE) , cMODE := "" , NIL )


       iif ( empty(cALIAS) , cALIAS := cFILE , NIL )

       iif ( aNTX == NIL , aNTX := {} , NIL )

       if ( nCONT := at(".",cALIAS)) <> 0
          cALIAS := left(cALIAS,nCONT-1)
       endif

       if ( nCONT := rat("\",cALIAS)) <> 0
          cALIAS := subs(cALIAS,nCONT+1)
       endif

       cALIAS := alltrim(cALIAS)

       if ! file(cPATH+cFILE+".DBF")
          qmensa("arquivo "+cFILE+" n„o encontrado...","LB")
          return .F.
       endif

       select 0

       do case
          case "E" $ cMODE
               use (cPATH+cFILE) alias (cALIAS) exclusive
          case "R" $ cMODE
               use (cPATH+cFILE) alias (cALIAS) readonly

          otherwise
               use (cPATH+cFILE) alias (cALIAS)
       endcase

       if neterr()
          qmensa("n„o foi possivel abrir "+cFILE+"...","LB")
          return .F.
       endif


       do case
          case RDD == "SIXNTX"

               for nCONT := 1 to len(aNTX)
                  if file ( cPATH + aNTX[nCONT]+".NTX" )
                     set index to ( cPATH + aNTX[nCONT] ) additive
                  else
                     qmensa("indice "+aNTX[nCONT]+" n„o encontrado...","LB")
                  endif
               next


          case RDD == "SDF"
               for nCONT := 1 to len(aNTX)
                  if file ( cPATH + aNTX[nCONT]+".NTX" )
                     set index to ( cPATH + aNTX[nCONT] ) additive
                  else
                     qmensa("indice "+aNTX[nCONT]+" n„o encontrado...","LB")
                  endif
               next

               case RDD == "DBFNTX"
               for nCONT := 1 to len(aNTX)
                  if file ( cPATH + aNTX[nCONT]+".NTX" )
                     set index to ( cPATH + aNTX[nCONT] ) additive
                  else
                     qmensa("indice "+aNTX[nCONT]+" n„o encontrado...","LB")
                  endif
               next


           case RDD == "SIXCDX"

              if file (cPATH + cFILE +".CDX")
                 set index to (cPATH+cFILE)
              endif

          case RDD == "DBFCDX"

             cFILE := rtrim(cFILE)
             if file (cPATH + cFILE +".CDX")
                set index to (cPATH+cFILE)
             endif


          case RDD == "SIXNSX"

             if file (cPATH + cFILE +".NSX")
                set index to (cPATH+cFILE)
                (cFILE)->(dbsetorder(1))
             endif

      endcase
   endif



return .T.

