/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO COMERCIO
// OBJETIVO...: Relatorio de comissao
// ANALISTA...: EDUARDO AUGUSTO BORIO
// PROGRAMADOR: EDUARDO AUGUSTO BORIO
// INICIO.....: ABRIL DE 2003
// OBS........:
// ALTERACOES.:

function cl539
#define K_MAX_LIN 57

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG) .or. empty(dINI) }

private cTITULO                   // titulo do relatorio
private dINI
private dFIM
private cSETOR := space(5)
private cVEND   := space(5)
private aEDICAO := {}             // vetor para os campos de entrada de dados

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qgetx(-1,0,@dINI)            } , "INI"    })
aadd(aEDICAO,{{ || qgetx(-1,0,@dFIM)            } , "FIM"    })
aadd(aEDICAO,{{ || view_vend(-1,0,@cVEND   )    } , "VEND"   })
aadd(aEDICAO,{{ || NIL                          } , NIL      })

do while .T.

   qlbloc(5,0,"B539A","QBLOC.GLO")
   XNIVEL := 1
   XFLAG  := .T.
   dINI := dFIM := ctod("")
   cVEND := space(5)
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
              qrsay(XNIVEL++, "Todos os Vendedores.......")
           else
              if ! VEND->(Dbseek(cVEND))
                 qmensa("Vendedor n„o encontrado","B")
                 return .F.
              else
                 qrsay(XNIVEL++,left(VEND->Nome,30))
              endif
           endif

   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // CRIA TITULO DO RELATORIO ______________________________________________


   cTITULO := "RELATORIO GERAL DE COMISSAO" + " de " + dtoc(dINI) + " a " + dtoc(dFIM)

   qmensa("")

   // ESTABELECE RELACOES ENTRE ARQUIVOS ____________________________________

   PROD->(dbsetorder(4))

   FAT->(dbsetorder(2)) // data de saida
   FAT->(dbgotop())
   set softseek on
   FAT->(Dbseek(dtos(dINI)))
   set softseek off
   ITEN_FAT->(dbsetorder(2))
return .T.


static function i_impressao

   qinitPrn()

   if XLOCALIMP == "X"
      i_impre_xls()
   else
      i_impre_prn()
   endif


