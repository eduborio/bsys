/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE COMPRAS
// OBJETIVO...: LISTAGEM DE PRODUTOS POR PROJETO
// ANALISTA...: EDUARDO AUGUSTO BORIO
// PROGRAMADOR: o mesmo
// INICIO.....: SETEMBRO DE 2006
// OBS........:
// ALTERACOES.:

function cp517

#define K_MAX_LIN 57

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG) .or. empty(dINI) }

private cTITULO                   // titulo do relatorio
private dINI
private dFIM
private cPROJ := space(5)
private cEVE  := space(5)
private aEDICAO := {}             // vetor para os campos de entrada de dados

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qgetx(-1,0,@dINI)            } , "INI"    })
aadd(aEDICAO,{{ || qgetx(-1,0,@dFIM)            } , "FIM"    })
aadd(aEDICAO,{{ || view_proj(-1,0,@cPROJ)       } , "PROJ"  })
aadd(aEDICAO,{{ || NIL                          } , NIL  })
aadd(aEDICAO,{{ || view_eve(-1,0,@cEVE)         } , "EVE"  })
aadd(aEDICAO,{{ || NIL                          } , NIL  })


do while .T.

   qlbloc(5,0,"B517A","QBLOC.GLO")
   XNIVEL := 1
   XFLAG  := .T.
   dINI := dFIM := ctod("")
   cPROJ := ""
   cEVE  := ""

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

      case cCAMPO == "PROJ"

           qrsay(XNIVEL,cPROJ)

           if empty(cPROJ)
              qrsay(XNIVEL+1,"Todos os Projetos...")
           else
              if ! PROJET->(Dbseek(cPROJ:=strzero(val(cPROJ),5)))
                 qmensa("Projeto n„o Cadastrado","B")
                 return .F.
              else
                 qrsay(XNIVEL+1,left(PROJET->Descricao,30))
                 EVENTOS->(Dbseek(PROJET->Cod_eve))
                 qrsay(XNIVEL+2,left(EVENTOS->Codigo,5))
                 cEVE := EVENTOS->Codigo
                 qrsay(XNIVEL+3,left(EVENTOS->Nome,30))


              endif
           endif

      case cCAMPO == "EVE"

           qrsay(XNIVEL,cEVE)

           if empty(cEVE)
              //qrsay(XNIVEL+1,"Todos os Projetos...")
              qmensa("Campo Obrigatorio ! ","B")
              return .F.
           else
              if ! EVENTOS->(Dbseek(cEVE:=strzero(val(cEVE),5)))
                 qmensa("Evento n„o Cadastrado","B")
                 return .F.
              else
                 qrsay(XNIVEL+1,left(EVENTOS->Nome,30))

              endif
           endif


   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // CRIA TITULO DO RELATORIO ______________________________________________


   cTITULO := "Compras por Projeto" +" de " + dtoc(dINI) + " a " + dtoc(dFIM)+" - "+left(PROJET->Descricao,25)

   qmensa("")

   // ESTABELECE RELACOES ENTRE ARQUIVOS ____________________________________

   PEDIDO->(dbsetorder(1)) // data de emissao
   PEDIDO->(dbgotop())
   set softseek on
   PEDIDO->(Dbseek(dtos(dINI)))
   set softseek off
   LANC->(dbsetorder(1))
return .T.


static function i_impressao

   if ! qinitprn() ; return ; endif

//   if XLOCALIMP == "X"
     // i_impre_xls()
//   else
      i_impre_prn()
//   endif



