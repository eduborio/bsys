//////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO COMERCIO
// OBJETIVO...: LISTAGEM DE PRODUTOS FATURADOS
// ANALISTA...: EDUARDO AUGUSTO BORIO
// PROGRAMADOR: EDUARDO AUGUSTO BORIO
// INICIO.....: MARCO DE 2007
// OBS........:
// ALTERACOES.:

function cl555
#define K_MAX_LIN 57

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG) .or. empty(dINI) }

private cTITULO                   // titulo do relatorio
private cTITULO2                   // titulo do relatorio
private dINI
private dFIM
private cREPRES := space(5)
private cCLI := space(5)
private aEDICAO := {}             // vetor para os campos de entrada de dados
private zREP := ""
private zCLI := ""
private XDRV_HB := "C:\QSYSTXT\"
private aReservas := {}

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qgetx(-1,0,@dINI)            } , "INI"    })
aadd(aEDICAO,{{ || qgetx(-1,0,@dFIM)            } , "FIM"    })
aadd(aEDICAO,{{ || view_repres(-1,0,@cREPRES)     } , "SETOR"  })
aadd(aEDICAO,{{ || NIL                          } , NIL  })

aadd(aEDICAO,{{ || view_Cli2(-1,0,@cCLI     )    } , "CLI"   })
aadd(aEDICAO,{{ || NIL                          } , NIL      })


do while .T.

   qlbloc(5,0,"B555A","QBLOC.GLO")
   XNIVEL := 1
   XFLAG  := .T.
   dINI := dFIM := ctod("")

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

      case cCAMPO == "SETOR"

           qrsay(XNIVEL,cREPRES)

           if empty(cREPRES)
              qrsay(XNIVEL++, "Todos os Setores.......")
           else
              if ! REPRES->(Dbseek(cREPRES:=strzero(val(cREPRES),5)))
                 qmensa("Setor n„o Cadastrado","B")
                 return .F.
              else
                 qrsay(XNIVEL++,left(REPRES->Razao,30))
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


   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // CRIA TITULO DO RELATORIO ______________________________________________


   cTITULO := "LISTAGEM DE PENDENCIAS POR REFERENCIA" +" de " + dtoc(dINI) + " a " + dtoc(dFIM)
   cTITULO2 := " Representante.: "+zRep+"           Cliente.: "+zCLI


   qmensa("")

   // ESTABELECE RELACOES ENTRE ARQUIVOS ____________________________________

   PEND->(dbsetorder(2)) // data de emissao
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
      i_impre_xls()
   else
      i_impre_prn()
   endif

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

