
/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: FOLHA DE PAGAMENTO
// OBJETIVO...: PROGRAMACAO DE FERIAS
// ANALISTA...: CARLOS EDUARDO RABELLO NUNES
// PROGRAMADOR: O MESMO
// INICIO.....: SETEMBRO DE 1994
// OBS........:
// ALTERACOES.:

// FAZ RELACIONAMENTO E ENTRA EM BROWSE _____________________________________

private nMESES

SITUA->(dbSetFilter({|| Anomes == XANOMES .and. Situacao <> "H" .and. Categoria <> "9" .and. ! Vinculo $ "HMN"},"Anomes == XANOMES .and. Situacao <> 'H' .and. Categoria <> '9' .and. ! Vinculo $ 'HMN'"))

SITUA->(dbgotop())

SITUA->(qview({{"Matricula/Matri."  ,1},;
               {"i_443a()/Nome"     ,2},;
               {"Di_ferias/Ini.Aq." ,0},;
               {"Df_ferias/Fim.Aq." ,0},;
               {"Pi_ferias/Ini.Fr." ,0},;
               {"Pf_ferias/Fim.Fr." ,0},;
               {"i_443b()/Venc." ,0}},"P",;
               {NIL,"i_443c",NIL,NIL},NIL,;
               "ALT-P, ALT-O, <A>ltera / <ESC>"))
return


/////////////////////////////////////////////////////////////////////////////
// RETORNA NOME DO FUNCIONARIO ______________________________________________

function i_443a
   FUN->(dbseek(SITUA->Matricula))
return left(FUN->Nome,18)

/////////////////////////////////////////////////////////////////////////////
// CALCULA MESES PARA VENCIMENTO ____________________________________________

function i_443b
   nMESES := XDATASYS-SITUA->Df_ferias
   if nMESES < 0
      nMESES := str(int(nMESES/30)+12,4)
   else
      nMESES := str(int(nMESES/30*-1)+12,4)
   endif
return nMESES

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ALTERAR A SITUACAO E O TIPO DE AFASTAMENTO ___________________

function i_443c
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))
   if cOPCAO $ XUSRA .and. cOPCAO == "A"
      qmensa("Entre com os dados...")
      i_alteracao()
   endif
   setcursor(nCURSOR)
return ""

/////////////////////////////////////////////////////////////////////////////
// EDICAO DA ALTERACAO ______________________________________________________

static function i_alteracao
   local dDI_FERIAS  := SITUA->Di_ferias
   local dDF_FERIAS  := SITUA->Df_ferias
   local dPI_FERIAS  := SITUA->Pi_ferias
   local dPF_FERIAS  := SITUA->Pf_ferias
   local sBLOC       := qlbloc("B443B","QBLOC.GLO")
   local nLIN        := row()
   cCORANTERIOR := SetColor()
   SetColor("B/W")

   qmensa("Alterar... <ESC - Cancela>")

   qgetx(nLIN,28,@dDI_FERIAS)

   if lastkey()==27; return; Endif

   // SE DATA FINAL DO PERIODO ESTIVER VAZIO, ENTAO SUGERE 1 ANO ____________

   if empty(dDF_FERIAS) .and. ! empty(dDI_FERIAS)
      dDF_FERIAS := strzero(day(dDI_FERIAS),2) + "/"
      dDF_FERIAS += strzero(month(dDI_FERIAS),2) + "/"
      dDF_FERIAS += right(strzero(year(dDI_FERIAS)+1,4),2)
      dDF_FERIAS := ctod(dDF_FERIAS) - 1
   endif

   qgetx(nLIN,39,@dDF_FERIAS)

   if lastkey()==27; return; Endif

   qgetx(nLIN,50,@dPI_FERIAS)

   if lastkey()==27; return; Endif

   // SE DATA FINAL DAS FERIAS ESTIVER VAZIA, ENTAO SUGERE 30 DIAS __________

   if empty(dPF_FERIAS) .and. ! empty(dPI_FERIAS)
      dPF_FERIAS := dPI_FERIAS + 29
   endif

   qgetx(nLIN,61,@dPF_FERIAS)

   if lastkey()==27; return; Endif

   // CONFIRMA E GRAVA AS ALTERACOES ________________________________________

   if qconf("Confirma esta altera‡„o ?")
      if SITUA->(qrlock())
         replace SITUA->Di_ferias  with dDI_FERIAS
         replace SITUA->Df_ferias  with dDF_FERIAS
         replace SITUA->Pi_ferias  with dPI_FERIAS
         replace SITUA->Pf_ferias  with dPF_FERIAS
         SITUA->(qunlock())
      else
         qm2()
      endif
   endif
   SetColor(cCORANTERIOR)
return

