/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: RECURSOS HUMANOS
// OBJETIVO...: EMISSAO DO DEMONSTRATIVO DE PAGAMENTO (002)
// ANALISTA...: LUCINEIDE VILAR POSSEBOM
// PROGRAMADOR: A MESMA
// INICIO.....: MARCO DE 1998
// OBS........:
// ALTERACOES.:

// RELATORIO DA FOLHA DE PAGAMENTO

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG .or. lastkey()==27) }

private sBLOCO1 := qlbloc("B563A","QBLOC.GLO") // bloco basico
private sBLOCO2 := qlbloc("B563B","QBLOC.GLO") // ambiente escolhido
private sBLOCO3 := qlbloc("B563C","QBLOC.GLO") // ordem de impressao

private cTIPOREL                // tipo de relatorio (mensal ou 13o.)
private cTITULO                 // titulo do relatorio
private cORDEM     := "M"       // ordem de impressao (matricula/nome)
private cMATRICULA := space(6)  // matricula do funcionario
private aEDICAO    := {}        // vetor para os campos de entrada de dados
private aPROV      := {}        // vetor para os eventos de provento
private aDESC      := {}        // vetor para os eventos de desconto
private aEVENTOS   := {}        // vetor para os eventos

private nPROV1_MS  := 0        // somatorio das bases da empresa 001
private nPROV1_AD  := 0
private nPROV1_FR  := 0
private nPROV1_DT  := 0
private nTOT_PROV  := 0
private nTOT_DESC  := 0
private nTOT_HORAS := 0

private nPROV2_MS  := 0        // somatorio das bases da empresa 002
private nPROV2_AD  := 0
private nPROV2_FR  := 0
private nPROV2_DT  := 0

private nFRACAO    := 0

private lTIRA_FRACAO := .F.

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qesco(-1,0,@cTIPOREL ,sBLOCO2)}       , "TIPOREL"  })
aadd(aEDICAO,{{ || qesco(-1,0,@cORDEM   ,sBLOCO3)}       , "ORDEM"    })
aadd(aEDICAO,{{ || view_fun(-1,0,@cMATRICULA ,"999999")} , "MATRICULA"})
aadd(aEDICAO,{{ || NIL },NIL}) // nome do funcionario

do while .T.

   qlbloc(5,0,"B563A","QBLOC.GLO")
   qmensa()
   XNIVEL    := 1
   XFLAG     := .T.
   cTIPOREL  := " "

   // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; dbcloseall() ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   if XEMPRESA <> "002"
      qmensa("Este relat¢rio deve ser impresso dentro da empresa 002","B")
      return
   endif

   if ( i_inicializacao() , i_impressao() , NIL )

enddo

/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA _____________________________________________

static function i_critica ( cCAMPO )
   do case
      case cCAMPO == "TIPOREL"
           if empty(cTIPOREL) ; return .F. ; endif
           qrsay(XNIVEL,qabrev(cTIPOREL,"MADF",{"Mˆs Corrente","Adiantamento","D‚cimo Terceiro","F‚rias"}))
      case cCAMPO == "ORDEM"
           if empty(cORDEM) ; return .F. ; endif
           qrsay(XNIVEL,qabrev(cORDEM,"MN",{"Matr¡cula","Nome"}))
      case cCAMPO == "MATRICULA"
           if empty(cMATRICULA)
              qrsay(XNIVEL+1,"Todas as Matriculas...")
           else
              if ! FUN->(dbseek(cMATRICULA:=strzero(val(cMATRICULA),6)))
                 qmensa("Matricula n„o Encontrada...","B")
                 cMATRICULA := space(6)
                 return .F.
              else
                 qrsay(XNIVEL+1,left(FUN->Nome,30))
              endif
           endif
   endcase
