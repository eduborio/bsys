/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: FOLHA DE PAGAMENTO
// OBJETIVO...: FICHA FINANCEIRA
// ANALISTA...: CARLOS EDUARDO RABELLO NUNES
// PROGRAMADOR: O MESMO
// INICIO.....: JUNHO DE 1995
// OBS........:
// ALTERACOES.:

#define K_MAX_LIN 55

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(lastkey()==27)}

private sBLOCO3 := qlbloc("B584C","QBLOC.GLO") // ordem de impressao

private cTITULO                // titulo do relatorio
private cORDEM  := "1"         // ordem de impressao (matricula/nome)
private cMATRICULA             // matricula p/ impressao individual
private aEDICAO := {}          // vetor para os campos de entrada de dados
private cPERI                  // periodo inicial
private cPERF                  // periodo final
private cFILIAL                // filial para impressao
private cCOND                  // condicao principal do loop
private cORDEM  := "1"         // ordem de impressao (matricula/nome)
private cPERIODO := "      "
private cANOMES := "      "
private cEVEN:= ""
private cVAL:= ""

private aFUN    := {{},{}}     // vetor com os dados do funcionario
private cNOMEEVE               // descricao do evento quando ! empty(cEVENTO)

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qgetx(-1,0,@cPERI,"@R 99/9999") } , "PERI"      })
aadd(aEDICAO,{{ || qgetx(-1,0,@cPERF,"@R 99/9999") } , "PERF"      })
aadd(aEDICAO,{{ || view_filial(-1,0,@cFILIAL)    }   , "FILIAL"    })
aadd(aEDICAO,{{ || NIL },NIL}) // descricao da filial
aadd(aEDICAO,{{ || view_fun(-1,0,@cMATRICULA)    }   , "MATRICULA" })
aadd(aEDICAO,{{ || NIL },NIL}) // descricao do funcionario
aadd(aEDICAO,{{ || qesco(-1,0,@cORDEM  ,sBLOCO3) }   , "ORDEM"     })

do while .T.

   qlbloc(5,0,"B584A","QBLOC.GLO")
   XNIVEL     := 1
   XFLAG      := .T.
   cTIPOREL   := " "
   cFILIAL    := space(4)
   cMATRICULA := space(6)
   cPERI      := space(6)
   cPERF      := space(6)

   qmensa()

   // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; dbcloseall() ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   cPERIODO := right(cPERI,4)+left(cPERI,2)

   if ( i_inicializacao() , i_impressao() , NIL )

enddo

/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA _____________________________________________

static function i_critica ( cCAMPO )
   if XFLAG
      do case

         case cCAMPO == "MATRICULA"
              if empty(cMATRICULA)
                 qrsay(XNIVEL+1,"********* Todas as Matriculas *******")
                 return .T.
              endif
              FUN->(dbsetorder(1))
              qrsay(XNIVEL,cMATRICULA:=strzero(val(cMATRICULA),6))
              if ! FUN->(dbseek(cMATRICULA))
                 qmensa("Funcionario n„o Cadastrado !","B")
                 return .F.
              endif
              qrsay(XNIVEL+1,left(FUN->Nome,20))

         case cCAMPO == "FILIAL"
              if empty(cFILIAL)
                 qrsay(XNIVEL+1,"********** Todas as Filiais *********")
                 return .T.
              endif
              qrsay(XNIVEL,cFILIAL:=strzero(val(cFILIAL),4))
              if ! FILIAL->(dbseek(cFILIAL))
                 qmensa("Filial n„o Cadastrada !","B")
                 return .F.
              endif
              qrsay(XNIVEL+1,left(FILIAL->Razao,20))

         case cCAMPO == "ORDEM"

              if empty(cORDEM) ; return .F. ; endif
              qrsay(XNIVEL,qabrev(cORDEM,"12",{"Matr¡cula","Nome"}))

      endcase
   endif
return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

