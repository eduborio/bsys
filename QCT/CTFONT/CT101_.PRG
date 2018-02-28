/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE CONTABILIDADE
// OBJETIVO...: MANUTENCAO DE PLANO DE CONTA
// ANALISTA...: IN SUNG CHANG
// PROGRAMADOR: IN SUNG CHANG
// INICIO.....: JANEIRO DE 1997
// OBS........:
// ALTERACOES.:

function ct101

NAT_CONT->(dbsetorder(3))

   //if ! empty(CONFIG->Mantra)
   //   if ! quse(XDRV_TS,"PLAN_FIN",{""},,"PLAN_FIN")
   //      qmensa("Arquivo Fluxo de Caixa nao pode ser aberto!","BL")
    //     return .F.
    //  endif

    //  PLAN_FIN->(dbsetorder(3))
  // endif


PLAN->(qview({{"ct_convcod(Codigo)/C¢digo"   ,1},;
             {"c101b()/Descri‡„o" ,2},;
             {"ct_convcod(Reduzido)/Cod.Red.",3}},"P",;
             {NIL,"c101a",NIL,NIL},;
              NIL,q_msg_acesso_usr()))
   //if ! empty(CONFIG->Mantra)
   //   PLAN_FIN->(dbclosearea())
   //endif
return
/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA DESLOCAR EM ARVORE A DESCRICAO DOS CENTROS DE CUSTO __________

function c101b
   local cDESCRICAO := PLAN->Descricao
   do case
      case len(alltrim(PLAN->Codigo)) == 1  ; cDESCRICAO := PLAN->Descricao
      case len(alltrim(PLAN->Codigo)) == 3  ; cDESCRICAO := "  "+PLAN->Descricao
      case len(alltrim(PLAN->Codigo)) == 5  ; cDESCRICAO := "   "+PLAN->Descricao
      case len(alltrim(PLAN->Codigo)) == 7  ; cDESCRICAO := "    "+PLAN->Descricao
      case len(alltrim(PLAN->Codigo)) == 12 ; cDESCRICAO := "     "+PLAN->Descricao
   endcase
return cDESCRICAO + space(09)

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function c101a

   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO $ XUSRA
      qlbloc(10,10,"B101A","QBLOC.GLO",1)
      qmensa(qabrev(cOPCAO,"IA",{"Inclus„o... <ESC - Cancela>","Altera‡„o... <ESC - Cancela>"}))
      i_edicao()
   endif

   setcursor(nCURSOR)

return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA ____________________________________

