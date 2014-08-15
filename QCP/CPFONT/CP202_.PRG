/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE COMPRAS
// OBJETIVO...: LANCAMENTO de PEDIDO (CHINA) - MANTRACO
// ANALISTA...: EDUARDO BORIO
// PROGRAMADOR: EDUARDO BORIO
// INICIO.....: NOVEBRO DE 2007
// OBS........:
// ALTERACOES.:
function cp202

#include "inkey.ch"
#include "fileio.ch"
#define K_MAX_LIN 50
#define TAB chr(9)
PROD->(dbsetorder(4))

quse(XDRV_CL,"CONFIG",NIL,NIL,"FATCFG")

/////////////////////////////////////////////////////////////////////////////
// MANUTENCAO DE COTACOES __________________________________________________

PED_FABR->(qview({{"left(Codigo,5)/C¢digo",1},;
                  {"Data_ped/Data"                       ,2},;
                  {"i_202desc_forn()/Fornecedor"            ,3}},"P",;
                  {NIL,"i_202b",NIL,NIL},;
                   NIL,q_msg_acesso_usr()+"/Im<P>rimir"))
return
FATCFG->(DbCloseArea())


function i_202desc_forn
local cRAZAO

   if FORN->(dbseek(PED_FABR->Cod_forn))
      cRAZAO := left(FORN->RAZAO,45)
   else
      cRAZAO := ""
   endif



return cRAZAO

//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO _____________________________________

function i_202b

   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))

   iif(cOPCAO=="P",i_imprime() ,nil)

   if cOPCAO $ XUSRA
      qlbloc(5,0,"B202A","QBLOC.GLO",1)
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

      qsay ( 06,20 , PED_FABR->Codigo,"@R 99999"   )
      qsay ( 08,20 , dtoc(PED_FABR->Data_ped)          )
      qsay ( 10,20 , PED_FABR->Cod_forn            )
      qsay ( 10,28 , left(PED_FABR->Fornecedor,45) )
      qsay ( 12,20 , left(PED_FABR->Obs,57) )

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
   aadd(aEDICAO,{{ || view_forn(10,20,@fCOD_FORN                       )} ,"COD_FORN"     })
   aadd(aEDICAO,{{ || qgetx(10,28,@fFORNECEDOR,"@!@S45",               )} ,"FORNECEDOR"   })
   aadd(aEDICAO,{{ || qgetx(12,20,@fOBS,"@!@S57",               )} ,"OBS"   })
   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO ____________________________________________________

   do while .T.

      qgirabarra()

      PED_FABR->(qpublicfields())

      iif(cOPCAO=="I", PED_FABR->(qinitfields()), PED_FABR->(qcopyfields()))

      XNIVEL := 2
      XFLAG := .T.

      // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

      do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
         eval ( aEDICAO [XNIVEL,1] )
         if eval ( bESCAPE );PED_FABR->(qreleasefields());return;endif
         if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
         iif ( XFLAG , XNIVEL++ , XNIVEL-- )
         qmensa("")
      enddo

      if ! lCONF ; return ; endif

      // AQUI INCREMENTA CODIGO DO TOMA_PRE ___________________________________

      if cOPCAO == "I" .and. CONFIG->(qrlock())
         replace CONFIG->cod_fabr with CONFIG->cod_fabr + 1
         fCODIGO := strzero(CONFIG->cod_fabr,5)
         qsay( 06,20 ,  transform(fCODIGO,"@R 99999")  )
         qmensa("C¢digo Gerado: "+transform(fCODIGO,"@R 99999"),"B")
      endif

      if PED_FABR->(iif(cOPCAO=="I",qappend(),qrlock()))

         // AGORA GRAVA E DESTRAVA ARQUIVO _____________________________________

         PED_FABR->(qreplacefields())

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

      if PED_FABR->(qrlock())

         ITEN_PED->(dbseek(PED_FABR->Codigo)) // itens da cotacao

         do while ! ITEN_PED->(eof()) .and. ITEN_PED->Cod_ped == PED_FABR->Codigo
            ITEN_PED->(qrlock())
            ITEN_PED->(dbdelete())
            ITEN_PED->(qunlock())
            ITEN_PED->(dbskip())
         enddo

         PED_FABR->(dbdelete())
         PED_FABR->(qunlock())

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

