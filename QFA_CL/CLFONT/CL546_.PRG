/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO COMERCIO
// OBJETIVO...: Relatorio de comissao
// ANALISTA...: EDUARDO AUGUSTO BORIO
// PROGRAMADOR: EDUARDO AUGUSTO BORIO
// INICIO.....: ABRIL DE 2003
// OBS........:
// ALTERACOES.:

function cl546
#define K_MAX_LIN 57

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG) .or. empty(dINI) }

private cTITULO                   // titulo do relatorio
private cTITULO2                   // titulo do relatorio
private dINI
private dFIM
private cSETOR := space(5)
private cVEND   := space(5)
private cCLI    := space(5)
private cPROD   := space(5)
private aEDICAO := {}             // vetor para os campos de entrada de dados
private zCLI := ""
private zREP := ""
private zPROD:= ""
private XDRV_HB := "C:\QSYSTXT\"
private aReservas := {}


// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qgetx(-1,0,@dINI)            } , "INI"    })
aadd(aEDICAO,{{ || qgetx(-1,0,@dFIM)            } , "FIM"    })
aadd(aEDICAO,{{ || view_repres(-1,0,@cVEND   )    } , "VEND"   })
aadd(aEDICAO,{{ || NIL                          } , NIL      })

aadd(aEDICAO,{{ || view_Cli2(-1,0,@cCLI     )    } , "CLI"   })
aadd(aEDICAO,{{ || NIL                          } , NIL      })

aadd(aEDICAO,{{ || view_prod(-1,0,@cPROD    )    } , "PROD"   })
aadd(aEDICAO,{{ || NIL                          } , NIL      })



do while .T.

   qlbloc(5,0,"B546A","QBLOC.GLO")
   XNIVEL := 1
   XFLAG  := .T.
   dINI := dFIM := ctod("")
   cVEND := space(5)
   cCLI := space(5)
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

      case cCAMPO == "VEND"

           qrsay(XNIVEL,cVEND)

           if empty(cVEND)
              qrsay(XNIVEL+1, "Todos os Representantes.......")
              zREP := " Todos"
           else
              if ! REPRES->(Dbseek(cVEND))
                 qmensa("Representante n„o encontrado","B")
                 return .F.
              else
                 qrsay(XNIVEL+1,left(REPRES->Razao,30))
                 zREP := " "+left(REPRES->Razao,25)
              endif
           endif

      case cCAMPO == "CLI"

           qrsay(XNIVEL,cCLI)

           if empty(cCLI)
              qrsay(XNIVEL+1, "Todos os Clientes.......")
              zCLI :=  " Todos"
           else
              if ! CLI1->(Dbseek(cCLI))
                 qmensa("Cliente n„o encontrado","B")
                 return .F.
              else
                 qrsay(XNIVEL+1,left(CLI1->Razao,30))
                 zCLI := " "+left(CLI1->Razao,25)

              endif
           endif

      case cCAMPO == "PROD"
           if ! empty(cPROD)
              if CONFIG->Modelo_fat == "1"
                 PROD->(dbsetorder(5))
                 if PROD->(dbseek(cPROD))
                    cPROD := right(PROD->Codigo,5)
                 else
                    PROD->(dbsetorder(3))
                    if PROD->(dbseek(cPROD))
                       fCPROD := right(PROD->Codigo,5)
                    endif
                 endif
                 PROD->(dbsetorder(4))
              endif

              if ! empty(cPROD)
                 qrsay(XNIVEL,cPROD:=strzero(val(cPROD),5))

                 if ! PROD->(dbseek(cPROD))
                    qmensa("Produto n„o encontrado !","B")
                    return .F.
                 endif

                 if CONFIG->Modelo_fat == "1"
                    qrsay ( XNIVEL+1 , left(PROD->Descricao,15)+"/"+PROD->Cod_ass+" - "+left(PROD->Cod_fabr,6) )
                 else
                    qrsay ( XNIVEL+1 , left(PROD->Descricao,38) )
                 endif

              endif
           endif



   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // CRIA TITULO DO RELATORIO ______________________________________________


   cTITULO  := "RELATORIO DE PENDENCIAS POR REPRESENTANTE" + " de " + dtoc(dINI) + " a " + dtoc(dFIM)
   cTITULO2 := " Representante.: "+zRep+"    Cliente.: "+zCLI+" Produto.:+ "+zPROD

   qmensa("")

   // ESTABELECE RELACOES ENTRE ARQUIVOS ____________________________________

   PEND->(dbsetorder(2)) // data de saida
   PEND->(dbgotop())
   set softseek on
   PEND->(Dbseek(dtos(dINI)))
   set softseek off
   ITEM_PEN->(dbsetorder(2))
