/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE CONTAS A RECEBER
// OBJETIVO...: ENVIO DE DOCUMENTOS PARA O BANCO
// ANALISTA...:
// PROGRAMADOR: LUCINEIDE VILAR POSSEBOM
// INICIO.....: ABRIL DE 1997
// OBS........:
// ALTERACOES.: ABRIL DE 2000 (ANDR SANTOS)
function pg404

//#include "inkey.ch"
//#include "setcurs.ch"

*fu_abre_FORN()

CCUSTO->(Dbsetorder(4))
BANCO->(Dbsetorder(3))

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

private dDATA_VENC := ctod("")
private aEDICAO1 := {}
private dDATA_INI  := ctod("")
private dDATA_FIN  := ctod("")
private nNUMERO
private nN_NUM := 900000
private nBANES := 0
private nCALCULO
private nTOT_VAL := 0
private cDT_EMIS   := space(1)
private dDATA_EM1  := ctod("")
private dDATA_EM2  := ctod("")
private cDT_VCTO   := space(1)
private dDATA_VC1  := ctod("")
private dDATA_VC2  := ctod("")
private cSITUA     := space(1)
private cSIT_COD   := space(2)
private cCLIENTE  := space(1)
private cCLI_COD   := space(5)
private cBANCO     := space(1)
private cBCO_COD   := space(5)

// VIEW INICIAL _____________________________________________________________

PAGAR->(dbSetFilter({|| empty (NUM_LOTE) }, 'empty (NUM_LOTE)'))

PAGAR->(qview({{"Data_venc/Vcto"              ,2},;
                 {"Cod_forn/Codigo"           ,6},;
                 {"f_404b()/Fornecedor"       ,0},;
                 {"f_404()/  Valor"           ,0},;
                 {"Fatura/Fatura"             ,0},;
                 {"Marcar/M"                  ,0}},"P",;
                 {NIL,"f404a",NIL,NIL},;
                  NIL,"ESC/ALT-P/ALT-O/<C>on/<F>ilt/<E>nv/<T>ot/<M>arca ou desmarca"))

//////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAGEM DO CLIENTE __________________________________________

function f_404b
   FORN->(dbseek(PAGAR->Cod_forn))
return left(FORN->Razao,30)

//////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAGEM DE VALOR COM PICTURE ________________________________

function f_404
return(transform(PAGAR->Valor,"@E 9999999.99"))

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function f404a
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO $ "C"
      qlbloc(05,02,"B404A","QBLOC.GLO",1)
      qmensa(qabrev(cOPCAO,"IA",{"Inclus„o...","Altera‡„o..."}))
      i_consulta()
   endif

   if cOPCAO == "M" ; i_marca()  ; return ; endif

   if cOPCAO == "F"

      aEDICAO1   := {}
      XNIVEL     := 1
      XFLAG      := .T.

      bESCAPE    := {||lastkey()==27}
      lCONF      := .F.

      qlbloc(10,13,"B404B","QBLOC.GLO",1)

      aadd(aEDICAO1,{{ || qgetx(13,15,@dDATA_EM1 , "@D"                    )},"DATA_EM1"  })
      aadd(aEDICAO1,{{ || qgetx(13,28,@dDATA_EM2 , "@D"                    )},"DATA_EM2"  })
      aadd(aEDICAO1,{{ || qgetx(13,41,@dDATA_VC1 , "@D"                    )},"DATA_VC1"  })
      aadd(aEDICAO1,{{ || qgetx(13,54,@dDATA_VC2 , "@D"                    )},"DATA_VC2"  })
      aadd(aEDICAO1,{{ || view_situa(15,25,@cSIT_COD, "99"                 )} ,"SIT_COD"  })
      aadd(aEDICAO1,{{ || NIL                                               } ,NIL        })
      aadd(aEDICAO1,{{ || view_forn(16,24,@cFORN_COD, "99999"              )} ,"FORN_COD" })
      aadd(aEDICAO1,{{ || NIL                                               } ,NIL        })
      aadd(aEDICAO1,{{ || view_banco(17,24,@cBCO_COD, "99999"              )} ,"BCO_COD"  })
      aadd(aEDICAO1,{{ || NIL                                               } ,NIL        })

      aadd(aEDICAO1,{{ || lCONF := qconf("Confirma Filtro ?") },NIL})

      do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO1)
         eval ( aEDICAO1 [XNIVEL,1] )
         if eval ( bESCAPE ) ; PAGAR->(qreleasefields()) ; return ; endif
         if ! i_crit1( aEDICAO1[XNIVEL,2] ) ; loop ; endif
         iif ( XFLAG , XNIVEL++ , XNIVEL-- )
      enddo

      if ! lCONF ;  return ; endif

      PAGAR->(Dbsetfilter())

      do case

         case ! empty(dDATA_EM1) .and. ! empty(dDATA_EM2)
              PAGAR->(dbSetFilter({|| Data_emiss >= dDATA_EM1 .and. Data_emiss <= dDATA_EM2}, 'Data_emiss >= dDATA_EM1 .and. Data_emiss <= dDATA_EM2'))
              PAGAR->(dbgotop())

         case ! empty(dDATA_EM1) .and. ! empty(dDATA_EM2) .and. ! empty(cSIT_COD)
              PAGAR->(dbSetFilter({|| Data_emiss >= dDATA_EM1 .and. Data_emiss <= dDATA_EM2 .and. Situacao == cSIT_COD}, 'Data_emiss >= dDATA_EM1 .and. Data_emiss <= dDATA_EM2 .and. Situacao == cSIT_COD'))
              PAGAR->(dbgotop())

         case ! empty(dDATA_EM1) .and. ! empty(dDATA_EM2) .and. ! empty(cFORN_COD)
              PAGAR->(dbSetFilter({|| Data_emiss >= dDATA_EM1 .and. Data_emiss <= dDATA_EM2 .and. Cod_forn == cFORN_COD}, 'Data_emiss >= dDATA_EM1 .and. Data_emiss <= dDATA_EM2 .and. Cod_cli == cFORN_COD'))
              PAGAR->(dbgotop())

         case ! empty(dDATA_EM1) .and. ! empty(dDATA_EM2) .and. ! empty(cBCO_COD)
              PAGAR->(dbSetFilter({|| Data_emiss >= dDATA_EM1 .and. Data_emiss <= dDATA_EM2 .and. Cod_banco == cBCO_COD}, 'Data_emiss >= dDATA_EM1 .and. Data_emiss <= dDATA_EM2 .and. Cod_banco == cBCO_COD'))
              PAGAR->(dbgotop())

         case ! empty(cCLI_COD) .and. ! empty(cBCO_COD) .and. ! empty(cSIT_COD)
              PAGAR->(dbSetFilter({|| Cod_cli == cCLI_COD .and. Cod_banco == cBCO_COD .and. Situacao == cSIT_COD}, 'Cod_cli === cCLI_COD .and. Cod_banco == cBCO_COD .and. Situacao == cSIT_COD'))
              PAGAR->(dbgotop())

         case ! empty(dDATA_VC1) .and. ! empty(dDATA_VC2)
              PAGAR->(dbSetFilter({|| Data_venc >= dDATA_VC1 .and. Data_venc <= dDATA_VC2}, 'Data_venc >= dDATA_VC1 .and. Data_venc <= dDATA_VC2'))
              PAGAR->(dbgotop())

         case ! empty(dDATA_VC1) .and. ! empty(dDATA_VC2) .and. ! empty(cSIT_COD)
              PAGAR->(dbSetFilter({|| Data_venc >= dDATA_VC1 .and. Data_venc <= dDATA_VC2 .and. Situacao == cSIT_COD}, 'Data_venc >= dDATA_VC1 .and. Data_venc <= dDATA_VC2 .and. Situacao == cSIT_COD'))
              PAGAR->(dbgotop())

         case ! empty(dDATA_VC1) .and. ! empty(dDATA_VC2) .and. ! empty(cFORN_COD)
              PAGAR->(dbSetFilter({|| Data_venc >= dDATA_VC1 .and. Data_venc <= dDATA_VC2 .and. Cod_forn == cFORN_COD}, 'Data_venc >= dDATA_VC1 .and. Data_venc <= dDATA_VC2 .and. Cod_forn == cFORN_COD'))
              PAGAR->(dbgotop())

         case ! empty(dDATA_VC1) .and. ! empty(dDATA_VC2) .and. ! empty(cBCO_COD)
              PAGAR->(dbSetFilter({|| Data_venc >= dDATA_VC1 .and. Data_venc <= dDATA_VC2 .and. Cod_banco == cBCO_COD}, 'Data_venc >= dDATA_VC1 .and. Data_venc <= dDATA_VC2 .and. Cod_banco == cBCO_COD'))
              PAGAR->(dbgotop())

         case ! empty(cSIT_COD)
              PAGAR->(dbSetFilter({|| Situacao == cSIT_COD}, 'Situacao == cSIT_COD'))
              PAGAR->(dbgotop())

         case ! empty(cFORN_COD)
              PAGAR->(dbSetFilter({|| Cod_forn == cFORN_COD}, 'Cod_forn == cFORN_COD'))
              PAGAR->(dbgotop())

         case ! empty(cBCO_COD)
              PAGAR->(dbSetFilter({|| Cod_banco == cBCO_COD}, 'Cod_banco == cBCO_COD'))
              PAGAR->(dbgotop())

      endcase

   endif

   if cOPCAO == "T"

      XNIVEL   := 1
      nTOT_BRU := nTOT_LIQ := nTOT_GER := 0
      lSAI     := .F.

      cCOD := PAGAR->Codigo

      qmensa("Aguarde... totalizando...")

      PAGAR->(dbgotop())

      do while ! PAGAR->(eof())

         if PAGAR->Codigo == cCOD
            lSAI := .T.
         endif

         if ! empty(PAGAR->Valor_1)
            nTOT_LIQ += ( PAGAR->Valor - PAGAR->Valor_1)
            nTOT_GER += ( PAGAR->Valor - PAGAR->Valor_1)
         else
            nTOT_BRU += PAGAR->Valor
            nTOT_GER += PAGAR->Valor
         endif

         if lSAI
            exit
         endif

         PAGAR->(Dbskip())

      enddo

      qlbloc(10,13,"B404D","QBLOC.GLO",1)
      qrsay(XNIVEL  ,transform(nTOT_BRU, "@R 999,999,999.99"))
      qrsay(XNIVEL+1,transform(nTOT_LIQ, "@R 999,999,999.99"))
      qrsay(XNIVEL+2,transform(nTOT_GER, "@R 999,999,999.99"))
      qwait()
      PAGAR->(dbgotop())
      nTOT_LIQ := nTOT_BRU := nTOT_GER := 0

   endif

   if cOPCAO == "E"

      if empty(dDATA_INI)
         qmensa("N„o foi definido FILTRO !!","B")
      else
         PAGAR->(dbSetFilter({|| Data_emiss >= dDATA_INI .and. Data_emiss <= dDATA_FIN .and. empty(Num_lote) }, 'Data_emiss >= dDATA_INI .and. Data_emiss <= dDATA_FIN .and. empty(Num_lote)'))
         PAGAR->(dbgotop())
      endif

      aEDICAO2   := {}
      XNIVEL     := 1
      XFLAG      := .T.
      fBANCO     := space(5)
      fFORM_PGTO := space(5)
      fNUM_LOTE  := space(5)
      bESCAPE    := {||lastkey()==27}
      lCONF      := .F.

      qlbloc(10,05,"B404C","QBLOC.GLO",1)

      aadd(aEDICAO2,{{ || NIL }                                         ,"NUM_LOTE"  })
      aadd(aEDICAO2,{{ || view_banco(-1,0,@fBANCO                   ) } ,"BANCO"     })
      aadd(aEDICAO2,{{ || NIL                                         } ,NIL         })
