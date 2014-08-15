/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: FOLHA DE PAGAMENTO
// OBJETIVO...: INFORME DE TOTAIS DE HORAS AULAS
// ANALISTA...: LUCIANO DA SILVA GORSKI
// PROGRAMADOR: LUCIANO DA SILVA GORSKI
// INICIO.....: JANEIRO DE 1996
// OBS........:
// ALTERACOES.:

#define K_MAX_LIN 52

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE    := {||(XNIVEL==1 .and. !XFLAG) .or. (XNIVEL==1 .and. lastkey()==27)}
private nEVENTO134 := 0
private nEVENTO135 := 0
private nEVENTO136 := 0
private nEVENTO137 := 0
private nEVENTO138 := 0
private nEVENTO139 := 0
private nEVENTO140 := 0
private nEVENTO142 := 0
private nEVENTO143 := 0
private cANOBASE   := space(4)
private cMATRICULA              // matricula p/ impressao individual
private aEDICAO    := {}        // vetor para os campos de entrada de dados
private cTITULO    := "RELATORIO DE TOTAIS DE HORAS AULAS - RELATORIO ANUAL"

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || view_fun(-1,0,@cMATRICULA )}, "MATRICULA" })
aadd(aEDICAO,{{ || NIL },NIL}) // nome do funcionario
aadd(aEDICAO,{{ || qgetx(-1,0,@cANOBASE, "@9")}, "ANOBASE"   })

do while .T.

   qlbloc(5,0,"B586A","QBLOC.GLO")
   XNIVEL     := 1
   XFLAG      := .T.
   cMATRICULA := space(6)

   // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; dbcloseall() ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo


   i_impressao()

enddo

/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA _____________________________________________

static function i_critica ( cCAMPO )

   if ! XFLAG ; return .T. ; endif

   do case
      case cCAMPO == "MATRICULA"
           FUN->(dbsetorder(1))
           FUN->(dbgotop())
           if ! empty(cMATRICULA)
              qrsay(XNIVEL,cMATRICULA := strzero(val(cMATRICULA),6))
              if ! FUN->(dbseek(cMATRICULA))
                 qmensa("Funcion rio nao encontrado...","B")
                 return .F.
              else
                 qrsay(XNIVEL+1,left(FUN->Nome,30))
              endif
           else
              qrsay(XNIVEL+1,"*** Todos os funcion rios ***")
           endif
      case cCAMPO == "ANOBASE"
           if empty(cANOBASE)
              qmensa("Campo ANO BASE ‚ obrigat¢rio ou est  invalido CAMPO ANO <9999>...","B")
              qmensa("")
              return .F.
           else
              qmensa("Aguarde... Filtrando Ano Informado!")
              FUN->(dbgotop())
              LANC->(dbgotop())
              LANC->(dbSetFilter({|| left(Anomes,4) == cANOBASE },"Left(Anomes,4) == cANOBASE"))
//              FUN->(dbSetRelation( "LANC" , {|| Matricula+ANOMES}, "Matricula+ANOMES" ))
              qmensa("")
              Return .T.
           endif
   endcase
return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IMPRESSAO ____________________________________________________

static function i_impressao

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________


   if ! qinitprn() ; return ; endif

   @ prow(),pcol() say XCOND1

   if ! empty(cMATRICULA)
      FUN->(dbseek(cMATRICULA))
      LANC->(dbgotop())
