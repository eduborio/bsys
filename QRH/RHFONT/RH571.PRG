/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: FOLHA DE PAGAMENTO
// OBJETIVO...: RELATORIO DE R.E. DO FGTS
// ANALISTA...: CARLOS EDUARDO RABELLO NUNES
// PROGRAMADOR: O MESMO
// INICIO.....: MARCO DE 1995
// OBS........:
// ALTERACOES.:

#include "rh.ch"

#define K_MAX_LIN 45

/////////////////////////////////////////////////////////////////////////////
// DECLARACAO E INICIALIZACAO DE VARIAVEIS E RELACAO DE ARQUIVOS ____________

local bESCAPE    := {||(XNIVEL==1 .and. !XFLAG) .or. lastkey()==27}

private cANOMES  := qanomes(XDATASYS)
private cPIC     := "999"
private nCOD_REC := "116"
private nCONT_PG := 0
private nPAG_TOT := 0
private nFUNC    := 0
private cFILIAL  := "0001"
private cCENTRO  := space(8)
private cTIT     := space(30)
private lACHOU   := .F.

private sBLOC1   := qlbloc("B571A","QBLOC.GLO")
private sBLOC2   := qlbloc("B571B","QBLOC.GLO")
private sBLOC3   := qlbloc("B571C","QBLOC.GLO")

private cTIPOAMB             // Tipo de Impressao
private cTIPOREL             // Tipo de Impressao
private aEDICAO  := {}       // vetor para os campos de entrada de dados
private nADT13

SITUA->(dbSetFilter({|| Anomes == XANOMES},"Anomes == XANOMES"))
GRPS->(dbSetFilter({|| Anomes == XANOMES},"Anomes == XANOMES"))

// CRIACAO DO VETOR DE BLOCOS ____________________________________________________

aadd(aEDICAO,{{ || qesco(-1,0,@cTIPOREL,sBLOC2)}    , "TIPOREL"  })
aadd(aEDICAO,{{ || qesco(-1,0,@cTIPOAMB,sBLOC3)}    , "TIPOAMB"  })
aadd(aEDICAO,{{ || qgetx(-1,0,@nCOD_REC,cPIC  )}    , "COD_REC"  })
aadd(aEDICAO,{{ || view_filial(-1,0,@cFILIAL  )}    , "FILIAL"   })
aadd(aEDICAO,{{ || NIL },NIL}) // descricao do filial
aadd(aEDICAO,{{ || view_ccusto(-1,0,@cCENTRO  )}    , "CENTRO"   })
aadd(aEDICAO,{{ || NIL },NIL}) // descricao do centro de custo

do while .T.

   qlbloc(5,0,"B571A","QBLOC.GLO")
   qmensa()
   XNIVEL   := 1
   cTIPOREL := "1"
   cTIPOAMB := "T"
   nPAG_TOT := 0
   nCONT_PG := 0
   cFILIAL  := "0001"
   cCENTRO  := space(8)

   // SEGUNDO LOOP PARA ENTRADA DOS DADOS ________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; dbcloseall() ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   qmensa()
   i_inicializa()
   i_impressao()

enddo

//////////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA __________________________________________________

static function i_critica ( cCAMPO )
    do case
      case cCAMPO == "TIPOREL"
           if empty(cTIPOREL) ; return .F. ; endif
           qrsay(XNIVEL,qabrev(cTIPOREL,"123",{"Modelo 1","Modelo 2","Cont¡nuo"}))
      case cCAMPO == "TIPOAMB"
           if empty(cTIPOAMB) ; return .F. ; endif
           qrsay(XNIVEL,qabrev(cTIPOAMB,"MDFT",{"Mensal","D‚cimo Terceiro","F‚rias","Todos"}))
       case cCAMPO == "COD_REC"
            if empty(nCOD_REC) ; return .F. ; endif
       case cCAMPO == "FILIAL"
            if ! empty(cFILIAL)