//      aadd(aEDICAO2,{{ || view_Pgto(-1,0,@fFORM_PGTO                ) } ,"FORM_PGTO" })
      aadd(aEDICAO2,{{ || NIL                                         } ,NIL         })

      aadd(aEDICAO2,{{ || lCONF := qconf("Confirma Envio ?") },NIL})

      cFORM_PGTO := fFORM_PGTO

      do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO2)
         eval ( aEDICAO2 [XNIVEL,1] )
         if eval ( bESCAPE ) ; PAGAR->(qreleasefields()) ; return ; endif
         if ! i_crit2( aEDICAO2[XNIVEL,2] ) ; loop ; endif
         iif ( XFLAG , XNIVEL++ , XNIVEL-- )
      enddo

      if ! lCONF ;  return ; endif

      qmensa("Aguarde ... Gerando Lote de Cobran‡a...")  // grava o numero do lote nos lacamentos filtrados ...

      do while ! PAGAR->(eof())

         if PAGAR->Marcar == "*"
            if PAGAR->(qrlock())
               replace PAGAR->Cod_banco with fBANCO
               replace PAGAR->Num_lote  with fNUM_LOTE
               replace PAGAR->Form_pgto with fFORM_PGTO
               PAGAR->(qunlock())
            else
               qmensa("N„o Consegui Travar o Registro - Tente Novamente ... ","B")
               return
            endif
         endif

         PAGAR->(dbskip())

      enddo

      PAGAR->(Dbgotop())

      if CONFIG->(qrlock())
         replace CONFIG->Num_lote with (CONFIG->Num_lote + 1)
      else
        qmensa("N„o Consegui Gerar N£mero do Lote... Verifique !!", "B")
        return
      endif

      qmensa("Aguarde... Criando arquivo CNAB ...")

      if i_gera_arq()
        qmensa("Arquivo CNAB Gerado com Sucesso !!", "B")
      else
        qmensa("N„o Consegui Gerar Arquivo CNAB... Verifique !!", "B")
      endif

      qmensa()

   endif

   setcursor(nCURSOR)
return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A CONSULTA NA TELA _________________________________

