/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: FOLHA DE PAGAMENTO
// OBJETIVO...: EMISSAO DO DEMONSTRATIVO DA FOLHA DE PAGAMENTO
// ANALISTA...: CARLOS EDUARDO RABELLO NUNES
// PROGRAMADOR: O MESMO
// INICIO.....: JUNHO DE 1994
// OBS........:
// ALTERACOES.:

// RELATORIO DA FOLHA DE PAGAMENTO

#define K_MAX_LIN 57
#define K_LEN_BASE 18

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG) .or. empty(cRESCSN)}

private sBLOCO1 := qlbloc("B501A","QBLOC.GLO") // bloco basico
private sBLOCO2 := qlbloc("B501B","QBLOC.GLO") // tipo de relatorio
private sBLOCO3 := qlbloc("B501C","QBLOC.GLO") // ordem de classificacao
private sBLOCO4 := qlbloc("B501D","QBLOC.GLO") // nivel de quebra
private sBLOCO5 := qlbloc("B501E","QBLOC.GLO") // analitico/sintetico
private sBLOCO6 := qlbloc("B501F","QBLOC.GLO") // resumido/completo
private sBLOCO7 := qlbloc("B501G","QBLOC.GLO") // Rescisoes em Separado

private nDESCGRPS := 0            // descontos na grps
private nINSS_TETO                // teto do iapas (inss)
private nPERC_FGTS                // percentual do fgts
private cRESCSN                   // imprime rescisao S/N
private cPRESSN                   // imprime rescisao S/N
private cTIPOREL                  // tipo de relatorio (mensal ou 13o.)
private cORDEM    := "M"          // ordem de impressao (matricula/nome)
private cQUEBRA   := "1"          // nivel de quebra e totalizacao (geral, filial, centro)
private cANALSINT := "A"          // analitico ou sintetico
private cTITULO                   // titulo principal do relatorio
private cFILIAL                   // filial para filtro
private cCENTRO                   // centro de custo para filtro
private cCURINGA                  // pode ser centro ou filial atual , conf. opcao
private cDADOSCAD := "R"          // tipo de dados cadastrais
private cDADOSFIN := "R"          // tipo de dados financeiros
private lAPOS_SUBTOTAL  := .F.    // flag para indicar fim do sub-total
private lAPOS_CABECALHO := .F.    // flag para indicar momento apos o cabecalho
private lSAIFORA                  // flag para sair apos impressao de 1 centro, filial ou depto
private cTIPO                     // tipo de totalizacao (FILIAL, CENTRO OU DEPTO)
private aEDICAO   := {}           // vetor para os campos de entrada de dados
private aBENEF    := {}           // vetor com os beneficios cadastrados
private bPROV                     // code block para proventos
private bDESC                     // code block para descontos
private lPRIM := .F.
private X_NomeCusto:=Space(25)
// private lTEM_LANCAMENTO := .F. // Verifica se tem lancamento para nao somar os funcionarios sem lancamento

private aFUN := {{},{}}           // vetor com os dados do funcionario
private aTOT := {{space(10),{}}}  // vetor com os dados de totalizacoes

SITUA->(dbSetFilter({|| Anomes == XANOMES},"Anomes == XANOMES"))
FUN->(dbSetFilter({|| Data_adm <= qfimmes(XDATASYS)},"Data_adm <= qfimmes(XDATASYS)"))

/* ESTRUTURA UTILIZADA NOS VETORES ACIMA:_____________________________________
   aFUN    == { eventos , bases }                                             |
   eventos == { cod.event. , finalidade , descricao , valor , fracao }        |
   bases   == { prov , desc , b.inss.ms , b.irrf.ms , b.fgts.ms ,             |
                              b.inss.fr , b.irrf.fr , b.fgts.fr ,             |
                              b.inss.dr , b.irrf.dt , b.fgts.dt ,             |
                              b.sfam    , v.sfam    , d.grps    ,             |
                              soma.inss , soma.irrf , soma.fgts , tot.fun }   |
   aTOT      == { (Cod.centro ou Cod.filial), sub.array }                     |
   sub.array == { eventos , bases }                                           |
   eventos   == { cod.event. , finalidade , descricao , valor , fracao }      |
   bases     == { prov , desc , b.inss.ms , b.irrf.ms , b.fgts.ms ,           |
                                b.inss.fr , b.irrf.fr , b.fgts.fr ,           |
                                b.sfam    , v.sfam    , d.grps    ,           |
                                soma.inss , soma.irrf , soma.fgts , tot.fun } |
*/
// ATUALIZA O VETOR DE BENEFICIOS ___________________________________________ |

   EVENT->(dbgotop())

   do while ! EVENT->(eof())
      qgirabarrara()
      iif(EVENT->Tipo=="6",aadd(aBENEF,EVENT->Evento),NIL)
      EVENT->(dbskip())
   enddo

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

   aadd(aEDICAO,{{ || qesco(-1,0,@cRESCSN  ,sBLOCO7)} , "RESCSN"   })
   aadd(aEDICAO,{{ || qesco(-1,0,@cPRESSN  ,sBLOCO7)} , "PRESSN"   })
   aadd(aEDICAO,{{ || qesco(-1,0,@cTIPOREL ,sBLOCO2)} , "TIPOREL"  })
   aadd(aEDICAO,{{ || qesco(-1,0,@cORDEM   ,sBLOCO3)} , "ORDEM"    })
   aadd(aEDICAO,{{ || qesco(-1,0,@cQUEBRA  ,sBLOCO4)} , "QUEBRA"   })
   aadd(aEDICAO,{{ || qesco(-1,0,@cANALSINT,sBLOCO5)} , "ANALSINT" })
   aadd(aEDICAO,{{ || qesco(-1,0,@cDADOSCAD,sBLOCO6)} , "DADOSCAD" })
   aadd(aEDICAO,{{ || qesco(-1,0,@cDADOSFIN,sBLOCO6)} , "DADOSFIN" })
   aadd(aEDICAO,{{ || view_filia(-1,0,@cFILIAL) }     , "FILIAL"   })
   aadd(aEDICAO,{{ || NIL },NIL}) // descricao do filial
   aadd(aEDICAO,{{ || view_ccusto(-1,0,@cCENTRO) }    , "CENTRO"   })
   aadd(aEDICAO,{{ || NIL },NIL}) // descricao do centro

