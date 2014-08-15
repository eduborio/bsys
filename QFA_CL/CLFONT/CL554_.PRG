/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO COMERCIO
// OBJETIVO...: LISTAGEM DE NOTAS FISCAIS
// ANALISTA...: EDUARDO AUGUSTO BORIO
// PROGRAMADOR: EDUARDO AUGUSTO BORIO
// INICIO.....: setembro de 2006
// OBS........:
// ALTERACOES.:

function cl554
#define K_MAX_LIN 60

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||lastkey() == 27 }

private cTITULO                   // titulo do relatorio
private dINI
private dFIM
private cCLI    := space(5)
private cREPRES := space(5)
private cVEND   := space(5)
private cCFOP := space(4)
private cUFS  := space(2)
private cITEM := space(1)
private sBLOC1:= XSN
private cPEDINI := space(5)
private cPEDFIM := space(5)

private aEDICAO := {}             // vetor para os campos de entrada de dados

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qgetx(-1,0,@cPEDINI)        } , "PEDINI"    })
aadd(aEDICAO,{{ || qgetx(-1,0,@cPEDFIM)        } , "PEDFIM"    })

aadd(aEDICAO,{{ || qgetx(-1,0,@dINI)            } , "INI"    })
aadd(aEDICAO,{{ || qgetx(-1,0,@dFIM)            } , "FIM"    })
aadd(aEDICAO,{{ || view_cli(-1,0,@cCLI   )      } , "CLI"  })
aadd(aEDICAO,{{ || NIL                          } , NIL  })
aadd(aEDICAO,{{ || view_ufs(-1,0,@cUFS   )      } , "UFS"  })
aadd(aEDICAO,{{ || NIL                          } , NIL  })
aadd(aEDICAO,{{ || qesco(-1,0,@cITEM,sBLOC1  )  } , "ITEM"  })
aadd(aEDICAO,{{ || view_cfop(-1,0,@cCFOP )      } , "CFOP"  })
aadd(aEDICAO,{{ || NIL                          } , NIL  })

aadd(aEDICAO,{{ || view_repres(-1,0,@cREPRES )      } , "REPRES"  })
aadd(aEDICAO,{{ || NIL                          } , NIL  })

aadd(aEDICAO,{{ || view_vend(-1,0,@cVEND )      } , "VEND"})
aadd(aEDICAO,{{ || NIL                          } , NIL  })




do while .T.

   qlbloc(5,0,"B554A","QBLOC.GLO")
   XNIVEL := 1
   XFLAG  := .T.
   dINI := dFIM := ctod("")
   cCLI := Space(5)
   cCFOP := Space(4)
   cUFS := Space(2)
   cITEM:= Space(1)


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

      case cCAMPO == "PEDINI"
           if ! empty(cPEDINI)
              cPEDINI := strzero(val(cPEDINI),5)
              qrsay(XNIVEL,cPEDINI)
           endif

      case cCAMPO == "PEDFIM"
           if ! empty(cPEDFIM)
              cPEDFIM := strzero(val(cPEDFIM),5)
              qrsay(XNIVEL,cPEDFIM)
           endif


      case cCAMPO == "INI"
           if ! empty(dINI)
              dFIM := qfimmes(dINI)
           endif

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

      case cCAMPO == "CFOP"

           qrsay(XNIVEL,cCFOP)

           if empty(cCFOP)
              qrsay(XNIVEL+1, "Todos .......")
           else
              if ! CFOP->(Dbseek(cCFOP))
                 qmensa("C.F.O.P. n„o encontrado","B")
                 return .F.
              else
                 qrsay(XNIVEL+1,left(CFOP->Nat_desc,30))
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

      case cCAMPO == "VEND"

           qrsay(XNIVEL,cVEND)

           if empty(cVEND)
              qrsay(XNIVEL+1, "Todos os Vendedores.....")
           else
              if ! VEND->(Dbseek(cVEND))
                 qmensa("Vendedor n„o encontrado","B")
                 return .F.
              else
                 qrsay(XNIVEL+1,left(VEND->Nome,30))
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


   cTITULO := "CONFERENCIA DE NOTAS FISCAIS" +" de " + dtoc(dINI) + " a " + dtoc(dFIM)

   qmensa("")

   // ESTABELECE RELACOES ENTRE ARQUIVOS ____________________________________
   //FAT->(dbSetFilter({|| !empty(FAT->Num_fatura) }, '!empty(FAT->Num_fatura)'))

   if empty(cPEDINI)
      FAT->(dbsetorder(2)) // data de emissao
      FAT->(dbgotop())
      set softseek on
      FAT->(Dbseek(dtos(dINI)))
      set softseek off
   else
      FAT->(dbsetorder(1)) // data de emissao
      FAT->(dbgotop())
      set softseek on
      FAT->(Dbseek(cPEDINI))
      set softseek off
   endif
   ITEN_FAT->(dbsetorder(2))
