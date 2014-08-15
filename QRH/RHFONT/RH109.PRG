
/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: FOLHA DE PAGAMENTO
// OBJETIVO...: MANUTENCAO DE VALORES-PREMIO DE PRODUCAO
// ANALISTA...: CARLOS EDUARDO RABELLO NUNES
// PROGRAMADOR: O MESMO
// INICIO.....: JANEIRO DE 1997
// OBS........:
// ALTERACOES.:

private cTIPOVAL := "1"

if empty(cTIPOVAL := qachoice(12,29,qlbloc("B109B","QBLOC.GLO"),cTIPOVAL,1)) ; return ; endif

if cTIPOVAL == "1"
   FUN->(dbSetFilter({|| Situacao != 'H' .and. Filial != '0001'},"Situacao != 'H' .and. Filial != '0001'"))
   FUN->(qview({{"Matricula/Matr¡cula",1},;
                {"left(Nome,30)/Nome"          ,2}},"P",;
                {"c109a",NIL,NIL,NIL},;
                 NIL,"<ESC> / ALT-P / ALT-O / <ENTER> para editar"))
else
   FILIAL->(dbSetFilter({|| Codigo != '0001'},"Codigo != '0001'"))
   FILIAL->(qview({{"Codigo/C¢digo",1},;
                   {"Razao/Raz„o"  ,2}},"P",;
                   {"c109b",NIL,NIL,NIL},;
                    NIL,"<ESC> / ALT-P / ALT-O / <ENTER> para editar"))
endif

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO PARA FUNCIONARIOS ______________

function c109a
   local nCURSOR := setcursor(1)
   qlbloc(10,05,"B109C","QBLOC.GLO",1)
   i_edicao1()
   setcursor(nCURSOR)
return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO PARA FILIAIS ___________________

function c109b
   local nCURSOR := setcursor(1)
   qlbloc(11,06,"B109D","QBLOC.GLO",1)
   i_edicao2()
   setcursor(nCURSOR)
return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA QUANDO FUNCIONARIOS ________________

static function i_edicao1
   local aEDICAO1  := {}
   local bESCAPE   := {|| lastkey() == 27}
   local cVOL_CONC := FUN->Vol_conc
   local cVOL_PLAS := FUN->Vol_plas
   local cVOL_BOMB := FUN->Vol_bomb

   // MONTA DADOS NA TELA ___________________________________________________

   XNIVEL := 1
   qsay(11,18,FUN->Matricula)
   qsay(11,27,left(FUN->Nome,30))
   qrsay(XNIVEL++,cVOL_CONC,"@E 999,999.99")
   qrsay(XNIVEL++,cVOL_PLAS,"@E 999,999.99")
   qrsay(XNIVEL++,cVOL_BOMB,"@E 999,999.99")

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO1,{{ || qgetx(-1,0,@cVOL_CONC,"@E 999,999.99") },"VOL_CONC" })
   aadd(aEDICAO1,{{ || qgetx(-1,0,@cVOL_PLAS,"@E 999,999.99") },"VOL_PLAS" })
   aadd(aEDICAO1,{{ || qgetx(-1,0,@cVOL_BOMB,"@E 999,999.99") },"VOL_BOMB" })

   // INICIALIZACAO DA EDICAO _______________________________________________

   XNIVEL := 1
   XFLAG  := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO1)
      eval ( aEDICAO1 [XNIVEL,1] )
      if eval ( bESCAPE ) ; return ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if FUN->(qrlock())
      replace FUN->Vol_conc with cVOL_CONC
      replace FUN->Vol_plas with cVOL_PLAS
      replace FUN->Vol_bomb with cVOL_BOMB
      FUN->(qunlock())
   else
      qm2()
   endif

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA QUANDO FILIAIS _____________________

static function i_edicao2
   local aEDICAO2  := {}
   local bESCAPE   := {|| lastkey() == 27}
   local cPR_MEDIO := FILIAL->Pr_medio
   local cPR_PLAST := FILIAL->Pr_plast
   local cNUM_VB   := FILIAL->Num_vb
   local cPR_MCC   := FILIAL->Pr_mcc
        
   // MONTA DADOS NA TELA __________________________________________________

   XNIVEL := 1
   qsay(12,16,FILIAL->Codigo)
   qsay(12,32,left(FILIAL->Razao,40))
   qrsay(XNIVEL++,cPR_MEDIO,"@E 9,999.99")
   qrsay(XNIVEL++,cPR_PLAST,"@E 9,999.99")
   qrsay(XNIVEL++,cNUM_VB  ,"@E 99")
   qrsay(XNIVEL++,cPR_MCC  ,"@E 9,999.99")
   
   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO2,{{ || qgetx(-1,0,@cPR_MEDIO,"@E 9,999.99") },"PR_MEDIO" })
   aadd(aEDICAO2,{{ || qgetx(-1,0,@cPR_PLAST,"@E 9,999.99") },"PR_PLAST" })
   aadd(aEDICAO2,{{ || qgetx(-1,0,@cNUM_VB  ,"@E 99"      ) },"NUM_VB"   })
   aadd(aEDICAO2,{{ || qgetx(-1,0,@cPR_MCC  ,"@E 9,999.99") },"PR_MCC"   })
   
   XNIVEL := 1
   XFLAG  := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO2)
      eval ( aEDICAO2 [XNIVEL,1] )
      if eval ( bESCAPE ) ;  return ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if FILIAL->(qrlock())
      replace FILIAL->Pr_medio with cPR_MEDIO
      replace FILIAL->Pr_plast with cPR_PLAST
      replace FILIAL->Num_vb   with cNUM_VB
      replace FILIAL->Pr_mcc   with cPR_MCC
      FILIAL->(qunlock())
   else
      qm2()
   endif

return
