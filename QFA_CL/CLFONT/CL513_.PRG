/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO COMERCIO
// OBJETIVO...: LISTAGEM DE NOTAS FISCAIS
// ANALISTA...: EDUARDO AUGUSTO BORIO
// PROGRAMADOR: EDUARDO AUGUSTO BORIO
// INICIO.....: JULHO DE 2002
// OBS........:
// ALTERACOES.:

function cl513
#define K_MAX_LIN 57

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG) .or. empty(dINI) }

private cTITULO                   // titulo do relatorio
private dINI
private dFIM
private cSETOR  := space(5)
private cES     := ""
private sBLOC1  := qlbloc("B513B","QBLOC.GLO")

private aEDICAO := {}             // vetor para os campos de entrada de dados

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qgetx(-1,0,@dINI)            } , "INI"    })
aadd(aEDICAO,{{ || qgetx(-1,0,@dFIM)            } , "FIM"    })
aadd(aEDICAO,{{ || qesco(-1,0,@cES,sBLOC1)       } , "FIM"    })

do while .T.

   qlbloc(5,0,"B513A","QBLOC.GLO")
   XNIVEL := 1
   XFLAG  := .T.
   dINI := dFIM := ctod("")
   cES := ""

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

      case cCAMPO == "ES"
           if empty(cES) ; return .F. ; endif
           qrsay(XNIVEL,qabrev(cES,"TES",{"Todos","Entrada","Saida"}))


   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // CRIA TITULO DO RELATORIO ______________________________________________


   cTITULO := "LISTAGEM DE NOTAS FISCAIS" +" de " + dtoc(dINI) + " a " + dtoc(dFIM)

   qmensa("")

   // ESTABELECE RELACOES ENTRE ARQUIVOS ____________________________________
   //FAT->(dbSetFilter({|| !empty(FAT->Num_fatura) }, '!empty(FAT->Num_fatura)'))

   FAT->(dbsetorder(2)) // data de emissao
   FAT->(dbgotop())
   set softseek on
   FAT->(Dbseek(dtos(dINI)))
   set softseek off
   ITEN_FAT->(dbsetorder(2))

   PROD->(dbsetorder(4))
return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impressao
    local nVAL_PED := 0
    local nTOTAL   := 0
    local nST      := 0
    local nDESC    := 0
    local nTOT_DESC:= 0
    local nIPI     := 0
    local aVend := {}
    local aProd := {}

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif

   do while ! FAT->(eof())  .and. FAT->Dt_emissao >= dINI .and. FAT->Dt_emissao <= dFIM  // condicao principal de loop

      if FAT->Cancelado
         FAT->(dbskip())
         loop
      endif

      if FAT->No_nf
         FAT->(dbskip())
         loop
      endif

      if cES != "T"
         if FAT->Es != cES
            FAT->(dbskip())
            loop
         endif
      endif

      if empty(FAT->Num_fatura).and. FAT->Es == "S"
         FAT->(dbskip())
         loop
      endif
      CLI1->(dbseek(FAT->Cod_cli))

//
  //    ITEN_FAT->(Dbgotop())

      nST := 0
      nVAL_PED :=0
      ITEN_FAT->(Dbseek(FAT->Codigo))
      do while ITEN_FAT->Num_fat == FAT->Codigo .and. ! ITEN_FAT->(eof())
          PROD->(dbsetorder(4))
          PROD->(dbseek(ITEN_FAT->Cod_Prod))
          nVAL_PED += (ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade)
          //nVAL_PED += q_soma_st()
          nST += q_soma_st()
          nIPI += (ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade) * (ITEN_FAT->Ipi/100)
          if left(FAT->Cod_cfop,3) $ "510-610-530-630-540-640"
             aadd(aProd,{ITEN_FAT->Cod_prod,ITEN_FAT->Quantidade})
          endif
          ITEN_FAT->(Dbskip())
      enddo

      nDESC := FAT->Aliq_desc
      nTOT_DESC := (nVAL_PED+nIPI) * (nDESC/100)
      if CONFIG->Modelo_fat == "1"
         nVAL_PED := nVAL_PED + nIPI
      else
         nVAL_PED := (nVAL_PED + nIPI)
      endif

      CLI1->(dbseek(FAT->Cod_cli))

      if left(FAT->Cod_cfop,3) $ "510-610-530-630-540-640"
         aadd(aVend,{"0",FAT->Num_fatura,left(CLI1->Razao,50),FAT->Cod_Cfop,dtoc(FAT->Dt_emissao),nVAL_PED,nST})
      else
         aadd(aVend,{FAT->Cod_cfop,FAT->Num_fatura,left(CLI1->Razao,50),FAT->Cod_Cfop,dtoc(FAT->Dt_emissao),nVAL_PED,nST})
      endif

      nVAL_PED := 0
      nIPI     := 0
      nDESC    := 0
      nTOT_DESC:= 0
      nST := 0

      FAT->(dbskip())

   enddo

   ImprimeArray(aVend)

//   if CONFIG->Modelo_NF == "01"
//      eject
//      XPAGINA := 0
//      ImprimeProds(aProd,dINI,dFIM)
//   endif

   qstopprn(.F.)

return

