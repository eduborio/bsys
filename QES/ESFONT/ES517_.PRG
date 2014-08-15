////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE ESTOQUES
// OBJETIVO...: RAZAO POR PRODUTO
// ANALISTA...: EDUARDO AUGUSTO BORIO
// PROGRAMADOR: EDUARDO AUGUSTO BORIO
// INICIO.....: AGOSTO DE 2009
// OBS........:
// ALTERACOES.:
function es517

#define K_MAX_LIN 57

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG) .or. lastkey() == 27 }

private cTITULO                   // titulo do relatorio
private cDESCRICAO := space(35)                   // titulo do relatorio
private nSALDO_INI := 0                // titulo do relatorio
private nSALDO_ATU := 0               // titulo do relatorio
private nPC_INI    := 0               // Preco de Custo Inicial
private nPC_CORRENTE  := 0            // P.C. Corrente
private cTIPO := ""
private dINI
private dFIM
private cPROD := space(5)
private aEDICAO := {}             // vetor para os campos de entrada de dados
private sBLOC1    := qlbloc("B507B","QBLOC.GLO")
private XDRV_HB := "C:\QSYSTXT\"
private cFILE   := alltrim(left(XUSRIDT,7))
private aPROD := {}


if ! quse(XDRV_ES,"ESTMP",{"ESTMP"},"E")
   qmensa("N„o foi poss¡vel criar arquivo temporario !! Tente novamente.")
   return
endif

if ! quse(XDRV_ES,"ESATU",{"ESATU"},"E")
   qmensa("N„o foi poss¡vel criar arquivo temporario !! Tente novamente.")
   return
endif

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qgetx(-1,0,@dINI)            } , "INI"    })
aadd(aEDICAO,{{ || qgetx(-1,0,@dFIM)            } , "FIM"    })
//aadd(aEDICAO,{{ || view_prod(-1,0,@cPROD)     } , "PROD"  })
//aadd(aEDICAO,{{ || NIL                          } , NIL  })
//aadd(aEDICAO,{{ || qesco(-1,0,@cTIPO       ,sBLOC1       )} ,"TIPO" })



do while .T.

   qlbloc(5,0,"B517A","QBLOC.GLO")
   XNIVEL := 1
   XFLAG  := .T.
   nSALDO_INI := 0                // SALDO Inicial de Estoque
   nSALDO_ATU := 0                // Saldo Corrente
   nPC_INI    := 0               // Preco de Custo Inicial
   nPC_CORRENTE  := 0            // P.C. Corrente
   cPROD := space(5)
   cTIPO := ""

   dINI := dFIM := ctod("")

   // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE )
         dbcloseall()
         erase_index()
         return
      endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   if ( i_inicializacao() , i_impressao() , NIL )

   closeFiles()

   qmensa("")

enddo

/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA _____________________________________________

