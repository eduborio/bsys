/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO COMERCIO
// OBJETIVO...: LANCAMENTO DE PEDIDO DE VENDA
// ANALISTA...:
// PROGRAMADOR: EDUARDO BORIO
// INICIO.....: Dezembro de 2006
// OBS........:
function es216

#include "inkey.ch"

private fTOTAL := 0
private nITENS := 0
private cES    := " "
private lALT   := .F.
private sBLOC1  := qlbloc("B216D","QBLOC.GLO")

CCUSTO->(Dbsetorder(4))

/////////////////////////////////////////////////////////////////////////////
// MANUTENCAO DE PEDIDO DE VENDA ___________________________________________

OME->(qview({{"Codigo/Ordem"            ,1},;
             {"Dt_Emissao/Emissao"      ,2},;
             {"i_216a()/Tipo",0}},"P",;
             {NIL,"i_216c",NIL,NIL},;
              NIL,q_msg_acesso_usr()+"/im<P>rime "))
return

//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAGEM DO CLIENTE ______________________________________________

function i_216a

return

//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAGEM DO CENTRO DE CUSTO  _____________________________________

function i_216b
   CCUSTO->(dbseek(OME->C_custo))
return left(CCUSTO->Descricao,18)

//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO _____________________________________

function i_216c

   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))


     iif(cOPCAO == "P", i_imprime(),)

   if cOPCAO $ XUSRA

      iif(cOPCAO == "A", lALT := .T.,)

      qlbloc(5,0,"B216A","QBLOC.GLO",1)

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
   local bESCAPE := {||empty(fCODIGO).or.(XNIVEL==1.and.!XFLAG).or.;
                       (XNIVEL==1.and.lastkey()==27)}

   fTOTAL := 0
   nCOMISSAO:= 0
   fPARC  := 0
   cES    := " "

// MONTA DADOS NA TELA ___________________________________________________________

   if cOPCAO <> "I"

      XNIVEL := 1

      qsay ( 06,17 , OME->Codigo           )
      qsay ( 06,42 , dtoc(OME->Dt_emissao) )
      qsay ( 07,24 , OME->Fi_origem  ) ; FILIAL->(dbseek(OME->Fi_origem))
      qsay ( 07,32 , left(FILIAL->Razao,35)  )
      qsay ( 08,24 , OME->Fi_destino  ) ; FILIAL->(dbseek(OME->Fi_destino))
      qsay ( 08,32 , left(FILIAL->Razao,35)  )
      qsay ( 09,24 , OME->CCusto       ) ; CCUSTO->(dbseek(OME->CCusto))
      qsay ( 09,32 , left(CCUSTO->Descricao,35)   )
      qsay ( 10,24,  qabrev(OME->Tipo,"123", {"1 Entrada - Transferencia","2 Saida - Transferencia","3 Saida - Quebra"}))
      qsay ( 11,14 , Left(OME->Obs,43)             )


      if cOPCAO == "C"
        i_atu_lanc()
        keyboard chr(27)
      endif

   endif

   // CONSULTA OU EXCLUSAO _______________________________________________________

   if cOPCAO == "C" ; qwait() ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO _________________________________________________

   aadd(aEDICAO,{{ || qgetx(6,17,@fCODIGO,"9999999",                    )},"CODIGO"})
   aadd(aEDICAO,{{ || qgetx(6,42,@fDT_EMISSAO,"@D",                     )} ,"DT_EMISSAO"   })

   aadd(aEDICAO,{{ || view_filial(7,24,@fFI_ORIGEM                      )} ,"FI_ORIGEM"      })
   aadd(aEDICAO,{{ || NIL },NIL }) // Filial Origem

   aadd(aEDICAO,{{ || view_filial(8,24,@fFI_DESTINO                     )} ,"FI_DESTINO"   })
   aadd(aEDICAO,{{ || NIL },NIL }) // Filial Destino

   aadd(aEDICAO,{{ || view_ccusto(9,24,@fCCUSTO                         )} ,"CCUSTO"   })
   aadd(aEDICAO,{{ || NIL },NIL }) // Centro deCusto

   aadd(aEDICAO,{{ || qesco(10,24,@fTIPO ,sBLOC1                       )}  ,"TIPO" })

   aadd(aEDICAO,{{ || qgetx(11,14,@fOBS,"@!S55",NIL                    )}   ,"OBS"        })


   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO ____________________________________________________

   do while .T.
      qgirabarra()

      OME->(qpublicfields())

      iif(cOPCAO=="I", OME->(qinitfields()), OME->(qcopyfields()))

      XNIVEL := 1
      XFLAG := .T.

      // LOOP PARA ENTRADA DOS CAMPOS ____________________________________________

      do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
         eval ( aEDICAO [XNIVEL,1] )
         if eval ( bESCAPE );OME->(qreleasefields());return;endif
         if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
         iif ( XFLAG , XNIVEL++ , XNIVEL-- )
         qmensa("")
      enddo

      if ! lCONF ; return ; endif

      if OME->(iif(cOPCAO=="I",qappend(),qrlock()))

         // AGORA GRAVA E DESTRAVA ARQUIVO _____________________________________
         OME->(qreplacefields())
      endif

      dbunlockall()

      i_proc_ped()
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

      case cCAMPO == "DATA"

           if empty(fDT_EMISSAO) ; return .F. ; endif

      case cCAMPO == "FI_ORIGEM"
           if empty(fFI_ORIGEM) ; return .F. ; endif
           qsay(7,24,fFI_ORIGEM)
           if ! FILIAL->(dbseek(fFI_ORIGEM))
              qmensa("Filial n„o encontrada !","B")
              return .F.
           endif
           qsay(7,31,left(FILIAL->Razao,40))

      case cCAMPO == "FI_DESTINO"
           if empty(fFI_DESTINO) ; return .F. ; endif
           qsay(8,24,fFI_DESTINO)
           if ! FILIAL->(dbseek(fFI_DESTINO))
              qmensa("Filial n„o encontrada !","B")
              return .F.
           endif
           qsay(8,31,left(FILIAL->Razao,40))

      case cCAMPO == "CCUSTO"
           if empty(fCCUSTO) ; return .F. ; endif
           qsay(9,24,fCCUSTO)
           if ! CCUSTO->(dbseek(fCCUSTO))
              qmensa("Centro de Custo nÆo encontrado !","B")
              return .F.
           endif
           qsay(9,31,left(CCUSTO->Descricao,40))



      case cCAMPO == "TIPO"
           if empty(fTIPO) ; return .F. ; endif
           qsay(10,24, qabrev(OME->Tipo,"123", {"Entrada - Transferencia","Saida - Transferencia","Saida - Quebra"}))

           if fTIPO $ "2-3"
              cES := "S"
              fES := cES
           else
              cES := "E"
              fES := cES
           Endif

   endcase

