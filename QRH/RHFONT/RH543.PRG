/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: FOLHA DE PAGAMENTO
// OBJETIVO...: EVOLUCAO SALARIAL
// ANALISTA...:
// PROGRAMADOR: ANDERSON EDUARDO DE LIMA.
// INICIO.....: MAIO DE 1997
// OBS........:
// ALTERACOES.:

#define K_MAX_LIN 52

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local bESCAPE := {||(XNIVEL==1 .and. !XFLAG) .or. empty(cMESANO) .or. lastkey() == 27}

private sBLOCO1 := qlbloc("B543B","QBLOC.GLO") // ordem de impressao

private cTIPOREL         // tipo de relatorio (mensal ou 13o.)
private cORDEM           // ordem de impressao
private cMESANO          // mes ano base
private cANOMES          // ano mes base
private cINCSAL          // incluir salario na ficha ?
private cHOMOLO          // incluir homologados ?
private cMATRICULA       // matricula
private cCENTRO          // centro
private cFILIAL          // filail
private cGRUPOC          // grupoc
private nPER  := 0       // percentual
private nSAL1 := 0       // salario1
private nSAL2 := 0       // salario2
private nSAL3 := 0       // salario3
private lPRI  := .T.     // logico primeiro
private bFILTRO          // filtro para centro, filial ou grupo
private aEDICAO := {}    // vetor para os campos de entrada de dados

SITUA->(dbSetFilter({|| Anomes == XANOMES},"Anomes == XANOMES"))

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qgetx(-1,0,cMESANO,"99/9999")}    , "MESANO"    })
aadd(aEDICAO,{{ || qesco(-1,0,@cORDEM,sBLOCO1) }     , "ORDEM"     })
aadd(aEDICAO,{{ || view_fun(-1,0,@cMATRICULA)}       , "MATRICULA" })
aadd(aEDICAO,{{ || NIL },NIL}) // nome do funcionario
aadd(aEDICAO,{{ || view_ccusto(-1,0,@cCENTRO)}       , "CENTRO"    })
aadd(aEDICAO,{{ || NIL },NIL}) // descricao do centro
aadd(aEDICAO,{{ || view_filia(-1,0,@cFILIAL)}        , "FILIAL"    })
aadd(aEDICAO,{{ || NIL },NIL}) // descricao do filial
aadd(aEDICAO,{{ || view_grupoc(-1,0,@cGRUPOC)}       , "GRUPOC"    })
aadd(aEDICAO,{{ || NIL },NIL}) // descricao do grupoc
//aadd(aEDICAO,{{ || qesco(-1,0,@cINCSAL,XSN) }        , "INCSAL"    })
//aadd(aEDICAO,{{ || qesco(-1,0,@cHOMOLO,XSN) }        , "HOMOLO"    })

do while .T.

   qlbloc(5,0,"B543A","QBLOC.GLO")
   XNIVEL     := 1
   XFLAG      := .T.
   cMATRICULA := space(6)
   cCENTRO    := space(8)
   cFILIAL    := space(4)
   cGRUPOC    := space(4)
   cMESANO    := right(XANOMES,2)+"/"+left(XANOMES,4)
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
      case cCAMPO == "MESANO"
           cANOMES := qanomes(ctod("01/"+cMESANO))
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
   SITUA->(dbsetorder(2))
   qmensa()

   // ESTABELECE RELACOES ENTRE ARQUIVOS ____________________________________
   cANOMES := qanomes(ctod("01/"+cMESANO))
   SITUA->(dbSetFilter({|| Anomes >= cANOMES},"Anomes >= cANOMES"))

   SITUA->(dbSetRelation("CBO",{|| Cbo},"Cbo"))
   SITUA->(dbSetRelation("CARGO",{|| Cargo},"Cargo"))
   //FUN->(dbSetRelation("SIND",{|| Sind_cod},"Sind_cod"))
   //FUN->(dbSetRelation("GRPS",{|| Grps},"Grps"))
   //FUN->(dbSetRelation("CCUSTO",{|| Centro},"Centro"))
   //FUN->(dbSetRelation("FILIAL",{|| Filial},"Filial"))

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

      if XPAGINA == 0 .or. prow() > K_MAX_LIN
         qpageprn()
         @ prow(),0 say XCOND1
         qcabecprn("RELATORIO DE EVOLUCAO SALARIAL",132)
         @ prow()+1,0 say "CODIGO MATRICULA  NOME..........................  FUNCAO........................  DATA....  TIPO SAL..  SALARIO.......  VAR.PER"
         @ prow()+1,0 say replicate("-",80)
      endif

      if ! qlineprn() ; return ; endif

      qmensa("Processando Matricula: "+FUN->Matricula)

      if eval(bFILTRO) .and. ;
         (FUN->Situacao <> "H" .or. (FUN->Situacao == "H" .and. cHOMOLO == "S"))
         i_ficha()
      endif

      FUN->(dbskip())

      if ! empty(cMATRICULA) ; exit ; endif

   enddo

   qstopprn()

return

/////////////////////////////////////////////////////////////////////////////
// DADOS RELATORIO DE EVOLUCAO SALARIAL______________________________________

static function i_ficha
   nSAL1 := SITUA->Salario    //primeiro salario
   lPRI  := .T.
   cMAT  := FUN->Matricula

   @ prow()+1,0 say  FUN->Matricula+"| "+FUN->Mat_ass+"| "+left(FUN->Nome,30)+"| "+left(CARGO->Descricao,30)+"| "+dtoc(SITUA->Data_Aumen)+"| "+;
                     qabrev(SITUA->Categoria,"123456789",{"Mensal","Quinzenal","Semanal","Diario","Horario","Tarefa","Comissao","Honorario","Estagiario"})+"| "+;
                     transform(SITUA->Salario,"@E 999,999,999.99")+"|"

   qmensa(FUN->Matricula+"-"+SITUA->Cargo+"-"+CARGO->Descricao)
   do while (SITUA->Matricula == FUN->Matricula)
      nSAL2 := SITUA->Salario //se primera vez sal2 == sal1 senao sal anterior
      SITUA->(dbskip())
      nSAL3 := SITUA->Salario //um mes sepois do anterior

      if lPRI
         nPER := (((nSAL3-nSAL1) * 100) / nSAL1)
      else
         nPER := (((nSAL3-nSAL2) * 100) / nSAL2)
      endif

      if (nSAl3 == nSAL2)
         nPER := 0
//      elseif (nSAL3 == nSAL1) .and. lPRI
//         nPER := 0
      endif

      if SITUA->Matricula == cMAT
        @ prow()+1, 0 say space(6)+"|"+space(9)+"|"+space(31)+"|"+space(31)+"| "+;
                          dtoc(SITUA->Data_Aumen)+"| "+;
                          qabrev(SITUA->Categoria,"123456789",{"Mensal","Quinzenal","Semanal","Diario","Horario","Tarefa","Comissao","Honorario","Estagiario"})+"| "+;
                          transform(SITUA->Salario,"@E 999,999,999.99")+"| "+;
                          iif((nPER <> 0), transform(nPER, "999.99")+"%", "       ")
      endif

   enddo

return