ITEN_PED-> (qview({{"i_202codass()/Ref."                          ,0},;
                   {"i_202fabr()/Ref. 2"                        ,0},;
                   {"i_202descprod()/Descricao"                       ,0},;
                   {"i_202colecao()/Colecao"                       ,0},;
                   {"transform(Quantidade,'@R 9999999')/Quantidade",0},;
                   {"i_202uni()/Unid."                      ,0}},;
                   "13002378S",;
                   {NIL,"f202e",NIL,NIL},;
                   {"ITEN_PED->Cod_ped == PED_FABR->Codigo",{||f202top()},{||f202bot()}},;
                   "<I>nc./<A>lt./<C>on./<E>xc/<ESC> para sair"))
return ""


////////////////////////////////////////////////////////////
//FUNCAO PARA MOSTRAR DESCRICAO DE PRODUTOS _______________

function i_202descprod
local aRet := ""

  PROD->(dbsetorder(4))

  if PROD->(dbseek(ITEN_PED->Cod_prod))
     cRET := left(PROD->Descricao,30)
  endif

return cRET



function i_202fabr
local aRet := ""

  PROD->(dbsetorder(4))

  if PROD->(dbseek(ITEN_PED->Cod_prod))
     cRET := left(PROD->Cod_fabr,8)
  endif

return cRET




function i_202codass
local cRET := ""

  PROD->(dbsetorder(4))
  if PROD->(dbseek(ITEN_PED->Cod_prod))
     cRET := PROD->Cod_ass

  endif

return cRET



function i_202colecao
local cRET := ""

  PROD->(dbsetorder(4))
  if PROD->(dbseek(ITEN_PED->Cod_prod))
     cRET := left(PROD->Marca,15)

  endif
return cRET



function i_202uni
local cRET := ""

  PROD->(dbsetorder(4))
  if PROD->(dbseek(ITEN_PED->Cod_prod))
     UNIDADE->(dbseek(PROD->Unidade))
     cRET := UNIDADE->Sigla

  endif
return cRET






/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IR PARA O INICIO DOS DADOS FILTRADOS _________________________

function f202top
   ITEN_PED->(dbsetorder(1))
   ITEN_PED->(dbseek(PED_FABR->Codigo))
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IR PARA O FINAL DOS DADOS FILTRADOS __________________________

function f202bot
   ITEN_PED->(dbsetorder(1))
   ITEN_PED->(qseekn(PED_FABR->Codigo))
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO DE CONTROLE PRINCIPAL ANTES DE PROCESSAR A TECLA ACIONADA _________