static function i_edicao
   local lCONF
   local aEDICAO := {}                                //!XFLAG
   local bESCAPE := {||empty(fCODIGO).or.(XNIVEL==1.and.Lastkey()==27) .or.;
                    (!empty(fDESCRICAO) .and. XNIVEL==3 .and. !XFLAG .or. !empty(fDESCRICAO) .and. XNIVEL==3 .and. Lastkey()==27).or.;
                       (XNIVEL==1.and.cOPCAO=="A".and.!XFLAG)}

   local sBLOC1 := qlbloc("B101B","QBLOC.GLO") // SIM/NAO

   private nTIPO := 0


   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"
      XNIVEL := 1
      qrsay(XNIVEL++,ct_convcod(PLAN->Codigo))
      qrsay(XNIVEL++,ct_convcod(PLAN->Reduzido))
      qrsay(XNIVEL++,PLAN->Descricao)
      qrsay(XNIVEL++,PLAN->Nat_cont) ; NAT_CONT->(dbseek(PLAN->Nat_cont))
      qrsay(XNIVEL++,left(NAT_CONT->Descricao,29))
      qrsay(XNIVEL++,PLAN->Desc_adic)
      qrsay(XNIVEL++,qabrev(PLAN->Bloq_tecla,"NS",{"N„o","Sim"}))
      qrsay(XNIVEL++,qabrev(PLAN->Cent_custo,"NS",{"N„o","Sim"}))
      qrsay(XNIVEL++,qabrev(PLAN->Lanc_index,"NS",{"N„o","Sim"}))
      qrsay(XNIVEL++,qabrev(PLAN->Mat_filial,"NS",{"N„o","Sim"}))
      if ! empty(CONFIG->Mantra)
        // qrsay(XNIVEL++,PLAN->Plan_fin) ; PLAN_FIN->(dbseek(PLAN->Plan_fin))
         //qrsay(XNIVEL++,left(PLAN_FIN->Descricao,29))
      endif
   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{||qgetx(-1,0,@fCODIGO   ,"@R 9.99.99.99.9999",,cOPCAO=="I" )},"CODIGO"    })
   aadd(aEDICAO,{{||qgetx(-1,0,@fREDUZIDO ,"@K 99999-9",,cOPCAO=="I"         )},"REDUZIDO"  })
   aadd(aEDICAO,{{||qgetx(-1,0,@fDESCRICAO,"@!","!empty(@)"                  )},"DESCRICAO" })
   aadd(aEDICAO,{{||view_n_conta(-1,0,@fNAT_CONT,"@!","!empty(@)"             )},"NAT_CONT"  })
   aadd(aEDICAO,{{ || NIL                                                     } ,NIL        })
   aadd(aEDICAO,{{||qgetx(-1,0,@fDESC_ADIC,"@!"                              )},"DESC_ADIC" })
   aadd(aEDICAO,{{ || qesco(-1,0,@fBLOQ_TECLA  ,sBLOC1                      ) } ,"BLOQ_TECLA"})
   aadd(aEDICAO,{{ || qesco(-1,0,@fCENT_CUSTO  ,sBLOC1                      ) } ,"CENT_CUSTO"})
   aadd(aEDICAO,{{ || qesco(-1,0,@fLANC_INDEX  ,sBLOC1                      ) } ,"LANC_INDEX"})
   aadd(aEDICAO,{{ || qesco(-1,0,@fMAT_FILIAL  ,sBLOC1                      ) } ,"MAT_FILIAL"})
   //if ! empty(CONFIG->Mantra)

   //aadd(aEDICAO,{{||view_planfin(-1,0,@fPlan_fin                             )},"PLAN_FIN"  })
   //aadd(aEDICAO,{{ || NIL                                                     } ,NIL        })
   //endif

   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   PLAN->(qpublicfields())
   iif(cOPCAO=="I",PLAN->(qinitfields()),PLAN->(qcopyfields()))

   XNIVEL := 1
   XFLAG  := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; PLAN->(qreleasefields()) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif

   if CONFIG->(qrlock()) .and. PLAN->(iif(cOPCAO=="I",qappend(),qrlock()))

      // AQUI INCREMENTA CODIGO DO PLANUTO __________________________________

      PLAN->(qreplacefields())

   else
      iif(cOPCAO=="I",qm1(),qm2())
   endif

   dbunlockall()

   if cOPCAO == "I" ; keyboard "I" ; endif

return

/////////////////////////////////////////////////////////////////////////////
// CRITICA DE EDICAO ________________________________________________________

