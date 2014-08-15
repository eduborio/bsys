/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: FOLHA DE PAGAMENTO
// OBJETIVO...: RELATORIO DE CADASTRO DE DEPENDENTES
// ANALISTA...: LUCINEIDE VILAR POSSEBOM WIECZORKOVSKI
// PROGRAMADOR: A MESMA
// INICIO.....: AGOSTO DE 1999
// OBS........:
// ALTERACOES.:

#define K_MAX_LIN 60

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(lastkey()==27 .or. !XFLAG)}

private sBLOCO1 := qlbloc("B551B","QBLOC.GLO") // ordem de impressao

private nTOTAL                 // total
private cTITULO                // titulo
private cCENTRO                // centro de custo para filtro
private cFILIAL                // filial para filtro
private aEDICAO := {}          // vetor para os campos de entrada de dados

SITUA->(dbSetFilter({|| Anomes == XANOMES},"Anomes == XANOMES"))

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || view_fun(-1,0,@cMATRICULA)}       , "MATRICULA" })
aadd(aEDICAO,{{ || NIL },NIL}) // nome do funcionario
aadd(aEDICAO,{{ || view_ccusto(-1,0,@cCENTRO)}       , "CENTRO"    })
aadd(aEDICAO,{{ || NIL },NIL}) // descricao do centro
aadd(aEDICAO,{{ || view_filia(-1,0,@cFILIAL)}        , "FILIAL"    })
aadd(aEDICAO,{{ || NIL },NIL}) // descricao do filial

do while .T.

   qlbloc(5,0,"B551A","QBLOC.GLO")
   XNIVEL  := 1
   XFLAG   := .T.
   cCENTRO := space(8)
   cFILIAL := space(4)
   cMATRICULA := space(6)

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
   endcase
