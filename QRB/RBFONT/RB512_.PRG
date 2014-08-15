/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE CONTAS A RECEBER
// OBJETIVO...: LISTAGEM DE CONTAS A RECEBER POR CLIENTES
// ANALISTA...: EDUARDO BORIO
// PROGRAMADOR: EDUARDO BORIO
// INICIO.....: MARCO DE 1997
// OBS........:
function rb512

#define K_MAX_LIN 52

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG .or. lastkey()==27)}

local  cCONT := 1

private cTITULO          // titulo do relatorio
private dDATA_INI        // define data inicial para impressao
private dDATA_FIM        // define datao final para impressao
private aEDICAO     := {}    // vetor para os campos de entrada de dados
private nTOT        := 0
private nTOT_DIA    := 0
private cCLIENTE    := space(5)
private cCLI_ATU   := space(5)
private cREPRES    := space(5)

if ! quse(XDRV_RB,"FI512",{"FI512"},"E")
   qmensa("N„o foi poss¡vel abrir arquivo temporario !! Tente novamente.")
   return
endif


// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qgetx(-1,0,@dDATA_INI                     ) } ,"DATA_INI"  })
aadd(aEDICAO,{{ || qgetx(-1,0,@dDATA_FIM                     ) } ,"DATA_FIM"  })
aadd(aEDICAO,{{ || view_repres(-1,0,@cREPRES                  ) } ,"REPRES"    })
aadd(aEDICAO,{{ || NIL                                         } , NIL        }) // nome do fornecedor


do while .T.

   qlbloc(05,0,"B512A","QBLOC.GLO",1)

   XNIVEL     := 1
   XFLAG      := .T.
   dDATA_INI  := ctod("")
   dDATA_FIN  := ctod("")
   cCLIENTE   := space(5)
   cCLI_ATU   := space(5)
   cREPRES    := space(5)

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
           dDATA_FIM := qfimmes(dDATA_INI)
           qrsay(XNIVEL+1,dDATA_FIM)

      case cCAMPO == "DATA_FIM"
           if empty(dDATA_FIM) ; return .F. ; endif
           if dDATA_INI > dDATA_FIM
              qmensa("Data Inicial n„o pode ser maior que a Data Final !","B")
              return .F.
           endif

      case cCAMPO == "REPRES"

           qrsay(XNIVEL,strzero(val(cREPRES),5))

           if empty(cREPRES)
              qrsay(XNIVEL+1, "Todos os Representantes...")
           else
              if ! REPRES->(Dbseek(cREPRES:=strzero(val(cREPRES),5)))
                 qmensa("Representante n„o encontrado!","B")
                 return .F.
              else
                 qrsay(XNIVEL+1,left(REPRES->Razao,30))
              endif
           endif

      endcase