function f202e

   local nCURSOR := setcursor(1)
   parameters cOPCAO

   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO $ XUSRA
      qlbloc(10,10,"B202B","QBLOC.GLO",1)
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
      qrsay ( XNIVEL++ , ITEN_PED->Cod_prod                      ) ; PROD->(dbseek(ITEN_PED->Cod_prod))
      qrsay ( XNIVEL++ , left(PROD->Descricao,20)                )
      qrsay ( XNIVEL++ , left(PROD->Marca,25)                )
      qrsay ( XNIVEL++ , left(PROD->Cod_ass,7)                )
      qrsay ( XNIVEL++ , left(PROD->Cod_fabr,8)                )
      qrsay ( XNIVEL++ , transform(ITEN_PED->Quantidade,"@e 9999999")   )
      UNIDADE->(dbseek(PROD->Unidade))
      qrsay ( XNIVEL++ , UNIDADE->Sigla)

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


   aadd(aEDICAO,{{ || qgetx(-1,0,@fQuantidade, "9999999"                  ) } ,"Quantidade"      })
   aadd(aEDICAO,{{ || NIL                                            } ,NIL          })

   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   ITEN_PED->(qpublicfields())

   iif(cOPCAO=="I",ITEN_PED->(qinitfields()),ITEN_PED->(qcopyfields()))

   XNIVEL := 1
   XFLAG  := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; ITEN_PED->(qreleasefields()) ; return ; endif
      if ! i_crit2( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   if ! lCONF ; return ; endif

   // GRAVACAO ______________________________________________________________

   if PED_FABR->(qrlock()) .and. ITEN_PED->(iif(cOPCAO=="I",qappend(),qrlock()))
      if cOPCAO == "I"
         fCOD_PED := PED_FABR->Codigo
      endif

      ITEN_PED->(qreplacefields())
      ITEN_PED->(qunlock())

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

           qrsay ( XNIVEL+1 , left(PROD->Descricao,30) )
           qrsay ( XNIVEL+2 , PROD->Marca )
           qrsay ( XNIVEL+3 , PROD->Cod_ass )
           qrsay ( XNIVEL+4 , left(PROD->Cod_fabr,7) )

           if UNIDADE->(dbseek(PROD->Unidade))
              qrsay ( XNIVEL+6 , UNIDADE->Sigla )
           endif

      case cCAMPO == "Quantidade"

           if fQuantidade <= 0 ; return .F. ; endif


   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXCLUIR ITENS DO TOMA_PREO ___________________________________

static function i_exc_itens

   if qconf("Confirma exclus„o do Item ?")

      if ITEN_PED->(qrlock())
         ITEN_PED->(dbdelete())
         ITEN_PED->(qunlock())
      else
         qm3()
      endif
   endif

return

////////////////////////////////////////////////////////////////////////////////////
static function i_atu_lanc


// LOOP PRINCIPAL ___________________________________________________________

setcolor("W/B")

ITEN_PED-> (qview({{"i_202codass()/Ref."                          ,0},;
                   {"i_202fabr()/Ref. 2"                        ,0},;
                   {"i_202descprod()/Descricao"                       ,0},;
                   {"i_202colecao()/Colecao"                       ,0},;
                   {"transform(Quantidade,'@R 9999999')/Quantidade",0},;
                   {"i_202uni()/Unid."                      ,0}},;
                   "13002378S",;
                   {NIL,"f202e",NIL,NIL},;
                   {"ITEN_PED->Cod_ped == PED_FABR->Codigo",{||f202top()},{||f202bot()}},;
                   "<I>nc./<A>lt./<C>on./<E>xc/<ESC> para sair"))


return


static function i_imprime

   if ! qinitprn() ; return ; endif

   if XLOCALIMP == "X"
      i_impre_xls()
   else
      i_impre_prn()
   endif

return

static function i_impre_prn
   local cTITULO,cTITULO2,cPROD,zPROD := ""
   local aPED  := {}
   local asPED := {}
   local lVetorNaoVazio := .F.

   cTITULO := "Pedido de Fabricacao (China) - No.: "+PED_FABR->Codigo

   PROD->(dbsetorder(4))

   ITEN_PED->(dbseek(PED_FABR->Codigo))
   Do while ! ITEN_PED->(Eof()) .and. ITEN_PED->Cod_ped == PED_FABR->Codigo

      PROD->(dbseek(ITEN_PED->Cod_prod))

      aadd(aPED,{PROD->Fabr,ITEN_PED->Cod_prod,ITEN_PED->Quantidade})

      lVetorNaoVazio := .T.
      ITEN_PED->(dbskip())
   enddo



   asPED := asort(aPED,,,{|x,y| x[1] < y[1] })

   if lVetorNaoVazio
       cFABR := asPED[1,1]
       FABRICA->(dbseek(cFABR))
       cTITULO2 := "FABRICA.: "+left(FABRICA->Razao,50)


       nCONT := 1
       do while  nCONT <= len(asPED)

           if ! qlineprn() ; exit ; endif

           if XPAGINA == 0 .or. prow() > K_MAX_LIN
              qpageprn()
              qcabecprn(cTITULO,110,NIL,rtrim(cTITULO2))
              @ prow()+1,0 say XCOND1 + "Ref1.   Ref2.  Descricao                Quantidade   Preco    CBM   Total"
              @ prow()+1,0 say replicate("-",110)
           endif

           PROD->(dbseek(asPED[nCONT,2]))
           
           @ prow()+1,00 say PROD->Cod_ass
           @ prow()  ,10 say left(PROD->Cod_fabr,6)
           @ prow()  ,20 say left(PROD->Descricao,20)
           @ prow()  ,50 say transform(asPED[nCONT,3],"@R 9999999")
           @ prow()  ,70 say ""//transform(asPED[nCONT,3],"@R 9999999")
           @ prow()  ,90 say transform(PROD->Cubagem,"@R 999999.999")


           nCONT++
           if nCONT > len(asPED)
              nCONT := len(asPED)
              exit
           endif

           if asPED[nCONT,1] != cFABR
              cFABR := asPED[nCONT,1]
              FABRICA->(dbseek(cFABR))
              cTITULO2 := "FABRICA.: "+left(FABRICA->Razao,50)

              eject
              qpageprn()
              qcabecprn(cTITULO,110,NIL,rtrim(cTITULO2))
              @ prow()+1,0 say XCOND1 + "Ref1.   Ref2.  Descricao                Quantidade   Preco    CBM   Total"
              @ prow()+1,0 say replicate("-",110)

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
   local cFANTASIA := ""
   local nFile := 0
   local cBuffer := ""
   local nTotItens := 0
   local nResto := 0
   

   cTITULO := "Pedido de Fabricacao (China) - No.: "+PED_FABR->Codigo

   PROD->(dbsetorder(4))

   ITEN_PED->(dbseek(PED_FABR->Codigo))
   Do while ! ITEN_PED->(Eof()) .and. ITEN_PED->Cod_ped == PED_FABR->Codigo

      PROD->(dbseek(ITEN_PED->Cod_prod))

      aadd(aPED,{PROD->Fabr,ITEN_PED->Cod_prod,ITEN_PED->Quantidade,PROD->Cod_fabr,PROD->Cust_ren,PROD->cust_dolar})

      lVetorNaoVazio := .T.
      ITEN_PED->(dbskip())
   enddo

   asPED := asort(aPED,,,{|x,y| x[1] + x[4]< y[1] + Y[4]})

   if lVetorNaoVazio

       cFABR := asPED[1,1]
       FABRICA->(dbseek(cFABR))
       cTITULO2 := "FABRICA.: "+left(FABRICA->Razao,50)
       cFANTASIA := FABRICA->Fantasia
	   
	   cFabrica := FABRICA->Razao
       
	   
	   cBuffer += xmlAbre(10,10,10,10)
       cBuffer += xmlStyles()
       cBuffer += xmlFechaStyles()
	   cBuffer += xmlCabecalho(cFabrica)
	  
	     

       nCONT := 1
       do while  nCONT <= len(asPED)

           PROD->(dbseek(asPED[nCONT,2]))
           
           cBuffer += xmlAbreLinha(15.75,"s88",0)
             cBuffer += xmlCell("String",rtrim(left(PROD->cod_fabr,6))+" - "+left(PROD->Descricao,25),"s91",2)
             cBuffer += xmlCell("Number",alltrim(transf(asPED[nCont,3],"@R 999999999")),"s79")
			 cBuffer += xmlCell("Number",alltrim(transf(asPED[nCont,5],"@R 999999999999.99")),"s87")
			 cBuffer += xmlCell("Number",alltrim(transf(asPED[nCont,3]*asPED[nCont,5],"@R 99999999999.99")),"s97")
           cBuffer += xmlFechaLinha()
		   
		   nTotItens ++

           nCONT++
           if nCONT > len(asPED)
              nCONT := len(asPED)
              exit
           endif

           if asPED[nCONT,1] != cFABR
              cFABR := asPED[nCONT,1]
              FABRICA->(dbseek(cFABR))
			  cFabrica := left(FABRICA->Razao,15)
			  
			  cBuffer += xmlRestoItem(nTotItens)
			  
			  nTotItens := 0
			  nResto    := 0

              cBuffer += xmlFechaPasta()
              cBuffer += xmlCabecalho(cFabrica)


          endif
       enddo
       cBuffer += XmlFechaPasta()
       cBuffer += XmlFecha()
	   
	   cFileName := "Purchase Order China "+ strzero(year(date()),4)+ " "+strzero(month(date()),2)+" "+strzero(day(date()),2)+ " - " + left(time(),2)+" "+substr(time(),4,2)+".xml"
   
       nFile := fCreate("C:\Qsystxt\"+cFileNAme,0)
       fWrite(nFile,cBuffer,len(cBuffer))
       fClose(nFile)
       alert("Arquivo "+cFileName+" gerado com sucesso.")


   endif

   qstopprn()

return

static function xmlRestoItem(nTotItens)
local cBuffer := ""
local nResto := 0
local nCont := 1

     if nTotItens <= 40
	     
        nResto := 40 - nTotItens   		 
		
		for nCont :=1 to nResto
    
	       cBuffer += xmlAbreLinha(15.75,"s88",0)
             cBuffer += xmlCell("String","","s91",2)
             cBuffer += xmlCell("Number",alltrim(transf(0,"@R 999999999")),"s79")
			 cBuffer += xmlCell("Number",alltrim(transf(0,"@R 999999999999.99")),"s87")
			 cBuffer += xmlCell("Number",alltrim(transf(0,"@R 99999999999.99")),"s97")
           cBuffer += xmlFechaLinha()
		next   
	 endif	   


return cBuffer

static function xmlColunas
local xml := ""
   xml += '<Column ss:Index="2" ss:StyleID="s64" ss:AutoFitWidth="0" ss:Width="255"/>'+chr(13)+chr(10)
   xml += '<Column ss:StyleID="s64" ss:AutoFitWidth="0" ss:Width="141"/>'+chr(13)+chr(10)
   xml += '<Column ss:StyleID="s64" ss:AutoFitWidth="0" ss:Width="114"/>'+chr(13)+chr(10)
   xml += '<Column ss:StyleID="s64" ss:AutoFitWidth="0" ss:Width="116.25"/>'+chr(13)+chr(10)

return xml

static function xmlCabecalho(cFabrica)
local cBuffer:= ""

       cBuffer += xmlAbrePasta(left(cFabrica,15))
	   cBuffer += xmlColunas()
        
       cBuffer += xmlLinha(,"cinza",0)
	   cBuffer += xmlLinha(24,"cinza",0)
	   
	   cBuffer += xmlAbreLinha(53.25,"s88",0)
	     cBuffer += xmlCell("String","PURCHASE ORDER","m78874228",2,3)
	   cBuffer += xmlFechaLinha()
	   
	   cBuffer += xmlAbreLinha(,"s88",0)
	     cBuffer += xmlCell("String","MANTRA BRASIL","s118",2)
		 cBuffer += xmlCell("String","","s119")
		 cBuffer += xmlCell("String","PO NUMBER:","s119")
		 cBuffer += xmlCell("Number",PED_FABR->Codigo,"s120")
	   cBuffer += xmlFechaLinha()	 
	   
	   cBuffer += xmlAbreLinha(,"s88",0)
	     cBuffer += xmlCell("String","","s118",2)
		 cBuffer += xmlCell("String","","s119")
		 cBuffer += xmlCell("String","PO DATE:","s119")
		 cBuffer += xmlCell("String",dtoc(PED_FABR->Data_ped),"s120")
	   cBuffer += xmlFechaLinha()
	   
	   cBuffer += xmlAbreLinha(,"s88",0)
	     cBuffer += xmlCell("String","","s118",2)
		 cBuffer += xmlCell("String","","s119")
		 cBuffer += xmlCell("String","","s119")
		 cBuffer += xmlCell("String","","s120")
	   cBuffer += xmlFechaLinha()
	   
	   cBuffer += xmlAbreLinha(,"s88",0)
	     cBuffer += xmlCell("String","","s118",2)
		 cBuffer += xmlCell("String","","s119")
		 cBuffer += xmlCell("String","","s119")
		 cBuffer += xmlCell("String","","s120")
	   cBuffer += xmlFechaLinha()
	   
	   cBuffer += xmlAbreLinha(15.75,"s88",0)
	     cBuffer += xmlCell("String","Buyer","s113",2)
		 cBuffer += xmlCell("String","","s114")
		 cBuffer += xmlCell("String","Suplier","s114")
		 cBuffer += xmlCell("String","","s115")
	   cBuffer += xmlFechaLinha()
	   
	   cBuffer += xmlAbreLinha(15.75,"s88")
	     cBuffer += xmlCell("String","Rua Eng. Julio Cesar de Souza Araujo, 220","s91",2)
		 cBuffer += xmlCell("String","","s92")
		 cBuffer += xmlCell("String",cFabrica,"s92")
		 cBuffer += xmlCell("String","","s93")
	   cBuffer += xmlFechaLinha()
	   
	   cBuffer += xmlAbreLinha(15.75,"s88")
	     cBuffer += xmlCell("String","Cidade Industrial - Curitiba - PR - Brasil.","s91",2)
		 cBuffer += xmlCell("String","","s92")
		 cBuffer += xmlCell("String","","s92")
		 cBuffer += xmlCell("String","","s93")
	   cBuffer += xmlFechaLinha()
	   
	   cBuffer += xmlAbreLinha(15.75,"s88")
	     cBuffer += xmlCell("String","CEP: 81290-270","s91",2)
		 cBuffer += xmlCell("String","","s92")
		 cBuffer += xmlCell("String","","s92")
		 cBuffer += xmlCell("String","","s93")
	   cBuffer += xmlFechaLinha()
	   
	   cBuffer += xmlAbreLinha(15.75,"s88")
	     cBuffer += xmlCell("String","Tel. 55 41 3026.8081","s91",2)
		 cBuffer += xmlCell("String","","s92")
		 cBuffer += xmlCell("String","China","s92")
		 cBuffer += xmlCell("String","","s93")
	   cBuffer += xmlFechaLinha()
	   
	   cBuffer += xmlAbreLinha(15.75,"s88")
	     cBuffer += xmlCell("String","E-mail: contato@mantraco.com.br","s91",2)
		 cBuffer += xmlCell("String","","s92")
		 cBuffer += xmlCell("String","","s92")
		 cBuffer += xmlCell("String","","s93")
	   cBuffer += xmlFechaLinha()
	   
	   cBuffer += xmlAbreLinha(15.75,"s88")
	     cBuffer += xmlCell("String","","s91",2)
		 cBuffer += xmlCell("String","","s92")
		 cBuffer += xmlCell("String","","s92")
		 cBuffer += xmlCell("String","","s93")
	   cBuffer += xmlFechaLinha()
	   
	   cBuffer += xmlAbreLinha(15.75,"s88",0)
	     cBuffer += xmlCell("String","Payment","s113",2)
		 cBuffer += xmlCell("String","Deposit","s114")
		 cBuffer += xmlCell("String","Delivery Term","m78874208",,1)
	   cBuffer += xmlFechaLinha()
	   
	   cBuffer += xmlAbreLinha(15.75,"s88")
	     cBuffer += xmlCell("String"," Teste ","s91",2)
		 cBuffer += xmlCell("String","","s92")
		 cBuffer += xmlCell("String","No particular conditions","s93",,1)
	   cBuffer += xmlFechaLinha()
	   
	   cBuffer += xmlAbreLinha(15.75,"s88",0)
	     cBuffer += xmlCell("String","Item Description","s113",2)
		 cBuffer += xmlCell("String","Quantity","s114")
		 cBuffer += xmlCell("String","Unit Price (Y)","s114")
		 cBuffer += xmlCell("String","Amount","s115")
	   cBuffer += xmlFechaLinha()
return cBuffer	   
	   

static function xmlStyles
local xml := ""
	 
   xml += '<Style ss:ID="Default" ss:Name="Normal">'+chr(13)+chr(10)
   xml += '<Alignment ss:Vertical="Bottom"/>'+chr(13)+chr(10)
   xml += '<Borders/>'+chr(13)+chr(10)
   xml += '<Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="12" ss:Color="#000000"/>'+chr(13)+chr(10)
   xml += '<Interior/>'+chr(13)+chr(10)
   xml += '<NumberFormat/>'+chr(13)+chr(10)
   xml += '<Protection/>'+chr(13)+chr(10)
   xml += '</Style>'+chr(13)+chr(10)
   
   xml += '<Style ss:ID="s53" ss:Name="Moeda">'+chr(13)+chr(10)
   xml += '<NumberFormat'+chr(13)+chr(10)
   xml += 'ss:Format="_(&quot;$&quot;* #,##0.00_);_(&quot;$&quot;* \(#,##0.00\);_(&quot;$&quot;* &quot;-&quot;??_);_(@_)"/>'+chr(13)+chr(10)
   xml += '</Style>'+chr(13)+chr(10)
   
   xml += '<Style ss:ID="s59" ss:Name="Separador de milhares">'+chr(13)+chr(10)
   xml += '<NumberFormat ss:Format="_(* #,##0.00_);_(* \(#,##0.00\);_(* &quot;-&quot;??_);_(@_)"/>'+chr(13)+chr(10)
   xml += '</Style>'+chr(13)+chr(10)
   
   xml += '<Style ss:ID="cinza">'+chr(13)+chr(10)
   xml += '<Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11"/>'+chr(13)+chr(10)
   xml += '<Interior ss:Color="#969696" ss:Pattern="Solid"/>'+chr(13)+chr(10)
   xml += '</Style>'+chr(13)+chr(10)
   
   xml += '<Style ss:ID="s64">'+chr(13)+chr(10)
   xml += '<Interior ss:Color="#969696" ss:Pattern="Solid"/>'+chr(13)+chr(10)
   xml += '</Style>'+chr(13)+chr(10)
   
   xml += '<Style ss:ID="s68">'+chr(13)+chr(10)
   xml += '<Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="12" ss:Color="#000000"/>'+chr(13)+chr(10)
   xml += '<Interior ss:Color="#969696" ss:Pattern="Solid"/>'+chr(13)+chr(10)
   xml += '</Style>'+chr(13)+chr(10)
   
   xml += '<Style ss:ID="s88">'+chr(13)+chr(10)
   xml += '<Alignment ss:Vertical="Center"/>'+chr(13)+chr(10)
   xml += '<Interior ss:Color="#969696" ss:Pattern="Solid"/>'+chr(13)+chr(10)
   xml += '</Style>'+chr(13)+chr(10)
   
   xml += '<Style ss:ID="s91">'+chr(13)+chr(10)
   xml += '<Alignment ss:Horizontal="Left" ss:Vertical="Bottom" ss:Indent="5"/>'+chr(13)+chr(10)
   xml += '<Borders>'+chr(13)+chr(10)
   xml += '<Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="2"'+chr(13)+chr(10)
   xml += 'ss:Color="#000000"/>'+chr(13)+chr(10)
   xml += '</Borders>'+chr(13)+chr(10)
   xml += '<Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="12"/>'+chr(13)+chr(10)
   xml += '<Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>'+chr(13)+chr(10)
   xml += '</Style>'+chr(13)+chr(10)
   
   xml += '<Style ss:ID="s92">'+chr(13)+chr(10)
   xml += '<Alignment ss:Horizontal="Left" ss:Vertical="Bottom" ss:Indent="5"/>'+chr(13)+chr(10)
   xml += '<Borders/>'+chr(13)+chr(10)
   xml += '<Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="12"/>'+chr(13)+chr(10)
   xml += '<Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>'+chr(13)+chr(10)
   xml += '</Style>'+chr(13)+chr(10)
   
   
   xml += '<Style ss:ID="s93">'+chr(13)+chr(10)
   xml += '<Alignment ss:Horizontal="Left" ss:Vertical="Bottom" ss:Indent="5"/>'+chr(13)+chr(10)
   xml += '<Borders>'+chr(13)+chr(10)
   xml += '<Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="2"'+chr(13)+chr(10)
   xml += 'ss:Color="#000000"/>'+chr(13)+chr(10)
   xml += '</Borders>'+chr(13)+chr(10)
   xml += '<Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="12"/>'+chr(13)+chr(10)
   xml += '<Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>'+chr(13)+chr(10)
   xml += '</Style>'+chr(13)+chr(10)
   
   xml += '<Style ss:ID="s113">'+chr(13)+chr(10)
   xml += '<Alignment ss:Horizontal="Left" ss:Vertical="Bottom"/>'+chr(13)+chr(10)
   xml += '<Borders>'+chr(13)+chr(10)
   xml += '<Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="2"'+chr(13)+chr(10)
   xml += 'ss:Color="#000000"/>'+chr(13)+chr(10)
   xml += '</Borders>'+chr(13)+chr(10)
   xml += '<Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="12" ss:Bold="1"/>'+chr(13)+chr(10)
   xml += '<Interior ss:Color="#808080" ss:Pattern="Solid"/>'+chr(13)+chr(10)
   xml += '</Style>'+chr(13)+chr(10)
   
   xml += '<Style ss:ID="s114">'+chr(13)+chr(10)
   xml += '<Alignment ss:Horizontal="Left" ss:Vertical="Bottom"/>'+chr(13)+chr(10)
   xml += '<Borders/>'+chr(13)+chr(10)
   xml += '<Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="12" ss:Bold="1"/>'+chr(13)+chr(10)
   xml += '<Interior ss:Color="#808080" ss:Pattern="Solid"/>'+chr(13)+chr(10)
   xml += '</Style>'+chr(13)+chr(10)
   
   xml += '<Style ss:ID="s115">'+chr(13)+chr(10)
   xml += '<Alignment ss:Horizontal="Left" ss:Vertical="Bottom"/>'+chr(13)+chr(10)
   xml += '<Borders>'+chr(13)+chr(10)
   xml += '<Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="2"'+chr(13)+chr(10)
   xml += 'ss:Color="#000000"/>'+chr(13)+chr(10)
   xml += '</Borders>'+chr(13)+chr(10)
   xml += '<Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="12" ss:Bold="1"/>'+chr(13)+chr(10)
   xml += '<Interior ss:Color="#808080" ss:Pattern="Solid"/>'+chr(13)+chr(10)
   xml += '</Style>'+chr(13)+chr(10)
   
   xml += '<Style ss:ID="s118">'+chr(13)+chr(10)
   xml += '<Alignment ss:Horizontal="Left" ss:Vertical="Bottom"/>'+chr(13)+chr(10)
   xml += '<Borders>'+chr(13)+chr(10)
   xml += '<Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="2"'+chr(13)+chr(10)
   xml += 'ss:Color="#000000"/>'+chr(13)+chr(10)
   xml += '</Borders>'+chr(13)+chr(10)
   xml += '<Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="14" ss:Color="#000000"'+chr(13)+chr(10)
   xml += 'ss:Bold="1"/>'+chr(13)+chr(10)
   xml += '<Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>'+chr(13)+chr(10)
   xml += '</Style>'+chr(13)+chr(10)
   
   xml += '<Style ss:ID="s119">'+chr(13)+chr(10)
   xml += '<Alignment ss:Horizontal="Left" ss:Vertical="Bottom"/>'+chr(13)+chr(10)
   xml += '<Borders/>'+chr(13)+chr(10)
   xml += '<Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="14" ss:Color="#000000"'+chr(13)+chr(10)
   xml += 'ss:Bold="1"/>'+chr(13)+chr(10)
   xml += '<Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>'+chr(13)+chr(10)
   xml += '</Style>'+chr(13)+chr(10)
   
   xml += '<Style ss:ID="s120">'+chr(13)+chr(10)
   xml += '<Alignment ss:Horizontal="Left" ss:Vertical="Bottom"/>'+chr(13)+chr(10)
   xml += '<Borders>'+chr(13)+chr(10)
   xml += '<Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="2"'+chr(13)+chr(10)
   xml += 'ss:Color="#000000"/>'+chr(13)+chr(10)
   xml += '</Borders>'+chr(13)+chr(10)
   xml += '<Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="14" ss:Color="#000000"'+chr(13)+chr(10)
   xml += 'ss:Bold="1"/>'+chr(13)+chr(10)
   xml += '<Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>'+chr(13)+chr(10)
   xml += '</Style>'+chr(13)+chr(10)
   
   
   
   xml += '<Style ss:ID="m78874208">'+chr(13)+chr(10)
   xml += '<Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>'+chr(13)+chr(10)
   xml += '<Borders>'+chr(13)+chr(10)
   xml += '<Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="2"'+chr(13)+chr(10)
   xml += 'ss:Color="#000000"/>'+chr(13)+chr(10)
   xml += '</Borders>'+chr(13)+chr(10)
   xml += '<Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="12" ss:Color="#000000"'+chr(13)+chr(10)
   xml += 'ss:Bold="1"/>'+chr(13)+chr(10)
   xml += '<Interior ss:Color="#808080" ss:Pattern="Solid"/>'+chr(13)+chr(10)
   xml += '</Style>'+chr(13)+chr(10)
   
   xml += '<Style ss:ID="m78874218">'+chr(13)+chr(10)
   xml += '<Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>'+chr(13)+chr(10)
   xml += '<Borders>'+chr(13)+chr(10)
   xml += '<Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="2"'+chr(13)+chr(10)
   xml += 'ss:Color="#000000"/>'+chr(13)+chr(10)
   xml += '</Borders>'+chr(13)+chr(10)
   xml += '<Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="12" ss:Color="#000000"/>'+chr(13)+chr(10)
   xml += '<Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>'+chr(13)+chr(10)
   xml += '</Style>'+chr(13)+chr(10)
   
   xml += '<Style ss:ID="m78874228">'+chr(13)+chr(10)
   xml += '<Alignment ss:Horizontal="Center" ss:Vertical="Center"/>'+chr(13)+chr(10)
   xml += '<Borders>'+chr(13)+chr(10)
   xml += '<Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="2"'+chr(13)+chr(10)
   xml += 'ss:Color="#000000"/>'+chr(13)+chr(10)
   xml += '<Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="2"'+chr(13)+chr(10)
   xml += 'ss:Color="#000000"/>'+chr(13)+chr(10)
   xml += '<Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="2"'+chr(13)+chr(10)
   xml += 'ss:Color="#000000"/>'+chr(13)+chr(10)
   xml += '</Borders>'+chr(13)+chr(10)
   xml += '<Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="24" ss:Color="#000000"'+chr(13)+chr(10)
   xml += 'ss:Bold="1"/>'+chr(13)+chr(10)
   xml += '<Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>'+chr(13)+chr(10)
   xml += '</Style>'+chr(13)+chr(10)
   
   xml += '<Style ss:ID="s79" ss:Parent="s59">'+chr(13)+chr(10)
   xml += '<Alignment ss:Horizontal="Right" ss:Vertical="Bottom"/>'+chr(13)+chr(10)
   xml += '<Borders>'+chr(13)+chr(10)
   xml += '<Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
   xml += '<Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
   xml += '</Borders>'+chr(13)+chr(10)
   xml += '<Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="12"/>'+chr(13)+chr(10)
   xml += '<Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>'+chr(13)+chr(10)
   xml += '</Style>'+chr(13)+chr(10)
   
   xml += '<Style ss:ID="s87" ss:Parent="s53">'+chr(13)+chr(10)
   xml += '<Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>'+chr(13)+chr(10)
   xml += '<Borders>'+chr(13)+chr(10)
   xml += '<Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
   xml += '</Borders>'+chr(13)+chr(10)
   xml += '<Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="12" ss:Color="#000000"/>'+chr(13)+chr(10)
   xml += '<Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>'+chr(13)+chr(10)
   xml += '</Style>'+chr(13)+chr(10)
   
   xml += '<Style ss:ID="s97" ss:Parent="s53">'+chr(13)+chr(10)
   xml += '<Alignment ss:Vertical="Bottom"/>'+chr(13)+chr(10)
   xml += '<Borders>'+chr(13)+chr(10)
   xml += '<Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
   xml += '<Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="2"'+chr(13)+chr(10)
   xml += 'ss:Color="#000000"/>'+chr(13)+chr(10)
   xml += '</Borders>'+chr(13)+chr(10)
   xml += '<Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="12" ss:Color="#000000"/>'+chr(13)+chr(10)
   xml += '<Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>'+chr(13)+chr(10)
   xml += '</Style>'+chr(13)+chr(10)
	 
return xml
