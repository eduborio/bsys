/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO COMERCIO
// OBJETIVO...: Relatorio de comissao
// ANALISTA...: EDUARDO AUGUSTO BORIO
// PROGRAMADOR: EDUARDO AUGUSTO BORIO
// INICIO.....: ABRIL DE 2007
// OBS........:
// ALTERACOES.:

function cl565
#define K_MAX_LIN 57

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG) .or. empty(dINI) }

private cTITULO                   // titulo do relatorio
private cTITULO2                   // titulo do relatorio
private cRepres                   // titulo do relatorio
private cEstado                   // titulo do relatorio
private cCidade                   // titulo do relatorio
private dINI
private dFIM
private dINI_ANT
private dFIM_ANT
private dINI_ACU
private dFIM_ACU

private dATUAL_INI
private dATUAL_FIM


private cSETOR := space(5)
private cVEND   := space(5)
private cTIPO   := space(1)
private cCGM    := space(6)
private cUFS    := space(2)

private aEDICAO    := {}             // vetor para os campos de entrada de dados
private aReport    := {}
private aCorrente  := {}
private asCorrente := {}
private sBLOC1  := qlbloc("B565B","QBLOC.GLO")




if ! quse(XDRV_CL,"FI565",{""},"E")
   qmensa("N„o foi poss¡vel abrir arquivo temporario !! Tente novamente.")
   return
endif


// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qgetx(-1,0,@dINI)            } , "INI"    })
aadd(aEDICAO,{{ || qgetx(-1,0,@dFIM)            } , "FIM"    })
aadd(aEDICAO,{{ || qesco(-1,0,@cTIPO ,sBLOC1    )}  ,"TIPO"  })

aadd(aEDICAO,{{ || view_repres(-1,0,@cVEND   )    } , "VEND"   })
aadd(aEDICAO,{{ || NIL                          } , NIL      })

aadd(aEDICAO,{{ || view_Ufs(-1,0,@cUFS   )      } , "UFS"  })
aadd(aEDICAO,{{ || NIL                          } , NIL  })

aadd(aEDICAO,{{ || view_cgm(-1,0,@cCGM   )      } , "CGM"  })
aadd(aEDICAO,{{ || NIL                          } , NIL  })


do while .T.

   qlbloc(5,0,"B559A","QBLOC.GLO")
   XNIVEL := 1
   XFLAG  := .T.
   cTIPO := " "
   cCGM  := space(6)
   cUFS  := space(2)

   dINI := dFIM := ctod("")

   dINI_ANT := dFIM_ANT := dINI_ACU := dFIM_ACU :=  dATUAL_INI :=  dATUAL_FIM := ctod("")

   cVEND := space(5)
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

      case cCAMPO == "VEND"

           qrsay(XNIVEL,cVEND)

           if empty(cVEND)
              qrsay(XNIVEL++, "Todos os Representantes.......")
              cRepres := " Todos "
           else
              if ! REPRES->(Dbseek(cVEND))
                 qmensa("Representante n„o encontrado","B")
                 return .F.
              else
                 qrsay(XNIVEL++,left(REPRES->Razao,30))
                 cRepres := " "+left(Repres->Razao,30)+" "
              endif

           endif

      case cCAMPO == "UFS"

           qrsay(XNIVEL,cUFS)

           if empty(cUFS)
              qrsay(XNIVEL+1, "Todos os Estados.......")
              cEstado := " Todos "
           else
              if ! UFS->(Dbseek(cUFS))
                 qmensa("Estado n„o encontrado","B")
                 return .F.
              else
                 qrsay(XNIVEL+1,left(UFS->Descricao,30))
                 cEstado := left(UFS->Descricao,30)

              endif
           endif

      case cCAMPO == "CGM"

           qrsay(XNIVEL,cCGM)

           if empty(cCGM)
              qrsay(XNIVEL+1, "Todas as Cidades.......")
              cCidade := " Todas "
           else
              if ! CGM->(Dbseek(cCGM))
                 qmensa("Municipio n„o encontrado","B")
                 return .F.
              else
                 qrsay(XNIVEL+1,left(CGM->Municipio,30))
                 cCidade := left(CGM->Municipio,30)
              endif
           endif


      case cCAMPO == "TIPO"
           if empty(cTIPO) ; return .F. ; endif
           qrsay(XNIVEL,qabrev(cTIPO,"123",{"1 - Representantes","2 - Clientes","3 - Produtos"}))


   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao
local sANO  := ""
local nANO  := ""
local dBissexto := ""

   // CRIA TITULO DO RELATORIO ______________________________________________


   cTITULO := "RELATORIO DE VENDAS POR REPRESENTANTE" + " de " + dtoc(dINI) + " a " + dtoc(dFIM)

   qmensa("")

   // ESTABELECE RELACOES ENTRE ARQUIVOS ____________________________________
   nANO := strzero(year(dFIM) - 1,4)

   sANO := "01/01/"+nANO

   dINI_ANT := ctod(strzero(day(dINI),2)+"/"+strzero(month(dINI),2)+"/"+nANO)
   
   dBissexto := qinimes(dFim)
   dBissexto := ctod(strzero(day(dBissexto),2)+"/"+strzero(month(dBissexto),2)+"/"+nANO)
   dFIM_ANT  := qfimMes(dBissexto) 
   

   dINI_ACU := ctod(sANO)
   dFIM_ACU := qfimMes(dBissexto)


   sANO := "01/01/"+strzero(year(dFIM),4)
   
   dATUAL_INI := ctod(sANO)
   dATUAL_FIM := dFIM

   FAT->(dbsetorder(2)) // data de saida
   FAT->(dbgotop())
   set softseek on
   FAT->(Dbseek(dtos(dINI_ACU)))
   set softseek off
   ITEN_FAT->(dbsetorder(2))

   //qmensa("Data................: "+ dtoc(dINI) + " a "+dtoc(dFIM) )
   //qinkey(0)
   //qmensa("Ano Atual Acumulado.: "+ dtoc(dATUAL_INI) + " a "+dtoc(dATUAL_FIM) )
   //qinkey(0)
   
   //qmensa("Ano anterior Data...: "+ dtoc(dINI_ANT) + " a "+dtoc(dFIM_ANT) )
   //qinkey(0)
   
   //qmensa("Ano anterior Acum...: "+ dtoc(dINI_ACU) + " a "+dtoc(dFIM_ACU) )
   //qinkey(0)


   INVENT->(dbsetorder(4))
   PROD->(dbsetorder(4))


return .T.

static function i_impressao

   if cTIPO == "1"
      if ! qinitprn() ; return  ; endif  
      i_impre_prn()
   elseif cTIPO == "2"
      i_impre_cli("REPRESENTANTE","REPRES")
   else
      i_impre_cli("SUPERVISOR","RESP_REP")
   endif


return


