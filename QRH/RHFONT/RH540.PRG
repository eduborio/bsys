/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: FOLHA DE PAGAMENTO
// OBJETIVO...: EVOLUCAO SALARIAL
// ANALISTA...:
// PROGRAMADOR: EDUARDO BORIO
// INICIO.....:
// OBS........:
// ALTERACOES.:

#define K_MAX_LIN 54

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local bESCAPE := {||(XNIVEL==1 .and. !XFLAG) .or. lastkey() == 27}

private cMatricula := ""
private lPRI  := .T.     // logico primeiro
private bFILTRO          // filtro para centro, filial ou grupo
private aEDICAO := {}    // vetor para os campos de entrada de dados

//SITUA->(dbSetFilter({|| Anomes == XANOMES},"Anomes == XANOMES"))

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || view_fun(-1,0,@cMATRICULA)}       , "MATRICULA" })
aadd(aEDICAO,{{ || NIL },NIL}) // nome do funcionario

do while .T.

   qlbloc(5,0,"B540A","QBLOC.GLO")
   XNIVEL     := 1
   XFLAG      := .T.
   cMATRICULA := space(6)

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
      case cCAMPO == "MATRICULA"

           if ! empty(cMATRICULA)
              qrsay(XNIVEL,cMATRICULA:=strzero(val(cMATRICULA),6))
           endif

           if FUN->(Dbseek(cMatricula))
              qrsay(XNIVEL+1,left(FUN->Nome,30))
           else
              qmensa("Funcionario no encontrado!","BL")
              return .F.
           endif
   endcase
return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   FILIAL->(dbseek(FUN->Filial))

   // CRIA MACRO DE FILTRO __________________________________________________


