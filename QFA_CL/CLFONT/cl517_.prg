/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO DA USIMIX
// OBJETIVO...: EMISSAO DE ETIQUETAS P/ MALA DIRETA
// ANALISTA...: LUIS ANTONIO ORLANDO PEREIRA
// PROGRAMADOR: LUIS ANTONIO ORLANDO PEREIRA
// INICIO.....: OUTUBRO DE 1995
// OBS........:
// ALTERACOES.:

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

function cl517
local   bESCAPE := {|| (XNIVEL==1 .and. !XFLAG) .or. lastkey()==27 }

private sBLOC1  := qlbloc("B501B","QBLOC.GLO") // Ordem Codigo ou Razao

private aEDICAO := {}    // vetor para os campos de entrada de dados
private cFILIAL          // Filial
private cSETOR           // Setor

CLI1->(Dbsetorder(4)) // codigo do cliente + codigo do setor

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || view_filial(-1,0,@cFILIAL)   } , "FILIAL" })
aadd(aEDICAO,{{ || NIL },NIL})           // descricao do Filial
aadd(aEDICAO,{{ || view_setor(-1,0,@cSETOR)     } , "SETOR"  })
aadd(aEDICAO,{{ || NIL },NIL})           // descricao do setor

do while .T.

   qlbloc(5,0,"B517A","QBLOC.GLO")

   XNIVEL  := 1
   XFLAG   := .T.
   cFILIAL := "    "
   cSETOR  := "     "

   // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; dbcloseall() ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ); loop   ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo
   if CONFIG->Modelo_fat =="4"
      i_impres_2()
   else
      i_impressao()
   endif
   qmensa("")

enddo

/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA _____________________________________________

static function i_critica ( cCAMPO )

   do case
      case cCAMPO == "FILIAL"
           if ! empty(cFILIAL)
              qrsay ( XNIVEL , cFILIAL := strzero(val(cFILIAL),4) )
              if FILIAL->(dbseek(cFILIAL))
                 qrsay(XNIVEL+1,left(FILIAL->Razao,40))
              else
                 qmensa("Filial n„o encontrada !","B")
                 return .F.
              endif
           else
             qrsay(XNIVEL+1,"Todas as Filiais...")
           endif

      case cCAMPO == "SETOR"
           if ! empty(cSETOR)
              qrsay ( XNIVEL , cSETOR := strzero(val(cSETOR),5) )
              if SETOR->(dbseek(cSETOR))
                 qrsay(XNIVEL+1,left(SETOR->Descricao,40))
              else
                 qmensa("Setor n„o encontrado !","B")
                 return .F.
              endif
           else
              qrsay(XNIVEL+1,"Todos os Setores...")
           endif

   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impressao

   local cLINHA1 := cLINHA2 := cLINHA3 := cLINHA4 := ""
   local nCONT := 0

   // VERIFICA SE QUER ALINHAMENTO __________________________________________

   do while alert("Quer realizar teste de alinhamento ",{"SIM","NŽO"}) == 1
      if ! qinitprn() ; return ; endif
      @ prow(),pcol() say XCOND1
      @ prow()+1,0 say padr("linha 1",58,".") + "   " + padr("linha 1",58,".") + "   " + padr("linha 1",58,".")
      @ prow()+1,0 say padr("linha 2",58,".") + "   " + padr("linha 2",58,".") + "   " + padr("linha 2",58,".")
      @ prow()+1,0 say padr("linha 3",58,".") + "   " + padr("linha 3",58,".") + "   " + padr("linha 3",58,".")
      @ prow()+1,0 say padr("linha 4",58,".") + "   " + padr("linha 4",58,".") + "   " + padr("linha 4",58,".")
      @ prow()+3,0 say ""
      qstopprn()
   enddo

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif

   @ prow(),pcol() say XCOND1

   CLI1->(dbgotop())

   do while ! CLI1->(eof())

      if  ! empty(cSETOR) .and. cSETOR <> CLI1->Cod_setor
          CLI1->(dbskip())
          loop
      endif

      qmensa(CLI1->Codigo)

      if ! qlineprn() ; exit ; endif

      if empty(cFILIAL) .or. cFILIAL == CLI1->Filial

         CGM->(dbseek(CLI1->Cgm_cob))
         cMUN_COB := left(CGM->Municipio,15) + " " + CGM->Estado

         cLINHA1 += padr("Razao: "+CLI1->Razao,72)
         cLINHA2 += padr("End: "+CLI1->End_cob,72)
         cLINHA3 += padr("Bairro: "+CLI1->Bairro_Cob,72)
         cLINHA4 += padr("Cep: "+transform(CLI1->Cep_cob,"@R 99.999-999")+" - "+alltrim(CGM->Municipio)+" - "+CGM->Estado,61)

         nCONT++

      endif

      CLI1->(dbskip())

      if nCONT == 2 .or. ( nCONT <> 0 .and. CLI1->(eof()) )

         @ prow()+1,0 say cLINHA1
         @ prow()+1,0 say cLINHA2
         @ prow()+1,0 say cLINHA3
         @ prow()+1,0 say cLINHA4
         @ prow()+2,0 say ""

         nCONT := 0
         cLINHA1 := cLINHA2 := cLINHA3 := cLINHA4 := ""

      endif

   enddo

   if nCONT == 2 .or. ( nCONT <> 0 .and. CLI1->(eof()) )

      @ prow()+1,0 say cLINHA1
      @ prow()+1,0 say cLINHA2
      @ prow()+1,0 say cLINHA3
      @ prow()+1,0 say cLINHA4
      @ prow()+2,0 say ""

      nCONT := 0
      cLINHA1 := cLINHA2 := cLINHA3 := cLINHA4 := ""

   endif


   qstopprn()

