/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO SERVICO
// OBJETIVO...: INTERFACE P/ CONTAS A RECEBER E FISCAL E CONTABILIDADE
// ANALISTA...: EDUARDO AUGUSTO BORIO
// PROGRAMADOR: EDUARDO AUGUSTO BORIO
// INICIO.....:
// OBS........:
// ALTERACOES.:

function cl601
#define K_MAX_LIN 52

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := { || ( XNIVEL==1 .and. !XFLAG ) .or. ( XNIVEL==1 .and. lastkey()==27 ) }

private dINI          // periodo inicial
private dFIM          // periodo final
private nVAL          := 0
private nCONTADOR     := 0
private nIPI_VLR      := 0
private nIPI_OUT      := 0
private nIPI_BASE     := 0
private nICMS_VLR     := 0
private nICMS_OUT     := 0
private nICMS_BASE    := 0
private nICMS_RED     := 0
private nISS_VLR      := 0
private zBXEST    := 0
private cFORN      := space(5)


private nALIQ     := 0
private aEDICAO := {} // vetor para os campos de entrada de dados
private lCONF

qmensa("<Pressione ESC para Cancelar>")

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qgetx(-1,0,@dINI)}          , "INI"    })
aadd(aEDICAO,{{ || qgetx(-1,0,@dFIM)}          , "FIM"    })
aadd(aEDICAO,{{ || lCONF := qconf("Confirma interface com o Contas a Receber ?") },NIL})

qlbloc(5,0,"B601A","QBLOC.GLO")
XNIVEL := 1
XFLAG  := .T.
dINI   := ctod("")
dFIM   := ctod("")

// SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
   eval ( aEDICAO [XNIVEL,1] )
   if eval ( bESCAPE ) ; dbcloseall() ; return ; endif
   if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
   iif ( XFLAG , XNIVEL++ , XNIVEL-- )
enddo

if ! lCONF ; return ; endif

i_interface()

return

/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA _____________________________________________

static function i_critica ( cCAMPO )
   do case
      case cCAMPO == "INI"
           if empty(dINI) ; return .F. ; endif
      case cCAMPO == "FIM"
           if dFIM < dINI ; return .F. ; endif
   endcase
return .T.

/////////////////////////////////////////////////////////////////////////////
// LOOP DE INTERFACE ________________________________________________________

