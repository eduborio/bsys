/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE TESOURARIA
// OBJETIVO...: PAGAMENTO DE LANCAMENTOS LIBERADOS (CONTAS A PAGAR)
// ANALISTA...: EDUARDO AUGUSTO BORIO
// PROGRAMADOR: EDUARDO AUGUSTO BORIO
// INICIO.....: MARCO DE 1997
// OBS........:
// ALTERACOES.:
function ts402

#include "inkey.ch"
#include "setcurs.ch"

BANCO->(Dbsetorder(3))
CCUSTO->(Dbsetorder(4))

private fCOD_BANCO  := space(5)
private cBANCO      := space(5)
private dDATA_PAGTO := ctod("")
private nNR_CHEQUE  := 0
private nTOTAL      := 0
private nCONT       := 0
private nHIST       := {}
private cTIPO       := ""
private cHISTOR     := space(60)
private cFORNECS    := space(60)
private cVALORES    := space(120)
private nQUANT      := 0
private sBLOC1      := qlbloc("B402C","QBLOC.GLO",1)
private nJuros:= 0
private nDesconto := 0

// VIEW INICIAL _____________________________________________________________

PAG_TESO->(qview({{"Codigo/C¢digo"             ,1},;
               {"Data_venc/Vencimento"         ,2},;
               {"left(Fornec,22)/Fornecedor"   ,6},;
               {"f_402c()/    Valor"           ,4},;
               {"Fatura/Fatura"                ,5},;
               {"Marcar/Marcar"                ,0}},"P",;
               {NIL,"f402a",NIL,NIL},;
                NIL,"ESC/ALT-P/ALT-O/<A>ltera/<C>onsulta/<M>arca/<B>aixa"))

//////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAGEM DO FORNECEDOR _______________________________________

function f_402b
   FORN->(dbseek(PAG_TESO->Cod_forn))
return left(FORN->Razao,22)

//////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAGEM DE VALOR COM PICTURE ________________________________

function f_402c
return(transform(PAG_TESO->Valor_liq,"@E 9,999,999.99"))

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function f402a
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))

   do case

      case cOPCAO == "C"

         qlbloc(05,00,"B402A","QBLOC.GLO",1)
         qmensa(qabrev(cOPCAO,"C",{"Consulta..."}))
         i_consulta()

      case cOPCAO == "B"
         qlbloc(12,04,"B402B","QBLOC.GLO",1)
         qmensa(qabrev(cOPCAO,"B",{"Baixa..."}))
         i_baixa()

      case cOPCAO == "A"
         qlbloc(12,04,"B402D","QBLOC.GLO",1)
         qmensa(qabrev(cOPCAO,"A",{"Ajustes..."}))
         i_Juros()


      case cOPCAO == "M"

         i_marca()

   endcase

   setcursor(nCURSOR)
return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA ____________________________________

