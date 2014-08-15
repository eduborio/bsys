/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE COMPRAS
// OBJETIVO...: CONSULTA DE PEDIDO DE COMPRAS DO ARQUIVO MORTO
// ANALISTA...:
// PROGRAMADOR: LUCINEIDE VILAR POSSEBOM
// INICIO.....: NOVEMBRO DE 1996
// OBS........:
// ALTERACOES.:

function cp302

#include "inkey.ch"

private sBLOC1  := qlbloc("B302E","QBLOC.GLO")

private cT_ORDE_COM   // Variavel temporario para lancamento fORDE_COM
private dT_DATA_PED   // Variavel temporario para lancamento fDATA_PED
private cT_CENTRO     // Variavel temporario para lancamento fCENTRO
private cT_FILIAL     // Variavel temporario para lancamento fFILIAL
private cT_VEICULO    // Variavel temporario para lancamento fVEICULO
private cT_EQUIPTO    // Variavel temporario para lancamento fVEICULO
private cT_TIPO       // Variavel temporario para lancamento fTIPO
private cT_COMPRADOR  // Variavel temporario para lancamento fCOMPRADOR
private cT_COD_FORN   // Variavel temporario para lancamento fCOD_FORN
private cT_COD_FISC   // Variavel temporario para lancamento fCOD_FISC
private cCOD_FORN     // Codigo do fornecedor temporario
private cMOTIVO := space(50)  // Descricao de motivo de compra de produto com garantia
private lPRIMEIRO_LANCAMENTO := .T.
private cSENHA

private cALIQ_ICMS := 0
private cALIQ_IPI  := 0

private fCOD_VEIC
private fCOD_PROD := space(5)
private fCOD_EQUIP
private cALIAS
private cTIPO := "1"

private   cLINHA1   := "*" + replicate("-",78) + "*"
private   nVAL_PROD := 0
private   nVAL_IPI  := 0
private   nVAL_ICM  := 0
private   nALIQ_ICMS := 0
private   nVAL_NOTA := 0
private   cAPL

//fu_abre_emitente()
//fu_abre_tvar()


PROD->(dbsetorder(4))

PEDIDO2->(qview({{"i_302c()/Pedido"                                      ,2},;
                {"Data_ped/Data Ped."                                    ,1},;
                {"left(Fornecedor,33)/Fornecedor"                        ,7},;
                {"transform(Val_pedido,'@E 999,999,999.99')/Valor Pedido",0},;
                {"i_302d()/Int."                                         ,0}},"P",;
                {NIL,"i_302b",NIL,NIL},;
                NIL,"<ESC>-Sai/<C>onsulta/<T>ransferencia/Im<P>rimir"))


//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAGEM DO FORNECEDOR ___________________________________________

function i_302c
return transform(PEDIDO2->Codigo,"@R 99999/9999")

//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INFORMAR SE FOI FEITO O INTERFACE _________________________________

function i_302d
   local cSIMNAO
   do case
      case PEDIDO2->Interface == .T.
           cSIMNAO := "SIM"
      case PEDIDO2->Interface == .F.
           cSIMNAO := "NŽO"
   endcase
return cSIMNAO

//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO _____________________________________

