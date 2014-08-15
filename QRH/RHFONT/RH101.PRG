/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: FOLHA DE PAGAMENTO
// OBJETIVO...: CADASTRO DE FUNCIONARIOS
// ANALISTA...: CARLOS EDUARDO RABELLO NUNES
// PROGRAMADOR: O MESMO
// INICIO.....: SETEMBRO DE 1996
// OBS........:
// ALTERACOES.:

#include "inkey.ch"

/////////////////////////////////////////////////////////////////////////////
// MANUTENCAO DE FUNCIONARIOS _______________________________________________

private cADIC      := CONFIG->Campoadic
private nDIAS_CTR  := CONFIG->Dias_ctr
private sBLOCO_AA := qlbloc("B102A","QBLOC.GLO")
do while .T.
   FUN->(qview({{"Matricula"          ,1},;
                {"left(Nome,30)/Nome" ,2},;
                {"Mat_Ass/Mat.Assoc." ,9},;
                {"Situacao/Sit"       ,0},;
                {"f101b()/RECONF"     ,0}},"P",;
                {NIL,"f101a",NIL,"str6"},;  // funcao str6 esta em funcoes.prg
                 NIL,q_msg_acesso_usr()+"/<R>econf/<H>omol"))
   if lastkey() == K_ESC ; exit ; endif
enddo

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function f101a
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))
   if cOPCAO == "R" ; return i_reconf() ; endif
   if cOPCAO == "H" ; return i_homolo() ; endif
   if cOPCAO $ XUSRA
      qlbloc(5,0,"B1011","QBLOC.GLO")
      qmensa(qabrev(cOPCAO,"IA",{"Inclus„o... <ESC Cancela>","Altera‡„o... <ESC Cancela>"}))
      i_edicao()
   endif
   setcursor(nCURSOR)
return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA POSICIONAMENTO DO SITUA.DBF NA OPCAO RECONF __________________

function f101b
   SITUA->(dbSetFilter({|| ANOMES <= XANOMES},"ANOMES <= XANOMES"))
   SITUA->(qseekn(FUN->Matricula))
return(&cADIC)

/////////////////////////////////////////////////////////////////////////////
// RECONFIGURACAO INCLUINDO CAMPO ADICIONAL _________________________________

function i_reconf
   private nTOP := nBOT := 1

   if ! quse("","QSTRUCT") ; return "" ; endif

   set filter to QSTRUCT->Arquivo $ "FUN     -SITUA   " .and. ! QSTRUCT->Campo $ "ANOMES    -MATRICULA "
   QSTRUCT->(dbgotop())
   nTOP := QSTRUCT->(recno())

   do while ! QSTRUCT->(eof())
      nBOT := QSTRUCT->(recno())
      QSTRUCT->(dbskip())
   enddo

   QSTRUCT->(dbgotop())

   if QSTRUCT->(eof())
      qmensa("Estrutura n„o disponivel...","B")
      return ""
   else
      QSTRUCT->(qview({{"Campo"              ,0},;
                       {"Tipo"               ,0},;
                       {"Tamanho/Tam."       ,0},;
                       {"Decimal/Dec."       ,0},;
                       {"Descricao/Descri‡„o",0}},;
                       "08042176",;
                       {"EXIT",NIL,NIL,NIL},;
                       {"QSTRUCT->Arquivo $ 'FUN     -SITUA   '",{||dbgoto(nTOP)},{||dbgoto(nBOT)}},;
                       "Escolha o Campo e aperte <ENTER>..."))
   endif

   if CONFIG->(qrlock())
      replace CONFIG->Campoadic with alltrim(QSTRUCT->Arquivo) + "->" + QSTRUCT->Campo
      CONFIG->(qunlock())
   endif

   cADIC := alltrim(QSTRUCT->Arquivo) + "->" + QSTRUCT->Campo
   QSTRUCT->(dbclosearea())
   select FUN
return "EXIT"

/////////////////////////////////////////////////////////////////////////////
// CONFIGURA FILTRO PARA INCLUIR OU NAO OS HOMOLOGADOS ______________________

static function i_homolo

   if qconf("Incluir funcion rios homologados ?")
      FUN->(dbclearFilter())
   else
      FUN->(dbSetFilter({|| Situacao <> "H"},"Situacao <> 'H'"))
   endif

   FUN->(dbgoto(recno()))
return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PRINCIPAL DE CONTROLE DA EDICAO ___________________________________

static function i_edicao

local cLASTFIELD, nCONT, zTMP, nRECFUN := FUN->(recno())

private aEDICAO1 := {}, aEDICAO2 := {}, aEDICAO3 := {}
private aEDICAO4 := {}, aEDICAO5 := {}, aEDICAO6 := {}

private lCONF, cVETOR_ATUAL
private bESCAPE, nCTRL_TELA, nTECLA_ALT, aHIST := {}

private sBLOCO_B, sBLOCO_D, sBLOCO_E, sBLOCO_J
private sBLOCO_F, sBLOCO_G, sBLOCO_H, sBLOCO_I, sBLOCO_J
private sBLOCO_K, sBLOCO_M, sBLOCO_N, sBLOCO_O
private sBLOCO_Q, sBLOCO_R, sBLOCO_S, sBLOCO_T, sBLOCO_U

// INICIALIZACAO DE VARIAVEIS _______________________________________________

qmensa("Inicializando variaveis...")

if cOPCAO == "I"
   bESCAPE := { || (empty(fNOME) .and. XNIVEL==2) .or. (XNIVEL==2 .and. !XFLAG) .or. !empty(fNOME) .and. XNIVEL==2 .and. Lastkey()==27 }
else
   bESCAPE := { || XNIVEL==2 .and. !XFLAG .or. Lastkey()==27 }
endif

lCONF := .F.

// CARREGA BLOCOS NECESSARIOS _______________________________________________

carrega_os_blocos_necessarios()

// SE CONSULTA CHAMA ROTINA E RETORNA _______________________________________

if cOPCAO == "C" ; setcursor(0) ; consulta101() ; return ; endif

// EXCLUSAO CHAMA ROTINA E RETORNA _______________________________________

if cOPCAO == "E" ; exclusao101() ; return ; endif

// SETA TECLAS ______________________________________________________________

set key 376 to ALT_16  // salta direto para tela 1
set key 377 to ALT_16  // salta direto para tela 2
set key 378 to ALT_16  // salta direto para tela 3
set key 379 to ALT_16  // salta direto para tela 4
set key 380 to ALT_16  // salta direto para tela 5
set key 381 to ALT_16  // salta direto para tela 6

if cOPCAO == "A"
   set key 273 to ALT_W   // salta direto para confirmacao de gravacao
endif

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

inic_edicao()

FUN->(qpublicfields())
SITUA->(qseekn(FUN->Matricula))
SITUA->(qpublicfields())
FUN->(qcopyfields())
SITUA->(qcopyfields())

qmensa()

// INICIALIZACAO PARA A EDICAO ______________________________________________

qlbloc(5,0,"B1011","QBLOC.GLO")
inicializa_campos()
cVETOR_ATUAL := ""
nTECLA_ALT   := 0
nCTRL_TELA   := 1
XFLAG        := .T.

// SEGUNDO LOOP PARA MUDAR DE TELAS ______________________________________

do while nCTRL_TELA > 0 .and. nCTRL_TELA < 7

   if XFLAG
      XNIVEL := iif(!empty(cVETOR_ATUAL).and.nCTRL_TELA==1,2,1)
   else
      XNIVEL := len(&("aEDICAO"+str(nCTRL_TELA,1)))
      iif(cLASTFIELD $ "IDT_NUM/CPF_NUM/ENDERECO/DATA_NASC/SANGUE",XNIVEL--,NIL)
   endif

   XFLAG := .T.
   cVETOR_ATUAL := "aEDICAO" + str(nCTRL_TELA,1)

   // TERCEIRO LOOP PARA EDICAO DAS TELAS ________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(&cVETOR_ATUAL.)
      eval ( (&cVETOR_ATUAL.)[XNIVEL,1] )

      if eval ( bESCAPE ) .and. nCTRL_TELA == 1
         FUN->(qreleasefields())
         SITUA->(qreleasefields())
         return
      endif

      if nTECLA_ALT == 999 .and. cOPCAO == "A"
         lCONF := qconf("Confirma grava‡„o das altera‡”es ?")
         exit
      endif

      if nTECLA_ALT != 0
         monta16(str(nTECLA_ALT,1))
         exit
      endif

      cLASTFIELD := &cVETOR_ATUAL.[XNIVEL,2]

      if ! i_critica( cLASTFIELD ) ; loop ; endif

      if ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   if nTECLA_ALT == 999 ; exit ; endif

   if nTECLA_ALT != 0
      nCTRL_TELA := nTECLA_ALT
      nTECLA_ALT := 0
   else
      if ( XFLAG , nCTRL_TELA++ , nCTRL_TELA-- )
   endif

