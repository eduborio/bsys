/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO COMERCIO
// OBJETIVO...: RELATORIO GERAL DE COBRANCA
// ANALISTA...:
// PROGRAMADOR: LUCINEIDE VILAR POSSEBOM
// INICIO.....: MARCO DE 1997
// OBS........:
// ALTERACOES.:

function cl524
#include "inkey.ch"
#define K_LEN_HIST 66

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE  := {||(XNIVEL==1 .and. !XFLAG) .or. lastkey() = 27}

private aEDICAO := {}               // vetor para os campos
private cTITULO                     // titulo do relatorio
private dDATAI                      // data inicial
private dDATAF                      // data final
private cVEND   := space(5)         // matricula do vendedor

private nTOTAL     := 0
private nTOT_PROD  := 0
private nTOT_GER   := 0
private nTOT_NOT   := 0
private nTOT_BRU   := 0
private nTOT_ICM   := 0

FAT->(dbSetFilter( { || ! Cancelado }, "! Cancelado" ))
FAT->(dbGoTop())

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qgetx(-1,0,@dDATAI             )} , "DATAI" })
aadd(aEDICAO,{{ || qgetx(-1,0,@dDATAF             )} , "DATAF" })
aadd(aEDICAO,{{ || view_vend(-1,0,@cVEND ,"99999" )} , "VEND"  })
aadd(aEDICAO,{{ || NIL },NIL})    // nome do vendedor

do while .T.

   qlbloc(5,0,"B524A","QBLOC.GLO")
   XNIVEL   := 1
   XFLAG    := .T.
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
   do case

      case cCAMPO == "DATAI"
           if empty(dDATAI)
              qmensa("Campo DATA INICIAL ‚ obrigat¢rio !","B")
              return .F.
           endif
      case cCAMPO == "DATAF"
           if empty(dDATAF)
              qmensa("Campo DATA FINAL ‚ obrigat¢rio !","B")
              return .F.
           endif
           if dDATAF < dDATAI
              qmensa("DATA FINAL ‚ anterior a DATA INICIAL !","B")
              return .F.
           endif

      case cCAMPO == "VEND"
           if ! empty(cVEND)
              qrsay(XNIVEL,cVEND:=strzero(val(cVEND),5))
              if ! VEND->(dbseek(cVEND))
                 qmensa("Vendedor n„o cadastrado !","B")
                 cVEND    := space(5)
                 return .F.
              endif
           endif
           qrsay(XNIVEL+1, iif ( VEND->(dbseek(cVEND))  , left(VEND->Nome,20)  , "Todos os Vendedores" ) )

   endcase
return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // INICIALIZA cTITULO ____________________________________________________

   cTITULO := "RELATORIO GERAL DE COBRANCA DE "
   cTITULO += dtoc(dDATAI) + " ATE " + dtoc(dDATAF)

   // RELACIONA ARQUIVOS ____________________________________________________

   FAT->(Dbsetorder(5))   // data de emissao + representante
   FAT->(Dbgotop())

return .T.

/////////////////////////////////////////////////////////////////////////////
// MODULO PRINCIPAL DE IMPRESSAO ____________________________________________

