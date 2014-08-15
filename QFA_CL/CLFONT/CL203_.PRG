/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO COMERCIO
// OBJETIVO...: LANCAMENTO DE PEDIDO DE VENDA
// ANALISTA...:
// PROGRAMADOR: EDUARDO BORIO
// INICIO.....: MARCO DE 1997
// OBS........:
// ALTERACOES.: EDUARDO AUGUSTO BORIO

function cl203
#include "inkey.ch"

private fDIA1 := fDIA2 := fDIA3 := fDIA4 := fDIA5 := fDIA6 := fDIA7 := nDES := 0
private fVALOR1 := fVALOR2 := fVALOR3 := fVALOR4 := fVALOR5 := fVALOR6 := fVALOR7 := 0
private fTOTAL := 0
private fPEDIDO := 0
private fIPI_VLR := 0
private fST_VLR  := 0
private nITENS := 0
private fPARC  := 0
private nCOMISSAO := 0
private lALT   := .F.
private sBLOC1  := qlbloc("B201D","QBLOC.GLO")
private sBLOC2  := qlbloc("B201ES","QBLOC.GLO")
private sBLOC3  := qlbloc("B203FR","QBLOC.GLO")
private sBLOC4  := qlbloc("B201DP","QBLOC.GLO")

CCUSTO->(Dbsetorder(4))

/////////////////////////////////////////////////////////////////////////////
// MANUTENCAO DE PEDIDO DE VENDA ___________________________________________
//PEND->(dbsetfilter({|| PEND->Es == "S"}))

PEND->(qview({{"Codigo/Pendencia"         ,1},;
             {"Dt_emissao/Emissao"        ,2},;
             {"i_203obs()/Obs"            ,0},;
             {"left(Cliente,25)/Cliente"  ,3},;
             {"i_203b()/Centro Custo",0},;
             {"Pedido/Pedido",0}},"P",;
             {NIL,"i_203c",NIL,NIL},;
              NIL,q_msg_acesso_usr()+"/im<P>rime/ <G>era Pedido"))
return

//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAGEM DO CLIENTE ______________________________________________

function i_203a
   CLI1->(dbseek(PEND->Cod_cli))
return left(CLI1->Razao,25)

function i_203obs
    OBSERVP->(dbseek(PEND->Codigo))
return iif(!empty(OBSERVP->Obs1),"Sim","   ")


//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAGEM DO CENTRO DE CUSTO  _____________________________________

function i_203b
   CCUSTO->(dbseek(PEND->C_custo))
return left(CCUSTO->Descricao,18)

//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO _____________________________________

function i_203c

   local nCURSOR := setcursor(1)
   local cOrdem := ""
   local sbloc1  := qlbloc("B201OP","QBLOC.GLO")
   
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))

     if cOPCAO == "P" 
	    qesco(15,15,@cOrdem,sbloc1)
	    i_imprime( cOrdem )
	 endif	
		
	 if(empty(CONFIG->Qsysoff))
	    iif(cOPCAO == "G", i_gera_pedido(),)
        iif(cOPCAO == "T", i_teste_mostra(),)
        iif(cOPCAO == "M", i_mudanomecli(),)
        iif(cOPCAO == "O", i_Observacao(),)
	 endif
		
     


   if cOPCAO $ XUSRA .and. empty(CONFIG->Qsysoff)

      iif(cOPCAO == "A", lALT := .T.,)

      if CONFIG->Modelo_2 $ "9"
        qlbloc(5,0,"B201AK","QBLOC.GLO",1)
      elseif CONFIG->Modelo_fat == "8"
        qlbloc(5,0,"B201M","QBLOC.GLO",1)
      elseif CONFIG->Modelo_2 == "2"
        qlbloc(5,0,"B201R","QBLOC.GLO",1)
      else
        qlbloc(5,0,"B203A","QBLOC.GLO",1)
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

   fDIA1 := fDIA2 := fDIA3 := fDIA4 := fDIA5 := fDIA6 := fDIA7 :=  0
   fVALOR1 := fVALOR2 := fVALOR3 := fVALOR4 := fVALOR5 := fVALOR6 := fVALOR7 := 0
   fTOTAL := 0
   fPRODS := 0
   nCOMISSAO:= 0
   fPARC  := 0

// MONTA DADOS NA TELA ___________________________________________________________

   if cOPCAO <> "I"

      XNIVEL := 1

      qsay ( 06,17 , PEND->Codigo           )
      qsay ( 06,42 , dtoc(PEND->Dt_Emissao) )
      qsay ( 06,68 , dtoc(PEND->Data_ped ) )
      qsay ( 07,24 , PEND->Cod_Cli          ) ; CLI1->(dbseek(PEND->Cod_cli))
      qsay ( 07,32 , left(CLI1->Razao,30)  )

      qsay ( 08,17 , PEND->Cod_vended       ) ; VEND->(dbseek(PEND->Cod_vended))
      qsay ( 08,25 , left(VEND->Nome,16)   )

      //qsay(08,08,left(PEND->USER,10))
      //qsay(08,29,left(PEND->USER_ALT,10))

      qsay ( 08,51 , PEND->Cod_repres       ) ; REPRES->(dbseek(PEND->Cod_repres))
      qsay ( 08,57 , left(REPRES->Razao,21)   )

      if CONFIG->Modelo_fat == "1"
         qsay ( 09,24,  qabrev(PEND->Boleto,"123456789", {"Boleto","Pgto a Vista - Boleto","Pgto a Vista - Deposito","Antecipado","Nulo","Plano MKT","Abater Credito","Segurar Duplicata","a Prazo - Deposito"}))

      else
         qsay ( 09,24 , PEND->Filial           ) ; FILIAL->(dbseek(PEND->Filial))
         qsay ( 09,31 , left(FILIAL->Razao,30))
      endif

      qsay ( 10,24 , PEND->C_custo          ) ; CCUSTO->(dbseek(PEND->C_custo))
      qsay ( 10,31 , left(CCUSTO->Descricao,15))

      if CONFIG->Modelo_2 $ "9"
         PROD->(dbsetorder(1))
         qsay ( 10,61 , PEND->Cod_di            ) ; PROD->(dbseek(PEND->Cod_Di))
         qsay ( 10,66 , left(PROD->Descricao,12) )
      else
         qsay ( 10,67 , PEND->Pedido  )
      endif

      qsay ( 11,24 , PEND->Cod_transp       ) ; TRANSP->(dbseek(PEND->Cod_transp))
      qsay ( 11,32 , left(TRANSP->Razao,30))
      qsay ( 12,24 , transform(PEND->Cod_cfop,"@R 9.999")) ; CFOP->(dbseek(PEND->Cod_cfop))
      qsay ( 12,32 , left(CFOP->Nat_desc,38))

      if  CONFIG->Modelo_fat == "8"
        qsay ( 13,24 , transform(PEND->cfop2,"@R 9.999")) ; CFOP->(dbseek(PEND->cfop2))
        qsay ( 13,32 , left(CFOP->Nat_desc,38))
      else
        if CONFIG->Modelo_2 == "2"
           qsay( 13,24,PEND->Condic) ; COND->(dbseek(PEND->Condic))
           qsay( 13,29,COND->Descricao )
        else
           qsay ( 13,21 , PEND->Tiposub          ) ; TIPOCONT->(dbseek(PEND->Tiposub))
           qsay ( 13,30,  alltrim(TIPOCONT->Descricao))
        endif
      endif

      qsay ( 14,27,  qabrev(PEND->Desc_sn,"SN", {"Sim","N„o"}))
      qsay ( 14,50,  qabrev(PEND->Es     ,"S", {"Saida"}))

      if CONFIG->Modelo_2 == "2"
         qsay ( 14,71, transform(PEND->Aliq_desc,"@E 9999.99")    )
      else
         qsay ( 14,73, transform(PEND->Aliq_desc,"@E 99.99")    )
      endif
      qsay ( 15,14 , Left(PEND->Obs,43)             )
      qsay ( 15,70,  qabrev(PEND->Frete    ,"12", {"1 - Cif","2 - Fob"}))


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

   if lALT
      aadd(aEDICAO,{{ || NIL                                               } ,NIL       })
   else
      aadd(aEDICAO,{{ || qgetx(6,68,@fDATA_PED  ,"@D",                    )} ,"DATA_PED"     })
   endif



   //aadd(aEDICAO,{{ || qgetx(6,68,@fDATA_PED  ,"@D",                    )} ,"DATA_PED"   })

   aadd(aEDICAO,{{ || view_cli2(7,24,@fCOD_CLI                          )} ,"COD_CLI"      })
   aadd(aEDICAO,{{ || NIL },NIL }) // razao do cliente

   aadd(aEDICAO,{{ || view_vend(8,17,@fCOD_VENDED                      )} ,"COD_VENDED"   })
   aadd(aEDICAO,{{ || NIL },NIL }) // nome do vendedor
   //aadd(aEDICAO,{{ || NIL },NIL }) // nome do vendedor

   aadd(aEDICAO,{{ || view_repres(8,51,@fCOD_REPRES                      )} ,"COD_REPRES"   })
   aadd(aEDICAO,{{ || NIL },NIL }) // nome do representante

   if CONFIG->Modelo_fat == "1"
      aadd(aEDICAO,{{ || qesco(9,24,@fBOLETO      ,sBLOC4                    )}   ,"BOLETO"  })
   else
      aadd(aEDICAO,{{ || view_filial(9,24,@fFILIAL                        )} ,"FILIAL"       })
      aadd(aEDICAO,{{ || NIL },NIL }) // descricao da filial
   endif

   aadd(aEDICAO,{{ || view_ccusto(10,24,@fC_CUSTO                       )} ,"C_CUSTO"      })
   aadd(aEDICAO,{{ || NIL },NIL }) // descricao do centro

   if CONFIG->Modelo_2 $ "9"
      aadd(aEDICAO,{{ || view_familia(10,61,@fCOD_DI                     )} ,"COD_DI"      })
      aadd(aEDICAO,{{ || NIL },NIL }) // descricao da DI
   else
      aadd(aEDICAO,{{ || qgetx(10,67,@fPEDIDO ,"999999",                    )} ,"PEDIDO"     })
   endif

   aadd(aEDICAO,{{ || view_transp(11,24,@fCOD_TRANSP                    )} ,"COD_TRANSP"      })
   aadd(aEDICAO,{{ || NIL },NIL }) // descricao da Transportadora

   if cOPCAO == "I" .or. left(XUSRIDT,5) == "BASSO"
      aadd(aEDICAO,{{  || view_cfop(12,24,@fCOD_CFOP                       )} ,"COD_CFOP"     })
      aadd(aEDICAO,{{ || NIL },NIL }) // descricao da natureza de operacao
   endif

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

   if CONFIG->Modelo_2 == "2"
      aadd(aEDICAO,{{ || qgetx(14,71,@fALIQ_DESC,"9999.99",NIL              )}   ,"ALIQ_DESC"  })
   else
      aadd(aEDICAO,{{ || qgetx(14,73,@fALIQ_DESC,"99.99",NIL              )}   ,"ALIQ_DESC"  })
   endif

   aadd(aEDICAO,{{ || qgetx(15,14,@fOBS,"@!S43",NIL                    )}   ,"OBS"        })
   aadd(aEDICAO,{{ || qesco(15,70,@fFRETE      ,sBLOC3                    )}   ,"FRETE"         })


   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO ____________________________________________________

   do while .T.
      qgirabarra()

      PEND->(qpublicfields())

      iif(cOPCAO=="I", PEND->(qinitfields()), PEND->(qcopyfields()))

      if cOPCAO  == "I"
         fDATA_LANC := date()
      endif

      fFILIAL := "0001"

      XNIVEL := 2
      XFLAG := .T.

      // LOOP PARA ENTRADA DOS CAMPOS ____________________________________________

      do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
         eval ( aEDICAO [XNIVEL,1] )
         if eval ( bESCAPE );PEND->(qreleasefields());return;endif
         if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
         iif ( XFLAG , XNIVEL++ , XNIVEL-- )
         qmensa("")
      enddo

      if ! lCONF ; return ; endif

      if CONFIG->(qrlock())

         // AQUI INCREMENTA CODIGO DO PEDIDO DE VENDA ____________

         if cOPCAO == "I"
            replace CONFIG->Cod_pend with CONFIG->Cod_Pend + 1
            qsay(6,17,fCODIGO := strzero(CONFIG->Cod_pend,5) )
            qmensa("C¢digo Gerado: "+fCODIGO,"B")
         endif

      else
         iif(cOPCAO=="I",qm1(),qm2())
      endif

      if PEND->(iif(cOPCAO=="I",qappend(),qrlock()))

         // AGORA GRAVA E DESTRAVA ARQUIVO _____________________________________

         fFATURAR := .F.

         PEND->(qreplacefields())
         replace PEND->Cliente with fCLIENTE
      endif

      dbunlockall()

      i_proc_lanc()
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

      case cCAMPO == "CODIGO"
           if lALT
              fDATA_LANC := date()
           endif

      case cCAMPO == "DT_EMISSAO"

           if empty(fDT_EMISSAO) ; return .F. ; endif

           if cOPCAO == "I"
              fUSER     := XUSRIDT
              fUSER_ALT := XUSRIDT
           endif

           if cOPCAO != "I"
              fUSER_ALT := XUSRIDT
           endif

           //qsay(08,08,left(fUSER,10))
           //qsay(08,28,left(fUSER_ALT,10))


           if CONFIG->Modelo_fat == "1"
              if cOPCAO == "I"
                 fC_CUSTO := "0005"
                 fFILIAL := "0001"
                 //fCOD_VENDED := "00001"
                 sDESC_SN := "N"
              endif
              fES := "S"
           endif


      case cCAMPO == "COD_CLI"

           if empty(fCOD_CLI) ; return .F. ; endif


           qsay(7,24,fCOD_CLI:=strzero(val(fCOD_CLI),5))
           if ! CLI1->(dbseek(fCOD_CLI))
              qmensa("Cliente n„o encontrado !","B")
              return .F.
           endif

           qsay(7,32,left(CLI1->Razao,40))
          // if empty(CLI1->Conta_cont)
          //    qmensa("Aten‡„o !! Conta Cont bil n„o informada !!","B")
          // endif

           if RESTRI->(dbseek(fCOD_CLI))
              qmensa("Cliente com Restricao, inclusao negada!","B")
			  alert("Cliente com restricao, o lancamento sera permitido, mas nao sera possivel liberar o Pedido!!",{"OK"},"N/BG")
           endif


