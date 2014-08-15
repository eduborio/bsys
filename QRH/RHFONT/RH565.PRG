/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: FOLHA DE PAGAMENTO
// OBJETIVO...: EMISSAO DE CONTRA-CHEQUES PADRAO
// ANALISTA...: CARLOS EDUARDO RABELLO NUNES
// PROGRAMADOR: O MESMO
// INICIO.....: SETEMBRO DE 1994
// OBS........:
// ALTERACOES.:

#define K_MAX_LIN 52

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG) .or. empty(cTIPOREL)}

private sBLOCO1 := qlbloc("B521A","QBLOC.GLO") // bloco basico
private sBLOCO2 := qlbloc("B521B","QBLOC.GLO") // tipo de relatorio
private sBLOCO3 := qlbloc("B521C","QBLOC.GLO") // ordem de impressao

private cTIPOREL               // tipo de relatorio (mensal ou 13o.)
private cTITULO                // titulo do contra-cheque
private cORDEM := "1"          // ordem de impressao (matricula/nome)
private cMATRICULA             // matricula p/ impressao individual
private cGRUPO                 // grupo de funcionarios
private cFILIAL                // filial para filtro
private cCENTRO                // centro de custo para filtro
private bFILTRO                // code block de filtro (centro/filial/grupo)
private aEDICAO := {}          // vetor para os campos de entrada de dados
private cMENSA1 := CONFIG->Mcc1
private cMENSA2 := CONFIG->Mcc2
private cMENSA3
private cNASC
private nQUANT_IMP

SITUA->(dbSetFilter({|| Anomes == XANOMES},"Anomes == XANOMES"))

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qesco(-1,0,@cTIPOREL,sBLOCO2) }   , "TIPOREL"   })
aadd(aEDICAO,{{ || qesco(-1,0,@cORDEM  ,sBLOCO3) }   , "ORDEM"     })
aadd(aEDICAO,{{ || view_fun(-1,0,@cMATRICULA)}       , "MATRICULA" })
aadd(aEDICAO,{{ || NIL },NIL}) // nome do funcionario
aadd(aEDICAO,{{ || view_grupoc(-1,0,@cGRUPO)}        , "GRUPO"     })
aadd(aEDICAO,{{ || NIL },NIL}) // descricao do centro
aadd(aEDICAO,{{ || view_filia(-1,0,@cFILIAL)}        , "FILIAL"    })
aadd(aEDICAO,{{ || NIL },NIL}) // descricao do filial
aadd(aEDICAO,{{ || view_ccusto(-1,0,@cCENTRO)}       , "CENTRO"    })
aadd(aEDICAO,{{ || NIL },NIL}) // descricao do centro
aadd(aEDICAO,{{ || qgetx(-1,0,@cMENSA1)            } , "MENSA1"    })
aadd(aEDICAO,{{ || qgetx(-1,0,@cMENSA2)            } , "MENSA2"    })

do while .T.

   qlbloc(5,0,"B521A","QBLOC.GLO")
   XNIVEL     := 1
   XFLAG      := .T.
   cMATRICULA := space(6)
   cFILIAL    := space(4)
   cCENTRO    := space(8)
   cGRUPO     := space(4)
   cTIPOREL   := " "
   nQUANT_IMP := 0

   qrsay(11,cMENSA1)
   qrsay(12,cMENSA2)

   qmensa()

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
      case cCAMPO == "TIPOREL"
           if empty(cTIPOREL) ; return .F. ; endif
           qrsay(XNIVEL,qabrev(cTIPOREL,"MAD",{"Mˆs Corrente","Adiantamento","D‚cimo Terceiro"}))
      case cCAMPO == "MATRICULA"
           if ! empty(cMATRICULA)
              qrsay(XNIVEL,cMATRICULA:=strzero(val(cMATRICULA),6))
           endif
           qrsay(XNIVEL+1,iif(FUN->(dbseek(cMATRICULA)),left(FUN->Nome,30),"*** Todos os Funcion rios ***"))
      case cCAMPO == "FILIAL"
           qrsay(XNIVEL+1,iif(FILIAL->(dbseek(cFILIAL)),left(FILIAL->Razao,40),"*** Todas as Filiais ***"))
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
      case cCAMPO == "GRUPO"
           if empty(cGRUPO)
              qrsay(XNIVEL+1,"*** N„o usar Grupo ***")
           else
              if ! GRUPOC->(dbseek(cGRUPO))
                 qmensa("Grupo n„o encontrado...","B")
                 return .F.
              else
                 qrsay(XNIVEL+1,GRUPOC->Descricao)
              endif
           endif
      case cCAMPO == "ORDEM"
           if empty(cORDEM) ; return .F. ; endif
           qrsay(XNIVEL,qabrev(cORDEM,"123456",{"Matr¡cula","Nome","Centro+Matr¡cula","Centro+Nome","Filial+Depto+Matr¡c","Filial+Depto+Nome"}))
   endcase
