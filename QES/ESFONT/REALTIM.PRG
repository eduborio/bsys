/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE ESTOQUE
// OBJETIVO...: INTERFACE COM COMPRAS
// ANALISTA...: LUCINEIDE VILAR POSSEBOM
// PROGRAMADOR: A MESMA
// INICIO.....: 20/05/97
// OBS........:

//////////////////////////////////////////////////////////////////////////////
// ABERTURA DE ARQUIVOS NECESSARIOS PARA INTERFACE __________________________

function realtime

private nVLRMERC := nISSBASE := nISSVLR := 0 , XNIVEL, sTELA

// ARQUIVO SH_CPEST DO COMPRAS EM MODO EXCLUSIVO _____________________________

if ! quse(XDRV_CP,"SH_CPEST",NIL,"E")
   qmensa("N„o foi poss¡vel abrir arquivo SH_CPEST.DBF !! Tente novamente.")
   return
endif

if ! quse(XDRV_ES,"MOVIMENT",{"MOV_PRDT","MOV_PROD","MOVI_DAT","MOV_TIPO","MOV_FILP","MOV_FILI"})
   qmensa("N„o foi poss¡vel abrir arquivo MOVIMENT.DBF !! Tente novamente.")
   return
endif

if ! quse(XDRV_CP,"PROD",{"PR_CODIG","PR_DESCR","PR_CODAS","PR_CODRD","PR_FABR","PR_REDUZ","PR_CDESC"})
   qmensa("N„o foi poss¡vel abrir arquivo PRODUTOS.DBF !! Tente novamente.")
   return
endif

if ! quse(XDRV_CP,"INVENT",{"INVE_FPR","INVE_DAT","INVE_FIL","INVE_PRO"})
   qmensa("N„o foi poss¡vel abrir arquivo INVENT.DBF !! Tente novamente.")
   return
endif

if ! quse(XDRV_CP,"LOTES",{"LOTES1","LOTES2","LOTES3"})
   qmensa("N„o foi poss¡vel abrir arquivo LOTES.DBF !! Tente novamente.")
   return
endif

SH_CPEST->(__dbPack())

// CARREGA BLOCO REALTIME.RRB _______________________________________________

sTELA := qsbloc(05,00,23,79)

//////////////////////////////////////////////////////////////////////////////
// EXECUTA INTERFACE ________________________________________________________

do while ! SH_CPEST->(eof())

   qlbloc(5,0,"BREAL","QBLOC.GLO")

 PROD->(Dbsetorder(4))

   if MOVIMENT->(qappend())

      replace MOVIMENT->Data       with SH_CPEST->Data
      replace MOVIMENT->Filial     with SH_CPEST->Filial
      replace MOVIMENT->Cod_prod   with SH_CPEST->Cod_prod
      replace MOVIMENT->Quantidade with SH_CPEST->Quantidade
      replace MOVIMENT->Val_uni    with SH_CPEST->Val_uni
      replace MOVIMENT->Lote       with SH_CPEST->Lote
      replace MOVIMENT->Tipo       with SH_CPEST->Tipo
      replace MOVIMENT->Saldo_ant  with SH_CPEST->Saldo_ant
      replace MOVIMENT->Obs        with SH_CPEST->Obs
      replace MOVIMENT->Contabil   with .T.

      XNIVEL := 1

      qrsay(XNIVEL++,dtoc(SH_CPEST->Data))
      qrsay(XNIVEL++,SH_CPEST->Filial)
      qrsay(XNIVEL++,SH_CPEST->Cod_prod)
      qrsay(XNIVEL++,transform(SH_CPEST->Quantidade,"@e 9,999.99999"))
      qrsay(XNIVEL++,transform(SH_CPEST->Val_uni, "@e 999,999.99"))
      qrsay(XNIVEL++,SH_CPEST->Tipo)

      SH_CPEST->(dbdelete())

      MOVIMENT->(qunlock())

   endif

   SH_CPEST->(dbskip())

enddo

SH_CPEST->(__dbPack())

SH_CPEST->(dbunlock())
MOVIMENT->(dbunlock())
LOTES->(dbunlock())

SH_CPEST->(dbclosearea())
MOVIMENT->(dbclosearea())
LOTES->(dbclosearea())

// PROD->(dbclosearea())

PROD->(dbclosearea())
INVENT->(dbclosearea())

qrbloc(5,0,sTELA)
return
