/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: FOLHA DE PAGAMENTO
// OBJETIVO...: CALCULO GERAL DA FOLHA
// ANALISTA...: CARLOS EDUARDO RABELLO NUNES
// PROGRAMADOR: O MESMO
// INICIO.....: 1994
// OBS........:
// ALTERACOES.:

// DECLARACAO DE VARIAVEIS __________________________________________________

local zTMP

parameters cAMBIENTE

private cMACROLOOP, cFORMULA, cANOMES := XANOMES

// O VETOR DE FORMULAS MANTERA AS FORMULAS EXPANDIDAS PARA CODE BLOCK
// PARA ACELERACAO DO CALCULO
// ESTRUTURA: { CODIGO_DA_FORMULA , CODE_BLOCK_CORRESPONDENTE }

private aFORMULAS := { { "$$$$" , { || 0 } } }

// AS VARIAVEIS ABAIXO SERAO UTILIZADAS PARA REALIZAR A BUSCA BINARIA

private nINICIO, nMEIO, nFINAL

// VERIFICA SE VAI ACIONAR KITS AUTOMATICAMENTE _____________________________

private cAUTO_MS := CONFIG->Auto_ms

// CALCULO SOMENTE PERMITIDO NO ULTIMO MES EM ABERTO ________________________

// if XDATASYS != CONFIG->Data_atual
//    qmensa("C lculo n„o ‚ permitido em meses anteriores !!","B")
//    return
// endif

// LOOP PARA NAO SAIR DA OPCAO ______________________________________________

do while XPROG == "401"

   qmensa("<Pressione ESC para Cancelar>")

   qlbloc(5,0,"B401A","QBLOC.GLO")

   // FAZ ESCOLHA DO TIPO DE CALCULO ________________________________________

   cMATRICULA := space(6)
   cCENTRO    := space(8)
   cFILIAL    := space(4)
   cGRUPO     := space(4)

   if empty(cAMBIENTE := rh_escolhe_amb()) ; return ; endif

   do case
      case cAMBIENTE == "MS" ; zTMP := "Mensal"
      case cAMBIENTE == "AD" ; zTMP := "Adiantamento"
      case cAMBIENTE == "FR" ; zTMP := "Ferias"
      case cAMBIENTE == "DT" ; zTMP := "Decimo-Terceiro"
      case cAMBIENTE == "PV" ; zTMP := "Provis”es"
   endcase

   qsay(11,18,zTMP)

   // ESCOLHE MATRICULA, CENTRO OU FILIAL ___________________________________

   do while .T.
      cFIM:=.T.
      view_ccusto(13,19,@cCENTRO)
      if lastkey()==27 ; cFIM:=.F. ; exit; endif
      if ! empty(cCENTRO)
         if ! CCUSTO->(dbseek(cCENTRO))
            qmensa("Centro de Custo n„o cadastrado !","B")
            loop
         endif
         if empty(right(cCENTRO,4))
            qmensa("Centro de Custo n„o Anal¡tico !!","B")
            loop
         endif
         qsay(13,19,CCUSTO->Codigo)
         qsay(13,32,CCUSTO->Descricao)
         keyboard chr(13) + chr(13)
      else
         qsay(13,32,"*** Todos os Centros ***")
      endif
      view_filia(15,25,@cFILIAL)
      if lastkey()==27 ; cFIM:=.F. ; exit; endif
      if ! empty(cFILIAL)
         if ! FILIAL->(dbseek(cFILIAL))
            qmensa("Filial n„o cadastrada !","B")
            keyboard chr(13)
            loop
         endif
         qsay(15,25,FILIAL->Codigo)
         qsay(15,32,left(FILIAL->Razao,40))
         keyboard chr(13)
      else
         qsay(15,32,"*** Todas as Filiais ***")
      endif
      view_grupoc(17,18,@cGRUPO)
      if lastkey()==27 ; cFIM:=.F. ; exit; endif
      if ! empty(cGRUPO)
         if ! GRUPOC->(dbseek(cGRUPO))
            qmensa("Grupo n„o cadastrado !","B")
            loop
         endif
         qsay(17,18,GRUPOC->Codigo)
         qsay(17,32,GRUPOC->Descricao)
      else
         qsay(17,32,"*** Todos os Grupos ***")
      endif
      exit
   enddo

   // CONFIRMACAO DO CALCULO ________________________________________________
   if ! cFIM; Return; endif
   if ! qconf("Confirma c lculo ?") ; return ; endif

   // ESTABELECE RELACIONAMENTO ENTRE ARQUIVOS _________________________________

   if XPROG == "401"
      SITUA->(dbSetFilter({|| Anomes == cANOMES},"Anomes == cANOMES"))
      FUN->(dbSetRelation("BASE"  ,{|| Matricula + cANOMES},"Matricula + cANOMES"))
      LANC->(dbSetRelation("EVENT",{|| Evento},"Evento"))
      SITUA->(dbgotop())
   else
      SITUA->(dbSetFilter({|| Anomes == cANOMES},"Anomes == cANOMES"))
   endif
   
   // ABRE INDEXADOR MAIS APROPRIADO PARA O CALCULO _________________________

   qmensa("Selecionando indexadores...")

   do case
      case ! empty(cCENTRO)
     //    FUN->(ordsetfocus(7))    // centro + matricula
     //    FUN->(dbseek(cCENTRO))
     //    SITUA->(ordsetfocus(3))  // centro + matricula
           SITUA->(dbsetorder(3))  // centro + matricula
           SITUA->(dbseek(cCENTRO))
      case ! empty(cFILIAL)
           FUN->(ordsetfocus(5))    // filial + matricula
           FUN->(dbseek(cFILIAL))
      otherwise
           FUN->(ordsetfocus(1))    // matricula
           FUN->(dbgotop())
   endcase

   // ESTABELECE MACRO PARA O LOOP __________________________________________

   do case
      case ! empty(cMATRICULA)
           cMACROLOOP := "FUN->Matricula == cMATRICULA"
      case ! empty(cCENTRO)
