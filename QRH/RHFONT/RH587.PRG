/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: FOLHA DE PAGAMENTO
// OBJETIVO...: FICHA FINANCEIRA
// ANALISTA...: LUIS ANTONIO ORLANDO PEREIRA
// PROGRAMADOR: CARLOS EDUARDO RABELLO NUNES
// INICIO.....: JUNHO DE 1995
// OBS........:
// ALTERACOES.:

#define K_MAX_LIN 55

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG) .or. empty(cPERI) .or. (XNIVEL==1 .and. lastkey()==27)}

private sBLOCO1 := qlbloc("B587A","QBLOC.GLO") // bloco basico
private sBLOCO2 := qlbloc("B587B","QBLOC.GLO") // tipo de relatorio
private sBLOCO3 := qlbloc("B587C","QBLOC.GLO") // ordem de impressao
private sBLOCO4 := qlbloc("B587D","QBLOC.GLO") // quebra de impressao

private lMUDOU                 // controle de mudanca de periodo
private cTIPOREL               // tipo de relatorio
private cTITULO                // titulo do relatorio
private cORDEM  := "1"         // ordem de impressao (matricula/nome)
private cMATRICULA             // matricula p/ impressao individual
private cEVENTO                // codigo do evento
private cQUEBRA                // se PERIODO+MATRICULA ou MATRICULA+PERIODO
private aEDICAO := {}          // vetor para os campos de entrada de dados
private cPERI                  // periodo inicial
private cPERF                  // periodo final

private aFUN    := {{},{}}     // vetor com os dados do funcionario
private cNOMEEVE               // descricao do evento quando ! empty(cEVENTO)

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qgetx(-1,0,@cPERI,"@R 99/9999") }   , "PERI"      })
aadd(aEDICAO,{{ || qgetx(-1,0,@cPERF,"@R 99/9999") }   , "PERF"      })
aadd(aEDICAO,{{ || qesco(-1,0,@cTIPOREL,sBLOCO2) }   , "TIPOREL"   })
aadd(aEDICAO,{{ || qesco(-1,0,@cORDEM  ,sBLOCO3) }   , "ORDEM"     })
aadd(aEDICAO,{{ || view_fun(-1,0,@cMATRICULA)}       , "MATRICULA" })
aadd(aEDICAO,{{ || NIL },NIL}) // nome do funcionario
aadd(aEDICAO,{{ || view_event(-1,0,@cEVENTO)}        , "EVENTO"    })
aadd(aEDICAO,{{ || NIL },NIL}) // descricao do evento
aadd(aEDICAO,{{ || qesco(-1,0,@cQUEBRA ,sBLOCO4) }   , "QUEBRA"    })

do while .T.

   qlbloc(5,0,"B587A","QBLOC.GLO")
   XNIVEL     := 1
   XFLAG      := .T.
   cMATRICULA := space(6)
   cEVENTO    := space(3)
   cQUEBRA    := space(19)
   cTIPOREL   := " "
   cPERI      := space(6)
   cPERF      := space(6)

   qmensa()

   // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      if empty(cEVENTO)
         eval ( aEDICAO [XNIVEL,1] )
      elseif XNIVEL = 9 .and. ! empty(cEVENTO)
         qrsay(XNIVEL,"Emissao sem quebra ")
      endif
      if eval ( bESCAPE ) ; dbcloseall() ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   if ( i_inicializacao() , i_impressao() , NIL )

enddo

/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA _____________________________________________

static function i_critica ( cCAMPO )
   if XFLAG
      do case
         case cCAMPO == "TIPOREL"
              if empty(cTIPOREL) ; return .F. ; endif
              qrsay(XNIVEL,qabrev(cTIPOREL,"MADF",{"Mensal","Adiantamento","D�cimo Terceiro","F�rias"}))
         case cCAMPO == "MATRICULA"
              if ! empty(cMATRICULA)
                 qrsay(XNIVEL,cMATRICULA:=strzero(val(cMATRICULA),6))
              endif
              qrsay(XNIVEL+1,iif(FUN->(dbseek(cMATRICULA)),left(FUN->Nome,30),"*** todos os funcionarios ***"))
         case cCAMPO == "EVENTO"
              if ! empty(cEVENTO)
                 qrsay(XNIVEL,cEVENTO:=strzero(val(cEVENTO),3))
              endif
              qrsay(XNIVEL+1,iif(EVENT->(dbseek(cEVENTO)),EVENT->Descricao,"*** todos os eventos ***"))
         case cCAMPO == "ORDEM"
              if empty(cORDEM) ; return .F. ; endif
              qrsay(XNIVEL,qabrev(cORDEM,"12",{"Matr�cula","Nome"}))
         case cCAMPO == "QUEBRA"
              if empty(cQUEBRA) ; return .T. ; endif  // se escolhe EVENTO, pula quebra
              qrsay(XNIVEL,qabrev(cQUEBRA,"12",{"Matr�cula + Per�odo","Per�odo + Matr�cula"}))
      endcase
   endif
