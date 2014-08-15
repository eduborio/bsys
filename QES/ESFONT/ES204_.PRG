/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE ESTOQUE
// OBJETIVO...: BAIXA DE PEDIDO DE COMPRAS
// ANALISTA...:
// PROGRAMADOR: LUCINEIDE VILAR POSSEBOM
// INICIO.....: JANEIRO DE 1997
// OBS........:
// ALTERACOES.: LUCIANO DA SILVA GORSKI
function es204

#include "inkey.ch"

private sBLOC1  := qlbloc("B204F","QBLOC.GLO")
private nLETRA := " "
private nTOT_PED := 0
private lTEM := .F.
private lNADA := .F.

PROD->(dbsetorder(4))

/////////////////////////////////////////////////////////////////////////////
// MANUTENCAO  _____________________________________________________________

qmensa("Aguarde... Selecionando Pedidos...")

PEDIDO->(dbSetFilter({|| PEDIDO->Estoque == "S" }, 'PEDIDO->Estoque == "S"'))

qmensa("")

PEDIDO->(qview({{"i_204c()/Pedido"      ,2},;
                {"Data_ped/Data Ped."   ,1},;
                {"Data_baixa/Data Baixa",0},;
                {"i_204a()/Fornecedor"  ,3},;
                {"transform(Val_pedido,'@E 9,999,999.99')/Valor Pedido",0},;
                {"i_204d()/Int."       ,0}},"P",;
                {NIL,"i_204b",NIL,NIL},;
                NIL,"<ESC>-Sai/<C>on/Pes<Q>uisa/<B>aixa"))
return

//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAGEM DO FORNECEDOR ___________________________________________

function i_204a
   FORN->(dbseek(PEDIDO->Cod_forn))
return left(FORN->Razao,23)

//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAGEM DO FORNECEDOR ___________________________________________

function i_204c
return transform(PEDIDO->Codigo,"@R 99999/9999!")

//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INFORMAR SE FOI FEITO O INTERFACE _________________________________

function i_204d
   local cSIMNAO
   do case
      case PEDIDO->Interface == .T.
           cSIMNAO := "SIM"
      case PEDIDO->Interface == .F.
           cSIMNAO := "NŽO"
   endcase
return cSIMNAO

//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO _____________________________________

function i_204b

   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))

   PEDIDO->(dbSetFilter({|| PEDIDO->Estoque == "S" }, 'PEDIDO->Estoque == "S"'))

   iif(cOPCAO=="Q",i_pesq_pedido(),nil)

   if cOPCAO=="B"
      if Pedido->Interface
         qmensa("Pedido ja foi Interfaceado !!","B")
         return ""
      endif
      if ! empty(PEDIDO->Data_Baixa)
         qmensa("Pedido ja foi Baixado !!","B")
         return ""
      else
         i_baixa_pedido()
      endif
   endif

   if cOPCAO $ "P*C"
      qlbloc(5,0,"B204A","QBLOC.GLO",1)
      qmensa(qabrev(cOPCAO,"C",{"Consulta..."}))
      i_edicao()
   endif

   setcursor(nCURSOR)

   select PEDIDO
   PEDIDO->(dbsetorder(1))

return ""

//////////////////////////////////////////////////////////////////////////////////
// PESQUISA PELO NUMERO DO PEDIDO ________________________________________________

static function i_pesq_pedido

   local cPEDIDO
   local cNUMERO := "     "
   local cANO    := "    "
   local nREC    := PEDIDO->(recno())

   qmensa("Digite o numero do Pedido p/ pesquisa:      /    ")
   qgetx(24,50,@cNUMERO,"99999")
   qgetx(24,56,@cANO,"9999"    )

   cPEDIDO := strzero(val(cNUMERO),5) + strzero(val(cANO),4)

   PEDIDO->(dbsetorder(2))

   if ! PEDIDO->(dbseek(cPEDIDO))
      qmensa("Pedido n„o encontrado !","B")
      PEDIDO->(dbgoto(nREC))
      return
   endif

return

//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA _________________________________________

