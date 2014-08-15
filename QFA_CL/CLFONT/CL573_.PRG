/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO COMERCIO
// OBJETIVO...: RELATORIO DE FATURAMENTO POR SETOR
// ANALISTA...: EDUARDO AUGUSTO BORIO
// PROGRAMADOR: EDUARDO AUGUSTO BORIO
// INICIO.....: NOVEMBRO DE 2002
// OBS........:
// ALTERACOES.:

function cl573
#define K_MAX_LIN 57

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG) .or. empty(dINI) }

private cTITULO                   // titulo do relatorio
private dINI
private dFIM
private cTIPO:= ""
private aEDICAO := {}             // vetor para os campos de entrada de dados
private sBLOC1  := qlbloc("B573B","QBLOC.GLO")


// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qgetx(-1,0,@dINI)            } , "INI"    })
aadd(aEDICAO,{{ || qgetx(-1,0,@dFIM)            } , "FIM"    })
aadd(aEDICAO,{{ || qesco(-1,0,@cTIPO ,sBLOC1    )}  ,"TIPO"  })

//aadd(aEDICAO,{{ || view_cli(-1,0,@cCLI)     } , "CLI"  })
//aadd(aEDICAO,{{ || NIL                          } , NIL  })

do while .T.

   qlbloc(5,0,"B573A","QBLOC.GLO")
   XNIVEL := 1
   XFLAG  := .T.
   dINI := dFIM := ctod("")
   cTIPO:= ""

   // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; dbcloseall() ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   if ( i_inicializacao() , i_impressao() , NIL )

   qmensa("")

enddo

/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA _____________________________________________

static function i_critica ( cCAMPO )

   do case
      case cCAMPO == "FIM"
           if dFIM < dINI
             return .F.
           endif

      case cCAMPO == "TIPO"
           if empty(cTIPO) ; return .F. ; endif
           qrsay(XNIVEL,qabrev(cTIPO,"12",{"1 - Clientes","2 - Trasportadoras"}))


   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // CRIA TITULO DO RELATORIO ______________________________________________


   cTITULO := "RELATORIO DE % DE CUSTO DE FRETE " +" de " + dtoc(dINI) + " a " + dtoc(dFIM)

   qmensa("")

   // ESTABELECE RELACOES ENTRE ARQUIVOS ____________________________________

   FRETE->(dbsetfilter({|| Dt_emissao >= dINI .and. Dt_Emissao <= dFIM}))
   if cTIPO == "1"
      FRETE->(dbsetorder(3))
   else
      FRETE->(dbsetorder(6))
   endif
   FRETE->(dbgotop())


return .T.


