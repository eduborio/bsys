/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO COMERCIO
// OBJETIVO...: MANUTENCAO DE ESPECIFICAO DO PRODUTO
// ANALISTA...:
// PROGRAMADOR: EDURADO BORIO
// INICIO.....: SETEMBRO DE 2002
// OBS........:
// ALTERACOES.:

function cl117
#include "inkey.ch"

/////////////////////////////////////////////////////////////////////////////
// MANUTENCAO DE PEDIDO DE VENDA ___________________________________________

ESPEC->(qview({{"Codigo/Codigo"          ,1},;
             {"left(Cliente,50)/Cliente" ,3}},"P",;
             {NIL,"i_117c",NIL,NIL},;
              NIL,q_msg_acesso_usr()))
return

//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO _____________________________________

function i_117c

   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO $ XUSRA

      iif(cOPCAO == "A", lALT := .T.,)

      qlbloc(5,0,"B117A","QBLOC.GLO",1)

      qmensa(qabrev(cOPCAO,"IA",{"Inclus„o... <ESC - Cancelar>","Altera‡„o... <ESC - Cancelar>"}))
      i_edicao()

   endif

   setcursor(nCURSOR)

return ""

//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA _________________________________________

static function i_edicao

   local lCONF
   local aEDICAO := {}
   local bESCAPE := {||empty(fCOD_CLI).or.(XNIVEL==2.and.!XFLAG).or.;
                       (XNIVEL==2.and.lastkey()==27)}


// MONTA DADOS NA TELA ___________________________________________________________

   if cOPCAO <> "I"

      XNIVEL := 1

      qsay ( 06,24 , ESPEC->Codigo           )
      qsay ( 08,24 , ESPEC->Cod_Cli          ) ; CLI1->(dbseek(ESPEC->Cod_cli))
      qsay ( 08,32 , left(CLI1->Razao,40)  )

      if cOPCAO == "C"
        i_atu_lanc()
        keyboard chr(27)
      endif

   endif

   // CONSULTA OU EXCLUSAO _______________________________________________________

   if cOPCAO == "C" ; qwait() ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO _________________________________________________

   aadd(aEDICAO,{{ || NIL                                               } ,"CODIGO"       })
   aadd(aEDICAO,{{ || view_cli(8,24,@fCOD_CLI                          )} ,"COD_CLI"      })
   aadd(aEDICAO,{{ || NIL },NIL }) // razao do cliente


   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO ____________________________________________________

   do while .T.
      qgirabarra()

      ESPEC->(qpublicfields())

      iif(cOPCAO=="I", ESPEC->(qinitfields()), ESPEC->(qcopyfields()))

      XNIVEL := 2
      XFLAG := .T.

      // LOOP PARA ENTRADA DOS CAMPOS ____________________________________________

      do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
         eval ( aEDICAO [XNIVEL,1] )
         if eval ( bESCAPE );ESPEC->(qreleasefields());return;endif
         if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
         iif ( XFLAG , XNIVEL++ , XNIVEL-- )
         qmensa("")
      enddo

      if ! lCONF ; return ; endif

      if CONFIG->(qrlock())

         // AQUI INCREMENTA CODIGO DO PEDIDO DE VENDA ____________

         if cOPCAO == "I"
            qsay(6,24,fCODIGO := fCOD_CLI )
            qmensa("C¢digo Gerado: "+fCODIGO,"B")
         endif

      else
         iif(cOPCAO=="I",qm1(),qm2())
      endif

      if ESPEC->(iif(cOPCAO=="I",qappend(),qrlock()))

         // AGORA GRAVA E DESTRAVA ARQUIVO _____________________________________

         ESPEC->(qreplacefields())
         replace ESPEC->Cliente with fCLIENTE
      endif

      dbunlockall()

      i_itens()
      keyboard chr(27)

   enddo

return

/////////////////////////////////////////////////////////////////////////////////
// CRITICAS NA DESCIDA __________________________________________________________

static function i_critica ( cCAMPO )

   qmensa("")

   iif ( cCAMPO == NIL , cCAMPO := "" , NIL )
   if ! XFLAG ; return .T. ; endif

   do case

      case cCAMPO == "COD_CLI"

           if empty(fCOD_CLI) ; return .F. ; endif
           qsay(8,24,fCOD_CLI:=strzero(val(fCOD_CLI),5))
           if ! CLI1->(dbseek(fCOD_CLI))
              qmensa("Cliente n„o encontrado !","B")
              return .F.
           else
              if cOPCAO == "I"
              if ESPEC->(dbseek(CLI1->Codigo))
                 qmensa("Especificacao ja Cadastrada p/ este Cliente !","B")
                 return .F.
              endif
              endif
           endif
           qsay(8,32,left(CLI1->Razao,40))
           fCLIENTE := CLI1->Razao
   endcase

