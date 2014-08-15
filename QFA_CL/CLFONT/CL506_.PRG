//////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO COMERCIO
// OBJETIVO...: LISTAGEM DE PRODUTOS FATURADOS
// ANALISTA...: EDUARDO AUGUSTO BORIO
// PROGRAMADOR: EDUARDO AUGUSTO BORIO
// INICIO.....: SETEMBRO DE 2002
// OBS........:
// ALTERACOES.:

function cl506
#define K_MAX_LIN 57

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG) .or. empty(dINI) }

private cTITULO                   // titulo do relatorio
private dINI
private dFIM
private cSETOR := space(5)
private aEDICAO := {}             // vetor para os campos de entrada de dados
private aReservas := {}

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qgetx(-1,0,@dINI)            } , "INI"    })
aadd(aEDICAO,{{ || qgetx(-1,0,@dFIM)            } , "FIM"    })
aadd(aEDICAO,{{ || view_setor(-1,0,@cSETOR)     } , "SETOR"  })
aadd(aEDICAO,{{ || NIL                          } , NIL  })

do while .T.

   qlbloc(5,0,"B519A","QBLOC.GLO")
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

           qrsay(XNIVEL,cSETOR)

           if empty(cSETOR)
              qrsay(XNIVEL++, "Todos os Setores.......")
           else
              if ! SETOR->(Dbseek(cSETOR:=strzero(val(cSETOR),5)))
                 qmensa("Setor n„o Cadastrado","B")
                 return .F.
              else
                 qrsay(XNIVEL++,left(SETOR->Descricao,30))
              endif
           endif

   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // CRIA TITULO DO RELATORIO ______________________________________________


   cTITULO := "LISTAGEM DE PRODUTOS FATURADOS" +" de " + dtoc(dINI) + " a " + dtoc(dFIM)

   qmensa("")

   // ESTABELECE RELACOES ENTRE ARQUIVOS ____________________________________

   FAT->(dbsetorder(2)) // data de emissao
   FAT->(dbgotop())
   set softseek on
   FAT->(dbseek(dtos(dINI)))
   set softseek off
   ITEN_FAT->(dbsetorder(2))
return .T.


