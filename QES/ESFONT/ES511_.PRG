////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE ESTOQUES
// OBJETIVO...: RAZAO POR PRODUTO
// ANALISTA...: EDUARDO AUGUSTO BORIO
// PROGRAMADOR: EDUARDO AUGUSTO BORIO
// INICIO.....: OUTUBRO DE 2006
// OBS........:
// ALTERACOES.:
function es511

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




if ! quse(XDRV_ES,"ESTMP",{"ESTMP"},"E")
   qmensa("N„o foi poss¡vel criar arquivo temporario !! Tente novamente.")
   return
endif

if ! quse(XDRV_ES,"ESATU",{"ESATU"},"E")
   qmensa("N„o foi poss¡vel criar arquivo temporario !! Tente novamente.")
   return
endif

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

//aadd(aEDICAO,{{ || qgetx(-1,0,@dINI)            } , "INI"    })
//aadd(aEDICAO,{{ || qgetx(-1,0,@dFIM)            } , "FIM"    })
aadd(aEDICAO,{{ || view_prod(-1,0,@cPROD)     } , "PROD"  })
aadd(aEDICAO,{{ || NIL                          } , NIL  })
aadd(aEDICAO,{{ || qesco(-1,0,@cTIPO       ,sBLOC1       )} ,"TIPO" })



do while .T.

   qlbloc(5,0,"B511A","QBLOC.GLO")
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

      case cCAMPO == "PROD"

           qrsay(XNIVEL,cPROD)

           if empty(cPROD)
              qrsay(XNIVEL+1, "Todos os Produtos.......")
           else
              PROD->(dbsetorder(4))
              if ! PROD->(Dbseek(cPROD:=strzero(val(cPROD),5)))
                 qmensa("Produto n„o Cadastrado","B")
                 return .F.
              else
                 qrsay(XNIVEL+1,left(PROD->Descricao,20)+" "+PROD->Cod_ass+" "+left(PROD->Cod_fabr,6) )
              endif
           endif

      case cCAMPO == "TIPO"
           qrsay(XNIVEL,qabrev(cTIPO," 123456", {"Todos","Produto Acabado","Matria prima","Material","Embalagens","Vazios","Outros"}))
   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // CRIA TITULO DO RELATORIO ______________________________________________

   faz_index()


   cTITULO := "Saldo de Estoque com Precos de Custo" +" de " + dtoc(dINI) + " a " + dtoc(dFIM)

   qmensa("")

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

    local nVLR_VEND  := 0
    local nVLR_VEND_TOT  := 0
    local nVLR_ENT_TOT  := 0
    local nVLR_ESTQ_TOT  := 0
    local nQTD_VEND  := 0

    local nVLR_ENT   := 0
    local nVLR_ESTQ  := 0
    local nQTD_ENT   := 0

    local nDESC      := 0
    local nTOT_GER   := 0
    local nCONT      := 0
    local nQUANT     := 0
    local nTOT_QUANT := 0
    local cPROD      := 0
    local aFAT       := {}
    local asFAT      := {}
    local nPERC      := 0
    local lPRIM := .T.
    local zPROD := space(50)

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

      if mod(val(FAT->codigo),60) == 1
         qmensa(FAT->Codigo)
      endif

      FAT->(dbskip())
      nVALOR := 0
      nDESC := 0
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

         nVALOR := 0
         nDESC := 0
   enddo

   do while ! PEDIDO->(eof())  // condicao principal de loop

      //qgirabarra()

      qmensa("Aguarde... Processando ...")

         if ! PEDIDO->Interface
            PEDIDO->(Dbskip())
            loop
         endif

         FORN->(dbseek(PEDIDO->Cod_forn))

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
         nVALOR := 0
         nDESC := 0
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

   lPRIM := .T.
   nCONT := 1
   do while ! ESTMP->(eof())

       if ESTMP->Es $ "S*B"  // Se for Saida soma as quantidade senao diminui
          nSALDO_COR := nSALDO_COR - ESTMP->Quantidade
       else

          if ESTMP->Es == "C"
             nCUSTO_COR := ( (nSALDO_COR * nCUSTO_COR) + (ESTMP->Quantidade*ESTMP->Preco_cust) ) / (nSALDO_COR+ESTMP->Quantidade)
          Endif

          nSALDO_COR := nSALDO_COR + ESTMP->Quantidade
       endif

       nCUSTO_COR := round(nCUSTO_COR,2)

       nVLR_ESTQ := (nSALDO_COR * nCUSTO_COR)



       ESTMP->(dbskip())

       if ESTMP->Produto != cPROD

          if mod(val(cPROD),5) == 1
             qmensa("Calculando custo... Aguarde...  "+cPROD)
          endif


          if ESATU->(Qappend())
             replace ESATU->Produto     with cPROD
             replace ESATU->Saldo       with nSALDO_COR
             replace ESATU->Preco_cust  with nCUSTO_COR
          endif

          cPROD := ESTMP->Produto
          //ESANT->(Dbseek(ESTMP->Produto))
          nSALDO_COR := 0//ESANT->Quantidade
          nCUSTO_COR := 0//ESANT->Preco_cust


          lPRIM := .T.

          nVLR_VEND := 0
          nQTD_VEND := 0
          nVLR_ENT  := 0
          nVLR_ESTQ := 0
          nQTD_ENT  := 0

          nQUANT := 0
          nTOTAL := 0
       endif
   enddo

   if ESATU->(Qappend())
      replace ESATU->Produto     with cPROD
      replace ESATU->Saldo       with nSALDO_COR
      replace ESATU->Preco_cust  with nCUSTO_COR
   endif


   nVLR_VEND := 0
   nQTD_VEND := 0
   nVLR_ENT  := 0
   nQTD_ENT  := 0
   nQUANT := 0
   nTOTAL := 0
   nPERC  := 0
   nVLR_VEND_TOT := 0
   nVLR_ENT_TOT := 0
   nVLR_ESTQ_TOT := 0

   if XLOCALIMP == "X"
      i_impre_xls()
   else
      i_impre_prn()
   endif

