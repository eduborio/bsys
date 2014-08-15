/////////////////////////////////////////////////////////////////////////////
// ABRE ARQUIVO SH_APCOM P/ INTERFACE COM CONTAS A PAGAR  ___________________

function funcoes
function fu_abre_apcom
   if ! quse(XDRV_CP,"SH_APCOM")
      qmensa("N„o foi possivel abrir SH_APCOM.DBF !","B")
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

function view_sit( LL , CC , XX )
   SIT_TRIB->(qview(LL,CC,@XX,"@R 999",NIL,.T.,NIL,{{"Codigo/C¢digo",1},{"Descricao/Descricao",2}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
return

function view_resp( LL , CC , XX )
   RESP_REP->(qview(LL,CC,@XX,"@R 99999",NIL,.T.,NIL,{{"Codigo/C¢digo",1},{"Nome/Nome",2}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
return

function view_motdev(LL , CC , XX )
   MOTDEV->(qview(LL,CC,@XX,"@R 99",NIL,.T.,NIL,{{"Codigo/C¢digo",1},{"Descricao/Descricao",2}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
return

function view_subsys(LL , CC , XX )
   SUBSYS->(qview(LL,CC,@XX,"@R 99",NIL,.T.,NIL,{{"Codigo/C¢digo",1},{"Descricao/Descricao",2}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
return

function view_defeito(LL , CC , XX )
   DEFEITO->(qview(LL,CC,@XX,"@R 99",NIL,.T.,NIL,{{"Codigo/C¢digo",1},{"Descricao/Descricao",2}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
return



function view_motbai(LL , CC , XX )
   MOTBAI->(qview(LL,CC,@XX,"@R 99",NIL,.T.,NIL,{{"Codigo/C¢digo",1},{"Descricao/Descricao",2}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
return



function view_especie ( LL , CC , XX )
   ESPECIE->(qview(LL,CC,@XX,"@R 99",NIL,.T.,NIL,{{"Codigo/C¢digo",1},{"Descricao/Descri‡„o",2}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
return

function view_serie ( LL , CC , XX )
   SERIE->(qview(LL,CC,@XX,"@R 99",NIL,.T.,NIL,{{"Codigo/C¢digo",1},{"Descricao/Descri‡„o",2}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
return

function view_doc ( LL , CC , XX )
   TIPO_DOC->(qview(LL,CC,@XX,"@R 99",NIL,.T.,NIL,{{"Codigo/C¢digo",1},{"Descricao/Descri‡„o",2}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
return


function view_designer ( LL , CC , XX )
   DESIGNER->(qview(LL,CC,@XX,"@R 999",NIL,.T.,NIL,{{"Codigo/C¢digo",1},{"Nome/Nome",2}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
return


// VIEW PADRAO PARA AREA _______________________________________________________

function view_area (XX,YY,ZZ)
   AREA->(qview(XX,YY,@ZZ,"@!",NIL,.T.,NIL,{{"Descricao/Descri‡„o",2},{"Codigo/C¢digo",1}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
return

// VIEW PADRAO PARA BANCO____________________________________________________

function view_banco (XX,YY,ZZ)
   BANCO->(qview(XX,YY,@ZZ,"99999",NIL,.T.,NIL,{{"CODIGO/C¢digo",1},{"Descricao/Nome",2}},"C",{"keyb(CODIGO)",NIL,NIL,NIL}))
return

//function view_rota (XX,YY,ZZ)
//   ROTA->(qview(XX,YY,@ZZ,"99999",NIL,.T.,NIL,{{"CODIGO/C¢digo",1},{"Descricao/Nome",2}},"C",{"keyb(CODIGO)",NIL,NIL,NIL}))
//return


function view_ufs (XX,YY,ZZ)
   UFS->(qview(XX,YY,@ZZ,"@!",NIL,.T.,NIL,{{"CODIGO/C¢digo",1},{"Descricao/Nome",2}},"C",{"keyb(CODIGO)",NIL,NIL,NIL}))
return

// VIEW PADRAO PARA O LOTE DO PRODUTO ______________________________________________

function view_lote ( LL , CC , XX )
   INVENT->(qview(LL,CC,@XX,"@R 9999999999",NIL,.T.,NIL,{{"Lote/Nr.Lote",3},{"Cod_prod/C¢d.Produto",0},{"Quant_atu/Saldo Atual",0},{"Filial/Filial",0}},"C",{"keyb(Lote)",NIL,NIL,NIL}))
return

/////////////////////////////////////////////////////////////////////////////
// ABRE ARQUIVO SH_PROCT P/ INTERFACE COM CONTABILIDADE (Q-SYS) ____________

function fu_abre_prov
   if ! quse(XDRV_CT,"SH_PROCT")
      qmensa("N„o foi possivel abrir SH_PROCT.DBF !","B")
      return .F.
   endif
return .T.

function abre_conf
   if ! quse(XDRV_CP,"CONFIG")
      qmensa("N„o foi possivel abrir CONFIG.DBF do Compras !","B")
      return .F.
   endif
return .T.

/////////////////////////////////////////////////////////////////////////////
// VIEW PADRAO PARA PLANO DE CONTAS _________________________________________
function view_plan ( LL , CC , XX )
   PLAN->(qview(LL,CC,@XX,"@R 99999-9",NIL,.T.,NIL,{{"Codigo/C¢digo",1},{"Descricao/Descri‡„o",2},{"Reduzido/C¢d.Reduz.",3}},"C",{"keyb(Reduzido)",NIL,NIL,NIL}))
return

// VIEW PADRAO PARA PEDIDOS DE VENDA __________________________________________

function view_ped ( LL , CC , XX )
   FAT->(qview(LL,CC,@XX,"@R 99999",NIL,.T.,NIL,{{"Codigo/C¢digo",1},{"c_CLI()/Cliente",0},{"Dt_emissao/Emissao",0}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
return

function c_CLI
   CLI1->(dbseek(FAT->Cod_cli))
return left(CLI1->Razao,25)

// VIEW PADRAO PARA FORNECEDOR ______________________________________________

function view_forn1 ( LL , CC , XX )
   FORN->(qview(LL,CC,@XX,"@R 99999",NIL,.T.,NIL,{{"Codigo/C¢digo",1},{"Razao/Descricao",2}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
return

// CODIGO E DESCRICAO DO VENDEDOR ___________________________________________

function view_vend( LL , CC , XX )
   VEND->(qview(LL,CC,@XX,"@R 99999",NIL,.T.,NIL,{{"Codigo/C¢digo",1},{"Nome/Nome",2}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
return

function view_alm( LL , CC , XX )
   ALMOXAR->(qview(LL,CC,@XX,"@R 99999",NIL,.T.,NIL,{{"Codigo/C¢digo",1},{"Nome/Nome",2}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
return


// CODIGO E DESCRICAO DO REPRESENTANTE ___________________________________________

function view_repres( LL , CC , XX )
   REPRES->(qview(LL,CC,@XX,"@R 99999",NIL,.T.,NIL,{{"Codigo/C¢digo",1},{"Razao/RazÆo",2}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
return

function view_cond( LL , CC , XX )
   COND->(qview(LL,CC,@XX,"@R 99",NIL,.T.,NIL,{{"Codigo/C¢digo",1},{"Descricao/Descricao",2}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
return

// CODIGO E DESCRICAO DO PREPOSTO  ___________________________________________

function view_prep( LL , CC , XX )
   PREP->(qview(LL,CC,@XX,"@R 99999",NIL,.T.,NIL,{{"Codigo/C¢digo",1},{"Descricao/Descri‡„o",2}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
return

function view_if( LL , CC , XX )
   IDENT->(qview(LL,CC,@XX,"@R 9999",NIL,.T.,NIL,{{"Codigo/C¢digo",1},{"left(Nome,30)/Nome",2},{"Aliq/Aliquota",0},{"Aliq_ded/Deducao",0}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
return

// CODIGO E DESCRICAO DO SETOR ___________________________________________

function view_setor( LL , CC , XX )
   SETOR->(qview(LL,CC,@XX,"@R 99999",NIL,.T.,NIL,{{"Codigo/C¢digo",1},{"Descricao/Descri‡„o",2}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
return

function view_territ( LL , CC , XX )
   TERRIT->(qview(LL,CC,@XX,"@R 9999",NIL,.T.,NIL,{{"Codigo/C¢digo",1},{"Descricao/Descri‡„o",2}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
return

function view_areaexc( LL , CC , XX )
   AREA_EXC->(qview(LL,CC,@XX,"@R 99999",NIL,.T.,NIL,{{"Codigo/Codigo",1},{"Descricao/Descricao",2}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
return


function view_rota( LL , CC , XX )
   ROTA->(qview(LL,CC,@XX,"@R 99999",NIL,.T.,NIL,{{"Codigo/C¢digo",1},{"Descricao/Descri‡„o",2}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
return

/////////////////////////////////////////////////////////////////////////////
// VIEW PADRAO PARA UNIDADES ________________________________________________

function view_uni (XX,YY,ZZ)
   UNIDADE->(qview(XX,YY,@ZZ,"999",NIL,.T.,NIL,{{"Sigla/Sigla",2},{"Codigo/C¢digo",1},{"Fator/Fator",0},{"Uni_fat()/Sig. Fat.",0}},"C",{"Keyb(left(Codigo,3))",NIL,NIL,NIL}))
return

/////////////////////////////////////////////////////////////////////////////
function view_agenc (XX,YY,ZZ)
   AGE_CED->(qview(XX,YY,@ZZ,"9999",NIL,.T.,NIL,{{"Codigo/Codigo",1},{"Descricao/Nome",2}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
return

/////////////////////////////////////////////////////////////////////////////
// VIEW PADRAO PARA TIPORPC ________________________________________________

function view_tipocont (XX,YY,ZZ)
   TIPOCONT->(qview(XX,YY,@ZZ,"@R 999999",NIL,.T.,NIL,{{"Codigo/C¢digo",1},{"Descricao/Descri‡„o",2}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
return

/////////////////////////////////////////////////////////////////////////////
// CODIGO E DESCRICAO DA NATUREZA DE OPERACAO _________________________________

function view_natop( LL , CC , XX )
   NATOP->(qview(LL,CC,@XX,"@R 9.99",NIL,.T.,NIL,{{"Nat_Cod/C¢digo",1},{"Nat_Desc/Descri‡„o",2}},"C",{"keyb(Nat_Cod)",NIL,NIL,NIL}))
return

function view_cfop( LL , CC , XX )
   CFOP->(qview(LL,CC,@XX,"@R 9.999",NIL,.T.,NIL,{{"Nat_Cod/C¢digo",1},{"Nat_Desc/Descri‡„o",2}},"C",{"keyb(Nat_Cod)",NIL,NIL,NIL}))
return

/////////////////////////////////////////////////////////////////////////////
// VIEW PADRAO PARA VEICULOS ________________________________________________

function view_veic ( LL , CC , XX )
   VEICULOS->(qview(LL,CC,@XX,"@R 99999",NIL,.T.,NIL,{{"Codigo/C¢digo",1},{"Descricao/Descricao",2}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
return

/////////////////////////////////////////////////////////////////////////////
// VIEW PADRAO PARA CLIENTES ________________________________________________

function view_cli (XX,YY,ZZ)
   CLI1->(qview(XX,YY,@ZZ,"99999",NIL,.T.,NIL,{{"Razao/Raz„o",2},{"Codigo/C¢digo",1}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
return

function view_cli2 (XX,YY,ZZ)

   if CONFIG->Modelo_fat == "1" .and. XPROG $ "201-202-203"
      CLI1->(qview(XX,YY,@ZZ,"99999",NIL,.T.,NIL,{{"fu_conv_cgccpf(Cgccpf)/CNPJ",3},{"iif(ShowRoom == 'S','Sim','Nao')/ShowRoom",0},{"qabrev(Categoria,'VPNFC',{'VIC','POT','NOR','FINAL','PROB'})/Categ.",0},{"RespVic()/Responsavel",0}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
   else
      CLI1->(qview(XX,YY,@ZZ,"99999",NIL,.T.,NIL,{{"left(Razao,30)/Raz„o",2},{"left(Fantasia,15)/Fantasia",4},{"Fone1/Telefone",5},{"fu_conv_cgccpf(Cgccpf)/CNPJ",3}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
   endif
return

function view_cli4 (XX,YY,ZZ)
    CLI1->(qview(XX,YY,@ZZ,"99999",NIL,.T.,NIL,{{"fu_conv_cgccpf(Cgccpf)/CNPJ",3},{"left(Razao,30)/Raz„o",2},{"left(Fantasia,15)/Fantasia",4},{"Fone1/Telefone",5}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
return


function view_clicnpj (XX,YY,ZZ)
   CLI1->(qview(XX,YY,@ZZ,"99999",NIL,.T.,NIL,{{"left(Razao,40)/Raz„o",2},{"Fone1/Telefone",5},{"fu_conv_cgccpf(Cgccpf)/CNPJ",3}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
return


function view_forn (XX,YY,ZZ)
   FORN->(qview(XX,YY,@ZZ,"99999",NIL,.T.,NIL,{{"left(Razao,40)/Raz„o",2},{"fu_conv_cgccpf(Cgccpf)/CNPJ",3}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
return


function view_cli3 (XX,YY,ZZ)
   CLI1->(qview(XX,YY,@ZZ,"99999",NIL,.T.,NIL,{{"Codigo/C¢digo",1},{"Razao/Raz„o",2}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
return

function view_fat (XX,YY,ZZ)
   FAT->(qview(XX,YY,@ZZ,"99999",NIL,.T.,NIL,{{"Codigo/C¢digo",1},{"left(Cliente,35)/Cliente",7},{"Num_fatura/Nota Fiscal",11}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
return

function view_conv (XX,YY,ZZ)
   CONVENIO->(qview(XX,YY,@ZZ,"999999",NIL,.T.,NIL,{{"left(Cliente,35)/Cliente",3},{"Codigo/C¢digo",1}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
return



/////////////////////////////////////////////////////////////////////////////
// VIEW PADRAO PARA TRANSPORTADORAS ________________________________________________

function view_transp (XX,YY,ZZ)
   TRANSP->(qview(XX,YY,@ZZ,"99999",NIL,.T.,NIL,{{"Razao/Raz„o",2},{"Codigo/C¢digo",1}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
return

// VIEW PADRAO PARA CGM _____________________________________________________

function view_cgm (XX,YY,ZZ)
   CGM->(qview(XX,YY,@ZZ,"@!",NIL,.T.,NIL,{{"Municipio",2},{"Codigo/C¢digo",1},{"Estado",0}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
return

/////////////////////////////////////////////////////////////////////////////
// VIEW PADRAO PARA FUNCIONARIOS ____________________________________________

function view_fun (XX,YY,ZZ)
   FUN->(qview(XX,YY,@ZZ,"999999",NIL,.T.,NIL,{{"Nome/Nome do funcionario",2},{"Matricula/Matri.",1}},"C",{"keyb(Matricula)",NIL,NIL,NIL}))
return

/////////////////////////////////////////////////////////////////////////////
// VIEW PADRAO PARA FILIAL _________________________________________

function view_centro (XX,YY,ZZ)
   CCUSTO->(qview(XX,YY,@ZZ,"@R 99.99.9999",NIL,.T.,NIL,{{"transform(Codigo,'@R 99.99.9999')/C¢digo",1},{"Descricao/Descri‡„o",2}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
return

/////////////////////////////////////////////////////////////////////////////
// VIEW PADRAO PARA GRUPO _________________________________________

function view_grupo (XX,YY,ZZ)
   GRUPO_PR->(qview(XX,YY,@ZZ,"@R 99999",NIL,.T.,NIL,{{"Codigo/C¢digo",1},{"Descricao/Descri‡„o",2}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
return


function view_ccusto (XX,YY,ZZ)
   CCUSTO->(qview(XX,YY,@ZZ,"9999",NIL,.T.,NIL,{{"Descricao/Descri‡„o",2},{"Codigo",1}},"C",{"keyb(right(Codigo,4))",NIL,NIL,NIL}))
return

function view_FILIAL (XX,YY,ZZ)
   FILIAL->(qview(XX,YY,@ZZ,"9999",NIL,.T.,NIL,{{"Codigo/Codigo",1},{"left(RAZAO,30)/Raz„o",2},{"busca_mun()/Municipio",0}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA BUSCAR MUNICIPIO NO CGM ______________________________________

function busca_mun
    CGM->(dbseek(FILIAL->Cgm))
return(CGM->Municipio)

// CODIGO E DESCRICAO DO PRODUTO ____________________________________________
//function view_prod ( LL , CC , XX )
//   PROD->(qview(LL,CC,@XX,"99999",NIL,.T.,NIL,{{"Codigo/C¢digo",1},{"Descricao/Produto",2}},"C",{"keyb(right(Codigo,5))",NIL,NIL,NIL}))
//return
function view_prod ( LL , CC , XX )
   PROD->(qview(LL,CC,@XX,"99999",NIL,.T.,NIL,{{"left(Descricao,40)/Descri‡„o",2},{"Cod_ass/Assoc.",3},{"Cod_fabr/C/Fabric.",5}},"C",{"keyb(right(Codigo,5))",NIL,NIL,NIL}))
return

function view_prod3 ( LL , CC , XX )
   PROD->(qview(LL,CC,@XX,"99999",NIL,.T.,NIL,{{"Codigo/C¢digo",1},{"left(Descricao,40)/Produto",2},{"Preco_cons/Preco",0},{"transf(f201cl(),'@R 99999.9')/Quant",0}},"C",{"keyb(right(Codigo,5))",NIL,NIL,NIL}))
return


return



function view_familia ( LL , CC , XX )
   PROD->(qview(LL,CC,@XX,"99",NIL,.T.,NIL,{{"Codigo/C¢digo",1},{"left(Descricao,12)/Descri‡„o",2}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
return

/////////////////////////////////////////////////////////////////////////////
// CODIGO E DESCRICAO DOS SERVICOS PRESTADOS (ISS)___________________________

function view_serv ( LL , CC , XX )
   SERV->(qview(LL,CC,@XX,"@!",NIL,.T.,NIL,{{"Descricao/Descri‡„o",2},{"Codigo/C¢digo",1}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
return

////////////////////////////////////////////////////////////////////////////////////////////
// ABRE ARQUIVO SH_FAREC DA QSYS PARA INTERFACE DO FATURAMENTO COM CONTAS A RECEBER ________

function fu_abre_farec
   if ! quse(XDRV_CL,"SH_FAREC")
      qmensa("N„o foi possivel abrir SH_FAREC.DBF !","B")
      return .F.
   endif
return .T.

/////////////////////////////////////////////////////////////////////////////
// CALCULA DATA DO VENCIMENTO DA PRIMEIRA DUPLICATA CONFORME CONTRATO _______

function fu_calc_data ( dEMISSAO , nDIAS , cTIPO )

   local dRET

   do case

           // DD - DIAS DIRETO ______________________________________________

      case cTIPO == "1"

           dRET := dEMISSAO + nDIAS

           // DFS - DIAS FORA A SEMANA (QUE INICIA NO SABADO) _______________

      case cTIPO == "2"

           if dow(dEMISSAO) == 7
              dEMISSAO += 7
           else
              do while dow(dEMISSAO) < 7
                 dEMISSAO++
              enddo
           endif

           dRET := dEMISSAO + nDIAS - 1

           // DFD - DIAS FORA DEZENA ________________________________________

      case cTIPO == "3"

           do while .T.
              if day(dEMISSAO) = 10 .or. day(dEMISSAO) = 20 .or. day(dEMISSAO) = day(qfimmes(dEMISSAO))
                 dRET := dEMISSAO + nDIAS //+ 1
                 exit
              endif
              dEMISSAO++
           enddo

           // DFQ - DIAS FORA QUINZENA ______________________________________

      case cTIPO == "4"

           do while .T.
              if day(dEMISSAO) = 15 .or. day(dEMISSAO) = day(qfimmes(dEMISSAO))
                 dRET := dEMISSAO + nDIAS //+ 1
                 exit
              endif
              dEMISSAO++
           enddo

           // DFM - DIAS FORA O MES _________________________________________

      case cTIPO == "5"

           dRET := qfimmes(dEMISSAO) //+ 1
           dRET += nDIAS
   endcase

   // SE SABADO OU DOMINGO, ENTAO PASSA P/ SEGUNDA __________________________

   if dow(dRET) == 7 ; dRET += 2 ; endif
   if dow(dRET) == 1 ; dRET += 1 ; endif

return dRET


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


/////////////////////////////////////////////////////////////////////////////
// CONVERTE CLASSE __________________________________________________________

function fu_conv_classe ( cCLASSE )
return qabrev ( cCLASSE , "ABCDEFGHIJKLMN" , { ;
                          "ARGAMASSA                  ",;
                          "CONCRETO                   ",;
                          "PLASTIMIX                  ",;
                          "SERVICO DE BOMBEAMENTO     ",;
                          "SERVICO DE ESTEIRA         ",;
                          "SERVICO DE CONCRETAGEM     ",;
                          "TAXA ADIC DE HORA EXTRA    ",;
                          "TAXA ADIC PLASTIFICANTE    ",;
                          "TAXA ADIC POR M3 FALTANTE  ",;
                          "TAXA ADIT IMPERMEABILIZANTE",;
                          "TAXA DE SERVICOS EXECUTADOS",;
                          "TAXA DE VENDAS DIVERSAS    ",;
                          "TAXA DIF PREC COBRADO MENOR",;
                          "TAXA REF REAJUSTE          " } )



/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA CODIFICAR SENHA ______________________________________________

function fu_codifica_senha ( cSENHA )
   local nCONT, cSTRING := "", cRET := ""

   cSENHA := qencri(cSENHA)

   cSTRING := cSENHA+cSENHA+cSENHA+cSENHA+cSENHA

   for nCONT := 1 to 10
       cRET += subs(cSENHA,nCONT,1)
       cRET += subs(cSTRING,nCONT*4,4)
   next

return cRET


/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA DECODIFICAR SENHA ____________________________________________

function fu_decodifica_senha ( cSTRING )

   local nCONT, cSENHA := ""

   for nCONT := 1 to 50 step 5
       cSENHA += subs(cSTRING,nCONT,1)
   next

return qdecri(cSENHA)

function RespVic
local cNome:= ""

    if(VEND->(dbseek(CLI1->Resp)))
       cNOME := left(VEND->Nome,10)
    else
       cNOME := "          "
    endif

return cNOME


/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA SOLICITAR SENHA DE LIBERACAO _________________________________

function fu_check_senha_lib ( cORIGINAL )

   local sBLOC := qsbloc(12,20,15,58)

   local lRET := .T.

   qlbloc(12,20,"BSENHA","QBLOC.GLO",1)

   if qgetsenha(13,43,10) <> cORIGINAL ; lRET := .F. ; endif

   qrbloc(12,20,sBLOC)

return lRET


function fu_transf ( cTIPO , cARQ , cCOD )

   private lTEM_OBRA, lTEM_CONT

   i_transf(cTIPO,cARQ,cCOD,.F.)

return


/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA TRANFERENCIA ENTRE ARQUIVOS VIVO E MORTO _____________________

function i_transf ( cTIPO , cARQ , cCOD , lREC )

   // INICIALIZA VARIAVEIS DE "ALIAS" E SALVA ORDEM _________________________

   local cORIG := cARQ + cTIPO
   local cDEST := cARQ + iif(cTIPO=="1","2","1")
   local nORD  := (cORIG)->(indexord())

   // VERIFICA SE EXISTE REGISTRO PARA SER TRANSFERIDO ______________________

   if lREC
      (cORIG)->(dbsetorder(iif(cARQ=="CLI",1,iif(cARQ=="OBRA",3,5))))
      (cORIG)->(dbseek(cCOD))
      (cORIG)->(dbsetorder(nORD))
   endif

   // SE EXISTE, ENTAO REALIZA TRANSFERENCIA ________________________________

   (cORIG)->(qpublicfields())

   if (cDEST)->(qappend()) .and. (cORIG)->(qrlock())
      (cORIG)->(qcopyfields())
      (cDEST)->(qreplacefields())
      (cORIG)->(dbdelete())
   else
      qmensa("N„o foi possivel realizar a transferencia...","B")
   endif

return


/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA CADASTRO DE ALIQUOTA DO MUNICIPIO ____________________________

function fu_inc_aliq_municipio()

   local lCONF
   local aEDICAO := {}
   local bESCAPE := {||(nNIVEL==1.and.lastkey()==27.and.!XFLAG)}
   local cCODIGO

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   qlbloc(9,12,"B102E","QBLOC.GLO",1)

// aadd(aEDICAO,{{ || qgetx(10,25,@fCODIGO       , "9999"               ) } ,"CODIGO"    })
   aadd(aEDICAO,{{ || qgetx(10,63,@fVENC         , "99"                 ) } ,"VENC"      })
   aadd(aEDICAO,{{ || view_filial(12,25,@fFILIAL                        ) } ,"FILIAL"    })
   aadd(aEDICAO,{{ || NIL },NIL }) // descricao do filial
   aadd(aEDICAO,{{ || view_cgm(14,25,@cCGM                              ) } ,"CGM"       })
   aadd(aEDICAO,{{ || NIL },NIL }) // descricao do cgm
   aadd(aEDICAO,{{ || qgetx(16,32,@fALIQ_BASE    , "@R 99.99"           ) } ,"ALIQ_BASE" })
   aadd(aEDICAO,{{ || qgetx(16,58,@fALIQ_ISS     , "@R 99.99"           ) } ,"ALIQ_ISS"  })
   aadd(aEDICAO,{{ || lCONF := qconf("Confirma inclus„o ?"              ) } ,NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   MUNICIP->(qpublicfields())

   MUNICIP->(qinitfields())

   nNIVEL:= 2
   XFLAG := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while nNIVEL>= 1 .and. nNIVEL<= len(aEDICAO)
      eval ( aEDICAO [nNIVEL,1] )
      if eval ( bESCAPE ) ; MUNICIP->(qreleasefields()) ; return ; endif
      if ! i_crit_municip( aEDICAO[nNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , nNIVEL++ , nNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif

   if quse(XDRV_EF,"CONFIG",{},"E","PROV") .and. MUNICIP->(qappend())

      replace PROV->Cod_munic with PROV->Cod_munic + 1
      qsay ( 10,25,cCODIGO := strzero(PROV->Cod_munic,4) )
      qmensa("C¢digo Gerado: "+cCODIGO,"B")

      fCGM := cCGM
      MUNICIP->(qreplacefields())
      replace MUNICIP->Codigo with cCODIGO
      MUNICIP->(qunlock())

      PROV->(dbclosearea())

   else

      iif(cOPCAO=="I",qm1(),qm2())

   endif

return

/////////////////////////////////////////////////////////////////////////////
// CRITICAS NA DESCIDA ______________________________________________________

static function i_crit_municip( cCAMPO )

   qmensa("")

   iif ( cCAMPO == NIL , cCAMPO := "" , NIL )

   do case
//    case cCAMPO == "CODIGO"
//         if empty(fCODIGO) .or. val(fCODIGO) == 0 ; return .F. ; endif
//         qsay(10,25,fCODIGO:=strzero(val(fCODIGO),4))
//         MUNICIP->(dbsetorder(1))
//         if MUNICIP->(dbseek(fCODIGO))
//            qmensa("Munic¡pio j  cadastrado !","B")
//            return .F.
//         endif

      case cCAMPO == "FILIAL"

           qsay(12,25,fFILIAL:=strzero(val(fFILIAL),4))

           if FILIAL->(dbseek(fFILIAL))
              qsay(12,38,left(FILIAL->Razao,27))
           else
              qmensa("Filial n„o encontrado !","B")
              return .F.
           endif

      case cCAMPO == "CGM"
           nREC := MUNICIP->(recno())
           MUNICIP->(dbsetorder(2))
           if MUNICIP->(dbseek(CGM->Codigo))
              qmensa("Municipio j  cadastrado para base de calculo do ISS !","B")
              MUNICIP->(dbsetorder(1))
              MUNICIP->(dbgoto(nREC))
              return .F.
           endif
           MUNICIP->(dbsetorder(1))
           MUNICIP->(dbgoto(nREC))
           qsay (14,34,left(CGM->Municipio,28) + "/" + CGM->Estado )

      case cCAMPO == "VENC"
           qsay(10,63,fVENC:=strzero(val(fVENC),2))
           if val(fVENC) > 31 .or. val(fVENC) < 0
              qmensa("Dia do vencimento inv lido !","B")
              return .F.
           endif
   endcase

return .T.

function q_soma_st()
local nICMS_PROPRIO := 0
local nICMS_ST      := 0
local nSubst        := 0

  if FAT->Dt_emissao >= ctod("01/05/2008") .and. FAT->Dt_emissao < ctod("04/02/2009")
     if CONFIG->Rel_subst == " " .and. CONFIG->Modelo_fat != "1"
        if ITEN_FAT->Bc_subst > 0 .and. CLI1->Final $ " -N"
           nICMS_ST      +=  ( (ITEN_FAT->Quantidade  * ITEN_FAT->Bc_subst) * (ITEN_FAT->Icms /100))
           nICMS_PROPRIO +=  ( ( ITEN_FAT->Quantidade * ITEN_FAT->Vl_unitar ) * ( ITEN_FAT->Icms / 100 ) )
        endif

        nSubst := nICMS_ST - nICMS_PROPRIO
     endif
  endif

  if FAT->Dt_emissao >= ctod("04/02/2009") .and. FAT->Dt_emissao <= ctod("10/08/2009")
     if CONFIG->Rel_subst == " " .and. CONFIG->Modelo_fat != "1"
        if ITEN_FAT->Bc_subst > 0 .and. CLI1->Final $ " -N"
           nICMS_ST      +=  ( (ITEN_FAT->Quantidade  * ITEN_FAT->Bc_subst) * (ITEN_FAT->Icms /100))
           nICMS_PROPRIO +=  ( ( ITEN_FAT->Quantidade * ITEN_FAT->vl_unitar ) * ( 7 / 100 ) )
        endif

        nSubst := nICMS_ST - nICMS_PROPRIO
     endif
  endif

  if FAT->Dt_emissao >= ctod("11/08/2009")
     if CONFIG->Rel_subst == " " .and. CONFIG->Modelo_fat != "1"
        if ITEN_FAT->Bc_subst > 0 .and. CLI1->Final $ " -N"
           nICMS_ST      +=  ( (ITEN_FAT->Quantidade  * ITEN_FAT->Bc_subst) * (ITEN_FAT->Icms /100))
           nICMS_PROPRIO +=  ( ( ITEN_FAT->Quantidade * ITEN_FAT->vl_unitar ) * ( ITEN_FAT->Icms / 100 ) )
        endif

        nSubst := nICMS_ST - nICMS_PROPRIO
     endif
  endif


return nSubst

function qconv_st()
local nICMS_PROPRIO := 0
local nICMS_ST      := 0
local nSubst        := 0

  if CONVENIO->Dt_emissao >= ctod("04/02/2009")
     if ITEN_CON->Bc_subst > 0 .and. CLI1->Final $ " -N"
        if ITEN_CON->Baixado
           nICMS_ST      +=  ( (ITEN_CON->Quant_ret  * ITEN_CON->Bc_subst) * (ITEN_CON->Icms /100))
           nICMS_PROPRIO +=  ( ( ITEN_CON->Quant_ret * ITEN_CON->vl_unitar ) * ( 7 / 100 ) )
        else
           nICMS_ST      +=  ( (ITEN_CON->Quantidade  * ITEN_CON->Bc_subst) * (ITEN_CON->Icms /100))
           nICMS_PROPRIO +=  ( ( ITEN_CON->Quantidade * ITEN_CON->vl_unitar ) * ( 7 / 100 ) )
        endif
     endif

     nSubst := nICMS_ST - nICMS_PROPRIO
  endif

return nSubst


function qemp_st()
local nICMS_PROPRIO := 0
local nICMS_ST      := 0
local nSubst        := 0

  if EMPENHO->Dt_emissao >= ctod("04/02/2009") .and. EMPENHO->Dt_emissao <= ctod("10/08/2009")
     if ITEN_EMP->Bc_subst > 0 .and. CLI1->Final $ " -N"
        nICMS_ST      +=  ( (ITEN_EMP->Quantidade  * ITEN_EMP->Bc_subst) * (ITEN_EMP->Icms /100))
        nICMS_PROPRIO +=  ( ( ITEN_EMP->Quantidade * ITEN_EMP->vl_unitar ) * ( 7 / 100 ) )
     endif

     nSubst := nICMS_ST - nICMS_PROPRIO
  endif

return nSubst

function ImpDataVenc()

   if DUP_FAT->Dias > 0
      dtoc(FAT->Dt_emissao+DUP_FAT->Dias)
   else
      dtoc(DUP_FAT->Data_venc)
   endif

return

function DataVenc()
local dData
   if DUP_FAT->Dias > 0
      dData := FAT->Dt_emissao+DUP_FAT->Dias
   else
      dData := DUP_FAT->Data_venc
   endif

return dData

function xmlAbre(nWindowHeigth,nWindowWidth,nTopX,nTopY)
local cXml := ""

	cXml := '<?xml version="1.0"?>'+chr(13)+chr(10)
	cXml += '<?mso-application progid="Excel.Sheet"?>'+chr(13)+chr(10)
	cXml += '<Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet"'+chr(13)+chr(10)
	cXml += 'xmlns:o="urn:schemas-microsoft-com:office:office"'+chr(13)+chr(10)
	cXml += 'xmlns:x="urn:schemas-microsoft-com:office:excel"'+chr(13)+chr(10)
	cXml += 'xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"'+chr(13)+chr(10)
    cXml += 'xmlns:html="http://www.w3.org/TR/REC-html40">'+chr(13)+chr(10)
    cXml += '<DocumentProperties xmlns="urn:schemas-microsoft-com:office:office">'+chr(13)+chr(10)
    cXml += '<Author>Sistema Faturamento</Author>'+chr(13)+chr(10)
    cXml += '<LastAuthor>Sistema Faturamento</LastAuthor>'+chr(13)+chr(10)
    cXml += '<Created>'+ strzero(year(date()),4)+'-'+strzero(month(date()),2)+'-'+strzero(day(date()),2)+'T01:29:55Z</Created>'+chr(13)+chr(10)
    cXml += '<Company>EPB Informatica Ltda</Company>'+chr(13)+chr(10)
    cXml += '<Version>11.9999</Version>'+chr(13)+chr(10)
    cXml += '</DocumentProperties>'+chr(13)+chr(10)
    cXml += '<ExcelWorkbook xmlns="urn:schemas-microsoft-com:office:excel">'+chr(13)+chr(10)
    cXml += '<WindowHeight>'+alltrim(str(nWindowHeigth))+'</WindowHeight>'+chr(13)+chr(10)
    cXml += '<WindowWidth>'+alltrim(str(nWindowWidth))+'</WindowWidth>'+chr(13)+chr(10)
    cXml += '<WindowTopX>'+alltrim(str(nTopX))+'</WindowTopX>'+chr(13)+chr(10)
    cXml += '<WindowTopY>'+alltrim(str(nTopY))+'</WindowTopY>'+chr(13)+chr(10)
    cXml += '<ProtectStructure>False</ProtectStructure>'  +chr(13)+chr(10)
    cXml += '<ProtectWindows>False</ProtectWindows>'+chr(13)+chr(10)
    cXml += '</ExcelWorkbook>'+chr(13)+chr(10)
    cXml += '<Styles>'+chr(13)+chr(10)

return cXml

function xmlAbrePasta(cNome)
local cXml := ""
    cXml := '<Worksheet ss:Name="'+cNome+'">'+chr(13)+chr(10)
    cXml += '<Table ss:DefaultRowHeight="15">'+chr(13)+chr(10)
return cXml

function xmlFechaPasta(nLinhaIni,nColunaIni,nLinhaFim,nColunaFim,cColuna,cOrdem)
local cXml := ""

    cXml := '</Table>'+chr(13)+chr(10)
	if nLinhaIni != NIL
	   cXml += xmlSort(nLinhaIni,nColunaIni,nLinhaFim,nColunaFim,cColuna,cOrdem)
	endif  
    cXml += '</Worksheet>'+chr(13)+chr(10)

return cXml

function xmlFecha()
local cXml := ""

    cXml := '</Workbook>'+chr(13)+chr(10)
return cXml

function xmlAbreLinha(nAltura,cStyle,nAutoFit)
local cXml := ""
	 cXml := '<Row'+xmlrowCfg(nAltura,cStyle,nAutoFit)+ '>'+chr(13)+chr(10)
return cXml

function xmlRowCfg(nAltura,cStyle,nAutoFit)
local lusaEspacoNoRetorno := .F.

   if nAltura != NIL
      lusaEspacoNoRetorno := .T.
   endif
   
   if cStyle != NIL
      lusaEspacoNoRetorno := .T.
   endif
   
   if nAutoFit != NIL
      lusaEspacoNoRetorno := .T.
   endif

return iif(lUsaEspacoNoRetorno,' ','')+xmlAutoFit(nAutoFit) + xmlAltura(nAltura) + xmlStyleId(cStyle)

function xmlAutoFit(nAutoFit)
return iif(nAutoFit != NIL,' ss:AutoFitHeight="'+alltrim(str(nAutoFit))+'" ','')

function xmlAltura(nAltura)
return iif(nAltura != NIL,' ss:Height="'+alltrim(str(nAltura))+'" ','')

function xmlFechaLinha()
local cXml := ""

	 cXml := '</Row>' +chr(13)+chr(10)
return cXml

function xmlFechaStyles()
local cXml := ""

	 cXml := '</Styles>' +chr(13)+chr(10)
return cXml

function xmlCell(cTipo,cValor,cStyleID,nIndex,nSpan)
local cXml := ""
    cXml := '<Cell'+ xmlCellCfg(cStyleID,nIndex,nSpan) +'><Data ss:Type="'+cTipo+'">'+cValor+'</Data></Cell>'+chr(13)+chr(10)
return cXml

static function xmlIndex(nIndex)
local xml := ""
  xml := iif(nIndex != NIL,' ss:Index="'+alltrim(str(nIndex))+'" ','')
return xml

static function xmlMergeAcross(nMergeAcross)
local xml := ""
  xml := iif(nMergeAcross != NIL,' ss:MergeAcross="'+alltrim(str(nMergeAcross))+'" ','')
return xml

static function xmlStyleId(nId)
local xml := ""
  xml := iif(nId != NIL,' ss:StyleID="'+nId+'" ','')
return xml

static function xmlCellCfg(cStyle,nIndex,nSpan)
local lRetornaEspaco := .F.

   if cStyle != NIL
      lRetornaEspaco := .T.
   endif
   
   if nIndex != NIL
      lRetornaEspaco := .T.
   endif
   
   if nSpan != NIL
      lRetornaEspaco := .T.
   endif

return iif(lRetornaEspaco,' ','') + xmlStyleId(cStyle) + xmlIndex(nIndex) + xmlMergeAcross(nSpan)



function xmlStyle(id)
local cXml := ""
	 cXml := '<Style ss:ID="'+id+'">'+chr(13)+chr(10)
	 cXml += '<Alignment ss:Horizontal="Center" ss:Vertical="Center"/>'+chr(13)+chr(10)
	 cXml += '<Borders>'+chr(13)+chr(10)
	 cXml += '<Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
	 cXml += '<Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
	 cXml += '<Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
	 cXml += '<Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
	 cXml += '</Borders>'+chr(13)+chr(10)
	 cXml += '<Font ss:Size="12" ss:Bold="1"/>'+chr(13)+chr(10)
	 cXml += '<Interior ss:Color="#AAAAAA" ss:Pattern="Solid"/>'+chr(13)+chr(10)
	 cXMl += '</Style>'+chr(13)+chr(10)
	 
return cXml



function xmlSort(nLinhaIni,nColunaIni,nLinhaFim,nColunaFim,cColuna,cOrdem)
local xml := ""

   xml += '<WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">'+chr(13)+chr(10)
   xml += '<PageSetup>'+chr(13)+chr(10)
   xml += '<Header x:Margin="0.49212598499999999"/>'+chr(13)+chr(10)
   xml += '<Footer x:Margin="0.49212598499999999"/>'+chr(13)+chr(10)
   xml += '<PageMargins x:Bottom="0.984251969" x:Left="0.78740157499999996"'+chr(13)+chr(10)
   xml += 'x:Right="0.78740157499999996" x:Top="0.984251969"/>'+chr(13)+chr(10)
   xml += '</PageSetup>'+chr(13)+chr(10)
   xml += '<Unsynced/>'+chr(13)+chr(10)
   xml += '<Selected/>'+chr(13)+chr(10)
   xml += '<Panes>'+chr(13)+chr(10)
   xml += '<Pane>'+chr(13)+chr(10)
   xml += '<Number>3</Number>'+chr(13)+chr(10)
   xml += '<ActiveRow>3</ActiveRow>'+chr(13)+chr(10)
   xml += '<RangeSelection>R'+alltrim(str(nLinhaIni))+'C'+alltrim(str(nColunaIni))+':R'+alltrim(str(nLinhaFim))+'C'+alltrim(str(nColunaFim))+'</RangeSelection>'+chr(13)+chr(10)
   xml += '</Pane>'+chr(13)+chr(10)
   xml += '</Panes>'+chr(13)+chr(10)
   xml += '<ProtectObjects>False</ProtectObjects>'+chr(13)+chr(10)
   xml += '<ProtectScenarios>False</ProtectScenarios>'+chr(13)+chr(10)
   xml += '</WorksheetOptions>'+chr(13)+chr(10)
   xml += '<Sorting xmlns="urn:schemas-microsoft-com:office:excel">'+chr(13)+chr(10)
   xml += '<Sort>Colunas '+alltrim(cColuna)+'</Sort>'+chr(13)+chr(10)
   if cOrdem == "D"
      xml += '<Descending/>'+chr(13)+chr(10)
   else
      xml += '<Ascending/>'+chr(13)+chr(10)
   endif    
   xml += '</Sorting>'+chr(13)+chr(10)
return xml

function strReplace(cTROCADO)

   cTROCADO := strtran(cTROCADO,"'","\'")
   cTROCADO := strtran(cTROCADO,'"','\"')
   //cTROCADO := strtran(cTROCADO,"\","\\")
   cTROCADO := strtran(cTROCADO,"€","C")
   cTROCADO := strtran(cTROCADO,"‡","C")
   cTROCADO := strtran(cTROCADO,"§",".")
   cTROCADO := strtran(cTROCADO,"¦","A")
   cTROCADO := strtran(cTROCADO,"‚","A")
   cTROCADO := strtran(cTROCADO,"ƒ","A")
   cTROCADO := strtran(cTROCADO,"„","A")
   cTROCADO := strtran(cTROCADO,"…","A")
   cTROCADO := strtran(cTROCADO,"†","A")
   cTROCADO := strtran(cTROCADO,"ˆ","E")
   cTROCADO := strtran(cTROCADO,"‰","E")
   cTROCADO := strtran(cTROCADO,"Š","E")
   cTROCADO := strtran(cTROCADO,"‹","I")
   cTROCADO := strtran(cTROCADO,"Œ","I")
   cTROCADO := strtran(cTROCADO,"","I")
   cTROCADO := strtran(cTROCADO,"“","O")
   cTROCADO := strtran(cTROCADO,"Ž","A")
   cTROCADO := strtran(cTROCADO,"","A")
   cTROCADO := strtran(cTROCADO,"","E")
   cTROCADO := strtran(cTROCADO,"“","O")
   cTROCADO := strtran(cTROCADO,"”","O")
   cTROCADO := strtran(cTROCADO,"•","O")
   cTROCADO := strtran(cTROCADO,"–","O")
   cTROCADO := strtran(cTROCADO,"—","O")
   cTROCADO := strtran(cTROCADO,"™","O")
   cTROCADO := strtran(cTROCADO,"š","U")
   cTROCADO := strtran(cTROCADO," ","A")
   cTROCADO := strtran(cTROCADO,"¡","I")
   cTROCADO := strtran(cTROCADO,"¢","O")
   cTROCADO := strtran(cTROCADO,"£","U")
   cTROCADO := strtran(cTROCADO,"¤","N")
   cTROCADO := strtran(cTROCADO,"&","E")
   cTROCADO := strtran(cTROCADO,"ø",".")
   cTROCADO := strtran(cTROCADO,",",".")
   cTROCADO := strtran(cTROCADO,chr(13)," ")
   cTROCADO := strtran(cTROCADO,chr(10)," ")
   //cTROCADO := strtran(cTROCADO,"(","")
   //cTROCADO := strtran(cTROCADO,")","")

return(cTROCADO)

function strTiraBarra(cTROCADO)

   cTROCADO := strtran(cTROCADO,"\","")
   
return(cTROCADO)


function calculaTotalSubst(cTIPO)
   local nVU       := 0
   local nBC_Icm   := 0
   local nTTBC_Icm := 0
   local nIcm      := 0
   local nTTIcm    := 0
   local nIpi      := 0
   local nTTIpi    := 0
   local nBC_ST    := 0
   local nTTBC_ST  := 0
   local nST       := 0
   local nTTST     := 0
   local nSTPG     := 0
   local nTTSTPG   := 0
   local nMVA      := 0
   local nALIQ_INT := 0
   local nALIQ_ICM := 0
   local cPAI      := ""
   local cFILHO    := ""
   local cID       := ""
   
   if ! quse(XDRV_CL,"IT_CLASS",{})
      qmensa("Nao foi possivel abrir MVAs dos produtos","BL") 
   endif
   
   if cTIPO == NIL
      cPAI := "FAT"
	  cFILHO := "ITEN_FAT"
	  cID     := "num_fat"
   endif
   
   if cTIPO == "FAT"
      cPAI := "FAT"
	  cFILHO := "ITEN_FAT"
	  cID     := "num_fat"
   endif   
   
   if cTIPO == "PEND"
      cPAI := "PEND"
	  cFILHO := "ITEM_PEN"
	  cID     := "cod_pend"
   endif
   
   PROD->(Dbsetorder(4))
   IT_CLASS->(dbsetorder(2))
   
   CLI1->(Dbseek((cPAI)->Cod_cli))
   CGM->(Dbseek(CLI1->Cgm_ent))
   
   (cFILHO)->(Dbseek((cPAI)->Codigo))

   ESTADO->(dbseek(CGM->Estado))
   nALIQ_INT :=  ESTADO->Aliq_inter
   
   do while ! (cFILHO)->(eof()) .and. (cFILHO)->&(cID) == (cPAI)->Codigo

      PROD->(Dbseek((cFILHO)->Cod_prod))

      if IT_CLASS->(dbseek(PROD->Cod_Class+CGM->Estado))
         nMVA := IT_CLASS->Mva
      endif

      if nMVA > 0
	  
	     nVU := round((cFILHO)->Vl_unitar,2)

         nTTBC_Icm += ((cFILHO)->Quantidade * nVU)
         nBC_Icm := (cFILHO)->Quantidade * nVU

         nIcm    := ( ( (cFILHO)->Quantidade * nVU  ) * ((cFILHO)->Icms/100) )
         nTTIcm  += ( ( (cFILHO)->Quantidade * nVU  ) * ((cFILHO)->Icms/100) )

         nIPI    :=  ( ( (cFILHO)->Quantidade * nVU ) * ( PROD->Ipi / 100 ) )
         nTTIPI  +=  ( ( (cFILHO)->Quantidade * nVU ) * ( PROD->Ipi / 100 ) )

         nBC_ST   := (nBC_ICM + nIPI) + ( (nBC_ICM + nIPI) * ( nMVA / 100) )
         nTTBC_ST += (nBC_ICM + nIPI) + ( (nBC_ICM + nIPI) * ( nMVA / 100) )

         nST     := ( nBC_ST * (nALIQ_INT/100))
         nTTST   += ( nBC_ST * (nALIQ_INT/100))

         nSTPG  := nST - nIcm
		 
		 nALIQ_ICM := (cFILHO)->Icms
		 nTTSTPG += (nST - nIcm )

      endif
	  
      (cFILHO)->(Dbskip())

   enddo
   
   IT_CLASS->(dbclosearea())
   
   if ! CGM->Estado $ "PR"
      nTTSTPG := 0
   endif	  

return 0

function null(cValor,lConstraint)

if lConstraint == NIL
   lConstraint := .T.
endif   

return iif(empty(cValor) .or.! lConstraint,"NULL",cValor)















