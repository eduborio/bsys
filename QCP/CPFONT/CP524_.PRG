/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO COMERCIO
// OBJETIVO...: RELATORIO DE PEDIDSO CHINA POR PRODUTO
// ANALISTA...: EDUARDO AUGUSTO BORIO
// PROGRAMADOR: EDUARDO AUGUSTO BORIO
// INICIO.....: AGOSTO DE 2010
// OBS........:
// ALTERACOES.:

function cp524
#define K_MAX_LIN 56

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG) .or. empty(dINI) }

private cTITULO                   // titulo do relatorio
private dINI
private dFIM
private cPROD
private cPROD_DESC
private cFABR
private cCLI
private nVALOR
private nVAL_UNI
private nCUSTO
private nQUANT
private aEDICAO := {}             // vetor para os campos de entrada de dados

PROD->(dbsetorder(4)) // codigo reduzido

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qgetx(-1,0,@dINI)            } , "INI"    })
aadd(aEDICAO,{{ || qgetx(-1,0,@dFIM)            } , "FIM"    })
aadd(aEDICAO,{{ || view_prod(-1,0,@cPROD)       } ,"PROD"    })
aadd(aEDICAO,{{ || NIL                          } ,NIL       })

do while .T.

   qlbloc(5,0,"B524A","QBLOC.GLO")
   XNIVEL := 1
   XFLAG  := .T.
   cCLI   := space(5)
   cPROD  := space(5)
   cPROD_DESC := space(45)
   cFABR := space(4)
   dINI := dFIM := ctod("")
   nVALOR := nQUANT := 0

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

      case cCAMPO == "PROD"
           if ! empty(cPROD)
              PROD->(dbsetorder(5))
              if PROD->(dbseek(cPROD))
                 cPROD := right(PROD->Codigo,5)
              else
                 PROD->(dbsetorder(3))
                 if PROD->(dbseek(cPROD))
                    fCPROD := right(PROD->Codigo,5)
                 endif
              endif
              PROD->(dbsetorder(4))

              if ! empty(cPROD)
                 qrsay(XNIVEL,cPROD:=strzero(val(cPROD),5))

                 if ! PROD->(dbseek(cPROD))
                    qmensa("Produto n„o encontrado !","B")
                    return .F.
                 endif

                 qrsay ( XNIVEL+1 , left(PROD->Descricao,15)+"/"+PROD->Cod_ass+" - "+left(PROD->Cod_fabr,6) )
                 cPROD_DESC := left(PROD->Descricao,45)
                 cFABR := left(PROD->Cod_fabr,4)

              endif
           endif

   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // CRIA TITULO DO RELATORIO ______________________________________________


   cTITULO := " "+left(cFABR,4)+ " " + left(cPROD_DESC,45) + " de " + dtoc(dINI) + " a " + dtoc(dFIM)

   qmensa("")

   // ESTABELECE RELACOES ENTRE ARQUIVOS ____________________________________

   PED_FABR->(dbsetorder(2)) // data de emissao
   PED_FABR->(dbgotop())
   set softseek on
   PED_FABR->(dbseek(dtos(dINI)))
   set softseek off

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

   local lTEM := .F.
   local nTOT_QTD := nTOT_VAL := nTOT_CUS := 0

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   @ prow()+1,0 say XCOND1


   do while ! PED_FABR->(eof())  .and. PED_FABR->data_ped >= dINI .and. PED_FABR->data_ped <= dFIM  // condicao principal de loop

      //if ! qlineprn() ; exit ; endif

      if XPAGINA == 0 .or. prow() > K_MAX_LIN
         qpageprn()
         qcabecprn(cTITULO,132)
         @ prow()+1,0 say "Pedido    Fornecedor                                                  Emissao          Quantidade"
         @ prow()+1,0 say replicate("-",132)
      endif

      ITEN_PED->(Dbseek(PED_FABR->Codigo))
      do while ! ITEN_PED->(eof()) .and. ITEN_PED->Cod_ped == PED_FABR->Codigo

         if ITEN_PED->Cod_prod == cPROD
            @ prow()+1,00  say PED_FABR->Codigo
            FORN->(dbseek(PED_FABR->cod_forn))
            @ prow()  ,10  say left(FORN->Razao,50)
            @ prow()  ,70  say dtoc(PED_FABR->data_ped)
            @ prow()  ,90  say transform(ITEN_PED->Quantidade, "@R 9999999")

            nTOT_QTD += ITEN_PED->Quantidade
         endif

         ITEN_PED->(dbskip())

      enddo
   
      PED_FABR->(dbskip())

   enddo

   @ prow()+1,00 say replicate("-",132)

   @ prow()+1,90  say transform(nTOT_QTD,"@R 9999999")
   qstopprn(.F.)

return


static function i_impre_xls

   local lTEM := .F.
   local nTOT_QTD := nTOT_VAL := nTOT_CUS := 0

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________


   do while ! PED_FABR->(eof())  .and. PED_FABR->data_ped >= dINI .and. PED_FABR->data_ped <= dFIM  // condicao principal de loop

      //if ! qlineprn() ; exit ; endif

      if XPAGINA == 0 //.or. prow() > K_MAX_LIN
         qpageprn()
         @ prow()+1,0 say chr(9)+cTITULO+ " 524"
         @ prow()+1,0 say "Pedido"+chr(9)+"Fornecedor"+chr(9)+"Emissao"+chr(9)+"Quantidade"
         @ prow()+1,0 say ""
      endif

      ITEN_PED->(Dbseek(PED_FABR->Codigo))
      do while ! ITEN_PED->(eof()) .and. ITEN_PED->Cod_ped == PED_FABR->Codigo

         if ITEN_PED->Cod_prod == cPROD
            @ prow()+1,00  say PED_FABR->Codigo
            FORN->(dbseek(PED_FABR->cod_forn))
            @ prow()  ,pcol()  say chr(9)+left(FORN->Razao,50)
            @ prow()  ,pcol()  say chr(9)+dtoc(PED_FABR->data_ped)
            @ prow()  ,pcol()  say chr(9)+transform(ITEN_PED->Quantidade, "@R 9999999")

            nTOT_QTD += ITEN_PED->Quantidade
         endif

         ITEN_PED->(dbskip())

      enddo
   
      PED_FABR->(dbskip())

   enddo

   @ prow()+1,00     say chr(9)+"Total.: "
   @ prow()  ,pcol() say chr(9)+chr(9)+transform(nTOT_QTD,"@R 9999999")
   qstopprn(.F.)

return