static function i_impressao

   if ! qinitprn() ; return  ; endif

   if XLOCALIMP == "X"
      if cTIPO == "1"
         i_CliXls()
      else
         i_TranspXls()
      endif
   else
      if cTipo == "1"
         i_CliPrn()
      else
         i_TranspPrn()
      endif
   endif

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_CliPrn
   local nFrete    := 0
   local nTTFrete := 0
   local nNotas    := 0
   local nTTNotas := 0

   local zCLI   := ""
   local zRazao := ""

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   zCLI := FRETE->Cod_cli

   do while ! FRETE->(eof())

      if ! qlineprn() ; exit ; endif

      if XPAGINA == 0 .or. prow() > K_MAX_LIN
         @prow()+1,0 say XCOND1
         qpageprn()
         qcabecprn(cTITULO,132)
         @ prow()+1,0 say "Emissao    Cliente                                                    Valor do Frete    Valor das NF(s)            % "
         @ prow()+1,0 say ""
      endif

      qgirabarra()

      qmensa("Aguarde... Processando ...")
   
      CLI1->(dbseek(FRETE->Cod_cli))

      CGM->(dbgotop())
      CGM->(dbseek(CLI1->Cgm_cob))

      @ prow()+1,00  say dtoc(FRETE->Dt_emissao)
      @ prow()  ,12  say left(CLI1->Razao,50)
      @ prow()  ,70  say transform(FRETE->Vlr_Total,"@E 999,999.99")
      @ prow()  ,90  say transform(FRETE->Vlr_Nf,"@E 999,999.99")
      @ prow()  ,110 say transform((FRETE->Vlr_total/FRETE->Vlr_NF)*100,"@E 999.99")+" %"

      nFrete     += FRETE->vlr_Total
      nTTFrete   += FRETE->vlr_Total
      nNotas     += FRETE->vlr_NF
      nTTNotas   += FRETE->vlr_NF


      FRETE->(dbskip())

      if FRETE->cod_cli != zCLI
         CLI1->(dbseek(zCLI))
         @ prow()+1,00  Say "Total do cliente.: "+left(CLI1->Razao,40)
         @ prow()  ,68  say transform(nFrete,"@E 9,999,999.99")
         @ prow()  ,88  say transform(nNotas,"@E 9,999,999.99")
         @ prow()  ,110 say transform((nFrete/nNotas)*100,"@E 999.99")+" %"
         @ prow()+1,00  Say replicate("-",132)
         @ prow()+1,0 say ""


         zCLI := FRETE->Cod_cli
         nFrete := 0
         nNotas := 0

      endif

   enddo

   if nFrete > 0
      CLI1->(dbseek(zCLI))
      @ prow()+1,00  Say "Total do cliente.: "+left(CLI1->Razao,40)
      @ prow()  ,68  say transform(nFrete,"@E 9,999,999.99")
      @ prow()  ,88  say transform(nNotas,"@E 9,999,999.99")
      @ prow()  ,110 say transform((nFrete/nNotas)*100,"@E 999.99")+" %"

      @ prow()+1,00  Say replicate("-",132)

      nFrete := 0
      nNotas := 0
   endif

   @ prow()+1,00  Say "Total Geral.: "
   @ prow()  ,68  say transform(nTTFrete,"@E 9,999,999.99")
   @ prow()  ,88  say transform(nTTNotas,"@E 9,999,999.99")
   @ prow()  ,110 say transform((nTTFrete/nTTNotas)*100,"@E 999.99")+" %"

   qstopprn(.F.)

return

static function i_TranspPrn
   local nFrete    := 0
   local nTTFrete := 0
   local nNotas    := 0
   local nTTNotas := 0

   local zFORN  := ""
   local zRazao := ""

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   zFORN := FRETE->Cod_forn

   do while ! FRETE->(eof())

      if ! qlineprn() ; exit ; endif

      if XPAGINA == 0 .or. prow() > K_MAX_LIN
         @prow()+1,0 say XCOND1
         qpageprn()
         qcabecprn(cTITULO,132)
         @ prow()+1,0 say "Emissao    Cliente                                                    Valor do Frete    Valor das NF(s)            % "
         @ prow()+1,0 say ""
      endif

      qgirabarra()

      qmensa("Aguarde... Processando ...")
   
      CLI1->(dbseek(FRETE->Cod_cli))

      CGM->(dbgotop())
      CGM->(dbseek(CLI1->Cgm_cob))

      @ prow()+1,00  say dtoc(FRETE->Dt_emissao)
      @ prow()  ,12  say left(CLI1->Razao,50)
      @ prow()  ,70  say transform(FRETE->Vlr_Total,"@E 999,999.99")
      @ prow()  ,90  say transform(FRETE->Vlr_Nf,"@E 999,999.99")
      @ prow()  ,110 say transform((FRETE->Vlr_total/FRETE->Vlr_NF)*100,"@E 999.99")+" %"

      nFrete     += FRETE->vlr_Total
      nTTFrete   += FRETE->vlr_Total
      nNotas     += FRETE->vlr_NF
      nTTNotas   += FRETE->vlr_NF


      FRETE->(dbskip())

      if FRETE->cod_forn != zFORN
         FORN->(dbseek(zFORN))
         @ prow()+1,00  Say "Total da Transportadora.: "+left(FORN->Razao,40)
         @ prow()  ,68  say transform(nFrete,"@E 9,999,999.99")
         @ prow()  ,88  say transform(nNotas,"@E 9,999,999.99")
         @ prow()  ,110 say transform((nFrete/nNotas)*100,"@E 999.99")+" %"
         @ prow()+1,00  Say replicate("-",132)
         @ prow()+1,0 say ""

         zFORN := FRETE->Cod_forn
         nFrete := 0
         nNotas := 0

      endif

   enddo

   if nFrete > 0
      FORN->(dbseek(zFORN))
      @ prow()+1,00  Say "Total da Transportadora.: "+left(FORN->Razao,40)
      @ prow()  ,68  say transform(nFrete,"@E 9,999,999.99")
      @ prow()  ,88  say transform(nNotas,"@E 9,999,999.99")
      @ prow()  ,110 say transform((nFrete/nNotas)*100,"@E 999.99")+" %"

      @ prow()+1,00  Say replicate("-",132)

      nFrete := 0
      nNotas := 0
   endif

   @ prow()+1,00  Say "Total Geral.: "
   @ prow()  ,68  say transform(nTTFrete,"@E 9,999,999.99")
   @ prow()  ,88  say transform(nTTNotas,"@E 9,999,999.99")
   @ prow()  ,110 say transform((nTTFrete/nTTNotas)*100,"@E 999.99")+" %"

   qstopprn(.F.)

