
/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: FOLHA DE PAGAMENTO
// OBJETIVO...: LANCAMENTOS VIA CAPTURA DE ARQUIVOS
// ANALISTA...: CARLOS EDUARDO RABELLO NUNES
// PROGRAMADOR: IDEM
// INICIO.....: SETEMBRO DE 1996
// OBS........:
// ALTERACOES.:

private cAMBIENTE

do while .T.
   cAMBIENTE := rh_escolhe_amb() // "MS","AD","DT","FR","PV"
   if empty(cAMBIENTE) ; return ; endif
   PTCFG->(qview({{"Codigo/C¢digo"      ,1},;
                  {"Descricao/Descri‡„o",2}},"P",;
                  {NIL,"c206a",NIL,NIL},;
                  NIL,q_msg_acesso_usr()+"/<R>ealiza Captura"))
enddo
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function c206a
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))
   if cOPCAO $ XUSRA + "R"
      qlbloc(5,0,"B206B","QBLOC.GLO")
      qmensa(qabrev(cOPCAO,"IA",{"Inclus„o...","Altera‡„o..."}))
      i_edicao()
   endif
   setcursor(nCURSOR)
return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA ____________________________________

static function i_edicao
   local lCONF
   local aEDICAO := {}
   local bESCAPE := {||empty(fCODIGO).or.(XNIVEL==1.and.!XFLAG).or.;
                       (XNIVEL==2.and.cOPCAO=="A".and.!XFLAG)}

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"
      XNIVEL := 1
      qrsay ( XNIVEL++ , PTCFG->Codigo    )
      qrsay ( XNIVEL++ , PTCFG->Descricao )
      qrsay ( XNIVEL++ , PTCFG->Cm1       )
      qrsay ( XNIVEL++ , PTCFG->Tp1       )
      qrsay ( XNIVEL++ , PTCFG->Tm1       )
      qrsay ( XNIVEL++ , PTCFG->Dc1       )
      qrsay ( XNIVEL++ , PTCFG->Ds1       )
      qrsay ( XNIVEL++ , PTCFG->Cm2       )
      qrsay ( XNIVEL++ , PTCFG->Tp2       )
      qrsay ( XNIVEL++ , PTCFG->Tm2       )
      qrsay ( XNIVEL++ , PTCFG->Dc2       )
      qrsay ( XNIVEL++ , PTCFG->Ds2       )
      qrsay ( XNIVEL++ , PTCFG->Cm3       )
      qrsay ( XNIVEL++ , PTCFG->Tp3       )
      qrsay ( XNIVEL++ , PTCFG->Tm3       )
      qrsay ( XNIVEL++ , PTCFG->Dc3       )
      qrsay ( XNIVEL++ , PTCFG->Ds3       )
      qrsay ( XNIVEL++ , PTCFG->Cm4       )
      qrsay ( XNIVEL++ , PTCFG->Tp4       )
      qrsay ( XNIVEL++ , PTCFG->Tm4       )
      qrsay ( XNIVEL++ , PTCFG->Dc4       )
      qrsay ( XNIVEL++ , PTCFG->Ds4       )
      qrsay ( XNIVEL++ , PTCFG->Cm5       )
      qrsay ( XNIVEL++ , PTCFG->Tp5       )
      qrsay ( XNIVEL++ , PTCFG->Tm5       )
      qrsay ( XNIVEL++ , PTCFG->Dc5       )
      qrsay ( XNIVEL++ , PTCFG->Ds5       )
      qrsay ( XNIVEL++ , PTCFG->Cm6       )
      qrsay ( XNIVEL++ , PTCFG->Tp6       )
      qrsay ( XNIVEL++ , PTCFG->Tm6       )
      qrsay ( XNIVEL++ , PTCFG->Dc6       )
      qrsay ( XNIVEL++ , PTCFG->Ds6       )
      qrsay ( XNIVEL++ , PTCFG->Fm1       ) ; FORM->(dbseek(PTCFG->Fm1))
      qrsay ( XNIVEL++ , FORM->Descricao  )
      qrsay ( XNIVEL++ , PTCFG->Fm2       ) ; FORM->(dbseek(PTCFG->Fm1))
      qrsay ( XNIVEL++ , FORM->Descricao  )
      qrsay ( XNIVEL++ , PTCFG->Fm3       ) ; FORM->(dbseek(PTCFG->Fm1))
      qrsay ( XNIVEL++ , FORM->Descricao  )
      qrsay ( XNIVEL++ , PTCFG->Fm4       ) ; FORM->(dbseek(PTCFG->Fm1))
      qrsay ( XNIVEL++ , FORM->Descricao  )
      qrsay ( XNIVEL++ , PTCFG->Fm5       ) ; FORM->(dbseek(PTCFG->Fm1))
      qrsay ( XNIVEL++ , FORM->Descricao  )
      qrsay ( XNIVEL++ , PTCFG->Fm6       ) ; FORM->(dbseek(PTCFG->Fm1))
      qrsay ( XNIVEL++ , FORM->Descricao  )
   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || qgetx(-1,0,@fCODIGO   ,"@!",NIL,cOPCAO=="I") }         ,"CODIGO"   })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDESCRICAO,"@!"     ,NIL,.T.) }            ,"DESCRICAO"})

   aadd(aEDICAO,{{ || qgetx(-1,0,@fCm1      ,"@!" ,NIL,.T.) },"CM1" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fTp1      ,"!"  ,NIL,.T.) },"TP1" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fTm1      ,"999",NIL,.T.) },"TM1" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDc1      ,"999",NIL,.T.) },"DC1" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDs1      ,"@!" ,NIL,.T.) },"DS1" })

   aadd(aEDICAO,{{ || qgetx(-1,0,@fCm2      ,"@!" ,NIL,.T.) },"CM2" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fTp2      ,"!"  ,NIL,.T.) },"TP2" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fTm2      ,"999",NIL,.T.) },"TM2" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDc2      ,"999",NIL,.T.) },"DC2" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDs2      ,"@!" ,NIL,.T.) },"DS2" })

   aadd(aEDICAO,{{ || qgetx(-1,0,@fCm3      ,"@!" ,NIL,.T.) },"CM3" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fTp3      ,"!"  ,NIL,.T.) },"TP3" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fTm3      ,"999",NIL,.T.) },"TM3" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDc3      ,"999",NIL,.T.) },"DC3" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDs3      ,"@!" ,NIL,.T.) },"DS3" })

   aadd(aEDICAO,{{ || qgetx(-1,0,@fCm4      ,"@!" ,NIL,.T.) },"CM4" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fTp4      ,"!"  ,NIL,.T.) },"TP4" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fTm4      ,"999",NIL,.T.) },"TM4" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDc4      ,"999",NIL,.T.) },"DC4" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDs4      ,"@!" ,NIL,.T.) },"DS4" })

   aadd(aEDICAO,{{ || qgetx(-1,0,@fCm5      ,"@!" ,NIL,.T.) },"CM5" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fTp5      ,"!"  ,NIL,.T.) },"TP5" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fTm5      ,"999",NIL,.T.) },"TM5" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDc5      ,"999",NIL,.T.) },"DC5" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDs5      ,"@!" ,NIL,.T.) },"DS5" })

   aadd(aEDICAO,{{ || qgetx(-1,0,@fCm6      ,"@!" ,NIL,.T.) },"CM6" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fTp6      ,"!"  ,NIL,.T.) },"TP6" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fTm6      ,"999",NIL,.T.) },"TM6" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDc6      ,"999",NIL,.T.) },"DC6" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDs6      ,"@!" ,NIL,.T.) },"DS6" })

   aadd(aEDICAO,{{ || view_form(-1,0,@fFm1)                 },"FM1" })
   aadd(aEDICAO,{{ || NIL                                   },NIL   })
   aadd(aEDICAO,{{ || view_form(-1,0,@fFm2)                 },"FM2" })
   aadd(aEDICAO,{{ || NIL                                   },NIL   })
   aadd(aEDICAO,{{ || view_form(-1,0,@fFm3)                 },"FM3" })
   aadd(aEDICAO,{{ || NIL                                   },NIL   })
   aadd(aEDICAO,{{ || view_form(-1,0,@fFm4)                 },"FM4" })
   aadd(aEDICAO,{{ || NIL                                   },NIL   })
   aadd(aEDICAO,{{ || view_form(-1,0,@fFm5)                 },"FM5" })
   aadd(aEDICAO,{{ || NIL                                   },NIL   })
   aadd(aEDICAO,{{ || view_form(-1,0,@fFm6)                 },"FM6" })
   aadd(aEDICAO,{{ || NIL                                   },NIL   })

   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   PTCFG->(qpublicfields())
   iif(cOPCAO=="I",PTCFG->(qinitfields()),PTCFG->(qcopyfields()))
   XNIVEL := 1
   XFLAG := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; PTCFG->(qreleasefields()) ; return ; endif
      if XFLAG
         if ! i_crit_d( aEDICAO[XNIVEL,2] ) ; loop ; endif
      else
         if ! i_crit_s( aEDICAO[XNIVEL,2] ) ; loop ; endif
      endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif

   if PTCFG->(iif(cOPCAO=="I",qappend(),qrlock()))
      PTCFG->(qreplacefields())
      PTCFG->(qunlock())
   else
      iif(cOPCAO=="I",qm1(),qm2())
   endif