static function i_edicao

   local lCONF
   local aEDICAO := {}
   local bESCAPE := {||empty(fDATA_PED).or.(XNIVEL==2.and.!XFLAG).or.;
                       (XNIVEL==2.and.lastkey()==27)}

   private cESTADO_EMP  // Estado da empresa
   private cESTADO_FOR  // Estado do fornecedor

   private nDIA_1   := 0
   private nDIA_2   := 0
   private nDIA_3   := 0
   private nDIA_4   := 0
   private nDIA_5   := 0
   private dDATA_1  := ctod("")
   private dDATA_2  := ctod("")
   private dDATA_3  := ctod("")
   private dDATA_4  := ctod("")
   private dDATA_5  := ctod("")
   private nVALOR_1 := 0
   private nVALOR_2 := 0
   private nVALOR_3 := 0
   private nVALOR_4 := 0
   private nVALOR_5 := 0

   private aPARCELA := {{0,ctod(""),0},{0,ctod(""),0},{0,ctod(""),0},{0,ctod(""),0},{0,ctod(""),0}}

   private nTOT_ICM := 0
   private nTOT_IPI := 0
   private nTOT_ISS := 0

// MONTA DADOS NA TELA ___________________________________________________________

   if cOPCAO $ "C*P"

      XNIVEL := 1

      qsay ( 6,22, PEDIDO->Codigo ,"@R 99999/9999" )
      qsay ( 6,51, PEDIDO->Data_ped  )
      qsay ( 7,22, PEDIDO->Filial    ) ; FILIAL->(dbseek(PEDIDO->Filial))
      qsay ( 7,35, left(FILIAL->Razao,40) )
      qsay ( 8,22, PEDIDO->Centro    ) ; CCUSTO->(dbseek(PEDIDO->Centro))
      qsay ( 8,35, CCUSTO->Descricao )
      qsay ( 9,14, PEDIDO->Veiculos  ) ; VEICULOS->(dbseek(PEDIDO->Veiculos))
      qsay ( 9,20, VEICULOS->Descricao )
      qsay ( 9,51, PEDIDO->Equipto   ) ; EQUIPTO->(dbseek(PEDIDO->Equipto))
      qsay ( 9,57, left(EQUIPTO->Descricao,20) )
      qsay (10,22, PEDIDO->Tipo      ) ; TIPOCONT->(dbseek(PEDIDO->Tipo) )
      qsay (10,31, alltrim(TIPOCONT->Descricao))
      qsay (11,22, PEDIDO->Comprador ) ; CAD_COMP->(dbseek(PEDIDO->Comprador))
      qsay (11,31, CAD_COMP->Nome    )

      qsay (11,73, qabrev(PEDIDO->Estoque,"SN", {"Sim","N„o"}))

      qsay (12,22, PEDIDO->Cod_forn  ) ; FORN->(dbseek(PEDIDO->Cod_forn))
      qsay (12,31, left(FORN->Razao,45))
      qsay (13,22, PEDIDO->Cod_Fisc , "@R 9.99" ) ; NATOP->(dbseek(PEDIDO->Cod_Fisc))
      qsay (13,31, NATOP->Nat_Desc   )

      if cOPCAO == "P"
        i_atualiza_lancs()
        keyboard chr(27)
      endif

   endif

   // CONSULTA OU EXCLUSAO _______________________________________________________

   if cOPCAO $ "C*P" ; i_consulta() ; return ; endif

//////////////////////////////////////////////////////////////////////////////////
// PARA CONSULTAR A SEGUNDA TELA _________________________________________________