return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // CONSTROI VARIAVEL "cTITULO" __________________________________________

   cTIPOREL := qabrev(cTIPOREL,"MAD",{"MS","AD","DT"})
   cTITULO = "CONTRA-CHEQUE "

   do case
      case cTIPOREL == "MS" ; cTITULO += "MENSAL"
      case cTIPOREL == "AD" ; cTITULO += "DE ADIANTAMENTO"
      case cTIPOREL == "DT" ; cTITULO += "DE 13. SALARIO"
   endcase

   cTITULO += " - " + upper(qnomemes(month(XDATASYS))) + "/" + str(year(XDATASYS),4)

   // SELECIONA ORDEM DO ARQUIVO CADFUN _____________________________________

   do case
      case cORDEM == "1" ; FUN->(dbsetorder(01)) // matricula
      case cORDEM == "2" ; FUN->(dbsetorder(02)) // nome
      case cORDEM == "3" ; FUN->(dbsetorder(07)) // centro + matricula
      case cORDEM == "4" ; FUN->(dbsetorder(08)) // centro + nome
      case cORDEM == "5" ; FUN->(dbsetorder(03)) // filial + depto + matricula
      case cORDEM == "6" ; FUN->(dbsetorder(04)) // local  + Depto + nome
   endcase

   qmensa()

   // CRIA MACRO DE FILTRO __________________________________________________

   do case
      case ! empty(cCENTRO)
//         bFILTRO := { || FUN->Centro == cCENTRO }
           bFILTRO := { || SITUA->Ccusto == cCENTRO }
      case ! empty(cFILIAL)
           bFILTRO := { || FUN->Filial == cFILIAL }
      case ! empty(cGRUPO)
           bFILTRO := { || GRUPOV->(dbseek(cGRUPO+FUN->Matricula)) }
      otherwise
           bFILTRO := { || .T. }
   endcase

   // ESTABELECE RELACOES ENTRE ARQUIVOS ____________________________________

   SITUA->(dbsetrelation("BASE",{|| Matricula+XANOMES},"Matricula+XANOMES"))

   SITUA->(dbsetrelation("CARGO",{|| Cargo},"Cargo"))

   SITUA->(dbsetrelation("LANC",{|| XANOMES+Matricula+cTIPOREL},"XANOMES+Matricula+cTIPOREL"))

   LANC->(dbsetrelation("EVENT",{|| Evento},"Evento"))

   FUN->(dbsetrelation("CCUSTO",{|| Centro},"Centro"))
   
   FUN->(dbsetrelation("FILIAL",{|| Filial},"Filial"))

   FUN->(dbgotop())
   
   // GRAVA MENSAGENS NO CONFIG _____________________________________________

   if CONFIG->(qrlock())
      replace CONFIG->Mcc1 with cMENSA1
      replace CONFIG->Mcc2 with cMENSA2
      CONFIG->(qunlock())
   endif

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impressao

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif

   if ! empty(cMATRICULA)
      FUN->(dbsetorder(1))
      FUN->(dbseek(cMATRICULA))
   endif

   do while ! FUN->(eof()) .and. qcontprn()  // condicao principal de loop

      qgirabarra()

      if FUN->Situacao == "H"
         FUN->(dbskip())
         loop
      endif

      SITUA->(dbseek(FUN->Matricula))

      do case
