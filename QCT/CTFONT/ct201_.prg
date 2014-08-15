/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE CONTABILIDADE
// OBJETIVO...: LANCAMENTOS EM LOTE
// ANALISTA...: LUIS ANTONIO ORLANDO PEREIRA
// PROGRAMADOR: O MESMO
// INICIO.....: FEVEREIRO DE 1996
// OBS........:
// ALTERACOES.:
function ct201

#include "inkey.ch"
#include "setcurs.ch"
#define K_MAX_LIN 55

/////////////////////////////////////////////////////////////////////////////
// DECLARACAO DE VARIAVEIS __________________________________________________

if empty(CONFIG->Exercicio) .or. len(alltrim(CONFIG->Exercicio)) < 4
    qmensa("Sistema sem o ano do Exerc¡cio informado !! Execute a op‡„o 803 !")
    return
endif

private bESCAPE    := {||lastkey()=27}        // condicao para abandonar edicoes
private cLANCCENT  := CONFIG->Lanccent        // permissao para lancamento com centro de custo
private nLOTE      := CONFIG->Ult_lote + 1    // numero do proximo lote a ser lancado
private dDATA_LANC := ctod("")                // data do lote
private nTOT_DEB   := 0                       // total de lancamentos de debito
private nTOT_CRE   := 0                       // total de lancamentos de credito
private nVALOR     := 0                       // valor de lancamento
private nREC       := 0                       // numero do registro do lote
private cNUM_LOTE  := space(10)               // numero do lote

private aEDICAO    := {}                      // vetor 1 de edicao para informacoes do lote
private aEDICAO1   := {}                      // vetor 2 de edicao para lancamentos no lote
private lEMABERTO  := .F.                     // flag de verificacao de existencia de lote em aberto
private lVOLTA     := .F.                     // flag que controla o retorno ao inicio
private lINTERF    := .F.                     // flag que controla se lote DE INTERFACE ou nao
private cINIDB     := " "                    // primeiro caracter do codigo da conta debito
private cINICR     := " "                    // primeiro caracter do codigo da conta credito
private lCONF      := .F.

PLAN->(dbsetorder(3))  // MANTEM A ORDEM EM CODIGO REDUZIDO P/ CHECK...

qlbloc(5,0,"B201A","QBLOC.GLO")
qmensa("ESC - Cancela...")

i_edicao()

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA ____________________________________

static function i_edicao

   local bESCAPE := {||(XNIVEL==1.and.!XFLAG).or.;
                       (empty(dDATA_LANC) .and. XNIVEL==2 .and. !XFLAG .or. empty(dDATA_LANC) .and. XNIVEL==2 .and. Lastkey()==27) .or.;
                       (XNIVEL==1.and.lastkey()==27)}

   local dULT_DATA := ctod("")

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO1,{{ || NIL },"NUM_LOTE"}) // numero de lote nao pode ser editado
   aadd(aEDICAO1,{{ || qgetx(06,63 , @dDATA_LANC              ) },"DATA_LANC" })
   
   // INICIALIZACAO DA EDICAO _______________________________________________

   // MONTA DADOS NA TELA ___________________________________________________
   
   XNIVEL := 1
   XFLAG  := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO1)
      eval ( aEDICAO1[XNIVEL,1] )
      if eval ( bESCAPE ) ; return .F. ; endif
      if ! i_critica1( aEDICAO1[XNIVEL,2] ) ; qmensa() ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo
   qmensa("")
   cNUM_LOTE := "CT" + XUSRNUM + strzero(nLOTE,5)
   i_verifica() // funcao para verificar lancamentos do lote e mostrar total
   i_lanca()
//   if nTOT_CRE == nTOT_DEB
   if qconf("Confirma inclus„o deste LOTE?","B")
      qmensa()
      i_gravacao()
   endif
 //endif
return .T.

/////////////////////////////////////////////////////////////////////////////
// CRITICAS NA DESCIDA ______________________________________________________

