/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO COMERCIO
// OBJETIVO...: RELATORIO DE FATURAMENTO POR SETOR
// ANALISTA...: EDUARDO AUGUSTO BORIO
// PROGRAMADOR: EDUARDO AUGUSTO BORIO
// INICIO.....: DEZEMBRO DE 2000
// OBS........:
// ALTERACOES.:

function cl510
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

   qlbloc(5,0,"B510A","QBLOC.GLO")
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


   cTITULO := "RELATORIO DE FATURAMENTO (Cond Pagto)" +" de " + dtoc(dINI) + " a " + dtoc(dFIM)

   qmensa("")

   // ESTABELECE RELACOES ENTRE ARQUIVOS ____________________________________

   FAT->(dbsetorder(9)) // data de saida
   FAT->(dbgotop())
   set softseek on
   FAT->(Dbseek(dtos(dINI)))
   set softseek off
   ITEN_FAT->(dbsetorder(2))
return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impressao
    local nVAL_PED := 0
    local nTOTAL   := 0
    local nDESC    := 0
    local nTOT_DESC:= 0
    local nIPI     := 0

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif

   do while ! FAT->(eof())  .and. FAT->Dt_saida >= dINI .and. FAT->Dt_saida <= dFIM  // condicao principal de loop

      if FAT->Cancelado
         FAT->(dbskip())
         loop
      endif

      if empty(FAT->Num_fatura).and. FAT->Es == "S"
         FAT->(dbskip())
         loop
      endif

      if ! qlineprn() ; exit ; endif

      if XPAGINA == 0 .or. prow() > K_MAX_LIN
         @prow()+1,0 say XCOND0
         qpageprn()
         qcabecprn(cTITULO,80)
         @ prow()+1,0 say XCOND1 + "N.F.    Cliente                                   Condicao                    Bairro         Telefone         Emissao            Valor"
         @ prow()+1,0 say ""
      endif

      qgirabarra()

      qmensa("Aguarde... Processando ...")

         CLI1->(dbseek(FAT->Cod_cli))

         @ prow()  ,00  say XCOND1
         @ prow()+1,01  say FAT->Num_fatura
         @ prow()  ,08  say left(CLI1->Razao,40)
         COND->(dbseek(FAT->Condic))
         @ prow()  ,50  say left(COND->Descricao,25)
         @ prow()  ,78  say left(CLI1->Bairro_cob,12)
         @ prow()  ,93  say CLI1->Fone1
         @ prow()  ,110  say dtoc(FAT->Dt_emissao)

         ITEN_FAT->(Dbgotop())
         ITEN_FAT->(Dbseek(FAT->Codigo))
         do while ITEN_FAT->Num_fat == FAT->Codigo .and. ! ITEN_FAT->(eof())

             PROD->(dbsetorder(4))
             PROD->(dbseek(ITEN_FAT->Cod_Prod))
             nVAL_PED += (ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade)
             nVAL_PED += q_soma_st()
             nIPI += (ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade) * (ITEN_FAT->Ipi/100)
             ITEN_FAT->(Dbskip())

         enddo

         if CONFIG->Modelo_fat == "1"
            nDESC := FAT->Aliq_desc
            nTOT_DESC := nDESC
           nVAL_PED := (nVAL_PED + nIPI) - nTOT_DESC
         else
           nVAL_PED := nVAL_PED + nIPI
         endif
         @ prow()  ,122  say transform(nVAL_PED, "@E 9,999,999.99")
         nTOTAL += nVAL_PED
         nVAL_PED := 0
         nIPI     := 0
         nDESC    := 0
         nTOT_DESC:= 0
      FAT->(dbskip())

   enddo

   @ prow()+1,00   say replicate("-",134)
   @ prow()+1, 84  say  "TOTAL -------------->"
   @ prow()  ,115  say transform(nTOTAL, "@E 9,999,999.99")

   qstopprn()

return