return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // DEFINE VARIAVEL DE COMPACTACAO ________________________________________

   // CRIA TITULO DO RELATORIO ______________________________________________
   REPRES->(dbseek(cREPRES))
   cTITULO := "LISTAGEM DE CONTAS A RECEBER - " + iif(empty(cREPRES),"TODOS REPRESNTANTES",REPRES->Razao)

   RECEBER->(dbsetfilter({|| RECEBER->Data_venc >= dDATA_INI .and. RECEBER->Data_venc <= dDATA_FIM }))
   RECEBER->(dbgotop())
   qmensa("")

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

   local nMAXLIN := 55
   local dVENC   := ctod("")
   local zREPRES := space(5)
   local zCLI    := space(5)
   local nTOT_CLI := 0
   local nTOT_REP := 0
   local nTOT     := 0

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   qmensa("imprimindo...")
   
   nTOT_CLI    := 0
   nTOT_DIA    := 0
   nTOT        := 0

   FI512->(__dbzap())

   do while ! RECEBER->(eof())  // condicao principal de loop

      CLI1->(dbseek(RECEBER->cod_cli))

      if ! empty(cREPRES)
         if CLI1->Cod_repres != cREPRES
            RECEBER->(dbskip())
            loop
          endif
      endif



      if FI512->(qappend())
         replace FI512->Data_venc  with RECEBER->Data_venc
         replace FI512->Cliente    with left(RECEBER->Cliente,50)
         replace FI512->Cod_repres with CLI1->Cod_repres
         replace FI512->Receber    with RECEBER->Codigo
         replace FI512->Cod_cli    with RECEBER->Cod_cli
      endif
      RECEBER->(dbskip())
   Enddo

   FI512->(dbcommit())
   FI512->(dbgotop())

   RECEBER->(dbsetorder(1))

   zREPRES := FI512->Cod_repres
   zCLI    := FI512->Cod_CLi


   do while ! FI512->(eof())  // condicao principal de loop

      if ! qlineprn() ; exit ; endif

      @ prow(),pcol() say XCOND1

      if XPAGINA == 0 .or. prow() > K_MAX_LIN
         qpageprn()
         qcabecprn(cTITULO,123)
         @ prow()+1, 0 say "VENCIMENTO  FATURA    EMISSAO    CLIENTE                             PRAZO    VALOR     HISTORICO"
         @ prow()+1, 0 say replicate("-",123)
      endif

      RECEBER->(dbseek(FI512->Receber))


      @ prow()+1,00  say dtoc(RECEBER->Data_venc)
      @ prow()  ,12  say left(RECEBER->Fatura,9) ; CLI1->(Dbseek(RECEBER->Cod_cli))
      @ prow()  ,22  say dtoc(RECEBER->Data_Emiss)
      @ prow()  ,33  say left(FI512->Cliente,35)
      @ prow()  ,69  say strzero(RECEBER->Data_venc - RECEBER->Data_emiss , 4)
      @ prow()  ,76  say transform(RECEBER->Valor_liq, "@E 999,999.99")
      @ prow()  ,88  say left(RECEBER->Historico,35)


      nTOT_CLI += RECEBER->Valor_liq
      nTOT_REP += RECEBER->Valor_liq
      nTOT     += RECEBER->Valor_liq

      FI512->(dbskip())

      if FI512->Cod_repres == zREPRES .and. FI512->Cod_cli != zCLI
         @ prow()+1,0 say XAENFAT + "Total do Cliente.: " + transform(nTOT_CLI, "@E 99,999,999.99") + XDENFAT
         @ prow()+1,0 say ""
           nTOT_CLI := 0
           zCLI    := FI512->Cod_cli
           zREPRES := FI512->Cod_repres
       endif

      if FI512->Cod_repres != zREPRES
         REPRES->(dbseek(zREPRES))
         @ prow()+1,0 say XAENFAT + "Total do Representante.: " + left(REPRES->Razao,40)+ "  "+ transform(nTOT_REP, "@E 99,999,999.99")+ XDENFAT
         eject
         nTOT_CLI := 0
         nTOT_REP := 0
         zCLI := FI512->Cod_cli
         zREPRES := FI512->Cod_repres
       endif


   enddo

   @ prow()+1,0 say XAENFAT + "Total do Cliente.: " + transform(nTOT_CLI, "@E 99,999,999.99") + XDENFAT
   @ prow()+1,0 say ""
   nTOT_CLI := 0
   zCLI := FI512->Cod_cli


   REPRES->(dbseek(zREPRES))
   @ prow()+1,0 say XAENFAT + "Total do Representante.: " + left(REPRES->Razao,40)+ "  "+ transform(nTOT_REP, "@E 99,999,999.99")+ XDENFAT
   nTOT_CLI := 0
   nTOT_REP := 0
   zCLI := FI512->Cod_cli
   zREPRES := FI512->Cod_repres

   @ prow()+1, 0 say replicate("-",123)
   @ prow()+1,0 say XAENFAT +       "Total Geral............... " + transform(nTOT, "@E 99,999,999.99") + XDENFAT

   qstopprn()
   FI512->(dbclosearea())

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO (formato Excel)

