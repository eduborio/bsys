/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE CONTAS A PAGAR
// OBJETIVO...: INCLUSAO DE CONTAS A PAGAR
// ANALISTA...:
// PROGRAMADOR: EDUARDO AUGUSTO BORIO
// INICIO.....: NOVEMBRO 2000
// OBS........:
// ALTERACOES.:

function pg202

#include "inkey.ch"
#include "setcurs.ch"

private lCONF1
private lCONF2
private cDESC
private cEmpresa
public nVAL_LIQ


private sBLOC1  := qlbloc("B201D","QBLOC.GLO")

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

private dDATA_VENC := ctod("")

// VIEW INICIAL _____________________________________________________________

GRUPO_PG->(qview({{"Data_emiss/Emissao"       ,2},;
               {"Cod_forn/Codigo"            ,3},;
               {"left(Fornec,25)/Fornecedor",4},;
               {"f202_val3()/Valor Tit."        ,0},;
               {"f202_val4()/Valor Liq."        ,0},;
               {"Duplicata/Duplicata"        ,0}},"P",;
               {NIL,"f202a",NIL,NIL},;
               NIL,"ESC/ALT-P/ALT-O/<I>nc/<A>lt/<E>xc/<C>on/<D>uplica/<P>arcial"))

//////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAGEM DO FORNECEDOR ______________________________________

function f_202b
   FORN->(dbseek(GRUPO_PG->Cod_forn))
return left(FORN->Razao,22)

//////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAGEM DE VALOR COM PICTURE ________________________________

function f202_val3
return(transform(GRUPO_PG->Valor,"@E 9999999.99"))

//////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAGEM DE VALOR COM PICTURE ________________________________

function f202_val4
return(transform(GRUPO_PG->Valor_liq,"@E 9999999.99"))

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function f202a
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO $ XUSRA
      qlbloc(05,00,"B202A","QBLOC.GLO",1)
      qmensa(qabrev(cOPCAO,"IA",{"Inclus„o...","Altera‡„o..."}))
      i_edicao()
   endif

   setcursor(nCURSOR)
return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA ____________________________________

static function i_edicao
   local cCodigo := ""
   local nCONT := 0
   local aEDICAO := {}
   local bESCAPE := {||empty(fEnviar).or.(XNIVEL==1.and.!XFLAG).or.;
                         (XNIVEL==2.and.cOPCAO=="A".and.!XFLAG).or. lastkey() == 27}

   fDATA_LANC := XDATASYS

   // MONTA DADOS NA TELA ___________________________________________________

   aEdicao := {}

   if cOPCAO <> "I"
      XNIVEL := 1

     // if cEMPRESA == "01"
         sayMayn()
     // else
     //    sayAll()
     // endif

   endif

   if cOPCAO == "C"
     i_atu_lanc()