return .T.

static function i_impressao
   if ! qinitprn() ; return ; endif

   i_reserva()

   if XLOCALIMP == "X"
      if ! empty(cPROD)
         i_ProdXls()
      else
         i_impre_xls()
       endif
   else
      if ! empty(cPROD)
         i_ProdPrn()
      else
         i_impre_prn()
      endif
   endif

return


/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impre_prn
    local nTOTAL     := 0
    local nDESC      := 0
    local nTOT_GER   := 0
    local nTOT_COM   := 0
    local nCONT      := 0
    local nCOMISS    := 0
    local nPERC      := 0
    local nQUANT     := 0
    local nTOT_QUANT := 0
    local cPROD      := 0
    local nUF_QUANT  := 0
    local nUF_VALOR  := 0
    local aFAT       := {}
    local asFAT      := {}
    local fDATA_VEND := ctod("")
    local fVENC      := ctod("")
    local lTEM := .T.
   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________
    lTEM := .F.
   //if ! qinitprn() ; return ; endif

   do while ! PEND->(eof())//  .and. PEND->Dt_emissao >= dINI .and. PEND->Dt_emissao <= dFIM  // condicao principal de loop

      CLI1->(dbseek(PEND->Cod_cli))

      if ! empty(cVEND)
         if PEND->Cod_repres != cVEND
            PEND->(dbskip())
            loop
         endif
      endif

      if ! empty(cCLI)
         if PEND->Cod_cli != cCLI
            PEND->(dbskip())
            loop
         endif
      endif

      qmensa("Aguarde... Processando ...")

      if PEND->Dt_emissao < dINI .or. PEND->Dt_emissao > dFIM
         PEND->(dbskip())
         loop
      endif

      ITEM_PEN->(Dbgotop())
      ITEM_PEN->(Dbseek(PEND->Codigo))
      do while ITEM_PEN->Cod_pend == PEND->Codigo .and. ! ITEM_PEN->(eof())

          PROD->(dbsetorder(4))
          PROD->(dbseek(ITEM_PEN->Cod_Prod))
          nTOTAL += ITEM_PEN->Quantidade * ITEM_PEN->Vl_unitar
          lTEM := .T.
          ITEM_PEN->(Dbskip())
      enddo

      if PEND->Aliq_desc > 0
         nDESC := nTOTAL * (PEND->Aliq_desc/100)
      endif

      aadd(aFAT,{dtoc(PEND->Dt_Emissao),PEND->Cod_cli,CLI1->Razao,nTOTAL,PEND->Pedido,PEND->Cod_repres,PEND->Codigo})

      nTOTAL := 0
      nDESC  := 0
      PEND->(dbskip())

   enddo

   //classifica a matriz por vendedor + data vencimento
   asFAT := asort(aFAT,,,{|x,y| x[6] + x[3] + x[5] < y[6] + y[3] + y[5] })
   if lTEM
       zVEND  := asFAT[1,6]
       nCONT := 1
       do while  nCONT <= len(asFAT)

           if ! qlineprn() ; exit ; endif

           if XPAGINA == 0 .or. prow() > K_MAX_LIN
              @prow()+1,0 say XCOND1
              qpageprn()
              qcabecprn(cTITULO,136,,cTITULO2)
              @ prow()+1,0 say XCOND1 + "Data Emissao    Cod.  Cliente                                                          Total  Pedido     "

              @ prow()+1,0 say replicate("-",136)
           endif

           nUF_VALOR += asFAT[nCONT,4]
           nTOT_GER  += asFAT[nCONT,4]

           @ prow()+1, 00  say asFAT[nCONT,1]                         //Data de Emissao
           @ prow()  , 16  say asFAT[nCONT,2]                         //Codigo do Cliente
           @ prow()  , 22  say asFAT[nCONT,3]                         //Razao do Cliente
           @ prow()  , 80  say transf(asFAT[nCONT,4],"@E 9,999,999.99") //Valor da Nota

           @ prow()  , 96  say asFAT[nCONT,5]                         //Numero da Nota

           ITEM_PEN->(dbsetorder(2))
           ITEM_PEN->(dbseek(asFAT[nCONT,7]))
           do while ! ITEM_PEN->(Eof()) .and. ITEM_PEN->Cod_pend == asFAT[nCONT,7]
              PROD->(Dbsetorder(4))
              PROD->(Dbseek(ITEM_PEN->Cod_prod))
              @ prow()+1,00 say left(PROD->Cod_fabr,6) +" "+left(PROD->Descricao,20)+" "+PROD->Marca+" "+PROD->Cod_ass
              @ prow()  ,50 say transf(ITEM_PEN->Quantidade,"@R 999999")
              @ prow()  ,70 say transf(ITEM_PEN->Vl_unitar ,"@E 999,999.99")
              @ prow()  ,90 say transf((ITEM_PEN->Vl_unitar*ITEM_PEN->Quantidade) ,"@E 999,999.99")

              ITEM_PEN->(DbSkip())
           enddo
           @ prow()+1,00 say " "



           nCONT++
           if nCONT > len(asFAT)
              nCONT := len(asFAT)
              exit
           endif

          if alltrim(asFAT[nCONT,6]) != alltrim(zVEND)
              REPRES->(dbseek(zVEND))
              @ prow()+1  ,00 say "TOTAIS DO REPRESENTANTE....: "+left(REPRES->Razao,30)
              @ prow()    , 79 say transf(nUF_VALOR,"@E 99,999,999.99")
              @ prow()+1,00 say replicate("-",136)
              @ prow()+1,00 say ""
              nUF_VALOR := 0
              nCOMISS := 0
          endif

         zVEND := asFAT[nCONT,6]

       enddo
       REPRES->(dbseek(zVEND))
       @ prow()+2  ,00 say "TOTAIS DO REPRESENTANTE...: "+left(REPRES->Razao,30)
       @ prow()    ,79 say transf(nUF_VALOR,"@E 99,999,999.99")


       @ prow()+1,00 say ""
       nUF_VALOR := 0


       @ prow()+1,00 say replicate("-",136)
       @ prow()  ,35 say "TOTAL GERAL...:"
       @ prow()  ,79 say transf(nTOT_GER,"@E 99,999,999.99")

       nQUANT := 0
       nTOTAL := 0
       nPERC  := 0
   endif

   qstopprn()

