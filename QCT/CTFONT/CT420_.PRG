/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO COMERCIO
// OBJETIVO...: Exportar arquivo p/ Software Dominio - (Clari Agua Mineral)
// ANALISTA...: EDUARDO AUGUSTO BORIO
// PROGRAMADOR: EDUARDO AUGUSTO BORIO
// INICIO.....: JUNHO 2009
// OBS........:
// ALTERACOES.:

function ct420

#define K_MAX_LIN 57
#include "fileio.ch"

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG) .or. lastkey() == 27 }

private cTITULO                   // titulo do relatorio
private dINI
private dFIM
private cICMS   := space(7)
private cIPI    := space(7)
private cEMP    := space(7)
private cTIPO   := space(2)
private cDRIVE  := space(2)
private cSISTEMA:= space(2)
private cDEB    := "DB01"
private cCRE    := "CR01"
private nSALDANT := 0
private nSALDATU := 0
private sBLOC1  := qlbloc("B420B","QBLOC.GLO")
private sBLOC2  := qlbloc("BDRIVES","QBLOC.GLO")

if ! quse(XDRV_CT,"SINCO",NIL,"E")
   qmensa("N„o foi poss¡vel abrir arquivo DOMINIO.DBF !! Tente novamente.")
   return
endif

SINCO->(__dbzap())

private aEDICAO := {}             // vetor para os campos de entrada de dados

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qgetx(-1,0,@dINI)            } , "INI"    })
aadd(aEDICAO,{{ || qgetx(-1,0,@dFIM)            } , "FIM"    })
aadd(aEDICAO,{{ || qesco(-1,0,@cTIPO,sBLOC1)    } , "TIPO" })
aadd(aEDICAO,{{ || qesco(-1,0,@cDRIVE,sBLOC2)   } , "DRIVE"})


aadd(aEDICAO,{{ || lCONF := qconf("Confirma Exportacao de Arquivo Sinco Contabil ?") },NIL})



do while .T.

   qlbloc(5,0,"B420A","QBLOC.GLO")
   XNIVEL := 1
   XFLAG  := .T.
   dINI    := ctod("")
   dFIM    := ctod("")
   cICMS   := space(7)
   cIPI    := space(7)
   cEMP    := space(7)
   cTIPO   := space(2)
   cSISTEMA:= space(2)
   cDRIVE := ""

   // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; dbcloseall() ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   if ( i_inicializacao() , i_gravacao() , NIL )

   qmensa("")

enddo

/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA _____________________________________________

static function i_critica ( cCAMPO )

   do case

      case cCAMPO == "INI"
           dFIM := qfimmes(dINI)
           qrsay(XNIVEL+1,dtoc(dFIM))

      case cCAMPO == "FIM"
           if dFIM < dINI
             qmensa("Data Final nÆo pode ser Inferior a Data Inicial !","B")
             return .F.
             qmensa("")
           endif

      case cCAMPO == "TIPO"
           if empty(cTIPO) ;  return .F. ; Endif
           qrsay(XNIVEL,qabrev(cTIPO,"12",{"1 - Entrada","2 - Saida"}))

   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // CRIA TITULO DO RELATORIO ______________________________________________


   cTITULO := ""

   qmensa("")

return .T.


static function i_gravacao
   local   cSINCO :=  ""

   cSINCO := ""

   do case
      case cDRIVE == "A"
           cDRIVE := "A:"

      case cDRIVE == "C"
           cDRIVE := "C:\"

      case cDRIVE == "D"
           cDRIVE := "D:\"

      case cDRIVE == "E"
           cDRIVE := "E:\"

      case cDRIVE == "F"
           cDRIVE := "F:\"

      case cDRIVE == "G"
           cDRIVE := "C:\Windows\Desktop\"

      case cDRIVE == "H"
           cDRIVE := "C:\Docume~1\AllUse~1\Desktop\"

      case cDRIVE == "I"
           cDRIVE := "C:\users\AllUse~1\Desktop\"

   endcase

   do case
      case cTIPO == "1"
           i_Plano()
      case cTIPO == "2"
           i_Diario()
      case cTIPO == "3"
           i_Balancete()
   endcase