return .T.

//////////////////////////////////////////////////////////////////////////////////
// FUN€AO PARA EXCLUIR PEDIDO DE VENDA __________________________________________

static function i_exclusao

   if qconf("Confirma exclus„o desta Ordem de Movimenta‡Æo ?")

      /// rotina para voltar o estoque dos produtos digitados no Pedido Deletado !

      ITEN_OME->(Dbgotop())
      ITEN_OME->(Dbseek(OME->Codigo))
      if OME->Tipo $ "2-3"
         cES := "S"
      else
         cES := "E"
      Endif


      do while ! ITEN_OME->(eof()) .and. ITEN_OME->Cod_ome == OME->Codigo

         PROD->(Dbsetorder(4))
         INVENT->(dbsetorder(1))

         if INVENT->(dbseek(OME->Fi_origem+ITEN_OME->Cod_prod+ITEN_OME->Lote)) .and. INVENT->(qrlock())
            if cES == "S" //Se For saida Aumenta estoque senao diminui
               replace INVENT->Quant_atu with (INVENT->Quant_atu + ITEN_OME->Quantidade)
            else
               replace INVENT->Quant_atu with (INVENT->Quant_atu - ITEN_OME->Quantidade)
            endif
            INVENT->(qunlock())
         endif

         ITEN_OME->(Dbskip())

      enddo

      if ITEN_OME->(qflock()) .and. OME->(qrlock())

         ITEN_OME->(dbseek(OME->Codigo))

         do while ! ITEN_OME->(eof()) .and. ITEN_OME->Cod_ome == OME->Codigo // itens do pedido (produtos)
            ITEN_OME->(dbdelete())
            ITEN_OME->(dbskip())
         enddo

         OME->(dbdelete())
         OME->(qunlock())
         ITEN_OME->(qunlock())

      else
         qm3()
      endif
   endif

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DOS PRODUTOS _______________________________

function i_proc_ped


// LOOP PRINCIPAL ___________________________________________________________

setcolor("W/B")

if cOPCAO == "A"
   fTOTAL := 0
   lALT := .T.
endif