static function i_impressao

   if ! qinitprn() ; return ; endif

   i_reserva()

   if XLOCALIMP == "X"
      i_impre_xls()
   else
      //i_impre_prn()
	  alert("Somente disponivel em excell!")
   endif



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
    local aFAT       := {}
    local asFAT      := {}
    local nPERC      := 0
    local lTEM := .T.
    local zPROD := space(50)
    local aEstoque := {}
    local aPROD := {}
   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________
    lTEM := .F.
   //if ! qinitprn() ; return ; endif

   FAT->(dbsetorder(2)) // data de emissao
   FAT->(dbgotop())
   set softseek on
   FAT->(dbseek(dtos(dINI)))
   set softseek off
   ITEN_FAT->(dbsetorder(2))


   do while ! FAT->(eof())  .and. FAT->Dt_emissao >= dINI .and. FAT->Dt_emissao <= dFIM  // condicao principal de loop

      if FAT->Cancelado
         FAT->(dbskip())
         loop
      endif

      if empty(FAT->Num_fatura) .and. FAT->Es == "S"
         FAT->(dbskip())
         loop
      endif

      //if ! left(FAT->Cod_cfop,3) $ "510-511-512-610-611-612-591-691-120-220"
      //   FAT->(dbskip())
      //   loop
      //endif

      qgirabarra()

      qmensa("Aguarde... Processando ...")

         CLI1->(dbseek(FAT->Cod_cli))

         ITEN_FAT->(Dbgotop())
         ITEN_FAT->(Dbseek(FAT->Codigo))
         do while ITEN_FAT->Num_fat == FAT->Codigo .and. ! ITEN_FAT->(eof())
             PROD->(dbsetorder(4))
             PROD->(dbseek(ITEN_FAT->Cod_Prod))
             nVALOR := nVALOR + ( (ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade) + ( (ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade)*(ITEN_FAT->Ipi/100) ) )
             nVALOR := nVALOR + q_soma_st()

             if FAT->Es == "S"
                aadd(aFAT,{right(PROD->Codigo,5),ITEN_FAT->Quantidade,ITEN_FAT->Vl_unitar,nVALOR,FAT->Es,0})
             else
                aadd(aFAT,{right(PROD->Codigo,5),0,ITEN_FAT->Vl_unitar,nVALOR,FAT->Es,ITEN_FAT->Quantidade})
             endif

             nPERC += nVALOR
             ITEN_FAT->(Dbskip())
             nVALOR := 0

             lTEM := .T.
         enddo
         FAT->(dbskip())
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


           if asFAT[nCONT,5] == "S"  // Se for Saida soma as quantidade senao diminui
              nQUANT += asFAT[nCONT,2]
              nTOT_QUANT += asFAT[nCONT,2]
              nTOTAL += asFAT[nCONT,4]    //Quantidade * valor unitario
              nTOT_GER += asFAT[nCONT,4]  //Quantidade * valor unitario

           else
              nQUANT_ENT += asFAT[nCONT,6]
              nTTQTDENT   += asFAT[nCONT,6]
              nTOTAL     -= asFAT[nCONT,4]    //Quantidade * valor unitario
              nTOT_GER   += asFAT[nCONT,4]  //Quantidade * valor unitario
           endif

           nCONT++
           if nCONT > len(asFAT)
              nCONT := len(asFAT)
              exit
           endif
           if asFAT[nCONT,1] != cPROD
              //@ prow()+1,00 say zPROD
              PROD->(dbseek(cPROD))

              //@ prow()  ,pcol() say chr(9)+transf(nQUANT_ENT,"@R 999999")
              //@ prow()  ,pcol() say chr(9)+transf(nQUANT,"@R 999999")
              //if CONFIG->Modelo_fat != "1"
              //   @ prow()  ,pcol() say chr(9)+transf(nTOTAL,"@E 99,999,999.99")
              //   @ prow()  ,pcol() say chr(9)+transf((nTOTAL/nPERC)*100,"@E 99.99") + " %"
              //endif
              //@ prow()  ,pcol() say chr(9)+PROD->Corredor+" "+PROD->Estante+" "+PROD->Prateleira
              //@ prow()  ,pcol() say chr(9)+transform(PROD->Peso,"@R 999999.99")
              aEstoque := i_CalcEstoque(cPROD)
              //@ prow()  ,pcol() say chr(9)+transform(aEstoque[1,1],"@R 999999")
              //@ prow()  ,pcol() say chr(9)+transform(aEstoque[1,2],"@R 999999")

              aadd(aPROD,{zPROD,nQUANT_ENT,nQUANT,PROD->Corredor+" "+PROD->Estante+" "+PROD->Prateleira,PROD->Peso,aEstoque[1,1],aEstoque[1,2],aEstoque[1,3],aEstoque[1,4],aEstoque[1,5]})

              cPROD := asFAT[nCONT,1]
              PROD->(Dbsetorder(4))
              PROD->(Dbseek(cPROD))
              zPROD := PROD->Cod_fabr+Chr(9)+PROD->Cod_ass+Chr(9)+PROD->Descricao+Chr(9)+PROD->Marca


              nQUANT_ENT := 0
              nQUANT := 0
              nTOTAL := 0
           endif
       enddo

       //@ prow()+1,00 say zPROD            //descricao do produto
       //@ prow()  ,pcol() say chr(9)+transf(nQUANT_ENT,"@R 999999")
       //@ prow()  ,pcol() say chr(9)+transf(nQUANT,"@R 999999")
       //if CONFIG->Modelo_fat != "1"
       //   @ prow()  ,pcol() say chr(9)+transf(nTOTAL,"@E 99,999,999.99")
       //   @ prow()  ,pcol() say chr(9)+transf((nTOTAL/nPERC)*100,"@E 99.99") + " %"
       //endif
       //PROD->(dbseek(cPROD))

       //@ prow()  ,pcol() say chr(9)+PROD->Corredor+" "+PROD->Estante+" "+PROD->Prateleira
       //@ prow()  ,pcol() say chr(9)+transform(PROD->Peso,"@R 999999.99")
       
       //@ prow()  ,pcol() say chr(9)+transform(aEstoque[1,1],"@R 999999")
       //@ prow()  ,pcol() say chr(9)+transform(aEstoque[1,2],"@R 999999")
	   aEstoque := i_CalcEstoque(cPROD)
	   aadd(aPROD,{zPROD,nQUANT_ENT,nQUANT,PROD->Corredor+" "+PROD->Estante+" "+PROD->Prateleira,PROD->Peso,aEstoque[1,1],aEstoque[1,2],aEstoque[1,3],aEstoque[1,4],aEstoque[1,5]})

       aProd := asort(aProd,,,{|x,y| x[4] < y[4] })


       for nCONT := 1 to len(aProd)

           if XPAGINA == 0
              qpageprn()
              @ prow()+1,0 say chr(9)+Chr(9)+cTITULO
              @ prow()+1,0 say "Cod. Fabr"+chr(9)+"Cod. Assoc."+Chr(9)+"Descricao"+chr(9)+"Marca"+Chr(9)+"Entrada"+chr(9)+"Saida"+Chr(9)+"Localizacao"+chr(9)+"Peso"+chr(9)+"Disponivel"+chr(9)+"Expedicao"+Chr(9)+"Avariado"+chr(9)+"Baixa" + Chr(9)+"Total"
              @ prow()+1,0 say ""
           endif


           @ prow()+1,00     say aProd[nCont,1]
           @ prow()  ,pcol() say chr(9)+transf(aProd[nCont,2],"@R 999999")
           @ prow()  ,pcol() say chr(9)+transf(aProd[nCont,3],"@R 999999")
           @ prow()  ,pcol() say chr(9)+aProd[nCont,4]
           @ prow()  ,pcol() say chr(9)+transform(aProd[nCont,5],"@R 999999.99")

		   @ prow()  ,pcol() say chr(9)+transform(aProd[nCont,6],"@R 99999999")
		   @ prow()  ,pcol() say chr(9)+transform(aProd[nCont,7],"@R 99999999")
		   @ prow()  ,pcol() say chr(9)+transform(aProd[nCont,8],"@R 99999999")
		   @ prow()  ,pcol() say chr(9)+transform(aProd[nCont,9],"@R 99999999")
		   @ prow()  ,pcol() say chr(9)+transform(aProd[nCont,10],"@R 99999999")

       next




       @ prow()+1,00 say ""
       @ prow()+1,00 say chr(9)+Chr(9)+chr(9)+chr(9)+transf(nTTQTDENT,"@R 9999999")
       @ prow()  ,pcol() say chr(9)+transf(nTOT_QUANT,"@R 9999999")+chr(9)+transf(nTOT_GER,"@E 99,999,999.99")

       nQUANT := 0
       nTOTAL := 0
       nPERC  := 0
       nTOT_GER  := 0
   endif

   qstopprn(.f.)