function i_inicializacao

   // CONSTROI VARIAVEL "cTITULO" __________________________________________

   cTITULO = "FICHA FINANCEIRA "

   cTITULO += " (" + subs(cPERI,1,2) + "/" + subs(cPERI,3,4) + " a " + ;
                     subs(cPERF,1,2) + "/" + subs(cPERF,3,4) + ")"

   qmensa()

   // ESTABELECE RELACOES ENTRE ARQUIVOS ____________________________________

   do case
      case cORDEM == "1" ; FUN->(dbsetorder(5)) // filial + matricula
      case cORDEM == "2" ; FUN->(dbsetorder(6)) // filial + nome
      FUN->(dbgotop())
   endcase

   do case

      case ! empty(cFILIAL) .and.   empty(cMATRICULA)
          FUN->(dbseek(cFILIAL))
          cCOND := "! FUN->(eof()) .and. FUN->Filial == cFILIAL"
      case   empty(cFILIAL) .and. ! empty(cMATRICULA)
          FUN->(dbsetorder(1))
          FUN->(dbseek(cMATRICULA))
          cCOND := "! FUN->(eof()) .and. FUN->Matricula == cMATRICULA"
      case ! empty(cFILIAL) .and. ! empty(cMATRICULA)
          FUN->(dbseek(cFILIAL+cMATRICULA))
          cCOND := "! FUN->(eof()) .and. FUN->Matricula == cMATRICULA .and. FUN->Filial == cFILIAL"
      case   empty(cFILIAL) .and.   empty(cMATRICULA)
          FUN->(dbgotop())
          cCOND := "! FUN->(eof())"

   endcase

   LANC->(dbsetorder(3)) // matricula + evento

   SITUA->(dbSetRelation("CARGO",{|| Cargo},"Cargo"))

   LANC->(dbSetRelation("EVENT",{|| Evento},"Evento"))

   BASE->(dbsetorder(1))

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

function i_impressao

   local nCONT := 0

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif

   @ prow(),pcol() say XCOND1

   do while &cCOND .and. qcontprn() // loop principal

      SITUA->(dbseek(FUN->Matricula))

      if FUN->Data_adm > qfimmes(XDATASYS)
         FUN->(dbskip())
         loop
      endif

      if ! qlineprn() ; return ; endif

      if XPAGINA == 0 .or. prow() > K_MAX_LIN
         qpageprn()
         qcabecprn(cTITULO,220)
      endif

      LANC->(dbgotop())

      if LANC->(Dbseek(FUN->Matricula))
         i_emite()
      endif

      FUN->(dbskip())

   enddo

   qstopprn(.F.)

return

/////////////////////////////////////////////////////////////////////////////
// EMITE FICHA FINANCEIRA  __________________________________________________

function i_emite

   local lACHOU  := .F.
   local cMATRICULA

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   aFUN := {{},{}}

   cANOMES :=  right(cPERI,4)+left(cPERI,2)

   do while ! LANC->(eof()) .and. LANC->Matricula == FUN->Matricula
      qgirabarra()
      qmensa("Aguarde - Analisando Lancamentos do Funcionario "+FUN->Matricula)
      if LANC->Valor <> 0.00 .and. left(LANC->Anomes,4) == right(cPERI,4)
         lACHOU := .t.
         aadd(aFUN[1],{LANC->Anomes,LANC->Evento,EVENT->Finalidade,left(EVENT->Descricao,34),LANC->Valor,LANC->Fracao} )
         if at(LANC->Evento,cEVEN) == 0
            cEVEN:=cEVEN + LANC->Evento + "*"
         endif
      endif
      LANC->(dbskip())
   enddo

   if lACHOU
      i_imp_sub_cabec()
      qmensa("Aguarde... Imprimindo dados do funcionario ...")
      i_imp_dados()
      qmensa("")
   endif

   lACHOU := .F.
   aFUN   := {{},{}}

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IMPRIMIR SUB CABECALHO DO FUNCIONARIO ________________________

function i_imp_sub_cabec

   if prow() > K_MAX_LIN
      qpageprn()
      qcabecprn(cTITULO,220)
   endif
   @ prow()+1,0      say "Matricula: " + FUN->Matricula + "    Nome: " + left(FUN->Nome,30)
   @ prow(),pcol()+3 say "Cargo: "     + padr(SITUA->Cargo,8) + CARGO->Descricao
   @ prow(),pcol()+3 say "Data Admimissao: "+dtoc(FUN->Data_adm)
   @ prow(),pcol()+3 say "C.T.P.S.: Nr."+FUN->Cp_num +" Serie: "+FUN->Cp_serie
   @ prow(),pcol()+3 say "R.G.: "+FUN->Idt_num
   @ prow()+1,0      say "C.P.F.: "+FUN->Cpf_num+"   Data Nascimento: "+dtoc(FUN->Data_nasc)
   @ prow(),pcol()+3 say "Situacao: "+SITUA->Situacao
   @ prow()+1,0      say "Filial: "+iif(FILIAL->(dbseek(FUN->Filial)), FILIAL->Razao , space(20) )
   @ prow()+1,0      say replicate("-",220)
   @ prow()+1,0      say "Eventos                                      Janeiro                  Fevereiro                      Marco                        Abril                       Maio                       Junho                     Total "
   @ prow()+1,0      say "                                        Valor      Fracao           Valor      Fracao          Valor       Fracao            Valor     Fracao            Valor     Fracao            Valor     Fracao"
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IMPRIMIR DADOS DE LANCAMENTO DO FUNCIONARIO __________________

