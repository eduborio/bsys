/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO COMERCIAL
// OBJETIVO...: RELATORIO DE HISTORICO DO CLIENTE
// ANALISTA...:
// PROGRAMADOR: EDUARDO AUGUSTO BORIO
// INICIO.....: FEVEREIRO DE 2000
// OBS........:

function cl530
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

           qrsay(XNIVEL,cCLIENTE)

           if empty(cCLIENTE)
              return .F.
           endif

           if ! CLI1->(Dbseek(cCLIENTE:=strzero(val(cCLIENTE),5)))
              qmensa("Cliente n„o Cadastrado","B")
              return .F.
           else
              qrsay(XNIVEL++,left(CLI1->Razao,30))
           endif


   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   if ! empty(cCLIENTE)
      CLI1->(dbsetorder(1))  // COD_CLI
      qmensa("")
   endif

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
   DUP_FAT->(dbsetorder(2))
   DUP_FAT->(dbgotop())
   ITEN_FAT->(dbsetorder(2))
   ITEN_FAT->(dbgotop())
   FAT->(dbsetfilter({|| FAT->Dt_emissao >= dINI .and. FAT->Dt_Emissao <= dFIM},'FAT->Dt_emissao >= dINI .and. FAT->Dt_Emissao <= dFIM'))
   FAT->(dbsetorder(11))
   FAT->(dbgotop())

     cTITULO := "LISTAGEM DO MOVIMENTO DO CLIENTE :" + left(CLI1->Razao,36)

     PROD->(Dbsetorder(4))


     do while ! FAT->(eof()) .and. qcontprn()

          if XPAGINA == 0 .or. prow() > K_MAX_LIN
             qpageprn()
             @ prow(),pcol() say XCOND0
             qcabecprn(cTITULO,80)
             CLI1->(Dbseek(cCLIENTE))
             CGM->(Dbseek(CLI1->Cgm_cob))
             @ prow(),pcol() say XCOND1
             @ prow()+1,0 say "Nota      Pedido  Emissao       Produto                 Cod. Ass.   Cod. Fabr.   Marca            Vlr. Unit.   Quant.        Total"
             @ prow()+1,0 say ""

          endif

          if FAT->Cancelado
             FAT->(Dbskip())
             loop
          endif

          if FAT->Cod_cli != cCLIENTE
             FAT->(Dbskip())
             loop
          endif

          if empty(FAT->Num_fatura).and. FAT->Es == "S"
             FAT->(dbskip())
             loop
          endif

          if CONFIG->Modelo_2 == "1"
             if year(dINI) < 2003
                if FAT->Cod_natop != "511" .and. FAT->Cod_natop != "611"
                   FAT->(dbskip())
                   loop
                endif
             else
            if ! left(FAT->Cod_cfop,3) $ "510-511-512-610-611-612"
                   FAT->(dbskip())
                   loop
                endif
             endif
          endif


          @ prow(),pcol() say XCOND1

          ITEN_FAT->(Dbseek(FAT->Codigo))

          do while ! ITEN_FAT->(eof()) .and. ITEN_FAT->Num_fat == FAT->Codigo

             PROD->(Dbseek(ITEN_FAT->Cod_prod))
             @ prow()+1,0  say FAT->Num_fatura
             @ prow()  ,10  say FAT->Codigo
             @ prow()  ,18 say dtoc(FAT->Dt_emissao)
             @ prow()  ,32 say left(PROD->Descricao,20)
             @ prow()  ,58 say left(PROD->Cod_ass,7)
             @ prow()  ,68 say left(PROD->Cod_fabr,7)
             @ prow()  ,81 say left(PROD->Marca,15)
             @ prow()  ,97 say transform(ITEN_FAT->Vl_unitar , "@E 999,999.99")

             @ prow()  ,110 say transform(ITEN_FAT->Quantidade, "@E 999999")

             @ prow()  ,120 say transform((ITEN_FAT->Quantidade * ITEN_FAT->Vl_unitar)+q_soma_st() , "@E 999,999.99")
             nTOT_PROD  := nTOT_PROD +  (ITEN_FAT->Quantidade * ITEN_FAT->Vl_unitar )
             nTOT_PROD += q_soma_st()
             nLIN++
             nQUANT += ITEN_FAT->Quantidade
             ITEN_FAT->(Dbskip())

          enddo
          nTOTAL += nTOT_PROD


          FAT->(dbskip())

          nTOT_PROD := nLIN := nTOT_BRU := nPROD := nICMS_SUBS := 0

    enddo
    @ prow()+1,00 say XCOND0 + replicate("-",80) + XCOND1
    @ prow()+1,97 say transform(nQUANT,"@R 999999")
    @ prow()  ,110 say transform(nTOTAL/nQUANT,"@E 999,999.99")
    @ prow()  ,120 say transform(nTOTAL,"@E 9,999,999.99")
    nTOTAL:= nQUANT := 0
    qstopprn(.F.)
