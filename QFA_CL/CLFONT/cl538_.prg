/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO COMERCIO
// OBJETIVO...: LISTAGEM DE PRODUTOS FATURADOS POR ESTADO (CLIENTE/PRODUTO/%)
// ANALISTA...: EDUARDO AUGUSTO BORIO
// PROGRAMADOR: EDUARDO AUGUSTO BORIO
// INICIO.....: JANEIRO DE 2003
// OBS........:
// ALTERACOES.:

function cl538
#define K_MAX_LIN 57

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG) .or. empty(dINI) }

private cTITULO                   // titulo do relatorio
private dINI
private dFIM
private cSETOR := space(5)
private cCLI   := space(5)
private aEDICAO := {}             // vetor para os campos de entrada de dados

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qgetx(-1,0,@dINI)            } , "INI"    })
aadd(aEDICAO,{{ || qgetx(-1,0,@dFIM)            } , "FIM"    })
aadd(aEDICAO,{{ || view_cli(-1,0,@cCLI   )      } , "CLI"  })
aadd(aEDICAO,{{ || NIL                          } , NIL  })

do while .T.

   qlbloc(5,0,"B538A","QBLOC.GLO")
   XNIVEL := 1
   XFLAG  := .T.
   dINI := dFIM := ctod("")
   cCLI := space(5)
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
              qrsay(XNIVEL++, "Todos os CLientes.......")
           else
              if ! CLI1->(Dbseek(cCLI))
                 qmensa("CLiente n„o encontrado","B")
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


   cTITULO := "LISTAGEM DE FATURAMENTOS POR CLIENTE" + " de " + dtoc(dINI) + " a " + dtoc(dFIM)

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
    local nTOTAL     := 0
    local nTOT_GER   := 0
    local nCONT      := 0
    local nPERC      := 0
    local nQUANT     := 0
    local nTOT_QUANT := 0
    local cPROD      := 0
    local nUF_QUANT  := 0
    local nUF_VALOR  := 0
    local aFAT       := {}
    local asFAT      := {}
    local lTEM := .T.
   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________
    lTEM := .F.
