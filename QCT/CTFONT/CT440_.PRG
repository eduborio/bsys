/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO COMERCIO
// OBJETIVO...: Exportar arquivo p/ SPED Contabil
// ANALISTA...: EDUARDO AUGUSTO BORIO
// PROGRAMADOR: EDUARDO AUGUSTO BORIO
// INICIO.....: JULHO 2010
// OBS........:
// ALTERACOES.:


function ct440

private dData := ctod("")
private nDeb, nCre,nTot_deb, nTot_cre,nReg := 0

if qconf("Confirma acerto de Partidas Simples p/ SPED?")

   select LANC
   dbsetfilter({|| hp1 != "108" .and. (empty(Cont_db)  .or. empty(cont_cr) ) })
   LANC->(dbsetorder(1))
   dbgotop()

   dDATA :=  Data_lanc
   nDeb := nCre := nTot_deb := nTot_cre := 0

   QinitPrn()

   @ prow()+1,00     say "Data"
   @ prow()  ,pcol() say chr(9)+"Conta Debito"
   @ prow()  ,pcol() say chr(9)+"Conta Credito"
   @ prow()  ,pcol() say chr(9)+"Valor Debito"
   @ prow()  ,pcol() say chr(9)+"Valor Credito"
   @ prow()  ,pcol() say chr(9)+"Historico"


   do while ! eof()

      @ prow()+1,00     say dtoc(Data_lanc)
      @ prow()  ,pcol() say chr(9)+Cont_db
      @ prow()  ,pcol() say chr(9)+Cont_cr

      if ! empty(Cont_db)
         @ prow()  ,pcol() say chr(9)+transf(Valor,"@E 999,999,999.99")+chr(9)
      else
         @ prow()  ,pcol() say chr(9)+chr(9)+transf(Valor,"@E 999,999,999.99")
      endif

      @ prow()  ,pcol() say chr(9)+rtrim(Hist_comp)
      @ prow()  ,pcol() say chr(9)+num_lanc
      @ prow()  ,pcol() say chr(9)+no_partida

      if !empty(Cont_db)
         nDeb     += Valor
         nTot_Deb += Valor
      endif

      if !empty(Cont_cr)
         nCre     += Valor
         nTot_Cre += Valor
      endif

      nReg++


      dbskip()

      if Data_lanc != dData
         @ prow()+1,00     say "Total"
         @ prow()  ,pcol() say chr(9)
         @ prow()  ,pcol() say chr(9)
         @ prow()  ,pcol() say chr(9)+transf(nDeb,"@E 999,999,999.99")
         @ prow()  ,pcol() say chr(9)+transf(nCre,"@E 999,999,999.99")
         @ prow()+1,00     say ""
         nCre := nDeb := 0
         dData := Data_lanc
      endif


   enddo

   if dData != Data_lanc
      @ prow()+1,00     say "Total"
      @ prow()  ,pcol() say chr(9)
      @ prow()  ,pcol() say chr(9)
      @ prow()  ,pcol() say chr(9)+transf(nDeb,"@E 999,999,999.99")
      @ prow()  ,pcol() say chr(9)+transf(nCre,"@E 999,999,999.99")
      @ prow()+1,00     say ""
      nCre := nDeb := 0
      dData := Data_lanc
   endif


   @ prow()+1,00     say "Total Geral"
   @ prow()  ,pcol() say chr(9)
   @ prow()  ,pcol() say chr(9)
   @ prow()  ,pcol() say chr(9)+transf(ntot_Deb,"@E 999,999,999.99")
   @ prow()  ,pcol() say chr(9)+transf(nTot_Cre,"@E 999,999,999.99")
   @ prow()  ,pcol() say chr(9)+"Registros .: "+transf(nReg,"@R 999999")
   @ prow()+1,00     say ""


   qstopPrn(.F.)


endif




return




