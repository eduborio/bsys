/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE TESOURARIA
// OBJETIVO...: PAGAMENTO DE LANCAMENTOS LIBERADOS (CONTAS A RECEBER)
// ANALISTA...:
// PROGRAMADOR: Eduardo Borio
// INICIO.....: MARCO DE 2007
// OBS........:
// ALTERACOES.:
function ts408

#include "inkey.ch"
#include "setcurs.ch"

private sBLOC1  := qlbloc("B408C","QBLOC.GLO",1)
private cTIPO       := ""
private nHISTORICO  := ""
private cCOD_BANCO  := space(5)
private fVALOR_LIQ  := 0
private nVLR_CHEQUE := 0
private nVLR_ESPEC  := 0
private nJuros      := 0
private nDesconto   := 0
private dDATA_RECEB := ctod("")
private cModelo     := " "

if ! quse(XDRV_CL,"CONFIG",{""},,"CFGFAT")
   qmensa("Nao foi possivel abrir ConfigFat!","BL")
   return .F.
else
   cModelo := CFGFAT->Modelo_2 + CFGFAT->Modelo_nf
   CFGFAT->(dbclosearea())
endif


BANCO->(Dbsetorder(3))

fu_abre_cli1()

// VIEW INICIAL _____________________________________________________________

RECEBER->(qview({{"Data_venc/Vencimento"         ,2},;
               {"left(cliente,22)/Cliente"     ,8},;
               {"f_408c()/    Valor"           ,6},;
               {"Fatura/Fatura"                ,11}},"P",;
               {NIL,"f408a",NIL,NIL},;
                NIL,"ESC/ALT-P/ALT-O/<C>onsulta/<B>aixa"))

//////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAGEM DO FORNECEDOR _______________________________________

function f_408b
   CLI1->(dbseek(RECEBER->Cod_cli))
return left(CLI1->Razao,22)

//////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAGEM DE VALOR COM PICTURE ________________________________

function f_408c
return(transform(RECEBER->Valor_liq,"@E 9,999,999.99"))

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function f408a
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))

   do case

      case cOPCAO == "C"
         qlbloc(05,02,"B403A","QBLOC.GLO",1)
         qmensa(qabrev(cOPCAO,"C",{"Consulta..."}))
         i_consulta()

      case cOPCAO == "B"
         qlbloc(10,04,"B408B","QBLOC.GLO",1)
         qmensa(qabrev(cOPCAO,"B",{"Baixa..."}))
         cCOD_BANCO := RECEBER->Cod_banco
         i_baixa()

      case cOPCAO == "S"
         i_pesq_nota()


   endcase

   setcursor(nCURSOR)
return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA ____________________________________

