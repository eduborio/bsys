/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE CONTAS A RECEBER/PAGAR
// OBJETIVO...: INCLUSAO DE CONTAS A RECEBER
// ANALISTA...: EDUARDO BORIO
// PROGRAMADOR: EDUARDO BORIO
// INICIO.....: NOVEMBRO DE 1996
// OBS........:
// ALTERACOES.:

function rb201

#include "inkey.ch"
#include "setcurs.ch"

//fu_abre_cli1()
//fu_abre_conta()
//fu_abre_prov()

CCUSTO->(Dbsetorder(4))
BANCO->(dbsetorder(3))

private lCONF1
private lCONF2
private cDESC
public nVAL_LIQ
private cDATA_ATU := date()
private sBLOC1  := qlbloc("B201D","QBLOC.GLO")

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

private dDATA_VENC := ctod("")

// VIEW INICIAL _____________________________________________________________
//RECEBER->(dbsetfilter({|| RECEBER->Setor}))
RECEBER->(qview({{"Data_venc/Vcto"            ,2},;
                 {"Data_emiss/Emissao"        ,4},;
                 {"left(RECEBER->Cliente,22)/Cliente",8},;
                 {"transform(RECEBER->Valor_liq,'@E 999,999.99')/Valor Liq."       ,6},;
                 {"Fatura/Documento"          ,11},;
                 {"f201bank()/Banco"           ,0}},"P",;
                 {NIL,"f201a",NIL,NIL},;
                 NIL,"<D>esdobra/<P>arcial/Pesqui<S>a Valor"))

//////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAGEM DO CLIENTE __________________________________________

function f_201b
   CLI1->(dbseek(RECEBER->Cod_cli))
return left(CLI1->Razao,22)

function f201bank
local cRet := "    "
   if BANCO->(dbseek(RECEBER->Cod_Banco))
      cRet := rtrim(BANCO->Banco)

      if cRet == "0356"
         cRET := "REAL"
      endif
	  
	  if cRet == "0033"
         cRET := "SANT"
      endif

      if cRet == "0001"
         cRET := "BB"
      endif
	  
	  if cRet == "0341"
         cRET := "ITAU"
      endif
	  
	  if cRet == "0399"
         cRET := "HSBC"
      endif
	  
	  if cRet == "0246"
         cRET := "ABC"
      endif
   else
      cRet := "    "
   endif

return cRet


//////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAGEM DE VALOR COM PICTURE ________________________________

function f_val3
return(transform(RECEBER->Valor,"@E 9999999.99"))

//////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAGEM DE VALOR COM PICTURE ________________________________

function f_val4
return(transform(RECEBER->Valor_liq,"@E 9999999.99"))

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function f201a
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO $ XUSRA
      iif(empty(CONFIG->Remoplast),qlbloc(05,02,"B201A","QBLOC.GLO",1),qlbloc(05,02,"B201R","QBLOC.GLO",1))
      qmensa(qabrev(cOPCAO,"IA",{"Inclus„o... <ESC - Cancela>","Altera‡„o... <ESC - Cancela>"}))
      i_edicao()
   endif

   if cOPCAO = "D" ; i_duplica() ; endif
   if cOPCAO = "S" ; i_pesq_nota() ; endif
   if cOPCAO = "P" ; i_parcial() ; endif
   if cOPCAO = "T" ; i_transf() ; endif
   if cOPCAO == "M" ; i_marca()  ; return ; endif
   if cOPCAO == "G" ; i_agrupa()  ; return ; endif


   setcursor(nCURSOR)
return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA ____________________________________