//     keyboard chr(27)
     return
   endif


   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

      //if cEMPRESA == "01"
         getMayn(aEDICAO)
      //else
      //   getAll(aEDICAO)
      //endif



   // INICIALIZACAO DA EDICAO _______________________________________________

   GRUPO_PG->(qpublicfields())
   iif(cOPCAO=="I",GRUPO_PG->(qinitfields()),GRUPO_PG->(qcopyfields()))

   XNIVEL := 2
   XFLAG  := .T.
   lCONF1 := .F.
   lCONF2 := .F.
   fEnviar := "S"
   if cOPCAO == "I"
      fDATA_LANC := date()
   endif

   if cOPCAO == "I"
      fCODIGO := strzero(CONFIG->Cod_gppag + 1,7)
   endif

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; GRUPO_PG->(qreleasefields()) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF2 ; return ; endif

   fVALOR_LIQ := fVALOR

   if GRUPO_PG->(iif(cOPCAO=="I",qappend(),qrlock()))
      GRUPO_PG->(qreplacefields())
      replace GRUPO_PG->Fornec with fFORNEC
      GRUPO_PG->(qunlock())
      if GRUPO_PG->Contabil == .F. .and. GRUPO_PG->Enviar == "S"
         i_contabil()
      endif
   else
      iif(cOPCAO=="I",qm1(),qm2())
   endif

   if CONFIG->(qrlock())
      replace CONFIG->Cod_gppag with val(fCODIGO)
      CONFIG->(qunlock())
      CONFIG->(dbcommit())
   endif

   if cOpcao == "I"

      for nCONT := 1 to val(GRUPO_PG->Vezes)
          if PAGAR->(qappend())

             if CONFIG->(qrlock())
                replace CONFIG->Cod_pag with CONFIG->cod_pag + 1
                CONFIG->(qunlock())
                CONFIG->(dbcommit())
                cCodigo := strzero(CONFIG->Cod_pag,7)
             endif

             replace PAGAR->Codigo      with cCodigo
             replace PAGAR->Grupo_pg    with GRUPO_PG->Codigo + strzero(nCONT,2)
             replace PAGAR->Data_emiss  with GRUPO_PG->Data_emiss
             replace PAGAR->Data_lanc   with GRUPO_PG->Data_lanc
             replace PAGAR->Data_venc   with GRUPO_PG->Data_emiss + ( nCONT * val(GRUPO_PG->Intervalo))
             replace PAGAR->Cod_forn    with GRUPO_PG->Cod_forn
             replace PAGAR->Fornec      with GRUPO_PG->Fornec
             replace PAGAR->Filial      with "0001"
             replace PAGAR->Tipo_sub    with GRUPO_PG->Tipo_sub
             replace PAGAR->Historico   with GRUPO_PG->Historico
             replace PAGAR->Valor       with round(GRUPO_PG->Valor/val(GRUPO_PG->Intervalo),2)
             replace PAGAR->Valor_liq   with round(GRUPO_PG->Valor/val(GRUPO_PG->Intervalo),2)
             replace PAGAR->Fatura      with rtrim(GRUPO_PG->Fatura)+"/"+strzero(nCONT,2)
             replace PAGAR->Contabil    with .T.
             replace PAGAR->Cod_plan    with GRUPO_PG->Cod_plan
             replace PAGAR->Enviar      with "N"

          endif
          PAGAR->(dbcommit())

      next



   endif

   i_proc_venctos()
   //keyboard chr(27)

return

/////////////////////////////////////////////////////////////////////////////
// CRITICAS NA DESCIDA ______________________________________________________

