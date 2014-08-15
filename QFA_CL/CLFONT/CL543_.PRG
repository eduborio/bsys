/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO COMERCIO
// OBJETIVO...: LISTAGEM DE PRODUTOS FATURADOS
// ANALISTA...: EDUARDO AUGUSTO BORIO
// PROGRAMADOR: EDUARDO AUGUSTO BORIO
// INICIO.....: janeiro DE 2006
// OBS........:
// ALTERACOES.:

function cl543
#define K_MAX_LIN 57

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG) .or. empty(dINI) }

private cTITULO                   // titulo do relatorio
private dINI
private dFIM
private nLIM := 0
private cTipo := " "
private cFORA := " "
private cVIDA := " "
private sBLOC1    := qlbloc("B543B","QBLOC.GLO")
private sBLOC2    := XSN
private aReservas := {}


private aEDICAO := {}             // vetor para os campos de entrada de dados

if ! quse(XDRV_CL,"PROD_TMP",{"TMPCDPRD"},"E")
   qmensa("Nao foi possivel abrir arquivo temporario !! Tente novamente.")
   return
endif

if ! quse(XDRV_CP,"FABRICA",{""},"")
   qmensa("Nao foi possivel abrir FABRICA... Tente novamente.")
   return
endif



// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qgetx(-1,0,@dINI)            } , "INI"    })
aadd(aEDICAO,{{ || qgetx(-1,0,@dFIM)            } , "FIM"    })
aadd(aEDICAO,{{ || qgetx(-1,0,@nLIM,"999")      } , "SETOR"  })
aadd(aEDICAO,{{ || qesco(-1,0,@cTIPO       ,sBLOC1       )} ,"TIPO" })
aadd(aEDICAO,{{ || qesco(-1,0,@cFORA       ,sBLOC2       )} ,"FORA" })
aadd(aEDICAO,{{ || qesco(-1,0,@cVIDA       ,sBLOC2       )} ,"VIDA" })



do while .T.

   qlbloc(5,0,"B543A","QBLOC.GLO")
   XNIVEL := 1
   XFLAG  := .T.
   dINI := dFIM := ctod("")
   cFORA := "N"
   cVIDA := "N"

   // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; dbcloseall() ; return ; endif
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

      case cCAMPO == "TIPO"
          // if empty(cTIPO) ; return .F. ; endif
           qrsay(XNIVEL,qabrev(cTIPO," 16", {"Todos","Produto Acabado","Outros"}))

      case cCAMPO == "FORA"
           if empty(cFORA) ; return .F. ; endif
           qrsay(XNIVEL,qabrev(cFORA,"SN", {"Sim","Nao"}))

      case cCAMPO == "VIDA"
           if empty(cVIDA) ; return .F. ; endif
           qrsay(XNIVEL,qabrev(cVIDA,"SN", {"Sim","Nao"}))




   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // CRIA TITULO DO RELATORIO ______________________________________________


   cTITULO := "LISTAGEM DE ESTOQUE (M.o.S)" +" de " + dtoc(dINI) + " a " + dtoc(dFIM)

   qmensa("")

   // ESTABELECE RELACOES ENTRE ARQUIVOS ____________________________________
   
   aReservas := {}
   i_reserva()

   FAT->(dbsetorder(1)) // Codigo
   FAT->(dbgotop())
//   ITEN_FAT->(dbsetfilter({||ITEN_FAT->Data >= dINI .and. ITEN_FAT->Data <= dFIM}))
   ITEN_FAT->(dbsetorder(3))
   ITEN_FAT->(dbGotop())

   PEND->(dbsetorder(2)) // data de emissao
   PEND->(dbgotop())
   set softseek on
   PEND->(Dbseek(dtos(dINI)))
   set softseek off
   ITEM_PEN->(dbsetorder(2))

   INVOICE->(dbsetorder(2)) // data de emissao
   INVOICE->(dbgotop())
//   set softseek on
//   INVOICE->(Dbseek(dtos(dINI)))
//   set softseek off
   ITEN_INV->(dbsetorder(1))


   PED_FABR->(dbsetorder(2)) // data de emissao
   PED_FABR->(dbgotop())
 //  set softseek on
 //  PED_FABR->(Dbseek(dtos(dINI)))
 //  set softseek off
   ITEN_PED->(dbsetorder(1))
   
   

return .T.


static function i_impressao

   if ! qinitprn() ; return ; endif

   //if XLOCALIMP == "X"
   //   i_impre_xls()
   //else
      i_impre_prn()
   //endif



