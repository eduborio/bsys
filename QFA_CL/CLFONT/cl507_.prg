/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO COMERCIO
// OBJETIVO...: LISTAGEM DE PRODUTOS PARA ENTREGAR
// ANALISTA...: EDUARDO AUGUSTO BORIO
// PROGRAMADOR: EDUARDO AUGUSTO BORIO
// INICIO.....: SETEMBRO DE 2002
// OBS........:
// ALTERACOES.:

function cl507
#define K_MAX_LIN 60

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


   cTITULO := "LISTAGEM DE PRODUTOS PARA ENTREGAR" +" de " + dtoc(dINI) + " a " + dtoc(dFIM)

   qmensa("")

   // ESTABELECE RELACOES ENTRE ARQUIVOS ____________________________________

   FAT->(dbsetorder(8)) // data de saida
   FAT->(dbgotop())
   set softseek on
   FAT->(Dbseek(dtos(dINI)))
   set softseek off
   ITEN_FAT->(dbsetorder(2))
return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impressao
    local nTOTAL     := 0
    local nTOT_GER   := 0
    local nCONT      := 0
    local nQUANT     := 0
    local nTOT_QUANT := 0
    local cPROD      := 0
    local aFAT       := {}
    local asFAT      := {}
    local lTEM := .T.
   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________
    lTEM := .F.
   if ! qinitprn() ; return ; endif

   do while ! FAT->(eof())  .and. FAT->Entregar >= dINI .and. FAT->Entregar <= dFIM  // condicao principal de loop

      if FAT->Cancelado
         FAT->(dbskip())
         loop
      endif

      if !empty(FAT->Num_fatura)
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

      qgirabarra()

      qmensa("Aguarde... Processando ...")

         CLI1->(dbseek(FAT->Cod_cli))

         ITEN_FAT->(Dbgotop())
         ITEN_FAT->(Dbseek(FAT->Codigo))
         do while ITEN_FAT->Num_fat == FAT->Codigo .and. ! ITEN_FAT->(eof())

             PROD->(dbsetorder(4))
             PROD->(dbseek(ITEN_FAT->Cod_Prod))
             aadd(aFAT,{FAT->Codigo,FAT->Dt_emissao,left(CLI1->Razao,45),dtoc(FAT->Entregar),ITEN_FAT->Quantidade,PROD->Descricao,ITEN_FAT->Vl_unitar})
             ITEN_FAT->(Dbskip())
             lTEM := .T.
         enddo
         FAT->(dbskip())

   enddo
   //classifica a matriz por descricao do produto
   asFAT := asort(aFAT,,,{|x,y| x[6] + x[4] < y[6] + y[4] })
   if lTEM
       cPROD := asFAT[1,6]
       nCONT := 1
       do while  nCONT <= len(asFAT)

           if ! qlineprn() ; exit ; endif
           if XPAGINA == 0 .or. prow() > K_MAX_LIN
              @prow()+1,0 say XCOND0
              qpageprn()
              qcabecprn(cTITULO,80)
              @ prow()+1,0 say XCOND1 + "Pedido Emissao     Cliente                      Entregar   Quantidade Produto                               Unit      Vlr Total Total"
              @ prow()+1,0 say replicate("-",134)
           endif
           @ prow()+1,00 say asFAT[nCONT,1]
           @ prow()  ,07 say dtoc(asFAT[nCONT,2])
           @ prow()  ,19 say left(asFAT[nCONT,3],28)
           @ prow()  ,48 say asFAT[nCONT,4]
           @ prow()  ,61 say transf(asFAT[nCONT,5],"@R 9999999")
           @ prow()  ,70 say left(asFAT[nCONT,6],28)
           @ prow()  ,102 say transf(asFAT[nCONT,7],"@E 999,999.99")
           @ prow()  ,115 say transf(asFAT[nCONT,7]*asFAT[nCONT,5],"@E 9,999,999.99")



           nQUANT += asFAT[nCONT,5]
           nTOT_QUANT += asFAT[nCONT,5]
           nCONT++
           if nCONT > len(asFAT)
              nCONT := len(asFAT)
              exit
           endif
           if asFAT[nCONT,6] != cPROD
              @ prow()  ,126 say transf(nQUANT,"@R 9999999")
              @ prow()+1,00 say replicate("-",134)
              cPROD := asFAT[nCONT,6]
              nQUANT := 0
           endif
       enddo
       @ prow()  ,126 say transf(nQUANT,"@R 9999999")

       @ prow()+1,00 say replicate("-",134)
       @ prow()+1,126 say transf(nTOT_QUANT,"@R 9999999")

       nQUANT := 0
       nTOTAL := 0
       nTOT_QUANT := 0
   endif

   qstopprn()

return
