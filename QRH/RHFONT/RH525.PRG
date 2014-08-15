/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: FOLHA DE PAGAMENTO
// OBJETIVO...: CARTA DE CREDITO BANCARIO
// ANALISTA...: CARLOS EDUARDO RABELLO NUNES
// PROGRAMADOR: O MESMO
// INICIO.....: OUTUBRO DE 1994
// OBS........:
// ALTERACOES.:

#define K_MAX_LIN 52

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG) .or. empty(cORDEM)}

private sBLOCO1 := qlbloc("B525B","QBLOC.GLO") // bloco ordem
private sBLOCO2 := qlbloc("B525C","QBLOC.GLO") // bloco tipo

private cTITULO1, cTITULO2     // para montar o titulo do relatorio
private cORDEM                 // ordem de impressao (numero da conta/matricula/nome)
private cTIPO                  // tipo de relatorio (mensal, adt , 13. ou ferias)
private cBANCO                 // banco de filtro
private cCENTRO                // centro para filtro
private cQUEBRA                // quebra por agencia (sim ou nao)
private cZERADO                // imprime liquido zerado (sim ou nao)
private aEDICAO := {}          // vetor para os campos de entrada de dados

SITUA->(dbSetFilter({|| Anomes == XANOMES},"Anomes == XANOMES"))

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qesco(-1,0,@cORDEM,sBLOCO1 )} , "ORDEM"  })
aadd(aEDICAO,{{ || qesco(-1,0,@cTIPO ,sBLOCO2 )} , "TIPO"   })
aadd(aEDICAO,{{ || view_banco(-1,0,@cBANCO    )} , "BANCO"  })
aadd(aEDICAO,{{ || NIL },NIL}) // descricao do banco
aadd(aEDICAO,{{ || qesco(-1,0,@cQUEBRA,XSN    )} , "QUEBRA" })
aadd(aEDICAO,{{ || qesco(-1,0,@cZERADO,XSN    )} , "ZERADO" })
aadd(aEDICAO,{{ || view_ccusto(-1,0,@cCENTRO) }  , "CENTRO" })
aadd(aEDICAO,{{ || NIL },NIL}) // descricao do centro
aadd(aEDICAO,{{ || view_sind(-1,0,@cCOD_SIND)           }, "COD_SIND"  })
aadd(aEDICAO,{{ || NIL },NIL}) // descricao do sindicato

do while .T.

   qlbloc(5,0,"B525A","QBLOC.GLO")
   XNIVEL  := 1
   XFLAG   := .T.
   cORDEM  := "1"
   cTIPO   := "M"
   cBANCO  := space(8)
   cORDEM  := " "
   cQUEBRA := "S"
   cZERADO := "N"
   cCENTRO := space(8)
   cCOD_SIND := space(2)
   qmensa()

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
           qrsay(XNIVEL,qabrev(cORDEM,"123",{"N£mero da Conta","Matr¡cula","Nome"}))
      case cCAMPO == "TIPO"
           qrsay(XNIVEL,qabrev(cTIPO,"MADFC",{"Mensal","Adiantamento","D‚cimo Terceiro","Ferias","Contabil"}))
      case cCAMPO == "BANCO"
           qrsay(XNIVEL+1,iif(BANCO->(dbseek(cBANCO)),BANCO->Banco+"/"+BANCO->Agencia,"*** Todos os Bancos ***"))
      case cCAMPO == "QUEBRA"
           qrsay(XNIVEL,qabrev(cQUEBRA,"SN",{"Sim","N„o"}))
      case cCAMPO == "ZERADO"
           qrsay(XNIVEL,qabrev(cZERADO,"SN",{"Sim","N„o"}))
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
      case cCAMPO == "COD_SIND"
           if ! empty(cCOD_SIND)
              if ! SIND->(dbseek(cCOD_SIND))
                 qmensa("Sindicato n„o Cadastrado !!","B")
                 return .F.
              endif
              qrsay ( XNIVEL+1 , left(SIND->Descricao,30) )
           else
              qrsay(XNIVEL+1 , "****  Todos os Sindicatos  ****")
           endif
   endcase
