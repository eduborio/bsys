/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: FATURAMENTO
// OBJETIVO...: PROPAGACAO DE SALDOS (SOMENTE NAS SAIDAS)
// ANALISTA...: EDUARDO BORIO
// PROGRAMADOR: O MESMO
// INICIO.....: ABRIL DE 2005
// OBS........:
// ALTERACOES.:

function cl404
	private dINI:= ctod("01/01/2005")
	private dFIM:= date()
	private cTITULO := ""

	if ! qconf("Confirma Geração de Arquivos AMARO ?")
		return .F.
	endif

	if ! quse(XDRV_CL,"FI540",{"FI540"},"E")
		qmensa("N„o foi poss¡vel abrir arquivo temporario !! Tente novamente.")
		return
	endif
	
	cTITULO := "RELATORIO DE VENDAS POR REPRESENTANTE" + " de " + dtoc(dINI) + " a " + dtoc(dFIM)
	
	i_getDados()
	
	if ! qinitprn() ; return  ; endif
	
	if XLOCALIMP == "X"
      
       i_impre_xls()
	 
    endif  

	FI540->(dbclosearea())
return

static function i_getDados
    local nTOTAL     := 0
    local nDESC      := 0
    local nTOT_GER   := 0
    local nTOT_COM   := 0
    local nCONT      := 0
    local nCOMISS    := 0
    local nPERC      := 0
    local nQUANT     := 0
    local nTOT_QUANT := 0
    local cPROD      := 0
    local nUF_QUANT  := 0
    local nUF_VALOR  := 0
    local aFAT       := {}
    local asFAT      := {}
    local fDATA_VEND := ctod("")
    local fVENC      := ctod("")
    local lTEM := .T.
    local nREP_COM := 0
    local nCOM_ITEM := 0


    FI540->(__dbzap())
   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________
    lTEM := .F.
	
   

   qmensa("")

   // ESTABELECE RELACOES ENTRE ARQUIVOS ____________________________________

   FAT->(dbsetorder(2)) // data de saida
   FAT->(dbgotop())
   set softseek on
   FAT->(Dbseek(dtos(dINI)))
   set softseek off
   ITEN_FAT->(dbsetorder(2))

   do while ! FAT->(eof())//  .and. FAT->Dt_emissao >= dINI .and. FAT->Dt_emissao <= dFIM  // condicao principal de loop

      CLI1->(dbseek(FAT->Cod_cli))

      if FAT->Cancelado
         FAT->(Dbskip())
         loop
      endif
	  
	  if ! FAT->Cod_repres $ "00005-00031"
		   FAT->(Dbskip())
		   loop	
	  endif
	  
	  CLI1->(dbseek(FAT->Cod_cli))
      CGM->(dbseek(CLI1->Cgm_Ent))
	  
	  if CGM->Estado != "SC"
	     FAT->(dbskip())
	     loop
	  endif

      if empty(FAT->Num_fatura) .and. FAT->Es == "S"
         FAT->(Dbskip())
         loop
      endif

      if ! left(FAT->Cod_cfop,3) $ "510-511-512-610-611-612-120-220-540-541-640-641-530-531-630-631"
         FAT->(dbskip())
         loop
      endif

      qgirabarra()

      qmensa("Aguarde... Processando ...")

      if FAT->Dt_emissao < dINI .or. FAT->Dt_emissao > dFIM
         FAT->(dbskip())
         loop
      endif

      nREP_COM := 0

      ITEN_FAT->(Dbgotop())
      ITEN_FAT->(Dbseek(FAT->Codigo))
      do while ITEN_FAT->Num_fat == FAT->Codigo .and. ! ITEN_FAT->(eof())

          PROD->(dbsetorder(4))
          PROD->(dbseek(ITEN_FAT->Cod_Prod))
          nTOTAL += ITEN_FAT->Quantidade * ITEN_FAT->Vl_unitar
          nDESC += ITEN_FAT->Vlr_desc * ITEN_FAT->Quantidade
          nREP_COM += ((ITEN_FAT->Quantidade * ITEN_FAT->Vl_unitar) * (ITEN_FAT->Comi_repre/100))
          lTEM := .T.
          ITEN_FAT->(Dbskip())
      enddo

      if CONFIG->Modelo_fat == "1"
         nDESC := nDESC
      else
         nDESC := nTOTAL * (FAT->Aliq_desc/100)
      endif

      //if !empty(cVEND) .and. FAT->Cod_repres <> cVEND
         //aadd(aFAT,{dtoc(FAT->Dt_Emissao),FAT->Cod_cli,,CGM->Estado,FAT->Cod_repres,CLI1->Comis_repr})
      //else
          //aadd(aFAT,{dtoc(FAT->Dt_Emissao),FAT->Cod_cli,CLI1->Razao,nTOTAL,FAT->Num_fatura,FAT->Cod_repres,nREP_COM,FAT->Es})
          if FI540->(qappend())
             replace FI540->Dt_emissao with FAT->Dt_emissao
             replace FI540->Cod_cli    with FAT->Cod_cli
             replace FI540->cli_razao  with CLI1->Razao
             replace FI540->Valor      with nTOTAL
             replace FI540->Fatura     with FAT->Num_fatura
             replace FI540->Cod_repres with FAT->cod_repres
             replace FI540->Rep_com    with nREP_COM
             replace FI540->Es         with FAT->Es
          endif

      //endif

      nTOTAL := 0
      nDESC  := 0
      nREP_COM := 0
      FAT->(dbskip())

   enddo

   FI540->(dbcommit())
   FI540->(dbgotop())


