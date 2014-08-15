/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: FOLHA DE PAGAMENTO
// OBJETIVO...: RELATORIO PROVISAO DE FERIAS
// ANALISTA...:
// PROGRAMADOR: IN SUNG CHANG
// INICIO.....: JENEIRO DE 1997
// OBS........:
// ALTERACOES.:

#include "rh.ch"

#define K_MAX_LIN 55

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local bESCAPE  := {||(XNIVEL==1 .and. !XFLAG).or.lastkey()==27}

private cTITULO                               // titulo do relatorio

private cCUSTO
private cTIPO
private cORDEM

private nVALFR  := 0    // valor de ferias
private nVALIN  := 0    // valor de INSS
private nVALFG  := 0    // valor de FGTS

private nREFFR  := 0    // valor de ferias
private nREFIN  := 0    // valor de INSS
private nREFFG  := 0    // valor de FGTS

private nTOT_C_FR  := 0    // total do centro de ferias
private nTOT_C_IN  := 0    // total do centro de INSS
private nTOT_C_FG  := 0    // total do centro de FGTS

private nTOT_G_FR  := 0    // total geral de ferias
private nTOT_G_IN  := 0    // total geral de INSS
private nTOT_G_FG  := 0    // total geral de FGTS

private aEDICAO := {}                         // vetor para os campos de entrada de dados
private sBLOCO2 := qlbloc("B503B","QBLOC.GLO") // tipo de relatorio
private sBLOCO3 := qlbloc("B503C","QBLOC.GLO") // ordem

private lIMP_CUSTO := .T.

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || view_ccusto(-1,0,@cCUSTO                    )} ,"CUSTO"})
aadd(aEDICAO,{{ || NIL },NIL }) // descricao do centro de custo
aadd(aEDICAO,{{ || qesco(-1,0,@cTIPO                  ,sBLOCO2 )} ,"TIPO" })
aadd(aEDICAO,{{ || qesco(-1,0,@cORDEM                 ,sBLOCO3 )} ,"ORDEM"})

do while .T.

   qlbloc(5,0,"B503A","QBLOC.GLO",1)
   XNIVEL  := 1
   XFLAG   := .T.
   cCUSTO  := space(8)
   cTIPO   := "A"
   cORDEM  := "M"

   nVALFR  := 0    // valor de ferias
   nVALIN  := 0    // valor de INSS
   nVALFG  := 0    // valor de FGTS

   nREFFR  := 0    // valor de ferias
   nREFIN  := 0    // valor de INSS
   nREFFG  := 0    // valor de FGTS

   nTOT_C_FR  := 0    // total do centro de ferias
   nTOT_C_IN  := 0    // total do centro de INSS
   nTOT_C_FG  := 0    // total do centro de FGTS

   nTOT_G_FR  := 0    // total geral de ferias
   nTOT_G_IN  := 0    // total geral de INSS
   nTOT_G_FG  := 0    // total geral de FGTS

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
      case cCAMPO == "CUSTO"
           if empty(cCUSTO)
              qrsay(XNIVEL+1,"*** Todos os Centros ***")
           else
              qrsay(XNIVEL,cCUSTO:=alltrim(cCUSTO))
              if ! CCUSTO->(dbseek(cCUSTO))
                 qmensa("Centro de Custo n„o encontrado !","B")
                 return .F.
              endif
              qrsay(XNIVEL+1,left(CCUSTO->Descricao,28))
           endif

      case cCAMPO == "TIPO"
           if empty(cTIPO) ; return .F. ; endif
           qrsay(XNIVEL,qabrev(cTIPO,"AS",{"Anal¡tica","Sint‚tica"}))

      case cCAMPO == "ORDEM"
           if empty(cORDEM) ; return .F. ; endif
           qrsay(XNIVEL,qabrev(cORDEM,"MN",{"Matr¡cula","Nome"}))

   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // CRIA TITULO DO RELATORIO ______________________________________________

   cTITULO := "PROVISAO PARA FERIAS - " + qnomemes(XDATASYS) + " DE "+ str(year(XDATASYS))
   
   // SELECIONA ORDEM DO ARQUIVO CODIGOS_____________________________________

   qmensa("")

   SITUA->(dbSetFilter({|| Anomes == XANOMES},"Anomes == XANOMES"))

   // ESTABELECE RELACOES ENTRE ARQUIVOS ____________________________________

   if cORDEM == "M"
//    FUN->(dbsetorder(7)) // CENTRO + MATRICULA
      FUN->(dbsetorder(1)) // MATRICULA
   else
//    FUN->(dbsetorder(8)) // CENTRO + NOME
      FUN->(dbsetorder(2)) // NOME
   endif

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impressao

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif

// if ! empty(cCUSTO)
//    FUN->(dbseek(cCUSTO))
// else

      FUN->(dbgotop())

