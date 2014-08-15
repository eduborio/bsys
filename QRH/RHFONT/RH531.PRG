/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: FOLHA DE PAGAMENTO
// OBJETIVO...: FICHA CADASTRAL
// ANALISTA...: CARLOS EDUARDO RABELLO NUNES
// PROGRAMADOR: O MESMO
// INICIO.....: SETEMBRO DE 1994
// OBS........:
// ALTERACOES.:

#define K_MAX_LIN 52

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local bESCAPE := {||(XNIVEL==1 .and. !XFLAG) .or. empty(cORDEM)}

private sBLOCO1 := qlbloc("B531B","QBLOC.GLO") // ordem de impressao

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
aadd(aEDICAO,{{ || qesco(-1,0,@cINCSAL,XSN) }        , "INCSAL"    })
aadd(aEDICAO,{{ || qesco(-1,0,@cHOMOLO,XSN) }        , "HOMOLO"    })

do while .T.

   qlbloc(5,0,"B531A","QBLOC.GLO")
   XNIVEL     := 1
   XFLAG      := .T.
   cMATRICULA := space(6)
   cCENTRO    := space(8)
   cFILIAL    := space(4)
   cGRUPOC    := space(4)
   cORDEM     := cHOMOLO := cINCSAL := " "

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
      case cCAMPO == "INCSAL"
           qrsay(XNIVEL,qabrev(cINCSAL,"SN",{"SIM","NAO"}))
      case cCAMPO == "HOMOLO"
           qrsay(XNIVEL,qabrev(cHOMOLO,"SN",{"SIM","NAO"}))
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
      case cORDEM == "N" ; FUN->(dbsetorder(2)) // nome
   endcase

   qmensa()

   // ESTABELECE RELACOES ENTRE ARQUIVOS ____________________________________

   SITUA->(dbSetRelation("CBO",{|| Cbo},"Cbo"))
   SITUA->(dbSetRelation("CARGO",{|| Cargo},"Cargo"))
// FUN->(dbSetRelation("CCUSTO",{|| Centro},"Centro"))
// SITUA->(dbSetRelation("CCUSTO",{|| Centro},"Ccusto"))
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

      if ! empty(cCENTRO) .and. SITUA->Ccusto <> cCENTRO
         FUN->(dbskip())
         loop
      endif

      if FUN->Data_adm > qfimmes(XDATASYS)
         FUN->(dbskip())
         loop
      endif
      
      if ! qlineprn() ; return ; endif

      qmensa("Processando Matricula: "+FUN->Matricula)

      if eval(bFILTRO)
//      .and. ;   (FUN->Situacao <> "H" .or. (FUN->Situacao == "H" .and. cHOMOLO == "S"))
         qpageprn()
         qcabecprn("FICHA CADASTRAL DE FUNCIONARIO",80)
         CCUSTO->(dbseek(SITUA->CCusto))
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

   @ prow()+1,0 say "Matricula: " + FUN->Matricula + "  Nome: " + left(FUN->Nome,30) + "  Matric.Assoc.: " + FUN->Mat_ass

   @ prow()+2,0 say "Categoria: " + qabrev(SITUA->Categoria,"123456789",{"Mensal","Quinzenal","Semanal","Diario","Horario","Tarefa","Comissao","Honorario","Estagiario"})

   @ prow(),pcol()+1 say "Vinculo: " + qabrev(SITUA->Vinculo,"ABCDEFGHIJKLMN",{"Urbano-CLT/PJ/Pz Ind.","Urbano-CLT/PF/Pz Ind.","Rural-CLT/PJ/Pz Ind.","Rural-CLT/PF/Pz Ind.","Servidor(RJU)-Militar","Servidor n„o efetivo",+;
   "Trabalhador Avulso","Trabalhador Tempor rio","Urbano-CLT/PJ/Pz. Det.","Urbano-CLT/PF/Pz. Det.","Rural-CLT/PJ/Pz. Det.","Rural-CLT/PF/Pz. Det.","Diretor c/V¡nc. FGTS","Diretor s/V¡nc. FGTS"})

   @ prow(),pcol()+1 say "Turno: " + qabrev(SITUA->Turno,"DNM",{"Diurno","Noturno","Misto"})

   @ prow()+2,0      say "Sexo: " + qabrev(FUN->Sexo,"MF",{"Masculino","Feminino"})
   @ prow(),pcol()+3 say "Estado Civil: " + qabrev(FUN->Est_civil,"12345",{"Solteiro","Casado","Desquitado","Divorciado","Viuvo"})
   @ prow(),pcol()+3 say "Instrucao: " + qabrev(FUN->Instrucao,"123456789",{"Analfabeto","Prim rio Incompleto","Prim rio","Gin sio Incompleto","Gin sio","2. Grau Incompleto","2. Grau","Superior Incompleto","Superior"})

   @ prow()+2,0      say "Cargo.....: " + pad(SITUA->Cargo,10) + CARGO->Descricao
   @ prow()+1,0      say "C.B.O.....: " + pad(SITUA->Cbo,10) + CBO->Descricao
   @ prow()+1,0      say "Guia GRPS.: " + pad(FUN->Grps,10) + GRPS->Descricao
