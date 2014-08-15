/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE TESOURARIA
// OBJETIVO...: CONCILIACAO BANCARIA
// ANALISTA...: LUCINEIDE VILAR POSSEBOM
// PROGRAMADOR: LUCINEIDE VILAR POSSEBOM
// INICIO.....: MARCO DE 1998
// OBS........:
// ALTERACOES.:   
function ts406

#include "inkey.ch"
#include "setcurs.ch"

BANCO->(Dbsetorder(3)) // codigo gerado

/////////////////////////////////////////////////////////////////////////////
// VIEW PRINCIPAL ___________________________________________________________

// FILTRO COM OS LANCAMENTOS PARA CONCILIACAO _______________________________
qmensa("Aguarde, Preparando Arquivo Para Concilia‡„o ")
select MOV_BANC
set filter to MOV_BANC->Concilia $ "01"
qmensa("")

MOV_BANC->(qview({{"i_406b()/Banco"                   ,3},;
                  {"left(Historico,15)/Hist¢rico"     ,0},;
                  {"Data/Data"                        ,0},;
                  {"i_406c()/Saida"                   ,0},;
                  {"i_406d()/Entrada"                 ,0},;
                  {"i_406e()/Conc."                   ,0}},;
                  "05002379",;
                  {NIL,"i_406a",NIL,NIL},;
                  NIL,;
                  "<Esc> / <C>onfirma  <Espa‡o> Concilia/Desconcilia"))
return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAR NOME DO BANCO ________________________________________

function i_406b
  BANCO->(Dbseek(MOV_BANC->Cod_banco))
return left(BANCO->Descricao,15)

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAR VALORES COM PICTURE _________________________________

function i_406c
return transform(MOV_BANC->Saida,"@R 9,999,999.99")

function i_406d
return transform(MOV_BANC->Entrada,"@R 9,999,999.99")


/////////////////////////////////////////////////////////////////////////////
// IMPRIME MARCA NA TELA SE CONCILIADO ______________________________________

function i_406e
   do case
      case MOV_BANC->Concilia == "0" ; return "Nao"
      case MOV_BANC->Concilia == "1" ; return "Sim"
   endcase
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO DE CONTROLE PRINCIPAL ANTES DE PROCESSAR A TECLA ACIONADA _________

function i_406a
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))
   if cOPCAO $ "C "+chr(K_DEL)
      i_processa_acao()
   endif
   setcursor(nCURSOR)
return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO DE BROWSE _________________________________________________________

static function i_processa_acao

   local zTMP            // variavel temporaria
   local nVALOR          // para editar o valor
   local nDESCP          // para edicar o descont
   local cEVENTO         // para editar o evento

   do case

      case cOPCAO == " "        ; i_concilia()    // Concilia ou Desconcilia
      case cOPCAO == "C"        ; i_confirma()    // Confirma e sai desta opcao

   endcase

   dbunlockall()

return

/////////////////////////////////////////////////////////////////////////////
// MARCA PARA CONCILIACAO DEFINITIVA QDO CONFIRMADA _________________________

static function i_concilia

   do case
      case MOV_BANC->Concilia == "1"
           // DESMARCA CONCILIACAO __________________________________________
           if MOV_BANC->(qrlock())
              replace MOV_BANC->Concilia with "0"
           else
              qm1()
           endif
      case MOV_BANC->Concilia == "0"
           // MARCA CONCILIACAO _____________________________________________
           if MOV_BANC->(qrlock())
              replace MOV_BANC->Concilia with "1"
           else
              qm1()
           endif
   endcase

return

/////////////////////////////////////////////////////////////////////////////
// CONCILIA TODOS OS REGISTROS MARCADOS EM DEFINITIVO _______________________

static function i_confirma

   if ! qconf("Confirma concilia‡„o dos Documentos Marcados ","B")
      return
   endif

   MOV_BANC->(dbgotop())

   do while ! MOV_BANC->(eof())
      qmensa("Aguarde confirmando concilia‡”es")
      if MOV_BANC->Concilia == "1"
         if MOV_BANC->(qrlock())
            replace MOV_BANC->Concilia with "2"
            MOV_BANC->(dbskip())
         endif
      else
         MOV_BANC->(dbskip())
      endif

   enddo

qmensa("Concili‡„o Ok ")

return
