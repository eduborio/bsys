/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: FOLHA DE PAGAMENTO
// OBJETIVO...: RELATORIO GFIP
// ANALISTA...: LUCINEIDE VILAR POSSEBOM
// PROGRAMADOR: A MESMA
// INICIO.....: NOVEMBRO  DE 1998
// OBS........:
// ALTERACOES.:

#include "rh.ch"

#define K_MAX_LIN 45

/////////////////////////////////////////////////////////////////////////////
// DECLARACAO E INICIALIZACAO DE VARIAVEIS E RELACAO DE ARQUIVOS ____________

local bESCAPE    := {||(XNIVEL==1 .and. !XFLAG) .or. lastkey()==27}

private cANOMES  := qanomes(XDATASYS)
private cPIC     := "999"
private nCOD_REC := "115"
private nCONT_PG := 0
private nPAG_TOT := 0
private nFUNC    := 0
private cFILIAL  := "0001"
private cCENTRO  := space(8)
private lACHOU   := .F.
private nCAM_37  := 0
private nCAM_38  := 0
private nCAM_39  := 0
private nCAM_17  := 0
private nCAM_18  := 0
private nCAM_19  := 0
private nCAM_20  := 0
private nCAM_21  := 0
private nCAM_22  := 0
private nCAM_40  := 0
private nCAM_41  := 0
private nLIN     := 0
private nPROLABO := 0
private nSALARIO
private nDECIMO
private nAUTO    := 0
Public nMENOS    := 0

private sBLOC1   := qlbloc("B572A","QBLOC.GLO")
private sBLOC2   := qlbloc("B572B","QBLOC.GLO")
private sBLOC3   := qlbloc("B572C","QBLOC.GLO")

private cTIPOAMB             // Tipo de Impressao
private cTIPOREL             // Tipo de Impressao
private aEDICAO  := {}       // vetor para os campos de entrada de dados
private nADT13

private aLINHA := {}
private cCAM_01 := ""
private cCAM_02 := ""
private cCAM_03 := ""
private cCAM_04 := ""
private cCAM_05 := 0
private cCAM_06 := 0
private cCAM_07 := ""
private cCAM_08 := ""
private cCAM_09 := ""
private cCAM_10 := ""
private cCAM_11 := ""
private cCAM_12 := ""

SITUA->(dbSetFilter({|| Anomes == XANOMES},"Anomes == XANOMES"))
//GRPS->(dbSetFilter({|| Anomes == XANOMES},"Anomes == XANOMES"))
BASE->(dbSetFilter({|| Anomes == XANOMES},"Anomes == XANOMES"))
LANC->(dbsetorder(1))  // anomes + matricula + ambiente + evento

//SITUA->(dbSetRelation("FUN",{|| Matricula},"Matricula"))

// CRIACAO DO VETOR DE BLOCOS ____________________________________________________

aadd(aEDICAO,{{ || qesco(-1,0,@cTIPOREL,sBLOC2      )}, "TIPOREL" })
aadd(aEDICAO,{{ || qesco(-1,0,@cTIPOAMB,sBLOC3      )}, "TIPOAMB" })
aadd(aEDICAO,{{ || view_gfip(-1,0,@nCOD_REC,cPIC    )}, "COD_REC" })
aadd(aEDICAO,{{ || qgetx(-1,0,@nAUTO,"@R 999,999.99")}, "AUTO"    }) // valor para autonomos
aadd(aEDICAO,{{ || view_filial(-1,0,@cFILIAL        )}, "FILIAL"  })
aadd(aEDICAO,{{ || NIL                               }, NIL       }) // descricao da filial
aadd(aEDICAO,{{ || view_ccusto(-1,0,@cCENTRO        )}, "CENTRO"  })
aadd(aEDICAO,{{ || NIL                               }, NIL       }) // descricao do centro de custo