return .T.



static function i_impressao
   if ! qinitprn() ; return ; endif

   if XLOCALIMP == "X"
      i_impre_xls()
   else
      if ! empty(cPEDINI)
         i_impre_ByPed()
      else
         i_impre_prn()
      endif
   endif

return




/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impre_byPed
    local nVAL_PED := 0
    local nTOTAL   := 0
    local nDESC    := 0
    local nTOT_DESC:= 0
    local nIPI     := 0
    local nVAL_UNI := 0

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________


   do while ! FAT->(eof())  .and. FAT->Codigo >= cPEDINI .and. FAT->Codigo <= cPEDFIM  // condicao principal de loop

      if FAT->Cancelado
         FAT->(dbskip())
         loop
      endif

      if empty(FAT->Num_fatura) .and. FAT->Es == "S"
         FAT->(dbskip())
         loop
      endif

      if ! empty(cCFOP)
         if FAT->Cod_cfop != cCFOP
            FAT->(Dbskip())
            loop
         endif
      endif

      if ! empty(cVEND)
         if FAT->Cod_vended != cVEND
            FAT->(Dbskip())
            loop
         endif
      endif

      if ! empty(cREPRES)
         if FAT->Cod_repres != cREPRES
            FAT->(Dbskip())
            loop
         endif
      endif





      CLI1->(Dbseek(FAT->Cod_cli))

      if ! empty(cUFS)
         CGM->(Dbseek(CLI1->Cgm_ent))
         if CGM->Estado != cUFS
            FAT->(dbskip())
            loop
         endif
      endif


      if ! empty(cCLI)
         if FAT->Cod_cli != cCli
            FAT->(dbskip())
            loop
         endif
      endif


      if ! qlineprn() ; exit ; endif

      if XPAGINA == 0 .or. prow() > K_MAX_LIN
         @prow()+1,0 say XCOND0
         qpageprn()
         qcabecprn(cTITULO,80)
         @ prow()+1,0 say XCOND1 + "N.F.    Cliente                                                  Cfop      Emissao         Valor da Nota   Tipo"
         @ prow()+1,0 say ""
      endif

      qgirabarra()

      qmensa("Aguarde... Processando ...")

         CLI1->(dbseek(FAT->Cod_cli))

         @ prow()  ,00  say XCOND1
         @ prow()+1,01  say FAT->Num_fatura
         @ prow()  ,08  say left(CLI1->Razao,50)
         @ prow()  ,65  say FAT->Cod_cfop
         @ prow()  ,75  say dtoc(FAT->Dt_emissao)

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
         nVAL_PED := nVAL_PED + nIPI
         @ prow()  ,94  say transform(nVAL_PED, "@E 999,999.99")
         if CONFIG->Modelo_2 == "7"
            TIPO_DOC->(dbseek(FAT->Tipo_doc))
            @ prow()  ,108  say left(TIPO_DOC->Descricao,10)
            @ prow()  ,120  say left(FAT->Obs,12)
         endif
         nTOTAL += nVAL_PED

         if cITEM == "S"

            ITEN_FAT->(Dbgotop())
            ITEN_FAT->(Dbseek(FAT->Codigo))
            do while ITEN_FAT->Num_fat == FAT->Codigo .and. ! ITEN_FAT->(eof())

               PROD->(dbsetorder(4))
               PROD->(dbseek(ITEN_FAT->Cod_Prod))
               if prow() >= K_MAX_LIN
                  @prow()+1,0 say XCOND0
                  qpageprn()
                  qcabecprn(cTITULO,80)
                  @ prow()+1,0 say XCOND1 + "N.F.    Cliente                                              Cfop       Emissao         Valor da Nota "
                  @ prow()+1,0 say ""
               endif

               @ prow()+1,00 say PROD->Cod_ass
               @ prow()  ,10 say left(PROD->Cod_fabr,8)
               @ prow()  ,20 say left(PROD->Descricao,25)
               @ prow()  ,50 say left(PROD->Marca,15)
               nVAL_UNI := ITEN_FAT->Vl_unitar + (ITEN_FAT->Vl_unitar * (ITEN_FAT->Ipi/100) )
               @ prow()  ,68 say transf(nVAL_UNI,"@E 999,999.99")
               @ prow()  ,81 say transf(ITEN_FAT->Quantidade,"@R 999999.99")
               @ prow()  ,94 say transf(ITEN_FAT->Quantidade*nVAL_UNI,"@E 999,999.99")
               nVAL_UNI := 0

               ITEN_FAT->(Dbskip())

           enddo
           @ prow()+1,00 say ""
         endif

         nVAL_PED := 0
         nIPI     := 0
         nDESC    := 0
         nTOT_DESC:= 0
      FAT->(dbskip())

   enddo

   @ prow()+1,00   say replicate("-",134)
   @ prow()+1, 78  say  "TOTAL -------------->"
   @ prow()  , 94  say transform(nTOTAL, "@E 9,999,999.99")

   qstopprn()