static function i_consulta

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO == "C"
      XNIVEL := 1
      qrsay ( XNIVEL++ , PAG_TESO->Codigo       )
      qrsay ( XNIVEL++ , PAG_TESO->Data_lanc    )
      qrsay ( XNIVEL++ , PAG_TESO->Cod_forn     ) ; FORN->(dbseek(PAG_TESO->Cod_forn))
      qrsay ( XNIVEL++ , left(FORN->Razao,40))
      qrsay ( XNIVEL++ , PAG_TESO->Centro       ) ; CCUSTO->(dbseek(PAG_TESO->Centro))
      qrsay ( XNIVEL++ , left(CCUSTO->Descricao,40))
      qrsay ( XNIVEL++ , PAG_TESO->Filial       ) ; FILIAL->(dbseek(PAG_TESO->Filial))
      qrsay ( XNIVEL++ , left(FILIAL->Razao,40))
      qrsay ( XNIVEL++ , PAG_TESO->Data_emiss   )
      qrsay ( XNIVEL++ , PAG_TESO->Cod_veic     ) ; VEICULOS->(dbseek(PAG_TESO->Cod_veic))
      qrsay ( XNIVEL++ , left(VEICULOS->Descricao,13))
      qrsay ( XNIVEL++ , PAG_TESO->Cod_eqpto    ) ; EQUIPTO->(dbseek(PAG_TESO->Cod_eqpto))
      qrsay ( XNIVEL++ , EQUIPTO->Descricao  )
      qrsay ( XNIVEL++ , PAG_TESO->Especie      ) ; ESPECIE->(dbseek(PAG_TESO->Especie))
      qrsay ( XNIVEL++ , left(ESPECIE->Descricao,13))
      qrsay ( XNIVEL++ , PAG_TESO->Serie        ) ; SERIE->(dbseek(PAG_TESO->Serie))
      qrsay ( XNIVEL++ , left(SERIE->Descricao,11))
      qrsay ( XNIVEL++ , PAG_TESO->Tipo_sub     ) ; TIPOCONT->(dbseek(PAG_TESO->Tipo_sub) )
      qrsay ( XNIVEL++ , left(TIPOCONT->Descricao,46))
      qrsay ( XNIVEL++ , left(PAG_TESO->Historico,60))
      qrsay ( XNIVEL++ , PAG_TESO->Data_venc    )
      qrsay ( XNIVEL++ , PAG_TESO->Data_prorr   )
      qrsay ( XNIVEL++ , transform(PAG_TESO->Valor,"@E 9,999,999.99"     ))
      qrsay ( XNIVEL++ , PAG_TESO->Tipo_doc     ) ; TIPO_DOC->(dbseek(PAG_TESO->Tipo_doc))
      qrsay ( XNIVEL++ , TIPO_DOC->Descricao   )
      qrsay ( XNIVEL++ , PAG_TESO->Fatura       )
      qrsay ( XNIVEL++ , PAG_TESO->Duplicata    )
      qrsay ( XNIVEL++ , PAG_TESO->Cgm          ) ; CGM->(dbseek(PAG_TESO->Cgm))
      qrsay ( XNIVEL++ , left(CGM->Municipio,40))
      qrsay ( XNIVEL++ , PAG_TESO->Cod_Banco    ) ; BANCO->(Dbseek(PAG_TESO->Cod_banco))
      qrsay ( XNIVEL++ , BANCO->Descricao      )
      qrsay ( XNIVEL++ , PAG_TESO->Situacao     ) ; SITUA->(dbseek(PAG_TESO->Situacao))
      qrsay ( XNIVEL++ , left(SITUA->Descricao,28))
      qrsay ( XNIVEL++ , PAG_TESO->Data_cont    )
      qrsay ( XNIVEL++ , left(PAG_TESO->Observacao,59))

   endif

   qwait()

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A BAIXA DOS PAGAMENTOS ______________________________

