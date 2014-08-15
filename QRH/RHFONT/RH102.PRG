/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: FOLHA DE PAGAMENTO
// OBJETIVO...: MANUTENCAO DE CARGOS
// ANALISTA...: CARLOS EDUARDO RABELLO NUNES
// PROGRAMADOR: O MESMO
// INICIO.....: SETEMBRO DE 1996
// OBS........:
// ALTERACOES.:

CARGO->(qview({{"Codigo/C¢digo"      ,1},;
               {"Descricao/Descri‡„o",2},;
               {"vlr_adiant/Valor Adiant.",3}},"P",;
               {NIL,"c102a",NIL,NIL},;
               NIL,q_msg_acesso_usr()))
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function c102a
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO $ XUSRA
      qlbloc(07,0,"B102A","QBLOC.GLO",1)
      sBLOCO_AA := qlbloc("B102B","QBLOC.GLO",1)    // remuneracao contratual
      qmensa(qabrev(cOPCAO,"IA",{"Inclus„o... <ESC - Cancela>","Altera‡„o... <ESC - Cancela>"}))
      i_edicao()
   endif

   setcursor(nCURSOR)

return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA ____________________________________

static function i_edicao
   local lCONF
   local aEDICAO := {}
   local bESCAPE := {||empty(fCODIGO).or.(XNIVEL==1.and.!XFLAG).or.(!empty(fCODIGO) .and. XNIVEL==2 .and. Lastkey()==27) .or.;
                       (XNIVEL==2.and.cOPCAO=="A".and.!XFLAG)}

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"
      XNIVEL := 1
      qrsay(XNIVEL++,CARGO->Codigo)
      qrsay(XNIVEL++,CARGO->(substr(Descricao,15)))
      qrsay(XNIVEL++,CARGO->Salario , "@E 999,999.99")
      qrsay(XNIVEL++,CARGO->Salariob, "@E 999,999.99")
      qrsay(XNIVEL++,CARGO->vlr_adiant,"@E 999,999.99")
      qrsay(XNIVEL++,CARGO->Especifica,"@R 9")
      qrsay(XNIVEL++,qabrev(CARGO->Especifica,"012345678",{"Nunca Foi Exposto a Agentes Nocivos","N„o Exposi‡„o a Agente Nocivo","Exposic.a Agent.Nocivo(Aposent.aos 15anos)","Exposic.a Agent.Nocivo(Aposent.aos 20anos)",;
      "Exposic.a Agent.Nocivo(Aposent.aos 25anos)","N„o Exposic.a Agent.Nocivo","Exposic.a Agent.Nocivo(Aposent.aos 15anos)","Exposic.a Agent.Nocivo(Aposent.aos 20anos)","Exposic.a Agent.Nocivo(Aposent.aos 25anos)"}))
   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || qgetx(-1,0,@fCODIGO    ,"@!",NIL,cOPCAO=="I") } ,"CODIGO"    })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDESCRICAO ,"@!")                 } ,"DESCRICAO" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fSALARIO   ,"@E 999,999.99")      } ,"SALARIO"   })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fSALARIOB  ,"@E 999,999.99")      } ,"SALARIOB"  })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fVLR_ADIANT,"@E 999,999.99")      } ,"VLR_ADIANT"})
   aadd(aEDICAO,{{ || qesco(-1,0,@fESPECIFICA,sBLOCO_AA)            } ,"ESPECIFICA"})

   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   CARGO->(qpublicfields())

   iif(cOPCAO=="I",CARGO->(qinitfields()),CARGO->(qcopyfields()))
       XNIVEL := 1
       XFLAG := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )

      if eval ( bESCAPE ) ; CARGO->(qreleasefields()) ; return ; endif

      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif

      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif

   if CARGO->(iif(cOPCAO=="I",qappend(),qrlock()))
      CARGO->(qreplacefields())
      CARGO->(qunlock())
   else
      iif(cOPCAO=="I",qm1(),qm2())
   endif

return

/////////////////////////////////////////////////////////////////////////////
// CRITICAS NA DESCIDA ______________________________________________________

static function i_critica ( cCAMPO )
   iif ( cCAMPO == NIL , cCAMPO := "" , NIL )
   do case
      case cCAMPO == "CODIGO" .and. cOPCAO == "I"
           nINVERT := Rtrim(fCODIGO)
           nQUANTI := 6 - Len(nINVERT)
           nCODIGO := Replicate(" ",nQUANTI)+nINVERT
           qrsay(XNIVEL,fCODIGO := nCODIGO)

           if CARGO->(dbseek(fCODIGO))
              qmensa("Cargo j  cadastrado !","B")
              return .F.
           endif

      case cCAMPO == "ESPECIFICA"

           if empty(fESPECIFICA) ; return .F. ; endif

           qrsay (XNIVEL,fESPECIFICA)
           qrsay ( XNIVEL+1 , qabrev(fESPECIFICA,"012345678",{"Nunca Foi Exposto a Agentes Nocivos","N„o Exposi‡„o a Agente Nocivo","Exposic.a Agent.Nocivo(Aposent.aos 15anos)","Exposic.a Agent.Nocivo(Aposent.aos 20anos)",;
           "Exposic.a Agent.Nocivo(Aposent.aos 25anos)","N„o Exposic.a Agent.Nocivo","Exposic.a Agent.Nocivo(Aposent.aos 15anos)","Exposic.a Agent.Nocivo(Aposent.aos 20anos)","Exposic.a Agent.Nocivo(Aposent.aos 25anos)"}) )
   endcase
return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXCLUIR CARGO ________________________________________________

static function i_exclusao
   if qconf("Confirma exclus„o deste cargo ?")
      if CARGO->(qrlock())
         CARGO->(dbdelete())
         CARGO->(qunlock())
      else
         qm3()
      endif
   endif
return

