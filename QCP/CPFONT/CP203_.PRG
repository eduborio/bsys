/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE COMPRAS
// OBJETIVO...: LANCAMENTO de PEDIDO (CHINA) - MANTRACO
// ANALISTA...: EDUARDO BORIO
// PROGRAMADOR: EDUARDO BORIO
// INICIO.....: NOVEBRO DE 2007
// OBS........:
// ALTERACOES.:

function cp203

#include "inkey.ch"
#Define TAB chr(9)
#Define K_MAX_LIN 56

PROD->(dbsetorder(4))
quse(XDRV_CL,"CONFIG",NIL,NIL,"FATCFG")

/////////////////////////////////////////////////////////////////////////////
// MANUTENCAO DE COTACOES __________________________________________________

INVOICE->(qview({{"left(Codigo,5)/C¢digo",1},;
                  {"Data_ped/Data"                       ,2},;
                  {"i_203desc_forn()/Fornecedor"         ,3},;
                  {"left(Invoice,11)/No. Invoice"                ,0},;
                  {"Dt_chegada/Data Entrega"            ,0}},"P",;
                  {NIL,"i_203b",NIL,NIL},;
                   NIL,q_msg_acesso_usr()+"/Im<P>rimir/ <G>erar NF e Estoque"))
return
FATCFG->(DbCloseArea())


function i_203desc_forn
local cRAZAO

   if FORN->(dbseek(INVOICE->Cod_forn))
      cRAZAO := left(FORN->RAZAO,25)
   else
      cRAZAO := ""
   endif



return cRAZAO

//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO _____________________________________

function i_203b

   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO == "R"
      qlbloc(5,0,"B203C","QBLOC.GLO",1)
      i_mostra()
      i_chegada()
   endif

   iif(cOPCAO=="P",i_imprime() ,nil)
   iif(cOPCAO=="G",i_enviar() ,nil)

   if cOPCAO $ XUSRA
      qlbloc(5,0,"B203A","QBLOC.GLO",1)
      qmensa(qabrev(cOPCAO,"IA",{"Inclus„o... <ESC - Cancela>","Altera‡„o... <ESC - Cancela>"}))
      i_edicao()

   endif

   setcursor(nCURSOR)

return ""

//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA _________________________________________

static function i_edicao

   local lCONF
   local aEDICAO := {}
   local bESCAPE := {||empty(fDATA_PED).or.(XNIVEL==2.and.!XFLAG).or.!empty(fDATA_PED).and.Lastkey()==27.or.;
                       (XNIVEL==2.and.lastkey()==27)}

// MONTA DADOS NA TELA ___________________________________________________________

   if cOPCAO <> "I"

      XNIVEL := 1

      qsay ( 06,20 , INVOICE->Codigo,"@R 99999"   )
      qsay ( 08,20 , dtoc(INVOICE->Data_ped)      )
      qsay ( 08,62 , INVOICE->Invoice             )
      qsay ( 10,20 , INVOICE->Cod_forn            )
      qsay ( 10,28 , left(INVOICE->Fornecedor,45) )
      qsay ( 12,20 , left(INVOICE->Obs,57) )

      if cOPCAO == "C"
        i_atu_lanc()
        keyboard chr(27)
      endif

   endif

   // CONSULTA OU EXCLUSAO _______________________________________________________

   if cOPCAO == "C" ; qwait() ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO _________________________________________________

   aadd(aEDICAO,{{ || NIL                                               } ,"CODIGO"       })
   aadd(aEDICAO,{{ || qgetx(08,20,@fDATA_PED,"@D",                         )} ,"DATA"         })
   aadd(aEDICAO,{{ || qgetx(08,62,@fINVOICE,"@!",                         )} ,"INVOICE"         })
   aadd(aEDICAO,{{ || view_forn(10,20,@fCOD_FORN                       )} ,"COD_FORN"     })
   aadd(aEDICAO,{{ || qgetx(10,28,@fFORNECEDOR,"@!@S45",               )} ,"FORNECEDOR"   })
   aadd(aEDICAO,{{ || qgetx(12,20,@fOBS,"@!@S57",               )} ,"OBS"   })
   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO ____________________________________________________

   do while .T.

      qgirabarra()

      INVOICE->(qpublicfields())

      iif(cOPCAO=="I", INVOICE->(qinitfields()), INVOICE->(qcopyfields()))

      XNIVEL := 2
      XFLAG := .T.

      // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

      do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
         eval ( aEDICAO [XNIVEL,1] )
         if eval ( bESCAPE );INVOICE->(qreleasefields());return;endif
         if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
         iif ( XFLAG , XNIVEL++ , XNIVEL-- )
         qmensa("")
      enddo

      if ! lCONF ; return ; endif

      // AQUI INCREMENTA CODIGO DO TOMA_PRE ___________________________________

      if cOPCAO == "I" .and. CONFIG->(qrlock())
         replace CONFIG->cod_inv with CONFIG->cod_inv + 1
         fCODIGO := strzero(CONFIG->cod_inv,5)
         qsay( 06,20 ,  transform(fCODIGO,"@R 99999")  )
         qmensa("C¢digo Gerado: "+transform(fCODIGO,"@R 99999"),"B")
      endif

      if INVOICE->(iif(cOPCAO=="I",qappend(),qrlock()))

         // AGORA GRAVA E DESTRAVA ARQUIVO _____________________________________

         INVOICE->(qreplacefields())

      endif

      dbunlockall()

      i_aciona()
      keyboard chr(27)

   enddo

