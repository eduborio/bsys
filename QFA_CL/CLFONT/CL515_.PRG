/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO COMERCIO
// OBJETIVO...: IMPRESSAO DE FATURAS
// ANALISTA...: EDUARDO AUGUSTO BORIO
// PROGRAMADOR: O MESMO
// INICIO.....: OUTUBRO DE 1998
// OBS........:
// ALTERACOES.: EDUARDO AUGUSTO BORIO
//

function cl515
#define K_MAX_LIN 52
//#include "common.ch"
#include "hbclass.ch"

//#ifndef __XHARBOUR__
//  #include "hbwin.ch"
//   #include "harupdf.ch"
//   #include "hbzebra.ch"
//   #include "hbcompat.ch"
//#endif

#include "c:\hbnfe\include\hbnfe.ch"
#include "hbblat.ch"
#include "hbcompat.ch"

private cFATURA       // codigo da fatura
private cPEDIDOS   := ""
private nVAL       := 0
private lPENDENCIA := .F.
private nDESC     := 0
private nVAL_UNI  := nTOT_PROD := nICMS := nVALOR := nALIQ_ICMS := nICM_SUBS := nTOT_GER := 0
private cFRETE    := " "
private nVALOR_FR := 0
private nALIQ_FR := 0
private nEXTENSO  := 0
private nOUTRAS   := 0
private nBASE     := 0
private cTRANSPOR := Space(23)
private cQUANT    := 0
private cESPECIE  := ""
private cPESOBR   := 0
private nPAGINAS  := 0
private nPAG_ATUAL:= 0
private cPESOLQ   := 0
private cNUMERO   := ""
private cMARCA    := ""
private cIPI      := space(3)
private nALIQ     := 0
private nFOL      := 0
private dIPI      := 0
private dICMS     := 0
private dBASE     := 0
private dTOT_PROD := 0
private dTOT_GER  := 0
private dTOT_DESC := 0
private dTOT_SUBS := 0
private lPAG      := .F.
private lPRIM     := .F.
private nREGISTRO := 0
private cCLASS    := space(2)
private aCLASS    := {}
private asCLASS   := {}
private afCLASS   := {}
private lCONTINUA := .F.
private nNOTAS    :=  0
private cES       :=  "S"
private XDRV_NFE  := "C:\ACBrNFeMonitor\"

private sBLOC1  := qlbloc("B515B","QBLOC.GLO")

//FAT->(dbsetfilter({|| FAT->Dt_emissao > ctod("24/09/2010") }))
//{"FAT->Dt_emissao > ctod('24/09/2010')",{||f515top()},{||f515bot()}},;

/////////////////////////////////////////////////////////////////////////////
// MANUTENCAO DAS FATURAS __________________________________________________
if CONFIG->Modelo_fat $ "12"
   FAT->(qview({{"Codigo/Pedido"         ,1},;
                {"Dt_emissao/Emissao"    ,2},;
                {"i_515a()/Cliente"      ,7},;
                {"i_Status()/Status"     ,0},;
                {"Num_fatura/Fatura"     ,11}},"P",;
                {NIL,"i_515c",NIL,NIL},;
                NIL,"<G>erar/<N>Enviar NFe/<C>ancelar/<P> DAnfe/<I>Etiq.Transp/<A>lmox/<V>ol"))

else
  if CONFIG->Modelo_NF == "01"

     FAT->(qview({{"Codigo/Pedido"         ,12},;
                  {"Dt_emissao/Emissao"    ,2},;
                  {"i_515a()/Cliente"      ,7},;
                  {"i_Status()/Status"     ,0},;
                  {"Num_fatura/Fatura"     ,11}},"P",;
                  {NIL,"i_515c",NIL,NIL},;
                  NIL,"<G>erar Num. NFe / <N>Envia NFe / <C>ancela NFe /<I>nutiliza NFe/ <P>Reimp. DAnfe "))
  else
     FAT->(qview({{"Codigo/Pedido"         ,12},;
                  {"Dt_emissao/Emissao"    ,2},;
                  {"i_515a()/Cliente"      ,7},;
                  {"i_Locked()/Trav."      ,0},;
                  {"Num_fatura/Fatura"     ,11}},"P",;
                  {NIL,"i_515c",NIL,NIL},;
                  NIL,"<E>mitir Faturas   <G>erar Numero Nota  <C>orrigir No NF"))


  endif
endif

return

function f515top
   FAT->(dbsetorder(2))
   FAT->(dbseek(dtos(ctod("27/09/2010"))))
return

function f515bot
   FAT->(dbsetorder(2))
   FAT->(dbgobottom())
return



//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAGEM DO CLIENTE ______________________________________________

function i_515a
local cRAZAO := space(38)

   CLI1->(dbseek(FAT->Cod_cli))
   cRAZAO := left(CLI1->Razao,38)

return cRAZAO
//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO _____________________________________

function i_515c

   local lCONF := .F.
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO == "M"
      alert("Enviar Mail")
      //blat()
   endif


   if CONFIG->NFE != "S"
      if cOPCAO == "E"
         nREC = FAT->(recno())
         if (CONFIG->Modelo_2 $ "3*9*1" .or. CONFIG->Modelo_fat == "4")
            qlbloc(10,14,"B515C","QBLOC.GLO",1)
         else
            qlbloc(12,17,"B515A","QBLOC.GLO",1)
         endif
         i_edicao()
      endif
   endif


   if CONFIG->Modelo_fat == "1"

      if cOPCAO == "I"
         i_etiqueta()
      endif
   else
      if CONFIG->Nfe == "S"
         if cOPCAO == "I"
             InutilizarNFe("ENT.TXT")
         endif
      endif
   endif

   if CONFIG->Nfe == "S"
      if cOPCAO == "N"

         if FAT->Status == "105"
            alert("NFe em processamento nos servidores da SEFA-PR. Aguarde!")
            return .F.
         endif

         if FAT->Status == "100"
            alert("NFe ja foi emitida!")
            return .F.
         endif


         nREC = FAT->(recno())
         if (CONFIG->Modelo_2 $ "3*9*1" .or. CONFIG->Modelo_fat == "4")
            qlbloc(10,14,"B515C","QBLOC.GLO",1)
         else
            qlbloc(12,17,"B515A","QBLOC.GLO",1)
         endif

         i_edicaoNFe(iif(CONFIG->scan,"3","1"))

      endif
	  

      if cOPCAO == "V"
         nREC = FAT->(recno())
         if (CONFIG->Modelo_2 $ "3*9*1" .or. CONFIG->Modelo_fat == "4")
            qlbloc(10,14,"B515C","QBLOC.GLO",1)
         else
            qlbloc(12,17,"B515A","QBLOC.GLO",1)
         endif

         i_edicaoVol()
      endif


      if cOPCAO == "C"
         if FAT->status == "105"
            qmensa("Nota em processamento, nao foi possivel cancelar!","BL")
            return .F.
         else
		    CancelarNfe()
		 endif		   
      endif
	  
	  if cOPCAO == "R"
		    CancelarLocalOnly()
      endif

      if cOPCAO == "P"
         ImprimirDanfe("ENT.TXT")
      endif

      if cOPCAO == "T"
         InutilizarNFe("ENT.TXT")
      endif
	  
	  if cOPCAO == "L"
	     
		 cTipo := iif(CONFIG->scan,"3","1")

         if FAT->(qrlock())
            replace FAT->Nfe       with getNFe( cTipo ) + qdigNFe(getNFe(cTipo))
            replace FAT->Modelo    with "55"
            FAT->(qunlock())
         endif
	  
		 cXml := ""
		 cXml := CONFIG->Unidade+":\Qsys_g\Qfa_cl\Nfe\Autorizadas\"+FAT->NFe+"-NFe.xml"
		 
		 aRetorno := consultaNFe(buildNFe(),cXml)
		 
		 IF aRetorno['OK'] == .F.
           cRetorno :=  aRetorno['MsgErro']
		   alert(cRetorno)
		   return .F.
        ELSE
           cStatus := aRetorno['cStat']
           cMotivo := aRetorno['xMotivo']
        ENDIF
		 
		 do case
                case cSTATUS == "100"
                     alert("NFe Autorizada! ;"+FAT->NFe)
                     if FAT->(qrlock())
                        replace FAT->Status    with cStatus
                        FAT->(qunlock())
                     endif


                case cSTATUS == "105"
                     if FAT->(qrlock())
                        replace FAT->Status    with cStatus
                        FAT->(qunlock())
                     endif

                     alert(cStatus+";"+cMotivo+";Aguarde um momento e tente novamente!")

                otherwise
                     alert("NFe Nao autorizada! ;"+cStatus+";"+cMotivo)

             endcase
      endif

   endif

   //if cOPCAO == "T"
   //   i_2etiqueta()
   //endif

   if CONFIG->Modelo_fat == "1"
      if cOPCAO == "A"
         qlbloc(10,10,"B515AL","QBLOC.GLO")
         i_almoxarifes()
      endif
   endif

   if cOPCAO == "S"
      i_Subst()
   endif


   //if CONFIG->NFE == "S"
      if cOPCAO == "G"
         i_geraNF(iif(CONFIG->scan,"3","1"))
      endif
   //endif


   if CONFIG->Modelo_fat == "1"
      if cOPCAO == "F"
         i_Filtro()
      endif

      if cOPCAO == "Y"
               ImprimirDanfePdf("ENT.TXT")

      endif

   endif

   setcursor(nCURSOR)

return ""

//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA _________________________________________

static function i_edicao
   local lCONF := .F.
   local aEDICAO := {}
   local bESCAPE := {||empty(cFATURA).or.(XNIVEL==1.and.!XFLAG).or.;
                       (XNIVEL==1.and.lastkey()==27)}
   cQUANT   := FAT->Qtde_vol
   cESPECIE := FAT->Especie
   cMARCA   := FAT->Marca
   cNUMERO  := FAT->Numero
   cPESOBR  := FAT->Peso_bruto
   cPESOLQ  := FAT->Peso_liqui
   cFRETE   := FAT->Frete
   nVALOR_FR:= FAT->Valor_fr
   nALIQ_FR := FAT->Aliq_fr

   cTRANSPOR:= Space(23)
   nOUTRAS  := 0
   nIPI     := space(3)
   nALIQ    := 0
   nFOL     := 0
   dIPI      := 0
   dICMS     := 0
   dBASE     := 0
   dTOT_PROD := 0
   dTOT_GER  := 0
   dTOT_DESC := 0
   dICMS_SUBS:= 0
   cADIANTA := 0
   cIRRF := 0
   cISS := 0
   cCPMF := 0
   lPAG  := .F.
   nREGSIDTRO := 0
   // CRIACAO DO VETOR DE BLOCOS _______________________________________________

   if CONFIG->NFE == "S"
      aadd(aEDICAO,{{ || NIL}, "FATURA" })
   else
      if CONFIG->Modelo_2 != "7".or. CONFIG->modelo_fat != "3"
         aadd(aEDICAO,{{ || qgetx(-1,0,@cFATURA                    )}, "FATURA"  })
      else
         aadd(aEDICAO,{{ || NIL}, "FATURA" })
      endif
   endif

   aadd(aEDICAO,{{ || qesco(-1,0,@cFRETE,sBLOC1              )}, "FRETE"   })
   aadd(aEDICAO,{{ || qgetx(-1,0,@nALIQ_FR,"@E 99.99"        )}, "ALIQ_FR" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@nVALOR_FR,"@R 9,999,999.99")}, NIL       })
   aadd(aEDICAO,{{ || qgetx(-1,0,@nOUTRAS ,"@R 9,999,999.99" )}, NIL       })
   aadd(aEDICAO,{{ || qgetx(-1,0,@cTRANSPOR ,"@X!"           )}, NIL       })
   aadd(aEDICAO,{{ || qgetx(-1,0,@cQUANT,"@R 999999.999"          )}, "QUANT"   })
   aadd(aEDICAO,{{ || qgetx(-1,0,@cESPECIE,"@!"              )}, "ESPECIE" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@cPESOBR, "999999.999"        )}, "PESOBR"  })
   aadd(aEDICAO,{{ || qgetx(-1,0,@cMARCA, "@!"               )}, "MARCA"   })
   aadd(aEDICAO,{{ || qgetx(-1,0,@cPESOLQ, "999999.999"        )}, "PESOLQ"  })
   aadd(aEDICAO,{{ || qgetx(-1,0,@cNUMERO, "@!"              )}, "NUMERO"  })

   if CONFIG->Modelo_2 $ "3*9*1" .or. CONFIG->Modelo_fat == "4"
      aadd(aEDICAO,{{ || qesco(-1,0,@cIPI,XSN                )}, "IPI"   })
   endif

   if CONFIG->NFE == "S"
      aadd(aEDICAO,{{ || lCONF := qconf("Confirma Envio de NFe ?") },NIL})
   else
      aadd(aEDICAO,{{ || lCONF := qconf("Confirma Impress„o das Notas Fiscais ?") },NIL})
   endif
   XNIVEL := 1

   do while .T.

      if CONFIG->NFE == "S"
         cFATURA   := FAT->Num_fatura
      else
         if CONFIG->Modelo_2 == "7" .or. CONFIG->modelo_fat == "3"
           cFATURA   := FAT->Num_fatura
         else
           cFATURA   := strzero(CONFIG->Cod_fat + 1,6)
         endif

      endif


      // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

      do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
         eval ( aEDICAO [XNIVEL,1] )
         if eval ( bESCAPE )
            return
         endif
         if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
         iif ( XFLAG , XNIVEL++ , XNIVEL-- )
      enddo

      if ! lCONF ; return ; endif


      zTMP_PRN := XCOD_PRN
      XCOD_PRN := "11"

      if ! qinitprn()
         return
      endif

      iif ( i_inicializacao(), i_imp() ,  )

      qstopprn(.F.)
      XCOD_PRN := zTMP_PRN
      if FAT->(qrlock())
         replace FAT->Qtde_vol   with cQUANT
         replace FAT->Marca      with cMARCA
         replace FAT->Numero     with cNUMERO
         replace FAT->Especie    with cESPECIE
         replace FAT->Peso_bruto with cPESOBR
         replace FAT->Peso_liqui with cPESOLQ
         replace FAT->Aliq_fr    with nALIQ_FR
         replace FAT->Valor_fr   with nVALOR_FR
         FAT->(Qunlock())
      endif


      exit

   enddo


return

//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA _________________________________________

static function i_edicaoNFe(cFormaEmissao)

   local lCONF
   local aEDICAO := {}
   local bESCAPE := {||empty(cFATURA).or.(XNIVEL==1.and.!XFLAG).or.;
                       (XNIVEL==1.and.lastkey()==27)}
   cQUANT   := FAT->Qtde_vol
   cESPECIE := FAT->Especie
   cMARCA   := FAT->Marca
   cNUMERO  := FAT->Numero
   cPESOBR  := FAT->Peso_bruto
   cPESOLQ  := FAT->Peso_liqui
   cFRETE   := FAT->Frete
   nVALOR_FR:= FAT->Valor_fr
   nALIQ_FR := FAT->Aliq_fr

   cTRANSPOR:= Space(23)
   nOUTRAS  := 0
   nIPI     := space(3)
   nALIQ    := 0
   nFOL     := 0
   dIPI      := 0
   dICMS     := 0
   dBASE     := 0
   dTOT_PROD := 0
   dTOT_GER  := 0
   dTOT_DESC := 0
   dICMS_SUBS:= 0
   cADIANTA := 0
   cIRRF := 0
   cISS := 0
   cCPMF := 0
   lPAG  := .F.
   nREGSIDTRO := 0
   // CRIACAO DO VETOR DE BLOCOS _______________________________________________

   if CONFIG->NFE == "S"
      aadd(aEDICAO,{{ || NIL}, "FATURA" })
   else
      if CONFIG->Modelo_2 != "7".or. CONFIG->modelo_fat != "3"
         aadd(aEDICAO,{{ || qgetx(-1,0,@cFATURA                    )}, "FATURA"  })
      else
         aadd(aEDICAO,{{ || NIL}, "FATURA" })
      endif
   endif

   aadd(aEDICAO,{{ || qesco(-1,0,@cFRETE,sBLOC1              )}, "FRETE"   })
   aadd(aEDICAO,{{ || qgetx(-1,0,@nALIQ_FR,"@E 99.99"        )}, "ALIQ_FR" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@nVALOR_FR,"@R 9,999,999.99")}, NIL       })
   aadd(aEDICAO,{{ || qgetx(-1,0,@nOUTRAS ,"@R 9,999,999.99" )}, NIL       })
   aadd(aEDICAO,{{ || qgetx(-1,0,@cTRANSPOR ,"@X!"           )}, NIL       })
   aadd(aEDICAO,{{ || qgetx(-1,0,@cQUANT,"@R 999999.999"          )}, "QUANT"   })
   aadd(aEDICAO,{{ || qgetx(-1,0,@cESPECIE,"@!"              )}, "ESPECIE" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@cPESOBR, "999999.999"        )}, "PESOBR"  })
   aadd(aEDICAO,{{ || qgetx(-1,0,@cMARCA, "@!"               )}, "MARCA"   })
   aadd(aEDICAO,{{ || qgetx(-1,0,@cPESOLQ, "999999.999"        )}, "PESOLQ"  })
   aadd(aEDICAO,{{ || qgetx(-1,0,@cNUMERO, "@!"              )}, "NUMERO"  })
   if CONFIG->Modelo_2 $ "3*9*1" .or. CONFIG->Modelo_fat == "4"
      aadd(aEDICAO,{{ || qesco(-1,0,@cIPI,XSN                )}, "IPI"   })
   endif

   if CONFIG->NFE == "S"
      aadd(aEDICAO,{{ || lCONF := qconf("Confirma Envio de NFe ?") },NIL})
   else
      aadd(aEDICAO,{{ || lCONF := qconf("Confirma Impress„o das Notas Fiscais ?") },NIL})
   endif
   XNIVEL := 1

   do while .T.

      if CONFIG->NFE == "S"
         cFATURA   := FAT->Num_fatura
      else
         if CONFIG->Modelo_2 == "7" .or. CONFIG->modelo_fat == "3"
           cFATURA   := FAT->Num_fatura
         else
           cFATURA   := strzero(CONFIG->Cod_fat + 1,6)
         endif

      endif


      // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

      do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
         eval ( aEDICAO [XNIVEL,1] )
         if eval ( bESCAPE )
            return
         endif
         if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
         iif ( XFLAG , XNIVEL++ , XNIVEL-- )
      enddo

      if ! lCONF ; return ; endif

      if FAT->(qrlock())
         replace FAT->Qtde_vol   with cQUANT
         replace FAT->Marca      with cMARCA
         replace FAT->Numero     with cNUMERO
         replace FAT->Especie    with cESPECIE
         replace FAT->Peso_bruto with cPESOBR
         replace FAT->Peso_liqui with cPESOLQ
         replace FAT->Aliq_fr    with nALIQ_FR
         replace FAT->Valor_fr   with nVALOR_FR
         FAT->(Qunlock())
      endif

      CriarNFe("ENT.TXT",cFormaEmissao)

   exit

   enddo


return

static function i_edicaoVol

   local lCONF
   local aEDICAO := {}
   local bESCAPE := {||empty(cFATURA).or.(XNIVEL==1.and.!XFLAG).or.;
                       (XNIVEL==1.and.lastkey()==27)}
   cQUANT   := FAT->Qtde_vol
   cESPECIE := FAT->Especie
   cMARCA   := FAT->Marca
   cNUMERO  := FAT->Numero
   cPESOBR  := FAT->Peso_bruto
   cPESOLQ  := FAT->Peso_liqui
   cFRETE   := FAT->Frete
   nVALOR_FR:= FAT->Valor_fr
   nALIQ_FR := FAT->Aliq_fr

   cTRANSPOR:= Space(23)
   nOUTRAS  := 0
   nIPI     := space(3)
   nALIQ    := 0
   nFOL     := 0
   dIPI      := 0
   dICMS     := 0
   dBASE     := 0
   dTOT_PROD := 0
   dTOT_GER  := 0
   dTOT_DESC := 0
   dICMS_SUBS:= 0
   cADIANTA := 0
   cIRRF := 0
   cISS := 0
   cCPMF := 0
   lPAG  := .F.
   nREGSIDTRO := 0
   // CRIACAO DO VETOR DE BLOCOS _______________________________________________

   if CONFIG->NFE == "S"
      aadd(aEDICAO,{{ || NIL}, "FATURA" })
   else
      if CONFIG->Modelo_2 != "7".or. CONFIG->modelo_fat != "3"
         aadd(aEDICAO,{{ || qgetx(-1,0,@cFATURA                    )}, "FATURA"  })
      else
         aadd(aEDICAO,{{ || NIL}, "FATURA" })
      endif
   endif

   aadd(aEDICAO,{{ || qesco(-1,0,@cFRETE,sBLOC1              )}, "FRETE"   })
   aadd(aEDICAO,{{ || qgetx(-1,0,@nALIQ_FR,"@E 99.99"        )}, "ALIQ_FR" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@nVALOR_FR,"@R 9,999,999.99")}, NIL       })
   aadd(aEDICAO,{{ || qgetx(-1,0,@nOUTRAS ,"@R 9,999,999.99" )}, NIL       })
   aadd(aEDICAO,{{ || qgetx(-1,0,@cTRANSPOR ,"@X!"           )}, NIL       })
   aadd(aEDICAO,{{ || qgetx(-1,0,@cQUANT,"@R 999999.999"          )}, "QUANT"   })
   aadd(aEDICAO,{{ || qgetx(-1,0,@cESPECIE,"@!"              )}, "ESPECIE" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@cPESOBR, "999999.999"        )}, "PESOBR"  })
   aadd(aEDICAO,{{ || qgetx(-1,0,@cMARCA, "@!"               )}, "MARCA"   })
   aadd(aEDICAO,{{ || qgetx(-1,0,@cPESOLQ, "999999.999"        )}, "PESOLQ"  })
   aadd(aEDICAO,{{ || qgetx(-1,0,@cNUMERO, "@!"              )}, "NUMERO"  })
   if CONFIG->Modelo_2 $ "3*9*1" .or. CONFIG->Modelo_fat == "4"
      aadd(aEDICAO,{{ || qesco(-1,0,@cIPI,XSN                )}, "IPI"   })
   endif

   aadd(aEDICAO,{{ || lCONF := qconf("Confirma Alteracao de dados ?") },NIL})
   XNIVEL := 1

   do while .T.

      if CONFIG->NFE == "S"
         cFATURA   := FAT->Num_fatura
      endif


      // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

      do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
         eval ( aEDICAO [XNIVEL,1] )
         if eval ( bESCAPE )
            return
         endif
         if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
         iif ( XFLAG , XNIVEL++ , XNIVEL-- )
      enddo

      if ! lCONF ; return ; endif

      if FAT->(qrlock())
         replace FAT->Qtde_vol   with cQUANT
         replace FAT->Marca      with cMARCA
         replace FAT->Numero     with cNUMERO
         replace FAT->Especie    with cESPECIE
         replace FAT->Peso_bruto with cPESOBR
         replace FAT->Peso_liqui with cPESOLQ
         replace FAT->Aliq_fr    with nALIQ_FR
         replace FAT->Valor_fr   with nVALOR_FR
         FAT->(Qunlock())
      endif

   exit

   enddo


