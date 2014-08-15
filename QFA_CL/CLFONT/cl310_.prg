/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO USIMIX
// OBJETIVO...: MANUTENCAO DE CLIENTES
// ANALISTA...: LUIS ANTONIO ORLANDO PEREIRA
// PROGRAMADOR: O MESMO
// INICIO.....: SETEMBRO DE 1995
// OBS........:
// ALTERACOES.:

function cl310
private cALIAS
private cDEBITO     := "Nao"
private cNOTAFISCAL := "      "
private cDT_VENC    := ctod("//")
private cTIPO := "1"
private nVAL_DEB := 0
private nTOT_DEB := 0

do while .T.

   qsay(3,45,"       ")

   qlbloc(5,0,"B101C","QBLOC.GLO")

   qmensa("Escolha o tipo de manuten‡„o...")

   if empty ( cTIPO := qachoice(8,27,qlbloc("B101B","QBLOC.GLO"),cTIPO,1) ) ; return ; endif

   qsay(3,45,iif(cTIPO=="1","[ATIVO]","[MORTO]"))

   cALIAS := "CLI" + cTIPO
   (cALIAS)->(qview({{"Codigo/C¢digo"               ,1},;
                    {"left(Razao,35)/Raz„o"         ,2},;
                    {"Fantasia/Fantasia"            ,6},;
                    {"Fone1/Telefone"               ,7},;
                    {"fu_conv_cgccpf(CGCCPF)/CNPJ",3}},"P",;
                    {NIL,"c310a",NIL,NIL},;
                    NIL,;
                    iif(cTIPO=="1",q_msg_acesso_usr()+"<T>ransf. <M>arcar","ALT-O, ALT-P, <C>onsulta, <T>ransf.")))
enddo

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function c310a
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))
   if (cOPCAO $ XUSRA .and. cTIPO == "1") .or. ( cOPCAO == "C" .and. cTIPO == "2" )

      qlbloc(5,0,"B310A","QBLOC.GLO",1)

      qmensa(qabrev(cOPCAO,"IA",{"Inclus„o... <ESC - Cancela>","Altera‡„o... <ESC - Cancela>"}))
      i_edicao()
   endif
   setcursor(nCURSOR)
return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA ____________________________________

