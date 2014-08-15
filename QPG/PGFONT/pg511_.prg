/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE CONTAS RECEBER
// OBJETIVO...: CONSULTA POSICAO SUMARIA DA CARTEIRA
// ANALISTA...:
// PROGRAMADOR:
// INICIO.....: MAIO DE 1997
// OBS........:
// ALTERACOES.:
function pg511

#define percent(X,Y) (100.0 * X/Y)
local cPICT1 := "@E 99,999,999.99"
local cPICT2 := "@E 999.99"
local dDATASYS := date()

local nTOT_VENC := nVENC_05 := nVENC_0615 := nVENC_1630 := nVENC_3145 := nVENC_4660 := nVENC_6190 := nVENC_90 := ;
      nTOT_AVEN := nAVEN_05 := nAVEN_0615 := nAVEN_1630 := nAVEN_3145 := nAVEN_4660 := nAVEN_6190 := nAVEN_90 := 0



   if ! qinitprn(); return .F. ; endif

   if ! qlineprn(); return .F. ; endif

   qpageprn()

   qcabecprn("Posicao Sumaria da Carteira",80)


PAGAR->(Dbsetorder(2))
PAGAR->(Dbgotop())

do while ! PAGAR->(eof())

   if PAGAR->Data_venc <= dDATASYS

      qmensa("Aguarde...")

      // vencidos

      do case

         case PAGAR->Data_venc >= (dDATASYS - 90) .and. PAGAR->Data_venc <= (dDATASYS - 61)
              nVENC_6190 += PAGAR->Valor

         case PAGAR->Data_venc >= (dDATASYS - 60) .and. PAGAR->Data_venc <= (dDATASYS - 46)
              nVENC_4660 += PAGAR->Valor

         case PAGAR->Data_venc >= (dDATASYS - 45) .and. PAGAR->Data_venc <= (dDATASYS - 31)
              nVENC_3145 += PAGAR->Valor

         case PAGAR->Data_venc >= (dDATASYS - 30) .and. PAGAR->Data_venc <= (dDATASYS - 16)
              nVENC_1630 += PAGAR->Valor

         case PAGAR->Data_venc >= (dDATASYS - 15)  .and. PAGAR->Data_venc <= (dDATASYS - 6)
              nVENC_0615 += PAGAR->Valor

         case PAGAR->Data_venc >= (dDATASYS - 5)
              nVENC_05 += PAGAR->Valor

         otherwise
              nVENC_90 += PAGAR->Valor
      endcase

   else

      do case
         case PAGAR->Data_venc >= (dDATASYS + 61) .and. PAGAR->Data_venc <= (dDATASYS + 90)
              nAVEN_6190 += PAGAR->Valor

         case PAGAR->Data_venc >= (dDATASYS + 46) .and. PAGAR->Data_venc <= (dDATASYS + 60)
              nAVEN_4660 += PAGAR->Valor

         case PAGAR->Data_venc >= (dDATASYS + 31) .and. PAGAR->Data_venc <= (dDATASYS + 45)
              nAVEN_3145 += PAGAR->Valor

         case PAGAR->Data_venc >= (dDATASYS + 16) .and. PAGAR->Data_venc <= (dDATASYS + 30)
              nAVEN_1630 += PAGAR->Valor

         case PAGAR->Data_venc >= (dDATASYS + 6)  .and. PAGAR->Data_venc <= (dDATASYS + 15)
              nAVEN_0615 += PAGAR->Valor

         case PAGAR->Data_venc <= (dDATASYS + 5)
              nAVEN_05 += PAGAR->Valor

         otherwise
              nAVEN_90 += PAGAR->Valor
      endcase

   endif

   PAGAR->(Dbskip())

enddo

nTOT_VENC := nVENC_05 + nVENC_0615 + nVENC_1630 + nVENC_3145 + nVENC_4660 + nVENC_6190 + nVENC_90
nTOT_AVEN := nAVEN_05 + nAVEN_0615 + nAVEN_1630 + nAVEN_3145 + nAVEN_4660 + nAVEN_6190 + nAVEN_90