return

static function i_impre_xls
    local nTOTAL     := 0
    local nDESC      := 0
    local nTOT_GER   := 0
    local nTOT_COM   := 0
    local nCONT      := 0
    local nCOMISS    := 0
    local nPERC      := 0
    local nQUANT     := 0
    local nTOT_QUANT := 0
    local cPROD      := 0
    local nUF_QUANT  := 0
    local nUF_VALOR  := 0
    local aRET       := {}
    local aFAT       := {}
    local asFAT      := {}
    local fDATA_VEND := ctod("")
    local fVENC      := ctod("")
    local lTEM := .T.
    local lFIRST := .T.
   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________
    lTEM := .F.
  // if ! qinitprn() ; return ; endif

   do while ! PEND->(eof())//  .and. PEND->Dt_emissao >= dINI .and. PEND->Dt_emissao <= dFIM  // condicao principal de loop

      CLI1->(dbseek(PEND->Cod_cli))

      if ! empty(cVEND)
         if PEND->Cod_repres != cVEND
            PEND->(dbskip())
            loop
         endif
      endif

      if ! empty(cCLI)
         if PEND->Cod_cli != cCLI
            PEND->(dbskip())
            loop
         endif
      endif


      qmensa("Aguarde... Processando ...")

      if PEND->Dt_emissao < dINI .or. PEND->Dt_emissao > dFIM
         PEND->(dbskip())
         loop
      endif

      ITEM_PEN->(Dbgotop())
      ITEM_PEN->(Dbseek(PEND->Codigo))
      do while ITEM_PEN->Cod_pend == PEND->Codigo .and. ! ITEM_PEN->(eof())

          PROD->(dbsetorder(4))
          PROD->(dbseek(ITEM_PEN->Cod_Prod))
          nTOTAL += ITEM_PEN->Quantidade * ITEM_PEN->Vl_unitar
          lTEM := .T.
          ITEM_PEN->(Dbskip())
      enddo

      aadd(aFAT,{dtoc(PEND->Dt_Emissao),PEND->Cod_cli,CLI1->Razao,nTOTAL,PEND->Pedido,PEND->Cod_repres,PEND->Codigo})

      nTOTAL := 0
      nDESC  := 0
      PEND->(dbskip())

   enddo

   //classifica a matriz por vendedor + data vencimento
   asFAT := asort(aFAT,,,{|x,y| x[6] + x[3] + x[5] < y[6] + y[3] + y[5] })
   if lTEM
       zVEND  := asFAT[1,6]
       nCONT := 1
       do while  nCONT <= len(asFAT)

           if ! qlineprn() ; exit ; endif

           if XPAGINA == 0
              @ prow()+1,0 say chr(9)+"RELATORIO DE PENDENCIAS POR REPRESENTANTE de "+dtoc(dINI)+" a "+dtoc(dFIM)+" - 546"
              @ prow()+1,0 say chr(9)+cTitulo2
              @ prow()+1,0 say "Emissao"+chr(9)+"Cliente"+chr(9)+"Pedido"+chr(9)+"Cod."+chr(9)+"Ref."+chr(9)+"Produto"+chr(9)+"Colecao"+chr(9)+"Vlr. Unit."+chr(9)+"Quantidade"+chr(9)+"Total"+chr(9)+"Disponivel"+chr(9)+"Expedicao"+chr(9)+"Avariado"+chr(9)+"Baixa"+chr(9)+"Estoque Total"
              qpageprn()
           endif
           nUF_VALOR += asFAT[nCONT,4]
           nTOT_GER  += asFAT[nCONT,4]
           lFIRST := .T.
           @ prow()+1, 00      say asFAT[nCONT,1]+chr(9)                         //Data de Emissao
           @ prow()  , pcol()  say asFAT[nCONT,3]+chr(9)                         //Razao do Cliente
           @ prow()  , pcol()  say asFAT[nCONT,5]+chr(9)                         //Numero do Pedido

           ITEM_PEN->(dbsetorder(2))
           if ITEM_PEN->(dbseek(asFAT[nCONT,7]))
              PROD->(Dbsetorder(4))
              PROD->(Dbseek(ITEM_PEN->Cod_prod))
              @ prow()  ,pcol()  say PROD->Cod_ass+chr(9)
              @ prow()  ,pcol()  say PROD->Cod_fabr+chr(9)
              @ prow()  ,pcol()  say left(PROD->Descricao,35)+chr(9)
              @ prow()  ,pcol()  say left(PROD->Marca,20)+chr(9)
              @ prow()  ,pcol()  say transform(ITEM_PEN->Vl_unitar,"@E 999,999.99")+chr(9)
              @ prow()  ,pcol()  say transform(ITEM_PEN->Quantidade,"@R 9999999")+chr(9)
              @ prow()  ,pcol()  say transform(ITEM_PEN->Quantidade*ITEM_PEN->Vl_unitar,"@E 999,999.99")+chr(9)
              aRET := i_calcEstoque(ITEM_PEN->Cod_prod)
              @ prow()  ,pcol()  say transform(aRET[1,1],"@R 99999999")+chr(9)
              @ prow()  ,pcol()  say transform(aRET[1,2],"@R 99999999")+chr(9)
			  @ prow()  ,pcol()  say transform(aRET[1,3],"@R 99999999")+chr(9)
			  @ prow()  ,pcol()  say transform(aRET[1,4],"@R 99999999")+chr(9)
              @ prow()  ,pcol()  say transform(aRET[1,5],"@R 99999999")
              ITEM_PEN->(Dbskip())

              if ITEM_PEN->Cod_pend == asFAT[nCONT,7]
                 do while ! ITEM_PEN->(Eof()) .and. ITEM_PEN->Cod_pend == asFAT[nCONT,7]
                    lFIRST := .F.
                    PROD->(Dbsetorder(4))
                    PROD->(Dbseek(ITEM_PEN->Cod_prod))

                    @ prow()+1,00      say chr(9)+chr(9)+chr(9)+PROD->Cod_ass+chr(9)
                    @ prow()  ,pcol()  say PROD->Cod_fabr+chr(9)
                    @ prow()  ,pcol()  say left(PROD->Descricao,35)+chr(9)
                    @ prow()  ,pcol()  say left(PROD->Marca,20)+chr(9)

                    @ prow()  , pcol() say transform(ITEM_PEN->Vl_unitar,"@E 999,999.99")+chr(9)
                    @ prow()  , pcol() say transform(ITEM_PEN->Quantidade,"@R 9999")+chr(9)
                    @ prow()  , pcol() say transform(ITEM_PEN->Quantidade*ITEM_PEN->Vl_unitar,"@E 999,999.99")+chr(9)
                    aRET := i_calcEstoque(ITEM_PEN->Cod_prod)
                    @ prow()  ,pcol()  say transform(aRET[1,1],"@R 99999999")+chr(9)
                    @ prow()  ,pcol()  say transform(aRET[1,2],"@R 99999999")+chr(9)
					@ prow()  ,pcol()  say transform(aRET[1,3],"@R 99999999")+chr(9)
					@ prow()  ,pcol()  say transform(aRET[1,4],"@R 99999999")+chr(9)
                    @ prow()  ,pcol()  say transform(aRET[1,5],"@R 99999999")


                    ITEM_PEN->(Dbskip())
                 enddo
              endif
           endif

           if ! lFIRST
              @ prow()   , 00  say replicate(chr(9),9)+transf(asFAT[nCONT,4],"@E 999,999.99") //Valor da Nota

           endif


           @ prow()+1,00 say " "


           nCONT++
           if nCONT > len(asFAT)
              nCONT := len(asFAT)
              exit
           endif

          if alltrim(asFAT[nCONT,6]) != alltrim(zVEND)
              REPRES->(dbseek(zVEND))
              @ prow()+1  ,00   say chr(9)+"TOTAIS DO REPRESENTANTE....: "+left(REPRES->Razao,30)+replicate(chr(9),8)
              @ prow()    ,pcol() say transf(nUF_VALOR,"@E 99,999,999.99")
              @ prow()+1,00 say ""
              nUF_VALOR := 0
              nCOMISS := 0
          endif

         zVEND := asFAT[nCONT,6]

       enddo
       REPRES->(dbseek(zVEND))
       @ prow()+2  ,00 say chr(9)+"TOTAIS DO REPRESENTANTE...: "+left(REPRES->Razao,30)+replicate(chr(9),8)
       @ prow()    ,pcol() say transf(nUF_VALOR,"@E 99,999,999.99")


       @ prow()+1,00 say ""
       nUF_VALOR := 0


       @ prow()+1,00 say chr(9)+ "TOTAL GERAL...:"+replicate(chr(9),8)
       @ prow()  ,pcol() say transf(nTOT_GER,"@E 99,999,999.99")

       nQUANT := 0
       nTOTAL := 0
       nPERC  := 0
   endif

   qstopprn()