//           if cOPCAO == "I" ; fCOD_VENDED := CLI1->Cod_vend ; endif
           if cOPCAO == "I" ; fCOD_REPRES := CLI1->Cod_repres ; endif
           if cOPCAO == "I" ; fCOD_TERRIT := CLI1->Cod_TERRIT ; endif

           fCLIENTE := CLI1->Razao
           if CONFIG->Modelo_2 == "1"
              fC_CUSTO := "0010"
              fFILIAL := "0001"
              fTIPOSUB := "010002"
              sDESC_SN := "N"
           endif
		   
		   if empty(CLI1->Cod_resp)
			  qmensa("Nao existe Responsavel cadastrado para este Cliente","BL")
              return .F.		
           endif
               
           fCOD_RESP := CLI1->Cod_resp 
 
           if XFLAG
              if ! empty(CLI1->Obs1)
                 alert(rtrim(CLI1->Obs1)+";"+rtrim(CLI1->Obs2)+";"+rtrim(CLI1->Obs3)+";"+rtrim(CLI1->Obs4)+";"+rtrim(CLI1->Obs5),{"OK"},"N/BG")
              endif
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

           if left(fCOD_CFOP,1) $ "1-2-3"
              qmensa("Nao ‚ permitido Cfop de entrada!!","B")
              return .F.
           endif

           CGM->(Dbseek(CLI1->Cgm_ent))
           if CGM->Estado == "PR"
              if left(fCOD_CFOP,1) $ "6-7"
                 qmensa("Cliente Dentro do Estado. Verifique !","B")
                 return .F.
              endif
           else
              if left(fCOD_CFOP,1) == "5"
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

           //qsay(13,32,left(CFOP->Nat_Desc,40))
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


      case cCAMPO == "TIPOSUB"
           if empty(fTIPOSUB) ; return .F. ; endif
           qsay(13,21,fTIPOSUB:=strzero(val(fTIPOSUB),6))
           if ! TIPOCONT->(dbseek(fTIPOSUB))
              qmensa("Tipo Contabil n„o encontrado !","B")
              return .F.
           endif

          // if left(fCOD_CFOP,1) $ "1-2-3"
          //    fES := "E"
          // else
              fES := "S"
          // endif
           qsay(13,30,alltrim(TIPOCONT->Descricao))

      case cCAMPO == "DESC_SN"
           if empty(fDESC_SN) ; return .F. ; endif
           qsay(14,27,qabrev(fDESC_SN,"SN",{"Sim","N„o"}))

      case cCAMPO == "ES"
           if empty(fES) ; return .F. ; endif
           qsay(14,50,qabrev(fES,"S",{"Saida"}))

      case cCAMPO == "FRETE"
           if empty(fFRETE) ; return .F. ; endif
           qsay(15,70,qabrev(fFRETE,"12", {"1 - Cif","2 - Fob"}))

      case cCAMPO == "BOLETO"
           if empty(fBOLETO) ; return .F. ; endif
           qsay ( 09,24,  qabrev(fBoleto,"123456789", {"Boleto","Pgto a Vista - Boleto","Pgto a Vista - Deposito","Antecipado","Nulo","Plano MKT","Abater Credito","Segurar Duplicata","a Prazo - Deposito"}))




   endcase

return .T.

//////////////////////////////////////////////////////////////////////////////////
// FUN€AO PARA EXCLUIR PEDIDO DE VENDA __________________________________________

static function i_exclusao

   if qconf("Confirma exclus„o deste Pedido de Venda ?")

      /// rotina para voltar o estoque dos produtos digitados no Pedido Deletado !

      ITEM_PEN->(Dbgotop())

      if ITEM_PEN->(qflock()) .and. PEND->(qrlock())

         ITEM_PEN->(dbseek(PEND->Codigo))

         do while ! ITEM_PEN->(eof()) .and. ITEM_PEN->Cod_pend == PEND->Codigo
            ITEM_PEN->(dbdelete())
            ITEM_PEN->(dbskip())
         enddo

         PEND->(dbdelete())
         PEND->(qunlock())
         ITEM_PEN->(qunlock())

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
   fPRODS := 0
   lALT := .T.
endif

PROD->(Dbsetorder(4))
//ITEM_PEN->(dbsetfilter({|| Devolucao == space(1)},"Devolucao == space(1)"))

if CONFIG->Modelo_fat == "1"
   ITEM_PEN->(qview({{"f203m1()/Cod."                                        ,0},;
                     {"f203a()/Descri‡„o"                                    ,0},;
                     {"f203m()/ref"                                          ,0},;
                     {"transform(Vl_unitar, '@E 999,999.99')/Vl.Unit."    ,0},;
                     {"transform(Quantidade,'@E 99999')/Quant."           ,0},;
                     {"f203b()/Un."                                          ,0},;
                     {"f203c()/Val. Total"                                   ,0}},;
                     "16002179S",;
                     {NIL,"f203d",NIL,NIL},;
                     {"ITEM_PEN->Cod_pend == PEND->Codigo",{||f203top()},{||f203bot()}},;
                     "<I>nc./<A>lt./<C>on./<E>xc. <D>uplicata",,{|| CONFIG->Modelo_Fat == "1" .and. left(PEND->Cod_cfop,3) $ "510-610-511-611-512-612-540-640" .and. !DUP_PEN->(dbseek(PEND->Codigo+"01")) },"Pendencia sem Duplicatas, Verifique!"))
else
   ITEM_PEN->(qview({{"Cod_prod/Cod."                                        ,2},;
                     {"f203a()/Descri‡„o"                                    ,0},;
                     {"transform(Vl_unitar, '@E 999,999.99999')/Vl.Unit."    ,0},;
                     {"transform(Quantidade,'@E 99999.99')/Quant."           ,0},;
                     {"f203b()/Un."                                          ,0},;
                     {"f203c()/Val. Total"                                   ,0}},;
                     "16002179S",;
                     {NIL,"f203d",NIL,NIL},;
                     {"ITEM_PEN->Cod_pend == PEND->Codigo",{||f203top()},{||f203bot()}},;
                     "<I>nc./<A>lt./<C>on./<E>xc. <D>uplicata"))
endif

verificarDuplicatas()

return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IR PARA O INICIO DOS DADOS FILTRADOS _________________________

function f203top
   ITEM_PEN->(dbsetorder(1))
   ITEM_PEN->(dbseek(PEND->Codigo))
   i_totaliza_pedido()
   qsay(22,16,transform(fTOTAL,"@E 99,999,999.99"))
   qsay(22,45,transform(fPedido,"@E 99,999,999.99"))
   qsay(22,66,transform(fIpi_vlr,"@E 99,999,999.99"))

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IR PARA O FINAL DOS DADOS FILTRADOS __________________________

function f203bot
   ITEM_PEN->(dbsetorder(1))
   ITEM_PEN->(qseekn(PEND->Codigo))
   i_totaliza_pedido()
   qsay(22,16,transform(fTOTAL,"@E 99,999,999.99"))
   qsay(22,45,transform(fPedido,"@E 99,999,999.99"))
   qsay(22,66,transform(fIpi_vlr,"@E 99,999,999.99"))
return

/////////////////////////////////////////////////////////////////////////////
// RETORNA A DESCRICAO DO PRODUTO __________________________________________

function f203a

   local cDESCRICAO := space(30)
   PROD->(Dbsetorder(4))
   if ! empty(ITEM_PEN->Cod_prod)
      PROD->(dbseek(left(ITEM_PEN->Cod_prod,5)))
      cDESCRICAO := left(PROD->Descricao,30)
   endif
   i_totaliza_pedido()
   qsay(22,16,transform(fTOTAL,"@E 99,999,999.99"))
   qsay(22,45,transform(fPedido,"@E 99,999,999.99"))
   qsay(22,66,transform(fIpi_vlr,"@E 99,999,999.99"))

return cDESCRICAO



