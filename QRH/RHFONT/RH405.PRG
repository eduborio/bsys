/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: FOLHA DE PAGAMENTO
// OBJETIVO...: INTEGRACAO BANCARIA
// ANALISTA...: CARLOS EDUARDO RABELLO NUNES
// PROGRAMADOR: O MESMO
// INICIO.....: MAIO DE 1996
// OBS........:
// ALTERACOES.:

#include "rh.ch"

private cNOMARQ

SITUA->(dbSetFilter({|| Anomes == XANOMES},'Anomes == XANOMES'))

/////////////////////////////////////////////////////////////////////////////
// DEFINE QUAL O BANCO QUE SERA TRABALHADO __________________________________

INTBANC->(qview({{"Banco/Banco"      ,0},;
                 {"Cod_banco/C¢digo" ,0}},"P",;
                 {NIL,"f405",NIL,NIL},;
                 NIL,q_msg_acesso_usr()+"/<B>anco para Gerar Disquete"))
return

////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA DISTRIBUICAO CONFORME BANCO SELECIONADO ______________________

function f405

   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO $ XUSRA
      qlbloc(12,10,"B405F","QBLOC.GLO",1)
      qmensa(qabrev(cOPCAO,"IA",{"Inclus„o... <ESC - Cancela>","Altera‡„o... <ESC - Cancela>"}))
      i_edicao()
   endif
   setcursor(nCURSOR)

   if cOPCAO == "B"
      do case
         case INTBANC->Cod_banco == "0038"   // BANESTADO
              i_0038()
         case INTBANC->Cod_banco == "0008"   // MERIDIONAL
              i_0008()
      endcase
   endif

return ""


/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA ____________________________________

static function i_edicao

   local lCONF   := .F.
   local aEDICAO := {}
   local bESCAPE := {||empty(fBANCO).or.(XNIVEL==1.and.!XFLAG).or.(!empty(fBANCO) .and. XNIVEL==1 .and. Lastkey()==27) .or.;
                       (XNIVEL==1.and.cOPCAO=="A".and.!XFLAG)}

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"
      XNIVEL := 1
      qrsay ( XNIVEL++ , INTBANC->Banco     )
      qrsay ( XNIVEL++ , INTBANC->Cod_banco )
   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || qgetx(-1,0,@fBANCO     ,"@!")                    },"BANCO"      })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fCOD_BANCO ,"9999")                  },"COD_BANCO"  })

   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   INTBANC->(qpublicfields())
   iif(cOPCAO=="I",INTBANC->(qinitfields()),INTBANC->(qcopyfields()))

   XNIVEL  := 1
   XFLAG   := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; INTBANC->(qreleasefields()) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif

   if INTBANC->(iif(cOPCAO=="I",qappend(),qrlock()))

      // AGORA GRAVA E DESTRAVA ARQUIVO _____________________________________

      INTBANC->(qreplacefields())

   else

      if empty(INTBANC->Banco) .and. empty(INTBANC->Cod_banco)
         INTBANC->(dbdelete())
      endif

      iif(cOPCAO=="I",qm1(),qm2())

   endif

   dbunlockall()

   if cOPCAO == "I" ; keyboard "I" ; endif

return

/////////////////////////////////////////////////////////////////////////////
// CRITICA DE EDICAO ________________________________________________________

static function i_critica ( cCAMPO )

   local zTMP

   if ! XFLAG ; return .T. ; endif

   do case
      case cCAMPO == "BANCO"
          if empty(fBANCO) ; return .F. ; endif

   endcase

return .T.


/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXCLUIR VEICULO ______________________________________________

static function i_exclusao
   if qconf("Confirma exclus„o desta Integra‡„o Banc ria ?")
      if INTBANC->(qrlock())
         INTBANC->(dbdelete())
         INTBANC->(qunlock())
      else
         qm3()
      endif
   endif
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INTEGRACAO COM BANESTADO (038) _______________________________

