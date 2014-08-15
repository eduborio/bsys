/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE CONTAS A PAGAR
// OBJETIVO...: INTERFACE COM FATURAMENTO
// ANALISTA...: IN SUNG CHANG
// PROGRAMADOR: IN SUNG CHANG
// INICIO.....: 01/11/96
// OBS........:
function realtime

local nDRIVE := space(2)

// ARQUIVO CONFIG.DBF PARA NUMERACAO DE LANCAMENTOS _________________________

if ! quse(XDRV_PG,"CONFIG",NIL)
   return
endif

i_interface()  // interface com o sistema de compras

// ARQUIVO SH_FAREC DO FATURAMENTO QSYS_G EM MODO EXCLUSIVO __________________

do case
   case CONFIG->Tipo_fat == "1"
        nDRIVE := "FS"  // faturamento servicos
   case CONFIG->Tipo_fat == "2"
        nDRIVE := "TR"  // faturamento transportes
   case CONFIG->Tipo_fat == "3"
        nDRIVE := "EB"  // faturamento contas a pagar <QEB>
   case CONFIG->Tipo_fat == "4"
        CONFIG->(dbclosearea())
        return // nao faz absolutamente nada
endcase

if ! quse(&("XDRV_"+ nDRIVE),"SH_FAPAG",NIL,"E")
   alert("Configure a op‡„o 801, para tipo de faturamento <NENHUM>, o seu sistema n„o realiza interface com faturamento ! ")
   CONFIG->(dbclosearea())
   return
endif

SH_FAPAG->(__dbPack())

if SH_FAPAG->(eof())
   SH_FAPAG->(dbclosearea())
   CONFIG->(dbclosearea())
   return
endif

do case
   case CONFIG->Tipo_fat == "1"
        servicos()
   case CONFIG->Tipo_fat == "2"
        transportes()
   case CONFIG->Tipo_fat == "3"
        est_industria()
   case CONFIG->Tipo_fat == "4"
        CONFIG->(dbclosearea())
        return // nao faz absolutamente nada
endcase

return

////////////////////////////////////////////////////////////////////////
// funcao para realizar interface com faturamento de servicos___________

function servicos

   private nCOD_LCTO := CONFIG->Cod_lcto

   // ARQUIVO LACTOS.DBF DO QPG ___________________________________________________

   if ! quse(XDRV_PG,"LACTOS",{"LCT_COD"},NIL)
      qmensa("N„o foi poss¡vel abrir arquivo LACTOS.DBF !! Tente novamente.")
      SH_FAPAG->(dbclosearea())
      CONFIG->(Dbclosearea())
      return
   endif

   // CARREGA BLOCO REALTIME.RRB _______________________________________________

   sTELA := qsbloc(05,00,23,79)
   qlbloc(7,5,"BREAL","QBLOC.GLO")

   //////////////////////////////////////////////////////////////////////////////
   // EXECUTA INTERFACE ________________________________________________________

      do while ! SH_FAPAG->(eof())

         if LACTOS->(qappend())

            replace LACTOS->Codigo     with strzero( nCOD_LCTO:= nCOD_LCTO + 1 , 5 )
            replace LACTOS->Data_lanc  with XDATASYS
            replace LACTOS->Cod_desp   with SH_FAPAG->Cod_desp
            replace LACTOS->Valor      with SH_FAPAG->Valor
            replace LACTOS->Vencto     with SH_FAPAG->Vencto

            XNIVEL := 1

            qrsay(XNIVEL++,LACTOS->Codigo)
            qrsay(XNIVEL++,dtoc(LACTOS->Data_lanc))
            qrsay(XNIVEL++,LACTOS->Cod_desp)
            qrsay(XNIVEL++,LACTOS->Valor,"@E 999,999,999.99")
            qrsay(XNIVEL++,dtoc(LACTOS->Vencto))

            SH_FAPAG->(dbdelete())

            LACTOS->(qunlock())

         endif

         SH_FAPAG->(dbskip())

      enddo

      if CONFIG->(qrlock())
         replace CONFIG->Cod_lcto with nCOD_LCTO
         CONFIG->(qunlock())
      endif

      SH_FAPAG->(dbclosearea())
      LACTOS->(dbclosearea())
      CONFIG->(dbclosearea())

      qrbloc(5,0,sTELA)

return

////////////////////////////////////////////////////////////////////////
// funcao para realizar interface com faturamento de transportes _______

