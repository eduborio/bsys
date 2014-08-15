/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE COMPRAS
// OBJETIVO...: LISTAGEM DE FORNECEDORES
// ANALISTA...:
// PROGRAMADOR:
// INICIO.....: JANEIRO DE 1997
// OBS........:

function cp504

#define K_MAX_LIN 52

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG .or. lastkey()==27)}

private cTITULO          // titulo do relatorio
private cFORN_INI        // define fornecedor inicial para impressao
private cFORN_FIN        // define fornecedor final para impressao
private aEDICAO := {}    // vetor para os campos de entrada de dados
private cCOND            // condicao principal de loop

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || view_forn(-1,0,@cFORN_INI)   } , "FORN_INI" })
aadd(aEDICAO,{{ || NIL },NIL})           // descricao do fornecedor
aadd(aEDICAO,{{ || view_forn(-1,0,@cFORN_FIN)   } , "FORN_FIN" })
aadd(aEDICAO,{{ || NIL },NIL})           // descricao do fornecedor

do while .T.

   qlbloc(05,0,"B504A","QBLOC.GLO",1)

   XNIVEL  := 1
   XFLAG   := .T.
   cFORN_INI  := space(5)
   cFORN_FIN  := space(5)

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
      case cCAMPO == "FORN_INI"
           if empty(cFORN_INI)
              qrsay(XNIVEL+1,"*** Todos os Fornecedores ***")
           else
              if ! FORN->(dbseek(strzero(val(cFORN_INI),5)))
                 qmensa("Fornecedor n„o encontrado !","B")
                 return .F.
              endif
              qrsay(XNIVEL+1,left(FORN->(Razao),30))
           endif

      case cCAMPO == "FORN_FIN"
           if empty(cFORN_FIN)
              qrsay(XNIVEL+1,"*** Todos os Fornecedores ***")
           else
              if ! FORN->(dbseek(strzero(val(cFORN_INI),5)))
                 qmensa("Fornecedor n„o encontrado !","B")
                 return .F.
              endif
              qrsay(XNIVEL+1,left(FORN->Razao,30))
           endif
           if val(cFORN_FIN) < val(cFORN_INI)
              qmensa("O Fornecedor final n„o pode ser inferior ao Inicial !")
              return .F.
           endif

   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // DEFINE VARIAVEL DE COMPACTACAO ________________________________________

   // CRIA TITULO DO RELATORIO ______________________________________________

   cTITULO := "LISTAGEM GERAL DE FORNECEDOR"

   if ! empty(cFORN_INI) .and. ! empty(cFORN_FIN)
       FORN->(dbseek(cFORN_INI))
       cCOND := "! FORN->(eof()) .and. FORN->Codigo >= cFORN_INI .and. FORN->Codigo <= cFORN_FIN"
   else
       cCOND :=  "! FORN->(eof())"
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

       if ! qlineprn() ; exit ; endif

       if XPAGINA == 0 .or. prow() > K_MAX_LIN
          qpageprn()
          qcabecprn(cTITULO,135)
          @ prow()+1 ,00 say "CODIGO  RAZAO SOCIAL                                      ENDERECO                        MUNICIPIO            CEP       TELEFONE"
          @ prow()+1,0 say replicate("-",135)
       endif

       @ prow()+1,000  say FORN->Codigo
       @ prow()  ,008  say left(FORN->Razao,48)
       @ prow()  ,058  say left(FORN->End_cob,30)
       @ prow()  ,090  say iif( CGM->(dbseek(FORN->Cgm_cob)) , left(CGM->Municipio,20) , space(20))
       @ prow()  ,111  say left(FORN->CEP_COB,5)+"-"+right(FORN->CEP_COB,3)
       @ prow()  ,121  say FORN->Fone1

       FORN->(dbskip())

   enddo

   @ prow()+1,0 say replicate("-",135)

   qstopprn()

return