return

/////////////////////////////////////////////////////////////////////////////////
// CRITICAS NA DESCIDA __________________________________________________________

static function i_critica ( cCAMPO )

   qmensa("")

   iif ( cCAMPO == NIL , cCAMPO := "" , NIL )
   if ! XFLAG ; return .T. ; endif

   do case

      case cCAMPO == "COD_FORN"
           if ! empty(fCOD_FORN)
              qsay(10,20,fCOD_FORN:=strzero(val(fCOD_FORN),5))
              if ! FORN->(dbseek(fCOD_FORN))
                 qmensa("Fornecedor n„o Cadastrado ","B")
                 return .F.
              endif
              fFORNECEDOR := FORN->Razao
              qsay(10,28,left(fFORNECEDOR,45))
              XNIVEL+=1
           endif

   endcase

return .T.

//////////////////////////////////////////////////////////////////////////////////
// FUN€AO PARA EXCLUIR TOMA_PRE ____________________________________________________

static function i_exclusao

   if qconf("Confirma exclus„o deste PEDIDO ?")

      if INVOICE->(qrlock())

         ITEN_INV->(dbseek(INVOICE->Codigo)) // itens da cotacao

         do while ! ITEN_INV->(eof()) .and. ITEN_INV->Cod_inv == INVOICE->Codigo
            ITEN_INV->(qrlock())
            ITEN_INV->(dbdelete())
            ITEN_INV->(qunlock())
            ITEN_INV->(dbskip())
         enddo

         INVOICE->(dbdelete())
         INVOICE->(qunlock())

      else
         qm3()
      endif
   endif

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DOS PRODUTOS _______________________________

static function i_aciona

// LOOP PRINCIPAL ___________________________________________________________

setcolor("W/B")

ITEN_INV-> (qview({{"i_203codass()/Ref."                          ,0},;
                   {"i_203fabr()/Ref. 2"                        ,0},;
                   {"i_203descprod()/Descricao"                       ,0},;
                   {"transform(Quantidade,'@R 9999999')/Quantidade",0},;
                   {"transform(Valor,'@E 999,999.9999')/Valor",0},;
                   {"transform(Valor*Quantidade,'@E 99,999,999.9999')/Total",0}},;
                   "13002378S",;
                   {NIL,"f203e",NIL,NIL},;
                   {"ITEN_INV->Cod_inv == INVOICE->Codigo",{||f203top()},{||f203bot()}},;
                   "<I>nc./<A>lt./<C>on./<E>xc/<ESC> para sair"))
return ""


////////////////////////////////////////////////////////////
//FUNCAO PARA MOSTRAR DESCRICAO DE PRODUTOS _______________

function i_203descprod
local aRet := ""

  PROD->(dbsetorder(4))

  if PROD->(dbseek(ITEN_INV->Cod_prod))
     cRET := left(PROD->Descricao,18)
  endif

return cRET



function i_203fabr
local aRet := ""

  PROD->(dbsetorder(4))

  if PROD->(dbseek(ITEN_INV->Cod_prod))
     cRET := left(PROD->Cod_fabr,6)
  endif

return cRET




function i_203codass
local cRET := ""

  PROD->(dbsetorder(4))
  if PROD->(dbseek(ITEN_INV->Cod_prod))
     cRET := PROD->Cod_ass

  endif

return cRET



function i_203colecao
local cRET := ""

  PROD->(dbsetorder(4))
  if PROD->(dbseek(ITEN_INV->Cod_prod))
     cRET := left(PROD->Marca,15)

  endif
return cRET



function i_203uni
local cRET := ""

  PROD->(dbsetorder(4))
  if PROD->(dbseek(ITEN_INV->Cod_prod))
     UNIDADE->(dbseek(PROD->Unidade))
     cRET := UNIDADE->Sigla

  endif
return cRET






/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IR PARA O INICIO DOS DADOS FILTRADOS _________________________

function f203top
   ITEN_INV->(dbsetorder(1))
   ITEN_INV->(dbseek(INVOICE->Codigo))
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IR PARA O FINAL DOS DADOS FILTRADOS __________________________

function f203bot
   ITEN_INV->(dbsetorder(1))
   ITEN_INV->(qseekn(INVOICE->Codigo))
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO DE CONTROLE PRINCIPAL ANTES DE PROCESSAR A TECLA ACIONADA _________

function f203e

   local nCURSOR := setcursor(1)
   parameters cOPCAO

   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO $ XUSRA
      qlbloc(10,10,"B203B","QBLOC.GLO",1)
      i_faz_acao()
   endif

   setcursor(nCURSOR)

