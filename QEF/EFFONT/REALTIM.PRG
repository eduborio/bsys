/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE ESCRITA FISCAL
// OBJETIVO...: INTERFACE COM FATURAMENTO/COMPRAS/XML
// ANALISTA...: Eduardo Borio
// PROGRAMADOR: Eduardo Borio
// INICIO.....:
// OBS........:


//////////////////////////////////////////////////////////////////////////////
// ABERTURA DE ARQUIVOS NECESSARIOS PARA INTERFACE __________________________
function realtime

private nDRIVE := "SH"
private nVLRMERC := nISSBASE := nISSVLR := 0 , XNIVEL, sTELA

// ARQUIVO SH_EFFAT DO EM MODO EXCLUSIVO ____________________________________

  xmlImport()

if ! quse( XDRV_EF ,"CONFIG",NIL,NIL,NIL)
   qmensa("N„o foi poss¡vel abrir arquivo CONFIG.DBF !! Tente novamente.")
   dbcloseall()
   return
endif

//////////////////////////////////////////////////////////////////////////////
// ARQUIVO SH_EFFAT DO FATURAMENTO QSYS_G EM MODO EXCLUSIVO __________________
   cTESTE := 0
   do case
      case CONFIG->Tipo_fat == "1"
           nDRIVE := "CL"  // faturamento comercial
      case CONFIG->Tipo_fat == "2"
           nDRIVE := "IN"  // faturamento industrial
      case CONFIG->Tipo_fat == "3"
           nDRIVE := "FS"  // faturamento servicos
      case CONFIG->Tipo_fat == "4"
           nDRIVE := "TV"  // faturamento tele-vendas
      case CONFIG->Tipo_fat == "5"
           nDRIVE := "TR"  // faturamento transportes
      case CONFIG->Tipo_fat == "6"
           nDRIVE := "FU"  // faturamento concretagem
      case CONFIG->Tipo_fat == "7"
           nDRIVE := "LJ"  // faturamento de loja
      case CONFIG->Tipo_fat == "8"
           nDRIVE := "SA"  // faturamento de servicos de acessoria
      case CONFIG->Tipo_fat == "9"
           nDRIVE := "FA"  // faturamento de fabrica
      case CONFIG->Tipo_fat == "A"
           cTESTE := 1
   endcase

   if cTESTE == 1
      Outros()  // Interface com outros arquivos Yes Som
      return
   elseif ! quse(&("XDRV_" + nDRIVE),"SH_EFFAT",NIL,"E")
      qmensa("N„o foi poss¡vel abrir arquivo SH_EFFAT.DBF !! Tente novamente.")
      dbcloseall()
      return
   endif

SH_EFFAT->(__dbPack())

// if SH_EFFAT->(eof())
//    SH_EFFAT->(dbclosearea())
//    return
// endif

if ! quse(XDRV_CT,"FILIAL",{"FI_CODIG"})
   qmensa("N„o foi poss¡vel abrir arquivo FILIAL.DBF !! Tente novamente.")
   dbcloseall()
   return
endif

if ! quse(XDRV_SH,"CGM",{"CGM_COD"})
   qmensa("N„o foi poss¡vel abrir arquivo CGM.DBF !! Tente novamente.")
   dbcloseall()
   return
endif

if ! quse(XDRV_EF,"ISS",{"ISS_NUM","ISS_LANC","ISS_FILI"})
   qmensa("N„o foi poss¡vel abrir arquivo ISS.DBF !! Tente novamente.")
   dbcloseall()
   return
endif

if ! quse(XDRV_EF,"SAI",{"SAI_NUM","SAI_LANC","SAI_FISC","SAI_VEND","SAI_FIS2","SAI_CONT"})
   qmensa("N„o foi poss¡vel abrir arquivo SAI.DBF !! Tente novamente.")
   dbcloseall()
   return
endif

// ARQUIVO MUNICIP.DBF DO QEF _______________________________________________

if ! quse(XDRV_EF,"MUNICIP",{"MUN_CGM"},"R")
   qmensa("N„o foi poss¡vel abrir arquivo MUNICIP.DBF !! Tente novamente.")
   dbcloseall()
   return