function i_302b

   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO == "C"

      qlbloc(5,0,"B302A","QBLOC.GLO",1)
      i_edicao()
      CCUSTO->(dbSetFilter())
   endif

   if cOPCAO == "T"

         qgirabarra()

         qmensa ( "Aguarde... Transferindo Pedido " + PEDIDO2->Codigo )

         PARCELA2->(Dbsetorder(1))

         if PARCELA2->(Dbseek(PEDIDO2->Codigo))

            do while ! PARCELA2->(eof()) .and. PARCELA2->Cod_ped == PEDIDO2->Codigo

               PARCELA2->(qpublicfields())

               if PARCELA->(qappend()) .and. PARCELA->(qrlock()) .and. PARCELA2->(qrlock())

                  PARCELA2->(qcopyfields())
                  PARCELA->(qreplacefields())
                  PARCELA2->(dbdelete())

                  PARCELA->(qunlock())

               else

                  qmensa("N„o foi possivel realizar a transferencia...","B")

               endif

               PARCELA2->(Dbskip())

            enddo

            LANC2->(Dbsetorder(1))

            if LANC2->(Dbseek(PEDIDO2->Codigo))

               do while ! LANC2->(eof()) .and. LANC2->Cod_ped == PEDIDO2->Codigo

                  LANC2->(qpublicfields())

                  if LANC->(qappend()) .and. LANC->(qrlock()) .and. LANC2->(qrlock())

                     LANC2->(qcopyfields())
                     LANC->(qreplacefields())
                     LANC2->(dbdelete())

                     LANC->(qunlock())

                  else
                     qmensa("N„o foi possivel realizar a transferencia...","B")
                  endif

                  LANC2->(Dbskip())

               enddo

            endif

            PEDIDO2->(qpublicfields())

            if PEDIDO->(qappend()) .and. PEDIDO->(qrlock()) .and. PEDIDO2->(qrlock())

               PEDIDO2->(qcopyfields())
               PEDIDO->(qreplacefields())
               PEDIDO2->(dbdelete())

               PEDIDO->(qunlock())

            else
               qmensa("N„o foi possivel realizar a transferencia...","B")
            endif

         endif

   endif


   if cOPCAO == "P"

      PROD->(dbsetorder(4))

      // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

      if ! qinitprn() ; return ; endif

      qmensa("Emitindo pedido.....")

      // PEGA RAZAO DO CLIENTE ______________________________________________

      FORN->(dbseek(PEDIDO2->Cod_forn))

      // PEGA ESTADO NO CGM _________________________________________________

      if CGM->(dbseek(FORN->Cgm_cob))
         cESTADO    := CGM->Estado
         cMUNICIPIO := CGM->Municipio
      endif

      // PEGA DESCRICAO DO GRUPO ____________________________________________

      LANC2->(dbseek(PEDIDO2->Codigo))
      PROD->(dbseek(right(LANC2->Cod_prod,5)))
      CAD_COMP->(dbseek(PEDIDO2->Comprador))
      FILIAL->(dbseek(PEDIDO2->Filial))

      setprc(0,0)

      @ prow()+1,0  say cLINHA1
      @ prow()+1,0  say "|" + XAEXPAN + XAENFAT + "PEDIDO DE COMPRA          No.: " + transform(PEDIDO2->Codigo,"@R 99999/9999") + XDEXPAN + XDENFAT + "|"
      @ prow()+1,0  say "| Data do Pedido: " + dtoc(PEDIDO2->Data_ped) + "   Baixa em " + dtoc(PEDIDO2->Data_baixa) + space(33) + "|"
      @ prow()+1,0  say "| Comprador: " + CAD_COMP->Nome + space(36) + "|"
      @ prow()+1,0  say cLINHA1
      @ prow()+1,0  say "|Fornecedor..: " + left(FORN->Razao,40) +   " Contato: " + left(FORN->Contato_c,14) + "|"
      @ prow()+1,0  say "|Endereco....: " + left(FORN->End_cob,40) + " Fone...: " + FORN->Fone1 +  "|"
      @ prow()+1,0  say "|Cidade......: "  + cMUNICIPIO + " Estado: " + cESTADO + " Cep...: " + transform(FORN->Cep_cob,"@R 99.999-999") + "    |"
      @ prow()+1,0  say cLINHA1
      @ prow()+1,0  say "| Dados do Faturamento (Nosso Estabelecimento)" + space(33) + "|"
      @ prow()+1,0  say "| --------------------------------------------" + space(33) + "|"
      @ prow()+1,0  say "| Filial.....: " + left(FILIAL->Razao,40) + space(24) + "|"
      @ prow()+1,0  say "| Endereco...: " + left(FILIAL->Endereco,36) + " C.G.C.: " + transform(FILIAL->Cgccpf,"@R 99.999.999/9999-99") + " |"
      CGM->(dbseek(FILIAL->Cgm))
      @ prow()+1,0  say "| Cidade.....: " + left(CGM->Municipio,15) + " U.F.: " + CGM->Estado + "   Inscricao: " + FILIAL->Insc_estad + space(11) + "|"

      @ prow()+1,0  say cLINHA1 + XAENFAT
      @ prow()+1,0  say "| Cond. de Pagamento:" + space(58) + "|"
      @ prow()+1,0  say "| -------------------" + space(58) + "|"
      PARCELA2->(dbseek(PEDIDO2->Codigo))
      nPARCELA := 1
      do while ! PARCELA2->(eof()) .and. PARCELA2->Cod_ped == PEDIDO2->Codigo
         @ prow()+1,0 say "| Parc.: " + strzero(nPARCELA,2) + " - " + strzero(PARCELA2->Dia,3) + " Dias - Data Pag.: " + dtoc(PARCELA2->Data) + " Valor: " + transform(PARCELA2->Valor,"@E 999,999.99") + space(17) + "|"
         nPARCELA++
         PARCELA2->(dbskip())
      enddo

      @ prow()+1,0  say XDENFAT + cLINHA1
      @ prow()+1,0  say "| Nota Fiscal: " + PEDIDO2->Numero_nf + " Serie: " + PEDIDO2->Serie + " Especie: " + PEDIDO2->Especie + space(36) + "|"
      @ prow()+1,0  say cLINHA1

      @ prow()+1,0  say "|   Pedimos fornecer o material abaixo descrito, de acordo com especificacoes  |"
      @ prow()+1,0  say "| estipuladas na presente ORDEM DE COMPRA.                                     |"


      @ prow()+1,0  say cLINHA1
      @ prow()+1,0  say "|Cod.|          Descricao       | APL.|  Qnt.  |   Valor  |  Valor  |IPI|      |"
      @ prow()+1,0  say "|    |                          |     |        |   Unit.  |  Total  | % |  IPI |"
      @ prow()+1,0  say cLINHA1

      do while ! LANC2->(eof())

         if LANC2->Cod_ped == PEDIDO2->Codigo
            if ! empty(LANC2->Cod_prod)
               PROD->(dbgotop())
               PROD->(dbseek(right(LANC2->Cod_prod,5)))
            endif

            nVAL_PROD += LANC2->Quant * LANC2->Preco
            nVAL_IPI  += LANC2->Quant * LANC2->Preco * LANC2->Aliq_ipi /100

            if PROD->Prod_iss == "N"
               nVAL_ICM  += LANC2->Quant * LANC2->Preco * LANC2->Aliq_icms  // Soma valor dos produtos para icms
               nALIQ_ICMS := LANC2->Aliq_icms
            endif

            @ prow(),pcol() say XCOND1

            do case
               case ! empty(LANC2->Cod_veic)
                    VEICULOS->(dbseek(LANC2->Cod_veic))
                    cAPL := left(VEICULOS->Descricao,7)
               case ! empty(LANC2->Cod_equip)
                    EQUIPTO->(dbseek(LANC2->Cod_equip))
                    cAPL := left(EQUIPTO->Descricao,7)
               case ! empty(LANC2->Centro)
                    cAPL := left(LANC2->Centro,7)
            endcase

            @ prow()+1,0 say "|  " + right(PROD->Codigo,5)                                 +;
                             " |"  + left(PROD->Descricao,45)                              +;
                             "| "  + cAPL                                                  +;
                             " | "  + transform(LANC2->Quant,"@E 999999.99999")                     +;
                             " | " + transform(LANC2->Preco , "@E 999,999,999.99999")                 +;
                             " | " + transform(LANC2->Quant * LANC2->Preco , "@E 999,999,999.99") +;
                             " | " + transform(LANC2->Aliq_ipi,"@E 99.99")                       +;
                             " | " + transform(LANC2->Quant * LANC2->Preco * LANC2->Aliq_ipi /100 , "@E 99,999.99") + "|"

            @ prow(),pcol() say XCOND0

         endif

         LANC2->(dbskip())

      enddo

      @ prow()+1,0 say cLINHA1
      @ prow()+1,0 say "|Aliquota do ICMS|  Valor do ICMS  |  Valor do IPI  |  Valor Total dos Produto |"

      // INICIA ALIQUOTA DE ICMS (EM CASO DE INCLUSAO) ______________________

      @ prow()+1,0 say "|"  + space(4) + transform(nALIQ_ICMS , "@E 99.99") + space(7) + "|" +;
                       transform(nVAL_ICM /100 , "@E 9,999,999.99") + space(5)                + "|" +;
                       transform(nVAL_IPI      , "@E 9,999,999.99") + space(4)                + "|" +;
                       space(6) +;
                       transform(nVAL_PROD     , "@e 9,999,999.99") + space(8)                + "|"

      @ prow()+1,0 say cLINHA1
      @ prow()+1,0 say "|                                                   |    Valor Total da Nota   |"
      @ prow()+1,0 say "| Suposta Data de Entrega: " + dtoc(PEDIDO2->Data_entre) + space(17) + "|" + space(6) + transform(nVAL_PROD + nVAL_IPI, "@E 999,999,999.99") + space(6) + "|"
      @ prow()+1,0 say "| Valor em extenso: (" + left(qextenso(nVAL_PROD+nVAL_IPI),57) + ")"
      @ prow()  ,79 say "|"

      if len(qextenso(nVAL_PROD+nVAL_IPI)) > 57
         @ prow()+1,0 say "| " + substr(qextenso(nVAL_PROD+nVAL_IPI),58,len(qextenso(nVAL_PROD+nVAL_IPI))) + ")"
         @ prow()  ,79 say "|"
      endif

      @ prow()+1,0 say cLINHA1
      @ prow()+1,0 say "| Observacao: " + substr(PEDIDO2->Observacao,1,65) + "|"
      @ prow()+1,0 say "|" + space(13) + substr(PEDIDO2->Observacao,66,65) + "|"
      @ prow()+1,0 say "|" + space(13) + substr(PEDIDO2->Observacao,131,65) + "|"
      @ prow()+1,0 say "|" + space(13) + substr(PEDIDO2->Observacao,196,65) + space(20) + "|"
      @ prow()+1,0 say cLINHA1

      @ prow()+6,03 say "----------------------------                    ----------------------------"
      @ prow()+1,03 say "  ASSINATURA DO COMPRADOR                          ASSINATURA DIRETORIA     "

      eject

      qstopprn(.F.)

   endif

   setcursor(nCURSOR)

   select PEDIDO2
   PEDIDO2->(dbsetorder(2))

