////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO COMERCIO
// OBJETIVO...: RAZAO POR PRODUTO
// ANALISTA...: EDUARDO AUGUSTO BORIO
// PROGRAMADOR: EDUARDO AUGUSTO BORIO
// INICIO.....: JUNHO DE 2005
// OBS........:
// ALTERACOES.:
function es416

#define K_MAX_LIN 57

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG) .or. empty(dINI) }

faz_index()

if ! quse(XDRV_ES,"ESTOQUE",{"ESTOQUE"},"E")
   qmensa("N„o foi poss¡vel criar arquivo temporario !! Tente novamente.")
   return
endif

if ! quse(XDRV_ES,"ESTMP",{"ESTMP"},"E")
   qmensa("N„o foi poss¡vel criar arquivo temporario !! Tente novamente.")
   return
endif



   if qconf("Confirma Propaga‡Æo dos Saldos de Estoque ?")
      i_impressao()
      ESTMP->(Dbclosearea())
      ESTOQUE->(dbclosearea())
	  erase_index()
   endif


/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impressao
    local nTOTAL     := 0
    local nSALDO_COR := 0
    local nSALDO_TER := 0
    local nSALDO_AVA := 0
    local nSALDO_RES := 0
    local nSALDO_RT  := 0
    local nSALDO_SHOW := 0

    local nCUSTO_COR := 0

    ESTOQUE->(__dbzap())
    ESTMP->(__dbzap())

    // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

    qmensa("Aguarde... Processando ...")
   ITEN_FAT->(dbsetorder(ITEN_FAT->(OrdCount())))
   FAT->(dbsetorder(FAT->(OrdCount())))
   FAT->(dbgotop())	
   do while ! FAT->(eof())

      if FAT->Cancelado
         FAT->(dbskip())
         loop
      endif

      ITEN_FAT->(Dbseek(FAT->Codigo))
      do while ITEN_FAT->Num_fat == FAT->Codigo .and. ! ITEN_FAT->(eof())

          if empty(FAT->Num_fatura) .and. FAT->Es == "S"
             if ITEN_FAT->Marcado != "*"
                ITEn_FAT->(dbskip())
                loop
             endif


              if ITEN_FAT->Terceiros > 0
                 PROD->(dbsetorder(4))
                 PROD->(dbseek(ITEN_FAT->Cod_prod))

                 Qmensa("Aviso! Produto.: "+Prod->Cod_fabr+" "+left(PROD->Marca,15)+" Aguardando pecas de Terceiros!","B")
                 qinkey(2)
              endif

          endif

          if ESTMP->(qappend())
             replace ESTMP->Fat_cod    with FAT->Codigo
             replace ESTMP->Data       with FAT->Dt_emissao
             replace ESTMP->Produto    with ITEN_FAT->Cod_prod
             replace ESTMP->Nota       with FAT->Num_fatura
             replace ESTMP->Cfop       with alltrim(FAT->Cod_cfop)
             replace ESTMP->Quantidade with ITEN_FAT->Quantidade

             if empty(FAT->Num_fatura) .and. FAT->Es == "S"
                if left(FAT->Cod_cfop,4) $ "1906-2906-5905-6905"
                   replace ESTMP->Es         with FAT->Es
                else
                   replace ESTMP->Es         with "R"
                endif
             else
                replace ESTMP->Es         with FAT->Es
             endif

             replace ESTMP->Cod_fc     with FAT->Cod_cli
          endif

          ITEN_FAT->(Dbskip())
      enddo
      FAT->(dbskip())
   enddo
//   ESTMP->(DbCommit())



   MOVIMENT->(dbsetorder(MOVIMENT->(OrdCount()))) // data de emissao
   MOVIMENT->(dbgotop())

   do while ! MOVIMENT->(eof())

      if MOVIMENT->Contabil
         MOVIMENT->(dbSkip())
         Loop
      endif

      if MOVIMENT->Tipo == "E"
         cDESCRICAO := "ENTRA"
      else
         cDESCRICAO := "SAIDA"
      endif

      if ESTMP->(qappend())
         replace ESTMP->Data       with MOVIMENT->Data
         replace ESTMP->Produto    with MOVIMENT->Cod_prod
         replace ESTMP->Nota       with ""
         replace ESTMP->Cfop       with left(cDESCRICAO,4)
         replace ESTMP->Quantidade with MOVIMENT->Quantidade
         if MOVIMENT->Tipo == "B"
            replace ESTMP->Es         with "T"
         else
            replace ESTMP->Es         with MOVIMENT->Tipo
         endif
         replace ESTMP->Cod_fc     with cDESCRICAO
      endif

      MOVIMENT->(dbskip())

   enddo