static function i_baixa

    local lCONF := .F.
    local aEDICAO := {}

    local bESCAPE := {|| empty(cTIPO).or.(XNIVEL==1.and.!XFLAG) .or.;
                        (XNIVEL==1.and.lastkey()==27)}
    XNIVEL := 1
    XFLAG  := .T.
    nTOTAL := 0
    cFORNECS := space(60)
    cVALORES := space(120)
    nQUANT   := 0
    cCentro  := ""
    cPedComp := ""
    // PREENCHE O VETOR DE EDICAO ___________________________________________

    aadd(aEDICAO,{{ || qesco(-1,0,@cTIPO , sBLOC1                   ) } ,"TIPO"       })
    aadd(aEDICAO,{{ || qgetx(-1,0,@dDATA_PAGTO ,"@D"                ) } ,"DATA_PAGTO" })
    aadd(aEDICAO,{{ || view_banco(-1,0,@cBANCO)                       },"BANCO"       })
    aadd(aEDICAO,{{ || NIL                                            },NIL           })
    aadd(aEDICAO,{{ || qgetx(-1,0,@nNR_CHEQUE  ,"9999999"           ) } ,"NR_CHEQUE"  })
    aadd(aEDICAO,{{ || lCONF := qconf("Confirma Pagamento ?") },NIL})

    XNIVEL := 1
    XFLAG  := .T.
    cFORNECS := space(60)
    cVALORES := space(120)
    dDATA_PAGTO := XDATA
    nQUANT   := 0
    do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
       eval ( aEDICAO [XNIVEL,1] )
       if eval ( bESCAPE ) ; return ; endif
       if ! i_crit_1( aEDICAO[XNIVEL,2] ) ; loop ; endif
       iif ( XFLAG , XNIVEL++ , XNIVEL-- )
    enddo

    // GRAVACAO ______________________________________________________________

    if ! lCONF ; return ; endif


    if TALOES->Ultimo_ch >= TALOES->Inter_fina   // grava ultimo numero do cheque, e verifica se o talao terminou
       if TALOES->(qrlock())
          TALOES->(Dbdelete())  // quando o talao acaba o registro e' excluido
       endif
    else
       if TALOES->(qrlock())
          replace TALOES->Ultimo_ch with (nNR_CHEQUE + 1)
       endif
    endif

    qgirabarra()

    PAG_TESO->(Dbgotop())
    nQUANT := 1
    do while ! PAG_TESO->(eof())

       qmensa("Aguarde... realizando baixa nos documentos...")

       if PAG_TESO->Marcar == "*"

          PAG_TESO->(qpublicfields())
          PAG_TESO->(qcopyfields())

          if PAGOS->(qrlock()) .and. PAGOS->(qappend())



             fBANCO_PGTO := cBANCO
             fCOD_BANCO  := cBANCO
             fNR_CHEQUE  := strzero(nNR_CHEQUE,7)
             fDATA_PAGTO := dDATA_PAGTO
             fDT_CONTABI := CONFIG->Data_atual
             fTIPO       := cTIPO
             cCentro     := fCentro
             cPedComp    := fPedComp
             if CONFIG->(qrlock())
                replace CONFIG->Cod_pagos with CONFIG->Cod_pagos + 1
                CONFIG->(qunlock())
             endif

             fCodigo := strzero(CONFIG->Cod_pagos,7)

             replace PAGOS->Codigo     with fCodigo

             PAGOS->(qreplacefields())  // grava no arquivo dos lancamentos ja pagos
             PAGOS->(qunlock())

             nTOTAL += PAGOS->Valor_liq

             aadd(nHIST , { left(PAGOS->Historico,50) , PAGOS->Valor_liq } )

             cHISTOR := PAG_TESO->Historico
             if nQUANT == 1
                cFORNECS := PAGOS->Cod_forn
                cVALORES := strzero(val(qtiraponto(str(PAGOS->Valor_liq,10,2))),10)
             else
                cFORNECS := rtrim(cFORNECS) + PAGOS->Cod_forn
                cVALORES := rtrim(cVALORES)+strzero(val(qtiraponto(str(PAGOS->Valor_liq,10,2))),10)
             endif
             if PAG_TESO->(qrlock())
                PAG_TESO->(dbdelete())     // exclui do arquivo dos lancamentos liberados para PAG_TESO
                PAG_TESO->(qunlock())
             endif

          endif

       endif

       PAG_TESO->(Dbskip())
       nQUANT++
    enddo

    if cTIPO $ "12345"

       if MOV_BANC->(qappend())
          replace MOV_BANC->Data with dDATA_PAGTO
          replace MOV_BANC->Data_comp with dDATA_PAGTO
          replace MOV_BANC->Cod_banco with cBANCO
          FORN->(Dbseek(PAG_TESO->Cod_forn))
          replace MOV_BANC->Historico with "CHEQUE NR. " + fNR_CHEQUE
          replace MOV_BANC->Saida     with nTOTAL
          replace MOV_BANC->Num_docto with ""//left(PAG_TESO->Fatura,6)
          replace MOV_BANC->Concilia  with "0"
          replace MOV_BANC->Fornec_cod with cFORNECS
          replace MOV_BANC->Valores    with cVALORES
          replace MOV_BANC->CCusto     with cCentro
          replace MOV_BANC->PedComp    with cPedComp
          replace MOV_BANC->Internal   with "PG"+PAGOS->Codigo


       endif

    endif


    if cTIPO == "6"

       if MOV_CAIX->(qappend())

          replace MOV_CAIX->Data with dDATA_PAGTO
          replace MOV_CAIX->Cod_banco with "99999"
          FORN->(Dbseek(PAG_TESO->Cod_forn))
          replace MOV_CAIX->Historico with "PAGO " + left(cHISTOR,50)
          replace MOV_CAIX->Saida     with nTOTAL
          replace MOV_CAIX->Internal   with "PG"+PAGOS->Codigo

       endif

    endif

    do case
//     case cTIPO $ "12"
//        i_emit_cheq()
       case cTIPO == "4"
          i_emit_copi()
    endcase

    qmensa("")

    PAG_TESO->(Dbgotop())

    if PAG_TESO->(qflock())
       replace all PAG_TESO->Marcar with " "
    endif
    nTOTAL := 0
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA CRITICA ______________________________________________________