PROD->(Dbsetorder(4))

   ITEN_OME->(qview({{"Cod_prod/Cod."                                        ,2},;
                     {"f216a()/Descri‡„o"                                    ,0},;
                     {"transform(Quantidade,'@R 9999999')/Quant."           ,0},;
                     {"f216b()/Un."                                          ,0}},;
                     "12002179S",;
                     {NIL,"f216d",NIL,NIL},;
                     {"ITEN_OME->Cod_ome == OME->Codigo",{||f216top()},{||f216bot()}},;
                     "<I>nc./<A>lt./<C>on./<E>xc./<D>uplicatas"))
return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IR PARA O INICIO DOS DADOS FILTRADOS _________________________

function f216top
   ITEN_OME->(dbsetorder(1))
   ITEN_OME->(dbseek(OME->Codigo))
   qsay(22,16,transform(fTOTAL,"@E 99,999,999.99"))

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IR PARA O FINAL DOS DADOS FILTRADOS __________________________

function f216bot
   ITEN_OME->(dbsetorder(1))
   ITEN_OME->(qseekn(OME->Codigo))
   qsay(22,16,transform(fTOTAL,"@E 99,999,999.99"))
return

/////////////////////////////////////////////////////////////////////////////
// RETORNA A DESCRICAO DO PRODUTO __________________________________________

function f216a

   local cDESCRICAO := space(30)
   PROD->(Dbsetorder(4))
   if ! empty(ITEN_OME->Cod_prod)
      PROD->(dbseek(left(ITEN_OME->Cod_prod,5)))
      cDESCRICAO := left(PROD->Descricao,30)
   endif
   qsay(22,16,transform(fTOTAL,"@E 99,999,999.99"))

return cDESCRICAO


function f216mar

   local cDESCRICAO := space(3)
   if ITEN_OME->Marcado == "*"
      cDESCRICAO := "SIM"
   else
      cDESCRICAO := "   "
   endif

return cDESCRICAO


function f216m
   local cFABR := space(4)

   PROD->(Dbsetorder(4))
   if ! empty(ITEN_OME->Cod_prod)
      PROD->(dbseek(left(ITEN_OME->Cod_prod,5)))
      cFABR := left(PROD->Cod_fabr,4)
   endif
   rtrim(cFABR)

return cFABR

function f216m1
   local cASS := space(7)

   PROD->(Dbsetorder(4))
   if ! empty(ITEN_OME->Cod_prod)
      PROD->(dbseek(left(ITEN_OME->Cod_prod,5)))
      cASS := left(PROD->Cod_ass,7)
   endif
   rtrim(cASS)

return cASS


/////////////////////////////////////////////////////////////////////////////
// RETORNA A UNIDADE DO PRODUTO _____________________________________________

function f216b
   PROD->(dbseek(left(ITEN_OME->Cod_prod,5)))
   UNIDADE->(dbseek(PROD->Unidade))
return UNIDADE->Sigla

/////////////////////////////////////////////////////////////////////////////
// RETORNA O VALOR TOTAL DO PRODUTO _________________________________________


/////////////////////////////////////////////////////////////////////////////
// FUNCAO DE CONTROLE PRINCIPAL ANTES DE PROCESSAR A TECLA ACIONADA _________

function f216d

   local nCURSOR := setcursor(1)
   parameters cOPCAO

   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO $ XUSRA

      qlbloc(08,08,"B216B","QBLOC.GLO",1)

      i_processa_item()
   endif


   setcursor(nCURSOR)

return ""






/////////////////////////////////////////////////////////////////////////////
// FUNCAO DE BROWSE _________________________________________________________

