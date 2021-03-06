/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE ESTOQUE
// OBJETIVO...: SALDO ATUAL DOS PRODUTOS
// ANALISTA...: Eduardo borio
// PROGRAMADOR: Eduardo Borio
// INICIO.....: AGOSTO DE 1997
// OBS........:
// ALTERACOES.: DEZEMBRO de 2006
function es507

#define K_MAX_LIN 55

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE  := {||(XNIVEL==1 .and. !XFLAG) .or. lastkey() = 27}

private cTITULO                // titulo do relatorio
private aEDICAO   := {}        // vetor para os campos
private cCOD_PROD := space(5)  // produto
private cFILIAL   := space(4)  // filial
private cTIPO     := space(1)  // Tipo de Produto
private sBLOC1    := qlbloc("B507B","QBLOC.GLO")
private aReservas := {}


// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || view_filial(-1,0,@cFILIAL,"@R 9999"   )},"FILIAL"  })
aadd(aEDICAO,{{ || NIL },NIL }) // descricao da filial
aadd(aEDICAO,{{ || view_prod(-1,0,@cCOD_PROD,"@R 99999"  )},"COD_PROD"})
aadd(aEDICAO,{{ || NIL },NIL }) // descricao do produto
aadd(aEDICAO,{{ || qesco(-1,0,@cTIPO       ,sBLOC1       )} ,"TIPO" })


do while .T.

   qlbloc(5,0,"B507A","QBLOC.GLO")

   XNIVEL     := 1
   XFLAG      := .T.
   cFILIAL    := space(4)
   cCOD_PROD  := space(5)
   cTIPO      := space(1)

   // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; dbcloseall() ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   quse(XDRV_CL,"CONFIG",NIL,NIL,"FATCFG")

   iif( i_inicializacao() , i_impressao() , NIL )

   FATCFG->(DbCloseArea())

enddo

/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA _____________________________________________

static function i_critica ( cCAMPO )

   qmensa("")

   do case

      case cCAMPO == "COD_PROD"

           if empty(cCOD_PROD)
              qrsay(XNIVEL+1,"*** Todos os Produtos ***")
           else
              PROD->(dbsetorder(4))

              if ! PROD->(dbseek(cCOD_PROD:=strzero(val(cCOD_PROD),5)))
                 qmensa("Produto n�o cadastrado !","B")
                 return .F.
              endif

              qrsay(XNIVEL+1,left(PROD->Descricao,36))

              if ! INVENT->(dbseek(cFILIAL+cCOD_PROD))
                 qmensa("N�o Existe Invent�rio para este Produto !","B")
                 return .F.
              endif
           endif

      case cCAMPO == "FILIAL"

           if empty(cFILIAL) ; return .F. ; endif

           qrsay(XNIVEL,cFILIAL:=strzero(val(cFILIAL),4))

           if ! FILIAL->(dbseek(cFILIAL))
              qmensa("Filial n�o encontrado !","B")
              return .F.
           endif

           qrsay(XNIVEL+1,left(FILIAL->Razao,30))

      case cCAMPO == "TIPO"
          // if empty(cTIPO) ; return .F. ; endif
           qrsay(XNIVEL,qabrev(cTIPO," 123456", {"Todos","Produto Acabado","Matria prima","Material","Embalagens","Vazios","Outros"}))


   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ____________________________

static function i_inicializacao

   if cTIPO $ "1-2-3-4-5-6-7-8-9"
      PROD->(DbClearFilter())
      PROD->(dbsetfilter({|| PROD->Tipo == cTIPO},'PROD->Tipo == cTIPO'))
   Endif

   cTITULO := "SALDO ATUAL NA " + cFILIAL + "-" + ALLTRIM(FILIAL->Razao)

   if CONFIG->Mantra == "S"
      PROD->(dbsetorder(3)) // codigo
   else
      PROD->(dbsetorder(1)) // codigo
   endif
   INVENT->(dbsetorder(1)) // filial + produto

   if FATCFG->Modelo_fat == "1"
      i_reserva()
   endif

   qmensa()

return .T.

static function i_impressao

   if ! qinitprn() ; return  ; endif

   if XLOCALIMP == "X"
      i_impre_xls()
   else
      i_impre_prn()
   endif

return


/////////////////////////////////////////////////////////////////////////////
// MODULO PRINCIPAL DE IMPRESSAO ____________________________________________

static function i_impre_prn

