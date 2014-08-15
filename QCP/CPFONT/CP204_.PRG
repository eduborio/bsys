/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE COMPRAS
// OBJETIVO...: MANUTENCAO DE PEDIDO DE COMPRAS
// ANALISTA...: EDUARDO AUGUSTO BORIO
// PROGRAMADOR:
// INICIO.....: JANEIRO DE 2005
// OBS........:
// ALTERACOES.:

function cp204

#include "inkey.ch"

#define K_MAX_LIN 60

private sBLOC1  := qlbloc("B204E","QBLOC.GLO")
private cTIPO := "1"
private cT_ORDE_COM   // Variavel temporario para lancamento fORDE_COM
private dT_DATA_PED   // Variavel temporario para lancamento fDATA_PED
private cT_CENTRO     // Variavel temporario para lancamento fCENTRO
private cT_FILIAL     // Variavel temporario para lancamento fFILIAL
private cT_VEICULO    // Variavel temporario para lancamento fVEICULO
private cT_EQUIPTO    // Variavel temporario para lancamento fVEICULO
private cT_COMPRADOR  // Variavel temporario para lancamento fCOMPRADOR
private cT_COD_FORN   // Variavel temporario para lancamento fCOD_FORN
private cT_COD_FISC   // Variavel temporario para lancamento fCOD_FISC
private cCOD_FORN     // Codigo do fornecedor temporario
private cMOTIVO := space(50)  // Descricao de motivo de compra de produto com garantia
private lPRIMEIRO_LANCAMENTO := .T.
private cSENHA
private cALIQ_ICMS := 0
private cALIQ_IPI  := 0
private fCOD_VEIC
private fCOD_PROD := space(5)
private fCOD_EQUIP
private cALIAS
private cT_TIPO       // Variavel temporario para lancamento fTIPO
private cOPCAO := ""

PROD->(dbsetorder(4))
quse(XDRV_CT,"CONFIG",NIL,NIL,"CONTAB")

quse(XDRV_CL,"CONFIG",NIL,NIL,"FATCFG")

IMPORT->(qview({{"i_204c()/Codigo"                                          ,2},;
                {"Data_ped/Data."                                       ,1},;
                {"left(Fornecedor,31)/Fornecedor"                           ,7},;
                {"transform(Val_liq,'@E 999,999,999.99')/Valor Total"   ,0},;
                {"Protocolo/P"                                              ,0}},"P",;
                {NIL,"i_204b",NIL,NIL},;
                NIL,"<ESC>/<A>lt/<E>xc/<I>nc/<C>on "))

FATCFG->(DbCloseArea())
CONTAB->(DbCloseArea())
//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAGEM DO FORNECEDOR ___________________________________________

function i_204c
return transform(IMPORT->Codigo,"@R 99999/9999!")

//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INFORMAR SE FOI FEITO O INTERFACE _________________________________

function i_204d
   local cSIMNAO
   do case
      case IMPORT->Interface == .T.
           cSIMNAO := "SIM"
      case IMPORT->Interface == .F.
           cSIMNAO := "NŽO"
   endcase
return cSIMNAO

//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MARCAR PROTOCOLO __________________________________________________

static function i_protocolo
   if IMPORT->(qrlock())
      if ! empty(IMPORT->Protocolo)
         replace IMPORT->Protocolo with " "
      else
         replace IMPORT->Protocolo with "*"
      endif
      IMPORT->(qunlock())
   else
      qm2()
   endif
return


//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO _____________________________________

function i_204b

   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))

   iif(cOPCAO=="P",i_imp_pedido() ,nil)


   //if cOPCAO $ "AE" .and. IMPORT->Interface
   //   qmensa("Foi feito interface, acesso proibido !","B")
   //   return ""
   //endif

   if (cOPCAO $ XUSRA .and. cTIPO == "1") .or. ( cOPCAO == "C" .and. cTIPO == "2" )

      qlbloc(5,0,"B204A","QBLOC.GLO",1)
      qmensa(qabrev(cOPCAO,"IA",{"Inclus„o... <ESC - Cancela>","Altera‡„o... <ESC - Cancela>"}))
      i_edicao()
   endif

   setcursor(nCURSOR)

   select IMPORT
   IMPORT->(dbsetorder(2))

return ""

//////////////////////////////////////////////////////////////////////////////////
// PESQUISA PELO NUMERO DO PEDIDO ________________________________________________

static function i_pesq_pedido

   local cPEDIDO
   local cNUMERO := "     "
   local cANO    := "    "
   local nREC    := IMPORT->(recno())

   qmensa("Digite o numero do Pedido p/ pesquisa:      /  ")
   qgetx(24,50,@cNUMERO,"99999")
   qgetx(24,56,@cANO,"9999"    )

   cPEDIDO := strzero(val(cNUMERO),5) + strzero(val(cANO),4)

   IMPORT->(dbsetorder(2))

   if ! IMPORT->(dbseek(cPEDIDO))
      qmensa("Pedido n„o encontrado !","B")
      IMPORT->(dbgoto(nREC))
      return
   endif

return

//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA _________________________________________

static function i_edicao

   local lCONF
   local aEDICAO := {}
   local bESCAPE := {||empty(fDATA_PED).or.(XNIVEL==2.and.!XFLAG).or.;
                       (XNIVEL==2.and.lastkey()==27)}

   private cESTADO_EMP  // Estado da empresa
   private cESTADO_FOR  // Estado do fornecedor

   private nDIA_1   := 0
   private nDIA_2   := 0
   private nDIA_3   := 0
   private nDIA_4   := 0
   private nDIA_5   := 0
   private dDATA_1  := ctod("")
   private dDATA_2  := ctod("")
   private dDATA_3  := ctod("")
   private dDATA_4  := ctod("")
   private dDATA_5  := ctod("")
   private nVALOR_1 := 0
   private nVALOR_2 := 0
   private nVALOR_3 := 0
   private nVALOR_4 := 0
   private nVALOR_5 := 0

   private aPARCELA := {{0,ctod(""),0},{0,ctod(""),0},{0,ctod(""),0},{0,ctod(""),0},{0,ctod(""),0}}

   private nTOT_ICM := 0
   private nTOT_IPI := 0
   private nTOT_ISS := 0
   private nTOT_II := 0
   private fESTOQUE := "N"

// MONTA DADOS NA TELA ___________________________________________________________

   if cOPCAO <> "I"
      XNIVEL := 1
      qsay ( 6,20, IMPORT->Codigo ,"@R 99999/9999"            )
      qsay ( 6,45, IMPORT->Data_ped                           )
      qsay ( 6,72, IMPORT->Orde_com                           )

      qsay ( 7,20, IMPORT->Num_Di                              )
      qsay ( 7,45, dtoc(IMPORT->Data_regdi)                   )
      qsay ( 8,20, IMPORT->Loc_desem                        )
      qsay ( 9,20, IMPORT->uf_desem                           )
      qsay ( 9,45, dtoc(IMPORT->data_desem)                   )
      qsay ( 9,71, IMPORT->cod_export                         )

//      qsay ( 7,20, left(IMPORT->Filial,4)                     ) ; FILIAL->(dbseek(IMPORT->Filial))
//      qsay ( 7,27, left(FILIAL->Razao,40)                     )
//      qsay ( 8,20, left(IMPORT->Centro,4)                     ) ; CCUSTO->(dbseek(IMPORT->Centro))
//      qsay ( 8,27, CCUSTO->Descricao                          )
//      qsay ( 9,14, IMPORT->Veiculos                           ) ; VEICULOS->(dbseek(IMPORT->Veiculos))
//      qsay ( 9,20, VEICULOS->Descricao                        )
//      qsay ( 9,51, IMPORT->Equipto                            ) ; EQUIPTO->(dbseek(IMPORT->Equipto))
//      qsay ( 9,57, left(EQUIPTO->Descricao,20)                )
      qsay (10,20, IMPORT->Tipo                               ) ; TIPOCONT->(dbseek(IMPORT->Tipo) )
      qsay (10,29, left(TIPOCONT->Descricao,30)               )
      qsay (10,74, qabrev(IMPORT->Estoque,"SN", {"Sim","N„o"})) ; iif(IMPORT->Estoque == "N",fESTOQUE := "N",fESTOQUE := "S")
      qsay (11,20, IMPORT->Comprador                          ) ; CAD_COMP->(dbseek(IMPORT->Comprador))
      qsay (11,29, CAD_COMP->Nome                             )

      qsay (11,72, IMPORT->Nr_os                              )
      qsay (12,20, IMPORT->Cod_forn                           ) ; FORN->(dbseek(IMPORT->Cod_forn))
      qsay (12,29, left(FORN->Razao,45)                       )
      qsay (13,20, IMPORT->Cod_cota                           )

      qsay (14,20, IMPORT->Cfop , "@R 9.999"               ) ; CFOP->(dbseek(IMPORT->Cfop))
      qsay (14,29, CFOP->Nat_Desc                            )
   endif

   // CONSULTA OU EXCLUSAO _______________________________________________________

   if cOPCAO == "C" ; i_consulta() ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO _________________________________________________

   aadd(aEDICAO,{{ || NIL                                              } ,NIL        })
   aadd(aEDICAO,{{ || qgetx(6,45,@fDATA_PED    ,"@D",NIL              )} ,"DATA_PED" })
   aadd(aEDICAO,{{ || view_ordem(6,72,@fORDE_COM                      )} ,"ORDE_COM" })


   aadd(aEDICAO,{{ || qgetx(7,20,@fNUM_DI      ,"9999999999"           )} ,NIL })
   aadd(aEDICAO,{{ || qgetx(7,45,@fDATA_REGDI  ,"@D",NIL              )} ,NIL })
   aadd(aEDICAO,{{ || qgetx(8,20,@fLOC_DESEM ,"@!"                  )} ,NIL })
   aadd(aEDICAO,{{ || qgetx(9,20,@fUF_DESEM    ,"@!"                  )} ,NIL })
   aadd(aEDICAO,{{ || qgetx(9,45,@fDATA_DESEM  ,"@D",NIL              )} ,NIL })
   aadd(aEDICAO,{{ || qgetx(9,71,@fCOD_EXPORT  ,"999999"              )} ,NIL })



//   aadd(aEDICAO,{{ || view_filial(7,20,@fFILIAL,"@R 9999"             )} ,"FILIAL"   })
//   aadd(aEDICAO,{{ || NIL                                              } ,NIL        }) // descricao da filial
// CCUSTO->(dbSetFilter({|| val(left(Codigo,2)) == val(fFILIAL)        } ,'val(left(Codigo,2)) == val(fFILIAL)'))
//   aadd(aEDICAO,{{ || view_ccusto(8,20,@fCENTRO                       )} ,"CENTRO"   })
//   aadd(aEDICAO,{{ || NIL                                              } ,NIL        }) // descricao do centro
//   aadd(aEDICAO,{{ || view_veic(9,14,@fVEICULOS                       )} ,"VEICULOS" })
//   aadd(aEDICAO,{{ || NIL                                              } ,NIL        }) // descricao da veiculos
//   aadd(aEDICAO,{{ || view_equip(9,51,@fEQUIPTO                       )} ,"EQUIPTO"  })
//   aadd(aEDICAO,{{ || NIL                                              } ,NIL        }) // descricao da equipamentos
   aadd(aEDICAO,{{ || view_tipo(10,20,@fTIPO                          )} ,"TIPO"     })
   aadd(aEDICAO,{{ || NIL                                              } ,NIL        }) // descricao do tipo
   aadd(aEDICAO,{{ || qesco(10,72,@fESTOQUE ,sBLOC1                   )} ,"ESTOQUE"  })
   aadd(aEDICAO,{{ || view_comprador(11,20,@fCOMPRADOR                )} ,"COMPRADOR"})
   aadd(aEDICAO,{{ || NIL                                              } ,NIL        }) // nome do comprador
   if fESTOQUE == "N"
   aadd(aEDICAO,{{ || view_os(11,72,@fNR_OS                           )} ,"NR_OS"    })
   else
   aadd(aEDICAO,{{ || NIL                                              } ,NIL        })
   Endif
   aadd(aEDICAO,{{ || view_forn(12,20,@fCOD_FORN                      )} ,"COD_FORN" })
   aadd(aEDICAO,{{ || NIL                                              } ,NIL        }) // nome do fornecedor
   aadd(aEDICAO,{{ || view_cota(13,20,@fCOD_COTA ,"@R 99999"          )} ,"COD_COTA" }) // Codigo da cotacao
   aadd(aEDICAO,{{ || NIL                                              } ,NIL        })

   aadd(aEDICAO,{{ || view_cfop(14,20,@fCFOP                          )} ,"CFOP" })
   aadd(aEDICAO,{{ || NIL                                              } ,NIL        }) // descricao do codigo fiscal

   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO ____________________________________________________

   do while .T.
      qgirabarra()

      IMPORT->(qpublicfields())

      iif(cOPCAO=="I", IMPORT->(qinitfields()), IMPORT->(qcopyfields()))

      XNIVEL := 2
      XFLAG := .T.

      if cOPCAO == "I"
         qlbloc(5,0,"B204A","QBLOC.GLO",1)
         fOBSERVACAO := space(240)
         if ! lPRIMEIRO_LANCAMENTO
            fDATA_PED   := dT_DATA_PED
            fORDE_COM   := cT_ORDE_COM
            fCENTRO     := cT_CENTRO
            fFILIAL     := cT_FILIAL
            fVEICULOS   := cT_VEICULOS
            fEQUIPTO    := cT_EQUIPTO
            fTIPO       := cT_TIPO
            fCOMPRADOR  := cT_COMPRADOR
            fCOD_FORN   := cT_COD_FORN
            fCOD_FISC   := cT_COD_FISC
         endif
      endif

      fFILIAL := "0001"

      // SE ALTERACAO , ENTAO INICIALIZA O VETOR DE CONDICAO DE PGTOS____________

      if cOPCAO == "A" ; i_init_parcela() ; endif

      // LOOP PARA ENTRADA DOS CAMPOS ____________________________________________

      do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
         eval ( aEDICAO [XNIVEL,1] )
         if eval ( bESCAPE );IMPORT->(qreleasefields());PARCELA->(qreleasefields());return;endif
         if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
         iif ( XFLAG , XNIVEL++ , XNIVEL-- )
         qmensa("")
      enddo

      if ! lCONF ; return ; endif

      if CONFIG->(qrlock()) .and. IMPORT->(iif(cOPCAO=="I",qappend(),qrlock()))

// AQUI INCREMENTA CODIGO DO PEDIDO __________________________________

         if cOPCAO == "I"
            replace CONFIG->Cod_import with CONFIG->Cod_import+1
            qsay ( 6,20, strzero(CONFIG->Cod_import,5)+"/"+ left(dtos(date()),4))
            qmensa("C¢digo Gerado: "+strzero(CONFIG->Cod_import,5)+"/"+left(dtos(date()),4),"B")
            fCODIGO := strzero(CONFIG->Cod_import,5)+left(dtos(date()),4)
         endif

