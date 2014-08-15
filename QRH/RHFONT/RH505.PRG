/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: FOLHA DE PAGAMENTO
// OBJETIVO...: FICHA CADASTRAL
// ANALISTA...: LUCINEIDE VILAR POSSEBOM
// PROGRAMADOR: LUCIANO DA SILVA GORSKI
// INICIO.....: AGOSTO DE 1998
// OBS........:
// ALTERACOES.:

#define K_MAX_LIN 52

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local bESCAPE := {||(XNIVEL==1 .and. !XFLAG) .or. empty(cORDEM)}

private sBLOCO1 := qlbloc("B505B","QBLOC.GLO") // ordem de impressao

private cTIPOREL         // tipo de relatorio (mensal ou 13o.)
private cORDEM           // ordem de impressao
private cINCSAL          // incluir salario na ficha ?
private cHOMOLO          // incluir homologados ?
private cMATRICULA       // matricula
private cCENTRO          // centro
private cFILIAL          // filail
private cGRUPOC          // grupoc
private bFILTRO          // filtro para centro, filial ou grupo
private aEDICAO := {}    // vetor para os campos de entrada de dados

SITUA->(dbSetFilter({|| Anomes == XANOMES},"Anomes == XANOMES"))
GRPS->(dbSetFilter({|| Anomes == XANOMES},"Anomes == XANOMES"))

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qesco(-1,0,@cORDEM,sBLOCO1) }     , "ORDEM"     })
aadd(aEDICAO,{{ || view_fun(-1,0,@cMATRICULA)}       , "MATRICULA" })
aadd(aEDICAO,{{ || NIL },NIL}) // nome do funcionario
aadd(aEDICAO,{{ || view_ccusto(-1,0,@cCENTRO)}       , "CENTRO"    })
aadd(aEDICAO,{{ || NIL },NIL}) // descricao do centro
aadd(aEDICAO,{{ || view_filia(-1,0,@cFILIAL)}        , "FILIAL"    })
aadd(aEDICAO,{{ || NIL },NIL}) // descricao do filial
aadd(aEDICAO,{{ || view_grupoc(-1,0,@cGRUPOC)}       , "GRUPOC"    })
aadd(aEDICAO,{{ || NIL },NIL}) // descricao do grupoc

do while .T.

   qlbloc(5,0,"B505A","QBLOC.GLO")
   XNIVEL     := 1
   XFLAG      := .T.
   cMATRICULA := space(6)
   cCENTRO    := space(8)
   cFILIAL    := space(4)
   cGRUPOC    := space(4)
   cORDEM     := " "

   // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; dbcloseall() ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   if ( i_inicializacao() , i_impressao() , NIL )

   qmensa()

enddo

/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA _____________________________________________

static function i_critica ( cCAMPO )
   do case
      case cCAMPO == "ORDEM"
           qrsay(XNIVEL,qabrev(cORDEM,"MN",{"Matricula","Nome"}))
      case cCAMPO == "MATRICULA"
           if ! empty(cMATRICULA)
              qrsay(XNIVEL,cMATRICULA:=strzero(val(cMATRICULA),6))
           endif
           qrsay(XNIVEL+1,iif(FUN->(dbseek(cMATRICULA)),left(FUN->Nome,30),"*** Todos os Funcion rios ***"))
      case cCAMPO == "CENTRO"
           if ! empty(cCENTRO)
              if empty(right(cCENTRO,4))
                 qmensa("Centro de Custo n„o Anal¡tico !!","B")
                 return .F.
              endif
              if ! CCUSTO->(dbseek(cCENTRO))
                 qmensa("Centro de Custo n„o Cadastrado !!","B")
                 return .F.
              endif
           endif
           qrsay(XNIVEL+1,iif(CCUSTO->(dbseek(cCENTRO)),CCUSTO->Descricao,"*** Todos os Centros ***"))
      case cCAMPO == "FILIAL"
           qrsay(XNIVEL+1,iif(FILIAL->(dbseek(cFILIAL)),left(FILIAL->Razao,40),"*** Todas as Filiais ***"))
      case cCAMPO == "GRUPOC"
           qrsay(XNIVEL+1,iif(GRUPOC->(dbseek(cGRUPOC)),GRUPOC->Descricao,"*** Todos os Grupos ***"))
   endcase