static function i_edicao
   local lCONF   := .F.
   local aEDICAO := {}
   local sBLOC1  := qlbloc("B101B","QBLOC.GLO")
   local bESCAPE := {||empty(fCGCCPF).or.(XNIVEL==2.and.!XFLAG).or.!empty(fCGCCPF).and.Lastkey()==27.or.;
                       (XNIVEL==2.and.cOPCAO=="A".and.!XFLAG)}

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"
      XNIVEL := 1
      qrsay ( XNIVEL++ , (cALIAS)->Codigo                                 )
      qrsay ( XNIVEL++ , fu_conv_cgccpf( (cALIAS)->Cgccpf )               )
      qrsay ( XNIVEL++ , (cALIAS)->Inscricao                              )
      qrsay ( XNIVEL++ , (cALIAS)->Razao                                  )
      qrsay ( XNIVEL++ , (cALIAS)->Fantasia                               )
      qrsay ( XNIVEL++ , (cALIAS)->Fone1                                  )

      qrsay ( XNIVEL++ , (cALIAS)->Cgm_ent                                ) ; CGM->(dbseek((cALIAS)->Cgm_ent))
      qrsay ( XNIVEL++ , left(CGM->Municipio,22)                                   )
      qrsay ( XNIVEL++ , CGM->Estado                                      )

      qrsay ( XNIVEL++ , (cALIAS)->Fax                                    )

      qrsay ( XNIVEL++ , (cALIAS)->Obs1                                     )
      qrsay ( XNIVEL++ , (cALIAS)->Obs2                                     )
      qrsay ( XNIVEL++ , (cALIAS)->Obs3                                     )
      qrsay ( XNIVEL++ , (cALIAS)->Obs4                                     )

      qrsay ( XNIVEL++ , (cALIAS)->Cod_Repres                             ) ; REPRES->(Dbseek((cALIAS)->Cod_repres))
      qrsay ( XNIVEL++ , left(REPRES->Razao,20)                           )

      qrsay ( XNIVEL++ , left((cALIAS)->Contato_c,20)                     )

      qrsay ( XNIVEL++ , CLI1->Email  )

         qrsay ( XNIVEL++ , CLI1->Dt_ult,"@D" )
         qrsay ( XNIVEL++ , fultcom() )
         i_getReceber(CLI1->Codigo)
         qrsay (XNIVEL++  , cDebito        )
         qrsay (XNIVEL++  , cNOTAFISCAL    )
         qrsay (XNIVEL++  , dtoc(cDT_VENC) )
         qrsay (XNIVEL++  , transform(nVAL_DEB,"@E 999,999.99") )
         qrsay (XNIVEL++  , transform(nTOT_DEB,"@E 999,999.99") )

   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || NIL                                                 },"CODIGO"    })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fCGCCPF       ,"@R 99.999.999/9999-99") },"CGCCPF"    })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fINSCRICAO    ,"@!")                    },"INSCRICAO" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fRAZAO        ,"@!"   ,"!empty(@)",.T.) },"RAZAO"     })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fFANTASIA     ,"@!")                    },"FANTASIA"  })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fFONE1        ,"@!")                    },"FONE1"     })
   aadd(aEDICAO,{{ || view_cgm(-1,0,@fCGM_ENT)                            },"CGM_ENT"   })
   aadd(aEDICAO,{{ || NIL                                                 },NIL         })
   aadd(aEDICAO,{{ || NIL                                                 },NIL         })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fFAX          ,"@!")                    },"FAX"       })

   aadd(aEDICAO,{{ || qgetx(-1,0,@fOBS1        ,"@!")                    },"OBS1" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fOBS2        ,"@!")                    },"OBS2" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fOBS3        ,"@!")                    },"OBS3" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fOBS4        ,"@!")                    },"OBS4" })

   aadd(aEDICAO,{{ || view_repres(-1,0,@fCOD_REPRES)                        },"COD_REPRES"})
   aadd(aEDICAO,{{ || NIL                                                 },NIL         })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fCONTATO_C    ,"@!")                    },"CONTATO_C" })


   aadd(aEDICAO,{{ || qgetx(-1,0,@fEMAIL    )                             },"EMAIL" })

   aadd(aEDICAO,{{ || qgetx(-1,0,@fDT_ULT,"@D"     )                             },"DT_ULT" })



   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   CLI1->(qpublicfields())
   iif(cOPCAO=="I",CLI1->(qinitfields()),CLI1->(qcopyfields()))
   XNIVEL  := 2
   XFLAG   := .T.
   fISENTO := iif(cOPCAO=="I","S",fISENTO)

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; CLI1->(qreleasefields()) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif

//   if ! quse(XDRV_CL,"CONFIG",{},"E","PROV")
//      qmensa("N„o foi possivel abrir CONFIG.DBF do Faturamento da Fabrica !","B")
//      return .F.
//   endif

   if cOPCAO == "I"
      if CONFIG->(qrlock())
         replace CONFIG->Cod_cli with CONFIG->Cod_cli + 1
         qrsay ( 1 , fCODIGO := strzero(CONFIG->Cod_cli,5) )
         qmensa("C¢digo Gerado: "+fCODIGO,"B")
         CONFIG->(qunlock())
      endif
   endif

  // PROV->(dbclosearea())

   select CLI1

   if CLI1->(iif(cOPCAO=="I",qappend(),qrlock()))

      // AGORA GRAVA E DESTRAVA ARQUIVO _____________________________________
      if cOPCAO == "I"  .and. CONFIG->Gera_plan
         fCONTA_CONT := Gera_plano()
      endif

      CLI1->(qreplacefields())

   else

      if empty(CLI1->Codigo) .and. empty(CLI1->Razao) .and. empty(CLI1->Cgccpf)
         CLI1->(dbdelete())
      endif

      iif(cOPCAO=="I",qm1(),qm2())

   endif

   dbunlockall()

   if cOPCAO == "I" ; keyboard "I" ; endif