// AQUI GRAVA REGISTROS NO ARQUIVO LANC ______________________________

         if cOPCAO == "I"
            if TOMA_PRE->(dbseek(fCOD_COTA))
               if TOMA_PRE->(qrlock())
                  ITEN_TOM->(qflock())
                  ITEN_TOM->(dbgotop())
                  do while ! ITEN_TOM->(eof()) .and. ITEN_TOM->Cod_tom == fCOD_COTA
                     select ITEN_IMP
                     append blank
                     replace  ITEN_IMP->Cod_ped   with  fCODIGO
                     replace  ITEN_IMP->Cod_prod  with  ITEN_TOM->Cod_prod
                     replace  ITEN_IMP->Cod_veic  with  iif(empty(fVEICULOS),"     ",strzero(val(fVEICULOS),5))
                     replace  ITEN_IMP->Cod_equip with  fEQUIPTO
                     replace  ITEN_IMP->Preco     with  ITEN_TOM->Valor
                     replace  ITEN_IMP->Lote      with  "0000000000"
                     replace  ITEN_IMP->Quant     with  ITEN_TOM->Quant
                     replace  ITEN_IMP->Centro    with  fCENTRO
                     replace  ITEN_IMP->Aliq_icms with  0
                     replace  ITEN_IMP->Aliq_ipi  with  0
                     replace  ITEN_IMP->Fator     with  1

                     ITEN_TOM->(dbskip())
                  enddo
               else
                  qm3()
               endif
               nDIA_1 := val(TOMA_PRE->Cond_1)
               nDIA_2 := val(TOMA_PRE->Cond_2)
               nDIA_3 := val(TOMA_PRE->Cond_3)
               nDIA_4 := val(TOMA_PRE->Cond_4)
               nDIA_5 := val(TOMA_PRE->Cond_5)
            endif
         endif

         // AGORA GRAVA E DESTRAVA ARQUIVO _____________________________________

         IMPORT->(qreplacefields())

         dT_DATA_PED  := fDATA_PED
         cT_ORDE_COM  := fORDE_COM
         cT_CENTRO    := fCENTRO
         cT_FILIAL    := fFILIAL
         cT_VEICULOS  := fVEICULOS
         cT_EQUIPTO   := fEQUIPTO
         cT_TIPO      := fTIPO
         cT_COMPRADOR := fCOMPRADOR
         cT_COD_FORN  := fCOD_FORN
         cT_COD_FISC  := fCOD_FISC

         lPRIMEIRO_LANCAMENTO := .F.

      endif

      dbunlockall()

      if cOPCAO $ "IA" //.and. lPASSA_PARA_LANC

         if cOPCAO == "I" .and. ! empty(fORDE_COM)  // se tiver Ordem de Compra, Grava os dados dos Produto no arq. LANC

            ORDEM->(Dbseek(fORDE_COM))
            ITENS_OC->(Dbseek(fORDE_COM))

            do while ! ITENS_OC->(eof()) .and. ITENS_OC->Cod_ord == fORDE_COM

               if ITEN_IMP->(qrlock()) .and. ITEN_IMP->(qappend())

                  replace ITEN_IMP->Cod_ped    with fCODIGO
                  replace ITEN_IMP->Cod_prod   with left(ITENS_OC->Produto,5)
                  replace ITEN_IMP->Quant      with ITENS_OC->Quantidade
                  replace ITEN_IMP->Lote       with ITENS_OC->LOTE
//                replace ITEN_IMP->Qt_estoque with ITEN_IMP->Quant * 1 // esse valor 1 deve mudar para o fator no ordem de compra
                  replace ITEN_IMP->Cod_veic   with ORDEM->Veiculo
                  replace ITEN_IMP->Cod_equip  with ORDEM->Equipament

               endif

               ITENS_OC->(Dbskip())
            enddo

            if ORDEM->(qrlock())
               replace ORDEM->Pedido with fCODIGO
            endif

            i_proc_lanc()

         else
           i_proc_lanc()

           cADIANTE := qconf("Confirma Pr¢xima Tela Pressione <S>, ou Retornar Pressione <N> ?")
           if ! cADIANTE; cOPCAO := ""; IMPORT->(qreleasefields());  exit ; endif


           i_parcelas()
         endif

      endif

   enddo
//   CONTAB->(Dbclosearea())
//   FATCFG->(DbCloseArea())
return
/////////////////////////////////////////////////////////////////////////////////
// CRITICAS NA DESCIDA __________________________________________________________

static function i_critica ( cCAMPO )
   local cbloq
   qmensa("")

   iif ( cCAMPO == NIL , cCAMPO := "" , NIL )
   if ! XFLAG ; return .T. ; endif

   do case
      case cCAMPO == "DATA_PED"

           if cOPCAO == "I"
              cBLOQ := strzero(month(fDATA_PED),2)
              cBLOQ := "TRAV_" + cBLOQ
              if CONTAB->&cBLOQ == "S"
                 qmensa("Mes bloqueado para lan‡amentos. Verfique com a contabilidade !!","B")
                 qmensa()
                 fDATA_PED := ctod("")
                 return .F.
              endif

           endif


      case cCAMPO == "ORDE_COM"

           ORDEM->(dbsetorder(1))

           if ! empty(fORDE_COM)

              if ! ORDEM->(dbseek(fORDE_COM:=strzero(val(fORDE_COM),5)))
                 qmensa("Ordem de Compra n„o encontrada !","B")
                 return .F.
              endif

              qsay(6,72,ORDEM->Codigo)

              fCENTRO   := ORDEM->Centro
              fFILIAL   := ORDEM->Filial
              fVEICULOS := ORDEM->Veiculo
              fEQUIPTO  := ORDEM->Equipament

           endif

      case cCAMPO == "CENTRO"
           if empty(fCENTRO) ; return .F. ; endif
           qsay(8,20,left(fCENTRO,4))

           CCUSTO->(dbsetorder(4))

           if ! CCUSTO->(dbseek(fCENTRO))
              qmensa("Centro de Custo n„o encontrado !","B")
              return .F.
           endif
           qsay(8,27,CCUSTO->Descricao)

      case cCAMPO == "FILIAL"
           if empty(fFILIAL) ; return .F. ; endif
           qsay(7,20,left(fFILIAL,4))
           if ! FILIAL->(dbseek(fFILIAL))
              qmensa("Filial n„o encontrado !","B")
              return .F.
           endif
           qsay(7,27,left(FILIAL->Razao,40))

      case cCAMPO == "VEICULOS"
           if ! empty(fVEICULOS)
              qsay(9,14,fVEICULOS:=strzero(val(fVEICULOS),5))
              if ! VEICULOS->(dbseek(fVEICULOS))
                 qmensa("Veiculos n„o encontrado !","B")
                 return .F.
              endif
              if VEICULOS->Filial <> alltrim(fFILIAL)
                 qmensa("Este ve¡culo n„o pertence a filial " + alltrim(fFILIAL),"B")
                 return .F.
              endif
              qsay(9,20,VEICULOS->Descricao)
           endif

      case cCAMPO == "EQUIPTO"
           if ! empty(fEQUIPTO)
              qsay(9,51,fEQUIPTO:=strzero(val(fEQUIPTO),5))
              if ! EQUIPTO->(dbseek(fEQUIPTO))
                 qmensa("Equipamentos n„o encontrado !","B")
                 return .F.
              endif
              qsay(9,57,left(EQUIPTO->Descricao,20))
           endif

      case cCAMPO == "TIPO"
           if empty(fTIPO) ; return .F. ; endif
           qsay(10,20,fTIPO:=strzero(val(fTIPO),6))
           if ! TIPOCONT->(dbseek(fTIPO))
              qmensa("Tipo Contabil n„o encontrado !","B")
              return .F.
           endif
           qsay(10,29,alltrim(TIPOCONT->Descricao))

      case cCAMPO == "ESTOQUE"
           if empty(fESTOQUE) ; return .F. ; endif
           qsay(10,74,qabrev(fESTOQUE,"SN",{"Sim","N„o"}))


      case cCAMPO == "COMPRADOR"
           if empty(fCOMPRADOR) ; return .F. ; endif
           qsay(11,20,fCOMPRADOR:=strzero(val(fCOMPRADOR),5))
           if ! CAD_COMP->(dbseek(fCOMPRADOR))
              qmensa("Comprador n„o encontrado !","B")
              return .F.
           endif
           qsay(11,29,CAD_COMP->Nome)

      case cCAMPO == "NR_OS"
//         if empty(fNR_OS) .and. fESTOQUE == "N" ; return .F. ; endif
           qsay(11,72,fNR_OS)
           if !empty(fNR_OS)
              if ! OS->(dbseek(fNR_OS))
                 qmensa("C¢digo da Ordem de Servi‡o n„o encontrado !","B")
                 return .F.
              endif
           Endif

      case cCAMPO == "COD_FORN"
           if empty(fCOD_FORN) ; return .F. ; endif
           qsay(12,20,fCOD_FORN:=strzero(val(fCOD_FORN),5))

           if ! FORN->(dbseek(fCOD_FORN))
              if ! qconf("Fornecedor n„o Cadastrado ! Incluir agora ?")
                 qmensa("")
                 return .F.
              endif
              if ! i_inc_fornec()
                 return .F.
              else
                 fCOD_FORN := cCOD_FORN
                 qsay(12,20,fCOD_FORN:=strzero(val(fCOD_FORN),5))

                 if empty(fCONTA_CONT)
                    qmensa("Aten‡„o !! Conta Cont bil n„o Informada ! ","B")
                 endif
              endif
           else
              if FORN->Qualif == "N"
                 qmensa("Fornecedor N„o Qualificado !","B")
                 return .F.
              endif
           endif

           // PEGA CODIGO DE CGM NO FORNECEDOR ___________________________________

           cESTADO_FOR := FORN->Cgm_cob
           fFORNECEDOR := FORN->Razao

           // PEGA ESTADO NO CGM _________________________________________________

           if CGM->(dbseek(cESTADO_FOR))
              cESTADO_FOR := CGM->Estado
           endif

           // INICIA ALIQUOTA DE ICMS (EM CASO DE INCLUSAO) ______________________

//         if cOPCAO == "I"     // foi retirada por causa de calculo de icms/ipi de outro estado
//            if ESTADO->(dbseek(cESTADO_FOR))
//               fALIQ_ICMS := ESTADO->ALiq_Orig
//            endif
//         endif

           qsay(12,29,left(FORN->Razao,45))

      case cCAMPO == "COD_COTA"
           if empty(fCOD_COTA)
              return .T.
           endif
           qsay(13,20,fCOD_COTA)

           if ! TOMA_PRE->(dbseek(fCOD_COTA))
                qmensa("C¢digo da Cota‡„o n„o encontrado...","B")
                return .F.
           endif
           return .T.

      case cCAMPO == "COD_FISC"

           if fCOD_FISC <> "999"

              // PEGA ESTADO NA FILIAL ______________________________________________

              FILIAL->(dbseek(fFILIAL))
              CGM->(dbseek(FILIAL->Cgm))

              cESTADO_EMP := CGM->Estado

              if ! NATOP->(dbseek(fCOD_FISC))
                 qmensa("C¢digo fiscal inv lido !","B") ; return .F.
              endif

              if substr(fCOD_FISC,1,1) $ "567"
                 qmensa("Codigo fiscal inv lido para entrada das notas !","B")
                 return .F.
              endif

              if right(fCOD_FISC,1) $ "0"
                 qmensa("C¢digo fiscal de grupo, n„o permitido !","B")
                 return .F.
              endif

              if cESTADO_EMP == cESTADO_FOR

                 if left(fCOD_FISC,1) <> "1" .and. left(fCOD_FISC,1) <> "3"  // Foi liberado os codigos fiscais de importacao
                    qmensa("C¢digo Inv lido Dentro do Estado! Ver Estado do Fornecedor <101>","B")
                    return .F.
                 endif

              else

                 if !left(fCOD_FISC,1) $ "23"
                    qmensa("C¢digo Inv lido Dentro do Estado! Ver Estado do Fornecedor <101>","B")
                    return .F.
                 endif

              endif

              qsay(14,29,NATOP->Nat_Desc)
           else
              if ! NATOP->(dbseek(fCOD_FISC))
                 qmensa("C¢digo fiscal inv lido !","B") ; return .F.
              endif
              qsay(14,29,NATOP->Nat_Desc)
           endif

       case cCAMPO == "CFOP"
            if ! CFOP->(dbseek(fCFOP))
               qmensa("C¢digo fiscal inv lido !","B") ; return .F.
            endif
            qsay(14,29,CFOP->Nat_Desc)


   endcase

return .T.

//////////////////////////////////////////////////////////////////////////////////
// FUN€AO PARA EXCLUIR PEDIDO DE COMPRA __________________________________________

static function i_exclusao

   if qconf("Confirma exclus„o deste Pedido de Compra ?")
      if PARCELA->(qflock()) .and. IMPORT->(qrlock()) .and. ITEN_IMP->(qflock())
         ITEN_IMP->(dbseek(IMPORT->Codigo))
         do while ! ITEN_IMP->(eof()) .and. ITEN_IMP->Cod_ped == IMPORT->Codigo
            ITEN_IMP->(dbdelete())
            ITEN_IMP->(dbskip())
         enddo
         i_grava_parcelas()
         IMPORT->(dbdelete())
         IMPORT->(qunlock())
         PARCELA->(qunlock())
         ITEN_IMP->(qunlock())
      else
         qm3()
      endif
//      MOTI_GAR->(Dbsetorder(2))
//      if MOTI_GAR->(Dbseek(IMPORT->Codigo)) .and. MOTI_GAR->(qrlock())
//         MOTI_GAR->(Dbdelete())
//         MOTI_GAR->(qunlock())
//      endif
   endif

return

//////////////////////////////////////////////////////////////////////////////////
// LANCAMENTOS DE PARCELAS _______________________________________________________