static function i_0038

   //////////////////////////////////////////////////////////////////////////
   // DECLARACAO E INICIALIZACAO DE VARIAVEIS E RELACAO DE ARQUIVOS _________

   local bESCAPE   := {||(XNIVEL==1 .and. !XFLAG) .or. lastkey()==27}

   private sBLOCO1 := qlbloc("B405B","QBLOC.GLO")
   private sBLOCO2 := qlbloc("B405C","QBLOC.GLO")
   private sBLOCO3 := qlbloc("B405D","QBLOC.GLO")
   private sBLOCO4 := qlbloc("B405E","QBLOC.GLO")
   
   private aEDICAO := {}
   private cTIPO
   private cMOD
   private cMESANO
   private cANOMES
   private dDATAPG := ctod("")
   private cDRIVE
   private nNUMARQ := 0
   private cAMBIENTE
   private nNUMPIB := CONFIG->Num_pib + 1
   private lCONF
   private lACHOU  := .F.

   // CRIACAO DO VETOR DE BLOCOS _______________________________________________

   aadd(aEDICAO,{{ || qesco(-1,0,@cTIPO    ,SBLOCO1       )}, "TIPO"    })
   aadd(aEDICAO,{{ || qesco(-1,0,@cMOD     ,SBLOCO2       )}, "MOD"     })
   aadd(aEDICAO,{{ || qgetx(-1,0,@cMESANO  ,"99/9999"     )}, "MESANO"  })
   aadd(aEDICAO,{{ || qesco(-1,0,@cAMBIENTE,SBLOCO3       )}, "AMBIENTE"})
   aadd(aEDICAO,{{ || qesco(-1,0,@cDRIVE   ,SBLOCO4       )}, "DRIVE"   })
   aadd(aEDICAO,{{ || qgetx(-1,0,@nNUMARQ  ,"99"          )}, "NUMARQ"  })
   aadd(aEDICAO,{{ || qgetx(-1,0,@dDATAPG                 )}, "DATAPG"  })
   aadd(aEDICAO,{{ || lCONF := qconf("Confirma Grava‡„o ?")}, NIL       })

   do while .T.

      qlbloc(5,0,"B405A","QBLOC.GLO")
      qmensa()
      cDRIVE  := "A"
      cMESANO := strzero(month(XDATASYS),2) + "/" + str(year(XDATASYS),4)
      dDATAPG := ctod("")
      XNIVEL  := 1

      // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

      do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
         eval ( aEDICAO [XNIVEL,1] )
         if eval ( bESCAPE ) ; return ; endif
         if ! i_crit_1( aEDICAO[XNIVEL,2] ) ; loop ; endif
         iif ( XFLAG , XNIVEL++ , XNIVEL-- )
      enddo

      if lCONF
         FUN->(dbgotop())
         grav_0038()
      endif

   enddo
return

/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA _____________________________________________

static function i_crit_1 ( cCAMPO )
    do case
       case cCAMPO == "TIPO"
            if empty(cTIPO) ; return .F. ; endif
            qrsay(XNIVEL,qabrev(cTIPO,"CS",{"Cr‚dito Normal","Solicita‡„o de Cart„o"}))
       case cCAMPO == "MOD"
            if empty(cMOD) ; return .F. ; endif
            qrsay(XNIVEL,qabrev(cMOD,"13",{"Cr‚dito em Conta Corrente","Cr‚dito em Conta de Cart„o Pagamento"}))
       case cCAMPO == "MESANO"
            if cMESANO != "  /    "
               if at(" ",cMESANO) != 0
                  qmensa("Informa‡„o Incorreta !!","B")
                  return .F.
               endif
            else
               qmensa("Campo Obrigat¢rio !!","B")
               return .F.
            endif
         case cCAMPO == "DATAPG"
            if empty(dDATAPG)
               qmensa("Campo ‚ Obrigat¢rio !!","B")
               return .F.
            endif
      case cCAMPO == "AMBIENTE"
           qrsay(XNIVEL,qabrev(cAMBIENTE,"MADF",{"Mensal","Adiantamento","D‚cimo Terceiro","F‚rias"}))
      case cCAMPO == "DRIVE"
           qrsay(XNIVEL, cDRIVE := qabrev(cDRIVE,"ABC",{"A:","B:","C:"}))
           if cTIPO == "S"
              XNIVEL++
           endif
    endcase
return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PRINCIPAL DE GRAVACAO DO ARQUIVO DE INTEGRACAO ____________________