return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // CONSTROI VARIAVEL "cTITULO" __________________________________________

   cTIPOREL := qabrev(cTIPOREL,"MADF",{"MS","AD","DT","FR"})

   cTITULO = "FICHA FINANCEIRA "

   do case
      case cTIPOREL == "MS" ; cTITULO += "MENSAL"
      case cTIPOREL == "AD" ; cTITULO += "DE ADIANTAMENTO"
      case cTIPOREL == "DT" ; cTITULO += "DE 13O. SALARIO"
      case cTIPOREL == "FR" ; cTITULO += "DE FERIAS"
   endcase

   cTITULO += " (" + subs(cPERI,1,2) + "/" + subs(cPERI,3,4) + " a " + ;
                     subs(cPERF,1,2) + "/" + subs(cPERF,3,4) + ")"

   // SELECIONA ORDEM DO ARQUIVO CADFUN _____________________________________

   do case
      case cORDEM == "1" ; FUN->(dbsetorder(01)) // matricula
      case cORDEM == "2" ; FUN->(dbsetorder(02)) // nome
   endcase

   qmensa()


   // GUARDA NOME DO EVENTO QUANDO ! EMPTY(cEVENTO __________________________

   if ! EMPTY(cEVENTO)
      cNOMEEVE := EVENT->Descricao
   endif

   // ESTABELECE RELACOES ENTRE ARQUIVOS ____________________________________

   select LANC
   set relation to Evento into EVENT

   select SITUA
   set relation to Cargo into CARGO

   FUN->(dbgotop())

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impressao

   local nCONT := 0
   local cCOND

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif

   @ prow(),pcol() say XCOND1

   if ! empty(cMATRICULA)
      FUN->(dbseek(cMATRICULA))
   endif

   cPERI := val(subs(cPERI,3,4) + subs(cPERI,1,2))
   cPERF := val(subs(cPERF,3,4) + subs(cPERF,1,2))

   if cQUEBRA == "1" .or. ! empty(cMATRICULA)
      cCOND := {|| LANC->(dbseek(str(nCONT,6) + FUN->Matricula))}
   else
      cCOND := {|| LANC->(dbseek(str(nCONT,6)))}
   endif

   do while ! FUN->(eof()) .and. qcontprn() // loop principal

      if FUN->Data_adm > qfimmes(XDATASYS)
         FUN->(dbskip())
         loop
      endif

      for nCONT = cPERI to cPERF

          if subs(str(nCONT,6),5,2) == "13"
             nCONT += 87
             loop
          endif

          if ! qlineprn() ; return ; endif

          if eval(cCOND)
             if cQUEBRA == "2" .or. empty(cQUEBRA)
                qmensa("Processando Mes/Ano: " + subs(str(nCONT,6),5,2) + "/" + subs(str(nCONT,6),1,4))
             else
                qmensa("Processando Matricula: " + FUN->Matricula)
             endif

             if XPAGINA == 0 .or. prow() > K_MAX_LIN
                qpageprn()
                qcabecprn(cTITULO,132)
                if ! empty(cEVENTO)
                   @ prow()+2,0 say padc("Exclusivo para Evento: " + cEVENTO + " - " + rtrim(cNOMEEVE),132)
                   @ prow()+1,0 say " "
                endif
             endif

             if empty(cEVENTO)
                if cQUEBRA == "1"
                   i_emite_1 ( nCONT )
                else
                   i_emite_3 ( nCONT )
                endif
             else
                i_emite_2 ( nCONT )
             endif
          endif

      next

      if ! empty(cMATRICULA) ; exit ; endif

      FUN->(dbskip())

   enddo

   qstopprn(.F.)

return

/////////////////////////////////////////////////////////////////////////////
// EMITE FICHA FINANCEIRA TIPO 1 (QUANDO EVENTO NAO INFORMADO) ______________