//             if empty(right(cFILIAL,4))
//                qmensa("Filial n„o encontrado !!","B")
//                return .F.
//             endif
               if ! FILIAL->(dbseek(cFILIAL))
                  qmensa("Filial n„o Cadastrado !!","B")
                  return .F.
               endif
            endif
            qrsay(XNIVEL+1,iif(FILIAL->(dbseek(cFILIAL)),left(FILIAL->Razao,30),"*** Todas as Filial ***"))
       case cCAMPO == "CENTRO"
            if ! empty(cCENTRO)
               if ! CCUSTO->(dbseek(cCENTRO))
                  qmensa("Centro de Custo n„o Cadastrado !!","B")
                  return .F.
               endif
            endif
            qrsay(XNIVEL+1,iif(CCUSTO->(dbseek(cCENTRO)),left(CCUSTO->Descricao,30),"*** Todos os Centros ***"))

    endcase
return .T.

////////////////////////////////////////////////////////////////////////////
// FUNCAO PRINCIPAL DE INICIALIZACAO _______________________________________

static function i_inicializa

    FUN->(dbsetorder(2))       // INDEXADO POR NOME

//  FUN->(dbSetFilter({|| Situacao <> 'H' .and. FUN->Data_adm < qfimmes(XDATASYS) .and. i_filial() .and. i_centro()},;
//                       "Situacao <> 'H' .and. FUN->Data_adm < qfimmes(XDATASYS) .and. i_filial() .and. i_centro()"))
    FUN->(dbSetFilter({|| Situacao <> 'H' .and. FUN->Data_adm < qfimmes(XDATASYS) .and. i_filial()},;
                         "Situacao <> 'H' .and. FUN->Data_adm < qfimmes(XDATASYS) .and. i_filial()"))

    FUN->(dbgotop())

    do while ! FUN->(eof())

       SITUA->(dbseek(FUN->Matricula))

       if ! empty(cCENTRO) .and. SITUA->Ccusto <> cCENTRO
          FUN->(Dbskip())
          loop
       endif

       if SITUA->Vinculo = K_DIRETOR .or. (SITUA->Categoria == "9" .and. SITUA->Vinculo == "H") .or. ;
                                                                     FUN->Data_adm > qfimmes(XDATASYS)
          // nao faz nada. apenas para constar
       else
          if BASE->(dbseek(FUN->Matricula + cANOMES))
             do case
                case cTIPOAMB == "T"
                     if BASE->V_fgtsms + BASE->V_fgtsfr + BASE->V_fgts13 + BASE->V_fgtsdt != 0.00
                        lACHOU := .T.
                        nCONT_PG++
                     endif
                case cTIPOAMB == "F"
                     if BASE->V_fgtsfr != 0.00
                        lACHOU := .T.
                        nCONT_PG++
                     endif
                case cTIPOAMB == "M"
                     if BASE->V_fgtsms != 0.00
                        lACHOU := .T.
                        nCONT_PG++
                     endif
                case cTIPOAMB == "D"
                     if BASE->V_fgts13 + BASE->V_fgtsdt != 0.00
                        lACHOU := .T.
                        nCONT_PG++
                     endif
             endcase
          endif
       endif

       FUN->(dbskip())

    enddo

    nPAG_TOT2 := nCONT_PG / 29
    nPAG_TOT1 := int(nCONT_PG / 29)
    nDIFEREN  := nPAG_TOT2 - nPAG_TOT1
    nPAG_TOT  := nPAG_TOT1
    if nDIFEREN <> 0
       nPAG_TOT := 0
       nPAG_TOT := nPAG_TOT1 + 1
    endif
    cTIT := left(CCUSTO->Descricao,25)
return

////////////////////////////////////////////////////////////////////////////
// FUNCAO AUXILIAR PARA FILTRO DE FILIAL ___________________________________

function i_filial
   if empty(cFILIAL) .or. FUN->Filial == cFILIAL
      return .T.
   endif
return .F.

////////////////////////////////////////////////////////////////////////////
// FUNCAO AUXILIAR PARA FILTRO DE CENTRO DE CUSTO __________________________

//function i_centro
//   if empty(cCENTRO) .or. FUN->Centro == cCENTRO
//      return .T.
//   endif
//return .F.

////////////////////////////////////////////////////////////////////////////
// FUNCAO PRINCIPAL DE IMPRESSAO ___________________________________________

