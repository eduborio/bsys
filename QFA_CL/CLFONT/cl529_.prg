/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO COMERCIO
// OBJETIVO...: RELATORIO GERAL DE COBRANCA
// ANALISTA...: LUCIANO DA SILVA GORSKI
// PROGRAMADOR: LUCIANO DA SILVA GORSKI
// INICIO.....: MAIO DE 1999
// OBS........:
// ALTERACOES.:

function cl529
#include "inkey.ch"
#define K_LEN_HIST 66

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE  := {||(XNIVEL==1 .and. !XFLAG) .or. lastkey() = 27}

private aEDICAO := {}         // vetor para os campos
private cTITULO               // titulo do relatorio
private dDATAI                // data inicial
private dDATAF                // data final
private cCENTRO := Space(10)  // Centro de custo

private nTOTAL  := 0

CCUSTO->(dbSetFilter())
FAT->(dbSetFilter( { || ! empty(Num_fatura) .and. ! Cancelado }, "! empty(Num_fatura) .and. ! Cancelado" ))
FAT->(dbGoTop())

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || view_centro(-1,0,@cCENTRO      )} ,"CENTRO" })
aadd(aEDICAO,{{ || NIL                             } , NIL     }) // Descricao do centro de custo
aadd(aEDICAO,{{ || qgetx(-1,0,@dDATAI             )} ,"DATAI"  })
aadd(aEDICAO,{{ || qgetx(-1,0,@dDATAF             )} ,"DATAF"  })

do while .T.

   qlbloc(5,0,"B529A","QBLOC.GLO")
   XNIVEL   := 1
   XFLAG    := .T.
   cCENTRO  := Space(10)
   dDATAI   := dDATAF  := ctod("")

   // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; dbcloseall() ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   iif( i_inicializacao() , i_imprime() , NIL )

enddo

/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA _____________________________________________

static function i_critica ( cCAMPO )

   if ! XFLAG ; return .T. ; endif

   do case

      case cCAMPO == "CENTRO"
           if !Empty(cCENTRO)
              if Right(cCENTRO,4)==Space(4); Return .F.; Endif
              if !CCUSTO->(dbseek(StrZero(Val(cCENTRO),8)))
                 qmensa("C¢digo do centro de custo n„o encontrado...","B")
                 cCENTRO := Space(10)
                 Return .F.
              else
                 cCENTRO:=CCUSTO->Codigo
                 qrsay(XNIVEL,Transform(cCENTRO,"@R 99.99.9999"))
                 qrsay(XNIVEL+1,left(CCUSTO->Descricao,28))
              Endif
           else
              qrsay(XNIVEL+1,"Todos os Centros de Custos..")
           endif
      case cCAMPO == "DATAI"
           if empty(dDATAI)
              qmensa("Campo DATA INICIAL ‚ obrigat¢rio !","B")
              qmensa("")
              return .F.
           endif
      case cCAMPO == "DATAF"
           if empty(dDATAF)
              qmensa("Campo DATA FINAL ‚ obrigat¢rio !","B")
              qmensa("")
              return .F.
           endif
           if dDATAF < dDATAI
              qmensa("DATA FINAL ‚ anterior a DATA INICIAL !","B")
              qmensa("")
              return .F.
           endif
   endcase
return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // INICIALIZA cTITULO ____________________________________________________

   cTITULO := "RESUMO DE FATURAMENTO REFERENTE AO PERIODO "
   cTITULO += dtoc(dDATAI) + " ATE " + dtoc(dDATAF)

   // RELACIONA ARQUIVOS ____________________________________________________

   CCUSTO->(dbSetFilter())
   FAT->(dbSetFilter())
   FAT->(Dbsetorder(2))   // data de emissao
   FAT->(Dbgotop())
   set softseek on
   FAT->(Dbseek(dtos(dDATAI)))
   CCUSTO->(dbSetFilter({|| right(CCUSTO->Codigo,4)<>Space(4) },"right(CCUSTO->Codigo,4)<>Space(4)"))
   iif(Empty(cCENTRO),CCUSTO->(dbgotop()),CCUSTO->(dbseek(StrZero(Val(cCENTRO),8))) )

return .T.

/////////////////////////////////////////////////////////////////////////////
// MODULO PRINCIPAL DE IMPRESSAO ____________________________________________