//       case cORDEM $ "12" ; qmensa("Imprimindo Centro: "+transform(FUN->Centro,"@R 99.99.9999")+" / Matricula: "+FUN->Matricula)
         case cORDEM $ "12" ; qmensa("Imprimindo Centro: "+transform(SITUA->Ccusto,"@R 99.99.9999")+" / Matricula: "+FUN->Matricula)
         case cORDEM $ "34" ; qmensa("Imprimindo Filial: "+FUN->Filial+" / Matricula: "+FUN->Matricula)
      endcase

      if ! qlineprn() ; return ; endif

      if ! FUN->Situacao $ "DH" .and. eval(bFILTRO) .and. FUN->Data_adm < qfimmes(XDATASYS)
         do case
            case CONFIG->Tipo_cc $ " -1"
                 i_impcc1()   // contra-cheque PADRAO
            case CONFIG->Tipo_cc $ "2"
*                 i_impcc2()   // contra-cheque SANTA CRUZ
            case CONFIG->Tipo_cc $ "3"
*                 i_impcc3()   // contra-cheque CRC
            case CONFIG->Tipo_cc $ "4"
*                 i_impcc4()   // recibo de pagamento
         endcase
      endif

      FUN->(dbskip())

      if ! empty(cMATRICULA) ; exit ; endif

   enddo

   qstopprn(.F.)

return

/////////////////////////////////////////////////////////////////////////////
// EMITE CONTRA-CHEQUE PADRAO _______________________________________________
// funcao criada em 01/2000 para atender especificacoes da YES

static function i_impcc1
   local cMACROP, cMACROD, nCONT, zTMP, nLINHA := 15
   local cFLAG := .T.
   local aLIN  := {}
   local aNOME := {}
   local cNOME := ''

   cMACROP := "BASE->Prov_" + cTIPOREL
   cMACROD := "BASE->Desc_" + cTIPOREL

   if &cMACROP. == 0 .and. &cMACROD. == 0 ; return ; endif

   do while LANC->Anomes == XANOMES .and. LANC->Matricula == FUN->Matricula .and. FUN->Situacao <> 'H'.and. LANC->Ambiente == cTIPOREL .and. qcontprn()
      if EVENT->Finalidade $ "PD" .and. LANC->Valor <> 0
         aadd(aLIN,"")
         aadd(aNOME,"")
         aLIN[len(aLIN)]   += str(LANC->Valor)
         aNOME[len(aLIN)]  += left(FUN->Nome,30)
      endif
      LANC->(dbskip())
   enddo


   FUN->(dbskip())
   LANC->(dbseek(XANOMES+FUN->Matricula+"AD"+"701"))

   nVALOR = 0

   do while LANC->Anomes == XANOMES .and. LANC->Matricula == FUN->Matricula .and. FUN->Situacao <> 'H'.and. LANC->Ambiente == cTIPOREL .and. qcontprn()
      nVALOR = LANC->Valor
      cNOME  = FUN->Nome
      LANC->(dbskip())
   enddo



   aLIN := asort(aLIN)

   for nCONT := 1 to len(aLIN)

       if cFLAG
          @ prow()  ,00   say XCOND0
          @ prow()+1,00   say '|' + replicate("-",37) + "|"
          @ prow()  ,41   say '|' + replicate("-",37) + "|"
          @ prow()+1,00   say '| Vale               R$' + subs(aLIN[nCONT],2) + space(3) + "|"
          @ prow()  ,41   say '| Vale               R$' + str(nVALOR)         // + space(3)
          @ prow()  ,79   say "|"

          @ prow()+1 ,00  say "|"   + space(37) + "|"
          @ prow()   ,41  say "|" + space(37) + "|"
          @ prow()+1,00   say '|'

          @ prow()  ,05   say XCOND1
          @ prow()  ,03   say qextenso(val(aLIN[nCONT]))
          @ prow()  ,65   say '|'
          @ prow()  ,71   say "|  " + qextenso(nVALOR)
          @ prow()  ,00   say  XCOND0

          @ prow()  ,82   say "|"  // + space(37) + "|" + space(39) + "|"
          @ prow()+1,00   say "|"  + space(37) + "|"
          @ prow()  ,41   say "|"  + space(37) + "|"
          @ prow()+1,00   say "| " + aNOME[nCONT]
          @ prow()  ,38   say '|'

          @ prow()  ,41   say "| " + left(cNOME,30)
          @ prow()  ,79   say '|'

          @ prow()+1,00   say "|"  + space(37) + "|"

          @ prow()  ,41   say "|"  + space(37) + "|"
          @ prow()+1,00   say "| " + space(11) +"Curitiba," + "  20/" + right(ltrim(str(val(XANOMES))),2)  + "/" + left(XANOMES,4) + space(4) + "|"
          @ prow()  ,41   say "| " + space(11) +"Curitiba," + "  20/" + right(ltrim(str(val(XANOMES))),2)  + "/" + left(XANOMES,4) + space(4) + "|"
          @ prow()+1,00   say '|' + space(37) + "|"
          @ prow()  ,41   say '|' + space(37) + "|"
          @ prow()+1,00   say '|' + space(37) + "|"
          @ prow()  ,41   say '|' + space(37) + "|"
          @ prow()+1,00   say '| Ass. ____________________________' + "   " + "|"
          @ prow()  ,41   say '| Ass. ____________________________' + "   " + "|"
          @ prow()+1,00   say "|" + space(37) + "|"
          @ prow()  ,41   say "|" + space(37) + "|"
          @ prow()+1,00   say "|" + replicate("-",37) + "|"
          @ prow()  ,41   say "|" + replicate("-",37) + "|"
          cFLAG  := .F.
          nLINHA := 15
       endif

       nLINHA--

   next

   @ prow()+3,0 say ""