static function i_impressao

       local aADM := {}, nCONT
       private nSOMA1 := nSOMA2 := 0

       if ! qinitprn() ; return ; endif

       FUN->(dbgotop())
       
       if cTIPOREL == "3"

          do while ! FUN->(eof()) .and. qcontprn()

             SITUA->(dbseek(FUN->Matricula))
             
             if ! empty(cCENTRO) .and. SITUA->Ccusto <> cCENTRO
                FUN->(Dbskip())
                loop
             endif

             if ! qlineprn() ; return ; endif

             i_cabec()

             if BASE->(dbseek(FUN->Matricula + cANOMES))
                do case
                   case cTIPOAMB == "T"
                        if BASE->V_fgtsms + BASE->V_fgtsfr + BASE->V_fgts13 + BASE->V_fgtsdt == 0.00
                           FUN->(dbskip())
                           loop
                        endif
                   case cTIPOAMB == "M"
                        if BASE->V_fgtsms == 0.00
                           FUN->(dbskip())
                           loop
                        endif
                   case cTIPOAMB == "F"
                        if BASE->V_fgtsfr == 0.00
                           FUN->(dbskip())
                           loop
                        endif
                   case cTIPOAMB == "D"
                        if BASE->V_fgts13 + BASE->V_fgtsdt == 0.00
                           FUN->(dbskip())
                           loop
                        endif
                endcase
             endif

             if (SITUA->Categoria == "9" .and. SITUA->Vinculo == "H")
                FUN->(dbskip())
                loop
             endif

             if FUN->Data_adm >= qinimes(XDATASYS) .and. FUN->Data_adm <= qfimmes(XDATASYS)
                aadd(aADM,FUN->(recno()))
             elseif SITUA->Vinculo <> K_DIRETOR
                i_linha()
             endif

             FUN->(dbskip())

          enddo

          if ! empty(aADM) .and. qcontprn()
             @ prow()+2,0 say "Admitidos neste mes:"
             @ prow()+1,0 say ""
          endif

          for nCONT := 1 to len(aADM)

             if ! qlineprn() ; return ; endif

             i_cabec()

             FUN->(dbgoto(aADM[nCONT]))

             if SITUA->Vinculo <> K_DIRETOR
                i_linha()
             endif

          next

          @ prow()+2,90 say "Totais: " + transform(nSOMA1,"@E 999,999.99") + "   " + transform(nSOMA2,"@E 999,999.99") + XCOND0

          qstopprn()

       else
       
          do while ! FUN->(eof()) .and. qcontprn()

             SITUA->(dbseek(FUN->Matricula))

             if ! empty(cCENTRO) .and. SITUA->Ccusto <> cCENTRO
                FUN->(Dbskip())
                loop
             endif

             if BASE->(dbseek(FUN->Matricula + cANOMES))
                do case
                   case cTIPOAMB == "T"
                        if BASE->V_fgtsms + BASE->V_fgtsfr + BASE->V_fgts13 + BASE->V_fgtsdt == 0.00
                           FUN->(dbskip())
                           loop
                        endif
                   case cTIPOAMB == "M"
                        if BASE->V_fgtsms == 0.00
                           FUN->(dbskip())
                           loop
                        endif
                   case cTIPOAMB == "F"
                        if BASE->V_fgtsfr == 0.00
                           FUN->(dbskip())
                           loop
                        endif
                   case cTIPOAMB == "D"
                        if BASE->V_fgts13 + BASE->V_fgtsdt == 0.00
                           FUN->(dbskip())
                           loop
                        endif
                endcase
             endif

             if (SITUA->Categoria == "9" .and. SITUA->Vinculo == "H")
                FUN->(dbskip())
                loop
             endif
             
             if XPAGINA == 0 .or. nFUNC == 29
                if XPAGINA > 0
                   @ prow()+(46-prow()),22 say transform(nSOMA1,"@E 999,999.99") + space(15) + transform(nSOMA2,"@E 999,999.99") + ;
                                                                          space(65) + transform(nSOMA1 + nSOMA2,"@E 999,999.99")
                   @ prow()+5,00 say ""
                endif
                nFUNC := nSOMA1 := nSOMA2 := 0
                setprc(0,0)
                XPAGINA++

                do case
                   case cTIPOREL == "1"
                        i_cab1()
                   case cTIPOREL == "2"
                        i_cab2()
                endcase

             endif

             if FUN->Data_adm >= qinimes(XDATASYS) .and. FUN->Data_adm <= qfimmes(XDATASYS)
                aadd(aADM,FUN->(recno()))
             elseif SITUA->Vinculo <> K_DIRETOR  // DIRETORES NAO ENTRAM NA R.E. !

                do case
                   case cTIPOREL == "1"
                        i_lin1()
                   case cTIPOREL == "2"
                        i_lin2()
                endcase

             endif

             qgirabarra()

             FUN->(dbskip())

          enddo

          for nCONT := 1 to len(aADM)

             if ! qlineprn() ; return ; endif

             if XPAGINA == 0 .or. nFUNC == 29
                if XPAGINA > 0
                   @ prow()+(46-prow()),22 say transform(nSOMA1,"@E 999,999.99") + space(15) + transform(nSOMA2,"@E 999,999.99") + ;
                                                                          space(65) + transform(nSOMA1 + nSOMA2,"@E 999,999.99")
                   @ prow()+5,00 say ""
                endif
                nFUNC := nSOMA1 := nSOMA2 := 0
                setprc(0,0)

                do case
                   case cTIPOREL == "1"
                        i_cab1()
                   case cTIPOREL == "2"
                        i_cab2()
                endcase

             endif
             
             FUN->(dbgoto(aADM[nCONT]))
             SITUA->(dbseek(FUN->Matricula))

             if SITUA->Vinculo <> K_DIRETOR  // DIRETORES NAO ENTRAM NA R.E. !

                do case
                   case cTIPOREL == "1"
                        i_lin1()
                   case cTIPOREL == "2"
                        i_lin2()
                endcase

             endif
          
          next

          if lACHOU
             @ prow()+(46-prow()),22 say transform(nSOMA1,"@E 999,999.99") + space(15) + transform(nSOMA2,"@E 999,999.99") + ;
                                                                    space(65) + transform(nSOMA1 + nSOMA2,"@E 999,999.99")
             @ prow()+5,00 say ""
          endif

          nSOMA1 := nSOMA2 := 0
          
          qstopprn(.F.)

       endif
