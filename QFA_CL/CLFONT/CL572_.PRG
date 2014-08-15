//////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO COMERCIO
// OBJETIVO...: LISTAGEM DE PRODUTOS FATURADOS
// ANALISTA...: EDUARDO AUGUSTO BORIO
// PROGRAMADOR: EDUARDO AUGUSTO BORIO
// INICIO.....: SETEMBRO DE 2002
// OBS........:
// ALTERACOES.:

function cl572
#define K_MAX_LIN 57

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG) .or. empty(dINI) }

private cTITULO                   // titulo do relatorio
private dINI
private dFIM
private cSETOR := space(5)
private aEDICAO := {}             // vetor para os campos de entrada de dados
private aAnomes := {}             // vetor para os campos de entrada de dados

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qgetx(-1,0,@dINI)            } , "INI"    })
aadd(aEDICAO,{{ || qgetx(-1,0,@dFIM)            } , "FIM"    })
aadd(aEDICAO,{{ || view_prod(-1,0,@cSETOR)     } , "SETOR"  })
aadd(aEDICAO,{{ || NIL                          } , NIL  })

do while .T.

   qlbloc(5,0,"B572A","QBLOC.GLO")
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

   if !quse(XDRV_ES,"RESERVA",{"RESERVA1"},"E",NIL)
      qmensa("Nap foi possivel abrir RESERVA.DBF","BL")
      return .F.
   endif

   if ( i_inicializacao() , i_impressao() , NIL )

   RESERVA->(DbCloseArea())


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
              qrsay(XNIVEL++, "Todos os Produtos......")
           else
              if ! PROD->(Dbseek(cSETOR:=strzero(val(cSETOR),5)))
                 qmensa("Produto n„o Cadastrado","B")
                 return .F.
              else
                 qrsay(XNIVEL++,left(PROD->Descricao,30))
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

   if ! quse(XDRV_CL,"FI572A",{"FI572A"},"E")
      qmensa("Nao foi possivel abrir arquivo temporario!! Tente Novamente.")
      return
   endif

   if ! quse(XDRV_CL,"FI572B",{"FI572B"},"E")
      qmensa("Nao foi possivel abrir arquivo temporario!! Tente Novamente.")
      return
   endif

   FI572A->(__dbzap())
   FI572B->(__dbzap())

   i_reserva()


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
    local nQUANT     := 0
    local cPROD      := 0
    local aEstoque   := {}
    local lTEM := .T.
    local zPROD := space(50)

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

    lTEM := .F.

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

      if ! left(FAT->Cod_cfop,3) $ "510-511-512-540-610-611-612-591-691-640-120-220"
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
             nVALOR := ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade
             nVALOR += q_soma_st()

             if FI572A->(Qappend())
                replace FI572A->Cod_prod     with ITEN_FAT->Cod_prod
                replace FI572A->Anomes       with i_Anomes(FAT->Dt_emissao)
                replace FI572A->Quantidade   with ITEN_FAT->Quantidade
                replace FI572A->vl_unitar    with ITEN_FAT->vl_unitar
                replace FI572A->Es           with FAT->Es
                replace FI572A->Total        with nVALOR
             endif

             ITEN_FAT->(Dbskip())
             nVALOR := 0
             lTEM := .T.
         enddo
         FAT->(dbskip())
         nVALOR := 0
   enddo

   FI572A->(dbcommit())
   FI572A->(dbgotop())

   cPROD   := FI572A->Cod_prod
   cANOMES := FI572A->Anomes
   nQUANT  := 0

   do while ! FI572A->(eof())


      if FI572A->Es == "S"
         nQUANT+= FI572A->Quantidade
      else
         nQUANT-= FI572A->Quantidade
      endif

      FI572A->(Dbskip())

      if cPROD + cANOMES !=  FI572A->cod_prod + FI572A->Anomes
         if FI572B->(qappend())
            replace FI572B->Cod_prod     with cPROD
            replace FI572B->Quantidade   with nQUANT
            replace FI572B->Anomes       with cANOMES
         endif

         cANOMES := FI572A->Anomes
         cPROD   := FI572A->Cod_prod
         nQUANT  := 0

      endif

   enddo

   FI572B->(dbcommit())
   FI572B->(dbgotop())

   nQUANT := 0
   cPROD := FI572B->cod_prod
   do while ! FI572B->(eof())


      if XPAGINA == 0 .or. prow() > K_MAX_LIN
         @prow()+1,0 say XCOND1
         qpageprn()
         qcabecprn(cTITULO,134)
         @ prow()+1,0 say "Ref1.  Ref2.                                                          Mes/Ano               Qtde     Estoque Avaria    Saldo"
         @ prow()+1,0 say replicate("-",134)
      endif

      PROD->(dbseek(FI572B->Cod_prod))

      nQUANT+= FI572B->Quantidade

      @ prow()+1,00 say left(PROD->cod_fabr,6) +" "+ PROD->Cod_ass
      @ prow()  ,70 say right(FI572B->Anomes,2)+"/"+left(FI572B->anomes,4)
      @ prow()  ,90 say transform(FI572B->Quantidade,"@R 999999")
      
      FI572B->(dbskip())

      if cPROD != Fi572B->cod_prod
         aEstoque := i_calcEstoque(cPROD)
         @ prow()+1,00     say "Total do Produto..: "+left(PROD->cod_fabr,6) +" "+ PROD->Cod_ass
         @ prow()  ,pcol()   say "  " + left(PROD->Descricao,20) +" "+ PROD->Marca
         @ prow()  ,90    say transform(nQUANT,"@R 999999")
         @ prow()  ,100   say transform(aEstoque[1,1],"@R 99999")
         @ prow()  ,110   say transform(aEstoque[1,2],"@R 99999")
         @ prow()  ,120   say transform(aEstoque[1,3],"@R 99999")
         @ prow()+1,00    say replicate("-",132)
         @ prow()+1,00    say ""



         cPROD := FI572B->cod_prod
         nQUANT := 0
      endif


   enddo

   @ prow()+1,00     say "Total do Produto..: "+left(PROD->cod_fabr,6) +" "+ PROD->Cod_ass
   @ prow()  ,pcol()   say "  " + left(PROD->Descricao,20) +" "+ PROD->Marca
   @ prow()  ,90    say transform(nQUANT,"@R 999999")
   @ prow()+1,00    say replicate("-",132)
   @ prow()+1,00    say ""

   cPROD := FI572B->cod_prod
   nQUANT := 0

   FI572A->(__dbzap())
   FI572B->(__dbzap())
   FI572A->(dbclosearea())

   FI572B->(dbclosearea())

   qstopprn(.F.)