return ""

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

   if cOPCAO == "C"

      XNIVEL := 1

      qsay ( 6,22, PEDIDO2->Codigo ,"@R 99999/9999" )
      qsay ( 6,47, PEDIDO2->Data_ped  )
      qsay ( 6,73, PEDIDO2->Orde_com  )
      qsay ( 7,22, left(PEDIDO2->Filial,4)    ) ; FILIAL->(dbseek(PEDIDO2->Filial))
      qsay ( 7,29, left(FILIAL->Razao,40))
      qsay ( 8,22, left(PEDIDO2->Centro,4)    ) ; CCUSTO->(dbseek(PEDIDO2->Centro))
      qsay ( 8,29, CCUSTO->Descricao )
      qsay ( 9,14, PEDIDO2->Veiculos  ) ; VEICULOS->(dbseek(PEDIDO2->Veiculos))
      qsay ( 9,20, VEICULOS->Descricao )
      qsay ( 9,51, PEDIDO2->Equipto   ) ; EQUIPTO->(dbseek(PEDIDO2->Equipto))
      qsay ( 9,57, left(EQUIPTO->Descricao,20) )
      qsay (10,22, PEDIDO2->Tipo      ) ; TIPOCONT->(dbseek(PEDIDO2->Tipo))
      qsay (10,31, alltrim(TIPOCONT->Descricao))
      qsay (11,22, PEDIDO2->Comprador ) ; CAD_COMP->(dbseek(PEDIDO2->Comprador))
      qsay (11,31, CAD_COMP->Nome    )

      qsay (11,73, qabrev(PEDIDO2->Estoque,"SN", {"Sim","N„o"}))

      qsay (12,22, PEDIDO2->Cod_forn  ) ; FORN->(dbseek(PEDIDO2->Cod_forn))
      qsay (12,31, left(FORN->Razao,45))
      qsay (13,22, PEDIDO2->Cod_Fisc , "@R 9.99" ) ; NATOP->(dbseek(PEDIDO2->Cod_Fisc))
      qsay (13,31, NATOP->Nat_Desc   )
   endif

   // CONSULTA OU EXCLUSAO _______________________________________________________

   if cOPCAO == "C" ; i_consulta() ; return ; endif