return

/////////////////////////////////////////////////////////////////////////////
// CABECALHO PRINCIPAL ______________________________________________________

static function i_cabec

   if XPAGINA == 0 .or. prow() > K_MAX_LIN
      qpageprn()
      @ prow(),pcol() say XCOND0
      qcabecprn("EMPREGADOS PARA O FGTS-MENSAL - "+cTIT,80)

      // POSICIONA ARQUIVO CGM EM RELACAO A CIDADE DA EMPRESA _____________________

      CGM->(dbseek(FILIAL->CGM))

      @ prow()+1,0 say XCOND1

      if XPAGINA = 1
         @ prow()  ,0 say "Razao Social                                           CGC                       Endereco"
         @ prow()+1,0 say left(FILIAL->Razao,50) + space(5) + transform(FILIAL->CGCCPF,"@R 99.999.999/9999-99")  + space(8) + FILIAL->ENDERECO + " " + str(FILIAL->Numero,5) + " " + alltrim(FILIAL->Compl)
         @ prow()+1,0 say FILIAL->Razao + space(5) + transform(FILIAL->CGCCPF,"@R 99.999.999/9999-99")  + space(8) + FILIAL->ENDERECO + " " + str(FILIAL->Numero,5) + " " + alltrim(FILIAL->Compl)
         @ prow()+2,0 say "Bairro                    Cidade                              UF       CEP           Telefone"
         @ prow()+1,0 say FILIAL->BAIRRO + space(6) + CGM->Municipio + space(6) + CGM->Estado + space(7) + transform(FILIAL->CEP,"@R 99999-999") + space(5) + FILIAL->TELEFONE
         @ prow()+1,0 say replicate("-",137)
         @ prow()+1,0 say ""
      endif

      @ prow()+1,0 say "Nome do Funcionario               Nascim.     Num.Pis     Admissao   C.Pro   Serie    Num.Conta  Dep. Mensal  Dep. 13 Sal   D.Afast. Cod"
      @ prow()+1,0 say replicate("-",137)
   endif
return

/////////////////////////////////////////////////////////////////////////////
// IMPRESSAO DA LINHA DE DADOS ______________________________________________