static function ImprimeArray(aVend)
local nCONT := 1
local cCFOP := ""
local nTOTAL := 0
local nTOT_GER := 0
local nValCfop := 0
local nStCfop  := 0
local nTotCfop  := 0
local nValGer := 0
local nStGer := 0
local nTotGer := 0

  aVend := asort(aVend,,,{|x,y| x[1]+x[2] < y[1]+y[2] })

  if len(aVend) > 0

      cCFOP := aVend[1,1]

      do while  nCONT <= len(aVend)

         if XPAGINA == 0 .or. prow() > K_MAX_LIN
            @prow()+1,0 say XCOND1
            qpageprn()
            qcabecprn(cTITULO,135)
            @ prow()+1,0 say "Numero  Cliente                                                  Cfop      Emissao           Vlr. Produtos        S.T.         Total"
            @ prow()+1,0 say ""
         endif

         @ prow()+1,00  say aVend[nCONT,2]
         @ prow()  ,08  say aVend[nCONT,3]
         @ prow()  ,65  say aVend[nCONT,4]
         @ prow()  ,75  say aVend[nCONT,5]
         @ prow()  ,94  say transform(aVend[nCONT,6],"@E 9,999,999.99")
         @ prow()  ,110 say transform(aVend[nCONT,7],"@E 9,999.99")
         @ prow()  ,120 say transform(aVend[nCONT,6]+aVend[nCONT,7],"@E 9,999,999.99")

         nValCfop   += aVend[nCONT,6]
         nStCfop    += aVend[nCONT,7]
         nTotCfop   += aVend[nCONT,6] + aVend[nCONT,7]

         nValGer    += aVend[nCONT,6]
         nStGer     += aVend[nCONT,7]
         nTotGer    += aVend[nCONT,6] + aVend[nCONT,7]

         qmensa("Aguarde... Processando ...")

         nCONT++
         if nCONT > len(aVend)
            nCONT := len(aVend)
            exit
         endif

         if aVend[nCONT,1] != cCFOP
            @ prow()+1,85 say "Total.: "
            @ prow()  ,94  say transform(nValCfop,"@E 9,999,999.99")
            @ prow()  ,110 say transform(nStCfop,"@E 9,999.99")
            @ prow()  ,120 say transform(nTotCfop,"@E 9,999,999.99")
            @ prow()+1,00 say ""

            nTOTAL := 0
            nValCfop := 0
            nStCfop  := 0
            nTotCfop := 0
            cCFOP := aVend[nCONT,1]
         endif
    enddo

    if nTOTAL <> 0
       @ prow()+1,85 say "Total.: "
       @ prow()  ,94  say transform(nValCfop,"@E 9,999,999.99")
       @ prow()  ,110 say transform(nStCfop,"@E 9,999.99")
       @ prow()  ,120 say transform(nTotCfop,"@E 9,999,999.99")
       @ prow()+1,00 say ""             

       nTOTAL := 0
       nValCfop := 0
       nValSt := 0
       nTOTAL := 0
    endif

    @ prow()+1,75 say "Total Geral.: "
    @ prow()  ,94  say transform(nValGer,"@E 9,999,999.99")
    @ prow()  ,110 say transform(nStGer,"@E 9,999.99")
    @ prow()  ,120 say transform(nTotGer,"@E 9,999,999.99")

  endif

return


static function ImprimeProds(aProd,dINI,dFIM)
local nCONT    := 1
local nQTD     := 0
local nTOT_LIT := 0
local cPROD    := ""
local nLitros := 0

  aProd := asort(aProd,,,{|x,y| x[1] < y[1] })

  if len(aProd) > 0

      cPROD := aProd[1,1]

      do while  nCONT <= len(aProd)

         if XPAGINA == 0 .or. prow() > K_MAX_LIN
            @prow()+1,0 say XCOND1
            qpageprn()
            qcabecprn(" Total em litros (Somente Vendas) "+dtoc(dINI)+" a "+dtoc(dFIM),135)
            @ prow()+1,0 say "Codigo    Descricao                                                    Qtde                   Litros                    Total"
            @ prow()+1,0 say ""
         endif

         nQTD += aProd[nCONT,2]

         qmensa("Aguarde... Processando ...")

         nCONT++
         if nCONT > len(aProd)
            nCONT := len(aProd)
            exit
         endif

         if aProd[nCONT,1] != cPROD
            PROD->(dbseek(cPROD))
            @ prow()+1,00  say right(PROD->Codigo,5)
            @ prow()  ,10  say PROD->Descricao
            @ prow()  ,65  say transform(nQTD,"@R 9999999.99")
            @ prow()  ,90  say transform(PROD->Peso,"@R 9999999.99")
            @ prow()  ,105 say transform(PROD->Peso*nQTD,"@E 999,999,999,999.999")
            nLitros += PROD->Peso * nQTD
            nQTD := 0
            cPROD := aProd[nCONT,1]
         endif
    enddo

    if nQTD > 0
       PROD->(dbseek(cPROD))
       @ prow()+1,00  say right(PROD->Codigo,5)
       @ prow()  ,10  say PROD->Descricao
       @ prow()  ,65  say transform(nQTD,"@E 9999999.99")
       @ prow()  ,90  say transform(PROD->Peso,"@E 9999999.999")
       @ prow()  ,105 say transform(PROD->Peso*nQTD,"@E 999,999,999,999.999")
       nLitros += (PROD->Peso * nQTD)
       nQTD := 0
    endif

    @ prow()+1,00  say "Total Geral.: "
    @ prow()  ,105 say transform(nLitros,"@E 999,999,999,999.999")



  endif

return