return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // CRIA MACRO DE FILTRO __________________________________________________

   do case
      case ! empty(cCENTRO)
//         bFILTRO := { || FUN->Centro == cCENTRO }
           bFILTRO := { || .T. }
      case ! empty(cFILIAL)
           bFILTRO := { || FUN->Filial == cFILIAL }
      case ! empty(cGRUPOC)
           bFILTRO := { || GRUPOV->(dbseek(cGRUPOC+FUN->Matricula)) }
      otherwise
           bFILTRO := { || .T. }
   endcase

   // SELECIONA ORDEM DO ARQUIVO CADFUN _____________________________________

   do case
      case cORDEM == "M" ; FUN->(dbsetorder(1)) // matricula
      case cORDEM == "N" ; FUN->(dbsetorder(1)) // nome
   endcase

   qmensa()

   // ESTABELECE RELACOES ENTRE ARQUIVOS ____________________________________

   SITUA->(dbSetRelation("CBO",{|| Cbo},"Cbo"))
   SITUA->(dbSetRelation("CARGO",{|| Cargo},"Cargo"))
// FUN->(dbSetRelation("CCUSTO",{|| Centro},"Centro"))
// SITUA->(dbSetRelation("CCUSTO",{|| Centro},"Centro"))
   FUN->(dbSetRelation("SIND",{|| Sind_cod},"Sind_cod"))
   FUN->(dbSetRelation("GRPS",{|| Grps},"Grps"))
   FUN->(dbSetRelation("FILIAL",{|| Filial},"Filial"))

   FUN->(dbgotop())

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impressao

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif

   if ! empty(cMATRICULA)
      FUN->(dbseek(cMATRICULA))
   endif

   // LOOP DE IMPRESSAO _____________________________________________________

   do while ! FUN->(eof()) .and. qcontprn()

      SITUA->(dbseek(FUN->Matricula))

      if ! empty(cCENTRO) .and. SITUA->CCusto <> cCENTRO
         FUN->(Dbskip())
         loop
      endif

      if ! qlineprn() ; return ; endif

      qmensa("Processando Matricula: "+FUN->Matricula)

      if eval(bFILTRO)
//      .and. ;   (FUN->Situacao <> "H" .or. (FUN->Situacao == "H" .and. cHOMOLO == "S"))
         qpageprn()
         qcabecprn("*** REGISTRO DE EMPREGADO ***",132)
         i_ficha()
      endif

      FUN->(dbskip())

      if ! empty(cMATRICULA) ; exit ; endif

   enddo

   qstopprn()

return

/////////////////////////////////////////////////////////////////////////////
// DADOS CADASTRAIS PARA A FICHA DO FUNCIONARIO _____________________________