enddo

SITUA->(dbgoto(nRECFUN))

iif ( lCONF , iif ( cOPCAO == "I" , inclusao() , alteracao() ) , NIL )

dbunlockall()

return

/////////////////////////////////////////////////////////////////////////////
// INCLUSAO DE FUNCIONARIO __________________________________________________

static function inclusao

   if CONFIG->(qrlock()) .and. FUN->(qappend()) .and. SITUA->(qappend())

      if CONFIG->Tipo_mat == "G"
         replace CONFIG->Matricula with CONFIG->Matricula+1
         fMATRICULA := strzero(CONFIG->Matricula,6)
      endif

      atualiza_historico("INCLUSAO")
      atualiza_salario()
      FUN->(qreplacefields())
      fANOMES := XANOMES
      SITUA->(qreplacefields())

      replace FUN->Situacao  with "T"  // inicializa situacao como trabalhando
      replace SITUA->Situacao  with "T"  // inicializa situacao como trabalhando
      replace SITUA->Di_ferias with FUN->Data_adm
      replace SITUA->Df_ferias with FUN->Data_adm + 365
//    replace SITUA->Ai_ferias with FUN->Data_adm - 365
//    replace SITUA->Af_ferias with FUN->Data_Adm - 1

// Alteracao p/ funcionario cadastrado em meses anteriores. Muitas vezes e necessario
// abrir um novo periodo p/ calculo de ferias e rescicao, antes de ter encerrado
// a movimentacao mensal.

      if XDATASYS < XDATA_ATUAL
         SITUA->(qappend())
         SITUA->(qreplacefields())
         if right(XANOMES,2) == "12"
            replace SITUA->Anomes with strzero(val(XANOMES)+89,6)
            replace SITUA->Situacao with "T"
         else
            replace SITUA->Anomes with strzero(val(XANOMES)+1,6)
            replace SITUA->Situacao with "T"
         endif
         SITUA->(dbskip(-1))
      endif

      CONFIG->(dbunlock())
      FUN->(dbunlock())
      SITUA->(dbunlock())
      SITUA->(dbgoto(recno()))
      CONFIG->(dbgoto(recno()))
      HIST->(dbgoto(recno()))
      qmensa("Matricula: "+fMATRICULA,"B") ; qmensa()
   else
      dbunlockall()
      qm1()
      return .F.
   endif
return .T.

/////////////////////////////////////////////////////////////////////////////
// ALTERACAO DE FUNCIONARIO _________________________________________________

static function alteracao
   SITUA->(qseekn(FUN->Matricula))

   if FUN->(qrlock()) .and. SITUA->(qrlock()).and. HIST->(qflock())
      atualiza_historico("ALTERACAO")
      atualiza_salario()
      FUN->(qreplacefields())
      FUN->(dbunlock())
      SITUA->(qreplacefields())
      SITUA->(dbunlock())
      HIST->(dbunlock())
      SITUA->(dbgoto(recno()))
      HIST->(dbgoto(recno()))
   else
      dbunlockall()
      qm2()
      return .F.
   endif
return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ATUALIZAR ARQUIVO DE HISTORICO _______________________________

static function atualiza_historico ( C_TIPO )

   local nCONT, zTMP1, zTMP2
   local C_TELA := qsbloc(0,0,24,79)
   local C_TYPE
   private cFIELD, cVARIA

   // INCLUSAO DE FUNCIONARIO ENTAO SOMENTE ALIMENTA HISTORICO ______________

   if C_TIPO == "INCLUSAO"

      for nCONT := 1 to len(aHIST)
          cFIELD := "FUN->" + aHIST[nCONT]
          cVARIA := "f"   + aHIST[nCONT]

          if &cFIELD != &cVARIA
             if HIST->(qappend())
                HIST->Matricula := fMATRICULA
                HIST->Campo     := "FU" + aHIST[nCONT]
                HIST->Inicio    := date()
                HIST->Motivo    := "Inclusao."
                C_TYPE := type("&cVARIA")
                do case
                   case C_TYPE == "C" ; HIST->Conteudo := &cVARIA
                   case C_TYPE == "N" ; HIST->Conteudo := str(&cVARIA)
                   case C_TYPE == "D" ; HIST->Conteudo := dtoc(&cVARIA)
                endcase
             endif
          endif
      next

   // ALTERACAO DE FUNC., ENTAO SOLICITA COMPLEMENTACAO _____________________

   else

      for nCONT := 1 to len(aHIST)
          cFIELD := "FUN->" + aHIST[nCONT]
          cVARIA := "f"   + aHIST[nCONT]

          if &cFIELD != &cVARIA
             qlbloc(16,00,"B101H","QBLOC.GLO")
             qsay(17,57,aHIST[nCONT])
             zTMP1 := space(65)
             zTMP2 := date()
             qgetx(19,10,@zTMP1,NIL,NIL,NIL,.T.)
             qgetx(20,10,@zTMP2,NIL,NIL,NIL,.T.)

             if HIST->(qappend())
                HIST->Matricula := fMATRICULA
                HIST->Campo     := "FU" + aHIST[nCONT]
                HIST->Motivo    := zTMP1
                HIST->Inicio    := zTMP2
                C_TYPE := type("&cVARIA")

                do case
                   case C_TYPE == "C" ; HIST->Conteudo := &cVARIA
                   case C_TYPE == "N" ; HIST->Conteudo := str(&cVARIA)
                   case C_TYPE == "D" ; HIST->Conteudo := dtoc(&cVARIA)
                endcase

             endif
          endif
      next

   endif

   qrbloc(00,00,C_TELA)

return

// FUNCAO PARA ATUALIZAR SALARIO SINCRONIZADO COM CARGO _____________________

static function atualiza_salario

   if (SITUA->Cargo <> fCARGO .or. cOPCAO == "I") .and. CONFIG->Sinc_sal == "S"
      if qconf("Cargo Alterado ! Sincronizar Salario ???")
         fSALARIO := CARGO->Salario
      endif
   endif
return

/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA _____________________________________________

