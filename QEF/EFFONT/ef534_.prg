
//////////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE ESCRITA FISCAL
// OBJETIVO...: CONTROLE DE LIMITES PARA MICRO EMPRESA (COMPRA E FATURAMENTO)
// ANALISTA...: LUIS ANTONIO ORLANDO PEREIRA
// PROGRAMADOR: IN SUNG CHANG
// INICIO.....: MARCO DE 1996
// OBS........:
// ALTERACOES.:
function ef534

#define K_MAX_LIN 55

// DECLARACAO E INICIALIZACAO DE VARIAVEIS _______________________________________

local bESCAPE := {||(XNIVEL==1 .and. !XFLAG .or. lastkey() = 27)}

private cPIC1 := "@E 99,999,999.99"
private cPIC2 := "@E 999,999.9999"
private bENT_FILTRO                    // Code block de filtro
private bSAI_FILTRO                    // Code block de filtro
private bISS_FILTRO                    // Code block de filtro
private nV_CON_C                       // Valor contabil das compras do mes
private nV_DED_C                       // Deducao base de calculo das compras
private nA_CON_C                       // Acumulo do valor contabil das compras
private nT_CON_C                       // Total do valor contabil das compras
private nT_DED_C                       // Total da deducao das compras
private nV_CON_F                       // Valor contabil do faturamento
private nA_CON_F                       // Acumulo do valor contabil do faturamento
private nT_CON_F                       // Total do valor contabil do faturamento
private dD_IND_C                       // Data do valor do indice de UPF/PR
private dD_IND_F                       // Data do valor do indice de UFIR
private dDATA_INI                      // Inicio do periodo do relatorio
private dDATA_FIM                      // Fim do periodo do relatorio
private nMES                           // Mes para comtrole de impressao
private nPROJ_LIM
private nPROJ_L_C
private nMES_PROJ
private nMES_P_C


// CRIACAO DO VETOR DE BLOCOS ____________________________________________________

qlbloc(5,0,"B534A","QBLOC.GLO",1)

do while .T.

   XNIVEL    := 1
   XFLAG     := .T.

   nV_CON_C  := 0
   nV_DED_C  := 0
   nA_CON_C  := 0
   nT_CON_C  := 0
   nT_DED_C  := 0
   nV_CON_F  := 0
   nA_CON_F  := 0
   nT_CON_F  := 0
   dDATA_INI := ctod("01/01/" + left(XANOMES,4))
   dDATA_FIM := ctod("31/12/" + left(XANOMES,4))
   nMES      := val(str(month(dDATA_INI),2))
   nPROJ_LIM := CONFIG->Lim_me_f
   nPROJ_L_C := CONFIG->Lim_me_c
   nMES_PROJ := nMES_P_C := nMES

   // SEGUNDO LOOP PARA ENTRADA DOS DADOS ________________________________________

   if eval ( bESCAPE ) ; dbcloseall() ; return ; endif
   if ( i_inicializacao() ,  i_impressao() , NIL )

enddo

//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ________________________________

static function i_inicializacao

   bENT_FILTRO := { || ENT->DATA_LANC >= dDATA_INI .and. ENT->DATA_LANC <= dDATA_FIM }
   bSAI_FILTRO := { || SAI->DATA_LANC >= dDATA_INI .and. SAI->DATA_LANC <= dDATA_FIM }
   bISS_FILTRO := { || ISS->DATA_LANC >= dDATA_INI .and. ISS->DATA_LANC <= dDATA_FIM }

   // ESTABELECE RELACOES ENTRE ARQUIVOS _________________________________________

   set softseek on

   select ENT
   ENT->(dbsetorder(2))                  // Valor contabil das entradas
   ENT->(dbgotop())
   ENT->(dbseek(dtos(dDATA_INI)))

   select SAI
   SAI->(dbsetorder(2))                  // Valor contabil das saidas
   SAI->(dbgotop())
   SAI->(dbseek(dtos(dDATA_INI)))

   select ISS
   ISS->(dbsetorder(2))                  // Valor contabil dos servicos
   ISS->(dbgotop())
   ISS->(dbseek(dtos(dDATA_INI)))

   set softseek off

return .T.

//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO PARA ENTRADA __________________

