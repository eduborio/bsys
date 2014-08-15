/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE ESTOQUES
// OBJETIVO...: LISTAGEM DE APURACAO DA CONTAGEM FISICA DOS MATERIAIS
// ANALISTA...:
// PROGRAMADOR:
// INICIO.....: JANEIRO DE 1997
// OBS........:
function es502

#define K_MAX_LIN 52

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG .or. lastkey()==27)}

private cTITULO                // titulo do relatorio
private dDATA_INI:=ctod("")    // define data inicial do relat¢rio
private cFILIAL                // define a filial do relatorio
private dDATA_FIN:=ctod("")    // define data final do relat¢rio
private aEDICAO := {}          // vetor para os campos de entrada de dados

PROD->(Dbsetorder(4))
CONTAGEM->(Dbsetorder(1))

// CRIACAO DO VETOR DE BLOCOS _______________________________________________


aadd(aEDICAO,{{ || view_filial(-1,0,@cFILIAL)   } , "FILIAL" })
aadd(aEDICAO,{{ || NIL },NIL})           // descricao da filial
aadd(aEDICAO,{{ || qgetx(-1,0,@dDATA_INI  ,"@D")         },"DATA_INI" })
aadd(aEDICAO,{{ || qgetx(-1,0,@dDATA_FIN  ,"@D")         },"DATA_FIN" })

do while .T.

   qlbloc(05,0,"B502A","QBLOC.GLO",1)

   XNIVEL  := 1
   XFLAG   := .T.
   cFILIAL := space(4)

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

      case cCAMPO == "DATA_INI"
           if empty(dDATA_INI) ; return .F. ; endif

      case cCAMPO == "DATA_FIN"
           if empty(dDATA_FIN) ; return .F. ; endif

           if dDATA_FIN < dDATA_INI
              qmensa("Data Inicial superior a data final !")
              return .F.
           endif

   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // DEFINE VARIAVEL DE COMPACTACAO ________________________________________

   // CRIA TITULO DO RELATORIO ______________________________________________

   cTITULO := "LISTAGEM DE APURACAO DA CONTAGEM FISICA DO ESTOQUE"

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

   do while ! CONTAGEM->(eof()) .and. CONTAGEM->Data >= dDATA_INI .and. CONTAGEM->Data <= dDATA_FIN .and. qcontprn()  // condicao principal de loop

       INVENT->( Dbsetorder(1))
       INVENT->(Dbgotop())

       qmensa("Aguarde... Selecionando Produtos da Filial..." )

       if ! INVENT->( Dbseek ( cFILIAL + CONTAGEM->Cod_prod ) )
          CONTAGEM->(Dbskip())
          loop
       endif

       qmensa()

       if ! qlineprn() ; exit ; endif

       if XPAGINA == 0 .or. prow() > K_MAX_LIN
          qpageprn()
          qcabecprn(cTITULO,80)
          @ prow()+1,0 say "FILIAL -> "+ INVENT->Filial + " " + iif( FILIAL->(Dbseek(INVENT->Filial)) , FILIAL->Razao , space(20))
          @ prow()+1,0 say "CODIGO    DESCRICAO                 ESTOQUE  CONT.1  CONT.2   SALDO 1   SALDO 2"
          @ prow()+1,0 say replicate("-",80)
       endif

       if PROD->(dbseek(CONTAGEM->Cod_prod))

          @ prow()+1,00  say PROD->Codigo
          @ prow()  ,10  say left(PROD->Descricao,25)
//        @ prow()  ,35  say transform(PROD->Qtn_estoq, "@e 999999.99")
          if INVENT->(dbseek(cFILIAL+right(PROD->Codigo,5)))
             @ prow()  ,35  say transform(INVENT->Quant_atu , "@e 999999.99")
             @ prow()  ,45  say transform(CONTAGEM->Contagem1, "@e 999999")
             @ prow()  ,53  say transform(CONTAGEM->Contagem2, "@e 999999")
//           @ prow()  ,61  say transform(PROD->Qtn_estoq - CONTAGEM->Contagem1, "@e 999999.99")
//           @ prow()  ,71  say transform(PROD->Qtn_estoq - CONTAGEM->Contagem2, "@e 999999.99")
             @ prow()  ,61  say transform(INVENT->Quant_atu - CONTAGEM->Contagem1, "@e 999999.99")
             @ prow()  ,71  say transform(INVENT->Quant_atu - CONTAGEM->Contagem2, "@e 999999.99")
          endif

       endif

       CONTAGEM->(dbskip())

   enddo

   qstopprn()

return