do while .T.

   qlbloc(5,0,"B572A","QBLOC.GLO")
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
           qrsay(XNIVEL,qabrev(cTIPOREL,"12",{"Modelo 1","Cont¡nuo"}))
      case cCAMPO == "TIPOAMB"
           if empty(cTIPOAMB) ; return .F. ; endif
           qrsay(XNIVEL,qabrev(cTIPOAMB,"MDFT",{"Mensal","D‚cimo Terceiro","F‚rias","Todos"}))
       case cCAMPO == "COD_REC"
            if empty(nCOD_REC) ; return .F. ; endif
            if !COD_GFIP->(dbseek(nCOD_REC))
               qmensa("Codigo n„o encontrado, campo obrigat¢rio!","B")
               return .F.
            Endif
       case cCAMPO == "FILIAL"
            if ! empty(cFILIAL)
               if ! FILIAL->(dbseek(cFILIAL))
                  qmensa("Filial n„o Cadastrado !!","B")
                  return .F.
               endif
            endif
            qrsay(XNIVEL+1,Left(FILIAL->Razao,30))
//            qrsay(XNIVEL+1,iif(FILIAL->(dbseek(cFILIAL)),left(FILIAL->Razao,30),"*** Todas as Filial ***"))
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

    FUN->(dbSetFilter({|| Situacao <> 'H' .and. FUN->Data_adm < qfimmes(XDATASYS) .and. i_filia1()},;
                         "Situacao <> 'H' .and. FUN->Data_adm < qfimmes(XDATASYS) .and. i_filia1()"))

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

return

////////////////////////////////////////////////////////////////////////////
// FUNCAO AUXILIAR PARA FILTRO DE FILIAL ___________________________________

function i_filia1
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
       local aSLINHA := {}
       private nSOMA1 := nSOMA2 := nCAM_31 := nCAM_32 := 0
    
       if ! qinitprn() ; return ; endif


       FUN->(dbgotop())
       
       if cTIPOREL == "2"

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

