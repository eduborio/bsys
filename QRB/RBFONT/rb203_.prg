/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE CONTAS A RECEBER/PAGAR
// OBJETIVO...: INCLUSAO DE CONTAS A RECEBER
// ANALISTA...: EDUARDO BORIO
// PROGRAMADOR: EDUARDO BORIO
// INICIO.....: NOVEMBRO DE 1996
// OBS........:
// ALTERACOES.:
function rb203

#include "inkey.ch"
#include "setcurs.ch"

fu_abre_cli1()
fu_abre_conta()
fu_abre_prov()

CCUSTO->(Dbsetorder(4))
BANCO->(dbsetorder(3))

private lCONF1
private cDESC
public nVAL_LIQ

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

private dDATA_VENC := ctod("")

// VIEW INICIAL _____________________________________________________________
RECEBER->(dbsetfilter({|| RECEBER->Setor == "00001"},'RECEBER->Setor == "00001"'))
RECEBER->(qview({{"Data_venc/Vcto"            ,2},;
                 {"Cod_cli/Codigo"            ,5},;
                 {"left(RECEBER->Cliente,22)/Cliente",8},;
                 {"f203b()/Valor Tit."       ,0},;
                 {"f203c()/Valor Liq."       ,0},;
                 {"Fatura/Documento"          ,11}},"P",;
                 {NIL,"f203a",NIL,NIL},;
                 NIL,"ESC/ALT-P/ALT-O/<I>nc/<A>lt/<E>xc/<C>on/<D>esdobra/<P>arcial"))

//////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAGEM DO CLIENTE __________________________________________

//////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAGEM DE VALOR COM PICTURE ________________________________

function f203b
return(transform(RECEBER->Valor,"@E 9999999.99"))

//////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAGEM DE VALOR COM PICTURE ________________________________

function f203c
return(transform(RECEBER->Valor_liq,"@E 9999999.99"))

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function f203a
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO $ XUSRA
      qlbloc(05,02,"B203A","QBLOC.GLO",1)
      qmensa(qabrev(cOPCAO,"IA",{"Inclus„o... <ESC - Cancela>","Altera‡„o... <ESC - Cancela>"}))
      i_edicao()
   endif

   if cOPCAO = "D" ; i_duplica() ; endif
   if cOPCAO = "P" ; i_parcial() ; endif
   if cOPCAO = "T" ; i_transf() ; endif

   setcursor(nCURSOR)
return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA ____________________________________

