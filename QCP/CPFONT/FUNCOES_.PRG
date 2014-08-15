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

function funcoes

/////////////////////////////////////////////////////////////////////////////
// VIEW PADRAO PARA PLANO DE CONTAS _________________________________________
function view_planfin ( LL , CC , XX )
   PLAN_FIN->(dbsetfilter({|| right(PLAN_FIN->codigo,5) != "     " .and. left(PLAN_FIN->Codigo,2) == "02"}))
   PLAN_FIN->(qview(LL,CC,@XX,"@R 99999",NIL,.T.,NIL,{{"left(Descricao,40)/Descri‡„o",2},{"right(codigo,5)/C¢digo",3}},"C",{"keyb(right(Codigo,5))",NIL,NIL,NIL}))
return

function view_plan ( LL , CC , XX )
   PLAN->(qview(LL,CC,@XX,"@R 99999-9",NIL,.T.,NIL,{{"Codigo/C¢digo",1},{"Descricao/Descri‡„o",2},{"Reduzido/C¢d.Reduz.",3}},"C",{"keyb(Reduzido)",NIL,NIL,NIL}))
return


function view_Cli ( LL , CC , XX )
   CLI1->(qview(LL,CC,@XX,"@R 99999",NIL,.T.,NIL,{{"Codigo/C¢digo",1},{"Razao/Razao",2}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
return

function view_resp ( LL , CC , XX )
   RESP_REP->(qview(LL,CC,@XX,"@R 99999",NIL,.T.,NIL,{{"Codigo/C¢digo",1},{"Nome/Nome",2}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
return


function view_designer ( LL , CC , XX )
   DESIGNER->(qview(LL,CC,@XX,"@R 999",NIL,.T.,NIL,{{"Codigo/C¢digo",1},{"Nome/Nome",2}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
return




// CODIGO E DESCRICAO DA NATUREZA DE OPERACAO _________________________________

function view_natop( LL , CC , XX )
   NATOP->(qview(LL,CC,@XX,"@R 9.99",NIL,.T.,NIL,{{"Nat_Cod/C¢digo",1},{"Nat_Desc/Descri‡„o",2}},"C",{"keyb(Nat_Cod)",NIL,NIL,NIL}))
return

// VIEW PADRAO PARA TIPOCONT ________________________________________________

function view_tipo (XX,YY,ZZ)
   TIPOCONT->(qview(XX,YY,@ZZ,"999999",NIL,.T.,NIL,{{"Descricao/Descri‡„o",2},{"Codigo/C¢digo",1}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
return

function view_cfop( LL , CC , XX )
   CFOP->(qview(LL,CC,@XX,"@R 9.999",NIL,.T.,NIL,{{"Nat_Cod/C¢digo",1},{"Nat_Desc/Descri‡„o",2}},"C",{"keyb(Nat_Cod)",NIL,NIL,NIL}))
return

// CODIGO E DESCRICAO DO REPRESENTANTE ________________________________________

function view_repres( LL , CC , XX )
   REPRES->(qview(LL,CC,@XX,"@R 99999",NIL,.T.,NIL,{{"Codigo/C¢digo",1},{"Razao/Raz„o",2}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
return

function view_eve( LL , CC , XX )
   EVENTOS->(qview(LL,CC,@XX,"@R 99999",NIL,.T.,NIL,{{"Codigo/C¢digo",1},{"Nome/Nome",2}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
return

function view_pav( LL , CC , XX )
   PAVILHAO->(qview(LL,CC,@XX,"@R 99999",NIL,.T.,NIL,{{"Codigo/C¢digo",1},{"Descricao/Pavilhao",2}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
return


function view_proj( LL , CC , XX )
   PROJET->(qview(LL,CC,@XX,"@R 99999",NIL,.T.,NIL,{{"Codigo/C¢digo",1},{"Descricao/Descricao",2}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
return



function view_class( LL , CC , XX )
   CLASSIF->(qview(LL,CC,@XX,"@R 99",NIL,.T.,NIL,{{"Codigo/Referencia",1},{"Descricao/Numero",2}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
return

// CODIGO E DESCRICAO DA OS  ________________________________________

function view_os( LL , CC , XX )
   OS->(qview(LL,CC,@XX,"@R 99999",NIL,.T.,NIL,{{"Codigo/C¢digo",1},{"Descricao/Descri‡„o",2}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
return

function view_tip2( LL , CC , XX )
   TIPO->(qview(LL,CC,@XX,"@R 99",NIL,.T.,NIL,{{"Codigo/C¢digo",1},{"Descricao/Descri‡„o",2}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
return

// FUNCAO PARA BUSCAR CENTRO DE CUSTO _________________________________________

function busca_cen
    CCUSTO->(Dbsetorder(4))
    CCUSTO->(dbseek(ORDEM->Centro))
return(left(CCUSTO->Descricao,20))

// FUNCAO PARA BUSCAR FILIAL __________________________________________________

function busca_fil
    FILIAL->(dbseek(ORDEM->Filial))
return(left(FILIAL->Razao,20))

// VIEW DAS ORDENS DE COMPRA __________________________________________________

function view_ordem( LL , CC , XX )
   ORDEM->(qview(LL,CC,@XX,"@R 99999",NIL,.T.,NIL,{{"Codigo/C¢digo",1},{"Data/Data",2},{"busca_cen()/Centro",0},{"busca_fil()/Filial",0}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
return


// SIGLA E ESTADO DA NOTA FISCAL ______________________________________________

function view_estado ( LL , CC , XX )
   ESTADO->(qview(LL,CC,@XX,"@!",NIL,.T.,NIL,{{"Est_Sig/Sigla",1},{"Est_Desc/Descri‡„o",2}},"C",{"keyb(Est_Sig)",NIL,NIL,NIL}))
return

/////////////////////////////////////////////////////////////////////////////
// VIEW PADRAO PARA FORNECEDOR ______________________________________________

function view_forn1 ( LL , CC , XX )
   FORN->(qview(LL,CC,@XX,"@R 99999",NIL,.T.,NIL,{{"Codigo/C¢digo",1},{"Razao/Descricao",2}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
return

function view_fabr ( LL , CC , XX )
   FABRICA->(qview(LL,CC,@XX,"@R 99999",NIL,.T.,NIL,{{"Codigo/C¢digo",1},{"Razao/Descricao",2}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
return


/////////////////////////////////////////////////////////////////////////////
// VIEW PADRAO PARA COTACAO ______________________________________________

function view_cota ( LL , CC , XX )
   TOMA_PRE->(qview(LL,CC,@XX,"@R 99999",NIL,.T.,NIL,{{"Codigo/C¢digo",1},{"Data/Data",2},{"left(Fornecedor,20)/Fornecedor",3}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
return


// CODIGO E DESCRICAO DO FORNECEDOR DA MERCADORIA _____________________________

function view_forn ( LL , CC , XX )
   FORN->(qview(LL,CC,@XX,"@R 99999",NIL,.T.,NIL,{{"Razao/Raz„o",2},;
                                                  {"Codigo/C¢digo",1}},;
                                                  "C",;
                                                  {"keyb(Codigo)","i_alt_forn",NIL,NIL},;
                                                  NIL,;
                                                  "<ESC>/ALT-O/ALT-P/<A>ltera"))
return

// PARA ALTERACAO DE FORNECEDORES DENTRO DE LANCAMENTOS _______________________

function i_alt_forn
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   if ( cOPCAO := upper(chr(cOPCAO)) ) == "A"
      ef_altera_forn()
   endif
   setcursor(nCURSOR)
return ""

// PARA ALTERACAO DE FORNECEDORES DENTRO DE LANCAMENTO ________________________

function ef_altera_forn
   local aEDICAO := {}
   local bESCAPE := {||(XNIVEL==1.and.lastkey()==27).or.;
                       (XNIVEL==2.and.cOPCAO=="A".and.!XFLAG)}
   local lCONF
   FORN->(qpublicfields())
   FORN->(qcopyfields())

   qlbloc(6,3,"B201G","QBLOC.GLO",1)

      XNIVEL := 1
      qrsay ( XNIVEL++ , FORN->Codigo   )
      qrsay ( XNIVEL++ , FORN->Razao    )
      qrsay ( XNIVEL++ , FORN->Endereco )
      qrsay ( XNIVEL++ , FORN->Cep ,"@R 99999-999")
      qrsay ( XNIVEL++ , FORN->Cgm      ) ; CGM->(dbseek(FORN->Cgm))
      qrsay ( XNIVEL++ , CGM->Municipio+"/"+CGM->Estado )
      qrsay ( XNIVEL++ , FORN->Fone     )
      qrsay ( XNIVEL++ , FORN->Fax      )
      qrsay ( XNIVEL++ , FORN->Cgc ,"@R 99.999.999/9999-99")
      qrsay ( XNIVEL++ , FORN->Inscricao)

      aadd(aEDICAO,{{ || qgetx(-1,0,@fCODIGO   ,"@!",NIL,cOPCAO=="I") } ,"CODIGO"   })
      aadd(aEDICAO,{{ || qgetx(-1,0,@fRAZAO    ,"@!",NIL,cOPCAO=="I") } ,"RAZAO"    })
      aadd(aEDICAO,{{ || qgetx(-1,0,@fENDERECO ,"@!") }                 ,"ENDERECO" })
      aadd(aEDICAO,{{ || qgetx(-1,0,@fCEP      ,"@R 99999-999") }       ,"CEP"      })
      aadd(aEDICAO,{{ || view_cgm(-1,0,@fCGM        ) }                 ,"CGM"      })
      aadd(aEDICAO,{{ || NIL                          }                 ,NIL        })
      aadd(aEDICAO,{{ || qgetx(-1,0,@fFONE     ,"@9") }                 ,"FONE"     })
      aadd(aEDICAO,{{ || qgetx(-1,0,@fFAX      ,"@9") }                 ,"FAX"      })
      aadd(aEDICAO,{{ || qgetx(-1,0,@fCGC      ,"@R 99.999.999/9999-99") } ,"CGC"   })
      aadd(aEDICAO,{{ || qgetx(-1,0,@fINSCRICAO,"@!") }                 ,"INSCRICAO"})
      aadd(aEDICAO,{{ || lCONF := qconf("Confirma altera‡„o ?") },NIL})

      // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

      do while .T.

         XNIVEL := 1
         XFLAG := .T.

         // LOOP PARA ENTRADA DOS CAMPOS ____________________________________

         do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
            eval ( aEDICAO [XNIVEL,1] )
            if eval ( bESCAPE ) ; FORN->(qreleasefields()) ; return ; endif
            if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
            iif ( XFLAG , XNIVEL++ , XNIVEL-- )
         enddo

         // GRAVACAO _____________________________________________________

         if ! lCONF ; return ; endif

         if FORN->(qrlock())
            FORN->(qreplacefields())
            FORN->(qunlock())
         else
            qm2()
         endif

         if cOPCAO == "A"
            exit
         endif

      enddo

      XNIVEL := 6

return

// CRITICAS NA DESCIDA ______________________________________________________

static function i_critica ( cCAMPO )
   qmensa("")
   do case
      case cCAMPO == "CGM"
           if ! CGM->(dbseek(fCGM))
              qmensa("Municipio n„o encontrado !","B")
              return .F.
           endif
           qrsay ( XNIVEL+1 , CGM->Municipio + "/" + CGM->Estado )
   endcase
return .T.

// CODIGO E DESCRICAO DA CONTA ________________________________________________

function view_conta ( LL , CC , XX )
   CONTA->(qview(LL,CC,@XX,"@R 999999",NIL,.T.,NIL,{{"Codigo/C¢digo",1},{"Descricao/Descri‡„o",2}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
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
      SERV->(qview(LL,CC,@XX,"@!",NIL,.T.,NIL,{{"Serv_Desc/Descri‡„o",2},{"Serv_Cod/C¢digo",1}},"C",{"keyb(Serv_Cod)",NIL,NIL,NIL}))
return

// CODIGO E DESCRICAO DOS SERVICOS PRESTADOS (ISS)_____________________________

function view_obs ( LL , CC , XX )
   SERV->(qview(LL,CC,@XX,"@!",NIL,.T.,NIL,{{"Serv_Desc/Descri‡„o",2},{"Serv_Cod/C¢digo",1}},"C",{"keyb(Serv_Desc)",NIL,NIL,NIL}))
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
   qmensa("Informe o ano e mes da tabela no formato AAMM...")
   qgetx(24,60,@fANOMES,"9999")
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
// ABRE ARQUIVO ART_CENT DA CONTABILIDADE DA IQ _____________________________

function fu_abre_ccusto
   if ! quse(XPATHCONTA,"ART_CENT",{"ART_CENT","ART_CENT"},"R","CCUSTO")
      qmensa("N„o foi possivel abrir ART_CENT.DBF !","B")
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

/////////////////////////////////////////////////////////////////////////////
// ABRE ARQUIVO EMITENTE DO FATURAMENTO DA IQ _______________________________

function fu_abre_emitente
   if ! quse(XPATHCOMP,"EMITENTE",{"FORN_01","FORN_02","FORN_03","FORN_04","FORN_05","FORN_06"})
      qmensa("N„o foi possivel abrir EMITENTE.DBF !","B")
      return .F.
   endif
return .T.

/////////////////////////////////////////////////////////////////////////////
// ABRE ARQUIVO SH_APCOM P/ INTERFACE COM CONTAS A PAGAR  ___________________

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

/////////////////////////////////////////////////////////////////////////////
// ABRE ARQUIVO SH_PROCT P/ INTERFACE COM CONTABILIDADE _____________________

function fu_abre_proct
   if ! quse(XDRV_CT,"SH_PROCT")
      qmensa("N„o foi possivel abrir SH_PROCT.DBF !","B")
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
// ABRE ARQUIVO LOTES.DBF / INTERFACE COM ESTOQUE (Q-SYS) ___________________

function fu_abre_lotes
   if ! quse(XDRV_CP,"LOTES",{"LOTES1","LOTES2","LOTES3"})
      qmensa("N„o foi possivel abrir LOTES.DBF !","B")
      return .F.
   endif
return .T.

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
   FUN->(qview(XX,YY,@ZZ,"999999",NIL,.T.,NIL,{{"Matricula/Matr¡cula",1},{"left(Nome,40)/Nome",1}},"C",{"Keyb(left(Matricula,6))",NIL,NIL,NIL}))
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
// CODIGO E DESCRICAO DO PRODUTO ____________________________________________

function view_prod ( LL , CC , XX )
   PROD->(qview(LL,CC,@XX,"99999",NIL,.T.,NIL,{{"left(Descricao,35)/Produto",2},{"Cod_fabr/Ref",5},{"Cod_ass/Associado",3},{"Codigo/C¢digo",1}},"C",{"keyb(right(Codigo,5))",NIL,NIL,NIL}))
return

/////////////////////////////////////////////////////////////////////////////
// CODIGO E DESCRICAO DO PRODUTO ____________________________________________

function view_produt ( LL , CC , XX )
   PROD->(qview(LL,CC,@XX,"@R 99999",NIL,.T.,NIL,{{"Codigo/C¢digo",1},{"Descricao/Produto",2}},"C",{"keyb(right(Codigo,5))",NIL,NIL,NIL}))
return

// CODIGO E DESCRICAO DO PRODUTO ____________________________________________

function view_prod1 ( LL , CC , XX )
   PROD->(qview(LL,CC,@XX,"@!",NIL,.T.,NIL,{{"Cod_ass/Assoc.",3},{"left(Descricao,35)/Produto",2}},"C",{"keyb(Cod_ass)",NIL,NIL,NIL}))
return

// CODIGO E DESCRICAO DO PRODUTO ____________________________________________
function view_prod2 ( LL , CC , XX )
   PROD->(qview(LL,CC,@XX,"@R 99",NIL,.T.,NIL,{{"Codigo/C¢digo",1},{"Descricao/Produto",2}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
return

function view_prod3 ( LL , CC , XX )
   PROD->(qview(LL,CC,@XX,"@R 9999",NIL,.T.,NIL,{{"Codigo/C¢digo",1},{"Descricao/Produto",2}},"C",{"keyb(left(Codigo,4))",NIL,NIL,NIL}))
return

/////////////////////////////////////////////////////////////////////////////
// VIEW PADRAO PARA TIPORPC ________________________________________________

function view_tiporpc (XX,YY,ZZ)
   TIPORPC->(qview(XX,YY,@ZZ,"@R 999999",NIL,.T.,NIL,{{"Tp_Des/Descri‡„o",2}},"C",{"keyb(Tp_Tip + Tp_Sub)",NIL,NIL,NIL}))
return

// FORNECEDORES DO PRODUTO __________________________________________________

function view_prfor ( LL , CC , XX )
   PROD_FOR->(Dbsetorder(1))
   PROD_FOR->(qview(LL,CC,@XX,"99999",NIL,.T.,NIL,{{"Cod_forn/Forn.",2},{"busca_for()/Razao Social",0},{"Quant_atu/Qtde",0}},"C",{"keyb(Cod_forn)",NIL,NIL,NIL}))
return
function busca_for
  FORN->(dbsetorder(1))
  FORN->(Dbseek(PROD_FOR->Cod_forn))
return left(FORN->Razao,30)

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
// LANCAMENTO DE GARANTIAS DENTRO DO CADASTRO DE PRODUTO ____________________

function lanc_garan

   local lCONF
   local aEDICAO := {}
   local bESCAPE := {||(XNIVEL==1.and.!XFLAG).or.;
                       (XNIVEL==1.and.lastkey()==27)}

   private fCOD        := space(5)
   private fCOD_FORNEC := space(5)
   private fCOD_VEICUL := space(5)
   private fCOD_EQUIPT := space(5)
   private fDT_COMPRA  := ctod("")
   private fNR_GARANTI := space(7)
   private fDIAS_GARAN := space(3)
   private fDT_VALIDAD := ctod("")
   private fKILOMETRAG := 0

   qlbloc(07,1,"B201F","QBLOC.GLO",1)

   PROD->(Dbsetorder(4))

   aadd(aEDICAO,{{ || NIL                                           },"COD_PRODUT" })
   aadd(aEDICAO,{{ || NIL                                           },NIL          })
   aadd(aEDICAO,{{ || view_forn1(10,15,@fCOD_FORNEC)                },"COD_FORNEC" })
   aadd(aEDICAO,{{ || NIL                                           },NIL          })
   aadd(aEDICAO,{{ || view_veic(11,15,@fCOD_VEICUL)                 },"COD_VEICUL" })
   aadd(aEDICAO,{{ || NIL                                           },NIL          })
   aadd(aEDICAO,{{ || view_equip(12,15,@fCOD_EQUIPT)                },"COD_EQUIPT" })
   aadd(aEDICAO,{{ || NIL                                           },NIL          })
   aadd(aEDICAO,{{ || qgetx(13,18,@fDT_COMPRA,"@D")                 },"DT_COMPR"   })
   aadd(aEDICAO,{{ || qgetx(13,44,@fNR_GARANTI,"@!")                },"NR_GARAN"   })
   aadd(aEDICAO,{{ || qgetx(13,74,@fDIAS_GARAN,"@!")                },"DIAS_GAR"   })
   aadd(aEDICAO,{{ || qgetx(14,18,@fDT_VALIDAD,"@D")                },"DT_VALID"   })
   aadd(aEDICAO,{{ || qgetx(14,69,@fKILOMETRAG,"99999999")          },"KILOMETR"   })

   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO ____________________________________________________

   XNIVEL := 1
   XFLAG := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE );GARANTIA->(qreleasefields());return;endif
      if ! i_crit( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
      qmensa("")
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif

   if GARANTIA->(iif(cOPCAO=="I",qappend(),qrlock()))

      // AQUI INCREMENTA CODIGO DA GARANTIA  _______________________________

      if cOPCAO == "I" .and. quse(XDRV_FT,"CONFIG",NIL,NIL,"PROV")
         if PROV->(qrlock())
            replace PROV->Cod_gara with PROV->Cod_gara+1
            qmensa("C¢digo Gerado: "+strzero(PROV->Cod_gara,5),"B")
            fCOD := strzero(PROV->Cod_gara,5)
         endif
         PROV->(Dbclosearea())
      endif

      // AGORA GRAVA E DESTRAVA ARQUIVO _____________________________________

      if PROD->(Dbseek(right(fCODIGO,5))) .and. PROD->(qrlock())  // grava numero da garantia no produto
         replace PROD->Garantia with fCOD
      endif

      replace GARANTIA->Codigo      with fCOD
      replace GARANTIA->Cod_produt  with right(fCODIGO,5)
      replace GARANTIA->Cod_fornec  with fCOD_FORNEC
      replace GARANTIA->Cod_veicul  with fCOD_VEICUL
      replace GARANTIA->Cod_equipt  with fCOD_EQUIPT
      replace GARANTIA->Dt_compra   with fDT_COMPRA
      replace GARANTIA->Nr_garanti  with fNR_GARANTI
      replace GARANTIA->Dias_garan  with fDIAS_GARAN
      replace GARANTIA->Dt_validad  with fDT_VALIDAD
      replace GARANTIA->Kilometrag  with fKILOMETRAG

   else
      iif(cOPCAO=="I",qm1(),qm2())
   endif

   dbunlockall()

   if cOPCAO == "I" ; keyboard "I" ; endif

return

/////////////////////////////////////////////////////////////////////////////////
// CRITICAS NA DESCIDA __________________________________________________________

static function i_crit ( cCAMPO )

   qmensa("")

   iif ( cCAMPO == NIL , cCAMPO := "" , NIL )
   if ! XFLAG ; return .T. ; endif

   do case

      case cCAMPO == "COD_PRODUT"

           PROD->(Dbsetorder(4))

           qsay(09,15,fCODIGO)

           if ! PROD->(dbseek(right(fCODIGO,5)))
              qmensa("Produto n„o encontrado !","B")
              return .F.
           endif

           qsay (09,27, left(PROD->Descricao,40) )

      case cCAMPO == "COD_FORNEC"
           if empty(fCOD_FORNEC) ; return .F. ; endif
           fCOD_FORNEC:=strzero(val(fCOD_FORNEC),5)
           qsay(10,15,fCOD_FORNEC)
           if ! FORN->(dbseek(fCOD_FORNEC))
              qmensa("Fornecedor n„o encontrado !","B")
              return .F.
           endif

           qsay(10,23,left(FORN->Razao,54))

      case cCAMPO == "COD_VEICUL"
           fCOD_VEICUL:=strzero(val(fCOD_VEICUL),5)
           qsay(11,15,fCOD_VEICUL)
           if VEICULOS->(dbseek(fCOD_VEICUL))
              qsay(11,23,VEICULOS->Descricao)
           endif

      case cCAMPO == "COD_EQUIPT"
           fCOD_EQUIPT:=strzero(val(fCOD_EQUIPT),5)
           qsay(12,15,fCOD_EQUIPT)
           if EQUIPTO->(dbseek(fCOD_EQUIPT))
              qsay(12,23,EQUIPTO->Descricao)
           endif

      case cCAMPO == "DT_COMPRA"
           if empty(fDT_COMPRA) ; return .F. ; endif

      case cCAMPO == "DIAS_GAR"
           if empty(fDIAS_GARAN) ; return .F. ; endif
           fDT_VALIDAD:= fDT_COMPRA + val(fDIAS_GARAN)

   endcase

return .T.


///////////////////////////////////////////////////////////////////////////
// funcao para transferir os fornecedores ativos para o arquivo morto______

function fu_transf ( cTIPO , cARQ , cCOD )

//   private lTEM_OBRA, lTEM_CONT

   i_transf(cTIPO,cARQ,cCOD,.F.)

return


/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA TRANFERENCIA ENTRE ARQUIVOS (FORN E FORN2) VIVO E MORTO _______

function i_transf ( cTIPO , cARQ , cCOD , lREC )

   // INICIALIZA VARIAVEIS DE "ALIAS" E SALVA ORDEM _________________________

   local cORIG := iif(cTIPO == "1", cARQ , cARQ + cTIPO )
   local cDEST := cARQ + iif(cTIPO=="1","2","")
   local nORD  := (cORIG)->(indexord())

   // VERIFICA SE EXISTE REGISTRO PARA SER TRANSFERIDO ______________________

   if lREC
      (cORIG)->(dbsetorder(iif(cARQ=="FORN",1,)))
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

   local lRET := .T.

   qlbloc(12,20,"BSENHA","QBLOC.GLO",1)

   if qgetsenha(13,43,10) <> cORIGINAL ; lRET := .F. ; endif

   qrbloc(12,20,sBLOC)

return lRET

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
    cXml += '<Author>Sistema Compras</Author>'+chr(13)+chr(10)
    cXml += '<LastAuthor>Sistema Compras</LastAuthor>'+chr(13)+chr(10)
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

function xmlFechaPasta(cNome)
local cXml := ""

    cXml := '</Table>'+chr(13)+chr(10)
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

function xmlLinha(nAltura,cStyle,nAutoFit)
local cXml := ""
	 cXml := '<Row'+xmlrowCfg(nAltura,cStyle,nAutoFit)+ '/>'+chr(13)+chr(10)
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

