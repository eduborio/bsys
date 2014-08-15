/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE CONTAS A RECEBER
// OBJETIVO...: MANUTENCAO DE LANCAMENTOS DE CARTOES DE CREDITO
// ANALISTA...: LUCINEIDE VILAR POSSEBOM
// PROGRAMADOR: LUCINEIDE VILAR POSSEBOM
// INICIO.....: JUNHO DE 1998
// OBS........:
// ALTERACOES.:
function rb202

LANC_CAR->(qview({{"Data_comp/Compra"          ,4},;
                  {"Cod_cart/Nr."              ,2},;
                  {"c202b()/Cart„o"            ,0},;
                  {"Data_lib/Liberacao"        ,3},;
                  {"transform(Valor_bru,'9999,999.99')/Bruto"           ,0},;
                  {"c202c()/Taxa"              ,0},;
                  {"c202d()/Liquido"           ,0}},"P",;
                  {NIL,"c202a",NIL,NIL           },;
                  NIL,q_msg_acesso_usr()+"<B>aixar documentos" ))

/////////////////////////////////////////////////////////////////////////////
function c202b
  CARTAO->(dbseek(LANC_CAR->Cod_cart))
return left(CARTAO->Descricao,18)

/////////////////////////////////////////////////////////////////////////////
function c202c
  CARTAO->(dbseek(LANC_CAR->Cod_cart))
return transform(CARTAO->TAXA,"@E 99.99")

/////////////////////////////////////////////////////////////////////////////
function c202d
  CARTAO->(dbseek(LANC_CAR->Cod_cart))
return transform((LANC_CAR->Valor_bru - (LANC_CAR->Valor_bru * CARTAO->Taxa) / 100),"@R 9999999.99")

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function c202a
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))
   if cOPCAO == "B" ; i_baixa() ; return ; endif
   if cOPCAO $ XUSRA
      qlbloc(10,4,"B202A","QBLOC.GLO",1)
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
   local nLIQ    := 0
   local bESCAPE := {||empty(fCOD_CART).or.(XNIVEL==2.and.!XFLAG).or.!empty(fCOD_CART).and.Lastkey()==27.and.XNIVEL==2.or.;
                       (XNIVEL==2.and.cOPCAO=="A".and.!XFLAG)}

   //   MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"
      XNIVEL := 1
      qrsay ( XNIVEL++ , LANC_CAR->Codigo      )
      qrsay ( XNIVEL++ , LANC_CAR->Cod_cart    ) ; CARTAO->(Dbseek(LANC_CAR->Cod_cart))
      qrsay ( XNIVEL++ , left(CARTAO->Descricao,30)     )
      qrsay ( XNIVEL++ , dtoc(LANC_CAR->Data_comp))
      qrsay ( XNIVEL++ , dtoc(LANC_CAR->Data_lib))
      qrsay ( XNIVEL++ , transform(LANC_CAR->Valor_bru,"@R 9,999,999.99")) ; nLIQ := (LANC_CAR->Valor_bru - (LANC_CAR->Valor_bru * CARTAO->Taxa) / 100)
      qrsay ( XNIVEL++ , transform(CARTAO->Taxa,"@R 99.99"))
      qrsay ( XNIVEL++ , transform(nLIQ,"@R 9,999,999.99"))
   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || NIL                                       },"CODIGO"    })
   aadd(aEDICAO,{{ || view_cart(-1,0,@fCOD_CART,"99999")        },"COD_CART"  })
   aadd(aEDICAO,{{ || NIL      },NIL   })  // descricao do cartao
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDATA_COMP,"@D")              },"DATA_COMP" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDATA_LIB,"@D")               },"DATA_LIB"  })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fVALOR_BRU,"@E 9,999,999.99") },"VALOR_BRU" })
   aadd(aEDICAO,{{ || NIL      },NIL   })  // taxa do cartao
   aadd(aEDICAO,{{ || qgetx(-1,0,@fVALOR_LIQ,"@E 9,999,999.99") },"VALOR_LIQ" })

   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   LANC_CAR->(qpublicfields())
   iif(cOPCAO=="I",LANC_CAR->(qinitfields()),LANC_CAR->(qcopyfields()))

   XNIVEL := 2
   XFLAG  := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; LANC_CAR->(qreleasefields()) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif

     // AGORA INCREMENTA CODIGO DA FORMA DE PAGAMENTO _______________________

   if CONFIG->(qrlock()) .and. LANC_CAR->(iif(cOPCAO=="I",qappend(),qrlock()))

      if cOPCAO == "I"
         replace CONFIG->Cod_lcart with CONFIG->Cod_lcart + 1
         qrsay ( 1 , fCODIGO := strzero(CONFIG->Cod_lcart,5) )
         qmensa("C¢digo Gerado: "+fCODIGO,"B")
      endif

      // AGORA GRAVA E DESTRAVA ARQUIVO _____________________________________

      LANC_CAR->(qreplacefields())
      LANC_CAR->(dbgotop())

   endif

   dbunlockall()

   if cOPCAO == "I" ; keyboard "I" ; endif

return

/////////////////////////////////////////////////////////////////////////////
// CRITICA DE EDICAO ________________________________________________________

static function i_critica ( cCAMPO )

   local nREC

   if ! XFLAG ; return .T. ; endif

   qmensa()

   do case

      case cCAMPO == "COD_CART"
           if empty(fCOD_CART) ; return .F. ; endif
           if ! CARTAO->(dbseek(fCOD_CART))
              qmensa("C¢digo do Cart„o de Cr‚dito n„o Existe...","B")
              return .F.
           else
              qrsay(XNIVEL+1,left(CARTAO->Descricao,30))
           endif

      case cCAMPO == "VALOR_BRU"
           qrsay(XNIVEL+1,transform(CARTAO->Taxa,"@R 99.99"))
           fVALOR_LIQ := (fVALOR_BRU - (fVALOR_BRU * CARTAO->Taxa) / 100)
           qrsay(XNIVEL+2,transform(fVALOR_LIQ,"@R 9,999,999.99"))

   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXCLUIR FORMAS DE PAGAMENTO __________________________________

static function i_exclusao
   if qconf("Confirma exclus„o desta Forma de Pagamento ?")
      if LANC_CAR->(qrlock())
         LANC_CAR->(dbdelete())
         LANC_CAR->(qunlock())
      else
         qm3()
      endif
   endif
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA BAIXAR DOCUMENTOS PELA DATA DE LIBERACAO _____________________

function i_baixa

   local cDATA_INI := cDATA_FIM := ctod("")

   qlbloc(10,05,"B202B","QBLOC.GLO",1)

   qgetx(12,22,@cDATA_INI,"@D")
   qgetx(12,53,@cDATA_FIM,"@D")

   if ! qconf("Confirma Baixa dos documentos?") ; return ; endif

   qmensa("Aguarde... Baixando documentos...")

   LANC_CAR->(Dbsetorder(3))
   LANC_CAR->(Dbgotop())

   set softseek on

   LANC_CAR->(dbseek(cDATA_INI))

   do while LANC_CAR->(qrlock()) .and. ! LANC_CAR->(eof()) .and. LANC_CAR->Data_lib >= cDATA_INI .and. LANC_CAR->Data_lib <= cDATA_FIM

      LANC_CAR->(dbdelete())
      LANC_CAR->(Dbskip())

   enddo

   LANC_CAR->(qunlock())

return