function transportes

   private nCOD_TERC := CONFIG->Cod_terc

   // ARQUIVO LCTO_TER.DBF DO QPG ______________________________________

   if ! quse(XDRV_PG,"LCTO_TER",{"TERP_COD"},NIL)
      qmensa("N„o foi poss¡vel abrir arquivo LCTO_TER.DBF !! Tente novamente.")
      SH_FAPAG->(dbclosearea())
      CONFIG->(Dbclosearea())
      return
   endif


   // CARREGA BLOCO REALTIME.RRB _______________________________________________

   sTELA := qsbloc(05,00,23,79)
   qlbloc(7,3,"BREAL1","QBLOC.GLO")

   //////////////////////////////////////////////////////////////////////////////
   // EXECUTA INTERFACE ________________________________________________________

      do while ! SH_FAPAG->(eof())

         if LCTO_TER->(qappend())

            replace LCTO_TER->Codigo     with strzero( nCOD_TERC:= nCOD_TERC + 1 , 5 )
            replace LCTO_TER->Nr_af      with SH_FAPAG->Nr_af
            replace LCTO_TER->Conhe_nr   with SH_FAPAG->Conhe_nr
            replace LCTO_TER->Valor_dup  with SH_FAPAG->Valor_dup
            replace LCTO_TER->Data_Vcto  with SH_FAPAG->Data_vcto
            replace LCTO_TER->Cod_terc   with SH_FAPAG->Cod_terc
            replace LCTO_TER->Data_emiss with SH_FAPAG->Data_emiss
            replace LCTO_TER->Aliquota   with SH_FAPAG->Aliquota
            replace LCTO_TER->Valor_terc with SH_FAPAG->Valor_terc
            replace LCTO_TER->Fr_numero  with SH_FAPAG->Fr_numero

            XNIVEL := 1

            qrsay(XNIVEL++,LCTO_TER->Codigo)
            qrsay(XNIVEL++,LCTO_TER->Nr_af)
            qrsay(XNIVEL++,LCTO_TER->Conhe_nr)
            qrsay(XNIVEL++,LCTO_TER->Valor_dup,"@E 9,999,999.99")
            qrsay(XNIVEL++,dtoc(LCTO_TER->Data_vcto))
            qrsay(XNIVEL++,LCTO_TER->Cod_terc)
            qrsay(XNIVEL++,dtoc(LCTO_TER->Data_emiss))
            qrsay(XNIVEL++,LCTO_TER->Aliquota,"@e 99.99")
            qrsay(XNIVEL++,LCTO_TER->Valor_terc,"@E 999,999,999.99")
            qrsay(XNIVEL++,LCTO_TER->Fr_numero,"@R 999999")

            SH_FAPAG->(dbdelete())

            LCTO_TER->(qunlock())

         endif

         SH_FAPAG->(dbskip())

      enddo

      if CONFIG->(qrlock())
         replace CONFIG->Cod_terc with nCOD_TERC
         CONFIG->(qunlock())
      endif

      SH_FAPAG->(dbclosearea())
      LCTO_TER->(dbclosearea())
      CONFIG->(dbclosearea())

      qrbloc(5,0,sTELA)

return

//////////////////////////////////////////////////////////////////////////
function i_interface

   private nCOD_PAG := CONFIG->Cod_pag

   // ARQUIVO SH_APCOM.DBF DO QCP ______________________________________

   if ! quse(XDRV_CP,"SH_APCOM",NIL,"E")
      qmensa("N„o foi poss¡vel abrir arquivo SH_APCOM.DBF !! Tente novamente.")
      SH_APCOM->(dbclosearea())
      return
   endif

   if ! quse(XDRV_PG,"PAGAR",{"PA_CODIG","PA_VENC","PA_FORN","PA_VALOR","PA_DUP","PA_AGRUP","PA_DTVEI","PA_FIFOD","PA_DTVFO","PAG_DESC","PAG_FRVC"},NIL)
      qmensa("N„o foi poss¡vel abrir arquivo PAGAR.DBF !! Tente novamente.")
      SH_APCOM->(dbclosearea())
      return
   endif

   SH_APCOM->(__dbPack())

   // CARREGA BLOCO REALTIME.RRB _______________________________________________

   sTELA := qsbloc(05,00,23,79)
   qlbloc(10,5,"BREAL2","QBLOC.GLO")

   //////////////////////////////////////////////////////////////////////////////
   // EXECUTA INTERFACE ________________________________________________________

      do while ! SH_APCOM->(eof())

         if PAGAR->(qappend())
            nCOD_PAG++
            replace PAGAR->Codigo       with strzero( nCOD_PAG,7 )
            replace PAGAR->Data_lanc    with SH_APCOM->Data_lanc
            replace PAGAR->Cod_forn     with SH_APCOM->Cod_forn
            replace PAGAR->Centro       with left(SH_APCOM->Centro,4)
            replace PAGAR->Filial       with left(SH_APCOM->Filial,4)
            replace PAGAR->Data_emiss   with SH_APCOM->Data_emiss
            replace PAGAR->Especie      with SH_APCOM->Especie
            replace PAGAR->Serie        with SH_APCOM->Serie
            replace PAGAR->Tipo_sub     with SH_APCOM->Tipo_sub
            replace PAGAR->Historico    with left(SH_APCOM->Historico,80)

            replace PAGAR->Data_venc    with SH_APCOM->Data_venc
            replace PAGAR->Valor        with SH_APCOM->Valor
            replace PAGAR->Valor_liq    with SH_APCOM->Valor_liq

            replace PAGAR->Fatura       with SH_APCOM->Fatura
            replace PAGAR->Duplicata    with SH_APCOM->Fatura
            replace PAGAR->Cgm          with SH_APCOM->Cgm
            replace PAGAR->Cod_veic     with SH_APCOM->Cod_veic
            replace PAGAR->Cod_eqpto    with SH_APCOM->Cod_eqpto
            replace PAGAR->Fornec       with SH_APCOM->Fornec
            replace PAGAR->Previsao     with "N"
            replace PAGAR->Contabil     with .T.
            replace PAGAR->PedComp      with SH_APCOM->Pedcomp
            replace PAGAR->Cod_plan     with SH_APCOM->cod_plan

            XNIVEL := 1

            qrsay(XNIVEL++,PAGAR->Codigo)
            qrsay(XNIVEL++,PAGAR->Fatura)
            qrsay(XNIVEL++,PAGAR->Valor,"@E 9,999,999.99")
            qrsay(XNIVEL++,dtoc(PAGAR->Data_venc))
            qrsay(XNIVEL++,dtoc(PAGAR->Data_emiss))

            SH_APCOM->(dbdelete())

            PAGAR->(qunlock())

         endif

         SH_APCOM->(dbskip())

      enddo

      if CONFIG->(qrlock())
         replace CONFIG->Cod_pag with nCOD_PAG
         CONFIG->(qunlock())
      endif

      PAGAR->(dbclosearea())
      SH_APCOM->(dbclosearea())

      qrbloc(5,0,sTELA)