/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impre_prn
    local nTOTAL     := 0
    local nDESC      := 0
    local nTOT_GER   := 0
    local nTOT_COM   := 0
    local nCONT      := 0
    local nCOMISS    := 0
    local nPERC      := 0
    local nQUANT     := 0
    local nTOT_QUANT := 0
    local cPROD      := 0
    local nUF_QUANT  := 0
    local nUF_VALOR  := 0
    local aFAT       := {}
    local asFAT      := {}
    local fDATA_VEND := ctod("")
    local fVENC      := ctod("")
    local lTEM := .T.
    local nREP_COM := 0
    local nCOM_ITEM := 0

    FI565->(__dbzap())

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________
    lTEM := .F.

   do while ! FAT->(eof())//  .and. FAT->Dt_emissao >= dINI .and. FAT->Dt_emissao <= dFIM  // condicao principal de loop

      CLI1->(dbseek(FAT->Cod_cli))
      CGM->(dbseek(CLI1->cgm_ent))

      if ! empty(cVEND)
         if CLI1->Cod_repres != cVEND
            FAT->(dbskip())
            loop
         endif
      endif

      if ! empty(cUFS)
         if CGM->Estado != cUFS
            FAT->(dbskip())
            loop
         endif
      endif

      if ! empty(cCGM)
         if CLI1->Cgm_ent != cCGM
            FAT->(dbskip())
            loop
         endif
      endif

      if FAT->Cancelado
         FAT->(Dbskip())
         loop
      endif

      if empty(FAT->Num_fatura) .and. FAT->Es == "S"
         FAT->(Dbskip())
         loop
      endif

      if ! left(FAT->Cod_cfop,3) $ "510-511-512-610-611-612-120-220-540-541-640-641-530-531-630-631-241-141"
         FAT->(dbskip())
         loop
      endif

      if FAT->Dt_emissao < dINI_ACU .or. FAT->Dt_emissao > dFIM
         FAT->(dbskip())
         loop
      endif

      qmensa("Aguarde... Somando faturamento... " + dtoc(FAT->dt_emissao))

      nREP_COM := 0
	  nTotal := 0

      ITEN_FAT->(Dbgotop())
      ITEN_FAT->(Dbseek(FAT->Codigo))
      do while ITEN_FAT->Num_fat == FAT->Codigo .and. ! ITEN_FAT->(eof())

          nTOTAL += ITEN_FAT->Quantidade * ITEN_FAT->Vl_unitar
          lTEM := .T.
          ITEN_FAT->(Dbskip())
      enddo

      if FI565->(dbseek(CLI1->Cod_repres))
         if FI565->(qrlock())
             if ! empty(CLI1->Cod_repres)
                i_grava(CLI1->cod_repres,FAT->Dt_emissao,nTOTAL,FAT->Es)
             endif
             FI565->(Qunlock())
         endif
         //FI565->(dbcommit())

      else
         if ! empty(CLI1->Cod_repres)

            if FI565->(qappend())
               i_grava(CLI1->cod_repres,FAT->Dt_emissao,nTOTAL,FAT->Es)
            endif
         endif
         //FI565->(dbcommit())
      endif

      nTOTAL := 0
      nDESC  := 0
      nREP_COM := 0
      FAT->(dbskip())

   enddo


   PEND->(dbsetorder(2)) // data de saida
   PEND->(dbgotop())
   set softseek on
   PEND->(Dbseek(dtos(dINI_ACU)))
   set softseek off
   ITEM_PEN->(dbsetorder(2))


   do while ! PEND->(eof())

      CLI1->(dbseek(PEND->Cod_cli))
      CGM->(dbseek(CLI1->cgm_ent))

      if ! empty(cVEND)
         if CLI1->Cod_repres != cVEND
            PEND->(dbskip())
            loop
         endif
      endif

      if ! empty(cUFS)
         if CGM->Estado != cUFS
            PEND->(dbskip())
            loop
         endif
      endif

      if ! empty(cCGM)
         if CLI1->Cgm_ent != cCGM
            PEND->(dbskip())
            loop
         endif
      endif



      if ! left(PEND->Cod_cfop,3) $ "510-511-512-540-610-611-612-640-120-220-241-141"
         PEND->(dbskip())
         loop
      endif

      qgirabarra()


      qmensa("Aguarde... Somando Pendencias... " + dtoc(PEND->dt_emissao))

      if PEND->Dt_emissao < dINI_ACU .or. PEND->Dt_emissao > dFIM
         PEND->(dbskip())
         loop
      endif

      nREP_COM := 0

      ITEM_PEN->(Dbgotop())
      ITEM_PEN->(Dbseek(PEND->Codigo))
      do while ITEM_PEN->Cod_pend == PEND->Codigo .and. ! ITEM_PEN->(eof())

          nTOTAL += ITEM_PEN->Quantidade * ITEM_PEN->Vl_unitar
          lTEM := .T.
          ITEM_PEN->(Dbskip())
      enddo

      if FI565->(dbseek(CLI1->Cod_repres))
         if FI565->(qrlock())
            if ! empty(CLI1->Cod_repres)
               i_grava_pend(CLI1->cod_repres,PEND->Dt_emissao,nTOTAL,PEND->Es)
            endif

            FI565->(Qunlock())
         endif
         //FI565->(dbcommit())

      else
         if ! empty(CLI1->Cod_repres)
            if FI565->(qappend())
               i_grava_pend(CLI1->cod_repres,PEND->Dt_emissao,nTOTAL,PEND->Es)
            endif
         endif
         //FI565->(dbcommit())
      endif

      nTOTAL := 0
      nDESC  := 0
      nREP_COM := 0
      PEND->(dbskip())

   enddo

   //FI565->(Dbcommit())

   FAT->(dbsetfilter({|| empty(Num_fatura) .and. FAT->Es == "S"} ))
   FAT->(dbsetorder(2)) // data de saida
   FAT->(dbgotop())
   set softseek on
   FAT->(Dbseek(dtos(dINI_ACU)))
   set softseek off
   ITEN_FAT->(dbsetorder(2))


   do while ! FAT->(eof())//  .and. FAT->Dt_emissao >= dINI .and. FAT->Dt_emissao <= dFIM  // condicao principal de loop

      CLI1->(dbseek(FAT->Cod_cli))
      CGM->(dbseek(CLI1->cgm_ent))


      if ! empty(cVEND)
         if CLI1->Cod_repres != cVEND
            FAT->(dbskip())
            loop
         endif
      endif

      if ! empty(cUFS)
         if CGM->Estado != cUFS
            FAT->(dbskip())
            loop
         endif
      endif

      if ! empty(cCGM)
         if CLI1->Cgm_ent != cCGM
            FAT->(dbskip())
            loop
         endif
      endif


      if FAT->Cancelado
         FAT->(Dbskip())
         loop
      endif

      if ! left(FAT->Cod_cfop,3) $ "510-511-512-540-610-611-612-640-120-220-141-241"
         FAT->(dbskip())
         loop
      endif

      qgirabarra()


      qmensa("Aguarde... Somando faturamento... " + dtoc(FAT->dt_emissao))

      if FAT->Dt_emissao < dINI_ACU .or. FAT->Dt_emissao > dFIM
         FAT->(dbskip())
         loop
      endif

      nREP_COM := 0

      ITEN_FAT->(Dbgotop())
      ITEN_FAT->(Dbseek(FAT->Codigo))
      do while ITEN_FAT->Num_fat == FAT->Codigo .and. ! ITEN_FAT->(eof())

          nTOTAL += ITEN_FAT->Quantidade * ITEN_FAT->Vl_unitar
          lTEM := .T.
          ITEN_FAT->(Dbskip())
      enddo

      if FI565->(dbseek(CLI1->Cod_repres))
         if FI565->(qrlock())
            if ! empty(CLI1->Cod_repres)
               i_grava_pend(CLI1->cod_repres,FAT->Dt_emissao,nTOTAL,FAT->Es)
            endif
            FI565->(Qunlock())

         endif
         //FI565->(dbcommit())

      else
         if ! empty(CLI1->Cod_repres)
            if FI565->(qappend())
               i_grava_pend(CLI1->cod_repres,FAT->Dt_emissao,nTOTAL,FAT->Es)
            endif
         endif
         //FI565->(dbcommit())
      endif

      nTOTAL := 0
      nDESC  := 0
      nREP_COM := 0
      FAT->(dbskip())

   enddo

   cTITULO2 := "Repres.:"+padc(cRepres,30)+"   Estado:"+padc(cEstado,30)+"   Cidade:"+rtrim(cCidade)


   //FI565->(Dbcommit())

   FAT->(DbClearFilter())

   i_repres()

   nQUANT := 0
   nTOTAL := 0
   nPERC  := 0

   qstopprn(.F.)