//         cMACROLOOP := "FUN->Centro == cCENTRO"
//         cMACROLOOP := "! FUN->(eof())"
           cMACROLOOP := "! FUN->(eof()) .and. SITUA->CCusto == cCENTRO"
      case ! empty(cFILIAL)
           cMACROLOOP := "FUN->Filial == cFILIAL"
      case ! empty(cGRUPO)
           cMACROLOOP := "GRUPOV->Codigo == cGRUPO"
           GRUPOV->(dbseek(cGRUPO))
      otherwise
           cMACROLOOP := "! FUN->(eof())"
   endcase

   // ABRE ROTINA DE CALCULO CARREGANDO TABELAS E VARIAVEIS _________________

   if ! rh_abre() ; return ; endif
   qmensa()

   clear_sl(11,07,17,72,113)
   qsay(11,07,"Calculando.:")
   qsay(13,07,"Evento.....:")
   qsay(15,07,"Funcion rios calculados:")
   qsay(17,07,"Tempo decorrido........:")

   // CHAMA FUNCAO PRINCIPAL DE CALCULO _____________________________________

   f_calculo() ; qbeep() ; qwait()

enddo

if XPROG <> "401"
   private cGRUPO := ""
   cMACROLOOP := "FUN->Matricula == cMATRICULA"
   if rh_abre()
      f_calculo()
   endif
endif

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PRINCIPAL DE CALCULO ______________________________________________

static function f_calculo

   local zTMP          // variavel temporaria de uso geral
   local nCONT         // contador de uso geral
   local aERRO := {}   // vetor com matriculas nao calculadas

   private nTOTFRA     // total de fracao do beneficio p/matricula
   private nTOTVAL     // total de valor  do beneficio p/matricula
   private nTOTN1      // total de N1 do beneficio p/matricula
   private nTOTN2      // total de N2 do beneficio p/matricula
   private M_REG_ATUAL := 1
   private M_QUANT_REG := FUN->(recc())
   private M_TEMPO     := time()
   private aEVENT_FUNC
   GRPS->(dbseek(XANOMES+FUN->Grps))

   // LOOP PRINCIPAL DA ROTINA DE CALCULO ___________________________________

   do while &cMACROLOOP.

      if ! empty(cGRUPO) ; FUN->(dbseek(GRUPOV->Matricula)) ; endif

        SITUA->(dbseek(FUN->Matricula))
