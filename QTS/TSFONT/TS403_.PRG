/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE TESOURARIA
// OBJETIVO...: PAGAMENTO DE LANCAMENTOS LIBERADOS (CONTAS A RECEBER)
// ANALISTA...:
// PROGRAMADOR: Eduardo Borio
// INICIO.....: MARCO DE 2007
// OBS........:
// ALTERACOES.:

function ts403

#include "inkey.ch"
#include "setcurs.ch"

private sBLOC1  := qlbloc("B403C","QBLOC.GLO",1)
private cTIPO       := ""
private nHISTORICO  := ""
private cCOD_BANCO  := space(5)
private fVALOR_LIQ  := 0
private nVLR_CHEQUE := 0
private nVLR_ESPEC  := 0
private dDATA_RECEB := ctod("")

BANCO->(Dbsetorder(3))

fu_abre_cli1()

// VIEW INICIAL _____________________________________________________________

REC_TESO->(qview({{"Data_venc/Vencimento"         ,2},;
               {"left(cliente,22)/Cliente"     ,7},;
               {"f_403c()/    Valor"           ,4},;
               {"Fatura/Fatura"                ,5}},"P",;
               {NIL,"f403a",NIL,NIL},;
                NIL,"ESC/ALT-P/ALT-O/<C>onsulta/<B>aixa"))

//////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAGEM DO FORNECEDOR _______________________________________

function f_403b
   CLI1->(dbseek(REC_TESO->Cod_cli))
return left(CLI1->Razao,22)

//////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAGEM DE VALOR COM PICTURE ________________________________

function f_403c
return(transform(REC_TESO->Valor_liq,"@E 9,999,999.99"))

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function f403a
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))

   do case

      case cOPCAO == "C"
         qlbloc(05,02,"B403A","QBLOC.GLO",1)
         qmensa(qabrev(cOPCAO,"C",{"Consulta..."}))
         i_consulta()

      case cOPCAO == "B"
         qlbloc(10,04,"B403B","QBLOC.GLO",1)
         qmensa(qabrev(cOPCAO,"B",{"Baixa..."}))
         cCOD_BANCO := REC_TESO->Cod_banco
         i_baixa()

   endcase

   setcursor(nCURSOR)
return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA ____________________________________