static function i_imprime

   nTOTAL := 0
   nTOT_GER := 0
   nTOT_NOT := 0
   nPRZ   := 0

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif

   do while ! FAT->(eof()) .and. qcontprn()

      if  FAT->Dt_emissao < dDATAI .or. FAT->Dt_emissao > dDATAF
          FAT->(Dbskip())
          loop
      endif

      if ! empty(cVEND) .and. FAT->Cod_vended <> cVEND
         FAT->(Dbskip())
         loop
      endif

      if empty(cVEND)
         cVENDATU := FAT->Cod_vended
      endif

      if ! qlineprn() ; exit ; endif

      // CABECALHO PRINCIPAL _____________________________________________

      @ prow() ,0 say XCOND1

      if prow() = 0 .or. prow() > 60
         qpageprn()
         qcabecprn(cTITULO,132)
         @ prow()+1,0 say "PEDIDO   DT SAIDA     DT VENCIMENTO VENDEDOR     NOME CLIENTE                      VALOR TOTAL        VALOR S/ICMS        ICMS.SUBS."
         @ prow()+1,0 say replicate("-",132)
      endif

      @ prow()+1,00  say FAT->Codigo
      @ prow()  ,09  say dtoc(FAT->Dt_emissao)

      DUP_FAT->(Dbseek(FAT->Codigo+"01"))
      @ prow()  ,22 say dtoc(DUP_FAT->Data_venc)

      @ prow()  ,37  say FAT->Cod_vended

   
      CLI1->(Dbseek(FAT->Cod_cli))

      @ prow()  ,50  say left(CLI1->Razao,30)

      ITEN_FAT->(Dbgotop())
      ITEN_FAT->(dbseek(FAT->Codigo))
      nVAL       := 0
      nDESC      := 0
      nTOT_PROD  := 0
      nALIQ_ICMS := 0
      nICMS      := 0
      nVAL_UNI   := 0
      nTOT_SUBS  := 0

      do while ! ITEN_FAT->(eof()) .and. ITEN_FAT->Num_Fat == FAT->Codigo

         PROD->(dbsetorder(4))
         PROD->(dbseek(ITEN_FAT->Cod_Prod))

         if ! empty(PROD->Desconto) .and. ITEN_FAT->Calc_desc == "S"
            nDESC := (PROD->Desconto/100)
         else
            nDESC := 1
         endif

         nVAL_UNI := (ITEN_FAT->Vl_unitar) * nDESC
         nTOT_PROD := nTOT_PROD + (ITEN_FAT->Quantidade * nVAL_UNI)
         nTOT_PROD := q_soma_st()

         if ITEN_FAT->Icms_Subst == "S"
            nTOT_SUBS := nTOT_SUBS + (ITEN_FAT->Quantidade * nVAL_UNI)
         else
            nICMS := nICMS + ( ( ITEN_FAT->Quantidade * nVAL_UNI) * (ITEN_FAT->Icms   / 100) )
         endif

         nALIQ_ICMS:= ITEN_FAT->Icms
         ITEN_FAT->(Dbskip())
         nVAL_UNI := 0

      enddo

      CLI1->(dbseek(FAT->Cod_cli)) // procura a aliquota do lucro no cliente da nota
      CGM->(dbseek(CLI1->Cgm_cob))
      LUCRO->(dbseek(CGM->Estado))

      if ! empty(FAT->Aliq_desc)
         if CONFIG->modelo_2 == "2"
            nDES := nTOT_PROD - FAT->Aliq_desc
         else
            nDES := ( (nTOT_PROD * FAT->Aliq_desc) / 100)
         endif
         if CONFIG->Modelo_fat == "1"
            nDES := 0
         endif
      else
         nDES := 0
      endif

      nICM_SUBS := ( nTOT_SUBS * LUCRO->Margem * (nALIQ_ICMS/100) ) - (nTOT_SUBS * (nALIQ_ICMS/100) )

      nVAL := nTOT_PROD - nDES + nICM_SUBS  // valor total da fatura

      nTOT_NOT += nVAL
      nTOT_GER += nVAL

      @ prow()  ,81 say transform(nVAL, "@R 999,999,999.99")

      ////
      @ prow()  ,100 say transform(nTOT_PROD-nDES,"@R 9,999,999.99")
      nTOT_BRU += (nTOT_PROD-nDES)
      @ prow()  ,120 say transform(nICM_SUBS,"@R 9,999,999.99")
      nTOT_ICM += nICM_SUBS

      ////
      nVAL       := 0
      nDESC      := 0
      nTOT_PROD  := 0
      nALIQ_ICMS := 0
      nTOT_SUBS  := 0
      nICM_SUBS  := 0
      nDES       := 0

      FAT->(Dbskip())

      if empty(cVEND) .and. FAT->Cod_vended <> cVENDATU .and. ! FAT->(eof())
         @ prow()+1,0   say XAENFAT + "Total"
         @ prow()  ,83  say transform(nTOT_NOT,  "@R 999,999,999.99")
         @ prow()+1,0   say "" + XDENFAT
         nTOT_NOT := 0
      endif

   enddo

   if nTOT_NOT <> 0
      @ prow()+1,0   say XAENFAT + "Total"
      @ prow()  ,83 say transform(nTOT_NOT, "@R 999,999,999.99")
      @ prow()+1,0   say "" + XDENFAT
      nTOT_NOT := 0
   endif

   @ prow()+1,0 say XAENFAT + replicate("-",132)
   @ prow()+1,0   say "Total Geral..................."
   @ prow()  ,81 say transform(nTOT_GER, "@R 999,999,999.99") + XDENFAT
   @ prow()  ,100 say transform(nTOT_BRU,  "@R   9,999,999.99")
   @ prow()  ,120  say transform(nTOT_ICM, "@R   9,999,999.99")
   @ prow()+1,0 say XAENFAT + replicate("-",132)

   qstopprn()

return