static function i_linha
   @ prow()+1,0      say left(FUN->Nome,30)
   @ prow(),pcol()+3 say FUN->Data_nasc
   @ prow(),pcol()+1 say FUN->Pis_num
   @ prow(),pcol()+1 say FUN->Data_adm
   @ prow(),pcol()+3 say FUN->Cp_num
   @ prow(),pcol()+3 say FUN->Cp_serie
   @ prow(),pcol()+3 say FUN->Fgts_num

   BASE->(dbseek(FUN->Matricula + cANOMES))

   do case
      case cTIPOAMB == "T"
           @ prow(),pcol()+3 say transform(BASE->V_fgtsms + BASE->V_fgtsfr,"@E 999,999.99")
           @ prow(),pcol()+3 say transform(BASE->V_fgts13 + BASE->V_fgtsdt,"@E 999,999.99")
      case cTIPOAMB == "M"
           @ prow(),pcol()+3 say transform(BASE->V_fgtsms ,"@E 999,999.99")
           @ prow(),pcol()+3 say transform(0,"@E 999,999.99")
      case cTIPOAMB == "F"
           @ prow(),pcol()+3 say transform(BASE->V_fgtsfr,"@E 999,999.99")
           @ prow(),pcol()+3 say transform(0,"@E 999,999.99")
      case cTIPOAMB == "D"
           @ prow(),pcol()+3 say transform(0,"@E 999,999.99")
           @ prow(),pcol()+3 say transform(BASE->V_fgts13 + BASE->V_fgtsdt,"@E 999,999.99")
   endcase

   if FUN->Situacao != "F"
      AFAST->(dbseek(SITUA->Af_cod))
      @ prow(),pcol()+1 say iif(AFAST->Retorno!="S",dtoc(SITUA->Af_ini),"  /  /    ")
      @ prow(),pcol()+2 say AFAST->Cod_re
   else
      @ prow(),pcol()+1 say "  /  /    "
   endif

   do case
      case cTIPOAMB == "T"
           nSOMA1 += BASE->V_fgtsms + BASE->V_fgtsfr
           nSOMA2 += BASE->V_fgts13 + BASE->V_fgtsdt
      case cTIPOAMB == "M"
           nSOMA1 += BASE->V_fgtsms
      case cTIPOAMB == "F"
           nSOMA1 += BASE->V_fgtsfr
      case cTIPOAMB == "D"
           nSOMA2 += BASE->V_fgts13 + BASE->V_fgtsdt
   endcase
return

/////////////////////////////////////////////////////////////////////////////
// CABECALHO PRINCIPAL PARA PRE-IMPRESSO MODELO 1 ______________________________

static function i_cab1

   local cDATA_COMP := (right(cANOMES,2) + "/" + left(cANOMES,4))

   // POSICIONA ARQUIVO CGM EM RELACAO A CIDADE DA EMPRESA _____________________

   CGM->(dbseek(FILIAL->CGM))

   @ prow(),pcol() say XCOND0
   @ prow()+3,096  say XCOND1 + XAEXPAN + transform(FILIAL->CGCCPF,"@R 99.999.999/9999-99") + XDEXPAN
   @ prow()+1,001  say left(FILIAL->RAZAO,50) + space(42) + transform(FILIAL->CGCCPF,"@R 99.999.999/9999-99") + space(53) + left(FILIAL->RAZAO,36)
   @ prow()+1,164  say SUBST(FILIAL->RAZAO,37,15)
//   @ prow()+1,162  say SUBST(FILIAL->Razao,15)
   @ prow()+1,001  say FILIAL->ENDERECO + " " + str(FILIAL->Numero,5) + " " + FILIAL->Compl + space(12) + FILIAL->BAIRRO +  space(63) + left(FILIAL->ENDERECO,25) + " " + str(FILIAL->Numero,5) + " " + left(FILIAL->Compl,9) + space(7) + cDATA_COMP
   @ prow()+1,164  say right(FILIAL->ENDERECO,15)
   @ prow()+1,001  say CGM->Municipio + space(63) + CGM->Estado + space(8) + transform(FILIAL->CEP,"@R 99999-999") + space(51) + ;
                                                                   alltrim(CGM->Municipio) +  space(5) + CGM->Estado
   @ prow()  ,212  say transform(nCOD_REC,cPIC)
   @ prow()+1,164  say transform(FILIAL->CEP,"@R 99999-999")
   @ prow()+1,001  say FILIAL->TELEFONE + space(11) + CONFIG->Cnae + space(21) + GRPS->Cod_sat + space(152) + ;
   strzero(XPAGINA,2) + "/" + strzero(nPAG_TOT,2)
   @ prow()+2,170  say FILIAL->Codigo
   @ prow()+3,001  say ""

