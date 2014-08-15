//////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO COMERCIO
// OBJETIVO...: LISTAGEM DE PRODUTOS FATURADOS
// ANALISTA...: EDUARDO AUGUSTO BORIO
// PROGRAMADOR: EDUARDO AUGUSTO BORIO
// INICIO.....: SETEMBRO DE 2002
// OBS........:
// ALTERACOES.:

function cl577
#define K_MAX_LIN 57

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG) .or. empty(dINI) }

private cTITULO                   // titulo do relatorio
private dINI
private dFIM
private cCLI := space(5)
private aEDICAO := {}             // vetor para os campos de entrada de dados

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qgetx(-1,0,@dINI)            } , "INI"    })
aadd(aEDICAO,{{ || qgetx(-1,0,@dFIM)            } , "FIM"    })
//aadd(aEDICAO,{{ || view_cli2(-1,0,@cCLI)        } , "CLI"  })
//aadd(aEDICAO,{{ || NIL                          } , NIL  })

do while .T.

   qlbloc(5,0,"B519A","QBLOC.GLO")
   XNIVEL := 1
   XFLAG  := .T.
   dINI := dFIM := ctod("")

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

      case cCAMPO == "CLI"

           qrsay(XNIVEL,cCLI)

           if empty(cCLI)
              qrsay(XNIVEL++, "Todos os Clientes.......")
           else
              if ! CLI1->(Dbseek(cSETOR:=strzero(val(cCLI),5)))
                 qmensa("Cliente n„o Cadastrado","B")
                 return .F.
              else
                 qrsay(XNIVEL++,left(CLI1->Razao,30))
              endif
           endif

   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // CRIA TITULO DO RELATORIO ______________________________________________


   cTITULO := "LISTAGEM DE PRODUTOS BAIXADOS" +" de " + dtoc(dINI) + " a " + dtoc(dFIM)

   qmensa("")

   // ESTABELECE RELACOES ENTRE ARQUIVOS ____________________________________

   FAT->(dbsetfilter({|| Dt_emissao >= dINI  .and. Dt_emissao <= dFIM .and. !Cancelado .and. left(cod_cfop,4) $ "5949-6949" }))
   ITEN_FAT->(dbsetorder(2))
   FAT->(dbsetorder(1))
   FAT->(dbgotop())

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
    local nQtyMotivo := 0
    local nQtyProd   := 0
    local nQtyTotal  := 0

    local nVlrMotivo := 0
    local nVlrProd   := 0
    local nVlrTotal  := 0
    local nVALOR     := 0

    local nCONT      := 0
    local cPROD      := 0
    local aFAT       := {}
    local asFAT      := {}
    local lTEM := .T.
    local zPROD := space(50)

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________
    lTEM := .F.

   do while ! FAT->(eof())  

      qgirabarra()

      qmensa("Aguarde... Processando ...")

         CLI1->(dbseek(FAT->Cod_cli))

         ITEN_FAT->(Dbgotop())
         ITEN_FAT->(Dbseek(FAT->Codigo))
         do while ITEN_FAT->Num_fat == FAT->Codigo .and. ! ITEN_FAT->(eof())
             PROD->(dbsetorder(4))
             PROD->(dbseek(ITEN_FAT->Cod_Prod))
             nVALOR := nVALOR + (ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade)
             nVALOR += q_soma_st()

             aadd(aFAT,{right(PROD->Codigo,5),ITEN_FAT->cod_Motbai,ITEN_FAT->Quantidade,ITEN_FAT->Vl_unitar,nVALOR})

             ITEN_FAT->(Dbskip())
             nVALOR := 0
             lTEM := .T.
         enddo
         FAT->(dbskip())
         nVALOR := 0
         nDESC := 0
   enddo

   //classifica a matriz por descricao do produto
   asFAT := asort(aFAT,,,{|x,y| x[1] + x[2] < y[1] + y[2] })
   if lTEM

       cPROD    := asFAT[1,1]
       cMOTIVO  := asFAT[1,2]
       PROD->(dbseek(cPROD))
       MOTBAI->(dbseek(cMOTIVO))
       zPROD   := left(PROD->Cod_fabr,6)+" "+PROD->Cod_ass+" "+left(PROD->Descricao,30)
       zMOTIVO := left(MOTBAI->Descricao,25)


       nCONT := 1
       do while  nCONT <= len(asFAT)

           if ! qlineprn() ; exit ; endif
           if XPAGINA == 0 .or. prow() > K_MAX_LIN
              @prow()+1,0 say XCOND1
              qpageprn()
              qcabecprn(cTITULO,132)
              @ prow()+1,0 say "Produto                               Motivo                 Qtde            Valor "
              @ prow()+1,0 say replicate("-",134)
           endif

           nQtyMotivo += asFAT[nCONT,3]
           nQtyProd   += asFAT[nCONT,3]
           nQtyTotal  += asFAT[nCONT,3]

           nVlrMotivo += asFAT[nCONT,5]
           nVlrProd   += asFAT[nCONT,5]
           nVlrTotal  += asFAT[nCONT,5]

           nCONT++
           if nCONT > len(asFAT)
              nCONT := len(asFAT)
              exit
           endif

           if asFAT[nCONT,2] != cMOTIVO
              @ prow()+1,00 say zPROD
              @ prow()  ,50 say zMOTIVO
              @ prow()  ,80 say transf(nQtyMotivo,"@R 999999")
              @ prow()  ,90 say transf(nVlrMotivo,"@E 99,999,999.99")

              cPROD   := asFAT[nCONT,1]
              cMOTIVO := asFAT[nCONT,2]
              PROD->(dbseek(cPROD))
              zPROD   := left(PROD->Cod_fabr,6)+" "+PROD->Cod_ass+" "+left(PROD->Descricao,30)
              MOTBAI->(dbseek(cMOTIVO))
              zMOTIVO := left(MOTBAI->Descricao,25)

              nQtyMotivo   := 0
              nVlrMotivo   := 0
           endif


           if asFAT[nCONT,1] != cPROD
              @ prow()+1,00 say "Total do Produto.: "+zPROD
              @ prow()  ,80 say transf(nQtyProd,"@R 999999")
              @ prow()  ,90 say transf(nVlrProd,"@E 99,999,999.99")

              cPROD   := asFAT[nCONT,1]
              cMOTIVO := asFAT[nCONT,2]
              PROD->(dbseek(cPROD))
              zPROD   := left(PROD->Cod_fabr,6)+" "+PROD->Cod_ass+" "+left(PROD->Descricao,30)
              MOTBAI->(dbseek(cMOTIVO))
              zMOTIVO := left(MOTBAI->Descricao,25)

              nQtyProd  := 0
              nQtyValor := 0
              nQtyMotivo   := 0
              nVlrMotivo   := 0
           endif
       enddo

          @ prow()+1,00 say zPROD
          @ prow()  ,50 say zMOTIVO
          @ prow()  ,80 say transf(nQtyMotivo,"@R 999999")
          @ prow()  ,90 say transf(nVlrMotivo,"@E 99,999,999.99")

          cPROD   := asFAT[nCONT,1]
          cMOTIVO := asFAT[nCONT,2]
          PROD->(dbseek(cPROD))
          zPROD   := left(PROD->Cod_fabr,6)+" "+PROD->Cod_ass+" "+left(PROD->Descricao,30)
          MOTBAI->(dbseek(cMOTIVO))
          zMOTIVO := left(MOTBAI->Descricao,25)

          nQtyMotivo   := 0
          nVlrMotivo   := 0

          @ prow()+1,00 say "Total do Produto.: "+zPROD
          @ prow()  ,80 say transf(nQtyProd,"@R 999999")
          @ prow()  ,90 say transf(nVlrProd,"@E 99,999,999.99")

          cPROD   := asFAT[nCONT,1]
          cMOTIVO := asFAT[nCONT,2]
          PROD->(dbseek(cPROD))
          zPROD   := left(PROD->Cod_fabr,6)+" "+PROD->Cod_ass+" "+left(PROD->Descricao,30)
          MOTBAI->(dbseek(cMOTIVO))
          zMOTIVO := left(MOTBAI->Descricao,25)

          nQtyProd  := 0
          nQtyValor := 0
          nQtyMotivo   := 0
          nVlrMotivo   := 0


   endif

   nQtyProd  := 0
   nQtyValor := 0
   nQtyMotivo   := 0
   nVlrMotivo   := 0


   qstopprn(.f.)

