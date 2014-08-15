////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO COMERCIO
// OBJETIVO...: RELATORIO DEMONSTRATIVO DE COMISSAO
// ANALISTA...:
// PROGRAMADOR: LUCINEIDE VILAR POSSEBOM
// INICIO.....: MARCO DE 1997
// OBS........:
// ALTERACOES.:

function cl527
#include "inkey.ch"
#define K_LEN_HIST 66

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE  := {||(XNIVEL==1 .and. !XFLAG) .or. lastkey() = 27}

private aEDICAO := {}    // vetor para os campos
private cTITULO          // titulo do relatorio
private cVEND            // vendedor
private dDATAI           // data inicial
private dDATAF           // data final
private nVISTA
private nPRAZO
private nCOM_VIS
private nVEZ_VIS
private nCOM_PRA
private nVEZ_PRA

private nTOTAL  := 0
private nTOT_VISTA := nVISTA := nTOT_PRAZO := nPRAZO := nTOT := 0

FAT->(dbSetFilter( { || ! Cancelado }, "! Cancelado" ))
FAT->(dbGoTop())

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || view_vend(-1,0,@cVEND ,"99999" )} , "VEND"  })
aadd(aEDICAO,{{ || NIL },NIL})    // nome do vendedor
aadd(aEDICAO,{{ || qgetx(-1,0,@dDATAI             )} , "DATAI" })
aadd(aEDICAO,{{ || qgetx(-1,0,@dDATAF             )} , "DATAF" })

do while .T.

   qlbloc(5,0,"B527A","QBLOC.GLO")
   XNIVEL   := 1
   XFLAG    := .T.
   dDATAI   := dDATAF  := ctod("")
   cVEND    := space(5)

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
           qrsay(XNIVEL+1, iif (VEND->(dbseek(cVEND)) ,left(VEND->Nome,30) ,"*** Todos os Vendedores ***"))

   endcase
return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // INICIALIZA cTITULO ____________________________________________________

   cTITULO := "DEMONSTRATIVO DE COMISSAO DE "
   cTITULO += dtoc(dDATAI) + " ATE " + dtoc(dDATAF)

   // RELACIONA ARQUIVOS ____________________________________________________

   FAT->(Dbsetorder(4))   // codigo representante
   FAT->(Dbgotop())

   VEND->(Dbgotop())

return .T.

/////////////////////////////////////////////////////////////////////////////
// MODULO PRINCIPAL DE IMPRESSAO ____________________________________________

