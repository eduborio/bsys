/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE ESTOQUES
// OBJETIVO...: LISTAGEM DE CONTAGEM FISICA DOS MATERIAIS
// ANALISTA...:
// PROGRAMADOR:
// INICIO.....: JANEIRO DE 1997
// OBS........:
function es501

#define K_MAX_LIN 52

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG .or. lastkey()==27)}

private cTITULO          // titulo do relatorio
private cPROD_INI        // define produto inicial para impressao
private cPROD_FIN        // define produto final para impressao
private cFILIAL          // define produto final para impressao
private aEDICAO := {}    // vetor para os campos de entrada de dados
private cCOND            // condicao principal de loop

PROD->(Dbsetorder(4))

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || view_filial(-1,0,@cFILIAL)   } , "FILIAL" })
aadd(aEDICAO,{{ || NIL },NIL})           // descricao da filial
aadd(aEDICAO,{{ || view_prod(-1,0,@cPROD_INI)   } , "PROD_INI" })
aadd(aEDICAO,{{ || NIL },NIL})           // descricao do produto inicial
aadd(aEDICAO,{{ || view_prod(-1,0,@cPROD_FIN)   } , "PROD_FIN" })
aadd(aEDICAO,{{ || NIL },NIL})           // descricao do produto final

do while .T.

   qlbloc(05,0,"B501A","QBLOC.GLO",1)

   XNIVEL  := 1
   XFLAG   := .T.
   cPROD_INI  := space(5)
   cPROD_FIN  := space(5)
   cFILIAL    := space(4)

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
      case cCAMPO == "FILIAL"
           if empty(cFILIAL) ; return .F. ; endif

           if ! FILIAL->(dbseek(cFILIAL:=strzero(val(cFILIAL),4)))
              qmensa("Filial n„o encontrado !","B")
              return .F.
           endif

           qrsay(XNIVEL+1,left(FILIAL->Razao,23))

      case cCAMPO == "PROD_INI"
           if empty(cPROD_INI)
              qrsay(XNIVEL+1,"*** Todos os Produtos ***")
           else
              cPROD_INI:=strzero(val(cPROD_INI),5)
              if ! PROD->(dbseek(cPROD_INI))
                 qmensa("Produto n„o encontrado !","B")
                 return .F.
              endif
              qrsay(XNIVEL+1,left(PROD->(Descricao),23))
           endif

      case cCAMPO == "PROD_FIN"
           if empty(cPROD_FIN)
              qrsay(XNIVEL+1,"*** Todos os Produtos ***")
           else
              cPROD_FIN:=strzero(val(cPROD_FIN),5)
              if ! PROD->(dbseek(cPROD_FIN))
                 qmensa("Produto n„o encontrado !","B")
                 return .F.
              endif
              qrsay(XNIVEL+1,left(PROD->Descricao,23))
           endif
           if val(cPROD_FIN) < val(cPROD_INI)
              qmensa("O Produto final n„o pode ser inferior ao Inicial !")
              return .F.
           endif

   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // DEFINE VARIAVEL DE COMPACTACAO ________________________________________

   // CRIA TITULO DO RELATORIO ______________________________________________

   cTITULO := "LISTAGEM PARA CONTAGEM FISICA DOS MATERIAIS"

   if ! empty(cPROD_INI) .and. ! empty(cPROD_FIN)
       PROD->(dbseek(cPROD_INI))
       cCOND := "! PROD->(eof()) .and. right(PROD->Codigo,5) >= cPROD_INI .and. right(PROD->Codigo,5) <= cPROD_FIN"
   else
       cCOND :=  "! PROD->(eof())"
   endif

   qmensa("")

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impressao

   local nMAXLIN := 55

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif
   qmensa("imprimindo...")
   
   @ prow(),pcol() say XCOND1

   do while &cCOND .and. qcontprn()  // condicao principal de loop

       INVENT->( Dbsetorder(1))
       INVENT->(Dbgotop())

       qmensa("Aguarde... Selecionando Produtos da Filial..." )

       if ! INVENT->( Dbseek( cFILIAL + right(PROD->Codigo,5) ) )
          PROD->(Dbskip())
          loop
       endif

       qmensa()

       if ! qlineprn() ; exit ; endif

       if XPAGINA == 0 .or. prow() > K_MAX_LIN
          qpageprn()
          qcabecprn(cTITULO,80)
          @ prow()+1,0 say "FILIAL -> "+ INVENT->Filial + " " + iif( FILIAL->(Dbseek(INVENT->Filial)) , FILIAL->Razao , space(20))
          @ prow()+1,0 say "CODIGO    DESCRICAO                         LOCALIZACAO   CONTAGEM 1  CONTAGEM 2 "
          @ prow()+1,0 say replicate("-",80)
       endif

       @ prow()+1,00  say PROD->Codigo
       @ prow()  ,10  say left(PROD->Descricao,33)
       @ prow()  ,45  say PROD->Corredor+" "+PROD->Estante+" "+PROD->Prateleira
       @ prow()  ,59  say "_________"
       @ prow()  ,71  say "_________"

       PROD->(dbskip())

   enddo

   qstopprn()

return
