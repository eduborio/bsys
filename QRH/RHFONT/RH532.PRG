/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: FOLHA DE PAGAMENTO
// OBJETIVO...: CAGED - ESPELHO PARA PRE-IMPRESSO
// ANALISTA...: CARLOS EDUARDO RABELLO NUNES
// PROGRAMADOR: O MESMO
// INICIO.....: JULHO DE 1995
// OBS........:
// ALTERACOES.:

#include "rh.ch"
#define K_MAX_LIN 60

/////////////////////////////////////////////////////////////////////////////
// TELA PRINCIPAL E PARTIDA NA EDICAO _______________________________________

local nCURSOR := setcursor(1)
i_inicializacao()
i_impressao()
setcursor(nCURSOR)
return

// INICIALIZACAO ____________________________________________________________

static function i_inicializacao

SITUA->(dbSetFilter({|| Anomes == XANOMES},"Anomes == XANOMES"))

FUN->(dbsetorder(2))   // indexado por nome

SITUA->(dbSetRelation("AFAST",{|| Af_cod},"Af_cod"))
FUN->(dbSetRelation("CGM",{|| Cp_cgm},"Cp_cgm"))

FUN->(dbgotop())

return

////////////////////////////////////////////////////////////////////////////
// FUNCAO PRINCIPAL DE IMPRESSAO ___________________________________________

static function i_impressao
   local lNOVO := .F.
   local nTOTFUN := nPRIMADM := nREEMP := nTRANSEN := nDESLSJ  := nDESLCJ := 0
   local nINICPP := nAPOSENT := nMORTE := nTRANSSA := nFIMCONT := nTOTADM := 0
   local lACHOU := .F. , nTOTDES := 0

   if ! qinitprn() ; return ; endif

   do while ! FUN->(eof()) .and. qcontprn()
      SITUA->(dbseek(FUN->Matricula))

      if ! qlineprn() ; return ; endif

