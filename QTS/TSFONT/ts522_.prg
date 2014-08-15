/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DA TESOURARIA
// OBJETIVO...: RELATORIO EXTRATO BANCARIO DO DIA
// ANALISTA...: EDUARDO AUGUSTO BORIO
// PROGRAMADOR:
// INICIO.....: Outubto de 2006
// OBS........:
// ALTERACOES.: EDUARDO AUGUSTO BORIO
function ts522

#define K_MAX_LIN 55

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local bESCAPE  := {||(XNIVEL==1 .and. !XFLAG).or.lastkey()==27}

private cTITULO                                 // titulo do relatorio

private bFILTRO                                 // code block de filtro
private aEDICAO   := {}                         // vetor para os campos de entrada de dados
private dDATA_INI := ctod("")
private dDATA_FIM := ctod("")
private cINST    := space(5)                   // codigo do INST
private cATUAL    := space(5)                   // codigo do INST
private nTOT_ENT  := 0
private nTOT_SAI  := 0
private nSALD_ANTER := 0
private nSALD_ATUAL := 0
private cDESCRICAO  := 0
INSTITU->(Dbsetorder(1))  // codigo do INST

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || view_inst(-1,0,@cINST ,"99999")              } ,"INST" })
aadd(aEDICAO,{{ || NIL                                           } ,NIL     })

do while .T.

   qlbloc(5,0,"B522A","QBLOC.GLO",1)
   XNIVEL  := 1
   XFLAG   := .T.

   // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; dbcloseall() ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   if ( i_inicializacao() , i_impressao() , NIL )

   set softseek off

enddo

/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA _____________________________________________

