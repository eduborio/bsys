/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE TESOURARIA
// OBJETIVO...: INTERFACE COM CONTAS A PAGAR / CONTAS A RECEBER
// ANALISTA...:
// PROGRAMADOR: LUCINEIDE VILAR POSSEBOM
// INICIO.....: DEZ/97
// OBS........:

function realtime

local nDRIVE := space(2)

if ! quse( XDRV_RB ,"SH_RECEB",{"RSH_DUPL"},"E")
   qmensa("N„o foi poss¡vel abrir arquivo SH_RECEB.DBF !! Tente novamente.")
   return
endif

if ! quse( XDRV_PG ,"SH_PAGAR",NIL,"E")
   qmensa("N„o foi poss¡vel abrir arquivo SH_PAGAR.DBF !! Tente novamente.")
   SH_RECEB->(dbclosearea())
   return
endif

// ARQUIVO REC_TESO.DBF DO QTS ___________________________________________________

if ! quse(XDRV_TS,"REC_TESO",{"REC_COD","REC_VENC","REC_CLI","REC_EMIS","REC_FATU","REC_DUPL","RCTS_CLR"})
   qmensa("N„o foi poss¡vel abrir arquivo REC_TESO.DBF !! Tente novamente.")
   return
endif

// ARQUIVO PAG_TESO.DBF DO QTS ___________________________________________________

if ! quse(XDRV_TS,"PAG_TESO",{"PAG_COD","PAG_VENC","PAG_VAL","PAG_EMVE","PAG_FATU","PAG_FORN","PGT_FODT"})
   qmensa("N„o foi poss¡vel abrir arquivo PAG_TESO.DBF !! Tente novamente.")
   return
endif

// CARREGA BLOCO REALTIME.RRB _______________________________________________

sTELA := qsbloc(05,00,23,79)
qlbloc(10,8,"BREAL","QBLOC.GLO")

