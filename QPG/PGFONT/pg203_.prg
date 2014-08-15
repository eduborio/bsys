/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE CONTAS A RECEBER/PAGAR
// OBJETIVO...: EXCLUSAO SEM CONTABILIZACAO
// ANALISTA...:
// PROGRAMADOR:
// INICIO.....: FEVEREIRO DE 1997
// OBS........:
// ALTERACOES.:

function pg203

#include "inkey.ch"
#include "setcurs.ch"

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

// VIEW INICIAL _____________________________________________________________

PAGAR->(qview({{"Codigo/C¢digo"             ,1},;
               {"Data_venc/Vencimento"      ,2},;
               {"f_203b()/Fornecedor"       ,3},;
               {"f_203c()/    Valor"        ,4},;
               {"Num_titulo/N£m. Doc."      ,5}},"P",;
               {NIL,"f203a",NIL,NIL},;
                NIL,"ESC/ALT-P/ALT-O/<E>xclui"))

//////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAGEM DO FORNECEDOR _______________________________________

function f_203b
   FORN->(dbseek(PAGAR->Cod_forn))
return left(FORN->Razao,22)

//////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAGEM DE VALOR COM PICTURE ________________________________

function f_203c
return(transform(PAGAR->Valor,"@E 9,999,999.99"))

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function f203a
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))
   if cOPCAO = "E"
      qlbloc(06,02,"B203A","QBLOC.GLO",1)
      i_edicao()
   endif
   setcursor(nCURSOR)
return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA ____________________________________

static function i_edicao
   local lCONF
   local aEDICAO := {}
   local bESCAPE := {||empty(fDATA_LANC).or.(XNIVEL==1.and.!XFLAG).or.;
                         (XNIVEL==2.and.cOPCAO=="A".and.!XFLAG)}

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO = "E"
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
      qrsay ( XNIVEL++ , transform(PAGAR->Valor,"@E 9,999,999.99"     ))
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

   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "E" ; i_exclusao() ; return ; endif

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXCLUIR CONTAS A PAGAR _______________________________________

static function i_exclusao
   if qconf("Confirma exclus„o desta Conta … Pagar ?")
      if PAGAR->(qrlock())
         if ! empty(PAGAR->Agrupado)
            if AGRUPA->(Dbseek(PAGAR->Agrupado)) .and. AGRUPA->(qrlock())
               AGRUPA->(Dbdelete())
            endif
         endif
         PAGAR->(dbdelete())
         PAGAR->(qunlock())
      else
         qm3()
      endif
   endif
return
