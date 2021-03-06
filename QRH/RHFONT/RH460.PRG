/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: FOLHA DE PAGAMENTO
// OBJETIVO...: DIRF EM DISQUETE
// ANALISTA...: 
// PROGRAMADOR: O MESMO
// INICIO.....: MARCO DE 1997
// OBS........:
// ALTERACOES.:

#include "rh.ch"

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

private bESCAPE   := {||(XNIVEL==1 .and. !XFLAG) .or. lastkey() = 27}

private sBLOCO1   := qlbloc("B460D","QBLOC.GLO")
private sBLOCO2   := qlbloc("B460E","QBLOC.GLO")

private cANOBASE        // ano base para emissao
private aEDICAO1 := {}  // vetor para entrada de dados 1
private aEDICAO2 := {}  // vetor para entrada de dados 2
private aTOTMES  := {}  // vetor com totais por mes
private cDRIVE          // drive para gravacao
private cDIRF           // string de montagem de cada linha
private cDT             // string de montagem de cada linha
private nCONT           // contador auxiliar
private lCONF           // variavel de confirmacao

// ABRE ARQUIVO DIRF.DBF ____________________________________________________

if ! quse(XDRV_RHX,"DIRF",NIL,"E")
   qmensa("N�o foi poss�vel abrir arquivo DIRF.DBF !! Tente novamente.")
   return
endif

FILIAL->(dbsetorder(3))

FILIAL->(qview({{"left(Razao,50)/Filial",1},;
                {"Codigo/C�digo"        ,2}},"P",;
                {NIL,"f460a",NIL,NIL},;
                 NIL,"<ESC> Encerra / <A>ltera / <C>onsulta / <P>rocessa"))

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function f460a
   local nCURSOR := setcursor(1)

   parameters cOPCAO

   cOPCAO := upper(chr(cOPCAO))

   do case
      case cOPCAO $ "AC"
           qlbloc(5,0,"B460C","QBLOC.GLO",1)
           i_edicao()
      case cOPCAO == "P"
           i_processa()
   endcase

   setcursor(nCURSOR)

return ""

/////////////////////////////////////////////////////////////////////////////
// EDICAO DADOS DAS FILIAIS _________________________________________________

