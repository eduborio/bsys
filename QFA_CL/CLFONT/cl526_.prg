/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO USIMIX
// OBJETIVO...: RELATORIO DE COMISSAO POR VENDEDOR
// ANALISTA...:
// PROGRAMADOR: LUCINEIDE VILAR POSSEBOM
// INICIO.....: MARCO DE 1997
// OBS........:
// ALTERACOES.:

function cl526
#include "inkey.ch"
#define K_LEN_HIST 66

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE  := {||(XNIVEL==1 .and. !XFLAG) .or. lastkey() = 27}

private aEDICAO := {}    // vetor para os campos
private cTITULO          // titulo do relatorio
private cVEND            // matricula do vendedor
private dDATAI           // data inicial
private dDATAF           // data final

private nCOMISSAO := 0
private nVAL_PROD := 0
private nVAL_COM  := 0
private nVAL_UNI  := 0

private cVENDATU         // vendedor anterior

FAT->(dbSetFilter( { || ! Cancelado }, "! Cancelado" ))
FAT->(dbGoTop())

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || view_vend(-1,0,@cVEND ,"99999" )} , "VEND"  })
aadd(aEDICAO,{{ || NIL },NIL})    // nome do vendedor
aadd(aEDICAO,{{ || qgetx(-1,0,@dDATAI             )} , "DATAI" })
aadd(aEDICAO,{{ || qgetx(-1,0,@dDATAF             )} , "DATAF" })

do while .T.

   qlbloc(5,0,"B526A","QBLOC.GLO")
   XNIVEL   := 1
   XFLAG    := .T.
   cVEND    := space(5)
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
      case cCAMPO == "VEND"
           if ! empty(cVEND)
              qrsay(XNIVEL,cVEND:=strzero(val(cVEND),5))
              if ! VEND->(dbseek(cVEND))
                 qmensa("Vendedor n„o cadastrado !","B")
                 cVEND    := space(5)
                 return .F.
              endif
           endif
           qrsay(XNIVEL+1, iif (VEND->(dbseek(cVEND)) ,left(VEND->Nome,30) ,"*** Todos os Vendedores ***"))

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

   cTITULO := "FATURAMENTO DE "
   cTITULO += dtoc(dDATAI) + " A " + dtoc(dDATAF)
   cTITULO += " POR VENDEDOR"

   // RELACIONA ARQUIVOS ____________________________________________________

   select FAT
   FAT->(Dbsetorder(4))   // codigo do representante
   FAT->(Dbgotop())

   if ! empty(cVEND)

      if ! FAT->(Dbseek(cVEND))
         qmensa("N„o tem Faturas para este Representante")
         return .F.
      endif

   endif

   qmensa()

return .T.

/////////////////////////////////////////////////////////////////////////////
// MODULO PRINCIPAL DE IMPRESSAO ____________________________________________

static function i_imprime

   local cCOMP , lACHOU , lMUDOU := .F. , nPOSIC , nCONT
   local nDESC      := 0
   local nTOT_PROD  := 0
   local nALIQ_ICMS := 0

   nCOMISSAO := 0
   nVAL_PROD := 0
   nVAL_COM  := 0
   nVAL_UNI  := 0
   nTOT_NOT  := 0
   nVENDA    := 0
   nICMS     := 0
   nVEZ      := 0
   nTOT_SUBS := 0

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif

   @ prow(),pcol() say XCOND0

   cVENDATU := FAT->Cod_vended

   VEND->(dbseek(cVENDATU))

   do while ! FAT->(eof()) .and. qcontprn()

      if FAT->Cod_vended == cVENDATU

         if FAT->Dt_emissao < dDATAI .or. FAT->Dt_emissao > dDATAF
            FAT->(dbskip())
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


         if ! qlineprn() ; exit ; endif

         // CABECALHO PRINCIPAL _____________________________________________

         if prow() = 0 .or. prow() > 60
            qpageprn()
            qcabecprn(cTITULO,80)
            i_sub_cab()
            @ prow()+1,0 say "PEDIDO                  CLIENTE                  EMISSAO     N/NF     VALOR N.F."
            @ prow()+1,0 say replicate("-",80)
         endif

         @ prow()+1,00  say FAT->Codigo
         @ prow()  ,08  say iif(CLI1->(Dbseek(FAT->Cod_cli)), left(CLI1->Razao,38) , space(38))
         @ prow()  ,48  say dtoc(FAT->Dt_emissao)
         @ prow()  ,61  say FAT->Num_fatura

         nVAL := nVAL_UNI := nICMS := nALIQ_ICMS := nDESC := nTOT_PROD := nTOT_SUBS := 0

         ITEN_FAT->(Dbgotop())
         ITEN_FAT->(dbseek(FAT->Codigo))

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

            if ITEN_FAT->Icms_subst == "S"
               nTOT_SUBS := nTOT_SUBS + ( ITEN_FAT->Quantidade * nVAL_UNI )
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
            if CONFIG->Modelo_fat == "1"
               nDES := 0
            else
               nDES := ( (nTOT_PROD * FAT->Aliq_desc) / 100)
            endif
         else
            nDES := 0
         endif


         nICM_SUBS := ( nTOT_SUBS * LUCRO->Margem * (nALIQ_ICMS/100) ) - (nTOT_SUBS * (nALIQ_ICMS/100) )

         nVAL := nTOT_PROD - nDES + nICM_SUBS  // valor total da fatura

         @ prow()  ,71   say transform(nVAL, "@E 999,999.99")

         nTOT_NOT += nVAL
         nVENDA   += nVAL

      else

        cVENDATU := FAT->Cod_vended

        i_tot_vend()

        if ! empty(cVEND) // quando mudar de vendedor e foi pedido so' de um, encerra ______________________
           exit
        else
           i_sub_cab()
           @ prow()+1,0 say "PEDIDO                  CLIENTE                  EMISSAO     N/NF     VALOR N.F."
           @ prow()+1,0 say replicate("-",80)
           cVENDATU  := FAT->Cod_vended
           nVENDA    := 0
           loop
        endif

      endif

      FAT->(Dbskip())

   enddo

   @ prow()+2,40  say "Total Geral.........:  " + transform(nTOT_NOT,"@E 999,999.99")

   qstopprn()

return

/////////////////////////////////////////////////////////////////////////////
// IMPRESSAO DO SUB_CABECALHO _______________________________________________

static function i_sub_cab
   @ prow()+1,0 say "VENDEDOR: " + cVENDATU + " - " + iif(VEND->(dbseek(cVENDATU)), alltrim(VEND->Nome) , space(20) )
return

/////////////////////////////////////////////////////////////////////////////
// IMPRESSAO DO TOTAL POR VENDEDOR _________________________________________

function i_tot_vend
   @ prow()+1,0 say replicate("-",80)
   @ prow()+1,40  say "Total das Vendas....:  " + transform(nVENDA,"@E 999,999.99")
   @ prow()+1,0 say replicate("-",80)
   nVEND := 0
return