return




static function i_grava(cCOD_REPRES,dDATA,nVALOR,cSAIDA)

      if dDATA >= dINI_ANT .and. dDATA <= dFIM_ANT
         replace FI565->Cod_repres with cCOD_REPRES
         if cSAIDA == "S"
            replace FI565->Anter      with FI565->Anter + nVALOR
         else
            replace FI565->Anter      with FI565->Anter - nVALOR

         endif
      endif


      if dDATA >= dINI_ACU .and. dDATA <= dFIM_ACU
         replace FI565->Cod_repres with cCOD_REPRES
         if cSAIDA == "S"
            replace FI565->TT_Anter      with FI565->TT_Anter + nVALOR
         else
            replace FI565->TT_Anter      with FI565->TT_Anter - nVALOR

         endif
      endif


      if dDATA >= dINI .and. dDATA <= dFIM
         replace FI565->Cod_repres with cCOD_REPRES
         if cSAIDA == "S"
            replace FI565->Corrent      with FI565->Corrent + nVALOR
         else
            replace FI565->corrent      with FI565->Corrent - nVALOR

         endif
      endif


      if dDATA >= dATUAL_INI .and. dDATA <= dATUAL_FIM
         replace FI565->Cod_repres with cCOD_REPRES
         if cSAIDA == "S"
            replace FI565->TT_corrent      with FI565->TT_Corrent + nVALOR
         else
            replace FI565->TT_corrent      with FI565->TT_Corrent - nVALOR

         endif
      endif


return


static function i_grava_pend(cCOD_REPRES,dDATA,nVALOR,cSAIDA)

      if dDATA >= dINI_ANT .and. dDATA <= dFIM_ANT
         replace FI565->Cod_repres with cCOD_REPRES
         if cSAIDA == "S"
            replace FI565->Ped_Anter      with FI565->Ped_Anter + nVALOR
         else
            replace FI565->Ped_Anter      with FI565->Ped_Anter - nVALOR

         endif
      endif


      if dDATA >= dINI_ACU .and. dDATA <= dFIM_ACU
         replace FI565->Cod_repres with cCOD_REPRES
         if cSAIDA == "S"
            replace FI565->TT_Ped_Ant      with FI565->TT_Ped_Ant + nVALOR
         else
            replace FI565->TT_Ped_ant      with FI565->TT_Ped_Ant - nVALOR

         endif
      endif


      if dDATA >= dINI .and. dDATA <= dFIM
         replace FI565->Cod_repres with cCOD_REPRES
         if cSAIDA == "S"
            replace FI565->Ped_cor      with FI565->Ped_cor + nVALOR
         else
            replace FI565->Ped_cor      with FI565->Ped_cor - nVALOR

         endif
      endif


      if dDATA >= dATUAL_INI .and. dDATA <= dATUAL_FIM
         replace FI565->Cod_repres with cCOD_REPRES
         if cSAIDA == "S"
            replace FI565->TT_Ped_cor      with FI565->TT_ped_cor + nVALOR
         else
            replace FI565->TT_ped_cor      with FI565->TT_ped_cor - nVALOR

         endif
      endif

return

static function i_repres
local nANTER,nCORRENT :=0
local nTANT , nTCOR

local nPedCor     := 0
local nFatCor     := 0
local nPedAcuCor  := 0
local nFatAcuCor  := 0