XNIVEL := 1

setcolor("W/B")

@ prow()+1,0  say XCOND1 + "Intervalo "
@ prow()  ,35 say "Vencidos "
@ prow()  ,45 say "Perc % "

@ prow()  ,70 say "a Vencer"
@ prow()  ,80 say "Perc % "

@ prow()+1,00 say replicate("-",134)


@ prow()+1,0  say "Ate 5 Dias.: "
@ prow()  ,30 say transform(nVENC_05, cPICT1 )
@ prow()  ,45 say transform( percent(nVENC_05,nTOT_VENC),cPICT2)
@ prow()  ,65 say transform(nAVEN_05, cPICT1 )
@ prow()  ,80 say transform( percent(nAVEN_05,nTOT_AVEN),cPICT2)

@ prow()+1,0  say "De 6 a 15 Dias.: "
@ prow()  ,30  say transform(nVENC_0615, cPICT1 )
@ prow()  ,45 say transform( percent(nVENC_0615,nTOT_VENC),cPICT2)
@ prow()  ,65 say transform(nAVEN_0615, cPICT1 )
@ prow()  ,80 say transform( percent(nAVEN_0615,nTOT_AVEN),cPICT2)

@ prow()+1,0  say "De 16 a 30 Dias.: "
@ prow()  ,30 say transform(nVENC_1630, cPICT1 )
@ prow()  ,45 say transform( percent(nVENC_1630,nTOT_VENC),cPICT2)
@ prow()  ,65 say transform(nAVEN_1630, cPICT1 )
@ prow()  ,80 say transform( percent(nAVEN_1630,nTOT_AVEN),cPICT2)

@ prow()+1,0  say "De 31 a 45 Dias.: "
@ prow()  ,30  say transform(nVENC_3145, cPICT1 )
@ prow()  ,45 say transform( percent(nVENC_3145,nTOT_VENC),cPICT2)
@ prow()  ,65 say transform(nAVEN_3145, cPICT1 )
@ prow()  ,80 say transform( percent(nAVEN_3145,nTOT_AVEN),cPICT2)

@ prow()+1,0  say "De 46 a 60 Dias.: "
@ prow()  ,30  say transform(nVENC_4660, cPICT1 )
@ prow()  ,45 say transform( percent(nVENC_4660,nTOT_VENC),cPICT2)
@ prow()  ,65 say transform(nAVEN_4660, cPICT1 )
@ prow()  ,80 say transform( percent(nAVEN_4660,nTOT_AVEN),cPICT2)


@ prow()+1,0  say "De 61 a 90 Dias.: "
@ prow()  ,30  say transform(nVENC_6190, cPICT1 )
@ prow()  ,45 say transform( percent(nVENC_6190,nTOT_VENC),cPICT2)
@ prow()  ,65 say transform(nAVEN_6190, cPICT1 )
@ prow()  ,80 say transform( percent(nAVEN_6190,nTOT_AVEN),cPICT2)

@ prow()+1,0  say "Mais de 90 Dias.: "
@ prow()  ,30  say transform(nVENC_90, cPICT1 )
@ prow()  ,45 say transform( percent(nVENC_90,nTOT_VENC),cPICT2)
@ prow()  ,65 say transform(nAVEN_90, cPICT1 )
@ prow()  ,80 say transform( percent(nAVEN_90,nTOT_AVEN),cPICT2)

@ prow()+1,00 say replicate("-",134)
@ prow()+1,00 say "Totais.: "
@ prow()  ,30 say transform( nTOT_VENC,cPICT1)
@ prow()  ,65 say transform( nTOT_AVEN,cPICT1)

@ prow()+1,00 say replicate("-",134)
@ prow()+1,00 say "Total Geral.: "
@ prow()  ,65 say transform( nTOT_AVEN+nTOT_VENC,cPICT1)

qstopprn()

return
