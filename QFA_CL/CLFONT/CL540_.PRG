/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO COMERCIO
// OBJETIVO...: Relatorio de comissao
// ANALISTA...: EDUARDO AUGUSTO BORIO
// PROGRAMADOR: EDUARDO AUGUSTO BORIO
// INICIO.....: ABRIL DE 2003
// OBS........:
// ALTERACOES.:

function cl540
#define K_MAX_LIN 57

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG) .or. empty(dINI) }

private cTITULO                   // titulo do relatorio
private dINI
private dFIM
private cSETOR := space(5)
private cVEND   := space(5)
private aEDICAO := {}             // vetor para os campos de entrada de dados
private sBLOC1  := XSN
private sBLOC2  := qlbloc("B540B","QBLOC.GLO")
private cGera   := "N"
private cTIPO   := "1"



if ! quse(XDRV_CL,"FI540",{"FI540"},"E")
   qmensa("N„o foi poss¡vel abrir arquivo temporario !! Tente novamente.")
   return
endif


// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qgetx(-1,0,@dINI)            } , "INI"    })
aadd(aEDICAO,{{ || qgetx(-1,0,@dFIM)            } , "FIM"    })
aadd(aEDICAO,{{ || view_repres(-1,0,@cVEND   )    } , "VEND"   })
aadd(aEDICAO,{{ || NIL                          } , NIL      })
aadd(aEDICAO,{{ || qesco(-1,0,@cGera,sBLOC1  )  } , "GERA"  })
aadd(aEDICAO,{{ || qesco(-1,0,@cTipo,sBLOC2  )  } , "TIPO"  })


do while .T.

   qlbloc(5,0,"B540A","QBLOC.GLO")
   XNIVEL := 1
   XFLAG  := .T.
   dINI := dFIM := ctod("")
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
              qrsay(XNIVEL+1, "Todos os Representantes.......")
           else
              if ! REPRES->(Dbseek(cVEND))
                 qmensa("Representante n„o encontrado","B")
                 return .F.
              else
                 qrsay(XNIVEL+1,left(REPRES->Razao,30))
              endif
           endif

      case cCAMPO == "GERA"

           if empty(cGera) ; return .F. ; endif
           qrsay(XNIVEL,qabrev(cGera,"SN",{"Sim","N„o"}))

      case cCAMPO == "TIPO"

           if empty(cTipo) ; return .F. ; endif
           qrsay(XNIVEL,qabrev(cTIPO,"12",{"Representante","Reponsavel"}))



   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // CRIA TITULO DO RELATORIO ______________________________________________


   cTITULO := "RELATORIO DE VENDAS POR REPRESENTANTE" + " de " + dtoc(dINI) + " a " + dtoc(dFIM)

   qmensa("")

   // ESTABELECE RELACOES ENTRE ARQUIVOS ____________________________________

   FAT->(dbsetorder(2)) // data de saida
   FAT->(dbgotop())
   set softseek on
   FAT->(Dbseek(dtos(dINI)))
   set softseek off
   ITEN_FAT->(dbsetorder(2))
return .T.

