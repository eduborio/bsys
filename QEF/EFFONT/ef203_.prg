////////////////////////////////////////////////////////////////////////////
// SISTEMA....: ESCRITA FISCAL
// OBJETIVO...: MANUTENCAO DAS NOTAS DE ISS (SERVICOS)
// ANALISTA...: LUIS ANTONIO
// PROGRAMADOR: IN SUNG CHANG
// INICIO.....: MARCO DE 1994
// OBS........:
// ALTERACOES.:
function ef203

#include "inkey.ch"

//fu_abre_ccusto()

private lVOLTA

// CONFIGURACOES _________________________________________________________________

if ! quse(XDRV_EF,"CONFIG") ; return ; endif
// private nPERC_SLP := CONFIG->Perc_slp
private cTRIB_SINC := CONFIG->Trib_Sinc
private nPERC_SLP  := CONFIG->Perc_slp
private cUSACENTRO := CONFIG->Exig_ccust
CONFIG->(dbclosearea())

// MANUTENCAO DAS NOTAS DE ISS (SERVICOS)____________________________________

ISS->(dbseek(XANOMES))

ISS->(qview({{"Data_Lanc/Data Lan‡.",2},;
             {"Num_Nf/Nota Fiscal"  ,1},;
             {"Serie/S‚rie"         ,0},;
             {"transform(Vlr_Cont,'@E 999,999,999.99')/Valor Cont.",0},;
             {"transform(Iss_Base,'@E 999,999,999.99')/B. de C lculo",0},;
             {"transform(Iss_Vlr ,'@E 999,999.99'    )/Valor ISS"  ,0},;
             {"Filial/Filial"     ,3}},"P",;
             {NIL,"i_203a",NIL,NIL},;
             {"qanomes(Data_lanc)==XANOMES",{||i203top()},{||i203bot()}},;
             "<ESC>-Sai/<A>lt/<E>xc/<I>nc/<C>on/Pesquisa <N>ota"))

return

function i203top
   ISS->(dbseek(dtos(ctod("01/"+right(XANOMES,2)+"/"+left(XANOMES,4))),.T.))
return

function i203bot
   ISS->(qseekn(dtos(qfimmes(ctod("01/"+right(XANOMES,2)+"/"+left(XANOMES,4))))))
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function i_203a
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))
   iif(cOPCAO=="N",i_pesq_nota(),nil)
   if cOPCAO $ XUSRA
      if !XTIPOEMP $ "6790"     // COMERCIO E PRESTACAO DE SERVICOS
         qmensa("Empresa n„o Configurada como Prest. de Servi‡os Utilize Op‡„o <802> !","B")
         return .F.
      endif
      qlbloc(6,1,"B203A","QBLOC.GLO",1)
      qmensa(qabrev(cOPCAO,"IA",{"Inclus„o... <ESC - Cancela>","Altera‡„o... <ESC - Cancela>"}))
      i_edicao()
      MUNICIP->(dbSetFilter())
   endif
   setcursor(nCURSOR)
return ""

/////////////////////////////////////////////////////////////////////////////
// PESQUISA PELO NUMERO DA NOTA _____________________________________________

static function i_pesq_nota
   local cNOTA := space(8)
   local nREC  := ISS->(recno())

   qmensa("Digite o numero da Nota p/ pesquisa:")
   qgetx(24,48,@cNOTA,"99999999")

   cNOTA := strzero(val(cNOTA),8)

   ISS->(dbsetorder(1))
   if ISS->(dbseek(cNOTA))
      if qanomes(ISS->Data_lanc) <> XANOMES
         qmensa("Nota encontrada em: " + dtoc(ISS->Data_lanc) + ". Utilize op‡„o <803> !","B")
         ISS->(dbgoto(nREC))
         return
      endif
   else
      qmensa("Nota n„o encontrada !","B")
      ISS->(dbgoto(nREC))
      return
   endif
   ISS->(dbsetorder(2))

return
/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA ____________________________________

static function i_edicao

   local lCONF
   local aEDICAO := {}
   local bESCAPE := {||empty(fDATA_LANC).or.(XNIVEL==1.and.!XFLAG).or.;
                       (XNIVEL==1.and.lastkey()==27)}

   local sBLOC1 := qlbloc("B203B","QBLOC.GLO") // especie
   local sBLOC2 := qlbloc("B203CC","QBLOC.GLO") // Lancamentos por Centro de Custos

   // LANCAMENTOS POR CENTRO DE CUSTO_____________________________________________
//    if ! quse(XDRV_EF,"CONFIG") ; return ; endif
//       if CONFIG->Exig_ccust =="S"
         private nVALOR    := 0
         private nBASECC_1 := 0
         private nBASECC_2 := 0
         private nBASECC_3 := 0
         private nBASECC_4 := 0
         private nBASECC_5 := 0
         private nALIQCC_1 := 0
         private nALIQCC_2 := 0
         private nALIQCC_3 := 0
         private nALIQCC_4 := 0
         private nALIQCC_5 := 0
         private nICMCC_1  := 0
         private nICMCC_2  := 0
         private nICMCC_3  := 0
         private nICMCC_4  := 0
         private nICMCC_5  := 0
         private cCENTRO_1 := space(8)
         private cCENTRO_2 := space(8)
         private cCENTRO_3 := space(8)
         private cCENTRO_4 := space(8)
         private cCENTRO_5 := space(8)
         private aCCUSTO   := {{0,0,0,"        "},{0,0,0,"        "},{0,0,0,"        "},{0,0,0,"        "},{0,0,0,"        "}}

 //     endif
 //  CONFIG->(dbclosearea())
   // VARIAVEIS TEMPORARIAS PARA LANCAMENTO DE NOTA FISCAL NA INCLUSAO ______

   private dTEMP_LANC
   private cTEMP_SERIE
   private cTEMP_DESC
   private cTEMP_DATA
   private zFILIAL
   private zMUNICIP

   private nNOTAS  := 0          // PARA VERIFICAR SE JA FOI LANCADA UMA NOTA