static function i_interface

   local nCONT, cTMP, cCGM_ISS, nTOT_SER

   nTOT_SER := 0

   FAT->(dbsetorder(2)) // dtos(dt_emissao)

   FAT->(dbseek(dtos(dINI),.T.))

   // LOOP PRINCIPAL NAS FATURAS A INTERFACEAR ______________________________

   do while FAT->Dt_emissao >= dINI .and. FAT->Dt_emissao <= dFIM

      qgirabarra()

      if FAT->Interface  .or. empty(FAT->Num_fatura)
         FAT->(Dbskip())
         loop
      endif

      if FAT->Es $ "E- "
         FAT->(Dbskip())
         loop
      endif

      if CONFIG->Modelo_fat == "1"
         if left(FAT->Cod_cfop,4) $ "5151-5152-5153-5154-2152-2151-2153-2154-5408-6408-5908-6908"
            FAT->(Dbskip())
            loop
         endif
      else
         if left(FAT->Cod_cfop,4) $ "5151-5152-5153-5154-2152-2151-2153-2154-5917-6917-5915-6915-6910-5910-5911-6911-5912-6912-5408-6408-5908-6908"
            FAT->(Dbskip())
            loop
         endif

      endif


      qmensa("Aguarde... Intefaceando com Contas a Receber...")

      if ! FAT->Cancelado

         fu_abre_farec()

         if CONFIG->Modelo_fat == "1"

            i_calc_val()

         else

            nVAL := calc_clari()

         endif
		 
		 nST := FAT->St
		 
		 
		 if nST > 0 .and. left(FAT->cod_cfop,1) $ "5-6-7"
		 
	        CLI1->(dbseek(FAT->cod_cli))
			CGM->(dbseek(CLI1->cgm_ent))
			
			if ! left(FAT->cod_cfop,4) $ "5910-6910" .and. CGM->Estado != "MG"		
				if SH_FAREC->(qappend())
					replace SH_FAREC->Data_lanc   with  FAT->Dt_emissao
					replace SH_FAREC->Cod_cli     with  FAT->Cod_cli
					replace SH_FAREC->CCusto      with  FAT->C_custo
					replace SH_FAREC->Filial      with  FAT->Filial
					replace SH_FAREC->Data_emiss  with  FAT->Dt_emissao
					replace SH_FAREC->Especie     with  "01"
					replace SH_FAREC->Serie       with  "01"
					replace SH_FAREC->Tipo_cont   with  FAT->Tiposub
					replace SH_FAREC->Historico   with  "SUBSTITUICAO TRIBUTARIA"
					replace SH_FAREC->Data_venc   with  FAT->Dt_emissao + 15

					replace SH_FAREC->Valor       with  FAT->St

					replace SH_FAREC->Fatura      with  FAT->Num_fatura+"/ST"
					replace SH_FAREC->Num_titulo  with  FAT->Num_fatura+"/ST"
					replace SH_FAREC->Cliente     with  FAT->Cliente
					replace SH_FAREC->Tipo_doc    with  FAT->Tipo_doc
				endif	
             endif
		endif	   


         DUP_FAT->(dbsetorder(1))
         DUP_FAT->(dbgotop())
         if DUP_FAT->(dbseek(FAT->Codigo+"01"))
            do while  ! DUP_FAT->(eof()) .and. left(DUP_FAT->Num_fat,5) == FAT->Codigo
               if SH_FAREC->(qappend())
                  replace SH_FAREC->Data_lanc   with  FAT->Dt_emissao
                  replace SH_FAREC->Cod_cli     with  FAT->Cod_cli
                  replace SH_FAREC->CCusto      with  FAT->C_custo
                  replace SH_FAREC->Filial      with  FAT->Filial
                  replace SH_FAREC->Data_emiss  with  FAT->Dt_emissao
                  replace SH_FAREC->Especie     with  "01"
                  replace SH_FAREC->Serie       with  "01"
                  replace SH_FAREC->Tipo_cont   with  FAT->Tiposub
                  replace SH_FAREC->Historico   with  FAT->Obs
                  replace SH_FAREC->Data_venc   with  DataVenc()

                  if CONFIG->Modelo_2 == "7"
                     if FAT->Vezes > 1
                        replace SH_FAREC->Valor       with  nVAL / FAT->Vezes
                     else
                        replace SH_FAREC->Valor       with  nVAL
                     endif
                  else
                     replace SH_FAREC->Valor       with  DUP_FAT->Valor
                  endif

                  replace SH_FAREC->Fatura      with  FAT->Num_fatura+"/"+right(DUP_FAT->Num_fat,2)
                  replace SH_FAREC->Num_titulo  with  FAT->Num_fatura+"/"+right(DUP_FAT->Num_fat,2)
                  replace SH_FAREC->Cliente     with  FAT->Cliente
                  replace SH_FAREC->Tipo_doc    with  FAT->Tipo_doc
               endif
               DUP_FAT->(dbskip())
            enddo
         else
            if CONFIG->Modelo_fat != "1"
               if SH_FAREC->(qappend())
                  replace SH_FAREC->Data_lanc   with  FAT->Dt_emissao
                  replace SH_FAREC->Cod_cli     with  FAT->Cod_cli
                  replace SH_FAREC->CCusto      with  FAT->C_custo
                  replace SH_FAREC->Filial      with  FAT->Filial
                  replace SH_FAREC->Data_emiss  with  FAT->Dt_emissao
                  replace SH_FAREC->Especie     with  "01"
                  replace SH_FAREC->Serie       with  "01"
                  replace SH_FAREC->Tipo_cont   with  FAT->Tiposub
                  replace SH_FAREC->Historico   with  FAT->Obs
                  DUP_FAT->(Dbseek(FAT->Codigo))
                  replace SH_FAREC->Data_venc   with  FAT->Dt_emissao

                  replace SH_FAREC->Valor       with  calc_clari()
                  if FAT->No_nf
                    replace SH_FAREC->Fatura      with  "PED "+FAT->Codigo
                    replace SH_FAREC->Num_titulo  with  "PED "+FAT->Codigo
                  else
                    replace SH_FAREC->Fatura      with  FAT->Num_fatura+"/01"
                    replace SH_FAREC->Num_titulo  with  FAT->Num_fatura+"/01"
                  endif
                  replace SH_FAREC->Cliente     with  FAT->Cliente
                  replace SH_FAREC->Tipo_doc    with  FAT->Tipo_doc
               endif
           endif
         endif
         SH_FAREC->(dbclosearea())

         if FAT->(qrlock())
            replace FAT->Interface with .T.
            FAT->(qunlock())
         endif
      endif

      if FAT->Fiscal .or. empty(FAT->Num_fatura)
         FAT->(Dbskip())
         loop
      endif

      if FAT->Continua
         FAT->(Dbskip())
         loop
      endif


      qmensa("Aguarde... Intefaceando com Escrita Fiscal...")

      if SH_EFFAT->(qappend())

         replace SH_EFFAT->Tipo      with left(FAT->Tiposub,2)
         replace SH_EFFAT->Subtipo   with right(FAT->Tiposub,4)
         replace SH_EFFAT->Serie     with "01"
         replace SH_EFFAT->Especie   with "01"
         replace SH_EFFAT->Nota_fisc with FAT->Num_fatura
         replace SH_EFFAT->Modelo    with FAT->Modelo
         replace SH_EFFAT->NFE       with FAT->NFe

         if FAT->Es != "C"
            replace SH_EFFAT->Valor_liq with round(nVAL,2) + round(FAT->St,2)
         endif

         replace SH_EFFAT->Data_cont with FAT->Dt_emissao
         CLI1->(dbseek(FAT->Cod_cli))
         CGM->(dbseek(CLI1->Cgm_ent))
         replace SH_EFFAT->Cgm        with CGM->Codigo
         replace SH_EFFAT->Filial     with FAT->Filial
         replace SH_EFFAT->Isento     with CLI1->Isento
         replace SH_EFFAT->Data_lanc  with FAT->Dt_emissao
         replace SH_EFFAT->Data_emiss with FAT->Dt_emissao
         replace SH_EFFAT->Estado     with CGM->Estado
         replace SH_EFFAT->Cod_cli    with FAT->Cod_cli
         
		 if CONFIG->Modelo_fat == "5"
            replace SH_EFFAT->Icm_base   with 0
         else
            replace SH_EFFAT->Icm_base   with nICMS_BASE
         endif
         if FAT->Es != "C"
            replace SH_EFFAT->Ipi_base   with nIPI_BASE
         endif
         
		 replace SH_EFFAT->Icm_aliq   with nALIQ
         replace SH_EFFAT->Icm_vlr    with nICMS_VLR
         replace SH_EFFAT->Ipi_vlr    with nIPI_VLR
         replace SH_EFFAT->Icm_red    with nICMS_RED
		 replace SH_EFFAT->Icm_red    with nICMS_RED
		 
		 replace SH_EFFAT->Icm_bc_s   with FAT->BaseSt
		 replace SH_EFFAT->Icm_subst  with FAT->St
         
		 if FAT->Es != "C"
            replace SH_EFFAT->Icm_out    with nICMS_OUT
         endif
         
		 if CONFIG->Modelo_fat == "5"
            replace SH_EFFAT->Icm_out with nICMS_OUT
         endif

         replace SH_EFFAT->Ipi_out    with nIPI_OUT//(nVAL - (nIPI_BASE + nIPI_VLR))
		 
		 if FAT->St > 0
			cCfop := ajustaCfop(left(FAT->Cod_cfop,4))
		 else
            cCfop :=   left(FAT->cod_cfop,4)
         endif 		 
         
		 replace SH_EFFAT->Cfop       with cCfop
		 
		 if FAT->St > 0
			replace SH_EFFAT->Icm_cod  with "1"
		 else
			replace SH_EFFAT->Icm_cod  with "0"
		 endif

         if FAT->Cancelado
            replace SH_EFFAT->Valor_liq with 0
            replace SH_EFFAT->Icm_base with 0
            replace SH_EFFAT->Icm_aliq with 0
            replace SH_EFFAT->Icm_vlr  with 0
            replace SH_EFFAT->Icm_out  with 0
            replace SH_EFFAT->Icm_red  with 0
            replace SH_EFFAT->Ipi_base with 0
            replace SH_EFFAT->Ipi_out  with 0
            replace SH_EFFAT->Ipi_vlr  with 0
			replace SH_EFFAT->Icm_bc_s   with 0
		    replace SH_EFFAT->Icm_subst  with 0
            replace SH_EFFAT->Obs      with "### NOTA FISCAL CANCELADA ###"
         endif



         SH_EFFAT->(qunlock())

      endif

      if FAT->(qrlock())
         replace FAT->Fiscal with .T.
         FAT->(qunlock())
      endif

      FAT->(dbskip())

      nVAL := 0

   enddo

   FAT->(dbsetorder(2)) // dtos(dt_emissao)
   FAT->(Dbgotop())
   FAT->(dbseek(dtos(dINI),.T.))

   fu_abre_prov()

   // LOOP PRINCIPAL NAS FATURAS A INTERFACEAR ______________________________

   do while FAT->Dt_emissao >= dINI .and. FAT->Dt_emissao <= dFIM

      qgirabarra()

      qmensa("Aguarde... Interfaceando Saidas com a Contabilidade...")

      if FAT->Contabil .or. empty(FAT->Num_fatura)
         FAT->(dbskip())
         loop
      endif

      if FAT->Es $ "E- "
         FAT->(Dbskip())
         loop
      endif

      if FAT->Continua
         FAT->(Dbskip())
         loop
      endif

      if FAT->Cancelado
         FAT->(Dbskip())
         loop
      endif

      TIPOCONT->(Dbseek(FAT->Tiposub))

      if SH_PROCT->(qappend())

         replace SH_PROCT->Data_lanc   with  FAT->Dt_emissao

         if TIPOCONT->Regime_ope == "2" // Regime de competencia

            nHISTORICO := TIPOCONT->Hist_l_pr

            if TIPOCONT->Cont_pr_dv == "1"
               replace SH_PROCT->Cont_db with TIPOCONT->Ct_ct_p_dv
            else
               CLI1->(dbseek(FAT->Cod_cli))
               replace SH_PROCT->Cont_db with CLI1->Conta_cont
            endif

            if TIPOCONT->Cont_pr_cr == "1"
               replace SH_PROCT->Cont_cr with TIPOCONT->Ct_ct_p_cr
            else
               CLI1->(dbseek(FAT->Cod_cli))
               replace SH_PROCT->Cont_cr with CLI1->Conta_cont
            endif

         else // regime de caixa

            nHISTORICO := TIPOCONT->Hist_l_pr

            if TIPOCONT->Conta_liq == "1"
               replace SH_PROCT->Cont_db with TIPOCONT->Ct_ct_liq
            else
               CLI1->(dbseek(FAT->Cod_cli))
               replace SH_PROCT->Cont_db with CLI1->Conta_cont
            endif

            if TIPOCONT->Conta_l2 == "1"
               replace SH_PROCT->Cont_cr with TIPOCONT->Ct_ct_l2
            else
               CLI1->(dbseek(FAT->Cod_cli))
               replace SH_PROCT->Cont_cr with CLI1->Conta_cont
            endif

         endif

         replace SH_PROCT->Filial     with  FAT->Filial

         i_calc_val()

         replace SH_PROCT->Valor      with  nVAL
         replace SH_PROCT->Num_doc    with  FAT->Num_fatura
         replace SH_PROCT->Num_lote   with  "CL" + XUSRNUM + strzero(CONFIG->Num_lote,5) // monta numero do lote
         replace SH_PROCT->Cod_hist   with nHISTORICO

         //if CONFIG->Modelo_fat == "1"
            replace SH_PROCT->Cod_fat    with FAT->Codigo
         //endif

         monta_hist("FAT",nHISTORICO)
         if nICMS_VLR <> 0
            for nCONTADOR := 1 to 13  // contabiliza lancamentos complementares das entradas
                bHIST := "TIPOCONT->Hi_comp" + alltrim(str(nCONTADOR))
                if ! empty(&bHIST) .and. &bHIST $ ( CONFIG->His_icms + "*" + CONFIG->His_ipi )
                   complementares(bHIST,alltrim(str(nCONTADOR)),"FAT")
                endif
            next
         endif


      endif
	  
	  CLI1->(dbseek(FAT->Cod_cli))
	  CGM->(dbseek(CLI1->Cgm_ent))

	  if FAT->St > 0 .and. ! left(FAT->cod_cfop,4) $ "5910-6910" .and. CGM->Estado != "MG"
	 
   	     if FAT->Es == "S"// "510-610-540-640"
		 
		    if CGM->Estado == "PR"
			   TIPOCONT->(Dbseek("010124")) // Conta De St Parana
			endif

			if CGM->Estado == "SC"
  			   TIPOCONT->(Dbseek("010127")) // Conta De St SC
			endif			
			
			if CGM->Estado == "RS"
  			   TIPOCONT->(Dbseek("010129")) // Conta De St RS
			endif
			
			if CGM->Estado == "RJ"
  			   TIPOCONT->(Dbseek("010131")) // Conta De St RS
			endif
			
			if CGM->Estado == "DF"
  			   TIPOCONT->(Dbseek("010137")) // Conta De St DF
			endif
			
			if right(alltrim(FAT->cod_cfop),3) $ "910" //Se for Remessa de bonificacao
				
				if CGM->Estado == "PR"
					TIPOCONT->(Dbseek("010126")) // Conta De St Parana
				endif

				if CGM->Estado == "SC"
					TIPOCONT->(Dbseek("010134")) // Conta De St SC
				endif			
			
				if CGM->Estado == "RS"
					TIPOCONT->(Dbseek("010133")) // Conta De St RS
				endif
			
				if CGM->Estado == "RJ"
					TIPOCONT->(Dbseek("010135")) // Conta De St RS
				endif
			
				if CGM->Estado == "DF"
					TIPOCONT->(Dbseek("010136")) // Conta De St DF
				endif
			
			endif
			
			//if ! left(FAT->cod_cfop,3) $ "510-540-610-640"
			//	TIPOCONT->(Dbseek(CONFIG->Tpo_desp))
			//endif

         else
		 
			if CGM->Estado == "PR"
			   TIPOCONT->(Dbseek("010125")) // Conta De St Parana
			endif
			
			if CGM->Estado == "SC"
			   TIPOCONT->(Dbseek("010128")) // Conta De St SC
			endif
			
			if CGM->Estado == "RS"
			   TIPOCONT->(Dbseek("010130")) // Conta De St RS
			endif
			
			if CGM->Estado == "RJ"
			   TIPOCONT->(Dbseek("010132")) // Conta De St Rj
			endif
			
			if CGM->Estado == "DF"
			   TIPOCONT->(Dbseek("010138")) // Conta De St Rj
			endif
            
         endif

         if SH_PROCT->(qappend())

            replace SH_PROCT->Data_lanc   with  FAT->Dt_emissao

            if TIPOCONT->Cont_pr_dv == "1"
               replace SH_PROCT->Cont_db with TIPOCONT->Ct_ct_p_dv
            else
               CLI1->(dbseek(FAT->Cod_cli))
               replace SH_PROCT->Cont_db with CLI1->Conta_cont
            endif

            if TIPOCONT->Cont_pr_cr == "1"
               replace SH_PROCT->Cont_cr with TIPOCONT->Ct_ct_p_cr
            else
               CLI1->(dbseek(FAT->Cod_cli))
               replace SH_PROCT->Cont_cr with CLI1->Conta_cont
            endif

            replace SH_PROCT->Filial     with  FAT->Filial

            replace SH_PROCT->Valor      with  FAT->St
            replace SH_PROCT->Num_doc    with  FAT->Num_fatura
            replace SH_PROCT->Num_lote   with  "CL" + XUSRNUM + "SUBST" // monta numero do lote
            replace SH_PROCT->Cod_hist   with ""

            replace SH_PROCT->Cod_fat    with FAT->Codigo

            replace SH_PROCT->Historico  with "VR SUBST. TRIB. NF "+FAT->Num_fatura+" "+ left(FAT->cliente,35)

         endif
	  endif	 

      if FAT->(qrlock())
         replace FAT->Contabil with .T.
         FAT->(qunlock())
      endif

      FAT->(dbskip())

   enddo

   if CONFIG->(qrlock())
      replace CONFIG->Num_lote with ( CONFIG->Num_lote + 1 )
      CONFIG->(qunlock())
   endif

   i_devol()
   i_notas()
   i_frete()
   //i_baixa_rb()
