////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO COMERCIO
// OBJETIVO...: RELATORIO GERAL DE COBRANCA
// ANALISTA...:
// PROGRAMADOR: LUCINEIDE VILAR POSSEBOM
// INICIO.....: MARCO DE 1997
// OBS........:
// ALTERACOES.:

function cl525
#include "inkey.ch"
#define K_LEN_HIST 66

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE  := {||(XNIVEL==1 .and. !XFLAG) .or. lastkey() = 27}

private aEDICAO := {}    // vetor para os campos
private cTITULO          // titulo do relatorio
private dDATAI           // data inicial
private dDATAF           // data final

private nTOTAL  := 0
private nTOT_VISTA := nVISTA := nTOT_PRAZO := nPRAZO := nTOT := 0

FAT->(dbSetFilter( { || ! Cancelado }, "! Cancelado" ))
FAT->(dbGoTop())

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qgetx(-1,0,@dDATAI             )} , "DATAI" })
aadd(aEDICAO,{{ || qgetx(-1,0,@dDATAF             )} , "DATAF" })

do while .T.

   qlbloc(5,0,"B525A","QBLOC.GLO")
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
   endcase
return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // INICIALIZA cTITULO ____________________________________________________

   cTITULO := "DEMONSTRATIVO DE VENDAS DE "
   cTITULO += dtoc(dDATAI) + " ATE " + dtoc(dDATAF)

   // RELACIONA ARQUIVOS ____________________________________________________

   FAT->(Dbsetorder(4))   // codigo representante
   FAT->(Dbgotop())

return .T.

/////////////////////////////////////////////////////////////////////////////
// MODULO PRINCIPAL DE IMPRESSAO ____________________________________________

static function i_imprime

   nTOTAL := 0
   nPRZ   := 0

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif

   @ prow(),pcol() say XCOND0

   do while ! VEND->(eof()) .and. qcontprn()

      FAT->(Dbseek(VEND->Codigo))

      do while FAT->Cod_vended == VEND->Codigo

         if  FAT->Dt_emissao < dDATAI .or. FAT->Dt_emissao > dDATAF
             FAT->(Dbskip())
             loop
         endif

         if CONFIG->Modelo_2 == "1"
            if year(dDATAI) < 2003
               if FAT->Cod_natop != "511" .and. FAT->Cod_natop != "611"
                  FAT->(dbskip())
                  loop
               endif
            else
               if FAT->Cod_cfop != "5101" .and. FAT->Cod_cfop != "6101"
                  FAT->(dbskip())
                  loop
               endif
            endif
         endif

         ITEN_FAT->(Dbgotop())
         ITEN_FAT->(dbseek(FAT->Codigo))

         nVAL       := 0
         nDESC      := 0
         nTOT_PROD  := 0
         nVAL_UNI   := 0

         do while ITEN_FAT->Num_Fat == FAT->Codigo

            PROD->(dbsetorder(4))
            PROD->(dbseek(ITEN_FAT->Cod_Prod))

            if ! empty(PROD->Desconto) .and. ITEN_FAT->Calc_desc == "S"
               nDESC := (PROD->Desconto/100)
            else
               nDESC := 1
            endif

            nVAL_UNI := (ITEN_FAT->Vl_unitar) * nDESC

            nTOT_PROD := nTOT_PROD + (ITEN_FAT->Quantidade * nVAL_UNI)
            nTOT_PROD := nTOT_PROD + q_soma_st()

            ITEN_FAT->(Dbskip())

            nVAL_UNI := 0

         enddo

         if ! empty(FAT->Aliq_desc)
            if CONFIG->Modelo_fat == "1"
             nTOT_PROD := nTOT_PROD
            else
              nTOT_PROD := nTOT_PROD - ( (nTOT_PROD * FAT->Aliq_desc) / 100)
            endif
         endif

         nVAL := nTOT_PROD  // valor total da fatura

         if FAT->Vista == "S"
            nVISTA  += nVAL
         else
            nPRAZO  += nVAL
         endif

         nTOTAL     += nVAL

         FAT->(Dbskip())

      enddo

      if ! qlineprn() ; exit ; endif

      // CABECALHO PRINCIPAL _____________________________________________

      @ prow() ,00 say XCOND0

      if prow() = 0 .or. prow() > 60
         qpageprn()
         qcabecprn(cTITULO,80)
         @ prow()+1,0 say "CODIGO   NOME DO VENDEDOR                     TOTAL         A VISTA      A PRAZO"
         @ prow()+1,0 say replicate("-",80)
      endif

      @ prow()+1,0  say VEND->Codigo
      @ prow()  ,10 say left(VEND->Nome,30)
      @ prow()  ,42 say transform(nVISTA+nPRAZO,"@E 9,999,999.99")
      @ prow()  ,55 say transform(nVISTA,"@E 9,999,999.99")
      @ prow()  ,67 say transform(nPRAZO,"@E 9,999,999.99")

      VEND->(Dbskip())

      nTOT_VISTA += nVISTA
      nTOT_PRAZO += nPRAZO
      nVISTA := nPRAZO := 0

   enddo

   @ prow()+1,0 say replicate("-",80)
   @ prow()+1,0   say "Total"
   @ prow()  ,42 say transform(nTOT_VISTA+nTOT_PRAZO, "@R 9,999,999.99")
   @ prow()  ,55 say transform(nTOT_VISTA, "@R 9,999,999.99")
   @ prow()  ,67 say transform(nTOT_PRAZO, "@R 9,999,999.99")
   @ prow()+1,0 say replicate("-",80)

   qstopprn()

return
