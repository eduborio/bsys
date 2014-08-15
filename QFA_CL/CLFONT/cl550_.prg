/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO COMERCIO
// OBJETIVO...: LISTAGEM DE PRODUTOS FATURADOS POR REPRESENTANTE/COLECAO
// ANALISTA...: EDUARDO AUGUSTO BORIO
// PROGRAMADOR: EDUARDO AUGUSTO BORIO
// INICIO.....: FEVEREIRO DE 2006
// OBS........:
// ALTERACOES.:

function cl550
#define K_MAX_LIN 57

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG) .or. empty(dINI) }

private cTITULO                   // titulo do relatorio
private dINI
private dFIM
private cREPRES := space(5)
private cRAZAO := space(40)
private aEDICAO := {}             // vetor para os campos de entrada de dados

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qgetx(-1,0,@dINI)            } , "INI"    })
aadd(aEDICAO,{{ || qgetx(-1,0,@dFIM)            } , "FIM"    })

do while .T.

   qlbloc(5,0,"B544A","QBLOC.GLO")
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


   cTITULO := "Relacao de Classif. Fiscais" +" de " + dtoc(dINI) + " a " + dtoc(dFIM)

   qmensa("")

   // ESTABELECE RELACOES ENTRE ARQUIVOS ____________________________________

   FAT->(dbsetorder(2)) // data de emissao
   FAT->(dbgotop())
   set softseek on
   FAT->(Dbseek(dtos(dINI)))
   set softseek off
   ITEN_FAT->(dbsetorder(2))
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
    local cCLI       := space(5)
    local cDESCCLI   := space(50)
    local cCLASS     := space(2)
    local cDESCCLASS := space(20)
    local nVAL_CLASS := 0
    local nTOT_CLI   := 0

    local nTOTAL     := 0
    local nVALOR     := 0
    local aFAT       := {}
    local asFAT      := {}
    local lTEM := .T.
    local zPROD := space(50)
   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________
    lTEM := .F.
   //if ! qinitprn() ; return ; endif

   do while ! FAT->(eof())  .and. FAT->Dt_emissao >= dINI .and. FAT->Dt_emissao <= dFIM  // condicao principal de loop

      if FAT->Cancelado
         FAT->(dbskip())
         loop
      endif

      if empty(FAT->Num_fatura).and. FAT->Es == "S"
         FAT->(dbskip())
         loop
      endif

      qmensa("Aguarde... Processando ...")

         CLI1->(dbseek(FAT->Cod_cli))

         ITEN_FAT->(Dbgotop())
         ITEN_FAT->(Dbseek(FAT->Codigo))
         do while ITEN_FAT->Num_fat == FAT->Codigo .and. ! ITEN_FAT->(eof())
             PROD->(dbsetorder(4))
             PROD->(dbseek(ITEN_FAT->Cod_Prod))
             nVALOR := nVALOR + ( (ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade) + ( (ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade)*(ITEN_FAT->Ipi/100) ) )
             aadd(aFAT,{CLI1->Codigo,PROD->Cod_class,nVALOR,FAT->Es})
             ITEN_FAT->(Dbskip())
             nVALOR := 0
             lTEM := .T.
         enddo
         FAT->(dbskip())
         nVALOR := 0
         nDESC := 0
   enddo
   //classifica a matriz por descricao do produto
   asFAT := asort(aFAT,,,{|x,y| x[1] + x[2] < y[1] + y[2]  })
   if lTEM
       cCLI   := asFAT[1,1]
       cCLASS := asFAT[1,2]

       cCLICLASS := asFAT[1,1]+asFAT[1,2]
       CLI1->(dbseek(asFAT[1,1]))
       CLASSIF->(dbseek(asFAT[1,2]))

       cDESCCLI := left(CLI1->Razao,50) + " "+fu_conv_cgccpf(CLI1->Cgccpf)
       cDESCCLASS := CLASSIF->Descricao


       nCONT := 1
       do while  nCONT <= len(asFAT)

           if ! qlineprn() ; exit ; endif
           if XPAGINA == 0 .or. prow() > K_MAX_LIN
              @prow()+1,0 say XCOND0
              qpageprn()
              qcabecprn(cTITULO,80)
           endif

           if asFAT[nCONT,4] == "S"  // Se for Saida soma as quantidade senao diminui
              nVAL_CLASS += asFAT[nCONT,3]
              nTOT_CLI += asFAT[nCONT,3]
           endif

           nCONT++
           if nCONT > len(asFAT)
              nCONT := len(asFAT)
              exit
           endif

           if asFAT[nCONT,1]+asFAT[nCONT,2] != cCLICLASS
              @ prow()+1,00 say cDESCCLASS
              @ prow()  ,90 say transf(nVAL_CLASS,"@E 9,999,999.99")
              cCLICLASS := asFAT[nCONT,1]+asFAT[nCONT,2]

              cCLASS := asFAT[nCONT,2]
              CLASSIF->(Dbseek(asFAT[nCONT,2]))
              cDESCCLASS := CLASSIF->Descricao
              nVAL_CLASS := 0
           endif

           if asFAT[nCONT,1] != cCLI
              @ prow()+1,00 say "Total do Cliente.: "+ cDESCCLI
              @ prow()  ,90 say transf(nTOT_CLI,"@E 9,999,999.99")

              cCLI := asFAT[nCONT,1]
              CLI1->(Dbseek(asFAT[nCONT,1]))
              cDESCCLI := CLI1->Razao
              cDESCCLI := left(CLI1->Razao,50) + "  "+fu_conv_cgccpf(CLI1->Cgccpf)
              @ prow()+1,0 say ""

              nTOT_CLI := 0
              nVAL_CLASS := 0
            endif

       enddo

       if asFAT[nCONT,1]+asFAT[nCONT,2] != cCLICLASS
          @ prow()+1,00 say cDESCCLASS
          @ prow()  ,90 say transf(nVAL_CLASS,"@E 9,999,999.99")
          cCLICLASS := asFAT[nCONT,1]+asFAT[nCONT,2]

          cCLASS := asFAT[nCONT,2]
          CLASSIF->(Dbseek(asFAT[nCONT,2]))
          cDESCCLASS := CLASSIF->Descricao
          nVAL_CLASS := 0
       endif

       if asFAT[nCONT,1] != cCLI
          @ prow()+1,00 say "Total do Cliente.: "+ cDESCCLI
          @ prow()  ,90 say transf(nTOT_CLI,"@E 9,999,999.99")

          cCLI := asFAT[nCONT,1]
          CLI1->(Dbseek(asFAT[nCONT,1]))
          cDESCCLI := CLI1->Razao
          cDESCCLI := left(CLI1->Razao,50) + "  "+fu_conv_cgccpf(CLI1->Cgccpf)
          @ prow()+1,0 say ""

          nTOT_CLI := 0
        endif



       nVAl_CLASS := 0
       nTOTAL := 0
       nPERC  := 0
       nTOT_CLI := 0
   endif

   qstopprn()

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO EM EXCEL__________________

