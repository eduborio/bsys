/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE ESTOQUES
// OBJETIVO...: MANUTENCAO DE ORDEM DE COMPRA
// ANALISTA...:
// PROGRAMADOR: LUCINEIDE VILAR POSSEBOM
// INICIO.....: JANEIRO DE 1997
// OBS........:
// ALTERACOES.:

function es101

PROD->(dbsetorder(4))
CCUSTO->(dbsetorder(4))

ORDEM->(qview({{"Codigo/C¢digo"               ,1},;
              {"Data/Data"                    ,2},;
              {"c101a()/Centro"               ,0},;
              {"c101b()/Filial"               ,0},;
              {"c101c()/Pedido"                ,0}},"P",;
              {NIL,"c101d",NIL,NIL},;
               NIL,q_msg_acesso_usr()))

 Return ""
//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAGEM DA FILIAL _______________________________________________

function c101a
   local cDescricao := space(25)
   if CCUSTO->(dbseek(ORDEM->Centro))
      cDescricao := left(CCUSTO->Descricao,25)
   endif
return cDescricao

//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAGEM DO NUMERO DO PEDIDO  ____________________________________

function c101c
return transform(ORDEM->Pedido,"@R 99999/9999")

//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAGEM DO CENTRO DE CUSTO  _____________________________________

function  c101b
   local cDescricao := space(25)
   if FILIAL->(dbseek(ORDEM->Filial))
      cDescricao := left(FILIAL->Razao,21)
   endif
return cDescricao

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function c101d

   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO $ XUSRA
      qlbloc(5,0,"B101A","QBLOC.GLO",1)
      qmensa(qabrev(cOPCAO,"IA",{"Inclus„o... <ESC - Cancela>","Altera‡„o... <ESC - Cancela>"}))
      i_edicao()
   endif

   setcursor(nCURSOR)

   ORDEM->(dbgotop())

return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA ____________________________________

