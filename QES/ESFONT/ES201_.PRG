/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE ESTOQUES
// OBJETIVO...: BAIXA - REQUISICAO DE MATERIAL
// ANALISTA...:
// PROGRAMADOR: LUCINEIDE VILAR POSSEBOM
// INICIO.....: DEZEMBRO DE 1996
// OBS........:
// ALTERACOES.: LUCIANO DA SILVA GORSKI
function es201

#include "inkey.ch"

private nINDEX
private nREC

CCUSTO->(Dbsetorder(4))

// REQUISIC->(dbSetFilter({|| qanomes(Dt_requisi)==qanomes(XDATASYS) }, 'qanomes(Dt_requisi)==qanomes(XDATASYS)'))

/////////////////////////////////////////////////////////////////////////////
// MANUTENCAO DAS REQUISICOES DE MATERIAIS __________________________________
Set Softseek on
REQUISIC->(dbsetorder(4))

//REQUISIC->(dbseek(ctod(XANOMES+"01")+REQUISIC->Codigo))
REQUISIC->(dbseek(dtos (ctod("01/"+right(XANOMES,2)+"/"+left(XANOMES,4)))))

REQUISIC->(qview({{"Dt_requisi/Dt. Req." ,4},;
                 {"Codigo/N£mero"        ,1},;
                 {"i_201a()/Filial"      ,0},;
                 {"i_201b()/Centro Custo",0},;
                 {"i_201d()/Baixado"     ,0}},"P",;
                 {NIL,"i_201c",NIL,NIL},;
                 {"dtos(Dt_requisi) >= dtos(ctod('01/'+right(XANOMES,2)+'/'+left(XANOMES,4)))",{||i201top()},{||i201bot()}},;
                  q_msg_acesso_usr()+"/<B>aixa/Im<P>/<R>equis./<T>ermo"))
return

function i201top
   REQUISIC->(dbseek(dtos(ctod("01/"+right(XANOMES,2)+"/"+left(XANOMES,4))),.T.))
return

function i201bot
   REQUISIC->(qseekn(dtos(qfimmes(ctod("01/"+right(XANOMES,2)+"/"+left(XANOMES,4))))))
return

//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAGEM DA FILIAL _______________________________________________

function i_201a
   FILIAL->(dbseek(REQUISIC->Filial))
return left(FILIAL->Razao,23)

//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAGEM DO CENTRO DE CUSTO  _____________________________________

function i_201b
   CCUSTO->(dbseek(REQUISIC->C_custo))
return left(CCUSTO->Descricao,25)

//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAGEM SE FOI BAIXADO  _________________________________________

function i_201d
   local cSIMNAO := "  NŽO"
   if REQUISIC->Bx_estoque
      cSIMNAO := "  SIM"
   endif
return cSIMNAO

//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO _____________________________________

function i_201c

   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO $ "AE" .and. REQUISIC->Bx_estoque
      qmensa("Requisi‡„o Baixada... Acesso Proibido !","B")
      return ""
   endif

   if cOPCAO == "B"
      if REQUISIC->Bx_estoque
         qmensa("Requisi‡„o Baixada !","B")
         return ""
      else
        i_baixa_estoque()
      endif
   endif

   if cOPCAO == "P"
      i_imp_req()
   endif

   iif(cOPCAO=="R",i_requisicao(),nil)
   iif(cOPCAO=="T",i_termo(),nil)

   if cOPCAO == "AE" .and. REQUISIC->Bx_estoque
      qmensa("Foi baixado, acesso proibido !","B")
      return ""
   endif

   if cOPCAO $ XUSRA
      qlbloc(5,0,"B201A","QBLOC.GLO",1)
      qmensa(qabrev(cOPCAO,"IA",{"Inclus„o... <ESC - Cancela>","Altera‡„o... <ESC - Cancela>"}))
      i_edicao()
     // CCUSTO->(dbSetFilter())
   endif

   setcursor(nCURSOR)

   select REQUISIC

return ""

//////////////////////////////////////////////////////////////////////////////////
// PESQUISA PELO NUMERO DA REQUISICAO ____________________________________________

