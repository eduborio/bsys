/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO COMERCIO
// OBJETIVO...: LISTAGEM DE NOTAS FISCAIS
// ANALISTA...: EDUARDO AUGUSTO BORIO
// PROGRAMADOR: EDUARDO AUGUSTO BORIO
// INICIO.....: setembro de 2006
// OBS........:
// ALTERACOES.:

function cl564
#define K_MAX_LIN 60

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG) .or. empty(dINI) }

private cTITULO                   // titulo do relatorio
private dINI
private dFIM
private cREPRES  := space(5)
private cUFS  := space(2)
private cITEM := space(1)
private sBLOC1:= XSN
private XDRV_HB := "C:\QSYSTXT\"
private cFILE   := alltrim(left(XUSRIDT,7))

private aEDICAO := {}             // vetor para os campos de entrada de dados

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qgetx(-1,0,@dINI)            } , "INI"    })
aadd(aEDICAO,{{ || qgetx(-1,0,@dFIM)            } , "FIM"    })
aadd(aEDICAO,{{ || view_repres(-1,0,@cREPRES   )      } , "REPRES"  })
aadd(aEDICAO,{{ || NIL                          } , NIL  })
aadd(aEDICAO,{{ || view_ufs(-1,0,@cUFS   )      } , "UFS"  })
aadd(aEDICAO,{{ || NIL                          } , NIL  })
aadd(aEDICAO,{{ || qesco(-1,0,@cITEM,sBLOC1  )  } , "ITEM"  })

do while .T.

   qlbloc(5,0,"B554A","QBLOC.GLO")
   XNIVEL := 1
   XFLAG  := .T.
   dINI := dFIM := ctod("")
   cREPRES := Space(5)
   cUFS := Space(2)
   cITEM:= "N"


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

static function i_critica ( cCAMPO )

   do case
      case cCAMPO == "INI"
           dFIM := dINI+364

      case cCAMPO == "FIM"
           if dFIM < dINI
             return .F.
           endif

      case cCAMPO == "UFS"

           qrsay(XNIVEL,cUFS)

           if empty(cUFS)
              qrsay(XNIVEL+1, "Todos os Estados.......")
           else
              if ! UFS->(Dbseek(cUFS))
                 qmensa("Estado n„o encontrado","B")
                 return .F.
              else
                 qrsay(XNIVEL+1,left(UFS->Descricao,30))
              endif
           endif

      case cCAMPO == "REPRES"

           qrsay(XNIVEL,cREPRES)

           if empty(cREPRES)
              qrsay(XNIVEL++,"Todos o Representantes...")
           else
              if ! REPRES->(Dbseek(cREPRES))
                 qmensa("Representante n„o encontrado","B")
                 return .F.
              else
                 qrsay(XNIVEL++,left(REPRES->Razao,30))
              endif
           endif

      case cCAMPO == "ITEM"

           if empty(cITEM) ; return .F. ; endif
           qrsay(XNIVEL,qabrev(cITEM,"SN",{"Sim","N„o"}))


   endcase

return .T.

///////////.//////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // CRIA TITULO DO RELATORIO ______________________________________________


   cTITULO := "Pontos por Representante" +" de " + dtoc(dINI) + " a " + dtoc(dFIM)

   qmensa("")

   MILHAS->(dbsetorder(2))

   FAT->(dbsetorder(2)) // data de emissao
   FAT->(dbgotop())
   set softseek on
   FAT->(Dbseek(dtos(dINI)))
   set softseek off
   ITEN_FAT->(dbsetorder(2))
return .T.