return

static function i_calcEstoque(Cod_prod)
local nQUANT_RES  := 0  //Avariados
local nQUANT_AVAR := 0  //Avariados
local nQUANT      := 0  //Em Transicao
local nQUANT_show := 0  //Em Transicao
local aResult := {}

  INVENT->(dbsetorder(4))
  INVENT->(dbseek(Cod_prod))

  do while ! INVENT->(eof()) .and. INVENT->Cod_prod == right(PROD->Codigo,5)
     nQUANT      += INVENT->Quant_atu
     nQUANT_AVAR += INVENT->Quant_defe
	 nQUANT_SHOW += INVENT->Quant_show

     INVENT->(dbskip())
  enddo

  nQUANT_RES := buscaReservas(Cod_prod)

  aadd(aResult,{nQUANT,nQUANT_RES,nQUANT_AVAR,nQUANT_SHOW,nQUANT + nQUANT_RES + nQUANT_AVAR + nQUANT_SHOW})

return aResult

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

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_ProdPrn
    local nTOTAL     := 0
    local nDESC      := 0
    local nTOT_GER   := 0
    local nTOT_COM   := 0
    local nCONT      := 0
    local nCOMISS    := 0
    local nPERC      := 0
    local nQUANT     := 0
    local nTOT_QUANT := 0
    local nUF_QUANT  := 0
    local nUF_VALOR  := 0
    local aFAT       := {}
    local asFAT      := {}
    local fDATA_VEND := ctod("")
    local fVENC      := ctod("")
    local lTEM := .T.
   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________
    lTEM := .F.
   //if ! qinitprn() ; return ; endif

   do while ! PEND->(eof())//  .and. PEND->Dt_emissao >= dINI .and. PEND->Dt_emissao <= dFIM  // condicao principal de loop

      CLI1->(dbseek(PEND->Cod_cli))

      if ! empty(cVEND)
         if PEND->Cod_repres != cVEND
            PEND->(dbskip())
            loop
         endif
      endif

      if ! empty(cCLI)
         if PEND->Cod_cli != cCLI
            PEND->(dbskip())
            loop
         endif
      endif

      qmensa("Aguarde... Processando ...")

      if PEND->Dt_emissao < dINI .or. PEND->Dt_emissao > dFIM
         PEND->(dbskip())
         loop
      endif

      ITEM_PEN->(Dbgotop())
      ITEM_PEN->(Dbseek(PEND->Codigo))
      do while ITEM_PEN->Cod_pend == PEND->Codigo .and. ! ITEM_PEN->(eof())

          if ITEM_PEN->Cod_prod == cPROD
            aadd(aFAT,{PEND->Dt_emissao,dtoc(PEND->Dt_Emissao),PEND->Cod_cli,PEND->Codigo,ITEM_PEN->Quantidade,ITEM_PEN->vl_unitar})
          endif

          ITEM_PEN->(Dbskip())
      enddo

      nTOTAL := 0
      PEND->(dbskip())

   enddo

   nQUANT := 0

   //classifica a matriz por data emissao
   asFAT := asort(aFAT,,,{|x,y| x[1] < y[1] })
   if len(asFAT) > 0
       nCONT := 1
       do while  nCONT <= len(asFAT)

           //if ! qlineprn() ; exit ; endif

           if XPAGINA == 0 .or. prow() > K_MAX_LIN
              @prow()+1,0 say XCOND1
              qpageprn()
              PROD->(dbsetorder(4))
              PROD->(dbseek(cPROD))
              qcabecprn("Pendencias por Referencia de "+dtoc(dINI)+ " a "+dtoc(dFIM),136,,"Ref.: "+ PROD->Cod_ass+" "+left(PROD->cod_fabr,6)+" "+left(PROD->Descricao,25)+" "+PROD->Marca)
              @ prow()+1,0 say XCOND1 + "Data Emissao  No.   Cliente                                      Quantidade     Vlr. Unitario              Total"
              @ prow()+1,0 say replicate("-",136)
           endif

           nQUANT += asFAT[nCONT,5]
           nTOT_GER  += (asFAT[nCONT,5] * asFAT[nCONT,6])

           @ prow()+1, 00  say asFAT[nCONT,2]                         //Data de Emissao
           @ prow()  , 16  say asFAT[nCONT,4]                         //Codigo do Cliente
           CLI1->(dbseek(asFAT[nCONT,3]))
           @ prow()  , 22  say left(CLI1->Razao,45)                   //Razao do Cliente

           @ prow()   ,70  say transf(asFAT[nCONT,5],"@R 999999")
           @ prow()   ,84  say transf(asFAT[nCONT,6] ,"@E 999,999.99")
           @ prow()   ,100 say transf(asFAT[nCONT,5]  *  asFAT[nCONT,6],"@E 99,999,999.99")

           nCONT++
           if nCONT > len(asFAT)
              nCONT := len(asFAT)
              exit
           endif


       enddo
       @ prow()+1,00  say replicate("-",136)
       @ prow()  ,35  say "TOTAL GERAL...:"
       @ prow()  ,70  say transf(nQUANT,"@R  999999")
       @ prow()  ,100 say transf(nTOT_GER,"@E 99,999,999.99")

       nQUANT := 0
       nTOTAL := 0
       nPERC  := 0
       nTOT_GER := 0
   endif

   qstopprn(.F.)

