/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE COMPRAS
// OBJETIVO...: LANCAMENTO de PEDIDO (CHINA) - MANTRACO
// ANALISTA...: EDUARDO BORIO
// PROGRAMADOR: EDUARDO BORIO
// INICIO.....: NOVEBRO DE 2007
// OBS........:
// ALTERACOES.:
function cp205

#include "inkey.ch"
#include "fileio.ch"
#define K_MAX_LIN 50
#define TAB chr(9)
PROD->(dbsetorder(4))

quse(XDRV_CL,"CONFIG",NIL,NIL,"FATCFG")

/////////////////////////////////////////////////////////////////////////////
// MANUTENCAO DE COTACOES __________________________________________________

WAREHOUS->(qview({{"left(Codigo,5)/C¢digo",1},;
                  {"Data_ped/Data"                       ,2},;
                  {"i_205desc_forn()/Fornecedor"            ,3}},"P",;
                  {NIL,"i_205b",NIL,NIL},;
                   NIL,q_msg_acesso_usr()+"/Im<P>rimir"))
return
FATCFG->(DbCloseArea())


function i_205desc_forn
local cRAZAO := space(45)

   if FORN->(dbseek(WAREHOUS->Cod_forn))
      cRAZAO := left(FORN->RAZAO,45)
   else
      cRAZAO := space(45)
   endif



return cRAZAO

//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO _____________________________________

function i_205b

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

      qsay ( 06,20 , WAREHOUS->Codigo,"@R 99999"   )
      qsay ( 08,20 , dtoc(WAREHOUS->Data_ped)          )
      qsay ( 10,20 , WAREHOUS->Cod_forn            )
      qsay ( 10,28 , left(WAREHOUS->Fornecedor,45) )
      qsay ( 12,20 , left(WAREHOUS->Obs,57) )

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

      WAREHOUS->(qpublicfields())

      iif(cOPCAO=="I", WAREHOUS->(qinitfields()), WAREHOUS->(qcopyfields()))

      XNIVEL := 2
      XFLAG := .T.

      // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

      do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
         eval ( aEDICAO [XNIVEL,1] )
         if eval ( bESCAPE );WAREHOUS->(qreleasefields());return;endif
         if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
         iif ( XFLAG , XNIVEL++ , XNIVEL-- )
         qmensa("")
      enddo

      if ! lCONF ; return ; endif

      // AQUI INCREMENTA CODIGO DO TOMA_PRE ___________________________________

      if cOPCAO == "I" .and. CONFIG->(qrlock())
         replace CONFIG->cod_ware with CONFIG->cod_ware + 1
         fCODIGO := strzero(CONFIG->cod_ware,5)
         qsay( 06,20 ,  transform(fCODIGO,"@R 99999")  )
         qmensa("C¢digo Gerado: "+transform(fCODIGO,"@R 99999"),"B")
      endif

      if WAREHOUS->(iif(cOPCAO=="I",qappend(),qrlock()))

         // AGORA GRAVA E DESTRAVA ARQUIVO _____________________________________

         WAREHOUS->(qreplacefields())

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

      if WAREHOUS->(qrlock())

         ITEN_WAR->(dbseek(WAREHOUS->Codigo)) // itens da cotacao

         do while ! ITEN_WAR->(eof()) .and. ITEN_WAR->Cod_ware == WAREHOUS->Codigo
            ITEN_WAR->(qrlock())
            ITEN_WAR->(dbdelete())
            ITEN_WAR->(qunlock())
            ITEN_WAR->(dbskip())
         enddo

         WAREHOUS->(dbdelete())
         WAREHOUS->(qunlock())

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