// MONTA DADOS NA TELA ______________________________________________________

   if cOPCAO <> "I"
      XNIVEL := 1

      qrsay ( XNIVEL++ , ISS->Filial                             ) ; FILIAL->(dbseek(ISS->Filial))
      qrsay ( XNIVEL++ , left(FILIAL->Razao,40)                  )

      qrsay ( XNIVEL++ , ISS->Municip                            ) ; MUNICIP->(dbseek(ISS->Municip)) ; CGM->(dbseek(MUNICIP->Cgm))
      qrsay ( XNIVEL++ , left(CGM->Municipio,28)+"/"+CGM->Estado )

      qrsay ( XNIVEL++ , ISS->Data_lanc     , "@D"               )
      qrsay ( XNIVEL++ , ISS->Num_nf        , "@R 99999999"      )
      qrsay ( XNIVEL++ , ISS->Serie                              ) ; SERIE->(dbseek(ISS->Serie ))
      qrsay ( XNIVEL++ , qabrev(ISS->Especie, "ABCDEFG",{"Nota Fiscal","Luz","Telefone","Telex","Transportes","CMR(Maq.Reg.)","N.F.F."}))
      qrsay ( XNIVEL++ , ISS->Data_Emis     , "@D"               )
      qrsay ( XNIVEL++ , ISS->Num_Ult_Nf    , "@R 99999999"      )
      qrsay ( XNIVEL++ , ISS->Tiposub       , "@R 999999"        ) ;TIPOCONT->(dbseek(ISS->Tiposub))
      qrsay ( XNIVEL++ , left(TIPOCONT->Descricao,30)            )
      qrsay ( XNIVEL++ , ISS->Cod_Serv      , "@R 9999"          ) ; SERV->(dbseek(ISS->Cod_Serv))
      qrsay ( XNIVEL++ , SERV->Descricao                         )
      qrsay ( XNIVEL++ , ISS->Vlr_Cont      , "@E 999,999,999.99")
      qrsay ( XNIVEL++ , ISS->Vlr_Merc      , "@E 999,999,999.99")
      qrsay ( XNIVEL++ , ISS->Iss_Base      , "@E 999,999,999.99")
      qrsay ( XNIVEL++ , ISS->Iss_aliq      , "@R 99.99"         )
      qrsay ( XNIVEL++ , ISS->Iss_Vlr       , "@E 999,999,999.99")
//    qrsay ( XNIVEL++ , ISS->Perc_slp      , "@E 99.99"         )
      qrsay ( XNIVEL++ , ISS->Obs           , "@!"               )

   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || view_filial(-1,0,@fFILIAL ,"@!"                            ) } ,"FILIAL"     })
   aadd(aEDICAO,{{ || NIL                                                          } ,NIL          }) // descricao do filial

   MUNICIP->(dbSetFilter({|| alltrim(Filial) == alltrim(fFILIAL)}, 'alltrim(Filial) == alltrim(fFILIAL)'))

   aadd(aEDICAO,{{ || view_municip(-1,0,@fMUNICIP ,"@!"                          ) } ,"MUNICIP"    })
   aadd(aEDICAO,{{ || NIL                                                          } , NIL         }) // descricao do filial

   aadd(aEDICAO,{{ || qgetx(-1,0,@fDATA_LANC      , "@D"                         ) } , "DATA_LANC" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fNUM_NF         , "@R 99999999"                ) } , "NUM_NF"    })
   aadd(aEDICAO,{{ || view_serie(-1,0,@fSERIE     , "@R 99"                      ) } , "SERIE"     })
   aadd(aEDICAO,{{ || qesco(-1,0,@fESPECIE        , sBLOC1                       ) } , "ESPECIE"   })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDATA_EMIS      , "@D"                         ) } , "DATA_EMIS" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fNUM_ULT_NF     , "@R 99999999"                ) } , "NUM_ULT_NF"})
   aadd(aEDICAO,{{ || view_tpo(-1,0,@fTIPOSUB     , "@R 999999"                  ) } , "TIPOSUB"   })
   aadd(aEDICAO,{{ || NIL                                                          } , NIL         })
   aadd(aEDICAO,{{ || view_serv(-1,0,@fCOD_SERV   , ""                           ) } , "COD_SERV"  })
   aadd(aEDICAO,{{ || NIL                                                          } , NIL         })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fVLR_CONT       , "@E 999,999,999.99"          ) } , "VLR_CONT"  })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fVLR_MERC       , "@E 999,999,999.99"          ) } , "VLR_MERC"  })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fISS_BASE       , "@E 999,999,999.99"          ) } , "ISS_BASE"  })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fISS_ALIQ       , "@R 99.99"                   ) } , "ISS_ALIQ"  })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fISS_VLR        , "@E 999,999,999.99"          ) } , "ISS_VLR"   })
