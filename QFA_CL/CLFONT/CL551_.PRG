/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO COMERCIO
// OBJETIVO...: LISTAGEM DE PRODUTOS
// ANALISTA...: EDUARDO AUGUSTO BORIO
// PROGRAMADOR: EDUARDO AUGUSTO BORIO
// INICIO.....: SETEMBRO DE 2006
// OBS........:
// ALTERACOES.:

function cl551
#define K_MAX_LIN 57

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG) .or. empty(dINI) .or. lastkey() == 27 }

private cTITULO                   // titulo do relatorio
private dINI
private dFIM
private cCLI       := space(5)
private cREPRES    := space(5)
private cCLI_ATUAL := space(5)
private cUFS       := space(2)
private cITEM      := space(1)
private cULTIMAS   := 0
private aEDICAO := {}             // vetor para os campos de entrada de dados
private aFAT    := {}
private lTEM    := .F.
private sBLOC1  := XSN

if ! quse(XDRV_CL,"CLI_TMP",{"CLI_TMP1"},"E")
   qmensa("N„o foi poss¡vel abrir arquivo temporario !! Tente novamente.")
   return
endif


// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qgetx(-1,0,@dINI)            } , "INI"    })
aadd(aEDICAO,{{ || qgetx(-1,0,@dFIM)            } , "FIM"    })

aadd(aEDICAO,{{ || view_cli(-1,0,@cCLI   )      } , "CLI"  })
aadd(aEDICAO,{{ || NIL                          } , NIL  })

aadd(aEDICAO,{{ || view_cli(-1,0,@cREPRES   )      } , "REPRES"  })
aadd(aEDICAO,{{ || NIL                          } , NIL  })

aadd(aEDICAO,{{ || view_ufs(-1,0,@cUFS   )      } , "UFS"  })
aadd(aEDICAO,{{ || NIL                          } , NIL  })
aadd(aEDICAO,{{ || qesco(-1,0,@cITEM,sBLOC1  )  } , "ITEM"  })

aadd(aEDICAO,{{ || qgetx(-1,0,@cULTIMAS,"999")        } ,"ULTIMAS"    })


do while .T.

   qlbloc(5,0,"B551A","QBLOC.GLO")
   XNIVEL      := 1
   XFLAG       := .T.
   dINI        := qinimes(date())
   cCLI        := space(5)
   cCLI_ATUAL  := space(5)
   cUFS        := space(2)
   cULTIMAS    := 0
   lTEM        := .F.

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

CLI_TMP->(DbCloseArea())


/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA _____________________________________________

static function i_critica ( cCAMPO )

   do case
      case cCAMPO == "INI"
           dFIM := qfimmes(dINI)

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

      case cCAMPO == "CLI"

           qrsay(XNIVEL,cCLI)

           if empty(cCLI)
              qrsay(XNIVEL+1, "Todos os Clientes.......")
           else
              if ! CLI1->(Dbseek(cCLI))
                 qmensa("Cliente n„o encontrado","B")
                 return .F.
              else
                 qrsay(XNIVEL+1,left(CLI1->Razao,30))
              endif
              XNIVEL++
           endif


      case cCAMPO == "REPRES"

           qrsay(XNIVEL,cREPRES)

           if empty(cREPRES)
              qrsay(XNIVEL+1, "Todos os Representantes......")
           else
              if ! REPRES->(Dbseek(cREPRES))
                 qmensa("Representante n„o encontrado","B")
                 return .F.
              else
                 qrsay(XNIVEL+1,left(REPRES->Razao,30))
              endif
              XNIVEL++
           endif


      case cCAMPO == "ITEM"

           if empty(cITEM) ; return .F. ; endif
           qrsay(XNIVEL,qabrev(cITEM,"SN",{"Sim","N„o"}))




   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // CRIA TITULO DO RELATORIO ______________________________________________
   cTITULO := "Ausencia de Compras de Cliente por Periodo" +" de " + dtoc(dINI) + " a " + dtoc(dFIM)

   qmensa("")

   // ESTABELECE RELACOES ENTRE ARQUIVOS ____________________________________

   FAT->(dbsetfilter({|| FAT->Dt_emissao >= dINI .and. FAT->Dt_emissao <= dFIM .and. ! FAT->Cancelado .and. FAT->Es == "S" .and. ! empty(FAT->Num_fatura) .and. (left(FAT->Cod_Cfop,3) $ "610-510-611-511-612-512") }))
   FAT->(dbsetorder(6)) // Codigo do Cliente
   FAT->(dbgotop())

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

////////////////////////////////////////////////////////
// FUNCAO DE IMPRESSAO NA IMPORESSORA

