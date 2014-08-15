/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE COMPRAS
// OBJETIVO...: TRANSFERENCIA P/ ARQUIVO MORTO
// ANALISTA...:
// PROGRAMADOR: LUCINEIDE VILAR POSSEBOM
// INICIO.....: MAIO DE 1997
// OBS........:
// ALTERACOES.:

function cp401

private dDATA, cSENHA := fu_decodifica_senha(CONFIG->Senhalib)

do while .T.

   qmensa("<Pressione ESC para Cancelar>")

   dDATA := ctod("")

   XNIVEL := 1

   qgetx(-1,0,@dDATA)

   if empty(dDATA) ; exit ; endif

   qmensa("Digite a senha para liberacao...")

   if fu_check_senha_lib(cSENHA)

      PEDIDO->(Dbsetorder(6)) // data_ped
      PEDIDO->(Dbgotop())

      qmensa("")

      do while ! PEDIDO->(eof())

         qgirabarra()

         if PEDIDO->Data_ped <= dDATA .and. PEDIDO->Interface

            qmensa ( "Aguarde... Transferindo Pedido " + PEDIDO->Codigo )

            PARCELA->(Dbsetorder(1))

            if PARCELA->(Dbseek(PEDIDO2->Codigo))

               do while ! PARCELA->(eof()) .and. PARCELA->Cod_ped == PEDIDO2->Codigo

                  PARCELA->(qpublicfields())

                  if PARCELA2->(qappend()) .and. PARCELA2->(qrlock()) .and. PARCELA->(qrlock())

                     PARCELA->(qcopyfields())
                     PARCELA2->(qreplacefields())
                     PARCELA->(dbdelete())

                     PARCELA->(qunlock())
                     PARCELA2->(qunlock())

                  else
                     qmensa("N„o foi possivel realizar a transferencia...","B")
                  endif

                  PARCELA->(Dbskip())

               enddo

            endif

            LANC->(Dbsetorder(1))

            if LANC->(Dbseek(PEDIDO2->Codigo))

               do while ! LANC->(eof()) .and. LANC->Cod_ped == PEDIDO2->Codigo

                  LANC->(qpublicfields())

                  if LANC2->(qappend()) .and. LANC2->(qrlock()) .and. LANC->(qrlock())

                     LANC->(qcopyfields())
                     LANC2->(qreplacefields())
                     LANC->(dbdelete())

                     LANC->(qunlock())
                     LANC2->(qunlock())

                  else
                     qmensa("N„o foi possivel realizar a transferencia...","B")
                  endif

                  LANC->(Dbskip())

               enddo

            endif

            PEDIDO->(qpublicfields())

            if PEDIDO2->(qappend()) .and. PEDIDO2->(qrlock()) .and. PEDIDO->(qrlock())

               PEDIDO->(qcopyfields())
               PEDIDO2->(qreplacefields())
               PEDIDO->(dbdelete())

               PEDIDO2->(qunlock())
               PEDIDO->(qunlock())

            else
               qmensa("N„o foi possivel realizar a transferencia...","B")
            endif

         endif

         PEDIDO->(dbskip())

      enddo

      qmensa("")

   endif

enddo

return
