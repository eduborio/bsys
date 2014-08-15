/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: RECURSOS HUMANOS
// OBJETIVO...: EMISSAO DO TOTAL GERAL DA FOLHA DE PAGAMENTO (002)
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

private cTIPOREL               // tipo de relatorio (mensal ou 13o.)
private cTITULO                // titulo do relatorio
private cMATRICULA:=space(6)   // matricula do funcionario
private cORDEM    := "M"       // ordem de impressao (matricula/nome)
private aEDICAO   := {}        // vetor para os campos de entrada de dados
private aPROV     := {}        // vetor para os eventos de provento
private aDESC     := {}        // vetor para os eventos de desconto
private aTOT_P    := {}        // vetor totalizador para os eventos de provento
private aTOT_D    := {}        // vetor totalizador para os eventos de desconto
private nPROVENTOS:= 0         // totalizador para os proventos
private nDESCONTOS:= 0         // totalizador para os descontos
private aEVENTOS  := {}        // vetor para os eventos

private aDADO_P
private aDADO_D
private aNOVO      := {}
private nLIN       := 0
private lLIN       := .T.

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qesco(-1,0,@cTIPOREL ,sBLOCO2)} , "TIPOREL"  })
aadd(aEDICAO,{{ || qesco(-1,0,@cORDEM   ,sBLOCO3)} , "ORDEM"    })
aadd(aEDICAO,{{ || view_fun(-1,0,@cMATRICULA ,"999999")} , "MATRICULA"})
aadd(aEDICAO,{{ || NIL },NIL}) // nome do funcionario

