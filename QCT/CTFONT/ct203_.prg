////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE CONTABILIDADE
// OBJETIVO...: MANUTENCAO DE LOTE
// ANALISTA...: LUCINEIDE VILAR POSSEBOM
// PROGRAMADOR: A MESMA
// INICIO.....: ABRIL DE 1998
// OBS........:
// ALTERACOES.:
function ct203

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
private nCREDITO    := 0
private nDEBITO     := 0

private dULT_DATA := ctod("")

PLAN->(Dbsetorder(3))  // codigo reduzido

i_edicao()

return

// PREENCHE O VETOR DE EDICAO ____________________________________________

static function i_edicao

   bESCAPE     := {||lastkey()==27.or.empty(cLOTE)}

   aadd(aEDICAO1,{{ || view_lote(06,19,@cLOTE,"@!"      )},"LOTE"})

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


   i_ver_tots() // funcao para verificar lancamentos do lote e mostrar total
   i_lote()

  // if nCREDITO == nDEBITO
      if qconf("Confirma inclus„o ?","B")
         qmensa()
         i_gravacao()
      endif
  // endif

return .T.

//////////////////////////////////////////////////////////////////////////
// CRITICAS NA DESCIDA ___________________________________________________

static function i_critica1 ( cCAMPO )
local cBLOQ
iif( cCAMPO == NIL , cCAMPO := "" , NIL )

if XFLAG

   do case
      case cCAMPO == "LOTE"
           if ! LOTE->(dbseek(cLOTE))
              qmensa("N£mero do Lote n„o encontrado...","B")
              return .F.
           endif
   endcase

endif

return .T.

/////////////////////////////////////////////////////////////////////////////
// LANCAMENTOS IMEDIATOS ____________________________________________________

function i_lote

LOTE->(qview({{"Data_lanc/Data"                             ,1},;
             {"transform(Cont_db,'@R 99999-9')/Ct.Db."      ,2},;
             {"transform(Cont_cr,'@R 99999-9')/Ct.Cr."      ,3},;
             {"i_hist203()/Hist."                           ,0},;
             {"transform(Valor,'@E 9,999,999,999.99')/Valor",0}},;
             "08002079",;
             {NIL,"f203a","f203b",NIL},;
             {"LOTE->Num_lote==cLOTE",{||f203top()},{||f203bot()}},;
             "<I>nclui/<A>ltera/<E>xclui/<H>ist/E<Q>uil"))
return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IR PARA O INICIO DOS DADOS FILTRADOS _________________________

function f203top
   mostra()
   LOTE->(dbsetorder(1))
   LOTE->(dbseek(cLOTE))
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IR PARA O FINAL DOS DADOS FILTRADOS __________________________

function f203bot
   mostra()
   LOTE->(dbsetorder(1))
   LOTE->(qseekn(cLOTE))
return

/////////////////////////////////////////////////////////////////////////////
// FORMATA O HISTORICO DO LANCAMENTO PARA O VIEW ____________________________

function i_hist203
   local cRET := ""
   mostra()
   HIST->(dbseek(LOTE->Hp1)) ; cRET += alltrim(HIST->Descricao) + " "
   HIST->(dbseek(LOTE->Hp2)) ; cRET += alltrim(HIST->Descricao) + " "
   HIST->(dbseek(LOTE->Hp3)) ; cRET += alltrim(HIST->Descricao) + " "
return pad(ltrim(alltrim(cRET)+" "+LOTE->Hist_comp),28)

/////////////////////////////////////////////////////////////////////////////
// FUNCAO DE CONTROLE PRINCIPAL ANTES DE PROCESSAR A TECLA ACIONADA _________

function f203a
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))

   iif(cOPCAO=="H",ct_con_lote(),)

   iif(cOPCAO=="Q",ct303(),)

   if cOPCAO $ "IAE"
      qlbloc(9,6,"B203B","QBLOC.GLO",1)
      i_edicao1()
   endif
   setcursor(nCURSOR)

return ""

/////////////////////////////////////////////////////////////////////////////
// ATUALIZACAO DE TELA A CADA MOVIMENTACAO DO VIEW E/OU REFRESH _____________