//   aadd(aEDICAO,{{ || qgetx(-1,0,@fPERC_SLP       , "@E 99.99"                   ) } , "PERC_SLP"  })
//   aadd(aEDICAO,{{ || view_obs(-1,0,@fOBS         , ""  , NIL,cOPCAO=="I"        ) } , "OBS"       })
//   aadd(aEDICAO,{{ || view_obs(-1,0,@fOBS                                        ) } ,"OBS"        })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fOBS            , "@!X"                          ) } ,"OBS"        })

   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   do while .T.

      if cOPCAO == "I"
         qlbloc(6,1,"B203A","QBLOC.GLO",1)
      endif

      ISS->(qpublicfields())
      if cOPCAO=="I"
         ISS->(qinitfields())
         if nNOTAS = 0
            fDATA_LANC := qfimmes(ctod("01/" + right(XANOMES,2) + "/" + left(XANOMES,4)))
            fDATA_EMIS := ctod("01/" + right(XANOMES,2) + "/" + left(XANOMES,4))
            fSERIE     := "01"
         else
            fDATA_LANC := dTEMP_LANC
            fSERIE     := cTEMP_SERIE
            fCOD_SERV := cTEMP_DESC
            fDATA_EMIS := cTEMP_DATA
            fFILIAL    := zFILIAL
            fMUNICIP   := zMUNICIP
         endif
//         if ! quse(XDRV_EF,"CONFIG") ; return ; endif
//           if CONFIG->Exig_ccust =="S"
                nBASECC_1 := 0
                nBASECC_2 := 0
                nBASECC_3 := 0
                nBASECC_4 := 0
                nBASECC_5 := 0
                nALIQCC_1 := 0
                nALIQCC_2 := 0
                nALIQCC_3 := 0
                nALIQCC_4 := 0
                nALIQCC_5 := 0
                nICMCC_1  := 0
                nICMCC_2  := 0
                nICMCC_3  := 0
                nICMCC_4  := 0
                nICMCC_5  := 0
                cCENTRO_1 := space(8)
                cCENTRO_2 := space(8)
                cCENTRO_3 := space(8)
                cCENTRO_4 := space(8)
                cCENTRO_5 := space(8)
                aCCUSTO   := {{0,0,0,"        "},{0,0,0,"        "},{0,0,0,"        "},{0,0,0,"        "},{0,0,0,"        "}}
//            endif
//          CONFIG->(dbclosearea())
      else
         ISS->(qcopyfields())
      endif
      XNIVEL := 1
      XFLAG := .T.
  ////  if ! quse(XDRV_EF,"CONFIG") ; return ; endif
  //    if CONFIG->Exig_ccust == "S" ;
  i_int_ccusto()// ; endif
  //    CONFIG->(dbclosearea())
      // LOOP PARA SAIDA DOS CAMPOS ____________________________________________
      Public CAMPO
      CAMPO := len(aEDICAO) - 2

      do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
         eval ( aEDICAO [XNIVEL,1] )
         if eval ( bESCAPE ) ; ISS->(qreleasefields()) ;ISS_CUST->(qreleasefields()); return ; endif
         if ! i_critica1( aEDICAO[XNIVEL,2] ) ; loop ; endif
         iif ( XFLAG , XNIVEL++ , XNIVEL-- )
         qmensa("")
      enddo

      // GRAVACAO ______________________________________________________________

      if ! lCONF ; return  ; endif

      if ISS->(iif(cOPCAO=="I",qappend(),qrlock()))
    //      if ! quse(XDRV_EF,"CONFIG") ; return ; endif
    //      if CONFIG->Exig_ccust =="S"
              i_grav_centro()
    //      endif
    //      CONFIG->(dbclosearea())
         ISS->(qreplacefields())
         ISS->(qunlock())
         dTEMP_LANC  := fDATA_LANC
         cTEMP_SERIE := fSERIE
         cTEMP_DESC  := fCOD_SERV
         cTEMP_DATA  := fDATA_EMIS
         zFILIAL     := fFILIAL
         zMUNICIP    := fMUNICIP
         nNOTAS++
      else
         iif(cOPCAO=="I",qm1(),qm2())
      endif

      if cOPCAO == "A"
         exit
      endif

   enddo

return

/////////////////////////////////////////////////////////////////////////////
// CRITICAS NA DESCIDA ______________________________________________________