return

//////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IMPRIMIR OS PEDIDOS (EXCELL)___________________________________

static function i_impre_xls

   local cTITULO
   local nTOT_PROD := nLIN := nTOT_BRU := nPROD := nICMS_SUBS := 0
   DUP_FAT->(dbsetorder(2))
   DUP_FAT->(dbgotop())
   ITEN_FAT->(dbsetorder(2))
   ITEN_FAT->(dbgotop())
   FAT->(dbsetfilter({|| FAT->Dt_emissao >= dINI .and. FAT->Dt_Emissao <= dFIM},'FAT->Dt_emissao >= dINI .and. FAT->Dt_Emissao <= dFIM'))
   FAT->(dbsetorder(11))
   FAT->(dbgotop())

     cTITULO := "LISTAGEM DO MOVIMENTO DO CLIENTE :" + left(CLI1->Razao,36)

     PROD->(Dbsetorder(4))


     do while ! FAT->(eof()) .and. qcontprn()

          if XPAGINA == 0 //.or. prow() > K_MAX_LIN
             qpageprn()
             @ prow()+1,00 say chr(9)+chr(9)+cTITULO+"  "+"530"
             CLI1->(Dbseek(cCLIENTE))
             CGM->(Dbseek(CLI1->Cgm_cob))
             @ prow()+1,0 say "Nota"+Chr(9)+"Pedido"+chr(9)+"Emissao"+chr(9)+"Produto"+chr(9)+"Cod. Ass."+chr(9)+"Cod. Fabr."+chr(9)+"Marca"+chr(9)+"Valor Unitario"+chr(9)+"Quantidade"+chr(9)+"Total"
             @ prow()+1,0 say ""

          endif

          if FAT->Cancelado
             FAT->(Dbskip())
             loop
          endif

          if FAT->Cod_cli != cCLIENTE
             FAT->(Dbskip())
             loop
          endif

          if empty(FAT->Num_fatura)
             FAT->(Dbskip())
             loop
          endif

          
            if ! left(FAT->Cod_cfop,3) $ "510-511-512-610-611-612-1202-2202"
                   FAT->(dbskip())
                   loop
            endif
          


          @ prow(),pcol() say XCOND1

          ITEN_FAT->(Dbseek(FAT->Codigo))

          do while ! ITEN_FAT->(eof()) .and. ITEN_FAT->Num_fat == FAT->Codigo

             PROD->(Dbseek(ITEN_FAT->Cod_prod))
             @ prow()+1,0      say FAT->Num_fatura
             @ prow()  ,pcol() say chr(9)+FAT->Codigo
             @ prow()  ,pcol() say chr(9)+dtoc(FAT->Dt_emissao)
             @ prow()  ,pcol() say chr(9)+left(PROD->Descricao,20)
             @ prow()  ,pcol() say chr(9)+left(PROD->Cod_ass,7)
             @ prow()  ,pcol() say chr(9)+left(PROD->Cod_fabr,7)
             @ prow()  ,pcol() say chr(9)+left(PROD->Marca,15)

             @ prow()  ,pcol() say chr(9)+transform(ITEN_FAT->Vl_unitar , "@E 999,999.99")

             @ prow()  ,pcol() say chr(9)+transform(ITEN_FAT->Quantidade, "@E 999999")

             @ prow()  ,pcol() say chr(9)+transform((ITEN_FAT->Quantidade * ITEN_FAT->Vl_unitar) * iif(FAT->Es == "S",(1),(-1)) +q_soma_st() , "@E 999,999.99")
			 @ prow()  ,pcol() say chr(9)+FAT->Cod_cfop
             nTOT_PROD  := nTOT_PROD +  ((ITEN_FAT->Quantidade * ITEN_FAT->Vl_unitar ) * iif(FAT->Es == "S",(1),(-1)))
             nTOT_PROD  := nTOT_PROD +  q_soma_st()
             nLIN++
             nQUANT += ITEN_FAT->Quantidade
             ITEN_FAT->(Dbskip())

          enddo
          nTOTAL += nTOT_PROD


          FAT->(dbskip())

          nTOT_PROD := nLIN := nTOT_BRU := nPROD := nICMS_SUBS := 0

    enddo
    @ prow()+1,00 say ""
    @ prow()+1,0  say replicate(Chr(9),7)+transform(nTOTAL/nQUANT,"@E 999,999.99")+;
    chr(9)+ transform(nQUANT,"@R 999999")+;
    chr(9)+ transform(nTOTAL,"@E 9,999,999.99")
    nTOTAL:= nQUANT := 0
    qstopprn(.F.)
return


