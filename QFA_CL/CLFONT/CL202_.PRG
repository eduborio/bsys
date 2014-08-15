/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO COMERCIO
// OBJETIVO...: LANCAMENTO DE PEDIDO DE VENDA
// ANALISTA...:
// PROGRAMADOR: EDUARDO BORIO
// INICIO.....: MARCO DE 2002
// OBS........:
// ALTERACOES.: EDUARDO AUGUSTO BORIO

function cl202
#include "inkey.ch"

private fDIA1 := fDIA2 := fDIA3 := fDIA4 := fDIA5 := fDIA6 := fDIA7 := nDES := fVEZES := 0
private fVALOR1 := fVALOR2 := fVALOR3 := fVALOR4 := fVALOR5 := fVALOR6 := fVALOR7 := 0
private fTOTAL := 0
private nITENS := 0
private fPARC  := 0
private nCOMISSAO := 0
private lALT   := .F.
private sBLOC1  := qlbloc("B201D","QBLOC.GLO")
private sBLOC2  := qlbloc("B202ES","QBLOC.GLO")
private lINCLUSAO:= .F.

CCUSTO->(Dbsetorder(4))

/////////////////////////////////////////////////////////////////////////////
// MANUTENCAO DE PEDIDO DE VENDA ___________________________________________
FAT->(dbsetfilter({|| FAT->Es == "E" .and. ! FAT->No_nf}))

FAT->(qview({{"Codigo/Pedido"         ,1},;
             {"Dt_emissao/Emissao"    ,2},;
             {"left(Cliente,25)/Cliente"      ,7},;
             {"i_202b()/NFe",0},;
             {"Num_fatura/No. NF ",11}},"P",;
             {NIL,"i_202c",NIL,NIL},;
              NIL,q_msg_acesso_usr()+"/im<P>rime / Cancela<R>"))
return

//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAGEM DO CLIENTE ______________________________________________

function i_202a
   CLI1->(dbseek(FAT->Cod_cli))
return left(CLI1->Razao,25)

//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAGEM DO CENTRO DE CUSTO  _____________________________________

function i_202b
return iif(!empty(FAT->NFe),"NFe Propria","           ")

//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO _____________________________________

function i_202c

   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))
   
     iif(cOPCAO == "Z", i_descancela(),)
     iif(cOPCAO == "P", i_imprime(),)

   if cOPCAO $ XUSRA

      if cOPCAO == "A" 
	     lALT := .T.
		 if ! empty(FAT->Nfe)
		    qmensa("Nao e permitido alterar NFe emitida pela propria Empresa!","BL")
			//return .F.
		 endif	
		 
	  endif	 
		 
      iif(cOPCAO == "I", lINCLUSAO := .T.,)


      if CONFIG->Modelo_2 $ "9"
        qlbloc(5,0,"B201AK","QBLOC.GLO",1)
      elseif CONFIG->Modelo_fat == "8"
        qlbloc(5,0,"B201M","QBLOC.GLO",1)
      elseif CONFIG->Modelo_2 == "2"
        qlbloc(5,0,"B201R","QBLOC.GLO",1)
      elseif CONFIG->Modelo_fat == "0"
        qlbloc(5,0,"B202A","QBLOC.GLO",1)
      else
        qlbloc(5,0,"B202A","QBLOC.GLO",1)
      endif

      qmensa(qabrev(cOPCAO,"IA",{"Inclus„o... <ESC - Cancelar>","Altera‡„o... <ESC - Cancelar>"}))
      i_edicao()

   endif

   setcursor(nCURSOR)

return ""

//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA _________________________________________

static function i_edicao

   local lCONF
   local aEDICAO := {}
   local bESCAPE := {||empty(fDT_EMISSAO).or.(XNIVEL==2.and.!XFLAG).or.;
                       (XNIVEL==2.and.lastkey()==27)}

   fDIA1 := fDIA2 := fDIA3 := fDIA4 := fDIA5 := fDIA6 := fDIA7 := fVEZES := 0
   fVALOR1 := fVALOR2 := fVALOR3 := fVALOR4 := fVALOR5 := fVALOR6 := fVALOR7 := 0
   fTOTAL := 0
   nCOMISSAO:= 0
   fPARC  := 0

// MONTA DADOS NA TELA ___________________________________________________________

   if cOPCAO <> "I"

      XNIVEL := 1

      qsay ( 06,17 , FAT->Codigo           )
      qsay ( 06,42 , dtoc(FAT->Dt_Emissao) )
      qsay ( 06,68 , dtoc(FAT->Dt_saida ) )
      qsay ( 07,24 , FAT->Cod_Cli          ) ; CLI1->(dbseek(FAT->Cod_cli))
      qsay ( 07,32 , left(CLI1->Razao,30)  )

      qsay ( 08,17 , FAT->Cod_vended       ) ; VEND->(dbseek(FAT->Cod_vended))
      qsay ( 08,25 , left(VEND->Nome,16)   )
      qsay ( 08,51 , FAT->Cod_repres       ) ; REPRES->(dbseek(FAT->Cod_repres))
      qsay ( 08,57 , left(REPRES->Razao,21)   )

      qsay ( 09,24 , FAT->Filial           ) ; FILIAL->(dbseek(FAT->Filial))
      qsay ( 09,31 , left(FILIAL->Razao,30))
      qsay ( 10,24 , FAT->C_custo          ) ; CCUSTO->(dbseek(FAT->C_custo))
      qsay ( 10,31 , left(CCUSTO->Descricao,15))

      qsay ( 11,24 , FAT->Cod_transp       ) ; TRANSP->(dbseek(FAT->Cod_transp))
      qsay ( 11,32 , left(TRANSP->Razao,30))
      qsay ( 12,24 , transform(FAT->Cod_cfop,"@R 9.999")) ; CFOP->(dbseek(FAT->Cod_cfop))
      qsay ( 12,32 , left(CFOP->Nat_desc,38))

      if  CONFIG->Modelo_fat == "8"
        qsay ( 13,24 , transform(FAT->cfop2,"@R 9.999")) ; CFOP->(dbseek(FAT->cfop2))
        qsay ( 13,32 , left(CFOP->Nat_desc,38))
      else
        if CONFIG->Modelo_2 == "2"
           qsay( 13,24,FAT->Condic) ; COND->(dbseek(FAT->Condic))
           qsay( 13,29,COND->Descricao )
        else
           qsay ( 13,21 , FAT->Tiposub          ) ; TIPOCONT->(dbseek(FAT->Tiposub))
           qsay ( 13,30,  alltrim(TIPOCONT->Descricao))
        endif
      endif

      qsay ( 14,27,  qabrev(FAT->Desc_sn,"SN", {"Sim","N„o"}))
      qsay ( 14,50,  qabrev(FAT->Es     ,"E", {"Entrada"}))

      //if CONFIG->Modelo_2 == "2"
      //   qsay ( 14,71, transform(FAT->Aliq_desc,"@E 9999.99")    )
      //else
      //   qsay ( 14,73, transform(FAT->Aliq_desc,"@E 99.99")    )
      //endif

      qsay ( 14,72 , FAT->Num_fatura               )
      qsay ( 15,14 , Left(FAT->Obs,42)             )
      qsay ( 15,72 , FAT->Ref_Numnf                )

      if cOPCAO == "C"
        i_atu_lanc()
        keyboard chr(27)
      endif

   endif

   // CONSULTA OU EXCLUSAO _______________________________________________________

   if cOPCAO == "C" ; qwait() ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO _________________________________________________

   aadd(aEDICAO,{{ || NIL                                               } ,"CODIGO"       })
   aadd(aEDICAO,{{ || qgetx(6,42,@fDT_EMISSAO,"@D",                    )} ,"DT_EMISSAO"   })
   aadd(aEDICAO,{{ || qgetx(6,68,@fDT_SAIDA  ,"@D",                    )} ,"DT_SAIDA"     })

   aadd(aEDICAO,{{ || view_cli2(7,24,@fCOD_CLI                          )} ,"COD_CLI"      })
   aadd(aEDICAO,{{ || NIL },NIL }) // razao do cliente

   aadd(aEDICAO,{{ || view_vend(8,17,@fCOD_VENDED                      )} ,"COD_VENDED"   })
   aadd(aEDICAO,{{ || NIL },NIL }) // nome do vendedor

   aadd(aEDICAO,{{ || view_repres(8,51,@fCOD_REPRES                      )} ,"COD_REPRES"   })
   aadd(aEDICAO,{{ || NIL },NIL }) // nome do representante


   aadd(aEDICAO,{{ || view_filial(9,24,@fFILIAL                        )} ,"FILIAL"       })
   aadd(aEDICAO,{{ || NIL },NIL }) // descricao da filial

   aadd(aEDICAO,{{ || view_ccusto(10,24,@fC_CUSTO                       )} ,"C_CUSTO"      })
   aadd(aEDICAO,{{ || NIL },NIL }) // descricao do centro

   aadd(aEDICAO,{{ || view_transp(11,24,@fCOD_TRANSP                    )} ,"COD_TRANSP"      })
   aadd(aEDICAO,{{ || NIL },NIL }) // descricao da Transportadora

   aadd(aEDICAO,{{ || view_cfop(12,24,@fCOD_CFOP                       )} ,"COD_CFOP"     })
   aadd(aEDICAO,{{ || NIL },NIL }) // descricao da natureza de operacao

   if CONFIG->Modelo_fat == "8"
      aadd(aEDICAO,{{ || view_cfop(13,24,@fCFOP2                      )} ,"CFOP2"     })
      aadd(aEDICAO,{{ || NIL },NIL }) // descricao da natureza de operacao
    else
      if CONFIG->Modelo_2 == "2"
        aadd(aEDICAO,{{ || view_cond(13,24,@fCONDIC                    )}  ,"CONDIC"      })
        aadd(aEDICAO,{{ || NIL },NIL }) // descricao do tipo
      else
        aadd(aEDICAO,{{ || view_tipocont(13,21,@fTIPOSUB                    )}  ,"TIPOSUB"      })
        aadd(aEDICAO,{{ || NIL },NIL }) // descricao do tipo
      endif
   endif

   aadd(aEDICAO,{{ || qesco(14,27,@fDESC_SN ,sBLOC1                    )}   ,"DESC_SN"    })
   aadd(aEDICAO,{{ || qesco(14,50,@fES      ,sBLOC2                    )}   ,"ES"         })

   //if CONFIG->Modelo_2 == "2"
   //   aadd(aEDICAO,{{ || qgetx(14,71,@fALIQ_DESC,"9999.99",NIL              )}   ,"ALIQ_DESC"  })
   //else
   //   aadd(aEDICAO,{{ || qgetx(14,73,@fALIQ_DESC,"99.99",NIL              )}   ,"ALIQ_DESC"  })
   //endif

   aadd(aEDICAO,{{ || qgetx(14,72,@fNUM_FATURA,"999999"              )}   ,"NUM_FATURA"})
   aadd(aEDICAO,{{ || qgetx(15,14,@fOBS,"@!S42",NIL                  )}   ,"OBS"       })
   aadd(aEDICAO,{{ || qgetx(15,72,@fREF_NUMNF ,"999999"              )}   ,"REF_NUMNF"})


   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO ____________________________________________________

   do while .T.
      qgirabarra()

      FAT->(qpublicfields())

      iif(cOPCAO=="I", FAT->(qinitfields()), FAT->(qcopyfields()))

      XNIVEL := 2
      XFLAG := .T.

      // LOOP PARA ENTRADA DOS CAMPOS ____________________________________________

      do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
         eval ( aEDICAO [XNIVEL,1] )
         if eval ( bESCAPE );FAT->(qreleasefields());return;endif
         if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
         iif ( XFLAG , XNIVEL++ , XNIVEL-- )
         qmensa("")
      enddo

      if ! lCONF ; return ; endif

      if NUM_PEDI->(qrlock())

         // AQUI INCREMENTA CODIGO DO PEDIDO DE VENDA ____________

         if cOPCAO == "I"
            replace NUM_PEDI->Pedido with NUM_PEDI->Pedido + 1
            qsay(6,17,fCODIGO := strzero(NUM_PEDI->Pedido,5) )
            qmensa("C¢digo Gerado: "+fCODIGO,"B")
         endif

      else
         iif(cOPCAO=="I",qm1(),qm2())
      endif

      if FAT->(iif(cOPCAO=="I",qappend(),qrlock()))

         // AGORA GRAVA E DESTRAVA ARQUIVO _____________________________________

         fFATURAR := .F.

         FAT->(qreplacefields())
         replace FAT->Cliente with fCLIENTE
      endif

      dbunlockall()

      i_proc_lanc()

      if left(FAT->Cod_Cfop,4) $ "1915-2915" .and. ! FAT->Conserto .and. lINCLUSAO

          if FAT->(Qrlock())
             replace FAT->Conserto with .T.
             FAT->(Qunlock())
          endif

          i_make_ret(FAT->Codigo)


      endif

      if left(FAT->Cod_Cfop,4) $ "1949-2949" .and. ! FAT->Conserto .and. lINCLUSAO .and. qconf("Deseja criar uma NF de Retorno de Conserto?","BL")

          if FAT->(Qrlock())
             replace FAT->Conserto with .T.
             FAT->(Qunlock())
          endif

          i_make_ret(FAT->Codigo)


      endif


      i_totaliza_pedido()

      //i_grava_cred(fTOTAL)

      keyboard chr(27)


   enddo

