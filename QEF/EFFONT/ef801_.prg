/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: ESCRITA FISCAL
// OBJETIVO...: CONFIGURACAO GERAL DO SISTEMA
// ANALISTA...: LUIS ANTONIO ORLANDO PEREIRA
// PROGRAMADOR: IN SUNG CHANG
// INICIO.....: JUNHO DE 1994
// OBS........:
// ALTERACOES.:

function ef801

// DECLARACAO DE VARIAVEIS __________________________________________________
qmensa("<ESC - Cancela>")
if ! quse("","QCONFIG") ; return ; endif

private bESCAPE := {||(XNIVEL==1 .and. !XFLAG .or. lastkey()=27.and.XNIVEL==1) }
private aEDICAO    := {}
private lCONF      := .F.
private sBLOC1     := qlbloc("B801B","QBLOC.GLO")
private sBLOC2     := qlbloc("B801C","QBLOC.GLO")
private sBLOC3     := qlbloc("B801D","QBLOC.GLO")
private sBLOC4     := qlbloc("B801E","QBLOC.GLO")
private sBLOC5     := qlbloc("B801F","QBLOC.GLO")

private cCONT_NOME  := QCONFIG->Cont_Nome
private cCONT_RG    := QCONFIG->Cont_Rg
private cCONT_CRC   := QCONFIG->Cont_Crc
private cCONT_FONE  := QCONFIG->Cont_Fone
private cSUBTOTAL   := QCONFIG->Subtotal
private cVERIFICA   := QCONFIG->Verifica
private cUSA_UFIR   := QCONFIG->Usa_Ufir
private cTIPO_GIA   := QCONFIG->Tipo_Gia
private cTIPO_GIAR  := QCONFIG->Tipo_Giar
private cFILT_ICMS  := QCONFIG->Filt_icms
private cTIPO_FAT   := CONFIG->Tipo_fat
private cTPO_ISS    := CONFIG->Tpo_iss

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

qlbloc(5,0,"B801A","QBLOC.GLO",1)

aadd(aEDICAO,{{ || qgetx(-1,0,@cCONT_NOME ,"@!"  ) },"CONT_NOME" })
aadd(aEDICAO,{{ || qgetx(-1,0,@cCONT_FONE ,"@9"  ) },"CONT_FONE" })
aadd(aEDICAO,{{ || qgetx(-1,0,@cCONT_RG   ,"@!"  ) },"CONT_RG"   })
aadd(aEDICAO,{{ || qgetx(-1,0,@cCONT_CRC  ,"@R XX-999999/X-9"  ) },"CONT_CRC"  })
aadd(aEDICAO,{{ || qesco(-1,0,@cSUBTOTAL  ,sBLOC1) },"SUBTOTAL"  })
aadd(aEDICAO,{{ || qesco(-1,0,@cVERIFICA  ,sBLOC2) },"VERIFICA"  })
aadd(aEDICAO,{{ || qesco(-1,0,@cUSA_UFIR  ,sBLOC3) },"USA_UFIR"  })
aadd(aEDICAO,{{ || qgetx(-1,0,@cTIPO_GIA  ,"@9"  ) },"TIPO_GIA"  })
aadd(aEDICAO,{{ || qgetx(-1,0,@cTIPO_GIAR ,"@9"  ) },"TIPO_GIAR" })
aadd(aEDICAO,{{ || qesco(-1,0,@cFILT_ICMS ,sBLOC4) },"FILT_ICMS" })
aadd(aEDICAO,{{ || qesco(-1,0,@cTIPO_FAT ,sBLOC5 ) } ,"TIPO_FAT" })
aadd(aEDICAO,{{ || view_tpo(-1,0,@cTPO_ISS       ) } ,"TPO_ISS" })

aadd(aEDICAO,{{ || lCONF := qconf("Confirma altera‡„o ?") },"CONF"})

// INICIALIZACAO DE CAMPOS E TELA ___________________________________________

XNIVEL := 1