//    if XPROG <> "401"
//       SITUA->(dbseek(FUN->Matricula))
//    else
//       if ! empty(cCENTRO)
//          SITUA->(dbseek(cCENTRO+FUN->Matricula))
//       else
//          SITUA->(dbseek(FUN->Matricula))
//       Endif
//    Endif
      
      // ANALIZADOR DAS CARACTERISTICAS DO FUNCIONARIO ______________________

      if FUN->(qrlock()) .and. SITUA->(qrlock())
         i_analiza()
         FUN->(qunlock())
         SITUA->(qunlock())
      endif

      // SE HOMOLOGADO VAMOS ELIMINAR LANCAMENTOS E BASES ___________________

      iif(FUN->Situacao == "H" , i_apaga_regs(),)

      // CONDICOES PARA NAO CALCULAR FUNCIONARIO ____________________________

      if FUN->Situacao == "H" .or. cAMBIENTE $ SITUA->Trav .or. FUN->Data_adm >= qfimmes(XDATASYS)
         FUN->(dbskip())
         if ! empty(cGRUPO)
            GRUPOV->(dbskip())
         endif
         loop
      endif

      if SITUA->Af_cod == "40"
         FUN->(dbskip())
         if ! empty(cGRUPO)
            GRUPOV->(dbskip())
         endif
         loop
      endif

      if FUN->Data_adm > qfimmes(XDATASYS)
         FUN->(dbskip())
         if ! empty(cGRUPO)
            GRUPOV->(dbskip())
         endif
         loop
      endif
      
      if cAMBIENTE == "FR" .and. FUN->Situacao <> "F"
         FUN->(dbskip())
         if ! empty(cGRUPO)
            GRUPOV->(dbskip())
         endif
         loop
      endif

      // SE CALCULO GLOBAL, ATUALIZA TELA ___________________________________

      if XPROG == "401"
         qsay(11,20,FUN->Matricula + " / " + left(FUN->Nome,30))
      endif

      cMATRICULA := FUN->Matricula

      if XPROG == "401"
         if inkey() == 27 ; exit ; endif   // <esc> aborta o calculo...
         if ! FUN->Situacao == "H"
            f_trace_time()
         endif
      endif
      
      // CRIA REGISTRO DE BASES CASO NECESSARIO _____________________________

      if BASE->(eof())
         if BASE->(qappend())
            replace BASE->Matricula with FUN->Matricula
            replace BASE->Anomes    with cANOMES
            BASE->(qunlock())
         endif
      endif

      FUN->(dbgoto(recno()))

      // TRAVA REGISTROS NECESSARIOS ________________________________________

      if ! FUN->(qrlock()) .or. ! SITUA->(qrlock()) .or. ! BASE->(qrlock())
         aadd(aERRO,FUN->Matricula)                // guarda matricula
         FUN->(dbskip())
         if ! empty(cGRUPO)
            GRUPOV->(dbskip())
         endif
         loop
      endif

      // VERIFICA NECESSIDADE DE UTILIZAR KITS ______________________________

      iif ( ! cAMBIENTE $ SITUA->Bloq , i_aciona_kit(cAMBIENTE) , NIL )
      qmensa()
      FUN->(dbgoto(recno()))  // reestabelece relacionamentos

      // CRIA VETOR COM EVENTOS A SEREM CALCULADOS __________________________

      LANC->(dbseek(cANOMES+FUN->Matricula+cAMBIENTE))
      aEVENT_FUNC := {}

      do while LANC->Anomes == cANOMES .and. LANC->Matricula == FUN->Matricula .and. LANC->Ambiente == cAMBIENTE
         aadd ( aEVENT_FUNC , EVENT->Ordem + str(LANC->(recno()),6) )
         LANC->(dbskip())
      enddo

      asort(aEVENT_FUNC)  // coloca na ordem correta de calculo...

      // LIMPA VARIAVEIS PUBLICAS DE BASES __________________________________

      BASE->(qinitfields("X"))

      // AGORA CALCULA NA ORDEM ESTABELECIDA ________________________________

      for nCONT := 1 to len(aEVENT_FUNC)

          LANC->(dbgoto(val(right(aEVENT_FUNC[nCONT],6))))

          if ! LANC->(qrlock())
             qmensa("Calculo incompleto, tente novamente...","B")
             exit
          endif

          if XPROG <> "401"
             qmensa(EVENT->Evento+"/"+EVENT->Descricao)
          else
             qsay(13,20,EVENT->Evento + " / " + EVENT->Descricao)
          endif

          poscu_sl(25,00)

          EVCFG->(dbseek(EVENT->Evento))

          do case

             case EVENT->Evento == "999"  // credito complemento de salario

                     LANC->(dbdelete())
                     replace SITUA->Debito with 0
                     loop

             // EVENTO DE BENEFICIO _________________________________________

             case EVENT->Tipo == "6" .and. ! LANC->Fixa

                  nTOTFRA := 0
                  nTOTVAL := 0
                  nTOTN1  := 0
                  nTOTN2  := 0
                        
                  if BENEF->(dbseek(cANOMES + LANC->Evento + "MS" + FUN->Matricula))
                     do while ! BENEF->(eof()) .and. BENEF->Anomes == cANOMES .and. BENEF->Evento == LANC->Evento .and. ;
                                                     BENEF->Ambiente == "MS" .and. BENEF->Matricula == FUN->Matricula
                        if EVENT->Evento == "207"
                           VALE->(dbSetFilter({|| Anomes == cANOMES},'Anomes == cANOMES'))
                           if VALE->(dbseek(cANOMES+strzero(BENEF->N1,2)))
                              nTOTFRA += BENEF->N2
                              nTOTVAL += BENEF->N2 * VALE->Valor
                           endif
                        else
                           if EVENT->Evento == "635"
                              FILIAL->(dbseek(FUN->Filial))
                           else
                              nTOTFRA += BENEF->Fracao
                              nTOTVAL += BENEF->Valor
                              nTOTN1  += BENEF->N1
                              nTOTN2  += BENEF->N2
                           endif
                        endif

                        if empty(EVENT->Formula)
                           replace LANC->Fracao with nTOTFRA
                           replace LANC->Valor  with nTOTVAL
                        endif

                        BENEF->(dbskip())
                     enddo

                     BENEF->(dbseek(cANOMES + LANC->Evento + "MS" + FUN->Matricula))

                     cFORMULA := EVENT->Formula
                     zTMP := errorblock ( { |e| error_in_calc(e) } )
                     begin sequence
                        // busca binaria atualiza variavel nMEIO
                        busca_binaria()
                        if ! empty(EVENT->Formula)
                           replace LANC->Valor with eval(aFORMULAS[nMEIO,2])
                        endif
                     recover
                        replace LANC->Valor with 0
                        aFORMULAS[nMEIO] := { cFORMULA , { || 0 } }
                     end sequence
                     errorblock ( zTMP )
                  else
                     replace LANC->Fracao with 0
                     replace LANC->Valor  with 0
                  endif

             // FORMULA ASSOCIADA ___________________________________________

             case ! empty(EVENT->Formula) .and. ! LANC->Fixa

                  cFORMULA := EVENT->Formula
                  zTMP := errorblock ( { |e| error_in_calc(e) } )
                  begin sequence
                     // busca binaria atualiza variavel nMEIO
                     busca_binaria()
                     replace LANC->Valor with eval(aFORMULAS[nMEIO,2])
                  recover
                     replace LANC->Valor with 0
                     aFORMULAS[nMEIO] := { cFORMULA , { || 0 } }
                  end sequence
                  errorblock ( zTMP )

             // VALOR CONSTANTE _____________________________________________

             case EVENT->Tipo == "2" .and. ! LANC->Fixa
                  replace LANC->Valor with EVENT->Valor

             // PERCENTUAL SOBRE COMBINACAO _________________________________

             case EVENT->Tipo == "5" .and. ! LANC->Fixa
                  zTMP := jcombeve()
                  if LANC->(qrlock())
                     replace LANC->Fracao with EVENT->Valor
                     replace LANC->Valor  with EVENT->Valor / 100 * zTMP
                  endif

          endcase

          i_salva_bases()  // atualizacao efetiva das bases

      next

      // FINALIZA CALCULO ___________________________________________________

      i_finaliza_calc()

      if empty(cGRUPO)
         FUN->(dbskip())
      else
         GRUPOV->(dbskip())
      endif

   enddo

   // FECHAMENTO DAS VARIAVEIS PUBLICAS DO CALCULO DA FOLHA _________________

   i_kill_vars()
   dbunlockall()