endif

// CARREGA BLOCO REALTIME.RRB _______________________________________________

sTELA := qsbloc(05,00,23,79)

//////////////////////////////////////////////////////////////////////////////
// EXECUTA INTERFACE ________________________________________________________



do while ! SH_EFFAT->(eof())

   qlbloc(5,0,"BREAL","QBLOC.GLO")

   MUNICIP->(dbseek(SH_EFFAT->Cgm))

//   if ISS->(qappend())
//
//      replace ISS->Data_lanc with SH_EFFAT->Data_cont
//     replace ISS->Filial    with SH_EFFAT->Filial
//      replace ISS->Municip   with MUNICIP->Codigo
//      replace ISS->Especie   with SH_EFFAT->Especie
//      replace ISS->Serie     with SH_EFFAT->Serie
//      replace ISS->Num_nf    with SH_EFFAT->Nota_fisc
//    replace ISS->Tipo      with SH_EFFAT->Tipo
//    replace ISS->Subtipo   with SH_EFFAT->Subtipo
//      replace ISS->Cod_serv  with SH_EFFAT->Cod_serv
//      replace ISS->Data_emis with SH_EFFAT->Data_cont
//      replace ISS->Vlr_cont  with SH_EFFAT->Valor_liq
//
//      FILIAL->(dbseek(SH_EFFAT->Filial))

//      CGM->(dbseek(FILIAL->Cgm))

//      if left(MUNICIP->Cgm_desc,15) <> CGM->Municipio
//         replace ISS->Obs   with  left(MUNICIP->Cgm_desc,18)
//      endif

//      if SH_EFFAT->Isento == "S"
//         replace ISS->Obs   with alltrim(ISS->Obs) + " - ISENTO"
//      endif

//      nVLRMERC := iif(SH_EFFAT->Isento<>"S",SH_EFFAT->Valor_liq * ((100 - MUNICIP->Aliq_base) / 100),0)

 //     replace ISS->Vlr_merc  with nVLRMERC

 //     nISSBASE := iif(SH_EFFAT->Isento<>"S",SH_EFFAT->Valor_liq - nVLRMERC,0)

 //     replace ISS->Iss_base  with nISSBASE
//      replace ISS->Iss_aliq  with MUNICIP->Aliq_iss

//      nISSVLR := iif(SH_EFFAT->Isento<>"S",nISSBASE * (MUNICIP->Aliq_iss / 100),0)

 //     replace ISS->Iss_vlr  with nISSVLR

//      XNIVEL := 1

//      qrsay(XNIVEL++,SH_EFFAT->Filial)
//      qrsay(XNIVEL++,ISS->Municip)
//      qrsay(XNIVEL++,SH_EFFAT->Data_cont)
//    qrsay(XNIVEL++,SH_EFFAT->Tipo)
//    qrsay(XNIVEL++,SH_EFFAT->Subtipo)
//      qrsay(XNIVEL++,SH_EFFAT->Nota_fisc)
//      qrsay(XNIVEL++,SH_EFFAT->Serie)
//      qrsay(XNIVEL++,SH_EFFAT->Especie)
//      qrsay(XNIVEL++,SH_EFFAT->Data_cont)
//      qrsay(XNIVEL++,SH_EFFAT->Valor_liq,"@E 999,999,999.99")

//      ISS->(qunlock())

