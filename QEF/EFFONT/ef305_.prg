/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: ESCRITA FISCAL
// OBJETIVO...: CONSULTA DE NOTAS DE ISS (SERVICOS)
// ANALISTA...:
// PROGRAMADOR: LUCINEIDE VILAR POSSEBOM
// INICIO.....: SETEMBRO DE 1998
// OBS........:
// ALTERACOES.:
function ef305

#include "inkey.ch"

private lVOLTA

// CONFIGURACOES _________________________________________________________________

if ! quse(XDRV_EF,"CONFIG") ; return ; endif
// private nPERC_SLP := CONFIG->Perc_slp
CONFIG->(dbclosearea())

// MANUTENCAO DAS NOTAS DE ISS (SERVICOS)____________________________________

ISS->(dbseek(XANOMES))

ISS->(qview({{"Data_Lanc/Data Lan‡.",2},;
             {"Num_Nf/Nota Fiscal"  ,1},;
             {"Serie/S‚rie"         ,0},;
             {"transform(Vlr_Cont,'@E 999,999,999.99')/Valor Cont.",0},;
             {"transform(Iss_Vlr ,'@E 999,999.99'    )/Valor ISS"  ,0},;
             {"Filial/Filial"     ,3}},"P",;
             {NIL,"i_305a",NIL,NIL},;
             NIL,"<ESC>-Sai/<C>onsulta"))

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function i_305a
   local nCURSOR := setcursor(1)
   parameters cOPCAO

   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO == "C"
      if !XTIPOEMP $ "6790"     // COMERCIO E PRESTACAO DE SERVICOS
         qmensa("Empresa n„o Configurada como Prest. de Servi‡os Utilize Op‡„o <802> !","B")
         return .F.
      endif

      qlbloc(6,1,"B305A","QBLOC.GLO",1)

      i_edicao()

      MUNICIP->(dbSetFilter())
   endif
   setcursor(nCURSOR)
return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA ____________________________________

static function i_edicao

   local lCONF
   local aEDICAO := {}
   local bESCAPE := {||empty(fDATA_LANC).or.(XNIVEL==1.and.!XFLAG).or.;
                       (XNIVEL==1.and.lastkey()==27)}

   local sBLOC1 := qlbloc("B305B","QBLOC.GLO") // especie

   // VARIAVEIS TEMPORARIAS PARA LANCAMENTO DE NOTA FISCAL NA INCLUSAO ______

   private dTEMP_LANC
   private cTEMP_SERIE
   private cTEMP_DESC
   private cTEMP_DATA

   private nNOTAS  := 0          // PARA VERIFICAR SE JA FOI LANCADA UMA NOTA

// MONTA DADOS NA TELA ______________________________________________________

   if cOPCAO == "C"
      XNIVEL := 1

      qrsay ( XNIVEL++ , ISS->Filial                   ) ; FILIAL->(dbseek(ISS->Filial))
      qrsay ( XNIVEL++ , left(FILIAL->Razao,40)        )

      qrsay ( XNIVEL++ , ISS->Municip                 ) ; MUNICIP->(dbseek(ISS->Municip)) ; CGM->(dbseek(MUNICIP->Cgm))
      qrsay ( XNIVEL++ , left(CGM->Municipio,28)+"/"+CGM->Estado )

      qrsay ( XNIVEL++ , ISS->Data_lanc     , "@D"               )
      qrsay ( XNIVEL++ , ISS->Num_nf        , "@R 99999999"      )
      qrsay ( XNIVEL++ , ISS->Serie                              ) ;SERIE->(dbseek(ISS->Serie ))
      qrsay ( XNIVEL++ , qabrev(ISS->Especie, "ABCDEFG",{"Nota Fiscal","Luz","Telefone","Telex","Transportes","CMR(Maq.Reg.)","N.F.F."}))
      qrsay ( XNIVEL++ , ISS->Data_Emis     , "@D"               )
      qrsay ( XNIVEL++ , ISS->Num_Ult_Nf    , "@R 99999999"      )
      qrsay ( XNIVEL++ , ISS->Tipo          , "@R 99"            )
      qrsay ( XNIVEL++ , ISS->Subtipo       , "@R 9999"          )
      qrsay ( XNIVEL++ , ISS->Cod_Serv      , "@R 9999"          ) ;SERV->(dbseek(ISS->Cod_Serv))
      qrsay ( XNIVEL++ , SERV->Descricao                         )
      qrsay ( XNIVEL++ , ISS->Vlr_Cont      , "@E 999,999,999.99")
      qrsay ( XNIVEL++ , ISS->Vlr_Merc      , "@E 999,999,999.99")
      qrsay ( XNIVEL++ , ISS->Iss_Base      , "@E 999,999,999.99")
      qrsay ( XNIVEL++ , ISS->Iss_aliq      , "@R 99.99"         )
      qrsay ( XNIVEL++ , ISS->Iss_Vlr       , "@E 999,999,999.99")
//    qrsay ( XNIVEL++ , ISS->Perc_slp      , "@E 99.99"         )
      qrsay ( XNIVEL++ , ISS->Obs           , "@!"               )

      qwait()

   endif

return