return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   qmensa("Inicializando Base de Dados...")

   cTIPOREL := qabrev(cTIPOREL,"MADF",{"MS","AD","DT","FR"})

   cTITULO = "DEMONSTRATIVO DA FOLHA DE PAGAMENTO A FUNCIONARIOS - "

   do case
      case cTIPOREL == "MS" ; cTITULO += " MENSAL"
      case cTIPOREL == "AD" ; cTITULO += " ADIANTAMENTO"
      case cTIPOREL == "DT" ; cTITULO += " 13. SALARIO"
      case cTIPOREL == "FR" ; cTITULO += " FERIAS"
   endcase

   cTITULO += " - " + alltrim(qnomemes(XDATASYS)) + "/" + str(year(XDATASYS),4)

   // SELECIONA ORDEM DO ARQUIVO FUN ________________________________________

   do case
      case cORDEM == "M" ; FUN->(dbsetorder(01)) // matricula
      case cORDEM == "N" ; FUN->(dbsetorder(02)) // nome
   endcase

   qmensa()

   FUN->(dbgotop())

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impressao

   local nMAXLIN := 55

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif

   if ! empty(cMATRICULA)
      FUN->(Dbsetorder(1))
      FUN->(Dbseek(cMATRICULA))
      if cORDEM == "N"
         FUN->(dbsetorder(2))
      endif
   endif

   do while ! FUN->(eof()) .and. qcontprn()

      if ! empty(cMATRICULA) .and. FUN->Matricula <> cMATRICULA
         qstopprn()
         return
      endif

      qgirabarra()

      if FUN->Situacao <> "T"
         FUN->(dbskip())
         loop
      endif

      if ! qlineprn() ; return ; endif

      SITUA->(dbSetFilter({|| Anomes == XANOMES},"Anomes == XANOMES"))
      LANC->(dbSetRelation("EVENT",{|| Evento},"Evento"))
      FUN->(dbSetRelation("BASE",{|| Matricula+XANOMES},"Matricula+XANOMES"))
      SITUA->(dbSetRelation("CARGO",{|| Cargo},"Cargo"))
      FUN->(dbSetRelation("LANC",{|| XANOMES+Matricula+cTIPOREL},"XANOMES+Matricula+cTIPOREL"))
      SITUA->(Dbseek(FUN->Matricula))


      aHORAS   := {}
      aPERICUL := {}
      aHE50    := {}
      aHE100   := {}
      aHRPRE   := {}
      aMEDICAO := {}
      aAUXDO   := {}
      aSALFAM  := {}
      aAUXFRA  := {}
      aACIDEN  := {}
      aTAREFA  := {}
      aVALE    := {}
      aDESC1   := {}
      aDESC2   := {}
      aDESC3   := {}
      aREFE    := {}
      aDSMA    := {}
      aHEXMA   := {}
      aREVSL   := {}
      aPGVTR   := {}
      aPENAL   := {}
      aDESFAR  := {}
      aAUXACI  := {}
      aDIFSA   := {}
      aDSR     := {}
      aPDSR    := {}
      aFALTAS  := {}
      aINSS    := {}
      aADTO    := {}
      aPADTO   := {}
      aIRRF    := {}
      aSIND    := {}
      aFGTS    := {}
      aPROLAB  := {}
      aSALSAL  := {}
      aDIFHE   := {}
      aDIFSAL  := {}
      aDESVAL  := {}
      aDESPRO  := {}
      aTAXA    := {}
      nSALARIO     := 0
      nTOT_HORAS   := 0
      nTOT_DESC    := 0
      nTOT_MEDICAO := 0
      nHE50        := 0
      nHE100       := 0

      nSALARIO  := SITUA->Salario

      cNOME := FUN->Nome
      SITUA->(Dbseek(FUN->Matricula))
      CARGO->(Dbseek(SITUA->Cargo))
      cCARGO := CARGO->Descricao

      i_lancs()  // somatoria dos lancamentos

      nMATRICULA := FUN->Matricula

      nREC_FUN := FUN->(recno())
      nREC_LAN := LANC->(recno())

      FUN->(Dbclosearea())
      LANC->(Dbclosearea())
      SITUA->(Dbclosearea())
      BASE->(Dbclosearea())

      if ! quse("\QSYS_G\QRH\E001\","FUN",{"FU_MATRI","FU_NOME","FU_FDMAT","FU_FDNOM","FU_FILMA","FU_FILNO","FU_CENMA","FU_CENNO","FU_MTASS","FU_MTASS","FU_GRPS"})
         qmensa("N„o foi poss¡vel abrir arquivo FUN.DBF na empresa 001 !! Tente novamente.")
         return .F.
      endif

      if ! quse("\QSYS_G\QRH\E001\","LANC",{"LA_MATRI","LA_EVENT","LA_MAEVE"})
         qmensa("N„o foi poss¡vel abrir arquivo LANC.DBF da empresa 001 !! Tente novamente.")
         return .F.
      endif

      if ! quse("\QSYS_G\QRH\E001\","SITUA",{"SI_MATRI","SI_MAAUM"})
         qmensa("N„o foi poss¡vel abrir arquivo SITUA.DBF da empresa 001 !! Tente novamente.")
         return .F.
      endif

      if ! quse("\QSYS_G\QRH\E001\","BASE",{"BA_MATRI"})
         qmensa("N„o foi poss¡vel abrir arquivo BASE.DBF da empresa 001 !! Tente novamente.")
         return .F.
      endif

      SITUA->(dbSetFilter({|| Anomes == XANOMES},"Anomes == XANOMES"))
      LANC->(dbSetRelation("EVENT",{|| Evento},"Evento"))
      FUN->(dbSetRelation("BASE",{|| Matricula+XANOMES},"Matricula+XANOMES"))
      SITUA->(dbSetRelation("CARGO",{|| Cargo},"Cargo"))
      FUN->(dbSetRelation("LANC",{|| XANOMES+Matricula+cTIPOREL},"XANOMES+Matricula+cTIPOREL"))

      FUN->(Dbgotop())

      if FUN->(dbseek(nMATRICULA))

         if cORDEM == "N"
            FUN->(Dbsetorder(2))
         endif

         SITUA->(Dbseek(FUN->Matricula))

         nSALARIO += SITUA->Salario

         if XPAGINA == 0 .or. prow() > nMAXLIN
            qpageprn()
            @ prow(),00    say XCOND0
            qcabecprn(cTITULO,80)
            @ prow()+1,00  say "FUNCIONARIO : " + left(FUN->Nome,50)
            @ prow()  ,60  say "MATRICULA   : " + FUN->Matricula ; SITUA->(Dbseek(FUN->Matricula)) ; CARGO->(Dbseek(SITUA->Cargo))
            @ prow()+1,00  say "FUNCAO      : " + CARGO->Descricao + space(5) + "SALARIO :" + transform(nSALARIO,"@R 9,999,999.99")
         endif

         i_lancs()

      else
         if XPAGINA == 0 .or. prow() > nMAXLIN // se o funcionario nao possui registro na empresa 001
            qpageprn()
            @ prow(),00    say XCOND0
            qcabecprn(cTITULO,80)
            @ prow()+1,00  say "FUNCIONARIO : " + left(cNOME,50)
            @ prow()  ,60  say "MATRICULA   : " + nMATRICULA
            @ prow()+1,00  say "FUNCAO      : " + cCARGO + space(5) + "SALARIO :" + transform(nSALARIO,"@R 9,999,999.99")
         endif
      endif

      FUN->(Dbclosearea())
      LANC->(Dbclosearea())
      SITUA->(Dbclosearea())
      BASE->(Dbclosearea())

      if ! quse("\QSYS_G\QRH\E002\","FUN",{"FU_MATRI","FU_NOME","FU_FDMAT","FU_FDNOM","FU_FILMA","FU_FILNO","FU_CENMA","FU_CENNO","FU_MTASS","FU_MTASS","FU_GRPS"})
         qmensa("N„o foi poss¡vel abrir arquivo FUN.DBF na empresa 002 !! Tente novamente.")
         return .F.
      endif

      if ! quse("\QSYS_G\QRH\E002\","LANC",{"LA_MATRI","LA_EVENT","LA_MAEVE"})
         qmensa("N„o foi poss¡vel abrir arquivo LANC.DBF da empresa 002 !! Tente novamente.")
         return .F.
      endif

      if ! quse("\QSYS_G\QRH\E002\","SITUA",{"SI_MATRI","SI_MAAUM"})
         qmensa("N„o foi poss¡vel abrir arquivo SITUA.DBF da empresa 002 !! Tente novamente.")
         return .F.
      endif

      if ! quse("\QSYS_G\QRH\E002\","BASE",{"BA_MATRI"})
         qmensa("N„o foi poss¡vel abrir arquivo BASE.DBF da empresa 002 !! Tente novamente.")
         return .F.
      endif

      nTOT_HORAS := nTOT_DESC := nTOT_MEDICAO := 0

      @ prow()+1,00 say XCOND0
      @ prow()+1,10 say XAEXPAN + "PROVENTOS HORAS TRABALHADAS" + XDEXPAN
      @ prow()+2,00 say XCOND0 + "..........Descricao........... .....Qtde.. .Valor Unit... ...Total.."
      @ prow()+1,00 say ""

      nFRACAO  := 0
      nVALOR   := 0
      nDESCRICAO := space(30)

      if ! empty(aHORAS)
         for nCONT:= 1 to len(aHORAS)
             nDESCRICAO := padr("HORAS TRABALHADAS",30,".")
             iif(nFRACAO==0, nFRACAO:= aHORAS[nCONT,5] ,)
             nVALOR += aHORAS[nCONT,4]
         next

         @ prow()+1,0  say nDESCRICAO
         @ prow()  ,35 say transform(nFRACAO,"@R 999.99")
         @ prow()  ,55 say transform(nVALOR,"@R 9,999,999.99")
         nTOT_HORAS += nVALOR
      endif

// PROVENTOS -------------------------------------------------------------------

      nFRACAO  := 0
      nVALOR   := 0
      nDESCRICAO := space(30)

      if ! empty(aDIFSA)
         for nCONT:= 1 to len(aDIFSA)
             nDESCRICAO := padr("DIFERENCA SALARIAL",30,".")
             iif(nFRACAO==0, nFRACAO:= aDIFSA[nCONT,5] ,)
             nVALOR += aDIFSA[nCONT,4]
         next

         @ prow()+1,0  say nDESCRICAO
         @ prow()  ,35 say transform(nFRACAO,"@R 999.99")
         @ prow()  ,55 say transform(nVALOR,"@R 9,999,999.99")
         nTOT_HORAS += nVALOR
      endif

      nFRACAO  := 0
      nVALOR   := 0
      nDESCRICAO := space(30)

      if ! empty(aPROLAB)
         for nCONT:= 1 to len(aPROLAB)
             nDESCRICAO := padr("PRO - LABORE",30,".")
             iif(nFRACAO==0, nFRACAO:= aPROLAB[nCONT,5] ,)
             nVALOR += aPROLAB[nCONT,4]
         next

         @ prow()+1,0  say nDESCRICAO
         @ prow()  ,35 say transform(nFRACAO,"@R 999.99")
         @ prow()  ,55 say transform(nVALOR,"@R 9,999,999.99")
         nTOT_HORAS += nVALOR
      endif

      nFRACAO  := 0
      nVALOR   := 0
      nDESCRICAO := space(30)

      if ! empty(aDSMA)
         for nCONT:= 1 to len(aDSMA)
             nDESCRICAO := padr("DIFER.SALARIO MES ANTER.",30,".")
             iif(nFRACAO==0, nFRACAO:= aDSMA[nCONT,5] ,)
             nVALOR += aDSMA[nCONT,4]
         next

         @ prow()+1,0  say nDESCRICAO
         @ prow()  ,35 say transform(nFRACAO,"@R 999.99")
         @ prow()  ,55 say transform(nVALOR,"@R 9,999,999.99")
         nTOT_HORAS += nVALOR
      endif


      nFRACAO  := 0
      nVALOR   := 0
      nDESCRICAO := space(30)

      if ! empty(aHEXMA)
         for nCONT:= 1 to len(aHEXMA)
             nDESCRICAO := padr("DIF.HORAS EXT.MES ANTER.",30,".")
             iif(nFRACAO==0, nFRACAO:= aHEXMA[nCONT,5] ,)
             nVALOR += aHEXMA[nCONT,4]
         next

         @ prow()+1,0  say nDESCRICAO
         @ prow()  ,35 say transform(nFRACAO,"@R 999.99")
         @ prow()  ,55 say transform(nVALOR,"@R 9,999,999.99")
         nTOT_HORAS += nVALOR
      endif

      nFRACAO  := 0
      nVALOR   := 0
      nDESCRICAO := space(30)

      if ! empty(aPGVTR)
         for nCONT:= 1 to len(aPGVTR)
             nDESCRICAO := padr("DIF.VALE TRANSPORTE",30,".")
             iif(nFRACAO==0, nFRACAO:= aPGVTR[nCONT,5] ,)
             nVALOR += aPGVTR[nCONT,4]
         next

         @ prow()+1,0  say nDESCRICAO
         @ prow()  ,35 say transform(nFRACAO,"@R 999.99")
         @ prow()  ,55 say transform(nVALOR,"@R 9,999,999.99")
         nTOT_HORAS += nVALOR
      endif

      nFRACAO  := 0
      nVALOR   := 0
      nDESCRICAO := space(30)

      if ! empty(aAUXACI)
         for nCONT:= 1 to len(aAUXACI)
             nDESCRICAO := padr("AUXILIO ACIDENTE",30,".")
             iif(nFRACAO==0, nFRACAO:= aAUXACI[nCONT,5] ,)
             nVALOR += aAUXACI[nCONT,4]
         next

         @ prow()+1,0  say nDESCRICAO
         @ prow()  ,35 say transform(nFRACAO,"@R 999.99")
         @ prow()  ,55 say transform(nVALOR,"@R 9,999,999.99")
         nTOT_HORAS += nVALOR
      endif

      nFRACAO  := 0
      nVALOR   := 0
      nDESCRICAO := space(30)

      if ! empty(aPERICUL)
         for nCONT:= 1 to len(aPERICUL)
             nDESCRICAO := padr("PERICULOSIDADE",30,".")
             nFRACAO += aPERICUL[nCONT,5]
             nVALOR += aPERICUL[nCONT,4]
         next

         @ prow()+1,0  say nDESCRICAO
         @ prow()  ,35 say transform(nFRACAO,"@R 999.99")
         @ prow()  ,55 say transform(nVALOR,"@R 9,999,999.99")
         nTOT_HORAS += nVALOR
      endif


      nFRACAO  := 0
      nVALOR   := 0
      nDESCRICAO := space(30)

      if ! empty(aPDSR)
         for nCONT:= 1 to len(aPDSR)
             nDESCRICAO := padr("DESCANSO SEMANAL REMUNERADO",30,".")
             iif(nFRACAO==0, nFRACAO:= aPDSR[nCONT,5] ,)
             nVALOR += aPDSR[nCONT,4]
         next

         @ prow()+1,0  say nDESCRICAO
         @ prow()  ,35 say transform(nFRACAO,"@R 999.99")
         @ prow()  ,55 say transform(nVALOR,"@R 9,999,999.99")
         nTOT_HORAS += nVALOR
      endif

      nFRACAO  := 0
      nVALOR   := 0
      nDESCRICAO := space(30)

      if ! empty(aHE50)
         for nCONT:= 1 to len(aHE50)
             nDESCRICAO := padr("HORAS EXTRAS 50%",30,".")
             nFRACAO += aHE50[nCONT,5]
             nVALOR  += aHE50[nCONT,4]
         next

         @ prow()+1,0  say nDESCRICAO
         @ prow()  ,35 say transform(nFRACAO,"@R 999.99")
         @ prow()  ,55 say transform( (nVALOR+nHE50) ,"@R 9,999,999.99")
         nTOT_HORAS += ( nVALOR + nHE50 )
      endif

      nFRACAO  := 0
      nVALOR   := 0
      nDESCRICAO := space(30)

      if ! empty(aHE100)
         for nCONT:= 1 to len(aHE100)
             nDESCRICAO := padr("HORAS EXTRAS 100%",30,".")
             nFRACAO += aHE100[nCONT,5]
             nVALOR  += aHE100[nCONT,4]
         next

         @ prow()+1,0  say nDESCRICAO
         @ prow()  ,35 say transform(nFRACAO,"@R 999.99")
         @ prow()  ,55 say transform( (nVALOR+nHE100),"@R 9,999,999.99")
         nTOT_HORAS += ( nVALOR + nHE100 )
      endif

      nFRACAO  := 0
      nVALOR   := 0
      nDESCRICAO := space(30)

      if ! empty(aHRPRE)
         for nCONT:= 1 to len(aHRPRE)
             nDESCRICAO := padr("HORAS PREMIO",30,".")
             iif(nFRACAO==0, nFRACAO:= aHRPRE[nCONT,5] ,)
             nVALOR     += aHRPRE[nCONT,4]
         next

         @ prow()+1,0  say nDESCRICAO
         @ prow()  ,35 say transform(nFRACAO,"@R 999.99")
         @ prow()  ,55 say transform(nVALOR,"@R 9,999,999.99")
         nTOT_HORAS += nVALOR
      endif

      nFRACAO  := 0
      nVALOR   := 0
      nDESCRICAO := space(30)

      if ! empty(aAUXDO)
         for nCONT:= 1 to len(aAUXDO)
             nDESCRICAO := padr("AUXILIO DOENCA",30,".")
             iif(nFRACAO==0, nFRACAO:= aAUXDO[nCONT,5] ,)
             nVALOR += aAUXDO[nCONT,4]
         next

         @ prow()+1,0  say nDESCRICAO
         @ prow()  ,35 say transform(nFRACAO,"@R 999.99")
         @ prow()  ,55 say transform(nVALOR,"@R 9,999,999.99")
         nTOT_HORAS += nVALOR
      endif

      nFRACAO  := 0
      nVALOR   := 0
      nDESCRICAO := space(30)

      if ! empty(aSALFAM)
         for nCONT:= 1 to len(aSALFAM)
             nDESCRICAO := padr("SALARIO FAMILIA",30,".")
             nFRACAO    += aSALFAM[nCONT,5]
             nVALOR     += aSALFAM[nCONT,4]
         next

         @ prow()+1,0  say nDESCRICAO
         @ prow()  ,35 say transform(nFRACAO,"@R 999.99")
         @ prow()  ,42 say transform(nSALARIO,"@R 999,999.99")
         @ prow()  ,55 say transform(nVALOR,"@R 9,999,999.99")
         nTOT_HORAS += nVALOR
      endif

      nFRACAO  := 0
      nVALOR   := 0
      nDESCRICAO := space(30)

      if ! empty(aAUXFRA)
         for nCONT:= 1 to len(aAUXFRA)
             nDESCRICAO := padr("AUXILIO PATERNIDADE",30,".")
             nFRACAO    += aAUXFRA[nCONT,5]
             nVALOR     += aAUXFRA[nCONT,4]
         next

         @ prow()+1,0  say nDESCRICAO
         @ prow()  ,35 say transform(nFRACAO,"@R 999.99")
         @ prow()  ,42 say transform(nSALARIO,"@R 999,999.99")
         @ prow()  ,55 say transform(nVALOR,"@R 9,999,999.99")
         nTOT_HORAS += nVALOR
      endif

      nFRACAO  := 0
      nVALOR   := 0
      nDESCRICAO := space(30)

      if ! empty(aACIDEN)
         for nCONT:= 1 to len(aACIDEN)
             nDESCRICAO := padr("ACIDENTE DE TRABALHO",30,".")
             nFRACAO    += aACIDEN[nCONT,5]
             nVALOR     += aACIDEN[nCONT,4]
         next

         @ prow()+1,0  say nDESCRICAO
         @ prow()  ,35 say transform(nFRACAO,"@R 999.99")
         @ prow()  ,42 say transform(nSALARIO,"@R 999,999.99")
         @ prow()  ,55 say transform(nVALOR,"@R 9,999,999.99")
         nTOT_HORAS += nVALOR
      endif

      if ! empty(aSALSAL)
         for nCONT:= 1 to len(aSALSAL)
             nDESCRICAO := padr("SALDO SALARIO MES FERIAS",30,".")
             nFRACAO    += aSALSAL[nCONT,5]
             nVALOR     += aSALSAL[nCONT,4]
         next

         @ prow()+1,0  say nDESCRICAO
         @ prow()  ,35 say transform(nFRACAO,"@R 999.99")
         @ prow()  ,42 say transform(nSALARIO,"@R 999,999.99")
         @ prow()  ,55 say transform(nVALOR,"@R 9,999,999.99")
         nTOT_HORAS += nVALOR
      endif

      if ! empty(aDIFHE)
         for nCONT:= 1 to len(aDIFHE)
             nDESCRICAO := padr("DIF DE HORAS EXTRAS MES ANT.",30,".")
             nFRACAO    += aDIFHE[nCONT,5]
             nVALOR     += aDIFHE[nCONT,4]
         next

         @ prow()+1,0  say nDESCRICAO
         @ prow()  ,35 say transform(nFRACAO,"@R 999.99")
         @ prow()  ,42 say transform(nSALARIO,"@R 999,999.99")
         @ prow()  ,55 say transform(nVALOR,"@R 9,999,999.99")
         nTOT_HORAS += nVALOR
      endif

      if ! empty(aDIFSAL)
         for nCONT:= 1 to len(aDIFSAL)
             nDESCRICAO := padr("DIF. DE SAL.DISSIDIO MES ANT.",30,".")
             nFRACAO    += aDIFSAL[nCONT,5]
             nVALOR     += aDIFSAL[nCONT,4]
         next

         @ prow()+1,0  say nDESCRICAO
         @ prow()  ,35 say transform(nFRACAO,"@R 999.99")
         @ prow()  ,42 say transform(nSALARIO,"@R 999,999.99")
         @ prow()  ,55 say transform(nVALOR,"@R 9,999,999.99")
         nTOT_HORAS += nVALOR
      endif

      nFRACAO  := 0
      nVALOR   := 0
      nDESCRICAO := space(30)

      @ prow()+2,00 say padr("TOTAL DE HORAS TRABALHADAS",30,".")
      @ prow()  ,55 say transform(nTOT_HORAS,"@E 9,999,999.99")

      if ! empty(aMEDICAO)

         @ prow()+1,00 say XCOND0
         @ prow()+1,10 say XAENFAT + "MEDICAO" + XDENFAT
         @ prow()+2,00 say XCOND0 + "..........Descricao........... .....Qtde.. .Valor Unit... ...Total.."
         @ prow()+1,00 say ""

         for nCONT := 1 to len(aMEDICAO)
             @ prow()+1,0  say left(aMEDICAO[nCONT,3],30)
             @ prow()  ,35 say transform(aMEDICAO[nCONT,5],"@R 999.99")
             @ prow()  ,42 say transform((aMEDICAO[nCONT,4]/aMEDICAO[nCONT,5]),"@R 999,999.99")
             @ prow()  ,55 say transform(aMEDICAO[nCONT,4],"@R 9,999,999.99")
             nTOT_MEDICAO += aMEDICAO[nCONT,4]
         next

         @ prow()+2,00 say padr("TOTAL DAS MEDICOES",30,".")
         @ prow()  ,55 say transform(nTOT_MEDICAO,"@E 9,999,999.99")

      endif

      @ prow()+2,00 say padr("SUB-TOTAL DOS PROVENTOS",30,".")
      @ prow()  ,55 say transform(nTOT_HORAS+nTOT_MEDICAO,"@E 9,999,999.99")

      @ prow()+1,00 say XCOND0
      @ prow()+1,10 say XAEXPAN + "DESCONTOS" + XDEXPAN
      @ prow()+2,00 say XCOND0 + "..........Descricao........... .....Qtde.. .Valor Unit... ...Total.."
      @ prow()+1,00 say ""

      nFRACAO  := 0
      nVALOR   := 0
      nDESCRICAO := space(30)

      if ! empty(aTAXA)
         for nCONT:= 1 to len(aTAXA)
             nDESCRICAO := padr("TAXA ASSISTENCIAL",30,".")
             iif(nFRACAO==0, nFRACAO:= aTAXA[nCONT,5] ,)
             nVALOR += aTAXA[nCONT,4]
         next

         @ prow()+1,0  say nDESCRICAO
         @ prow()  ,35 say transform(nFRACAO,"@R 999.99")
         @ prow()  ,55 say transform(nVALOR,"@R 9,999,999.99")
         nTOT_DESC += nVALOR
      endif

      nFRACAO  := 0
      nVALOR   := 0
      nDESCRICAO := space(30)

      if ! empty(aTAREFA)
         for nCONT:= 1 to len(aTAREFA)
             nDESCRICAO := padr("HORAS DE TAREFA",30,".")
             iif(nFRACAO==0, nFRACAO:= aTAREFA[nCONT,5] ,)
             nVALOR += aTAREFA[nCONT,4]
         next

         @ prow()+1,0  say nDESCRICAO
         @ prow()  ,35 say transform(nFRACAO,"@R 999.99")
         @ prow()  ,55 say transform(nVALOR,"@R 9,999,999.99")
         nTOT_DESC += nVALOR
      endif

      nFRACAO  := 0
      nVALOR   := 0
      nDESCRICAO := space(30)

      if ! empty(aVALE)
         for nCONT:= 1 to len(aVALE)
             nDESCRICAO := padr("VALE TRANSPORTE",30,".")
             iif(nFRACAO==0, nFRACAO:= aVALE[nCONT,5] ,)
             nVALOR += aVALE[nCONT,4]
         next

         @ prow()+1,0  say nDESCRICAO
         @ prow()  ,35 say transform(nFRACAO,"@R 999.99")
         @ prow()  ,55 say transform(nVALOR,"@R 9,999,999.99")
         nTOT_DESC += nVALOR
      endif

      nFRACAO  := 0
      nVALOR   := 0
      nDESCRICAO := space(30)

      if ! empty(aDESVAL)
         for nCONT:= 1 to len(aDESVAL)
             nDESCRICAO := padr("DESCONTO DE VALES",30,".")
             iif(nFRACAO==0, nFRACAO:= aDESVAL[nCONT,5] ,)
             nVALOR += aDESVAL[nCONT,4]
         next

         @ prow()+1,0  say nDESCRICAO
         @ prow()  ,35 say transform(nFRACAO,"@R 999.99")
         @ prow()  ,55 say transform(nVALOR,"@R 9,999,999.99")
         nTOT_DESC += nVALOR
      endif

      nFRACAO  := 0
      nVALOR   := 0
      nDESCRICAO := space(30)

      if ! empty(aDESPRO)
         for nCONT:= 1 to len(aDESPRO)
             nDESCRICAO := padr("DESC. ADIANTAMENTO PRO-LABORE",30,".")
             iif(nFRACAO==0, nFRACAO:= aDESPRO[nCONT,5] ,)
             nVALOR += aDESPRO[nCONT,4]
         next

         @ prow()+1,0  say nDESCRICAO
         @ prow()  ,35 say transform(nFRACAO,"@R 999.99")
         @ prow()  ,55 say transform(nVALOR,"@R 9,999,999.99")
         nTOT_DESC += nVALOR
      endif

      nFRACAO  := 0
      nVALOR   := 0
      nDESCRICAO := space(30)

      if ! empty(aREFE)
         for nCONT:= 1 to len(aREFE)
             nDESCRICAO := padr("REFEICOES      ",30,".")
             iif(nFRACAO==0, nFRACAO:= aREFE[nCONT,5] ,)
             nVALOR += aREFE[nCONT,4]
         next

         @ prow()+1,0  say nDESCRICAO
         @ prow()  ,35 say transform(nFRACAO,"@R 999.99")
         @ prow()  ,55 say transform(nVALOR,"@R 9,999,999.99")
         nTOT_DESC += nVALOR
      endif

// INCLUSAO FEITA PELO LUCIANO EM FERIAS DA LUCINEIDE-----------------------------


      nFRACAO  := 0
      nVALOR   := 0
      nDESCRICAO := space(30)

      if ! empty(aREVSL)
         for nCONT:= 1 to len(aREVSL)
             nDESCRICAO := padr("REVERSAO SALARIAL",30,".")
             iif(nFRACAO==0, nFRACAO:= aREVSL[nCONT,5] ,)
             nVALOR += aREVSL[nCONT,4]
         next

         @ prow()+1,0  say nDESCRICAO
         @ prow()  ,35 say transform(nFRACAO,"@R 999.99")
         @ prow()  ,55 say transform(nVALOR,"@R 9,999,999.99")
         nTOT_DESC += nVALOR
      endif

      nFRACAO  := 0
      nVALOR   := 0
      nDESCRICAO := space(30)

      if ! empty(aPENAL)
         for nCONT:= 1 to len(aPENAL)
             nDESCRICAO := padr("PENSAO ALIMENTICIA",30,".")
             iif(nFRACAO==0, nFRACAO:= aPENAL[nCONT,5] ,)
             nVALOR += aPENAL[nCONT,4]
         next

         @ prow()+1,0  say nDESCRICAO
         @ prow()  ,35 say transform(nFRACAO,"@R 999.99")
         @ prow()  ,55 say transform(nVALOR,"@R 9,999,999.99")
         nTOT_DESC += nVALOR
      endif

      nFRACAO  := 0
      nVALOR   := 0
      nDESCRICAO := space(30)

      if ! empty(aDESFAR)
         for nCONT:= 1 to len(aDESFAR)
             nDESCRICAO := padr("DESCONTO DE FARMACIA",30,".")
             iif(nFRACAO==0, nFRACAO:= aDESFAR[nCONT,5] ,)
             nVALOR += aDESFAR[nCONT,4]
         next

         @ prow()+1,0  say nDESCRICAO
         @ prow()  ,35 say transform(nFRACAO,"@R 999.99")
         @ prow()  ,55 say transform(nVALOR,"@R 9,999,999.99")
         nTOT_DESC += nVALOR
      endif

// NOVAS INCLUSOES 427,615,327................
      nFRACAO  := 0
      nVALOR   := 0
      nDESCRICAO := space(30)

      if ! empty(aDESC1)
         for nCONT:= 1 to len(aDESC1)
             nDESCRICAO := padr("HORAS COMPENSADA MES ANTERIOR",30,".")
             iif(nFRACAO==0, nFRACAO:= aDESC1[nCONT,5] ,)
             nVALOR += aDESC1[nCONT,4]
         next

         @ prow()+1,0  say nDESCRICAO
         @ prow()  ,35 say transform(nFRACAO,"@R 999.99")
         @ prow()  ,55 say transform(nVALOR,"@R 9,999,999.99")
         nTOT_DESC += nVALOR
      endif

      nFRACAO  := 0
      nVALOR   := 0
      nDESCRICAO := space(30)

      if ! empty(aDESC2)
         for nCONT:= 1 to len(aDESC2)
             nDESCRICAO := padr("DESCONTOS DE ALUGUEL",30,".")
             iif(nFRACAO==0, nFRACAO:= aDESC2[nCONT,5] ,)
             nVALOR += aDESC2[nCONT,4]
         next

         @ prow()+1,0  say nDESCRICAO
         @ prow()  ,35 say transform(nFRACAO,"@R 999.99")
         @ prow()  ,55 say transform(nVALOR,"@R 9,999,999.99")
         nTOT_DESC += nVALOR
      endif

      nFRACAO  := 0
      nVALOR   := 0
      nDESCRICAO := space(30)

      if ! empty(aDESC3)
         for nCONT:= 1 to len(aDESC3)
             nDESCRICAO := padr("EQPTOS DE PROTECAO INDIVIDUAL",30,".")
             iif(nFRACAO==0, nFRACAO:= aDESC3[nCONT,5] ,)
             nVALOR += aDESC3[nCONT,4]
         next

         @ prow()+1,0  say nDESCRICAO
         @ prow()  ,35 say transform(nFRACAO,"@R 999.99")
         @ prow()  ,55 say transform(nVALOR,"@R 9,999,999.99")
         nTOT_DESC += nVALOR
      endif

// FINAL DE ALTERACOES EM DESCONTOS.................

      nFRACAO  := 0
      nVALOR   := 0
      nDESCRICAO := space(30)

      if ! empty(aDSR)
         for nCONT:= 1 to len(aDSR)
             nDESCRICAO := padr("DESCONTO DE DSR",30,".")
             iif(nFRACAO==0, nFRACAO:= aDSR[nCONT,5] , )
             nVALOR += aDSR[nCONT,4]
         next

         @ prow()+1,0  say nDESCRICAO
         @ prow()  ,35 say transform(nFRACAO,"@R 999.99")
         @ prow()  ,55 say transform(nVALOR,"@R 9,999,999.99")
         nTOT_DESC += nVALOR
      endif

      nFRACAO  := 0
      nVALOR   := 0
      nDESCRICAO := space(30)

      if ! empty(aFALTAS)
         for nCONT:= 1 to len(aFALTAS)
             nDESCRICAO := padr("FALTAS",30,".")
             nFRACAO += aFALTAS[nCONT,5]
             nVALOR += aFALTAS[nCONT,4]
         next

         @ prow()+1,0  say nDESCRICAO
         @ prow()  ,35 say transform(nFRACAO,"@R 999.99")
         @ prow()  ,42 say transform(nSALARIO,"@R 999,999.99")
         @ prow()  ,55 say transform(nVALOR,"@R 9,999,999.99")
         nTOT_DESC += nVALOR
      endif

      nFRACAO  := 0
      nVALOR   := 0
      nDESCRICAO := space(30)

      if ! empty(aINSS)
         for nCONT:= 1 to len(aINSS)
             nDESCRICAO := padr("I.N.S.S.",30,".")
             nFRACAO    += aINSS[nCONT,5]
             nVALOR     += aINSS[nCONT,4]
         next

         @ prow()+1,0  say nDESCRICAO
         @ prow()  ,35 say transform(nFRACAO,"@R 999.99")
         @ prow()  ,55 say transform(nVALOR,"@R 9,999,999.99")
         nTOT_DESC += nVALOR
      endif

      nFRACAO  := 0
      nVALOR   := 0
      nDESCRICAO := space(30)

      if ! empty(aADTO)
         for nCONT:= 1 to len(aADTO)
             nDESCRICAO := padr("DESC. ADIANTAMENTO DE SALARIO",30,".")
             nFRACAO    += aADTO[nCONT,5]
             nVALOR     += aADTO[nCONT,4]
         next

         @ prow()+1,0  say nDESCRICAO
         @ prow()  ,35 say transform(nFRACAO,"@R 999.99")
         @ prow()  ,55 say transform(nVALOR,"@R 9,999,999.99")
         nTOT_DESC += nVALOR
      endif

      nFRACAO  := 0
      nVALOR   := 0
      nDESCRICAO := space(30)

      if ! empty(aPADTO)
         for nCONT:= 1 to len(aPADTO)
             nDESCRICAO := padr("ADIANTAMENTO DE SALARIO",30,".")
             nFRACAO    += aPADTO[nCONT,5]
             nVALOR     += aPADTO[nCONT,4]
         next

         @ prow()+1,0  say nDESCRICAO
         @ prow()  ,35 say transform(nFRACAO,"@R 999.99")
         @ prow()  ,55 say transform(nVALOR,"@R 9,999,999.99")
         nTOT_DESC += nVALOR
      endif

      nFRACAO  := 0
      nVALOR   := 0
      nDESCRICAO := space(30)

      if ! empty(aIRRF)
         for nCONT:= 1 to len(aIRRF)
             nDESCRICAO := padr("I.R.R.F.",30,".")
             nFRACAO    += aIRRF[nCONT,5]
             nVALOR     += aIRRF[nCONT,4]
         next

         @ prow()+1,0  say nDESCRICAO
         @ prow()  ,35 say transform(nFRACAO,"@R 999.99")
         @ prow()  ,55 say transform(nVALOR,"@R 9,999,999.99")
         nTOT_DESC += nVALOR
      endif

      nFRACAO  := 0
      nVALOR   := 0
      nDESCRICAO := space(30)

      if ! empty(aSIND)
         for nCONT:= 1 to len(aSIND)
             nDESCRICAO := padr("CONTRIBUICAO SINDICAL",30,".")
             nFRACAO    += aSIND[nCONT,5]
             nVALOR     += aSIND[nCONT,4]
         next

         @ prow()+1,0  say nDESCRICAO
         @ prow()  ,35 say transform(nFRACAO,"@R 999.99")
         @ prow()  ,55 say transform(nVALOR,"@R 9,999,999.99")
         nTOT_DESC += nVALOR
      endif

      @ prow()+2,00 say padr("TOTAL DOS DESCONTOS",30,".")
      @ prow()  ,55 say transform(nTOT_DESC,"@E 9,999,999.99")

      @ prow()+2,00 say XAENFAT + padr("TOTAL LIQUIDO",30,".")
      @ prow()  ,55 say transform( ((nTOT_HORAS+nTOT_MEDICAO)-nTOT_DESC) ,"@E 9,999,999.99") + XDENFAT

      @ prow()+2,00 say XCOND1 + "Vistos:" + space(53) + "Recebi o Valor Constante nesta planilha em.: _____/_____/______"
      @ prow()+2,00 say "______________________    ________________________" + space(10) + "Assinatura do Funcionario: ____________________________________"
      @ prow()+1,00 say "     Superv.Obras              Administracao      "
      @ prow()+1,00 say XCOND0

      if prow() < nMAXLIN
         nMAXLIN := ( prow() - 1 )
      endif

      if cORDEM == "N"
         FUN->(Dbsetorder(1))
         FUN->(dbseek(nMATRICULA))  // procura a primeira matricula, e vai para a proxima
         FUN->(Dbsetorder(2))
      else
         FUN->(dbseek(nMATRICULA))  // procura a primeira matricula, e vai para a proxima
      endif

      FUN->(dbskip())

   enddo

   qstopprn()

return


//////////////////////////////////////////////////////////////////////////////
// FUNCAO UTILIZADA PARA ALIMENTAR VETORES DE EVENTOS _______________________
function i_lancs

   do while LANC->Matricula == FUN->Matricula .and. LANC->Anomes == XANOMES .and. LANC->Ambiente == cTIPOREL

      if LANC->Valor <> 0 .and. ! LANC->Evento $ "591_592_593_594_595_596"

         if EVENT->Finalidade $ "P+"

            if LANC->Evento $ "100*301*294"
               if ( nLIN := ascan ( aHORAS ,{ |x| x[1] == LANC->Evento } ) ) <> 0
                  aHORAS[nLIN,4] += LANC->Valor
                  aHORAS[nLIN,5] += LANC->Fracao
                  aHORAS[nLIN,6] += LANC->Valor/LANC->Fracao
               else
                  aadd ( aHORAS , {LANC->Evento,EVENT->Finalidade,left(EVENT->Descricao,30),LANC->Valor,LANC->Fracao,(LANC->Valor/LANC->Fracao)})
               endif
               if EVENT->Finalidade = "P"
                  nTOT_HORAS += LANC->Valor
               endif

            elseif LANC->Evento $ "101"
               if ( nLIN := ascan ( aSALSAL ,{ |x| x[1] == LANC->Evento } ) ) <> 0
                  aSALSAL[nLIN,4] += LANC->Valor
                  aSALSAL[nLIN,5] += LANC->Fracao
                  aSALSAL[nLIN,6] += LANC->Valor/LANC->Fracao
               else
                  aadd ( aSALSAL , {LANC->Evento,EVENT->Finalidade,left(EVENT->Descricao,30),LANC->Valor,LANC->Fracao,(LANC->Valor/LANC->Fracao)})
               endif
               if EVENT->Finalidade = "P"
                  nTOT_HORAS += LANC->Valor
               endif

            elseif LANC->Evento $ "178"
               if ( nLIN := ascan ( aDIFHE ,{ |x| x[1] == LANC->Evento } ) ) <> 0
                  aDIFHE[nLIN,4] += LANC->Valor
                  aDIFHE[nLIN,5] += LANC->Fracao
                  aDIFHE[nLIN,6] += LANC->Valor/LANC->Fracao
               else
                  aadd ( aDIFHE , {LANC->Evento,EVENT->Finalidade,left(EVENT->Descricao,30),LANC->Valor,LANC->Fracao,(LANC->Valor/LANC->Fracao)})
               endif
               if EVENT->Finalidade = "P"
                  nTOT_HORAS += LANC->Valor
               endif


            elseif LANC->Evento $ "995"
               if ( nLIN := ascan ( aDIFSAL ,{ |x| x[1] == LANC->Evento } ) ) <> 0
                  aDIFSAL[nLIN,4] += LANC->Valor
                  aDIFSAL[nLIN,5] += LANC->Fracao
                  aDIFSAL[nLIN,6] += LANC->Valor/LANC->Fracao
               else
                  aadd ( aDIFSAL , {LANC->Evento,EVENT->Finalidade,left(EVENT->Descricao,30),LANC->Valor,LANC->Fracao,(LANC->Valor/LANC->Fracao)})
               endif
               if EVENT->Finalidade = "P"
                  nTOT_HORAS += LANC->Valor
               endif

            elseif LANC->Evento $ "105"
               if ( nLIN := ascan ( aPROLAB ,{ |x| x[1] == LANC->Evento } ) ) <> 0
                  aPROLAB[nLIN,4] += LANC->Valor
                  aPROLAB[nLIN,5] += LANC->Fracao
                  aPROLAB[nLIN,6] += LANC->Valor/LANC->Fracao
               else
                  aadd ( aPROLAB , {LANC->Evento,EVENT->Finalidade,left(EVENT->Descricao,30),LANC->Valor,LANC->Fracao,(LANC->Valor/LANC->Fracao)})
               endif
               if EVENT->Finalidade = "P"
                  nTOT_HORAS += LANC->Valor
               endif

            elseif LANC->Evento $ "311*304"
               if ( nLIN := ascan ( aHE50 ,{ |x| x[1] == LANC->Evento } ) ) <> 0
                  aHE50[nLIN,4] += LANC->Valor
                  aHE50[nLIN,5] += LANC->Fracao
                  aHE50[nLIN,6] += LANC->Valor/LANC->Fracao
               else
                  aadd ( aHE50 , {LANC->Evento,EVENT->Finalidade,left(EVENT->Descricao,30),LANC->Valor,LANC->Fracao,(LANC->Valor/LANC->Fracao)})
               endif
               if EVENT->Finalidade = "P"
                  nTOT_HORAS += LANC->Valor
               endif

            elseif LANC->Evento $ "313*305"
               if ( nLIN := ascan ( aHE100 ,{ |x| x[1] == LANC->Evento } ) ) <> 0
                  aHE100[nLIN,4] += LANC->Valor
                  aHE100[nLIN,5] += LANC->Fracao
                  aHE100[nLIN,6] += LANC->Valor/LANC->Fracao
               else
                  aadd ( aHE100 , {LANC->Evento,EVENT->Finalidade,left(EVENT->Descricao,30),LANC->Valor,LANC->Fracao,(LANC->Valor/LANC->Fracao)})
               endif
               if EVENT->Finalidade = "P"
                  nTOT_HORAS += LANC->Valor
               endif

            elseif LANC->Evento $ "303"
               if ( nLIN := ascan ( aHRPRE ,{ |x| x[1] == LANC->Evento } ) ) <> 0
                  aHRPRE[nLIN,4] += LANC->Valor
                  aHRPRE[nLIN,5] += LANC->Fracao
                  aHRPRE[nLIN,6] += LANC->Valor/LANC->Fracao
               else
                  aadd ( aHRPRE, {LANC->Evento,EVENT->Finalidade,left(EVENT->Descricao,30),LANC->Valor,0,(LANC->Valor/LANC->Fracao)})
               endif
               if EVENT->Finalidade = "P"
                  nTOT_HORAS += LANC->Valor
               endif

            elseif LANC->Evento $ ("667*668*625*626*679*655*656*656*536*574*654*671*669*608*676*677*633*648*661*662*572*538*641*") .or. ;
                   LANC->Evento $ ("586*587*649*644*678*627*666*663*652*653*645*634*573*646*647*660*629*657*659*578*582*") .or. ;
                   LANC->Evento $ ("579*583*600*585*539*576*571*590*577*624*664*529*528*616*613*614*527*526*665*") .or. ;
                   LANC->Evento $ ("643*690*618*598*575*599*642*628*537*617*584*623")
               if ( nLIN := ascan ( aMEDICAO ,{ |x| x[1] == LANC->Evento } ) ) <> 0 //81
                  aMEDICAO[nLIN,4] += LANC->Valor
                  aMEDICAO[nLIN,5] += LANC->Fracao
                  aMEDICAO[nLIN,6] += LANC->Valor/LANC->Fracao
               else
                  aadd ( aMEDICAO, {LANC->Evento,EVENT->Finalidade,left(EVENT->Descricao,30),LANC->Valor,LANC->Fracao,(LANC->Valor/LANC->Fracao)})
               endif
               if EVENT->Finalidade = "P"
                  nTOT_MEDICAO += LANC->Valor
               endif

            elseif LANC->Evento $ "674*673"
               if ( nLIN := ascan ( aAUXDO ,{ |x| x[1] == LANC->Evento } ) ) <> 0
                  aAUXDO[nLIN,4] += LANC->Valor
                  aAUXDO[nLIN,5] += LANC->Fracao
                  aAUXDO[nLIN,6] += LANC->Valor/LANC->Fracao
               else
                  aadd ( aAUXDO, {LANC->Evento,EVENT->Finalidade,left(EVENT->Descricao,30),LANC->Valor,LANC->Fracao,(LANC->Valor/LANC->Fracao)})
               endif
               if EVENT->Finalidade = "P"
                  nTOT_HORAS += LANC->Valor
               endif

            elseif LANC->Evento $ "901*902"
               if ( nLIN := ascan ( aSALFAM ,{ |x| x[1] == LANC->Evento } ) ) <> 0
                  aSALFAM[nLIN,4] += LANC->Valor
                  aSALFAM[nLIN,5] += LANC->Fracao
                  aSALFAM[nLIN,6] += LANC->Valor/LANC->Fracao
               else
                  aadd ( aSALFAM, {LANC->Evento,EVENT->Finalidade,left(EVENT->Descricao,30),LANC->Valor,LANC->Fracao,(LANC->Valor/LANC->Fracao)})
               endif
               if EVENT->Finalidade = "P"
                  nTOT_HORAS += LANC->Valor
               endif

            elseif LANC->Evento $ "930"
               if ( nLIN := ascan ( aFGTS ,{ |x| x[1] == LANC->Evento } ) ) <> 0
                  aFGTS[nLIN,4] += LANC->Valor
                  aFGTS[nLIN,5] += LANC->Fracao
                  aFGTS[nLIN,6] += LANC->Valor/LANC->Fracao
               else
                  aadd ( aFGTS, {LANC->Evento,EVENT->Finalidade,left(EVENT->Descricao,30),LANC->Valor,LANC->Fracao,(LANC->Valor/LANC->Fracao)})
               endif

            elseif LANC->Evento $ "481"
               if ( nLIN := ascan ( aAUXFRA ,{ |x| x[1] == LANC->Evento } ) ) <> 0
                  aAUXFRA[nLIN,4] += LANC->Valor
                  aAUXFRA[nLIN,5] += LANC->Fracao
                  aAUXFRA[nLIN,6] += LANC->Valor/LANC->Fracao
               else
                  aadd ( aAUXFRA, {LANC->Evento,EVENT->Finalidade,left(EVENT->Descricao,30),LANC->Valor,LANC->Fracao,(LANC->Valor/LANC->Fracao)})
               endif
               if EVENT->Finalidade = "P"
                  nTOT_HORAS += LANC->Valor
               endif

            elseif LANC->Evento $ "104"
               if ( nLIN := ascan ( aACIDEN ,{ |x| x[1] == LANC->Evento } ) ) <> 0
                  aACIDEN[nLIN,4] += LANC->Valor
                  aACIDEN[nLIN,5] += LANC->Fracao
                  aACIDEN[nLIN,6] += LANC->Valor/LANC->Fracao
               else
                  aadd ( aACIDEN, {LANC->Evento,EVENT->Finalidade,left(EVENT->Descricao,30),LANC->Valor,LANC->Fracao,(LANC->Valor/LANC->Fracao)})
               endif
               if EVENT->Finalidade = "P"
                  nTOT_HORAS += LANC->Valor
               endif

            elseif LANC->Evento $ "701"
               if ( nLIN := ascan ( aPADTO ,{ |x| x[1] == LANC->Evento } ) ) <> 0
                  aPADTO[nLIN,4] += LANC->Valor
                  aPADTO[nLIN,5] += LANC->Fracao
                  aPADTO[nLIN,6] += LANC->Valor/LANC->Fracao
               else
                  aadd ( aPADTO , {LANC->Evento,EVENT->Finalidade,left(EVENT->Descricao,30),LANC->Valor,LANC->Fracao,(LANC->Valor/LANC->Fracao)})
               endif
               nTOT_HORAS += LANC->Valor

            elseif LANC->Evento $ "171*149"
               if ( nLIN := ascan ( aPDSR ,{ |x| x[1] == LANC->Evento } ) ) <> 0
                  aPDSR[nLIN,4] += LANC->Valor
                  aPDSR[nLIN,5] += LANC->Fracao
                  aPDSR[nLIN,6] += LANC->Valor/LANC->Fracao
               else
                  aadd ( aPDSR , {LANC->Evento,EVENT->Finalidade,left(EVENT->Descricao,30),LANC->Valor,LANC->Fracao,(LANC->Valor/LANC->Fracao)})
               endif
               nTOT_HORAS += LANC->Valor

            elseif LANC->Evento $ "120"
               if ( nLIN := ascan ( aDSMA ,{ |x| x[1] == LANC->Evento } ) ) <> 0
                  aDSMA[nLIN,4] += LANC->Valor
                  aDSMA[nLIN,5] += LANC->Fracao
                  aDSMA[nLIN,6] += LANC->Valor/LANC->Fracao
               else
                  aadd ( aDSMA , {LANC->Evento,EVENT->Finalidade,left(EVENT->Descricao,30),LANC->Valor,LANC->Fracao,(LANC->Valor/LANC->Fracao)})
               endif
               nTOT_HORAS += LANC->Valor

            elseif LANC->Evento $ "214"
               if ( nLIN := ascan ( aAUXACI ,{ |x| x[1] == LANC->Evento } ) ) <> 0
                  aAUXACI[nLIN,4] += LANC->Valor
                  aAUXACI[nLIN,5] += LANC->Fracao
                  aAUXACI[nLIN,6] += LANC->Valor/LANC->Fracao
               else
                  aadd ( aAUXACI , {LANC->Evento,EVENT->Finalidade,left(EVENT->Descricao,30),LANC->Valor,LANC->Fracao,(LANC->Valor/LANC->Fracao)})
               endif
               nTOT_HORAS += LANC->Valor

            elseif LANC->Evento $ "119"
               if ( nLIN := ascan ( aDIFSA ,{ |x| x[1] == LANC->Evento } ) ) <> 0
                  aDIFSA[nLIN,4] += LANC->Valor
                  aDIFSA[nLIN,5] += LANC->Fracao
                  aDIFSA[nLIN,6] += LANC->Valor/LANC->Fracao
               else
                  aadd ( aDIFSA , {LANC->Evento,EVENT->Finalidade,left(EVENT->Descricao,30),LANC->Valor,LANC->Fracao,(LANC->Valor/LANC->Fracao)})
               endif
               nTOT_HORAS += LANC->Valor

            elseif LANC->Evento $ "178"
               if ( nLIN := ascan ( aHEXMA ,{ |x| x[1] == LANC->Evento } ) ) <> 0
                  aHEXMA[nLIN,4] += LANC->Valor
                  aHEXMA[nLIN,5] += LANC->Fracao
                  aHEXMA[nLIN,6] += LANC->Valor/LANC->Fracao
               else
                  aadd ( aHEXMA , {LANC->Evento,EVENT->Finalidade,left(EVENT->Descricao,30),LANC->Valor,LANC->Fracao,(LANC->Valor/LANC->Fracao)})
               endif
               nTOT_HORAS += LANC->Valor

            elseif LANC->Evento $ "638"
               if ( nLIN := ascan ( aPGVTR ,{ |x| x[1] == LANC->Evento } ) ) <> 0
                  aPGVTR[nLIN,4] += LANC->Valor
                  aPGVTR[nLIN,5] += LANC->Fracao
                  aPGVTR[nLIN,6] += LANC->Valor/LANC->Fracao
               else
                  aadd ( aPGVTR , {LANC->Evento,EVENT->Finalidade,left(EVENT->Descricao,30),LANC->Valor,LANC->Fracao,(LANC->Valor/LANC->Fracao)})
               endif
               nTOT_HORAS += LANC->Valor

            elseif LANC->Evento $ "410"
               if ( nLIN := ascan ( aPERICUL ,{ |x| x[1] == LANC->Evento } ) ) <> 0
                  aPERICUL[nLIN,4] += LANC->Valor
                  aPERICUL[nLIN,5] += LANC->Fracao
                  aPERICUL[nLIN,6] += LANC->Valor/LANC->Fracao
               else
                  aadd ( aPERICUL , {LANC->Evento,EVENT->Finalidade,left(EVENT->Descricao,30),LANC->Valor,LANC->Fracao,(LANC->Valor/LANC->Fracao)})
               endif
               nTOT_HORAS += LANC->Valor

            elseif LANC->Evento $ "306"
                nHE50 += LANC->Valor
            elseif LANC->Evento $ "307"
                nHE100 += LANC->Valor
            endif

// soma eventos -------
         else
// descontos de proventos

            if LANC->Evento $ "228"
               if ( nLIN := ascan ( aTAXA ,{ |x| x[1] == LANC->Evento } ) ) <> 0
                  aTAXA[nLIN,4] += LANC->Valor
                  aTAXA[nLIN,5] += LANC->Fracao
                  aTAXA[nLIN,6] += LANC->Valor/LANC->Fracao
               else
                  aadd ( aTAXA, {LANC->Evento,EVENT->Finalidade,left(EVENT->Descricao,30),LANC->Valor,LANC->Fracao,(LANC->Valor/LANC->Fracao)})
               endif

               if EVENT->Finalidade = "D"
                  nTOT_DESC += LANC->Valor
               endif

            elseif LANC->Evento $ "221"
               if ( nLIN := ascan ( aTAREFA ,{ |x| x[1] == LANC->Evento } ) ) <> 0
                  aTAREFA[nLIN,4] += LANC->Valor
                  aTAREFA[nLIN,5] += LANC->Fracao
                  aTAREFA[nLIN,6] += LANC->Valor/LANC->Fracao
               else
                  aadd ( aTAREFA, {LANC->Evento,EVENT->Finalidade,left(EVENT->Descricao,30),LANC->Valor,LANC->Fracao,(LANC->Valor/LANC->Fracao)})
               endif

               if EVENT->Finalidade = "D"
                  nTOT_DESC += LANC->Valor
               endif

            elseif LANC->Evento $ "703"
               if ( nLIN := ascan ( aDESVAL ,{ |x| x[1] == LANC->Evento } ) ) <> 0
                  aDESVAL[nLIN,4] += LANC->Valor
                  aDESVAL[nLIN,5] += LANC->Fracao
                  aDESVAL[nLIN,6] += LANC->Valor/LANC->Fracao
               else
                  aadd ( aDESVAL, {LANC->Evento,EVENT->Finalidade,left(EVENT->Descricao,30),LANC->Valor,LANC->Fracao,(LANC->Valor/LANC->Fracao)})
               endif

               if EVENT->Finalidade = "D"
                  nTOT_DESC += LANC->Valor
               endif


            elseif LANC->Evento $ "581"
               if ( nLIN := ascan ( aDESPRO ,{ |x| x[1] == LANC->Evento } ) ) <> 0
                  aDESPRO[nLIN,4] += LANC->Valor
                  aDESPRO[nLIN,5] += LANC->Fracao
                  aDESPRO[nLIN,6] += LANC->Valor/LANC->Fracao
               else
                  aadd ( aDESPRO, {LANC->Evento,EVENT->Finalidade,left(EVENT->Descricao,30),LANC->Valor,LANC->Fracao,(LANC->Valor/LANC->Fracao)})
               endif

               if EVENT->Finalidade = "D"
                  nTOT_DESC += LANC->Valor
               endif

            elseif LANC->Evento $ "207"
               if ( nLIN := ascan ( aVALE ,{ |x| x[1] == LANC->Evento } ) ) <> 0
                  aVALE[nLIN,4] += LANC->Valor
                  aVALE[nLIN,5] += LANC->Fracao
                  aVALE[nLIN,6] += LANC->Valor/LANC->Fracao
               else
                  aadd ( aVALE , {LANC->Evento,EVENT->Finalidade,left(EVENT->Descricao,30),LANC->Valor,LANC->Fracao,(LANC->Valor/LANC->Fracao)})
               endif
               nTOT_DESC += LANC->Valor
//inclusao deita pelo luciano novos eventos...................

            elseif LANC->Evento $ "427"
               if ( nLIN := ascan ( aVALE ,{ |x| x[1] == LANC->Evento } ) ) <> 0
                  aDESC1[nLIN,4] += LANC->Valor
                  aDESC1[nLIN,5] += LANC->Fracao
                  aDESC1[nLIN,6] += LANC->Valor/LANC->Fracao
               else
                  aadd ( aDESC1, {LANC->Evento,EVENT->Finalidade,left(EVENT->Descricao,30),LANC->Valor,LANC->Fracao,(LANC->Valor/LANC->Fracao)})
               endif
               nTOT_DESC += LANC->Valor

            elseif LANC->Evento $ "615"
               if ( nLIN := ascan ( aVALE ,{ |x| x[1] == LANC->Evento } ) ) <> 0
                  aDESC2[nLIN,4] += LANC->Valor
                  aDESC2[nLIN,5] += LANC->Fracao
                  aDESC2[nLIN,6] += LANC->Valor/LANC->Fracao
               else
                  aadd ( aDESC2, {LANC->Evento,EVENT->Finalidade,left(EVENT->Descricao,30),LANC->Valor,LANC->Fracao,(LANC->Valor/LANC->Fracao)})
               endif
               nTOT_DESC += LANC->Valor

            elseif LANC->Evento $ "327"
               if ( nLIN := ascan ( aVALE ,{ |x| x[1] == LANC->Evento } ) ) <> 0
                  aDESC3[nLIN,4] += LANC->Valor
                  aDESC3[nLIN,5] += LANC->Fracao
                  aDESC3[nLIN,6] += LANC->Valor/LANC->Fracao
               else
                  aadd ( aDESC3, {LANC->Evento,EVENT->Finalidade,left(EVENT->Descricao,30),LANC->Valor,LANC->Fracao,(LANC->Valor/LANC->Fracao)})
               endif
               nTOT_DESC += LANC->Valor
//Finalizado aqui 427,615,327.................

            elseif LANC->Evento $ "635"
               if ( nLIN := ascan ( aREFE ,{ |x| x[1] == LANC->Evento } ) ) <> 0
                  aREFE[nLIN,4] += LANC->Valor
                  aREFE[nLIN,5] += LANC->Fracao
                  aREFE[nLIN,6] += LANC->Valor/LANC->Fracao
               else
                  aadd ( aREFE , {LANC->Evento,EVENT->Finalidade,left(EVENT->Descricao,30),LANC->Valor,LANC->Fracao,(LANC->Valor/LANC->Fracao)})
               endif
               nTOT_DESC += LANC->Valor


            elseif LANC->Evento $ "107"
               if ( nLIN := ascan ( aREVSL ,{ |x| x[1] == LANC->Evento } ) ) <> 0
                  aREVSL[nLIN,4] += LANC->Valor
                  aREVSL[nLIN,5] += LANC->Fracao
                  aREVSL[nLIN,6] += LANC->Valor/LANC->Fracao
               else
                  aadd ( aREVSL , {LANC->Evento,EVENT->Finalidade,left(EVENT->Descricao,30),LANC->Valor,LANC->Fracao,(LANC->Valor/LANC->Fracao)})
               endif
               nTOT_DESC += LANC->Valor

            elseif LANC->Evento $ "860"
               if ( nLIN := ascan ( aPENAL ,{ |x| x[1] == LANC->Evento } ) ) <> 0
                  aPENAL[nLIN,4] += LANC->Valor
                  aPENAL[nLIN,5] += LANC->Fracao
                  aPENAL[nLIN,6] += LANC->Valor/LANC->Fracao
               else
                  aadd ( aPENAL , {LANC->Evento,EVENT->Finalidade,left(EVENT->Descricao,30),LANC->Valor,LANC->Fracao,(LANC->Valor/LANC->Fracao)})
               endif
               nTOT_DESC += LANC->Valor

            elseif LANC->Evento $ "205"
               if ( nLIN := ascan ( aDESFAR ,{ |x| x[1] == LANC->Evento } ) ) <> 0
                  aDESFAR[nLIN,4] += LANC->Valor
                  aDESFAR[nLIN,5] += LANC->Fracao
                  aDESFAR[nLIN,6] += LANC->Valor/LANC->Fracao
               else
                  aadd ( aDESFAR , {LANC->Evento,EVENT->Finalidade,left(EVENT->Descricao,30),LANC->Valor,LANC->Fracao,(LANC->Valor/LANC->Fracao)})
               endif
               nTOT_DESC += LANC->Valor


            elseif LANC->Evento $ "220"
               if ( nLIN := ascan ( aDSR ,{ |x| x[1] == LANC->Evento } ) ) <> 0
                  aDSR[nLIN,4] += LANC->Valor
                  aDSR[nLIN,5] += LANC->Fracao / 2
                  aDSR[nLIN,6] += LANC->Valor/LANC->Fracao
               else
                  aadd ( aDSR , {LANC->Evento,EVENT->Finalidade,left(EVENT->Descricao,30),LANC->Valor,LANC->Fracao,(LANC->Valor/LANC->Fracao)})
               endif
               nTOT_DESC += LANC->Valor

            elseif LANC->Evento $ "222"
               if ( nLIN := ascan ( aFALTAS ,{ |x| x[1] == LANC->Evento } ) ) <> 0
                  aFALTAS[nLIN,4] += LANC->Valor
                  aFALTAS[nLIN,5] += LANC->Fracao / 2
                  aFALTAS[nLIN,6] += LANC->Valor/LANC->Fracao
               else
                  aadd ( aFALTAS , {LANC->Evento,EVENT->Finalidade,left(EVENT->Descricao,30),LANC->Valor,LANC->Fracao,(LANC->Valor/LANC->Fracao)})
               endif
               nTOT_DESC += LANC->Valor

            elseif LANC->Evento $ "910"
               if ( nLIN := ascan ( aINSS ,{ |x| x[1] == LANC->Evento } ) ) <> 0
                  aINSS[nLIN,4] += LANC->Valor
                  aINSS[nLIN,5] += LANC->Fracao
                  aINSS[nLIN,6] += LANC->Valor/LANC->Fracao
               else
                  aadd ( aINSS , {LANC->Evento,EVENT->Finalidade,left(EVENT->Descricao,30),LANC->Valor,LANC->Fracao,(LANC->Valor/LANC->Fracao)})
               endif
               nTOT_DESC += LANC->Valor

            elseif LANC->Evento $ "201"
               if ( nLIN := ascan ( aADTO ,{ |x| x[1] == LANC->Evento } ) ) <> 0
                  aADTO[nLIN,4] += LANC->Valor
                  aADTO[nLIN,5] += LANC->Fracao
                  aADTO[nLIN,6] += LANC->Valor/LANC->Fracao
               else
                  aadd ( aADTO , {LANC->Evento,EVENT->Finalidade,left(EVENT->Descricao,30),LANC->Valor,LANC->Fracao,(LANC->Valor/LANC->Fracao)})
               endif
               nTOT_DESC += LANC->Valor

            elseif LANC->Evento $ "920"
               if ( nLIN := ascan ( aIRRF ,{ |x| x[1] == LANC->Evento } ) ) <> 0
                  aIRRF[nLIN,4] += LANC->Valor
                  aIRRF[nLIN,5] += LANC->Fracao
                  aIRRF[nLIN,6] += LANC->Valor/LANC->Fracao
               else
                  aadd ( aIRRF , {LANC->Evento,EVENT->Finalidade,left(EVENT->Descricao,30),LANC->Valor,LANC->Fracao,(LANC->Valor/LANC->Fracao)})
               endif
               nTOT_DESC += LANC->Valor

            elseif LANC->Evento $ "230"
               if ( nLIN := ascan ( aSIND ,{ |x| x[1] == LANC->Evento } ) ) <> 0
                  aSIND[nLIN,4] += LANC->Valor
                  aSIND[nLIN,5] += LANC->Fracao
                  aSIND[nLIN,6] += LANC->Valor/LANC->Fracao
               else
                  aadd ( aSIND , {LANC->Evento,EVENT->Finalidade,left(EVENT->Descricao,30),LANC->Valor,LANC->Fracao,(LANC->Valor/LANC->Fracao)})
               endif
               nTOT_DESC += LANC->Valor
            endif

         endif

      endif

      LANC->(dbskip())

   enddo

return
