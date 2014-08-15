/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO COMERCIO
// OBJETIVO...: LISTAGEM DE NOTAS FISCAIS
// ANALISTA...: EDUARDO AUGUSTO BORIO
// PROGRAMADOR: EDUARDO AUGUSTO BORIO
// INICIO.....: Janeiro de 2010
// OBS........:
// ALTERACOES.:

function cl578
#define K_MAX_LIN 65

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||lastkey() == 27 }

private cTITULO                   // titulo do relatorio
private dINI
private dFIM
private cREPRES := space(5)
private cVEND   := space(5)
private cRAZAO  := ""

private aEDICAO := {}             // vetor para os campos de entrada de dados

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qgetx(-1,0,@dINI)            } , "INI"    })
aadd(aEDICAO,{{ || qgetx(-1,0,@dFIM)            } , "FIM"    })

aadd(aEDICAO,{{ || view_repres(-1,0,@cREPRES )      } , "REPRES"  })
aadd(aEDICAO,{{ || NIL                          } , NIL  })

aadd(aEDICAO,{{ || view_vend(-1,0,@cVEND )      } , "VEND"})
aadd(aEDICAO,{{ || NIL                          } , NIL  })




do while .T.

   qlbloc(5,0,"B578A","QBLOC.GLO")
   XNIVEL := 1
   XFLAG  := .T.
   dINI := dFIM := ctod("")
   cCLI := Space(5)
   cREPRES := Space(5)
   cVEND   := Space(5)


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
           if ! empty(dINI)
              dFIM := qfimmes(dINI)
           endif

      case cCAMPO == "FIM"
           if dFIM < dINI
             return .F.
           endif

      case cCAMPO == "REPRES"

           qrsay(XNIVEL,cREPRES)

           if empty(cREPRES)
              qrsay(XNIVEL+1, "Todos os Representantes......")
              cRAZAO := " *** Todos ***"
           else
              if ! REPRES->(Dbseek(cREPRES))
                 qmensa("Representante n„o encontrado","B")
                 return .F.
              else
                 qrsay(XNIVEL+1,left(REPRES->Razao,30))
                 cRAZAO := left(REPRES->Razao,25)
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


   cTITULO := "ACERTO COM REPRESENTANTE "+rtrim(cRAZAO) +" de " + dtoc(dINI) + " a " + dtoc(dFIM)

   qmensa("")

   // ESTABELECE RELACOES ENTRE ARQUIVOS ____________________________________


   PROD->(dbsetorder(4))

   FAT->(dbsetorder(2)) // data de emissao
   FAT->(dbgotop())
   set softseek on
   FAT->(Dbseek(dtos(dINI)))
   set softseek off
   ITEN_FAT->(dbsetorder(2))
return .T.



static function i_impressao
   if ! qinitprn() ; return ; endif

   if XLOCALIMP == "X"
//      i_impre_xls()
   else
      i_impre_prn()
   endif

return

