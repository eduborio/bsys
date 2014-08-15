/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO COMERCIAL
// OBJETIVO...: MANUTENCAO DE EXCLUSIVIDADE DE PRODUTOS POR CLIENTE/CIDADE
// ANALISTA...: EDUARDO BORIO
// PROGRAMADOR: O MESMO
// INICIO.....: JULHO DE 2012
// OBS........:
// ALTERACOES.:

function cl139
AREA_EXC->(qview({{"Codigo/Cod. Area"                ,1},;
                  {"left(Descricao,30)/Area de Exclusividade"      ,2},;
                  {"Cidade/Cod. Cidade"              ,3},;
                  {"f139b()/Cidade"                       ,4}},"P",;
                  {NIL,"c139a",NIL,NIL},;
                  NIL,q_msg_acesso_usr()))

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function c139a

   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO $ XUSRA

      qlbloc(10,5,"B139A","QBLOC.GLO",1)
      qmensa(qabrev(cOPCAO,"IA",{"Inclus„o... <ESC - Cancela>","Altera‡„o... <ESC - Cancela>"}))
      i_edicao()

   endif

   setcursor(nCURSOR)

return ""

function f139b
return left(AREA_EXC->Desc_Cid,15)+"/"+AREA_EXC->Uf


/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA ____________________________________

static function i_edicao()

   local lCONF   := .F.
   local aEDICAO := {}
   local bESCAPE := {|| lastkey()==27}

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"
      XNIVEL := 1
	  qrsay ( XNIVEL++ , AREA_EXC->Codigo     )
	  qrsay ( XNIVEL++ , AREA_EXC->Descricao   )
      qrsay ( XNIVEL++ , AREA_EXC->Cidade     ); CGM->(dbseek(AREA_EXC->Cidade))
      qrsay ( XNIVEL++ , left(CGM->Municipio,50))
      

   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________
   
   aadd(aEDICAO,{{ || NIL                                            }, NIL   })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDescricao,"@!")                   },"DESCRICAO"   })
   aadd(aEDICAO,{{ || view_cgm(-1,0,@fCidade,"999999")               },"CGM"   })
   aadd(aEDICAO,{{ || NIL                                            }, NIL   })
   aadd(aEDICAO,{{ || NIL                                            }, NIL   })
   

   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclusao","alteracao")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   AREA_EXC->(qpublicfields())
   iif(cOPCAO=="I",AREA_EXC->(qinitfields()),AREA_EXC->(qcopyfields()))

   XNIVEL  := 1
   XFLAG   := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; AREA_EXC->(qreleasefields()) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif

   if AREA_EXC->(iif(cOPCAO=="I",qappend(),qrlock()))


      // AQUI INCREMENTA CODIGO Da Area __________________________________
	  
	  if cOPCAO == "I" .and. CONFIG->(qrlock())
         replace CONFIG->Cod_area with CONFIG->Cod_area + 1
         qrsay ( 1 , fCODIGO := strzero(CONFIG->Cod_area,5) )
         qmensa("Codigo Gerado: "+fCODIGO,"B")
		 CONFIG->(qunlock())
      endif


      AREA_EXC->(qreplacefields())

   else


      iif(cOPCAO=="I",qm1(),qm2())

   endif

   dbunlockall()

   if cOPCAO == "I" ; keyboard "I" ; endif

return

/////////////////////////////////////////////////////////////////////////////
// CRITICA DE EDICAO ________________________________________________________

static function i_critica ( cCAMPO )
   local nREG, nINDEX := 0

   if ! XFLAG ; return .T. ; endif

   do case

      case cCAMPO == "CGM"

           if empty(fCidade) ; return .F. ; endif

           if ! CGM->(dbseek(fCidade))
              qmensa("Municipio nao encontrado !","B")
              return .F.
           endif

           qrsay(XNIVEL+1,left(CGM->Municipio,50))
		   qrsay(XNIVEL+2,CGM->Estado)

           fDESC_CID  := CGM->Municipio
           fUF        := CGM->Estado



      case cCAMPO == "DESCRICAO"

        if empty(fDESCRICAO) 
		   return .F.  
		   qmensa("Campo obrigatorio!","BL")
		endif

   endcase

return .T.


/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXCLUIR   ___________________________________________

static function i_exclusao
   if qconf("Confirma exclus„o deste(a) Area de Exclusividade ?")
      if AREA_EXC->(qrlock())
         AREA_EXC->(dbdelete())
         AREA_EXC->(qunlock())
      else
         qm3()
      endif
   endif
return