static function i_edicao
   local lCONF   := .F.
   local aEDICAO := {}
   local bESCAPE := {||empty(fDATA).or.(XNIVEL==2.and.!XFLAG).or.!empty(fDATA).and.Lastkey()==27.or.;
                       (XNIVEL==2.and.cOPCAO=="A".and.!XFLAG)}

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"

      XNIVEL := 1

      qsay ( 06,23 , ORDEM->Codigo       )

      qsay ( 06,68 , ORDEM->Data         )

      qsay ( 07,23 , ORDEM->Filial       ) ; FILIAL->(dbseek(ORDEM->Filial))
      qsay ( 07,36 , left(FILIAL->Razao,25))

      qsay ( 08,23 , ORDEM->Centro       ) ; CCUSTO->(dbseek(ORDEM->Centro))
      qsay ( 08,36 , CCUSTO->Descricao   )


      qsay ( 09,13 , ORDEM->Veiculo      ) ; VEICULOS->(dbseek(ORDEM->Veiculo))
      qsay ( 09,19 , VEICULOS->Descricao )

      qsay ( 09,50 , ORDEM->Equipament   ) ; EQUIPTO->(dbseek(ORDEM->Equipament))
      qsay ( 09,56 , left(EQUIPTO->Descricao,20)  )

      qsay ( 10,23 , transform(ORDEM->Pedido, "@R 99999/9999"))
      qsay ( 10,45 , ORDEM->Funcionari   ) ; FUN->(dbseek(ORDEM->Funcionari))
      qsay ( 10,52 , left(FUN->Nome,20)  )

      if cOPCAO == "C"
         i_atu_item()
         keyboard chr(27)
      endif

   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || NIL                                                  },"CODIGO"    })
   aadd(aEDICAO,{{ || qgetx(6,68,@fDATA                                   )},"DATA"      })
   aadd(aEDICAO,{{ || view_filial(7,23,@fFILIAL                           )} ,"FILIAL"   })
   aadd(aEDICAO,{{ || NIL },NIL }) // descricao da filial
   aadd(aEDICAO,{{ || view_ccusto(8,23,@fCENTRO                           )} ,"CENTRO"   })
   aadd(aEDICAO,{{ || NIL },NIL }) // descricao do centro
   aadd(aEDICAO,{{ || view_veic(9,13,@fVEICULO)                            },"VEICULO"   })
   aadd(aEDICAO,{{ || NIL                                                  },NIL         })
   aadd(aEDICAO,{{ || view_equip(9,50,@fEQUIPAMENT)                      },"EQUIPAMENT"})
   aadd(aEDICAO,{{ || NIL                                                  },NIL         })
   aadd(aEDICAO,{{ || qgetx(10,23,@fPEDIDO    ,"@R 99999/9999")            },"PEDIDO"    })
   aadd(aEDICAO,{{ || view_fun(10,45,@fFUNCIONARI)                         },"FUNCIONARI"})
   aadd(aEDICAO,{{ || NIL                                                  },NIL         })

   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   do while .T.

       ORDEM->(qpublicfields())

       iif(cOPCAO=="I",ORDEM->(qinitfields()),ORDEM->(qcopyfields()))

       XNIVEL  := 2
       XFLAG   := .T.

       // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

       do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
          eval ( aEDICAO [XNIVEL,1] )
          if eval ( bESCAPE ) ; ORDEM->(qreleasefields()) ; return ; endif
          if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
          iif ( XFLAG , XNIVEL++ , XNIVEL-- )
       enddo

       // GRAVACAO ______________________________________________________________

       if ! lCONF ; return ; endif

       if CONFIG->(qrlock()) .and. ORDEM->(iif(cOPCAO=="I",qappend(),qrlock()))

          // AQUI INCREMENTA CODIGO DA ORDEM DE COMPRA  _________________________

          if cOPCAO == "I"
             replace CONFIG->Cod_ORDEM with CONFIG->Cod_ORDEM + 1
             qrsay ( 1 , fCODIGO := strzero(CONFIG->Cod_ORDEM,5) )
             qmensa("C¢digo Gerado: "+fCODIGO,"B")
             qsay(06,23 , fCodigo)

          endif

          // AGORA GRAVA E DESTRAVA ARQUIVO _____________________________________

          ORDEM->(qreplacefields())

       else

          if empty(ORDEM->Cod_ord) .and. empty(ORDEM->Razao) .and. empty(ORDEM->Cgccpf)
             ORDEM->(dbdelete())
          endif

          iif(cOPCAO=="I",qm1(),qm2())

       endif

       dbunlockall()

       i_proc_item()
//       keyboard chr(27)
       exit
   enddo

return

/////////////////////////////////////////////////////////////////////////////
// CRITICA DE EDICAO ________________________________________________________

static function i_critica ( cCAMPO )

   if ! XFLAG ; return .T. ; endif

   do case

      case cCAMPO == "CODIGO" .and. cOPCAO == "I"

           if ORDEM->(dbseek(fCODIGO))
              qmensa("Ordem de Compra j  cadastrado !","B")
              return .F.
           endif

      case cCAMPO == "DATA"

           if empty(fDATA) ; return .F. ; endif


      case cCAMPO == "FILIAL"

           FILIAL->(dbsetorder(4))

           if ! FILIAL->(dbseek(fFILIAL))
              qmensa("Filial n„o encontrada !","B")
              return .F.
           endif

           qsay(07,36,left(FILIAL->Razao,25))

      case cCAMPO == "CENTRO"

           CCUSTO->(dbsetorder(4))

           if ! CCUSTO->(dbseek(fCENTRO))
              qmensa("Centro de Custo n„o encontrado !","B")
              return .F.
           endif

           qsay(08,36,CCUSTO->Descricao)

      case cCAMPO == "VEICULO"

           if ! empty(fVEICULO)
              fVEICULO:=strzero(val(fVEICULO),5)
              if ! VEICULOS->(dbseek(fVEICULO))
                 qmensa("Ve¡culo n„o encontrado !","B")
                 return .F.
              endif
              qsay(09,19,VEICULOS->Descricao)
           endif

      case cCAMPO == "EQUIPAMENT"

           if ! empty(fEQUIPAMENT)
              fEQUIPAMENT:=strzero(val(fEQUIPAMENT),5)
              if ! EQUIPTO->(dbseek(fEQUIPAMENT))
                 qmensa("Equipamento n„o encontrado !","B")
                 return .F.
              endif
              qsay(09,56,left(EQUIPTO->Descricao,20))
           endif

      case cCAMPO == "FUNCIONARI"

           if ! empty(fFUNCIONARI)
              fFUNCIONARI:=strzero(val(fFUNCIONARI),6)
              if ! FUN->(dbseek(fFUNCIONARI))
                 qmensa("Funcion rio n„o encontrado !","B")
                 return .F.
              endif
              qsay(10,52,left(FUN->Nome,20))
           endif

   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXCLUIR ORDEM DE COMPRA _____________________________________