local nPedAnt     := 0
local nFatAnt     := 0
local nPedAcuAnt  := 0
local nFatAcuAnt  := 0


   nTANT := 0
   nTCOR := 0

   FI565->(dbsetfilter({|| FI565->Cod_repres != "     " }))
   FI565->(Dbgotop())

   zVEND  := FI565->Cod_repres


   do while  ! FI565->(eof())

       if ! qlineprn() ; exit ; endif

       if XPAGINA == 0
          @prow()+1,0 say " "
          qpageprn()
          @ prow()+1,0 say cTITULO  + "565"
          @ prow()+1,0 say cTITULO2

          @ prow()+2, 0       say "Representante"
          @ prow()  , pcol()  say chr(9)+"Pedido"
          @ prow()  , pcol()  say chr(9)+""

          @ prow()  , pcol()  say chr(9)
          @ prow()  , pcol()  say chr(9)

          @ prow()  , pcol()  say chr(9)+"Faturado"
          @ prow()  , pcol()  say chr(9)+""

          @ prow()  , pcol()  say chr(9)
          @ prow()  , pcol()  say chr(9)

          @ prow()  , pcol()  say chr(9)+"Pedido Acum."
          @ prow()  , pcol()  say chr(9)+""

          @ prow()  , pcol()  say chr(9)
          @ prow()  , pcol()  say chr(9)

          @ prow()  , pcol()  say chr(9)+"Faturado Acum."
          @ prow()  , pcol()  say chr(9)+""

          @ prow()+1, 0  say ""
          @ prow()  , pcol()  say chr(9)+strzero(month(dFIM_ANT),2)+"/"+strzero(year(dFIM_ANT),4)
          @ prow()  , pcol()  say chr(9)+strzero(month(dFIM),2)+"/"+strzero(year(dFIM),4)

          @ prow()  , pcol()  say chr(9)
          @ prow()  , pcol()  say chr(9)

          @ prow()  , pcol()  say chr(9)+strzero(month(dFIM_ANT),2)+"/"+strzero(year(dFIM_ANT),4)
          @ prow()  , pcol()  say chr(9)+strzero(month(dFIM),2)+"/"+strzero(year(dFIM),4)

          @ prow()  , pcol()  say chr(9)
          @ prow()  , pcol()  say chr(9)

          @ prow()  , pcol()  say chr(9)+ "01/"+strzero(year(dFIM_ANT),4)+ " a " +strzero(month(dFIM_ANT),2)+"/"+strzero(year(dFIM_ANT),4)
          @ prow()  , pcol()  say chr(9)+ "01/"+strzero(year(dFIM),4)+ " a " +strzero(month(dFIM),2)+"/"+strzero(year(dFIM),4)

          @ prow()  , pcol()  say chr(9)
          @ prow()  , pcol()  say chr(9)

          @ prow()  , pcol()  say chr(9)+ "01/"+strzero(year(dFIM_ANT),4)+ " a " +strzero(month(dFIM_ANT),2)+"/"+strzero(year(dFIM_ANT),4)
          @ prow()  , pcol()  say chr(9)+ "01/"+strzero(year(dFIM),4)+ " a " +strzero(month(dFIM),2)+"/"+strzero(year(dFIM),4)

          @ prow()+1,0 say ""
       endif

       nPerc:= 0

       REPRES->(dbseek(FI565->cod_repres))

       nANTER   := FI565->Ped_anter + FI565->Anter
       nCORRENT := FI565->Ped_cor   + FI565->Corrent

       nPedAnt += FI565->Ped_anter + FI565->Anter
       nPedCor += FI565->Ped_cor   + FI565->corrent

       nTANT += FI565->Ped_anter + FI565->Anter
       nTCOR += FI565->Ped_cor   + FI565->Corrent

       @ prow()+1, 00  say left(REPRES->Razao,50)                          //Data de Emissao

       /////////////////////////////////////////////////////////////
       //Pedido no Mes______________________________________________

       @ prow()  , pcol()  say chr(9)+transf(nAnter,"@E 999,999,999.99") //Valor da Nota
       @ prow()  , pcol()  say chr(9)+transf(nCorrent,"@E 999,999,999.99") //Valor da Nota

       if nAnter > nCorrent

          nPerc := ( (nAnter-nCorrent) / nAnter) * 100
          @ prow() , pcol()  say chr(9)+transf(nPERC*(-1),"@E 9999.99")+" %"


       else
          nPerc := ( (nCorrent/nAnter) -1) * 100
          if nANTER == 0
             nPERC := nPERC * (-1)
          endif
          @ prow() , pcol()  say chr(9)+transf(nPERC,"@E 9999.99")+" %"

       endif

       @ prow() , pcol()  say chr(9)


       /////////////////////////////////////////////////////////////
       //Faturado no Mes___________________________________________

       nFatAnt += FI565->Anter
       nFatCor += FI565->corrent


       @ prow()  , pcol()  say chr(9)+transf(FI565->Anter,"@E 999,999,999.99") //Valor da Nota
       @ prow()  , pcol()  say chr(9)+transf(FI565->Corrent,"@E 999,999,999.99") //Valor da Nota

       if FI565->Anter > FI565->Corrent

          nPerc := ( (FI565->Anter-FI565->Corrent) / FI565->Anter) * 100
          @ prow() , pcol()  say chr(9)+transf(nPERC*(-1),"@E 9999.99")+" %"


       else
          nPerc := ( (FI565->Corrent/FI565->Anter) -1) * 100
          if FI565->Anter == 0
             nPERC := nPERC * (-1)
          endif

          @ prow() , pcol()  say chr(9)+transf(nPERC,"@E 9999.99")+" %"

       endif

       @ prow() , pcol()  say chr(9)

       /////////////////////////////////////////////////////////////
       //Pedido Acumulado__________________________________________

       nPedAcuAnt += FI565->TT_Anter + FI565->TT_Ped_ant
       nPedacuCor += FI565->TT_corrent + FI565->TT_Ped_cor

       @ prow()  , pcol()  say chr(9)+transf(FI565->TT_anter + FI565->TT_Ped_ant,"@E 999,999,999.99") //Valor da Nota
       @ prow()  , pcol()  say chr(9)+transf(FI565->TT_Corrent + FI565->TT_Ped_cor,"@E 999,999,999.99") //Valor da Nota

       if (FI565->TT_anter + FI565->TT_Ped_ant) > FI565->TT_Corrent + FI565->TT_Ped_cor
          nPerc :=  ( (FI565->TT_anter + FI565->TT_Ped_ant)-(FI565->TT_Corrent + FI565->TT_Ped_cor) ) / (FI565->TT_anter + FI565->TT_Ped_ant) * 100
          @ prow() , pcol()  say chr(9)+transf(nPERC*(-1),"@E 9999.99")+" %"
       else
          nPerc := ( (FI565->TT_Corrent + FI565->TT_Ped_cor)/(FI565->TT_anter + FI565->TT_Ped_ant) -1) * 100
          if (FI565->TT_anter + FI565->TT_Ped_ant) == 0
             nPERC := nPERC * (-1)
          endif
          @ prow() , pcol()  say chr(9)+transf(nPERC,"@E 9999.99")+" %"
       endif

       @ prow() , pcol()  say chr(9)


       /////////////////////////////////////////////////////////////////
       //Fatramento Acumulado____________________________________________
       nFatAcuAnt += FI565->TT_Anter
       nFatAcuCor += FI565->TT_corrent


       @ prow()  , pcol()  say chr(9)+transf(FI565->TT_Anter,"@E 999,999,999.99") //Valor da Nota
       @ prow()  , pcol()  say chr(9)+transf(FI565->TT_Corrent,"@E 999,999,999.99") //Valor da Nota

       if FI565->TT_anter > FI565->TT_corrent

          nPerc := ( (FI565->TT_anter-FI565->TT_corrent) / FI565->TT_anter) * 100
          @ prow() , pcol()  say chr(9)+transf(nPERC*(-1),"@E 9999.99")+" %"


       else
          nPerc := ( (FI565->TT_Corrent/FI565->TT_anter) -1) * 100
          if FI565->TT_Anter == 0
             nPERC := nPERC * (-1)
          endif

          @ prow() , pcol()  say chr(9)+transf(nPERC,"@E 9999.99")+" %"

       endif

       nANTER   := 0
       nCORRENT := 0

       FI565->(dbskip())

   enddo

   @ prow()+1, 00  say "Total Geral.:"


   @ prow()  , pcol()  say chr(9)+transf(nPedAnt,"@E 999,999,999.99") //Valor da Nota
   @ prow()  , pcol()  say chr(9)+transf(nPedCor,"@E 999,999,999.99") //Valor da Nota
   print_perc(nPedant,nPedcor)
   @ prow() , pcol()  say chr(9)

   @ prow()  , pcol()  say chr(9)+transf(nFatAnt,"@E 999,999,999.99") //Valor da Nota
   @ prow()  , pcol()  say chr(9)+transf(nFatCor,"@E 999,999,999.99") //Valor da Nota
   print_perc(nFatAnt,nFatCor)
   @ prow() , pcol()  say chr(9)

   @ prow()  , pcol()  say chr(9)+transf(nPedAcuAnt,"@E 999,999,999.99") //Valor da Nota
   @ prow()  , pcol()  say chr(9)+transf(nPedacuCor,"@E 999,999,999.99") //Valor da Nota
   print_perc(nPedAcuAnt,nPedAcuCor)
   @ prow() , pcol()  say chr(9)

   @ prow()  , pcol()  say chr(9)+transf(nFatAcuAnt,"@E 999,999,999.99") //Valor da Nota
   @ prow()  , pcol()  say chr(9)+transf(nFatAcuCor,"@E 999,999,999.99") //Valor da Nota
   print_perc(nFatAcuAnt,nFatAcuCor)
   @ prow() , pcol()  say chr(9)

   XPAGINA := 0
   nPerc:= 0

return

static function i_total(nANTER,nCORRENT)
local nPERC := 0

  @ prow()+1, 00      say "Total"                          //Data de Emissao
  @ prow()  , pcol()  say chr(9)+transf(nAnter,"@E 999,999,999.99") //Valor da Nota
  @ prow()  , pcol()  say chr(9)+transf(nCorrent,"@E 999,999,999.99") //Valor da Nota

  if nAnter > nCorrent

     nPerc := ( (nAnter-nCorrent) / nAnter) * 100
     @ prow() , pcol()  say chr(9)+transf(nPERC*(-1),"@E 9999.99")+" %"


  else
     nPerc := ( (nCorrent/nAnter) -1) * 100
     if nANTER == 0
        nPERC := nPERC * (-1)
     endif
     @ prow() , pcol()  say chr(9)+transf(nPERC,"@E 9999.99")+" %"

  endif

return

static function i_impre_cli(cClasse,cFile)
    local nTOTAL     := 0
    local nDESC      := 0
    local nTOT_GER   := 0
    local nTOT_COM   := 0
    local nCONT      := 0
    local nCOMISS    := 0
    local nPERC      := 0
    local nQUANT     := 0
    local nTOT_QUANT := 0
    local cPROD      := 0
    local nUF_QUANT  := 0
    local nUF_VALOR  := 0
    local aFAT       := {}
    local asFAT      := {}
    local fDATA_VEND := ctod("")
    local fVENC      := ctod("")
    local lTEM := .T.
    local nREP_COM := 0
    local nCOM_ITEM := 0

    FI565->(__dbzap())
    FI565->(dbsetorder(2))


   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________
    lTEM := .F.
 

   do while ! FAT->(eof())  //.and. FAT->Dt_emissao <= dFIM

