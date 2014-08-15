/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO
// OBJETIVO...: MANUTENCAO DE CLIENTES
// ANALISTA...: EDUARDO BORIO
// PROGRAMADOR: O MESMO
// INICIO.....: SETEMBRO DE 1998
// OBS........:
// ALTERACOES.:
//

function cl101

private cALIAS
private cDEBITO     := "Nao"
private cNOTAFISCAL := "      "
private cDT_VENC    := ctod("//")
private cTIPO := "1"
private nVAL_DEB := 0
private nTOT_DEB := 0
private lAGUA := .F.
//private aEDICAO := {}


//BANCO->(Dbsetorder(3)) // codigo do banco
PLAN->(dbsetorder(3))

do while .T.

   qsay(3,45,"       ")

   qlbloc(5,0,"B101C","QBLOC.GLO")

   qmensa("Escolha o tipo de manuten‡„o...")

   if empty ( cTIPO := qachoice(8,27,qlbloc("B101B","QBLOC.GLO"),cTIPO,1) ) ; return ; endif

   qsay(3,45,iif(cTIPO=="1","[ATIVO]","[MORTO]"))

   cALIAS := "CLI" + cTIPO
   (cALIAS)->(qview({{"Codigo/C¢digo"               ,1},;
                    {"f101vic()/Categ."             ,0},;
                    {"left(Razao,35)/Raz„o"         ,2},;
                    {"left(Fantasia,15)/Fantasia"   ,4},;
                    {"Fone1/Telefone"               ,5},;
                    {"fu_conv_cgccpf(CGCCPF)/CNPJ",3}},"P",;
                    {NIL,"c101a",NIL,NIL},;
                    NIL,;
                    iif(cTIPO=="1",q_msg_acesso_usr()+"e<M>ails <O>bs <V>IC","ALT-O, ALT-P, <C>onsulta, <T>ransf.")))
enddo

return

function f101vic
 local cResult := ""

  cResult := qabrev(CLI1->categoria,"VPNFC",{"VIC","POT","NOR","FINAL","PROB"})


return cResult

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function c101a
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))
   
   if ! empty(CONFIG->qsysoff)
      qmensa("Opção desabilitada!!","BL")
	  return .F.
   endif

   if CONFIG->Modelo_fat == "1"

      if cOPCAO == "O"

         qlbloc(10,10,"B101OBS","QBLOC.GLO",1)

         i_Obs()
      endif

      if cOPCAO == "M"

         qlbloc(10,10,"B101MAIL","QBLOC.GLO",1)

         i_Mail()
      endif


   endif

   if CONFIG->Modelo_fat == "1"

      if cOPCAO == "V"

         qlbloc(10,10,"B101VIC","QBLOC.GLO",1)

         i_VIC()
      endif
   endif


   if (cOPCAO $ XUSRA .and. cTIPO == "1") .or. ( cOPCAO == "C" .and. cTIPO == "2" )


      if CONFIG->Modelo_2 == "7" .or. CONFIG->Modelo_fat == "3"
         lAGUA := .T.
        qlbloc(5,0,"B101F","QBLOC.GLO",1)
      else
        if CONFIG->Modelo_fat == "1"
           qlbloc(5,0,"B101E","QBLOC.GLO",1)
        else
           qlbloc(5,0,"B101E","QBLOC.GLO",1)
        endif
      endif

      if CONFIG->Modelo_2 $ "8*5"
        qlbloc(5,0,"B101D","QBLOC.GLO",1)
      endif

      qmensa(qabrev(cOPCAO,"IA",{"Inclus„o... <ESC - Cancela>","Altera‡„o... <ESC - Cancela>"}))
      i_edicao()
   endif

   setcursor(nCURSOR)
return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA ____________________________________

static function i_edicao
   local lCONF   := .F.
   local sBLOC1  := qlbloc("B101B","QBLOC.GLO")
   
   
   local bESCAPE := {||empty(fCGCCPF).or.(XNIVEL==2.and.!XFLAG).or.!empty(fCGCCPF).and.Lastkey()==27.or.;
                       (XNIVEL==2.and.cOPCAO=="A".and.!XFLAG)}

   aEDICAO := {}


   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"
      XNIVEL := 1
      if CONFIG->Modelo_2 == "7"
         sayMayn()
      endif

      if CONFIG->Modelo_2 == "5"
         sayFlexForm()
      endif

      if ! CONFIG->Modelo_2 $ "5-7"
         sayMantra()
      endif

   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   if CONFIG->Modelo_2 == "7"
      getMayn(aEdicao)
   endif

   if CONFIG->Modelo_2 == "5"
      getFlexForm(aEdicao)
   endif

   if ! CONFIG->Modelo_2 $ "5-7"
      getMantra(aEdicao)
   endif

   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})


   // INICIALIZACAO DA EDICAO _______________________________________________

   CLI1->(qpublicfields())
   iif(cOPCAO=="I",CLI1->(qinitfields()),CLI1->(qcopyfields()))
   XNIVEL  := 2
   XFLAG   := .T.
   fISENTO := iif(cOPCAO=="I","S",fISENTO)

   if cOPCAO =="I" .or. fFINAL == " "
      fFINAL := "N"
   endif


   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; CLI1->(qreleasefields()) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo


   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif

   if cOPCAO == "I"
      if CONFIG->(qrlock())
         replace CONFIG->Cod_cli with CONFIG->Cod_cli + 1
         qrsay ( 1 , fCODIGO := strzero(CONFIG->Cod_cli,5) )
         qmensa("C¢digo Gerado: "+fCODIGO,"B")
         CONFIG->(qunlock())
      endif
   endif

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
              qmensa("Cliente j  cadastrado !","BL")
              return .F.
           endif

           if cOPCAO =="I" .or. fFINAL == " "
              fFINAL := "N"
           endif

      case cCAMPO == "ISENTO"
           qrsay(XNIVEL,qabrev(fISENTO,"SN",{"Sim","N„o"}))

      case cCAMPO == "FINAL"
           qrsay(XNIVEL,qabrev(fFINAL,"SN ",{"Sim","N„o","Nao"}))


      case cCAMPO == "ULTIMA"
           qrsay(XNIVEL,fUltCom() )

      case cCAMPO == "CGCCPF"

           zTMP := .T.

           qrsay(XNIVEL,fu_conv_cgccpf(fCGCCPF) )

           if alltrim(fCGCCPF) == "00000000000000" .or. alltrim(fCGCCPF) == "00000000000"
              if CONFIG->Modelo_2 == "7"
                 qmensa("Campo Obrigatorio !","BL")
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
              qmensa("CNPJ inv lido !","BL")
              return .F.
           endif

           return i_check_cgc_dup()

      case cCAMPO == "CGM_COB"

           if ! CGM->(dbseek(fCGM_COB))
              qmensa("Cgm n„o encontrado !","BL")