return

/////////////////////////////////////////////////////////////////////////////
// CRITICAS NA DESCIDA ______________________________________________________

static function i_crit_d ( cCAMPO )
   local cMACRO
   iif ( cCAMPO == NIL , cCAMPO := "" , NIL )
   do case
      case cCAMPO == "CODIGO" .and. cOPCAO == "I"
           if PTCFG->(dbseek(fCODIGO))
              qmensa("Codigo j  cadastrado !","B")
              return .F.
           endif
      case left(cCAMPO,2) == "FM"
           cMACRO := "f" + cCAMPO
           FORM->(dbseek(&cMACRO))
           qrsay(XNIVEL+1,FORM->Descricao)
   endcase
return .T.

/////////////////////////////////////////////////////////////////////////////
// CRITICAS NA SUBIDA _______________________________________________________

static function i_crit_s ( cCAMPO )
return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXCLUIR CONFIG. DE CAPTURA ___________________________________

static function i_exclusao
   if qconf("Confirma exclus„o desta config. de captura ?")
      if PTCFG->(qrlock())
         replace PTCFG->Codigo with "@"
         PTCFG->(dbdelete())
         PTCFG->(qunlock())
      else
         qm3()
      endif
   endif
return






function xyzxyzxyz

// CAPTURA DE LANCAMENTOS

