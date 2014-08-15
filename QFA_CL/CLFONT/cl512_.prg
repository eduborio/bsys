/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO COMERCIO
// OBJETIVO...: ESPELHO P/ CONFERENCIA DE FATURAS
// ANALISTA...:
// PROGRAMADOR: LUCINEIDE VILAR POSSEBOM
// INICIO.....: MARCO DE 1997
// OBS........:
// ALTERACOES.:

function cl512
#define K_MAX_LIN 52

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := { || ( XNIVEL==1 .and. !XFLAG ) .or. ( XNIVEL==1 .and. lastkey()==27 ) }

private cFATURA       // codigo da fatura
private aEDICAO := {} // vetor para os campos de entrada de dados
private nVALOR  := 0
private nTOT_PROD := 0

FAT->(dbSetFilter( { || ! Cancelado }, "! Cancelado" ))
FAT->(dbGoTop())

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || view_ped(-1,0,@cFATURA)} , "FATURA" })

do while .T.

   qlbloc(5,0,"B512A","QBLOC.GLO")
   XNIVEL    := 1
   XFLAG     := .T.
   cFATURA   := space(5)

   // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; dbcloseall() ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   if ! qinitprn() ; return ; endif

   i_loop_imp()

   qstopprn(.F.)

enddo

/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA _____________________________________________

static function i_critica ( cCAMPO )
   do case
      case cCAMPO == "FATURA"
           if ! empty(cFATURA)
              if ! FAT->(dbseek(cFATURA:=strzero(val(cFATURA),5)))
                 qmensa("Fatura n„o encontrada !","B")
                 return .F.
              endif
           else
             return .F.
           endif
   endcase
return .T.

/////////////////////////////////////////////////////////////////////////////
// LOOP DE CONTROLE DE IMPRESSAO ____________________________________________

static function i_loop_imp

   // LOOP DE IMPRESSAO _____________________________________________________

   FAT->(dbseek(cFATURA))

   i_impressao()

   eject

return

/////////////////////////////////////////////////////////////////////////////
// IMPRESSAO DE UM ESPELHO P/ CONFERENCIA ___________________________________