//              return .F.
           endif

           qrsay(XNIVEL+1,CGM->Municipio)
           qrsay(XNIVEL+2,CGM->Estado)


           if cOPCAO == "I"
              fDATA_ENT := date()
           else
              if empty(fDATA_ENT)
                 fDATA_ENT := primeCom()
              endif
           endif

      case cCAMPO == "CGM_ENT"

           if ! CGM->(dbseek(fCGM_ENT))
              qmensa("Cgm n„o encontrado !","BL")
       //       return .F.
           endif

           qrsay(XNIVEL+1,CGM->Municipio)
           qrsay(XNIVEL+2,CGM->Estado)

           if CONFIG->Modelo_fat == "1"

              if cOPCAO == "I"
                 fCOMIS_REPR := 10
              endif
           endif
		   
		   AREA_EXC->(dbclearfilter())
		   AREA_EXC->(dbsetfilter({|| Cidade == fCGM_ENT}))



      case cCAMPO == "DT_ANIVER"

           if val(left(fDT_ANIVER,2)) > 31 .or. val(left(fDT_ANIVER,2)) < 0
              qmensa("Dia Inv lido !","BL")
              return .F.
           endif

           if val(right(fDT_ANIVER,2)) > 12 .or. val(right(fDT_ANIVER,2)) < 0
              qmensa("Mes Inv lido !","BL")
              return .F.
           endif



      case cCAMPO == "BAIRRO_ENT"

           if cOPCAO $ "I"
              fEND_COB := fEND_ENT
              fCGM_COB := fCGM_ENT
              fCEP_COB := fCEP_ENT
              fBAIRRO_COB := fBAIRRO_ENT
           endif

           if CONFIG->Modelo_2 == "7"
              ROTA_ABR->(dbsetorder(2))
              if ! ROTA_ABR->(dbseek(fBAIRRO_ENT))
                 alert("Nao foi encontrada ROTA para este bairro; Verifique!!")
                 qmensa(" . ","BL")
                // return .F.
              else
                  fCOD_ROTA := ROTA_ABR->Cod_rota
                  qrsay(XNIVEL+15,fCOD_ROTA)
                  ROTA->(dbseek(fCOD_ROTA))
                  qrsay(XNIVEL+16,left(ROTA->Descricao,25))
              endif
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
                 qmensa("Banco n„o encontrado !","BL")
                 return .F.
              endif
              qrsay(XNIVEL+1,BANCO->Descricao)
           endif

      case cCAMPO == "COD_VEND"
           if ! empty(fCOD_VEND)
              if ! VEND->(dbseek(fCOD_VEND))
                 qmensa("Vendedor n„o encontrado !","BL")
                 return .F.
              endif
              qrsay(XNIVEL+1,left(VEND->Nome,12))
           endif

      case cCAMPO == "COD_TERRIT"
           if ! empty(fCOD_TERRIT)
              if ! TERRIT->(dbseek(fCOD_TERRIT))
                 qmensa("Territorio de Representante n„o encontrado !","BL")
                 return .F.
              endif
              qrsay(XNIVEL+1,left(TERRIT->Descricao,17))
           endif
		   
	   case cCAMPO == "COD_EXC"
	   
	       AREA_EXC->(dbsetorder(3))
		   
	       if AREA_EXC->(dbseek(fCGM_ENT)) .and. empty(fCOD_EXC)
		      qmensa("Campo obrigatorio para esta cidade !","BL")
              return .F.
		   endif
		   
		   AREA_EXC->(dbsetorder(1))
		   
           if ! empty(fCOD_EXC)
              if ! AREA_EXC->(dbseek(fCOD_EXC))
                 qmensa("Area de Exclusividade nao encontrada !","BL")
                 return .F.
              endif
              qrsay(XNIVEL+1,left(AREA_EXC->Descricao,17))
           endif


      case cCAMPO == "TIPO_DOC"
           if ! empty(fTIPO_DOC)
              if ! TIPO_DOC->(dbseek(fTIPO_DOC))
                 qmensa("Tipo de Documento n„o encontrado !","BL")
                 return .F.
              endif
              qrsay(XNIVEL+1,left(TIPO_DOC->Descricao,25))
           endif

      case cCAMPO == "COD_ROTA"
           if ! empty(fCOD_ROTA)
              if ! ROTA->(dbseek(fCOD_ROTA))
                 qmensa("Rota n„o encontrada !","B")
                 return .F.
              endif
              qrsay(XNIVEL+1,left(ROTA->Descricao,25))
           endif

      case cCAMPO == "COD_AREA"

           if ! empty(fCOD_AREA)

              if ! AREA->(dbseek(fCOD_AREA))
                 qmensa("rea n„o encontrada !","BL")
                 return .F.
              endif

              qrsay(XNIVEL+1,AREA->Descricao)

           endif

      case cCAMPO == "COD_REPRES"
           if ! empty(fCOD_REPRES)
              if ! REPRES->(dbseek(fCOD_REPRES))
                 qmensa("Representante n„o encontrado !","BL")
                 return .F.
              endif
              qrsay(XNIVEL+1,left(REPRES->Razao,20))
           endif

      case cCAMPO == "COD_TRANSP"
           if ! empty(fCOD_TRANSP)
              if ! TRANSP->(dbseek(fCOD_TRANSP))
                 qmensa("Transportadora n„o encontrada !","BL")
                 return .F.
              endif
              qrsay(XNIVEL+1,left(TRANSP->Razao,30))
           endif


      case cCAMPO == "COD_SETOR"
           if ! empty(fCOD_SETOR)
              if ! SETOR->(dbseek(fCOD_SETOR))
                 qmensa("Setor n„o encontrado !","BL")
                 return .F.
              endif
              qrsay(XNIVEL+1,left(SETOR->Descricao,25))
           endif

      case cCAMPO == "VEND_EXTER"
           if ! empty(fVEND_EXTER)
              if ! VEND->(dbseek(fVEND_EXTER))
                 qmensa("Vendedor n„o encontrado !","BL")
                 return .F.
              endif
              qrsay(XNIVEL+1,left(VEND->Nome,40))
           endif


      case cCAMPO == "CONTA_CONT"
           if ! empty(fCONTA_CONT)
              if ! PLAN->(dbseek(fCONTA_CONT))
                 qmensa("C¢digo da Conta Cont bil n„o encontrada !","BL")
                 fCONTA_CONT := space(7)
                 return .F.
              endif
              qrsay(XNIVEL+1,left(PLAN->Descricao,38))
           endif


      case cCAMPO == "FILIAL"

           if ! FILIAL->(dbseek(fFILIAL))
              qmensa("Filial n„o encontrado !","BL")
              return .F.
           endif

           qrsay(XNIVEL+1,left(FILIAL->Razao,40))
		   
	  case cCAMPO == "RESP"

           if ! RESP_REP->(dbseek(fCod_resp))
              qmensa("Respopnsavel nao encontrado !","BL")
              return .F.
           endif

           qrsay(XNIVEL+1,left(RESP_REP->Nome,40))
		   
	  case cCAMPO == "TRIBUTACAO"
           qrsay(XNIVEL,qabrev(fTRIBUTACAO,"1234",{"Simples Nacional","Lucro Presumido","Lucro Real","Pessoa Fisica"}))

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
      FAT->(Dbsetorder(6))
      if FAT->(Dbseek(CLI1->Codigo))
         qmensa("Cliente Cadastrado em Pedido - Exclus„o Proibida","B")
         return .F.
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

   if cTIPO == "1"
      FAT->(Dbsetorder(6))
   endif

   if cTIPO == "1" .and. FAT->(Dbseek(CLI1->Codigo))
      qmensa("Cliente Cadastrado em Pedido - Transferencia Proibida","B")
      return .F.
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

