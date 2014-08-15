/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: Sistema DE Tesouraria
// OBJETIVO...: Gera Arquivos pra Tesouraria
// ANALISTA...: EDUARDO AUGUSTO BORIO
// PROGRAMADOR: EDUARDO AUGUSTO BORIO
// INICIO.....: Dezembro 2010
// OBS........:
// ALTERACOES.:


function ct450

private dData := ctod("")
private XDRV_HB := "C:\Qsystxt\"

if qconf("Confirma geracao de Movimento no sistema financeiro?")

   if ! quse(XDRV_TS,"RECEBIDO",{""},"RECEBIDO")
      qmensa("Nao foi possivel abrir Recebidos da Tesouraria!","BL")
      return .F.
   endif

   if ! quse(XDRV_TS,"MOV_CAIX",{""},"MOV_CAIX")
      qmensa("Nao foi possivel abrir Mov Caixa da Tesouraria!","BL")
      return .F.
   endif

   if ! quse(XDRV_TS,"SALD_CAI",{""},"SALD_CAI")
      qmensa("Nao foi possivel abrir Saldo de Caixa da Tesouraria!","BL")
      return .F.
   endif

   if ! quse(XDRV_TS,"MOV_BANC",{""},"E","MOV_BANC")
      qmensa("Nao foi possivel abrir Mov Banco da Tesouraria!","BL")
      return .F.
   endif

   if ! quse(XDRV_TS,"SALD_BAN",{""},"E","SALD_BAN")
      qmensa("Nao foi possivel abrir Saldo de Banco da Tesouraria!","BL")
      return .F.
   endif



   MOV_BANC->(__dbzap())
   SALD_BAN->(__dbzap())




//   processaCaixa()
//   geraSaldoCaixa()
     processaBB()
     geraSaldoBB()
//   processaReal()
//   geraSaldoReal()



     RECEBIDO->(dbclosearea())
     MOV_CAIX->(dbclosearea())
     MOV_BANC->(dbclosearea())
     SALD_CAI->(dbclosearea())
     SALD_BAN->(dbclosearea())


endif
return


static function processaCaixa

      RECEBIDO->(dbsetfilter({|| Recebido->Data_emiss >= ctod("01/01/2010")}))
      RECEBIDO->(dbsetorder(5))
      RECEBIDO->(dbgotop())

      LANC->(dbsetfilter({|| Cont_db == "000019" .or. Cont_cr == "000019"} ))
      LANC->(dbgotop())

      do while ! LANC->(eof())

         if LANC->Hp1 == "108"
            LANC->(dbskip())
            loop
         endif

         if MOV_CAIX->(qappend())

            replace MOV_CAIX->Data      with LANC->Data_lanc
            replace MOV_CAIX->Cod_banco with "99999"
            replace MOV_CAIX->Historico with LANC->Hist_comp

            if LANC->Cont_db == "000019"
               replace MOV_CAIX->Entrada with LANC->Valor
            endif

            if LANC->Cont_cr == "000019"
               replace MOV_CAIX->Saida   with LANC->Valor
            endif

            if !empty(LANC->Num_Lote)
               if LANC->cont_db == "000019"
                  if RECEBIDO->(dbseek(substr(LANC->Hist_comp,6,9)))
                     if RECEBIDO->(qrlock())
                        replace RECEBIDO->Tipo      with "5"
                        replace RECEBIDO->Cod_banco with "99999"
                        RECEBIDO->(qunlock())
                     endif
                     replace MOV_CAIX->Internal with "RE"+RECEBIDO->Codigo
                  endif
               endif
            endif
         endif

         LANC->(dbskip())
      enddo

      MOV_CAIX->(dbgotop())

      for dCont := ctod("01/01/2011") to ctod("22/03/2011")

          if ! MOV_CAIX->(dbseek(dCont))
             if MOV_CAIX->(qappend())
                replace MOV_CAIX->Data      with dCont
                replace MOV_CAIX->Historico with "Saldo"
             endif

          endif

      next



return

static function geraSaldoCaixa
local dData := ctod("01/01/2011")
local nSaldo := 0


    MOV_CAIX->(dbgotop())
    if SALD_CAI->(qappend())
       replace SALD_CAI->Data   with ctod("01/01/2011")
       replace SALD_CAI->Saldo  with 79.83
    endif

    nSaldo := 79.83

    do while ! MOV_CAIX->(eof())

       if MOV_CAIX->Entrada > 0
          nSaldo += MOV_CAIX->Entrada
       else
          nSaldo -= MOV_CAIX->Saida
       endif

       MOV_CAIX->(dbskip())

       if dData != MOV_CAIX->Data
          if SALD_CAI->(qappend())
             replace SALD_CAI->Data  with MOV_CAIX->Data
             replace SALD_CAI->Saldo with nSaldo
          endif
          dData := MOV_CAIX->Data
       endif

    enddo

