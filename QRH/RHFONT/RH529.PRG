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

   local nVENC := nINSS := nIRRF := nSALFAM := nOUTROS := nLIQ := 0
   local nTVENC := nTINSS := nTIRRF := nTSALFAM := nTOUTROS := nTLIQ := 0
   local cPIC   := "@E 999,999.99"

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif

   qmensa("Imprimindo...")

   do while ! FUN->(eof()) .and. qcontprn()     // condicao principal de loop

      if ! qlineprn() ; return ; endif

      if XPAGINA == 0 .or. prow() > K_MAX_LIN
         qpageprn()
         qcabecprn(cTITULO,80)

         @ prow()+1,0 say XCOND1 + "MAT.    NOME                             VENCIMENTOS     SAL. FAM.     DESC. INSS     DESC. IRRF   OUTROS DESC.    VALOR LIQUIDO" + XCOND0
         @ prow()+1,0 say replicate("-",80)
      endif

      if i_filtro()

         qmensa("Funcionario: "+FUN->Matricula+" / "+left(FUN->Nome,40))
//         nVENC := nINSS := nIRRF := nSALFAM := nOUTROS := nLIQ := 0
//         nTVENC := nTINSS := nTIRRF := nTSALFAM := nTOUTROS := nTLIQ := 0

         @ prow()+1,0        say XCOND1 + FUN->Matricula
         @ prow()  ,pcol()+2 say left(FUN->Nome,30)

         SITUA->(dbseek(FUN->Matricula))

         @ prow()  ,pcol()+2 say nVENC   := i_venc("MS")  picture cPIC
         @ prow()  ,pcol()+4 say nSALFAM := i_salfam("MS")  picture cPIC
         @ prow()  ,pcol()+5 say nINSS   := i_inss("MS") picture cPIC

         @ prow()  ,pcol()+4 say nIRRF   := i_irrf("MS")  picture cPIC
         @ prow()  ,pcol()+5 say nOUTROS := i_outros("MS")  picture cPIC
         @ prow()  ,pcol()+7 say nLIQ    := i_liq("MS") picture cPIC


         nTVENC   += nVENC
         nTSALFAM += nSALFAM
         nTINSS   += nINSS
         nTIRRF   += nIRRF
         nTOUTROS += nOUTROS
         nTLIQ    += nLIQ

      endif

      FUN->(dbskip())

   enddo

   @ prow()+2,0      say XCOND1 + "Totais" + replicate(".",21) + ": " + space(10)
   @ prow(),pcol()+1  say nTVENC           picture cPIC
   @ prow(),pcol()+4  say nTSALFAM               picture cPIC
   @ prow(),pcol()+5  say nTINSS           picture cPIC
   @ prow(),pcol()+4  say nTIRRF               picture cPIC
   @ prow(),pcol()+5  say nTOUTROS               picture cPIC
   @ prow(),pcol()+7  say nTLIQ                 picture cPIC

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

