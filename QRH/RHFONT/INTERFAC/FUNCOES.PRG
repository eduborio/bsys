
/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: FOLHA DE PAGAMENTO
// OBJETIVO...: FUNCOES DIVERSAS PARA ESTE SISTEMA
// ANALISTA...: CARLOS EDUARDO RABELLO NUNES
// PROGRAMADOR: O MESMO
// INICIO.....: 1994
// OBS........:
// ALTERACOES.:

/////////////////////////////////////////////////////////////////////////////
// FUNCOES DIVERSAS UTILIZADAS NO SISTEMA DE FOLHA DE PAGAMENTO.
//
// RH_ESCOLHE_AMB       - escolha do ambiente de trabalho/calculo
// RH_RET_KIT           - montagem dos kits associados
// VIEW_????            - funcoes padronizadas para view

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHER AMBIENTE ____________________________________________

function rh_escolhe_amb
   local sBLOC  := qsbloc(5,0,15,28)
   local cOPCAO := qachoice(5,0,qlbloc("B201Z","QBLOC.GLO"),"1",1)
   cOPCAO := qabrev(cOPCAO,"1234 ",{"MS","AD","FR","DT","  "})
   qrbloc(5,0,sBLOC)
return cOPCAO

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MONTAGEM DOS KITS ASSOCIADOS _________________________________

function rh_ret_kit ( cMACRO )

   local aEVENTOS := {}

   SIND->(dbseek(FUN->Sind_cod))
   CARGO->(dbseek(SITUA->Cargo))
   CCUSTO->(dbseek(FUN->Centro))
   FILIAL->(dbseek(FUN->Filial))
   AFAST->(dbseek(SITUA->Af_cod))

   if FUN->Situacao $ "AD" .and. cMACRO == "KIT_I_MS"
      if KIT->(dbseek(AFAST->Kit))
         i_alimenta(aEVENTOS)
      endif
   endif

   if FUN->Situacao != "A"
      if ! empty(SITUA->(&cMACRO.))   .and. KIT->(dbseek(SITUA->(&cMACRO.)))
         i_alimenta(aEVENTOS) ; endif
      if ! empty(CARGO->(&cMACRO.))   .and. KIT->(dbseek(CARGO->(&cMACRO.)))
         i_alimenta(aEVENTOS) ; endif
      if ! empty(SIND->(&cMACRO.))    .and. KIT->(dbseek(SIND->(&cMACRO.)))
         i_alimenta(aEVENTOS) ; endif
      if ! empty(CCUSTO->(&cMACRO.))  .and. KIT->(dbseek(CCUSTO->(&cMACRO.)))
         i_alimenta(aEVENTOS) ; endif
      if ! empty(FILIAL->(&cMACRO.))   .and. KIT->(dbseek(FILIAL->(&cMACRO.)))
         i_alimenta(aEVENTOS) ; endif
      if ! empty(CONFIG->(&cMACRO.))  .and. KIT->(dbseek(CONFIG->(&cMACRO.)))
         i_alimenta(aEVENTOS) ; endif
   endif

return aEVENTOS

/////////////////////////////////////////////////////////////////////////////
// VIEW PADRAO PARA QINST.DBF ______________________________________________

function view_qinst (XX,YY,ZZ)
   QINST->(qview(XX,YY,@ZZ,"@!",NIL,.T.,NIL,{{"Empresa/Empresa",1},{"Razao/Raz„o Social",2}},"C",{"keyb(Empresa)",NIL,NIL,NIL}))
return

/////////////////////////////////////////////////////////////////////////////
// VIEW PADRAO PARA CFGDISQ.DBF _____________________________________________

function view_disq (XX,YY,ZZ)
   CFGDISQ->(qview(XX,YY,@ZZ,"@!",NIL,.T.,NIL,{{"Empresa/Empresa",1},{"Razao/Raz„o Social",2}},"C",{"keyb(Empresa)",NIL,NIL,NIL}))
return

/////////////////////////////////////////////////////////////////////////////
// VIEW PADRAO PARA FUNCIONARIOS ____________________________________________

