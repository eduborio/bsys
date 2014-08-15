/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: FOLHA DE PAGAMENTO
// OBJETIVO...: CHEQUES DE PAGAMENTO
// ANALISTA...: CARLOS EDUARDO RABELLO NUNES
// PROGRAMADOR: O MESMO
// INICIO.....:
// OBS........:
// ALTERACOES.:

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local bESCAPE := {||(XNIVEL==1 .and. !XFLAG) .or. empty(cORDEM)}

private sBLOCO1 := qlbloc("B531B","QBLOC.GLO") // ordem de impressao

private cORDEM                 // ordem de impressao
private cPOSIC                 // teste de posicionamento ?
private cMATRICULA             // matricula
private cCENTRO                // centro
private cFILIAL                // filial
private cGRUPOC                // grupoc
private bFILTRO                // filtro
private aEDICAO := {}          // vetor para os campos de entrada de dados
private cANOMES := qanomes(XDATASYS)

cAMBIENTE :=  rh_escolhe_amb()

SITUA->(dbSetFilter({|| Anomes == XANOMES},"Anomes == XANOMES"))

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qesco(-1,0,@cORDEM,sBLOCO1) }     , "ORDEM"     })
aadd(aEDICAO,{{ || qesco(-1,0,@cPOSIC,XSN) }         , "POSIC"     })
aadd(aEDICAO,{{ || view_fun(-1,0,@cMATRICULA)}       , "MATRICULA" })
aadd(aEDICAO,{{ || NIL },NIL}) // nome do funcionario
aadd(aEDICAO,{{ || view_ccusto(-1,0,@cCENTRO)}       , "CENTRO"    })
aadd(aEDICAO,{{ || NIL },NIL}) // descricao do centro
aadd(aEDICAO,{{ || view_filia(-1,0,@cFILIAL)}        , "FILIAL"    })
aadd(aEDICAO,{{ || NIL },NIL}) // descricao do filial
aadd(aEDICAO,{{ || view_grupoc(-1,0,@cGRUPOC)}       , "GRUPOC"    })
aadd(aEDICAO,{{ || NIL },NIL}) // descricao do grupoc

do while .T.

   qlbloc(5,0,"B524A","QBLOC.GLO")
   XNIVEL     := 1
   XFLAG      := .T.
   cMATRICULA := space(6)
   cCENTRO    := space(8)
   cFILIAL    := space(4)
   cGRUPOC    := space(4)
   cPOSIC     := "N"
   cORDEM     := " "

   // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; dbcloseall() ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   if ( i_inicializacao() , i_impressao() , NIL )

enddo

/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA _____________________________________________

static function i_critica ( cCAMPO )
   do case
      case cCAMPO == "ORDEM"
           qrsay(XNIVEL,qabrev(cORDEM,"MN",{"Matr¡cula","Nome"}))
      case cCAMPO == "POSIC"
           qrsay(XNIVEL,qabrev(cPOSIC,"SN",{"Sim","N„o"}))
           if cPOSIC == "S"
              i_posic()
              return .F.
           endif
      case cCAMPO == "MATRICULA"
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
           bFILTRO := { || SITUA->Ccusto == cCENTRO }
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

   select FUN
   set relation to Matricula+cANOMES into BASE

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

   do while ! FUN->(eof()) .and. qcontprn()
      SITUA->(dbseek(FUN->Matricula))

      if FUN->Data_adm > qfimmes(XDATASYS)
         FUN->(dbskip())
         loop
      endif
   
      qmensa("Processando Matr¡cula: "+FUN->Matricula)

      // SOMENTE FILTRO (CENTRO/FILIAL/GRUPO) +
      // SITUACAO DIFERENTE DE HOMOLOGADO OU DEMITIDOS +
      // TIPO DE PAGAMENTO IGUAL A "C"HEQUE +
      // LIQUIDO A RECEBER DIFERENTE DE ZERO...

      if eval(bFILTRO) .and. ! FUN->Situacao $ "HD" ;
                       .and. SITUA->Tipo_pgto == "C" ;
                       .and. &("BASE->Prov_"+cAMBIENTE) - &("BASE->Desc_"+cAMBIENTE) <> 0
         i_emite ( left(FUN->Nome,30) , &("BASE->Prov_"+cAMBIENTE) - &("BASE->Desc_"+cAMBIENTE) )
      endif

      FUN->(dbskip())

      if ! empty(cMATRICULA) ; exit ; endif

   enddo

   qstopprn(.F.)

return

/////////////////////////////////////////////////////////////////////////////
// EMITE O CHEQUE PARA O FUNCIONARIO ________________________________________

static function i_emite ( cNOME , nVALOR )

   setprc(0,0)

   cEXTENSO := qextenso(nVALOR) + " " + replicate("*",125)

   @ 04,50 say nVALOR picture "@E 9,999,999,999.99"

   if substr(cEXTENSO,59,1) = " "
      @ 06,10 say substr(cEXTENSO,1,58)
      @ 08,01 say substr(cEXTENSO,59,67)
   else
      @ 06,10 say substr(cEXTENSO,1,57)+"-"
      @ 08,01 say substr(cEXTENSO,58,67)
   endif

   @ 10,02 say alltrim(cNOME)+" "+replicate("*",(57-len(alltrim(cNOME))))
   @ 12,36 say "Curitiba   " + strzero(day(date()),2)
   @ 12,52 say qnomemes(date()) + "    " + str(year(date())-1900,2)
   @ 18,00 say ""

return

/////////////////////////////////////////////////////////////////////////////
// TESTE DE POSICIONAMENTO NA IMPRESSORA ____________________________________

static function i_posic()

   if ! qinitprn() ; return ; endif

   setprc(0,0)
   @ 04,50 say 9999999999.99 pict "@E 9,999,999,999.99"
   @ 06,10 say "valor por extenso " + replicate("*",40)
   @ 08,01 say replicate("*",67)
   @ 10,02 say "portador " + replicate("*",48)
   @ 12,36 say "Curitiba   " + strzero(day(date()),2)
   @ 12,52 say qnomemes(date()) + "    " + str(year(date())-1990,1)
   @ 18,00 say ""

   qstopprn(.F.)

return

