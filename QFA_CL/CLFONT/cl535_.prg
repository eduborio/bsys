/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO COMERCIO
// OBJETIVO...: RELATORIO DE FATURAMENTO POR SETOR
// ANALISTA...: EDUARDO AUGUSTO BORIO
// PROGRAMADOR: EDUARDO AUGUSTO BORIO
// INICIO.....: NOVEMBRO DE 2002
// OBS........:
// ALTERACOES.:

function cl535
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
aadd(aEDICAO,{{ || view_cli(-1,0,@cSETOR)     } , "SETOR"  })
aadd(aEDICAO,{{ || NIL                          } , NIL  })

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

      case cCAMPO == "SETOR"

   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // CRIA TITULO DO RELATORIO ______________________________________________


   cTITULO := "RELATORIO GERAL DE FATURAMENTO" +" de " + dtoc(dINI) + " a " + dtoc(dFIM)

   qmensa("")

   // ESTABELECE RELACOES ENTRE ARQUIVOS ____________________________________

   ITEN_FAT->(dbsetorder(2))
return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impressao
    local nVAL_PED := 0
    local nTOTAL   := 0
    local nDESC    := 0
    local nTOT_DESC:= 0
    local nTOT_FAT := 0
    local nTOT_VIS := 0
    local nIPI     := 0
    local nTOT_QUANT :=0
    local nCONT := 0

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   FAT->(dbsetfilter({|| FAT->Dt_emissao >= dINI .and. FAT->Dt_Emissao <= dFIM},'FAT->Dt_emissao >= dINI .and. FAT->Dt_Emissao <= dFIM'))
   FAT->(dbsetorder(11))
   FAT->(dbgotop())


   if ! qinitprn() ; return ; endif

   do while ! FAT->(eof())  .and. FAT->Dt_emissao >= dINI .and. FAT->Dt_emissao <= dFIM  // condicao principal de loop

      if FAT->Cancelado
         FAT->(dbskip())
         loop
      endif

      if empty(FAT->Num_fatura).and. FAT->Es == "S"
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
            if ! left(FAT->Cod_cfop,3) $ "510-511-512-610-611-612-710-711-712"
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
         @ prow()+1,0 say XCOND1 + "Data Emissao    Cod.  Cliente                                                          Total        Nota Fiscal    UF"
         @ prow()+1,0 say ""
      endif

      qgirabarra()

      qmensa("Aguarde... Processando ...")
   
      CLI1->(dbseek(FAT->Cod_cli))

      CGM->(dbgotop())
      CGM->(dbseek(CLI1->Cgm_cob))

      ITEN_FAT->(Dbgotop())
      ITEN_FAT->(Dbseek(FAT->Codigo))

      do while ITEN_FAT->Num_fat == FAT->Codigo .and. ! ITEN_FAT->(eof())

          PROD->(dbsetorder(4))
          PROD->(dbseek(ITEN_FAT->Cod_Prod))
          nTOTAL += ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade
          nTOTAL += q_soma_st()
          nCONT++
          ITEN_FAT->(Dbskip())
      enddo

      @ prow()+1,00  say dtoc(FAT->Dt_emissao)
      @ prow()  ,16  say CLI1->Codigo
      @ prow()  ,22  say left(CLI1->Razao,50)
      @ prow()  ,80  say transform(nTOTAL,"@E 9,999,999.99")
      @ prow()  ,103  say FAT->Num_fatura

      @ prow()  ,115  say CGM->Estado


      FAT->(dbskip())


   enddo


   qstopprn()

return
