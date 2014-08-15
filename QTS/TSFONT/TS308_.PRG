/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE CONTAS A RECEBER/PAGAR
// OBJETIVO...: CONSULTA DE LANCAMENTOS PAGOS
// ANALISTA...:
// PROGRAMADOR:
// INICIO.....: MARCO DE 1997
// OBS........:
// ALTERACOES.:
function ts308

#include "inkey.ch"
#include "setcurs.ch"

CCUSTO->(dbsetorder(4))

// VIEW INICIAL _____________________________________________________________

PAGOS->(qview({{"PAGOS->Data_venc/Vencimento"         ,2},;
               {"PAGOS->Data_pagto/Pagamento"         ,5},;
               {"left(PAGOS->Fornec,19)/Fornecedor"   ,9},;
               {"f_308c()/    Valor"           ,4},;
               {"left(PAGOS->Fatura,6)/Fatura"  ,5},;
               {"f_308tip()/TIPO"                ,0},;
               {"f_308mov()/MOV"                ,0}},"P",;
               {NIL,"f308a",NIL,NIL},;
                NIL,"ESC/ALT-P/ALT-O/<C>onsulta"))

//////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAGEM DO FORNECEDOR _______________________________________

function f_308b
   FORN->(dbseek(PAGOS->Cod_forn))
return left(FORN->Razao,22)


function f_308tip
local cResult := " "

  do case
     case PAGOS->Tipo == "1"
          cResult := "Cheque"

     case PAGOS->Tipo == "2"
          cResult := "Ch.Pre"

     case PAGOS->Tipo == "3"
          cResult := "Deb.CC"

     case PAGOS->Tipo == "4"
          cResult := "Cop.Ch"

     case PAGOS->Tipo == "5"
          cResult := "Ord Pg"

     case PAGOS->Tipo == "6"
          cResult := "Espec."

     case PAGOS->Tipo == "7"
          cResult := "OnLine"

  endcase

return cResult


function f_308mov
local cResult := "N"
   MOV_BANC->(dbsetorder(4))
   if MOV_BANC->(dbseek("PG"+PAGOS->Codigo))
      cRESULT := "S"
   endif

   MOV_CAIX->(dbsetorder(2))
   if MOV_CAIX->(dbseek("PG"+PAGOS->Codigo))
      cRESULT := "S"
   endif
return cResult


//////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAGEM DE VALOR COM PICTURE ________________________________

function f_308c
return(transform(PAGOS->Valor,"@E 9,999,999.99"))

function f_308forn
  FORN->(dbseek(left(MOV_BANC->Fornec_cod,5)))
return left(FORN->Razao,30)


/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function f308a
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))


   if cOPCAO == "A"
      i_altera()
   endif

   if cOPCAO == "B"
      i_ver_mov_banc()
   endif

   if cOPCAO == "X"
      i_ver_mov_caix()
   endif

   if cOPCAO == "U"
      gera_mov()
   endif


   if cOPCAO == "D"
      i_datapagto()
   endif


   if cOPCAO $ "C"
      qlbloc(05,02,"B308A","QBLOC.GLO",1)
      qmensa(qabrev(cOPCAO,"C",{"Consulta..."}))
      i_consulta()
   endif

   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   setcursor(nCURSOR)
return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA ____________________________________