//   ESTMP->(dbcommit())

   AVARIADO->(dbsetorder(AVARIADO->(OrdCount()))) // data de emissao
   AVARIADO->(dbgotop())

   do while ! AVARIADO->(eof())

      if ESTMP->(qappend())
         replace ESTMP->Data       with AVARIADO->Data
         replace ESTMP->Produto    with AVARIADO->Cod_prod
         replace ESTMP->Nota       with ""
         replace ESTMP->Cfop       with "AVAR"
         replace ESTMP->Quantidade with AVARIADO->Quantidade
         replace ESTMP->Es         with "V"
      endif

      AVARIADO->(dbskip())

   enddo

   SHOWROOM->(dbsetorder(SHOWROOM->(OrdCount()))) // data de emissao
   SHOWROOM->(dbgotop())

   do while ! SHOWROOM->(eof())

      if ESTMP->(qappend())
         replace ESTMP->Data       with SHOWROOM->Data
         replace ESTMP->Produto    with SHOWROOM->Cod_prod
         replace ESTMP->Nota       with ""
         replace ESTMP->Cfop       with "ROOM"
         replace ESTMP->Quantidade with SHOWROOM->Quantidade
         replace ESTMP->Es         with "H"
      endif

      SHOWROOM->(dbskip())

   enddo