static function grav_0038

   local nSEQ  := 1 , cINTEG := "" , nLIQ := 0 , nTIPO1 := nTIPO2 := 0
   local nMOD1 := nMOD2 := nMOD3 := nMOD4 := nMOD5 := nMOD6 := 0

   cANOMES := right(cMESANO,2) + left(cMESANO,2)

   // ABRE ARQUIVO INTEGRA.DBF E ZERA _______________________________________

   if ! quse(XDRV_RH,"INTEGRA",NIL,"E")
      qmensa("N„o foi poss¡vel abrir arquivo INTEGRA.DBF !! Tente novamente.")
      return
   endif

   INTEGRA->(__dbzap())

   // MONTA REGISTRO TIPO 0 _________________________________________________

   cINTEG += "0PIBPgtos.Integr. Banestado01Remessa Pagtos      " + dtos(date())
   cINTEG += qtiraponto(time()) + CONFIG->Agenc_sal + CONFIG->Conta_sal + left(XRAZAO,30)
   cINTEG += space(11) + CONFIG->Chave_pib + space(6) + "PAGTOS      "
   cINTEG += strzero(nNUMPIB,6) + strzero(nSEQ,6)

   INTEGRA->(qappend())
   INTEGRA->Linha := cINTEG
   cINTEG := ""

   // MONTA REGISTROS TIPO 1 OU TIPO 2 SE SOLICITACAO DE CARTAO _____________

   do while ! FUN->(eof())
      qgirabarra()

      if ! FUN->Situacao $ "FT" .or. FUN->Modal_pag != cMOD .or. FUN->Modal_pag $ "45"
         FUN->(dbskip())
         loop
      endif

      if cTIPO == "C"
         BASE->(dbseek(FUN->Matricula + cANOMES))

         do case
            case cAMBIENTE == "M"
                 nLIQ := BASE->Prov_ms - BASE->Desc_ms
            case cAMBIENTE == "A"
                 nLIQ := BASE->Prov_ad - BASE->Desc_ad
            case cAMBIENTE == "D"
                 nLIQ := BASE->Prov_dt - BASE->Desc_dt
            case cAMBIENTE == "F"
                 nLIQ := BASE->Prov_fr - BASE->Desc_fr
         endcase

         if nLIQ <= 0
            FUN->(dbskip())
            loop
         endif

      endif

      qmensa("Funcion rio: " + FUN->Matricula + "-" + FUN->Nome)

      nSEQ++

      if cTIPO == "C"
         cINTEG := "10" + FUN->Modal_pag + strzero(val(FUN->Matricula),10) + "0000"
         cINTEG += "00" + FUN->Nome + space(10) + strzero(val(left(FUN->Csal_ban,4)),4)  + strzero(val(right(FUN->Csal_ban,4)),4)
         cINTEG += iif(FUN->Modal_pag == "1" , strzero(val(qtiraponto(FUN->Csal_num)),11) , "00000000000")
         cINTEG += right(cMESANO,4) + left(cMESANO,2)
         cINTEG += dtos(dDATAPG) + strzero(val(qtiraponto(str(nLIQ,9,2))),14) + "011"
         cINTEG += space(35) + strzero(nSEQ,6)
      else
         cINTEG := "202" + strzero(val(FUN->Matricula),10) + FUN->Nome + space(10) + "0038"
         cINTEG += strzero(val(right(FUN->Csal_ban,4)),4) + repl(" ",83) + strzero(nSEQ,6)
      endif

      INTEGRA->(qappend())
      INTEGRA->Linha := cINTEG
      cINTEG := ""

      if cTIPO == "C"
         nTIPO1++

         do case
            case FUN->Modal_pag == "1"
                 nMOD1+= nLIQ
            case FUN->Modal_pag == "3"
                 nMOD3+= nLIQ
            case FUN->Modal_pag == "4"
                 nMOD4+= nLIQ
            case FUN->Modal_pag == "5"
                 nMOD5+= nLIQ
         endcase
      else
         nTIPO2++
      endif

      FUN->(dbskip())

   enddo

   // MONTA REGISTRO TIPO 9 _________________________________________________

   nSEQ++

   cINTEG := "9" + strzero(nTIPO1,6) + strzero(nTIPO2,6) + strzero(val(qtiraponto(str(nMOD1,9,2))),15)
   cINTEG += strzero(val(qtiraponto(str(nMOD2,9,2))),15) + strzero(val(qtiraponto(str(nMOD3,9,2))),15)
   cINTEG += strzero(val(qtiraponto(str(nMOD4,9,2))),15) + strzero(val(qtiraponto(str(nMOD5,9,2))),15)
   cINTEG += strzero(val(qtiraponto(str(nMOD6,9,2))),15) + space(41) + strzero(nSEQ,6)


   INTEGRA->(qappend())
   INTEGRA->Linha := cINTEG
   cINTEG := ""

   // GRAVA ARQUIVO NO DISQUETE _____________________________________________

   qmensa("Aguarde...Gravando arquivo...","B")

   if CONFIG->(qrlock())
      replace CONFIG->Num_pib with nNUMPIB
      CONFIG->(qunlock())
   endif

   if cDRIVE != "C"
      cNOMARQ := cDRIVE + "PIB" + strzero(day(date()),2) + "A" + strzero(nNUMARQ,2) + ".ENT"
   else
      cNOMARQ := XDRV_RHX + "PIB" + strzero(day(date()),2) + "A" + strzero(nNUMARQ,2) + ".ENT"
   endif

   INTEGRA->(dbgotop())

   INTEGRA->(__dbSDF( .T., CNOMARQ , { } ,,,,, .F. ) )

   select INTBANC