static function i_impre_prn
   local nCONT := 0
   local nCONT_ULT := 0

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   CLI_TMP->(__dbzap()) //Apaga todos os Regsitros do Arquivo temporario

   i_cli_comprou()      //Busca Clientes que Compraram no Periodo

   i_cli_nao_comprou()  //Apura Clientes que nao Compraram no Periodo

   FAT->(DbClearFilter())
   FAT->(dbsetfilter({|| FAT->Dt_emissao < dINI .and. ! FAT->Cancelado .and. FAT->Es == "S" .and. ! empty(FAT->Num_fatura)  .and. (left(FAT->Cod_Cfop,3) $ "610-510-611-511-612-512") }))

   aFAT := asort(aFAT,,,{|x,y| x[3] < y[3] })



   if lTEM
      nCONT := 1
      Do While nCONT <= len(aFAT)

         if XPAGINA == 0 .or. prow() > K_MAX_LIN
            @prow()+1,0 say XCOND1
            qpageprn()
            qcabecprn(cTITULO,136)
            @ prow()+1,0 say XCOND1 + "Cliente                                 Contato           Telefone       Emissao     N.F.         Total    UF  Representante"
            @ prow()+1,0 say replicate("-",136)
         endif

         if cULTIMAS == 0
            @ prow()+1,00 say  aFAT[nCONT,2]
         endif


         if FAT->(dbseek(aFAT[nCONT,1]))
            FAT->(qseekn(aFAT[nCONT,1]))
            For nCONT_ULT := 1 to cULTIMAS

                if FAT->Cod_cli == aFAT[nCONT,1] .and. ! FAT->(Bof())
                   CLI1->(Dbseek(FAT->Cod_cli))
                   if prow() > K_MAX_LIN
                      @ prow()+1,0 say XCOND1
                      qpageprn()
                      qcabecprn(cTITULO,136)
                      @ prow()+1,0 say XCOND1 + "Cliente                                 Contato           Telefone       Emissao     N.F.         Total    UF  Representante"
                      @ prow()+1,0 say replicate("-",136)
                   endif

                   @ prow()+1,00 say left(CLI1->Razao,38)
                   @ prow()  ,40 say left(CLI1->Contato_c,13)
                   @ prow()  ,58 say left(CLI1->Fone1,13)
                   @ prow()  ,73 say dtoc(FAT->Dt_emissao)
                   @ prow()  ,85 say FAT->Num_fatura

                   nTOTAL := 0

                   ITEN_FAT->(Dbseek(FAT->Codigo))

                   Do While ! ITEN_FAT->(Eof()) .and. ITEN_FAT->Num_fat == FAT->Codigo
                      PROD->(Dbsetorder(4)) ; PROD->(dbseek(ITEN_FAT->Cod_Prod))

                      nTOTAL += ( (ITEN_FAT->Quantidade * ITEN_FAT->Vl_unitar) * (ITEN_FAT->Ipi/100) )
                      nTOTAL += (ITEN_FAT->Quantidade * ITEN_FAT->Vl_unitar)
                      ITEN_FAT->(Dbskip())
                   enddo

                   @ prow()  ,93 say transf(nTOTAL,"@E 999,999.99")
                   nTOTAL := 0
                   CGM->(Dbseek(CLI1->Cgm_ent))
                   REPRES->(Dbseek(FAT->Cod_repres))
                   @ prow()  ,105  say CGM->Estado
                   @ prow()  ,108 say left(REPRES->Razao,15)

                   if VEND->(dbseek(CLI1->Resp))
                      @ prow()  ,126 say left(VEND->Nome,10)
                   endif

                   if RESTRI->(dbseek(FAT->Cod_cli))
                      @ prow()+1, 00 say "Cliente com Restricao: " + RESTRI->Obs
                   endif

                   if cITEM == "S"
                      ITEN_FAT->(Dbseek(FAT->Codigo))
                      nTOTAL := 0
                      Do While ! ITEN_FAT->(Eof()) .and. ITEN_FAT->Num_fat == FAT->Codigo

                         if prow() > K_MAX_LIN
                            @prow()+1,0 say XCOND1
                            qpageprn()
                            qcabecprn(cTITULO,136)
                            @ prow()+1,0 say XCOND1 + "Cliente                                 Contato           Telefone       Emissao     N.F.         Total    UF  Representante"
                            @ prow()+1,0 say replicate("-",136)
                         endif
                         PROD->(Dbsetorder(4)) ; PROD->(dbseek(ITEN_FAT->Cod_Prod))

                         @ prow()+1,00 say PROD->Cod_ass
                         @ prow()  ,09 say left(PROD->Cod_fabr,8)
                         @ prow()  ,18 say left(PROD->Descricao,20)
                         @ prow()  ,43 say left(PROD->Marca,15)
                         @ prow()  ,60 say transf(ITEN_FAT->Quantidade,"@R 999999")
                         @ prow()  ,70 say transf(ITEN_FAT->Vl_unitar+(ITEN_FAT->Vl_unitar*(ITEN_FAT->ipi/100)),"@E 99,999.99")
                         nTOTAL += ( (ITEN_FAT->Quantidade * ITEN_FAT->Vl_unitar) * (ITEN_FAT->Ipi/100) )
                         nTOTAL += (ITEN_FAT->Quantidade * ITEN_FAT->Vl_unitar)
                         @ prow()  ,82 say transf(nTOTAL,"@E 999,999.99")
                         nTOTAL := 0


                         ITEN_FAT->(Dbskip())
                      enddo
                      if prow() < K_MAX_LIN
                         @ prow()+1,00 say ""
                      endif
                   endif




                   FAT->(Dbskip(-1))
                endif
            next

         endif

         @ prow()+1,00 say ""

         nCONT++
         if nCONT > len(aFAT)
            nCONT := len(aFAT)
            exit
         endif

      enddo


   endif
   aFAT := {}
   qstopprn()