function i_processa_item

   local lCONF
   local aEDICAO := {}
   local bESCAPE := {||empty(fCOD_PROD).or.(XNIVEL==1.and.!XFLAG).or.;
                       (XNIVEL==1.and.lastkey()==27).or.;
                       (XNIVEL==2.and.cOPCAO=="A".and.!XFLAG)}

   if lALT  // se alteracao - zera o totalizador e refaz a soma das parcelas
      fPARC := 0
   endif

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"

      XNIVEL := 1
      qrsay ( XNIVEL++ , ITEN_OME->Cod_prod            , "@R 99999"                    ) ; PROD->(dbseek(left(ITEN_OME->Cod_prod,5)))
      qrsay ( XNIVEL++ , left(PROD->Descricao,40)                                      )
      qrsay ( XNIVEL++ , ITEN_OME->Lote                                            )
      qrsay ( XNIVEL++ , ITEN_OME->Quantidade                                          )

   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exc_itens_fat() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || view_prod(-1,0,@fCOD_PROD                    ) } ,"COD_PROD"  })
   aadd(aEDICAO,{{ || NIL                                            } ,NIL         })
   aadd(aEDICAO,{{ || view_lote(-1,0,@fLOTE, "@r 9999999999"   ) } ,"NUM_LOTE"  })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fQUANTIDADE , "@r 9999999"      ) } ,"QUANTIDADE"})

   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   ITEN_OME->(qpublicfields())

   iif(cOPCAO=="I",ITEN_OME->(qinitfields()),ITEN_OME->(qcopyfields()))

   if cOPCAO == "A"
      XNIVEL := 3
   else
      XNIVEL := 1
   endif

   XFLAG  := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; ITEN_OME->(qreleasefields()) ; return ; endif
      if ! i_crit2( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   if ! lCONF ; return ; endif

   // GRAVACAO ______________________________________________________________

   if OME->(qrlock()) .and. ITEN_OME->(iif(cOPCAO=="I",qappend(),qrlock()))

      if cOPCAO == "I"
         fCOD_OME := fCODIGO
         fDATA    := fDT_EMISSAO
      endif

      fDATA    := fDT_EMISSAO
      INVENT->(Dbsetorder(1))

      if cOPCAO == "A" // volta o estoque anterior a alteracao, para baixar corretamente a quantidade
         if INVENT->(dbseek(fFI_ORIGEM+fCOD_PROD+fLOTE)) .and. INVENT->(qrlock())
            if OME->Es == "S"
               replace INVENT->Quant_atu with (INVENT->Quant_atu + ITEN_OME->Quantidade)
            else
               replace INVENT->Quant_atu with (INVENT->Quant_atu - ITEN_OME->Quantidade)
            endif
            INVENT->(qunlock())
         endif
      endif

      ITEN_OME->(qreplacefields())
      ITEN_OME->(qunlock())


      // rotina que baixa o produto do Estoque quando e' confirmado no pedido


      if PROD->(qrlock())
         if INVENT->(dbseek(fFI_ORIGEM+fCOD_PROD+fLOTE)) .and. INVENT->(qrlock())
            if OME->Es == "S"
               replace INVENT->Quant_atu with (INVENT->Quant_atu - ITEN_OME->Quantidade)
            else
               replace INVENT->Quant_atu with (INVENT->Quant_atu + ITEN_OME->Quantidade)
            endif
            INVENT->(qunlock())
         endif
      Endif
   else

      iif(cOPCAO=="I",qm1(),qm2())

   endif

return

/////////////////////////////////////////////////////////////////////////////
// CRITICAS NA DESCIDA ______________________________________________________

static function i_crit2 ( cCAMPO )
local nORDEM := 0
local nREG   := 0

   qmensa("")

   iif ( cCAMPO == NIL , cCAMPO := "" , NIL )
   if ! XFLAG; return .t.; endif
   do case

      case cCAMPO == "COD_PROD"

           INVENT->(dbClearFilter())
           qrsay(XNIVEL,fCOD_PROD:=strzero(val(fCOD_PROD),5))

           nORDEM := ITEN_OME->(Indexord())
           nREG   := ITEN_OME->(recno())

           if ITEN_OME->(dbseek(OME->Codigo+fCOD_PROD))
              qmensa("Produto ja cadastrado, InclusÆo negada !","B")
              return .F.
           endif

           ITEN_OME->(Dbsetorder(nORDEM))
           ITEN_OME->(Dbgoto(nREG))
           nREG := 0
           nORDEm := 0

           PROD->(Dbsetorder(4))

           if ! PROD->(dbseek(fCOD_PROD))
              qmensa("Produto n„o encontrado !","B")
              return .F.
           endif

           INVENT->(DbSetFilter({|| INVENT->Cod_prod == fCOD_PROD },'Cod_prod == fCOD_PROD'))

//           if CONFIG->Modelo_fat == "1"
//              qrsay ( XNIVEL+1 , left(PROD->Descricao,20)+"/"+PROD->Cod_ass+" - "+left(PROD->Cod_fabr,6) )
//           else
              qrsay ( XNIVEL+1 , left(PROD->Descricao,38) )
//           endif


           Return .T.

      case cCAMPO == "QUANTIDADE"

           if  empty(fQUANTIDADE) ; return .F. ; endif

               INVENT->(dbsetorder(1))
               if ! INVENT->(dbseek(fFI_ORIGEM+fCOD_PROD+fLOTE))
                  qmensa("N„o Existe Inventario deste Produto - Verifique ! ","B")
                  return .F.
               endif

               if INVENT->Quant_atu < fQUANTIDADE
                  qmensa("No estoque tem "+ transform(INVENT->Quant_atu,"@E 999,999.99") + " Unidades","B")
                  return .F.
               endif
               Return .T.


      case cCAMPO == "NUM_LOTE"

              if empty(fLOTE)
                 fLOTE := "0000000000"
                 qrsay(XNIVEL,fLOTE)
              else
                 fLOTE := strzero(val(fLOTE),10)
                 qrsay(XNIVEL,fLOTE)
              endif

              INVENT->(Dbsetorder(1))
              if ! INVENT->(dbseek(fFI_ORIGEM+fCOD_PROD+fLOTE))
                 qmensa("N£mero de Lote deste Produto nÆo encontrado...","B")
                 fLOTE := "          "
                 return .F.
              endif

              if INVENT->Quant_atu <= 0 .or. INVENT->Quant_atu < fQUANTIDADE
                 qmensa("Estoque Insufisciente !","B")
                 fLOTE := "          "
                 return .F.
              endif

   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXCLUIR ITENS DO PEDIDO  _____________________________________

static function i_exc_itens_fat

   if qconf("Confirma exclus„o do Produto ?")

      // rotina que volta a quantidade em estoque pois foi baixa no pedido
      if INVENT->(dbseek(fFI_ORIGEM+ITEN_OME->Cod_prod+ITEN_OME->Lote)) .and. INVENT->(qrlock())
         if OME->Es == "S"
            replace INVENT->Quant_atu with (INVENT->Quant_atu + ITEN_OME->Quantidade)
         else
            replace INVENT->Quant_atu with (INVENT->Quant_atu - ITEN_OME->Quantidade)
         endif
         INVENT->(qunlock())
      endif

      if ITEN_OME->(qrlock())
         ITEN_OME->(dbdelete())
         ITEN_OME->(qunlock())
      else
         qm3()
      endif
   endif

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA DEVOLUCAO de ITENS DO PEDIDO  _____________________________________


////////////////////////////////////////////////////////////////////////////////////
static function i_atu_lanc
   ITEN_OME->(qview({{"Cod_prod/Cod."                                       ,2},;
                     {"f216a()/Descri‡„o"                                    ,0},;
                     {"transform(Quantidade,'@E 99999.99')/Quant."           ,0},;
                     {"f216b()/Un."                                          ,0}},;
                     "12002179S",;
                     {NIL,NIL,NIL,NIL},;
                     {"ITEN_OME->Cod_ome == OME->Codigo",{||f216top()},{||f216bot()}},;
                    "<ESC> para sair" ))


return ""

//////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IMPRIMIR PEDIDO ________________________________________________

static function i_imprime

   local cTITULO
   cTIPO := ""
   cTITULO := "LISTAGEM DA ORDEM No."+OME->Codigo+"   Data Emissao: "+dtoc(OME->Dt_emissao)

   PROD->(Dbsetorder(4))

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif

   if ! qlineprn() ; return ; endif

   if XPAGINA == 0 .or. prow() > K_MAX_LIN
      qpageprn()
      @ prow(),pcol() say XCOND0
      qcabecprn(cTITULO,80)

      FILIAL->(Dbseek(OME->Fi_origem))
      @ prow()+1,0 say "Origem.: "+ FILIAL->Razao

      FILIAL->(Dbseek(OME->Fi_Destino))
      @ prow()+1,0 say "Destino: "+FILIAL->Razao

      CCUSTO->(Dbseek(OME->CCusto))
      @ prow()+1,0 say "Ccusto.: "+CCUSTO->Descricao
      cTIPO := qabrev(OME->Tipo,"123", {"Entrada - Transferencia","Saida - Transferencia","Saida - Quebra"})
      @ prow()+1,0 say "Tipo   : " +cTIPO
      @ prow()+1,0 say "Observacao: "+left(OME->Obs,70)
      @ prow()+1,0 say replicate("-",80)
   endif

   @ prow(),pcol() say XCOND0
   @ prow()+1,0 say "Codigo  Qtde                  Produto                        "
   @ prow()+1,0 say ""

   ITEN_OME->(Dbseek(OME->Codigo))

   do while ! ITEN_OME->(eof()) .and. ITEN_OME->Cod_ome == OME->Codigo

      PROD->(Dbsetorder(4))
      PROD->(Dbseek(ITEN_OME->Cod_prod))
      @ prow()+1,0  say right(PROD->Codigo,5)
      @ prow()  ,6  say transform(ITEN_OME->Quantidade, "@E 99999.99")
      @ prow()  ,16 say left(PROD->Descricao,18)
      @ prow()  ,70 say transform(ITEN_OME->Quantidade,"@R 9999999 ")

      ITEN_OME->(Dbskip())

   enddo


   @ prow()+1,0 say replicate("-",80)

   qstopprn()

return