return


/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INTEGRACAO COM MERIDIONAL (0008) ____________________________

static function i_0008

   //////////////////////////////////////////////////////////////////////////
   // DECLARACAO E INICIALIZACAO DE VARIAVEIS E RELACAO DE ARQUIVOS _________

   local bESCAPE   := {||(XNIVEL==1 .and. !XFLAG) .or. lastkey()==27}

   private sBLOCO1 := qlbloc("B405H","QBLOC.GLO")
   private sBLOCO2 := qlbloc("B405E","QBLOC.GLO")
   private sBLOCO3 := qlbloc("B405D","QBLOC.GLO")
   private sBLOCO4 := qlbloc("B405I","QBLOC.GLO")
   
   private aEDICAO := {}
   private cCODIGO
   private cTIPO
   private cCENTRO
   private cDT_PGTO
   private cAMBIENTE
   private cDRIVE
   private nNUMARQ := 0
   private lCONF
   private lACHOU  := .F.
   private cANOMES
   private cTESTE
   private cCAMINHO
                    
   // CRIACAO DO VETOR DE BLOCOS _______________________________________________

   aadd(aEDICAO,{{ || qgetx(-1,0,@cCODIGO  ,"999999999"   )}, "CODIGO"  })
   aadd(aEDICAO,{{ || qesco(-1,0,@cAMBIENTE,SBLOCO3       )}, "AMBIENTE"})
   aadd(aEDICAO,{{ || qesco(-1,0,@cTIPO    ,SBLOCO1       )}, "TIPO"    })
   aadd(aEDICAO,{{ || view_ccusto(-1,0,@cCENTRO)           }, "CENTRO"  })
   aadd(aEDICAO,{{ || NIL },NIL}) // descricao do centro de custo
   aadd(aEDICAO,{{ || view_sind(-1,0,@cCOD_SIND)           }, "COD_SIND"  })
   aadd(aEDICAO,{{ || NIL },NIL}) // descricao do sindicato
   aadd(aEDICAO,{{ || qgetx(-1,0,@cDT_PGTO  ,"@D"         )}, "DT_PGTO" })
   aadd(aEDICAO,{{ || qesco(-1,0,@cTESTE   ,SBLOCO4       )}, "TESTE"   })
   aadd(aEDICAO,{{ || qesco(-1,0,@cDRIVE   ,SBLOCO2       )}, "DRIVE"   })
   aadd(aEDICAO,{{ || qgetx(-1,0,@cCAMINHO ,"@!"          )}, "CAMINHO" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@cNOMARQ  ,"@!"          )}, "NOMARQ"  })
   aadd(aEDICAO,{{ || lCONF := qconf("Confirma Grava‡„o ?")}, NIL       })

   do while .T.

      qlbloc(5,0,"B405G","QBLOC.GLO")
      qmensa()
      cDRIVE    := "C"
      cDT_PGTO  := ctod("")
      cCODIGO   := "012446726"
      cCENTRO   := space(8)
      cCOD_SIND := space(4)
      cAMBIENTE := " "
      XNIVEL    := 1
      cANOMES   := space(4)
      cCAMINHO := "\ZAPT\"

      // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

      do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
         eval ( aEDICAO [XNIVEL,1] )
         if eval ( bESCAPE ) ; return ; endif
         if ! i_crit_2( aEDICAO[XNIVEL,2] ) ; loop ; endif
         iif ( XFLAG , XNIVEL++ , XNIVEL-- )
      enddo

      if lCONF
         FUN->(Dbgotop())
//       FUN->(dbsetorder(8)) // centro + nome
//       if ! FUN->(Dbseek(cCENTRO))
//          qmensa("N„o existem funcion rios Cadastrados neste Centro !","B")
//          return
//       endif
         grav_0008()
      endif

   enddo