function fultcom()
local dULT := ctod("")

FAT->(dbsetorder(6))
FAT->(dbgotop())

if FAT->(dbseek(CLI1->Codigo))
   FAT->(qseekn(CLI1->Codigo))
   dULT := FAT->Dt_emissao
endif

return dULT

function primeCom()
local dULT := ctod("")

FAT->(dbsetorder(6))
FAT->(dbgotop())

if FAT->(dbseek(CLI1->Codigo))
   FAT->(qseekn(CLI1->Codigo))
   dULT := FAT->Dt_emissao
endif

return dULT

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


static function i_Obs
   local lCONF   := .F.
   local aEDICAO := {}


   local bESCAPE := {|| lastkey()== 27}

   // MONTA DADOS NA TELA ___________________________________________________

   XNIVEL := 1

   qrsay ( XNIVEL++ , CLI1->Obs1                               )
   qrsay ( XNIVEL++ , CLI1->Obs2                               )
   qrsay ( XNIVEL++ , CLI1->Obs3                               )
   qrsay ( XNIVEL++ , CLI1->Obs4                               )
   qrsay ( XNIVEL++ , CLI1->Obs5                               )


   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || qgetx(-1,0,@fOBS1    ,"@!")                    },"OBS" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fOBS2    ,"@!")                    },"OBS" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fOBS3    ,"@!")                    },"OBS" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fOBS4    ,"@!")                    },"OBS" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fOBS5    ,"@!")                    },"OBS" })

   aadd(aEDICAO,{{ || lCONF := qconf("Confirma ?") },NIL})


   // INICIALIZACAO DA EDICAO _______________________________________________

   CLI1->(qpublicfields())
   CLI1->(qcopyfields())

   XNIVEL  := 1
   XFLAG   := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )

      if eval ( bESCAPE ) ; CLI1->(qreleasefields()) ; return ; endif
      //if ! i_critobs( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif

   select CLI1

   if CLI1->(qrlock())

      CLI1->(qreplacefields())

   endif

   dbunlockall()

return

