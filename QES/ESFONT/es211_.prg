/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO COMERCIO
// OBJETIVO...: LANCAMENTO DE EMPENHOS/CONVENIOS
// ANALISTA...: Eduardo Borio
// PROGRAMADOR: O Mesmo
// INICIO.....: Fevereiro de 2009
// OBS........:
function es211

#include "inkey.ch"

private fTOTAL := 0
private cTIPO  := ""
private nITENS := 0
private nSaldo := 0
private cES    := " "
private fPARC  := 0
private nCOMISSAO := 0
private lALT   := .F.
private sBLOC1  := qlbloc("B211D","QBLOC.GLO")

CONVENIO->(dbsetfilter({|| ! Faturado }))

/////////////////////////////////////////////////////////////////////////////
// MANUTENCAO DE PEDIDO DE VENDA ___________________________________________

CONVENIO->(qview({{"Codigo/Lancto"       ,1},;
             {"Dt_emissao/Emissao"      ,2},;
             {"left(Cliente,35)/Cliente",3}},"P",;
             {NIL,"i_211c",NIL,NIL},;
              NIL,q_msg_acesso_usr()+"/im<P>rime "))
return

//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAGEM DO CLIENTE ______________________________________________

function i_211a
   CLI1->(dbseek(CONVENIO->Cod_cli))
return left(CLI1->Razao,25)


function i_211c

   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))


   iif(cOPCAO == "P", i_imprime(),)


   if cOPCAO $ "AC"

      iif(cOPCAO == "A", lALT := .T.,)

      qlbloc(5,0,"B211A","QBLOC.GLO",1)

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

   // PREENCHE O VETOR DE EDICAO _________________________________________________

   aadd(aEDICAO,{{ || NIL                                               } ,"CODIGO"       })
   aadd(aEDICAO,{{ || NIL                                               } ,"CODIGO"       })
   //aadd(aEDICAO,{{ || qgetx(6,42,@fDT_EMISSAO,"@D",                    )} ,"DT_EMISSAO"   })

   //aadd(aEDICAO,{{ || view_cli2(7,24,@fCOD_CLI                          )} ,"COD_CLI"      })
   aadd(aEDICAO,{{ || NIL },NIL }) // razao do cliente
   aadd(aEDICAO,{{ || NIL },NIL }) // razao do cliente

   //aadd(aEDICAO,{{ || view_vend(8,24,@fCOD_VENDED                      )} ,"COD_VENDED"   })
   aadd(aEDICAO,{{ || NIL },NIL }) // nome do vendedor
   aadd(aEDICAO,{{ || NIL },NIL }) // nome do vendedor

   //aadd(aEDICAO,{{ || view_repres(9,24,@fCOD_REPRES                      )} ,"COD_REPRES"   })
   aadd(aEDICAO,{{ || NIL },NIL }) // nome do representante
   aadd(aEDICAO,{{ || NIL },NIL }) // nome do representante


   //aadd(aEDICAO,{{ || view_filial(10,24,@fFILIAL                        )} ,"FILIAL"       })
   aadd(aEDICAO,{{ || NIL },NIL }) // descricao da filial
   aadd(aEDICAO,{{ || NIL },NIL }) // descricao da filial
   aadd(aEDICAO,{{ || NIL },NIL }) // descricao da filial


   //aadd(aEDICAO,{{ || qgetx(11,14,@fOBS,"@!S43",NIL                    )}   ,"OBS"        })


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

   endcase

return .T.


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
                     {"f211a()/Descri‡„o"                                    ,0},;
                     {"transform(Vl_unitar, '@E 9,999,999.99')/Vl.Unit."    ,0},;
                     {"transform(Quantidade,'@E 999999')/Quant."           ,0},;
                     {"f211b()/Un."                                          ,0},;
                     {"f211c()/Val. Total"                                   ,0}},;
                     "12002179S",;
                     {NIL,"f211d",NIL,NIL},;
                     {"ITEN_CON->cod_conv == CONVENIO->Codigo",{||f211top()},{||f211bot()}},;
                     "<A>lt./<C>on."))
return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IR PARA O INICIO DOS DADOS FILTRADOS _________________________

function f211top
   ITEN_CON->(dbsetorder(1))
   ITEN_CON->(dbseek(CONVENIO->Codigo))
   i_totaliza_pedido()
   qsay(22,16,transform(fTOTAL,"@E 99,999,999.99"))

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IR PARA O FINAL DOS DADOS FILTRADOS __________________________

function f211bot
   ITEN_CON->(dbsetorder(1))
   ITEN_CON->(qseekn(CONVENIO->Codigo))
   i_totaliza_pedido()
   qsay(22,16,transform(fTOTAL,"@E 99,999,999.99"))
return

/////////////////////////////////////////////////////////////////////////////
// RETORNA A DESCRICAO DO PRODUTO __________________________________________

function f211a

   local cDESCRICAO := space(30)
   PROD->(Dbsetorder(4))
   if ! empty(ITEN_CON->Cod_prod)
      PROD->(dbseek(left(ITEN_CON->Cod_prod,5)))
      cDESCRICAO := left(PROD->Descricao,30)
   endif
   i_totaliza_pedido()
   qsay(22,16,transform(fTOTAL,"@E 99,999,999.99"))

return cDESCRICAO