return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impre_prn
    local aFAT       := {}
    local aVEND      := {}
    local asFAT      := {}
    local lTEM := .T.
    local nQTY_PROD := 0
    local nVLR_PROD := 0
    local nVLR_CLI  := 0
    local nVLR_VEND := 0
    local nCOM_CLI  := 0
    local nCOM_VEND := 0
    local nVLR_TOT  := 0
    local nCOM_TOT  := 0

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________
   lTEM := .F.

   do while ! FAT->(eof()) .and. FAT->Dt_emissao >= dINI .and. FAT->Dt_emissao <= dFIM  // condicao principal de loop

      if FAT->Cancelado
         FAT->(dbskip())
         loop
      endif

      if empty(FAT->Num_fatura).and. FAT->Es == "S"
         FAT->(dbskip())
         loop
      endif

      CLI1->(dbseek(FAT->Cod_cli))

      if ! empty(cVEND)
         if FAT->Cod_vended != cVEND
            FAT->(dbskip())
            loop
         endif
      endif

      if ! left(FAT->Cod_cfop,3) $ "540-604-510-511-512-610-611-612-120-220"
         FAT->(dbskip())
         loop
      endif

     qgirabarra()

     qmensa("Aguarde... Processando ...")

      ITEN_FAT->(Dbgotop())
      ITEN_FAT->(Dbseek(FAT->Codigo))
      do while ITEN_FAT->Num_fat == FAT->Codigo .and. ! ITEN_FAT->(eof())

         aadd(aFAT,{FAT->cod_vended,FAT->Cod_cli,ITEN_FAT->Cod_prod,ITEN_FAT->Quantidade,ITEN_FAT->Vl_unitar,ITEN_FAT->Comissao})
         lTEM := .T.
         ITEN_FAT->(Dbskip())
      enddo
      FAT->(dbskip())

   enddo
   //classifica a matriz por vendedor + data vencimento
   asFAT := asort(aFAT,,,{|x,y| x[1] + x[2] + x[3] < y[1] + y[2] + y[3] })
   if lTEM
       zVEND  := asFAT[1,1]
       zCLI   := asFAT[1,2]
       zPROD  := asFAT[1,3]
       nCONT := 1

       do while  nCONT <= len(asFAT)

           if mod(nCONT,75) == 0
              if ! qlineprn() ; exit ; endif
           endif

           if XPAGINA == 0 .or. prow() > K_MAX_LIN
              @prow()+1,0 say XCOND1
              qpageprn()
              qcabecprn(cTITULO,136)
              @ prow()+1,0 say "Produto                                         Quantidade            Vlr. Medio                    Total      Comissao"
              @ prow()+1,0 say replicate("-",136)
           endif

           nQTY_PROD  += asFAT[nCONT,4]
           nVLR_PROD  += asFAT[nCONT,4] * asFAT[nCONT,5]
           nVLR_CLI   += asFAT[nCONT,4] * asFAT[nCONT,5]
           nVLR_VEND  += asFAT[nCONT,4] * asFAT[nCONT,5]
           nCOM_CLI   += ( (asFAT[nCONT,4] * asFAT[nCONT,5]) * (asFAT[nCONT,6] /100) )
           nCOM_VEND  += ( (asFAT[nCONT,4] * asFAT[nCONT,5]) * (asFAT[nCONT,6] /100) )
           nVLR_TOT   += asFAT[nCONT,4] * asFAT[nCONT,5]
           nCOM_TOT   += ( (asFAT[nCONT,4] * asFAT[nCONT,5]) * (asFAT[nCONT,6] /100) )

           nCONT++
           if nCONT > len(asFAT)
              nCONT := len(asFAT)
              exit
           endif

           if asFAT[nCONT,1] + asFAT[nCONT,2]+asFAT[nCONT,3] != zVEND+zCLI+zPROD
               PROD->(dbseek(zPROD))
               @ prow()+1  ,00  say zPROD+" "+left(PROD->Descricao,35)
               @ prow()    ,50  say transform(nQTY_PROD,"@R 99999999")
               @ prow()    ,70  say transform(round(nVLR_PROD/nQTY_PROD,2),"@E 999,999.99")
               @ prow()    ,93  say transform(nVLR_PROD,"@E 9,999,999.99")
               nQTY_PROD := 0
               nVLR_PROD := 0
               zPROD := asFAT[nCONT,3]
           endif

           if asFAT[nCONT,1]+asFAT[nCONT,2] != zVEND+zCLI
              CLI1->(dbseek(zCLI))
              @ prow()+1  ,00  say "TOTAL DO CLIENTE....: "+left(CLI1->Razao,30)
              @ prow()    ,93  say transform(nVLR_CLI,"@E 9,999,999.99")
              @ prow()    ,110 say transform(nCOM_CLI,"@E 99,999.99")

              @ prow()+1,00 say replicate("-",136)
              @ prow()+1,00 say ""
              nVLR_CLI := 0
              nCOM_CLI := 0
              zCLI := asFAT[nCONT,2]
           endif


           if alltrim(asFAT[nCONT,1]) != alltrim(zVEND)
              VEND->(dbseek(zVEND))
              @ prow()+1  ,00  say "TOTAL DO VENDEDOR....: "+left(VEND->Nome,30)
              @ prow()    ,93  say transform(nVLR_VEND,"@E 9,999,999.99")
              @ prow()    ,110 say transform(nCOM_VEND,"@E 99,999.99")

              aadd(aVend,{zVEND,nVLR_VEND,nCOM_VEND})

              @ prow()+1,00 say replicate("-",136)
              @ prow()+1,00 say ""
              nVLR_VEND := 0
              nCOM_VEND  := 0
              zVEND := asFAT[nCONT,1]
           endif


       enddo

       if nVLR_PROD > 0
          PROD->(dbseek(zPROD))
          @ prow()+1  ,00  say zPROD+" "+left(PROD->Descricao,35)
          @ prow()    ,50  say transform(nQTY_PROD,"@R 99999999")
          @ prow()    ,70  say transform(round(nVLR_PROD/nQTY_PROD,2),"@E 999,999.99")
          @ prow()    ,93  say transform(nVLR_PROD,"@E 9,999,999.99")
          nQTY_PROD := 0
          nVLR_PROD := 0
       endif


       if nVLR_CLI > 0
          CLI1->(dbseek(zCLI))
          @ prow()+1  ,00  say "TOTAL DO CLIENTE....: "+left(CLI1->Razao,30)
          @ prow()    ,93  say transform(nVLR_CLI,"@E 9,999,999.99")
          @ prow()    ,110 say transform(nCOM_CLI,"@E 999,999.99")
          @ prow()+1,00 say replicate("-",136)
          @ prow()+1,00 say ""
          nVLR_CLI := 0
          nCOM_CLI := 0
       endif

       if nVLR_VEND > 0
          VEND->(dbseek(zVEND))
          @ prow()+2  ,00  say "TOTAIS DO VENDEDOR....: "+left(VEND->Nome,30)
          @ prow()    ,93  say transform(nVLR_VEND,"@E 99,999,999.99")
          @ prow()    ,110 say transform(nCOM_VEND,"@E 999,999.99")

          aadd(aVend,{zVEND,nVLR_VEND,nCOM_VEND})

          @ prow()+1,00 say replicate("-",136)
          nVLR_VEND := 0
          nCOM_VEND := 0
       endif

       @ prow()+1,00 say ""

   endif

   eject

   aVEND := asort(aVEND,,,{|x,y| x[2] > y[2] })

   nCONT := 1

   XPAGINA := 0


   do while  nCONT <= len(aVEND)

      if ! qlineprn() ; exit ; endif
      if XPAGINA == 0 .or. prow() > K_MAX_LIN
         qpageprn()
         @ prow()+1,0   say qcabecPrn("Resumo de Vebdedores",132)
         @ prow()+1,0   say "Vendedor"
         @ prow()  ,50  say " Valor Total"
         @ prow()  ,70  say " Comissao"
         @ prow()+1,0 say ""
      endif

      VEND->(dbseek(aVEND[nCONT,1]))
      @ prow()+1,00 say left(VEND->Nome,40)
      @ prow()  ,50 say transform(aVEND[nCONT,2],"@E 9,999,999.99")
      @ prow()  ,70 say transform(aVEND[nCONT,3],"@E 99,999.99")

      nCONT++

      if nCONT > len(aVEND)
         nCONT := len(aVEND)
         exit
      endif

   enddo



   if XLOCALIMP == "S"
      @ prow()+1,00 say "[GRAFICO]"
      nCONT := 1

      do while  nCONT <= len(aVEND)

         if ! qlineprn() ; exit ; endif

         VEND->(dbseek(aVEND[nCONT,1]))
         @ prow()+1,00 say left(VEND->Nome,40)
         @ prow()  ,50 say strzero(val(qtiraponto(str(aVEND[nCONT,2],14,2))),14)

         nCONT++

         if nCONT > len(aVEND)
            nCONT := len(aVEND)
            exit
         endif

      enddo

      aVend := {}

   endif

   qstopprn(.f.)