return


static function i_CliXls
   local nFrete    := 0
   local nTTFrete := 0
   local nNotas    := 0
   local nTTNotas := 0

   local zCLI   := ""
   local zRazao := ""

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   zCLI := FRETE->Cod_cli

   do while ! FRETE->(eof())

      if ! qlineprn() ; exit ; endif

      if XPAGINA == 0 //.or. prow() > K_MAX_LIN
         @prow()+1,0 say ""
         qpageprn()
         //qcabecprn(cTITULO,132)
         @ prow()+1,0 say chr(9)+cTitulo+" 573"
         @ prow()+1,0 say "Emissao"+chr(9)+"Cliente"+chr(9)+"Valor do Frete"+chr(9)+"Valor das NF(s)"+chr(9)+" % "
         @ prow()+1,0 say ""
      endif

      qgirabarra()

      qmensa("Aguarde... Processando ...")
   
      CLI1->(dbseek(FRETE->Cod_cli))

      CGM->(dbgotop())
      CGM->(dbseek(CLI1->Cgm_cob))

      @ prow()+1,00      say dtoc(FRETE->Dt_emissao)
      @ prow()  ,pcol()  say chr(9)+left(CLI1->Razao,50)
      @ prow()  ,pcol()  say chr(9)+transform(FRETE->Vlr_Total,"@E 999,999.99")
      @ prow()  ,pcol()  say chr(9)+transform(FRETE->Vlr_Nf,"@E 999,999.99")
      @ prow()  ,pcol()  say chr(9)+transform((FRETE->Vlr_total/FRETE->Vlr_NF)*100,"@E 999.99")+" %"

      nFrete     += FRETE->vlr_Total
      nTTFrete   += FRETE->vlr_Total
      nNotas     += FRETE->vlr_NF
      nTTNotas   += FRETE->vlr_NF


      FRETE->(dbskip())

      if FRETE->cod_cli != zCLI
         CLI1->(dbseek(zCLI))
         @ prow()+1,00      Say chr(9)+"Total do cliente.: "+left(CLI1->Razao,40)
         @ prow()  ,pcol()  say chr(9)+transform(nFrete,"@E 9,999,999.99")
         @ prow()  ,pcol()  say chr(9)+transform(nNotas,"@E 9,999,999.99")
         @ prow()  ,pcol()  say chr(9)+transform((nFrete/nNotas)*100,"@E 999.99")+" %"
         @ prow()+1,0 say ""
         @ prow()+1,0 say ""


         zCLI := FRETE->Cod_cli
         nFrete := 0
         nNotas := 0

      endif

   enddo

   CLI1->(dbseek(zCLI))
   if nFrete > 0
      @ prow()+1,00     Say chr(9)+"Total do cliente.: "+left(CLI1->Razao,40)
      @ prow()  ,pcol() say chr(9)+transform(nFrete,"@E 9,999,999.99")
      @ prow()  ,pcol() say chr(9)+transform(nNotas,"@E 9,999,999.99")
      @ prow()  ,pcol() say chr(9)+transform((nFrete/nNotas)*100,"@E 999.99")+" %"

      @ prow()+1,00  Say ""

      nFrete := 0
      nNotas := 0
   endif


   @ prow()+1,00      Say chr(9)+"Total Geral.: "
   @ prow()  ,pcol()  say chr(9)+transform(nTTFrete,"@E 9,999,999.99")
   @ prow()  ,pcol()  say chr(9)+transform(nTTNotas,"@E 9,999,999.99")
   @ prow()  ,pcol()  say chr(9)+transform((nTTFrete/nTTNotas)*100,"@E 999.99")+" %"

   qstopprn(.F.)