// PARA CONSULTAR A SEGUNDA TELA _________________________________________________

static function i_consulta
   local nTECLA, nCONT
   setpos(24,79)

   if cOPCAO <> "A"
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
         qlbloc(5,2,"B302B","QBLOC.GLO",1)

         qrsay ( XNIVEL++  , PEDIDO2->Data_adto  , "@D" )
         qrsay ( XNIVEL++  , PEDIDO2->Valor_adto , "@E 9,999,999.99" )

         qrsay ( XNIVEL++  , PEDIDO2->DESC_COND   , "@E 99.99" )
         qrsay ( XNIVEL++  , PEDIDO2->VL_DESC_C  , "@E 9,999,999.99" )

         qrsay ( XNIVEL++  , PEDIDO2->DESC_INCON  , "@E 99.99" )
         qrsay ( XNIVEL++  , PEDIDO2->VL_DESC_I  , "@E 9,999,999.99" )

         qrsay ( XNIVEL++  , PEDIDO2->IRRF        , "@E 99.99" )
         qrsay ( XNIVEL++  , PEDIDO2->VL_IRRF    , "@E 9,999,999.99" )

         qrsay ( XNIVEL++  , PEDIDO2->RED_ICMS    , "@E 99.99" )
         qrsay ( XNIVEL++  , PEDIDO2->VL_RED_IC  , "@E 9,999,999.99" )

         qrsay ( XNIVEL++  , PEDIDO2->VL_FRETE   , "@E 9,999,999.99" )
         qrsay ( XNIVEL++  , PEDIDO2->VL_SEGURO  , "@E 9,999,999.99" )

         for nCONT := 1 to 5
             qrsay(XNIVEL++,strzero(aPARCELA[nCONT,1],3))
             qrsay(XNIVEL++,aPARCELA[nCONT,2])
             qrsay(XNIVEL++,aPARCELA[nCONT,3],"@E 9,999,999.99")
         next

         qrsay ( XNIVEL++ , PEDIDO2->Val_LIQ , "@E 999,999,999.99" )
         qrsay ( XNIVEL++ , PEDIDO2->Data_entre)
         qrsay ( XNIVEL++ , PEDIDO2->Data_baixa)
         qrsay ( XNIVEL++ , PEDIDO2->Numero_nf )
         qrsay ( XNIVEL++ , PEDIDO2->Serie     ) ; SERIE->(dbseek(PEDIDO2->Serie))
         qrsay ( XNIVEL++ , left(SERIE->Descricao,15)  )
         qrsay ( XNIVEL++ , PEDIDO2->Especie   ) ; ESPECIE->(dbseek(PEDIDO2->Especie))
         qrsay ( XNIVEL++ , left(ESPECIE->Descricao,15))
         qrsay ( XNIVEL++ , PEDIDO2->Data_emiss)
         qrsay ( XNIVEL++ , left(PEDIDO2->Observacao,57))
         qwait()
         exit
      endif
   enddo
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ATUALIZAR LANCAMENTOS NA TELA ________________________________