return .T.

//////////////////////////////////////////////////////////////////////////////////
// FUN€AO PARA EXCLUIR PEDIDO DE VENDA __________________________________________

static function i_exclusao

   if qconf("Confirma exclus„o desta Especificacao de produto ?")


      ITEN_ESP->(Dbgotop())
      ITEN_ESP->(Dbseek(ESPEC->Codigo))

      if ITEN_ESP->(qflock()) .and. ESPEC->(qrlock())

         ITEN_ESP->(dbseek(ESPEC->Codigo))

         do while ! ITEN_ESP->(eof()) .and. ITEN_ESP->Cod_esp == ESPEC->Codigo // itens da especificacao
            ITEN_ESP->(dbdelete())
            ITEN_ESP->(dbskip())
         enddo

         ESPEC->(dbdelete())
         ESPEC->(qunlock())
         ITEN_ESP->(qunlock())

      else
         qm3()
      endif
   endif

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DOS PRODUTOS _______________________________

function i_itens


// LOOP PRINCIPAL ___________________________________________________________

setcolor("W/B")

if cOPCAO == "A"
   fTOTAL := 0
   lALT := .T.
endif

PROD->(Dbsetorder(4))
ITEN_ESP-> (qview({{"Cod_Prod/Produto"                      ,2},;
                  {"f117a()/Descri‡„o"                   ,0},;
                  {"left(linha1,25)/Especificacao"                ,0}},;
                  "10002279S",;
                  {NIL,"f117d",NIL,NIL},;
                  {"ITEN_ESP->Cod_esp == ESPEC->Codigo",{||f117top()},{||f117bot()}},;
                  "<I>nc./<A>lt./<C>on./<E>xc."))

return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IR PARA O INICIO DOS DADOS FILTRADOS _________________________

function f117top
   ITEN_ESP->(dbsetorder(1))
   ITEN_ESP->(dbseek(ESPEC->Codigo))

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IR PARA O FINAL DOS DADOS FILTRADOS __________________________

function f117bot
   ITEN_ESP->(dbsetorder(1))
   ITEN_ESP->(qseekn(ESPEC->Codigo))
return

/////////////////////////////////////////////////////////////////////////////
// RETORNA A DESCRICAO DO PRODUTO __________________________________________

function f117a

   local cDESCRICAO := space(25)
   PROD->(Dbsetorder(4))
   if ! empty(ITEN_ESP->Cod_prod)
      PROD->(dbseek(left(ITEN_ESP->Cod_prod,5)))
      cDESCRICAO := left(PROD->Descricao,35)
   endif

return cDESCRICAO

/////////////////////////////////////////////////////////////////////////////
// FUNCAO DE CONTROLE PRINCIPAL ANTES DE PROCESSAR A TECLA ACIONADA _________

function f117d

   local nCURSOR := setcursor(1)
   parameters cOPCAO

   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO $ XUSRA
      qlbloc(08,08,"B117B","QBLOC.GLO",1)
      i_2acao()
   endif


   setcursor(nCURSOR)

return ""






/////////////////////////////////////////////////////////////////////////////
// FUNCAO DE BROWSE _________________________________________________________