static function i_emite_1 ( nCONT )

   local lACHOU  := .F.
   local cMATRICULA

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   aFUN := {{},{}}

   do while ! LANC->(eof()) .and. LANC->Anomes = str(nCONT,6) .and. qcontprn()
      cMATRICULA := FUN->Matricula
      do while ! LANC->(eof()) .and. LANC->Anomes = str(nCONT,6)  .and. LANC->Matricula == cMATRICULA
         if LANC->Valor <> 0.00 .and. LANC->MATRICULA == cMATRICULA .and. LANC->Ambiente == cTIPOREL
            lACHOU := .t.
            aadd(aFUN[1],{LANC->Evento,EVENT->Finalidade,left(EVENT->Descricao,34),LANC->Valor,LANC->Fracao} )
         endif
         LANC->(dbskip())
      enddo

      if lACHOU
         i_imp_sub_cabec()
      else
         return
      endif

      if lACHOU
         if prow() > K_MAX_LIN
            qpageprn()
            qcabecprn(cTITULO,132)
         endif

         @ prow()+2,0 say padc("Lancamentos em: " + qnomemes(subs(str(nCONT,6),5,2))+"/"+subs(str(nCONT,6),1,4),132)
         @ prow()+1,0 say " "

         i_imp_dados()
      endif

      if empty(cEVENTO) .and. lACHOU
         BASE->(dbseek(FUN->Matricula+str(nCONT,6)))

         bPROV := { || BASE->Prov_ms + BASE->Prov_fr + BASE->Prov_dt }
         bDESC := { || BASE->Desc_ms + BASE->Desc_fr + BASE->Desc_dt }

         @ prow()+2,9 say   "Proventos: " + transform(eval(bPROV)   ,"@E 999,999.99") + ;
                          "  B.INSS.Ms: " + transform(BASE->B_inssms,"@E 999,999.99") + ;
                          "  B.IRRF.Ms: " + transform(BASE->B_irrfms,"@E 999,999.99") + ;
                          "  B.FGTS.Ms: " + transform(BASE->B_fgtsms,"@E 999,999.99") + ;
                          "  B.Sal.Fam: " + transform(BASE->B_salfam,"@E 999,999.99")

         @ prow()+1,9 say   "Descontos: " + transform(eval(bDESC)   ,"@E 999,999.99") + ;
                          "  B.INSS.Fr: " + transform(BASE->B_inssfr,"@E 999,999.99") + ;
                          "  B.IRRF.Fr: " + transform(BASE->B_irrffr,"@E 999,999.99") + ;
                          "  B.FGTS.Fr: " + transform(BASE->B_fgtsfr,"@E 999,999.99") + ;
                          "  V.Sal.Fam: " + transform(BASE->V_salfam,"@E 999,999.99")

         @ prow()+1,9 say   "Liquido..: " + transform(eval(bPROV)-eval(bDESC),"@E 999,999.99") + ;
                          "  B.INSS.Dt: " + transform(BASE->B_inssdt,"@E 999,999.99") + ;
                          "  B.IRRF.Dt: " + transform(BASE->B_irrfdt,"@E 999,999.99") + ;
                          "  B.FGTS.Dt: " + transform(BASE->B_fgtsdt,"@E 999,999.99") + ;
                          "  Desc.Grps: " + transform(0             ,"@E 999,999.99")

         @ prow()+1,0 say replicate("-",132)
      endif

      lACHOU := .F.
      aFUN   := {{},{}}

   enddo

return

/////////////////////////////////////////////////////////////////////////////
// EMITE FICHA FINANCEIRA TIPO 2 (PARA EVENTO INFORMADO) ____________________