static function i_Mail
   local lCONF   := .F.
   local aEDICAO := {}


   local bESCAPE := {|| lastkey()== 27}

   // MONTA DADOS NA TELA ___________________________________________________

   XNIVEL := 1

   qrsay ( XNIVEL++ , CLI1->Email                              )
   qrsay ( XNIVEL++ , CLI1->Email_cp                           )
   qrsay ( XNIVEL++ , CLI1->Email_fi                           )


   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || qgetx(-1,0,@fEMAIL )                    },"OBS" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@femail_cp)                    },"OBS" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@femail_fi)                    },"OBS" })

   aadd(aEDICAO,{{ || lCONF := qconf("Confirma ?") },NIL})


   // INICIALIZACAO DA EDICAO _______________________________________________

   CLI1->(qpublicfields())
   CLI1->(qcopyfields())

   XNIVEL  := 1
   XFLAG   := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )

      if eval ( bESCAPE ) ; CLI1->(qreleasefields()) ; return ; endif
      //if ! i_critobs( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif

   select CLI1

   if CLI1->(qrlock())

      CLI1->(qreplacefields())

   endif

   dbunlockall()

return


static function i_Vic
   local lCONF   := .F.
   local aEDICAO := {}
   local sBLOC1 := qlbloc("B101BV","QBLOC.GLO")

   local bESCAPE := {|| lastkey()== 27}

   // MONTA DADOS NA TELA ___________________________________________________

   XNIVEL := 1

   qrsay ( XNIVEL++ , CLI1->Resp                               );VEND->(dbseek(CLI1->Resp))
   qrsay ( XNIVEL++ , left(VEND->Nome,30)                      )
   qrsay ( XNIVEL++ , iif(CLI1->ShowRoom == "S","Sim","Nao")   )
   qrsay ( XNIVEL++ , qabrev(CLI1->Categoria,"VPN",{"VIC","Potencial","Normal"}))


   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || view_vend(-1,0,@fRESP    ,"99999")             },"RESP"})
   aadd(aEDICAO,{{ || NIL                                            },"NIL" })
   aadd(aEDICAO,{{ || qesco(-1,0,@fSHOWROOM ,XSN)                    },"SHOWROOM"})
   aadd(aEDICAO,{{ || qesco(-1,0,@fCATEGORIA,sBLOC1)                 },"CATEGORIA" })

   aadd(aEDICAO,{{ || lCONF := qconf("Confirma ?") },NIL})


   // INICIALIZACAO DA EDICAO _______________________________________________

   CLI1->(qpublicfields())
   CLI1->(qcopyfields())

   XNIVEL  := 1
   XFLAG   := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )

      if eval ( bESCAPE ) ; CLI1->(qreleasefields()) ; return ; endif
      if ! i_critvic( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif

   select CLI1

   if CLI1->(qrlock())

      CLI1->(qreplacefields())

   endif

   dbunlockall()

return

static function i_critvic ( cCAMPO )

   do case

      case cCAMPO == "RESP"

           qrsay(XNIVEL,fRESP := strzero(val(fRESP),5) )

           if ! VEND->(dbseek(fRESP))
              qmensa("Responsavel nao Cadastrado !","B")
              return .F.
           endif

           qrsay(XNIVEL+1,left(VEND->Nome,30))


      case cCAMPO == "SHOWROOM"
           qrsay(XNIVEL,qabrev(fSHOWROOM,"S ",{"Sim","N„o"}))

      case cCAMPO == "CATEGORIA"
           if empty(fCATEGORIA) ; return .F. ; endif
           qrsay(XNIVEL,qabrev(fCATEGORIA,"VPNFC",{"VIC","POTENCIAL","NORMAL","FINAL","PROBLEMATICO"}))


   endcase
return .T.

static function besquisa
local aOrdKey:= {}
local nCONT:= 1

return

static function SayMantra

   qrsay ( XNIVEL++ , (cALIAS)->Codigo                                 )
   qrsay ( XNIVEL++ , fu_conv_cgccpf( (cALIAS)->Cgccpf )               )
   qrsay ( XNIVEL++ , (cALIAS)->Inscricao                              )
   qrsay ( XNIVEL++ , (cALIAS)->Razao                                  )
   qrsay ( XNIVEL++ , (cALIAS)->Fantasia                               )
   qrsay ( XNIVEL++ , (cALIAS)->Rg                                           )

   qrsay ( XNIVEL++ , iif(CLI1->Isento $ " N","N„o","Sim")             )

   qrsay ( XNIVEL++ , left((cALIAS)->End_ent,48)                       )
   qrsay ( XNIVEL++ , (cALIAS)->Numero                                 )
   qrsay ( XNIVEL++ , (cALIAS)->Cgm_ent                                ) ; CGM->(dbseek((cALIAS)->Cgm_ent))
   qrsay ( XNIVEL++ , CGM->Municipio                                   )
   qrsay ( XNIVEL++ , CGM->Estado                                      )
   qrsay ( XNIVEL++ , (cALIAS)->Cep_ent , "@R 99.999-999"              )
   qrsay ( XNIVEL++ , (cALIAS)->Bairro_ent, "@!"                       )
   qrsay ( XNIVEL++ , (cALIAS)->Compl     , "@!"                       )

   qrsay ( XNIVEL++ , (cALIAS)->End_cob                                )
   qrsay ( XNIVEL++ , (cALIAS)->Cgm_cob                                ) ; CGM->(dbseek((cALIAS)->Cgm_cob))
   qrsay ( XNIVEL++ , CGM->Municipio                                   )
   qrsay ( XNIVEL++ , CGM->Estado                                      )
   qrsay ( XNIVEL++ , (cALIAS)->Cep_cob , "@R 99.999-999"              )
   qrsay ( XNIVEL++ , (cALIAS)->Bairro_cob, "@!"                       )

   qrsay ( XNIVEL++ , (cALIAS)->Fax                                    )
   qrsay ( XNIVEL++ , (cALIAS)->Fone1                                  )

   qrsay ( XNIVEL++ , (cALIAS)->Fone2                               )
   qrsay ( XNIVEL++ , (cALIAS)->Data_ent                            )
   qrsay ( XNIVEL++ , (cALIAS)->Foner                               )

   qrsay ( XNIVEL++ , (cALIAS)->Cod_setor                              ) ; SETOR->(Dbseek((cALIAS)->Cod_setor))
   qrsay ( XNIVEL++ , left(SETOR->Descricao,15)                        )
   qrsay ( XNIVEL++ , (cALIAS)->Cod_resp                               ) ; RESP_REP->(Dbseek((cALIAS)->Cod_resp))
   qrsay ( XNIVEL++ , left(RESP_REP->Nome,12)                              )

   qrsay ( XNIVEL++ , (cALIAS)->Cod_exc                               ) ; AREA_EXC->(Dbseek((cALIAS)->Cod_exc))
   qrsay ( XNIVEL++ , left(AREA_EXC->Descricao,17)                    )


   qrsay ( XNIVEL++ , (cALIAS)->Cod_Repres                             ) ; REPRES->(Dbseek((cALIAS)->Cod_repres))
   qrsay ( XNIVEL++ , left(REPRES->Razao,20)                           )
   qrsay ( XNIVEL++ , (cALIAS)->Comis_Repr,"@E 99.99"                  )

   qrsay ( XNIVEL++ , left((cALIAS)->Contato_c,20)                     )

   qrsay ( XNIVEL++ , (cALIAS)->Contato_f                              )
   qrsay ( XNIVEL++ , (cALIAS)->Conta_cont, "@R 99999-9"               ) ; PLAN->(Dbseek((cALIAS)->Conta_cont))
   qrsay ( XNIVEL++ , iif((cALIAS)->Conta_cont <> space(6),PLAN->Descricao," "))

   qrsay ( XNIVEL++ , (cALIAS)->Filial    ) ; FILIAL->(dbseek((cALIAS)->Filial))
   qrsay ( XNIVEL++ , left(FILIAL->Razao,40)                           )
   qrsay ( XNIVEL++ , CLI1->Email  )
   qrsay ( XNIVEL++ , CLI1->Dt_aniver, "99/99")

   qrsay ( XNIVEL++ , qabrev(CLI1->Tributacao,"1234",{"Simples Nacional","Lucro Presumido","Lucro Real","Pessoa Fisica"}))
   qrsay ( XNIVEL++ , CLI1->Voltagem, "999")

return


static function sayMayn
    qrsay ( XNIVEL++ , (cALIAS)->Codigo                                 )
    qrsay ( XNIVEL++ , fu_conv_cgccpf( (cALIAS)->Cgccpf )               )
    qrsay ( XNIVEL++ , (cALIAS)->Inscricao                              )
    qrsay ( XNIVEL++ , (cALIAS)->Razao                                  )
    qrsay ( XNIVEL++ , (cALIAS)->Fantasia                               )
    qrsay ( XNIVEL++ , (cALIAS)->Rg                                           )

    qrsay ( XNIVEL++ , iif(CLI1->Final $ " N","N„o","Sim")             )

    qrsay ( XNIVEL++ , left((cALIAS)->End_ent,48)                       )
    qrsay ( XNIVEL++ , (cALIAS)->Numero                                 )
    qrsay ( XNIVEL++ , (cALIAS)->Cgm_ent                                ) ; CGM->(dbseek((cALIAS)->Cgm_ent))
    qrsay ( XNIVEL++ , CGM->Municipio                                   )
    qrsay ( XNIVEL++ , CGM->Estado                                      )
    qrsay ( XNIVEL++ , (cALIAS)->Cep_ent , "@R 99.999-999"              )
    qrsay ( XNIVEL++ , (cALIAS)->Bairro_ent, "@!"                       )
    qrsay ( XNIVEL++ , (cALIAS)->Compl     , "@!"                       )

    qrsay ( XNIVEL++ , (cALIAS)->Fax                                    )
    qrsay ( XNIVEL++ , (cALIAS)->Fone1                                  )

    qrsay ( XNIVEL++ , (cALIAS)->Cod_setor                              ) ; SETOR->(Dbseek((cALIAS)->Cod_setor))
    qrsay ( XNIVEL++ , left(SETOR->Descricao,15)                        )
    qrsay ( XNIVEL++ , (cALIAS)->Cod_vend                               ) ; VEND->(Dbseek((cALIAS)->Cod_vend))
    qrsay ( XNIVEL++ , left(VEND->Nome,12)                              )

    qrsay ( XNIVEL++ , (cALIAS)->Cod_Repres                             ) ; REPRES->(Dbseek((cALIAS)->Cod_repres))
    qrsay ( XNIVEL++ , left(REPRES->Razao,20)                           )
    qrsay ( XNIVEL++ , (cALIAS)->Comis_Repr,"@E 99.99"                  )

    qrsay ( XNIVEL++ , left((cALIAS)->Contato_c,20)                     )

    qrsay ( XNIVEL++ , (cALIAS)->Filial    ) ; FILIAL->(dbseek((cALIAS)->Filial))
    qrsay ( XNIVEL++ , left(FILIAL->Razao,40)                           )
    qrsay ( XNIVEL++ , CLI1->Email  )

    qrsay ( XNIVEL++ , fultcom() )
    qrsay ( XNIVEL++ , CLI1->Cod_rota );ROTA->(dbseek(CLI1->Cod_rota))
    qrsay ( XNIVEL++ , left(ROTA->Descricao,25))
    qrsay ( XNIVEL++ , CLI1->Tipo_doc );TIPO_DOC->(dbseek(CLI1->Tipo_doc))
    qrsay ( XNIVEL++ , left(TIPO_DOC->Descricao,25) )
    qrsay ( XNIVEL++ , Transform(CLI1->Dias,"@R 99") )
    i_getReceber(CLI1->Codigo)
    qrsay (XNIVEL++  , cDebito        )
    qrsay (XNIVEL++  , cNOTAFISCAL    )
    qrsay (XNIVEL++  , dtoc(cDT_VENC) )
    qrsay (XNIVEL++  , transform(nVAL_DEB,"@E 999,999.99") )
    qrsay (XNIVEL++  , transform(nTOT_DEB,"@E 999,999.99") )

return


static function sayFlexForm
      qrsay ( XNIVEL++ , (cALIAS)->Codigo                                 )
      qrsay ( XNIVEL++ , fu_conv_cgccpf( (cALIAS)->Cgccpf )               )
      qrsay ( XNIVEL++ , (cALIAS)->Inscricao                              )
      qrsay ( XNIVEL++ , (cALIAS)->Razao                                  )
      qrsay ( XNIVEL++ , (cALIAS)->Fantasia                               )
      qrsay ( XNIVEL++ , (cALIAS)->Rg                                           )
      qrsay ( XNIVEL++ , iif(CLI1->Isento $ " N","N„o","Sim")             )

      qrsay ( XNIVEL++ , left((cALIAS)->End_ent,48)                       )
      qrsay ( XNIVEL++ , (cALIAS)->Numero                                 )
      qrsay ( XNIVEL++ , (cALIAS)->Cgm_ent                                ) ; CGM->(dbseek((cALIAS)->Cgm_ent))
      qrsay ( XNIVEL++ , CGM->Municipio                                   )
      qrsay ( XNIVEL++ , CGM->Estado                                      )
      qrsay ( XNIVEL++ , (cALIAS)->Cep_ent , "@R 99.999-999"              )
      qrsay ( XNIVEL++ , (cALIAS)->Bairro_ent, "@!"                       )
      qrsay ( XNIVEL++ , (cALIAS)->Compl     , "@!"                       )

      qrsay ( XNIVEL++ , (cALIAS)->End_cob                                )
      qrsay ( XNIVEL++ , (cALIAS)->Cgm_cob                                ) ; CGM->(dbseek((cALIAS)->Cgm_cob))
      qrsay ( XNIVEL++ , CGM->Municipio                                   )
      qrsay ( XNIVEL++ , CGM->Estado                                      )
      qrsay ( XNIVEL++ , (cALIAS)->Cep_cob , "@R 99.999-999"              )
      qrsay ( XNIVEL++ , (cALIAS)->Bairro_cob, "@!"                       )

      qrsay ( XNIVEL++ , (cALIAS)->Fax                                    )
      qrsay ( XNIVEL++ , (cALIAS)->Fone1                                  )

      qrsay ( XNIVEL++ , (cALIAS)->Ramal1                              )
      qrsay ( XNIVEL++ , (cALIAS)->Fone2                               )
      qrsay ( XNIVEL++ , (cALIAS)->Ramal2                              )
      qrsay ( XNIVEL++ , (cALIAS)->Foner                               )

      qrsay ( XNIVEL++ , (cALIAS)->Cod_setor                              ) ; SETOR->(Dbseek((cALIAS)->Cod_setor))
      qrsay ( XNIVEL++ , left(SETOR->Descricao,15)                        )
      qrsay ( XNIVEL++ , (cALIAS)->Cod_vend                               ) ; VEND->(Dbseek((cALIAS)->Cod_vend))
      qrsay ( XNIVEL++ , left(VEND->Nome,12)                              )

      qrsay ( XNIVEL++ , (cALIAS)->Cod_Repres                             ) ; REPRES->(Dbseek((cALIAS)->Cod_repres))
      qrsay ( XNIVEL++ , left(REPRES->Razao,20)                           )
      qrsay ( XNIVEL++ , (cALIAS)->Comis_Repr,"@E 99.99"                  )

      qrsay ( XNIVEL++ , left((cALIAS)->Contato_c,20)                     )
      qrsay ( XNIVEL++ , (cALIAS)->Contato_f                              )

      qrsay ( XNIVEL++ , (cALIAS)->vend_exter                             ) ; VEND->(Dbseek((cALIAS)->vend_exter))
      qrsay ( XNIVEL++ , left(VEND->Nome,35)                              )

      qrsay ( XNIVEL++ , (cALIAS)->Conta_cont, "@R 99999-9"               ) ; PLAN->(Dbseek((cALIAS)->Conta_cont))
      qrsay ( XNIVEL++ , iif((cALIAS)->Conta_cont <> space(6),PLAN->Descricao," "))

      qrsay ( XNIVEL++ , (cALIAS)->Filial    ) ; FILIAL->(dbseek((cALIAS)->Filial))
      qrsay ( XNIVEL++ , left(FILIAL->Razao,40)                           )

return

static function getMantra(aEDICAO)
   local sBLOC1  := qlbloc("B101TRIB","QBLOC.GLO")
   
   aadd(aEDICAO,{{ || NIL                                                 },"CODIGO"    })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fCGCCPF       ,"@R 99.999.999/9999-99") },"CGCCPF"    })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fINSCRICAO    ,"@!")                    },"INSCRICAO" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fRAZAO        ,"@!"   ,"!empty(@)",.T.) },"RAZAO"     })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fFANTASIA     ,"@!")                    },"FANTASIA"  })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fRG           ,"@X!")                   },"RG"        })

   aadd(aEDICAO,{{ || qesco(-1,0,@fISENTO,XSN)                            },"ISENTO"    })

   aadd(aEDICAO,{{ || qgetx(-1,0,@fEND_ENT      ,"@!S48")                 },"END_ENT"   })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fNUMERO       ,"@!")                },"NUMERO"    })
   aadd(aEDICAO,{{ || view_cgm(-1,0,@fCGM_ENT)                            },"CGM_ENT"   })
   aadd(aEDICAO,{{ || NIL                                                 },NIL         })
   aadd(aEDICAO,{{ || NIL                                                 },NIL         })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fCEP_ENT      ,"@R 99.999-999")         },"CEP_ENT"   })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fBAIRRO_ENT      ,"@!")                 },"BAIRRO_ENT"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@fCOMPL           ,"@!")                 },"COMPL"})

   aadd(aEDICAO,{{ || qgetx(-1,0,@fEND_COB      ,"@!")                    },"END_COB"   })
   aadd(aEDICAO,{{ || view_cgm(-1,0,@fCGM_COB)                            },"CGM_COB"   })
   aadd(aEDICAO,{{ || NIL                                                 },NIL         })
   aadd(aEDICAO,{{ || NIL                                                 },NIL         })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fCEP_COB      ,"@R 99.999-999")         },"CEP_COB"   })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fBAIRRO_COB      ,"@!")                 },"BAIRRO_COB"})

   aadd(aEDICAO,{{ || qgetx(-1,0,@fFAX          ,"@!")                    },"FAX"       })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fFONE1        ,"@!")                    },"FONE1"     })

   aadd(aEDICAO,{{ || qgetx(-1,0,@fFONE2        ,"@!")                    },"FONE2"     })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDATA_ENT     ,"@D")                    },"DATA_ENT"  })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fFONER        ,"@!")                    },"FONER"     })

   aadd(aEDICAO,{{ || view_setor(-1,0,@fCOD_SETOR)                        },"COD_SETOR" })
   aadd(aEDICAO,{{ || NIL                                                 },NIL         })
   aadd(aEDICAO,{{ || view_resp(-1,0,@fCOD_RESP)                          },"COD_RESP"  })
   aadd(aEDICAO,{{ || NIL                                                 },NIL         })

   aadd(aEDICAO,{{ || view_areaexc(-1,0,@fCOD_EXC)                        },"COD_EXC"  })
   aadd(aEDICAO,{{ || NIL                                                 },NIL         })

   aadd(aEDICAO,{{ || view_repres(-1,0,@fCOD_REPRES)                        },"COD_REPRES"})
   aadd(aEDICAO,{{ || NIL                                                 },NIL         })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fCOMIS_REPR,"@E 99.99"  )               },"COD_REPRES"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@fCONTATO_C    ,"@!")                    },"CONTATO_C" })

   aadd(aEDICAO,{{ || qgetx(-1,0,@fCONTATO_F    ,"@!")                    },"CONTATO_F" })
   aadd(aEDICAO,{{ || view_plan(-1,0,@fCONTA_CONT ,"@R 99999-9")          },"CONTA_CONT"})
   aadd(aEDICAO,{{ || NIL                                                 },NIL         })

   aadd(aEDICAO,{{ || view_filial(-1,0,@fFILIAL)                          },"FILIAL"    })
   aadd(aEDICAO,{{ || NIL                                                 },NIL         })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fEMAIL    )                             },"EMAIL" })

   aadd(aEDICAO,{{ || qgetx(-1,0,@fDT_ANIVER,"99/99"    )                 },"DT_ANIVER" })

   //aadd(aEDICAO,{{ || view_transp(-1,0,@fCOD_TRANSP,"99999"    )          },"COD_TRANSP" })
   //aadd(aEDICAO,{{ || NIL                                                 },NIL         })
   
   aadd(aEDICAO,{{ || qesco(20,21,@fTRIBUTACAO,sBLOC1)                     },"TRIBUTACAO" })
   
   aadd(aEDICAO,{{ || qgetx(-1,0,@fVOLTAGEM,"999"    )                    },"VOLTAGEM" })