static function i_exclusao
   if qconf("Confirma exclus„o desta Ordem de Compra ?")
      if ITENS_OC->(qflock()) .and. ORDEM->(qrlock())
         ITENS_OC->(dbseek(ORDEM->Codigo))
         do while ! ITENS_OC->(eof()) .and. ITENS_OC->Cod_ord == ORDEM->Codigo
            ITENS_OC->(dbdelete())
            ITENS_OC->(dbskip())
         enddo
         ORDEM->(dbdelete())
         ORDEM->(qunlock())
         ITENS_OC->(qunlock())
      else
         qm3()
      endif
   endif
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DOS PRODUTOS _______________________________

function i_proc_item

// LOOP PRINCIPAL ___________________________________________________________

setcolor("W/B")

ITENS_OC->(qview({{"Produto/Cod."                                    ,1},;
                  {"f101a()/Descri‡„o"                               ,0},;
                  {"transform(Quantidade,'@E 9999.99999')/Quantidade",0},;
                  {"Lote/N£mero do Lote"                             ,0}},;
                  "11002379S",;
                  {NIL,"f101d",NIL,NIL},;
                  {"ITENS_OC->Cod_ord == ORDEM->Codigo",{||f101top()},{||f101bot()}},;
                  "ESC - Retorna/ <I>nc./<A>lt./<C>on.<E>xc."))

return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IR PARA O INICIO DOS DADOS FILTRADOS _________________________

function f101top
   ITENS_OC->(dbsetorder(1))
   ITENS_OC->(dbseek(ORDEM->Codigo))
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IR PARA O FINAL DOS DADOS FILTRADOS __________________________

function f101bot
   ITENS_OC->(dbsetorder(1))
   ITENS_OC->(qseekn(ORDEM->Codigo))
return

/////////////////////////////////////////////////////////////////////////////
// RETORNA A DESCRICAO DO PRODUTO __________________________________________

function f101a

   local cDESCRICAO := space(40)

   if ! empty(ITENS_OC->Produto)
      PROD->(dbseek(ITENS_OC->Produto))
      cDESCRICAO := left(PROD->Descricao,40)
   endif

return cDESCRICAO

/////////////////////////////////////////////////////////////////////////////
// FUNCAO DE CONTROLE PRINCIPAL ANTES DE PROCESSAR A TECLA ACIONADA _________

function f101d

   local nCURSOR := setcursor(1)
   parameters cOPCAO

   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO $ XUSRA
      qlbloc(11,08,"B101B","QBLOC.GLO",1)
      i_proc_acao()
   endif

   setcursor(nCURSOR)

   ITENS_OC->(dbgotop())

return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO DE BROWSE _________________________________________________________