static function i_requisicao

   local cREQUISICAO := space(5)
   local nREC  := REQUISIC->(recno())

   qmensa("Digite o numero da Requisi‡„o p/ pesquisa:      ")
   qgetx(24,54,@cREQUISICAO ,"99999")

   cREQUISICAO := strzero(val(cREQUISICAO),5)

   REQUISIC->(dbsetorder(1))
   REQUISIC->(dbseek(cREQUISICAO))
   REQUISIC->(dbsetorder(4))
   if REQUISIC->(eof())
      qmensa("Requisi‡„o n„o encontrada !","B")
      REQUISIC->(dbgoto(nREC))
      return
   endif

   if qanomes(REQUISIC->Dt_requisi) <> XANOMES
      qmensa("Requisi‡„o encontrada em: " + dtoc(REQUISIC->Dt_requisi) + ". Utilize op‡„o <802> !","B")
      REQUISIC->(dbgoto(nREC))
      return
   endif

return

//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA _________________________________________

static function i_edicao

   local lCONF
   local aEDICAO := {}
   local bESCAPE := {||empty(fCODIGO).or.(XNIVEL==1.and.!XFLAG).or.;
                       (XNIVEL==1.and.lastkey()==27)}

// MONTA DADOS NA TELA ___________________________________________________________

   if cOPCAO <> "I"

      XNIVEL := 1

      qsay ( 06,21 , REQUISIC->Codigo           )
      qsay ( 06,68 , dtoc(REQUISIC->Dt_Requisi) )
      qsay ( 07,21 , REQUISIC->Filial           ) ; FILIAL->(dbseek(REQUISIC->Filial))
      qsay ( 07,28 , left(FILIAL->Razao,30)      )
      qsay ( 08,21 , REQUISIC->C_custo          ) ; CCUSTO->(dbseek(REQUISIC->C_custo))
      qsay ( 08,28 , left(CCUSTO->Descricao,30)      )
      qsay ( 09,11 , REQUISIC->Cod_veic         ) ; VEICULOS->(dbseek(REQUISIC->Cod_veic))
      qsay ( 09,17 , VEICULOS->Descricao        )
      qsay ( 09,48 , REQUISIC->Cod_equi         ) ; EQUIPTO->(dbseek(REQUISIC->Cod_equi))
      qsay ( 09,54 , left(EQUIPTO->Descricao,24))
      qsay ( 10,21 , REQUISIC->Tipo             ) ; TIPOCONT->(dbseek(REQUISIC->Tipo))
      qsay ( 10,30, alltrim(TIPOCONT->Descricao)    )
      qsay ( 11,14 , REQUISIC->Autorizado       ) ; FUN->(dbseek(REQUISIC->Autorizado))
      qsay ( 11,23 , left(FUN->Nome,30)         )
      qsay ( 12,14 , dtoc(REQUISIC->Dt_Requisi) )

      qsay ( 12,73 , REQUISIC->Nr_os            )

      qsay ( 13,14 , REQUISIC->Recebedor        ) ; FUN->(dbseek(REQUISIC->Recebedor))
      qsay ( 13,23 , left(FUN->Nome,30)         )
      qsay ( 14,14 , REQUISIC->Observacao       )

      if cOPCAO == "C"
        i_atu_lanc()
        keyboard chr(27)
      endif

   endif

   // CONSULTA OU EXCLUSAO _______________________________________________________

   if cOPCAO == "C" ; qwait() ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO _________________________________________________

   aadd(aEDICAO,{{ || qgetx(6,21,@fCODIGO     ,"99999",NIL             )} ,"CODIGO"       })
   aadd(aEDICAO,{{ || qgetx(6,68,@fDT_REQUISI ,"@D",                   )} ,"DT_REQUISI"   })
   aadd(aEDICAO,{{ || view_filial(7,21,@fFILIAL                        )} ,"FILIAL"       })
   aadd(aEDICAO,{{ || NIL },NIL }) // descricao da filial
   aadd(aEDICAO,{{ || view_ccusto(8,21,@fC_CUSTO                       )} ,"C_CUSTO"      })
   aadd(aEDICAO,{{ || NIL },NIL }) // descricao do centro
   aadd(aEDICAO,{{ || view_veic(9,11,@fCOD_VEIC                        )} ,"COD_VEIC"     })
   aadd(aEDICAO,{{ || NIL },NIL }) // descricao da veiculos
   aadd(aEDICAO,{{ || view_equip(9,48,@fCOD_EQUI                       )}  ,"COD_EQUI"    })
   aadd(aEDICAO,{{ || NIL },NIL }) // descricao da equipamentos
   aadd(aEDICAO,{{ || view_tipocont(10,21,@fTIPO                         )}  ,"TIPO"        })
   aadd(aEDICAO,{{ || NIL },NIL }) // descricao do tipo
   aadd(aEDICAO,{{ || view_fun(11,14,@fAUTORIZADO                      )} ,"AUTORIZADO" })
   aadd(aEDICAO,{{ || NIL },NIL }) // nome do funcionario que autorizou
   aadd(aEDICAO,{{ || qgetx(12,14,@fDT_ENTREGA ,"@D",NIL               )} ,"DT_ENTREGA" })

   aadd(aEDICAO,{{ || view_os(12,73,@fNR_OS                            )} ,"NR_OS"        })

   aadd(aEDICAO,{{ || view_fun(13,14,@fRECEBEDOR                       )}   ,"RECEBEDOR"  })
   aadd(aEDICAO,{{ || NIL },NIL }) // nome do funcionario que recebeu
   aadd(aEDICAO,{{ || qgetx(14,14,@fOBSERVACAO  ,"@!",NIL              )}   ,"OBSERVACAO" })

   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO ____________________________________________________

   do while .T.
      qgirabarra()

      REQUISIC->(qpublicfields())

      iif(cOPCAO=="I", REQUISIC->(qinitfields()), REQUISIC->(qcopyfields()))

      XNIVEL := 1
      XFLAG := .T.

      // LOOP PARA ENTRADA DOS CAMPOS ____________________________________________

      do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
         eval ( aEDICAO [XNIVEL,1] )
         if eval ( bESCAPE );REQUISIC->(qreleasefields());return;endif
         if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
         iif ( XFLAG , XNIVEL++ , XNIVEL-- )
         qmensa("")
      enddo

      if ! lCONF ; return ; endif

      if REQUISIC->(iif(cOPCAO=="I",qappend(),qrlock()))

         // AGORA GRAVA E DESTRAVA ARQUIVO _____________________________________

         REQUISIC->(qreplacefields())

      endif

      dbunlockall()

      i_proc_lanc()
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
      case cCAMPO == "CODIGO"
           qsay(6,21,fCODIGO :=strzero(val(fCODIGO),5))
           nINDEX := REQUISIC->(indexord())
           nREC   := REQUISIC->(recno())
           REQUISIC->(dbsetorder(1))
           if cOPCAO == "I"
              if REQUISIC->(dbseek(fCODIGO))
                 qmensa("Requisi‡„o j  Cadastrada !","B")
                 REQUISIC->(dbsetorder(nINDEX))
                 REQUISIC->(dbgoto(nREC))
                 return .F.
              endif
           else
              if ! REQUISIC->(dbseek(fCODIGO))
                 qmensa("Requisi‡„o n„o Cadastrada !","B")
                 REQUISIC->(dbsetorder(nINDEX))
                 REQUISIC->(dbgoto(nREC))
                 return .F.
              endif
           endif

      case cCAMPO == "DT_REQUISI"
           if empty(fDT_REQUISI) ; return .F. ; endif

      case cCAMPO == "FILIAL"
           if empty(fFILIAL) ; return .F. ; endif
           qsay(7,21,fFILIAL)
           if ! FILIAL->(dbseek(fFILIAL))
              qmensa("Filial n„o encontrado !","B")
              return .F.
           endif
           qsay(7,28,left(FILIAL->Razao,40))

           //llif fFILIAL != "0001"
           //   CCUSTO->(dbSetFilter({|| val(left(Codigo,2)) == val(fFILIAL) }, 'val(left(Codigo,2)) == val(fFILIAL)'))
           //endif

      case cCAMPO == "C_CUSTO"
           if empty(fC_CUSTO) ; return .F. ; endif
           qsay(8,21,fC_CUSTO)
           CCUSTO->(dbsetorder(4))
           if ! CCUSTO->(dbseek(fC_CUSTO))
              qmensa("Centro de Custo n„o encontrado !","B")
              return .F.
           endif
           qsay(8,28,CCUSTO->Descricao)

      case cCAMPO == "COD_VEIC"
           if ! empty(fCOD_VEIC)
              qsay(9,11,fCOD_VEIC:=strzero(val(fCOD_VEIC),5))
              if ! VEICULOS->(dbseek(fCOD_VEIC))
                 qmensa("Veiculo n„o encontrado !","B")
                 return .F.
              endif
              qsay(9,17,VEICULOS->Descricao)
           endif

      case cCAMPO == "COD_EQUI"
           if ! empty(fCOD_EQUI)
              qsay(9,48,fCOD_EQUI:=strzero(val(fCOD_EQUI),5))
              if ! EQUIPTO->(dbseek(fCOD_EQUI))
                 qmensa("Equipamento n„o encontrado !","B")
                 return .F.
              endif
              qsay(9,54,left(EQUIPTO->Descricao,24))
           endif

      case cCAMPO == "TIPO"
           if empty(fTIPO) ; return .F. ; endif
           qsay(10,21,fTIPO:=strzero(val(fTIPO),6))
           if ! TIPOCONT->(dbseek(fTIPO))
              qmensa("Tipo Contabil n„o encontrado !","B")
              return .F.
           endif
           qsay(10,30,alltrim(TIPOCONT->Descricao))

      case cCAMPO == "AUTORIZADO"
           if empty(fAUTORIZADO) ; return .F. ; endif
           qsay(11,14,fAUTORIZADO:=strzero(val(fAUTORIZADO),6))
           if ! FUN->(dbseek(fAUTORIZADO))
              qmensa("Funcion rio n„o encontrado !","B")
              return .F.
           endif
           qsay(11,23,left(FUN->Nome,30))

      case cCAMPO == "NR_OS"