//             if FUN->Data_adm >= qinimes(XDATASYS) .and. FUN->Data_adm <= qfimmes(XDATASYS)
             if FUN->Data_adm <= qfimmes(XDATASYS)
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

          @ prow()+2,90 say "Totais: " + transform(nSOMA1,"@E 999,999,999.99") + "   " + transform(nSOMA2,"@E 999,999,999.99") + XCOND0

          qstopprn(.f.)

       else

          do while ! GRPS->(eof()) .and. qcontprn()

             if GRPS->Anomes <> XANOMES
                GRPS->(dbskip())
                loop
             endif

             FUN->(dbsetorder(10)) // codigo da GRPS
             FUN->(dbgotop())
             FUN->(dbseek(GRPS->Codigo))
             SITUA->(dbseek(FUN->Matricula))

             if FUN->(eof()) .or. SITUA->Ccusto <> cCENTRO
                 GRPS->(dbskip())
                 loop
             endif

             do while ! FUN->(eof()) .and. FUN->Grps == GRPS->Codigo

                SITUA->(dbseek(FUN->Matricula))

                if ! empty(cCENTRO) .and. SITUA->Ccusto <> cCENTRO
                   FUN->(Dbskip())
                   loop
                endif

                  if (SITUA->Categoria == "9" .and. SITUA->Vinculo == "H")
                     FUN->(dbskip())
                     loop
                  endif

                if FUN->Data_adm <= qfimmes(XDATASYS)
                   i_lin1()
                elseif SITUA->Vinculo <> K_DIRETOR  // DIRETORES NAO ENTRAM NA R.E. !
                   i_lin1()
                endif

                qgirabarra()

                FUN->(dbskip())

             enddo

   //////// classificacao do array para impressao em ordem de categoria

             aSLINHA := aSORT(aLINHA,,,{|x,y| x[4] < y[4] })

             for i:= 1 to len(aSLINHA)

                 if XPAGINA == 0 .or. nFUNC == 26
                    if XPAGINA > 0
                       @ prow()+2,0  say " "
                       @ prow()+1,70  say transform(nCAM_37 ,"@E 999,999,999.99") + space(14) + transform(nCAM_38 ,"@E 999,999,999.99") + "       " + Transform(nCAM_39,"@E 999")
                       @ prow()  ,130 say transform((nCAM_40),"@E 999,999.99")
                       @ prow()  ,185 say transform((((nCAM_40+nCAM_41))*0.08),"@E 999,999.99")
                       @ prow()+8,00 say ""
                       nMENOS:= 0
                    endif
                    nFUNC := nSOMA1 := nSOMA2 := 0
                    nCAM_37 := nCAM_38 := nCAM_39 := nCAM_40 := 0
                    setprc(0,0)
                    XPAGINA++
                    i_cab1()
                    nLIN := 0
                 endif

                 @ prow()+1,5   say aSLINHA[i,1]
                 @ prow()  ,24  say aSLINHA[i,2]
                 @ prow()  ,42  say aSLINHA[i,3]
                 @ prow()  ,60  say aSLINHA[i,4]
                 @ prow()  ,70  say transform(aSLINHA[i,5],"@E 9,999,999.99")
                 @ prow()  ,95  say transform(aSLINHA[i,6],"@E 9,999,999.99")
                 @ prow()  ,120 say aSLINHA[i,7]
                 @ prow()  ,126 say aSLINHA[i,8]
                 @ prow()  ,177 say aSLINHA[i,9]
                 @ prow()  ,191 say aSLINHA[i,10]
                 @ prow()  ,197 say aSLINHA[i,11]

                 nCAM_37 += aSLINHA[i,5]
                 nCAM_38 += aSLINHA[i,6]
                 nCAM_39 += val(aSLINHA[i,7])
                 if aSLINHA[i,4] $ "1*2*3*5"
                    if aSLINHA[i,11] <> "S"
                       nCAM_40 += (aSLINHA[i,5] + aSLINHA[i,6])
                    endif
                 elseif aSLINHA[i,4] == "4"
                    if aSLINHA[i,11] <> "S"
                       nCAM_41 += ( aSLINHA[i,5] + aSLINHA[i,6] )
                    endif
                 endif

                 nFUNC++
                 nLIN++

             next

             nRESTO := 26 - nLIN
             for nCONT := 1 to nRESTO
                 @ prow()+1,0 say ""
             next

             @ prow()+2,0   say " "
             @ prow()+1,70  say transform(nCAM_37 ,"@E 999,999,999.99") + space(14) + transform(nCAM_38 ,"@E 999,999,999.99") + "       " + Transform(nCAM_39,"@E 999")
             @ prow()  ,130 say transform((nCAM_40),"@E 999,999.99")
             @ prow()  ,185 say transform((((nCAM_40+nCAM_41))*0.08),"@E 999,999.99")

             @ prow()+8,00 say ""
             nMENOS:= 0
             nCAM_37 := nCAM_38 := nCAM_39 := nCAM_40 := 0

             GRPS->(dbskip())

             aLINHA  := aSLINHA := {}
             nFUNC   := 0
             XPAGINA := 0

          enddo

          qstopprn(.f.)

       endif

return

/////////////////////////////////////////////////////////////////////////////
// CABECALHO PRINCIPAL ______________________________________________________

static function i_cabec

   if XPAGINA == 0 .or. prow() > K_MAX_LIN
      qpageprn()
      @ prow(),pcol() say XCOND0
      qcabecprn("RELACAO DE EMPREGADOS PARA O FGTS-MENSAL",80)

      // POSICIONA ARQUIVO CGM EM RELACAO A CIDADE DA EMPRESA _____________________

      CGM->(dbseek(FILIAL->CGM))

      @ prow()+1,0 say XCOND1

      if XPAGINA = 1
         @ prow()  ,0 say "Razao Social                                           CGC                       Endereco"
         @ prow()+1,0 say left(FILIAL->Razao,50) + space(5) + transform(FILIAL->CGCCPF,"@E 99.999.999/9999-99")  + space(8) + FILIAL->ENDERECO + " " + str(FILIAL->Numero,5) + " " + alltrim(FILIAL->Compl)
         @ prow()+1,0 say FILIAL->Razao + space(5) + transform(FILIAL->CGCCPF,"@E 99.999.999/9999-99")  + space(8) + FILIAL->ENDERECO + " " + str(FILIAL->Numero,5) + " " + alltrim(FILIAL->Compl)
         @ prow()+2,0 say "Bairro                    Cidade                              UF       CEP           Telefone"
         @ prow()+1,0 say FILIAL->BAIRRO + space(6) + CGM->Municipio + space(6) + CGM->Estado + space(7) + transform(FILIAL->CEP,"@E 99999-999") + space(5) + FILIAL->TELEFONE
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