return


static function i_impre_xls
    local nTOTAL     := 0
    local nDESC      := 0
    local nTOT_GER   := 0
    local nTOT_COM   := 0
    local nCONT      := 0
    local nCOMISS    := 0
    local nPERC      := 0
    local nQUANT     := 0
    local nTOT_QUANT := 0
    local cPROD      := 0
    local nUF_QUANT  := 0
    local nUF_VALOR  := 0
    local aFAT       := {}
    local asFAT      := {}
    local fDATA_VEND := ctod("")
    local fVENC      := ctod("")
    local lTEM := .T.
    local nREP_COM := 0
    local nCOM_ITEM := 0

       FI540->(dbgotop())
       //zVEND  := FI540->Cod_repres
       nCONT := 1
       do while ! FI540->(eof())


           if XPAGINA == 0
              qpageprn()
              @ prow()+1,0 say chr(9)+chr(9)+cTITULO
              @ prow()+1,0 say "Data Emissao"+chr(9)+"Cod."+chr(9)+"Cliente"+chr(9)+"Total"+chr(9)+"Nota Fiscal"+chr(9)+"Vlr Comissao"

              @ prow()+1,0 say ""
           endif

           if FI540->Es == "S"
              nUF_VALOR += (FI540->Valor)
              nTOT_GER  += (FI540->Valor)
           else
              nUF_VALOR -= FI540->Valor
              nTOT_GER  -= FI540->Valor
           endif

           @ prow()+1, 00  say dtoc(FI540->dt_emissao)                         //Data de Emissao
           @ prow()  , pcol()  say chr(9)+FI540->Cod_cli                         //Codigo do Cliente
           @ prow()  , pcol()  say chr(9)+FI540->cli_razao                       //Razao do Cliente
           @ prow()  , pcol()  say chr(9)+transf(FI540->Valor,"@E 9,999,999.99") //Valor da Nota

           @ prow()  , pcol()  say chr(9)+FI540->Fatura                         //Numero da Nota

           if FI540->Es == "S"
              @ prow()  ,pcol()  say chr(9)+transf(FI540->Rep_com,"@E 999,999.99") //Comissao
              nCOMISS  += ( FI540->Rep_com )
              nTOT_COM += ( FI540->Rep_com)

           else
              @ prow()  ,pcol()  say chr(9)+transf(FI540->Rep_com,"@E 999,999.99") //Comissao
              @ prow()  ,pcol()  say chr(9)+"Devolucao" //Comissao

              nCOMISS  -= ( FI540->Rep_com )
              nTOT_COM -= ( FI540->Rep_com)


           endif

           FI540->(dbskip())

       enddo

       @ prow()+2  ,00 say chr(9)+chr(9)+"TOTAIS DO REPRESENTANTE...: "+"AMARO SOMENTE SC"
       @ prow()    ,pcol() say chr(9)+transf(nUF_VALOR,"@E 99,999,999.99")
       @ prow()    ,pcol() say chr(9)+transf(nCOMISS,"@E 999,999.99")
       @ prow()+1,00 say ""

       nQUANT := 0
       nTOTAL := 0
       nPERC  := 0

       qstopprn()

return