static function i_edicao
   local aEDICAO := {}
   local bESCAPE := {||empty(fDATA_LANC).or.(XNIVEL==1.and.!XFLAG).or.!empty(fDATA_LANC).and.Lastkey()==27.and.XNIVEL==2.or.;
                         (XNIVEL==2.and.cOPCAO=="A".and.!XFLAG)}

   fDATA_LANC := XDATASYS

   // MONTA DADOS NA TELA ___________________________________________________

   if ! cOPCAO $ "I"
      XNIVEL := 1
      qrsay ( XNIVEL++ , RECEBER->Codigo       )
      qrsay ( XNIVEL++ , RECEBER->Data_lanc    )
      qrsay ( XNIVEL++ , qabrev(RECEBER->Previsao,"SN", {"Sim","N„o"}))
      qrsay ( XNIVEL++ , RECEBER->Cod_cli      ) ; CLI1->(dbseek(RECEBER->Cod_cli))
      qrsay ( XNIVEL++ , left(CLI1->Razao,40))

      if empty(CONFIG->Remoplast)
         qrsay ( XNIVEL++ , RECEBER->Centro       ) ; CCUSTO->(dbseek(RECEBER->Centro))
         qrsay ( XNIVEL++ , left(CCUSTO->Descricao,40))
         qrsay ( XNIVEL++ , RECEBER->Filial       ) ; FILIAL->(dbseek(RECEBER->Filial))
         qrsay ( XNIVEL++ , left(FILIAL->Razao,40))
      endif

      qrsay ( XNIVEL++ , RECEBER->Data_emiss   )
      qrsay ( XNIVEL++ , RECEBER->Setor    ) ; SETOR->(dbseek(RECEBER->Setor))
      qrsay ( XNIVEL++ , left(SETOR->Descricao,25))

      if empty(CONFIG->Remoplast)
         qrsay ( XNIVEL++ , RECEBER->Especie      ) ; ESPECIE->(dbseek(RECEBER->Especie))
         qrsay ( XNIVEL++ , left(ESPECIE->Descricao,13))
         qrsay ( XNIVEL++ , RECEBER->Serie        ) ; SERIE->(dbseek(RECEBER->Serie))
         qrsay ( XNIVEL++ , left(SERIE->Descricao,11))
         qrsay ( XNIVEL++ , RECEBER->Tipo_sub     ) ; TIPOCONT->(dbseek(RECEBER->Tipo_sub) )
         qrsay ( XNIVEL++ , left(TIPOCONT->Descricao,46))
      endif

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

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || NIL }                                         ,NIL         })  // codigo nao pode ser editado
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDATA_LANC                    ) } ,"DATA_LANC" })
   aadd(aEDICAO,{{ || qesco(-1,0,@fPREVISAO,sBLOC1              )} ,"PREVISAO"   })
   aadd(aEDICAO,{{ || view_cli(-1,0,@fCOD_CLI                 ) } ,"COD_CLI"     })
   aadd(aEDICAO,{{ || NIL                                         } ,NIL         })
   if empty(CONFIG->Remoplast)
      aadd(aEDICAO,{{ || view_ccusto(-1,0,@fCENTRO                ) } ,"CENTRO"     })
      aadd(aEDICAO,{{ || NIL                                         } ,NIL         })
      aadd(aEDICAO,{{ || view_filial(-1,0,@fFILIAL                 ) } ,"FILIAL"    })
      aadd(aEDICAO,{{ || NIL                                         } ,NIL         })
   endif
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDATA_EMISS                   ) } ,"DATA_EMISS"})
   aadd(aEDICAO,{{ || view_set(-1,0,@fSETOR                   ) } ,"SETOR"     })
   aadd(aEDICAO,{{ || NIL                                         } ,NIL         })
   if empty(CONFIG->Remoplast)
      aadd(aEDICAO,{{ || view_especie(-1,0,@fESPECIE               ) } ,"ESPECIE"   })
      aadd(aEDICAO,{{ || NIL                                         } ,NIL         })
      aadd(aEDICAO,{{ || view_serie(-1,0,@fSERIE                   ) } ,"SERIE"     })
      aadd(aEDICAO,{{ || NIL                                         } ,NIL         })
      aadd(aEDICAO,{{ || view_tipo(-1,0,@fTIPO_SUB                 ) } ,"TIPO_SUB"  })
      aadd(aEDICAO,{{ || NIL                                         } ,NIL         })
   endif
   aadd(aEDICAO,{{ || qgetx(-1,0,@fHISTORICO,"@!@S60"           ) } ,"HISTORICO" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDATA_VENC                    ) } ,"DATA_VENC" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDATA_PRORR                   ) } ,"DATA_PRORR"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@fVALOR    ,"@E 9,999,999.99"  ) } ,"VALOR"     })
   aadd(aEDICAO,{{ || view_doc(-1,0,@fTIPO_DOC                  ) } ,"TIPO_DOC"  })
   aadd(aEDICAO,{{ || NIL                                         } ,NIL         })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fFATURA,"@!"                  ) } ,"FATURA"    })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDUPLICATA,"@!"               ) } ,"DUPLICATA"})
   aadd(aEDICAO,{{ || view_cgm(-1,0,@fCGM                     ) } ,"CGM"     })
   aadd(aEDICAO,{{ || NIL                                         } ,NIL         })
   aadd(aEDICAO,{{ || view_banco(-1,0,@fCOD_BANCO               ) } ,"COD_BANCO" })
   aadd(aEDICAO,{{ || NIL                                         } ,NIL         })
   aadd(aEDICAO,{{ || view_situa(-1,0,@fSITUACAO                ) } ,"SITUACAO"  })
   aadd(aEDICAO,{{ || NIL                                         } ,NIL         })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDATA_CONT                   ) } ,"DATA_CONT"})
   aadd(aEDICAO,{{ || view_fun(-1,0,@fVENDEDOR                   ) } ,"VENDEDOR"   })
   aadd(aEDICAO,{{ || NIL                                         } ,NIL         })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fOBSERVACAO,"@!@S59"          ) } ,"OBSERVACAO"})

   aadd(aEDICAO,{{ || lCONF1 := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" de Lan‡amentos Complementares ?") },"COMPLEM"})
   aadd(aEDICAO,{{ || lCONF2 := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   RECEBER->(qpublicfields())
   iif(cOPCAO=="I",RECEBER->(qinitfields()),RECEBER->(qcopyfields()))

   XNIVEL := 2
   XFLAG  := .T.
   lCONF1 := .F.
   lCONF2 := .F.
   if cOPCAO == "I"
      fDATA_LANC := date()
   endif
   if cOPCAO == "I"
      fCODIGO := strzero(CONFIG->Cod_rec + 1,7)
   endif

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; RECEBER->(qreleasefields()) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF2 ; return ; endif

   fVALOR_LIQ := nVAL_LIQ

   if RECEBER->(iif(cOPCAO=="I",qappend(),qrlock()))
      RECEBER->(qreplacefields())
      replace RECEBER->Cliente with fCLIENTE
      RECEBER->(qunlock())
      if RECEBER->Contabil == .F. .and. RECEBER->Previsao == "N"
         i_contabil()
      endif
   else
      iif(cOPCAO=="I",qm1(),qm2())
   endif

   if CONFIG->(qrlock())
      replace CONFIG->Cod_rec with val(fCODIGO)
   endif

return

/////////////////////////////////////////////////////////////////////////////
// CRITICAS NA DESCIDA ______________________________________________________

static function i_critica ( cCAMPO )
   iif ( cCAMPO == NIL , cCAMPO := "" , NIL )
   do case
      case cCAMPO == "CODIGO" .and. cOPCAO == "I"
           fCODIGO := strzero(val(fCODIGO),7)
           qrsay(XNIVEL,fCODIGO)
           if RECEBER->(dbseek(fCODIGO))
              qmensa("Tipo de Documento j  cadastrado !","B")
              return .F.
           endif

      case cCAMPO == "PREVISAO"
           if empty(fPREVISAO) ; return .F. ; endif
           qrsay(XNIVEL,qabrev(fPREVISAO,"SN",{"Sim","N„o"}))

      case cCAMPO == "COD_CLI"
           qrsay(XNIVEL,fCOD_CLI:=strzero(val(fCOD_CLI),5))
           if ! CLI1->(dbseek(fCOD_CLI))
              qmensa("Cliente n„o Cadastrado !","B")
              return .F.
           else
              qrsay(XNIVEL+1,left(CLI1->Razao,40))
              if empty(CLI1->Conta_cont)
                 qmensa("Aten‡„o !! Conta Cont bil n„o Informada!","B")
              endif
           endif
           fCLIENTE := CLI1->Razao

      case cCAMPO == "CENTRO"
           qrsay(XNIVEL,fCENTRO:=strzero(val(fCENTRO),4))
           if ! CCUSTO->(dbseek(fCENTRO))
              qmensa("Centro de Custo n„o Cadastrado !","B")
              return .F.
           else
              qrsay(XNIVEL+1,left(CCUSTO->Descricao,40))

           endif

      case cCAMPO == "SETOR"
           qrsay(XNIVEL,iif(!empty(fSETOR),fSETOR:=strzero(val(fSETOR),5),"") )
           if ! SETOR->(dbseek(fSETOR))
              qmensa("Setor n„o Cadastrado !","B")
              //return .F.
              qmensa("")
           else
              qrsay(XNIVEL+1,left(SETOR->Descricao,25))

           endif

      case cCAMPO == "FILIAL"
           qrsay(XNIVEL,fFILIAL:=strzero(val(fFILIAL),4))
           if ! FILIAL->(dbseek(fFILIAL))
              qmensa("Filial n„o Cadastrada !","B")
              return .F.
           else
              qrsay(XNIVEL+1,left(FILIAL->Razao,40))
           endif

      case cCAMPO == "DATA_EMISS"
           if empty(fDATA_EMISS) ; return .F. ; endif
           fDATA_CONT := fDATA_EMISS

      case cCAMPO == "DATA_CONT"
           if empty(fDATA_CONT)
              qmensa("Data Cont bil ‚ obrigat¢ria ...","B")
              fDATA_CONT := fDATA_EMISS
              return .F.
           endif
           qmensa("")

      case cCAMPO == "TIPO_SUB"
           if empty(fTIPO_SUB) ; return .F. ; endif
           qrsay(XNIVEL,fTIPO_SUB:=strzero(val(fTIPO_SUB),6))
           if ! TIPOCONT->(dbseek(fTIPO_SUB))
              qmensa("Tipo e Sub-Tipo n„o encontrado !","B")
              return .F.
           endif
           if ! TIPOCONT->Motivo $ "13"
              qmensa("Este Tipo Cont bil n„o ‚ de Recebimento...","B")
              return .F.
           endif
           qrsay(XNIVEL+1,left(TIPOCONT->Descricao,46))
           //if cOPCAO == "I"
           //   fHISTORICO := rtrim(TIPOCONT->Descricao)
           //endif

      case cCAMPO == "VALOR"
           if empty(fVALOR) ; return .F. ; endif


      case cCAMPO == "FATURA"
           if empty(fFATURA) .and. TIPOCONT->Nota_fisc == "1"
              qmensa("Campo obrigat¢rio...","B")
              return .F.
           endif

      case cCAMPO == "SITUACAO"
           qrsay(XNIVEL,iif(!empty(fSITUACAO),fSITUACAO:=strzero(val(fSITUACAO),2),""))
           if ! SITUA->(dbseek(fSITUACAO))
              qmensa("Situacao n„o Cadastrada !","B")
              //return .F.
              qmensa("")
           else
              qrsay(XNIVEL+1,left(SITUA->Descricao,28))
           endif

      case cCAMPO == "CGM"
           qrsay(XNIVEL,iif(!empty(fCGM),fCGM:=strzero(val(fCGM),6),""))
           if ! CGM->(dbseek(fCGM))
              qmensa("Praca n„o Cadastrada !","B")
              //return .F.
              qmensa("")
           else
              qrsay(XNIVEL+1,left(CGM->Municipio,40))
           endif

      case cCAMPO == "ESPECIE"
           qrsay(XNIVEL,fESPECIE := strzero(val(fESPECIE),2))
           if ! ESPECIE->(dbseek(fESPECIE))
              qmensa("Esp‚cie Inv lida !","B")
              return .F.
           else
              qrsay(XNIVEL+1,left(ESPECIE->Descricao,11))
           endif

      case cCAMPO == "TIPO_DOC"
           qrsay(XNIVEL,fTIPO_DOC := strzero(val(fTIPO_DOC),2))
           if ! TIPO_DOC->(dbseek(fTIPO_DOC))
              qmensa("Tipo de Documento inv lido !","B")
              return .F.
           else
              qrsay(XNIVEL+1,TIPO_DOC->Descricao)
           endif

      case cCAMPO == "SERIE"
           if empty(fSERIE) ; return .T. ; endif

           qrsay(XNIVEL,fSERIE := strzero(val(fSERIE),2))
           if ! SERIE->(dbseek(fSERIE))
              qmensa("S‚rie Inv lida !","B")
              return .F.
           else
              qrsay(XNIVEL+1,left(SERIE->Descricao,11))
           endif

      case cCAMPO == "DATA_VENC"

           if fDATA_VENC < fDATA_LANC
              qmensa("Data do Vencimento Inferior a do Lan‡amento !","B")
              return .F.
           endif

      case cCAMPO == "COD_BANCO"

           if ! empty(fCOD_BANCO)
              qrsay(XNIVEL,iif(!empty(fCOD_BANCO),fCOD_BANCO:=strzero(val(fCOD_BANCO),5),"") )
              if ! BANCO->(dbseek(fCOD_BANCO))
                 qmensa("Banco n„o Encontrado !","B")
                 //return .F.
                 qmensa("")
              else
                 qrsay(XNIVEL+1,BANCO->Descricao)
              endif
           endif

      case cCAMPO == "VENDEDOR"

           if ! empty(fVENDEDOR)
              qrsay(XNIVEL,fVENDEDOR:=strzero(val(fVENDEDOR),6))

              if ! FUN->(dbseek(fVENDEDOR))
                 qmensa("Vendedor n„o Cadastrado !","B")
                 return .F.
              else
                 qrsay(XNIVEL+1,left(FUN->Nome,40))
              endif
           endif

      case cCAMPO == "COMPLEM"
           if lCONF1
              i_tela_2()
              iif(empty(CONFIG->Remoplast),XNIVEL := 37,XNIVEL := 26)
           endif

   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXCLUIR CONTAS A RECEBER _______________________________________

static function i_exclusao

   if qconf("Confirma exclus„o desta Conta … Receber ?")

      //if SH_CONTA->(dbseek(RECEBER->Cod_cli + RECEBER->Fatura + RECEBER->Serie))
      //   if SH_CONTA->(qrlock())
      //      SH_CONTA->(dbdelete())
      //      SH_CONTA->(qunlock())
      //   endif
      //endif

      if RECEBER->(qrlock())
         RECEBER->(dbdelete())
         RECEBER->(qunlock())
      else
         qm3()
      endif

   endif
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA DESDOBRAMENTO DO LANCAMENTO DE CONTAS A RECEBER ________________

function i_desdobra

   local lCONF
   local aEDICAO := {}
   local bESCAPE := {||empty(dDATA_VENC).or.(XNIVEL==1.and.!XFLAG).or.;
                         (XNIVEL==1.and.!XFLAG)}

   private dDATA_VENC := ctod("")
   private nVALOR     := 0
   private nVAL_DES   := 0
   private lPRI_LANC  := .T.
   private nVAL_INI   := 0   // variavel para controle do valor dos desdobramentos

   nVAL_INI := RECEBER->Valor

   qlbloc(11,02,"B201B","QBLOC.GLO",1)

   do while .T.

      qsay ( 12,17 , RECEBER->Codigo       ) ; CLI1->(Dbseek(RECEBER->Cod_cli))
      qsay ( 13,17 , left(CLI1->Razao,40))
      qsay ( 15,22 , transform(RECEBER->Valor, "@E 9,999,999.99"))

      aadd(aEDICAO,{{ || qgetx(-1,0,@dDATA_VENC, "@D"              ) } ,"DATA_VENC" })
      aadd(aEDICAO,{{ || qgetx(-1,0,@nVALOR, "@E 9,999,999.99"     ) } ,"VALOR"     })

      aadd(aEDICAO,{{ || lCONF := qconf("Confirma Lan‡amento ?"    ) } ,NIL         })

      XNIVEL := 1
      XFLAG  := .T.

      do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
         eval ( aEDICAO [XNIVEL,1] )
         if eval ( bESCAPE ) ; return ; endif
         if ! i_crit_1( aEDICAO[XNIVEL,2] ) ; loop ; endif
         if ( XFLAG , XNIVEL++ , XNIVEL-- )
      enddo

      // GRAVACAO ______________________________________________________________

      if ! lCONF ; return ; endif

      if lPRI_LANC

         if RECEBER->(qrlock())
            replace RECEBER->Data_venc    with dDATA_VENC
            replace RECEBER->Valor        with nVALOR
         else
            iif(cOPCAO=="I",qm1(),qm2())
         endif

         RECEBER->(qunlock())

         lPRI_LANC := .F.

      else

         RECEBER->(qpublicfields())
         RECEBER->(qcopyfields())

         if CONFIG->(qrlock()) .and. RECEBER->(qflock()) .and. RECEBER->(qappend())

            replace CONFIG->Cod_rec with CONFIG->Cod_rec + 1

            fCODIGO    := strzero(CONFIG->Cod_rec,7)
            fDATA_VENC := dDATA_VENC
            fVALOR     := nVALOR

            RECEBER->(qreplacefields())

            qmensa("C¢digo Gerado: "+fCODIGO,"B")

         endif

      endif

      qsay ( 15,50 , transform(nVAL_DES, "@E 9,999,999.99"))

      if nVAL_DES = nVAL_INI
         exit
      endif

      dDATA_VENC := ctod("")
      nVALOR     := 0
      aEDICAO    := {}

   enddo

return
/////////////////////////////////////////////////////////////////////////////
// CRITICAS NA DESCIDA ______________________________________________________

static function i_crit_1 ( cCAMPO )

   do case

      case cCAMPO == "DATA_VENC"

           if dDATA_VENC < RECEBER->Data_venc
              qmensa("Data do Vencimento deve ser Superior !","B")
              return .F.
           endif

      case cCAMPO == "VALOR"

           if empty(nVALOR) ; return .F. ; endif

           nVAL_DES := nVAL_DES + nVALOR

           if nVAL_DES > nVAL_INI
              qmensa("Valor do desdobramento superou o valor do pagamento !", "B")
              nVAL_DES := nVAL_DES - nVALOR
              return .F.
           endif

   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA DESDOBRAMENTO DO LANCAMENTO DE CONTAS A RECEBER ________________

function i_parcial

   local lCONF
   local aEDICAO := {}
   local bESCAPE := {||empty(dDATA_VENC).or.(XNIVEL==1.and.!XFLAG).or.;
                         (XNIVEL==1.and.!XFLAG)}

   private dDATA_VENC := ctod("")
   private nVALOR     := 0
   private nVAL_DES   := 0
   private lPRI_LANC  := .T.
   private nVAL_INI   := 0   // variavel para controle do valor dos desdobramentos

   nVAL_INI := RECEBER->Valor

   qlbloc(11,02,"B201E","QBLOC.GLO",1)

  // do while .T.

      qsay ( 12,17 , RECEBER->Codigo       ) ; CLI1->(Dbseek(RECEBER->Cod_cli))
      qsay ( 13,17 , left(CLI1->Razao,40))

      aadd(aEDICAO,{{ || qgetx(-1,0,@dDATA_VENC, "@D"              ) } ,"DATA_VENC" })
      aadd(aEDICAO,{{ || qgetx(-1,0,@nVALOR, "@E 9,999,999.99"     ) } ,"VALOR"     })

      aadd(aEDICAO,{{ || lCONF := qconf("Confirma Lan‡amento ?"    ) } ,NIL         })

      XNIVEL := 1
      XFLAG  := .T.

      do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
         eval ( aEDICAO [XNIVEL,1] )
         if eval ( bESCAPE ) ; return ; endif
         if ! i_crit_2( aEDICAO[XNIVEL,2] ) ; loop ; endif
         if ( XFLAG , XNIVEL++ , XNIVEL-- )
      enddo

      // GRAVACAO ______________________________________________________________

      if ! lCONF ; return ; endif


      if RECEBER->(qrlock())
         replace RECEBER->Valor_liq    with (RECEBER->Valor - nVALOR)
         replace RECEBER->Valor        with (RECEBER->Valor - nVALOR)
      else
         iif(cOPCAO=="I",qm1(),qm2())
      endif

      RECEBER->(qunlock())


      RECEBER->(qpublicfields())
      RECEBER->(qcopyfields())

      if CONFIG->(qrlock()) .and. RECEBER->(qflock()) .and. RECEBER->(qappend())

         replace CONFIG->Cod_rec with CONFIG->Cod_rec + 1

         fCODIGO    := strzero(CONFIG->Cod_rec,7)
         fDATA_VENC := dDATA_VENC
         fVALOR     := nVALOR
         fVALOR_LIQ := nVALOR
         RECEBER->(qreplacefields())

         qmensa("C¢digo Gerado: "+fCODIGO,"B")

      endif

      dDATA_VENC := ctod("")
      nVALOR     := 0
      aEDICAO    := {}


return
/////////////////////////////////////////////////////////////////////////////
// CRITICAS NA DESCIDA ______________________________________________________

static function i_crit_2 ( cCAMPO )

   do case

      case cCAMPO == "DATA_VENC"

           if dDATA_VENC < RECEBER->Data_venc
              qmensa("Data do Vencimento deve ser Superior !","B")
              return .F.
           endif

      case cCAMPO == "VALOR"

           if empty(nVALOR) ; return .F. ; endif

           nVAL_DES := nVAL_DES + nVALOR

           if nVAL_DES > nVAL_INI
              qmensa("Valor Parcial superou o valor do pagamento !", "B")
              nVAL_DES := nVAL_DES - nVALOR
              return .F.
           endif

   endcase

return .T.

function i_duplica

   local lCONF
   local aEDICAO := {}
   local bESCAPE := {||empty(dDATA_VENC).or.(XNIVEL==1.and.!XFLAG).or.;
                         (XNIVEL==1.and.!XFLAG)}

   private dDATA_VENC := ctod("")
   private nVALOR     := 0
   private nVAL_DES   := 0
   private cHIST      := space(30)
   private cFATURA    := space(8)
   private lPRI_LANC  := .T.
   private nVAL_INI   := 0   // variavel para controle do valor dos desdobramentos

   nVAL_INI := RECEBER->Valor

   qlbloc(11,02,"B201E","QBLOC.GLO",1)

  // do while .T.

      qsay ( 12,17 , RECEBER->Codigo       ) ; CLI1->(Dbseek(RECEBER->Cod_cli))
      qsay ( 13,17 , left(CLI1->Razao,40))

      aadd(aEDICAO,{{ || qgetx(-1,0,@dDATA_VENC, "@D"              ) } ,"DATA_VENC" })
      aadd(aEDICAO,{{ || qgetx(-1,0,@nVALOR, "@E 9,999,999.99"     ) } ,"VALOR"     })
      aadd(aEDICAO,{{ || qgetx(-1,0,@cHIST, "@!"              ) } ,"HISTORICO"     })
      aadd(aEDICAO,{{ || qgetx(-1,0,@cFATURA, "@!"                 ) } ,"FATURA"     })

      aadd(aEDICAO,{{ || lCONF := qconf("Confirma Lan‡amento ?"    ) } ,NIL         })

      XNIVEL := 1
      XFLAG  := .T.

      do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
         eval ( aEDICAO [XNIVEL,1] )
         if eval ( bESCAPE ) ; return ; endif
         if ! i_crit_3( aEDICAO[XNIVEL,2] ) ; loop ; endif
         if ( XFLAG , XNIVEL++ , XNIVEL-- )
      enddo

      // GRAVACAO ______________________________________________________________

      if ! lCONF ; return ; endif


      //if RECEBER->(qrlock())
      //   replace RECEBER->Valor_liq    with (RECEBER->Valor - nVALOR)
      //   replace RECEBER->Valor        with (RECEBER->Valor - nVALOR)
      //else
      //   iif(cOPCAO=="I",qm1(),qm2())
      //endif

      RECEBER->(qunlock())


      RECEBER->(qpublicfields())
      RECEBER->(qcopyfields())

      if CONFIG->(qrlock()) .and. RECEBER->(qflock()) .and. RECEBER->(qappend())

         replace CONFIG->Cod_rec with CONFIG->Cod_rec + 1

         fCODIGO    := strzero(CONFIG->Cod_rec,7)
         fDATA_VENC := dDATA_VENC
         fVALOR     := nVALOR
         fVALOR_LIQ := nVALOR
         fHISTORICO := cHIST
         fFATURA    := cFATURA
         fDUPLICATA := cFATURA
         RECEBER->(qreplacefields())

         qmensa("C¢digo Gerado: "+fCODIGO,"B")

      endif

      dDATA_VENC := ctod("")
      nVALOR     := 0
      aEDICAO    := {}


return
/////////////////////////////////////////////////////////////////////////////
// CRITICAS NA DESCIDA ______________________________________________________

static function i_crit_3 ( cCAMPO )

   do case

      case cCAMPO == "VALOR"

           if empty(nVALOR) ; return .F. ; endif


   endcase

return .T.

static function i_agrupa

   local lCONF
   local aEDICAO := {}
   local bESCAPE := {||empty(dDATA_VENC).or.(XNIVEL==1.and.!XFLAG).or.;
                         (XNIVEL==1.and.!XFLAG)}

   private dDATA_VENC := ctod("")
   private nVALOR     := 0
   private nVAL_DES   := 0
   private cHIST      := space(30)
   private cFATURA    := space(8)
   private lPRI_LANC  := .T.
   private nVAL_INI   := 0   // variavel para controle do valor dos desdobramentos

   nVAL_INI := 0


   RECEBER->(Dbsetfilter({|| RECEBER->Agrupa == "*" }))
   RECEBER->(Dbgotop())

   do while ! RECEBER->(Eof())
      nVALOR += RECEBER->Valor_liq
      cHIST  := rtrim(cHIST)+" "+rtrim(RECEBER->Fatura)+"/"
      RECEBER->(Dbskip())
   enddo

   RECEBER->(Dbgotop())


   qlbloc(11,02,"B201E","QBLOC.GLO",1)

  // do while .T.

      qsay ( 12,17 , RECEBER->Codigo       ) ; CLI1->(Dbseek(RECEBER->Cod_cli))
      qsay ( 13,17 , left(CLI1->Razao,40))

      aadd(aEDICAO,{{ || qgetx(-1,0,@dDATA_VENC, "@D"              ) } ,"DATA_VENC" })
      aadd(aEDICAO,{{ || qgetx(-1,0,@nVALOR, "@E 9,999,999.99"     ) } ,"VALOR"     })
      aadd(aEDICAO,{{ || qgetx(-1,0,@cHIST, "@!"              ) } ,"HISTORICO"     })
      aadd(aEDICAO,{{ || qgetx(-1,0,@cFATURA, "@!"                 ) } ,"FATURA"     })

      aadd(aEDICAO,{{ || lCONF := qconf("Confirma Lan‡amento ?"    ) } ,NIL         })

      XNIVEL := 1
      XFLAG  := .T.

      do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
         eval ( aEDICAO [XNIVEL,1] )
         if eval ( bESCAPE ) ; return ; endif
         if ! i_crit_4( aEDICAO[XNIVEL,2] ) ; loop ; endif
         if ( XFLAG , XNIVEL++ , XNIVEL-- )
      enddo

      // GRAVACAO ______________________________________________________________

      if ! lCONF ; return ; endif


     // RECEBER->(qunlock())


      RECEBER->(qpublicfields())
      RECEBER->(qcopyfields())

      if CONFIG->(qrlock()) .and. RECEBER->(qflock()) .and. RECEBER->(qappend())

         replace CONFIG->Cod_rec with CONFIG->Cod_rec + 1

         fCODIGO    := strzero(CONFIG->Cod_rec,7)
         fDATA_VENC := dDATA_VENC
         fVALOR     := nVALOR
         fVALOR_LIQ := nVALOR
         fAGRUPA    := " "
         fHISTORICO := cHIST
         fFATURA    := cFATURA
         fDUPLICATA := cFATURA
         RECEBER->(qreplacefields())

         qmensa("C¢digo Gerado: "+fCODIGO,"B")

      endif

      i_del_transf()

      dDATA_VENC := ctod("")
      nVALOR     := 0
      aEDICAO    := {}


return
/////////////////////////////////////////////////////////////////////////////
// CRITICAS NA DESCIDA ______________________________________________________

static function i_crit_4 ( cCAMPO )

   do case

      case cCAMPO == "VALOR"

           if empty(nVALOR) ; return .F. ; endif

   endcase

return .T.



/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA ____________________________________

static function i_tela_2

   local aEDICAO2 := {}

   private nNIVEL

   XNIVEL := nNIVEL

   // MONTA DADOS NA TELA ___________________________________________________

   qlbloc(05,02,"B201C","QBLOC.GLO",1)

   TIPOCONT->(dbseek(fTIPO_SUB))

   if ! empty(TIPOCONT->Hi_comp1)
      HIST->(dbseek(TIPOCONT->Hi_comp1))
      cDESC_1 := left(HIST->Descricao,41)
   else
      cDESC_1 := TIPOCONT->Hi_comp1
   endif

   if ! empty(TIPOCONT->Hi_comp2)
      HIST->(dbseek(TIPOCONT->hi_comp2))
      cDESC_2 := left(HIST->Descricao,41)
   else
      cDESC_2 := TIPOCONT->hi_comp2
   endif

   if ! empty(TIPOCONT->Hi_comp3)
      HIST->(dbseek(TIPOCONT->hi_comp3))
      cDESC_3 := left(HIST->Descricao,41)
   else
      cDESC_3 := TIPOCONT->hi_comp3
   endif

   if ! empty(TIPOCONT->Hi_comp4)
      HIST->(dbseek(TIPOCONT->hi_comp4))
      cDESC_4 := left(HIST->Descricao,41)
   else
      cDESC_4 := TIPOCONT->hi_comp4
   endif

   if ! empty(TIPOCONT->Hi_comp5)
      HIST->(dbseek(TIPOCONT->hi_comp5))
      cDESC_5 := left(HIST->Descricao,41)
   else
      cDESC_5 := TIPOCONT->hi_comp5
   endif

   if ! empty(TIPOCONT->Hi_comp6)
      HIST->(dbseek(TIPOCONT->hi_comp6))
      cDESC_6 := left(HIST->Descricao,41)
   else
      cDESC_6 := TIPOCONT->hi_comp6
   endif

   if ! empty(TIPOCONT->Hi_comp7)
      HIST->(dbseek(TIPOCONT->hi_comp7))
      cDESC_7 := left(HIST->Descricao,41)
   else
      cDESC_7 := TIPOCONT->hi_comp7
   endif

   if ! empty(TIPOCONT->Hi_comp8)
      HIST->(dbseek(TIPOCONT->hi_comp8))
      cDESC_8 := left(HIST->Descricao,41)
   else
      cDESC_8 := TIPOCONT->hi_comp8
   endif

   if ! empty(TIPOCONT->Hi_comp9)
      HIST->(dbseek(TIPOCONT->hi_comp9))
      cDESC_9 := left(HIST->Descricao,41)
   else
      cDESC_9 := TIPOCONT->hi_comp9
   endif

   if ! empty(TIPOCONT->Hi_comp10)
      HIST->(dbseek(TIPOCONT->hi_comp10))
      cDESC_10 := left(HIST->Descricao,41)
   else
      cDESC_10 := TIPOCONT->hi_comp10
   endif

   if ! empty(TIPOCONT->Hi_comp11)
      HIST->(dbseek(TIPOCONT->hi_comp11))
      cDESC_11 := left(HIST->Descricao,41)
   else
      cDESC_11 := TIPOCONT->hi_comp11
   endif

   if ! empty(TIPOCONT->Hi_comp12)
      HIST->(dbseek(TIPOCONT->hi_comp12))
      cDESC_12 := left(HIST->Descricao,41)
   else
      cDESC_12 := TIPOCONT->hi_comp12
   endif

   if ! empty(TIPOCONT->Hi_comp13)
      HIST->(dbseek(TIPOCONT->hi_comp13))
      cDESC_13 := left(HIST->Descricao,41)
   else
      cDESC_13 := TIPOCONT->hi_comp13
   endif

   qsay  ( 8 ,15, cDESC_1 )
   qsay  ( 9 ,15, cDESC_2 )
   qsay  ( 10,15, cDESC_3 )
   qsay  ( 11,15, cDESC_4 )
   qsay  ( 12,15, cDESC_5 )
   qsay  ( 13,15, cDESC_6 )
   qsay  ( 14,15, cDESC_7 )
   qsay  ( 15,15, cDESC_8 )
   qsay  ( 16,15, cDESC_9 )
   qsay  ( 17,15, cDESC_10 )
   qsay  ( 18,15, cDESC_11 )
   qsay  ( 19,15, cDESC_12 )
   qsay  ( 20,15, cDESC_13 )

   if cOPCAO <> "I"
      nNIVEL := 1
      qrsay ( nNIVEL++ , RECEBER->Valor_1  , "@E 9,999,999.99" )
      qrsay ( nNIVEL++ , RECEBER->Valor_2  , "@E 9,999,999.99" )
      qrsay ( nNIVEL++ , RECEBER->Valor_3  , "@E 9,999,999.99" )
      qrsay ( nNIVEL++ , RECEBER->Valor_4  , "@E 9,999,999.99" )
      qrsay ( nNIVEL++ , RECEBER->Valor_5  , "@E 9,999,999.99" )
      qrsay ( nNIVEL++ , RECEBER->Valor_6  , "@E 9,999,999.99" )
      qrsay ( nNIVEL++ , RECEBER->Valor_7  , "@E 9,999,999.99" )
      qrsay ( nNIVEL++ , RECEBER->Valor_8  , "@E 9,999,999.99" )
      qrsay ( nNIVEL++ , RECEBER->Valor_9  , "@E 9,999,999.99" )
      qrsay ( nNIVEL++ , RECEBER->Valor_10 , "@E 9,999,999.99" )
      qrsay ( nNIVEL++ , RECEBER->Valor_11 , "@E 9,999,999.99" )
      qrsay ( nNIVEL++ , RECEBER->Valor_12 , "@E 9,999,999.99" )
      qrsay ( nNIVEL++ , RECEBER->Valor_13 , "@E 9,999,999.99" )
   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO2,{{ || qgetx(-1,0,@fVALOR_1 , "@E 9,999,999.99")},"VALOR_1"  })
   aadd(aEDICAO2,{{ || qgetx(-1,0,@fVALOR_2 , "@E 9,999,999.99")},"VALOR_2"  })
   aadd(aEDICAO2,{{ || qgetx(-1,0,@fVALOR_3 , "@E 9,999,999.99")},"VALOR_3"  })
   aadd(aEDICAO2,{{ || qgetx(-1,0,@fVALOR_4 , "@E 9,999,999.99")},"VALOR_4"  })
   aadd(aEDICAO2,{{ || qgetx(-1,0,@fVALOR_5 , "@E 9,999,999.99")},"VALOR_5"  })
   aadd(aEDICAO2,{{ || qgetx(-1,0,@fVALOR_6 , "@E 9,999,999.99")},"VALOR_6"  })
   aadd(aEDICAO2,{{ || qgetx(-1,0,@fVALOR_7 , "@E 9,999,999.99")},"VALOR_7"  })
   aadd(aEDICAO2,{{ || qgetx(-1,0,@fVALOR_8 , "@E 9,999,999.99")},"VALOR_8"  })
   aadd(aEDICAO2,{{ || qgetx(-1,0,@fVALOR_9 , "@E 9,999,999.99")},"VALOR_9"  })
   aadd(aEDICAO2,{{ || qgetx(-1,0,@fVALOR_10 , "@E 9,999,999.99")},"VALOR_10"})
   aadd(aEDICAO2,{{ || qgetx(-1,0,@fVALOR_11 , "@E 9,999,999.99")},"VALOR_11"})
   aadd(aEDICAO2,{{ || qgetx(-1,0,@fVALOR_12 , "@E 9,999,999.99")},"VALOR_12"})
   aadd(aEDICAO2,{{ || qgetx(-1,0,@fVALOR_13 , "@E 9,999,999.99")},"VALOR_13"})

   nNIVEL := 1
   XFLAG  := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while nNIVEL >= 1 .and. nNIVEL <= len(aEDICAO2)
      XNIVEL := nNIVEL
      eval ( aEDICAO2[nNIVEL,1] )
      if ! i_crit2( aEDICAO2[nNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , nNIVEL++ , nNIVEL-- )
   enddo

   nVAL_LIQ := fVALOR

   if TIPOCONT->Fu_comp1 $ "36"
      nVAL_LIQ := nVAL_LIQ + fVALOR_1
   endif
   if TIPOCONT->Fu_comp1 $ "127"
      nVAL_LIQ := nVAL_LIQ - fVALOR_1
   endif

   if TIPOCONT->Fu_comp2 $ "36"
      nVAL_LIQ := nVAL_LIQ + fVALOR_2
   endif
   if TIPOCONT->Fu_comp2 $ "127"
      nVAL_LIQ := nVAL_LIQ - fVALOR_2
   endif

   if TIPOCONT->Fu_comp3 $ "36"
      nVAL_LIQ := nVAL_LIQ + fVALOR_3
   endif
   if TIPOCONT->Fu_comp3 $ "127"
      nVAL_LIQ := nVAL_LIQ - fVALOR_3
   endif

   if TIPOCONT->Fu_comp4 $ "36"
      nVAL_LIQ := nVAL_LIQ + fVALOR_4
   endif
   if TIPOCONT->Fu_comp4 $ "127"
      nVAL_LIQ := nVAL_LIQ - fVALOR_4
   endif

   if TIPOCONT->Fu_comp5 $ "36"
      nVAL_LIQ := nVAL_LIQ + fVALOR_5
   endif
   if TIPOCONT->Fu_comp5 $ "127"
      nVAL_LIQ := nVAL_LIQ - fVALOR_5
   endif

   if TIPOCONT->Fu_comp6 $ "36"
      nVAL_LIQ := nVAL_LIQ + fVALOR_6
   endif
   if TIPOCONT->Fu_comp6 $ "127"
      nVAL_LIQ := nVAL_LIQ - fVALOR_6
   endif

   if TIPOCONT->Fu_comp7 $ "36"
      nVAL_LIQ := nVAL_LIQ + fVALOR_7
   endif
   if TIPOCONT->Fu_comp7 $ "127"
      nVAL_LIQ := nVAL_LIQ - fVALOR_7
   endif

   if TIPOCONT->Fu_comp8 $ "36"
      nVAL_LIQ := nVAL_LIQ + fVALOR_8
   endif
   if TIPOCONT->Fu_comp8 $ "127"
      nVAL_LIQ := nVAL_LIQ - fVALOR_8
   endif

   if TIPOCONT->Fu_comp9 $ "36"
      nVAL_LIQ := nVAL_LIQ + fVALOR_9
   endif
   if TIPOCONT->Fu_comp9 $ "127"
      nVAL_LIQ := nVAL_LIQ - fVALOR_9
   endif

   if TIPOCONT->Fu_comp10 $ "36"
      nVAL_LIQ := nVAL_LIQ + fVALOR_10
   endif
   if TIPOCONT->Fu_comp10 $ "127"
      nVAL_LIQ := nVAL_LIQ - fVALOR_10
   endif

   if TIPOCONT->Fu_comp11 $ "36"
      nVAL_LIQ := nVAL_LIQ + fVALOR_11
   endif
   if TIPOCONT->Fu_comp11 $ "127"
      nVAL_LIQ := nVAL_LIQ - fVALOR_11
   endif

   if TIPOCONT->Fu_comp12 $ "36"
      nVAL_LIQ := nVAL_LIQ + fVALOR_12
   endif
   if TIPOCONT->Fu_comp12 $ "127"
      nVAL_LIQ := nVAL_LIQ - fVALOR_12
   endif

   if TIPOCONT->Fu_comp13 $ "36"
      nVAL_LIQ := nVAL_LIQ + fVALOR_13
   endif
   if TIPOCONT->Fu_comp13 $ "127"
      nVAL_LIQ := nVAL_LIQ - fVALOR_13
   endif

   qsay  ( 22,65, nVAL_LIQ , "@E 9,999,999.99" )

// inkey(3)

return .T.

///////////////////////////////////////////////////////////////////////////
// FUNCAO PARA CRITICAS LANCAMENTOS COMPLEMENTARES ________________________
static function i_crit2 ( cCAMPO )
   iif ( cCAMPO == NIL , cCAMPO := "" , NIL )
   do case
      case cCAMPO == "VALOR_1"
           if empty(cDESC_1) ; nNIVEL := 41 ; endif
      case cCAMPO == "VALOR_2"
           if empty(cDESC_2) ; nNIVEL := 41 ; endif
      case cCAMPO == "VALOR_3"
           if empty(cDESC_3) ; nNIVEL := 41 ; endif
      case cCAMPO == "VALOR_4"
           if empty(cDESC_4) ; nNIVEL := 41 ; endif
      case cCAMPO == "VALOR_5"
           if empty(cDESC_5) ; nNIVEL := 41 ; endif
      case cCAMPO == "VALOR_6"
           if empty(cDESC_6) ; nNIVEL := 41 ; endif
      case cCAMPO == "VALOR_7"
           if empty(cDESC_7) ; nNIVEL := 41 ; endif
      case cCAMPO == "VALOR_8"
           if empty(cDESC_8) ; nNIVEL := 41 ; endif
      case cCAMPO == "VALOR_9"
           if empty(cDESC_9) ; nNIVEL := 41 ; endif
      case cCAMPO == "VALOR_10"
           if empty(cDESC_10) ; nNIVEL := 41 ; endif
      case cCAMPO == "VALOR_11"
           if empty(cDESC_11) ; nNIVEL := 41 ; endif
      case cCAMPO == "VALOR_12"
           if empty(cDESC_12) ; nNIVEL := 41 ; endif
      case cCAMPO == "VALOR_13"
           if empty(cDESC_13) ; nNIVEL := 41 ; endif
   endcase
return .T.


///////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INCLUIR O LCTO CONTABIL PARA LIQUIDACAO ____________________
function i_contabil

  if SH_CONTA->(qappend())

     replace SH_CONTA->Codigo     with RECEBER->Cod_cli
     replace SH_CONTA->Num_nota   with RECEBER->Fatura
     replace SH_CONTA->Data_lanc  with RECEBER->Data_lanc
     replace SH_CONTA->Serie      with RECEBER->Serie
     CLI1->(dbsetorder(1))
     CLI1->(dbseek(RECEBER->Cod_cli))
     replace SH_CONTA->Ca         with CLI1->Razao
     replace SH_CONTA->Cgc        with CLI1->Cgccpf
     replace SH_CONTA->Dp         with RECEBER->Fatura
     ESPECIE->(dbseek(RECEBER->Especie))
     replace SH_CONTA->Ep         with ESPECIE->Descricao
     replace SH_CONTA->Fa         with RECEBER->Fatura
     replace SH_CONTA->Nf         with RECEBER->Fatura
     SERIE->(dbseek(RECEBER->Serie))
     replace SH_CONTA->Se         with SERIE->Descricao

  endif

  if TIPOCONT->(dbseek(RECEBER->Tipo_sub)) .and. TIPOCONT->Regime_ope == "2"
     if RECEBER->(qrlock())
        replace RECEBER->Contabil with .T.
     endif
     if SH_PROCT->(qappend())

        replace SH_PROCT->Data_lanc   with  RECEBER->Data_lanc

        if TIPOCONT->Regime_ope == "2" // Regime de competencia

           nHISTORICO := TIPOCONT->Hist_l_pr

           if TIPOCONT->Cont_pr_dv == "1"
              replace SH_PROCT->Cont_db with TIPOCONT->Ct_ct_p_dv
           else
              CLI1->(dbseek(RECEBER->Cod_cli))
              replace SH_PROCT->Cont_db with CLI1->Conta_cont
           endif

           if TIPOCONT->Cont_pr_cr == "1"
              replace SH_PROCT->Cont_cr with TIPOCONT->Ct_ct_p_cr
           else
              CLI1->(dbseek(RECEBER->Cod_cli))
              replace SH_PROCT->Cont_cr with CLI1->Conta_cont
           endif

        else // regime de caixa

           nHISTORICO := TIPOCONT->Hist_l_pr

           if TIPOCONT->Conta_liq == "1"
              replace SH_PROCT->Cont_db with TIPOCONT->Ct_ct_liq
           else
              CLI1->(dbseek(RECEBER->Cod_cli))
              replace SH_PROCT->Cont_db with CLI1->Conta_cont
           endif

           if TIPOCONT->Conta_l2 == "1"
              replace SH_PROCT->Cont_cr with TIPOCONT->Ct_ct_l2
           else
              CLI1->(dbseek(RECEBER->Cod_cli))
              replace SH_PROCT->Cont_cr with CLI1->Conta_cont
           endif

        endif

        replace SH_PROCT->Filial     with  RECEBER->Filial

        replace SH_PROCT->Valor      with  RECEBER->Valor
        replace SH_PROCT->Num_doc    with  RECEBER->Fatura
        replace SH_PROCT->Num_lote   with  "RB" + XUSRNUM + strzero(CONFIG->Lote_cont,5) // monta numero do lote
        replace SH_PROCT->Cod_hist   with  nHISTORICO

        monta_hist("RECEBER",nHISTORICO)

     endif

     if CONFIG->(qrlock())
        replace CONFIG->Num_lote with (CONFIG->Num_lote + 1)
        CONFIG->(qunlock())
     endif

  endif

return

////////////////////////////////////////////////////////////////////////////////
// FUNCAO UTILIZADA PARA A SELECAO DOS MNEUMONICOS DO HISTORICO ________________
function monta_hist(cARQ,cHIST)

HIST->(dbseek(cHIST))
nHIST := HIST->Descricao

for nCONT := 1 to len(nHIST)
    if ( nPOS := at("[",nHIST) )  <> 0
       nPOS += 2  // para ignorar os simbolos [@
       CLI1->(dbgotop())
       do case
          case substr(nHIST,nPOS,2) == "CA"
               CLI1->(Dbseek((cARQ)->Cod_cli))
               replace SH_PROCT->Ca with left(CLI1->Razao,40)
          case substr(nHIST,nPOS,3) == "CGC"
               CLI1->(Dbseek((cARQ)->Cod_cli))
               replace SH_PROCT->Cgc with CLI1->Cgccpf
          case substr(nHIST,nPOS,2) == "DA"
               replace SH_PROCT->Da with XDATSYS
          case substr(nHIST,nPOS,2) == "DP" .or. substr(nHIST,nPOS,2) == "FA" .or. substr(nHIST,nPOS,2) == "NF"
               replace SH_PROCT->Dp with (cARQ)->Fatura
               replace SH_PROCT->Fa with (cARQ)->Fatura
               replace SH_PROCT->Nf with (cARQ)->Fatura
          case substr(nHIST,nPOS,2) == "EP"
               ESPECIE->(Dbseek((cARQ)->Especie))
               replace SH_PROCT->Ep with left(ESPECIE->Descricao,3)
          case substr(nHIST,nPOS,2) == "SE"
               SERIE->(Dbseek((cARQ)->Serie))
               replace SH_PROCT->Se with left(SERIE->Descricao,3)
       endcase

       nHIST := substr( nHIST , nPOS+4 , len(nHIST) ) // retira da variavel nHIST, os mneumonicos que ja foram verificados

    else
      exit
    endif

next

return

function i_transf
   local lCONF

   lCONF := qconf("Confirma Transferencia p/ Arquivo Morto ?")

   if lCONF

      if ! RECEBER->(qflock()) .and. ! RECEB2->(qflock())
         qmensa("N„o foi Poss¡vel Transferir !","B")
         return
      endif
      RECEBER->(qpublicfields())
      RECEBER->(qcopyfields())
      RECEB2->(qappend())
      fDATA_PAGTO := date()
      RECEB2->(qreplacefields())

      RECEBER->(dbdelete())
      RECEBER->(qunlock())
      RECEB2->(qunlock())

   endif
return

// FUNCAO PARA FAZER A MARCACAO PARA LIBERACAO ______________________________

static function i_marca
   if RECEBER->(qrlock())
      if RECEBER->Agrupa == "*"
         replace RECEBER->Agrupa with " "
      else
         replace RECEBER->Agrupa with "*"
      endif
   endif
return

static function i_del_transf
     RECEBER->(Dbgotop())

     do while ! RECEBER->(Eof())

        RECGRUPO->(qappend())

        RECEBER->(qpublicfields())
        RECEBER->(qcopyfields())
        fAGRUPA := " "
        RECGRUPO->(qreplacefields())
        if RECEBER->(Qrlock())
           RECEBER->(dbdelete())
           RECEBER->(qunlock())
        endif

        RECEBER->(Dbskip())

     enddo
     RECEBER->(Dbclearfil())

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



