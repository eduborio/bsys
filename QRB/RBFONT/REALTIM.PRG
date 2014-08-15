/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE CONTAS A RECEBER
// OBJETIVO...: INTERFACE COM FATURAMENTO
// ANALISTA...: IN SUNG CHANG
// PROGRAMADOR: IN SUNG CHANG
// INICIO.....: 01/11/96
// OBS........:

function realtime

local nDRIVE := space(2)

if ! quse( XDRV_RB ,"CONFIG",NIL)
   qmensa("N„o foi poss¡vel abrir arquivo CONFIG.DBF !! Tente novamente.")
   return
endif

private nCOD_REC := CONFIG->Cod_rec

//////////////////////////////////////////////////////////////////////////////
// ARQUIVO SH_FAREC DO FATURAMENTO QSYS_G EM MODO EXCLUSIVO __________________

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
           nDRIVE := "EB"  // faturamento de INDUSTRIA <QEB>
   endcase

   if ! quse(&("XDRV_" + nDRIVE) , "SH_FAREC",iif(CONFIG->Tipo_fat == "3",{"REC_CONT"},),"E") // Abre indice somente no faturamento de servico
      qmensa("N„o foi poss¡vel abrir arquivo SH_FAREC.DBF !! Tente novamente.")
      return
   endif

   //SH_FAREC->(__dbPack())

// ARQUIVO RECEBER.DBF DO QRB ___________________________________________________

if ! quse(XDRV_RB,"RECEBER",{"REC_COD","REC_VENC","REC_DUP","REC_DTEM","REC_CLIE","REC_LIQ","REC_BANC","REC_CLRZ","REC_CDCL","RB_DTVCL","REC_FATU","RECCLIVC"})
   qmensa("N„o foi poss¡vel abrir arquivo RECEBER.DBF !! Tente novamente.")
   return
endif

// CARREGA BLOCO REALTIME.RRB _______________________________________________

sTELA := qsbloc(05,00,23,79)
qlbloc(5,0,"BREAL","QBLOC.GLO")

//////////////////////////////////////////////////////////////////////////////
// EXECUTA INTERFACE ________________________________________________________

   do while ! SH_FAREC->(eof())

      if RECEBER->(qappend())

         replace RECEBER->Codigo     with strzero(nCOD_REC := nCOD_REC + 1,7)
         replace RECEBER->Tipo_sub   with SH_FAREC->Tipo_cont
         replace RECEBER->Historico  with SH_FAREC->Historico
         replace RECEBER->Data_lanc  with SH_FAREC->Data_emiss
         replace RECEBER->Serie      with SH_FAREC->Serie
         replace RECEBER->Especie    with SH_FAREC->Especie
         replace RECEBER->Cod_cli    with SH_FAREC->Cod_cli
         replace RECEBER->Fatura     with SH_FAREC->Fatura
         replace RECEBER->Valor      with SH_FAREC->Valor
         replace RECEBER->Valor_liq  with SH_FAREC->Valor
         replace RECEBER->Data_venc  with SH_FAREC->Data_venc
         replace RECEBER->Data_emiss with SH_FAREC->Data_emiss
         replace RECEBER->Centro     with SH_FAREC->CCusto
         replace RECEBER->Filial     with SH_FAREC->Filial
         replace RECEBER->Situacao   with SH_FAREC->Cod_situa
         replace RECEBER->Tipo_doc   with SH_FAREC->Tipo_doc
         replace RECEBER->Cgm        with SH_FAREC->Cgm
         replace RECEBER->Cod_banco  with SH_FAREC->Cod_banco
         replace RECEBER->Data_cont  with SH_FAREC->Data_emiss
         replace RECEBER->Cliente    with SH_FAREC->Cliente
         replace RECEBER->Previsao   with "N"
         replace RECEBER->Contabil   with .T.

         if CONFIG->Tipo_fat == "3"  // faturamento de servicos
            replace RECEBER->Duplicata  with SH_FAREC->Contrato
         endif
         if CONFIG->Tipo_fat == "5" // faturamento de transportadora
            replace RECEBER->Duplicata  with SH_FAREC->Duplicata
         endif
         XNIVEL := 1

         qrsay(XNIVEL++,RECEBER->Codigo)
         qrsay(XNIVEL++,RECEBER->Data_lanc)
         qrsay(XNIVEL++,RECEBER->Cod_cli)
         qrsay(XNIVEL++,RECEBER->Centro)
         qrsay(XNIVEL++,RECEBER->Filial)
         qrsay(XNIVEL++,ctod(""))
         qrsay(XNIVEL++,RECEBER->Data_venc)
         qrsay(XNIVEL++,RECEBER->Tipo_sub)
         qrsay(XNIVEL++,left(RECEBER->Historico,43))
         qrsay(XNIVEL++,RECEBER->Valor,"@E 999,999,999.99")

         SH_FAREC->(dbdelete())

         RECEBER->(qunlock())

      endif

      SH_FAREC->(dbskip())

   enddo

   if CONFIG->(qrlock())
	  replace CONFIG->Cod_rec with nCOD_REC
      CONFIG->(qunlock())
   endif	  

   SH_FAREC->(dbclosearea())
   RECEBER->(dbclosearea())
   CONFIG->(dbclosearea())

   qrbloc(5,0,sTELA)

return