return

/////////////////////////////////////////////////////////////////////////////
// CRITICA DE EDICAO ________________________________________________________

static function i_critica ( cCAMPO )

   local zTMP

   if ! XFLAG ; return .T. ; endif

   do case

      case cCAMPO == "CODIGO" .and. cOPCAO == "I"

           if CLI1->(dbseek(fCODIGO))
              qmensa("Cliente j  cadastrado !","B")
              return .F.
           endif

      case cCAMPO == "ISENTO"
           qrsay(XNIVEL,qabrev(fISENTO,"SN",{"Sim","N„o"}))

      case cCAMPO == "ULTIMA"
           qrsay(XNIVEL,fUltCom() )

      case cCAMPO == "CGCCPF"

           zTMP := .T.

           qrsay(XNIVEL,fu_conv_cgccpf(fCGCCPF) )

           if alltrim(fCGCCPF) == "00000000000000" .or. alltrim(fCGCCPF) == "00000000000"
              if CONFIG->Modelo_2 == "7"
                 qmensa("Campo Obrigatorio !","B")
                 return .F.
              endif
           endif

           do case
              case len(alltrim(fCGCCPF)) == 14
                   zTMP := qcheckcgc(fCGCCPF)
              case len(alltrim(fCGCCPF)) == 11
                   zTMP := qcheckcpf(fCGCCPF)
              otherwise
                   zTMP := .F.
           endcase

           if ! zTMP
              qmensa("CNPJ inv lido !","B")
              return .F.
           endif

           return i_check_cgc_dup()

      case cCAMPO == "CGM_COB"

           if ! CGM->(dbseek(fCGM_COB))
              qmensa("Cgm n„o encontrado !","B")