return

static function ajustaCfop(cCfop)
local cfop := cCfop
   
   if cfop == "2202"
      return "2411"
   endif 	
	
   if cfop == "1202"
      return "1411"
   endif	  
	  
   if cfop == "5102"
      return "5403"
   endif	  

   if cfop == "6102"
      return "6403"
   endif 	  

return cfop



static function i_Devol

   local nCONT, cTMP, cCGM_ISS, nTOT_SER

   nTOT_SER := 0

   FAT->(dbsetorder(2)) // dtos(dt_emissao)
   FAT->(Dbgotop())

   FAT->(dbseek(dtos(dINI),.T.))

   // LOOP PRINCIPAL NAS FATURAS A INTERFACEAR ______________________________

   do while ! FAT->(eof()) .and. FAT->Dt_emissao >= dINI .and. FAT->Dt_emissao <= dFIM

      qgirabarra()

      if FAT->Fiscal
         FAT->(Dbskip())
         loop
      endif

      if FAT->Es $ "S-C- "
         FAT->(Dbskip())
         loop
      endif

      if SH_FICOM->(qappend())

         replace SH_FICOM->Serie     with "01"
         replace SH_FICOM->Especie   with "01"
         replace SH_FICOM->Num_nf    with FAT->Num_fatura
         i_calc_val()
         replace SH_FICOM->Vlr_cont  with nVAL
         CLI1->(dbseek(FAT->Cod_cli))
         CGM->(dbseek(CLI1->Cgm_ent))
         replace SH_FICOM->Filial     with FAT->Filial
         replace SH_FICOM->Data_lanc  with FAT->Dt_emissao
         replace SH_FICOM->Data_emis  with FAT->Dt_emissao
         i_cria_forn()
         replace SH_FICOM->Cod_forn   with cFORN
         replace SH_FICOM->Icm_base   with nICMS_BASE
         replace SH_FICOM->Ipi_base   with nIPI_BASE
         replace SH_FICOM->Icm_aliq   with nALIQ
         replace SH_FICOM->Icm_vlr    with nICMS_VLR
         replace SH_FICOM->Ipi_vlr    with nIPI_VLR
         replace SH_FICOM->Icm_out    with (nVAL-nICMS_BASE)
         replace SH_FICOM->Ipi_out    with (nVAL-(nIPI_BASE+nIPI_VLR))
		 replace SH_FICOM->Icm_bc_s   with FAT->BaseSt
		 replace SH_FICOM->Icm_subst  with FAT->St
         replace SH_FICOM->Cfop       with FAT->Cod_cfop
         SH_FICOM->(qunlock())

      endif

      if FAT->(qrlock())
         replace FAT->Fiscal with .T.
         FAT->(qunlock())
      endif

      FAT->(dbskip())

      nVAL := 0

   enddo

   FAT->(dbsetorder(2)) // dtos(dt_emissao)
   FAT->(Dbgotop())
   FAT->(dbseek(dtos(dINI),.T.))

   //fu_abre_prov()

   // LOOP PRINCIPAL NAS FATURAS A INTERFACEAR ______________________________

   do while FAT->Dt_emissao >= dINI .and. FAT->Dt_emissao <= dFIM

      qgirabarra()

      qmensa("Aguarde... Interfaceando Entradas com a Contabilidade...")

      if FAT->Contabil //.or. empty(FAT->Num_fatura)
         FAT->(dbskip())
         loop
      endif

      if FAT->Es $ "S-C"
         FAT->(Dbskip())
         loop
      endif


      TIPOCONT->(Dbseek(FAT->Tiposub))

      if SH_PROCT->(qappend())

         replace SH_PROCT->Data_lanc   with  FAT->Dt_emissao

         if TIPOCONT->Regime_ope == "2" // Regime de competencia

            nHISTORICO := TIPOCONT->Hist_l_pr

            if TIPOCONT->Cont_pr_dv == "1"
               replace SH_PROCT->Cont_db with TIPOCONT->Ct_ct_p_dv
            else
               CLI1->(dbseek(FAT->Cod_cli))
               replace SH_PROCT->Cont_db with CLI1->Conta_cont
            endif

            if TIPOCONT->Cont_pr_cr == "1"
               replace SH_PROCT->Cont_cr with TIPOCONT->Ct_ct_p_cr
            else
               CLI1->(dbseek(FAT->Cod_cli))
               replace SH_PROCT->Cont_cr with CLI1->Conta_cont
            endif

         else // regime de caixa

            nHISTORICO := TIPOCONT->Hist_l_pr

            if TIPOCONT->Conta_liq == "1"
               replace SH_PROCT->Cont_db with TIPOCONT->Ct_ct_liq
            else
               CLI1->(dbseek(FAT->Cod_cli))
               replace SH_PROCT->Cont_db with CLI1->Conta_cont
            endif

            if TIPOCONT->Conta_l2 == "1"
               replace SH_PROCT->Cont_cr with TIPOCONT->Ct_ct_l2
            else
               CLI1->(dbseek(FAT->Cod_cli))
               replace SH_PROCT->Cont_cr with CLI1->Conta_cont
            endif

         endif

         replace SH_PROCT->Filial     with  FAT->Filial

         i_calc_val()

         replace SH_PROCT->Valor      with  nVAL
         replace SH_PROCT->Num_doc    with  FAT->Num_fatura
         replace SH_PROCT->Num_lote   with  "CL" + XUSRNUM + strzero(CONFIG->Num_lote,5) // monta numero do lote
         replace SH_PROCT->Cod_hist   with nHISTORICO

         monta_hist("FAT",nHISTORICO)
         if nICMS_VLR <> 0
         for nCONTADOR := 1 to 13  // contabiliza lancamentos complementares das entradas
             bHIST := "TIPOCONT->Hi_comp" + alltrim(str(nCONTADOR))
             if ! empty(&bHIST) .and. &bHIST $ ( CONFIG->His_icms + "*" + CONFIG->His_ipi )
                complementares(bHIST,alltrim(str(nCONTADOR)),"FAT")
             endif
         next
         endif

      endif
	  
	  if FAT->St > 0
	 
   	     if left(FAT->Cod_cfop,1) == "5"
			TIPOCONT->(Dbseek("010125")) // Conta De St Parana
         endif

         if SH_PROCT->(qappend())

            replace SH_PROCT->Data_lanc   with  FAT->Dt_emissao

            if TIPOCONT->Cont_pr_dv == "1"
               replace SH_PROCT->Cont_db with TIPOCONT->Ct_ct_p_dv
            else
               CLI1->(dbseek(FAT->Cod_cli))
               replace SH_PROCT->Cont_db with CLI1->Conta_cont
            endif

            if TIPOCONT->Cont_pr_cr == "1"
               replace SH_PROCT->Cont_cr with TIPOCONT->Ct_ct_p_cr
            else
               CLI1->(dbseek(FAT->Cod_cli))
               replace SH_PROCT->Cont_cr with CLI1->Conta_cont
            endif

            replace SH_PROCT->Filial     with  FAT->Filial

            replace SH_PROCT->Valor      with  FAT->St
            replace SH_PROCT->Num_doc    with  FAT->Num_fatura
            replace SH_PROCT->Num_lote   with  "CL" + XUSRNUM + "SUBST" // monta numero do lote
            replace SH_PROCT->Cod_hist   with ""

            replace SH_PROCT->Cod_fat    with FAT->Codigo

            replace SH_PROCT->Historico  with "VR SUBST. TRIB. NF "+FAT->Num_fatura+" "+ left(FAT->cliente,35)

         endif
	  endif	



      if FAT->(qrlock())
         replace FAT->Contabil with .T.
         FAT->(qunlock())
      endif

      FAT->(dbskip())

   enddo

   if CONFIG->(qrlock())
      replace CONFIG->Num_lote with ( CONFIG->Num_lote + 1 )
      CONFIG->(qunlock())
   endif