// endif

   do while ! FUN->(eof()) .and. qcontprn()

      SITUA->(dbseek(FUN->Matricula))

      if ! empty(cCUSTO) .and. SITUA->Ccusto <> cCUSTO
         FUN->(dbskip())
         loop
      endif

      if SITUA->Situacao $ "HD " .or. FUN->Data_adm > qfimmes(XDATASYS) .or. SITUA->Vinculo == K_DIRETOR
         FUN->(dbskip())
         loop
      endif

      if SITUA->Categoria == "9" .and. SITUA->Vinculo == "H"
         FUN->(dbskip())
         loop
      endif

      qmensa("Funcionario: "+FUN->Matricula+" / "+left(FUN->Nome,30))

      if LANC->(dbseek(XANOMES+FUN->Matricula+"MS"+"591"))
         nVALFR := LANC->Valor
         nREFFR := LANC->Fracao
      endif
      if LANC->(dbseek(XANOMES+FUN->Matricula+"MS"+"592"))
         nVALIN := LANC->Valor
         nREFIN := LANC->Fracao
      endif
      if LANC->(dbseek(XANOMES+FUN->Matricula+"MS"+"593"))
         nVALFG := LANC->Valor
         nREFFG := LANC->Fracao
      endif

      if ! qlineprn() ; exit ; endif

      qgirabarra()

      if XPAGINA == 0 .or. prow() > K_MAX_LIN
         @ prow(),pcol() say XCOND0 + XAENFAT
         qpageprn()
         qcabecprn(cTITULO,80)
         if cTIPO == "A"
            @ prow()+1,0 say "MATRIC.  NOME                            FERIAS               INSS          FGTS"
            @ prow()+1,0 say replicate("-",80)
         else
            @ prow()+1,0 say "                                         FERIAS               INSS          FGTS"
         endif
         @ prow(),pcol() say XDENFAT
      endif

//    if empty(cCUSTO) .or. cCUSTO == FUN->Centro
      if empty(cCUSTO) .or. cCUSTO == SITUA->Ccusto

         if lIMP_CUSTO
//          CCUSTO->(dbseek(FUN->Centro))
            CCUSTO->(dbseek(SITUA->Ccusto))
            @ prow(),pcol() say XCOND0
            @ prow()+2,0 say "Centro: " + transform(CCUSTO->Codigo,"@R 99.99.9999")
            lIMP_CUSTO := .F.
         endif

//       cTMP_CUSTO := FUN->Centro
         cTMP_CUSTO := SITUA->Ccusto

         if cTIPO == "A"
            @ prow()+1,0         say XCOND1 + FUN->Matricula
            @ prow()  ,pcol()+10 say left(FUN->Nome,30)
            @ prow()  ,pcol()+26 say transform(nVALFR,"9,999,999.99")
            @ prow()  ,pcol()+1 say transform(nREFFR,"99.99")
            @ prow()  ,pcol()+4 say transform(nVALIN,"9,999,999.99")
            @ prow()  ,pcol()+2 say transform(nREFIN,"99.99")
            @ prow()  ,pcol()+5 say transform(nVALFG,"9,999,999.99")
            @ prow()  ,pcol()+2 say transform(nREFFG,"99.99")
         endif

         nTOT_C_FR += nVALFR
         nTOT_C_IN += nVALIN
         nTOT_C_FG += nVALFG

         nTOT_G_FR += nVALFR
         nTOT_G_IN += nVALIN
         nTOT_G_FG += nVALFG

         nVALFR := 0
         nVALIN := 0
         nVALFG := 0

         nREFFR := 0
         nREFIN := 0
         nREFFG := 0

      endif

      FUN->(dbskip())

//    if cTMP_CUSTO <> FUN->Centro .and. nTOT_C_FR <> 0

      SITUA->(dbseek(FUN->Matricula))

      if cTMP_CUSTO <> SITUA->Ccusto .and. nTOT_C_FR <> 0

         if cTIPO == "A"
            @ prow()+1,0 say XCOND0 + replicate("-",80)
            @ prow()+1,0 say "Total do Centro:  "
            @ prow()  ,40 say transform(nTOT_C_FR,"9,999,999.99")
            @ prow()  ,pcol()+2 say transform(nTOT_C_IN,"9,999,999.99")
            @ prow()  ,pcol()+2 say transform(nTOT_C_FG,"9,999,999.99")
         else
            @ prow()  ,40 say transform(nTOT_C_FR,"9,999,999.99")
            @ prow()  ,pcol()+2 say transform(nTOT_C_IN,"9,999,999.99")
            @ prow()  ,pcol()+2 say transform(nTOT_C_FG,"9,999,999.99")
         endif

         nTOT_C_FR := 0
         nTOT_C_IN := 0
         nTOT_C_FG := 0

         lIMP_CUSTO := .T.

      endif

   enddo

   @ prow()+2,0 say replicate("=",80)
   @ prow()+1,0 say "Total Geral....: "
   @ prow()  ,40 say transform(nTOT_G_FR,"9,999,999.99")
   @ prow()  ,pcol()+2 say transform(nTOT_G_IN,"9,999,999.99")
   @ prow()  ,pcol()+2 say transform(nTOT_G_FG,"9,999,999.99")

   qstopprn()

return

