/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE CONTROLE DE ESTOQUE
// OBJETIVO...: PROPAGACAO DE SALDOS
// ANALISTA...: IN SUNG CHANG
// PROGRAMADOR: IN SUNG CHANG
// INICIO.....: AGOSTO DE 1997
// OBS........:
// ALTERACOES.:

// INICIALIZACOES ___________________________________________________________
function es410

#include "inkey.ch"

local nREC
local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG .or. lastkey()==27)}

private nSALDO
private cFILIAL          // define produto final para impressao
private cCOD_PROD
private aEDICAO := {}    // vetor para os campos de entrada de dados

aadd(aEDICAO,{{ || view_filial(-1,0,@cFILIAL)   } , "FILIAL"  })
aadd(aEDICAO,{{ || NIL },NIL})           // descricao da filial
aadd(aEDICAO,{{ || view_prod(-1,0,@cCOD_PROD)   } , "COD_PROD"})
aadd(aEDICAO,{{ || NIL },NIL})           // descricao do produto

do while .T.

   qlbloc(05,0,"B410A","QBLOC.GLO",1)

   XNIVEL    := 1
   XFLAG     := .T.
   cCOD_PROD := space(5)
   cFILIAL   := space(4)

   // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; dbcloseall() ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ); loop   ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // CONFIRMA PROPAGACAO DE SALDOS ____________________________________________

   if ! qconf("Confirma Propaga‡„o de Saldos ?") ; return ; endif

   // TRAVA OS ARQUIVOS ________________________________________________________

   qmensa("Zerando os saldos de estoque. Aguarde...")

   nREC := INVENT->(lastrec())

   if empty(cFILIAL) .and. empty(cCOD_PROD)
      do while ! INVENT->(eof())

         qsay(24,70,nREC--)

         if INVENT->(qrlock())
            replace INVENT->Quant_atu with 0
         else
            qmensa("N„o foi possivel completar o processo, tente novamente...","B")
            return
         endif

         INVENT->(dbskip())

      enddo
   else
      if INVENT->(dbseek(cFILIAL+cCOD_PROD))
         do while ! INVENT->(eof()) .and. INVENT->Filial == cFILIAL .and. INVENT->Cod_prod == cCOD_PROD

            qsay(24,70,nREC--)

            if INVENT->(qrlock())
               replace INVENT->Quant_atu with 0
            else
               qmensa("N„o foi possivel completar o processo, tente novamente...","B")
               return
            endif

            INVENT->(dbskip())

         enddo
      endif
   endif

   i_atualiza_saldo()

   qmensa("")

enddo

/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA _____________________________________________

static function i_critica ( cCAMPO )

   do case
      case cCAMPO == "FILIAL"

           if ! empty(cFILIAL)
              if ! FILIAL->(dbseek(cFILIAL:=strzero(val(cFILIAL),4)))
                 qmensa("Filial n„o encontrado !","B")
                 return .F.
              endif
              qrsay(XNIVEL+1,left(FILIAL->Razao,23))
           else
              qrsay(XNIVEL+1,"*** Todas as Filiais ***")
           endif


      case cCAMPO == "COD_PROD"
           PROD->(dbsetorder(4))
           if empty(cCOD_PROD)
              qrsay(XNIVEL+1,"*** Todos os Produtos ***")
           else
              cCOD_PROD:=strzero(val(cCOD_PROD),5)
              if ! PROD->(dbseek(cCOD_PROD))
                 qmensa("Produto n„o encontrado !","B")
                 return .F.
              endif
              qrsay(XNIVEL+1,left(PROD->(Descricao),23))
           endif

   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// ATUALIZA SALDO DE UM DETERMINADO MES _____________________________________