static function i_consulta

   // MONTA DADOS NA TELA ___________________________________________________

      XNIVEL := 1
      qrsay ( XNIVEL++ , PAGAR->Codigo       )
      qrsay ( XNIVEL++ , PAGAR->Data_lanc    )
      qrsay ( XNIVEL++ , PAGAR->Cod_forn     ) ; FORN->(dbseek(PAGAR->Cod_forn))
      qrsay ( XNIVEL++ , left(FORN->Razao,40))
      qrsay ( XNIVEL++ , PAGAR->Centro       ) ; CCUSTO->(dbseek(PAGAR->Centro))
      qrsay ( XNIVEL++ , left(CCUSTO->Descricao,40))
      qrsay ( XNIVEL++ , PAGAR->Filial       ) ; FILIAL->(dbseek(PAGAR->Filial))
      qrsay ( XNIVEL++ , left(FILIAL->Razao,40))
      qrsay ( XNIVEL++ , PAGAR->Data_emiss   )
      qrsay ( XNIVEL++ , PAGAR->Especie      ) ; ESPECIE->(dbseek(PAGAR->Especie))
      qrsay ( XNIVEL++ , left(ESPECIE->Descricao,13))
      qrsay ( XNIVEL++ , PAGAR->Serie        ) ; SERIE->(dbseek(PAGAR->Serie))
      qrsay ( XNIVEL++ , left(SERIE->Descricao,11))
      qrsay ( XNIVEL++ , PAGAR->Tipo_sub     ) ; TIPOCONT->(dbseek(PAGAR->Tipo_sub) )
      qrsay ( XNIVEL++ , left(TIPOCONT->Descricao,46))
      qrsay ( XNIVEL++ , left(PAGAR->Historico,60))
      qrsay ( XNIVEL++ , PAGAR->Data_venc    )
      qrsay ( XNIVEL++ , PAGAR->Data_prorr   )
      qrsay ( XNIVEL++ , transform(PAGAR->Valor,"@E 9,999,999.99"     ))
      qrsay ( XNIVEL++ , PAGAR->Tipo_doc     ) ; TIPO_DOC->(dbseek(PAGAR->Tipo_doc))
      qrsay ( XNIVEL++ , TIPO_DOC->Descricao   )
      qrsay ( XNIVEL++ , PAGAR->Fatura       )
      qrsay ( XNIVEL++ , PAGAR->Duplicata    )
      qrsay ( XNIVEL++ , PAGAR->Cgm          ) ; CGM->(dbseek(PAGAR->Cgm))
      qrsay ( XNIVEL++ , left(CGM->Municipio,40))
      qrsay ( XNIVEL++ , PAGAR->Cod_Banco    ) ; BANCO->(Dbseek(PAGAR->Cod_banco))
      qrsay ( XNIVEL++ , BANCO->Descricao      )
      qrsay ( XNIVEL++ , PAGAR->Situacao     ) ; SITUA->(dbseek(PAGAR->Situacao))
      qrsay ( XNIVEL++ , left(SITUA->Descricao,28))
      qrsay ( XNIVEL++ , PAGAR->Data_cont    )
//      qrsay ( XNIVEL++ , PAGAR->Vendedor     ) ; FUN->(dbseek(PAGAR->Vendedor))
//      qrsay ( XNIVEL++ , left(FUN->Nome,40)    )
      qrsay ( XNIVEL++ , left(PAGAR->Observacao,59))

      qwait()

return

/////////////////////////////////////////////////////////////////////////////
// CRITICAS NA DESCIDA ______________________________________________________

static function i_crit1 ( cCAMPO )

do case

      case cCAMPO == "DATA_VC2"
           if ! empty(cDT_VCTO)
              if dDATA_VC2 < dDATA_VC1
                 qmensa("Data Inicial n„o pode ser maior que a Data Final !","B")
                 return .F.
              endif
           endif

      case cCAMPO == "SIT_COD"
           if ! empty(cSIT_COD)
              if ! SITUA->(dbseek(cSIT_COD))
                 qmensa("Situacao n„o Cadastrada !","B")
                 return .F.
              else
                 qsay(15,30,left(SITUA->Descricao,15))
              endif
           endif

      case cCAMPO == "FORN_COD"

           if ! empty(cFORN_COD)
              qsay(16,24,cFORN_COD:=strzero(val(cFORN_COD),5))
              if ! FORN->(dbseek(cFORN_COD))
                 qmensa("Forcenedor n„o Cadastrado !","B")
                 return .F.
              else
                 qsay(16,32,left(FORN->Razao,15))
              endif
           endif

      case cCAMPO == "BCO_COD"

           if ! empty(cBCO_COD)
              qrsay(17,24,cBCO_COD)

              if ! BANCO->(dbseek(cBCO_COD))
                 qmensa("Banco n„o Encontrado !","B")
                 return .F.
              else
                 qsay(17,32,left(BANCO->Descricao,20))
              endif
           endif


endcase


return .T.

/////////////////////////////////////////////////////////////////////////////
// CRITICAS NA DESCIDA ______________________________________________________

static function i_crit2 ( cCAMPO )

do case

      case cCAMPO == "NUM_LOTE"
           fNUM_LOTE := str(CONFIG->Num_lote + 1)
           qrsay(XNIVEL,fNUM_LOTE:=strzero(val(fNUM_LOTE),5))

      case cCAMPO == "BANCO"
           qrsay(XNIVEL,fBANCO)

           if ! BANCO->(dbseek(fBANCO:=strzero(val(fBANCO),5)))
              qmensa("Banco n„o Encontrado !","B")
              return .F.
           else
              qrsay(XNIVEL+1,left(BANCO->Descricao,30))
              if ! BANCO->Banco $ "0038-0422-0353-0291-0033"
                 qmensa("Banco n„o possui Lay-out para CNAB !","B")
                 return .F.
              endif
              if ! LAY_OUT->(Dbseek(BANCO->Banco))
                 qmensa("O Lay-out n„o foi definido - Verifique opcao <103> !","B")
                 return .F.
              endif
           endif

      case cCAMPO == "FORM_PGTO"
           qrsay(XNIVEL,fFORM_PGTO)

           if ! FORM_PGT->(dbseek(fFORM_PGTO:=strzero(val(fFORM_PGTO),5)))
              qmensa("Forma de Pagamento n„o Encontrada !","B")
              return .F.
           else
              qrsay(XNIVEL+1,FORM_PGT->Descricao)
           endif
endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA GERAR ARQUIVO CNAB ___________________________________________

static function i_gera_arq

     local nBANCO := space(4)

     BANCO->(dbsetorder(3))
     BANCO->(dbseek(fBANCO))
     nBANCO := BANCO->Banco

     do case
        case BANCO->Banco == "0038"
          i_banestado()
        case BANCO->Banco == "0422"
          i_safra()
        case BANCO->Banco == "0353"
          i_geralcom()
        case BANCO->Banco == "0291"
          i_crednac()
        case BANCO->Banco == "0033"
          i_banespa()

        otherwise

          return .F.
     endcase
return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA GERAR ARQUIVO CNAB (BANESTADO) ______________________________

static function i_banestado

   local nSEQ  := 1 , cINTEG := "" , nVALOR := 0 , nTOT_VAL := 0

   // ABRE ARQUIVO INTEGRA.DBF E ZERA _______________________________________

   if ! quse(XDRV_PG,"INTEGRA",NIL,"E")
      qmensa("N„o foi poss¡vel abrir arquivo INTEGRA.DBF !! Tente novamente.")
      return
   endif

   INTEGRA->(__dbzap())

   // MONTA REGISTRO TIPO 0 (HEADER) ________________________________________

   LAY_OUT->(Dbseek(BANCO->Banco))

   cINTEG = "0PIBPAGTOS.INTEGR.BANESTADO01REMESSAPAGTOS       " + qinvert(date(),7) + substr(time(),1,2) + substr(time(),4,2) + substr(time(),7,2) + right(BANCO->Agencia,3) + BANCO->Conta + left(XRAZAO,30) + space(11) + 'PAGTOS' + 'PAGTOS' + space(12) + '000005' + '000001'

*   cINTEG = "01REMESSA01COBRANCA       " + space(7) + left(LAY_OUT->Ag_banes,5) + BANCO->Conta + right(BANCO->Conta,1) + left(XRAZAO,30)
*   cINTEG += "038BANESTADO      " + qtiraponto(dtoc(XDATASYS)) + "01600BPI" + space(286) + strzero(nSEQ,6)

   INTEGRA->(qappend())
   INTEGRA->Linha := cINTEG
   cINTEG := ""

   // MONTA REGISTROS TIPO 1  _______________________________________________

   PAGAR->(dbsetfilter())
   PAGAR->(dbgotop())

   PAGAR->(Dbsetorder(10)) // numero do lote
   PAGAR->(Dbseek(fNUM_LOTE))

   do while ! PAGAR->(eof()) .and. PAGAR->Num_lote == fNUM_LOTE

      qgirabarra()

      nSEQ++