static function i_consulta
   local nTECLA, nCONT
   //setpos(24,79)

   if cOPCAO $ "C*P"
      keyboard chr(27)
      i_atualiza_lancs()
   endif

   qmensa("<ESC> p/ sair ou <O>utra Tela")

   do while .T.
      nTECLA := qinkey()
      if nTECLA == K_ESC ; exit ; endif
      if upper(chr(nTECLA)) == "O"
         i_init_parcela()
         XNIVEL := 1
         qlbloc(5,2,"B204B","QBLOC.GLO",1)

         qrsay ( XNIVEL++  , PEDIDO->Data_adto  , "@D" )
         qrsay ( XNIVEL++  , PEDIDO->Valor_adto , "@E 9,999,999.99" )

         qrsay ( XNIVEL++  , PEDIDO->DESC_COND   , "@E 99.99" )
         qrsay ( XNIVEL++  , PEDIDO->VL_DESC_C  , "@E 9,999,999.99" )

         qrsay ( XNIVEL++  , PEDIDO->DESC_INCON  , "@E 99.99" )
         qrsay ( XNIVEL++  , PEDIDO->VL_DESC_I  , "@E 9,999,999.99" )

         qrsay ( XNIVEL++  , PEDIDO->IRRF        , "@E 99.99" )
         qrsay ( XNIVEL++  , PEDIDO->VL_IRRF    , "@E 9,999,999.99" )

         qrsay ( XNIVEL++  , PEDIDO->RED_ICMS    , "@E 99.99" )
         qrsay ( XNIVEL++  , PEDIDO->VL_RED_IC  , "@E 9,999,999.99" )
         for nCONT := 1 to 5
             qrsay(XNIVEL++,strzero(aPARCELA[nCONT,1],3))
             qrsay(XNIVEL++,aPARCELA[nCONT,2])
             qrsay(XNIVEL++,aPARCELA[nCONT,3],"@E 9,999,999.99")
         next
         qrsay ( XNIVEL++ , PEDIDO->Val_LIQ , "@E 999,999,999.99" )
         qrsay ( XNIVEL++ , PEDIDO->Data_entre)
         qrsay ( XNIVEL++ , PEDIDO->Data_baixa)
         qrsay ( XNIVEL++ , PEDIDO->Numero_nf )
         qrsay ( XNIVEL++ , PEDIDO->Serie     ) ; SERIE->(dbseek(PEDIDO->Serie))
         qrsay ( XNIVEL++ , left(SERIE->Descricao,15)  )
         qrsay ( XNIVEL++ , PEDIDO->Especie   ) ; ESPECIE->(dbseek(PEDIDO->Especie))
         qrsay ( XNIVEL++ , left(ESPECIE->Descricao,15))
         qrsay ( XNIVEL++ , PEDIDO->Data_emiss)
         qrsay ( XNIVEL++ , left(PEDIDO->Observacao,57))
         qwait()
         exit
      endif
   enddo
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ATUALIZAR LANCAMENTOS NA TELA ________________________________

static function i_atualiza_lancs

   LANC->(qview({{"Cod_prod/Cod."                                 ,2},;
                 {"f204d()/Descri‡„o"                             ,0},;
                 {"transform(Preco,'@E 99,999.9999')/Val. Un."    ,0},;
                 {"transform(Quant,'@E 9999.99999')/Quant."       ,0},;
                 {"f204e()/Un."                                   ,0},;
                 {"Parcial/Baixar",0},;
                 {"f204c()/Val. Total"                            ,0}},;
                 "14002179S",;
                 {NIL,"f204k",NIL,NIL},;
                 {"LANC->Cod_ped==PEDIDO->Codigo",{||f204top()},{||f204bot()}},;
                 "<ESC> P/Sair <M>arcar/  <B>aixar  "))
return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IR PARA O INICIO DOS DADOS FILTRADOS _________________________

function f204top
   LANC->(dbsetorder(1))
   LANC->(dbseek(PEDIDO->Codigo))
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IR PARA O FINAL DOS DADOS FILTRADOS __________________________

function f204bot
   LANC->(dbsetorder(1))
   LANC->(qseekn(PEDIDO->Codigo))
return


function f204k

   local nCURSOR := setcursor(1)
   parameters cOPCAO

   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO == "M"
      i_marca()
   endif

   if cOPCAO == "B"
      i_Baixar()
   endif


   setcursor(nCURSOR)

return ""



/////////////////////////////////////////////////////////////////////////////
// FUNCAO DE CONTROLE PRINCIPAL ANTES DE PROCESSAR A TECLA ACIONADA _________

function f204d

   local cDESCRICAO := space(19)

   i_totaliza_pedidos()

   qsay ( 22,17 , transform(nTOT_ICM , "@E 999,999.99") )
   qsay ( 22,43 , transform(nTOT_IPI , "@E 999,999.99") )
   qsay ( 22,68 , transform(nTOT_ISS , "@E 999,999.99") )

   if ! empty(LANC->Cod_prod)
      PROD->(dbseek(LANC->Cod_prod))
      cDESCRICAO := left(PROD->Descricao,19)
   endif

return cDESCRICAO

/////////////////////////////////////////////////////////////////////////////
// RETORNA O VALOR TOTAL DO PRODUTO _________________________________________

function f204c
return transform((LANC->Preco * LANC->Quant)+(LANC->Preco*LANC->Quant*LANC->Aliq_ipi/100),"@E 9,999,999.99")

/////////////////////////////////////////////////////////////////////////////
// RETORNA A UNIDADE DO PRODUTO _____________________________________________

function f204e
   PROD->(dbseek(LANC->Cod_prod))
   UNIDADE->(dbseek(PROD->Unidade))
return UNIDADE->Sigla

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA TOTALIZAR VARIAVEIS DO PEDIDO ________________________________

static function i_totaliza_pedidos

   local nREC := LANC->(recno())

   fVAL_PEDIDO := nTOT_ICM := nTOT_IPI := nTOT_ISS := 0

   if cOPCAO $ "C-P"