function view_fun (XX,YY,ZZ)
   FUN->(dbSetFilter({|| Situacao <> "H"},'Situacao <> "H"'))
   FUN->(qview(XX,YY,@ZZ,"999999",NIL,.T.,NIL,{{"Matricula",1},{"Nome",2},{"Situacao/Situa‡„o",0}},"C",{"keyb(Matricula)",NIL,NIL,"str6"}))
   FUN->(dbclearFilter())
return

/////////////////////////////////////////////////////////////////////////////
// VIEW PADRAO PARA PLANO DE CONTAS (Q-SYS)___________________________________

function view_plan (XX,YY,ZZ)
   PLAN->(qview(XX,YY,@ZZ,"@K@R 99999-9",NIL,.T.,NIL,; // MUDEI NO DIA 14/10/97, ESTAVA ASSIM 9999-9
         {{"ct_convcod(Codigo)/C¢digo"     ,1},;
          {"Descricao/Descri‡„o"           ,2},;
          {"ct_convcod(Reduzido)/Cod.Red." ,3}},;
          "C",{"keyb(Reduzido)",NIL,NIL,NIL}))
return

/////////////////////////////////////////////////////////////////////////////
// VIEW PADRAO PARA PLANO DE CONTAS (IQ) ____________________________________

function view_pliq (XX,YY,ZZ)
// PLAN->(dbSetFilter({|| len(alltrim(Conta)) == 11},"len(alltrim(Conta)) == 11"))  // MUDEI NO DIA 14/05/97, ESTAVA ASSIM
   PLAN->(dbSetFilter({|| len(alltrim(Codigo)) == 12},"len(alltrim(Codigo)) == 12"))
   PLAN->(qview(XX,YY,@ZZ,"@R 9.99.99.99.9999-9",NIL,.T.,NIL,; // MUDEI NO DIA 14/05/97, ESTAVA ASSIM 9.99.99.99.9999
         {{"ct_convcod(Codigo)/Conta Cont bil",1},;  // ESTAVA ASSIM ct_convcod(Conta)
          {"Descricao/Descri‡„o"                  ,2}},;  // ESTAVA ASSIM Nome/
          "C",{"keyb(Codigo)",NIL,NIL,NIL}))   // ESTAVA ASSIM keyb(Conta)
   PLAN->(dbclearFilter())
return

/////////////////////////////////////////////////////////////////////////////
// VERIFICA DIGITO __________________________________________________________

function ct_dig_ok ( cCOD )
   local cNUM, cDIG
   if ! empty(cCOD)
      cCOD := strtran(cCOD," ","")
      cNUM := left(cCOD,len(cCOD)-1)
      cDIG := right(cCOD,1)
      if qdigito(cNUM) <> cDIG
         return .F.
      endif
   endif
return .T.

/////////////////////////////////////////////////////////////////////////////
// RETORNO DE STRZERO NA MATRICULA (PARA VIEW) ______________________________

function str6 ( cMATRI )
   if val(cMATRI) <> 0
      return strzero(val(cMATRI),6)
   endif
return cMATRI

/////////////////////////////////////////////////////////////////////////////
// VIEW PADRAO PARA FILIAIS _________________________________________________