static function i_atualiza_lancs

   LANC2->(qview({{"Cod_prod/Cod."                                 ,2},;
                 {"f302d()/Descri‡„o"                             ,0},;
                 {"alltrim(Centro)/Cent."                         ,0},;
                 {"transform(Preco,'@E 999,999,999.99999')/Val. Un."    ,0},;
                 {"transform(Quant,'@E 999999.99999')/Quant."       ,0},;
                 {"f302e()/Un."                                   ,0},;
                 {"f302c()/Val. Total"                            ,0}},;
                 "14002179S",;
                 {NIL,NIL,NIL,NIL},;
                 {"LANC2->Cod_ped==PEDIDO2->Codigo",{||f302top()},{||f302bot()}},;
                 "<ESC> para sair"))

return

//////////////////////////////////////////////////////////////////////////////////
// PARA INICIAR PARCELAS DO PEDIDO _______________________________________________

static function i_init_parcela

   if PARCELA2->(dbseek(PEDIDO2->Codigo))
      for nCONT := 1 to 5
           aPARCELA[nCONT,1] := PARCELA2->Dia
           aPARCELA[nCONT,2] := PARCELA2->Data
           aPARCELA[nCONT,3] := PARCELA2->Valor
           PARCELA2->(dbskip())
           if PEDIDO2->Codigo <> PARCELA2->Cod_ped
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

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IR PARA O INICIO DOS DADOS FILTRADOS _________________________