return

/////////////////////////////////////////////////////////////////////////////
// IMPRESSAO DA LINHA DE DADOS PARA PRE-IMPRESSO MODELO 1 ___________________

static function i_lin1

   local cPIC1 := "@E 9,999,999.99"
   local cCOD      // Busca sobre primeiro emprego, reemprego ou trabalhador do outro estabelecimento

   if FUN->Prim_adm == "S"
      cCOD := "A"
   else
      if SITUA->Transf == "S"
         cCOD := "C"
      else
         cCOD := "B"
      endif
   endif

   @ prow()+1,0       say left(FUN->Nome,30)
   @ prow(),pcol()+31 say FUN->Data_nasc
   @ prow(),pcol()+9  say FUN->Pis_num
   @ prow(),pcol()+7  say FUN->Data_adm
   @ prow(),pcol()+5  say "9" + cCOD
   @ prow(),pcol()+6  say FUN->Cp_num
   @ prow(),pcol()+5  say FUN->Cp_serie

   BASE->(dbseek(FUN->Matricula + cANOMES))

   do case
      case cTIPOAMB == "T"
           @ prow(),pcol()+10 say transform(BASE->V_fgtsms + BASE->V_fgtsfr,cPIC1)
           @ prow(),pcol()+12 say transform(BASE->V_fgts13 + BASE->V_fgtsdt,cPIC1)
      case cTIPOAMB == "M"
           @ prow(),pcol()+10 say transform(BASE->V_fgtsms ,cPIC1)
           @ prow(),pcol()+12 say transform(0,cPIC1)
      case cTIPOAMB == "F"
           @ prow(),pcol()+10 say transform(BASE->V_fgtsfr,cPIC1)
           @ prow(),pcol()+12 say transform(0,cPIC1)
      case cTIPOAMB == "D"
           @ prow(),pcol()+10 say transform(0,cPIC1)
           @ prow(),pcol()+12 say transform(BASE->V_fgts13 + BASE->V_fgtsdt,cPIC1)
   endcase

   if FUN->Situacao != "F"
      AFAST->(dbseek(SITUA->Af_cod))
      @ prow(),pcol()+26 say iif(AFAST->Retorno!="S",dtoc(SITUA->Af_ini),"  /  /    ")
      @ prow(),pcol()+5  say AFAST->Cod_re
   else
      @ prow(),pcol()+26 say "  /  /    "
   endif

   do case
      case cTIPOAMB == "T"
           nSOMA1 += BASE->V_fgtsms + BASE->V_fgtsfr
           nSOMA2 += BASE->V_fgts13 + BASE->V_fgtsdt
      case cTIPOAMB == "M"
           nSOMA1 += BASE->V_fgtsms
      case cTIPOAMB == "F"
           nSOMA1 += BASE->V_fgtsfr
      case cTIPOAMB == "D"
           nSOMA2 += BASE->V_fgts13 + BASE->V_fgtsdt

   endcase

   setprc()

   nFUNC++

return

/////////////////////////////////////////////////////////////////////////////
// CABECALHO PRINCIPAL PARA PRE-IMPRESSO MODELO 2 ______________________________