function i_imp_dados

  local nMETADE
  local aEVENTOS := array(len(aFUN[1]))
  local aORDEM   := {}
  local nVAL1:=nVAL2:=nVAL3:=nVAL4:=nVAL5:=nVAL6:=nVAL7:=nVAL8:=nVAL9:=nVAL10:=nVAL11:=nVAL12:=0
  local nFRA1:=nFRA2:=nFRA3:=nFRA4:=nFRA5:=nFRA6:=nFRA7:=nFRA8:=nFRA9:=nFRA10:=nFRA11:=nFRA12:=0

  cFLAG := cEVEN
  qgirabarra()
  do while ! empty(cEVEN)
      cEVENT := left(cEVEN,3)
      for nCONT = 1 to len(aFUN[1])
          if right(aFUN[1][nCONT,1],2) > "06"  // aqui entra somente os vetores ate o mes 06
             nCONT := len(aFUN[1])
          endif
          do case
             case aFUN[1][nCONT,1] == right(cPERI,4)+"01" .and. aFUN[1][nCONT,2] == cEVENT
                  nVAL1:=nVAL1+aFUN[1][nCONT,5]
                  nFRA1:=nFRA1+aFUN[1][nCONT,6]
             case aFUN[1][nCONT,1] == right(cPERI,4)+"02" .and. aFUN[1][nCONT,2] == cEVENT
                  nVAL2:=nVAL2+aFUN[1][nCONT,5]
                  nFRA2:=nFRA2+aFUN[1][nCONT,6]
             case aFUN[1][nCONT,1] == right(cPERI,4)+"03" .and. aFUN[1][nCONT,2] == cEVENT
                  nVAL3:=nVAL3+aFUN[1][nCONT,5]
                  nFRA3:=nFRA3+aFUN[1][nCONT,6]
             case aFUN[1][nCONT,1] == right(cPERI,4)+"04" .and. aFUN[1][nCONT,2] == cEVENT
                  nVAL4:=nVAL4+aFUN[1][nCONT,5]
                  nFRA4:=nFRA4+aFUN[1][nCONT,6]
             case aFUN[1][nCONT,1] == right(cPERI,4)+"05" .and. aFUN[1][nCONT,2] == cEVENT
                  nVAL5:=nVAL5+aFUN[1][nCONT,5]
                  nFRA5:=nFRA5+aFUN[1][nCONT,6]
             case aFUN[1][nCONT,1] == right(cPERI,4)+"06" .and. aFUN[1][nCONT,2] == cEVENT
                  nVAL6:=nVAL6+aFUN[1][nCONT,5]
                  nFRA6:=nFRA6+aFUN[1][nCONT,6]
          endcase
      next
      if nVAL1 = 0 .and.  nVAL2 = 0 .and.  nVAL3 = 0 .and. nVAL4 = 0 .and. nVAL5 = 0 .and.  nVAL6 = 0
         // nao imprime
      else
         @ prow()+1 ,0 say cEVENT+"  "+iif( EVENT->(Dbseek(cEVENT)), left(EVENT->Descricao,20) , space(20) )
         @ prow(), 35 say transform(nVAL1,"@E 999,999.99")+"    "+ transform(nFRA1,"@E 999.9999") + "      " +;
                          transform(nVAL2,"@E 999,999.99")+"    "+ transform(nFRA2,"@E 999.9999") + "      " + ;
                          transform(nVAL3,"@E 999,999.99")+"    "+ transform(nFRA3,"@E 999.9999") + "      " + ;
                          transform(nVAL4,"@E 999,999.99")+"    "+ transform(nFRA4,"@E 999.9999") + "      " + ;
                          transform(nVAL5,"@E 999,999.99")+"    "+ transform(nFRA5,"@E 999.9999") + "      " + ;
                          transform(nVAL6,"@E 999,999.99")+"    "+ transform(nFRA6,"@E 999.9999") + "          " + ;
                          transform(nVAL1+nVAL2+nVAL3+nVAL4+nVAL5+nVAL6,"@E 999,999.99")
      endif
      nVAL1:=nVAL2:=nVAL3:=nVAL4:=nVAL5:=nVAL6:=nVAL7:=nVAL8:=nVAL9:=nVAL10:=nVAL11:=nVAL12:=0
      nFRA1:=nFRA2:=nFRA3:=nFRA4:=nFRA5:=nFRA6:=nFRA7:=nFRA8:=nFRA9:=nFRA10:=nFRA11:=nFRA12:=0
      cNUM := len(cEVEN)
      cEVEN := substr(cEVEN,5,cNUM)
  enddo

  nVAL1:=nVAL2:=nVAL3:=nVAL4:=nVAL5:=nVAL6:=nVAL7:=nVAL8:=nVAL9:=nVAL10:=nVAL11:=nVAL12:=0
  nFRA1:=nFRA2:=nFRA3:=nFRA4:=nFRA5:=nFRA6:=nFRA7:=nFRA8:=nFRA9:=nFRA10:=nFRA11:=nFRA12:=0
  @ prow()+1,0      say replicate("-",220)
  @ prow()+1,0      say "Salario   ... "
  cVAL:="Salario"
  soma_base1(cVAL)
  @ prow()+1,0      say "Proventos ... "
  cVAL:="Prov_ms"
  soma_base1(cVAL)
  @ prow()+1,0      say "Descontos ... "
  cVAL:="Desc_ms"
  soma_base1(cVAL)
  @ prow()+1,0      say "Base Irrf ... "
  cVAL:="B_Irrfms"
  soma_base1(cVAL)
  @ prow()+1,0      say "Base FGTS ... "
  cVAL:="B_Fgtsms"
  soma_base1(cVAL)

  cEVEN := cFLAG
  @ prow()+1,0      say replicate("-",220)
  @ prow()+1,0      say "Eventos                                      Julho                       Agosto                      Setembro                   Outrubro                    Novembro                     Dezembro"
  @ prow()+1,0      say "                                        Valor      Fracao            Valor     Fracao            Valor     Fracao            Valor     Fracao            Valor     Fracao            Valor     Fracao"
  do while ! empty(cEVEN)
      cEVENT := left(cEVEN,3)
      for nCONT = 1 to len(aFUN[1])
          do case
             case aFUN[1][nCONT,1] == right(cPERI,4)+"07" .and. aFUN[1][nCONT,2] == cEVENT
                  nVAL1:=nVAL1+aFUN[1][nCONT,5]
                  nFRA1:=nFRA1+aFUN[1][nCONT,6]
             case aFUN[1][nCONT,1] == right(cPERI,4)+"08" .and. aFUN[1][nCONT,2] == cEVENT
                  nVAL2:=nVAL2+aFUN[1][nCONT,5]
                  nFRA2:=nFRA2+aFUN[1][nCONT,6]
             case aFUN[1][nCONT,1] == right(cPERI,4)+"09" .and. aFUN[1][nCONT,2] == cEVENT
                  nVAL3:=nVAL3+aFUN[1][nCONT,5]
                  nFRA3:=nFRA3+aFUN[1][nCONT,6]
             case aFUN[1][nCONT,1] == right(cPERI,4)+"10" .and. aFUN[1][nCONT,2] == cEVENT
                  nVAL4:=nVAL4+aFUN[1][nCONT,5]
                  nFRA4:=nFRA4+aFUN[1][nCONT,6]
             case aFUN[1][nCONT,1] == right(cPERI,4)+"11" .and. aFUN[1][nCONT,2] == cEVENT
                  nVAL5:=nVAL5+aFUN[1][nCONT,5]
                  nFRA5:=nFRA5+aFUN[1][nCONT,6]
             case aFUN[1][nCONT,1] == right(cPERI,4)+"12" .and. aFUN[1][nCONT,2] == cEVENT
                  nVAL6:=nVAL6+aFUN[1][nCONT,5]
                  nFRA6:=nFRA6+aFUN[1][nCONT,6]
          endcase
      next
      if nVAL1 = 0 .and.  nVAL2 = 0 .and.  nVAL3 = 0 .and. nVAL4 = 0 .and. nVAL5 = 0 .and.  nVAL6 = 0
         // nao imprime
      else
         @ prow()+1 ,0 say cEVENT+"  "+iif( EVENT->(Dbseek(cEVENT)), left(EVENT->Descricao,20) , space(20) )
         @ prow(), 35 say transform(nVAL1,"@E 999,999.99")+"    "+ transform(nFRA1,"@E 999.9999") + "      " +;
                          transform(nVAL2,"@E 999,999.99")+"    "+ transform(nFRA2,"@E 999.9999") + "      " + ;
                          transform(nVAL3,"@E 999,999.99")+"    "+ transform(nFRA3,"@E 999.9999") + "      " + ;
                          transform(nVAL4,"@E 999,999.99")+"    "+ transform(nFRA4,"@E 999.9999") + "      " + ;
                          transform(nVAL5,"@E 999,999.99")+"    "+ transform(nFRA5,"@E 999.9999") + "      " + ;
                          transform(nVAL6,"@E 999,999.99")+"    "+ transform(nFRA6,"@E 999.9999") + "          " + ;
                          transform(nVAL1+nVAL2+nVAL3+nVAL4+nVAL5+nVAL6,"@E 999,999.99")
      endif
      nVAL1:=nVAL2:=nVAL3:=nVAL4:=nVAL5:=nVAL6:=nVAL7:=nVAL8:=nVAL9:=nVAL10:=nVAL11:=nVAL12:=0
      nFRA1:=nFRA2:=nFRA3:=nFRA4:=nFRA5:=nFRA6:=nFRA7:=nFRA8:=nFRA9:=nFRA10:=nFRA11:=nFRA12:=0
      cNUM := len(cEVEN)
      cEVEN := substr(cEVEN,5,cNUM)
  enddo
  @ prow()+1,0      say replicate("-",220)
  @ prow()+1,0      say "Salarios  ... "
  cVAL:="Salario"
  soma_base2(cVAL)
  @ prow()+1,0      say "Proventos ... "
  cVAL:="Prov_ms"
  soma_base2(cVAL)
  @ prow()+1,0      say "Descontos ... "
  cVAL:="Desc_ms"
  soma_base2(cVAL)
  @ prow()+1,0      say "Base Irrf ... "
  cVAL:="B_Irrfms"
  soma_base2(cVAL)
  @ prow()+1,0      say "Base FGTS ... "
  cVAL:="B_Fgtsms"
  soma_base2(cVAL)
  eject

