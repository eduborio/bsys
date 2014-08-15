/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO COMERCIAL
// OBJETIVO...: RELATORIO DE HISTORICO DO CLIENTE
// ANALISTA...:
// PROGRAMADOR: EDUARDO AUGUSTO BORIO
// INICIO.....: FEVEREIRO DE 2000
// OBS........:

function cl571
#define K_MAX_LIN 58
local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG .or. lastkey()==27)}

local  cCONT := 1
private nTOTAL := 0
private nQUANT := 0

private cTITULO          // titulo do relatorio
private aEDICAO     := {}    // vetor para os campos de entrada de dados
private cCLIENTE    := space(5)
private dINI
private dFIM
private lTEM := .F.


// CRIACAO DO VETOR DE BLOCOS _______________________________________________
aadd(aEDICAO,{{ || qgetx(-1,0,@dINI)            } , "INI"    })
aadd(aEDICAO,{{ || qgetx(-1,0,@dFIM)            } , "FIM"    })
aadd(aEDICAO,{{ || view_cli2(-1,0,@cCLIENTE                   ) } ,"CLIENTE"   })
aadd(aEDICAO,{{ || NIL                                         } , NIL        }) // nome do cliente

do while .T.

   qlbloc(05,0,"B530A","QBLOC.GLO",1)

   XNIVEL     := 1
   XFLAG      := .T.
   cCLIENTE   := space(5)
   dINI := dFIM := ctod("")

   // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; dbcloseall() ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ); loop   ; endif
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

      case cCAMPO == "CLIENTE"

           if !empty(cCLIENTE)
              if ! CLI1->(Dbseek(cCLIENTE:=strzero(val(cCLIENTE),5)))
                 qmensa("Cliente n„o Cadastrado","B")
                 return .F.
              else
                 qrsay(XNIVEL++,left(CLI1->Razao,30))
              endif
           else
              qrsay(XNIVEL++,"   *** TODOS OS CLIENTES ***  ")
           endif


   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao
  PROD->(dbsetorder(4))

return .T.

static function i_impressao

   if ! qinitprn() ; return ; endif

   if XLOCALIMP == "X"
      i_impre_xls()
   else
      i_impre_prn()
   endif


return





//////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IMPRIMIR OS PEDIDOS ___________________________________________