static function i_impressao
   if ! qinitprn() ; return ; endif

   if XLOCALIMP == "X"
      i_impre_xls()
   else
      i_impre_prn()
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
    local nPontos   := 0

    criaTmpFile()


    lTEM := .F.

    PROD->(dbsetorder(4))

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

      if ! left(FAT->Cod_cfop,3) $ "510-511-512-610-611-612-120-220-540-541-640-641-530-531-630-631"
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
      nPontos  := 0

      ITEN_FAT->(Dbgotop())
      ITEN_FAT->(Dbseek(FAT->Codigo))
      do while ITEN_FAT->Num_fat == FAT->Codigo .and. ! ITEN_FAT->(eof())

          nTOTAL  += ITEN_FAT->Quantidade * ITEN_FAT->Vl_unitar
          nPontos += ((ITEN_FAT->Quantidade*ITEN_FAT->Pontos) * ITEN_FAT->Vl_unitar)
          lTEM := .T.
          ITEN_FAT->(Dbskip())
      enddo

      if !empty(cREPRES) .and. FAT->Cod_repres <> cREPRES
         //aadd(aFAT,{dtoc(FAT->Dt_Emissao),FAT->Cod_cli,,CGM->Estado,FAT->Cod_repres,CLI1->Comis_repr})
      else
          //aadd(aFAT,{dtoc(FAT->Dt_Emissao),FAT->Cod_cli,CLI1->Razao,nTOTAL,FAT->Num_fatura,FAT->Cod_repres,nREP_COM,FAT->Es})
          if (cFILE)->(qappend())
             replace (cFILE)->Dt_emissao with FAT->Dt_emissao
             replace (cFILE)->Cfop       with left(FAT->Cod_cfop,4)
             replace (cFILE)->Cod_cli    with FAT->Cod_cli
             replace (cFILE)->Cli_Razao  with left(CLI1->razao,50)
             replace (cFILE)->Valor      with nTOTAL
             replace (cFILE)->Fatura     with FAT->Num_fatura
             replace (cFILE)->Cod_repres with FAT->cod_repres
             replace (cFILE)->Pontos     with nPontos
             replace (cFILE)->Es         with FAT->Es
          endif

      endif

      nTOTAL   := 0
      nDESC    := 0
      nREP_COM := 0
      nPontos  := 0
      FAT->(dbskip())

   enddo

   (cFILE)->(dbgotop())


return





/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impre_prn
    local nVAL_PED := 0
    local nVAL_PTS := 0
    local nTOTAL   := 0
    local nTT_PTS  := 0
    local nDESC    := 0
    local nTOT_DESC:= 0
    local nIPI     := 0
    local nVAL_UNI := 0
    local zREPRES  := 0
    local nREPPTS  := 0
    local nREPVAL  := 0

    i_getDados()

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   (cFILE)->(dbgotop())
   zREPRES := (cFILE)->Cod_Repres


   do while ! (cFILE)->(eof()) //.and. qcontprn()  // condicao principal de loop



      if XPAGINA == 0 .or. prow() > K_MAX_LIN
         qpageprn()
         @ prow()+1,0 say XCOND0
         qcabecprn(cTITULO,80)
         @ prow()+1,0 say XCOND1 + "N.F.    Cliente                                                  Cfop      Emissao         Valor da Nota        Pontos"
         @ prow()+1,0 say ""
      endif

      qgirabarra()

      qmensa("Aguarde... Processando ...")

      CLI1->(dbseek((cFILE)->cod_cli))

      @ prow()+1,00  say (cFILE)->Fatura
      @ prow()  ,08  say left(CLI1->Razao,50)
      @ prow()  ,65  say (cFILE)->cfop
      @ prow()  ,75  say dtoc((cFILE)->Dt_emissao)
      @ prow()  ,94  say transform((cFILE)->Valor, "@E 999,999.99")
      @ prow()  ,114 say transform((cFILE)->Pontos/100, "@E 999,999.99")

      if (cFILE)->Es == "E"
         nTOTAL   -= (cFILE)->Valor
         nREPVAL  -= (cFILE)->Valor
         nTT_PTS  -= (cFILE)->Pontos
         nREPPTS  -= (cFILE)->Pontos
      else
         nTOTAL   += (cFILE)->Valor
         nTT_PTS  += (cFILE)->Pontos
         nREPVAL  += (cFILE)->Valor
         nREPPTS  += (cFILE)->Pontos
      endif

      (cFILE)->(dbskip())

      if (cFILE)->Cod_repres != zRepres

         i_totaliza_repres(@zRepres,@nREPVAL,@nREPPTS)


      endif

   enddo

   i_totaliza_repres(@zRepres,@nREPVAL,@nREPPTS)


   @ prow()+1,00   say replicate("-",134)
   @ prow()+1, 78  say  "TOTAL -------------->"
   @ prow()  , 91  say transform(nTOTAL, "@E 99,999,999.99")
   @ prow()  , 111 say transform(nTT_PTS, "@E 99,999,999.99")

   (cFILE)->(dbclosearea())

   erasefiles()

   qstopprn(.F.)

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impre_xls
    local nVAL_PED := 0
    local nVAL_PTS := 0
    local nTOTAL   := 0
    local nTT_PTS  := 0
    local nDESC    := 0
    local nTOT_DESC:= 0
    local nIPI     := 0
    local nVAL_UNI := 0
    local zREPRES  := 0
    local nREPPTS  := 0
    local nREPVAL  := 0

    i_getDados()

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   (cFILE)->(dbgotop())
   zREPRES := (cFILE)->Cod_Repres


   do while ! (cFILE)->(eof()) //.and. qcontprn()  // condicao principal de loop



      if XPAGINA == 0 //.or. prow() > K_MAX_LIN
         qpageprn()
         @ prow()+1,0 say chr(9)+cTitulo+" 564"
         @ prow()+1,0 say "N.F."+chr(9)+"Cliente"+chr(9)+"Cfop"+chr(9)+"Emissao"+chr(9)+"Valor"+chr(9)+"Pontos"
         @ prow()+1,0 say ""
      endif

      qgirabarra()

      qmensa("Aguarde... Processando ...")

      CLI1->(dbseek((cFILE)->cod_cli))

      @ prow()+1,00     say (cFILE)->Fatura
      @ prow()  ,pcol() say chr(9)+left(CLI1->Razao,50)
      @ prow()  ,pcol() say chr(9)+(cFILE)->cfop
      @ prow()  ,pcol() say chr(9)+dtoc((cFILE)->Dt_emissao)
      @ prow()  ,pcol() say chr(9)+transform((cFILE)->Valor, "@E 999,999.99")
      @ prow()  ,pcol() say chr(9)+transform((cFILE)->Pontos/100, "@E 999,999.99")

      if (cFILE)->Es == "E"
         nTOTAL   -= (cFILE)->Valor
         nREPVAL  -= (cFILE)->Valor
         nTT_PTS  -= (cFILE)->Pontos
         nREPPTS  -= (cFILE)->Pontos
      else
         nTOTAL   += (cFILE)->Valor
         nTT_PTS  += (cFILE)->Pontos
         nREPVAL  += (cFILE)->Valor
         nREPPTS  += (cFILE)->Pontos
      endif

      (cFILE)->(dbskip())

      if (cFILE)->Cod_repres != zRepres

         i_xls(@zRepres,@nREPVAL,@nREPPTS)


      endif

   enddo

   i_xls(@zRepres,@nREPVAL,@nREPPTS)


   @ prow()+1,00   say ""
   @ prow()+1, 00  say  chr(9)+"TOTAL GERAL.:"
   @ prow()  , pcol()  say chr(9)+chr(9)+transform(nTOTAL, "@E 99,999,999.99")
   @ prow()  , pcol()  say chr(9)+transform(nTT_PTS, "@E 99,999,999.99")

   (cFILE)->(dbclosearea())
   erasefiles()

   qstopprn(.F.)

