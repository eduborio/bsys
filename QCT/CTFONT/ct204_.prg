/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE CONTABILIDADE
// OBJETIVO...: MANUTENCAO DE LOTE INTEGRADOS
// ANALISTA...: LUCINEIDE VILAR POSSEBOM
// PROGRAMADOR: A MESMA
// INICIO.....: MAIO DE 1998
// OBS........:
// ALTERACOES.:
function ct204

#include "inkey.ch"
#include "setcurs.ch"

// DECLARACAO DE VARIAVEIS __________________________________________________

if empty(CONFIG->Exercicio) .or. len(alltrim(CONFIG->Exercicio)) < 4
    qmensa("Sistema sem o ano do Exerc¡cio informado !! Execute a op‡„o 803 !")
    return
endif

private dDATA_LANC := ctod("")
private aEDICAO    := {}
private aEDICAO1   := {}
private cLANCCENT  := CONFIG->Lanccent
private cLANCFILIAL:= CONFIG->Lancfilial
private cPARTIDA   := CONFIG->Partida
private cCENTRO    := space(10)
private cINIDB
private cINICR
private lCONF
private fFILIAL     := space(10)
private cLOTE       := space(10)
private bESCAPE     := {||lastkey()==27}
private nTOT_CRE    := 0
private nTOT_DEB    := 0

private dULT_DATA := ctod("")

PLAN->(Dbsetorder(3))  // codigo reduzido
LANC->(Dbsetorder(5))

i_edicao()

return

// PREENCHE O VETOR DE EDICAO ____________________________________________

static function i_edicao

   bESCAPE     := {||lastkey()==27.or.empty(cLOTE)}

   aadd(aEDICAO1,{{ || view_lanc(06,19,@cLOTE,"@!"      )},"LOTE"})

   // MONTA DADOS NA TELA ___________________________________________________

   qmensa()

   XNIVEL := 1
   XFLAG  := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO1)
      eval ( aEDICAO1[XNIVEL,1] )
      if eval ( bESCAPE ) ; return .F. ; endif
      if ! i_critica1( aEDICAO1[XNIVEL,2] ) ; qmensa() ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   i_ver() // funcao para verificar lancamentos do lote e mostrar total
   i_lanc()

return .T.

//////////////////////////////////////////////////////////////////////////
// CRITICAS NA DESCIDA ___________________________________________________

static function i_critica1 ( cCAMPO )
local cBLOQ
iif( cCAMPO == NIL , cCAMPO := "" , NIL )

if XFLAG

   do case
      case cCAMPO == "LOTE"
           if ! LANC->(dbseek(cLOTE))
              qmensa("N£mero do Lote n„o encontrado...","B")
              return .F.
           endif
   endcase

endif

return .T.

/////////////////////////////////////////////////////////////////////////////
// LANCAMENTOS IMEDIATOS ____________________________________________________

function i_lanc

LANC->(qview({{"Data_lanc/Data"                             ,1},;
             {"transform(Cont_db,'@R 99999-9')/Ct.Db."      ,2},;
             {"transform(Cont_cr,'@R 99999-9')/Ct.Cr."      ,3},;
             {"i_hist204()/Hist."                           ,0},;
             {"transform(Valor,'@E 9,999,999,999.99')/Valor",0}},;
             "08002079",;
             {NIL,"f204a","f204b",NIL},;
             {"LANC->Num_lote==cLOTE",{||f204top()},{||f204bot()}},;
             "<I>nclui/<A>ltera/<E>xclui/<H>ist/E<Q>uil"))
return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IR PARA O INICIO DOS DADOS FILTRADOS _________________________

function f204top
   i_mostra()
   LANC->(dbsetorder(5))
   LANC->(dbseek(cLOTE))
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IR PARA O FINAL DOS DADOS FILTRADOS __________________________

function f204bot
   i_mostra()
   LANC->(dbsetorder(5))
   LANC->(qseekn(cLOTE))
return

