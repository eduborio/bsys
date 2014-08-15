/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: FATURAMENTO
// OBJETIVO...: CONVERSAO DO CAMPO FORNECEDOR
// ANALISTA...: EDUARDO BORIO
// PROGRAMADOR: O MESMO
// INICIO.....: NOVEMBRO DE 2003
// OBS........:
// ALTERACOES.:

function cp450

local nCONT := 0

if ! qconf("Confirma Convers„o dos Arquivos ?")
   return
endif

qmensa("Convertendo Registros dos Produtos... Aguarde")

PROD->(dbsetorder(1))
PROD->(dbgotop())
INVENT->(dbgotop())
LOTES->(dbgotop())
UNIDADE->(dbsetorder(2))
UNIDADE->(dbgotop())
CGM->(dbsetorder(2))
CGM->(dbgotop())
nCONT := 1

do while ! PD_001->(eof())

   qgirabarra()
   qmensa(PD_001->Descri_pro )

   if PROD->(qappend())
      replace PROD->Codigo       with left(PD_001->Codigo_pro,4) + strzero(nCONT,5)
      replace PROD->Cod_ass      with left(PD_001->Codigo_pro,7)
      replace PROD->Descricao    with PD_001->Descri_pro
      replace PROD->Desc2        with PD_001->Inform_pro
      UNIDADE->(dbseek(PD_001->Unidad_pro))
      replace PROD->Unidade       with UNIDADE->Codigo
      replace PROD->Preco_cust    with PD_001->Custo_pro
      replace PROD->Preco_cons    with PD_001->Venda_pro
      replace PROD->Prod_iss      with "N"
      replace PROD->Lista         with "S"
   endif

   if INVENT->(qappend())
      replace INVENT->Data        with ctod("21/11/2003")
      replace INVENT->Cod_prod    with strzero(nCONT,5)
      replace INVENT->Filial      with "0001"
      replace INVENT->Val_invent  with PD_001->Custo_pro
      replace INVENT->Preco_uni   with PD_001->Custo_pro
      replace INVENT->Quant_atu   with PD_001->Saldo_pro
      replace INVENT->Lote        with replicate("0",10)
   endif

   if LOTES->(qappend())
      replace LOTES->Data       with ctod("21/11/2003")
      replace LOTES->Produto    with strzero(nCONT,5)
      replace LOTES->Filial     with "0001"
      replace LOTES->Quantidade with PD_001->Saldo_pro
      replace LOTES->Num_lote   with replicate("0",10)
   endif

   PD_001->(dbskip())
   nCONT++
enddo

do while ! VD_001->(eof())
   qgirabarra()
   qmensa(VD_001->descri_ven )
   if VEND->(qappend())
      replace VEND->Codigo    with strzero(val(VD_001->codigo_ven),5)
      replace VEND->Nome      with VD_001->Descri_ven
      replace VEND->Comis     with VD_001->Comissao
   endif

   VD_001->(dbskip())

enddo

do while ! BDREG->(eof())
   qgirabarra()
   qmensa(BDREG->Dereg )
   if SETOR->(qappend())
      replace SETOR->Codigo    with strzero(BDREG->Cdreg,5)
      replace SETOR->Descricao with BDREG->Dereg
   endif

   BDREG->(dbskip())

enddo


do while ! FT_001->(eof())
   qgirabarra()
   qmensa(FT_001->Razsoc_cli )

   if CLI1->(qappend())
      replace CLI1->Codigo      with strzero(val(FT_001->Codcli_cli),5)
      replace CLI1->Razao       with FT_001->Razsoc_cli
      replace CLI1->Cgccpf      with qtiraponto(FT_001->codcgc_cli)
      replace CLI1->End_ent     with FT_001->Endere_cli
      CGM->(dbseek(FT_001->Cidade_cli))
      replace CLI1->Cgm_ent     with CGM->Codigo
      replace CLI1->Bairro_ent  with FT_001->Bairro_cli
      replace CLI1->Cep_ent     with FT_001->codcep_cli

      replace CLI1->End_cob     with FT_001->Endere_cli
      CGM->(dbseek(FT_001->Cidade_cli))
      replace CLI1->Cgm_cob     with CGM->Codigo
      replace CLI1->Bairro_cob  with FT_001->Bairro_cli
      replace CLI1->Cep_cob     with FT_001->codcep_cli
      replace CLI1->Inscricao   with FT_001->insest_cli
      replace CLI1->Fone1       With FT_001->Telefo_cli
      replace CLI1->Fax         With FT_001->Telfax_cli
      replace CLI1->Filial      with "0001"
      replace CLI1->Cod_vend    with strzero(val(FT_001->Codven_cli),5)
      replace CLI1->Cod_Setor       with strzero(FT_001->Codreg_cli,5)
   endif

   FT_001->(dbskip())