return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO DE BROWSE _________________________________________________________

static function i_faz_acao

   local lCONF
   local aEDICAO := {}
   local bESCAPE := {||(XNIVEL==1.and.!XFLAG).or.;
                       (XNIVEL==1.and.lastkey()==27).or.;
                       (XNIVEL==2.and.cOPCAO=="A".and.!XFLAG)}

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"

      XNIVEL := 1
      qrsay ( XNIVEL++ , ITEN_INV->Cod_prod                      ) ; PROD->(dbseek(ITEN_INV->Cod_prod))
      qrsay ( XNIVEL++ , left(PROD->Descricao,20)                )
      qrsay ( XNIVEL++ , left(PROD->Marca,25)                )
      qrsay ( XNIVEL++ , left(PROD->Cod_ass,7)                )
      qrsay ( XNIVEL++ , left(PROD->Cod_fabr,8)                )
      qrsay ( XNIVEL++ , transform(ITEN_INV->Quantidade,"@E 9999999")   )
      UNIDADE->(dbseek(PROD->Unidade))
      qrsay ( XNIVEL++ , transform(ITEN_INV->Valor,"@e 999,999.9999")   )
      qrsay ( XNIVEL++ , transform(ITEN_INV->Valor*ITEN_INV->Quantidade,"@e 99,999,999.9999")   )

   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exc_itens() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || view_prod(-1,0,@fCOD_PROD                    ) } ,"COD_PROD"   })
   aadd(aEDICAO,{{ || NIL                                            } ,NIL          })
   aadd(aEDICAO,{{ || NIL                                            } ,NIL          })
   aadd(aEDICAO,{{ || NIL                                            } ,NIL          })
   aadd(aEDICAO,{{ || NIL                                            } ,NIL          })


   aadd(aEDICAO,{{ || qgetx(-1,0,@fQuantidade, "9999999"           ) } ,"Quantidade"      })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fVALOR,     "@E 999,999.9999"    ) } ,"Valor"      })
   aadd(aEDICAO,{{ || NIL                                            } ,"MULT"  })
   aadd(aEDICAO,{{ || NIL                                            } ,NIL          })

   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   ITEN_INV->(qpublicfields())

   iif(cOPCAO=="I",ITEN_INV->(qinitfields()),ITEN_INV->(qcopyfields()))

   XNIVEL := 1
   XFLAG  := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; ITEN_INV->(qreleasefields()) ; return ; endif
      if ! i_crit2( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   if ! lCONF ; return ; endif

   // GRAVACAO ______________________________________________________________

   if INVOICE->(qrlock()) .and. ITEN_INV->(iif(cOPCAO=="I",qappend(),qrlock()))
      if cOPCAO == "I"
         fCOD_INV := INVOICE->Codigo
      endif

      ITEN_INV->(qreplacefields())
      ITEN_INV->(qunlock())

   else

      iif(cOPCAO=="I",qm1(),qm2())

   endif

return

/////////////////////////////////////////////////////////////////////////////
// CRITICAS NA DESCIDA ______________________________________________________

static function i_crit2 ( cCAMPO )

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

           fVALOR := PROD->Cust_dolar

           qrsay ( XNIVEL+1 , left(PROD->Descricao,30) )
           qrsay ( XNIVEL+2 , PROD->Marca )
           qrsay ( XNIVEL+3 , PROD->Cod_ass )
           qrsay ( XNIVEL+4 , left(PROD->Cod_fabr,7) )
           qrsay ( XNIVEL+6 , transform(fValor,"@e 999,999.9999") )


      case cCAMPO == "Quantidade"
           if fQuantidade <= 0 ; return .F. ; endif

      case cCAMPO == "VALOR"
           if fValor <= 0 ; return .F. ; endif


      case cCAMPO == "MULT"
           qrsay ( XNIVEL , fValor*fQuantidade,"@E 99,999,999.9999" )



   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXCLUIR ITENS DO TOMA_PREO ___________________________________

static function i_exc_itens

   if qconf("Confirma exclus„o do Item ?")

      if ITEN_INV->(qrlock())
         ITEN_INV->(dbdelete())
         ITEN_INV->(qunlock())
      else
         qm3()
      endif
   endif

return

////////////////////////////////////////////////////////////////////////////////////
static function i_atu_lanc


// LOOP PRINCIPAL ___________________________________________________________

setcolor("W/B")

ITEN_INV-> (qview({{"i_203codass()/Ref."                          ,0},;
                   {"i_203fabr()/Ref. 2"                        ,0},;
                   {"i_203descprod()/Descricao"                       ,0},;
                   {"transform(Quantidade,'@R 9999999')/Quantidade",0},;
                   {"transform(Valor,'@E 999,999.9999')/Valor",0},;
                   {"transform(Valor*Quantidade,'@E 99,999,999.9999')/Total",0}},;
                   "13002378S",;
                   {NIL,"f203e",NIL,NIL},;
                   {"ITEN_INV->Cod_inv == INVOICE->Codigo",{||f203top()},{||f203bot()}},;
                   "<I>nc./<A>lt./<C>on./<E>xc/<ESC> para sair"))


return



//static function i_chegada
//if qconf("Confirma Chegada das Mercadorias ?")
//   if INVOICE->(Qrlock())
//      replace INVOICE->Chegou with .T.
//      INVOICE->(Qunlock())
//   endif
//endif

static function i_chegada
   local lCONF
   local aEDICAO := {}
   local bESCAPE := {||(XNIVEL==1.and.!XFLAG).or.;
                       (XNIVEL==1.and.lastkey()==27)}


   // CRIACAO DO VETOR DE BLOCOS _______________________________________________

   aadd(aEDICAO,{{ || qgetx(-1,0,@fDT_CHEGADA,"@D"            )},"DT_CHEGADA" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fFRETE_USD,"@E 99,999,999.99"  )},"FRETE"  })

   aadd(aEDICAO,{{ || NIL                                      },"TOT_PROD"   })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDOLAR,    "@E 9.9999"      )},"DOLAR"      })
   aadd(aEDICAO,{{ || NIL                                      },"TOT_REAL"   })

   aadd(aEDICAO,{{ || qgetx(-1,0,@fII  , "@E 99,999,999.99"    )},"II"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@fIPI , "@E 99,999,999.99"    )},"IPI"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@fPIS , "@E 99,999,999.99"    )},"PIS"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@fCOFINS, "@E 99,999,999.99"  )},"COFINS"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@fSISCOM ,"@E 99,999,999.99"  )},"SISCOM"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDESP_ADU, "@E 99,999,999.99")},"DESP_ADU"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@fTOT_TRIB ,"@E 99,999,999.99")},"TOT_TRIB"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@fBASE    , "@E 99,999,999.99")},"BASE"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@fALIQ    , "@E 99.99")},"ALIQ"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@fIMPOSTO , "@E 99,999,999.99")},"IMPOSTO"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDIFER   , "@E 99,999,999.99")},"DIFER"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDEVIDO  , "@E 99,999,999.99")},"DEVIDO"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@fPRESUM  , "@E 99,999,999.99")},"PRESUM"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@fICMS    , "@E 99,999,999.99")},"ICMS"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDESP_ACESS , "@E 99,999,999.99")},"DESP_ACESS"})



   aadd(aEDICAO,{{ || lCONF := qconf("Confirma os Dados ?"   )},NIL})

   INVOICE->(qpublicfields())
   INVOICE->(qcopyfields())

   XNIVEL  := 1
   XFLAG   := .T.


   do while .T.

      // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

      do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
         eval ( aEDICAO [XNIVEL,1] )
         if eval ( bESCAPE ) ; INVOICE->(qreleasefields()) ;return ; endif
         if ! i_2critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
         iif ( XFLAG , XNIVEL++ , XNIVEL-- )
      enddo

      if ! lCONF ; return ; endif

      if INVOICE->(qrlock())
         INVOICE->(qreplacefields())
      endif

      if ITEN_INV->(qflock())
         rateio_itens()
      else
         qmensa("Nal foi possivel gerar o rateio por ITEM!","BL")
      endif


      INVOICE->(qunlock())
      exit

   enddo