return


static function i_impre_prn
local nQUANT := 0
local nPRECO := 0

  PROD->(Dbsetorder(4))
  PROD->(Dbgotop())
  Do while ! PROD->(Eof())

     if right(PROD->Codigo,5) == "     "
        PROD->(Dbskip())
        loop
     endif

     if ! empty(cTIPO)
        if PROD->Tipo != cTIPO
           PROD->(Dbskip())
           loop
        endif
     endif

     if PROD->Fora_linha == "S"
        PROD->(Dbskip())
        loop
     endif


     if XPAGINA == 0 .or. prow() > K_MAX_LIN
        qpageprn()
        qcabecprn(cTITULO,80)
        @ prow()+1,0 say "PRODUTO                                              EM ESTOQUE   PRECO UNITARIO"
        @ prow()+1,0 say replicate("-",80)
     endif


     nQUANT := ESATU->Saldo
     nPRECO := ESATU->Preco_cust

     @ prow()+1,00 say left(PROD->Cod_fabr,7) + " - " + PROD->Cod_ass +" "+ left(PROD->Descricao,18)+" "+left(PROD->Marca,12)   + " " +;
                       iif( right(PROD->Codigo,5) <> "     " , transform(nQUANT,"@E 999,999.99") + " " +;
                       transform(nPRECO,"@E 99,999,999.99") , "")

     nQUANT := 0
     nPRECO := 0


     PROD->(Dbskip())
  enddo

  qstopprn(.f.)

return


static function i_impre_xls
local nQUANT := 0
local nPRECO := 0

  PROD->(Dbsetorder(4))
  PROD->(Dbgotop())
  Do while ! PROD->(Eof())

     if right(PROD->Codigo,5) == "     "
        PROD->(Dbskip())
        loop
     endif

     if ! empty(cTIPO)
        if PROD->Tipo != cTIPO
           PROD->(Dbskip())
           loop
        endif
     endif


     if PROD->Fora_linha == "S"
        PROD->(Dbskip())
        loop
     endif


     if XPAGINA == 0
        qpageprn()
        @ prow()+1,0 say cTITULO+chr(9)+"511"
        @ prow()+1,0 say "Produto"+Chr(9)+"Cod."+Chr(9)+"Ref."+chr(9)+"Marca"+chr(9)+"Saldo do Estoque"+Chr(9)+"Preco Custo"+chr(9)+"Valor Total"
        @ prow()+1,0 say ""
     endif


     if ESATU->(Dbseek(right(PROD->Codigo,5)))
        nQUANT := ESATU->Saldo
        nPRECO := ESATU->Preco_cust
		
		if PROD->(qrlock())
		   replace PROD->Preco_cust with nPRECO
           PROD->(qunlock())
		endif   
		   
     endif

     @ prow()+1,00 say left(PROD->Descricao,18)+chr(9)+;
                       PROD->Cod_ass+chr(9)+;
                       PROD->Cod_fabr+Chr(9)+;
                       PROD->Marca +chr(9)+;
                       transform(nQUANT,"@E 999,999.99") + chr(9) +;
                       transform(nPRECO,"@E 99,999,999.99")+chr(9)+;
                       transform(nQUANT*nPRECO,"@E 99,999,999.99")

     nQUANT := 0
     nPRECO := 0


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

   index on dtos(dt_emissao) tag emiss TO (XDRV_ES + "ES510A.TMP")
   dbsetindex(XDRV_ES + "es510A.TMP")


   select ITEN_FAT

   index on NUM_FAT tag num TO (XDRV_ES + "ES510B.TMP")
   dbsetindex(XDRV_ES + "es510B.TMP")


   select PEDIDO

   index on dtos(data_ped) tag dtp TO (XDRV_ES + "ES510C.TMP")
   dbsetindex(XDRV_ES + "ES510C.TMP")


   select LANC
   index on cod_ped tag UM TO (XDRV_ES + "ES510D.TMP")
   dbsetindex(XDRV_ES + "es510D.TMP")


   select MOVIMENT

   index on data tag UM TO (XDRV_ES + "ES510E.TMP")
   dbsetindex(XDRV_ES + "es510E.TMP")

return

static function erase_index

   erase(XDRV_ES+"ES510A.TMP")
   erase(XDRV_ES+"ES510B.TMP")
   erase(XDRV_ES+"ES510C.TMP")
   erase(XDRV_ES+"ES510D.TMP")
   erase(XDRV_ES+"ES510E.TMP")

return