// @ prow()+1,0      say "Centro....: " + pad(FUN->Centro,10) + CCUSTO->Descricao
   @ prow()+1,0      say "Centro....: " + pad(SITUA->Ccusto,10) + CCUSTO->Descricao
   @ prow()+1,0      say "Filial....: " + pad(FUN->Filial,10) + left(FILIAL->Razao,55)
   @ prow()+1,0      say "Sindicato.: " + pad(FUN->Sind_cod,10) + SIND->Descricao

   @ prow()+2,0      say "Data de Admissao: " + dtoc(FUN->Data_adm)
   @ prow(),pcol()+2 say "Data Renov. Ctr.: " + dtoc(FUN->Data_rctr)
   @ prow(),pcol()+2 say "Data Fim Ctr.: " + dtoc(FUN->Data_fctr)

   @ prow()+2,0      say "Pai: " + FUN->Nome_pai
   @ prow(),pcol()+2 say "Nac.: " + expan_nacio(FUN->Nac_pai)
   @ prow()+1,0      say "Mae: " + FUN->Nome_mae
   @ prow(),pcol()+2 say "Nac.: " + expan_nacio(FUN->Nac_mae)

   @ prow()+2,0      say "Identidade No.: " + FUN->Idt_num
   @ prow(),pcol()+2 say "Data: " + dtoc(FUN->Idt_dat)
   @ prow(),pcol()+2 say "Org.Emi: " + FUN->Idt_emi
   // futuro idt_cgm
   @ prow(),pcol()+2 say "Via: " + FUN->Idt_via

   @ prow()+2,0      say "Cart.Prof.: " + FUN->Cp_num
   @ prow(),pcol()+2 say "Serie: " + FUN->Cp_serie
   @ prow(),pcol()+2 say "Data Emissao: " + dtoc(FUN->Cp_emis)
   // futuro cp_cgm
   @ prow(),pcol()+2 say "Pag.: " + FUN->Cp_pagina

   @ prow()+2,0      say "Reserv.: " + FUN->Res_num
   @ prow(),pcol()+1 say "Regiao: " + FUN->Res_reg
   @ prow(),pcol()+1 say "Circ.: " + FUN->Res_cir
   @ prow(),pcol()+1 say "Sit.: " + qabrev(FUN->Res_sit,"1234567",{"Cert.Disp.Incorpora‡ao","Cert.Alistamento Militar","Atestado Desobrigacao","Cert.Reserv.1a Categoria","Cert.Reserv.2a Categoria","Cert.Reserv.3a Categoria","Certificado de Isencao"})

   @ prow()+2,0      say "Habilitacao: " + FUN->Hab_num
   @ prow(),pcol()+2 say "Categoria: " + FUN->Hab_cat
   @ prow(),pcol()+2 say "Data Venc.: " + dtoc(FUN->Hab_dat)
   // futuro hab_cgm

   @ prow()+2,0      say "Titulo Eleitor: " + FUN->Te_num
   @ prow(),pcol()+2 say "Zona: " + FUN->Te_zon
   @ prow(),pcol()+2 say "Secao: " + FUN->Te_sec
   // futuro te_cgm

   @ prow()+2,0      say "CPF: " + FUN->Cpf_num

   @ prow()+2,0      say "Cta Salario: " + pad(FUN->Csal_num,12)
   @ prow(),pcol()+2 say "Bco/Ag.: " + FUN->Csal_ban + "/"
   BANCO->(dbseek(FUN->Csal_ban))
   @ prow(),pcol()   say BANCO->Banco + "/" + BANCO->Agencia

   @ prow()+1,0      say "Cta FGTS...: " + pad(FUN->Fgts_num,11)
   @ prow(),pcol()+2 say "Bco/Ag.: " + FUN->Fgts_ban + "/"
   BANCO->(dbseek(FUN->Fgts_ban))
   @ prow(),pcol()   say BANCO->Banco + "/" + BANCO->Agencia

   @ prow()+1,0      say "Cta PIS....: " + pad(FUN->Pis_num,11)
   @ prow(),pcol()+2 say "Bco/Ag.: " + FUN->Pis_ban + "/"
   BANCO->(dbseek(FUN->Pis_ban))
   @ prow(),pcol()   say BANCO->Banco + "/" + BANCO->Agencia

   @ prow()+2,0      say "End.: " + FUN->Endereco
   @ prow(),pcol()+1 say "Bairro: " + FUN->Bairro

   @ prow()+2,0      say "CEP: " + FUN->Cep
   CGM->(dbseek(FUN->Resid_cgm))
   @ prow(),pcol()+2 say "Municipio: " + alltrim(CGM->Municipio)
   @ prow(),pcol()+2 say "UF: " + CGM->Estado
   @ prow(),pcol()+2 say "Fone: " + FUN->Ddd + "." + FUN->Telefone

   @ prow()+2,0      say "Data Nasc.: " + dtoc(FUN->Data_nasc)
   @ prow(),pcol()+2 say "Nacionalidade: " + expan_nacio(FUN->Nacional)

   @ prow()+2,0      say "Hora da Entrada: "   + SITUA->Hentrada
   @ prow(),pcol()+4 say "Intervalo: " + SITUA->Hintervalo
   @ prow(),pcol()+4 say "Hora da Saida: " + SITUA->Hsaida

   @ prow()+2,0      say "Descanso: " + SITUA->Descanso
   @ prow(),pcol()+5 say "Horario no Sabado: "   + SITUA->Hsabado

   @ prow()+2,0      say "Carga Hor. Mensal: " + str(FUN->Hor_trab,6,2)
   @ prow(),pcol()+2 say "Carga Hor. Semanal: " + str(FUN->Hor_sema,6,2)
   @ prow(),pcol()+2 say "Cartao de Ponto: " + qabrev(FUN->Ctp_eti,"SN",{"Sim","Nao"})

   @ prow()+2,0      say "Cont. Sind. Paga ?: " + qabrev(FUN->Sind_sit,"SN",{"Sim","Nao"})
   @ prow(),pcol()+2 say "Prim. Adm. ?: " + qabrev(FUN->Prim_adm,"SN",{"Sim","Nao"})
   @ prow(),pcol()+2 say "Transf. ?: " + qabrev(SITUA->Transf,"SN",{"Sim","Nao"})
   @ prow(),pcol()+2 say "Tipo Pgto.: " + qabrev(SITUA->Tipo_pgto,"BCDO",{"Banco","Cheque","Dinheiro","Outro"})

   if DEPE->(dbseek(FUN->Matricula))
      @ prow()+2,0   say "Dependentes:                   Data.Nasc.  Irrf  Sfam  Saud  Vida  Educ"
   endif

   do while ! DEPE->(eof()) .and. DEPE->Matricula == FUN->Matricula
      @ prow()+1,0      say DEPE->Nome + " " + dtoc(DEPE->Data_nasc)
      @ prow(),pcol()+4 say qabrev(DEPE->Irrf     ,"SN",{"Sim","Nao"})
      @ prow(),pcol()+3 say qabrev(DEPE->Sal_fam  ,"SN",{"Sim","Nao"})
      @ prow(),pcol()+3 say qabrev(DEPE->Seg_saude,"SN",{"Sim","Nao"})
      @ prow(),pcol()+3 say qabrev(DEPE->Seg_vida ,"SN",{"Sim","Nao"})
      @ prow(),pcol()+3 say qabrev(DEPE->Bolsa    ,"SN",{"Sim","Nao"})
      DEPE->(dbskip())
   enddo

   if cINCSAL == "S"
      @ prow()+2,0   say "Salario Contratual: " + transform(SITUA->Salario,"@E 999,999,999.99")
   endif
return