static function i_proc_acao

   local lCONF
   local aEDICAO := {}
   local bESCAPE := {||empty(fPRODUTO).or.(XNIVEL==1.and.!XFLAG).or.;
                       (XNIVEL==1.and.lastkey()==27).or.;
                       (XNIVEL==2.and.cOPCAO=="A".and.!XFLAG)}

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"

      XNIVEL := 1
      qrsay ( XNIVEL++ , ITENS_OC->Produto , "@R 99999"  ) ; PROD->(dbseek(ITENS_OC->Produto))
      qrsay ( XNIVEL++ , left(PROD->Descricao,40)        )
      qrsay ( XNIVEL++ , ITENS_OC->Lote                  )
      qrsay ( XNIVEL++ , ITENS_OC->Quantidade            )

      LOTES->(dbSetFilter({|| Produto == fPRODUTO .and. Filial == ORDEM->FILIAL }, 'Produto == fPRODUTO .and. Filial == ORDEM->FILIAL'))

   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exc_itens_oc() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || view_prod(-1,0,@fPRODUTO                    ) } ,"PRODUTO"   })
   aadd(aEDICAO,{{ || NIL                                           } ,NIL         })

   aadd(aEDICAO,{{ || view_lote(-1,0,@fLOTE , "@R 9999999999"     ) } ,"LOTE"      })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fQUANTIDADE , "@E 9999.99999"   ) } ,"QUANTIDADE"})

   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   ITENS_OC->(qpublicfields())

   iif(cOPCAO=="I",ITENS_OC->(qinitfields()),ITENS_OC->(qcopyfields()))

   XNIVEL := 1
   XFLAG  := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; ITENS_OC->(qreleasefields()) ; return ; endif
      if ! i_crit2( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   if ! lCONF ; return ; endif

   // GRAVACAO ______________________________________________________________

   if ORDEM->(qrlock()) .and. ITENS_OC->(iif(cOPCAO=="I",qappend(),qrlock()))
      if cOPCAO == "I"
         fCOD_ORD := fCODIGO
      endif
      ITENS_OC->(qreplacefields())
      ITENS_OC->(qunlock())
      ITENS_OC->(dbgotop())

   else

      iif(cOPCAO=="I",qm1(),qm2())

   endif
   ITENS_OC->(dbgotop())

return ""

/////////////////////////////////////////////////////////////////////////////
// CRITICAS NA DESCIDA ______________________________________________________

static function i_crit2 ( cCAMPO )

   qmensa("")

   iif ( cCAMPO == NIL , cCAMPO := "" , NIL )

   do case

      case cCAMPO == "PRODUTO"

           qrsay(XNIVEL,fPRODUTO:=strzero(val(fPRODUTO),5))

           if ! PROD->(dbseek(fPRODUTO))
              qmensa("Produto n„o encontrado !","B")
              return .F.
           endif
           LOTES->(dbSetFilter({|| Produto == fPRODUTO .and. Filial == ORDEM->FILIAL }, 'Produto == fPRODUTO .and. Filial == ORDEM->FILIAL'))

           qrsay ( XNIVEL+1 , left(PROD->Descricao,40) )

      case cCAMPO == "LOTE"
           LOTES->(dbSetFilter({|| Produto == fPRODUTO .and. Filial == ORDEM->FILIAL }, 'Produto == fPRODUTO .and. Filial == ORDEM->FILIAL'))

           if empty(fLOTE); return .t.; endif

           if ! LOTES->(dbseek(fPRODUTO+fFILIAL+fLOTE))
              qmensa("N£mero de Lote deste Produto nÆo encontrado...","B")
              fLOTE := "          "
              return .F.
           endif

      case cCAMPO == "QUANTIDADE"

          if empty(fQUANTIDADE) ; return .F. ; endif


   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXCLUIR ITENS DA ORDEM DE COMPRA ____________________________

static function i_exc_itens_oc

   if qconf("Confirma exclus„o do Produto ?")
      if ITENS_OC->(qrlock())
         ITENS_OC->(dbdelete())
         ITENS_OC->(qunlock())
      else
         qm3()
      endif
   endif

return

////////////////////////////////////////////////////////////////////////////////////
static function i_atu_item

setcolor("W/B")

ITENS_OC->(qview({{"Produto/Cod."                                      ,2},;
                  {"f101a()/Descri‡„o"                                 ,0},;
                  {"transform(Quantidade,'@E 9999.99999')/Quantidade"  ,0},;
                  {"Lote/N£mero do Lote"                               ,0}},;
                  "11002379S",;
                  {NIL,NIL,NIL,NIL},;
                  {"ITENS_OC->Cod_ord == ORDEM->Codigo",{||f101top()},{||f101bot()}},;
                 "<ESC> para sair" ))

return ""

