/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: RECURSOS HUMANOS
// OBJETIVO...: EMISSAO DO DEMONSTRATIVO DA FOLHA DE PAGAMENTO (002)
// ANALISTA...: LUCINEIDE VILAR POSSEBOM
// PROGRAMADOR: A MESMA
// INICIO.....: MARCO DE 1998
// OBS........:
// ALTERACOES.:

// RELATORIO DA FOLHA DE PAGAMENTO

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG .or. lastkey()==27) }

private sBLOCO1 := qlbloc("B560A","QBLOC.GLO") // bloco basico
private sBLOCO2 := qlbloc("B560B","QBLOC.GLO") // ambiente escolhido
private sBLOCO3 := qlbloc("B560C","QBLOC.GLO") // ordem de impressao

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

private nPROV2_MS  := 0        // somatorio das bases da empresa 002
private nPROV2_AD  := 0
private nPROV2_FR  := 0
private nPROV2_DT  := 0

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qesco(-1,0,@cTIPOREL ,sBLOCO2)}       , "TIPOREL"  })
aadd(aEDICAO,{{ || qesco(-1,0,@cORDEM   ,sBLOCO3)}       , "ORDEM"    })
aadd(aEDICAO,{{ || view_fun(-1,0,@cMATRICULA ,"999999")} , "MATRICULA"})
aadd(aEDICAO,{{ || NIL },NIL}) // nome do funcionario

do while .T.

   qlbloc(5,0,"B560A","QBLOC.GLO")
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
      qmensa("Este relat�rio deve ser impresso dentro da empresa 002","B")
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
           qrsay(XNIVEL,qabrev(cTIPOREL,"MADF",{"M�s Corrente","Adiantamento","D�cimo Terceiro","F�rias"}))
      case cCAMPO == "ORDEM"
           if empty(cORDEM) ; return .F. ; endif
           qrsay(XNIVEL,qabrev(cORDEM,"MN",{"Matr�cula","Nome"}))
      case cCAMPO == "MATRICULA"
           if empty(cMATRICULA)
              qrsay(XNIVEL++,"Todas as Matriculas...")
           else
              if ! FUN->(dbseek(cMATRICULA:=strzero(val(cMATRICULA),6)))
                 qmensa("Matricula n�o Encontrada...","B")
                 return .F.
              else
                 qrsay(XNIVEL++,left(FUN->Nome,30))
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