//////////////////////////////////////////////////////////////////////////////
// EXECUTA INTERFACE ________________________________________________________

   do while ! SH_RECEB->(eof())

      if REC_TESO->(qappend())

         replace REC_TESO->Codigo     with SH_RECEB->Codigo
         replace REC_TESO->Data_lanc  with SH_RECEB->Data_lanc
         replace REC_TESO->Cod_cli    with SH_RECEB->Cod_cli
         replace REC_TESO->Centro     with SH_RECEB->Centro
         replace REC_TESO->Filial     with SH_RECEB->Filial
         replace REC_TESO->Data_emiss with SH_RECEB->Data_emiss
         replace REC_TESO->Especie    with SH_RECEB->Especie
         replace REC_TESO->Serie      with SH_RECEB->Serie
         replace REC_TESO->Tipo_sub   with SH_RECEB->Tipo_sub
         replace REC_TESO->Historico  with SH_RECEB->Historico
         replace REC_TESO->Data_venc  with SH_RECEB->Data_venc
         replace REC_TESO->Data_prorr with SH_RECEB->Data_prorr
         replace REC_TESO->Valor      with SH_RECEB->Valor
         replace REC_TESO->Valor_liq  with SH_RECEB->Valor_liq
         replace REC_TESO->Fatura     with SH_RECEB->Fatura
         replace REC_TESO->Num_titulo with SH_RECEB->Num_titulo
         replace REC_TESO->Cgm        with SH_RECEB->Cgm
         replace REC_TESO->Cod_banco  with SH_RECEB->Cod_banco
         replace REC_TESO->Situacao   with SH_RECEB->Situacao
         replace REC_TESO->Vendedor   with SH_RECEB->Vendedor
         replace REC_TESO->Dt_contabi with SH_RECEB->Dt_contabi
         replace REC_TESO->Cnab       with SH_RECEB->Cnab
         replace REC_TESO->Num_lote   with SH_RECEB->Num_lote
         replace REC_TESO->Form_pgto  with SH_RECEB->Form_pgto
         replace REC_TESO->Desc_valor with SH_RECEB->Desc_valor
         replace REC_TESO->Indice     with "01"
         replace REC_TESO->Periodo    with "C"
         replace REC_TESO->Nota_fisc  with subs(SH_RECEB->Fatura,2,8)
         replace REC_TESO->Duplicata  with SH_RECEB->Duplicata
         replace REC_TESO->Valor_1    with SH_RECEB->Valor_1
         replace REC_TESO->Valor_ded  with SH_RECEB->Valor_1
         replace REC_TESO->Valor_ind  with 1
         replace REC_TESO->Valor_cor  with 1
         replace REC_TESO->Grupo_p    with SH_RECEB->Cod_cli
         replace REC_TESO->Data_cont  with SH_RECEB->Data_cont
         replace REC_TESO->Libera_mat with SH_RECEB->Libera_mat
         replace REC_TESO->Libera_con with SH_RECEB->Libera_con
         replace REC_TESO->Libera_fin with SH_RECEB->Libera_fin
         replace REC_TESO->Doc_interf with SH_RECEB->Fatura
         replace REC_TESO->Tipo_doc   with SH_RECEB->Tipo_doc
         replace REC_TESO->Data_vhis  with SH_RECEB->Data_venc
         replace REC_TESO->Codbanco   with SH_RECEB->Codbanco
         replace REC_TESO->Bco_porta  with SH_RECEB->Bco_porta
         replace REC_TESO->Forma_port with SH_RECEB->Forma_port
         replace REC_TESO->Data       with SH_RECEB->Data
         replace REC_TESO->Status_tit with SH_RECEB->Status_tit
         replace REC_TESO->Data_pagto with SH_RECEB->Data_pagto
         replace REC_TESO->Cliente    with SH_RECEB->Cliente
         replace REC_TESO->Setor      with SH_RECEB->Setor
         replace REC_TESO->Observacao with SH_RECEB->Observacao

         XNIVEL := 1

         qrsay(XNIVEL++,SH_RECEB->Data_lanc)
         qrsay(XNIVEL++,SH_RECEB->Cod_cli)
         qrsay(XNIVEL++,SH_RECEB->Centro)
         qrsay(XNIVEL++,SH_RECEB->Filial)
         qrsay(XNIVEL++,SH_RECEB->Data_venc)
         qrsay(XNIVEL++,SH_RECEB->Tipo_sub)
         qrsay(XNIVEL++,SH_RECEB->Valor,"@E 999,999,999.99")

         if SH_RECEB->(qrlock())
            SH_RECEB->(dbdelete())
            SH_RECEB->(qunlock())
         endif

         REC_TESO->(qunlock())

      endif

      SH_RECEB->(dbskip())

   enddo

   do while ! SH_PAGAR->(eof())

      if PAG_TESO->(qappend())

         replace PAG_TESO->Codigo     with SH_PAGAR->Codigo
         replace PAG_TESO->Data_lanc  with SH_PAGAR->Data_lanc
         replace PAG_TESO->Cod_forn   with SH_PAGAR->Cod_forn
         replace PAG_TESO->Centro     with SH_PAGAR->Centro
         replace PAG_TESO->Filial     with SH_PAGAR->Filial
         replace PAG_TESO->Data_emiss with SH_PAGAR->Data_emiss
         replace PAG_TESO->Especie    with SH_PAGAR->Especie
         replace PAG_TESO->Serie      with SH_PAGAR->Serie
         replace PAG_TESO->Tipo_Sub   with SH_PAGAR->Tipo_Sub
         replace PAG_TESO->Historico  with SH_PAGAR->Historico
         replace PAG_TESO->Data_venc  with SH_PAGAR->Data_venc
         replace PAG_TESO->Data_prorr with SH_PAGAR->Data_prorr
         replace PAG_TESO->Valor      with SH_PAGAR->Valor
         replace PAG_TESO->Valor_liq  with SH_PAGAR->Valor_liq
         replace PAG_TESO->Fatura     with SH_PAGAR->Fatura
         replace PAG_TESO->Num_titulo with SH_PAGAR->Num_titulo
         replace PAG_TESO->Cgm        with SH_PAGAR->Cgm
         replace PAG_TESO->Cod_banco  with SH_PAGAR->Cod_banco
         replace PAG_TESO->Situacao   with SH_PAGAR->Situacao
         replace PAG_TESO->Data_cont  with SH_PAGAR->Dt_contabi
         replace PAG_TESO->Agrupado   with SH_PAGAR->Agrupado
         replace PAG_TESO->Fornec     with SH_PAGAR->Fornec
         replace PAG_TESO->PedComp    with SH_PAGAR->PedComp

         XNIVEL := 1

         qrsay(XNIVEL++,SH_PAGAR->Data_lanc)
         qrsay(XNIVEL++,SH_PAGAR->Cod_forn)
         qrsay(XNIVEL++,SH_PAGAR->Centro)
         qrsay(XNIVEL++,SH_PAGAR->Filial)
         qrsay(XNIVEL++,SH_PAGAR->Data_venc)
         qrsay(XNIVEL++,SH_PAGAR->Tipo_sub)
         qrsay(XNIVEL++,SH_PAGAR->Valor,"@E 999,999,999.99")

         if SH_PAGAR->(qrlock())
            SH_PAGAR->(dbdelete())
            SH_PAGAR->(Qunlock())
         endif

         PAG_TESO->(qunlock())

      endif

      SH_PAGAR->(dbskip())

   enddo

   SH_RECEB->(dbclosearea())
   REC_TESO->(dbclosearea())
   SH_PAGAR->(dbclosearea())
   PAG_TESO->(dbclosearea())

   qrbloc(5,0,sTELA)

return
