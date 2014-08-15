
/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE CONTAS A PAGAR
// OBJETIVO...: CONSULTA DE FORNECEDOR
// ANALISTA...:
// PROGRAMADOR:
// INICIO.....: DEZEMBRO DE 1996
// OBS........:
// ALTERACOES.:

function cl307
AREA->(qview({{"Codigo/C¢digo"                ,1},;
              {"left(Descricao,47)/Descri‡„o" ,2},;
              {" /TOTAL"                ,0}},"P",;
              {NIL,"c307a",NIL,NIL},;
               NIL,"<ESC> para Sair / <C>onsulta"))

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function c307a
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))
   if cOPCAO == "C"
//      qlbloc(5,0,"B307A","QBLOC.GLO",1)
        i_busca_vend()
   endif
   setcursor(nCURSOR)
return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA ____________________________________

static function i_edicao

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"
      XNIVEL := 1
      qrsay ( XNIVEL++ , FORN->Codigo    )

      qrsay ( XNIVEL++ , fu_conv_cgccpf( FORN->Cgccpf ) )

      qrsay ( XNIVEL++ , FORN->Inscricao )
      qrsay ( XNIVEL++ , FORN->Razao     )
      qrsay ( XNIVEL++ , FORN->Fantasia  )

      qrsay ( XNIVEL++ , FORN->End_ent   )
      qrsay ( XNIVEL++ , FORN->Cgm_ent   ) ; CGM->(dbseek(FORN->Cgm_ent))
      qrsay ( XNIVEL++ , CGM->Municipio )
      qrsay ( XNIVEL++ , CGM->Estado    )
      qrsay ( XNIVEL++ , FORN->Cep_ent , "@R 99.999-999" )

      qrsay ( XNIVEL++ , FORN->End_cob   )
      qrsay ( XNIVEL++ , FORN->Cgm_cob   ) ; CGM->(dbseek(FORN->Cgm_cob))
      qrsay ( XNIVEL++ , CGM->Municipio )
      qrsay ( XNIVEL++ , CGM->Estado    )
      qrsay ( XNIVEL++ , FORN->Cep_cob , "@R 99.999-999" )

      qrsay ( XNIVEL++ , FORN->Fone1     )
      qrsay ( XNIVEL++ , FORN->Ramal1    )
      qrsay ( XNIVEL++ , FORN->Fone2     )
      qrsay ( XNIVEL++ , FORN->Ramal2    )
      qrsay ( XNIVEL++ , FORN->Fax       )
      qrsay ( XNIVEL++ , FORN->Foner     )
      qrsay ( XNIVEL++ , FORN->Contato_c )
      qrsay ( XNIVEL++ , FORN->Contato_f )
      qrsay ( XNIVEL++ , FORN->Filial    ) ; FILIAL->(dbseek(FORN->Filial))
      qrsay ( XNIVEL++ , left(Filial->Razao,48))
   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA RETORNAR N§ DE CLIENTES EM UMA AREA DE VENDA
function i_busca_vend

VEND->(qview({{"Codigo/C¢digo"                      ,1},;
              {"left(Nome,30)/Descri‡„o"            ,2},;
              {"c307c()/TOTAL"                      ,0}},"P",;
              {NIL,"c307a",NIL,NIL},;
               NIL,"<ESC> para Sair"))
 return

//////////////////////////////////////////////////////////////////
//FUNCAO PRA RETORNAR N§ DE CLIENTES E CADA VENDEDOR E SUA AREA

 function c307c

  local nTOTAL
  nTOTAL := 0
  CLI1->(dbgotop())
  do while ! CLI1->(eof())
     if CLI1->Cod_area == AREA->Codigo
        if CLI1->Cod_Vend == VEND->Codigo
           nTOTAL ++
        endif
     endif
      CLI1->(dbskip())
  enddo
 return nTOTAL
//////////////////////////////////////////////////////////////////
//FUNCAO PRA RETORNAR N§ DE CLIENTES E CADA VENDEDOR E SUA AREA

 function c307b

  local nTOTAL
  nTOTAL := 0
  CLI1->(dbgotop())
  do while ! CLI1->(eof())
     if CLI1->Cod_area == AREA->Codigo
           nTOTAL ++
     endif
      CLI1->(dbskip())
  enddo

return  nTOTAL

/////////////////////////////////////////////////////////////////
// funcao para retornar percentual de cada vendedor_____________

function c307d

  local nTOT_VEND
  local nTOT_GER
  local nPERC
  nTOT_VEND := 0
  nTOT_GER  := 0
  nPERC     := 0

  CLI1->(dbgotop())
  do while ! CLI1->(eof())
     if CLI1->Cod_area == AREA->Codigo
        if CLI1->Cod_Vend == VEND->Codigo
           nTOT_VEND++
        endif
        nTOT_GER++
     endif
      CLI1->(dbskip())
  enddo
  nPERC:= (nTOT_VEND * 100) / nTOT_GER
return  transf(nPERC,"@E 999.99")

