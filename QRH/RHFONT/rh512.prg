/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: FOLHA DE PAGAMENTO
// OBJETIVO...: CONFERENCIA DE INSS
// ANALISTA...: CARLOS EDUARDO RABELLO NUNES
// PROGRAMADOR: O MESMO
// INICIO.....: SETEMBRO DE 1994
// OBS........:
// ALTERACOES.:

#define K_MAX_LIN 60

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG) .or. empty(cORDEM)}

private sBLOCO1 := qlbloc("B512B","QBLOC.GLO") // ordem de impressao

private nTOTAL                 // total
private cTITULO                // titulo
private cORDEM                 // ordem de impressao (matricula/nome)
private cCENTRO                // centro de custo para filtro
private cFILIAL                // filial para filtro
private aEDICAO := {}          // vetor para os campos de entrada de dados

SITUA->(dbSetFilter({|| Anomes == XANOMES},"Anomes == XANOMES"))

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qesco(-1,0,@cORDEM,sBLOCO1) }     , "ORDEM"     })
aadd(aEDICAO,{{ || view_ccusto(-1,0,@cCENTRO)}       , "CENTRO"    })
aadd(aEDICAO,{{ || NIL },NIL}) // descricao do centro
aadd(aEDICAO,{{ || view_filia(-1,0,@cFILIAL)}        , "FILIAL"    })
aadd(aEDICAO,{{ || NIL },NIL}) // descricao do filial

do while .T.

   qlbloc(5,0,"B511A","QBLOC.GLO")
   XNIVEL  := 1
   XFLAG   := .T.
   cORDEM  := " "
   cCENTRO := space(8)
   cFILIAL := space(4)

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
      case cCAMPO == "ORDEM"
           qrsay(XNIVEL,qabrev(cORDEM,"MN",{"Matricula","Nome"}))
      case cCAMPO == "CENTRO"
           if ! empty(cCENTRO)
              if empty(right(cCENTRO,4))
                 qmensa("Centro de Custo n�o Anal�tico !!","B")
                 return .F.
              endif
              if ! CCUSTO->(dbseek(cCENTRO))
                 qmensa("Centro de Custo n�o Cadastrado !!","B")
                 return .F.
              endif
           endif
           qrsay(XNIVEL+1,iif(CCUSTO->(dbseek(cCENTRO)),CCUSTO->Descricao,"*** Todos os Centros ***"))
      case cCAMPO == "FILIAL"
           qrsay(XNIVEL+1,iif(FILIAL->(dbseek(cFILIAL)),left(FILIAL->Razao,40),"*** Todas as Filiais ***"))
   endcase