return

/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA _____________________________________________

static function i_2critica ( cCAMPO )
local nTOTAL    := 0
local nTOT_REAL := 0
local nICM1     := 0
local nfICM2     := 0

   nTOTAL    := i_total()
   nTOT_REAL := i_real()

   do case

      case cCAMPO == "DT_CHEGADA"

           if fDT_CHEGADA < fDATA_PED
              qmensa("Data nao pode ser menor que a Data do Pedido","BL")
              return .F.
           endif
           fCHEGOU := .T.

      case cCAMPO == "DOLAR"
           nTOT_REAL := nTOTAL * fDOLAR
           qrsay(XNIVEL+1,nTOT_REAL+(fFRETE_USD * fDOLAR),"@E 99,999,999.99")
           fTTPROD_RS := nTOT_REAL


      case cCAMPO == "DESP_ADU"

           fTOT_TRIB := i_soma()

           qrsay(XNIVEL+1,fTOT_TRIB,"@E 99,999,999.99")

      case cCAMPO == "TOT_TRIB"
           fBASE := fTOT_TRIB / 0.82
           qrsay(XNIVEL+1,fBASE,"@E 99,999,999.99")

      case cCAMPO == "ALIQ"
           fIMPOSTO := fBASE * (fALIQ/100)
           qrsay(XNIVEl+1,fIMPOSTO,"@E 99,999,999.99")

      case cCAMPO == "IMPOSTO"
           fDIFER := fIMPOSTO * 0.33333
           qrsay(XNIVEl+1,fDIFER,"@E 99,999,999.99")


      case cCAMPO == "DIFER"
           fDEVIDO := fIMPOSTO - fDIFER
           qrsay(XNIVEl+1,fDEVIDO,"@E 99,999,999.99")


      case cCAMPO == "DEVIDO"
           fPRESUM := fBASE * 0.09
           qrsay(XNIVEl+1,fPRESUM,"@E 99,999,999.99")


      case cCAMPO == "PRESUM"

           nICM1 := (fDEVIDO - fPRESUM)
           nICM2 := fBASE * 0.03

           if nICM1 == nICM2
              fICMS := nICM1
           else
              if nICM1 > nICM2
                 fICMS := nICM1
              else
                 fICMS := nICM2
              endif
           endif

           qrsay(XNIVEl+1,fICMS,"@E 99,999,999.99")





   endcase