static function i_emite_2 ( nCONT )

   local lACHOU   := .F.
   local aEVENTOS := {}
   local nCONTA

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   aFUN := {{},{}}

   do while ! LANC->(eof()) .and. LANC->Anomes == str(nCONT,6)
      if (LANC->Fracao <> 0 .or. LANC->Valor <> 0) .and. LANC->Ambiente == cTIPOREL .and. LANC->Evento == cEVENTO
         if empty(cMATRICULA) .or. (! empty(cMATRICULA).and. LANC->Matricula == cMATRICULA)
            lACHOU := .T.
            FUN->(dbseek(LANC->Matricula))
            aadd(aFUN[1],{LANC->Matricula,left(FUN->Nome,30),LANC->Valor,LANC->Fracao})
         endif
      endif

      LANC->(dbskip())
   enddo

   if ! lACHOU
      return
   endif

   @ prow()+1,0 say padc("Lancamentos no Mes: " + qnomemes(subs(str(nCONT,6),5,2))+"/"+subs(str(nCONT,6),1,4),132)
   @ prow()+1,0 say " "
     
   // JUNTA TODOS OS ELEMENTOS PARA FORMAR UMA LINHA ________________________

   aEVENTOS := array(len(aFUN[1]))

   for nCONTA = 1 to len(aFUN[1])
       aEVENTOS[nCONTA]    := aFUN[1,nCONTA,1] + " - "
       aEVENTOS[nCONTA]    += aFUN[1,nCONTA,2] + "  "
       aEVENTOS[nCONTA]    += transform(aFUN[1,nCONTA,3],"@E 999,999,999.99") + " "
       if aFUN[1,nCONTA,4] == 0.00
          aEVENTOS[nCONTA] += space(8)
       else
          aEVENTOS[nCONTA] += "(" + transform(aFUN[1,nCONTA,4],"@E 999.99") + ")"
       endif
   next

   nMETADE := len(aEVENTOS) / 2

   if int(nMETADE) != nMETADE        // entao e' impar
      aadd(aEVENTOS,space(60))
   endif

   nMETADE := len(aEVENTOS) / 2

   for nCONTA = 1 to nMETADE
       if prow() > K_MAX_LIN
          qpageprn()
          qcabecprn(cTITULO,132)
          @ prow()+2,0 say padc("Exclusivo para Evento: " + cEVENTO + " - " + rtrim(cNOMEEVE),132)
          @ prow()+2,0 say padc("Lancamentos no Mes: " + qnomemes(subs(str(nCONT,6),5,2)) + "/" + subs(str(nCONT,5),1,4),132)
          @ prow()+1,0 say " "
       endif

       @ prow()+1,0 say aEVENTOS[nCONTA] + " | " + aEVENTOS[nCONTA + nMETADE]
   next

   @ prow()+1,0 say replicate("-",132)

return

/////////////////////////////////////////////////////////////////////////////
// EMITE FICHA FINANCEIRA TIPO 3 (PARA EVENTO NAO INFORMADO) ________________

static function i_emite_3 ( nCONT )

   local lACHOU := .f.
   local cMAT_AGORA

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   aFUN := {{},{}}

   do while ! LANC->(eof()) .and. LANC->Anomes == str(nCONT,6) .and. qcontprn()
      if ! empty(cMATRICULA)
         cMAT_AGORA := cMATRICULA
      else
         cMAT_AGORA := LANC->Matricula
      endif

      do while ! LANC->(eof()) .and. LANC->Anomes == str(nCONT,6) .and. LANC->Matricula = cMAT_AGORA
         if LANC->Valor <> 0.00 .and. LANC->Matricula = cMAT_AGORA .and. LANC->Ambiente == cTIPOREL
            lACHOU := .t.
            FUN->(dbseek(LANC->Matricula))
            aadd(aFUN[1],{LANC->Evento,EVENT->Finalidade,left(EVENT->Descricao,34),LANC->Valor,LANC->Fracao} )
         endif
         LANC->(dbskip())
      enddo

      if lACHOU .and. qcontprn()
         if prow() > K_MAX_LIN
            qpageprn()
            qcabecprn(cTITULO,132)
         endif

         @ prow()+2,0 say padc("Lancamentos em: " + qnomemes(subs(str(nCONT,6),5,2))+"/"+subs(str(nCONT,6),1,4),132)
         @ prow()+2,0 say PADC("Matricula: " + FUN->Matricula + " - " + left(FUN->Nome,30),132)
         @ prow()+1,0 say " "

         i_imp_dados()

         BASE->(dbseek(FUN->Matricula+str(nCONT,6)))

         bPROV := { || BASE->Prov_ms + BASE->Prov_fr + BASE->Prov_dt }
         bDESC := { || BASE->Desc_ms + BASE->Desc_fr + BASE->Desc_dt }

         @ prow()+2,9 say   "Proventos: " + transform(eval(bPROV)   ,"@E 999,999.99") + ;
                          "  B.INSS.Ms: " + transform(BASE->B_inssms,"@E 999,999.99") + ;
                          "  B.IRRF.Ms: " + transform(BASE->B_irrfms,"@E 999,999.99") + ;
                          "  B.FGTS.Ms: " + transform(BASE->B_fgtsms,"@E 999,999.99") + ;
                          "  B.Sal.Fam: " + transform(BASE->B_salfam,"@E 999,999.99")

         @ prow()+1,9 say   "Descontos: " + transform(eval(bDESC)   ,"@E 999,999.99") + ;
                          "  B.INSS.Fr: " + transform(BASE->B_inssfr,"@E 999,999.99") + ;
                          "  B.IRRF.Fr: " + transform(BASE->B_irrffr,"@E 999,999.99") + ;
                          "  B.FGTS.Fr: " + transform(BASE->B_fgtsfr,"@E 999,999.99") + ;
                          "  V.Sal.Fam: " + transform(BASE->V_salfam,"@E 999,999.99")

         @ prow()+1,9 say   "Liquido..: " + transform(eval(bPROV)-eval(bDESC),"@E 999,999.99") + ;
                          "  B.INSS.Dt: " + transform(BASE->B_inssdt,"@E 999,999.99") + ;
                          "  B.IRRF.Dt: " + transform(BASE->B_irrfdt,"@E 999,999.99") + ;
                          "  B.FGTS.Dt: " + transform(BASE->B_fgtsdt,"@E 999,999.99") + ;
                          "  Desc.Grps: " + transform(0             ,"@E 999,999.99")

         @ prow()+1,0 say replicate("-",132)

      else
         return
      endif

      lACHOU := .f.
      aFUN   := {{},{}}

   enddo

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IMPRIMIR SUB CABECALHO DO FUNCIONARIO ________________________