return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impre_prn
    local nTOTAL     := 0
    local nCONT_PROD := 0
    local nVALOR     := 0
    local nDESC      := 0
    local nTOT_GER   := 0
    local nCONT      := 0
    local nQUANT     := 0
    local nTOT_QUANT := 0
    local cPROD      := 0
    local aFAT       := {}
    local asFAT      := {}
    local nPERC      := 0
    local lTEM := .T.
    local zPROD := space(50)
   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________
    lTEM := .F.
   //if ! qinitprn() ; return ; endif
   nPERC := 0
   do while ! PEDIDO->(eof())  .and. PEDIDO->data_ped >= dINI .and. PEDIDO->data_ped <= dFIM  // condicao principal de loop

      qgirabarra()

      qmensa("Aguarde... Processando ...")

         FORN->(dbseek(PEDIDO->Cod_forn))

         LANC->(Dbgotop())
         LANC->(Dbseek(PEDIDO->Codigo))
         do while LANC->Cod_ped == PEDIDO->Codigo .and. ! LANC->(eof())

             if ! empty(cPROJ)
                if ! LANC->Cod_projet == cPROJ
                   LANC->(DbSkip())
                   loop
                endif
             else
                if ! LANC->Cod_eve == cEVE
                   LANC->(DbSkip())
                   loop
                endif
             endif

             PROD->(dbsetorder(4))
             PROD->(dbseek(LANC->Cod_Prod))
             nVALOR := nVALOR + (LANC->preco * LANC->quant)

             aadd(aFAT,{right(PROD->Codigo,5),LANC->quant,LANC->preco,nVALOR})
             nPERC := nPERC + nVALOR
             LANC->(Dbskip())
             nVALOR := 0
             lTEM := .T.
         enddo
         PEDIDO->(dbskip())
         nVALOR := 0
         nDESC := 0
   enddo

   //classifica a matriz por descricao do produto
   asFAT := asort(aFAT,,,{|x,y| x[1] < y[1] })
   if lTEM
       cPROD := asFAT[1,1]
       PROD->(Dbsetorder(4))
       PROD->(Dbseek(cPROD))
       zPROD := right(PROD->Codigo,5)+"   "+PROD->Descricao

       nCONT := 1
       do while  nCONT <= len(asFAT)

           if XPAGINA == 0 .or. prow() > K_MAX_LIN
              qpageprn()
              qcabecprn(cTITULO,136)
              @ prow()+1,0 say XCOND1 + "Codigo  Produto                                                quant      Preco Medio             Valor   "
              @ prow()+1,0 say replicate("-",134)
           endif

           nQUANT := (nQUANT + asFAT[nCONT,2])
           nTOT_QUANT := (nTOT_QUANT + asFAT[nCONT,2])
           nTOTAL := nTOTAL + (asFAT[nCONT,2]*asFAT[nCONT,3])  //quant * valor unitario
           nTOT_GER := nTOT_GER + (asFAT[nCONT,2]*asFAT[nCONT,3])  //quant * valor unitario

           nCONT++
           if nCONT > len(asFAT)
              nCONT := len(asFAT)
              exit
           endif

           if asFAT[nCONT,1] != cPROD
              @ prow()+1,00 say zPROD
              @ prow()  ,61 say transf(nQUANT,"@R 999999")
              @ prow()  ,73 say transf((nTOTAL/nQUANT),"@E 999,999.99")
              @ prow()  ,90 say transf(nTOTAL,"@E 99,999,999.99")
              @ prow()  ,107 say transf((nTOTAL/nPERC)*100,"@E 99.99") + " %"
              cPROD := asFAT[nCONT,1]
              PROD->(Dbseek(cPROD))
              zPROD := right(PROD->Codigo,5) +"   "+ PROD->Descricao

              nQUANT := 0
              nTOTAL := 0
           endif
       enddo
       @ prow()+1,00 say zPROD            //descricao do produto
       @ prow()  ,61 say transf(nQUANT,"@R 999999")
       @ prow()  ,73 say transf((nTOTAL/nQUANT),"@E 999,999.99")

       @ prow()  ,90 say transf(nTOTAL,"@E 99,999,999.99")
       @ prow()  ,107 say transf((nTOTAL/nPERC)*100,"@E 99.99") + " %"


       @ prow()+1,00 say replicate("-",134)
       @ prow()+1,60 say transf(nTOT_QUANT,"@R 9999999")
       @ prow()  ,90 say transf(nTOT_GER,"@E 99,999,999.99")

       nQUANT := 0
       nTOTAL := 0
       nPERC  := 0
   endif

   qstopprn()

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO EM EXCEL__________________


