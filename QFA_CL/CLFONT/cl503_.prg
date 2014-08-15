/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO COMERCIO
// OBJETIVO...: RELATORIO DE PROGRAMACAO DE ENTREGA
// ANALISTA...: EDUARDO AUGUSTO BORIO
// PROGRAMADOR: EDUARDO AUGUSTO BORIO
// INICIO.....: SETEMBRO DE 2002
// OBS........:
// ALTERACOES.:

function cl503
#define K_MAX_LIN 60

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG) .or. lastkey()==27  }

private cTITULO                   // titulo do relatorio
private cSETOR := space(5)
private aEDICAO := {}             // vetor para os campos de entrada de dados
private dINI
private dFIM

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qgetx(-1,0,@dINI)            } , "INI"    })
aadd(aEDICAO,{{ || qgetx(-1,0,@dFIM)            } , "FIM"    })
aadd(aEDICAO,{{ || view_setor(-1,0,@cSETOR)     } , "SETOR"  })
aadd(aEDICAO,{{ || NIL                          } , NIL  })

do while .T.

   qlbloc(5,0,"B503A","QBLOC.GLO")
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


   cTITULO := "LISTAGEM DE PROGRAMACAO DE ENTREGAS" +" emitido em " + dtoc(date())

   qmensa("")

   // ESTABELECE RELACOES ENTRE ARQUIVOS ____________________________________

   ITEN_FAT->(dbsetorder(2))

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impressao
    local nQUANT     := 0
    local nQTDE_FAT  := 0
    local nTOT_FAT   := 0
    local nTOT_QUANT :=0
    local nTOTAL     := 0
    local nTOT_GER   := 0
    local nDESC    := 0
    local nTOT_DESC:= 0
    local nIPI     := 0
    local dVENC   := ctod("")
    local dFAT    := ctod("")

   nQTDE_FAT := 0
   nTOT_FAT  := 0
   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   FAT->(dbsetorder(2)) // data de emissao
   FAT->(dbgotop())
   set softseek on
   FAT->(dbseek(dtos(dINI)))
   set softseek off
   do while ! FAT->(eof()).and. FAT->Dt_emissao >= dINI .and. FAT->dt_emissao <= dFIM  // condicao principal de loop

      if FAT->Cancelado
         FAT->(dbskip())
         loop
      endif

      if empty(FAT->Num_fatura)
         FAT->(dbskip())
         loop
      endif

      if CONFIG->Modelo_2 == "1"
         if year(dINI) < 2003
            if FAT->Cod_natop != "511" .and. FAT->Cod_natop != "611"
               FAT->(dbskip())
               loop
            endif
         else
            if left(FAT->Cod_cfop,3) $ "510-511-512-610-611-612"
            //OK
            else
               FAT->(dbskip())
               loop
            endif
         endif
      endif
      ITEN_FAT->(Dbgotop())
      ITEN_FAT->(Dbseek(FAT->Codigo))

      do while ITEN_FAT->Num_fat == FAT->Codigo .and. ! ITEN_FAT->(eof())

          nQTDE_FAT += ITEN_FAT->Quantidade
          nTOT_FAT  += ITEN_FAT->Quantidade * ITEN_FAT->Vl_unitar
          ITEN_FAT->(Dbskip())

      enddo
      dFAT  := FAT->dt_saida
      FAT->(dbskip())

   enddo
   FAT->(dbgotop())
   if ! qinitprn() ; return ; endif

   FAT->(dbsetfilter({|| empty(FAT->Num_fatura).and.FAT->Entregar>=dINI.and.FAT->Entregar <= dFIM},'empty(FAT->Num_fatura).and.FAT->Entregar>=dINI.and.FAT->Entregar <= dFIM'))
   FAT->(dbsetorder(8)) // data de emissao
   FAT->(dbgotop())

   do while ! FAT->(eof())  // condicao principal de loop

      if FAT->Cancelado
         FAT->(dbskip())
         loop
      endif
      if CONFIG->Modelo_2 == "1"
         if year(dINI) < 2003
            if FAT->Cod_natop != "511" .and. FAT->Cod_natop != "611"
               FAT->(dbskip())
               loop
            endif
         else
            if left(FAT->Cod_cfop,3) $ "510-511-512-610-611-612"
            //OK
            else
               FAT->(dbskip())
               loop
            endif
         endif
      endif

      if ! qlineprn() ; exit ; endif

      if XPAGINA == 0 .or. prow() > K_MAX_LIN
         @prow()+1,0 say XCOND0
         qpageprn()
         qcabecprn(cTITULO,80)
         @ prow()+1,0 say XCOND1 + "No. Pedido  Emissao  Cliente                               Entregar     Quantidade  Produto                     Preco Unit       Total"
         @ prow()+1,0 say ""
      endif

      qgirabarra()

      qmensa("Aguarde... Processando ...")

         CLI1->(dbseek(FAT->Cod_cli))
         if !empty(cSETOR)
            if CLI1->Cod_setor != cSETOR
               FAT->(dbskip())
               loop
            endif
         endif

         dVENC := FAT->Entregar
         ITEN_FAT->(Dbgotop())
         ITEN_FAT->(Dbseek(FAT->Codigo))
         do while ITEN_FAT->Num_fat == FAT->Codigo .and. ! ITEN_FAT->(eof())

             PROD->(dbsetorder(4))
             PROD->(dbseek(ITEN_FAT->Cod_Prod))

             @ prow()  ,00  say XCOND1
             @ prow()+1,01  say FAT->Codigo
             @ prow() , 11  say dtoc(FAT->Dt_emissao)
             @ prow()  ,22  say left(CLI1->Razao,36)
             @ prow()  ,59  say dtoc(FAT->Entregar)
             @ prow()  ,75  say transf(ITEN_FAT->Quantidade,"@R 9999999")
             PROD->(dbsetorder(4))
             PROD->(dbseek(ITEN_FAT->Cod_Prod))

             @ prow()  ,83  say left(PROD->Descricao,25)
             @ prow()  ,110 say transf(ITEN_FAT->Vl_unitar,"@R 99,999.99")
             @ prow()  ,120 say transf(ITEN_FAT->Quantidade*ITEN_FAT->Vl_unitar,"@R 99,999,999.99")
             nQUANT += ITEN_FAT->Quantidade
             nTOTAL += ITEN_FAT->Quantidade * ITEN_FAT->Vl_unitar
             nTOT_GER += ITEN_FAT->Quantidade * ITEN_FAT->Vl_unitar
             nTOT_QUANT += ITEN_FAT->Quantidade
             ITEN_FAT->(Dbskip())

         enddo

      FAT->(dbskip())
      if FAT->Entregar <> dVENC
         dVENC:= FAT->Entregar

         @ prow()+1,00   say replicate("-",134)
         @ prow()+1,59   say "TOTAIS DO DIA.: "
         @ prow()  ,75   say transf(nQUANT,"@R 9999999")
         @ prow()  ,120  say transf(nTOTAL,"@R 99,999,999.99")
         nQUANT := 0
         nTOTAL := 0
         @ prow()+1,00   say " "

      endif
   enddo
   @ prow()+1,00   say replicate("-",134)
   @ prow()+1,59   say "TOTAL ..: "
   @ prow()  ,75   say transf(nTOT_QUANT,"@R 9999999")
   @ prow()  ,120  say transf(nTOT_GER,"@R 99,999,999.99")

   @ prow()+1,00   say replicate("-",134)
   @ prow()+1,59   say dtoc(dFAT)
   @ prow()  ,75   say transf(nQTDE_FAT,"@R 9999999")
   @ prow()  ,110 say transf(nTOT_FAT/nQTDE_FAT,"@R 99,999.99")

   @ prow()  ,120  say transf(nTOT_FAT,"@R 99,999,999.99")

   @ prow()+1,00   say replicate("-",134)
   @ prow()+1,59   say "GERAL...: "
   @ prow()  ,75   say transf(nQTDE_FAT+nTOT_QUANT,"@R 9999999")
   @ prow()  ,110 say transf((nTOT_FAT+nTOT_GER)/(nQTDE_FAT+nTOT_QUANT),"@R 99,999.99")
   @ prow()  ,120  say transf(nTOT_FAT+nTOT_GER,"@R 99,999,999.99")


   nTOT_QUANT := 0
   nTOT_GER   := 0
   nQUANT     := 0
   nTOTAL     := 0
   nQTDE_FAT  := 0
   nTOT_FAT   := 0

   qstopprn()

return
