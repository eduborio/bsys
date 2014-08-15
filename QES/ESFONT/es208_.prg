/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE ESTOQUES
// OBJETIVO...: LANCAMENTOS TELEPAR (APR)
// ANALISTA...:
// PROGRAMADOR: LUCINEIDE VILAR POSSEBOM
// INICIO.....: SETEMBRO DE 1998
// OBS........:

function es208

#include "inkey.ch"

private nDESC := 0

fu_abre_cli1()

/////////////////////////////////////////////////////////////////////////////
// MANUTENCAO DOS LANCAMENTOS ______________________________________________

TELEPAR->(qview({{"Data_emiss/Emiss„o" ,1},;
                 {"Docto/Documento"    ,0},;
                 {"i_208a()/Cliente"   ,0}},"P",;
                 {NIL,"i_208b",NIL,NIL},;
                 NIL,q_msg_acesso_usr()))
return


//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAGEM DO CLIENTE _______________________________________________

function i_208a
   CLI1->(dbseek(TELEPAR->Cod_cli))
return left(CLI1->Razao,52)

//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO _____________________________________

function i_208b

   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO $ XUSRA
      qlbloc(5,0,"B208A","QBLOC.GLO",1)
      qmensa(qabrev(cOPCAO,"IA",{"Inclus„o... <ESC - Cancela>","Altera‡„o... <ESC - Cancela>"}))
      i_edicao()
   endif

   setcursor(nCURSOR)

return ""

//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA _________________________________________

static function i_edicao

   local lCONF
   local aEDICAO := {}
   local bESCAPE := {||empty(fDOCTO).or.(XNIVEL==1.and.!XFLAG).or.;
                       (XNIVEL==1.and.lastkey()==27)}

// MONTA DADOS NA TELA ___________________________________________________________

   if cOPCAO <> "I"

      XNIVEL := 1

      qsay ( 06,21 , TELEPAR->Docto            )
      qsay ( 06,68 , dtoc(TELEPAR->Data_emiss) )
      qsay ( 07,21 , TELEPAR->Cod_cli          ) ; CLI1->(dbseek(TELEPAR->Cod_cli))
      qsay ( 07,29,  left(CLI1->Razao,35)      )
      qsay ( 08,21 , TELEPAR->Filial           ) ; FILIAL->(dbseek(TELEPAR->Filial))
      qsay ( 08,28,  left(FILIAL->Razao,35)    )

      if cOPCAO == "C"
        i_atu_lanc()
        keyboard chr(27)
      endif

   endif

   // CONSULTA OU EXCLUSAO _______________________________________________________

   if cOPCAO == "C" ; qwait() ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO _________________________________________________

   aadd(aEDICAO,{{ || qgetx(6,21,@fDOCTO     ,"@!",NIL                 )} ,"DOCTO"        })
   aadd(aEDICAO,{{ || qgetx(6,68,@fDATA_EMISS ,"@D",                   )} ,"DATA_EMISS"   })
   aadd(aEDICAO,{{ || view_cli(7,21,@fCOD_CLI                          )} ,"COD_CLI"      })
   aadd(aEDICAO,{{ || NIL },NIL }) // descricao do cliente
   aadd(aEDICAO,{{ || view_filial(8,21,@fFILIAL                        )} ,"FILIAL"       })
   aadd(aEDICAO,{{ || NIL },NIL }) // descricao da filial

   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO ____________________________________________________

   do while .T.
      qgirabarra()

      TELEPAR->(qpublicfields())

      iif(cOPCAO=="I", TELEPAR->(qinitfields()), TELEPAR->(qcopyfields()))

      XNIVEL := 1
      XFLAG := .T.

      // LOOP PARA ENTRADA DOS CAMPOS ____________________________________________

      do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
         eval ( aEDICAO [XNIVEL,1] )
         if eval ( bESCAPE );TELEPAR->(qreleasefields());return;endif
         if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
         iif ( XFLAG , XNIVEL++ , XNIVEL-- )
         qmensa("")
      enddo

      if ! lCONF ; return ; endif

      if TELEPAR->(iif(cOPCAO=="I",qappend(),qrlock()))

         // AGORA GRAVA E DESTRAVA ARQUIVO _____________________________________

         TELEPAR->(qreplacefields())

      endif

      dbunlockall()

      i_proc1_lanc()
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
      case cCAMPO == "DOCTO"
           qsay(6,21,fDOCTO)
           nINDEX := TELEPAR->(indexord())
           nREC   := TELEPAR->(recno())
           TELEPAR->(dbsetorder(1))
           if cOPCAO == "I"
              if TELEPAR->(dbseek(fDOCTO))
                 qmensa("Documento j  Cadastrado !","B")
                 TELEPAR->(dbsetorder(nINDEX))
                 TELEPAR->(dbgoto(nREC))
                 return .F.
              endif
           else
              if ! TELEPAR->(dbseek(fDOCTO))
                 qmensa("Docuemnto n„o Cadastrado !","B")
                 TELEPAR->(dbsetorder(nINDEX))
                 TELEPAR->(dbgoto(nREC))
                 return .F.
              endif
           endif

      case cCAMPO == "DATA_EMISS"
           if empty(fDATA_EMISS) ; return .F. ; endif

      case cCAMPO == "COD_CLI"
           if empty(fCOD_CLI) ; return .F. ; endif
           qsay(7,21,fCOD_CLI)
           CLI1->(dbsetorder(1))
           if ! CLI1->(dbseek(fCOD_CLI))
              qmensa("Cliente n„o encontrado !","B")
              return .F.
           endif
           qsay(7,29,left(CLI1->Razao,35))

      case cCAMPO == "FILIAL"
           if empty(fFILIAL) ; return .F. ; endif
           qsay(8,21,fFILIAL)
           FILIAL->(dbsetorder(1))
           if ! FILIAL->(dbseek(fFILIAL))
              qmensa("Filial n„o encontrado !","B")
              return .F.
           endif
           qsay(8,28,left(FILIAL->Razao,35))

   endcase

