// CODIGO E DESCRICAO DOS CODIGO DE PRODUTO ___________________________________

function funcoes

function view_prod ( LL , CC , XX )
   COD_PROD->(qview(LL,CC,@XX,"@R 9999-9",NIL,.T.,NIL,{{"Codigo/C¢digo",1},{"Descricao/Descri‡„o",2}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
return



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

/////////////////////////////////////////////////////////////////////////////
// VIEW PADRAO PARA PLANO DE CONTAS _________________________________________
function view_plan ( LL , CC , XX )
   PLAN->(qview(LL,CC,@XX,"@R 99999-9",NIL,.T.,NIL,{{"Descricao/Descri‡„o",2},{"Codigo/C¢digo",1},{"Reduzido/C¢d.Reduz.",3}},"C",{"keyb(Reduzido)",NIL,NIL,NIL}))
return

// CODIGO E DESCRICAO DA NATUREZA DE OPERACAO _________________________________

function view_natop( LL , CC , XX )
   NATOP->(qview(LL,CC,@XX,"@R 9.99",NIL,.T.,NIL,{{"Nat_Cod/C¢digo",1},{"Nat_Desc/Descri‡„o",2}},"C",{"keyb(Nat_Cod)",NIL,NIL,NIL}))
return

// CODIGO DO ICMS
function view_icms( LL , CC , XX )
   ICMS->(qview(LL,CC,@XX,"99",NIL,.T.,NIL,{{"Codigo/C¢digo",1},{"Descricao/Descri‡„o",0}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
return

// VIEW PADRAO PARA HISTORICOS ______________________________________________

function view_hist (XX,YY,ZZ)
   HIST->(qview(XX,YY,@ZZ,"@!",NIL,.T.,NIL,{{"Descricao/Descri‡„o",2},{"Codigo/C¢digo",1}},"C",{"keyb(Descricao)",NIL,NIL,NIL}))
return

// SIGLA E ESTADO DA NOTA FISCAL ______________________________________________

function view_estado ( LL , CC , XX )
   ESTADO->(qview(LL,CC,@XX,"@!",NIL,.T.,NIL,{{"Est_Sig/Sigla",1},{"Est_Desc/Descri‡„o",2}},"C",{"keyb(Est_Sig)",NIL,NIL,NIL}))
return

// CODIGO E DESCRICAO DO FORNECEDOR DA MERCADORIA _____________________________

function view_forn ( LL , CC , XX )
   FORN->(qview(LL,CC,@XX,"@R 99999",NIL,.T.,NIL,{{"Razao/Raz„o",2},;
                                                 {"Codigo/C¢digo",1}},;
                                                 "C",;
                                                 {"keyb(Codigo)",NIL,NIL,NIL},;
                                                 NIL,;
                                                 "<ESC>/ALT-O/ALT-P"))
return

function view_cli ( LL , CC , XX )
   CLI1->(qview(LL,CC,@XX,"@!",NIL,.T.,NIL,{{"Razao/Raz„o",2},;
                                                 {"Codigo/C¢digo",1}},;
                                                 "C",;
                                                 {"keyb(Codigo)",NIL,NIL,NIL},;
                                                 NIL,;
                                                 "<ESC>/ALT-O/ALT-P"))
return

// CODIGO E DESCRICAO DA CONTA ________________________________________________

function view_conta ( LL , CC , XX )
   CONTA->(qview(LL,CC,@XX,"@R 999999",NIL,.T.,NIL,{{"Codigo/C¢digo",1},{"Descricao/Descri‡„o",2}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
return

// CODIGO E DESCRICAO DA TIPO CONTABIL ________________________________________________

function view_tpo ( LL , CC , XX )
   TIPOCONT->(qview(LL,CC,@XX,"@R 999999",NIL,.T.,NIL,{{"Codigo/C¢digo",1},{"Descricao/Descri‡„o",2}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
return

function view_cfop( LL , CC , XX )
   CFOP->(qview(LL,CC,@XX,"@R 9.999",NIL,.T.,NIL,{{"Nat_Cod/C¢digo",1},{"Nat_Desc/Descri‡„o",2}},"C",{"keyb(Nat_Cod)",NIL,NIL,NIL}))
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

// CODIGO E DESCRICAO DA SAIDA MAQUINA REGISTRADORA ___________________________

function view_maq ( LL , CC , XX )
   MAQ->(qview(LL,CC,@XX,"@R 99",NIL,.T.,NIL,{{"Maq_Cod/C¢digo",1},{"Maq_Desc/Descri‡„o",2}},"C",{"keyb(Maq_Cod)",NIL,NIL,NIL}))
return

// CODIGO E DESCRICAO DOS SERVICOS PRESTADOS (ISS)_____________________________

function view_serv ( LL , CC , XX )
   SERV->(qview(LL,CC,@XX,"@!",NIL,.T.,NIL,{{"Descricao/Descri‡„o",2},{"Codigo/C¢digo",1}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
return

// CODIGO E DESCRICAO DOS TRIBUTOS FISCAIS ____________________________________

function view_trib ( LL , CC , XX )
   TRIB->(qview(LL,CC,@XX,"@R 9999",NIL,.T.,NIL,{{"Codigo/C¢digo",1},{"Descricao/Descri‡„o",2}},"C",{"keyb(Codigo)",NIL,NIL,NIL},{"Anomes==XANOMES",{||dbseek(XANOMES)},{||qseekn(XANOMES)}}))
return

// CODIGO E DESCRICAO DOS SERVICOS PRESTADOS (ISS)_____________________________

function view_obs ( LL , CC , XX )
   SERV->(qview(LL,CC,@XX,"@!",NIL,.T.,NIL,{{"Descricao/Descri‡„o",2},{"Codigo/C¢digo",1}},"C",{"keyb(Descricao)",NIL,NIL,NIL}))
return

// CODIGO E NOME DOS VENDEDORES _______________________________________________

function view_vend ( LL , CC , XX )
   VEND->(qview(LL,CC,@XX,"@!",NIL,.T.,NIL,{{"Nome/Nome",2},{"Codigo/C¢digo",1}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA SOLICITACAO DE ANO MES _______________________________________

function f104x
return qnomemes(val(right(Anomes,2)))

function f104y
   qmensa("Informe o ano e mes da tabela no formato AAAAMM...")
   qgetx(24,60,@fANOMES,"999999")
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA DUPLICAR TRIBUTOS ____________________________________________

function ef_exec_dup ( cANOMES1 , cANOMES2 )

   local cCOD, cDES, nALI, nDIA, nREC

   TRIB->(dbseek(cANOMES1))

   do while ! TRIB->(eof()) .and. TRIB->Anomes == cANOMES1

      cCOD := TRIB->Codigo
      cDES := TRIB->Descricao
      nALI := TRIB->Aliquota
      nDIA := TRIB->Dia_venc
      nREC := TRIB->(recno())

      if ! TRIB->(dbseek(cANOMES2+cCOD))
         if TRIB->(qappend())
            replace TRIB->Anomes    with cANOMES2
            replace TRIB->Codigo    with cCOD
            replace TRIB->Descricao with cDES
            replace TRIB->Aliquota  with nALI
            replace TRIB->Dia_venc  with nDIA
         endif
      endif

      TRIB->(dbgoto(nREC))
      TRIB->(dbskip())

   enddo

return

/////////////////////////////////////////////////////////////////////////////
// VIEW PADRAO PARA CENTRO DE CUSTO _________________________________________

function view_ccusto (XX,YY,ZZ)
   CCUSTO->(qview(XX,YY,@ZZ,"@R 99999999",NIL,.T.,NIL,{{"transform(Codigo,'@R 99999999')/C¢digo",1},{"Descricao/Descri‡„o",2}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
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
// VIEW PADRAO PARA MUNICIPIO DE ISS ________________________________________

function view_municip (XX,YY,ZZ)
   MUNICIP->(qview(XX,YY,@ZZ,"9999",NIL,.T.,NIL,{{"Cgm_desc/Descri‡„o",4},{"Codigo/C¢digo",1}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
return

/////////////////////////////////////////////////////////////////////////////
// ABRE ARQUIVO ART_CENT DA CONTABILIDADE DA IQ _____________________________

function fu_abre_ccusto
   if ! quse(XPATHCONTA,"ART_CENT",{"ART_CENT","ART_CENT"},"R","CCUSTO")
      qmensa("N„o foi possivel abrir ART_CENT.DBF !","B")
      return .F.
   endif
return .T.

/////////////////////////////////////////////////////////////////////////////
// ABRE ARQUIVO EMITENTE DO FATURAMENTO DA IQ _______________________________

function fu_abre_emitente
   if ! quse(XPATHCOMP,"EMITENTE",{"FORN_01","FORN_02","FORN_03","FORN_04","FORN_05","FORN_06"})
      qmensa("N„o foi possivel abrir EMITENTE.DBF !","B")
      return .F.
   endif
return .T.

/////////////////////////////////////////////////////////////////////////////
// ABRE ARQUIVO TIPOVAR DA TESOURARIA DA IQ _________________________________

function fu_abre_tvar
   if ! quse(XPATHTESO,"TIPOVAR",{"TIPOVAR","TVAR_NOM","TVAR_CGC"})
      qmensa("N„o foi possivel abrir TIPOVAR.DBF !","B")
      return .F.
   endif
return .T.

