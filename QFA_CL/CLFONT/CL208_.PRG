///////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO COMERCIO
// OBJETIVO...: LANCAMENTO DE EMPENHOS/CONVENIOS
// ANALISTA...: Eduardo Borio
// PROGRAMADOR: O Mesmo
// INICIO.....: Fevereiro de 2009
// OBS........:

function cl208
#include "inkey.ch"

private fTOTAL := 0
private cTIPO  := ""
private nITENS := 0
private nSaldo := 0
private cES    := " "
private fPARC  := 0
private nCOMISSAO := 0
private lALT   := .F.
private sBLOC1  := qlbloc("B208D","QBLOC.GLO")

/////////////////////////////////////////////////////////////////////////////
// MANUTENCAO DE PEDIDO DE VENDA ___________________________________________

CONVENIO->(qview({{"Codigo/Lancto"      ,1},;
             {"Dt_emissao/Emissao"      ,2},;
             {"left(Cliente,35)/Cliente",3},;
             {"f208fa()/Faturado"       ,0},;
             {"fcancelado()/Cancelado",0}},"P",;
             {NIL,"i_208c",NIL,NIL},;
              NIL,q_msg_acesso_usr()+"/im<P>rime/<F>Aturado/Cancela<R>"))
return

//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAGEM DO CLIENTE ______________________________________________

function fcancelado()
   local result := ""

   if CONVENIO->Cancelado  == .T.
      result := "Sim"
   endif

return result


function i_208a
   CLI1->(dbseek(CONVENIO->Cod_cli))
return left(CLI1->Razao,25)


function i_208c

   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))


   iif(cOPCAO == "P", i_imprime(),)
   iif(cOPCAO == "R", i_cancelaConv(),)
   iif(cOPCAO == "F", i_faturado(),)


   if cOPCAO $ XUSRA

      iif(cOPCAO == "A", lALT := .T.,)

      qlbloc(5,0,"B208A","QBLOC.GLO",1)

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
   local bESCAPE := {||empty(fDT_EMISSAO).or.(XNIVEL==2.and.!XFLAG).or.;
                       (XNIVEL==2.and.lastkey()==27)}

   fTOTAL := 0
   nCOMISSAO:= 0
   fPARC  := 0
   cES    := " "