function f203m
   local cFABR := space(4)

   PROD->(Dbsetorder(4))
   if ! empty(ITEM_PEN->Cod_prod)
      PROD->(dbseek(left(ITEM_PEN->Cod_prod,5)))
      cFABR := left(PROD->Cod_fabr,4)
   endif
   i_totaliza_pedido()
   qsay(22,16,transform(fTOTAL,"@E 99,999,999.99"))
   qsay(22,45,transform(fPedido,"@E 99,999,999.99"))
   qsay(22,66,transform(fIpi_vlr,"@E 99,999,999.99"))
   rtrim(cFABR)

return cFABR

function f203m1
   local cASS := space(7)

   PROD->(Dbsetorder(4))
   if ! empty(ITEM_PEN->Cod_prod)
      PROD->(dbseek(left(ITEM_PEN->Cod_prod,5)))
      cASS := left(PROD->Cod_ass,7)
   endif
   i_totaliza_pedido()
   qsay(22,16,transform(fTOTAL,"@E 99,999,999.99"))
   qsay(22,45,transform(fPedido,"@E 99,999,999.99"))
   qsay(22,66,transform(fIpi_vlr,"@E 99,999,999.99"))
   rtrim(cASS)

return cASS


/////////////////////////////////////////////////////////////////////////////
// RETORNA A UNIDADE DO PRODUTO _____________________________________________

function f203b
   PROD->(dbseek(left(ITEM_PEN->Cod_prod,5)))
   UNIDADE->(dbseek(PROD->Unidade))
   i_totaliza_pedido()
   qsay(22,16,transform(fTOTAL,"@E 99,999,999.99"))
   qsay(22,45,transform(fPedido,"@E 99,999,999.99"))
   qsay(22,66,transform(fIpi_vlr,"@E 99,999,999.99"))
return UNIDADE->Sigla

/////////////////////////////////////////////////////////////////////////////
// RETORNA O VALOR TOTAL DO PRODUTO _________________________________________

function f203c
   i_totaliza_pedido()
   qsay(22,16,transform(fTOTAL,"@E 99,999,999.99"))
   qsay(22,45,transform(fPedido,"@E 99,999,999.99"))
   qsay(22,66,transform(fIpi_vlr,"@E 99,999,999.99"))
return transform(ITEM_PEN->Vl_unitar * ITEM_PEN->Quantidade,"@E 999,999.99")

function f203cl
   //INVENT->(DbSeek(PEND->Filial+right(PROD->Codigo,5)+"0000000000" ))

return INVENT->Quant_Atu


/////////////////////////////////////////////////////////////////////////////
// FUNCAO DE CONTROLE PRINCIPAL ANTES DE PROCESSAR A TECLA ACIONADA _________

function f203d

   local nCURSOR := setcursor(1)
   parameters cOPCAO

   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO $ XUSRA
      if CONFIG->Modelo_fat == "B"
         qlbloc(08,08,"B201BG","QBLOC.GLO",1)
     elseif CONFIG->Modelo_2 $ "9"
         qlbloc(08,08,"B201BK","QBLOC.GLO",1)
     else
         qlbloc(05,05,"B201B1","QBLOC.GLO",1)
     endif

      i_processa_acao()
   endif

   if cOPCAO == "D"

      i_totaliza_pedido()

      if left(PEND->Cod_cfop,4) $ "5910-6910-5911-6911-5912-6912-5915-6915-5917-6917"
         qmensa("CFOP Invalido, Proibida a geracao de Faturas !","B")
         return .F.
      endif


      i_duplicata()

   endif


   setcursor(nCURSOR)

return ""






/////////////////////////////////////////////////////////////////////////////
// FUNCAO DE BROWSE _________________________________________________________

