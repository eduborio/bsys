//////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO COMERCIO
// OBJETIVO...: LISTAGEM DE PRODUTOS FATURADOS
// ANALISTA...: EDUARDO AUGUSTO BORIO
// PROGRAMADOR: EDUARDO AUGUSTO BORIO
// INICIO.....: SETEMBRO DE 2002
// OBS........:
// ALTERACOES.:

function cl583
#define K_MAX_LIN 57

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG) .or. empty(dINI) }

private cTITULO                   // titulo do relatorio
private dINI
private dFIM
private cCLI := space(5)
private aEDICAO := {}             // vetor para os campos de entrada de dados

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qgetx(-1,0,@dINI)            } , "INI"    })
aadd(aEDICAO,{{ || qgetx(-1,0,@dFIM)            } , "FIM"    })
aadd(aEDICAO,{{ || view_cli2(-1,0,@cCLI)        } , "CLI"  })
aadd(aEDICAO,{{ || NIL                          } , NIL  })

do while .T.

   qlbloc(5,0,"B583A","QBLOC.GLO")
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

      case cCAMPO == "CLI"

           qrsay(XNIVEL,cCLI)

           if empty(cCLI)
              qrsay(XNIVEL++, "Todos os Clientes.......")
           else
              if ! CLI1->(Dbseek(cSETOR:=strzero(val(cCLI),5)))
                 qmensa("Cliente n„o Cadastrado","B")
                 return .F.
              else
                 qrsay(XNIVEL++,left(CLI1->Razao,30))
              endif
           endif

   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // CRIA TITULO DO RELATORIO ______________________________________________


   cTITULO := "LISTAGEM DE ENTRADA DE PRODUTOS" +" de " + dtoc(dINI) + " a " + dtoc(dFIM)

   qmensa("")

   // ESTABELECE RELACOES ENTRE ARQUIVOS ____________________________________

   FAT->(dbsetfilter({|| Es == "E" .and. Dt_emissao >= dINI  .and. Dt_emissao <= dFIM .and. !Cancelado }))
   ITEN_FAT->(dbsetorder(2))
   FAT->(dbgotop())

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
    local nQty := 0
    local nTotQty := 0
    local nVal := 0
    local nTotVal := 0

    local nVALOR     := 0

    local nCONT      := 0
    local cCLIENTE   := 0
    local aFAT       := {}
    local asFAT      := {}

    PROD->(dbsetorder(4))

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________
    lTEM := .F.

   do while ! FAT->(eof())  

      qmensa("Aguarde... Processando ...")

         CLI1->(dbseek(FAT->Cod_cli))

         if ! empty(cCLI)
            if FAT->cod_cli != cCLI
               FAT->(dbskip())
               loop
            endif
         endif

         ITEN_FAT->(Dbgotop())
         ITEN_FAT->(Dbseek(FAT->Codigo))
         do while ITEN_FAT->Num_fat == FAT->Codigo .and. ! ITEN_FAT->(eof())
             nVALOR := nVALOR + (ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade)
             nVALOR += q_soma_st()
             aadd(aFAT,{FAT->cod_cli,ITEN_FAT->cod_prod,FAT->Dt_emissao,FAT->Num_fatura,ITEN_FAT->Quantidade,ITEN_FAT->Vl_unitar,nVALOR,left(FAT->Cod_cfop,4)})
             ITEN_FAT->(Dbskip())
             nVALOR := 0
         enddo
         FAT->(dbskip())
         nVALOR := 0
   enddo

   //classifica a matriz por descricao do produto
   asFAT := asort(aFAT,,,{|x,y| x[1] + dtos(x[3]) < y[1] + dtos(y[3]) })
   if len(asFAT) > 0

       cCLIENTE  := asFAT[1,1]

       nCONT := 1
       do while  nCONT <= len(asFAT)

           //if ! qlineprn() ; exit ; endif
           if XPAGINA == 0 .or. prow() > K_MAX_LIN
              @prow()+1,0 say XCOND1
              qpageprn()
              qcabecprn(cTITULO,132)
              @ prow()+1,0 say "Cfop   Cliente                         Emissao     NF       Ref      Descricao               Qtde        Unit.    Valor Total"
              @ prow()+1,0 say replicate("-",132)
           endif

           @ prow()+1,00  say asFAT[nCONT,8]
           CLI1->(dbseek(asFAT[nCONT,1]))
           @ prow()  ,07  say left(CLI1->Razao,30)
           @ prow()  ,39  say dtoc(asFAT[nCONT,3])
           @ prow()  ,51  say asFAT[nCONT,4]
           PROD->(dbseek(asFAT[nCONT,2]))
           @ prow()  ,60  say PROD->Cod_ass
           @ prow()  ,69  say left(PROD->Descricao,19)
           @ prow()  ,91  say transf(asFAT[nCONT,5],"@R 999999")
           @ prow()  ,100 say transf(asFAT[nCONT,6],"@E 999,999.99")
           @ prow()  ,115 say transf(asFAT[nCONT,7],"@E 999,999.99")

           nQty    += asFAT[nCONT,5]
           nTotQty += asFAT[nCONT,5]

           nVal    += asFAT[nCONT,7]
           nTotVal += asFAT[nCONT,7]


           nCONT++
           if nCONT > len(asFAT)
              nCONT := len(asFAT)
              exit
           endif

           if asFAT[nCONT,1] != cCLIENTE
              CLI1->(dbseek(cCLIENTE))
              @ prow()+1,00 say replicate("-",132)
              @ prow()+1,00 say "       "+"Total"
              @ prow()  ,91  say transf(nQty,"@R 999999")
              @ prow()  ,100 say transf(nVal/nqty,"@E 999,999.99")
              @ prow()  ,115 say transf(nVal,"@E 999,999.99")
              @ prow()+1,00 say ""

              nQty := 0
              nVal := 0
              cCLIENTE := asFat[nCONT,1]
           endif
       enddo

       if nVAL <> 0
          CLI1->(dbseek(cCLIENTE))
          @ prow()+1,00 say replicate("-",132)
          @ prow()+1,00 say "       "+"Total"
          @ prow()  ,91  say transf(nQty,"@R 999999")
          @ prow()  ,100 say transf(nVal/nQty,"@E 999,999.99")
          @ prow()  ,115 say transf(nVal,"@E 999,999.99")

          nQty := 0
          nVal := 0
       endif

       if nTotVAL <> 0
          @ prow()+1,00 say "Total Geral "
          @ prow()  ,91  say transf(nTotQty,"@R 999999")
          @ prow()  ,100 say transf(nTotVal/nTotqty,"@E 999,999.99")
          @ prow()  ,115 say transf(nTotVal,"@E 999,999.99")

          nQty := 0
          nVal := 0
          nTotQty := 0
          nTotVal := 0
       endif




   endif

   qstopprn(.f.)

