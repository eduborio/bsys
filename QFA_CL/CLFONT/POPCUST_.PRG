/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: FATURAMENTO
// OBJETIVO...: Populate no arquivo ITEN_FAT com o preco de custo do periodo de cada venda
// ANALISTA...: EDUARDO BORIO
// PROGRAMADOR: O MESMO
// INICIO.....: ABRIL DE 2007
// OBS........:
// ALTERACOES.:

function popcust
local nCONT  := 0
local nVALOR := 0
local nALIQ  := 0
local nDESC  := 0
local dINI   := ctod("01/01/1995")

if ! qconf("Confirma POPULATE em ITENS ?")
   return .F.
endif


nCONT  := 0
nVALOR := 0
nALIQ  := 0
nDESC  := 0

FAT->(dbsetorder(1))
FAT->(dbgotop())


Do while ! ITEN_FAT->(Eof())

   if FAT->(Dbseek(ITEN_FAT->Num_fat)) .and. ITEN_FAT->(qrlock())
      replace ITEN_FAT->Data       with FAT->Dt_emissao
      Qunlock()
   endif

   PROD->(Dbseek(ITEN_FAT->Cod_prod))

   ITEN_FAT->(Dbskip())
enddo



ITEN_FAT->(Dbsetorder(3))
ITEN_FAT->(Dbgotop())

PROD->(Dbsetorder(4))
PROD->(Dbgotop())


do while ! CUSTO->(eof())

   if ! empty(CUSTO->Data_ini)
      dINI := CUSTO->Data_ini
   endif



   ITEN_FAT->(Dbgotop())
   if ITEN_FAT->(Dbseek(CUSTO->Cod_prod))
      Do while ! ITEN_FAT->(Eof()) .and. ITEN_FAT->Cod_prod == CUSTO->Cod_prod

         if ITEN_FAT->Data >= dINI .and. ITEN_FAT->Data <= CUSTO->Data_fim
             if CUSTO->Cod_prod == "00202"
                qmensa("Entrou")
                qinkey(0)
             endif


            if ITEN_FAT->(Qrlock())
               if CUSTO->Preco_cust  > 0
                  replace ITEN_FAT->Preco_cust with CUSTO->Preco_cust
               else
                 if PROD->(Dbseek(CUSTO->Cod_prod))
                    replace ITEN_FAT->Preco_cust with PROD->Preco_cust
                 endif
                 if CUSTO->Cod_prod == "00202"
                    qmensa("0000")
                    qinkey(0)
                 endif

               endif

               ITEN_FAT->(Qunlock())
            endif
         else
            qmensa(left(Prod->Descricao,8)+"  "+CUSTO->Cod_prod+"  "+ITEN_FAT->Cod_prod+" "+ dtoc(CUSTO->Data_ini)+ " " + dtoc(CUSTO->Data_fim) + " "+dtoc(ITEN_FAT->Data) )
            if CUSTO->Cod_prod == "00202"
               qinkey(0)
            endif
         endif

         ITEN_FAT->(Dbskip())

      enddo
   endif

   qgirabarra()
   qmensa(CUSTO->Cod_prod + " "+dtoc(CUSTO->Data_ini)+" "+dtoc(CUSTO->Data_fim))

   CUSTO->(dbskip())

enddo

return