//   BASE->(dbseek(FUN->Matricula + cANOMES))
   BASE->(dbseek(FUN->Matricula))

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

//   if FUN->Situacao != "F"
   if FUN->Situacao != "H"
      AFAST->(dbseek(SITUA->Af_cod))
      @ prow(),pcol()+1 say iif(AFAST->Retorno!="S",dtoc(SITUA->Af_ini),"  /  /    ")
      @ prow(),pcol()+2 say AFAST->Cod_re
   else
      @ prow(),pcol()+1 say "  /  /    "
   endif

   do case
      case cTIPOAMB == "T"
//         nSOMA1 += BASE->V_fgtsms + BASE->V_fgtsfr
           nSOMA1 +=nSALARIO + nPROLABO
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

if cTIPOAMB == "D"
   cDATA_COMP := "13/" + left(cANOMES,4)
else
   cDATA_COMP := (right(cANOMES,2) + "/" + left(cANOMES,4))
endif

   // POSICIONA ARQUIVO CGM EM RELACAO A CIDADE DA EMPRESA _____________________

   CGM->(dbseek(FILIAL->CGM))

   @ prow(),pcol() say XCOND1
   @ prow()  ,145  say ""          //XCGCCPF
   @ prow()+1,144  say Space(34)   //left(XRAZAO,34)
   @ prow()+1,144  say Space(33)   //left(XENDERECO,20) + " " + XNUMERO + " " + left(XCOMPL,7)
   @ prow()  ,200  say cDATA_COMP
   @ prow()+1,144  say ""          //XCEP
   @ prow()+1,144  say Space(23)   //left(CGM->Municipio,20) + " " + CGM->Estado
   @ prow()  ,200  say nCOD_REC

   @ prow()+2,001  say left(FILIAL->RAZAO,50)
   @ prow()  ,072  say left(XCONTATO,10) + " " + FILIAL->TELEFONE
   @ prow()  ,115  say Transform(FILIAL->CGCCPF,"@R 99.999.999/9999-99")

   @ prow()+2,001  say left(FILIAL->ENDERECO,30) + " " + StrZero(FILIAL->NUMERO,5) + " " + left(FILIAL->COMPL,10)
   @ prow()  ,090  say left(FILIAL->BAIRRO,20)
   @ prow()  ,125  say Transform(FILIAL->CEP,"@R 99999-999")
   @ prow()  ,142  say left(CGM->Municipio,20)
   @ prow()  ,177  say CGM->Estado

   @ prow()+2,005  say GRPS->Cod_fpas
   @ prow()  ,017  say GRPS->Cod_terc
   @ prow()  ,030  say iif(CONFIG->Gr_simples=="N","01","02")   //iif(CONFIG->Gr_simples=="N","NAO","SIM")