return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impressao
local aSind    := {}
local aCargo   := {}
local aSalario := {}
local aFerias  := {}
local aAfast   := {}
local nCONT    := 0
local zCONT    := 0
local nLIN     := 0
local nTOTSIND := 5
local cCARGO   := ""
local cDem_dt := ""
local cDem_cg := ""
local nDem_sl := 0
local nSAL    := 0
local cCod    := ""
local cAfast  := ""


   ////////////////////////////
   // Busca Contribuicoes_____

   LANC->(dbsetorder(3))
   LANC->(dbseek(FUN->Matricula))
   SIND->(dbseek(FUN->Sind_cod))

   do while ! LANC->(eof()) .and. LANC->Matricula == FUN->Matricula
      if LANC->Evento == "230"
         aadd(aSind,{left(LANC->Anomes,4),right(LANC->Anomes,2)+"/"+left(LANC->Anomes,4),left(SIND->Descricao,25),transform(LANC->Valor,"@E 9,999.99")})
      endif
      LANC->(dbskip())
   enddo

   aSind := aSort(aSind,NIL,NIL,{|x,y| x[1] < y[1]})

   ////////////////////////////
   // Busca Alteracoes Cargo___

   CGM->(dbseek(FILIAL->Cgm))
   SITUA->(dbsetfilter({|| Matricula == FUN->Matricula .and. ! empty(Anomes) }))
   SITUA->(dbsetorder(4))
   SITUA->(dbgotop())
   CARGO->(dbseek(SITUA->Cargo))
   aadd(aCargo,{dtoc(FUN->Data_adm),"ADMISSAO",rtrim(CGM->Municipio)+"-"+left(FILIAL->Endereco,30),left(CARGO->Descricao,30)})

   cCARGO := SITUA->Cargo

   do while ! SITUA->(eof()) .and. SITUA->Matricula == FUN->Matricula

      if SITUA->Situacao == "D"
         cDem_dt := dtoc(SITUA->Af_ini)
         cDem_cg := SITUA->Cargo
      endif

      SITUA->(dbskip())

      if alltrim(cCARGO) != alltrim(SITUA->Cargo)
         CARGO->(dbseek(cCARGO))
         aadd(aCargo,{"01/"+right(SITUA->Anomes,2)+"/"+left(SITUA->Anomes,4),"ACORDO COLETIVO",rtrim(CGM->Municipio)+"-"+left(FILIAL->Endereco,30),left(CARGO->Descricao,30)})
         cCARGO := SITUA->Cargo
      endif

   enddo

   if ! empty(cDem_dt)
      CARGO->(dbseek(cDem_cg))
      aadd(aCargo,{cDem_dt,"DEMISSAO",rtrim(CGM->Municipio)+"-"+left(FILIAL->Endereco,30),left(CARGO->Descricao,30)})
   endif

   cDem_dt := ""
   nDem_sl := 0
   cDem_cg := ""

   ////////////////////////////
   // Busca Alteracoes Salario___

   CGM->(dbseek(FILIAL->Cgm))
   SITUA->(dbsetorder(4))
   SITUA->(dbgotop())
   aadd(aSalario,{strzero(Month(FUN->Data_adm),2)+"/"+strzero(year(FUN->Data_adm),4),transform(SITUA->Salario,"@E 99,999.99"),"ADMISSAO       ","       "})

   nSAL := SITUA->Salario

   do while ! SITUA->(eof()) .and. SITUA->Matricula == FUN->Matricula

      if SITUA->Situacao == "D"
         cDem_dt := dtoc(SITUA->Af_ini)
         cDem_sl := SITUA->Salario
      endif

      SITUA->(dbskip())

      if nSAL != SITUA->Salario
         nPerc := ( (SITUA->Salario - nSAL) / nSAL) * 100
         if SITUA->Salario > 0
            aadd(aSalario,{right(SITUA->Anomes,2)+"/"+left(SITUA->Anomes,4),transform(SITUA->Salario,"@E 99,999.99"),"ACORDO COLETIVO",transform(nPerc,"@E 999.99")+"%"})
         endif
         nSAL := SITUA->Salario
      endif

   enddo

   LANC->(dbsetorder(3))
   LANC->(dbseek(FUN->Matricula))

   do while ! LANC->(eof()) .and. LANC->Matricula == FUN->Matricula
      if LANC->Evento == "180"
         if SITUA->(dbseek(FUN->Matricula+LANC->Anomes))
            if SITUA->Situacao == "F"
               aadd(aFerias,{dtoc(SITUA->Di_ferias),dtoc(SITUA->Df_ferias),dtoc(SITUA->Af_ini),dtoc(SITUA->Af_ret)})
            endif
         endif
      endif
      LANC->(dbskip())
   enddo

   aFerias := aSort(aFerias,NIL,NIL,{|x,y| x[1] < y[1]})

   ////////////////////////////
   // Busca Afastamento Legais_

   SITUA->(dbclearfilter())
   SITUA->(dbsetfilter({|| Matricula == FUN->Matricula .and. ! empty(Anomes) .and. SITUA->Situacao == "A"}))
   SITUA->(dbsetorder(4))
   SITUA->(dbgotop())

   cAfast := dtos(SITUA->Af_ini)+dtos(SITUA->Af_ret)
   cCod := SITUA->Af_cod
   AFAST->(dbseek(SITUA->Af_cod))

   if ! empty(SITUA->af_ini)
