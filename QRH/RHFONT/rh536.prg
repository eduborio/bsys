/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: FOLHA DE PAGAMENTO
// OBJETIVO...: EMISSAO DE RELACAO SINTETICA
// ANALISTA...: EDUARDO AUGUSTO BORIO
// PROGRAMADOR: O MESMO
// INICIO.....: FEVEREIRO DE 2002
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

   qlbloc(5,0,"B512A","QBLOC.GLO")
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
                 qmensa("Centro de Custo n„o Anal¡tico !!","B")
                 return .F.
              endif
              if ! CCUSTO->(dbseek(cCENTRO))
                 qmensa("Centro de Custo n„o Cadastrado !!","B")
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

   cTITULO = "RELACAO SINTETICA  - "
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

   local nVENC := nINSS := nIRRF := nSALFAM := nOUTROS := nLIQ := nADIC := nHORAS := nOTHERS := nSALBASE := 0
   local nTVENC := nTINSS := nTIRRF := nTSALFAM := nTOUTROS := nTLIQ := nTSALBASE := nTADIC := nTHORAS := nTOTHERS := nTINTEG :=  0
   local cPIC   := "@E 999,999.99"

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif

   qmensa("Imprimindo...")

   do while ! FUN->(eof()) .and. qcontprn()     // condicao principal de loop

      if ! qlineprn() ; return ; endif

      if XPAGINA == 0 .or. prow() > K_MAX_LIN
         qpageprn()
         qcabecprn(cTITULO,80)

         @ prow()+1,0 say XCOND2 + "MAT.    NOME                             SAL. BASE   ADIC NOT.  INTEGRACOES  H. EXTRAS   SAL. FAM.  OUTROS PROV.  I.N.S.S.    I.R.R.F.   OUTROS DESC.  LIQUIDO" + XCOND0
         @ prow()+1,0 say replicate("-",80)
      endif

      if i_filtro()

         qmensa("Funcionario: "+FUN->Matricula+" / "+left(FUN->Nome,40))
//         nVENC := nINSS := nIRRF := nSALFAM := nOUTROS := nLIQ := 0
//         nTVENC := nTINSS := nTIRRF := nTSALFAM := nTOUTROS := nTLIQ := 0

         @ prow()+1,0        say XCOND2 + FUN->Matricula
         @ prow()  ,pcol()+2 say left(FUN->Nome,30)

         SITUA->(dbseek(FUN->Matricula))

         @ prow()  ,pcol()+2 say nSALBASE   := i_sal_base()  picture cPIC
         @ prow()  ,pcol()+2 say nADIC      := i_adic_not()  picture cPIC
         @ prow()  ,pcol()+2 say nINTEG     := i_integracoes()  picture cPIC
         @ prow()  ,pcol()+2 say nHORAS     := i_horas()  picture cPIC
         @ prow()  ,pcol()+2 say nSALFAM    := i_salfam("MS") picture cPIC
         @ prow()  ,pcol()+2 say nOTHERS    := i_prov() picture cPIC

         @ prow()  ,pcol()+2 say nINSS   := i_inss("MS")  picture cPIC
         @ prow()  ,pcol()+2 say nIRRF   := i_irrf("MS")  picture cPIC
         @ prow()  ,pcol()+2 say nOUTROS := i_outros("MS")  picture cPIC
         @ prow()  ,pcol()+3 say nLIQ    := i_liq("MS") picture cPIC

         nTSALBASE += nSALBASE
         nTOTHERS  += nOTHERS
         nTADIC    += nADIC
         nTINTEG   += nINTEG
         nTHORAS   += nHORAS
         nTSALFAM  += nSALFAM
         nTINSS    += nINSS
         nTIRRF    += nIRRF
         nTOUTROS  += nOUTROS
         nTLIQ     += nLIQ

      endif

      FUN->(dbskip())

   enddo

   @ prow()+2,0      say XCOND2 + "Totais" + replicate(".",21) + ": " + space(10)
   @ prow(),pcol()+1  say nTSALBASE           picture cPIC
   @ prow(),pcol()+2  say nTADIC              picture cPIC
   @ prow(),pcol()+2  say nTINTEG             picture cPIC
   @ prow(),pcol()+2  say nTHORAS             picture cPIC
   @ prow(),pcol()+2  say nTSALFAM            picture cPIC
   @ prow(),pcol()+2  say nTOTHERS            picture cPIC
   @ prow(),pcol()+2  say nTINSS              picture cPIC
   @ prow(),pcol()+2  say nTIRRF              picture cPIC
   @ prow(),pcol()+2  say nTOUTROS            picture cPIC
   @ prow(),pcol()+3  say nTLIQ               picture cPIC

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
   if SITUA->Vinculo == "G"
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