static function i_impressao

   // INICIALIZA PROCESSO DE IMPRESSAO ___________________________________________

   if ! qinitprn() ; return ; endif

   @ prow(),pcol() say XCOND2

   i_imp_c()
   i_imp_f()

   qstopprn()

return

//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO PARA ENTRADA __________________

static function i_imp_c

   i_cab_compra()

   for nMES = 1 TO 12

       dDATA_INI := ctod("01/"+strzero(nMES)+"/"+left(XANOMES,4))
       dDATA_FIM := qfimmes(dDATA_INI)

       do while eval(bENT_FILTRO) .and. ! ENT->(eof())
          if ENT->Cod_fisc <> "199" .and. ENT->Cod_fisc <> "299" .and. ENT->Cod_fisc <> "399"
             nV_CON_C += ENT->Vlr_cont
          endif
          ENT->(dbskip())
       enddo

       // ACUMULA VALOR CONTABIL  _________________________________________________

       dD_IND_C := ctod("01/" + str(nMES) + "/" + left(CONFIG->Anomes,4))
       nA_CON_C += (nV_CON_C - nV_DED_C) / qbuscaind("55",dD_IND_C)

       // IMPRIME POR MES _________________________________________________________

       if nV_CON_C <> 0
          @ prow()+1,0 say qnomemes(nMES) + space(3) + transform(nV_CON_C, cPIC1) +;
                                            space(3) + transform(nV_DED_C, cPIC1) +;
                                            space(3) + transform(nV_CON_C - nV_DED_C, cPIC1) +;
                                            space(6) + transform(qbuscaind("55",dD_IND_C), "@E 99.99") +;
                                            space(6) + transform((nV_CON_C - nV_DED_C) / qbuscaind("55",dD_IND_C), cPIC2) +;
                                            space(6) + transform(nA_CON_C, cPIC2) +;
                                            space(6) + transform(nA_CON_C / nMES, cPIC2) +;
                                            space(6) + transform(CONFIG->Lim_me_c - nA_CON_C, cPIC2)
          nMES_P_C  := nMES
          nPROJ_L_C := CONFIG->Lim_me_c - nA_CON_C
       else
          @ prow()+1,0 say qnomemes(nMES) + space(3) + transform(nV_CON_C, cPIC1) +;
                                            space(3) + transform(nV_DED_C, cPIC1) +;
                                            space(3) + transform(nV_CON_C - nV_DED_C, cPIC1) +;
                                            space(6) + transform(qbuscaind("55",dD_IND_C), "@E 99.99") +;
                                            space(6) + transform((nV_CON_C - nV_DED_C) / qbuscaind("55",dD_IND_C), cPIC2) +;
                                            space(6) + transform(nA_CON_C, cPIC2) +;
                                            space(6) + transform(nA_CON_C / nMES_P_C, cPIC2) +;
                                            space(6) + transform(nPROJ_L_C := nPROJ_L_C - (nA_CON_C/nMES_P_C), cPIC2)
       endif

       nT_CON_C += nV_CON_C
       nT_DED_C += nV_DED_C

       nV_CON_C := 0
       nV_DED_C := 0

   next

   i_tot_ent()

return

//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO PARA SAIDAS ___________________