/////////////////////////////////////////////////////////////////////////////
// FORMATA O HISTORICO DO LANCAMENTO PARA O VIEW ____________________________

function i_hist204
   local cRET := ""
   i_mostra()
   HIST->(dbseek(LANC->Hp1)) ; cRET += alltrim(HIST->Descricao) + " "
   HIST->(dbseek(LANC->Hp2)) ; cRET += alltrim(HIST->Descricao) + " "
   HIST->(dbseek(LANC->Hp3)) ; cRET += alltrim(HIST->Descricao) + " "
return pad(ltrim(alltrim(cRET)+" "+LANC->Hist_comp),28)

/////////////////////////////////////////////////////////////////////////////
// FUNCAO DE CONTROLE PRINCIPAL ANTES DE PROCESSAR A TECLA ACIONADA _________

function f204a
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))

   iif(cOPCAO=="H",ct_con_hist(),)

   iif(cOPCAO=="Q",ct303(),)

   if cOPCAO $ "IAE"
      qlbloc(9,6,"B204B","QBLOC.GLO",1)
      i_edicao1()
   endif
   setcursor(nCURSOR)

return ""

/////////////////////////////////////////////////////////////////////////////
// ATUALIZACAO DE TELA A CADA MOVIMENTACAO DO VIEW E/OU REFRESH _____________

function f204b

   PLAN->(dbseek(LANC->Cont_db))
   if ! empty(PLAN->Reduzido)
      qsay(21,16,PLAN->Descricao)
   else
      qsay(21,16,space(40))
   endif

   PLAN->(dbseek(LANC->Cont_cr))
   if ! empty(PLAN->Reduzido)
      qsay(22,16,PLAN->Descricao)
   else
      qsay(22,16,space(40))
   endif

return


/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA ____________________________________

static function i_edicao1
   local dULT_DATA := ctod("")
   local aEDICAO   := {}
   local bESCAPE := {||empty(fDATA_LANC).or.(XNIVEL==1.and.!XFLAG).or.;
                       (XNIVEL==1.and.lastkey()==K_ESC)}

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"
      XNIVEL := 1
      qrsay(XNIVEL++,LANC->Data_lanc)
      qrsay(XNIVEL++,LANC->Num_doc  )
      qrsay(XNIVEL++,LANC->Arq      )
      qrsay(XNIVEL++,LANC->Valor   , "@E 9,999,999,999.99" )
      qrsay(XNIVEL++,LANC->Cont_db , "@R 99999-9" ) ; PLAN->(dbseek(LANC->Cont_db))
      qrsay(XNIVEL++,iif(!empty(PLAN->Reduzido),PLAN->Descricao,space(40)))
      qrsay(XNIVEL++,LANC->Cont_cr , "@R 99999-9" ) ; PLAN->(dbseek(LANC->Cont_cr))
      qrsay(XNIVEL++,iif(!empty(PLAN->Reduzido),PLAN->Descricao,space(40)))
      qrsay(XNIVEL++,LANC->Filial       ) ; FILIAL->(dbseek(LANC->Filial))
      qrsay(XNIVEL++,left(FILIAL->Razao,32))
      qrsay(XNIVEL++,LANC->Centro       ) ; CCUSTO->(dbseek(LANC->Centro))
      qrsay(XNIVEL++,left(CCUSTO->Descricao,32))
      qrsay(XNIVEL++,LANC->Hp1          ) ; HIST->(dbseek(LANC->Hp1))
      qrsay(XNIVEL++,LEFT(HIST->Descricao,50)    )
      qrsay(XNIVEL++,LANC->Hp2          ) ; HIST->(dbseek(LANC->Hp2))
      qrsay(XNIVEL++,LEFT(HIST->Descricao,50)    )
      qrsay(XNIVEL++,LANC->Hp3          ) ; HIST->(dbseek(LANC->Hp3))
      qrsay(XNIVEL++,LEFT(HIST->Descricao,50)    )
      qrsay(XNIVEL++,left(LANC->Hist_comp,58) )
   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

