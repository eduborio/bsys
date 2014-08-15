/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE COMPRAS
// OBJETIVO...: RELATORIO DOS 100 FORNECEDORES MAIS COMPRADOS
// ANALISTA...:
// PROGRAMADOR: LUCINEIDE VILAR POSSEBOM
// INICIO.....: JANEIRO DE 1997
// OBS........:
// ALTERACOES.:

function cp506

#define K_MAX_LIN 55

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local bESCAPE  := {||(XNIVEL==1 .and. !XFLAG).or.lastkey()==27}

private sBLOC1 := qlbloc("B506B","QBLOC.GLO") // ordem de impressao

private cTITULO                               // titulo do relatorio

private aEDICAO := {}                         // vetor para os campos de entrada de dados
private dDATA_INI
private dDATA_FIN
private aFORN := {}

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qgetx(-1,0,@dDATA_INI  ,"@D")         },"DATA_INI" })
aadd(aEDICAO,{{ || qgetx(-1,0,@dDATA_FIN  ,"@D")         },"DATA_FIN" })

do while .T.

   qlbloc(5,0,"B506A","QBLOC.GLO",1)
   XNIVEL  := 1
   XFLAG   := .T.
   dDATA_INI := dDATA_FIN := ctod("")

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
           if empty(dDATA_INI) ; return .F. ; endif

      case cCAMPO == "DATA_FIN"
           if empty(dDATA_FIN) ; return .F. ; endif

           if dDATA_FIN < dDATA_INI
              qmensa("Data Inicial superior a data final !")
              return .F.
           endif

   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // CRIA TITULO DO RELATORIO ______________________________________________

   cTITULO := "RELATORIO DOS 100 FORNECEDORES MAIS COMPRADOS DE :"+dtoc(dDATA_INI)+" A: "+dtoc(dDATA_FIN)

   PEDIDO->(Dbsetorder(6))
   PEDIDO->(Dbgotop())
   set softseek on
   PEDIDO->(Dbseek(dtos(dDATA_INI)))
   set softseek off

   // ROTINA QUE CRIA O VETOR E CALCULA TODOS OS FORNECEDORES NESTE PERIODO SOMANDO AS COMPRAS REALIZADAS____________

   do while ! PEDIDO->(eof()) .and. PEDIDO->Data_ped >= dDATA_INI .and. PEDIDO->Data_ped <= dDATA_FIN

      if ( nTMP := ascan(aFORN,{|cTMP| cTMP[1] == PEDIDO->Cod_forn}) ) == 0  // Soma os valores por codigo do fornecedor
         aadd(aFORN, { PEDIDO->Cod_forn , 1 , PEDIDO->Val_liq } )
      else
         aFORN[nTMP,2] += 1
         aFORN[nTMP,3] += PEDIDO->Val_liq
      endif

      PEDIDO->(Dbskip())

   enddo

   // REALIZA CLASSIFICACAO DO ARRAY QUANTIDADE (aQUANT) EM ORDEM DESCENDENTE PARA IMPRESSAO DOS MAIS COMPRADOS____________

   asort(aFORN,,, { |x,y| x[2] > y[2] } )

   qmensa("")

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impressao

   local nTMP
   local cCOND  := 0
   local nCONTX := 0
   local nTOT_FOR := nTOT_QTD := nTOT_VAL := 0

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif

   if ! qlineprn() ; return ; endif
   qgirabarra()

   iif ( len(aFORN) > 100 ,  cCOND := 100 , cCOND := len(aFORN) )

   for nCONTX := 1 to cCOND

       if XPAGINA == 0 .or. prow() > K_MAX_LIN
          qpageprn()
          qcabecprn(cTITULO,80)
          @ prow()+1 ,00 say "CODIGO  RAZAO SOCIAL                                 QUANTIDADE   VALOR COMPRADO"
          @ prow()+1,0 say replicate("-",80)
       endif

       @ prow()+1,00  say aFORN[nCONTX,1]
       @ prow()  ,08  say iif( FORN->(Dbseek(aFORN[nCONTX,1])), left(FORN->Razao,45) , space(45) )
       @ prow()  ,53  say transform(aFORN[nCONTX,2], "@e 99999")
       @ prow()  ,66  say transform(aFORN[nCONTX,3], "@e 999,999,999.99")

       nTOT_FOR += 1
       nTOT_QTD += aFORN[nCONTX,2]
       nTOT_VAL += aFORN[nCONTX,3]

   next

   @ prow()+1,0 say replicate("-",80)
   @ prow()+1,17 say "Total de Fornecedores .........>            "+transform(nTOT_FOR,"@e 999")
   @ prow()+1,17 say "Total Quantidade de Compra.....>           "+transform(nTOT_QTD, "@e 9999")
   @ prow()+1,17 say "Total do Valor Comprado........> "+transform(nTOT_VAL, "@e 999,999,999.99")
   @ prow()+1,0 say replicate("-",80)

   aFORN := {}

   qstopprn()

return
