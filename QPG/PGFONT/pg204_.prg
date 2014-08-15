/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE CONTAS A PAGAR/RECEBER
// OBJETIVO...: MANUTENCAO DE ADIANTAMENTO A FUNCIONARIOS
// ANALISTA...:
// PROGRAMADOR: LUCINEIDE VILAR POSSEBOM
// INICIO.....: FEVEREIRO DE 1997
// OBS........:
// ALTERACOES.:

function pg204

CCUSTO->(Dbsetorder(4))

ADIANT->(qview({{"Codigo/C¢digo"                ,1},;
              {"dtoc(Data_adian)/Adiantamento"  ,2},;
              {"c204a()/Funcionario"            ,0}},"P",;
              {NIL,"c204b",NIL,NIL},;
               NIL,q_msg_acesso_usr()))

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA LOCALIZAR FUNCIONARIO ________________________________________
function c204a
  local cNOME := space(20)
  FUN->(Dbseek(ADIANT->(Codi_fun)))
  cNOME := left(FUN->Nome,20)
return cNOME

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function c204b
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))
   if cOPCAO $ XUSRA
      qlbloc(10,2,"B204A","QBLOC.GLO",1)
      qmensa(qabrev(cOPCAO,"IA",{"Inclus„o... <ESC - Cancela>","Altera‡„o... <ESC - Cancela>"}))
      i_edicao()
   endif
   setcursor(nCURSOR)
return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA ____________________________________

static function i_edicao
   local lCONF   := .F.
   local aEDICAO := {}
   local bESCAPE := {||empty(fDATA_ADIAN).or.(XNIVEL==2.and.!XFLAG).or.!empty(fDATA_ADIAN).and.XNIVEL==2.and.Lastkey()==27.or.;
                       (XNIVEL==2.and.cOPCAO=="A".and.!XFLAG)}

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"

      XNIVEL := 1
      qrsay ( XNIVEL++ , ADIANT->Codigo           )
      qrsay ( XNIVEL++ , dtoc(ADIANT->Data_adian ))
      qrsay ( XNIVEL++ , ADIANT->Codi_fun        ) ; FUN->(Dbseek(ADIANT->Codi_fun))
      qrsay ( XNIVEL++ , left(FUN->Nome,46)      )
      qrsay ( XNIVEL++ , ADIANT->Ccusto          ) ; CCUSTO->(Dbseek(ADIANT->Ccusto))
      qrsay ( XNIVEL++ , left(CCUSTO->Descricao,42))
      qrsay ( XNIVEL++ , ADIANT->Filial          ) ; FILIAL->(Dbseek(ADIANT->Filial))
      qrsay ( XNIVEL++ , left(FILIAL->Razao,42)  )
      qrsay ( XNIVEL++ , ADIANT->Tipo            ) ; TIPOCONT->(dbseek(ADIANT->Tipo))
      qrsay ( XNIVEL++,  left(TIPOCONT->Descricao,20))
      qrsay ( XNIVEL++ , transform(ADIANT->Valor, "@e 999,999.99"))

   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || NIL                                                 },"CODIGO"    })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDATA_ADIAN   ,"@D")                    },"DATA_ADIAN"})
   aadd(aEDICAO,{{ || view_fun(-1,0,@fCODI_FUN)                           },"CODI_FUN"   })
   aadd(aEDICAO,{{ || NIL                                                 },NIL         })
   aadd(aEDICAO,{{ || view_ccusto(-1,0,@fCCUSTO)                          },"CCUSTO"    })
   aadd(aEDICAO,{{ || NIL                                                 },NIL         })
   aadd(aEDICAO,{{ || view_filial(-1,0,@fFILIAL)                          },"FILIAL"    })
   aadd(aEDICAO,{{ || NIL                                                 },NIL         })
   aadd(aEDICAO,{{ || view_tipo(-1,0,@fTIPO)                              },"TIPO"      })
   aadd(aEDICAO,{{ || NIL                                                 },NIL         })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fVALOR   ,"@E 999,999.99")              },"VALOR"     })

   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   ADIANT->(qpublicfields())
   iif(cOPCAO=="I",ADIANT->(qinitfields()),ADIANT->(qcopyfields()))

   XNIVEL  := 2
   XFLAG   := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; ADIANT->(qreleasefields()) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif

   if CONFIG->(qrlock()) .and. ADIANT->(iif(cOPCAO=="I",qappend(),qrlock()))

      // AQUI INCREMENTA CODIGO DO ADIANTECEDOR _______________________________

      if cOPCAO == "I"
         replace CONFIG->Cod_adian with CONFIG->Cod_adian + 1
         qrsay ( 1 , fCODIGO := strzero(CONFIG->Cod_adian,5) )
         qmensa("C¢digo Gerado: "+fCODIGO,"B")
      endif

      // AGORA GRAVA E DESTRAVA ARQUIVO _____________________________________

      ADIANT->(qreplacefields())

   else

      if empty(ADIANT->Codigo) .and. empty(ADIANT->Razao) .and. empty(ADIANT->Cgccpf)
         ADIANT->(dbdelete())
      endif

      iif(cOPCAO=="I",qm1(),qm2())

   endif

   dbunlockall()

   if cOPCAO == "I" ; keyboard "I" ; endif

return

/////////////////////////////////////////////////////////////////////////////
// CRITICA DE EDICAO ________________________________________________________

static function i_critica ( cCAMPO )

   if ! XFLAG ; return .T. ; endif

   do case

      case cCAMPO == "CODI_FUN"

           if ! FUN->(dbseek(fCODI_FUN:=strzero(val(fCODI_FUN),6)))
              qmensa("Funcionario n„o encontrado !","B")
              return .F.
           endif

           qrsay(XNIVEL+1,left(FUN->Nome,46))

      case cCAMPO == "CCUSTO"

           qrsay(XNIVEL,fCCUSTO:=strzero(val(fCCUSTO),4))

           if ! CCUSTO->(dbseek(fCCUSTO))
              qmensa("Centro de Custo n„o encontrado !","B")
              return .F.
           endif

           qrsay(XNIVEL+1,left(CCUSTO->Descricao,42))

      case cCAMPO == "FILIAL"

           qrsay(XNIVEL,fFILIAL:=strzero(val(fFILIAL),4))

           if ! FILIAL->(dbseek(fFILIAL))
              qmensa("Filial n„o encontrada !","B")
              return .F.
           endif

           qrsay(XNIVEL+1,left(FILIAL->Razao,42))

      case cCAMPO == "TIPO"

           if empty(fTIPO) ; return .F. ; endif

           qrsay(XNIVEL,fTIPO)

           if ! TIPOCONT->(dbseek(fTIPO))
              qmensa("Tipo Contabil n„o encontrado !","B")
              return .F.
           endif

           qrsay(XNIVEL+1,left(TIPOCONT->Descricao,20))

      case cCAMPO == "VALOR"
           if empty(fVALOR) ; return .F. ; endif

   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXCLUIR ADIANTAMENTO _________________________________________

static function i_exclusao
   if qconf("Confirma exclus„o deste Adiantamento  ?")
      if ADIANT->(qrlock())
         ADIANT->(dbdelete())
         ADIANT->(qunlock())
      else
         qm3()
      endif
   endif
return

