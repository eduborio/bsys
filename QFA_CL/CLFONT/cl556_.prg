/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO COMERCIO
// OBJETIVO...: RELATORIO DE FATURAMENTO POR SETOR
// ANALISTA...: EDUARDO AUGUSTO BORIO
// PROGRAMADOR: EDUARDO AUGUSTO BORIO
// INICIO.....: NOVEMBRO DE 2002
// OBS........:
// ALTERACOES.:

function cl556
#define K_MAX_LIN 60

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

   qlbloc(5,0,"B556A","QBLOC.GLO")
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

   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // CRIA TITULO DO RELATORIO ______________________________________________


   cTITULO := "LISTAGEM DE PEDIDOS " +" de " + dtoc(dINI) + " a " + dtoc(dFIM)

   qmensa("")

   // ESTABELECE RELACOES ENTRE ARQUIVOS ____________________________________

   ITEN_FAT->(dbsetorder(2))
return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impressao
    local nVAL_PED := 0
    local nTOTAL   := 0
    local nVALOR   := 0
    local nTT_VALOR   := 0
    local nTT_QUANT  := 0
    local nQUANT  := 0
    local nCONT    := 0
    local nDESC    := 0
    local nTOT_DESC:= 0
    local nTOT_FAT := 0
    local nTOT_VIS := 0
    local nIPI     := 0
    local ltem := .F.
    local aFAT := {}
    local asFAT := {}
    local zCFOP := ""

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   FAT->(dbsetfilter({|| FAT->Dt_emissao >= dINI .and. FAT->Dt_Emissao <= dFIM}))
   FAT->(dbsetorder(11))
   FAT->(dbgotop())

   PROD->(dbsetorder(4))
   ITEM_ROMA->(dbsetorder(2))


   if ! qinitprn() ; return ; endif

   do while ! FAT->(eof())

      if FAT->Cancelado
         FAT->(dbskip())
         loop
      endif

      if ITEM_ROMA->(dbseek(FAT->Codigo))
         FAT->(dbskip())
         loop
      endif

      qgirabarra()

      qmensa("Aguarde... Processando ...")

      CLI1->(dbseek(FAT->Cod_cli))

      //ITEN_FAT->(Dbseek(FAT->Codigo))
      //do while ITEN_FAT->Num_fat == FAT->Codigo .and. ! ITEN_FAT->(eof())
      //    PROD->(dbseek(ITEN_FAT->Cod_prod))
      //
      //    ITEN_FAT->(Dbskip())
      //enddo

      aadd(aFAT,{FAT->Cod_rota,FAT->Codigo})

      FAT->(dbskip())


   enddo

   asFAT := asort(aFAT,,,{|x,y| x[1]  < y[1] })



   if lTEM

       zCFOP := asFAT[1,1]
       nQUANT := 0
       nTT_QUANT := 0
       nVALOR := 0
       nTT_VALOR := 0
       nCONT := 1

       do while  nCONT <= len(asFAT)

          if ! qlineprn() ; exit ; endif

          if XPAGINA == 0 .or. prow() > K_MAX_LIN
             @prow()+1,0 say XCOND0
             qpageprn()
             qcabecprn(cTITULO,80)
             @ prow()+1,0 say XCOND1 + "N.F.    Cliente                             Peso  Produto                      Vl Unitario         Total    UF"
             @ prow()+1,0 say ""
          endif


          @ prow()+1,00  say asFAT[nCONT,2]

          CLI1->(dbseek(asFAT[nCONT,3]))
          @ prow()  ,08  say left(CLI1->Razao,30)
          @ prow()  ,42  say transf(asFAT[nCONT,4],"@R 999999")

          PROD->(dbsetorder(4))
          PROD->(dbseek(asFAT[nCONT,5]))

          @ prow()  ,50  say left(PROD->Descricao,28)
          @ prow()  ,80  say transf(asFAT[nCONT,6],"@E 999,999.99")
          @ prow()  ,92  say transf(asFAT[nCONT,4]*asFAT[nCONT,6],"@E 9,999,999.99")

          CGM->(dbseek(asFAT[nCONT,7]))
          @ prow()  ,110  say CGM->Estado


          nQUANT+= asFAT[nCONT,4]
          nTT_QUANT+= asFAT[nCONT,4]
          nVALOR += asFAT[nCONT,4] * asFAT[nCONT,6]
          nTT_VALOR += asFAT[nCONT,4] * asFAT[nCONT,6]



          nCONT++
          if nCONT > len(asFAT)
             nCONT := len(asFAT)
             exit
          endif

          if asFAT[nCONT,1] != zCFOP
            @ prow()+2,00   say "TOTAIS DO CFOP.:    "+zCFOP
            @ prow()  , 42 say transf(nQUANT,"@R 999999")
            @ prow()  , 92 say transf(nVALOR,"@E 9,999,999.99")
            @ prow()+1,00  say replicate("-",134)
            @ prow()+1,00  say ""
            nQUANT := 0
            nVALOR := 0

          endif

          zCFOP := asFAT[nCONT,1]

       enddo

       @ prow()+2,00   say "TOTAIS DO CFOP.:    "+zCFOP
       @ prow()  , 42 say transf(nQUANT,"@R 999999")
       @ prow()  , 92 say transf(nVALOR,"@E 9,999,999.99")
       @ prow()+1,00  say replicate("-",134)
       @ prow()+1,00  say ""
       nQUANT := 0
       nVALOR := 0

       @ prow()+2,00   say "TOTAL GERAL.:    "
       @ prow()  , 42 say transf(nTT_QUANT,"@R 999999")
       @ prow()  , 92 say transf(nTT_VALOR,"@E 9,999,999.99")
       nQUANT := 0
       nTT_QUANT := 0
       nVALOR := 0
       nTT_VALOR := 0





   endif


   qstopprn()

return