function f203b

   PLAN->(dbseek(LOTE->Cont_db))
   if ! empty(PLAN->Reduzido)
      qsay(21,16,PLAN->Descricao)
   else
      qsay(21,16,space(40))
   endif

   PLAN->(dbseek(LOTE->Cont_cr))
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
      qrsay(XNIVEL++,LOTE->Data_lanc)
      qrsay(XNIVEL++,LOTE->Num_doc  )
      qrsay(XNIVEL++,LOTE->Arq      )
      qrsay(XNIVEL++,LOTE->Valor   , "@E 9,999,999,999.99" )
      qrsay(XNIVEL++,LOTE->Cont_db , "@R 99999-9" ) ; PLAN->(dbseek(LOTE->Cont_db))
      qrsay(XNIVEL++,iif(!empty(PLAN->Reduzido),PLAN->Descricao,space(40)))
      qrsay(XNIVEL++,LOTE->Cont_cr , "@R 99999-9" ) ; PLAN->(dbseek(LOTE->Cont_cr))
      qrsay(XNIVEL++,iif(!empty(PLAN->Reduzido),PLAN->Descricao,space(40)))
      qrsay(XNIVEL++,LOTE->Filial       ) ; FILIAL->(dbseek(LOTE->Filial))
      qrsay(XNIVEL++,left(FILIAL->Razao,32))
      qrsay(XNIVEL++,LOTE->Centro       ) ; CCUSTO->(dbseek(LOTE->Centro))
      qrsay(XNIVEL++,left(CCUSTO->Descricao,32))
      qrsay(XNIVEL++,LOTE->Hp1          ) ; HIST->(dbseek(LOTE->Hp1))
      qrsay(XNIVEL++,LEFT(HIST->Descricao,50)    )
      qrsay(XNIVEL++,LOTE->Hp2          ) ; HIST->(dbseek(LOTE->Hp2))
      qrsay(XNIVEL++,LEFT(HIST->Descricao,50)    )
      qrsay(XNIVEL++,LOTE->Hp3          ) ; HIST->(dbseek(LOTE->Hp3))
      qrsay(XNIVEL++,LEFT(HIST->Descricao,50)    )
      qrsay(XNIVEL++,left(LOTE->Hist_comp,58) )
   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

// PREENCHE O VETOR DE EDICAO ____________________________________________

    aadd(aEDICAO,{{ || qgetx(-1,0,@fDATA_LANC)                     },"DATA_LANC" })
    aadd(aEDICAO,{{ || qgetx(-1,0,@fNUM_DOC,"@!")                  },"NUM_DOC"   })
    aadd(aEDICAO,{{ || qgetx(-1,0,@fARQ,"@!")                      },"ARQ"       })
    aadd(aEDICAO,{{ || qgetx(-1,0,@fVALOR,"@E 9,999,999,999.99"   )},"VALOR"     })
    aadd(aEDICAO,{{ || view_plllanc(-1,0,@fCONT_DB)                 },"CONT_DB"  })
    aadd(aEDICAO,{{ || NIL                                         },NIL         })
    aadd(aEDICAO,{{ || view_plllanc(-1,0,@fCONT_CR)                 },"CONT_CR"  })
    aadd(aEDICAO,{{ || NIL                                         },NIL         })
    aadd(aEDICAO,{{ || view_filial(-1,0,@fFILIAL,"@K 9999")        },"FILIAL"    })
    aadd(aEDICAO,{{ || NIL                                         },NIL         })
    aadd(aEDICAO,{{ || view_ccusto(-1,0,@cCENTRO,"@!",NIL,cLANCCENT=="S" .and. (! cINIDB $ "12" .or. ! cINICR $ "12"))},"CENTRO"})
    aadd(aEDICAO,{{ || NIL                                         },NIL         })
    aadd(aEDICAO,{{ || view_hist(-1,0,@fHP1,"@K 999")              },"HP1"       })
    aadd(aEDICAO,{{ || NIL                                         },NIL         })
    aadd(aEDICAO,{{ || view_hist(-1,0,@fHP2,"@K 999")              },"HP2"       })
    aadd(aEDICAO,{{ || NIL                                         },NIL         })
    aadd(aEDICAO,{{ || view_hist(-1,0,@fHP3,"@K 999")              },"HP3"       })
    aadd(aEDICAO,{{ || NIL                                         },NIL         })
    aadd(aEDICAO,{{ || qgetx(-1,0,@fHIST_COMP,"@!@S58")            },"HIST_COMP" })
    aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   LOTE->(qpublicfields())

   iif(cOPCAO=="I",LOTE->(qinitfields()),LOTE->(qcopyfields()))

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
      if eval ( bESCAPE ) ; LOTE->(qreleasefields()) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   if cOPCAO $ "ID"
      dULT_DATA := fDATA_LANC
   endif

   if ! lCONF ; return ; endif

   // GRAVACAO ______________________________________________________________

   if LOTE->(qrlock()) .and. LOTE->(iif(cOPCAO=="I",qappend(),qrlock()))
      if cOPCAO == "I"
         fNUM_LOTE  := cLOTE