**      cINTEG := "1" + '05' + qtiraponto(XCGCCPF) + '0004' + '00' space(7) + left(LAY_OUT->Ag_banes,5) + BANCO->Conta + right(BANCO->Conta,1) + space(25)  // OBS:. MODALIDADE FIXADA P/ CHEQUE = 02
**      cINTEG := "102" + qtiraponto(XCGCCPF) + space(7) + left(LAY_OUT->Ag_banes,5) + BANCO->Conta + right(BANCO->Conta,1) + space(25)
      do case
         case LAY_OUT->Carteira == "1"
              cCARTEIRA := "1"
         case LAY_OUT->Carteira == "2"
              cCARTEIRA := "5"
         case LAY_OUT->Carteira == "3"
              cCARTEIRA := "C"
         case LAY_OUT->Carteira == "4"
              cCARTEIRA := "D"
      endcase
      do case
         case LAY_OUT->Remessa == "1"
              cREMESSA := "01"
         case LAY_OUT->Remessa == "2"
              cREMESSA := "02"
         case LAY_OUT->Remessa == "3"
              cREMESSA := "04"
         case LAY_OUT->Remessa == "4"
              cREMESSA := "05"
         case LAY_OUT->Remessa == "5"
              cREMESSA := "06"
         case LAY_OUT->Remessa == "6"
              cREMESSA := "08"
         case LAY_OUT->Remessa == "7"
              cREMESSA := "09"
         case LAY_OUT->Remessa == "8"
              cREMESSA := "10"
         case LAY_OUT->Remessa == "9"
              cREMESSA := "18"
      endcase

      if LAY_OUT->N_numero == "1"

*         cINTEG += replicate("0",10)

      else

         i_calc()

*         cINTEG += nCALCULO

         nBANES += 1 // numero devera ser incrementado

         if nBANES == 999999999
            nBANES := 0
         endif

      endif

*      cINTEG += space(10) + space(25) + cCARTEIRA + cREMESSA + left(PAGAR->Duplicata,10) + qtiraponto(dtoc(PAGAR->Data_venc))

      do case
         case LAY_OUT->Especie == "1"
              cESPECIE := "22"
         case LAY_OUT->Especie == "2"
              cESPECIE := "05"
         case LAY_OUT->Especie == "3"
              cESPECIE := "01"
         case LAY_OUT->Especie == "4"
              cESPECIE := "99"
      endcase
      do case
         case LAY_OUT->Titulos == "1"
              cTITULOS := "A"
         case LAY_OUT->Titulos == "2"
              cTITULOS := "N"
      endcase

*      cINTEG += strzero(val(qtiraponto(str(PAGAR->Valor,12,2))),13) + "00000000" + cESPECIE +  cTITULOS +  qtiraponto(dtoc(PAGAR->Data_emiss)) + "0606"

      cDESC  := PAGAR->Valor_1

      // cINTEG += strzero(val(qtiraponto(str(PAGAR->Mora,11,2))),13) + qtiraponto(dtoc(PAGAR->Data_venc)) + strzero(val(qtiraponto(str(cDESC,11,2))),13) + replicate("0",13)

*      cINTEG += "0000000000000" + iif(cDESC==0,"000000",qtiraponto(dtoc(PAGAR->Data_venc))) + strzero(val(qtiraponto(str(cDESC,11,2))),13) + replicate("0",13)
*      cINTEG += "0000000000000"

      nVALOR += PAGAR->Valor

      FORN->(Dbseek(PAGAR->Cod_forn))

      if len(FORN->Cgccpf) == 14
         cCGCCPF := "02"
      else
         cCGCCPF := "01"
      endif

      cINTEG := "1" + right(PAGAR->FORM_PGTO,2) + substr(qtiraponto(XCGCCPF),1,10) + '0000' + '00' + left(FORN->Razao,40) + BANCO->Banco + BANCO->Agencia + '0000' + BANCO->Conta  // OBS:. DIGITO VERIFICADOR FIXADO = 00
      cINTEG  += substr(qinvert(XDATASYS,7),1,6) + ltrim(str(val(qinvert(PAGAR->Data_venc,7))-1)) + strzero(PAGAR->Valor,14,2) + '99' + '1' + space(30) + space(5) + strzero(nSEQ,6) + '  teste de andre'


*      cINTEG += cCGCCPF + strzero(val(FORN->Cgccpf),14,0) + left(FORN->Razao,40)

      CGM->(Dbseek(FORN->Cgm_cob))

*      cINTEG += left(FORN->End_cob,40) + space(12) + FORN->Cep_cob + left(CGM->Municipio,15) + CGM->Estado + space(43) + strzero(nSEQ,6)

      INTEGRA->(qappend())
      INTEGRA->Linha := cINTEG
      cINTEG := ""

      PAGAR->(dbskip())

   enddo

   // MONTA REGISTRO TIPO 9 (TRAILLER) ______________________________________

   nSEQ++

   cINTEG := "9" + strzero(nSEQ,6,0) + '000000' + strzero(val(qtiraponto(str(nVALOR,12,2))),15)
   cINTEG += space(371) + strzero(nSEQ,6)

   INTEGRA->(qappend())
   INTEGRA->Linha := cINTEG
   cINTEG := ""

   qmensa("Aguarde...Gravando arquivo...","B")

   cNOMARQ := alltrim(BANCO->Caminho) + "BANES" + strzero(day(date()),2) + ".TXT"
**BANES  -  ANDRE

   INTEGRA->(dbgotop())

   INTEGRA->(__dbSDF( .T., CNOMARQ , { } ,,,,, .F. ) )

   select PAGAR
   PAGAR->(dbgotop())

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA GERAR ARQUIVO CNAB (SAFRA) ______________________________