return


static function i_impre_xls
    local nQty := 0
    local nTotQty := 0
    local nVal := 0
    local nTotVal := 0

    local nVALOR     := 0

    local nCONT      := 0
    local cCLIENTE   := 0
    local aFAT       := {}
    local asFAT      := {}

    PROD->(dbsetorder(4))

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________
    lTEM := .F.

   do while ! FAT->(eof())  

      qmensa("Aguarde... Processando ...")

         CLI1->(dbseek(FAT->Cod_cli))

         if ! empty(cCLI)
            if FAT->cod_cli != cCLI
               FAT->(dbskip())
               loop
            endif
         endif

         ITEN_FAT->(Dbgotop())
         ITEN_FAT->(Dbseek(FAT->Codigo))
         do while ITEN_FAT->Num_fat == FAT->Codigo .and. ! ITEN_FAT->(eof())
             nVALOR := nVALOR + (ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade)
             nVALOR += q_soma_st()
             aadd(aFAT,{FAT->cod_cli,ITEN_FAT->cod_prod,FAT->Dt_emissao,FAT->Num_fatura,ITEN_FAT->Quantidade,ITEN_FAT->Vl_unitar,nVALOR,left(FAT->Cod_cfop,4)})
             ITEN_FAT->(Dbskip())
             nVALOR := 0
         enddo
         FAT->(dbskip())
         nVALOR := 0
   enddo

   //classifica a matriz por descricao do produto
   asFAT := asort(aFAT,,,{|x,y| x[1] + dtos(x[3]) < y[1] + dtos(y[3]) })
   if len(asFAT) > 0

       cCLIENTE  := asFAT[1,1]

       nCONT := 1
       do while  nCONT <= len(asFAT)

           //if ! qlineprn() ; exit ; endif
           if XPAGINA == 0
              qpageprn()
              @ prow()+1,0 say chr(9)+cTITULO+ "  583"
              @ prow()+1,0 say "Cfop"+chr(9)+"Cliente"+chr(9)+"Emissao"+chr(9)+"NF"+chr(9)+"Ref"+chr(9)+"Descricao"+chr(9)+"Qtde"+chr(9)+"Unit."+chr(9)+"Valor Total"
              @ prow()+1,0 say ""
           endif

           @ prow()+1,00      say asFAT[nCONT,8]
           CLI1->(dbseek(asFAT[nCONT,1]))
           @ prow()  ,pcol()  say chr(9)+left(CLI1->Razao,30)
           @ prow()  ,pcol()  say chr(9)+dtoc(asFAT[nCONT,3])
           @ prow()  ,pcol()  say chr(9)+asFAT[nCONT,4]
           PROD->(dbseek(asFAT[nCONT,2]))
           @ prow()  ,pcol()  say chr(9)+PROD->Cod_ass
           @ prow()  ,pcol()  say chr(9)+left(PROD->Descricao,19)
           @ prow()  ,pcol()  say chr(9)+transf(asFAT[nCONT,5],"@R 999999")
           @ prow()  ,pcol()  say chr(9)+transf(asFAT[nCONT,6],"@E 999,999.99")
           @ prow()  ,pcol()  say chr(9)+transf(asFAT[nCONT,7],"@E 999,999.99")

           nQty    += asFAT[nCONT,5]
           nTotQty += asFAT[nCONT,5]

           nVal    += asFAT[nCONT,7]
           nTotVal += asFAT[nCONT,7]


           nCONT++
           if nCONT > len(asFAT)
              nCONT := len(asFAT)
              exit
           endif

           if asFAT[nCONT,1] != cCLIENTE
              @ prow()+1,00     say chr(9)+"Total"
              @ prow()  ,pcol() say chr(9)+chr(9)+chr(9)+chr(9)+chr(9)+transf(nQty,"@R 999999")

              @ prow()  ,pcol() say chr(9)+ transf(nVal/nqty,"@E 999,999.99")
              @ prow()  ,pcol() say chr(9)+ transf(nVal,"@E 999,999.99")
              @ prow()+1,00 say ""

              nQty := 0
              nVal := 0
              cCLIENTE := asFat[nCONT,1]
           endif
       enddo

       if nVAL <> 0
          @ prow()+1,00     say chr(9)+"Total"
          @ prow()  ,pcol() say chr(9)+chr(9)+chr(9)+chr(9)+chr(9)+transf(nQty,"@R 999999")
          @ prow()  ,pcol() say chr(9)+ transf(nVal/nqty,"@E 999,999.99")
          @ prow()  ,pcol() say chr(9)+ transf(nVal,"@E 999,999.99")
          @ prow()+1,00 say ""

          nQty := 0
          nVal := 0
       endif

       if nTotVAL <> 0
          @ prow()+1,00     say chr(9)+"Total Geral"
          @ prow()  ,pcol() say chr(9)+chr(9)+chr(9)+chr(9)+chr(9)+transf(nTotQty,"@R 999999")
          @ prow()  ,pcol() say chr(9)+ transf(nTotVal/nTotqty,"@E 999,999.99")
          @ prow()  ,pcol() say chr(9)+ transf(nTotVal,"@E 999,999.99")
          @ prow()+1,00 say ""

          nQty := 0
          nVal := 0
          nTotQty := 0
          nTotVal := 0
       endif




   endif

   qstopprn(.f.)

return