static function i_critica1 ( cCAMPO )
   local nDIFERENCA
   qmensa("")
   iif ( cCAMPO == NIL , cCAMPO := "" , NIL )
   if ! XFLAG ; return .T. ; endif
   do case

      case cCAMPO == "FILIAL"

           qrsay(XNIVEL,fFILIAL:=strzero(val(fFILIAL),4))

           if FILIAL->(dbseek(fFILIAL))
              qrsay(XNIVEL+1,left(FILIAL->Razao,40))
           else
              qmensa("Filial n„o encontrada !","B")
              return .F.
           endif
           Return .T.

      case cCAMPO == "MUNICIP"

           if ! empty(fMUNICIP)
              qrsay(XNIVEL,fMUNICIP:=strzero(val(fMUNICIP),4))

              if MUNICIP->(dbseek(fMUNICIP))
                 CGM->(dbseek(MUNICIP->Cgm))
                 qrsay(XNIVEL+1,left(CGM->Municipio,28)+"/"+CGM->Estado)
                 fISS_ALIQ := MUNICIP->Aliq_iss
              else
                 if ! qconf("Munic¡pio n„o Cadastrado  !  Incluir agora ?")
                    fMUNICIP := space(4)
                    qmensa("")
                    return .F.
                 endif
                 MUNICIP->(dbSetFilter())
                 MUNICIP->(dbgobottom())
                 fMUNICIP := strzero(val(MUNICIP->Codigo)+1,4)
                 MUNICIP->(dbgotop())
                 MUNICIP->(dbSetFilter({|| alltrim(Filial) == alltrim(fFILIAL)}, 'alltrim(Filial) == alltrim(fFILIAL)'))
                 if ! i_inc_municip( fMUNICIP )
                    fMUNICIP := space(4)
                    return .F.
                 else
                    qrsay(XNIVEL,fMUNICIP)
                    qrsay(XNIVEL+1,left(CGM->Municipio,28)+"/"+CGM->Estado)
                    XNIVEL++
                 endif
                 lVOLTA := .F.
              endif
           else
              qmensa("Municipio n†o encontrado","B")
              return .F.
           endif
           Return .T.

      case cCAMPO == "DATA_LANC"

           if empty(fDATA_LANC) ; return .F. ; endif

           if substr(dtoc(fDATA_LANC),4,2) <> right(XANOMES,2)
              qmensa("Mes de Lancamento da Nota Fiscal n„o est  correto !","B")
              return .F.
           endif
           fDATA_EMIS := fDATA_LANC
           qrsay(XNIVEL,fDATA_LANC)
           Return .T.

      case cCAMPO == "DATA_EMIS"
           if empty(fDATA_EMIS) ; return .F. ; endif
           if fDATA_EMIS > fDATA_LANC
              qmensa("Data de Emiss„o n„o pode ser maior que a Data de Lancamento !","B")
              return .F.
           endif
           qrsay(XNIVEL,fDATA_EMIS)
           Return .T.

      case cCAMPO == "NUM_NF"
           if empty(fNUM_NF) ; return .F. ; endif
           qrsay(XNIVEL,fNUM_NF:=strzero(val(fNUM_NF),8))
           Return .T.

      case cCAMPO == "SERIE" .and. cOPCAO == "I"
           // ALTERA PARA ORDEM DE NUMERO + SERIE ___________________________________
           ISS->(dbsetorder(1))
           qrsay(XNIVEL,fSERIE:=strzero(val(fSERIE),2))

           if ! SERIE->(dbseek(fSERIE))
              qmensa("S‚rie Inv lida !","B")
              // RETORNA ORDEM PARA DATA DE LANCAMENTO ______________________________
              ISS->(dbsetorder(2))
              return .F.
           endif

           if ISS->(dbseek(fNUM_NF+fSERIE+fFILIAL))
              qmensa("ATENCŽO: Nota Fiscal j  cadastrada em "+dtoc(ISS->DATA_LANC)+".","B")
              XNIVEL--
           endif

           // RETORNA ORDEM PARA DATA DE LANCAMENTO _________________________________
           ISS->(dbsetorder(2))

      case cCAMPO == "SERIE" .and. cOPCAO == "A"
           if ! SERIE->(dbseek(fSERIE))
              qmensa("S‚rie Inv lida !","B") ; return .F.
           endif

      case cCAMPO == "ESPECIE"
           if empty(fESPECIE) ; return .F. ; endif
           qrsay(XNIVEL,qabrev(fESPECIE,"ABCDEFG",{"Nota Fiscal","Luz","Telefone","Telex","Transportes","CMR(Maq.Reg.)","N.F.F."}))

      case cCAMPO == "NUM_ULT_NF"
           if empty(fNUM_ULT_NF) ; return .T. ; endif
           qrsay(XNIVEL,fNUM_ULT_NF:=strzero(val(fNUM_ULT_NF),6))
           if val(fNUM_ULT_NF) < val(fNUM_NF)
              qmensa("Esta nota deve ser maior que a Nota Fiscal informada acima !","B")
              return .F.
           endif
           Return .T.

      case cCAMPO == "COD_SERV"
           if empty(fCOD_SERV) ; return .T. ; endif
           qrsay(XNIVEL,fCOD_SERV:=strzero(val(fCOD_SERV),4))
           if SERV->(dbseek(fCOD_SERV))
              qrsay(XNIVEL+1,SERV->Descricao)
           else
              qmensa("Servico n„o Cadastrado !","B")
              return .F.
           endif
           Return .T.

      case cCAMPO == "ISS_ALIQ"
           fISS_VLR := round(((fISS_BASE * fISS_ALIQ) / 100),2)
           qrsay(XNIVEL+1,fISS_VLR,"@E 999,999,999.99")
           Return .T.

      case cCAMPO == "VLR_MERC"
           fISS_BASE := fVLR_CONT - fVLR_MERC
           qrsay(XNIVEL+1,fISS_BASE,"@E 999,999,999.99")
           Return .T.

      case cCAMPO == "VLR_CONT" .and. cOPCAO == "I"
           if empty(fVLR_CONT)
              fOBS := "## NF CANCELADA"
              XNIVEL := CAMPO  // quando emite nota cancelada aceita valor nulo
              qrsay(20,fOBS)
              return .T.
           endif
           nBASECC_1 := fVLR_CONT
           nVALOR    := fVLR_CONT
           fVLR_MERC := fVLR_CONT * (100 - MUNICIP->Aliq_base) / 100
           qrsay(XNIVEL,fVLR_CONT,"@E 999,999,999.99")
           Return .T.

      case cCAMPO == "VLR_CONT" .and. cOPCAO == "A"
           if empty(fVLR_CONT)
              fVLR_MERC:= fISS_BASE :=fISS_ALIQ :=fISS_VLR := 0
              fOBS := "## NF CANCELADA"
              XNIVEL := CAMPO  // quando emite nota cancelada aceita valor nulo
              qrsay(32,fOBS)
              return .T.
           endif
           fVLR_MERC := fVLR_CONT * (100 - MUNICIP->Aliq_base) / 100
           qrsay(XNIVEL,fVLR_CONT,"@E 999,999,999.99")
           Return .T.

      case cCAMPO == "ISS_VLR"
           nDIFERENCA := fISS_VLR - ((fISS_ALIQ * fISS_BASE) / 100)
             if cUSACENTRO == "S"
                i_centro()
             endif

           Return .T.

   endcase
