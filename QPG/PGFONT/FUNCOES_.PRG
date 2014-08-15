
function funcoes
/////////////////////////////////////////////////////////////////////////////
// VIEW PADRAO PARA PLANO DE CONTAS _________________________________________
function view_plan ( LL , CC , XX )
   PLAN->(qview(LL,CC,@XX,"@R 99999-9",NIL,.T.,NIL,{{"Codigo/C¢digo",1},{"Descricao/Descri‡„o",2},{"Reduzido/C¢d.Reduz.",3}},"C",{"keyb(Reduzido)",NIL,NIL,NIL}))
return

function view_planfin ( LL , CC , XX )
   PLAN_FIN->(dbsetfilter({|| right(PLAN_FIN->codigo,5) != "     " .and. left(PLAN_FIN->Codigo,2) == "02"}))
   PLAN_FIN->(qview(LL,CC,@XX,"@R 99999",NIL,.T.,NIL,{{"left(Descricao,40)/Descri‡„o",2},{"right(codigo,5)/C¢digo",3}},"C",{"keyb(right(Codigo,5))",NIL,NIL,NIL}))
return


function view_proj ( LL , CC , XX )
   PROJET->(qview(LL,CC,@XX,"@R 99999",NIL,.T.,NIL,{{"Codigo/C¢digo",1},{"Descricao/Descri‡„o",2}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
return

function view_eve ( LL , CC , XX )
   EVENTOS->(qview(LL,CC,@XX,"@R 99999",NIL,.T.,NIL,{{"Codigo/C¢digo",1},{"Nome/Nome",2}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
return





// VIEW PADRAO PARA TIPO_DOC ________________________________________________

function view_doc (XX,YY,ZZ)
   TIPO_DOC->(qview(XX,YY,@ZZ,"99",NIL,.T.,NIL,{{"Codigo/C¢digo",1},{"Descricao/Descri‡„o",2}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
return

/////////////////////////////////////////////////////////////////////////////
// VIEW PADRAO PARA EQUIPAMENTOS ____________________________________________

function view_equip ( LL , CC , XX )
   EQUIPTO->(qview(LL,CC,@XX,"@R 99999",NIL,.T.,NIL,{{"Codigo/C¢digo",1},{"Descricao/Descricao",2}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
return

function view_set ( LL , CC , XX )
      SETOR->(qview(LL,CC,@XX,"@!",NIL,.T.,NIL,{{"Descricao/Descri‡„o",2},{"Codigo/C¢digo",1}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
return

/////////////////////////////////////////////////////////////////////////////
function view_desp (XX,YY,ZZ)
   DESPESAS->(qview(XX,YY,@ZZ,"99999",NIL,.T.,NIL,{{"Codigo/Codigo",1},{"Descricao/Descricao",2}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
return

/////////////////////////////////////////////////////////////////////////////
// VIEW PADRAO PARA VEICULOS ________________________________________________

function view_veic ( LL , CC , XX )
   VEICULOS->(qview(LL,CC,@XX,"@R 99999",NIL,.T.,NIL,{{"Codigo/C¢digo",1},{"Descricao/Descricao",2},{"Placa/Placa",0}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
return

// CODIGO E DESCRICAO DO REPRESENTANTE ________________________________________

function view_repres( LL , CC , XX )
   REPRES->(qview(LL,CC,@XX,"@R 99999",NIL,.T.,NIL,{{"Codigo/C¢digo",1},{"Razao/Raz„o",2}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
return

// VIEW PADRAO PARA TIPOCONT ________________________________________________

function view_tipo (XX,YY,ZZ)
   TIPOCONT->(qview(XX,YY,@ZZ,"@R 999999",NIL,.T.,NIL,{{"Codigo/Codigo",1},{"Descricao/Descri‡„o",2}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
return

/////////////////////////////////////////////////////////////////////////////
// VIEW PADRAO PARA TERCEIROS _______________________________________________

function view_terc (XX,YY,ZZ)
   TERCEIRO->(qview(XX,YY,@ZZ,"99999",NIL,.T.,NIL,{{"Codigo/C¢digo",1},{"Nome/Nome",2}},"C",{"Keyb(Codigo)",NIL,NIL,NIL}))
return

/////////////////////////////////////////////////////////////////////////////
// VIEW PADRAO PARA FUNCIONARIOS ____________________________________________

function view_fun (XX,YY,ZZ)
   FUN->(qview(XX,YY,@ZZ,"999999",NIL,.T.,NIL,{{"Matricula/Matr¡cula",1},{"Nome/Nome",1}},"C",{"Keyb(left(Matricula,6))",NIL,NIL,NIL}))
return

// PEDIDOS DE COMPRA  _________________________________________________________

function view_pedcomp ( LL , CC , XX )
   PEDIDO->(qview(LL,CC,@XX,"@!",NIL,.T.,NIL,{{"Codigo/C¢digo",2},{"left(Fornecedor,50)/Fornecedor",7}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
return

// CODIGO E DESCRICAO DOS BANCOS ______________________________________________

function view_banco ( LL , CC , XX )
   BANCO->(qview(LL,CC,@XX,"@R 99999",NIL,.T.,NIL,{{"Codigo/C¢digo",1},{"Descricao/Banco",2}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
return

/////////////////////////////////////////////////////////////////////////////
// VIEW PADRAO PARA FORNECEDORES ___________________________________________

function view_forn (XX,YY,ZZ)
   FORN->(qview(XX,YY,@ZZ,"99999",NIL,.T.,NIL,{{"Razao/Raz„o",2},{"Codigo/C¢digo",1}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
return

/////////////////////////////////////////////////////////////////////////////
// VIEW PADRAO PARA SITUACAO _______________________________________________

function view_situa (XX,YY,ZZ)
   SITUA->(qview(XX,YY,@ZZ,"99",NIL,.T.,NIL,{{"Codigo/C¢digo",1},{"Descricao/Descri‡„o",2}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
return

// CODIGO E DESCRICAO DA SERIE ________________________________________________

function view_serie ( LL , CC , XX )
   SERIE->(qview(LL,CC,@XX,"@R 99",NIL,.T.,NIL,{{"Codigo/C¢digo",1},{"Descricao/Descri‡„o",2}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
return

// CODIGO E DESCRICAO DA SERIE ________________________________________________

function view_especie ( LL , CC , XX )
   ESPECIE->(qview(LL,CC,@XX,"@R 99",NIL,.T.,NIL,{{"Codigo/C¢digo",1},{"Descricao/Descri‡„o",2}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
return

/////////////////////////////////////////////////////////////////////////////
// VIEW PADRAO PARA CGM _____________________________________________________

function view_cgm (XX,YY,ZZ)
   CGM->(qview(XX,YY,@ZZ,"@!",NIL,.T.,NIL,{{"Municipio",2},{"Codigo/C¢digo",1},{"Estado",0}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
return

/////////////////////////////////////////////////////////////////////////////
// VIEW PADRAO PARA CENTRO DE CUSTO _________________________________________

function view_ccusto (XX,YY,ZZ)
   CCUSTO->(qview(XX,YY,@ZZ,"9999",NIL,.T.,NIL,{{"Descricao/Descri‡„o",2},{"Codigo/Codigo",1}},"C",{"keyb(right(Codigo,4))",NIL,NIL,NIL}))
return

/////////////////////////////////////////////////////////////////////////////
function view_FILIAL (XX,YY,ZZ)
   FILIAL->(qview(XX,YY,@ZZ,"9999",NIL,.T.,NIL,{{"Codigo/Codigo",1},{"left(RAZAO,30)/Raz„o",2},{"busca_mun()/Municipio",0}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
return

/////////////////////////////////////////////////////////////////////////////
// VIEW PADRAO PARA VEICULOS_________________________________________________

function view_veiculos (XX,YY,ZZ)
   VEICULOS->(qview(XX,YY,@ZZ,"99999",NIL,.T.,NIL,{{"Descricao/Descri‡„o",2},{"Codigo/Codigo",1}},"C",{"keyb(right(Codigo,5))",NIL,NIL,NIL}))
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA BUSCAR MUNICIPIO NO CGM ______________________________________

function busca_mun
    CGM->(dbseek(FILIAL->Cgm))
return(CGM->Municipio)

/////////////////////////////////////////////////////////////////////////////
// ABRE ARQUIVO SH_CONTA P/ INTERFACE COM CONTABIL (Q-SYS) __________________

function fu_abre_conta
   if ! quse(XDRV_TS,"SH_CONTA",{"SH_CONTA"})
      qmensa("N„o foi possivel abrir SH_CONTA.DBF !","B")
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
// CALCULA DATA DO VENCIMENTO DA PRIMEIRA DUPLICATA CONFORME CONTRATO _______

function fu_calc_data ( dEMISSAO , nDIAS , cTIPO )

   local dRET

   do case

      case cTIPO == "1" // DD

           dRET := dEMISSAO + nDIAS

      case cTIPO == "2" // DFS (semana comeca no sabado)

           do while dow(dEMISSAO) < 7
              dEMISSAO++
           enddo

           dRET := dEMISSAO + nDIAS - 1

      case cTIPO == "3" // DFD

           do while .T.
              if day(dEMISSAO) = 10 .or. day(dEMISSAO) = 20 .or. day(dEMISSAO) = day(qfimmes(dEMISSAO))
                 dRET := dEMISSAO + nDIAS //+ 1
                 exit
              endif
              dEMISSAO++
           enddo

      case cTIPO == "4" // DFQ

           do while .T.
              if day(dEMISSAO) = 15 .or. day(dEMISSAO) = day(qfimmes(dEMISSAO))
                 dRET := dEMISSAO + nDIAS //+ 1
                 exit
              endif
              dEMISSAO++
           enddo

      case cTIPO == "5" // DFM

           dRET := qfimmes(dEMISSAO) //+ 1
           dRET += nDIAS
   endcase

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

return padl(cRET,18)

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

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA SOLICITAR SENHA DE LIBERACAO _________________________________

function fu_check_senha_lib ( cORIGINAL )

   local sBLOC := qsbloc(12,20,15,58)

   qlbloc(12,20,"BSENHA","QBLOC.GLO",1)

   if qgetsenha(13,43,10) <> cORIGINAL ; return .F. ; endif

   qrbloc(12,20,sBLOC)

return .T.

/////////////////////////////////////////////////////////////////////////////
// ABRE ARQUIVO ART_CENT DA CONTABILIDADE DA IQ _____________________________

function fu_abre_ccusto
   if ! quse(XPATHCONTA,"ART_CENT",{"ART_CENT","ART_CENT"},"R","CCUSTO")
      qmensa("N„o foi possivel abrir ART_CENT.DBF !","B")
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