return

static function i_impre_xls
    local nQUANT     := 0
    local cPROD      := 0
    local cTABS      := ""
    local cGeraCabec := ""
    local aEstoque   := {}
    local lTEM := .T.
    local lStartNewProduto := .F.
    local zPROD := space(50)
    local aCabec      := {}
    local uPosicao    := 0
    local nMEDIA      := 0

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

    lTEM := .F.

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
      if ! left(FAT->Cod_cfop,3) $ "510-511-512-540-610-611-612-640-591-691-120-220"
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
             nVALOR := ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade
             nVALOR += q_soma_st()

             if FI572A->(Qappend())
                replace FI572A->Cod_prod     with ITEN_FAT->Cod_prod
                replace FI572A->Anomes       with i_Anomes(FAT->Dt_emissao)
                replace FI572A->Quantidade   with ITEN_FAT->Quantidade
                replace FI572A->vl_unitar    with ITEN_FAT->vl_unitar
                replace FI572A->Es           with FAT->Es
                replace FI572A->Total        with nVALOR
             endif

             ITEN_FAT->(Dbskip())
             nVALOR := 0
             lTEM := .T.
         enddo
         FAT->(dbskip())
         nVALOR := 0
   enddo

   FI572A->(dbcommit())
   FI572A->(dbgotop())

   cPROD   := FI572A->Cod_prod
   cANOMES := FI572A->Anomes
   nQUANT  := 0

   do while ! FI572A->(eof())


      if FI572A->Es == "S"
         nQUANT+= FI572A->Quantidade
      else
         nQUANT-= FI572A->Quantidade
      endif

      FI572A->(Dbskip())

      if cPROD + cANOMES !=  FI572A->cod_prod + FI572A->Anomes
         if FI572B->(qappend())
            replace FI572B->Cod_prod     with cPROD
            replace FI572B->Quantidade   with nQUANT
            replace FI572B->Anomes       with cANOMES
         endif

         cANOMES := FI572A->Anomes
         cPROD   := FI572A->Cod_prod
         nQUANT  := 0

      endif

   enddo

   FI572B->(dbcommit())
   FI572B->(dbgotop())

   nQUANT := 0
   cPROD := FI572B->cod_prod
   lStartNewProduto := .T.
   uPosicao := 0

   do while ! FI572B->(eof())


      if XPAGINA == 0 //.or. prow() > K_MAX_LIN
         @prow()+1,0 say ""
         qpageprn()
         @ prow()+1,0 say chr(9)+chr(9)+cTITULO+" 572"
         @ prow()+1,0 say "Ref1"+chr(9)+"Ref2"+chr(9)+"Descricao"+chr(9)+"Marca"
         GeraCabec(dINI,dFIM)
         @ prow(),pcol() say chr(9)+"Total"+chr(9)+"Media Mensal"+chr(9)+"Local"+chr(9)+"Terceiros"+ chr(9)+"Total Estoque"
         nMedia := len(aAnomes)

      endif

      if lStartNewProduto
         PROD->(dbseek(cPROD))
         @ prow()+1,00 say " "+left(PROD->cod_fabr,6)+" " +chr(9)+ " "+PROD->Cod_ass +" "+ chr(9) + PROD->Descricao + chr(9)+ PROD->Marca
         lStartNewProduto := .F.
      endif

      nQUANT+= FI572B->Quantidade

      Escolhecoluna(FI572B->Anomes,@uPosicao)

      @ prow()  ,pcol() say chr(9)+transform(FI572B->Quantidade,"@R 999999")

      FI572B->(dbskip())

      if cPROD != Fi572B->cod_prod
         aEstoque := i_calcEstoque(cPROD)
         PreencheResto(@uPosicao)
         @ prow()  ,pcol()   say chr(9)+transform(nQUANT,"@R 999999")
         @ prow()  ,pcol()   say chr(9)+transform(abs(nQUANT/nMEDIA),"@R 999999")
         @ prow()  ,pcol()   say chr(9)+transform(aEstoque[1,1],"@R 999999")
         @ prow()  ,pcol()   say chr(9)+transform(aEstoque[1,2],"@R 999999")
         @ prow()  ,pcol()   say chr(9)+transform(aEstoque[1,3],"@R 999999")

         cPROD := FI572B->cod_prod
         nQUANT := 0
         lStartNewProduto := .T.
         uPosicao := 0
      endif


   enddo

   aEstoque := i_calcEstoque(cPROD)
   PreencheResto(@uPosicao)
   @ prow()  ,pcol()   say chr(9)+transform(nQUANT,"@R 999999")
   @ prow()  ,pcol()   say chr(9)+transform(abs(nQUANT/nMEDIA),"@R 999999")
   @ prow()  ,pcol()   say chr(9)+transform(aEstoque[1,1],"@R 999999")
   @ prow()  ,pcol()   say chr(9)+transform(aEstoque[1,2],"@R 999999")
   @ prow()  ,pcol()   say chr(9)+transform(aEstoque[1,3],"@R 999999")

   cPROD := FI572B->cod_prod
   nQUANT := 0
   lStartNewProduto := .T.
   uPosicao := 0


   cPROD := FI572B->cod_prod
   nQUANT := 0

   FI572A->(__dbzap())
   FI572B->(__dbzap())
   FI572A->(dbclosearea())
   FI572B->(dbclosearea())

   qstopprn(.F.)


