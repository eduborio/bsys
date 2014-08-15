function ef901
if quse(XDRV_EF,"CONFIG") .and. CONFIG->Trib_sinc <> "1"

   if quse(XDRV_EF,"TRIB")

      index on ANOMES+CODIGO    to (XDRV_EF+"TRIB_COD")
      index on ANOMES+DESCRICAO to (XDRV_EF+"TRIB_DES")

      TRIB->(dbclosearea())

   endif

   CONFIG->(dbclosearea())

endif

q901()
return