return


static function i_TranspXls
   local nFrete    := 0
   local nTTFrete := 0
   local nNotas    := 0
   local nTTNotas := 0

   local zFORN   := ""
   local zRazao := ""

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   zFORN := FRETE->Cod_forn

   do while ! FRETE->(eof())

      if ! qlineprn() ; exit ; endif

      if XPAGINA == 0 //.or. prow() > K_MAX_LIN
         @prow()+1,0 say ""
         qpageprn()
         @ prow()+1,0 say chr(9)+cTitulo+" 573"
         @ prow()+1,0 say "Emissao"+chr(9)+"Cliente"+chr(9)+"Valor do Frete"+chr(9)+"Valor das NF(s)"+chr(9)+" % "
         @ prow()+1,0 say ""
      endif

      qgirabarra()

      qmensa("Aguarde... Processando ...")
   
      CLI1->(dbseek(FRETE->Cod_cli))

      CGM->(dbgotop())
      CGM->(dbseek(CLI1->Cgm_cob))

      @ prow()+1,00      say dtoc(FRETE->Dt_emissao)
      @ prow()  ,pcol()  say chr(9)+left(CLI1->Razao,50)
      @ prow()  ,pcol()  say chr(9)+transform(FRETE->Vlr_Total,"@E 999,999.99")
      @ prow()  ,pcol()  say chr(9)+transform(FRETE->Vlr_Nf,"@E 999,999.99")
      @ prow()  ,pcol()  say chr(9)+transform((FRETE->Vlr_total/FRETE->Vlr_NF)*100,"@E 999.99")+" %"

      nFrete     += FRETE->vlr_Total
      nTTFrete   += FRETE->vlr_Total
      nNotas     += FRETE->vlr_NF
      nTTNotas   += FRETE->vlr_NF


      FRETE->(dbskip())

      if FRETE->cod_forn != zFORN
         FORN->(dbseek(zFORN))
         @ prow()+1,00      Say chr(9)+"Total da Transportadora.: "+left(FORN->Razao,40)
         @ prow()  ,pcol()  say chr(9)+transform(nFrete,"@E 9,999,999.99")
         @ prow()  ,pcol()  say chr(9)+transform(nNotas,"@E 9,999,999.99")
         @ prow()  ,pcol()  say chr(9)+transform((nFrete/nNotas)*100,"@E 999.99")+" %"
         @ prow()+1,0 say ""
         @ prow()+1,0 say ""


         zFORN := FRETE->Cod_forn
         nFrete := 0
         nNotas := 0

      endif

   enddo

   FORN->(dbseek(zFORN))
   if nFrete > 0
      @ prow()+1,00     Say chr(9)+"Total da Transportadora.: "+left(FORN->Razao,40)
      @ prow()  ,pcol() say chr(9)+transform(nFrete,"@E 9,999,999.99")
      @ prow()  ,pcol() say chr(9)+transform(nNotas,"@E 9,999,999.99")
      @ prow()  ,pcol() say chr(9)+transform((nFrete/nNotas)*100,"@E 999.99")+" %"

      @ prow()+1,00  Say ""

      nFrete := 0
      nNotas := 0
   endif


   @ prow()+1,00      Say chr(9)+"Total Geral.: "
   @ prow()  ,pcol()  say chr(9)+transform(nTTFrete,"@E 9,999,999.99")
   @ prow()  ,pcol()  say chr(9)+transform(nTTNotas,"@E 9,999,999.99")
   @ prow()  ,pcol()  say chr(9)+transform((nTTFrete/nTTNotas)*100,"@E 999.99")+" %"

   qstopprn(.F.)

return