static function i_consulta

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO == "C"
      XNIVEL := 1

      qrsay ( XNIVEL++ , PAGOS->Codigo       )
      qrsay ( XNIVEL++ , PAGOS->Data_lanc    )
      qrsay ( XNIVEL++ , PAGOS->Cod_forn     ) ; FORN->(dbseek(PAGOS->Cod_forn))
      qrsay ( XNIVEL++ , left(FORN->Razao,40))
      qrsay ( XNIVEL++ , PAGOS->Centro       ) ; CCUSTO->(dbseek(PAGOS->Centro))
      qrsay ( XNIVEL++ , left(CCUSTO->Descricao,40))
      qrsay ( XNIVEL++ , PAGOS->Filial       ) ; FILIAL->(dbseek(PAGOS->Filial))
      qrsay ( XNIVEL++ , left(FILIAL->Razao,40))
      qrsay ( XNIVEL++ , PAGOS->Data_emiss   )
      qrsay ( XNIVEL++ , PAGOS->Cod_veic     ) ; VEICULOS->(dbseek(PAGOS->Cod_veic))
      qrsay ( XNIVEL++ , left(VEICULOS->Descricao,13))
      qrsay ( XNIVEL++ , PAGOS->Cod_eqpto    ) ; EQUIPTO->(dbseek(PAGOS->Cod_eqpto))
      qrsay ( XNIVEL++ , EQUIPTO->Descricao  )
      qrsay ( XNIVEL++ , PAGOS->Especie      ) ; ESPECIE->(dbseek(PAGOS->Especie))
      qrsay ( XNIVEL++ , left(ESPECIE->Descricao,13))
      qrsay ( XNIVEL++ , PAGOS->Serie        ) ; SERIE->(dbseek(PAGOS->Serie))
      qrsay ( XNIVEL++ , left(SERIE->Descricao,11))
      qrsay ( XNIVEL++ , PAGOS->Tipo_sub     ) ; TIPOCONT->(dbseek(PAGOS->Tipo_sub) )
      qrsay ( XNIVEL++ , left(TIPOCONT->Descricao,20))
      qrsay ( XNIVEL++ , PAGOS->Data_pagto    )

      qrsay ( XNIVEL++ , left(PAGOS->Historico,60))
      qrsay ( XNIVEL++ , PAGOS->Data_venc    )
      qrsay ( XNIVEL++ , PAGOS->Data_prorr   )
      qrsay ( XNIVEL++ , transform(PAGOS->Valor,"@E 9,999,999.99"     ))
      qrsay ( XNIVEL++ , PAGOS->Tipo_doc     ) ; TIPO_DOC->(dbseek(PAGOS->Tipo_doc))
      qrsay ( XNIVEL++ , TIPO_DOC->Descricao   )
      qrsay ( XNIVEL++ , PAGOS->Fatura       )
      qrsay ( XNIVEL++ , PAGOS->Duplicata    )
      qrsay ( XNIVEL++ , PAGOS->Cgm          ) ; CGM->(dbseek(PAGOS->Cgm))
      qrsay ( XNIVEL++ , left(CGM->Municipio,40))
      qrsay ( XNIVEL++ , PAGOS->Cod_Banco    ) ; BANCO->(Dbseek(PAGOS->Cod_banco))
      qrsay ( XNIVEL++ , BANCO->Descricao      )
      qrsay ( XNIVEL++ , PAGOS->Situacao     ) ; SITUA->(dbseek(PAGOS->Situacao))
      qrsay ( XNIVEL++ , left(SITUA->Descricao,28))
      qrsay ( XNIVEL++ , PAGOS->Data_cont    )
      qrsay ( XNIVEL++ , left(PAGOS->Observacao,59))

   endif

   qwait()

return

static function i_exclusao
   if qconf("Confirma exclus„o deste Pagamento ?")

      MOV_BANC->(dbsetorder(4))
      if MOV_BANC->(dbseek("PG"+PAGOS->Codigo))
         if MOV_BANC->(qrlock())
            MOV_BANC->(dbdelete())
            MOV_BANC->(qunlock())
         endif
      endif

      MOV_CAIX->(dbsetorder(2))
      if MOV_CAIX->(dbseek("PG"+PAGOS->Codigo))
         if MOV_CAIX->(qrlock())
            MOV_CAIX->(dbdelete())
            MOV_CAIX->(qunlock())
         endif
      endif


      if PAGOS->(qrlock())
         PAGOS->(dbdelete())
         PAGOS->(qunlock())
      else
         qm3()
      endif
   endif
return

static function i_altera
local newValor := 0
local nLinha    := 0

  nLinha := row()

   qgetx(nLinha,38,@newValor,"@E 999,999.99")

   if newValor > 0
      if PAGOS->(qrlock())
         replace  PAGOS->Valor_liq with newValor
         replace  PAGOS->Valor     with newValor
         PAGOS->(qunlock())
      endif

      MOV_BANC->(dbsetorder(4))
      if MOV_BANC->(dbseek("PG"+PAGOS->Codigo))
         if MOV_BANC->(qrlock())

            if MOV_BANC->Saida > 0
               replace MOV_BANC->Saida with newValor
            endif

            MOV_BANC->(qunlock())
         endif
      endif

      MOV_CAIX->(dbsetorder(2))
      if MOV_CAIX->(dbseek("PG"+PAGOS->Codigo))
         if MOV_CAIX->(qrlock())

            if MOV_CAIX->Entrada > 0
               replace MOV_CAIX->Entrada with newValor
            endif

            MOV_CAIX->(qunlock())
         endif
      endif
   endif


return


static function i_dataPagto
local newValor := ctod("")
local nLinha    := 0

  nLinha := row()

   qgetx(nLinha,38,@newValor,"@D")

   if newValor != nil
      if PAGOS->(qrlock())
         replace  PAGOS->data_pagto with newValor
 //        replace  PAGOS->Valor     with newValor
         PAGOS->(qunlock())
      endif

      MOV_BANC->(dbsetorder(4))
      if MOV_BANC->(dbseek("PG"+PAGOS->Codigo))
         if MOV_BANC->(qrlock())

            //if MOV_BANC->Saida > 0
               replace MOV_BANC->Data with newValor
            //endif

            MOV_BANC->(qunlock())
         endif
      endif

      MOV_CAIX->(dbsetorder(2))
      if MOV_CAIX->(dbseek("PG"+PAGOS->Codigo))
         if MOV_CAIX->(qrlock())

            if MOV_CAIX->Entrada > 0
               replace MOV_CAIX->Entrada with newValor
            endif

            MOV_CAIX->(qunlock())
         endif
      endif
   endif