return

function soma_base1(cVAL)
  for nCONT = 1 to 6
      if BASE->( dbseek(FUN->Matricula+left(cANOMES,4)+strzero(nCONT,2)))
         do case
            case nCONT = 1
               @ prow(),35 say transform(BASE->&cVAL,"@E 999,999.99")
            case nCONT = 2
               @ prow(),63 say transform(BASE->&cVAL,"@E 999,999.99")
            case nCONT = 3
               @ prow(),91 say transform(BASE->&cVAL,"@E 999,999.99")
            case nCONT = 4
               @ prow(),119 say transform(BASE->&cVAL,"@E 999,999.99")
            case nCONT = 5
               @ prow(),147 say transform(BASE->&cVAL,"@E 999,999.99")
            case nCONT = 6
               @ prow(),175 say transform(BASE->&cVAL,"@E 999,999.99")
         endcase
      else
         do case
            case nCONT = 1
               @ prow(),41 say "0,00"
            case nCONT = 2
               @ prow(),69 say "0,00"
            case nCONT = 3
               @ prow(),97 say "0,00"
            case nCONT = 4
               @ prow(),125 say "0,00"
            case nCONT = 5
               @ prow(),153 say "0,00"
            case nCONT = 6
               @ prow(),181 say "0,00"
         endcase
      endif
  next