do while .T.
   qlbloc(5,0,"B501A","QBLOC.GLO")
   qmensa()
   XNIVEL    := 1
   XFLAG     := .T.
   lSAIFORA  := .F.
   cCENTRO   := space(8)
   cFILIAL   := space(4)
   cTIPOREL  := " "
   cRESCSN   := " "
   cPRESSN   := " "

   // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; dbcloseall() ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   if ( i_inicializacao() , i_impressao() , NIL )

enddo

/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA _____________________________________________

static function i_critica ( cCAMPO )
   do case
      case cCAMPO == "PRESSN"
           if empty(cPRESSN) ; return .F. ; endif
           qrsay(XNIVEL,qabrev(cPRESSN,"SN",{"Sim","N„o"}))

      case cCAMPO == "RESCSN"
           if empty(cRESCSN) ; return .F. ; endif
           qrsay(XNIVEL,qabrev(cRESCSN,"SN",{"Sim","N„o"}))

      case cCAMPO == "TIPOREL"
           if empty(cTIPOREL) ; return .F. ; endif
           qrsay(XNIVEL,qabrev(cTIPOREL,"MADFC",{"Mˆs Corrente","Adiantamento","D‚cimo Terceiro","F‚rias","Cont bil"}))
      case cCAMPO == "ORDEM"
           if empty(cORDEM) ; return .F. ; endif
           qrsay(XNIVEL,qabrev(cORDEM,"MN",{"Matr¡cula","Nome"}))
      case cCAMPO == "QUEBRA"
           if empty(cQUEBRA) ; return .F. ; endif
           qrsay(XNIVEL,qabrev(cQUEBRA,"123",{"N„o usar","Filial","Centro"}))
      case cCAMPO == "ANALSINT"
           if empty(cANALSINT) ; return .F. ; endif
           qrsay(XNIVEL,qabrev(cANALSINT,"AS",{"Anal¡tico","Sint‚tico"}))
      case cCAMPO == "DADOSCAD"
           if empty(cDADOSCAD) ; return .F. ; endif
           qrsay(XNIVEL,qabrev(cDADOSCAD,"RC",{"Resumido","Completo"}))
      case cCAMPO == "DADOSFIN"
           if empty(cDADOSFIN) ; return .F. ; endif
           qrsay(XNIVEL,qabrev(cDADOSFIN,"RC",{"Resumido","Completo"}))
           if cQUEBRA == "1"
              XNIVEL+=3
           endif
           if cQUEBRA == "3"
              XNIVEL+=2
           endif
      case cCAMPO == "FILIAL"
           qrsay(XNIVEL+1,iif(FILIAL->(dbseek(cFILIAL)),left(FILIAL->Razao,40),"*** Todas as Filiais ***"))
           if cQUEBRA == "2"
              XNIVEL+=2
           endif
      case cCAMPO == "CENTRO"
           if ! empty(cCENTRO)
              if empty(right(cCENTRO,4))
                 qmensa("Centro de Custo n„o Anal¡tico !!","B")
                 return .F.
              endif
              if ! CCUSTO->(dbseek(cCENTRO))
                 qmensa("Centro de Custo n„o Cadastrado !!","B")
                 return .F.
              else
                 X_NomeCusto:=left(CCUSTO->Descricao,25)
              endif
           endif
           qrsay(XNIVEL+1,iif(CCUSTO->(dbseek(cCENTRO)),CCUSTO->Descricao,"*** Todos os Centros ***"))
   endcase
return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao
   qmensa("Inicializando Base de Dados...")
   aTOT := {{space(10),{}}}

   // VERIFICA TABELAS ______________________________________________________

   if ! TBIF->(dbseek(XANOMES))
      qmensa("Tabela de INSS do Funcion rio incompleta !","B") ; return .F.
   endif
   nINSS_TETO := TBIF->If_teto
   if ! TBGR->(dbseek(XANOMES))
      qmensa("Tabela Geral incompleta !","B") ; return .F.
   endif

   nPERC_FGTS := TBGR->Gr_fgts

   // CONSTROI VARIAVEL "cTITULO" __________________________________________

   cTIPOREL := qabrev(cTIPOREL,"MADFC",{"MS","AD","DT","FR","CT"})
   cTITULO = "RELATORIO DA FOLHA DE PAGAMENTO - "

   do case
      case cTIPOREL == "MS" ; cTITULO += " MENSAL"
      case cTIPOREL == "AD" ; cTITULO += " ADIANTAMENTO"
      case cTIPOREL == "DT" ; cTITULO += " 13. SALARIO"
      case cTIPOREL == "FR" ; cTITULO += " FERIAS"
      case cTIPOREL == "CT" ; cTITULO += " CONTABIL"
   endcase

   cTITULO += " - " + alltrim(qnomemes(XDATASYS)) + "/" + str(year(XDATASYS),4)

   // INICIALIZA MACROS DE PROV E DESC ______________________________________

   if cTIPOREL == "CT"
      bPROV := { || BASE->Prov_ms + BASE->Prov_fr + BASE->Prov_dt }
      bDESC := { || BASE->Desc_ms + BASE->Desc_fr + BASE->Desc_dt }
   else
      bPROV := &("{|| BASE->Prov_" + cTIPOREL + "}")
      bDESC := &("{|| BASE->Desc_" + cTIPOREL + "}")
   endif

   // SELECIONA ORDEM DO ARQUIVO FUN ________________________________________

   do case
      case cQUEBRA == "1" .and. cORDEM == "M" ; FUN->(dbsetorder(01)) // matricula
      case cQUEBRA == "1" .and. cORDEM == "N" ; FUN->(dbsetorder(02)) // nome
      case cQUEBRA == "2" .and. cORDEM == "M" ; FUN->(dbsetorder(03)) // filial + depto + matricula
      case cQUEBRA == "2" .and. cORDEM == "N" ; FUN->(dbsetorder(04)) // filial + depto + nome
      case cQUEBRA == "3" .and. cORDEM == "M" ; FUN->(dbsetorder(07)) // centro + matricula
      case cQUEBRA == "3" .and. cORDEM == "N" ; FUN->(dbsetorder(08)) // centro + nome
   endcase

   qmensa()

   // ESTABELECE RELACOES ENTRE ARQUIVOS ____________________________________

   LANC->(dbSetRelation("EVENT",{|| Evento},"Evento"))

   if cTIPOREL == "CT"
      LANC->(dbSetFilter({|| Ambiente $ "MS_FR_DT"},"Ambiente $ 'MS_FR_DT'"))
   endif

   FUN->(dbSetRelation("BASE",{|| Matricula+XANOMES},"Matricula+XANOMES"))
   FUN->(dbSetRelation("CCUSTO",{|| Centro},"Centro"))
   SITUA->(dbSetRelation("CCUSTO",{|| Ccusto},"Centro"))
   FUN->(dbSetRelation("FILIAL",{|| Filial},"Filial"))
   FUN->(dbSetRelation("DEPART",{|| Depto},"Depto"))
   SITUA->(dbSetRelation("AFAST",{|| Af_cod},"Af_cod"))
   SITUA->(dbSetRelation("CARGO",{|| Cargo},"Cargo"))
   SITUA->(dbSetRelation("CBO",{|| Cbo},"Cbo"))

   if cTIPOREL == "CT"
      FUN->(dbSetRelation("LANC",{|| XANOMES+Matricula},"XANOMES+Matricula"))
   else
      FUN->(dbSetRelation("LANC",{|| XANOMES+Matricula+cTIPOREL},"XANOMES+Matricula+cTIPOREL"))
   endif

   FUN->(dbgotop())

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impressao

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif

   @ prow(),pcol() say XRESET
   @ prow(),pcol() say XCOND1

   if cRESCSN == "S"

      lPRIM := .T.
      imp_rel()
      FUN->(Dbgotop())
      do case
         case cQUEBRA == "1" .and. cORDEM == "M" ; FUN->(dbsetorder(01)) // matricula
         case cQUEBRA == "1" .and. cORDEM == "N" ; FUN->(dbsetorder(02)) // nome
         case cQUEBRA == "2" .and. cORDEM == "M" ; FUN->(dbsetorder(03)) // filial + depto + matricula
         case cQUEBRA == "2" .and. cORDEM == "N" ; FUN->(dbsetorder(04)) // filial + depto + nome
         case cQUEBRA == "3" .and. cORDEM == "M" ; FUN->(dbsetorder(07)) // centro + matricula
         case cQUEBRA == "3" .and. cORDEM == "N" ; FUN->(dbsetorder(08)) // centro + nome
      endcase
      lAPOS_SUBTOTAL  := .F.
      lPRIM := .F.
      lAPOS_CABECALHO := .F.
      XPAGINA := 0
      aFUN := {{},{}}
      aTOT := {{space(10),{}}}
      aEVENTOS := {}
