/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO COMERCIO
// OBJETIVO...: RELATORIO GERAL DE COMISSAO SINTETICO
// ANALISTA...:
// PROGRAMADOR: LUCINEIDE VILAR POSSEBOM
// INICIO.....: DEZEMBRO DE 1997
// OBS........:
// ALTERACOES.:

function cl528
#include "inkey.ch"
#define K_LEN_HIST 66

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE  := {||(XNIVEL==1 .and. !XFLAG) .or. lastkey() = 27}

private aEDICAO := {}               // vetor para os campos
private cTITULO                     // titulo do relatorio
private dDATAI                      // data inicial
private dDATAF                      // data final
private cVEND   := space(5)         // matricula do vendedor
private cTIPO   := space(1)         // Tipo do Relatorio

sBLOC1 := qlbloc("B528B","QBLOC.GLO")
private nTOTAL     := 0
private nTOT_PROD  := 0
private nTOT_GER   := 0
private nTOT_NOT   := 0

FAT->(dbSetFilter( { || ! Cancelado }, "! Cancelado" ))
FAT->(dbGoTop())

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qgetx(-1,0,@dDATAI             )} , "DATAI" })
aadd(aEDICAO,{{ || qgetx(-1,0,@dDATAF             )} , "DATAF" })
aadd(aEDICAO,{{ || qesco(-1,0,@cTIPO  ,sBLOC1     )} , "TIPO"  })
aadd(aEDICAO,{{ || view_vend(-1,0,@cVEND ,"99999" )} , "VEND"  })
aadd(aEDICAO,{{ || NIL },NIL})    // nome do vendedor

do while .T.

   qlbloc(5,0,"B528A","QBLOC.GLO")
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

      case cCAMPO == "TIPO"
           if empty(cTIPO) ; return .F. ; endif
           qrsay(XNIVEL,qabrev(cTIPO,"12",{"Sint‚tico","Anal¡tico"}))

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

   cTITULO := "RELATORIO GERAL DE COMISSAO SINTETICO DE "
   cTITULO += dtoc(dDATAI) + " ATE " + dtoc(dDATAF)

   // RELACIONA ARQUIVOS ____________________________________________________

   FAT->(Dbsetorder(5))   // data de emissao + representante
   FAT->(Dbgotop())

return .T.

/////////////////////////////////////////////////////////////////////////////
// MODULO PRINCIPAL DE IMPRESSAO ____________________________________________

static function i_imprime
   do case
      case cTIPO == "1"
           i_sintetico()
      case cTIPO == "2"
           i_analitico()
   endcase

return

static function i_sintetico

   nTOTAL := 0
   nTOT_GER := 0
   nTOT_NOT := 0
   nPRZ   := 0
   nTOT_COMI  := 0

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

      if ! left(FAT->Cod_cfop,3) $ "510-511-512-610-611-612"
         FAT->(dbskip())
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
         qcabecprn(cTITULO,122)
         @ prow()+1,0 say "PEDIDO   DT SAI     VCTO    VENDEDOR          NOME CLIENTE                  CIDADE           VALOR NOTA  COMISS.  VAL COM."
         @ prow()+1,0 say replicate("-",122)
      endif

      @ prow()+1,00  say FAT->Codigo
      @ prow()  ,06  say dtoc(FAT->Dt_emissao)

      DUP_FAT->(Dbseek(FAT->Codigo+"01"))
      @ prow()  ,17 say dtoc(DUP_FAT->Data_venc)

      @ prow()  ,28  say FAT->Cod_vended
      VEND->(dbseek(FAT->Cod_vended))
      @ prow()  ,34  say left(VEND->Nome,11)

      CLI1->(Dbseek(FAT->Cod_cli))

      @ prow()  ,46  say left(CLI1->Razao,25)
      CGM->(dbseek(CLI1->Cgm_cob))
      @ prow()  ,76  say left(CGM->Municipio,16)

      ITEN_FAT->(dbsetorder(2))
      ITEN_FAT->(Dbgotop())
      ITEN_FAT->(dbseek(FAT->Codigo))

      nVAL       := 0
      nDESC      := 0
      nTOT_PROD  := 0
      nALIQ_ICMS := 0
      nICMS      := 0
      nVAL_UNI   := 0
      nTOT_SUBS  := 0
      nCOMI      := 0

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

         nCOMI := ITEN_FAT->Comissao

         ITEN_FAT->(Dbskip())
         nVAL_UNI := 0

      enddo

      CLI1->(dbseek(FAT->Cod_cli)) // procura a aliquota do lucro no cliente da nota
      CGM->(dbseek(CLI1->Cgm_cob))
      LUCRO->(dbseek(CGM->Estado))

      if ! empty(FAT->Aliq_desc)
         if CONFIG->Modelo_fat = "1"
           nTOT_PROD := nTOT_PROD
         else
           nTOT_PROD := nTOT_PROD - ( (nTOT_PROD * FAT->Aliq_desc) / 100)
         endif
      endif

      nVAL := nTOT_PROD   // valor total da fatura

      nTOT_NOT += nVAL
      nTOT_GER += nVAL
      nTOT_COMI += (nVAL*(nCOMI/100))
      @ prow()  ,92  say transform(nVAL, "@R 9999,999.99")
      @ prow()  ,107 say transform(nCOMI,"@R 99.99")
      @ prow()  ,113 say transform(nVAL*(nCOMI/100),"@R 99,999.99")

      nVAL       := 0
      nDESC      := 0
      nTOT_PROD  := 0
      nALIQ_ICMS := 0
      nTOT_SUBS  := 0

      FAT->(Dbskip())

      if empty(cVEND) .and. FAT->Cod_vended <> cVENDATU .and. ! FAT->(eof())
         @ prow()+1,0   say XAENFAT + "Total"
         @ prow()  ,91 say transform(nTOT_NOT, "@R 999,999,999.99") + XDENFAT
         nTOT_NOT := 0
      endif

   enddo

   if nTOT_NOT <> 0
      @ prow()+1,0   say XAENFAT + "Total"
      @ prow()  ,91 say transform(nTOT_NOT, "@R 999,999,999.99") + XDENFAT
      nTOT_NOT := 0
   endif

   @ prow()+1,0 say XAENFAT + replicate("-",122)
   @ prow()+1,0   say "Total Geral..................."
   @ prow()  ,89 say transform(nTOT_GER, "@R 999,999,999.99")
   @ prow()  ,112 say transform(nTOT_COMI, "@R 999,999.99") + XDENFAT
   @ prow()+1,0 say XAENFAT + replicate("-",122)

   qstopprn()