static function i_impressao

   local cLINHA1 := "*" + replicate("-",77) + "*"
   local cLINHA2 := "|" + space(77) + "|"
   local cMACRO, cEXTENSO, nCONT, nRESTO := 12
   local nDES

   qmensa("Emitindo espelho da fatura: "+FAT->Num_fatura)

   setprc(0,0)

   CLI1->(dbseek(FAT->Cod_cli))
   FILIAL->(dbseek(FAT->Filial))

   if ! qlineprn() ; return .F. ; endif

   @ prow()+1,2 say XRAZAO
   @ prow(),59  say time() + "  " + dtoc(date())
   @ prow()+1,0 say cLINHA1
   @ prow()+1,0 say space(4) + XCOND1 + XAEXPAN + "RELATORIO DE CONFERENCIA INDIVIDUAL DO PEDIDO N: " + transform(FAT->Codigo,"@R 999999") + XDEXPAN + XCOND0
   @ prow()+1,0 say cLINHA1
   @ prow()+1,0 say cLINHA2

   if ! qlineprn() ; return .F. ; endif

   @ prow()+1,0 say "| PEDIDO...: " + FAT->Codigo + space(13) + "DATA DE EMISSAO: " + dtoc(FAT->Dt_emissao) ; i_x()
   @ prow()+1,0 say "| FILIAL...: " + FAT->Filial + " - " + left(FILIAL->Razao,40) ; i_x()
   VEND->(Dbseek(FAT->Cod_repres))
   @ prow()+1,0 say "| VENDEDOR.: " + VEND->Codigo + " - " + left(VEND->Nome,30) ; i_x()
   @ prow()+1,0 say cLINHA2

   if ! qlineprn() ; return .F. ; endif

   @ prow()+1,0 say cLINHA1
   @ prow()+1,0 say "|  DUPLICATA        |          VENCIMENTO       |            VALOR            |"
   @ prow()+1,0 say cLINHA1

   DUP_FAT->(Dbseek(FAT->Codigo+"01"))

   do while ! DUP_FAT->(eof()) .and. left(DUP_FAT->Num_fat,5) == FAT->Codigo

      if ! empty(FAT->Aliq_desc)
         if CONFIG->Modelo_2 == "2"
            nDES :=  ( DUP_FAT->Valor ) - FAT->Aliq_desc
         else
            nDES := ( ( DUP_FAT->Valor ) * FAT->Aliq_desc ) / 100
         endif
      else
         nDES := 0
      endif

      @ prow()+1 ,0 say "|    " + left(DUP_FAT->Num_fat,5) + "/" + right(DUP_FAT->Num_Fat,2) + "       |          " + iif(DUP_FAT->Dias == 0 ,dtoc(DUP_FAT->Data_venc),dtoc(DUP_FAT->Data_venc+DUP_FAT->Dias)) + "       |           " + transform(DUP_FAT->Valor - nDES, "@E 999,999,999.99") + "    |"

      nVALOR := ( nVALOR + DUP_FAT->Valor ) - nDES
      DUP_FAT->(Dbskip())

   enddo

   @ prow()+1,0 say cLINHA1
   @ prow()+1,0 say cLINHA2

   if ! qlineprn() ; return .F. ; endif

   @ prow()+1,0 say "| CLIENTE..: " + CLI1->Codigo + " - " + left(CLI1->Razao,56) ; i_x()
   @ prow()+1,0 say cLINHA2
   @ prow()+1,0 say "| END ENT..: " + CLI1->End_ent ; i_x() ; CGM->(dbseek(CLI1->Cgm_ent))
   @ prow()+1,0 say "| CEP......: " + transform(CLI1->Cep_ent,"@R 99.999-999") + "   Mun.: " + CGM->Municipio + "   Estado: " + CGM->Estado ; i_x()
   @ prow()+1,0 say cLINHA2
   @ prow()+1,0 say "| END COB..: " + CLI1->End_cob ; i_x() ; CGM->(dbseek(CLI1->Cgm_cob))
   @ prow()+1,0 say "| CEP......: " + transform(CLI1->Cep_cob,"@R 99.999-999") + "   Mun.: " + CGM->Municipio + "   Estado: " + CGM->Estado ; i_x()
   @ prow()+1,0 say cLINHA2
   @ prow()+1,0 say "| TELEFONE.: " + CLI1->Fone1 + "/" + CLI1->Ramal1 + "  ,  " + CLI1->Fone2 + "/" + CLI1->Ramal2 ; i_x()
   @ prow()+1,0 say cLINHA2
   @ prow()+1,0 say "| C.G.C....: " + fu_conv_cgccpf(CLI1->Cgccpf) + "           INSCRICAO ESTADUAL: " + CLI1->Inscricao ; i_x()
   @ prow()+1,0 say cLINHA2

   cEXTENSO := pad(alltrim(qextenso(nVALOR)) + " ",168,"*")

   @ prow()+1,0 say "| Valor por extenso: " + left(cEXTENSO,56)    ; i_x()
   @ prow()+1,0 say "|                    " + subs(cEXTENSO,57,56) ; i_x()
   @ prow()+1,0 say "|                    " + right(cEXTENSO,56)   ; i_x()
   @ prow()+1,0 say cLINHA2

   @ prow()+1,0 say "| Obs: " + FAT->Obs ; i_x()

   @ prow()+1,0 say cLINHA1
   @ prow()+1,0 say "| UN |   QUANT. |  DESCRICAO DOS PRODUTOS          | VALOR UNIT. | VALOR TOTAL|"
   @ prow()+1,0 say cLINHA1

   if ! qlineprn() ; return .F. ; endif

   ITEN_FAT->(Dbseek(FAT->Codigo))

   do while ITEN_FAT->Num_Fat == FAT->Codigo

      PROD->(dbsetorder(4))
      PROD->(dbseek(ITEN_FAT->Cod_Prod))
      UNIDADE->(dbseek(PROD->Unidade))

      @ prow()+1,0 say "|"+UNIDADE->Sigla+" | " + transform(ITEN_FAT->Quantidade,"@E 99999.99") + " |  " + left(PROD->Descricao,30) + ;
                       "  | " + transform(ITEN_FAT->Vl_unitar,"@E 999,999.99") + ;
                       "  | " + transform(ITEN_FAT->Vl_unitar*ITEN_FAT->Quantidade,"@E 999,999.99")+ " |"
      nTOT_PROD += (ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade)

      nRESTO--

      ITEN_FAT->(dbskip())

   enddo

   for nCONT := 1 to (nRESTO-1)
      @ prow()+1,0 say "|    |          |                                  |             |            |"
   next

   if ! empty(FAT->Aliq_desc)
      if CONFIG->Modelo_2 == "2"
         nDES :=  nTOT_PROD - FAT->Aliq_desc
      else
         nDES := ( nTOT_PROD * FAT->Aliq_desc ) / 100
      endif
   else
      nDES := 0
   endif

   @ prow()+1,00 say "|" + space(46) + "Total da Fatura > "+transform(nTOT_PROD-nDES, "@E 9,999,999.99")+" |"

   @ prow()+1,0 say cLINHA2
   @ prow()+1,0 say cLINHA1

   nTOT_PROD := 0
   nVALOR    := 0
return .T.


static function i_x
   @ prow(),78 say "|"
return