//         if empty(fNR_OS) .and. fESTOQUE == "N" ; return .F. ; endif
           qsay(12,73,fNR_OS)
           if !empty(fNR_OS)
              if ! OS->(dbseek(fNR_OS))
                 qmensa("C¢digo da Ordem de Servi‡o n„o encontrado !","B")
                 return .F.
              endif
           Endif
           if OS->Bloq == "S"
              qmensa("Aten‡„o !! Esta O.S. j  foi encerrada !!","B")
              return .F.
           endif

      case cCAMPO == "RECEBEDOR"
           if empty(fRECEBEDOR) ; return .F. ; endif
           qsay(13,14,fRECEBEDOR:=strzero(val(fRECEBEDOR),6))
           if ! FUN->(dbseek(fRECEBEDOR))
              qmensa("Funcion rio n„o encontrado !","B")
              return .F.
           endif
           qsay(13,23,left(FUN->Nome,30))

   endcase

return .T.

//////////////////////////////////////////////////////////////////////////////////
// FUN€AO PARA EXCLUIR REQUISICAO DE MATERIAL ___________________________________

static function i_exclusao

   if qconf("Confirma exclus„o desta Requisi‡„o de Material ?")
      if ITENS_RQ->(qflock()) .and. REQUISIC->(qrlock())
         ITENS_RQ->(dbseek(REQUISIC->Codigo))
         do while ! ITENS_RQ->(eof()) .and. ITENS_RQ->Cod_req == REQUISIC->Codigo
            ITENS_RQ->(dbdelete())
            ITENS_RQ->(dbskip())
         enddo
         REQUISIC->(dbdelete())
         REQUISIC->(qunlock())
         ITENS_RQ->(qunlock())
      else
         qm3()
      endif
   endif

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DOS PRODUTOS _______________________________