return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // INDEXANDO POR BANCO __________________________________________________

   qmensa("Aguarde, criando indice por banco...")

   select FUN

   do case
      case cORDEM == "1"
//         index on Csal_ban + Csal_num  to (XDRV_RH+"TMP") for Situacao <> "H"
//         index on Csal_num  to (XDRV_RH+"TMP") for Situacao <> "H"
           index on Csal_ban  to (XDRV_RH+"TMP") for Situacao <> "H"
      case cORDEM == "2"
//         index on Csal_ban + Matricula to (XDRV_RH+"TMP") for Situacao <> "H"
           index on Csal_ban + Matricula to (XDRV_RH+"TMP") for Situacao <> "H"
           FUN->(dbsetorder(1))
      case cORDEM == "3"
//         index on Csal_ban + Nome      to (XDRV_RH+"TMP") for Situacao <> "H"
           index on Csal_ban + Nome      to (XDRV_RH+"TMP") for Situacao <> "H"
           FUN->(dbsetorder(2))
   endcase

   // FILTRA POR CENTRO, SE FOR O CASO ______________________________________

// if ! empty(cCENTRO)
//    set filter to Centro == cCENTRO
// endif

   // ESTABELECE RELACOES ENTRE ARQUIVOS ____________________________________

   FUN->(dbsetrelation("BASE",{|| Matricula+XANOMES},"Matricula+XANOMES"))
// FUN->(dbsetrelation("CCUSTO",{|| Centro},"Centro"))
// SITUA->(dbsetrelation("CCUSTO",{|| cCentro},"cCentro"))
   FUN->(dbsetrelation("FILIAL",{|| Filial},"Filial"))
// FUN->(dbsetrelation("BANCO" ,{|| Csal_ban},"Csal_ban"))
   FUN->(dbsetrelation("BANCO" ,{|| Csal_ban},"Csal_ban"))

   FUN->(dbgotop())

   // CONSTROI VARIAVEL "cTITULO" ___________________________________________

   cTITULO1 := "CARTA DE CREDITO BANCARIO - "

   do case
      case cTIPO == "M"
           cTITULO1+= "FOLHA MENSAL DE "
      case cTIPO == "A"
           cTITULO1+= "ADIANTAMENTO MENSAL DE "
      case cTIPO == "D"
           cTITULO1+= "DECIMO TERCEIRO DE "
      case cTIPO == "F"
           cTITULO1+= "FERIAS DE "
      case cTIPO == "C"
           cTITULO1+= "CONTABIL DE"
      endcase

   cTITULO1+= upper(qnomemes(month(XDATASYS))) + "/" + str(year(XDATASYS),4)

// cTITULO2 := "CENTRO DE CUSTO: " + FUN->Centro + " - " + CCUSTO->Descricao
   cTITULO2 := "CENTRO DE CUSTO: " + SITUA->Ccusto + " - " + CCUSTO->Descricao

   // SE ESCOLHER BANCO UNICO, ENTAO POSICIONA ______________________________

   if ! empty(cBANCO)
      FUN->(dbseek(cBANCO))
   endif

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR A IMPRESSAO GERAL ________________________________

