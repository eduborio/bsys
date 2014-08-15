/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: FOLHA DE PAGAMENTO
// OBJETIVO...: MANUTENCAO DE RELOGIO PONTO
// ANALISTA...: CARLOS EDUARDO RABELLO NUNES
// PROGRAMADOR: O MESMO
// INICIO.....: SETEMBRO DE 1996
// OBS........:
// ALTERACOES.:

CADPONTO->(dbsetrelation('FUN' ,{|| Matricula},'Matricula'))

CADPONTO->(qview({{"Matricula/Matricula"      ,1},;
                  {"FUN->Nome/Nome do Funcionario",2},;
                  {'Data/Data',0},;
                  {'Horaent/Entrada',0},;
                  {'Horasai/Saida',0},;
                  {'Horaextra/Hora Extra',0}},"P",;
                  {NIL,"c114a",NIL,NIL},;
                  NIL,q_msg_acesso_usr()))
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function c114a
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))
   if cOPCAO $ XUSRA
      qlbloc(07,0,"B114A","QBLOC.GLO",1)
 //     sBLOCO_AA := qlbloc("B102b","QBLOC.GLO",1)    // remuneracao contratual b102b
      qmensa(qabrev(cOPCAO,"IA",{"Inclus„o... <ESC - Cancela>","Altera‡„o... <ESC - Cancela>"}))
      i_edicao()
   endif
   setcursor(nCURSOR)

   if cOPCAO = 'L'
      i_calc_horaextra()
   endif

return ""



/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA ____________________________________

static function i_edicao
   local lCONF
   local aEDICAO := {}
   local bESCAPE := {||empty(fMATRICULA).or.(XNIVEL==1.and.!XFLAG).or.(!empty(fMATRICULA) .and. XNIVEL==2 .and. Lastkey()==27) .or.;
                       (XNIVEL==2.and.cOPCAO=="A".and.!XFLAG)}

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"
      XNIVEL := 1
      qrsay(XNIVEL++,CADPONTO->Matricula)
      qrsay(XNIVEL++,FUN->Nome)
      qrsay(XNIVEL++,CADPONTO->Data)
      qrsay(XNIVEL++,CADPONTO->Horaent)
      qrsay(XNIVEL++,CADPONTO->Horasai)
   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || qgetx(-1,0,@fMATRICULA   ,"@!",NIL,cOPCAO=="I") } ,"MATRICULA"  })
   aadd(aEDICAO,{{ || NIL                                             } ,NIL          })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDATA)                              } ,"DATA"       })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fHORAENT,'99:99')                   } ,"HORAENT"    })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fHORASAI,'99:99')                   } ,"HORASAI"    })

   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   CADPONTO->(qpublicfields())
   iif(cOPCAO=="I",CADPONTO->(qinitfields()),CADPONTO->(qcopyfields()))
   XNIVEL := 1
   XFLAG := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; CADPONTO->(qreleasefields()) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif

   if CADPONTO->(iif(cOPCAO=="I",qappend(),qrlock()))
      CADPONTO->(qreplacefields())
      CADPONTO->(qunlock())
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
      if CADPONTO->(qrlock())
         CADPONTO->(dbdelete())
         CADPONTO->(qunlock())
      else
         qm3()
      endif
   endif
return


static function i_calc_horaextra(cSITUA)
   local zHORAEXTRA := ''   
   iif ( cSITUA == NIL , cSITUA := "" , NIL )
   SITUA->(dbsetorder(4))        // matricula + anomes
   do while ! CADPONTO->(eof())
      SITUA->(dbseek(substr(CADPONTO->Matricula,1,6)))
      if SITUA->Turno = 'D'
         zHORAEXTRA = elaptime(elaptime(CADPONTO->Horasai,CADPONTO->Horaent),'09:00:00')
      else
          zHORAEXTRA = elaptime(elaptime(CADPONTO->Horasai,CADPONTO->Horaent),'09:00:00')
*         zHORAEXTRA = elaptime(elaptime('24:00:00',Horaent) + elaptimeCADPONTO->Horasai,'09:00:00')
      endif
*      if zHOAEXTRA > 1
         CADPONTO->(qrlock())
         replace CADPONTO->Horaextra with substr(zHORAEXTRA,1,5)
*      endif
      skip
   enddo
   CADPONTO->(qunlock())
   SITUA->(dbsetorder(1))
return .t.