static function i_venc ( cTIPO )
   local nVAL := 0
   do case
      case cTIPO == "MS" ; nVAL := BASE->Prov_ms + BASE->Prov_fr - (i_salfam("MS"))
   endcase
return nVAL

////////////////////////////////////////////////////////////////////////////
// BUSCA BASE DE CALCULO DE INSS ___________________________________________
static function i_salfam ( cTIPO )
   local nVAL := 0
   do case
      case cTIPO == "MS" ; nVAL := BASE->V_salfam
   endcase
return nVAL

static function i_irrf ( cTIPO )
   local nVAL := 0
   do case
      case cTIPO == "MS" ; nVAL := BASE->V_irrfms + BASE->V_irrffr + BASE->V_irrfdt
   endcase
return nVAL

static function i_inss ( cTIPO )
   local nVAL := 0
   do case
      case cTIPO == "MS" ; nVAL := BASE->V_inssms + BASE->V_inssfr + BASE->V_inssdt
   endcase
return nVAL

static function i_outros ( cTIPO )
   local nVAL := 0
   do case
      case cTIPO == "MS" ; nVAL := BASE->Desc_ms + BASE->Prov_fr
           nVAL := nVAL - (i_inss("MS")+i_irrf("MS"))
           if SITUA->Situacao == "D"
              nVAL := 0
              nVAL := (nVAL + BASE->Prov_ms) - (i_inss("MS") + i_irrf("FR"))
           endif
   endcase
return nVAL

static function i_liq ( cTIPO )
   local nVAL := 0
   do case
      case cTIPO == "MS" ; nVAL := (i_venc("MS")+i_salfam("MS")) - (i_inss("MS")+i_irrf("MS")+i_outros("MS"))
   endcase
return nVAL


static function i_sal_base
local nVALOR := 0

      //SALARIOS E SALDOS DE SALARIO
      LANC->(dbseek(XANOMES+FUN->Matricula+"MS"+"100"))
      nVALOR += LANC->Valor
      LANC->(dbseek(XANOMES+FUN->Matricula+"MS"+"101"))
      nVALOR += LANC->Valor
      LANC->(dbseek(XANOMES+FUN->Matricula+"MS"+"102"))
      nVALOR += LANC->Valor
      LANC->(dbseek(XANOMES+FUN->Matricula+"MS"+"103"))
      nVALOR += LANC->Valor
      //DIARIAS
      LANC->(dbseek(XANOMES+FUN->Matricula+"MS"+"362"))
      nVALOR += LANC->Valor
      LANC->(dbseek(XANOMES+FUN->Matricula+"MS"+"339"))
      nVALOR += LANC->Valor
      LANC->(dbseek(XANOMES+FUN->Matricula+"MS"+"355"))
      nVALOR += LANC->Valor
      LANC->(dbseek(XANOMES+FUN->Matricula+"MS"+"363"))
      nVALOR += LANC->Valor
      LANC->(dbseek(XANOMES+FUN->Matricula+"MS"+"438"))
      nVALOR += LANC->Valor
      LANC->(dbseek(XANOMES+FUN->Matricula+"MS"+"353"))
      nVALOR += LANC->Valor
      LANC->(dbseek(XANOMES+FUN->Matricula+"MS"+"352"))
      nVALOR += LANC->Valor

return nVALOR