return

static function i_ver_mov_banc

   MOV_BANC->(dbsetfilter({|| Internal == "PG"+PAGOS->Codigo}))

   MOV_BANC->(qview({{"Data/Data"         ,1},;
                    {"Saida/Valor"        ,0},;
                    {"f_308forn()/1o Forn",0},;
                    {"Internal/Internal"  ,0}},"10052075",;
                    {NIL,"f308a2",NIL,NIL},;
                     NIL,"ESC/ALT-P/ALT-O/<C>onsulta"))



return

static function i_ver_mov_caix

   MOV_CAIX->(dbsetfilter({|| Internal == "PG"+PAGOS->Codigo}))

   MOV_CAIX->(qview({{"Data/Data"         ,1},;
                    {"Saida/Valor"        ,0},;
                    {"Historico/Historico",0},;
                    {"Internal/Internal"  ,0}},"10052075",;
                    {NIL,"f308a2",NIL,NIL},;
                     NIL,"ESC/ALT-P/ALT-O/<C>onsulta"))



return


static function gera_mov

local nOrd, nReg := 0

   nREG := PAGOS->(recno())
   nOrd := PAGOS->(IndexOrd())

   if ! qconf("Deseja gerar mov_banc?","BL")
      return .F.
   endif

   if CONFIG->Gera_mov != "S"
      qmensa("Geracao nao permitida, CONFIG->Gera_mov deve ser 'S'. ","BL")
      return .f.
   endif

   PAGOS->(dbsetorder(1))
   PAGOS->(dbgotop())

   do While ! PAGOS->(eof())

     if PAGOS->(qrlock())
        replace PAGOS->Codigo with strzero(PAGOS->(Recno()),7)
        PAGOS->(qunlock())
     endif

     PAGOS->(dbskip())
   enddo


   MOV_BANC->(dbsetfilter({|| left(MOV_BANC->Internal,4) == "PG00"}))
   MOV_BANC->(dbgotop())

   do while ! MOV_BANC->(eof())

      if MOV_BANC->(qrlock())
         MOV_BANC->(dbdelete())
         MOV_BANC->(qunlock())
      endif

      MOV_BANC->(dbskip())
   enddo
   MOV_BANC->(dbclearfilter())

   MOV_CAIX->(dbsetfilter({|| left(MOV_CAIX->Internal,4) == "PG00"}))
   MOV_CAIX->(dbgotop())

   do while ! MOV_CAIX->(eof())

      if MOV_CAIX->(qrlock())
         MOV_CAIX->(dbdelete())
         MOV_CAIX->(qunlock())
      endif


      MOV_CAIX->(dbskip())
   enddo
   MOV_CAIX->(dbclearfilter())

   PAGOS->(dbsetorder(1))
   PAGOS->(dbgotop())

   do While ! PAGOS->(eof())

     if PAGOS->Tipo == "6"
        if MOV_CAIX->(qappend())
           replace MOV_CAIX->Data          with PAGOS->data_pagto
           replace MOV_CAIX->Cod_banco     with "99999"
           replace MOV_CAIX->Historico     with "PG NF "+left(PAGOS->Fatura,8)+" "+left(PAGOS->fornec,25)
           replace MOV_CAIX->Saida         with PAGOS->Valor_liq
           replace MOV_CAIX->Internal      with "PG"+PAGOS->Codigo
        endif

     else

        if MOV_BANC->(qappend())
           replace MOV_BANC->Data          with PAGOS->data_pagto
           replace MOV_BANC->Data_comp     with PAGOS->data_pagto
           replace MOV_BANC->Cod_banco     with "00001"
           replace MOV_BANC->Historico     with "PG NF "+left(PAGOS->Fatura,8)+" "+left(PAGOS->fornec,25)
           replace MOV_BANC->Saida         with PAGOS->Valor_liq
           replace MOV_BANC->Num_docto     with left(PAGOS->fatura,6)
           replace MOV_BANC->fornec_cod    with PAGOS->Cod_forn
           replace MOV_BANC->valores       with strzero(val(qtiraponto(str(PAGOS->Valor_liq,10,2))),10)
           replace MOV_BANC->Concilia      with "0"
           replace MOV_BANC->Internal      with "PG"+PAGOS->Codigo
        endif

     endif

     PAGOS->(dbskip())
   enddo

   PAGOS->(dbgotop())

   select PAGOS

   PAGOS->(dbsetorder(nOrd))
   PAGOS->(dbgoto(nREG))

return