return

static function getMayn(aEDICAO)
   aadd(aEDICAO,{{ || NIL                                                 },"CODIGO"    })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fCGCCPF       ,"@R 99.999.999/9999-99") },"CGCCPF"    })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fINSCRICAO    ,"@!")                    },"INSCRICAO" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fRAZAO        ,"@!"   ,"!empty(@)",.T.) },"RAZAO"     })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fFANTASIA     ,"@!")                    },"FANTASIA"  })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fRG           ,"@X!")                   },"RG"        })

   aadd(aEDICAO,{{ || qesco(-1,0,@fFINAL,XSN)                            },"FINAL"    })

   aadd(aEDICAO,{{ || qgetx(-1,0,@fEND_ENT      ,"@!S48")                 },"END_ENT"   })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fNUMERO       ,"9999999")                },"NUMERO"    })
   aadd(aEDICAO,{{ || view_cgm(-1,0,@fCGM_ENT)                            },"CGM_ENT"   })
   aadd(aEDICAO,{{ || NIL                                                 },NIL         })
   aadd(aEDICAO,{{ || NIL                                                 },NIL         })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fCEP_ENT      ,"@R 99.999-999")         },"CEP_ENT"   })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fBAIRRO_ENT      ,"@!")                 },"BAIRRO_ENT"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@fCOMPL           ,"@!")                 },"COMPL"})

   aadd(aEDICAO,{{ || qgetx(-1,0,@fFAX          ,"@!")                    },"FAX"       })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fFONE1        ,"@!")                    },"FONE1"     })

   aadd(aEDICAO,{{ || view_setor(-1,0,@fCOD_SETOR)                        },"COD_SETOR" })
   aadd(aEDICAO,{{ || NIL                                                 },NIL         })
   aadd(aEDICAO,{{ || view_vend(-1,0,@fCOD_VEND)                          },"COD_VEND"  })
   aadd(aEDICAO,{{ || NIL                                                 },NIL         })

   aadd(aEDICAO,{{ || view_repres(-1,0,@fCOD_REPRES)                        },"COD_REPRES"})
   aadd(aEDICAO,{{ || NIL                                                 },NIL         })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fCOMIS_REPR,"@E 99.99"  )               },"COD_REPRES"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@fCONTATO_C    ,"@!")                    },"CONTATO_C" })

   aadd(aEDICAO,{{ || view_filial(-1,0,@fFILIAL)                          },"FILIAL"    })
   aadd(aEDICAO,{{ || NIL                                                 },NIL         })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fEMAIL    )                             },"EMAIL" })

   aadd(aEDICAO,{{ || NIL                                                 },"ULTIMA"  })

   aadd(aEDICAO,{{ || view_rota(-1,0,@fCOD_ROTA)                          },"COD_ROTA" })
   aadd(aEDICAO,{{ || NIL                                                 },NIL         })

   aadd(aEDICAO,{{ || view_doc(-1,0,@fTIPO_DOC)                           },"TIPO_DOC" })
   aadd(aEDICAO,{{ || NIL                                                 },NIL         })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDIAS     )                             },"DIAS" })