static function i_edicao
   local aEDICAO1 := {}

   FILIAL->(qpublicfields())
   FILIAL->(qinitfields())
   FILIAL->(qcopyfields())

   if(empty(fSEI),fSEI := "I",fSEI)

   XNIVEL := 1

   qsay(6,14,FILIAL->Codigo)
   qsay(6,21,left(FILIAL->Razao,44))
   qsay(8,21,qabrev(fTIPO_INSC,"12",{"CNPJ","CPF"}))
   qsay(8,51,fCGCCPF)
   qrsay(XNIVEL++,qabrev(fSEI,"SEI",{"Corre��o de Estabelecimento Rejeitado ou Substitui��o",;
                           "Exclus�o de Estabelecimento","Inclus�o de Estabelecimento"}))

   qrsay(XNIVEL++,FILIAL->Cpf_resp)
   qrsay(XNIVEL++,FILIAL->ult_recibo)
   qrsay(XNIVEL++,FILIAL->cpf_preenc)
   qrsay(XNIVEL++,FILIAL->Nome_resp)
   qrsay(XNIVEL++,FILIAL->ddd_resp)
   qrsay(XNIVEL++,FILIAL->tel_resp)
   qrsay(XNIVEL++,FILIAL->ramal_resp)
   qrsay(XNIVEL++,FILIAL->fax_resp)
   qrsay(XNIVEL++,FILIAL->email_resp)

   // CONSULTA _________________________________________________________________

   if cOPCAO == "C" ; qwait() ; return "" ; endif

   // CRIACAO DO VETOR DE BLOCOS _______________________________________________

   aadd(aEDICAO1,{{ || qesco(-1,0,@fSEI,SBLOCO2)},"SEI"})
   aadd(aEDICAO1,{{ || qgetx(-1,0,@fCPF_RESP,"99999999999")},"CPF_RESP"})
   aadd(aEDICAO1,{{ || qgetx(-1,0,@fULT_RECIBO,"999999999999")},"UTL_RECIBO"})
   aadd(aEDICAO1,{{ || qgetx(-1,0,@fCPF_PREENC,"99999999999")},"CPF_PREENC"})
   aadd(aEDICAO1,{{ || qgetx(-1,0,@fnome_resp,"@!")},"nome_resp"})
   aadd(aEDICAO1,{{ || qgetx(-1,0,@fddd_resp )},"ddd_resp"})
   aadd(aEDICAO1,{{ || qgetx(-1,0,@ftel_resp )},"tel_resp"})
   aadd(aEDICAO1,{{ || qgetx(-1,0,@framal_resp )},"ramal_resp"})
   aadd(aEDICAO1,{{ || qgetx(-1,0,@ffax_resp )},"fax_resp"})
   aadd(aEDICAO1,{{ || qgetx(-1,0,@femail_resp )},"email_resp"})
   
   // INICIALIZACAO DA EDICAO _______________________________________________

   XNIVEL := 1
   XFLAG  := .T.
   
   // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO1)
      eval ( aEDICAO1 [XNIVEL,1] )
      if eval ( bESCAPE ) ; FILIAL->(qreleasefields()) ; return "EXIT" ; endif
      if ! i_critica1( aEDICAO1[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO DA FILIAL ____________________________________________________

   if cOPCAO == "A"
      if FILIAL->(qrlock())
         FILIAL->(qreplacefields())
         FILIAL->(qunlock())
      else
         qm2()
      endif
   endif

return

/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA 1 ___________________________________________

static function i_critica1 ( cCAMPO )
   qmensa()
   do case
      case cCAMPO == "SEI"
           qrsay(XNIVEL,qabrev(fSEI,"SEI",{"Corre��o de Estabelecimento Rejeitado ou Substitui��o",;
                                       "Exclus�o de Estabelecimento","Inclus�o de Estabelecimento"}))
   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// INICIALIZACAO DO PROCESSO DE GERACAO DA RAIS EM DISQUETE ________________

static function i_processa
   local aEDICAO2 := {}

   // CRIACAO DO VETOR DE BLOCOS _______________________________________________

   aadd(aEDICAO2,{{ || qgetx(-1,0,@cANOBASE      )},"ANOBASE"})
   aadd(aEDICAO2,{{ || qesco(-1,0,@cDRIVE,SBLOCO1)},"DRIVE"  })
   aadd(aEDICAO2,{{ || lCONF := qconf("Confirma emiss�o da DIRF ?") },NIL})

   do while .T.

      qlbloc(5,0,"B460F","QBLOC.GLO")
      XNIVEL    := 1
      XFLAG     := .T.
      cRESP     := "   "
      cANOBASE  := "    "
      cDRIVE    := "A"

      // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

      do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO2)
         eval ( aEDICAO2 [XNIVEL,1] )
         if eval ( bESCAPE ) ; return ; endif
         if ! i_critica2( aEDICAO2[XNIVEL,2] ) ; loop ; endif
         iif ( XFLAG , XNIVEL++ , XNIVEL-- )
      enddo

      iif ( lCONF , i_gravacao() , NIL )

      FILIAL->(dbgotop())

   enddo

return ""

/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA _____________________________________________

static function i_critica2 ( cCAMPO )
   qmensa()
   do case
      case cCAMPO == "ANOBASE"
           qrsay(XNIVEL , cANOBASE)
      case cCAMPO == "DRIVE"
           qrsay(XNIVEL , qabrev(cDRIVE,"AB",{"A:","B:"}))
   endcase
return .T.

/////////////////////////////////////////////////////////////////////////////
// INICIALIZA PROCESSO DE GRAVACAO __________________________________________

static function i_gravacao
   local lCONF , nSEQ := 1 , cNOMARQ , cDIRF := ""
   local cDT := ""
   local nREND := nDEDU := nIRRF := nULT := nTOTREG := 0 , lPRIM := .T.
   local nTTBASE13 := nTTDEDU13 := nTTIRRF13 := 0 , lACHOUF := .F. , lACHOUE := .F.
   local nSOMA  := 0
   local nSOMAIR := 0
   local nINSS := nTTINSS := nPENSAO := nTTPENSAO := nDEPE := nTTDEPE := 0
   local nFile := 0
   local nMeses := 0
   local nMesAdmissao := 0

   DIRF->(__dbzap())

   qmensa("Aguarde...")

   FUN->(dbCreateIndex( XDRV_RH + "TMP", "Cpf_num", {|| Cpf_num}, if( .F., .T., NIL ) ))

   qmensa()

   //FUN->(dbSetFilter({|| ! empty(Filial)},"! empty(Filial)"))


      for nCONT = 1 to 12
          aadd ( aTOTMES, { 0 , 0 , 0 } )
      next

   qsay(16,28,FILIAL->Codigo)
   qsay(16,35,left(FILIAL->Razao,37))

   nFile := fcreate("C:\qsystxt\Dirf2014.txt",0)

   /////////////////////////////////////////////////////////
   //MONTA REGISTRO TIPO - IDENTIFICADOR DIRF

   cDIRF := "Dirf|"
   cDIRF += "2014|"
   cDIRF += "2013|"
   cDIRF += "N|"
   cDIRF += space(12)+"|"
   cDIRF += "F8UCL6S|"+chr(13)+chr(10)

   fwrite(nfile,cDirf,len(cDirf))

   cDirf:=""



   /////////////////////////////////////////////////////////
   //MONTA REGISTRO TIPO - RESPO

   cDIRF := "RESPO|"
   cDIRF += FILIAL->Cpf_preenc+"|"
   cDIRF += rtrim(FILIAL->nome_resp)+"|"
   cDIRF += "41|"
   cDIRF += rtrim(FILIAL->tel_resp)+"|"
   cDIRF += rtrim(FILIAL->Ramal_resp)+"|"
   cDIRF += alltrim(FILIAL->fax_resp)+"|"
   cDIRF += alltrim(FILIAL->email_resp)+"|"+chr(13)+chr(10)

   fwrite(nfile,cDirf,len(cDirf))

   cDirf:=""

   if FILIAL->Tipo_insc == "1"
      /////////////////////////////////////////////////////////
      //MONTA REGISTRO TIPO - DECPJ

      cDIRF := "DECPJ"+"|"
      cDIRF += FILIAL->Cgccpf+"|"
      cDIRF += rtrim(FILIAL->Razao)+"|"
      cDIRF += "0"+"|"
      cDIRF += qtiraponto(FILIAL->Cpf_resp)+"|"
      cDIRF += "N"+"|"
      cDIRF += "N"+"|"
      cDIRF += "N"+"|"
      cDIRF += "N"+"|"
      cDIRF += "N"+"|"
      cDIRF += "N"+"|"
	  cDIRF += "N"+"|"
      cDIRF += "|"+chr(13)+chr(10)

      fwrite(nfile,cDirf,len(cDirf))

      cDIRF := ""
    else

      /////////////////////////////////////////////////////////
      //MONTA REGISTRO TIPO - DECPJ

      cDIRF := "DECPF"+"|"
      cDIRF += qtiraponto(FILIAL->Cpf_resp)+"|"
      cDIRF += rtrim(FILIAL->Razao)+"|"
      cDIRF += "N"+"|"
      cDIRF += "N"+"|"
      cDIRF += "N"+"|"
      cDIRF += "N"+"|"
      cDIRF += space(8)+"| |"+chr(13)+chr(10)

      fwrite(nfile,cDirf,len(cDirf))

      cDIRF := ""

    endif


   /////////////////////////////////////////////////////////
   //MONTA REGISTRO TIPO - IDREC

   cDIRF := "IDREC" + "|"
   cDIRF += "0561"  + "|" +chr(13)+chr(10)

   fwrite(nfile,cDirf,len(cDirf))

   cDIRF := ""

   /////////////////////////////////////////////////////////
   //MONTA REGISTRO TIPO - BPFDEC

   FUN->(dbgotop())

   do while ! FUN->(eof())

      if year(FUN->Data_adm) > val(cANOBASE)
         FUN->(dbskip())
         loop
      endif

      nSoma := 0

      if BASE->(dbseek(FUN->Matricula+cANOBASE))
         do while ! BASE->(eof()) .and. BASE->Matricula == FUN->Matricula .and. left(BASE->Anomes,4) == cANOBASE
            nSoma += (BASE->Prov_ms + BASE->Prov_dt + BASE->Prov_fr)
            BASE->(dbskip())
         enddo
      endif

      if nSoma > 0

         /////////////////////////////////////////////////////////
         //MONTA REGISTRO TIPO - BPFDEC


         cDIRF := "BPFDEC"+"|"
         cDIRF += FUN->Cpf_num+"|"
         cDIRF += left(FUN->nome,60)+"|"
		 cDIRF += space(8)+"|"
         cDIRF += chr(13)+chr(10)
         fwrite(nfile,cDirf,len(cDirf))
         cDIRF := ""

         if year(FUN->Data_adm) == 2013
            nMesAdmissao := month(FUN->Data_adm)
         else
            nMesAdmissao := 1
         endif

         ///////////////////////////////////////////////////////
         // Monta Registro tipo RTRT____________________________

         BASE->(dbgotop())
         if BASE->(dbseek(FUN->Matricula+cANOBASE))
            cDIRF := "RTRT|"

            if nMesAdmissao > 1
               for nCONT := 1 to (nMesAdmissao -1)
                   cDIRF += replicate("0",13)+"|"
               next
            endif

            do while ! BASE->(eof()) .and. BASE->Matricula == FUN->Matricula .and. left(BASE->Anomes,4) == cANOBASE
               nULT  := val(right(BASE->Anomes,2))
               nREND := BASE->B_irrfms + BASE->B_irrffr + BASE->V_inssms + BASE->V_inssfr
               cDIRF += strzero(val(qtiraponto(str(nREND,11,2))),13)+"|"

               if BASE->B_inss13 > 0 .or. BASE->B_Inssdt > 0
                  nTTBASE13 := BASE->B_irrf13 + BASE->V_inss13 + BASE->D_irrf13 + BASE->B_irrfdt + BASE->V_inssdt + BASE->D_irrfdt
                  nTTIRRF13 := BASE->V_irrf13 + BASE->V_irrfdt
               endif

               BASE->(dbskip())
            enddo

             if nULT < 12
                for nMESES = (nULT + 1) to 12
                    cDIRF += replicate("0",13)+"|"
                next
             endif


             if nTTBASE13 > 0
                cDT :=  strzero(val(qtiraponto(str(nTTBASE13,11,2))),13)+"|"
             else
                cDT := repl("0",13)+"|"
             endif

             nTTBASE13 := 0
             nTTDEDU13 := 0
             nTTIRRF13 := 0

             cDIRF += cDT+chr(13)+chr(10)

             fwrite(nfile,cDirf,len(cDirf))
             cDIRF := ""
             cDT   := ""
         endif

         ///////////////////////////////////////////////////////
         // Monta Registro tipo RTPO____________________________

         BASE->(dbgotop())
         if BASE->(dbseek(FUN->Matricula+cANOBASE))
            cDIRF := "RTPO|"

            if nMesAdmissao > 1
               for nCONT := 1 to (nMesAdmissao -1)
                   cDIRF += replicate("0",13)+"|"
               next
            endif


            do while ! BASE->(eof()) .and. BASE->Matricula == FUN->Matricula .and. left(BASE->Anomes,4) == cANOBASE
               nULT  := val(right(BASE->Anomes,2))
               nREND := BASE->V_inssms + BASE->V_inssfr
               cDIRF += strzero(val(qtiraponto(str(nREND,11,2))),13)+"|"

               if BASE->V_inss13 > 0 .or. BASE->V_Inssdt > 0
                  nTTBASE13 := BASE->V_inss13 + BASE->V_inssdt
               endif

               BASE->(dbskip())
            enddo

             if nULT < 12
                for nMESES = (nULT + 1) to 12
                    cDIRF += replicate("0",13)+"|"
                next
             endif


             if nTTBASE13 > 0
                cDT :=  strzero(val(qtiraponto(str(nTTBASE13,11,2))),13)+"|"
             else
                cDT := repl("0",13)+"|"
             endif

             nTTBASE13 := 0
             nTTDEDU13 := 0
             nTTIRRF13 := 0

             cDIRF += cDT+chr(13)+chr(10)

             fwrite(nfile,cDirf,len(cDirf))
             cDIRF := ""
             cDT   := ""
         endif

         ///////////////////////////////////////////////////////
         // Monta Registro tipo RTDP____________________________

         BASE->(dbgotop())
         if BASE->(dbseek(FUN->Matricula+cANOBASE))
            cDIRF := "RTDP|"

            if nMesAdmissao > 1
               for nCONT := 1 to (nMesAdmissao -1)
                   cDIRF += replicate("0",13)+"|"
               next
            endif


            do while ! BASE->(eof()) .and. BASE->Matricula == FUN->Matricula .and. left(BASE->Anomes,4) == cANOBASE
               nULT  := val(right(BASE->Anomes,2))
               nREND := BASE->D_irrfms
               cDIRF += strzero(val(qtiraponto(str(nREND,11,2))),13)+"|"

               if BASE->V_inss13 > 0 .or. BASE->V_Inssdt > 0
                  nTTBASE13 := BASE->D_irrfms
               endif

               BASE->(dbskip())
            enddo

             if nULT < 12
                for nMESES = (nULT + 1) to 12
                    cDIRF += replicate("0",13)+"|"
                next
             endif


             if nTTBASE13 > 0
                cDT :=  strzero(val(qtiraponto(str(nTTBASE13,11,2))),13)+"|"
             else
                cDT := repl("0",13)+"|"
             endif

             nTTBASE13 := 0
             nTTDEDU13 := 0
             nTTIRRF13 := 0

             cDIRF += cDT+chr(13)+chr(10)

             fwrite(nfile,cDirf,len(cDirf))
             cDIRF := ""
             cDT   := ""
         endif

         ///////////////////////////////////////////////////////
         // Monta Registro tipo RTIRF____________________________

         BASE->(dbgotop())
         if BASE->(dbseek(FUN->Matricula+cANOBASE))
            cDIRF := "RTIRF|"

            if nMesAdmissao > 1
               for nCONT := 1 to (nMesAdmissao -1)
                   cDIRF += replicate("0",13)+"|"
               next
            endif


            do while ! BASE->(eof()) .and. BASE->Matricula == FUN->Matricula .and. left(BASE->Anomes,4) == cANOBASE
               nULT  := val(right(BASE->Anomes,2))
               nREND := BASE->V_irrfms + BASE->V_IrrfFr + BASE->V_irrfDt
               cDIRF += strzero(val(qtiraponto(str(nREND,11,2))),13)+"|"

               if BASE->V_inss13 > 0 .or. BASE->V_Inssdt > 0
                  nTTBASE13 := BASE->V_irrf13 + BASE->V_irrfDt
               endif

               BASE->(dbskip())
            enddo

             if nULT < 12
                for nMESES = (nULT + 1) to 12
                    cDIRF += replicate("0",13)+"|"
                next
             endif


             if nTTBASE13 > 0
                cDT :=  strzero(val(qtiraponto(str(nTTBASE13,11,2))),13)+"|"
             else
                cDT := repl("0",13)+"|"
             endif

             nTTBASE13 := 0
             nTTDEDU13 := 0
             nTTIRRF13 := 0

             cDIRF += cDT+chr(13)+chr(10)

             fwrite(nfile,cDirf,len(cDirf))
             cDIRF := ""
             cDT   := ""
         endif





      endif

      FUN->(dbskip())

   enddo

   cDIRF := "FIMDirf" +"|"+chr(13)+chr(10)
   fwrite(nfile,cDirf,len(cDirf))
   cDIRF := ""


   cDIRF := ""


   qsay(17,28,FUN->Matricula)
   qsay(17,37,left(FUN->Nome,30))


   
   // GRAVA ARQUIVO NO DISQUETE _____________________________________________

   qmensa("Gravando Arquivo...")

   fclose(nfile)

   qmensa()

return



static function oldStyle

//         do while ! BASE->(eof()) .and. BASE->Matricula == FUN->Matricula .and. left(BASE->Anomes,4) == cANOBASE
//            nULT  := val(right(BASE->Anomes,2))
//            nREND := BASE->B_irrfms + BASE->B_irrffr + BASE->V_inssms + BASE->V_inssfr
//            nDEDU := 0 //BASE->D_irrfms + BASE->V_inssms + BASE->V_inssfr
//            nIRRF := BASE->V_irrfms + BASE->V_irrffr + BASE->V_irrfdt
//
//            cDIRF += strzero(val(qtiraponto(str(nREND,9,2))),15)
//            cDIRF += strzero(val(qtiraponto(str(nDEDU,9,2))),15)
//            cDIRF += strzero(val(qtiraponto(str(nIRRF,9,2))),15)
//
//            if BASE->B_inss13 > 0 .or. BASE->B_Inssdt > 0
//               nTTBASE13 := BASE->B_irrf13 + BASE->V_inss13 + BASE->D_irrf13 + BASE->B_irrfdt + BASE->V_inssdt + BASE->D_irrfdt
//               nTTDEDU13 := 0//BASE->D_irrf13 + BASE->V_inss13 + BASE->D_irrfdt + BASE->V_inssdt
//               nTTIRRF13 := BASE->V_irrf13 + BASE->V_irrfdt
//
//            endif
//
//            BASE->(dbskip())
//
//         enddo
//

//         if nULT < 12
//            for nMESES = (nULT + 1) to 12
//                cDIRF += repl("0",45)
//            next
//         endif
//
//
//         if nTTBASE13 > 0
//            cDT :=  strzero(val(qtiraponto(str(nTTBASE13,9,2))),15)
//            cDT +=  strzero(val(qtiraponto(str(nTTDEDU13,9,2))),15)
//            cDT +=  strzero(val(qtiraponto(str(nTTIRRF13,9,2))),15)
//         else
//            cDT := repl("0",45)
//         endif
//
//         nTTBASE13 := 0
//         nTTDEDU13 := 0
//         nTTIRRF13 := 0
//
//         DIRF->(qappend())
//         DIRF->Linha := cDIRF+cDT+"0"+"0"+space(8)+space(32)+"9"
//
//         cDIRF := ""
//         cDT   := ""
//
//         //INSS + DEPENDENTES
//
//         BASE->(dbseek(FUN->Matricula+cANOBASE))
//
//         nSEQ++
//         cDIRF += strzero(nSEQ,8) + "2" + FILIAL->Cgccpf + "05611"
//         cDIRF += "000" + qtiraponto(FUN->Cpf_num) + left(FUN->Nome,60)
//
//         nTOTREG++
//
//         lACHOUE := .T.
//
//         if val(right(BASE->Anomes,2)) > 1
//            for nMESES = 1 to (val(right(BASE->Anomes,2)) - 1)
//                cDIRF += repl("0",45)
//            next
//         endif
//
//         do while ! BASE->(eof()) .and. BASE->Matricula == FUN->Matricula .and. left(BASE->Anomes,4) == cANOBASE
//            nULT    := val(right(BASE->Anomes,2))
//            nINSS   := BASE->V_inssms + BASE->V_inssfr
//            nDEPE   := BASE->D_IRRFMS
//            nPENSAO := 0
//
//            cDIRF += strzero(val(qtiraponto(str(nINSS,9,2))),15)
//            cDIRF += strzero(val(qtiraponto(str(nDEPE,9,2))),15)
//            cDIRF += strzero(val(qtiraponto(str(nPENSAO,9,2))),15)
//
//            if BASE->B_inss13 > 0 .or. BASE->B_Inssdt > 0
//               nTTINSS   := BASE->V_inss13 + BASE->V_inssdt
//               nTTDEPE   := BASE->D_IRRFMS
//               nTTPENSAO := 0
//
//            endif
//
//            BASE->(dbskip())
//
//         enddo
//
//
//         if nULT < 12
//            for nMESES = (nULT + 1) to 12
//                cDIRF += repl("0",45)
//            next
//         endif
//
//         //qmensa(transf(nTTINSS,"@R 999,999.99"))
//         //qinkey(0)
//
//
//         if nTTINSS > 0
//            cDT :=  strzero(val(qtiraponto(str(nTTINSS,9,2))),15)
//            cDT +=  strzero(val(qtiraponto(str(nTTDEPE,9,2))),15)
//            cDT +=  strzero(val(qtiraponto(str(nTTPENSAO,9,2))),15)
//         else
//            cDT := repl("0",45)
//         endif
//
//         nTTDEPE := 0
//         nTTINSS := 0
//         nTTPENSAO := 0
//
//         DIRF->(qappend())
//         DIRF->Linha := cDIRF+cDT+"0"+"1"+space(8)+space(32)+"9"
//
//         cDIRF := ""
//         cDT   := ""
//

return