return

/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA _____________________________________________

static function i_crit_2 ( cCAMPO )
    do case

      case cCAMPO == "AMBIENTE"
           qrsay(XNIVEL,qabrev(cAMBIENTE,"MADF",{"Mensal","Adiantamento","D‚cimo Terceiro","F‚rias"}))

       case cCAMPO == "TIPO"
            if empty(cTIPO) ; return .F. ; endif
            qrsay(XNIVEL,qabrev(cTIPO,"123",{"Inclusao de Funcionario novo","Alteracao de Funcionario ja existente","Exclusao de funcionarios ja existentes"}))

         case cCAMPO == "DT_PGTO"
            if empty(cDT_PGTO)
               qmensa("Campo ‚ Obrigat¢rio !!","B")
               return .F.
            endif
            cANOMES := qanomes(cDT_PGTO)

      case cCAMPO == "DRIVE"
           qrsay(XNIVEL, cDRIVE := qabrev(cDRIVE,"ABC",{"A:","B:","C:"}))

      case cCAMPO == "TESTE"
           qrsay(XNIVEL, cTESTE := qabrev(cTESTE,"SN",{"Sim","N„o"}))
           if left(cTESTE,1) == "S"
              cNOMARQ := "TESTE "
           else
              cNOMARQ := "SRA" + left(qtiraponto(dtoc(date())),4) + " "
           endif

      case cCAMPO == "CENTRO"

           if CCUSTO->(dbseek(cCENTRO))
              qrsay ( XNIVEL+1 , left(CCUSTO->Descricao,30) )
           else
              qmensa("Centro de Custo n„o encontrado !","B")
              return .F.
           endif

      case cCAMPO == "COD_SIND"

           if ! empty(cCOD_SIND)
              if SIND->(dbseek(cCOD_SIND))
                 qrsay ( XNIVEL+1 , left(SIND->Descricao,30) )
              else
                 qmensa("Sindicato n„o encontrado !","B")
                 return .F.
              endif
           endif

    endcase
return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PRINCIPAL DE GRAVACAO DO ARQUIVO DE INTEGRACAO ____________________




static function i_Cef //Febrabam


    //////////////////////////////////////////////
    //Monta Registro Tipo 0______________________

    cCEF := "104"     // Banco
    cCEF += "0000"    //reg de Lote
    cCEF += "0"       //Cod do Registro.
    cCEF += space(9)
    cCEF += nCNPJ     //1 Cpf       2 Cnpj
    cCEF += cCNPJ     //Cpf ou Cnpj.
    cCEF += cConvenioBanco // 6  Informado pelo banco.
    cCEF += cTransmissao   // 2  Informado pelo banco.
    cCEF += cAmbiente     // "T"este "P"roducao
    cCEF += space(1)
    cCEF += space(3)
    cCEF += "0000"
    cCEF += space(3)
    cCEF += cAgenciaCC // 5
    cCEF += cDvAgencia // 1
    cCEF += cOper+cConta     //4 + 8 = 12
    cCEF += cDvConta   // 1
    cCEF += cDvAgConta // 1
    cCEF += cEmpresa   // 30
    cCEF += cBanco     // 30
    cCEF += space(10)  // Filler
    cCEF += "1"
    cCEF += cDataGer   //DDMMAAAA
    cCEF += cHoraGer   //HHMMSS
    cCEF += nSequencia //Seq do Arquivo
    cCEF += "080"      //Versao do layout
    cCEF += "01600"    //Densidade
    cCEF += space(20)
    cCEF += space(20)
    cCEF += space(11)
    cCEF += space(3)
    cCEF += "000"
    cCEF += space(2)
    cCEF += space(10)

    //////////////////////////////////////////////
    //Monta Registro Tipo 1______________________

    cCEF := "104"
    cCEF += cLote     //4
    cCEF += "1"       //Cod reg.
    cCEF += "C"       //C - Quando for Pagto
    cCEF += "30"      //Pagamento de Salarios.
    cCEF += "01"      //Credito em Conta Corrente
    cCEF += "041"      //Versao do Layout







return