// if GRPS->(dbseek(cANOMES))
      if CONFIG->Gr_simples=="N"
         @ prow()  ,038  say GRPS->Perc_acid
      else
         @ prow()  ,038 say ""
      endif
      FUN->(dbsetorder(10))
      FUN->(dbgotop())
      FUN->(dbseek(GRPS->Codigo))
      do while ! FUN->(eof()) .and. FUN->Grps == GRPS->Codigo
         SITUA->(dbseek(FUN->Matricula))
         if ! empty(cCENTRO) .and. SITUA->Ccusto <> cCENTRO // calcula de centros de custo separados
            FUN->(Dbskip())
            loop
         endif
         if BASE->(dbseek(FUN->Matricula + cANOMES))
            if BASE->V_inssms + BASE->V_inssfr + BASE->V_inss13 + BASE->V_inssdt <> 0.00
               if SITUA->Af_cod <> "22"
                  if CONFIG->Gr_simples=="S"
                     nCAM_17+=BASE->V_inssms + BASE->V_inssfr + BASE->V_inss13 + BASE->V_inssdt
                     nCAM_18+=BASE->V_inssms + BASE->V_inssfr + BASE->V_inss13 + BASE->V_inssdt
                  else
                    nBASE:=(BASE->T_inssms + BASE->T_inssfr + BASE->T_inssdt + BASE->T_inss13)
                    nPERC:=((GRPS->Perc_empr + GRPS->Perc_acid + GRPS->Perc_terc)/100)
                    nTOTEMP := nBASE * nPERC
                    nCAM_17+=BASE->V_inssms + BASE->V_inssfr + BASE->V_inss13 + BASE->V_inssdt + nTOTEMP
                    nCAM_18+=BASE->V_inssms + BASE->V_inssfr + BASE->V_inss13 + BASE->V_inssdt
                  endif
               endif
            endif
         endif
         FUN->(dbskip())
      enddo
// else
//    GRPS->(dbgobottom())
//    if CONFIG->Gr_simples=="N"
//       @ prow()  ,038  say GRPS->Perc_acid
//    else
//       @ prow()  ,038 say ""
//    endif
//    do while !FUN->(eof())
//       SITUA->(dbseek(FUN->Matricula))
//       if BASE->(dbseek(FUN->Matricula + cANOMES))
//          if BASE->V_inssms + BASE->V_inssfr + BASE->V_inss13 + BASE->V_inssdt <> 0.00
//             if SITUA->Af_cod <> "22"
//                if CONFIG->Gr_simples=="S"
//                   nCAM_17+=BASE->V_inssms + BASE->V_inssfr + BASE->V_inss13 + BASE->V_inssdt
//                   nCAM_18+=BASE->V_inssms + BASE->V_inssfr + BASE->V_inss13 + BASE->V_inssdt
//                else
//                  nBASE:=(BASE->T_inssms + BASE->T_inssfr + BASE->T_inssdt + BASE->T_inss13)
//                  nPERC:=((GRPS->Perc_empr + GRPS->Perc_acid + GRPS->Perc_terc)/100)
//                  nTOTEMP := nBASE * nPERC
//                  nCAM_17+=BASE->V_inssms + BASE->V_inssfr + BASE->V_inss13 + BASE->V_inssdt + nTOTEMP
//                  nCAM_18+=BASE->V_inssms + BASE->V_inssfr + BASE->V_inss13 + BASE->V_inssdt
//                endif
//             endif
//          endif
//       endif
//       FUN->(dbskip())
//    enddo
// endif

   @ prow()  ,056  say CONFIG->Cnae

   LANC->(dbsetorder(2)) // anomes + evento
   LANC->(dbSetFilter({|| Anomes == XANOMES},"Anomes == XANOMES"))
   LANC->(Dbgotop())