// DECLARACAO DE VARIAVEIS __________________________________________________

local C_OPCAO

// ESCOLHA DA OPERACAO A SER EXECUTADA ______________________________________

C_OPCAO := alert("Escolha a op‡„o:",{"1-Def.Estrutura","2-Def.Convers„o","3-Exec.Captura"})

do case
   case C_OPCAO == 1 ; f_def_est()
   case C_OPCAO == 2 ; f_def_con()
   case C_OPCAO == 3 ; f_exe_cap()
endcase

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA DEFINIR A ESTRUTURA PARA CAPTURA _____________________________

static function f_def_est
   local nCONT

   // colocar aqui qlbloc()

   if ! PTCFG->(qrlock())
      qmensa("N„o foi possivel travar arquivo !","B")
      return
   endif

   for nCONT := 1 to 11
       PTCFG->(dbgoto(nCONT))
       qsay(nCONT+8,10,PTCFG->Campo          )
       qsay(nCONT+8,25,PTCFG->Tipo           )
       qsay(nCONT+8,31,PTCFG->Tamanho  ,"999")
       qsay(nCONT+8,39,PTCFG->Decimais ,"999")
       qsay(nCONT+8,47,PTCFG->Descricao      )
   next

   PTCFG->(qpublicfields())

   for nCONT := 1 to 11
       PTCFG->(dbgoto(nCONT))
       PTCFG->(qcopyfields())
       qgetx(nCONT+8,10,@M_CAMPO    ,"@!" ,NIL,.T.)
       qgetx(nCONT+8,25,@M_TIPO     ,"!"  ,NIL,.T.)
       qgetx(nCONT+8,31,@M_TAMANHO  ,"999",NIL,.T.)
       qgetx(nCONT+8,39,@M_DECIMAIS ,"999",NIL,.T.)
       qgetx(nCONT+8,47,@M_DESCRICAO,"@!" ,NIL,.T.)
       PTCFG->(qreplacefields())
   next

   PTCFG->(qreleasefields())
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA DEFINIR A CONVERSAO __________________________________________