return
////////////////////////////////////////////////////////////////////////////////
//Desconta o valor das duplicatas quando for devolucÆo de venda. _______________

static function i_baixa_rb
   local nVALOR   := 0
   local nENTRADA := 0
   local nTOT_RECEB := 0
   local nTOT_DEVOL := 0

   nTOT_SER := 0

   FAT->(dbsetorder(2)) // dtos(dt_emissao)
   FAT->(Dbgotop())

   FAT->(dbseek(dtos(dINI),.T.))

   // LOOP PRINCIPAL NAS FATURAS A INTERFACEAR ______________________________

   do while ! FAT->(eof()) .and. FAT->Dt_emissao >= dINI .and. FAT->Dt_emissao <= dFIM

      qgirabarra()

      if FAT->Es $ "S-C"
         FAT->(Dbskip())
         loop
      endif

      if FAT->Interface
         FAT->(Dbskip())
         loop
      endif

      if FAT->Cod_cfop $ "1202 -2202 "
         i_calc_val()
         nTOT_DEVOL := nVAL
         RECEBER->(dbsetorder(11))
         if RECEBER->(Dbseek(FAT->Ref_Numnf))
            do while  left(RECEBER->Fatura,6)  == FAT->Ref_numnf
               nTOT_RECEB := nTOT_RECEB + RECEBER->Valor_liq
               qmensa("Fatura.: "+RECEBER->Fatura +"     Valor.: "+transf(RECEBER->Valor_liq,"@E 999,999.99"))
               qinkey(0)
               RECEBER->(Dbskip())
            enddo
         endif

         if RECEBER->(Dbseek(FAT->Ref_Numnf))
            if nTOT_DEVOL <= RECEBER->Valor_liq
               if RECEBER->(Qrlock())
                  replace RECEBER->Valor_liq with (RECEBER->Valor_liq - nTOT_DEVOL)
                  replace RECEBER->Valor   with (RECEBER->Valor - nTOT_DEVOL)
                  qmensa("Fatura.: "+RECEBER->Fatura +"     Valor.: "+transf(RECEBER->Valor_liq,"@E 999,999.99"))
                  qinkey(0)
                  RECEBER->(Qunlock())
               endif


            else


            endif
         endif

         if FAT->(Qrlock())
            replace FAT->Interface with .T.
            FAT->(Qunlock())
         endif


      endif

      nTOT_RECEB := 0
      nTOT_DEVOL := 0
      FAT->(dbskip())

   enddo
  