return

static function i_impre_prn
    local nVAL_PED := 0
    local nTOTAL   := 0
    local nDESC    := 0
    local nTOT_DESC:= 0
    local nIPI     := 0
    local nVAL_UNI := 0

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________


   do while ! FAT->(eof())  .and. FAT->Dt_emissao >= dINI .and. FAT->Dt_emissao <= dFIM  // condicao principal de loop

      if FAT->Cancelado
         FAT->(dbskip())
         loop
      endif

      if empty(FAT->Num_fatura) .and. FAT->Es == "S"
         FAT->(dbskip())
         loop
      endif

      if ! empty(cCFOP)
         if FAT->Cod_cfop != cCFOP
            FAT->(Dbskip())
            loop
         endif
      endif

      if ! empty(cVEND)
         if FAT->Cod_vended != cVEND
            FAT->(Dbskip())
            loop
         endif
      endif

      if ! empty(cREPRES)
         if FAT->Cod_repres != cREPRES
            FAT->(Dbskip())
            loop
         endif
      endif




      CLI1->(Dbseek(FAT->Cod_cli))

      if ! empty(cUFS)
         CGM->(Dbseek(CLI1->Cgm_ent))
         if CGM->Estado != cUFS
            FAT->(dbskip())
            loop
         endif
      endif


      if ! empty(cCLI)
         if FAT->Cod_cli != cCli
            FAT->(dbskip())
            loop
         endif
      endif


      if ! qlineprn() ; exit ; endif

      if XPAGINA == 0 .or. prow() > K_MAX_LIN
         @prow()+1,0 say XCOND0
         qpageprn()
         qcabecprn(cTITULO,80)
         @ prow()+1,0 say XCOND1 + "N.F.    Cliente                                                  Cfop      Emissao         Valor da Nota   Tipo"
         @ prow()+1,0 say ""
      endif

      qgirabarra()

      qmensa("Aguarde... Processando ...")

         CLI1->(dbseek(FAT->Cod_cli))

         @ prow()  ,00  say XCOND1
         @ prow()+1,01  say FAT->Num_fatura
         @ prow()  ,08  say left(CLI1->Razao,50)
         @ prow()  ,65  say FAT->Cod_cfop
         @ prow()  ,75  say dtoc(FAT->Dt_emissao)

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
         nVAL_PED := nVAL_PED + nIPI
         @ prow()  ,94  say transform(nVAL_PED, "@E 999,999.99")
         if CONFIG->Modelo_2 == "7"
            TIPO_DOC->(dbseek(FAT->Tipo_doc))
            @ prow()  ,108  say left(TIPO_DOC->Descricao,20)
         endif
         nTOTAL += nVAL_PED

         if cITEM == "S"

            ITEN_FAT->(Dbgotop())
            ITEN_FAT->(Dbseek(FAT->Codigo))
            do while ITEN_FAT->Num_fat == FAT->Codigo .and. ! ITEN_FAT->(eof())

               PROD->(dbsetorder(4))
               PROD->(dbseek(ITEN_FAT->Cod_Prod))
               if prow() >= K_MAX_LIN
                  @prow()+1,0 say XCOND0
                  qpageprn()
                  qcabecprn(cTITULO,80)
                  @ prow()+1,0 say XCOND1 + "N.F.    Cliente                                              Cfop       Emissao         Valor da Nota "
                  @ prow()+1,0 say ""
               endif

               @ prow()+1,00 say PROD->Cod_ass
               @ prow()  ,10 say left(PROD->Cod_fabr,8)
               @ prow()  ,20 say left(PROD->Descricao,25)
               @ prow()  ,50 say left(PROD->Marca,15)
               nVAL_UNI := ITEN_FAT->Vl_unitar + (ITEN_FAT->Vl_unitar * (ITEN_FAT->Ipi/100) )
               @ prow()  ,68 say transf(nVAL_UNI,"@E 999,999.99")
               @ prow()  ,81 say transf(ITEN_FAT->Quantidade,"@R 999999.99")
               @ prow()  ,94 say transf(ITEN_FAT->Quantidade*nVAL_UNI,"@E 999,999.99")
               nVAL_UNI := 0

               ITEN_FAT->(Dbskip())

           enddo
           @ prow()+1,00 say ""
         endif

         nVAL_PED := 0
         nIPI     := 0
         nDESC    := 0
         nTOT_DESC:= 0
      FAT->(dbskip())

   enddo

   @ prow()+1,00   say replicate("-",134)
   @ prow()+1, 78  say  "TOTAL -------------->"
   @ prow()  , 94  say transform(nTOTAL, "@E 9,999,999.99")

   qstopprn()