//   endif

   if SAI->(qappend())

      replace SAI->Data_lanc with SH_EFFAT->Data_lanc
      replace SAI->Filial    with SH_EFFAT->Filial
      replace SAI->Especie   with SH_EFFAT->Especie
      replace SAI->Serie     with SH_EFFAT->Serie
      replace SAI->Cod_cli   with SH_EFFAT->Cod_cli
      if nDRIVE == "TR"
         replace SAI->Num_nf    with right(SH_EFFAT->Nota_fisc,6)
      else
         replace SAI->Num_nf    with left(SH_EFFAT->Nota_fisc,6)
      endif
      replace SAI->Data_emis with SH_EFFAT->Data_cont
      replace SAI->Estado    with SH_EFFAT->Estado
      replace SAI->Vlr_cont  with SH_EFFAT->Valor_liq
      replace SAI->Tipo_cont with SH_EFFAT->Tipo + SH_EFFAT->Subtipo
      replace SAI->Cod_fisc  with SH_EFFAT->Cod_fisc
      replace SAI->Icm_base  with SH_EFFAT->Icm_base
      replace SAI->Icm_aliq  with SH_EFFAT->Icm_aliq
      replace SAI->Icm_vlr   with SH_EFFAT->Icm_vlr
      replace SAI->Icm_red   with SH_EFFAT->Icm_red
      replace SAI->Ipi_base  with SH_EFFAT->Ipi_base
      replace SAI->Ipi_Vlr   with SH_EFFAT->Ipi_vlr
      replace SAI->Icm_out   with SH_EFFAT->Icm_out
      replace SAI->Ipi_out   with SH_EFFAT->Ipi_out
	  replace SAI->Icm_bc_s  with SH_EFFAT->Icm_bc_s
      replace SAI->Icm_subst with SH_EFFAT->Icm_subst

      replace SAI->Cfop      with SH_EFFAT->cfop
      replace SAI->Icm_cod   with "0"
      replace SAI->Modelo    with SH_EFFAT->Modelo
      replace SAI->NFE       with SH_EFFAT->NFE

   endif

   SH_EFFAT->(dbdelete())

   SH_EFFAT->(dbskip())

enddo



SH_EFFAT->(dbclosearea())
ISS->(dbclosearea())
SAI->(dbclosearea())
MUNICIP->(dbclosearea())
CGM->(dbclosearea())
FILIAL->(dbclosearea())

if ! quse(XDRV_CP,"SH_FICOM",NIL,"E")
   qmensa("N„o foi poss¡vel abrir arquivo SH_FICOM.DBF !! Tente novamente.")
   dbcloseall()
   return
endif

SH_FICOM->(__dbPack())

// if SH_FICOM->(eof())
//    SH_FICOM->(dbclosearea())
//    return
// endif

//fu_abre_ccusto()

// ARQUIVO ISS.DBF DO QEF ___________________________________________________

if ! quse(XDRV_EF,"ENT",{"ENT_NUM","ENT_LANC","ENT_FISC","ENT_FIS2","ENT_FORN","ENT_CONT"})
   qmensa("N„o foi poss¡vel abrir arquivo ENT.DBF !! Tente novamente.")
   dbcloseall()
   return
endif

sTELA := qsbloc(05,00,23,79)