return .T.

//////////////////////////////////////////////////////////////////////////////////
// FUN€AO PARA EXCLUIR LANCAMENTO DA TELEPAR _____________________________________

static function i_exclusao

   if qconf("Confirma exclus„o deste Documento ?")
      if ITEN_TEL->(qflock()) .and. TELEPAR->(qrlock())
         ITEN_TEL->(dbseek(TELEPAR->Docto))
         do while ! ITEN_TEL->(eof()) .and. ITEN_TEL->Docto_tel  == TELEPAR->Docto
            ITEN_TEL->(dbdelete())
            ITEN_TEL->(dbskip())
         enddo
         TELEPAR->(dbdelete())
         TELEPAR->(qunlock())
         ITEN_TEL->(qunlock())
      else
         qm3()
      endif
   endif

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DOS PRODUTOS _______________________________

function i_proc1_lanc

// LOOP PRINCIPAL ___________________________________________________________

setcolor("W/B")

PROD->(Dbsetorder(4))

ITEN_TEL->(qview({{"Cod_Prod/Cod."                                        ,2},;
                  {"f208a()/Descri‡„o"                                    ,0},;
                  {"transform(Val_unit, '@E 999,999,999.99')/Vl.Unit."    ,0},;
                  {"transform(Quantidade,'@E 99999')/Quant."              ,0},;
                  {"f208c()/Val. Total"                                   ,0},;
                  {"transform(Desconto,'@E 99.99')/Desc."                     ,0}},;
                  "09002379S",;
                  {NIL,"f208d",NIL,NIL},;
                  {"ITEN_TEL->Docto_tel == TELEPAR->Docto",{||f208top()},{||f208bot()}},;
                  "<I>nc./<A>lt./<C>on.<E>xc."))

return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IR PARA O INICIO DOS DADOS FILTRADOS _________________________

function f208top
   ITEN_TEL->(dbsetorder(1))
   ITEN_TEL->(dbseek(TELEPAR->Docto))
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IR PARA O FINAL DOS DADOS FILTRADOS __________________________

function f208bot
   ITEN_TEL->(dbsetorder(1))
   ITEN_TEL->(qseekn(TELEPAR->Docto))
return

/////////////////////////////////////////////////////////////////////////////
// RETORNA A DESCRICAO DO PRODUTO __________________________________________

function f208a

   local cDESCRICAO := space(25)
   PROD->(Dbsetorder(4))
   if ! empty(ITEN_TEL->Cod_prod)
      PROD->(dbseek(left(ITEN_TEL->Cod_prod,5)))
      cDESCRICAO := left(PROD->Descricao,25)
   endif

return cDESCRICAO

/////////////////////////////////////////////////////////////////////////////
// RETORNA O VALOR TOTAL DO PRODUTO _________________________________________

function f208c
   iif (ITEN_TEL->Desconto <> 0 , nDESC := (ITEN_TEL->Val_unit * ITEN_TEL->Quantidade) * (ITEN_TEL->Desconto/100) , nDESC := 0 )
return transform((ITEN_TEL->Val_unit * ITEN_TEL->Quantidade)-nDESC,"@E 9,999,999.99")

/////////////////////////////////////////////////////////////////////////////
// FUNCAO DE CONTROLE PRINCIPAL ANTES DE PROCESSAR A TECLA ACIONADA _________

function f208d

   local nCURSOR := setcursor(1)
   parameters cOPCAO

   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO $ XUSRA
      qlbloc(13,08,"B208B","QBLOC.GLO",1)
      i_processa_acao()
   endif

   setcursor(nCURSOR)