static function f_def_con
   local C_PONTO_01 := DF->Ponto_01
   local C_PONTO_02 := DF->Ponto_02
   local C_PONTO_03 := DF->Ponto_03
   local C_PONTO_04 := DF->Ponto_04
   local C_PONTO_05 := DF->Ponto_05
   local C_PONTO_06 := DF->Ponto_06
   local C_PONTO_07 := DF->Ponto_07
   local C_PONTO_08 := DF->Ponto_08

   // colocar aqui qlbloc()

   qsay ( 10 , 17 , C_PONTO_01    ) ; FORM->(dbseek(C_PONTO_01))
   qsay ( 10 , 45 , FORM->Descricao )
   qsay ( 11 , 17 , C_PONTO_02    ) ; FORM->(dbseek(C_PONTO_02))
   qsay ( 11 , 45 , FORM->Descricao )
   qsay ( 12 , 17 , C_PONTO_03    ) ; FORM->(dbseek(C_PONTO_03))
   qsay ( 12 , 45 , FORM->Descricao )
   qsay ( 13 , 17 , C_PONTO_04    ) ; FORM->(dbseek(C_PONTO_04))
   qsay ( 13 , 45 , FORM->Descricao )
   qsay ( 14 , 17 , C_PONTO_05    ) ; FORM->(dbseek(C_PONTO_05))
   qsay ( 14 , 45 , FORM->Descricao )
   qsay ( 15 , 17 , C_PONTO_06    ) ; FORM->(dbseek(C_PONTO_06))
   qsay ( 15 , 45 , FORM->Descricao )
   qsay ( 16 , 17 , C_PONTO_07    ) ; FORM->(dbseek(C_PONTO_07))
   qsay ( 16 , 45 , FORM->Descricao )
   qsay ( 17 , 17 , C_PONTO_08    ) ; FORM->(dbseek(C_PONTO_08))
   qsay ( 17 , 45 , FORM->Descricao )

   view_form(10,17,@C_PONTO_01) ; qsay (10,45,FORM->Descricao )
   view_form(11,17,@C_PONTO_02) ; qsay (11,45,FORM->Descricao )
   view_form(12,17,@C_PONTO_03) ; qsay (12,45,FORM->Descricao )
   view_form(13,17,@C_PONTO_04) ; qsay (13,45,FORM->Descricao )
   view_form(14,17,@C_PONTO_05) ; qsay (14,45,FORM->Descricao )
   view_form(15,17,@C_PONTO_06) ; qsay (15,45,FORM->Descricao )
   view_form(16,17,@C_PONTO_07) ; qsay (16,45,FORM->Descricao )
   view_form(17,17,@C_PONTO_08) ; qsay (17,45,FORM->Descricao )

   if qconf("Confirma grava‡„o destas f¢rmulas ?")
      if ! DF->(qrlock())
         qm2()
         return
      else
         replace DF->Ponto_01 with C_PONTO_01
         replace DF->Ponto_02 with C_PONTO_02
         replace DF->Ponto_03 with C_PONTO_03
         replace DF->Ponto_04 with C_PONTO_04
         replace DF->Ponto_05 with C_PONTO_05
         replace DF->Ponto_06 with C_PONTO_06
         replace DF->Ponto_07 with C_PONTO_07
         replace DF->Ponto_08 with C_PONTO_08
      endif
   endif

return // arquivo sera fechado quando voltar ao menu...

function f_751a ( C_FORMULA )
   FORM->(dbseek(C_FORMULA))
   if empty(C_FORMULA) ; return .F. ; endif
   if FORM->(eof()) ; return .T. ; endif
return .F.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A CAPTURA DO PONTO _____________________________________