//   ESTMP->(dbcommit())

   LANC->(dbsetorder(LANC->(OrdCount()))) // data de emissao
   PEDIDO->(dbsetorder(PEDIDO->(OrdCount()))) // data de emissao
   PEDIDO->(dbgotop())
   do while ! PEDIDO->(eof()) 

         if ! PEDIDO->Interface
            PEDIDO->(Dbskip())
            loop
         endif

         LANC->(Dbseek(PEDIDO->Codigo))
         do while LANC->Cod_ped == PEDIDO->Codigo .and. ! LANC->(eof())

            if ESTMP->(qappend())
               replace ESTMP->Data        with PEDIDO->Data_ped
               replace ESTMP->Produto     with LANC->Cod_prod
               replace ESTMP->Nota        with PEDIDO->Numero_nf
               replace ESTMP->Cfop        with PEDIDO->Cfop
               replace ESTMP->Quantidade  with LANC->Quant
               replace ESTMP->Preco_cust  with LANC->Preco
               replace ESTMP->Es          with "C"
               replace ESTMP->Cod_fc      with PEDIDO->Cod_forn
            endif

            LANC->(Dbskip())
         enddo
         PEDIDO->(dbskip())
   enddo
   ESTMP->(Dbcommit())

   ESTMP->(Dbgotop())
   ESTMP->(Dbsetorder(1))

   cPROD := ESTMP->Produto
   nSALDO_COR := 0
   nCUSTO_COR := 0
   nSALDO_TER := 0
   nSALDO_AVA := 0
   nSALDO_RES := 0
   nSALDO_RT  := 0
   nSALDO_SHOW := 0

   do while ! ESTMP->(eof())

       if ESTMP->Es $ "S*R*T*V*H"  // Se for Saida soma as quantidades senao diminui

          if ESTOQUE->(qappend())
             replace ESTOQUE->Cod_prod    with ESTMP->Produto
             replace ESTOQUE->Data        with ESTMP->Data
             replace ESTOQUE->Fat_cod     with ESTMP->Fat_cod
             replace ESTOQUE->Cfop        with ESTMP->Cfop
             replace ESTOQUE->Num_nf      with ESTMP->Nota
             replace ESTOQUE->Cod_fc      with ESTMP->Cod_fc

             do case
                case ESTMP->Es == "S"
                     replace ESTOQUE->Saldo_ant   with nSALDO_COR
                     replace ESTOQUE->Saida       with ESTMP->Quantidade
                     replace ESTOQUE->Saldo_atu   with (nSALDO_COR - ESTMP->Quantidade)
                     nSALDO_COR := nSALDO_COR - ESTMP->Quantidade

                     replace ESTOQUE->Ter_ant     with nSALDO_TER

                     if ESTMP->Cfop $ "5905-6905"
                        replace ESTOQUE->Ent_ter  with ESTMP->Quantidade
                        replace ESTOQUE->Ter_atu  with (nSALDO_TER + ESTMP->Quantidade)
                        nSALDO_TER := nSALDO_TER + ESTMP->Quantidade
                     else
                        replace ESTOQUE->Ter_atu  with nSALDO_TER
                     endif

                     replace ESTOQUE->Ava_ant     with nSALDO_AVA
                     replace ESTOQUE->Ava_atu     with nSALDO_AVA

                     replace ESTOQUE->Res_ant    with nSALDO_RES
                     replace ESTOQUE->RT_ant     with nSALDO_RT

                     replace ESTOQUE->Res_atu    with nSALDO_RES
                     replace ESTOQUE->RT_atu     with nSALDO_RT

                     //OK

                case ESTMP->Es == "T"
                     replace ESTOQUE->Saldo_ant   with nSALDO_COR
                     replace ESTOQUE->Saida       with ESTMP->Quantidade
                     replace ESTOQUE->Saldo_atu   with (nSALDO_COR - ESTMP->Quantidade)
                     nSALDO_COR := nSALDO_COR - ESTMP->Quantidade

                     replace ESTOQUE->Ter_ant     with nSALDO_TER
                     replace ESTOQUE->Ter_atu     with nSALDO_TER

                     replace ESTOQUE->Ava_ant     with nSALDO_AVA
                     replace ESTOQUE->Ava_atu     with nSALDO_AVA

                     replace ESTOQUE->Res_ant    with nSALDO_RES
                     replace ESTOQUE->RT_ant     with nSALDO_RT

                     replace ESTOQUE->Res_atu    with nSALDO_RES
                     replace ESTOQUE->RT_atu     with nSALDO_RT

                     //OK

                case ESTMP->Es == "V"
                     replace ESTOQUE->Saldo_ant   with nSALDO_COR
                     replace ESTOQUE->Saida       with ESTMP->Quantidade
                     replace ESTOQUE->Saldo_atu   with (nSALDO_COR - ESTMP->Quantidade)
                     nSALDO_COR := nSALDO_COR - ESTMP->Quantidade

                     replace ESTOQUE->Ava_ant with nSALDO_AVA
                     replace ESTOQUE->Ava_ent with ESTMP->Quantidade
                     replace ESTOQUE->Ava_atu with (nSALDO_AVA + ESTMP->Quantidade)
                     nSALDO_AVA := nSALDO_AVA + ESTMP->Quantidade

                     replace ESTOQUE->Ter_ant    with nSALDO_TER
                     replace ESTOQUE->Ter_atu    with nSALDO_TER

                     replace ESTOQUE->Res_ant    with nSALDO_RES
                     replace ESTOQUE->RT_ant     with nSALDO_RT

                     replace ESTOQUE->Res_atu    with nSALDO_RES
                     replace ESTOQUE->RT_atu     with nSALDO_RT

                case ESTMP->Es == "H" //ShowRoom
                     replace ESTOQUE->Saldo_ant   with nSALDO_COR
                     replace ESTOQUE->Saida       with ESTMP->Quantidade
                     replace ESTOQUE->Saldo_atu   with (nSALDO_COR - ESTMP->Quantidade)
                     nSALDO_COR := nSALDO_COR - ESTMP->Quantidade

                     replace ESTOQUE->show_ant with nSALDO_show
                     replace ESTOQUE->show_ent with ESTMP->Quantidade
                     replace ESTOQUE->show_atu with (nSALDO_show + ESTMP->Quantidade)
                     nSALDO_show := nSALDO_show + ESTMP->Quantidade

                     replace ESTOQUE->Ter_ant    with nSALDO_TER
                     replace ESTOQUE->Ter_atu    with nSALDO_TER

                     replace ESTOQUE->Res_ant    with nSALDO_RES
                     replace ESTOQUE->RT_ant     with nSALDO_RT

                     replace ESTOQUE->Res_atu    with nSALDO_RES
                     replace ESTOQUE->RT_atu     with nSALDO_RT


                     //OK

                case ESTMP->Es == "R"

                     replace ESTOQUE->Saldo_ant  with nSALDO_COR

                     replace ESTOQUE->Ter_ant    with nSALDO_TER
                     replace ESTOQUE->Ter_atu     with nSALDO_TER

                     replace ESTOQUE->Ava_ant    with nSALDO_AVA
                     replace ESTOQUE->Ava_atu    with nSALDO_AVA

                     replace ESTOQUE->Res_ant    with nSALDO_RES

                     replace ESTOQUE->RT_ant     with nSALDO_RT

                     if ESTMP->Quantidade <= nSALDO_COR
                        replace ESTOQUE->Saida   with ESTMP->Quantidade
                        replace ESTOQUE->Res_ent with ESTMP->Quantidade
                        nSALDO_COR := nSALDO_COR - ESTMP->Quantidade
                        nSALDO_RES := nSALDO_RES + ESTMP->Quantidade

                        replace ESTOQUE->Res_atu   with nSALDO_RES
                        replace ESTOQUE->Saldo_atu with nSALDO_COR
                        replace ESTOQUE->RT_atu    with nSALDO_RT
                        //OK
                     else
                        if ESTMP->Quantidade <= (nSALDO_COR+(nSALDO_TER-nSALDO_RT))
                           replace ESTOQUE->Saida     with nSALDO_COR
                           replace ESTOQUE->Res_ent   with nSALDO_COR
                           replace ESTOQUE->Saldo_atu with 0
                           replace ESTOQUE->RT_ent    with (ESTMP->Quantidade - nSALDO_COR)

                           ITEN_FAT->(dbsetorder(1))
                           if ITEN_FAT->(dbseek(ESTMP->Fat_cod+ESTMP->produto))

                              if ITEN_FAT->(qrlock())
                                 replace ITEN_FAT->Local     with nSALDO_COR
                                 replace ITEN_FAT->Terceiros with (ESTMP->quantidade - nSALDO_COR)
                                 ITEN_FAT->(qunlock())
                               endif

                           endif

                           nSALDO_RT  := nSALDO_RT  + (ESTMP->Quantidade  - nSALDO_COR)
                           nSALDO_RES := nSALDO_RES + nSALDO_COR
                           nSALDO_COR := 0
                           replace ESTOQUE->RT_atu     with nSALDO_RT
                           replace ESTOQUE->Res_atu    with nSALDO_RES

                        endif
                     endif

             endcase

          endif

       else
          if ESTMP->ES $ "E-C"
          if ESTOQUE->(qappend())
             replace ESTOQUE->Cod_prod    with ESTMP->Produto
             replace ESTOQUE->Data        with ESTMP->Data
             replace ESTOQUE->Cfop        with ESTMP->Cfop
             replace ESTOQUE->Num_nf      with ESTMP->Nota
             replace ESTOQUE->Saldo_ant   with nSALDO_COR
             replace ESTOQUE->Entrada     with ESTMP->Quantidade
             replace ESTOQUE->Saldo_atu   with (nSALDO_COR + ESTMP->Quantidade)
             replace ESTOQUE->Cod_fc      with ESTMP->Cod_fc


             nSALDO_COR := nSALDO_COR + ESTMP->Quantidade

             replace ESTOQUE->Ter_ant     with nSALDO_TER

             if ESTMP->Cfop $ "1906-2906"
                replace ESTOQUE->Sai_ter  with ESTMP->Quantidade
                replace ESTOQUE->Ter_atu  with (nSALDO_TER - ESTMP->Quantidade)
                nSALDO_TER := nSALDO_TER - ESTMP->Quantidade
             else
                replace ESTOQUE->Ter_atu  with nSALDO_TER
             endif
          endif

       endif
       endif

       //if ESTMP->Produto == "01136"
       //   qmensa("Nota.: "+estmp->nota+"  Cfop.: "+estmp->cfop+"   saldo.: "+transf(nsaldo_cor,"@R 9999999"))
       //   qinkey(0)
       //endif

       ESTMP->(dbskip())

       if ESTMP->Produto != cPROD

          INVENT->(Dbsetorder(4))
          if INVENT->(dbseek(cPROD))
             if INVENT->(Qrlock())
                replace INVENT->Quant_atu  with nSALDO_COR
                replace INVENT->Quant_ter  with nSALDO_TER
                replace INVENT->Quant_res  with nSALDO_RT
                replace INVENT->Quant_defe with nSALDO_AVA
                replace INVENT->Quant_show with nSALDO_SHOW
                INVENT->(qunlock())
              endif
          endif

          cPROD := ESTMP->Produto


          nSALDO_COR := 0
          nSALDO_TER := 0
          nSALDO_AVA := 0
          nSALDO_SHOW:= 0
          nSALDO_RES := 0
          nSALDO_RT  := 0

       endif

   enddo

   //ESTOQUE->(dbcommit())

   