return
////////////////////////////////////////////////////////////////////////////////
// FUNCAO UTILIZADA PARA A SELECAO DOS MNEUMONICOS DO HISTORICO ________________
function monta_hist(cARQ,cHIST)

HIST->(dbseek(cHIST))
nHIST := HIST->Descricao

for nCONT := 1 to len(nHIST)
    if ( nPOS := at("[",nHIST) )  <> 0
       nPOS += 2  // para ignorar os simbolos [@
       CLI1->(dbgotop())
       do case
          case substr(nHIST,nPOS,2) == "CA"
               if cARQ == "FRETE"
                  FORN->(dbsetorder(1))
                  FORN->(Dbseek((cARQ)->Cod_forn))
                  replace SH_PROCT->Ca with left(FORN->Razao,40)
               else
                  CLI1->(Dbseek((cARQ)->Cod_cli))
                  replace SH_PROCT->Ca with left(CLI1->Razao,40)
               endif
          case substr(nHIST,nPOS,3) == "CGC"
               CLI1->(Dbseek((cARQ)->Cod_cli))
               replace SH_PROCT->Cgc with CLI1->Cgccpf
          case substr(nHIST,nPOS,2) == "DA"
               replace SH_PROCT->Da with XDATSYS
          case substr(nHIST,nPOS,2) == "DP" .or. substr(nHIST,nPOS,2) == "FA" .or. substr(nHIST,nPOS,2) == "NF"
               replace SH_PROCT->Dp with (cARQ)->Num_fatura
               replace SH_PROCT->Fa with (cARQ)->Num_fatura
               replace SH_PROCT->Nf with (cARQ)->Num_fatura
       endcase

       nHIST := substr( nHIST , nPOS+4 , len(nHIST) ) // retira da variavel nHIST, os mneumonicos que ja foram verificados

    else
      exit
    endif

next

return

/////////////////////////////////////////////////////////////////////
// funcao para calcular o valor com substituicao tributaria  ________

static function i_calc_val

   local nDESC      := 0
   local nDESCONTO  := 0
   local nTOT_PROD  := 0
   local nALIQ_ICMS := 0
   local nICMS_SUBST := 0
   local nICMS      := 0
   local nIPI       := 0
   local nOUT_IPI   := 0
   local nOUT_ICM   := 0
   local nISS       := 0
   local nBC_IPI    := 0
   local nBC_ICMS   := 0
   local nBC_SUBST  := 0
   local nICM_SUBST := 0
   local nDES_BC    := 0
   local nDES_ICMS  := 0

   ITEN_FAT->(Dbgotop())
   ITEN_FAT->(dbseek(FAT->Codigo))

   do while ITEN_FAT->Num_Fat == FAT->Codigo

      PROD->(dbsetorder(4))
      PROD->(dbseek(ITEN_FAT->Cod_Prod))

      nVAL_UNI := (ITEN_FAT->Vl_unitar)

      nTOT_PROD := nTOT_PROD + (ITEN_FAT->Quantidade * nVAL_UNI)

      if ITEN_FAT->Icms  > 0

         nBC_ICMS  := nBC_ICMS + (ITEN_FAT->Quantidade * nVAL_UNI)

         if ITEN_FAT->Ipi > 0
            nBC_IPI   := nBC_IPI  + (ITEN_FAT->Quantidade * nVAL_UNI)
            nIPI  := nIPI + ( ( ITEN_FAT->Quantidade * nVAL_UNI) * (ITEN_FAT->Ipi /100) )
            //Valor do IPI vai Pra Icms Outras - pqnao forma B.C. de ICMS

            nOUT_ICM := nOUT_ICM + ( ( ITEN_FAT->Quantidade * nVAL_UNI) * (ITEN_FAT->Ipi /100) )
         else
            nOUT_IPI  := nOUT_IPI + (ITEN_FAT->Quantidade * nVAL_UNI)
         endif



      else
         nOUT_ICM  := nOUT_ICM + (ITEN_FAT->Quantidade * nVAL_UNI)
         nOUT_IPI  := nOUT_IPI + (ITEN_FAT->Quantidade * nVAL_UNI)
      endif

      nALIQ := ITEN_FAT->Icms
      nICMS := nICMS + ( ( ITEN_FAT->Quantidade * nVAL_UNI) * (ITEN_FAT->Icms  / 100) )
      nISS  := 0

      //Valor do IPI vai Pra Icms Outras - pqnao forma B.C. de ICMS
      //nOUT_ICM := nOUT_ICM + ( ( ITEN_FAT->Quantidade * nVAL_UNI) * (ITEN_FAT->Ipi /100) )


      ITEN_FAT->(Dbskip())

      nVAL_UNI := 0

   enddo

   nICMS_VLR := nICMS
   nIPI_VLR := nIPI
   nISS_VLR := nISS

   nICMS_RED := 0
   if left(FAT->Cod_cfop,1) == "5"  .and. CLI1->Isento == "S"
      nICMS_VLR := (nICMS_VLR - (nICMS_VLR * 0.33333) )
      nICMS_RED := 33.333
   else
      nICMS_VLR  := nICMS_VLR
   endif


   CLI1->(dbseek(FAT->Cod_cli)) // procura a aliquota do lucro no cliente da nota
   CGM->(dbseek(CLI1->Cgm_cob))
   LUCRO->(dbseek(CGM->Estado))


   nICMS_BASE := nBC_ICMS
   nIPI_BASE  := nBC_IPI
   nICMS_OUT  := nOUT_ICM
   nIPI_OUT   := nOUT_IPI
   nVAL := nTOT_PROD + nIPI_VLR + nICMS_SUBST // valor total da fatura

   nVAL       := round(nVAL,2)
   nICMS_BASE := round(nICMS_BASE,2)
   nICMS_OUT  := round(nICMS_OUT,2)
   nIPI_BASE  := round(nIPI_BASE,2)
   nIPI_OUT   := round(nIPI_OUT,2)

   nICMS_VLR  := round(nICMS_VLR,2)
   nIPI_VLR   := round(nIPI_VLR,2)


return