static function i_impressao

   if cTIPO == "1"
      i_getDados()
   else
      i_getResp()
   endif


   if cGera == "S"
      if ! qinitprn(,,"REPR"+right(FI540->Cod_repres,4)) ; return  ; endif
   else
      if ! qinitprn() ; return  ; endif
   endif

   if XLOCALIMP == "X"
      if cTIPO == "1"
         i_impre_xls()
      else
         i_impre_resp()
      endif
   else
      //2if ! qinitprn() ; return  ; endif
      if cTIPO == "1"
         i_impre_prn()
      else
         i_impre_resp_prn()
      endif
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
    local aVEND := {}

    FI540->(Dbgotop())

   if lTEM
       zVEND  := FI540->Cod_repres
       nCONT := 1
       do while  ! FI540->(eof())

           if ! qlineprn() ; exit ; endif

           if XPAGINA == 0 .or. prow() > K_MAX_LIN
              @prow()+1,0 say XCOND1
              qpageprn()
              qcabecprn(cTITULO,136)
              @ prow()+1,0 say "Data Emissao    Cod.  Cliente                                                          Total  Nota Fiscal    %   Vlr Comissao"

              @ prow()+1,0 say replicate("-",136)
           endif

           if FI540->Es == "S"
              nUF_VALOR += FI540->Valor //(asFAT[nCONT,4])
              nTOT_GER  += FI540->Valor //(asFAT[nCONT,4])
           else
              nUF_VALOR -= FI540->Valor  //asFAT[nCONT,4]
              nTOT_GER  -= FI540->Valor  //asFAT[nCONT,4]
           endif

           @ prow()+1, 00  say dtoc(FI540->Dt_emissao)  //asFAT[nCONT,1]                         //Data de Emissao
           @ prow()  , 16  say FI540->Cod_cli           //asFAT[nCONT,2]                         //Codigo do Cliente
           @ prow()  , 22  say left(FI540->cli_razao,45)   //asFAT[nCONT,3]                         //Razao do Cliente
           @ prow()  , 80  say transf(FI540->Valor,"@E 999,999.99") //Valor da Nota

           @ prow()  , 96  say FI540->Fatura        //asFAT[nCONT,5]                         //Numero da Nota

           if FI540->Es == "S"
             // @ prow()  ,106  say transf(FI540->rep_com,"@E 99.9") //Comissao
              @ prow()  ,118  say transf(FI540->rep_com,"@E 999,999.99") //Comissao
              nCOMISS  += ( FI540->rep_com )
              nTOT_COM += ( FI540->rep_com)

           else
              @ prow()  ,106  say "Devolucao" //Comissao
              @ prow()  ,118  say transf(FI540->rep_com,"@E 999,999.99") //Comissao
              nCOMISS  -= ( FI540->rep_com )
              nTOT_COM -= ( FI540->rep_com )


           endif

           Fi540->(dbskip())

          if alltrim(FI540->cod_repres) != alltrim(zVEND)
              REPRES->(dbseek(zVEND))
              @ prow()+2  ,00 say "TOTAIS DO REPRESENTANTE....: "+left(REPRES->Razao,30)
              @ prow()    , 79 say transf(nUF_VALOR,"@E 99,999,999.99")
              @ prow()    ,116 say transf(nCOMISS,"@E 99,999.99")
              @ prow()+1,00 say replicate("-",136)

              aadd(aVend,{left(REPRES->Razao,40),nUF_VALOR})


              if REPRES->(dbseek(zVEND))

                 MILHAS->(dbsetorder(2))
                 if MILHAS->(dbseek(REPRES->Codigo))
                    i_clube_prn()
                    //@ prow()+1,00 say "Clube Beneficio Siente La Luz..."
                    //@ prow()+1,00 say "Pontucao ate "+dtoc(date())+" : "+transf(MILHAS->Pontos/100,"@E 9,999,999.99")
                    //@ prow()+1,00 say "Resgate de Premios ate "+dtoc(MILHAS->Data_ini+365)+"."
                 endif
              endif

              @ prow()+1,00 say ""
              nUF_VALOR := 0
              nCOMISS := 0
          endif

         zVEND := FI540->cod_repres

       enddo
       REPRES->(dbseek(zVEND))
       @ prow()+2  ,00 say "TOTAIS DO REPRESENTANTE...: "+left(REPRES->Razao,30)
       @ prow()    ,79 say transf(nUF_VALOR,"@E 99,999,999.99")
       @ prow()    ,116 say transf(nCOMISS,"@E 99,999.99")
       @ prow()+1,00 say replicate("-",136)

       MILHAS->(dbsetorder(2))
       if MILHAS->(dbseek(REPRES->Codigo))
          //@ prow()+1,00 say "Clube Beneficio Siente La Luz..."
          //@ prow()+1,00 say "Pontucao ate "+dtoc(date())+" : "+transf(MILHAS->Pontos/100,"@E 9,999,999.99")
          //@ prow()+1,00 say "Resgate de Premios ate "+dtoc(MILHAS->Data_ini+365)+"."
          i_clube_prn()
       endif

       @ prow()+1,00 say ""
       nUF_VALOR := 0


       @ prow()+1,00 say replicate("-",136)
       @ prow()  ,35 say "TOTAL GERAL...:"
       @ prow()  ,79 say transf(nTOT_GER,"@E 99,999,999.99")
       @ prow() ,116 say transf(nTOT_COM,"@E 99,999.99")

       nQUANT := 0
       nTOTAL := 0
       nPERC  := 0
   endif

   if XLOCALIMP == "S"
      @ prow()+1,00 say "[GRAFICO]"
      nCONT := 1

      do while  nCONT <= len(aVEND)

         if ! qlineprn() ; exit ; endif

         //VEND->(dbseek(aVEND[nCONT,1]))
         @ prow()+1,00 say aVEND[nCONT,1]
         @ prow()  ,50 say strzero(val(qtiraponto(str(aVEND[nCONT,2],14,2))),14)

         nCONT++

         if nCONT > len(aVEND)
            nCONT := len(aVEND)
            exit
         endif

      enddo

      aVend := {}

   endif


   qstopprn(.f.)