static function i_parcelas

   local lCONF
   local sBLOC := qsbloc(5,0,24,79)
   local aEDICAO := {}
   local bESCAPE := {||(XNIVEL==1.and.!XFLAG)}
   local nBaseIcm, nValIcm := 0

   qlbloc(5,2,"B204B","QBLOC.GLO",1)

   XNIVEL := 1

   // ATUALIZA A TELA ____________________________________________________________

   qrsay ( XNIVEL++  , fBASE_ICM   , "@E 999,999,999.99"       )
   qrsay ( XNIVEL++  , fALIQ_ICM   , "@E 99.99"              )
   qrsay ( XNIVEL++  , fVLR_ICM    , "@E 999,999,999.99"       )
   qrsay ( XNIVEL++  , fBASE_IPI   , "@E 999,999,999.99"       )
   qrsay ( XNIVEL++  , fALIQ_IPI   , "@E 99.99"              )
   qrsay ( XNIVEL++  , fVLR_IPI    , "@E 999,999,999.99"       )
   qrsay ( XNIVEL++  , fVAL_PEDIDO , "@E 999,999,999.99"       )
   qrsay ( XNIVEL++  , fDESP_ACESS , "@E 999,999,999.99"       )
   qrsay ( XNIVEL++  , fVAL_LIQ    , "@E 999,999,999.99"       )
   qrsay ( XNIVEL++  , left(fOBSERVACAO,60)        )
   nBaseIcm := getBaseIcms()
   nValIcm  := getValorIcms()
   
   qrsay ( XNIVEL++  , nBaseIcm  , "@E 999,999,999.99"       )
   qrsay ( XNIVEL++  , nValIcm , "@E 999,999,999.99"       )
   
   

   XNIVEL := 1

   // PARCELAS DO PEDIDO _______________________________________________________

   aadd(aEDICAO,{{ || qgetx(-1,0,@fBASE_ICM   , "@E 999,999,999.99"     )} ,"BASE_ICM"  })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fALIQ_ICM   , "@E 99.99"              )} ,"ALIQ_ICM"  })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fVLR_ICM    , "@E 999,999,999.99"     )} ,"VLR_ICM"   })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fBASE_IPI   , "@E 999,999,999.99"     )} ,"BASE_IPI"  })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fALIQ_IPI   , "@E 99.99"              )} ,"ALIQ_IPI"  })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fVLR_IPI    , "@E 999,999,999.99"     )} ,"VLR_IPI"   })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fVAL_PEDIDO , "@E 999,999,999.99"     )} ,"VAL_LIQ"   })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDESP_ACESS , "@E 999,999,999.99"     )} ,"DESP_ACESS"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@fVAL_LIQ    , "@E 999,999,999.99"     )} ,"TOT_PROD"  })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fOBSERVACAO , "@!S60"     )} ,"OBSEWRV"  })
   aadd(aEDICAO,{{ || NIL                                        } ,NIL          })
   aadd(aEDICAO,{{ || NIL                                        } ,NIL          })
 
   

   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE )
         qrbloc(5,0,sBLOC)
         return
      endif
      if ! i_crit_3( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   aPARCELA[1,1] := nDIA_1
   aPARCELA[2,1] := nDIA_2
   aPARCELA[3,1] := nDIA_3
   aPARCELA[4,1] := nDIA_4
   aPARCELA[5,1] := nDIA_5
   aPARCELA[1,2] := dDATA_1
   aPARCELA[2,2] := dDATA_2
   aPARCELA[3,2] := dDATA_3
   aPARCELA[4,2] := dDATA_4
   aPARCELA[5,2] := dDATA_5
   aPARCELA[1,3] := nVALOR_1
   aPARCELA[2,3] := nVALOR_2
   aPARCELA[3,3] := nVALOR_3
   aPARCELA[4,3] := nVALOR_4
   aPARCELA[5,3] := nVALOR_5

   if ! lCONF ;qrbloc(5,0,sBLOC); return ; endif

   if PARCELA->(qflock()) .and. IMPORT->(qrlock())

//      fVAL_LIQ := fVAL_LIQ + fVL_FRETE + fVL_SEGURO
//      fVALOR_IPI := nTOT_IPI
// /     fVALOR_ICM := nTOT_ICM
//      fALIQ_ICMS := cALIQ_ICMS
//      fALIQ_IPI  := cALIQ_IPI

      replace IMPORT->Vl_red_ic  with fVL_RED_IC
      replace IMPORT->Vl_frete   with fVL_FRETE
      replace IMPORT->Vl_seguro  with fVL_SEGURO
      replace IMPORT->Red_icms   with fRED_ICMS
      replace IMPORT->Vl_irrf    with fVL_IRRF
      replace IMPORT->Irrf       with fIRRF
      replace IMPORT->Vl_desc_i  with fVL_DESC_I
      replace IMPORT->Desc_incon with fDESC_INCON
      replace IMPORT->Vl_desc_c  with fVL_DESC_C
      replace IMPORT->Desp_Acess with fDESP_ACESS
      replace IMPORT->Out_desp   with fOUT_DESP
      replace IMPORT->Perc_pis   with fPERC_PIS
      replace IMPORT->Vlr_pis    with fVLR_PIS
      replace IMPORT->Perc_cof   with fPERC_COF
      replace IMPORT->Vlr_cof    with fVLR_COF
      replace IMPORT->Desc_cond  with fDESC_COND
      replace IMPORT->Data_adto  with fDATA_ADTO
      replace IMPORT->Valor_adto with fVALOR_ADTO
      replace IMPORT->Data_entre with fDATA_ENTRE
      replace IMPORT->Data_baixa with fDATA_BAIXA
      replace IMPORT->Numero_nf  with fNUMERO_NF
      replace IMPORT->Serie      with fSERIE
      replace IMPORT->Especie    with fESPECIE
      replace IMPORT->Data_emiss with fDATA_EMISS
      replace IMPORT->Observacao with fOBSERVACAO
      replace IMPORT->Val_liq    with fVAL_LIQ
      replace IMPORT->Valor_ipi  with fVALOR_IPI
      replace IMPORT->Valor_icm  with fVALOR_ICM
      replace IMPORT->Valor_iss  with fVALOR_ISS
      replace IMPORT->Aliq_icms  with fALIQ_ICMS
      replace IMPORT->Aliq_ipi   with fALIQ_IPI
      replace IMPORT->Val_pedido with fVal_pedido
      replace IMPORT->Sub_grup   with fSUB_GRUP
      replace IMPORT->Fornecedor with fFORNECEDOR
      replace IMPORT->Estoque    with fESTOQUE
      replace IMPORT->Base_icm   with fBASE_ICM
      replace IMPORT->Aliq_icm   with fALIQ_ICM
      replace IMPORT->Vlr_Icm    with fVLR_ICM
      replace IMPORT->Base_ipi   with fBASE_IPI
      replace IMPORT->Aliq_ipi   with fALIQ_IPI
      replace IMPORT->Vlr_ipi    with fVLR_IPI
      i_grava_parcelas()
   endif

   dbunlockall()


   if cOPCAO <> "I"
      keyboard chr(27)
   endif

return

////////////////////////////////////////////////////////////////////////////////
// CRITICAS NA DESCIDA _________________________________________________________

static function i_crit_3 ( cCAMPO )

   local nDIFERE := 0

   iif ( cCAMPO == NIL , cCAMPO := "" , NIL )
   if ! XFLAG ; return .T. ; endif

   do case

      case cCAMPO == "ALIQ_ICM"
           fVLR_ICM := (fBASE_ICM * (fALIQ_ICM / 100) )
      case cCAMPO == "ALIQ_IPI"
           fVLR_IPI := (fBASE_IPI * (fALIQ_IPI / 100) )


      case cCAMPO == "DESP_ACESS"
           fVAL_LIQ := fVLR_IPI + fDESP_ACESS + fVAL_PEDIDO



   endcase

return .T.

//////////////////////////////////////////////////////////////////////////////////
// PARA CONSULTAR A SEGUNDA TELA _________________________________________________

static function i_consulta
   local nTECLA, nCONT
   setpos(24,79)

   if cOPCAO <> "A"
      keyboard chr(27)
      i_atualiza_lancs()
   endif

   qmensa("<ESC> p/ sair ou <O>utra Tela")

   do while .T.
      nTECLA := qinkey()
      if nTECLA == K_ESC ; exit ; endif
      if upper(chr(nTECLA)) == "O"
         i_init_parcela()
         XNIVEL := 1
         qlbloc(5,2,"B204B","QBLOC.GLO",1)

         qrsay ( XNIVEL++  , IMPORT->Data_adto  , "@D"              )
         qrsay ( XNIVEL++  , IMPORT->Valor_adto , "@E 9,999,999.99" )
         qrsay ( XNIVEL++  , IMPORT->DESC_COND  , "@E 99.99"        )
         qrsay ( XNIVEL++  , IMPORT->VL_DESC_C  , "@E 9,999,999.99" )

         qrsay ( XNIVEL++  , IMPORT->DESP_ACESS , "@E 9,999,999.99" )
         qrsay ( XNIVEL++  , IMPORT->OUT_DESP   , "@E 9,999,999.99" )

         qrsay ( XNIVEL++  , IMPORT->PERC_PIS   , "@E 99.99"        )
         qrsay ( XNIVEL++  , IMPORT->VLR_PIS    , "@E 9,999,999.99" )
         qrsay ( XNIVEL++  , IMPORT->PERC_COF   , "@E 99.99"        )
         qrsay ( XNIVEL++  , IMPORT->VLR_COF    , "@E 9,999,999.99" )

         qrsay ( XNIVEL++  , IMPORT->VL_FRETE   , "@E 9,999,999.99" )
         qrsay ( XNIVEL++  , IMPORT->VL_SEGURO  , "@E 9,999,999.99" )

         for nCONT := 1 to 5
             qrsay(XNIVEL++,strzero(aPARCELA[nCONT,1],3))
             qrsay(XNIVEL++,aPARCELA[nCONT,2])
             qrsay(XNIVEL++,aPARCELA[nCONT,3],"@E 9,999,999.99")
         next

         qrsay ( XNIVEL++ , IMPORT->Val_pedido , "@E 999,999,999.99" )
         qrsay ( XNIVEL++ , IMPORT->Val_LIQ , "@E 9,999,999.99" )
         qrsay ( XNIVEL++ , IMPORT->Data_entre                    )
         qrsay ( XNIVEL++ , IMPORT->Data_baixa                    )
         qrsay ( XNIVEL++ , IMPORT->Numero_nf                     )
         qrsay ( XNIVEL++ , IMPORT->Serie                         ) ; SERIE->(dbseek(IMPORT->Serie))
         qrsay ( XNIVEL++ , left(SERIE->Descricao,15)             )
         qrsay ( XNIVEL++ , IMPORT->Especie                       ) ; ESPECIE->(dbseek(IMPORT->Especie))
         qrsay ( XNIVEL++ , left(ESPECIE->Descricao,15)           )
         qrsay ( XNIVEL++ , IMPORT->Data_emiss                    )
         qrsay ( XNIVEL++ , left(IMPORT->Observacao,57)           )
         qwait()
         exit
      endif
   enddo
return

//////////////////////////////////////////////////////////////////////////////////
// PARA INICIAR PARCELAS DO PEDIDO _______________________________________________

static function i_init_parcela

   if PARCELA->(dbseek(IMPORT->Codigo))
      for nCONT := 1 to 5
           aPARCELA[nCONT,1] := PARCELA->Dia
           aPARCELA[nCONT,2] := PARCELA->Data
           aPARCELA[nCONT,3] := PARCELA->Valor
           PARCELA->(dbskip())
           if IMPORT->Codigo <> PARCELA->Cod_ped
              exit
           endif
      next
   else
      return
   endif

   // INICIA VARIAVEIS PARA EDICAO _______________________________________________

   nDIA_1   := aPARCELA[1,1]
   nDIA_2   := aPARCELA[2,1]
   nDIA_3   := aPARCELA[3,1]
   nDIA_4   := aPARCELA[4,1]
   nDIA_5   := aPARCELA[5,1]
   dDATA_1  := aPARCELA[1,2]
   dDATA_2  := aPARCELA[2,2]
   dDATA_3  := aPARCELA[3,2]
   dDATA_4  := aPARCELA[4,2]
   dDATA_5  := aPARCELA[5,2]
   nVALOR_1 := aPARCELA[1,3]
   nVALOR_2 := aPARCELA[2,3]
   nVALOR_3 := aPARCELA[3,3]
   nVALOR_4 := aPARCELA[4,3]
   nVALOR_5 := aPARCELA[5,3]

return

//////////////////////////////////////////////////////////////////////////////////
// GRAVA AS PARCELAS _____________________________________________________________

static function i_grava_parcelas

   do while PARCELA->(dbseek(IMPORT->Codigo))
      PARCELA->(dbdelete())
   enddo

   // OBS. UTILIZADA TAMBEM PARA EXCLUSAO DE LANCAMENTO, QUANDO O VETOR
   // VAI ESTAR VAZIO E NAO VAI ENTRAR NO for ABAIXO...

   for nCONT := 1 to 5

       if empty(aPARCELA[nCONT,2]) ; exit ; endif

       PARCELA->(qappend())

       replace PARCELA->Cod_ped   with IMPORT->Codigo
       replace PARCELA->Dia       with aPARCELA[nCONT,1]
       replace PARCELA->Data      with aPARCELA[nCONT,2]
       replace PARCELA->Valor     with aPARCELA[nCONT,3]

       PARCELA->(dbskip())

   next

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DE PEDIDO __________________________________

static function i_proc_lanc

setcolor("W/B")

if FATCFG->Modelo_fat == "1"
   ITEN_IMP->(qview({{"f204m1()/Cod."                                    ,2},;
                 {"f204d()/Descri‡„o"                                ,0},;
                 {"f204m()/Ref."                                       ,0},;
                 {"transform(Preco,'@E 9,999,999.99999')/Val. Un." ,0},;
                 {"transform(Quant,'@E 999999.99999')/Quant."        ,0},;
                 {"f204e()/Un."                                      ,0},;
                 {"f204c()/Val. Total"                               ,0}},;
                 "15002179S",;
                 {NIL,"f204f",NIL,NIL},;
                 {"ITEN_IMP->Cod_ped==IMPORT->Codigo",{||f204top()},{||f204bot()}},;
                 "<ESC> para pr¢x. tela/ALT-P/<I>nc./<A>lt./<C>on.<E>xc."))
else
   ITEN_IMP->(qview({{"Cod_prod/Cod."                                    ,2},;
                 {"f204d()/Descri‡„o"                                ,0},;
                 {"f204m()/Ref."                                       ,0},;
                 {"transform(Preco,'@E 9,999,999.99999')/Val. Un." ,0},;
                 {"transform(Quant,'@E 999999.99999')/Quant."        ,0},;
                 {"f204e()/Un."                                      ,0},;
                 {"f204c()/Val. Total"                               ,0}},;
                 "15002179S",;
                 {NIL,"f204f",NIL,NIL},;
                 {"ITEN_IMP->Cod_ped==IMPORT->Codigo",{||f204top()},{||f204bot()}},;
                 "<ESC> para pr¢x. tela/ALT-P/<I>nc./<A>lt./<C>on.<E>xc."))

endif
return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IR PARA O INICIO DOS DADOS FILTRADOS _________________________

function f204top
   ITEN_IMP->(dbsetorder(1))
   ITEN_IMP->(dbseek(IMPORT->Codigo))
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IR PARA O FINAL DOS DADOS FILTRADOS __________________________

function f204bot
   ITEN_IMP->(dbsetorder(1))
   ITEN_IMP->(qseekn(IMPORT->Codigo))
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO DE CONTROLE PRINCIPAL ANTES DE PROCESSAR A TECLA ACIONADA _________

function f204d

   local cDESCRICAO := space(15)

   i_totaliza_pedidos()

   qsay ( 22,17 , transform(nTOT_ICM , "@E 999,999.99") )
   qsay ( 22,43 , transform(nTOT_II , "@E 999,999.99") )
   qsay ( 22,68 , transform(nTOT_IPI , "@E 999,999.99") )

   if ! empty(ITEN_IMP->Cod_prod)
      PROD->(dbseek(ITEN_IMP->Cod_prod))
      cDESCRICAO := left(PROD->Descricao,15)
   endif

return cDESCRICAO

function f204m

   local cDESCRICAO := space(8)

   if ! empty(ITEN_IMP->Cod_prod)
      PROD->(dbseek(ITEN_IMP->Cod_prod))
      cDESCRICAO := left(PROD->Cod_fabr,8)
   endif

return cDESCRICAO

function f204m1

   local cDESCRICAO := space(7)

   if ! empty(ITEN_IMP->Cod_prod)
      PROD->(dbseek(ITEN_IMP->Cod_prod))
      cDESCRICAO := left(PROD->Cod_ass,7)
   endif

return cDESCRICAO



/////////////////////////////////////////////////////////////////////////////
// RETORNA O VALOR TOTAL DO PRODUTO _________________________________________

function f204c
return transform((ITEN_IMP->Preco * ITEN_IMP->Quant)+(ITEN_IMP->Preco*ITEN_IMP->Quant*ITEN_IMP->Aliq_ipi/100),"@E 99,999,999.99")

/////////////////////////////////////////////////////////////////////////////
// RETORNA A UNIDADE DO PRODUTO _____________________________________________

function f204e
   PROD->(dbseek(ITEN_IMP->Cod_prod))
   UNIDADE->(dbseek(PROD->Unidade))
return UNIDADE->Sigla

/////////////////////////////////////////////////////////////////////////////
// FUNCAO DE CONTROLE PRINCIPAL ANTES DE PROCESSAR A TECLA ACIONADA _________

function f204f

   local nCURSOR := setcursor(1)
   parameters cOPCAO

   cOPCAO := upper(chr(cOPCAO))
   if cOPCAO $ XUSRA
      qlbloc(09,00,"B204C","QBLOC.GLO",1)
      i_processa_acao()
   endif

   setcursor(nCURSOR)

return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA TOTALIZAR VARIAVEIS DO PEDIDO ________________________________

static function i_totaliza_pedidos

   local nREC := ITEN_IMP->(recno())
   local nALIQ_ICMS := 0
   fVAL_PEDIDO := nTOT_ICM := nTOT_IPI := nTOT_II := 0

   if cOPCAO == "C"
//    fALIQ_ICMS  := IMPORT->Aliq_icms   // foi retirado por causa do calculo de icms/ipi do outro estado
      fVALOR_ADTO := IMPORT->Valor_adto
   endif

   ITEN_IMP->(dbgotop())
   ITEN_IMP->(dbsetorder(1))
   ITEN_IMP->(dbseek(IMPORT->Codigo))

   do while ! ITEN_IMP->(eof()) .and. ITEN_IMP->Cod_Ped == IMPORT->Codigo

      PROD->(dbseek(ITEN_IMP->Cod_Prod))

      if PROD->Prod_iss == "S"
         nTOT_ISS += ITEN_IMP->Quant * ITEN_IMP->Preco
      else
//       nTOT_ICM += ((ITEN_IMP->Quant * ITEN_IMP->Preco) * fALIQ_ICMS)  / 100 // foi retirada por causa do calculo icms/ipi do outro estado
         nTOT_ICM += ((ITEN_IMP->Quant * ITEN_IMP->Base_icms) * ITEN_IMP->Aliq_icms)  / 100
      endif

//    nTOT_IPI += ((ITEN_IMP->Quant * ITEN_IMP->Preco) *  PROD->Ipi) / 100 // foi retirada por causa do calculo icms/ipi do outro estado
      nTOT_IPI += ((ITEN_IMP->Quant * ITEN_IMP->Base_ipi) *  ITEN_IMP->Aliq_ipi) / 100
	  nTOT_II  += ((ITEN_IMP->Quant * ITEN_IMP->Base_ii) *   ITEN_IMP->Aliq_ii) / 100

      fVAL_PEDIDO += ITEN_IMP->Quant * ITEN_IMP->Preco
      //fVAL_LIQ    := fVAL_PEDIDO - fVALOR_ADTO
      fSUB_GRUP   := left(PROD->Codigo,4)

      ITEN_IMP->(dbskip())

   enddo
 //  nTOT_ICM += ( IMPORT->DESP_ACESS * (nALIQ_ICMS/100) )
// fVAL_PEDIDO := fVAL_PEDIDO + nTOT_IPI // foi retirado por causa de calculo de desconto
//   fVAL_PEDIDO := fVAL_PEDIDO  + IMPORT->DESP_ACESS

   ITEN_IMP->(dbgoto(nREC))

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO DE BROWSE _________________________________________________________

//static function i_processa_acao
static function i_processa_acao

   local lCONF
   local nVALOR_LANC := 0
   local aEDICAO := {}
   local bESCAPE := {||empty(fCOD_PROD).or.(XNIVEL==1.and.!XFLAG).or.;
                       (XNIVEL==1.and.lastkey()==27).or.;
                       (XNIVEL==2.and.cOPCAO=="A".and.!XFLAG)}

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"

      XNIVEL := 1
      qrsay ( XNIVEL++ , ITEN_IMP->Cod_prod             , "@R 99999"        ) ; PROD->(dbseek(ITEN_IMP->Cod_prod))
      qrsay ( XNIVEL++ , left(PROD->Descricao,40)                       )
      qrsay ( XNIVEL++ , ITEN_IMP->Preco           , "@E 999,999,999.99999" )
	  qrsay ( XNIVEL++ , ITEN_IMP->Quant              , "@E 999999.99999"   )
	  qrsay ( XNIVEL++ , ITEN_IMP->Preco * ITEN_IMP->Quant  , "@E 9,999,999.99")
	  
	  qrsay ( XNIVEL++ , ITEN_IMP->Base_icms                    , "@E 999,999.99" )
	  qrsay ( XNIVEL++ , ITEN_IMP->Base_Icms * ITEN_IMP->Quant  , "@E 9,999,999.99")
      qrsay ( XNIVEL++ , ITEN_IMP->Aliq_icms                    , "@E 99.99"   )
	  qrsay ( XNIVEL++ , (ITEN_IMP->Base_Icms * ITEN_IMP->Quant) * (ITEN_IMP->Aliq_icms / 100)  , "@E 9,999,999.99")
	  
	  qrsay ( XNIVEL++ , ITEN_IMP->Base_ii                    , "@E 999,999.99" )
	  qrsay ( XNIVEL++ , ITEN_IMP->Base_ii * ITEN_IMP->Quant  , "@E 9,999,999.99")
      qrsay ( XNIVEL++ , ITEN_IMP->Aliq_ii                    , "@E 99.99"   )
	  qrsay ( XNIVEL++ , (ITEN_IMP->Base_ii * ITEN_IMP->Quant) * (ITEN_IMP->Aliq_ii / 100)  , "@E 9,999,999.99")
	  
	  qrsay ( XNIVEL++ , ITEN_IMP->Base_ipi                    , "@E 999,999.99" )
	  qrsay ( XNIVEL++ , ITEN_IMP->Base_ipi * ITEN_IMP->Quant  , "@E 9,999,999.99")
      qrsay ( XNIVEL++ , ITEN_IMP->Aliq_ipi                    , "@E 99.99"   )
	  qrsay ( XNIVEL++ , (ITEN_IMP->Base_ipi * ITEN_IMP->Quant) * (ITEN_IMP->Aliq_ipi / 100)  , "@E 9,999,999.99")

      i_totaliza_pedidos()

      qsay ( 22,16 , transform(nTOT_ICM , "@E 9,999,999.99")            )
      qsay ( 22,41 , transform(nTOT_II  , "@E 9,999,999.99")            )
      qsay ( 22,66 , transform(nTOT_IPI , "@E 9,999,999.99")            )

   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exc_lanc() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || view_prod(-1,0,@fCOD_PROD                 )} ,"COD_PROD"   })
   aadd(aEDICAO,{{ || NIL                                        } ,NIL          })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fPRECO,"@E 999,999,999.99999" )} ,"PRECO"      })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fQUANT,"@E 999999.99999"      )} ,"QUANT"      })
   aadd(aEDICAO,{{ || NIL                                        } ,NIL          })
   
   aadd(aEDICAO,{{ || qgetx(-1,0,@fBASE_ICMS,"@E 999,999.99" )}  ,"BASE_ICMS" })
   aadd(aEDICAO,{{ || NIL                                        } ,NIL          })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fALIQ_ICMS  , "@E 99.99"      )} ,"ALIQ_ICMS"  })
   aadd(aEDICAO,{{ || NIL                                        } ,NIL          })
   
   aadd(aEDICAO,{{ || qgetx(-1,0,@fBASE_II,"@E 999,999.99" )} ,"BASE_II" })
   aadd(aEDICAO,{{ || NIL                                        } ,NIL          })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fALIQ_II  , "@E 99.99"      )} ,"ALIQ_II"  })
   aadd(aEDICAO,{{ || NIL                                        } ,NIL          })
   
   aadd(aEDICAO,{{ || qgetx(-1,0,@fBASE_IPI,"@E 999,999.99" )} ,"BASE_IPI" })
   aadd(aEDICAO,{{ || NIL                                        } ,NIL          })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fALIQ_IPI  , "@E 99.99"      )} ,"ALIQ_IPI"  })
   aadd(aEDICAO,{{ || NIL                                        } ,NIL          })

   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   if cOPCAO == "I"
      qlbloc(09,00,"B204C","QBLOC.GLO",1)
   endif

   ITEN_IMP->(qpublicfields())

   iif(cOPCAO=="I",ITEN_IMP->(qinitfields()),ITEN_IMP->(qcopyfields()))

   XNIVEL := 1
   XFLAG  := .T.

   if cOPCAO == "I"
      fCOD_VEIC := fVEICULOS
      fCOD_EQUIP := fEQUIPTO
   endif

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; ITEN_IMP->(qreleasefields()) ; return ; endif
      if ! i_crit4( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif

   //if cOPCAO == "I"   // pergunta se deseja lancar garantia do produto na inclusao do pedido de compras

      //lGARAN := qconf("Produto tem garantia ?")

      //if lGARAN
      //   save screen
      //   fCOD_FORNEC := fCOD_FORN
      //   fCOD_VEICUL := fVEICULOS
      //   fCOD_EQUIPT := fEQUIPTO
      //   garan(right(fCOD_PROD,5))
      //   select ITEN_IMP
      //   restore screen
      //endif

  // endif

   if IMPORT->(qrlock()) .and. ITEN_IMP->(iif(cOPCAO=="I",qappend(),qrlock()))
      if CONFIG->(qrlock()) .and. cOPCAO == "I"
         replace CONFIG->Cod_lote with CONFIG->Cod_lote+1
         fN_LOTE := strzero(CONFIG->Cod_lote,6)
         CONFIG->(qunlock())
      endif

      if cOPCAO == "I"
         fCOD_PED := fCODIGO
      endif
      ITEN_IMP->(qreplacefields())
      ITEN_IMP->(qunlock())

      i_totaliza_pedidos()

      qsay ( 22,16 , transform(nTOT_ICM , "@E 9,999,999.99") )
      qsay ( 22,41 , transform(nTOT_II , "@E 9,999,999.99") )
      qsay ( 22,66 , transform(nTOT_IPI , "@E 9,999,999.99") )

      cALIQ_ICMS := fALIQ_ICMS
      cALIQ_IPI  := fALIQ_IPI

   else

      iif(cOPCAO=="I",qm1(),qm2())

   endif

return

/////////////////////////////////////////////////////////////////////////////
// CRITICAS NA DESCIDA ______________________________________________________

static function i_crit4 ( cCAMPO )

   qmensa("")

   iif ( cCAMPO == NIL , cCAMPO := "" , NIL )

   do case
      case cCAMPO == "COD_PROD"

           if FATCFG->Modelo_fat == "1"

              PROD->(dbsetorder(5))
              if PROD->(dbseek(fCOD_PROD))
                 fCOD_PROD := right(PROD->Codigo,5)
              else
                 PROD->(dbsetorder(3))
                 if PROD->(dbseek(fCOD_PROD))
                    fCOD_PROD := right(PROD->Codigo,5)
                 endif
              endif

              PROD->(dbsetorder(4))
           endif


           qrsay(XNIVEL,fCOD_PROD := strzero(val(fCOD_PROD),5))

           if ! PROD->(dbseek(fCOD_PROD))
              qmensa("Produto n„o encontrado !","B")
              return .F.
           endif

           if FATCFG->Modelo_fat == "1"
              qrsay ( XNIVEL+1 , left(PROD->Descricao,20)+ "/"+PROD->Cod_ass+" - "+left(PROD->Cod_fabr,6) )
           else
              qrsay ( XNIVEL+1 , left(PROD->Descricao,30) )
           endif

      case cCAMPO == "PRECO"
           if empty(fPRECO) ; return .F. ; endif

      case cCAMPO == "BASE_ICMS"
           qrsay ( XNIVEL+1 , fBASE_ICMS * fQUANT, "@E 9,999,999.99")
		   qrsay ( XNIVEL+3 , (fBASE_ICMS * fQUANT) * (fALIQ_ICMS/100), "@E 9,999,999.99")
		   
	  case cCAMPO == "ALIQ_ICMS"
           qrsay ( XNIVEL+1 , (fBASE_ICMS * fQUANT) * (fALIQ_ICMS/100), "@E 9,999,999.99")
		   
	  case cCAMPO == "BASE_II"
           qrsay ( XNIVEL+1 , fBASE_II * fQUANT, "@E 9,999,999.99")
		   qrsay ( XNIVEL+3 , (fBASE_II * fQUANT) * (fALIQ_II/100), "@E 9,999,999.99")
		   
	  case cCAMPO == "ALIQ_II"
           qrsay ( XNIVEL+1 , (fBASE_II * fQUANT) * (fALIQ_II/100), "@E 9,999,999.99")
		   
	  case cCAMPO == "BASE_IPI"
           qrsay ( XNIVEL+1 , fBASE_IPI * fQUANT, "@E 9,999,999.99")
		   qrsay ( XNIVEL+3 , (fBASE_IPI * fQUANT) * (fALIQ_IPI/100), "@E 9,999,999.99")
		   
	  case cCAMPO == "ALIQ_IPI"
           qrsay ( XNIVEL+1 , (fBASE_IPI * fQUANT) * (fALIQ_IPI/100), "@E 9,999,999.99")


   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXCLUIR LANCAMENTOS DO PEDIDO ________________________________

static function i_exc_lanc

   if qconf("Confirma exclus„o do Lan‡amento ?")

      //MOTI_GAR->(Dbsetorder(3))
      //if MOTI_GAR->(qrlock()) .and. MOTI_GAR->(Dbseek(ITEN_IMP->Cod_ped + ITEN_IMP->Cod_prod))
      //   MOTI_GAR->(Dbdelete())
      //   MOTI_GAR->(qunlock())
      //endif

      if ITEN_IMP->(qrlock())
         ITEN_IMP->(dbdelete())
         ITEN_IMP->(qunlock())
      else
         qm3()
      endif
   endif

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ATUALIZAR LANCAMENTOS NA TELA ________________________________

static function i_atualiza_lancs
if FATCFG->Modelo_fat == "1"
   ITEN_IMP->(qview({{"Cod_prod/Cod."                                     ,2},;
                 {"f204d()/Descri‡„o"                                 ,0},;
                 {"n_lote/Lote"                                       ,0},;
                 {"transform(Preco,'@E 9,999,999.99999')/Val. Un."  ,0},;
                 {"transform(Quant,'@E 999999.99999')/Quant."         ,0},;
                 {"f204e()/Un."                                       ,0},;
                 {"f204c()/Val. Total"                                ,0}},;
                 "15002179S",;
                 {NIL,NIL,NIL,NIL},;
                 {"ITEN_IMP->Cod_ped==IMPORT->Codigo",{||f204top()},{||f204bot()}},;
                 "<ESC> para sair"))
else
   ITEN_IMP->(qview({{"f204m1()/Cod."                                     ,2},;
                 {"f204d()/Descri‡„o"                                 ,0},;
                 {"n_lote/Lote"                                       ,0},;
                 {"transform(Preco,'@E 9,999,999.99999')/Val. Un."  ,0},;
                 {"transform(Quant,'@E 999999.99999')/Quant."         ,0},;
                 {"f204e()/Un."                                       ,0},;
                 {"f204c()/Val. Total"                                ,0}},;
                 "15002179S",;
                 {NIL,NIL,NIL,NIL},;
                 {"ITEN_IMP->Cod_ped==IMPORT->Codigo",{||f204top()},{||f204bot()}},;
                 "<ESC> para sair"))

endif
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IMPRIMIR O PEDIDO ____________________________________________

static function i_imp_pedido  // LAYOUT da Rutgers

   local cLINHA1   :=  replicate("-",78)
   local nVAL_PROD := 0
   local nVAL_IPI  := 0
   local nVAL_ICM  := 0
   local nALIQ_ICMS := 0
   local nVAL_NOTA := 0
   local cAPL

   PROD->(dbsetorder(4))

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif

   qmensa("Emitindo pedido.....")

   // PEGA RAZAO DO CLIENTE ______________________________________________

   FORN->(dbseek(IMPORT->Cod_forn))

   // PEGA ESTADO NO CGM _________________________________________________

   cESTADO := space(2)
   cMUNICIPIO := space(45)

   if CGM->(dbseek(FORN->Cgm_cob))
      cESTADO    := CGM->Estado
      cMUNICIPIO := CGM->Municipio
   endif

   // PEGA DESCRICAO DO GRUPO ____________________________________________

   ITEN_IMP->(dbseek(IMPORT->Codigo))
   PROD->(dbseek(right(ITEN_IMP->Cod_prod,5)))
   CAD_COMP->(dbseek(IMPORT->Comprador))
   FILIAL->(dbseek(IMPORT->Filial))

   setprc(0,0)
   @ prow(),pcol() say XCOND0

   CGM->(dbseek(FILIAL->Cgm))
   @ prow()+1,0  say XAENFAT + left(FILIAL->Razao,40) //+ XDENFAT
   @ prow()+1,0  say alltrim(left(FILIAL->Endereco,36)) + " - CEP " + transform(FILIAL->Cep,"@R 99.999-999") + ;
                   " " + alltrim(left(CGM->Municipio,50)) + " - " + CGM->Estado
   @ prow()+1,0  say "Tel.: " + FILIAL->Telefone + " C.G.C.: " + transform(FILIAL->Cgccpf,"@R 99.999.999/9999-99")

   @ prow()+1,0  say cLINHA1

   @ prow()+1,0  say  padc("PROTOCOLO DE TELEFAX",80)// + XDENFAT
   @ prow()+2,0  say "Fornecedor..: " + left(FORN->Razao,40)  +   " Data: " + dtoc(IMPORT->Data_ped)
   @ prow()+1,0  say "Endereco....: " + left(FORN->End_cob,40) + " Fone: " + FORN->Fone1
   @ prow()+1,0  say "Cidade......: "  + cMUNICIPIO + " - " + cESTADO + "      FAX.:" + FORN->Fax
   @ prow()+1,0  say "Att.........: " + FORN->Contato_c //+ XDENFAT

   @ prow()+1,0  say cLINHA1
   @ prow()+1,0  say  padc("PEDIDO DE COMPRA  No.: " + transform(IMPORT->Codigo,"@R 99999/9999"),80) //+ XDENFAT
   @ prow()+2,0  say "Pedimos fornecer o material abaixo descrito, de acordo com especificacoes  "
   @ prow()+1,0  say "estipuladas na presente ORDEM DE COMPRA.                                   "

   @ prow()+1,0  say cLINHA1
   @ prow()+1,0  say "Codigo    Descricao                  Unid.  Quant.  Preco     Preco     IPI(%)"
   @ prow()+1,0  say "                                                    Unit.     Total           "

   do while ! ITEN_IMP->(eof())
      if ITEN_IMP->Cod_ped == IMPORT->Codigo
         if ! empty(ITEN_IMP->Cod_prod)
            PROD->(dbgotop())
            PROD->(dbseek(right(ITEN_IMP->Cod_prod,5)))

         endif

         nVAL_PROD += ITEN_IMP->Quant * ITEN_IMP->Preco
         nVAL_IPI  += ITEN_IMP->Quant * ITEN_IMP->Preco * ITEN_IMP->Aliq_ipi /100

         if PROD->Prod_iss == "N"
            nVAL_ICM  += ITEN_IMP->Quant * ITEN_IMP->Preco // Soma valor dos produtos para icms
            nALIQ_ICMS := ITEN_IMP->Aliq_icms
         endif

         @ prow(),pcol() say XCOND1

         do case
            case ! empty(ITEN_IMP->Cod_veic)
                 VEICULOS->(dbseek(ITEN_IMP->Cod_veic))
                 cAPL := left(VEICULOS->Descricao,7)
            case ! empty(ITEN_IMP->Cod_equip)
                 EQUIPTO->(dbseek(ITEN_IMP->Cod_equip))
                 cAPL := left(EQUIPTO->Descricao,7)
            case ! empty(ITEN_IMP->Centro)
                 cAPL := left(ITEN_IMP->Centro,7)
         endcase

         @ prow()+1,0 say  left(PROD->Cod_fabr,6)                                                 +;
                          "  "      + left(PROD->Descricao,20)+PROD->Cod_ass+left(PROD->Marca,10) +;
                          "  "      + f204e()                                                     +;
                          "    "      + transform(ITEN_IMP->Quant,"@E 999999.99999")                  +;
                          " "      + transform(ITEN_IMP->Preco , "@E 999,999,999.99")                 +;
                          "   "      + transform(ITEN_IMP->Quant * ITEN_IMP->Preco , "@E 999,999,999.99") +;
                          "        " + transform(ITEN_IMP->Aliq_ipi,"@E 99.99")
         @ prow(),pcol() say XCOND0

      endif
      ITEN_IMP->(dbskip())
   enddo
   nVAL_ICM += IMPORT->Vl_red_ic
   @ prow()+1,0  say  cLINHA1

   PARCELA->(dbseek(IMPORT->Codigo))
   nDESCONTO:= 0
   do while  ! PARCELA->(eof()) .and. PARCELA->Cod_ped == IMPORT->Codigo
      nDESCONTO += PARCELA->Valor
      PARCELA->(dbskip())
   enddo

   nVL_DESCONTO := (nVAL_PROD + nVAL_IPI) - nDESCONTO

   @ prow()+1,0 say " Aliquota do ICMS   Valor do ICMS     Valor do IPI    Valor Total dos Produtos"

   // INICIA ALIQUOTA DE ICMS (EM CASO DE INCLUSAO) ______________________

// if ESTADO->(dbseek(cESTADO))
//    nVAL_ICM :=  ESTADO->Aliq_dest * nVAL_ICM
// endif

   @ prow()+1,0  say  cLINHA1
   @ prow()+1,0 say space(4) + transform(nALIQ_ICMS , "@E 99.99") + space(7) + " " +;
                    transform(nVAL_ICM * (nALIQ_ICMS/100) , "@E 9,999,999.99") + space(5)                + " " +;
                    transform(nVAL_IPI      , "@E 9,999,999.99") + space(4)                + " " +;
                    space(6) +;
                    transform(nVAL_PROD +IMPORT->Vl_red_ic , "@e 9,999,999.99")

   @ prow()+1,0 say cLINHA1
   @ prow()+1,0 say "  DESCONTO......R$: "+Transform(nVL_DESCONTO,"@e 999,999,999.99")+"                Valor Total da Nota    "
   @ prow()+1,0 say "  Prazo de Entrega: " + dtoc(IMPORT->Data_entre) + space(15) + " " + space(6) + transform((nVAL_PROD + nVAL_IPI + IMPORT->Desp_acess)-nVL_DESCONTO, "@E 999,999,999.99") + space(6) + " "
   @ prow()+1,0 say "  Valor em extenso: (" + left(qextenso(nVAL_PROD+nVAL_IPI-nVL_DESCONTO),57) + ")"

   if len(qextenso(nVAL_PROD+nVAL_IPI-nVL_DESCONTO)) > 57
      @ prow()+1,0 say "  " + substr(qextenso( (nVAL_PROD+nVAL_IPI+IMPORT->Desp_acess)-nVL_DESCONTO),58,len(qextenso(nVAL_PROD+nVAL_IPI-nVL_DESCONTO))) + ")"
      @ prow()  ,79 say " "
   endif

   @ prow()+1,0  say cLINHA1
   @ prow()+1,0  say "  Cond. de Pagamento:"
   @ prow()+1,0  say " "
   PARCELA->(dbseek(IMPORT->Codigo))
   nPARCELA := 1
   nDESCONTO:= 0
   do while ! PARCELA->(eof()) .and. PARCELA->Cod_ped == IMPORT->Codigo
      @ prow()+1,0 say "  Parc.: " + strzero(nPARCELA,2) + " - " + strzero(PARCELA->Dia,3) + " Dias - Data Pag.: " + dtoc(PARCELA->Data) + "      Valor: " + transform(PARCELA->Valor,"@E 999,999.99")
      nPARCELA++
      nDESCONTO += PARCELA->Valor
      PARCELA->(dbskip())
   enddo

   @ prow()+1,0  say cLINHA1
   @ prow()+1,0 say "  Importante: Incluir o numero deste Pedido de Compra na sua Nota Fiscal" //+ XDENFAT
   @ prow()+1,0 say "  Observacoes: " + substr(IMPORT->Observacao,1,65)

   @ prow()+1,0 say cLINHA1

   MOTI_GAR->(Dbsetorder(2))

   if MOTI_GAR->(Dbseek(IMPORT->Codigo))
      do while ! MOTI_GAR->(eof()) .and. MOTI_GAR->Pedido == IMPORT->Codigo
         @ prow()+1,0 say "Produto " + MOTI_GAR->Cod_prod + " comprado mesmo com garantia por motivo de : "
         @ prow()+1,0 say alltrim(MOTI_GAR->Descricao) //+ XDENFAT
         MOTI_GAR->(Dbskip())
      enddo
   endif

   ITEN_IMP->(Dbseek(IMPORT->Codigo))

   do while ! ITEN_IMP->(eof()) .and. ITEN_IMP->Cod_ped == IMPORT->Codigo

      if PROD->(Dbseek(ITEN_IMP->Cod_prod)) .and. ! empty(PROD->Garantia)

         GARANTIA->(Dbseek(PROD->Garantia))

         @ prow()+1,0 say "Produto " + PROD->Codigo + " com garantia nr. " + GARANTIA->Codigo + " valida ate: " + dtoc(GARANTIA->Dt_validad)

      endif

      ITEN_IMP->(Dbskip())

   enddo
   @ prow()+2,01 say      "------------------------------  -----------------------   ---------------------"
   @ prow()+1,01 say   padc(alltrim(CAD_COMP->Nome),30) + "    Gerencia Financeira         Gerencia Geral "

   eject

   qstopprn(.F.)

return

 //////////////////////////////////////////////////////////////////////////////////
 // INCLUI FORNECEDOR NO LANCAMENTO DA NOTA FISCAL ________________________________

 static function i_inc_fornec ( fCOD_FORN )

    local nNIVEL  := XNIVEL
    local nORDER  := FORN->(dbsetorder(1))
    local sBLOC   := qsbloc(0,0,24,79)
    local nCURS   := setcursor(1)

    XNIVEL        := 2

    FORN->(qpublicfields())
    FORN->(qinitfields())

    i_inc_f2()

    FORN->(dbsetorder(nORDER))

    XNIVEL := nNIVEL

    setcursor(nCURS)

    if qconf("Confirma inclus„o deste fornecedor ?","B")
       if FORN->(qappend()) .and. CONFIG->(qrlock())
          replace CONFIG->Cod_forn with CONFIG->Cod_forn + 1
          qrsay ( 1 , fCODIGO := strzero(CONFIG->Cod_forn,5) )
          qmensa("C¢digo Gerado: "+fCODIGO,"B")
          cCOD_FORN := fCODIGO
          FORN->(qreplacefields())

          FORN->(qunlock())

          qrbloc(0,0,sBLOC)
          return .T.

       else

          if empty(FORN->Codigo) .and. empty(FORN->Razao) .and. empty(FORN->Cgccpf)
             FORN->(dbdelete())
          endif
          iif(cOPCAO=="I",qm1(),qm2())

       endif
    endif

    qrbloc(0,0,sBLOC)

 return .F.

 //////////////////////////////////////////////////////////////////////////////////
 // FAZ A EDICAO DOS CAMPOS PARA INCLULSAO DO FORNECEDOR __________________________

 static function i_inc_f2

    local aEDICAO := {}
    local bESCAPE := {||empty(fCGCCPF).or.(XNIVEL==1.and.!XFLAG)}

    qlbloc(5,0,"B204D","QBLOC.GLO")

   aadd(aEDICAO,{{ || NIL                                                 },"CODIGO"    })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fCGCCPF       ,"@R 99.999.999/9999-99") },"CGCCPF"    })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fINSCRICAO    ,"@!")                    },"INSCRICAO" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fRAZAO        ,"@!"   ,"!empty(@)",.T.) },"RAZAO"     })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fFANTASIA     ,"@!")                    },"FANTASIA"  })

   aadd(aEDICAO,{{ || qgetx(-1,0,@fEND_ENT      ,"@!")                    },"END_ENT"   })
   aadd(aEDICAO,{{ || view_cgm(-1,0,@fCGM_ENT)                            },"CGM_ENT"   })
   aadd(aEDICAO,{{ || NIL                                                 },NIL         })
   aadd(aEDICAO,{{ || NIL                                                 },NIL         })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fCEP_ENT      ,"@R 99.999-999")         },"CEP_ENT"   })

   aadd(aEDICAO,{{ || qgetx(-1,0,@fEND_COB      ,"@!")                    },"END_COB"   })
   aadd(aEDICAO,{{ || view_cgm(-1,0,@fCGM_COB)                            },"CGM_COB"   })
   aadd(aEDICAO,{{ || NIL                                                 },NIL         })
   aadd(aEDICAO,{{ || NIL                                                 },NIL         })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fCEP_COB      ,"@R 99.999-999")         },"CEP_COB"   })

   aadd(aEDICAO,{{ || qgetx(-1,0,@fFONE1        ,"@!")                    },"FONE1"     })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fRAMAL1       ,"@!")                    },"RAMAL1"    })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fFONE2        ,"@!")                    },"FONE2"     })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fRAMAL2       ,"@!")                    },"RAMAL2"    })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fFAX          ,"@!")                    },"FAX"       })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fFONER        ,"@!")                    },"FONER"     })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fCONTATO_C    ,"@!")                    },"CONTATO_C" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fCONTATO_F    ,"@!")                    },"CONTATO_F" })
   aadd(aEDICAO,{{ || view_filial(-1,0,@fFILIAL)                          },"FILIAL"    })
   aadd(aEDICAO,{{ || NIL                                                 },NIL         })

    do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
       eval ( aEDICAO [XNIVEL,1] )
       if eval ( bESCAPE ) ; FORN->(qreleasefields()) ; return ; endif
       if ! i_crit_2( aEDICAO[XNIVEL,2] ) ; loop ; endif
       iif ( XFLAG , XNIVEL++ , XNIVEL-- )
    enddo

 return

 ////////////////////////////////////////////////////////////////////////////////
 // CRITICAS NA DESCIDA _________________________________________________________

 static function i_crit_2 ( cCAMPO )

    iif ( cCAMPO == NIL , cCAMPO := "" , NIL )

    if ! XFLAG ; return .T. ; endif

    do case
      case cCAMPO == "CODIGO" .and. cOPCAO == "I"

           if FORN->(dbseek(fCODIGO))
              qmensa("Fornecedor j  cadastrado !","B")
              return .F.
           endif

      case cCAMPO == "CGCCPF"

           zTMP := .T.

           qrsay(XNIVEL,fu_conv_cgccpf(fCGCCPF) )
           do case
              case len(alltrim(fCGCCPF)) == 14
                   zTMP := qcheckcgc(fCGCCPF)
              case len(alltrim(fCGCCPF)) == 11
                   zTMP := qcheckcpf(fCGCCPF)
              otherwise
                   zTMP := .F.
           endcase

           if ! zTMP
              qmensa("CGC inv lido !","B")
              return .F.
           endif

           return i_check_cgc_dup()

      case cCAMPO == "CGM_COB"

           if ! CGM->(dbseek(fCGM_COB))
              qmensa("Cgm n„o encontrado !","B")
              return .F.
           endif

           qrsay(XNIVEL+1,CGM->Municipio)
           qrsay(XNIVEL+2,CGM->Estado)

      case cCAMPO == "CGM_ENT"

           if ! CGM->(dbseek(fCGM_ENT))
              qmensa("Cgm n„o encontrado !","B")
              return .F.
           endif

           qrsay(XNIVEL+1,CGM->Municipio)
           qrsay(XNIVEL+2,CGM->Estado)

      case cCAMPO == "CEP_ENT"

           if len(alltrim(fCEP_ENT)) <> 8
              qmensa("C.E.P. incorreto !","B")
              return .F.
           endif

           if cOPCAO == "I"
              fEND_COB := fEND_ENT
              fCGM_COB := fCGM_ENT
              fCEP_COB := fCEP_ENT
           endif

      case cCAMPO == "CEP_COB"

           if len(alltrim(fCEP_COB)) <> 8
              qmensa("C.E.P. incorreto !","B")
              return .F.
           endif

      case cCAMPO == "FILIAL"

           if ! FILIAL->(dbseek(fFILIAL))
              qmensa("Filial n„o encontrado !","B")
              return .F.
           endif

           qrsay(XNIVEL+1,left(FILIAL->Razao,40))

    endcase

 return .T.