ITEN_WAR-> (qview({{"i_205codass()/Ref."                          ,0},;
                   {"i_205fabr()/Ref. 2"                        ,0},;
                   {"i_205descprod()/Descricao"                       ,0},;
                   {"i_205colecao()/Colecao"                       ,0},;
                   {"transform(Quantidade,'@R 9999999')/Quantidade",0},;
                   {"i_205uni()/Unid."                      ,0}},;
                   "13002378S",;
                   {NIL,"f205e",NIL,NIL},;
                   {"ITEN_WAR->Cod_ware == WAREHOUS->Codigo",{||f205top()},{||f205bot()}},;
                   "<I>nc./<A>lt./<C>on./<E>xc/<ESC> para sair"))
return ""


////////////////////////////////////////////////////////////
//FUNCAO PARA MOSTRAR DESCRICAO DE PRODUTOS _______________

function i_205descprod
local aRet := ""

  PROD->(dbsetorder(4))

  if PROD->(dbseek(ITEN_WAR->Cod_prod))
     cRET := left(PROD->Descricao,30)
  endif

return cRET



function i_205fabr
local aRet := ""

  PROD->(dbsetorder(4))

  if PROD->(dbseek(ITEN_WAR->Cod_prod))
     cRET := left(PROD->Cod_fabr,8)
  endif

return cRET




function i_205codass
local cRET := ""

  PROD->(dbsetorder(4))
  if PROD->(dbseek(ITEN_WAR->Cod_prod))
     cRET := PROD->Cod_ass

  endif

return cRET



function i_205colecao
local cRET := ""

  PROD->(dbsetorder(4))
  if PROD->(dbseek(ITEN_WAR->Cod_prod))
     cRET := left(PROD->Marca,15)

  endif
return cRET



function i_205uni
local cRET := ""

  PROD->(dbsetorder(4))
  if PROD->(dbseek(ITEN_WAR->Cod_prod))
     UNIDADE->(dbseek(PROD->Unidade))
     cRET := UNIDADE->Sigla

  endif
return cRET

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IR PARA O INICIO DOS DADOS FILTRADOS _________________________

function f205top
   ITEN_WAR->(dbsetorder(1))
   ITEN_WAR->(dbseek(WAREHOUS->Codigo))
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IR PARA O FINAL DOS DADOS FILTRADOS __________________________

function f205bot
   ITEN_WAR->(dbsetorder(1))
   ITEN_WAR->(qseekn(WAREHOUS->Codigo))
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO DE CONTROLE PRINCIPAL ANTES DE PROCESSAR A TECLA ACIONADA _________