return


static function i_impre_xls
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

   if lTEM
       FI540->(dbgotop())
       zVEND  := FI540->Cod_repres
       nCONT := 1
       do while ! FI540->(eof())


           if XPAGINA == 0
              qpageprn()
              @ prow()+1,0 say chr(9)+chr(9)+cTITULO
              @ prow()+1,0 say "Data Emissao"+chr(9)+"Cod."+chr(9)+"Cliente"+chr(9)+"Total"+chr(9)+"Nota Fiscal"+chr(9)+"Vlr Comissao"

              @ prow()+1,0 say ""
           endif

           if FI540->Es == "S"
              nUF_VALOR += (FI540->Valor)
              nTOT_GER  += (FI540->Valor)
           else
              nUF_VALOR -= FI540->Valor
              nTOT_GER  -= FI540->Valor
           endif

           @ prow()+1, 00  say dtoc(FI540->dt_emissao)                         //Data de Emissao
           @ prow()  , pcol()  say chr(9)+FI540->Cod_cli                         //Codigo do Cliente
           @ prow()  , pcol()  say chr(9)+FI540->cli_razao                       //Razao do Cliente
           @ prow()  , pcol()  say chr(9)+transf(FI540->Valor,"@E 9,999,999.99") //Valor da Nota

           @ prow()  , pcol()  say chr(9)+FI540->Fatura                         //Numero da Nota

           if FI540->Es == "S"
             // @ prow()  ,106  say chr(9)+transf(FI540->Rep_com,"@E 99.9") //Comissao
              @ prow()  ,pcol()  say chr(9)+transf(FI540->Rep_com,"@E 999,999.99") //Comissao
              nCOMISS  += ( FI540->Rep_com )
              nTOT_COM += ( FI540->Rep_com)

           else
              @ prow()  ,pcol()  say chr(9)+transf(FI540->Rep_com,"@E 999,999.99") //Comissao
              @ prow()  ,pcol()  say chr(9)+"Devolucao" //Comissao

              nCOMISS  -= ( FI540->Rep_com )
              nTOT_COM -= ( FI540->Rep_com)


           endif

           FI540->(dbskip())

          if alltrim(FI540->cod_repres) != alltrim(zVEND)
              REPRES->(dbseek(zVEND))
              @ prow()+2  ,00 say chr(9)+chr(9)+"TOTAIS DO REPRESENTANTE....: "+left(REPRES->Razao,30)
              @ prow()    , pcol() say chr(9)+transf(nUF_VALOR,"@E 99,999,999.99")
              @ prow()    ,pcol() say chr(9)+transf(nCOMISS,"@E 99,999.99")
              @ prow()+1,00 say ""

              MILHAS->(dbsetorder(2))
              if MILHAS->(dbseek(REPRES->Codigo))
                 //@ prow()+1,00 say chr(9)+chr(9)+"Clube Beneficio Siente La Luz..."
                 //@ prow()+1,00 say chr(9)+chr(9)+"Pontucao ate "+dtoc(date())+" : "+transf(MILHAS->Pontos/100,"@E 9,999,999.99")
                 //@ prow()+1,00 say chr(9)+chr(9)+"Resgate de Premios ate "+dtoc(MILHAS->Data_ini+365)+"."
                 i_clube_xls()
              endif

              @ prow()+1,00 say ""
              nUF_VALOR := 0
              nCOMISS := 0


              if cGera == "S" .and. ! FI540->(Eof())
                 qstopPrn()
                 qinitPrn(,"X","REPR"+right(FI540->Cod_repres,4))
              endif

          endif

         zVEND := FI540->cod_repres

       enddo
       REPRES->(dbseek(zVEND))
       @ prow()+2  ,00 say chr(9)+chr(9)+"TOTAIS DO REPRESENTANTE...: "+left(REPRES->Razao,30)
       @ prow()    ,pcol() say chr(9)+transf(nUF_VALOR,"@E 99,999,999.99")
       @ prow()    ,pcol() say chr(9)+transf(nCOMISS,"@E 99,999.99")
       @ prow()+1,00 say ""

       MILHAS->(dbsetorder(2))
       if MILHAS->(dbseek(REPRES->Codigo))
          i_clube_xls()

         // @ prow()+1,00 say chr(9)+chr(9)+"Clube Beneficio Siente La Luz..."
         // /@ prow()+1,00 say chr(9)+chr(9)+"Pontucao ate "+dtoc(date())+" : "+transf(MILHAS->Pontos/100,"@E 9,999,999.99")
         // @ prow()+1,00 say chr(9)+chr(9)+"Resgate de Premios ate "+dtoc(MILHAS->Data_ini+365)+"."
       endif

       @ prow()+1,00 say ""
       nUF_VALOR := 0


       @ prow()+1 ,00 say chr(9)+chr(9)+"TOTAL GERAL...:"
       @ prow()  ,pcol() say chr(9)+transf(nTOT_GER,"@E 99,999,999.99")
       @ prow() ,pcol() say chr(9)+transf(nTOT_COM,"@E 99,999.99")

       nQUANT := 0
       nTOTAL := 0
       nPERC  := 0
   endif

   qstopprn()