return

static function criaTmpFile
  local aStruct := {}
  aStruct := {;
             {"DT_EMISSAO","D",8 ,0},;
             {"CFOP"      ,"C",4 ,0},;
             {"COD_CLI"   ,"C",5 ,0},;
             {"CLI_RAZAO" ,"C",50,0},;
             {"VALOR"     ,"N",12,2},;
             {"PONTOS"    ,"N",12,2},;
             {"COD_REPRES","C",5 ,0},;
             {"FATURA"    ,"C",6 ,0},;
             {"REP_COM"   ,"N",12,2},;
             {"ES"        ,"C",1 ,0} ;
             }

   eraseFiles()

   dbCreate(XDRV_HB+cFILE,aStruct)

   if ! Quse(XDRV_HB,cFILE,{""})
      qmensa("Erro ao criar arquivo temporario!","BL")
      return .F.
   endif

   select (cFILE)
   index on (COD_REPRES + CLI_RAZAO + FATURA) tag Um
   dbsetindex(XDRV_HB+cFILE)


return

static function eraseFiles

   if file(XDRV_HB+cFILE+".DBF")
      erase(XDRV_HB+cFILE+".DBF")
   endif

   if file(XDRV_HB+cFILE+".CDX")
      erase(XDRV_HB+cFILE+".CDX")
   endif

return

static function i_totaliza_repres(zRepres,nREPVAL,nREPPTS)

       if nREPVAL <> 0 .or. nREPPTS <> 0
          REPRES->(dbseek(zREPRES))
          @ prow()+1,00 say replicate("-",132)
          @ prow()+1,00 say "Total do Representante.: "+REPRES->Razao
          @ prow()  ,92  say transform(nREPVAL, "@E 9,999,999.99")
          @ prow()  ,112 say transform(nREPPTS/100, "@E 9,999,999.99")
          @ prow()+1,00 say ""
          i_clube_prn(zRepres,nREPPTS)



          nREPVAL := 0
          nREPPTS := 0
          zRepres := (cFILE)->Cod_repres
       endif