return .T.


static function i_total
local fTOTAL := 0

      ITEN_INV->(dbseek(INVOICE->Codigo)) // itens da cotacao


      while ! ITEN_INV->(Eof()) .and. ITEN_INV->Cod_inv == INVOICE->Codigo

          fTOTAL += ITEN_INV->Quantidade * ITEN_INV->Valor
          ITEN_INV->(Dbskip())
      enddo

return  fTOTAL

static function i_real
local nTOTAL := 0

      nTOTAL := i_total()*INVOICE->Dolar


return nTOTAL

static function i_total_real
local nTOTAL := 0

      nTOTAL := i_total()*INVOICE->Dolar


return nTOTAL


static function i_mostra

local fTOTAL := 0
local fTOT_REAL := 0

   nTOTAL      := i_total()
   nTOT_REAL   := i_real()+(INVOICE->Frete_usd * INVOICE->Dolar)

   XNIVEL := 1
   qrsay(XNIVEL,INVOICE->DT_CHEGADA,"@D")
   qrsay(XNIVEL+1,INVOICE->Frete_usd ,"@E 99,999,999.99" )
   qrsay(XNIVEL+2,nTOTAL     ,"@E 99,999,999.99" )
   qrsay(XNIVEL+3,INVOICE->DOLAR,    "@E 9.9999"        )
   qrsay(XNIVEL+4,nTOT_REAL ,"@E 99,999,999.99")
   qrsay(XNIVEL+5,INVOICE->II       , "@E 99,999,999.99")
   qrsay(XNIVEL+6,INVOICE->IPI      , "@E 99,999,999.99")
   qrsay(XNIVEL+7,INVOICE->PIS      , "@E 99,999,999.99")
   qrsay(XNIVEL+9,INVOICE->COFINS   , "@E 99,999,999.99")
   qrsay(XNIVEL+09,INVOICE->SISCOM   , "@E 99,999,999.99")
   qrsay(XNIVEL+10,INVOICE->DESP_ADU , "@E 99,999,999.99")
   qrsay(XNIVEL+11,INVOICE->TOT_TRIB, "@E 99,999,999.99")
   qrsay(XNIVEL+12,INVOICE->BASE    , "@E 99,999,999.99")
   qrsay(XNIVEL+13,INVOICE->ALIQ    , "@E 99.99")
   qrsay(XNIVEL+14,INVOICE->IMPOSTO , "@E 99,999,999.99")
   qrsay(XNIVEL+15,INVOICE->DIFER   , "@E 99,999,999.99")
   qrsay(XNIVEL+16,INVOICE->DEVIDO  , "@E 99,999,999.99")
   qrsay(XNIVEL+17,INVOICE->PRESUM  , "@E 99,999,999.99")
   qrsay(XNIVEL+18,INVOICE->ICMS    , "@E 99,999,999.99")
   qrsay(XNIVEL+19,INVOICE->Desp_Acess , "@E 99,999,999.99")

return


static function i_soma

local nTOT  := 0
local nReal := 0

    nREAL := (i_total()+ fFRETE_USD) * fDOLAR
    nTOT := nREAL
    nTOT += fIPI
    nTOT += fII
    nTOT += fPIS
    nTOT += fCOFINS
    nTOT += fSISCOM
    nTOT += fDESP_ADU

return nTOT

static function ipi
local nRET:= 0

nRET :=  Total_Reais()*(Rateio_Ipi()/100)

return nRET

static function Icms
local nRET:= 0

nRET := Bc_icms()*(Rateio_Icms()/100)

return nRET


static function desp_acess
local nRET:= 0

nRET := Total_Reais()*(Rateio_Despesas()/100)

return nRET

static function Bc_icms
local nRET:= 0

nRET := ( (Total_dolar() * INVOICE->Dolar) + INVOICE->Frete_real)

return nRET



static function total_reais
local nRET:= 0

nRET := Total_dolar() * INVOICE->Dolar

return nRET


static function total_dolar
local nRET:= 0

nRET := ITEN_INV->Quantidade * ITEN_INV->Valor

return nRET

static function Total_NF
local nRET := 0

nRET := Total_Reais()+Icms()

return  nRET

static function Unitario_NF
local nRET := 0

nRET := Total_NF()/ITEN_INV->Quantidade

return nRET

static function Total_Estoque
local nRET := 0

nRET := Total_Reais()+Desp_acess()

return  nRET

static function Unitario_Estoque
local nRET := 0

nRET := Total_Estoque()/ITEN_INV->Quantidade

return nRET

static function rateio_ipi
local nRET:= 0

nRET := ((INVOICE->IPI/INVOICE->TTPROD_RS)*100)