return


static function i_clube_prn()

   local nTT_PTS := 0
   
   if dFim > ctod("30/04/2013")
	  return .F.
   endif	  


   PREMIO->(dbsetorder(2))
   MILHAS->(dbsetorder(2))

   MILHAS->(dbseek(REPRES->Codigo))
   if PREMIO->(dbseek(REPRES->Codigo))
      do while ! PREMIO->(eof()) .and. PREMIO->Cod_repres == REPRES->Codigo
         if PREMIO->Data >= MILHAS->Data_ini .and. PREMIO->Data <= (Milhas->Data_ini + 1825)
            nTT_PTS += PREMIO->Pontos
         endif
         PREMIO->(dbskip())
      enddo
   endif

   MILHAS->(dbsetorder(2))
   if MILHAS->(dbseek(REPRES->Codigo))
      @ prow()+1,00 say "Clube Beneficio Siente La Luz..."
      @ prow()+1,00 say "Pontos acumulados ate "+dtoc(date())+" :         "+transf((MILHAS->Pontos+nTT_PTS)/100,"@E 9,999,999.99")

      PREMIO->(dbgotop())
      if PREMIO->(dbseek(REPRES->Codigo))
         @ prow()+1,00 say "Premios regatados.:"
         do while ! PREMIO->(eof()) .and. PREMIO->Cod_repres == REPRES->Codigo
            if PREMIO->Data >= MILHAS->Data_ini .and. PREMIO->Data <= (Milhas->Data_ini + 1825)
               @ prow()+1,00 say left(PREMIO->Descricao,30)+" "+dtoc(PREMIO->Data)+": "+transf(PREMIO->Pontos/100,"@E 9,999,999.99")
            endif
            PREMIO->(dbskip())
         enddo
      endif
      @ prow()+1,00 say ""
      @ prow()+1,00 say "Total de pontos a resgatar ate "+dtoc(MILHAS->Data_ini+1825)+": "+transf(MILHAS->Pontos/100,"@E 9,999,999.99")



   endif
return


static function i_clube_xls()

   local nTT_PTS := 0

   if dFim > ctod("30/04/2013")
	  return .F.
   endif

   PREMIO->(dbsetorder(2))
   MILHAS->(dbsetorder(2))

   MILHAS->(dbseek(REPRES->Codigo))
   if PREMIO->(dbseek(REPRES->Codigo))
      do while ! PREMIO->(eof()) .and. PREMIO->Cod_repres == REPRES->Codigo
         if PREMIO->Data >= MILHAS->Data_ini .and. PREMIO->Data <= (Milhas->Data_ini + 1825)
            nTT_PTS += PREMIO->Pontos
         endif
         PREMIO->(dbskip())
      enddo
   endif

   MILHAS->(dbsetorder(2))
   if MILHAS->(dbseek(REPRES->Codigo))
      @ prow()+1,00 say chr(9)+chr(9)+"Clube Beneficio Siente La Luz..."
      @ prow()+1,00 say chr(9)+chr(9)+"Pontos Acumulados ate "+dtoc(date())+" :         "+transf((MILHAS->Pontos+nTT_PTS)/100,"@E 9,999,999.99")

      PREMIO->(dbgotop())
      if PREMIO->(dbseek(REPRES->Codigo))
         @ prow()+1,00 say chr(9)+chr(9)+"Premios Regatados.: "

         do while ! PREMIO->(eof()) .and. PREMIO->Cod_repres == REPRES->Codigo
            if PREMIO->Data >= MILHAS->Data_ini .and. PREMIO->Data <= (Milhas->Data_ini + 1825)
               @ prow()+1,00 say chr(9)+chr(9)+dtoc(PREMIO->Data)+" "+left(PREMIO->Descricao,35)+" "+transf(PREMIO->Pontos/100,"@E 9,999,999.99")
            endif
            PREMIO->(dbskip())
         enddo
      endif
      @ prow()+1,00 say ""
      @ prow()+1,00 say chr(9)+chr(9)+"Total de pontos a resgatar ate "+dtoc(MILHAS->Data_ini+1825)+": " +transf(MILHAS->Pontos/100,"@E 9,999,999.99")



   endif