return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impre_prn
    local nTOTAL     := 0
    local nVALOR     := 0
    local nDESC      := 0
    local nMEDIA     := 0
    local nDIAS      := 0
    local nMESES     := 0
    local nESQMIN    := 0
    local nPEDIR     := 0
    local nMESES_POS := 0
    local nDOS       := 0 //Days of Suplies
    local nTOTDOS    := 0 //Days of Suplies
    local dDATA_ENT  := ctod("")
    local dDATA_INI  := ctod("")
    local dDATA_FIM  := ctod("")
    local nTOT_GER   := 0
    local nSALDO     := 0
    local nCONT      := 0
    local nQUANT     := 0
    local nQUANT_TER := 0
    local nTOT_QUANT := 0
    local cPROD      := 0
    local aFAT       := {}
    local aPED       := {}
    local aPEND       := {}
    local aPROD      := {}
    local asFAT      := {}
    local asPROD     := {}
    local asPED     := {}
    local asPEND     := {}

    local nPERC      := 0
    local lTEM := .T.
    local zPROD := space(50)
    local cGRUPO := space(4)
    local cDESCGRUPO := space(30)
   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________
    lTEM := .F.
   //if ! qinitprn() ; return ; endif
   PROD_TMP->(__dbzap())

   //ITEN_FAT->(dbsetfilter({||ITEN_FAT->Data >= dINI .and. ITEN_FAT->Data <= dFIM}))
   ITEN_FAT->(dbsetorder(3))
   ITEN_FAT->(dbGotop())
   cPROD := ITEN_FAT->Cod_prod

   do while ! ITEN_FAT->(eof())  //.and. FAT->Dt_emissao >= dINI .and. FAT->Dt_emissao <= dFIM  // condicao principal de loop
   
      //qmensa(ITEN_FAT->(recno()))

      FAT->(dbseek(ITEN_FAT->Num_fat))
      if FAT->Cancelado
         ITEN_FAT->(dbskip())
         if ITEN_FAT->Cod_prod != cPROD
            if nQUANT > 0 .or. nQUANT_TER > 0
               PROD->(dbseek(cPROD))
               PROD_TMP->(qappend())
               replace PROD_TMP->Cod_prod    with cPROD
               replace PROD_TMP->Quantidade  with nQUANT
               replace PROD_TMP->Preco       with PROD->Preco_cons
               replace PROD_TMP->Quant_ter   with nQUANT_TER
            endif

            cPROD := ITEN_FAT->Cod_prod

            nQUANT := 0
            nQUANT_TER := 0
            nTOTAL := 0
         endif

         loop
      endif

      if empty(FAT->Num_fatura) .and. FAT->Es == "S"
         ITEN_FAT->(dbskip())
         if ITEN_FAT->Cod_prod != cPROD
            if nQUANT > 0 .or. nQUANT_TER > 0
               PROD->(dbseek(cPROD))
               PROD_TMP->(qappend())
               replace PROD_TMP->Cod_prod    with cPROD
               replace PROD_TMP->Quantidade  with nQUANT
               replace PROD_TMP->Preco       with PROD->Preco_cons
               replace PROD_TMP->Quant_ter   with nQUANT_TER
            endif
            cPROD := ITEN_FAT->Cod_prod

            nQUANT := 0
            nQUANT_TER := 0
            nTOTAL := 0
         endif

         loop
      endif

      if FAT->Dt_emissao < dINI .or. FAT->Dt_emissao > dFIM
         ITEN_FAT->(dbskip())
         if ITEN_FAT->Cod_prod != cPROD

            if nQUANT > 0 .or. nQUANT_TER > 0
               PROD->(dbseek(cPROD))
               PROD_TMP->(qappend())
               replace PROD_TMP->Cod_prod    with cPROD
               replace PROD_TMP->Quantidade  with nQUANT
               replace PROD_TMP->Preco       with PROD->Preco_cons
               replace PROD_TMP->Quant_ter   with nQUANT_TER
            endif

            cPROD := ITEN_FAT->Cod_prod

            nQUANT := 0
            nQUANT_TER := 0
            nTOTAL := 0
         endif

         loop
      endif