return

/////////////////////////////////////////////////////////////////////////////
// EMITE CONTRA-CHEQUE SANTA CRUZ ___________________________________________

static function i_impcc2
   local cMACROP, cMACROD, nCONT, zTMP, nLINHA := 14, aLIN := {}

   cMACROP := "BASE->Prov_" + cTIPOREL
   cMACROD := "BASE->Desc_" + cTIPOREL

   if &cMACROP. == 0 .and. &cMACROD. == 0 ; return ; endif

   @ prow()+1,0    say XCOND1 + XRAZAO
   @ prow()+1,0    say XCGCCPF
   @ prow()  ,45   say cTITULO
   @ prow()+3,0    say FUN->Matricula + "/" + left(FUN->Nome,30)
   @ prow(),pcol() say "  Cbo: " + SITUA->Cbo
// @ prow(),pcol() say "  Centro: " + FUN->Centro
   @ prow(),pcol() say "  Centro: " + SITUA->Ccusto ;CARGO->(dbseek(SITUA->Cargo))
   @ prow(),pcol() say "  Cargo: " + left(CARGO->Descricao,33)
   @ prow(),pcol() say "(" + FUN->Situacao + ")"
   @ prow()+1,0    say "R.G.: " + FUN->Idt_num + space(10) + "CPF: " + transform(FUN->Cpf_num,"@R 999.999.999-99")
   @ prow()+2,0    say ""

   do while LANC->Anomes == XANOMES .and. LANC->Matricula == FUN->Matricula .and. LANC->Ambiente == cTIPOREL .and. qcontprn()
      if EVENT->Finalidade $ "PD" .and. LANC->Valor <> 0
         zTMP := space(iif(EVENT->Finalidade=="P",9,33))
         aadd(aLIN,"")
         aLIN[len(aLIN)] += iif(EVENT->Finalidade=="P","A","B")
         aLIN[len(aLIN)] += LANC->Evento + "    " + EVENT->Descricao
         aLIN[len(aLIN)] += space(13) + transform(LANC->Fracao,"@E 999.9999")
         aLIN[len(aLIN)] += zTMP + transform(LANC->Valor,"@E 9,999,999,999.99")
      endif
      LANC->(dbskip())
   enddo

   aLIN := asort(aLIN)

   for nCONT := 1 to len(aLIN)
       @ prow()+1,0 say subs(aLIN[nCONT],2)
       nLINHA--
   next

   for nCONT := nLINHA to 1 step -1
       @ prow()+1,0 say ""
   next

   @ prow()+2,0      say cMENSA1
   @ prow(),77       say &cMACROP. picture "@E 9,999,999,999.99"
   @ prow(),pcol()+8 say &cMACROD. picture "@E 9,999,999,999.99"
   @ prow()+1,0      say cMENSA2

   if month(FUN->Data_nasc) = month(XDATASYS)
      cNASC   := left(dtoc(FUN->Data_nasc),6) + right(dtoc(XDATASYS),2)
      cMENSA3 := "PARABENS PELO SEU ANIVERSARIO NO DIA " + cNASC + " !!!  FELICIDADES !!!"
   else
      cMENSA3 := space(67)
   endif

   if FUN->Situacao == "T"  .and. ! empty(SITUA->Inicio_av) .and. ! empty(SITUA->Final_av)
      cMENSA3 := "Trabalhando c/ Aviso Previo de " + dtoc(SITUA->Inicio_av) + " a " + dtoc(SITUA->Final_av)
   endif

   @ prow()+1,0      say cMENSA3
   @ prow(),101      say &cMACROP.-&cMACROD. picture "@E 9,999,999,999.99"
   @ prow()+2,04     say BASE->Salario       picture "@E 9,999,999,999.99"

   if cTIPOREL $ "MS-AD"
      @ prow(),pcol()+4  say BASE->B_inssms picture "@E 9,999,999,999.99"
      @ prow(),pcol()+5  say BASE->B_fgtsms picture "@E 9,999,999,999.99"
      if cTIPOREL == "MS"
         @ prow(),pcol()+3 say BASE->V_fgtsms + BASE->V_fgtsdt picture "@E 9,999,999,999.99"
      else
         @ prow(),pcol()+3 say BASE->V_fgtsms picture "@E 9,999,999,999.99"
      endif
      @ prow(),pcol()+6  say BASE->B_irrfms picture "@E 9,999,999,999.99"
      @ prow(),pcol()+10 say BASE->P_irrfms picture "@E 99.99"
   else
      @ prow(),pcol()+4  say BASE->B_inss13 picture "@E 9,999,999,999.99"
      @ prow(),pcol()+5  say BASE->B_fgts13 picture "@E 9,999,999,999.99"
      @ prow(),pcol()+3  say BASE->V_fgts13 picture "@E 9,999,999,999.99"
      @ prow(),pcol()+6  say BASE->B_irrf13 picture "@E 9,999,999,999.99"
      @ prow(),pcol()+10 say BASE->P_irrf13 picture "@E 99.99"
   endif

   @ prow()+8,0 say ""