//    lSAIFORA  := .F.
//    i_cabecalho_principal()
      FUN->(dbSetFilter({|| Situacao == "D"},"Situacao == 'D'"))
      cTITULO := "RELATORIO DA FOLHA DE PAGAMENTO - MENSAL (RESCISAO) - " + alltrim(qnomemes(XDATASYS)) + "/" + str(year(XDATASYS),4)
      imp_rel()
      qstopprn()
      FUN->(dbSetFilter())
   else

     imp_rel()
     qstopprn()

   endif

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IMPRIMIR O RELATORIO ________________________________________

static function imp_rel

   do while ! FUN->(eof()) .and. qcontprn()
      qgirabarra()

      if FUN->Situacao == "H" .and. SITUA->Af_ini < qinimes(XDATASYS)
//       if i_imp_sub_total() // FOI INCLUIDO 05/06/97 PARA USIMIX
//          lAPOS_SUBTOTAL := .T.
//       endif
//       i_imp_sub_total() // FOI INCLUIDO 14/06/97
         FUN->(dbskip())
         loop
      endif

      if cRESCSN == "S"
         if lPRIM
            if FUN->Situacao $ "D "
//             if i_imp_sub_total() // FOI INCLUIDO 05/06/97 PARA USIMIX
//                lAPOS_SUBTOTAL := .T.
//             endif
//             i_imp_sub_total() // FOI INCLUIDO 14/06/97
               FUN->(Dbskip())
               loop
            endif
         else
            if ! FUN->Situacao $ "D "
               FUN->(Dbskip())
               loop
            endif
         endif
      endif

      SITUA->(dbseek(FUN->Matricula))

      if FUN->Data_adm > qfimmes(XDATASYS)
         FUN->(dbskip())
         loop
      endif

      if cPRESSN == "S"
         if SITUA->Vinculo $ "F-G-H-M-N"
            FUN->(Dbskip())
            loop
         endif
      endif

      if SITUA->Vinculo == "G"
         FUN->(Dbskip())
         loop
      endif
         
      if ! empty(cCENTRO)
//       if FUN->Centro != cCENTRO
         if SITUA->Ccusto != cCENTRO
            FUN->(dbskip())
            loop
         endif
      endif

      if ! empty(cFILIAL)
         if FUN->Filial != cFILIAL
            FUN->(dbskip())
            loop
         endif
      endif

      do case
         case cQUEBRA == "1" ; qmensa("Imprimindo Matr¡cula: "+FUN->Matricula)
         case cQUEBRA == "2" ; qmensa("Imprimindo Filial: "   +FUN->Filial+" / Matricula: "+FUN->Matricula)
//       case cQUEBRA == "3" ; qmensa("Imprimindo Centro: "   +transform(FUN->Centro,"@R 99.99.9999")+" / Matricula: "+FUN->Matricula)
         case cQUEBRA == "3" ; qmensa("Imprimindo Centro: "   +transform(SITUA->Ccusto,"@R 99.99.9999")+" / Matricula: "+FUN->Matricula)
      endcase

      if ! qlineprn() ; return ; endif

      if XPAGINA == 0 .or. prow() > K_MAX_LIN .or. lAPOS_SUBTOTAL
         lAPOS_SUBTOTAL := .F.
         if i_cabecalho_principal()
            lAPOS_CABECALHO := .T. // para imprimir sub-titulo
         else
            exit
         endif
      endif

      i_imp_funcionario()   // imprime dados de 1 funcionario
      i_imp_sub_total()     // imprime sub-total se necessario

      if lSAIFORA .and. qcontprn()
         return
      endif

      FUN->(dbskip())

   enddo

   // REUTILIZO A FUNCAO DE SUB-TOTAL PARA O TOTAL GERAL ____________________

// if empty(cCENTRO+cFILIAL)
//    i_agora_imprime_sub_total ( space(8) )
// endif
  i_agora_imprime_sub_total ( space(8) )  // ****
  // qstopprn()

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IMPRIMIR O CABECALHO PRINCIPAL _______________________________

