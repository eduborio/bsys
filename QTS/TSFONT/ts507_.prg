/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE TESOURARIA
// OBJETIVO...: RELATORIO DE CADASTRO DE BANCO
// ANALISTA...: LUCINEIDE VILAR POSSEBOM
// PROGRAMADOR: LUCINEIDE VILAR POSSEBOM
// INICIO.....: JANEIRO DE 1998
// OBS........:
function ts507

#define K_MAX_LIN 52

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG .or. lastkey()==27)}

local  cCONT := 1

private cTITULO          // titulo do relatorio
private aEDICAO     := {}    // vetor para os campos de entrada de dados
private cCOD_BANCO  := space(5)

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || view_banco(-1,0,@cCOD_BANCO            ) } ,"COD_BANCO" })
aadd(aEDICAO,{{ || NIL                                       },NIL          })

do while .T.

   qlbloc(05,0,"B507A","QBLOC.GLO",1)

   XNIVEL  := 1
   XFLAG   := .T.
   cCOD_BANCO := space(5)

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

      case cCAMPO == "COD_BANCO"
           if empty(cCOD_BANCO)
              qrsay(XNIVEL+1,"Todos os Bancos.....")
           else
              BANCO->(dbsetorder(3))
              if ! BANCO->(dbseek(cCOD_BANCO:=strzero(val(cCOD_BANCO),5)))
                 qmensa("Banco n„o cadastrado !","B")
                 return
              else
                 qrsay(XNIVEL+1,left(BANCO->Descricao,30))
              endif
           endif

   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // DEFINE VARIAVEL DE COMPACTACAO ________________________________________

   // CRIA TITULO DO RELATORIO ______________________________________________

   cTITULO := "RELATORIO DE CADASTRO DE BANCO"

   qmensa("")

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impressao

   local nMAXLIN := 55

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif
   qmensa("imprimindo...")

   BANCO->(dbsetorder(2))  // descricao
   BANCO->(dbgotop())

   if ! empty(cCOD_BANCO)
      BANCO->(Dbsetorder(3))
      BANCO->(dbseek(cCOD_BANCO))
   endif

   do while ! BANCO->(eof()) .and. qcontprn()  // condicao principal de loop

       if ! qlineprn() ; exit ; endif

       if XPAGINA == 0 .or. prow() > K_MAX_LIN
          qpageprn()
          @ prow(),pcol() say XCOND0
          qcabecprn(cTITULO,80)
          @ prow()+1, 0 say replicate("-",80)
          @ prow(),pcol() say XCOND1
          @ prow()+1, 0 say "BANCO                          NUMERO AG.  CONTA   ENDERECO               CIDADE               CEP       TELEFONE       GERENTE"
          @ prow(),pcol() say XCOND0
          @ prow()+1, 0 say replicate("-",80)
       endif

       @ prow(),pcol() say XCOND1

       @ prow()+1,00  say left(BANCO->Descricao,30)
       @ prow()  ,31  say BANCO->Banco
       @ prow()  ,38  say BANCO->Agencia
       @ prow()  ,43  say BANCO->Conta
       @ prow()  ,51  say left(BANCO->End_agenc,22) ; CGM->(Dbseek(BANCO->Cod_cgm))
       @ prow()  ,74  say left(CGM->Municipio,20)
       @ prow()  ,95  say BANCO->Cep
       @ prow()  ,105 say BANCO->Telefone
       @ prow()  ,120 say left(BANCO->Gerente,18)


       BANCO->(dbskip())

       if ! empty(cCOD_BANCO)
          exit
       endif

   enddo

   @ prow(),pcol() say XCOND0
   @ prow()+2, 0 say replicate("=",80)

   qstopprn()

return