return


static function processaBB
local dCont   := ctod("")
local aContas := {}
local nFile   := 0
local cConta  := ""
local cLinha  := ""
local nCont   := 0

      PLAN->(dbsetorder(3))

      RECEBIDO->(dbsetfilter({|| Recebido->Data_emiss >= ctod("01/01/2010")}))
      RECEBIDO->(dbsetorder(5))
      RECEBIDO->(dbgotop())

      LANC->(dbsetfilter({|| Cont_db == "000043" .or. Cont_cr == "000043"} ))
      LANC->(dbgotop())

      do while ! LANC->(eof())

         if LANC->Hp1 == "108"
            LANC->(dbskip())
            loop
         endif

         if MOV_BANC->(qappend())

            replace MOV_BANC->Data      with LANC->Data_lanc
            replace MOV_BANC->Cod_banco with "00016"
            replace MOV_BANC->Historico with LANC->Hist_comp

            if LANC->Cont_db == "000043"
               replace MOV_BANC->Entrada    with LANC->Valor
               if empty(LANC->Num_lote)
                  PLAN->(dbseek(LANC->Cont_cr))
                  if left(PLAN->Codigo,7) == "1010201" .or. left(PLAN->Codigo,7) == "2010502"
                     aadd(aContas,{LANC->Cont_cr,PLAN->Codigo,PLAN->Descricao,"DB BB",iif(left(PLAN->Codigo,7) == "1010201","Rec. Lan‡ado direto pela contabilidade","Adto de Cliente, Rec a maior ou Dev.")})
                  else
                     aadd(aContas,{LANC->Cont_cr,PLAN->Codigo,PLAN->Descricao,"DB BB",PLAN->Plan_fin})
                  endif
               endif

               if left(PLAN->Codigo,7) == "1010201" .or. left(PLAN->Codigo,7) == "2010502" //Adto de Clientes ou rececimento a maior. dev.
                  replace MOV_BANC->Conta_fin with "00014"
               else
                  replace MOV_BANC->Conta_fin with PLAN->Plan_fin
               endif

            endif

            if LANC->Cont_cr == "000043"
               replace MOV_BANC->Saida   with LANC->Valor
               PLAN->(dbseek(LANC->Cont_db))
               if left(PLAN->Codigo,7) == "2010502"
                  aadd(aContas,{LANC->cont_db,PLAN->Codigo,PLAN->Descricao,"CR BB","Devolucao!!"})
               else
                  aadd(aContas,{LANC->cont_db,PLAN->Codigo,PLAN->Descricao,"CR BB",PLAN->Plan_fin})
               endif

               if left(PLAN->Codigo,7) == "2010502"
                  replace MOV_BANC->Conta_fin with "00014"
               else
                  replace MOV_BANC->Conta_fin with PLAN->Plan_fin
               endif

            endif

            if !empty(LANC->Num_Lote)
               if LANC->cont_db == "000043"
                  if RECEBIDO->(dbseek(substr(LANC->Hist_comp,6,9)))
                     if RECEBIDO->(qrlock())
                        replace RECEBIDO->Tipo      with "4"
                        replace RECEBIDO->Cod_banco with "00016"
                        RECEBIDO->(qunlock())
                     endif
                     replace MOV_BANC->Internal with "RE"+RECEBIDO->Codigo
                     replace MOV_BANC->Conta_fin with "00014"
                  endif
               endif
            endif


         endif

         LANC->(dbskip())
      enddo

      MOV_BANC->(dbgotop())

      for dCont := ctod("01/01/2011") to ctod("22/03/2011")

          if ! MOV_BANC->(dbseek(dCont))
             if MOV_BANC->(qappend())
                replace MOV_BANC->Data      with dCont
                replace MOV_BANC->Cod_banco with "00016"
                replace MOV_BANC->Historico with "Saldo"
             endif

          endif

      next

     geraContasXml(aContas)



return

static function geraSaldoBB
local dData := ctod("01/01/2011")
local nSaldo := 0

    MOV_BANC->(dbgotop())
    if SALD_BAN->(qappend())
       replace SALD_BAN->Data      with ctod("01/01/2011")
       replace SALD_BAN->cod_banco with "00016"
       replace SALD_BAN->Saldo     with 77698.76
    endif

    nSaldo := 77698.76

    do while ! MOV_BANC->(eof())

       if MOV_BANC->Entrada > 0
          nSaldo += MOV_BANC->Entrada
       else
          nSaldo -= MOV_BANC->Saida
       endif

       MOV_BANC->(dbskip())

       if dData != MOV_BANC->Data
          if SALD_BAN->(qappend())
             replace SALD_BAN->Data      with MOV_BANC->Data
             replace SALD_BAN->Cod_banco with "00016"
             replace SALD_BAN->Saldo     with nSaldo
          endif
          dData := MOV_BANC->Data
       endif

    enddo