static function i_impre_prn
    local nVAL_PED := 0
    local nTOTAL   := 0
    local nDESC    := 0
    local nTOT_DESC:= 0
    local nIPI     := 0
    local nVAL_UNI := 0
    local lTEM     := .F.
    local aFORA    := {}
    local aDENTRO  := {}
    local asFORA   := {}
    local asDENTRO := {}
    local nCONT    := 0
    local nQUANT_PROD := 0
    local nVALOR_PROD := 0
    local cPROD    := ""
    local aITENS   := {}
    local asITENS  := {}
    local nSubst   := 0
    local nST      := 0
    local nICM     := 0
    local nTT_GERAL:= 0
    local nTT_Subst:= 0
    local nTOT_Doc := 0
    local nPROD    := 0
    local nPROD_DOC    := 0
    local nPROD_GER    := 0
    local nST_DOC    := 0
    local nST_GER    := 0
    local lNoSpace := .F.

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________


   do while ! FAT->(eof())  .and. FAT->Dt_emissao >= dINI .and. FAT->Dt_emissao <= dFIM  // condicao principal de loop

      if FAT->Cancelado
         FAT->(dbskip())
         loop
      endif

      if ! left(FAT->Cod_cfop,3) $ "510-511-512-610-611-612-120-220-540-541-640-641-530-531-630-631"
         FAT->(dbskip())
         loop
      endif

      if empty(FAT->Num_fatura) .and. FAT->Es == "S"
         FAT->(dbskip())
         loop
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

      nTOTAL := 0
      nSUBST := 0
      nPROD  := 0

      ITEN_FAT->(dbseek(FAT->codigo))

      do while ! ITEN_FAT->(eof()) .and. ITEN_FAT->num_fat == FAT->Codigo
         nTOTAL += ITEN_FAT->Quantidade * ITEN_FAT->Vl_unitar
         nPROD  += ITEN_FAT->Quantidade * ITEN_FAT->Vl_unitar
         //aadd(aITENS,{ITEN_FAT->Cod_prod,ITEN_FAT->Quantidade,ITEN_FAT->vl_unitar,ITEN_FAT->Bc_subst,ITEN_FAT->Icms,FAT->cod_cli})
         nTOTAL += q_soma_st()
         nSUBST += q_soma_st()
         ITEN_FAT->(dbskip())
      enddo


      aadd(aDENTRO,{FAT->Codigo,FAT->Num_fatura,left(CLI1->Razao,35),FAT->Cod_cfop,dtos(FAT->Dt_emissao),FAT->tipo_doc,nTOTAL,FAT->Dt_emissao,nPROD,nSUBST})

      nTOTAL := 0
      nSUBST := 0
      nPROD  := 0

      FAT->(dbskip())

   enddo


   asDENTRO := asort(aDENTRO,,,{|x,y| x[6] + x[5] + x[2] < y[6] + x[5] + y[2] })

   nTT_GERAL := 0


   if len(asDENTRO) > 0

      cDOC := asDENTRO[1,6]

      nCONT := 1

      do while  nCONT <= len(asDENTRO)

         if XPAGINA == 0 .or. prow() > K_MAX_LIN
            qpageprn()
            qcabecprn(rtrim(cTITULO)+" Estoque Dentro",136)
            @ prow()+1,0 say "Doc  Data Emissao   N.F.      CFOP    Cliente                                      Valor dos Produtos         S.T.       Total"
            @ prow()+1,0 say ""
         endif


         @ prow()+1,00  say asDENTRO[nCONT,6]
         @ prow()  ,05  say dtoc(asDENTRO[nCONT,8])
         @ prow()  ,20  say asDENTRO[nCONT,2]
         @ prow()  ,30  say asDENTRO[nCONT,4]
         @ prow()  ,38  say asDENTRO[nCONT,3]
         @ prow()  ,90  say transform(asDENTRO[nCONT,9] ,"@E 999,999.99")
         @ prow()  ,105 say transform(asDENTRO[nCONT,10],"@E 999,999.99")
         @ prow()  ,120 say transform(asDENTRO[nCONT,7] ,"@E 999,999.99")

         lNoSpace := .F.

         if DUP_FAT->(dbseek(asDentro[nCONT,1]+"01"))
            do While ! DUP_FAT->(eof()) .and. left(DUP_FAT->Num_fat,5) == asDentro[nCONT,1]

               if DUP_FAT->Dias == 0
                  DUP_FAT->(dbskip())
                  loop
                  lNoSpace := .T.
               endif

               @ prow()+1,00  say str(DUP_FAT->Dias,3)+"D "+dtoc(DUP_FAT->Data_venc)
               @ prow()  ,20  say asDentro[nCONT,2]+"/"+right(DUP_FAT->Num_fat,2)
               @ prow()  ,120 say transform(DUP_FAT->Valor,"@E 999,999.99")
               DUP_FAT->(dbskip())
            enddo

            if lNospace
               //
            else
               @ prow()+1,00 say ""
            endif
         endif

         nTOT_DOC   += asDENTRO[nCONT,7]
         nPROD_DOC  += asDENTRO[nCONT,9]
         nST_DOC    += asDENTRO[nCONT,10]

         nTT_GERAL += asDENTRO[nCONT,7]
         nPROD_GER += asDENTRO[nCONT,9]
         nST_GER   += asDENTRO[nCONT,10]

         nCONT++

         if nCONT > len(asDENTRO)
            nCONT := len(asDENTRO)
            exit
         endif

         if asDENTRO[nCONT,6] != cDOC
            TIPO_DOC->(dbseek(cDOC))
            @ prow()+1,00 say replicate("-",136)
            @ prow()+1,00 say "Total do Tipo.: "+cDOC+" - "+TIPO_DOC->Descricao
            @ prow()  ,88 say transform(nPROD_DOC,"@E 9,999,999.99")
            @ prow()  ,103 say transform(nST_DOC,"@E 9,999,999.99")
            @ prow()  ,118 say transform(nTOT_DOC,"@E 9,999,999.99")
            @ prow()+1,00 say ""
            nTOT_DOC  := 0
            nPROD_DOC := 0
            nST_DOC   := 0
            cDOC := asDENTRO[nCONT,6]
         endif

      enddo

      if nTOT_DOC > 0
         @ prow()+1,00 say replicate("-",136)
         TIPO_DOC->(dbseek(cDOC))
         @ prow()+1,00 say "Total do Tipo.: "+cDOC+" - "+TIPO_DOC->Descricao
         @ prow()  ,88 say transform(nPROD_DOC,"@E 9,999,999.99")
         @ prow()  ,103 say transform(nST_DOC,"@E 9,999,999.99")
         @ prow()  ,118 say transform(nTOT_DOC,"@E 9,999,999.99")
         @ prow()+1,00 say ""

         nTOT_DOC  := 0
         nPROD_DOC := 0
         nST_DOC   := 0
      endif

      if nTT_GERAL > 0
         @ prow()+1,00 say replicate("-",136)
         @ prow()+1,00 say "Total Geral.: "
         @ prow()  ,88 say transform(nPROD_GER,"@E 9,999,999.99")
         @ prow()  ,103 say transform(nST_GER,"@E 9,999,999.99")
         @ prow()  ,118 say transform(nTT_GERAL,"@E 9,999,999.99")
         @ prow()+1,00 say ""

      endif

      qstopprn(.F.)
   endif


