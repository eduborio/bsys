/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE COMPRAS
// OBJETIVO...: RELATORIO DE FORNECEDORES POR FILIAL
// ANALISTA...:
// PROGRAMADOR: LUCINEIDE VILAR POSSEBOM
// INICIO.....: JANEIRO DE 1997
// OBS........:
// ALTERACOES.:
function cp505

#define K_MAX_LIN 55

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local bESCAPE  := {||(XNIVEL==1 .and. !XFLAG).or.lastkey()==27}

private sBLOC1 := qlbloc("B505B","QBLOC.GLO") // ordem de impressao

private cTITULO                               // titulo do relatorio

private aEDICAO := {}                         // vetor para os campos de entrada de dados
private cFILIAL
private cULT_FIL
private cCOND

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || view_FILIAL(-1,0,@cFILIAL                    )} ,"FILIAL"   })
aadd(aEDICAO,{{ || NIL },NIL }) // descricao da filial

do while .T.

   qlbloc(5,0,"B505A","QBLOC.GLO",1)
   XNIVEL  := 1
   XFLAG   := .T.
   cFILIAL := space(11)
   cULT_FIL := space(4)

   // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; dbcloseall() ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   if ( i_inicializacao() , i_impressao() , NIL )

enddo

/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA _____________________________________________

static function i_critica ( cCAMPO )

   do case
      case cCAMPO == "FILIAL"
           if empty(cFILIAL)
              qrsay(XNIVEL+1,"*** Todas as Filiais ***")
           else
              qrsay(XNIVEL,cFILIAL:=strzero(val(cFILIAL),4))
              if ! FILIAL->(dbseek(cFILIAL))
                 qmensa("Filial n„o encontrado !","B")
                 return .F.
              endif
              qrsay(XNIVEL+1,left(FILIAL->RAZAO,28))
           endif

   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // CRIA TITULO DO RELATORIO ______________________________________________

   cTITULO := "RELATORIO DE FORNECEDORES POR FILIAL"
   
   qmensa("")

   if ! empty(cFILIAL)
      cFILIAL:=strzero(val(cFILIAL),4)
      FORN->(Dbsetorder(4))
      if FORN->(Dbseek(cFILIAL))
         cCOND := "! FORN->(eof()) .and. FORN->Filial == cFILIAL"
      else
         qmensa("N„o Existe esta Filial !","B")
         return .F.
      endif
   else
     FORN->(Dbsetorder(4))
     FORN->(Dbgotop())
     cCOND := "! FORN->(eof())"
   endif

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impressao

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif
   qmensa("imprimindo...")

   @ prow(),pcol() say XCOND1

     do while &cCOND .and. qcontprn()

      if ! qlineprn() ; exit ; endif
      qgirabarra()

      if XPAGINA == 0 .or. prow() > K_MAX_LIN
         qpageprn()
         qcabecprn(cTITULO,135)
         @ prow()+1 ,00 say "FILIAL->"+iif( FILIAL->(Dbseek(left(FORN->Filial,4))), FILIAL->Razao, space(65))
         @ prow()+1,0 say replicate("-",135)
         @ prow()+1 ,00 say "CODIGO  RAZAO SOCIAL                                      ENDERECO                        MUNICIPIO            CEP       TELEFONE"
         @ prow()+1,0 say replicate("-",135)
         if empty(cFILIAL) ; cULT_FIL := left(FORN->Filial,4) ; endif
      endif

      @ prow()+1,000  say FORN->Codigo
      @ prow()  ,008  say left(FORN->Razao,48)
      @ prow()  ,058  say left(FORN->End_cob,30)
      @ prow()  ,090  say iif( CGM->(dbseek(FORN->Cgm_cob)) , left(CGM->Municipio,20) , space(20))
      @ prow()  ,111  say right(FORN->CEP_COB,5)+"-"+left(FORN->CEP_COB,3)
      @ prow()  ,121  say FORN->Fone1

      FORN->(dbskip())

      if ! FORN->(eof()) .and. empty(cFILIAL) .and. FORN->Filial <> cULT_FIL
         @ prow()+1 ,00 say "FILIAL->"+iif( FILIAL->(Dbseek(left(FORN->Filial,4))), FILIAL->Razao, space(65))
         @ prow()+1,0 say replicate("-",135)
         @ prow()+1 ,00 say "CODIGO  RAZAO SOCIAL                                      ENDERECO                        MUNICIPIO            CEP       TELEFONE"
         @ prow()+1,0 say replicate("-",135)
         cULT_FIL := left(FORN->Filial,4)
      endif

   enddo

   @ prow()+1,0 say replicate("-",135)

   qstopprn()

return