return

static function i_ProdXLS
    local nTOTAL     := 0
    local nDESC      := 0
    local nTOT_GER   := 0
    local nTOT_COM   := 0
    local nCONT      := 0
    local nCOMISS    := 0
    local nPERC      := 0
    local nQUANT     := 0
    local nTOT_QUANT := 0
    local nUF_QUANT  := 0
    local nUF_VALOR  := 0
    local aFAT       := {}
    local asFAT      := {}
    local fDATA_VEND := ctod("")
    local fVENC      := ctod("")
    local lTEM := .T.
   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________
    lTEM := .F.
   //if ! qinitprn() ; return ; endif

   do while ! PEND->(eof())//  .and. PEND->Dt_emissao >= dINI .and. PEND->Dt_emissao <= dFIM  // condicao principal de loop

      CLI1->(dbseek(PEND->Cod_cli))

      if ! empty(cVEND)
         if PEND->Cod_repres != cVEND
            PEND->(dbskip())
            loop
         endif
      endif

      if ! empty(cCLI)
         if PEND->Cod_cli != cCLI
            PEND->(dbskip())
            loop
         endif
      endif

      qmensa("Aguarde... Processando ...")

      if PEND->Dt_emissao < dINI .or. PEND->Dt_emissao > dFIM
         PEND->(dbskip())
         loop
      endif

      ITEM_PEN->(Dbgotop())
      ITEM_PEN->(Dbseek(PEND->Codigo))
      do while ITEM_PEN->Cod_pend == PEND->Codigo .and. ! ITEM_PEN->(eof())

          if ITEM_PEN->Cod_prod == cPROD
            aadd(aFAT,{PEND->Dt_emissao,dtoc(PEND->Dt_Emissao),PEND->Cod_cli,PEND->Codigo,ITEM_PEN->Quantidade,ITEM_PEN->vl_unitar})
          endif

          ITEM_PEN->(Dbskip())
      enddo

      nTOTAL := 0
      PEND->(dbskip())

   enddo

   nQUANT := 0

   //classifica a matriz por data emissao
   asFAT := asort(aFAT,,,{|x,y| x[1] < y[1] })
   if len(asFAT) > 0
       nCONT := 1
       do while  nCONT <= len(asFAT)

           if ! qlineprn() ; exit ; endif

           if XPAGINA == 0 //.or. prow() > K_MAX_LIN
              qpageprn()
              PROD->(dbsetorder(4))
              PROD->(dbseek(cPROD))
              @ prow()+1,0 say chr(9)+chr(9)+"Pendencias por Referencia de "+dtoc(dINI)+ " a "+dtoc(dFIM)+ "546 "
              @ prow()+1,0 say chr(9)+chr(9)+"Ref.: "+ PROD->Cod_ass+" "+left(PROD->cod_fabr,6)+" "+left(PROD->Descricao,25)+" "+PROD->Marca
              @ prow()+1,0 say "Data Emissao"+chr(9)+"No."+chr(9)+"Cliente"+chr(9)+"Quantidade"+chr(9)+"Vlr. Unitario"+chr(9)+"Total"
              @ prow()+1,0 say ""
           endif

           nQUANT += asFAT[nCONT,5]
           nTOT_GER  += (asFAT[nCONT,5] * asFAT[nCONT,6])

           @ prow()+1, 00      say asFAT[nCONT,2]                         //Data de Emissao
           @ prow()  , pcol()  say chr(9)+asFAT[nCONT,4]                         //Codigo do Cliente
           CLI1->(dbseek(asFAT[nCONT,3]))
           @ prow()  , pcol()  say chr(9)+left(CLI1->Razao,45)                   //Razao do Cliente

           @ prow()   ,pcol()  say chr(9)+transf(asFAT[nCONT,5],"@R 999999")
           @ prow()   ,pcol()  say chr(9)+transf(asFAT[nCONT,6] ,"@E 999,999.99")
           @ prow()   ,pcol()  say chr(9)+transf(asFAT[nCONT,5]  *  asFAT[nCONT,6],"@E 99,999,999.99")

           nCONT++
           if nCONT > len(asFAT)
              nCONT := len(asFAT)
              exit
           endif


       enddo
       @ prow()  ,00      say chr(9)+chr(9)+"Total.:"
       @ prow()  ,pcol()  say chr(9)+transf(nQUANT,"@R  999999")
       @ prow()  ,pcol()  say chr(9)+chr(9)+transf(nTOT_GER,"@E 99,999,999.99")

       nQUANT := 0
       nTOTAL := 0
       nPERC  := 0
       nTOT_GER := 0
   endif

   qstopprn(.F.)

return

static function buscaReservas(cPROD)
local nKey := 0

       nKey := ascan(aReservas,{|ckey| cKey[1] == cPROD})

       if nKey > 0
          return aReservas[nKey,4] 
       endif

return 0


