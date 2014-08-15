/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE ESTOQUES
// OBJETIVO...: LISTAGEM DE LANCAMENTOS TELEPAR
// ANALISTA...: LUCINEIDE VILAR POSSEBOM
// PROGRAMADOR: A MESMA
// INICIO.....: SETEMBRO DE 1998
// OBS........:
function es508

#define K_MAX_LIN 52

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG .or. lastkey()==27)}

private cTITULO                // titulo do relatorio
private dDATA_INI:=ctod("")    // define data inicial do relat¢rio
private dDATA_FIN:=ctod("")    // define data final do relat¢rio
private aEDICAO := {}          // vetor para os campos de entrada de dados
private nTOTAL := 0

fu_abre_cli1()

PROD->(Dbsetorder(4))
TELEPAR->(Dbsetorder(2)) // data emissao

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qgetx(-1,0,@dDATA_INI  ,"@D")         },"DATA_INI" })
aadd(aEDICAO,{{ || qgetx(-1,0,@dDATA_FIN  ,"@D")         },"DATA_FIN" })

do while .T.

   qlbloc(05,0,"B508A","QBLOC.GLO",1)

   XNIVEL  := 1
   XFLAG   := .T.
   nTOTAL  := 0

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

   set softseek on
   TELEPAR->(dbseek(dtos(dDATA_INI)))
   set softseek off

   // CRIA TITULO DO RELATORIO ______________________________________________

   cTITULO := "MOVIMENTACAO FISICA E FINANCEIRA DO P.S."

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

   do while ! TELEPAR->(eof()) .and. TELEPAR->Data_emiss >= dDATA_INI .and. TELEPAR->Data_emiss <= dDATA_FIN .and. qcontprn()  // condicao principal de loop

       qmensa()

       if ! qlineprn() ; exit ; endif

       if XPAGINA == 0 .or. prow() > K_MAX_LIN
          @ prow(),00 say XCOND0
          qpageprn()
          qcabecprn(cTITULO,80)
       endif

       @ prow()+1,00  say XCOND0 + "Documento..: " + TELEPAR->Docto
       @ prow()  ,54  say "Data de Emissao..: " + dtoc(TELEPAR->Data_emiss)
       @ prow()+1,00  say "Cliente....: " + TELEPAR->Cod_cli ; CLI1->(dbseek(TELEPAR->Cod_cli))
       @ prow()  ,20  say CLI1->Razao
       @ prow()+1,0   say replicate("-",80)
                      
       ITEN_TEL->(dbseek(TELEPAR->Docto))

       do while ! ITEN_TEL->(eof()) .and. ITEN_TEL->Docto_tel == TELEPAR->Docto

          @ prow()+1,0  say XCOND1 + "Data : " + dtoc(TELEPAR->Data_emiss)
          @ prow()  ,23 say "Qtde : " + transform(ITEN_TEL->Quantidade,"@R 99999")
          @ prow()  ,40 say "Unitario: " + transform(ITEN_TEL->Val_unit,"@R 99,999,999.99")
          @ prow()  ,66 say "% Desc: " + transform(ITEN_TEL->Desconto,"@R 99.99")
          nDESC := 0
          iif (ITEN_TEL->Desconto <> 0 , nDESC := ITEN_TEL->Val_unit * (ITEN_TEL->Desconto/100) , nDESC := 0 )
          @ prow()  ,82 say "Preco c/ Desc: " + transform(ITEN_TEL->Val_unit - nDESC, "@E 9,999,999.99")
          nDESC := 0
          iif (ITEN_TEL->Desconto <> 0 , nDESC := (ITEN_TEL->Val_unit * ITEN_TEL->Quantidade) * (ITEN_TEL->Desconto/100) , nDESC := 0 )
          @ prow()  ,119 say XAENFAT + "Total: " + transform((ITEN_TEL->Val_unit * ITEN_TEL->Quantidade)-nDESC,"@E 9,999,999.99") + XDENFAT
          nTOTAL += (ITEN_TEL->Val_unit * ITEN_TEL->Quantidade)-nDESC
          PROD->(dbseek(ITEN_TEL->Cod_prod))
          @ prow()+1,00 say "Produto : " + ITEN_TEL->Cod_prod + "  -  "
          @ prow()  ,25 say PROD->Descricao + XCOND0

          @ prow()+1,0 say replicate("-",80)

          ITEN_TEL->(Dbskip())

       enddo

       TELEPAR->(dbskip())

   enddo

   @ prow()+1,0 say XAENFAT + "TOTAL....." + transform(nTOTAL,"@R 999,999,999.99") + XDENFAT
   @ prow()+1,0 say replicate("-",80)
    
   qstopprn()

return
