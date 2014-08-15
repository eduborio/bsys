static function i_menos_pontos(cCOD_REPRES,cCOD_PROD,nQUANT,nPRECO)
local nREG   := 0
local nINDEX := 0
local nPONTOS := 0

nREG   := PROD->(Recno())
nINDEX := PROD->(IndexOrd())

MILHAS->(Dbsetorder(2))

PROD->(Dbsetorder(4))

if PROD->(dbseek(cCOD_PROD))
   nPONTOS := PROD->Pontos
else
   nPONTOS := 0
endif


if left(FAT->Cod_cfop,3) $ "510-610-511-611"
   if MILHAS->(Dbseek(cCOD_REPRES))
      if MILHAS->(Qrlock()) .and. FAT->Dt_emissao >= MILHAS->Data_ini
         replace MILHAS->Pontos with MILHAS->Pontos - ( (nPRECO * nQUANT) * nPONTOS )
      endif
   endif
endif

PROD->(dbgoto(nREG))
PROD->(dbsetorder(nINDEX))

return

static function i_abre_lanc()
local labriu := .F.

   if ! quse(XDRV_CT,"LANC",{"LA_DATA","LA_DBDAT","LA_CRDAT","LA_NLANC","LA_LOLAN","LA_CEDBD","LA_CECRD","LA_DTFIL","LA_FICTD","LA_FICTC","LA_DTNUM","LANC_FAT","LANC_DOC"})
      Qmensa("Nao foi possivel abrir arquivo LANC.DBF !","B")
      lAbriu := .F.
   else
      lAbriu := .T.
   endif
return lAbriu


static function i_abre_sai()
local labriu := .F.

   if ! quse(XDRV_EF,"SAI",{"SAI_NUM","SAI_LANC","SAI_FISC","SAI_VEND","SAI_FIS2","SAI_CONT","SAI_NFFI","SAI_CFOP","SAI_CFP2","SAI_EMISS","NUMNFTX"})
      Qmensa("Nao foi possivel abrir arquivo SAI.DBF !","B")
      lAbriu := .F.
   else
      lAbriu := .T.
   endif
return lAbriu


static function i_abre_receber()
local labriu := .F.

   if ! quse(XDRV_RB,"RECEBER",{"REC_COD","REC_VENC","REC_DUP","REC_DTEM","REC_CLIE","REC_LOTE","REC_BANC","REC_CLRZ","REC_CDCL","RB_DTVCL","REC_FATU","RECCLIVC"})
      Qmensa("Nao foi possivel abrir arquivo RECEBER.DBF !","B")
      lAbriu := .F.
   else
      lAbriu := .T.
   endif
return lAbriu

static function i_entra_mantra(nQTY,nLOCAL,nTERCEIROS) //Executa estoques...
local nMANTRA := 0
local nIGI    := 0
local nTT     := 0


if CONFIG->Modelo_fat == "1"

   if left(FAT->cod_cfop,4) $ "5905-6905-5906-6906"
      if INVENT->(dbseek(FAT->Filial+ITEN_FAT->Cod_prod+ITEN_FAT->Num_lote))
         if INVENT->(qrlock())
            replace INVENT->Quant_atu with INVENT->Quant_atu + nQTY
            replace INVENT->Quant_ter with INVENT->Quant_ter - nQTY
            INVENT->(Qunlock())
         endif
       else
          qmensa("Lote nao encontrado nesta Filial !","B")
          return .F.
      endif

   else

      if INVENT->(dbseek(FAT->Filial+ITEN_FAT->Cod_prod+ITEN_FAT->Num_lote))

         if INVENT->(Qrlock())

            if nLOCAL > 0 .or. nTerceiros > 0
               if nLOCAL > 0
                  replace INVENT->Quant_atu with INVENT->Quant_atu + nLOCAL
               endif

               if nTerceiros > 0
                  //replace INVENT->Quant_ter with INVENT->Quant_ter + nTERCEIROS
                  replace INVENT->Quant_res with INVENT->Quant_res - nTERCEIROS
               endif
            else
               replace INVENT->Quant_atu with INVENT->Quant_atu + nQTY
            endif
            INVENT->(Qunlock())
         endif

       else
          qmensa("Lote nao encontrado nesta Filial !","B")
          return .F.
      endif
   endif


else
   if CONFIG->Estoque == "S"
      if INVENT->(dbseek(FAT->Filial+ITEN_FAT->Cod_prod+ITEN_FAT->Num_lote))

         if INVENT->(Qrlock())
            replace INVENT->Quant_atu with INVENT->Quant_atu + nQTY
            INVENT->(Qunlock())
         endif

       else
          qmensa("Lote nao encontrado nesta Filial !","B")
          return .F.
      endif
  endif
endif

return