//      LANC->(dbseek(cMATRICULA))
   else
      FUN->(dbsetorder(3))
      LANC->(dbsetorder(3))
      FUN->(dbgotop())
      LANC->(dbgotop())
   endif

   do while ! FUN->(eof()) //.and. qcontprn()     // condicao principal de loop

      if Empty(cMATRICULA)
         LANC->(dbgotop())
      Endif
      qmensa("Analizando, Funcion rio: "+FUN->Matricula+" / "+left(FUN->Nome,30))

      if ! LANC->(eof())
         do while ! LANC->(eof())
            qgirabarra()
            if LANC->Matricula == FUN->Matricula .and. left(LANC->Anomes,4) == cANOBASE
               if LANC->Evento == "134" .and. LANC->Ambiente == "MS"
                  nEVENTO134  += LANC->Fracao
               Endif
               if LANC->Evento == "135" .and. LANC->Ambiente == "MS"
                  nEVENTO135  += LANC->Fracao
               Endif
               if LANC->Evento == "136" .and. LANC->Ambiente == "MS"
                  nEVENTO136  += LANC->Fracao
               Endif
               if LANC->Evento == "137" .and. LANC->Ambiente == "MS"
                  nEVENTO137  += LANC->Fracao
               Endif
               if LANC->Evento == "138" .and. LANC->Ambiente == "MS"
                  nEVENTO138  += LANC->Fracao
               Endif
               if LANC->Evento == "139" .and. LANC->Ambiente == "MS"
                  nEVENTO139  += LANC->Fracao
               Endif
               if LANC->Evento == "140" .and. LANC->Ambiente == "MS"
                  nEVENTO140  += LANC->Fracao
               Endif
               if LANC->Evento == "142" .and. LANC->Ambiente == "MS"
                  nEVENTO142  += LANC->Fracao
               Endif
               if LANC->Evento == "143" .and. LANC->Ambiente == "MS"
                  nEVENTO143  += LANC->Fracao
               Endif
            Endif
            LANC->(dbskip())
         enddo

         if ! qlineprn() ; return ; endif

         if XPAGINA == 0 .or. prow() > K_MAX_LIN
            qpageprn()
            qcabecprn(cTITULO,132)
         endif

         if nEVENTO134 == 0 .and. nEVENTO135 == 0 .and. nEVENTO136 == 0 .and. nEVENTO137 == 0 .and. nEVENTO138 == 0 .and. nEVENTO139 == 0 .and. nEVENTO140 == 0 .and. nEVENTO142 == 0 .and. nEVENTO143 == 0
            if ! empty(cMATRICULA)
               exit
            endif
            FUN->(dbskip())
            Loop
         Endif

         @ prow()+1,00 say "Matricula..: "+FUN->Matricula + "  Nome..: " + left(FUN->Nome,30)
         @ prow()+1,00 say ""
         @ prow()+1,00 say "Evento 134 - Salario Hora/Aula Cursinho.............................................................................: "+Transform(nEVENTO134,"@R 999,999,999.99")
         @ prow()+1,00 say "Evento 135 - Salario Hora/Aula R1...................................................................................: "+Transform(nEVENTO135,"@R 999,999,999.99")
         @ prow()+1,00 say "Evento 136 - Salario Hora/Aula R2...................................................................................: "+Transform(nEVENTO136,"@R 999,999,999.99")
         @ prow()+1,00 say "Evento 137 - Salario Hora/Aula R3...................................................................................: "+Transform(nEVENTO137,"@R 999,999,999.99")
         @ prow()+1,00 say "Evento 138 - Salario Hora/Aula S1...................................................................................: "+Transform(nEVENTO138,"@R 999,999,999.99")
         @ prow()+1,00 say "Evento 139 - Salario Hora/Aula S2...................................................................................: "+Transform(nEVENTO139,"@R 999,999,999.99")
         @ prow()+1,00 say "Evento 140 - Salario Hora/Aula R2 - 1...............................................................................: "+Transform(nEVENTO140,"@R 999,999,999.99")
         @ prow()+1,00 say "Evento 142 - Salario Hora/Aula R2 - 2...............................................................................: "+Transform(nEVENTO142,"@R 999,999,999.99")
         @ prow()+1,00 say "Evento 143 - Salario Hora/Aula TST..................................................................................: "+Transform(nEVENTO143,"@R 999,999,999.99")
         @ prow()+1,00 say ""

         nEVENTO134 := 0
         nEVENTO135 := 0
         nEVENTO136 := 0
         nEVENTO137 := 0
         nEVENTO138 := 0
         nEVENTO139 := 0
         nEVENTO140 := 0
         nEVENTO142 := 0
         nEVENTO143 := 0

      endif

      if ! empty(cMATRICULA)
         exit
      endif

      FUN->(dbskip())

   enddo
   qmensa("")
   qstopprn()

return