//      CLI1->(dbseek(FAT->Cod_cli))

      CLI1->(dbseek(FAT->Cod_cli))
      CGM->(dbseek(CLI1->cgm_ent))

      if ! empty(cVEND)
         if CLI1->Cod_repres != cVEND
            FAT->(dbskip())
            loop
         endif
      endif

      if ! empty(cUFS)
         if CGM->Estado != cUFS
            FAT->(dbskip())
            loop
         endif
      endif

      if ! empty(cCGM)
         if CLI1->Cgm_ent != cCGM
            FAT->(dbskip())
            loop
         endif
      endif


      if FAT->Cancelado
         FAT->(Dbskip())
         loop
      endif

      if empty(FAT->Num_fatura) .and. FAT->Es == "S"
         FAT->(Dbskip())
         loop
      endif

      if ! left(FAT->Cod_cfop,3) $ "510-511-512-540-610-611-612-640-120-220-141-241"
         FAT->(dbskip())
         loop
      endif
	  
	  if FAT->Dt_emissao < dINI_ACU .or. FAT->Dt_emissao > dFIM
         FAT->(dbskip())
         loop
      endif

      qmensa("Aguarde... Somando faturamento... " + dtoc(FAT->dt_emissao))

      nREP_COM := 0

      ITEN_FAT->(Dbseek(FAT->Codigo))
      do while ITEN_FAT->Num_fat == FAT->Codigo .and. ! ITEN_FAT->(eof())
          nTOTAL += ITEN_FAT->Quantidade * ITEN_FAT->Vl_unitar
          lTEM := .T.
          ITEN_FAT->(Dbskip())
      enddo

      FI565->(dbsetorder(2))
      if FI565->(dbseek(FAT->Cod_cli))
	     i_selecionaGravadorFaturado(cClasse,nTotal)
	     
         FI565->(Qunlock())
      else
         if FI565->(qappend())
            i_selecionaGravadorFaturado(cClasse,nTotal)
         endif
      endif

      nTOTAL := 0
      nDESC  := 0
      nREP_COM := 0
      FAT->(dbskip())

   enddo


   PEND->(dbsetorder(2)) // data de saida
   PEND->(dbgotop())
   set softseek on
   PEND->(Dbseek(dtos(dINI_ACU)))
   set softseek off
   ITEM_PEN->(dbsetorder(2))


   do while ! PEND->(eof()) //.and. PEND->dt_emissao <= dFIM

      CLI1->(dbseek(PEND->Cod_cli))
      CGM->(dbseek(CLI1->cgm_ent))

      if ! empty(cVEND)
         if CLI1->Cod_repres != cVEND
            PEND->(dbskip())
            loop
         endif
      endif

      if ! empty(cUFS)
         if CGM->Estado != cUFS
            PEND->(dbskip())
            loop
         endif
      endif

      if ! empty(cCGM)
         if CLI1->Cgm_ent != cCGM
            PEND->(dbskip())
            loop
         endif
      endif

      if ! left(PEND->Cod_cfop,3) $ "510-511-512-540-610-611-612-640-120-220-241-141"
         PEND->(dbskip())
         loop
      endif

      qgirabarra()


      qmensa("Aguarde... Somando Pendencias... " + dtoc(PEND->dt_emissao))

      if PEND->Dt_emissao < dINI_ACU .or. PEND->Dt_emissao > dFIM
         PEND->(dbskip())
         loop
      endif

      nREP_COM := 0

      ITEM_PEN->(Dbgotop())
      ITEM_PEN->(Dbseek(PEND->Codigo))
      do while ITEM_PEN->Cod_pend == PEND->Codigo .and. ! ITEM_PEN->(eof())

          nTOTAL += ITEM_PEN->Quantidade * ITEM_PEN->Vl_unitar
          lTEM := .T.
          ITEM_PEN->(Dbskip())
      enddo

      FI565->(dbsetorder(2))
      if FI565->(dbseek(PEND->Cod_cli))
         if FI565->(qrlock())
			 i_selecionaGravadorPedido(cClasse,"PEND",nTotal)
             FI565->(Qunlock())
         endif
      else
         if FI565->(qappend())
		    i_selecionaGravadorPedido(cClasse,"PEND",nTotal)
         endif
      endif

      nTOTAL := 0
      nDESC  := 0
      nREP_COM := 0
      PEND->(dbskip())

   enddo

   //FI565->(Dbcommit())

   FAT->(dbsetfilter({|| empty(Num_fatura) .and. FAT->Es == "S"} ))
   FAT->(dbsetorder(2)) // data de saida
   FAT->(dbgotop())
   set softseek on
   FAT->(Dbseek(dtos(dINI_ACU)))
   set softseek off
   ITEN_FAT->(dbsetorder(2))


   do while ! FAT->(eof()) //.and. FAT->Dt_emissao <= dFim   //conddicao principal de loop

      CLI1->(dbseek(FAT->Cod_cli))
      CGM->(dbseek(CLI1->cgm_ent))

      if ! empty(cVEND)
         if C->Cod_repres != cVEND
            FAT->(dbskip())
            loop
         endif
      endif

      if ! empty(cUFS)
         if CGM->Estado != cUFS
            FAT->(dbskip())
            loop
         endif
      endif

      if ! empty(cCGM)
         if CLI1->Cgm_ent != cCGM
            FAT->(dbskip())
            loop
         endif
      endif


      if FAT->Cancelado
         FAT->(Dbskip())
         loop
      endif

      if ! left(FAT->Cod_cfop,3) $ "510-511-512-540-610-611-612-640-120-220-141-241"
         FAT->(dbskip())
         loop
      endif

      qgirabarra()


      qmensa("Aguarde... Somando faturamento... " + dtoc(FAT->dt_emissao))

      if FAT->Dt_emissao < dINI_ACU .or. FAT->Dt_emissao > dFIM
         FAT->(dbskip())
         loop
      endif

      nREP_COM := 0

      ITEN_FAT->(Dbgotop())
      ITEN_FAT->(Dbseek(FAT->Codigo))
      do while ITEN_FAT->Num_fat == FAT->Codigo .and. ! ITEN_FAT->(eof())

          nTOTAL += ITEN_FAT->Quantidade * ITEN_FAT->Vl_unitar
          lTEM := .T.
          ITEN_FAT->(Dbskip())
      enddo

      FI565->(dbsetorder(2))
      if FI565->(dbseek(FAT->Cod_cli))
         if FI565->(qrlock())
		     i_selecionaGravadorPedido(cClasse,"FAT",nTotal)
             //i_cgrava_pend(FAT->Cod_cli,CLI1->cod_repres,FAT->Dt_emissao,nTOTAL,FAT->Es)
             FI565->(Qunlock())
         endif
         //FI565->(dbcommit())

      else
         if FI565->(qappend())
            //i_cgrava_pend(FAT->Cod_cli,CLI1->cod_repres,FAT->Dt_emissao,nTOTAL,FAT->Es)
			i_selecionaGravadorPedido(cClasse,"FAT",nTotal)
         endif
         //FI565->(dbcommit())
      endif

      nTOTAL := 0
      nDESC  := 0
      nREP_COM := 0
      FAT->(dbskip())

   enddo
  // FI565->(Dbcommit())

   FAT->(DbClearFilter())

   //cTITULO2 := "Repres.:"+cRepres+"Estado:"+cEstado+"Cidade:"+rtrim(cCidade)
   //cTITULO2 := "Repres.:"+padc(cRepres,30)+"    Estado:"+padc(cEstado,30)+"    Cidade:"+rtrim(cCidade)



   i_cliente(cClasse,cFile)

   nQUANT := 0
   nTOTAL := 0
   nPERC  := 0

return