return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // CONSTROI VARIAVEL "cTITULO" __________________________________________

   cTITULO = "RELACAO DE DEPENDENTES POR FUNCIONARIO"

   // SELECIONA ORDEM DO ARQUIVO CADFUN _____________________________________

   FUN->(dbsetorder(01)) // matricula

   qmensa()

   // ESTABELECE RELACOES ENTRE ARQUIVOS ____________________________________

   FUN->(dbSetRelation( "FILIAL", {|| Filial}, "Filial" ))

   FUN->(dbgotop())

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

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif

   qmensa("Imprimindo...")

   SITUA->(dbsetorder(3)) // ccusto + matricula
   SITUA->(dbgotop())

   if ! empty(cCENTRO)
      SITUA->(dbseek(cCENTRO))
   else
      cCENTRO_ATU := SITUA->Ccusto
   endif

   do while ! SITUA->(eof()) .and. qcontprn()     // condicao principal de loop

      if ! empty(cMATRICULA)
         if SITUA->Matricula <> cMATRICULA
            SITUA->(dbskip())
            loop
         endif
      endif

      if ! empty(cCENTRO)
         if SITUA->Ccusto <> cCENTRO
            SITUA->(dbskip())
            loop
         endif
      endif

      if ! FUN->(dbseek(SITUA->Matricula))
         SITUA->(dbskip())
         loop
      endif

      if ! DEPE->(dbseek(FUN->Matricula))
         SITUA->(dbskip())
         loop
      endif

      if ! empty(cFILIAL) .and. FUN->Filial <> cFILIAL
         SITUA->(dbskip())
         loop
      endif

      if ! qlineprn() ; return ; endif

      if XPAGINA == 0 .or. prow() > K_MAX_LIN
         qpageprn()
         qcabecprn(cTITULO,80)
         @ prow()+1,0 say "Matri. Nome Fun. / Nome Dep.          Sexo  Data.Nasc. Est. Civil/Parentesco"
         @ prow()+2,0 say "   CENTRO DE CUSTO --> " + SITUA->Ccusto + " " + iif(CCUSTO->(dbseek(SITUA->CCusto)),CCUSTO->Descricao,)
         @ prow()+1,0 say replicate("-",80)
      endif

      qmensa("Funcionario: "+FUN->Matricula+" / "+left(FUN->Nome,40))

      @ prow()+1,0  say XCOND1 + FUN->Matricula
      @ prow()  ,7  say left(FUN->Nome,30)
      @ prow()  ,39 say FUN->Sexo
      iif(FUN->Sexo=="M",nSEXOFM++,nSEXOFF++)
      @ prow()  ,44 say dtoc(FUN->Data_nasc)
      do case
         case FUN->Est_civil == "1"
              @ prow() ,57 say "SOLTEIRO(A)"
              nESTF1++
         case FUN->Est_civil == "2"
              nESTF2++
              @ prow() ,57 say "CASADO(A)"
         case FUN->Est_civil == "3"
              @ prow() ,57 say "DESQUITADO(A)"
              nESTF3++
         case FUN->Est_civil == "4"
              @ prow() ,57 say "DIVORCIADO(A)"
              nESTF4++
         case FUN->Est_civil == "5"
              @ prow() ,57 say "VIUVO(A)"
              nESTF5++
         case FUN->Est_civil == "6"
              @ prow() ,57 say "OUTROS"
              nESTF6++
      endcase

      nFUN++

      do while ! DEPE->(eof()) .and. DEPE->Matricula == FUN->Matricula

         @ prow()+1,7  say DEPE->Nome
         @ prow()  ,39 say DEPE->Sexo
         iif(DEPE->Sexo=="M",nSEXODM++,nSEXODF++)
         @ prow()  ,44 say dtoc(DEPE->Data_nasc)
         @ prow()  ,57 say f131c(DEPE->Parentesco)

         nDEPE++

         DEPE->(dbskip())

      enddo

      SITUA->(dbskip())

      if empty(cCENTRO) .and. cCENTRO_ATU <> SITUA->Ccusto
         @ prow()+1,0 say " TOTAL DE FUNCIONARIOS DO CENTRO........: " + transform(nFUN,"@R 9999")
         @ prow()+1,0 say " TOTAL DE DEPENDENTES  DO CENTRO........: " + transform(nDEPE,"@R 9999")
         nFUN := nDEPE := 0
         @ prow()+2,0 say "   CENTRO DE CUSTO --> " + iif(CCUSTO->(dbseek(SITUA->CCusto)),CCUSTO->Descricao,)
         cCENTRO_ATU := SITUA->Ccusto
      endif

   enddo

   @ prow()+1,0 say replicate("-",80)

   @ prow()+1,0 say "            TOTAIS"

   @ prow()+1,0 say "----------------------------------"
   @ prow()+1,0 say "FUNC. SEXO MASCULINO.........:" + transform(nSEXOFM,"@R 9999")
   @ prow()+1,0 say "FUNC. SEXO FEMININO..........:" + transform(nSEXOFF,"@R 9999")
   @ prow()+1,0 say "FUNC. EST. CIVIL (SOLTEIRO)..:" + transform(nESTF1,"@R 9999")
   @ prow()+1,0 say "FUNC. EST. CIVIL (CASADO)....:" + transform(nESTF2,"@R 9999")
   @ prow()+1,0 say "FUNC. EST. CIVIL (DESQUITADO):" + transform(nESTF3,"@R 9999")
   @ prow()+1,0 say "FUNC. EST. CIVIL (DIVORCIADO):" + transform(nESTF4,"@R 9999")
   @ prow()+1,0 say "FUNC. EST. CIVIL (VIUVO).....:" + transform(nESTF5,"@R 9999")
   @ prow()+1,0 say "FUNC. EST. CIVIL (OUTROS)....:" + transform(nESTF6,"@R 9999")
   @ prow()+1,0 say "DEPENDENTES SEXO MASCULINO...:" + transform(nSEXODM,"@R 9999")
   @ prow()+1,0 say "DEPENDENTES SEXO FEMININO....:" + transform(nSEXODF,"@R 9999")

   qstopprn()

   qmensa()

return