static function i_critica ( cCAMPO )

   if cOPCAO == "I"
      qmensa("ALT+<1~6> p/ mudar de tela.")
   else
      qmensa("ALT+<1~6> p/ mudar tela \ ALT-W p/ gravar")
   endif

   // CRITICAS DE RETORNO ___________________________________________________

   if ! XFLAG
      do case
         case cCAMPO == "NOME"
              qlbloc(5,0,"B1011","QBLOC.GLO")
              inicializa_campos()
              XNIVEL := 1
              return .F.
         case cCAMPO == "IDT_NUM"   ; monta16("1")
         case cCAMPO == "CPF_NUM"   ; monta16("2")
         case cCAMPO == "ENDERECO"  ; monta16("3")
         case cCAMPO == "DATA_NASC" ; monta16("4")
         case cCAMPO == "SANGUE"    ; monta16("5")
      endcase
      return .T.
   endif

   // CRITICAS NORMAIS ______________________________________________________

   do case

      case cCAMPO == "MATRICULA" .and. CONFIG->Tipo_mat == "I" .and. cOPCAO == "I"
           qrsay(XNIVEL,fMATRICULA:=strzero(val(fMATRICULA),6))
           if FUN->(dbseek(fMATRICULA))
              qmensa("Matricula j  utilizada !","B")
              return .F.
           endif
      case cCAMPO == "CATEGORIA"
           if empty(fCATEGORIA) ; return .F. ; endif
           qrsay ( XNIVEL , qabrev(fCATEGORIA,"123456789",{"Mensal","Quinzenal","Semanal","Diario","Horario","Tarefa","Comissao","Honorario","Estagiario"}) )
      case cCAMPO == "VINCULO"
           if empty(fVINCULO) ; return .F. ; endif
           qrsay ( XNIVEL , qabrev(fVINCULO,"ABCDEFGHIJKLMNO",{"Urbano-CLT/PJ/Pz Ind.","Urbano-CLT/PF/Pz Ind.","Rural-CLT/PJ/Pz Ind.","Rural-CLT/PF/Pz Ind.","Servidor(RJU)-Militar","Trabalhador Autonomo",+;
           "Trabalhador Avulso","Trabalhador Tempor rio","Urbano-CLT/PJ/Pz. Det.","Urbano-CLT/PF/Pz. Det.","Rural-CLT/PJ/Pz. Det.","Rural-CLT/PF/Pz. Det.","Diretor c/V¡nc. FGTS","Diretor s/V¡nc. FGTS","Menor Aprendiz"}))
      case cCAMPO == "TURNO"
           if empty(fTURNO) ; return .F. ; endif
           qrsay ( XNIVEL , qabrev(fTURNO,"DNM",{"Diurno ","Noturno","Misto  "}) )
      case cCAMPO == "SEXO"
           if empty(fSEXO) ; return .F. ; endif
           qrsay ( XNIVEL , qabrev(fSEXO,"MF",{"Masculino","Feminino"}) )
      case cCAMPO == "EST_CIVIL"
           if empty(fEST_CIVIL) ; return .F. ; endif
           qrsay ( XNIVEL , qabrev(fEST_CIVIL,"123456",{"Solteiro","Casado","Desquitado","Divorciado","Viuvo","Outros"}) )
      case cCAMPO == "INSTRUCAO"
           if empty(fINSTRUCAO) ; return .F. ; endif
           qrsay ( XNIVEL , qabrev(fINSTRUCAO,"123456789",{"Analfabeto","Educ. Infantil Inc.","Educacao Infantil","Ensino Fund Inc.","Ens. Fundamental","Ensino Medio Inc.","Ensino Medio","Superior Incompleto","Superior"}) )
      case cCAMPO == "CARGO"
           nINVERT := Rtrim(fCARGO)
           nQUANTI := 6 - Len(nINVERT)
           nCARGO  := Replicate(" ",nQUANTI)+nINVERT
           qrsay(XNIVEL,fCARGO := nCARGO)
           if CARGO->(dbseek(fCARGO))
              qrsay ( XNIVEL+1 , CARGO->Descricao )
           else
              qmensa("Cargo n„o encontrado !","B")
              return .F.
           endif
           fULT_CARGO := fCARGO
      case cCAMPO == "CBO"
           if CBO->(dbseek(fCBO))
              qrsay ( XNIVEL+1 , left(CBO->Descricao,40) )
           else
              qmensa("CBO n„o encontrado !","B")
              return .F.
           endif
      case cCAMPO == "GRPS"
           if GRPS->(dbseek(XANOMES + fGRPS))
              qrsay ( XNIVEL+1 , GRPS->Descricao )
           else
              qmensa("Guia de Grps n„o encontrada !","B")
              return .F.
           endif
      case cCAMPO == "FILIAL"
           if FILIAL->(dbseek(fFILIAL))
              qrsay ( XNIVEL+1 , left(FILIAL->Razao,40) )
           else
              qmensa("Filial n„o encontrado !","B")
              return .F.
           endif
//    case cCAMPO == "CENTRO"
//         if CCUSTO->(dbseek(fCENTRO))
//            if empty(right(fCENTRO,4))
//            if empty(fCENTRO)
//               qmensa("Centro de Custo n„o Anal¡tico !!","B")
//               return .F.
//            endif
//            qrsay ( XNIVEL+1 , CCUSTO->Descricao )
//         else
//            qmensa("Centro de Custo n„o encontrado !","B")
//            return .F.
//         endif
      case cCAMPO == "CCUSTO"
           if CCUSTO->(dbseek(fCCUSTO))