static function i_cab2

   local cDATA_COMP := (right(cANOMES,2) + "/" + left(cANOMES,4))

   // POSICIONA ARQUIVO CGM EM RELACAO A CIDADE DA EMPRESA _____________________

   CGM->(dbseek(FILIAL->CGM))

   @ prow(),pcol() say XCOND0
   @ prow()+3,097  say XCOND1 + XAEXPAN + transform(FILIAL->CGCCPF,"@R 99.999.999/9999-99") + XDEXPAN
   @ prow()+1,001  say left(FILIAL->RAZAO,50) + space(41) + transform(FILIAL->CGCCPF,"@R 99.999.999/9999-99") + space(56) + left(FILIAL->RAZAO,35)
   @ prow()+1,001  say FILIAL->Razao + space(41) + transform(FILIAL->CGCCPF,"@R 99.999.999/9999-99") + space(56) + left(FILIAL->Razao,35)
   @ prow()+1,162  say SUBST(FILIAL->Razao,36,15)
   @ prow()+1,162  say SUBST(FILIAL->Razao,36,15)
   @ prow()+1,001  say FILIAL->ENDERECO + str(FILIAL->Numero,5) + " " + FILIAL->Compl + space(2) + FILIAL->BAIRRO +  space(66) + left(FILIAL->ENDERECO,30) + " " + str(FILIAL->Numero,5) + " " + left(FILIAL->Compl,9) + cDATA_COMP
   @ prow()+1,166  say right(FILIAL->ENDERECO,15)
   @ prow()+1,001  say CGM->Municipio + space(65) + CGM->Estado + space(8) + transform(FILIAL->CEP,"@R 99999-999") + space(51) + ;
                                                                   alltrim(CGM->Municipio) +  space(5) + CGM->Estado
   @ prow()  ,211  say transform(nCOD_REC,cPIC)
   @ prow()+1,166  say transform(FILIAL->CEP,"@R 99999-999")
   @ prow()+1,001  say FILIAL->TELEFONE + space(11) + CONFIG->Cnae + space(20) + GRPS->Cod_sat + space(153) + ;
   strzero(XPAGINA,2) + "/" + strzero(nPAG_TOT,2)
   @ prow()+2,170  say FILIAL->Codigo
   @ prow()+2,170  say FILIAL->Codigo
   @ prow()+3,001  say ""

return

/////////////////////////////////////////////////////////////////////////////
// IMPRESSAO DA LINHA DE DADOS PARA PRE-IMPRESSO MODELO 2 ___________________

static function i_lin2

   local cPIC1 := "@E 9,999,999.99"
   local cCOD      // Busca sobre primeiro emprego, reemprego ou trabalhador do outro estabelecimento

   if FUN->Prim_adm == "S"
      cCOD := "A"
   else
      if SITUA->Transf == "S"
         cCOD := "C"
      else
         cCOD := "B"
      endif
   endif

   @ prow()+1,0       say left(FUN->Nome,30)
   @ prow(),pcol()+33 say FUN->Data_nasc
   @ prow(),pcol()+9  say FUN->Pis_num
   @ prow(),pcol()+9  say FUN->Data_adm
   @ prow(),pcol()+4  say "9" + cCOD
   @ prow(),pcol()+6  say FUN->Cp_num
   @ prow(),pcol()+5  say FUN->Cp_serie

   BASE->(dbseek(FUN->Matricula + cANOMES))

   do case
      case cTIPOAMB == "T"
           @ prow(),pcol()+10 say transform(BASE->V_fgtsms + BASE->V_fgtsfr,cPIC1)
           @ prow(),pcol()+10 say transform(BASE->V_fgts13 + BASE->V_fgtsdt,cPIC1)
      case cTIPOAMB == "M"
           @ prow(),pcol()+10 say transform(BASE->V_fgtsms,cPIC1)
           @ prow(),pcol()+10 say transform(0,cPIC1)
      case cTIPOAMB == "F"
           @ prow(),pcol()+10 say transform(BASE->V_fgtsfr,cPIC1)
           @ prow(),pcol()+10 say transform(0,cPIC1)
      case cTIPOAMB == "D"
           @ prow(),pcol()+10 say transform(0,cPIC1)
           @ prow(),pcol()+10 say transform(BASE->V_fgts13 + BASE->V_fgtsdt,cPIC1)
   endcase

   if FUN->Situacao != "F"
      AFAST->(dbseek(SITUA->Af_cod))
      @ prow(),pcol()+33 say iif(AFAST->Retorno!="S",dtoc(SITUA->Af_ini),"  /  /    ")
      @ prow(),pcol()+6  say AFAST->Cod_re
   else
      @ prow(),pcol()+33 say "  /  /    "
   endif

   do case
      case cTIPOAMB == "T"
           nSOMA1 += BASE->V_fgtsms + BASE->V_fgtsfr
           nSOMA2 += BASE->V_fgts13 + BASE->V_fgtsdt
      case cTIPOAMB == "M"
           nSOMA1 += BASE->V_fgtsms
      case cTIPOAMB == "F"
           nSOMA1 += BASE->V_fgtsfr
      case cTIPOAMB == "D"
           nSOMA2 += BASE->V_fgts13 + BASE->V_fgtsdt
   endcase

   setprc()

   nFUNC++

return