static function i_critica ( cCAMPO )
   iif ( cCAMPO == NIL , cCAMPO := "" , NIL )
   do case

      case cCAMPO == "CODIGO" .and. cOPCAO == "I"
           fCODIGO := strzero(val(fCODIGO),7)
           qrsay(XNIVEL,fCODIGO)
           if GRUPO_PG->(dbseek(fCODIGO))
              qmensa("Tipo de Documento j  cadastrado !","B")
              return .F.
           endif

      case cCAMPO == "COD_FORN"
           qrsay(XNIVEL,fCOD_FORN:=strzero(val(fCOD_FORN),5))
           if ! FORN->(dbseek(fCOD_FORN))
              qmensa("Fornecedor n„o Cadastrado !","B")
              return .F.
           else
              qrsay(XNIVEL+1,left(FORN->Razao,40))
              if empty(FORN->Conta_cont)
                 qmensa("Aten‡„o !! Conta Cont bil n„o Informada!","B")
              endif
           endif
           fFORNEC := FORN->Razao

      case cCAMPO == "ENVIAR"
           if empty(fEnviar) ; return .F. ; endif
           qrsay(XNIVEL,qabrev(fEnviar,"SN",{"Sim","N„o"}))


      case cCAMPO == "DATA_LANC"
           qrsay(XNIVEL,fDATA_LANC := date())
           if empty(fDATA_LANC) ; return .F. ; endif

      case cCAMPO == "COD_PLAN"
           if ! empty(fCOD_PLAN)
              qrsay(XNIVEL,fCOD_PLAN := strzero(val(fCOD_PLAN),5))
              PLAN_FIN->(dbsetorder(3))
              if ! PLAN_FIN->(dbseek(fCOD_PLAN))
                 qmensa("Conta Financeira n„o encontrada !","B")
                 return .F.
              endif
              qrsay(XNIVEL+1,left(PLAN_FIN->Descricao,25))
           else
              qmensa("Campo Obrigatorio!!","BL")
              return .F.
           endif


      case cCAMPO == "DATA_EMISS"
           if fDATA_EMISS == Ctod("00/00/00")
              qmensa("Data de emiss„o deve ser Informada !","B")
              qmensa("")
              Return .F.
          else
              Return .T.
          endif


      case cCAMPO == "TIPO_SUB"
           if empty(fTIPO_SUB) ; return .F. ; endif
           qrsay(XNIVEL,fTIPO_SUB:=strzero(val(fTIPO_SUB),6))
           if ! TIPOCONT->(dbseek(fTIPO_SUB))
              qmensa("Tipo e Sub-Tipo n„o encontrado !","B")
              return .F.
           endif
           if ! TIPOCONT->Motivo $ "23"
              qmensa("Este Tipo Cont bil n„o ‚ de Pagamento...","B")
              return .F.
           endif
           qrsay(XNIVEL+1,left(TIPOCONT->Descricao,46))


      case cCAMPO == "FATURA"
           if empty(fFATURA)
              qmensa("Campo obrigat¢rio...","B")
              return .F.
           endif

      case cCAMPO == "VEZES"
           if empty(fVEZES)
              qmensa("Campo obrigat¢rio...","B")
              return .F.
           endif

      case cCAMPO == "INTERVALO"
           if empty(fINTERVALO)
              qmensa("Campo obrigat¢rio...","B")
              return .F.
           endif



      case cCAMPO == "VALOR"
           if fVALOR == 0
              qmensa("Valor do lancamento deve ser Informado...","B")
              qmensa("")
              Return .F.
           else
              Return .T.
           endif

      case cCAMPO == "DATA_VENC"

           if fDATA_VENC < fDATA_LANC
              qmensa("Data do Vencimento Inferior a do Lan‡amento !","B")
              return .F.
           endif

   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXCLUIR CONTAS A PAGAR _______________________________________

static function i_exclusao
   if qconf("Confirma exclus„o desta Conta … Pagar ?")

      if GRUPO_PG->(qrlock())
         GRUPO_PG->(dbdelete())
         GRUPO_PG->(qunlock())
      else
         qm3()
      endif
   endif
return


/////////////////////////////////////////////////////////////////////////////
// CRITICAS NA DESCIDA ______________________________________________________

static function i_crit_2 ( cCAMPO )

   do case

      case cCAMPO == "DATA_VENC"

           if dDATA_VENC < GRUPO_PG->Data_venc
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


///////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INCLUIR O LCTO CONTABIL PARA LIQUIDACAO ____________________
static function i_contabil

  if TIPOCONT->(dbseek(GRUPO_PG->Tipo_sub)) .and. TIPOCONT->Regime_ope == "2"
     if GRUPO_PG->(qrlock())
        replace GRUPO_PG->Contabil with .T.
     endif

     fu_abre_prov()

     if SH_PROCT->(qappend())

        replace SH_PROCT->Data_lanc   with  GRUPO_PG->Data_emiss

        if TIPOCONT->Regime_ope == "2" // Regime de competencia

           nHISTORICO := TIPOCONT->Hist_l_pr

           if TIPOCONT->Cont_pr_dv == "1"
              replace SH_PROCT->Cont_db with TIPOCONT->Ct_ct_p_dv
           else
              FORN->(dbseek(GRUPO_PG->Cod_forn))
              replace SH_PROCT->Cont_db with FORN->Conta_cont
           endif

           if TIPOCONT->Cont_pr_cr == "1"
              replace SH_PROCT->Cont_cr with TIPOCONT->Ct_ct_p_cr
           else
              FORN->(dbseek(GRUPO_PG->Cod_forn))
              replace SH_PROCT->Cont_cr with FORN->Conta_cont
           endif

        else // regime de caixa

           nHISTORICO := TIPOCONT->Hist_l_pr

           if TIPOCONT->Conta_liq == "1"
              replace SH_PROCT->Cont_db with TIPOCONT->Ct_ct_liq
           else
              FORN->(dbseek(GRUPO_PG->Cod_forn))
              replace SH_PROCT->Cont_db with FORN->Conta_cont
           endif

           if TIPOCONT->Conta_l2 == "1"
              replace SH_PROCT->Cont_cr with TIPOCONT->Ct_ct_l2
           else
              FORN->(dbseek(GRUPO_PG->Cod_forn))
              replace SH_PROCT->Cont_cr with FORN->Conta_cont
           endif

        endif

        replace SH_PROCT->Filial     with  "0001"

        replace SH_PROCT->Valor      with  GRUPO_PG->Valor
        replace SH_PROCT->Num_doc    with  GRUPO_PG->Fatura
        replace SH_PROCT->Num_lote   with  "PG" + XUSRNUM + strzero(CONFIG->Num_lote,5) // monta numero do lote
        replace SH_PROCT->Cod_hist   with nHISTORICO

        monta_histpg("GRUPO_PG",nHISTORICO)


        if CONFIG->(qrlock())
           replace CONFIG->Num_lote with (CONFIG->Num_lote + 1)
           CONFIG->(qunlock())
        endif

     endif
     Sh_PROCT->(dbclosearea())

     select GRUPO_PG

  endif