// PREENCHE O VETOR DE EDICAO ____________________________________________

    aadd(aEDICAO,{{ || qgetx(-1,0,@fDATA_LANC)                     },"DATA_LANC" })
    aadd(aEDICAO,{{ || qgetx(-1,0,@fNUM_DOC,"@!")                  },"NUM_DOC"   })
    aadd(aEDICAO,{{ || qgetx(-1,0,@fARQ,"@!")                      },"ARQ"       })
    aadd(aEDICAO,{{ || qgetx(-1,0,@fVALOR,"@E 9,999,999,999.99"   )},"VALOR"     })
    aadd(aEDICAO,{{ || view_planc(-1,0,@fCONT_DB)                 },"CONT_DB"  })
    aadd(aEDICAO,{{ || NIL                                         },NIL         })
    aadd(aEDICAO,{{ || view_planc(-1,0,@fCONT_CR)                 },"CONT_CR"  })
    aadd(aEDICAO,{{ || NIL                                         },NIL         })
    aadd(aEDICAO,{{ || view_filial(-1,0,@fFILIAL,"@K 9999")        },"FILIAL"    })
    aadd(aEDICAO,{{ || NIL                                         },NIL         })
    aadd(aEDICAO,{{ || view_ccusto(-1,0,@cCENTRO          )        },"CENTRO"    })
    aadd(aEDICAO,{{ || NIL                                         },NIL         })
    aadd(aEDICAO,{{ || view_hist(-1,0,@fHP1,"@K 999")              },"HP1"       })
    aadd(aEDICAO,{{ || NIL                                         },NIL         })
    aadd(aEDICAO,{{ || view_hist(-1,0,@fHP2,"@K 999")              },"HP2"       })
    aadd(aEDICAO,{{ || NIL                                         },NIL         })
    aadd(aEDICAO,{{ || view_hist(-1,0,@fHP3,"@K 999")              },"HP3"       })
    aadd(aEDICAO,{{ || NIL                                         },NIL         })
    aadd(aEDICAO,{{ || qgetx(-1,0,@fHIST_COMP,"@!@S58")            },"HIST_COMP" })
    aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   LANC->(qpublicfields())

   iif(cOPCAO=="I",LANC->(qinitfields()),LANC->(qcopyfields()))

   XNIVEL   := 1
   XFLAG    := .T.
   fCONT_DB += "  "
   fCONT_CR += "  "

   if cOPCAO $ "ID"
      fDATA_LANC := dULT_DATA
   endif

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; LANC->(qreleasefields()) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   if cOPCAO $ "ID"
      dULT_DATA := fDATA_LANC
   endif

   if ! lCONF ; return ; endif

   // GRAVACAO ______________________________________________________________

   if ct_trava_prop(fCONT_DB,fCONT_CR) .and. CONFIG->(qrlock()) .and. LANC->(iif(cOPCAO $ "I",qappend(),qrlock()))

      i_propagacao(cOPCAO)

      if cOPCAO $ "I"
         replace CONFIG->Num_lanc with CONFIG->Num_lanc + 1
         fNUM_LANC := strzero(CONFIG->Num_lanc,5)
      endif

    //  fCENTRO := cCENTRO
      fNUM_LOTE  := cLOTE

      LANC->(qreplacefields())
      LANC->(qunlock())

   else

      iif(cOPCAO=="I",qm1(),qm2())

   endif

   i_ver()

return ""

/////////////////////////////////////////////////////////////////////////////
// CRITICAS NA DESCIDA ______________________________________________________

