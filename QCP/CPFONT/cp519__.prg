//////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO COMERCIO
// OBJETIVO...: LISTAGEM DE PRODUTOS FATURADOS
// ANALISTA...: EDUARDO AUGUSTO BORIO
// PROGRAMADOR: EDUARDO AUGUSTO BORIO
// INICIO.....: SETEMBRO DE 2009
// OBS........:
// ALTERACOES.:

function cp519
#define K_MAX_LIN 57

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG) .or. empty(dINI) }

private cTITULO                   // titulo do relatorio
private dINI
private dFIM
private cSETOR := space(5)
private aEDICAO := {}             // vetor para os campos de entrada de dados

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qgetx(-1,0,@dINI)            } , "INI"    })
aadd(aEDICAO,{{ || qgetx(-1,0,@dFIM)            } , "FIM"    })

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

   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // CRIA TITULO DO RELATORIO ______________________________________________


   cTITULO := "LISTAGEM DE PRODUTOS COMPRADOS" +" de " + dtoc(dINI) + " a " + dtoc(dFIM)

   qmensa("")

   // ESTABELECE RELACOES ENTRE ARQUIVOS ____________________________________

   PEDIDO->(dbsetorder(1)) // data de emissao
   PEDIDO->(dbgotop())
   set softseek on
   PEDIDO->(dbseek(dtos(dINI)))
   set softseek off
   LANC->(dbsetorder(1))
return .T.


static function i_impressao

   if ! qinitprn() ; return ; endif

   if XLOCALIMP == "X"
      i_impre_xls()
   else
      i_impre_prn()
   endif

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impre_prn
    local nCONT      := 0
    local nQUANT     := 0
    local nPRECO     := 0
    local cPROD      := 0
    local aFAT       := {}
    local asFAT      := {}
    local aPROD      := {}
    local lTEM := .T.

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   lTEM := .F.

   do while ! PEDIDO->(eof())  .and. PEDIDO->Data_ped >= dINI .and. PEDIDO->Data_ped <= dFIM  // condicao principal de loop

      qgirabarra()

      qmensa("Aguarde... Processando ...")

      LANC->(Dbseek(PEDIDO->Codigo))
      do while LANC->Cod_ped == PEDIDO->Codigo .and. ! LANC->(eof())
         aadd(aFAT,{right(PROD->Codigo,5),LANC->Quantidade,LANC->Preco})
         LANC->(Dbskip())
         nVALOR := 0
         lTEM := .T.
      enddo
      PEDIDO->(dbskip())
      nVALOR := 0
      nDESC := 0
   enddo

   //classifica a matriz por produto
   asFAT := asort(aFAT,,,{|x,y| x[1] < y[1] })
   if lTEM
       cPROD := asFAT[1,1]

       nCONT := 1
       do while  nCONT <= len(asFAT)

           if ! qlineprn() ; exit ; endif
           if XPAGINA == 0 .or. prow() > K_MAX_LIN
              @prow()+1,0 say XCOND0
              qpageprn()
              qcabecprn(cTITULO,80)
              @ prow()+1,0 say XCOND1 + "Produto                                                      Preco Custo     Qtde         Preco Compra    Qtde      Preco Custo Atual "
              @ prow()+1,0 say XCOND1 + "                                                               Anterior    Anterior                                                   "
              @ prow()+1,0 say replicate("-",134)
           endif

           nQUANT += asFAT[nCONT,2]
           nPRECO += asFAT[nCONT,3]

           nCONT++
           if nCONT > len(asFAT)
              nCONT := len(asFAT)
              exit
           endif

           if asFAT[nCONT,1] != cPROD

              aadd(aProd,{cPROD,nQUANT,nPRECO})

              cPROD := asFAT[nCONT,1]

              nQUANT     := 0
              nPRECO     := 0
           endif
       enddo
       if nQUANT > 0 .or. nPRECO > 0
          aadd(aProd,{cPROD,nQUANT,nPRECO})
       endif

       nQUANT     := 0
       nPRECO     := 0
   endif

return