return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXCLUIR NOTAS FISCAIS DE ISS (SERVICOS)_______________________

static function i_exclusao
   if qconf("Confirma exclus„o desta nota fiscal ?")
      if ISS->(qrlock()) .and. ISS_CUST->(qrlock())
         i_grav_centro()
         ISS->(dbdelete())
         ISS->(qunlock())
         ISS_CUST->(qunlock())
      else
         qm3()
      endif
   endif
return

 //////////////////////////////////////////////////////////////////////////////////
 // INCLUI MUNICIPIO NO LANCAMENTO DA NOTA FISCAL ________________________________

function i_inc_municip ( fMUNICIP )

    local nNIVEL    := XNIVEL
    local nORDER    := MUNICIP->(dbsetorder(1))
    local nCURS     := setcursor(1)
    local fCODIGO
    private sBLOC   := qsbloc(0,0,24,79)

    MUNICIP->(qpublicfields())
    MUNICIP->(qinitfields())

    i_inc_m2()
    
    qrbloc(0,0,sBLOC)

    if lVOLTA
       return .T.
    else
       return .F.
    endif

    MUNICIP->(dbsetorder(nORDER))

    XNIVEL := nNIVEL

    setcursor(nCURS)
    
 return

  //////////////////////////////////////////////////////////////////////////////////
 // FAZ A EDICAO DOS CAMPOS PARA INCLUSAO DO MUNICIPIO _____________________________

 static function i_inc_m2

    local aEDICAO2:= {} , XNIVEL := 1 , lCONF1 := .F.
    local bESCAPE := {||empty(fCODIGO).or.(XNIVEL==1.and.!XFLAG)}

    qlbloc(9,12,"B109A","QBLOC.GLO",1)

    fCODIGO := fMUNICIP

    aadd(aEDICAO2,{{ || NIL                                                 },"CODIGO"    })
    aadd(aEDICAO2,{{ || qgetx(10,63,@fVENC      , "99"                     )},"VENC"      })

    aadd(aEDICAO2,{{ || NIL                                                 },"FILIAL"    })
    aadd(aEDICAO2,{{ || NIL },NIL }) // descricao do filial

    aadd(aEDICAO2,{{ || view_cgm(14,25,@fCGM                               )},"CGM"       })
    aadd(aEDICAO2,{{ || NIL                                                 },NIL         })

    aadd(aEDICAO2,{{ || qgetx(16,32,@fALIQ_BASE , "@R 99.99"               )},"ALIQ_BASE" })
    aadd(aEDICAO2,{{ || qgetx(16,58,@fALIQ_ISS  , "@R 99.99"               )},"ALIQ_ISS"  })

    aadd(aEDICAO2,{{ || lCONF1 := qconf("Confirma inclus„o ?")              },NIL         })

    do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO2)
       eval ( aEDICAO2 [XNIVEL,1] )
       if eval ( bESCAPE ) ; MUNICIP->(qreleasefields()) ; return ; endif
       if ! i_critica2( aEDICAO2[XNIVEL,2] ) ; loop ; endif
       iif ( XFLAG , XNIVEL++ , XNIVEL-- )
    enddo

    if lCONF1
       MUNICIP->(qappend())
       MUNICIP->(qreplacefields())
       MUNICIP->(qunlock())
       lVOLTA := .T.
    else
       lVOLTA := .F.
    endif

return

/////////////////////////////////////////////////////////////////////////////
// CRITICAS NA DESCIDA ______________________________________________________

static function i_critica2 ( cCAMPO )

   qmensa("")

   iif ( cCAMPO == NIL , cCAMPO := "" , NIL )

   do case
      case cCAMPO == "CODIGO"
           if empty(fCODIGO) .or. val(fCODIGO) == 0 ; return .F. ; endif
           qsay(10,25,fCODIGO:=strzero(val(fCODIGO),4))

      case cCAMPO == "FILIAL"

           qsay(12,25,FILIAL->Codigo)
           qsay(12,38,left(FILIAL->Razao,27))

           fFILIAL := FILIAL->Codigo

      case cCAMPO == "CGM"
           if ! CGM->(dbseek(fCGM))
              qmensa("Municipio n„o encontrado !","B")
              return .F.
           endif
           nREC := MUNICIP->(recno())
           MUNICIP->(dbsetorder(2))
           if MUNICIP->(dbseek(CGM->Codigo)) .and. alltrim(MUNICIP->Filial) == fFILIAL
              qmensa("Municipio j  cadastrado para base de calculo do ISS !","B")
              MUNICIP->(dbsetorder(1))
              MUNICIP->(dbgoto(nREC))
              XNIVEL := XNIVEL - 4
              return .F.
           endif
           MUNICIP->(dbsetorder(1))
           MUNICIP->(dbgoto(nREC))
           qsay(14,34,left(CGM->Municipio,28) + "/" + CGM->Estado )

           fCGM_DESC:= CGM->Municipio
           fCGM     := CGM->Codigo

      case cCAMPO == "VENC"
           qsay(10,63,fVENC:=strzero(val(fVENC),2))
           if val(fVENC) > 31 .or. val(fVENC) < 0
              qmensa("Dia do vencimento inv lido !","B")
              return .F.
           endif
   endcase