// MONTA DADOS NA TELA ___________________________________________________________

   if cOPCAO <> "I"

      XNIVEL := 1

      qsay ( 06,17 , CONVENIO->Codigo           )
      qsay ( 06,42 , dtoc(CONVENIO->Dt_Emissao) )
      qsay ( 07,24 , CONVENIO->Cod_Cli          ) ; CLI1->(dbseek(CONVENIO->Cod_cli))
      qsay ( 07,32 , left(CLI1->Razao,35)  )
      qsay ( 08,24 , CONVENIO->Cod_vended       ) ; VEND->(dbseek(CONVENIO->Cod_vended))
      qsay ( 08,32 , left(VEND->Nome,35)   )
      qsay ( 09,24 , CONVENIO->Cod_repres       ) ; REPRES->(dbseek(CONVENIO->Cod_repres))
      qsay ( 09,32 , left(REPRES->Razao,35)   )
      qsay ( 10,24 , CONVENIO->Filial           ) ; FILIAL->(dbseek(CONVENIO->Filial))
      qsay ( 10,31 , left(FILIAL->Razao,35))
      qsay ( 11,14 , Left(CONVENIO->Obs,43)             )


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
   aadd(aEDICAO,{{ || qgetx(6,42,@fDT_EMISSAO,"@D",                    )} ,"DT_EMISSAO"   })

   aadd(aEDICAO,{{ || view_cli2(7,24,@fCOD_CLI                          )} ,"COD_CLI"      })
   aadd(aEDICAO,{{ || NIL },NIL }) // razao do cliente

   aadd(aEDICAO,{{ || view_vend(8,24,@fCOD_VENDED                      )} ,"COD_VENDED"   })
   aadd(aEDICAO,{{ || NIL },NIL }) // nome do vendedor

   aadd(aEDICAO,{{ || view_repres(9,24,@fCOD_REPRES                      )} ,"COD_REPRES"   })
   aadd(aEDICAO,{{ || NIL },NIL }) // nome do representante


   aadd(aEDICAO,{{ || view_filial(10,24,@fFILIAL                        )} ,"FILIAL"       })
   aadd(aEDICAO,{{ || NIL },NIL }) // descricao da filial


   aadd(aEDICAO,{{ || qgetx(11,14,@fOBS,"@!S43",NIL                    )}   ,"OBS"        })


   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO ____________________________________________________

   do while .T.
      qgirabarra()

      CONVENIO->(qpublicfields())

      iif(cOPCAO=="I", CONVENIO->(qinitfields()), CONVENIO->(qcopyfields()))

      XNIVEL := 2
      XFLAG := .T.

      // LOOP PARA ENTRADA DOS CAMPOS ____________________________________________
      //if cOPCAO == "A"
      //   cTIPO := fTIPO
      //endif

      do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
         eval ( aEDICAO [XNIVEL,1] )
         if eval ( bESCAPE );CONVENIO->(qreleasefields());return;endif
         if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
         iif ( XFLAG , XNIVEL++ , XNIVEL-- )
         qmensa("")
      enddo

      if ! lCONF ; return ; endif

      if CONFIG->(qrlock())

         // AQUI INCREMENTA CODIGO DO PEDIDO DE VENDA ____________

         if cOPCAO == "I"
            replace CONFIG->Empenho with CONFIG->Empenho + 1
            qsay(6,17,fCODIGO := strzero(CONFIG->Empenho,5) )
            qmensa("C¢digo Gerado: "+fCODIGO,"B")
         endif

      else
         iif(cOPCAO=="I",qm1(),qm2())
      endif

      //if cOPCAO == "I"
      //   if fTIPO == "1"
      //      fCOD_CFOP := "5102"
      //      fNUM_FATURA := "P"+fCODIGO
      //   endif

      //   if fTIPO == "7"
      //      fCOD_CFOP := "1202"
      //      fNUM_FATURA := "P"+fCODIGO
      //   endif
      //endif


      if CONVENIO->(iif(cOPCAO=="I",qappend(),qrlock()))

         // AGORA GRAVA E DESTRAVA ARQUIVO _____________________________________
         fUSER := XUSRIDT
         CONVENIO->(qreplacefields())
         replace CONVENIO->Cliente with fCLIENTE
      endif

      dbunlockall()

      i_proc_emp()
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

      case cCAMPO == "DT_EMISSAO"

           if empty(fDT_EMISSAO) ; return .F. ; endif


      case cCAMPO == "COD_CLI"

           if empty(fCOD_CLI) ; return .F. ; endif
           qsay(7,24,fCOD_CLI:=strzero(val(fCOD_CLI),5))
           if ! CLI1->(dbseek(fCOD_CLI))
              qmensa("Cliente n„o encontrado !","B")
              return .F.
           endif


           if cOPCAO == "I"
              if CT_CONV->(dbseek(fCOD_CLI))
                 nSaldo := qGetSaldo(fCOD_CLI)
                 if CT_CONV->Limite - nSaldo <= 0
                    qmensa("Limite.: "+transf(CT_CONV->Limite,"@E 999,999.99")+" Usado.: "+transform(nsaldo,"@E 999,999.99")+ " Saldo.: "+transf(CT_CONV->Limite - nSAldo,"@E 999,999.99"),"BL")
                    return .F.
                 endif
              else
                 qmensa("Cliente Sem Conta Convenio!","BL")
                 return .F.
              endif
           endif


           qsay(7,32,left(CLI1->Razao,40))

           if cOPCAO == "I" ; fCOD_VENDED := CLI1->Cod_vend   ; endif
           if cOPCAO == "I" ; fCOD_REPRES := CLI1->Cod_repres ; endif
           fCLIENTE := left(CLI1->Razao,50)

      case cCAMPO == "COD_REPRES"
           if empty(fCOD_REPRES) ; return .F. ; endif
           qsay(9,24,fCOD_REPRES:=strzero(val(fCOD_REPRES),5))
           if ! REPRES->(dbseek(fCOD_REPRES))
              qmensa("Representante n„o encontrado !","B")
              return .F.
           endif
           qsay(9,32,left(REPRES->Razao,35))

      case cCAMPO == "COD_VENDED"
           if empty(fCOD_VENDED) ; return .F. ; endif
           qsay(8,24,fCOD_VENDED:=strzero(val(fCOD_VENDED),5))
           if ! VEND->(dbseek(fCOD_VENDED))
              qmensa("Vendedor n„o encontrado !","B")
              return .F.
           endif
           qsay(8,32,left(VEND->Nome,35))


      case cCAMPO == "FILIAL"
           if empty(fFILIAL) ; return .F. ; endif
           qsay(10,24,fFILIAL)
           if ! FILIAL->(dbseek(fFILIAL))
              qmensa("Filial n„o encontrado !","B")
              return .F.
           endif
           qsay(10,31,left(FILIAL->Razao,40))

   endcase

