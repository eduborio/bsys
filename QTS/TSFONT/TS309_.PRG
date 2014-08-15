/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE CONTAS A RECEBER/PAGAR
// OBJETIVO...: CONSULTA DE LANCAMENTOS RECEBIDOS
// ANALISTA...:
// PROGRAMADOR:
// INICIO.....: MARCO DE 1997
// OBS........:
// ALTERACOES.:
function ts309

#include "inkey.ch"
#include "setcurs.ch"

CCUSTO->(dbsetorder(4))

fu_abre_cli1()

// VIEW INICIAL _____________________________________________________________

RECEBIDO->(qview({{"Data_pagto/Recebido"          ,6},;
                  {"left(cliente,22)/Cliente"     ,9},;
                  {"f_309d()/Valor"               ,0},;
                  {"Fatura/Fatura"                ,5},;
                  {"f_309e()/Contabilizado"        ,0}},"P",;
                  {NIL,"f309a",NIL,NIL},;
                   NIL,"ESC/ALT-P/ALT-O/<C>onsulta/<E>xclusao/<A>ltera / <M>arca / <R>everte"))

//////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAGEM DO CLIENTE __________________________________________

function f_309e
 local cResult := "   "

 if RECEBIDO->Contabil == .T.
    cRESULT := "Sim"
 else
    cResult := "Nao"
 endif

return cResult

function f_309b
   CLI1->(dbseek(RECEBIDO->Cod_cli))
return left(CLI1->Razao,22)

//////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAGEM DE VALOR COM PICTURE ________________________________

function f_309c
return(transform(RECEBIDO->Valor,"@E 999,999.99"))

//////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAGEM DE VALOR COM PICTURE ________________________________

function f_309d
return(transform(RECEBIDO->Valor_liq,"@E 999,999.99"))

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function f309a
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO == "C"
      qlbloc(05,02,"B309A","QBLOC.GLO",1)
      qmensa(qabrev(cOPCAO,"C",{"Consulta..."}))
      i_consulta()
   endif


   if cOPCAO == "A"
      i_altera()
   endif

   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   if cOPCAO == "M" ; i_marcar() ; return ; endif

   if cOPCAO == "R" ; i_reverter() ; return ; endif

   setcursor(nCURSOR)
return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA ____________________________________

static function i_consulta

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO == "C"
      XNIVEL := 1
      qrsay ( XNIVEL++ , RECEBIDO->Codigo       )
      qrsay ( XNIVEL++ , RECEBIDO->Data_lanc    )
      qrsay ( XNIVEL++ , RECEBIDO->Cod_cli      ) ; CLI1->(dbseek(RECEBIDO->Cod_cli))
      qrsay ( XNIVEL++ , left(CLI1->Razao,40))
      qrsay ( XNIVEL++ , RECEBIDO->Centro       ) ; CCUSTO->(dbseek(RECEBIDO->Centro))
      qrsay ( XNIVEL++ , left(CCUSTO->Descricao,40))
      qrsay ( XNIVEL++ , RECEBIDO->Filial       ) ; FILIAL->(dbseek(RECEBIDO->Filial))
      qrsay ( XNIVEL++ , left(FILIAL->Razao,40))
      qrsay ( XNIVEL++ , RECEBIDO->Data_emiss   )
      qrsay ( XNIVEL++ , RECEBIDO->Data_pagto   )
      qrsay ( XNIVEL++ , RECEBIDO->Especie      ) ; ESPECIE->(dbseek(RECEBIDO->Especie))
      qrsay ( XNIVEL++ , left(ESPECIE->Descricao,13))
      qrsay ( XNIVEL++ , RECEBIDO->Serie        ) ; SERIE->(dbseek(RECEBIDO->Serie))
      qrsay ( XNIVEL++ , left(SERIE->Descricao,11))
      qrsay ( XNIVEL++ , RECEBIDO->Tipo_sub     ) ; TIPOCONT->(dbseek(RECEBIDO->Tipo_sub) )
      qrsay ( XNIVEL++ , left(TIPOCONT->Descricao,46))
      qrsay ( XNIVEL++ , RECEBIDO->Data_pagto    )

      qrsay ( XNIVEL++ , left(RECEBIDO->Historico,60))
      qrsay ( XNIVEL++ , RECEBIDO->Data_venc    )
      qrsay ( XNIVEL++ , RECEBIDO->Data_prorr   )
      qrsay ( XNIVEL++ , transform(RECEBIDO->Valor,"@E 9,999,999.99"     ))
      qrsay ( XNIVEL++ , RECEBIDO->Tipo_doc     ) ; TIPO_DOC->(dbseek(RECEBIDO->Tipo_doc))
      qrsay ( XNIVEL++ , TIPO_DOC->Descricao   )
      qrsay ( XNIVEL++ , RECEBIDO->Fatura       )
      qrsay ( XNIVEL++ , RECEBIDO->Duplicata    )
      qrsay ( XNIVEL++ , RECEBIDO->Cgm          ) ; CGM->(dbseek(RECEBIDO->Cgm))
      qrsay ( XNIVEL++ , left(CGM->Municipio,40))
      qrsay ( XNIVEL++ , RECEBIDO->Cod_Banco    ) ; BANCO->(Dbseek(RECEBIDO->Cod_banco))
      qrsay ( XNIVEL++ , BANCO->Descricao      )
      qrsay ( XNIVEL++ , RECEBIDO->Situacao     ) ; SITUA->(dbseek(RECEBIDO->Situacao))
      qrsay ( XNIVEL++ , left(SITUA->Descricao,28))
      qrsay ( XNIVEL++ , RECEBIDO->Data_cont    )
      qrsay ( XNIVEL++ , RECEBIDO->Vendedor     ) ; FUN->(dbseek(RECEBIDO->Vendedor))
      qrsay ( XNIVEL++ , left(FUN->Nome,40)    )
      qrsay ( XNIVEL++ , left(RECEBIDO->Observacao,59))

   endif

   qwait()