return .T.

//////////////////////////////////////////////////////////////////////////////////
// PARA INICIAR VALORES DE CENTRO DE CUSTOS ______________________________________

static function i_int_ccusto

   if ISS_CUST->(dbseek(dtos(ISS->Data_lanc)+ ISS->Num_nf + ISS->Serie + ISS->Filial))
      for nCONT := 1 to 5
           aCCUSTO[nCONT,1] := ISS_CUST->Iss_Base
           aCCUSTO[nCONT,2] := ISS_CUST->Iss_Aliq
           aCCUSTO[nCONT,3] := ISS_CUST->Iss_Vlr
           aCCUSTO[nCONT,4] := ISS_CUST->Centro
           ISS_CUST->(dbskip())
           if ISS->Num_nf + ISS->Serie + ISS->Filial <> ISS_CUST->Num_nf + ISS_CUST->Serie + ISS_CUST->Filial
              exit
           endif
      next
   else
      return
   endif

   // INICIA VARIAVEIS PARA EDICAO _______________________________________________

   nBASECC_1 := aCCUSTO[1,1]
   nBASECC_2 := aCCUSTO[2,1]
   nBASECC_3 := aCCUSTO[3,1]
   nBASECC_4 := aCCUSTO[4,1]
   nBASECC_5 := aCCUSTO[5,1]

   nALIQCC_1 := aCCUSTO[1,2]
   nALIQCC_2 := aCCUSTO[2,2]
   nALIQCC_3 := aCCUSTO[3,2]
   nALIQCC_4 := aCCUSTO[4,2]
   nALIQCC_5 := aCCUSTO[5,2]

   nICMCC_1  := aCCUSTO[1,3]
   nICMCC_2  := aCCUSTO[2,3]
   nICMCC_3  := aCCUSTO[3,3]
   nICMCC_4  := aCCUSTO[4,3]
   nICMCC_5  := aCCUSTO[5,3]

   cCENTRO_1  := aCCUSTO[1,4]
   cCENTRO_2  := aCCUSTO[2,4]
   cCENTRO_3  := aCCUSTO[3,4]
   cCENTRO_4  := aCCUSTO[4,4]
   cCENTRO_5  := aCCUSTO[5,4]


return

//////////////////////////////////////////////////////////////////////////////////
// GRAVA LANCAMENTOS POR CENTRO DE CUSTOS_________________________________________

static function i_grav_centro

   do while ISS_CUST->(dbseek(ISS->Num_nf+ISS->Serie + ISS->Filial))
      ISS_CUST->(qrlock())
      ISS_CUST->(dbdelete())
      ISS_CUST->(qunlock())

   enddo

   // OBS. UTILIZADA TAMBEM PARA EXCLUSAO DE LANCAMENTO, QUANDO O VETOR
   // VAI ESTAR VAZIO E NAO VAI ENTRAR NO for ABAIXO...

   for nCONT := 1 to 5

       if empty(aCCUSTO[nCONT,1]) ; exit ; endif

       ISS_CUST->(qappend())
       replace ISS_CUST->Data_Lanc with fDATA_LANC
       replace ISS_CUST->Num_Nf    with fNUM_NF
       replace ISS_CUST->Serie     with fSERIE
       replace ISS_CUST->Filial    with fFILIAL
       replace ISS_CUST->Iss_Base  with aCCUSTO[nCONT,1]
       replace ISS_CUST->Iss_Aliq  with aCCUSTO[nCONT,2]
       replace ISS_CUST->Iss_Vlr   with aCCUSTO[nCONT,3]
       replace ISS_CUST->Centro    with aCCUSTO[nCONT,4]


       ISS_CUST->(dbskip())

   next

return

//////////////////////////////////////////////////////////////////////////////////
// LANCAMENTOS POR CENTRO DE CUSTOS_______________________________________________