return

static function i_getDados
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


    FI540->(__dbzap())
   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________
    lTEM := .F.

   do while ! FAT->(eof())//  .and. FAT->Dt_emissao >= dINI .and. FAT->Dt_emissao <= dFIM  // condicao principal de loop

      CLI1->(dbseek(FAT->Cod_cli))

      if FAT->Cancelado
         FAT->(Dbskip())
         loop
      endif

      if empty(FAT->Num_fatura) .and. FAT->Es == "S"
         FAT->(Dbskip())
         loop
      endif

      if ! left(FAT->Cod_cfop,3) $ "510-511-512-610-611-612-120-220-540-541-640-641-530-531-630-631-141-241"
         FAT->(dbskip())
         loop
      endif

      qgirabarra()

      qmensa("Aguarde... Processando ...")

      if FAT->Dt_emissao < dINI .or. FAT->Dt_emissao > dFIM
         FAT->(dbskip())
         loop
      endif

      nREP_COM := 0

      ITEN_FAT->(Dbgotop())
      ITEN_FAT->(Dbseek(FAT->Codigo))
      do while ITEN_FAT->Num_fat == FAT->Codigo .and. ! ITEN_FAT->(eof())

          PROD->(dbsetorder(4))
          PROD->(dbseek(ITEN_FAT->Cod_Prod))
          nTOTAL += ITEN_FAT->Quantidade * ITEN_FAT->Vl_unitar
          nDESC += ITEN_FAT->Vlr_desc * ITEN_FAT->Quantidade
          nREP_COM += ((ITEN_FAT->Quantidade * ITEN_FAT->Vl_unitar) * (ITEN_FAT->Comi_repre/100))
          lTEM := .T.
          ITEN_FAT->(Dbskip())
      enddo

      if CONFIG->Modelo_fat == "1"
         nDESC := nDESC
      else
         nDESC := nTOTAL * (FAT->Aliq_desc/100)
      endif

      if !empty(cVEND) .and. FAT->Cod_repres <> cVEND
         //aadd(aFAT,{dtoc(FAT->Dt_Emissao),FAT->Cod_cli,,CGM->Estado,FAT->Cod_repres,CLI1->Comis_repr})
      else
          //aadd(aFAT,{dtoc(FAT->Dt_Emissao),FAT->Cod_cli,CLI1->Razao,nTOTAL,FAT->Num_fatura,FAT->Cod_repres,nREP_COM,FAT->Es})
          if FI540->(qappend())
             replace FI540->Dt_emissao with FAT->Dt_emissao
             replace FI540->Cod_cli    with FAT->Cod_cli
             replace FI540->cli_razao  with CLI1->Razao
             replace FI540->Valor      with nTOTAL
             replace FI540->Fatura     with FAT->Num_fatura
             replace FI540->Cod_repres with FAT->cod_repres
             replace FI540->Rep_com    with nREP_COM
             replace FI540->Es         with FAT->Es
          endif

      endif

      nTOTAL := 0
      nDESC  := 0
      nREP_COM := 0
      FAT->(dbskip())

   enddo

   FI540->(dbcommit())
   FI540->(dbgotop())


return