//      aadd(aAfast,{dtoc(SITUA->Af_ini),dtoc(SITUA->af_ret),left(AFAST->Descricao,30)})
   endif

   do while ! SITUA->(eof()) .and. SITUA->Matricula == FUN->Matricula

      SITUA->(dbskip())
      if dtos(SITUA->Af_ini)+dtos(SITUA->af_ret) != cAfast
         AFAST->(dbseek(cCod))
         aadd(aAfast,{dtoc(stod(left(cAfast,8))),dtoc(stod(right(cAfast,8))),left(AFAST->Descricao,30)})

         cAfast := dtos(SITUA->Af_ini)+dtos(SITUA->Af_ret)
         cCod   := SITUA->Af_cod
      endif
   enddo

   if ! qinitprn() ; return ; endif


   @ prow()+1,00  say XCOND1
   @ prow()+1,00  say padc("FICHA DE ANOTACOES E ATUALIZACOES DA CARTEIRA DE TRABALHO E PREVIDENCIA SOCIAL",136)
   @ prow()+1,00  say padc("(PORTARIA 628 de 10/08/2000 DO MTB)",136)
   @ prow()+1,00  say "  Data de emissao.: "+dtoc(date())
   @ prow()  ,80  say "Periodo abrangido.: "+ strzero(Month(FUN->Data_Adm),2)+"/"+strzero(year(FUN->Data_adm),4)+" a "+strzero(Month(XDATASYS),2)+"/"+strzero(year(XDATASYS),4)
   @ prow()+1,00  say "|"+replicate("-",134)+"|"
   CGM->(dbseek(FILIAL->Cgm))

   @ prow()+1,00  say "|Empregador: "+FILIAL->Razao
   @ prow()  ,109 say "|CNPJ: "+transform(FILIAL->Cgccpf,"@R 99.999.999/9999-99")+" |"
   @ prow()+1,00  say "|Endereco..: "+FILIAL->Endereco+", "+str(FILIAL->Numero,5)+"             "+FILIAL->Bairro+"   "+CGM->Municipio+"/"+ CGM->Estado+"      |"

   @ prow()+1,00  say "|"+replicate("-",134)+"|"


   @ prow()+1,00  say "|Empregado.: "+FUN->Nome
   @ prow()  ,109 say "|Contrato..: "+FUN->Mat_ass+"     |"
   @ prow()+1,00  say "|"+replicate("-",134)+"|"

   CGM->(dbseek(FUN->Idt_cgm))
   @ prow()+1,00  say "|Carteira Profissional (No/Serie)   |        Rg         |   Estado Emissor   |      Data Admissao            |    PIS                  |"
   @ prow()+1,00  say "|      "+FUN->Cp_num+"/"+FUN->Cp_Serie
   @ prow()  ,36  say "|    "+ left(FUN->Idt_num,11)
   @ prow()  ,56  say "|      "+ CGM->Estado
   @ prow()  ,77  say "|      "+ dtoc(FUN->Data_adm)
   @ prow()  ,109 say "|    "+ FUN->Pis_num
   @ prow()  ,135 say "|"
   @ prow()+1,00  say "|"+replicate("-",134)+"|"
   @ prow()+1,00  say "|"+padc("Contribuicoes Sindicais",134)+"|"
   @ prow()+1,00  say "|Ano Ref  Mes/Ano  Sindicato                               Valor   |   Ano Ref  Mes/Ano  Sindicato                               Valor |"
   @ prow()+1,00  say "|"+replicate("-",134)+"|"

   if len(aSind) > 0
      for nCONT := 1 to len(aSind)

          if mod(nCONT,2) != 0
             @ prow()+1,00 say "|"+aSind[nCONT,1]
             @ prow()  ,10 say aSind[nCONT,2]
             @ prow()  ,19 say aSind[nCONT,3]
             @ prow()  ,58 say aSind[nCONT,4]+" |"
             nLIN ++
          else
             @ prow()  ,71  say aSind[nCONT,1]
             @ prow()  ,80  say aSind[nCONT,2]
             @ prow()  ,89  say aSind[nCONT,3]
             @ prow()  ,126 say aSind[nCONT,4]+" |"
          endif

      next
   endif

   nResto := 6 - nLIN
   if nResto > 0
      for nCONT := 1 to nRESTO
          @ prow()+1,00  say "|"
          @ prow()  ,67  say "|"
          @ prow()  ,135 say "|"
      next
   endif

   nResto := 0
   nLin   := 0
   nCont  := 0

   @ prow()+1,00  say "|"+replicate("-",134)+"|"
   @ prow()+1,00  say "|"+padc("Alteracoes Funcionais",134)+"|"
   @ prow()+1,00  say "|Data         Motivo                                 Local de Trabalho                             Cargo                               |"
   @ prow()+1,00  say "|"+replicate("-",134)+"|"

   if len(aCargo) > 0
      for nCONT := 1 to len(aCargo)

          @ prow()+1,00 say "|"+aCargo[nCONT,1]
          @ prow()  ,14 say aCargo[nCONT,2]
          @ prow()  ,53 say aCargo[nCONT,3]
          @ prow()  ,99 say aCargo[nCONT,4]+"      |"
          nLIN ++

      next
   endif

   nResto := 5 - nLIN
   if nResto > 0
      for nCONT := 1 to nRESTO
          @ prow()+1,00  say "|"
          @ prow()  ,135 say "|"
      next
   endif

   nResto := 0
   nLin   := 0
   nCont  := 0


   @ prow()+1,00  say "|"+replicate("-",134)+"|"
   @ prow()+1,00  say "|"+padc("Alteracoes Salariais",134)+"|"
   @ prow()+1,00  say "|Data           Salario  Motivo                             Perc % | Data           Salario  Motivo                             Perc % |"
   @ prow()+1,00  say "|"+replicate("-",134)+"|"

   if len(aSalario) > 0
      for nCONT := 1 to len(aSalario)

          if mod(nCONT,2) != 0
             @ prow()+1,00 say "|"+aSalario[nCONT,1]
             @ prow()  ,14 say aSalario[nCONT,2]
             @ prow()  ,25 say aSalario[nCONT,3]
             @ prow()  ,59 say aSalario[nCONT,4]+" |"
             nLIN ++
          else
             @ prow()  ,69  say aSalario[nCONT,1]
             @ prow()  ,82  say aSalario[nCONT,2]
             @ prow()  ,93  say aSalario[nCONT,3]
             @ prow()  ,126 say aSalario[nCONT,4]+"  |"
          endif

      next
   endif

   nResto := 6 - nLIN
   if nResto > 0
      for nCONT := 1 to nRESTO
          @ prow()+1,00  say "|"
          @ prow()  ,67  say "|"
          @ prow()  ,135 say "|"
      next
   endif

   nResto := 0
   nLin   := 0
   nCont  := 0

   @ prow()+1,00  say "|"+replicate("-",134)+"|"
   @ prow()+1,00  say "|"+padc("Ferias",134)+"|"
   @ prow()+1,00  say "|Periodo Aquisitivo                    Periodo de Fruicao          | Periodo Aquisitivo                     Periodo de Fruicao         |"
   @ prow()+1,00  say "|"+replicate("-",134)+"|"

   if len(aFerias) > 0
      for nCONT := 1 to len(aFerias)

          if mod(nCONT,2) != 0
             @ prow()+1,00 say "|"+aFerias[nCONT,1]
             @ prow()  ,14 say aFerias[nCONT,2]
             @ prow()  ,39 say aFerias[nCONT,3]
             @ prow()  ,52 say aFerias[nCONT,4]+"     |"
             nLIN ++
          else
             @ prow()  ,69  say aFerias[nCONT,1]
             @ prow()  ,83  say aFerias[nCONT,2]
             @ prow()  ,108 say aFerias[nCONT,3]
             @ prow()  ,120 say aFerias[nCONT,4]+"     |"
          endif

      next
   endif

   nResto := 6 - nLIN
   if nResto > 0
      for nCONT := 1 to nRESTO
          @ prow()+1,00  say "|"
          @ prow()  ,67  say "|"
          @ prow()  ,135 say "|"
      next
   endif

   nResto := 0
   nLin   := 0
   nCont  := 0

   @ prow()+1,00  say "|"+replicate("-",134)+"|"
   @ prow()+1,00  say "|"+padc("Afastamentos Legais",134)+"|"
   @ prow()+1,00  say "|Inicio             Retorno            Motivo                      | Inicio              Retorno            Motivo                     |"
   @ prow()+1,00  say "|"+replicate("-",134)+"|"

   if len(aAfast) > 0
      for nCONT := 1 to len(aAfast)

          if mod(nCONT,2) != 0
             @ prow()+1,00 say "|"+aAfast[nCONT,1]
             @ prow()  ,20 say aAfast[nCONT,2]
             @ prow()  ,36 say aAfast[nCONT,3]+" |"
             nLIN ++
          else
             @ prow()  ,69  say aAfast[nCONT,1]
             @ prow()  ,83  say aAfast[nCONT,2]
             @ prow()  ,95  say aAfast[nCONT,3]+" |"
          endif

      next
   endif

   nResto := 5 - nLIN
   if nResto > 0
      for nCONT := 1 to nRESTO
          @ prow()+1,00  say "|"
          @ prow()  ,67  say "|"
          @ prow()  ,135 say "|"
      next
   endif
   @ prow()+1,00  say "|"+replicate("-",134)+"|"
   @ prow()+1,00  say " O presente documento substitui as anotacoes na Carteira de Trabalho e Previdencia Social"
   @ prow()+1,00  say " fazendo parte integrante dela."
   @ prow()+1,95  say " _______________________________"
   @ prow()+1,95  say "       RECURSOS HUMANOS "


   nResto := 0
   nLin   := 0
   nCont  := 0








   qstopprn(.F.)

return

/////////////////////////////////////////////////////////////////////////////