static function i_safra

   local nSEQ  := 1 , cINTEG := "" , nTOT_VAL := 0

   // ABRE ARQUIVO INTEGRA.DBF E ZERA _______________________________________

   if ! quse(XDRV_PG,"INTEGRA",NIL,"E")
      qmensa("N„o foi poss¡vel abrir arquivo INTEGRA.DBF !! Tente novamente.")
      return
   endif

   INTEGRA->(__dbzap())

   LAY_OUT->(Dbseek(BANCO->Banco))

   // MONTA REGISTRO TIPO 0 _________________________________________________

   cINTEG += "01REMESSA01COBRANCA       "+LAY_OUT->Insc_banco + space(6) + left(XRAZAO,30) + "422" + "BANCO SAFRA    " + qtiraponto(dtoc(XDATASYS))
   cINTEG += space(291) + "001" + strzero(nSEQ,6)

   INTEGRA->(qappend())
   INTEGRA->Linha := cINTEG
   cINTEG := ""

   PAGAR->(dbsetfilter())
   PAGAR->(dbgotop())

   PAGAR->(Dbsetorder(10)) // numero do lote
   PAGAR->(Dbseek(fNUM_LOTE))

   do while ! PAGAR->(eof()) .and. PAGAR->Num_lote == fNUM_LOTE

      nSEQ++

      FILIAL->(Dbseek(PAGAR->Filial))
      cCGCCPF := FILIAL->CGCCPF

      cINTEG := "1" + iif(len(cCGCCPF) == 14, "02" , "01" )  + strzero(val(cCGCCPF),14,0) + left(XRAZAO,14) + space(6) + space(25)
      cINTEG += left(PAGAR->Num_titulo,9) + space(30) + "0" + "00 00" + LAY_OUT->Carteira

      do case
         case LAY_OUT->Ocorrencia == "A"
              cOCORRENCIA := "01"
         case LAY_OUT->Ocorrencia == "B"
              cOCORRENCIA := "02"
         case LAY_OUT->Ocorrencia == "C"
              cOCORRENCIA := "03"
         case LAY_OUT->Ocorrencia == "D"
              cOCORRENCIA := "04"
         case LAY_OUT->Ocorrencia == "E"
              cOCORRENCIA := "05"
         case LAY_OUT->Ocorrencia == "F"
              cOCORRENCIA := "06"
         case LAY_OUT->Ocorrencia == "G"
              cOCORRENCIA := "07"
         case LAY_OUT->Ocorrencia == "H"
              cOCORRENCIA := "08"
         case LAY_OUT->Ocorrencia == "I"
              cOCORRENCIA := "09"
         case LAY_OUT->Ocorrencia == "J"
              cOCORRENCIA := "10"
         case LAY_OUT->Ocorrencia == "K"
              cOCORRENCIA := "11"
         case LAY_OUT->Ocorrencia == "L"
              cOCORRENCIA := "15"
         case LAY_OUT->Ocorrencia == "M"
              cOCORRENCIA := "16"
      endcase

      cINTEG += cOCORRENCIA + left(PAGAR->Num_titulo,10) + qtiraponto(dtoc(PAGAR->Data_venc)) + strzero(val(qtiraponto(str(PAGAR->Valor,12,2))),13)
      cINTEG += "422" + strzero(val(BANCO->Agencia),5,0) + strzero(val(LAY_OUT->Especie),2,0) + LAY_OUT->Aceito + qtiraponto(dtoc(PAGAR->Data_emiss))

      cINTEG +=  strzero(val(LAY_OUT->Instrucao),2,0) + strzero(val(LAY_OUT->Instrucao),2,0) + "0000000000000" + qtiraponto(dtoc(PAGAR->Data_venc))
      cINTEG += iif( PAGAR->Valor_1 <> 0, strzero( val(transform( PAGAR->Valor_1, "@e 9999999999999")),13) , "0000000000000") + strzero(val(transform(LAY_OUT->IOF, "@E 9999999999999")),13)
      cINTEG += "0000000000000"

      FORN->(Dbseek(PAGAR->Cod_cli))

      iif ( len(FORN->CGCCPF) == 14,  cINTEG += "02" , cINTEG += "01" )

      if CGM->(Dbseek(FORN->Cgm_cob))
         cMUNICIPIO := left(CGM->Municipio,15)
         cUF := CGM->Estado
      else
         cMUNICIPIO := space(15)
         cUF := space(2)
      endif

      cINTEG += strzero(val(FORN->Cgccpf),14,0) +  left(FORN->Razao,40) + left(FORN->End_cob,40) + space(10) + space(2) + FORN->Cep_cob + cMUNICIPIO + cUF + space(30)
      cINTEG += "0000000" + space(3) +  "001" + strzero(nSEQ,6)

      nTOT_VAL := nTOT_VAL + PAGAR->Valor

      INTEGRA->(qappend())
      INTEGRA->Linha := cINTEG
      cINTEG := ""

      PAGAR->(dbskip())

   enddo

   // MONTA REGISTRO TIPO 9 _________________________________________________

   nSEQ++

   cINTEG += "9" + space(367) + strzero((nSEQ-1),8) + strzero(nTOT_VAL,15) + "001" + strzero(nSEQ,6)

   INTEGRA->(qappend())
   INTEGRA->Linha := cINTEG
   cINTEG := ""

   // GRAVA ARQUIVO NO DISQUETE _____________________________________________

   qmensa("Aguarde...Gravando arquivo...","B")

   cNOMARQ := alltrim(BANCO->Caminho) + "SAFRA" + strzero(day(date()),2) + ".TXT"

   INTEGRA->(dbgotop())

   INTEGRA->(__dbSDF( .T., CNOMARQ , { } ,,,,, .F. ) )

   select PAGAR
   PAGAR->(dbgotop())
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA GERAR ARQUIVO CNAB (BANCO GERAL DO COMERCIO) ________________