function complementares (nCAMPO,nNUM,cARQ)  // nCAMPO == codigo do historio / nNUM = numero do campo / cARQ = arquivo a ser contabilizado
local zNUM  := 0

    //if TIPOCONT->Motivo == "1" // recebimento

       if SH_PROCT->(qappend())

          if cARQ == "FRETE"
             replace SH_PROCT->Data_lanc   with  (cARQ)->Dt_lanc
          else
             replace SH_PROCT->Data_lanc   with  (cARQ)->Dt_emissao
          endif

          nCONTA := "TIPOCONT->Ct_liq_" + nNUM
          zNUM := val(nNUM)

          if &nCONTA == "1"

             nCONTA  := "TIPOCONT->Ct_comp" + nNUM
             nCONTA1 := "TIPOCONT->Ct_comp" + alltrim(str(zNUM+1))
             zHIST   := "TIPOCONT->Hi_comp" + nNUM
             zHIST1  := "TIPOCONT->Hi_comp" + alltrim(str(zNUM+1))

             if &zHIST == &zHIST1
                if TIPOCONT->&("Fu_comp" + nNUM) == "4"
                     replace SH_PROCT->Cont_db with &nCONTA
                     replace SH_PROCT->Cont_cr with &nCONTA1
                     nCONTADOR++
                else
                     replace SH_PROCT->Cont_cr with &nCONTA
                     replace SH_PROCT->Cont_db with &nCONTA1
                     nCONTADOR++
                endif
             else
                do case
                  case TIPOCONT->&("Fu_comp" + nNUM) == "4"
                       replace SH_PROCT->Cont_db with &nCONTA
                  case TIPOCONT->&("Fu_comp" + nNUM) == "5"
                       replace SH_PROCT->Cont_cr with &nCONTA
                  otherwise
                       replace SH_PROCT->Cont_db with &nCONTA
               endcase
            endif

          endif

          replace SH_PROCT->Filial     with  "0001"
          replace SH_PROCT->Num_doc    with  (cARQ)->Num_fatura

          if (cARQ) == "FAT"
             replace SH_PROCT->Cod_fat    with  (cARQ)->Codigo
          endif

          do case
             case &nCAMPO == CONFIG->His_icms

                  do case
                  case cARQ == "FRETE"
                     replace SH_PROCT->Valor      with  (cARQ)->Vlr_Icm
                  case cARQ == "NOTAS"
                     replace SH_PROCT->Valor      with  (cARQ)->Icm_vlr
                  otherwise
                     replace SH_PROCT->Valor      with  nICMS_VLR   //(cARQ)->Icm_vlr
                  endcase
             case &nCAMPO == CONFIG->His_ipi
                  if cARQ == "NOTAS"
                     replace SH_PROCT->Valor      with  (cARQ)->Ipi_vlr
                  else
                     replace SH_PROCT->Valor      with  nIPI_VLR    //(cARQ)->Ipi_vlr
                  endif

          endcase

          replace SH_PROCT->Num_lote   with  "CL" + XUSRNUM + strzero(CONFIG->Num_lote,5) // monta numero do lote
          replace SH_PROCT->Cod_hist   with  &nCAMPO

          monta_hist((cARQ),nHISTORICO)

       endif

    //endif


return

static function i_cria_forn

local cCOD_FORN := space(5)
local cRAZAO    := space(65)


FORN->(Dbsetorder(3))
FORN->(Dbgotop())
cCOD_FORN := "     "
cRAZAO := Space(65)



CLI1->(Dbseek(FAT->Cod_Cli))

  if ! FORN->(dbseek(CLI1->Cgccpf))

     if ! quse(XDRV_CP,"CONFIG",NIL,NIL,"CPCFG")
        qmensa("Nao foi possivel abrir CONFIG do Compras!!","B")
     endif


     if CPCFG->(qrlock())
        replace CPCFG->Cod_forn with CPCFG->Cod_forn + 1
        cCOD_FORN := strzero(CPCFG->Cod_forn,5)
        CPCFG->(Qunlock())
     endif

     CPCFG->(DbCloseArea())

     if FORN->(Qappend())
        replace FORN->Codigo      with cCOD_FORN
        replace FORN->Filial      with CLI1->Filial
        replace FORN->Razao       with CLI1->Razao
        cRAZAO := CLI1->Razao
        replace FORN->Cgccpf      with CLI1->Cgccpf
        replace FORN->Inscricao   with CLI1->Inscricao
        replace FORN->End_cob     with CLI1->End_cob
        replace FORN->Bairro_cob  with CLI1->Bairro_cob
        replace FORN->Cgm_cob     with CLI1->Cgm_cob
        replace FORN->Cep_cob     with CLI1->Cep_cob
        replace FORN->End_ent     with CLI1->End_ent
        replace FORN->Bairro_cob  with CLI1->Bairro_ent
        replace FORN->Cgm_ent     with CLI1->Cgm_ent
        replace FORN->Cep_ent     with CLI1->Cep_ent
        replace FORN->Fone1       with CLI1->Fone1
        cFORN := cCOD_FORN
     endif
     CLI1->(DbCommit())
  else
    cFORN   := FORN->Codigo
    cRAZAO  := FORN->Razao
  endif

return