//            if empty(right(fCUSTO,4))
              if empty(fCCUSTO)
                 qmensa("Centro de Custo n„o Anal¡tico !!","B")
                 return .F.
              endif
              qrsay ( XNIVEL+1 , CCUSTO->Descricao )
           else
              qmensa("Centro de Custo n„o encontrado !","B")
              return .F.
           endif
      case cCAMPO == "DEPTO"
           if ! empty(fDEPTO)
              if DEPART->(dbseek(fDEPTO))
                 qrsay ( XNIVEL+1 , DEPART->Descricao )
              else
                 qmensa("Departamento n„o encontrado !","B")
                 return .F.
              endif
           endif
      case cCAMPO == "SIND_COD"
           if SIND->(dbseek(fSIND_COD))
              qrsay ( XNIVEL+1 , left(SIND->Descricao,40) )
           else
              qmensa("Sindicato n„o encontrado !","B")
              return .F.
           endif

      case cCAMPO == "ESPECIFICA"

           if empty(fESPECIFICA) ; return .F. ; endif

           qrsay ( XNIVEL , qabrev(fESPECIFICA,"012345678",{"Nunca Foi Exposto a Agentes Nocivos","N„o Exposi‡„o a Agente Nocivo","Exposic.a Agent.Nocivo(Aposent.aos 15anos)","Exposic.a Agent.Nocivo(Aposent.aos 20anos)",;
           "Exposic.a Agent.Nocivo(Aposent.aos 25anos)","N„o Exposic.a Agent.Nocivo(Mais de 1 Vinculo)","Exposic.a Agent.Nocivo(Aposent.aos 15anos)","Exposic.a Agent.Nocivo(Aposent.aos 20anos)","Exposic.a Agent.Nocivo(Aposent.aos 25anos)"}) )

      case cCAMPO == "DATA_ADM"
           if empty(fDATA_ADM) ; return .F. ; endif
           if cOPCAO == "I"
              fFGTS_DAT := fEXAME_MED := fDATA_ADM
              if  ( month(fDATA_ADM) < month(CONFIG->Datasys) ) .or. ( month(fDATA_ADM) > month(CONFIG->Datasys) )
                 qmensa("Funcion rio n„o pode ser inclu¡do fora do mˆs!!","B")
                 return .F.
              endif
           endif
           fPI_FERIAS := fDATA_ADM + 366
           fPF_FERIAS := qfimmes(fDATA_ADM) + 366
           fDI_FERIAS := fDATA_ADM
           fDF_FERIAS := fDATA_ADM + 365
           fAI_FERIAS := fDATA_ADM - 365
           fAF_FERIAS := fDATA_ADM - 1
           if fVINCULO <> "N"
              qgetx(21,34,@nDIAS_CTR,"99",)

              fDATA_RCTR := fDATA_ADM + nDIAS_CTR - 1
              if cOPCAO == "I"
                 fDATA_FCTR := fDATA_RCTR + nDIAS_CTR
              endif

              qgetx(21,58,@fDATA_RCTR,"  /  /  ",)
              qgetx(21,69,@fDATA_FCTR,"  /  /  ",)
              monta16("2")
           else
              monta16("2")
           endif

      // MUDA PARA TELA 2 ___________________________________________________

      case cCAMPO == "IDT_CGM"
           if CGM->(dbseek(fIDT_CGM))
              qrsay ( XNIVEL+1 , CGM->Municipio+"/"+CGM->Estado )
           endif
      case cCAMPO == "CP_CGM"
           if CGM->(dbseek(fCP_CGM))
              qrsay ( XNIVEL+1 , CGM->Municipio+"/"+CGM->Estado )
           endif
      case cCAMPO == "RES_SIT"
           if empty(fRES_SIT) ; return .F. ; endif
           qrsay ( XNIVEL , qabrev(fRES_SIT,"01234567",{"Indefinido","Cert.Disp.Incorpora‡„o","Cert.Alistamento Militar","Atestado Desobriga‡„o","Cert.Reserv.1¦ Categoria","Cert.Reserv.2¦ Categoria","Cert.Reserv.3¦ Categoria","Certificado de Isen‡„o"}) )
      case cCAMPO == "HAB_CGM"
           if CGM->(dbseek(fHAB_CGM))
              qrsay ( XNIVEL+1 , CGM->Municipio+"/"+CGM->Estado )
           endif
      case cCAMPO == "TE_CGM"
           if CGM->(dbseek(fTE_CGM))
              qrsay ( XNIVEL+1 , CGM->Municipio+"/"+CGM->Estado )
           endif
           monta16("3")

      // MUDA PARA TELA 3 ___________________________________________________

      case cCAMPO == "CPF_NUM"
           if ! qcheckcpf(fCPF_NUM)
              qmensa("Numero do CPF invalido !","B")
              return .F.
           endif
      case cCAMPO == "NAC_PAI"
           if empty(fNAC_PAI) ; return .F. ; endif
           qrsay ( XNIVEL , expan_nacio(fNAC_PAI) )
      case cCAMPO == "NAC_MAE"
           if empty(fNAC_MAE) ; return .F. ; endif
           qrsay ( XNIVEL , expan_nacio(fNAC_MAE) )
      case cCAMPO == "FGTS_BAN"
           if BANCO->(dbseek(fFGTS_BAN))
              qrsay ( XNIVEL+1 , left(Banco->Descricao,41) )
           endif
      case cCAMPO == "CSAL_BAN"
           if BANCO->(dbseek(fCSAL_BAN))
              qrsay ( XNIVEL+1 , left(Banco->Descricao,41) )
           endif
      case cCAMPO == "MODAL_PAG"
           if empty(fMODAL_PAG) ; return .F. ; endif
           qrsay ( XNIVEL , qabrev(fMODAL_PAG,"1345",{"Cr‚dito em Conta Corrente","Cr‚dito em Conta de Cart„o Pagamento",;
                                                      "Ordem de Pagamento Verde-Amarela","Cheque"}) )
      case cCAMPO == "PIS_TIP"
           if empty(fPIS_TIP) ; return .F. ; endif
           qrsay ( XNIVEL , qabrev(fPIS_TIP,"12",{"PIS  ","PASEP"}) )
      case cCAMPO == "PIS_NUM"
           if len(alltrim(fPIS_NUM)) <> 11
              qmensa("Favor fornecer o numero do PIS","B")
              return .F.
           endif
    //       if ! qcheckpis(fPIS_NUM)
    //          qmensa("D¡gito verificador inv lido !","B")
    //          return .F.
    //       endif
      case cCAMPO == "PIS_BAN"
           if BANCO->(dbseek(fPIS_BAN))
              qrsay ( XNIVEL+1 , left(Banco->Descricao,41) )
           endif
           monta16("4")

      // MUDA PARA TELA 4 ___________________________________________________

      case cCAMPO == "RESID_CGM"
           if CGM->(dbseek(fRESID_CGM))
              qrsay ( XNIVEL+1 , CGM->Municipio+"/"+CGM->Estado )
           endif
      case cCAMPO == "SEXO"
           if empty(fSEXO) ; return .F. ; endif
           qrsay ( XNIVEL , qabrev(fSEXO,"MF",{"Masculino","Feminino"}) )
      case cCAMPO == "EST_CIVIL"
           if empty(fEST_CIVIL) ; return .F. ; endif
           qrsay ( XNIVEL , qabrev(fEST_CIVIL,"123456",{"Solteiro","Casado","Desquitado","Divorciado","Viuvo","Outros"}) )
      case cCAMPO == "INSTRUCAO"
           if empty(fINSTRUCAO) ; return .F. ; endif
           qrsay ( XNIVEL , qabrev(fINSTRUCAO,"123456789",{"Analfabeto","Educ. Infantil Inc.","Educacao Infantil","Ensino Fund Inc.","Ens. Fundamental","Ensino Medio Inc.","Ensino Medio","Superior Incompleto","Superior"}) )
      case cCAMPO == "NACIONAL"
           if empty(fNACIONAL) ; return .F. ; endif
           qrsay ( XNIVEL , expan_nacio(fNACIONAL) )
      case cCAMPO == "NC_CGM"
           if CGM->(dbseek(fNC_CGM))
              qrsay ( XNIVEL+1 , CGM->Municipio+"/"+CGM->Estado )
           endif
      case cCAMPO == "NAT_CGM"
           if CGM->(dbseek(fNAT_CGM))
              qrsay ( XNIVEL+1 , CGM->Municipio+"/"+CGM->Estado )
           endif
      case cCAMPO == "NC_19"
           monta16("5")

      // MUDA PARA TELA 5 ___________________________________________________

      case cCAMPO == "DATA_NASC"
           if empty(fDATA_NASC)
              qmensa("Favor digitar a data de nascimento !","B")
              return .F.
           endif
      case cCAMPO == "CTP_ETI"
           if empty(fCTP_ETI) ; return .F. ; endif
           qrsay ( XNIVEL , qabrev(fCTP_ETI,"SN",{"Sim","N„o"}) )
      case cCAMPO == "CTP_NUM"
           monta16("6")

      // MUDA PARA TELA 6 ___________________________________________________

      case cCAMPO == "SANGUE"
           if empty(fSANGUE) ; return .F. ; endif
           qrsay ( XNIVEL  , qabrev(fSANGUE,"012345678",{'INDEFIN.','"A " (+)','"A " (-)','"B " (+)','"B " (-)','"O " (+)','"O " (-)','"AB" (+)','"AB" (-)'}))
      case cCAMPO == "MAODEOBRA"
           if empty(fMAODEOBRA) ; return .F. ; endif
           qrsay ( XNIVEL , qabrev(fMAODEOBRA ,"1234",{"Direta","Indireta","Administrativa","De Rateio"}) )
      case cCAMPO == "PRIM_ADM"
           if empty(fPRIM_ADM) ; return .F. ; endif
           qrsay ( XNIVEL , qabrev(fPRIM_ADM,"SN",{"Sim","N„o"}) )
      case cCAMPO == "TRANSF"
           if empty(fTRANSF) ; return .F. ; endif
           qrsay ( XNIVEL , qabrev(fTRANSF,"SN",{"Sim","N„o"}) )
      case cCAMPO == "DATA_TRANS"
           if fTRANSF $ "S" .and. empty(fDATA_TRANS) ; return .F. ; endif
      case cCAMPO == "ESTAB_PROV"
           if empty(fESTAB_PROV) ; return .F. ; endif
           qrsay ( XNIVEL , qabrev(fESTAB_PROV,"01234567",{"Sem Estabilidade","Acidente","Cipista","Doen‡a","Encargo Publico","Gestante","Servi‡o Militar","Sindical"}) )
      case cCAMPO == "TIPO_PGTO"
           if empty(fTIPO_PGTO) ; return .F. ; endif
           qrsay ( XNIVEL , qabrev(fTIPO_PGTO,"BCDO",{"Banco","Cheque","Dinheiro","Outro"}) )
      case cCAMPO == "VALE_TRANS"
           if empty(fVALE_TRANS) ; return .F. ; endif
           qrsay ( XNIVEL , qabrev(fVALE_TRANS,"SN",{"Sim","N„o"}) )
      case cCAMPO == "APOSENTADO"
           if empty(fAPOSENTADO) ; return .F. ; endif
           qrsay ( XNIVEL , qabrev(fAPOSENTADO,"SN",{"Sim","N„o"}) )
           qsay(19,18,fULT_CARGO)
           qsay(19,27,CARGO->Descricao)
           qsay(21,22,fDT_AFAST)

   endcase
return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXCLUIR FUNCIONARIO __________________________________________

function exclusao101
   consulta101()

   if ! qconf("Confirma exclus„o deste Funcionario ?")
      return
   endif

   if SITUA->(qflock()) .and. BASE->(qflock()) .and. LANC->(qflock())
      SITUA->(dbeval({|| dbDelete()}, {|| Matricula == FUN->Matricula},,,, .F.))
      BASE->(dbeval({|| dbDelete()}, {|| Matricula == FUN->Matricula},,,, .F.))
      LANC->(dbeval({|| dbDelete()}, {|| Matricula == FUN->Matricula},,,, .F.))
      SITUA->(dbunlock())
      BASE->(dbunlock())
      LANC->(dbunlock())
   endif

   if FUN->(qrlock())
      FUN->(dbdelete())
      FUN->(dbunlock())
   else
      qm3()
   endif

   dbunlockall()
   dbcommitall()

return NIL

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAR TELA CHEIA QUANDO DA CONSULTA OU EXCLUSAO ____________

