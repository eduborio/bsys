/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE COMPRAS
// OBJETIVO...: LIMPEZA DE PEDIDOS DO ARQUIVO MORTO
// ANALISTA...: EDUARDO BORIO
// PROGRAMADOR: EDUARDO BORIO
// INICIO.....: MAIO de 2006
// OBS........:
// ALTERACOES.:

function cp470

if Qconf("Confirma ConvsersÆo de Arquivos?")
   i_processa()
endif


static function i_processa
N_GRUPO->(Dbgotop())

While ! N_GRUPO->(eof())
   if PROD->(Qappend())
      replace PROD->Codigo with alltrim(N_GRUPO->Grp_code,2)
      replace PROD->Descricao with N_GRUPO->Grp_name
   endif
   N_GRUPO->(Dbskip())
enddo

While ! N_SUB->(eof())
   if PROD->(Qappend())
      replace PROD->Codigo with alltrim(N_SUB->Grp_code,2) + alltrim(N_SUB->Sub_code)
      replace PROD->Descricao with N_SUB->Sub_name
   endif
   N_SUB->(Dbskip())
enddo

While ! MATERIAL->(eof())
   if PROD->(Qappend())
      replace PROD->Codigo with alltrim(MATERIAL->Grp_code,2) + alltrim(MATERIAL->Sub_code)+strzero(MATERIAL->Mat_id,5)
      replace PROD->Descricao  with MATERIAL->Mat_name
      replace PROD->Preco_cust with MATERIAL->Mat_cost
      replace PROD->Unidade    with strzero(MATERIAL->Uni_id,3)
      replace PROD->Preco_alug with MATERIAL->Mat_loc
   endif
   MATERIAL->(Dbskip())
   qmensa(MATERIAL->Mat_name)
enddo

While ! UNI_NEO->(Eof())
   if UNIDADE->(qappend())
      replace UNIDADE->Codigo    with strzero(UNI_NEO->Uni_id,3)
      replace UNIDADE->Descricao with left(UNI_NEO->Uni_desc,50)
      replace UNIDADE->Sigla     with Left(UNI_NEO->Uni_desc,3)

   endif
   UNI_NEO->(Dbskip())
enddo

return