static function i_cgrava(cCOD_CLI,cCOD_REPRES,dDATA,nVALOR,cSAIDA)
local lBlank := .T.


      if dDATA >= dINI_ANT .and. dDATA <= dFIM_ANT
         replace FI565->Cod_repres with cCOD_REPRES
         replace FI565->Cod_cli    with cCOD_CLI

         if cSAIDA == "S"
            replace FI565->Anter      with FI565->Anter + nVALOR
         else
            replace FI565->Anter      with FI565->Anter - nVALOR

         endif
         lBlank := .F.
      endif

      if dDATA >= dINI_ACU .and. dDATA <= dFIM_ACU
         replace FI565->Cod_repres with cCOD_REPRES
         replace FI565->Cod_cli    with cCOD_CLI
         if cSAIDA == "S"
            replace FI565->TT_Anter      with FI565->TT_Anter + nVALOR
         else
            replace FI565->TT_Anter      with FI565->TT_Anter - nVALOR

         endif
         lBlank := .F.

      endif


      if dDATA >= dINI .and. dDATA <= dFIM
         replace FI565->Cod_repres with cCOD_REPRES
         replace FI565->Cod_cli    with cCOD_CLI
         if cSAIDA == "S"
            replace FI565->Corrent      with FI565->Corrent + nVALOR
         else
            replace FI565->corrent      with FI565->Corrent - nVALOR

         endif
         lBlank := .F.

      endif


      if dDATA >= dATUAL_INI .and. dDATA <= dATUAL_FIM
         replace FI565->Cod_repres with cCOD_REPRES
         replace FI565->Cod_cli    with cCOD_CLI
         if cSAIDA == "S"
            replace FI565->TT_corrent      with FI565->TT_Corrent + nVALOR
         else
            replace FI565->TT_corrent      with FI565->TT_Corrent - nVALOR

         endif
         lBlank := .F.

      endif

      if empty(Fi565->Cod_cli) .and. empty(FI565->cod_repres)
         FI565->(dbdelete())
      endif

return


static function i_cgrava_pend(cCOD_CLI,cCOD_REPRES,dDATA,nVALOR,cSAIDA)

      if dDATA >= dINI_ANT .and. dDATA <= dFIM_ANT
         replace FI565->Cod_repres with cCOD_REPRES
         replace FI565->Cod_cli    with cCOD_CLI

         if cSAIDA == "S"
            replace FI565->Ped_Anter      with FI565->Ped_Anter + nVALOR
         else
            replace FI565->Ped_Anter      with FI565->Ped_Anter - nVALOR

         endif
      endif


      if dDATA >= dINI_ACU .and. dDATA <= dFIM_ACU
         replace FI565->Cod_repres with cCOD_REPRES
         replace FI565->Cod_cli    with cCOD_cli
         if cSAIDA == "S"
            replace FI565->TT_Ped_Ant      with FI565->TT_Ped_Ant + nVALOR
         else
            replace FI565->TT_Ped_ant      with FI565->TT_Ped_Ant - nVALOR

         endif
      endif


      if dDATA >= dINI .and. dDATA <= dFIM
         replace FI565->Cod_repres with cCOD_REPRES
         replace FI565->Cod_cli    with cCOD_CLI
         if cSAIDA == "S"
            replace FI565->Ped_cor      with FI565->Ped_cor + nVALOR
         else
            replace FI565->Ped_cor      with FI565->Ped_cor - nVALOR

         endif
      endif


      if dDATA >= dATUAL_INI .and. dDATA <= dATUAL_FIM
         replace FI565->Cod_repres with cCOD_REPRES
         replace FI565->Cod_cli    with cCOD_CLI
         if cSAIDA == "S"
            replace FI565->TT_Ped_cor      with FI565->TT_ped_cor + nVALOR
         else
            replace FI565->TT_ped_cor      with FI565->TT_ped_cor - nVALOR

         endif
      endif

      if empty(Fi565->Cod_cli) .and. empty(FI565->cod_repres)
         FI565->(dbdelete())
      endif

return


static function i_cliente(cClasse,cFile)
local nANTER,nCORRENT :=0
local nTANT , nTCOR
local zREPRES := ""

local nPedAnt := 0
local nPedCor := 0

local nFatAnt := 0
local nFatCor := 0

local nPedAcuAnt := 0
local nPedAcuCor := 0

local nFatAcuAnt := 0
local nFatAcuCor := 0