static function i_critica1 ( cCAMPO )
   local cBLOQ
   iif( cCAMPO == NIL , cCAMPO := "" , NIL )

   if XFLAG

      do case

         case cCAMPO == "NUM_LOTE"
              cNUM_LOTE := "CT" + XUSRNUM + strzero(nLOTE,5)
              qsay(06,19,cNUM_LOTE)

         case cCAMPO == "DATA_LANC"
              if year(dDATA_LANC) != val(CONFIG->Exercicio)
                 qmensa("Data fora do Exerc¡cio !","B")
                 dDATA_LANC := ctod("")
                 return .F.
              endif
              cBLOQ := strzero(month(dDATA_LANC),2)
              cBLOQ := "TRAV_" + cBLOQ
              if CONFIG->&cBLOQ == "S"
                 qmensa("Mes bloqueado para lan‡amentos !!","B")
                 qmensa()
                 fDATA_LANC := ctod("")
                 return .F.
              endif

      endcase

   endif

return .T.


/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DOS LANCAMENTOS EM LOTE ___________________

function i_lanca

LOTE->(qview({{"Cont_db/D‚bito"                                 ,0},;
              {"Cont_cr/Cr‚dito"                                ,0},;
              {"f201a()/Filial"                                 ,0},;
              {"f201b()/Centro"                                 ,0},;
              {"transform(Valor,'@R 999999,999,999.99')/Valor"  ,0}},;
              "09002379S",;
              {NIL,"f201c",NIL,NIL},;
              {"LOTE->Num_lote == cNUM_LOTE",{||f201top()},{||f201bot()}},;
              "<ESC> Abandona /<I>nc./<A>lt./<C>on./<E>xc."))

return ""

/////////////////////////////////////////////////////////////////////////////
// RETORNA O CENTRO DE CUSTO DO LOTE _______________________________________

function f201b
   mostra_val()
   CCUSTO->(dbseek(LOTE->Centro))
return left(CCUSTO->Descricao,20)

/////////////////////////////////////////////////////////////////////////////
// RETORNA A FILIAL DO LOTE _________________________________________________

function f201a
   mostra_val()
   FILIAL->(dbseek(LOTE->Filial))
return left(FILIAL->Razao,20)

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IR PARA O INICIO DOS DADOS FILTRADOS _________________________

function f201top
   mostra_val()
   LOTE->(dbsetorder(1))
   LOTE->(dbseek(cNUM_LOTE))
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IR PARA O FINAL DOS DADOS FILTRADOS __________________________

function f201bot
   mostra_val()
   LOTE->(dbsetorder(1))
   LOTE->(qseekn(cNUM_LOTE))
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO DE CONTROLE PRINCIPAL ANTES DE PROCESSAR A TECLA ACIONADA _________

function f201c

   local nCURSOR := setcursor(1)
   parameters cOPCAO

   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO $ XUSRA
      qlbloc(10,08,"B201B","QBLOC.GLO",1)
      i_verifica()
      i_processa_acao()
   endif

   setcursor(nCURSOR)

return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO DE BROWSE _________________________________________________________