return

static function i_anomes(dDATA)
local result := ""

   result := strzero(year(dDATA),4)+strzero(month(dDATA),2)

return result

static function i_calcEstoque(Cod_prod)
local nQUANT_RES  := 0  //Avariados
local nQUANT_AVAR := 0  //Avariados
local nQUANT_TER  := 0  //Em Transicao
local nQUANT_RT   := 0  //Em Transicao
local nQUANT_TT   := 0  //Em Transicao
local nQUANT      := 0  //Em Transicao
local aResult := {}

  INVENT->(dbsetorder(4))
  INVENT->(dbseek(cod_prod))

  do while ! INVENT->(eof()) .and. INVENT->Cod_prod == right(PROD->Codigo,5)
     nQUANT      += INVENT->Quant_atu
     nQUANT_AVAR += INVENT->Quant_defe
     nQUANT_TER  += INVENT->QUANT_TER
     nQUANT_RT   += INVENT->QUANT_RES

     INVENT->(dbskip())
  enddo

  if RESERVA->(dbseek(cod_prod))
     nQUANT_RES := RESERVA->Quantidade
  else
     nQUANT_RES := 0
  endif

  nQUANT_TT   := (nQUANT + nQUANT_TER + nQUANT_RES - nQUANT_RT)

  aadd(aResult,{nQUANT+nQUANT_RES,nQUANT_TER-nQUANT_RT,nQUANT_TT})

