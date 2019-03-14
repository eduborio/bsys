/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE CONTABILIDADE
// OBJETIVO...: MANUTENCAO DE LANCAMENTOS
// ANALISTA...: LUIS ANTONIO ORLANDO PEREIRA
// PROGRAMADOR: O MESMO
// INICIO.....: JUNHO DE 1995
// OBS........:
// ALTERACOES.:
function ct202

#include "inkey.ch"
#include "setcurs.ch"

// DECLARACAO DE VARIAVEIS __________________________________________________

if empty(CONFIG->Exercicio) .or. len(alltrim(CONFIG->Exercicio)) < 4
    qmensa("Sistema sem o ano do Exerc¡cio informado !! Execute a op‡„o 803 !")
    return
endif

private dDATA_LANC := ctod("")
private aEDICAO    := {}
private cLANCCENT  := CONFIG->Lanccent
private cLANCFILIAL:= CONFIG->Lancfilial
private cPARTIDA   := CONFIG->Partida
private cCENTRO    := space(10)
private cINIDB
private cINICR
private lCONF
private fFILIAL     := space(10)

// PREENCHE O VETOR DE EDICAO ____________________________________________

aadd(aEDICAO,{{ || qgetx(-1,0,@fDATA_LANC)                     },"DATA_LANC" })
aadd(aEDICAO,{{ || qgetx(-1,0,@fNUM_DOC,"@!")                  },"NUM_DOC"   })
aadd(aEDICAO,{{ || qgetx(-1,0,@fVALOR,"@E 9,999,999,999.99"   )},"VALOR"     })
aadd(aEDICAO,{{ || qgetx(-1,0,@fARQ,"@!")                      },"ARQ"       })
aadd(aEDICAO,{{ || view_pllanc(-1,0,@fCONT_DB)                 },"CONT_DB"   })
aadd(aEDICAO,{{ || NIL                                         },NIL         })
aadd(aEDICAO,{{ || view_pllanc(-1,0,@fCONT_CR)                 },"CONT_CR"   })
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

PLAN->(dbsetorder(3))  // MANTEM A ORDEM EM CODIGO REDUZIDO P/ CHECK...

/////////////////////////////////////////////////////////////////////////////
// LANCAMENTOS IMEDIATOS ____________________________________________________

LANC->(qview({{"Data_lanc/Data"                             ,1},;
             {"transform(Cont_db,'@R 99999-9')/Ct.Db."      ,2},;
             {"transform(Cont_cr,'@R 99999-9')/Ct.Cr."      ,3},;
             {"Num_lanc/Lanc."                              ,4},;
             {"i_hist202()/Hist."                           ,0},;
             {"transform(Valor,'@E 9,999,999,999.99')/Valor",0},;
             {"Num_Doc /No. Doc."                           ,13}},;
             "05002079",;
             {NIL,"f202a","f202b",NIL},;
             NIL,q_msg_acesso_usr()+"/<D>uplica/<H>ist/E<Q>uil"))
return

/////////////////////////////////////////////////////////////////////////////
// FORMATA O HISTORICO DO LANCAMENTO PARA O VIEW ____________________________

function i_hist202
   local cRET := ""
   HIST->(dbseek(LANC->Hp1)) ; cRET += alltrim(HIST->Descricao) + " "
   HIST->(dbseek(LANC->Hp2)) ; cRET += alltrim(HIST->Descricao) + " "
   HIST->(dbseek(LANC->Hp3)) ; cRET += alltrim(HIST->Descricao) + " "
return pad(ltrim(alltrim(cRET)+" "+LANC->Hist_comp),25)

/////////////////////////////////////////////////////////////////////////////
// FUNCAO DE CONTROLE PRINCIPAL ANTES DE PROCESSAR A TECLA ACIONADA _________

function f202a
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))

   iif(cOPCAO=="H",ct_con_hist(),)

   iif(cOPCAO=="Q",ct303(),)
   
   iif(cOPCAO=="Z",i_troca_plan(),)

   if cOPCAO $ XUSRA  + "D"
	  qlbloc(6,6,"B202B","QBLOC.GLO",1)
      i_edicao()
   endif
   setcursor(nCURSOR)