return

static function i_impres_2

   local cLINHA1 := cLINHA2 := cLINHA3 := cLINHA4 := ""
   local nCONT := 0

   // VERIFICA SE QUER ALINHAMENTO __________________________________________

   do while alert("Quer realizar teste de alinhamento ",{"SIM","NŽO"}) == 1
      if ! qinitprn() ; return ; endif
      @ prow(),pcol() say XCOND1
      @ prow()+1,0 say padr("linha 1",58,".") + "   " + padr("linha 1",58,".") + "   " + padr("linha 1",58,".")
      @ prow()+1,0 say padr("linha 2",58,".") + "   " + padr("linha 2",58,".") + "   " + padr("linha 2",58,".")
      @ prow()+1,0 say padr("linha 3",58,".") + "   " + padr("linha 3",58,".") + "   " + padr("linha 3",58,".")
      @ prow()+1,0 say padr("linha 4",58,".") + "   " + padr("linha 4",58,".") + "   " + padr("linha 4",58,".")
      @ prow()+3,0 say ""
      qstopprn()
   enddo

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif

   @ prow(),pcol() say XCOND1

   CLI1->(dbgotop())

   do while ! CLI1->(eof())

      if  ! empty(cSETOR) .and. cSETOR <> CLI1->Cod_setor
          CLI1->(dbskip())
          loop
      endif

      qmensa(CLI1->Codigo)

      if ! qlineprn() ; exit ; endif

      if empty(cFILIAL) .or. cFILIAL == CLI1->Filial

         CGM->(dbseek(CLI1->Cgm_cob))
         cMUN_COB := left(CGM->Municipio,15) + " " + CGM->Estado

         cLINHA1 += padr("Razao: "+CLI1->Razao,75)
         cLINHA2 += padr("End: "+CLI1->End_cob,75)
         cLINHA3 += padr("Bairro: "+CLI1->Bairro_Cob,75)
         cLINHA4 += padr("Cep: "+transform(CLI1->Cep_cob,"@R 99.999-999")+" - "+alltrim(CGM->Municipio)+" - "+CGM->Estado,75)

         nCONT++

      endif

      CLI1->(dbskip())

      if nCONT == 3 .or. ( nCONT <> 0 .and. CLI1->(eof()) )

         @ prow()+1,0 say cLINHA1
         @ prow()+1,0 say cLINHA2
         @ prow()+1,0 say cLINHA3
         @ prow()+1,0 say cLINHA4
         @ prow()+3,0 say ""

         nCONT := 0
         cLINHA1 := cLINHA2 := cLINHA3 := cLINHA4 := ""

      endif

   enddo

   if nCONT == 3 .or. ( nCONT <> 0 .and. CLI1->(eof()) )

      @ prow()+1,4 say cLINHA1
      @ prow()+1,4 say cLINHA2
      @ prow()+1,4 say cLINHA3
      @ prow()+1,4 say cLINHA4
      @ prow()+2,4 say ""

      nCONT := 0
      cLINHA1 := cLINHA2 := cLINHA3 := cLINHA4 := ""

   endif


   qstopprn()

return