static function i_critica ( cCAMPO )

   local nREC

   if ! XFLAG ; return .T. ; endif

   do case

      case cCAMPO == "CODIGO"
           do case
              case len(alltrim(fCODIGO)) == 1
                   if cOPCAO == "I"
                      if PLAN->(dbseek(fCODIGO))
                         qmensa("Conta Sint‚tico j  cadastrado !","B")
                         fCODIGO := ""
                         return .F.
                      endif
                    endif

              case len(alltrim(fCODIGO)) == 3
                   if cOPCAO == "I"
                      if ! PLAN->(dbseek(left(fCODIGO,1))).and. len(fCODIGO) == 1
                         qmensa("Conta Sint‚tico n„o cadastrado !","B")
                         fCODIGO := ""
                         return .F.
                      endif
                      if PLAN->(dbseek(left(fCODIGO,3))).and. len(fCODIGO) == 3
                         qmensa("Conta Sint‚tico j  cadastrado !","B")
                         fCODIGO := ""
                         return .F.
                      endif
                    endif

              case len(alltrim(fCODIGO)) == 5
                   if cOPCAO == "I"
                      if ! PLAN->(dbseek(left(fCODIGO,1))) .and. len(fCODIGO) == 1
                         qmensa("Conta Sint‚tico n„o cadastrado !","B")
                         fCODIGO := ""
                         return .F.
                      endif
                      if ! PLAN->(dbseek(left(fCODIGO,3))) .and. len(fCODIGO) ==3
                         qmensa("Conta Sint‚tico j  cadastrado !","B")
                         fCODIGO := ""
                         return .F.
                      endif
                      if PLAN->(dbseek(left(fCODIGO,5))) .and. len(fCODIGO) == 5
                         qmensa("Conta Sint‚tico j  cadastrado !","B")
                         fCODIGO := ""
                         return .F.
                      endif
                    endif

              case len(alltrim(fCODIGO)) == 7

                   if cOPCAO == "I"
                      if ! PLAN->(dbseek(left(fCODIGO,1))) .and. len(fCODIGO) == 1
                         qmensa("Conta Sint‚tica n„o cadastrado !","B")
                         fCODIGO := ""
                         return .F.
                      endif
                      if ! PLAN->(dbseek(left(fCODIGO,3))) .and. cOPCAO == "I" .and. len(fCODIGO) == 3
                         qmensa("Conta Sint‚tica n„o cadastrado !","B")
                         fCODIGO := ""
                         return .F.
                      endif
                      if ! PLAN->(dbseek(left(fCODIGO,5))) .and. cOPCAO == "I" .and. len(fCODIGO) == 5
                         qmensa("Conta Sint‚tica n„o Cadastrada !","B")
                         fCODIGO := ""
                         return .F.
                      endif
                      if PLAN->(dbseek(fCODIGO))
                         qmensa("Conta Sint‚tica j  Cadastrada !","B")
                         fCODIGO := ""
                         return .F.
                      endif
                   endif

              case len(alltrim(fCODIGO)) == 11
                   fCODIGO := alltrim(fCODIGO) + qdigito(fCODIGO)
                   qrsay(XNIVEL,fCODIGO,"@R 9.99.99.99.9999-9")
                   if ! PLAN->(dbseek(left(fCODIGO,3))) .and. cOPCAO == "I" .and. len(fCODIGO) == 3
                      qmensa("Conta Sint‚tica n„o Cadastrada !","B")
                      fCODIGO := ""
                      return .F.
                   endif
                   if ! PLAN->(dbseek(left(fCODIGO,5))) .and. cOPCAO == "I" .and. len(fCODIGO) == 5
                      qmensa("Conta Sint‚tica n„o Cadastrada !","B")
                      fCODIGO := ""
                      return .F.
                   endif
                   if ! PLAN->(dbseek(left(fCODIGO,7))) .and. cOPCAO == "I" .and. len(fCODIGO) == 7
                      qmensa("Conta Sint‚tica n„o Cadastrada !","B")
                      fCODIGO := ""
                      return .F.
                   endif
                   if PLAN->(dbseek(fCODIGO)) .and. cOPCAO == "I"
                      qmensa("Conta Anal¡tica j  Cadastrada !","B")
                      fCODIGO := ""
                      return .F.
                   endif
                   qrsay( XNIVEL,fCODIGO,"@R 9.99.99.99.9999-9")
                   PLAN->(dbsetorder(3))
                   PLAN->(dbgobottom())
                   PLAN->(dbsetorder(1))
                   qrsay( XNIVEL+1 , fREDUZIDO := strzero(val(left(PLAN->Reduzido,5))+1,5) )

           endcase

      case cCAMPO == "REDUZIDO" .and. cOPCAO == "I"
           if val(subs(fCODIGO,8,4)) <> 0
              fREDUZIDO := strzero(val(left(fREDUZIDO,5)),5)
              fREDUZIDO := fREDUZIDO + qdigito(fREDUZIDO)
              qrsay(XNIVEL,fREDUZIDO,"@R 99999-9")
              PLAN->(dbsetorder(3))
              if PLAN->(dbseek(fREDUZIDO))
                 qmensa("Codigo reduzido ja utilizado !","B")
                 PLAN->(dbsetorder(1))
                 return .F.
              endif
              PLAN->(dbsetorder(1))
           endif

      case cCAMPO == "NAT_CONT"
           if ! NAT_CONT->(dbseek(fNAT_CONT))
              qmensa("Natureza da Conta n„o cadastrado !","B")
              return .F.
           endif

           qrsay(XNIVEL+1,left(NAT_CONT->Descricao,29))


      case cCAMPO == "PLAN_FIN"
         if ! empty(fPLAN_FIN)
            qrsay(XNIVEL,fPLAN_FIN := strzero(val(fPLAN_FIN),5) )

            if ! PLAN_FIN->(dbseek(fPLAN_FIN))
                 qmensa("PLANO Fluxo de Caixa nao cadastrado !","B")
                 return .F.
            endif

            qrsay(XNIVEL+1,left(PLAN_FIN->Descricao,29))
         endif

      case cCAMPO == "BLOQ_TECLA"
           if empty(fBLOQ_TECLA) ; return .F. ; endif
           qrsay(XNIVEL,qabrev(fBLOQ_TECLA,"NS",{"N„o","Sim"}))

      case cCAMPO == "CENT_CUSTO"
           if empty(fCENT_CUSTO) ; return .F. ; endif
           qrsay(XNIVEL,qabrev(fCENT_CUSTO,"NS",{"N„o","Sim"}))

      case cCAMPO == "LANC_INDEX"
           if empty(fLANC_INDEX) ; return .F. ; endif
           qrsay(XNIVEL,qabrev(fLANC_INDEX,"NS",{"N„o","Sim"}))

      case cCAMPO == "MAT_FILIAL"
           if empty(fMAT_FILIAL) ; return .F. ; endif
           qrsay(XNIVEL,qabrev(fMAT_FILIAL,"NS",{"N„o","Sim"}))

   endcase

   select PLAN

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXCLUIR PLANUTO ______________________________________________

