/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE CONTAS A PAGAR
// OBJETIVO...:
// ANALISTA...: EDUARDO AUGUSTO BORIO
// PROGRAMADOR: EDUARDO AUGUSTO BORIO
// INICIO.....: JANEIRO DE 2003
// OBS........:
// ALTERACOES.:
function pg509

#define K_MAX_LIN 60

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG) .or. empty(dINI) }

private cTITULO                   // titulo do relatorio
private dINI
private dFIM
private cSETOR := space(5)
private cSITUA := space(2)
private cFORN  := space(5)
private aEDICAO := {}             // vetor para os campos de entrada de dados

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qgetx(-1,0,@dINI)            } , "INI"    })
aadd(aEDICAO,{{ || qgetx(-1,0,@dFIM)            } , "FIM"    })
aadd(aEDICAO,{{ || view_forn(-1,0,@cFORN )      } , "FORN"  })
aadd(aEDICAO,{{ || NIL                          } , NIL  })
aadd(aEDICAO,{{ || view_situa(-1,0,@cSITUA                   ) } ,"SITUA"    })
aadd(aEDICAO,{{ || NIL                                         } , NIL        }) // nome do fornecedor
aadd(aEDICAO,{{ || view_set(-1,0,@cSETOR                     ) } ,"SETOR"    })
aadd(aEDICAO,{{ || NIL                                         } , NIL        }) // nome do fornecedor

