/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE CONTAS A PAGAR
// OBJETIVO...: CONSULTA POR CENTRO DE CUSTO
// ANALISTA...:
// PROGRAMADOR: LUCINEIDE VILAR POSSEBOM
// INICIO.....: FEVEREIRO DE 1997
// OBS........:
// ALTERACOES.:

function cp304

CCUSTO->(qview({{"Codigo/C�digo"               ,1},;
                {"left(Descricao,45)/Descri��o",2}},"P",;
                {NIL,"c304a",NIL,NIL},;
                 NIL,"<ESC>-Sai/<C>onsulta"))


/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function c304a

   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO $ "C"
      qlbloc(12,9,"B304A","QBLOC.GLO",1)
      i_edicao()
   endif

   setcursor(nCURSOR)

return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA ____________________________________

static function i_edicao
   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO ==  "C"

      XNIVEL := 1

      qrsay(XNIVEL++,CCUSTO->Codigo)
      qrsay(XNIVEL++,CCUSTO->Descricao)

      qwait()

   endif

return

/////////////////////////////////////////////////////////////////////////////
// CRITICA DE EDICAO ________________________________________________________

static function i_critica ( cCAMPO )

   if ! XFLAG ; return .T. ; endif

   do case

   endcase

return .T.

return