static function i_atualiza_saldo

   dbunlockall()

   qmensa("Atualizando os saldos. Aguarde...")

   nSALDO := 0

   INVENT->(dbgotop())

   if ! empty(cFILIAL) .and. ! empty(cCOD_PROD)
      INVENT->(dbseek(cFILIAL+cCOD_PROD))
   endif

   do while ! INVENT->(eof())

      if ! empty(cFILIAL) .and. ! empty(cCOD_PROD)
         if INVENT->Filial <> cFILIAL .or. INVENT->Cod_prod <> cCOD_PROD
            exit
         endif
      endif

      qmensa("Filial: " + INVENT->Filial + " Produto: " + INVENT->Cod_prod)

      qgirabarra()

      ////////////////////////////////////////
      // REQUISIC.DBF E ITENS_RQ.DBF ________

      REQUISIC->(dbsetorder(3))
      REQUISIC->(dbgotop())

      if REQUISIC->(dbseek(INVENT->Filial))

         qgirabarra()

         do while ! REQUISIC->(eof()) .and. REQUISIC->Filial == INVENT->Filial

            qmensa("Filial: " + INVENT->Filial + " Produto: " + INVENT->Cod_prod + " Requisi‡„o: " + REQUISIC->Codigo)

            qgirabarra()

            ITENS_RQ->(Dbsetorder(2))
            ITENS_RQ->(Dbgotop())
            ITENS_RQ->(Dbseek(REQUISIC->Codigo))

            do while ! ITENS_RQ->(eof()) .and. ITENS_RQ->Cod_req == REQUISIC->Codigo
               if ITENS_RQ->Cod_produt == INVENT->Cod_prod
                  nSALDO := nSALDO - ITENS_RQ->Quantidade
               endif
               ITENS_RQ->(dbskip())
            enddo

            REQUISIC->(dbskip())

         enddo

      endif

      ////////////////////////////////////////
      // OFICINA.DBF E ITENS_OF.DBF ________

      OFICINA->(dbsetorder(3))
      OFICINA->(dbgotop())

      if OFICINA->(dbseek(INVENT->Filial))

         qgirabarra()

         do while ! OFICINA->(eof()) .and. OFICINA->Filial == INVENT->Filial

            qmensa("Filial: " + INVENT->Filial + " Produto: " + INVENT->Cod_prod + " Oficina: " + OFICINA->Codigo)

            qgirabarra()

            ITENS_OF->(Dbsetorder(2))
            ITENS_OF->(Dbgotop())
            ITENS_OF->(Dbseek(OFICINA->Codigo))

            do while ! ITENS_OF->(eof()) .and. ITENS_OF->Cod_oficin == OFICINA->Codigo
               if ITENS_OF->Cod_produt == INVENT->Cod_prod
                  nSALDO := nSALDO - ITENS_OF->Quantidade
               endif
               ITENS_OF->(dbskip())
            enddo

            OFICINA->(dbskip())

         enddo

      endif

      ////////////////////////////////////////
      // PEDIDO.DBF E LANC.DBF _______________

      PEDIDO->(Dbsetorder(4))
      PEDIDO->(Dbgotop())

      if PEDIDO->(dbseek(INVENT->Filial))

         do while ! PEDIDO->(eof()) .and. alltrim(PEDIDO->Filial) == INVENT->Filial

            qmensa("Filial: " + INVENT->Filial + " Produto: " + INVENT->Cod_prod + " Pedido: " + PEDIDO->Codigo)

            LANC->(Dbsetorder(1))
            LANC->(Dbgotop())

            if LANC->(dbseek(PEDIDO->Codigo))
               do while ! LANC->(eof()) .and. PEDIDO->Codigo == LANC->Cod_ped

                  qgirabarra()

                  if LANC->Cod_prod == INVENT->Cod_prod .and. PEDIDO->Estoque == "S"
                     nSALDO := nSALDO + (LANC->Quant * LANC->Fator)
                  endif

                  LANC->(dbskip())

               enddo
            endif

            PEDIDO->(dbskip())

         enddo

      endif

      ////////////////////////////////////////
      // PEDIDO2.DBF E LANC2.DBF _______________

      PEDIDO2->(Dbsetorder(4))
      PEDIDO2->(Dbgotop())

      if PEDIDO2->(dbseek(INVENT->Filial))

         do while ! PEDIDO2->(eof()) .and. alltrim(PEDIDO2->Filial) == INVENT->Filial

            qmensa("Filial: " + INVENT->Filial + " Produto: " + INVENT->Cod_prod + " Pedido: " + PEDIDO2->Codigo)

            LANC2->(Dbsetorder(1))
            LANC2->(Dbgotop())

            if LANC2->(dbseek(PEDIDO2->Codigo))
               do while ! LANC2->(eof()) .and. PEDIDO2->Codigo == LANC2->Cod_ped

                  qgirabarra()

                  if LANC2->Cod_prod == INVENT->Cod_prod .and. PEDIDO2->Estoque == "S"
                     nSALDO := nSALDO + (LANC2->Quant * LANC2->Fator)
                  endif

                  LANC2->(dbskip())

               enddo
            endif

            PEDIDO2->(dbskip())

         enddo

      endif

      ////////////////////////////////////////
      // MOVIMENT.DBF ________________________

      MOVIMENT->(Dbsetorder(5))
      MOVIMENT->(Dbgotop())

      if MOVIMENT->(Dbseek(INVENT->Filial+INVENT->Cod_prod))


         do while ! MOVIMENT->(eof()) .and. MOVIMENT->Filial == INVENT->Filial .and. MOVIMENT->Cod_prod == INVENT->Cod_prod

            qmensa("Filial: " + INVENT->Filial + " Produto: " + INVENT->Cod_prod + " Dt. Mov.: " + dtoc(MOVIMENT->Data) + " E/S: " + MOVIMENT->Tipo)

            qgirabarra()

            if MOVIMENT->Tipo == "E" .and. ! MOVIMENT->Contabil
               nSALDO := nSALDO + MOVIMENT->Quantidade
            endif

            if MOVIMENT->Tipo $ "SB" .and. ! MOVIMENT->Contabil
               nSALDO := nSALDO - MOVIMENT->Quantidade
            endif

            MOVIMENT->(dbskip())

         enddo

      endif

      ////////////////////////////////////////
      // REL_COMB.DBF E ITENS_RC.DBF _________

      REL_COMB->(Dbsetorder(2))
      REL_COMB->(Dbgotop())

      if REL_COMB->(Dbseek(INVENT->Filial+INVENT->Cod_prod))


         do while ! REL_COMB->(eof()) .and. REL_COMB->Filial == INVENT->Filial .and. REL_COMB->Cod_prod == INVENT->Cod_prod

            qmensa("Filial: " + INVENT->Filial + " Produto: " + INVENT->Cod_prod + " Rel. Comb.: " + REL_COMB->Codigo)

            qgirabarra()

            ITENS_RC->(dbgotop())

            if ITENS_RC->(dbseek(REL_COMB->Codigo))
               do while ! ITENS_RC->(eof()) .and. ITENS_RC->Cod_relcom == REL_COMB->Codigo
                  nSALDO := nSALDO - ITENS_RC->Quantidade
                  ITENS_RC->(dbskip())
               enddo
            endif

            REL_COMB->(dbskip())

         enddo

      endif

      ////////////////////////////////////////
      // NFTRANF.DBF E ITENS_NF.DBF __________

      NFTRANSF->(Dbsetorder(2))
      NFTRANSF->(Dbgotop())

      if NFTRANSF->(dbseek(INVENT->Filial))

         do while ! NFTRANSF->(eof()) .and. NFTRANSF->Filial == INVENT->Filial

            qmensa("Filial: " + INVENT->Filial + " Produto: " + INVENT->Cod_prod + " Nf. Transf.: " + NFTRANSF->Codigo)

            ITENS_NF->(Dbsetorder(1))
            ITENS_NF->(Dbgotop())

            if ITENS_NF->(dbseek(NFTRANSF->Codigo))
               do while ! ITENS_NF->(eof()) .and. NFTRANSF->Codigo == ITENS_NF->Num_nf

                  qgirabarra()

                  if ITENS_NF->Cod_produt == INVENT->Cod_prod
                     nSALDO := nSALDO - ITENS_NF->Quantidade
                  endif

                  ITENS_NF->(dbskip())

               enddo
            endif

            NFTRANSF->(dbskip())

         enddo

      endif

      FAT->(Dbsetorder(3))
      FAT->(Dbgotop())

      if FAT->(dbseek(INVENT->Filial))

         do while ! FAT->(eof()) .and. alltrim(FAT->Filial) == INVENT->Filial

            qmensa("Filial: " + INVENT->Filial + " Produto: " + INVENT->Cod_prod + " Venda: " + FAT->Codigo)

            ITEN_FAT->(Dbsetorder(2))
            ITEN_FAT->(Dbgotop())

            if ITEN_FAT->(dbseek(FAT->Codigo))
               do while ! ITEN_FAT->(eof()) .and. FAT->Codigo == ITEN_FAT->Num_fat

                  qgirabarra()

                  if ITEN_FAT->Cod_prod == INVENT->Cod_prod
                     nSALDO := nSALDO - ITEN_FAT->Quantidade
                  endif

                  ITEN_FAT->(dbskip())

               enddo
            endif

            FAT->(dbskip())

         enddo

      endif

      do while ! VISTA->(eof())

         qmensa("Filial: " + INVENT->Filial + " Produto: " + INVENT->Cod_prod + " Venda: " + VISTA->Codigo)

         ITEM_VIS->(Dbsetorder(2))
         ITEM_VIS->(Dbgotop())

         if ITEM_VIS->(dbseek(VISTA->Codigo))
            do while ! ITEM_VIS->(eof()) .and. VISTA->Codigo == ITEM_VIS->Num_vist
               qgirabarra()

               if ITEM_VIS->Cod_prod == INVENT->Cod_prod
                  nSALDO := nSALDO - ITEM_VIS->Quantidade
               endif

               ITEM_VIS->(dbskip())

            enddo
         endif

         VISTA->(dbskip())

      enddo


      if INVENT->(qrlock())
         replace INVENT->Quant_atu with INVENT->Quantidade + nSALDO
      else
         qmensa("N„o foi possivel completar o processo, tente novamente...","B")
         return
      endif

      nSALDO := 0

      INVENT->(dbskip())

   enddo

   dbunlockall()

return