return

/////////////////////////////////////////////////////////////////////////////
// EMITE CONTRA-CHEQUE CRC __________________________________________________

static function i_impcc3
   local cMACROP, cMACROD, cMACROI, nCONT, zTMP, nLINHA := 14
   local aPROV := {} , aDESC := {} , nTAM

   cMACROP := "BASE->Prov_" + cTIPOREL
   cMACROD := "BASE->Desc_" + cTIPOREL

   if &cMACROP. == 0 .and. &cMACROD. == 0 ; return ; endif

   @ prow()+1,0    say XCOND1 + XRAZAO       // linha alterada por Andr‚
   @ prow()+3,000 say XCOND2 + left(FUN->Nome,50)
   @ prow()  ,115 say FUN->Matricula
   @ prow()  ,137 say FUN->Pis_num
   @ prow()+2,005 say qnomemes(XDATASYS) + "/" + strzero(year(XDATASYS),4)
   @ prow()  ,028 say CCUSTO->Descricao

   CGM->(dbseek(XCGM))

   @ prow()  ,122 say alltrim(CGM->Municipio);CARGO->(dbseek(SITUA->Cargo))
   @ prow()+2,000 say CARGO->Descricao
   @ prow()  ,090 say left(FUN->Csal_ban,3)
   @ prow()  ,105 say right(FUN->Csal_ban,4)
   @ prow()  ,114 say FUN->Csal_num
   @ prow()  ,134 say strzero(SITUA->Dep_ir,2) + "     " + strzero(SITUA->Dep_fam,2)

   @ prow()+1,000 say ""

   do while LANC->Anomes == XANOMES .and. LANC->Matricula == FUN->Matricula .and. LANC->Ambiente == cTIPOREL .and. qcontprn()
      do case
         case EVENT->Finalidade == "P" .and. LANC->Valor <> 0
              aadd(aPROV,"")
              aPROV[len(aPROV)] += LANC->Evento + "   " + EVENT->Descricao
              aPROV[len(aPROV)] += "    " + transform(LANC->Fracao,"@E 999.9999")
              aPROV[len(aPROV)] += transform(LANC->Valor,"@E 99,999,999.99")
         case EVENT->Finalidade == "D" .and. LANC->Valor <> 0
              aadd(aDESC,"")
              aDESC[len(aDESC)] += LANC->Evento + "   " + EVENT->Descricao
              aDESC[len(aDESC)] += "    " + transform(LANC->Fracao,"@E 999.9999")
              aDESC[len(aDESC)] += transform(LANC->Valor,"@E 99,999,999.99")
      endcase
      LANC->(dbskip())
   enddo

   nTAM := iif(len(aPROV)>=len(aDESC),len(aPROV),len(aDESC))

   for nCONT := 1 to nTAM
       @ prow()+1,000 say ""
       if nCONT <= len(aPROV)
          @ prow(),000 say aPROV[nCONT]
       endif
       if nCONT <= len(aDESC)
          @ prow(),076 say aDESC[nCONT]
       endif
       nLINHA--
   next

   for nCONT := nLINHA to 1 step -1
       @ prow()+1,0  say ""
   next

   @ prow(),000    say &cMACROP.-&cMACROD. picture "@E 99,999,999.99"

   if cTIPOREL == "MS"
      @ prow(),026 say BASE->V_fgtsms+ BASE->V_fgtsdt picture "@E 99,999,999.99"
   else
      @ prow(),026 say BASE->V_fgts13 picture "@E 99,999,999.99"
   endif

   @ prow(),054 say &cMACROP. picture "@E 99,999,999.99"

   if cTIPOREL == "MS"
      @ prow(),082 say BASE->B_fgtsms + BASE->B_fgtsdt picture "@E 99,999,999.99"
   else
      @ prow(),082 say BASE->B_fgts13 picture "@E 99,999,999.99"
   endif

   if cTIPOREL == "MS"
      @ prow(),106 say BASE->B_irrfms + BASE->B_irrfdt picture "@E 99,999,999.99"
   else
      @ prow(),106 say BASE->B_irrf13 picture "@E 99,999,999.99"
   endif

   @ prow(),128 say &cMACROD. picture "@E 99,999,999.99"

   @ prow()+2,014 say cMENSA1
   @ prow()+1,014 say cMENSA2

   if month(FUN->Data_nasc) = month(XDATASYS)
      cNASC   := left(dtoc(FUN->Data_nasc),6) + right(dtoc(XDATASYS),2)
      cMENSA3 := "PARABENS PELO SEU ANIVERSARIO NO DIA " + cNASC + " !!!  FELICIDADES !!!"
   else
      cMENSA3 := space(67)
   endif

   if FUN->Situacao == "T"  .and. ! empty(SITUA->Inicio_av) .and. ! empty(SITUA->Final_av)
      cMENSA3 := "Trabalhando c/ Aviso Previo de " + dtoc(SITUA->Inicio_av) + " a " + dtoc(SITUA->Final_av)
   endif

   @ prow()+1,014 say cMENSA3
   @ prow()+7,0 say ""

