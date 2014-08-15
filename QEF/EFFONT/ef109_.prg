
/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: ESCRITA FISCAL
// OBJETIVO...: MANUTENCAO DE BASE DE CALCULO DE ISS
// ANALISTA...:
// PROGRAMADOR: IN SUNG CHANG
// INICIO.....: OUTUBRO DE 1996
// OBS........:
// ALTERACOES.:
function ef109

//fu_abre_ccusto()

/////////////////////////////////////////////////////////////////////////////
// MANUTENCAO DE ALIQUOTAS DE ISS POR MUNICIPIO _____________________________

MUNICIP->(qview({{"Codigo/C¢digo"        ,1},;
                 {"i_109a()/Municipio"   ,4},;
                 {"Aliq_base/Al¡q. Base" ,0},;
                 {"Aliq_iss/Al¡q. ISS"   ,0},;
                 {"i_venc()/Venc."       ,0},;
                 {"Filial/Filial"      ,3}},"P",;
                 {NIL,"i_109b",NIL,NIL},;
                  NIL,q_msg_acesso_usr()))
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRA DO DIA DO VENCIMENTO __________________________________

function i_venc
   local cVENC
return cVENC := " " + MUNICIP->Venc

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTARGEM DO MUNICIPIO(CGM) __________________________________

function i_109a
   CGM->(dbseek(MUNICIP->Cgm))
return CGM->Municipio

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function i_109b

   local nCURSOR := setcursor(1)

   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO $ XUSRA
      qlbloc(9,12,"B109A","QBLOC.GLO",1)
      qmensa(qabrev(cOPCAO,"IA",{"Inclus„o... <ESC - Cancela>","Altera‡„o... <ESC - Cancela>"}))
      i_edicao()
   endif

   setcursor(nCURSOR)

return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA ____________________________________

static function i_edicao

   local lCONF
   local aEDICAO := {}
   local bESCAPE := {||empty(fVENC).or.(XNIVEL==2.and.!XFLAG).or.!empty(fVENC).and.Lastkey()==27.or.;
                       (XNIVEL==2.and.lastkey()==27).or.;
                       (XNIVEL==2.and.cOPCAO=="A".and.!XFLAG)}

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"

      XNIVEL := 1

      qrsay ( XNIVEL++ , MUNICIP->Codigo    , "9999"     )
      qrsay ( XNIVEL++ , MUNICIP->Venc      , "99"       )

      qrsay ( XNIVEL++ , MUNICIP->Filial                 ) ; FILIAL->(dbseek(MUNICIP->Filial))
      qrsay ( XNIVEL++ , left(FILIAL->Razao,27)           )

      qrsay ( XNIVEL++ , MUNICIP->Cgm       , "999999"   ) ; CGM->(dbseek(MUNICIP->Cgm))
      qrsay ( XNIVEL++ , left(CGM->Municipio,28)+"/"+CGM->Estado )

      qrsay ( XNIVEL++ , MUNICIP->Aliq_base , "@R 99.99" )
      qrsay ( XNIVEL++ , MUNICIP->Aliq_iss  , "@R 99.99" )

   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || NIL                                                 } ,"CODIGO"    })
// aadd(aEDICAO,{{ || qgetx(-1,0,@fCODIGO    , "9999", NIL,cOPCAO=="I"  ) } ,"CODIGO"    })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fVENC      , "99"                     ) } ,"VENC"      })

   aadd(aEDICAO,{{ || view_filial(-1,0,@fFILIAL ,"@!"                   ) } ,"FILIAL"    })
   aadd(aEDICAO,{{ || NIL },NIL }) // descricao do filial

   aadd(aEDICAO,{{ || view_cgm(-1,0,@fCGM                               ) } ,"CGM"       })
   aadd(aEDICAO,{{ || NIL                                                 } ,NIL         })

   aadd(aEDICAO,{{ || qgetx(-1,0,@fALIQ_BASE , "@R 99.99"               ) } ,"ALIQ_BASE" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fALIQ_ISS  , "@R 99.99"               ) } ,"ALIQ_ISS"  })
   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   MUNICIP->(qpublicfields())

   iif(cOPCAO=="I",MUNICIP->(qinitfields()),MUNICIP->(qcopyfields()))

   XNIVEL := 2
   XFLAG := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; MUNICIP->(qreleasefields()) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif

   if CONFIG->(qrlock()) .and. MUNICIP->(iif(cOPCAO=="I",qappend(),qrlock()))

      if cOPCAO == "I"
         replace CONFIG->Cod_munic with CONFIG->Cod_munic + 1
         qrsay ( 1 , fCODIGO := strzero(CONFIG->Cod_munic,4) )
         qmensa("C¢digo Gerado: "+fCODIGO,"B")
      endif

      MUNICIP->(qreplacefields())
      MUNICIP->(qunlock())

   else
      iif(cOPCAO=="I",qm1(),qm2())
   endif

   if cOPCAO == "I" ; keyboard "I" ; endif

return

/////////////////////////////////////////////////////////////////////////////
// CRITICAS NA DESCIDA ______________________________________________________

static function i_critica ( cCAMPO )

   qmensa("")

   iif ( cCAMPO == NIL , cCAMPO := "" , NIL )

   do case
//    case cCAMPO == "CODIGO"
//         if empty(fCODIGO) .or. val(fCODIGO) == 0 ; return .F. ; endif
//         qrsay(XNIVEL,fCODIGO:=strzero(val(fCODIGO),4))
//         if cOPCAO == "I"
//            if MUNICIP->(dbseek(fCODIGO))
//               qmensa("Munic¡pio j  cadastrado !","B")
//               return .F.
//            endif
//         else
//            if ! MUNICIP->(dbseek(fCODIGO))
//               qmensa("C¢digo inv lido !","B")
//               return .F.
//            endif
//         endif

      case cCAMPO == "FILIAL"

           qrsay(XNIVEL,fFILIAL:=strzero(val(fFILIAL),4))

           if FILIAL->(dbseek(fFILIAL))
              qrsay(XNIVEL+1,left(FILIAL->Razao,27))
           else
              qmensa("Filial n„o encontrado !","B")
              return .F.
           endif

      case cCAMPO == "CGM" .and. cOPCAO == "I"
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
           qrsay ( XNIVEL+1 , left(CGM->Municipio,28) + "/" + CGM->Estado )
           fCGM_DESC := CGM->Municipio

      case cCAMPO == "CGM" .and. cOPCAO == "A"
           if ! CGM->(dbseek(fCGM))
              qmensa("Municipio n„o encontrado !","B")
              return .F.
           endif
           qrsay ( XNIVEL+1 , left(CGM->Municipio,28) + "/" + CGM->Estado )
           fCGM_DESC := CGM->Municipio

      case cCAMPO == "VENC"
           qrsay(XNIVEL,fVENC:=strzero(val(fVENC),2))
           if val(fVENC) > 31 .or. val(fVENC) < 0
              qmensa("Dia do vencimento inv lido !","B")
              return .F.
           endif
   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXCLUIR MUNICIPIO ____________________________________________

static function i_exclusao

   if qconf("Confirma exclus„o deste Munic¡pio ?")
      if MUNICIP->(qrlock())
         MUNICIP->(dbdelete())
         MUNICIP->(qunlock())
      else
         qm3()
      endif
   endif

return