return

/////////////////////////////////////////////////////////////////////////////////
// CRITICAS NA DESCIDA __________________________________________________________

static function i_critica ( cCAMPO )

   qmensa("")

   iif ( cCAMPO == NIL , cCAMPO := "" , NIL )
   if ! XFLAG ; return .T. ; endif

   do case

      case cCAMPO == "DT_EMISSAO"

           if empty(fDT_EMISSAO) ; return .F. ; endif

           if CONFIG->Modelo_fat == "1"
              if cOPCAO == "I"
                 fC_CUSTO := "0004"
                 fFILIAL := "0001"
                 fCOD_VENDED := "00001"
                 sDESC_SN := "N"
              endif
              fES := "E"
           endif

      case cCAMPO == "COD_CLI"

           if empty(fCOD_CLI) ; return .F. ; endif
           qsay(7,24,fCOD_CLI:=strzero(val(fCOD_CLI),5))
           if ! CLI1->(dbseek(fCOD_CLI))
              qmensa("Cliente n„o encontrado !","B")
              return .F.
           endif

          //if fCOD_CLI == "00001" .and. CONFIG->Modelo_2 == "1"
          //  i_inc_Balcao()
          // Endif


           qsay(7,32,left(CLI1->Razao,40))
          // if empty(CLI1->Conta_cont)
          //    qmensa("Aten‡„o !! Conta Cont bil n„o informada !!","B")
          // endif

           if cOPCAO == "I" ; fCOD_VENDED := CLI1->Cod_vend ; endif
           if cOPCAO == "I" ; fCOD_REPRES := CLI1->Cod_repres ; endif
           if cOPCAO == "I" ; fCOD_TERRIT := CLI1->Cod_TERRIT; endif

           fCLIENTE := CLI1->Razao
           if CONFIG->Modelo_2 == "1"
              fC_CUSTO := "0010"
              fFILIAL := "0001"
              fTIPOSUB := "010002"
              sDESC_SN := "N"
           endif
		   
		   if CONFIG->Modelo_fat == "1"
		      if empty(CLI1->Cod_resp)
			     qmensa("nao existe Responsavel cadastrado para este Cliente","BL")
                 return .F.		
              endif
              
              fCOD_RESP := CLI1->Cod_resp 
		   endif	  

      case cCAMPO == "COD_REPRES"
           if empty(fCOD_REPRES) ; return .F. ; endif
           qsay(8,51,fCOD_REPRES:=strzero(val(fCOD_REPRES),5))
           if ! REPRES->(dbseek(fCOD_REPRES))
              qmensa("Representante n„o encontrado !","B")
              return .F.
           endif
           qsay(8,57,left(REPRES->Razao,21))

      case cCAMPO == "COD_VENDED"
           if empty(fCOD_VENDED) ; return .F. ; endif
           qsay(8,17,fCOD_VENDED:=strzero(val(fCOD_VENDED),5))
           if ! VEND->(dbseek(fCOD_VENDED))
              qmensa("Vendedor n„o encontrado !","B")
              return .F.
           endif
           nCOMISSAO := VEND->Comis
           qsay(8,25,left(VEND->Nome,16))

      case cCAMPO == "COD_DI"
           if empty(fCOD_DI) ; return .F. ; endif
           qsay(10,61,fCOD_DI)
           PROD->(dbsetorder(1))
           if ! PROD->(dbseek(fCOD_DI))
              qmensa("D/I n„o encontrada !","B")
              return .F.
           endif
           qsay(10,66,left(PROD->Descricao,12))

      case cCAMPO == "COD_IF"
           if empty(fCOD_IF) ; return .F. ; endif
           qsay(14,17,fCOD_IF:=strzero(val(fCOD_IF),4))
           if ! IDENT->(dbseek(fCOD_IF))
              qmensa("Identificacao Fiscal n„o encontrada !","B")
              return .F.
           endif
           qsay(14,17,left(IDENT->Nome,30))

      case cCAMPO == "FILIAL"
           if empty(fFILIAL) ; return .F. ; endif
           qsay(9,24,fFILIAL)
           if ! FILIAL->(dbseek(fFILIAL))
              qmensa("Filial n„o encontrado !","B")
              return .F.
           endif
           qsay(9,31,left(FILIAL->Razao,40))

      case cCAMPO == "C_CUSTO"
           if empty(fC_CUSTO) ; return .F. ; endif
           qsay(10,24,fC_CUSTO)
           CCUSTO->(dbsetorder(4))
           if ! CCUSTO->(dbseek(fC_CUSTO))
              qmensa("Centro de Custo n„o encontrado !","B")
              return .F.
           endif
           qsay(10,31,left(CCUSTO->Descricao,15))

      case cCAMPO == "COD_TRANSP"
           qsay(11,24,fCOD_TRANSP:=strzero(val(fCOD_TRANSP),5))
           if ! TRANSP->(dbseek(fCOD_TRANSP))
              qmensa("Transportadora n„o encontrada !")

           endif
           if fCOD_TRANSP == "00000"
              fCOD_TRANSP := "     "
           endif
           qsay(11,32,left(TRANSP->Razao,40))


      case cCAMPO == "COD_CFOP"
           if empty(fCOD_CFOP) ; return .F. ; endif

           if left(fCOD_CFOP,1) $ "5-6-7"
              qmensa("Nao ‚ permitido Cfop de Saida!!","B")
              return .F.
           endif

           CGM->(Dbseek(CLI1->Cgm_ent))
           if CGM->Estado == "PR"
              if left(fCOD_CFOP,1) $ "2-3"
                 qmensa("Cliente Dentro do Estado. Verifique !","B")
                 return .F.
              endif
           else
              if left(fCOD_CFOP,1) == "1"
                 qmensa("Cliente Fora do Estado. Verifique !","B")
                 return .F.
              endif
           endif



           qsay(12,24,transform(fCOD_CFOP,"@R 9.999"))
           if ! CFOP->(dbseek(fCOD_CFOP))
              qmensa("Natureza de Opera‡„o n„o encontrada !","B")
              return .F.
           endif
           qsay(12,32,left(CFOP->Nat_Desc,40))
           if ! empty(CFOP->Tipo_cont) .and. TIPOCONT->(dbseek(CFOP->Tipo_cont))
              fTIPOSUB := TIPOCONT->Codigo
              qsay(13,21,fTIPOSUB)
              qsay(13,30,alltrim(TIPOCONT->Descricao))
           endif



      case cCAMPO == "CONDIC"
           if empty(fCONDIC) ; return .F. ; endif
           qsay(13,24,fCONDIC)
           if ! COND->(dbseek(fCONDIC))
              qmensa("Condicao de Pagamento n„o encontrada !","B")
              return .F.
           endif
           qsay(13,29,COND->Descricao)

      case cCAMPO == "CFOP2"
           qsay(13,24,transform(fCFOP2,"@R 9.999"))
           if ! CFOP->(dbseek(fCFOP2))
              qmensa("Natureza de Opera‡„o n„o encontrada !","B")
              return .T.
              qmensa()
           endif
           qsay(13,32,left(CFOP->Nat_Desc,40))



      case cCAMPO == "TIPOSUB"
           if empty(fTIPOSUB) ; return .F. ; endif
           qsay(13,21,fTIPOSUB:=strzero(val(fTIPOSUB),6))
           if ! TIPOCONT->(dbseek(fTIPOSUB))
              qmensa("Tipo Contabil n„o encontrado !","B")
              return .F.
           endif

           qsay(13,30,alltrim(TIPOCONT->Descricao))

      case cCAMPO == "NUM_FATURA"

           if CONFIG->Modelo_fat == "1"
              if empty(fNUM_FATURA) ; return .F. ; endif
              qsay(14,72,fNUM_FATURA:=strzero(val(fNUM_FATURA),6))
           else
              if ! Empty(fNUM_FATURA)
                 qsay(14,72,fNUM_FATURA:=strzero(val(fNUM_FATURA),6))
              endif
           endif

      case cCAMPO == "REF_NUMNF"
           if empty(fREF_NUMNF) ; return .F. ; endif
           qsay(15,72,fREF_NUMNF:=strzero(val(fREF_NUMNF),6))


      case cCAMPO == "DESC_SN"
           if empty(fDESC_SN) ; return .F. ; endif
           qsay(14,27,qabrev(fDESC_SN,"SN",{"Sim","N„o"}))

      case cCAMPO == "ES"
           if empty(fES) ; return .F. ; endif
           qsay(14,50,qabrev(fES,"E",{"Entrada"}))

   endcase