return



/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA _____________________________________________

static function i_critica ( cCAMPO )
   do case
      case cCAMPO == "FATURA"

        qrsay(XNIVEL,cFATURA)
        //if empty(cFATURA) ; return .F. ; endif
        if CONFIG->Modelo_2 == "1"
           cIPI := "N"
        endif

        if CONFIG->Modelo_2 == "7" .or. CONFIG->Modelo_fat ==  "3"

           if empty(FAT->Num_fatura)
              qmensa("Numero da Nota em Branco, Gere um numero de Nota !","B")
              return .F.
           endif


           i_peso()

           //nALIQ_FR := 10
           nPAGINAS   := 0
           nPAG_ATUAL := 1


           //if ! DUP_FAT->(Dbseek(FAT->Codigo+"01")) .and. left(FAT->Cod_cfop,3) $ "510-610" .and. FAT->Tipo_doc != "01"
           //   qmensa("Valor das Duplicatas nÆo foi Lancado !!!","B")
           //   return .F.
           //endif

           //nPAGINAS := i_totPages()

        endif

        if CONFIG->Modelo_fat $ "1"

           if ! FAT->Fechado .and. FAT->Es != "E"
              qmensa("Pedido em Aberto, Verifique !","B")
              return .F.
           endif

           i_duplicado()


           if ! DUP_FAT->(Dbseek(FAT->Codigo+"01")) .and. left(FAT->Cod_cfop,3) $ "510-610"
              qmensa("Valor das Duplicatas nÆo foi Lancado !!!","B")
           endif

           nPAGINAS   := 0
           nPAG_ATUAL := 1

           nICMS     := 0
           nIPI      := 0
           nTOT_SUBS := 0
           nBASE     := 0
           nLINHA    := 0
           nRESTO    := 0
           nCONT     := 0
           nDESC     := 0
           nEXTENSO  := 0
           nTOT_PROD := 0
           nTOT_GER  := 0

           nPAGINAS := i_ver_parcs()

        endif

      case cCAMPO == "FRETE"
           if empty(cFRETE) ; return .F. ; endif
           qrsay(XNIVEL,qabrev(cFRETE,"12",{"1 - Emitente","2 - Destinatario"}))

      case cCAMPO == "IPI"
           if empty(cIPI) ; return .F. ; endif
           qrsay(XNIVEL,qabrev(cIPI,"SN",{"Sim","N„o"}))


   endcase
return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   PROD->(dbsetorder(4))

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A SELECAO DO MODELO DE NOTA FISCAL _____________________

static function i_imp


return .T.

/////////////////////////////////////////////////////////////////////////////
// IMPRESSAO DE FATURA (MODELO 1 - CHAMATA)___________________________________


/////////////////////////////////////////////////////////////////////////////
// CALCULO DA FORMA DE PAGAMENTO ___________________________________________

function i_calc_dup1

return


/////////////////////////////////////////////////////////////////////////////
// LOOP DE CONTROLE DE IMPRESSAO (MODELO 2 - ASSOMA) _______________________

static function i_imp2

return




function i_almoxarifes
   local lCONF
   local aEDICAO := {}
   local bESCAPE := {||(XNIVEL==1.and.!XFLAG).or.;
                       (XNIVEL==1.and.lastkey()==27)}


   // CRIACAO DO VETOR DE BLOCOS _______________________________________________

   aadd(aEDICAO,{{ || qgetx(-1,0,@fCOL_INI,"99:99"            )},"COL_INI"   })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fCOL_FIM,"99:99"            )},"COL_FIM" })
   aadd(aEDICAO,{{ || NIL           },NIL })
   aadd(aEDICAO,{{ || view_alm(-1,0,@fCOL_ALM                 )} ,"COL_ALM"})
   aadd(aEDICAO,{{ || NIL           },NIL })

   aadd(aEDICAO,{{ || qgetx(-1,0,@fEXP_INI,"99:99"            )},"EXP_INI"   })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fEXP_FIM,"99:99"            )},"EXP_FIM" })
   aadd(aEDICAO,{{ || NIL           },NIL })
   aadd(aEDICAO,{{ || view_alm(-1,0,@fEXP_ALM                 )} ,"EXP_ALM"})
   aadd(aEDICAO,{{ || NIL           },NIL })


   aadd(aEDICAO,{{ || lCONF := qconf("Confirma Alteracao ?"   )},NIL})

   FAT->(qpublicfields())
   FAT->(qcopyfields())

   XNIVEL  := 1
   XFLAG   := .T.


   do while .T.

      // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

      do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
         eval ( aEDICAO [XNIVEL,1] )
         if eval ( bESCAPE ) ; FAT->(qreleasefields()) ;return ; endif
         if ! i_2critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
         iif ( XFLAG , XNIVEL++ , XNIVEL-- )
      enddo

      if ! lCONF ; return ; endif

      if FAT->(qrlock())
         FAT->(qreplacefields())

      endif
      FAT->(qunlock())
      exit

   enddo
return

/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA _____________________________________________

static function i_2critica ( cCAMPO )
local  nHora_ini := 0
local  nHora_fim := 0
local  nMin_ini  := 0
local  nMin_fim  := 0
local  nMinRest  := 0
local  nHorasRest:= 0

   do case

      case cCAMPO == "COL_ALM"
           if empty(fCOL_ALM) ; return .F. ; endif
           qrsay(XNIVEL,fCOL_ALM:=strzero(val(fCOL_ALM),5))
           if ! ALMOXAR->(dbseek(fCOL_ALM))
              qmensa("Almoxarife n„o encontrado !","B")
              return .F.
           endif
           qrsay(XNIVEL+1,left(ALMOXAR->Nome,30))

      case cCAMPO == "EXP_ALM"
           if empty(fEXP_ALM) ; return .F. ; endif
           qrsay(XNIVEL,fEXP_ALM:=strzero(val(fEXP_ALM),5))
           if ! ALMOXAR->(dbseek(fEXP_ALM))
              qmensa("Almoxarife n„o encontrado !","B")
              return .F.
           endif
           qrsay(XNIVEL+1,left(ALMOXAR->Nome,30))


      case cCAMPO == "COL_INI"
           nHora_ini := val(left(fcol_ini,2))
           nMin_ini  := val(right(fcol_ini,2))

           if nHora_ini < 0 .or. nHora_ini > 23
              qmensa("Hora Invalida!","BL")
              return .F.
           endif

           if nMin_ini < 0 .or. nMin_Ini > 59
              qmensa("Hora Invalida!","BL")
              return .F.
           endif


           qrsay(XNIVEL  ,fcol_ini)
           qrsay(XNIVEL+1,fcol_fim)
           qrsay(XNIVEL+2,fcol_time)
           qrsay(XNIVEL+3,fCol_alm);ALMOXAR->(dbseek(fCol_alm))
           qrsay(XNIVEL+4,left(ALMOXAR->Nome,25))

           qrsay(XNIVEL+5,exp_ini)
           qrsay(XNIVEL+6,fexp_fim)
           qrsay(XNIVEL+7,fexp_time)
           qrsay(XNIVEL+8,fexp_alm);ALMOXAR->(dbseek(fexp_alm))
           qrsay(XNIVEL+9,left(ALMOXAR->Nome,25))


      case cCAMPO == "COL_FIM"
           nHora_ini := val(left(fcol_ini,2))
           nMin_ini  := val(right(fcol_ini,2))

           nHora_fim := val(left(fcol_fim,2))
           nMin_fim  := val(right(fcol_fim,2))

           if nHora_fim < 0 .or. nHora_fim > 23
              qmensa("Hora Invalida!","BL")
              return .F.
           endif

           if nMin_fim < 0 .or. nMin_fim > 59
              qmensa("Hora Invalida!","BL")
              return .F.
           endif

           if nHora_fim < nHora_ini
              qmensa("Horario Final nao pode ser menor que o Incial!","BL")
              return .F.
           else
              if nHora_fim == nHora_ini
                 if nMin_fim < nMin_ini
                    qmensa("Horario Final nao pode ser menor que o Incial!","BL")
                    return .F.
                 endif
              endif
           endif

           fcol_time := left(qdifhora(fcol_ini,fcol_fim),5)

           qrsay(XNIVEL+1,fcol_time)


      case cCAMPO == "EXP_INI"

           nHora_ini := val(left(fexp_ini,2))
           nMin_ini  := val(right(fexp_ini,2))

           if nHora_ini < 0 .or. nHora_ini > 23
              qmensa("Hora Invalida!","BL")
              return .F.
           endif

           if nMin_ini < 0 .or. nMin_Ini > 59
              qmensa("Hora Invalida!","BL")
              return .F.
           endif

      case cCAMPO == "EXP_FIM"
           nHora_ini := val(left(fexp_ini,2))
           nMin_ini  := val(right(fexp_ini,2))

           nHora_fim := val(left(fexp_fim,2))
           nMin_fim  := val(right(fexp_fim,2))

           if nHora_fim < 0 .or. nHora_fim > 23
              qmensa("Hora Invalida!","BL")
              return .F.
           endif

           if nMin_fim < 0 .or. nMin_fim > 59
              qmensa("Hora Invalida!","BL")
              return .F.
           endif

           if nHora_fim < nHora_ini
              qmensa("Horario Final nao pode ser menor que o Incial!","BL")
              return .F.
           else
              if nHora_fim == nHora_ini
                 if nMin_fim < nMin_ini
                    qmensa("Horario Final nao pode ser menor que o Incial!","BL")
                    return .F.
                 endif
              endif
           endif

           fexp_time := left(qdifhora(fexp_ini,fexp_fim),5)

           qrsay(XNIVEL+1,fexp_time)




   endcase
return .T.

static function criticaInputs(nHora_ini,nMin_ini,nHora_fim,nMin_fim)

   if nHora_fim < 0 .or. nHora_fim > 24
      qmensa("Hora Invalida!","BL")
      return .F.
   endif

   if nMin_fim < 0 .or. nfim > 60
      qmensa("Hora Invalida!","BL")
      return .F.
   endif

   if nHora_fim < nHora_ini
      qmensa("Horario Final nao pode ser menor que o Incial!","BL")
      return .F.
   else
      if nMin_fim < nMin_ini
         qmensa("Horario Final nao pode ser menor que o Incial!","BL")
         return .F.
      endif
   endif

return .T.



static function i_2etiqueta
local nCONT := 0
local zCONT := 0
      nCONT := 1
      zCONT := 1
    if ! qinitprn() ; return .F. ;endif
    @ prow()+1,00 say XAEXPAN+XAENFAT


    for nCONT:= 1 to FAT->Qtde_vol

       CGM->(DbSeek(FILIAL->Cgm))

       if zCONT == 1 .or. zCONT == 3 .or. zCONT == 5
          @ prow()+4,00 say left(FILIAL->Razao,6) + " BRASIL"
          @ prow()+1,00 say transf(nCONT,"999")+"/"+transf(FAT->Qtde_vol,"999")+" "+FAT->Especie
          @ prow()+1,00 say "NF "+FAT->Num_fatura
          @ prow()+4,00 say ""
       endif




       if zCONT == 2 .or. zCONT == 4 .or. zCONT == 6
          @ prow()  ,30 say left(FILIAL->Razao,6) + " BRASIL"
          @ prow()  ,30 say transf(nCONT,"999")+"/"+transf(FAT->Qtde_vol,"999")+" "+FAT->Especie
          @ prow()  ,30 say "NF "+FAT->Num_fatura
          @ prow()  ,30 say ""
       endif

       if zCONT >= 6
          eject
          zCONT := 1
          loop
       endif

       zCONT++
    next

    @ prow()+1,00 say XCOND1+XDENFAT

    qstopprn()

return



static function i_etiqueta
local nCONT := 0
local zCONT := 0
      nCONT := 1
      zCONT := 1
    if ! qinitprn() ; return .F. ;endif

    for nCONT:= 1 to FAT->Qtde_vol
       @ prow()+1,00 say XCOND1
       @ prow()+1,00 say XAENFAT
       CGM->(DbSeek(FILIAL->Cgm))

       @ prow()+1,00 say "----------------------------------------------------------------------------------------------------------------------"
       CFOP->(Dbseek(FAT->Cod_cfop))
       CLI1->(dbSeek(FAT->Cod_cli))
       CGM->(DbSeek(CLI1->Cgm_ent))

       @ prow()+1,00 say "|Nome/Razao Social                                                |C.N.P.J         |Municipio                        |"
       @ prow()+1,00 say "|"+CLI1->Razao+      "|"+CLI1->Cgccpf+space(2)+"| "+CGM->Municipio+space(2)+"|"
       @ prow()+1,00 say "----------------------------------------------------------------------------------------------------------------------"

       @ prow()+1,00 say XAEXPAN
       @ prow()+1,00 say XAENFAT
       @ prow()+1,00 say "VOLUMES.: "+transf(nCONT,"999")+"/"+transf(FAT->Qtde_vol,"999")+" "+rtrim(FAT->Especie)+ " NF "+FAT->Num_fatura
       @ prow()+1,00 say XCOND1
       @ prow()+1,00 say XDENFAT
       @ prow()+1,00 say ""

       if zCONT >= 8
          eject
          zCONT := 1
          loop
       endif

       zCONT++



    next

    @ prow()+1,00 say XCOND1+XDENFAT

    qstopprn(.F.)

return



static function i_ver_parcs

local nTOT_PARC := 0
local nTOT_PEDI := 0
local nVAL      := 0
local nQTDE     := 0
local nPAGS     := 0
local nQTDE_ITENS := 0

cPESOBR := 0
cPESOLQ := 0
ITEN_FAT->(Dbsetorder(2))
ITEN_FAT->(dbseek(FAT->Codigo))

do while ! ITEN_FAT->(Eof()) .and. ITEN_FAT->Num_fat == FAT->Codigo

   PROD->(Dbsetorder(4))
   PROD->(Dbseek(ITEN_FAT->Cod_prod))

   nVAL     := ITEN_FAT->Vl_unitar
   nQTDE    := ITEN_FAT->Quantidade
   nTOT_PEDI += ( (nVAL * nQTDE) + ( (nVAL*nQTDE) * (PROD->Ipi/100) )  )
   cPESOBR := cPESOBR + (PROD->Peso*ITEN_FAT->Quantidade)
   cPESOLQ := cPESOLQ + (PROD->Peso*ITEN_FAT->Quantidade)
   nQTDE_ITENS ++

   ITEN_FAT->(Dbskip())

enddo

//ITEN_FAT->(Dbsetorder(2))
//ITEN_FAT->(dbseek(FAT->Codigo))


DUP_FAT->(Dbsetorder(1))
DUP_FAT->(Dbgotop())

DUP_FAT->(dbseek(FAT->Codigo+"01"))

do while ! DUP_FAT->(Eof()) .and. left(DUP_FAT->Num_fat,5) == FAT->Codigo
   nTOT_PARC := nTOT_PARC + DUP_FAT->Valor
   DUP_FAT->(Dbskip())
enddo

DUP_FAT->(Dbsetorder(1))
DUP_FAT->(Dbgotop())
DUP_FAT->(dbseek(FAT->Codigo+"01"))

nTOT_PARC :=  round(nTOT_PARC,2)
nTOT_PEDI :=  round(nTOT_PEDI,2)

nPAGS  := nQTDE_ITENS / 15

nRESTO :=  mod(nQTDE_ITENS,15)
if nRESTO <> 0
   nPAGS++
endif

nPAGS  := int(nPAGS)


if nTOT_PARC <> nTOT_PEDI
   alert("Pedido.: "+transf(nTOT_PEDI,"@E 999,999.99")+ "     Parcelas .: "+Transf(nTOT_PARC,"@E 999,999.99"))
   qmensa("Valor das Parcelas Difere do Valor do Pedido, Verfique !!!","B")

endif


return nPAGS

static function i_totPages()

local nPAGS     := 0
local nQTDE_ITENS := 0

ITEN_FAT->(Dbsetorder(2))
ITEN_FAT->(dbseek(FAT->Codigo))

do while ! ITEN_FAT->(Eof()) .and. ITEN_FAT->Num_fat == FAT->Codigo

   nQTDE_ITENS ++

   ITEN_FAT->(Dbskip())

enddo

nPAGS  := nQTDE_ITENS / 11

nRESTO :=  mod(nQTDE_ITENS,11)
if nRESTO <> 0
   nPAGS++
endif

nPAGS  := int(nPAGS)

return nPAGS


static function i_duplicado
local nREG   := 0
local nINDEX := 0

//nREG   := FAT->(RecNo())
//nINDEX := FAT->(IndexOrd())

if FAT->Dt_emissao <> Date()
   alert("Data de Emissao, Difere da Data de Hoje...")
endif

//FAT->(Dbsetorder(11))
//i//f FAT->(DbSeek(cFATURA))
//   alert("Este Numero de Nota ja foi Impresso...")
//endif

//FAT->(DbGoto(nREG))
//FAT->(Dbsetorder(nINDEX))

return


static function i_filtro()
local cFIL := ""

if qconf("Confirma alteracao de Filtro?")
   cFIL := FAT->(dbfilter())
   FAT->(DbClearFilter())
   if left(cFIL,1) == "T" //Tira Entrada
   //   FAT->(DbSetFilter({|| FAT->No_nf == .F.},"P"))
   else
   //   FAT->(DbsetFilter({|| FAT->Modelo != "01" },"T"))
   endif
endif

return

function i_locked()
   local nCONT := 1
   local aLIST := FAT->(DBrLockList())
   local cLocked := "N"
   if len(aLIST) > 0
      for nCONT := 1 to len(aLIST)
          if FAT->(Recno()) == aLIST[nCONT]
             cLocked := "S"
             exit
          endif
      next
   endif
return iif(cLocked == "N","Nao","Sim")


static function i_peso
   cPESOBR := 0
   cPESOLQ := 0
   cQUANT  := 0

   PROD->(Dbsetorder(4))

   ITEN_FAT->(Dbsetorder(2))
   ITEN_FAT->(dbseek(FAT->Codigo))

   do while ! ITEN_FAT->(Eof()) .and. ITEN_FAT->Num_fat == FAT->Codigo

      PROD->(Dbseek(ITEN_FAT->Cod_prod))

      cPESOBR := cPESOBR + (PROD->Peso_Bruto*ITEN_FAT->Quantidade)
      cPESOLQ := cPESOLQ + (PROD->Peso*ITEN_FAT->Quantidade)
      cQUANT += ITEN_FAT->Quantidade
      ITEN_FAT->(Dbskip())

   enddo

return