function i_crit_1 ( cCAMPO )

   do case
      case cCAMPO == "BANCO"

           if cTIPO $ "1234"  // SE FOR CHEQUE/PRE-DATADO/DEBITO EM C/C ENTAO PEDE O BANCO

              if empty(cBANCO) ; return .F. ; endif

              if ! POS_CHEQ->(dbseek(cBANCO:=strzero(val(cBANCO),5)))
                 qmensa("N„o Existe Posi‡„o do Cheque deste Banco - Op‡„o <401> !","B")
                 XNIVEL := 40 // para sair do loop principal
                 return .F.
              endif

              if ! BANCO->(dbseek(cBANCO:=strzero(val(cBANCO),5)))
                  qmensa("Banco n„o Cadastrado !","B")
                  return .F.
              endif

              qrsay(XNIVEL+1,left(BANCO->Descricao,30))

           endif

           if cTIPO $ "124"
              TALOES->(dbsetorder(2))  // codigo do banco
              TALOES->(dbgotop())

              if TALOES->(dbseek(cBANCO))
                 nNR_CHEQUE := TALOES->Ultimo_ch
              else
                qmensa("N„o Existe Tal„o Cadastrado para este Banco !","B")
                XNIVEL := 40 // para sair do loop principal
                return .F.
              endif
           endif


      case cCAMPO == "DATA_PAGTO"
           if empty(dDATA_PAGTO)
              qmensa("Campo Obrigatorio...","B")
              return .F.
           endif

           //if dDATA_PAGTO < CONFIG->Data_atual
           //   qmensa("O Caixa desta data ja foi Encerrado. Data de Pagto Invalida !","B")
           //   qmensa("")
           //   return .F.
           //
           //endif

      case cCAMPO == "NR_CHEQUE"

           if cTIPO $ "124"  // SE FOR CHEQUE/PRE-DATADO/DEBITO EM C/C ENTAO PEDE O NUMERO DO CHEQUE

              lACHOU := .F.

              if empty(nNR_CHEQUE)
                 XFLAG := .F.
                 return .T.
              endif

              TALOES->(dbsetorder(2))  // codigo do banco
              TALOES->(dbgotop())

              if TALOES->(dbseek(cBANCO))

                 do while ! TALOES->(eof()) .and. TALOES->Cod_banco == cBANCO

                    if ( nNR_CHEQUE >= TALOES->Inter_prim ) .and. ( nNR_CHEQUE <= TALOES->Inter_fina )
                        lACHOU := .T.
                        exit
                    endif
                    TALOES->(dbskip())

                 enddo

              endif

              if ! lACHOU
                 qmensa("N„o Existe Nr. de cheque em nenhum Tal„o - Verifique Op‡„o <102> !","B")
//               XNIVEL := ( len(aEDICAO) + 1 )
                 return .F.
              endif

           endif

      case cCAMPO == "TIPO"

           qrsay(XNIVEL,qabrev(cTIPO,"123456",{"Cheque","Pr‚-Datado","D‚bito C/C","C¢pia Cheque","Ordem Pgto","Esp‚cie"}))

    endcase

return .T.

//////////////////////////////////////////////////////////////////////////////////
static function i_marca
   if PAG_TESO->(qrlock())
      if PAG_TESO->Marcar == "*"
         replace PAG_TESO->Marcar with " "
      else
         replace PAG_TESO->Marcar with "*"
      endif
   endif
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EMITIR COPIA DE CHEQUE _______________________________________

