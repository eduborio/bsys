
// FUNCAO PARA ABRIR OS ARQUIVOS AUTOMATICAMENTE DE ACORDO COM O CAMPO
// ARQUIVOS NO QPROGS, LEMBRANDO QUE OS ARQUIVOS QPROGS E QINDEX JA
// ESTAO ABERTOS E POSICIONADO PELA FUNCAO QCALL()

function qopen


   local nCONT
   local RDD := "DBFCDX"

   private cMACRO

   if i_chk_idxing()
      alert("Sistema em reindexacao. Por favor aguarde...")
      return .F.
   endif


   if empty(QPROGS->Arquivos) ; return .T. ; endif

   do while ! QINDEX->(eof())
      if alltrim(QINDEX->Arquivo) $ QPROGS->Arquivos
         qmensa("Abrindo arquivos...     ("+alltrim(QINDEX->Arquivo)+")")

         if left(QINDEX->Via,4) == "QRDD"
            if ! quse("",alltrim(QINDEX->Arquivo),,,,"QRDD")
               return .F.
            endif
            RDD:= "QRDD"

         else
            if ! quse(&(QINDEX->Caminho),alltrim(QINDEX->Arquivo))
               return .F.
            endif
         endif


         do case
            case  RDD == "SDF"
                  for nCONT := 1 to 15
                      cMACRO := "NTX_" + strzero(nCONT,2)
                      if "U" $ type("QINDEX->&cMACRO") .or. empty(QINDEX->(&cMACRO))
                         exit
                      endif
                      dbsetindex(&(QINDEX->Caminho)+QINDEX->(&cMACRO))
                  next
                  
            case  RDD == "DBFNTX"
                  for nCONT := 1 to 15
                      cMACRO := "NTX_" + strzero(nCONT,2)
                      if "U" $ type("QINDEX->&cMACRO") .or. empty(QINDEX->(&cMACRO))
                         exit
                      endif
                      dbsetindex(&(QINDEX->Caminho)+QINDEX->(&cMACRO))
                  next

            case  RDD == "SIXNTX"
                  for nCONT := 1 to 15
                      cMACRO := "NTX_" + strzero(nCONT,2)
                      if "U" $ type("QINDEX->&cMACRO") .or. empty(QINDEX->(&cMACRO))
                         exit
                      endif
                      dbsetindex(&(QINDEX->Caminho)+QINDEX->(&cMACRO))
                  next

            case RDD == "DBFCDX"
                 if(empty(QINDEX->Key_01))
                    QINDEX->(dbskip())
                    loop
                 endif

                 if empty(QINDEX->Via)
                    dbsetindex((&(QINDEX->Caminho)+alltrim(QINDEX->Arquivo)))
                 else
                    dbsetindex( (&alltrim(QINDEX->Arquivo)) )
                 endif

            case RDD == "SIXCDX"
                 if(empty(QINDEX->Key_01))
                    QINDEX->(dbskip())
                    loop
                 endif

                 dbsetindex((&(QINDEX->Caminho)+alltrim(QINDEX->Arquivo)))



            case RDD == "SIXNSX"
                 if(empty(QINDEX->Key_01))
                    QINDEX->(dbskip())
                    loop
                 endif
                 dbsetindex((&(QINDEX->Caminho)+alltrim(QINDEX->Arquivo)))


         endcase
      endif
      QINDEX->(dbskip())
   enddo

   qmensa("")

return .T.