//      cNOMARQ := cDRIVE+"Entradas.TxT"
//      geraTxT(cNomArq)
//   else
//      i_saidas()
//      cNOMARQ := cDRIVE+"Saidas.TxT"
//      geraTxT(cNomArq)
//
//   endif

   qmensa("Operacao Concluida!","BL")

return


static function i_Plano
local cSINCO := ""
local cNOMEARQ  := ""
local cNOMEARQ2 := ""

   PLAN->(dbsetorder(1))
   PLAN->(dbgotop())

   do while ! PLAN->(eof())

      cSINCO := qdata_sinco(ctod("01/01/"+CONFIG->Exercicio))
      cSINCO += PLAN->Codigo+PLAN->Reduzido+space(10)
      cSINCO += iif(len(alltrim(PLAN->codigo)) < 12,"S","A")
      cSINCO += searchSuperior(PLAN->Codigo) + space(16)
      cSINCO += PLAN->Descricao+space(5)

      SINCO->(qappend())
      SINCO->Linha := cSINCO
      cSINCO := ""

      PLAN->(dbskip())
   enddo

   cNOMEARQ := cDRIVE+"Plano.TxT"
//   cNOMEARQ2 := cDRIVE+"Plano2.TxT"


//   SINCO->(__dbSDF( .T., CNOMEARQ , { },,,,, .F. ) )
   geraTxt(cNOMEARQ,1)
//   readFile(cNOMEARQ2)

   if SINCO->(qflock())
      SINCO->(__dbzap())
   endif

return

static function i_Diario
local cSINCO := ""
local cNOMEARQ  := ""
local cHIST := ""
local nRESTO := 0

  PLAN->(dbsetorder(3))

  LANC->(dbgotop())
  do while ! LANC->(eof())

     if ! empty(LANC->Cont_cr)
        cSINCO := qdata_sinco(LANC->Data_lanc);  PLAN->(dbseek(LANC->Cont_cr))
        cSINCO += PLAN->Codigo+PLAN->Reduzido+space(10)
        cSINCO += space(28)

        if ! empty(LANC->cont_db)
           PLAN->(dbseek(LANC->Cont_db))
           cSINCO += PLAN->Codigo + PLAN->Reduzido+space(10)
        else
           cSINCO += space(28)
        endif

        cSINCO += i_valida(LANC->Valor,17)

        cSINCO += "C"

        cSINCO += strzero(val(LANC->Num_lanc),12)
        cSINCO += strzero(val(LANC->Num_lanc),12)

        HIST->(dbseek(LANC->Hp1)) ; cHIST += alltrim(HIST->Descricao) + " "
        HIST->(dbseek(LANC->Hp2)) ; cHIST += alltrim(HIST->Descricao) + " "
        HIST->(dbseek(LANC->Hp3)) ; cHIST += alltrim(HIST->Descricao) + " "

        cHIST += LANC->Hist_comp

        nRESTO := len(cHIST)

        cSINCO += left(cHIST,150)

        SINCO->(qappend())
        SINCO->Linha := cSINCO
        cSINCO := ""
     endif

     if ! empty(LANC->Cont_db)
        cSINCO := qdata_sinco(LANC->Data_lanc);  PLAN->(dbseek(LANC->Cont_db))
        cSINCO += PLAN->Codigo+PLAN->Reduzido+space(10)
        cSINCO += space(28)

        if ! empty(LANC->cont_cr)
           PLAN->(dbseek(LANC->Cont_cr))
           cSINCO += PLAN->Codigo + PLAN->Reduzido + space(10)
        else
           cSINCO += space(28)
        endif

        cSINCO += i_valida(LANC->Valor,17)

        cSINCO += "D"

        cSINCO += strzero(val(LANC->Num_lanc),12)
        cSINCO += strzero(val(LANC->Num_lanc),12)

        HIST->(dbseek(LANC->Hp1)) ; cHIST := alltrim(HIST->Descricao) + " "
        HIST->(dbseek(LANC->Hp2)) ; cHIST += alltrim(HIST->Descricao) + " "
        HIST->(dbseek(LANC->Hp3)) ; cHIST += alltrim(HIST->Descricao) + " "

        cHIST += LANC->Hist_comp

        nRESTO := len(cHIST)

        cSINCO += left(cHIST,150)

        SINCO->(qappend())
        SINCO->Linha := cSINCO
        cSINCO := ""
     endif



     qmensa("Lancamento.: "+LANC->Num_lanc)
     if LANC->Valor < 0.01
        qinkey(0)
     endif


     LANC->(dbskip())
  enddo

  cNOMEARQ := cDRIVE+"Diario.TxT"

  geraTXT(cNOMEARQ,2)

  if SINCO->(qflock())
     SINCO->(__dbzap())
  endif