function consulta101
   local C_KEY
   XFLAG := .T.
   FUN->(qpublicfields())
   SITUA->(qseekn(FUN->Matricula))
   SITUA->(qpublicfields())
   FUN->(qcopyfields())
   SITUA->(qcopyfields())
   monta16("1")
   if cOPCAO == "E" ; return NIL ; endif
   qmensa("ALT+<1~6> p/ mudar telas \ <ESC> p/ sair")
   do while (C_KEY := inkey(0)) != 27
      C_KEY -= 375
      if C_KEY > 0 .and. C_KEY < 7
         monta16(str(C_KEY,1))
      endif
   enddo
return NIL

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXPANDIR NACIONALIDADE _______________________________________

function expan_nacio ( C_NACIONALIDADE )
   do case
      case C_NACIONALIDADE == "A" ; return "Brasileiro Nato     "
      case C_NACIONALIDADE == "B" ; return "Brasil. Naturalizado"
      case C_NACIONALIDADE == "C" ; return "Argentino           "
      case C_NACIONALIDADE == "D" ; return "Boliviano           "
      case C_NACIONALIDADE == "E" ; return "Chileno             "
      case C_NACIONALIDADE == "F" ; return "Paraguaio           "
      case C_NACIONALIDADE == "G" ; return "Uruguaio            "
      case C_NACIONALIDADE == "H" ; return "Alem†o              "
      case C_NACIONALIDADE == "I" ; return "Belga               "
      case C_NACIONALIDADE == "J" ; return "Britƒnico           "
      case C_NACIONALIDADE == "K" ; return "Canadense           "
      case C_NACIONALIDADE == "L" ; return "Espanhol            "
      case C_NACIONALIDADE == "M" ; return "Norte-Americano(EUA)"
      case C_NACIONALIDADE == "N" ; return "Francˆs             "
      case C_NACIONALIDADE == "O" ; return "Sui‡o               "
      case C_NACIONALIDADE == "P" ; return "Italiano            "
      case C_NACIONALIDADE == "Q" ; return "Japonˆs             "
      case C_NACIONALIDADE == "R" ; return "Chinˆs              "
      case C_NACIONALIDADE == "S" ; return "Coreano             "
      case C_NACIONALIDADE == "T" ; return "Portuguˆs           "
      case C_NACIONALIDADE == "U" ; return "Outros Latino-Americ"
      case C_NACIONALIDADE == "V" ; return "Outros Asi ticos    "
      case C_NACIONALIDADE == "X" ; return "Outros              "
   endcase
return " "

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MONTAR TELAS _________________________________________________

function monta16 ( cNUMTELA )
   qlbloc(5,0,"B101"+cNUMTELA,"QBLOC.GLO")
   atualiza_matricula()
   eval( &("{||say"+cNUMTELA+"()}") )
return NIL

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ATUALIZAR MATRICULA, NOME E MATRICULA ASSOCIADA ______________

static function atualiza_matricula
   qsay ( 07 , 10 , fMATRICULA )
   qsay ( 07 , 26 , left(fNOME,30))
   qsay ( 07 , 69 , fMAT_ASS   )
return NIL

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA PASSAR ENTRE TELAS ___________________________________________

 static function alt_16
   nTECLA_ALT := lastkey() - 375 ; keyboard chr(13)
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA SAIR DIRETO PARA A CONFIRMACAO DE GRAVACAO ___________________

static function alt_w
   nTECLA_ALT := 999 ; keyboard chr(13)
return NIL

// FUNCAO PARA INICIALIZAR CAMPOS ESPECIFICOS P/ INCLUSAO ___________________

static function inicializa_campos

   if cOPCAO == "I"
      FUN->(qinitfields())
      SITUA->(qseekn(FUN->Matricula))
      SITUA->(qinitfields())
      fTIPO_PGTO  := "C"
      fAPOSENTADO := "N"
      fVALE_TRANS := "S"
      fVINCULO    := "A"
      fPRIM_ADM   := "N"
      fFGTS_TAX   := 3
      fTRANSF     := "N"
   else
      FUN->(qcopyfields())
      SITUA->(qseekn(FUN->Matricula))
      SITUA->(qcopyfields())
      monta16("1")
   endif
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA CARREGAR OS BLOCOS NECESSARIOS _______________________________

function carrega_os_blocos_necessarios

   sBLOCO_B := qlbloc("B101B","QBLOC.GLO") // categoria reservista
   sBLOCO_G := qlbloc("B101G","QBLOC.GLO") // tipo_pgto
   sBLOCO_I := qlbloc("B101I","QBLOC.GLO") // estado civil
   sBLOCO_J := qlbloc("B101J","QBLOC.GLO") // grau de instrucao
   sBLOCO_K := qlbloc("B101K","QBLOC.GLO") // remuneracao contratual
   sBLOCO_M := qlbloc("B101M","QBLOC.GLO") // turno
   sBLOCO_N := qlbloc("B101N","QBLOC.GLO") // vinculo
   sBLOCO_O := qlbloc("B101O","QBLOC.GLO") // tipo de sangue
   sBLOCO_Q := qlbloc("B101Q","QBLOC.GLO") // sexo
   sBLOCO_R := qlbloc("B101R","QBLOC.GLO") // mao de obra
   sBLOCO_S := qlbloc("B101S","QBLOC.GLO") // estabilidade provisoria
   sBLOCO_T := qlbloc("B101T","QBLOC.GLO") // nacionalidades
   sBLOCO_U := qlbloc("B101U","QBLOC.GLO") // modalidade de pagamento
   sBLOCO_AA := qlbloc("B102B","QBLOC.GLO")
return NIL

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA PREENCHER O VETOR DA TELA 1 __________________________________

function inic_edicao

   qmensa("Preparando Tela 1...")
   aadd(aEDICAO1,{{ || qgetx(-1,0,@fMATRICULA,"@K@9",NIL,CONFIG->Tipo_mat=="I".and.cOPCAO=="I") }, "MATRICULA"  })

   aadd(aEDICAO1,{{ || qgetx(-1,0,@fNOME,"@!S30")                 }, "NOME"      })
   aadd(aEDICAO1,{{ || qgetx(-1,0,@fMAT_ASS,"@!")                 }, "MAT_ASS"   })
   aadd(aEDICAO1,{{ || qesco(-1,0,@fCATEGORIA,sBLOCO_K)           }, "CATEGORIA" })
   aadd(aEDICAO1,{{ || qesco(-1,0,@fVINCULO  ,sBLOCO_N)           }, "VINCULO"   })
   aadd(aEDICAO1,{{ || qesco(-1,0,@fTURNO    ,sBLOCO_M)           }, "TURNO"     })
   aadd(aEDICAO1,{{ || qesco(-1,0,@fSEXO     ,sBLOCO_Q)           }, "SEXO"      })
   aadd(aEDICAO1,{{ || qesco(-1,0,@fEST_CIVIL,sBLOCO_I)           }, "EST_CIVIL" })
   aadd(aEDICAO1,{{ || qesco(-1,0,@fINSTRUCAO,sBLOCO_J)           }, "INSTRUCAO" })
   aadd(aEDICAO1,{{ || qesco(-1,0,@fESPECIFICA,sBLOCO_AA)            } ,"ESPECIFICA"})
   aadd(aEDICAO1,{{ || view_cargo(-1,0,@fCARGO,"@!")              }, "CARGO"     })
   aadd(aEDICAO1,{{ || NIL },NIL}) // descricao do cargo
   aadd(aEDICAO1,{{ || view_cbo(-1,0,@fCBO)                       }, "CBO"       })
   aadd(aEDICAO1,{{ || NIL },NIL}) // descricao do cbo
   aadd(aEDICAO1,{{ || view_grps(-1,0,@fGRPS)                     }, "GRPS"      })
   aadd(aEDICAO1,{{ || NIL },NIL}) // descricao da guia
   aadd(aEDICAO1,{{ || view_filia(-1,0,@fFILIAL)                  }, "FILIAL"    })
   aadd(aEDICAO1,{{ || NIL },NIL}) // descricao do filial