return

/////////////////////////////////////////////////////////////////////////////
// EMITE RECIBO PADRAO ______________________________________________________

static function i_impcc4
   local cMACROP, cMACROD, nCONT, zTMP, nLINHA := 8
   local cFLAG := .T.
   local aLIN := {}
   local cLINHA1 := "+--------------------------------------------------------------------------------------------------------------------+"

   cMACROP := "BASE->Prov_" + cTIPOREL
   cMACROD := "BASE->Desc_" + cTIPOREL

   if &cMACROP. == 0 .and. &cMACROD. == 0 ; return ; endif
                   
   do while LANC->Anomes == XANOMES .and. LANC->Matricula == FUN->Matricula .and. LANC->Ambiente == cTIPOREL .and. qcontprn()
      if EVENT->Finalidade $ "PD" .and. LANC->Valor <> 0
         zTMP := space(iif(EVENT->Finalidade=="P",8,0))
         aadd(aLIN,"")
         aLIN[len(aLIN)] += iif(EVENT->Finalidade=="P","A","B")
         aLIN[len(aLIN)] += "| " + LANC->Evento + " | " + EVENT->Descricao
         aLIN[len(aLIN)] += space(12) + "| " + transform(LANC->Fracao,"@E 999.9999") + "  |"
         if EVENT->Finalidade=="D" ; aLIN[len(aLIN)] += space(24) + " | " ; endif
         aLIN[len(aLIN)] += zTMP + transform(LANC->Valor,"@E 9,999,999,999.99") + " |"
         if EVENT->Finalidade=="P" ; aLIN[len(aLIN)] += space(17) + " | " ; endif
      endif
      LANC->(dbskip())
   enddo

   aLIN := asort(aLIN)

   for nCONT := 1 to len(aLIN)
       if cFLAG
          @ prow()+1,0    say XCOND1
          @ prow()+1,0    say "| " + space(40) + "VALE                   R$ "