static function i_geraNF(cSCAN)
local nNF_ANTER := 0
local nNF_ATUAL := 0
local lCFGOK := .T.
local lFATOK := .T.
local lTESTE := .F.

  if empty(FAT->NFe)
     if ! FAT->Gerada .or. cSCAN == "3"
		
        if cSCAN == "3"
		  nNF_ANTER := CONFIG->nf_scan
          nNF_ATUAL := CONFIG->nf_scan + 1

          if CONFIG->(qrlock())
             replace CONFIG->nf_scan with nNF_ATUAL
             CONFIG->(qunlock())
             CONFIG->(Dbcommit())
          else
             qmensa("Nao foi possivel gravar Numero da Nota ! Config.DBF","B")
             lCFGOK := .F.
             return .F.
          endif
		
		
		else
          nNF_ANTER := CONFIG->Cod_fat
          nNF_ATUAL := CONFIG->Cod_fat + 1

          if CONFIG->(qrlock())
             replace CONFIG->Cod_fat with nNF_ATUAL
             CONFIG->(qunlock())
             CONFIG->(Dbcommit())
          else
             qmensa("Nao foi possivel gravar Numero da Nota ! Config.DBF","B")
             lCFGOK := .F.
             return .F.
          endif
		endif

        if FAT->(qrlock())
           replace FAT->NUm_fatura with strzero(nNF_ATUAL,6)
           replace FAT->dt_emissao with date()
           FAT->(qunlock())
           FAT->(dbcommit())
        else
           qmensa("Pedido esta sendo usado por outro usuario !","B")
           lFATOK := .F.
           return .F.
        endif

           if FAT->(qrlock())
              replace FAT->Gerada with .T.
              FAT->(qunlock())
           endif
     else
        qmensa("NF ja foi gerada para este pedido!","B")
        return .F.
     endif
   else
     qmensa("NF Autorizada nao e possivel gerar numero!","B")
     return .F.
   endif



return


static function i_geraNF02
local nNF_ANTER := 0
local nNF_ATUAL := 0
local lCFGOK := .T.
local lFATOK := .T.
local lTESTE := .F.


  if ! FAT->Gerada

     nNF_ANTER := CONFIG->Cod_fat2
     nNF_ATUAL := CONFIG->Cod_fat2 + 1

     if FAT->(qrlock())
        replace FAT->NUm_fatura with strzero(nNF_ATUAL,6)
        FAT->(qunlock())
     else
        qmensa("Pedido esta sendo usado por outro usuario !","B")
        lFATOK := .F.
        return .F.
     endif


     if CONFIG->(qrlock())
        replace CONFIG->Cod_fat2 with nNF_ATUAL
        CONFIG->(qunlock())
     else
        qmensa("Nao foi possivel gravar Numero da Nota ! Config.DBF","B")
        lCFGOK := .F.
        return .F.
     endif

     FAT->(dbcommit())
     CONFIG->(Dbcommit())


     if lCFGOK .and. lFATOK .and. CONFIG->Cod_fat2 == (nNF_ANTER + 1) .and. val(FAT->Num_fatura) == (nNF_ANTER + 1)
        lTESTE := .T.
     else
        qmensa("Nota nao foi Gerada!","B")
        return .F.
     endif

     if lTESTE
        if FAT->(qrlock())
           replace FAT->Gerada with .T.
           FAT->(qunlock())
        endif

     endif
  else
     qmensa("NF ja foi gerada para este pedido!","B")
     return .F.
  endif



return


static function i_subst

   local cTITULO
   local nVU       := 0
   local nBC_Icm   := 0
   local nTTBC_Icm := 0
   local nIcm      := 0
   local nTTIcm    := 0
   local nIpi      := 0
   local nTTIpi    := 0
   local nBC_ST    := 0
   local nTTBC_ST  := 0
   local nST       := 0
   local nTTST     := 0
   local nSTPG     := 0
   local nTTSTPG     := 0
   local nMVA      := 0
   local nALIQ_INT := 0
   local nALIQ_ICM := 0
   local lSimples := .F.
   
   CLI1->(Dbseek(FAT->Cod_cli))
   CGM->(Dbseek(CLI1->Cgm_ent))
   
   if CGM->Estado == "PR"
      qmensa("Para o Parana, a ST Sera gerada na NFe!!","BL")
	  return .F.
   endif	  


   cTITULO := "CALCULO DA SUBSTITUICAO TRIBUTARIA N.F. "+FAT->Num_fatura+"   Data Emissao: "+dtoc(FAT->Dt_emissao)

   PROD->(Dbsetorder(4))
   IT_CLASS->(dbsetorder(2))

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif

   if ! qlineprn() ; return ; endif

   if XPAGINA == 0 .or. prow() > K_MAX_LIN
      qpageprn()
      @ prow(),pcol() say XCOND1
      qcabecprn(cTITULO,134)
      CLI1->(Dbseek(FAT->Cod_cli))
      CGM->(Dbseek(CLI1->Cgm_ent))

      @ prow()+1,0 say "Cliente : "+CLI1->Codigo + " - " + left(CLI1->Razao,36) + "  Telefone: "+ CLI1->Fone1
      @ prow()+1,0 say "Fantasia: "+CLI1->Fantasia + " " + "Inscricao Estadual.: " + CLI1->Inscricao
      @ prow()+1,0 say "CNPJ....: "+fu_conv_cgccpf(CLI1->Cgccpf)
      @ prow()+1,0 say "Endereco: "+left(CLI1->End_ent,32) + " - " + left(CGM->Municipio,15) + " UF: "+CGM->Estado
      @ prow()+1,0 say "Bairro  : " + CLI1->Bairro_ent + "  CEP.: "+CLI1->Cep_ent
	  @ prow()+1,0 say "Regime Tribuario : " + qabrev(CLI1->Tributacao,"1234",{"Simples Nacional","Lucro Presumido","Lucro Real","Pessoa Fisica"})
	  
	  if CLI1->Tributacao == "1"
	     lSimples := .T.
	  endif	 
      
	  @ prow()+1,0 say replicate("-",134)
   endif

   @ prow()+1,0 say XCOND1
   @ prow()+1,0 say "Ref.     Descricao             Qtde   Vlr Unit.    BC Icms     Icms       IPI     BC Icms+IPI   M.V.A.    BC S.T.   Icms S.T.     S.T."
   @ prow()+1,0 say ""

   ITEN_FAT->(Dbseek(FAT->Codigo))

   ESTADO->(dbseek(CGM->Estado))
   nALIQ_INT :=  ESTADO->Aliq_inter

   do while ! ITEN_FAT->(eof()) .and. ITEN_FAT->Num_fat == FAT->Codigo

      PROD->(Dbseek(ITEN_FAT->Cod_prod))

      if IT_CLASS->(dbseek(PROD->Cod_Class+CGM->Estado))
         nMVA := IT_CLASS->Mva
		 if CGM->Estado == "SC" .and. lSimples
		    nMVA := nMVA - ( nMVA * 0.30)
		 endif
      endif

      CLASSIF->(dbseek(PROD->Cod_class))

      if nMVA > 0

         @ prow()+1,0   say PROD->Cod_ass
         @ prow()  ,009 say left(CLASSIF->Descricao,15)
         @ prow()  ,029 say transform(ITEN_FAT->Quantidade, "@E 999999")

         nVU := round(ITEN_FAT->Vl_unitar,2)


         nTTBC_Icm += (ITEN_FAT->Quantidade * nVU)
         nBC_Icm := ITEN_FAT->Quantidade * nVU

         nIcm    := ( ( ITEN_FAT->Quantidade * nVU  ) * (ITEN_FAT->Icms/100) )
         nTTIcm  += ( ( ITEN_FAT->Quantidade * nVU  ) * (ITEN_FAT->Icms/100) )

         nIPI    :=  ( ( ITEN_FAT->Quantidade * nVU ) * ( PROD->Ipi / 100 ) )
         nTTIPI  +=  ( ( ITEN_FAT->Quantidade * nVU ) * ( PROD->Ipi / 100 ) )

         nBC_ST   := (nBC_ICM + nIPI) + ( (nBC_ICM + nIPI) * ( nMVA / 100) )
		 
		 if CGM->Estado == "GO" .and. lSimples
			nBC_ST := nBC_ST - (nBC_ST * 0.2941)
		 endif
		 
         nTTBC_ST += nBC_ST

         nST     := ( nBC_ST * (nALIQ_INT/100))
         nTTST   += ( nBC_ST * (nALIQ_INT/100))

         nSTPG  := nST - nIcm

         nALIQ_ICM := ITEN_FAT->Icms

         @ prow()  ,37  say transform(nVU, "@E  99,999.99")
         @ prow()  ,48  say transform(ITEN_FAT->Quantidade * nVU, "@E  99,999.99")
         @ prow()  ,59  say transform(nIcm, "@E 9,999.99")
         @ prow()  ,69  say transform(nIpi, "@E 9,999.99")
         @ prow()  ,83  say transform(nBc_Icm+nIPI, "@E  99,999.99")
         @ prow()  ,97  say transform(nMVA, "@E 99.99")+"%"
         @ prow()  ,103 say transform(nBC_ST, "@E  99,999.99")
         @ prow()  ,116 say transform(nST   , "@E  9,999.99")
         @ prow()  ,125 say transform(nSTPG , "@E  9,999.99")
      endif

       
      ITEN_FAT->(Dbskip())

   enddo


   @ prow()+1,00  say replicate("-",134)
   @ prow()+1,00  say ""
   @ prow()+1,00  say "Base de Icms.........: "+transform(nTTBC_Icm, "@E  99,999.99") + "  Aliq. Icms......: "             +transform(nAliq_Icm, "@E  99.99")  + "%    Icms......: "+ transform(nTTIcm, "@E 9,999.99") + "    IPI.: "+ transform(nTTIpi, "@E 9,999.99")
   @ prow()+1,00  say "Base de Substituicao.: "+transform(nTTBC_ST , "@E  99,999.99") + "  Aliq. Interna "+CGM->Estado+": "+transform(nAliq_Int, "@E  99.99")  + "%    Icms S.T..: "+ transform(nTTST , "@E 9,999.99")
   @ prow()+1,00  say "Icms Substituicao....: "+transform(nTTST-nTTICM , "@E  99,999.99")
   //@ prow()+2,00  say "Icms Substituicao.funcoes: "+transform(calculaTotalSubst(), "@E  99,999.99")


   qstopprn(.F.)
   
   
   if ! CGM->Estado $ "PR-RS-SC" 
      sendST(round(nTTST-nTTICM,2))
   endif	  

return

static function sendST(nValor)

   if nValor > 0

   if ! FAT->St_sended


      if qconf("Deseja enviar fatura pra Contas a Receber/Contabilidade ?")


         if left(FAT->Cod_cfop,4) $ "5101-5102-5401-5402-6101-6102-6401-6402-6403"

            fu_abre_prov()
            fu_abre_farec()

            if SH_FAREC->(qappend())
               replace SH_FAREC->Data_lanc   with  FAT->Dt_emissao
               replace SH_FAREC->Cod_cli     with  FAT->Cod_cli
               replace SH_FAREC->CCusto      with  FAT->C_custo
               replace SH_FAREC->Filial      with  FAT->Filial
               replace SH_FAREC->Data_emiss  with  FAT->Dt_emissao
               replace SH_FAREC->Especie     with  "01"
               replace SH_FAREC->Serie       with  "01"
               replace SH_FAREC->Tipo_cont   with  FAT->Tiposub
               replace SH_FAREC->Historico   with  "SUBSTITUICAO TRIBUTARIA"
               replace SH_FAREC->Data_venc   with  FAT->Dt_emissao + 10
               replace SH_FAREC->Valor       with  nValor

               replace SH_FAREC->Fatura      with  FAT->Num_fatura+"/ST"
               replace SH_FAREC->Num_titulo  with  FAT->Num_fatura+"/ST"
               replace SH_FAREC->Cliente     with  FAT->Cliente
               replace SH_FAREC->Tipo_doc    with  FAT->Tipo_doc
            endif
         endif

         if left(FAT->Cod_cfop,4) $ "5101-5102-5402-6101-6102-6402-6403-5403"
            TIPOCONT->(Dbseek(CONFIG->Tpo_vend))
         else
            TIPOCONT->(Dbseek(CONFIG->Tpo_desp))
         endif

         if SH_PROCT->(qappend())

            replace SH_PROCT->Data_lanc   with  FAT->Dt_emissao

            if TIPOCONT->Cont_pr_dv == "1"
               replace SH_PROCT->Cont_db with TIPOCONT->Ct_ct_p_dv
            else
               CLI1->(dbseek(FAT->Cod_cli))
               replace SH_PROCT->Cont_db with CLI1->Conta_cont
            endif

            if TIPOCONT->Cont_pr_cr == "1"
               replace SH_PROCT->Cont_cr with TIPOCONT->Ct_ct_p_cr
            else
               CLI1->(dbseek(FAT->Cod_cli))
               replace SH_PROCT->Cont_cr with CLI1->Conta_cont
            endif

            replace SH_PROCT->Filial     with  FAT->Filial

            replace SH_PROCT->Valor      with  nVALOR
            replace SH_PROCT->Num_doc    with  FAT->Num_fatura
            replace SH_PROCT->Num_lote   with  "CL" + XUSRNUM + "SUBST" // monta numero do lote
            replace SH_PROCT->Cod_hist   with ""

            replace SH_PROCT->Cod_fat    with FAT->Codigo

            replace SH_PROCT->Historico  with "VR SUBST. TRIB. NF "+FAT->Num_fatura+" "+ left(FAT->cliente,35)

         endif

         SH_FAREC->(dbclosearea())
         SH_PROCT->(dbclosearea())

         select FAT

         if FAT->(qrlock())
            replace FAT->St_sended with .T.
            FAT->(qunlock())
         endif


      endif


   endif

   endif

return

static function CriarNFeDpec(cDestino,cFormaEmissao)
local cCodMunic    := ""
local nCONT        := 0
local nTotal       := 0
local nICMS        := 0
local nICMS_DIF    := 0
local nIPI         := 0
local nICMSST      := 0
local nBASE_ICMSST := 0
local nBASE_ICMS   := 0
local nBASE_IPI    := 0
local nValorSt     := 0
local aST := {}
local nInfAdic := 0
local nALIQ_ICMS := 0
local nIcmsItem := 0
local nMVA     := 0
local cNCM     := ""
local nBASE_PLAFORTE := 0
local nST_PLAFORTE   := 0
local cIniNFe        := ""
local nFile          := 0
local eol            := chr(13) + chr(10)

   //set printer to (XDRV_NFE+cDESTINO)
   //set device to printer
   //set margin to 0
   //setprc(0,0)
   
   //@ prow() +1,00 say   "NFE.SetFormaEmissao('"+cFormaEmissao+"');"
   cNFe := "[Identificacao]" +eol

   CFOP->(dbseek(FAT->cod_cfop))
   cNFe += "NaturezaOperacao="+i_trocachr(left(CFOP->Nat_desc,20))+eol
   cNFe += "Modelo=55"+eol
   
   if cFormaEmissao == "4"
      cNFe += "Serie=900"+eol
   else
      cNFe += "Serie=1"+eol
   endif	
   
   cNFe += "Codigo="+FAT->Num_fatura+eol
   cNFe += "Numero="+FAT->Num_fatura+eol
   cNFe += "Emissao="+dtoc(date())+eol