static function i_consulta

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO == "C"
      XNIVEL := 1
      qrsay ( XNIVEL++ , REC_TESO->Codigo       )
      qrsay ( XNIVEL++ , REC_TESO->Data_lanc    )
      qrsay ( XNIVEL++ , REC_TESO->Cod_cli      ) ; CLI1->(dbseek(REC_TESO->Cod_cli))
      qrsay ( XNIVEL++ , left(CLI1->Razao,40))
      qrsay ( XNIVEL++ , REC_TESO->Centro       ) ; CCUSTO->(dbseek(REC_TESO->Centro))
      qrsay ( XNIVEL++ , left(CCUSTO->Descricao,40))
      qrsay ( XNIVEL++ , REC_TESO->Filial       ) ; FILIAL->(dbseek(REC_TESO->Filial))
      qrsay ( XNIVEL++ , left(FILIAL->Razao,40))
      qrsay ( XNIVEL++ , REC_TESO->Data_emiss   )
      qrsay ( XNIVEL++ , REC_TESO->Especie      ) ; ESPECIE->(dbseek(REC_TESO->Especie))
      qrsay ( XNIVEL++ , left(ESPECIE->Descricao,13))
      qrsay ( XNIVEL++ , REC_TESO->Serie        ) ; SERIE->(dbseek(REC_TESO->Serie))
      qrsay ( XNIVEL++ , left(SERIE->Descricao,11))
      qrsay ( XNIVEL++ , REC_TESO->Tipo_sub     ) ; TIPOCONT->(dbseek(REC_TESO->Tipo_sub) )
      qrsay ( XNIVEL++ , left(TIPOCONT->Descricao,46))
      qrsay ( XNIVEL++ , left(REC_TESO->Historico,60))
      qrsay ( XNIVEL++ , REC_TESO->Data_venc    )
      qrsay ( XNIVEL++ , REC_TESO->Data_prorr   )
      qrsay ( XNIVEL++ , transform(REC_TESO->Valor,"@E 9,999,999.99"     ))
      qrsay ( XNIVEL++ , REC_TESO->Tipo_doc     ) ; TIPO_DOC->(dbseek(REC_TESO->Tipo_doc))
      qrsay ( XNIVEL++ , TIPO_DOC->Descricao   )
      qrsay ( XNIVEL++ , REC_TESO->Fatura       )
      qrsay ( XNIVEL++ , REC_TESO->Duplicata    )
      qrsay ( XNIVEL++ , REC_TESO->Cgm          ) ; CGM->(dbseek(REC_TESO->Cgm))
      qrsay ( XNIVEL++ , left(CGM->Municipio,40))
      qrsay ( XNIVEL++ , REC_TESO->Cod_Banco    ) ; BANCO->(Dbseek(REC_TESO->Cod_banco))
      qrsay ( XNIVEL++ , BANCO->Descricao      )
      qrsay ( XNIVEL++ , REC_TESO->Situacao     ) ; SITUA->(dbseek(REC_TESO->Situacao))
      qrsay ( XNIVEL++ , left(SITUA->Descricao,28))
      qrsay ( XNIVEL++ , REC_TESO->Data_cont    )
      qrsay ( XNIVEL++ , REC_TESO->Vendedor     ) ; FUN->(dbseek(REC_TESO->Vendedor))
      qrsay ( XNIVEL++ , left(FUN->Nome,40)    )
      qrsay ( XNIVEL++ , left(REC_TESO->Observacao,59))
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
    aadd(aEDICAO,{{ || qgetx(-1,0,@nVLR_ESPEC,"9,999,999.99"         )},"VLR_ESPEC"})
    aadd(aEDICAO,{{ || qgetx(-1,0,@nVLR_CHEQUE,"9,999,999.99"        )},"VLR_CHEQUE"})
    aadd(aEDICAO,{{ || qgetx(-1,0,@fVALOR_LIQ,"9,999,999.99"        ) },"VALOR_LIQ"})

    aadd(aEDICAO,{{ || lCONF := qconf("Confirma Recebimento ?") },NIL})

    XNIVEL := 1
    XFLAG  := .T.
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

    REC_TESO->(qpublicfields())
    REC_TESO->(qcopyfields())

    if RECEBIDO->(qrlock()) .and. RECEBIDO->(qappend()) .and. REC_TESO->(qrlock())

       fDATA_PAGTO := dDATA_RECEB
       fCOD_BANCO  := cCOD_BANCO
       fTIPO       := cTIPO
       fVLR_CHEQUE := nVLR_CHEQUE
       fVLR_ESPEC  := nVLR_ESPEC
       fVALOR_LIQ  := (nVLR_ESPEC + nVLR_CHEQUE)
       fCONTABIL   := .F.

       RECEBIDO->(qreplacefields())  // grava no arquivo dos lancamentos ja recebidos
       RECEBIDO->(qunlock())

       if cTIPO $ "4*6"
          if MOV_BANC->(qappend())

             replace MOV_BANC->Data with dDATA_RECEB
             replace MOV_BANC->Data_comp with dDATA_RECEB
             replace MOV_BANC->Form_pgto with REC_TESO->Form_pgto
             replace MOV_BANC->Cod_banco with cCOD_BANCO
             i_hist("REC_TESO")
             replace MOV_BANC->Historico with nHISTORICO
             replace MOV_BANC->Entrada   with (nVLR_ESPEC + nVLR_CHEQUE)
             replace MOV_BANC->Num_docto with left(REC_TESO->Fatura,6)
             replace MOV_BANC->Concilia  with "0"
             replace MOV_BANC->Internal  with "RE"+REC_TESO->Codigo

          endif


       else
          if MOV_CAIX->(qappend())

             replace MOV_CAIX->Data with dDATA_RECEB //CONFIG->Data_atual
             replace MOV_CAIX->Form_pgto with REC_TESO->Form_pgto
             replace MOV_CAIX->Cod_banco with "99999"
             i_hist("REC_TESO")
             replace MOV_CAIX->Historico with nHISTORICO
             replace MOV_CAIX->Entrada   with (nVLR_ESPEC + nVLR_CHEQUE)
             replace MOV_CAIX->Num_docto with left(REC_TESO->Fatura,6)
             replace MOV_CAIX->Internal  with "RE"+REC_TESO->Codigo
          endif


       endif

       nVLR_ESPEC  := 0
       nVLR_CHEQUE := 0

       REC_TESO->(dbdelete())     // exclui do arquivo dos lancamentos liberados para REC_TESO
       REC_TESO->(qunlock())

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
              return .F.
           endif

           fVALOR_LIQ := REC_TESO->Valor_liq

           qrsay(XNIVEL+4,transform(REC_TESO->Valor_liq,"@R 9,999,999.99"))

      case cCAMPO == "TIPO"

           if empty(cTIPO) ; return .F. ; endif

           qrsay(XNIVEL,qabrev(cTIPO,"123456",{"Carteira","Cheque","Cheque Pr‚-Datado","Cobranca Bancaria","Caixa","Desconto"}))
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
       case cCAMPO == "VALOR_LIQ"

            //if XFLAG
            //   if nVLR_ESPEC <> 0 .or. nVLR_CHEQUE <> 0
             //     if fVALOR_LIQ <> (nVLR_CHEQUE+nVLR_ESPEC)
            //         qmensa("Soma nÆo Confere !","B")
            //         return .f.
            //      endif
            //   endif
            //endif

       case cCAMPO == "VLR_CHEQUE"

            if XFLAG
               if nVLR_ESPEC == 0 .and. nVLR_CHEQUE == 0
                  qmensa("Campo obrigatorio !","B")
                  return .f.
              endif
            endif



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