function f302top
   LANC2->(dbsetorder(1))
   LANC2->(dbseek(PEDIDO2->Codigo))
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IR PARA O FINAL DOS DADOS FILTRADOS __________________________

function f302bot
   LANC2->(dbsetorder(1))
   LANC2->(qseekn(PEDIDO2->Codigo))
return

/////////////////////////////////////////////////////////////////////////////
// RETORNA A UNIDADE DO PRODUTO _____________________________________________

function f302e
   PROD->(dbseek(LANC2->Cod_prod))
   UNIDADE->(dbseek(PROD->Unidade))
return UNIDADE->Sigla

/////////////////////////////////////////////////////////////////////////////
// RETORNA O VALOR TOTAL DO PRODUTO _________________________________________

function f302c
return transform((LANC2->Preco * LANC2->Quant)+(LANC2->Preco*LANC2->Quant*LANC2->Aliq_ipi/100),"@E 99,999,999.99")

/////////////////////////////////////////////////////////////////////////////
// FUNCAO DE CONTROLE PRINCIPAL ANTES DE PROCESSAR A TECLA ACIONADA _________

function f302d

   local cDESCRICAO := space(15)

   i_totaliza_pedidos()

   qsay ( 22,17 , transform(nTOT_ICM , "@E 999,999.99") )
   qsay ( 22,43 , transform(nTOT_IPI , "@E 999,999.99") )
   qsay ( 22,68 , transform(nTOT_ISS , "@E 999,999.99") )

   if ! empty(LANC2->Cod_prod)
      PROD->(dbseek(LANC2->Cod_prod))
      cDESCRICAO := left(PROD->Descricao,15)
   endif

return cDESCRICAO

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA TOTALIZAR VARIAVEIS DO PEDIDO ________________________________

static function i_totaliza_pedidos

   local nREC := LANC2->(recno())

   fVAL_PEDIDO := nTOT_ICM := nTOT_IPI := nTOT_ISS := 0

   if cOPCAO == "C"
      fVALOR_ADTO := PEDIDO2->Valor_adto
   endif

   LANC2->(dbgotop())
   LANC2->(dbsetorder(1))
   LANC2->(dbseek(PEDIDO2->Codigo))

   do while ! LANC2->(eof()) .and. LANC2->Cod_Ped == PEDIDO2->Codigo

      PROD->(dbseek(LANC2->Cod_Prod))

      if PROD->Prod_iss == "S"
         nTOT_ISS += LANC2->Quant * LANC2->Preco
      else
         nTOT_ICM += ((LANC2->Quant * LANC2->Preco) * LANC2->Aliq_icms)  / 100
      endif

      nTOT_IPI += ((LANC2->Quant * LANC2->Preco) *  LANC2->Aliq_ipi) / 100

      fVAL_PEDIDO += LANC2->Quant * LANC2->Preco
      fVAL_LIQ    := fVAL_PEDIDO - fVALOR_ADTO
      fSUB_GRUP   := left(PROD->Codigo,4)

      LANC2->(dbskip())

   enddo

   fVAL_PEDIDO := fVAL_PEDIDO

   LANC2->(dbgoto(nREC))

return