return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // CONSTROI VARIAVEL "cTITULO" __________________________________________

   cTITULO = "RELACAO P/ CONFERENCIA DE IRRF - "
   cTITULO += upper(qnomemes(month(XDATASYS))) + "/" + str(year(XDATASYS),4)

   // SELECIONA ORDEM DO ARQUIVO CADFUN _____________________________________

   do case
      case cORDEM == "M" ; FUN->(dbsetorder(01)) // matricula
      case cORDEM == "N" ; FUN->(dbsetorder(02)) // nome
   endcase

   qmensa()

   // ESTABELECE RELACOES ENTRE ARQUIVOS ____________________________________

   FUN->(dbSetRelation( "BASE"  , {|| Matricula+XANOMES}, "Matricula+XANOMES" ))
   FUN->(dbSetRelation( "CCUSTO", {|| Centro}, "Centro" ))
   FUN->(dbSetRelation( "FILIAL", {|| Filial}, "Filial" ))

   FUN->(dbgotop())

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impressao

   local nVALMS := nVALFE := nVALDT :=nTOTMS := nTOTFE := nTOTDT := 0
   local nTT_BASEMS := nTT_BASEFE := nTT_BASEDT := 0
   local cPIC   := "@E 999,999.99"

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif

   qmensa("Imprimindo...")

   do while ! FUN->(eof()) .and. qcontprn()     // condicao principal de loop

      if ! qlineprn() ; return ; endif

      if XPAGINA == 0 .or. prow() > K_MAX_LIN
         qpageprn()
         qcabecprn(cTITULO,80)

         @ prow()+1,0 say XCOND1 + "MAT.    NOME                             B. MENSAL     ALIQUOTA     IRRF MENSAL    B. FERIAS     ALIQUOTA     IRRF FERIAS        TOTAL." + XCOND0
         @ prow()+1,0 say replicate("-",80)
      endif

      if i_filtro()

         qmensa("Funcionario: "+FUN->Matricula+" / "+left(FUN->Nome,40))
         if BASE->V_irrfms + BASE->V_irrffr == 0
            FUN->(dbskip())
            loop
         endif

         nVALMS := nVALFE := nVALDT := 0
         nBASMS := nBASFE := nBASDT := 0

         @ prow()+1,0        say XCOND1 + FUN->Matricula
         @ prow()  ,pcol()+2 say left(FUN->Nome,30)

         SITUA->(dbseek(FUN->Matricula))
         if SITUA->Vinculo == "G"
            FUN->(dbskip())
            loop
         endif

         @ prow()  ,pcol()+2 say nBASMS := i_base_irrf("MS")  picture cPIC
         @ prow()  ,pcol()+3 say  i_aliq_irrf("MS")  picture cPIC
         @ prow()  ,pcol()+4 say nVALMS := i_busca_irrf("MS") picture cPIC

         @ prow()  ,pcol()+3 say nBASFE := i_base_irrf("FR")  picture cPIC
         @ prow()  ,pcol()+5 say i_aliq_irrf("FR")  picture cPIC
         @ prow()  ,pcol()+4 say nVALFE := i_busca_irrf("FR") picture cPIC

         nTOTMS += nVALMS
         nTOTFE += nVALFE

         nTT_BASEMS += nBASMS
         nTT_BASEFE += nBASFE

         @ prow()  ,pcol()+4 say nVALMS+nVALFE picture cPIC + XCOND0

      endif

      FUN->(dbskip())

   enddo

   @ prow()+2,0      say XCOND1 + "Totais" + replicate(".",21) + ": " + space(10)
   @ prow(),pcol()+1  say nTT_BASEMS           picture cPIC
   @ prow(),pcol()+17  say nTOTMS               picture cPIC
   @ prow(),pcol()+3  say nTT_BASEFE           picture cPIC
   @ prow(),pcol()+19  say nTOTFE               picture cPIC
   @ prow(),pcol()+4  say nTOTMS+nTOTFE picture cPIC + XCOND0

   qstopprn()

   qmensa()

return

/////////////////////////////////////////////////////////////////////////////
// FILTRO DE IMPRESSAO ______________________________________________________

static function i_filtro
   if FUN->Situacao == "H"
      return .F.
   endif
   if ! SITUA->(dbseek(FUN->Matricula))
      return .F.
   endif
   if SITUA->Situacao == "H" .or. FUN->Data_adm > qfimmes(XDATASYS)
      return .F.
   endif
   if ! empty(cCENTRO) .and. cCENTRO <> SITUA->Ccusto ; return .F. ; endif
   if ! empty(cFILIAL) .and. cFILIAL <> FUN->Filial ; return .F. ; endif
return .T.

/////////////////////////////////////////////////////////////////////////////
// BUSCA E TOTALIZA VALORES DE INSS _________________________________________

static function i_busca_irrf ( cTIPO )
   local nVAL := 0
   do case
      case cTIPO == "MS" ; nVAL := BASE->V_irrfms + BASE->V_irrfdt
      case cTIPO == "FR" ; nVAL := BASE->V_irrffr
      case cTIPO == "DT" ; nVAL := BASE->V_irrf13
   endcase
return nVAL

////////////////////////////////////////////////////////////////////////////
// BUSCA BASE DE CALCULO DE INSS ___________________________________________
static function i_base_irrf ( cTIPO )
   local nVAL := 0
   do case
      case cTIPO == "MS" ; nVAL := BASE->B_irrfms + BASE->B_irrfdt
      case cTIPO == "FR" ; nVAL := BASE->B_irrffr
      case cTIPO == "DT" ; nVAL := BASE->B_irrf13
   endcase
return nVAL

static function i_aliq_irrf ( cTIPO )
   local nVAL := 0
   do case
      case cTIPO == "MS" ; nVAL := BASE->P_irrfms + BASE->P_irrfdt
      case cTIPO == "FR" ; nVAL := BASE->P_irrffr
      case cTIPO == "DT" ; nVAL := BASE->P_irrf13
   endcase
return nVAL