// aadd(aEDICAO1,{{ || view_ccusto(-1,0,@fCENTRO)                 }, "CENTRO"    })
   aadd(aEDICAO1,{{ || view_ccusto(-1,0,@fCCUSTO)                 }, "CCUSTO"    })
   aadd(aEDICAO1,{{ || NIL },NIL}) // descricao do centro
   aadd(aEDICAO1,{{ || view_dpto(-1,0,@fDEPTO)                    }, "DEPTO"     })
   aadd(aEDICAO1,{{ || NIL },NIL}) // descricao do departamento
   aadd(aEDICAO1,{{ || view_sind(-1,0,@fSIND_COD , "@R 99")       }, "SIND_COD"  })
   aadd(aEDICAO1,{{ || NIL },NIL}) // sindicato
   aadd(aEDICAO1,{{ || qgetx(-1,0,@fDATA_ADM ,"  /  /  ",)        }, "DATA_ADM"  })

   qmensa("Preparando Tela 2...")
   aadd(aEDICAO2,{{ || qgetx(-1,0,@fIDT_NUM  )                    }, "IDT_NUM"   })
   aadd(aEDICAO2,{{ || qgetx(-1,0,@fIDT_DAT  )                    }, "IDT_DAT"   })
   aadd(aEDICAO2,{{ || qgetx(-1,0,@fIDT_EMI  )                    }, "IDT_EMI"   })
   aadd(aEDICAO2,{{ || view_cgm(-1,0,@fIDT_CGM)                   }, "IDT_CGM"   })
   aadd(aEDICAO2,{{ || NIL },NIL}) // municipio
   aadd(aEDICAO2,{{ || qgetx(-1,0,@fIDT_VIA  )                    }, "IDT_VIA"   })
   aadd(aEDICAO2,{{ || qgetx(-1,0,@fCP_NUM   )                    }, "CP_NUM"    })
   aadd(aEDICAO2,{{ || qgetx(-1,0,@fCP_SERIE )                    }, "CP_SERIE"  })
   aadd(aEDICAO2,{{ || qgetx(-1,0,@fCP_EMIS  )                    }, "CP_EMIS"   })
   aadd(aEDICAO2,{{ || qgetx(-1,0,@fCP_PAGINA)                    }, "CP_PAGINA" })
   aadd(aEDICAO2,{{ || view_cgm(-1,0,@fCP_CGM)                    }, "CP_CGM"    })
   aadd(aEDICAO2,{{ || NIL },NIL}) // municipio
   aadd(aEDICAO2,{{ || qgetx(-1,0,@fRES_NUM  )                    }, "RES_NUM"   })
   aadd(aEDICAO2,{{ || qgetx(-1,0,@fRES_REG  )                    }, "RES_REG"   })
   aadd(aEDICAO2,{{ || qgetx(-1,0,@fRES_CIR  )                    }, "RES_CIR"   })
   aadd(aEDICAO2,{{ || qesco(16,48,@fRES_SIT,sBLOCO_B)            }, "RES_SIT"   })
   aadd(aEDICAO2,{{ || qgetx(-1,0,@fHAB_NUM )                     }, "HAB_NUM"   })
   aadd(aEDICAO2,{{ || qgetx(-1,0,@fHAB_CAT )                     }, "HAB_CAT"   })
   aadd(aEDICAO2,{{ || qgetx(-1,0,@fHAB_DAT )                     }, "HAB_DAT"   })
   aadd(aEDICAO2,{{ || view_cgm(-1,0,@fHAB_CGM)                   }, "HAB_CGM"   })
   aadd(aEDICAO2,{{ || NIL },NIL}) // municipi
   aadd(aEDICAO2,{{ || qgetx(-1,0,@fTE_NUM  )                     }, "TE_NUM"    })
   aadd(aEDICAO2,{{ || qgetx(-1,0,@fTE_ZON  )                     }, "TE_ZON"    })
   aadd(aEDICAO2,{{ || qgetx(-1,0,@fTE_SEC  )                     }, "TE_SEC"    })
   aadd(aEDICAO2,{{ || view_cgm(-1,0,@fTE_CGM)                    }, "TE_CGM"    })
   aadd(aEDICAO2,{{ || NIL },NIL}) // municipio

   qmensa("Preparando Tela 3...")
   aadd(aEDICAO3,{{ || qgetx(-1,0,@fCPF_NUM,"@R 999.999.999-99" ) }, "CPF_NUM"   })
   aadd(aEDICAO3,{{ || qgetx(-1,0,@fNOME_PAI ,"@!")               }, "NOME_PAI"  })
   aadd(aEDICAO3,{{ || qesco(0,52,@fNAC_PAI,sBLOCO_T)             }, "NAC_PAI"   })
   aadd(aEDICAO3,{{ || qgetx(-1,0,@fNOME_MAE ,"@!S30")            }, "NOME_MAE"  })
   aadd(aEDICAO3,{{ || qesco(0,52,@fNAC_MAE,sBLOCO_T)             }, "NAC_MAE"   })
   aadd(aEDICAO3,{{ || qgetx(-1,0,@fFGTS_DAT)                     }, "FGTS_DAT"  })
   aadd(aEDICAO3,{{ || qgetx(-1,0,@fFGTS_TAX,"9")                 }, "FGTS_TAX"  })
   aadd(aEDICAO3,{{ || qgetx(-1,0,@fFGTS_NUM)                     }, "FGTS_NUM"  })
   aadd(aEDICAO3,{{ || view_banco(-1,0,@fFGTS_BAN)                }, "FGTS_BAN"  })
   aadd(aEDICAO3,{{ || NIL },NIL}) // banco
   aadd(aEDICAO3,{{ || qgetx(-1,0,@fCSAL_DAT)                     }, "CSAL_DAT"  })
   aadd(aEDICAO3,{{ || qgetx(-1,0,@fCSAL_NUM)                     }, "CSAL_NUM"  })
   aadd(aEDICAO3,{{ || view_banco(-1,0,@fCSAL_BAN)                }, "CSAL_BAN"  })
   aadd(aEDICAO3,{{ || NIL },NIL}) // banco
   aadd(aEDICAO3,{{ || qesco(-1,0,@fMODAL_PAG,sBLOCO_U)           }, "MODAL_PAG" })
   aadd(aEDICAO3,{{ || qgetx(-1,0,@fPIS_DAT)                      }, "PIS_DAT"   })
   aadd(aEDICAO3,{{ || qgetx(-1,0,@fPIS_NUM)                      }, "PIS_NUM"   })
   aadd(aEDICAO3,{{ || view_banco(-1,0,@fPIS_BAN)                 }, "PIS_BAN"   })
   aadd(aEDICAO3,{{ || NIL },NIL}) // banco

   qmensa("Preparando Tela 4...")
   aadd(aEDICAO4,{{ || qgetx(-1,0,@fENDERECO ,"@!")               }, "ENDERECO"  })
   aadd(aEDICAO4,{{ || qgetx(-1,0,@fBAIRRO   ,"@!")               }, "BAIRRO"    })
   aadd(aEDICAO4,{{ || qgetx(-1,0,@fCEP      ,"@!")               }, "CEP"       })
   aadd(aEDICAO4,{{ || view_cgm(-1,0,@fRESID_CGM)                 }, "RESID_CGM" })
   aadd(aEDICAO4,{{ || NIL },NIL}) // municipio
   aadd(aEDICAO4,{{ || qgetx(-1,0,@fDDD      ,"@!")               }, "DDD"       })
   aadd(aEDICAO4,{{ || qgetx(-1,0,@fTELEFONE ,"@!")               }, "TELEFONE"  })
   aadd(aEDICAO4,{{ || qesco(0,52,@fNACIONAL,sBLOCO_T)            }, "NACIONAL"  })
   aadd(aEDICAO4,{{ || view_cgm(-1,0,@fNAT_CGM)                   }, "NAT_CGM"   })
   aadd(aEDICAO4,{{ || NIL },NIL}) // municipio
   aadd(aEDICAO4,{{ || view_cgm(-1,0,@fNC_CGM)                    }, "NC_CGM"    })
   aadd(aEDICAO4,{{ || NIL },NIL}) // municipio
   aadd(aEDICAO4,{{ || qgetx(-1,0,@fNC_DAT,"99/99/99")            }, "NC_DAT"    })
   aadd(aEDICAO4,{{ || qgetx(-1,0,@fNC_19)                        }, "NC_19"     })

   qmensa("Preparando Tela 5...")
   aadd(aEDICAO5,{{ || qgetx(-1,0,@fDATA_NASC)                    }, "DATA_NASC" })
   aadd(aEDICAO5,{{ || qgetx(-1,0,@fHOR_TRAB,"@E 999.99")               }, "HOR_TRAB"  })
   aadd(aEDICAO5,{{ || qgetx(-1,0,@fHOR_SEMA,"999")               }, "HOR_SEMA"  })
   aadd(aEDICAO5,{{ || qgetx(-1,0,@fHENTRADA,"99:99")             }, "HENTRADA"  })
   aadd(aEDICAO5,{{ || qgetx(-1,0,@fHINTERVALO,"99:99-99:99")     }, "HINTERVALO"})
   aadd(aEDICAO5,{{ || qgetx(-1,0,@fHSAIDA,"99:99")               }, "HSAIDA"    })
   aadd(aEDICAO5,{{ || qgetx(-1,0,@fHSABADO,"99:99-99:99")        }, "HSABADO"   })
   aadd(aEDICAO5,{{ || qgetx(-1,0,@fDESCANSO,"@!")                }, "DESCANSO"  })
   aadd(aEDICAO5,{{ || qgetx(-1,0,@fEXAME_MED)                    }, "EXAME_MED" })
   aadd(aEDICAO5,{{ || qgetx(-1,0,@fDATA_INSS)                    }, "DATA_INSS" })
   aadd(aEDICAO5,{{ || qesco(-1,0,@fCTP_ETI,XSN)                  }, "CTP_ETI"   })
   aadd(aEDICAO5,{{ || qgetx(-1,0,@fCTP_QUA,"@!")                 }, "CTP_QUA"   })
   aadd(aEDICAO5,{{ || qgetx(-1,0,@fCTP_NUM,"@!")                 }, "CTP_NUM"   })

   qmensa("Preparando Tela 6...")
   aadd(aEDICAO6,{{ || qesco(-1,0,@fSANGUE,sBLOCO_O)              }, "SANGUE"    })
   aadd(aEDICAO6,{{ || qesco(-1,0,@fMAODEOBRA ,sBLOCO_R)          }, "MAODEOBRA" })
   aadd(aEDICAO6,{{ || qesco(-1,0,@fESTAB_PROV,sBLOCO_S)          }, "ESTAB_PROV"})
   aadd(aEDICAO6,{{ || qgetx(-1,0,@fESTAB_DOC,"@!")               }, "ESTAB_DOC" })
   aadd(aEDICAO6,{{ || qgetx(-1,0,@fESTAB_DAT,NIL)                }, "ESTAB_DAT" })
   aadd(aEDICAO6,{{ || qesco(-1,0,@fPRIM_ADM  ,XSN)               }, "PRIM_ADM"  })
   aadd(aEDICAO6,{{ || qesco(-1,0,@fTRANSF    ,XSN)               }, "TRANSF"    })
   aadd(aEDICAO6,{{ || qgetx(-1,0,@fDATA_TRANS)                   }, "DATA_TRANS"})
   aadd(aEDICAO6,{{ || qesco(-1,0,@fTIPO_PGTO ,sBLOCO_G)          }, "TIPO_PGTO" })
   aadd(aEDICAO6,{{ || qesco(-1,0,@fVALE_TRANS,XSN)               }, "VALE_TRANS"})
   aadd(aEDICAO6,{{ || qesco(-1,0,@fAPOSENTADO,XSN)               }, "APOSENTADO"})
   aadd(aEDICAO6,{{ || qgetx(-1,0,@fOBS  ,"@!")                   }, "OBS"       })

   aadd(aEDICAO6,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

return NIL

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ATUALIZAR TELA 1 QUANDO DA ALTERACAO _________________________

function say1
   local nNIVEL := 1
   qrsay ( nNIVEL++ , fMATRICULA    )
   qrsay ( nNIVEL++ , left(fNOME,30))
   qrsay ( nNIVEL++ , fMAT_ASS      )
   qrsay ( nNIVEL++ , qabrev(fCATEGORIA,"123456789",{"Mensal","Quinzenal","Semanal","Diario","Horario","Tarefa","Comissao","Honorario","Estagiario"}) )
   qrsay ( nNIVEL++ , qabrev(fVINCULO,"ABCDEFGHIJKLMNO",{"Urbano-CLT/PJ/Pz Ind.","Urbano-CLT/PF/Pz Ind.","Rural-CLT/PJ/Pz Ind.","Rural-CLT/PF/Pz Ind.","Servidor(RJU)-Militar","Trabalhador Autonomo",+;
   "Trabalhador Avulso","Trabalhador Tempor rio","Urbano-CLT/PJ/Pz. Det.","Urbano-CLT/PF/Pz. Det.","Rural-CLT/PJ/Pz. Det.","Rural-CLT/PF/Pz. Det.","Diretor c/V¡nc. FGTS","Diretor s/V¡nc. FGTS","Menor Aprendiz"}))
   qrsay ( nNIVEL++ , qabrev(fTURNO,"DNM",{"Diurno","Noturno","Misto"}) )
   qrsay ( nNIVEL++ , qabrev(fSEXO,"MF",{"Masculino","Feminino"}) )
   qrsay ( nNIVEL++ , qabrev(fEST_CIVIL,"123456",{"Solteiro","Casado","Desquitado","Divorciado","Viuvo","Outros"}) )
   qrsay ( nNIVEL++ , qabrev(fINSTRUCAO,"123456789",{"Analfabeto","Educ. Infantil Inc.","Educacao Infantil","Ensino Fund Inc.","Ens. Fundamental","Ensino Medio Inc.","Ensino Medio","Superior Incompleto","Superior"}) )
   qrsay ( nNIVEL++,qabrev(FUN->Especifica,"012345678",{"Nunca Foi Exposto a Agentes Nocivos","N„o Exposi‡„o a Agente Nocivo","Exposic.a Agent.Nocivo(Aposent.aos 15anos)","Exposic.a Agent.Nocivo(Aposent.aos 20anos)",;
   "Exposic.a Agent.Nocivo(Aposent.aos 25anos)","N„o Exposic.a Agent.Nocivo (Mais de 1 Vinculo)","Exposic.a Agent.Nocivo(Aposent.aos 15anos)","Exposic.a Agent.Nocivo(Aposent.aos 20anos)","Exposic.a Agent.Nocivo(Aposent.aos 25anos)"}))

   qrsay ( nNIVEL++ , fCARGO        ) ; CARGO->(dbseek(fCARGO))
   qrsay ( nNIVEL++ , CARGO->Descricao )
   qrsay ( nNIVEL++ , fCBO          ) ; CBO->(dbseek(fCBO))
   qrsay ( nNIVEL++ , left(CBO->Descricao,40) )
   qrsay ( nNIVEL++ , fGRPS         ) ; GRPS->(dbseek(XANOMES + fGRPS))
   qrsay ( nNIVEL++ , GRPS->Descricao )
   qrsay ( nNIVEL++ , fFILIAL       ) ; FILIAL->(dbseek(fFILIAL))
   qrsay ( nNIVEL++ , left(FILIAL->Razao,40) )
// qrsay ( nNIVEL++ , transform(fCENTRO,"@R 99.99.9999")) ; CCUSTO->(dbseek(fCENTRO))
   qrsay ( nNIVEL++ , transform(fCCUSTO,"@R 99.99.9999")) ; CCUSTO->(dbseek(fCCUSTO))
   qrsay ( nNIVEL++ , CCUSTO->Descricao )
   qrsay ( nNIVEL++ , fDEPTO        ) ; DEPART->(dbseek(fDEPTO))
   qrsay ( nNIVEL++ , DEPART->Descricao )
   qrsay ( nNIVEL++ , fSIND_COD     ) ; SIND->(dbseek(fSIND_COD))
   qrsay ( nNIVEL++ , left(SIND->Descricao,40)   )

   qrsay ( nNIVEL++ , fDATA_ADM     )

   if fVINCULO <> "N"
      if ! empty(fDATA_RCTR)
         qsay(21,34,nDIAS_CTR := fDATA_RCTR-fDATA_ADM+1,"99")
      else
         qsay(21,34,0,"99")
      endif

      qsay ( 21,58 , fDATA_RCTR    )
      qsay ( 21,69 , fDATA_FCTR    )
   endif

return NIL

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ATUALIZAR TELA 2 QUANDO DA ALTERACAO _________________________

function say2
   local nNIVEL := 1
   qrsay ( nNIVEL++ , fIDT_NUM   )
   qrsay ( nNIVEL++ , fIDT_DAT   )
   qrsay ( nNIVEL++ , fIDT_EMI   )
   qrsay ( nNIVEL++ , fIDT_CGM   ) ; CGM->(dbseek(fIDT_CGM))
   qrsay ( nNIVEL++ , CGM->Municipio+"/"+CGM->Estado )
   qrsay ( nNIVEL++ , fIDT_VIA   )
   qrsay ( nNIVEL++ , fCP_NUM    )
   qrsay ( nNIVEL++ , fCP_SERIE  )
   qrsay ( nNIVEL++ , fCP_EMIS   )
   qrsay ( nNIVEL++ , fCP_PAGINA )
   qrsay ( nNIVEL++ , fCP_CGM  ) ; CGM->(dbseek(fCP_CGM))
   qrsay ( nNIVEL++ , CGM->Municipio+"/"+CGM->Estado )
   qrsay ( nNIVEL++ , fRES_NUM   )
   qrsay ( nNIVEL++ , fRES_REG   )
   qrsay ( nNIVEL++ , fRES_CIR   )
   qrsay ( nNIVEL++ , qabrev(fRES_SIT,"01234567",{"Indefinido","Cert.Disp.Incorpora‡„o","Cert.Alistamento Militar","Atestado Desobriga‡„o","Cert.Reserv.1¦ Categoria","Cert.Reserv.2¦ Categoria","Cert.Reserv.3¦ Categoria","Certificado de Isen‡„o"}) )
   qrsay ( nNIVEL++ , fHAB_NUM  )
   qrsay ( nNIVEL++ , fHAB_CAT  )
   qrsay ( nNIVEL++ , fHAB_DAT  )
   qrsay ( nNIVEL++ , fHAB_CGM  ) ; CGM->(dbseek(fHAB_CGM))
   qrsay ( nNIVEL++ , CGM->Municipio+"/"+CGM->Estado )
   qrsay ( nNIVEL++ , fTE_NUM   )
   qrsay ( nNIVEL++ , fTE_ZON   )
   qrsay ( nNIVEL++ , fTE_SEC   )
   qrsay ( nNIVEL++ , fTE_CGM   ) ; CGM->(dbseek(fTE_CGM))
   qrsay ( nNIVEL++ , CGM->Municipio+"/"+CGM->Estado )
return NIL

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ATUALIZAR TELA 3 QUANDO DA ALTERACAO _________________________

function say3
   local nNIVEL := 1
   qrsay ( nNIVEL++ , fCPF_NUM , "@R 999.999.999-99"  )
   qrsay ( nNIVEL++ , fNOME_PAI  )
   qrsay ( nNIVEL++ , expan_nacio(fNAC_PAI) )
   qrsay ( nNIVEL++ , left(fNOME_MAE,30)  )
   qrsay ( nNIVEL++ , expan_nacio(fNAC_MAE) )
   qrsay ( nNIVEL++ , fFGTS_DAT )
   qrsay ( nNIVEL++ , fFGTS_TAX , "9" )
   qrsay ( nNIVEL++ , fFGTS_NUM )
   qrsay ( nNIVEL++ , fFGTS_BAN ) ; BANCO->(dbseek(fFGTS_BAN))
   qrsay ( nNIVEL++ , left(Banco->Descricao,41) )
   qrsay ( nNIVEL++ , fCSAL_DAT  )
   qrsay ( nNIVEL++ , fCSAL_NUM  )
   qrsay ( nNIVEL++ , fCSAL_BAN  ) ; BANCO->(dbseek(fCSAL_BAN))
   qrsay ( nNIVEL++ , left(Banco->Descricao,41) )
   qrsay ( nNIVEL++ , qabrev(fMODAL_PAG,"1345",{"Cr‚dito em Conta Corrente","Cr‚dito em Conta de Cart„o Pagamento",;
                                                "Ordem de Pagamento Verde-Amarela","Cheque"}) )
   qrsay ( nNIVEL++ , fPIS_DAT  )
   qrsay ( nNIVEL++ , fPIS_NUM  )
   qrsay ( nNIVEL++ , fPIS_BAN  ) ; BANCO->(dbseek(fPIS_BAN))
   qrsay ( nNIVEL++ , left(Banco->Descricao,41) )
return NIL

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ATUALIZAR TELA 4 QUANDO DA ALTERACAO _________________________

function say4
   local nNIVEL := 1
   qrsay ( nNIVEL++ , fENDERECO  )
   qrsay ( nNIVEL++ , fBAIRRO    )
   qrsay ( nNIVEL++ , fCEP       )
   qrsay ( nNIVEL++ , fRESID_CGM   ) ; CGM->(dbseek(fRESID_CGM))
   qrsay ( nNIVEL++ , CGM->Municipio+"/"+CGM->Estado )
   qrsay ( nNIVEL++ , fDDD       )
   qrsay ( nNIVEL++ , fTELEFONE  )
   qrsay ( nNIVEL++ , expan_nacio(fNACIONAL) )
   qrsay ( nNIVEL++ , fNAT_CGM   ) ; CGM->(dbseek(fNAT_CGM))
   qrsay ( nNIVEL++ , CGM->Municipio+"/"+CGM->Estado )
   qrsay ( nNIVEL++ , fNC_CGM    ) ; CGM->(dbseek(fNC_CGM))
   qrsay ( nNIVEL++ , CGM->Municipio+"/"+CGM->Estado )
   qrsay ( nNIVEL++ , fNC_DAT    )
   qrsay ( nNIVEL++ , fNC_19     )
return NIL

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ATUALIZAR TELA 5 QUANDO DA ALTERACAO _________________________

function say5
   local nNIVEL := 1
   qrsay ( nNIVEL++ , fDATA_NASC  )
   qrsay ( nNIVEL++ , fHOR_TRAB     , "@E 999.99" )
   qrsay ( nNIVEL++ , fHOR_SEMA     , "999" )
   qrsay ( nNIVEL++ , fHENTRADA     )
   qrsay ( nNIVEL++ , fHINTERVALO   )
   qrsay ( nNIVEL++ , fHSAIDA       )
   qrsay ( nNIVEL++ , fHSABADO      )
   qrsay ( nNIVEL++ , fDESCANSO     )
   qrsay ( nNIVEL++ , fEXAME_MED    )
   qrsay ( nNIVEL++ , fDATA_INSS    )
   qrsay ( nNIVEL++ , qabrev(fCTP_ETI,"SN",{"Sim","N„o"}) )
   qrsay ( nNIVEL++ , fCTP_QUA      )
   qrsay ( nNIVEL++ , fCTP_NUM      )
return NIL

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ATUALIZAR TELA 6 QUANDO DA ALTERACAO _________________________

function say6
   local nNIVEL := 1
   qrsay ( nNIVEL++ , qabrev(fSANGUE,"012345678",{'INDEFIN.','"A " (+)','"A " (-)','"B " (+)','"B " (-)','"O " (+)','"O " (-)','"AB" (+)','"AB" (-)'}) )
   qrsay ( nNIVEL++ , qabrev(fMAODEOBRA ,"1234",{"Direta        ","Indireta      ","Administrativa","De Rateio     "}) )
   qrsay ( nNIVEL++ , qabrev(fESTAB_PROV,"01234567",{"Sem Estabilidade","Acidente        ","Cipista         ","Doen‡a          ","Encargo Publico ","Gestante        ","Servi‡o Militar ","Sindical        "}) )
   qrsay ( nNIVEL++ , fESTAB_DOC )
   qrsay ( nNIVEL++ , fESTAB_DAT )
   qrsay ( nNIVEL++ , qabrev(fPRIM_ADM  ,"SN",{"Sim","N„o"}) )
   qrsay ( nNIVEL++ , qabrev(fTRANSF    ,"SN",{"Sim","N„o"}) )
   qrsay ( nNIVEL++ , fDATA_TRANS )
   qrsay ( nNIVEL++ , qabrev(fTIPO_PGTO ,"BCDO",{"Banco","Cheque","Dinheiro","Outro"}) )
   qrsay ( nNIVEL++ , qabrev(fVALE_TRANS,"SN",{"Sim","N„o"}) )
   qrsay ( nNIVEL++ , qabrev(fAPOSENTADO,"SN",{"Sim","N„o"}) )
   qsay  ( 19,18,FUN->Ult_cargo                              );CARGO->(dbseek(FUN->Ult_cargo))
   qsay  ( 19,27,CARGO->Descricao)
   qsay  ( 21,22,FUN->Dt_Afast)
   qrsay ( nNIVEL++ , fOBS )
return NIL