static function i_centro

   local nNIVEL  := XNIVEL
   local sBLOC := qsbloc(5,0,24,79)
   local aEDICAO := {}
   local bESCAPE := {||(XNIVEL==1.and.!XFLAG)}
   qlbloc(5,0,"B203CC","QBLOC.GLO")

   XNIVEL := 1

   // ATUALIZA A TELA ____________________________________________________________

   qrsay(XNIVEL++ , nBASECC_1 , "@E 999,999,999.99" )
   qrsay(XNIVEL++ , nALIQCC_1 , "@E 99.99"          )
   qrsay(XNIVEL++ , nICMCC_1  , "@E 999,999,999.99" )
   qrsay(XNIVEL++ , cCENTRO_1 , "99999999" )


   qrsay(XNIVEL++ , nBASECC_2 , "@E 999,999,999.99" )
   qrsay(XNIVEL++ , nALIQCC_2 , "@E 99.99"          )
   qrsay(XNIVEL++ , nICMCC_2  , "@E 999,999,999.99" )
   qrsay(XNIVEL++ , cCENTRO_2 , "99999999" )
                            

   qrsay(XNIVEL++ , nBASECC_3 , "@E 999,999,999.99" )
   qrsay(XNIVEL++ , nALIQCC_3 , "@E 99.99"          )
   qrsay(XNIVEL++ , nICMCC_3  , "@E 999,999,999.99" )
   qrsay(XNIVEL++ , cCENTRO_3 , "99999999" )

   qrsay(XNIVEL++ , nBASECC_4 , "@E 999,999,999.99" )
   qrsay(XNIVEL++ , nALIQCC_4 , "@E 99.99"          )
   qrsay(XNIVEL++ , nICMCC_4  , "@E 999,999,999.99" )
   qrsay(XNIVEL++ , cCENTRO_4 , "99999999" )

   qrsay(XNIVEL++ , nBASECC_5 , "@E 999,999,999.99" )
   qrsay(XNIVEL++ , nALIQCC_5 , "@E 99.99"          )
   qrsay(XNIVEL++ , nICMCC_5  , "@E 999,999,999.99" )
   qrsay(XNIVEL++ , cCENTRO_5 , "99999999" )

   XNIVEL := 1

   // CALCULO DE LANCAMENTOS POR CENTRO DE CUSTOS___________________________________

   aadd(aEDICAO,{{ || qgetx(-1,0,@nBASECC_1            , "@E 999,999,999.99") } ,"BASECC_1" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@nALIQCC_1            , "@E 99.99"         ) } ,"ALIQCC_1" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@nICMCC_1             , "@E 999,999,999.99") } ,"ICMCC_1"  })
   aadd(aEDICAO,{{ || view_ccusto(-1,0,@cCENTRO_1      , "@R 99999999"      ) } ,"CENTRO_1" })


   aadd(aEDICAO,{{ || qgetx(-1,0,@nBASECC_2          , "@E 999,999,999.99") } ,"BASECC_2" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@nALIQCC_2          , "@E 99.99"         ) } ,"ALIQCC_2" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@nICMCC_2           , "@E 999,999,999.99") } ,"ICMCC_2"  })
   aadd(aEDICAO,{{ || view_ccusto(-1,0,@cCENTRO_2    , "@R 99999999"       ) } ,"CENTRO_2" })


   aadd(aEDICAO,{{ || qgetx(-1,0,@nBASECC_3            , "@E 999,999,999.99") } ,"BASECC_3" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@nALIQCC_3            , "@E 99.99"         ) } ,"ALIQCC_3" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@nICMCC_3             , "@E 999,999,999.99") } ,"ICMCC_3"  })
   aadd(aEDICAO,{{ || view_ccusto(-1,0,@cCENTRO_3      , "@R 99999999"      ) } ,"CENTRO_3" })

   aadd(aEDICAO,{{ || qgetx(-1,0,@nBASECC_4          , "@E 999,999,999.99") } ,"BASECC_4" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@nALIQCC_4          , "@E 99.99"         ) } ,"ALIQCC_4" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@nICMCC_4           , "@E 999,999,999.99") } ,"ICMCC_4"  })
   aadd(aEDICAO,{{ || view_ccusto(-1,0,@cCENTRO_4    , "@R 99999999"      ) } ,"CENTRO_4" })

   aadd(aEDICAO,{{ || qgetx(-1,0,@nBASECC_5          , "@E 999,999,999.99") } ,"BASECC_5" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@nALIQCC_5          , "@E 99.99"         ) } ,"ALIQCC_5" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@nICMCC_5           , "@E 999,999,999.99") } ,"ICMCC_5"  })
   aadd(aEDICAO,{{ || view_ccusto(-1,0,@cCENTRO_5    , "@R 99999999"      ) } ,"CENTRO_5" })


   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE )
         qrbloc(5,0,sBLOC)
         XNIVEL := nNIVEL
         return
      endif
      if ! i_crit_4( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   XNIVEL := nNIVEL
   qrbloc(5,0,sBLOC)

   aCCUSTO[1,1] := nBASECC_1
   aCCUSTO[2,1] := nBASECC_2
   aCCUSTO[3,1] := nBASECC_3
   aCCUSTO[4,1] := nBASECC_4
   aCCUSTO[5,1] := nBASECC_5
   aCCUSTO[1,2] := nALIQCC_1
   aCCUSTO[2,2] := nALIQCC_2
   aCCUSTO[3,2] := nALIQCC_3
   aCCUSTO[4,2] := nALIQCC_4
   aCCUSTO[5,2] := nALIQCC_5
   aCCUSTO[1,3] := nICMCC_1
   aCCUSTO[2,3] := nICMCC_2
   aCCUSTO[3,3] := nICMCC_3
   aCCUSTO[4,3] := nICMCC_4
   aCCUSTO[5,3] := nICMCC_5

   aCCUSTO[1,4] := cCENTRO_1
   aCCUSTO[2,4] := cCENTRO_2
   aCCUSTO[3,4] := cCENTRO_3
   aCCUSTO[4,4] := cCENTRO_4
   aCCUSTO[5,4] := cCENTRO_5


return

////////////////////////////////////////////////////////////////////////////////
// CRITICAS NA DESCIDA _________________________________________________________

static function i_crit_4 ( cCAMPO )

   local nDIFERE := 0
   iif ( cCAMPO == NIL , cCAMPO := "" , NIL )
   if ! XFLAG ; return .T. ; endif

   do case
      case cCAMPO == "ICM_1CC"
           nDIFERE := (nICMCC_1 - ((nBASECC_1 * nALIQCC_1) / 100))
           if (round(nDIFERE,2) >= 0.02 .or. round(nDIFERE,2) <= -0.02) .and. cOPCAO == "I"
              qmensa("Valor do imposto est  incorreto !! Recalcule !","B")
              XNIVEL -= 4
           endif

      case cCAMPO == "CENTRO_1"
           if ! CCUSTO->(dbseek(cCENTRO_1)); qmensa("Centro de Custo Nao Encontrado !","B")
                qmensa("                                ","")
           endif
           if cOPCAO == "I"
              nBASECC_2 := (nVALOR - nBASECC_1)
              qrsay(XNIVEL+1,nBASECC_2,"@E 999,999,999.99")
              nVALOR  := nBASECC_2
           endif

      case cCAMPO == "ICMCC_2"
           nDIFERE := (nICMCC_2 - ((nBASECC_2 * nALIQCC_2) / 100))
           if (round(nDIFERE,2) >= 0.02 .or. round(nDIFERE,2) <= -0.02) .and. cOPCAO == "I"
              qmensa("Valor do imposto est  incorreto !! Recalcule !","B")
              XNIVEL -= 4
           endif

      case cCAMPO == "CENTRO_2"
           if ! CCUSTO->(dbseek(cCENTRO_2)); qmensa("Centro de Custo Nao Encontrado !","B")
                qmensa("                                ","")
           endif

           if cOPCAO == "I"
              nBASECC_3 := nVALOR - nBASECC_2
              qrsay(XNIVEL+1,nBASECC_3,"@E 999,999,999.99")
              nVALOR  := nBASECC_3
           endif


      case cCAMPO == "ICMCC_3"
           nDIFERE := (nICMCC_3 - ((nBASECC_3 * nALIQCC_3) / 100))
           if (round(nDIFERE,2) >= 0.02 .or. round(nDIFERE,2) <= -0.02) .and. cOPCAO == "I"
              qmensa("Valor do imposto est  incorreto !! Recalcule !","B")
              XNIVEL -= 4
           endif

      case cCAMPO == "CENTRO_3"
           if ! CCUSTO->(dbseek(cCENTRO_3)); qmensa("Centro de Custo Nao Encontrado !","B")
                qmensa("                                ","")
           endif

           if cOPCAO == "I"
              nBASECC_4 := nVALOR - nBASECC_3
              qrsay(XNIVEL+1,nBASECC_4,"@E 999,999,999.99")
              nVALOR  := nBASECC_4

           endif

      case cCAMPO == "ICMCC_4"
           nDIFERE := (nICMCC_4 - ((nBASECC_4 * nALIQCC_4) / 100))
           if (round(nDIFERE,2) >= 0.02 .or. round(nDIFERE,2) <= -0.02) .and. cOPCAO == "I"
              qmensa("Valor do imposto est  incorreto !! Recalcule !","B")
              XNIVEL -= 4
           endif

      case cCAMPO == "CENTRO_4"
           if ! CCUSTO->(dbseek(cCENTRO_4)); qmensa("Centro de Custo Nao Encontrado !","B")
                qmensa("                                ","")
           endif

           if cOPCAO == "I"
              nBASECC_5 := nVALOR - nBASECC_4
              qrsay(XNIVEL+1,nBASECC_5,"@E 999,999,999.99")
           endif

      case cCAMPO == "ICMCC_5"
           nDIFERE := (nICMCC_5 - ((nBASECC_5 * nALIQCC_5) / 100))
           if (round(nDIFERE,2) >= 0.02 .or. round(nDIFERE,2) <= -0.02) .and. cOPCAO == "I"
              qmensa("Valor do imposto est  incorreto !! Recalcule !","B")
              XNIVEL -= 4
           endif

      case cCAMPO == "CENTRO_5"
           if ! CCUSTO->(dbseek(cCENTRO_5)); qmensa("Centro de Custo Nao Encontrado !","B")
                qmensa("                                ","")
           endif


      case cCAMPO == "ALIQCC_1" .and. cOPCAO $ "IA"
           nICMCC_1 := (nBASECC_1 * nALIQCC_1) / 100
           qrsay(XNIVEL+1, nICMCC_1 , "@E 999,999,999.99")

      case cCAMPO == "ALIQCC_2" .and. cOPCAO $ "IA"
           nICMCC_2 := (nBASECC_2 * nALIQCC_2) / 100
           qrsay(XNIVEL+1, nICMCC_2 , "@E 999,999,999.99")

      case cCAMPO == "ALIQCC_3" .and. cOPCAO $ "IA"
           nICMCC_3 := (nBASECC_3 * nALIQCC_3) / 100
           qrsay(XNIVEL+1, nICMCC_3 , "@E 999,999,999.99")

      case cCAMPO == "ALIQCC_4" .and. cOPCAO $ "IA"
           nICMCC_4 := (nBASECC_4 * nALIQCC_4) / 100
           qrsay(XNIVEL+1, nICMCC_4 , "@E 999,999,999.99")

      case cCAMPO == "ALIQCC_5" .and. cOPCAO $ "IA"
           nICMCC_5 := (nBASECC_5 * nALIQCC_5) / 100
           qrsay(XNIVEL+1, nICMCC_5 , "@E 999,999,999.99")

   endcase

return .T.