static function i_geralcom

      local nSEQ  := 1 , cINTEG := "" , nTOT_VAL := 0

      // ABRE ARQUIVO INTEGRA.DBF E ZERA _______________________________________

      if ! quse(XDRV_RB,"INTEGRA",NIL,"E")
         qmensa("N„o foi poss¡vel abrir arquivo INTEGRA.DBF !! Tente novamente.")
         return
      endif

      INTEGRA->(__dbzap())

      LAY_OUT->(Dbseek(BANCO->Banco))

      // MONTA REGISTRO TIPO 0 _________________________________________________

      cINTEG += "01REMESSA01COBRANCA       "
      cINTEG += LAY_OUT->Agen_ceden + CONFIG->Conta_mov + CONFIG->Conta_cob + left(XRAZAO,30) + "353BANGERAL       " + qtiraponto(dtoc(XDATASYS))
      cINTEG += replicate("0",16) + space(275) + "001000001"

      INTEGRA->(qappend())
      INTEGRA->Linha := cINTEG
      cINTEG := ""

      PAGAR->(dbsetfilter())
      PAGAR->(dbgotop())

      PAGAR->(Dbsetorder(6)) // numero do lote
      PAGAR->(Dbseek(fNUM_LOTE))

      do while ! PAGAR->(eof()) .and. PAGAR->Num_lote == fNUM_LOTE

         nSEQ++

         FILIAL->(Dbseek(PAGAR->Filial))
         cCGCCPF := FILIAL->CGCCPF

         cINTEG := "1" + iif(len(cCGCCPF) == 14, "02" , "01" )  + strzero(val(cCGCCPF),14,0) + LAY_OUT->Agen_ceden + CONFIG->Conta_mov + CONFIG->Conta_cob + space(25)

         nN_NUM++

         if LAY_OUT->CARTEIRA == "5"

            nNUMERO := left(LAY_OUT->Agen_ceden,3) + left(CONFIG->Conta_mov,6) + str(nN_NUM,6)

            i_calc_dig()

            cINTEG += nCALCULO

         else

           cINTEG += "00000000"

         endif

         cINTEG += "000000 4" + strzero(val(transform(PAGAR->Multa_per, "@R 9999")),4) + "000000000000000    000000"

         do case
            case LAY_OUT->Ocorrencia == "1"
               cOCORRENCIA := "01"
            case LAY_OUT->Ocorrencia == "2"
               cOCORRENCIA := "02"
            case LAY_OUT->Ocorrencia == "3"
               cOCORRENCIA := "04"
            case LAY_OUT->Ocorrencia == "4"
               cOCORRENCIA := "05"
            case LAY_OUT->Ocorrencia == "5"
               cOCORRENCIA := "06"
            case LAY_OUT->Ocorrencia == "6"
               cOCORRENCIA := "07"
            case LAY_OUT->Ocorrencia == "7"
               cOCORRENCIA := "08"
            case LAY_OUT->Ocorrencia == "8"
               cOCORRENCIA := "09"
            case LAY_OUT->Ocorrencia == "9"
               cOCORRENCIA := "18"
         endcase

         cINTEG += LAY_OUT->Carteira + cOCORRENCIA + left(LAY_OUT->Insc_banco,10) + qtiraponto(dtoc(PAGAR->Data_venc)) + strzero(val(transform(PAGAR->Valor, "9999999999999")),13)
         cINTEG += "353"

         if LAY_OUT->Carteira == "5"
            cINTEG += strzero(val(BANCO->Agencia),5,0)
         else
            cINTEG += "00000"
         endif

         do case
            case LAY_OUT->Especie == "1"
               cESPECIE := "01"
            case LAY_OUT->Especie == "2"
               cESPECIE := "02"
            case LAY_OUT->Especie == "3"
               cESPECIE := "03"
            case LAY_OUT->Especie == "4"
               cESPECIE := "05"
            case LAY_OUT->Especie == "5"
               cESPECIE := "06"
         endcase

         cINTEG += cESPECIE + "N" + qtiraponto(dtoc(PAGAR->Data_emiss))

         do case
            case LAY_OUT->Instrucao == "1"
               cINSTRUCAO := "00"
            case LAY_OUT->Instrucao == "2"
               cINSTRUCAO := "02"
            case LAY_OUT->Instrucao == "3"
               cINSTRUCAO := "03"
            case LAY_OUT->Instrucao == "4"
               cINSTRUCAO := "04"
            case LAY_OUT->Instrucao == "5"
               cINSTRUCAO := "06"
            case LAY_OUT->Instrucao == "6"
               cINSTRUCAO := "07"
            case LAY_OUT->Instrucao == "7"
               cINSTRUCAO := "08"
         endcase

         cINTEG +=  cINSTRUCAO + cINSTRUCAO + "0000000000000" + qtiraponto(dtoc(PAGAR->Data_venc))
         cINTEG += iif( PAGAR->Valor_1 <> 0, strzero( val(transform( PAGAR->Valor_1, "@e 9999999999999")),13) , "0000000000000") + strzero(val(transform(LAY_OUT->IOF, "@E 9999999999999")),13)
         cINTEG += "0000000000000"

         FORN->(Dbseek(PAGAR->Cod_cli))

         if len(FORN->CGCCPF) == 14
            cINTEG += "02"+FORN->CGCCPF
         else
            cINTEG += "01"+ strzero(val(FORN->CGCCPF),14,0)
            cINTEG += left(FORN->Cgccpf,9) + "000" + right(FORN->Cgccpf,2)
         endif

         if CGM->(Dbseek(FORN->Cgm_cob))
            cMUNICIPIO := left(CGM->Municipio,15)
            cUF := CGM->Estado
         else
            cMUNICIPIO := space(15)
            cUF := space(2)
         endif

         cINTEG += iif(  FORN->(Dbseek(PAGAR->Cod_cli))     ,    left(FORN->Razao,40) + left(FORN->End_cob,40) + space(12) + FORN->Cep_cob + cMUNICIPIO + cUF  , space(117) )
         cINTEG += space(30) + space(10) + iif( cINSTRUCAO == "06" , LAY_OUT->Dias_multa , "00" ) + " " + strzero(nSEQ,6)

         nTOT_VAL := nTOT_VAL + PAGAR->Valor

         INTEGRA->(qappend())
         INTEGRA->Linha := cINTEG
         cINTEG := ""

         PAGAR->(dbskip())

      enddo

      // MONTA REGISTRO TIPO 9 _________________________________________________

      nSEQ++

      cINTEG += "9" + strzero(nSEQ,6) + strzero(nTOT_VAL,13) + replicate("0",374) + strzero(nSEQ,6)

      INTEGRA->(qappend())
      INTEGRA->Linha := cINTEG
      cINTEG := ""

      // GRAVA ARQUIVO NO DISQUETE _____________________________________________

      qmensa("Aguarde...Gravando arquivo...","B")

      cNOMARQ := alltrim(BANCO->Caminho) + "GERCOM" + strzero(day(date()),2) + ".TXT"

      INTEGRA->(dbgotop())

      INTEGRA->(__dbSDF( .T., CNOMARQ , { } ,,,,, .F. ) )

      select PAGAR
      PAGAR->(dbgotop())

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA GERAR ARQUIVO CNAB (BANCO DE CREDITO NACIONAL) _______________

static function i_crednac

   local nSEQ  := 1 , cINTEG := "" , nVALOR := 0 , nTOT_VAL := 0

   // ABRE ARQUIVO INTEGRA.DBF E ZERA _______________________________________

   if ! quse(XDRV_RB,"INTEGRA",NIL,"E")
      qmensa("N„o foi poss¡vel abrir arquivo INTEGRA.DBF !! Tente novamente.")
      return
   endif

   INTEGRA->(__dbzap())

   // MONTA REGISTRO TIPO 0 (HEADER) ________________________________________

   LAY_OUT->(Dbseek(BANCO->Banco))

   cINTEG = "01REMESSA01COBRANCA       " + space(10) + left(BANCO->Agencia,3) + left(BANCO->Conta,6) + right(BANCO->Conta,1) + left(XRAZAO,30)
   cINTEG += "291B.C.N.         " + qtiraponto(dtoc(XDATASYS)) + "01600BPI" + space(280) + strzero(nSEQ,6) + strzero(nSEQ,6)

   INTEGRA->(qappend())
   INTEGRA->Linha := cINTEG
   cINTEG := ""

   // MONTA REGISTROS TIPO 1  _______________________________________________

   PAGAR->(dbsetfilter())
   PAGAR->(dbgotop())

   PAGAR->(Dbsetorder(6)) // numero do lote
   PAGAR->(Dbseek(fNUM_LOTE))

   do while ! PAGAR->(eof()) .and. PAGAR->Num_lote == fNUM_LOTE

      qgirabarra()

      nSEQ++

      cINTEG := "102" + qtiraponto(XCGCCPF) + space(10) + left(BANCO->Agencia,3) + left(BANCO->Conta,6) + right(BANCO->Conta,1) + space(25)
      cINTEG += space(12)

      nNUMERO := LAY_OUT->Noss_num

      i_noss_num()

      cINTEG += nCALCULO + space(25) + LAY_OUT->Carteira

      do case
         case LAY_OUT->Ocorrencia == "1"
              cOCORRENCIA := "01"
         case LAY_OUT->Ocorrencia == "2"
              cOCORRENCIA := "02"
         case LAY_OUT->Ocorrencia == "3"
              cOCORRENCIA := "04"
         case LAY_OUT->Ocorrencia == "4"
              cOCORRENCIA := "05"
         case LAY_OUT->Ocorrencia == "5"
              cOCORRENCIA := "06"
         case LAY_OUT->Ocorrencia == "6"
              cOCORRENCIA := "09"
         case LAY_OUT->Ocorrencia == "7"
              cOCORRENCIA := "18"
      endcase

      cINTEG += cOCORRENCIA + left(PAGAR->Num_titulo,10) + qtiraponto(dtoc(PAGAR->Data_venc)) + strzero(val(qtiraponto(str(PAGAR->Valor,12,2))),13)
      cINTEG += "29100000"

      do case
         case LAY_OUT->Especie == "1"
              cESPECIE := "01"
         case LAY_OUT->Especie == "2"
              cESPECIE := "02"
         case LAY_OUT->Especie == "3"
              cESPECIE := "03"
         case LAY_OUT->Especie == "4"
              cESPECIE := "05"
         case LAY_OUT->Especie == "5"
              cESPECIE := "99"
      endcase

      cINTEG += cESPECIE + LAY_OUT->Aceito + qtiraponto(dtoc(PAGAR->Data_emiss)) + "0000" + "0000000000000" + qtiraponto(dtoc(PAGAR->Data_venc))
      cINTEG += iif( PAGAR->Valor_1 <> 0, strzero( val(transform( PAGAR->Valor_1, "@e 9999999999999")),13) , "0000000000000")
      cINTEG += strzero(val(transform(LAY_OUT->Iof, "@E 9999999999999")),13) + "0000000000000"

      FORN->(Dbseek(PAGAR->Cod_cli))

      if len(FORN->Cgccpf) == 14
         cCGCCPF := "02"
      else
         cCGCCPF := "01"
      endif

      cINTEG += cCGCCPF + strzero(val(FORN->Cgccpf),14,0) + left(FORN->Razao,40)

      CGM->(Dbseek(FORN->Cgm_cob))

      cINTEG += left(FORN->End_cob,40) + space(12) + FORN->Cep_cob + left(CGM->Municipio,15) + CGM->Estado + space(43) + strzero(nSEQ,6)

      INTEGRA->(qappend())
      INTEGRA->Linha := cINTEG
      cINTEG := ""

      PAGAR->(dbskip())

   enddo

   // MONTA REGISTRO TIPO 9 (TRAILLER) ______________________________________

   nSEQ++

   cINTEG := "9" + space(393) + strzero(nSEQ,6)

   INTEGRA->(qappend())
   INTEGRA->Linha := cINTEG
   cINTEG := ""

   qmensa("Aguarde...Gravando arquivo...","B")

   cNOMARQ := alltrim(BANCO->Caminho) + "CREDNA" + strzero(day(date()),2) + ".TXT"

   INTEGRA->(dbgotop())

   INTEGRA->(__dbSDF( .T., CNOMARQ , { } ,,,,, .F. ) )

   select PAGAR
   PAGAR->(dbgotop())