static function i_notas

   NOTAS->(dbsetorder(2)) // dtos(dt_emissao)

   NOTAS->(dbseek(dtos(dINI),.T.))

   // LOOP PRINCIPAL NAS FATURAS A INTERFACEAR ______________________________

   do while NOTAS->Dt_emissao >= dINI .and. NOTAS->Dt_emissao <= dFIM

      qgirabarra()

      if NOTAS->Fiscal
         NOTAS->(Dbskip())
         loop
      endif

      qmensa("Aguarde... Intefaceando com Escrita Fiscal...")

      if SH_EFFAT->(qappend())

         replace SH_EFFAT->Tipo      with left(NOTAS->Tipocont,2)
         replace SH_EFFAT->Subtipo   with right(NOTAS->Tipocont,4)
         replace SH_EFFAT->Serie     with "01"
         replace SH_EFFAT->Especie   with "01"
         replace SH_EFFAT->Nota_fisc with NOTAS->Num_fatura
         replace SH_EFFAT->Valor_liq with NOTAS->Vlr_cont
         replace SH_EFFAT->Data_cont with NOTAS->Dt_emissao
         CLI1->(Dbseek(NOTAS->Cod_cli))
         CGM->(Dbseek(CLI1->Cgm_ent))
         replace SH_EFFAT->Cgm        with CGM->Codigo
         replace SH_EFFAT->Filial     with "0001"
         replace SH_EFFAT->Data_lanc  with NOTAS->Dt_emissao
         replace SH_EFFAT->Data_emiss with NOTAS->Dt_emissao
         replace SH_EFFAT->Estado     with CGM->Estado
         replace SH_EFFAT->Cod_cli    with NOTAS->Cod_cli
         replace SH_EFFAT->Icm_base   with NOTAS->Icm_base
         replace SH_EFFAT->Ipi_base   with NOTAS->ipi_base
         replace SH_EFFAT->Icm_aliq   with NOTAS->Icm_aliq
         replace SH_EFFAT->Icm_vlr    with NOTAS->Icm_vlr
         replace SH_EFFAT->Ipi_vlr    with NOTAS->Ipi_vlr
         replace SH_EFFAT->Ipi_out    with (NOTAS->Vlr_cont - NOTAS->Icm_base)
         replace SH_EFFAT->Cfop       with NOTAS->Cfop
         SH_EFFAT->(qunlock())

      endif

      if NOTAS->(qrlock())
         replace NOTAS->Fiscal with .T.
         NOTAS->(qunlock())
      endif

      NOTAS->(dbskip())
   enddo

   NOTAS->(dbsetorder(2)) // dtos(dt_emissao)
   NOTAS->(Dbgotop())
   NOTAS->(dbseek(dtos(dINI),.T.))

   //fu_abre_prov()

   // LOOP PRINCIPAL NAS FATURAS A INTERFACEAR ______________________________

   do while NOTAS->Dt_emissao >= dINI .and. NOTAS->Dt_emissao <= dFIM

      qgirabarra()

      qmensa("Aguarde... Interfaceando Saidas com a Contabilidade...")

      if NOTAS->Contabil
         NOTAS->(dbskip())
         loop
      endif

      TIPOCONT->(Dbseek(NOTAS->Tipocont))

      if SH_PROCT->(qappend())

         replace SH_PROCT->Data_lanc   with  NOTAS->Dt_emissao

         if TIPOCONT->Regime_ope == "2" // Regime de competencia

            nHISTORICO := TIPOCONT->Hist_l_pr

            if TIPOCONT->Cont_pr_dv == "1"
               replace SH_PROCT->Cont_db with TIPOCONT->Ct_ct_p_dv
            else
               CLI1->(dbseek(NOTAS->Cod_cli))
               replace SH_PROCT->Cont_db with CLI1->Conta_cont
            endif

            if TIPOCONT->Cont_pr_cr == "1"
               replace SH_PROCT->Cont_cr with TIPOCONT->Ct_ct_p_cr
            else
               CLI1->(dbseek(NOTAS->Cod_cli))
               replace SH_PROCT->Cont_cr with CLI1->Conta_cont
            endif

         else // regime de caixa

            nHISTORICO := TIPOCONT->Hist_l_pr

            if TIPOCONT->Conta_liq == "1"
               replace SH_PROCT->Cont_db with TIPOCONT->Ct_ct_liq
            else
               CLI1->(dbseek(NOTAS->Cod_cli))
               replace SH_PROCT->Cont_db with CLI1->Conta_cont
            endif

            if TIPOCONT->Conta_l2 == "1"
               replace SH_PROCT->Cont_cr with TIPOCONT->Ct_ct_l2
            else
               CLI1->(dbseek(NOTAS->Cod_cli))
               replace SH_PROCT->Cont_cr with CLI1->Conta_cont
            endif

         endif

         replace SH_PROCT->Filial     with  "0001"

         replace SH_PROCT->Valor      with  NOTAS->Vlr_cont
         replace SH_PROCT->Num_doc    with  NOTAS->Num_fatura
         replace SH_PROCT->Num_lote   with  "CL" + XUSRNUM + strzero(CONFIG->Num_lote,5) // monta numero do lote
         replace SH_PROCT->Cod_hist   with nHISTORICO

         monta_hist("NOTAS",nHISTORICO)
         for nCONTADOR := 1 to 13  // contabiliza lancamentos complementares das entradas
             bHIST := "TIPOCONT->Hi_comp" + alltrim(str(nCONTADOR))
             if ! empty(&bHIST) .and. &bHIST $ ( CONFIG->His_icms + "*" + CONFIG->His_ipi )
                complementares(bHIST,alltrim(str(nCONTADOR)),"NOTAS")
             endif
         next


      endif



      if NOTAS->(qrlock())
         replace NOTAS->Contabil with .T.
         NOTAS->(qunlock())
      endif

      NOTAS->(dbskip())

   enddo

   if CONFIG->(qrlock())
      replace CONFIG->Num_lote with ( CONFIG->Num_lote + 1 )
      CONFIG->(qunlock())
   endif





return

static function i_frete
   fu_abre_apcom()


   FRETE->(dbsetorder(5)) // dtos(dt_lanc)

   FRETE->(dbseek(dtos(dINI),.T.))

   // LOOP PRINCIPAL NAS FATURAS A INTERFACEAR ______________________________

   do while FRETE->Dt_lanc >= dINI .and. FRETE->Dt_lanc <= dFIM

      qgirabarra()

      if FRETE->Fiscal
         FRETE->(Dbskip())
         loop
      endif

      //if SH_APCOM->(qappend())
      //
      //   replace SH_APCOM->Data_lanc    with FRETE->Dt_lanc
      //   replace SH_APCOM->Cod_forn     with FRETE->Cod_forn
      //   replace SH_APCOM->Centro       with "0001"
      // /  replace SH_APCOM->Filial       with "0001"
      //   replace SH_APCOM->Data_emiss   with FRETE->Dt_emissao
      //   replace SH_APCOM->Especie      with FRETE->Especie
      //   replace SH_APCOM->Serie        with FRETE->Serie
      //   replace SH_APCOM->Tipo_sub     with FRETE->Tipocont

      //   replace SH_APCOM->Data_venc    with FRETE->Dt_venc
      //   replace SH_APCOM->Valor        with FRETE->Vlr_total
      //   replace SH_APCOM->Valor_liq    with FRETE->Vlr_total
      //
      //   replace SH_APCOM->Fatura       with FRETE->Num_fatura
      //   replace SH_APCOM->Cgm          with "041000"
      //   FORN->(dbseek(FRETE->Cod_forn))
      //   replace SH_APCOM->Fornec       with FORN->Razao

      //endif


     if ! FRETE->Fiscal .and. FRETE->(qrlock())

        if SH_FICOM->(qappend())

           // ATUALIZA FLAG DE INTERFACIAMENTO ________________________________

           replace FRETE->Fiscal with .T.

           replace SH_FICOM->Data_lanc  with FRETE->Dt_Lanc
           replace SH_FICOM->Filial     with "0001"
           replace SH_FICOM->Num_nf     with FRETE->Num_fatura
           replace SH_FICOM->Especie    with FRETE->Especie
           replace SH_FICOM->Serie      with FRETE->Serie
           replace SH_FICOM->Data_emis  with FRETE->Dt_emissao
           replace SH_FICOM->Cod_forn   with FRETE->Cod_forn
           replace SH_FICOM->Vlr_cont   with FRETE->Vlr_total
           replace SH_FICOM->Cfop       with FRETE->Cfop
           replace SH_FICOM->Icm_base   with FRETE->Base_Icm
           replace SH_FICOM->Icm_aliq   with FRETE->Aliq_icm
           replace SH_FICOM->Icm_vlr    with FRETE->Vlr_icm
           replace SH_FICOM->Icm_out    with FRETE->Vlr_total - FRETE->Base_icm
           replace SH_FICOM->Ipi_out    with FRETE->Vlr_total
           replace SH_FICOM->Icm_cod    with "0"
        endif

     endif

     if ! FRETE->Contabil .and. FRETE->(qrlock())

        if TIPOCONT->(dbseek(FRETE->Tipocont)) //.and. TIPOCONT->Regime_ope == "2"
           replace FRETE->Contabil with .T.

           if SH_PROCT->(qappend())

              replace SH_PROCT->Data_lanc   with  FRETE->Dt_lanc

              if TIPOCONT->Regime_ope == "2" // Regime de competencia

                 nHISTORICO := TIPOCONT->Hist_l_pr

                 if TIPOCONT->Cont_pr_dv == "1"
                    replace SH_PROCT->Cont_db with TIPOCONT->Ct_ct_p_dv
                 else
                    FORN->(dbsetorder(1))
                    FORN->(dbseek(FRETE->Cod_forn))
                    replace SH_PROCT->Cont_db with FORN->Conta_cont
                 endif

                 if TIPOCONT->Cont_pr_cr == "1"
                    replace SH_PROCT->Cont_cr with TIPOCONT->Ct_ct_p_cr
                 else
                    FORN->(dbsetorder(1))
                    FORN->(dbseek(FRETE->Cod_forn))
                    replace SH_PROCT->Cont_cr with FORN->Conta_cont
                 endif

              else // regime de caixa

                 nHISTORICO := TIPOCONT->Hist_l_pr

                 if TIPOCONT->Conta_liq == "1"
                    replace SH_PROCT->Cont_db with TIPOCONT->Ct_ct_liq
                 else
                    FORN->(dbsetorder(1))
                    FORN->(dbseek(FRETE->Cod_forn))
                    replace SH_PROCT->Cont_db with FORN->Conta_cont
                 endif

                 if TIPOCONT->Conta_l2 == "1"
                    replace SH_PROCT->Cont_cr with TIPOCONT->Ct_ct_l2
                 else
                    FORN->(dbsetorder(1))
                    FORN->(dbseek(FRETE->Cod_forn))
                    replace SH_PROCT->Cont_cr with FORN->Conta_cont
                 endif

              endif

              replace SH_PROCT->Filial     with  "0001"

              replace SH_PROCT->Valor      with  FRETE->Vlr_Total
              replace SH_PROCT->Num_doc    with  FRETE->Num_fatura
              replace SH_PROCT->Num_lote   with  "CL" + XUSRNUM + strzero(CONFIG->Num_lote,5) // monta numero do lote
              replace SH_PROCT->Cod_hist   with nHISTORICO

              monta_hist("FRETE",nHISTORICO)
              for nCONTADOR := 1 to 13  // contabiliza lancamentos complementares das entradas
                  bHIST := "TIPOCONT->Hi_comp" + alltrim(str(nCONTADOR))
                  if ! empty(&bHIST) .and. &bHIST $ ( CONFIG->His_icms + "*" + CONFIG->His_ipi )
                     complementares(bHIST,alltrim(str(nCONTADOR)),"FRETE")
                  endif
              next



           endif
        endif

     endif

     enddo
              if CONFIG->(qrlock())
                 replace CONFIG->Num_lote with (CONFIG->Num_lote + 1)
                 CONFIG->(qunlock())
              endif

     SH_APCOM->(qunlock())
     SH_APCOM->(dbclosearea())

     SH_FICOM->(qunlock())
     SH_FICOM->(dbclosearea())

     SH_PROCT->(qunlock())
     SH_PROCT->(dbclosearea())