return

function soma_base2(cVAL)
  for nCONT = 7 to 12
      if BASE->( dbseek(FUN->Matricula+left(cANOMES,4)+strzero(nCONT,2)))
         do case
            case nCONT = 7
               @ prow(),35 say transform(BASE->&cVAL,"@E 999,999.99")
            case nCONT = 8
               @ prow(),63 say transform(BASE->&cVAL,"@E 999,999.99")
            case nCONT = 9
               @ prow(),91 say transform(BASE->&cVAL,"@E 999,999.99")
            case nCONT = 10
               @ prow(),119 say transform(BASE->&cVAL,"@E 999,999.99")
            case nCONT = 11
               @ prow(),147 say transform(BASE->&cVAL,"@E 999,999.99")
            case nCONT = 12
               @ prow(),175 say transform(BASE->&cVAL,"@E 999,999.99")
         endcase
      else
         do case
            case nCONT = 7
               @ prow(),41 say "0,00"
            case nCONT = 8
               @ prow(),69 say "0,00"
            case nCONT = 9
               @ prow(),97 say "0,00"
            case nCONT = 10
               @ prow(),125 say "0,00"
            case nCONT = 11
               @ prow(),153 say "0,00"
            case nCONT = 12
               @ prow(),181 say "0,00"
         endcase

      endif
  next
return