return NIL

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR BUSCA BINARIA NO VETOR DE FORMULAS __________________

function busca_binaria
   nINICIO := 1
   nFINAL  := len(aFORMULAS)

   do while .T.

      nMEIO := int ( ( nINICIO + nFINAL ) / 2 )

      do case
         case aFORMULAS[nMEIO,1] == cFORMULA ; exit
         case aFORMULAS[nMEIO,1]  < cFORMULA ; nINICIO := nMEIO + 1
         otherwise                           ; nFINAL  := nMEIO - 1
      endcase

      if nFINAL < nINICIO
         nMEIO := int ( ( nINICIO + nFINAL ) / 2 ) + 1
         aadd(aFORMULAS,NIL)
         ains(aFORMULAS,nMEIO)
         if FORM->(dbseek(cFORMULA))
            aFORMULAS[nMEIO] := { cFORMULA , &(rh_expan(FORM->Formula,FORM->Parameter)) }
         else
            aFORMULAS[nMEIO] := { cFORMULA , { || 0 } }
         endif
         exit
      endif

   enddo

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO DE CONTROLE DE ERROS QUANDO OCORRIDOS DENTRO DE FORMULAS __________

function error_in_calc ( C_ERRO )
   local C_MENSAGEM := "ERRO NA FORMULA: "
   if C_ERRO:gencode == 5 ; return 0 ; endif  // gencode=5 e' divisao por zero!
   FORM->(dbseek(cFORMULA))
   C_MENSAGEM += cFORMULA + " - " + alltrim(FORM->Descricao)
   C_MENSAGEM += ";" + C_ERRO:description()
   C_MENSAGEM += " - " + C_ERRO:operation()
   C_MENSAGEM += ";;(o evento correspondente nao ser  calculado!)"
   alert(C_MENSAGEM,{"OK"})
   break
