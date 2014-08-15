/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE ESTOQUES
// OBJETIVO...: LISTA DE PRECOS
// ANALISTA...:
// PROGRAMADOR: LUCINEIDE VILAR POSSEBOM
// INICIO.....: MARCO DE 1997
// OBS........:
// ALTERACOES.:
function es505

#define K_MAX_LIN 57

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||lastkey() == 27 .or. (XNIVEL==1 .and. !XFLAG)}

private cTITULO                   // titulo do relatorio
private aEDICAO := {}             // vetor para os campos de entrada de dados
private cFILIAL                   // filial para impressao

aadd(aEDICAO,{{ || view_filial(-1,0,@cFILIAL,"9999")  } , "FILIAL"})
aadd(aEDICAO,{{ || NIL },NIL})           // descricao do filial

do while .T.

   qlbloc(5,0,"B505A","QBLOC.GLO",1)
   XNIVEL := 1
   XFLAG  := .T.
   cFILIAL:= space(4)

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
      case cCAMPO == "FILIAL"
           if empty(cFILIAL)
              return .F.
           else
              if ! FILIAL->(Dbseek(cFILIAL:=strzero(val(cFILIAL),4)))
                 qmensa("Filial n„o Encontrada...","B")
                 return .F.
              else
                 qrsay(XNIVEL+1, left(FILIAL->Razao,15))
              endif
           endif

   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // CRIA TITULO DO RELATORIO ______________________________________________

   cTITULO := "LISTAGEM DE PRECOS PARA BALCAO"

   // SELECIONA ORDEM DO ARQUIVO CODIGOS_____________________________________

   INVENT->(Dbsetorder(1))
   INVENT->(Dbgotop())

   if ! empty(cFILIAL)
      if ! INVENT->(dbseek(cFILIAL))
         qmensa("N„o existem produtos nesta filial...","B")
         return .f.
      endif
   endif

   qmensa("")

   PROD->(Dbsetorder(7)) // left(codigo,5) + descricao do produto
   PROD->(Dbgotop())

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
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impre_prn

   local nTOTAL := 0

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________


   do while ! PROD->(eof()) .and. qcontprn()  // condicao principal de loop

      if ! qlineprn() ; exit ; endif

      if XPAGINA == 0 .or. prow() > K_MAX_LIN
         qpageprn()
         qcabecprn(cTITULO,80)
         @ prow()+2,0 say "CODIGO    DESCRICAO DO PRODUTO                          QUANTIDADE         VALOR"
         @ prow()+1,0 say ""
      endif

      qgirabarra()

      if ! empty(cFILIAL)
         if ! INVENT->(Dbseek(cFILIAL+right(PROD->Codigo,5)))
            PROD->(Dbskip())
            loop
         endif
      endif

      @ prow()+1 , 00 say left(PROD->Cod_fabr,8)+" - "+PROD->Cod_ass
      @ prow()   , 17 say left(PROD->Descricao,35)+PROD->Marca

      @ prow()   , 62 say transform(INVENT->Quant_atu, "@E 9,999,999.99")
      @ prow()   , 80 say transform(PROD->Preco_cons, "@E 9,999,999.99")

      PROD->(dbskip())

   enddo

   qstopprn()

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impre_xls

   local nTOTAL := 0

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________


   do while ! PROD->(eof()) .and. qcontprn()  // condicao principal de loop

      if ! qlineprn() ; exit ; endif

      if XPAGINA == 0 .or. prow() > K_MAX_LIN
         qpageprn()
         @ prow()+1,0 say chr(9)+cTITULO
         @ prow()+2,0 say "CODIGO"+chr(9)+"DESCRICAO DO PRODUTO"+chr(9)+"QUANTIDADE"+chr(9)+"VALOR"
         @ prow()+1,0 say ""
      endif

      qgirabarra()

      if ! empty(cFILIAL)
         if ! INVENT->(Dbseek(cFILIAL+right(PROD->Codigo,5)))
            PROD->(Dbskip())
            loop
         endif
      endif

      @ prow()+1 , 00 say left(PROD->Cod_fabr,8)+ " - "+PROD->Cod_ass
      @ prow()   , pcol() say chr(9)+left(PROD->Descricao,30)+PROD->Marca

      @ prow()   , pcol() say chr(9)+transform(INVENT->Quant_atu, "@E 9,999,999.99")
      @ prow()   , pcol() say chr(9)+transform(PROD->Preco_cons, "@E 9,999,999.99")

      PROD->(dbskip())

   enddo

   qstopprn()

return