static function i_imprime

   nTOTAL := 0
   nPRZ   := 0
   nVISTA := nPRAZO := nCOM_VIS := nVEZ_VIS := nCOM_PRA := nVEZ_PRA := nTOT_VISTA := nTOT_PRAZO := 0

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif

   @ prow(),pcol() say XCOND1

   do while ! VEND->(eof()) .and. qcontprn()

      if ! empty(cVEND)
         VEND->(dbseek(cVEND))
         FAT->(dbseek(cVEND))
      else
         FAT->(Dbseek(VEND->Codigo))
      endif

      do while FAT->Cod_vended == VEND->Codigo

         if FAT->Dt_emissao < dDATAI .or. FAT->Dt_emissao > dDATAF
            FAT->(dbskip())
            loop
         endif

         if FAT->Cod_cfop != "5101" .and. FAT->Cod_cfop != "6101"
            FAT->(dbskip())
            loop
         endif

         if FAT->Vista == "S"

            ITEN_FAT->(Dbgotop())
            ITEN_FAT->(Dbseek(FAT->Codigo))

            do while ! ITEN_FAT->(eof()) .and. ITEN_FAT->Num_fat == FAT->Codigo

               PROD->(dbsetorder(4))
               PROD->(dbseek(ITEN_FAT->Cod_Prod))

               if ! empty(PROD->Desconto) .and. ITEN_FAT->Calc_desc == "S"
                  nDESC := (PROD->Desconto/100)
               else
                  nDESC := 1
               endif

               nVAL_UNI := (ITEN_FAT->Vl_unitar) * nDESC

               if ! empty(FAT->Aliq_desc)
                  if CONFIG->Modelo_fat == "1"
                     nCOM_VIS +=  ( ( nVAL_UNI * ITEN_FAT->Quantidade ) - ( (ITEN_FAT->Quantidade * nVAL_UNI) ) ) * (ITEN_FAT->Comissao/100)
                  else
                     nCOM_VIS +=  ( ( nVAL_UNI * ITEN_FAT->Quantidade ) - (((ITEN_FAT->Quantidade * nVAL_UNI) * FAT->Aliq_desc) / 100) ) * (ITEN_FAT->Comissao/100)
                  endif
               else
                  nCOM_VIS += (nVAL_UNI * ITEN_FAT->Quantidade) * (ITEN_FAT->Comissao/100)
               endif

               ITEN_FAT->(Dbskip())

            enddo

         else

            ITEN_FAT->(Dbgotop())
            ITEN_FAT->(Dbseek(FAT->Codigo))

            do while ! ITEN_FAT->(eof()) .and. ITEN_FAT->Num_fat == FAT->Codigo

               PROD->(dbsetorder(4))
               PROD->(dbseek(ITEN_FAT->Cod_Prod))

               if ! empty(PROD->Desconto) .and. ITEN_FAT->Calc_desc == "S"
                  nDESC := (PROD->Desconto/100)
               else
                  nDESC := 1
               endif

               nVAL_UNI := (ITEN_FAT->Vl_unitar) * nDESC

               if ! empty(FAT->Aliq_desc)
                  nCOM_PRA +=  ( ( nVAL_UNI * ITEN_FAT->Quantidade ) - (((ITEN_FAT->Quantidade * nVAL_UNI) * FAT->Aliq_desc) / 100) ) * (ITEN_FAT->Comissao/100)
               else
                  nCOM_PRA += (nVAL_UNI * ITEN_FAT->Quantidade) * (ITEN_FAT->Comissao/100)
               endif

               ITEN_FAT->(Dbskip())

            enddo

         endif

         FAT->(Dbskip())

      enddo

      if ! qlineprn() ; exit ; endif

      // CABECALHO PRINCIPAL _____________________________________________

      @ prow() ,00 say XCOND1

      if prow() = 0 .or. prow() > 60
         qpageprn()
         qcabecprn(cTITULO,100)
         @ prow()+1,0 say "Codigo  Nome do Vendedor    Comissao total                Comissao a Vista         Comissao a Prazo"
         @ prow()+1,0 say replicate("-",100)
      endif

      @ prow()+1,00 say VEND->Codigo
      @ prow()  ,08 say left(VEND->Nome,19)
      @ prow()  ,30 say transform(nCOM_VIS+nCOM_PRA,"@E 9,999,999.99")
      @ prow()  ,62 say transform(nCOM_VIS,"@E 9,999,999.99")
      @ prow()  ,88 say transform(nCOM_PRA,"@E 9,999,999.99")

      VEND->(Dbskip())

      if ! empty(cVEND)
         nTOT_VISTA += nCOM_VIS
         nTOT_PRAZO += nCOM_PRA
         nCOM_VIS := nCOM_PRA := 0
         exit
      endif

      nTOT_VISTA += nCOM_VIS
      nTOT_PRAZO += nCOM_PRA
      nCOM_VIS := nCOM_PRA := 0

   enddo

   @ prow()+1,0 say replicate("-",100)
   @ prow()+1,0   say "Total"
   @ prow()  ,30 say transform(nTOT_VISTA+nTOT_PRAZO, "@R 9,999,999.99")
   @ prow()  ,62 say transform(nTOT_VISTA, "@R 9,999,999.99")
   @ prow()  ,88 say transform(nTOT_PRAZO, "@R 9,999,999.99")
   @ prow()+1,0 say replicate("-",100)

   qstopprn()

return