static function i_cabecalho_principal

   qpageprn()

   @ prow()+1,001 say XRAZAO + iif(cQUEBRA=="3","Centro de Custo.: "+cCENTRO+" - "+X_NomeCusto,"" )
   @ prow()  ,121 say "Pagina: " + strzero(XPAGINA,3)
   @ prow()+1,000 say padc(cTITULO,132)
   @ prow()  ,112 say date()
   @ prow()  ,123 say time()
   @ prow()+1,000 say replicate("#",132)
   @ prow()+1,000 say " "

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IMPRIMIR DADOS DE 1 FUNCIONARIO ______________________________

static function i_imp_funcionario()
   local cSUB_TITULO

//   if FUN->Situacao == "H" .and. SITUA->Af_ini < qinimes(XDATASYS)  // se homologado em mes anterior, retorna
//      return
//   endif

   do case
//    case ! empty(cCENTRO) .and. cCENTRO != FUN->Centro ; return
      case ! empty(cCENTRO) .and. cCENTRO != SITUA->Ccusto ; return
      case ! empty(cFILIAL) .and. cFILIAL != FUN->Filial ; return
   endcase

   i_calcula_funcionario()

   if cQUEBRA $ "1-3"
//    i_totaliza_ultimo_funcionario ( FUN->Centro , "CENTRO" )
      SITUA->(dbseek(FUN->Matricula))  // ****
      i_totaliza_ultimo_funcionario ( SITUA->Ccusto , "CENTRO" )
   else
      if ! empty(FUN->Depto)
         i_totaliza_ultimo_funcionario ( FUN->Depto , "DEPTO" )
      endif
      i_totaliza_ultimo_funcionario ( FUN->Filial , "FILIAL" )
   endif

   if len(aFUN[1]) == 0 ; return ; endif  // nao ha lancamentos neste ambiente

   if lAPOS_CABECALHO .and. cANALSINT == "A" .and. cQUEBRA != "1"
      do case
         case cQUEBRA == "2" ; cSUB_TITULO := "FUNCIONARIOS DA FILIAL: " + FILIAL->Codigo  + " / " + FILIAL->Razao
         case cQUEBRA == "3" ; cSUB_TITULO := "FUNCIONARIOS DO CENTRO: " + transform(CCUSTO->Codigo,"@R 99.99.9999") + " / " + CCUSTO->Descricao
      endcase
      if cANALSINT == "A"
         @ prow()  ,0 say cSUB_TITULO
         @ prow()+1,0 say " "
      endif
      lAPOS_CABECALHO := .F. // para que este sub-titulo nao seja mais impresso
   endif

   if cANALSINT == "A"
      i_imp_cabecalho_do_funcionario()
      i_imp_dados_do_funcionario()
      i_imp_final_do_funcionario()
   endif

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA CALCULAR FUNCIONARIO _________________________________________

static function i_calcula_funcionario

   aFUN := {{},{}}   // REINICIALIZA VETOR DO FUNCIONARIO

   nDESCGRPS := 0

   do while LANC->Matricula == FUN->Matricula .and. LANC->Anomes == XANOMES .and. iif(cTIPOREL=="CT",.T.,LANC->Ambiente == cTIPOREL)

      if LANC->Valor <> 0 .and. ! LANC->Evento $ "591_592_593_594_595_596"     //.or. LANC->Evento == "980"
         aadd ( aFUN[1] , {LANC->Evento,EVENT->Finalidade,left(EVENT->Descricao,27),LANC->Valor,LANC->Fracao} )
         // lTEM_LANCAMENTO := .T.
      endif

      if LANC->Evento $ "901_902_161_480" // SAL.FAM DO MES + SAL.FAM. MESES ANT. + SAL. MATERN. + AUX. NATALIDADE
         nDESCGRPS += LANC->Valor
      endif

      LANC->(dbskip())

   enddo

   do case
      case cTIPOREL == "MS" //.and. lTEM_LANCAMENTO
           aFUN[2] := { eval(bPROV) ,;
                        eval(bDESC) ,;
                        BASE->T_inssms ,;
                        iif ( BASE->B_irrfms > 0 , BASE->B_irrfms , 0 ) ,;
                        BASE->B_fgtsms ,;
                        BASE->T_inssfr ,;
                        iif ( BASE->B_irrffr > 0 , BASE->B_irrffr , 0 ) ,;
                        BASE->B_fgtsfr ,;
                        BASE->T_inssdt ,;
                        iif ( BASE->B_irrfdt > 0 , BASE->B_irrfdt , 0 ) ,;
                        BASE->B_fgtsdt ,;
                        BASE->B_salfam ,;
                        BASE->V_salfam ,;
                        nDESCGRPS      ,;
                        BASE->V_inssms + BASE->V_inssfr + BASE->V_inssdt ,;
                        BASE->V_irrfms + BASE->V_irrffr + BASE->V_irrfdt ,;
                        BASE->V_fgtsms + BASE->V_fgtsfr + BASE->V_fgtsdt ,;
                        1 }

      case cTIPOREL == "DT" // .and. lTEM_LANCAMENTO
           aFUN[2] := { eval(bPROV) ,;
                        eval(bDESC) ,;
                        0           ,;
                        0           ,;
                        0           ,;
                        0           ,;
                        0           ,;
                        0           ,;
                        BASE->T_inss13 ,;
                        iif ( BASE->B_irrf13 > 0 , BASE->B_irrf13 , 0 ) ,;
                        BASE->B_fgts13 ,;
                        0              ,;
                        0              ,;
                        0              ,;
                        BASE->V_inss13 ,;
                        BASE->V_irrf13 ,;
                        BASE->V_fgts13 ,;
                        1 }

      case cTIPOREL == "FR" // .and. lTEM_LANCAMENTO
           aFUN[2] := { eval(bPROV) ,;
                        eval(bDESC) ,;
                        0           ,;
                        0           ,;
                        0           ,;
                        BASE->T_inssfr ,;
                        iif ( BASE->B_irrffr > 0 , BASE->B_irrffr , 0 ) ,;
                        BASE->B_fgtsfr ,;
                        0              ,;
                        0              ,;
                        0              ,;
                        0              ,;
                        0              ,;
                        0              ,;
                        BASE->V_inssfr ,;
                        BASE->V_irrffr ,;
                        BASE->V_fgtsfr ,;
                        1 }

      case cTIPOREL == "AD" // .and. lTEM_LANCAMENTO
           aFUN[2] := { eval(bPROV) ,;
                        eval(bDESC) ,;
                        0           ,;
                        0           ,;
                        0           ,;
                        0           ,;
                        0           ,;
                        0           ,;
                        0           ,;
                        0           ,;
                        0           ,;
                        0           ,;
                        0           ,;
                        0           ,;
                        0           ,;
                        0           ,;
                        0           ,;
                        1 }

      case cTIPOREL == "CT" // .and. lTEM_LANCAMENTO
           aFUN[2] := { eval(bPROV) ,;
                        eval(bDESC) ,;
                        BASE->T_inssms ,;
                        iif ( BASE->B_irrfms > 0 , BASE->B_irrfms , 0 ) ,;
                        BASE->B_fgtsms ,;
                        BASE->T_inssfr ,;
                        iif ( BASE->B_irrffr > 0 , BASE->B_irrffr , 0 ) ,;
                        BASE->B_fgtsfr ,;
                        BASE->T_inssdt ,;
                        iif ( BASE->B_irrfdt + BASE->B_irrf13 > 0 , BASE->B_irrfdt + BASE->B_irrf13 , 0 ) ,;
                        BASE->B_fgtsdt + BASE->B_fgts13 ,;
                        BASE->B_salfam ,;
                        BASE->V_salfam ,;
                        nDESCGRPS      ,;
                        BASE->V_inssms + BASE->V_inssfr + BASE->V_inssdt + BASE->V_inss13 ,;
                        BASE->V_irrfms + BASE->V_irrffr + BASE->V_irrfdt + BASE->V_irrf13 ,;
                        BASE->V_fgtsms + BASE->V_fgtsfr + BASE->V_fgtsdt + BASE->V_fgts13 ,;
                        1 }
   endcase