local nQUANT_AVAR := 0  //Avariados
local nQUANT_SHOW := 0  //Show Room
local nQUANT_TER  := 0  //Em Transicao
local nQUANT_TT   := 0  //Total
local nQUANT_RES  := 0  //Reservado aguardando faturamento
local nQUANT_RT   := 0  //Reservado aguardando faturamento

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   @ prow(),pcol() say XCOND1

   do while ! PROD->(eof()) .and. qcontprn()

      if mod(PROD->(Recno()),75) == 1
         if ! qlineprn() ; exit ; endif
      endif

      qgirabarra()

      if ! empty(cCOD_PROD)
         if right(PROD->Codigo,5) <> cCOD_PROD
            exit
         endif
      endif

      //if PROD->Fora_Linha == "S"
      //   PROD->(dbskip())
      //   loop
      //endif

      if XPAGINA == 0 .or. prow() > K_MAX_LIN
         qpageprn()
         qcabecprn(cTITULO,134)
         @ prow()+1,0 say "FILIAL  ->"+ cFILIAL   + "-" + FILIAL->Razao
         @ prow()+1,0 say replicate("-",134)
         @ prow()+1,0 say "PRODUTO                                              Qtd. Local                    Expedicao    Avariados   Baixa      Qtd. Total    Preco Unit"
         @ prow()+1,0 say replicate("-",134)
      endif

      INVENT->(dbgotop())

      if empty(cCOD_PROD)
         if ! INVENT->(dbseek(cFILIAL+right(PROD->Codigo,5)))
            PROD->(dbskip())
            loop
         endif
      else
         INVENT->(dbseek(cFILIAL+cCOD_PROD))
         PROD->(dbsetorder(4))
         PROD->(dbseek(cCOD_PROD))
         if CONFIG->Mantra == "S"
            PROD->(dbsetorder(3)) // codigo
         else
            PROD->(dbsetorder(1)) // codigo
         endif
      endif

//    PROD->(dbseek(INVENT->Cod_prod))

      // rotina que localiza todos os produtos lancados no inventario de lotes distintos
      nQUANT      := 0
      nQUANT_AVAR := 0
      nQUANT_SHOW := 0
      nQUANT_TER  := 0
      nQUANT_TT   := 0
      do while ! INVENT->(eof()) .and. INVENT->Cod_prod == right(PROD->Codigo,5)
         nQUANT      += INVENT->Quant_atu
         nQUANT_AVAR += INVENT->Quant_defe
         nQUANT_SHOW += INVENT->Quant_show

         INVENT->(dbskip())
      enddo

      nQUANT_RES := buscaReservas(right(PROD->Codigo,5))

      nQUANT_TT   := (nQUANT + nQUANT_AVAR + nQUANT_SHOW + nQUANT_RES)

      UNIDADE->(dbseek(Prod->Unidade))
      @ prow()+1,00 say iif(FATCFG->Modelo_fat == "1",PROD->Corredor + PROD->Estante + "  "+left(PROD->Cod_fabr,7),right(PROD->Codigo,5))  + " - " + PROD->Cod_ass +" "+ left(PROD->Descricao,20)+" "+left(PROD->Marca,08)   + " " +UNIDADE->Sigla+" "+;
                        iif( right(PROD->Codigo,5) <> "     " , transform(nQUANT     ,"@R 9999999"),)  + space(7) +;
                        iif( right(PROD->Codigo,5) <> "     " , transform(nQUANT_RES ,"@R 9999999"),)  + space(7) +;
                        iif( right(PROD->Codigo,5) <> "     " , space(7)                           ,)  + space(7) +;
                        iif( right(PROD->Codigo,5) <> "     " , transform(nQUANT_AVAR,"@R 9999999"),)  + space(7) +;
                        iif( right(PROD->Codigo,5) <> "     " , transform(nQUANT_SHOW,"@R 9999999"),)  + space(7) +;
                        iif( right(PROD->Codigo,5) <> "     " , transform(nQUANT_TT  ,"@R 9999999"),)  + space(4) +;
                        transform(PROD->Preco_cons,"@E 999,999.99")

      PROD->(dbskip())

   enddo

   qstopprn()



return

/////////////////////////////////////////////////////////////////////////////
// MODULO PRINCIPAL DE IMPRESSAO ____________________________________________

