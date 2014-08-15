/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE COMPRAS
// OBJETIVO...: RELATORIO DE RESUMO DE COMPRAS
// ANALISTA...: EDUARDO BORIO
// PROGRAMADOR: O MESMO
// INICIO.....: JULHO DE 1999
// OBS........:
// ALTERACOES.:

function cp522

#define K_MAX_LIN 55

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local bESCAPE  := {||(XNIVEL==1 .and. !XFLAG).or.lastkey()==27}

private sBLOC1 := qlbloc("B522B","QBLOC.GLO") // ordem de impressao

private cTITULO                               // titulo do relatorio

private bFILTRO                               // code block de filtro
private cTIPO := " "
private bFILTRO1                              // code block de filtro
private aEDICAO := {}                         // vetor para os campos de entrada de dados
private lFLAG_1 := .F.                        // flag para impressao do total geral por filial
private lFLAG_2 := .F.                        // flag para segundo loop CCUSTO por centro de custo
private dINI := ctod("")
private dFIM := ctod("")
private sBLOC1 := qlbloc("B522B","QBLOC.GLO")

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qgetx(-1,0,@dINI     ,"@D"     ,NIL,NIL) } ,"DATA_INI"})
aadd(aEDICAO,{{ || qgetx(-1,0,@dFIM     ,"@D"     ,NIL,NIL) } ,"DATA_FIM"})
aadd(aEDICAO,{{ || qesco(-1,0,@cTIPO ,sBLOC1                 )} ,"TIPO" })


do while .T.

   qlbloc(5,0,"B522A","QBLOC.GLO",1)
   XNIVEL  := 1
   XFLAG   := .T.
   cTIPO := " "

   // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; dbcloseall() ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   if ( i_inicializacao() , i_impressao() , NIL )

enddo

/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA _____________________________________________

static function i_critica ( cCAMPO )

   do case
      case cCAMPO == "DATA_INI"
           if empty(dINI) ; return .F. ; endif
           dFIM := qfimmes(dINI)
           qrsay(XNIVEL+1,dFIM)

      case cCAMPO == "DATA_FIM"
           if empty(dFIM) ; return .F. ; endif
           if dINI > dFIM
              qmensa("Data Inicial n„o pode ser maior que a Data Final !","B")
              return .F.
           endif

      case cCAMPO == "TIPO"
           qrsay(XNIVEL,qabrev(cTIPO," 123456", {"Todos","Produto Acabado","Matria prima","Material","Embalagens","Vazios","Outros"}))

   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // CRIA TITULO DO RELATORIO ______________________________________________

   cTITULO := "RESUMO DE COMPRAS POR PRODUTO: " + dtoc(dINI) + " ATE " + dtoc(dFIM)
   
   // SELECIONA ORDEM DO ARQUIVO CODIGOS_____________________________________

   qmensa("")

   PROD->(dbsetorder(4))

   PEDIDO->(dbsetorder(6)) // data_ped
   PEDIDO->(dbgotop())
   set softseek on
   PEDIDO->(dbseek(dtos(dINI)))
   set softseek off


return .T.


static function i_impressao

   qinitprn()

   if XLOCALIMP == "X"
      i_impre_xls()
   else
      i_impre_prn()
   endif


return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impre_prn

   local cPIC   := "@E 99,999,999.99"
   local cPICQ  := "@R 99999999"
   local nTOTAL := 0
   local aPROD  := {}
   local nQTY   := 0
   local nCONT  := 0

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

//   if ! qinitprn() ; return ; endif

   qgirabarra()

   do while ! PEDIDO->(eof())

      qgirabarra()

      if PEDIDO->Data_ped < dINI .or. PEDIDO->Data_ped > dFIM
         PEDIDO->(dbskip())
         loop
      endif


      LANC->(dbseek(PEDIDO->Codigo))
      do while ! LANC->(eof()) .and. LANC->Cod_ped == PEDIDO->Codigo

         PROD->(dbseek(LANC->Cod_prod))

         if cTIPO == " "
            aadd(aProd,{LANC->Cod_prod,LANC->Quant,LANC->preco,LANC->Quant * LANC->preco})
         else
            if PROD->Tipo == cTIPO
               aadd(aProd,{LANC->Cod_prod,LANC->Quant,LANC->preco,LANC->Quant * LANC->preco})
            endif
         endif

         LANC->(dbskip())

      enddo

      PEDIDO->(dbskip())

   enddo

   aProd := asort(aProd,,,{|x,y| x[1] < y[1] })

   if len(aProd) > 0
       cPROD   := aProd[1,1]
       nQTY    := 0

       nCONT := 1
       do while  nCONT <= len(aProd)


           if XPAGINA == 0 .or. prow() > K_MAX_LIN
              qpageprn()
              qcabecprn(cTITULO,134,,qabrev(cTIPO," 123456", {"Todos","Produto Acabado","Matria prima","Material","Embalagens","Vazios","Outros"}))
              @ prow()+1,0 say "Codigo    Descricao                                                 Quantidade                                  Valor Total"
              @ prow()+1,0 say replicate("-",134)
           endif


           nQTY   += aProd[nCONT,2]
           nTOTAL += aProd[nCONT,4]

           nCONT++
           if nCONT > len(aProd)
              nCONT := len(aProd)
              exit
           endif

           if aProd[nCONT,1] != cPROD
              PROD->(dbseek(cPROD))
              @ prow()+1,00  say right(PROD->Codigo,5)
              @ prow()  ,10  say left(PROD->Descricao,45)
              @ prow()  ,70  say transf(nQTY,cPICQ)
              @ prow()  ,90  say transf(nTOTAL/nQTY,cPIC)
              @ prow()  ,110 say transf(nTOTAL,cPIC)

              cPROD   := aProd[nCONT,1]
              nQTY    := 0
              nTOTAL  := 0
           endif
       enddo

       if nQTY > 0
          PROD->(dbseek(cPROD))
          @ prow()+1,00  say right(PROD->Codigo,5)
          @ prow()  ,10  say left(PROD->Descricao,45)
          @ prow()  ,70  say transf(nQTY,cPICQ)
          @ prow()  ,90  say transf(nTOTAL/nQTY,cPIC)
          @ prow()  ,110 say transf(nTOTAL,cPIC)

          cPROD   := aProd[nCONT,1]
          nQTY    := 0
          nTOTAL  := 0

       endif

       nQTY   := 0
       nTOTAL := 0

   endif

   qstopprn(.F.)

