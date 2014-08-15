/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO COMERCIO
// OBJETIVO...: RELATORIO DE EMBARQUES
// ANALISTA...: EDUARDO AUGUSTO BORIO
// PROGRAMADOR: EDUARDO AUGUSTO BORIO
// INICIO.....: SETEMBRO DE 2002
// OBS........:
// ALTERACOES.:

function cl508
#define K_MAX_LIN 60

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG) .or. lastkey()==27  }

private cTITULO                   // titulo do relatorio
private aEDICAO := {}             // vetor para os campos de entrada de dados
private dINI
private dFIM

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qgetx(-1,0,@dINI)            } , "INI"    })
aadd(aEDICAO,{{ || qgetx(-1,0,@dFIM)            } , "FIM"    })

do while .T.

   qlbloc(5,0,"B508A","QBLOC.GLO")
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


   cTITULO := "LISTAGEM DE EMBARQUES" + " DE "+ dtoc(dINI) +" a " + dtoc(dFIM)

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

   if ! qinitprn() ; return ; endif

   FAT->(dbsetfilter({|| !empty(FAT->Num_fatura).and.FAT->Embarque>=dINI.and.FAT->Embarque <= dFIM},'!empty(FAT->Num_fatura).and.FAT->Embarque>=dINI.and.FAT->Embarque <= dFIM'))
   FAT->(dbsetorder(11)) // Num NF
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
            if ! left(FAT->Cod_cfop,3) $ "510-511-512-610-611-612"
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
         @ prow()+1,0 say XCOND1 + "No N.F. Emissao    Cliente                        Quant         Total  Produto                    Lote               Transporte      UF"
         @ prow()+1,0 say ""
      endif

      qgirabarra()

      qmensa("Aguarde... Processando ...")

      CLI1->(dbseek(FAT->Cod_cli))

      ITEN_FAT->(Dbgotop())
      ITEN_FAT->(Dbseek(FAT->Codigo))
      do while ITEN_FAT->Num_fat == FAT->Codigo .and. ! ITEN_FAT->(eof())

          PROD->(dbsetorder(4))
          PROD->(dbseek(ITEN_FAT->Cod_Prod))

          @ prow()+1,00  say FAT->Num_fatura
          @ prow() , 08  say dtoc(FAT->Dt_emissao)
          @ prow()  ,19  say left(CLI1->Razao,30)
          @ prow()  ,49  say transf(ITEN_FAT->Quantidade,"@R 9999999")
          PROD->(dbsetorder(4))
          PROD->(dbseek(ITEN_FAT->Cod_Prod))
          @ prow()  ,58  say transf(ITEN_FAT->Quantidade*ITEN_FAT->Vl_unitar,"@E 9,999,999.99")

          @ prow()  ,72  say left(PROD->Descricao,26)

          @ prow()  ,99  say FAT->Lote_est

          TRANSP->(dbseek(FAT->Cod_transp))
          @ prow()  ,118 say left(TRANSP->Razao,15)
          CGM->(dbseek(CLI1->Cgm_ent))
          @ prow()  ,134 say CGM->Estado

          nQUANT += ITEN_FAT->Quantidade
          nTOTAL += (ITEN_FAT->Quantidade*ITEN_FAT->Vl_unitar)
          ITEN_FAT->(Dbskip())

      enddo

      FAT->(dbskip())
   enddo

   @ prow()+1,00   say replicate("*",30)
   @ prow()+1,00   say "TOTAL.: " + transf(nTOTAL,"@E 9,999,999.99")
   @ prow()+1,00   say replicate("*",30)
   @ prow()+1  ,00 say "PESO LIQUIDO.: "+ transf(nQUANT,"@R 9999999")
   @ prow()+1,00   say replicate("*",30)


   nTOT_QUANT := 0
   nTOT_GER   := 0
   nQUANT     := 0
   nTOTAL     := 0
   nQTDE_FAT  := 0
   nTOT_FAT   := 0

   qstopprn()

return
