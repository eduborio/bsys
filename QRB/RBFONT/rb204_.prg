/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE CONTAS A RECEBER/PAGAR
// OBJETIVO...: INCLUSAO DE CONTAS A RECEBER
// ANALISTA...: EDUARDO BORIO
// PROGRAMADOR: EDUARDO BORIO
// INICIO.....: Fevereiro DE 2008
// OBS........:
// ALTERACOES.:
function rb204


// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________


// VIEW INICIAL _____________________________________________________________

CRED_CLI->(qview({{"Data_emiss/Emissao"            ,2},;
                 {"Cod_cli/Codigo"            , 3},;
                 {"left(CRED_CLI->Cliente,22)/Cliente",4},;
                 {"f204c()/Valor"        ,0},;
                 {"Num_fatura/Nota Fiscal"    ,5}},"P",;
                 {NIL,"f204a",NIL,NIL},;
                 NIL,"ESC/ALT-P/ALT-O/<I>nc/<A>lt/<E>xc/<C>on/<D>esdobra/<P>arcial"))

//////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAGEM DE VALOR COM PICTURE ________________________________

function f204c
return(transform(CRED_CLI->Valor,"@E 9999999.99"))

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function f204a
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO $ XUSRA
      qlbloc(05,02,"B204A","QBLOC.GLO",1)
      qmensa(qabrev(cOPCAO,"IA",{"Inclus„o... <ESC - Cancela>","Altera‡„o... <ESC - Cancela>"}))
      i_edicao()
   endif

   setcursor(nCURSOR)
return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA ____________________________________

static function i_edicao
   local aEDICAO := {}
   local bESCAPE := {||XNIVEL==1.and.!XFLAG}

   // MONTA DADOS NA TELA ___________________________________________________

   if ! cOPCAO $ "I"
      XNIVEL := 1
      qrsay ( XNIVEL++ , CRED_CLI->Codigo       )
      qrsay ( XNIVEL++ , CRED_CLI->Cod_cli      ) ; CLI1->(dbseek(CRED_CLI->Cod_cli))
      qrsay ( XNIVEL++ , left(CLI1->Razao,40))



      qrsay ( XNIVEL++ , CRED_CLI->Data_emiss   )

      qrsay ( XNIVEL++ , CRED_CLI->Cod_cli      ) ; FILIAL->(dbseek(CRED_CLI->Filial))
      qrsay ( XNIVEL++ , left(FILIAL->Razao,40))


      qrsay ( XNIVEL++ , transform(CRED_CLI->Valor,"@E 9,999,999.99"     ))
      qrsay ( XNIVEL++ , CRED_CLI->Num_Fatura       )

   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || NIL }                                         ,NIL         })  // codigo nao pode ser editado
   aadd(aEDICAO,{{ || view_cli(-1,0,@fCOD_CLI                 ) } ,"COD_CLI"     })
   aadd(aEDICAO,{{ || NIL                                         } ,NIL         })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDATA_EMISS                   ) } ,"DATA_EMISS"})
   aadd(aEDICAO,{{ || view_filial(-1,0,@fFILIAL                 ) } ,"FILIAL"    })
   aadd(aEDICAO,{{ || NIL                                         } ,NIL         })

   aadd(aEDICAO,{{ || qgetx(-1,0,@fVALOR    ,"@E 9,999,999.99"  ) } ,"VALOR"     })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fNUM_FATURA,"@!"                  ) } ,"FATURA"    })
   aadd(aEDICAO,{{ || lCONF1 := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})


   // INICIALIZACAO DA EDICAO _______________________________________________

   CRED_CLI->(qpublicfields())
   iif(cOPCAO=="I",CRED_CLI->(qinitfields()),CRED_CLI->(qcopyfields()))

   XNIVEL := 2
   XFLAG  := .T.
   lCONF1 := .F.

   if cOPCAO == "I"
      fCODIGO := strzero(CONFIG->Cod_cred + 1,5)
   endif

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; CRED_CLI->(qreleasefields()) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   if CRED_CLI->(iif(cOPCAO=="I",qappend(),qrlock()))
      CRED_CLI->(qreplacefields())
      CRED_CLI->(qunlock())
   else
      iif(cOPCAO=="I",qm1(),qm2())
   endif
   if CONFIG->(qrlock())
      replace CONFIG->Cod_cred with val(fCODIGO)
   endif



return

/////////////////////////////////////////////////////////////////////////////
// CRITICAS NA DESCIDA ______________________________________________________

static function i_critica ( cCAMPO )
   iif ( cCAMPO == NIL , cCAMPO := "" , NIL )
   do case
      case cCAMPO == "COD_CLI"
           qrsay(XNIVEL,fCOD_CLI:=strzero(val(fCOD_CLI),5))
           if ! CLI1->(dbseek(fCOD_CLI)) .and. XFLAG
              qmensa("Cliente n„o Cadastrado !","B")
              return .F.
           else
              qrsay(XNIVEL+1,left(CLI1->Razao,40))
           endif
           fCLIENTE := CLI1->Razao

      case cCAMPO == "FILIAL"
           qrsay(XNIVEL,fFILIAL:=strzero(val(fFILIAL),4))
           if ! FILIAL->(dbseek(fFILIAL))
              qmensa("Filial n„o Cadastrada !","B")
              return .F.
           else
              qrsay(XNIVEL+1,left(FILIAL->Razao,40))
           endif


      case cCAMPO == "DATA_EMISS"
           if empty(fDATA_EMISS) ; return .F. ; endif

      case cCAMPO == "VALOR"
           if empty(fVALOR) ; return .F. ; endif


      case cCAMPO == "FATURA"
           if empty(fNUM_FATURA)
              qmensa("Campo obrigat¢rio...","B")
              return .F.
           endif

   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXCLUIR CONTAS A RECEBER _______________________________________

static function i_exclusao

   if qconf("Confirma exclus„o deste Credito ?")

      if CRED_CLI->(qrlock())
         CRED_CLI->(dbdelete())
         CRED_CLI->(qunlock())
      else
         qm3()
      endif

   endif
return