static function i_consulta

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO == "C"
      XNIVEL := 1
      qrsay ( XNIVEL++ , RECEBER->Codigo       )
      qrsay ( XNIVEL++ , RECEBER->Data_lanc    )
      qrsay ( XNIVEL++ , RECEBER->Cod_cli      ) ; CLI1->(dbseek(RECEBER->Cod_cli))
      qrsay ( XNIVEL++ , left(CLI1->Razao,40))
      qrsay ( XNIVEL++ , RECEBER->Centro       ) ; CCUSTO->(dbseek(RECEBER->Centro))
      qrsay ( XNIVEL++ , left(CCUSTO->Descricao,40))
      qrsay ( XNIVEL++ , RECEBER->Filial       ) ; FILIAL->(dbseek(RECEBER->Filial))
      qrsay ( XNIVEL++ , left(FILIAL->Razao,40))
      qrsay ( XNIVEL++ , RECEBER->Data_emiss   )
      qrsay ( XNIVEL++ , RECEBER->Especie      ) ; ESPECIE->(dbseek(RECEBER->Especie))
      qrsay ( XNIVEL++ , left(ESPECIE->Descricao,13))
      qrsay ( XNIVEL++ , RECEBER->Serie        ) ; SERIE->(dbseek(RECEBER->Serie))
      qrsay ( XNIVEL++ , left(SERIE->Descricao,11))
      qrsay ( XNIVEL++ , RECEBER->Tipo_sub     ) ; TIPOCONT->(dbseek(RECEBER->Tipo_sub) )
      qrsay ( XNIVEL++ , left(TIPOCONT->Descricao,46))
      qrsay ( XNIVEL++ , left(RECEBER->Historico,60))
      qrsay ( XNIVEL++ , RECEBER->Data_venc    )
      qrsay ( XNIVEL++ , RECEBER->Data_prorr   )
      qrsay ( XNIVEL++ , transform(RECEBER->Valor,"@E 9,999,999.99"     ))
      qrsay ( XNIVEL++ , RECEBER->Tipo_doc     ) ; TIPO_DOC->(dbseek(RECEBER->Tipo_doc))
      qrsay ( XNIVEL++ , TIPO_DOC->Descricao   )
      qrsay ( XNIVEL++ , RECEBER->Fatura       )
      qrsay ( XNIVEL++ , RECEBER->Duplicata    )
      qrsay ( XNIVEL++ , RECEBER->Cgm          ) ; CGM->(dbseek(RECEBER->Cgm))
      qrsay ( XNIVEL++ , left(CGM->Municipio,40))
      qrsay ( XNIVEL++ , RECEBER->Cod_Banco    ) ; BANCO->(Dbseek(RECEBER->Cod_banco))
      qrsay ( XNIVEL++ , BANCO->Descricao      )
      qrsay ( XNIVEL++ , RECEBER->Situacao     ) ; SITUA->(dbseek(RECEBER->Situacao))
      qrsay ( XNIVEL++ , left(SITUA->Descricao,28))
      qrsay ( XNIVEL++ , RECEBER->Data_cont    )
      qrsay ( XNIVEL++ , RECEBER->Vendedor     ) ; FUN->(dbseek(RECEBER->Vendedor))
      qrsay ( XNIVEL++ , left(FUN->Nome,40)    )
      qrsay ( XNIVEL++ , left(RECEBER->Observacao,59))
   endif

   qwait()

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A BAIXA DOS RECEBIMENTOS ____________________________

static function i_baixa

    local lCONF       := .F.
    local aEDICAO     := {}

    local bESCAPE := {|| empty(dDATA_RECEB).or.(XNIVEL==1.and.!XFLAG) .or.;
                        (XNIVEL==1.and.lastkey()==27)}

    XNIVEL := 1
    XFLAG  := .T.

    // PREENCHE O VETOR DE EDICAO ___________________________________________

    aadd(aEDICAO,{{ || qgetx(-1,0,@dDATA_RECEB ,"@D"              ) } ,"DATA_RECEB" })
    aadd(aEDICAO,{{ || qesco(-1,0,@cTIPO , sBLOC1                 ) } ,"TIPO"       })
    aadd(aEDICAO,{{ || view_banco(-1,0,@cCOD_BANCO)                   },"COD_BANCO" })
    aadd(aEDICAO,{{ || NIL                                            },NIL         })
    aadd(aEDICAO,{{ || NIL                                            },NIL         })
   //aadd(aEDICAO,{{ || qgetx(-1,0,@fVALOR    ,"9,999,999.99"         )},"VALOR"})
    aadd(aEDICAO,{{ || qgetx(-1,0,@nJUROS    ,"9,999,999.99"        )},"JUROS"})
    aadd(aEDICAO,{{ || qgetx(-1,0,@nDESCONTO ,"9,999,999.99"        ) },"DESCONTO"})
    aadd(aEDICAO,{{ || NIL                                            },NIL         })


    aadd(aEDICAO,{{ || lCONF := qconf("Confirma Recebimento ?") },NIL})

    XNIVEL    := 1
    XFLAG     := .T.
    nJuros    := 0
    nDesconto := 0

    dDATA_RECEB := XDATA
    do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
       eval ( aEDICAO [XNIVEL,1] )
       if eval ( bESCAPE ) ; return ; endif
       if ! i_crit_2( aEDICAO[XNIVEL,2] ) ; loop ; endif
       iif ( XFLAG , XNIVEL++ , XNIVEL-- )
    enddo

    // GRAVACAO ______________________________________________________________

    if ! lCONF ; return ; endif

    qgirabarra()

    RECEBER->(qpublicfields())
    RECEBER->(qcopyfields())

    if RECEBIDO->(qrlock()) .and. RECEBIDO->(qappend()) .and. RECEBER->(qrlock())

       fDATA_PAGTO := dDATA_RECEB
       fCOD_BANCO  := cCOD_BANCO
       fTIPO       := cTIPO
       fJuros      := nJuros
       fDesconto   := nDesconto

       fVLR_CHEQUE := 0
       fVLR_ESPEC  := 0
       fCONTABIL   := .F.
       // if cMODELO == "7  "
       //    fVALOR_LIQ  := (nVLR_ESPEC + nVLR_CHEQUE)
       // endif

       fValor_liq := ((fValor + fJuros) - fdesconto)

       RECEBIDO->(qreplacefields())  // grava no arquivo dos lancamentos ja recebidos
       RECEBIDO->(qunlock())

       if cTIPO == "4"
          if MOV_BANC->(qappend())

             replace MOV_BANC->Data with dDATA_RECEB
             replace MOV_BANC->Data_comp with dDATA_RECEB
             replace MOV_BANC->Form_pgto with RECEBER->Form_pgto
             replace MOV_BANC->Cod_banco with cCOD_BANCO
             i_hist("RECEBER")
             replace MOV_BANC->Historico with nHISTORICO
             replace MOV_BANC->Entrada   with RECEBER->Valor_liq
             replace MOV_BANC->Num_docto with left(RECEBER->Fatura,6)
             replace MOV_BANC->Concilia  with "0"
             replace MOV_BANC->Internal  with "RE"+RECEBER->Codigo
          endif
       endif

       if cTIPO == "5"
          if MOV_CAIX->(qappend())

             replace MOV_CAIX->Data with dDATA_RECEB //CONFIG->Data_atual
             replace MOV_CAIX->Form_pgto with RECEBER->Form_pgto
             replace MOV_CAIX->Cod_banco with "99999"
             i_hist("RECEBER")
             replace MOV_CAIX->Historico with nHISTORICO
             replace MOV_CAIX->Entrada   with RECEBER->Valor_liq
             replace MOV_CAIX->Num_docto with left(RECEBER->Fatura,6)
             replace MOV_CAIX->Internal  with "RE"+RECEBER->Codigo
          endif
       endif