/////////////////////////////////////////////////////////////////////////////
// CHECAR CGC DUPLICADO _____________________________________________________

static function i_check_cgc_dup

   local lFLAG, nRESP

   local nRECNO := FORN->(recno())

   local nORDER := FORN->(indexord())

   FORN->(dbsetorder(3)) // muda para cgc...

   lFLAG := FORN->(dbseek(fCGCCPF))

   if fCODIGO == FORN->Codigo
      lFLAG := .F.
   endif

   FORN->(dbsetorder(nORDER)) // retorna ao original...

   if ! lFLAG

      FORN->(dbgoto(nRECNO))

   else

      do while .T.

         nRESP := alert("CGC DUPLICADO !",{"Corrigir","Aceitar","Localizar"})

         do case
            case nRESP == 1
                 FORN->(dbgoto(nRECNO))
                 return .F.
            case nRESP == 2
                 FORN->(dbgoto(nRECNO))
                 return .T.
            case nRESP == 3 // para acionar bESCAPE...
                 XNIVEL := -1
                 return .T.
            otherwise
                 loop
         endcase

      enddo

   endif

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INTERFACE ____________________________________________________

static function i_interface

   // SOMENTE AS AINDA NAO INTERFACEADAS E CONSEGUIU TRAVAR FAT.DBF ______

   local nVAL_BASE := 0
   local nVAL_RED  := 0
   local cFATOR    := 1
   fu_abre_apcom()
   fu_abre_ficom()
   fu_abre_cpest()
   fu_abre_conta()
   fu_abre_lotes()
   fu_abre_proct()

   if ! IMPORT->Interface .and. IMPORT->(qrlock())

      if IMPORT->Estoque == "S"

         ITEN_IMP->(Dbseek(IMPORT->Codigo))

         do while ! ITEN_IMP->(eof()) .and. ITEN_IMP->Cod_ped == IMPORT->Codigo

            INVENT->(Dbsetorder(1))  // atualiza inventario............................
            PROD->(dbsetorder(4))
            if PROD->(dbseek(ITEN_IMP->Cod_prod)) .and. PROD->(qrlock())
               replace PROD->Preco_cust with ITEN_IMP->Preco
               PROD->(Qunlock())
            endif

            if INVENT->(qrlock()) .and. INVENT->(Dbseek(alltrim(IMPORT->Filial)+ITEN_IMP->Cod_prod+ITEN_IMP->Lote))
               INVENT->(qrlock())
               replace INVENT->Quant_atu with ( INVENT->Quant_atu +  (ITEN_IMP->Quant*ITEN_IMP->Fator) )

               INVENT->(qunlock())

            else
               if INVENT->(qrlock()) .and. INVENT->(qappend())

                   replace INVENT->Data       with IMPORT->Data_ped
                   replace INVENT->Filial     with IMPORT->Filial
                   replace INVENT->Cod_prod   with ITEN_IMP->Cod_prod
                   replace INVENT->Quantidade with (ITEN_IMP->Quant*ITEN_IMP->Fator)
                   replace INVENT->Val_invent with ITEN_IMP->Preco
                   replace INVENT->Lote       with ITEN_IMP->Lote
                   replace INVENT->Quant_atu  with (ITEN_IMP->Quant*ITEN_IMP->Fator)
                   replace INVENT->Preco_uni  with ITEN_IMP->Preco

                   INVENT->(qunlock())
               endif

            endif

            if SH_CPEST->(qappend())

               replace SH_CPEST->Data       with IMPORT->Data_ped
               replace SH_CPEST->Filial     with IMPORT->Filial
               replace SH_CPEST->Cod_prod   with ITEN_IMP->Cod_prod
               replace SH_CPEST->Quantidade with val(transform(ITEN_IMP->Quant*ITEN_IMP->Fator,"@R 999999.99999"))
               replace SH_CPEST->Lote       with ITEN_IMP->LOTE
               replace SH_CPEST->Val_uni    with ITEN_IMP->Preco / ITEN_IMP->Fator
               replace SH_CPEST->Tipo       with "E"

            endif