static function i_impressao

   local nTOTAL := 0, cLASTBAN := FUN->Csal_ban, cSTRING , nVALOR

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif
   qmensa("imprimindo...")

   @ prow(),pcol() say XCOND0

   do while ! FUN->(eof()) .and. qcontprn()     // condicao principal de loop

      SITUA->(dbseek(FUN->Matricula))

      if ! empty(cCENTRO) .and. SITUA->CCusto <> cCENTRO
         FUN->(dbskip())
         loop
      endif

      if FUN->Data_adm > qfimmes(XDATASYS) .or. SITUA->Tipo_pgto != "B"
         FUN->(dbskip())
         loop
      endif

      if ! empty(cCOD_SIND)
         if FUN->Sind_cod <> cCOD_SIND
            FUN->(dbskip())
            loop
         endif
      endif
      
      if FUN->Situacao $ "H "
         FUN->(dbskip())
         loop
      endif

      qmensa("Funcionario: "+FUN->Matricula+" / "+left(FUN->Nome,30) )

      if ! qlineprn() ; return ; endif

      // CABECALHO SE NECESSARIO ____________________________________________

      if XPAGINA == 0 .or. prow() > K_MAX_LIN
         qpageprn()
         @ prow(),pcol() say XCOND0
         if ! empty(cCENTRO)
            qcabecprn(cTITULO1,80,.T.,cTITULO2)
         else
            qcabecprn(cTITULO1,80)
         endif
         if cQUEBRA == "S"
            @ prow()+2,0 say padc("BANCO: " + FUN->Csal_ban + " / " + BANCO->Banco + "/" + BANCO->Agencia,80)
            @ prow()+2,3 say XCOND1 + "MATRICULA   NOME                             SITUACAO    CENTRO           AGENCIA    NUMERO DA CONTA        VALOR A CREDITAR"
         else
            @ prow()+2,2 say XCOND1 + "MATRICULA     NOME                             SITUACAO      CENTRO         AGENCIA       NUMERO DA CONTA       VALOR A CREDITAR"
         endif
         @ prow()+1,0 say replicate("-",137)
      endif

      do case
         case cTIPO == "M"
              nVALOR := BASE->Prov_ms - BASE->Desc_ms
         case cTIPO == "A"
              nVALOR := BASE->Prov_ad - BASE->Desc_ad
         case cTIPO == "D"
              nVALOR := BASE->Prov_dt - BASE->Desc_dt
         case cTIPO == "F"
              nVALOR := BASE->Prov_fr - BASE->Desc_fr
         case cTIPO == "C"
              nVALOR := (BASE->Prov_ms - BASE->Prov_dt) - (BASE->Desc_ms + BASE->Desc_dt)
      endcase

      if cZERADO == "N" .and. nVALOR <= 0
         FUN->(dbskip())
         loop
      endif

      if cQUEBRA == "S"
         i_imprime1()
      else
         i_imprime2()
      endif
      
      nTOTAL += nVALOR

      FUN->(dbskip())

      if cQUEBRA == "S"
         @ prow(),pcol()+10 say transform(nVALOR,"9,999,999,999.99")

         // SE MUDAR DE BANCO, ENTAO TOTALIZA E REINICIA _______________________

         if cLASTBAN <> FUN->Csal_ban
            @ prow()+2,106 say "Total: " + transform(nTOTAL,"@E 9,999,999,999.99")
            cLASTBAN := FUN->Csal_ban
            setprc(100,0)
            nTOTAL  := 0
            if ! empty(cBANCO) ; exit ; endif   // para sair se escolheu banco.
         endif
      else
         @ prow(),pcol()+10 say transform(nVALOR,"9,999,999,999.99")
      endif

   enddo

   if cQUEBRA == "N"
      @ prow()+2,109 say "Total: " + transform(nTOTAL,"@E 9,999,999,999.99")
   endif

   qstopprn()

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA A IMPRESSAO (TIPO1 - COM QUEBRA POR AGENCIA) _________________

static function i_imprime1

   // DADOS DE CADA FUNCIONARIO __________________________________________

   @ prow()+1,7        say FUN->Matricula
   @ prow()  ,pcol()+4 say left(FUN->Nome,30)
   @ prow()  ,pcol()+7 say FUN->Situacao
// @ prow()  ,pcol()+7 say FUN->Centro
   @ prow()  ,pcol()+7 say SITUA->Ccusto
   @ prow()  ,pcol()+7 say FUN->Csal_ban
   @ prow()  ,pcol()+7 say FUN->Csal_num

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA A IMPRESSAO (TIPO2 - SEM QUEBRA POR AGENCIA) _________________

static function i_imprime2

   // DADOS DE CADA FUNCIONARIO __________________________________________

   @ prow()+1,5         say FUN->Matricula
   @ prow()  ,pcol()+6  say left(FUN->Nome,30)
   @ prow()  ,pcol()+7  say FUN->Situacao
// @ prow()  ,pcol()+10 say FUN->Centro
   @ prow()  ,pcol()+10 say SITUA->Ccusto
   @ prow()  ,pcol()+4  say FUN->Csal_ban
   @ prow()  ,pcol()+10 say FUN->Csal_num

return