return



/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impre_xls
    local nVAL_PED := 0
    local nTOTAL   := 0
    local nDESC    := 0
    local nTOT_DESC:= 0
    local nIPI     := 0
    local nVAL_UNI := 0

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________


   do while ! FAT->(eof())  .and. FAT->Dt_emissao >= dINI .and. FAT->Dt_emissao <= dFIM  // condicao principal de loop

      if FAT->Cancelado
         FAT->(dbskip())
         loop
      endif


      if empty(FAT->Num_fatura) .and. FAT->Es == "S"
         FAT->(dbskip())
         loop
      endif

      if ! empty(cCFOP)
         if FAT->Cod_cfop != cCFOP
            FAT->(Dbskip())
            loop
         endif
      endif

      if ! empty(cVEND)
         if FAT->Cod_vended != cVEND
            FAT->(Dbskip())
            loop
         endif
      endif

      if ! empty(cREPRES)
         if FAT->Cod_repres != cREPRES
            FAT->(Dbskip())
            loop
         endif
      endif



      CLI1->(Dbseek(FAT->Cod_cli))

      if ! empty(cUFS)
         CGM->(Dbseek(CLI1->Cgm_ent))
         if CGM->Estado != cUFS
            FAT->(dbskip())
            loop
         endif
      endif


      if ! empty(cCLI)
         if FAT->Cod_cli != cCli
            FAT->(dbskip())
            loop
         endif
      endif


      if ! qlineprn() ; exit ; endif

      if XPAGINA == 0
         qpageprn()
         @ prow()+1,0 say ""+chr(9)+cTITULO + chr(9)+ "554"
         @ prow()+1,0 say  "N.F." +chr(9)+    "Cliente" +chr(9)+  "Cfop"  +chr(9)+   "Emissao"  +chr(9)+       "Valor da Nota"
         @ prow()+1,0 say ""
      endif

      qgirabarra()

      qmensa("Aguarde... Processando ...")

         CLI1->(dbseek(FAT->Cod_cli))

         @ prow()+1,00      say FAT->Num_fatura
         @ prow()  ,pcol()  say chr(9)+left(CLI1->Razao,50)
         @ prow()  ,pcol()  say chr(9)+FAT->Cod_cfop
         @ prow()  ,pcol()  say chr(9)+dtoc(FAT->Dt_emissao)

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
         nVAL_PED := nVAL_PED + nIPI
         @ prow()  ,pcol()  say chr(9)+transform(nVAL_PED, "@E 999,999.99")
         if CONFIG->Modelo_2 == "7"
            TIPO_DOC->(dbseek(FAT->Tipo_doc))
            @ prow()  ,pcol()  say chr(9)+left(TIPO_DOC->Descricao,20)
         endif

         nTOTAL += nVAL_PED

         if cITEM == "S"

            ITEN_FAT->(Dbgotop())
            ITEN_FAT->(Dbseek(FAT->Codigo))
            do while ITEN_FAT->Num_fat == FAT->Codigo .and. ! ITEN_FAT->(eof())

               PROD->(dbsetorder(4))
               PROD->(dbseek(ITEN_FAT->Cod_Prod))

               @ prow()+1,00     say chr(9)+PROD->Cod_ass
               @ prow()  ,pcol() say chr(9)+left(PROD->Cod_fabr,8)
               @ prow()  ,pcol() say chr(9)+left(PROD->Descricao,25)
               @ prow()  ,pcol() say chr(9)+left(PROD->Marca,15)
               nVAL_UNI := ITEN_FAT->Vl_unitar + (ITEN_FAT->Vl_unitar * (ITEN_FAT->Ipi/100) )
               @ prow()  ,pcol() say chr(9)+transf(nVAL_UNI,"@E 999,999.99")
               @ prow()  ,pcol() say chr(9)+transf(ITEN_FAT->Quantidade,"@R 999999.99")
               @ prow()  ,pcol() say chr(9)+transf(ITEN_FAT->Quantidade*nVAL_UNI,"@E 999,999.99")
               nVAL_UNI := 0

               ITEN_FAT->(Dbskip())

           enddo
           @ prow()+1,00 say ""
         endif

         nVAL_PED := 0
         nIPI     := 0
         nDESC    := 0
         nTOT_DESC:= 0
      FAT->(dbskip())

   enddo

   @ prow()+1, 00 say chr(9)+Chr(9)+chr(9)+Chr(9)+transform(nTOTAL, "@E 9,999,999.99")

   qstopprn(.F.)

return