static function f_exe_cap
   local nCONT, C_MATRICULA, C_EVENTO, C_VALOR, C_FRACAO
   local C_FIXA, C_AQUISICAO, C_TMP

   // qlbloc()

   // VERIFICA EXISTENCIA DO ARQUIVO "SH_GRUPO.TXT" _________________________

   if ! file(P_DRIVE_OU+"SH_GRUPO.TXT")
      qmensa("Arquivo <SH_GRUPO.TXT> n„o encontrado !","B")
      return
   endif

   // CRIA ARQUIVO "PONTOEXT.DBF" ___________________________________________

   f_trace("1 - Criando arquivo temporario de configura‡„o...")
   create (XDRV_SIST+"PTEXT.DBF")
   use

   if ! quse(XDRV_SIST,"PTEXT")
      return .F.
   endif

   for nCONT := 1 to 11
       PTCFG->(dbgoto(nCONT))
       if empty(PTCFG->Campo) ; exit ; endif
       append blank
       replace PONTOEXT->Field_name with PTCFG->Campo
       replace PONTOEXT->Field_type with PTCFG->Tipo
       replace PONTOEXT->Field_len  with PTCFG->Tamanho
       replace PONTOEXT->Field_dec  with PTCFG->Decimais
   next
   use

   // CRIA ARQUIVO "PONTOINT.DBF" ___________________________________________

   f_trace("2 - Criando arquivo paralelo de transferencia...")
   create (XDRV_SIST+"PTINT.CDB") from (XDRV_SIST+"PTEXT.CDB")
   use
   delete file (DRIVE_RR+"PONTOEXT.DBF")

   // FAZ APPEND FROM _______________________________________________________

   f_trace("3 - Realizando captura para arquivo paralelo...")

   if ! quse(XDRV_SIST,"PTINT")
      return .F.
   endif

   append from (P_DRIVE_OU+"SH_GRUPO.TXT") for qgirabarra() SDF

   // ALIMENTA ARQUIVO GRUPO ________________________________________________

   f_trace("4 - Transferindo arquivo paralelo para arquivo grupo...")

   PONTOINT->(dbgotop())

   do while ! PONTOINT->(eof())
      C_MATRICULA := iif(FORM->(dbseek(DF->Ponto_01)),seval(FORM->Formula),space(6))
      C_EVENTO    := iif(FORM->(dbseek(DF->Ponto_02)),seval(FORM->Formula),space(3))
      C_VALOR     := iif(FORM->(dbseek(DF->Ponto_03)),seval(FORM->Formula),0)
      C_FRACAO    := iif(FORM->(dbseek(DF->Ponto_04)),seval(FORM->Formula),0)
      C_FIXA      := iif(FORM->(dbseek(DF->Ponto_06)),seval(FORM->Formula),.F.)
      C_AQUISICAO := iif(FORM->(dbseek(DF->Ponto_07)),seval(FORM->Formula),space(7))

      if FU->(dbseek(C_MATRICULA)) .and. EV->(dbseek(C_EVENTO))
         if LANC->(dbseek(XANOMES+C_MATRICULA+C_EVENTO))
            C_TMP := LANC->(qrlock())
         else
            C_TMP := LANC->(qappend())
         endif
         if C_TMP
            replace LANC->Anomes    with XANOMES
            replace LANC->Matricula with C_MATRICULA
            replace LANC->Evento    with C_EVENTO
            replace LANC->Valor     with C_VALOR
            replace LANC->Fracao    with C_FRACAO
            replace LANC->Fixa      with C_FIXA
            replace LANC->Aquisicao with C_AQUISICAO
            LANC->(qunlock())
         endif
      endif

      PONTOINT->(dbskip())
   enddo

//   dbcloseall() // fui obrigado a fechar os arquivos aqui, pois estava
                // ocorrendo um erro 53H quando do retorno ao menu, na
                // tentativa de se abrir o arquivo QLOGON...
                // erro 53h ==> critical error - interrupt failure

   qmensa("Captura completa ! <qualquer tecla p/ voltar>...")
   qbeep() ; qinkey(0)

return

static function f_trace ( C_MENSAGEM )
   scrol_sl(08,08,18,71,1,"S")
   qsay(18,08,C_MENSAGEM)
return