do while .T.

   qlbloc(5,0,"B561A","QBLOC.GLO")
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
                 if FUN->Situacao <> "T"
                    qmensa("Funcion rio n„o est  trabalhando...","B")
                    return .F.
                 endif
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
         exit
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

      if XPAGINA == 0 .or. prow() > nMAXLIN
         qpageprn()
         @ prow(),00    say XCOND0
         qcabecprn(cTITULO,80)
         @ prow()+1,00  say "FUNCIONARIO : " + left(FUN->Nome,50)
         @ prow()  ,60  say "MATRICULA   : " + FUN->Matricula ; SITUA->(Dbseek(FUN->Matricula)) ; CARGO->(Dbseek(SITUA->Cargo))
         @ prow()+1,00  say "FUNCAO      : " + CARGO->Descricao
      else
         @ prow()+1,00  say replicate("*",80)
         @ prow()+1,00  say "FUNCIONARIO : " + left(FUN->Nome,50)
         @ prow()  ,60  say "MATRICULA   : " + FUN->Matricula ; SITUA->(Dbseek(FUN->Matricula)) ; CARGO->(Dbseek(SITUA->Cargo))
         @ prow()+1,00  say "FUNCAO      : " + CARGO->Descricao
      endif

      aPROV      := {}
      aDESC      := {}
      aEVENTOS   := {}
      aORDEM     := {}
      nTOT_PROV  := 0
      nTOT_DESC  := 0

      do while LANC->Matricula == FUN->Matricula .and. LANC->Anomes == XANOMES .and. LANC->Ambiente == cTIPOREL

         if LANC->Valor <> 0 .and. ! LANC->Evento $ "591_592_593_594_595_596"
            if EVENT->Finalidade $ "P+"

               aadd ( aPROV , {LANC->Evento,EVENT->Finalidade,left(EVENT->Descricao,30),LANC->Valor,LANC->Fracao,(LANC->Valor/LANC->Fracao)})

               if len(aNOVO) == 0
                  aadd ( aNOVO , {LANC->Evento,EVENT->Finalidade,left(EVENT->Descricao,30),LANC->Valor,LANC->Fracao,(LANC->Valor/LANC->Fracao)})
               else
                  if ( nLIN := ascan ( aNOVO ,{ |x| x[1] == LANC->Evento } ) ) <> 0
                     aNOVO[nLIN,4] += LANC->Valor
                  else
                     aadd ( aNOVO , {LANC->Evento,EVENT->Finalidade,left(EVENT->Descricao,30),LANC->Valor,LANC->Fracao,(LANC->Valor/LANC->Fracao)})
                  endif
               endif

               if EVENT->Finalidade = "P"
                  nTOT_PROV += LANC->Valor
               endif
            else
               aadd ( aDESC , {LANC->Evento,EVENT->Finalidade,left(EVENT->Descricao,30),LANC->Valor,LANC->Fracao,(LANC->Valor/LANC->Fracao)})

               if len(aNOVO) == 0
                  aadd ( aNOVO , {LANC->Evento,EVENT->Finalidade,left(EVENT->Descricao,30),LANC->Valor,LANC->Fracao,(LANC->Valor/LANC->Fracao)})
               else
                  if ( nLIN := ascan ( aNOVO ,{ |x| x[1] == LANC->Evento } ) ) <> 0
                     aNOVO[nLIN,4] += LANC->Valor
                  else
                     aadd ( aNOVO , {LANC->Evento,EVENT->Finalidade,left(EVENT->Descricao,30),LANC->Valor,LANC->Fracao,(LANC->Valor/LANC->Fracao)})
                  endif
               endif

               nTOT_DESC += LANC->Valor

            endif
         endif

         LANC->(dbskip())

      enddo

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

                  if len(aNOVO) == 0
                     aadd ( aNOVO , {LANC->Evento,EVENT->Finalidade,left(EVENT->Descricao,30),LANC->Valor,LANC->Fracao,(LANC->Valor/LANC->Fracao)})
                  else
                     if ( nLIN := ascan ( aNOVO ,{ |x| x[1] == LANC->Evento } ) ) <> 0
                        aNOVO[nLIN,4] += LANC->Valor
                     else
                        aadd ( aNOVO , {LANC->Evento,EVENT->Finalidade,left(EVENT->Descricao,30),LANC->Valor,LANC->Fracao,(LANC->Valor/LANC->Fracao)})
                     endif
                  endif

                  if EVENT->Finalidade = "P"
                     nTOT_PROV += LANC->Valor
                  endif
               else
                  aadd ( aDESC , {LANC->Evento,EVENT->Finalidade,left(EVENT->Descricao,30),LANC->Valor,LANC->Fracao,(LANC->Valor/LANC->Fracao)} )
                  nTOT_DESC += LANC->Valor

                  if len(aNOVO) == 0
                     aadd ( aNOVO , {LANC->Evento,EVENT->Finalidade,left(EVENT->Descricao,30),LANC->Valor,LANC->Fracao,(LANC->Valor/LANC->Fracao)})
                  else
                     if ( nLIN := ascan ( aNOVO ,{ |x| x[1] == LANC->Evento } ) ) <> 0
                        aNOVO[nLIN,4] += LANC->Valor
                     else
                        aadd ( aNOVO , {LANC->Evento,EVENT->Finalidade,left(EVENT->Descricao,30),LANC->Valor,LANC->Fracao,(LANC->Valor/LANC->Fracao)})
                     endif
                  endif

               endif
            endif

            LANC->(dbskip())

         enddo

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
             aEVENTOS[nCONT] += "  0.00"
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
             aEVENTOS[nCONT] += "  0.00"
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

      @ prow()+1,00  say replicate("*",80)

      @ prow()+2,10 say "TOTAL DOS PROVENTOS...: " + transform(nTOT_PROV,"@E 9,999,999.99")
      @ prow()+1,10 say "TOTAL DOS DESCONTOS...: " + transform(nTOT_DESC,"@E 9,999,999.99")

      @ prow()+2,10 say "LIQUIDO A RECEBER.....: " + transform(nTOT_PROV-nTOT_DESC,"@E 9,999,999.99")

      if cORDEM == "N"
         FUN->(Dbsetorder(1))
         FUN->(dbseek(nMATRICULA))  // procura a primeira matricula, e vai para a proxima
         FUN->(Dbsetorder(2))
      else
         FUN->(dbseek(nMATRICULA))  // procura a primeira matricula, e vai para a proxima
      endif

      FUN->(dbskip())

      aPROV    := {}
      aDESC    := {}
      aEVENTOS := {}
      aORDEM   := {}
      nTOT_PROV  := 0
      nTOT_DESC  := 0

   enddo

   // IMPRIME O TOTAL GERAL DA EMPRESA ___________________________________________

   cTITULO := "TOTAL GERAL DA EMPRESA"
   qpageprn()
   @ prow(),00    say XCOND0
   qcabecprn(cTITULO,80)

   aEVENTOS := array(len(aNOVO))

   for nCONT := 1 to len(aNOVO)
       aEVENTOS[nCONT] := aNOVO[nCONT,1] + " "
       aEVENTOS[nCONT] += aNOVO[nCONT,2] + " "
       aEVENTOS[nCONT] += aNOVO[nCONT,3] + "   "
       aEVENTOS[nCONT] += transform(aNOVO[nCONT,4],"@E 9,999,999.99") + " "
       if aNOVO[nCONT,5] == 0
          aEVENTOS[nCONT] += space(9)
       else
          aEVENTOS[nCONT] += "(" + transform(aNOVO[nCONT,5],"@E 999.99") + ") "
       endif
       if ! aNOVO[nCONT,1] $ "633*572*577*579*571*643*207*910*930*701"
          aEVENTOS[nCONT] += transform(aNOVO[nCONT,6],"@E 999.99")
       else
          aEVENTOS[nCONT] += "  0.00"
       endif
       if substr(aEVENTOS[nCONT],5,1) == "P"
          nPROVENTOS += aNOVO[nCONT,4]
       elseif substr(aEVENTOS[nCONT],5,1) == "D"
          nDESCONTOS += aNOVO[nCONT,4]
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

   @ prow()+2,0   say XCOND1 + "Total de Proventos..: " + transform(nPROVENTOS,"@E 99,999,999,999.99")
   @ prow()  ,52  say "Total de Descontos..: " + transform(nDESCONTOS,"@E 99,999,999,999.99")
   @ prow()  ,105 say "Total Liquido..: " + transform(nPROVENTOS - nDESCONTOS,"@E 99,999,999,999.99")

   nPROVENTOS := nDESCONTOS := 0

   qstopprn()

return