static function i_impre_prn

   local cTITULO
   local nTOT_PROD := nLIN := nTOT_BRU := nPROD := nICMS_SUBS := 0
   local aPROD := {}
   local zCLI := ""
   local nTOTAL :=  0

   ITEN_CON->(dbsetorder(1))
   ITEN_CON->(dbgotop())

   CONVENIO->(dbsetfilter({|| iif(!empty(cCLIENTE),CONVENIO->Cod_cli == cCLIENTE,CONVENIO->Cod_cli != "     " ) .and. CONVENIO->Dt_emissao >= dINI .and. CONVENIO->Dt_Emissao <= dFIM .and. !Faturado .and. !Cancelado}))
   CONVENIO->(dbsetorder(4))
   CONVENIO->(dbgotop())

     cTITULO := "LISTAGEM DE CONVENIOS EMITIDOS POR CLIENTE "+"DE "+dtoc(dINI)+" A "+dtoc(dFIM)

     PROD->(Dbsetorder(4))

     zCLI := CONVENIO->Cod_cli

     do while ! CONVENIO->(eof()) .and. qcontprn()

          if XPAGINA == 0 .or. prow() > K_MAX_LIN
             qpageprn()
             @ prow(),pcol() say XCOND0
             qcabecprn(cTITULO,80)
             CLI1->(Dbseek(cCLIENTE))
             CGM->(Dbseek(CLI1->Cgm_cob))
             @ prow(),pcol() say XCOND1
             @ prow()+1,0 say "Codigo    Cliente                         Emissao  Cod.  Descricao                           Vlr. Unit.   Quant.        Total"
             @ prow()+1,0 say ""

          endif

          nTOT_PROD := 0

          ITEN_CON->(Dbseek(CONVENIO->Codigo))

          do while ! ITEN_CON->(eof()) .and. ITEN_CON->cod_conv == CONVENIO->Codigo

             PROD->(Dbseek(ITEN_CON->Cod_prod))
             @ prow()+1,0  say CONVENIO->Codigo
             @ prow()  ,10 say left(CONVENIO->Cliente,30)
             @ prow()  ,43 say dtoc(CONVENIO->Dt_emissao)
             @ prow()  ,55 say ITEN_CON->Cod_prod
             @ prow()  ,62 say left(PROD->Descricao,30)
             @ prow()  ,97 say transform(ITEN_CON->Vl_unitar , "@E 999,999.99")

             @ prow()  ,110 say transform(ITEN_CON->Quant_ret, "@E 999999")

             @ prow()  ,120 say transform((ITEN_CON->Quant_ret * ITEN_CON->Vl_unitar)+qconv_st() , "@E 999,999.99")
             @ prow()  ,132 say iif(ITEN_CON->Baixado,"BX","")

             nTOT_PROD  := nTOT_PROD +  (ITEN_CON->Quant_ret   * ITEN_CON->Vl_unitar )
             nTOT_PROD += qconv_st()
             nTOTAL += nTOT_PROD
             aadd(aPROD,{ITEN_CON->Cod_prod,ITEN_CON->Quant_ret,ITEN_CON->Vl_unitar,nTOT_PROD})
             lTEM := .T.
             nTOT_PROD := 0
             ITEN_CON->(Dbskip())

          enddo

          CONVENIO->(dbskip())

          @ prow()+1,00 Say ""

          if CONVENIO->Cod_cli != zCLI
             @ prow()+1,00  Say "Total do Cliente.: "
             @ prow()  ,120 say transform(nTOTAL,"@E 999,999.99")
             @ prow()+1,00  Say ""

             if len(aPROD) > 0
                i_Resumo(aPROD,zCLI)
             endif
             aPROD := {}
             zCLI := CONVENIO->Cod_cli
          endif


          nTOT_PROD := nLIN := nTOT_BRU := nPROD := nICMS_SUBS := 0

    enddo

    if ! empty(cCLIENTE)
       @ prow()+1,00 Say "Total do Cliente.: "+transform(nTOTAL,"@E 999,999.99")
       @ prow()+1,00 Say ""

       if len(aPROD) > 0
          i_Resumo(aPROD,zCLI)
       endif
       aPROD := {}
       zCLI := CONVENIO->Cod_cli
   endif


    nTOTAL:= nQUANT := 0
    qstopprn()
return

static function i_impre_xls

return

static function i_Resumo(aPROD,cCLI)
local asPROD := {}
local nQUANT := 0
local nTOTAL := 0
local cPROD := ""
local zPROD := ""

       if !lTEM
          return .F.
       endif

       asPROD := asort(aPROD,,,{|x,y| x[1] < y[1] })
       cPROD := asPROD[1,1]
       PROD->(dbseek(cPROD))
       zPROD := cPROD + "   "+PROD->Descricao
       CLI1->(dbseek(cCLI))
       @ prow()+1,00 say "Resumo do Cliente.: "+left(CLI1->Razao,35)

       nCONT := 1
       do while  nCONT <= len(asPROD)

           if XPAGINA == 0 .or. prow() > K_MAX_LIN
              @prow()+1,0 say XCOND0
              qpageprn()
              qcabecprn("Resumo do Cliente.: "+cCLI,80)
              @ prow()+1,0 say XCOND1 + "Produto                                                                   Qtde                    Valor "
              @ prow()+1,0 say replicate("-",134)
           endif

           nQUANT += asPROD[nCONT,2]
           nTOTAL += asPROD[nCONT,4]


           nCONT++
           if nCONT > len(asPROD)
              nCONT := len(asPROD)
              exit
           endif

           if asPROD[nCONT,1] != cPROD
              @ prow()+1,00 say zPROD
              @ prow()  ,110 say transf(nQUANT,"@R 999999")

              @ prow()  ,120 say transf(nTOTAL,"@E 999,999.99")
              cPROD := asPROD[nCONT,1]
              PROD->(dbseek(cPROD))
              zPROD := cPROD + "   "+PROD->Descricao

              nQUANT     := 0
              nTOTAL     := 0
           endif
       enddo
       @ prow()+1,00 say zPROD            //descricao do produto
       @ prow()  ,110 say transf(nQUANT,"@R 999999")
       @ prow()  ,120 say transf(nTOTAL,"@E 999,999.99")
       @ prow()+1,00  say replicate("-",132)
       @ prow()+1,00  say ""



       nQUANT     := 0
       nTOTAL     := 0


return