do while ! SH_FICOM->(eof())

   qlbloc(5,0,"BREAL1","QBLOC.GLO")

   if ENT->(qappend())

      replace ENT->DATA_LANC  with SH_FICOM->DATA_LANC
      replace ENT->FILIAL     with SH_FICOM->FILIAL
      replace ENT->NUM_NF     with SH_FICOM->NUM_NF
      replace ENT->ESPECIE    with SH_FICOM->ESPECIE
      replace ENT->SERIE      with SH_FICOM->SERIE
      replace ENT->DATA_EMIS  with SH_FICOM->DATA_EMIS
      replace ENT->COD_FORN   with SH_FICOM->COD_FORN
      replace ENT->COD_MAQ    with SH_FICOM->COD_MAQ
      replace ENT->VLR_CONT   with SH_FICOM->VLR_CONT
      replace ENT->COD_CONT   with SH_FICOM->COD_CONT
      replace ENT->COD_FISC   with SH_FICOM->COD_FISC
      replace ENT->CFOP        with SH_FICOM->CFOP

         replace ENT->ICM_BASE   with SH_FICOM->ICM_BASE
         replace ENT->ICM_OUT    with SH_FICOM->ICM_OUT
         replace ENT->ICM_ALIQ   with SH_FICOM->ICM_ALIQ
         replace ENT->ICM_VLR    with SH_FICOM->ICM_VLR

         replace ENT->ICM_COD    with "0"

      replace ENT->IPI_BASE   with SH_FICOM->IPI_BASE
      replace ENT->IPI_VLR    with SH_FICOM->IPI_VLR
      replace ENT->IPI_ISEN   with SH_FICOM->IPI_ISEN
      replace ENT->IPI_OUT    with SH_FICOM->IPI_OUT
      replace ENT->IPI_DESC   with SH_FICOM->IPI_DESC
      replace ENT->OBS        with SH_FICOM->OBS
      replace ENT->ICM_SUBST  with SH_FICOM->ICM_SUBST
      replace ENT->ICM_BC_S   with SH_FICOM->ICM_BC_S

      XNIVEL := 1

      qrsay(XNIVEL++,SH_FICOM->FILIAL     )
      qrsay(XNIVEL++,SH_FICOM->DATA_LANC  )
      qrsay(XNIVEL++,SH_FICOM->NUM_NF     )
      qrsay(XNIVEL++,SH_FICOM->ESPECIE    )
      qrsay(XNIVEL++,SH_FICOM->SERIE      )
      qrsay(XNIVEL++,SH_FICOM->DATA_EMIS  )
      qrsay(XNIVEL++,SH_FICOM->COD_FORN   )
      qrsay(XNIVEL++,SH_FICOM->COD_MAQ    )
      qrsay(XNIVEL++,SH_FICOM->COD_FISC   )
      qrsay(XNIVEL++,SH_FICOM->COD_CONT   )
      qrsay(XNIVEL++,SH_FICOM->VLR_CONT   )
      qrsay(XNIVEL++,SH_FICOM->ICM_BASE   )
      qrsay(XNIVEL++,SH_FICOM->ICM_RED    )
      qrsay(XNIVEL++,SH_FICOM->ICM_ALIQ   )
      qrsay(XNIVEL++,SH_FICOM->ICM_VLR    )
      qrsay(XNIVEL++,SH_FICOM->ICM_ISEN   )
      qrsay(XNIVEL++,SH_FICOM->ICM_OUT    )
      qrsay(XNIVEL++,SH_FICOM->ICM_BC_S   )
      qrsay(XNIVEL++,SH_FICOM->ICM_SUBST  )
      qrsay(XNIVEL++,SH_FICOM->IPI_BASE   )
      qrsay(XNIVEL++,SH_FICOM->IPI_VLR    )
      qrsay(XNIVEL++,SH_FICOM->IPI_ISEN   )
      qrsay(XNIVEL++,SH_FICOM->IPI_OUT    )
      qrsay(XNIVEL++,SH_FICOM->IPI_DESC   )
      qrsay(XNIVEL++,SH_FICOM->ICM_COD    )
      qrsay(XNIVEL++,SH_FICOM->OBS        )

      SH_FICOM->(dbdelete())

      ENT->(qunlock())

   endif

   SH_FICOM->(dbskip())

enddo

SH_FICOM->(dbclosearea())
ENT->(dbclosearea())
CONFIG->(dbclosearea())

dbunlockall()

qrbloc(5,0,sTELA)

return

// ARQUIVO DE INTERFACE YES SOM ENTRADA ___________________________________________________

Function Outros

   if ! quse(XDRV_EF,"ENT",{"ENT_NUM","ENT_LANC","ENT_FISC","ENT_FIS2","ENT_FORN","ENT_CONT"},"E")
      qmensa("N„o foi poss¡vel abrir arquivo ENT.DBF !! Tente novamente.")
      dbcloseall()
      return
   endif

   if ! quse(XDRV_EF,"SH_QEFET",NIL,"E")
      qmensa("N„o foi poss¡vel abrir arquivo SH_QEFET.DBF !! Tente novamente.")
      dbcloseall()
      return
   endif

   if ! quse(XDRV_EF,"OUTENT",{"OUTENT"},"E")
      qmensa("N„o foi poss¡vel abrir arquivo OUTENT.DBF !! Tente novamente.")
      dbcloseall()
      return
   endif

   if ! quse(XDRV_EFX,"NATOP",{"NAT_COD"})
      qmensa("N„o foi poss¡vel abrir arquivo NATOP.DBF !! Tente novamente.")
      dbcloseall()
      return
   endif

   sTELA := qsbloc(05,00,23,79)

   nTOTAL := SH_QEFET->(Lastrec())
   do while ! SH_QEFET->(eof())
      Select ENT
      qmensa("Aguarde... Processando Registros de Entrada.: "+transform(strzero(SH_QEFET->(recno()),6),"@R 99999999")+ "Total -> "+ transform(strzero(nTOTAL,6),"@R 99999999"))
      qlbloc(5,0,"BREAL1","QBLOC.GLO")