static function i_exclusao
local nReg    := PLAN->(recno())
local nIndex  := PLAN->(IndexOrd()) 
   
   if qconf("Confirma exclus„o desta Conta ?")
      
	   if ! empty(PLAN->Reduzido)
          LANC->(dbsetorder(2))
          if LANC->(dbseek(PLAN->Reduzido))
             qmensa("Existem Lan‡amentos com esta Conta... Exclus„o negada...","B")
             return
          endif

          LANC->(dbsetorder(3))
          if LANC->(dbseek(PLAN->Reduzido))
             qmensa("Existem Lan‡amentos com esta Conta... Exclus„o negada...","B")
             return
          endif
       else
          PLAN->(dbsetorder(1))
          do case
             case len(alltrim(PLAN->Codigo)) == 1 
			      if verificaSeExisteSubGrupoDestaConta(1,nReg,nIndex)
				      return
				  endif	  
				  
             case len(alltrim(PLAN->Codigo)) == 3  
			      if verificaSeExisteSubGrupoDestaConta(3,nReg,nIndex)
				      return
				  endif

             case len(alltrim(PLAN->Codigo)) == 5
			      if verificaSeExisteSubGrupoDestaConta(5,nReg,nIndex)
				     return
				  endif

             case len(alltrim(PLAN->Codigo)) == 7
			      if verificaSeExisteSubGrupoDestaConta(7,nReg,nIndex)
				     return
				  endif

             endcase
	   
       endif	 
         
	   if PLAN->(qrlock())
          PLAN->(dbdelete())
          PLAN->(qunlock())
       else
          qm3()
       endif
	  
   endif
return

static function verificaSeExisteSubGrupoDestaConta(nSize,nReg,nIndex)
local cCodigo      := left(PLAN->Codigo,nSize)
local cCodigoGeral := PLAN->Codigo

   if PLAN->(dbseek(left(PLAN->Codigo,nSize)))
      Do while ! PLAN->(eof()) .and. left(PLAN->Codigo,nSize) == cCodigo
      if cCodigoGeral != PLAN->Codigo
	     qmensa("Existe Sub-Grupo para esta Conta","BL")
		 retornaAoRegistro(nReg,nIndex)
		 return .T.
      endif
      PLAN->(dbskip())
   enddo
   endif
   retornaAoRegistro(nReg,nIndex)

return .F.

static procedure retornaAoRegistro(nReg,nIndex)
   PLAN->(dbgoto(nReg))
   PLAN->(dbsetorder(nIndex))
return


static function i_trocachr(cTROCADO)

   cTROCADO := strtran(cTROCADO,"Ç","C")
   cTROCADO := strtran(cTROCADO,"ç","C")
   cTROCADO := strtran(cTROCADO,"Ã","A")
   cTROCADO := strtran(cTROCADO,"Õ","O")
   cTROCADO := strtran(cTROCADO,"É","E")

return(cTROCADO)