static function grav_0008

   local nSEQ  := 1 , cINTEG := "" , nLIQ := 0 , nTIPO1 := nTIPO2 := 0
   local nMOD1 := nMOD2 := nMOD3 := nMOD4 := nMOD5 := nMOD6 := nTOTAL := 0

   // ABRE ARQUIVO INTEGRA.DBF E ZERA _______________________________________

   if ! quse(XDRV_RH,"INTEGRA",NIL,"E")
      qmensa("N„o foi poss¡vel abrir arquivo INTEGRA.DBF !! Tente novamente.")
      return
   endif

   INTEGRA->(__dbzap())

   // MONTA PRIMEIRO REGISTRO ________________________________________________

   set century on

   cINTEG += transform(cCODIGO, "@R 999999999") + replicate("0",13) + "05" + "008MERIDIONAL" + qtiraponto(dtos(date())) + replicate(" ",55)

   INTEGRA->(qappend())
   INTEGRA->Linha := cINTEG
   cINTEG := ""

   // MONTA REGISTROS MOVIMENTO ______________________________________________

// FUN->(dbsetorder(8))
   FUN->(dbsetorder(2))
   FUN->(dbgotop())

   do while ! FUN->(eof())

      qgirabarra()

      SITUA->(dbseek(FUN->Matricula))

      if empty(cCOD_SIND)
//       if FUN->Centro <> cCENTRO .or. FUN->Situacao $ "DH "
         if SITUA->Ccusto <> cCENTRO .or. FUN->Situacao $ "DH "
            FUN->(dbskip())
            loop
         endif
      else
//       if FUN->Centro <> cCENTRO .or. FUN->Situacao $ "DH " .or. FUN->Sind_cod <> cCOD_SIND
         if SITUA->Ccusto <> cCENTRO .or. FUN->Situacao $ "DH " .or. FUN->Sind_cod <> cCOD_SIND
            FUN->(dbskip())
            loop
         endif
      endif

      BASE->(dbseek(FUN->Matricula + XANOMES))

      do case

         case cAMBIENTE == "M"
              nLIQ := BASE->Prov_ms - BASE->Desc_ms
         case cAMBIENTE == "A"
              nLIQ := BASE->Prov_ad - BASE->Desc_ad
         case cAMBIENTE == "D"
              nLIQ := BASE->Prov_dt - BASE->Desc_dt
         case cAMBIENTE == "F"
              nLIQ := BASE->Prov_fr - BASE->Desc_fr

      endcase

      if nLIQ <= 0
         FUN->(dbskip())
         loop
      endif

      qmensa("Funcion rio: " + FUN->Matricula + "-" + FUN->Nome)

      nSEQ++

      if left(FUN->Csal_num,2) == "40"
         cINTEG := transform(cCODIGO, "@R 999999999") + "269" + left(qtiraponto(FUN->Csal_num),10 ) + cTIPO + FUN->Nome + space(10) + "0000000000000"
         cINTEG += qtiraponto(dtos(cDT_PGTO)) + strzero(val(qtiraponto(str(nLIQ,9,2))),13) + "   "
      else
         cINTEG := transform(cCODIGO, "@R 999999999") + "269" + left(qtiraponto(FUN->Csal_num),10) + cTIPO + FUN->Nome + space(10) + "269" + left(qtiraponto(FUN->Csal_num),10)
         cINTEG += qtiraponto(dtos(cDT_PGTO)) + strzero(val(qtiraponto(str(nLIQ,9,2))),13) + "   "
      endif

      INTEGRA->(qappend())
      INTEGRA->Linha := cINTEG
      cINTEG := ""

      nTOTAL := nTOTAL + nLIQ

      FUN->(dbskip())

   enddo

   // MONTA REGISTRO TIPO TRAILLER __________________________________________

   nSEQ++

   cINTEG := transform(cCODIGO, "@R 999999999") + replicate("9",13) + strzero(nSEQ,6,0) + strzero(val(qtiraponto(str(nTOTAL,10,2))),15)
   cINTEG += space(57)

   INTEGRA->(qappend())
   INTEGRA->Linha := cINTEG
   cINTEG := ""

   // GRAVA ARQUIVO NO DISQUETE _____________________________________________

   qmensa("Aguarde...Gravando arquivo...","B")

   if left(cTESTE,1) == "S"

      cNOMARQ := cDRIVE + alltrim(cCAMINHO) + alltrim(cNOMARQ) + ".TES"

   else

      cNOMARQ := cDRIVE + alltrim(cCAMINHO) + alltrim(cNOMARQ) + ".ENT"

   endif

   INTEGRA->(dbgotop())

   INTEGRA->(__dbSDF( .T., CNOMARQ , { } ,,,,, .F. ) )

   select INTBANC

return