return

//////////////////////////////////////////////////////////////////////////
// funcao para realizar interface com a industria <QEB>
function est_industria

   private nCOD_PAG := CONFIG->Cod_pag

 // ARQUIVO SH_FAPAG.DBF DO <QEB> ______________________________________

   if ! quse(XDRV_PG,"PAGAR",{"PA_CODIG","PA_VENC","PA_FORN","PA_VALOR","PA_DUP","PA_AGRUP","PA_DTVEI","PA_FIFOD","PA_DTVFO","PAG_DESC"},NIL)
      qmensa("N„o foi poss¡vel abrir arquivo PAGAR.DBF !! Tente novamente.")
      SH_FAPAG->(dbclosearea())
      return
   endif

   SH_FAPAG->(__dbPack())

   // CARREGA BLOCO REALTIME.RRB _______________________________________________

   sTELA := qsbloc(05,00,23,79)
   qlbloc(10,5,"BREAL2","QBLOC.GLO")

   //////////////////////////////////////////////////////////////////////////////
   // EXECUTA INTERFACE ________________________________________________________

      do while ! SH_FAPAG->(eof())

         if PAGAR->(qappend())

            replace PAGAR->Codigo       with strzero( nCOD_PAG := nCOD_PAG + 1 ,7 )
            replace PAGAR->Data_lanc    with SH_FAPAG->Data_lanc
            replace PAGAR->Cod_forn     with SH_FAPAG->Cod_forn
            replace PAGAR->Centro       with left(SH_FAPAG->Centro,4)
            replace PAGAR->Filial       with left(SH_FAPAG->Filial,4)
            replace PAGAR->Data_emiss   with SH_FAPAG->Data_emiss
            replace PAGAR->Dt_contabi   with SH_FAPAG->Data_emiss
            replace PAGAR->Especie      with SH_FAPAG->Especie
            replace PAGAR->Serie        with SH_FAPAG->Serie
            replace PAGAR->Tipo_sub     with SH_FAPAG->Tipo_sub
            replace PAGAR->Historico    with left(SH_FAPAG->Historico,80)

            replace PAGAR->Data_venc    with SH_FAPAG->Data_venc
            replace PAGAR->Valor        with SH_FAPAG->Valor
            replace PAGAR->Valor_liq    with SH_FAPAG->Valor_liq

            replace PAGAR->Fatura       with SH_FAPAG->Fatura
            replace PAGAR->Cgm          with SH_FAPAG->Cgm
            replace PAGAR->Cod_veic     with SH_FAPAG->Cod_veic
            replace PAGAR->Cod_eqpto    with SH_FAPAG->Cod_eqpto

            XNIVEL := 1

            qrsay(XNIVEL++,PAGAR->Codigo)
            qrsay(XNIVEL++,PAGAR->Fatura)
            qrsay(XNIVEL++,PAGAR->Valor,"@E 9,999,999.99")
            qrsay(XNIVEL++,dtoc(PAGAR->Data_venc))
            qrsay(XNIVEL++,dtoc(PAGAR->Data_emiss))

            SH_FAPAG->(dbdelete())

            PAGAR->(qunlock())

         endif

         SH_FAPAG->(dbskip())

      enddo

      if CONFIG->(qrlock())
         replace CONFIG->Cod_pag with nCOD_PAG
         CONFIG->(qunlock())
      endif

      PAGAR->(dbclosearea())
      SH_FAPAG->(dbclosearea())
      CONFIG->(dbclosearea())

      qrbloc(5,0,sTELA)

return