*          @ prow()+1,0    say cLINHA1

*          @ prow()+1,0    say "| " + FILIAL->Razao
*          @ prow()  ,117  say "|"

*          @ prow()+1,0    say "| " + FILIAL->Endereco
*          @ prow()  ,55   say transform(FILIAL->Cgccpf,"@R 99.999.999/9999-99")
*          @ prow()  ,117  say "|"

*          @ prow()+1,0    say cLINHA1
          @ prow()+1,0    say "| Codigo: " + FUN->Matricula + " Nome: " + left(FUN->Nome,30) + " "
*          @ prow(),pcol() say "  CBO: " + SITUA->Cbo + "   " ;CARGO->(dbseek(SITUA->Cargo))
*          @ prow(),pcol() say "  CARGO: " + left(CARGO->Descricao,33)
*          @ prow(),pcol() say "(" + FUN->Situacao + ") |"

*          @ prow()+1,0    say "| DEPTO.: " + FUN->Depto + space(5) + "CPF: " + transform(FUN->Cpf_num,"@R 999.999.999-99") + space(5)
*          @ prow(),pcol() say " CENTRO: " + transform(FUN->Centro,"@R 99.99.9999") + " - " + CCUSTO->Descricao
*          @ prow(),pcol() say " CENTRO: " + transform(SITUA->Ccusto,"@R 99.99.9999") + " - " + CCUSTO->Descricao
          @ prow()  ,117  say "|"
          @ prow()+1,0    say "+-----+-----------------------------------------------------+-----------+-------------------------+------------------+"
          @ prow()+1,0    say "|Cod. | Descricao                                           |Referencia | Vencimento              | Desconto         |"
          @ prow()+1,0    say "+-----+-----------------------------------------------------+-----------+-------------------------+------------------+"
          cFLAG  := .F.
          nLINHA := 8
       endif

       @ prow()+1,0 say subs(aLIN[nCONT],2)

       nLINHA--

       if nCONT = 8 .and. len(aLIN) > 8

          cFLAG := .T.
          @ prow()+2,0 say ""

*          @ prow(),76       say "*,***,***,***.**"
*          @ prow(),pcol()+8 say "*,***,***,***.**"
*          @ prow()+2,0      say ""