return

static function getFlexForm(aEDICAO)

   aadd(aEDICAO,{{ || NIL                                                 },"CODIGO"    })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fCGCCPF       ,"@R 99.999.999/9999-99") },"CGCCPF"    })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fINSCRICAO    ,"@!")                    },"INSCRICAO" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fRAZAO        ,"@!"   ,"!empty(@)",.T.) },"RAZAO"     })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fFANTASIA     ,"@!")                    },"FANTASIA"  })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fRG           ,"@X!")                   },"RG"        })

   aadd(aEDICAO,{{ || qesco(-1,0,@fISENTO,XSN)                            },"ISENTO"    })

   aadd(aEDICAO,{{ || qgetx(-1,0,@fEND_ENT      ,"@!S48")                 },"END_ENT"   })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fNUMERO       ,"9999999")                },"NUMERO"    })
   aadd(aEDICAO,{{ || view_cgm(-1,0,@fCGM_ENT)                            },"CGM_ENT"   })
   aadd(aEDICAO,{{ || NIL                                                 },NIL         })
   aadd(aEDICAO,{{ || NIL                                                 },NIL         })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fCEP_ENT      ,"@R 99.999-999")         },"CEP_ENT"   })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fBAIRRO_ENT      ,"@!")                 },"BAIRRO_ENT"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@fCOMPL           ,"@!")                 },"COMPL"})

   aadd(aEDICAO,{{ || qgetx(-1,0,@fEND_COB      ,"@!")                    },"END_COB"   })
   aadd(aEDICAO,{{ || view_cgm(-1,0,@fCGM_COB)                            },"CGM_COB"   })
   aadd(aEDICAO,{{ || NIL                                                 },NIL         })
   aadd(aEDICAO,{{ || NIL                                                 },NIL         })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fCEP_COB      ,"@R 99.999-999")         },"CEP_COB"   })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fBAIRRO_COB      ,"@!")                 },"BAIRRO_COB"})

   aadd(aEDICAO,{{ || qgetx(-1,0,@fFAX          ,"@!")                    },"FAX"       })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fFONE1        ,"@!")                    },"FONE1"     })


   aadd(aEDICAO,{{ || qgetx(-1,0,@fRAMAL1       ,"@!")                    },"RAMAL1"    })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fFONE2        ,"@!")                    },"FONE2"     })

   aadd(aEDICAO,{{ || qgetx(-1,0,@fRAMAL2       ,"@!")                    },"RAMAL2"    })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fFONER        ,"@!")                    },"FONER"     })

   aadd(aEDICAO,{{ || view_setor(-1,0,@fCOD_SETOR)                        },"COD_SETOR" })
   aadd(aEDICAO,{{ || NIL                                                 },NIL         })
   aadd(aEDICAO,{{ || view_vend(-1,0,@fCOD_VEND)                          },"COD_VEND"  })
   aadd(aEDICAO,{{ || NIL                                                 },NIL         })

   aadd(aEDICAO,{{ || view_repres(-1,0,@fCOD_REPRES)                        },"COD_REPRES"})
   aadd(aEDICAO,{{ || NIL                                                 },NIL         })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fCOMIS_REPR,"@E 99.99"  )               },"COD_REPRES"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@fCONTATO_C    ,"@!")                    },"CONTATO_C" })

   aadd(aEDICAO,{{ || qgetx(-1,0,@fCONTATO_F    ,"@!")                    },"CONTATO_F" })

   aadd(aEDICAO,{{ || view_vend(-1,0,@fVEND_EXTER)                        },"VEND_EXTER"})
   aadd(aEDICAO,{{ || NIL                                                 },NIL         })

   aadd(aEDICAO,{{ || view_plan(-1,0,@fCONTA_CONT ,"@R 99999-9")          },"CONTA_CONT"})
   aadd(aEDICAO,{{ || NIL                                                 },NIL         })

   aadd(aEDICAO,{{ || view_filial(-1,0,@fFILIAL)                          },"FILIAL"    })
   aadd(aEDICAO,{{ || NIL                                                 },NIL         })




return