return nRET


static function rateio_icms
local nRET:= 0

nRET := ((INVOICE->Icms/INVOICE->TTPROD_RS)*100)


return nRET

static function rateio_despesas
local nRET:= 0

nRET := ((INVOICE->Desp_acess/INVOICE->TTPROD_RS)*100)


return nRET

static function rateio_itens()

    ITEN_INV->(dbseek(INVOICE->Codigo))
    do WHILE ITEN_INV->(!Eof()) .and. ITEN_INV->Cod_inv == INVOICE->Codigo

        replace ITEN_INV->Total_us   with Total_Dolar()
        replace ITEN_INV->Total_RS   with Total_Reais()
        replace ITEN_INV->Ipi        with Ipi()
        replace ITEN_INV->Icms       with Icms()
        replace ITEN_INV->Desp_acess with Desp_acess()
        replace ITEN_INV->Custo_NF   with Total_NF()
        replace ITEN_INV->VlrUni_NF  with Unitario_NF()
        replace ITEN_INV->Cust_Est   with Total_Estoque()
        replace ITEN_INV->VlrUni_Est with Unitario_Estoque()



       ITEN_INV->(dbskip())
    enddo

return

static function i_imprime

   if ! qinitprn() ; return ; endif

   if XLOCALIMP == "X"
      i_impre_xls()
   else
      if XLOCALIMP $ "A-T"
         i_impre_prn()
      endif
   endif

return

static function i_impre_prn
   local cTITULO,cTITULO2,cPROD,zPROD := ""
   local aPED  := {}
   local asPED := {}
   local lVetorNaoVazio := .F.

   cTITULO := "Comercial Invoice - No.: "+INVOICE->Codigo

   PROD->(dbsetorder(4))

   ITEN_INV->(dbseek(INVOICE->Codigo))
   Do while ! ITEN_INV->(Eof()) .and. ITEN_INV->Cod_inv == INVOICE->Codigo

      PROD->(dbseek(ITEN_INV->Cod_prod))

      aadd(aPED,{PROD->Cod_ass,ITEN_INV->Cod_prod,ITEN_INV->Quantidade,ITEN_INV->Valor,ITEN_INV->Total_us,ITEN_INV->Total_rs,ITEN_INV->Ipi,ITEN_INV->Icms,ITEN_INV->Desp_acess,ITEN_INV->Custo_NF,ITEN_INV->Vlruni_nf,ITEN_INV->Cust_est,ITEN_INV->Vlruni_est})

      lVetorNaoVazio := .T.
      ITEN_INV->(dbskip())
   enddo



   asPED := asort(aPED,,,{|x,y| x[1] < y[1] })

   if lVetorNaoVazio

       nCONT := 1
       do while  nCONT <= len(asPED)



           if XPAGINA == 0 .or. prow() > K_MAX_LIN
              @ prow(),pcol() say chr(27)+"&l1O"
              qpageprn()
              qcabecprn(cTITULO,134)
              @ prow()+1,0 say XCOND1 + "Ref1.   Ref2.  Descricao          Qty  Preco    Total em   Total em    Ipi     Icms   Desp.Acess.  Valor    Vlr.Uni      Custo     Vlr.Uni"
              @ prow()+1,0 say          "                                       Dolar      Dolar      Real                                   N.F.      N.F.      Estoque    Estoque"
              @ prow()+1,0 say replicate("-",110)
           endif

           PROD->(dbseek(asPED[nCONT,2]))
           
           @ prow()+1,00  say PROD->Cod_ass
           @ prow()  ,10  say left(PROD->Cod_fabr,6)
           @ prow()  ,20  say left(PROD->Descricao,20)
           @ prow()  ,50  say transform(asPED[nCONT,3] ,"@R 9999999")
           @ prow()  ,65  say transform(asPED[nCONT,4] ,"@E 999,999.9999")
           @ prow()  ,65  say transform(asPED[nCONT,5] ,"@E 999,999.9999")
           @ prow()  ,80  say transform(INVOICE->Dolar ,"@E 999,999.9999")
           @ prow()  ,95  say transform(asPED[nCONT,6] ,"@E 999,999.99")
           @ prow()  ,108 say transform(asPED[nCONT,7] ,"@E 999,999.99")
           @ prow()  ,120 say transform(asPED[nCONT,8] ,"@E 999,999.99")
           @ prow()  ,132 say transform(asPED[nCONT,9] ,"@E 999,999.99")
           @ prow()  ,144 say transform(asPED[nCONT,10],"@E 999,999.99")
           @ prow()  ,156 say transform(asPED[nCONT,11],"@E 999,999.99")
           @ prow()  ,170 say transform(asPED[nCONT,12],"@E 999,999.99")
           @ prow()  ,184 say transform(asPED[nCONT,13],"@E 999,999.99")


           nCONT++
           if nCONT > len(asPED)
              nCONT := len(asPED)
              exit
           endif
       enddo

   endif

   qstopprn()

return