// cNFe += "Saida="+dtoc(date())+eol
   if FAT->Es == "S"
      cNFe += "Tipo=1"+eol
   else
      cNFe += "Tipo=0"+eol
   endif

   if DUP_FAT->(dbseek(FAT->Codigo+"01"))
      cNFe += "FormaPag=1"+eol
   else
      if left(FAT->cod_cfop,3) $ "510-610-511-512-611-612-540-640"
         cNFe += "FormaPag=0" + eol
      else
         cNFe += "FormaPag=2" + eol
      endif
   endif
   cNFe += "Finalidade=0" + eol
   cNFe += "[Emitente]" + eol
   FILIAL->(dbseek(FAT->Filial))
   cNFe += "CNPJ="+FILIAL->cgccpf + eol
   cNFe += "IE="+qtiraponto(FILIAL->Insc_estad) + eol
   
   CLI1->(dbseek(FAT->Cod_cli))
   CGM->(dbseek(CLI1->cgm_ent))
   if CGM->Estado == "PR"
      cNFe += "IEST="+qtiraponto(FILIAL->Insc_st) + eol
   endif	  
   cNFe += "Razao="+i_trocachr(rtrim(FILIAL->Razao)) + eol
   cNFe += "Fantasia="+i_trocachr(rtrim(FILIAL->Fantasia)) + eol
   cNFe += "Fone="+i_trocachr(FILIAL->Telefone) + eol
   cNFe += "CEP="+FILIAL->Cep + eol
   cNFe += "Logradouro="+i_trocachr(rtrim(FILIAL->Endereco)) + eol
   cNFe += "Numero="+strzero(FILIAL->numero,6) + eol
   cNFe += "Complemento="+i_trocachr(rtrim(FILIAL->Compl)) + eol
   cNFe += "Bairro="+i_trocachr(rtrim(FILIAL->Bairro)) + eol
   CGM->(dbseek(FILIAL->Cgm))
   cNFe += "CidadeCod="+BuscaMunicipio(CGM->Cod_rais,CGM->Municipio) + eol
   cNFe += "Cidade="+rtrim(CGM->Municipio) + eol
   cNFe += "UF="+CGM->Estado + eol

   cNFe += "[Destinatario]" + eol
   CLI1->(dbseek(FAT->Cod_cli))
   cNFe += "CNPJ="+CLI1->cgccpf + eol
   cNFe += "IE="+qtiraponto(CLI1->Inscricao) + eol
   cNFe += "NomeRazao="+i_trocachr(rtrim(CLI1->Razao)) + eol
   cNFe += "Fone="+i_trocachr(CLI1->Fone1) + eol
   cNFe += "CEP="+CLI1->Cep_ent + eol
   cNFe += "Logradouro="+i_trocachr(rtrim(CLI1->End_ent)) + eol
   cNFe += "Numero="+alltrim(CLI1->Numero) + eol
   cNFe += "Complemento="+i_trocachr(alltrim(CLI1->Compl)) + eol
   cNFe += "Bairro="+i_trocachr(rtrim(CLI1->Bairro_ent)) + eol
   CGM->(dbseek(CLI1->Cgm_ent)) 
   cNFe += "CidadeCod="+BuscaMunicipio(CGM->Cod_rais,CGM->Municipio) + eol
   cNFe += "Cidade="+rtrim(CGM->Municipio) + eol
   cNFe += "UF="+CGM->Estado + eol

   nICMS        := 0
   nICMSST      := 0
   nBASE_ICMSST := 0
   nBASE        := 0
   nTOTAL       := 0


   ITEN_FAT->(dbsetorder(2))
   ITEN_FAT->(dbseek(FAT->Codigo))
   PROD->(dbsetorder(4))
   nCONT := 1
   do while ! ITEN_FAT->(eof()) .and. ITEN_FAT->Num_fat == FAT->Codigo

      PROD->(dbseek(ITEN_FAT->Cod_prod))
	  
      cNFe += "[PRODUTO"+strzero(nCONT,3)+"]" +eol
      cNFe += "CFOP="+alltrim(FAT->Cod_cfop)
      if CONFIG->Modelo_fat =="1" 
         cNFe += "Codigo="+rtrim(PROD->cod_fabr) +eol
      else
         cNFe += "Codigo="+right(PROD->codigo,5) +eol
      endif
      if CLASSIF->(dbseek(PROD->Cod_class))
         cNFe += "NCM="+alltrim(i_trocachr(CLASSIF->Descricao)) +eol
		 cNCM := alltrim(i_trocachr(CLASSIF->Descricao))
      endif

      cNFe += "Descricao="+rtrim(PROD->Descricao)+eol
      UNIDADE->(dbseek(PROD->Unidade))
      cNFe += "Unidade="+alltrim(UNIDADE->Sigla) +eol
      cNFe += "Quantidade="+alltrim(transf(ITEN_FAT->Quantidade,"@R 9999999"))+eol
      cNFe += "ValorUnitario="+alltrim(transf(ITEN_FAT->vl_unitar,"@R 9999999.99"))+eol
      cNFe += "ValorTotal="+alltrim(transf(ITEN_FAT->Quantidade*ITEN_FAT->vl_unitar,"@R 9999999.99"))+eol
      
      cNFe += "[ICMS"+strzero(nCONT,3)+"]"+eol
      cNFe += "Origem="+left(ITEN_FAT->Cod_sit,1)+eol
	  
	  cNFe += "CST="+right(ITEN_FAT->Cod_sit,2)+eol

      if CONFIG->Simples != "S"
         cNFe += "Aliquota="+alltrim(transf(ITEN_FAT->Icms,"@R 99.99")) +eol

		 if left(FAT->Cod_cfop,1) $ "1-5" .and. CLI1->Isento == "S"
		    cNFe += "PercentualReducao="+alltrim(transf(33.33,"@R 9999999.99")) +eol
			nBaseItem := (ITEN_FAT->vl_unitar*ITEN_FAT->Quantidade)
			nBaseItem := nBaseItem - (nBaseItem*0.3333)
			if ITEN_FAT->Icms > 0
		        cNFe += "ValorBase="+alltrim(transf(nBaseItem,"@R 9999999.99")) +eol
     			nIcmsItem := (ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade)*(ITEN_FAT->Icms/100)
		     	nIcmsItem := nIcmsItem - (nIcmsItem * 0.3333)
		        cNFe += "Valor="+alltrim(transf(nIcmsItem,"@R 9999999.99")) +eol
			endif	
		 else
		    if ITEN_FAT->Icms > 0
		       cNFe += "ValorBase="+alltrim(transf(ITEN_FAT->vl_unitar*ITEN_FAT->Quantidade,"@R 9999999.99")) + eol
	           cNFe += "Valor="+alltrim(transf((ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade)*(ITEN_FAT->Icms/100),"@R 9999999.99")) +eol
			endif
		 endif
		 
		 
         if ITEN_FAT->icms > 0 
            cNFe += "[IPI"+strzero(nCONT,3)+"]" +eol
            cNFe += "CST="+ITEN_FAT->Cod_sit +eol

            cNFe += "ValorBase="+alltrim(transf(ITEN_FAT->vl_unitar*ITEN_FAT->Quantidade,"@R 9999999.99")) +eol
            cNFe += "Aliquota="+alltrim(transf(ITEN_FAT->IPI,"@R 99.99"))+eol
            cNFe += "Valor="+alltrim(transf((ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade)*(ITEN_FAT->Ipi/100),"@R 9999999.99"))+eol
		 else
            cNFe += "[IPI"+strzero(nCONT,3)+"]" +eol
            cNFe += "CST="+ITEN_FAT->Cod_sit +eol

            cNFe += "ValorBase="+alltrim(transf(ITEN_FAT->vl_unitar*ITEN_FAT->Quantidade,"@R 9999999.99")) +eol
            cNFe += "Aliquota="+alltrim(transf(0,"@R 99.99")) +eol
            cNFe += "Valor="+alltrim(transf(0,"@R 9999999.99")) +eol
         endif		 
	  else 
	      if (CONFIG->Sol == "S" .or. CONFIG->Plaforte == "S") .and. CLI1->Final != "S"
		  
		    if CONFIG->Sol == "S" 
               cNFe += "ValorBaseST="+alltrim(transf( (ITEN_FAT->Vl_unitar*ITEN_FAT->Quantidade) * 2.4,"@R 9999999.99")) +eol
    	       cNFe += "AliquotaST="+alltrim(transf(ITEN_FAT->Icms,"@R 99.99")) +eol
               cNFe += "ValorST="+alltrim(transf( ((ITEN_FAT->vl_unitar * ITEN_FAT->Quantidade * 2.4) - (ITEN_FAT->vl_unitar * ITEN_FAT->Quantidade) )*(ITEN_FAT->Icms/100),"@R 9999999.99")) +eol
			endif   
			
			if CONFIG->Plaforte == "S" .and. cNCM $ "90191000-39221000"
			
			   nMVA := AliqMVA(cNCM,left(FAT->Cod_Cfop,1))
			   alert(transf(nMVA,"@R 99999999.99"))
			  
               cNFE += "ValorBaseST="+alltrim(transf( (ITEN_FAT->Vl_unitar*ITEN_FAT->Quantidade) * nMVA,"@R 9999999.99")) +eol
    	       cNFE += "AliquotaST="+alltrim(transf(18.00,"@R 99.99"))+eol
               cNFE += "ValorST="+alltrim(transf( ((ITEN_FAT->vl_unitar * ITEN_FAT->Quantidade * nMVA) - (ITEN_FAT->vl_unitar * ITEN_FAT->Quantidade) ) *  0.18,"@R 9999999.99"))+eol
			   nBASE_PLAFORTE += ((ITEN_FAT->Vl_unitar*ITEN_FAT->Quantidade) * nMVA )
			   nST_PLAFORTE   += (((ITEN_FAT->vl_unitar * ITEN_FAT->Quantidade * nMVA) - (ITEN_FAT->vl_unitar * ITEN_FAT->Quantidade) ) * 0.18 )
			endif
			
			
		 endif  
      endif

      nBASE_IPI    += (ITEN_FAT->Quantidade * ITEN_FAT->Vl_unitar)
      nBASE_ICMSST += (ITEN_FAT->Quantidade * ITEN_FAT->Bc_subst)
      nICMS        += ((ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade)*(ITEN_FAT->Icms/100))
      nALIQ_ICMS  := ITEN_FAT->Icms

      if ITEN_FAT->Icms > 0
         nBASE_ICMS   += (ITEN_FAT->Quantidade * ITEN_FAT->Vl_unitar)
		 if CONFIG->Sol != "S"
            nIPI         += ((ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade)*(ITEN_FAT->Ipi/100))
		 endif	
      endif

      nICMSST      += ((ITEN_FAT->Bc_subst * ITEN_FAT->Quantidade)*(ITEN_FAT->Icms/100))

      if ITEN_FAT->Bc_subst > 0
         aadd(aST,{ITEN_FAT->Cod_prod,(ITEN_FAT->Quantidade*ITEN_FAT->BC_subst),((ITEN_FAT->Quantidade*ITEN_FAT->Bc_subst) * (ITEN_FAT->Icms /100)),((ITEN_FAT->Quantidade * ITEN_FAT->Vl_unitar) * ( ITEN_FAT->Icms / 100 ))})
      endif

      //ValorBase=
      //Aliquota=
      //Valor=
      //ModalidadeST=
      //PercentualMargemST
      //PercentualReducaoST
      //ValorBaseST=
      //AliquotaST=
      //ValorST=
      //PercentualReducao=

      nTotal += (ITEN_FAT->Quantidade * ITEN_FAT->Vl_unitar) 

      nCONT++
      ITEN_FAT->(dbskip())
   enddo

   nValorSt := nICMSST - nICMS
   if nValorSt < 0
      nValorSt := 0
   endif

   cNFE += "[Total]" +eol
   if CONFIG->simples != "S"

      if left(FAT->Cod_cfop,1) $ "1-5" .and. CLI1->Isento == "S"
         nICMS_DIF := (nICMS*0.3333)
         nICMS := nICMS-(nICMS*0.3333)
		 nBase_Icms := nBase_Icms - (nBase_icms * 0.3333)
      endif

      cNFE += "BaseICMS="+alltrim(transf(nBase_Icms,"@R 9999999.99")) +eol
      cNFE += "ValorICMS="+alltrim(transf(nIcms,"@R 9999999.99"))+eol
      cNFE += "ValorIPI="+alltrim(transf(nIpi,"@R 9999999.99"))+eol
      //cNFE += "BaseIcmsSubstituicao="+alltrim(transf(nBASE_ICMSST,"@R 9999999.99"))+eol
      //cNFE += "ValorIcmsSubstituicao="+alltrim(transf(nValorSt,"@R 9999999.99"))+eol
   endif

   if CONFIG->SOL == "S"
      if CLI1->Final != "S"
         nBASE_ICMSST := nBASE_ICMS * 2.4
         nVAlorSt     := (nBASE_ICMSST*(nAliq_Icms/100))-(nBase_Icms*(nAliq_Icms/100))

         cNFE += "BaseIcmsSubstituicao="+alltrim(transf(nBASE_ICMSST,"@R 9999999.99"))+eol
         cNFE += "ValorIcmsSubstituicao="+alltrim(transf(nValorSt,"@R 9999999.99"))+eol
      endif
   endif
   
   if CONFIG->Plaforte == "S"
      if CLI1->Final != "S"
         cNFe += "BaseIcmsSubstituicao="+alltrim(transf(nBASE_PLAFORTE,"@R 9999999.99"))+eol
         cNFe += "ValorIcmsSubstituicao="+alltrim(transf(nST_PLAFORTE,"@R 9999999.99"))+eol
		 nValorST := nST_PLAFORTE
      endif
   endif

   cNFe += "ValorProduto="+alltrim(transf(nTotal,"@R 9999999.99")) +eol
   cNFe += "ValorNota="+alltrim(transf(nTotal+(nValorST)+nIPI,"@R 9999999.99")) +eol

   TRANSP->(dbseek(FAT->Cod_transp))

   cNFe += "[Transportador]" +eol
   cNFe += "FretePorConta="+strzero(val(FAT->Frete)-1,1) +eol
   cNFe += "CnpjCpf="+alltrim(i_trocachr(TRANSP->cgccpf)) +eol
   cNFe += "IE="+alltrim(i_trocachr(TRANSP->Inscricao))+eol
   cNFe += "NomeRazao="+rtrim(i_trocachr(TRANSP->Razao))+eol
   cNFe += "Endereco="+rtrim(i_trocachr(TRANSP->Endereco))+eol
   CGM->(dbseek(TRANSP->Cgm))
//  cNFe += "CidadeCod="+BuscaMunicipio(CGM->Cod_rais,CGM->Municipio)+eol
   cNFe += "Cidade="+rtrim(CGM->Municipio)+eol
   cNFe += "UF="+CGM->Estado+eol
   if ! empty(FAT->Cod_transp)
       if ! empty(TRANSP->Placa)
          cNFe += "Placa="+alltrim(i_trocachr(TRANSP->Placa)) +eol
          cNFe += "UFPlaca="+CGM->Estado +eol
       endif      
   endif    

   cNFe += "[volume001]" +eol
   cNFe += "Quantidade="+alltrim(transf(FAT->Qtde_vol,"@R 999999")) +eol
   cNFe += "Especie="+FAT->Especie +eol
   cNFe += "Marca="+FAT->Marca +eol
   cNFe += "Numeracao="+FAT->Numero +eol
   cNFe += "PesoBruto="+alltrim(transf(FAT->Peso_bruto,"@R 999999.99")) +eol
   cNFe += "PesoLiquido="+alltrim(transf(FAT->Peso_liqui,"@R 999999.99")) +eol

   nCONT := 1

   if DUP_FAT->(dbseek(FAT->Codigo+"01"))
      do while left(DUP_FAT->Num_fat,5) == FAT->Codigo .and. ! DUP_FAT->(eof())
         cNFe += "[Duplicata"+strzero(nCONT,3)+"]" +eol
         cNFe += "Numero="+FAT->Num_fatura + "/"+right(DUP_FAT->Num_fat,2) +eol
         cNFe += "Datavencimento="+dtoc(date()+DUP_FAT->Dias) +eol
         cNFe += "Valor="+alltrim(transf(DUP_FAT->Valor,"@R 9999999.999")) +eol
         nCONT++
         DUP_FAT->(dbskip())
      enddo
   endif

   cNFe += "[DadosAdicionais]" + eol

   if CONFIG->Simples == "S"
      cNFe += "Complemento=Empresa optante pelo Simples Nacional Cfe. Lei 123/2006."
      cNFe += ";Nao gera direito a credito do ICMS."
      cNFe += ";"+left(FAT->Obs,50)
      if ! empty(substr(FAT->Obs,51,50))
         cNFe += ";"+substr(FAT->Obs,51,50)
      endif

      if ! empty(substr(FAT->Obs,101,50))
         cNFe += ";"+substr(FAT->Obs,101,50)
      endif

      if ! empty(substr(FAT->Obs,151,50))
         cNFe += ";"+substr(FAT->Obs,151,50)
      endif
   else
      cNFe += "Complemento="+rtrim(left(FAT->Obs,50))

      if ! empty(substr(FAT->Obs,51,50))
        cNFe += "[InfAdic"+strzero(nInfAdic,3)+"]"
        cNFe += ";"+rtrim(substr(FAT->Obs,51,50)) 
      endif

      if ! empty(substr(FAT->Obs,101,50))
         cNFe += ";"+substr(FAT->Obs,101,50)
      endif

      if ! empty(substr(FAT->Obs,151,50))
         cNFe += ";"+substr(FAT->Obs,151,50)
      endif
	  
      if CONFIG->Modelo_Fat == "1"
         if left(FAT->Cod_cfop,1) $ "1-5" .and. nIcms > 0 .and. CLI1->Isento == "S"
            cNFe +=  ";ICMS Diferido Conf. Art. 87-A do RICMS - Decreto No. 5141/01."
            cNFe += ";Valor do Icms Diferido.: "+alltrim(transf(nICMS_DIF,"@R 999999.99"))
         endif

         if ! empty(CLI1->msg_recife)
            cNFe += ";Contribuinte credenciado para nao-antecipacao de ICMS"
            cNFe += ";Edital DPC No. 004/2010 - RE ST"
         endif
      endif

   endif
   
   //cNFe += eol

//   if len(aST) > 0 .and. CLI1->Final != "S"
//      @ prow(), pcol() say ";Base de Calculo da Substituicao Tributaria Conf. NPF 020/2010."
//
//      for nCONT := 1  to len(aST)
//          PROD->(dbseek(aST[nCONT,1]))
//          @ prow(),pcol() say ";"+left(PROD->Descricao,45) + " " + padr(alltrim(transform(aST[nCONT,2],"@R 999999.99")) +" "+alltrim(transform(aST[nCONT,3]-aST[nCONT,4],"@R 999999.99")),18)
//      next
//
//   endif
   if cFormaEmissao == "dpec"
	  cEnvio := "NFe.AdicionarNFe("+cNFe+",0)"+eol
      cEnvio += "NFe.EnviarDPECNFe(0,1)"
   else  
      cEnvio := "NFE.CriarEnviarNFe("+cNFe+",0,1)"
   endif 	  
   
   
   nFile := fcreate(XDRV_NFE+"ENT.TXT",0)
   fwrite(nFile,cEnvio,len(cEnvio))
   fclose(nFile)

   nCONT := 1


   readFile(XDRV_NFE+"SAI.TXT","ENVIAR")

   if ! empty(FAT->NFe) .and. FAT->Status == "100"

      if FAT->Es == "S"
         imprimirDanfe("ENT.TXT")
         imprimirDanfePdf("ENT.TXT")

         if CONFIG->Modelo_fat == "1"
            //blat()
			if TRANSP->(dbseek(FAT->cod_transp))
	           if ! empty(TRANSP->Email)
			      //blatTransp()
			   endif	  
			endif
         endif

      endif

   endif

//   if FAT->Status == "105"
//      if file(XDRV_NFE+"logs\"+getNFe()+qdigNFe(getNFe())+"-NFe.xml")
//         if FAT->(qrlock())
//            replace FAT->NFe with getNFe() + qdigNFe(getNFe())
//            replace FAT->Modelo with "55"
//            FAT->(qunlock())
//            FAT->(dbcommit())
//         endif
//       endif
//   endif



return

static function buscaMunicipio(cCodIbge,cMunic)
local cCodMunic := ""
   if ! empty(cCodIbge)
      MUNIC->(dbsetorder(1))
      if MUNIC->(dbseek(cCodIbge))
         cCodMunic := MUNIC->Codigo
      endif
   else
      MUNIC->(dbsetorder(2))
     if MUNIC->(dbseek(rtrim(cMunic)))
        cCodMunic := MUNIC->Codigo
     endif
   endif
        
return  cCodMunic

static function i_trocachr(cTROCADO)

   cTROCADO := strtran(cTROCADO,",","")
   cTROCADO := strtran(cTROCADO,"'"," ")
   cTROCADO := strtran(cTROCADO,"€","C")
   cTROCADO := strtran(cTROCADO,"‡","c")
   cTROCADO := strtran(cTROCADO,"§",".")
   cTROCADO := strtran(cTROCADO,"¦","a")
   cTROCADO := strtran(cTROCADO,"‚","e")
   cTROCADO := strtran(cTROCADO,"ƒ","a")
   cTROCADO := strtran(cTROCADO,"„","a")
   cTROCADO := strtran(cTROCADO,"…","a")
   cTROCADO := strtran(cTROCADO,"†","a")
   cTROCADO := strtran(cTROCADO,"ˆ","e")
   cTROCADO := strtran(cTROCADO,"‰","e")
   cTROCADO := strtran(cTROCADO,"Š","e")
   cTROCADO := strtran(cTROCADO,"‹","i")
   cTROCADO := strtran(cTROCADO,"Œ","i")
   cTROCADO := strtran(cTROCADO,"","i")
   cTROCADO := strtran(cTROCADO,"“","o")
   cTROCADO := strtran(cTROCADO,"Ž","A")
   cTROCADO := strtran(cTROCADO,"","A")
   cTROCADO := strtran(cTROCADO,"","E")
   cTROCADO := strtran(cTROCADO,"“","o")
   cTROCADO := strtran(cTROCADO,"”","o")
   cTROCADO := strtran(cTROCADO,"•","o")
   cTROCADO := strtran(cTROCADO,"–","u")
   cTROCADO := strtran(cTROCADO,"—","u")
   cTROCADO := strtran(cTROCADO,"™","o")
   cTROCADO := strtran(cTROCADO,"š","U")
   cTROCADO := strtran(cTROCADO," ","a")
   cTROCADO := strtran(cTROCADO,"¡","i")
   cTROCADO := strtran(cTROCADO,"¢","o")
   cTROCADO := strtran(cTROCADO,"£","u")
   cTROCADO := strtran(cTROCADO,"¤","n")
   cTROCADO := strtran(cTROCADO,"&","E")
   cTROCADO := strtran(cTROCADO,"-","")
   cTROCADO := strtran(cTROCADO,"=","")
   cTROCADO := strtran(cTROCADO,"_","")
   cTROCADO := strtran(cTROCADO,"ø","")

return(cTROCADO)