return

static function i_impre_xls
    local aFAT       := {}
    local aVEND      := {}
    local asFAT      := {}
    local lTEM := .T.
    local nQTY_PROD := 0
    local nVLR_PROD := 0
    local nVLR_CLI  := 0
    local nVLR_VEND := 0
    local nCOM_CLI  := 0
    local nCOM_VEND := 0
    local nVLR_TOT  := 0
    local nCOM_TOT  := 0

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________
    lTEM := .F.

   do while ! FAT->(eof()) .and. FAT->Dt_emissao >= dINI .and. FAT->Dt_emissao <= dFIM  // condicao principal de loop

      if FAT->Cancelado
         FAT->(dbskip())
         loop
      endif

      if empty(FAT->Num_fatura).and. FAT->Es == "S"
         FAT->(dbskip())
         loop
      endif

      CLI1->(dbseek(FAT->Cod_cli))

      if ! empty(cVEND)
         if FAT->Cod_vended != cVEND
            FAT->(dbskip())
            loop
         endif
      endif


      if ! left(FAT->Cod_cfop,3) $ "540-604-510-511-512-610-611-612-120-220"
         FAT->(dbskip())
         loop
      endif

     qgirabarra()

     qmensa("Aguarde... Processando ...")

      ITEN_FAT->(Dbgotop())
      ITEN_FAT->(Dbseek(FAT->Codigo))
      do while ITEN_FAT->Num_fat == FAT->Codigo .and. ! ITEN_FAT->(eof())

         aadd(aFAT,{FAT->cod_vended,FAT->Cod_cli,ITEN_FAT->Cod_prod,ITEN_FAT->Quantidade,ITEN_FAT->Vl_unitar,ITEN_FAT->Comissao})
         lTEM := .T.
         ITEN_FAT->(Dbskip())
      enddo
      FAT->(dbskip())

   enddo
   //classifica a matriz por vendedor + data vencimento
   asFAT := asort(aFAT,,,{|x,y| x[1] + x[2] + x[3] < y[1] + y[2] + y[3] })
   if lTEM
       zVEND  := asFAT[1,1]
       zCLI   := asFAT[1,2]
       zPROD  := asFAT[1,3]
       nCONT := 1

       do while  nCONT <= len(asFAT)

           if mod(nCONT,75) == 0
              if ! qlineprn() ; exit ; endif
           endif

           if XPAGINA == 0 //.or. prow() > K_MAX_LIN
              @prow()+1,0 say ""
              qpageprn()
              @ prow()+1,0 say chr(9)+cTITULO+" 539"
              @ prow()+1,0 say "Cod."+chr(9)+"Produto"+chr(9)+"Quantidade"+chr(9)+"Vlr. Medio"+chr(9)+"Total"+chr(9)+"Comissao"
              @ prow()+1,00 say replicate(chr(196),136)

           endif

           nQTY_PROD  += asFAT[nCONT,4]
           nVLR_PROD  += asFAT[nCONT,4] * asFAT[nCONT,5]
           nVLR_CLI   += asFAT[nCONT,4] * asFAT[nCONT,5]
           nVLR_VEND  += asFAT[nCONT,4] * asFAT[nCONT,5]
           nCOM_CLI   += ( (asFAT[nCONT,4] * asFAT[nCONT,5]) * (asFAT[nCONT,6] /100) )
           nCOM_VEND  += ( (asFAT[nCONT,4] * asFAT[nCONT,5]) * (asFAT[nCONT,6] /100) )
           nVLR_TOT   += asFAT[nCONT,4] * asFAT[nCONT,5]
           nCOM_TOT   += ( (asFAT[nCONT,4] * asFAT[nCONT,5]) * (asFAT[nCONT,6] /100) )

           nCONT++
           if nCONT > len(asFAT)
              nCONT := len(asFAT)
              exit
           endif

           if asFAT[nCONT,1] + asFAT[nCONT,2]+asFAT[nCONT,3] != zVEND+zCLI+zPROD
               PROD->(dbseek(zPROD))
               @ prow()+1  ,00  say zPROD+chr(9)+left(PROD->Descricao,35)
               @ prow()    ,pcol()  say chr(9)+transform(nQTY_PROD,"@R 99999999")
               @ prow()    ,pcol()  say chr(9)+transform(round(nVLR_PROD/nQTY_PROD,2),"@E 999,999.99")
               @ prow()    ,pcol()  say chr(9)+transform(nVLR_PROD,"@E 9,999,999.99")
               nQTY_PROD := 0
               nVLR_PROD := 0
               zPROD := asFAT[nCONT,3]
           endif

           if asFAT[nCONT,1]+asFAT[nCONT,2] != zVEND+zCLI
              CLI1->(dbseek(zCLI))
              @ prow()+1  ,00  say chr(9)+"TOTAL DO CLIENTE....: "+left(CLI1->Razao,30)
              @ prow()    ,pcol()  say chr(9)+chr(9)+chr(9)+transform(nVLR_CLI,"@E 9,999,999.99")
              @ prow()    ,pcol()  say chr(9)+transform(nCOM_CLI,"@E 99,999.99")

              @ prow()+1,00 say replicate(chr(196),136)

              @ prow()+1,00 say ""
              nVLR_CLI := 0
              nCOM_CLI := 0
              zCLI := asFAT[nCONT,2]
           endif


           if alltrim(asFAT[nCONT,1]) != alltrim(zVEND)
              VEND->(dbseek(zVEND))
              @ prow()+1  ,00  say chr(9)+"TOTAL DO VENDEDOR....: "+left(VEND->Nome,30)
              @ prow()    ,pcol()  say chr(9)+chr(9)+chr(9)+transform(nVLR_VEND,"@E 9,999,999.99")
              @ prow()    ,pcol()  say chr(9)+transform(nCOM_VEND,"@E 99,999.99")

              aadd(aVend,{zVEND,nVLR_VEND,nCOM_VEND})
              @ prow()+1,00 say replicate(chr(196),136)

              @ prow()+1,00 say ""
              nVLR_VEND := 0
              nCOM_VEND  := 0
              zVEND := asFAT[nCONT,1]
           endif


       enddo

       if nVLR_PROD > 0
          PROD->(dbseek(zPROD))
          @ prow()+1  ,00  say zPROD+chr(9)+left(PROD->Descricao,35)
          @ prow()    ,pcol()  say chr(9)+transform(nQTY_PROD,"@R 99999999")
          @ prow()    ,pcol()  say chr(9)+transform(round(nVLR_PROD/nQTY_PROD,2),"@E 999,999.99")
          @ prow()    ,pcol()  say chr(9)+transform(nVLR_PROD,"@E 9,999,999.99")

          nQTY_PROD := 0
          nVLR_PROD := 0
       endif


       if nVLR_CLI > 0
          CLI1->(dbseek(zCLI))
          @ prow()+1  ,00  say chr(9)+"TOTAL DO CLIENTE....: "+left(CLI1->Razao,30)
          @ prow()    ,pcol()  say chr(9)+chr(9)+chr(9)+transform(nVLR_CLI,"@E 9,999,999.99")
          @ prow()    ,pcol()  say chr(9)+transform(nCOM_CLI,"@E 99,999.99")

         @ prow()+1,00 say replicate(chr(196),136)

          @ prow()+1,00 say ""
          nVLR_CLI := 0
          nCOM_CLI := 0
       endif

       if nVLR_VEND > 0
          VEND->(dbseek(zVEND))
          @ prow()+1  ,00  say chr(9)+"TOTAL DO VENDEDOR....: "+left(VEND->Nome,30)
          @ prow()    ,pcol()  say chr(9)+chr(9)+chr(9)+transform(nVLR_VEND,"@E 9,999,999.99")
          @ prow()    ,pcol()  say chr(9)+transform(nCOM_VEND,"@E 99,999.99")

          aadd(aVend,{zVEND,nVLR_VEND,nCOM_VEND})

         @ prow()+1,00 say replicate(chr(196),136)

          nVLR_VEND := 0
          nCOM_VEND := 0
       endif

       @ prow()+1,00 say ""

   endif

   eject

   aVEND := asort(aVEND,,,{|x,y| x[2] > y[2] })

   nCONT := 1

   XPAGINA := 0


   do while  nCONT <= len(aVEND)

      if ! qlineprn() ; exit ; endif
      if XPAGINA == 0 //.or. prow() > K_MAX_LIN
         qpageprn()
         @ prow()+1,0       say chr(9)+"Resumo de Vebdedores"
         @ prow()+1,0       say chr(9)+"Vendedor"
         @ prow()  ,pcol()  say chr(9)+chr(9)+chr(9)+"Valor Total"
         @ prow()  ,pcol()  say chr(9)+"Comissao"
         @ prow()+1,00 say replicate(chr(196),136)
      endif

      VEND->(dbseek(aVEND[nCONT,1]))
      @ prow()+1,00     say chr(9)+left(VEND->Nome,40)
      @ prow()  ,pcol() say chr(9)+chr(9)+chr(9)+transform(aVEND[nCONT,2],"@E 9,999,999.99")
      @ prow()  ,pcol() say chr(9)+transform(aVEND[nCONT,3],"@E 99,999.99")

      nCONT++

      if nCONT > len(aVEND)
         nCONT := len(aVEND)
         exit
      endif

   enddo

   aVEND := {}

   qstopprn(.f.)

return

