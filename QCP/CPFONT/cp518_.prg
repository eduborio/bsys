/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO COMERCIO
// OBJETIVO...: LISTAGEM DE NOTAS FISCAIS
// ANALISTA...: EDUARDO AUGUSTO BORIO
// PROGRAMADOR: EDUARDO AUGUSTO BORIO
// INICIO.....: Outubro de 2006
// OBS........:
// ALTERACOES.:


function cp518
#define K_MAX_LIN 57

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG) .or. empty(dINI) }

private cTITULO                   // titulo do relatorio
private dINI
private dFIM
private cFORN  := space(5)
private cITEM := space(1)
private sBLOC1:= XSN

private aEDICAO := {}             // vetor para os campos de entrada de dados

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qgetx(-1,0,@dINI)            } , "INI"    })
aadd(aEDICAO,{{ || qgetx(-1,0,@dFIM)            } , "FIM"    })
aadd(aEDICAO,{{ || view_forn(-1,0,@cFORN   )      } , "FORN"  })
aadd(aEDICAO,{{ || NIL                          } , NIL  })
aadd(aEDICAO,{{ || qesco(-1,0,@cITEM,sBLOC1  )  } , "ITEM"  })

do while .T.

   qlbloc(5,0,"B518A","QBLOC.GLO")
   XNIVEL := 1
   XFLAG  := .T.
   dINI := dFIM := ctod("")
   cFORN := Space(5)
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
      case cCAMPO == "INI"
           dFIM := qfimmes(dINI)

      case cCAMPO == "FIM"
           if dFIM < dINI
             return .F.
           endif


      case cCAMPO == "FORN"

           qrsay(XNIVEL,cFORN)

           if empty(cFORN)
              qrsay(XNIVEL+1, "Todos os Fornecedores...")
           else
              if ! FORN->(Dbseek(cFORN))
                 qmensa("Fornecedor n„o encontrado","B")
                 return .F.
              else
                 qrsay(XNIVEL+1,left(FORN->Razao,30))
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


   cTITULO := "CONFERENCIA DE COMPRAS" +" de " + dtoc(dINI) + " a " + dtoc(dFIM)

   qmensa("")

   // ESTABELECE RELACOES ENTRE ARQUIVOS ____________________________________
   //PEDIDO->(dbSetFilter({|| !empty(PEDIDO->Cod_pedura) }, '!empty(PEDIDO->Cod_pedura)'))

   PEDIDO->(dbsetorder(1)) // data de emissao
   PEDIDO->(dbgotop())
   set softseek on
   PEDIDO->(Dbseek(dtos(dINI)))
   set softseek off
   LANC->(dbsetorder(1))
return .T.



static function i_impressao
   if ! qinitprn() ; return ; endif

   if XLOCALIMP == "X"
      i_impre_xls()
   else
      i_impre_prn()
   endif

return