static function i_adic_not
local nVALOR := 0

      LANC->(dbseek(XANOMES+FUN->Matricula+"MS"+"361"))
      nVALOR += LANC->Valor
      LANC->(dbseek(XANOMES+FUN->Matricula+"MS"+"359"))
      nVALOR += LANC->Valor
      LANC->(dbseek(XANOMES+FUN->Matricula+"MS"+"358"))
      nVALOR += LANC->Valor
      LANC->(dbseek(XANOMES+FUN->Matricula+"MS"+"341"))
      nVALOR += LANC->Valor
      LANC->(dbseek(XANOMES+FUN->Matricula+"MS"+"659"))
      nVALOR += LANC->Valor
      LANC->(dbseek(XANOMES+FUN->Matricula+"MS"+"340"))
      nVALOR += LANC->Valor
      LANC->(dbseek(XANOMES+FUN->Matricula+"MS"+"366"))
      nVALOR += LANC->Valor
      LANC->(dbseek(XANOMES+FUN->Matricula+"MS"+"412"))
      nVALOR += LANC->Valor

return nVALOR

static function i_integracao
local nVALOR := 0

      LANC->(dbseek(XANOMES+FUN->Matricula+"MS"+"368"))
      nVALOR += LANC->Valor
      LANC->(dbseek(XANOMES+FUN->Matricula+"MS"+"369"))
      nVALOR += LANC->Valor
      LANC->(dbseek(XANOMES+FUN->Matricula+"MS"+"378"))
      nVALOR += LANC->Valor
      LANC->(dbseek(XANOMES+FUN->Matricula+"MS"+"379"))
      nVALOR += LANC->Valor
      LANC->(dbseek(XANOMES+FUN->Matricula+"MS"+"174"))
      nVALOR += LANC->Valor
      LANC->(dbseek(XANOMES+FUN->Matricula+"MS"+"370"))
      nVALOR += LANC->Valor

return nVALOR

static function i_horas
local nVALOR := 0

      LANC->(dbseek(XANOMES+FUN->Matricula+"MS"+"311"))
      nVALOR += LANC->Valor
      LANC->(dbseek(XANOMES+FUN->Matricula+"MS"+"308"))
      nVALOR += LANC->Valor
      LANC->(dbseek(XANOMES+FUN->Matricula+"MS"+"314"))
      nVALOR += LANC->Valor
      LANC->(dbseek(XANOMES+FUN->Matricula+"MS"+"315"))
      nVALOR += LANC->Valor
      LANC->(dbseek(XANOMES+FUN->Matricula+"MS"+"319"))
      nVALOR += LANC->Valor
      LANC->(dbseek(XANOMES+FUN->Matricula+"MS"+"312"))
      nVALOR += LANC->Valor
      LANC->(dbseek(XANOMES+FUN->Matricula+"MS"+"318"))
      nVALOR += LANC->Valor
      LANC->(dbseek(XANOMES+FUN->Matricula+"MS"+"316"))
      nVALOR += LANC->Valor
      LANC->(dbseek(XANOMES+FUN->Matricula+"MS"+"322"))
      nVALOR += LANC->Valor
      LANC->(dbseek(XANOMES+FUN->Matricula+"MS"+"333"))
      nVALOR += LANC->Valor
      LANC->(dbseek(XANOMES+FUN->Matricula+"MS"+"320"))
      nVALOR += LANC->Valor
      LANC->(dbseek(XANOMES+FUN->Matricula+"MS"+"329"))
      nVALOR += LANC->Valor
      LANC->(dbseek(XANOMES+FUN->Matricula+"MS"+"330"))
      nVALOR += LANC->Valor
      LANC->(dbseek(XANOMES+FUN->Matricula+"MS"+"317"))
      nVALOR += LANC->Valor
      LANC->(dbseek(XANOMES+FUN->Matricula+"MS"+"328"))
      nVALOR += LANC->Valor
      LANC->(dbseek(XANOMES+FUN->Matricula+"MS"+"321"))
      nVALOR += LANC->Valor
      LANC->(dbseek(XANOMES+FUN->Matricula+"MS"+"310"))
      nVALOR += LANC->Valor
      LANC->(dbseek(XANOMES+FUN->Matricula+"MS"+"304"))
      nVALOR += LANC->Valor
      LANC->(dbseek(XANOMES+FUN->Matricula+"MS"+"305"))
      nVALOR += LANC->Valor

return nVALOR

static function i_prov
local nVALOR := 0
      nVALOR := (BASE->Prov_ms + BASE->Prov_Fr) - i_salfam("MS")
      nVALOR -= (i_sal_base()+i_Adic_not()+i_horas()+i_integracao())

return nVALOR