static function i_critica ( cCAMPO )

   do case

      case cCAMPO == "INST"
           if empty(cINST)
              qrsay(XNIVEL+1,"Todos as Instituicoes Financeiras...")
           else
              if ! INSTITU->(dbseek(cINST))
                 qmensa("Instituicao nao cadastrada ! ","B")
                 return .F.
              endif
              qrsay(XNIVEL+1,left(INSTITU->Nome,40))
              cDESCRICAO := INSTITU->Nome
           endif

   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // DEFINE VARIAVEL DE COMPACTACAO ________________________________________

   // CRIA TITULO DO RELATORIO ______________________________________________

   cTITULO := "RELATORIO DE EXTRATO DA INSTITUICAO EM: " + dtoc(XDATA)

   qmensa("")

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impressao

   local nMAXLIN := 55
   local nCONT := 0
   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif

   qmensa("imprimindo...")

   MOV_FIN->(dbsetorder(3))
   SALD_FIN->(dbsetorder(1))


   if ! empty(cINST)
      SALD_FIN->(dbseek(dtos(XDATA)+cINST))
      nSALD_ANTER := SALD_FIN->Saldo
   else
      SALD_FIN->(Dbgotop())
   endif


   if ! empty(cINST)
      MOV_FIN->(dbseek(cINST))
   else
      MOV_FIN->(Dbgotop())
   endif

   do while ! MOV_FIN->(eof()) .and. qcontprn()  // condicao principal de loop

      if MOV_FIN->Data <> XDATA
         MOV_FIN->(Dbskip())
         loop
      endif

      if MOV_FIN->Cod_inst != cINST
         MOV_FIN->(dbskip())
         loop
      endif
       if ! qlineprn() ; exit ; endif

       if XPAGINA == 0 .or. prow() > K_MAX_LIN
          qpageprn()
          @ prow(),pcol() say XCOND1
          qcabecprn(cTITULO,136)
          @ prow()+1, 0 say "INSTITUICAO......: " +  cDESCRICAO +"SALDO ANTERIOR......: " + transform(nSALD_ANTER,"@E 9,999,999.99")
          @ prow()+2, 0 say "HISTORICO                                                       SAIDA         ENTRADA        DOCTO"
          @ prow()+1, 0 say replicate("-",136)
       endif

       cATUAL := MOV_FIN->Cod_INST

       @ prow(),pcol() say XCOND1

       @ prow()+1,00   say left(MOV_FIN->Historico,50)
       @ prow()  ,57   say transform(MOV_FIN->Saida,"@E 999,999,999.99")
       @ prow()  ,74  say transform(MOV_FIN->Entrada,"@E 999,999,999.99")
       @ prow()  ,93  say MOV_FIN->Num_docto
       if ! empty(MOV_FIN->Fornec_cod)
          for nCONT := 0 to 23
              if substr(MOV_FIN->Fornec_cod,(nCONT*5)+1,5) == "     "
                 nCONT := 0
                 exit
              endif
              FORN->(Dbseek(substr(MOV_FIN->Fornec_cod,(nCONT*5)+1,5)))
              @ prow()+1 ,42   say left(FORN->Razao,39)
              @ prow()   ,88   say transf(val(substr(MOV_FIN->Valores,(nCONT*10)+1,10))/100,"@E 999,999,999.99")
          next
          @ prow()+1,00 say ""
       endif

       nTOT_ENT += MOV_FIN->Entrada
       nTOT_SAI += MOV_FIN->Saida

       MOV_FIN->(dbskip())

       if empty(cINST) .and. MOV_FIN->Cod_INST <> cATUAL .and. ! MOV_FIN->(eof())
          @ prow()+2, 0  say "TOTAIS..........: "
          @ prow()  ,55  say transform(nTOT_SAI,"@R 9,999,999,999.99")
          @ prow()  ,72 say transform(nTOT_ENT,"@R 9,999,999,999.99")
          if SALD_FIN->(dbseek(dtos(XDATA)+cATUAL))
             nSALD_ANTER := SALD_FIN->Saldo
          endif
          @ prow()+2, 0 say "INSTITUICAO...........: " + cDESCRICAO + "SALDO ANTERIOR.......: " + transf(nSALD_ANTER,"@E 9,999,999.99")
          @ prow()+1, 0  say replicate("-",136)
          @ prow()+1, 0 say "SALDO ATUAL............: "+transf((nSALD_ANTER)+(nTOT_ENT-nTOT_SAI),"@E 9,999,999.99")
          @ prow()+1, 0  say replicate("=",136)

          nTOT_ENT := nTOT_SAI := 0
       elseif ! empty(cINST)
          if cINST <> MOV_FIN->Cod_inst
             exit
          endif
       endif

   enddo
   if nTOT_ENT == 0  .and. nTOT_SAI == 0
      qcabecprn(cTITULO,136)
      @ prow()+1, 0 say "INSTITUICAO......: " + cDESCRICAO +"SALDO ANTERIOR......: " + transform(nSALD_ANTER,"@E 9,999,999.99")
      @ prow()+1, 0  say replicate("=",136)

      @ prow()+2, 0  say "TOTAIS..........: "
      @ prow()  ,55  say transform(nTOT_SAI,"@R 9,999,999,999.99")
      @ prow()  ,72  say transform(nTOT_ENT,"@R 9,999,999,999.99")

      @ prow()+1, 0  say replicate("-",136)
      @ prow()+1, 0 say "SALDO ATUAL............: "+transf((nSALD_ANTER)+(nTOT_ENT-nTOT_SAI),"@E 9,999,999.99")
      @ prow()+1, 0  say replicate("=",136)

   endif
   if nTOT_ENT <> 0 .or. nTOT_SAI <> 0
      @ prow()+2, 0  say "TOTAIS..........: "
      @ prow()  ,55  say transform(nTOT_SAI,"@R 9,999,999,999.99")
      @ prow()  ,72  say transform(nTOT_ENT,"@R 9,999,999,999.99")

      @ prow()+1, 0  say replicate("-",136)
      @ prow()+1, 0 say "SALDO ATUAL............: "+transf((nSALD_ANTER)+(nTOT_ENT-nTOT_SAI),"@E 9,999,999.99")
      @ prow()+1, 0  say replicate("=",136)
   endif
   nSALD_ANTER := nTOT_ENT := NTOT_SAI := 0

   qstopprn()

return