static function i_impre_xls
local nQUANT_RES  := 0  //Avariados
local nQUANT_AVAR := 0  //Avariados
local nQUANT_SHOW := 0  //Avariados
local nQUANT_TER  := 0  //Em Transicao
local nQUANT_RT   := 0  //Em Transicao
local nQUANT_TT   := 0  //Em Transicao

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   do while ! PROD->(eof()) 
      qgirabarra()

      if ! empty(cCOD_PROD)
         if right(PROD->Codigo,5) <> cCOD_PROD
            exit
         endif
      endif

      //if PROD->Fora_Linha == "S"
      //   PROD->(dbskip())
      //   loop
      //endif


      if XPAGINA == 0
         qpageprn()
         @ prow()+1,0 say chr(9)+chr(9)+cTITULO+chr(9)+"507"
         @ prow()+1,0 say "Local."+chr(9)+"Ref."+chr(9)+"Cod assoc."+Chr(9)+"Descricao"+chr(9)+"Marca"+chr(9)+"Disponivel"+chr(9)+"Expedicao"+chr(9)+"Avariados"+chr(9)+"Baixa"+chr(9)+"Qtde. Total"+chr(9)+"Preco Unitario" +chr(9) + "Status"
         @ prow()+1,0 say ""
      endif

      INVENT->(dbgotop())

      if empty(cCOD_PROD)
         if ! INVENT->(dbseek(cFILIAL+right(PROD->Codigo,5)))
            PROD->(dbskip())
            loop
         endif
      else
         INVENT->(dbseek(cFILIAL+cCOD_PROD))
         PROD->(dbsetorder(4))
         PROD->(dbseek(cCOD_PROD))
         if CONFIG->Mantra == "S"
            PROD->(dbsetorder(3)) // codigo
         else
            PROD->(dbsetorder(1)) // codigo
         endif
      endif


      // rotina que localiza todos os produtos lancados no inventario de lotes distintos
      nQUANT      := 0
      nQUANT_AVAR := 0
      nQUANT_SHOW := 0
      nQUANT_TT   := 0
      nQUANT_RES  := 0


      do while ! INVENT->(eof()) .and. INVENT->Cod_prod == right(PROD->Codigo,5)
         nQUANT      += INVENT->Quant_atu
         nQUANT_AVAR += INVENT->Quant_defe
         nQUANT_SHOW += INVENT->Quant_show

         INVENT->(dbskip())
      enddo

      nQUANT_RES := buscaReservas(right(PROD->Codigo,5))

      nQUANT_TT   := (nQUANT + nQUANT_AVAR + nQUANT_SHOW + nQUANT_RES)

      @ prow()+1,00 say PROD->Corredor+ " "+ PROD->Estante+chr(9)+left(PROD->Cod_fabr,7) +  chr(9)  + PROD->Cod_ass +chr(9)+ left(PROD->Descricao,18)+chr(9)+left(PROD->Marca,12)   +chr(9)+;
                        iif( right(PROD->Codigo,5) <> "     " , transform(nQUANT     ,"@R 9999999"),) + chr(9) +;
                        iif( right(PROD->Codigo,5) <> "     " , transform(nQUANT_RES ,"@R 9999999"),) + chr(9) +;
                        iif( right(PROD->Codigo,5) <> "     " , transform(nQUANT_AVAR,"@R 9999999"),) + chr(9) +;
                        iif( right(PROD->Codigo,5) <> "     " , transform(nQUANT_SHOW,"@R 9999999"),) + chr(9) +;
                        iif( right(PROD->Codigo,5) <> "     " , transform(nQUANT_TT  ,"@R 9999999"),) + chr(9) +;
                        transform(PROD->Preco_cons,"@E 99,999,999.99") + chr(9) + iif(PROD->Fora_linha == "S" ,"Fora De Linha","") 
						

      PROD->(dbskip())

   enddo

   qstopprn(.F.)


return

static function i_reserva
local aPED := {}
local aPEDS := {}
local lTEM := .F.
local cLOTE   := space(10)
local cFILIAL := space(4)
local nQTY    := 0
local cPROD   := space(5)
local nCONT   := 1

ITEN_FAT->(dbsetorder(2))
FAT->(dbsetorder(11))
FAT->(dbgotop())

aReservas := {}

Do while ! FAT->(eof()) .and. empty(FAT->Num_fatura)
    if FAT->es != "S"
      FAT->(dbskip())
	  loop
   endif
   
   if left(FAT->Cod_cfop,4) $ "5905-6905"
      FAT->(dbskip())
	  loop
   endif

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
		   aadd(aReservas,{cPROD,cFILIAL,cLOTE,nQTY}) 

           cPROD   := asPED[nCONT,1]
           cFILIAL := asPED[nCONT,2]
           cLOTE   := asPED[nCONT,3]
           nQTY    := 0
        endif
    enddo
	aadd(aReservas,{cPROD,cFILIAL,cLOTE,nQTY})

endif

aPED := {}
asPED := {}
return

static function buscaReservas(cPROD)
local nKey := 0

       nKey := ascan(aReservas,{|ckey| cKey[1] == cPROD})

       if nKey > 0
          return aReservas[nKey,4] 
       endif

return 0