static function i_edicao
   local aEDICAO := {}
   local bESCAPE := {||XNIVEL==1.and.!XFLAG}

   fDATA_LANC := XDATASYS

   // MONTA DADOS NA TELA ___________________________________________________

   if ! cOPCAO $ "I"
      XNIVEL := 1
      qrsay ( XNIVEL++ , RECEBER->Codigo       )
      qrsay ( XNIVEL++ , RECEBER->Cod_cli      ) ; CLI1->(dbseek(RECEBER->Cod_cli))
      qrsay ( XNIVEL++ , left(CLI1->Razao,40))

      qrsay ( XNIVEL++ , RECEBER->Data_emiss   )

      qrsay ( XNIVEL++ , left(RECEBER->Historico,60))
      qrsay ( XNIVEL++ , RECEBER->Data_venc    )
      qrsay ( XNIVEL++ , transform(RECEBER->Valor,"@E 9,999,999.99"     ))
      qrsay ( XNIVEL++ , RECEBER->Fatura       )
      qrsay ( XNIVEL++ , RECEBER->Duplicata    )

   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || NIL }                                         ,NIL         })  // codigo nao pode ser editado
   aadd(aEDICAO,{{ || view_cli(-1,0,@fCOD_CLI                 ) } ,"COD_CLI"     })
   aadd(aEDICAO,{{ || NIL                                         } ,NIL         })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDATA_EMISS                   ) } ,"DATA_EMISS"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@fHISTORICO,"@!@S60"           ) } ,"HISTORICO" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDATA_VENC                    ) } ,"DATA_VENC" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fVALOR    ,"@E 9,999,999.99"  ) } ,"VALOR"     })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fFATURA,"@!"                  ) } ,"FATURA"    })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDUPLICATA,"@!"               ) } ,"DUPLICATA"})
   aadd(aEDICAO,{{ || lCONF1 := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})


   // INICIALIZACAO DA EDICAO _______________________________________________

   RECEBER->(qpublicfields())
   iif(cOPCAO=="I",RECEBER->(qinitfields()),RECEBER->(qcopyfields()))

   XNIVEL := 2
   XFLAG  := .T.
   lCONF1 := .F.

   if cOPCAO == "I"
      fCODIGO := strzero(CONFIG->Cod_rec + 1,7)
   endif

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; RECEBER->(qreleasefields()) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   if lCONF1
   // GRAVACAO ______________________________________________________________
   //if cOPCAO == "I"
      fVALOR_LIQ := fVALOR
      fSETOR     := "00001"
      fCENTRO    := "0015"
      fFILIAL    := "0001"
      fPREVISAO  := "N"
      fESPECIE   := "67"
      fSERIE     := "01"
      fDATA_LANC := date()
      fDATA_CONT := fDATA_EMISS
      fTIPO_SUB  := "010073"
      fTIPO_DOC  := "04"
      fSITUACAO  := "01"
   //endif

   if RECEBER->(iif(cOPCAO=="I",qappend(),qrlock()))
      RECEBER->(qreplacefields())
      replace RECEBER->Cliente with fCLIENTE
      RECEBER->(qunlock())
      if RECEBER->Contabil == .F. .and. RECEBER->Previsao == "N"
         i_contabil()
      endif
   else
      iif(cOPCAO=="I",qm1(),qm2())
   endif

   if CONFIG->(qrlock())
      replace CONFIG->Cod_rec with val(fCODIGO)
   endif
   else
      //teste
   endif

return

/////////////////////////////////////////////////////////////////////////////
// CRITICAS NA DESCIDA ______________________________________________________

static function i_critica ( cCAMPO )
   iif ( cCAMPO == NIL , cCAMPO := "" , NIL )
   do case
      case cCAMPO == "CODIGO" .and. cOPCAO == "I"
           fCODIGO := strzero(val(fCODIGO),7)
           qrsay(XNIVEL,fCODIGO)
           if RECEBER->(dbseek(fCODIGO))
              qmensa("Tipo de Documento j  cadastrado !","B")
              return .F.
           endif

      case cCAMPO == "COD_CLI"
           qrsay(XNIVEL,fCOD_CLI:=strzero(val(fCOD_CLI),5))
           if ! CLI1->(dbseek(fCOD_CLI))
              qmensa("Cliente n„o Cadastrado !","B")
              return .F.
           else
              qrsay(XNIVEL+1,left(CLI1->Razao,40))
              if empty(CLI1->Conta_cont)
                 qmensa("Aten‡„o !! Conta Cont bil n„o Informada!","B")
              endif
           endif
           fCLIENTE := CLI1->Razao

      case cCAMPO == "DATA_EMISS"
           if empty(fDATA_EMISS) ; return .F. ; endif
           fDATA_CONT := fDATA_EMISS

      case cCAMPO == "VALOR"
           if empty(fVALOR) ; return .F. ; endif


      case cCAMPO == "FATURA"
           if empty(fFATURA) .and. TIPOCONT->Nota_fisc == "1"
              qmensa("Campo obrigat¢rio...","B")
              return .F.
           endif

   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXCLUIR CONTAS A RECEBER _______________________________________

static function i_exclusao

   if qconf("Confirma exclus„o desta Conta … Receber ?")

      if SH_CONTA->(dbseek(RECEBER->Cod_cli + RECEBER->Fatura + RECEBER->Serie))
         if SH_CONTA->(qrlock())
            SH_CONTA->(dbdelete())
            SH_CONTA->(qunlock())
         endif
      endif

      if RECEBER->(qrlock())
         RECEBER->(dbdelete())
         RECEBER->(qunlock())
      else
         qm3()
      endif

   endif
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA DESDOBRAMENTO DO LANCAMENTO DE CONTAS A RECEBER ________________

static function i_desdobra

   local lCONF
   local aEDICAO := {}
   local bESCAPE := {||empty(dDATA_VENC).or.(XNIVEL==1.and.!XFLAG).or.;
                         (XNIVEL==1.and.!XFLAG)}

   private dDATA_VENC := ctod("")
   private nVALOR     := 0
   private nVAL_DES   := 0
   private lPRI_LANC  := .T.
   private nVAL_INI   := 0   // variavel para controle do valor dos desdobramentos

   nVAL_INI := RECEBER->Valor

   qlbloc(11,02,"B201B","QBLOC.GLO",1)

   do while .T.

      qsay ( 12,17 , RECEBER->Codigo       ) ; CLI1->(Dbseek(RECEBER->Cod_cli))
      qsay ( 13,17 , left(CLI1->Razao,40))
      qsay ( 15,22 , transform(RECEBER->Valor, "@E 9,999,999.99"))

      aadd(aEDICAO,{{ || qgetx(-1,0,@dDATA_VENC, "@D"              ) } ,"DATA_VENC" })
      aadd(aEDICAO,{{ || qgetx(-1,0,@nVALOR, "@E 9,999,999.99"     ) } ,"VALOR"     })

      aadd(aEDICAO,{{ || lCONF := qconf("Confirma Lan‡amento ?"    ) } ,NIL         })

      XNIVEL := 1
      XFLAG  := .T.

      do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
         eval ( aEDICAO [XNIVEL,1] )
         if eval ( bESCAPE ) ; return ; endif
         if ! i_crit_1( aEDICAO[XNIVEL,2] ) ; loop ; endif
         if ( XFLAG , XNIVEL++ , XNIVEL-- )
      enddo

      // GRAVACAO ______________________________________________________________

      if ! lCONF ; return ; endif

      if lPRI_LANC

         if RECEBER->(qrlock())
            replace RECEBER->Data_venc    with dDATA_VENC
            replace RECEBER->Valor        with nVALOR
         else
            iif(cOPCAO=="I",qm1(),qm2())
         endif

         RECEBER->(qunlock())

         lPRI_LANC := .F.

      else

         RECEBER->(qpublicfields())
         RECEBER->(qcopyfields())

         if CONFIG->(qrlock()) .and. RECEBER->(qflock()) .and. RECEBER->(qappend())

            replace CONFIG->Cod_rec with CONFIG->Cod_rec + 1

            fCODIGO    := strzero(CONFIG->Cod_rec,7)
            fDATA_VENC := dDATA_VENC
            fVALOR     := nVALOR

            RECEBER->(qreplacefields())

            qmensa("C¢digo Gerado: "+fCODIGO,"B")

         endif

      endif

      qsay ( 15,50 , transform(nVAL_DES, "@E 9,999,999.99"))

      if nVAL_DES = nVAL_INI
         exit
      endif

      dDATA_VENC := ctod("")
      nVALOR     := 0
      aEDICAO    := {}

   enddo

return
/////////////////////////////////////////////////////////////////////////////
// CRITICAS NA DESCIDA ______________________________________________________

static function i_crit_1 ( cCAMPO )

   do case

      case cCAMPO == "DATA_VENC"

           if dDATA_VENC < RECEBER->Data_venc
              qmensa("Data do Vencimento deve ser Superior !","B")
              return .F.
           endif

      case cCAMPO == "VALOR"

           if empty(nVALOR) ; return .F. ; endif

           nVAL_DES := nVAL_DES + nVALOR

           if nVAL_DES > nVAL_INI
              qmensa("Valor do desdobramento superou o valor do pagamento !", "B")
              nVAL_DES := nVAL_DES - nVALOR
              return .F.
           endif

   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA DESDOBRAMENTO DO LANCAMENTO DE CONTAS A RECEBER ________________

static function i_parcial

   local lCONF
   local aEDICAO := {}
   local bESCAPE := {||empty(dDATA_VENC).or.(XNIVEL==1.and.!XFLAG).or.;
                         (XNIVEL==1.and.!XFLAG)}

   private dDATA_VENC := ctod("")
   private nVALOR     := 0
   private nVAL_DES   := 0
   private lPRI_LANC  := .T.
   private nVAL_INI   := 0   // variavel para controle do valor dos desdobramentos

   nVAL_INI := RECEBER->Valor

   qlbloc(11,02,"B201E","QBLOC.GLO",1)

  // do while .T.

      qsay ( 12,17 , RECEBER->Codigo       ) ; CLI1->(Dbseek(RECEBER->Cod_cli))
      qsay ( 13,17 , left(CLI1->Razao,40))

      aadd(aEDICAO,{{ || qgetx(-1,0,@dDATA_VENC, "@D"              ) } ,"DATA_VENC" })
      aadd(aEDICAO,{{ || qgetx(-1,0,@nVALOR, "@E 9,999,999.99"     ) } ,"VALOR"     })

      aadd(aEDICAO,{{ || lCONF := qconf("Confirma Lan‡amento ?"    ) } ,NIL         })

      XNIVEL := 1
      XFLAG  := .T.

      do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
         eval ( aEDICAO [XNIVEL,1] )
         if eval ( bESCAPE ) ; return ; endif
         if ! i_crit_2( aEDICAO[XNIVEL,2] ) ; loop ; endif
         if ( XFLAG , XNIVEL++ , XNIVEL-- )
      enddo

      // GRAVACAO ______________________________________________________________

      if ! lCONF ; return ; endif


      if RECEBER->(qrlock())
         replace RECEBER->Valor_liq    with (RECEBER->Valor - nVALOR)
         replace RECEBER->Valor        with (RECEBER->Valor - nVALOR)
      else
         iif(cOPCAO=="I",qm1(),qm2())
      endif

      RECEBER->(qunlock())


      RECEBER->(qpublicfields())
      RECEBER->(qcopyfields())

      if CONFIG->(qrlock()) .and. RECEBER->(qflock()) .and. RECEBER->(qappend())

         replace CONFIG->Cod_rec with CONFIG->Cod_rec + 1

         fCODIGO    := strzero(CONFIG->Cod_rec,7)
         fDATA_VENC := dDATA_VENC
         fVALOR     := nVALOR
         fVALOR_LIQ := nVALOR
         RECEBER->(qreplacefields())

         qmensa("C¢digo Gerado: "+fCODIGO,"B")

      endif

      dDATA_VENC := ctod("")
      nVALOR     := 0
      aEDICAO    := {}


return
/////////////////////////////////////////////////////////////////////////////
// CRITICAS NA DESCIDA ______________________________________________________

static function i_crit_2 ( cCAMPO )

   do case

      case cCAMPO == "DATA_VENC"

           if dDATA_VENC < RECEBER->Data_venc
              qmensa("Data do Vencimento deve ser Superior !","B")
              return .F.
           endif

      case cCAMPO == "VALOR"

           if empty(nVALOR) ; return .F. ; endif

           nVAL_DES := nVAL_DES + nVALOR

           if nVAL_DES > nVAL_INI
              qmensa("Valor Parcial superou o valor do pagamento !", "B")
              nVAL_DES := nVAL_DES - nVALOR
              return .F.
           endif

   endcase

return .T.

static function i_duplica

   local lCONF
   local aEDICAO := {}
   local bESCAPE := {||empty(dDATA_VENC).or.(XNIVEL==1.and.!XFLAG).or.;
                         (XNIVEL==1.and.!XFLAG)}

   private dDATA_VENC := ctod("")
   private nVALOR     := 0
   private nVAL_DES   := 0
   private cHIST      := space(30)
   private cFATURA    := space(8)
   private lPRI_LANC  := .T.
   private nVAL_INI   := 0   // variavel para controle do valor dos desdobramentos

   nVAL_INI := RECEBER->Valor

   qlbloc(11,02,"B201E","QBLOC.GLO",1)

  // do while .T.

      qsay ( 12,17 , RECEBER->Codigo       ) ; CLI1->(Dbseek(RECEBER->Cod_cli))
      qsay ( 13,17 , left(CLI1->Razao,40))

      aadd(aEDICAO,{{ || qgetx(-1,0,@dDATA_VENC, "@D"              ) } ,"DATA_VENC" })
      aadd(aEDICAO,{{ || qgetx(-1,0,@nVALOR, "@E 9,999,999.99"     ) } ,"VALOR"     })
      aadd(aEDICAO,{{ || qgetx(-1,0,@cHIST, "@!"              ) } ,"HISTORICO"     })
      aadd(aEDICAO,{{ || qgetx(-1,0,@cFATURA, "@!"                 ) } ,"FATURA"     })

      aadd(aEDICAO,{{ || lCONF := qconf("Confirma Lan‡amento ?"    ) } ,NIL         })

      XNIVEL := 1
      XFLAG  := .T.

      do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
         eval ( aEDICAO [XNIVEL,1] )
         if eval ( bESCAPE ) ; return ; endif
         if ! i_crit_3( aEDICAO[XNIVEL,2] ) ; loop ; endif
         if ( XFLAG , XNIVEL++ , XNIVEL-- )
      enddo

      // GRAVACAO ______________________________________________________________

      if ! lCONF ; return ; endif


      //if RECEBER->(qrlock())
      //   replace RECEBER->Valor_liq    with (RECEBER->Valor - nVALOR)
      //   replace RECEBER->Valor        with (RECEBER->Valor - nVALOR)
      //else
      //   iif(cOPCAO=="I",qm1(),qm2())
      //endif

      RECEBER->(qunlock())


      RECEBER->(qpublicfields())
      RECEBER->(qcopyfields())

      if CONFIG->(qrlock()) .and. RECEBER->(qflock()) .and. RECEBER->(qappend())

         replace CONFIG->Cod_rec with CONFIG->Cod_rec + 1

         fCODIGO    := strzero(CONFIG->Cod_rec,7)
         fDATA_VENC := dDATA_VENC
         fVALOR     := nVALOR
         fVALOR_LIQ := nVALOR
         fHISTORICO := cHIST
         fFATURA    := cFATURA
         fDUPLICATA := cFATURA
         RECEBER->(qreplacefields())

         qmensa("C¢digo Gerado: "+fCODIGO,"B")

      endif

      dDATA_VENC := ctod("")
      nVALOR     := 0
      aEDICAO    := {}


return
/////////////////////////////////////////////////////////////////////////////
// CRITICAS NA DESCIDA ______________________________________________________

static function i_crit_3 ( cCAMPO )

   do case

      //case cCAMPO == "DATA_VENC"

      //     if dDATA_VENC < RECEBER->Data_venc
      //        qmensa("Data do Vencimento deve ser Superior !","B")
      //        return .F.
      //     endif

      case cCAMPO == "VALOR"

           if empty(nVALOR) ; return .F. ; endif

           nVAL_DES := nVAL_DES + nVALOR

          // if nVAL_DES > nVAL_INI
          //    qmensa("Valor Parcial superou o valor do pagamento !", "B")
          //    nVAL_DES := nVAL_DES - nVALOR
          //    return .F.
          // endif

   endcase

return .T.


///////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INCLUIR O LCTO CONTABIL PARA LIQUIDACAO ____________________
static function i_contabil

  if SH_CONTA->(qappend())

     replace SH_CONTA->Codigo     with RECEBER->Cod_cli
     replace SH_CONTA->Num_nota   with RECEBER->Fatura
     replace SH_CONTA->Data_lanc  with RECEBER->Data_lanc
     replace SH_CONTA->Serie      with RECEBER->Serie
     CLI1->(dbsetorder(1))
     CLI1->(dbseek(RECEBER->Cod_cli))
     replace SH_CONTA->Ca         with CLI1->Razao
     replace SH_CONTA->Cgc        with CLI1->Cgccpf
     replace SH_CONTA->Dp         with RECEBER->Fatura
     ESPECIE->(dbseek(RECEBER->Especie))
     replace SH_CONTA->Ep         with ESPECIE->Descricao
     replace SH_CONTA->Fa         with RECEBER->Fatura
     replace SH_CONTA->Nf         with RECEBER->Fatura
     SERIE->(dbseek(RECEBER->Serie))
     replace SH_CONTA->Se         with SERIE->Descricao

  endif

  if TIPOCONT->(dbseek(RECEBER->Tipo_sub)) .and. TIPOCONT->Regime_ope == "2"
     if RECEBER->(qrlock())
        replace RECEBER->Contabil with .T.
     endif
     if SH_PROCT->(qappend())

        replace SH_PROCT->Data_lanc   with  RECEBER->Data_lanc

        if TIPOCONT->Regime_ope == "2" // Regime de competencia

           nHISTORICO := TIPOCONT->Hist_l_pr

           if TIPOCONT->Cont_pr_dv == "1"
              replace SH_PROCT->Cont_db with TIPOCONT->Ct_ct_p_dv
           else
              CLI1->(dbseek(RECEBER->Cod_cli))
              replace SH_PROCT->Cont_db with CLI1->Conta_cont
           endif

           if TIPOCONT->Cont_pr_cr == "1"
              replace SH_PROCT->Cont_cr with TIPOCONT->Ct_ct_p_cr
           else
              CLI1->(dbseek(RECEBER->Cod_cli))
              replace SH_PROCT->Cont_cr with CLI1->Conta_cont
           endif

        else // regime de caixa

           nHISTORICO := TIPOCONT->Hist_l_pr

           if TIPOCONT->Conta_liq == "1"
              replace SH_PROCT->Cont_db with TIPOCONT->Ct_ct_liq
           else
              CLI1->(dbseek(RECEBER->Cod_cli))
              replace SH_PROCT->Cont_db with CLI1->Conta_cont
           endif

           if TIPOCONT->Conta_l2 == "1"
              replace SH_PROCT->Cont_cr with TIPOCONT->Ct_ct_l2
           else
              CLI1->(dbseek(RECEBER->Cod_cli))
              replace SH_PROCT->Cont_cr with CLI1->Conta_cont
           endif

        endif

        replace SH_PROCT->Filial     with  RECEBER->Filial

        replace SH_PROCT->Valor      with  RECEBER->Valor
        replace SH_PROCT->Num_doc    with  RECEBER->Fatura
        replace SH_PROCT->Num_lote   with  "RB" + XUSRNUM + strzero(CONFIG->Lote_cont,5) // monta numero do lote
        replace SH_PROCT->Cod_hist   with  nHISTORICO

        monta_hist("RECEBER",nHISTORICO)

     endif

     if CONFIG->(qrlock())
        replace CONFIG->Num_lote with (CONFIG->Num_lote + 1)
        CONFIG->(qunlock())
     endif

  endif

return

////////////////////////////////////////////////////////////////////////////////
// FUNCAO UTILIZADA PARA A SELECAO DOS MNEUMONICOS DO HISTORICO ________________
static function monta_hist(cARQ,cHIST)

HIST->(dbseek(cHIST))
nHIST := HIST->Descricao

for nCONT := 1 to len(nHIST)
    if ( nPOS := at("[",nHIST) )  <> 0
       nPOS += 2  // para ignorar os simbolos [@
       CLI1->(dbgotop())
       do case
          case substr(nHIST,nPOS,2) == "CA"
               CLI1->(Dbseek((cARQ)->Cod_cli))
               replace SH_PROCT->Ca with left(CLI1->Razao,40)
          case substr(nHIST,nPOS,3) == "CGC"
               CLI1->(Dbseek((cARQ)->Cod_cli))
               replace SH_PROCT->Cgc with CLI1->Cgccpf
          case substr(nHIST,nPOS,2) == "DA"
               replace SH_PROCT->Da with XDATSYS
          case substr(nHIST,nPOS,2) == "DP" .or. substr(nHIST,nPOS,2) == "FA" .or. substr(nHIST,nPOS,2) == "NF"
               replace SH_PROCT->Dp with (cARQ)->Fatura
               replace SH_PROCT->Fa with (cARQ)->Fatura
               replace SH_PROCT->Nf with (cARQ)->Fatura
          case substr(nHIST,nPOS,2) == "EP"
               ESPECIE->(Dbseek((cARQ)->Especie))
               replace SH_PROCT->Ep with left(ESPECIE->Descricao,3)
          case substr(nHIST,nPOS,2) == "SE"
               SERIE->(Dbseek((cARQ)->Serie))
               replace SH_PROCT->Se with left(SERIE->Descricao,3)
       endcase

       nHIST := substr( nHIST , nPOS+4 , len(nHIST) ) // retira da variavel nHIST, os mneumonicos que ja foram verificados

    else
      exit
    endif

next

return

static function i_transf
   local lCONF

   lCONF := qconf("Confirma Transferencia p/ Arquivo Morto ?")

   if lCONF

      if ! RECEBER->(qflock()) .and. ! RECEB2->(qflock())
         qmensa("N„o foi Poss¡vel Transferir !","B")
         return
      endif
      RECEBER->(qpublicfields())
      RECEBER->(qcopyfields())
      RECEB2->(qappend())
      fDATA_PAGTO := date()
      RECEB2->(qreplacefields())

      RECEBER->(dbdelete())
      RECEBER->(qunlock())
      RECEB2->(qunlock())

   endif
return