//   lTEM_LANCAMENTO := .F.

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA TOTALIZAR O ULTIMO FUNCIONARIO CALCULADO _____________________

static function i_totaliza_ultimo_funcionario ( cCURINGA , cTIPO )

   local nCONT, nPOINTER, aDADOS, cCENTRO_SUP , cFILIAL_SUP

   // PESQUISA SE JA EXISTE TOTALIZACOES NESTE CENTRO/FILIAL/DEPTO __________

   if ( nPOINTER := ascan ( aTOT , { |x| x[1] == cCURINGA }) ) == 0
      aadd(aTOT,{cCURINGA,{}})
      nPOINTER := len(aTOT)
   endif

   aDADOS := aTOT[nPOINTER,2]  // APENAS UMA REFERENCIA AO SUB-VETOR DE DADOS

   // CRIA ESTRUTURAS E INICIALIZA OU TOTALIZA ______________________________

   if empty(aDADOS)                           // SE VAZIO...
      aadd(aDADOS,0)                          // CRIA ESTRUTURA (eventos)
      aadd(aDADOS,0)                          // CRIA ESTRUTURA (bases)
      aDADOS[1] := aclone(aFUN[1])            // FAZ UM CLONE DOS EVENTOS
      aDADOS[2] := aclone(aFUN[2])            // FAZ UM CLONE DAS BASES
   else

      // TOTALIZA OS EVENTOS ________________________________________________

      for nCONT := 1 to len(aFUN[1])
          if ( nPOINTER := ascan ( aDADOS[1] , {|x| x[1] == aFUN[1,nCONT,1] } ) ) == 0
             aadd(aDADOS[1],aclone(aFUN[1,nCONT]))
          else
             aDADOS[1,nPOINTER,4] += aFUN[1,nCONT,4]
             if aDADOS[1,nPOINTER,1] != "701" .and. left(aDADOS[1,nPOINTER,1],1) != "9"
                aDADOS[1,nPOINTER,5] += aFUN[1,nCONT,5]
             endif
          endif
      next

      // TOTALIZA AS BASES __________________________________________________

      for nCONT := 1 to K_LEN_BASE
          aDADOS[2,nCONT] += aFUN[2,nCONT]
      next

   endif

   // ATUALIZA CENTROS OU LOCAIS SUPERIORES (RECURSIVAMENTE) __________________________

   if empty(cCURINGA)
      return
   endif

   if cQUEBRA == "3"
      cCENTRO_SUP := CCUSTO->(qbusca_sup(cCURINGA))
      i_totaliza_ultimo_funcionario ( cCENTRO_SUP )
//    cCENTRO_SUP := space(8)
//    i_totaliza_ultimo_funcionario ( cCENTRO_SUP )
   else
      if cTIPO != "DEPTO"
         cCENTRO_SUP := space(8)
         i_totaliza_ultimo_funcionario ( cCENTRO_SUP )
      endif
   endif

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IMPRIMIR CABECALHO DO FUNCIONARIO ____________________________