return

static function prodcare

      nVALOR_PROd := 0
      asITENS := aSort(aITENS,,,{|x,y|  x[1] < y[1] })

      qpageprn()
      qcabecprn("Total por Produto ",136)

      @ prow()+1,0 say "Produto                                                  Quantidade             Sub-Total       S.T.             Total"
      @ prow()+1,0 say ""

      nTT_GERAL := 0
      nSubst := 0

      if len(asITENS) > 0

         cPROD := asITENS[1,1]

         nCONT := 1

         do while  nCONT <= len(asITENS)

            nQUANT_PROD += asITENS[nCONT,2]
            nVALOR_PROD += asITENS[nCONT,2] * asITENS[nCONT,3]
            nTT_GERAL   += asITENS[nCONT,2] * asITENS[nCONT,3]
            CLI1->(dbseek(asITENS[nCONT,6]))

            if  asITENS[nCONT,4] > 0 .and. CLI1->Final $ " -N"
                nST         := ( (asITENS[nCONT,2] * asITENS[nCONT,4]) * (asITENS[nCONT,5] / 100) )
                nICM        := ((asITENS[nCONT,2] * asITENS[nCONT,3]) * (asITENS[nCONT,5] / 100) )
                nSubst      += (nST - nICM)
                nTT_Subst   += (nST - nICM)
            endif


            nST := 0
            nICM := 0

            nCONT++

            if nCONT > len(asITENS)
               nCONT := len(asITENS)
               exit
            endif

            if asITENS[nCONT,1] != cPROD
               PROD->(dbseek(cPROD))
               @ prow()+1,00  say cPROD + " - " + left(PROD->Descricao,40)
               @ prow()  ,60  say transform(nQUANT_PROD,"@R 9999999")
               @ prow()  ,75  say transform(nVALOR_PROD,"@E 99,999,999.99")
               @ prow()  ,90 say transform(nSubst,"@E 999,999.99")
               @ prow()  ,105 say transform(nVALOR_PROD+nSubst,"@E 99,999,999.99")
               nQUANT_PROD := 0
               nVALOR_PROD := 0
               nSubst      := 0
               cPROD := asITENS[nCONT,1]
            endif

         enddo

         if nQUANT_PROD > 0
            PROD->(dbseek(cPROD))
            @ prow()+1,00 say cPROD + " - " + PROD->Descricao
            @ prow()  ,60 say transform(nQUANT_PROD,"@R 9999999")
            @ prow()  ,75 say transform(nVALOR_PROD,"@E 99,999,999.99")
            @ prow()  ,90 say transform(nSubst,"@E 999,999.99")
            @ prow()  ,105 say transform(nVALOR_PROD+nSubst,"@E 99,999,999.99")

            nQUANT_PROD := 0
            nVALOR_PROD := 0
            nSubst := 0
         endif

         if nTT_GERAL > 0
            @ prow()+1,00 say replicate("-",136)
            @ prow()+1,00 say "Total Geral.: "
            @ prow()  ,75 say transform(nTT_GERAL,"@E 99,999,999.99")
            @ prow()  ,90 say transform(nTT_Subst,"@E 999,999.99")
            @ prow()  ,105 say transform(nTT_GERAL+nTT_Subst,"@E 99,999,999.99")

            nQUANT_PROD := 0
            nVALOR_PROD := 0
            nSubst := 0
            nTT_GERAL := 0
            nTT_Subst := 0
         endif


      endif



return