function i_proc_lanc

// LOOP PRINCIPAL ___________________________________________________________

setcolor("W/B")

PROD->(Dbsetorder(4))

ITENS_RQ->(qview({{"Cod_Produt/Cod."                                      ,2},;
                  {"f201a()/Descri‡„o"                                    ,0},;
                  {"transform(Vl_unitari, '@E 999,999,999.99999')/Vl.Unit."  ,0},;
                  {"transform(Quantidade,'@E 999999.999')/Quant."         ,0},;
                  {"f201b()/Un."                                          ,0},;
                  {"f201c()/Val. Total"                                   ,0}},;
                  "15002379S",;
                  {NIL,"f201d",NIL,NIL},;
                  {"ITENS_RQ->Cod_req == REQUISIC->Codigo",{||f201top()},{||f201bot()}},;
                  "<I>nc./<A>lt./<C>on.<E>xc."))

return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IR PARA O INICIO DOS DADOS FILTRADOS _________________________

function f201top
   ITENS_RQ->(dbsetorder(1))
   ITENS_RQ->(dbseek(REQUISIC->Codigo))
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IR PARA O FINAL DOS DADOS FILTRADOS __________________________

function f201bot
   ITENS_RQ->(dbsetorder(1))
   ITENS_RQ->(qseekn(REQUISIC->Codigo))
return

/////////////////////////////////////////////////////////////////////////////
// RETORNA A DESCRICAO DO PRODUTO __________________________________________

function f201a

   local cDESCRICAO := space(25)
   PROD->(Dbsetorder(4))
   if ! empty(ITENS_RQ->Cod_produt)
      PROD->(dbseek(left(ITENS_RQ->Cod_produt,5)))
      cDESCRICAO := left(PROD->Descricao,15)
   endif

return cDESCRICAO