////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impre_prn
    local nTOTAL     := 0
    local nTOTAL_ENT := 0
    local nVALOR     := 0
    local nDESC      := 0
    local nTOT_GER   := 0
    local nCONT      := 0
    local nQUANT     := 0
    local nQUANT_ENT := 0
    local nTOT_QUANT := 0
    local cPROD      := 0
    local aFAT       := {}
    local asFAT      := {}
    local nPERC      := 0
    local lTEM := .T.
    local zPROD := space(50)
   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________
    lTEM := .F.
   //if ! qinitprn() ; return ; endif

   do while ! PEND->(eof())  .and. PEND->Dt_emissao >= dINI .and. PEND->Dt_emissao <= dFIM  // condicao principal de loop

      qgirabarra()

      qmensa("Aguarde... Processando ...")

         CLI1->(dbseek(PEND->Cod_cli))

         if ! empty(cREPRES)
            if PEND->Cod_repres != cREPRES
               PEND->(Dbskip())
               loop
            endif
         endif

         if ! empty(cCLI)
            if PEND->Cod_cli != cCLI
               PEND->(dbskip())
               loop
            endif
         endif


         ITEM_PEN->(Dbgotop())
         ITEM_PEN->(Dbseek(PEND->Codigo))
         do while ITEM_PEN->Cod_pend == PEND->Codigo .and. ! ITEM_PEN->(eof())
             PROD->(dbsetorder(4))
             PROD->(dbseek(ITEM_PEN->Cod_Prod))
             nVALOR := nVALOR + (ITEM_PEN->Vl_unitar * ITEM_PEN->Quantidade)

             aadd(aFAT,{right(PROD->Codigo,5),ITEM_PEN->Quantidade,ITEM_PEN->Vl_unitar,left(PROD->Cod_fabr,4),left(PROD->Descricao,20)+" "+left(PROD->Marca,12)+ " "+PROD->Cod_ass,nVALOR,PEND->Es})

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
   asFAT := asort(aFAT,,,{|x,y| x[1] < y[1] })
   if lTEM
       cPROD := asFAT[1,1]
       zPROD := asFAT[1,4]+" "+asFAT[1,5]

       nCONT := 1
       do while  nCONT <= len(asFAT)

           if ! qlineprn() ; exit ; endif
           if XPAGINA == 0 .or. prow() > K_MAX_LIN
              @prow()+1,0 say XCOND0
              qpageprn()
              qcabecprn(cTITULO,80,,cTITULO2)
              @ prow()+1,0 say XCOND1 + "Produto                                                                   Saida                   Valor "
              @ prow()+1,0 say replicate("-",134)
           endif

           nQUANT += asFAT[nCONT,2]
           nTOT_QUANT += asFAT[nCONT,2]
           nTOTAL += asFAT[nCONT,6]    //Quantidade * valor unitario
           nTOT_GER += asFAT[nCONT,6]  //Quantidade * valor unitario


           nCONT++
           if nCONT > len(asFAT)
              nCONT := len(asFAT)
              exit
           endif
           if asFAT[nCONT,1] != cPROD
              @ prow()+1,00 say zPROD
              @ prow()  ,73 say transf(nQUANT,"@R 999999")

              @ prow()  ,90 say transf(nTOTAL,"@E 99,999,999.99")
              @ prow()  ,110 say transf((nTOTAL/nPERC)*100,"@E 99.99") + " %"
              cPROD := asFAT[nCONT,1]
              zPROD := asFAT[nCONT,4]+" "+asFAT[nCONT,5]

              nQUANT     := 0
              nQUANT_ENT := 0
              nTOTAL     := 0
              nTOTAL_ENT := 0
           endif
       enddo
       @ prow()+1,00 say zPROD            //descricao do produto
       @ prow()  ,73 say transf(nQUANT,"@R 999999")
       @ prow()  ,90 say transf(nTOTAL,"@E 99,999,999.99")
       @ prow()  ,110 say transf((nTOTAL/nPERC)*100,"@E 99.99") + " %"

       nQUANT     := 0
       nQUANT_ENT := 0
       nTOTAL     := 0
       nTOTAL_ENT := 0
       nPERC  := 0
   endif

   qstopprn()

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO EM EXCEL__________________