static function faz_index
   local cTime := ""

   if ! quse(XDRV_CL,"FAT")
      qmensa("N„o foi poss¡vel abrir FAT.DBF !! Tente novamente.")
      return
   endif

   if ! quse(XDRV_CL,"ITEN_FAT")
      qmensa("N„o foi poss¡vel abrir FAT.DBF !! Tente novamente.")
      return
   endif

   if ! quse(XDRV_CP,"PEDIDO")
      qmensa("N„o foi poss¡vel abrir FAT.DBF !! Tente novamente.")
      return
   endif

   if ! quse(XDRV_CP,"LANC")
      qmensa("N„o foi poss¡vel abrir FAT.DBF !! Tente novamente.")
      return
   endif

   if ! quse(XDRV_ES,"MOVIMENT")
      qmensa("N„o foi poss¡vel abrir FAT.DBF !! Tente novamente.")
      return
   endif
   
   if ! quse(XDRV_ES,"AVARIADO")
      qmensa("N„o foi poss¡vel abrir AVARIADO.DBF !! Tente novamente.")
      return
   endif
   
   if ! quse(XDRV_ES,"SHOWROOM")
      qmensa("N„o foi poss¡vel abrir SHOWROOM.DBF !! Tente novamente.")
      return
   endif

   
   cTIME := time()
   
   select FAT

   index on CODIGO tag ID TO (XDRV_ES + "ES415A.TMP")
   dbsetindex(XDRV_ES + "ES415A.TMP")


   select ITEN_FAT
    
   index on NUM_FAT  tag ID    TO (XDRV_ES + "ES415B.TMP")
   dbsetindex(XDRV_ES + "ES415B.TMP")

   select PEDIDO

   index on CODIGO tag ID TO (XDRV_ES + "ES415C.TMP")
   dbsetindex(XDRV_ES + "ES415C.TMP")

   select MOVIMENT
   index on data tag ID TO (XDRV_ES + "ES415E.TMP")
   dbsetindex(XDRV_ES + "ES415E.TMP")
   
   select AVARIADO

   index on data    tag ID TO (XDRV_ES + "ES415F.TMP")
   dbsetindex(XDRV_ES + "ES415F.TMP")
   
   select SHOWROOM

   index on data    tag ID TO (XDRV_ES + "ES415G.TMP")
   dbsetindex(XDRV_ES + "ES415G.TMP")
   
   select LANC

   index on COD_PED tag ID TO (XDRV_ES + "ES415D.TMP")
   dbsetindex(XDRV_ES + "ES415D.TMP")
   

   if neterr()
      qmensa("Erro ao indexar arquivos temporarios!","BL")
      return .F.
   endif


return

static function erase_index

   erase(XDRV_ES+"ES415A.TMP")
   erase(XDRV_ES+"ES415B.TMP")
   erase(XDRV_ES+"ES415C.TMP")
   erase(XDRV_ES+"ES415D.TMP")
   erase(XDRV_ES+"ES415E.TMP")
   erase(XDRV_ES+"ES415F.TMP")
   erase(XDRV_ES+"ES415G.TMP")

   if neterr()
      qmensa("Erro ao deletar arquivos temporarios!","BL")
      return .F.
   endif

return