static function readFile(cFile,cTIPO)
local fileHnd   := 0
local cBuffer   := ""
local nTTLinhas := 0
local nLinha    := 1
local nSize     := 0
local nLastLine := 0
local cEOL  := chr(13)+chr(10)
local nPos := 0
local fileHnd2 := 0
local cNFe := ""
local cStatus  := ""
local cMotivo  := ""
local cRecibo  := ""
local cDataRec := ""
local cautoriz := ""
local cDigVal  := ""
local nEol := 0

  do while .T.
     fileHnd := fopen(cFile,2)
     if ferror() == 0
        exit
     endif
  enddo

  nSize := fseek(fileHnd,0,2)
  cBuffer := space(nSize)
  fseek(fileHnd,0)
  fRead(fileHnd,@cBuffer,nSize)

  if left(cBuffer,4) == "ERRO"
     alert(i_trocachr(cBuffer))
  endif

  do case
     case cTIPO == "ENVIAR"
          if left(cBuffer,2) == "OK"
             cRetorno := substr(cBuffer,at("[RETORNO]",cBuffer),len(cBuffer))

             cStatus  := right(substr(cRetorno,at("CStat",cRetorno),9),3)

             cNFE     := substr(cRetorno,at("ChNFe",cRetorno),len(cRetorno))
             nEol     := at(cEOL,cNFE)-6
             cNFE     := substr(cNFE,7,nEol-1)

             cMotivo  := substr(cRetorno,at("XMotivo",cRetorno),len(cRetorno))
             nEol     := at(cEOL,cMotivo)-8
             cMotivo    := substr(cMOTIVO,9,nEol-1)

             cRecibo  := substr(cRetorno,at("NRec",cRetorno),len(cRetorno))
             nEol     := at(cEOL,cRecibo)-5
             cRecibo  := substr(cRecibo,6,nEol-1)

             cDataRec := substr(cRetorno,at("DhRecbto",cRetorno),len(cRetorno))
             nEol     := at(cEOL,cDataRec)-9
             cDataRec := substr(cDataRec,10,nEol-1)

             cAutoriz := substr(cRetorno,at("NProt",cRetorno),len(cRetorno))
             nEol     := at(cEOL,cAutoriz)-6
             cAutoriz := substr(cAutoriz,7,nEol-1)

             cDigVal  := substr(cRetorno,at("DigVal",cRetorno),len(cRetorno))
             nEol     := at(cEOL,cDigVal)-7
             cDigVal  := substr(cDigVal,8,nEol-1)

             //alert("Nota.: "+cNfe+ ";Recibo.: "+cRecibo+";Data.: "+cDataRec+";Autorizacao.: "+cAutoriz+";DigVal.: "+cDigVal)

             do case
                case cSTATUS == "100"
                     alert("NFe Autorizada! ;"+cNFE)
                     if FAT->(qrlock())
                        replace FAT->Nfe       with cNFE
                        replace FAT->Modelo    with "55"
                        replace FAT->Status    with cStatus
                        replace FAT->Recibo    with cRecibo
                        FAT->(qunlock())
                     endif

                     if RECIBO->(Qappend())
                        replace RECIBO->Cod_fat   with FAT->Codigo
                        replace RECIBO->Datarec   with cDataRec
                        replace RECIBO->Protocolo with cAutoriz
                        replace RECIBO->recibo    with cRecibo
                        replace RECIBO->DigVal    with cDigVal
                        replace RECIBO->Status    with cStatus
                     endif


                case cSTATUS == "105"
                     if FAT->(qrlock())
                        replace FAT->Nfe       with getNFe(iif(CONFIG->scan,"3","1")) + qdigNFe(getNFe(iif(CONFIG->scan,"3","1")))
                        replace FAT->Modelo    with "55"
                        replace FAT->Status    with cStatus
                        replace FAT->Recibo    with cRecibo
                        FAT->(qunlock())
                     endif

                //     if RECIBO->(Qappend())
                //        replace RECIBO->Cod_fat   with FAT->Codigo
                //        replace RECIBO->Datarec   with cDataRec
                //        replace RECIBO->Protocolo with cAutoriz
                //        replace RECIBO->recibo    with cRecibo
                //        replace RECIBO->DigVal    with cDigVal
                // /       replace RECIBO->Status    with cStatus
                //     endif

                     alert(cStatus+";"+cMotivo+";Aguarde um momento e tente novamente!")

                otherwise
                     alert("NFe Nao autorizada! ;"+cStatus+";"+cMotivo)

             endcase

          endif


     case cTIPO == "CONSULTAR"
          if left(cBuffer,2) == "OK"
             cRetorno := substr(cBuffer,at("[CONSULTA]",cBuffer),len(cBuffer))

             cStatus  := right(substr(cRetorno,at("CStat",cRetorno),9),3)

             //cNFE     := substr(cRetorno,at("ChNFe",cRetorno),len(cRetorno))
             //nEol     := at(cEOL,cNFE)-6
             //cNFE     := substr(cNFE,7,nEol-1)

             //cMotivo  := substr(cRetorno,at("XMotivo",cRetorno),len(cRetorno))
             //nEol     := at(cEOL,cMotivo)-8
             //cMotivo    := substr(cMOTIVO,9,nEol-1)

             //cRecibo  := substr(cRetorno,at("NRec",cRetorno),len(cRetorno))
             //nEol     := at(cEOL,cRecibo)-5
             //cRecibo  := substr(cRecibo,6,nEol-1)

             cDataRec := substr(cRetorno,at("DhRecbto",cRetorno),len(cRetorno))
             nEol     := at(cEOL,cDataRec)-9
             cDataRec := substr(cDataRec,10,nEol-1)

             cAutoriz := substr(cRetorno,at("NProt",cRetorno),len(cRetorno))
             nEol     := at(cEOL,cAutoriz)-6
             cAutoriz := substr(cAutoriz,7,nEol-1)

             //cDigVal  := substr(cRetorno,at("DigVal",cRetorno),len(cRetorno))
             //nEol     := at(cEOL,cDigVal)-7
             //cDigVal  := substr(cDigVal,8,nEol-1)

             //alert("Nota.: "+cNfe+ ";Recibo.: "+cRecibo+";Data.: "+cDataRec+";Autorizacao.: "+cAutoriz+";DigVal.: "+cDigVal)

             do case
                case cSTATUS == "100"
                     alert("NFe Autorizada! ;"+cNFE)
                     if FAT->(qrlock())
                        //replace FAT->Nfe       with cNFE
                        //replace FAT->Modelo    with "55"
                        replace FAT->Status    with cStatus
                        //replace FAT->Recibo    with cRecibo
                        FAT->(qunlock())
                     endif

                     if RECIBO->(Qappend())
                        replace RECIBO->Cod_fat   with FAT->Codigo
                        replace RECIBO->Datarec   with cDataRec
                        replace RECIBO->Protocolo with cAutoriz
                        replace RECIBO->recibo    with cRecibo
                        replace RECIBO->DigVal    with cDigVal
                        replace RECIBO->Status    with cStatus
                     endif

                     //setXmlProtocolo(FAT->NFe,cAutoriz,cDataRec)


                case cSTATUS == "105"
                     if FAT->(qrlock())
                 //       replace FAT->Nfe       with cNFE
                 //       replace FAT->Modelo    with "55"
                        replace FAT->Status    with cStatus
                //        replace FAT->Recibo    with cRecibo
                        FAT->(qunlock())
                     endif

                     if RECIBO->(Qappend())
                        replace RECIBO->Cod_fat   with FAT->Codigo
                        replace RECIBO->Datarec   with cDataRec
                        replace RECIBO->Protocolo with cAutoriz
                        replace RECIBO->recibo    with cRecibo
                        replace RECIBO->DigVal    with cDigVal
                        replace RECIBO->Status    with cStatus
                     endif

                     alert(cStatus+";"+cMotivo+";Aguarde um momento e tente novamente!")

                otherwise
                     alert("NFe Nao autorizada! ;"+cStatus+";"+cMotivo)

             endcase

          endif

     case cTIPO == "CANCELAR"
          if left(cBuffer,2) == "OK"
             cRetorno := substr(cBuffer,at("[CANCELAMENTO]",cBuffer),len(cBuffer))
             cStatus  := right(substr(cRetorno,at("CStat",cRetorno),9),3)
             cNFE     := substr(cRetorno,at("ChNFe",cRetorno),len(cRetorno))
             nEol     := at(cEOL,cNFE)-6
             cNFE     := substr(cNFE,7,nEol-1)

             cMotivo  := substr(cRetorno,at("XMotivo",cRetorno),len(cRetorno))
             nEol     := at(cEOL,cMotivo)-8
             cMotivo  := substr(cMOTIVO,9,nEol-1)

             if cStatus == "101"
                alert("Cancelamento de NFe Homologado! ;"+cNFE)
				return "101"
             else
                alert("Cancelamento Nao Homologado ;"+cStatus+";"+cMotivo)
				return "000"
             endif
          endif
		  
		  return "000"

     case cTIPO == "INUTILIZAR"
          if left(cBuffer,2) == "OK"
             cRetorno := substr(cBuffer,at("[INUTILIZACAO]",cBuffer),len(cBuffer))
             cStatus  := right(substr(cRetorno,at("CStat",cRetorno),9),3)
             cNFE     := substr(cRetorno,at("ChNFe",cRetorno),len(cRetorno))
             nEol     := at(cEOL,cNFE)-6
             cNFE     := substr(cNFE,7,nEol-1)

             cMotivo  := substr(cRetorno,at("XMotivo",cRetorno),len(cRetorno))
             nEol     := at(cEOL,cMotivo)-8
             cMotivo  := substr(cMOTIVO,9,nEol-1)

             if cStatus == "102"
                alert("Inutilizacao de Numero Homologado!")
             else
                alert("Inutilizacao Nao Homologado ;"+cStatus+";"+cMotivo)
             endif
          endif

   endcase


  fclose(fileHnd)

  if ferase(cFile) == -1
     alert(str(ferror()))
  endif


return

static function i_menos_pontos(cCOD_REPRES,cCOD_PROD,nQUANT,nPRECO)
local nREG   := 0
local nINDEX := 0
local nPONTOS := 0

nREG   := PROD->(Recno())
nINDEX := PROD->(IndexOrd())

MILHAS->(Dbsetorder(2))

PROD->(Dbsetorder(4))

if PROD->(dbseek(cCOD_PROD))
   nPONTOS := PROD->Pontos
else
   nPONTOS := 0
endif


if left(FAT->Cod_cfop,3) $ "510-540-610-640-511-611"
   if MILHAS->(Dbseek(cCOD_REPRES))
      if MILHAS->(Qrlock()) .and. FAT->Dt_emissao >= MILHAS->Data_ini
         replace MILHAS->Pontos with MILHAS->Pontos - ( (nPRECO * nQUANT) * nPONTOS )
      endif
   endif
endif

PROD->(dbgoto(nREG))
PROD->(dbsetorder(nINDEX))

return

static function i_mais_pontos(cCOD_REPRES,cCOD_PROD,nQUANT,nPRECO)
local nREG   := 0
local nINDEX := 0
local nPONTOS := 0

nREG   := PROD->(Recno())
nINDEX := PROD->(IndexOrd())

MILHAS->(Dbsetorder(2))

PROD->(Dbsetorder(4))

if PROD->(dbseek(cCOD_PROD))
   nPONTOS := PROD->Pontos
else
   nPONTOS := 0
endif


if left(FAT->Cod_cfop,3) $ "120-220"
   if MILHAS->(Dbseek(cCOD_REPRES))
      if MILHAS->(Qrlock()) .and. FAT->Dt_emissao >= MILHAS->Data_ini
         replace MILHAS->Pontos with MILHAS->Pontos + ( (nPRECO * nQUANT) * nPONTOS )
      endif
   endif
endif

PROD->(dbgoto(nREG))
PROD->(dbsetorder(nINDEX))

return

static function CancelarNfe(cDestino)
local CancelouNaSefaPR := .F.
local cChave := ""

    if FAT->Cancelado
       qmensa("Esta Nota Fiscal ja esta Cancelada!!!","B")
       return .F.
    endif

    if empty(FAT->Num_fatura)
       qmensa("Pedido Nao Faturado, impossivel Cancelar!!!","B")
       return .F.
    endif
	
	if qconf("Cofirma cancelamento de Nota Fiscal?")
	
	   cChave := ""
	   cChave := FAT->NFe  //CONFIG->Unidade+":\Qsys_g\Qfa_cl\Nfe\Autorizadas\"+FAT->NFe+"-NFe.xml"
	
	   CancelouNaSefaPR := cancelouNFe(buildNFe(),cChave)
	
	   if CancelouNaSefaPR // True

          ITEN_FAT->(Dbgotop())
          ITEN_FAT->(Dbseek(FAT->Codigo))

          do while ! ITEN_FAT->(eof()) .and. ITEN_FAT->Num_fat == FAT->Codigo

             if CONFIG->Modelo_fat == "1"
                if ITEN_FAT->Marcado $ "P- "
                   ITEN_FAT->(Dbskip())
                   loop
                endif
             endif

             INVENT->(dbclearfilter())
             INVENT->(dbsetorder(1))
		  
             if FAT->es == "S"
                i_entra_mantra(ITEN_FAT->Quantidade,ITEN_FAT->Local,ITEN_FAT->Terceiros)
               // i_menos_pontos(FAT->Cod_Repres,ITEN_FAT->Cod_prod,ITEN_FAT->Quantidade,ITEN_FAT->Vl_unitar) 
			 else	
	 	        i_baixa_mantra(ITEN_FAT->Quantidade,ITEN_FAT->Local,ITEN_FAT->Terceiros)
               // i_mais_pontos(FAT->Cod_Repres,ITEN_FAT->Cod_prod,ITEN_FAT->Quantidade,ITEN_FAT->Vl_unitar)
		     endif	 

             ITEN_FAT->(Dbskip())

          enddo

           if FAT->Interface
             i_abre_receber()
             RECEBER->(dbsetorder(11))
             if  RECEBER->(dbseek(FAT->Num_fatura))
                  while ! RECEBER->(Eof()) .and. left(RECEBER->Fatura,6) == FAT->Num_fatura

                    if RECEBER->(qrlock())
                       RECEBER->(Dbdelete())
                       RECEBER->(Qunlock())
                    endif
                    RECEBER->(dbskip())
                 enddo
             endif

             RECEBER->(dbclosearea())

             SELECT FAT
          endif
		  
		  if FAT->Fiscal
		     if FAT->Es == "S"
                i_abre_sai()
                SAI->(dbsetorder(11))
				if  SAI->(dbseek(FAT->Num_fatura))
					do while ! SAI->(Eof()) .and. SAI->num_nf == FAT->Num_fatura
						if  SAI->Modelo == FAT->Modelo
							if SAI->(qrlock())
								replace SAI->Valor_liq  with 0
								replace SAI->Icm_base   with 0
								replace SAI->Icm_aliq   with 0
								replace SAI->Icm_vlr    with 0
								replace SAI->Icm_out    with 0
								replace SAI->Icm_red    with 0
								replace SAI->Ipi_base   with 0
								replace SAI->Ipi_out    with 0
								replace SAI->Ipi_vlr    with 0
								replace SAI->Icm_bc_s   with 0
								replace SAI->Icm_subst  with 0
								replace SAI->Obs        with "### NOTA FISCAL CANCELADA ###"	
								SAI->(Qunlock())
							endif	
						endif
						SAI->(dbskip())
					enddo
				endif
			 endif	
				
             SELECT FAT
          endif
		  
		  if FAT->Contabil
                i_abre_lanc()
                LANC->(dbsetorder(12))
				if  LANC->(dbseek(FAT->Codigo))
					if LANC->(qrlock())
                       LANC->(Dbdelete())
					   LANC->(Qunlock())
					endif	
				endif
				
             SELECT FAT
          endif

	   else	  
	      qmensa("Ocorreu algum problema ao homologar este Cancelamento na SEFA-PR. Tente novamente em alguns segundos...","BL")
	      return .F.
	   endif //Se cancelou na Sefa PR

  endif

return

static function CancelarLocalOnly()
local CancelouNaSefaPR := .F.
local cChave := ""

    if FAT->Cancelado
       qmensa("Esta Nota Fiscal ja esta Cancelada!!!","B")
       return .F.
    endif

    if empty(FAT->Num_fatura)
       qmensa("Pedido Nao Faturado, impossivel Cancelar!!!","B")
       return .F.
    endif
	
	if qconf("Cofirma cancelamento de Nota Fiscal?")
	
	   cChave := ""
	   cChave := FAT->NFe  //CONFIG->Unidade+":\Qsys_g\Qfa_cl\Nfe\Autorizadas\"+FAT->NFe+"-NFe.xml"
	
	   CancelouNaSefaPR := .T. //cancelouNFe(buildNFe(),cChave)
	
	   if CancelouNaSefaPR // True

          ITEN_FAT->(Dbgotop())
          ITEN_FAT->(Dbseek(FAT->Codigo))

          do while ! ITEN_FAT->(eof()) .and. ITEN_FAT->Num_fat == FAT->Codigo

             if CONFIG->Modelo_fat == "1"
                if ITEN_FAT->Marcado $ "P- "
                   ITEN_FAT->(Dbskip())
                   loop
                endif
             endif

             INVENT->(dbclearfilter())
             INVENT->(dbsetorder(1))
		  
             if FAT->es == "S"
                i_entra_mantra(ITEN_FAT->Quantidade,ITEN_FAT->Local,ITEN_FAT->Terceiros)
                //i_menos_pontos(FAT->Cod_Repres,ITEN_FAT->Cod_prod,ITEN_FAT->Quantidade,ITEN_FAT->Vl_unitar) 
			 else	
	 	        i_baixa_mantra(ITEN_FAT->Quantidade,ITEN_FAT->Local,ITEN_FAT->Terceiros)
                //i_mais_pontos(FAT->Cod_Repres,ITEN_FAT->Cod_prod,ITEN_FAT->Quantidade,ITEN_FAT->Vl_unitar)
		     endif	 

             ITEN_FAT->(Dbskip())

          enddo

           if FAT->Interface
             i_abre_receber()
             RECEBER->(dbsetorder(11))
             if  RECEBER->(dbseek(FAT->Num_fatura))
                  while ! RECEBER->(Eof()) .and. left(RECEBER->Fatura,6) == FAT->Num_fatura

                    if RECEBER->(qrlock())
                       RECEBER->(Dbdelete())
                       RECEBER->(Qunlock())
                    endif
                    RECEBER->(dbskip())
                 enddo
             endif

             RECEBER->(dbclosearea())

             SELECT FAT
          endif

          FAT->(qrlock())
          replace FAT->Cancelado with .T.
          replace FAT->Obs With "### NOTA FISCAL CANCELADA ###"
          FAT->(qunlock())
	   else	  
	      qmensa("Ocorreu algum problema ao homologar este Cancelamento na SEFA-PR. Tente novamente em alguns segundos...","BL")
	      return .F.
	   endif //Se cancelou na Sefa PR

  endif

return

static function ConsultarNfe(cDestino)

    if FAT->Cancelado
       qmensa("Esta Nota Fiscal ja esta Cancelada!!!","B")
       return .F.
    endif

    if empty(FAT->Num_fatura)
       qmensa("Pedido Nao Faturado, impossivel Cancelar!!!","B")
       return .F.
    endif

    if qconf("Verificar status da NFe?")

       set printer to (XDRV_NFE+cDESTINO)
       set device to printer
       set margin to 0
       setprc(0,0)
       @ prow()+1,00 say 'NFE.ConsultarNFe("'+FAT->NFe+'")'

       set printer to
       set device to screen

       readfile(XDRV_NFE+"SAI.TXT","CONSULTAR")

  endif


return



static function ImprimirDanfe(cDestino)
   local cUNIDADE := CONFIG->Unidade
   Local cStdOut, cStdErr

   cCommand := "java BorioNFe "+ cUnidade +":\\Qsys_g\\Qfa_cl\\Nfe\\Autorizadas\\"+FAT->NFe+"-nfe.xml"
   cCommand := "qlogin.exe"
   
    //hb_run( cCommand)
    
   
   set printer to (XDRV_NFE+cDESTINO)
   set device to printer
   set margin to 0
   setprc(0,0)
   //if FAT->Cancelado
   //   @ prow()+1,00 say 'NFE.ImprimirDanfe("'+cUNIDADE+':\Qsys_g\Qfa_cl\Nfe\Canceladas\'+FAT->NFe+'-NFe.xml")'
   //else
      @ prow()+1,00 say 'NFE.ImprimirDanfe("'+cUNIDADE+':\Qsys_g\Qfa_cl\Nfe\Autorizadas\'+FAT->NFe+'-NFe.xml")'
   //endif

   set printer to
   set device to screen

   readfile(XDRV_NFE+"SAI.TXT","IMPRIMIR")


return

static function ImprimirDanfePdf(cDestino)
   local cUNIDADE := CONFIG->Unidade
   set printer to (XDRV_NFE+cDESTINO)
   set device to printer
   set margin to 0
   setprc(0,0)
   //if FAT->Cancelado
   //   @ prow()+1,00 say 'NFE.ImprimirDanfePdf("'+cUNIDADE+':\Qsys_g\Qfa_cl\Nfe\Canceladas\'+FAT->NFe+'-NFe.xml")'
   //else
      @ prow()+1,00 say 'NFE.ImprimirDanfePdf("'+cUNIDADE+':\Qsys_g\Qfa_cl\Nfe\Autorizadas\'+FAT->NFe+'-NFe.xml")'
   //endif

   set printer to
   set device to screen

   readfile(XDRV_NFE+"SAI.TXT","IMPRIMIR")
return


static function InutilizarNfe(cDestino)
   set printer to (XDRV_NFE+cDESTINO)
   set device to printer
   set margin to 0
   setprc(0,0)
   FILIAL->(dbseek(FAT->Filial))
   @ prow()+1,00 say 'NFE.InutilizarNFe("'+FILIAL->cgccpf+'","Teste Inutilizacao",10,55,1,'+alltrim(str(val(FAT->Num_fatura)))+','+alltrim(str(val(FAT->Num_fatura)))+')'

   set printer to
   set device to screen

   readfile(XDRV_NFE+"SAI.TXT","INUTILIZAR")

return

function i_status
 local cStatus := "           "

 if FAT->Cancelado
    cStatus := "Cancelada  "
 else
    if FAT->Status == "105"
       cStatus := "Processando"
    else
       if ! empty(FAT->NFe)
          cStatus := "Autorizada "
       endif
    endif
 endif


return cStatus


static function i_abre_lanc()
local labriu := .F.

   if ! quse(XDRV_CT,"LANC",{"LA_DATA","LA_DBDAT","LA_CRDAT","LA_NLANC","LA_LOLAN","LA_CEDBD","LA_CECRD","LA_DTFIL","LA_FICTD","LA_FICTC","LA_DTNUM","LANC_FAT","LANC_DOC"})
      Qmensa("Nao foi possivel abrir arquivo LANC.DBF !","B")
      lAbriu := .F.
   else
      lAbriu := .T.
   endif
return lAbriu


static function i_abre_sai()
local labriu := .F.

   if ! quse(XDRV_EF,"SAI",{"SAI_NUM","SAI_LANC","SAI_FISC","SAI_VEND","SAI_FIS2","SAI_CONT","SAI_NFFI","SAI_CFOP","SAI_CFP2","SAI_EMISS","NUMNFTX"})
      Qmensa("Nao foi possivel abrir arquivo SAI.DBF !","B")
      lAbriu := .F.
   else
      lAbriu := .T.
   endif
return lAbriu


static function i_abre_receber()
local labriu := .F.

   if ! quse(XDRV_RB,"RECEBER",{"REC_COD","REC_VENC","REC_DUP","REC_DTEM","REC_CLIE","REC_LOTE","REC_BANC","REC_CLRZ","REC_CDCL","RB_DTVCL","REC_FATU","RECCLIVC"})
      Qmensa("Nao foi possivel abrir arquivo RECEBER.DBF !","B")
      lAbriu := .F.
   else
      lAbriu := .T.
   endif
return lAbriu

static function i_entra_mantra(nQTY,nLOCAL,nTERCEIROS) //Executa estoques...

      if INVENT->(dbseek(FAT->Filial+ITEN_FAT->Cod_prod+ITEN_FAT->Num_lote))

         if INVENT->(Qrlock())
            replace INVENT->Quant_atu with INVENT->Quant_atu + nQTY
            INVENT->(Qunlock())
         endif
       else
          qmensa("Lote nao encontrado nesta Filial !","B")
          return .F.
      endif

return

static function i_baixa_mantra(nQTY,nLOCAL,nTERCEIROS) //Executa estoques...

      if INVENT->(dbseek(FAT->Filial+ITEN_FAT->Cod_prod+ITEN_FAT->Num_lote))

         if INVENT->(Qrlock())
		    if INVENT->Quant_atu >= nQTY
               replace INVENT->Quant_atu with INVENT->Quant_atu - nQTY
			endif   
            INVENT->(Qunlock())
         endif
       else
          qmensa("Lote nao encontrado nesta Filial !","B")
          return .F.
      endif

return



static function getNFe(cTipo)
local cNFE   := ""
   cNFE := "41"
   cNFE += substr(strzero(year(FAT->dt_emissao),4),3,2)
   cNFE += strzero(month(FAT->dt_emissao),2)
   FILIAL->(dbseek(FAT->Filial))
   cNFE += FILIAL->Cgccpf
   cNFE += "55" +iif(cTipo =="3","900","001")
   cNFE += "000"+FAT->Num_fatura
   cNFE += cTipo + "00"+FAT->Num_fatura

return cNFE

