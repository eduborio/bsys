
/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: FOLHA DE PAGAMENTO
// OBJETIVO...: MANUTENCAO DE VALORES DE TICKET POR FILIAL
// ANALISTA...: CARLOS EDUARDO RABELLO NUNES
// PROGRAMADOR: O MESMO
// INICIO.....: JANEIRO DE 1997
// OBS........:
// ALTERACOES.:

/////////////////////////////////////////////////////////////////////////////
// MANUTENCAO DE TICKET'S NO ARQUIVO FILIAL _________________________________

FILIAL->(qview({{"Codigo/C¢digo"                      ,1},;
                {"left(Razao,40)/Raz„o"               ,2},;
                {"transform(Ticket,'@E 99.99')/Ticket",0}},"P",;
                {"c105A",NIL,NIL,NIL},;
                 NIL,"ALT-P / ALT-O / <ENTER> Edita / <ESC>"))
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO DE CONTROLE PRINCIPAL ANTES DE PROCESSAR A TECLA ACIONADA _________

function c105a
   local nCURSOR := setcursor(1)
   qlbloc(12,05,"B105A","QBLOC.GLO",1)
   i_edicao()
   setcursor(nCURSOR)
return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA ____________________________________

static function i_edicao
   local nTICKET := FILIAL->Ticket

   XNIVEL := 1
   qrsay(XNIVEL++,FILIAL->Codigo)
   qrsay(XNIVEL++,left(FILIAL->Razao,40))

   qgetx(-1,0,@nTICKET,"@E 99.99")

   if FILIAL->(qrlock())
      replace FILIAL->Ticket with nTICKET
   else
      qm1()
   endif

return