return

static function i_balancete
  local cSINCO   := ""
  local cNOMEARQ := ""
  local nCONT    := 1

  do while ! PLAN->(eof())


     if len(alltrim(PLAN->Codigo)) < 12
        PLAN->(dbskip())
        loop
     endif

     //i_puxasaldo(12)

     if ! i_temMovimento() //nSALDANT = 0.00 .and. PLAN->&cDEB = 0.00 .and. PLAN->&cCRE = 0.00
        PLAN->(dbskip())
        loop
     endif


     for nCONT := 1 to 12

         i_puxasaldo(nCONT)

         cSINCO := qdata_sinco(ctod("01/"+strzero(nCONT,2)+"/"+CONFIG->Exercicio))
         cSINCO += PLAN->Codigo + PLAN->Reduzido + space(10)

         if nSALDANT < 0
            cSINCO += i_valida(nSALDANT*-1,17)
            cSINCO += "C"
         else
            cSINCO += i_valida(nSALDANT,17)
            cSINCO += "D"
         endif

         cSINCO += i_valida(PLAN->&cDEB,17)
         cSINCO += i_valida(PLAN->&cCRE,17)
         nSALDATU := nSALDANT + PLAN->&cDEB + PLAN->&cCRE

         if nSALDATU < 0
            cSINCO += i_valida(nSALDATU*-1,17)
            cSINCO += "C"
         else
            cSINCO += i_valida(nSALDATU,17)
            cSINCO += "D"
         endif

         SINCO->(qappend())
         SINCO->Linha := cSINCO
         cSINCO := ""


     next

     nSALDANT := 0
     nSALDATU := 0

     qmensa("Gerando Conta.: "+ct_convcod(PLAN->Codigo))

     PLAN->(dbskip())

  enddo

  cNOMEARQ := cDRIVE+"Saldos.TxT"

  geraTXT(cNOMEARQ,3)

  if SINCO->(qflock())
     SINCO->(__dbzap())
  endif



return


static Function i_valida(nVALOR,nNUM)
local cValor := ""
   cVALOR := strzero(val(qtiraponto(str(nVALOR,nNUM,2))),nNUM)
return cVALOR

static function qdata_sinco(dDATA)
 local dRET,cANO,cMES,cDIA
 cANO := strzero(year(dDATA),4)
 cMES := strzero(month(dDATA),2)
 cDIA := strzero(day(dDATA),2)
 dRET := cDIA +cMES + CONFIG->Exercicio
return  dRET

static function geraTxT(cDESTINO,cPlan)
local cTEXTO := ""

   set printer to (cDESTINO)
   set device to printer
   set margin to 0
   setprc(0,0)

   SINCO->(dbgotop())
   while ! SINCO->(eof())


          do case
             case cPlan == 1
                  if SINCO->(recno()) == 1
                      @ prow()  ,00 say left(SINCO->Linha,110)
                  else
                      @ prow()+1,00 say left(SINCO->Linha,110)
                  endif

             case cPlan == 2
                  if SINCO->(recno()) == 1
                      @ prow()  ,00 say left(SINCO->Linha,284)
                  else
                      @ prow()+1,00 say left(SINCO->Linha,284)
                  endif

             case cPlan == 3
                  if SINCO->(recno()) == 1
                      @ prow()  ,00 say left(SINCO->Linha,106)
                  else
                      @ prow()+1,00 say left(SINCO->Linha,106)
                  endif


         endcase
       SINCO->(dbskip())
   enddo
   @ prow(),pcol() say chr(13)+chr(10)
   set printer to
   set device to screen

return