static function i_ficha

   @ prow()+1,0 say "Numero  " + FUN->Matricula + "           Nome " + left(FUN->Nome,30) + "/ Matricula Associada: " +FUN->Mat_ass + "               Numero de Matricula " + FUN->Matricula
   @ prow()+2,25      say "Pai  " + FUN->Nome_pai
   @ prow(),pcol()+2  say "       Nacionalidade " + expan_nacio(FUN->Nac_pai)
   @ prow()+1,17 say "FILIACAO"
   @ prow()+1,25      say "Mae: " + FUN->Nome_mae
   @ prow(),pcol()+2 say "       Nacionalidade " + expan_nacio(FUN->Nac_mae)
   @ prow()+2,25 say "DATA DE NASCIMENTO IDADE NACIONALIDADE      ESTADO CIVIL   LOCAL DO NASCIMENTO ESTADO CEDULA DE IDENTIDADE"
   CGM->(dbseek(FUN->Nat_cgm))
   @ prow()+1,25 say "  "+dtoc(FUN->Data_nasc)+"       "+StrZero((val(right(dtoc(Date()),4)) - val(right(dtoc(FUN->Data_nasc),4))),3)+"   "+expan_nacio(FUN->Nacional)+" "+qabrev(FUN->Est_civil,"12345",{"Solteiro","Casado","Desquitado","Divorciado","Viuvo"})+"   "+left(CGM->Municipio,20)+"    "+CGM->Estado+" "+FUN->Idt_num
   @ prow()+2,25 say "CART.PROFISSIONAL  SERIE  CART.RESERVISTA CATEGORIA    CPF/CIC      TITULO ELEITOR SEC.ZONA CARTEIRA/SAUDE"
   @ prow()+1,25 say  FUN->Cp_num+"             "+FUN->Cp_serie+"  "+FUN->Res_num+"   "+qabrev(FUN->Res_sit,"01234567",{"Indefinido  ","Disp.Incorp.","Alis.Militar","Desobrigacao","1-Categoria.","2-Categoria.","3-Categoria.","Cert.Isencao"})+" "+;
   FUN->Cpf_num+"  "+FUN->Te_num+" "+FUN->Te_zon+" "+FUN->Te_sec
   @ prow()+4,0  say "QUANDO ESTRANGEIRO            CART.MOD.19  E CASADO(A) COM BRASILEIRO(A)?  E NATURALIZADO?  TEM FILHOS BRASILEIROS?"
   @ prow()+1,0  say "  "+dtoc(FUN->Nc_dat)+"                     "+FUN->nc_19+"     "
   @ prow()+1,0  say ""
   @ prow()+1,0  say "Data que Chegou no Brasil     N.REG.GERAL           NOME DO CONJUGE                         QUANTOS?                   AUTENTICACAO"
   @ prow()+3,0  say "Endereco "+left(FUN->Endereco,41)+"  Bairro "+left(FUN->Bairro,18)+" Cep "+FUN->Cep +"    (*** CARACTERISTICAS FISICOS ***)"
   @ prow()+1,0  say "                                                                                           Cor  Altura  Peso  Cabelos Olhos  Sinais"
   @ prow()+1,0  say "Mudanca de Endereco                                                                        [  ] [    ]  [   ] [     ] [   ]  [    ]"
   @ prow()+2,0  say ""
   if DEPE->(dbseek(FUN->Matricula))
      @ prow()+2,0   say "Beneficiarios(NOME)            Data.Nasc.   Irrf  Sfam  Saud  Vida  Educ   (*******  PROGRAMA DE INTEGRACAO SOCIAL  -  PIS *******)"
   endif
   @ prow()+1,0  say ""
   nCONTAS:=0
   do while ! DEPE->(eof()) .and. DEPE->Matricula == FUN->Matricula
      @ prow()+1,0      say DEPE->Nome + " " + dtoc(DEPE->Data_nasc)
      @ prow(),pcol()+4 say qabrev(DEPE->Irrf     ,"SN",{"Sim","Nao"})
      @ prow(),pcol()+3 say qabrev(DEPE->Sal_fam  ,"SN",{"Sim","Nao"})
      @ prow(),pcol()+3 say qabrev(DEPE->Seg_saude,"SN",{"Sim","Nao"})
      @ prow(),pcol()+3 say qabrev(DEPE->Seg_vida ,"SN",{"Sim","Nao"})
      @ prow(),pcol()+3 say qabrev(DEPE->Bolsa    ,"SN",{"Sim","Nao"})
      DEPE->(dbskip())
      if DEPE->Matricula == FUN->Matricula
         nCONTAS++
         CADAS_PIS(nCONTAS,0)
      Endif
   enddo
   nNUMER:=0
   if nCONTAS < 5
      nCONTAS := nCONTAS+1
      For nFALT:= nCONTAS to 5
          CADAS_PIS(nFALT,nNUMER)
          nNUMER:=1
      Next
   Endif
   @ prow()+1,0  say ""
   @ prow()+2,0  say "DATA DA ADMISS. DATA DO REGISTRO CARGO                SECAO       SALARIO INICIAL  COMISSOES TAREFA              FORMA DE PAGAMENTO"
   SITUA->(dbseek(FUN->Matricula))
   @ prow()+1,0  say dtoc(FUN->Data_adm)+"      "+dtoc(FUN->Data_adm)+"       "+left(CARGO->Descricao,20)+" "+left(CCUSTO->Descricao,12)+" "+transform(SITUA->Salario,"@E 999,999,999.99")+"            "+left(CBO->Descricao,19)+" "+qabrev(SITUA->Categoria,"123456789",{"Mensal","Quinzenal","Semanal","Diario","Horario","Tarefa","Comissao","Honorario","Estagiario"})
   @ prow()+3,0  say "SITUACAO PERANTE O FUNDO DE GARANTIA DO TEMPO DE SERVICO                                    (*** HORARIO DE TRABALHO ***)"
   BANCO->(dbseek(FUN->Fgts_ban))
   @ prow()+1,0  say "Cta FGTS "+FUN->Fgts_num+" Data da Opcao "+dtoc(FUN->Fgts_dat)+" Bco/Agencia "+FUN->Fgts_ban+"/"+BANCO->Banco+"/"+BANCO->Agencia + "           ENTRADA   REFEICAO   SAIDA    DESCANCO SEMANAL "
   BANCO->(dbseek(FUN->Pis_ban))
   @ prow()+1,0  say "Banco Depositante "+left(BANCO->Descricao,30)+" Agencia "+left(BANCO->End_agenc,27)+Space(3)+SITUA->Hentrada+"  "+SITUA->Hintervalo+" "+SITUA->Hsaida+"    "+SITUA->Descanso
   @ prow()+4,60 say " ESTOU DE PLENO ACORDO COM AS DECLARACOES ACIMA QUE EXPRIMEM A VERDADE."
   @ prow()+3,0  say ""
   @ prow()+2,80 say "__________________________________________________"
   @ prow()+1,80 say "            ASSINATURA DO EMPREGADO               "
   @ prow()+3,0  say ""
   @ prow()+1,0  say "                             _____________________________________________"
   @ prow()+1,0  say "POLEGAR DIREITO                     CARIMBO E VISTO DO EMPREGADOR                EM ___________ DE _____________________ DE 19____"

return

//////////////////////////////////////////////////////////////////////////////////////////////////////
// FUNCAO ESPECIAL PARA INTERCALAR A IMPRESSAO NA MESMA LINHA

   Function CADAS_PIS
   Parameters nTEST,nNUM
   if nTEST == 1
      @ prow()+nNUM,75 say "Cadastrado em  "+dtoc(FUN->Pis_dat)
      Return
   Elseif nTEST == 2
      @ prow()+nNUM,75 say "Sob Numero "+FUN->Pis_num
      Return
   Elseif nTEST == 3
      BANCO->(dbseek(FUN->Pis_ban))
      @ prow()+nNUM,75 say "Dep.no Banco "+BANCO->Descricao
      Return
   Elseif nTEST == 4
      BANCO->(dbseek(FUN->Pis_ban))
      @ prow()+nNUM,75 say "Endereco "+left(BANCO->End_agenc,40)
      Return
   Elseif nTEST == 5
      BANCO->(dbseek(FUN->Pis_ban))
      @ prow()+nNUM,75 say "Banco "+left(BANCO->Descricao,37)+" Agencia "+BANCO->Agencia
      Return
   Endif