return

static function i_calcEstoque(Cod_prod)
local nQUANT_RES  := 0  //Avariados
local nQUANT_AVAR := 0  //Avariados
local nQUANT      := 0  //Em Transicao
local nQUANT_show := 0  //Em Transicao
local nTotal := 0
local aResult := {}

  INVENT->(dbsetorder(4))
  INVENT->(dbseek(Cod_prod))

  do while ! INVENT->(eof()) .and. INVENT->Cod_prod == Cod_prod
     nQUANT      += INVENT->Quant_atu
     nQUANT_AVAR += INVENT->Quant_defe
	 nQUANT_SHOW += INVENT->Quant_show

     INVENT->(dbskip())
  enddo

  
  nQUANT_RES := buscaReservas(cod_prod)
  
  
  nTotal := (nQUANT + nQUANT_RES + nQUANT_AVAR + nQUANT_SHOW)

  aadd(aResult,{nQUANT,nQUANT_RES,nQUANT_AVAR,nQUANT_SHOW,nTotal})

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
local nIndex  := FAT->(IndexOrd())
local nReg    := FAT->(recNo())

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
FAT->(dbsetorder(nIndex))
FAT->(dbgoto(nReg))

return

static function buscaReservas(cPROD)
local nKey := 0

       nKey := ascan(aReservas,{|ckey| cKey[1] == cPROD})

       if nKey > 0
          return aReservas[nKey,4] 
       endif

return 0




