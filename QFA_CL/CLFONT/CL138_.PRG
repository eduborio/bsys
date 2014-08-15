/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO COMERCIAL
// OBJETIVO...: MANUTENCAO DE EXCLUSIVIDADE DE PRODUTOS POR CLIENTE/CIDADE/Area
// ANALISTA...: EDUARDO BORIO
// PROGRAMADOR: O MESMO
// INICIO.....: FEVEREIRO DE 2012
// OBS........:
// ALTERACOES.:

function cl138
EXCLUSIV->(qview({{"left(Cliente,35)/Cliente"               ,2},;
             {"cod_ass/Produto"                    ,0},;
             {"f138b()/Cidade"                   ,0}},"P",;
             {NIL,"c138a",NIL,NIL},;
             NIL,q_msg_acesso_usr()))

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function c138a

   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO $ XUSRA

      qlbloc(10,5,"B138A","QBLOC.GLO",1)
      qmensa(qabrev(cOPCAO,"IA",{"Inclus„o... <ESC - Cancela>","Altera‡„o... <ESC - Cancela>"}))
      i_edicao()

   endif

   setcursor(nCURSOR)

return ""

function f138b
return left(EXCLUSIV->Desc_Cid,15)+"/"+EXCLUSIV->Uf


/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA ____________________________________

static function i_edicao()

   local lCONF   := .F.
   local aEDICAO := {}
   local bESCAPE := {||empty(fCod_cli).or.(XNIVEL==1.and.!XFLAG).or.lastkey()==27}

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"
      XNIVEL := 1
      qrsay ( XNIVEL++ , EXCLUSIV->Cod_cli     ); CLI1->(dbseek(EXCLUSIV->Cod_cli))
      qrsay ( XNIVEL++ , left(Cli1->Razao,50)  )
      qrsay ( XNIVEL++ , EXCLUSIV->Cod_prod    ); PROD->(dbseek(EXCLUSIV->Cod_prod))
      qrsay ( XNIVEL++ , left(PROD->Descricao,50)  )

   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || view_cli(-1,0,@fCod_cli,"99999")                                                 },"CLI"   })
   aadd(aEDICAO,{{ || NIL                                            }, NIL   })
   aadd(aEDICAO,{{ || view_prod(-1,0,@fCod_prod,"99999")                                               },"PROD"   })
   aadd(aEDICAO,{{ || NIL                                            }, NIL   })


   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   EXCLUSIV->(qpublicfields())
   iif(cOPCAO=="I",EXCLUSIV->(qinitfields()),EXCLUSIV->(qcopyfields()))

   XNIVEL  := 1
   XFLAG   := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; EXCLUSIV->(qreleasefields()) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif

   if EXCLUSIV->(iif(cOPCAO=="I",qappend(),qrlock()))


      // AQUI INCREMENTA CODIGO DO CLIENTE __________________________________

      EXCLUSIV->(qreplacefields())

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
   local lTemArea     := .F.
   local lTemVinculo  := .F.

   if ! XFLAG ; return .T. ; endif

   do case

      case cCAMPO == "CLI"

           if empty(fCOD_CLI) ; return .F. ; endif

           qrsay(XNIVEL,fCOD_CLI:=strzero(val(fCOD_CLI),5))

           if ! CLI1->(dbseek(fCOD_CLI))
              qmensa("Cliente n„o encontrado !","B")
              return .F.
           endif

           qrsay(XNIVEL+1,left(CLI1->Razao,50))

           fCLIENTE := left(CLI1->Razao,50)
           fCIDADE  := CLI1->Cgm_ent
           CGM->(dbseek(CLI1->Cgm_ent))
           fDESC_CID  := CGM->Municipio
           fUF        := CGM->Estado
		   fCOD_EXC   := CLI1->Cod_exc



      case cCAMPO == "PROD"

        if empty(fCOD_PROD) ; return .F. ; endif

        PROD->(dbsetorder(5))

        if PROD->(dbseek(fCOD_PROD))

           fCOD_PROD := right(PROD->Codigo,5)

        else

           PROD->(dbsetorder(3))

           if PROD->(dbseek(fCOD_PROD))
              fCOD_PROD := right(PROD->Codigo,5)
           endif

        endif

        PROD->(dbsetorder(4))


        qrsay(XNIVEL,fCOD_PROD:=strzero(val(fCOD_PROD),5))

        if ! PROD->(dbseek(fCOD_PROD))
           qmensa("Produto n„o encontrado !","B")
           return .F.
        endif

        qrsay ( XNIVEL+1 , left(PROD->Descricao,20)+"/"+PROD->Cod_ass+" - "+left(PROD->Cod_fabr,6) )
        fCOD_ASS := PROD->Cod_ass


        nREG   := EXCLUSIV->(recno())
        nINDEX := EXCLUSIV->(IndexOrd())

        EXCLUSIV->(dbsetorder(1))

        if EXCLUSIV->(dbseek(fCOD_CLI + fCOD_PROD))
           qmensa("Produto ja cadastrado para este cliente!","BL")

           EXCLUSIV->(dbgoto(nREG))
           EXCLUSIV->(dbsetorder(nINDEX))

           return .F.
        endif

        nREG   := EXCLUSIV->(recno())
        nINDEX := EXCLUSIV->(IndexOrd())
		
		lExisteArea  := existeArea(fCidade)
		lTemVinculo := iif(empty(CLI1->Cod_exc),.F.,.T.)
				
		if lExisteArea .and. lTemVinculo
		
		      EXCLUSIV->(dbsetorder(4))
              if EXCLUSIV->(dbseek(fCIDADE + fCOD_EXC + fCOD_PROD))

                 qmensa("","B")
				 AREA_EXC->(dbseek(fCOD_EXC))
				 alert(alltrim(fCOD_ASS) +" exclusivo de "+left(EXCLUSIV->Cliente,25)+" em "+EXCLUSIV->Desc_cid+" - "+left(AREA_EXC->Descricao,20))

                 EXCLUSIV->(dbgoto(nREG))
                 EXCLUSIV->(dbsetorder(nINDEX))
                 return .F.
			  endif 	 
		
		else
		    //Modo Normal Sem Area
			EXCLUSIV->(dbsetorder(3))

           if EXCLUSIV->(dbseek(fCIDADE + fCOD_PROD))

              qmensa(alltrim(fCOD_ASS) +" exclusivo de "+left(EXCLUSIV->Cliente,25)+" em "+EXCLUSIV->Desc_cid+"!","BL")

              EXCLUSIV->(dbgoto(nREG))
              EXCLUSIV->(dbsetorder(nINDEX))

              return .F.
           endif
		
		endif

        EXCLUSIV->(dbsetorder(2))



   endcase

return .T.


/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXCLUIR   ___________________________________________

static function i_exclusao
   if qconf("Confirma exclus„o deste(a) Exclusividade ?")
      if EXCLUSIV->(qrlock())
         EXCLUSIV->(dbdelete())
         EXCLUSIV->(qunlock())
      else
         qm3()
      endif
   endif
return

static function existeArea(fCidade)
local nReg := 0
local nIndex := 0
local lExisteArea := .F.

        nREG   := AREA_EXC->(recno())
        nINDEX := AREA_EXC->(IndexOrd())
		
		AREA_EXC->(dbsetorder(3))

        if AREA_EXC->(dbseek(fCIDADE))
		   lExisteArea := .T.
		endif
		
		AREA_EXC->(dbgoto(nREG))
        AREA_EXC->(dbsetorder(nINDEX))


return lExisteArea
