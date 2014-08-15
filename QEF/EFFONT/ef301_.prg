/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE ESCRITA FISCAL
// OBJETIVO...: CONSULTA POR FILIAL
// ANALISTA...:
// PROGRAMADOR:
// INICIO.....: JANEIRO DE 1997
// OBS........:
// ALTERACOES.:
function ef301

FILIAL->(qview({{"Codigo/C¢digo"       ,1},;
              {"left(Razao,25)/Raz„o"  ,2},;
              {"busca_mun()/Municipio" ,2}},"P",;
              {NIL,"c301a",NIL,NIL},;
              NIL,"<ESC>-Sai/<C>onsulta"))


/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function c301a

   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO $ "C"
      qlbloc(11,1,"B301A","QBLOC.GLO",1)
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

      qrsay(XNIVEL++,FILIAL->Codigo)
      qrsay(XNIVEL++,FILIAL->Razao); CGM->(dbseek(FILIAL->Cgm))
      qrsay(XNIVEL++,CGM->Municipio)

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
