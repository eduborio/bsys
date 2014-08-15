/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE CONTAS A RECEBER/PAGAR
// OBJETIVO...: LIBERACAO DE PAGAMENTOS
// ANALISTA...:
// PROGRAMADOR:
// INICIO.....: FEVEREIRO DE 1997
// OBS........:
// ALTERACOES.:
function pg402

#include "inkey.ch"
#include "setcurs.ch"

// VIEW INICIAL _____________________________________________________________

PAGAR->(qview({{"Data_venc/Vcto"             ,2},;
               {"Cod_forn/Codigo"            ,3},;
               {"left(Fornec,39)/Fornecedor",10},;
               {"f_402c()/Valor Tit."        ,0},;
               {"Marcacao/M"                 ,0},;
               {"Duplicata/Duplicata"        ,0}},"P",;
               {NIL,"f402a",NIL,NIL},;
               NIL,"ESC/ALT-P/ALT-O/<C>onsulta/<L>ibera/<M>arca ou Desmarca"))

//////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAGEM DO FORNECEDOR _______________________________________

function f_402b
   FORN->(dbseek(PAGAR->Cod_forn))
return left(FORN->Razao,42)

//////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAGEM DE VALOR COM PICTURE ________________________________

function f_402c
return(transform(PAGAR->Valor_liq,"@E 9,999,999.99"))

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function f402a
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))
   if cOPCAO = "M" ; i_marca()  ; return ; endif
   if cOPCAO = "L" ; i_libera()    ; return ; endif
   if cOPCAO = "C" ; qlbloc(05,02,"B402A","QBLOC.GLO",1) ; i_consulta() ; endif
   setcursor(nCURSOR)
return ""


/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA CONSULTAR LANCAMENTO DE PAGAMENTO _____________________________

static function i_consulta

   // MONTA DADOS NA TELA ___________________________________________________

      XNIVEL := 1
      qrsay ( XNIVEL++ , PAGAR->Codigo       )
      qrsay ( XNIVEL++ , PAGAR->Data_lanc    )
      qrsay ( XNIVEL++ , PAGAR->Cod_forn     ) ; FORN->(dbseek(PAGAR->Cod_forn))
      qrsay ( XNIVEL++ , left(FORN->Razao,40))
      qrsay ( XNIVEL++ , PAGAR->Centro       ) ; CCUSTO->(dbseek(PAGAR->Centro))
      qrsay ( XNIVEL++ , left(CCUSTO->Descricao,40))
      qrsay ( XNIVEL++ , PAGAR->Filial       ) ; FILIAL->(dbseek(PAGAR->Filial))
      qrsay ( XNIVEL++ , left(FILIAL->Razao,40))
      qrsay ( XNIVEL++ , PAGAR->Data_emiss   )
      qrsay ( XNIVEL++ , PAGAR->Cod_veic     ) ; VEICULOS->(dbseek(PAGAR->Cod_veic))
      qrsay ( XNIVEL++ , left(VEICULOS->Descricao,13))
      qrsay ( XNIVEL++ , PAGAR->Cod_eqpto    ) ; EQUIPTO->(dbseek(PAGAR->Cod_eqpto))
      qrsay ( XNIVEL++ , EQUIPTO->Descricao  )
      qrsay ( XNIVEL++ , PAGAR->Especie      ) ; ESPECIE->(dbseek(PAGAR->Especie))
      qrsay ( XNIVEL++ , left(ESPECIE->Descricao,13))
      qrsay ( XNIVEL++ , PAGAR->Serie        ) ; SERIE->(dbseek(PAGAR->Serie))
      qrsay ( XNIVEL++ , left(SERIE->Descricao,11))
      qrsay ( XNIVEL++ , PAGAR->Tipo_sub     ) ; TIPOCONT->(dbseek(PAGAR->Tipo_sub) )
      qrsay ( XNIVEL++ , left(TIPOCONT->Descricao,46))
      qrsay ( XNIVEL++ , left(PAGAR->Historico,60))
      qrsay ( XNIVEL++ , PAGAR->Data_venc    )
      qrsay ( XNIVEL++ , PAGAR->Data_prorr   )
      qrsay ( XNIVEL++ , transform(PAGAR->Valor_liq,"@E 9,999,999.99"     ))
      qrsay ( XNIVEL++ , PAGAR->Tipo_doc     ) ; TIPO_DOC->(dbseek(PAGAR->Tipo_doc))
      qrsay ( XNIVEL++ , TIPO_DOC->Descricao   )
      qrsay ( XNIVEL++ , PAGAR->Fatura       )
      qrsay ( XNIVEL++ , PAGAR->Duplicata    )
      qrsay ( XNIVEL++ , PAGAR->Cgm          ) ; CGM->(dbseek(PAGAR->Cgm))
      qrsay ( XNIVEL++ , left(CGM->Municipio,40))
      qrsay ( XNIVEL++ , PAGAR->Cod_Banco    ) ; BANCO->(Dbseek(PAGAR->Cod_banco))
      qrsay ( XNIVEL++ , BANCO->Descricao      )
      qrsay ( XNIVEL++ , PAGAR->Situacao     ) ; SITUA->(dbseek(PAGAR->Situacao))
      qrsay ( XNIVEL++ , left(SITUA->Descricao,28))
      qrsay ( XNIVEL++ , PAGAR->Data_cont    )
      qrsay ( XNIVEL++ , left(PAGAR->Observacao,59))

      qwait()

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A MARCACAO PARA LIBERACAO ______________________________