//       if cTIPO == "7"
//       endif


       RECEBER->(dbdelete())     // exclui do arquivo dos lancamentos liberados para EC_TESO
       RECEBER->(qunlock())

    else

       qm1()

    endif

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA CRITICA ______________________________________________________

static function i_crit_2 ( cCAMPO )

   do case

      case cCAMPO == "COD_BANCO"

//         if cTIPO $ "123"
//            XNIVEL += 2
//         endif

           if ! empty(cCOD_BANCO)

              if ! BANCO->(dbseek(cCOD_BANCO:=strzero(val(cCOD_BANCO),5)))
                  qmensa("Banco n„o Cadastrado !","B")
                  return .F.
              endif

              qrsay(XNIVEL+1,left(BANCO->Descricao,30))

           else
              if cTIPO != "7"
                 return .F.
              endif
           endif

           fVALOR := RECEBER->Valor

           qrsay(XNIVEL+2,transform(RECEBER->Valor,"@R 9,999,999.99"))

      case cCAMPO == "TIPO"

           if empty(cTIPO) ; return .F. ; endif

           qrsay(XNIVEL,qabrev(cTIPO,"1234567",{"Carteira","Cheque","Cheque Pr‚-Datado","Banco","Caixa","Desconto","Bx Conta 139-2"}))
           if cTIPO $ "1*2*3*5"
              cCOD_BANCO := "99999"
              BANCO->(dbseek(cCOD_BANCO))
              qrsay(XNIVEL+1,cCOD_BANCO)
              qrsay(XNIVEL+2,left(BANCO->Descricao,30))
           endif

      case cCAMPO == "DATA_RECEB"

           if empty(dDATA_RECEB)
              qmensa("Campo Obrigatorio...","B")
              return .F.
           endif

           //if dDATA_RECEB <  CONFIG->Data_atual
           //   qmensa("O Caixa desta data ja foi Encerrado. Data de Recebimento Invalida !","B")
           //   qmensa(" ")
           //
           //   return .F.
           //endif
       //case cCAMPO == "JUROSVALOR_LIQ"

            //if XFLAG
            //   if nVLR_ESPEC <> 0 .or. nVLR_CHEQUE <> 0
             //     if fVALOR_LIQ <> (nVLR_CHEQUE+nVLR_ESPEC)
            //         qmensa("Soma nÆo Confere !","B")
            //         return .f.
            //      endif
            //   endif
            //endif

       //case cCAMPO == "VLR_CHEQUE"

           // if XFLAG
           //    if nVLR_ESPEC == 0 .and. nVLR_CHEQUE == 0
           //       qmensa("Campo obrigatorio !","B")
           //       return .f.
           //   endif
           // endif

       case cCAMPO == "DESCONTO"

           // if XFLAG
           //    if nVLR_ESPEC == 0 .and. nVLR_CHEQUE == 0
           //       qmensa("Campo obrigatorio !","B")
           //       return .f.
           //   endif
           // endif

           qrsay(XNIVEL+1,transform(RECEBER->Valor+nJuros-nDesconto,"@R 9,999,999.99"))





     endcase

