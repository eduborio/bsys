/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE ESTOQUES
// OBJETIVO...: INTERFACE P/ CONTABILIDADE
// ANALISTA...: LUCINEIDE VILAR POSSEBOM
// PROGRAMADOR: A MESMA
// INICIO.....: ABRIL DE 1998
// OBS........:
// ALTERACOES.:

function es601
#define K_MAX_LIN 52

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := { || ( XNIVEL==1 .and. !XFLAG ) .or. ( XNIVEL==1 .and. lastkey()==27 ) }

private dINI          // periodo inicial
private dFIM          // periodo final
private nVAL    := 0
private aEDICAO := {} // vetor para os campos de entrada de dados
private lCONF

fu_abre_prov()

if ! quse("","QCONFIG")  // abre o arquivo QCONFIG para ler a sigla do sistema
   qmensa("N„o foi possivel abrir QCONFIG.DBF... Tente Novamente...","B")
   return
endif

qmensa("<Pressione ESC para Cancelar>")

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qgetx(-1,0,@dINI)}          , "INI"    })
aadd(aEDICAO,{{ || qgetx(-1,0,@dFIM)}          , "FIM"    })
aadd(aEDICAO,{{ || lCONF := qconf("Confirma interface com a Contabilidade ?") },NIL})

qlbloc(5,0,"B601A","QBLOC.GLO")
XNIVEL := 1
XFLAG  := .T.
dINI   := ctod("")
dFIM   := ctod("")

// SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
   eval ( aEDICAO [XNIVEL,1] )
   if eval ( bESCAPE ) ; dbcloseall() ; return ; endif
   if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
   iif ( XFLAG , XNIVEL++ , XNIVEL-- )
enddo

if ! lCONF ; return ; endif

i_interface()

return

/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA _____________________________________________

static function i_critica ( cCAMPO )
   do case
      case cCAMPO == "INI"
           if empty(dINI) ; return .F. ; endif
      case cCAMPO == "FIM"
           if dFIM < dINI ; return .F. ; endif
   endcase
return .T.

/////////////////////////////////////////////////////////////////////////////
// LOOP DE INTERFACE ________________________________________________________

