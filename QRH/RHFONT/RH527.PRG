/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: FOLHA DE PAGAMENTO
// OBJETIVO...: NOTAS E MOEDAS PARA PAGAMENTO EM DINHEIRO
// ANALISTA...: CARLOS EDUARDO RABELLO NUNES
// PROGRAMADOR: O MESMO
// INICIO.....: FEVEREIRO DE 1997
// OBS........:
// ALTERACOES.:

#define K_MAX_LIN 52

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG) .or. empty(cTIPOREL)}

private sBLOCO1 := qlbloc("B501B","QBLOC.GLO") // tipo de relatorio
private sBLOCO2 := qlbloc("B523B","QBLOC.GLO") // SUBTOT (nao/centro/filial)

private aNOTAS1 := array(11)   // vetor com quant. de notas e moedas (SUBTOT)
private aNOTAS2 := array(11)   // vetor com quant. de notas e moedas (TOTAL)
private cTIPOREL               // tipo de relatorio (mensal ou 13o.)
private aEDICAO := {}          // vetor para os campos de entrada de dados
//private cANOMES := qanomes(XDATASYS)
private cANOMES := qanomes(CONFIG->Data_atual)
private cTIPO

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qesco(-1,0,@cTIPOREL,sBLOCO1)}    , "TIPOREL"   })

do while .T.

   qlbloc(5,0,"B527A","QBLOC.GLO")
   XNIVEL   := 1
   XFLAG    := .T.
   cTIPOREL := " "

   // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; dbcloseall() ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   i_inicializacao()

enddo

/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA _____________________________________________

static function i_critica ( cCAMPO )
   do case
      case cCAMPO == "TIPOREL"
           qrsay(XNIVEL,qabrev(cTIPOREL,"MAD",{"Mes Corrente","Adiantamento","Decimo Terceiro"}))
   endcase
return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // SELECIONA ORDEM DO ARQUIVO CADFUN _____________________________________

   qmensa()

   // ESTABELECE RELACOES ENTRE ARQUIVOS ____________________________________

   cTIPOREL := qabrev(cTIPOREL,"MAD",{"MS","AD","DT"})

   afill(aNOTAS1,0)
   afill(aNOTAS2,0)

   abre_001()
   i_impressao()
   FUN->(Dbclosearea())
   BASE->(Dbclosearea())
   abre_002()
   i_impressao()
   FUN->(Dbclosearea())
   BASE->(Dbclosearea())
   i_imp_final()

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impressao

   local nCONT, cMACROP, cMACROD

// afill(aNOTAS1,0)
// afill(aNOTAS2,0)

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   do while ! FUN->(eof())

      qgirabarra()

//    if FUN->Data_adm > qfimmes(XDATASYS) .or. FUN->Situacao $ "DH"
      if FUN->Situacao <> "T"
         FUN->(dbskip())
         loop
      endif
      
      cMACROP := "BASE->Prov_" + cTIPOREL
      cMACROD := "BASE->Desc_" + cTIPOREL

      cTIPO := "GERAL "

//    if FUN->(eof())
//       if ! EMPTY(cCTRL)
//          @ prow()+1,1      say iif(cSUBTOT=="C",transform(cCTRL,"@R 99.99.9999"),iif(cSUBTOT=="F",cCTRL+space(6),cCTRL))
//          @ prow(),pcol()+2 say transform(aNOTAS1[11],"@E 99,999,999.99")
//          for nCONT := 1 to 10
//              @ prow(),pcol()+1 say aNOTAS1[nCONT] picture "9999"
//          next
//       endif
//       cCTRL := FUN->(&cMACRO.)
//       afill(aNOTAS1,0)
//       if FUN->(eof()) ; exit ; endif
//    endif

      if FUN->Situacao $ "T"   // revisar no futuro
         i_calc_notas(&cMACROP.-&cMACROD.)
      endif

      FUN->(dbskip())

   enddo

return

/////////////////////////////////////////////////////////////
function i_imp_final

   if ! qinitprn() ; return ; endif

   if ! qlineprn() ; return ; endif

   if XPAGINA == 0 .or. prow() > K_MAX_LIN
      qpageprn()
      qcabecprn("RELACAO DE NOTAS E MOEDAS",80)
      @ prow()+1,0 say cTIPO + "               TOTAL  100   50   10    5    1  ,50  ,25  ,10  ,05  ,01"
      @ prow()+1,0 say replicate("-",80)
      @ prow()+1,0 say ""
   endif

   @ prow()+2,13 say transform(aNOTAS2[11],"@E 99,999,999.99")

   for nCONT := 1 to 10
       @ prow(),pcol()+1 say aNOTAS2[nCONT] picture "9999"
   next

   qstopprn()

return

/////////////////////////////////////////////////////////////////////////////
// CALCULO DAS NOTAS E ATUALIZACAO DOS VETORES ANOTAS1 E ANOTAS2 ____________

static function i_calc_notas ( nVALOR )
   local nCONT, nTMP, aVAL := {100,50,10,5,1,.50,.25,.10,.05,.01}

   aNOTAS1[11] += nVALOR
   aNOTAS2[11] += nVALOR

   for nCONT := 1 to 10
       nVALOR := nVALOR / aVAL[nCONT]
       nTMP   := int(val(str(nVALOR)))
       nVALOR := (nVALOR - nTMP) * aVAL[nCONT]
       aNOTAS1[nCONT] += nTMP
       aNOTAS2[nCONT] += nTMP
   next

return

/////////////////////////////////////////////////////
// FUNCAO UTILIZADA PARA ABRIR AQUIVOS DA EMP 001 ___
function abre_001

   if ! quse("\QSYS_G\QRH\E001\","FUN",{"FU_MATRI","FU_NOME","FU_FDMAT","FU_FDNOM","FU_FILMA","FU_FILNO","FU_CENMA","FU_CENNO","FU_MTASS","FU_MTASS","FU_GRPS"})
      qmensa("N„o foi poss¡vel abrir arquivo FUN.DBF na empresa 001 !! Tente novamente.")
      return .F.
   endif

   if ! quse("\QSYS_G\QRH\E001\","BASE",{"BA_MATRI"})
      qmensa("N„o foi poss¡vel abrir arquivo BASE.DBF da empresa 001 !! Tente novamente.")
      return .F.
   endif

   select FUN
   set relation to Matricula+cANOMES into BASE

   FUN->(dbgotop())

return

/////////////////////////////////////////////////////
// FUNCAO UTILIZADA PARA ABRIR AQUIVOS DA EMP 002 ___
function abre_002

   if ! quse("\QSYS_G\QRH\E002\","FUN",{"FU_MATRI","FU_NOME","FU_FDMAT","FU_FDNOM","FU_FILMA","FU_FILNO","FU_CENMA","FU_CENNO","FU_MTASS","FU_MTASS","FU_GRPS"})
      qmensa("N„o foi poss¡vel abrir arquivo FUN.DBF na empresa 001 !! Tente novamente.")
      return .F.
   endif

   if ! quse("\QSYS_G\QRH\E002\","BASE",{"BA_MATRI"})
      qmensa("N„o foi poss¡vel abrir arquivo BASE.DBF da empresa 001 !! Tente novamente.")
      return .F.
   endif

   select FUN
   set relation to Matricula+cANOMES into BASE

   FUN->(dbgotop())

return