//              return .F.
           endif
           qrsay(XNIVEL+1,left(CGM->Municipio,22))

           qrsay(XNIVEL+2,CGM->Estado)

      case cCAMPO == "CGM_ENT"

           if ! CGM->(dbseek(fCGM_ENT))
              qmensa("Cgm n„o encontrado !","B")
       //       return .F.
           endif

           qrsay(XNIVEL+1,left(CGM->Municipio,22))
           qrsay(XNIVEL+2,CGM->Estado)

      case cCAMPO == "DT_ANIVER"

           if val(left(fDT_ANIVER,2)) > 31 .or. val(left(fDT_ANIVER,2)) < 0
              qmensa("Dia Inv lido !","B")
              return .F.
           endif

           if val(right(fDT_ANIVER,2)) > 12 .or. val(right(fDT_ANIVER,2)) < 0
              qmensa("Mes Inv lido !","B")
              return .F.
           endif



      case cCAMPO == "BAIRRO_ENT"

           if cOPCAO $ "I"
              fEND_COB := fEND_ENT
              fCGM_COB := fCGM_ENT
              fCEP_COB := fCEP_ENT
              fBAIRRO_COB := fBAIRRO_ENT
           endif
      //
      //     if len(alltrim(fCEP_ENT)) <> 8
      //        qmensa("C.E.P. incorreto !","B")
      //        return .F.
      //     endif

      case cCAMPO == "CEP_COB"

      //     if len(alltrim(fCEP_COB)) <> 8
      //        qmensa("C.E.P. incorreto !","B")
      //        return .F.
      //     endif

       //    if cOPCAO $ "I"
       //       fEND_COB := fEND_ENT
       //       fCGM_COB := fCGM_ENT
       //       fCEP_COB := fCEP_ENT
       //       fBAIRRO_COB := fBAIRRO_ENT
       //    endif

      case cCAMPO == "COD_BANCO"
           if ! emPty(fCOD_BANCO)
              if ! BANCO->(dbseek(fCOD_BANCO))
                 qmensa("Banco n„o encontrado !","B")
                 return .F.
              endif
              qrsay(XNIVEL+1,BANCO->Descricao)
           endif

      case cCAMPO == "COD_VEND"
           if ! empty(fCOD_VEND)
              if ! VEND->(dbseek(fCOD_VEND))
                 qmensa("Vendedor n„o encontrado !","B")
                 return .F.
              endif
              qrsay(XNIVEL+1,left(VEND->Nome,40))
           endif

      case cCAMPO == "TIPO_DOC"
           if ! empty(fTIPO_DOC)
              if ! TIPO_DOC->(dbseek(fTIPO_DOC))
                 qmensa("Tipo de Documento n„o encontrado !","B")
                 return .F.
              endif
              qrsay(XNIVEL+1,left(TIPO_DOC->Descricao,25))
           endif

      case cCAMPO == "COD_AREA"

           if ! empty(fCOD_AREA)

              if ! AREA->(dbseek(fCOD_AREA))
                 qmensa("rea n„o encontrada !","B")
                 return .F.
              endif

              qrsay(XNIVEL+1,AREA->Descricao)

           endif

      case cCAMPO == "COD_REPRES"
           if ! empty(fCOD_REPRES)
              if ! REPRES->(dbseek(fCOD_REPRES))
                 qmensa("Representante n„o encontrado !","B")
                 return .F.
              endif
              qrsay(XNIVEL+1,left(REPRES->Razao,20))
           endif

      case cCAMPO == "COD_TRANSP"
           if ! empty(fCOD_TRANSP)
              if ! TRANSP->(dbseek(fCOD_TRANSP))
                 qmensa("Transportadora n„o encontrada !","B")
                 return .F.
              endif
              qrsay(XNIVEL+1,left(TRANSP->Razao,30))
           endif


      case cCAMPO == "COD_SETOR"
           if ! empty(fCOD_SETOR)
              if ! SETOR->(dbseek(fCOD_SETOR))
                 qmensa("Setor n„o encontrado !","B")
                 return .F.
              endif
              qrsay(XNIVEL+1,left(SETOR->Descricao,25))
           endif

      case cCAMPO == "VEND_EXTER"
           if ! empty(fVEND_EXTER)
              if ! VEND->(dbseek(fVEND_EXTER))
                 qmensa("Vendedor n„o encontrado !","B")
                 return .F.
              endif
              qrsay(XNIVEL+1,left(VEND->Nome,40))
           endif


      case cCAMPO == "CONTA_CONT"
           if ! empty(fCONTA_CONT)
              if ! PLAN->(dbseek(fCONTA_CONT))
                 qmensa("C¢digo da Conta Cont bil n„o encontrada !","B")
                 fCONTA_CONT := space(7)
                 return .F.
              endif
              qrsay(XNIVEL+1,left(PLAN->Descricao,38))
           endif


      case cCAMPO == "FILIAL"

           if ! FILIAL->(dbseek(fFILIAL))
              qmensa("Filial n„o encontrado !","B")
              return .F.
           endif

           qrsay(XNIVEL+1,left(FILIAL->Razao,40))

      case cCAMPO == "EMAIL"
           fDT_ULT := date()
           Qrsay(XNIVEL+1,fDT_ULT,"@D")


   endcase
return .T.

/////////////////////////////////////////////////////////////////////////////
// CHECAR CGC DUPLICADO _____________________________________________________

static function i_check_cgc_dup

   local lFLAG, nRESP

   local nRECNO := CLI1->(recno())

   local nORDER := CLI1->(indexord())

   CLI1->(dbsetorder(3)) // muda para cgc...

   lFLAG := CLI1->(dbseek(fCGCCPF))

   if cOPCAO == "A" .and. fCODIGO == CLI1->Codigo
      lFLAG := .F.
   endif

   CLI1->(dbsetorder(nORDER)) // retorna ao original...

   if ! lFLAG

      CLI1->(dbgoto(nRECNO))

   else

      do while .T.

         nRESP := alert("CNPJ DUPLICADO !",{"Corrigir","Aceitar","Localizar"})

         do case
            case nRESP == 1
                 CLI1->(dbgoto(nRECNO))
                 return .F.
            case nRESP == 2
                 CLI1->(dbgoto(nRECNO))
                 return .T.
            case nRESP == 3 // para acionar bESCAPE...
                 XNIVEL := -1
                 return .T.
            otherwise
                 loop
         endcase

      enddo

   endif

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXCLUIR CLIENTE ______________________________________________