//    fALIQ_ICMS  := PEDIDO->Aliq_icms
      fVALOR_ADTO := PEDIDO->Valor_adto
   endif

   LANC->(dbgotop())
   LANC->(dbsetorder(1))
   LANC->(dbseek(PEDIDO->Codigo))

   do while ! LANC->(eof()) .and. LANC->Cod_Ped == PEDIDO->Codigo

      PROD->(dbseek(LANC->Cod_Prod))

      if PROD->Prod_iss == "S"
         nTOT_ISS += LANC->Quant * LANC->Preco
      else
//       nTOT_ICM += ((LANC->Quant * LANC->Preco) * fALIQ_ICMS)  / 100
         nTOT_ICM += ((LANC->Quant * LANC->Preco) * LANC->Aliq_icms)  / 100
      endif

  //  nTOT_IPI += ((LANC->Quant * LANC->Preco) *  PROD->Ipi) / 100
      nTOT_IPI += ((LANC->Quant * LANC->Preco) *  LANC->Aliq_ipi) / 100

      fVAL_PEDIDO += LANC->Quant * LANC->Preco
      fVAL_LIQ    := fVAL_PEDIDO - fVALOR_ADTO
      fSUB_GRUP   := left(PROD->Codigo,4)

      LANC->(dbskip())

   enddo

// fVAL_PEDIDO := fVAL_PEDIDO + nTOT_IPI
   fVAL_PEDIDO := fVAL_PEDIDO

   LANC->(dbgoto(nREC))

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INTERFACE ____________________________________________________

static function i_interface

   // SOMENTE AS AINDA NAO INTERFACEADAS E CONSEGUIU TRAVAR FAT.DBF ______

   local nVAL_BASE := 0
   local nVAL_RED  := 0
   local cFATOR    := 1

   qmensa("Aguarde...Realizando Interface com Contas a Pagar...")

   fu_abre_apcom()
   fu_abre_ficom()
   fu_abre_cpest()
   fu_abre_conta()

   if ! PEDIDO->Interface .and. PEDIDO->(qrlock())

      if PEDIDO->Estoque == "S"

         LANC->(Dbseek(PEDIDO->Codigo))

         do while ! LANC->(eof()) .and. LANC->Cod_ped == PEDIDO->Codigo

            INVENT->(Dbsetorder(1))  // atualiza inventario............................

            if INVENT->(qrlock()) .and. INVENT->(Dbseek(alltrim(PEDIDO->Filial)+LANC->Cod_prod+LANC->Lote))

               INVENT->(qrlock())

               replace INVENT->Quant_atu with ( INVENT->Quant_atu +  (LANC->Quant*LANC->Fator) )

               INVENT->(qunlock())
            else
               if INVENT->(qrlock()) .and. INVENT->(qappend())

                  INVENT->(qrlock())

                   replace INVENT->Data       with PEDIDO->Data_ped
                   replace INVENT->Filial     with PEDIDO->Filial
                   replace INVENT->Cod_prod   with LANC->Cod_prod
                   replace INVENT->Quantidade with (LANC->Quant*LANC->Fator)
                   replace INVENT->Val_invent with LANC->Preco
                   replace INVENT->Lote       with LANC->LOTE
                   replace INVENT->Quant_atu  with (LANC->Quant*LANC->Fator)
                   replace INVENT->Preco_uni  with LANC->Preco

                   INVENT->(qunlock())
               endif

            endif

            if SH_CPEST->(qappend())

               replace SH_CPEST->Data       with PEDIDO->Data_ped
               replace SH_CPEST->Filial     with PEDIDO->Filial
               replace SH_CPEST->Cod_prod   with LANC->Cod_prod
               replace SH_CPEST->Quantidade with val(transform(LANC->Quant*LANC->Fator,"@R 999999.99999"))
               replace SH_CPEST->Lote       with LANC->LOTE
               replace SH_CPEST->Val_uni    with LANC->Preco / LANC->Fator
               replace SH_CPEST->Tipo       with "E"

            endif