do while .T.

   qlbloc(5,0,"B501A","QBLOC.GLO")
   XNIVEL := 1
   XFLAG  := .T.
   dINI := dFIM := ctod("")
   cFORN := space(5)
   cSETOR := space(5)
   cSITUA := space(2)
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

      case cCAMPO == "INI"
           if empty(dINI) ; return .F. ; endif
           dFIM := qfimmes(dINI)
           qrsay(XNIVEL+1,dFIM)

      case cCAMPO == "FIM"
           if empty(dFIM) ; return .F. ; endif
           if dINI > dFIM
              qmensa("Data Inicial n„o pode ser maior que a Data Final !","B")
              return .F.
           endif

      case cCAMPO == "FORN"

           qrsay(XNIVEL,strzero(val(cFORN),5))

           if empty(cFORN)
              qrsay(XNIVEL+1, "Todos os Fornecedores.......")
           else
              if ! FORN->(Dbseek(cFORN:=strzero(val(cFORN),5)))
                 qmensa("Fornecedor n„o Cadastrado","B")
                 return .F.
              else
                 qrsay(XNIVEL+1,left(FORN->Razao,30))
              endif
           endif

      case cCAMPO == "SITUA"

           qrsay(XNIVEL,strzero(val(cSITUA),2))

           if empty(cSITUA)
              qrsay(XNIVEL+1, "Todas as Situa‡”es.......")
           else
              if ! SITUA->(Dbseek(cSITUA:=strzero(val(cSITUA),2)))
                 qmensa("Situa‡„o n„o Cadastrada","B")
                 return .F.
              else
                 qrsay(XNIVEL+1,left(SITUA->Descricao,30))
              endif
           endif

      case cCAMPO == "SETOR"

           qrsay(XNIVEL,strzero(val(cSETOR),2))

           if empty(cSETOR)
              qrsay(XNIVEL+1, "Todos os Setores.......")
           else
              if ! SETOR->(Dbseek(cSETOR:=strzero(val(cSETOR),5)))
                 qmensa("Setor n„o Cadastrado","B")
                 return .F.
              else
                 qrsay(XNIVEL+1,left(SETOR->Descricao,30))
              endif
           endif

   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // CRIA TITULO DO RELATORIO ______________________________________________


   cTITULO := "LISTAGEM DE CONTAS A PAGAR" + " de " + dtoc(dINI) + " a " + dtoc(dFIM)
   PAGAR->(dbsetfilter({||iif(!empty(cFORN),Cod_forn == cFORN,Cod_forn != "00000").and.iif(!empty(cSITUA),Situacao == cSITUA,Situacao!="00").and.iif(!empty(cSETOR),Setor == cSETOR,Setor!="00000") }, 'iif(!empty(cFORN),Cod_for == cFORN,cod_forn != "00000").and.iif(!empty(cSITUA),Situacao == cSITUA,Situacao!="00").and.iif(!empty(cSETOR),Setor == cSETOR,Setor!="00000")'))


   PAGAR->(dbsetorder(10))  // RAZAO DO FORNECEDOR
   PAGAR->(dbgotop())
   qmensa("")

   qmensa("")

   // ESTABELECE RELACOES ENTRE ARQUIVOS ____________________________________

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impressao
    local nTOTAL     := 0
    local nTOT_GER   := 0
    local nCONT      := 0
    local aFAT       := {}
    local asFAT      := {}
    local lTEM := .T.

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________
   if ! qinitprn() ; return ; endif

   do while ! PAGAR->(eof())  .and. FAT->Dt_emissao >= dINI .and. FAT->Dt_emissao <= dFIM  // condicao principal de loop

      qgirabarra()

      qmensa("Aguarde... Processando ...")

      aadd(aFAT,{FAT->Num_fatura,FAT->Dt_Emissao,FAT->Cod_cli,left(PROD->Descricao,25),ITEN_FAT->Quantidade,ITEN_FAT->Vl_unitar,CGM->Estado})
      PAGAR->(dbskip())

   enddo

   //classifica a matriz por descricao do produto + Estado
   asFAT := asort(aFAT,,,{|x,y| x[3] + x[1] < y[3] + y[1] })
   if lTEM
       zCLI  := asFAT[1,3]
       nCONT := 1
       do while  nCONT <= len(asFAT)

           if ! qlineprn() ; exit ; endif

           if XPAGINA == 0 .or. prow() > K_MAX_LIN
              @prow()+1,0 say XCOND0
              qpageprn()
              qcabecprn(cTITULO,80)
              @ prow()+1,0 say XCOND1 + "No. NF   Emissao      Cliente                          Produto                       Quantidade      Vl Unitario        Total "
              @ prow()+1,0 say replicate("-",134)
           endif

           nTOT_QUANT += asFAT[nCONT,5]
           nUF_QUANT += asFAT[nCONT,5]
           nUF_VALOR += asFAT[nCONT,5] * asFAT[nCONT,6]//Quantidade * valor unitario
           nTOT_GER += asFAT[nCONT,5] * asFAT[nCONT,6] //Quantidade * valor unitario

           @ prow()+1,00  say asFAT[nCONT,1]                      //Numero da NF
           @ prow()  ,09  say dtoc(asFAT[nCONT,2])                //Data de Emissao
           CLI1->(dbseek(asFAT[nCONT,3]))
           @ prow()  ,22  say left(CLI1->Razao,30)                //Razao do Cliente
           @ prow()  ,55  say asFAT[nCONT,4]                      //Descricao do Produto
           @ prow()  ,88  say transf(asFAT[nCONT,5],"@R 999999")  //Quantidade
           @ prow()  ,100 say transf(asFAT[nCONT,6],"@E 999,999.99") //Quantidade * Vl Unitario
           @ prow()  ,113 say transf(asFAT[nCONT,5]*asFAT[nCONT,6],"@E 99,999,999.99") //Quantidade * Vl Unitario

           nCONT++
           if nCONT > len(asFAT)
              nCONT := len(asFAT)
              exit
           endif

          if alltrim(asFAT[nCONT,3]) != alltrim(zCLI)
              @ prow()+2  ,00 say "TOTAIS DO CLIENTE"
              @ prow()    ,88 say transf(nUF_QUANT,"@R 999999")
              @ prow()    ,113 say transf(nUF_VALOR,"@E 99,999,999.99")
  //            if empty(cCLI)
                 @ prow()    ,130 say transf((nUF_VALOR/nPERC)*100,"@E 99.99") + " %"
  //            endif
              @ prow()+1,00 say replicate("-",136)
              @ prow()+1,00 say ""
              nUF_QUANT := 0
              nUF_VALOR := 0

          endif

         zCLI := asFAT[nCONT,3]

       enddo
       @ prow()+2  ,00 say "TOTAIS DO CLIENTE"
       @ prow()    ,88 say transf(nUF_QUANT,"@R 999999")
       @ prow()    ,113 say transf(nUF_VALOR,"@E 99,999,999.99")
    //   if empty(cCLI)
          @ prow()    ,130 say transf((nUF_VALOR/nPERC)*100,"@E 99.99") + " %"
    //  endif

       @ prow()+1,00 say ""
       nUF_QUANT := 0
       nUF_VALOR := 0


       @ prow()+1,00 say replicate("-",134)
       @ prow()+1,88 say transf(nTOT_QUANT,"@R 9999999")
       @ prow()  ,113 say transf(nTOT_GER,"@E 99,999,999.99")

       nQUANT := 0
       nTOTAL := 0
       nPERC  := 0
   endif

   qstopprn()

return