static function i_imp_cabecalho_do_funcionario

   if cDADOSCAD == "C"
      @ prow()+1,0        say "Matr: " + FUN->Matricula
      @ prow()  ,pcol()+2 say "Nome: " + left(FUN->Nome,30)
      @ prow()  ,pcol()+2 say "Cargo: " + CARGO->Codigo + "/" + CARGO->Descricao
      @ prow()  ,pcol()+2 say "CBO: " + CBO->Codigo
      @ prow()+1,0        say "Carteira de Identidade: " + FUN->Idt_num + space(10) + "CPF: " + transform(FUN->Cpf_num,"@R 999.999.999-99")
      @ prow(),pcol()     say space(10) + "Data Admissao..: " + dtoc(FUN->Data_adm)
      @ prow()+1,0        say "Situacao: " + qabrev(FUN->Situacao,"TFAD",{"Trabalhando","Ferias","Afast.","Demitido"})

      do case
         case FUN->Situacao == "F" ; @ prow(),pcol() say "-("+dtoc(SITUA->Af_ini)+" a "+dtoc(SITUA->Af_ret)+")"
         case FUN->Situacao $ "AD" ; @ prow(),pcol() say "-(" + AFAST->Codigo + "-" + AFAST->Descricao + ") c/ Av. Prev.: " + dtoc(SITUA->Inicio_av) + " a " + dtoc(SITUA->Final_av)
         case ! empty(SITUA->Inicio_av) ; @ prow(),pcol() say " c/ Av. Prev.: " + dtoc(SITUA->Inicio_av) + " a " + dtoc(SITUA->Final_av)
         case FUN->Situacao == "T" ; @ prow(),pcol() say space(36)
      endcase

      @ prow()  ,pcol()+1 say "Depend.p/ IR:" + str(SITUA->Dep_ir,2)
      @ prow()  ,pcol()+1 say "SF:" + str(SITUA->Dep_fam,2)
      @ prow()  ,pcol()+1 say "SS:" + str(SITUA->Dep_saude,2)
      @ prow()  ,pcol()+1 say "SV:" + str(SITUA->Dep_vida,2)
      @ prow()  ,pcol()+1 say "BE:" + str(SITUA->Dep_bolsa,2)

      @ prow()+1,0        say "Centro: " + transform(CCUSTO->Codigo,"@R 99.99.9999") + "-" + CCUSTO->Descricao + space(5) + "Departamento: " + FUN->Depto + "-" + DEPART->Descricao
      @ prow()+1,0        say "Salario Base: "
      @ prow()  ,pcol()   say transform(SITUA->Salario   ,"@E 9,999,999,999.99")
      @ prow()  ,pcol()+2 say "Categoria: " + qabrev(SITUA->Categoria,"123456789",{"Mensal","Quinzenal","Semanal","Diario","Horario","Tarefa","Comissao","Honorario","Estagiario"})
      @ prow()  ,pcol()+2 say "Beneficios: " + i_benef_cadastrados()
   else
      @ prow()+1,0    say FUN->Matricula + " - " + left(FUN->Nome,30)
      @ prow(),pcol() say " - Situacao: " + qabrev(FUN->Situacao,"TFAD",{"Trab.","Fer. ","Afas.","Demi."})
      @ prow(),pcol() say " - DP.IR: " + str(SITUA->Dep_ir,2) + " - DP.SF: " + str(SITUA->Dep_fam,2) + space(10)
      @ prow(),pcol() say "Salario Base: " + transform(SITUA->Salario,"@E 999,999.99")
      @ prow()+1,0    say "Cargo: " + CARGO->Codigo + " - " + CARGO->Descricao  + space(10) + "CPF: " + transform(FUN->Cpf_num,"@R 999.999.999-99")
      @ prow(),pcol() say space(15) + "Data Admissao: " + dtoc(FUN->Data_adm)
      @ prow()+1,0    say "Centro: " + transform(CCUSTO->Codigo,"@R 99.99.9999") + " - " +;
                          CCUSTO->Descricao + space(2) + "Departamento: " + FUN->Depto + "-" +;
                          DEPART->Descricao
   endif

   @ prow()+1,0 say space(1)

return

// RETORNA OS BENEFICIOS CADASTRADOS PARA ESTE FUNCIONARIO __________________

static function i_benef_cadastrados
   local nCONT, cSTRING := ""
   for nCONT := 1 to len(aBENEF)
       if BENEF->(dbseek(aBENEF[nCONT]+cTIPOREL+FUN->Matricula))
          cSTRING += aBENEF[nCONT]+"/"
       endif
   next
return cSTRING

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IMPRIMIR DADOS DO FUNCIONARIO ________________________________

static function i_imp_dados_do_funcionario
   local nCONT, nMETADE
   local aEVENTOS := array(len(aFUN[1]))
   local aORDEM   := {}

   // JUNTA TODOS OS ELEMENTOS PARA FORMAR UMA LINHA ________________________

   for nCONT := 1 to len(aFUN[1])
       aEVENTOS[nCONT] := aFUN[1,nCONT,1] + " "
       aEVENTOS[nCONT] += aFUN[1,nCONT,2] + " "
       aEVENTOS[nCONT] += aFUN[1,nCONT,3] + "        "
       aEVENTOS[nCONT] += transform(aFUN[1,nCONT,4],"@E 9,999,999.99") + "   "
       if aFUN[1,nCONT,5] == 0
          aEVENTOS[nCONT] += space(8)
       else
          aEVENTOS[nCONT] += "(" + transform(aFUN[1,nCONT,5],"@E 999.99") + ")"
       endif
   next

   // TESTE E COLOCA NA ORDEM DE PROVENTOS, DESCONTOS, INC.BASE E DEC.BASE __

   for nCONT := 1 to len(aEVENTOS)
       iif ( substr(aEVENTOS[nCONT],5,1)=="P" , aadd(aORDEM,aEVENTOS[nCONT]) , NIL )
   next
   for nCONT := 1 to len(aEVENTOS)
       iif ( substr(aEVENTOS[nCONT],5,1)=="D" , aadd(aORDEM,aEVENTOS[nCONT]) , NIL )
   next
   for nCONT := 1 to len(aEVENTOS)
       iif ( substr(aEVENTOS[nCONT],5,1)=="+" , aadd(aORDEM,aEVENTOS[nCONT]) , NIL )
   next
   for nCONT := 1 to len(aEVENTOS)
       iif ( substr(aEVENTOS[nCONT],5,1)=="-" , aadd(aORDEM,aEVENTOS[nCONT]) , NIL )
   next

   nMETADE := len(aORDEM) / 2

   if int(nMETADE) != nMETADE        // entao e' impar
      aadd(aORDEM,space(60))
   endif

   nMETADE := len(aORDEM) / 2

   for nCONT := 1 to nMETADE
       if prow() > K_MAX_LIN
          i_cabecalho_principal()
          i_imp_cabecalho_do_funcionario()
       endif
       @ prow()+1,0 say aORDEM[nCONT] + " | " + aORDEM[nCONT+nMETADE]
   next

   @ prow()+1,0 say space(1)
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IMPRIMIR FINAL DO FUNCIONARIO ________________________________