// ATUALIZACAO DO ARQUIVO LOTES...............

            if LOTES->(dbseek(ITEN_IMP->Cod_prod+alltrim(IMPORT->Filial)+ITEN_IMP->Lote)) .and. LOTES->(qrlock())
               Replace LOTES->Quantidade With (LOTES->Quantidade + ITEN_IMP->Quant)
               LOTES->(qunlock())
            Else
               if LOTES->(qappend())
                  Replace LOTES->Data       with IMPORT->Data_ped
                  Replace LOTES->Produto    with ITEN_IMP->Cod_prod
                  Replace LOTES->Filial     with IMPORT->Filial
                  Replace LOTES->Quantidade with ITEN_IMP->Quant
                  Replace LOTES->Num_lote   with ITEN_IMP->Lote
               Endif
            Endif

            ITEN_IMP->(Dbskip())

         enddo

      endif

      // ATUALIZA FLAG DE INTERFACEAMENTO ________________________________

      replace IMPORT->Interface with .T.

      PARCELA->(Dbsetorder(1))
      PARCELA->(Dbseek(IMPORT->Codigo))

      do while ! PARCELA->(eof()) .and. PARCELA->Cod_ped == IMPORT->Codigo

         if SH_APCOM->(qappend())

            replace SH_APCOM->Data_lanc    with IMPORT->Data_ped
            replace SH_APCOM->Cod_forn     with IMPORT->Cod_forn
            replace SH_APCOM->Centro       with left(IMPORT->Centro,4)
            replace SH_APCOM->Filial       with left(IMPORT->Filial,4)
            replace SH_APCOM->Data_emiss   with IMPORT->Data_emiss
            replace SH_APCOM->Especie      with IMPORT->Especie
            replace SH_APCOM->Serie        with IMPORT->Serie
            replace SH_APCOM->Tipo_sub     with IMPORT->Tipo
            replace SH_APCOM->Historico    with IMPORT->Observacao

            replace SH_APCOM->Data_venc    with PARCELA->Data
            replace SH_APCOM->Valor        with PARCELA->Valor
            replace SH_APCOM->Valor_liq    with PARCELA->Valor

            replace SH_APCOM->Fatura       with IMPORT->Numero_nf
            replace SH_APCOM->Cgm          with "041000"
            replace SH_APCOM->Cod_veic     with IMPORT->Veiculos
            replace SH_APCOM->Cod_eqpto    with IMPORT->Equipto
            replace SH_APCOM->Fornec       with IMPORT->Fornecedor

         endif

         PARCELA->(dbskip())

      enddo

   endif

   if ! IMPORT->Fiscal .and. IMPORT->(qrlock())

      if SH_FICOM->(qappend())

         // ATUALIZA FLAG DE INTERFACIAMENTO ________________________________

         replace IMPORT->Fiscal with .T.

         replace SH_FICOM->Data_lanc  with IMPORT->Data_baixa
         replace SH_FICOM->Filial     with alltrim(IMPORT->Filial)
         replace SH_FICOM->Num_nf     with IMPORT->Numero_nf
         replace SH_FICOM->Especie    with IMPORT->Especie
         replace SH_FICOM->Serie      with IMPORT->Serie
         replace SH_FICOM->Data_emis  with IMPORT->Data_emiss
         replace SH_FICOM->Cod_forn   with IMPORT->Cod_forn
         replace SH_FICOM->Vlr_cont   with IMPORT->Val_liq
         replace SH_FICOM->Cod_fisc   with IMPORT->Cod_fisc
         replace SH_FICOM->Cfop       with IMPORT->Cfop

         if IMPORT->Red_icms == 0
            replace SH_FICOM->Icm_base   with nVAL_BASE := IMPORT->Val_liq
         else
            replace SH_FICOM->Icm_base   with nVAL_BASE := IMPORT->Val_liq - ((IMPORT->Val_liq * IMPORT->Red_icms)/100)
         endif

         replace SH_FICOM->Icm_red    with IMPORT->Red_icms

         replace SH_FICOM->Icm_aliq   with IMPORT->Aliq_icms

         replace SH_FICOM->Icm_vlr    with IMPORT->Valor_icm

         replace SH_FICOM->Icm_isen   with IMPORT->Val_liq - nVAL_BASE

         replace SH_FICOM->Icm_out    with IMPORT->Val_liq - nVAL_BASE - SH_FICOM->Icm_isen

         do case
            case SH_FICOM->Icm_isen <> 0
                 replace SH_FICOM->Icm_cod    with "4"
            case SH_FICOM->Icm_out <> 0
                 replace SH_FICOM->Icm_cod    with "9"
            otherwise
                 replace SH_FICOM->Icm_cod    with "0"
         endcase

         ITEN_IMP->(dbseek(IMPORT->Codigo))
         PROD->(dbseek(ITEN_IMP->Cod_prod))

         replace SH_FICOM->Ipi_vlr    with IMPORT->Valor_ipi

         if SH_FICOM->Ipi_vlr <> 0
            replace SH_FICOM->Ipi_base   with IMPORT->Val_pedido
         else
            replace SH_FICOM->Ipi_isen   with IMPORT->Val_pedido
         endif

         if SH_FICOM->Ipi_isen <> 0
            replace SH_FICOM->Ipi_out    with IMPORT->Val_pedido
         endif

      endif

   endif

   if ! IMPORT->Contabil .and. IMPORT->(qrlock())

      if SH_CONTA->(qappend())

         // ATUALIZA FLAG DE INTERFACEAMENTO ________________________________


         replace SH_CONTA->Codigo     with IMPORT->Cod_forn
         replace SH_CONTA->Num_nota   with IMPORT->Numero_nf
         replace SH_CONTA->Data_lanc  with IMPORT->Data_baixa
         replace SH_CONTA->Serie      with IMPORT->Serie
         FORN->(dbsetorder(1))
         FORN->(dbseek(IMPORT->Cod_forn))
         replace SH_CONTA->Ca         with FORN->Razao
         replace SH_CONTA->Cgc        with FORN->Cgccpf
         replace SH_CONTA->Dp         with IMPORT->Numero_nf
         ESPECIE->(dbseek(IMPORT->Especie))
         replace SH_CONTA->Ep         with ESPECIE->Descricao
         replace SH_CONTA->Fa         with IMPORT->Numero_nf
         replace SH_CONTA->Nf         with IMPORT->Numero_nf
         replace SH_CONTA->Pc         with IMPORT->Codigo
         SERIE->(dbseek(IMPORT->Serie))
         replace SH_CONTA->Se         with SERIE->Descricao

      endif

      if TIPOCONT->(dbseek(IMPORT->Tipo)) //.and. TIPOCONT->Regime_ope == "2"
         replace IMPORT->Contabil with .T.

         if SH_PROCT->(qappend())

            replace SH_PROCT->Data_lanc   with  IMPORT->Data_baixa

            if TIPOCONT->Regime_ope == "2" // Regime de competencia

               nHISTORICO := TIPOCONT->Hist_l_pr

               if TIPOCONT->Cont_pr_dv == "1"
                  replace SH_PROCT->Cont_db with TIPOCONT->Ct_ct_p_dv
               else
                  FORN->(dbseek(IMPORT->Cod_forn))
                  replace SH_PROCT->Cont_db with FORN->Conta_cont
               endif

               if TIPOCONT->Cont_pr_cr == "1"
                  replace SH_PROCT->Cont_cr with TIPOCONT->Ct_ct_p_cr
               else
                  FORN->(dbseek(IMPORT->Cod_forn))
                  replace SH_PROCT->Cont_cr with FORN->Conta_cont
               endif

            else // regime de caixa

               nHISTORICO := TIPOCONT->Hist_l_pr

               if TIPOCONT->Conta_liq == "1"
                  replace SH_PROCT->Cont_db with TIPOCONT->Ct_ct_liq
               else
                  FORN->(dbseek(IMPORT->Cod_forn))
                  replace SH_PROCT->Cont_db with FORN->Conta_cont
               endif

               if TIPOCONT->Conta_l2 == "1"
                  replace SH_PROCT->Cont_cr with TIPOCONT->Ct_ct_l2
               else
                  FORN->(dbseek(IMPORT->Cod_forn))
                  replace SH_PROCT->Cont_cr with FORN->Conta_cont
               endif

            endif

            replace SH_PROCT->Filial     with  IMPORT->Filial

            replace SH_PROCT->Valor      with  IMPORT->Val_pedido
            replace SH_PROCT->Num_doc    with  IMPORT->Numero_nf
            replace SH_PROCT->Num_lote   with  "CP" + XUSRNUM + strzero(CONFIG->Num_lote,5) // monta numero do lote
            replace SH_PROCT->Cod_hist   with nHISTORICO

            monta_hist("PEDIDO",nHISTORICO)

            if CONFIG->(qrlock())
               replace CONFIG->Num_lote with (CONFIG->Num_lote + 1)
               CONFIG->(qunlock())
            endif

         endif

      endif


   endif

   SH_APCOM->(qunlock())
   SH_APCOM->(dbclosearea())

   SH_FICOM->(qunlock())
   SH_FICOM->(dbclosearea())

   SH_CPEST->(qunlock())
   SH_CPEST->(dbclosearea())

   SH_CONTA->(qunlock())
   SH_CONTA->(dbclosearea())

   SH_PROCT->(qunlock())
   SH_PROCT->(dbclosearea())

   IMPORT->(qunlock())

   LOTES->(qunlock())
   LOTES->(dbclosearea())