return

static function i_xls(zRepres,nREPVAL,nREPPTS)

       if nREPVAL <> 0 .or. nREPPTS <> 0
          REPRES->(dbseek(zREPRES))
          @ prow()+1,00      say chr(9)+"Total do Representante.: "+REPRES->Razao
          @ prow()  ,pcol()  say chr(9)+chr(9)+chr(9)+transform(nREPVAL, "@E 9,999,999.99")
          @ prow()  ,pcol()  say chr(9)+transform(nREPPTS/100, "@E 9,999,999.99")
          @ prow()+1,00 say ""

          i_clube_xls(zRepres,nREPPTS)


          nREPVAL := 0
          nREPPTS := 0
          zRepres := (cFILE)->Cod_repres
       endif

return

static function i_clube_prn(zRepres,nREPPTS)

   local nTT_PTS := 0


   PREMIO->(dbsetorder(2))

   @ prow()+1,00  say "Clube Beneficio Siente La Luz..."
   @ prow()+1,00  say "Pontos de "+dtoc(dINI)+" a " + dtoc(dFIM)+" .: "
   @ prow()  ,112 say transf(nREPPTS/100,"@E 9,999,999.99")

   PREMIO->(dbgotop())
   if PREMIO->(dbseek(zREPRES))
      @ prow()+1,00 say "Premios regatados.:"
      do while ! PREMIO->(eof()) .and. PREMIO->Cod_repres == zREPRES
         if PREMIO->Data >= dINI .and. PREMIO->Data <= dFIM
            @ prow()+1,00  say left(PREMIO->Descricao,30)+" "+dtoc(PREMIO->Data)+": "
            @ prow()  ,112 say transf(PREMIO->Pontos/100,"@E 9,999,999.99")
            nTT_PTS += PREMIO->Pontos
         endif
         PREMIO->(dbskip())
      enddo
   endif
   @ prow()+1,00  say "Total de pontos retirados de  "+dtoc(dINI)+" a "+dtoc(dFIM)+": "
   @ prow()  ,112 say transf(nTT_PTS/100,"@E 9,999,999.99")

   @ prow()+1,00  say "Total de pontos a resgatar em "+dtoc(dFIM)+".: "
   @ prow()  ,112 say transf((nREPPTS-nTT_PTS)/100,"@E 9,999,999.99")
   @ prow()+1,00 say ""
   @ prow()+1,00 say ""


return

static function i_clube_xls(zRepres,nREPPTS)

   local nTT_PTS := 0


   PREMIO->(dbsetorder(2))

   @ prow()+1,00 say chr(9)+"Clube Beneficio Siente La Luz..."
   @ prow()+1,00 say chr(9)+"Pontos de "+dtoc(dINI)+" a " + dtoc(dFIM)+" .: "+chr(9)+chr(9)+chr(9)+chr(9)+transf(nREPPTS/100,"@E 9,999,999.99")

   PREMIO->(dbgotop())
   if PREMIO->(dbseek(zREPRES))
      @ prow()+1,00 say chr(9)+"Premios regatados.:"
      do while ! PREMIO->(eof()) .and. PREMIO->Cod_repres == zREPRES
         if PREMIO->Data >= dINI .and. PREMIO->Data <= dFIM
            @ prow()+1,00 say chr(9)+left(PREMIO->Descricao,30)+chr(9)+chr(9)+dtoc(PREMIO->Data)+chr(9)+chr(9)+transf(PREMIO->Pontos/100,"@E 9,999,999.99")
            nTT_PTS += PREMIO->Pontos
         endif
         PREMIO->(dbskip())
      enddo
   endif
   @ prow()+1,00 say chr(9)+"Total de pontos retirados de "+dtoc(dINI)+" a "+dtoc(dFIM)+":"+chr(9)+chr(9)+chr(9)+chr(9)+transf(nTT_PTS/100,"@E 9,999,999.99")
   @ prow()+1,00 say chr(9)+"Total de pontos a resgatar em "+dtoc(dFIM)+":"+chr(9)+chr(9)+chr(9)+chr(9)+transf((nREPPTS-nTT_PTS)/100,"@E 9,999,999.99")
   @ prow()+1,00 say ""


return

