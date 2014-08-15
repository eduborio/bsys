/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: FOLHA DE PAGAMENTO
// OBJETIVO...: PROGRAMACAO DE FERIAS
// ANALISTA...: CARLOS EDUARDO RABELLO NUNES
// PROGRAMADOR: O MESMO
// INICIO.....: MAIO DE 1995
// OBS........:
// ALTERACOES.:

#define K_MAX_LIN 52

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG) .or. empty(nQUANT)}

private cCENTRO                // centro de custo para filtro
private cFILIAL                // filial para filtro
private aEDICAO := {}          // vetor para os campos de entrada de dados
private nQUANT                 // quantidade de meses a vencer
private nMESES
private nMES

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qgetx(-1,0,@nQUANT,"99") }        , "QUANT"     })
aadd(aEDICAO,{{ || view_ccusto(-1,0,@cCENTRO)}       , "CENTRO"    })
aadd(aEDICAO,{{ || NIL },NIL}) // descricao do centro
aadd(aEDICAO,{{ || view_filia(-1,0,@cFILIAL)}        , "FILIAL"    })
aadd(aEDICAO,{{ || NIL },NIL}) // descricao do filial

do while .T.

   qlbloc(5,0,"B542A","QBLOC.GLO")

   XNIVEL  := 1
   XFLAG   := .T.
   cCENTRO := space(8)
   cFILIAL := space(4)
   nQUANT  := 0

   // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; dbcloseall() ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // INDEXA ANTES DE INICIAR O RELATORIO ___________________________________

   qmensa("Aguarde cria‡„o de ¡ndice tempor rio...")

   //select SITUA

   //index on dtos(Df_ferias) to (XDRV_RH+"INDICE.TMP") ;
   //   for i_ret_meses() <= nQUANT .and. qgirabarra()

   //dbgotop()

   // ACIONA ROTINA DE IMPRESSAO ____________________________________________

   i_impressao()

   // FECHA INDICE TEMPORARIO E APAGA DO DISCO ______________________________

   //set index to

   //erase (XDRV_RH+"INDICE.TMP")

enddo

static function i_ret_meses
   nMESES := XDATASYS-SITUA->Df_ferias
   if nMESES < 0
      nMESES := int(nMESES/30)+12
   else
      nMESES := int(nMESES/30*-1)+12
   endif
return nMESES

/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA _____________________________________________

static function i_critica ( cCAMPO )
   do case
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
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impressao
local zCENTRO := ""
local lImprime := .F.
local nFUN := 0

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________
   private nVENC := 0
   if ! qinitprn() ; return ; endif
   SITUA->(dbSetFilter({|| Anomes == XANOMES .and. ! Situacao $ "HD"},"Anomes == XANOMES .and. ! Situacao $ 'HD'"))

   SITUA->(dbsetorder(3))
   SITUA->(dbgotop())
   zCENTRO := SITUA->Ccusto

   do while ! SITUA->(eof()) .and. qcontprn()     // condicao principal de loop
      FUN->(dbseek(SITUA->Matricula))

      lImprime := .T.

      if FUN->Data_adm > qfimMes(XDATASYS)
         limprime := .F.
      endif

      qmensa("Funcionario: "+FUN->Matricula+" / "+left(FUN->Nome,30))

      if ! qlineprn() ; return ; endif

      if XPAGINA == 0 .or. prow() > K_MAX_LIN
         @ prow(),pcol() say XCOND0
         qpageprn()
         qcabecprn("PROGRAMACAO DE FERIAS",80)
         if ! empty(cCENTRO)
            @ prow()+2,0 say padc("Centro de Custo: " + alltrim(CCUSTO->Codigo) + " - " + CCUSTO->Descricao,80)
         endif
         if ! empty(cFILIAL)
            @ prow()+2,0 say padc("Filial: " + FILIAL->Codigo + " - " + FILIAL->Razao,80)
         endif
         @ prow()+2,0 say XCOND1 + "MATR.   NOME DO FUNCIONARIO      DATA ADMISSAO     ------ PERIODO AQUISITIVO ------      ---- FERIAS PREVISTAS PARA: ----      M.T. PRAZO"
         @ prow()+1,0 say replicate("-",135)
      endif

      nVENC := XDATASYS-SITUA->Df_ferias
      if nVENC < 0
         nVENC := str(int(nVENC/30)+12,4)
      else
         nVENC := str(int(nVENC/30*-1)+12,4)
      endif

      if lIMPRIME
         nFUN++
         @ prow()+1,0        say XCOND1 + FUN->Matricula
         @ prow()  ,pcol()+2 say left(FUN->Nome,25)
         @ prow()  ,pcol()+1 say dtoc(FUN->Data_adm)
         @ prow()  ,pcol()+1 say XCOND0 + dtoc(SITUA->Di_ferias) + " a"
         @ prow()  ,pcol()+1 say dtoc(SITUA->Df_ferias)
         @ prow()  ,pcol()+1 say dtoc(SITUA->Pi_ferias) + " a"
         @ prow()  ,pcol()+1 say dtoc(SITUA->Pf_ferias)
         @ prow()  ,pcol()+1 say XCOND1 + nVENC//str((int(XDATASYS-SITUA->Di_ferias)/30),3)
         @ prow()  ,pcol()+1 say nVENC//str((int(XDATASYS-SITUA->Di_ferias)/30),3)
         nVENC := 0
      endif

      SITUA->(dbskip())

      if SITUA->Ccusto != zCentro
         CCUSTO->(dbseek(zCentro))
         if nFUN > 0
            @ prow()+1,0        say XCOND1 + replicate("-",135)
            @ prow()+1,0        say XCOND1 + "Centro de Custo.: "+CCUSTO->Descricao
            @ prow()+1,0        say ""
            zCentro := SITUA->CCusto
            nFUN := 0
         endif
      endif

   enddo

   qstopprn()

   qmensa()

return