*          @ prow(),100      say "*,***,***,***.**"
*          @ prow()+2,05     say "*,***,***,***.**"

          if cTIPOREL $ "MS-AD"
*             @ prow(),pcol()+2 say "*,***,***,***.**"
*             @ prow(),pcol()+5 say "*,***,***,***.**"
             if cTIPOREL == "MS"
*                @ prow(),pcol()+3 say "*,***,***,***.**"
             else
*                @ prow(),pcol()+3 say "*,***,***,***.**"
             endif
*             @ prow(),pcol()+6 say "*,***,***,***.**"
*             @ prow(),pcol()+7 say "**.**"
          else
*             @ prow(),pcol()+2 say "*,***,***,***.**"
*             @ prow(),pcol()+5 say "*,***,***,***.**"
*             @ prow(),pcol()+3 say "*,***,***,***.**"
*             @ prow(),pcol()+6 say "*,***,***,***.**"
*             @ prow(),pcol()+7 say "**.**"
          endif

          @ prow()+5,0 say ""

       endif
   next

   for nCONT := nLINHA to 1 step -1
       @ prow()+1,0 say "|     |                                                     |           |                         |                  |"
   next

/*   @ prow()+1,0  say "+-----+-----------------------------------------------------+-----------+-------------------------+------------------+"
   @ prow()+1,0  say "| CTBA, ____/____/____                                                  | TOTAL DE VENCIMENTO     | TOTAL DE DESCONTO|"
   @ prow()+1,0  say "|                                                                       +-------------------------+------------------+"
   @ prow()+1,0  say "|                                                                       |" + transform(&cMACROP.,"@E 9,999,999,999.99") + " |         " + transform(&cMACROD.,"@E 9,999,999,999.99") + " |"
   @ prow()+1,0  say "| ASS.: ____________________________________                            +-------------------------+------------------+"
   @ prow()+1,0  say "|                                                                       | VALOR LIQUIDO ==>         " + transform(&cMACROP.-&cMACROD.,"@E 9,999,999,999.99") + " |"
   @ prow()+1,0  say "+-----------------------------------------------------------------------+--------------------------------------------+"
   @ prow()+1,0  say "|     SALARIO BASE         SAL. CON. INSS         B. CALC. FGTS          FGTS DO MES        B. CALC. IRRF      FAIXA |"
   @ prow()+1,0  say "+--------------------------------------------------------------------------------------------------------------------+"
   @ prow()+1,0  say "| " + transform(BASE->Salario,"@E 9,999,999,999.99")
*/
   if cTIPOREL $ "MS-AD"
/*      @ prow(),pcol()+2 say BASE->B_inssms picture "@E 9,999,999,999.99"
      @ prow(),pcol()+7 say BASE->B_fgtsms picture "@E 9,999,999,999.99"
      if cTIPOREL == "MS"
         @ prow(),pcol()+5 say BASE->V_fgtsms + BASE->V_fgtsdt picture "@E 9,999,999,999.99"
      else
         @ prow(),pcol()+5 say BASE->V_fgtsms picture "@E 9,999,999,999.99"
      endif
      @ prow(),pcol()+9 say BASE->B_irrfms picture "@E 9,999,999,999.99"
      @ prow(),pcol()+7 say BASE->P_irrfms picture "@E 99.99" + "|"
   else
      @ prow(),pcol()+2 say BASE->B_inss13 picture "@E 9,999,999,999.99"
      @ prow(),pcol()+7 say BASE->B_fgts13 picture "@E 9,999,999,999.99"
      @ prow(),pcol()+5 say BASE->V_fgts13 picture "@E 9,999,999,999.99"
      @ prow(),pcol()+9 say BASE->B_irrf13 picture "@E 9,999,999,999.99"
      @ prow(),pcol()+7 say BASE->P_irrf13 picture "@E 99.99" + "|"
*/
   endif
*   @ prow()+1,0  say "+--------------------------------------------------------------------------------------------------------------------+"
*   @ prow()+2,0  say ""

   nQUANT_IMP++

   if nQUANT_IMP == 2
      EJECT
      nQUANT_IMP := 0
   endif

return