return


static function processaReal
local dCont := ctod("")


      RECEBIDO->(dbsetfilter({|| Recebido->Data_emiss >= ctod("01/01/2010")}))
      RECEBIDO->(dbsetorder(5))
      RECEBIDO->(dbgotop())

      LANC->(dbsetfilter({|| Cont_db == "009989" .or. Cont_cr == "009989"} ))
      LANC->(dbgotop())

      do while ! LANC->(eof())

         if LANC->Hp1 == "108"
            LANC->(dbskip())
            loop
         endif

         if MOV_BANC->(qappend())

            replace MOV_BANC->Data      with LANC->Data_lanc
            replace MOV_BANC->Cod_banco with "00018"
            replace MOV_BANC->Historico with LANC->Hist_comp

            if LANC->Cont_db == "009989"
               replace MOV_BANC->Entrada with LANC->Valor
            endif

            if LANC->Cont_cr == "009989"
               replace MOV_BANC->Saida   with LANC->Valor
            endif

            if !empty(LANC->Num_Lote)
               if LANC->cont_db == "009989"
                  if RECEBIDO->(dbseek(substr(LANC->Hist_comp,6,9)))
                     if RECEBIDO->(qrlock())
                        replace RECEBIDO->Tipo      with "4"
                        replace RECEBIDO->Cod_banco with "00018"
                        RECEBIDO->(qunlock())
                     endif
                     replace MOV_BANC->Internal with "RE"+RECEBIDO->Codigo
                  endif
               endif
            endif
         endif

         LANC->(dbskip())
      enddo

      MOV_BANC->(dbgotop())

      for dCont := ctod("01/01/2011") to ctod("22/03/2011")

          if ! MOV_BANC->(dbseek(dCont))
             if MOV_BANC->(qappend())
                replace MOV_BANC->Data      with dCont
                replace MOV_BANC->Cod_banco with "00018"
                replace MOV_BANC->Historico with "Saldo"
             endif

          endif

      next



return

static function geraSaldoReal
local dData := ctod("01/01/2011")
local nSaldo := 0

    MOV_BANC->(dbgotop())
    if SALD_BAN->(qappend())
       replace SALD_BAN->Data      with ctod("01/01/2011")
       replace SALD_BAN->cod_banco with "00018"
       replace SALD_BAN->Saldo     with 14967.22
    endif

    nSaldo := 14967.22

    do while ! MOV_BANC->(eof())

       if MOV_BANC->Entrada > 0
          nSaldo += MOV_BANC->Entrada
       else
          nSaldo -= MOV_BANC->Saida
       endif

       MOV_BANC->(dbskip())

       if dData != MOV_BANC->Data
          if SALD_BAN->(qappend())
             replace SALD_BAN->Data      with MOV_BANC->Data
             replace SALD_BAN->Cod_banco with "00018"
             replace SALD_BAN->Saldo     with nSaldo
          endif
          dData := MOV_BANC->Data
       endif

    enddo

return


static function geraContasXml(aContas)
local cLinha := cConta := cBugado := ""
local cTipo  := ""
local nFile := 0

       nFile := fCreate(XDRV_HB+"Contas.xls",0)

       //Ordena por Conta
       aContas := asort(aContas,,,{|x,y| x[1] < y[1] })


      nCONT  := 1
      cConta := aContas[1,1]
      cTipo  := aContas[1,4]
      cBugado := aContas[1,5]
      do while  nCONT <= len(aContas)

          //cConta := aContas[nCont,1]+chr(9)+aContas[nCont,2]+Chr(9)+aContas[nCont,3]+chr(13)+chr(10)

          //fwrite(nFile,cConta,len(cConta))

          nCONT++
          if nCONT > len(aContas)
             nCONT := len(aContas)
             exit
          endif

          if cConta != aContas[nCont,1]
             PLAN->(dbseek(cConta))
             cLinha := cConta+chr(9)+PLAN->codigo+Chr(9)+PLAN->Descricao+chr(9)+cTipo+chr(9)+cBugado+chr(13)+chr(10)
             fwrite(nFile,cLinha,len(cLinha))
             cConta := aContas[nCont,1]
             ctipo :=  acontas[ncont,4]
             cBugado := aContas[nCont,5]
          endif

      enddo

      PLAN->(dbseek(cConta))
      cLinha := cConta+chr(9)+PLAN->codigo+Chr(9)+PLAN->Descricao+chr(9)+cTipo+chr(9)+cBugado+chr(13)+chr(10)
      fwrite(nFile,cLinha,len(cLinha))
      cConta := aContas[nCont,1]


      fclose(nFile)


return