static function i_getResp
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


    FI540->(__dbzap())
   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________
    lTEM := .F.

   do while ! FAT->(eof())//  .and. FAT->Dt_emissao >= dINI .and. FAT->Dt_emissao <= dFIM  // condicao principal de loop

      CLI1->(dbseek(FAT->Cod_cli))

      if FAT->Cancelado
         FAT->(Dbskip())
         loop
      endif

      if empty(FAT->Num_fatura) .and. FAT->Es == "S"
         FAT->(Dbskip())
         loop
      endif

      if ! left(FAT->Cod_cfop,3) $ "510-511-512-610-611-612-120-220-540-541-640-641-530-531-630-631-141-241"
         FAT->(dbskip())
         loop
      endif

      qgirabarra()

      qmensa("Aguarde... Processando ...")

      if FAT->Dt_emissao < dINI .or. FAT->Dt_emissao > dFIM
         FAT->(dbskip())
         loop
      endif

      nREP_COM := 0

      ITEN_FAT->(Dbgotop())
      ITEN_FAT->(Dbseek(FAT->Codigo))
      do while ITEN_FAT->Num_fat == FAT->Codigo .and. ! ITEN_FAT->(eof())

          PROD->(dbsetorder(4))
          PROD->(dbseek(ITEN_FAT->Cod_Prod))
          nTOTAL += ITEN_FAT->Quantidade * ITEN_FAT->Vl_unitar
          nDESC += ITEN_FAT->Vlr_desc * ITEN_FAT->Quantidade
          nREP_COM += ((ITEN_FAT->Quantidade * ITEN_FAT->Vl_unitar) * (ITEN_FAT->Comi_repre/100))
          lTEM := .T.
          ITEN_FAT->(Dbskip())
      enddo

      if CONFIG->Modelo_fat == "1"
         nDESC := nDESC
      else
         nDESC := nTOTAL * (FAT->Aliq_desc/100)
      endif

      //if !empty(cVEND) .and. FAT->Cod_repres <> cVEND
         //aadd(aFAT,{dtoc(FAT->Dt_Emissao),FAT->Cod_cli,,CGM->Estado,FAT->Cod_repres,CLI1->Comis_repr})
      //else
          //aadd(aFAT,{dtoc(FAT->Dt_Emissao),FAT->Cod_cli,CLI1->Razao,nTOTAL,FAT->Num_fatura,FAT->Cod_repres,nREP_COM,FAT->Es})
          if FI540->(qappend())
             replace FI540->Dt_emissao with FAT->Dt_emissao
             replace FI540->Cod_cli    with FAT->Cod_cli
             replace FI540->cli_razao  with CLI1->Razao
             replace FI540->Valor      with nTOTAL
             replace FI540->Fatura     with FAT->Num_fatura
             
             replace FI540->Cod_repres with FAT->cod_resp
             replace FI540->Rep_com    with nREP_COM
             replace FI540->Es         with FAT->Es
          endif

      //endif

      nTOTAL := 0
      nDESC  := 0
      nREP_COM := 0
      FAT->(dbskip())

   enddo

   FI540->(dbcommit())
   FI540->(dbgotop())


return