/////////////////////////////////////////////////////////////////////////////
// RETORNA A UNIDADE DO PRODUTO _____________________________________________

function f201b
   PROD->(dbseek(left(ITENS_RQ->Cod_produt,5)))
   UNIDADE->(dbseek(PROD->Unidade))
return UNIDADE->Sigla

/////////////////////////////////////////////////////////////////////////////
// RETORNA O VALOR TOTAL DO PRODUTO _________________________________________

function f201c
return transform(ITENS_RQ->Vl_unitari * ITENS_RQ->Quantidade,"@E 9,999,999.99")

/////////////////////////////////////////////////////////////////////////////
// FUNCAO DE CONTROLE PRINCIPAL ANTES DE PROCESSAR A TECLA ACIONADA _________

function f201d

   local nCURSOR := setcursor(1)
   parameters cOPCAO

   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO $ XUSRA
      qlbloc(13,08,"B201B","QBLOC.GLO",1)
      i_processa_acao()
   endif

   setcursor(nCURSOR)

return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO DE BROWSE _________________________________________________________

static function i_processa_acao

   local lCONF
   local aEDICAO := {}
   local bESCAPE := {||empty(fCOD_PRODUT).or.(XNIVEL==1.and.!XFLAG).or.;
                       (XNIVEL==1.and.lastkey()==27).or.;
                       (XNIVEL==2.and.cOPCAO=="A".and.!XFLAG)}

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"

      XNIVEL := 1
      qrsay ( XNIVEL++ , ITENS_RQ->Cod_produt          , "@R 99999"     ) ; PROD->(dbseek(left(ITENS_RQ->Cod_produt,5)))
      qrsay ( XNIVEL++ , left(PROD->Descricao,40)                       )
      qrsay ( XNIVEL++ , ITENS_RQ->Vl_unitari, "@E 99,999,999.99999"    )
      qrsay ( XNIVEL++ , ITENS_RQ->Lote , "@r 9999999999"               )
      qrsay ( XNIVEL++ , ITENS_RQ->Quantidade, "@E 999999.999"         )
      qrsay ( XNIVEL++ , ITENS_RQ->Vl_unitari * ITENS_RQ->Quantidade, "@E 99,999,999.99" )

   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exc_itens_rq() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || view_prod(-1,0,@fCOD_PRODUT                  ) } ,"COD_PRODUT"})
   aadd(aEDICAO,{{ || NIL                                            } ,NIL         })

   aadd(aEDICAO,{{ || qgetx(-1,0,@fVL_UNITARI , "@E 99,999,999.99999")} ,"VL_UNITARI" })
   aadd(aEDICAO,{{ || view_lote(-1,0,@fLOTE , "@r 9999999999"      ) } ,"LOTE"      })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fQUANTIDADE , "@E 999999.999"   ) } ,"QUANTIDADE"})

   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   ITENS_RQ->(qpublicfields())

   iif(cOPCAO=="I",ITENS_RQ->(qinitfields()),ITENS_RQ->(qcopyfields()))

   XNIVEL := 1
   XFLAG  := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; ITENS_RQ->(qreleasefields()) ; return ; endif
      if ! i_crit2( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   if ! lCONF ; return ; endif

   // GRAVACAO ______________________________________________________________

   if REQUISIC->(qrlock()) .and. ITENS_RQ->(iif(cOPCAO=="I",qappend(),qrlock()))
      if cOPCAO == "I"
         fCOD_REQ := fCODIGO
      endif
      ITENS_RQ->(qreplacefields())
      ITENS_RQ->(qunlock())

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

      case cCAMPO == "COD_PRODUT"

           INVENT->(DbclearFilter())
           qrsay(XNIVEL,fCOD_PRODUT:=strzero(val(fCOD_PRODUT),5))

           if ! PROD->(dbseek(fCOD_PRODUT))
              qmensa("Produto n„o encontrado !","B")
              return .F.
           endif

           fVL_UNITARI := PROD->Preco_cust

           INVENT->(dbSetFilter({|| Cod_Prod == fCOD_PRODUT .and. Filial == REQUISIC->FILIAL }))

           qrsay ( XNIVEL+1 , left(PROD->Descricao,40) )

      case cCAMPO == "LOTE"

           if empty(fLOTE)
              fLOTE := "0000000000"
              qrsay(XNIVEL,fLOTE)
            else
              fLOTE := strzero(val(fLOTE),10)
              qrsay(XNIVEL,fLOTE)
            endif


            //qmensa("Codigo.: "+fCOD_PRODUT)
            //qinkey(0)

           if ! INVENT->(dbseek(alltrim(fFILIAL)+fCOD_PRODUT+fLOTE))
              qmensa("N„o Existe Invent rio para este Produto !","B")
              fLOTE := "          "
              return .F.
           endif

           if INVENT->Quant_atu <= 0 .or. fQUANTIDADE > INVENT->Quant_atu
              qmensa("Estoque Insuficiente !","B")
              return .F.
           endif

      case cCAMPO == "QUANTIDADE"
           qrsay(XNIVEL+1,transform(fVL_UNITARI*fQUANTIDADE, "@e 99,999,999.99"))

   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXCLUIR ITENS_RQAMENTOS DO REQUISIC ________________________________

static function i_exc_itens_rq

   if qconf("Confirma exclus„o do Produto ?")
      if ITENS_RQ->(qrlock())
         ITENS_RQ->(dbdelete())
         ITENS_RQ->(qunlock())
      else
         qm3()
      endif
   endif

return

////////////////////////////////////////////////////////////////////////////////////
static function i_atu_lanc

setcolor("W/B")

ITENS_RQ->(qview({{"Cod_Produt/Cod."                                      ,2},;
                  {"f201a()/Descri‡„o"                                    ,0},;
                  {"transform(Vl_unitari, '@E 999,999,999.99999')/Vl.Unit."  ,0},;
                  {"transform(Quantidade,'@E 999999.999')/Quant."         ,0},;
                  {"f201b()/Un."                                          ,0},;
                  {"f201c()/Val. Total"                                   ,0}},;
                  "15002379S",;
                  {NIL,NIL,NIL,NIL},;
                  {"ITENS_RQ->Cod_req == REQUISIC->Codigo",{||f201top()},{||f201bot()}},;
                 "<ESC> para sair" ))

return ""

/////////////////////////////////////////////////////////////////
// BAIXA DO PRODUTO - COMPRAS ___________________________________

static function i_baixa_estoque

   local lCONF
   local cFATOR    := 1
   local cPRIMEIRO := .T.
   local cSAL_ANT  := 0

   lCONF := qconf("Confirma Baixar no Estoque este lan‡amento ?")

   if ! lCONF; return .T.; Endif

   PROD->(Dbsetorder(4))

   if REQUISIC->(qrlock())

      if ITENS_RQ->(dbseek(REQUISIC->Codigo))

         do while ITENS_RQ->Cod_req == REQUISIC->Codigo .and. ! ITENS_RQ->(eof())

            PROD->(Dbsetorder(4))
            INVENT->(dbsetorder(1))
            if INVENT->(dbseek(alltrim(REQUISIC->Filial)+ITENS_RQ->Cod_produt+ITENS_RQ->Lote))

               if cPRIMEIRO

                  if INVENT->Quant_atu <= 0 .or. INVENT->Quant_atu < ITENS_RQ->Quantidade

                     lCONF := qconf("N„o Existe estoque deste produto, gera Ordem de Compra ?")

                     if ! lCONF
                        return .F.
                     else
                        gera_oc()
                        return
                     endif

                  endif

                  cPRIMEIRO := .F.

               endif

               cSAL_ANT := INVENT->Quant_atu
               if INVENT->(qrlock())
                  replace INVENT->Quant_atu  with ( INVENT->Quant_atu - ITENS_RQ->Quantidade  )
                  INVENT->(qunlock())
               else
                  qmensa("Nao foi possivel bloquear aqruivo pra gravacao!","B")
               endif

               replace REQUISIC->Bx_estoque with .T.

               if MOVIMENT->(qrlock()) .and. MOVIMENT->(qappend())
                  replace MOVIMENT->Data       with REQUISIC->Dt_requisi
                  replace MOVIMENT->Filial     with REQUISIC->Filial
                  replace MOVIMENT->Cod_prod   with right(PROD->Codigo,5)
                  replace MOVIMENT->Quantidade with ITENS_RQ->Quantidade
                  replace MOVIMENT->Val_uni    with INVENT->Preco_uni
                  replace MOVIMENT->Saldo_ant  with cSAL_ANT
                  replace MOVIMENT->Tipo       with "S"
                  replace MOVIMENT->Contabil   with .T.
               endif

            endif

            ITENS_RQ->(dbskip())

         enddo

      endif
   endif

   dbunlockall()

return

////////////////////////////////////////////////////////////////////////////////////
// FUNCAO QUE GERA ORDEM DE COMPRA A PARTIR DA BAIXA DA REQUISICAO ________________

static function gera_oc

    if REQUISIC->(qrlock()) .and. ORDEM->(qflock()) .and. CONFIG->(qrlock()) .and. ORDEM->(qappend())

       replace ORDEM->Codigo        with strzero(CONFIG->Cod_ordem + 1,5)
       replace ORDEM->Data          with REQUISIC->Dt_requisi
       replace ORDEM->Filial        with REQUISIC->Filial
       replace ORDEM->Centro        with REQUISIC->C_custo
       replace ORDEM->Veiculo       with REQUISIC->Cod_veic
       replace ORDEM->Equipament    with REQUISIC->Cod_equi

       replace CONFIG->Cod_ordem    with (CONFIG->Cod_ordem + 1)

       do while ! ITENS_RQ->(eof()) .and. ITENS_RQ->Cod_req == REQUISIC->Codigo .and. ITENS_RQ->(qrlock()) .and. ITENS_OC->(qrlock()) .and. ITENS_OC->(qappend())

          replace ITENS_OC->Cod_ord    with ORDEM->Codigo
          replace ITENS_OC->Produto    with ITENS_RQ->Cod_produt
          replace ITENS_OC->Quantidade with ITENS_RQ->Quantidade

          ITENS_RQ->(Dbskip())

       enddo

       dbunlockall()

    else

       qm2()

    endif

return


//////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IMPRIMIR REQUISICAO ___________________________________________

function i_imp_req

   local cTITULO
   local nTOT_PROD := nLIN := nTOT_BRU := nPROD := 0

   cTITULO := "EMISSAO DE REQUISICAO DE MATERIAIS No."+transform(CODIGO, "@R 999999")+"   Data Emissao: "+dtoc(REQUISIC->Dt_requisi)

   PROD->(Dbsetorder(4))

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif

   if ! qlineprn() ; return ; endif


   qpageprn()
   qcabecprn(cTITULO,80)
   @ prow(),pcol() say XCOND1
   @ prow()+1,0 say "ITEN     UN.  QUANT.   PRODUTO  FORNECEDOR  DESCRICAO DO PRODUTO                            UNITARIO                 TOTAL"
   @ prow()+1,0 say ""

   ITENS_RQ->(Dbseek(REQUISIC->Codigo))

   nCONT := 1

   do while ! ITENS_RQ->(eof()) .and. ITENS_RQ->Cod_req == REQUISIC->Codigo

      PROD->(Dbseek(ITENS_RQ->Cod_produt))
      @ prow()+1,0  say strzero(nCONT,2)
      UNIDADE->(Dbseek(PROD->Unidade))
      @ prow()  ,09  say UNIDADE->Sigla
      @ prow()  ,14  say transform(ITENS_RQ->Quantidade, "@E 999999.999")
      @ prow()  ,25  say PROD->Cod_ass
      @ prow()  ,34  say left(PROD->Cod_fornec,7)
      @ prow()  ,44  say left(PROD->Descricao,40)
      @ prow()  ,90  say transform(ITENS_RQ->Vl_unitari, "@E 999,999.99")
      @ prow()  ,110 say transform((ITENS_RQ->Quantidade * ITENS_RQ->Vl_unitari), "@E 999,999.99")
      nTOT_PROD  := nTOT_PROD +  (ITENS_RQ->Quantidade * ITENS_RQ->Vl_unitari)

      nCONT++

      ITENS_RQ->(Dbskip())

   enddo

   @ prow(),pcol() say XCOND0

   @ prow()+1,0 say replicate("-",80)
   @ prow()+1,41 say " Total ..........> "+transform(nTOT_PROD, "@E 99,999,999.99")
   @ prow()+1,0 say replicate("-",80)

   @ prow()+1,0 say "Observacao: "+REQUISIC->Observacao
   @ prow()+1,0 say replicate("-",80)

   @ prow()+4,0  say "Requisitado por: "+iif( FUN->(Dbseek(REQUISIC->Recebedor)) , FUN->Nome,"")
   @ prow()  ,45 say "Autorizado por: "+iif( FUN->(Dbseek(REQUISIC->Autorizado)) , FUN->Nome,"")
   @ prow()+2,0 say XDENFAT+"________________________________                 _______________________________"
   @ prow()+1,0 say "             Assinatura                                        Assinatura"

   nCONT += 14

   qstopprn()

return

//////////////////////////////////////////////////////////////////////////////
// ROTINA DESENVOLVIDA POR LUCIANO DA SILVA GORSKI ///////////////////////////
// FUNCAO PARA IMPRIMIR TERMO DE RESPONSABILIDADE ___________________________________________


function i_termo

   local cTITULO
   local nTOT_PROD := nLIN := nTOT_BRU := nPROD := 0

   if ! quse( XDRV_RH ,"CONFIG",NIL,"E","RHCONFIG")
      qmensa("N„o foi poss¡vel abrir arquivo CONFIG.DBF !! Tente novamente.")
      return
   endif
    
   cTITULO := "EMISSAO DE TERMO DE RESPONSABILIDADE -Ficha Nr."+transform(REQUISIC->Codigo, "@R 999999")+" Data Emissao: "+dtoc(REQUISIC->Dt_requisi)

   PROD->(Dbsetorder(4))

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif

   if ! qlineprn() ; return ; endif

   qpageprn()

   qcabecprn(cTITULO,80)
   @ prow()+1,0 say "Nome...: " + iif( FUN->(Dbseek(REQUISIC->Recebedor)) , FUN->Nome,"")
   cFUNC := FUN->Matricula

   SITUA->(Dbsetorder(1))
   SITUA->(Dbgotop())
   SITUA->(dbSetFilter({|| Anomes == qanomes(RHCONFIG->Data_Atual)},"Anomes == qanomes(RHCONFIG->Data_Atual)"))

   SITUA->(Dbseek(cFUNC))
   CARGO->(dbseek(SITUA->Cargo))

   @ prow()+1,0 say "Funcao.: " + CARGO->Descricao
   CCUSTO->(dbsetorder(4))
   CCUSTO->(dbseek(REQUISIC->C_custo))
   @ prow()+1,0 say "Obra...: " + CCUSTO->Descricao
   @ prow()+1,0 say "Data...: " + dtoc(REQUISIC->Dt_entrega)
   @ prow()+1,0 say replicate("=",80)
   @ prow()+1,0 say "  QUANT.   DESCRICAO DO PRODUTO                 CODIGO      UNITARIO       TOTAL"
   @ prow()+1,0 say ""

   ITENS_RQ->(Dbseek(REQUISIC->Codigo))

   nCONT := 1

   do while ! ITENS_RQ->(eof()) .and. ITENS_RQ->Cod_req == REQUISIC->Codigo

      PROD->(Dbseek(ITENS_RQ->Cod_produt))
      @ prow()+1,00  say transform(ITENS_RQ->Quantidade, "@E 999999.999")
      @ prow()  ,11  say left(PROD->Descricao,30)
      @ prow()  ,48  say PROD->Codigo
      @ prow()  ,58  say transform(ITENS_RQ->Vl_unitari, "@E 999,999.99")
      @ prow()  ,70  say transform((ITENS_RQ->Quantidade * ITENS_RQ->Vl_unitari), "@E 999,999.99")
      nTOT_PROD  := nTOT_PROD +  (ITENS_RQ->Quantidade * ITENS_RQ->Vl_unitari)

      nCONT++

      ITENS_RQ->(Dbskip())

   enddo

   @ prow(),pcol() say XCOND0

   @ prow()+1,0 say replicate("-",80)
   @ prow()+1,41 say "        Total ..........> "+transform(nTOT_PROD, "@E 99,999,999.99")
   @ prow()+1,0 say replicate("-",80)

   @ prow()+1,0 say "Observacao: "+REQUISIC->Observacao
   @ prow()+1,0 say ""
   @ prow()+1,0 say "      DECLARO QUE RECEBI NESTA DATA OS UNIFORMES ACIMA DISCRIMINADOS, PELO QUAIS"
   @ prow()+1,0 say "ASSUMO TOTAL RESPONSABILIDADE, DESDE JA AUTORIZANDO O DESCONTO EM MEUS VENCIMEN-"
   @ prow()+1,0 say "TOS DOS UNIFORMES QUE NAO DEVOLVER A EMPRESA."
   @ prow()+1,0 say replicate("-",80)

   @ prow()+4,0  say "Requisitado por: "+iif( FUN->(Dbseek(REQUISIC->Recebedor)) , left(FUN->Nome,25),"")
   @ prow() ,50  say "Almox.: "+iif( FUN->(Dbseek(REQUISIC->Autorizado)) , left(FUN->Nome,25),"")
   @ prow()+2,0 say XDENFAT+"________________________________                 _______________________________"
   @ prow()+1,0 say "             Assinatura                                        Assinatura"

   nCONT += 14

   RHCONFIG->(Dbclosearea())
   REQUISIC->(dbsetorder(4))

   qstopprn()

return