static function searchSuperior(cCONTA)
  local cRESULT := ""
  local nREG := PLAN->(recno())

  do case
     case len(alltrim(cCONTA)) == 12
           PLAN->(dbseek(left(cCONTA,7)))
           cRESULT := PLAN->Codigo
           PLAN->(dbgoto(nREG))

     case len(alltrim(cCONTA)) == 7
           PLAN->(dbseek(left(cCONTA,5)))
           cRESULT := PLAN->Codigo
           PLAN->(dbgoto(nREG))

     case len(alltrim(cCONTA)) == 5
           PLAN->(dbseek(left(cCONTA,3)))
           cRESULT := PLAN->Codigo
           PLAN->(dbgoto(nREG))

     case len(alltrim(cCONTA)) == 3
           PLAN->(dbseek(left(cCONTA,1)))
           cRESULT := PLAN->Codigo
           PLAN->(dbgoto(nREG))

     case len(alltrim(cCONTA)) == 1
           cRESULT := space(12)
  endcase

return cRESULT

static function getDrive(cDR)
local cDRIVE := ""

   do case
      case cDR == "A"
           cDRIVE := "A:"

      case cDR == "C"
           cDRIVE := "C:\"

      case cDR == "D"
           cDRIVE := "D:\"

      case cDR == "E"
           cDRIVE := "E:\"

      case cDR == "F"
           cDRIVE := "F:\"

      case cDR == "G"
           cDRIVE := "C:\Windows\Desktop\"

      case cDR == "H"
           cDRIVE := "C:\Docume~1\AllUse~1\Desktop\"

      case cDR == "I"
           cDRIVE := "C:\users\AllUse~1\Desktop\"

   endcase
return cDRIVE


static function readFile(cFile)
local fileHnd := 0
local cBuffer := space(112)
local nTTLinhas := 0
local nLinha    := 1
local nSize := 0

  if file(cFile)
     fileHnd := fopen(cFile,2)
     if ferror() == 2
        qmensa("File not found!!","B")
        return .F.
     endif
  else
     qmensa("Nao achou!","B")
     return .F.
  endif

  clear

  nSize:= fseek(fileHnd,0,2)
  nTTLinhas := (nSize/112)
  @ 01,10 say str(nSize)+" bytes."
  @ 02,10 say str(nSize/112)+" Registros."


  qinkey(0)

  fseek(fileHnd,0)

  do while nLinha <= nTTLinhas

     if fRead(fileHnd,@cBuffer,112) <> 112
        qmensa("Erro de leitura!"+"Linha.: "+str(nLinha),"B")
        qinkey(0)
     else
        @ 10,10 say "Data..: "+ left(cBuffer,8)
        @ 11,10 say "Conta.: "+ substr(cBuffer,9,28)
        @ 12,10 say "Tipo..: "+ substr(cBuffer,37,1)
        @ 13,10 say "Super.: "+ substr(cBuffer,38,28)
        @ 14,10 say "Descr.: "+ substr(cBuffer,66,47)
     endif

     if nLinha >= 1800
        qinkey(0)
     endif

     nLinha++
  enddo

  fclose(fileHnd)

return

static function i_puxasaldo(nMES)

       local  nCONT

       nSALDANT := PLAN->Saldo_ant
       for nCONT = 1 to nMES
           cDEB := "DB"+strzero(nCONT,2)
           cCRE := "CR"+strzero(nCONT,2)
           if nCONT != nMES
              nSALDANT := nSALDANT + PLAN->&cDEB + PLAN->&cCRE
           endif
       next
return

static function i_temMovimento()
local cRESULT  := .F.
local nTotDeb  := 0
local nTotCred := 0

       local  nCONT

       for nCONT = 1 to 12
           cDEB := "DB"+strzero(nCONT,2)
           cCRE := "CR"+strzero(nCONT,2)
           //nSALDANT := nSALDANT + PLAN->&cDEB + PLAN->&cCRE
           nTotDeb  += PLAN->&cDEB
           nTotCred += PLAN->&cCRE
           //endif
       next

       if nTotDeb <> 0 .or. nTotCred <> 0
          cRESULT := .T.
       endif

return cRESULT



