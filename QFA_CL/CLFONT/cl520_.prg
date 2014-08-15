/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO COMERCIAL
// OBJETIVO...: RELATORIO DE HISTORICO DO CLIENTE
// ANALISTA...:
// PROGRAMADOR: EDUARDO AUGUSTO BORIO
// INICIO.....: FEVEREIRO DE 2000
// OBS........:

function cl520
#define K_MAX_LIN  60

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG .or. lastkey()==27)}

local  cCONT := 1

private cTITULO          // titulo do relatorio
private dINI
private dFIM
private nPRAZO   := 0
private nCHEQ_DIA:= 0
private nDESP    := 0
private nCHEQ_PRE:= 0
private nOUT     := 0
private nDIN     := 0
private nDESC    := 0
private nTOT_GER  := 0

private aEDICAO     := {}    // vetor para os campos de entrada de dados

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qgetx(-1,0,@dINI)                    },"INI"    })
aadd(aEDICAO,{{ || qgetx(-1,0,@dFIM)                    },"FIM"    })
aadd(aEDICAO,{{ || qgetx(-1,0,@nPRAZO  ,"@E 999,999.99")},"PRAZO"  })
aadd(aEDICAO,{{ || qgetx(-1,0,@nDESP   ,"@E 999,999.99")},"DESP"})
aadd(aEDICAO,{{ || qgetx(-1,0,@nCHEQ_DIA,"@E 999,999.99")},"CHEQ_DIA"})
aadd(aEDICAO,{{ || qgetx(-1,0,@nCHEQ_PRE,"@E 999,999.99")},"CHEQ_PRE"})
aadd(aEDICAO,{{ || qgetx(-1,0,@nOUT     ,"@E 999,999.99")},"OUT"   })

do while .T.

   qlbloc(05,0,"B520A","QBLOC.GLO",1)
   XNIVEL := 1
   XFLAG  := .T.
   dINI   :=  dFIM := ctod("")
   // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; dbcloseall() ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ); loop   ; endif
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
     cTITULO := "RESUMO DE CARGAS DIARIO "+ " de " + dtoc(dINI)+ " a "  + dtoc(dFIM)
     FAT->(dbsetorder(2)) // data de emissao
     FAT->(Dbsetfilter({|| FAT->Dt_emissao >= dINI .and. FAT->Dt_emissao <= dFIM},'FAT->Dt_emissao >= dINI .and. FAT->Dt_emissao <= dFIM' ))
     FAT->(dbgotop())


     ITEN_FAT->(dbsetorder(2))
     ITEN_FAT->(dbgotop())


return .T.





//////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IMPRIMIR OS PEDIDOS ___________________________________________

function i_impressao

   local nTOT_QUANT := nTOTAL := nPRECO:=zPRECO := nLIN := nTOT_BRU := nPROD := nICMS_SUBS := nDEVOL := 0
   local cCOD_PROD := space(5)

   lTEM := .F.

   PROD->(Dbsetorder(4))
   PROD->(Dbgotop())

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________
   if ! qinitprn() ; return ; endif

   if ! qlineprn() ; return ; endif


   do while ! PROD->(eof())

       if XPAGINA == 0 .or. prow() > K_MAX_LIN
          qpageprn()
          @ prow(),pcol() say XCOND0
          qcabecprn(cTITULO,80)
          @ prow()+1,00 say XCOND1 + "Codigo  Descricao                                                 Unidade       Quantidade               Valor"+XCOND0
          @ prow()+1,00 say replicate("-",80)
       endif
       @ prow(),pcol() say XCOND1

       cCOD_PROD := right(PROD->Codigo,5)
       FAT->(dbgotop())
       ITEN_FAT->(dbgotop())

       do while ! FAT->(eof())

            ITEN_FAT->(Dbseek(FAT->Codigo))

            do while ! ITEN_FAT->(eof()) .and. ITEN_FAT->Num_fat == FAT->Codigo

               if ITEN_FAT->Cod_prod == cCOD_PROD
                  nTOT_QUANT += ITEN_FAT->Quantidade
                  nPRECO += (ITEN_FAT->Quantidade * ITEN_FAT->Vl_Unitar)
                  zPRECO += (ITEN_FAT->Quantidade * ITEN_FAT->Vl_Unitar)
                  nTOTAL += nPRECO
                  if ITEN_FAT->devolucao == "1"
                     nDEVOL += nPRECO
                  endif
                  lTEM := .T.
               endif
               ITEN_FAT->(Dbskip())

            enddo
            nPRECO := 0

            FAT->(dbskip())

      enddo

      if lTEM
        @ prow()+1,00 say right(PROD->Codigo,5)
        @ prow()  ,08 say PROD->Descricao
        UNIDADE->(dbseek(PROD->Unidade))
        @ prow()  ,68 say UNIDADE->Sigla
        @ prow()  ,80 say transform(nTOT_QUANT,"@E 99,999.99")
        @ prow()  ,100 say transform(zPRECO,"@E 999,999.99")

        zPRECO := 0
        nTOT_QUANT := 0
        lTEM := .F.
      endif
      cCOD_PROD := space(5)
      PROD->(Dbskip())

   enddo
   @ prow()+1,00 say XCOND0 + replicate("-",80) + XCOND1
   @ prow()+1,68 say "SUBTOTAL --------------->"
   @ prow()  ,98 say transform(nTOTAL,"@E 9,999,999.99")
   @ prow()+1,00 say XCOND0 + replicate("-",80) + XCOND1

   @ prow()+1,01 say "VENDAS A PRAZO.: " + transform(nPRAZO,"@E 9,999,999.99")
   @ prow()  ,81 say "DEVOLUCOES.....: " + transform(nDEVOL,"@E 9,999,999.99")
   @ prow()+1,01 say "DESPESAS.......: " + transform(nDESP,"@E 9,999,999.99")
   @ prow()  ,81 say "LIQ. VENDA.....: " + transform(nTOTAL-nDEVOL,"@E 9,999,999.99")

   @ prow()+1,01 say "CHEQUES P/ DIA.: " + transform(nCHEQ_DIA,"@E 9,999,999.99")
   @ prow()+1,01 say "CHEQUES PRE....: " + transform(nCHEQ_PRE,"@E 9,999,999.99")
   @ prow()+1,01 say "OUTROS.........: " + transform(nOUT,"@E 9,999,999.99")
   nDIN := (nTOTAL - nDEVOL) - nPRAZO - nDESP - nCHEQ_DIA - nCHEQ_PRE - nOUT
   @ prow()+1,01 say "DINHEIRO.......: " + transform(nDIN,"@E 9,999,999.99")
   @ prow()+1,00 say XCOND0 + replicate("-",80) + XCOND1
   nTOT_GER := nPRAZO + nDESP + nCHEQ_DIA + nCHEQ_PRE + nOUT + nDIN
   @ prow()+1,01 say "TOTAL GERAL....: " + transform(nTOT_GER,"@E 9,999,999.99")

   @ prow()+2,01 say "Declaro que recebi a mercadoria acima para vender, entregar e prestar contas na volta."
   @ prow()+2,01 say "_____________________________________            _____________________________________      "
   @ prow()+1,01 say "               ASS...:                                          ASS..:                      "

   eject
   qstopprn(.F.)
return