static function i_impre_xls
   local cTITULO,cTITULO2,cPROD,zPROD := ""
   local aPED  := {}
   local asPED := {}
   local lVetorNaoVazio := .F.
   local nTTDolar := 0
   local nTTReal  := 0
   local nTTIpi   := 0
   local nTTIcms  := 0
   local nTTDesp  := 0
   local nTTNf    := 0
   local nTTEst   := 0


   cTITULO := "Comercial Invoice - No.: "+INVOICE->Codigo

   PROD->(dbsetorder(4))

   ITEN_INV->(dbseek(INVOICE->Codigo))
   Do while ! ITEN_INV->(Eof()) .and. ITEN_INV->Cod_inv == INVOICE->Codigo

      PROD->(dbseek(ITEN_INV->Cod_prod))

      aadd(aPED,{PROD->Cod_ass,ITEN_INV->Cod_prod,ITEN_INV->Quantidade,ITEN_INV->Valor,ITEN_INV->Total_us,ITEN_INV->Total_rs,ITEN_INV->Ipi,ITEN_INV->Icms,ITEN_INV->Desp_acess,ITEN_INV->Custo_NF,ITEN_INV->Vlruni_nf,ITEN_INV->Cust_est,ITEN_INV->Vlruni_est})

      lVetorNaoVazio := .T.
      ITEN_INV->(dbskip())
   enddo



   asPED := asort(aPED,,,{|x,y| x[1] < y[1] })

   if lVetorNaoVazio

       nCONT := 1
       do while  nCONT <= len(asPED)



           if XPAGINA == 0 //.or. prow() > K_MAX_LIN
              qpageprn()
              @ prow()+1,0 say TAB+TAB+cTITULO
              @ prow()+1,0 say "Ref1."+TAB+"Ref2."+TAB+"Descricao"+TAB+"Qty"+TAB+"Preco Dolar"+TAB+"Total em Dolar"+TAB+"Dolar Cambio"+TAB+"Total em Real"+TAB+"Ipi"+TAB+"Icms"+TAB+"Desp.Acess."+TAB+"Custo NF"+TAB+"Vlr.Uni NF"+TAB+"Custo Estoque"+TAB+"Vlr.Uni Estoque"
              @ prow()+1,0 say replicate(TAB,8)+transf(rateio_ipi(),"@E 99.99999")+TAB+transf(rateio_icms(),"@E 99.99999")+TAB+transf(rateio_despesas(),"@E 99.99999")
              @ prow()+1,0 say ""
           endif

           PROD->(dbseek(asPED[nCONT,2]))
           
           @ prow()+1,00  say " "+PROD->Cod_ass+" "
           @ prow()  ,pcol()  say TAB+" "+left(PROD->Cod_fabr,6)+" "
           @ prow()  ,pcol()  say TAB+left(PROD->Descricao,20)
           @ prow()  ,pcol()  say TAB+transform(asPED[nCONT,3] ,"@R 9999999")
           @ prow()  ,pcol()  say TAB+transform(asPED[nCONT,4] ,"@E 999,999.9999")
           @ prow()  ,pcol()  say TAB+transform(asPED[nCONT,5] ,"@E 999,999.9999")
           @ prow()  ,pcol()  say TAB+transform(INVOICE->Dolar ,"@E 999,999.9999")
           @ prow()  ,pcol()  say TAB+transform(asPED[nCONT,6] ,"@E 999,999.99")
           @ prow()  ,pcol()  say TAB+transform(asPED[nCONT,7] ,"@E 999,999.99")
           @ prow()  ,pcol()  say TAB+transform(asPED[nCONT,8] ,"@E 999,999.99")
           @ prow()  ,pcol()  say TAB+transform(asPED[nCONT,9] ,"@E 999,999.99")
           @ prow()  ,pcol()  say TAB+transform(asPED[nCONT,10],"@E 999,999.99")
           @ prow()  ,pcol()  say TAB+transform(asPED[nCONT,11],"@E 999,999.99")
           @ prow()  ,pcol()  say TAB+transform(asPED[nCONT,12],"@E 999,999.99")
           @ prow()  ,pcol()  say TAB+transform(asPED[nCONT,13],"@E 999,999.99")

           nTTDolar += asPED[nCONT,5]
           nTTReal  += asPED[nCONT,6]
           nTTIpi   += asPED[nCONT,7]
           nTTIcms  += asPED[nCONT,8]
           nTTDesp  += asPED[nCONT,9]
           nTTNf    += asPED[nCONT,10]
           nTTEst   += asPED[nCONT,12]


           nCONT++
           if nCONT > len(asPED)
              nCONT := len(asPED)
              exit
           endif
       enddo

   endif

   @ prow()+2,00      say ""
   @ prow()  ,pcol()  say TAB
   @ prow()  ,pcol()  say TAB
   @ prow()  ,pcol()  say TAB
   @ prow()  ,pcol()  say TAB
   @ prow()  ,pcol()  say TAB+transform(nTTDolar ,"@E 99,999,999.9999")
   @ prow()  ,pcol()  say TAB
   @ prow()  ,pcol()  say TAB+transform(nTTReal  ,"@E 99,999,999.99")
   @ prow()  ,pcol()  say TAB+transform(nTTIPI   ,"@E 99,999,999.99")
   @ prow()  ,pcol()  say TAB+transform(nTTIcms  ,"@E 99,999,999.99")
   @ prow()  ,pcol()  say TAB+transform(nTTDesp  ,"@E 99,999,999.99")
   @ prow()  ,pcol()  say TAB+transform(nTTNF    ,"@E 99,999,999.99")
   @ prow()  ,pcol()  say TAB
   @ prow()  ,pcol()  say TAB+transform(nTTEst,"@E 99,999,999.99")

   @ prow()+4,00 say TAB+TAB+"Total em Reais"+TAB+transf(INVOICE->TTProd_RS,"@E 99,999,999.99")+TAB+"Rateio % "
   @ prow()+1,00 say TAB+TAB+"Icms Informado"+TAB+transf(INVOICE->Icms,"@E 99,999,999.99")+TAB+transf(rateio_icms(),"@E 99.99999")+" %"
   @ prow()+1,00 say TAB+TAB+"IPI  Informado"+TAB+transf(INVOICE->Ipi ,"@E 99,999,999.99")+TAB+transf(rateio_ipi(),"@E 99.99999")+" %"
   @ prow()+1,00 say TAB+TAB+"Despesas Acess"+TAB+transf(INVOICE->Desp_acess,"@E 99,999,999.99")+TAB+transf(rateio_despesas(),"@E 99.99999")+" %"


   @ prow()+4,00 say TAB+TAB+"Valor Contabil"+TAB+transf(nTTNF,"@E 99,999,999.99")
   @ prow()+1,00 say TAB+TAB+"Base de Calculo Icms"+TAB+transf(INVOICE->Base,"@E 99,999,999.99")
   @ prow()+1,00 say TAB+TAB+"Valor Icms"+TAB+transf(INVOICE->Icms,"@E 99,999,999.99")
   @ prow()+1,00 say TAB+TAB+"Valor Ipi" +TAB+transf(INVOICE->Ipi ,"@E 99,999,999.99")
   @ prow()+1,00 say TAB+TAB+"Despesas Acess." +TAB+transf(INVOICE->Desp_acess,"@E 99,999,999.99")
   @ prow()+1,00 say TAB+TAB+"Valor Total da Nota" +TAB+transf(nTTNF+INVOICE->Ipi+INVOICE->Desp_acess,"@E 99,999,999.99")
   @ prow()+2,00 say TAB+TAB+"Base de Calc. IPI" +TAB+transf(INVOICE->Ipi/0.15,"@E 99,999,999.99")
   @ prow()+1,00 say TAB+TAB+"Credito Presumido Icms" +TAB+transf(INVOICE->Presum,"@E 99,999,999.99")

   qstopprn(.F.)