return



static function i_impre_xls
    local nQtyMotivo := 0
    local nQtyProd   := 0
    local nQtyTotal  := 0

    local nVlrMotivo := 0
    local nVlrProd   := 0
    local nVlrTotal  := 0
    local nVALOR     := 0

    local nCONT      := 0
    local cPROD      := 0
    local aFAT       := {}
    local asFAT      := {}
    local lTEM := .T.
    local zPROD := space(50)

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________
    lTEM := .F.

   do while ! FAT->(eof())  

      qgirabarra()

      qmensa("Aguarde... Processando ...")

         CLI1->(dbseek(FAT->Cod_cli))

         ITEN_FAT->(Dbseek(FAT->Codigo))
         do while ITEN_FAT->Num_fat == FAT->Codigo .and. ! ITEN_FAT->(eof())
             PROD->(dbsetorder(4))
             PROD->(dbseek(ITEN_FAT->Cod_Prod))
             nVALOR := nVALOR + (ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade)
             nVALOR += q_soma_st()

             aadd(aFAT,{right(PROD->Codigo,5),ITEN_FAT->cod_Motbai,ITEN_FAT->Quantidade,ITEN_FAT->Vl_unitar,nVALOR})

             ITEN_FAT->(Dbskip())
             nVALOR := 0
             lTEM := .T.
         enddo
         FAT->(dbskip())
         nVALOR := 0
         nDESC := 0
   enddo

   //classifica a matriz por descricao do produto
   asFAT := asort(aFAT,,,{|x,y| x[1] + x[2] < y[1] + y[2] })
   if lTEM

       cPROD    := asFAT[1,1]
       cMOTIVO  := asFAT[1,2]
       PROD->(dbseek(cPROD))
       MOTBAI->(dbseek(cMOTIVO))
       zPROD   := left(PROD->Cod_fabr,6)+chr(9)+PROD->Cod_ass+chr(9)+left(PROD->Descricao,30)
       zMOTIVO := left(MOTBAI->Descricao,25)


       nCONT := 1
       do while  nCONT <= len(asFAT)

           if ! qlineprn() ; exit ; endif
           if XPAGINA == 0 //.or. prow() > K_MAX_LIN
              @prow()+1,0 say ""
              qpageprn()
              @ prow()+1,0 say chr(9)+chr(9)+cTITULO + " "+"577"
              @ prow()+1,0 say "Ref1"+chr(9)+"Ref2"+chr(9)+"Descricao"+chr(9)+"Motivo da Baixa"+chr(9)+"Qtde"+chr(9)+"Valor Total"
              @ prow()+1,0 say ""
           endif

           nQtyMotivo += asFAT[nCONT,3]
           nQtyProd   += asFAT[nCONT,3]
           nQtyTotal  += asFAT[nCONT,3]

           nVlrMotivo += asFAT[nCONT,5]
           nVlrProd   += asFAT[nCONT,5]
           nVlrTotal  += asFAT[nCONT,5]

           nCONT++
           if nCONT > len(asFAT)
              nCONT := len(asFAT)
              exit
           endif

           if asFAT[nCONT,1]+asFAT[nCONT,2] != cPROD+cMOTIVO
              @ prow()+1,00 say zPROD
              @ prow()  ,pcol() say chr(9)+zMOTIVO
              @ prow()  ,pcol() say chr(9)+transf(nQtyMotivo,"@R 999999")
              @ prow()  ,pcol() say chr(9)+transf(nVlrMotivo,"@E 99,999,999.99")

              cMOTIVO := asFAT[nCONT,2]
              MOTBAI->(dbseek(cMOTIVO))
              zMOTIVO := left(MOTBAI->Descricao,25)

              nQtyMotivo   := 0
              nVlrMotivo   := 0
           endif


           if asFAT[nCONT,1] != cPROD
              @ prow()+1,00     say zPROD
              @ prow()  ,pcol() say chr(9)+"Total do Produto"
              @ prow()  ,pcol() say chr(9)+transf(nQtyProd,"@R 999999")
              @ prow()  ,pcol() say chr(9)+transf(nVlrProd,"@E 99,999,999.99")
              @ prow()+1,00     say " "

              cPROD   := asFAT[nCONT,1]
              cMOTIVO := asFAT[nCONT,2]
              PROD->(dbseek(cPROD))
              zPROD   := left(PROD->Cod_fabr,6)+chr(9)+PROD->Cod_ass+chr(9)+left(PROD->Descricao,30)
              MOTBAI->(dbseek(cMOTIVO))
              zMOTIVO := left(MOTBAI->Descricao,25)

              nQtyProd     := 0
              nVlrProd     := 0
              nQtyMotivo   := 0
              nVlrMotivo   := 0
           endif
       enddo

       nQtyProd  := 0
       nQtyValor := 0
       nQtyMotivo   := 0
       nVlrMotivo   := 0


   endif

   nQtyProd  := 0
   nQtyValor := 0
   nQtyMotivo   := 0
   nVlrMotivo   := 0


   qstopprn(.f.)

return