//      if ! left(FAT->Cod_cfop,3) $ "510-511-512-610-611-612-591-691-120-220"
//         FAT->(dbskip())
//         loop
//      endif
//      qgirabarra()

        if FAT->Es == "S"  // Se for Saida soma as quantidades, senao diminui
           if ! left(FAT->Cod_cfop,4) $ "5905-6905"
              nQUANT += ITEN_FAT->Quantidade
              nTOT_QUANT += ITEN_FAT->Quantidade
              nTOTAL += (ITEN_FAT->Quantidade * ITEN_FAT->Vl_unitar)    //Quantidade * valor unitario
           else
              nQUANT_TER += ITEN_FAT->Quantidade
           endif
        else
           if ! left(FAT->cod_cfop,4) $ "1905-1906-2905-2906"
              nQUANT -= ITEN_FAT->Quantidade
              nTOT_QUANT -= ITEN_FAT->Quantidade
              nTOTAL -= (ITEN_FAT->Quantidade * ITEN_FAT->Vl_unitar)    //Quantidade * valor unitario
           else
              nQUANT_TER -= ITEN_FAT->Quantidade
           endif
        endif
        //qmensa(ITEN_FAT->Num_fat+"     "+cPROD+"    "+transf(nQUANT,"@R 99999"))
        //qinkey(0)

        ITEN_FAT->(dbskip())

        if ITEN_FAT->Cod_prod != cPROD

           PROD->(dbseek(cPROD))
           PROD_TMP->(qappend())
           replace PROD_TMP->Cod_prod    with cPROD
           replace PROD_TMP->Quantidade  with nQUANT
           replace PROD_TMP->Preco       with PROD->Preco_cons
           replace PROD_TMP->Quant_ter   with nQUANT_TER

           cPROD := ITEN_FAT->Cod_prod

           nQUANT := 0
           nQUANT_TER := 0
           nTOTAL := 0
        endif

        qmensa("Aguarde... Processando ...")

   enddo
   if nQUANT > 0 .or. nQUANT_TER > 0
      PROD->(dbseek(cPROD))
      PROD_TMP->(qappend())
      replace PROD_TMP->Cod_prod    with cPROD
      replace PROD_TMP->Quantidade  with nQUANT
      replace PROD_TMP->Quant_ter   with nQUANT_ter
      replace PROD_TMP->Preco       with PROD->Preco_cons
   endif


   nQUANT := 0
   nQUANT_TER := 0
   nTOTAL := 0
   nPERC  := 0
   nVALOR := 0

   lTEM := .F.
   asFAT := {}

   ////////////////////////////////////////////////////////////////////////////
   //PROCESSA PEDIDOS PENDENDES________________________________________________
   PED_FABR->(dbgotop())
   do while ! PED_FABR->(eof()) //.and. PED_FABR->Data_ped >= dINI .and. PED_FABR->Data_ped <= dFIM  // condicao principal de loop

      qmensa("Aguarde... Processando ...")

      ITEN_PED->(Dbgotop())
      ITEN_PED->(Dbseek(PED_FABR->Codigo))
      do while ITEN_PED->Cod_ped == PED_FABR->Codigo .and. ! ITEN_PED->(eof())
          PROD->(dbsetorder(4))
          PROD->(dbseek(ITEN_PED->Cod_Prod))
          //nVALOR := nVALOR +  (ITEN_PED->Valor * ITEN_PED->Quantidade)

          aadd(aPED,{right(PROD->Codigo,5),ITEN_PED->Quantidade,0,"","",nVALOR})
          nPERC += nVALOR
          ITEN_PED->(Dbskip())
          nVALOR := 0
          lTEM := .T.
      enddo

      PED_FABR->(dbskip())
      nVALOR := 0
      nDESC := 0
   enddo

   //classifica a matriz por descricao do produto
   asPED := asort(aPED,,,{|x,y| x[1] < y[1] })
   aPED := {}

   if lTEM
      cPROD := asPED[1,1]
      zPROD := asPED[1,4]+" "+asPED[1,5]

      nCONT := 1
      do while  nCONT <= len(asPED)

         nQUANT += asPED[nCONT,2]

         nCONT++
         if nCONT > len(asPED)
            nCONT := len(asPED)
            exit
         endif

         if asPED[nCONT,1] != cPROD

            PROD->(dbseek(cPROD))
            if PROD_TMP->(dbseek(cPROD))
               replace PROD_TMP->Pedidos       with nQUANT
               replace PROD_TMP->Fabric        with nQUANT
            else
               PROD_TMP->(qappend())
               replace PROD_TMP->Cod_prod    with cPROD
               //replace PROD_TMP->Quantidade  with nQUANT
               replace PROD_TMP->Preco       with PROD->Preco_cons
               replace PROD_TMP->Pedidos       with nQUANT
               replace PROD_TMP->Fabric        with nQUANT
            endif

            cPROD := asPED[nCONT,1]
            zPROD := asPED[nCONT,4]+" "+asPED[nCONT,5]

            nQUANT := 0
            nTOTAL := 0
         endif
      enddo
      PROD->(dbseek(cPROD))
      if PROD_TMP->(dbseek(cPROD))
         replace PROD_TMP->Pedidos      with nQUANT
         replace PROD_TMP->Fabric       with nQUANT
      else
         PROD_TMP->(qappend())
         replace PROD_TMP->Cod_prod    with cPROD
         //replace PROD_TMP->Quantidade  with nQUANT
         replace PROD_TMP->Preco       with PROD->Preco_cons
         replace PROD_TMP->Pedidos       with nQUANT
         replace PROD_TMP->Fabric        with nQUANT
      endif


      nQUANT := 0
      nTOTAL := 0
      nPERC  := 0
   endif

   lTEM := .F.
   asPED := {}
   aPED  := {}



   ////////////////////////////////////////////////////////////////////////////
   //PROCESSA PEDIDOS PENDENDES________________________________________________

   INVOICE->(dbgotop())
   do while ! INVOICE->(eof()) //.and. INVOICE->Data_ped >= dINI .and. INVOICE->Data_ped <= dFIM  // condicao principal de loop

      qmensa("Aguarde... Processando ...")


      ITEN_INV->(Dbgotop())
      ITEN_INV->(Dbseek(INVOICE->Codigo))
      do while ITEN_INV->Cod_inv == INVOICE->Codigo .and. ! ITEN_INV->(eof())
          PROD->(dbsetorder(4))
          PROD->(dbseek(ITEN_INV->Cod_Prod))
          nVALOR := nVALOR +  (ITEN_INV->Valor * ITEN_INV->Quantidade)

          aadd(aPED,{right(PROD->Codigo,5),ITEN_INV->Quantidade,ITEN_INV->Valor,"","",nVALOR})
          nPERC += nVALOR
          ITEN_INV->(Dbskip())
          nVALOR := 0
          lTEM := .T.
      enddo

      INVOICE->(dbskip())
      nVALOR := 0
      nDESC := 0
   enddo

   //classifica a matriz por descricao do produto
   asPED := asort(aPED,,,{|x,y| x[1] < y[1] })
   aPED := {}

   if lTEM
      cPROD := asPED[1,1]
      zPROD := asPED[1,4]+" "+asPED[1,5]

      nCONT := 1
      do while  nCONT <= len(asPED)

         nQUANT += asPED[nCONT,2]

         nCONT++
         if nCONT > len(asPED)
            nCONT := len(asPED)
            exit
         endif

         if asPED[nCONT,1] != cPROD

            PROD->(dbseek(cPROD))
            if PROD_TMP->(dbseek(cPROD))
               replace PROD_TMP->Transito     with nQUANT
               replace PROD_TMP->Fabric       with PROD_TMP->Fabric -  nQUANT
            else
               PROD_TMP->(qappend())
               replace PROD_TMP->Cod_prod    with cPROD
               //replace PROD_TMP->Quantidade  with nQUANT
               replace PROD_TMP->Preco       with PROD->Preco_cons
               replace PROD_TMP->Transito    with nQUANT
               replace PROD_TMP->Fabric       with PROD_TMP->Fabric -  nQUANT

            endif

            cPROD := asPED[nCONT,1]
            zPROD := asPED[nCONT,4]+" "+asPED[nCONT,5]

            nQUANT := 0
            nTOTAL := 0
         endif
      enddo
      PROD->(dbseek(cPROD))
      if PROD_TMP->(dbseek(cPROD))
         replace PROD_TMP->Transito     with nQUANT
         replace PROD_TMP->Fabric       with PROD_TMP->Fabric -  nQUANT

      else
         PROD_TMP->(qappend())
         replace PROD_TMP->Cod_prod    with cPROD
         //replace PROD_TMP->Quantidade  with nQUANT
         replace PROD_TMP->Preco       with PROD->Preco_cons
         replace PROD_TMP->Transito     with nQUANT
         replace PROD_TMP->Fabric       with PROD_TMP->Fabric -  nQUANT

      endif


      nQUANT := 0
      nTOTAL := 0
      nPERC  := 0
   endif

   lTEM := .F.
   asPED := {}
   aPED  := {}


   ////////////////////////////////////////////////////////////////////////////
   //PROCESSA INVOICE QUE JA CHEGOU____________________________________________

   INVOICE->(dbsetorder(5)) // data de Chegada
   INVOICE->(dbgotop())
   //set softseek on
   //INVOICE->(Dbseek(dtos(dINI)))
   // set softseek off
   ITEN_INV->(dbsetorder(1))


   do while ! INVOICE->(eof()) //.and. INVOICE->Dt_chegada >= dINI .and. INVOICE->Dt_chegada <= dFIM  // condicao principal de loop

      qmensa("Aguarde... Processando ...")

      if empty(INVOICE->Dt_chegada)
         INVOICE->(dbskip())
         loop
      endif

      ITEN_INV->(Dbgotop())
      ITEN_INV->(Dbseek(INVOICE->Codigo))
      do while ITEN_INV->Cod_inv == INVOICE->Codigo .and. ! ITEN_INV->(eof())
          PROD->(dbsetorder(4))
          PROD->(dbseek(ITEN_INV->Cod_Prod))
          nVALOR := nVALOR +  (ITEN_INV->Valor * ITEN_INV->Quantidade)

          aadd(aPED,{right(PROD->Codigo,5),ITEN_INV->Quantidade,ITEN_INV->Valor,"","",nVALOR})
          nPERC += nVALOR
          ITEN_INV->(Dbskip())
          nVALOR := 0
          lTEM := .T.
      enddo

      INVOICE->(dbskip())
      nVALOR := 0
      nDESC := 0
   enddo

   //classifica a matriz por descricao do produto
   asPED := asort(aPED,,,{|x,y| x[1] < y[1] })
   aPED := {}

   if lTEM
      cPROD := asPED[1,1]
      zPROD := asPED[1,4]+" "+asPED[1,5]

      nCONT := 1
      do while  nCONT <= len(asPED)

         nQUANT += asPED[nCONT,2]

         nCONT++
         if nCONT > len(asPED)
            nCONT := len(asPED)
            exit
         endif

         if asPED[nCONT,1] != cPROD

            PROD->(dbseek(cPROD))
            if PROD_TMP->(dbseek(cPROD))
               replace PROD_TMP->Transito       with (PROD_TMP->Transito -  nQUANT)
               replace PROD_TMP->Chegou         with nQUANT
            else
               PROD_TMP->(qappend())
               replace PROD_TMP->Cod_prod    with cPROD
               //replace PROD_TMP->Quantidade  with nQUANT
               replace PROD_TMP->Preco       with PROD->Preco_cons
               replace PROD_TMP->Transito       with (PROD_TMP->Transito -  nQUANT)
               replace PROD_TMP->Chegou         with nQUANT



            endif

            cPROD := asPED[nCONT,1]
            zPROD := asPED[nCONT,4]+" "+asPED[nCONT,5]

            nQUANT := 0
            nTOTAL := 0
         endif
      enddo
      PROD->(dbseek(cPROD))
      if PROD_TMP->(dbseek(cPROD))
         replace PROD_TMP->Transito       with (PROD_TMP->Transito -  nQUANT)
         replace PROD_TMP->Chegou         with nQUANT

      else
         PROD_TMP->(qappend())
         replace PROD_TMP->Cod_prod    with cPROD
         //replace PROD_TMP->Quantidade  with nQUANT
         replace PROD_TMP->Preco       with PROD->Preco_cons
         replace PROD_TMP->Transito       with (PROD_TMP->Transito -  nQUANT)
         replace PROD_TMP->Chegou         with nQUANT


      endif


      nQUANT := 0
      nTOTAL := 0
      nPERC  := 0
   endif

   lTEM := .F.
   asPED := {}
   aPED  := {}




   ///////////////////////////////////////////////////////////////////////////
   //PROCESSA PENDENCIAS______________________________________________________


   do while ! PEND->(eof())  .and. PEND->Dt_emissao >= dINI .and. PEND->Dt_emissao <= dFIM  // condicao principal de loop

      qmensa("Aguarde... Processando ...")


         ITEM_PEN->(Dbgotop())
         ITEM_PEN->(Dbseek(PEND->Codigo))
         do while ITEM_PEN->Cod_pend == PEND->Codigo .and. ! ITEM_PEN->(eof())
             PROD->(dbsetorder(4))
             PROD->(dbseek(ITEM_PEN->Cod_Prod))
             nVALOR := nVALOR + ( (ITEM_PEN->Vl_unitar * ITEM_PEN->Quantidade) + ( (ITEM_PEN->Vl_unitar * ITEM_PEN->Quantidade)*(ITEN_FAT->Ipi/100) ) )

             aadd(aPEND,{right(PROD->Codigo,5),ITEM_PEN->Quantidade,ITEM_PEN->Vl_unitar,"","",nVALOR})
             nPERC += nVALOR
             ITEM_PEN->(Dbskip())
             nVALOR := 0
             lTEM := .T.
         enddo
         PEND->(dbskip())
         nVALOR := 0
         nDESC := 0
   enddo

   //classifica a matriz por descricao do produto
   asPEND := asort(aPEND,,,{|x,y| x[1] < y[1] })
   aPEND := {}
   if lTEM
       cPROD := asPEND[1,1]
       zPROD := asPEND[1,4]+" "+asPEND[1,5]

       nCONT := 1
       do while  nCONT <= len(asPEND)

          nQUANT += asPEND[nCONT,2]

          nCONT++
          if nCONT > len(asPEND)
             nCONT := len(asPEND)
             exit
          endif

          if asPEND[nCONT,1] != cPROD
             PROD->(dbseek(cPROD))
             if PROD_TMP->(dbseek(cPROD))
                replace PROD_TMP->Pendencias  with nQUANT
             else
                PROD_TMP->(qappend())
                replace PROD_TMP->Cod_prod    with cPROD
                //replace PROD_TMP->Quantidade  with //nQUANT
                replace PROD_TMP->Preco       with PROD->Preco_cons
                replace PROD_TMP->Pendencias  with nQUANT
             endif

             cPROD := asPEND[nCONT,1]
             zPROD := asPEND[nCONT,4]+" "+asPEND[nCONT,5]

             nQUANT := 0
             nTOTAL := 0
          endif
       enddo
       PROD->(Dbseek(cPROD))
       if PROD_TMP->(dbseek(cPROD))
          replace PROD_TMP->Pendencias  with nQUANT
       else
          PROD_TMP->(qappend())
          replace PROD_TMP->Cod_prod    with cPROD
          //replace PROD_TMP->Quantidade  with //nQUANT
          replace PROD_TMP->Preco       with PROD->Preco_cons
          replace PROD_TMP->Pendencias  with nQUANT
       endif


      nQUANT := 0
      nTOTAL := 0
      nPERC  := 0
   endif

   lTEM := .F.
   asPEND := {}

   //qstopprn()
   nDOS := 0
   nTOTDOS := 0
   nMESES := 0
   nMESES_POS := 0

   PROD->(Dbgotop())
   do While ! PROD->(eof())

      if cTipo != " " .and. ! empty(PROD->Tipo)
         if PROD->tipo != cTipo
            PROD->(dbskip())
            loop
         endif
      endif

      if right(PROD->Codigo,5) == "     "
         PROD->(Dbskip())
         loop
      endif

      if cFORA == "N"
         if PROD->Fora_linha == "S"
            PROD->(dbskip())
            loop
         endif
      endif

      if cVIDA == "N"
         if PROD->FimDeVida == "S"
            PROD->(dbskip())
            loop
         endif
      endif


      dDATA_INI :=  dINI
      dDATA_FIM :=  dFIM


      INVENT->(dbsetorder(4))
      if INVENT->(Dbseek(right(PROD->Codigo,5)))
         nSALDO := INVENT->Quant_atu

         if INVENT->Data > dDATA_INI
            dDATA_INI := INVENT->Data
         endif
      else
         nSALDO := 0
         dDATA_ENT := ctod("")
         //qmensa("Produto sem Saldo!!")
      endif

      nMESES := busca_media(dDATA_INI,dDATA_FIM)
      nReserva :=  buscaReservaDoProduto(right(PROD->Codigo,5))

      if PROD_TMP->(dbseek(right(PROD->Codigo,5)))
         nMEDIA  := PROD_TMP->Quantidade / nMESES
		 
		 
         nDOS    := ((INVENT->Quant_atu+nReserva) / nMEDIA)
         nTOTDOS := (INVENT->Quant_atu+nReserva + PROD_TMP->Transito + PROD_TMP->Fabric + PROD_TMP->Pendencias) / nMEDIA
         nESTMIN := nMEDIA*4
         nPEDIR  := (nESTMIN + PROD_TMP->Pendencias) - (INVENT->Quant_atu+nReserva + PROD_TMP->Transito + PROD_TMP->Fabric)
         if nPEDIR < 0
            nPEDIR := 0
         endif

         aadd(aPROD,{right(PROD->Codigo,5),left(PROD->Descricao,30),PROD->Cod_fabr,PROD->Cod_ass,PROD->Marca,PROD->Preco_cons,PROD_TMP->Quantidade,left(PROD->Codigo,4),INVENT->Quant_atu+nReserva,INVENT->Data,nMESES,nMEDIA,nDOS,PROD_TMP->Transito,PROD_TMP->Pendencias,nTOTDOS,nESTMIN,nPEDIR,PROD_TMP->Pedidos,PROD_TMP->Fabric,PROD_TMP->Chegou,PROD->Cust_ren,INVENT->Quant_defe})
      else
         aadd(aPROD,{right(PROD->Codigo,5),left(PROD->Descricao,30),PROD->Cod_fabr,PROD->Cod_ass,PROD->Marca,PROD->Preco_cons,0,left(PROD->Codigo,4),INVENT->Quant_atu+nReserva,INVENT->Data,nMESES,nMEDIA,nDOS,0,0,nTOTDOS,0,0,0,0,0,PROD->cust_ren,INVENT->Quant_defe})
      endif

      nDIAS  := 0
      nMESES := 0
      nMEDIA := 0
      nDOS   := 0
      nTOTDOS   := 0
      nESTMIN := 0
      nPEDIR := 0
      PROD->(dbskip())
   enddo


   asPROD := asort(aPROD,,,{|x,y| x[8] + x[1] < y[8] + y[1] })

   nCONT := 1
   cGRUPO := asPROD[1,8]
   PROD->(Dbsetorder(4))
   PROD->(Dbseek(asPROD[1,1]))
   cDESCGRUPO := asPROD[1,5]
   do while  nCONT <= len(asPROD)

      if mod(nCONT,35) == 0
         if ! qlineprn() ; exit ; endif
      endif

      if XLOCALIMP == "X"
         if XPAGINA == 0 //.or. prow() > K_MAX_LIN
            qpageprn()
            @ prow()+1,0 say chr(9)+cTITULO
            @ prow()+1,0 say "Grupo"+chr(9)+"Descricao" +chr(9)+ "Cod.Fab" +chr(9)+ "Cod.Ass."+chr(9)+"Marca/Colecao"+chr(9)+"Fabrica"+Chr(9)+"Preco Venda"+chr(9)+"Saidas"+chr(9)+"Saldo em Estoque"+chr(9)+"Avarias"+chr(9)+"Data de Entrada"+chr(9)+"Meses"+chr(9)+"Media Mensal"+chr(9)+"Estoque em Meses"+chr(9)+"Total de Ped. Compra"+chr(9)+"Em Transito"+chr(9)+"Em Fabricacao"+chr(9)+"Entregue" +chr(9)+"Pendencias"+chr(9)+"M.o.S Total"+chr(9)+"Estoque Minimo"+chr(9)+"Pedido"+chr(9)+"Custo Rmb"
            @ prow()+1,0 say ""
			
         endif
      else
        if XPAGINA == 0 .or. prow() > K_MAX_LIN
            @prow()+1,0 say XCOND0
            qpageprn()
            qcabecprn(cTITULO,80)
            @ prow()+1,0 say XCOND1 + "Codigo    Descricao                          Cod.Fab   Cod.Ass.  Marca                        Preco Venda          Saidas"
            @ prow()+1,0 say replicate("-",134)
         endif
      endif


      if XLOCALIMP == "X"
         @ prow()+1,00      say " "+asPROD[nCONT,8] +chr(9) //Codigo
         PROD->(Dbsetorder(4))
         PROD->(Dbseek(asPROD[nCONT,1]))
         @ prow()  ,pcol()  say left(asPROD[nCONT,2],30)+chr(9)  //Descricao
         @ prow()  ,pcol()  say " "+left(asPROD[nCONT,3],8)+chr(9)  //Cod_fabr
         @ prow()  ,pcol()  say " "+asPROD[nCONT,4]+chr(9)  //Cod_ass
         @ prow()  ,pcol()  say PROD->Marca+chr(9)  //Marca
         FABRICA->(dbseek(PROD->Fabr))
         @ prow()  ,pcol()  say Fabrica->Razao+chr(9)  //Marca
         @ prow()  ,pcol()  say transf(asPROD[nCONT,6],"@E 999,999.99")+chr(9)  //Preco de Venda
         @ prow()  ,pcol()  say transf(asPROD[nCONT,7],"@R 9999999")+chr(9)  //Quantidade
         @ prow()  ,pcol()  say transf(asPROD[nCONT,9],"@R 9999999")+chr(9)  //Saldo atual
		 @ prow()  ,pcol()  say transf(asPROD[nCONT,23],"@R 9999999")+chr(9) //Avarias
         @ prow()  ,pcol()  say " "+dtoc(asPROD[nCONT,10])+chr(9)  //Meses
         @ prow()  ,pcol()  say transf(asPROD[nCONT,11],"@R 9999999")+chr(9)  //Data da 1a Entrada
         @ prow()  ,pcol()  say transf(asPROD[nCONT,12],"@E 999999.9")+chr(9)  //Media
         @ prow()  ,pcol()  say transf(asPROD[nCONT,13],"@E 999999.9")+chr(9)  //D.O.S
         @ prow()  ,pcol()  say transf(asPROD[nCONT,19],"@E 999999.9")+chr(9)  //Pedidos
         @ prow()  ,pcol()  say transf(asPROD[nCONT,14],"@E 999999.9")+chr(9)  //Transito
         @ prow()  ,pcol()  say transf(asPROD[nCONT,20],"@E 999999.9")+chr(9)  //Em Fabricacao
         @ prow()  ,pcol()  say transf(asPROD[nCONT,21],"@E 999999.9")+chr(9)  //Em Fabricacao
         @ prow()  ,pcol()  say transf(asPROD[nCONT,15],"@E 999999.9")+Chr(9)  //Pendencias
         @ prow()  ,pcol()  say transf(asPROD[nCONT,16],"@E 999999.9")+Chr(9)  //Pendencia + Pedido + Saldo em Estoque / Media de Venda
         @ prow()  ,pcol()  say transf(asPROD[nCONT,17],"@E 999999.9")+chr(9)  //Media de Venda * 4 Estoque Minimo
         @ prow()  ,pcol()  say transf(asPROD[nCONT,18],"@E 999999.9")+chr(9)  //(Estoque MInimo + Pendencia) - (Pedido + Saldo em Estoque)
         @ prow()  ,pcol()  say transf(asPROD[nCONT,22],"@E 99,999,999.99")  //(Estoque MInimo + Pendencia) - (Pedido + Saldo em Estoque)
      else
         @ prow()+1,00  say asPROD[nCONT,1]  //Codigo
         @ prow()  ,10  say left(asPROD[nCONT,2],30)  //Descricao
         @ prow()  ,45  say left(asPROD[nCONT,3],8)  //Cod_fabr
         @ prow()  ,55  say asPROD[nCONT,4]  //Cod_ass
         @ prow()  ,65  say asPROD[nCONT,5]  //Marca
         @ prow()  ,95  say transf(asPROD[nCONT,6],"@E 999,999.99")  //Preco de Venda
         @ prow()  ,115 say transf(asPROD[nCONT,7],"@R 999999")  //Quantidade
         @ prow()  ,125 say transf(asPROD[nCONT,9],"@R 999999")  //Quantidade
      endif

      nCONT++

      if nCONT > len(asPROD)
         nCONT := len(asPROD)
         exit
      endif


   enddo
   qstopprn()