static function i_interface

   PEDIDO->(dbsetorder(6)) // dtos(data_ped)

   PEDIDO->(dbgotop())

   set softseek on

   PEDIDO->(dbseek(dINI))

   // LOOP PRINCIPAL NOS PEDIDOS A INTERFACEAR ______________________________

   nHISTORICO := space(3)

   do while ! PEDIDO->(eof()) .and. PEDIDO->Data_ped >= dINI .and. PEDIDO->Data_ped <= dFIM

      qgirabarra()

      if PEDIDO->Lote_conta .and. ! PEDIDO->Interface .and. ! PEDIDO->Fiscal .and. ! PEDIDO->Contabil
         PEDIDO->(Dbskip())
         loop
      endif

      qmensa("Aguarde... Interfaceando Entradas com a Contabilidade...")

      TIPOCONT->(Dbseek(PEDIDO->Tipo))

      if ! quse(XDRV_ES,"CONFIG")
         qmensa("N„o foi possivel abrir CONFIG.DBF... ","B")
         QCONFIG->(Dbclosearea())
         return
      endif

      if SH_PROCT->(qappend())

         replace SH_PROCT->Data_lanc   with  PEDIDO->Data_ped

         if TIPOCONT->Regime_ope == "2" // Regime de competencia

            nHISTORICO := TIPOCONT->Hist_l_pr

            if TIPOCONT->Cont_pr_dv == "1"
               replace SH_PROCT->Cont_db with TIPOCONT->Ct_ct_p_dv
            else
               FORN->(dbseek(PEDIDO->Cod_forn))
               replace SH_PROCT->Cont_db with FORN->Conta_cont
            endif

            if TIPOCONT->Cont_pr_cr == "1"
               replace SH_PROCT->Cont_cr with TIPOCONT->Ct_ct_p_cr
            else
               FORN->(dbseek(PEDIDO->Cod_forn))
               replace SH_PROCT->Cont_cr with FORN->Conta_cont
            endif

         else // regime de caixa

            nHISTORICO := TIPOCONT->Hist_l_pr

            if TIPOCONT->Conta_liq == "1"
               replace SH_PROCT->Cont_db with TIPOCONT->Ct_ct_liq
            else
               FORN->(dbseek(PEDIDO->Cod_forn))
               replace SH_PROCT->Cont_db with FORN->Conta_cont
            endif

            if TIPOCONT->Conta_l2 == "1"
               replace SH_PROCT->Cont_cr with TIPOCONT->Ct_ct_l2
            else
               FORN->(dbseek(PEDIDO->Cod_forn))
               replace SH_PROCT->Cont_cr with FORN->Conta_cont
            endif

         endif

         replace SH_PROCT->Filial     with  PEDIDO->Filial

         LANC->(dbseek(PEDIDO->Codigo))

         nTOTAL := 0

         do while ! LANC->(eof()) .and. LANC->Cod_ped == PEDIDO->Codigo
            nTOTAL += (LANC->Preco * LANC->Quant)
            LANC->(dbskip())
         enddo

         replace SH_PROCT->Valor      with  nTOTAL
         replace SH_PROCT->Num_doc    with  PEDIDO->Numero_nf
         replace SH_PROCT->Num_lote   with  QCONFIG->Sigla + XUSRNUM + strzero(CONFIG->Num_lote,5) // monta numero do lote
         CONFIG->(dbclosearea())
         replace SH_PROCT->Cod_hist   with nHISTORICO

         monta_hist("PEDIDO",nHISTORICO)

      endif

      if PEDIDO->(qrlock())
         replace PEDIDO->Lote_conta with .T.
         PEDIDO->(qunlock())
      endif

      PEDIDO->(Dbskip())

   enddo

   Dbcloseall()

return

////////////////////////////////////////////////////////////////////////////////
// FUNCAO UTILIZADA PARA A SELECAO DOS MNEUMONICOS DO HISTORICO ________________
function monta_hist(cARQ,cHIST)

HIST->(dbseek(cHIST))
nHIST := HIST->Descricao

for nCONT := 1 to len(nHIST)
    if ( nPOS := at("[",nHIST) )  <> 0
       nPOS += 2  // para ignorar os simbolos [@
       FORN->(dbgotop())
       do case
          case substr(nHIST,nPOS,2) == "CA"
               FORN->(Dbseek((cARQ)->Cod_forn))
               replace SH_PROCT->Ca with left(FORN->Razao,40)
          case substr(nHIST,nPOS,3) == "CGC"
               FORN->(Dbseek((cARQ)->Cod_forn))
               replace SH_PROCT->Cgc with FORN->Cgccpf
          case substr(nHIST,nPOS,2) == "DA"
               replace SH_PROCT->Da with XDATSYS
          case substr(nHIST,nPOS,2) == "DP" .or. substr(nHIST,nPOS,2) == "FA" .or. substr(nHIST,nPOS,2) == "NF"
               replace SH_PROCT->Dp with (cARQ)->Numero_nf
               replace SH_PROCT->Fa with (cARQ)->Numero_nf
               replace SH_PROCT->Nf with (cARQ)->Numero_nf
          case substr(nHIST,nPOS,2) == "EP"
               ESPECIE->(Dbseek((cARQ)->Especie))
               replace SH_PROCT->Ep with ESPECIE->Descricao
          case substr(nHIST,nPOS,2) == "SE"
               SERIE->(Dbseek((cARQ)->Serie))
               replace SH_PROCT->Se with SERIE->Descricao
          case substr(nHIST,nPOS,2) == "PC"
               replace SH_PROCT->Pc with transform(PEDIDO->Codigo,"@R 99999/99")
       endcase

       nHIST := substr( nHIST , nPOS+4 , len(nHIST) ) // retira da variavel nHIST, os mneumonicos que ja foram verificados

    else
      exit
    endif

next
