/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: FOLHA DE PAGAMENTO
// OBJETIVO...: RELACAO DE FUNCIONARIOS POR CCUSTO
// ANALISTA...: EDUARDO AUGUSTO BORIO
// PROGRAMADOR: O MESMO
// INICIO.....: ABRIL DE 2002
// OBS........:
// ALTERACOES.:

#define K_MAX_LIN 60

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG) .or. empty(cORDEM)}

private sBLOCO1 := qlbloc("B512B","QBLOC.GLO") // ordem de impressao

private nTOTAL                 // total
private cTITULO                // titulo
private cORDEM                 // ordem de impressao (matricula/nome)
private cCENTRO                // centro de custo para filtro
private cFILIAL                // filial para filtro
private aEDICAO := {}          // vetor para os campos de entrada de dados

//SITUA->(dbSetFilter({|| Anomes == XANOMES},"Anomes == XANOMES"))

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qesco(-1,0,@cORDEM,sBLOCO1) }     , "ORDEM"     })
aadd(aEDICAO,{{ || view_ccusto(-1,0,@cCENTRO)}       , "CENTRO"    })
aadd(aEDICAO,{{ || NIL },NIL}) // descricao do centro
aadd(aEDICAO,{{ || view_filia(-1,0,@cFILIAL)}        , "FILIAL"    })
aadd(aEDICAO,{{ || NIL },NIL}) // descricao do filial

do while .T.

   qlbloc(5,0,"B511A","QBLOC.GLO")
   XNIVEL  := 1
   XFLAG   := .T.
   cORDEM  := " "
   cCENTRO := space(8)
   cFILIAL := space(4)

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
           qrsay(XNIVEL,qabrev(cORDEM,"MN",{"Matricula","Nome"}))
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

   cTITULO = "RELACAO DE FUNCIONARIO POR CENTRO DE CUSTO "
   cTITULO += upper(qnomemes(month(XDATASYS))) + "/" + str(year(XDATASYS),4)

   // SELECIONA ORDEM DO ARQUIVO CADFUN _____________________________________

   //do case
   //   case cORDEM == "M" ; FUN->(dbsetorder(01)) // matricula
   //   case cORDEM == "N" ; FUN->(dbsetorder(02)) // nome
   //endcase

   qmensa()

   // ESTABELECE RELACOES ENTRE ARQUIVOS ____________________________________


   FUN->(dbgotop())

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impressao
local zCentro := ""
local nFUN := 0

   local nVALMS := nVALFE := nVALDT :=nTOTMS := nFUN := nTOTDT := 0
   local nTT_BASEMS := nTT_BASEFE := nTT_BASEDT := 0
   local cPIC   := "@E 999,999.99"

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif

   SITUA->(Dbsetfilter({|| Anomes == XANOMES .and. ! Situacao $ "HD"}))
   SITUA->(dbsetorder(3))
   SITUA->(dbgotop())
   zCentro := SITUA->Ccusto

   do while ! SITUA->(eof()) // condicao principal de loop

      if XPAGINA == 0 .or. prow() > K_MAX_LIN
         qpageprn()
         qcabecprn(cTITULO,80)

         @ prow()+1,0 say XCOND1 + "MAT.    NOME                             CARGO                                        SALARIO       ADMISSAO" + XCOND0
         @ prow()+1,0 say replicate("-",80)
      endif

      @ prow()+1,0        say XCOND1 + SITUA->Matricula
      FUN->(dbseek(SITUA->Matricula))
      @ prow()  ,pcol()+2 say left(FUN->Nome,30)
      CARGO->(Dbseek(SITUA->Cargo))
      @ prow()  ,pcol()+2 say CARGO->Descricao
      @ prow()  ,pcol()+3 say SITUA->Salario  picture cPIC
      @ prow()  ,pcol()+4 say dtoc(FUN->Data_adm)
      nFUN++

      SITUA->(dbskip())

      if SITUA->Ccusto != zCentro
         if nFUN > 0
            CCUSTO->(dbseek(zCentro))
            @ prow()+1, 00 say replicate("-",80)
            @ prow()+1, 00 say "Centro de Custo.: "+left(CCUSTO->Descricao,30)
            @ prow()+1, 00 say ""
            nFUN:=0
            zCEntro := SITUA->CCusto
         endif
      endif

   enddo

   qstopprn()

   qmensa()

return