static function i_marca
   if PAGAR->(qrlock())
      if PAGAR->Marcacao = "*"
         replace PAGAR->Marcacao with " "
      else
         replace PAGAR->Marcacao with "*"
      endif
   endif
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A LIBERACAO DO LANCAMENTO PARA TESOURARIA _____________

static function i_libera

   local lCONF

   lCONF := qconf("Confirma Liberacao deste(s) Lancamento(s) ?")

   if lCONF

      if ! PAGAR->(qflock()) .and. ! SH_PAGAR->(qflock())
         qmensa("N„o foi Poss¡vel Liberar para Tesouraria !","B")
         return
      endif

      PAGAR->(dbgotop())

      do while ! PAGAR->(eof())

         qgirabarra()

         if PAGAR->Marcacao == "*"

            if SH_PAGAR->(qappend())

                  qmensa("Aguarde ... Liberando Pagamento para Tesouraria ...")

                  replace SH_PAGAR->Codigo     with PAGAR->Codigo
                  replace SH_PAGAR->Data_lanc  with PAGAR->Data_lanc
                  replace SH_PAGAR->Cod_forn   with PAGAR->Cod_forn
                  replace SH_PAGAR->Centro     with PAGAR->Centro
                  replace SH_PAGAR->Filial     with PAGAR->Filial
                  replace SH_PAGAR->Data_emiss with PAGAR->Data_emiss
                  replace SH_PAGAR->Especie    with PAGAR->Especie
                  replace SH_PAGAR->Serie      with PAGAR->Serie
                  if empty(CONFIG->Remoplast)
                     replace SH_PAGAR->Tipo_Sub   with PAGAR->Tipo_Sub
                  else
                     replace SH_PAGAR->Tipo_Sub  with "010002"
                  endif
                  replace SH_PAGAR->Historico  with PAGAR->Historico
                  replace SH_PAGAR->Data_venc  with PAGAR->Data_venc
                  replace SH_PAGAR->Data_prorr with PAGAR->Data_prorr
                  replace SH_PAGAR->Valor      with PAGAR->Valor
                  replace SH_PAGAR->Valor_liq  with PAGAR->Valor_liq
                  replace SH_PAGAR->Fatura     with PAGAR->Fatura
                  replace SH_PAGAR->Num_titulo with PAGAR->Num_titulo
                  replace SH_PAGAR->Cgm        with PAGAR->Cgm
                  replace SH_PAGAR->Cod_banco  with PAGAR->Cod_banco
                  replace SH_PAGAR->Situacao   with PAGAR->Situacao
                  replace SH_PAGAR->Dt_contabi with PAGAR->Data_cont
                  replace SH_PAGAR->Agrupado   with PAGAR->Agrupado
                  replace SH_PAGAR->Fornec     with PAGAR->Fornec
                  replace SH_PAGAR->PedComp    with PAGAR->PedComp

                  PAGAR->(dbdelete())

            else

              qm1()

            endif

            qmensa("")

         endif

         PAGAR->(dbskip())

      Enddo

      PAGAR->(qunlock())
      SH_PAGAR->(qunlock())

   endif

PAGAR->(dbgotop())
return