static function qdigNFe ( cSTRING )

  local nSOMA, nRESTO, cDIGITO, nCONT, nCTRL

  nSOMA   := 0
  nRESTO  := 0
  cDIGITO := 0
  nCTRL   := 2

  for nCONT = len(cSTRING) to 1 Step -1
    nSOMA += val(subs(cSTRING,nCONT,1)) * nCTRL

    if nCTRL = 9
       nCTRL = 1
    endif
    nCTRL++
  next


  nRESTO = nSOMA % 11


  if nRESTO = 0 .or. nRESTO = 1
     cDIGITO := 0
  else
     cDIGITO := 11 - nRESTO
  endif

return str(int(cDIGITO),1)


static function setXmlprotocolo(cNFE,cAuth,cData)
local cBuffer    := ""
local nFile      := 0
local nSize      := 0
local nPosicaoIniDigest := 0
local nPosicaoFimDigest := 0
local cDigVal    := ""
local cIni := ""
local cFinal := ""
local cNFeComAuth := ""


   nFile := fopen(XDRV_NFE+"\logs\"+cNFE+"-Nfe.Xml",2)

   if ferror() == 0
      alert("OK")
   else
      alert(str(ferror(),2))
   endif

   nSize := fseek(nFile,0,2)
   cBuffer := space(nSize)
   fseek(nFile,0)
   fRead(nFile,@cBuffer,nSize)

   nPosicaoIniDigest := at("<DigestValue>",cBuffer)
   nPosicaoIniDigest += 13

   nPosicaoFimDigest := at("</DigestValue>",cBuffer)
   //nPosicaoFimDigest -= 14

   cDigVal := substr(cBuffer,nPosicaoIniDigest,nPosicaoFimDigest-nPosicaoIniDigest)

   //alert(cDigVal + str(nPosicaoIniDigest,5)+"   "+str(nPOsicaoFimDigest,5)+"   ")

   cIni := '<?xml version="1.0" encoding="UTF-8" ?>'
   cIni += '<nfeProc versao="2.00" xmlns="http://www.portalfiscal.inf.br/nfe">'


   cFinal := '<protNFe versao="2.00">'
   cFInal += '<infProt>'
   cFInal += '<tpAmb>1</tpAmb>'
   cFinal += '<verAplic>PR-v2_1_18</verAplic>'
   cFinal += '<chNFe>'+FAT->Nfe+'</chNFe>'
   cFinal += '<dhRecbto>'+cData+'</dhRecbto>'
   cFinal += '<nProt>'+cAuth+'</nProt>'
   cFinal += '<DigVal>'+cDigVal+'</DigVal>'
   cFinal += '<cStat>100</cStat>'
   cFinal += '<xMotivo>Autorizado o uso da NF-e</xMotivo>'
   cFInal += '</infProt>'
   cFInal += '</protNFe>'
   cFInal += '</nfeProc>'

//   cBuffer :=
   cNFeComAuth := cIni+cBuffer+cFinal

   fseek(nFile,0,0)


  // fwrite(nFile,cNfeComAuth,len(cNfecomAuth))
  // fClose(nFile)
  // _filecopy(XDRV_NFE+"\logs\"+FAT->Nfe+"-nfe.xml",Config->Unidade+":\Qsys_g\Qfa_cl\Nfe\Autorizadas\")

//  copy file (XDRV_NFE+"\logs\"+FAT->Nfe+"-nfe.xml") to (Config->Unidade+":\Qsys_g\Qfa_cl\Nfe\Autorizadas\"+FAT->Nfe+"-nfe.xml")

return

static function aliqMVA(cNCM , cES)

    if cNCM == "90191000"
	   if cES == "5"
          return 1.34
       endif 	   
	   
	   if cES == "6"
          return 1.438
       endif
	endif
	
	if cNCM == "39221000"
	   if cES == "5"
          return 1.41
       endif 	   
	   
	   if cES == "6"
          return 1.5132
       endif
	endif
	
return 1

static function CriarNFeST(cDestino)
local cCodMunic    := ""
local nCONT        := 0
local nTotal       := 0
local nICMS        := 0
local nICMS_DIF    := 0
local nIPI         := 0
local nBASE_ICMS   := 0
local nBASE_IPI    := 0
local nInfAdic := 0
local nALIQ_ICMS := 0
local nMVA     := 0
local cNCM     := ""
local nIcmsItem := 0
local nBaseItem := 0
local nVU := 0

local nTTBC_Icm := 0
local nBC_Icm := 0

local nIcm    := 0
local nTTIcm  := 0

local nIPIST    :=  0
local nTTIPIST  :=  0

local nBC_ST   := 0
local nTTBC_ST := 0

local nST     := 0
local nTTST   := 0
local nSTPG   := 0
local nTTSTPG   := 0



local lVenda := .F.
local cEstados := ""

   set printer to (XDRV_NFE+cDESTINO)
   set device to printer
   set margin to 0
   setprc(0,0)

   @ prow()   ,00 say "NFE.CriarEnviarNFe([Identificacao]"
   CFOP->(dbseek(FAT->cod_cfop))
   @ prow()+1 ,03 say "NaturezaOperacao="+i_trocachr(left(CFOP->Nat_desc,20))
   @ prow()+1 ,03 say "Modelo=55"
   @ prow()+1 ,03 say "Serie=1"
   @ prow()+1 ,03 say "Codigo="+FAT->Num_fatura
   @ prow()+1 ,03 say "Numero="+FAT->Num_fatura
   @ prow()+1 ,03 say "Emissao="+dtoc(date())
//   @ prow()+1 ,03 say "Saida="+dtoc(date())
   if FAT->Es == "S"
      @ prow()+1 ,03 say "Tipo=1"
   else
      @ prow()+1 ,03 say "Tipo=0"
   endif

   if DUP_FAT->(dbseek(FAT->Codigo+"01"))
      @ prow()+1 ,03 say "FormaPag=1"
   else
      if left(FAT->cod_cfop,3) $ "510-610-511-512-611-612-540-640"
         @ prow()+1 ,03 say "FormaPag=0"
      else
         @ prow()+1 ,03 say "FormaPag=2"
      endif
   endif
   @ prow()+1 ,03 say "Finalidade=0"
   @ prow()+1 ,03 say "[Emitente]"
   FILIAL->(dbseek(FAT->Filial))
   @ prow()+1 ,03 say "CNPJ="+FILIAL->cgccpf
   @ prow()+1 ,03 say "IE="+qtiraponto(FILIAL->Insc_estad)
   
   CLI1->(dbseek(FAT->Cod_cli))
   CGM->(dbseek(CLI1->cgm_ent))
   if CGM->Estado == "PR"
      @ prow()+1 ,03 say "IEST="+qtiraponto(FILIAL->Insc_st)
   endif	  
   @ prow()+1 ,03 say "Razao="+i_trocachr(rtrim(FILIAL->Razao))
   @ prow()+1 ,03 say "Fantasia="+i_trocachr(rtrim(FILIAL->Fantasia))
   @ prow()+1 ,03 say "Fone="+i_trocachr(FILIAL->Telefone)
   @ prow()+1 ,03 say "CEP="+FILIAL->Cep
   @ prow()+1 ,03 say "Logradouro="+i_trocachr(rtrim(FILIAL->Endereco))
   @ prow()+1 ,03 say "Numero="+strzero(FILIAL->numero,6)
   @ prow()+1 ,03 say "Complemento="+i_trocachr(rtrim(FILIAL->Compl))
   @ prow()+1 ,03 say "Bairro="+i_trocachr(rtrim(FILIAL->Bairro))
   CGM->(dbseek(FILIAL->Cgm))
   @ prow()+1 ,03 say "CidadeCod="+BuscaMunicipio(CGM->Cod_rais,CGM->Municipio)
   @ prow()+1 ,03 say "Cidade="+rtrim(CGM->Municipio)
   @ prow()+1 ,03 say "UF="+CGM->Estado

   @ prow()+1 ,03 say "[Destinatario]"
   CLI1->(dbseek(FAT->Cod_cli))
   @ prow()+1 ,03 say "CNPJ="+CLI1->cgccpf
   @ prow()+1 ,03 say "IE="+qtiraponto(CLI1->Inscricao)
   @ prow()+1 ,03 say "NomeRazao="+i_trocachr(rtrim(CLI1->Razao))
   @ prow()+1 ,03 say "Fone="+i_trocachr(CLI1->Fone1)
   @ prow()+1 ,03 say "CEP="+CLI1->Cep_ent
   @ prow()+1 ,03 say "Logradouro="+i_trocachr(rtrim(CLI1->End_ent))
   @ prow()+1 ,00 say "Numero="+alltrim(CLI1->Numero)
   @ prow()+1 ,00 say "Complemento="+i_trocachr(alltrim(CLI1->Compl))
   @ prow()+1 ,03 say "Bairro="+i_trocachr(rtrim(CLI1->Bairro_ent))
   CGM->(dbseek(CLI1->Cgm_ent))
   @ prow()+1 ,03 say "CidadeCod="+BuscaMunicipio(CGM->Cod_rais,CGM->Municipio)
   @ prow()+1 ,03 say "Cidade="+rtrim(CGM->Municipio)
   @ prow()+1 ,03 say "UF="+CGM->Estado

   nICMS        := 0
   nICMSST      := 0
   nBASE_ICMSST := 0
   nBASE        := 0
   nTOTAL       := 0


   ITEN_FAT->(dbsetorder(2))
   ITEN_FAT->(dbseek(FAT->Codigo))
   PROD->(dbsetorder(4))
   nCONT := 1
   
   ESTADO->(dbseek(CGM->Estado))
   nALIQ_INT :=  ESTADO->Aliq_inter
   
   do while ! ITEN_FAT->(eof()) .and. ITEN_FAT->Num_fat == FAT->Codigo

      PROD->(dbseek(ITEN_FAT->Cod_prod))
	  
      if IT_CLASS->(dbseek(PROD->Cod_Class+CGM->Estado))
         nMVA := IT_CLASS->Mva
      endif
	  
      @ prow()+1,03 say "[PRODUTO"+strzero(nCONT,3)+"]"
	  if alltrim(FAT->Cod_cfop) $ "5102-6102-5101-6101-5401-5402-5403-6401-6402-6403"
	     lVenda := .T.   
	  endif
      
	  if lVenda
	     if nMVA > 0 .and. CGM->Estado $ cEstados  //Se tem Substituição
	        @ prow()+1,03 say "CFOP=" + left(alltrim(FAT->Cod_cfop),1) + "403"
		 else
            @ prow()+1,03 say "CFOP=" +alltrim(FAT->Cod_cfop)
         endif		 
	  else
	      @ prow()+1,03 say "CFOP="+alltrim(FAT->Cod_cfop)
	  endif	  
		  
      if CONFIG->Modelo_fat =="1"
         @ prow()+1,03 say "Codigo="+rtrim(PROD->cod_fabr)
      else
         @ prow()+1,03 say "Codigo="+right(PROD->codigo,5)
      endif
     
	 if CLASSIF->(dbseek(PROD->Cod_class))
         @ prow()+1,03 say "NCM="+alltrim(i_trocachr(CLASSIF->Descricao))
		 cNCM := alltrim(i_trocachr(CLASSIF->Descricao))
      endif

      @ prow()+1,03 say "Descricao="+rtrim(PROD->Descricao)
      UNIDADE->(dbseek(PROD->Unidade))
      @ prow()+1,03 say "Unidade="+alltrim(UNIDADE->Sigla)
      @ prow()+1,03 say "Quantidade="+alltrim(transf(ITEN_FAT->Quantidade,"@R 9999999"))
      @ prow()+1,03 say "ValorUnitario="+alltrim(transf(ITEN_FAT->vl_unitar,"@R 9999999.99"))
      @ prow()+1,03 say "ValorTotal="+alltrim(transf(ITEN_FAT->Quantidade*ITEN_FAT->vl_unitar,"@R 9999999.99"))
      
      @ prow()+1,03 say "[ICMS"+strzero(nCONT,3)+"]"
      @ prow()+1,03 say "Origem="+left(ITEN_FAT->Cod_sit,1)
	  
	  if lVenda
	     if nMVA > 0 .and. CGM->Estado $ cEstados//Se tem Substituição
	        @ prow()+1,03 say "CST=" + "10"
		 else
            @ prow()+1,03 say "CST=" + right(ITEN_FAT->Cod_sit,2)
         endif		 
	  else
	      @ prow()+1,03 say "CST="+right(ITEN_FAT->Cod_sit,2)
	  endif
	  
         @ prow()+1,03 say "Aliquota="+alltrim(transf(ITEN_FAT->Icms,"@R 99.99"))

		 if left(FAT->Cod_cfop,1) $ "1-5" .and. CLI1->Isento == "S"
		    @ prow()+1,03 say "PercentualReducao="+alltrim(transf(33.33,"@R 9999999.99"))
			nBaseItem := (ITEN_FAT->vl_unitar*ITEN_FAT->Quantidade)
			nBaseItem := nBaseItem - (nBaseItem*0.3333)
			if ITEN_FAT->Icms > 0
		        @ prow()+1,03 say "ValorBase="+alltrim(transf(nBaseItem,"@R 9999999.99"))
     			nIcmsItem := (ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade)*(ITEN_FAT->Icms/100)
		     	nIcmsItem := nIcmsItem - (nIcmsItem * 0.3333)
		        @ prow()+1,03 say "Valor="+alltrim(transf(nIcmsItem,"@R 9999999.99"))
			endif	
		 else
		    
			if ITEN_FAT->Icms > 0
		       @ prow()+1,03 say "ValorBase="+alltrim(transf(ITEN_FAT->vl_unitar*ITEN_FAT->Quantidade,"@R 9999999.99"))
	           @ prow()+1,03 say "Valor="+alltrim(transf((ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade)*(ITEN_FAT->Icms/100),"@R 9999999.99"))
			endif
			
			if lVenda
	           if nMVA > 0 .and. CGM->Estado $ cEstados  //Se tem Substituição
			      nVU := round(ITEN_FAT->Vl_unitar,2)

                  nTTBC_Icm += (ITEN_FAT->Quantidade * nVU)
                  nBC_Icm := ITEN_FAT->Quantidade * nVU

                  nIcm    := ( ( ITEN_FAT->Quantidade * nVU  ) * (ITEN_FAT->Icms/100) )
                  nTTIcm  += ( (ITEN_FAT->Quantidade * nVU  ) * (ITEN_FAT->Icms/100) )

                  nIPIST    :=  ( ( ITEN_FAT->Quantidade * nVU ) * ( PROD->Ipi / 100 ) )
                  nTTIPIST  +=  ( ( ITEN_FAT->Quantidade * nVU ) * ( PROD->Ipi / 100 ) )

                  nBC_ST   := (nBC_ICM + nIPIST) + ( (nBC_ICM + nIPIST) * ( nMVA / 100) )
                  nTTBC_ST += (nBC_ICM + nIPIST) + ( (nBC_ICM + nIPIST) * ( nMVA / 100) )

                  nST     := ( nBC_ST * (nALIQ_INT/100))
                  nTTST   += ( nBC_ST * (nALIQ_INT/100))
				  
				  nSTPG := nST - nICM
				  nTTSTPG += (nST - nICM)
			     
            	  @ prow()+1,03 say "ValorBaseST="+alltrim(transf( nBC_ST,"@R 99999999.99"))
                  @ prow()+1,03 say "AliquotaST="+alltrim(transf(nALIQ_INT,"@R 99.99"))
                  @ prow()+1,03 say "ValorST="+alltrim(transf( nSTPG,"@R 99999999.99"))
			   endif
            endif			   
		 endif
		 
		 
         if ITEN_FAT->icms > 0 
            @ prow()+1,03 say "[IPI"+strzero(nCONT,3)+"]"
            @ prow()+1,03 say "CST="+ITEN_FAT->Cod_sit

            @ prow()+1,03 say "ValorBase="+alltrim(transf(ITEN_FAT->vl_unitar*ITEN_FAT->Quantidade,"@R 9999999.99"))
            @ prow()+1,03 say "Aliquota="+alltrim(transf(ITEN_FAT->IPI,"@R 99.99"))
            @ prow()+1,03 say "Valor="+alltrim(transf((ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade)*(ITEN_FAT->Ipi/100),"@R 9999999.99"))
		 else
            @ prow()+1,03 say "[IPI"+strzero(nCONT,3)+"]"
            @ prow()+1,03 say "CST="+ITEN_FAT->Cod_sit

            @ prow()+1,03 say "ValorBase="+alltrim(transf(ITEN_FAT->vl_unitar*ITEN_FAT->Quantidade,"@R 9999999.99"))
            @ prow()+1,03 say "Aliquota="+alltrim(transf(0,"@R 99.99"))
            @ prow()+1,03 say "Valor="+alltrim(transf(0,"@R 9999999.99"))
         endif		 
		 
	  nIPI := 0

      nBASE_IPI    += (ITEN_FAT->Quantidade * ITEN_FAT->Vl_unitar)
      nICMS        += ((ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade)*(ITEN_FAT->Icms/100))
      nALIQ_ICMS  := ITEN_FAT->Icms

      if ITEN_FAT->Icms > 0
         nBASE_ICMS   += (ITEN_FAT->Quantidade * ITEN_FAT->Vl_unitar)
         nIPI         += ((ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade)*(ITEN_FAT->Ipi/100))
      endif

      nTotal += (ITEN_FAT->Quantidade * ITEN_FAT->Vl_unitar) 

      nCONT++
      ITEN_FAT->(dbskip())
   enddo

   @ prow()+1, 03 say "[Total]"
   if CONFIG->simples != "S"

      if left(FAT->Cod_cfop,1) $ "1-5" .and. CLI1->Isento == "S"
         nICMS_DIF := (nICMS*0.3333)
         nICMS := nICMS-(nICMS*0.3333)
		 nBase_Icms := nBase_Icms - (nBase_icms * 0.3333)
      endif

      @ prow()+1, 03 say "BaseICMS="+alltrim(transf(nBase_Icms,"@R 9999999.99"))
      @ prow()+1, 03 say "ValorICMS="+alltrim(transf(nIcms,"@R 9999999.99"))
      @ prow()+1, 03 say "ValorIPI="+alltrim(transf(nIpi,"@R 9999999.99"))
      @ prow()+1, 03 say "BaseIcmsSubstituicao="+alltrim(transf(nTTBC_ST,"@R 9999999.99"))
      @ prow()+1, 03 say "ValorIcmsSubstituicao="+alltrim(transf(nTTSTPG,"@R 9999999.99"))
   endif


   @ prow()+1, 03 say "ValorProduto="+alltrim(transf(nTotal,"@R 9999999.99"))
   @ prow()+1, 03 say "ValorNota="+alltrim(transf(nTotal+(nTTSTPG)+nIPI,"@R 9999999.99"))

   TRANSP->(dbseek(FAT->Cod_transp))

   @ prow()+1, 03 say "[Transportador]"
   @ prow()+1, 03 say "FretePorConta="+strzero(val(FAT->Frete)-1,1)
   @ prow()+1, 03 say "CnpjCpf="+alltrim(i_trocachr(TRANSP->cgccpf))
   @ prow()+1, 03 say "IE="+alltrim(i_trocachr(TRANSP->Inscricao))
   @ prow()+1, 03 say "NomeRazao="+rtrim(i_trocachr(TRANSP->Razao))
   @ prow()+1, 03 say "Endereco="+rtrim(i_trocachr(TRANSP->Endereco))
   CGM->(dbseek(TRANSP->Cgm))
   @ prow()+1, 03 say "Cidade="+rtrim(CGM->Municipio)
   @ prow()+1, 03 say "UF="+CGM->Estado
   
   if ! empty(FAT->Cod_transp)
       if ! empty(TRANSP->Placa)
          @ prow()+1, 03 say "Placa="+alltrim(i_trocachr(TRANSP->Placa))
          @ prow()+1, 03 say "UFPlaca="+CGM->Estado
       endif      
   endif    

   @ prow()+1, 03 say "[volume001]"
   @ prow()+1, 03 say "Quantidade="+alltrim(transf(FAT->Qtde_vol,"@R 999999"))
   @ prow()+1, 03 say "Especie="+FAT->Especie
   @ prow()+1, 03 say "Marca="+FAT->Marca
   @ prow()+1, 03 say "Numeracao="+FAT->Numero
   @ prow()+1, 03 say "PesoBruto="+alltrim(transf(FAT->Peso_bruto,"@R 999999.99"))
   @ prow()+1, 03 say "PesoLiquido="+alltrim(transf(FAT->Peso_liqui,"@R 999999.99"))

   nCONT := 1

   if DUP_FAT->(dbseek(FAT->Codigo+"01"))
      do while left(DUP_FAT->Num_fat,5) == FAT->Codigo .and. ! DUP_FAT->(eof())
         @ prow()+1, 03 say "[Duplicata"+strzero(nCONT,3)+"]"
         @ prow()+1, 03 say "Numero="+FAT->Num_fatura + "/"+right(DUP_FAT->Num_fat,2)
         @ prow()+1, 03 say "Datavencimento="+dtoc(date()+DUP_FAT->Dias)
         @ prow()+1, 03 say "Valor="+alltrim(transf(DUP_FAT->Valor,"@R 9999999.999"))
         nCONT++
         DUP_FAT->(dbskip())
      enddo
   endif
   
   if nTTSTPG > 0
         @ prow()+1, 03 say "[Duplicata"+strzero(nCONT,3)+"]"
         @ prow()+1, 03 say "Numero="+FAT->Num_fatura + "/ST"
         @ prow()+1, 03 say "Datavencimento="+dtoc( date() + 10 )
         @ prow()+1, 03 say "Valor="+alltrim(transf(nTTSTPG,"@R 9999999.999"))
   endif	   
	   

   @ prow()+1, 03 say "[DadosAdicionais]"

      @ prow()+1, 03 say "Complemento="+rtrim(left(FAT->Obs,50))

      if ! empty(substr(FAT->Obs,51,50))
         @ prow(), pcol() say ";"+rtrim(substr(FAT->Obs,51,50))
      endif

      if ! empty(substr(FAT->Obs,101,50))
         @ prow(), pcol() say ";"+substr(FAT->Obs,101,50)
      endif

      if ! empty(substr(FAT->Obs,151,50))
         @ prow(), pcol() say ";"+substr(FAT->Obs,151,50)
      endif

      if CONFIG->Modelo_Fat == "1"
         if left(FAT->Cod_cfop,1) $ "1-5" .and. nIcms > 0 .and. CLI1->Isento == "S"
            @ prow()    ,pcol() say ";ICMS Diferido Conf. Art. 87-A do RICMS - Decreto No. 5141/01."
            @ prow()  ,pcol() say ";Valor do Icms Diferido.: "+alltrim(transf(nICMS_DIF,"@R 999999.99"))
         endif

         if ! empty(CLI1->msg_recife)
            @ prow()  ,pcol() say ";Contribuinte credenciado para nao-antecipacao de ICMS"
            @ prow()  ,pcol() say ";Edital DPC No. 004/2010 - RE ST"
         endif
      endif

   @ prow()+1, 03 say ",0,1)"

   nCONT := 1

   set printer to
   set device to screen

   readFile(XDRV_NFE+"SAI.TXT","ENVIAR")

   if ! empty(FAT->NFe) .and. FAT->Status == "100"

      if FAT->Es == "S"
         imprimirDanfe("ENT.TXT")
         imprimirDanfePdf("ENT.TXT")

         if CONFIG->Modelo_fat == "1"
            //blat()
			if TRANSP->(dbseek(FAT->cod_transp))
	           if ! empty(TRANSP->Email)
			      //blatTransp()
			   endif	  
			endif
         endif

      endif

   endif

//   if FAT->Status == "105"
//      if file(XDRV_NFE+"logs\"+getNFe()+qdigNFe(getNFe())+"-NFe.xml")
//         if FAT->(qrlock())
//            replace FAT->NFe with getNFe() + qdigNFe(getNFe())
//            replace FAT->Modelo with "55"
//            FAT->(qunlock())
//            FAT->(dbcommit())
//         endif
//       endif
//   endif

return

static function CriarNFe(cDestino,cFormaEmissao)
local cCodMunic    := ""
local nCONT        := 0
local nTotal       := 0
local nICMS        := 0
local nICMS_DIF    := 0
local nIPI         := 0
local nICMSST      := 0
local nBASE_ICMSST := 0
local nBASE_ICMS   := 0
local nBASE_IPI    := 0
local nValorSt     := 0
local aST := {}
local nInfAdic := 0
local nALIQ_ICMS := 0
local nIcmsItem := 0
local nMVA     := 0
local cNCM     := ""
local nBASE_PLAFORTE := 0
local nST_PLAFORTE   := 0
local cEstados := "PR"
local lTemST   := .F.
local nBaseItem   := 0
local nIcmsStItem := 0
local nBaseStItem := 0
local nBASE_ST := 0
local nST := 0

   set printer to (XDRV_NFE+cDESTINO)
   set device to printer
   set margin to 0
   setprc(0,0)
   
   @ prow()   ,00 say "NFE.CriarEnviarNFe([Identificacao]"
   CFOP->(dbseek(FAT->cod_cfop))
   @ prow()+1 ,03 say "NaturezaOperacao="+i_trocachr(left(CFOP->Nat_desc,20))
   @ prow()+1 ,03 say "Modelo=55"
   
   if cFormaEmissao == "3"
      @ prow()+1 ,03 say "Serie=900"
	  @ prow()+1 ,03 say "dhCont="+dtoc(CONFIG->dt_contin) + " " + CONFIG->hora_cont+":00"    
	  @ prow()+1 ,03 say "xJust=SEFAZ DO ESTADO DO PARANA FORA DE OPERACAO"
   else
      @ prow()+1 ,03 say "Serie=1"
   endif
   
   @ prow()+1 ,03 say "Codigo="+FAT->Num_fatura
   @ prow()+1 ,03 say "Numero="+FAT->Num_fatura
   @ prow()+1 ,03 say "Emissao="+dtoc(date())
//   @ prow()+1 ,03 say "Saida="+dtoc(date())
   if FAT->Es == "S"
      @ prow()+1 ,03 say "Tipo=1"
   else
      @ prow()+1 ,03 say "Tipo=0"
   endif

   if DUP_FAT->(dbseek(FAT->Codigo+"01"))
      @ prow()+1 ,03 say "FormaPag=1"
   else
      if left(FAT->cod_cfop,3) $ "510-610-511-512-611-612-540-640"
         @ prow()+1 ,03 say "FormaPag=0"
      else
         @ prow()+1 ,03 say "FormaPag=2"
      endif
   endif
   @ prow()+1 ,03 say "Finalidade=0"
   @ prow()+1 ,03 say "[Emitente]"
   FILIAL->(dbseek(FAT->Filial))
   @ prow()+1 ,03 say "CNPJ="+FILIAL->cgccpf
   @ prow()+1 ,03 say "IE="+qtiraponto(FILIAL->Insc_estad)
   
   CLI1->(dbseek(FAT->Cod_cli))
   CGM->(dbseek(CLI1->cgm_ent))
   if CGM->Estado == "PR"
      @ prow()+1 ,03 say "IEST="+qtiraponto(FILIAL->Insc_st)
   endif	  
   @ prow()+1 ,03 say "Razao="+i_trocachr(rtrim(FILIAL->Razao))
   @ prow()+1 ,03 say "Fantasia="+i_trocachr(rtrim(FILIAL->Fantasia))
   @ prow()+1 ,03 say "Fone="+i_trocachr(FILIAL->Telefone)
   @ prow()+1 ,03 say "CEP="+FILIAL->Cep
   @ prow()+1 ,03 say "Logradouro="+i_trocachr(rtrim(FILIAL->Endereco))
   @ prow()+1 ,03 say "Numero="+strzero(FILIAL->numero,6)
   @ prow()+1 ,03 say "Complemento="+i_trocachr(rtrim(FILIAL->Compl))
   @ prow()+1 ,03 say "Bairro="+i_trocachr(rtrim(FILIAL->Bairro))
   CGM->(dbseek(FILIAL->Cgm))
   @ prow()+1 ,03 say "CidadeCod="+BuscaMunicipio(CGM->Cod_rais,CGM->Municipio)
   @ prow()+1 ,03 say "Cidade="+rtrim(CGM->Municipio)
   @ prow()+1 ,03 say "UF="+CGM->Estado

   @ prow()+1 ,03 say "[Destinatario]"
   CLI1->(dbseek(FAT->Cod_cli))
   @ prow()+1 ,03 say "CNPJ="+CLI1->cgccpf
   @ prow()+1 ,03 say "IE="+qtiraponto(CLI1->Inscricao)
   @ prow()+1 ,03 say "NomeRazao="+i_trocachr(rtrim(CLI1->Razao))
   @ prow()+1 ,03 say "Fone="+i_trocachr(CLI1->Fone1)
   @ prow()+1 ,03 say "CEP="+CLI1->Cep_ent
   @ prow()+1 ,03 say "Logradouro="+i_trocachr(rtrim(CLI1->End_ent))
   @ prow()+1 ,00 say "Numero="+alltrim(CLI1->Numero)
   @ prow()+1 ,00 say "Complemento="+i_trocachr(alltrim(CLI1->Compl))
   @ prow()+1 ,03 say "Bairro="+i_trocachr(rtrim(CLI1->Bairro_ent))
   CGM->(dbseek(CLI1->Cgm_ent))
   @ prow()+1 ,03 say "CidadeCod="+BuscaMunicipio(CGM->Cod_rais,CGM->Municipio)
   @ prow()+1 ,03 say "Cidade="+rtrim(CGM->Municipio)
   @ prow()+1 ,03 say "UF="+CGM->Estado

   nICMS        := 0
   nICMSST      := 0
   nBASE_ICMSST := 0
   nBASE        := 0
   nTOTAL       := 0
   nBASE_ICMS   := 0
   nST          := 0
   nBASE_ST     := 0 
   nICMS_DIF    := 0


   ITEN_FAT->(dbsetorder(2))
   ITEN_FAT->(dbseek(FAT->Codigo))
   IT_CLASS->(dbsetorder(2))
   
   PROD->(dbsetorder(4))
   nCONT := 1
   do while ! ITEN_FAT->(eof()) .and. ITEN_FAT->Num_fat == FAT->Codigo

      PROD->(dbseek(ITEN_FAT->Cod_prod))
	  
	  nMVA := 0
	  lTemST := .F.
	  lVEnda := .F.
	  
	  if IT_CLASS->(dbseek(PROD->Cod_Class+CGM->Estado))
         nMVA := IT_CLASS->Mva
      endif
	  
      @ prow()+1,03 say "[PRODUTO"+strzero(nCONT,3)+"]"
	  if ! alltrim(FAT->Cod_cfop) $ "5915-5916-6915-6916-1916-1915-5917-5912-6912-6917"
	     lVenda := .T.   
	  endif
	  
	  if lVenda
	     if nMVA > 0 .and. CGM->Estado $ cEstados .and. ehContribuinteIcms() .and. ITEN_FAT->NFAntigast != "S" //Se tem Substituição
	        lTemST := .T.
         endif	
	  endif
      
	  if lTemST .and. left(FAT->Cod_cfop,4) $ "5102-6102"
         @ prow()+1,03 say "CFOP=" +alltrim(left(FAT->Cod_cfop,1))+"403"
	  else
         @ prow()+1,03 say "CFOP="+alltrim(FAT->Cod_cfop)
	  endif	  
	        
	  if CONFIG->Modelo_fat =="1"
         @ prow()+1,03 say "Codigo="+rtrim(PROD->cod_fabr)
      else
         @ prow()+1,03 say "Codigo="+right(PROD->codigo,5)
      endif
      if CLASSIF->(dbseek(PROD->Cod_class))
         @ prow()+1,03 say "NCM="+alltrim(i_trocachr(CLASSIF->Descricao))
		 cNCM := alltrim(i_trocachr(CLASSIF->Descricao))
      endif

      @ prow()+1,03 say "Descricao="+rtrim(PROD->Descricao)
      UNIDADE->(dbseek(PROD->Unidade))
      @ prow()+1,03 say "Unidade="+alltrim(UNIDADE->Sigla)
      @ prow()+1,03 say "Quantidade="+alltrim(transf(ITEN_FAT->Quantidade,"@R 9999999"))
      @ prow()+1,03 say "ValorUnitario="+alltrim(transf(ITEN_FAT->vl_unitar,"@R 9999999.99"))
      @ prow()+1,03 say "ValorTotal="+alltrim(transf(ITEN_FAT->Quantidade*ITEN_FAT->vl_unitar,"@R 9999999.99"))
      @ prow()+1,03 say "EAN="+alltrim(PROD->Cod_barras)
      @ prow()+1,03 say "EANTRIB="+alltrim(PROD->Cod_barras)
      @ prow()+1,03 say "xPed="+alltrim(ITEN_FAT->Ordem_Comp)
	  
	  
      
      @ prow()+1,03 say "[ICMS"+strzero(nCONT,3)+"]"
      @ prow()+1,03 say "Origem="+left(ITEN_FAT->Cod_sit,1)
	  
	  if lTemSt 
          @ prow()+1,03 say "CST=" + "10"
	  else
	      @ prow()+1,03 say "CST="+right(ITEN_FAT->Cod_sit,2)
	  endif
	  
      if CONFIG->Simples != "S"
	    
		if CGM->Estado == "PR" .and. lTemST
            @ prow()+1,03 say "Aliquota="+alltrim(transf(ITEN_FAT->Icms,"@R 99.99"))
		else
		    @ prow()+1,03 say "Aliquota="+alltrim(transf(ITEN_FAT->Icms,"@R 99.99"))
		endif  

   	     if ITEN_FAT->Icms > 0
		    
			if CGM->Estado == "PR"
			   if lTemST
			      @ prow()+1,03 say "ValorBase="+alltrim(transf(ITEN_FAT->vl_unitar*ITEN_FAT->Quantidade,"@R 9999999.999"))
	              @ prow()+1,03 say "Valor="+alltrim(transf((ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade)*(ITEN_FAT->Icms/100),"@R 9999999.999"))
			      nIcmsItem := ((ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade)*(ITEN_FAT->Icms / 100) )
			      nICMS        += ((ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade)*(ITEN_FAT->Icms / 100))
				  nBASE_ICMS   += (ITEN_FAT->Quantidade * ITEN_FAT->Vl_unitar)
			   else
			      if ehContribuinteIcms()
				     nIcmsItem :=  ((ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade)*(ITEN_FAT->Icms/100) ) * 0.66666
				     nICMS        += (nIcmsItem)
					 nBASE_ICMS   += ( (ITEN_FAT->Quantidade * ITEN_FAT->Vl_unitar) * 0.66666 )
					 nICMS_DIF += ((ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade)*(ITEN_FAT->Icms/100) ) * 0.33333
				     
                     @ prow()+1,03 say "PercentualReducao="+alltrim(transf(33.33,"@R 9999999.999"))   					 
					 @ prow()+1,03 say "ValorBase="+alltrim(transf((ITEN_FAT->vl_unitar*ITEN_FAT->Quantidade)*0.66666,"@R 9999999.999"))
			         @ prow()+1,03 say "Valor="+alltrim(transf(nIcmsItem,"@R 9999999.99"))
			      else
				     @ prow()+1,03 say "ValorBase="+alltrim(transf(ITEN_FAT->vl_unitar*ITEN_FAT->Quantidade,"@R 9999999.999"))
				     @ prow()+1,03 say "Valor="+alltrim(transf((ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade)*(ITEN_FAT->Icms/100),"@R 9999999.999"))
			         nIcmsItem := (ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade)*(ITEN_FAT->Icms/100)
			         nICMS        += ((ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade)*(ITEN_FAT->Icms/100)) 
					 nBASE_ICMS   += (ITEN_FAT->Quantidade * ITEN_FAT->Vl_unitar)
                  endif				  
			   endif  
			else
			   @ prow()+1,03 say "ValorBase="+alltrim(transf(ITEN_FAT->vl_unitar*ITEN_FAT->Quantidade,"@R 9999999.999"))
               @ prow()+1,03 say "Valor="+alltrim(transf((ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade)*(ITEN_FAT->Icms/100),"@R 9999999.999"))
			   nIcmsItem := (ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade)*(ITEN_FAT->Icms/100)
			   nICMS        += ((ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade)*(ITEN_FAT->Icms/100))
			   nBASE_ICMS   += (ITEN_FAT->Quantidade * ITEN_FAT->Vl_unitar)
            endif			
		 endif
		 
		 if lTemST
		    @ prow()+1,03 say "ValorBaseST="+alltrim(transf( i_calcBaseST(nMva,cNCM),"@R 9999999.999"))
    	    @ prow()+1,03 say "AliquotaST="+alltrim(transf(18.00,"@R 99.99"))
		    @ prow()+1,03 say "ValorST="+alltrim(transf( i_calcValorST(i_calcBaseST(nMva,cNCM)) - nIcmsItem,"@R 9999999.999"))
			nBASE_ST += i_calcBaseSt(nMva,cNCM)
			nST      += i_calcValorSt(i_calcBaseST(nMva,cNCM)) - nIcmsItem
		 endif
		 
		 if ITEN_FAT->icms > 0 
            @ prow()+1,03 say "[IPI"+strzero(nCONT,3)+"]"
            @ prow()+1,03 say "CST="+ITEN_FAT->Cod_sit

            @ prow()+1,03 say "ValorBase="+alltrim(transf(ITEN_FAT->vl_unitar*ITEN_FAT->Quantidade,"@R 9999999.999"))
            @ prow()+1,03 say "Aliquota="+alltrim(transf(ITEN_FAT->IPI,"@R 99.99"))
            @ prow()+1,03 say "Valor="+alltrim(transf((ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade)*(ITEN_FAT->Ipi/100),"@R 9999999.999"))
		 else
            @ prow()+1,03 say "[IPI"+strzero(nCONT,3)+"]"
            @ prow()+1,03 say "CST="+ITEN_FAT->Cod_sit

            @ prow()+1,03 say "ValorBase="+alltrim(transf(ITEN_FAT->vl_unitar*ITEN_FAT->Quantidade,"@R 9999999.999"))
            @ prow()+1,03 say "Aliquota="+alltrim(transf(0,"@R 99.99"))
            @ prow()+1,03 say "Valor="+alltrim(transf(0,"@R 9999999.99"))
         endif		 
	  else 
	      if (CONFIG->Sol == "S" .or. CONFIG->Plaforte == "S") .and. CLI1->Final != "S"
		  
		    if CONFIG->Sol == "S" 
               @ prow()+1,03 say "ValorBaseST="+alltrim(transf( (ITEN_FAT->Vl_unitar*ITEN_FAT->Quantidade) * 2.4,"@R 9999999.99"))
    	       @ prow()+1,03 say "AliquotaST="+alltrim(transf(ITEN_FAT->Icms,"@R 99.99"))
               @ prow()+1,03 say "ValorST="+alltrim(transf( ((ITEN_FAT->vl_unitar * ITEN_FAT->Quantidade * 2.4) - (ITEN_FAT->vl_unitar * ITEN_FAT->Quantidade) )*(ITEN_FAT->Icms/100),"@R 9999999.99"))
			endif   
			
			if CONFIG->Plaforte == "S" .and. cNCM $ "90191000-39221000"
			
			   nMVA := AliqMVA(cNCM,left(FAT->Cod_Cfop,1))
			   alert(transf(nMVA,"@R 99999999.99"))
			  
               //@ prow()+1,03 say "ValorBase="+alltrim(transf(ITEN_FAT->vl_unitar*ITEN_FAT->Quantidade,"@R 9999999.99"))
			   //@ prow()+1,03 say "Aliquota="+alltrim(transf(18.00,"@R 99.99"))
	           //@ prow()+1,03 say "Valor="+alltrim(transf((ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade)*0.18,"@R 9999999.99"))
               @ prow()+1,03 say "ValorBaseST="+alltrim(transf( (ITEN_FAT->Vl_unitar*ITEN_FAT->Quantidade) * nMVA,"@R 9999999.99"))
    	       @ prow()+1,03 say "AliquotaST="+alltrim(transf(18.00,"@R 99.99"))
               @ prow()+1,03 say "ValorST="+alltrim(transf( ((ITEN_FAT->vl_unitar * ITEN_FAT->Quantidade * nMVA) - (ITEN_FAT->vl_unitar * ITEN_FAT->Quantidade) ) *  0.18,"@R 9999999.99"))
			   nBASE_PLAFORTE += ((ITEN_FAT->Vl_unitar*ITEN_FAT->Quantidade) * nMVA )
			   nST_PLAFORTE   += (((ITEN_FAT->vl_unitar * ITEN_FAT->Quantidade * nMVA) - (ITEN_FAT->vl_unitar * ITEN_FAT->Quantidade) ) * 0.18 )
			endif
			
			
		 endif  
      endif

      nBASE_IPI    += (ITEN_FAT->Quantidade * ITEN_FAT->Vl_unitar)
      nBASE_ICMSST += (ITEN_FAT->Quantidade * ITEN_FAT->Bc_subst)
      //nICMS        += ((ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade)*(ITEN_FAT->Icms/100))
      nALIQ_ICMS  := ITEN_FAT->Icms

      if ITEN_FAT->Icms > 0
         //nBASE_ICMS   += (ITEN_FAT->Quantidade * ITEN_FAT->Vl_unitar)
		 if CONFIG->Sol != "S"
            nIPI         += round(((ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade)*(ITEN_FAT->Ipi/100)),2)
		 endif	
      endif

      //nICMSST      += ((ITEN_FAT->Bc_subst * ITEN_FAT->Quantidade)*(ITEN_FAT->Icms/100))

      //if ITEN_FAT->Bc_subst > 0
      //   aadd(aST,{ITEN_FAT->Cod_prod,(ITEN_FAT->Quantidade*ITEN_FAT->BC_subst),((ITEN_FAT->Quantidade*ITEN_FAT->Bc_subst) * (ITEN_FAT->Icms /100)),((ITEN_FAT->Quantidade * ITEN_FAT->Vl_unitar) * ( ITEN_FAT->Icms / 100 ))})
      //endif

      //ValorBase=
      //Aliquota=
      //Valor=
      //ModalidadeST=
      //PercentualMargemST
      //PercentualReducaoST
      //ValorBaseST=
      //AliquotaST=
      //ValorST=
      //PercentualReducao=

      nTotal += (ITEN_FAT->Quantidade * ITEN_FAT->Vl_unitar) 

      nCONT++
      ITEN_FAT->(dbskip())
   enddo

   nValorSt := nICMSST - nICMS
   if nValorSt < 0
      nValorSt := 0
   endif

   @ prow()+1, 03 say "[Total]"
   if CONFIG->simples != "S"

      //if left(FAT->Cod_cfop,1) $ "1-5" .and. CLI1->Isento == "S"
      //   nICMS_DIF := (nICMS*0.3333)
      //   nICMS := nICMS-(nICMS*0.3333)
//		 nBase_Icms := nBase_Icms - (nBase_icms * 0.3333)
 //     endif

      @ prow()+1, 03 say "BaseICMS="+alltrim(transf(nBase_Icms,"@R 9999999.999"))
      @ prow()+1, 03 say "ValorICMS="+alltrim(transf(nIcms,"@R 9999999.999"))
      @ prow()+1, 03 say "ValorIPI="+alltrim(transf(nIpi,"@R 9999999.999"))
      @ prow()+1, 03 say "BaseIcmsSubstituicao="+alltrim(transf(nBASE_ST,"@R 9999999.999"))
      @ prow()+1, 03 say "ValorIcmsSubstituicao="+alltrim(transf(nST,"@R 9999999.999"))
   endif

   if CONFIG->SOL == "S"
      if CLI1->Final != "S"
         nBASE_ICMSST := nBASE_ICMS * 2.4
         nVAlorSt     := (nBASE_ICMSST*(nAliq_Icms/100))-(nBase_Icms*(nAliq_Icms/100))

         @ prow()+1, 03 say "BaseIcmsSubstituicao="+alltrim(transf(nBASE_ICMSST,"@R 9999999.99"))
         @ prow()+1, 03 say "ValorIcmsSubstituicao="+alltrim(transf(nValorSt,"@R 9999999.99"))
      endif
   endif
   
   if CONFIG->Plaforte == "S"
      if CLI1->Final != "S"
	     //@ prow()+1, 03 say "BaseICMS="+alltrim(transf(nBase_Icms,"@R 9999999.99"))
         //@ prow()+1, 03 say "ValorICMS="+alltrim(transf(nIcms,"@R 9999999.99"))
         @ prow()+1, 03 say "BaseIcmsSubstituicao="+alltrim(transf(nBASE_PLAFORTE,"@R 9999999.99"))
         @ prow()+1, 03 say "ValorIcmsSubstituicao="+alltrim(transf(nST_PLAFORTE,"@R 9999999.99"))
		 nST := nST_PLAFORTE
      endif
   endif

   @ prow()+1, 03 say "ValorProduto="+alltrim(transf(nTotal,"@R 9999999.999"))
   @ prow()+1, 03 say "ValorNota="+alltrim(transf(round(nTotal,2)+round(nST,2)+round(nIPI,2),"@R 9999999.999"))

   TRANSP->(dbseek(FAT->Cod_transp))

   @ prow()+1, 03 say "[Transportador]"
   @ prow()+1, 03 say "FretePorConta="+strzero(val(FAT->Frete)-1,1)
   @ prow()+1, 03 say "CnpjCpf="+alltrim(i_trocachr(TRANSP->cgccpf))
  @ prow()+1, 03 say "IE="+alltrim(i_trocachr(TRANSP->Inscricao))
   @ prow()+1, 03 say "NomeRazao="+rtrim(i_trocachr(TRANSP->Razao))
   @ prow()+1, 03 say "Endereco="+rtrim(i_trocachr(TRANSP->Endereco))
   CGM->(dbseek(TRANSP->Cgm))
//  @ prow()+1 ,03 say "CidadeCod="+BuscaMunicipio(CGM->Cod_rais,CGM->Municipio)
   @ prow()+1, 03 say "Cidade="+rtrim(CGM->Municipio)
   @ prow()+1, 03 say "UF="+CGM->Estado
   if ! empty(FAT->Cod_transp)
       if ! empty(TRANSP->Placa)
          @ prow()+1, 03 say "Placa="+alltrim(i_trocachr(TRANSP->Placa))
          @ prow()+1, 03 say "UFPlaca="+CGM->Estado
       endif      
   endif    

   @ prow()+1, 03 say "[volume001]"
   @ prow()+1, 03 say "Quantidade="+alltrim(transf(FAT->Qtde_vol,"@R 999999"))
   @ prow()+1, 03 say "Especie="+FAT->Especie
   @ prow()+1, 03 say "Marca="+FAT->Marca
   @ prow()+1, 03 say "Numeracao="+FAT->Numero
   @ prow()+1, 03 say "PesoBruto="+alltrim(transf(FAT->Peso_bruto,"@R 999999.99"))
   @ prow()+1, 03 say "PesoLiquido="+alltrim(transf(FAT->Peso_liqui,"@R 999999.99"))

   nCONT := 1

   if DUP_FAT->(dbseek(FAT->Codigo+"01"))
      do while left(DUP_FAT->Num_fat,5) == FAT->Codigo .and. ! DUP_FAT->(eof())
         @ prow()+1, 03 say "[Duplicata"+strzero(nCONT,3)+"]"
         @ prow()+1, 03 say "Numero="+FAT->Num_fatura + "/"+right(DUP_FAT->Num_fat,2)
         @ prow()+1, 03 say "Datavencimento="+dtoc(date()+DUP_FAT->Dias)
         @ prow()+1, 03 say "Valor="+alltrim(transf(DUP_FAT->Valor,"@R 9999999.999"))
         nCONT++
         DUP_FAT->(dbskip())
      enddo
   endif
   
   if nST > 0 .and. left(FAT->Cod_cfop,1) $ "5-6-7" .and. CONFIG->Modelo_fat == "1"
         @ prow()+1, 03 say "[Duplicata"+strzero(nCONT,3)+"]"
         @ prow()+1, 03 say "Numero="+FAT->Num_fatura + "/ST"
         @ prow()+1, 03 say "Datavencimento="+dtoc( date() + 15 )
         @ prow()+1, 03 say "Valor="+alltrim(transf(nST,"@R 9999999.999"))
   endif

   @ prow()+1, 03 say "[DadosAdicionais]"

   if CONFIG->Simples == "S"
      @ prow()+1, 03     say "Complemento=Empresa optante pelo Simples Nacional Cfe. Lei 123/2006."
      @ prow()  , pcol() say ";Nao gera direito a credito do ICMS."
      @ prow()  , pcol() say ";"+left(FAT->Obs,50)
      if ! empty(substr(FAT->Obs,51,50))
         @ prow()  , pcol() say ";"+substr(FAT->Obs,51,50)
      endif

      if ! empty(substr(FAT->Obs,101,50))
         @ prow()  ,pcol()  say ";"+substr(FAT->Obs,101,50)
      endif

      if ! empty(substr(FAT->Obs,151,50))
         @ prow()  , pcol() say ";"+substr(FAT->Obs,151,50)
      endif
   else
      @ prow()+1, 03 say "Complemento="+rtrim(left(FAT->Obs,50))

      if ! empty(substr(FAT->Obs,51,50))
        // nInfAdic++
        // @ prow()+1, 03 say "[InfAdic"+strzero(nInfAdic,3)+"]"
         @ prow(), pcol() say ";"+rtrim(substr(FAT->Obs,51,50))
      endif

      if ! empty(substr(FAT->Obs,101,50))
        // nInfAdic++
        // @ prow()+1, 03 say "[InfAdic"+strzero(nInfAdic,3)+"]"
         @ prow(), pcol() say ";"+substr(FAT->Obs,101,50)
      endif

      if ! empty(substr(FAT->Obs,151,50))
        // nInfAdic++
        // @ prow()+1, 03 say "[InfAdic"+strzero(nInfAdic,3)+"]"
         @ prow(), pcol() say ";"+substr(FAT->Obs,151,50)
      endif

      if CONFIG->Modelo_Fat == "1"
         if left(FAT->Cod_cfop,1) $ "1-5" .and. nIcms_DIF > 0 .and. CLI1->Isento == "S"
            //nInfAdic++
            //@ prow()+1, 03    say "[InfAdic"+strzero(nInfAdic,3)+"]"
            @ prow()    ,pcol() say ";ICMS Diferido Conf. Art. 87-A do RICMS - Decreto No. 5141/01."

           //nInfAdic++
           //@ prow()+1, 03 say "[InfAdic"+strzero(nInfAdic,3)+"]"
           @ prow()  ,pcol() say ";Valor do Icms Diferido.: "+alltrim(transf(nICMS_DIF,"@R 999999.99"))
         endif

         if ! empty(CLI1->msg_recife)
            @ prow()  ,pcol() say ";Contribuinte credenciado para nao-antecipacao de ICMS"
            @ prow()  ,pcol() say ";Edital DPC No. 004/2010 - RE ST"
         endif
		 
		 if ! empty(CLI1->msg_sc)
            @ prow()  ,pcol() say ";Icms Substituicao Tributaria. Destinatario responsavel pelo"
            @ prow()  ,pcol() say ";recolhimento do ICMS-ST. Art. 20 paragrafo 4o. do Anexo 3."
			@ prow()  ,pcol() say ";TDD No. 115000000986815"
			@ prow()  ,pcol() say ";Processo No. SEF 21180/2011"
			@ prow()  ,pcol() say ";Prazo de Vigencia 09/2011 a 09/2013"
         endif
      endif

   endif

//   if len(aST) > 0 .and. CLI1->Final != "S"
//      @ prow(), pcol() say ";Base de Calculo da Substituicao Tributaria Conf. NPF 020/2010."
//
//      for nCONT := 1  to len(aST)
//          PROD->(dbseek(aST[nCONT,1]))
//          @ prow(),pcol() say ";"+left(PROD->Descricao,45) + " " + padr(alltrim(transform(aST[nCONT,2],"@R 999999.99")) +" "+alltrim(transform(aST[nCONT,3]-aST[nCONT,4],"@R 999999.99")),18)
//      next
//
//   endif

   @ prow()+1, 03 say ",0,1)"

   nCONT := 1

   set printer to
   set device to screen

   readFile(XDRV_NFE+"SAI.TXT","ENVIAR")

   if ! empty(FAT->NFe) .and. FAT->Status == "100"
        if FAT->(qrlock())
		   replace FAT->St with nST
		   replace FAT->BaseSt with nBase_ST
		   FAT->(qunlock())
        endif		   
		   

      if FAT->Es == "S"
         imprimirDanfe("ENT.TXT")
         imprimirDanfePdf("ENT.TXT")

         if CONFIG->Modelo_fat == "1"
            //blat()
			if TRANSP->(dbseek(FAT->cod_transp))
	           if ! empty(TRANSP->Email)
			      //blatTransp()
			   endif	  
			endif
         endif

      endif

   endif

//   if FAT->Status == "105"
//      if file(XDRV_NFE+"logs\"+getNFe()+qdigNFe(getNFe())+"-NFe.xml")
//         if FAT->(qrlock())
//            replace FAT->NFe with getNFe() + qdigNFe(getNFe())
//            replace FAT->Modelo with "55"
//            FAT->(qunlock())
//            FAT->(dbcommit())
//         endif
//       endif
//   endif



return

static function BuildNFe()
local oNfe, oStatus, oValida, oConsulta, oCancela,;
      oNF, ;
      aRetorno, cRetorno, nI, cCaminho, oFuncoes := hbNFeFuncoes(),;
      nOption, SW_SHOWNORMAL := 1,;
      hIniData, cPastaSchemas, cSerialCert, cUFWS, tpAmb, versaoDados, cUF, ;
      tpImp, versaoSistema, cXMLFileAssinado, idLote, tpEmis, nRecibo, cChaveNFe,;
      xUF, CNPJ, cXMLFileSemAssinatura, cChaveNfeCanc, nProtCanc, xJustificativa
      
   hIniData := HB_ReadIni( "nfe.ini" )
   cPastaSchemas=hIniData['Principais']['cPastaSchemas']
   cSerialCert=hIniData['Principais']['cSerialCert']
   cUFWS=hIniData['Principais']['cUFWS']
   tpAmb=hIniData['Principais']['tpAmb']
   tpImp=hIniData['Principais']['tpImp']
   versaoDados=hIniData['Principais']['versaoDados']
   cUF=hIniData['Principais']['cUF']
   versaoSistema=hIniData['Principais']['versaoSistema']

   oNfe := hbNfe()
   oNfe:cPastaSchemas := cPastaSchemas
   oNFe:cSerialCert := cSerialCert
   oNFe:nSOAP := HBNFE_MXML
   oNFe:cUFWS := cUFWS // UF WebService
   oNFe:tpAmb := tpAmb // Tipo de Ambiente
   oNFe:versaoDados := versaoDados // Versao
   oNFe:versaoDadosCCe := '1.00'
   oNFe:tpEmis := tpEmis //normal/scan/dpec/fs/fsda
   oNFe:empresa_UF := cUF
   oNFe:empresa_cMun := "4190206"
   oNFe:empresa_tpImp := tpImp
   oNFe:versaoSistema := versaoSistema
   oNFe:pastaNFe := "nfe\autorizadas"
   oNFe:pastaCancelamento := "nfe\canceladas"
   oNFe:pastaPDF := "nfe\autorizadas"
   oNFe:pastaInutilizacao := "nfe\inutilizadas"
   oNFe:pastaDPEC := "nfe\dpec"
   oNFe:pastaEnvRes := "nfe\envresp"
   oNFe:cEmailEmitente := "contato@mantraco.com.br"
   oNFe:cSiteEmitente := "www.mantraco.com.br"
   oNFe:cDesenvolvedor := "Borio Sistemas Ltda"
   oNFe:cCertPFX := hIniData['Principais']['cCertPFX']
   oNFe:cCertFilePub := hIniData['Principais']['cCertFilePub']
   oNFe:cCertFileKey := hIniData['Principais']['cCertFileKey']
   oNFe:cCertPass := hIniData['Principais']['cCertPass']

return oNFe

static function consultaStatus(oNFe)
local cRetorno := ""
        oStatus := hbNFeStatus()
        oStatus:ohbNFe := oNfe       // Objeto hbNFe
        oStatus:tpAmb  := oNfe:getTpAmb()
        oStatus:cUF    := "41"
        aRetorno := oStatus:execute()
        oStatus := Nil

        IF aRetorno['OK'] == .F.
            cretorno := aRetorno['MsgErro']
        ELSE
            cRetorno := aRetorno['tpAmb']+";"
            cRetorno += aRetorno['verAplic']+";"
            cRetorno += aRetorno['cStat']+";"
            cRetorno += aRetorno['xMotivo']+";"
            cRetorno += aRetorno['cUF']+";"
            cRetorno += aRetorno['dhRecbto']+";"
            cRetorno += aRetorno['tMed']
        ENDIF
		
		oNFe := Nil

return cRetorno

static function consultaNFe(oNFe,cXml)
local cRetorno := ""
local eol := +chr(13) + chr(10)
local nFile := 0

        oConsulta := hbNFeConsulta()
        oConsulta:ohbNFe    := oNfe // Objeto hbNFe
        //oConsulta:cChaveNFe := cChave // Chave ou pode ser um arquivo xml com o parametro cNFeFile
		oConsulta:cNFeFile := cXml
        aRetorno := oConsulta:execute()
        oConsulta := Nil

        IF aRetorno['OK'] == .F.
           cRetorno :=  aRetorno['MsgErro']
        ELSE
           cRetorno := aRetorno['tpAmb'] + eol
           cRetorno += aRetorno['verAplic']+ eol
           cRetorno += aRetorno['dhRecbto']+ eol
           cRetorno += aRetorno['nProt']+ eol
           cRetorno += aRetorno['digVal']+ eol
           cRetorno += aRetorno['cStat']+ eol
           cRetorno += aRetorno['xMotivo']+ eol
           cRetorno += aRetorno['protNFe']
        ENDIF
		
		nFile := fCreate("c:\qsystxt\log.txt",0)
		fwrite(nFile,cRetorno,len(cRetorno))
		fclose(nFile)
		
		oNFe := Nil

return aRetorno

static function cancelouNFeOld(oNFe,cXml)
local cRetorno := ""
local eol := +chr(13) + chr(10)
local nFile := 0
local cStats := ""
local cMotivo := ""

        oCancela := hbNFeCancela()
        oCancela:ohbNFe := oNfe // Objeto hbNFe
        oCancela:cNFeFile := cXml
        oCancela:cJustificativa := "Cancelamneto de Nota Fiscal"
        aRetorno := oCancela:execute()
        oCancela := Nil

        IF aRetorno['OK'] == .F.
           cRetorno := aRetorno['MsgErro']
		   alert(cRetorno)
		   return .f.
        ELSE
           cRetorno := aRetorno['tpAmb']+ eol
           cRetorno += aRetorno['verAplic']+ eol
           cRetorno += aRetorno['cStat']+ eol
           cRetorno += aRetorno['xMotivo']+ eol
           cRetorno += aRetorno['cUF']+ eol
           cRetorno += aRetorno['chNFe']+ eol
           cRetorno += aRetorno['dhRecbto']+ eol
           cRetorno += aRetorno['nProt']+ eol
           cRetorno += aRetorno['retCancNFe']+ eol
		   cStats :=  aRetorno['cStat']
		   cMotivo :=  aRetorno['xMotivo']
		   if cStats == "101"
		      alert("Cancelamento Homologado com sucesso;"+aRetorno['chNFe'])
		      return .T.
		   else 
              alert("Cancelamento Nao Homologado;"+cstats+";"+cMotivo) 		   
              return .F.
           endif		   
		   
        ENDIF
		
		nFile := fCreate("c:\qsystxt\log.txt",0)
		fwrite(nFile,cRetorno,len(cRetorno))
		fclose(nFile)
		
		oNFe := Nil

return .f.

static function cancelouNFe(oNFe,cChave)
local cRetorno := ""
local eol := +chr(13) + chr(10)
local nFile := 0
local cStats := ""
local cMotivo := ""
local oEventoCancela
local cXml := ""
local aRetorno := {}
local nProtocolo := ""

        cXml := ""
		cXml := CONFIG->Unidade+":\Qsys_g\Qfa_cl\Nfe\Autorizadas\"+FAT->NFe+"-NFe.xml"
		 
		aRetorno := consultaNFe(oNfe,cXml)
		nProtocolo := aRetorno['nProt']
		
		oEventoCancela := hbNFeEvento()
        oEventoCancela:ohbNFe := oNfe // Objeto hbNFe
        oEventoCancela:cChaveNFe := cChave
		oEventoCancela:versaoDados:= "1.00"
		oEventoCancela:cUF   := "41"
		oEventoCancela:cCnpj := FILIAL->cgccpf
		oEventoCancela:cIDevento := "110111"
		oEventoCancela:dDataEvento := date()
		oEventoCancela:cHoraEvento := time()
		oEventoCancela:cUTC        := "-03:00"
		oEventoCancela:nTipoEvento := _EVENTO
		oEventoCancela:cTIPevento := "Cancelamento"
		
		oEventoCancela:AddEvento()
        oEventoCancela:Evento[oEventoCancela:nEvento]:nSeqEvento  := '1'
        oEventoCancela:Evento[oEventoCancela:nEvento]:cJustifica   := 'Cancelamento de Nota Fiscal.'
        oEventoCancela:Evento[oEventoCancela:nEvento]:nProt        := nProtocolo
		
        aRetorno := oEventoCancela:execute()
        oEventoCancela := Nil

        IF aRetorno['OK'] == .F.
           cRetorno := aRetorno['MsgErro']
		   alert(cRetorno)
		   return .f.
        ELSE
		   cStats   :=  aRetorno['cStat']
		   cMotivo  :=  aRetorno['xMotivo']
		   	   
		   alert(cStats+";"+cMotivo);
		   
		   cStats   :=  aRetorno['cStat_1']
		   cMotivo  :=  aRetorno['xMotivo_1']
		   
		   //alert(cStats+";"+cMotivo);
		   
		   if cStats == "135"
		      alert(cStats+";"+cMotivo)
		      return .T.
		   else 
              alert(cStats+";"+cMotivo)	   
              return .F.
           endif		   
		   
        ENDIF
		
		oNFe := Nil

return .f.

static function ehContribuinteIcms
local lResult := .F.

   if ! empty(CLI1->Inscricao) .and. left(upper(CLI1->Inscricao),5) != "ISENT" .and. CONFIG->Modelo_fat == "1" .and. CLI1->Isento == "S"
  	  lResult := .T.
   endif

return lResult 

static function i_calcBaseSt(nIVA,cNCM)
  local nBase := 0 
  nBase := ITEN_FAT->Quantidade * ITEN_FAT->Vl_unitar 
  
  if ITEN_FAT->OldSt == "S"  
  
     if left(cNCM,6) $ "940590-940520"
	    nIVA := 49.17 
	 endif
	 
	 if left(cNCM,6) $ "940510"
	    nIVA := 44.88 
	 endif
	 
	 
     nBase += (nBase * (nIVA/100) )
	 
     if ITEN_FAT->Icms > 0
        nBase += ( (ITEN_FAT->Quantidade * ITEN_FAT->Vl_unitar) * (ITEN_FAT->Ipi/100) )
     endif	
  else  
  	 if ITEN_FAT->Icms > 0
        nBase += ( (ITEN_FAT->Quantidade * ITEN_FAT->Vl_unitar) * (ITEN_FAT->Ipi/100) )
     endif	
  
     nBase += (nBase * (nIVA/100) )
  endif	 

return nBase

static function i_calcValorSt(nBase)
  local nValor := 0 
  
  nValor := nBase * 0.18
  
return nValor