static function i_critica ( cCAMPO )

   do case
      case cCAMPO == "FIM"
           if dFIM < dINI
             return .F.
           endif


   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // CRIA TITULO DO RELATORIO ______________________________________________

   erase_index()

   faz_index()


   cTITULO := "Precos de Custo por Pedido" +" de " + dtoc(dINI) + " a " + dtoc(dFIM)

   qmensa("")

   criaTmpFile()


   FAT->(dbsetorder(FAT->(Ordcount()))) // data de emissao
   FAT->(dbgotop())
   ITEN_FAT->(dbsetorder(ITEN_FAT->(Ordcount())))

   PEDIDO->(dbsetorder(PEDIDO->(Ordcount()))) // data de emissao
   PEDIDO->(dbgotop())
   LANC->(dbsetorder(LANC->(Ordcount())))

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impressao
    local nTOTAL     := 0
    local nSALDO_COR := 0
    local nSALDO_INI := 0
    local nCUSTO_INI := 0
    local nCUSTO_COR := 0
    local nVALOR     := 0

    local nCONT      := 0
    local nQUANT     := 0
    local cPROD      := 0
    local aFAT       := {}
    local asFAT      := {}

    ESTMP->(__dbzap())
    ESATU->(__dbzap())

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif

   do while ! FAT->(eof())  // condicao principal de loop

      if FAT->Cancelado
         FAT->(dbskip())
         loop
      endif

      if empty(FAT->Num_Fatura) .and. FAT->Es == "S"
         FAT->(DbSkip())
         loop
      endif

      if left(FAT->Cod_cfop,4) $ "5905-6905-1906-2906-5906-6906-1905-2905"
         FAT->(DbSkip())
         loop
      endif

      ITEN_FAT->(Dbseek(FAT->Codigo))
      do while ITEN_FAT->Num_fat == FAT->Codigo .and. ! ITEN_FAT->(eof())

          if ESTMP->(qappend())
             replace ESTMP->Data       with FAT->Dt_emissao
             replace ESTMP->Produto    with right(ITEN_FAT->Cod_prod,5)
             replace ESTMP->Quantidade with ITEN_FAT->Quantidade
             replace ESTMP->Es         with FAT->Es
          endif
          ITEN_FAT->(Dbskip())
      enddo

      if mod(val(FAT->codigo),75) == 1
         qgirabarra()
      endif

      FAT->(dbskip())
   enddo

   MOVIMENT->(dbsetorder(MOVIMENT->(Ordcount()))) // data de emissao
   MOVIMENT->(dbgotop())

   do while ! MOVIMENT->(eof())

         if MOVIMENT->Contabil
            MOVIMENT->(dbSkip())
            Loop
         endif

         if MOVIMENT->Tipo == "E"
            cDESCRICAO := "ENTRA"
         else
            cDESCRICAO := "SAIDA"
         endif

         if ESTMP->(qappend())
            replace ESTMP->Data       with MOVIMENT->Data
            replace ESTMP->Produto    with right(MOVIMENT->Cod_prod,5)
            replace ESTMP->Quantidade with MOVIMENT->Quantidade
            replace ESTMP->Es         with MOVIMENT->Tipo
         endif

         MOVIMENT->(dbskip())
   enddo


   do while ! PEDIDO->(eof())  // condicao principal de loop


         if ! PEDIDO->Interface
            PEDIDO->(Dbskip())
            loop
         endif

         LANC->(Dbseek(PEDIDO->Codigo))
         do while LANC->Cod_ped == PEDIDO->Codigo .and. ! LANC->(eof())

             if ESTMP->(qappend())
                replace ESTMP->Data        with PEDIDO->Data_ped
                replace ESTMP->Produto     with right(LANC->Cod_prod,5)
                replace ESTMP->Quantidade  with LANC->Quant
                replace ESTMP->Preco_cust  with LANC->Preco
                replace ESTMP->Es          with "C"
             endif

             LANC->(Dbskip())
         enddo
         PEDIDO->(dbskip())
   enddo

   i_agrupa_prod()

 return

static Function i_agrupa_prod

   ESTMP->(Dbgotop())
   ESTMP->(Dbsetorder(1))
   cPROD := ESTMP->Produto
   PROD->(dbsetorder(4))
   nSALDO_COR := 0
   nCUSTO_COR := 0

   nCONT := 1
   do while ! ESTMP->(eof())

       if ESTMP->Es $ "S*B"  // Se for Saida soma as quantidade senao diminui
          nSALDO_COR := nSALDO_COR - ESTMP->Quantidade
       else

          if ESTMP->Es == "C"
             if (cFILE)->(qappend())
                replace (cFILE)->Cod_prod  with ESTMP->Produto
                replace (cFILE)->Data      with ESTMP->Data
                replace (cFILE)->Quant_ant with nSALDO_COR
                replace (cFILE)->Preco_ant with nCUSTO_COR
                replace (cFILE)->Quant_com with ESTMP->Quantidade
                replace (cFILE)->Preco_com with ESTMP->Preco_cust
                replace (cFILE)->Quant_atu with (nSALDO_COR + ESTMP->Quantidade)
                replace (cFILE)->Preco_atu with ( (nSALDO_COR * nCUSTO_COR) + (ESTMP->Quantidade*ESTMP->Preco_cust) ) / (nSALDO_COR+ESTMP->Quantidade)
             endif

             nCUSTO_COR := ( (nSALDO_COR * nCUSTO_COR) + (ESTMP->Quantidade*ESTMP->Preco_cust) ) / (nSALDO_COR+ESTMP->Quantidade)
          Endif

          nSALDO_COR := nSALDO_COR + ESTMP->Quantidade
       endif

       nCUSTO_COR := round(nCUSTO_COR,2)

       ESTMP->(dbskip())

       if ESTMP->Produto != cPROD

          if mod(val(cPROD),25) == 1
             qmensa("Calculando custo... Aguarde...  "+cPROD)
          endif


          if ESATU->(Qappend())
             replace ESATU->Produto     with cPROD
             replace ESATU->Saldo       with nSALDO_COR
             replace ESATU->Preco_cust  with nCUSTO_COR
          endif

          cPROD := ESTMP->Produto
          nSALDO_COR := 0//ESANT->Quantidade
          nCUSTO_COR := 0//ESANT->Preco_cust
       endif
   enddo

   if ESATU->(Qappend())
      replace ESATU->Produto     with cPROD
      replace ESATU->Saldo       with nSALDO_COR
      replace ESATU->Preco_cust  with nCUSTO_COR
   endif

   if XLOCALIMP == "X"
      i_impre_xls()
   else
      i_impre_prn()
   endif