return .T.

//////////////////////////////////////////////////////////////////////////////////
// FUN€AO PARA EXCLUIR PEDIDO DE VENDA __________________________________________

static function i_exclusao

   if qconf("Confirma exclus„o desta Devolu‡Æo de Venda ?")
   
      if ! empty(FAT->Nfe)
	     qmensa("Nao e permitido excluir NFe de Entrada emitida pela propria empresa","BL")
	     return .F.
	  endif

      /// rotina para voltar o estoque dos produtos digitados no Pedido Deletado !

      ITEN_FAT->(Dbgotop())
      ITEN_FAT->(Dbseek(FAT->Codigo))

      do while ! ITEN_FAT->(eof()) .and. ITEN_FAT->Num_fat == FAT->Codigo

         PROD->(Dbsetorder(4))
         INVENT->(dbsetorder(1))

         i_baixa_estoque(ITEN_FAT->Quantidade,ITEN_FAT->Reserva,ITEN_FAT->Terceiros)

         //i_mais_pontos(FAT->Cod_Repres,ITEN_FAT->Cod_prod,ITEN_FAT->Quantidade,ITEN_FAT->Vl_unitar)

         ITEN_FAT->(Dbskip())

      enddo

      if ITEN_FAT->(qflock()) .and. FAT->(qrlock())

         ITEN_FAT->(dbseek(FAT->Codigo))

         do while ! ITEN_FAT->(eof()) .and. ITEN_FAT->Num_fat == FAT->Codigo // itens do pedido (produtos)
            ITEN_FAT->(dbdelete())
            ITEN_FAT->(dbskip())
         enddo

         DUP_FAT->(dbseek(FAT->Codigo+"01"))

         do while ! DUP_FAT->(eof()) .and. DUP_FAT->(qrlock()) .and. left(DUP_FAT->Num_fat,5) == FAT->Codigo // duplicatas do pedido
            DUP_FAT->(dbdelete())
            DUP_FAT->(dbskip())
         enddo

         i_exc_cred()



         FAT->(dbdelete())
         FAT->(qunlock())
         ITEN_FAT->(qunlock())
         DUP_FAT->(qunlock())

      else
         qm3()
      endif
   endif

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DOS PRODUTOS _______________________________

static function i_proc_lanc


// LOOP PRINCIPAL ___________________________________________________________

setcolor("W/B")

if cOPCAO == "A"
   fTOTAL := 0
   lALT := .T.
endif

PROD->(Dbsetorder(4))

if CONFIG->Modelo_fat == "1"
   ITEN_FAT->(qview({{"f202m1()/Cod."                                        ,0},;
                     {"f202a()/Descri‡„o"                                    ,0},;
                     {"f202m()/ref"                                          ,0},;
                     {"transform(Vl_unitar, '@E 999,999.99')/Vl.Unit."    ,0},;
                     {"transform(Quantidade,'@E 99999')/Quant."           ,0},;
                     {"f202b()/Un."                                          ,0},;
                     {"f202c()/Val. Total"                                   ,0}},;
                     "16002179S",;
                     {NIL,"f202d",NIL,NIL},;
                     {"ITEN_FAT->Num_fat == FAT->Codigo",{||f202top()},{||f202bot()}},;
                     "<I>nc./<A>lt./<C>on./<E>xc."))
else
   ITEN_FAT->(qview({{"Cod_prod/Cod."                                        ,2},;
                     {"f202a()/Descri‡„o"                                    ,0},;
                     {"transform(Vl_unitar, '@E 999,999.99999')/Vl.Unit."    ,0},;
                     {"transform(Quantidade,'@E 99999.99')/Quant."           ,0},;
                     {"f202b()/Un."                                          ,0},;
                     {"f202c()/Val. Total"                                   ,0}},;
                     "16002179S",;
                     {NIL,"f202d",NIL,NIL},;
                     {"ITEN_FAT->Num_fat == FAT->Codigo",{||f202top()},{||f202bot()}},;
                     "<I>nc./<A>lt./<C>on./<E>xc."))
endif
return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IR PARA O INICIO DOS DADOS FILTRADOS _________________________

function f202top
   ITEN_FAT->(dbsetorder(1))
   ITEN_FAT->(dbseek(FAT->Codigo))
   i_totaliza_pedido()
   qsay(22,16,transform(fTOTAL,"@E 99,999,999.99"))

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IR PARA O FINAL DOS DADOS FILTRADOS __________________________

function f202bot
   ITEN_FAT->(dbsetorder(1))
   ITEN_FAT->(qseekn(FAT->Codigo))
   i_totaliza_pedido()
   qsay(22,16,transform(fTOTAL,"@E 99,999,999.99"))
return

/////////////////////////////////////////////////////////////////////////////
// RETORNA A DESCRICAO DO PRODUTO __________________________________________

function f202a

   local cDESCRICAO := space(30)
   PROD->(Dbsetorder(4))
   if ! empty(ITEN_FAT->Cod_prod)
      PROD->(dbseek(left(ITEN_FAT->Cod_prod,5)))
      cDESCRICAO := left(PROD->Descricao,30)
   endif
   i_totaliza_pedido()
   qsay(22,16,transform(fTOTAL,"@E 99,999,999.99"))

return cDESCRICAO


function f202m
   local cFABR := space(4)

   PROD->(Dbsetorder(4))
   if ! empty(ITEN_FAT->Cod_prod)
      PROD->(dbseek(left(ITEN_FAT->Cod_prod,5)))
      cFABR := left(PROD->Cod_fabr,4)
   endif
   i_totaliza_pedido()
   qsay(22,16,transform(fTOTAL,"@E 99,999,999.99"))
   rtrim(cFABR)

return cFABR

function f202m1
   local cASS := space(7)

   PROD->(Dbsetorder(4))
   if ! empty(ITEN_FAT->Cod_prod)
      PROD->(dbseek(left(ITEN_FAT->Cod_prod,5)))
      cASS := left(PROD->Cod_ass,7)
   endif
   i_totaliza_pedido()
   qsay(22,16,transform(fTOTAL,"@E 99,999,999.99"))
   rtrim(cASS)

return cASS


/////////////////////////////////////////////////////////////////////////////
// RETORNA A UNIDADE DO PRODUTO _____________________________________________