function i_emit_copi

   local cEXTENSO

   if ! qinitprn() ; return ; endif

   @ prow()+1,33 say XAENFAT + "COPIA DE CHEQUE" + XDENFAT
   @ prow()+1,val(POS_CHEQ->Valor)   say transform(nTOTAL,"@E 999,999,999.99")

   cEXTENSO := qextenso(nTOTAL)
   nTAM := len(cEXTENSO)

   @ prow()+2,val(POS_CHEQ->Extenso)      say iif( nTAM > val(POS_CHEQ->Linha) , left(cEXTENSO, val(POS_CHEQ->Linha) ) , cEXTENSO  )

   if nTAM > val(POS_CHEQ->Linha)
      @ prow()+1,val(POS_CHEQ->Extenso)   say substr( cEXTENSO, val(POS_CHEQ->Linha)+1, nTAM )
   else
      @ prow()+1,0 say ""
   endif

   @ prow()+2,val(POS_CHEQ->Nominal) say iif( FORN->(Dbseek(PAGOS->Cod_forn)) , FORN->Razao    , space(20) )
   @ prow()+3,val(POS_CHEQ->Cidade)  say iif( CGM-> (Dbseek(PAGOS->Cgm))    , left(CGM->Municipio,20) , space(20) )
   @ prow()  ,val(POS_CHEQ->Dia)     say left(dtoc(XDATASYS),2)
   @ prow()  ,val(POS_CHEQ->Mes)     say qnomemes(XDATASYS)
   @ prow()  ,val(POS_CHEQ->Ano)     say right(dtoc(XDATASYS),2)

   @ prow()+2,0 say repli("-",80)
   @ prow()+1,0 say "Banco..: " + fCOD_BANCO + "  " + iif(BANCO->(Dbseek(fCOD_BANCO)), left(BANCO->Descricao,15) , space(15) ) + "    Nr. Cheque..: " + fNR_CHEQUE

   @ prow()+1,0 say "        Historico                                               Valor     "

   for nCONT := 1 to len(nHIST)
       @ prow()+1,0 say nHIST[nCONT,1] + "   " + transform(nHIST[nCONT,2], "@E 9,999,999.99")
   next

   nHIST := {}

   @ prow()+3,0 say ""

   qstopprn(.F.)

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A BAIXA DOS PAGAMENTOS ______________________________

static function i_juros

    local lCONF := .F.
    local aEDICAO := {}

    //local bESCAPE := {|| empty(cTIPO).or.(XNIVEL==1.and.!XFLAG) .or.;
    //                    (XNIVEL==1.and.lastkey()==27)}
    XNIVEL := 1
    XFLAG  := .T.

    nJuros    := PAG_TESO->Juros
    nDesconto := PAG_TESO->Desconto


    // PREENCHE O VETOR DE EDICAO ___________________________________________


    aadd(aEDICAO,{{ || NIL                                             } ,"VALOR"  })
    aadd(aEDICAO,{{ || qgetx(-1,0,@nJuros   ,"@E 999,999.99"         ) } ,"JUROS"  })
    aadd(aEDICAO,{{ || qgetx(-1,0,@nDesconto,"@E 999,999.99"         ) } ,"DESCONTO"  })
    aadd(aEDICAO,{{ || NIL                                             } ,"VALOR_LIQ"  })

    aadd(aEDICAO,{{ || lCONF := qconf("Confirma Alteracao ?") },NIL})

    XNIVEL := 1
    XFLAG  := .T.

    do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
       eval ( aEDICAO [XNIVEL,1] )
       //if eval ( bESCAPE ) ; return ; endif
       if ! i_crit_2( aEDICAO[XNIVEL,2] ) ; loop ; endif
       iif ( XFLAG , XNIVEL++ , XNIVEL-- )
    enddo

    // GRAVACAO ______________________________________________________________

    if ! lCONF ; return ; endif

    qgirabarra()

    if PAG_TESO->(qrlock())
       replace PAG_TESO->Juros     with nJuros
       replace PAG_TESO->Desconto  with nDesconto
       replace PAG_TESO->Valor_liq with ((PAG_TESO->Valor+nJuros)-nDesconto)
       PAG_TESO->(qunlock())
    endif

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA CRITICA ______________________________________________________

function i_crit_2 ( cCAMPO )

   do case

      case cCAMPO == "VALOR"
           qrsay(XNIVEL,PAG_TESO->Valor,"@E 999,999.99")
           qrsay(XNIVEL+3,(PAG_TESO->Valor+nJuros)-nDesconto,"@E 999,999.99")


      case cCAMPO == "JUROS"
           qrsay(XNIVEL+2,(PAG_TESO->Valor+nJuros)-nDesconto,"@E 999,999.99")

      case cCAMPO == "DESCONTO"
           qrsay(XNIVEL+1,(PAG_TESO->Valor+nJuros)-nDesconto,"@E 999,999.99")

      case cCAMPO == "VALOR_LIQ"
           qrsay(XNIVEL,(PAG_TESO->Valor+nJuros)-nDesconto,"@E 999,999.99")



   endcase


return .T.