return

static function busca_media(dINICIAL,dFINAL)
local nMESES  := 0
local intCONT   := 0
local cANOMES := 0
local nANOMES_INI := 0
local nANOMES_FIM := 0
local lFIRST := .T.

cANOMES := strzero(year(dINICIAL),4)+strzero(month(dINICIAL),2)
nANOMES_INI := val(cANOMES)

cANOMES := strzero(year(dFINAL),4)+strzero(month(dFINAL),2)
nANOMES_FIM := val(cANOMES)

For intCONT :=  nANOMES_INI To nANOMES_FIM

    if right(strzero(intCONT),2) == "12"
       intCONT += 88
    endif

    nMESES++


next

return nMESES

static function i_reserva
local aPED := {}
local aPEDS := {}
local lTEM := .F.
local cLOTE   := space(10)
local cFILIAL := space(4)
local nQTY    := 0
local cPROD   := space(5)
local nCONT   := 1

aReservas := {}

ITEN_FAT->(dbsetorder(2))
FAT->(dbsetorder(11))
FAT->(dbgotop())

Do while ! FAT->(eof()) .and. empty(FAT->Num_fatura)

   if FAT->es != "S"
      FAT->(dbskip())
	  loop
   endif
   
   if left(FAT->Cod_cfop,4) $ "5905-6905"
      FAT->(dbskip())
	  loop
   endif

   ITEN_FAT->(Dbseek(FAT->Codigo))

   Do while ! ITEN_FAT->(eof()) .and. ITEN_FAT->Num_fat == FAT->Codigo
      aadd(aPED,{ITEN_FAT->Cod_prod,FAT->Filial,ITEN_FAT->Num_Lote,ITEN_FAT->Quantidade})
      lTEM := .T.
      ITEN_FAT->(dbskip())
   enddo


   FAT->(Dbskip())
enddo

asPED := asort(aPED,,,{|x,y| x[1] < y[1] })

if lTEM
    cPROD   := asPED[1,1]
    cFILIAL := asPED[1,2]
    cLOTE   := asPED[1,3]
    nQTY    := 0

    nCONT := 1
    do while  nCONT <= len(asPED)

        nQTY += asPED[nCONT,4]

        nCONT++
        if nCONT > len(asPED)
           nCONT := len(asPED)
           exit
        endif

        if asPED[nCONT,1] != cPROD
		   
		   aadd(aReservas,{cPROD,cFILIAL,cLOTE,nQTY})

           cPROD   := asPED[nCONT,1]
           cFILIAL := asPED[nCONT,2]
           cLOTE   := asPED[nCONT,3]
           nQTY    := 0
        endif
    enddo
	
	aadd(aReservas,{cPROD,cFILIAL,cLOTE,nQTY})

endif

aPED := {}
asPED := {}

return

static function buscaReservaDoProduto(cPROD)
local nKey := 0

       nKey := ascan(aReservas,{|ckey| cKey[1] == cPROD})

       if nKey > 0
          return aReservas[nKey,4] 
       endif

return 0