// ATUALIZACAO DO ARQUIVO LOTES...............

            LOTES->(dbsetorder(1))

            if LOTES->(dbseek(LANC->Cod_prod+alltrim(PEDIDO->Filial)+LANC->Lote)) .and. LOTES->(qrlock())

               Replace LOTES->Quantidade With (LOTES->Quantidade + LANC->Quant)
               LOTES->(qunlock())
            else

               if LOTES->(qappend())
                  Replace LOTES->Data       with PEDIDO->Data_ped
                  Replace LOTES->Produto    with LANC->Cod_prod
                  Replace LOTES->Filial     with PEDIDO->Filial
                  Replace LOTES->Quantidade with LANC->Quant
                  Replace LOTES->Num_lote   with LANC->Lote
               endif
            endif

            LANC->(Dbskip())

         enddo

      endif

      // ATUALIZA FLAG DE INTERFACEAMENTO ________________________________

      replace PEDIDO->Interface with .T.

      PARCELA->(Dbsetorder(1))
      PARCELA->(Dbseek(PEDIDO->Codigo))

      do while ! PARCELA->(eof()) .and. PARCELA->Cod_ped == PEDIDO->Codigo

         if SH_APCOM->(qappend())

            replace SH_APCOM->Data_lanc    with PEDIDO->Data_ped
            replace SH_APCOM->Cod_forn     with PEDIDO->Cod_forn
            replace SH_APCOM->Centro       with left(PEDIDO->Centro,4)
            replace SH_APCOM->Filial       with left(PEDIDO->Filial,4)
            replace SH_APCOM->Data_emiss   with PEDIDO->Data_emiss
            replace SH_APCOM->Especie      with PEDIDO->Especie
            replace SH_APCOM->Serie        with PEDIDO->Serie
            replace SH_APCOM->Tipo_sub     with PEDIDO->Tipo
            replace SH_APCOM->Historico    with PEDIDO->Observacao

            replace SH_APCOM->Data_venc    with PARCELA->Data
            replace SH_APCOM->Valor        with PARCELA->Valor
            replace SH_APCOM->Valor_liq    with PARCELA->Valor

            replace SH_APCOM->Fatura       with PEDIDO->Numero_nf
            replace SH_APCOM->Cgm          with "041000"
            replace SH_APCOM->Cod_veic     with PEDIDO->Veiculos
            replace SH_APCOM->Cod_eqpto    with PEDIDO->Equipto

         endif

         PARCELA->(dbskip())

      enddo

   endif

   if ! PEDIDO->Fiscal .and. PEDIDO->Cod_fisc <> "999" .and. PEDIDO->(qrlock())

      if SH_FICOM->(qappend())

         // ATUALIZA FLAG DE INTERFACIAMENTO ________________________________

         replace PEDIDO->Fiscal with .T.

         replace SH_FICOM->Data_lanc  with PEDIDO->Data_baixa
         replace SH_FICOM->Filial     with alltrim(PEDIDO->Filial)
         replace SH_FICOM->Num_nf     with PEDIDO->Numero_nf
         replace SH_FICOM->Especie    with PEDIDO->Especie
         replace SH_FICOM->Serie      with PEDIDO->Serie
         replace SH_FICOM->Data_emis  with PEDIDO->Data_emiss
         replace SH_FICOM->Cod_forn   with PEDIDO->Cod_forn
         replace SH_FICOM->Vlr_cont   with PEDIDO->Val_liq
         replace SH_FICOM->Cod_fisc   with PEDIDO->Cod_fisc

         if PEDIDO->Red_icms == 0
            replace SH_FICOM->Icm_base   with nVAL_BASE := PEDIDO->Val_liq
         else
            replace SH_FICOM->Icm_base   with nVAL_BASE := PEDIDO->Val_liq - ((PEDIDO->Val_liq * PEDIDO->Red_icms)/100)
         endif

         replace SH_FICOM->Icm_red    with PEDIDO->Red_icms

         replace SH_FICOM->Icm_aliq   with PEDIDO->Aliq_icms

         replace SH_FICOM->Icm_vlr    with PEDIDO->Valor_icm

         replace SH_FICOM->Icm_isen   with PEDIDO->Val_liq - nVAL_BASE

         replace SH_FICOM->Icm_out    with PEDIDO->Val_liq - nVAL_BASE - SH_FICOM->Icm_isen

         do case
            case SH_FICOM->Icm_isen <> 0
                 replace SH_FICOM->Icm_cod    with "4"
            case SH_FICOM->Icm_out <> 0
                 replace SH_FICOM->Icm_cod    with "9"
            otherwise
                 replace SH_FICOM->Icm_cod    with "0"
         endcase

         LANC->(dbseek(PEDIDO->Codigo))
         PROD->(dbseek(LANC->Cod_prod))

         replace SH_FICOM->Ipi_vlr    with PEDIDO->Valor_ipi

         if SH_FICOM->Ipi_vlr <> 0
            replace SH_FICOM->Ipi_base   with PEDIDO->Val_pedido
         else
            replace SH_FICOM->Ipi_isen   with PEDIDO->Val_pedido
         endif

         if SH_FICOM->Ipi_isen <> 0
            replace SH_FICOM->Ipi_out    with PEDIDO->Val_pedido
         endif

      endif

   endif

   if ! PEDIDO->Contabil .and. PEDIDO->(qrlock())

      if SH_CONTA->(qappend())

         // ATUALIZA FLAG DE INTERFACEAMENTO ________________________________

         replace PEDIDO->Contabil with .T.

         replace SH_CONTA->Codigo     with PEDIDO->Cod_forn
         replace SH_CONTA->Num_nota   with PEDIDO->Numero_nf
         replace SH_CONTA->Data_lanc  with PEDIDO->Data_baixa
         replace SH_CONTA->Serie      with PEDIDO->Serie
         FORN->(dbsetorder(1))
         FORN->(dbseek(PEDIDO->Cod_forn))
         replace SH_CONTA->Ca         with FORN->Razao
         replace SH_CONTA->Cgc        with FORN->Cgccpf
         replace SH_CONTA->Dp         with PEDIDO->Numero_nf
         ESPECIE->(dbseek(PEDIDO->Especie))
         replace SH_CONTA->Ep         with ESPECIE->Descricao
         replace SH_CONTA->Fa         with PEDIDO->Numero_nf
         replace SH_CONTA->Nf         with PEDIDO->Numero_nf
         replace SH_CONTA->Pc         with PEDIDO->Codigo
         SERIE->(dbseek(PEDIDO->Serie))
         replace SH_CONTA->Se         with SERIE->Descricao

      endif

   endif

   SH_APCOM->(qunlock())
   SH_APCOM->(dbclosearea())

   SH_FICOM->(qunlock())
   SH_FICOM->(dbclosearea())

   SH_CPEST->(qunlock())
   SH_CPEST->(dbclosearea())

   SH_CONTA->(qunlock())
   SH_CONTA->(dbclosearea())

   PEDIDO->(qunlock())

   qmensa("")