return

////////////////////////////////////////////////////////
// FUNCAO DE IMPRESSAO em Excel

static function i_impre_Xls
   local nCONT := 0
   local nCONT_ULT := 0

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   CLI_TMP->(__dbzap()) //Apaga todos os Regsitros do Arquivo temporario

   i_cli_comprou()      //Busca Clientes que Compraram no Periodo

   i_cli_nao_comprou()  //Apura Clientes que nao Compraram no Periodo

   FAT->(DbClearFilter())
   FAT->(dbsetfilter({|| FAT->Dt_emissao < dINI .and. ! FAT->Cancelado .and. FAT->Es == "S" .and. ! empty(FAT->Num_fatura)  .and. (left(FAT->Cod_Cfop,3) $ "610-510-611-511-612-512") }))

   asFAT := asort(aFAT,,,{|x,y| x[3] < y[3] })
   aFAT := {}


   if lTEM
      nCONT := 1
      Do While nCONT <= len(asFAT)

         if XPAGINA == 0
            qpageprn()
            @prow ()+1,0 say cTITULO + " "+"551"
            @ prow()+1,0 say "Cliente" +chr(9)+ "Contato" +chr(9)+  "Telefone" +chr(9)+ "Emissao"  +chr(9)+ "N.F." +chr(9)+  "Total"   +chr(9)+ "UF" +chr(9)+  "Representante"
            @ prow()+1,0 say ""
         endif

         if cULTIMAS == 0
            @ prow()+1,00 say  asFAT[nCONT,2]
         endif


         if FAT->(dbseek(asFAT[nCONT,1]))
            FAT->(qseekn(asFAT[nCONT,1]))
            For nCONT_ULT := 1 to cULTIMAS

                if FAT->Cod_cli == asFAT[nCONT,1] .and. ! FAT->(Bof())
                   CLI1->(Dbseek(FAT->Cod_cli))

                   @ prow()+1,00 say left(CLI1->Razao,38)
                   @ prow()  ,pcol() say chr(9)+ left(CLI1->Contato_c,13)
                   @ prow()  ,pcol() say chr(9)+ left(CLI1->Fone1,13)
                   @ prow()  ,pcol() say chr(9)+ dtoc(FAT->Dt_emissao)
                   @ prow()  ,pcol() say chr(9)+ FAT->Num_fatura

                   nTOTAL := 0

                   ITEN_FAT->(Dbseek(FAT->Codigo))
                   PROD->(Dbsetorder(4)) ; PROD->(dbseek(ITEN_FAT->Cod_Prod))

                   Do While ! ITEN_FAT->(Eof()) .and. ITEN_FAT->Num_fat == FAT->Codigo
                      nTOTAL += ( (ITEN_FAT->Quantidade * ITEN_FAT->Vl_unitar) * (ITEN_FAT->Ipi/100) )
                      nTOTAL += (ITEN_FAT->Quantidade * ITEN_FAT->Vl_unitar)
                      ITEN_FAT->(Dbskip())
                   enddo

                   @ prow()  ,pcol() say chr(9) + transf(nTOTAL,"@E 999,999.99")
                   nTOTAL := 0
                   CGM->(Dbseek(CLI1->Cgm_ent))
                   REPRES->(Dbseek(FAT->Cod_repres))
                   @ prow()  ,pcol() say chr(9)+  CGM->Estado
                   @ prow()  ,pcol() say chr(9)+  left(REPRES->Razao,20)
                   if VEND->(dbseek(CLI1->Resp))
                      @ prow()  ,pcol() say chr(9)+left(VEND->Nome,20)
                   endif

                   if RESTRI->(dbseek(FAT->Cod_cli))
                      @ prow()+1, 00 say "Cliente com Restricao: " + RESTRI->Obs
                   endif


                   if cITEM == "S"

                      ITEN_FAT->(Dbseek(FAT->Codigo))
                      nTOTAL := 0
                      Do While ! ITEN_FAT->(Eof()) .and. ITEN_FAT->Num_fat == FAT->Codigo

                         PROD->(Dbsetorder(4)) ; PROD->(dbseek(ITEN_FAT->Cod_Prod))

                         @ prow()+1,00     say left(PROD->Descricao,50)
                         @ prow()  ,pcol() say chr(9)+ PROD->Cod_ass
                         @ prow()  ,pcol() say chr(9)+ left(PROD->Cod_fabr,8)
                         @ prow()  ,pcol() say chr(9)+ left(PROD->Marca,15)
                         @ prow()  ,pcol() say chr(9)+ transf(ITEN_FAT->Quantidade,"@R 999999")
                         @ prow()  ,pcol() say chr(9)+ transf(ITEN_FAT->Vl_unitar+(ITEN_FAT->Vl_unitar*(ITEN_FAT->ipi/100)),"@E 99,999.99")
                         nTOTAL += ( (ITEN_FAT->Quantidade * ITEN_FAT->Vl_unitar) * (ITEN_FAT->Ipi/100) )
                         nTOTAL += (ITEN_FAT->Quantidade * ITEN_FAT->Vl_unitar)
                         @ prow()  ,pcol() say chr(9)+ transf(nTOTAL,"@E 999,999.99")
                         nTOTAL := 0


                         ITEN_FAT->(Dbskip())
                      enddo
                      if prow() < K_MAX_LIN
                         @ prow()+1,00 say ""
                      endif
                   endif




                   FAT->(Dbskip(-1))
                endif
            next

         endif

         @ prow()+1,00 say ""

         nCONT++
         if nCONT > len(asFAT)
            nCONT := len(asFAT)
            exit
         endif

      enddo


   endif
   asFAT := {}
   qstopprn()
