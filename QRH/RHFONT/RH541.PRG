/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: FOLHA DE PAGAMENTO
// OBJETIVO...: QUADRO DE HORARIOS
// ANALISTA...: CARLOS EDUARDO RABELLO NUNES
// PROGRAMADOR: O MESMO
// INICIO.....: MARCO DE 1994
// OBS........:
// ALTERACOES.:

#define K_MAX_LIN 55

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local bESCAPE := {||(XNIVEL==1 .and. !XFLAG) .or. empty(cORDEM)}

private sBLOCO1 := qlbloc("B531B","QBLOC.GLO") // ordem de impressao

private cORDEM                 // ORDEM DE IMPRESSAO
private dDAT := XDATASYS       // DATA DO QUADRO
private cCENTRO                // CENTRO
private cFILIAL                // FILIAL
private cGRUPOC                // GRUPOC
private bFILTRO                // FILTRO
private aEDICAO := {}          // VETOR PARA OS CAMPOS DE ENTRADA DE DADOS

SITUA->(dbSetFilter({|| Anomes == XANOMES},"Anomes == XANOMES"))

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qesco(-1,0,@cORDEM,sBLOCO1) }     , "ORDEM"  })
aadd(aEDICAO,{{ || qgetx(-1,0,@dDAT) }               , "DAT"    })
aadd(aEDICAO,{{ || view_ccusto(-1,0,@cCENTRO)}       , "CENTRO" })
aadd(aEDICAO,{{ || NIL },NIL}) // descricao do centro
aadd(aEDICAO,{{ || view_filia(-1,0,@cFILIAL)}        , "FILIAL" })
aadd(aEDICAO,{{ || NIL },NIL}) // descricao do filial
aadd(aEDICAO,{{ || view_grupoc(-1,0,@cGRUPOC)}       , "GRUPOC" })
aadd(aEDICAO,{{ || NIL },NIL}) // descricao do grupoc

do while .T.

   qlbloc(5,0,"B541A","QBLOC.GLO")
   XNIVEL := 1
   XFLAG  := .T.
   cMATRICULA := space(6)
   cCENTRO := space(8)
   cFILIAL := space(4)
   cGRUPOC := space(4)
   cPOSIC  := "N"
   cORDEM  := " "

   // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; dbcloseall() ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   if ( i_inicializacao() , i_impressao() , NIL )

   qmensa("")

enddo

/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA _____________________________________________

static function i_critica ( cCAMPO )
   do case
      case cCAMPO == "ORDEM"
           qrsay(XNIVEL,qabrev(cORDEM,"MN",{"Matr¡cula","Nome"}))
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
           qrsay(XNIVEL+1,iif(GRUPOC->(dbseek(cGRUPOC)),GRUPOC->Descricao,"*** Todas os Grupos ***"))
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

   FUN->(dbgotop())

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impressao

   local cLINHA := "+" + replicate("-",135) + "+"

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif

   do while ! FUN->(eof()) .and. qcontprn()
      SITUA->(dbseek(FUN->Matricula))

      if FUN->Data_adm > qfimmes(XDATASYS)
         FUN->(dbskip())
         loop
      endif
      
      qmensa("Processando Matr¡cula: "+FUN->Matricula)

      if ! qlineprn() ; return ; endif

      if XPAGINA == 0 .or. prow() > K_MAX_LIN
         qpageprn()
         @ prow(),pcol() say XCOND1
         @ prow()+1,0    say cLINHA
         @ prow()+1,0    say XCOND0 + space(11) + XAEXPAN + "QUADRO DE HORARIO DE TRABALHO" + XDEXPAN + XCOND1
         @ prow()+1,0    say cLINHA
         @ prow()+1,0    say "| Empresa...: " + XRAZAO
         @ prow()  ,70   say "CGC/MF: " + XCGCCPF
         @ prow()  ,124  say "Pagina: " + strzero(XPAGINA,3) + " |"
         @ prow()+1,0    say "| Endereco..: " + XENDERECO + " " + XNUMERO
         @ prow()  ,70   say "Bairro: " + XBAIRRO
         @ prow()  ,136  say "|"
         CNAE->(dbseek(CONFIG->Cnae))
         @ prow()+1,0    say "| Atividade.: " + CNAE->Codigo + " / " + CNAE->Descricao
         @ prow()  ,136  say "|"
         @ prow()+1,0    say cLINHA
         @ prow()+1,0    say "| MATRIC. | NOME DO FUNCIONARIO           |  DATA.ADM | CART.PROFIS. | ENTRADA |  INTERVALO  | SAIDA |    SABADO   | DESCANSO |  VISTO  |"
         @ prow()+1,0    say cLINHA
      endif

      if eval(bFILTRO) .and. ! FUN->Situacao $ "DH" .and. SITUA->Vinculo <> "N" .and. qcontprn()
         @ prow()+1,0      say "| " + FUN->Matricula + "  | " + left(FUN->Nome,30) + "|" + dtoc(FUN->Data_adm) + " |  "
         @ prow()  ,pcol() say FUN->Cp_num + "/" + FUN->Cp_serie + "|  "
         @ prow()  ,pcol() say SITUA->Hentrada + "  | " + SITUA->Hintervalo + " | " + SITUA->Hsaida + " | " + SITUA->Hsabado + " |  "
         @ prow()  ,pcol() say SITUA->Descanso + " |         |"
      endif

      // FECHA O QUADRO DE HORARIO __________________________________________

      if prow() > K_MAX_LIN ; i_rodape(cLINHA) ; endif

      FUN->(dbskip())

   enddo

   i_rodape(cLINHA)

   qstopprn()

return

/////////////////////////////////////////////////////////////////////////////
// EMITE O CABECALHO FINAL DO QUADRO DE HORARIO _____________________________

static function i_rodape ( cLINHA )
   @ prow()+1,0      say cLINHA
   @ prow()+1,0      say "|" + space(135) + "|"
   CGM->(dbseek(XCGM))
   @ prow()+1,0      say "|" + space(15) + alltrim(CGM->Municipio) + ", " + strzero(day(dDAT),2) + " de "
   @ prow()  ,pcol() say alltrim(qnomemes(month(dDAT))) + " de "
   @ prow()  ,pcol() say str(year(dDAT),4)
   @ prow()  ,136    say "|"
   @ prow()+1,0      say "|" + space(70) + replicate("_",55)
   @ prow()  ,136    say "|"
   @ prow()+1,0      say cLINHA
return