return

////////////////////////////////////////////////////////////////////////////////
// FUNCAO UTILIZADA PARA A SELECAO DOS MNEUMONICOS DO HISTORICO ________________
static function monta_histpg(cARQ,cHIST)

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

static function sayMayn

    qrsay ( XNIVEL++ , GRUPO_PG->Codigo       )
    qrsay ( XNIVEL++ , qabrev(GRUPO_PG->Enviar,"SN", {"Sim","Nao"}))
    qrsay ( XNIVEL++ , GRUPO_PG->Data_lanc    )
   // qrsay ( XNIVEL++ , qabrev(GRUPO_PG->Previsao,"SN", {"Sim","N„o"}))
    qrsay ( XNIVEL++ , GRUPO_PG->Cod_forn     ) ; FORN->(dbseek(GRUPO_PG->Cod_forn))
    qrsay ( XNIVEL++ , left(FORN->Razao,40))

    PLAN_FIN->(dbsetorder(3))
    qrsay ( XNIVEL++ , GRUPO_PG->Cod_plan    ) ; PLAN_FIN->(dbseek(GRUPO_PG->Cod_plan))
    qrsay ( XNIVEL++ , left(PLAN_FIN->Descricao,40))

    qrsay ( XNIVEL++ , GRUPO_PG->Tipo_sub     ) ; TIPOCONT->(dbseek(GRUPO_PG->Tipo_sub) )
    qrsay ( XNIVEL++ , left(TIPOCONT->Descricao,46))


    qrsay ( XNIVEL++ , GRUPO_PG->Data_emiss   )

   // qrsay ( XNIVEL++ , GRUPO_PG->Especie      ) ; ESPECIE->(dbseek(GRUPO_PG->Especie))
   // qrsay ( XNIVEL++ , left(ESPECIE->Descricao,13))
   // qrsay ( XNIVEL++ , GRUPO_PG->Serie        ) ; SERIE->(dbseek(GRUPO_PG->Serie))
   // qrsay ( XNIVEL++ , left(SERIE->Descricao,11))

    qrsay ( XNIVEL++ , left(GRUPO_PG->Historico,60))
//    qrsay ( XNIVEL++ , GRUPO_PG->Data_venc    )
    qrsay ( XNIVEL++ , transform(GRUPO_PG->Valor,"@E 9,999,999.99"     ))
    qrsay ( XNIVEL++ , GRUPO_PG->Fatura       )
    qrsay ( XNIVEL++ , GRUPO_PG->Vezes        )
    qrsay ( XNIVEL++ , GRUPO_PG->Intervalo    )
   //qrsay ( XNIVEL++ , GRUPO_PG->Duplicata    )
    qrsay ( XNIVEL++ , left(GRUPO_PG->Observacao,59))

return