/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impre_prn
    local nVAL_PED := 0
    local nTOTAL   := 0
    local nDESC    := 0
    local nTOT_DESC:= 0
    local nIPI     := 0
    local nVAL_UNI := 0

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________


   do while ! PEDIDO->(eof())  .and. PEDIDO->data_ped >= dINI .and. PEDIDO->data_ped <= dFIM  // condicao principal de loop


      FORN->(Dbseek(PEDIDO->Cod_forn))

      if ! empty(cFORN)
         if PEDIDO->Cod_forn != cFORN
            PEDIDO->(dbskip())
            loop
         endif
      endif


      if ! qlineprn() ; exit ; endif

      if XPAGINA == 0 .or. prow() > K_MAX_LIN
         @prow()+1,0 say XCOND0
         qpageprn()
         qcabecprn(cTITULO,80)
         @ prow()+1,0 say XCOND1 + "N.F.    Fornecedor                                               Cfop      Emissao         Valor da Nota "
         @ prow()+1,0 say ""
      endif

      qgirabarra()

      qmensa("Aguarde... Processando ...")

         FORN->(dbseek(PEDIDO->Cod_forn))

         @ prow()  ,00  say XCOND1
         @ prow()+1,01  say PEDIDO->Numero_Nf
         @ prow()  ,08  say left(FORN->Razao,50)
         @ prow()  ,65  say PEDIDO->Cfop
         @ prow()  ,75  say dtoc(PEDIDO->data_ped)

         LANC->(Dbgotop())
         LANC->(Dbseek(PEDIDO->Codigo))
         do while LANC->Cod_ped == PEDIDO->Codigo .and. ! LANC->(eof())

             PROD->(dbsetorder(4))
             PROD->(dbseek(LANC->Cod_Prod))
             nVAL_PED += (LANC->preco * LANC->Quant)
             nIPI += (LANC->preco * LANC->Quant) * (PROD->Ipi/100)
             LANC->(Dbskip())

         enddo
         nVAL_PED := nVAL_PED + nIPI
         @ prow()  ,94  say transform(nVAL_PED, "@E 999,999.99")
         nTOTAL += nVAL_PED

         if cITEM == "S"

            LANC->(Dbgotop())
            LANC->(Dbseek(PEDIDO->Codigo))
            do while LANC->Cod_ped == PEDIDO->Codigo .and. ! LANC->(eof())

               PROD->(dbsetorder(4))
               PROD->(dbseek(LANC->Cod_Prod))
               if prow() >= K_MAX_LIN
                  @prow()+1,0 say XCOND0
                  qpageprn()
                  qcabecprn(cTITULO,80)
                  @ prow()+1,0 say XCOND1 + "N.F.    Forncedor                                            Cfop       Emissao         Valor da Nota "
                  @ prow()+1,0 say ""
               endif

               @ prow()+1,00 say PROD->Cod_ass
               @ prow()  ,10 say left(PROD->Cod_fabr,8)
               @ prow()  ,20 say left(PROD->Descricao,25)
               @ prow()  ,50 say left(PROD->Marca,15)
               nVAL_UNI := LANC->preco + (LANC->preco * (PROD->Ipi/100) )
               @ prow()  ,68 say transf(nVAL_UNI,"@E 999,999.99")
               @ prow()  ,81 say transf(LANC->Quant,"@R 999999.99")
               @ prow()  ,94 say transf(LANC->Quant*nVAL_UNI,"@E 999,999.99")
               nVAL_UNI := 0

               LANC->(Dbskip())

           enddo
           @ prow()+1,00 say ""
         endif

         nVAL_PED := 0
         nIPI     := 0
         nDESC    := 0
         nTOT_DESC:= 0
      PEDIDO->(dbskip())

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


   do while ! PEDIDO->(eof())  .and. PEDIDO->data_ped >= dINI .and. PEDIDO->data_ped <= dFIM  // condicao principal de loop

      FORN->(Dbseek(PEDIDO->Cod_forn))

      if ! PEDIDO->Interface
         PEDIDO->(Dbskip())
         loop
      endif

      if ! empty(cFORN)
         if PEDIDO->Cod_forn != cFORN
            PEDIDO->(dbskip())
            loop
         endif
      endif


      if ! qlineprn() ; exit ; endif

      if XPAGINA == 0
         qpageprn()
         @ prow()+1,0 say ""+chr(9)+cTITULO + chr(9)+ "518"
         @ prow()+1,0 say  "N.F." +chr(9)+    "Forncedor"+chr(9)+  "Cfop"  +chr(9)+   "Emissao"  +chr(9)+       "Valor da Nota"
         @ prow()+1,0 say ""
      endif

      qgirabarra()

      qmensa("Aguarde... Processando ...")

         FORN->(dbseek(PEDIDO->Cod_forn))

         @ prow()+1,00      say PEDIDO->Numero_nf
         @ prow()  ,pcol()  say chr(9)+left(FORN->Razao,50)
         @ prow()  ,pcol()  say chr(9)+PEDIDO->Cfop
         @ prow()  ,pcol()  say chr(9)+dtoc(PEDIDO->data_ped)

         LANC->(Dbgotop())
         LANC->(Dbseek(PEDIDO->Codigo))
         do while LANC->Cod_ped == PEDIDO->Codigo .and. ! LANC->(eof())

             PROD->(dbsetorder(4))
             PROD->(dbseek(LANC->Cod_Prod))
             nVAL_PED += (LANC->preco * LANC->Quant)
             nIPI += (LANC->preco * LANC->Quant) * (PROD->Ipi/100)
             LANC->(Dbskip())

         enddo
         nVAL_PED := nVAL_PED + nIPI
         @ prow()  ,pcol()  say chr(9)+transform(nVAL_PED, "@E 999,999.99")
         nTOTAL += nVAL_PED

         if cITEM == "S"

            LANC->(Dbgotop())
            LANC->(Dbseek(PEDIDO->Codigo))
            do while LANC->Cod_ped == PEDIDO->Codigo .and. ! LANC->(eof())

               PROD->(dbsetorder(4))
               PROD->(dbseek(LANC->Cod_Prod))

               @ prow()+1,00     say chr(9)+PROD->Cod_ass
               @ prow()  ,pcol() say chr(9)+left(PROD->Cod_fabr,8)
               @ prow()  ,pcol() say chr(9)+left(PROD->Descricao,25)
               @ prow()  ,pcol() say chr(9)+left(PROD->Marca,15)
               nVAL_UNI := LANC->preco + (LANC->preco * (PROD->Ipi/100) )
               @ prow()  ,pcol() say chr(9)+transf(nVAL_UNI,"@E 999,999.99")
               @ prow()  ,pcol() say chr(9)+transf(LANC->Quant,"@R 999999.99")
               @ prow()  ,pcol() say chr(9)+transf(LANC->Quant*nVAL_UNI,"@E 999,999.99")
               nVAL_UNI := 0

               LANC->(Dbskip())

           enddo
           @ prow()+1,00 say ""
         endif

         nVAL_PED := 0
         nIPI     := 0
         nDESC    := 0
         nTOT_DESC:= 0
      PEDIDO->(dbskip())

   enddo

   @ prow()+1, 00 say chr(9)+Chr(9)+chr(9)+Chr(9)+transform(nTOTAL, "@E 9,999,999.99")

   qstopprn()

return