return aResult


static function i_reserva
local aPED := {}
local aPEDS := {}
local lTEM := .F.
local cLOTE   := space(10)
local cFILIAL := space(4)
local nQTY    := 0
local cPROD   := space(5)
local nCONT   := 1

RESERVA->(__Dbzap())

FAT->(dbsetfilter({|| ( ! left(Cod_cfop,4) $ "5905-6905" ) .and. empty(num_fatura) .and. Es == "S" .and. No_nf == .F. }))
ITEN_FAT->(dbsetorder(2))
FAT->(dbgotop())

Do while ! FAT->(eof())

   ITEN_FAT->(Dbseek(FAT->Codigo))

   Do while ! ITEN_FAT->(eof()) .and. ITEN_FAT->Num_fat == FAT->Codigo
      aadd(aPED,{ITEN_FAT->Cod_prod,FAT->Filial,ITEN_FAT->Num_Lote,ITEN_FAT->Quantidade})
      lTEM := .T.
      ITEN_FAT->(dbskip())
   enddo


   FAT->(Dbskip())
enddo

asPED := asort(aPED,,,{|x,y| x[1] < y[1] })

if lTEM
    cPROD   := asPED[1,1]
    cFILIAL := asPED[1,2]
    cLOTE   := asPED[1,3]
    nQTY    := 0

    nCONT := 1
    do while  nCONT <= len(asPED)

        nQTY += asPED[nCONT,4]

        nCONT++
        if nCONT > len(asPED)
           nCONT := len(asPED)
           exit
        endif

        if asPED[nCONT,1] != cPROD
           if RESERVA->(qappend())
              replace RESERVA->Cod_prod   with cPROD
              replace RESERVA->Filial     with cFILIAL
              replace RESERVA->Lote       with cLOTE
              replace RESERVA->Quantidade with nQTY
           endif

           cPROD   := asPED[nCONT,1]
           cFILIAL := asPED[nCONT,2]
           cLOTE   := asPED[nCONT,3]
           nQTY    := 0
        endif
    enddo

    if RESERVA->(qappend())
       replace RESERVA->Cod_prod   with cPROD
       replace RESERVA->Filial     with cFILIAL
       replace RESERVA->Lote       with cLOTE
       replace RESERVA->Quantidade with nQTY
    endif

    RESERVA->(dbcommit())
endif

FAT->(dbclearfilter())
aPED := {}
asPED := {}

return

static function EscolheColuna(cANOMES,nPos)
local nCONT    := 0
local nIndexOf := 0
local nDif     := 0

   nIndexOf := ascan(aAnomes,cAnomes)

   nDif := nIndexOf - nPos

   for nCONT := 1 to (nDIF-1)
       @ prow(), pcol() say chr(9)+"0"
   next

   nPos := nIndexOf


return

static function PreencheResto(nPos)
local nCONT    := 0
local nResto   := 0

   nResto := len(aAnomes) - nPos

   for nCONT := 1 to nResto
       @ prow(), pcol() say chr(9)+"0"
   next

return



static function geraCabec(dINICIAL,dFINAL)
local nMESES  := 0
local intCONT   := 0
local cANOMES := 0
local nANOMES_INI := 0
local nANOMES_FIM := 0
local lFIRST := .T.
local cResult := ""
local lFisrt := .F.

cANOMES := strzero(year(dINICIAL),4)+strzero(month(dINICIAL),2)
nANOMES_INI := val(cANOMES)

cANOMES := strzero(year(dFINAL),4)+strzero(month(dFINAL),2)
nANOMES_FIM := val(cANOMES)

aAnomes := {}

lFirst := .T.

For intCONT := nANOMES_INI To nANOMES_FIM

    @ prow(),pcol() say  chr(9)+right(strzero(intCont,6),2)+"/"+left(strzero(intCont,6),4)

    aadd(aAnomes,strzero(intCONT,6))

    if right(strzero(intCONT),2) == "12"
       intCONT += 88
    endif

    nMESES++


next

return