static function i_processa_acao

   local lCONF
   local aEDICAO := {}
   local bESCAPE := {||(XNIVEL==1.and.!XFLAG).or.;
                       (XNIVEL==1.and.lastkey()==27)}

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"

      XNIVEL := 1
      qrsay ( XNIVEL++ , LOTE->Cont_db , "@R 99999-9"           ) ; PLAN->(dbseek(LOTE->Cont_db))
      qrsay ( XNIVEL++ , left(PLAN->Descricao,40)               )
      qrsay ( XNIVEL++ , LOTE->Cont_cr , "@R 99999-9"           ) ; PLAN->(dbseek(LOTE->Cont_cr))
      qrsay ( XNIVEL++ , left(PLAN->Descricao,40)               )
      qrsay ( XNIVEL++ , LOTE->Filial                           ) ; FILIAL->(dbseek(LOTE->Filial))
      qrsay ( XNIVEL++ , left(FILIAL->Razao,40)                 )
      qrsay ( XNIVEL++ , LOTE->Centro                           ) ; CCUSTO->(dbseek(LOTE->Centro))
      qrsay ( XNIVEL++ , left(CCUSTO->Descricao,35)             )
      qrsay ( XNIVEL++ , LOTE->Num_doc                          )
      qrsay ( XNIVEL++ , LOTE->Arq                              )
      qrsay ( XNIVEL++ , LOTE->Valor, "@E 999999999,999.99"     )
      qrsay ( XNIVEL++ , LOTE->Hp1                              ) ; HIST->(dbseek(LOTE->Hp1))
      qrsay ( XNIVEL++ , left(HIST->Descricao,50)               )
      qrsay ( XNIVEL++ , LOTE->Hp2                              ) ; HIST->(dbseek(LOTE->Hp2))
      qrsay ( XNIVEL++ , left(HIST->Descricao,50)               )
      qrsay ( XNIVEL++ , LOTE->Hp3                              ) ; HIST->(dbseek(LOTE->Hp3))
      qrsay ( XNIVEL++ , left(HIST->Descricao,50)               )
      qrsay ( XNIVEL++ , left(LOTE->Hist_comp,50)               )

   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exc_lote() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || view_plan(-1,0,@fCONT_DB                     ) } ,"CONT_DB"   })
   aadd(aEDICAO,{{ || NIL                                            } ,NIL         })
   aadd(aEDICAO,{{ || view_plan(-1,0,@fCONT_CR                     ) } ,"CONT_CR"   })
   aadd(aEDICAO,{{ || NIL                                            } ,NIL         })
   aadd(aEDICAO,{{ || view_filial(-1,0,@fFILIAL                    ) } ,"FILIAL"    })
   aadd(aEDICAO,{{ || NIL                                            } ,NIL         })
   aadd(aEDICAO,{{ || view_ccusto(-1,0,@fCENTRO                    ) } ,"CENTRO"    })
   aadd(aEDICAO,{{ || NIL                                            } ,NIL         })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fNUM_DOC                         ) } ,"NUM_DOC"   })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fARQ                             ) } ,"ARQ"       })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fVALOR, "999999999,999.99"       ) } ,"VALOR"     })
   aadd(aEDICAO,{{ || view_hist(-1,0,@fHP1                         ) } ,"HP1"       })
   aadd(aEDICAO,{{ || NIL                                            } ,NIL         })
   aadd(aEDICAO,{{ || view_hist(-1,0,@fHP2                         ) } ,"HP2"       })
   aadd(aEDICAO,{{ || NIL                                            } ,NIL         })
   aadd(aEDICAO,{{ || view_hist(-1,0,@fHP3                         ) } ,"HP3"       })
   aadd(aEDICAO,{{ || NIL                                            } ,NIL         })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fHIST_COMP,"@!@S40"              ) } ,"HIST_COMP" })

   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   LOTE->(qpublicfields())

   iif(cOPCAO=="I",LOTE->(qinitfields()),LOTE->(qcopyfields()))

   if cOPCAO == "A"
      nVALOR := fVALOR
   endif

   XNIVEL := 1

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; LOTE->(qreleasefields()) ; return ; endif
      if ! i_crit2( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   if ! lCONF ; return ; endif

   // GRAVACAO ______________________________________________________________

   if LOTE->(qrlock()) .and. LOTE->(iif(cOPCAO=="I",qappend(),qrlock()))
      if cOPCAO == "I"
         fNUM_LOTE  := cNUM_LOTE
         fDATA_LANC := dDATA_LANC
      endif

      LOTE->(qreplacefields())
      LOTE->(qunlock())

   else

      iif(cOPCAO=="I",qm1(),qm2())

   endif

   i_verifica()

return

//////////////////////////////////////////////////////////////////////////
// CRITICAS NA DESCIDA ___________________________________________________

static function i_crit2 ( cCAMPO )
   iif( cCAMPO == NIL , cCAMPO := "" , NIL )
   if XFLAG
      do case
         case cCAMPO == "CONT_DB"
              if ! empty(fCONT_DB)
                 if ! ct_dig_ok(fCONT_DB)
                    qmensa("Digito verificador invalido !","B")
                    return .F.
                 endif
                 fCONT_DB := strzero(val(fCONT_DB),6)
                 qrsay(XNIVEL,fCONT_DB,"@R 99999-9")
                 if ! PLAN->(dbseek(fCONT_DB))
                    qmensa("Conta d‚bito n„o encontrada !","B")
                    return .F.
                 endif
                 qrsay(XNIVEL+1,PLAN->Descricao)
                 cINIDB := left(PLAN->Codigo,1)
                 if ct_e_sint()
                    qmensa("Conta Sint‚tica ! Lan‡amento n„o permitido !","B")
                    return .F.
                 endif
              endif
         case cCAMPO == "CONT_CR"
              if ! empty(fCONT_CR)
                 if ! ct_dig_ok(fCONT_CR)
                    qmensa("Digito verificador invalido !","B")
                    return .F.
                 endif
                 fCONT_CR := strzero(val(fCONT_CR),6)
                 qrsay(XNIVEL,fCONT_CR,"@R 99999-9")
                 if ! PLAN->(dbseek(fCONT_CR))
                    qmensa("Conta cr‚dito n„o encontrada !","B")
                    return .F.
                 endif
                 cINICR := left(PLAN->Codigo,1)
                 qrsay(XNIVEL+1,PLAN->Descricao)
                 if ct_e_sint()
                    qmensa("Conta Sint‚tica ! Lan‡amento n„o permitido !","B")
                    return .F.
                 endif
              endif
              if fCONT_CR == fCONT_DB
                 qmensa("Contas iguais ! Lan‡amento inv lido !","B")
                 return .F.
              endif
         case cCAMPO == "FILIAL"
              cFILIAL:= strzero(val(fFILIAL),4)
              if ! FILIAL->(dbseek(fFILIAL))
                 qmensa("Filial n„o cadastrado !","B")
                 return .F.
              endif
              qrsay(XNIVEL+1,left(FILIAL->Razao,38))
              if cLANCCENT != "S" .or. (cINIDB $ "12 " .and. cINICR $ "12 ")
                 fCENTRO := space(10)
                 qrsay(XNIVEL+2,space(10))
                 qrsay(XNIVEL+3,space(32))
                 XNIVEL+=2
              endif
         case cCAMPO == "CENTRO"
              if cLANCCENT == "S"
                 if ! cINIDB $ "12" .or. ! cINICR $ "12"
                    if ! CCUSTO->(dbseek(fCENTRO))
                       qmensa("Centro de Custo n„o cadastrado !","B")
                       return .F.
                    endif
                    qrsay(XNIVEL+1,left(CCUSTO->Descricao,35))
                 endif
              endif
         case cCAMPO == "VALOR"
              if empty(fVALOR) ; return .F. ; endif

         case cCAMPO == "HP1"
              if ! empty(fHP1)
                 qrsay(XNIVEL,fHP1:=strzero(val(fHP1),3))
                 if ! HIST->(dbseek(fHP1))
                    qmensa("Hist¢rico n„o encontrado !","B")
                    return .F.
                 endif
                 qrsay(XNIVEL+1,LEFT(HIST->Descricao,50))
              endif
              if empty(fHP1)
                 fHP2 := fHP3 := space(3)
                 keyboard chr(13)+chr(13)
              endif

         case cCAMPO == "HP2"
              if ! empty(fHP2)
                 qrsay(XNIVEL,fHP2:=strzero(val(fHP2),3))
                 if ! HIST->(dbseek(fHP2))
                    qmensa("Hist¢rico n„o encontrado !","B")
                    return .F.
                 endif
                 qrsay(XNIVEL+1,LEFT(HIST->Descricao,50))
              endif
              if empty(fHP2) .and. cOPCAO == "I" ; keyboard chr(13) ; endif

         case cCAMPO == "HP3"
              if ! empty(fHP3)
                 qrsay(XNIVEL,fHP3:=strzero(val(fHP3),3))
                 if ! HIST->(dbseek(fHP3))
                    qmensa("Hist¢rico n„o encontrado !","B")
                    return .F.
                 endif
                 qrsay(XNIVEL+1,LEFT(HIST->Descricao,50))
              endif

         case cCAMPO == "HIST_COMP"
              if empty(fHP1) .and. empty(fHP2) .and. empty(fHP3) .and. empty(fHIST_COMP)
                 return .F.
              endif
      endcase

   endif

return .T.


/////////////////////////////////////////////////////////////////////////////
// EXCLUSAO DE LANCAMENTOS NO LOTE __________________________________________

static function i_exc_lote
   if qconf("Confirma exclus„o deste Lan‡amento ?")
      if LOTE->(qrlock())
         LOTE->(dbdelete())
         LOTE->(qunlock())
      else
         qm3()
      endif
      i_verifica()
   endif
return

/////////////////////////////////////////////////////////////////////////////
// GRAVACAO DOS LANCAMENTOS NOS ARQUIVOS CONTABEIS __________________________

static function i_gravacao
   local lENTROU := .F.

   LOTE->(dbsetorder(1))
   LOTE->(dbgotop())
   LOTE->(dbseek(cNUM_LOTE))

   qmensa("Aguarde... Processando Inclus„o...")

   do while ! LOTE->(eof()) .and. LOTE->Num_lote == cNUM_LOTE
      if ct_trava_prop(LOTE->Cont_db,LOTE->Cont_cr) .and. CONFIG->(qrlock()) .and. LANC->(qappend())

         qlbloc(13,06,"B201B","QBLOC.GLO")

         qgirabarra()

         replace CONFIG->Num_lanc with CONFIG->Num_lanc + 1

         if ! empty(LOTE->Cont_cr) .or. ! empty(LOTE->Cont_db)
            replace LANC->Data_lanc with LOTE->Data_lanc
            replace LANC->Cont_cr   with LOTE->Cont_cr
            replace LANC->Cont_db   with LOTE->Cont_db
            replace LANC->Filial    with LOTE->Filial
            replace LANC->Centro    with LOTE->Centro
            replace LANC->Valor     with LOTE->Valor
            replace LANC->Num_lote  with LOTE->Num_lote
            replace LANC->Num_lanc  with strzero(CONFIG->Num_lanc,5)
            replace LANC->Num_doc   with LOTE->Num_doc
            replace LANC->Arq       with LOTE->Arq
            replace LANC->Hp1       with LOTE->Hp1
            replace LANC->Hp2       with LOTE->Hp2
            replace LANC->Hp3       with LOTE->Hp3
            replace LANC->Hist_comp with LOTE->Hist_comp

            XNIVEL := 1
            qrsay(XNIVEL++,LOTE->Cont_db,"@R 99999-9" ) ; PLAN->(dbseek(LOTE->Cont_db))
            qrsay(XNIVEL++,PLAN->Descricao    )
            qrsay(XNIVEL++,LOTE->Cont_cr,"@R 99999-9" ) ; PLAN->(dbseek(LOTE->Cont_cr))
            qrsay(XNIVEL++,PLAN->Descricao    )
            qrsay(XNIVEL++,LOTE->Filial  ) ; FILIAL->(dbseek(LOTE->Filial))
            qrsay(XNIVEL++,left(FILIAL->Razao,38))
            qrsay(XNIVEL++,LOTE->Centro  ) ; CCUSTO->(dbseek(LOTE->Centro))
            qrsay(XNIVEL++,left(CCUSTO->Descricao,38))
            qrsay(XNIVEL++,LOTE->Num_doc )
            qrsay(XNIVEL++,LOTE->Arq )
            qrsay(XNIVEL++,LOTE->Valor,"@E 9,999,999,999.99" )
            qrsay(XNIVEL++,LOTE->Hp1     ) ; HIST->(dbseek(LOTE->Hp1))
            qrsay(XNIVEL++,LEFT(HIST->Descricao,50)    )
            qrsay(XNIVEL++,LOTE->Hp2     ) ; HIST->(dbseek(LOTE->Hp2))
            qrsay(XNIVEL++,LEFT(HIST->Descricao,50)    )
            qrsay(XNIVEL++,LOTE->Hp3     ) ; HIST->(dbseek(LOTE->Hp3))
            qrsay(XNIVEL++,LEFT(HIST->Descricao,50)    )
            qrsay(XNIVEL++,left(LOTE->Hist_comp,58) )

            i_propagacao("I")

            lENTROU := .T.

            if LOTE->(qrlock())
               LOTE->(dbdelete())
               LOTE->(qunlock())
            endif

         endif
      else
         qm1()
      endif

      dbunlockall()

      LOTE->(dbskip())

   enddo

   if lENTROU
      if CONFIG->(qrlock())
         replace CONFIG->Ult_lote with CONFIG->Ult_lote + 1
         replace CONFIG->Interface with space(6)
         replace CONFIG->Tp_estorno with space(2)
         replace CONFIG->Estorno with 0
      endif
      nLOTE++
      lVOLTA := .T.
      qlbloc(5,0,"B201A","QBLOC.GLO")
   endif
   qmensa("")
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA VERIFICAR VALOR DO LOTE (DB/CR) ______________________________
function i_verifica
   nTOT_CRE := nTOT_DEB := 0
   LOTE->(dbsetorder(1))
   nREC := LOTE->(recno())
   LOTE->(dbgotop())
   LOTE->(dbseek(cNUM_LOTE))
   while ! LOTE->(eof()) .and. LOTE->Num_lote == cNUM_LOTE
      do case
         case empty(LOTE->Cont_db) .and. ! empty(LOTE->Cont_cr)
              nTOT_CRE += LOTE->Valor
         case ! empty(LOTE->Cont_db) .and. empty(LOTE->Cont_cr)
              nTOT_DEB += LOTE->Valor
         case ! empty(LOTE->Cont_db) .and. ! empty(LOTE->Cont_cr)
              nTOT_DEB += LOTE->Valor
              nTOT_CRE += LOTE->Valor
      endcase
      LOTE->(dbskip())
   enddo
   mostra_val()
   LOTE->(Dbgoto(nREC))
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAR OS VALORES DO LOTE (DB/CR) ___________________________
function mostra_val
   qsay(07,19,transform(nTOT_CRE,"@R 9999,999,999.99"))
   qsay(07,58,transform(nTOT_DEB,"@R 9999,999,999.99"))
return

/////////////////////////////////////////////////////////////////////////////
// PROPAGACAO GERAL DE SALDO ________________________________________________

static function i_propagacao ( cOPT )

  // ATUALIZA SALDOS NA INCLUSAO ________________________________________

  if CONFIG->(qrlock())
     if ! empty(LOTE->Cont_db)
        ct_prop_saldo(LOTE->Cont_db,LOTE->Valor,"DB"+strzero(month(LOTE->Data_lanc),2))
        CONFIG->&("DB"+strzero(month(LOTE->Data_lanc),2))+=LOTE->Valor
     endif
     if ! empty(LOTE->Cont_cr)
        ct_prop_saldo(LOTE->Cont_cr,LOTE->Valor,"CR"+strzero(month(LOTE->Data_lanc),2))
        CONFIG->&("CR"+strzero(month(LOTE->Data_lanc),2))+=LOTE->Valor*-1
     endif
     CONFIG->(qunlock())
  endif

return