return

static function i_analitico

   lTEM := .F.
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
         qcabecprn(cTITULO,122)
         @ prow()+1,0 say "PEDIDO   DT SAI     VCTO    VENDEDOR          NOME CLIENTE                  CIDADE           VALOR NOTA  COMISS.  VAL COM."
         @ prow()+1,0 say replicate("-",122)
      endif

      @ prow()+1,00  say FAT->Codigo
      @ prow()  ,06  say dtoc(FAT->Dt_emissao)

      if DUP_FAT->(Dbseek(FAT->Codigo+"01"))
//         @ prow()  ,17 say dtoc(DUP_FAT->Data_venc)
         lTEM := .T.
      else
         @ prow()  ,17 say dtoc(FAT->Dt_emissao)
      endif

      @ prow()  ,28  say FAT->Cod_vended
      VEND->(dbseek(FAT->Cod_vended))
      @ prow()  ,34  say left(VEND->Nome,11)

      CLI1->(Dbseek(FAT->Cod_cli))

      @ prow()  ,46  say left(CLI1->Razao,25)
      CGM->(dbseek(CLI1->Cgm_cob))
      @ prow()  ,76  say left(CGM->Municipio,16)

      ITEN_FAT->(dbsetorder(2))
      ITEN_FAT->(Dbgotop())
      ITEN_FAT->(dbseek(FAT->Codigo))

      nVAL       := 0
      nDESC      := 0
      nTOT_PROD  := 0
      nALIQ_ICMS := 0
      nICMS      := 0
      nVAL_UNI   := 0
      nTOT_SUBS  := 0
      nCOMI      := 0

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

         nCOMI := ITEN_FAT->Comissao

         ITEN_FAT->(Dbskip())
         nVAL_UNI := 0

      enddo

      CLI1->(dbseek(FAT->Cod_cli)) // procura a aliquota do lucro no cliente da nota
      CGM->(dbseek(CLI1->Cgm_cob))
      LUCRO->(dbseek(CGM->Estado))

      if ! empty(FAT->Aliq_desc)
         if CONFIG->Modelo_fat == "1"
           nTOT_PROD := nTOT_PROD
         else
           nTOT_PROD := nTOT_PROD - ( (nTOT_PROD * FAT->Aliq_desc) / 100)
         endif
      endif

      nVAL := nTOT_PROD   // valor total da fatura

      nTOT_NOT += nVAL
      nTOT_GER += nVAL

      @ prow()  ,92  say transform(nVAL, "@R 9999,999.99")
      @ prow()  ,107 say transform(nCOMI,"@R 99.99")
      @ prow()  ,113 say transform(nVAL*(nCOMI/100),"@R 99,999.99")

      if lTEM

         do while ! DUP_FAT->(eof()) .and. left(DUP_FAT->Num_fat,5) == FAT->Codigo
            if DUP_FAT->Valor = 0
               exit
            endif

            @ prow()+1 ,00 say "Dpl.: "+ DUP_FAT->Num_fat
            @ prow()   ,17 say dtoc(DUP_FAT->Data_venc)

            @ prow()  ,28  say FAT->Cod_vended
            VEND->(dbseek(FAT->Cod_vended))
            @ prow()  ,34  say left(VEND->Nome,11)

            CLI1->(Dbseek(FAT->Cod_cli))
            @ prow()  ,46  say left(CLI1->Razao,25)


            @ prow()  ,92  say transform(DUP_FAT->Valor, "@R 9999,999.99")
            @ prow()  ,107 say transform(nCOMI,"@R 99.99")
            @ prow()  ,113 say transform(DUP_FAT->Valor*(nCOMI/100),"@R 99,999.99")

            DUP_FAT->(dbskip())

         enddo
         @ prow()+1,0 say ""
      endif

      nVAL       := 0
      nDESC      := 0
      nTOT_PROD  := 0
      nALIQ_ICMS := 0
      nTOT_SUBS  := 0
      lTEM := .F.

      FAT->(Dbskip())

      if empty(cVEND) .and. FAT->Cod_vended <> cVENDATU .and. ! FAT->(eof())
         @ prow()+1,0   say XAENFAT + "Total"
         @ prow()  ,91 say transform(nTOT_NOT, "@R 999,999,999.99") + XDENFAT
         nTOT_NOT := 0
      endif

   enddo

   if nTOT_NOT <> 0
      @ prow()+1,0   say XAENFAT + "Total"
      @ prow()  ,91 say transform(nTOT_NOT, "@R 999,999,999.99") + XDENFAT
      nTOT_NOT := 0
   endif

   @ prow()+1,0 say XAENFAT + replicate("-",122)
   @ prow()+1,0   say "Total Geral..................."
   @ prow()  ,89 say transform(nTOT_GER, "@R 999,999,999.99") + XDENFAT
   @ prow()+1,0 say XAENFAT + replicate("-",122)

   qstopprn()

return