static function i_impre_xls
   local dVENC   := ctod("")
   local zREPRES := space(5)
   local zCLI    := space(5)
   local nTOT_CLI := 0
   local nTOT_REP := 0
   local nTOT     := 0

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   qmensa("imprimindo...")
   
   nTOT_CLI    := 0
   nTOT_DIA    := 0
   nTOT        := 0

   FI512->(__dbzap())

   do while ! RECEBER->(eof())  // condicao principal de loop

      CLI1->(dbseek(RECEBER->cod_cli))

      if ! empty(cREPRES) .and. cREPRES != "00000"
         if CLI1->Cod_repres != cREPRES
            RECEBER->(dbskip())
            loop
          endif
      endif

      if FI512->(qappend())
         replace FI512->Data_venc  with RECEBER->Data_venc
         replace FI512->Cliente    with left(RECEBER->Cliente,50)
         replace FI512->Cod_repres with CLI1->Cod_repres
         replace FI512->Receber    with RECEBER->Codigo
         replace FI512->Cod_cli    with RECEBER->Cod_cli
      endif
      RECEBER->(dbskip())
   Enddo

   FI512->(dbcommit())
   FI512->(dbgotop())

   RECEBER->(dbsetorder(1))

   zREPRES := FI512->Cod_repres
   zCLI    := FI512->Cod_CLi


   do while ! FI512->(eof())  // condicao principal de loop

      if ! qlineprn() ; exit ; endif

      if XPAGINA == 0
         qpageprn()
         @ prow()+1, 0 say chr(9)+chr(9)+chr(9)+cTITULO
         @ prow()+1, 0 say "VENCIMENTO"+CHR(9)+"FATURA"+CHR(9)+"EMISSAO"+CHR(9)+"CLIENTE"+CHR(9)+"PRAZO"+CHR(9)+"VALOR"+Chr(9)+"HISTORICO"
         @ prow()+1, 0 say ""
      endif

      RECEBER->(dbseek(FI512->Receber))


      @ prow()+1,00  say dtoc(RECEBER->Data_venc)+chr(9)
      @ prow()  ,pcol()  say left(RECEBER->Fatura,9)+chr(9) ; CLI1->(Dbseek(RECEBER->Cod_cli))
      @ prow()  ,pcol()  say dtoc(RECEBER->Data_Emiss)+chr(9)
      @ prow()  ,pcol()  say left(FI512->Cliente,35)+chr(9)
      @ prow()  ,pcol()  say strzero(RECEBER->Data_venc - RECEBER->Data_emiss , 4)+chr(9)
      @ prow()  ,pcol()  say transform(RECEBER->Valor_liq, "@E 999,999.99")+chr(9)
      @ prow()  ,pcol()  say left(RECEBER->Historico,35)


      nTOT_CLI += RECEBER->Valor_liq
      nTOT_REP += RECEBER->Valor_liq
      nTOT     += RECEBER->Valor_liq

      FI512->(dbskip())

      if FI512->Cod_repres == zREPRES .and. FI512->Cod_cli != zCLI
         @ prow()+1,0 say chr(9)+chr(9)+chr(9)+"Total do Cliente.: " +chr(9)+chr(9)+ transform(nTOT_CLI, "@E 99,999,999.99") + XDENFAT
         @ prow()+1,0 say ""
           nTOT_CLI := 0
           zCLI    := FI512->Cod_cli
           zREPRES := FI512->Cod_repres
       endif

      if FI512->Cod_repres != zREPRES
         REPRES->(dbseek(zREPRES))
         @ prow()+2,0 say chr(9)+chr(9)+chr(9)+"Total do Representante.: " + left(REPRES->Razao,40)+ CHR(9)+chr(9)+ transform(nTOT_REP, "@E 99,999,999.99")
         @ prow()+1,0 say ""
         nTOT_CLI := 0
         nTOT_REP := 0
         zCLI := FI512->Cod_cli
         zREPRES := FI512->Cod_repres
       endif


   enddo

      if FI512->Cod_repres == zREPRES .and. FI512->Cod_cli != zCLI
         @ prow()+1,0 say chr(9)+chr(9)+chr(9)+"Total do Cliente.: " +chr(9)+chr(9)+ transform(nTOT_CLI, "@E 99,999,999.99")
         @ prow()+1,0 say ""
         nTOT_CLI := 0
         zCLI := FI512->Cod_cli
       endif

      if FI512->Cod_repres != zREPRES
         REPRES->(dbseek(zREPRES))
         @ prow()+2,0 say chr(9)+chr(9)+chr(9)+"Total do Representante.: " + left(REPRES->Razao,40)+ CHR(9)+chr(9)+ transform(nTOT_REP, "@E 99,999,999.99")
         @ prow()+1,0 say ""
         nTOT_CLI := 0
         nTOT_REP := 0
         zCLI := FI512->Cod_cli
         zREPRES := FI512->Cod_repres
       endif


   @ prow()+1, 0 say ""
   @ prow()+1,0 say chr(9)+chr(9)+chr(9) + "Total Geral............... " + chr(9)+chr(9)+transform(nTOT, "@E 99,999,999.99")

   qstopprn(.F.)
   FI512->(dbclosearea())



return