return


static function i_impre_prn
  qstopprn(.F.)
return


static function i_impre_xls
local nQUANT := 0
local nPRECO := 0
local nIndexOf := 0

  getProdList()

  PROD->(Dbsetorder(4))
  PROD->(Dbgotop())

  (cFILE)->(dbsetorder(1))
  (cFILE)->(dbgotop())

  Do while ! PROD->(Eof())

     if right(PROD->Codigo,5) == "     "
        PROD->(Dbskip())
        loop
     endif

     nIndexOf := ascan(aPROD,right(PROD->Codigo,5))

     if nIndexOf == 0
        PROD->(Dbskip())
        loop
     endif

     if XPAGINA == 0
        qpageprn()
        @ prow()+1,0 say cTITULO+chr(9)+" 517"
        @ prow()+1,0 say "Produto"+Chr(9)+"Cod."+Chr(9)+"Ref."+chr(9)+"Marca"+chr(9)+"Saldo Antes da Compra"+Chr(9)+"Preco Custo Antes da Compra"+chr(9)+"Data da Compra"+chr(9)+"Quantidade Comprada"+chr(9)+"Preco Custo Unitario da Compra"+chr(9)+"Qtde pos Compra"+chr(9)+"Preco de Custo Atual"
        @ prow()+1,0 say ""
     endif

      if (cFILE)->(dbseek(right(PROD->Codigo,5)))

        do while ! (cFILE)->(Eof())  .and. (cFILE)->Cod_prod == right(PROD->Codigo,5)

           @ prow()+1,00 say left(PROD->Descricao,18)+chr(9)+;
                             PROD->Cod_ass+chr(9)+;
                             PROD->Cod_fabr+Chr(9)+;
                             PROD->Marca +chr(9)+;
                             transform((cFILE)->Quant_ant,"@R 999999") + chr(9) +;
                             transform((cFILE)->Preco_ant,"@E 99,999,999.99")+chr(9)+;
                             dtoc(((cFILE)->Data))+chr(9)+;
                             transform((cFILE)->Quant_com,"@R 999999") + chr(9) +;
                             transform((cFILE)->Preco_com,"@E 99,999,999.99")+chr(9)+;
                             transform((cFILE)->Quant_atu,"@R 999999") + chr(9) +;
                             transform((cFILE)->Preco_atu,"@E 99,999,999.99")

            (cFILE)->(dbskip())

        enddo
     endif

     @ prow()+2,00 say ""


     PROD->(Dbskip())
  enddo

  qstopprn(.F.)

return

