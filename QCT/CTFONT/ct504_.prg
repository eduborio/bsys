
/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE CONTABILIDADE
// OBJETIVO...: RELATORIO DE LANCAMENTOS POR FILIAL
// ANALISTA...:
// PROGRAMADOR: LUCINEIDE VILAR POSSEBOM
// INICIO.....: FEVEREIRO DE 1997
// OBS........:
// ALTERACOES.:
function ct504

#define K_MAX_LIN 52

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG) .or. lastkey() = 27}

private cFILIAL := space(10)

private cTITULO                // titulo do relatorio
private aEDICAO := {}          // vetor para os campos de entrada de dados
private cCOD_FIL:= space(4)
private nTOT    := 0
private dDATA_INI  := ctod("")
private dDATA_FIM  := ctod("")

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || view_filial(-1,0,@cFILIAL,"@!") } , "FILIAL"   })
aadd(aEDICAO,{{ || NIL                                                     } ,NIL        })
aadd(aEDICAO,{{||qgetx(-1,0,@dDATA_INI      ,"@D") } , "DATA_INI" })
aadd(aEDICAO,{{||qgetx(-1,0,@dDATA_FIM      ,"@D") } , "DATA_FIM" })

do while .T.

   qlbloc(5,0,"B504A","QBLOC.GLO")
   XNIVEL   := 1
   XFLAG    := .T.

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
      case cCAMPO == "FILIAL"

         if ! empty(cFILIAL)
            FILIAL->(dbseek(cFILIAL))
           qrsay(XNIVEL+1,left(FILIAL->Razao,20))
         else
           qrsay(XNIVEL+1," Todas as Filiais ******")
         endif

      case cCAMPO == "DATA_INI"

         if  empty(dDATA_INI) ; return .F. ; endif

      case cCAMPO == "DATA_FIM"

         if  empty(dDATA_FIM) ; return .F. ; endif

         if dDATA_FIM < dDATA_INI
            qmensa("Data Final n„o Pode ser Inferior a Inicial")
            return .F.
         endif

   endcase
return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // CONSTROI VARIAVEL "cTITULO" ___________________________________________

   cTITULO := "RELACAO DE LANCAMENTOS POR FILIAL"

   // SELECIONA ORDEM DO ARQUIVO LANC _______________________________________

   LANC->(dbsetorder(8))
   LANC->(dbgotop())

   if ! empty(cFILIAL)
      set softseek on
      LANC->(dbseek(dtos(dDATA_INI)+cFILIAL))
   else
      set softseek on
      LANC->(dbseek(dDATA_INI))
   endif

   qmensa()

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impressao

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif

   qmensa("imprimindo...")

   cCOD_FIL := LANC->Filial

   do while ! LANC->(eof()) .and. LANC->Data_lanc >= dDATA_INI .and. LANC->Data_lanc <= dDATA_FIM .and. qcontprn()     // condicao principal de loop

      if ! empty(cFILIAL) .and. LANC->Filial <> left(cFILIAL,4)
         LANC->(Dbskip())
         loop
      endif

      if ! qlineprn() ; return ; endif

      if XPAGINA == 0 .or. prow() > K_MAX_LIN
         qpageprn()
         qcabecprn(cTITULO,80)
         @ prow()+1,0 say replicate("-",80)
         @ prow()+1,00 say "FILIAL -->"+iif(FILIAL->(dbseek(LANC->Filial)), FILIAL->Razao , space(20) )
         @ prow()+2,0 say "Data     Conta Credito Conta Debito Centro de Custo                Valor  "
         @ prow()+1,0 say replicate("-",80)
      endif

      CCUSTO->(Dbseek(LANC->Centro))

      @ prow()+1 ,00 say dtoc(LANC->Data_lanc)
      @ prow()   ,09 say transform(LANC->Cont_cr,"@R 99999-9")
      @ prow()   ,24 say transform(LANC->Cont_db,"@R 99999-9")
      @ prow()   ,36 say left(CCUSTO->Descricao,29)
      @ prow()   ,66 say transform(LANC->Valor,"@E 999,999,999.99")

      nTOT += 1

      LANC->(dbskip())

      if empty(cFILIAL)
         if  ! LANC->(eof()) .and. cCOD_FIL <> LANC->Filial
              filial_dif()
         endif
      endif

   enddo

   if nTOT <> 0
      @ prow()+2,00 say "Total: "+transform(nTOT, "@E 999")+" Lancamento(s)."
      nTOT := 0
   endif

   qstopprn()
   qmensa()

return

static function filial_dif                                // quando muda o codigo da filial
  @ prow()+2,00 say "Total: "+transform(nTOT, "@E 999")+" Lancamento(s)."
  nTOT := 0
  eject
  @ prow()+2,00 say "FILIAL -->"+iif( FILIAL->(dbseek(LANC->Filial)), FILIAL->Razao, space(20) )
  @ prow()+1,00 say replicate("-",80)
  @ prow()+2,00 say "Data      Conta Credito  Conta Debito  Centro de Custo                Valor  "
  @ prow()+1,00 say replicate("-",80)
  cCOD_FIL := LANC->Filial
return
