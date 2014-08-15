/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: FOLHA DE PAGAMENTO
// OBJETIVO...: RELATORIO DE CONTRIBUICOES SINDICAL
// ANALISTA...: CARLOS EDUARDO RABELLO NUNES
// PROGRAMADOR: O MESMO
// INICIO.....: MARCO DE 1996
// OBS........:
// ALTERACOES.:

#define K_MAX_LIN 55

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG) .or. lastkey() = 27}

private cTITULO1       // titulo do relatorio
private cTITULO2       // sub-titulo do relatorio
private aEDICAO := {}  // vetor para os campos de entrada de dados
private lCONF          // variavel para confirmacao
private nCONT          // variavel auxiliar para contagem
private cAUX           // variavel auxiliar para macro
private lACHOU         // flag para indicar existencia de evento com valor
private nTOTFUN        // total de contribuicao por funcionario
private nTOTSIND       // total de contribuicao por sindicato
private cANOMES        // ano e mes atual
private cSINDANT       // sindicato anterior para controle de quebra
private cEVENT1        // codigo do primeiro evento de contribuicao
private cEVENT2        // codigo do segundo evento de contribuicao
private cEVENT3        // codigo do terceiro evento de contribuicao

SITUA->(dbSetFilter({|| Anomes == XANOMES},"Anomes == XANOMES"))

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || view_event(-1,0,@cEVENT1 ) } , "EVENT1" })
aadd(aEDICAO,{{ || NIL },NIL}) // descricao do EVENTO 1
aadd(aEDICAO,{{ || view_event(-1,0,@cEVENT2 ) } , "EVENT2" })
aadd(aEDICAO,{{ || NIL },NIL}) // descricao do EVENTO 2
aadd(aEDICAO,{{ || view_event(-1,0,@cEVENT3 ) } , "EVENT3" })
aadd(aEDICAO,{{ || NIL },NIL}) // descricao do EVENTO 3
aadd(aEDICAO,{{ || lCONF := qconf("Confirma Eventos ?") },NIL})

do while .T.

   qlbloc(5,0,"B585A","QBLOC.GLO")
   XNIVEL  := 1
   XFLAG   := .T.
   cANOMES := qanomes(XDATASYS)
   cEVENT1 := cEVENT2 := cEVENT3 := "   "

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
      case cCAMPO == "EVENT1"
           if ! empty(cEVENT1)
              cEVENT1 := strzero(val(cEVENT1),3)
              if EVENT->(dbseek(cEVENT1))
                 qrsay(XNIVEL+1,EVENT->Descricao)
              else
                 qmensa("Evento n„o cadastrado !!","B")
                 return .F.
              endif
           else
              qmensa("Evento 1 ‚ obrigat¢rio !!","B")
              return .F.
           endif
      case cCAMPO == "EVENT2"
           if ! empty(cEVENT2)
              if cEVENT2 == cEVENT1
                 qmensa("Evento j  informado !!","B")
                 return .F.
              endif
              cEVENT2 := strzero(val(cEVENT2),3)
              if EVENT->(dbseek(cEVENT2))
                 qrsay(XNIVEL+1,EVENT->Descricao)
              else
                 qmensa("Evento n„o cadastrado !!","B")
                 return .F.
              endif
           endif
      case cCAMPO == "EVENT3"
           if ! empty(cEVENT3)
              if cEVENT3 $ cEVENT1 + "-" + cEVENT2
                 qmensa("Evento j  informado !!","B")
                 return .F.
              endif
              cEVENT3 := strzero(val(cEVENT3),3)
              if EVENT->(dbseek(cEVENT3))
                 qrsay(XNIVEL+1,EVENT->Descricao)
              else
                 qmensa("Evento n„o cadastrado !!","B")
                 return .F.
              endif
           endif
   endcase
return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   if ! lCONF ; return .F. ; endif

   // CONSTROI VARIAVEIS "cTITULO1 e cTITULO2" ______________________________

   cTITULO1 := "RELATORIO DE CONTRIBUICAO SINDICAL - " + substr(dtoc(XDATASYS),4,7)

   cTITULO2 := "C.G.C. " + XCGCCPF

   // INDEXA ARQUIVO FUN POR SINDICATO + MATRICULA __________________________

   FUN->(dbCreateIndex( XDRV_RH + "TMP", "Sind_cod + Matricula", {|| Sind_cod + Matricula}, if( .F., .T., NIL ) ))

   FUN->(dbgotop())

   qmensa()

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impressao

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif

   @ prow(),pcol() say XCOND1

   do while ! FUN->(eof()) .and. qcontprn()     // condicao principal de loop

      cSINDANT := FUN->Sind_cod
      nTOTSIND := 0

      do while ! FUN->(eof()) .and. FUN->Sind_cod == cSINDANT .and. qcontprn()
         SITUA->(dbseek(FUN->Matricula))

         if FUN->Situacao == "H" .or. FUN->Data_Adm > qfimmes(XDATASYS)
            FUN->(dbskip())
            loop
         endif

         lACHOU  := .F.
         nTOTFUN := 0

         for nCONT = 1 to 3
             cAUX := "cEVENT" + str(nCONT,1)
             if empty(&cAUX)
                exit
             endif
             if LANC->(dbseek(cANOMES+FUN->Matricula+"MS"+&cAUX))
                nTOTFUN  += LANC->Valor
                nTOTSIND += LANC->Valor
                lACHOU   := .T.
             endif
         next

         if lACHOU
            SIND->(dbseek(FUN->Sind_cod))

            if ! qlineprn() ; return ; endif
            
            if XPAGINA == 0 .or. prow() > K_MAX_LIN
               qpageprn()
               qcabecprn(cTITULO1,132,.T.,cTITULO2)
               @ prow()+2,000 say padc(SIND->Descricao,132)
               @ prow()+2,000 say "MATRICULA"
               @ prow()  ,017 say "NOME DO FUNCIONARIO"
               @ prow()  ,067 say "CARGO"
               @ prow()  ,099 say "SALARIO"
               @ prow()  ,120 say "CONTRIBUICAO"
               @ prow()+1,000 say "---------"
               @ prow()  ,012 say repl("-",30)
               @ prow()  ,050 say repl("-",40)
               @ prow()  ,095 say "---------------"
               @ prow()  ,120 say "------------"
            endif

            @ prow()+1,002 say FUN->Matricula
            @ prow()  ,012 say left(FUN->Nome,30)

            CARGO->(dbseek(SITUA->Cargo))

            @ prow()  ,050 say CARGO->Descricao
            @ prow()  ,098 say transform(SITUA->Salario,"@E 9,999,999.99")
            @ prow()  ,120 say transform(nTOTFUN,"@E 9,999,999.99")

            FUN->(dbskip())
         else
            FUN->(dbskip())
         endif

      enddo

      if lACHOU == .T.
         @ prow()+2,098 say "TOTAL DO SINDICATO:"
         @ prow()  ,120 say transform(nTOTSIND,"@E 9,999,999.99")
      endif

      setprc(100,0)

   enddo

   qstopprn()

   qmensa()

return
