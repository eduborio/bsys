////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO COMERCIO
// OBJETIVO...: RAZAO POR PRODUTO
// ANALISTA...: EDUARDO AUGUSTO BORIO
// PROGRAMADOR: EDUARDO AUGUSTO BORIO
// INICIO.....: JUNHO DE 2005
// OBS........:
// ALTERACOES.:
function es415

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

return
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
	  
      if left(FAT->Cod_cfop,4) $ "5905-6905-1906-2906-5906-6906-1905-2905"
         FAT->(DbSkip())
         loop
      endif

      ITEN_FAT->(Dbseek(FAT->Codigo))
      do while ITEN_FAT->Num_fat == FAT->Codigo .and. ! ITEN_FAT->(eof())
	  
	     // if ITEN_FAT->Marcado != "*" .and. FAT->es != "S" .and. empty(FAT->Num_fatura)
		 //    alert("Aviso!!!! " + ITEN_FAT->Num_fat)
		 // endif
	  
          if ESTMP->(qappend())
             replace ESTMP->Fat_cod    with FAT->Codigo
             replace ESTMP->Data       with FAT->Dt_emissao
             replace ESTMP->Produto    with ITEN_FAT->Cod_prod
             replace ESTMP->Nota       with FAT->Num_fatura
             replace ESTMP->Cfop       with alltrim(FAT->Cod_cfop)
             replace ESTMP->Quantidade with ITEN_FAT->Quantidade
             replace ESTMP->Es         with FAT->Es

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

                case ESTMP->Es == "T"
                     replace ESTOQUE->Saldo_ant   with nSALDO_COR
                     replace ESTOQUE->Saida       with ESTMP->Quantidade
                     replace ESTOQUE->Saldo_atu   with (nSALDO_COR - ESTMP->Quantidade)
                     nSALDO_COR := nSALDO_COR - ESTMP->Quantidade
					 
				case ESTMP->Es == "V"
                     replace ESTOQUE->Saldo_ant   with nSALDO_COR
                     replace ESTOQUE->Saida       with ESTMP->Quantidade
                     replace ESTOQUE->Saldo_atu   with (nSALDO_COR - ESTMP->Quantidade)
                     nSALDO_COR := nSALDO_COR - ESTMP->Quantidade
					 nSALDO_AVA := nSALDO_AVA + ESTMP->Quantidade

                case ESTMP->Es == "H"
                     replace ESTOQUE->Saldo_ant   with nSALDO_COR
                     replace ESTOQUE->Saida       with ESTMP->Quantidade
                     replace ESTOQUE->Saldo_atu   with (nSALDO_COR - ESTMP->Quantidade)
                     nSALDO_COR := nSALDO_COR - ESTMP->Quantidade
                     nSALDO_SHOW:= nSALDO_SHOW + ESTMP->Quantidade					 

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
            endif

		 endif
       endif

       ESTMP->(dbskip())

       if ESTMP->Produto != cPROD
	   
          INVENT->(Dbsetorder(4))
          if INVENT->(dbseek(cPROD))
             if INVENT->(Qrlock())
                replace INVENT->Quant_atu  with nSALDO_COR
                replace INVENT->Quant_ter  with 0
                replace INVENT->Quant_res  with 0
                replace INVENT->Quant_defe with nSaldo_ava
                replace INVENT->Quant_show with nSaldo_show
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
return   

   
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