static function getMayn(aEDICAO)

   aadd(aEDICAO,{{ || NIL }                                         ,NIL         })  // codigo nao pode ser editado
   aadd(aEDICAO,{{ || qesco(-1,0,@fENVIAR,sBLOC1                  )} ,"ENVIAR"   })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDATA_LANC                    ) } ,"DATA_LANC" })
   //aadd(aEDICAO,{{ || qesco(-1,0,@fPREVISAO,sBLOC1              )} ,"PREVISAO" })
   aadd(aEDICAO,{{ || view_forn(-1,0,@fCOD_FORN                 ) } ,"COD_FORN"  })
   aadd(aEDICAO,{{ || NIL                                         } ,NIL         })

   aadd(aEDICAO,{{ || view_planfin(-1,0,@fCOD_PLAN              ) } ,"COD_PLAN"  })
   aadd(aEDICAO,{{ || NIL                                         } ,NIL         })

   aadd(aEDICAO,{{ || view_tipo(-1,0,@fTIPO_SUB                 ) } ,"TIPO_SUB"  })
   aadd(aEDICAO,{{ || NIL                                         } ,NIL         })

   aadd(aEDICAO,{{ || qgetx(-1,0,@fDATA_EMISS                   ) } ,"DATA_EMISS"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@fHISTORICO,"@!@S60"           ) } ,"HISTORICO" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fVALOR    ,"@E 9,999,999.99"  ) } ,"VALOR"     })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fFATURA,"@!"                  ) } ,"FATURA"    })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fVEZES,"99"                   ) } ,"VEZES"     })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fINTERVALO,"99"               ) } ,"INTERVALO" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fOBSERVACAO,"@!@S59"          ) } ,"OBSERVACAO"})

   aadd(aEDICAO,{{ || lCONF2 := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})


return

static function i_proc_venctos

   // LOOP PRINCIPAL ___________________________________________________________
   //setcolor("W/B")
   XVIEWCOLOR := "N/W"

   if cOPCAO == "A"
      fTOTAL := 0
      lALT := .T.
   endif

   PAGAR->(qview({{"Data_venc/Vencimento."                               ,2},;
                  {"Data_emiss/Emissao."                                 ,7},;
                  {"Fatura/Fatura"                                       ,0},;
                  {"transform(Valor, '@E 999,999.99')/Valor"            ,0}},;
                  "16002379S",;
                  {NIL,"f202d",NIL,NIL},;
                  {"left(PAGAR->Grupo_pg,7) == GRUPO_PG->Codigo",{||f202top()},{||f202bot()}},;
                  "<I>nc./<A>lt./<C>on./<E>xc."))


   XVIEWCOLOR := "N/BG"


return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IR PARA O INICIO DOS DADOS FILTRADOS _________________________

function f202top
   PAGAR->(dbsetorder(12))
   PAGAR->(dbseek(GRUPO_PG->Codigo))

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IR PARA O FINAL DOS DADOS FILTRADOS __________________________

function f202bot
   PAGAR->(dbsetorder(12))
   PAGAR->(qseekn(GRUPO_PG->Codigo))
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO DE CONTROLE PRINCIPAL ANTES DE PROCESSAR A TECLA ACIONADA _________

function f202d

   local nCURSOR := setcursor(1)
   parameters cOPCAO

   cOPCAO := upper(chr(cOPCAO))

   //if cOPCAO $ XUSRA


     // qlbloc(08,08,"B201B","QBLOC.GLO",1)

     //i_processa_acao()
   //endif


   setcursor(nCURSOR)

return ""

static function i_atu_lanc
   XVIEWCOLOR := "N/W"

   PAGAR->(qview({{"Data_venc/Vencimento."                               ,2},;
                  {"Data_emiss/Emissao."                                 ,7},;
                  {"Fatura/Fatura"                                       ,0},;
                  {"transform(Valor, '@E 999,999.99')/Valor"            ,0}},;
                  "16002379S",;
                  {NIL,NIL,NIL,NIL},;
                  {"left(PAGAR->Grupo_pg,7) == GRUPO_PG->Codigo",{||f202top()},{||f202bot()}},;
                  "<ESC> pra sair."))


   XVIEWCOLOR := "N/BG"


return ""