static function i_impre_xls
    local nTOTAL     := 0
    local nVALOR     := 0
    local nDESC      := 0
    local nTOT_GER   := 0
    local nCONT      := 0
    local nQUANT     := 0
    local nQUANT_ENT := 0
    local nTOT_QUANT := 0
    local nTTQTDENT  := 0
    local cPROD      := 0
    local aRET       := {}
    local aFAT       := {}
    local asFAT      := {}
    local nPERC      := 0
    local lTEM := .T.
    local zPROD := space(50)
   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________
    lTEM := .F.
   //if ! qinitprn() ; return ; endif

   do while ! PEND->(eof())  .and. PEND->Dt_emissao >= dINI .and. PEND->Dt_emissao <= dFIM  // condicao principal de loop

      qgirabarra()

      qmensa("Aguarde... Processando ...")

         CLI1->(dbseek(PEND->Cod_cli))

         if ! empty(cREPRES)
            if PEND->Cod_repres != cREPRES
               PEND->(Dbskip())
               loop
            endif
         endif


         if ! empty(cCLI)
            if PEND->Cod_cli != cCLI
               PEND->(dbskip())
               loop
            endif
         endif


         ITEM_PEN->(Dbgotop())
         ITEM_PEN->(Dbseek(PEND->Codigo))
         do while ITEM_PEN->Cod_pend == PEND->Codigo .and. ! ITEM_PEN->(eof())
             PROD->(dbsetorder(4))
             PROD->(dbseek(ITEM_PEN->Cod_Prod))
             nVALOR := nVALOR +  (ITEM_PEN->Vl_unitar * ITEM_PEN->Quantidade)

             aadd(aFAT,{right(PROD->Codigo,5),ITEM_PEN->Quantidade,ITEM_PEN->Vl_unitar,nVALOR,PEND->Es,0})

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
   asFAT := asort(aFAT,,,{|x,y| x[1] < y[1] })
   if lTEM
       cPROD := asFAT[1,1]
       PROD->(Dbsetorder(4))
       PROD->(Dbseek(asFAT[1,1]))
       zPROD := PROD->Cod_fabr+Chr(9)+PROD->Cod_ass+Chr(9)+PROD->Descricao+Chr(9)+PROD->Marca

       nCONT := 1
       do while  nCONT <= len(asFAT)

           //if ! qlineprn() ; exit ; endif
           if XPAGINA == 0
              qpageprn()
              @ prow()+1,0 say chr(9)+Chr(9)+cTITULO+" 555"
              @ prow()+1,0 say chr(9)+Chr(9)+cTITULO2
              @ prow()+1,0 say "Cod. Fabr"+chr(9)+"Cod. Assoc."+Chr(9)+"Descricao"+chr(9)+"Marca"+Chr(9)+"Pendencia"+Chr(9)+"Valor"+Chr(9)+Chr(9)+"Estoque"
              @ prow()+1,0 say "         "+chr(9)+"           "+Chr(9)+"         "+chr(9)+"     "+Chr(9)+"         "+Chr(9)+"     "+chr(9)+Chr(9)+"Disponivel" +chr(9)+"Expedicao"+chr(9)+"Avariadas"+chr(9)+"Baixa" + chr(9) + "Total"
              @ prow()+1,0 say ""
           endif

           nQUANT += asFAT[nCONT,2]
           nTOT_QUANT += asFAT[nCONT,2]
           nTOTAL += asFAT[nCONT,4]    //Quantidade * valor unitario
           nTOT_GER += asFAT[nCONT,4]  //Quantidade * valor unitario


           nCONT++
           if nCONT > len(asFAT)
              nCONT := len(asFAT)
              exit
           endif
           if asFAT[nCONT,1] != cPROD
              @ prow()+1,00 say zPROD
              @ prow()  ,pcol() say chr(9)+transf(nQUANT,"@R 999999")
              @ prow()  ,pcol() say chr(9)+transf(nTOTAL,"@E 99,999,999.99")
              @ prow()  ,pcol() say chr(9)+transf((nTOTAL/nPERC)*100,"@E 99.99") + " %"
              aRET := i_calcEstoque(cPROD)
              @ prow()  ,pcol() say chr(9)+transf(aRET[1,1],"@R 99999999")
              @ prow()  ,pcol() say chr(9)+transf(aRET[1,2],"@R 99999999")
              @ prow()  ,pcol() say chr(9)+transf(aRET[1,3],"@R 99999999")
			  @ prow()  ,pcol() say chr(9)+transf(aRET[1,4],"@R 99999999")
			  @ prow()  ,pcol() say chr(9)+transf(aRET[1,5],"@R 99999999")
              cPROD := asFAT[nCONT,1]
              PROD->(Dbsetorder(4))
              PROD->(Dbseek(cPROD))
              zPROD := PROD->Cod_fabr+Chr(9)+PROD->Cod_ass+Chr(9)+PROD->Descricao+Chr(9)+PROD->Marca


              nQUANT_ENT := 0
              nQUANT := 0
              nTOTAL := 0
           endif
       enddo
       @ prow()+1,00 say zPROD            //descricao do produto
       @ prow()  ,pcol() say chr(9)+transf(nQUANT,"@R 999999")
       @ prow()  ,pcol() say chr(9)+transf(nTOTAL,"@E 99,999,999.99")
       @ prow()  ,pcol() say chr(9)+transf((nTOTAL/nPERC)*100,"@E 99.99") + " %"
       aRET := i_calcEstoque(cPROD)
       @ prow()  ,pcol() say chr(9)+transf(aRET[1,1],"@R 99999999")
       @ prow()  ,pcol() say chr(9)+transf(aRET[1,2],"@R 99999999")
       @ prow()  ,pcol() say chr(9)+transf(aRET[1,3],"@R 99999999")
	   @ prow()  ,pcol() say chr(9)+transf(aRET[1,4],"@R 99999999")
	   @ prow()  ,pcol() say chr(9)+transf(aRET[1,5],"@R 99999999")



       @ prow()+1,00 say ""
       @ prow()+1,00 say chr(9)+Chr(9)+chr(9)
       @ prow()  ,pcol() say chr(9)+transf(nTOT_QUANT,"@R 9999999")+chr(9)+transf(nTOT_GER,"@E 99,999,999.99")

       nQUANT := 0
       nTOTAL := 0
       nPERC  := 0
       nTOT_GER  := 0
   endif

   qstopprn()

return

static function buscaReservas(cPROD)
local nKey := 0

       nKey := ascan(aReservas,{|ckey| cKey[1] == cPROD})

       if nKey > 0
          return aReservas[nKey,4] 
       endif

return 0