function f202b
   PROD->(dbseek(left(ITEN_FAT->Cod_prod,5)))
   UNIDADE->(dbseek(PROD->Unidade))
   i_totaliza_pedido()
   qsay(22,16,transform(fTOTAL,"@E 99,999,999.99"))
return UNIDADE->Sigla

/////////////////////////////////////////////////////////////////////////////
// RETORNA O VALOR TOTAL DO PRODUTO _________________________________________

function f202c
   i_totaliza_pedido()
   qsay(22,16,transform(fTOTAL,"@E 99,999,999.99"))
return transform(ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade,"@E 999,999.99")


/////////////////////////////////////////////////////////////////////////////
// FUNCAO DE CONTROLE PRINCIPAL ANTES DE PROCESSAR A TECLA ACIONADA _________

function f202d

   local nCURSOR := setcursor(1)
   parameters cOPCAO

   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO $ "ICE"
     if CONFIG->Modelo_fat == "B"
         qlbloc(08,08,"B201BG","QBLOC.GLO",1)
     elseif CONFIG->Modelo_fat $ "1-0-4" .or. CONFIG->Modelo_2 == "7"
         qlbloc(06,08,"B202B1","QBLOC.GLO",1)
     elseif CONFIG->Modelo_2 $ "9"
         qlbloc(08,08,"B201BK","QBLOC.GLO",1)
     elseif CONFIG->Modelo_2 $ "5"
         qlbloc(08,08,"B201B1","QBLOC.GLO",1)
     else
         qlbloc(08,08,"B201B","QBLOC.GLO",1)
     endif

      i_processa_dev()
   endif

    i_totaliza_pedido()
return ""






/////////////////////////////////////////////////////////////////////////////
// FUNCAO DE BROWSE _________________________________________________________

static function i_processa_dev

   local lCONF
   local aEDICAO := {}
   local bESCAPE := {||empty(fCOD_PROD).or.(XNIVEL==1.and.!XFLAG).or.;
                       (XNIVEL==1.and.lastkey()==27).or.;
                       (XNIVEL==2.and.cOPCAO=="A".and.!XFLAG)}

   if lALT  // se alteracao - zera o totalizador e refaz a soma das parcelas
      fPARC := 0
   endif

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"

      XNIVEL := 1
      qrsay ( XNIVEL++ , ITEN_FAT->Cod_prod            , "@R 99999"                    ) ; PROD->(dbseek(left(ITEN_FAT->Cod_prod,5)))
      qrsay ( XNIVEL++ , left(PROD->Descricao,40)                                      )
      qrsay ( XNIVEL++ , ITEN_FAT->Num_lote                                            )
      qrsay ( XNIVEL++ , qabrev(ITEN_FAT->Avariado  ,"NS", {"Nao","Sim"})                )
	  qrsay ( XNIVEL++ , qabrev(ITEN_FAT->NfAntigaSt,"NS", {"Nao","Sim"})                )
	  qrsay ( XNIVEL++ , qabrev(ITEN_FAT->OldSt     ,"NS", {"Nao","Sim"})                )
      qrsay ( XNIVEL++ , ITEN_FAT->Preco_vend, "@E 999,999.99"        )
      qrsay ( XNIVEL++ , ITEN_FAT->Desc_prod, "@E 99.99"     )
      qrsay ( XNIVEL++ , ITEN_FAT->Vlr_Desc , "@E 999,999.99"                       )
      qrsay ( XNIVEL++ , ITEN_FAT->Vl_unitar, "@E 9999,999,999.99"                       )
      qrsay ( XNIVEL++ , ITEN_FAT->Quantidade                                          )
      qrsay ( XNIVEL++ , transform(ITEN_FAT->Icms,"@E 99.99")                          )
      qrsay ( XNIVEL++ , transform(ITEN_FAT->Ipi, "@E 99.99")                              )
      qrsay ( XNIVEL++ , ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade, "@E 9,999,999.99" )
      qrsay ( XNIVEL++ , transform(ITEN_FAT->Comissao, "@E 99.99" )                    )
      qrsay ( XNIVEL++ , transform(ITEN_FAT->Comi_repre, "@E 99.99" )                    )

      if CONFIG->Modelo_fat != "B"
         qrsay ( XNIVEL++ , ITEN_FAT->Cod_motdev    );MOTDEV->(dbseek(ITEN_FAT->Cod_motdev))
         qrsay ( XNIVEL++ , left(MOTDEV->Descricao,30)                                  )
         SUBSYS->(dbsetorder(1))
         qrsay ( XNIVEL++ , ITEN_FAT->Cod_subsys    );SUBSYS->(dbseek(ITEN_FAT->Cod_subsys))
         qrsay ( XNIVEL++ , left(SUBSYS->Descricao,30)                                  )

         DEFEITO->(dbsetorder(1))
         qrsay ( XNIVEL++ , ITEN_FAT->Cod_defe    );DEFEITO->(dbseek(ITEN_FAT->Cod_defe))
         qrsay ( XNIVEL++ , left(DEFEITO->Descricao,30)                                  )


         qrsay ( XNIVEL++ , ITEN_FAT->Cod_sit          ,"@R 999"   );SIT_TRIB->(dbseek(ITEN_FAT->Cod_sit))
         qrsay ( XNIVEL++ , left(SIT_TRIB->Descricao,30)                                  )
//         qrsay ( XNIVEL++ , ITEN_FAT->Classif                  )
         if CONFIG->Modelo_2 == "3"
            qrsay ( XNIVEL++ , ITEN_FAT->Num_nf                )
         endif
      endif
      // CONFIGURACAO P/ RICHETTI & GOBBO (PREPOSTO)
      if  CONFIG->Modelo_fat == "B"
        qrsay ( XNIVEL++ , ITEN_FAT->Prep_cod,"@R 99999" );PREP->(Dbseek(ITEN_FAT->Prep_cod))
        qrsay ( XNIVEL++ , left(PREP->Descricao,40)      )
      endif

      //CONFIGURACAO P/ OFICINA DOS IMPORTADOS (IMPOSTO DE IMPORTACAO)
      if  CONFIG->Modelo_2=="9"
        qrsay ( XNIVEL++ , ITEN_FAT->Vlr_ii, "@E 99,999,999.99"                          )
      endif

      if CONFIG->Modelo_fat == "9"
         qrsay ( XNIVEL++ , ITEN_FAT->N_lote)
      endif
   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exc_itens_fat() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || view_prod(-1,0,@fCOD_PROD                    ) } ,"COD_PROD"  })
   aadd(aEDICAO,{{ || NIL                                            } ,NIL         })
   aadd(aEDICAO,{{ || view_lote(-1,0,@fNUM_LOTE, "@!"              ) } ,"NUM_LOTE"  })
   aadd(aEDICAO,{{ || qesco(-1,0,@fAVARIADO,XSN                    ) } ,"AVARIA"    })
   aadd(aEDICAO,{{ || qesco(-1,0,@fNFANTIGAST,XSN                ) } ,"ANTIGAST"    })
   aadd(aEDICAO,{{ || qesco(-1,0,@fOLDST     ,XSN                ) } ,"OLDST"    })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fPRECO_VEND, "@e 999,999.99")      } ,"PRECO_VED" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDESC_PROD , "99.99"          ) } ,"DESC_PROD" })
  //aadd(aEDICAO,{{ || qgetx(-1,0,@fVLR_DESC  , "@e 999,999.99")      } ,"DESC_PROD"})
   aadd(aEDICAO,{{ || NIL                                            } ,"VLR_DESC"  })

   aadd(aEDICAO,{{ || qgetx(-1,0,@fVL_UNITAR , "@e 9999,999,999.99") } ,"VL_UNITAR" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fQUANTIDADE , "@R 999999.999"      ) } ,"QUANTIDADE"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@fICMS, "99.99"                   ) } ,"ICMS"      })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fIPI, "99.99"                    ) } ,"IPI"      })
  // aadd(aEDICAO,{{ || NIL                                            } ,"IPI"       })
   aadd(aEDICAO,{{ || NIL                                            } ,"TOTAL"     })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fCOMISSAO, "99.99"               ) } ,"COMISSAO"  })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fCOMI_REPRE, "99.99"             ) } ,"COI_REPRE" })

   if CONFIG->Modelo_fat != "B"

      //if left(FAT->Cfop,3) == "120-220"
         aadd(aEDICAO,{{ || view_motdev(-1,0,@fCOD_MOTDEV                ) } ,"MOTDEV"  })
         aadd(aEDICAO,{{ || NIL                                            } ,NIL       })

         aadd(aEDICAO,{{ || view_subsys(-1,0,@fCOD_SUBSYS                ) } ,"SUBSYS"  })
         aadd(aEDICAO,{{ || NIL                                            } ,NIL       })

         aadd(aEDICAO,{{ || view_defeito(-1,0,@fCOD_DEFE                  ) } ,"DEFE"  })
         aadd(aEDICAO,{{ || NIL                                            } ,NIL         })
      //else
      //   aadd(aEDICAO,{{ || NIL                                            } ,NIL       })
      //   aadd(aEDICAO,{{ || NIL                                            } ,NIL       })

      //   aadd(aEDICAO,{{ || NIL                                            } ,NIL       })
      //   aadd(aEDICAO,{{ || NIL                                            } ,NIL       })

      //   aadd(aEDICAO,{{ || NIL                                            } ,NIL         })
      //   aadd(aEDICAO,{{ || NIL                                            } ,NIL         })
      //endif


      aadd(aEDICAO,{{ || view_sit(-1,0,@fCOD_SIT                      ) } ,"COD_SIT"  })
      aadd(aEDICAO,{{ || NIL                                            } ,NIL         })