return


/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA GERAR ARQUIVO CNAB (BANCO BANESPA ) __________________________

static function i_banespa

   local nSEQ  := 1 , cINTEG := ""
   local cOCORRENCIA := cTITULOS := cINSTRUCAO := "  "

   // ABRE ARQUIVO INTEGRA.DBF E ZERA _______________________________________

   if ! quse(XDRV_RB,"INTEGRA",NIL,"E")
      qmensa("N„o foi poss¡vel abrir arquivo INTEGRA.DBF !! Tente novamente.")
      return
   endif

   INTEGRA->(__dbzap())

   // MONTA REGISTRO TIPO 0 (HEADER) ________________________________________

   LAY_OUT->(Dbseek(BANCO->Banco))

   cINTEG = "01remessa01cobranca       " + "08452000027" + space(09) + left(XRAZAO,30)
   cINTEG += "033Banespa        " + qtiraponto(dtoc(XDATASYS)) + "01600BPI" + space(286) + strzero(nSEQ,6)

   INTEGRA->(qappend())
   INTEGRA->Linha := cINTEG
   cINTEG := ""

   // MONTA REGISTROS TIPO 1  _______________________________________________

   PAGAR->(dbsetfilter())
   PAGAR->(dbgotop())

   PAGAR->(Dbsetorder(6)) // numero do lote
   PAGAR->(Dbseek(fNUM_LOTE))

   do while ! PAGAR->(eof()) .and. PAGAR->Num_lote == fNUM_LOTE

      if empty(PAGAR->Marcar)
         PAGAR->(Dbskip())
         loop
      endif

      qgirabarra()

      nSEQ++

      cINTEG := "102" + qtiraponto(XCGCCPF) + "08452000027" + space(09) + space(25) + "084" + strzero(val(PAGAR->Codigo),7) + space(10)

      do case    // identificacao da ocorrencia
         case LAY_OUT->Ocorrencia == "A"
              cOCORRENCIA := "01"
         case LAY_OUT->Ocorrencia == "B"
              cOCORRENCIA := "02"
         case LAY_OUT->Ocorrencia == "C"
              cOCORRENCIA := "04"
         case LAY_OUT->Ocorrencia == "D"
              cOCORRENCIA := "05"
         case LAY_OUT->Ocorrencia == "E"
              cOCORRENCIA := "06"
         case LAY_OUT->Ocorrencia == "F"
              cOCORRENCIA := "07"
         case LAY_OUT->Ocorrencia == "G"
              cOCORRENCIA := "08"
         case LAY_OUT->Ocorrencia == "H"
              cOCORRENCIA := "09"
         case LAY_OUT->Ocorrencia == "I"
              cOCORRENCIA := "10"
         otherwise
              cOCORRENCIA := "00"
      endcase

      cINTEG += space(25) + "1" + cOCORRENCIA + left(PAGAR->Num_titulo,10) + qtiraponto(dtoc(PAGAR->Data_venc)) + strzero(val(qtiraponto(str(PAGAR->Valor,12,2))),13)
      // strzero( val(transform( PAGAR->Valor, "@e 9999999999999")),13)
      cINTEG += "03300000"

      do case  // nota 1
         case LAY_OUT->Titulos == "A"
              cTITULOS := "01"
         case LAY_OUT->Titulos == "B"
              cTITULOS := "02"
         case LAY_OUT->Titulos == "C"
              cTITULOS := "03"
         case LAY_OUT->Titulos == "D"
              cTITULOS := "05"
         case LAY_OUT->Titulos == "E"
              cTITULOS := "06"
         case LAY_OUT->Titulos == "F"
              cTITULOS := "07"
         case LAY_OUT->Titulos == "G"
              cTITULOS := "08"
         case LAY_OUT->Titulos == "H"
              cTITULOS := "09"
         case LAY_OUT->Titulos == "I"
              cTITULOS := "10"
         case LAY_OUT->Titulos == "J"
              cTITULOS := "11"
         case LAY_OUT->Titulos == "K"
              cTITULOS := "12"
         case LAY_OUT->Titulos == "L"
              cTITULOS := "21"
         case LAY_OUT->Titulos == "M"
              cTITULOS := "31"
         case LAY_OUT->Titulos == "N"
              cTITULOS := "98"
      endcase

      cINTEG += cTITULOS + LAY_OUT->Aceito + qtiraponto(dtoc(PAGAR->Data_emiss))

      do case  // nota 2
         case LAY_OUT->Instrucao == "A"
              cINSTRUCAO := "01"
         case LAY_OUT->Instrucao == "B"
              cINSTRUCAO := "06"
         case LAY_OUT->Instrucao == "C"
              cINSTRUCAO := "07"
         case LAY_OUT->Instrucao == "D"
              cINSTRUCAO := "08"
         case LAY_OUT->Instrucao == "E"
              cINSTRUCAO := "10"
         case LAY_OUT->Instrucao == "F"
              cINSTRUCAO := "12"
         case LAY_OUT->Instrucao == "G"
              cINSTRUCAO := "18"
         case LAY_OUT->Instrucao == "H"
              cINSTRUCAO := "22"
         case LAY_OUT->Instrucao == "I"
              cINSTRUCAO := "28"
         case LAY_OUT->Instrucao == "J"
              cINSTRUCAO := "30"
         case LAY_OUT->Instrucao == "K"
              cINSTRUCAO := "32"
         case LAY_OUT->Instrucao == "L"
              cINSTRUCAO := "34"
         case LAY_OUT->Instrucao == "M"
              cINSTRUCAO := "36"
         case LAY_OUT->Instrucao == "N"
              cINSTRUCAO := "38"
         otherwise
              cINSTRUCAO := "00"
      endcase

      cINTEG += cINSTRUCAO + cINSTRUCAO +  "9999999999999" +  qtiraponto(dtoc(PAGAR->Data_prorr))
      cINTEG += "0000000000000"

      cINTEG += strzero( val(transform( LAY_OUT->Iof, "@e 9999999999999")),13) + "0000000000000"

      FORN->(Dbseek(PAGAR->Cod_cli))

      if len(FORN->Cgccpf) == 14
         cCGCCPF := "02"
      else
         cCGCCPF := "01"
      endif

      cINTEG += cCGCCPF + strzero(val(FORN->Cgccpf),14,0) + left(FORN->Razao,40)

      CGM->(Dbseek(FORN->Cgm_cob))

      cINTEG += left(FORN->End_cob,40) + space(12) + FORN->Cep_cob + left(CGM->Municipio,15) + CGM->Estado + space(40) + space(2)

      cINTEG += " " + strzero(nSEQ,6)

      INTEGRA->(qappend())
      INTEGRA->Linha := cINTEG
      cINTEG := ""

      PAGAR->(dbskip())

   enddo

   // MONTA REGISTRO TIPO 9 (TRAILLER) ______________________________________

   nSEQ++

   cINTEG := "9" + space(393) + strzero(nSEQ,6)

   INTEGRA->(qappend())
   INTEGRA->Linha := cINTEG
   cINTEG := ""

   qmensa("Aguarde...Gravando arquivo...","B")

   cNOMARQ := alltrim(BANCO->Caminho) + "ARQ01.TXT"

   INTEGRA->(dbgotop())

   INTEGRA->(__dbSDF( .T., CNOMARQ , { } ,,,,, .F. ) )

   select PAGAR
   PAGAR->(dbgotop())