enddo


do while ! TR_001->(eof())
   qgirabarra()
   qmensa(TR_001->Descri_mot)

   if TRANSP->(qappend())
      replace TRANSP->Codigo    with strzero(val(TR_001->Codigo_mot),5)
      replace TRANSP->Razao     with TR_001->Descri_mot
      replace TRANSP->Endereco  with TR_001->Endere_mot
      CGM->(dbseek(TR_001->Cidade_mot))
      replace TRANSP->Cgm       with CGM->Codigo
      replace TRANSP->Fone1     with TR_001->Telefo_mot
      replace TRANSP->Fax       with TR_001->Telfax_mot
      replace TRANSP->Cgccpf    with TR_001->Codcgc_mot
      replace TRANSP->Inscricao with TR_001->Codins_mot
   endif


   TR_001->(dbskip())

enddo



do while ! NF_001->(eof())
   qgirabarra()
   qmensa(NF_001->Notafi_nf)

   if FAT->(qappend())
      replace FAT->Codigo     with strzero(val(NF_001->Numero_nf),5)
      replace FAT->Num_fatura with NF_001->Notafi_nf
      replace FAT->Dt_emissao with NF_001->Datemi_nf
      replace FAT->Dt_saida   with NF_001->Datemi_nf
      replace FAT->Cod_cfop   with NF_001->Natope_nf
      replace FAT->Cod_transp with strzero(val(NF_001->Codtra_nf),5)
      replace FAT->Cod_vended with strzero(val(NF_001->Codven_nf),5)

      replace FAT->Filial     with "0001"
      replace FAT->Linha1     with left(NF_001->Mensage_nf,40)
      replace FAT->Linha2     with left(NF_001->Mensag1_nf,40)
      replace FAT->Linha3     with left(NF_001->Mensag2_nf,40)
      replace FAT->Linha4     with left(NF_001->Mensag3_nf,40)
      replace FAT->Linha5     with left(NF_001->Mensag4_nf,40)
      replace FAT->Cod_cli    with strzero(val(NF_001->Codcli_nf),5)
      CLI1->(dbseek(FAT->Cod_cli))
      replace FAT->Cliente    with CLI1->Razao

      replace FAT->Desc_sn    with "N"
      replace FAT->Es         with "S"
      replace FAT->Interface  with .T.
      replace FAT->Fiscal     with .T.
      replace FAT->Contabil   with .T.
   endif


   NF_001->(dbskip())

enddo


PROD->(dbsetorder(3))
PROD->(dbgotop())

do while ! NF_002->(eof())
   qgirabarra()
   qmensa(NF_002->Codped_ite)

   if ITEN_FAT->(qappend())
      replace ITEN_FAT->Num_fat    with strzero(val(NF_002->Codped_ite),5)
      PROD->(dbseek(NF_002->Codpro_ite))
      replace ITEN_FAT->Cod_prod   with right(PROD->Codigo,5)
      replace ITEN_FAT->Quantidade with NF_002->Qtdpro_ite
      replace ITEN_FAT->Vl_unitar  with NF_002->Precou_ite
      replace ITEN_FAT->Calc_desc  with "N"
      replace ITEN_FAT->Icms_subst with "N"
      replace ITEN_FAT->Num_lote   with replicate("0",10)
      replace ITEN_FAT->Cod_sit    with "000"
   endif

   NF_002->(dbskip())

enddo
return