return

static function i_enviar
local cPEDIDO, cIMPORT, cNF := ""

if QConf("Deseja enviar para (201-Estoque) e (204-Nota Fiscal) ?","B")

   if INVOICE->Enviado
      qmensa("Invoice ja foi enviada!","BL")
      if ! Qconf("Deseja enviar novamente?","B")
         return .F.
      endif

   endif

   if CONFIG->(qrlock())
      replace CONFIG->Cod_pedido with CONFIG->Cod_pedido + 1
      cPEDIDO := strzero(CONFIG->cod_pedido,5)+left(dtos(date()),4)

      replace CONFIG->Cod_import with CONFIG->Cod_import + 1
      cIMPORT := strzero(CONFIG->cod_import,5)+left(dtos(date()),4)
      CONFIG->(qunlock())
   else
      return .F.
   endif

   PEDIDO->(qpublicfields())
   PEDIDO->(qinitfields())
   PEDIDO->(qappend())
   fCODIGO     := cPEDIDO
   fDATA_PED   := date()
   fCENTRO     := "0004"
   fFILIAL     := "0001"
   fCFOP       := "3102"
   fTIPO       := "010002"
   fCOD_FORN   := INVOICE->Cod_forn
   fCOMPRADOR  := "00001"
   fFORNECEDOR := INVOICE->Fornecedor
   fESTOQUE     := "S"
   fDESPESA     := "N"
   PEDIDO->(qreplacefields())
   PEDIDO->(qreleasefields())

   IMPORT->(qpublicfields())
   IMPORT->(qinitfields())
   IMPORT->(qappend())
   fCODIGO     := cIMPORT
   fDATA_PED   := date()
   fCENTRO     := "0004"
   fFILIAL     := "0001"
   fCFOP       := "3102"
   fTIPO       := "010002"
   fCOD_FORN   := INVOICE->Cod_forn
   fCOMPRADOR  := "00001"
   fFORNECEDOR := INVOICE->Fornecedor
   fESTOQUE     := "S"
   fDESPESA     := "N"
   IMPORT->(qreplacefields())
   IMPORT->(qreleasefields())


   if INVOICE->(qrlock())
      replace INVOICE->Enviado with .T.
      INVOICE->(qunlock())
   endif

endif

return