return

static function i_exclusao

   if qconf("Confirma exclus„o deste Recebimento ?")

      MOV_BANC->(dbsetorder(4))
      if MOV_BANC->(dbseek("RE"+RECEBIDO->Codigo))
         if MOV_BANC->(qrlock())
            MOV_BANC->(dbdelete())
            MOV_BANC->(qunlock())
         endif
      endif

      MOV_CAIX->(dbsetorder(2))
      if MOV_CAIX->(dbseek("RE"+RECEBIDO->Codigo))
         if MOV_CAIX->(qrlock())
            MOV_CAIX->(dbdelete())
            MOV_CAIX->(qunlock())
         endif
      endif


      if RECEBIDO->(qrlock())
         RECEBIDO->(dbdelete())
         RECEBIDO->(qunlock())
      else
         qm3()
      endif

   endif
return


static function i_reverter

   if qconf("Confirma reversao deste Recebimento ?")

      MOV_BANC->(dbsetorder(4))
      if MOV_BANC->(dbseek("RE"+RECEBIDO->Codigo))
         if MOV_BANC->(qrlock())
            MOV_BANC->(dbdelete())
            MOV_BANC->(qunlock())
         endif
      endif

      MOV_CAIX->(dbsetorder(2))
      if MOV_CAIX->(dbseek("RE"+RECEBIDO->Codigo))
         if MOV_CAIX->(qrlock())
            MOV_CAIX->(dbdelete())
            MOV_CAIX->(qunlock())
         endif
      endif


      if quse(XDRV_RB,"CONFIG",NIL,NIL,"CFGRB")
         if CFGRB->(qrlock())
            replace CFGRB->Cod_rec with CFGRB->Cod_rec + 1
            CFGRB->(Qunlock())
         endif
      endif

      quse(XDRV_RB,"RECEBER",NIL,NIL)


      if RECEBER->(qappend())
         RECEBER->(qpublicfields())
         RECEBER->(qinitfields())
         RECEBIDO->(qcopyfields())

         fCODIGO := strzero(CFGRB->Cod_rec,7)
         fDATA_PAGTO := ctod("")
         //fDATA_LANC  := date()
         RECEBER->(qreplacefields())

         if RECEBIDO->(qrlock())
            RECEBIDO->(dbdelete())
            RECEBIDO->(qunlock())
         else
            qm3()
         endif
      endif

      RECEBER->(dbclosearea())

      select RECEBIDO

   endif
return


static function i_marcar

      if RECEBIDO->(qrlock())
         if RECEBIDO->Contabil == .T.
            replace RECEBIDO->Contabil with .F.
         else
            replace RECEBIDO->Contabil with .T.
         endif
         RECEBIDO->(qunlock())
      else
         qm3()
      endif
      RECEBIDO->(dbcommit())

return

static function i_altera
local newValor := 0
local nLinha    := 0

  nLinha := row()

   qgetx(nLinha,38,@newValor,"@E 999,999.99")

   if RECEBIDO->(qrlock())
      replace  RECEBIDO->Valor_liq with newValor
      replace  RECEBIDO->Valor     with newValor
      RECEBIDO->(qunlock())
   endif

   MOV_BANC->(dbsetorder(4))
   if MOV_BANC->(dbseek("RE"+RECEBIDO->Codigo))
      if MOV_BANC->(qrlock())

         if MOV_BANC->Entrada > 0
            replace MOV_BANC->Entrada with newValor
         endif

         MOV_BANC->(qunlock())
      endif
   endif

   MOV_CAIX->(dbsetorder(2))
   if MOV_CAIX->(dbseek("RE"+RECEBIDO->Codigo))
      if MOV_CAIX->(qrlock())

         if MOV_CAIX->Entrada > 0
            replace MOV_CAIX->Entrada with newValor
         endif

         MOV_CAIX->(qunlock())
      endif
   endif


return