static function faz_index
local cTime := ""

   if ! quse(XDRV_CL,"FAT")
      qmensa("N„o foi poss¡vel abrir FAT.DBF !! Tente novamente.")
      return
   endif

   if ! quse(XDRV_CL,"ITEN_FAT")
      qmensa("N„o foi poss¡vel abrir FAT.DBF !! Tente novamente.")
      return
   endif

   if ! quse(XDRV_CP,"PEDIDO")
      qmensa("N„o foi poss¡vel abrir FAT.DBF !! Tente novamente.")
      return
   endif

   if ! quse(XDRV_CP,"LANC")
      qmensa("N„o foi poss¡vel abrir FAT.DBF !! Tente novamente.")
      return
   endif

   if ! quse(XDRV_ES,"MOVIMENT")
      qmensa("N„o foi poss¡vel abrir FAT.DBF !! Tente novamente.")
      return
   endif

   select FAT

   cTIME := time()

   index on dtos(dt_emissao) tag emiss TO (XDRV_ES + "ES517A.TMP")
   dbsetindex(XDRV_ES + "es517A.TMP")

   select ITEN_FAT
   index on NUM_FAT tag num TO (XDRV_ES + "ES517B.TMP")
   dbsetindex(XDRV_ES + "es517B.TMP")

   select PEDIDO
   index on dtos(data_ped) tag dtp TO (XDRV_ES + "ES517C.TMP")
   dbsetindex(XDRV_ES + "ES517C.TMP")


   select LANC
   index on cod_ped tag UM TO (XDRV_ES + "ES517D.TMP")
   dbsetindex(XDRV_ES + "es517D.TMP")

   select MOVIMENT
   index on data tag UM TO (XDRV_ES + "ES517E.TMP")
   dbsetindex(XDRV_ES + "es517E.TMP")

return

static function erase_index

   erase(XDRV_ES+"ES517A.TMP")
   erase(XDRV_ES+"ES517B.TMP")
   erase(XDRV_ES+"ES517C.TMP")
   erase(XDRV_ES+"ES517D.TMP")
   erase(XDRV_ES+"ES517E.TMP")

return

static function criaTmpFile
  local aStruct := {}
  aStruct := {;
             {"COD_PROD"  ,"C",5 ,0},;
             {"DATA"      ,"D",8 ,0},;
             {"QUANT_ANT" ,"N",7 ,0},;
             {"PRECO_ANT" ,"N",12,2},;
             {"QUANT_COM" ,"N",7 ,0},;
             {"PRECO_COM" ,"N",12,2},;
             {"QUANT_ATU" ,"N",7 ,0},;
             {"PRECO_ATU" ,"N",12,2};
             }

   eraseFiles()

   dbCreate(XDRV_HB+cFILE,aStruct)

   if ! Quse(XDRV_HB,cFILE,{""})
      qmensa("Erro ao criar arquivo temporario!","BL")
      return .F.
   endif

   select (cFILE)
   index on (COD_PROD + dtos(DATA)) tag Um
   dbsetindex(XDRV_HB+cFILE)


return

static function eraseFiles

   if file(XDRV_HB+cFILE+".DBF")
      erase(XDRV_HB+cFILE+".DBF")
   endif

   if file(XDRV_HB+cFILE+".CDX")
      erase(XDRV_HB+cFILE+".CDX")
   endif

return

static function getProdList

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   aPROD := {}

   PEDIDO->(dbsetorder(PEDIDO->(Ordcount()))) // data de emissao
   PEDIDO->(dbgotop())
   set softseek on
   PEDIDO->(dbseek(dtos(dINI)))
   set softseek off

   LANC->(dbsetorder(LANC->(Ordcount())))


   do while ! PEDIDO->(eof())  .and. PEDIDO->Data_ped >= dINI .and. PEDIDO->Data_ped <= dFIM  // condicao principal de loop

      qgirabarra()

      LANC->(Dbseek(PEDIDO->Codigo))

      do while LANC->Cod_ped == PEDIDO->Codigo .and. ! LANC->(eof())
         aadd(aPROD,LANC->Cod_prod)
         LANC->(Dbskip())
      enddo

      PEDIDO->(dbskip())
   enddo

   aPROD := aSort(aPROD)

return


static function CloseFiles
  FAT->(dbCloseArea())
  PEDIDO->(dbCloseArea())
  LANC->(dbCloseArea())
  ITEN_FAT->(dbCloseArea())
  MOVIMENT->(dbCloseArea())

  eraseFiles()

return

