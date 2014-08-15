 /////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE CONTAS A RECEBER
// OBJETIVO...: CONFIGURACAO DE DIRETORIOS DOS BANCOS PARA TRANSMISSAO
// ANALISTA...:
// PROGRAMADOR: LUCINEIDE VILAR POSSEBOM
// INICIO.....: ABRIL DE 1997
// OBS........:
// ALTERACOES.:
function rb802

BANCO->(qview({{"Codigo/C¢digo"                          ,0},;
               {"Banco/Banco"                            ,1},;
               {"left(Descricao,30)/Nome"                ,2},;
               {"c802b()/Nr. Conta"                      ,0},;
               {"Agencia/Agˆncia"                        ,0},;
               {"alltrim(Caminho)/Diretorio"             ,0}},"P",;
               {NIL,"c802a",NIL,NIL},;
                NIL,"<D>iretorio"))

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function c802a
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))
   if cOPCAO $ "D"
      qlbloc(13,12,"B802A","QBLOC.GLO",1)
      i_diretorio()
   endif

   setcursor(nCURSOR)
return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA RETRNAR A MASCARA DA CONTA ___________________________________

function c802b
return transform(BANCO->Conta,"@R 999999-9")

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA DEFINIR DIRETORIO PARA BANCO ___________________________________

function i_diretorio

   //////////////////////////////////////////////////////////////////////////
   // DECLARACAO E INICIALIZACAO DE VARIAVEIS E RELACAO DE ARQUIVOS _________

   local lCONF   := .F.
   local aEDICAO := {}
   local bESCAPE   := {||(XNIVEL==1 .and. !XFLAG) .or. lastkey()==27}

   private cDIRETORIO := space(30)

   cDIRETORIO := BANCO->Caminho

   // CRIACAO DO VETOR DE BLOCOS _______________________________________________

   aadd(aEDICAO,{{ || qgetx(-1,0,@cDIRETORIO ,"@!"         )}, "DIRETORIO"  })
   aadd(aEDICAO,{{ || lCONF := qconf("Confirma Diretorio ?")}, NIL          })

   do while .T.

      XNIVEL  := 1

      // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

      do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
         eval ( aEDICAO [XNIVEL,1] )
         if eval ( bESCAPE ) ; return ; endif
         if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
         iif ( XFLAG , XNIVEL++ , XNIVEL-- )
      enddo

      if ! lCONF ; return ; endif

      if BANCO->(qrlock())
         replace BANCO->Caminho with cDIRETORIO
         BANCO->(qunlock())
      endif
      exit

   enddo

return .T.

function i_critica
return .T.