// LANC->(dbseek(FUN->Matricula))

   nMATER := 0 // salario maternidade para deducao no campo 17

   do while ! LANC->(eof())

      qgirabarra()

      if LANC->Anomes <> XANOMES
         LANC->(dbskip())
         loop
      endif

      if LANC->Evento $ "901"
         SITUA->(dbseek(LANC->Matricula))
         if SITUA->Af_cod <> "22"
            nCAM_19 += LANC->Valor
         endif
      endif

      if LANC->Evento $ "161"
         SITUA->(dbseek(LANC->Matricula))
         nMATER += LANC->Valor
      endif

      LANC->(Dbskip())

   enddo

   nVAL := 0
   if nAUTO <> 0
      nVAL := nAUTO * (GRPS->Perc_auto/100)
   endif

   nCAM_17 := ( ((nCAM_17 + (nMENOS*(GRPS->Perc_prol/100))) - nCAM_19) - nMATER ) + nVAL // (soma 15% pro-labore) e diminui o salario familia se houver e soma autonomos se houver
   
   @ prow()+2,05  say transform(nCAM_17,"@E 9,999,999,999.99")
   @ prow()  ,33  say transform(nCAM_18,"@E 9,999,999,999.99")
   @ prow()  ,58  say transform(nCAM_19,"@E 9,999,999,999.99")
   @ prow()  ,84  say transform(nCAM_20,"@E 9,999,999,999.99")
   @ prow()  ,110 say transform(nCAM_21,"@E 9,999,999,999.99")
   @ prow()  ,135 say transform(nCAM_22,"@E 9,999,999,999.99")
   @ prow()  ,160 say transform(nCAM_17+nCAM_18+nCAM_19+nCAM_20+nCAM_21+nCAM_22,"@R 9,999,999,999.99")

   @ prow()+2,0 say ""

   nCAM_17  := 0
   nCAM_18  := 0
   nCAM_19  := 0
   nCAM_20  := 0
   nCAM_21  := 0
   nCAM_22  := 0

   LANC->(Dbsetfilter())
   LANC->(Dbsetorder(1))
   LANC->(dbgotop())

return