return



static function i_cli_comprou

   FAT->(Dbgotop())
   cCLI_ATUAL := FAT->Cod_cli
   do while ! FAT->(eof()) // condicao principal de loop

      CLI1->(dbseek(FAT->Cod_cli))

      CGM->(Dbseek(CLI1->Cgm_ent))

      FAT->(dbskip())

      if FAT->Cod_cli != cCLI_ATUAL
         if CLI_TMP->(qappend())
            replace CLI_TMP->Cod_cli with cCLI_ATUAL
            cCLI_ATUAL := FAT->Cod_cli
         endif
      endif


   enddo



   if FAT->Cod_cli != cCLI_ATUAL
      if CLI_TMP->(qappend())
         replace CLI_TMP->Cod_cli with cCLI_ATUAL
         cCLI_ATUAL := FAT->Cod_cli
      endif
   endif

  CLI_TMP->(DbCommit())


   cCLI_ATUAL := space(5)
return

static function i_cli_nao_comprou
   CLI1->(Dbsetorder(1))
   CLI1->(dbGotop())
   CLI_TMP->(Dbsetorder(1))
   CLI_TMP->(dbGotop())

   if empty(cCLI)
      do while ! CLI1->(Eof())

         if ! empty(cUFS)
            CGM->(Dbseek(CLI1->Cgm_ent))
            if ! CGM->Estado == cUFS
               CLI1->(Dbskip())
               loop
            endif
         endif

         if ! empty(cREPRES)
            if CLI1->Cod_repres != cREPRES
               CLI1->(Dbskip())
               loop
            endif
         endif


         if ! CLI_TMP->(Dbseek(CLI1->Codigo))
            aadd(aFAT,{CLI1->Codigo,CLI1->Razao,CLI1->Cod_repres})
         endif

         CLI1->(Dbskip())
      enddo
   else
      if ! CLI_TMP->(dbseek(cCLI))
         CLI1->(dbseek(cCLI))
         aadd(aFAT,{CLI1->Codigo,CLI1->Razao})
         qmensa(CLI1->Codigo +  " - " + CLI1->Razao )
      endif
   endif

   if len(aFAT) > 0
      lTEM := .T.
   endif

return