function f211m
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

function f211m1
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

function f211b
   PROD->(dbseek(left(ITEN_CON->Cod_prod,5)))
   UNIDADE->(dbseek(PROD->Unidade))
   i_totaliza_pedido()
   qsay(22,16,transform(fTOTAL,"@E 99,999,999.99"))
return UNIDADE->Sigla

/////////////////////////////////////////////////////////////////////////////
// RETORNA O VALOR TOTAL DO PRODUTO _________________________________________

function f211c
   i_totaliza_pedido()
   qsay(22,16,transform(fTOTAL,"@E 99,999,999.99"))
return transform(ITEN_CON->Vl_unitar * ITEN_CON->Quantidade,"@E 999,999.99")

function f211cl
   INVENT->(DbSeek(CONVENIO->Filial+right(PROD->Codigo,5)+"0000000000" ))

return INVENT->Quant_Atu


/////////////////////////////////////////////////////////////////////////////
// FUNCAO DE CONTROLE PRINCIPAL ANTES DE PROCESSAR A TECLA ACIONADA _________

function f211d

   local nCURSOR := setcursor(1)
   parameters cOPCAO

   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO $ XUSRA

      qlbloc(08,08,"B211B","QBLOC.GLO",1)

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

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   //aadd(aEDICAO,{{ || view_prod(-1,0,@fCOD_PROD                    ) } ,"COD_PROD"  })
   aadd(aEDICAO,{{ || NIL                                            } ,NIL         })
   aadd(aEDICAO,{{ || NIL                                            } ,NIL         })
   aadd(aEDICAO,{{ || NIL                                            } ,NIL         })
   aadd(aEDICAO,{{ || NIL                                            } ,NIL         })
   aadd(aEDICAO,{{ || NIL                                            } ,NIL         })
   //aadd(aEDICAO,{{ || view_lote(-1,0,@fNUM_LOTE, "@r 9999999999"   ) } ,"NUM_LOTE"  })
   //aadd(aEDICAO,{{ || qgetx(-1,0,@fVL_UNITAR , "@e 999,999,999.99") } ,"VL_UNITAR" })
   //aadd(aEDICAO,{{ || qgetx(-1,0,@fQUANTIDADE , "@r 999999999"      ) } ,"QUANTIDADE"})
   aadd(aEDICAO,{{ || NIL                                            } ,"TOTAL"     })
   aadd(aEDICAO,{{ || NIL                                            } ,"TOTAL"     })
   aadd(aEDICAO,{{ || NIL                                            } ,"TOTAL"     })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fQUANT_RET , "@r 999999999"      ) } ,"QUANT_RET "})
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

   if fQUANT_RET > fQUANTIDADE
      qmensa("Qtde Entregue, nao pode ser maior que a enviada! ","BL")
      return .F.
   else
      if CONVENIO->(qrlock()) .and. ITEN_CON->(iif(cOPCAO=="I",qappend(),qrlock()))

         fBAIXADO := .T.
         ITEN_CON->(qreplacefields())
         ITEN_CON->(qunlock())

         fTOTAL := fTOTAL + (ITEN_CON->Vl_unitar*fQUANTIDADE)

         // rotina que baixa o produto do Estoque quando e' confirmado no pedido

      else

         iif(cOPCAO=="I",qm1(),qm2())

      endif
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

      case cCAMPO == "QUANT_RET"
           if fQUANT_RET > fQUANTIDADE .or. fQUANT_RET < 0
               qmensa("Qtde entregue nao pode ser maior que a enviada!","BL")
               return .F.
           endif

   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA DEVOLUCAO de ITENS DO PEDIDO  _____________________________________


////////////////////////////////////////////////////////////////////////////////////
static function i_atu_lanc
   ITEN_CON->(qview({{"Cod_prod/Cod."                                       ,2},;
                     {"f211a()/Descri‡„o"                                    ,0},;
                     {"transform(Vl_unitar, '@E 999,999.99999')/Vl.Unit."    ,0},;
                     {"transform(Quantidade,'@E 99999.99')/Quant."           ,0},;
                     {"f211b()/Un."                                          ,0},;
                     {"f211c()/Val. Total"                                   ,0}},;
                     "12002179S",;
                     {NIL,NIL,NIL,NIL},;
                     {"ITEN_CON->cod_conv == CONVENIO->Codigo",{||f211top()},{||f211bot()}},;
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

   cTITULO := "LISTAGEM DO CONVENIO No."+CODIGO+"   Data Emissao: "+dtoc(CONVENIO->Dt_emissao)

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



      nLIN++
      nLIN++
      ITEN_CON->(Dbskip())

   enddo

   @ prow()+1,0 say replicate("-",132)
   @ prow()+1,41 say " Valor do Empenho - - - - - -> "+transform( nTOT_PROD, "@E 99,999,999.99")
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

      //if CONVENIO->Faturado
      //   CONVENIO->(dbskip())
      //   loop
      //endif

      ITEN_CON->(dbgotop())
      ITEN_CON->(dbseek(CONVENIO->Codigo))

      do while ! ITEN_CON->(eof()) .and. ITEN_CON->cod_conv == CONVENIO->Codigo
         nTOTAL += (ITEN_CON->Quantidade * ITEN_CON->Vl_unitar) + qconv_st()
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