static function i_processa_acao

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
      qrsay ( XNIVEL++ , ITEM_PEN->Cod_prod            , "@R 99999"                    ) ; PROD->(dbseek(left(ITEM_PEN->Cod_prod,5)))
      qrsay ( XNIVEL++ , left(PROD->Descricao,40)                                      )
      qrsay ( XNIVEL++ , ITEM_PEN->Num_lote                                            )
      qrsay ( XNIVEL++ , qabrev(ITEM_PEN->Prod_ser,"12", {"N„o","Sim"})                )
	  
      if CONFIG->Modelo_fat == "1"
         qrsay ( XNIVEL++ , ITEM_PEN->Preco_vend, "@E 999,999.99"        )
         qrsay ( XNIVEL++ , ITEM_PEN->Desc_prod, "@E 99.99"     )
         qrsay ( XNIVEL++ , ITEM_PEN->Vlr_Desc , "@E 999,999.99"                       )
         qrsay ( XNIVEL++ , ITEM_PEN->Ordem_comp,"@!"                                  )
      endif
	  
      qrsay ( XNIVEL++ , ITEM_PEN->Vl_unitar, "@E 9,999,999.99999"                       )
      qrsay ( XNIVEL++ , ITEM_PEN->Quant_ped                                          )
      qrsay ( XNIVEL++ , ITEM_PEN->Quantidade                                          )
      qrsay ( XNIVEL++ , ITEM_PEN->Quant_pen                                          )
      qrsay ( XNIVEL++ , transform(ITEM_PEN->Icms,"@E 99.99")                          )
      qrsay ( XNIVEL++ , transform(ITEM_PEN->Ipi, "@E 99.99")                              )
      qrsay ( XNIVEL++ , ITEM_PEN->Vl_unitar * ITEM_PEN->Quantidade, "@E 9,999,999.99" )
      qrsay ( XNIVEL++ , transform(ITEM_PEN->Comissao, "@E 99.99" )                    )
	  
      if CONFIG->Modelo_fat == "1"
         qrsay ( XNIVEL++ , transform(ITEM_PEN->Comi_repre, "@E 99.99" )                    )
      endif
	  
      if CONFIG->Modelo_fat != "B"
         qrsay ( XNIVEL++ , ITEM_PEN->Cod_sit          ,"@R 999"   );SIT_TRIB->(dbseek(ITEM_PEN->Cod_sit))
         qrsay ( XNIVEL++ , left(SIT_TRIB->Descricao,30)                                  )
         qrsay ( XNIVEL++ , ITEM_PEN->Classif                  )

         if CONFIG->Modelo_2 == "3"
            qrsay ( XNIVEL++ , ITEM_PEN->Num_nf                )
         endif
      endif
   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exc_itens_fat() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || view_prod(-1,0,@fCOD_PROD                    ) } ,"COD_PROD"  })
   aadd(aEDICAO,{{ || NIL                                            } ,NIL         })
   aadd(aEDICAO,{{ || view_lote(-1,0,@fNUM_LOTE, "@!"              ) } ,"NUM_LOTE"  })
   aadd(aEDICAO,{{ || NIL                                            } ,NIL         })
   if CONFIG->Modelo_fat == "1"
      aadd(aEDICAO,{{ || NIL                                            } ,"PRECO_VEND"         })
 //     aadd(aEDICAO,{{ || qgetx(-1,0,@fPRECO_VEND, "@e 999,999.99")      } ,"PRECO_VEND" })
      aadd(aEDICAO,{{ || qgetx(-1,0,@fDESC_PROD , "99.99"          ) } ,"DESC_PROD" })
      aadd(aEDICAO,{{ || NIL                                            } ,"VLR_DESC"  })
	  aadd(aEDICAO,{{ || qgetx(-1,0,@fORDEM_COMP, "@!"           ) } ,"ORDEM_COMP"  })
   endif

   aadd(aEDICAO,{{ || qgetx(-1,0,@fVL_UNITAR , "@e 9,999,999.99999") } ,"VL_UNITAR" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fQUANT_PED , "@R 999999.999"      ) } ,"QUANT_PED"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@fQUANTIDADE , "@R 999999.999"      ) } ,"QUANTIDADE"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@fQUANT_PEN , "@R 999999.999"      ) } ,"QUANT_PEN"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@fICMS, "99.99"                   ) } ,"ICMS"      })
   aadd(aEDICAO,{{ || NIL                                            } ,"IPI"       })
   aadd(aEDICAO,{{ || NIL                                            } ,"TOTAL"     })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fCOMISSAO, "99.99"               ) } ,"COMISSAO"  })

   if CONFIG->Modelo_fat =="1"
      aadd(aEDICAO,{{ || qgetx(-1,0,@fCOMI_REPRE, "99.99"             ) } ,"COI_REPRE" })
   endif

   if CONFIG->Modelo_fat != "B"
      aadd(aEDICAO,{{ || view_sit(-1,0,@fCOD_SIT                      ) } ,"COD_SIT"  })
      aadd(aEDICAO,{{ || NIL                                            } ,NIL         })
      aadd(aEDICAO,{{ || qgetx(-1,0,@fCLASSIF, "@!"                   ) } ,"CLASSIF"  })
      if CONFIG->Modelo_2 == "3"
         aadd(aEDICAO,{{ || qgetx(-1,0,@fNUM_NF, "@999999"            ) } ,"NUM_NF"  })
      endif
   endif


   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   ITEM_PEN->(qpublicfields())

   iif(cOPCAO=="I",ITEM_PEN->(qinitfields()),ITEM_PEN->(qcopyfields()))

   if cOPCAO == "A"
      XNIVEL := 3
   else
      XNIVEL := 1
   endif

   XFLAG  := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; ITEM_PEN->(qreleasefields()) ; return ; endif
      if ! i_crit2( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   if ! lCONF ; return ; endif

   // GRAVACAO ______________________________________________________________

   if PEND->(qrlock()) .and. ITEM_PEN->(iif(cOPCAO=="I",qappend(),qrlock()))
      if cOPCAO == "I"
         fCOD_PEND := fCODIGO
         fDATA    := fDT_EMISSAO
      endif
      fDATA    := fDT_EMISSAO

      ITEM_PEN->(qreplacefields())
      ITEM_PEN->(qunlock())

      fTOTAL := fTOTAL + (ITEM_PEN->Vl_unitar*fQUANTIDADE)

      // rotina que baixa o produto do Estoque quando e' confirmado no pedido

   else

      iif(cOPCAO=="I",qm1(),qm2())

   endif

return

/////////////////////////////////////////////////////////////////////////////
// CRITICAS NA DESCIDA ______________________________________________________

static function i_crit2 ( cCAMPO )
local nREG   := 0
local nORDEM := 0
local zPROD := ""
local fCOD_ASS := ""

   qmensa("")

   iif ( cCAMPO == NIL , cCAMPO := "" , NIL )
   if ! XFLAG; return .t.; endif
   do case

      case cCAMPO == "COD_PROD"

           if CONFIG->Modelo_fat == "1"

              PROD->(dbsetorder(5))
              if PROD->(dbseek(fCOD_PROD))
                 fCOD_PROD := right(PROD->Codigo,5)
              else
                 PROD->(dbsetorder(3))
                 if PROD->(dbseek(fCOD_PROD))
                    fCOD_PROD := right(PROD->Codigo,5)
                 else
                    //qmensa("Produto nao encontrado!","BL")
                    //return .F.
                 endif
              endif

              PROD->(dbsetorder(4))
           endif

           qrsay(XNIVEL,fCOD_PROD:=strzero(val(fCOD_PROD),5))

              PROD->(Dbsetorder(4))

              nORDEM := ITEM_PEN->(Indexord())
              nREG   := ITEM_PEN->(recno())

              if ITEM_PEN->(dbseek(PEND->Codigo+fCOD_PROD))
                 qmensa("Produto ja cadastrado, InclusÆo negada !","B")
                 return .F.
              endif

              ITEM_PEN->(Dbsetorder(nORDEM))
              ITEM_PEN->(Dbgoto(nREG))
              nREG := 0
              nORDEm := 0


           if ! PROD->(dbseek(fCOD_PROD))
              qmensa("Produto n„o encontrado !","B")
              return .F.
           endif

           if CONFIG->Modelo_fat == "1"
              qrsay ( XNIVEL+1 , left(PROD->Descricao,20)+"/"+PROD->Cod_ass+" - "+left(PROD->Cod_fabr,6) )
              fCOD_ASS := PROD->Cod_ass
           else
              qrsay ( XNIVEL+1 , left(PROD->Descricao,38) )
           endif
		   
		   lExisteArea  := existeArea(CLI1->Cgm_ent)
		   lTemVinculo := iif(empty(CLI1->Cod_exc),.F.,.T.)
		 		
		   if lExisteArea .and. lTemVinculo
		         EXCLUSIV->(dbsetorder(4))
                 if EXCLUSIV->(dbseek(CLI1->Cgm_ent + CLI1->Cod_exc + fCOD_PROD))
				    if PEND->Cod_cli != EXCLUSIV->Cod_cli

				       AREA_EXC->(dbseek(CLI1->Cod_exc))
				       alert(alltrim(fCOD_ASS) +"; exclusivo de ;"+rtrim(EXCLUSIV->Cliente)+"; em "+rtrim(EXCLUSIV->Desc_cid)+"/"+EXCLUSIV->Uf+";"+left(AREA_EXC->Descricao,20))
					   if ! alltrim(fUSER_ALT) $ "DANIELA-BASSO"
				          qrsay(XNIVEL,fCOD_PROD := "")
				          return .F.
				       endif
					endif
		    	 endif 	 
		  else

              EXCLUSIV->(dbsetorder(3))

              if EXCLUSIV->(dbseek(CLI1->CGM_ENT + fCOD_PROD))
                 if PEND->Cod_cli != EXCLUSIV->Cod_cli
                    Alert(alltrim(fCOD_ASS) +"; exclusivo de ;"+rtrim(EXCLUSIV->Cliente)+"; em "+rtrim(EXCLUSIV->Desc_cid)+"/"+EXCLUSIV->Uf,{"OK"},"N/BG")
                    if ! alltrim(fUSER_ALT) $ "DANIELA-BASSO"
				       qrsay(XNIVEL,fCOD_PROD := "")
				       return .F.
				    endif	
                 endif
              endif
		   endif


           qrsay ( XNIVEL+3 , qabrev(PROD->Prod_iss,"SN", {"Sim","N„o"}))

           fPROD_SER:=qabrev(PROD->Prod_iss,"SN", {"2","1"})

           LOTES->(dbSetFilter({|| Produto == fCOD_PROD .and. Filial == fFILIAL }, 'Produto == fCOD_PROD .and. Filial == fFILIAL'))
           if CONFIG->Modelo_fat == "9"
              fVL_UNITAR := PROD->Preco_unit
              fPRECO_VEND := PROD->Preco_unit

           else
              if left(PEND->Cod_cfop,3) $ "510-610-511-611-512-612-710-711-712-220-221"
                 if CONFIG->Modelo_2 $ "8*5"
                   fVL_UNITAR := PROD->Preco_cons - (PROD->Preco_Cons * (CLI1->Comis_repr/100 ))
                 else
                   fVL_UNITAR  := PROD->Preco_cons
                   fPRECO_VEND := PROD->Preco_cons
                   fDESC_PROD  := PEND->Aliq_desc
                 endif
              endif

              if left(PEND->Cod_Cfop,4) $ "5910-5911-5912-5917-6910-6911-6912-6917"
                 fVL_UNITAR := PROD->Preco_cust
                 fPRECo_VEND:= PROD->Preco_cust
              endif


           endif


           if cOPCAO == "I" .and. CONFIG->Modelo_fat == "1"
              fCOMI_REPRE := CLI1->Comis_repr
           endif


           fPRECO_CUST := PROD->Preco_cust

           fPONTOS := PROD->Pontos

           qrsay(XNIVEL+4,fPRECO_VEND,"@E 999,999.9999")



           Return .T.

      case cCAMPO == "DESC_PROD"
           if PEND->Aliq_desc <> 0 .and. fDESC_PROD <> PEND->Aliq_desc
              Qmensa("Desconto no Produto diferente da Aliquota do Pedido!!!","B")
              return .F.
           endif
           fVLR_DESC := round(fPRECO_VEND * (fDESC_PROD/100),2)
           fVL_UNITAR := round(fPRECO_VEND - fVLR_DESC,2)
           qrsay(XNIVEL+1,fVLR_DESC,"@E 999,999.99")
           qrsay(XNIVEL+3,fVL_UNITAR,"@E 999,999.99999")

      case cCAMPO == "QUANTIDADE"

           if CONFIG->Modelo_2 != "0"
              if empty(fQUANTIDADE) ; return .F. ; endif
           endif

           if INVENT->(dbseek(fFILIAL+fCOD_PROD+fNUM_LOTE))
              qmensa("No estoque tem "+ transform(INVENT->Quant_atu+(INVENT->Quant_ter-INVENT->Quant_res),"@R 999999") + " Unidades. Pecas Avariadas "+transform(INVENT->Quant_defe,"@R 999999"),"BL")
           else
              qmensa("Produto sem Inventario !","BL")
           endif

           //if CONFIG->Modelo_fat == "1" .and. PEND->Cod_cli $ "00616-00139"
           //   fCOD_SIT   := "060"
           //else
              fCOD_SIT   := "100"
           //endif



      case cCAMPO == "VL_UNITAR"

           if CONFIG->Modelo_2 != "0"
             if empty(fVL_UNITAR) ; return .F. ; endif
           endif

           CGM->(Dbseek(CLI1->Cgm_ent))
           ESTADO->(Dbseek(CGM->Estado))
           fICMS := ESTADO->Aliq_dest
		   if cOPCAO == "I"
		      fIPI := PROD->Ipi
		   endif
		   
		   if ! empty(CLI1->Inscricao) .and. left(upper(CLI1->Inscricao),5) != "ISENT" .and. CONFIG->Modelo_fat == "1"
		       if left(PEND->Cod_cfop ,1) == "6"
			      fIcms := 4.00
		       endif
		   endif

           if CLI1->Isento == "N" //.and. CONFIG->Modelo_fat != "1"
              fICMS := 18
           endif

           fCOMISSAO := nCOMISSAO
           if CONFIG->Modelo_2 == "1"
              fCOMISSAO := 7
           endif
           fCALC_DESC := "N"
           fICMS_SUBST := "N"


           Return .t.

      case cCAMPO == "IPI"
           if fICMS <> 0
              qrsay ( XNIVEL , transform(fIPI, "@E 99.99") )
           endif
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
              //LOTES->(dbSetFilter({|| Produto == fCOD_PROD .and. Filial == fFILIAL }, 'Produto == fCOD_PROD .and. Filial == fFILIAL'))

              if empty(fNUM_LOTE)
                 fNUM_LOTE := "0000000000"
                 qrsay(XNIVEL,fNUM_LOTE)

                 return .t.
              endif
              if LOTES->(dbseek(fCOD_PROD+fFILIAL+fNUM_LOTE))
                 Return .t.
              Else
                 qmensa("N£mero de Lote deste Produto nÆo encontrado...","B")
                 fLOTE := "0000000000"
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

           //if CONFIG->Modelo_fat == "1" .and. PEND->Cod_cli $ "00616-00139"
           //   fCOD_SIT   := "060"
           //endif
		   //


      case cCAMPO == "ICMS"

           if CONFIG->Modelo_fat != "1"
           if CLI1->Isento == "N"
              if fICMS <> 0 .and. fICMS <> 18
                 qmensa("Aliquota de Icms Invalida!","B")
                 return .f.
              endif

           else
              CGM->(Dbseek(CLI1->Cgm_ent))
              ESTADO->(Dbseek(CGM->Estado))

              if fICMS <> 0 .and. fICMS <> ESTADO->Aliq_dest
                 qmensa("Aliquota de Icms Invalida!","B")
                 return .f.

              endif

           endif
           endif


   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXCLUIR ITENS DO PEDIDO  _____________________________________

static function i_exc_itens_fat

   if qconf("Confirma exclus„o do Produto ?")

      if ITEM_PEN->(qrlock())
         ITEM_PEN->(dbdelete())
         ITEM_PEN->(qunlock())
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
   ITEM_PEN->(qview({{"f203m1()/Cod."                                       ,0},;
                     {"f203a()/Descri‡„o"                                    ,0},;
                     {"f203m()/Ref."                                         ,0},;
                     {"transform(Vl_unitar, '@E 999,999.99999')/Vl.Unit."    ,0},;
                     {"transform(Quantidade,'@E 99999.99')/Quant."           ,0},;
                     {"f203b()/Un."                                          ,0},;
                     {"f203c()/Val. Total"                                   ,0}},;
                     "16002179S",;
                     {NIL,NIL,NIL,NIL},;
                     {"ITEM_PEN->Cod_pend == PEND->Codigo",{||f203top()},{||f203bot()}},;
                    "<ESC> para sair" ))
else
   ITEM_PEN->(qview({{"Cod_prod/Cod."                                       ,2},;
                     {"f203a()/Descri‡„o"                                    ,0},;
                     {"transform(Vl_unitar, '@E 999,999.99999')/Vl.Unit."    ,0},;
                     {"transform(Quantidade,'@E 99999.99')/Quant."           ,0},;
                     {"f203b()/Un."                                          ,0},;
                     {"f203c()/Val. Total"                                   ,0}},;
                     "16002179S",;
                     {NIL,NIL,NIL,NIL},;
                     {"ITEM_PEN->Cod_pend == PEND->Codigo",{||f203top()},{||f203bot()}},;
                    "<ESC> para sair" ))

endif

return ""

//////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IMPRIMIR PEDIDO ________________________________________________

static function i_imprime( cOrdem ) 

   local cTITULO
   local nTOT_PROD := nLIN := nTOT_BRU := nPROD := nICMS_SUBS := 0
   local nALIQ_ICMS := 0
   local nIPI := 0
   local nICMS := 0
   local nST   := 0
   local aITENS := {}
   local nCONT := 1
   cTITULO := "LISTAGEM DA PENDENCIA No."+CODIGO+"   Data Emissao: "+dtoc(PEND->Dt_emissao)

   PROD->(Dbsetorder(4))

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif

   //if ! qlineprn() ; return ; endif

   i_totaliza_pedido()

   if XPAGINA == 0 .or. prow() > K_MAX_LIN
      qpageprn()
      @ prow()+1,00 say XCOND1
	  @ prow()+1,00 say ""
      qcabecprn(cTITULO,132)
      CLI1->(Dbseek(PEND->Cod_cli))
      REPRES->(Dbseek(PEND->Cod_repres))
      CGM->(Dbseek(CLI1->Cgm_ent))
      @ prow()+1,0 say "Cliente : "+CLI1->Codigo + " - " + left(CLI1->Razao,50) + "  Telefone: "+ CLI1->Fone1
      @ prow()+1,0 say "Fantasia: "+CLI1->Fantasia + " " + "Inscricao Estadual.: " + CLI1->Inscricao
      @ prow()+1,0 say "CNPJ....: "+fu_conv_cgccpf(CLI1->Cgccpf)
      @ prow()+1,0 say "Endereco: "+padr(rtrim(CLI1->End_ent)+iif(!empty(CLI1->Numero),", "+CLI1->Numero," ")+rtrim(CLI1->Compl),45) + " - " + left(CGM->Municipio,15) + " UF: "+CGM->Estado

      @ prow()+1,0 say "Bairro  : " + CLI1->Bairro_ent +"                                CEP.: "+padr(transform(CLI1->Cep_ent,"@R 99.999-999"),11)
      @ prow()+1,0 say "Representante: "+ left(REPRES->Razao,50)
      CFOP->(Dbseek(PEND->Cod_cfop))
      @ prow()+1,0 say "Nat. de Operacao: " + PEND->Cod_cfop + " - " + left(CFOP->Nat_desc,30)
	  TRANSP->(dbseek(PEND->Cod_transp))
      @ prow()+1,0 say "Frete...: " + iif(PEND->Frete == "0","Sem frete",iif(PEND->Frete == "1","Cif","Fob")) + "Transportadora.: " + rtrim(TRANSP->Razao) + " Tel.: "+TRANSP->fone1
      @ prow()+1,0 say "Incluiu...: "+PEND->User +"   Ultima Alteracao.: "+PEND->User_alt+ "  Voltagem.: "+CLI1->Voltagem

      @ prow()+1,0 say "Observacao: "+left(PEND->Obs,70)
      if PEND->Frete == "1" .and. fTotal < 1000
         @ prow()+1,0 say " *** Pedido inferior a R$ 1000,00. Consultar a possibilidade de aumento do pedido com o cliente."
      endif
      @ prow()+1,0 say replicate("-",132)
   endif

   @ prow()+1,0 say "Codigo                    Qtde         Produto                       Unitario             Total      Local.  Local.2    Obs.   "


   @ prow()+1,0 say ""


   ITEM_PEN->(dbgotop())
   ITEM_PEN->(dbseek(PEND->Codigo))

   do while ! ITEM_PEN->(eof()) .and. ITEM_PEN->cod_pend == PEND->Codigo

      PROD->(dbsetorder(4))
      PROD->(dbseek(ITEM_PEN->Cod_prod))

      aadd(aItens,{ITEM_PEN->Cod_prod,ITEM_PEN->cod_pend,PROD->Corredor + PROD->Estante + PROD->Prateleira,PROD->Corredor2 + PROD->Estante2 + PROD->Prateleir2,PROD->Cod_fabr})

      ITEM_PEN->(Dbskip())

   enddo


  // ITEM_PEN->(Dbseek(PEND->Codigo))

   //do while ! ITEM_PEN->(eof()) .and. ITEM_PEN->Cod_pend == PEND->Codigo
   
   if cOrdem == "1"
      aItens := asort(aItens,,,{|x,y| x[3] < y[3]})
   else
      aItens := asort(aItens,,,{|x,y| x[5] < y[5]})
   endif

   for nCONT:= 1 to len(aItens) //do while ! ITEN_FAT->(eof()) .and. ITEN_FAT->Num_fat == FAT->Codigo

      PROD->(Dbseek(aItens[nCont,1]))
      ITEM_PEN->(dbgotop())
      ITEM_PEN->(dbseek(aItens[nCONT,2]+aItens[nCONT,1]))


      PROD->(Dbseek(ITEM_PEN->Cod_prod))
      //@ prow()+1,0  say left(PROD->Cod_fabr,4)
      @ prow()+1,0  say left(PROD->Cod_fabr,6)+iif(left(PROD->Cod_fabr,7)==PROD->Cod_ass,"","/"+PROD->Cod_ass)

      @ prow()  ,21  say transform(ITEM_PEN->Quantidade, "@E 999999.99")
      @ prow()  ,39 say left(PROD->Descricao,18)

      if ! empty(PROD->Desconto) .and. ITEM_PEN->Calc_desc == "S"
         nDESC := PROD->Desconto/100
      else
         nDESC := 1
      endif

      @ prow()  ,67 say transform(round(ITEM_PEN->Vl_unitar * nDESC,2), "@E 999,999.99")
      @ prow()  ,85 say transform(ITEM_PEN->Quantidade * round(ITEM_PEN->Vl_unitar * nDESC,2), "@E 999,999.99")
      @ prow()  ,100 say " "+PROD->Corredor +" "+ PROD->Estante +" "+ PROD->Prateleira
      @ prow()  ,110 say " "+PROD->Corredor2 +" "+ PROD->Estante2 +" "+ PROD->Prateleir2
      @ prow()  ,120 say iif(PROD->Inspecao == "S","Inspecionar"," ")

//      @ prow()  ,58 say transform(round(ITEM_PEN->Vl_unitar * nDESC,2), "@E 999,999.99")
//      @ prow()  ,70 say transform(ITEM_PEN->Quantidade * round(ITEM_PEN->Vl_unitar * nDESC,2), "@E 999,999.99")
      nTOT_PROD  := nTOT_PROD +  (ITEM_PEN->Quantidade * round(ITEM_PEN->Vl_unitar * nDESC,2))
      nALIQ_ICMS := ITEM_PEN->Icms

      nIPI  +=  ( ( ITEM_PEN->Quantidade * ITEM_PEN->Vl_unitar ) * ( ITEM_PEN->Ipi / 100 ) )
      nICMS += ( ( ITEM_PEN->Quantidade * ITEM_PEN->Vl_unitar  ) * (ITEM_PEN->Icms/100) )
      iif(ITEM_PEN->Icms == 0,nIPI := 0, )

      if ITEM_PEN->ICMS_SUBST == "S" // soma somente os produtos com icms subst. tributaria nos itens do pedido
         nICMS_SUBS := nICMS_SUBS +  (ITEM_PEN->Quantidade * round(ITEM_PEN->Vl_unitar * nDESC,2))
      endif

      nLIN++
      //ITEM_PEN->(Dbskip())

   //enddo
   next
   
   nST := calculaTotalSubst("PEND")

   @ prow()+1,0 say replicate("-",132)

   @ prow()+1,92 say " Valor dos Produtos      >"+transform(nTOT_PROD, "@E 99,999,999.99")
   @ prow()+1,92 say " Valor do  IPI           >"+transform(nIPI,  "@E 99,999,999.99")
   @ prow()+1,92 say " Valor do  ICMS          >"+transform(nICMS, "@E 99,999,999.99")
   @ prow()+1,92 say " Valor da  Subst. Trib.  >"+transform(nST, "@E 99,999,999.99")

   @ prow()+1,92 say " Valor do Pedido         >"+transform( nTOT_PROD+nIPI+nST , "@E 99,999,999.99")
   @ prow()+1,0 say replicate("-",132)

      nResto := prow()
      for nCONT = 53 to nResto step -1
          @prow()+1,0 say ""
      next

      @ prow()+1,00 say "Coleta...: Inicio ___:___  Fim ___:___  Responsavel __________________________"
      @ prow()+2,00 say "Expedicao: Inicio ___:___  Fim ___:___  Responsavel __________________________"



   select PEND
   qstopprn(.F.)

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA TOTALIZAR VARIAVEIS DO PEDIDO ________________________________

static function i_totaliza_pedido

   local nREC   := ITEM_PEN->(recno())
   local nINDEX := ITEM_PEN->(indexord())
   nITENS := 0
   nTOT_PED := 0
   fTOTAL := 0
   fPEDIDO:= 0
   fST_VLR   := 0
   fIPI_VLR  := 0
   nTOT_PROD := 0
   nTOT_IPI  := 0
   nDESC := 0
   nTOT_DESC := 0
   ITEM_PEN->(dbsetorder(2))
   ITEM_PEN->(dbgotop())
   ITEM_PEN->(dbseek(PEND->Codigo))

   do while ! ITEM_PEN->(eof()) .and. ITEM_PEN->Cod_pend == PEND->Codigo
      PROD->(dbsetorder(4))
      PROD->(dbseek(ITEM_PEN->Cod_prod))
	  
	  if ITEM_PEN->Icms > 0
		 nTOT_IPI := nTOT_IPI + ( ( (ITEM_PEN->Quantidade*ITEM_PEN->Vl_unitar) * ITEM_PEN->Ipi) / 100)
	  endif	 

      fTOTAL    := fTOTAL + (ITEM_PEN->Quantidade*ITEM_PEN->Vl_unitar)
	  fPEDIDO   := fPEDIDO + (ITEM_PEN->Quantidade*ITEM_PEN->Vl_unitar)
      nITENS++
      ITEM_PEN->(Dbskip())
   enddo
   
   
   fTOTAL      := (fTOTAL + nTOT_IPI)
   fPEDIDO     := round(fPEDIDO,2)
   fIPI_VLR    := round(nTOT_IPI,2)
   //fST_VLR     := round(calculaTotalSubst("PEND"),2)

   ITEM_PEN->(dbsetorder(nINDEX))
   ITEM_PEN->(dbgoto(nREC))

return

static function i_gera_pedido
local cCODIGO       := space(5)
local cCOD_PEND     := space(5)
local cPENDENCIA    := space(5)
local lBAIXOU       := .F.
local lDELPEND      := .T.
local restQUANT     := 0
local nValor        := 0
local nResto        := 0
local baixadaQuant  := 0
local lITEMEXISTS   := .F.
local nLOCAL        := 0
local nTERCEIROS    := 0
local aRet      := {}
local aVerify   := {}

  if temOutrasPendencias(PEND->Cod_cli)
     mostraOutrasPendencias(PEND->Cod_cli,PEND->Codigo)
  endif


  if qconf("Confirma envio de pendencia para pedido?")


     if RESTRI->(dbseek(PEND->Cod_cli))
        qmensa("Cliente com Restricao, geracao negada!","B")
        return .F.
     endif

     if PEND->Frete == "0"
         qmensa("Tipo de Frete nÆo Informado. Verifique !","B")
         return .F.
     endif

     DUP_PEN->(dbgotop())
     if ! DUP_PEN->(Dbseek(PEND->Codigo+"01")) .and. left(PEND->Cod_cfop,3) $ "510-511-512-610-611-612"
         qmensa("Numero de Parcelas nÆo Informado. Verifique !","B")
         return .F.
     endif

     if ! i_ver_estoque()
        qmensa("Nao ha estoque suficiente para gerar um Pedido!","B")
        return .F.
     endif

      FAT->(QPublicFields())
      FAT->(QInitFields())
      PEND->(QPublicFields())
      PEND->(QcopyFields())

      cCOD_PEND := PEND->codigo

      cCODIGO := i_ped_existe(PEND->Cod_cli,left(PEND->Cod_cfop,4))

      if len(cCODIGO) == 5 .and. qconf("Pedido deste Cliente encontrado. Deseja agrupar ?")
         if val(cCODIGO) > 0
            FAT->(dbseek(cCODIGO))
            if FAT->(qrlock())
               replace FAT->Obs with rtrim(FAT->Obs) + "/"+PEND->Pedido + " /"+rtrim(PEND->Obs)
               FAT->(qunlock())
            endif
          else
            Qmensa("Nao foi Possivel gerar numero do pedido! Tente Novamente!","B")
            FAT->(QreleaseFields())
            PEND->(QreleaseFields())
            return .F.
          endif
          FAT->(QreleaseFields())
          PEND->(QreleaseFields())
      else


         if NUM_PEDI->(qrlock())
            replace NUM_PEDI->Pedido with NUM_PEDI->Pedido + 1
            qsay(6,17,fCODIGO := strzero(NUM_PEDI->Pedido,5) )
            qmensa("C¢digo Gerado: "+fCODIGO,"B")
            NUM_PEDI->(qunlock())
         else
            Qmensa("Nao foi Possivel gerar numero do pedido! Tente Novamente!","B")
            return .F.
         endif

         if empty(fCODIGO)
            Qmensa("Nao foi Possivel gerar numero do pedido! Tente Novamente!","B")
            return .F.
         endif


         cCODIGO := fCODIGO
         fOBS    := rtrim(fOBS)+"/"+fPEDIDO
         FAT->(Qappend())
         FAT->(qreplaceFields())
         FAT->(QreleaseFields())
         PEND->(QreleaseFields())
      endif

      ITEM_PEN->(Dbgotop())
      if ITEM_PEN->(Dbseek(PEND->Codigo))
         Do While ! ITEM_PEN->(Eof()) .and. ITEM_PEN->Cod_pend ==  PEND->Codigo

            ITEN_FAT->(QPublicFields())
            //ITEN_FAT->(QcopyFields()) Era Copy, mas acho que tem que ser init 06/11/2012
			ITEN_FAT->(QinitFields())

            fNUM_FAT := cCODIGO

            ITEM_PEN->(QPublicFields())
            ITEM_PEN->(QcopyFields())
            lBAIXOU       := .F.
            restQuant     := 0
            baixadaQuant  := 0

            aRet := i_baixa_estoque(PEND->Filial,ITEM_PEN->Cod_prod,ITEM_PEN->Num_lote,ITEM_PEN->Quantidade,left(PEND->Cod_cfop,4))
            lBAIXOU       := aRet[1,1]
            restQuant     := aRet[1,2]
            baixadaQuant  := aRet[1,3]
            nLOCAL        := aRet[1,4]
            nTERCEIROS    := aRet[1,5]
            if lBAIXOU
               if i_prod_existe(cCODIGO,ITEM_PEN->Cod_prod) > 0
                  if ITEN_FAT->(dbseek(cCODIGO+ITEM_PEN->Cod_prod))
                     if ITEN_FAT->(qrlock())
                        PROD->(dbsetorder(4))
                        PROD->(dbseek(ITEM_PEN->Cod_prod))
             //           replace ITEN_FAT->preco_vend with PROD->Preco_cons
             //           replace ITEN_FAT->Vl_unitar  with PROD->Preco_cons
                        replace ITEN_FAT->Quantidade with (ITEN_FAT->Quantidade + baixadaQuant)
                        replace ITEN_FAT->Local      with (ITEN_FAT->Local      + nLOCAL)
                        replace ITEN_FAT->Terceiros  with (ITEN_FAT->Terceiros  + nTERCEIROS)
                        replace ITEN_FAT->Quant_ped  with (ITEN_FAT->Quant_ped + baixadaQuant)
                        replace ITEN_FAT->Pend_cod   with cCOD_PEND
						if left(PEND->cod_cfop,4) $ "6915-6916-5915-5916-5949-6949"
						   replace ITEN_FAT->Ipi        with ITEM_PEN->Ipi
						else
						   replace ITEN_FAT->Ipi        with PROD->Ipi
						endif   
                        ITEN_FAT->(qunlock())
                     endif

                     ITEM_PEN->(QreleaseFields())

                     if ITEM_PEN->(Qrlock())
                        if restQuant == 0
                           ITEM_PEN->(DbDelete())
                        else
                           replace ITEM_PEN->Quantidade with restQuant
                           replace ITEM_PEN->Quant_ped  with restQuant
                           ITEM_PEN->(Qunlock())
                        endif
                     endif
                  endif
               else
                  if ITEN_FAT->(Qappend())
                     PROD->(dbsetorder(4))
                     PROD->(dbseek(fCod_prod))
                     //fpreco_vend := PROD->Preco_cons
                     //fVl_unitar  := PROD->Preco_cons
                     fQUANTIDADE := baixadaQuant
                     fLOCAL      := nLOCAL
					 
					if left(PEND->cod_cfop,4) $ "6915-6916-5915-5916-5949-6949"
					   fIPI        := ITEM_PEN->Ipi
					else
					   fIPI        := PROD->Ipi
					endif   	
						
                     fTerceiros  := nTerceiros
                     fQUANT_PED  := baixadaQuant
                     fPEND_COD   := cCOD_PEND
                     ITEN_FAT->(QreplaceFields())
                     ITEM_PEN->(QreleaseFields())

                     if ITEM_PEN->(Qrlock())
                        if restQuant == 0
                           ITEM_PEN->(DbDelete())
                        else
                           replace ITEM_PEN->Quantidade with restQuant
                           replace ITEM_PEN->Quant_ped  with restQuant
                           ITEM_PEN->(Qunlock())
                        endif
                     endif

                     if ITEN_FAT->(Qrlock())
                        replace ITEN_FAT->Marcado with "*"
                        ITEN_FAT->(Qunlock())
                     endif
                  endif
               endif

               if restQuant > 0
                  lDELPEND := .F.
               endif

            endif
            ITEM_PEN->(dbskip())
            lBAIXOU       := .F.
            restQuant     := 0
            baixadaQuant  := 0
            nLOCAL        := 0
            nTerceiros    := 0

        enddo


        DUP_PEN->(dbgotop())
        if DUP_PEN->(Dbseek(PEND->Codigo+"01"))

           Do While ! DUP_PEN->(Eof()) .and. left(DUP_PEN->Num_pen,5) == PEND->Codigo
              if DUP_FAT->(Qappend())

                 replace DUP_FAT->Num_fat   with cCODIGO + right(DUP_PEN->Num_pen,2)
                 replace DUP_FAT->Data_venc with DUP_PEN->Data_venc
                 replace DUP_FAT->Valor     with DUP_PEN->Valor
                 replace DUP_FAT->Dias      with DUP_PEN->Dias
              endif

              //if DUP_PEN->(Qrlock())
              //   DUP_PEN->(DbDelete())
              //   DUP_PEN->(Qunlock())
              //endif
              //Modificado em 28/06/2009 Eduardo

              DUP_PEN->(Dbskip())

           enddo

        endif

        if ITEM_PEN->(dbseek(PEND->Codigo))
           lITEMEXISTS := .T.
        endif

        if lDELPEND .and. ! lITEMEXISTS
           DUP_PEN->(dbgotop())
           if DUP_PEN->(Dbseek(PEND->Codigo+"01"))

              Do While ! DUP_PEN->(Eof()) .and. left(DUP_PEN->Num_pen,5) == PEND->Codigo
                 if DUP_PEN->(Qrlock())
                    DUP_PEN->(DbDelete())
                    DUP_PEN->(Qunlock())
                 endif
                 DUP_PEN->(Dbskip())
              enddo
           endif
           if PEND->(qrlock())
              PEND->(dbdelete())
              PEND->(qunlock())
           endif
        else //Se ainda houver itens, recalcula parcelas.

           i_totaliza_pedido()

           nVALOR := round(fTOTAL / PEND->Vezes,2)
           nRESTO := fTOTAL - (nVALOR*PEND->Vezes)

           DUP_PEN->(dbgotop())
           if DUP_PEN->(Dbseek(PEND->Codigo+"01"))

              Do While ! DUP_PEN->(Eof()) .and. left(DUP_PEN->Num_pen,5) == PEND->Codigo
                 if DUP_PEN->(Qrlock())
                    if right(DUP_PEN->Num_pen,2) == "01"
                       replace DUP_PEN->Valor with nValor + nResto
                    else
                       replace DUP_PEN->Valor with nValor
                    endif
                    DUP_PEN->(Qunlock())
                 endif
                 DUP_PEN->(Dbskip())
              enddo
           endif

        endif


      endif

   endif

return

////////////////////////////////////////////////////////////////////////////////////
static function i_duplicata

    local bESCAPE := {||lastkey()==27}
    local aEDICAO := {}
    local lCONF := .F.
    local nDIA   := ""
    local nVALOR := ""
    local nUMAPARC     :=  0
    local lAltDuplicata := .F.

    if DUP_PEN->(Dbseek(PEND->Codigo+"01"))
       lAltDuplicata := .T.
    else
       lAltDuplicata := .F.
    endif


    XNIVEL := 1
    XFLAG  := .T.

    if lAltduplicata
       i_pend_parc()
    endif

    qlbloc(8,2,"B201C","QBLOC.GLO",1)

    if lALTDuplicata
       i_mostra_dupli()
    endif

    i_totaliza_pedido()
    qsay(19,25,transform(fTOTAL,"@E 9,999,999.99"))

    aadd(aEDICAO,{{ || qgetx(-1,0,@fVEZES,"9"                      )} ,"VEZES"   })

    aadd(aEDICAO,{{ || qgetx(-1,0,@fDIA1,"999"                    )} ,"DIA1"   })
    aadd(aEDICAO,{{ || NIL },NIL }) // descricao
    aadd(aEDICAO,{{ || qgetx(-1,0,@fVALOR1,"@E 99,999,999.99"            )} ,"VALOR1"   })
    aadd(aEDICAO,{{ || qgetx(-1,0,@fDIA2,"999"                    )} ,"DIA2"   })
    aadd(aEDICAO,{{ || NIL },NIL }) // descricao
    aadd(aEDICAO,{{ || qgetx(-1,0,@fVALOR2,"@E 99,999,999.99"            )} ,"VALOR2"   })
    aadd(aEDICAO,{{ || qgetx(-1,0,@fDIA3,"999"                    )} ,"DIA3"   })
    aadd(aEDICAO,{{ || NIL },NIL }) // descricao
    aadd(aEDICAO,{{ || qgetx(-1,0,@fVALOR3,"@E 99,999,999.99"            )} ,"VALOR3"   })
    aadd(aEDICAO,{{ || qgetx(-1,0,@fDIA4,"999"                    )} ,"DIA4"   })
    aadd(aEDICAO,{{ || NIL },NIL }) // descricao
    aadd(aEDICAO,{{ || qgetx(-1,0,@fVALOR4,"@E 99,999,999.99"            )} ,"VALOR4"   })
    aadd(aEDICAO,{{ || qgetx(-1,0,@fDIA5,"999"                    )} ,"DIA5"   })
    aadd(aEDICAO,{{ || NIL },NIL }) // descricao
    aadd(aEDICAO,{{ || qgetx(-1,0,@fVALOR5,"99,999,999.99"            )} ,"VALOR5"   })
    aadd(aEDICAO,{{ || qgetx(-1,0,@fDIA6,"999"                    )} ,"DIA6"   })
    aadd(aEDICAO,{{ || NIL },NIL }) // descricao
    aadd(aEDICAO,{{ || qgetx(-1,0,@fVALOR6,"99,999,999.99"            )} ,"VALOR6"   })
    aadd(aEDICAO,{{ || qgetx(-1,0,@fDIA7,"999"                    )} ,"DIA7"   })
    aadd(aEDICAO,{{ || NIL },NIL }) // descricao
    aadd(aEDICAO,{{ || qgetx(-1,0,@fVALOR7,"99,999,999.99"            )} ,"VALOR7"   })



    aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

    // LOOP PARA ENTRADA DOS CAMPOS ____________________________________________

    do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
       eval ( aEDICAO [XNIVEL,1] )
       if eval ( bESCAPE );return;endif
       if ! i_crit_3( aEDICAO[XNIVEL,2] ) ; loop ; endif
       iif ( XFLAG , XNIVEL++ , XNIVEL-- )
       qmensa("")
    enddo

    if ! lCONF ; return ; endif

    if DUP_PEN->(qrlock())

       if lALTDuplicata
          DUP_PEN->(Dbgotop())
          DUP_PEN->(Dbseek(PEND->Codigo+"01"))
          do while ! DUP_PEN->(eof()) .and. left(DUP_PEN->Num_pen,5) == PEND->Codigo .and. DUP_PEN->(qrlock())
             DUP_PEN->(Dbdelete())
             DUP_PEN->(Dbskip())
          enddo
       endif

       if empty(fDIA1) .and. DUP_PEN->(qappend())   // venda a vista

          replace DUP_PEN->Num_pen   with fCODIGO+"01"
          replace DUP_PEN->Data_venc with fDT_EMISSAO
          replace DUP_PEN->Valor     with fVALOR1
          replace DUP_PEN->Dias      with fDia1


           if PEND->(qrlock())
              replace PEND->Vezes with fVEZES
              PEND->(qunlock())
           endif

       else

          if PEND->(qrlock())
             replace PEND->Vezes with fVEZES
             PEND->(qunlock())
          endif


          for nCONT := 1 to 7

              nDIA   := "fDIA"+str(nCONT,1)
              nVALOR := "fVALOR"+str(nCONT,1)

              if ! empty(&nDIA) .and. DUP_PEN->(qappend())
                 replace DUP_PEN->Num_pen   with fCODIGO+strzero(nCONT,2)
                 replace DUP_PEN->Data_venc with (fDT_EMISSAO + &nDIA )
                 replace DUP_PEN->Valor     with &nVALOR
                 replace DUP_PEN->Dias      with &nDIA

              endif

          next

       endif

       DUP_PEN->(qunlock())
       fVALOR1 := fVALOR2 := fVALOR3 := fVALOR4 := fVALOR5 := fVALOR6 := fVALOR7 := fPARC :=  0
       nVALOR1 := nVALOR2 := nVALOR3 := nVALOR4 := nVALOR5 := nVALOR6 := nVALOR7:= 0


    else
       qm1()
    endif

return ""

/////////////////////////////////////////////////////////////////////////////
// CRITICAS NA DESCIDA ______________________________________________________

static function i_crit_3 ( cCAMPO )
local nVLR_PARC := nCONT := 0
local cPARC := space(7)
local nDIA := 0
local nVALOR := 0
local nRESTO := 0
   qmensa("")

   do case
      case cCAMPO == "VEZES"

          for nCONT := 1 to 7
              nVALOR := "fVALOR"+str(nCONT,1)
              &nVALOR := 0
          next

          i_totaliza_pedido()

          nVLR_PARC := round(fTOTAL / fVEZES,2)
          nRESTO := fTOTAL - (nVLR_PARC*fVEZES)
          //qmensa("Resto.: "+transf(nRESTO,"@E 999,999.99"))
          //qinkey(0)

          for nCONT := 1 to fVEZES
              if  nCONT == 1
                  cPARC  := "fVALOR"+str(nCONT,1)
                  &cPARC := nVLR_PARC + nRESTO
              else
                  cPARC  := "fVALOR"+str(nCONT,1)
                  &cPARC := nVLR_PARC
              endif
          next


      case cCAMPO == "DIA1"
           if ! empty(fDIA1)
             qrsay(XNIVEL+1,dtoc(fDT_EMISSAO+fDIA1))
           else
             qrsay(XNIVEL+1,dtoc(fDT_EMISSAO))
           endif

      case cCAMPO == "DIA2"
           if ! empty(fDIA2)
             qrsay(XNIVEL+1,dtoc(fDT_EMISSAO+fDIA2))
           endif

      case cCAMPO == "DIA3"
           if ! empty(fDIA3)
             qrsay(XNIVEL+1,dtoc(fDT_EMISSAO+fDIA3))
           endif

      case cCAMPO == "DIA4"
           if ! empty(fDIA4)
             qrsay(XNIVEL+1,dtoc(fDT_EMISSAO+fDIA4))
           endif

      case cCAMPO == "DIA5"
           if ! empty(fDIA5)
             qrsay(XNIVEL+1,dtoc(fDT_EMISSAO+fDIA5))
           endif

      case cCAMPO == "DIA6"
           if ! empty(fDIA6)
             qrsay(XNIVEL+1,dtoc(fDT_EMISSAO+fDIA6))
           endif

      case cCAMPO == "DIA7"
           if ! empty(fDIA7)
             qrsay(XNIVEL+1,dtoc(fDT_EMISSAO+fDIA7))
           endif



      case cCAMPO == "VALOR1"
           if fVALOR1 == 0
              fVALOR1 := fTOTAL
           endif
           qrsay(XNIVEL,fVALOR1,"@E 99,999,999.99")
           fPARC :=  fVALOR1
           if fPARC < fTOTAL .and. fVALOR2 == 0
              fVALOR2 := fTOTAL - fPARC
           endif
           qsay(19,62,transform(fPARC,"@E 9,999,999.99"))

      case cCAMPO == "VALOR2"
           fPARC := fPARC + fVALOR2
           if fPARC < fTOTAL .and. fVALOR3 == 0
              fVALOR3 := fTOTAL - fPARC
           endif

           qsay(19,62,transform(fPARC,"@E 9,999,999.99"))
      case cCAMPO == "VALOR3"
           fPARC := fPARC + fVALOR3
           if fPARC < fTOTAL.and. fVALOR4 == 0
              fVALOR4 := fTOTAL - fPARC
           endif

           qsay(19,62,transform(fPARC,"@E 9,999,999.99"))
      case cCAMPO == "VALOR4"
           fPARC := fPARC + fVALOR4
           if fPARC < fTOTAL .and. fVALOR5 == 0
              fVALOR5 := fTOTAL - fPARC
           endif

           qsay(19,62,transform(fPARC,"@E 9,999,999.99"))

      case cCAMPO == "VALOR5"
           fPARC := fPARC + fVALOR5
           if fPARC < fTOTAL .and. fVALOR6 == 0
              fVALOR6 := fTOTAL - fPARC
           endif

           qsay(19,62,transform(fPARC,"@E 9,999,999.99"))

      case cCAMPO == "VALOR6"
           fPARC := fPARC + fVALOR6
           if fPARC < fTOTAL .and. fVALOR7 == 0
              fVALOR7 := fTOTAL - fPARC
           endif

           qsay(19,62,transform(fPARC,"@E 9,999,999.99"))


      case cCAMPO == "VALOR7"
           fPARC := fPARC + fVALOR7
           if fPARC <> fTOTAL
             qmensa("Valor nao esta batendo!!")
           endif

           qsay(19,62,transform(fPARC,"@E 9,999,999.99"))
         //  if fPARC - 0.01  > fTOTAL
         //     qmensa("Valor das Parcelas Superou o Valor dos Produtos!!","B")
         //     fPARC  := 0
         //     XNIVEL := 0
         //     return .T.
         //  endif

   endcase

return .T.

//////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ATUALIZAR AS PARCELAS DO PEDIDO _______________________________

static function i_pend_parc

   if ! DUP_PEN->(Dbseek(PEND->Codigo+"01"))
       qmensa("Pedido n„o Possui Duplicatas !!","B")
       return .F.
   endif

   for nCONT := 1 to 7

       if ! DUP_PEN->(eof()) .and. left(DUP_PEN->Num_pen,5) == PEND->Codigo

          nDIA   := "fDIA"+str(nCONT,1)
          nVALOR := "fVALOR"+str(nCONT,1)

          if DUP_PEN->Dias == 0
             &nDIA   := DUP_PEN->Data_venc - PEND->DT_EMISSAO
          else
             &nDIA   := DUP_PEN->Dias
          endif

          &nVALOR := DUP_PEN->Valor
          DUP_PEN->(Dbskip())

       endif

   next

return

static function i_mostra_dupli
   local zNIVEL := XNIVEL

   Qrsay(zNIVEL++,PEND->Vezes)


   for nCONT := 1 to 7

       nDIA   := "fDIA"+str(nCONT,1)
       nVALOR := "fVALOR"+str(nCONT,1)

       if (&nDIA) > 0
          Qrsay(zNIVEL++,&nDIA,"999")
          Qrsay(zNIVEL++,iif(&nDIA > 0,dtoc(PEND->Dt_emissao + (&nDIA)),"") )
          Qrsay(zNIVEL++,&nValor,"@E 99,999,999.99")
       else
          Qrsay(zNIVEL++,&nDIA,"999")
          Qrsay(zNIVEL++,iif(&nValor > 0,dtoc(PEND->Dt_emissao + (&nDIA)),"") )
          Qrsay(zNIVEL++,&nValor,"@E 99,999,999.99")
       endif


   next

return


static function i_ped_existe(cCLI,cCFOP)
local nORDEM := FAT->(IndexOrd())
local nREG   := FAT->(recno())
local cPED := ""

  FAT->(dbsetorder(10)) //Cli + Cfop + Num_fatura >> Para trazer as faturas em branco em 1o lugar ou seja pedidos reservados


  if  FAT->(dbseek(cCLI + cCFOP))
    
    if empty(FAT->Num_fatura)
      cPED := FAT->Codigo
	endif  
   
  endif 

return cPED


static function saoIguaisOsPrecosDosProdutosEmComum(cCodPed)
local nItenFatOrdem := ITEN_FAT->(IndexOrd())
local nItenFatReg   := ITEN_FAT->(RecNo())
local nItenPenOrdem := ITEM_PEN->(IndexOrd())
local nItenPenReg   := ITEM_PEN->(RecNo())
local nFatOrder     := FAT->(IndexOrd())
local nFatReg       := FAT->(RecNo())
local nPendOrder    := PEND->(IndexOrd())
local nPendReg      := PEND->(RecNo())
local aPedido := {}
local aPendencia :={}
    
	FAT->(dbsetorder(1)) 
    ITEN_FAT->(dbsetorder(2))
	
	if FAT->(dbseek(cCodPed))
	   ITEN_FAT->(dbseek(FAT->codigo))
	   Do while ! ITEN_FAT->(eof()) .and. ITEN_FAT->num_fat ==  FAT->Codigo
          aadd(aPedido,{ITEN_FAT->Cod_prod,ITEN_FAT->Vl_unitar})
          ITEN_FAT->(dbskip())
       enddo
    endif  	   
	
	if ITEM_PEN->(dbseek(PEND->Codigo))
	   Do while ! ITEM_PEN->(eof()) .and. ITEM_PEN->cod_pend ==  PEND->Codigo
          aadd(aPendencia,{ITEM_PEN->Cod_prod,ITEM_PEN->Vl_unitar})
          ITEM_PEN->(dbskip())
       enddo
	endif   
	
	if len(aPedido) > 0
	
	
	endif
    
	

return 

static function i_prod_existe(cCODIGO,cPROD)
local nORDEM := ITEN_FAT->(IndexOrd())
local nREG   := ITEN_FAT->(recno())
local nQUANT := 0

if ITEN_FAT->(dbseek(cCODIGO+cPROD))
   nQUANT := ITEN_FAT->Quantidade
else
   nQUANT := 0
endif

ITEN_FAT->(DbSetorder(nORDEM))
ITEN_FAT->(dbgoto(nREG))

return nQUANT

static function i_baixa_estoque(cFILIAL,cCOD_PROD,cLOTE,nQUANT,cCFOP)
local nREG    := INVENT->(Recno())
local nINDEX  := INVENT->(IndexOrd())
local lBAIXOU := .F.
local restQuant    := nQUANT
local baixadaQuant := 0
local aRet := {}
local nTERCEIROS := 0
local nLOCAL     := 0


INVENT->(Dbsetorder(1))


if INVENT->(dbseek(cFILIAL+cCOD_PROD+cLOTE))

   if cCFOP $ "5905-6905"
      if INVENT->Quant_atu > 0 .and. INVENT->(qrlock())
         if nQUANT <= INVENT->Quant_atu

            replace INVENT->Quant_atu with (INVENT->Quant_atu - nQUANT)
            replace INVENT->Quant_ter with (INVENT->Quant_ter + nQUANT)

            restQuant := 0
            baixadaQuant := nQUANT
            lBAIXOU := .T.
         else
            if nQUANT  > INVENT->Quant_atu
               restQuant := (nQUANT - INVENT->Quant_atu)
               baixadaQuant := INVENT->Quant_atu
               replace INVENT->Quant_ter with INVENT->Quant_atu
               replace INVENT->Quant_atu with 0
               lBAIXOU := .T.
               INVENT->(qunlock())
            endif
         endif
      else
         restQuant    := nQUANT
         baixadaQuant := 0
         lBAIXOU := .F.
      endif
   else

      if (INVENT->Quant_atu + (INVENT->Quant_ter-INVENT->Quant_res)) > 0 .and. INVENT->(qrlock())
         if nQUANT <= INVENT->Quant_atu
            replace INVENT->Quant_atu with INVENT->Quant_atu - nQUANT
            nLOCAL := nQUANT
            INVENT->(qunlock())
            restQuant := 0
            baixadaQuant := nQUANT
            lBAIXOU := .T.
         else
            if nQUANT <= (INVENT->Quant_atu+(INVENT->Quant_ter-INVENT->Quant_res))

               nLOCAL     := iif(INVENT->Quant_atu < 0,0,INVENT->Quant_atu)
               nTERCEIROS := (nQUANT - nLOCAL)
               if (nTERCEIROS + nLOCAL) == nQUANT
                  if INVENT->(qrlock())
                     replace INVENT->Quant_atu with INVENT->Quant_atu - nLOCAL
                     //replace INVENT->Quant_ter with INVENT->Quant_ter - nTERCEIROS
                     replace INVENT->Quant_res with INVENT->Quant_res + nTERCEIROS
                  endif
               endif

               restQuant := 0
               baixadaQuant := nQUANT
               lBAIXOU := .T.
               INVENT->(qunlock())
            else
               restQuant := (nQUANT - (INVENT->Quant_atu+(INVENT->Quant_ter-INVENT->Quant_res)))
               baixadaQuant := (INVENT->Quant_atu + (INVENT->Quant_ter-INVENT->Quant_res))

               nLOCAL     := iif(INVENT->Quant_atu < 0,0,INVENT->Quant_atu)
               nTERCEIROS := (baixadaQUANT - nLOCAL)
               if (nTERCEIROS + nLOCAL) == baixadaQUANT
                  if INVENT->(qrlock())
                     replace INVENT->Quant_atu with INVENT->Quant_atu - nLOCAL
                     //replace INVENT->Quant_ter with INVENT->Quant_ter - nTERCEIROS
                     replace INVENT->Quant_res with INVENT->Quant_res + nTERCEIROS
                  endif
               endif

               lBAIXOU := .T.
               INVENT->(qunlock())

            endif

         endif
      else
         restQuant    := nQUANT
         baixadaQuant := 0
         lBAIXOU := .F.
      endif
   endif

else
   qmensa("Lote nao encontrado nesta Filial !","B")
   restQUANT    := nQUANT
   baixadaQuant := 0
   lBAIXOU := .F.
endif

INVENT->(dbgoto(nREG))
INVENT->(dbsetorder(nINDEX))

aadd(aret,{lBAIXOU,restQuant,baixadaQuant,nLOCAL,nTERCEIROS})

return aRet



static function i_ver_estoque
local lTem := .F.
   ITEM_PEN->(Dbgotop())
   if ITEM_PEN->(Dbseek(PEND->Codigo))
      Do While ! ITEM_PEN->(Eof()) .and. ITEM_PEN->cod_pend ==  PEND->Codigo

         INVENT->(dbsetorder(1))
         if INVENT->(dbseek(PEND->Filial+ITEM_PEN->Cod_prod+ITEM_PEN->Num_lote))
            if (INVENT->Quant_atu+(INVENT->Quant_ter-INVENT->Quant_res)) > 0
               lTEM := .T.
            endif
         endif
         ITEM_PEN->(dbskip())
      enddo
   endif
return lTEM

static function temOutrasPendencias(cCLI)
local temPendencia := .F.
local nRegistro := PEND->(recno())
local nIndex    := PEND->(IndexOrd())
local nCONT     := 0

     PEND->(dbsetorder(5))
     if PEND->(dbseek(cCLI))
     do while !PEND->(eof()) .and. PEND->Cod_cli == cCLI
        nCONT++
        PEND->(dbskip())
     enddo
     endif
     if nCONT > 1
        temPendencia := .T.
     else
        temPendencia := .F.
     endif

PEND->(dbSetOrder(nIndex))
PEND->(dbgoto(nRegistro))

return temPendencia

static function mostraOutrasPendencias(cCLI,cCOD)
local temPendencia := .F.
local nRegistro := PEND->(recno())
local nIndex    := PEND->(IndexOrd())
local nCONT     := 0
local aPend     := {}
local cAlert    := ""

     PEND->(dbsetorder(5))
     if PEND->(dbseek(cCLI))
     do while !PEND->(eof()) .and. PEND->Cod_cli == cCLI
        nCONT++
        if cCOD != PEND->Codigo
           cAlert += "Codigo.: "+ PEND->Codigo+"     Data.: " + dtoc(PEND->Dt_emissao) + "     Pedido.: "+PEND->Pedido + ";"
        endif

        PEND->(dbskip())
     enddo
     endif

PEND->(dbSetOrder(nIndex))
PEND->(dbgoto(nRegistro))
    alert(cAlert,{"OK"},"N/BG")
return

static function i_teste_mostra()
  if temOutrasPendencias(PEND->Cod_cli)
     mostraOutrasPendencias(Pend->Cod_cli,PEND->Codigo)
  endif

return

static function i_mudanomecli

  CLI1->(dbseek(PEND->cod_cli))
  if PEND->(qrlock())
     replace Cliente with CLI1->Razao
     PEND->(qunlock())
  endif

return

static function i_Observacao

    local bESCAPE := {||lastkey()==27}
    local aEDICAO := {}
    local lCONF := .F.

    qlbloc(8,2,"B201O","QBLOC.GLO",1)


    XNIVEL := 1
    XFLAG  := .T.


    if OBSERVP->(dbseek(PEND->Codigo))
       OBSERVP->(qpublicfields())
       OBSERVP->(qinitfields())
       OBSERVP->(qcopyfields())

       qrsay(XNIVEL  ,OBSERVP->Obs1)
       qrsay(XNIVEL+1,fObs2)
       qrsay(XNIVEL+2,fObs3)
       qrsay(XNIVEL+3,fObs4)
       qrsay(XNIVEL+4,fObs5)
    else
       OBSERVP->(qpublicfields())
       OBSERVP->(qinitfields())
    endif


    aadd(aEDICAO,{{ || qgetx(-1,0,@fOBS1,"@!"                      )} ,"OBS1"   })
    aadd(aEDICAO,{{ || qgetx(-1,0,@fOBS2,"@!"                      )} ,"OBS2"   })
    aadd(aEDICAO,{{ || qgetx(-1,0,@fOBS3,"@!"                      )} ,"OBS3"   })
    aadd(aEDICAO,{{ || qgetx(-1,0,@fOBS4,"@!"                      )} ,"OBS4"   })
    aadd(aEDICAO,{{ || qgetx(-1,0,@fOBS5,"@!"                      )} ,"OBS5"   })

    aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

    // LOOP PARA ENTRADA DOS CAMPOS ____________________________________________

    do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
       eval ( aEDICAO [XNIVEL,1] )
       if eval ( bESCAPE );return;endif
       if ! i_crit_obs( aEDICAO[XNIVEL,2] ) ; loop ; endif
       iif ( XFLAG , XNIVEL++ , XNIVEL-- )
       qmensa("")
    enddo

    if ! lCONF ; return ; endif

    if OBSERVP->(dbseek(PEND->codigo))
       OBSERVP->(qrlock())
       OBSERVP->(qreplacefields())
       OBSERVP->(qunlock())
    else
       OBSERVP->(qappend())
       OBSERVP->(qreplacefields())
       OBSERVP->(dbcommit())
    endif



return ""

/////////////////////////////////////////////////////////////////////////////
// CRITICAS NA DESCIDA ______________________________________________________

static function i_crit_obs ( cCAMPO )
   qmensa("")

   do case
      case cCAMPO == "OBS1"
           fCOD_FAT := PEND->codigo


   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// PARA CONSULTAR SE POSSUI OUTRAS ALIQUOTAS ________________________________

static function i_consObs

   local nTECLA, nCONT

   setpos(24,79)

   do while .T.
      nTECLA := qinkey()
      if nTECLA == K_ESC ; exit ; endif

      qlbloc(8,2,"B201O","QBLOC.GLO",1)

      XNIVEL := 1

      if OBSERVP->(dbseek(PEND->Codigo))
         qrsay(XNIVEL  ,OBSERVP->Obs1)
         qrsay(XNIVEL+1,OBSERVP->Obs2)
         qrsay(XNIVEL+2,OBSERVP->Obs3)
         qrsay(XNIVEL+3,OBSERVP->Obs4)
         qrsay(XNIVEL+4,OBSERVP->Obs5)
      endif
      qwait()
      exit
   enddo



return

static function verificarDuplicatas()

 if ! left(PEND->Cod_cfop,3) $ "510-610-611-511-512-612-540-640"
    if DUP_PEN->(Dbseek(PEND->Codigo+"01"))
	   do while ! DUP_PEN->(eof()) .and. left(DUP_PEN->Num_pen,5) == PEND->Codigo .and. DUP_PEN->(qrlock())
          DUP_PEN->(Dbdelete())
          DUP_PEN->(Dbskip())
       enddo
	   alert("Esta pendencia nao e referenta a uma venda, as duplicatas foram excluidas")
	endif   
 endif
 
 select PEND
  
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