local cBuffer := ""
local nFile := 0
local cFileName := ""
local nLinha := 0

   nTANT := 0
   nTCOR := 0

   FI565->(dbsetorder(1))

   FI565->(Dbgotop())
   //alert(FI565->Cod_repres)

   zREPRES := FI565->Cod_repres
   
   REPRES->(dbseek(FI565->Cod_repres))
   RESP_REP->(dbseek(FI565->Cod_repres))
   
   cBuffer += xmlAbre(10,10,10,10)
   cBuffer += xmlStyles()
   cBuffer += xmlFechaStyles()
   cBuffer += xmlAbrePasta("RP"+rtrim((cFile)->Codigo + " " + iif(cFile == "REPRES",left(REPRES->Razao,22),left(RESP_REP->Nome,22))))
   cBuffer += cabec_xml()
   
   
   

   do while  ! FI565->(eof())
   
     

     nPerc:= 0

     CLI1->(dbseek(FI565->cod_cli))

     nANTER   := FI565->Ped_anter + FI565->Anter
     nCORRENT := FI565->Ped_cor   + FI565->Corrent

     nPedAnt +=  (FI565->Ped_anter + FI565->Anter)
     nPedCor +=  (FI565->Ped_cor   + FI565->Corrent)
	 
	 cBuffer += xmlAbreLinha()
	    nLinha++
	    cBuffer += xmlCell("String",rtrim(left(strtran(CLI1->Razao,"Ç","C"),50)),"Cliente")
		cBuffer += xmlCell("Number",alltrim(transf(nAnter,"@R 999999999.99")),"s66")
		cBuffer += xmlCell("Number",alltrim(transf(nCorrent,"@R 999999999.99")),"s66")
		cBuffer += print_perc_xml(nAnter,nCorrent,"s66")

       ////////////////////////////////////////////////////////////////
       //Faturamento Corrente__________________________________________

       nANTER   := 0
       nCORRENT := 0

       nANTER   := FI565->Anter
       nCORRENT := FI565->Corrent

       nFatAnt +=  FI565->Anter
       nFatCor +=  FI565->Corrent

       cBuffer += xmlCell("Number",alltrim(transf(nAnter,"@R 999999999.99")),"s80")
       cBuffer += xmlCell("Number",alltrim(transf(nCorrent,"@R 999999999.99")),"s80")
       cBuffer += print_perc_xml(nAnter,nCorrent,"s80")

       ////////////////////////////////////////////////////////////////
       //Pedido Acumulado__________________________________________

       nANTER   := 0
       nCORRENT := 0

       nANTER   := FI565->TT_Anter   + FI565->TT_Ped_ant
       nCORRENT := FI565->TT_Corrent + FI565->TT_Ped_cor

       nPedAcuAnt +=  (FI565->TT_Anter   + FI565->TT_Ped_ant)
       nPedAcuCor +=  (FI565->TT_Corrent + FI565->TT_Ped_cor)
	   
       cBuffer += xmlCell("Number",alltrim(transf(nAnter,"@R 999999999.99")),"s66")
       cBuffer += xmlCell("Number",alltrim(transf(nCorrent,"@R 999999999.99")),"s66")
       cBuffer += print_perc_xml(nAnter,nCorrent,"s66")
	   cBuffer += print_diff_xml(nAnter,nCorrent,"s66")
	   //cBuffer += xmlCell("String","","s66")

       ////////////////////////////////////////////////////////////////
       //Faturamento Acumulado__________________________________________

       nANTER   := 0
       nCORRENT := 0

       nANTER   := FI565->TT_Anter
       nCORRENT := FI565->TT_Corrent

       nFatAcuAnt += FI565->TT_Anter
       nFatAcuCor += FI565->TT_Corrent
	   
       cBuffer += xmlCell("Number",alltrim(transf(nAnter,"@R 999999999.99")),"s80")
       cBuffer += xmlCell("Number",alltrim(transf(nCorrent,"@R 999999999.99")),"s80")
       cBuffer += print_perc_xml(nAnter,nCorrent,"s80")
	   cBuffer += print_diff_xml(nAnter,nCorrent,"s80")
	   //cBuffer += xmlCell("String","","s80")
       
	   CGM->(dbseek(CLI1->Cgm_ent))
	   
	   cBuffer += xmlCell("String",trim(Cgm->Municipio))
	   cBuffer += xmlCell("String",Cgm->Estado)
	 cBuffer += xmlFechaLinha()  

       nANTER   := 0
       nCORRENT := 0

       FI565->(dbskip())

       if FI565->Cod_repres != zREPRES
            
			REPRES->(dbseek(zREPRES))
            RESP_REP->(dbseek(zREPRES))
		  
            cBuffer += xmlAbreLinha()
            cBuffer += xmlCell("String","TOTAL Do "+cClasse+".: "+strtran(rtrim(left(iif(cFile=="REPRES",REPRES->RAzao,RESP_REP->Nome),35)),"Ç","C"),"Cliente")

            cBuffer += xmlCell("Number",alltrim(transf(nPedAnt,"@R 999999999.99") ),"s66")
            cBuffer += xmlCell("Number",alltrim(transf(nPedCor,"@R 999999999.99") ),"s66")
            cBuffer += print_perc_xml(nPedAnt,nPedCor,"s66")
            //cBuffer += xmlCell("String","","s66")
			
            cBuffer += xmlCell("Number",alltrim(transf(nFatAnt,"@R 999999999.99") ),"s80")
            cBuffer += xmlCell("Number",alltrim(transf(nFatCor,"@R 999999999.99") ),"s80")
            cBuffer += print_perc_xml(nFatAnt,nFatCor,"s80")
            //cBuffer += xmlCell("String","","s80")
			
            cBuffer += xmlCell("Number",alltrim(transf(nPedAcuAnt,"@R 999999999.99") ),"s66")
            cBuffer += xmlCell("Number",alltrim(transf(nPedAcuCor,"@R 999999999.99") ),"s66")
            cBuffer += print_perc_xml(nPedAcuAnt,nPedAcuCor,"s66")
            cBuffer += xmlCell("String","","s66")
			
            cBuffer += xmlCell("Number",alltrim(transf(nFatAcuAnt,"@R 999999999.99") ),"s80")
            cBuffer += xmlCell("Number",alltrim(transf(nFatAcuCor,"@R 999999999.99") ),"s80")
            cBuffer += print_perc_xml(nFatAcuAnt,nFatAcuCor,"s80")
            cBuffer += xmlCell("String","","s80")
          cBuffer += xmlFechaLinha()
          cBuffer += xmlFechaPasta(4,1,nLinha+3,15,"O","C")	//De linha 4 col 1 a total+3, linha 15, ordena por O	em ordem crescente  

          zREPRES := FI565->Cod_repres
		  nLinha := 0
		  
          //(cFile)->(dbseek(zREPRES))
		  REPRES->(dbseek(FI565->Cod_repres))
          RESP_REP->(dbseek(FI565->Cod_repres))
		  
		  if FI565->(eof())
		      cBuffer += xmlAbrePasta("Fim")
		  else
             cBuffer += xmlAbrePasta(rtrim((cFile)->Codigo + " " +left(strtran(iif(cFile=="REPRES",REPRES->RAzao,RESP_REP->Nome),"Ç","C"),24)))
			 cBuffer += cabec_xml()
		  endif 

          nPedAnt := 0
          nPedCor := 0

          nFatAnt := 0
          nFatCor := 0

          nPedAcuAnt := 0
          nPedAcuCor := 0

          nFatAcuAnt := 0
          nFatAcuCor := 0

       endif

   enddo

   cBuffer += xmlFechaPasta()
   cBuffer += xmlFecha()
   
   cFileName := "Rel 565 por "+ iif(cFile=="REPRES","Representante","Supervisor") + " "+strzero(year(date()),4)+ " "+strzero(month(date()),2)+" "+strzero(day(date()),2)+ " - " + left(time(),2)+" "+substr(time(),4,2)+".xml"
   
   nFile := fCreate("C:\Qsystxt\"+cFileNAme,0)
   fWrite(nFile,cBuffer,len(cBuffer))
   fClose(nFile)
   alert("Arquivo gerado na pasta c:\qsystxt !")

   nPedAnt := 0
   nPedCor := 0

   nFatAnt := 0
   nFatCor := 0

   nPedAcuAnt := 0
   nPedAcuCor := 0

   nFatAcuAnt := 0
   nFatAcuCor := 0

   XPAGINA := 0
   nPerc:= 0

return

static function print_perc(nAnter,nCorrent)
local nPerc := 0

    if nAnter > nCorrent
       nPerc := ( (nAnter-nCorrent) / nAnter) * 100
       @ prow() , pcol()  say chr(9)+transf(nPERC*(-1),"@E 9999.99")+" %"
    else
       nPerc := ( (nCorrent/nAnter) -1) * 100
       if nANTER == 0
          nPERC := nPERC * (-1)
       endif
       @ prow() , pcol()  say chr(9)+transf(nPERC,"@E 9999.99")+" %"
    endif

return

static function print_perc_xml(nAnter,nCorrent,cStyle)
local nPerc := 0

    if nAnter > nCorrent
       nPerc := ( (nAnter-nCorrent) / nAnter) * 100
       xmlCell("Number",alltrim(transf(nPERC*(-1),"@R 99999999.99")),cStyle)
    else
       nPerc := ( (nCorrent/nAnter) -1) * 100
       if nANTER == 0
          nPERC := nPERC * (-1)
       endif
       xmlCell("Number",alltrim(transf(nPERC,"@R 99999999.99")),cStyle)
    endif

return

static function print_diff_xml(nAnter,nCorrent,cStyle)
       xmlCell("Number",alltrim(transf(nCorrent-nAnter,"@R 9999999999.99")),cStyle)
return

static function i_impre_supervisor
return

static function xmlStyles
local xml := ""
	 
   
   xml += '<Style ss:ID="Default" ss:Name="Normal">'+chr(13)+chr(10)
   xml += '<Alignment ss:Vertical="Bottom"/>'+chr(13)+chr(10)
   xml += '<Borders/>'+chr(13)+chr(10)
   xml += '<Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>'+chr(13)+chr(10)
   xml += '<Interior/>'+chr(13)+chr(10)
   xml += '<NumberFormat/>'+chr(13)+chr(10)
   xml += '<Protection/>'+chr(13)+chr(10)
   xml += '</Style>'+chr(13)+chr(10)
   
   xml += '<Style ss:ID="s66">'+chr(13)+chr(10)
   xml += '<Alignment ss:Horizontal="Right" ss:Vertical="Center" ss:WrapText="1"/>'+chr(13)+chr(10)
   xml += '<Borders>'+chr(13)+chr(10)
   xml += '<Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
   xml += '<Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
   xml += '<Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
   xml += '<Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
   xml += '</Borders>'+chr(13)+chr(10)
   xml += '<Font ss:FontName="Calibri" x:Family="Swiss" ss:Color="#000000"/>'+chr(13)+chr(10)
   xml += '<Interior ss:Color="#C5D9F1" ss:Pattern="Solid"/>'+chr(13)+chr(10)
   xml += '</Style>'+chr(13)+chr(10)
   
   xml += '<Style ss:ID="Cliente">'+chr(13)+chr(10)
   xml += '<Alignment ss:Horizontal="Left" ss:Vertical="Center" ss:WrapText="1"/>'+chr(13)+chr(10)
   xml += '<Borders>'+chr(13)+chr(10)
   xml += '<Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
   xml += '<Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
   xml += '<Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
   xml += '<Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
   xml += '</Borders>'+chr(13)+chr(10)
   xml += '<Font ss:FontName="Calibri" x:Family="Swiss" ss:Color="#000000"/>'+chr(13)+chr(10)
   xml += '<Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>'+chr(13)+chr(10)
   xml += '</Style>'+chr(13)+chr(10)
   
   xml += '<Style ss:ID="Titulo">'+chr(13)+chr(10)
   xml += '<Alignment ss:Horizontal="Center" ss:Vertical="Center" ss:WrapText="1"/>'+chr(13)+chr(10)
   xml += '<Borders>'+chr(13)+chr(10)
   xml += '<Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
   xml += '<Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
   xml += '<Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
   xml += '<Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
   xml += '</Borders>'+chr(13)+chr(10)
   xml += '<Font ss:FontName="Calibri" x:Family="Swiss" ss:Color="#000000"/>'+chr(13)+chr(10)
   xml += '<Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>'+chr(13)+chr(10)
   xml += '</Style>'+chr(13)+chr(10)
   
   xml += '<Style ss:ID="s80">'+chr(13)+chr(10)
   xml += '<Alignment ss:Horizontal="Right" ss:Vertical="Center" ss:WrapText="1"/>'+chr(13)+chr(10)
   xml += '<Borders>'+chr(13)+chr(10)
   xml += '<Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
   xml += '<Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
   xml += '<Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
   xml += '<Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
   xml += '</Borders>'+chr(13)+chr(10)
   xml += '<Font ss:FontName="Calibri" x:Family="Swiss" ss:Color="#000000"/>'+chr(13)+chr(10)
   xml += '<Interior ss:Color="#F2DCDB" ss:Pattern="Solid"/>'+chr(13)+chr(10)
   xml += '</Style>'+chr(13)+chr(10)
  
return xml

static function cabec_xml

local cBuffer := ""

   cBuffer += xmlAbreLinha()
      cBuffer += xmlCell("String",rtrim(cTitulo) + " 565","Titulo",,18) 
   cBuffer += xmlFechaLinha()
   
   cBuffer += xmlAbreLinha()
      cBuffer += xmlCell("String","Cliente","Cliente") 
	  cBuffer += xmlCell("String","Pedido","s66",,2)

	  cBuffer += xmlCell("String","Faturado","s80",,2)

	  cBuffer += xmlCell("String","Pedido Acum.","s66",,3)

	  cBuffer += xmlCell("String","Faturamento Acum.","s80",,3)
   cBuffer += xmlFechaLinha()
   
   cBuffer += xmlAbreLinha(35)
      cBuffer += xmlCell("String","","Cliente")
      cBuffer += xmlCell("String",strzero(month(dFIM_ANT),2)+"/"+strzero(year(dFIM_ANT),4),"s66")
      cBuffer += xmlCell("String",strzero(month(dFIM),2)+"/"+strzero(year(dFIM),4),"s66")
 	  cBuffer += xmlCell("String","%","s66")
  	  
	  cBuffer += xmlCell("String",strzero(month(dFIM_ANT),2)+"/"+strzero(year(dFIM_ANT),4),"s80")
	  cBuffer += xmlCell("String",strzero(month(dFIM),2)+"/"+strzero(year(dFIM),4),"s80")
	  cBuffer += xmlCell("String","%","s80")
	  
	  cBuffer += xmlCell("String","01/"+strzero(year(dFIM_ANT),4)+ " a " +strzero(month(dFIM_ANT),2)+"/"+strzero(year(dFIM_ANT),4),"s66")
	  cBuffer += xmlCell("String","01/"+strzero(year(dFIM),4)+ " a " +strzero(month(dFIM),2)+"/"+strzero(year(dFIM),4),"s66")
	  cBuffer += xmlCell("String","%","s66")
	  cBuffer += xmlCell("String","Diferenca","s66")
	  
	  cBuffer += xmlCell("String","01/"+strzero(year(dFIM_ANT),4)+ " a " +strzero(month(dFIM_ANT),2)+"/"+strzero(year(dFIM_ANT),4),"s80")
	  cBuffer += xmlCell("String","01/"+strzero(year(dFIM),4)+ " a " +strzero(month(dFIM),2)+"/"+strzero(year(dFIM),4),"s80")
	  cBuffer += xmlCell("String","%","s80")
	  cBuffer += xmlCell("String","Diferenca","s80")
   cBuffer += xmlFechaLinha()

return cBuffer

static function i_selecionaGravadorFaturado(cClasse,nTotal)
         if cClasse == "REPRESENTANTE"
            i_cgrava(FAT->Cod_cli,CLI1->cod_repres,FAT->Dt_emissao,nTOTAL,FAT->Es)
		 else
		    if cClasse == "SUPERVISOR"
			   if !empty(CLI1->Cod_resp)
			      i_cgrava(FAT->Cod_cli,CLI1->cod_resp,FAT->Dt_emissao,nTOTAL,FAT->Es)
			   else
			      REPRES->(dbseek(CLI1->Cod_repres))
                  i_cgrava(FAT->Cod_cli,REPRES->cod_resp,FAT->Dt_emissao,nTOTAL,FAT->Es) 
               endif 			   
		 	endif
         endif		 
return

static function i_selecionaGravadorPedido(cClasse,cArq,nTotal)
         if cClasse == "REPRESENTANTE"
            i_cgrava_pend((cArq)->Cod_cli,CLI1->cod_repres,(cArq)->Dt_emissao,nTOTAL,(cArq)->Es)
		 else
		    if cClasse == "SUPERVISOR"
			   if !empty(CLI1->Cod_resp)
			      i_cgrava_pend((cARQ)->Cod_cli,CLI1->cod_resp,(cArq)->Dt_emissao,nTOTAL,(cArq)->Es)
			   else
			      REPRES->(dbseek(CLI1->Cod_repres))
                  i_cgrava_pend((cArq)->Cod_cli,REPRES->cod_resp,(cArq)->Dt_emissao,nTOTAL,(cArq)->Es) 
               endif 			   
		 	endif
         endif		 
return

static function xmlColunas
local xml := ""
   xml += '<Column ss:Width="250"/>'+chr(13)+chr(10)
   xml += '<Column ss:Width="45"/>'+chr(13)+chr(10)
   xml += '<Column ss:Width="45"/>'+chr(13)+chr(10)
   xml += '<Column ss:Width="25"/>'+chr(13)+chr(10)
   xml += '<Column ss:Width="10"/>'+chr(13)+chr(10)
   xml += '<Column ss:Width="10"/>'+chr(13)+chr(10)
   xml += '<Column ss:Width="5"/>'+chr(13)+chr(10)
   xml += '<Column ss:Width="15"/>'+chr(13)+chr(10)
   xml += '<Column ss:Width="15"/>'+chr(13)+chr(10)
   xml += '<Column ss:Width="5"/>'+chr(13)+chr(10)
   xml += '<Column ss:Width="15"/>'+chr(13)+chr(10)
   xml += '<Column ss:Width="15"/>'+chr(13)+chr(10)
   xml += '<Column ss:Width="15"/>'+chr(13)+chr(10)
   xml += '<Column ss:Width="5"/>'+chr(13)+chr(10)
   xml += '<Column ss:Width="15"/>'+chr(13)+chr(10)
   xml += '<Column ss:Width="30"/>'+chr(13)+chr(10)
   xml += '<Column ss:Width="3"/>'+chr(13)+chr(10)
  

return xml