function funcoes

/////////////////////////////////////////////////////////////////////////////
function view_agenc (XX,YY,ZZ)
   AGE_CED->(qview(XX,YY,@ZZ,"9999",NIL,.T.,NIL,{{"Codigo/Codigo",1},{"Descricao/Nome",2}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
return


/////////////////////////////////////////////////////////////////////////////
function view_layout (XX,YY,ZZ)
   LAYOUT->(qview(XX,YY,@ZZ,"9999",NIL,.T.,NIL,{{"Codigo/Codigo",1},{"Descricao/Nome",2},{"Convenio/Convenio",0},{"Carteira/Carteira",0}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
return

/////////////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////////////////////
function view_cart (XX,YY,ZZ)
   CARTAO->(qview(XX,YY,@ZZ,"99999",NIL,.T.,NIL,{{"Codigo/Codigo",1},{"Descricao/Descricao",2}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
return
/////////////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////////////////////
function view_pgto (XX,YY,ZZ)
   FORM_PGT->(qview(XX,YY,@ZZ,"99999",NIL,.T.,NIL,{{"Codigo/Codigo",1},{"Descricao/Nome",2}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
return
/////////////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////////////////////
function view_FILIAL (XX,YY,ZZ)
   FILIAL->(qview(XX,YY,@ZZ,"9999",NIL,.T.,NIL,{{"Codigo/Codigo",1},{"left(RAZAO,30)/Raz„o",2},{"busca_mun()/Municipio",0}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
return

// FUNCAO PARA BUSCAR MUNICIPIO NO CGM ______________________________________

function busca_mun
    CGM->(dbseek(FILIAL->Cgm))
return(CGM->Municipio)

// VIEW PADRAO PARA SITUACAO _______________________________________________

function view_situa (XX,YY,ZZ)
   SITUA->(qview(XX,YY,@ZZ,"99",NIL,.T.,NIL,{{"Codigo/C¢digo",1},{"Descricao/Descri‡„o",2}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
return

function view_repres (XX,YY,ZZ)
   REPRES->(qview(XX,YY,@ZZ,"99999",NIL,.T.,NIL,{{"Codigo/C¢digo",1},{"Razao/Razao",2}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
return


// VIEW PADRAO PARA TIPO_DOC ________________________________________________

function view_doc (XX,YY,ZZ)
   TIPO_DOC->(qview(XX,YY,@ZZ,"99",NIL,.T.,NIL,{{"Codigo/C¢digo",1},{"Descricao/Descri‡„o",2}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
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

// CODIGO E DESCRICAO DOS BANCOS ______________________________________________

function view_banco ( LL , CC , XX )
   BANCO->(qview(LL,CC,@XX,"@R 99999",NIL,.T.,NIL,{{"Codigo/C¢digo",1},{"Descricao/Nome",2},{"Banco/Banco",0}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
return

// VIEW PADRAO PARA TIPOCONT ________________________________________________

function view_tipo (XX,YY,ZZ)
   TIPOCONT->(qview(XX,YY,@ZZ,"999999",NIL,.T.,NIL,{{"Descricao/Descri‡„o",2},{"Codigo/C¢digo",1}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
return

/////////////////////////////////////////////////////////////////////////////
// VIEW PADRAO PARA FUNCIONARIOS ____________________________________________

function view_fun (XX,YY,ZZ)
   FUN->(qview(XX,YY,@ZZ,"999999",NIL,.T.,NIL,{{"Matricula/Matr¡cula",1},{"Nome/Nome",1}},"C",{"Keyb(left(Matricula,6))",NIL,NIL,NIL}))
return

// CODIGO E RAZAO DOS CLIENTES ______________________________________________

function view_cli ( LL , CC , XX )
      CLI1->(qview(LL,CC,@XX,"@!",NIL,.T.,NIL,{{"Razao/Raz„o",2},{"Codigo/C¢digo",1}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
return

// CODIGO E DESCRICAO DOS SETORES____________________________________________

function view_set ( LL , CC , XX )
      SETOR->(qview(LL,CC,@XX,"@!",NIL,.T.,NIL,{{"Descricao/Descri‡„o",2},{"Codigo/C¢digo",1}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
return

/////////////////////////////////////////////////////////////////////////////
// VIEW PADRAO PARA CENTRO DE CUSTO _________________________________________

function view_ccusto (XX,YY,ZZ)
   CCUSTO->(qview(XX,YY,@ZZ,"9999",NIL,.T.,NIL,{{"Descricao/Descri‡„o",2},{"Codigo",1}},"C",{"keyb(right(Codigo,4))",NIL,NIL,NIL}))
return

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
// ABRE ARQUIVO SH_CONTA P/ INTERFACE COM CONTABIL (Q-SYS) __________________

function fu_abre_conta
   if ! quse(XDRV_TS,"SH_CONTA",{"SH_CONTA"})
      qmensa("N„o foi possivel abrir SH_CONTA.DBF !","B")
      return .F.
   endif
return .T.

/////////////////////////////////////////////////////////////////////////////
// ABRE ARQUIVO TIPO_RPC DA TESOURARIA DA IQ ________________________________

function fu_abre_tiporpc
   if ! quse(XPATHTESO,"TIPORPC",{"TIPORPC","TIPO_NO"})
      qmensa("N„o foi possivel abrir TIPORPC.DBF !","B")
      return .F.
   endif
return .T.

/////////////////////////////////////////////////////////////////////////////
// ABRE ARQUIVO ART_HIST DA CONTABILIDADE DA IQ _____________________________

function fu_abre_hist
   if ! quse(XPATHCT1,"ART_HIST",{"ART_HIST"})
      qmensa("N„o foi poss¡vel abrir ART_HIST.DBF !","B")
      return .F.
   endif
return .T.

/////////////////////////////////////////////////////////////////////////////
// ABRE ARQUIVO SH_RECEB DO CONTAS A RECEBER DA Q-SYS _______________________

function fu_abre_sh_receb
   if ! quse(XDRV_RB,"SH_RECEB")
      qmensa("N„o foi poss¡vel abrir SH_RECEB.DBF !","B")
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
           if ! quse(XDRV_TV , "CLI1",{"CL1CODIG","CL1RAZAO","CL1CGC"})
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

/////////////////////////////////////////////////////////////////////////////
// ABRE ARQUIVO SH_PROCT P/ INTERFACE COM CONTABILIDADE (Q-SYS) ____________

function fu_abre_prov
   if ! quse(XDRV_CT,"SH_PROCT")
      qmensa("N„o foi possivel abrir SH_PROCT.DBF !","B")
      return .F.
   endif
return .T.

