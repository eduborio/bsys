/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE COMPRAS
// OBJETIVO...: LIMPEZA DE PEDIDOS DO ARQUIVO MORTO
// ANALISTA...:
// PROGRAMADOR: LUCINEIDE VILAR POSSEBOM
// INICIO.....: MAIO DE 1997
// OBS........:
// ALTERACOES.:

function cp402

private dDATA, cSENHA := fu_decodifica_senha(CONFIG->Senhalib)

do while .T.

   qmensa("<Pressione ESC para Cancelar>")

   dDATA := ctod("")

   XNIVEL := 1

   qgetx(-1,0,@dDATA)

   if empty(dDATA) ; exit ; endif

   qmensa("Digite a senha para liberacao...")

   if fu_check_senha_lib(cSENHA)

      PEDIDO2->(Dbsetorder(6)) // data_ped
      PEDIDO2->(Dbgotop())

      qmensa("<Pressione ESC para Cancelar>")

      do while ! PEDIDO2->(eof())

         qgirabarra()

         if PEDIDO2->Data_ped <= dDATA

            qmensa ( "Aguarde... Limpando Pedido " + PEDIDO2->Codigo )

            PARCELA2->(Dbsetorder(1))

            if PARCELA2->(Dbseek(PEDIDO2->Codigo))

               do while ! PARCELA2->(eof()) .and. PARCELA2->Cod_ped == PEDIDO2->Codigo

                  if PARCELA2->(qrlock())

                     PARCELA2->(dbdelete())

                     PARCELA2->(qunlock())

                  else
                     qmensa("N„o foi possivel realizar a limpeza...","B")
                  endif

                  PARCELA2->(Dbskip())

               enddo

            endif

            LANC2->(Dbsetorder(1))

            if LANC2->(Dbseek(PEDIDO2->Codigo))

               do while ! LANC2->(eof()) .and. LANC2->Cod_ped == PEDIDO2->Codigo

                  if LANC2->(qrlock())

                     LANC2->(dbdelete())

                     LANC2->(qunlock())

                  else
                     qmensa("N„o foi possivel realizar a limpeza...","B")
                  endif

                  LANC2->(Dbskip())

               enddo

            endif

            if PEDIDO2->(qrlock())

               PEDIDO2->(dbdelete())

               PEDIDO2->(qunlock())

            else
               qmensa("N„o foi possivel realizar a limpeza...","B")
            endif

         endif

         PEDIDO2->(dbskip())

      enddo

      qmensa("")

   endif

enddo

return