return

///////////////////////////////////////////////////////////////////////////////////////
function i_calc_dig

   local nCONT := 1
   local nVAR  := 2
   local nDIG1 := 0
   local nSOMA := 0

   for nCONT := 15 to 1 step -1

       if nVAR = 10
          nVAR := 2
       endif

       nSOMA := nSOMA + val(substr(nNUMERO,nCONT,1)) * nVAR
       nVAR++

   next

   nDIG1 := mod((nSOMA * 10),11)
   nDIG1 := alltrim(str(nDIG1))

   nNUMERO := nNUMERO + left(nDIG1,1)

   // inicializa as variaveis controladoras

   nCONT := 1
   nVAR  := 2
   nSOMA := 0

   for nCONT := 16 to 1 step -1

       if nVAR = 10
          nVAR := 2
       endif

       nSOMA := nSOMA + val(substr(nNUMERO,nCONT,1)) * nVAR
       nVAR++

   next

   nDIG2 := mod((nSOMA * 10),11)
   nDIG2 := alltrim(str(nDIG2))

   nCALCULO := str(nN_NUM,6) + left(nDIG1,1) + left(nDIG2,1)

return

///////////////////////////////////////////////////////////////////////////////////////
//
function i_calc

   local nCONT := 1
   local nVAR  := 9
   local nDIG1 := 0
   local nSOMA := 0

   for nCONT := 9 to 1 step -1

       if nVAR = 5
          nVAR := 9
       endif

       nSOMA := nSOMA + val(substr(str(nBANES,9),nCONT,1)) * nVAR
       nVAR--

   next

   nDIG1 := mod((nSOMA),11)
   nDIG1 := alltrim(str(nDIG1))

   if left(nDIG1,2) == "10"
      nBANES += 1
      i_calc()
   endif

   nCALCULO := strzero(val(transform(nBANES, "@R 999999999")),9) + left(nDIG1,1)

return

//////////////////////////////////////////////////////////////////
// calculo do digito do nosso numero do banco de credito nacional
function i_noss_num

   local nCONT := 1
   local nVAR  := 8
   local nDIG1 := 0
   local nSOMA := 0

   for nCONT := 1 to 7 

       if nVAR = 1
          nVAR := 8
       endif

       nSOMA := nSOMA + val(substr(nNUMERO,nCONT,1)) * (nVAR*10)
       nVAR--

   next

   nDIG1 := mod((nSOMA),11)
   nDIG1 := alltrim(str(nDIG1))

   if nDIG1 == "10"
      nDIG1 := 0
   endif

   nCALCULO := strzero(val(transform(nNUMERO, "@R 9999999")),7) + left(nDIG1,1)

return


/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A MARCACAO PARA LIBERACAO ______________________________

static function i_marca
   if PAGAR->(qrlock())
      if PAGAR->Marcar == "*"
         replace PAGAR->Marcar with " "
      else
         replace PAGAR->Marcar with "*"
      endif
   endif
return

//////////////////////////////////////////////////////////////////////////////
// TIPO 1 OU 2 INVERTE VARIAVEL CARACTER ANO,MES,DIA PARA VARIAVEL DATA     DIA,MES,ANO  (ANDRE)
// TIPO 3 OU 4 INVERTE VARIAVEL DATA     DIA,MES,ANO PARA VARIAVEL CARACTER ANO,MES,DIA
// TIPO 5 OU 6 INVERTE VARIAVEL CARACTER ANOMES PARA DIA 1,MES,ANO
// TIPO 1 = DIA MES ANO C/ 2 DIGITOS    (DATA)
// TIPO 2 = DIA MES ANO C/ 4 DIGITOS    (DATA)
// TIPO 3 = ANO/MES/DIA C/ 2 DIGITOS    (CARACTER)
// TIPO 4 = ANO/MES/DIA C/ 4 DIGITOS    (CARACTER)
// TIPO 5 = DIA=01 MES ANO C/ 2 DIGITOS (DATA)
// TIPO 6 = DIA=01 MES ANO C/ 4 DIGITOS (DATA)

static function qinvert(zPARM,zTIPO)  // PARAMETRO DO TIPO CARACTER ANO+MES+DIA, EX: '20000130' -- PARAMETRO PARA TIPO SECULO

 if zTIPO = 1 .or. zTIPO = 2
    if zTIPO = 1 ; zANO = substr(zPARM,3,2) ; endif
    if zTIPO = 2 ; zANO = substr(zPARM,1,4) ; endif
    zMES = substr(zPARM,5,2)
    zDIA = substr(zPARM,7,2)
    zDATA = zDIA + '/' + zMES + '/' + zANO
    zDATA = ctod(zDATA)
 endif

 if zTIPO = 3 .or. zTIPO = 4 
    if zTIPO = 3 ; zANO = substr(zPARM,7,2) ; endif
    if zTIPO = 4 ; zANO = substr(zPARM,5,4) ; endif
    zDIA = substr(zPARM,1,2)
    zMES = substr(zPARM,3,2)
    zDATA = zANO + '/' + zMES + '/' + zDIA
 endif


 if zTIPO = 5 .or. zTIPO = 6 
    if zTIPO = 5 ; zANO = substr(zPARM,3,2) ; endif
    if zTIPO = 6 ; zANO = substr(zPARM,1,4) ; endif
    zDIA = '01'
    zMES = substr(zPARM,5,2)
    zDATA = zDIA + '/' + zMES + '/' + zANO
    zDATA = ctod(zDATA)
 endif

 if zTIPO = 7 .or. zTIPO = 8     //  PASSAR PARAMETRO COMO DATA
    zPARM = dtoc(zPARM)
    if zTIPO = 7 ; zANO = substr(zPARM,7,4) ; endif
    if zTIPO = 8 ; zANO = substr(zPARM,9,2) ; endif
    zMES = substr(zPARM,4,2)
    zDIA = substr(zPARM,1,2)
    zDATA = zANO + zMES + zDIA
 endif

return zDATA         // RETORNA PARAMETRO FORNECIDO PARA TIPO DATA