function f205e

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
      qrsay ( XNIVEL++ , ITEN_WAR->Cod_prod                      ) ; PROD->(dbseek(ITEN_WAR->Cod_prod))
      qrsay ( XNIVEL++ , left(PROD->Descricao,20)                )
      qrsay ( XNIVEL++ , left(PROD->Marca,25)                )
      qrsay ( XNIVEL++ , left(PROD->Cod_ass,7)                )
      qrsay ( XNIVEL++ , left(PROD->Cod_fabr,8)                )
      qrsay ( XNIVEL++ , transform(ITEN_WAR->Quantidade,"@e 9999999")   )
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

   ITEN_WAR->(qpublicfields())

   iif(cOPCAO=="I",ITEN_WAR->(qinitfields()),ITEN_WAR->(qcopyfields()))

   XNIVEL := 1
   XFLAG  := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; ITEN_WAR->(qreleasefields()) ; return ; endif
      if ! i_crit2( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   if ! lCONF ; return ; endif

   // GRAVACAO ______________________________________________________________

   if WAREHOUS->(qrlock()) .and. ITEN_WAR->(iif(cOPCAO=="I",qappend(),qrlock()))
      if cOPCAO == "I"
         fCOD_WARE := WAREHOUS->Codigo
      endif

      ITEN_WAR->(qreplacefields())
      ITEN_WAR->(qunlock())

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

      if ITEN_WAR->(qrlock())
         ITEN_WAR->(dbdelete())
         ITEN_WAR->(qunlock())
      else
         qm3()
      endif
   endif

return

////////////////////////////////////////////////////////////////////////////////////
static function i_atu_lanc


// LOOP PRINCIPAL ___________________________________________________________

setcolor("W/B")

ITEN_WAR-> (qview({{"i_205codass()/Ref."                          ,0},;
                   {"i_205fabr()/Ref. 2"                        ,0},;
                   {"i_205descprod()/Descricao"                       ,0},;
                   {"i_205colecao()/Colecao"                       ,0},;
                   {"transform(Quantidade,'@R 9999999')/Quantidade",0},;
                   {"i_205uni()/Unid."                      ,0}},;
                   "13002378S",;
                   {NIL,"f205e",NIL,NIL},;
                   {"ITEN_WAR->Cod_ware == WAREHOUS->Codigo",{||f205top()},{||f205bot()}},;
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

   cTITULO := "WareHouse Order (China) - No.: "+WAREHOUS->Codigo

   PROD->(dbsetorder(4))

   ITEN_WAR->(dbseek(WAREHOUS->Codigo))
   Do while ! ITEN_WAR->(Eof()) .and. ITEN_WAR->Cod_ware == WAREHOUS->Codigo

      PROD->(dbseek(ITEN_WAR->Cod_prod))

      aadd(aPED,{PROD->Fabr,ITEN_WAR->Cod_prod,ITEN_WAR->Quantidade})

      lVetorNaoVazio := .T.
      ITEN_WAR->(dbskip())
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
              @ prow()+1,0 say XCOND1 + "Ref1.   Ref2.  Description                Qty          Price    Cubic Footage   Total"
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
              @ prow()+1,0 say XCOND1 + "Ref1.   Ref2.  Description           Qty      Price    Cubic Footage  Total"
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

   cTITULO := "Warehouse Order (China) - No.: "+WAREHOUS->Codigo

   PROD->(dbsetorder(4))

   ITEN_WAR->(dbseek(WAREHOUS->Codigo))
   Do while ! ITEN_WAR->(Eof()) .and. ITEN_WAR->Cod_ware == WAREHOUS->Codigo

      PROD->(dbseek(ITEN_WAR->Cod_prod))

      aadd(aPED,{PROD->Fabr,ITEN_WAR->Cod_prod,ITEN_WAR->Quantidade})

      lVetorNaoVazio := .T.
      ITEN_WAR->(dbskip())
   enddo

   asPED := asort(aPED,,,{|x,y| x[1] < y[1] })

   if lVetorNaoVazio

       nFile := fCreate("C:\qsystxt\warehouse.xml",FC_NORMAL)
       cFABR := asPED[1,1]
       FABRICA->(dbseek(cFABR))
       cTITULO2 := "FABRICA.: "+left(FABRICA->Razao,50)
       cFANTASIA := FABRICA->Fantasia
       xmlAbre(nFile)
       xmlCabecStyle(nFile,"Cabec")
       xmlFechaStyles(nfile)
       xmlAbrePasta(nFile,left(FABRICA->Razao,15))

       xmlAbreLinha(nFile)
         xmlCell(nFile,"String","","Cabec")
         xmlCell(nFile,"String","","Cabec")
         xmlCell(nFile,"String","ORDER NO.: "+WAREHOUS->Codigo,"Cabec")
       xmlFechaLinha(nFile)

       nCONT := 1
       do while  nCONT <= len(asPED)

           PROD->(dbseek(asPED[nCONT,2]))
           
           xmlAbreLinha(nFile)
             xmlCell(nFile,"String",PROD->Cod_ass)
             xmlCell(nFile,"String",PROD->cod_fabr)
             xmlCell(nFile,"String",PROD->descricao)
             xmlCell(nFile,"String",transf(asPED[nCont,3],"@R 999999999"))
           xmlFechaLinha(nFile)

           nCONT++
           if nCONT > len(asPED)
              nCONT := len(asPED)
              exit
           endif

           if asPED[nCONT,1] != cFABR
              cFABR := asPED[nCONT,1]
              FABRICA->(dbseek(cFABR))

              xmlFechaPasta(nFile)
              xmlAbrePasta(nFile,left(FABRICA->Razao,15))

              xmlAbreLinha(nFile)
                xmlCell(nFile,"String","","Cabec")
                xmlCell(nFile,"String","","Cabec")
                xmlCell(nFile,"String","ORDER NO.: "+WAREHOUS->Codigo,"Cabec")
              xmlFechaLinha(nFile)

          endif
       enddo
       XmlFechaPasta(nFile)
       XmlFecha(nFile)
       alert("Arquivo warehouse.xml gerado com sucesso.")


   endif

   qstopprn()

return

static function xmlAbre(nfile)
local cXml := ""

	cXml := '<?xml version="1.0"?>'+chr(13)+chr(10)
	cXml += '<?mso-application progid="Excel.Sheet"?>'+chr(13)+chr(10)
	cXml += '<Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet"'+chr(13)+chr(10)
	cXml += 'xmlns:o="urn:schemas-microsoft-com:office:office"'+chr(13)+chr(10)
	cXml += 'xmlns:x="urn:schemas-microsoft-com:office:excel"'+chr(13)+chr(10)
	cXml += 'xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"'+chr(13)+chr(10)
	cXml += 'xmlns:html="http://www.w3.org/TR/REC-html40">'+chr(13)+chr(10)
   fWrite(nFile,cXml,len(cXml))
   cXml := ""
   cXml := '<DocumentProperties xmlns="urn:schemas-microsoft-com:office:office">'+chr(13)+chr(10)
   cXml += '<Author>Sistema Compras - Relatorio 525</Author>'+chr(13)+chr(10)
   cXml += '<LastAuthor>Sistema Compras - Relatorio 525</LastAuthor>'+chr(13)+chr(10)
   cXml += '<Created>'+ strzero(year(date()),4)+'-'+strzero(month(date()),2)+'-'+strzero(day(date()),2)+'T01:29:55Z</Created>'+chr(13)+chr(10)
   cXml += '<Company>EPB Informatica Ltda</Company>'+chr(13)+chr(10)
   cXml += '<Version>11.9999</Version>'+chr(13)+chr(10)
   cXml += '</DocumentProperties>'+chr(13)+chr(10)
   fWrite(nFile,cXml,len(cXml))
   cXml := ""
   cXml := '<ExcelWorkbook xmlns="urn:schemas-microsoft-com:office:excel">'+chr(13)+chr(10)
   cXml += '<WindowHeight>9240</WindowHeight>'+chr(13)+chr(10)
   cXml += '<WindowWidth>18195</WindowWidth>'+chr(13)+chr(10)
   cXml += '<WindowTopX>480</WindowTopX>'+chr(13)+chr(10)
   cXml += '<WindowTopY>120</WindowTopY>'+chr(13)+chr(10)
   cXml += '<ProtectStructure>False</ProtectStructure>'  +chr(13)+chr(10)
   cXml += '<ProtectWindows>False</ProtectWindows>'+chr(13)+chr(10)
   cXml += '</ExcelWorkbook>'+chr(13)+chr(10)
   cXml += '<Styles>'+chr(13)+chr(10)
   cXml += '<Style ss:ID="Default" ss:Name="Normal">'+chr(13)+chr(10)
   cXml += '<Alignment ss:Vertical="Bottom"/>'+chr(13)+chr(10)
   cXml += '<Borders/>'+chr(13)+chr(10)
   cXml += '<Font/>'+chr(13)+chr(10)
   cXml += '<Interior/>'+chr(13)+chr(10)
   cXml += '<NumberFormat/>'+chr(13)+chr(10)
   cXml += '<Protection/>'+chr(13)+chr(10)
   cXml += '</Style>'+chr(13)+chr(10)
   fWrite(nFile,cXml,len(cXml))

return

static function xmlAbrePasta(nFile,cNome)
local cXml := ""

    cXml := '<Worksheet ss:Name="'+cNome+'">'+chr(13)+chr(10)
    cXml += '<Table>'+chr(13)+chr(10)
    fwrite(nFile,cXml,len(cXml))

return

static function xmlFechaPasta(nFile,cNome)
local cXml := ""

    cXml := '</Table>'+chr(13)+chr(10)
    cXml += '</Worksheet>'+chr(13)+chr(10)
    fwrite(nFile,cXml,len(cXml))

return

static function xmlFecha(nFile)
local cXml := ""

    cXml := '</Workbook>'+chr(13)+chr(10)
    fwrite(nFile,cXml,len(cXml))
    fClose(nFile)
    
return

static function xmlAbreLinha(nFile)
local cXml := ""

	 cXml := '<Row>'+chr(13)+chr(10)
	 fwrite(nFile,cXml,len(cXml))
return

static function xmlFechaLinha(nFile)
local cXml := ""

	 cXml := '</Row>' +chr(13)+chr(10)
	 fwrite(nFile,cXml,len(cXml))
return

static function xmlFechaStyles(nFile)
local cXml := ""

	 cXml := '</Styles>' +chr(13)+chr(10)
	 fwrite(nFile,cXml,len(cXml))
return

static function xmlCell(nFile,cTipo,cValor,cStyleID)
local cXml := ""
	 if cStyleID == NIL
	    cXml := '<Cell><Data ss:Type="'+cTipo+'">'+cValor+'</Data></Cell>'+chr(13)+chr(10)
	 else
	    cXml := '<Cell ss:StyleID="'+cStyleID+'"><Data ss:Type="'+cTipo+'">'+cValor+'</Data></Cell>'+chr(13)+chr(10)
	 endif   
	 fwrite(nFile,cXml,len(cXml))
return

static function xmlCabecStyle(nFile,cNome)
local cXml := ""
	 cXml := '<Style ss:ID="Cabec">'+chr(13)+chr(10)
	 cXml += '<Alignment ss:Horizontal="Center" ss:Vertical="Center"/>'+chr(13)+chr(10)
	 cXml += '<Borders>'+chr(13)+chr(10)
	 cXml += '<Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
	 cXml += '<Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
	 cXml += '<Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
	 cXml += '<Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
	 cXml += '</Borders>'+chr(13)+chr(10)
         cXml += '<Font ss:Size="12" ss:Bold="0"/>'+chr(13)+chr(10)
	 cXml += '<Interior ss:Color="#AAAAAA" ss:Pattern="Solid"/>'+chr(13)+chr(10)
	 cXMl += '</Style>'+chr(13)+chr(10)
	 fwrite(nFile,cXml,len(cXml))
	 cXml := ""
	 cXml := '<Style ss:ID="par">'+chr(13)+chr(10)
	 cXml += '<Alignment ss:Vertical="Bottom"/>'+chr(13)+chr(10)
    cXml += '<Borders/>'+chr(13)+chr(10)
    cXml += '<Font/>'+chr(13)+chr(10)
    cXml += '<Interior ss:Color="#DDDDDD" ss:Pattern="Solid"/>'+chr(13)+chr(10)
    cXml += '<NumberFormat/>'+chr(13)+chr(10)
    cXml += '<Protection/>'+chr(13)+chr(10)
    cXMl += '</Style>'+chr(13)+chr(10)
	 fwrite(nFile,cXml,len(cXml))
	 cXml := ""
	 cXml := '<Style ss:ID="total">'+chr(13)+chr(10)
	 cXml += '<Alignment ss:Vertical="Bottom"/>'+chr(13)+chr(10)
    cXml += '<Borders/>'+chr(13)+chr(10)
    cXml += '<Font ss:Bold="1"/>'+chr(13)+chr(10)
    cXml += '<Interior/>'+chr(13)+chr(10)
    cXml += '<NumberFormat/>'+chr(13)+chr(10)
    cXml += '<Protection/>'+chr(13)+chr(10)
    cXMl += '</Style>'+chr(13)+chr(10)
	 fwrite(nFile,cXml,len(cXml))
return