return ""

/////////////////////////////////////////////////////////////////////////////
// ATUALIZACAO DE TELA A CADA MOVIMENTACAO DO VIEW E/OU REFRESH _____________

function f202b
   PLAN->(dbseek(LANC->Cont_db))
   qsay(21,16,iif(!empty(PLAN->Reduzido),left(PLAN->Descricao,35),space(35)))
   PLAN->(dbseek(LANC->Cont_cr))
   qsay(22,16,iif(!empty(PLAN->Reduzido),left(PLAN->Descricao,35),space(35)))
   qsay(21,70,LANC->Num_doc)
   qsay(22,66,LANC->Num_lote)
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA ____________________________________

static function i_edicao
   local dULT_DATA := ctod("")
   local bESCAPE := {||empty(fDATA_LANC).or.(XNIVEL==1.and.!XFLAG).or.;
                       (XNIVEL==1.and.lastkey()==K_ESC)}

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"
      XNIVEL := 1
      qrsay(XNIVEL++,LANC->Data_lanc                                       )
      qrsay(XNIVEL++,LANC->Num_doc                                         )
      qrsay(XNIVEL++,LANC->Valor   , "@E 9,999,999,999.99"                 )
      qrsay(XNIVEL++,LANC->Arq                                             )
      qrsay(XNIVEL++,LANC->Cont_db , "@R 99999-9"                          ) ; PLAN->(dbseek(LANC->Cont_db))
      qrsay(XNIVEL++,iif(!empty(PLAN->Reduzido),PLAN->Descricao,space(40)) )
      qrsay(XNIVEL++,LANC->Cont_cr , "@R 99999-9"                          ) ; PLAN->(dbseek(LANC->Cont_cr))
      qrsay(XNIVEL++,iif(!empty(PLAN->Reduzido),PLAN->Descricao,space(40)) )
      qrsay(XNIVEL++,LANC->Filial                                          ) ; FILIAL->(dbseek(LANC->Filial))
      qrsay(XNIVEL++,left(FILIAL->Razao,32)                                )
      qrsay(XNIVEL++,LANC->Centro                                          ) ; CCUSTO->(dbseek(LANC->Centro))
      qrsay(XNIVEL++,left(CCUSTO->Descricao,32)                            )
      qrsay(XNIVEL++,LANC->Hp1                                             ) ; HIST->(dbseek(LANC->Hp1))
      qrsay(XNIVEL++,LEFT(HIST->Descricao,50)                              )
      qrsay(XNIVEL++,LANC->Hp2                                             ) ; HIST->(dbseek(LANC->Hp2))
      qrsay(XNIVEL++,LEFT(HIST->Descricao,50)                              )
      qrsay(XNIVEL++,LANC->Hp3                                             ) ; HIST->(dbseek(LANC->Hp3))
      qrsay(XNIVEL++,LEFT(HIST->Descricao,50)                              )
      qrsay(XNIVEL++,left(LANC->Hist_comp,58)                              )
   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif
   

   // CONTINUA EM LOOP SE FOR INCLUSAO ______________________________________

   if cOPCAO == "I"  // antes de entrar no loop inicializa as variaveis - depois nao
      LANC->(qpublicfields())
      LANC->(qinitfields())
   endif

   do while .T.

   // INICIALIZACAO DA EDICAO _______________________________________________

   if cOPCAO == "I" ; qlbloc(6,6,"B202B","QBLOC.GLO",1) ; endif

   qmensa()

   LANC->(qpublicfields())

   if cOPCAO != "I" ; LANC->(qcopyfields()) ; endif

   XNIVEL   := 1
   XFLAG    := .T.
   if cOPCAO == "I"
      fNUM_DOC := space(8)
      fVALOR   := 0
      fARQ     := space(4)
   endif

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

   // GRAVACAO ______________________________________________________________

   if lCONF

      if ct_trava_prop(fCONT_DB,fCONT_CR) .and. CONFIG->(qrlock()) .and. LANC->(iif(cOPCAO $ "ID",qappend(),qrlock()))

         i_propagacao(cOPCAO)

         if cOPCAO $ "ID"
            replace CONFIG->Num_lanc with CONFIG->Num_lanc + 1
            fNUM_LANC := strzero(CONFIG->Num_lanc,5)
         endif

         fCENTRO := cCENTRO

         LANC->(qreplacefields())

      else

         iif(cOPCAO $ "ID",qm1(),qm2())

      endif

   endif

   dbunlockall()

   if cOPCAO $ "I"
      loop
   else
      exit
   endif

   enddo