//    if SH_QEFET->Vlr_cont = 0.00
//       SH_QEFET->(Dbskip())
//       loop
//    endif

      if ! ENT->(dbseek(SH_QEFET->Num_nf + SH_QEFET->Serie + SH_QEFET->Filial + SH_QEFET->Cod_forn))

         if ENT->(qappend())

            replace ENT->DATA_LANC  with SH_QEFET->DATA_LANC
            replace ENT->FILIAL     with SH_QEFET->FILIAL
            replace ENT->NUM_NF     with SH_QEFET->NUM_NF
            replace ENT->ESPECIE    with SH_QEFET->ESPECIE
            replace ENT->SERIE      with SH_QEFET->SERIE
            replace ENT->DATA_EMIS  with SH_QEFET->DATA_EMIS
            replace ENT->COD_FORN   with SH_QEFET->COD_FORN
            replace ENT->COD_MAQ    with SH_QEFET->COD_MAQ
            replace ENT->VLR_CONT   with SH_QEFET->VLR_CONT
            replace ENT->COD_CONT   with SH_QEFET->COD_CONT
            replace ENT->COD_FISC   with SH_QEFET->COD_FISC
            NATOP->(dbseek(ENT->Cod_fisc))
            replace ENT->Tipo_cont  with NATOP->Tip_cont
            replace ENT->ICM_BASE   with SH_QEFET->ICM_BASE
            replace ENT->ICM_RED    with SH_QEFET->ICM_RED
            replace ENT->ICM_ALIQ   with SH_QEFET->ICM_ALIQ
            replace ENT->ICM_VLR    with SH_QEFET->ICM_VLR
            replace ENT->ICM_ISEN   with SH_QEFET->ICM_ISEN
            replace ENT->ICM_OUT    with SH_QEFET->ICM_OUT
            replace ENT->ICM_COD    with SH_QEFET->ICM_COD
            replace ENT->IPI_BASE   with SH_QEFET->IPI_BASE
            replace ENT->IPI_VLR    with SH_QEFET->IPI_VLR
            replace ENT->IPI_ISEN   with SH_QEFET->IPI_ISEN
            replace ENT->IPI_OUT    with SH_QEFET->IPI_OUT
            replace ENT->IPI_DESC   with SH_QEFET->IPI_DESC
            replace ENT->OBS        with SH_QEFET->OBS
            replace ENT->ICM_SUBST  with SH_QEFET->ICM_SUBST
            replace ENT->ICM_BC_S   with SH_QEFET->ICM_BC_S
            replace ENT->ICM_COD    with "0"

            XNIVEL := 1

            qrsay(XNIVEL++,SH_QEFET->FILIAL     )
            qrsay(XNIVEL++,SH_QEFET->DATA_LANC  )
            qrsay(XNIVEL++,SH_QEFET->NUM_NF     )
            qrsay(XNIVEL++,SH_QEFET->ESPECIE    )
            qrsay(XNIVEL++,SH_QEFET->SERIE      )
            qrsay(XNIVEL++,SH_QEFET->DATA_EMIS  )
            qrsay(XNIVEL++,SH_QEFET->COD_FORN   )
            qrsay(XNIVEL++,SH_QEFET->COD_MAQ    )
            qrsay(XNIVEL++,SH_QEFET->COD_FISC   )
            qrsay(XNIVEL++,SH_QEFET->COD_CONT   )
            qrsay(XNIVEL++,SH_QEFET->VLR_CONT   )
            qrsay(XNIVEL++,SH_QEFET->ICM_BASE   )
            qrsay(XNIVEL++,SH_QEFET->ICM_RED    )
            qrsay(XNIVEL++,SH_QEFET->ICM_ALIQ   )
            qrsay(XNIVEL++,SH_QEFET->ICM_VLR    )
            qrsay(XNIVEL++,SH_QEFET->ICM_ISEN   )
            qrsay(XNIVEL++,SH_QEFET->ICM_OUT    )
            qrsay(XNIVEL++,SH_QEFET->ICM_BC_S   )
            qrsay(XNIVEL++,SH_QEFET->ICM_SUBST  )
            qrsay(XNIVEL++,SH_QEFET->IPI_BASE   )
            qrsay(XNIVEL++,SH_QEFET->IPI_VLR    )
            qrsay(XNIVEL++,SH_QEFET->IPI_ISEN   )
            qrsay(XNIVEL++,SH_QEFET->IPI_OUT    )
            qrsay(XNIVEL++,SH_QEFET->IPI_DESC   )
            qrsay(XNIVEL++,SH_QEFET->ICM_COD    )
            qrsay(XNIVEL++,SH_QEFET->OBS        )

            SH_QEFET->(dbdelete())

            ENT->(qunlock())

         endif

      else
         cNUM_NF := SH_QEFET->Num_nf
         cSERIE  := SH_QEFET->Serie
         cFILIAL := SH_QEFET->Filial
         if SH_QEFET->ICM_ALIQ <> 0
            Select OUTENT
            if ! OUTENT->(dbseek(cNUM_NF + cSERIE + cFILIAL ))
               if OUTENT->(qappend())
                  replace OUTENT->DATA_LANC  with SH_QEFET->DATA_LANC
                  replace OUTENT->NUM_NF     with SH_QEFET->NUM_NF
                  replace OUTENT->SERIE      with SH_QEFET->SERIE
                  replace OUTENT->FILIAL     with SH_QEFET->FILIAL
                  replace OUTENT->ICM_BASE   with SH_QEFET->ICM_BASE
                  replace OUTENT->ICM_ALIQ   with SH_QEFET->ICM_ALIQ
                  replace OUTENT->ICM_VLR    with SH_QEFET->ICM_VLR
                  if ENT->(qrlock())
                     replace ENT->VLR_CONT      with (ENT->VLR_CONT + SH_QEFET->ICM_BASE)
                     ENT->(qunlock())
                  endif
                  Select  OUTENT
                  OUTENT->(qunlock())
                  Select  SH_QEFET
               endif
            endif
         endif

         SH_QEFET->(dbdelete())
         ENT->(qunlock())

      endif

      SH_QEFET->(dbskip())

   enddo

   SH_QEFET->(__dbPack())

   SH_QEFET->(dbclosearea())

   ENT->(dbclosearea())

   OUTENT->(dbclosearea())

   NATOP->(dbclosearea())

   dbunlockall()

   qrbloc(5,0,sTELA)

   if ! quse(XDRV_EF,"SAI",{"SAI_NUM","SAI_LANC","SAI_FISC","SAI_VEND","SAI_FIS2","SAI_CONT"},"E")
      qmensa("N„o foi poss¡vel abrir arquivo SAI.DBF !! Tente novamente.")
      dbcloseall()
      return
   endif

   if ! quse(XDRV_EF,"SH_QEFSA",NIL,"E")
      qmensa("N„o foi poss¡vel abrir arquivo SH_QEFSA.DBF !! Tente novamente.")
      dbcloseall()
      return
   endif

   if ! quse(XDRV_EF,"OUTSAI",{"OUTSAI"},"E")
      qmensa("N„o foi poss¡vel abrir arquivo OUTSAI.DBF !! Tente novamente.")
      dbcloseall()
      return
   endif

   if ! quse(XDRV_EFX,"NATOP",{"NAT_COD"},"E")
      qmensa("N„o foi poss¡vel abrir arquivo NATOP.DBF !! Tente novamente.")
      dbcloseall()
      return
   endif

   sTELA := qsbloc(05,00,23,79)

   nTOTAL := SH_QEFSA->(Lastrec())

   do while ! SH_QEFSA->(eof())
      Select SAI
      qmensa("Aguarde... Processando Registros de Saida...: "+transform(strzero(SH_QEFSA->(recno()),6),"@R 99999999")+ "Total -> " + transform(strzero(nTOTAL,6), "@R 99999999"))

      qlbloc(5,0,"BREAL1","QBLOC.GLO")