return

// FUNCAO PARA FAZER ACOMPANHAMENTO DO TEMPO DE CALCULO _____________________

static function f_trace_time
   C_DECORRIDO := qdifhora(M_TEMPO,time())

   qsay(15,35,M_REG_ATUAL++,"99999")
   qsay(17,32,C_DECORRIDO          )
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ABRIR ROTINA DE CALCULO ______________________________________

static function rh_abre

qmensa("Inicializando rotina de calculo...5")

// VARIAVEIS PARA INCREMENTO DAS BASES DE CALCULO ___________________________

i_init_vars()

// CARGA DA TABELA GERAL ____________________________________________________

qmensa("Inicializando rotina de calculo...4")
if ! quse(XDRV_RHX,"TBGR",{"TBGR"},"R") ; return .F. ; endif
if ! TBGR->(dbseek(cANOMES))
   qmensa("Tabela Geral incompleta para esta data !","B")
   return .F.
endif
TBGR->(qpublicfields("X")) ; TBGR->(qcopyfields("X")) ; TBGR->(dbclosearea())

// CARGA DA TABELA DO INSS DO EMPREGADO _____________________________________

qmensa("Inicializando rotina de calculo...3")
if ! quse(XDRV_RHX,"TBIF",{"TBIF"},"R") ; return .F. ; endif
if ! TBIF->(dbseek(cANOMES))
   qmensa("Tabela de Inss incompleta para esta data !","B")
   return .F.
endif
TBIF->(qpublicfields("X")) ; TBIF->(qcopyfields("X")) ; TBIF->(dbclosearea())

// CARGA DA TABELA DO IMPOSTO DE RENDA RETIDO NA FONTE ______________________

qmensa("Inicializando rotina de calculo...2")
if ! quse(XDRV_RHX,"TBIR",{"TBIR"},"R") ; return .F. ; endif
if ! TBIR->(dbseek(cANOMES))
   qmensa("Tabela de Irrf incompleta para esta data !","B")
   return .T.
endif
TBIR->(qpublicfields("X")) ; TBIR->(qcopyfields("X")) ; TBIR->(dbclosearea())

// CARGA DA TABELA DO SALARIO FAMILIA _______________________________________

qmensa("Inicializando rotina de calculo...1")
if ! quse(XDRV_RHX,"TBSF",{"TBSF"},"R") ; return .F. ; endif
if ! TBSF->(dbseek(cANOMES))
   qmensa("Tabela de Sal.Familia incompleta para esta data !","B")
   return .F.
endif
TBSF->(qpublicfields("X")) ; TBSF->(qcopyfields("X")) ; TBSF->(dbclosearea())

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR AS VARIAVEIS PUBLICAS UTILIZADAS NO CALCULO ______

static function i_init_vars

   public XPROV := 0
   public XDESC := 0

   BASE->(qpublicfields("X"))
   BASE->(qinitfields("X"))

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FECHAR ROTINA DE CALCULO _____________________________________

static function i_kill_vars

   BASE->(qreleasefields("X"))

   public XANOMES := qanomes(XDATASYS)

   release XPROV, XDESC
   release all like XIF_LIM*
   release all like XIF_ALI*
   release all like XIR_LIM*
   release all like XIR_DED*
   release all like XIR_ALI*
   release all like XGR_*
return NIL

/////////////////////////////////////////////////////////////////////////////
// ROTINA QUE LIMPA AS VARIAVEIS DE ACUMULO DAS BASES NA QUEBRA DE FUNC. ____