return


/////////////////////////////////////////////////////////////////////////////
// LANCAMENTO DE GARANTIAS DENTRO DO PEDIDO DE COMPRAS  _____________________

static function garan

   local lCONF
   local aEDICAO := {}
   local bESCAPE := {||(XNIVEL==1.and.!XFLAG).or.;
                       (XNIVEL==1.and.lastkey()==27)}

   private fCOD        := space(5)
   private fDT_COMPRA  := ctod("")
   private fNR_GARANTI := space(7)
   private fDIAS_GARAN := space(3)
   private fDT_VALIDAD := ctod("")
   private fKILOMETRAG := 0

   qlbloc(07,1,"B204F","QBLOC.GLO",1)

   PROD->(Dbsetorder(4))

   aadd(aEDICAO,{{ || NIL                                           },"COD_PRODUT" })
   aadd(aEDICAO,{{ || NIL                                           },NIL          })
   aadd(aEDICAO,{{ || view_forn1(10,15,@fCOD_FORNEC)                },"COD_FORNEC" })
   aadd(aEDICAO,{{ || NIL                                           },NIL          })
   aadd(aEDICAO,{{ || view_veic(11,15,@fCOD_VEICUL)                 },"COD_VEICUL" })
   aadd(aEDICAO,{{ || NIL                                           },NIL          })
   aadd(aEDICAO,{{ || view_equip(12,15,@fCOD_EQUIPT)                },"COD_EQUI"   })
   aadd(aEDICAO,{{ || NIL                                           },NIL          })
   aadd(aEDICAO,{{ || qgetx(13,18,@fDT_COMPRA,"@D")                 },"DT_COMPR"   })
   aadd(aEDICAO,{{ || qgetx(13,44,@fNR_GARANTI,"@!")                },"NR_GARAN"   })
   aadd(aEDICAO,{{ || qgetx(13,74,@fDIAS_GARAN,"@!")                },"DIAS_GAR"   })
   aadd(aEDICAO,{{ || qgetx(14,18,@fDT_VALIDAD,"@D")                },"DT_VALID"   })
   aadd(aEDICAO,{{ || qgetx(14,69,@fKILOMETRAG,"99999999")          },"KILOMETR"   })

   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO ____________________________________________________

   XNIVEL := 1
   XFLAG := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE );GARANTIA->(qreleasefields());return;endif
      if ! i_crit( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
      qmensa("")
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif

   if GARANTIA->(iif(cOPCAO=="I",qappend(),qrlock()))

      // AQUI INCREMENTA CODIGO DA GARANTIA  _______________________________

      if cOPCAO == "I" .and. quse(XDRV_FT,"CONFIG",NIL,NIL,"PROV")
         if PROV->(qrlock())
            replace PROV->Cod_gara with PROV->Cod_gara+1
            qmensa("C¢digo Gerado: "+strzero(PROV->Cod_gara,5),"B")
            fCOD := strzero(PROV->Cod_gara,5)
         endif
         PROV->(Dbclosearea())
      endif

      // AGORA GRAVA E DESTRAVA ARQUIVO _____________________________________

      if PROD->(Dbseek(right(fCOD_PROD,5))) .and. PROD->(qrlock())  // grava numero da garantia no produto
         replace PROD->Garantia with fCOD
         PROD->(qunlock())
      endif

      replace GARANTIA->Codigo      with fCOD
      replace GARANTIA->Cod_produt  with fCOD_PROD
      replace GARANTIA->Cod_fornec  with fCOD_FORNEC
      replace GARANTIA->Cod_veicul  with fCOD_VEICUL
      replace GARANTIA->Cod_equipt  with fCOD_EQUIPT
      replace GARANTIA->Dt_compra   with fDT_COMPRA
      replace GARANTIA->Nr_garanti  with fNR_GARANTI
      replace GARANTIA->Dias_garan  with fDIAS_GARAN
      replace GARANTIA->Dt_validad  with fDT_VALIDAD
      replace GARANTIA->Kilometrag  with fKILOMETRAG

   else
      iif(cOPCAO=="I",qm1(),qm2())
   endif

   if cOPCAO == "I" ; keyboard "I" ; endif

//   CONTAB->(Dbclosearea())
  // FATCFG->(DbCloseArea())
return

/////////////////////////////////////////////////////////////////////////////////
// CRITICAS NA DESCIDA __________________________________________________________

static function i_crit ( cCAMPO )

   qmensa("")

   iif ( cCAMPO == NIL , cCAMPO := "" , NIL )
   if ! XFLAG ; return .T. ; endif

   do case

      case cCAMPO == "COD_PRODUT"

           PROD->(Dbsetorder(4))

           qsay(09,15,fCOD_PROD)

           if ! PROD->(dbseek(right(fCOD_PROD,5)))
              qmensa("Produto n„o encontrado !","B")
              return .F.
           endif

           qsay (09,27, left(PROD->Descricao,40) )

      case cCAMPO == "COD_FORNEC"
           if empty(fCOD_FORNEC) ; return .F. ; endif
           fCOD_FORNEC:=strzero(val(fCOD_FORNEC),5)
           qsay(10,15,fCOD_FORNEC)
           if ! FORN->(dbseek(fCOD_FORNEC))
              qmensa("Fornecedor n„o encontrado !","B")
              return .F.
           endif

           qsay(10,23,left(FORN->Razao,54))

      case cCAMPO == "COD_VEICUL"
           fCOD_VEICUL:=strzero(val(fCOD_VEICUL),5)
           qsay(11,15,fCOD_VEICUL)
           if VEICULOS->(dbseek(fCOD_VEICUL))
              qsay(11,23,VEICULOS->Descricao)
           endif

      case cCAMPO == "COD_EQUIPT"
           fCOD_EQUIPT:=strzero(val(fCOD_EQUIPT),5)
           qsay(12,15,fCOD_EQUIPT)
           if EQUIPTO->(dbseek(fCOD_EQUIPT))
              qsay(12,23,EQUIPTO->Descricao)
           endif

      case cCAMPO == "DT_COMPRA"
           if empty(fDT_COMPRA) ; return .F. ; endif

      case cCAMPO == "DIAS_GAR"
           if empty(fDIAS_GARAN) ; return .F. ; endif
           fDT_VALIDAD:= fDT_COMPRA + val(fDIAS_GARAN)

   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IMPRIMIR O PROTOCOLO _________________________________________

static function i_imp_protocolo

   local cPIC    := "@E 999,999.99"
   local cTITULO := "PROTOCOLOS DE NOTAS PARA CONTAS A PAGAR"
   local nREC    := IMPORT->(recno())

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif
   
   IMPORT->(dbgotop())

   IMPORT->(dbsetorder(9))

   IMPORT->(dbseek("*"))

   do while ! IMPORT->(eof()) .and. qcontprn()

      if ! qlineprn() ; exit ; endif

      qgirabarra()

      qmensa("Imprimindo os Protocolos......")

      if XPAGINA == 0 .or. prow() > K_MAX_LIN
         @ prow(),pcol() say XCOND0
         qpageprn()
         qcabecprn(cTITULO,80)
         @ prow()+1,00 say "PEDIDO    N. FISCAL   FORNECEDOR                                     VALOR"
         @ prow()+1,00 say replicate("-",80)
      endif

      if IMPORT->Protocolo == "*"
         FORN->(dbseek(IMPORT->Cod_forn))
         @ prow()+1,00 say transform(IMPORT->Codigo,"@R 99999/9999") + "  " +;
                           IMPORT->Numero_nf + "    " +;
                           left(FORN->Razao,40) + "  " +;
                           transform(IMPORT->Val_pedido,cPIC)
      endif

      IMPORT->(dbskip())

   enddo

   IMPORT->(dbsetorder(2))

   IMPORT->(dbgoto(nREC))

   qstopprn()

return


/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA LIMPAR A MARCACAO DE  PROTOCOLO ______________________________

static function i_limpa_protocolo

   IMPORT->(dbsetorder(9))

   IMPORT->(dbgotop())

   IMPORT->(dbseek("*"))

   do while ! IMPORT->(eof())
      qmensa("Limpando a marca‡„o do Pedido: " + transform(IMPORT->Codigo,"@R 99999/9999"))
      if IMPORT->(qflock())
         replace IMPORT->Protocolo with " "
      else
         qm2()
      endif
      IMPORT->(dbskip())
   enddo

   IMPORT->(qunlock())

   IMPORT->(dbsetorder(2))

   IMPORT->(dbgoto(nREC))

return
// FUNCAO DE IMPRESAO DE PEDIDO POR CODIGO DO PRODUTO _______________________
static function i_imp_ped_a()

   local cLINHA1   := "*" + replicate("-",78) + "*"
   local nVAL_PROD := 0
   local nVAL_IPI  := 0
   local nVAL_ICM  := 0
   local nALIQ_ICMS := 0
   local nVAL_NOTA := 0
   local cAPL

   PROD->(dbsetorder(4))

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif

   qmensa("Emitindo pedido.....")

   // PEGA RAZAO DO CLIENTE ______________________________________________

   FORN->(dbseek(IMPORT->Cod_forn))

   // PEGA ESTADO NO CGM _________________________________________________

   cESTADO    := space(2)
   cMUNICIPIO := space(45)

   if CGM->(dbseek(FORN->Cgm_cob))
      cESTADO    := CGM->Estado
      cMUNICIPIO := CGM->Municipio
   endif

   // PEGA DESCRICAO DO GRUPO ____________________________________________

   ITEN_IMP->(dbseek(IMPORT->Codigo))
   PROD->(dbseek(right(ITEN_IMP->Cod_prod,5)))
   CAD_COMP->(dbseek(IMPORT->Comprador))
   FILIAL->(dbseek(IMPORT->Filial))

   setprc(0,0)

   @ prow()+1,0  say cLINHA1
   @ prow()+1,0  say "|" + XAEXPAN + XAENFAT + "PEDIDO DE COMPRA  No.: " + transform(IMPORT->Codigo,"@R 99999/9999") + XDEXPAN + XDENFAT + "|"
   @ prow()+1,0  say "| Data do Pedido: " + dtoc(IMPORT->Data_ped) + "   Baixa em " + dtoc(IMPORT->Data_baixa) + space(29) + "|"
   @ prow()+1,0  say "| Comprador: " + CAD_COMP->Nome + space(36) + "|"
   @ prow()+1,0  say cLINHA1
   @ prow()+1,0  say "|Fornecedor..: " + left(FORN->Razao,40) +   " Contato: " + left(FORN->Contato_c,14) + "|"
   @ prow()+1,0  say "|Endereco....: " + left(FORN->End_cob,40) + " Fone...: " + FORN->Fone1 +  "|"
   @ prow()+1,0  say "|Cidade......: "  + cMUNICIPIO + " Estado: " + cESTADO + " Cep...: " + transform(FORN->Cep_cob,"@R 99.999-999") + "    |"
   @ prow()+1,0  say cLINHA1
   @ prow()+1,0  say "| Dados do Faturamento (Nosso Estabelecimento)" + space(33) + "|"
   @ prow()+1,0  say "| --------------------------------------------" + space(33) + "|"
   @ prow()+1,0  say "| Filial.....: " + left(FILIAL->Razao,40) + space(24) + "|"
   @ prow()+1,0  say "| Endereco...: " + left(FILIAL->Endereco,36) + " C.G.C.: " + transform(FILIAL->Cgccpf,"@R 99.999.999/9999-99") + " |"
   CGM->(dbseek(FILIAL->Cgm))
   @ prow()+1,0  say "| Cidade.....: " + left(CGM->Municipio,15) + " U.F.: " + CGM->Estado + "   Inscricao: " + FILIAL->Insc_estad + space(11) + "|"

   @ prow()+1,0  say cLINHA1 + XAENFAT
   @ prow()+1,0  say "| Cond. de Pagamento:" + space(58) + "|"
   @ prow()+1,0  say "| -------------------" + space(58) + "|"
   PARCELA->(dbseek(IMPORT->Codigo))
   nPARCELA := 1
   nDESCONTO:= 0
   do while ! PARCELA->(eof()) .and. PARCELA->Cod_ped == IMPORT->Codigo
      @ prow()+1,0 say "| Parc.: " + strzero(nPARCELA,2) + " - " + strzero(PARCELA->Dia,3) + " Dias - Data Pag.: " + dtoc(PARCELA->Data) + " Valor: " + transform(PARCELA->Valor,"@E 999,999.99") + space(15) + "|"
      nPARCELA++
      nDESCONTO += PARCELA->Valor
      PARCELA->(dbskip())
   enddo

   @ prow()+1,0  say XDENFAT + cLINHA1
   @ prow()+1,0  say "| Nota Fiscal: " + IMPORT->Numero_nf + " Serie: " + IMPORT->Serie + " Especie: " + IMPORT->Especie + space(36) + "|"
   @ prow()+1,0  say cLINHA1

   @ prow()+1,0  say "|   Pedimos fornecer o material abaixo descrito, de acordo com especificacoes  |"
   @ prow()+1,0  say "| estipuladas na presente ORDEM DE COMPRA.                                     |"


   @ prow()+1,0  say cLINHA1
   @ prow()+1,0  say "|Cod.|          Descricao       | APL.|  Qnt.  |   Valor  |  Valor  |IPI|      |"
   @ prow()+1,0  say "|    |                          |     |        |   Unit.  |  Total  | % |  IPI |"
   @ prow()+1,0  say cLINHA1
   do while ! ITEN_IMP->(eof())
      if ITEN_IMP->Cod_ped == IMPORT->Codigo
         if ! empty(ITEN_IMP->Cod_prod)
            PROD->(dbgotop())
            PROD->(dbseek(right(ITEN_IMP->Cod_prod,5)))
         endif

         nVAL_PROD += ITEN_IMP->Quant * ITEN_IMP->Preco
         nVAL_IPI  += ITEN_IMP->Quant * ITEN_IMP->Preco * ITEN_IMP->Aliq_ipi /100

         if PROD->Prod_iss == "N"
            nVAL_ICM  += ITEN_IMP->Quant * ITEN_IMP->Preco * ITEN_IMP->Aliq_icms  // Soma valor dos produtos para icms
            nALIQ_ICMS := ITEN_IMP->Aliq_icms
         endif

         @ prow(),pcol() say XCOND1

         do case
            case ! empty(ITEN_IMP->Cod_veic)
                 VEICULOS->(dbseek(ITEN_IMP->Cod_veic))
                 cAPL := left(VEICULOS->Descricao,7)
            case ! empty(ITEN_IMP->Cod_equip)
                 EQUIPTO->(dbseek(ITEN_IMP->Cod_equip))
                 cAPL := left(EQUIPTO->Descricao,7)
            case ! empty(ITEN_IMP->Centro)
                 cAPL := left(ITEN_IMP->Centro,7)
         endcase

         @ prow()+1,0 say "|  " + right(PROD->Codigo,5)                                 +;
                          " |"  + left(PROD->Descricao,45)                              +;
                          "| "  + cAPL                                                  +;
                          " | "  + transform(ITEN_IMP->Quant,"@E 999999.99999")                     +;
                          " | " + transform(ITEN_IMP->Preco , "@E 999,999,999.99999")                 +;
                          " | " + transform(ITEN_IMP->Quant * ITEN_IMP->Preco , "@E 999,999,999.99") +;
                          " | " + transform(ITEN_IMP->Aliq_ipi,"@E 99.99")                       +;
                          " | " + transform((ITEN_IMP->Quant * ITEN_IMP->Preco * ITEN_IMP->Aliq_ipi /100) , "@E 99,999.99") + "|"

         @ prow(),pcol() say XCOND0

      endif
      ITEN_IMP->(dbskip())
   enddo

   nVL_DESCONTO := (nVAL_PROD + nVAL_IPI) - nDESCONTO

   @ prow()+1,0 say cLINHA1
   @ prow()+1,0 say "|Aliquota do ICMS|  Valor do ICMS  |  Valor do IPI  |  Valor Total dos Produtos|"

   // INICIA ALIQUOTA DE ICMS (EM CASO DE INCLUSAO) ______________________

// if ESTADO->(dbseek(cESTADO))
//    nVAL_ICM :=  ESTADO->Aliq_dest * nVAL_ICM
// endif

   @ prow()+1,0 say "|"  + space(4) + transform(nALIQ_ICMS , "@E 99.99") + space(7) + "|" +;
                    transform(nVAL_ICM /100 , "@E 9,999,999.99") + space(5)                + "|" +;
                    transform(nVAL_IPI      , "@E 9,999,999.99") + space(4)                + "|" +;
                    space(6) +;
                    transform(nVAL_PROD     , "@e 9,999,999.99") + space(8)                + "|"

   @ prow()+1,0 say cLINHA1
   @ prow()+1,0 say "| D.e.s.c.o.n.t.o. ....R$: "+Transform(nVL_DESCONTO,"@e 999,999,999.99")+"           |    Valor Total da Nota   |"
   @ prow()+1,0 say "| Suposta Data de Entrega: " + dtoc(IMPORT->Data_entre) + space(15) + "|" + space(6) + transform((nVAL_PROD + nVAL_IPI)-nVL_DESCONTO, "@E 999,999,999.99") + space(6) + "|"
   @ prow()+1,0 say "| Valor em extenso: (" + left(qextenso(nVAL_PROD+nVAL_IPI-nVL_DESCONTO),57) + ")"
   @ prow()  ,79 say "|"

   if len(qextenso(nVAL_PROD+nVAL_IPI-nVL_DESCONTO)) > 57
      @ prow()+1,0 say "| " + substr(qextenso(nVAL_PROD+nVAL_IPI-nVL_DESCONTO),58,len(qextenso(nVAL_PROD+nVAL_IPI-nVL_DESCONTO))) + ")"
      @ prow()  ,79 say "|"
   endif

   @ prow()+1,0 say cLINHA1
   @ prow()+1,0 say "| Observacao: " + substr(IMPORT->Observacao,1,65) + "|"
   @ prow()+1,0 say "|" + space(13) + substr(IMPORT->Observacao,66,65) + "|"
   @ prow()+1,0 say "|" + space(13) + substr(IMPORT->Observacao,131,65) + "|"
   @ prow()+1,0 say "|" + space(13) + substr(IMPORT->Observacao,196,65) + space(20) + "|"
   @ prow()+1,0 say cLINHA1

   MOTI_GAR->(Dbsetorder(2))

   if MOTI_GAR->(Dbseek(IMPORT->Codigo))
      do while ! MOTI_GAR->(eof()) .and. MOTI_GAR->Pedido == IMPORT->Codigo
         @ prow()+1,0 say XAENFAT + "Produto " + MOTI_GAR->Cod_prod + " comprado mesmo com garantia por motivo de : "
         @ prow()+1,0 say alltrim(MOTI_GAR->Descricao) + XDENFAT
         MOTI_GAR->(Dbskip())
      enddo
   endif

   ITEN_IMP->(Dbseek(IMPORT->Codigo))

   do while ! ITEN_IMP->(eof()) .and. ITEN_IMP->Cod_ped == IMPORT->Codigo

      if PROD->(Dbseek(ITEN_IMP->Cod_prod)) .and. ! empty(PROD->Garantia)

         GARANTIA->(Dbseek(PROD->Garantia))

         @ prow()+1,0 say XAENFAT + "Produto " + PROD->Codigo + " com garantia nr. " + GARANTIA->Codigo + " valida ate: " + dtoc(GARANTIA->Dt_validad)

      endif

      ITEN_IMP->(Dbskip())

   enddo

   @ prow()+6,03 say "----------------------------                    ----------------------------"
   @ prow()+1,03 say "  ASSINATURA DO COMPRADOR                          ASSINATURA DIRETORIA     "

   eject

   qstopprn(.F.)

return

////////////////////////////////////////////////////////////////////////////////
// FUNCAO UTILIZADA PARA A SELECAO DOS MNEUMONICOS DO HISTORICO ________________
static function monta_hist(cARQ,cHIST)

HIST->(dbseek(cHIST))
nHIST := HIST->Descricao

for nCONT := 1 to len(nHIST)
    if ( nPOS := at("[",nHIST) )  <> 0
       nPOS += 2  // para ignorar os simbolos [@
       FORN->(dbgotop())
       do case
          case substr(nHIST,nPOS,2) == "CA"
               FORN->(Dbseek((cARQ)->Cod_forn))
               replace SH_PROCT->Ca with left(FORN->Razao,40)
          case substr(nHIST,nPOS,3) == "CGC"
               FORN->(Dbseek((cARQ)->Cod_forn))
               replace SH_PROCT->Cgc with FORN->Cgccpf
          case substr(nHIST,nPOS,2) == "DA"
               replace SH_PROCT->Da with XDATSYS
          case substr(nHIST,nPOS,2) == "DP" .or. substr(nHIST,nPOS,2) == "FA" .or. substr(nHIST,nPOS,2) == "NF"
               replace SH_PROCT->Dp with IMPORT->Numero_nf
               replace SH_PROCT->Fa with IMPORT->Numero_nf
               replace SH_PROCT->Nf with IMPORT->Numero_nf
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

/////////////////////////
static function Mostra_hist
   local nCONT, cHIST := ""
   local sBLOC := qsbloc(09,04,19,77)

   qlbloc(09,04,"B204E","QBLOC.GLO",1)

   HIST->(dbseek(ITEN_IMP->Hp1)) ; cHIST += alltrim(HIST->Descricao) + " "
   HIST->(dbseek(ITEN_IMP->Hp2)) ; cHIST += alltrim(HIST->Descricao) + " "
   HIST->(dbseek(ITEN_IMP->Hp3)) ; cHIST += alltrim(HIST->Descricao) + " "

   cHIST += PAGAR->Historico

   for nCONT := 1 to 6
       qsay(nCONT+11,6,subs(cHIST,(nCONT-1)*67+1,67))
   next

   qwait()

   qrbloc(09,04,sBLOC)

return

///////////////////////////////////////////////////////////////
// FUNCAO UTILIZADA PARA A MONTAGEM DO HISTORICO PADRAO _______

static function i_hist(cARQ,cVARIA)

   TIPOCONT->(dbseek((cARQ)->Tipo_sub))
   HIST->(dbseek(TIPOCONT->&cVARIA))
   nHIST := HIST->Descricao

   nHISTORICO := ""

   for nCONT := 1 to len(nHIST)

       if ( nPOS := at("[",nHIST) )  <> 0

          iif(nPOS <> 1 ,nHISTORICO += substr(nHIST,1,nPOS-1),)

          nPOS += 2  // para ignorar os simbolos [@

          do case

             case substr(nHIST,nPOS,2) == "CA"
                  nHISTORICO += left(FORN->Razao,30) + " "
             case substr(nHIST,nPOS,3) == "CGC"
                  nHISTORICO += transform(FORN->Cgc,"@R 99.999.999/9999-99") + " "
             case substr(nHIST,nPOS,2) == "DA"
                  nHISTORICO += dtos((cARQ)->Da)    + " "
             case substr(nHIST,nPOS,2) == "DP"
                  nHISTORICO += alltrim((cARQ)->Dp) + " "
             case substr(nHIST,nPOS,2) == "FA"
                  nHISTORICO += alltrim((cARQ)->Fa) + " "
             case substr(nHIST,nPOS,2) == "NF"
                  nHISTORICO += alltrim((cARQ)->Nf) + " "
             case substr(nHIST,nPOS,2) == "EP"
                  nHISTORICO += alltrim((cARQ)->Ep) + " "
             case substr(nHIST,nPOS,2) == "SE"
                  nHISTORICO += alltrim((cARQ)->Se) + " "
             case substr(nHIST,nPOS,2) == "BC"
                  nHISTORICO += alltrim((cARQ)->Bc) + " "
             case substr(nHIST,nPOS,2) == "CH"
                  nHISTORICO += alltrim((cARQ)->Ch) + " "
             case substr(nHIST,nPOS,2) == "DA"
                  nHISTORICO += alltrim((cARQ)->Da) + " "
             case substr(nHIST,nPOS,2) == "HO"
                  nHISTORICO += alltrim((cARQ)->Ho) + " "
             case substr(nHIST,nPOS,2) == "HP"
                  nHISTORICO += alltrim((cARQ)->Hp) + " "
             case substr(nHIST,nPOS,2) == "ND"
                  nHISTORICO += alltrim((cARQ)->Nd) + " "
             case substr(nHIST,nPOS,2) == "NT"
                  nHISTORICO += alltrim((cARQ)->Nt) + " "
             case substr(nHIST,nPOS,2) == "PC"
                  nHISTORICO += alltrim((cARQ)->Pc) + " "
          endcase

          nHIST := substr( nHIST , nPOS+4 , len(nHIST) ) // retira da variavel nHIST, os mneumonicos que ja foram verificados

       else

         exit

       endif

   next
Mostra_hist()
return

static function i_libera

local cCOD_CLI := space(5)
local cCOD_FAT := space(5)
local cRAZAO   := space(65)

  if ! Qconf("Comfirma Envio de Dados p/ N.F. de Entrada ?")
    return
  endif

  if IMPORT->Env_Fat
     qmensa("Pedido ja foi enviado, verifique no Sistema de Faturamento opcao(204) !","B")
     return
  endif

  CLI1->(Dbsetorder(3))
  CLI1->(Dbgotop())
  cCOD_CLI := "     "
  cRAZAO := Space(65)

  FORN->(Dbseek(IMPORT->Cod_forn))

  if ! CLI1->(dbseek(FORN->Cgccpf))

     if FATCFG->(qrlock())
        replace FATCFG->Cod_cli with FATCFG->Cod_cli + 1
        cCOD_CLI := strzero(FATCFG->Cod_cli,5)
        FATCFG->(Qunlock())
     endif

     if CLI1->(Qappend())
        replace CLI1->Codigo      with cCOD_CLI
        replace CLI1->Filial      with FORN->Filial
        replace CLI1->Razao       with FORN->Razao
        cRAZAO := FORN->Razao
        replace CLI1->Cgccpf      with FORN->Cgccpf
        replace CLI1->Inscricao   with FORN->Inscricao
        replace CLI1->End_cob     with FORN->End_cob
        replace CLI1->Bairro_cob  with FORN->Bairro_cob
        replace CLI1->Cgm_cob     with FORN->Cgm_cob
        replace CLI1->Cep_cob     with FORN->Cep_cob
        replace CLI1->End_ent     with FORN->End_ent
        replace CLI1->Bairro_cob  with FORN->Bairro_ent
        replace CLI1->Cgm_ent     with FORN->Cgm_ent
        replace CLI1->Cep_ent     with FORN->Cep_ent
        replace CLI1->Fone1       with FORN->Fone1
     endif
     CLI1->(DbCommit())
  else
    cCOD_CLI := CLI1->Codigo
    cRAZAO   := FORN->Razao
  endif

  if ! quse(XDRV_CL,"FAT",{"FATFATUR","FATDTEMI","FAT_FIDE","FAT_VEND","FAT_DTRE","FAT_CDCL","FAT_CLIR","FAT_ENTR","FAT_SAID","FAT_EMBR","FAT_NFAT","FATDESCE"},"","FAT")
     qmensa("Nao foi possivel abrir FAT.DBF !!!")
     return .F.
  Endif

  if FAT->(qappend())

     if ! quse(XDRV_CL,"NUM_PEDI",{},"","CONF")
        qmensa("N„o foi possivel abrir NUM_PEDI.DBF do Faturamento !","B")
        return .F.
     endif

     if CONF->(qrlock())
        replace CONF->Pedido with CONF->Pedido + 1
        cCOD_FAT := strzero(CONF->Pedido,5)
        CONF->(Qunlock())
     endif
     CONF->(DbCloseArea())

     replace FAT->Codigo      with cCOD_FAT
     replace FAT->Filial      with IMPORT->Filial
     replace FAT->C_Custo     With "0010"
     replace FAT->Dt_emissao  With IMPORT->Data_ped
     replace FAT->Dt_Saida    With IMPORT->Data_ped
     replace FAT->Cod_cli     With cCOD_CLI
     replace FAT->Cod_Cfop    with IMPORT->Cfop
     replace FAT->Cod_vended  with "00001"
     replace FAT->Tiposub     With "010002"
     replace FAT->Desc_sn     With "N"
     replace FAT->Es          With "E"
     replace FAT->Cliente     With cRAZAO
     replace FAT->Enviado     With .T.


     FAT->(DbCommit())
     ITEN_IMP->(Dbseek(IMPORT->Codigo))
     FAT->(DbCloseArea())

     if ! quse(XDRV_CL,"ITEN_FAT",{"FAT_FAPR","ITEN_NUM","FAT_SERV","ITEN_PRE"},"","ITEN_FAT")
        qmensa("Nao foi possivel abrir ITEN_FAT.DBF !!!")
        return .F.
     Endif

     Do while ! ITEN_IMP->(Eof()) .and. ITEN_IMP->Cod_ped == IMPORT->Codigo

        if ITEN_FAT->(Qappend())
           replace ITEN_FAT->Num_fat       With cCOD_FAT
           replace ITEN_FAT->Cod_prod      With ITEN_IMP->Cod_prod
           replace ITEN_FAT->Vl_unitar     With ITEN_IMP->Preco
           replace ITEN_FAT->Quantidade    With ITEN_IMP->Quant
           replace ITEN_FAT->Icms          With ITEN_IMP->Aliq_icms
           replace ITEN_FAT->Prod_ser      With "1"
           replace ITEN_FAT->Comissao      With 7
           replace ITEN_FAT->Calc_Desc     With "N"
           replace ITEN_FAT->Icms_subst    With "N"
           replace ITEN_FAT->Num_lote      with "0000000000"
           replace ITEN_FAT->Cod_sit       with "000"
           ITEN_FAT->(DbCommit())
        endif
        ITEN_IMP->(DbSkip())

     enddo
     ITEN_FAT->(DbCloseArea())

     if ! quse(XDRV_CL,"DUP_FAT",{"FAT_FADV","FAT_DUP"},"","DUP_FAT")
        qmensa("Nao foi possivel abrir DUP_FAT.DBF !!!")
        return .F.
     Endif

     PARCELA->(DbSetorder(1))
     PARCELA->(DbGotop())
     PARCELA->(Dbseek(IMPORT->Codigo))
     nCONT := 1



     do while ! PARCELA->(eof()) .and. PARCELA->Cod_ped == IMPORT->Codigo
        if DUP_FAT->(Qappend())
           replace DUP_FAT->Num_fat       With cCOD_FAT+strzero(nCONT,2)
           replace DUP_FAT->Valor         With PARCELA->Valor
           replace DUP_FAT->Data_venc     With PARCELA->Data
           DUP_FAT->(DbCommit())
           nCONT++
        Endif
        PARCELA->(DbSkip())
     enddo

     DUP_FAT->(DbCloseArea())

  endif

//  if IMPORT->(Qrlock())
//     replace IMPORT->Env_fat  With .T.
//     IMPORT->(qunlock())
//  endif


return

static function getBaseIcms
local nBase := 0
local nIcms := 0
local nTotalBase := 0
local nTotalIcms := 0
   
    ITEN_IMP->(dbseek(IMPORT->Codigo))
    do while ! ITEN_IMP->(eof()) .and. ITEN_IMP->Cod_ped == IMPORT->Codigo
	   
	   nBase := (ITEN_IMP->Quant * ITEN_IMP->Base_icms) 
	   nIcms := (nBase * (ITEN_IMP->Aliq_icms / 100))
	   nTotalBase += nBase
	   nTotalIcms += nIcms
	   
	
       ITEN_IMP->(dbskip())
    enddo
	
return nTotalBase

static function getValorIcms
local nBase := 0
local nIcms := 0
local nTotalBase := 0
local nTotalIcms := 0
   
    ITEN_IMP->(dbseek(IMPORT->Codigo))
    do while ! ITEN_IMP->(eof()) .and. ITEN_IMP->Cod_ped == IMPORT->Codigo
	   
	   nBase := (ITEN_IMP->Quant * ITEN_IMP->Base_icms) 
	   nIcms := (nBase * (ITEN_IMP->Aliq_icms / 100))
	   nTotalBase += nBase
	   nTotalIcms += nIcms
	   	
       ITEN_IMP->(dbskip())
    enddo
	
	
return nTotalIcms