static function i_imp_sub_cabec

   @ prow()+1,0      say "Matricula: " + FUN->Matricula + "    Nome: " + left(FUN->Nome,30)
   SITUA->(dbsetorder(1))
   SITUA->(dbgotop())
   SITUA->(dbseek(FUN->Matricula))
   @ prow(),pcol()+5 say "Cargo: "     + padr(SITUA->Cargo,8) + CARGO->Descricao

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IMPRIMIR DADOS DE LANCAMENTO DO FUNCIONARIO __________________

static function i_imp_dados

   local nCONT, nMETADE
   local aEVENTOS := array(len(aFUN[1]))
   local aORDEM   := {}

   // JUNTA TODOS OS ELEMENTOS PARA FORMAR UMA LINHA ________________________

   for nCONT = 1 to len(aFUN[1])
       aEVENTOS[nCONT] := aFUN[1,nCONT,1] + " "
       aEVENTOS[nCONT] += aFUN[1,nCONT,2] + " "
       aEVENTOS[nCONT] += aFUN[1,nCONT,3] + " "
       aEVENTOS[nCONT] += transform(aFUN[1,nCONT,4],"@E 999,999,999.99") + " "
       if aFUN[1,nCONT,5] == 0
          aEVENTOS[nCONT] += space(8)
       else
          aEVENTOS[nCONT] += "(" + transform(aFUN[1,nCONT,5],"@E 999.99") + ")"
       endif
   next

   // TESTE E COLOCA NA ORDEM DE PROVENTOS, DESCONTOS, INC.BASE E DEC.BASE __

   for nCONT = 1 to len(aEVENTOS)
       iif ( substr(aEVENTOS[nCONT],5,1)=="P" , aadd(aORDEM,aEVENTOS[nCONT]) , NIL )
   next
   for nCONT = 1 to len(aEVENTOS)
       iif ( substr(aEVENTOS[nCONT],5,1)=="D" , aadd(aORDEM,aEVENTOS[nCONT]) , NIL )
   next
   for nCONT = 1 to len(aEVENTOS)
       iif ( substr(aEVENTOS[nCONT],5,1)=="+" , aadd(aORDEM,aEVENTOS[nCONT]) , NIL )
   next
   for nCONT = 1 to len(aEVENTOS)
       iif ( substr(aEVENTOS[nCONT],5,1)=="-" , aadd(aORDEM,aEVENTOS[nCONT]) , NIL )
   next

   nMETADE := len(aORDEM) / 2

   if int(nMETADE) != nMETADE        // entao e' impar
      aadd(aORDEM,space(60))
   endif

   nMETADE := len(aORDEM) / 2

   for nCONT = 1 to nMETADE
       if prow() > K_MAX_LIN .and. qcontprn()
          qpageprn()
          qcabecprn(cTITULO,132)
          if cQUEBRA == "1"
             i_imp_sub_cabec()
             @ prow()+1,0 say " "
          else
             @ prow()+2,0 say padc("Lancamentos em: " + qnomemes(subs(str(nCONT,6),5,2))+"/"+subs(str(nCONT,6),1,4),132)
             @ prow()+2,0 say PADC("Matricula: " + FUN->Matricula + " - " + left(FUN->Nome,30),132)
             @ prow()+1,0 say " "
          endif
       endif

       @ prow()+1,0 say aORDEM[nCONT] + " | " + aORDEM[nCONT+nMETADE]
   next

return