return

/////////////////////////////////////////////////////////////////
// BAIXA DO PEDIDO DE COMPRAS ___________________________________

static function i_baixa_pedido

   local cFATOR := 1
   local nCURSOR := setcursor(1)
   local cSAL_ANT := 0

   qlbloc(11,01,"B204E","QBLOC.GLO",1)
   i_inc_bx()

   setcursor(nCURSOR)

// if PEDIDO->(qrlock()) .and. PROD->(qflock())
// if PEDIDO->(qrlock()) .and. INVENT->(qflock())
//
//    if LANC->(dbseek(PEDIDO->Codigo))
//
//       do while LANC->Cod_ped == PEDIDO->Codigo .and. ! LANC->(eof())
//
//          if INVENT->(dbseek(PEDIDO->Filial+LANC->Cod_prod))
//
//             cSAL_ANT := INVENT->Quant_atu
//
//             replace INVENT->Quant_atu with ( INVENT->Quant_atu  + ( LANC->Quant * LANC->Fator ))
//             replace INVENT->Preco_uni with ( INVENT->Preco_uni + (LANC->Preco / LANC->Fator) ) / 2
//
//             if MOVIMENT->(qrlock()) .and. MOVIMENT->(qappend())
//
//                replace MOVIMENT->Data       with PEDIDO->Data_baixa
//                replace MOVIMENT->Filial     with PEDIDO->Filial
//                replace MOVIMENT->Cod_prod   with right(PROD->Codigo,5)
//                replace MOVIMENT->Quantidade with LANC->Quant * LANC->Fator
//                replace MOVIMENT->Val_uni    with LANC->Preco / LANC->Fator
//                replace MOVIMENT->Saldo_ant  with cSAL_ANT
//                replace MOVIMENT->Tipo       with "E"
//                replace MOVIMENT->Contabil   with .T.
//
//             endif
//
//          endif
//
//          LANC->(dbskip())
//
//       enddo
//
//    endif
//
// endif
//
// dbunlockall()

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO QUE INCLUI OS DADOS PARA BAIXA DO PEDIDO DE COMPRAS _______________

