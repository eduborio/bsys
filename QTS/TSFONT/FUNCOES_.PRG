/////////////////////////////////////////////////////////////////////////////
// ABRE ARQUIVO CLI1 DO FATURAMENTO RESPECTIVO DE USO DA EMPRESA ____________

function funcoes

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
           if ! quse(XDRV_EB, "CLI1",{"CL_CODIG","CL_NOME","CL_CGC","CL_ENDER","CL_INSCR"})
              qmensa("N„o foi poss¡vel abrir arquivo CLI1.DBF !! Tente novamente.")
              return
           endif

   endcase

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
// ABRE ARQUIVO TIPO_RPC DA TESOUTRARIA DA IQ _____________________________

function fu_abre_tiporpc
   if ! quse(XPATHTESO,"TIPORPC",{"TIPORPC","TIPO_NO"})
      qmensa("N„o foi possivel abrir TIPORPC.DBF !","B")
      return .F.
   endif
return .T.

/////////////////////////////////////////////////////////////////////////////
// ABRE ARQUIVO QINST DAS EMPRESAS _________________________________________

function fu_abre_qinst
   if ! quse(XDRV_SH,"QINST",{"QINST1","QINST2"})
      qmensa("N„o foi possivel abrir QINST.DBF !","B")
      return .F.
   endif
return .T.

// VIEW PADRAO PARA TIPORPC ________________________________________________