static function i_impre_xls
    local cCLI       := space(5)
    local cDESCCLI   := space(50)
    local cCLASS     := space(2)
    local cDESCCLASS := space(20)
    local nVAL_CLASS := 0
    local nTOT_CLI   := 0

    local nTOTAL     := 0
    local nVALOR     := 0
    local aFAT       := {}
    local asFAT      := {}
    local lTEM := .T.
    local zPROD := space(50)
   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________
    lTEM := .F.
   //if ! qinitprn() ; return ; endif

   do while ! FAT->(eof())  .and. FAT->Dt_emissao >= dINI .and. FAT->Dt_emissao <= dFIM  // condicao principal de loop

      if FAT->Cancelado
         FAT->(dbskip())
         loop
      endif

      if empty(FAT->Num_fatura).and. FAT->Es == "S"
         FAT->(dbskip())
         loop
      endif

      qmensa("Aguarde... Processando ...")

         CLI1->(dbseek(FAT->Cod_cli))

         ITEN_FAT->(Dbgotop())
         ITEN_FAT->(Dbseek(FAT->Codigo))
         do while ITEN_FAT->Num_fat == FAT->Codigo .and. ! ITEN_FAT->(eof())
             PROD->(dbsetorder(4))
             PROD->(dbseek(ITEN_FAT->Cod_Prod))
             nVALOR := nVALOR + ( (ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade) + ( (ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade)*(ITEN_FAT->Ipi/100) ) )
             aadd(aFAT,{CLI1->Codigo,PROD->Cod_class,nVALOR,FAT->Es})
             ITEN_FAT->(Dbskip())
             nVALOR := 0
             lTEM := .T.
         enddo
         FAT->(dbskip())
         nVALOR := 0
         nDESC := 0
   enddo
   //classifica a matriz por descricao do produto
   asFAT := asort(aFAT,,,{|x,y| x[1] + x[2] < y[1] + y[2]  })
   if lTEM
       cCLI   := asFAT[1,1]
       cCLASS := asFAT[1,2]

       cCLICLASS := asFAT[1,1]+asFAT[1,2]
       CLI1->(dbseek(asFAT[1,1]))
       CLASSIF->(dbseek(asFAT[1,2]))

       cDESCCLI := left(CLI1->Razao,50) +chr(9)+fu_conv_cgccpf(CLI1->Cgccpf)
       cDESCCLASS := CLASSIF->Descricao


       nCONT := 1
       do while  nCONT <= len(asFAT)

           if ! qlineprn() ; exit ; endif
           if XPAGINA == 0
              @prow()+1,0 say cTITULO
              qpageprn()
           endif

           if asFAT[nCONT,4] == "S"  // Se for Saida soma as quantidade senao diminui
              nVAL_CLASS += asFAT[nCONT,3]
              nTOT_CLI += asFAT[nCONT,3]
           endif

           nCONT++
           if nCONT > len(asFAT)
              nCONT := len(asFAT)
              exit
           endif

           if asFAT[nCONT,1]+asFAT[nCONT,2] != cCLICLASS
              @ prow()+1,00 say cDESCCLASS+chr(9)+chr(9)
              @ prow()  ,pcol() say transf(nVAL_CLASS,"@E 9,999,999.99")
              cCLICLASS := asFAT[nCONT,1]+asFAT[nCONT,2]

              cCLASS := asFAT[nCONT,2]
              CLASSIF->(Dbseek(asFAT[nCONT,2]))
              cDESCCLASS := CLASSIF->Descricao
              nVAL_CLASS := 0
           endif

           if asFAT[nCONT,1] != cCLI
              @ prow()+1,00 say "Total do Cliente.: "+ cDESCCLI+chr(9)
              @ prow()  ,pcol() say transf(nTOT_CLI,"@E 9,999,999.99")

              cCLI := asFAT[nCONT,1]
              CLI1->(Dbseek(asFAT[nCONT,1]))
              cDESCCLI := CLI1->Razao
              cDESCCLI := left(CLI1->Razao,50) + chr(9)+fu_conv_cgccpf(CLI1->Cgccpf)
              @ prow()+1,0 say ""

              nTOT_CLI := 0
              nVAL_CLASS := 0
            endif

       enddo

       if asFAT[nCONT,1]+asFAT[nCONT,2] != cCLICLASS
          @ prow()+1,00 say cDESCCLASS+chr(9)+chr(9)
          @ prow()  ,pcol() say transf(nVAL_CLASS,"@E 9,999,999.99")
          cCLICLASS := asFAT[nCONT,1]+asFAT[nCONT,2]

          cCLASS := asFAT[nCONT,2]
          CLASSIF->(Dbseek(asFAT[nCONT,2]))
          cDESCCLASS := CLASSIF->Descricao
          nVAL_CLASS := 0
       endif

       if asFAT[nCONT,1] != cCLI
          @ prow()+1,00 say "Total do Cliente.: "+ cDESCCLI+chr(9)
          @ prow()  ,pcol() say transf(nTOT_CLI,"@E 9,999,999.99")

          cCLI := asFAT[nCONT,1]
          CLI1->(Dbseek(asFAT[nCONT,1]))
          cDESCCLI := CLI1->Razao
          cDESCCLI := left(CLI1->Razao,50) + chr(9)+fu_conv_cgccpf(CLI1->Cgccpf)
          @ prow()+1,0 say ""

          nTOT_CLI := 0
        endif



       nVAl_CLASS := 0
       nTOTAL := 0
       nPERC  := 0
       nTOT_CLI := 0
   endif

   qstopprn()


return