//    if SH_QEFSA->Vlr_cont = 0.00
//       SH_QEFSA->(Dbskip())
//       loop
//    endif

      if ! SAI->(dbseek(SH_QEFSA->Num_nf + SH_QEFSA->Serie + alltrim(SH_QEFSA->Filial)))

         if SAI->(qappend())

            replace SAI->DATA_LANC  with SH_QEFSA->DATA_LANC
            replace SAI->FILIAL     with SH_QEFSA->FILIAL
            replace SAI->NUM_NF     with SH_QEFSA->NUM_NF
            replace SAI->ESPECIE    with SH_QEFSA->ESPECIE
            replace SAI->SERIE      with SH_QEFSA->SERIE
            replace SAI->DATA_EMIS  with SH_QEFSA->DATA_EMIS
            replace SAI->Estado     with SH_QEFSA->Estado
            replace SAI->VLR_CONT   with SH_QEFSA->VLR_CONT
            replace SAI->COD_CONT   with SH_QEFSA->COD_CONT
            replace SAI->COD_FISC   with SH_QEFSA->COD_FISC
            NATOP->(dbseek(SAI->Cod_fisc))
            replace SAI->Tipo_cont  with NATOP->Tip_cont
            replace SAI->ICM_BASE   with SH_QEFSA->ICM_BASE
            replace SAI->ICM_RED    with SH_QEFSA->ICM_RED
            replace SAI->ICM_ALIQ   with SH_QEFSA->ICM_ALIQ
            replace SAI->ICM_VLR    with SH_QEFSA->ICM_VLR
            replace SAI->ICM_ISEN   with SH_QEFSA->ICM_ISEN
            replace SAI->ICM_OUT    with SH_QEFSA->ICM_OUT
            replace SAI->ICM_COD    with SH_QEFSA->ICM_COD
            replace SAI->IPI_BASE   with SH_QEFSA->IPI_BASE
            replace SAI->IPI_VLR    with SH_QEFSA->IPI_VLR
            replace SAI->IPI_ISEN   with SH_QEFSA->IPI_ISEN
            replace SAI->IPI_OUT    with SH_QEFSA->IPI_OUT
            replace SAI->IPI_DESC   with SH_QEFSA->IPI_DESC
            replace SAI->OBS        with SH_QEFSA->OBS
            replace SAI->ICM_SUBST  with SH_QEFSA->ICM_SUBST
            replace SAI->ICM_BC_S   with SH_QEFSA->ICM_BC_S

            XNIVEL := 1

            qrsay(XNIVEL++,SH_QEFSA->FILIAL     )
            qrsay(XNIVEL++,SH_QEFSA->DATA_LANC  )
            qrsay(XNIVEL++,SH_QEFSA->NUM_NF     )
            qrsay(XNIVEL++,SH_QEFSA->ESPECIE    )
            qrsay(XNIVEL++,SH_QEFSA->SERIE      )
            qrsay(XNIVEL++,SH_QEFSA->DATA_EMIS  )
            qrsay(XNIVEL++,SPACE(5)             )
            qrsay(XNIVEL++,SPACE(5)             )
            qrsay(XNIVEL++,SH_QEFSA->COD_FISC   )
            qrsay(XNIVEL++,SH_QEFSA->COD_CONT   )
            qrsay(XNIVEL++,SH_QEFSA->VLR_CONT   )
            qrsay(XNIVEL++,SH_QEFSA->ICM_BASE   )
            qrsay(XNIVEL++,SH_QEFSA->ICM_RED    )
            qrsay(XNIVEL++,SH_QEFSA->ICM_ALIQ   )
            qrsay(XNIVEL++,SH_QEFSA->ICM_VLR    )
            qrsay(XNIVEL++,SH_QEFSA->ICM_ISEN   )
            qrsay(XNIVEL++,SH_QEFSA->ICM_OUT    )
            qrsay(XNIVEL++,SH_QEFSA->ICM_BC_S   )
            qrsay(XNIVEL++,SH_QEFSA->ICM_SUBST  )
            qrsay(XNIVEL++,SH_QEFSA->IPI_BASE   )
            qrsay(XNIVEL++,SH_QEFSA->IPI_VLR    )
            qrsay(XNIVEL++,SH_QEFSA->IPI_ISEN   )
            qrsay(XNIVEL++,SH_QEFSA->IPI_OUT    )
            qrsay(XNIVEL++,SH_QEFSA->IPI_DESC   )
            qrsay(XNIVEL++,SH_QEFSA->ICM_COD    )
            qrsay(XNIVEL++,SH_QEFSA->OBS        )

            SH_QEFSA->(dbdelete())

            SAI->(qunlock())

         endif
      else
         cNUM_NF := SH_QEFSA->Num_nf
         cSERIE  := SH_QEFSA->Serie
         cFILIAL := SH_QEFSA->Filial
         if SH_QEFSA->ICM_ALIQ <> 0
            Select OUTSAI
            if ! OUTSAI->(dbseek(cNUM_NF + cSERIE + cFILIAL ))
               if OUTSAI->(qappend())
                  replace OUTSAI->DATA_LANC  with SH_QEFSA->DATA_LANC
                  replace OUTSAI->NUM_NF     with SH_QEFSA->NUM_NF
                  replace OUTSAI->SERIE      with SH_QEFSA->SERIE
                  replace OUTSAI->FILIAL     with SH_QEFSA->FILIAL
                  replace OUTSAI->ICM_BASE   with SH_QEFSA->ICM_BASE
                  replace OUTSAI->ICM_ALIQ   with SH_QEFSA->ICM_ALIQ
                  replace OUTSAI->ICM_VLR    with SH_QEFSA->ICM_VLR
                  if SAI->(qrlock())
                     replace SAI->VLR_CONT      with (SAI->VLR_CONT + SH_QEFSA->ICM_BASE)
                     SAI->(qunlock())
                  endif
                  Select OUTSAI
                  OUTSAI->(qunlock())
                  Select SH_QEFSA
               endif
            endif
         endif
         SH_QEFSA->(dbdelete())
         SAI->(qunlock())
      endif

      SH_QEFSA->(dbskip())

   enddo

   SH_QEFSA->(__dbPack())

   SH_QEFSA->(dbclosearea())
   SAI->(dbclosearea())
   OUTSAI->(dbclosearea())
   CONFIG->(dbclosearea())
   NATOP->(dbclosearea())

   dbunlockall()
   qmensa("")
   qrbloc(5,0,sTELA)

return

static function xmlImport
local aDir := {}
local nCONT := 0
local nPos  := 0
local nSize := 0
local nFile := 0
local XDRV_XML := "C:\QSYSTXT\E"+XEMPRESA+"\"
local cBuffer := ""
local cTeste := space(100)


   aDir := directory(XDRV_XML+"*.XML",NIL)


   for nCONT := 1 to len(aDir)
       cNome := aDir[nCont,1]
       nFile := fopen(XDRV_XML+cNome,2)

       alert(cNome)

       if ferror() != 0
          alert("Erro de abertura de arquivo! Erro: "+str(fError(),2))
          exit
       endif

       nSize := fseek(nFile,0,2)
       cBuffer := space(nSize)
       fseek(nFile,0)
       fread(nFile,@cBuffer,nSize)
       nPos := at("<dest>",cBuffer)
       fseek(nFile,nPos,0)
       fread(nFile,@cTeste,100)
       alert(cTeste)
       fClose(nFile)



   next


return