static function i_finaliza_calc

   local nVALOR, nLIQUIDO, cMACROP, cMACROD, cMACROL, nSALFAM
   local nREG := 0

   // SALVA PROVENTO / DESCONTO NO AMBIENTE APROPRIADO ______________________

   cMACROP := "BASE->PROV_" + cAMBIENTE
   cMACROD := "BASE->DESC_" + cAMBIENTE
   cMACROL := "SITUA->LIQ_" + cAMBIENTE

   replace &cMACROP. with XPROV
   replace &cMACROD. with XDESC
   replace &cMACROL. with XPROV - XDESC
   nSALFAM := BASE->V_salfam


   // VERIFICA SE HA CREDITO COMPLEMENTO DE SALARIO _________________________

   // PROCEDIMENTO PARA FUNCIONARIOS DEVEDORES, ONDE SERA CRIADO O EVENTO 999
   // (CREDITO COMPLEMENTO DE SALARIO), E TERA SEU LIQUIDO REDUZIDO A ZERO.
   // CONSIDERA TAMBEM SALARIO FAMILIA QUE DEVERA SER PAGO CASO MES NORMAL !

   nLIQUIDO := XPROV - XDESC

   // VERIFICA SE DEMITIDO NO MES. CASO SIM, DESCONSIDERA SAL. FAMILIA PARA
   // LIQUIDO DE RESCISAO

   //if month(SITUA->Af_ini) == month(XDATASYS) .and. year(SITUA->Af_ini) == year(XDATASYS)
   //   nSALFAM := 0
   //else
   //endif



   if nLIQUIDO < 0
      if LANC->(qappend())
         replace LANC->Anomes    with cANOMES
         replace LANC->Matricula with FUN->Matricula
         replace LANC->Ambiente  with cAMBIENTE
         replace LANC->Evento    with "999"
         replace LANC->Valor     with (nLIQUIDO * (-1)) + nSALFAM
      endif

      XPROV := XDESC + nSALFAM

      if BASE->(qrlock())
         replace &cMACROP. with XPROV
      endif

      replace SITUA->Debito with LANC->Valor
   endif

   BASE->(qinitfields())

   XPROV := XDESC := 0

   FUN->(dbgoto(recno()))

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO QUE INCREMENTA AS BASES DE CALCULO PARA TODAS AS FUNCOES __________

function i_salva_bases
   local nVALOR := LANC->Valor                  // Valor do Evento

   do case
      case EVENT->Finalidade == "P"             // Proventos
           XPROV += nVALOR
      case EVENT->Finalidade == "D"             // Descontos
           XDESC += nVALOR
           nVALOR := nVALOR * (-1)
      case EVENT->Finalidade == "-"             // Dedutor da Base
           nVALOR := nVALOR * (-1)
//    case EVENT->Finalidade == "+"             // Incrementa Base
//         nVALOR := nVALOR                     // (na verdade nao faz nada!)
   endcase                                      // manter p/ documentacao...

   // ATUALIZACAO EFETIVA DAS BASES AMBIENTE MENSAL ____________________________

   iif ( EVENT->inssms == "S" , XB_INSSMS += nVALOR  , NIL )
   iif ( EVENT->irrfms == "S" , XB_IRRFMS += nVALOR  , NIL )
   iif ( EVENT->fgtsms == "S" , XB_FGTSMS += nVALOR  , NIL )
   iif ( EVENT->salfam == "S" , XB_SALFAM += nVALOR  , NIL )
   iif ( EVENT->fgtsms == "S" , XB_SFIPMS += nVALOR  , NIL )

   // ATUALIZACAO EFETIVA DAS BASES AMBIENTE FERIAS ____________________________

   iif ( EVENT->inssfr == "S" , XB_INSSFR += nVALOR  , NIL )
   iif ( EVENT->irrffr == "S" , XB_IRRFFR += nVALOR  , NIL )
   iif ( EVENT->fgtsfr == "S" , XB_FGTSFR += nVALOR  , NIL )

   // ATUALIZACAO EFETIVA DAS BASES AMBIENTE 13 SALARIO ________________________

   iif ( EVENT->inssms == "S" , XB_INSSDT += nVALOR  , NIL )
   iif ( EVENT->irrfms == "S" , XB_IRRFDT += nVALOR  , NIL )
   iif ( EVENT->fgtsms == "S" , XB_FGTSDT += nVALOR  , NIL )
   iif ( EVENT->fgtsms == "S" , XB_SFIPDT += nVALOR  , NIL )

return NIL

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INCLUIR/EXCLUIR KITS _________________________________________

static function i_aciona_kit ( cAMB )
   local aEVENTOS, nCONT

   if cAMB == "MS" .and. cAUTO_MS <> "S" ; return ; endif

   qmensa("Incluindo kit...")
   aEVENTOS := rh_ret_kit("KIT_I_"+cAMB)
   for nCONT := 1 to len(aEVENTOS)
       if ! LANC->(dbseek(cANOMES+FUN->Matricula+cAMBIENTE+aEVENTOS[nCONT]))
          if EVENT->(dbseek(aEVENTOS[nCONT]))
             if LANC->(qappend())
                replace LANC->Anomes    with cANOMES
                replace LANC->Matricula with FUN->Matricula
                replace LANC->Ambiente  with cAMBIENTE
                replace LANC->Evento    with aEVENTOS[nCONT]
                LANC->(qunlock())
             endif
          endif
       endif
   next
   qmensa("Excluindo kit...")
   aEVENTOS := rh_ret_kit("KIT_E_"+cAMB)
   for nCONT := 1 to len(aEVENTOS)
       if LANC->(dbseek(cANOMES+FUN->Matricula+cAMBIENTE+aEVENTOS[nCONT]))
          if LANC->(qrlock())
             LANC->(dbdelete())
             LANC->(qunlock())
          endif
       endif
   next
