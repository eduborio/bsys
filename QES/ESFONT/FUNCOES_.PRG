// PARAMETROS DO VIEW
// linha para o get
// coluna para o get
// campo a ser editado (@)
// picture
// expressao valid
// expressao when
// vetor para o browse
//  - sub-vetor: string indicando o campo / string indicando o cabecalho
//             : numero indicando a ordem de classificacao (order)
// string da area "C"entralizado, "P"arcial, "T"otal, "10122070"
// vetor de funcoes {enter,qualquer tecla,movimentacao,pesquisa}

// CODIGO E RAZAO DOS CLIENTES ______________________________________________


function funcoes

function view_cli ( LL , CC , XX )
      CLI1->(qview(LL,CC,@XX,"99999",NIL,.T.,NIL,{{"Razao/Raz„o",2},{"Codigo/C¢digo",1}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
return

function view_comp ( LL , CC , XX )
      COMPOSIC->(qview(LL,CC,@XX,"99999",NIL,.T.,NIL,{{"Descricao/Descri‡„o",2},{"Codigo/C¢digo",1}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
return

function view_requi ( LL , CC , XX )
   REQUISIC->(qview(LL,CC,@XX,"@!",NIL,.T.,NIL,{{"Codigo/C¢digo",1},{"Nr_os/Nr. O.S.",5}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
return


// VIEW PADRAO PARA O LOTE DO PRODUTO ______________________________________________

function view_lote ( LL , CC , XX )
   INVENT->(qview(LL,CC,@XX,"@R 9999999999",NIL,.T.,NIL,{{"Lote/Nr.Lote",1},{"Cod_prod/C¢d.Produto",4},{"Quant_atu/Saldo Atual",0},{"Filial/Filial",0}},"C",{"keyb(Lote)",NIL,NIL,NIL}))
return

// CODIGO E DESCRICAO DA OS  ________________________________________

function view_os( LL , CC , XX )
   OS->(qview(LL,CC,@XX,"@R 99999",NIL,.T.,NIL,{{"Codigo/C¢digo",1},{"Descricao/Descri‡„o",2}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
return

/////////////////////////////////////////////////////////////////////////////
// VIEW PADRAO PARA VENDEDOR ________________________________________________

function view_vend (XX,YY,ZZ)
   VEND->(qview(XX,YY,@ZZ,"999",NIL,.T.,NIL,{{"CODIGO/Codigo",1},{"Nome/Nome",2}},"C",{"keyb(CODIGO)",NIL,NIL,NIL}))
return

/////////////////////////////////////////////////////////////////////////////
// VIEW PADRAO PARA Projeto ________________________________________________

function view_proj (XX,YY,ZZ)
   PROJET->(qview(XX,YY,@ZZ,"99999",NIL,.T.,NIL,{{"CODIGO/Codigo",1},{"Descricao/Nome",2}},"C",{"keyb(CODIGO)",NIL,NIL,NIL}))
return


/////////////////////////////////////////////////////////////////////////////
// VIEW PADRAO PARA CENTRO DE CUSTO _________________________________________

function view_ccusto (XX,YY,ZZ)
   CCUSTO->(qview(XX,YY,@ZZ,"9999",NIL,.T.,NIL,{{"CODIGO",1},{"DESCRICAO/Descri‡„o",2}},"C",{"keyb(RIGHT(CODIGO,4))",NIL,NIL,NIL}))
return

function view_FILIAL (XX,YY,ZZ)
   FILIAL->(qview(XX,YY,@ZZ,"9999",NIL,.T.,NIL,{{"Codigo/Codigo",1},{"left(RAZAO,30)/Raz„o",2},{"busca_mun()/Municipio",0}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA BUSCAR MUNICIPIO NO CGM ______________________________________

function busca_mun
    CGM->(dbseek(FILIAL->Cgm))
return(CGM->Municipio)

/////////////////////////////////////////////////////////////////////////////
// VIEW PADRAO PARA NORMAS DE OPERACOES _____________________________________

function view_normas (XX,YY,ZZ)
   NOP_COMP->(qview(XX,YY,@ZZ,"99999",NIL,.T.,NIL,{{"Nome/Descri‡„o",2},{"Nop/C¢digo",1}},"C",{"keyb(left(Nop,5))",NIL,NIL,NIL}))
return

/////////////////////////////////////////////////////////////////////////////
// VIEW PADRAO PARA FUNCIONARIOS ____________________________________________

function view_fun (XX,YY,ZZ)
   FUN->(qview(XX,YY,@ZZ,"999999",NIL,.T.,NIL,{{"Matricula/Matr¡cula",1},{"left(Nome,30)/Nome",2}},"C",{"Keyb(left(Matricula,6))",NIL,NIL,NIL}))
return

/////////////////////////////////////////////////////////////////////////////
// VIEW PADRAO PARA FUNCIONARIOS ____________________________________________

function view_comprador (XX,YY,ZZ)
   CAD_COMP->(qview(XX,YY,@ZZ,"99999",NIL,.T.,NIL,{{"Codigo/C¢digo",1},{"Nome/Nome",3}},"C",{"Keyb(left(Codigo,5))",NIL,NIL,NIL}))
return

/////////////////////////////////////////////////////////////////////////////
// VIEW PADRAO PARA UNIDADES ________________________________________________

function view_uni (XX,YY,ZZ)
   UNIDADE->(qview(XX,YY,@ZZ,"999",NIL,.T.,NIL,{{"Sigla/Sigla",2},{"Codigo/C¢digo",1},{"Fator/Fator",0},{"Uni_fat()/Sig. Fat.",0}},"C",{"Keyb(left(Codigo,3))",NIL,NIL,NIL}))
return

/////////////////////////////////////////////////////////////////////////////
// RETORNA SIGLA DA UNIDAE __________________________________________________

function uni_fat

   local nREC := UNIDADE->(recno())
   local nORD := UNIDADE->(indexord())
   local cDESCRICAO

   UNIDADE->(dbsetorder(1))
   UNIDADE->(dbseek(UNIDADE->Cod_uni))
   cDESCRICAO := UNIDADE->Sigla
   UNIDADE->(dbsetorder(nORD))
   UNIDADE->(dbgoto(nREC))

return cDESCRICAO

/////////////////////////////////////////////////////////////////////////////
// CODIGO E DESCRICAO DO PRODUTO ____________________________________________

function view_prod ( LL , CC , XX )
   PROD->(qview(LL,CC,@XX,"99999",NIL,.T.,NIL,{{"Cod_fabr/Ref.",5},{"Cod_Ass/Cod.",3},{"Descricao/Produto",2},{"Marca/Marca",0}  },"C",{"keyb(right(Codigo,5))",NIL,NIL,NIL}))
return

function view_prod1 ( LL , CC , XX )
   PROD->(qview(LL,CC,@XX,"99999",NIL,.T.,NIL,{{"Descricao/Produto",2},{"Right(Codigo,5)/Codigo",4}  },"C",{"keyb(right(Codigo,5))",NIL,NIL,NIL}))
return



/////////////////////////////////////////////////////////////////////////////
// CODIGO E DESCRICAO DO PRODUTO ____________________________________________

function view_proda ( LL , CC , XX )
   PROD->(qview(LL,CC,@XX,"999999999",NIL,.T.,NIL,{{"Codigo/C¢digo",1},{"Descricao/Produto",2}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
return

/////////////////////////////////////////////////////////////////////////////
// VIEW PADRAO PARA TIPORPC ________________________________________________

function view_tipocont (XX,YY,ZZ)
   TIPOCONT->(qview(XX,YY,@ZZ,"@R 999999",NIL,.T.,NIL,{{"Codigo/C¢digo",1},{"Descricao/Descri‡„o",2}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
return

/////////////////////////////////////////////////////////////////////////////
// VIEW PADRAO PARA VEICULOS ________________________________________________

function view_veic ( LL , CC , XX )
   VEICULOS->(qview(LL,CC,@XX,"@R 99999",NIL,.T.,NIL,{{"Codigo/C¢digo",1},{"Descricao/Descricao",2}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
return

/////////////////////////////////////////////////////////////////////////////
// VIEW PADRAO PARA EQUIPAMENTOS ____________________________________________

function view_equip ( LL , CC , XX )
   EQUIPTO->(qview(LL,CC,@XX,"@R 99999",NIL,.T.,NIL,{{"Codigo/C¢digo",1},{"Descricao/Descricao",2}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
return

/////////////////////////////////////////////////////////////////////////////
// FORMATA CGC OU CPF _______________________________________________________

function fu_conv_cgccpf ( cCGC )

   local nLENG := len(alltrim(cCGC))
   local cRET  := cCGC

   do case
      case nLENG == 14 ; cRET := transform(cCGC,"@R 99.999.999/9999-99")
      case nLENG == 11 ; cRET := transform(cCGC,"@R 999.999.999-99")
   endcase

return padl(cRET,18)

// CODIGO E DESCRICAO DO FORNECEDOR DA MERCADORIA _____________________________

function view_forn ( LL , CC , XX )
   FORN->(qview(LL,CC,@XX,"@R 99999",NIL,.T.,NIL,{{"Razao/Raz„o",2},;
                                                  {"Codigo/C¢digo",1}},;
                                                  "C",;
                                                  {"keyb(Codigo)","i_alt_forn",NIL,NIL},;
                                                  NIL,;
                                                  "<ESC>/ALT-O/ALT-P/<A>ltera"))
return

// CODIGO E DESCRICAO DA NATUREZA DE OPERACAO _________________________________

function view_natop( LL , CC , XX )
   NATOP->(qview(LL,CC,@XX,"@R 9.99",NIL,.T.,NIL,{{"Nat_Cod/C¢digo",1},{"Nat_Desc/Descri‡„o",2}},"C",{"keyb(Nat_Cod)",NIL,NIL,NIL}))
return

// CODIGO E DESCRICAO DA SERIE ________________________________________________

function view_serie ( LL , CC , XX )
   SERIE->(qview(LL,CC,@XX,"@R 99",NIL,.T.,NIL,{{"Codigo/C¢digo",1},{"Descricao/Descri‡„o",2}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
return

// CODIGO E DESCRICAO DA ESPECIE ______________________________________________

function view_especie ( LL , CC , XX )
   ESPECIE->(qview(LL,CC,@XX,"@R 99",NIL,.T.,NIL,{{"Codigo/C¢digo",1},{"Descricao/Descri‡„o",2}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
return

// CODIGO E DESCRICAO DOS MUNICIPIOS __________________________________________

function view_cgm ( LL , CC , XX )
   CGM->(qview(LL,CC,@XX,"@R 999999",NIL,.T.,NIL,{{"Codigo/C¢digo",1},{"Municipio/Municipio",2}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
return

/////////////////////////////////////////////////////////////////////////////
// ABRE ARQUIVO SH_APCOM P/ INTERFACE COM PAGAR (INTERQ.) ___________________

function fu_abre_apcom
   if ! quse(XDRV_CP,"SH_APCOM")
      qmensa("N„o foi possivel abrir SH_APCOM.DBF !","B")
      return .F.
   endif
return .T.

/////////////////////////////////////////////////////////////////////////////
// ABRE ARQUIVO SH_CONTA P/ INTERFACE COM CONTABIL (Q-SYS) __________________

function fu_abre_conta
   if ! quse(XDRV_TS,"SH_CONTA",{"SH_CONTA"})
      qmensa("N„o foi possivel abrir SH_CONTA.DBF !","B")
      return .F.
   endif
return .T.

/////////////////////////////////////////////////////////////////////////////
// ABRE ARQUIVO SH_CPEST P/ INTERFACE COM ESTOQUE (Q-SYS) ___________________

function fu_abre_cpest
   if ! quse(XDRV_CP,"SH_CPEST")
      qmensa("N„o foi possivel abrir SH_CPEST.DBF !","B")
      return .F.
   endif
return .T.

/////////////////////////////////////////////////////////////////////////////
// ABRE ARQUIVO SH_FICOM P/ INTERFACE COM FISCAL (Q-SYS) ___________________

function fu_abre_ficom
   if ! quse(XDRV_CP,"SH_FICOM")
      qmensa("N„o foi possivel abrir SH_FICOM.DBF !","B")
      return .F.
   endif
return .T.


/////////////////////////////////////////////////////////////////////////////
// ABRE ARQUIVO SH_PROCT P/ INTERFACE COM CONTABILIDADE (Q-SYS) ____________

function fu_abre_prov
   if ! quse(XDRV_CT,"SH_PROCT")
      qmensa("N„o foi possivel abrir SH_PROCT.DBF !","B")
      return .F.
   endif
return .T.

/////////////////////////////////////////////////////////////////////////////
// ABRE ARQUIVO CLI1 DO FATURAMENTO RESPECTIVO DE USO DA EMPRESA ____________

function fu_abre_cli1

   do case
      case CONFIG->Tipo_fat == "1"
           if ! quse(XDRV_CL , "CLI1",{"CL1CODIG","CL1RAZAO","CL1CGC"})
              qmensa("N„o foi poss¡vel abrir arquivo CLI1.DBF !! Tente novamente.")
              return
           endif
      case CONFIG->Tipo_fat == "2"
           if ! quse(XDRV_IN , "CLI1",{"CL1CODIG","CL1RAZAO","CL1CGC"})
              qmensa("N„o foi poss¡vel abrir arquivo CLI1.DBF !! Tente novamente.")
              return
           endif
      case CONFIG->Tipo_fat == "3"
           if ! quse(XDRV_SE , "CLI1",{"CL1CODIG","CL1RAZAO","CL1CGC"})
              qmensa("N„o foi poss¡vel abrir arquivo CLI1.DBF !! Tente novamente.")
              return
           endif
      case CONFIG->Tipo_fat == "4" // tele-vendas na PAPYRUS, puxa o arquivo do faturamento da fabrica
           if ! quse(XDRV_FA , "CLI1",{"CL1CODIG","CL1RAZAO","CL1CGC","CL1REPRE"})
              qmensa("N„o foi poss¡vel abrir arquivo CLI1.DBF !! Tente novamente.")
              return
           endif
      case CONFIG->Tipo_fat == "5"
           if ! quse(XDRV_TR , "CLI1",{"CL1CODIG","CL1RAZAO","CL1CGC"})
              qmensa("N„o foi poss¡vel abrir arquivo CLI1.DBF !! Tente novamente.")
              return
           endif
      case CONFIG->Tipo_fat == "6"
           if ! quse(XDRV_FU , "CLI1",{"CL1CODIG","CL1RAZAO","CL1CGC"})
              qmensa("N„o foi poss¡vel abrir arquivo CLI1.DBF !! Tente novamente.")
              return
           endif
      case CONFIG->Tipo_fat == "7" // faturamento de loja na PAPYRUS, puxa o arquivo do faturamento da fabrica
           if ! quse(XDRV_FA , "CLI1",{"CL1CODIG","CL1RAZAO","CL1CGC","CL1REPRE"})
              qmensa("N„o foi poss¡vel abrir arquivo CLI1.DBF !! Tente novamente.")
              return
           endif
      case CONFIG->Tipo_fat == "8"
           if ! quse(XDRV_SA, "CLI1",{"CL1CODIG","CL1RAZAO","CL1CGC"})
              qmensa("N„o foi poss¡vel abrir arquivo CLI1.DBF !! Tente novamente.")
              return
           endif
      case CONFIG->Tipo_fat == "9"
           if ! quse(XDRV_FA, "CLI1",{"CL1CODIG","CL1RAZAO","CL1CGC"})
              qmensa("N„o foi poss¡vel abrir arquivo CLI1.DBF !! Tente novamente.")
              return
           endif
      case CONFIG->Tipo_fat == "A"
           if ! quse(XDRV_FU, "CLI1",{"CL1CODIG","CL1RAZAO","CL1CGC","CL1ENDER","CL1INSCR"})
              qmensa("N„o foi poss¡vel abrir arquivo CLI1.DBF !! Tente novamente.")
              return
           endif

   endcase

return .T.

function qconv_st()
local nICMS_PROPRIO := 0
local nICMS_ST      := 0
local nSubst        := 0

  if CONVENIO->Dt_emissao >= ctod("04/02/2009")
     if ITEN_CON->Bc_subst > 0 .and. CLI1->Final $ " -N"
        nICMS_ST      +=  ( (ITEN_CON->Quantidade  * ITEN_CON->Bc_subst) * (ITEN_CON->Icms /100))
        nICMS_PROPRIO +=  ( ( ITEN_CON->Quantidade * ITEN_CON->vl_unitar ) * ( 7 / 100 ) )
     endif

     nSubst := nICMS_ST - nICMS_PROPRIO
  endif

return nSubst