//    if FUN->Situacao == "H" .and. SITUA->Af_ini < qinimes(XDATASYS)
//       FUN->(dbskip())
//       loop
//    endif
//
//    if FUN->Data_adm > qfimmes(XDATASYS)
//       FUN->(dbskip())
//       loop
//    endif
         
      if ! qlineprn() ; return ; endif

      SITUA->(dbSetFilter({|| Anomes == XANOMES},"Anomes == XANOMES"))
      LANC->(dbSetRelation("EVENT",{|| Evento},"Evento"))
      FUN->(dbSetRelation("BASE",{|| Matricula+XANOMES},"Matricula+XANOMES"))
      SITUA->(dbSetRelation("CARGO",{|| Cargo},"Cargo"))
      FUN->(dbSetRelation("LANC",{|| XANOMES+Matricula+cTIPOREL},"XANOMES+Matricula+cTIPOREL"))

      if XPAGINA == 0 .or. prow() > nMAXLIN
         qpageprn()
         @ prow(),00    say XCOND0
         qcabecprn(cTITULO,80)
         @ prow()+1,00  say "FUNCIONARIO : " + left(FUN->Nome,50)
         @ prow()  ,60  say "MATRICULA   : " + FUN->Matricula ; SITUA->(Dbseek(FUN->Matricula)) ; CARGO->(Dbseek(SITUA->Cargo))
         @ prow()+1,00  say "FUNCAO      : " + CARGO->Descricao
      endif

      aPROV    := {}
      aDESC    := {}
      aEVENTOS := {}
      aORDEM   := {}
      nTOT_PROV  := 0
      nTOT_DESC  := 0

      do while LANC->Matricula == FUN->Matricula .and. LANC->Anomes == XANOMES .and. LANC->Ambiente == cTIPOREL

         if LANC->Valor <> 0 .and. ! LANC->Evento $ "591_592_593_594_595_596"
            if EVENT->Finalidade $ "P+"
               aadd ( aPROV , {LANC->Evento,EVENT->Finalidade,left(EVENT->Descricao,30),LANC->Valor,LANC->Fracao,(LANC->Valor/LANC->Fracao)})
               if EVENT->Finalidade = "P"
                  nTOT_PROV += LANC->Valor
               endif
            else
               aadd ( aDESC , {LANC->Evento,EVENT->Finalidade,left(EVENT->Descricao,30),LANC->Valor,LANC->Fracao,(LANC->Valor/LANC->Fracao)})
               nTOT_DESC += LANC->Valor
            endif
         endif

         LANC->(dbskip())

      enddo

      do case
         case cTIPOREL == "MS"
           nPROV1_MS += ( BASE->Prov_ms - BASE->Desc_ms )
         case cTIPOREL == "AD"
           nPROV1_AD += ( BASE->Prov_ad - BASE->Desc_ad )
         case cTIPOREL == "DT"
           nPROV1_DT += ( BASE->Prov_dt - BASE->Desc_dt )
         case cTIPOREL == "FR"
           nPROV1_FR += ( BASE->Prov_fr - BASE->Desc_fr )
      endcase

      nMATRICULA := FUN->Matricula

      nREC_FUN := FUN->(recno())
      nREC_LAN := LANC->(recno())

      FUN->(Dbclosearea())
      LANC->(Dbclosearea())
      SITUA->(Dbclosearea())
      BASE->(Dbclosearea())

      if ! quse("\QSYS_G\QRH\E001\","FUN",{"FU_MATRI","FU_NOME","FU_FDMAT","FU_FDNOM","FU_FILMA","FU_FILNO","FU_CENMA","FU_CENNO","FU_MTASS","FU_MTASS","FU_GRPS"})
         qmensa("N�o foi poss�vel abrir arquivo FUN.DBF na empresa 001 !! Tente novamente.")
         return .F.
      endif

      if ! quse("\QSYS_G\QRH\E001\","LANC",{"LA_MATRI","LA_EVENT","LA_MAEVE"})
         qmensa("N�o foi poss�vel abrir arquivo LANC.DBF da empresa 001 !! Tente novamente.")
         return .F.
      endif

      if ! quse("\QSYS_G\QRH\E001\","SITUA",{"SI_MATRI","SI_MAAUM"})
         qmensa("N�o foi poss�vel abrir arquivo SITUA.DBF da empresa 001 !! Tente novamente.")
         return .F.
      endif

      if ! quse("\QSYS_G\QRH\E001\","BASE",{"BA_MATRI"})
         qmensa("N�o foi poss�vel abrir arquivo BASE.DBF da empresa 001 !! Tente novamente.")
         return .F.
      endif

      SITUA->(dbSetFilter({|| Anomes == XANOMES},"Anomes == XANOMES"))
      LANC->(dbSetRelation("EVENT",{|| Evento},"Evento"))
      FUN->(dbSetRelation("BASE",{|| Matricula+XANOMES},"Matricula+XANOMES"))
      SITUA->(dbSetRelation("CARGO",{|| Cargo},"Cargo"))
      FUN->(dbSetRelation("LANC",{|| XANOMES+Matricula+cTIPOREL},"XANOMES+Matricula+cTIPOREL"))

//    do case
//       case cORDEM == "M" ; FUN->(dbsetorder(01)) // matricula
//       case cORDEM == "N" ; FUN->(dbsetorder(02)) // nome
//    endcase

      FUN->(Dbgotop())

      if FUN->(dbseek(nMATRICULA))

         if cORDEM == "N"
            FUN->(Dbsetorder(2))
         endif

         do while LANC->Matricula == FUN->Matricula .and. LANC->Anomes == XANOMES .and. LANC->Ambiente == cTIPOREL

            if LANC->Valor <> 0 .and. ! LANC->Evento $ "591_592_593_594_595_596"
               if EVENT->Finalidade $ "P+"
                  aadd ( aPROV , {LANC->Evento,EVENT->Finalidade,left(EVENT->Descricao,30),LANC->Valor,LANC->Fracao,(LANC->Valor/LANC->Fracao)} )
                  if EVENT->Finalidade = "P"
                     nTOT_PROV += LANC->Valor
                  endif
               else
                  aadd ( aDESC , {LANC->Evento,EVENT->Finalidade,left(EVENT->Descricao,30),LANC->Valor,LANC->Fracao,(LANC->Valor/LANC->Fracao)} )
                  nTOT_DESC += LANC->Valor
               endif
            endif

            LANC->(dbskip())

         enddo

         do case
            case cTIPOREL == "MS"
              nPROV2_MS += ( BASE->Prov_ms - BASE->Desc_ms )
            case cTIPOREL == "AD"
              nPROV2_AD += ( BASE->Prov_ad - BASE->Desc_ad )
            case cTIPOREL == "DT"
              nPROV2_DT += ( BASE->Prov_dt - BASE->Desc_dt )
            case cTIPOREL == "FR"
              nPROV2_FR += ( BASE->Prov_fr - BASE->Desc_fr )
         endcase

      endif

      FUN->(Dbclosearea())
      LANC->(Dbclosearea())
      SITUA->(Dbclosearea())
      BASE->(Dbclosearea())

      if ! quse("\QSYS_G\QRH\E002\","FUN",{"FU_MATRI","FU_NOME","FU_FDMAT","FU_FDNOM","FU_FILMA","FU_FILNO","FU_CENMA","FU_CENNO","FU_MTASS","FU_MTASS","FU_GRPS"})
         qmensa("N�o foi poss�vel abrir arquivo FUN.DBF na empresa 002 !! Tente novamente.")
         return .F.
      endif

      if ! quse("\QSYS_G\QRH\E002\","LANC",{"LA_MATRI","LA_EVENT","LA_MAEVE"})
         qmensa("N�o foi poss�vel abrir arquivo LANC.DBF da empresa 002 !! Tente novamente.")
         return .F.
      endif

      if ! quse("\QSYS_G\QRH\E002\","SITUA",{"SI_MATRI","SI_MAAUM"})
         qmensa("N�o foi poss�vel abrir arquivo SITUA.DBF da empresa 002 !! Tente novamente.")
         return .F.
      endif

      if ! quse("\QSYS_G\QRH\E002\","BASE",{"BA_MATRI"})
         qmensa("N�o foi poss�vel abrir arquivo BASE.DBF da empresa 002 !! Tente novamente.")
         return .F.
      endif

      @ prow()+1,00 say XCOND0
      @ prow()+1,30 say XAEXPAN + "PROVENTOS" + XDEXPAN
      @ prow()+1,00 say ""

      aEVENTOS := array(len(aPROV))
      aORDEM   := {}

      // JUNTA TODOS OS ELEMENTOS PARA FORMAR UMA LINHA ________________________

      for nCONT := 1 to len(aPROV)
          aEVENTOS[nCONT] := aPROV[nCONT,1] + " "
          aEVENTOS[nCONT] += aPROV[nCONT,2] + " "
          aEVENTOS[nCONT] += aPROV[nCONT,3] + "   "
          aEVENTOS[nCONT] += transform(aPROV[nCONT,4],"@E 9,999,999.99") + " "
          if aPROV[nCONT,5] == 0
             aEVENTOS[nCONT] += space(9)
          else
             aEVENTOS[nCONT] += "(" + transform(aPROV[nCONT,5],"@E 999.99") + ") "
          endif
          if ! aPROV[nCONT,1] $ "633*572*577*579*571*643*207*910*930*701"
             aEVENTOS[nCONT] += transform(aPROV[nCONT,6],"@E 999.99")
          else
             aEVENTOS[nCONT] += "0.00"
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
          @ prow()+1,0 say XCOND1 + aORDEM[nCONT] + " | " + aORDEM[nCONT+nMETADE] + XCOND0
      next

      @ prow()+2,20 say "TOTAL DOS PROVENTOS...: " + transform(nTOT_PROV,"@E 9,999,999.99")

      @ prow()+1,0 say space(1)

      @ prow()+2,30 say XAEXPAN + "DESCONTOS" + XDEXPAN
      @ prow()+1,00 say ""

      aEVENTOS := {}
      aEVENTOS := array(len(aDESC))
      aORDEM   := {}

      // JUNTA TODOS OS ELEMENTOS PARA FORMAR UMA LINHA ________________________

      for nCONT := 1 to len(aDESC)
          aEVENTOS[nCONT] := aDESC[nCONT,1] + " "
          aEVENTOS[nCONT] += aDESC[nCONT,2] + " "
          aEVENTOS[nCONT] += aDESC[nCONT,3] + "   "
          aEVENTOS[nCONT] += transform(aDESC[nCONT,4],"@E 9,999,999.99") + " "
          if aDESC[nCONT,5] == 0
             aEVENTOS[nCONT] += space(9)
          else
             aEVENTOS[nCONT] += "(" + transform(aDESC[nCONT,5],"@E 999.99") + ") "
          endif
          if ! aDESC[nCONT,1] $ "633*572*577*579*571*643*207*910*930*701"
             aEVENTOS[nCONT] += transform(aDESC[nCONT,6],"@E 999.99")
          else
             aEVENTOS[nCONT] += "0.00"
          endif
      next

      nMETADE := len(aORDEM) / 2

      if int(nMETADE) != nMETADE        // entao e' impar
         aadd(aORDEM,space(60))
      endif

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

      for nCONT := 1 to nMETADE
          @ prow()+1,0 say  XCOND1 + aORDEM[nCONT] + " | " + aORDEM[nCONT+nMETADE] + XCOND0
      next

      @ prow()+2,20 say "TOTAL DOS DESCONTOS...: " + transform(nTOT_DESC,"@E 9,999,999.99")

      @ prow()+1,0 say space(1)

      if prow() < nMAXLIN
         nMAXLIN := prow()
      endif

      @ prow()+1,20 say "LIQUIDO A RECEBER.....: " + transform(nTOT_PROV-nTOT_DESC,"@E 9,999,999.99")

      @ prow()+1,00 say XCOND0
      @ prow()+1,20 say XAEXPAN + "FORMA DE PAGAMENTO" + XDEXPAN

      @ prow()+2,10 say "RECIBO DE AJUDA DE CUSTO "

      do case
         case cTIPOREL == "MS"
           @ prow() ,40 say  transform(nPROV1_MS,"@R 9,999,999.99")
         case cTIPOREL == "AD"
           @ prow() ,40 say  transform(nPROV1_AD,"@R 9,999,999.99")
         case cTIPOREL == "DT"
           @ prow() ,40 say  transform(nPROV1_DT,"@R 9,999,999.99")
         case cTIPOREL == "FR"
           @ prow() ,40 say  transform(nPROV1_FR,"@R 9,999,999.99")
         otherwise
           @ prow() ,40 say  "        0.00"
      endcase

      @ prow()+2,10 say "RECIBO DE PGTO DE SALARIO"

      do case
         case cTIPOREL == "MS"
           @ prow() ,40 say  transform(nPROV2_MS,"@R 9,999,999.99")
         case cTIPOREL == "AD"
           @ prow() ,40 say  transform(nPROV2_AD,"@R 9,999,999.99")
         case cTIPOREL == "DT"
           @ prow() ,40 say  transform(nPROV2_DT,"@R 9,999,999.99")
         case cTIPOREL == "FR"
           @ prow() ,40 say  transform(nPROV2_FR,"@R 9,999,999.99")
         otherwise
           @ prow() ,40 say  "        0.00"
      endcase

      do case
         case cTIPOREL == "MS"
           nPROV_TOT := nPROV2_MS + nPROV1_MS
         case cTIPOREL == "AD"
           nPROV_TOT := nPROV2_AD + nPROV1_AD
         case cTIPOREL == "DT"
           nPROV_TOT := nPROV2_DT + nPROV1_DT
         case cTIPOREL == "FR"
           nPROV_TOT := nPROV2_FR + nPROV1_FR
      endcase

      @ prow()+3,00 say replicate("*",80)
      @ prow()+2,20 say XAENFAT + "RECIBO" + XDENFAT
      @ prow()  ,60 say "R$ (" + transform(nPROV_TOT,"@R 9,999,999.99") + ")"
      @ prow()+3,15 say "Recebi(emos) de TECNOCRUZ Construcoes e Empreendimentos Ltda, a"
      @ prow()+1,10 say "quantia acima de (" + XCOND1 + qextenso(nPROV_TOT) +XCOND0 + ")."
      @ prow()+1,10 say "Correspondente ao valor total desta medicao, referente aos  servicos"
      @ prow()+1,10 say "acima discriminados."
      @ prow()+2,05 say "Data:  _____/_____/_____       Ass.Empr.:_______________________________"
      @ prow()+2,05 say "Ass.Empregado.: ___________________________________"

      nPROV1_MS  := 0        // somatorio das bases da empresa 001
      nPROV1_AD  := 0
      nPROV1_FR  := 0
      nPROV1_DT  := 0

      nPROV2_MS  := 0        // somatorio das bases da empresa 002
      nPROV2_AD  := 0
      nPROV2_FR  := 0
      nPROV2_DT  := 0

      aPROV    := {}
      aDESC    := {}
      aEVENTOS := {}
      aORDEM   := {}
      nTOT_PROV  := 0
      nTOT_DESC  := 0

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