/////////////////////////////////////////////////////////////////////////////
// IMPRESSAO DA LINHA DE DADOS PARA PRE-IMPRESSO MODELO 1 ___________________

   function i_lin1

   local cPIC1 := "@R 9,999,999.99"

   cCAM_01 := ""
   cCAM_02 := ""
   cCAM_03 := ""
   cCAM_04 := ""
   cCAM_05 := 0
   cCAM_06 := 0
   cCAM_07 := ""
   cCAM_08 := ""
   cCAM_09 := ""
   cCAM_10 := ""
   cCAM_11 := ""
   cCAM_12 := ""

   SITUA->(dbseek(FUN->Matricula))

   if SITUA->Vinculo == "G"
      LANC->(dbsetorder(1))  // anomes + matricula + ambiente + evento
      if ! LANC->(dbseek(cANOMES + SITUA->Matricula + "MS500"))
         return
      endif
   endif

   cCAM_01 := FUN->Pis_num
   cCAM_02 := dtoc(FUN->Data_adm)
   cCAM_03 := FUN->Cp_num +"/"+FUN->Cp_serie

   LANC->(Dbsetorder(1))

   nSALARIO := 0
   nPROLABO := 0
   vTEST := .T.

   if BASE->(dbseek(FUN->Matricula))
      nSALARIO += BASE->B_Fgtsms + BASE->B_Fgtsfr
   endif

   nDECIMO := 0

   if BASE->(dbseek(FUN->Matricula))
      nDECIMO += BASE->B_Fgts13 + BASE->B_Fgtsdt
   endif

   if SITUA->Situacao $ "D*A"

      if SITUA->Af_cod == "22"
         nDECIMO := 0
         nSALARIO := 0
      endif
      if SITUA->Af_cod == "06" .or. SITUA->Af_cod == "21"
         if SITUA->Af_cod == "21"
            //nSALARIO := 0 // codigo 21 nao imprime salario e a categoria ‚ 1
            cCAM_04 := "1"
         else
         endif
         if SITUA->Af_cod == "06"
            cCAM_04 := "3"
         endif
      else
         do case
            case SITUA->Vinculo == "G"
                 LANC->(dbsetorder(1))  // anomes + matricula + ambiente + evento
                 if LANC->(dbseek(cANOMES + SITUA->Matricula + "MS500"))
                    nPROLABO := LANC->Valor
                    cCAM_04 := "2"
                    cCAM_05 := nPROLABO
                    cCAM_12 := "S"
                    vTEST := .F.
                 Endif
                 if vTEST
                    cCAM_04 := "2"
                 Endif
            case SITUA->Vinculo $ "I*J*K*L"
                 cCAM_04 := "4"
            case SITUA->Vinculo == "M"
                 cCAM_04 := "5"
            case SITUA->Vinculo == "N"

                 LANC->(dbsetorder(1))  // anomes + matricula + ambiente + evento

                 cCAM_04 := "11"

                 if LANC->(dbseek(cANOMES + SITUA->Matricula + "MS105"))
                    nPROLABO := LANC->Valor
                    cCAM_12 := "S"
                    vTEST := .F.
                 elseif LANC->(dbseek(cANOMES + SITUA->Matricula + "MS106"))
                    nPROLABO := LANC->Valor
                    cCAM_12 := "S"
                    vTEST := .F.
                 endif
                 cCAM_05 := nPROLABO

            otherwise
                 cCAM_04 := "1"
         endcase
      endif
   else
      do case
         case SITUA->Vinculo == "G"
              LANC->(dbsetorder(1))  // anomes + matricula + ambiente + evento
              if LANC->(dbseek(cANOMES + SITUA->Matricula + "MS500"))
                 nPROLABO := LANC->Valor
                 cCAM_04 := "2"
                 cCAM_05 := nPROLABO
                 cCAM_12 := "S"
                 vTEST := .F.
              Endif
              if vTEST
                 cCAM_04 := "2"
              Endif
         case SITUA->Vinculo $ "I*J*K*L"
              cCAM_04 := "4"
         case SITUA->Vinculo == "M"
              cCAM_04 := "5"
         case SITUA->Vinculo == "N"
              LANC->(dbsetorder(1))  // anomes + matricula + ambiente + evento
              cCAM_04 := "11"
              if LANC->(dbseek(cANOMES + SITUA->Matricula + "MS105"))
                 nPROLABO := LANC->Valor
                 vTEST := .F.
                 cCAM_12 := "S"
              elseif LANC->(dbseek(cANOMES + SITUA->Matricula + "MS106"))
                 nPROLABO := LANC->Valor
                 cCAM_12 := "S"
                 vTEST := .F.
              endif
              cCAM_05 := nPROLABO

         otherwise
              cCAM_04 := "1"
      endcase
   endif

   if vTEST
      cCAM_05 := nSALARIO
   endif

   nSOMA1 +=  BASE->SALARIO + nPROLABO             // totalizador por pagina impressa
   nMENOS += nPROLABO

   cCAM_06 := nDECIMO

   nSOMA2  += nDECIMO      // totalizador por pagina
   if SITUA->(dbseek(FUN->Matricula))
      if CARGO->(dbseek(SITUA->Cargo))
         cCAM_07 := StrZero(Val(CARGO->Especifica),2)
      else
         cCAM_07 := "01"
      endif
   else
         cCAM_07 := "01"
   endif

   cCAM_08 := left(FUN->Nome,35)

   AFAST->(dbseek(SITUA->Af_cod))

   if SITUA->Af_ini <> Ctod(Space(8)) .and. SITUA->Af_ret < Date()
      cCAM_09 := iif(SITUA->Situacao <> "F",dtoc(SITUA->Af_ini),"  /  /  ")
      cCAM_10 := iif(SITUA->Situacao <> "F",AFAST->Cod_re,"")
   elseif SITUA->Af_ret <> Ctod(Space(8)) .and. SITUA->Af_ret >= Date()
      cCAM_09 := iif(SITUA->Situacao <> "F",dtoc(SITUA->Af_ini),"  /  /  ")
      cCAM_10 := iif(SITUA->Situacao <> "F",AFAST->Cod_re,"")
   endif

   cCAM_11 := dtoc(FUN->Data_nasc)

   aadd(aLINHA,{cCAM_01,cCAM_02,cCAM_03,cCAM_04,cCAM_05,cCAM_06,cCAM_07,cCAM_08,cCAM_09,cCAM_10,cCAM_11,cCAM_12})

return