return .T.

//////////////////////////////////////////////////////////////////////////////////
// FUN€AO PARA EXCLUIR PEDIDO DE VENDA __________________________________________

static function i_exclusao


   if qconf("Confirma exclus„o deste Pedido de Venda ?")

      /// rotina para voltar o estoque dos produtos digitados no Pedido Deletado !

      ITEN_CON->(Dbgotop())
      ITEN_CON->(Dbseek(CONVENIO->Codigo))

      if ITEN_CON->(qflock()) .and. CONVENIO->(qrlock())

         ITEN_CON->(dbseek(CONVENIO->Codigo))

         do while ! ITEN_CON->(eof()) .and. ITEN_CON->cod_conv == CONVENIO->Codigo // itens do pedido (produtos)
            ITEN_CON->(dbdelete())
            ITEN_CON->(dbskip())
         enddo


         CONVENIO->(dbdelete())
         CONVENIO->(qunlock())
         ITEN_CON->(qunlock())

      else
         qm3()
      endif
   endif

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DOS PRODUTOS _______________________________

function i_proc_emp


// LOOP PRINCIPAL ___________________________________________________________

setcolor("W/B")

if cOPCAO == "A"
   fTOTAL := 0
   lALT := .T.
endif

PROD->(Dbsetorder(4))

ITEN_CON->(qview({{"Cod_prod/Cod."                                        ,2},;
                     {"f208a()/Descri‡„o"                                    ,0},;
                     {"transform(Vl_unitar, '@E 9,999,999.99')/Vl.Unit."    ,0},;
                     {"transform(Quantidade,'@E 999999')/Quant."           ,0},;
                     {"f208b()/Un."                                          ,0},;
                     {"f208c()/Val. Total"                                   ,0},;
                     {"f208du()/BX"                                          ,0}},;
                     "12002179S",;
                     {NIL,"f208d",NIL,NIL},;
                     {"ITEN_CON->cod_conv == CONVENIO->Codigo",{||f208top()},{||f208bot()}},;
                     "<I>nc./<A>lt./<C>on./<E>xc."))
return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IR PARA O INICIO DOS DADOS FILTRADOS _________________________

function f208top
   ITEN_CON->(dbsetorder(1))
   ITEN_CON->(dbseek(CONVENIO->Codigo))
   i_totaliza_pedido()
   qsay(22,16,transform(fTOTAL,"@E 99,999,999.99"))

return

function f208fa
   local result := ""

   if CONVENIO->Faturado
      result := "Sim"
   endif

return result


/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IR PARA O FINAL DOS DADOS FILTRADOS __________________________

function f208bot
   ITEN_CON->(dbsetorder(1))
   ITEN_CON->(qseekn(CONVENIO->Codigo))
   i_totaliza_pedido()
   qsay(22,16,transform(fTOTAL,"@E 99,999,999.99"))
return

/////////////////////////////////////////////////////////////////////////////
// RETORNA A DESCRICAO DO PRODUTO __________________________________________

function f208a

   local cDESCRICAO := space(30)
   PROD->(Dbsetorder(4))
   if ! empty(ITEN_CON->Cod_prod)
      PROD->(dbseek(left(ITEN_CON->Cod_prod,5)))
      cDESCRICAO := left(PROD->Descricao,25)
   endif
   i_totaliza_pedido()
   qsay(22,16,transform(fTOTAL,"@E 99,999,999.99"))

return cDESCRICAO


function f208du
   local cResult := space(3)

   if ITEN_CON->Baixado
      cResult := "SIM"
   endif


return cResult