return

/////////////////////////////////////////////////////////////////////////////
// PROPAGACAO GERAL DE SALDO ________________________________________________

static function i_propagacao ( cOPT )

   do case

      // ATUALIZA SALDOS NA INCLUSAO E DUPLICACAO ___________________________

      case cOPT $ "I"
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

             if cLANCFILIAL == "S" .and. cOPCAO == "A"
                fFILIAL := "0001"
             else
                fFILIAL := "    "
                XNIVEL+=2
                if cLANCCENT != "S" .or. (cINIDB $ "12" .and. cINICR $ "12")
                   iif(cOPCAO=="I",fCENTRO := space(10),)
                   qrsay(XNIVEL+2,space(10))
                   qrsay(XNIVEL+3,space(32))
                   XNIVEL+=2
                endif
             endif

             // if cLANCFILIAL != "S" .or. (cINIDB $ "12" .and. cINICR $ "12")
             //    iif(cOPCAO=="I",fFILIAL := space(4),)
             //    qrsay(XNIVEL+2,space(4))
             //    qrsay(XNIVEL+3,space(32))
             //    XNIVEL+=2
             //    if cLANCCENT != "S" .or. (cINIDB $ "12" .and. cINICR $ "12")
             //       iif(cOPCAO=="I",fCENTRO := space(10),)
             //       qrsay(XNIVEL+2,space(10))
             //       qrsay(XNIVEL+3,space(32))
             //       XNIVEL+=2
             //    else
             //       iif(cOPCAO=="I",fCENTRO := space(10),)
             //    endif
             // else
             //    iif(cOPCAO=="I",fFILIAL := space(4),)
             // endif

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
              if empty(fHP2); fHP3:=(Space(3)); keyboard chr(13) ; endif
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

function view_pllanc (XX,YY,ZZ)
   PLAN->(dbSetFilter({|| right(PLAN->Codigo,4) <> "0000"}, 'right(PLAN->Codigo,4) <> "0000"'))

   PLAN->(qview(XX,YY,@ZZ,"@K@R 99999-9",NIL,.T.,NIL,;
         {{"Descricao/Descri‡„o"           ,2},;
          {"ct_convcod(Codigo)/C¢digo"     ,1},;
          {"ct_convcod(Reduzido)/Cod.Red." ,3}},;
          "C",{"keyb(Reduzido)",NIL,NIL,NIL}))

   PLAN->(dbClearFilter())
return


static function i_troca_plan()

	PLAN->(Dbsetorder(1))
	PLAN->(dbgotop())
	
	while ! PLAN->(eof())
	
		if PLAN->(qrlock())
			replace PLAN->descricao with i_trocachr(PLAN->Descricao)
			qmensa(PLAN->Descricao,"L")
		endif	
	
		PLAN->(dbskip())
	
	enddo
	
	PLAN->(dbcommit())

return

static function i_trocachr(cTROCADO)

   cTROCADO := strtran(cTROCADO,"Ç","C")
   cTROCADO := strtran(cTROCADO,"ç","C")
   cTROCADO := strtran(cTROCADO,"Ã","A")
   cTROCADO := strtran(cTROCADO,"Õ","O")
   cTROCADO := strtran(cTROCADO,"É","E")
   cTROCADO := strtran(cTROCADO,"‡","C")
   cTROCADO := strtran(cTROCADO,"c","C")
   cTROCADO := strtran(cTROCADO,"€","C")

return(cTROCADO)