qrsay ( XNIVEL++ , cCONT_NOME )
qrsay ( XNIVEL++ , cCONT_FONE )
qrsay ( XNIVEL++ , cCONT_RG   )
qrsay ( XNIVEL++ , cCONT_CRC,"@R XX-999999/X-9"  )
qrsay ( XNIVEL++ , qabrev(cSUBTOTAL,"12",{"Sim","N„o" }))
qrsay ( XNIVEL++ , qabrev(cVERIFICA,"12",{"Sim","N„o" }))
qrsay ( XNIVEL++ , qabrev(cUSA_UFIR,"12",{"Sim","N„o" }))
qrsay ( XNIVEL++ , cTIPO_GIA  )
qrsay ( XNIVEL++ , cTIPO_GIAR )
qrsay ( XNIVEL++ , qabrev(cFILT_ICMS,"12",{"Sim","N„o" }))
qrsay ( XNIVEL++ , qabrev(CONFIG->Tipo_fat,"123456789A", {"Comercial","Industrial","Servi‡os","Tele-Vendas","Transportes","Concretagem","Loja","Acessoria","Fabrica","Outro Sistema"}))
qrsay ( XNIVEL++ , cTPO_ISS   )

XNIVEL := 1
XFLAG  := .T.

// LOOP PARA ENTRADA DOS DADOS ______________________________________________

do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
   eval ( aEDICAO [XNIVEL,1] )
   if eval ( bESCAPE ) ; return ; endif
   if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
   iif ( XFLAG , XNIVEL++ , XNIVEL-- )
enddo

// GRAVACAO _________________________________________________________________

if lCONF

   if QCONFIG->(qrlock())

      replace QCONFIG->Cont_Nome  with cCONT_NOME
      replace QCONFIG->Cont_Fone  with cCONT_FONE
      replace QCONFIG->Cont_Rg    with cCONT_RG
      replace QCONFIG->Cont_Crc   with cCONT_CRC
      replace QCONFIG->Subtotal   with cSUBTOTAL
      replace QCONFIG->Verifica   with cVERIFICA
      replace QCONFIG->Usa_Ufir   with cUSA_UFIR
      replace QCONFIG->Tipo_Gia   with cTIPO_GIA
      replace QCONFIG->Tipo_Giar  with cTIPO_GIAR
      replace QCONFIG->Filt_icms  with cFILT_ICMS

      QCONFIG->(qunlock())

   else

      qmensa("N„o foi poss¡vel alterar a configura‡„o, tente novamente","B")

   endif

   if CONFIG->(qrlock())
      replace CONFIG->Tipo_fat with cTIPO_FAT
      replace CONFIG->Tpo_iss  with cTPO_ISS
      CONFIG->(qunlock())
   endif

endif

QCONFIG->(dbclosearea())

return

/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA _____________________________________________

static function i_critica ( cCAMPO )

   do case
      case cCAMPO == "SUBTOTAL"
           if empty(cSUBTOTAL) ; return .F. ; endif
           qrsay(XNIVEL,qabrev(cSUBTOTAL,"12",{"Sim","N„o"}))

      case cCAMPO == "VERIFICA"
           if empty(cVERIFICA) ; return .F. ; endif
           qrsay(XNIVEL,qabrev(cVERIFICA,"12",{"Sim","N„o"}))

      case cCAMPO == "USA_UFIR"
           if empty(cUSA_UFIR) ; return .F. ; endif
           qrsay(XNIVEL,qabrev(cUSA_UFIR,"12",{"Sim","N„o"}))

      case cCAMPO == "TIPO_GIA"
           if empty(cTIPO_GIA) ; return .F. ; endif
           qrsay(XNIVEL,cTIPO_GIA:=strzero(val(cTIPO_GIA),2))

      case cCAMPO == "TIPO_GIAR"
           if empty(cTIPO_GIAR) ; return .F. ; endif
           qrsay(XNIVEL,cTIPO_GIAR:=strzero(val(cTIPO_GIAR),2))

      case cCAMPO == "FILT_ICMS"
           if empty(cFILT_ICMS) ; return .F. ; endif
           qrsay(XNIVEL,qabrev(cFILT_ICMS,"12",{"Sim","N„o"}))

      case cCAMPO == "TIPO_FAT"
           if empty(cTIPO_FAT) ; return .F. ; endif
           qrsay(XNIVEL,qabrev(cTIPO_FAT,"123456789A", {"Comercial","Industrial","Servi‡os","Tele-Vendas","Transportes","Concretagem","Loja","Acessoria","Fabrica","Outro Sistema"}))

      case cCAMPO == "TPO_ISS"
           if ! empty(cTPO_ISS)
              if ! TIPOCONT->(dbseek(cTPO_ISS))
                  qmensa("Tipo Cont bil n„o encontrado...","B")
                  return .F.
              else
                if len(TIPOCONT->Codigo) <> 6
                   qmensa("C¢digo Inv lido...","B")
                   return .F.
                endif
              endif
           endif

   endcase
   
return .T.
