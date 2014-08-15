
/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA CONTAS A PAGAR
// OBJETIVO...: CONSULTA DE VEICULOS
// ANALISTA...:
// PROGRAMADOR:
// INICIO.....: FEVEREIRO DE 1996
// OBS........:
// ALTERACOES.:

function pg303

VEICULOS->(qview({{"Codigo/C¢digo"                ,1},;
                  {"Descricao/Descri‡„o"          ,2},;
                  {"Placa/Placa"                  ,0},;
                  {"Fabricante/Fabricante"        ,0},;
                  {"Modelo/Modelo"                ,0},;
                  {"Ano/Ano"                      ,0},;
                  {"c303b()/Combustivel"          ,0},;
                  {"Placa/Placa"                  ,0}},"P",;
                  {NIL,"c303a",NIL,NIL},;
                   NIL,"<ESC> para Sair / <C>onsulta"))

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAR A DESCRICAO DO COMBUSTIVEL __________________________

function c303b
  COMBUSTI->(dbseek(VEICULOS->(Cod_comb)))
return left(COMBUSTI->Descricao,16)

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function c303a
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))
   if cOPCAO == "C"
      qlbloc(5,1,"B303A","QBLOC.GLO",1)
      i_edicao()
   endif
   setcursor(nCURSOR)
return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA ____________________________________

static function i_edicao

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"
      XNIVEL := 1
      qrsay ( XNIVEL++ , VEICULOS->Codigo     )
      qrsay ( XNIVEL++ , VEICULOS->Descricao  )
      qrsay ( XNIVEL++ , VEICULOS->Placa      )
      qrsay ( XNIVEL++ , VEICULOS->Patrimonio )
      qrsay ( XNIVEL++ , VEICULOS->Fabricante )
      qrsay ( XNIVEL++ , VEICULOS->Modelo     )
      qrsay ( XNIVEL++ , VEICULOS->Ano        )
      qrsay ( XNIVEL++ , VEICULOS->Cod_comb   ) ; COMBUSTI->(dbseek(VEICULOS->Cod_comb))

      qrsay ( XNIVEL++ , left(COMBUSTI->Descricao,16))
      qrsay ( XNIVEL++ , VEICULOS->Cod_Carroc ) ; TIPO_CAR->(dbseek(VEICULOS->Cod_Carroc))
      qrsay ( XNIVEL++ , left(TIPO_CAR->Descricao,16))

      qrsay ( XNIVEL++ , VEICULOS->Cores      )
      qrsay ( XNIVEL++ , VEICULOS->Chassi     )
      qrsay ( XNIVEL++ , VEICULOS->Chas_Serie )
      qrsay ( XNIVEL++ , VEICULOS->Centro     ) ; CCUSTO->(dbseek(VEICULOS->Centro))
      qrsay ( XNIVEL++ , CCUSTO->Descricao    )
      qrsay ( XNIVEL++ , VEICULOS->Filial     ) ; FILIAL->(dbseek(VEICULOS->Filial))
      qrsay ( XNIVEL++ , left(FILIAL->Razao,40)        )
      qrsay ( XNIVEL++ , VEICULOS->Concession )
      qrsay ( XNIVEL++ , VEICULOS->Cod_segura ) ; SEGURA->(dbseek(VEICULOS->Cod_segura))
      qrsay ( XNIVEL++ , left(SEGURA->Nome,22))
      qrsay ( XNIVEL++ , VEICULOS->Val_franq,"@e 999,999,999.99")
      qrsay ( XNIVEL++ , VEICULOS->Data_comp  )
      qrsay ( XNIVEL++ , VEICULOS->Doc_comp   )
      qrsay ( XNIVEL++ , VEICULOS->Val_comp,"@e 999,999,999.99")
      qrsay ( XNIVEL++ , VEICULOS->Mes_licenc )
      qrsay ( XNIVEL++ , VEICULOS->Mes_ipva   )
      qrsay ( XNIVEL++ , VEICULOS->Seg_obrig  )
      qrsay ( XNIVEL++ , VEICULOS->Unidade    )
      qrsay ( XNIVEL++ , VEICULOS->Cod_fun    ) ; FUN->(dbseek(VEICULOS->Cod_fun))
      qrsay ( XNIVEL++ , FUN->Nome            )
      qrsay ( XNIVEL++ , VEICULOS->Observacao )
      qrsay ( XNIVEL++ , VEICULOS->Tipo_motor )
      qrsay ( XNIVEL++ , VEICULOS->Tipo_cambi )
      qrsay ( XNIVEL++ , VEICULOS->Hp         )
      qrsay ( XNIVEL++ , VEICULOS->Tanque     )
      qrsay ( XNIVEL++ , VEICULOS->Tara       )
      qrsay ( XNIVEL++ , VEICULOS->Lotacao    )
      qrsay ( XNIVEL++ , VEICULOS->Tipo_Difer )
      qrsay ( XNIVEL++ , VEICULOS->Red_Difer  )
   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif

return