return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO DE BROWSE _________________________________________________________

static function i_processa_acao

   local lCONF
   local aEDICAO := {}
   local bESCAPE := {||empty(fCOD_PROD).or.(XNIVEL==1.and.!XFLAG).or.;
                       (XNIVEL==1.and.lastkey()==27).or.;
                       (XNIVEL==2.and.cOPCAO=="A".and.!XFLAG)}

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"

      XNIVEL := 1
      qrsay ( XNIVEL++ , ITEN_TEL->Cod_prod          , "@R 99999"       ) ; PROD->(dbseek(left(ITEN_TEL->Cod_prod,5)))
      qrsay ( XNIVEL++ , left(PROD->Descricao,40)                       )
      qrsay ( XNIVEL++ , ITEN_TEL->Val_unit, "@E 99,999,999.99"         )
      qrsay ( XNIVEL++ , ITEN_TEL->Quantidade, "@E 99999"               )
      qrsay ( XNIVEL++ , ITEN_TEL->Desconto , "@E 99.99"                )
      qrsay ( XNIVEL++ , ITEN_TEL->Val_unit * ITEN_TEL->Quantidade, "@E 99,999,999.99" )

   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exc_iten_tel() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || view_prod(-1,0,@fCOD_PROD                     ) } ,"COD_PROD"  })
   aadd(aEDICAO,{{ || NIL                                             } ,NIL         })

   aadd(aEDICAO,{{ || qgetx(-1,0,@fVAL_UNIT , "@E 99,999,999.99"   ) } ,"VAL_UNIT"   })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fQUANTIDADE , "@E 99999"          ) } ,"QUANTIDADE"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDESCONTO , "@E 99.99"           ) } ,"DESCONTO"   })
   aadd(aEDICAO,{{ || NIL                                             } ,NIL         })

   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   ITEN_TEL->(qpublicfields())

   iif(cOPCAO=="I",ITEN_TEL->(qinitfields()),ITEN_TEL->(qcopyfields()))

   XNIVEL := 1
   XFLAG  := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; ITEN_TEL->(qreleasefields()) ; return ; endif
      if ! i_crit2( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   if ! lCONF ; return ; endif

   // GRAVACAO ______________________________________________________________

   if TELEPAR->(qrlock()) .and. ITEN_TEL->(iif(cOPCAO=="I",qappend(),qrlock()))
      if cOPCAO == "I"
         fDOCTO_TEL := fDOCTO
      endif
      ITEN_TEL->(qreplacefields())
      ITEN_TEL->(qunlock())

   else

      iif(cOPCAO=="I",qm1(),qm2())

   endif

return

/////////////////////////////////////////////////////////////////////////////
// CRITICAS NA DESCIDA ______________________________________________________

static function i_crit2 ( cCAMPO )

   qmensa("")

   iif ( cCAMPO == NIL , cCAMPO := "" , NIL )

   do case

      case cCAMPO == "COD_PROD"

           qrsay(XNIVEL,fCOD_PROD:=strzero(val(fCOD_PROD),5))

           if ! PROD->(dbseek(fCOD_PROD))
              qmensa("Produto n„o encontrado !","B")
              return .F.
           endif

           qrsay ( XNIVEL+1 , left(PROD->Descricao,40) )

      case cCAMPO == "DESCONTO"
           iif (fDESCONTO <> 0 , nDESC := (fVAL_UNIT * fQUANTIDADE) * (fDESCONTO/100) , nDESC := 0 )
           qrsay(XNIVEL+1,transform((fVAL_UNIT*fQUANTIDADE)-nDESC, "@e 99,999,999.99"))

   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXCLUIR ITENS DA TELEPAR _____________________________________

static function i_exc_iten_tel

   if qconf("Confirma exclus„o do Item ?")
      if ITEN_TEL->(qrlock())
         ITEN_TEL->(dbdelete())
         ITEN_TEL->(qunlock())
      else
         qm3()
      endif
   endif

return

////////////////////////////////////////////////////////////////////////////////////
static function i_atu_lanc

setcolor("W/B")

ITEN_TEL->(qview({{"Cod_Prod/Cod."                                        ,2},;
                  {"f208a()/Descri‡„o"                                    ,0},;
                  {"transform(Val_unit, '@E 99,999,999.99')/Vl.Unit."     ,0},;
                  {"transform(Quantidade,'@E 99999')/Quant."              ,0},;
                  {"f208c()/Val. Total"                                   ,0},;
                  {"transform(Desconto,'@E 99.99')/Desc."                 ,0}},;
                  "09002379S",;
                  {NIL,NIL,NIL,NIL},;
                  {"ITEN_TEL->Docto_tel == TELEPAR->Docto",{||f208top()},{||f208bot()}},;
                 "<ESC> para sair" ))

return ""