//       fDATA_LANC := dDATA_LANC
      endif

      LOTE->(qreplacefields())
      LOTE->(qunlock())

   else

      iif(cOPCAO=="I",qm1(),qm2())

   endif

   i_ver_tots()

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
               //if CONFIG->Partida == "N"
               //   qmensa("Lan‡amentos em Partida Simples n„o s„o Permitidos !","B")
               //   return .F.
               //endif
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

              if cLANCFILIAL != "S" .or. (cINIDB $ "12" .and. cINICR $ "12")
                 cFILIAL := space(4)
                 qrsay(XNIVEL+2,space(4))
                 qrsay(XNIVEL+3,space(32))
                 XNIVEL+=2
                 if cLANCCENT != "S" .or. (cINIDB $ "12" .and. cINICR $ "12")
                    cCENTRO := space(10)
                    qrsay(XNIVEL+2,space(10))
                    qrsay(XNIVEL+3,space(32))
                    XNIVEL+=2
                 endif
              endif

         case cCAMPO == "FILIAL"
              if ! FILIAL->(dbseek(fFILIAL))
                 qmensa("Filial n„o cadastrada !","B")
                 return .F.
              endif
              qrsay(XNIVEL+1,left(FILIAL->Razao,32))
              if cLANCCENT != "S" .or. (cINIDB $ "12 " .and. cINICR $ "12 ")
                 cCENTRO := space(10)
                 qrsay(XNIVEL+2,space(10))
                 qrsay(XNIVEL+3,space(32))
                 XNIVEL+=2
              endif
         case cCAMPO == "CENTRO"
              if cLANCCENT == "S"
                 if ! cINIDB $ "12" .or. ! cINICR $ "12"
                    if ! CCUSTO->(dbseek(cCENTRO))
                       qmensa("Centro de Custo n„o cadastrado !","B")
                       return .F.
                    endif
                    qrsay(XNIVEL+1,left(CCUSTO->Descricao,32))
                 endif
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
      if LOTE->(qrlock()) .and. CONFIG->(qrlock()) .and. LOTE->(ct_trava_prop(Cont_db,Cont_cr))
         i_propaga("E")
         LOTE->(dbdelete())
      else
         qm3()
      endif
      dbunlockall()
   endif
return

/////////////////////////////////////////////////////////////////////////////
// VIEW PADRAO PARA PLANO DE CONTAS SOMENTE PARA ESTE PROGRAMA ______________

function view_plllanc (XX,YY,ZZ)
   PLAN->(dbSetFilter({|| right(PLAN->Codigo,5) <> " "}, 'right(PLAN->Codigo,5) <> " "'))

   PLAN->(qview(XX,YY,@ZZ,"@K@R 99999-9",NIL,.T.,NIL,;
         {{"ct_convcod(Codigo)/C¢digo"     ,1},;
          {"Descricao/Descri‡„o"           ,2},;
          {"ct_convcod(Reduzido)/Cod.Red." ,3}},;
          "C",{"keyb(Reduzido)",NIL,NIL,NIL}))

   PLAN->(dbClearFilter())
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA VERIFICAR VALOR DO LOTE (DB/CR) ______________________________
function i_ver_tots

   nCREDITO := nDEBITO := 0
   LOTE->(dbsetorder(1))
   nREC := LOTE->(recno())
   LOTE->(dbgotop())
   LOTE->(dbseek(cLOTE))

   while ! LOTE->(eof()) .and. LOTE->Num_lote == cLOTE

      qgirabarra()

      do case
         case empty(LOTE->Cont_db) .and. ! empty(LOTE->Cont_cr)
              nCREDITO += LOTE->Valor
         case ! empty(LOTE->Cont_db) .and. empty(LOTE->Cont_cr)
              nDEBITO += LOTE->Valor
         case ! empty(LOTE->Cont_db) .and. ! empty(LOTE->Cont_cr)
              nDEBITO += LOTE->Valor
              nCREDITO += LOTE->Valor
      endcase

      LOTE->(dbskip())

   enddo

   qsay(07,19,transform(nCREDITO,"@R 9999,999,999.99"))
   qsay(07,62,transform(nDEBITO,"@R 9999,999,999.99"))

   LOTE->(Dbgoto(nREC))

return

/////////////////////////////////////////////////////////////////////////////
// GRAVACAO DOS LANCAMENTOS NOS ARQUIVOS CONTABEIS __________________________

static function i_gravacao
   local lENTROU := .F.

   LOTE->(dbsetorder(1))
   LOTE->(dbgotop())
   LOTE->(dbseek(cLOTE))

   qmensa("Aguarde... Processando Inclus„o...")

   do while ! LOTE->(eof()) .and. LOTE->Num_lote == cLOTE
      if ct_trava_prop(LOTE->Cont_db,LOTE->Cont_cr) .and. CONFIG->(qrlock()) .and. LANC->(qappend())
         qlbloc(9,06,"B203B","QBLOC.GLO")
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
            replace LANC->Cod_fat   with LOTE->Cod_fat

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

            lENTROU := .T.

            i_propaga("I")

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
      lVOLTA := .T.
      qlbloc(5,0,"B203A","QBLOC.GLO")
   endif

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAR OS VALORES DO LOTE (DB/CR) ___________________________
function mostra
   qsay(07,19,transform(nCREDITO,"@R 9999,999,999.99"))
   qsay(07,62,transform(nDEBITO,"@R 9999,999,999.99"))
return

/////////////////////////////////////////////////////////////////////////////
// PROPAGACAO GERAL DE SALDO ________________________________________________

static function i_propaga ( cOPT )

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
