/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE CONTABILIDADE
// OBJETIVO...: APURACAO DE DIFERENCAS
// ANALISTA...: LUCINEIDE VILAR POSSEBOM
// PROGRAMADOR: A MESMA
// INICIO.....: JUNHO  DE 1998
// OBS........:
// ALTERACOES.:
function ct406

// INICIALIZACOES ___________________________________________________________

#include "inkey.ch"

private aEDICAO := {}
private nVALOR  := 0
private cLANCFILIAL:= CONFIG->Lancfilial
private cLANCCENT  := CONFIG->Lanccent
private cPARTIDA   := CONFIG->Partida
private cINIDB
private cINICR

PLAN->(dbsetorder(3))  // MANTEM A ORDEM EM CODIGO REDUZIDO P/ CHECK...

qlbloc(5,0,"B406A","QBLOC.GLO")

qmensa("ESC - Cancela...")

i_edicao()

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA ____________________________________

static function i_edicao

   local bESCAPE := {||(XNIVEL==1.and.!XFLAG).or.;
                       (nVALOR == 0 .and. XNIVEL==1 .and. !XFLAG .or. nVALOR== 0 .and. XNIVEL==1 .and. Lastkey()==27) .or.;
                       (XNIVEL==1.and.lastkey()==27)}

   aadd(aEDICAO,{{ || qgetx(-1,0, @nVALOR ,"@R 999,999,999.99" ) },"VALOR" })
   aadd(aEDICAO,{{ || lCONF := qconf("Confirma Verifica‡„o ?"  ) },NIL     })
   
   XNIVEL := 1
   XFLAG  := .T.
   lCONF  := .F.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO[XNIVEL,1] )
      if eval ( bESCAPE ) ; return .F. ; endif
      if ! i_critica1( aEDICAO[XNIVEL,2] ) ; qmensa() ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   if ! lCONF ; return ; endif

   verifica()

return .T.

/////////////////////////////////////////////////////////////////////////////
// CRITICAS NA DESCIDA ______________________________________________________

static function i_critica1 ( cCAMPO )
   local cBLOQ
   iif( cCAMPO == NIL , cCAMPO := "" , NIL )

   if XFLAG

      do case

         case cCAMPO == "VALOR"
              if empty(nVALOR) ; return .f. ; endif

      endcase

   endif

return .T.

////////////////////////////////////////////////////////////////////
// FUNCAO UTILIZADA PARA VERIFICAR VALORES PARA APURACAO ____________
function verifica
  LANC->(Dbgotop())
  do while ! LANC->(eof())
     if LANC->Valor == nVALOR
        LANC->(qpublicfields())
        LANC->(qcopyfields())
        i_altera()
     endif
     LANC->(Dbskip())
  enddo
return

////////////////////////////////////////////////////////////////////
// FUNCAO UTILIZADA PARA ALTERAR LANCAMENTOS _______________________

function i_altera

   local bESCAPE := {||empty(fDATA_LANC).or.(XNIVEL==1.and.!XFLAG).or.;
                       (XNIVEL==1.and.lastkey()==K_ESC)}
   private aEDICAO1 := {}

    qlbloc(6,6,"B406B","QBLOC.GLO")

    // MONTA DADOS NA TELA ___________________________________________________

    XNIVEL := 1

    qrsay(XNIVEL++,LANC->Data_lanc    )
    qrsay(XNIVEL++,LANC->Num_doc      )
    qrsay(XNIVEL++,LANC->Valor   , "@E 9,999,999,999.99" )
    qrsay(XNIVEL++,LANC->Arq          )
    qrsay(XNIVEL++,LANC->Cont_db , "@R 99999-9" ) ; PLAN->(dbseek(LANC->Cont_db))
    qrsay(XNIVEL++,iif(!empty(PLAN->Reduzido),PLAN->Descricao,space(40))    )
    qrsay(XNIVEL++,LANC->Cont_cr , "@R 99999-9" ) ; PLAN->(dbseek(LANC->Cont_cr))
    qrsay(XNIVEL++,iif(!empty(PLAN->Reduzido),PLAN->Descricao,space(40))    )
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

    // PREENCHE O VETOR DE EDICAO ____________________________________________

    aadd(aEDICAO1,{{ || qgetx(-1,0,@fDATA_LANC)                     },"DATA_LANC" })
    aadd(aEDICAO1,{{ || qgetx(-1,0,@fNUM_DOC,"@!")                  },"NUM_DOC"   })
    aadd(aEDICAO1,{{ || qgetx(-1,0,@fVALOR,"@E 9,999,999,999.99"   )},"VALOR"     })
    aadd(aEDICAO1,{{ || qgetx(-1,0,@fARQ,"@!")                      },"ARQ"       })
    aadd(aEDICAO1,{{ || view_pllanc(-1,0,@fCONT_DB)                 },"CONT_DB"   })
    aadd(aEDICAO1,{{ || NIL                                         },NIL         })
    aadd(aEDICAO1,{{ || view_pllanc(-1,0,@fCONT_CR)                 },"CONT_CR"   })
    aadd(aEDICAO1,{{ || NIL                                         },NIL         })
    aadd(aEDICAO1,{{ || view_filial(-1,0,@fFILIAL,"@K 9999")        },"FILIAL"    })
    aadd(aEDICAO1,{{ || NIL                                         },NIL         })
    aadd(aEDICAO1,{{ || view_ccusto(-1,0,@cCENTRO,"@!",NIL,cLANCCENT=="S" .and. (! cINIDB $ "12" .or. ! cINICR $ "12"))},"CENTRO"})
    aadd(aEDICAO1,{{ || NIL                                         },NIL         })
    aadd(aEDICAO1,{{ || view_hist(-1,0,@fHP1,"@K 999")              },"HP1"       })
    aadd(aEDICAO1,{{ || NIL                                         },NIL         })
    aadd(aEDICAO1,{{ || view_hist(-1,0,@fHP2,"@K 999")              },"HP2"       })
    aadd(aEDICAO1,{{ || NIL                                         },NIL         })
    aadd(aEDICAO1,{{ || view_hist(-1,0,@fHP3,"@K 999")              },"HP3"       })
    aadd(aEDICAO1,{{ || NIL                                         },NIL         })
    aadd(aEDICAO1,{{ || qgetx(-1,0,@fHIST_COMP,"@!@S58")            },"HIST_COMP" })
    aadd(aEDICAO1,{{ || lCONF := qconf("Confirma altera‡„o ?") },NIL})

    XNIVEL := 1
    XFLAG  := .T.
    lCONF  := .F.

    do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO1)
       eval ( aEDICAO1 [XNIVEL,1] )
       if eval ( bESCAPE ) ; LANC->(qreleasefields()) ; return ; endif
       if ! i_critica( aEDICAO1[XNIVEL,2] ) ; loop ; endif
       iif ( XFLAG , XNIVEL++ , XNIVEL-- )
    enddo

   // GRAVACAO ______________________________________________________________

   if lCONF

      if ct_trava_prop(fCONT_DB,fCONT_CR) .and. CONFIG->(qrlock()) .and. LANC->(qrlock())

         i_propagacao("A")

         LANC->(qreplacefields())

      endif

   endif

   dbunlockall()

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
              if cLANCCENT != "S" .or. (cINIDB $ "12" .and. cINICR $ "12")
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
                 fHP2 := fHP3 := (space(3))
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

return