static function i_critica ( cCAMPO )
   local zTMP , cBLOQ
   iif ( cCAMPO == NIL , cCAMPO := "" , NIL )
   if XFLAG
      do case
         case cCAMPO == "DATA_LANC"
              if year(fDATA_LANC) != val(CONFIG->Exercicio)
                 qmensa("Data fora do Exerc¡cio !","B")
                 dDATA_LANC := ctod("")
                 return .F.
              endif
              cBLOQ := strzero(month(fDATA_LANC),2)
              cBLOQ := "TRAV_" + cBLOQ
              if CONFIG->&cBLOQ == "S"
                 qmensa("Mes bloqueado para lan‡amentos !!","B")
                 qmensa()
                 fDATA_LANC := ctod("")
                 return .F.
              endif
         case cCAMPO == "VALOR"
              if empty(fVALOR) ; return .F. ; endif
         case cCAMPO == "CONT_DB"
              if empty(fCONT_DB)
                 qrsay(XNIVEL  ,space(6))
                 qrsay(XNIVEL+1,space(40))
                 cINIDB := " "
                 if CONFIG->Partida == "N"
                    qmensa("Lan‡amentos em Partida Simples n„o s„o Permitidos !","B")
                    return .F.
                 endif
              else
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
              if empty(fCONT_CR)
                 qrsay(XNIVEL  ,space(6))
                 qrsay(XNIVEL+1,space(40))
                 cINICR := " "
                 if CONFIG->Partida == "N"
                    qmensa("Lan‡amentos em Partida Simples n„o s„o Permitidos !","B")
                    return .F.
                 endif
              else
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
                 qrsay(XNIVEL+1,PLAN->Descricao)
                 cINICR := left(PLAN->Codigo,1)
                 if ct_e_sint()
                    qmensa("Conta Sint‚tica ! Lan‡amento n„o permitido !","B")
                    return .F.
                 endif
              endif
              if fCONT_CR == fCONT_DB
                 qmensa("Contas iguais ! Lan‡amento inv lido !","B")
                 return .F.
              endif
//              if cLANCFILIAL != "S" .or. (cINIDB $ "12" .and. cINICR $ "12")
//                 cFILIAL := space(4)
//                 qrsay(XNIVEL+2,space(4))
//                 qrsay(XNIVEL+3,space(32))
//                 XNIVEL+=2
//                 if cLANCCENT != "S" .or. (cINIDB $ "12" .and. cINICR $ "12")
//                    cCENTRO := space(10)
//                    qrsay(XNIVEL+2,space(10))
//                    qrsay(XNIVEL+3,space(32))
//                    XNIVEL+=2
//                 endif
//              endif
                cCENTRO := fCENTRO
         case cCAMPO == "FILIAL"
              if ! FILIAL->(dbseek(fFILIAL))
                 qmensa("Filial n„o cadastrada !","B")
                 return .F.
              endif
              qrsay(XNIVEL+1,left(FILIAL->Razao,32))
//              if cLANCCENT != "S" .or. (cINIDB $ "12 " .and. cINICR $ "12 ")
//                 cCENTRO := space(10)
//                 qrsay(XNIVEL+2,space(10))
//                 qrsay(XNIVEL+3,space(32))
//                 XNIVEL+=2
//              endif
         case cCAMPO == "CENTRO"
              if cLANCCENT == "S"
                    if ! CCUSTO->(dbseek(cCENTRO))
                       qmensa("Centro de Custo n„o cadastrado !","B")
                       return .F.
                    endif
                    qrsay(XNIVEL+1,left(CCUSTO->Descricao,32))
              endif
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
                 fHP2:= fHP3 := space(3)
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
              if empty(fHP2) ; keyboard chr(13) ; endif
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
// FUNCAO PARA EXCLUIR LANCAMENTOS __________________________________________

static function i_exclusao
   if qconf("Confirma exclus„o deste lan‡amento ?")
      if LANC->(qrlock()) .and. CONFIG->(qrlock()) .and. LANC->(ct_trava_prop(Cont_db,Cont_cr))
         i_propagacao("E")
         LANC->(dbdelete())
      else
         qm3()
      endif
      dbunlockall()
   endif
return

