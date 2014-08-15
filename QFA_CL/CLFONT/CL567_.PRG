//////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO COMERCIO
// OBJETIVO...: LISTAGEM DE PRODUTOS FATURADOS
// ANALISTA...: EDUARDO AUGUSTO BORIO
// PROGRAMADOR: EDUARDO AUGUSTO BORIO
// INICIO.....: ABRIL de 2008
// OBS........:
// ALTERACOES.:

function cl567
#define K_MAX_LIN 57

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG) .or. empty(dINI) }

private cTITULO                   // titulo do relatorio
private dINI
private dFIM
private aEDICAO := {}             // vetor para os campos de entrada de dados

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qgetx(-1,0,@dINI)            } , "INI"    })
aadd(aEDICAO,{{ || qgetx(-1,0,@dFIM)            } , "FIM"    })

do while .T.

   qlbloc(5,0,"B567A","QBLOC.GLO")
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


   cTITULO := "REl. P/ Pedido de Pecas em Terceiros" +" de " + dtoc(dINI) + " a " + dtoc(dFIM)

   qmensa("")

   // ESTABELECE RELACOES ENTRE ARQUIVOS ____________________________________

   FAT->(dbSetFilter({|| empty(Num_fatura) .and. ES == "S"}))


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
      i_impre_xls()
   else
      i_impre_prn()
   endif



return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impre_prn
    local nTOTAL     := 0
    local nCONT      := 0
    local nQUANT     := 0
    local nTOT_QUANT := 0
    local cPROD      := 0
    local aFAT       := {}
    local asFAT      := {}
    local lTEM := .T.
    local zPROD := space(50)
   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________
    lTEM := .F.
   //if ! qinitprn() ; return ; endif


   do while ! FAT->(eof())  .and. FAT->Dt_emissao >= dINI .and. FAT->Dt_emissao <= dFIM  // condicao principal de loop

      qgirabarra()

      qmensa("Aguarde... Processando ...")

         CLI1->(dbseek(FAT->Cod_cli))

         ITEN_FAT->(Dbgotop())
         ITEN_FAT->(Dbseek(FAT->Codigo))
         do while ITEN_FAT->Num_fat == FAT->Codigo .and. ! ITEN_FAT->(eof())

            if ITEN_FAT->Terceiros > 0
               aadd(aFAT,{ITEN_FAT->Cod_prod,ITEN_FAT->Terceiros})
               lTEM := .T.
            endif

            ITEN_FAT->(Dbskip())
         enddo
         FAT->(dbskip())
         nVALOR := 0
         nDESC := 0
   enddo

   //classifica a matriz por descricao do produto
   asFAT := asort(aFAT,,,{|x,y| x[1] < y[1] })
   if lTEM
       cPROD := asFAT[1,1]
       PROD->(dbsetorder(4))
       PROD->(Dbseek(cPROD))
       zPROD := Prod->Cod_ass+" "+left(PROD->Cod_fabr,6) + " " + left(PROD->Descricao,18)+ " " +Left(Prod->Marca,10)

       nCONT := 1
       do while  nCONT <= len(asFAT)

           if ! qlineprn() ; exit ; endif
           if XPAGINA == 0 .or. prow() > K_MAX_LIN
              @prow()+1,0 say XCOND1

              qpageprn()
              qcabecprn(cTITULO,134)
              @ prow()+1,0 say XCOND1 + "Produto                                                                   Qtde.       "
              @ prow()+1,0 say replicate("-",134)
           endif

           nQUANT += asFAT[nCONT,2]
           nTOT_QUANT += asFAT[nCONT,2]

           nCONT++
           if nCONT > len(asFAT)
              nCONT := len(asFAT)
              exit
           endif
           if asFAT[nCONT,1] != cPROD
              @ prow()+1,00 say zPROD
              @ prow()  ,73 say transf(nQUANT,"@R 999999")

              cPROD := asFAT[nCONT,1]

              PROD->(Dbseek(cPROD))
              zPROD := Prod->Cod_ass+" "+left(PROD->Cod_fabr,6) + " " + left(PROD->Descricao,18)+ " " +Left(Prod->Marca,10)

              nQUANT     := 0
           endif
       enddo

       @ prow()+1,00 say zPROD            //descricao do produto
       @ prow()  ,73 say transf(nQUANT,"@R 999999")

       nQUANT     := 0
       nQUANT_ENT := 0
       nTOTAL     := 0
       nTOTAL_ENT := 0
       nPERC  := 0
   endif

   qstopprn()