static function i_2acao

   local lCONF
   local aEDICAO := {}
   local bESCAPE := {||empty(fCOD_PROD).or.(XNIVEL==1.and.!XFLAG).or.;
                       (XNIVEL==1.and.lastkey()==27).or.;
                       (XNIVEL==2.and.cOPCAO=="A".and.!XFLAG)}

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"

      XNIVEL := 1
      qrsay ( XNIVEL++ , ITEN_ESP->Cod_prod            , "@R 99999"           ) ; PROD->(dbseek(left(ITEN_ESP->Cod_prod,5)))
      qrsay ( XNIVEL++ , left(PROD->Descricao,40)                             )
      qrsay ( XNIVEL++ , ITEN_ESP->Linha1, "@!"                               )
      qrsay ( XNIVEL++ , ITEN_ESP->Linha2, "@!"                               )
      qrsay ( XNIVEL++ , ITEN_ESP->Linha3, "@!"                               )
      qrsay ( XNIVEL++ , ITEN_ESP->Linha4, "@!"                               )
      qrsay ( XNIVEL++ , ITEN_ESP->Linha5, "@!"                               )
      qrsay ( XNIVEL++ , ITEN_ESP->Linha6, "@!"                               )
      qrsay ( XNIVEL++ , ITEN_ESP->Linha7, "@!"                               )
      qrsay ( XNIVEL++ , ITEN_ESP->Linha8, "@!"                               )
      qrsay ( XNIVEL++ , ITEN_ESP->Linha9, "@!"                               )
      qrsay ( XNIVEL++ , ITEN_ESP->Linha10, "@!"                               )
      qrsay ( XNIVEL++ , ITEN_ESP->Linha11, "@!"                               )
      qrsay ( XNIVEL++ , ITEN_ESP->Linha12, "@!"                               )
      qrsay ( XNIVEL++ , ITEN_ESP->Linha13, "@!"                               )

   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exc_itens() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || view_prod(-1,0,@fCOD_PROD                    ) } ,"COD_PROD"  })
   aadd(aEDICAO,{{ || NIL                                            } ,NIL         })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fLINHA1, "@!"                     ) } ,"LINHA1"    })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fLINHA2, "@!"                     ) } ,"LINHA2"    })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fLINHA3, "@!"                     ) } ,"LINHA3"    })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fLINHA4, "@!"                     ) } ,"LINHA4"    })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fLINHA5, "@!"                     ) } ,"LINHA5"    })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fLINHA6, "@!"                     ) } ,"LINHA6"    })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fLINHA7, "@!"                     ) } ,"LINHA7"    })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fLINHA8, "@!"                     ) } ,"LINHA8"    })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fLINHA9, "@!"                     ) } ,"LINHA9"    })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fLINHA10, "@!"                    ) } ,"LINHA10"    })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fLINHA11, "@!"                    ) } ,"LINHA11"    })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fLINHA12, "@!"                    ) } ,"LINHA12"    })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fLINHA13, "@!"                    ) } ,"LINHA13"    })

   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   ITEN_ESP->(qpublicfields())

   iif(cOPCAO=="I",ITEN_ESP->(qinitfields()),ITEN_ESP->(qcopyfields()))

   if cOPCAO == "A"
      XNIVEL := 3
   else
      XNIVEL := 1
   endif

   XFLAG  := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; ITEN_ESP->(qreleasefields()) ; return ; endif
      if ! i_crit2( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   if ! lCONF ; return ; endif

   // GRAVACAO ______________________________________________________________

   if ESPEC->(qrlock()) .and. ITEN_ESP->(iif(cOPCAO=="I",qappend(),qrlock()))
      if cOPCAO == "I"
         fCOD_ESP := fCODIGO
         fCLI_COD := fCOD_CLI
      endif

      ITEN_ESP->(qreplacefields())
      ITEN_ESP->(qunlock())

   else

      iif(cOPCAO=="I",qm1(),qm2())

   endif

return

/////////////////////////////////////////////////////////////////////////////
// CRITICAS NA DESCIDA ______________________________________________________

static function i_crit2 ( cCAMPO )

   qmensa("")

   iif ( cCAMPO == NIL , cCAMPO := "" , NIL )
   if ! XFLAG; return .t.; endif
   do case

      case cCAMPO == "COD_PROD"

           qrsay(XNIVEL,fCOD_PROD:=strzero(val(fCOD_PROD),5))

           if ! PROD->(dbseek(fCOD_PROD))
              qmensa("Produto n„o encontrado !","B")
              return .F.
           endif

           qrsay ( XNIVEL+1 , left(PROD->Descricao,40) )

   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXCLUIR ITENS DO PEDIDO  _____________________________________

static function i_exc_itens

   if qconf("Confirma exclus„o do Produto ?")

      if ITEN_ESP->(qrlock())
         ITEN_ESP->(dbdelete())
         ITEN_ESP->(qunlock())
      else
         qm3()
      endif
   endif

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA DEVOLUCAO de ITENS DO PEDIDO  _____________________________________


////////////////////////////////////////////////////////////////////////////////////
static function i_atu_lanc

ITEN_ESP->(qview({{"Cod_Prod/Produto"                                     ,2},;
                  {"f117a()/Descri‡„o"                                    ,0},;
                  {"left(linha1,25)/Especificacao"                        ,0}},;
                  "10002279S",;
                  {NIL,NIL,NIL,NIL},;
                  {"ITEN_ESP->Cod_esp == ESPEC->Codigo",{||f117top()},{||f117bot()}},;
                 "<ESC> para sair" ))

return ""


