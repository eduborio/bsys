/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO COMERCIAL
// OBJETIVO...: MANUTENCAO DE SITUACAO TRIBUTARIA
// ANALISTA...: EDUARDO AUGUSTO BORIO
// PROGRAMADOR: EDUARDO AUGUSTO BORIO
// INICIO.....: OUTUBRO DE 2002
// OBS........:
// ALTERACOES.:

function cl118
COND->(qview({{"Cod_cli/Cod. "           ,1},;
              {"left(Cliente,35)/Razao"  ,2},;
              {"iTipoDoc()/Tipo .Doc"    ,0}},"P",;
             {NIL,"c118a",NIL,NIL},;
              NIL,q_msg_acesso_usr()))

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function c118a

   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO $ XUSRA
      qlbloc(7,0,"B118A","QBLOC.GLO",1)
      qmensa(qabrev(cOPCAO,"IA",{"Inclus„o... <ESC - Cancela>","Altera‡„o... <ESC - Cancela>"}))
      i_edicao()
   endif

   setcursor(nCURSOR)

return ""


function iTipoDoc
local cDESC := space(15)

TIPO_DOC->(Dbseek(COND->Tipo_doc))
cDESC := left(TIPO_DOC->Descricao,15)

return cDesc

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA ____________________________________

static function i_edicao
   local lCONF   := .F.
   local aEDICAO := {}
   local bESCAPE := {||(XNIVEL==1.and.!XFLAG).or. Lastkey()==27}

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"

      XNIVEL := 1

      qrsay ( XNIVEL++ , COND->Cod_cli                  )
      qrsay ( XNIVEL++ , left(COND->Cliente,35)         )
      qrsay ( XNIVEL++ , COND->Tipo_doc                 ) ; TIPO_DOC->(Dbseek(COND->Tipo_doc))
      qrsay ( XNIVEL++ , left(TIPO_DOC->Descricao,35)   )
      qrsay ( XNIVEL++ , COND->N_Parc,"@R 9"               )
      qrsay ( XNIVEL++ , COND->Dias1 ,"@R 999"             )
      qrsay ( XNIVEL++ , COND->Dias2 ,"@R 999"             )
      qrsay ( XNIVEL++ , COND->Dias3 ,"@R 999"             )
      qrsay ( XNIVEL++ , COND->Dias4 ,"@R 999"             )
      qrsay ( XNIVEL++ , COND->Dias5 ,"@R 999"             )
      qrsay ( XNIVEL++ , COND->Dias6 ,"@R 999"             )
      qrsay ( XNIVEL++ , COND->Dias7 ,"@R 999"             )

   endif
   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || view_cli(-1,0,@fCOD_CLI,"99999")        },"COD_CLI"  })
   aadd(aEDICAO,{{ || NIL                                     }, NIL       })
   aadd(aEDICAO,{{ || view_doc(-1,0,@fTIPO_DOC,"99")          },"TIPO_DOC" })
   aadd(aEDICAO,{{ || NIL                                     }, NIL       })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fN_PARC,"@R 9")             },"N_PARC"  })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDIAS1,"@R 999")            },"NADA"  })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDIAS2,"@R 999")            },"NADA"  })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDIAS3,"@R 999")            },"NADA"  })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDIAS4,"@R 999")            },"NADA"  })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDIAS5,"@R 999")            },"NADA"  })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDIAS6,"@R 999")            },"NADA"  })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDIAS7,"@R 999")            },"NADA"  })

   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   COND->(qpublicfields())
   iif(cOPCAO=="I",COND->(qinitfields()),COND->(qcopyfields()))

   XNIVEL := 1
   XFLAG  := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; COND->(qreleasefields()) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif

   if CONFIG->(qrlock()) .and. COND->(iif(cOPCAO=="I",qappend(),qrlock()))

      COND->(qreplacefields())
      COND->(dbgotop())

   else
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

      case cCAMPO == "COD_CLI"

           if empty(fCOD_CLI) ; return .F. ; endif

           qrsay(XNIVEL,fCOD_CLI:=strzero(val(fCOD_CLI),5))
           if ! CLI1->(dbseek(fCOD_CLI))
              qmensa("Cliente n„o encontrado !","B")
              return .F.
           endif

           if cOPCAO == "I"
              if COND->(dbseek(fCOD_CLI))
                 qmensa("Condicoes de Pagto pra este Cliente, ja existe !","B")
                 return .F.
              endif
           endif

           qrsay(XNIVEL+1,left(CLI1->Razao,40))
           fCLIENTE := CLI1->Razao

      case cCAMPO == "TIPO_DOC"

           if empty(fTIPO_DOC) ; return .F. ; endif

           qrsay(XNIVEL,fTIPO_DOC:=strzero(val(fTIPO_DOC),2))
           if ! TIPO_DOC->(dbseek(fTIPO_DOC))
              qmensa("Tipo de Documento nao encontrado !","B")
              return .F.
           endif

           qrsay(XNIVEL+1,left(TIPO_DOC->Descricao,40))


   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXCLUIR TRANSPORTADORA _______________________________________

static function i_exclusao
   if qconf("Confirma exclus„o desta Condicao de Pagamento ?")
      if COND->(qrlock())
         COND->(dbdelete())
         COND->(qunlock())
      else
         qm3()
      endif
   endif
return