function f208m
   local cFABR := space(4)

   PROD->(Dbsetorder(4))
   if ! empty(ITEN_CON->Cod_prod)
      PROD->(dbseek(left(ITEN_CON->Cod_prod,5)))
      cFABR := left(PROD->Cod_fabr,4)
   endif
   i_totaliza_pedido()
   qsay(22,16,transform(fTOTAL,"@E 99,999,999.99"))
   rtrim(cFABR)

return cFABR

function f208m1
   local cASS := space(7)

   PROD->(Dbsetorder(4))
   if ! empty(ITEN_CON->Cod_prod)
      PROD->(dbseek(left(ITEN_CON->Cod_prod,5)))
      cASS := left(PROD->Cod_ass,7)
   endif
   i_totaliza_pedido()
   qsay(22,16,transform(fTOTAL,"@E 99,999,999.99"))
   rtrim(cASS)

return cASS


/////////////////////////////////////////////////////////////////////////////
// RETORNA A UNIDADE DO PRODUTO _____________________________________________

function f208b
   PROD->(dbseek(left(ITEN_CON->Cod_prod,5)))
   UNIDADE->(dbseek(PROD->Unidade))
   i_totaliza_pedido()
   qsay(22,16,transform(fTOTAL,"@E 99,999,999.99"))
return UNIDADE->Sigla

/////////////////////////////////////////////////////////////////////////////
// RETORNA O VALOR TOTAL DO PRODUTO _________________________________________

function f208c
   i_totaliza_pedido()
   qsay(22,16,transform(fTOTAL,"@E 99,999,999.99"))
return transform(ITEN_CON->Vl_unitar * ITEN_CON->Quantidade,"@E 999,999.99")

function f208cl
   INVENT->(DbSeek(CONVENIO->Filial+right(PROD->Codigo,5)+"0000000000" ))

return INVENT->Quant_Atu


/////////////////////////////////////////////////////////////////////////////
// FUNCAO DE CONTROLE PRINCIPAL ANTES DE PROCESSAR A TECLA ACIONADA _________

function f208d

   local nCURSOR := setcursor(1)
   parameters cOPCAO

   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO $ XUSRA
      if CONFIG->Modelo_fat == "B"
         qlbloc(08,08,"B208BG","QBLOC.GLO",1)
     elseif CONFIG->Modelo_2 $ "9"
         qlbloc(08,08,"B208BK","QBLOC.GLO",1)
     elseif CONFIG->Modelo_fat == "1"
         qlbloc(08,08,"B208B1","QBLOC.GLO",1)
     else
         qlbloc(08,08,"B208B","QBLOC.GLO",1)
     endif


      i_empenho_item()
   endif


   setcursor(nCURSOR)

return ""






/////////////////////////////////////////////////////////////////////////////
// FUNCAO DE BROWSE _________________________________________________________