static function i_exclusao
   if qconf("Confirma exclus„o deste Cliente ?")
      PEDIDO->(Dbsetorder(7))
      if PEDIDO->(Dbseek(CLI1->Codigo))
         qmensa("Cliente Cadastrado em Pedido - Exclus„o Proibida","B")
         return
      endif
      if CLI1->(qrlock())
         CLI1->(dbdelete())
         CLI1->(qunlock())
      else
         qm3()
      endif
   endif
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA TRANSFERENCIA ENTRE ARQUIVOS "CLI1" E "CLI2" _________________

static function i_transf

   PEDIDO->(Dbsetorder(7))

   if PEDIDO->(Dbseek(CLI1->Codigo))
      qmensa("Cliente Cadastrado em Pedido - Transferencia Proibida","B")
      return
   endif

   if ! qconf("Confirma transferencia para o arquivo "+iif(cTIPO=="1","morto","ativo")+" ?")
      return
   endif

   fu_transf(cTIPO,"CLI",(cALIAS)->Codigo)

return

static function i_marca
   CLI1->(qrlock())
   if empty(CLI1->Inadimp)
      replace CLI1->Inadimp with '*'
   else
     replace CLI1->Inadimp with ' '
   endif
   CLI1->(qunlock())
return

static function gera_plano

local fULTCLI := space(4)
local myCODIGO := space(12)
local fREDUZIDO

PLAN->(qseekn("1010201"))
fULTCLI := strzero(CONFIG->Cod_cli,4)

myCODIGO := "1010201"+fULTCLI

myCODIGO := alltrim(myCODIGO) + qdigito(myCODIGO)

PLAN->(dbsetorder(3))
PLAN->(Dbgobottom())
fREDUZIDO := fREDUZIDO := strzero(val(left(PLAN->Reduzido,5))+1,5)
fREDUZIDO := fREDUZIDO + qdigito(fREDUZIDO)

if PLAN->(Qappend())
   replace PLAN->Codigo     with myCODIGO
   replace PLAN->Reduzido   with fREDUZIDO
   replace PLAN->Descricao  with fRAZAO
   replace PLAN->Nat_cont   with "AT"
   replace PLAN->Bloq_tecla with "N"
   replace PLAN->Cent_custo with "N"
   replace PLAN->Lanc_index with "N"
   replace PLAN->Mat_filial with "S"
endif
PLAN->(DbCommit())

return fREDUZIDO

static function fultcom()
local dULT := ctod("")

FAT->(dbsetorder(6))
FAT->(dbgotop())

if FAT->(dbseek(CLI1->Codigo))
   FAT->(qseekn(CLI1->Codigo))
   dULT := FAT->Dt_emissao
endif

return dtoc(dULT)

static function i_getReceber(pCod_cli)

nTOT_DEB := 0

RECEBER->(Dbsetorder(5))
if RECEBER->(Dbseek(pCOD_CLI))
   do while ! RECEBER->(Eof()) .and. RECEBER->Cod_cli == pCod_cli
      if RECEBER->Data_venc < date()
         cDEBITO    := "Sim"
         cNOTAFISCAL := left(RECEBER->Fatura,6)
         cDT_VENC    := RECEBER->Data_venc
         nVAL_DEB    := RECEBER->Valor
         nTOT_DEB    += RECEBER->Valor
      endif
      RECEBER->(Dbskip())
   enddo
else
  cDEBITO     := "Nao"
  cNOTAFISCAL := space(6)
  cDT_VENC    := ctod("//")
  nVAL_DEB    := 0
  nTOT_DEB    := 0
endif

return




