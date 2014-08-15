/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: FOLHA DE PAGAMENTO
// OBJETIVO...: RELATORIO DE EVENTOS POR FUNCIONARIOS
// ANALISTA...: LUCINEIDE VILAR POSSEBOM WIECZORKOVSKI
// PROGRAMADOR: A MESMA
// INICIO.....: AGOSTO DE 1999
// OBS........:
// ALTERACOES.:

#define K_MAX_LIN 60

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(lastkey()==27 .or. !XFLAG)}

private nTOTAL                 // total
private cTITULO                // titulo
private cCENTRO                // centro de custo para filtro
private cFILIAL                // filial para filtro
private cEVENT                 // evento para filtro
private cTIPOREL              // ambiente para busca
private aEDICAO := {}          // vetor para os campos de entrada de dados
private sBLOCO1 := qlbloc("B552B","QBLOC.GLO") // tipo de relatorio

SITUA->(dbSetFilter({|| Anomes == XANOMES},"Anomes == XANOMES"))

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || view_fun(-1,0,@cMATRICULA)}       , "MATRICULA" })
aadd(aEDICAO,{{ || NIL },NIL}) // nome do funcionario
aadd(aEDICAO,{{ || view_ccusto(-1,0,@cCENTRO)}       , "CENTRO"    })
aadd(aEDICAO,{{ || NIL },NIL}) // descricao do centro
aadd(aEDICAO,{{ || view_filia(-1,0,@cFILIAL)}        , "FILIAL"    })
aadd(aEDICAO,{{ || NIL },NIL}) // descricao da filial
aadd(aEDICAO,{{ || view_event(-1,0,@cEVENT)}         , "EVENT"     })
aadd(aEDICAO,{{ || NIL },NIL}) // descricao do evento
aadd(aEDICAO,{{ || qesco(-1,0,@cTIPOREL ,sBLOCO1)} , "TIPOREL"  })

do while .T.

   qlbloc(5,0,"B552A","QBLOC.GLO")
   XNIVEL  := 1
   XFLAG   := .T.
   cCENTRO := space(8)
   cFILIAL := space(4)
   cMATRICULA := space(6)
   cTIPOREL  := " "
   cEVENT     := space(3)

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
      case cCAMPO == "MATRICULA"
           if ! empty(cMATRICULA)
              if ! FUN->(dbseek(cMATRICULA))
                 qmensa("Funcionario n„o Cadastrado !!","B")
                 return .F.
              endif
           endif
           qrsay(XNIVEL+1,iif(FUN->(dbseek(cMATRICULA)),left(FUN->Nome,40),"*** Todos os Funcion rios ***"))

      case cCAMPO == "EVENT"
           if empty(cEVENT) ; return .F. ; endif
           if ! empty(cEVENT)
              if ! EVENT->(dbseek(cEVENT))
                 qmensa("Evento n„o Cadastrado !!","B")
                 return .F.
              else
                 qrsay(XNIVEL+1,left(EVENT->Descricao,30))
              endif
           endif

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
      case cCAMPO == "TIPOREL"
           if empty(cTIPOREL) ; return .F. ; endif
           qrsay(XNIVEL,qabrev(cTIPOREL,"MADFC",{"Mˆs Corrente","Adiantamento","D‚cimo Terceiro","F‚rias","Cont bil"}))

   endcase
return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // CONSTROI VARIAVEL "cTITULO" __________________________________________

   cTITULO = "RELACAO DE EVENTOS POR FUNCIONARIO"

   // SELECIONA ORDEM DO ARQUIVO CADFUN _____________________________________

   FUN->(dbsetorder(01)) // matricula

   qmensa()

   // ESTABELECE RELACOES ENTRE ARQUIVOS ____________________________________

   FUN->(dbSetRelation( "FILIAL", {|| Filial}, "Filial" ))

   FUN->(dbgotop())

   EVENT->(dbsetorder(1))
   EVENT->(dbgotop())
   EVENT->(dbseek(cEVENT))

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impressao

   local cPIC   := "@E 9,999,999,999.99"
   nESTF1 := 0
   nESTF2 := 0
   nESTF3 := 0
   nESTF4 := 0
   nESTF5 := 0
   nESTF6 := 0
   nSEXOFM:= 0
   nSEXOFF:= 0
   nSEXODM:= 0
   nSEXODF:= 0
   nDEPE  := 0
   nFUN   := 0
   nTOTAL := 0
   cTIPOREL := qabrev(cTIPOREL,"MADFC",{"MS","AD","DT","FR","CT"})


   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif

   qmensa("Imprimindo...")

   SITUA->(dbsetorder(3)) // ccusto + matricula
   SITUA->(dbgotop())

//   if ! empty(cCENTRO)
//      SITUA->(dbseek(cCENTRO))
//   else
//      cCENTRO_ATU := SITUA->Ccusto
//   endif

   do while ! SITUA->(eof()) .and. qcontprn()     // condicao principal de loop

      if ! empty(cMATRICULA)
         if SITUA->Matricula <> cMATRICULA
            SITUA->(dbskip())
            loop
         endif
      endif

//      if ! empty(cCENTRO)
//         if SITUA->Ccusto <> cCENTRO
//            SITUA->(dbskip())
//            loop
//         endif
 //     endif

      if ! FUN->(dbseek(SITUA->Matricula))
         SITUA->(dbskip())
         loop
      endif

      if ! empty(cFILIAL) .and. FUN->Filial <> cFILIAL
         SITUA->(dbskip())
         loop
      endif

      if ! LANC->(dbseek(XANOMES+FUN->Matricula+cTIPOREL+cEVENT))
         SITUA->(dbskip())
         loop
      endif

      if LANC->Valor == 0
         SITUA->(dbskip())
         loop
      endif
      if ! qlineprn() ; return ; endif

      if XPAGINA == 0 .or. prow() > K_MAX_LIN
         qpageprn()
         qcabecprn(cTITULO,80)
         @ prow()+1,0 say "Matri. Funcionario                                     Fracao            Valor"
         @ prow()+2,0 say "   EVENTO          --> " + EVENT->Evento + "      " + EVENT->Descricao
         @ prow()+1,0 say replicate("-",80)
      endif

      qmensa("Funcionario: "+FUN->Matricula+" / "+left(FUN->Nome,40))

      @ prow()+1,0  say FUN->Matricula
      @ prow()  ,8  say left(FUN->Nome,40)
      @ prow()  ,53 say transform(LANC->Fracao,"@R 999.9999")
      @ prow()  ,65 say transform(LANC->Valor,"@R 9999,999,999.99")
      nTOTAL := nTOTAL + LANC->Valor

      nFUN++

      SITUA->(dbskip())

 //    if ! SITUA->(eof()) .and. empty(cCENTRO) .and. cCENTRO_ATU <> SITUA->Ccusto
 //        @ prow()+1,0 say " TOTAL DE FUNCIONARIOS DO CENTRO........: " + transform(nFUN,"@R 9999")
 //         nFUN :=  0
 //        @ prow()+2,0 say "   CENTRO DE CUSTO --> " + iif(CCUSTO->(dbseek(SITUA->CCusto)),CCUSTO->Descricao,space(10))
 //        cCENTRO_ATU := SITUA->Ccusto
 //     endif

   enddo




   @ prow()+1,0 say replicate("-",80)
   @ prow()+1,0 say " VALOR TOTAL...........................: " + transform(nTOTAL,"@R 999,999.99")
   nTOTAL := 0
   qstopprn()

   qmensa()

return