return


/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impre_xls

   local cPIC   := "@E 99,999,999.99"
   local cPICQ  := "@R 99999999"
   local nTOTAL := 0
   local aPROD  := {}
   local nQTY   := 0
   local nCONT  := 0

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   //if ! qinitprn() ; return ; endif

   qgirabarra()

   do while ! PEDIDO->(eof())

      qgirabarra()

      if PEDIDO->Data_ped < dINI .or. PEDIDO->Data_ped > dFIM
         PEDIDO->(dbskip())
         loop
      endif


      LANC->(dbseek(PEDIDO->Codigo))
      do while ! LANC->(eof()) .and. LANC->Cod_ped == PEDIDO->Codigo

         PROD->(dbseek(LANC->Cod_prod))

         if cTIPO == " "
            aadd(aProd,{LANC->Cod_prod,LANC->Quant,LANC->preco,LANC->Quant * LANC->preco})
         else
            if PROD->Tipo == cTIPO
               aadd(aProd,{LANC->Cod_prod,LANC->Quant,LANC->preco,LANC->Quant * LANC->preco})
            endif
         endif

         LANC->(dbskip())

      enddo

      PEDIDO->(dbskip())

   enddo

   aProd := asort(aProd,,,{|x,y| x[1] < y[1] })

   if len(aProd) > 0
       cPROD   := aProd[1,1]
       nQTY    := 0

       nCONT := 1
       do while  nCONT <= len(aProd)


           if XPAGINA == 0 //.or. prow() > K_MAX_LIN
              qpageprn()
              //qcabecprn(cTITULO,134,,qabrev(cTIPO," 123456", {"Todos","Produto Acabado","Matria prima","Material","Embalagens","Vazios","Outros"}))
              @ prow()+1,0 say chr(9)+cTITULO+" 522 - Compras"
              @ prow()+1,0 say "Codigo"+chr(9)+"Descricao"+chr(9)+"Quantidade"+chr(9)+"Valor Total"
           endif


           nQTY   += aProd[nCONT,2]
           nTOTAL += aProd[nCONT,4]

           nCONT++
           if nCONT > len(aProd)
              nCONT := len(aProd)
              exit
           endif

           if aProd[nCONT,1] != cPROD
              PROD->(dbseek(cPROD))
              @ prow()+1,00      say right(PROD->Cod_ass,7)
              @ prow()  ,pcol()  say chr(9)+left(PROD->Descricao,45)
              @ prow()  ,pcol()  say chr(9)+transf(nQTY,cPICQ)
              @ prow()  ,pcol()  say chr(9)+transf(nTOTAL/nQTY,cPIC)
              @ prow()  ,pcol()  say chr(9)+transf(nTOTAL,cPIC)

              cPROD   := aProd[nCONT,1]
              nQTY    := 0
              nTOTAL  := 0
           endif
       enddo

       if nQTY > 0
          PROD->(dbseek(cPROD))
          @ prow()+1,00      say right(PROD->Cod_ass,7)
          @ prow()  ,pcol()  say chr(9)+left(PROD->Descricao,45)
          @ prow()  ,pcol()  say chr(9)+transf(nQTY,cPICQ)
          @ prow()  ,pcol()  say chr(9)+transf(nTOTAL/nQTY,cPIC)
          @ prow()  ,pcol()  say chr(9)+transf(nTOTAL,cPIC)

          cPROD   := aProd[nCONT,1]
          nQTY    := 0
          nTOTAL  := 0

       endif

       nQTY   := 0
       nTOTAL := 0

   endif

   qstopprn(.F.)

return