/////////////////////////////////////////////////////////////////////////////
// VIEW PADRAO PARA PLANO DE CONTAS SOMENTE PARA ESTE PROGRAMA ______________

function view_planc (XX,YY,ZZ)
   PLAN->(dbSetFilter({|| right(PLAN->Codigo,5) <> " "}, 'right(PLAN->Codigo,5) <> " "'))

   PLAN->(qview(XX,YY,@ZZ,"@K@R 99999-9",NIL,.T.,NIL,;
         {{"Descricao/Descri‡„o"           ,2},;
          {"ct_convcod(Codigo)/C¢digo"     ,1},;
          {"ct_convcod(Reduzido)/Cod.Red." ,3}},;
          "C",{"keyb(Reduzido)",NIL,NIL,NIL}))

   PLAN->(dbClearFilter())
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA VERIFICAR VALOR DO LOTE (DB/CR) ______________________________
function i_ver

   nTOT_CRE := nTOT_DEB := 0
   LANC->(dbsetorder(5))
   nREC := LANC->(recno())
   LANC->(dbgotop())
   LANC->(dbseek(cLOTE))

   while ! LANC->(eof()) .and. LANC->Num_lote == cLOTE

      qgirabarra()

      do case
         case empty(LANC->Cont_db) .and. ! empty(LANC->Cont_cr)
              nTOT_CRE += LANC->Valor
         case ! empty(LANC->Cont_db) .and. empty(LANC->Cont_cr)
              nTOT_DEB += LANC->Valor
         case ! empty(LANC->Cont_db) .and. ! empty(LANC->Cont_cr)
              nTOT_DEB += LANC->Valor
              nTOT_CRE += LANC->Valor
      endcase

      LANC->(dbskip())

   enddo

   qsay(07,19,transform(nTOT_CRE,"@R 9999,999,999.99"))
   qsay(07,62,transform(nTOT_DEB,"@R 9999,999,999.99"))

   LANC->(Dbgoto(nREC))

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAR OS VALORES DO LOTE (DB/CR) ___________________________
function i_mostra
   qsay(07,19,transform(nTOT_CRE,"@R 9999,999,999.99"))
   qsay(07,62,transform(nTOT_DEB,"@R 9999,999,999.99"))
return

/////////////////////////////////////////////////////////////////////////////
// PROPAGACAO GERAL DE SALDO ________________________________________________

static function i_propagacao ( cOPT )

   do case

      // ATUALIZA SALDOS NA INCLUSAO E DUPLICACAO ___________________________

      case cOPT $ "ID"
           if ! empty(fCONT_DB)
              ct_prop_saldo(fCONT_DB,fVALOR,"DB"+strzero(month(fDATA_LANC),2))
              CONFIG->&("DB"+strzero(month(fDATA_LANC),2))+=fVALOR
           endif
           if ! empty(fCONT_CR)
              ct_prop_saldo(fCONT_CR,fVALOR,"CR"+strzero(month(fDATA_LANC),2))
              CONFIG->&("CR"+strzero(month(fDATA_LANC),2))+=fVALOR*-1
           endif

      // ATUALIZA SALDOS NA EXCLUSAO ________________________________________

      case cOPT == "E"
           if ! empty(LANC->Cont_db)
              ct_prop_saldo(LANC->Cont_db,LANC->Valor*-1,"DB"+strzero(month(LANC->Data_lanc),2))
              CONFIG->&("DB"+strzero(month(LANC->Data_lanc),2))+=LANC->Valor*-1
           endif
           if ! empty(LANC->Cont_cr)
              ct_prop_saldo(LANC->Cont_cr,LANC->Valor*-1,"CR"+strzero(month(LANC->Data_lanc),2))
              CONFIG->&("CR"+strzero(month(LANC->Data_lanc),2))+=LANC->Valor
           endif

      // RECURSIVAMENTE CHAMA EXCLUSAO E INCLUSAO ___________________________

      case cOPT == "A"
           i_propagacao("E")
           i_propagacao("I")

   endcase

return