return

/////////////////////////////////////////////////////////////////////////////
// ANALIZADOR DAS CARACTERISTICAS DIVERSAS DO FUNCIONARIO ___________________

static function i_analiza
   local zTMP, cPERANT, nMES, nANO, lTRAVA, aFIXO := {}, aEVENTOS

   // SE VALE-TRANS == "S" NO FUN.DBF ENTAO COLOCA "207" NO BENEF.DBF _______

   if FUN->Vale_trans == "S" .and. FUN->Situacao == "T"
      BENEF->(dbsetorder(2))
      if ! BENEF->(dbseek(cANOMES + FUN->Matricula + cAMBIENTE + "207"))
         if BENEF->(qappend())
            replace BENEF->Matricula with FUN->Matricula
            replace BENEF->Ambiente  with cAMBIENTE
            replace BENEF->Evento    with "207"
            BENEF->(qunlock())
         endif
      endif
      BENEF->(dbsetorder(1))
   endif

   // CRIA REGISTRO PARA NOVO MES NO ARQUIVO BASE SE NAO HOMOLOGADO _________

   if ! FUN->Situacao == "H"
      if ! BASE->(dbseek(FUN->Matricula + CANOMES))
         if BASE->(qappend())
            replace BASE->Matricula with FUN->Matricula
            replace BASE->Anomes    with CANOMES
            BASE->(qunlock())
         endif
      endif
   endif

   // VERIFICA EXISTENCIA DE EVENTO PERMANENTE E, CASO POSITIVO, INCLUI OU ALTERA

   if FUN->Situacao == "T" .or. (FUN->Situacao == "F" .and. cAMBIENTE == "MS")
      LANC->(dbseek("FIXO  "+FUN->Matricula))

      do while LANC->Anomes == "FIXO  " .and. LANC->Matricula == FUN->Matricula

         if EVENT->(dbseek(LANC->Evento))
            aadd(aFIXO,{LANC->Evento,LANC->Valor,LANC->Fracao})
         endif

         LANC->(dbskip())

      enddo

      for zTMP := 1 to len(aFIXO)
          if LANC->(dbseek(cANOMES+FUN->Matricula+"MS"+aFIXO[zTMP,1]))
             if ! LANC->Fixa .and. LANC->(qrlock())
                replace LANC->Valor  with aFIXO[zTMP,2]
                replace LANC->Fracao with aFIXO[zTMP,3]
                LANC->(qunlock())
             endif
          else
             if LANC->(qappend())
                replace LANC->Anomes    with cANOMES
                replace LANC->Matricula with FUN->Matricula
                replace LANC->Ambiente  with "MS"
                replace LANC->Evento    with aFIXO[zTMP,1]
                replace LANC->Valor     with aFIXO[zTMP,2]
                replace LANC->Fracao    with aFIXO[zTMP,3]
                LANC->(qunlock())
             endif
          endif
      next
   endif
      
   // INCLUI EVENTOS DO BENEF.DBF NO LANC.DBF _______________________________

   if FUN->Situacao $ "DT" .or. (FUN->Situacao == "F" .and. cAMBIENTE == "MS")
      BENEF->(dbsetorder(2))    //  anomes + matricula + ambiente + evento

      if BENEF->(dbseek(cANOMES + FUN->Matricula + "MS"))
         do while ! BENEF->(eof()) .and. BENEF->Matricula == FUN->Matricula .and. BENEF->Ambiente == "MS"
            if ! LANC->(dbseek(cANOMES+FUN->Matricula+"MS"+BENEF->Evento))
               if LANC->(qappend())
                  replace LANC->Anomes    with cANOMES
                  replace LANC->Matricula with BENEF->Matricula
                  replace LANC->Ambiente  with "MS"
                  replace LANC->Evento    with BENEF->Evento
               endif
            endif

            LANC->(qunlock())

            BENEF->(dbskip())
         enddo
      endif

      BENEF->(dbsetorder(1))    // evento + ambiente + matricula
   endif

   // SE ADIANTAMENTO DE SALARIO (701) LANCA AUTOMATICAMENTE O DESCONTO (201)

   if cAMBIENTE == "MS" .and. LANC->(dbseek(cANOMES+FUN->Matricula+"AD701")) ;
                      .and. ! LANC->(dbseek(cANOMES+FUN->Matricula+"MS201"))
      if LANC->(qappend())
         replace LANC->Anomes    with cANOMES
         replace LANC->Matricula with FUN->Matricula
         replace LANC->Ambiente  with "MS"
         replace LANC->Evento    with "201"
      endif
      LANC->(qunlock())
   endif

   // VERIFICA NECESSIDADE DE SALDO DE SALARIOS DE FERIAS ___________________

   if FUN->Situacao == "F" .and. cAMBIENTE == "MS" ;
                           .and. ! LANC->(dbseek(cANOMES+FUN->Matricula+"MS101"))
      if LANC->(qappend())
         replace LANC->Anomes    with cANOMES
         replace LANC->Matricula with FUN->Matricula
         replace LANC->Ambiente  with "MS"
         replace LANC->Evento    with "101"
      endif
      LANC->(qunlock())
   endif

   // LIMPA BASES ANTES DE CADA CALCULO _____________________________________

   if BASE->Matricula == FUN->Matricula .and. BASE->(qrlock()) .and. ! cAMBIENTE $ SITUA->Trav
      select BASE
      do case
         case cAMBIENTE == "AD"
              replace Prov_ad  with 0, Desc_ad  with 0
         case cAMBIENTE == "MS"
              replace T_inssms with 0, B_inssms with 0, V_inssms with 0, P_inssms with 0
              replace B_fgtsms with 0, V_fgtsms with 0, P_fgtsms with 0
              replace B_irrfms with 0, V_irrfms with 0, P_irrfms with 0, D_irrfms with 0
              replace B_salfam with 0, V_salfam with 0
              replace Prov_ms  with 0, Desc_ms  with 0
              replace T_inssdt with 0, B_inssdt with 0, V_inssdt with 0, P_inssdt with 0
              replace B_fgtsdt with 0, V_fgtsdt with 0, P_fgtsdt with 0
              replace B_irrfdt with 0, V_irrfdt with 0, P_irrfdt with 0, D_irrfdt with 0
              replace B_sfipms with 0, B_sfipdt with 0

              if FUN->Situacao == "D"
                 replace Prov_dt with 0, Desc_dt with 0
              endif

         case cAMBIENTE == "FR"
              replace T_inssfr with 0, B_inssfr with 0, V_inssfr with 0, P_inssfr with 0
              replace B_fgtsfr with 0, V_fgtsfr with 0, P_fgtsfr with 0
              replace B_irrffr with 0, V_irrffr with 0, P_irrffr with 0, D_irrffr with 0
              replace Prov_fr  with 0, Desc_fr  with 0
         case cAMBIENTE == "DT"
              replace T_inss13 with 0, B_inss13 with 0, V_inss13 with 0, P_inss13 with 0
              replace B_fgts13 with 0, V_fgts13 with 0, P_fgts13 with 0
              replace B_irrf13 with 0, V_irrf13 with 0, P_irrf13 with 0, D_irrf13 with 0
              replace Prov_dt  with 0, Desc_dt  with 0

      endcase
   endif

   // VERIFICA SE MES ANTERIOR HOUVE "999" E LANCA "998" P/ DEBITAR _________

   nMES := val(right(cANOMES,2)) - 1
   nANO := val(left(cANOMES,4))

   if nMES == 0
      nMES := 12
      nANO--
   endif

   cPERANT := strzero(nANO,4) + strzero(nMES,2)

   if cAMBIENTE == "MS" .and. LANC->(dbseek(cPERANT+FUN->Matricula+"MS999")) ;
                        .and. ! LANC->(dbseek(cANOMES+FUN->Matricula+"MS998"))
      if LANC->(qappend())
         replace LANC->Anomes    with cANOMES
         replace LANC->Matricula with FUN->Matricula
         replace LANC->Ambiente  with "MS"
         replace LANC->Evento    with "998"
      endif
   endif

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA APAGAR LANCAMENTOS E BASES DE FUNCIONARIOS HOMOLOGADOS _______

static function i_apaga_regs

   // BASE ESTA RELACIONADO, ENTAO TRAVA E EXCLUI REGISTRO __________________

   if BASE->Matricula == FUN->Matricula .and. BASE->(qrlock())
      BASE->(dbdelete())
      BASE->(qunlock())
   endif

   // BUSCA REGISTRO NO PERIODO E MATRICULA, FAZ LOOP, TRAVA E EXCLUI... ____

   if LANC->(dbseek(cANOMES+FUN->Matricula))
      do while cANOMES==LANC->Anomes .and. FUN->Matricula==LANC->Matricula
         qgirabarra()
         if LANC->(qrlock())
            LANC->(dbdelete())
            LANC->(qunlock())
         endif
         LANC->(dbskip())
      enddo
   endif

return