function view_tipo (XX,YY,ZZ)
   TIPOCONT->(qview(XX,YY,@ZZ,"@R 999999",NIL,.T.,NIL,{{"Codigo/C¢digo",1},{"Descricao/Descri‡„o",2}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
return

function view_planfin ( LL , CC , XX )
   PLAN_FIN->(dbsetfilter({|| right(PLAN_FIN->codigo,5) != "     " }))
   PLAN_FIN->(qview(LL,CC,@XX,"@R 99999",NIL,.T.,NIL,{{"left(Descricao,40)/Descri‡„o",2},{"right(codigo,5)/C¢digo",3}},"C",{"keyb(right(Codigo,5))",NIL,NIL,NIL}))
return

function view_planfinpag ( LL , CC , XX )
   PLAN_FIN->(dbsetfilter({|| right(PLAN_FIN->codigo,5) != "     " .and. left(PLAN_FIN->Codigo,2) == "02" }))
   PLAN_FIN->(qview(LL,CC,@XX,"@R 99999",NIL,.T.,NIL,{{"left(Descricao,40)/Descri‡„o",2},{"right(codigo,5)/C¢digo",3}},"C",{"keyb(right(Codigo,5))",NIL,NIL,NIL}))
return

function view_planfinrec ( LL , CC , XX )
   PLAN_FIN->(dbsetfilter({|| right(PLAN_FIN->codigo,5) != "     " .and. left(PLAN_FIN->Codigo,2) == "01" }))
   PLAN_FIN->(qview(LL,CC,@XX,"@R 99999",NIL,.T.,NIL,{{"left(Descricao,40)/Descri‡„o",2},{"right(codigo,5)/C¢digo",3}},"C",{"keyb(right(Codigo,5))",NIL,NIL,NIL}))
return

// VIEW PADRAO PARA FORMAS DE PAGAMENTO ________________________________________________

function view_form (XX,YY,ZZ)
   FORM_PGT->(qview(XX,YY,@ZZ,"99999",NIL,.T.,NIL,{{"CODIGO/C¢digo",1},{"Descricao/Descricao",2}},"C",{"keyb(CODIGO)",NIL,NIL,NIL}))
return

// VIEW PADRAO PARA EMPRESAS CADASTRADAS ________________________________________________

function view_emp (XX,YY,ZZ)
   QINST->(qview(XX,YY,@ZZ,"999",NIL,.T.,NIL,{{"Empresa/C¢digo",1},{"Razao/Razao",2}},"C",{"keyb(EMPRESA)",NIL,NIL,NIL}))
return


/////////////////////////////////////////////////////////////////////////////
// VIEW PADRAO PARA PLANO DE CONTAS _________________________________________

function view_plan (XX,YY,ZZ)
   PLAN->(qview(XX,YY,@ZZ,"@K@R 99999-9",NIL,.T.,NIL,;
         {{"ct_convcod(Codigo)/C¢digo"     ,1},;
          {"Descricao/Descri‡„o"           ,2},;
          {"ct_convcod(Reduzido)/Cod.Red." ,3}},;
          "C",{"keyb(Reduzido)",NIL,NIL,NIL}))
return

/////////////////////////////////////////////////////////////////////////////
// CONVERTE CODIGOS DE CONTA E REDUZIDO _____________________________________

function ct_convcod ( cCOD )
   if len(cCOD) == 12
      cCOD := transform(cCOD,"@R 9.99.99.99.9999-9")
   else
      cCOD := transform(cCOD,"@R 99999-9")
   endif
return cCOD

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA BUSCAR FILIAL ________________________________________________
function view_FILIAL (XX,YY,ZZ)
   FILIAL->(qview(XX,YY,@ZZ,"9999",NIL,.T.,NIL,{{"Codigo/Codigo",1},{"left(RAZAO,30)/Raz„o",2},{"busca_mun()/Municipio",0}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA BUSCAR MUNICIPIO NO CGM ______________________________________

function busca_mun
    CGM->(dbseek(FILIAL->Cgm))
return(CGM->Municipio)

/////////////////////////////////////////////////////////////////////////////
// VIEW PADRAO PARA CENTRO DE CUSTO _________________________________________

function view_ccusto (XX,YY,ZZ)
   CCUSTO->(qview(XX,YY,@ZZ,"9999",NIL,.T.,NIL,{{"CODIGO",1},{"DESCRICAO/Descri‡„o",2}},"C",{"keyb(RIGHT(CODIGO,4))",NIL,NIL,NIL}))
return

/////////////////////////////////////////////////////////////////////////////
// VIEW PADRAO PARA BANCO____________________________________________________

function view_banco (XX,YY,ZZ)
   BANCO->(qview(XX,YY,@ZZ,"99999",NIL,.T.,NIL,{{"CODIGO/C¢digo",1},{"Descricao/Nome",2}},"C",{"keyb(CODIGO)",NIL,NIL,NIL}))
return

function view_inst (XX,YY,ZZ)
   INSTITU->(qview(XX,YY,@ZZ,"99999",NIL,.T.,NIL,{{"CODIGO/C¢digo",1},{"Nome/Nome",2}},"C",{"keyb(CODIGO)",NIL,NIL,NIL}))
return

function view_proj (XX,YY,ZZ)
   PROJET->(qview(XX,YY,@ZZ,"99999",NIL,.T.,NIL,{{"CODIGO/C¢digo",1},{"Descricao/Nome",2}},"C",{"keyb(CODIGO)",NIL,NIL,NIL}))
return



function view_adiant (XX,YY,ZZ)
   AD_VIAG->(qview(XX,YY,@ZZ,"99999",NIL,.T.,NIL,{{"Favorecido/Nome",3},{"CODIGO/C¢digo",1},{"Data/Data",2}},"C",{"keyb(CODIGO)",NIL,NIL,NIL}))
return



/////////////////////////////////////////////////////////////////////////////
// VIEW PADRAO PARA EMITENTES _______________________________________________

function view_emit (XX,YY,ZZ)
   EMIT->(qview(XX,YY,@ZZ,"9999",NIL,.T.,NIL,{{"Razao/Raz„o",2},{"Codigo/C¢digo",1},{"rc_conv_cgccpf(cgccpf)/CGC/CPF",3}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
return

/////////////////////////////////////////////////////////////////////////////
// VIEW PADRAO PARA CLIENTES ________________________________________________

function view_cli (XX,YY,ZZ)
   CLI1->(qview(XX,YY,@ZZ,"99999",NIL,.T.,NIL,{{"Razao/Raz„o",2},{"Codigo/C¢digo",1}},"C",{"keyb(Codigo)",NIL,NIL,"str5"}))
return

/////////////////////////////////////////////////////////////////////////////
// VIEW PADRAO PARA CLIENTES ________________________________________________

function view_forn (XX,YY,ZZ)
   FORN->(qview(XX,YY,@ZZ,"99999",NIL,.T.,NIL,{{"Razao/Raz„o",2},{"Codigo/C¢digo",1}},"C",{"keyb(Codigo)",NIL,NIL,"str5"}))
return

function view_fun (XX,YY,ZZ)
   FUN->(qview(XX,YY,@ZZ,"999999",NIL,.T.,NIL,{{"Nome/Nome",2},{"Matricula/Matricula",1}},"C",{"keyb(matricula)",NIL,NIL,"str6"}))
return


/////////////////////////////////////////////////////////////////////////////
// RETORNO DE STRZERO NA CODIGO (PARA VIEW) _________________________________

function str5 ( cCODIGO )
   if val(cCODIGO) <> 0
      return strzero(val(cCODIGO),5)
   endif
return cCODIGO

function str6 ( cCODIGO )
   if val(cCODIGO) <> 0
      return strzero(val(cCODIGO),6)
   endif
return cCODIGO


/////////////////////////////////////////////////////////////////////////////
// VIEW PADRAO PARA CGM _____________________________________________________

function view_cgm (XX,YY,ZZ)
   CGM->(qview(XX,YY,@ZZ,"@!",NIL,.T.,NIL,{{"Municipio",2},{"Codigo/C¢digo",1},{"Estado",0}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
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

return padr(cRET,18)

// CODIGO E DESCRICAO DA SERIE ________________________________________________

function view_serie ( LL , CC , XX )
   SERIE->(qview(LL,CC,@XX,"@R 99",NIL,.T.,NIL,{{"Codigo/C¢digo",1},{"Descricao/Descri‡„o",2}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
return

// CODIGO E DESCRICAO DA SERIE ________________________________________________

function view_especie ( LL , CC , XX )
   ESPECIE->(qview(LL,CC,@XX,"@R 99",NIL,.T.,NIL,{{"Codigo/C¢digo",1},{"Descricao/Descri‡„o",2}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
return