function i_empenho_item

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
      qrsay ( XNIVEL++ , ITEN_CON->Cod_prod            , "@R 99999"                    ) ; PROD->(dbseek(left(ITEN_CON->Cod_prod,5)))
      qrsay ( XNIVEL++ , left(PROD->Descricao,40)                                      )
      qrsay ( XNIVEL++ , ITEN_CON->Num_lote                                            )
      qrsay ( XNIVEL++ , ITEN_CON->Vl_unitar, "@E 999,999,999.99"                        )
      qrsay ( XNIVEL++ , ITEN_CON->Quantidade,"@R 999999999"       )
      qrsay ( XNIVEL++ , ITEN_CON->Vl_unitar * ITEN_CON->Quantidade, "@E 9,999,999.99" )
      qrsay ( XNIVEL++ , qconv_st(), "@E 9,999,999.99" )
      qrsay ( XNIVEL++ , (ITEN_CON->Vl_unitar * ITEN_CON->Quantidade)+qconv_st(), "@E 9,999,999.99" )
      qrsay ( XNIVEL++ , ITEN_CON->Quant_ret,"@R 999999999"       )


   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exc_itens_fat() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || view_prod(-1,0,@fCOD_PROD                    ) } ,"COD_PROD"  })
   aadd(aEDICAO,{{ || NIL                                            } ,NIL         })
   aadd(aEDICAO,{{ || view_lote(-1,0,@fNUM_LOTE, "@r 9999999999"   ) } ,"NUM_LOTE"  })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fVL_UNITAR , "@e 999,999,999.99") } ,"VL_UNITAR" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fQUANTIDADE , "@r 999999999"      ) } ,"QUANTIDADE"})
   aadd(aEDICAO,{{ || NIL                                            } ,"TOTAL"     })
   aadd(aEDICAO,{{ || NIL                                            } ,"TOTAL"     })
   aadd(aEDICAO,{{ || NIL                                            } ,"TOTAL"     })

   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   ITEN_CON->(qpublicfields())

   iif(cOPCAO=="I",ITEN_CON->(qinitfields()),ITEN_CON->(qcopyfields()))

   if cOPCAO == "A"
      XNIVEL := 3
   else
      XNIVEL := 1
   endif

   XFLAG  := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; ITEN_CON->(qreleasefields()) ; return ; endif
      if ! i_crit2( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   if ! lCONF ; return ; endif

   // GRAVACAO ______________________________________________________________

   if CONVENIO->(qrlock()) .and. ITEN_CON->(iif(cOPCAO=="I",qappend(),qrlock()))

      if cOPCAO == "I"
         fcod_conv := fCODIGO
         fDATA    := fDT_EMISSAO
      endif

      fDATA    := fDT_EMISSAO
      INVENT->(Dbsetorder(1))

      ITEN_CON->(qreplacefields())
      ITEN_CON->(qunlock())

      fTOTAL := fTOTAL + (ITEN_CON->Vl_unitar*fQUANTIDADE)

      // rotina que baixa o produto do Estoque quando e' confirmado no pedido

   else

      iif(cOPCAO=="I",qm1(),qm2())

   endif

return

/////////////////////////////////////////////////////////////////////////////
// CRITICAS NA DESCIDA ______________________________________________________

static function i_crit2 ( cCAMPO )
local nORDEM := 0
local nREG   := 0
local nVAL_UNI := 0

   qmensa("")

   iif ( cCAMPO == NIL , cCAMPO := "" , NIL )
   if ! XFLAG; return .t.; endif
   do case

      case cCAMPO == "COD_PROD"

           INVENT->(dbClearFilter())
           qrsay(XNIVEL,fCOD_PROD:=strzero(val(fCOD_PROD),5))

           nORDEM := ITEN_CON->(Indexord())
           nREG   := ITEN_CON->(recno())


           ITEN_CON->(dbsetorder(2))
           if ITEN_CON->(dbseek(CONVENIO->Codigo+fCOD_PROD))
              qmensa("Produto ja cadastrado, InclusÆo negada !","B")
              return .F.
           endif

           ITEN_CON->(Dbsetorder(nORDEM))
           ITEN_CON->(Dbgoto(nREG))
           nREG := 0
           nORDEm := 0

           PROD->(Dbsetorder(4))

           if ! PROD->(dbseek(fCOD_PROD))
              qmensa("Produto n„o encontrado !","B")
              return .F.
           endif

           qrsay ( XNIVEL+1 , left(PROD->Descricao,38) )

           //////////////////////////////////////////////////////////////////////////
           // TABELA DE PRECOS POR CLIENTE __________________________________________

           if CONFIG->Modelo_2 == "7"
              fBC_SUBST := PROD->Bc_subst
              fICMS := 18
              CLI_PR->(dbsetorder(2))
              if CLI_PR->(dbseek(CONVENIO->Cod_cli))

                 ITEN_GP->(Dbsetorder(2))
                 if ITEN_GP->(DbSeek(CLI_PR->Cod_grupo+right(PROD->Codigo,5)))
                    fVL_UNITAR := ITEN_GP->Valor
                 else
                    fVL_UNITAR := PROD->Preco_cons
                 endif
              else
                 fVL_UNITAR := PROD->Preco_cons
              endif
           endif

           Return .T.

      case cCAMPO == "QUANTIDADE"

           if CONFIG->Modelo_2 != "0"
              if empty(fQUANTIDADE) ; return .F. ; endif
           endif

           if CT_CONV->(dbseek(CONVENIO->COD_CLI))
              nSaldo := (qGetSaldo(CONVENIO->Cod_cli) + ((fQuantidade*fVl_unitar)+i_soma_st()))
              alert("Saldo..: "+Transf(nSAldo,"@E 999,999.99"))
              if CT_CONV->Limite - nSaldo <= 0
                 qmensa("Limite.: "+transf(CT_CONV->Limite,"@E 999,999.99")+" Usado.: "+transform(nsaldo,"@E 999,999.99")+ " Saldo.: "+transf(CT_CONV->Limite - nSAldo,"@E 999,999.99"),"BL")
                 return .F.
              endif
           else
              qmensa("Cliente Sem Conta Convenio!","BL")
              return .F.
           endif

           qrsay ( XNIVEL+1 , transf(fQuantidade * fVl_unitar,"@E 99,999,999.99" ))
           qrsay ( XNIVEL+2 , transf(i_soma_st(),"@E 99,999,999.99" ))
           qrsay ( XNIVEL+3 , transf((fQuantidade * fVl_unitar)+i_soma_st(),"@E 99,999,999.99" ))

      case cCAMPO == "VL_UNITAR"

           if CONFIG->Modelo_2 != "0"
             if empty(fVL_UNITAR) ; return .F. ; endif
           endif

           if CONFIG->Modelo_2 == "7"
              CLI_PR->(dbsetorder(2))
              if CLI_PR->(dbseek(CONVENIO->Cod_cli))

                 ITEN_GP->(Dbsetorder(2))
                 if ITEN_GP->(DbSeek(CLI_PR->Cod_grupo+right(PROD->Codigo,5)))
                    fVAL_UNI := ITEN_GP->Valor
                 else
                    fVAL_UNI := PROD->Preco_cons
                 endif
              else
                 fVAL_UNI := PROD->Preco_cons
              endif
           endif

           if fVL_UNITAR < fVAL_UNI
              qmensa("Valor abaixo do preco de Tabela. Verifique!","B")
              return .F.
           endif


           Return .t.

   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXCLUIR ITENS DO PEDIDO  _____________________________________

static function i_exc_itens_fat

   if qconf("Confirma exclus„o do Produto ?")

      //INVENT->(Dbclearfilter())
      //INVENT->(Dbsetorder(1))

      //if CONFIG->Estoque == "S"
      // rotina que volta a quantidade em estoque pois foi baixa no pedido
      //if CONVENIO->Enviado == .F.
      //   if INVENT->(dbseek(fFILIAL+ITEN_CON->Cod_prod+ITEN_CON->Num_lote)) .and. INVENT->(qrlock())
      //      if CONVENIO->Es == "S"
      //         replace INVENT->Quant_atu with (INVENT->Quant_atu + ITEN_CON->Quantidade)
      //      else
      //         replace INVENT->Quant_atu with (INVENT->Quant_atu - ITEN_CON->Quantidade)
      //      endif
      //      INVENT->(qunlock())
      //   else
      //      qmensa("Lote nao encontrado !","B")
      //      return .F.
      //   endif
      //Endif
      //endif

      if ITEN_CON->(qrlock())
         ITEN_CON->(dbdelete())
         ITEN_CON->(qunlock())
      else
         qm3()
      endif
   endif

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA DEVOLUCAO de ITENS DO PEDIDO  _____________________________________


////////////////////////////////////////////////////////////////////////////////////
static function i_atu_lanc
   ITEN_CON->(qview({{"Cod_prod/Cod."                                       ,2},;
                     {"f208a()/Descri‡„o"                                    ,0},;
                     {"transform(Vl_unitar, '@E 999,999.99999')/Vl.Unit."    ,0},;
                     {"transform(Quantidade,'@E 99999.99')/Quant."           ,0},;
                     {"f208b()/Un."                                          ,0},;
                     {"f208c()/Val. Total"                                   ,0}},;
                     "12002179S",;
                     {NIL,NIL,NIL,NIL},;
                     {"ITEN_CON->cod_conv == CONVENIO->Codigo",{||f208top()},{||f208bot()}},;
                    "<ESC> para sair" ))

return ""

//////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IMPRIMIR PEDIDO ________________________________________________

static function i_imprime

   local cTITULO
   local nTOT_PROD := nLIN := nTOT_BRU := nPROD := nICMS_SUBS := 0
   local nALIQ_ICMS := 0
   local nIPI := 0
   local nICMS := 0
   local cPESOBR := 0
   local cPESOLQ := 0

   cTITULO := "LISTAGEM DO EMPENHO No."+CODIGO+"   Data Emissao: "+dtoc(CONVENIO->Dt_emissao)

   PROD->(Dbsetorder(4))

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif

   if ! qlineprn() ; return ; endif

   if XPAGINA == 0 .or. prow() > K_MAX_LIN
      qpageprn()
      @ prow(),pcol() say XCOND1
      qcabecprn(cTITULO,132)
      CLI1->(Dbseek(CONVENIO->Cod_cli))
      REPRES->(Dbseek(CONVENIO->Cod_repres))
      CGM->(Dbseek(CLI1->Cgm_ent))
      @ prow()+1,0 say "Cliente : "+CLI1->Codigo + " - " + left(CLI1->Razao,36) + "  Telefone: "+ CLI1->Fone1
      @ prow()+1,0 say "Fantasia: "+CLI1->Fantasia
      @ prow()+1,0 say "CNPJ....: "+fu_conv_cgccpf(CLI1->Cgccpf)
      @ prow()+1,0 say "Endereco: "+left(CLI1->End_ent,32) + " - " + left(CGM->Municipio,15) + " UF: "+CGM->Estado
      @ prow()+1,0 say "Bairro  : " + CLI1->Bairro_ent + "  CEP.: "+CLI1->Cep_ent
      @ prow()+1,0 say "Representante: "+ REPRES->Razao
      ROTA->(dbseek(CLI1->Cod_rota))
      @ prow()+1,45 say "Rota.: " + left(ROTA->Descricao,26)

      @ prow()+1,0 say "Observacao: "+left(CONVENIO->Obs,70)
      @ prow()+1,0 say "Usuario(a) : "+CONVENIO->User
      @ prow()+1,0 say replicate("-",132)
   endif

   @ prow()+1,0 say "Codigo    Produto                                                Valor          Valor          Qtde              Qtde"
   @ prow()+1,0 say "                                                                Unitario        Total        Carregada         Entregue"
   @ prow()+1,0 say ""

   ITEN_CON->(Dbseek(CONVENIO->Codigo))

   do while ! ITEN_CON->(eof()) .and. ITEN_CON->cod_conv == CONVENIO->Codigo

      PROD->(Dbseek(ITEN_CON->Cod_prod))
      @ prow()+1,0    say ITEN_CON->cod_prod
      @ prow()  ,10   say left(PROD->Descricao,40)
      @ prow()  ,60   say transform(ITEN_CON->Vl_unitar , "@E 999,999.99")
      @ prow()  ,75   say transform(ITEN_CON->Quantidade*ITEN_CON->Vl_unitar, "@E 999,999.99")
      @ prow()  ,92   say transform(ITEN_CON->Quantidade, "@E 9999999")
      @ prow()  ,112  say "_______"

      nTOT_PROD += (ITEN_CON->Quantidade*ITEN_CON->vl_unitar)
      cPESOBR := cPESOBR + (PROD->Peso_Bruto*ITEN_CON->Quantidade)
      cPESOLQ := cPESOLQ + (PROD->Peso*ITEN_CON->Quantidade)




      nLIN++
      nLIN++
      ITEN_CON->(Dbskip())

   enddo

   @ prow()+1,0 say replicate("-",132)
   @ prow()+1,41 say " Valor do Empenho - - - - - -> "+transform( nTOT_PROD, "@E 99,999,999.99")
   @ prow()+1,00 say " Peso Bruto   - - - -> "+transform(cPESOBR , "@R 999999999.999")
   @ prow()  ,41 say " Peso Liquido - - - -> "+transform(cPESOLQ , "@R 999999999.999")

   @ prow()+2,00    say "Ass. Responsavel.:____________________"
   @ prow()  ,45    say "Ass. Almoxarife..:____________________"
   @ prow()  ,90    say "Ass. Financeiro..:____________________"


   qstopprn()

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA TOTALIZAR VARIAVEIS DO PEDIDO ________________________________

static function i_totaliza_pedido

   local nREC   := ITEN_CON->(recno())
   local nINDEX := ITEN_CON->(indexord())
   nITENS := 0
   nTOT_PED := 0
   fTOTAL := 0
   nTOT_PROD := 0
   nTOT_IPI  := 0
   nDESC := 0
   nTOT_DESC := 0
   nICMS_ST := 0
   nICMS_PROPRIO := 0
   ITEN_CON->(dbgotop())
   ITEN_CON->(dbseek(CONVENIO->Codigo))

   do while ! ITEN_CON->(eof()) .and. ITEN_CON->cod_conv == CONVENIO->Codigo
      PROD->(dbsetorder(4))
      PROD->(dbseek(ITEN_CON->Cod_prod))

      if ITEN_CON->Bc_subst > 0 .and. CLI1->Final $ " -N"
         nICMS_ST      +=  ( (ITEN_CON->Quantidade*ITEN_CON->Bc_subst) * (ITEN_CON->Icms /100))
         nICMS_PROPRIO +=  ( ( ITEN_CON->Quantidade * ITEN_CON->vl_unitar ) * ( 7 / 100 ) )
      endif

      fTOTAL    := fTOTAL + (ITEN_CON->Quantidade*ITEN_CON->Vl_unitar)

      ITEN_CON->(Dbskip())

   enddo

   fTOTAL := fTOTAL +(nICMS_ST - nICMS_PROPRIO)

   ITEN_CON->(dbsetorder(nINDEX))
   ITEN_CON->(dbgoto(nREC))

return

function qGetSaldo(cCOD_CLI)

local nTotal := 0
local nREG   := CONVENIO->(recno())
local nINDEX := CONVENIO->(IndexOrd())

RECEBER->(dbsetorder(5))
if RECEBER->(dbseek(cCOD_CLI))

   do while ! RECEBER->(eof()) .and. RECEBER->Cod_cli == cCOD_CLI
      nTotal += RECEBER->Valor_liq
      RECEBER->(dbskip())
   enddo
endif

CONVENIO->(dbsetorder(4))

if CONVENIO->(dbseek(cCOD_CLI))

   do while ! CONVENIO->(eof()) .and. CONVENIO->Cod_cli == cCOD_CLI

      //if CONVENIO->Tipo == "E"
      //   CONVENIO->(dbskip())
      //   loop
      //endif

      if CONVENIO->Faturado
         CONVENIO->(dbskip())
         loop
      endif

      if CONVENIO->Cancelado
         CONVENIO->(dbskip())
         loop
      endif


      ITEN_CON->(dbgotop())
      ITEN_CON->(dbseek(CONVENIO->Codigo))

      do while ! ITEN_CON->(eof()) .and. ITEN_CON->cod_conv == CONVENIO->Codigo

         if ITEN_CON->Baixado
            nTOTAL += (ITEN_CON->Quant_ret * ITEN_CON->Vl_unitar) + qconv_st()
         else
            nTOTAL += (ITEN_CON->Quantidade * ITEN_CON->Vl_unitar) + qconv_st()
         endif

         ITEN_CON->(dbskip())
      enddo

      CONVENIO->(dbskip())
   enddo
endif

CONVENIO->(dbgoto(nREG))
CONVENIO->(dbsetorder(nINDEX))


return nTOTAL


static function i_soma_st()
local nICMS_PROPRIO := 0
local nICMS_ST      := 0
local nSubst        := 0

if fBc_subst > 0 .and. CLI1->Final $ " -N"
   nICMS_ST      +=  ( (fQuantidade  * fBc_subst) * (fIcms /100))
   nICMS_PROPRIO +=  ( ( fQuantidade * fvl_unitar ) * ( 7 / 100 ) )
endif

nSubst := nICMS_ST - nICMS_PROPRIO

return nSubst


static function i_faturado()

     if i_permite_faturar().and. CONVENIO->(qrlock())
        replace CONVENIO->faturado with .T.
        CONVENIO->(qunlock())
     else
        qmensa("Ha produtos nao baixados, verifique!","BL")
        return .F.
     endif

return


static function i_permite_faturar()
   local result := .T.

   ITEN_CON->(dbseek(CONVENIO->Codigo))

   do while ! ITEN_CON->(eof()) .and. ITEN_CON->cod_conv == CONVENIO->Codigo

      if ! ITEN_CON->Baixado
         result := .F.
      endif

      ITEN_CON->(Dbskip())

   enddo

return result

static function i_cancelaConv()
if qconf("Confirma cancelamento?")
     if CONVENIO->(qrlock())
        replace CONVENIO->cancelado with .T.
        CONVENIO->(qunlock())
     endif
endif

return