//      aadd(aEDICAO,{{ || qgetx(-1,0,@fCLASSIF, "@!"                   ) } ,"CLASSIF"  })
      if CONFIG->Modelo_2 == "3"
         aadd(aEDICAO,{{ || qgetx(-1,0,@fNUM_NF, "@999999"            ) } ,"NUM_NF"  })
      endif
   endif
   if CONFIG->Modelo_fat == "B"
     aadd(aEDICAO,{{ || view_prep(-1,0,@fPREP_COD                   )} ,"PREP_COD" })
     aadd(aEDICAO,{{ || NIL                                          } ,NIL        })
   endif

   if CONFIG->Modelo_2 $ "9"
     aadd(aEDICAO,{{ || qgetx(-1,0,@fVLR_II , "@E 99,999,999.99") } ,"VLR_II" })
   endif

   if CONFIG->Modelo_fat == "9"
     aadd(aEDICAO,{{ || qgetx(-1,0,@fN_lote) } ,"N_lote" })
   endif

   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   ITEN_FAT->(qpublicfields())

   iif(cOPCAO=="I",ITEN_FAT->(qinitfields()),ITEN_FAT->(qcopyfields()))

   if cOPCAO == "A"
      XNIVEL := 3
   else
      XNIVEL := 1
	  fOLDST := "N"
	  fNFANTIGAST := "N"
   endif

   XFLAG  := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; ITEN_FAT->(qreleasefields()) ; return ; endif
      if ! i_crit2( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   if ! lCONF ; return ; endif

   // GRAVACAO ______________________________________________________________

   if FAT->(qrlock()) .and. ITEN_FAT->(iif(cOPCAO=="I",qappend(),qrlock()))
      if cOPCAO == "I"
         fNUM_FAT := fCODIGO
         fDATA    := fDT_EMISSAO
      endif

      fDATA    := fDT_EMISSAO
      if CONFIG->Estoque == "S"

      if cOPCAO == "A" // volta o estoque anterior a alteracao, para baixar corretamente a quantidade
         i_baixa_estoque(ITEN_FAT->Quantidade,ITEN_FAT->Reserva,ITEN_FAT->Terceiros)

         //i_mais_pontos(FAT->Cod_Repres,ITEN_FAT->Cod_prod,ITEN_FAT->Quantidade,ITEN_FAT->Vl_unitar)
      endif

      endif
      ITEN_FAT->(qreplacefields())
      ITEN_FAT->(qunlock())

      fTOTAL := fTOTAL + (ITEN_FAT->Vl_unitar*fQUANTIDADE)

      // rotina que baixa o produto do Estoque quando e' confirmado no pedido

      i_entra_estoque(ITEN_FAT->Quantidade)

      //i_menos_pontos(FAT->Cod_Repres,ITEN_FAT->Cod_prod,ITEN_FAT->Quantidade,ITEN_FAT->Vl_unitar)

   else

      iif(cOPCAO=="I",qm1(),qm2())

   endif

return

/////////////////////////////////////////////////////////////////////////////
// CRITICAS NA DESCIDA ______________________________________________________

static function i_crit2 ( cCAMPO )

   qmensa("")

   iif ( cCAMPO == NIL , cCAMPO := "" , NIL )
   if ! XFLAG; return .t.; endif
   do case

      case cCAMPO == "COD_PROD"
           i_totaliza_pedido()

           if CONFIG->Modelo_fat == "1"

              PROD->(dbsetorder(5))
              if PROD->(dbseek(fCOD_PROD))
                 fCOD_PROD := right(PROD->Codigo,5)
              else
                 PROD->(dbsetorder(3))
                 if PROD->(dbseek(fCOD_PROD))
                    fCOD_PROD := right(PROD->Codigo,5)
                 else
                    //qmensa("Produto nao cadastrado!","BL")
                    //return .F.
                 endif
              endif

              PROD->(dbsetorder(4))
           endif

           //if nITENS >= 23
           //   Qmensa("Pedido execedeu a quantidade de itens!!","B")
           //   return .F.
           //endif
           qrsay(XNIVEL,fCOD_PROD:=strzero(val(fCOD_PROD),5))

           INVENT->(DbClearFilter())

           if ! PROD->(dbseek(fCOD_PROD))
              qmensa("Produto n„o encontrado !","B")
              return .F.
           endif
           if CONFIG->Modelo_fat == "1"
              qrsay ( XNIVEL+1 , left(PROD->Descricao,20)+"/"+PROD->Cod_ass+" - "+left(PROD->Cod_fabr,6) )
           else
              qrsay ( XNIVEL+1 , left(PROD->Descricao,38) )
           endif

           INVENT->(DbSetFilter({|| INVENT->Cod_prod == fCOD_PROD .and. INVENT->Filial == FAT->Filial }))

           //qrsay ( XNIVEL+3 , qabrev(PROD->Prod_iss,"SN", {"Sim","N„o"}))

           fPROD_SER:=qabrev(PROD->Prod_iss,"SN", {"2","1"})

           if CONFIG->Modelo_fat == "9"
              fVL_UNITAR := PROD->Preco_unit
           else
              if left(FAT->Cod_cfop,3) $ "510-610-511-540-611-640-512-612-710-711-712-220-221"
                 if CONFIG->Modelo_2 == "8"
                   fVL_UNITAR := PROD->Preco_cons - (PROD->Preco_Cons * (CLI1->Comis_repr/100 ))
                 else
                   fVL_UNITAR := PROD->Preco_cons
                 endif
              else
                 fVL_UNITAR  := PROD->Preco_cust
                 fPRECO_VEND := PROD->Preco_cust
              endif
           endif

           if CONFIG->Modelo_2 == "7"
              fBC_SUBST := PROD->Bc_subst

           //   ITEN_PR->(Dbsetorder(1))
           //   if ITEN_PR->(DbSeek(CLI1->Codigo+right(PROD->Codigo,5)))
           //      fPRECO_VEND := ITEN_PR->Valor
           //   endif
           endif


           fPONTOS := PROD->Pontos
           Return .T.

      case cCAMPO == "DESC_PROD"
           if FAT->Aliq_desc <> 0 .and. fDESC_PROD <> FAT->Aliq_desc
              Qmensa("Desconto no Produto diferente da Aliquota do Pedido!!!","B")
              return .F.
           endif
           fVLR_DESC := fPRECO_VEND * (fDESC_PROD/100)
           fVL_UNITAR := fPRECO_VEND - fVLR_DESC
           qrsay(XNIVEL+1,fVLR_DESC,"@E 999,999.99")
		   fVL_UNITAR := round(fVL_UNITAR,2)
           qrsay(XNIVEL+2,fVL_UNITAR,"@E 99,999,999.99")


      case cCAMPO == "QUANTIDADE"

           if CONFIG->Modelo_2 != "0"
              if empty(fQUANTIDADE) ; return .F. ; endif
           endif

           if CONFIG->Estoque == "S" .and. CONFIG->Modelo_fat != "1"
               INVENT->(dbsetorder(1))
               if ! INVENT->(dbseek(fFILIAL+fCOD_PROD+fNUM_LOTE))
                  qmensa("NÆo Existe Inventario deste Produto ! ","B")
                  return .F.
               endif
           endif

           if CONFIG->Modelo_fat == "1"
               INVENT->(dbsetorder(1))
               if INVENT->(dbseek(fFILIAL+fCOD_PROD+fNUM_LOTE))
                  if left(FAT->Cod_cfop,4) $ "1905-1906-2905-2906"
                     if fQUANTIDADE > (INVENT->Quant_ter)
                        qmensa("Quantidade em terceiros insuficiente ! ","B")
                        return .F.
                     endif
                  endif
               else
                  qmensa("NÆo Existe Inventario deste Produto ! ","B")
                  return .F.
               endif
           endif


           //if CONFIG->Modelo_2 == "3"
           //   if ! ESTOQ->(dbseek(fCOD_PROD))
           //      qmensa("Favor Cadastrar produto na opcao 121!!! ","B")
           //      return .F.
           //   endif
           //endif
      case cCAMPO == "VL_UNITAR"

           if CONFIG->Modelo_2 != "0"
             if empty(fVL_UNITAR) ; return .F. ; endif
           endif

           if cOPCAO == "I" .and. CONFIG->Modelo_fat == "1"
              fCOMI_REPRE := CLI1->Comis_repr
           endif

           if CONFIG->Estoque == "S"
             INVENT->(dbsetorder(1))
             if ! INVENT->(dbseek(fFILIAL+fCOD_PROD+fNUM_LOTE))
                qmensa("N„o Existe Inventario deste produto !","B")
             else
                qmensa("No estoque tem "+ transform(INVENT->Quant_atu,"@E 999,999.99") + " Unidades","B")
             endif
           endif

           CGM->(Dbseek(CLI1->Cgm_ent))
           ESTADO->(Dbseek(CGM->Estado))
           fICMS := ESTADO->Aliq_dest
		   if cOPCAO == "I"
		      fIPI := PROD->Ipi
		   endif

           fCOMISSAO := nCOMISSAO
           if CONFIG->Modelo_2 == "1"
              fCOMISSAO := 7
           endif
           fCALC_DESC := "N"
           fICMS_SUBST := "N"
           fCOD_SIT   := "000"

           Return .t.

      case cCAMPO == "IPI"
           qrsay ( XNIVEL , transform(fIPI, "@E 99.99") )
           qrsay ( XNIVEL+1, transform(fVL_UNITAR*fQUANTIDADE,"@E 9,999,999.99"))
           Return .t.

      case cCAMPO == "CALC_DESC"
           qrsay(XNIVEL,qabrev(fCALC_DESC,"SN",{"Sim","N„o"}))
           Return .t.

      case cCAMPO == "ICMS_SUBST"
           qrsay(XNIVEL,qabrev(fICMS_SUBST,"SN",{"Sim","N„o"}))
           Return .t.

      case cCAMPO == "NUM_LOTE"
           if CONFIG->Estoque == "S"

              if empty(fNUM_LOTE)
                 fNUM_LOTE := "0000000000"
                 qrsay(XNIVEL,fNUM_LOTE)
              else
                 fNUM_LOTE := strzero(val(fNUM_LOTE),10)
                 qrsay(XNIVEL,fNUM_LOTE)
              endif

              INVENT->(Dbsetorder(1))
              if ! INVENT->(dbseek(fFILIAL+fCOD_PROD+fNUM_LOTE))
                 qmensa("N£mero de Lote deste Produto nÆo encontrado...","B")
                 fLOTE := "          "
                 return .F.
              endif


           endif

      case cCAMPO == "PREP_COD"

           qrsay(XNIVEL,fPREP_COD:=strzero(val(fPREP_COD),5))

           if ! PREP->(dbseek(fPREP_COD))
              qmensa("Preposto n„o encontrado !","B")
              return .F.
           endif
           qrsay ( XNIVEL+1 , left(PREP->Descricao,40) )

      case cCAMPO == "COD_SIT"

           qrsay(XNIVEL,fCOD_SIT:=strzero(val(fCOD_SIT),3))

           if ! SIT_TRIB->(dbseek(fCOD_SIT))
              qmensa("Situacao Tributaria n„o encontrada !","B")
              return .F.
           endif
           qrsay ( XNIVEL+1 , left(SIT_TRIB->Descricao,30) )

      case cCAMPO == "MOTDEV"

           if CONFIG->Modelo_fat == "1" //.and. left(FAT->cod_cfop,3) $ "120-220"
              if empty(fCOD_MOTDEV)
                 qmensa("Campo Obrigatorio!","BL")
                 return .F.
              endif
           endif

           if ! empty(fCOD_MOTDEV)

              fCOD_MOTDEV:=strzero(val(fCOD_MOTDEV),2)
              qrsay(XNIVEL,fCOD_MOTDEV)

              if ! MOTDEV->(dbseek(fCOD_MOTDEV))
                 qmensa("Motivo de Devolucao n„o encontrado !","B")
                 return .F.
              endif

              qrsay ( XNIVEL+1 , left(MOTDEV->Descricao,30) )

              SUBSYS->(dbclearfilter())
              SUBSYS->(dbsetfilter({|| COD_MOT == fCOD_MOTDEV }))
              SUBSYS->(dbsetorder(3))

           endif


      case cCAMPO == "SUBSYS"
           if CONFIG->Modelo_fat == "1" //.and. left(FAT->cod_cfop,3) $ "120-220"

              if ! empty(fCOD_SUBSYS)
                 qrsay(XNIVEL,fCOD_SUBSYS)
                 SUBSYS->(dbsetorder(1))
                 if ! SUBSYS->(dbseek(fCOD_SUBSYS))
                    qmensa("Sub-Sistema n„o encontrado !","B")
                    return .F.
                 endif
                 qrsay(XNIVEL+1,left(SUBSYS->Descricao,30))
               else
                  SUBSYS->(dbsetorder(3))
                  if SUBSYS->(dbseek(fCOD_MOTDEV))
                     qmensa("Existe Sub-Sistema pra este motivo, selecione com F9!","B")
                     return .F.
                  endif
               endif


           endif
           DEFEITO->(dbclearfilter())
           DEFEITO->(dbsetfilter({|| Cod_subsys == fCOD_SUBSYS }))


      case cCAMPO == "DEFE"
           if CONFIG->Modelo_fat == "1" //.and. left(FAT->cod_cfop,3) $ "120-220"

              if ! empty(fCOD_DEFE)
                 DEFEITO->(dbsetorder(1))
                 if ! DEFEITO->(dbseek(fCOD_DEFE))
                    qmensa("Defeito n„o encontrado !","B")
                    return .F.
                 endif
                 qrsay(XNIVEL+1,left(DEFEITO->Descricao,30))

              else
                 DEFEITO->(dbsetorder(3))
                 if DEFEITO->(dbseek(fCOD_SUBSYS))
                    qmensa("Existe Defeito pra esse Sub-Sistema, selecione com F9 !","B")
                    return .F.
                 endif


              endif

           endif


           case cCAMPO == "AVARIA"
                if empty(fAVARIADO) ; return .F. ; endif
                qrsay(XNIVEL,qabrev(fAVARIADO,"NS",{"Nao","Sim"}))
				
		   case cCAMPO == "ANTIGAST"
                if empty(fNfAntigaSt) ; return .F. ; endif
                qrsay(XNIVEL,qabrev(fNFAntigaSt,"NS",{"Nao","Sim"}))		
				
		   case cCAMPO == "OLDST"
                if empty(fOLDSt) ; return .F. ; endif
                qrsay(XNIVEL,qabrev(fOLDSt,"NS",{"Nao","Sim"}))		



   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXCLUIR ITENS DO PEDIDO  _____________________________________

static function i_exc_itens_fat

   if qconf("Confirma exclus„o do Produto ?")
   
      if ! empty(FAT->NFe)
	     qmensa("Nao e permitido excluir iten de NFe Emitida pela propria Empresa!","BL")
		 return .F.
	  endif

      i_baixa_estoque(ITEN_FAT->Quantidade,ITEN_FAT->Reserva,ITEN_FAT->Terceiros)

      //i_mais_pontos(FAT->Cod_Repres,ITEN_FAT->Cod_prod,ITEN_FAT->Quantidade,ITEN_FAT->Vl_unitar)



      if ITEN_FAT->(qrlock())
         ITEN_FAT->(dbdelete())
         ITEN_FAT->(qunlock())
      else
         qm3()
      endif
   endif

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA DEVOLUCAO de ITENS DO PEDIDO  _____________________________________


////////////////////////////////////////////////////////////////////////////////////
static function i_atu_lanc
if CONFIG->Modelo_fat == "1"
   ITEN_FAT->(qview({{"f202m1()/Cod."                                       ,0},;
                     {"f202a()/Descri‡„o"                                    ,0},;
                     {"f202m()/Ref."                                         ,0},;
                     {"transform(Vl_unitar, '@E 99,999,999.99')/Vl.Unit."    ,0},;
                     {"transform(Quantidade,'@E 99999.99')/Quant."           ,0},;
                     {"f202b()/Un."                                          ,0},;
                     {"f202c()/Val. Total"                                   ,0}},;
                     "16002179S",;
                     {NIL,NIL,NIL,NIL},;
                     {"ITEN_FAT->Num_fat == FAT->Codigo",{||f202top()},{||f202bot()}},;
                    "<ESC> para sair" ))
else
   ITEN_FAT->(qview({{"Cod_prod/Cod."                                       ,2},;
                     {"f202a()/Descri‡„o"                                    ,0},;
                     {"transform(Vl_unitar, '@E 99,999,999.99')/Vl.Unit."    ,0},;
                     {"transform(Quantidade,'@E 99999.99')/Quant."           ,0},;
                     {"f202b()/Un."                                          ,0},;
                     {"f202c()/Val. Total"                                   ,0}},;
                     "16002179S",;
                     {NIL,NIL,NIL,NIL},;
                     {"ITEN_FAT->Num_fat == FAT->Codigo",{||f202top()},{||f202bot()}},;
                    "<ESC> para sair" ))

endif

return ""

static function i_totaliza_pedido

   local nREC   := ITEN_FAT->(recno())
   local nINDEX := ITEN_FAT->(indexord())
   nITENS := 0
   nTOT_PED := 0
   fTOTAL := 0
   nTOT_PROD := 0
   nTOT_IPI  := 0
   nDESC := 0
   nTOT_DESC := 0
   ITEN_FAT->(dbsetorder(2))
   ITEN_FAT->(dbgotop())
   ITEN_FAT->(dbseek(FAT->Codigo))

   do while ! ITEN_FAT->(eof()) .and. ITEN_FAT->Num_fat == FAT->Codigo
      PROD->(dbsetorder(4))
      PROD->(dbseek(ITEN_FAT->Cod_prod))
      if ITEN_FAT->Icms <> 0
         nTOT_IPI := nTOT_IPI + ( ( (ITEN_FAT->Quantidade*ITEN_FAT->Vl_unitar) * ITEN_FAT->Ipi) / 100)
      endif

      fTOTAL    := fTOTAL + (ITEN_FAT->Quantidade*ITEN_FAT->Vl_unitar)
      nITENS++
      ITEN_FAT->(Dbskip())
   enddo
   if CONFIG->Modelo_2 == "2"
      nDESC := FAT->Aliq_desc
      nTOT_DESC := nDESC
      fTOTAL := fTOTAL - nTOT_DESC + nTOT_IPI
   else
      nDESC := FAT->Aliq_desc
      nTOT_DESC := (fTOTAL + nTOT_IPI) * (nDESC/100)
      fTOTAL := (fTOTAL + nTOT_IPI) - nTOT_DESC
   endif

   ITEN_FAT->(dbsetorder(nINDEX))
   ITEN_FAT->(dbgoto(nREC))

return

static function i_imprime

   local cTITULO
   local nTOT_PROD := nLIN := nTOT_BRU := nPROD := nICMS_SUBS := 0
   local nALIQ_ICMS := 0
   local nIPI := 0
   local nICMS := 0
   cTITULO := "LISTAGEM DO PEDIDO No."+CODIGO+"   Data Emissao: "+dtoc(FAT->Dt_emissao)

   PROD->(Dbsetorder(4))

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif

   if ! qlineprn() ; return ; endif

   if XPAGINA == 0 .or. prow() > K_MAX_LIN
      qpageprn()
      @ prow(),pcol() say XCOND0
      qcabecprn(cTITULO,80)
      CLI1->(Dbseek(FAT->Cod_cli))
      VEND->(Dbseek(FAT->Cod_vended))
      CGM->(Dbseek(CLI1->Cgm_cob))
      if CONFIG->Modelo_2 == "1" .and. CLI1->Codigo == "00001"
         @ prow()+1,0 say "Cliente : "+CLI1->Codigo + " - " + left(FAT->Tb_nome,36) + "  Telefone: "+ FAT->Tb_Tel
         @ prow()+1,0 say "Endereco: "+left(FAT->TB_End,32) + " - " + left(FAT->Tb_cid,15) + " CPF: "+FAT->Tb_Cpf
         @ prow()+1,0 say "Representante: "+VEND->Codigo + " - " + left(VEND->Nome,32)  + "      " + FAT->Tb_Bai
         CFOP->(Dbseek(FAT->Cod_cfop))
         @ prow()+1,0 say "Nat. de Operacao: " + FAT->Cod_Cfop + "- " + left(CFOP->Nat_desc,30)
         @ prow()+1,0 say "Observacao: "+left(FAT->Obs,70)
         @ prow()+2,0 say replicate("-",80)
      else
         @ prow()+1,0 say "Cliente : "+CLI1->Codigo + " - " + left(CLI1->Razao,36) + "  Telefone: "+ CLI1->Fone1
         @ prow()+1,0 say "Fantasia: "+CLI1->Fantasia + " " + "Inscricao Estadual.: " + CLI1->Inscricao
         @ prow()+1,0 say "Endereco: "+left(CLI1->End_cob,32) + " - " + left(CGM->Municipio,15) + " CGC: "+CLI1->Cgccpf
         @ prow()+1,0 say "Representante: "+VEND->Codigo + " - " + left(VEND->Nome,32)  + "      " + CLI1->Bairro_cob
         CFOP->(Dbseek(FAT->Cod_cfop))
         @ prow()+1,0 say "Nat. de Operacao: " + FAT->Cod_cfop + "- " + left(CFOP->Nat_desc,30)
         @ prow()+1,0 say "Observacao: "+left(FAT->Obs,70)
         @ prow()+1,0 say replicate("-",80)
      endif
   endif

   @ prow(),pcol() say XCOND0
   @ prow()+1,0 say "Codigo  Qtde                  Produto                       Unitario       Total"
   @ prow()+1,0 say ""

   ITEN_FAT->(Dbseek(FAT->Codigo))

   do while ! ITEN_FAT->(eof()) .and. ITEN_FAT->Num_fat == FAT->Codigo

      PROD->(Dbseek(ITEN_FAT->Cod_prod))
      @ prow()+1,0  say left(PROD->Cod_fabr,4)
      @ prow()  ,6  say transform(ITEN_FAT->Quantidade, "@E 99999.99")
      @ prow()  ,16 say left(PROD->Descricao,18)
      @ prow()  ,36 say PROD->cOD_aSS
      @ prow()  ,46 say left(PROD->Marca,10)

      if ! empty(PROD->Desconto) .and. ITEN_FAT->Calc_desc == "S"
         nDESC := PROD->Desconto/100
      else
         nDESC := 1
      endif

      @ prow()  ,58 say transform(round(ITEN_FAT->Vl_unitar * nDESC,2), "@E 999,999.99")
      @ prow()  ,70 say transform(ITEN_FAT->Quantidade * round(ITEN_FAT->Vl_unitar * nDESC,2), "@E 999,999.99")
      nTOT_PROD  := nTOT_PROD +  (ITEN_FAT->Quantidade * round(ITEN_FAT->Vl_unitar * nDESC,2))
      nALIQ_ICMS := ITEN_FAT->Icms

      nIPI  +=  ( ( ITEN_FAT->Quantidade * ITEN_FAT->Vl_unitar ) * ( ITEN_FAT->Ipi / 100 ) )
      nICMS += ( ( ITEN_FAT->Quantidade * ITEN_FAT->Vl_unitar  ) * (ITEN_FAT->Icms/100) )


      if ITEN_FAT->ICMS_SUBST == "S" // soma somente os produtos com icms subst. tributaria nos itens do pedido
         nICMS_SUBS := nICMS_SUBS +  (ITEN_FAT->Quantidade * round(ITEN_FAT->Vl_unitar * nDESC,2))
      endif

      nLIN++
      ITEN_FAT->(Dbskip())

   enddo

   DUP_FAT->(Dbsetorder(1))
   DUP_FAT->(Dbgotop())

   @ prow()+1,0 say replicate("-",80)

   if DUP_FAT->(Dbseek(FAT->Codigo+"01"))
      do while ! DUP_FAT->(eof()) .and. left(DUP_FAT->Num_fat,5) == FAT->Codigo
         if DUP_FAT->Valor = 0
            exit
         endif
         @ prow()+1,00 say "Fatura No.: " + left(DUP_FAT->Num_fat,5)+"/"+Right(DUP_FAT->Num_fat,2)
         @ prow()  ,22 say "Vencimento: " + dtoc(DUP_FAT->Data_venc)
         @ prow()  ,62 say "Valor : "+ alltrim(transform(DUP_FAT->Valor , "@E 999,999,999.99"))
         DUP_FAT->(Dbskip())
      enddo
   endif

   @ prow()+1,0 say replicate("-",80)

   @ prow()+1,41 say " Valor dos Produtos      >"+transform(nTOT_PROD, "@E 99,999,999.99")
   @ prow()+1,41 say " Valor do  IPI           >"+transform(nIPI,  "@E 99,999,999.99")
   @ prow()+1,41 say " Valor do  ICMS          >"+transform(nICMS, "@E 99,999,999.99")

   @ prow()+1,41 say " Valor do Pedido         >"+transform( nTOT_PROD+nIPI , "@E 99,999,999.99")
   @ prow()+1,0 say replicate("-",80)


   qstopprn(.F.)

return

static function i_mais_pontos(cCOD_REPRES,cCOD_PROD,nQUANT,nPRECO)
local nREG   := 0
local nINDEX := 0
local nPONTOS := 0

nREG   := PROD->(Recno())
nINDEX := PROD->(IndexOrd())

MILHAS->(Dbsetorder(2))

PROD->(Dbsetorder(4))

if PROD->(dbseek(cCOD_PROD))
   nPONTOS := PROD->Pontos
else
   nPONTOS := 0
endif

if left(FAT->Cod_cfop,3) $ "120-220"
   if MILHAS->(Dbseek(cCOD_REPRES))
      if MILHAS->(Qrlock()) .and. FAT->Dt_emissao >= MILHAS->Data_ini
         replace MILHAS->Pontos with MILHAS->Pontos + ( (nPRECO * nQUANT) * nPONTOS )
      endif
   endif
endif

PROD->(dbgoto(nREG))
PROD->(dbsetorder(nINDEX))

return

static function i_menos_pontos(cCOD_REPRES,cCOD_PROD,nQUANT,nPRECO)
local nREG   := 0
local nINDEX := 0
local nPONTOS := 0




nREG   := ITEN_FAT->(Recno())
nINDEX := ITEN_FAT->(IndexOrd())

MILHAS->(dbsetorder(2))

PROD->(Dbsetorder(4))

if PROD->(dbseek(cCOD_PROD))
   nPONTOS := PROD->Pontos
else
   nPONTOS := 0
endif


if left(FAT->Cod_cfop,3) $ "120-220"
   if MILHAS->(Dbseek(cCOD_REPRES))
      if MILHAS->(Qrlock()) .and. FAT->Dt_emissao >= MILHAS->Data_ini
         replace MILHAS->Pontos with MILHAS->Pontos - ( (nPRECO * nQUANT) * nPONTOS )
      endif
   endif
endif

PROD->(dbgoto(nREG))
PROD->(dbsetorder(nINDEX))

return

static function i_make_ret(cCODFAT)


  PEND->(qrlock())

  FAT->(qpublicfields())
  FAT->(qcopyfields())

  if ! PEND->(qappend())
    qmensa("N„o foi possivel duplicar, tente novamente...","B")
  else

    if CONFIG->(qrlock())
       replace CONFIG->Cod_pend with CONFIG->Cod_pend + 1
       CONFIG->(qunlock())
    endif

    fCODIGO := strzero(CONFIG->Cod_pend,5)
    qmensa("C¢digo Gerado: "+fCODIGO,"B")

    fNUM_FATURA := "      "
    fNUM_REF    := "      "
    fES := "S"
    fCONSERTO  := .F.
    fCANCELADO := .F.
    fFECHADO   := .F.
    fOBS       := rtrim(fOBS)+" REF. NF.: "+ FAT->Ref_NumNf

    if left(fCOD_CFOP,4) == "1915"
       fCOD_CFOP := "5916"
    endif

    if left(fCOD_CFOP,4) == "2915"
       fCOD_CFOP := "6916"
    endif

    if left(fCOD_CFOP,4) == "2949"
       fCOD_CFOP := "6949"
    endif

    if left(fCOD_CFOP,4) == "1949"
       fCOD_CFOP := "5949"
    endif




    PEND->(qreplacefields())
    FAT->(qreleasefields())


    if ITEN_FAT->(dbseek(cCODFAT))
       do while ! ITEN_FAT->(eof()) .and. ITEN_FAT->Num_fat == cCODFAT
          ITEM_PEN->(qrlock())
          ITEN_FAT->(qpublicfields())
          ITEN_FAT->(qcopyfields())
          nREC := ITEN_FAT->(recno())
          ITEM_PEN->(qappend())
          fCOD_PEND := strzero(CONFIG->Cod_pend,5)
          fQUANT_PED := fQUANTIDADE
          ITEM_PEN->(qreplacefields())
          ITEN_FAT->(dbgoto(nREC))

          ITEN_FAT->(dbskip())
          ITEN_FAT->(qreleasefields())
          ITEN_FAT->(qunlock())


       enddo
    endif
  endif


  FAT->(qunlock())

return

static function i_abre_cred()
local labriu := .F.

   if ! quse(XDRV_RB,"CRED_CLI",{""})
      Qmensa("Nao foi possivel abrir arquivo CRED_CLI.DBF !","B")
      lAbriu := .F.
   else
      lAbriu := .T.
   endif
return lAbriu

static function i_grava_cred(cVALOR)

   if left(FAT->Cod_cfop,4) $ "1202-2202"

      i_Abre_cred()

      if ! quse(XDRV_RB,"CONFIG",,,"CFGRB")
         Qmensa("Nao foi possivel abrir arquivo CONFIG.DBF QRB !","B")
         return .F.
      endif


      if cOPCAO == "I"
         if CRED_CLI->(qappend())
            replace CRED_CLI->Codigo      with strzero(CFGRB->Cod_cred + 1,5)
            replace CRED_CLI->Cod_cli     with FAT->Cod_cli
            replace CRED_CLI->Valor       with cVALOR
            replace CRED_CLI->Data_emiss  with FAT->Dt_emissao
            replace CRED_CLI->Cliente     with FAT->cliente
            replace CRED_CLI->Num_fatura  with FAT->Num_fatura
            replace CRED_CLI->Filial      with FAT->Filial
         endif
      else
         if cOPCAO == "A"
            CRED_CLI->(dbsetorder(5))
            if CRED_CLI->(qrlock()) .and. CRED_CLI->(dbseek(FAT->Num_fatura))
               replace CRED_CLI->Cod_cli     with FAT->Cod_cli
               replace CRED_CLI->Valor       with cVALOR
               replace CRED_CLI->Data_emiss  with FAT->Dt_emissao
               replace CRED_CLI->Cliente     with FAT->cliente
               replace CRED_CLI->Num_fatura  with FAT->Num_fatura
               replace CRED_CLI->Filial      with FAT->Filial
            endif
         endif
      endif

      CRED_CLI->(dbCommit())

      if CFGRB->(Qrlock())
         if cOPCAO == "I"
            replace CFGRB->Cod_cred with val(CRED_CLI->Codigo)
         endif
      endif

      CFGRB->(dbclosearea())
      CRED_CLI->(DbcloseArea())

      Select FAT
  endif

return

static function i_exc_cred()

   i_Abre_cred()
   CRED_CLI->(dbsetorder(5))
   CRED_CLI->(dbseek(FAT->Num_fatura))

   while ! CRED_CLI->(eof()) .and. CRED_CLI->Num_fatura == FAT->Num_fatura

        if CRED_CLI->(qrlock())
           CRED_CLI->(dbdelete())
           CRED_CLI->(qunlock())
        endif

        CRED_CLI->(Dbskip())
   enddo

   CRED_CLI->(dbcloseArea())

   select FAT

return

static function i_baixa_estoque(nQTY,nRESERVA,nTERCEIROS) //Executa estoques...
local nMANTRA := 0
local nIGI    := 0
local nTT     := 0

INVENT->(dbsetorder(1))


       if INVENT->(dbseek(FAT->Filial+ITEN_FAT->Cod_prod+ITEN_FAT->Num_lote))
          if INVENT->(qrlock())
             replace INVENT->Quant_atu with INVENT->Quant_atu - nQTY
             INVENT->(Qunlock())

             //if left(FAT->Cod_cfop,4) $ "1915-2915"
             if ITEN_FAT->Avariado == "S"
                INVENT->(Qrlock())
                replace INVENT->Quant_atu  with INVENT->Quant_atu  + nQTY
                replace INVENT->Quant_defe with INVENT->Quant_defe - nQTY
                INVENT->(Qunlock())
                i_deleta_avar()
                select ITEN_FAT
             endif



          endif
        else
           qmensa("Lote nao encontrado nesta Filial !","B")
           return .F.
       endif

return

static function i_entra_estoque(nQTY) //Executa estoques...
local nRESERVA   := 0
local nTERCEIROS := 0
local nTT      := 0
local nMANTRA := 0
local nIGI   := 0

INVENT->(dbsetorder(1))


      if INVENT->(dbseek(FAT->Filial+ITEN_FAT->Cod_prod+ITEN_FAT->Num_lote))

         INVENT->(Qrlock())
         replace INVENT->Quant_atu with INVENT->Quant_atu + nQTY
         INVENT->(Qunlock())

         if ITEN_FAT->Avariado == "S"
            if INVENT->(Qrlock())
               replace INVENT->Quant_atu  with INVENT->Quant_atu  - nQTY
               replace INVENT->Quant_defe with INVENT->Quant_defe + nQTY
               INVENT->(Qunlock())
            endif
            i_make_avar(FAT->Dt_emissao,FAT->Filial,ITEN_FAT->Cod_prod,ITEN_FAT->Quantidade,ITEN_FAT->vl_unitar,ITEN_FAT->Num_lote,FAT->codigo)
            select ITEN_FAT

         endif

       else
          qmensa("Lote nao encontrado nesta Filial !","B")
          return .F.
      endif

return


static function i_make_avar(pData,pFILIAL,pCOD_PROD,pQuantidade,pVal,PLote,pCODIGO)

   if ! quse(XDRV_ES,"AVARIADO",{"AVARIAD1","AVARIAD2","AVARIAD3","AVARIAD4","AVARIAD5","AVARIAD6","AVARIAD7"})
      qmensa("Nao foi possivela abrir arquivo de Avarias!","BL")
   endif

   if AVARIADO->(qappend())
      replace AVARIADO->Data       with pData
      replace AVARIADO->Filial     with pFilial
      replace AVARIADO->Cod_prod   with pCOD_PROD
      replace AVARIADO->Quantidade with pQuantidade
      replace AVARIADO->Val_uni    with pVal
      replace AVARIADO->Lote       with pLOTE
      replace AVARIADO->Obs        with "NF Conserto No.: "+FAT->Num_fatura
      replace AVARIADO->Fat_cod    With pCODIGO
   endif

   AVARIADO->(dbCommit())
   AVARIADO->(dbclosearea())

return

static function i_deleta_avar()

   if ! quse(XDRV_ES,"AVARIADO",{"AVARIAD1","AVARIAD2","AVARIAD3","AVARIAD4","AVARIAD5","AVARIAD6","AVARIAD7"})
      qmensa("Nao foi possivela abrir arquivo de Avarias!","BL")
      return .F.
   endif

   AVARIADO->(dbsetorder(7))
   if AVARIADO->(dbseek(FAT->Codigo))
      do while ! AVARIADO->(eof()) .and. AVARIADO->fat_cod == FAT->Codigo
         if AVARIADO->Cod_prod  == ITEN_FAT->Cod_prod
            if AVARIADO->(qrlock())
               AVARIADO->(dbdelete())
               AVARIADO->(Qunlock())
            else
               qmensa("Nao foi possivel travar AVARIA pra exclusao!","BL")
               return .F.
            endif
         endif
         AVARIADO->(dbskip())
      enddo
   else
      qmensa("Nao encontrado registro nas AVARIAS - (112) !","BL")
      return .F.
   endif

   AVARIADO->(dbclosearea())

return

static function i_Descancela
    if ! FAT->Cancelado
       qmensa("Esta Nota Fiscal nao esta Cancelada!!!","B")
       return .F.
    endif

    if qconf("Cofirma reversao de cancelamento de Nota Fiscal?")

       /// rotina para voltar o estoque dos produtos digitados no Pedido Cancelado!

       ITEN_FAT->(Dbgotop())
       ITEN_FAT->(Dbseek(FAT->Codigo))

       do while ! ITEN_FAT->(eof()) .and. ITEN_FAT->Num_fat == FAT->Codigo

          INVENT->(dbclearfilter())
          INVENT->(dbsetorder(1))

          i_entra_estoque(ITEN_FAT->Quantidade)

          //i_menos_pontos(FAT->Cod_Repres,ITEN_FAT->Cod_prod,ITEN_FAT->Quantidade,ITEN_FAT->Vl_unitar)

          ITEN_FAT->(Dbskip())

       enddo

       FAT->(qrlock())
       replace FAT->Cancelado with .F.
       replace FAT->Obs With " "
       FAT->(qunlock())


    endif
return