static function i_inc_bx

   local lCONF
   local aEDICAO := {}
   local bESCAPE := {||empty(cDATA_BAIXA).and.!XFLAG.or.;
                       lastkey()==27}

   private cDATA_BAIXA := ctod("")
   private cNUMERO_NF  := space(6)
   private cSERIE      := space(2)
   private cESPECIE    := space(2)
   private cDATA_EMISS := ctod("")

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || qgetx(12,22,@cDATA_BAIXA, "@D"                ) } ,"DATA_BAIXA"})
   aadd(aEDICAO,{{ || qgetx(12,67,@cNUMERO_NF , "999999"            ) } ,"NUMERO_NF"})
   aadd(aEDICAO,{{ || view_serie(13,10,@cSERIE     , "@E 99"             ) } ,"SERIE"})
   aadd(aEDICAO,{{ || NIL                                              } ,NIL        })
   aadd(aEDICAO,{{ || view_especie(13,53,@cESPECIE   , "@E 99"             ) } ,"ESPECIE"})
   aadd(aEDICAO,{{ || NIL                                              } ,NIL        })
   aadd(aEDICAO,{{ || qgetx(14,28,@cDATA_EMISS, "@D"                ) } ,"DATA_EMISS"})

   aadd(aEDICAO,{{ || lCONF := qconf("Confirma Dados da Baixa  ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   XNIVEL := 1
   XFLAG  := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; return ; endif
      if ! i_crit2( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   if ! lCONF ; return ; endif

   // GRAVACAO ______________________________________________________________

   if PEDIDO->(qrlock())

      replace PEDIDO->Data_baixa with cDATA_BAIXA
      replace PEDIDO->Data_emiss with cDATA_EMISS
      replace PEDIDO->Numero_nf  with cNUMERO_NF
      replace PEDIDO->Serie      with cSERIE
      replace PEDIDO->Especie    with cESPECIE

      i_interface()

   else

      iif(cOPCAO=="I",qm1(),qm2())

   endif

return

/////////////////////////////////////////////////////////////////////////////
// CRITICAS NA DESCIDA ______________________________________________________

static function i_crit2 ( cCAMPO )

   qmensa("")

   iif ( cCAMPO == NIL , cCAMPO := "" , NIL )

   do case

      case cCAMPO == "DATA_BAIXA"

           if empty(cDATA_BAIXA) ; return .F. ; endif

           if cDATA_BAIXA < PEDIDO->DATA_PED .and. ! empty(cDATA_BAIXA)
              qmensa("A data da baixa n„o pode ser anterior a data do pedido !","B")
              return .F.
           endif

      case cCAMPO == "DATA_EMISS"

           if empty(cDATA_EMISS) ; return .F. ; endif


      case cCAMPO == "SERIE"

           if ! SERIE->(dbseek(cSERIE))
              qmensa("Serie n„o encontrada !","B")
              return .F.
           endif

           qsay(13,15,left(SERIE->Descricao,10))

      case cCAMPO == "ESPECIE"

           if ! ESPECIE->(dbseek(cESPECIE))
              qmensa("Especie n„o encontrada !","B")
              return .F.
           endif

           qsay(13,58,left(ESPECIE->Descricao,10))

      case cCAMPO == "NUMERO_NF"

           if empty(cNUMERO_NF) ; return .F. ; endif


   endcase

return .T.

/////////////////////////////////////////////////////////////////
static function i_init_parcela

   if PARCELA->(dbseek(PEDIDO->Codigo))
      for nCONT := 1 to 5
           aPARCELA[nCONT,1] := PARCELA->Dia
           aPARCELA[nCONT,2] := PARCELA->Data
           aPARCELA[nCONT,3] := PARCELA->Valor
           PARCELA->(dbskip())
           if PEDIDO->Codigo <> PARCELA->Cod_ped
              exit
           endif
      next
   else
      return
   endif

   // INICIA VARIAVEIS PARA EDICAO _______________________________________________

   nDIA_1   := aPARCELA[1,1]
   nDIA_2   := aPARCELA[2,1]
   nDIA_3   := aPARCELA[3,1]
   nDIA_4   := aPARCELA[4,1]
   nDIA_5   := aPARCELA[5,1]
   dDATA_1  := aPARCELA[1,2]
   dDATA_2  := aPARCELA[2,2]
   dDATA_3  := aPARCELA[3,2]
   dDATA_4  := aPARCELA[4,2]
   dDATA_5  := aPARCELA[5,2]
   nVALOR_1 := aPARCELA[1,3]
   nVALOR_2 := aPARCELA[2,3]
   nVALOR_3 := aPARCELA[3,3]
   nVALOR_4 := aPARCELA[4,3]
   nVALOR_5 := aPARCELA[5,3]

return

static function i_marca

  if LANC->Parcial == " "
     if LANC->(Qrlock())
        replace LANC->Parcial with "*"
        qunlock()
     endif
  else
     if LANC->(Qrlock())
        replace LANC->Parcial with " "
        qunlock()
     endif
  endif
return

static function i_Baixar
local nREG
    nTOT_PED := 0
    i_verifica()

    nREG := LANC->(recno())

    if ! PEDIDO->Interface .or. empty(PEDIDO->Data_baixa)
       LANC->(Dbseek(PEDIDO->Codigo))
       do while ! LANC->(Eof()) .and. PEDIDO->Codigo == LANC->Cod_ped

          if LANC->Parcial == "*"
             INVENT->(Dbsetorder(1))
             INVENT->(Dbgotop())

             LOTES->(dbsetorder(1))
             LOTES->(Dbgotop())

             if INVENT->(dbseek(alltrim(PEDIDO->Filial)+LANC->Cod_prod+LANC->Lote))
                if INVENT->(qrlock())
                   replace INVENT->Quant_atu with (INVENT->Quant_atu + LANC->Quant)
                   INVENT->(qunlock())
                endif
             endif

             if LOTES->(dbseek(LANC->Cod_prod+alltrim(PEDIDO->Filial)+LANC->Lote))
                if LOTES->(qrlock())
                   replace LOTES->Quantidade with (LOTES->Quantidade + LANC->Quant)
                   LOTES->(qunlock())
                endif
             endif
           
          else
             nTOT_PED := nTOT_PED + (LANC->Quant * LANC->Preco)
             nTOT_PED := nTOT_PED + ( ( (LANC->Quant * LANC->Preco) * LANC->Aliq_Ipi) / 100 )

             if lTEM
                if lNADA
                   dup_Lanc()
                endif
             endif


          endif
          LANC->(DbSkip())
       Enddo
       if lTEM
          if lNADA
            Dup_ped()
          endif
       endif

       if PEDIDO->(qrlock())
//          replace PEDIDO->Interface with .T.
//          replace PEDIDO->Data_baixa with Date()
       endif
       LANC->(dbgoto(nREG))

    else
      qmensa("Pedido ja foi Baixado !!!","B")

    endif

return

static function Dup_ped
local nREG


 nREG := PEDIDO->(Recno())
 PEDIDO->(qpublicfields())
 PEDIDO->(qcopyfields())
 nLETRA := right(PEDIDO->Codigo,1)
 i_Letra()
 fCODIGO := left(fCODIGO,9) + nLETRA
 fVAL_PEDIDO := nTOT_PED
 fVAL_LIQ    := nTOT_PED
 PEDIDO->(Qappend())
 PEDIDO->(qreplacefields())
 PEDIDO->(qreleasefields())
 PEDIDO->(DbGoto(nREG))

return

static function Dup_lanc
local nREG

 nREG := LANC->(Recno())
 LANC->(qpublicfields())
 LANC->(qcopyfields())
 nLETRA := right(fCOD_PED,1)
 i_Letra()
 fCOD_PED := left(fCOD_PED,9) + nLETRA

 LANC->(Qappend())
 LANC->(qreplacefields())
 LANC->(qreleasefields())
 LANC->(DbGoto(nREG))

return

static function I_Letra

   do case
      case  nLETRA == "K"
            nLETRA := "L"

      case  nLETRA == "J"
            nLETRA := "K"

      case  nLETRA == "I"
            nLETRA := "J"

      case  nLETRA == "H"
            nLETRA := "I"

      case  nLETRA == "G"
            nLETRA := "H"

      case  nLETRA == "F"
            nLETRA := "G"

      case  nLETRA == "E"
            nLETRA := "F"

      case  nLETRA == "D"
            nLETRA := "E"

      case  nLETRA == "C"
            nLETRA := "D"

      case  nLETRA == "B"
            nLETRA := "C"

      case  nLETRA == "A"
            nLETRA := "B"

      case  nLETRA == " "
            nLETRA := "A"
   endcase

return

static function i_verifica
local nREG
   lTEM := .F.
   lNADA := .F.
   nREG := LANC->(Recno())
   LANC->(Dbseek(PEDIDO->Codigo))
   do while ! LANC->(Eof()) .and. PEDIDO->Codigo == LANC->Cod_ped

      if LANC->Parcial == "*"
         lTEM := .T.
      endif

      if LANC->Parcial == " "
         lNADA := .T.
      endif


      LANC->(DbSkip())
   Enddo

   LANC->(dbgoto(nREG))

return


