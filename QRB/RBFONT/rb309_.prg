/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE CONTAS RECEBER
// OBJETIVO...: CONSULTA POSICAO SUMARIA DA CARTEIRA
// ANALISTA...:
// PROGRAMADOR:
// INICIO.....: MAIO DE 1997
// OBS........:
// ALTERACOES.:

function rb309
#define percent(X,Y) (100.0 * X/Y)

local cPICT1 := "@E 9999999,999.99"
local cPICT2 := "@E 999.9999"
local dDATASYS := date()

local nTOT_VENC := nVENC_05 := nVENC_0615 := nVENC_1630 := nVENC_3145 := nVENC_4660 := nVENC_6190 := nVENC_90 := ;
      nTOT_AVEN := nAVEN_05 := nAVEN_0615 := nAVEN_1630 := nAVEN_3145 := nAVEN_4660 := nAVEN_6190 := nAVEN_90 := 0

RECEBER->(Dbsetorder(2))
RECEBER->(Dbgotop())

do while ! RECEBER->(eof())

   if RECEBER->Data_venc <= dDATASYS

      qmensa("Aguarde...")

      // vencidos

      do case

         case RECEBER->Data_venc >= (dDATASYS - 90) .and. RECEBER->Data_venc <= (dDATASYS - 61)
              nVENC_6190 += RECEBER->Valor

         case RECEBER->Data_venc >= (dDATASYS - 60) .and. RECEBER->Data_venc <= (dDATASYS - 46)
              nVENC_4660 += RECEBER->Valor

         case RECEBER->Data_venc >= (dDATASYS - 45) .and. RECEBER->Data_venc <= (dDATASYS - 31)
              nVENC_3145 += RECEBER->Valor

         case RECEBER->Data_venc >= (dDATASYS - 30) .and. RECEBER->Data_venc <= (dDATASYS - 16)
              nVENC_1630 += RECEBER->Valor

         case RECEBER->Data_venc >= (dDATASYS - 15)  .and. RECEBER->Data_venc <= (dDATASYS - 6)
              nVENC_0615 += RECEBER->Valor

         case RECEBER->Data_venc >= (dDATASYS - 5)
              nVENC_05 += RECEBER->Valor

         otherwise
              nVENC_90 += RECEBER->Valor
      endcase

   else

      do case
         case RECEBER->Data_venc >= (dDATASYS + 61) .and. RECEBER->Data_venc <= (dDATASYS + 90)
              nAVEN_6190 += RECEBER->Valor

         case RECEBER->Data_venc >= (dDATASYS + 46) .and. RECEBER->Data_venc <= (dDATASYS + 60)
              nAVEN_4660 += RECEBER->Valor

         case RECEBER->Data_venc >= (dDATASYS + 31) .and. RECEBER->Data_venc <= (dDATASYS + 45)
              nAVEN_3145 += RECEBER->Valor

         case RECEBER->Data_venc >= (dDATASYS + 16) .and. RECEBER->Data_venc <= (dDATASYS + 30)
              nAVEN_1630 += RECEBER->Valor

         case RECEBER->Data_venc >= (dDATASYS + 6)  .and. RECEBER->Data_venc <= (dDATASYS + 15)
              nAVEN_0615 += RECEBER->Valor

         case RECEBER->Data_venc <= (dDATASYS + 5)
              nAVEN_05 += RECEBER->Valor

         otherwise
              nAVEN_90 += RECEBER->Valor
      endcase

   endif

   RECEBER->(Dbskip())

enddo

nTOT_VENC := nVENC_05 + nVENC_0615 + nVENC_1630 + nVENC_3145 + nVENC_4660 + nVENC_6190 + nVENC_90
nTOT_AVEN := nAVEN_05 + nAVEN_0615 + nAVEN_1630 + nAVEN_3145 + nAVEN_4660 + nAVEN_6190 + nAVEN_90

XNIVEL := 1

setcolor("W/B")

qrsay(XNIVEL++,transform(nVENC_05, cPICT1 ))
qrsay(XNIVEL++,transform( percent(nVENC_05,nTOT_VENC),cPICT2))
qrsay(XNIVEL++,transform(nAVEN_05, cPICT1 ))
qrsay(XNIVEL++,transform( percent(nAVEN_05,nTOT_AVEN),cPICT2))

qrsay(XNIVEL++,transform(nVENC_0615, cPICT1 ))
qrsay(XNIVEL++,transform( percent(nVENC_0615,nTOT_VENC),cPICT2))
qrsay(XNIVEL++,transform(nAVEN_0615, cPICT1 ))
qrsay(XNIVEL++,transform( percent(nAVEN_0615,nTOT_AVEN),cPICT2))

qrsay(XNIVEL++,transform(nVENC_1630, cPICT1 ))
qrsay(XNIVEL++,transform( percent(nVENC_1630,nTOT_VENC),cPICT2))
qrsay(XNIVEL++,transform(nAVEN_1630, cPICT1 ))
qrsay(XNIVEL++,transform( percent(nAVEN_1630,nTOT_AVEN),cPICT2))

qrsay(XNIVEL++,transform(nVENC_3145, cPICT1 ))
qrsay(XNIVEL++,transform( percent(nVENC_3145,nTOT_VENC),cPICT2))
qrsay(XNIVEL++,transform(nAVEN_3145, cPICT1 ))
qrsay(XNIVEL++,transform( percent(nAVEN_3145,nTOT_AVEN),cPICT2))

qrsay(XNIVEL++,transform(nVENC_4660, cPICT1 ))
qrsay(XNIVEL++,transform( percent(nVENC_4660,nTOT_VENC),cPICT2))
qrsay(XNIVEL++,transform(nAVEN_4660, cPICT1 ))
qrsay(XNIVEL++,transform( percent(nAVEN_4660,nTOT_AVEN),cPICT2))

qrsay(XNIVEL++,transform(nVENC_6190, cPICT1 ))
qrsay(XNIVEL++,transform( percent(nVENC_6190,nTOT_VENC),cPICT2))
qrsay(XNIVEL++,transform(nAVEN_6190, cPICT1 ))
qrsay(XNIVEL++,transform( percent(nAVEN_6190,nTOT_AVEN),cPICT2))

qrsay(XNIVEL++,transform(nVENC_90, cPICT1 ))
qrsay(XNIVEL++,transform( percent(nVENC_90,nTOT_VENC),cPICT2))
qrsay(XNIVEL++,transform(nAVEN_90, cPICT1 ))
qrsay(XNIVEL++,transform( percent(nAVEN_90,nTOT_AVEN),cPICT2))

qrsay(XNIVEL++,transform( nTOT_VENC,cPICT1))
qrsay(XNIVEL++,transform( nTOT_AVEN,cPICT1))

qrsay(XNIVEL++,transform( nTOT_AVEN+nTOT_VENC,cPICT1))

qwait()

return