static function i_imp_final_do_funcionario
   local cPIC1 := "@E 999,999.99"

   if cDADOSFIN == "C"
      @ prow()+1,0 say   "Proventos: " + transform(eval(bPROV)   ,cPIC1) + ;
                       "  B.INSS.Ms: " + transform(BASE->T_inssms,cPIC1) + ;
                       "  B.IRRF.Ms: " + transform(BASE->B_irrfms,cPIC1) + ;
                       "  B.FGTS.Ms: " + transform(BASE->B_fgtsms,cPIC1) + ;
                       "  B.Sal.Fam: " + transform(BASE->B_salfam,cPIC1)

      @ prow()+1,0 say   "Descontos: " + transform(eval(bDESC)   ,cPIC1) + ;
                       "  B.INSS.Fr: " + transform(BASE->T_inssfr,cPIC1) + ;
                       "  B.IRRF.Fr: " + transform(BASE->B_irrffr,cPIC1) + ;
                       "  B.FGTS.Fr: " + transform(BASE->B_fgtsfr,cPIC1) + ;
                       "  V.Sal.Fam: " + transform(BASE->V_salfam,cPIC1)

      @ prow()+1,0 say   "Liquido..: " + transform(eval(bPROV)-eval(bDESC),cPIC1) + ;
                       "  B.INSS.Dt: " + transform(iif(cTIPOREL=="DT",BASE->T_inss13,BASE->T_inssdt),cPIC1) + ;
                       "  B.IRRF.Dt: " + transform(iif(cTIPOREL=="DT",BASE->B_irrf13,BASE->B_irrfdt),cPIC1) + ;
                       "  B.FGTS.Dt: " + transform(iif(cTIPOREL=="DT",BASE->B_fgts13,BASE->B_fgtsdt),cPIC1)
   else
      @ prow()+1,0      say "Proventos: " + transform(eval(bPROV),cPIC1)
      @ prow(),pcol()+4 say "Descontos: " + transform(eval(bDESC),cPIC1)
      @ prow(),pcol()+4 say "Liquido: "   + transform(eval(bPROV)-eval(bDESC),cPIC1)
   endif

   @ prow()+1,0 say replicate("-",132)
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IMPRIMIR O SUB-TOTAL (CENTRO/FILIAL/DEPTO) ___________________

static function i_imp_sub_total()
   local nRECFUN := FUN->(recno())     // salva registro do fun.dbf
   local cLAST1                        // centro ou filial atual
   local cLAST2                        // centro ou filial proximo registro
   local cLAST3                        // depto atual
   local cLAST4                        // depto proximo registro

   if cQUEBRA == "1" ; return .F. ; endif

   // ATUALIZA VARIAVEIS NA MUDANCA DE REGISTRO _____________________________

   if cRESCSN == "N"
      do case
         case cQUEBRA == "3"
   //           SITUA->(dbgotop())
   //           SITUA->(dbseek(FUN->Matricula))
   //           cLAST1 := FUN->Centro
              cLAST1 := SITUA->Ccusto
              FUN->(dbskip())
   //           cLAST2 := FUN->Centro
              cLAST2 := SITUA->Ccusto
   //         FUN->(dbskip(-1))
              FUN->(dbgoto(nRECFUN))
         case cQUEBRA == "2"
              cLAST1 := FUN->Filial
              cLAST3 := FUN->Depto
              FUN->(dbskip())
              cLAST2 := FUN->Filial
              cLAST4 := FUN->Depto
              FUN->(dbgoto(nRECFUN))
      endcase

      // FAZ SUB-TOTAL SE NECESSARIO ___________________________________________

      if cQUEBRA == "3" .and. cLAST1 <> cLAST2
         lAPOS_SUBTOTAL := CCUSTO->(i_subtot(cLAST1,cLAST2,"CENTRO"))
      else
         lAPOS_SUBTOTAL := DEPART->(i_subtot(cLAST3,cLAST4,"DEPTO"))
         lAPOS_SUBTOTAL := FILIAL->(i_subtot(cLAST1,cLAST2,"FILIAL"))
      endif
   endif
return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO RECURSIVA PARA IMPRIMIR OS SUB-TOTAIS DA ARVORE ___________________

static function i_subtot ( cLAST1 , cLAST2 , cTIPO )
   if cLAST1 <> cLAST2
      if i_agora_imprime_sub_total ( cLAST1 , cTIPO )
         if lSAIFORA
            return .F.
         endif
//         if cQUEBRA == "3" .and. empty(cCENTRO)
//            i_subtot(qbusca_sup(cLAST1),qbusca_sup(cLAST2))
//         endif
         return .T.
      endif
   endif
return .F.

/////////////////////////////////////////////////////////////////////////////
// AQUI IMPRIME REALMENTE O SUB-TOTAL _______________________________________

static function i_agora_imprime_sub_total ( cATUAL , cTIPO )

   local cTITULO, nCONT, nPOINTER, aEVENTOS, aBASES
   local cPIC1 := "@E 999,999.99"

   // SE VETOR DE SUB-TOTAL ESTIVER VAZIO, ENTAO NAO FAZ SUB-TOTAL __________

   if ( nPOINTER := ascan ( aTOT , { |x| x[1] == cATUAL }) ) == 0 ; return .F. ; endif

   if len(aTOT) == 1 ; return .F. ; endif

   aEVENTOS := aTOT[nPOINTER,2,1]  // REFERENCIA AO SUB-VETOR DE EVENTOS
   aBASES   := aTOT[nPOINTER,2,2]  // REFERENCIA AO SUB-VETOR DE BASES

   if empty(aEVENTOS) ; return .F. ; endif
   if cTIPO != "FILIAL"
      iif ( cANALSINT=="A" .or. prow() > 10 , i_cabecalho_principal() , NIL )
   endif
   if empty(cATUAL) .and. ! FUN->(eof())
      return .T.
   endif

   if empty(cATUAL)
      cTITULO := "TOTAL GERAL DA EMPRESA"
   else
      cTITULO := "SUB-TOTAL D"
      do case
         case cQUEBRA == "2"
              if cTIPO == "FILIAL"
                 FILIAL->(dbseek(cATUAL))
                 cTITULO += "A FILIAL: " + FILIAL->Codigo + " / " + FILIAL->Razao
              else
                 DEPART->(dbseek(cATUAL))
                 cTITULO += "O DEPARTAMENTO: " + DEPART->Codigo + " / " + DEPART->Descricao
              endif
//              lAPOS_SUBTOTAL := .T.

         case cQUEBRA == "3"
//              CCUSTO->(dbgotop())
              CCUSTO->(dbseek(cATUAL))
              cTITULO += "O CENTRO: " + transform(CCUSTO->Codigo,"@R 99.99.9999") + " / " + CCUSTO->Descricao
//              lAPOS_SUBTOTAL := .T.
      endcase
   endif

   @ prow()+1,0 say padc(cTITULO,132)
   @ prow()+1,0 say " "

   i_imp_ev_tot(aEVENTOS)

