//////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO COMERCIO
// OBJETIVO...: LISTAGEM DE PRODUTOS FATURADOS
// ANALISTA...: EDUARDO AUGUSTO BORIO
// PROGRAMADOR: EDUARDO AUGUSTO BORIO
// INICIO.....: SETEMBRO DE 2002
// OBS........:
// ALTERACOES.:

function cl579
#define K_MAX_LIN 57

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG) .or. empty(dINI) }

private cTITULO                   // titulo do relatorio
private dINI
private dFIM
private cSETOR := space(5)
private aEDICAO := {}             // vetor para os campos de entrada de dados

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qgetx(-1,0,@dINI)            } , "INI"    })
aadd(aEDICAO,{{ || qgetx(-1,0,@dFIM)            } , "FIM"    })
aadd(aEDICAO,{{ || view_setor(-1,0,@cSETOR)     } , "SETOR"  })
aadd(aEDICAO,{{ || NIL                          } , NIL  })

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

      case cCAMPO == "SETOR"

           qrsay(XNIVEL,cSETOR)

           if empty(cSETOR)
              qrsay(XNIVEL++, "Todos os Setores.......")
           else
              if ! SETOR->(Dbseek(cSETOR:=strzero(val(cSETOR),5)))
                 qmensa("Setor n„o Cadastrado","B")
                 return .F.
              else
                 qrsay(XNIVEL++,left(SETOR->Descricao,30))
              endif
           endif

   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // CRIA TITULO DO RELATORIO ______________________________________________


   cTITULO := "LISTAGEM DE PRODUTOS FATURADOS" +" de " + dtoc(dINI) + " a " + dtoc(dFIM)

   qmensa("")

   // ESTABELECE RELACOES ENTRE ARQUIVOS ____________________________________

   FAT->(dbsetorder(2)) // data de emissao
   FAT->(dbgotop())
   set softseek on
   FAT->(dbseek(dtos(dINI)))
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
    local nTOTAL_ENT := 0
    local nVALOR     := 0
    local nDESC      := 0
    local nTOT_GER   := 0
    local nCONT      := 0
    local nQUANT     := 0
    local nQUANT_ENT := 0
    local nTOT_QUANT := 0
    local cPROD      := 0
    local nQTDVIS    := 0
    local nTOTVIS    := 0
    local nQTDPRZ    := 0
    local nTOTPRZ    := 0

    local nTTQTDPRZ    := 0
    local nTTVLRPRZ    := 0
    local nTTQTDVIS    := 0
    local nTTVLRVIS    := 0
    local aFAT       := {}
    local asFAT      := {}
    local nPERC      := 0
    local lTEM := .T.
    local zPROD := space(50)

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________
    lTEM := .F.
   //if ! qinitprn() ; return ; endif

   FAT->(dbsetorder(2)) // data de emissao
   FAT->(dbgotop())
   set softseek on
   FAT->(dbseek(dtos(dINI)))
   set softseek off
   ITEN_FAT->(dbsetorder(2))


   do while ! FAT->(eof())  .and. FAT->Dt_emissao >= dINI .and. FAT->Dt_emissao <= dFIM  // condicao principal de loop

      if FAT->Cancelado
         FAT->(dbskip())
         loop
      endif

      if empty(FAT->Num_fatura).and. FAT->Es == "S"
         FAT->(dbskip())
         loop
      endif

      if ! left(FAT->Cod_cfop,3) $ "510-511-512-540-640-610-611-612-591-691-120-220"
         FAT->(dbskip())
         loop
      endif

      qgirabarra()

      qmensa("Aguarde... Processando ...")

         CLI1->(dbseek(FAT->Cod_cli))

         ITEN_FAT->(Dbgotop())
         ITEN_FAT->(Dbseek(FAT->Codigo))
         do while ITEN_FAT->Num_fat == FAT->Codigo .and. ! ITEN_FAT->(eof())
             PROD->(dbsetorder(4))
             PROD->(dbseek(ITEN_FAT->Cod_Prod))
             nVALOR := nVALOR + ( (ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade) + ( (ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade)*(ITEN_FAT->Ipi/100) ) )
             nVALOR += q_soma_st()
            // if FAT->Es == "S"
                if FAT->tipo_doc == "01"
                   aadd(aFAT,{ITEN_FAT->Cod_prod,ITEN_FAT->Quantidade,nVALOR,0,0,FAT->Es})
                else
                   aadd(aFAT,{ITEN_FAT->Cod_prod,0,0,ITEN_FAT->Quantidade,nVALOR,FAT->ES})
                endif
            // endif

             nPERC += nVALOR
             ITEN_FAT->(Dbskip())
             nVALOR := 0
             lTEM := .T.
         enddo
         FAT->(dbskip())
         nVALOR := 0
         nDESC := 0
   enddo
   //classifica a matriz por descricao do produto
   asFAT := asort(aFAT,,,{|x,y| x[1] < y[1] })

   if lTEM
       cPROD := asFAT[1,1]
       zPROD := ""

       nCONT := 1
       do while  nCONT <= len(asFAT)

           if ! qlineprn() ; exit ; endif
           if XPAGINA == 0 .or. prow() > K_MAX_LIN
              @prow()+1,0 say XCOND0
              qpageprn()
              qcabecprn(cTITULO,135)
              @ prow()+1,0 say XCOND1 + "                                               A VISTA                       A PRAZO                         TOTAL "
              @ prow()+1,0 say XCOND1 + "Produto                                   Qtde          Total           Qtde          Total           Qtde          Total"
              @ prow()+1,0 say replicate("-",135)
           endif

           if asFAT[nCONT,6] == "S"
              nQTDVIS      += asFAT[nCONT,2]
              nTOTVIS      += asFAT[nCONT,3]    //Quantidade * valor unitario
              nQTDPRZ      += asFAT[nCONT,4]
              nTOTPRZ      += asFAT[nCONT,5]    //Quantidade * valor unitario

              nTTQTDVIS += asFAT[nCONT,2]       //Quantidade * valor unitario
              nTTQTDPRZ += asFAT[nCONT,4]       //Quantidade * valor unitario
              nTTVLRVIS += asFAT[nCONT,3]       //Quantidade * valor unitario
              nTTVLRPRZ += asFAT[nCONT,5]       //Quantidade * valor unitario
           else
              nQTDVIS      -= asFAT[nCONT,2]
              nTOTVIS      -= asFAT[nCONT,3]    //Quantidade * valor unitario
              nQTDPRZ      -= asFAT[nCONT,4]
              nTOTPRZ      -= asFAT[nCONT,5]    //Quantidade * valor unitario

              nTTQTDVIS -= asFAT[nCONT,2]       //Quantidade * valor unitario
              nTTQTDPRZ -= asFAT[nCONT,4]       //Quantidade * valor unitario
              nTTVLRVIS -= asFAT[nCONT,3]       //Quantidade * valor unitario
              nTTVLRPRZ -= asFAT[nCONT,5]       //Quantidade * valor unitario
           endif

           nCONT++
           if nCONT > len(asFAT)
              nCONT := len(asFAT)
              exit
           endif

           if asFAT[nCONT,1] != cPROD
              PROD->(dbseek(cPROD))
              @ prow()+1,00 say cPROD + " - " + left(PROD->Descricao,30)
              @ prow()  ,40 say transf(nQTDVIS,"@R 9999999")
              @ prow()  ,50 say transf(nTOTVIS,"@E 9,999,999.99")

              @ prow()  ,70 say transf(nQTDPRZ,"@R 9999999")
              @ prow()  ,80 say transf(nTOTPRZ,"@E 9,999,999.99")

              @ prow()  ,100 say transf(nQTDPRZ+nQTDVIS,"@R 9999999")
              @ prow()  ,110 say transf(nTOTPRZ+nTOTVIS,"@E 9,999,999.99")

              cPROD := asFAT[nCONT,1]

              nQTDVIS       := 0
              nTOTVIS       := 0
              nQTDPRZ       := 0
              nTOTPRZ       := 0
           endif
       enddo
       PROD->(dbseek(cPROD))
       @ prow()+1,00 say cPROD + " - " + left(PROD->Descricao,30)
       @ prow()  ,40 say transf(nQTDVIS,"@R 9999999")
       @ prow()  ,50 say transf(nTOTVIS,"@E 9,999,999.99")

       @ prow()  ,70 say transf(nQTDPRZ,"@R 9999999")
       @ prow()  ,80 say transf(nTOTPRZ,"@E 9,999,999.99")

       @ prow()  ,100 say transf(nQTDPRZ+nQTDVIS,"@R 9999999")
       @ prow()  ,110 say transf(nTOTPRZ+nTOTVIS,"@E 9,999,999.99")

       nQTDVIS       := 0
       nTOTVIS       := 0
       nQTDPRZ       := 0
       nTOTPRZ       := 0
       nQTDTOT       := 0
       nVLRTOT       := 0


       @ prow()+1,00 say replicate("-",135)
       @ prow()+1,00 say "Total Geral.: "
       @ prow()  ,40 say transf(nTTQTDVIS,"@R 9999999")
       @ prow()  ,50 say transf(nTTVLRVIS,"@E 9,999,999.99")

       @ prow()  ,70 say transf(nTTQTDPRZ,"@R 9999999")
       @ prow()  ,80 say transf(nTTVLRPRZ,"@E 9,999,999.99")

       @ prow()  ,100 say transf(nTTQTDPRZ+nTTQTDVIS,"@R 9999999")
       @ prow()  ,110 say transf(nTTVLRPRZ+nTTVLRVIS,"@E 9,999,999.99")



   endif

   qstopprn()

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO EM EXCEL__________________

static function i_impre_xls

return