//      if FUN->Data_adm < qinimes(XDATASYS) .and. SITUA->Vinculo = K_DIRETOR .and. FUN->Situacao <> "H"
//         nTOTFUN++
//      endif

      if SITUA->Vinculo = K_DIRETOR .or. FUN->Situacao == "H" .or. FUN->Data_adm > qfimmes(XDATASYS) ;
      .or. SITUA->Af_ini > qfimmes(XDATASYS) .or. (SITUA->Categoria == "9" .and. SITUA->Vinculo == "H")

         FUN->(dbskip())
         loop
      endif

      if FUN->Data_adm < qinimes(XDATASYS)
         nTOTFUN++
      endif

      if ! empty(SITUA->Af_ini)
         if SITUA->Af_ini < qinimes(XDATASYS)
            FUN->(dbskip())
            loop
         endif
      endif


      do case
         case FUN->Data_adm >= qinimes(XDATASYS) .and. FUN->Prim_adm == "S"
              nPRIMADM++
         case FUN->Data_adm >= qinimes(XDATASYS) .and. FUN->Prim_adm == "N" .and. SITUA->Transf != "S"
              nREEMP++
         case FUN->Data_adm >= qinimes(XDATASYS) .and. SITUA->Transf == "S"
              nTRANSEN++
         case SITUA->Af_ini   >= qinimes(XDATASYS) .and. AFAST->cod_caged == "31"
              nDESLSJ++
         case SITUA->Af_ini   >= qinimes(XDATASYS) .and. AFAST->cod_caged == "32"
              nDESLCJ++
         case SITUA->Af_ini   >= qinimes(XDATASYS) .and. AFAST->cod_caged == "40"
              nINICPP++
         case SITUA->Af_ini   >= qinimes(XDATASYS) .and. AFAST->cod_caged == "50"
              nAPOSENT++
         case SITUA->Af_ini   >= qinimes(XDATASYS) .and. AFAST->cod_caged == "60"
              nMORTE++
         case SITUA->Af_ini   >= qinimes(XDATASYS) .and. AFAST->cod_caged == "80"
              nTRANSSA++
         case SITUA->Af_ini   >= qinimes(XDATASYS) .and. AFAST->cod_caged == "45"
              nFIMCONT++
      endcase

      if empty(SITUA->Af_ini) .and. FUN->Data_adm < qinimes(XDATASYS)
         FUN->(dbskip())
         loop
      endif

      if ! empty(SITUA->Af_ini) .and. ! AFAST->Cod_caged $ "31-32-40-45-50-60-70-80"
         FUN->(dbskip())
         loop
      endif

      if FUN->Data_adm >= qinimes(XDATASYS)
         lNOVO := .T.
         if SITUA->Transf != "S"
            if FUN->Prim_adm == "S"
               cCOD_NOVO := "10"
            else
               cCOD_NOVO := "20"
            endif
         else
            cCOD_NOVO := "70"
         endif
      endif

      if ! qlineprn() ; return ; endif

      if XPAGINA == 0 .or. prow() > K_MAX_LIN
         qpageprn()
         @ prow(),pcol() say XCOND1
         qcabecprn("CAGED - ESPELHO DE AUXILIO PARA PRE-IMPRESSO",132)
         @ prow()+1,0 say " PIS/PASEP  SEXO INST.   CBO   NOME DO FUNCIONARIO            C. PROF. SERIE UF NASCIMENTO REMUNERACAO SEMANA ADMISSAO DESLIG. TIPO"
         @ prow()+1,0 say replicate("-",132)
      endif

      lACHOU := .T.

      @ prow()+1,0      say FUN->Pis_num
      @ prow(),pcol()+3 say FUN->Sexo
      @ prow(),pcol()+4 say FUN->Instrucao
      @ prow(),pcol()+3 say SITUA->Cbo
      @ prow(),pcol()+1 say left(FUN->Nome,30)
      @ prow(),pcol()+2 say FUN->Cp_num
      @ prow(),pcol()+2 say FUN->Cp_serie
      @ prow(),pcol()+1 say CGM->Estado
      @ prow(),pcol()+1 say FUN->Data_nasc
      @ prow(),pcol()+2 say transform(SITUA->Salario,"@E 999,999.99")
      @ prow(),pcol()+3 say transform(FUN->Hor_sema,"999")
      @ prow(),pcol()+2 say FUN->Data_adm
      @ prow(),pcol()+2 say strzero(day(SITUA->Af_ini),2)

      if lNOVO .and. qcontprn()
         @ prow(),pcol()+5 say cCOD_NOVO
         lNOVO := .F.
      else
         @ prow(),pcol()+5 say AFAST->Cod_caged
      endif

      FUN->(dbskip())
   enddo

   if lACHOU
      __eject()
   endif

   nTOTADM := nPRIMADM + nREEMP  + nTRANSEN
   nTOTDES := nDESLSJ  + nDESLCJ + nINICPP + nAPOSENT + nMORTE + nTRANSSA + nFIMCONT

   @ prow(),pcol() say XCOND0
   qcabecprn("CAGED - ESPELHO DE AUXILIO PARA PRE-IMPRESSO",80)
   @ prow()+2,00 say padc("INFORMACOES SOBRE A EMPRESA E TOTALIZADORES",80)
   @ prow()+1,00 say padc(repl("-",43),80)
   @ prow()+3,01 say "CGC: " + XCGCCPF + space(3) + "CNAE: " + CONFIG->Cnae
   @ prow()  ,42 say "MES: " + strzero(month(XDATASYS),2) + space(4) + "ANO: " + ;
       strzero(year(XDATASYS),4)  + space(4) + "CEP:"  + left(XCEP,5) + "-" +right(XCEP,3)
   @ prow()+4,00 say padc("TOTAL DE FUNCIONARIOS NO PRIMEIRO DIA DO MES: " + strzero(nTOTFUN,3),80)
   @ prow()+4,00 say padc("ADMISSOES NO MES INFORMADO",80)
   @ prow()+1,00 say padc(repl("-",60),80)
   @ prow()+2,10 say "PRIM. EMPREGO     REEMPREGO     TRANSFERENCIA         TOTAL"
   @ prow()+1,15 say strzero(nPRIMADM,3) + space(13) + strzero(nREEMP,3) + space(13) + ;
                     strzero(nTRANSEN,3) + space(15) + strzero(nTOTADM,3)
   @ prow()+3,00 say padc("DESLIGAMENTOS NO MES INFORMADO",80)
   @ prow()+1,00 say repl("-",80)
   @ prow()+2,01 say "S/JUSTA  C/JUSTA  PEDIDO  APOSENT.  MORTE  TRANSFER.  FIM DE CONTRATO    TOTAL"
   @ prow()+1,03 say strzero(nDESLSJ,3) + space(6) + strzero(nDESLCJ,3) + space(5) + strzero(nINICPP,3) + ;
                     space(6) + strzero(nAPOSENT,3) + space(6) + strzero(nMORTE,3) + space(5) + ;
                     strzero(nTRANSSA,3) + space(11) + strzero(nFIMCONT,3) + space(12) + strzero(nTOTDES,3)
   @ prow()+4,00 say padc("TOTAL DE EMPREGADOS EXISTENTES NO FINAL DO ULTIMO DIA DO MES INFORMADO:  " ;
                                                           + strzero((nTOTFUN+nTOTADM-nTOTDES),3),80)
   qstopprn()

return