static function i_impre_resp
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

   if lTEM
       FI540->(dbgotop())
       zVEND  := FI540->Cod_repres
       nCONT := 1
       do while ! FI540->(eof())


           if XPAGINA == 0
              qpageprn()
              @ prow()+1,0 say chr(9)+chr(9)+cTITULO
              @ prow()+1,0 say "Data Emissao"+chr(9)+"Cod."+chr(9)+"Cliente"+chr(9)+"Total"+chr(9)+"Nota Fiscal"+chr(9)+"Vlr Comissao"

              @ prow()+1,0 say ""
           endif

           if FI540->Es == "S"
              nUF_VALOR += (FI540->Valor)
              nTOT_GER  += (FI540->Valor)
           else
              nUF_VALOR -= FI540->Valor
              nTOT_GER  -= FI540->Valor
           endif

           @ prow()+1, 00  say dtoc(FI540->dt_emissao)                         //Data de Emissao
           @ prow()  , pcol()  say chr(9)+FI540->Cod_cli                         //Codigo do Cliente
           @ prow()  , pcol()  say chr(9)+FI540->cli_razao                       //Razao do Cliente
           @ prow()  , pcol()  say chr(9)+transf(FI540->Valor,"@E 9,999,999.99") //Valor da Nota

           @ prow()  , pcol()  say chr(9)+FI540->Fatura                         //Numero da Nota

           if FI540->Es == "S"
             // @ prow()  ,106  say chr(9)+transf(FI540->Rep_com,"@E 99.9") //Comissao
              @ prow()  ,pcol()  say chr(9)+transf(FI540->Rep_com,"@E 999,999.99") //Comissao
              nCOMISS  += ( FI540->Rep_com )
              nTOT_COM += ( FI540->Rep_com)

           else
              @ prow()  ,pcol()  say chr(9)+transf(FI540->Rep_com,"@E 999,999.99") //Comissao
              @ prow()  ,pcol()  say chr(9)+"Devolucao" //Comissao

              nCOMISS  -= ( FI540->Rep_com )
              nTOT_COM -= ( FI540->Rep_com)


           endif

           FI540->(dbskip())

          if alltrim(FI540->cod_repres) != alltrim(zVEND)
              RESP_REP->(dbseek(zVEnd))
              //zVEND := FI540->cod_repres

              @ prow()+2  ,00 say chr(9)+chr(9)+"TOTAIS DO RESPONSAVEL..: "+left(RESP_REP->Nome,30)
              @ prow()    , pcol() say chr(9)+transf(nUF_VALOR,"@E 99,999,999.99")
              @ prow()    ,pcol() say chr(9)+transf(nCOMISS,"@E 99,999.99")
              @ prow()+1,00 say ""

              //MILHAS->(dbsetorder(2))
              //if MILHAS->(dbseek(REPRES->Codigo))
                 //@ prow()+1,00 say chr(9)+chr(9)+"Clube Beneficio Siente La Luz..."
                 //@ prow()+1,00 say chr(9)+chr(9)+"Pontucao ate "+dtoc(date())+" : "+transf(MILHAS->Pontos/100,"@E 9,999,999.99")
                 //@ prow()+1,00 say chr(9)+chr(9)+"Resgate de Premios ate "+dtoc(MILHAS->Data_ini+1825)+"."
              //   i_clube_xls()
              //endif

              @ prow()+1,00 say ""
              nUF_VALOR := 0
              nCOMISS := 0


              //if cGera == "S" .and. ! FI540->(Eof())
              //   qstopPrn()
              //   qinitPrn(,"X","REPR"+right(FI540->Cod_repres,4))
              //endif

          endif
          zVEND := FI540->cod_repres



       enddo
       RESP_REP->(dbseek(zVEND))

       @ prow()+2  ,00 say chr(9)+chr(9)+"TOTAIS DO RESPONSAVEL...: "+left(RESP_REP->Nome,30)
       @ prow()    ,pcol() say chr(9)+transf(nUF_VALOR,"@E 99,999,999.99")
       @ prow()    ,pcol() say chr(9)+transf(nCOMISS,"@E 99,999.99")
       @ prow()+1,00 say ""

       //MILHAS->(dbsetorder(2))
       //if MILHAS->(dbseek(REPRES->Codigo))
       //   i_clube_xls()

         // @ prow()+1,00 say chr(9)+chr(9)+"Clube Beneficio Siente La Luz..."
         // /@ prow()+1,00 say chr(9)+chr(9)+"Pontucao ate "+dtoc(date())+" : "+transf(MILHAS->Pontos/100,"@E 9,999,999.99")
         // @ prow()+1,00 say chr(9)+chr(9)+"Resgate de Premios ate "+dtoc(MILHAS->Data_ini+1825)+"."
       //endif

       @ prow()+1,00 say ""
       nUF_VALOR := 0


       @ prow()+1 ,00 say chr(9)+chr(9)+"TOTAL GERAL...:"
       @ prow()  ,pcol() say chr(9)+transf(nTOT_GER,"@E 99,999,999.99")
       @ prow() ,pcol() say chr(9)+transf(nTOT_COM,"@E 99,999.99")

       nQUANT := 0
       nTOTAL := 0
       nPERC  := 0
   endif

   qstopprn(.F.)

return