/*   bases     == { prov , desc , b.inss.ms , b.irrf.ms , b.fgts.ms ,
                                  b.inss.fr , b.irrf.fr , b.fgts.fr ,
                                  b.inss.dr , b.irrf.dt , b.fgts.dt , b.sfam , v.sfam , d.grps } */

   @ prow()+2,0 say   "Proventos: "    + transform(aBASES[01],cPIC1) + ;
                    "  Base.INSS.Ms: " + transform(aBASES[03],cPIC1) + ;
                    "  Base.IRRF.Ms: " + transform(aBASES[04],cPIC1) + ;
                    "  Base.FGTS.Ms: " + transform(aBASES[05],cPIC1) + ;
                    "  Base.Sal.Fam: " + transform(aBASES[12],cPIC1)

   @ prow()+2,0 say   "Descontos: "    + transform(aBASES[02],cPIC1) + ;
                    "  Base.INSS.Fr: " + transform(aBASES[06],cPIC1) + ;
                    "  Base.IRRF.Fr: " + transform(aBASES[07],cPIC1) + ;
                    "  Base.FGTS.Fr: " + transform(aBASES[08],cPIC1) + ;
                    "  Val.Sal.Fam.: " + transform(aBASES[13],cPIC1)

   @ prow()+2,0 say   "Liquido..: "    + transform(aBASES[01]-aBASES[02],cPIC1) + ;
                    "  Base.INSS.Dt: " + transform(aBASES[09],cPIC1) + ;
                    "  Base.IRRF.Dt: " + transform(aBASES[10],cPIC1) + ;
                    "  Base.FGTS.Dt: " + transform(aBASES[11],cPIC1)

   @ prow()+2,21 say "  Soma.B.INSS.: " + transform(aBASES[03]+aBASES[06]+aBASES[09],cPIC1) + ;
                     "  Soma.B.IRRF.: " + transform(aBASES[04]+aBASES[07]+aBASES[10],cPIC1) + ;
                     "  Soma.B.FGTS.: " + transform(aBASES[05]+aBASES[08]+aBASES[11],cPIC1)

   @ prow()+2,21 say "  Tot.Ret.INSS: " + transform(aBASES[15],cPIC1) + ;
                     "  Tot.Ret.IRRF: " + transform(aBASES[16],cPIC1) + ;
                     "  Tot.Ret.FGTS: " + transform(aBASES[17],cPIC1)

   if CONFIG->Aliq == "S"
        @ prow()+2,00 say "  Tot.FGTS.MS 0,5% : " + transform((aBASES[05])*0.005,cPIC1) + ;
                          "  Tot.FGTS.FR 0.5% : " + transform((aBASES[08])*0.005,cPIC1) + ;
                          "  Tot.FGTS.DT 0.5% : " + transform((aBASES[11])*0.005,cPIC1)
        @ prow()+1,00 say "  Tot.Ret.FGTS 0,5%: " + transform((aBASES[05]+aBASES[08]+aBASES[11])*0.005,cPIC1)
   endif

   if cQUEBRA != "1"  .and. ! empty(cATUAL)
      do case
         case cQUEBRA == "2" .and. cTIPO == "FILIAL"
              @ prow()+2,43 say "Total de funcion rios da Filial: " + strzero(aBASES[18],3)
//              i_cabecalho_principal() // foi colocado no dia 31/08/97
              lAPOS_CABECALHO := .T.  // para que este sub-titulo impresso
         case cQUEBRA == "2" .and. cTIPO == "DEPTO"
              @ prow()+2,43 say "Total de funcion rios do Departamento: " + strzero(aBASES[18],3)
              i_cabecalho_principal()

         case cQUEBRA == "3"
              @ prow()+2,43 say "Total de funcion rios do Centro: " + strzero(aBASES[18],3)
              Return .T.
//              i_cabecalho_principal()
      endcase
   endif

   if empty(cATUAL)
      @ prow()+2,43 say "Total geral de funcionarios....: " + strzero(aBASES[18],4)
   endif

   if ! empty(cCENTRO)
      lSAIFORA := .T.
   endif
return .F.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IMPRIMIR OS DADOS NO SUB-TOTAL E NO TOTAL ____________________

static function i_imp_ev_tot ( aEVENTOS )
   local aLINHA := array(len(aEVENTOS))
   local aORDEM := {}
   local cINCID := "IN-IR-FG"
   local nMETADE

   for nCONT := 1 to len(aEVENTOS)
       aLINHA[nCONT] := aEVENTOS[nCONT,1] + " "
       aLINHA[nCONT] += aEVENTOS[nCONT,2] + " "
       aLINHA[nCONT] += left(aEVENTOS[nCONT,3],25) + " "
       aLINHA[nCONT] += transform(aEVENTOS[nCONT,4],"@E 9,999,999.99") + " "
       aLINHA[nCONT] += "(" + transform(aEVENTOS[nCONT,5],"@E 999,999.99") + ") "

       EVENT->(dbseek(aEVENTOS[nCONT,1]))

       cINCID := "IN-IR-FG"

       EVENT->(iif(Inssms=="S".or.Inssfr=="S",,cINCID:=strtran(cINCID,"IN","  ")))
       EVENT->(iif(Irrfms=="S".or.Irrffr=="S",,cINCID:=strtran(cINCID,"IR","  ")))
       EVENT->(iif(Fgtsms=="S".or.Fgtsfr=="S",,cINCID:=strtran(cINCID,"FG","  ")))

       aLINHA[nCONT] += cINCID
   next

   // TESTE E COLOCA NA ORDEM DE PROVENTOS, DESCONTOS, INC.BASE E DEC.BASE __

   for nCONT := 1 to len(aLINHA)
       iif ( substr(aLINHA[nCONT],5,1)=="P" , aadd(aORDEM,aLINHA[nCONT]) , NIL )
   next
   for nCONT := 1 to len(aLINHA)
       iif ( substr(aLINHA[nCONT],5,1)=="D" , aadd(aORDEM,aLINHA[nCONT]) , NIL )
   next
   for nCONT := 1 to len(aLINHA)
       iif ( substr(aLINHA[nCONT],5,1)=="+" , aadd(aORDEM,aLINHA[nCONT]) , NIL )
   next
   for nCONT := 1 to len(aLINHA)
       iif ( substr(aLINHA[nCONT],5,1)=="-" , aadd(aORDEM,aLINHA[nCONT]) , NIL )
   next

   nMETADE := len(aEVENTOS) / 2

   if int(nMETADE) != nMETADE        // entao e' impar
      aadd(aORDEM,space(60))
   endif

   nMETADE := len(aORDEM) / 2

   for nCONT := 1 to nMETADE
       @ prow()+1,0 say aORDEM[nCONT] + " | " + aORDEM[nCONT+nMETADE]
   next

   @ prow()+1,0 say " "
return