function view_filia (XX,YY,ZZ)
   FILIAL->(qview(XX,YY,@ZZ,"@!",NIL,.T.,NIL,{{"left(Razao,30)/Raz„o",2},{"Codigo/C¢digo",1},{"busca_mun()/Municipio",0}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
return

/////////////////////////////////////////////////////////////////////////////
// VIEW PADRAO PARA DEPARTAMENTOS ___________________________________________

function view_dpto (XX,YY,ZZ)
   DEPART->(qview(XX,YY,@ZZ,"@!",NIL,.T.,NIL,{{"Descricao/Descri‡„o",2},{"Codigo/C¢digo",1}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
return

/////////////////////////////////////////////////////////////////////////////
// VIEW PADRAO PARA CENTRO DE CUSTO _________________________________________

function view_ccusto (XX,YY,ZZ)
   CCUSTO->(qview(XX,YY,@ZZ,"@R 99.99.9999",NIL,.T.,NIL,{{"transform(Codigo,'@R 99.99.9999')/C¢digo",1},{"Descricao/Descri‡„o",2}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
return

/////////////////////////////////////////////////////////////////////////////
// VIEW PADRAO PARA CARGO ___________________________________________________

function view_cargo (XX,YY,ZZ)
   CARGO->(qview(XX,YY,@ZZ,"@!",NIL,.T.,NIL,{{"Descricao/Descri‡„o",2},{"Codigo/C¢digo",1}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
return

/////////////////////////////////////////////////////////////////////////////
// VIEW PADRAO PARA CBO _____________________________________________________

function view_cbo (XX,YY,ZZ)
   CBO->(qview(XX,YY,@ZZ,"9.99.99" ,NIL,.T.,NIL,{{"Descricao/Descri‡„o",2},{"Codigo/C¢digo",1}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
return

/////////////////////////////////////////////////////////////////////////////
// VIEW PADRAO PARA SINDICATOS ______________________________________________

function view_sind (XX,YY,ZZ)
   SIND->(qview(XX,YY,@ZZ,"@!",NIL,.T.,NIL,{{"Descricao/Descri‡„o",2},{"Codigo/C¢digo",1}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
return

/////////////////////////////////////////////////////////////////////////////
// VIEW PADRAO PARA EVENTOS _________________________________________________

function view_event (XX,YY,ZZ)
   EVENT->(qview(XX,YY,@ZZ,"999",NIL,.T.,NIL,{{"Descricao/Descri‡„o",2},{"Evento/Cod.Evento",1}},"C",{"keyb(Evento)",NIL,NIL,NIL}))
return

/////////////////////////////////////////////////////////////////////////////
// VIEW PADRAO PARA KITS ____________________________________________________

function view_kit (XX,YY,ZZ)
   KIT->(qview(XX,YY,@ZZ,"@!",NIL,.T.,NIL,{{"Descricao/Descri‡„o",2},{"Codigo/C¢digo",1}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
return


/////////////////////////////////////////////////////////////////////////////
// VIEW PADRAO PARA GUIAS DE GRPS ___________________________________________

function view_grps (XX,YY,ZZ)
   GRPS->(dbSetFilter({|| Anomes == XANOMES}, 'Anomes == XANOMES'))
   GRPS->(qview(XX,YY,@ZZ,"@!",NIL,.T.,NIL,{{"Descricao/Descri‡„o",2},{"Codigo/C¢digo",1}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
   GRPS->(dbclearFilter())
return

/////////////////////////////////////////////////////////////////////////////
// VIEW PADRAO PARA CGM _____________________________________________________

function view_cgm (XX,YY,ZZ)
   CGM->(qview(XX,YY,@ZZ,"@!",NIL,.T.,NIL,{{"Municipio",2},{"Codigo/C¢digo",1},{"Estado",0}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
return

/////////////////////////////////////////////////////////////////////////////
// VIEW PADRAO PARA BANCOS __________________________________________________

function view_banco (XX,YY,ZZ)
   BANCO->(qview(XX,YY,@ZZ,"@!",NIL,.T.,NIL,{{"ibancoagencia()/Descri‡„o",2},{"Banco/C¢d.Banco",1}},"C",{"keyb(Banco+Agencia)",NIL,NIL,NIL}))
return

function ibancoagencia
return BANCO->Descricao+"/"+BANCO->Agencia

/////////////////////////////////////////////////////////////////////////////
// VIEW PADRAO PARA FORMULAS ________________________________________________

function view_form (XX,YY,ZZ)
   FORM->(qview(XX,YY,@ZZ,"@!",NIL,.T.,NIL,{{"Descricao/Descri‡„o",2},{"Codigo/C¢digo",1}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
return

/////////////////////////////////////////////////////////////////////////////
// VIEW PADRAO PARA GRUPOC __________________________________________________

function view_grupoc (XX,YY,ZZ)
   GRUPOC->(qview(XX,YY,@ZZ,"9999",NIL,.T.,NIL,{{"Descricao/Descri‡„o",2},{"Codigo/C¢digo",1}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
return

/////////////////////////////////////////////////////////////////////////////
// VIEW PADRAO PARA AFAST ___________________________________________________

function view_afast (XX,YY,ZZ)
   AFAST->(qview(XX,YY,@ZZ,"!!",NIL,.T.,NIL,{{"Descricao/Descri‡„o",2},{"Codigo/C¢digo",1}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
return

/////////////////////////////////////////////////////////////////////////////
// VIEW PADRAO PARA C.N.A.E. ________________________________________________

function view_cnae (XX,YY,ZZ)
   CNAE->(qview(XX,YY,@ZZ,"9999-9",NIL,.T.,NIL,{{"left(Descricao,65)/Descri‡„o",2},{"Codigo/C¢digo",1}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA BUSCAR MUNICIPIO NO CGM ______________________________________

function busca_mun
    CGM->(dbseek(FILIAL->Cgm))
return(CGM->Municipio)

/////////////////////////////////////////////////////////////////////////////
// ABRE ARQUIVO ART_SALD DA CONTABILIDADE DA IQ _____________________________

function fu_abre_plan
   if ! quse(XPATHCONTA,"ART_SALD",{"ART_CONT","ART_CONO"},"R","PLAN")
      qmensa("N„o foi possivel abrir ART_SALD.DBF !","B")
      return .F.
   endif
return .T.

/////////////////////////////////////////////////////////////////////////////
// ABRE ARQUIVO ART_PROF (INTERFACE DA FOLHA) DA IQ _________________________

function fu_abre_share
   if ! quse(XPATHSHARE,"ART_PROF")
      qmensa("N„o foi possivel abrir ART_PROF !","B")
      return .F.
   endif
return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA SOLICITACAO DE ANO MES _______________________________________

function f141x
return qnomemes(val(right(Anomes,2)))

function f141y
   qmensa("Informe o ano e mes da tabela no formato AAMM...")
   qgetx(24,60,@fANOMES,"9999")
return

/////////////////////////////////////////////////////////////////////////////
// CONVERTE CODIGOS DE CONTA E REDUZIDO _____________________________________

function ct_convcod ( cCOD )
   cCOD := transform(cCOD,"@R 9.99.99.99.9999-9") // MUDEI NO DIA 14/05/97, ESTAVA ASSIM 9.99.99.99.9999
return cCOD

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA DUPLICACAO DE REGISTRO DE TABELAS ____________________________

function i_dup_tab
   local nMES := (alias())->(val(right(Anomes,2)))
   local nANO := (alias())->(val(left(Anomes,2)))

   if ! qconf("Confirma duplicar esta tabela p/ o proximo mˆs ?")
      return
   endif

   (alias())->(qpublicfields())
   (alias())->(qcopyfields())

   if ! (alias())->(qappend())
      qmensa("N„o foi possivel duplicar, tente novamente...","B")
   else
      nMES++
      if nMES > 12
         nMES := 1
         nANO++
      endif
      fANOMES := strzero(nANO,2) + strzero(nMES,2)
      (alias())->(qreplacefields())
   endif
   (alias())->(qreleasefields())
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA RETORNAR FAIXA DE DATAS DA ULTIMA SEMANA DO MES ______________

function rh_ultsemana
   local cPRIMDIA := XDATASYS
   do while dow(cPRIMDIA) != 1 .and. dow(cPRIMDIA) != 7
      if dow(cPRIMDIA) = 1
         exit
      endif
      cPRIMDIA--
   enddo
return cPRIMDIA

/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////
//  FUNCOES DISPONIVEIS PARA USO FUTURO


/////////////////////////////////////////////////////////////////////////////
// FUNCAO RECURSIVA PARA FAZER AFILL EM VETORES MULTI-DIMENSIONAIS __________

function qafill ( C_VETOR , C_CONTEUDO )
   local nCONT := 1
   aeval ( C_VETOR , { |elem| iif(valtype(C_VETOR[nCONT])="A",;
         qafill(C_VETOR[nCONT],C_CONTEUDO),;
         C_VETOR[nCONT]:=C_CONTEUDO), nCONT++ } )
return NIL

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAR OS ARQUIVOS SENDO ABERTOS ____________________________

function trace_open
   qmensa("abrindo arquivos, aguarde... "+str(P_NIVEL_255--,2))
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXPANDIR/CONVERTER FORMULAS __________________________________

function rh_expan ( cFORMULA , cPARAMET )
   local nCONT, C_1, C_2

   iif(cPARAMET==NIL,cPARAMET:="",NIL)

   // PRIMEIRO ELIMINA TODOS OS CARACTERES DE FORMATACAO MEMOEDIT ___________

   cFORMULA := strtran(cFORMULA,chr(010),"")
   cFORMULA := strtran(cFORMULA,chr(013),"")
   cFORMULA := strtran(cFORMULA,chr(141),"")
   cFORMULA := alltrim(cFORMULA)

   // AGORA RETIRA OS COMENTARIOS INSERIDOS ENTRE "#" _______________________

   do while "#" $ cFORMULA
      // C_1 == posicao da primeira ocorrencia do "#"
      // C_2 == posicao da segunda ocorrencia do "#"
      C_1 := at("#",cFORMULA)
      C_2 := at("#",substr(cFORMULA,C_1+1)) + C_1
      // retira o primeiro comentario encontrado
      cFORMULA := left(cFORMULA,C_1-1) + substr(cFORMULA,C_2+1)
   enddo

   // AGORA REFORMATA PARA CODE BLOCK COM OS PARAMETROS _____________________

   cFORMULA := "{|" + alltrim(cPARAMET) + "|" + cFORMULA + "}"

return cFORMULA

/////////////////////////////////////////////////////////////////////////////
// EVAL DE CODE BLOCK COM EXPANSAO DE MACRO AUTOMATICAMENTE _________________

function seval
   parameters cFORMULA
   cFORMULA := &(rh_expan(cFORMULA))
return eval(cFORMULA)

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DE CAMPOS ____________________________________________

/*
function qescfild ( C_ARQUIVO )

   local C_PATH, C_DBF, nCONT, C_POINTER, C_TELA
   local C_RETORNO := ""
   local C_ALIAS   := alias()
   local C_CURSOR  := setcursor(0)
   local C_COLOR   := setcolor("W+/B")

   private V_CAMPOS := {} // vetor com os campos

   C_ARQUIVO := alltrim(upper(C_ARQUIVO))

   // CASO TENHA SIDO PASSADO RETIRA O ".DBF" _______________________________

   if right(C_ARQUIVO,4) == ".DBF"
      C_ARQUIVO := left(C_ARQUIVO,len(C_ARQUIVO)-4)
   endif

   // SEPARA "C_PATH" E "C_DBF" _____________________________________________

   C_POINTER := rat("\",C_ARQUIVO)
   if C_POINTER == 0 ; return "" ; endif
   C_PATH := substr(C_ARQUIVO,1,C_POINTER)
   C_DBF  := padr(substr(C_ARQUIVO,C_POINTER+1),8)

   if file(C_PATH+"QSTRUCT.DBF")
      f_via_layout(C_PATH,C_DBF)
   else
      f_via_arqdbf(C_PATH,C_DBF)
   endif

   if ! empty(V_CAMPOS)
      C_TELA := copac_sl(savev_sl())
      @ 10,05 clear to 19,75
      @ 10,05 to 19,75
      //qshadow(10,05,19,75,7)
      asort(V_CAMPOS)
      C_POINTER := achoice(11,06,18,74,V_CAMPOS,.T.)
      if C_POINTER != 0
         C_RETORNO := alltrim(left(V_CAMPOS[C_POINTER],10))
      endif
   endif

   r_estv_sl(depac_sl(C_TELA))
   dbselectar(C_ALIAS)
   setcursor(C_CURSOR)
   setcolor(C_COLOR)

return C_RETORNO
*/

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ATUALIZAR VETOR VIA QSTRUCT _________________________________

static function f_via_layout ( C_PATH , C_DBF )
   local nCONT

   if ! quse(C_PATH,"IQLAYOUT")
      return
   endif

   locate for C_DBF $ Arquivo

   if eof()
      return
   endif

   do while ! eof() .and. C_DBF == Arquivo
      aadd(V_CAMPOS,Campo+" - "+Tipo+" - "+str(Tamanho,4)+" - "+str(Decimal,2)+" - "+;
             iif(empty(Descricao),"descri‡„o n„o disponivel..."+space(13),Descricao) )
      skip
   enddo
   use

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ATUALIZAR VETOR VIA ARQUIVO DBF ______________________________

static function f_via_arqdbf ( C_PATH , C_DBF )
   local V_ESTRU, nCONT

   if ! quse(C_PATH,C_DBF)
      return
   endif

   V_ESTRU := dbstruct()
   use

   for nCONT := 1 to len(V_ESTRU)
       aadd(V_CAMPOS,padr(V_ESTRU[nCONT,1],10)+" - "+;
                     V_ESTRU[nCONT,2]+" - "+;
                     str(V_ESTRU[nCONT,3],4)+" - "+;
                     str(V_ESTRU[nCONT,4],2)+" - "+;
                     "descri‡„o n„o disponivel..."+space(13) )
   next

return

/////////////////////////////////////////////////////////
//                                                     //
// FUNCOES COMPLEMENTARES DA ROTINA DE CALCULO (RH401) //
//                                                     //
/////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ARQUIVOS NECESSARIOS PARA O CALCULO __________________________

function f_abre_para_calc ( C_UNICO )

   // ABRE KIT ______________________________________________________________

   if ! ("KIT")->(used())
      iif(C_UNICO,NIL,trace_open())
      if ! quse(XDRV_RHX,"KIT") ; return .F. ; endif
   endif

   // ABRE ATIV _____________________________________________________________

   if ! ("ATIV")->(used())
      iif(C_UNICO,NIL,trace_open())
      if ! quse(XDRV_RHX,"ATIV") ; return .F. ; endif
   endif

   // ABRE CBO ______________________________________________________________

   if ! ("CBO")->(used())
      iif(C_UNICO,NIL,trace_open())
      if ! quse(XDRV_RHX,"CBO") ; return .F. ; endif
   endif

   // ABRE SIND _____________________________________________________________

   if ! ("SIND")->(used())
      iif(C_UNICO,NIL,trace_open())
      if ! quse(XDRV_RHX,"SIND") ; return .F. ; endif
   endif

   // ABRE CARGO ____________________________________________________________

   if ! ("CARGO")->(used())
      iif(C_UNICO,NIL,trace_open())
      if ! quse(XDRV_RHX,"CARGO") ; return .F. ; endif
   endif

   // ABRE CCUSTO ___________________________________________________________

   if ! ("CCUSTO")->(used())
      iif(C_UNICO,NIL,trace_open())
      if ! quse(XDRV_CONT,"CCUSTO") ; return .F. ; endif
   endif

   // ABRE LOCAL ____________________________________________________________

   if ! ("LOCAL")->(used())
      iif(C_UNICO,NIL,trace_open())
      if ! quse(XDRV_ATIV,"LOCAL") ; return .F. ; endif
   endif

   // ABRE HORA _____________________________________________________________

   if ! ("HORA")->(used())
      iif(C_UNICO,NIL,trace_open())
      if ! quse(XDRV_RHX,"HORA") ; return .F. ; endif
   endif

   // ABRE ARQUIVO TB_GERAL _________________________________________________

   if ! ("TB_GERAL")->(used())
      iif(C_UNICO,NIL,trace_open())
      if ! quse(XDRV_RHX,"TB_GERAL") ; return .F. ; endif
   endif

   // ABRE ARQUIVO TB_IAPA1 _________________________________________________

   if ! ("TB_IAPA1")->(used())
      iif(C_UNICO,NIL,trace_open())
      if ! quse(XDRV_RHX,"TB_IAPA1") ; return .F. ; endif
   endif

   // ABRE ARQUIVO TB_IRRF __________________________________________________

   if ! ("TB_IRRF")->(used())
      iif(C_UNICO,NIL,trace_open())
      if ! quse(XDRV_RHX,"TB_IRRF") ; return .F. ; endif
   endif

   // ABRE ARQUIVO TB_SAFAM _________________________________________________

   if ! ("TB_SAFAM")->(used())
      iif(C_UNICO,NIL,trace_open())
      if ! quse(XDRV_RHX,"TB_SAFAM") ; return .F. ; endif
   endif

return

// FUNCAO PARA ADICIONAR OS EVENTOS DOS KITS NO VETOR PRINCIPAL _____________

function i_alimenta ( aEVENTOS )
   local nCONT, cEVENTO, nTAMANHO := len(KIT->Eventos)
   for nCONT := 1 to nTAMANHO step 3
       cEVENTO := substr(KIT->Eventos,nCONT,3)
       if val(cEVENTO) == 0 ; exit ; endif
       aadd(aEVENTOS,cEVENTO)
   next
return