return

/////////////////////////////////////////////////////////////////////
// funcao para calcular o valor com substituicao tributaria  ________

static function calc_clari

   local nDESC      := 0
   local nDESCONTO  := 0
   local nTOT_PROD  := 0
   local nALIQ_ICMS := 0
   local nICMS_SUBST := 0
   local nICMS      := 0
   local nIPI       := 0
   local nISS       := 0
   local nBC_ICMS   := 0
   local nICMS_ST   := 0
   local nICMS_PROPRIO := 0
   local nDES_BC    := 0
   local nDES_ICMS  := 0
   local nVLR       := 0

   nVLR := 0

   ITEN_FAT->(Dbgotop())
   ITEN_FAT->(dbseek(FAT->Codigo))

   do while ITEN_FAT->Num_Fat == FAT->Codigo

      PROD->(dbsetorder(4))
      PROD->(dbseek(ITEN_FAT->Cod_Prod))

      nVAL_UNI := (ITEN_FAT->Vl_unitar)

      if FAT->dt_emissao >= ctod("04/02/2009") .and. FAT->dt_emissao <= ctod("10/08/2009")
         if ITEN_FAT->Bc_subst > 0 .and. CLI1->Final $ " -N"
            nICMS_ST      +=  ( (ITEN_FAT->Quantidade*ITEN_FAT->Bc_subst) * (ITEN_FAT->Icms /100))
            nICMS_PROPRIO +=  ( ( ITEN_FAT->Quantidade * ITEN_FAT->vl_unitar ) * ( 7 / 100 ) )
         endif
      else
         if ITEN_FAT->Bc_subst > 0 .and. CLI1->Final $ " -N"
            nICMS_ST      +=  ( (ITEN_FAT->Quantidade*ITEN_FAT->Bc_subst) * (ITEN_FAT->Icms /100))
            nICMS_PROPRIO +=  ( ( ITEN_FAT->Quantidade * nVAL_UNI ) * ( ITEN_FAT->Icms / 100 ) )
         endif
      endif

      nTOT_PROD := nTOT_PROD + (ITEN_FAT->Quantidade * nVAL_UNI)
      nBC_ICMS  := nBC_ICMS + (ITEN_FAT->Quantidade * nVAL_UNI)


      nICMS := nICMS + ( ( ITEN_FAT->Quantidade * nVAL_UNI) * (ITEN_FAT->Icms  / 100) )
      nIPI  := nIPI + ( ( ITEN_FAT->Quantidade * nVAL_UNI) * (ITEN_FAT->Ipi /100) )
      nISS  := 0

      nALIQ_ICMS:= ITEN_FAT->Icms

      ITEN_FAT->(Dbskip())

      nVAL_UNI := 0

   enddo

   if nALIQ_ICMS == 0
      nICMS := 0
      nIPI  := 0
   endif

   nALIQ := nALIQ_ICMS

   if CONFIG->Modelo_fat == "1"
     nICMS_VLR := nICMS
     nIPI_VLR := nIPI
     nISS_VLR := nISS

     //
   else
     nICMS_VLR := nICMS - (nICMS * (FAT->Aliq_desc/100) )
     nIPI_VLR := nIPI - (nIPI * (FAT->Aliq_desc/100) )
     nISS_VLR := nISS
   endif

   nICMS_RED := 0
   if left(FAT->Cod_cfop,1) == "5"  .and. CLI1->Isento == "S" .and. CLI1->Final $ " -N"
      nICMS_VLR := (nICMS_VLR - (nICMS_VLR * 0.33333) )
      nICMS_RED := 33.333
   else
      nICMS_VLR  := nICMS_VLR
   endif


   CLI1->(dbseek(FAT->Cod_cli)) // procura a aliquota do lucro no cliente da nota
   CGM->(dbseek(CLI1->Cgm_cob))
   LUCRO->(dbseek(CGM->Estado))

   if ! empty(FAT->Aliq_desc)
      if CONFIG->Modelo_fat == "1"
         nTOT_PROD := nTOT_PROD
      else
         nDESC :=  nTOT_PROD  * (FAT->Aliq_desc  / 100)
         nTOT_PROD := nTOT_PROD - nDESC
      endif
   endif

   if ! empty(FAT->Aliq_desc)
      if CONFIG->Modelo_fat == "1"
        nBC_ICMS := nBC_ICMS
      else
        nDES_BC :=  nBC_ICMS  * (FAT->Aliq_desc  / 100)
        nBC_ICMS := nBC_ICMS - nDES_BC
      endif
   endif

   nICMS_BASE := nBC_ICMS
   nIPI_BASE := nTOT_PROD
   if CONFIG->Modelo_2 == "7"
      nVLR := nTOT_PROD + (nICMS_ST-nICMS_PROPRIO) // valor total da fatura
   else
      nVLR := nTOT_PROD + nIPI_VLR  // valor total da fatura
   endif

   //if left(FAT->Cod_cfop,1) == "5"
   //   nICMS_BASE := nICMS_BASE - (nICMS_BASE*0.3333)
   //else
   //   nICMS_BASE := nICMS_BASE
   //endif


return nVLR