static function i_imprime

   nTOTAL := 0
   nPRZ   := 0
   lTESTE :=.F.
   nNUMER := 0

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif

   @ prow(),pcol() say XCOND0

   do while iif(Empty(cCENTRO),!CCUSTO->(eof()),right(CCUSTO->Codigo,4)==Right(cCENTRO,4))

      iif(Empty(cCENTRO),nCENTRO:=Right(CCUSTO->Codigo,4),nCENTRO:=Right(cCENTRO,4) )
      set softseek on
      iif(Empty(cCENTRO),FAT->(dbgotop()),)
      iif(Empty(cCENTRO),FAT->(Dbseek(dtos(dDATAI))),)
      set softseek off

      do while ! FAT->(eof()) .and. FAT->Dt_emissao >= dDATAI .and. FAT->Dt_emissao <= dDATAF .and. qcontprn()

          if lTESTE .and. nNUMER > 0
             @ prow()+1,0 say replicate("-",119)
             @ prow()+1,0 say "CODIGO E DESCRICAO DO CENTRO DE CUSTO...: "+Transform(CCUSTO->Codigo,"@R 99.99.9999")+" - "+CCUSTO->Descricao
             @ prow()+1,0 say replicate("-",119)
             nNUMER:=0
             lTESTE:=.F.
          Endif

         if FAT->C_custo == nCENTRO

            if FAT->Faturar  // relacao dos pedidos que ja foram faturados
                  nNUMER++
                  if ! qlineprn() ; exit ; endif

                  // CABECALHO PRINCIPAL _____________________________________________

                  @ prow() ,00 say XCOND1

                  if prow() = 0 .or. prow() > 60
                     qpageprn()
                     qcabecprn(cTITULO,119)
                     @ prow()+1,0 say "PEDIDO   DATA SAIDA   COD/VEND NOME DO VENDEDOR     DT VENC.  PRZ. COD/CLI NOME DO CLIENTE                   VALOR NOTA"
                     @ prow()+1,0 say replicate("-",119)
                     @ prow()+1,0 say "CODIGO E DESCRICAO DO CENTRO DE CUSTO...: "+Transform(CCUSTO->Codigo,"@R 99.99.9999")+" - "+CCUSTO->Descricao
                     @ prow()+1,0 say replicate("-",119)
                     lTESTE:=.F.
                  endif

                  @ prow()+1,00  say FAT->Codigo
                  @ prow()  ,09  say dtoc(FAT->Dt_emissao)

                  CLI1->(Dbseek(FAT->Cod_cli))
                  VEND->(Dbseek(CLI1->Cod_vend))

                  @ prow()  ,22  say VEND->Codigo
                  @ prow()  ,30  say left(VEND->Nome,15)

                  DUP_FAT->(Dbseek(FAT->Codigo+"01"))

                  lPRI := .T.

                  do while ! DUP_FAT->(eof()) .and. left(DUP_FAT->Num_fat,5) == FAT->Codigo

                     if lPRI
                        @ prow()  ,52  say dtoc(DUP_FAT->Data_venc)
                        nPRZ := DUP_FAT->Data_venc - FAT->Dt_emissao
                        @ prow()  ,62  say transform(nPRZ, "@E 999")
                        @ prow()  ,67  say FAT->Cod_cli
                        @ prow()  ,75  say left(CLI1->Razao,15)
                        @ prow()  ,105 say transform(DUP_FAT->Valor, "@R 999,999,999.99")
                        lPRI := .F.
                     else
                        @ prow()+1,52  say dtoc(DUP_FAT->Data_venc)
                        nPRZ := DUP_FAT->Data_venc - FAT->Dt_emissao
                        @ prow()  ,62  say transform(nPRZ, "@E 999")
                        @ prow()  ,67  say FAT->Cod_cli
                        @ prow()  ,75  say left(CLI1->Razao,15)
                        @ prow()  ,105 say transform(DUP_FAT->Valor, "@R 999,999,999.99")
                     endif

                     DUP_FAT->(Dbskip())

                     nTOTAL += DUP_FAT->Valor

                  enddo

            endif
         endif
         FAT->(Dbskip())

      enddo

      CCUSTO->(dbskip())
      lTESTE:= .T.

   enddo

   @ prow()+1,0 say replicate("-",119)
   @ prow()+1,0   say "Total"
   @ prow()  ,105 say transform(nTOTAL, "@R 999,999,999.99")

   qstopprn()

return