//   if ! qinitprn() ; return ; endif

   do while ! FAT->(eof())  .and. FAT->Dt_emissao >= dINI .and. FAT->Dt_emissao <= dFIM  // condicao principal de loop

      if FAT->Cancelado
         FAT->(dbskip())
         loop
      endif

      if empty(FAT->Num_fatura).and. FAT->Es == "S"
         FAT->(dbskip())
         loop
      endif

      CLI1->(dbseek(FAT->Cod_cli))

      if ! left(FAT->Cod_cfop,3) $ "510-511-512-610-611-612-120-220"
         FAT->(dbskip())
         loop
      endif

      qgirabarra()

      qmensa("Aguarde... Processando ...")

         ITEN_FAT->(Dbgotop())
         ITEN_FAT->(Dbseek(FAT->Codigo))
         do while ITEN_FAT->Num_fat == FAT->Codigo .and. ! ITEN_FAT->(eof())
             PROD->(dbsetorder(4))
             PROD->(dbseek(ITEN_FAT->Cod_Prod))
             nTOTAL += (ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade)
             nTOTAL += q_soma_st()
             lTEM := .T.
             ITEN_FAT->(Dbskip())
         enddo
         if CONFIG->Modelo_fat == "1"
            nDESC := 0
         else
            nDESC := nTOTAL * (FAT->Aliq_desc/100)
         endif
         nTOTAL := nTOTAL - nDESC
         nDESC := 0
         if !empty(cCLI).and.FAT->Cod_cli <> cCLI
            nPERC += nTOTAL
         else
            CGM->(Dbseek(CLI1->Cgm_ent))
            aadd(aFAT,{FAT->Dt_Emissao,FAT->Cod_cli,CLI1->Razao,nTOTAL,FAT->Num_fatura,CGM->Estado,FAT->Es})
            nPERC += nTOTAL
         endif
         nTOTAL := 0
         FAT->(dbskip())

   enddo
   //classifica a matriz por descricao do produto + Estado
   asFAT := asort(aFAT,,,{|x,y| x[3] + x[5] < y[3] + y[5] })
   if lTEM
       zCLI  := asFAT[1,2]
       nCONT := 1
       do while  nCONT <= len(asFAT)

           if ! qlineprn() ; exit ; endif

           if XPAGINA == 0 .or. prow() > K_MAX_LIN
              @prow()+1,0 say XCOND1
              qpageprn()
              qcabecprn(cTITULO,136)
              @ prow()+1,0 say XCOND1 + "Data Emissao    Cod.  Cliente                                                          Total        Nota Fiscal    UF"
              @ prow()+1,0 say replicate("-",134)

           endif

           if asFAT[nCONT,7] == "S"
              nUF_VALOR += asFAT[nCONT,4]
              nTOT_GER += asFAT[nCONT,4]
           else
              nUF_VALOR -= asFAT[nCONT,4]
              nTOT_GER  -= asFAT[nCONT,4]
           endif

           @ prow()+1, 00  say dtoc(asFAT[nCONT,1])                //Data de Emissao
           @ prow()  , 16  say asFAT[nCONT,2]                       //Codigo do Cliente
           @ prow()  , 22  say left(asFAT[nCONT,3],50)                 //Razao do Cliente

           if asFAT[nCONT,7] == "S"
              @ prow()  , 80  say transf(asFAT[nCONT,4],"@E 9,999,999.99")  //Total da Nota
              @ prow()  ,103  say asFAT[nCONT,5]                       //Numero da N.F.
              @ prow()  ,115  say asFAT[nCONT,6]                       //SIGLA DO ESTADO
           else
              @ prow()  , 80  say transf(asFAT[nCONT,4],"@E 9,999,999.99")  //Total da Nota
              @ prow()  ,103  say asFAT[nCONT,5]                       //Numero da N.F.
              @ prow()  ,115  say asFAT[nCONT,6]                       //SIGLA DO ESTADO
              @ prow()  ,120  say "Devolucao"                          //SIGLA DO ESTADO
           endif

           nCONT++
           if nCONT > len(asFAT)
              nCONT := len(asFAT)
              exit
           endif

          if alltrim(asFAT[nCONT,2]) != alltrim(zCLI)
              @ prow()+2  ,00 say "TOTAIS DO CLIENTE"
              @ prow()    ,79 say transf(nUF_VALOR,"@E 99,999,999.99")
              @ prow()    ,106 say transf((nUF_VALOR/nPERC)*100,"@E 99.99") + " %"
              @ prow()+1,00 say replicate("-",136)
              @ prow()+1,00 say ""
              nUF_VALOR := 0

          endif

         zCLI := asFAT[nCONT,2]

       enddo
       @ prow()+2  ,00 say "TOTAIS DO CLIENTE"
       @ prow()    ,79 say transf(nUF_VALOR,"@E 99,999,999.99")
       @ prow()    ,106 say transf((nUF_VALOR/nPERC)*100,"@E 99.99") + " %"

       @ prow()+1,00 say ""
       nUF_VALOR := 0


       @ prow()+1,00 say replicate("-",134)
       @ prow()+1,79 say transf(nTOT_GER,"@E 99,999,999.99")

       nTOTAL := 0
       nPERC  := 0
   endif

   qstopprn()

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impre_xls
    local nTOTAL     := 0
    local nTOT_GER   := 0
    local nCONT      := 0
    local nPERC      := 0
    local nQUANT     := 0
    local nTOT_QUANT := 0
    local cPROD      := 0
    local nUF_QUANT  := 0
    local nUF_VALOR  := 0
    local aFAT       := {}
    local asFAT      := {}
    local lTEM := .T.
   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________
    lTEM := .F.
   //if ! qinitprn() ; return ; endif

   do while ! FAT->(eof())  .and. FAT->Dt_emissao >= dINI .and. FAT->Dt_emissao <= dFIM  // condicao principal de loop

      if FAT->Cancelado
         FAT->(dbskip())
         loop
      endif

      if empty(FAT->Num_fatura).and. FAT->Es == "S"
         FAT->(dbskip())
         loop
      endif

      CLI1->(dbseek(FAT->Cod_cli))

      if ! left(FAT->Cod_cfop,3) $ "510-511-512-610-611-612-120-220"
         FAT->(dbskip())
         loop
      endif

      qgirabarra()

      qmensa("Aguarde... Processando ...")

         ITEN_FAT->(Dbgotop())
         ITEN_FAT->(Dbseek(FAT->Codigo))
         do while ITEN_FAT->Num_fat == FAT->Codigo .and. ! ITEN_FAT->(eof())
             PROD->(dbsetorder(4))
             PROD->(dbseek(ITEN_FAT->Cod_Prod))
             nTOTAL += (ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade)
             nTOTAL += q_soma_st()
             lTEM := .T.
             ITEN_FAT->(Dbskip())
         enddo
         if CONFIG->Modelo_fat == "1"
            nDESC := 0
         else
            nDESC := nTOTAL * (FAT->Aliq_desc/100)
         endif
         nTOTAL := nTOTAL - nDESC
         nDESC := 0
         if !empty(cCLI).and.FAT->Cod_cli <> cCLI
            nPERC += nTOTAL
         else
            CGM->(Dbseek(CLI1->Cgm_ent))
            aadd(aFAT,{FAT->Dt_Emissao,FAT->Cod_cli,CLI1->Razao,nTOTAL,FAT->Num_fatura,CGM->Estado,FAT->Es})
            nPERC += nTOTAL
         endif
         nTOTAL := 0
         FAT->(dbskip())

   enddo
   //classifica a matriz por descricao do produto + Estado
   asFAT := asort(aFAT,,,{|x,y| x[3] + x[5] < y[3] + y[5] })
   if lTEM
       zCLI  := asFAT[1,2]
       nCONT := 1
       do while  nCONT <= len(asFAT)

           if ! qlineprn() ; exit ; endif

           if XPAGINA == 0
              qpageprn()
              @ prow()+1,0 say chr(9)+chr(9)+cTITULO
              @ prow()+1,0 say "Data Emissao"+chr(9)+"Cod."+Chr(9)+"Cliente"+Chr(9)+"Total"+Chr(9)+"Nota Fiscal"+chr(9)+"UF"
              @ prow()+1,0 say ""

           endif

           if asFAT[nCONT,7] == "S"
              nUF_VALOR += asFAT[nCONT,4]
              nTOT_GER += asFAT[nCONT,4]
           else
              nUF_VALOR -= asFAT[nCONT,4]
              nTOT_GER  -= asFAT[nCONT,4]
           endif

           @ prow()+1, 00  say dtoc(asFAT[nCONT,1])                //Data de Emissao
           @ prow()  , pcol()  say chr(9)+asFAT[nCONT,2]                       //Codigo do Cliente
           @ prow()  , pcol()  say chr(9)+left(asFAT[nCONT,3],50)                 //Razao do Cliente

           if asFAT[nCONT,7] == "S"
              @ prow()  ,pcol()  say chr(9)+transf(asFAT[nCONT,4],"@E 9,999,999.99")  //Total da Nota
              @ prow()  ,pcol()  say chr(9)+asFAT[nCONT,5]                       //Numero da N.F.
              @ prow()  ,pcol()  say chr(9)+asFAT[nCONT,6]                       //SIGLA DO ESTADO
           else
              @ prow()  ,pcol()  say chr(9)+transf(asFAT[nCONT,4],"@E 9,999,999.99")  //Total da Nota
              @ prow()  ,pcol()  say chr(9)+asFAT[nCONT,5]                       //Numero da N.F.
              @ prow()  ,pcol()  say chr(9)+asFAT[nCONT,6]                       //SIGLA DO ESTADO
              @ prow()  ,pcol()  say chr(9)+"Devolucao"                          //SIGLA DO ESTADO
           endif

           nCONT++
           if nCONT > len(asFAT)
              nCONT := len(asFAT)
              exit
           endif

          if alltrim(asFAT[nCONT,2]) != alltrim(zCLI)
              @ prow()+1  ,00 say chr(9)+chr(9)+"TOTAIS DO CLIENTE"
              @ prow()    ,pcol() say chr(9)+transf(nUF_VALOR,"@E 99,999,999.99")
              @ prow()    ,pcol() say chr(9)+transf((nUF_VALOR/nPERC)*100,"@E 99.99") + " %"
              @ prow()+1,00 say ""
              nUF_VALOR := 0

          endif

         zCLI := asFAT[nCONT,2]

       enddo

       @ prow()+1  ,00 say chr(9)+chr(9)+"TOTAIS DO CLIENTE"
       @ prow()    ,pcol() say chr(9)+transf(nUF_VALOR,"@E 99,999,999.99")
       @ prow()    ,pcol() say chr(9)+transf((nUF_VALOR/nPERC)*100,"@E 99.99") + " %"

       @ prow()+1,00 say ""
       nUF_VALOR := 0


       @ prow()+1,00 say chr(9)+chr(9)+chr(9)+transf(nTOT_GER,"@E 99,999,999.99")

       nTOTAL := 0
       nPERC  := 0
   endif

   qstopprn()

return