return .T.

///////////////////////////////////////////////////////////////
// FUNCAO UTILIZADA PARA A MONTAGEM DO HISTORICO PADRAO _______

static function i_hist(cARQ)

   TIPOCONT->(Dbseek((cARQ)->Tipo_sub))

   if TIPOCONT->Regime_ope == "2" // Regime de competencia
      nHISTORICO := TIPOCONT->Hist_l_2
   else // Regime de Caixa
      nHISTORICO := TIPOCONT->Hi_l_liq2
   endif

   HIST->(dbseek(nHISTORICO))
   nHIST := HIST->Descricao

   nHISTORICO := ""

   for nCONT := 1 to len(nHIST)

       if ( nPOS := at("[",nHIST) )  <> 0

          iif(nPOS <> 1 ,nHISTORICO += substr(nHIST,1,nPOS-1),)

          nPOS += 2  // para ignorar os simbolos [@

          do case

             case substr(nHIST,nPOS,2) == "CA"
                  CLI1->(dbseek((cARQ)->Cod_cli))
                  nHISTORICO += left(CLI1->Razao,20) + " "
             case substr(nHIST,nPOS,3) == "CGC"
                  CLI1->(dbseek((cARQ)->Cod_cli))
                  nHISTORICO += CLI1->Cgccpf + " "
             case substr(nHIST,nPOS,2) == "DA"
                  nHISTORICO += dtoc(XDATASYS) + " "
             case substr(nHIST,nPOS,2) == "DP"
                  nHISTORICO += alltrim((cARQ)->Duplicata) + " "
             case substr(nHIST,nPOS,2) $ "FA-NF-NT"
                  nHISTORICO += alltrim((cARQ)->Fatura) + " "
             case substr(nHIST,nPOS,2) == "EP"
                  ESPECIE->(dbseek((cARQ)->Especie))
                  nHISTORICO += left(ESPECIE->Descricao,3) + " "
             case substr(nHIST,nPOS,2) == "SE"
                  SERIE->(dbseek((cARQ)->Serie))
                  nHISTORICO += left(SERIE->Descricao,3) + " "
             case substr(nHIST,nPOS,2) == "BC"
                  BANCO->(dbseek((cARQ)->Cod_banco))
                  nHISTORICO += left(BANCO->Descricao,10) + " "
          endcase

          nHIST := substr( nHIST , nPOS+4 , len(nHIST) ) // retira da variavel nHIST, os mneumonicos que ja foram verificados

       else

         exit

       endif

   next

return

static function i_pesq_nota

   local nValor  := 0
   local nIndice := RECEBER->(indexord())
   local nRec    := RECEBER->(recno())

   qmensa("Digite o valor da Fatura p/ pesquisa:          ")
   qgetx(24,48,@nValor ,"@E 9,999,999.99")


   RECEBER->(dbsetorder(6))
   if ! RECEBER->(dbseek(nValor))
      RECEBER->(dbsetorder(nIndice))
      qmensa("Fatura n„o encontrada !","BL")
      RECEBER->(dbgoto(nREC))
      return
   endif
return