return



/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impre_xls
    local nTOTAL     := 0
    local nCONT      := 0
    local nQUANT     := 0
    local nTOT_QUANT := 0
    local cPROD      := 0
    local aFAT       := {}
    local asFAT      := {}
    local lTEM := .T.
    local zPROD := space(50)
   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________
    lTEM := .F.
   //if ! qinitprn() ; return ; endif


   do while ! FAT->(eof())  .and. FAT->Dt_emissao >= dINI .and. FAT->Dt_emissao <= dFIM  // condicao principal de loop

      qgirabarra()

      qmensa("Aguarde... Processando ...")

         CLI1->(dbseek(FAT->Cod_cli))

         ITEN_FAT->(Dbgotop())
         ITEN_FAT->(Dbseek(FAT->Codigo))
         do while ITEN_FAT->Num_fat == FAT->Codigo .and. ! ITEN_FAT->(eof())

            if ITEN_FAT->Terceiros > 0
               aadd(aFAT,{ITEN_FAT->Cod_prod,ITEN_FAT->Terceiros})
               lTEM := .T.
            endif

            ITEN_FAT->(Dbskip())
         enddo
         FAT->(dbskip())
         nVALOR := 0
         nDESC := 0
   enddo

   //classifica a matriz por descricao do produto
   asFAT := asort(aFAT,,,{|x,y| x[1] < y[1] })
   if lTEM
       cPROD := asFAT[1,1]
       PROD->(dbsetorder(4))
       PROD->(Dbseek(cPROD))
       zPROD := Prod->Cod_ass+chr(9)+left(PROD->Cod_fabr,6) + chr(9) + left(PROD->Descricao,18)+ chr(9) +Left(Prod->Marca,10)

       nCONT := 1
       do while  nCONT <= len(asFAT)

           if XPAGINA == 0 //.or. prow() > K_MAX_LIN
              qpageprn()
              @ prow()+1,0 say Chr(9)+chr(9)+cTITULO + " 567"
              @ prow()+1,0 say "Ref." +chr(9)+ "Ref2."+Chr(9)+"Descricao"+chr(9)+"Colecao"+chr(9)+"Quantidade"
              @ prow()+1,0 say " "
           endif

           nQUANT += asFAT[nCONT,2]
           nTOT_QUANT += asFAT[nCONT,2]

           nCONT++
           if nCONT > len(asFAT)
              nCONT := len(asFAT)
              exit
           endif

           if asFAT[nCONT,1] != cPROD
              @ prow()+1,00 say zPROD
              @ prow()  ,pcol() say chr(9)+transf(nQUANT,"@R 999999")

              cPROD := asFAT[nCONT,1]

              PROD->(Dbseek(cPROD))
              zPROD := Prod->Cod_ass+chr(9)+left(PROD->Cod_fabr,6) + chr(9) + left(PROD->Descricao,18)+ chr(9) +Left(Prod->Marca,10)

              nQUANT     := 0
           endif
       enddo

       @ prow()+1,00     say zPROD            //descricao do produto
       @ prow()  ,pcol() say chr(9)+transf(nQUANT,"@R 999999")

       nQUANT     := 0
       nQUANT_ENT := 0
       nTOTAL     := 0
       nTOTAL_ENT := 0
       nPERC  := 0
   endif

   qstopprn(.F.)

return