static function i_imp_f

   i_cab_fat()

   for nMES = 1 TO 12

       dDATA_INI := ctod("01/"+strzero(nMES)+"/"+left(XANOMES,4))
       dDATA_FIM := qfimmes(dDATA_INI)

       do while eval(bSAI_FILTRO) .and. ! SAI->(eof())
          if SAI->Cod_fisc <> "599" .and. SAI->Cod_fisc <> "699" .and. SAI->Cod_fisc <> "799"
             nV_CON_F += SAI->Vlr_cont
          endif
          SAI->(dbskip())
       enddo

       do while eval(bISS_FILTRO) .and. ! ISS->(eof())
          nV_CON_F += ISS->Vlr_cont
          ISS->(dbskip())
       enddo

       // ACUMULA TOTAL GERAL E SUB-TOTAIS ________________________________________

       dD_IND_F := ctod("01/" + str(nMES) + "/" + left(CONFIG->Anomes,4))
       nA_CON_F += nV_CON_F / qbuscaind("91",dD_IND_F)

       // IMPRIME POR MES _________________________________________________________

       if nV_CON_F <> 0
          @ prow()+1,0 say qnomemes(nMES) + space(3) + transform(nV_CON_F, cPIC1) +;
                                            space(6) + transform(qbuscaind("91",dD_IND_F), "@E 99.9999") +;
                                            space(6) + transform(nV_CON_F / qbuscaind("91",dD_IND_F), cPIC2) +;
                                            space(6) + transform(nA_CON_F, cPIC2) +;
                                            space(6) + transform(nA_CON_F / nMES, cPIC2) +;
                                            space(6) + transform(CONFIG->Lim_me_f - nA_CON_F, cPIC2)
          nMES_PROJ := nMES
          nPROJ_LIM := CONFIG->Lim_me_f - nA_CON_F
       else
          @ prow()+1,0 say qnomemes(nMES) + space(3) + transform(nV_CON_F, cPIC1) +;
                                            space(6) + transform(qbuscaind("91",dD_IND_F), "@E 99.9999") +;
                                            space(6) + transform(nV_CON_F / qbuscaind("91",dD_IND_F), cPIC2) +;
                                            space(6) + transform(nA_CON_F, cPIC2) +;
                                            space(6) + transform(nA_CON_F / nMES_PROJ, cPIC2) +;
                                            space(6) + transform(nPROJ_LIM := nPROJ_LIM - (nA_CON_F/nMES_PROJ), cPIC2)
       endif

       nT_CON_F += nV_CON_F
       nV_CON_F := 0

   next

   i_tot_fat()

return

//////////////////////////////////////////////////////////////////////////////////
// CABECALHO DE COMPRAS __________________________________________________________

static function i_cab_compra

   @ prow()+1,0 say "CONTROLE DE COMPRAS -" + left(CONFIG->Anomes,4)
   @ prow()+2,0 say "CLIENTE : " + XRAZAO
   @ prow()+2,0 say "MES               COMPRAS       DED.BASE           DIFE-     U.P.F./PR       COMPRAS          COMPRAS            PROJECAO          LIMITE"
   @ prow()+1,0 say "                   EM R$       DE CALCULO          RENCA                    EM UPF/PR       ACUM.UPF.PR                          DISPONIVEL"

return

//////////////////////////////////////////////////////////////////////////////////
// CABECALHO DE FATURAMENTO_______________________________________________________

static function i_cab_fat

   @ prow()+3,0 say "CONTROLE DE FATURAMENTO -" + left(CONFIG->Anomes,4)
   @ prow()+2,0 say "CLIENTE : " + XRAZAO
   @ prow()+2,0 say "MES             FATURAMANTO      UFIR       FATURAMENTO      FATURAMENTO          PROJECAO           LIMITE"
   @ prow()+1,0 say "                   EM R$                      EM UFIR       ACUM. EM UFIR                          DISPONIVEL"

return

//////////////////////////////////////////////////////////////////////////////////
// TOTALIZA OS VALORES DO RELATORIO ENTRADA ______________________________________

static function i_tot_ent

   @ prow()+1,0 say replicate("-",140)
   @ prow()+1,0 say "TOTAIS   " + space(03) + transform(nT_CON_C, cPIC1) +;
                                  space(03) + transform(nT_DED_C, cPIC1) +;
                                  space(03) + transform(nT_CON_C - nT_DED_C, cPIC1) +;
                                  space(17) + transform(nA_CON_C, cPIC2) +;
                                  space(06) + transform(nA_CON_C, cPIC2) +;
                                  space(24) + transform(CONFIG->Lim_me_c - nA_CON_C, cPIC2)

return

//////////////////////////////////////////////////////////////////////////////////
// TOTALIZA OS VALORES DO RELATORIO SAIDAS  ______________________________________

static function i_tot_fat

   @ prow()+1,0 say replicate("-",110)
   @ prow()+1,0 say "TOTAIS   " + space(03) + transform(nT_CON_F, cPIC1) +;
                                  space(19) + transform(nA_CON_F, cPIC2) +;
                                  space(06) + transform(nA_CON_F, cPIC2) +;
                                  space(24) + transform(CONFIG->Lim_me_f - nA_CON_F, cPIC2)

return
