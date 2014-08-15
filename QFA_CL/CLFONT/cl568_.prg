/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO COMERCIO
// OBJETIVO...: RELATORIO DE FATURAMENTO POR PRODUTO
// ANALISTA...: EDUARDO AUGUSTO BORIO
// PROGRAMADOR: EDUARDO AUGUSTO BORIO
// INICIO.....: AGOSTO DE 2000
// OBS........:
// ALTERACOES.:

function cl568
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

   qlbloc(5,0,"B522A","QBLOC.GLO")
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
           if empty(cPROD) ; return .F. ; endif
           qrsay(XNIVEL,cPROD:=strzero(val(cPROD),5))
           if ! PROD->(dbseek(cPROD))
               qmensa("Produto inv lido !","B")
               return .F.
           else
              qrsay(XNIVEL+1,left(PROD->Descricao,38))
              cPROD_DESC := left(PROD->Descricao,45)
              cFABR := left(PROD->Cod_fabr,4)
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

   FAT->(DbsetFilter({|| empty(FAT->Num_fatura) .and. FAT->Es == "S"}))

   FAT->(dbsetorder(2)) // data de emissao
   FAT->(dbgotop())
   set softseek on
   FAT->(dbseek(dtos(dINI)))
   set softseek off

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impressao

   local lTEM := .F.
   local nTOT_QTD := nTOT_VAL := nTOT_CUS := 0

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif

   do while ! FAT->(eof())  .and. FAT->Dt_emissao >= dINI .and. FAT->Dt_emissao <= dFIM  // condicao principal de loop

      if ! qlineprn() ; exit ; endif

      if XPAGINA == 0 .or. prow() > K_MAX_LIN
         @prow()+1,0 say XCOND0
         qpageprn()
         qcabecprn(cTITULO,80)
         @ prow()+1,0 say XCOND1 + "Nota   Pedido  Cliente                           Emissao            Quantidade          Preco Unitario             Valor "
         @ prow()+1,0 say ""
      endif

      qgirabarra()

      qmensa("Aguarde... Processando ...")

      ITEN_FAT->(Dbgotop())
      if ITEN_FAT->(Dbseek(FAT->Codigo+cPROD))
         nQUANT += ITEN_FAT->Quantidade
         nVALOR += (ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade)
         nVAL_UNI := ITEN_FAT->Vl_unitar

         if nQUANT > 0
            lTEM := .T.
         endif
      else
        FAT->(dbskip())
        loop
      endif

      if lTEM
         @ prow()+1,00  say XCOND1 + FAT->Num_fatura
         @ prow()  ,08  say FAT->Codigo
         CLI1->(dbseek(FAT->Cod_cli))
         @ prow()  ,15  say left(CLI1->Razao,30)
         @ prow()  ,50  say dtoc(FAT->Dt_emissao)
         @ prow()  ,65  say transform(nQUANT, "@E 9,999,999.99")
         @ prow()  ,86  say transform(nVAL_UNI, "@E 9,999,999.99")
         @ prow()  ,110 say transform(nVALOR, "@E 9,999,999.99")
         @ prow()  ,125 say FAT->(Cod_cfop)

         nTOT_QTD += nQUANT

         nTOT_VAL += nVALOR

         nQUANT := nVALOR := nCUSTO:= 0

         lTEM := .F.

         @ prow(),pcol() say XCOND0

      endif
   
      FAT->(dbskip())

   enddo

   @ prow()+1,00 say replicate("-",80)
   @ prow(),pcol() say XCOND1

   @ prow()+1,65  say transform(nTOT_QTD,"@E 9,999,999.99")
   @ prow()  ,110  say transform(nTOT_VAL,"@E 9,999,999.99")
   @ prow(),pcol() say XCOND0
   qstopprn()

return