static function i_impre_resp_prn
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
    local aVEND := {}

    FI540->(Dbgotop())

   if lTEM
       zVEND  := FI540->Cod_repres
       nCONT := 1
       do while  ! FI540->(eof())

           if ! qlineprn() ; exit ; endif

           if XPAGINA == 0 .or. prow() > K_MAX_LIN
              @prow()+1,0 say XCOND1
              qpageprn()
              qcabecprn(cTITULO,136)
              @ prow()+1,0 say "Data Emissao    Cod.  Cliente                                                          Total  Nota Fiscal    %   Vlr Comissao"

              @ prow()+1,0 say replicate("-",136)
           endif

           if FI540->Es == "S"
              nUF_VALOR += FI540->Valor //(asFAT[nCONT,4])
              nTOT_GER  += FI540->Valor //(asFAT[nCONT,4])
           else
              nUF_VALOR -= FI540->Valor  //asFAT[nCONT,4]
              nTOT_GER  -= FI540->Valor  //asFAT[nCONT,4]
           endif

           @ prow()+1, 00  say dtoc(FI540->Dt_emissao)  //asFAT[nCONT,1]                         //Data de Emissao
           @ prow()  , 16  say FI540->Cod_cli           //asFAT[nCONT,2]                         //Codigo do Cliente
           @ prow()  , 22  say left(FI540->cli_razao,45)   //asFAT[nCONT,3]                         //Razao do Cliente
           @ prow()  , 80  say transf(FI540->Valor,"@E 999,999.99") //Valor da Nota

           @ prow()  , 96  say FI540->Fatura        //asFAT[nCONT,5]                         //Numero da Nota

           if FI540->Es == "S"
             // @ prow()  ,106  say transf(FI540->rep_com,"@E 99.9") //Comissao
              @ prow()  ,118  say transf(FI540->rep_com,"@E 999,999.99") //Comissao
              nCOMISS  += ( FI540->rep_com )
              nTOT_COM += ( FI540->rep_com)

           else
              @ prow()  ,106  say "Devolucao" //Comissao
              @ prow()  ,118  say transf(FI540->rep_com,"@E 999,999.99") //Comissao
              nCOMISS  -= ( FI540->rep_com )
              nTOT_COM -= ( FI540->rep_com )


           endif

           Fi540->(dbskip())

          if alltrim(FI540->cod_repres) != alltrim(zVEND)
              RESP_REP->(dbseek(zVend))
              //zVEND := FI540->Cod_repres
              @ prow()+2  ,00 say "TOTAIS DO RESPONSAVEL....: "+left(RESP_REP->Nome,30)
              @ prow()    , 79 say transf(nUF_VALOR,"@E 99,999,999.99")
              @ prow()    ,116 say transf(nCOMISS,"@E 99,999.99")
              @ prow()+1,00 say replicate("-",136)

              aadd(aVend,{left(RESP_REP->Nome,40),nUF_VALOR})


              //if REPRES->(dbseek(zVEND))

              ////   MILHAS->(dbsetorder(2))
              //   if MILHAS->(dbseek(REPRES->Codigo))
              //      i_clube_prn()
                    //@ prow()+1,00 say "Clube Beneficio Siente La Luz..."
                    //@ prow()+1,00 say "Pontucao ate "+dtoc(date())+" : "+transf(MILHAS->Pontos/100,"@E 9,999,999.99")
                    //@ prow()+1,00 say "Resgate de Premios ate "+dtoc(MILHAS->Data_ini+365)+"."
              //   endif
              //endif

              @ prow()+1,00 say ""
              nUF_VALOR := 0
              nCOMISS := 0
          endif

          zVEND := FI540->Cod_repres


         //zVEND := FI540->cod_repres

       enddo
       RESP_REP->(dbseek(zVend))
       @ prow()+2  ,00 say "TOTAIS DO RESPONSAVEL...: "+left(RESP_REP->Nome,30)
       @ prow()    ,79 say transf(nUF_VALOR,"@E 99,999,999.99")
       @ prow()    ,116 say transf(nCOMISS,"@E 99,999.99")
       @ prow()+1,00 say replicate("-",136)

       //MILHAS->(dbsetorder(2))
       //if MILHAS->(dbseek(REPRES->Codigo))
          //@ prow()+1,00 say "Clube Beneficio Siente La Luz..."
          //@ prow()+1,00 say "Pontucao ate "+dtoc(date())+" : "+transf(MILHAS->Pontos/100,"@E 9,999,999.99")
          //@ prow()+1,00 say "Resgate de Premios ate "+dtoc(MILHAS->Data_ini+365)+"."
       //   i_clube_prn()
       //endif

       @ prow()+1,00 say ""
       nUF_VALOR := 0


       @ prow()+1,00 say replicate("-",136)
       @ prow()  ,35 say "TOTAL GERAL...:"
       @ prow()  ,79 say transf(nTOT_GER,"@E 99,999,999.99")
       @ prow() ,116 say transf(nTOT_COM,"@E 99,999.99")

       nQUANT := 0
       nTOTAL := 0
       nPERC  := 0
   endif

   if XLOCALIMP == "S"
      @ prow()+1,00 say "[GRAFICO]"
      nCONT := 1

      do while  nCONT <= len(aVEND)

         if ! qlineprn() ; exit ; endif

         //VEND->(dbseek(aVEND[nCONT,1]))
         @ prow()+1,00 say aVEND[nCONT,1]
         @ prow()  ,50 say strzero(val(qtiraponto(str(aVEND[nCONT,2],14,2))),14)

         nCONT++

         if nCONT > len(aVEND)
            nCONT := len(aVEND)
            exit
         endif

      enddo

      aVend := {}

   endif


   qstopprn(.f.)

return




