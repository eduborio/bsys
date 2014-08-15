/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: FOLHA DE PAGAMENTO
// OBJETIVO...: EMISSAO DO RECIBO DE RESCISAO
// ANALISTA...: CARLOS EDUARDO RABELLO NUNES
// PROGRAMADOR: O MESMO
// INICIO.....: SETEMBRO DE 1994
// OBS........:
// ALTERACOES.:

#define K_MAX_LIN 52

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG) .or. (XNIVEL==1 .and. lastkey()==27)}

private sBLOCO1 := qlbloc("B533B","QBLOC.GLO") // bloco tipo de relatorio

private cMATRICULA           // matricula p/ impressao individual
private cGRUPO               // grupo de funcionarios
private cTIPOREL             // modelo de relatorio
private nVIAS    := 1        // numero de vias para impressao
private nPERC    := 0        // aliquota pensao alimenticia
private aEDICAO  := {}       // vetor para os campos de entrada de dados
private nBASEIS  := 0.00     // acumulador de base inss mes + 13. sal
private nBASEIR  := 0.00     // acumulador de base irrf mes + 13. sal
private nBASEFG  := 0.00     // acumulador de base fgts mes + 13. sal
private dDT_HOMO := ctod("") // data da homologacao
private dPGTO    := ctod("") //Data do Pagamento
private cPREP := space(40)
private nFile := 0

SITUA->(dbSetFilter({|| Anomes == XANOMES},"Anomes == XANOMES"))

// ESTABELECE RELACAO ENTRE OS ARQUIVOS _____________________________________

LANC->(dbSetRelation("EVENT",{|| Evento},"Evento"))
FUN->(dbSetRelation("LANC",{|| XANOMES+Matricula+"MS"},"XANOMES+Matricula+'MS'"))
FUN->(dbSetRelation("BASE",{|| Matricula+XANOMES},"Matricula+XANOMES"))
SITUA->(dbSetRelation("CARGO",{|| Cargo},"Cargo"))
SITUA->(dbSetRelation("AFAST",{|| Af_cod},"Af_cod"))
FUN->(dbsetRelation("SIND",{|| Sind_cod},"sind_cod"))

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || view_fun(-1,0,@cMATRICULA)}       , "MATRICULA" })
aadd(aEDICAO,{{ || NIL },NIL}) // nome do funcionario
aadd(aEDICAO,{{ || view_grupoc(-1,0,@cGRUPO)}        , "GRUPO"     })
aadd(aEDICAO,{{ || NIL },NIL}) // descricao do centro
aadd(aEDICAO,{{ || qgetx(-1,0,@cPREP,"@!")}            , "PREP"   })
aadd(aEDICAO,{{ || qesco(-1,0,@cTIPOREL ,sBLOCO1)}   , "TIPOREL"   })
aadd(aEDICAO,{{ || qgetx(-1,0,@dDT_HOMO)}            , "DT_HOMO"   })
aadd(aEDICAO,{{ || qgetx(-1,0,@dPGTO  )}            , "PGTO"   })

do while .T.

   qlbloc(5,0,"B533A","QBLOC.GLO")
   XNIVEL     := 1
   XFLAG      := .T.
   cTIPOREL   := "1"
   cMATRICULA := space(6)
   cGRUPO     := space(4)
   cPREP      := space(40)
   dPGTO      := Date()
   // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; dbcloseall() ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   if ! empty(cMATRICULA) .or. ! empty(cGRUPO)
      i_impressao()
   endif

enddo

/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA _____________________________________________

static function i_critica ( cCAMPO )
   do case
      case cCAMPO == "MATRICULA"
           if ! empty(cMATRICULA)
              qrsay(XNIVEL,cMATRICULA := strzero(val(cMATRICULA),6))
              if ! FUN->(dbseek(cMATRICULA))
                 qmensa("Funcion rio n„o encontrado...","B")
                 return .F.
              else
                 if SITUA->(dbseek(FUN->Matricula))
                    if qanomes(SITUA->Af_ini) != XANOMES
                       qmensa("Funcion rio n„o foi demitido nesse mˆs!!","B")
                       return .F.
                    endif
                 endif
                 if FUN->Situacao != "D"
                    qmensa("Funcion rio n„o est  demitido !!","B")
                    cMATRICULA := space(6)
                    return .F.
                 endif
                 qrsay(XNIVEL+1,left(FUN->Nome,30))
              endif
              XNIVEL+=2
           endif
      case cCAMPO == "GRUPO"
           if ! empty(cGRUPO)
              if ! GRUPOC->(dbseek(cGRUPO))
                 qmensa("Grupo nao encontrado...","B")
                 return .F.
              else
                 qrsay(XNIVEL+1,GRUPOC->Descricao)
              endif
           endif
      case cCAMPO == "TIPOREL"
           if empty(cTIPOREL) ; return .F. ; endif
           qrsay(XNIVEL,qabrev(cTIPOREL,"1",{"Modelo 2011"}))

      case cCAMPO == "PGTO"
           if cTIPOREL $ "456"
              XNIVEL++
              qgetx(-1,0,@nVIAS,"9")
              XNIVEL++
              qgetx(-1,0,@nPERC,"99.99")
           endif

   endcase
return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impressao
   local nCONT

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   i_reciboXml()
   alert("Arquivo gerado na pasta C:\QsysTxT")

return

/////////////////////////////////////////////////////////////////////////////
// EMITE RECIBO TIPO 1 ______________________________________________________

static function i_recibo1
   local nCONT, zTMP, lINIC := .T., cSTRING
   local nTOTPROV := nTOTDESC := 0

   qmensa("Emitindo recibo para: "+FUN->Matricula+"/"+left(FUN->Nome,40))
   setprc(0,0)

   @ prow()+6,0      say XCOND1 + FILIAL->Razao + space(7) + CONFIG->Conta_fgts
   @ prow()  ,88     say XAEXPAN + transform(FILIAL->Cgccpf,"@R 99.999.999/9999-99") + XDEXPAN
   @ prow()+2,0      say FILIAL->Endereco + " " + str(FILIAL->Numero,5)
   @ prow()  ,88     say left(FILIAL->Razao,42) + iif(!empty(subs(FILIAL->Razao,43)),"-","")
   @ prow()+1,88     say subs(FILIAL->Razao,43)
   CGM->(dbseek(FILIAL->Cgm))
   @ prow()+1,0      say transform(FILIAL->Cep,"@R 99.999-999") + space(12) + FILIAL->Bairro + space(10) + left(CGM->Municipio,25) + space(3) + CGM->Estado
   @ prow()  ,88     say left(FILIAL->Endereco,42) + iif(!empty(subs(FILIAL->Endereco,43)),"-","") + " " + str(FILIAL->Numero,5)
   @ prow()+1,88     say alltrim(subs(FILIAL->Endereco,43) + space(5)) + FILIAL->Bairro
   BANCO->(dbseek(CONFIG->Banco_fgts))
   @ prow()+1,0      say BANCO->Codigo+"-"+left(BANCO->Descricao,20) + space(10)
   @ prow()  ,pcol() say BANCO->Agencia + space(33) + BANCO->Agencia
   @ prow()  ,88     say FILIAL->Cep + " - " + alltrim(CGM->Municipio) + " - " + CGM->Estado
   @ prow()+2,0      say left(FUN->Nome,60) + space(16) + FUN->Matricula + space(8)
   CGM->(dbseek(FUN->Cp_cgm))
   @ prow(),pcol()   say "Num. "+FUN->Cp_num+"   Serie: "+FUN->Cp_serie+"   UF: "+CGM->Estado
   @ prow()+2,0      say FUN->Pis_num + space(27) + FUN->Fgts_num + space(17)
   @ prow(),pcol()   say dtoc(FUN->Data_nasc) + space(10) + dtoc(FUN->Data_adm) + space(8)
   @ prow(),pcol()   say dtoc(FUN->Fgts_dat) + space(10) + dtoc(SITUA->Af_ini)
   @ prow()+2,0      say transform(SITUA->Salario,"@E 999,999,999.99") + space(20)
   @ prow(),pcol()   say dtoc(SITUA->Inicio_av) + space(26) + AFAST->Descricao + space(20)
   @ prow(),pcol()   say iif(empty(SITUA->Codsaqfgts),"*****",SITUA->Codsaqfgts)
   @ prow()+1,0      say ""

   for nCONT := 1 to 2
       zTMP := iif(nCONT==1,"P","D")

       @ prow()+2,0 say "--- "+iif(zTMP=="P","PROVENTOS","DESCONTOS")+" ----------------------- REFERENCIA ------- VALOR -------------------------------------- REFERENCIA ------- VALOR"

       lINIC := .T.
       LANC->(dbseek(XANOMES+FUN->Matricula+"MS"))
       do while LANC->Matricula == FUN->Matricula .and. LANC->Ambiente == "MS"
          if EVENT->Finalidade == zTMP .and. LANC->Valor <> 0
             cSTRING := LANC->Evento + "-" + left(EVENT->Descricao,37) + " "
             cSTRING += transform(LANC->Fracao,"@E 999.99") + " "
             cSTRING += transform(LANC->Valor,"@E 99,999,999.99")
             iif(zTMP=="P",nTOTPROV+=LANC->Valor,)
             iif(zTMP=="D",nTOTDESC+=LANC->Valor,)
             if lINIC
                lINIC := .F.
                @ prow()+1,0 say cSTRING
             else
                lINIC := .T.
                @ prow(),pcol()+2 say cSTRING
             endif
          endif
          LANC->(dbskip())
       enddo
       @ prow()+1,90 say "Total de " + iif(zTMP=="P","Proventos... ","Descontos... ") + ;
         transform(iif(zTMP=="P",nTOTPROV,nTOTDESC),"@E 999,999,999.99")
   next

   @ prow()+2,90 say "LIQUIDO A RECEBER:    " + transform(nTOTPROV-nTOTDESC,"@E 999,999,999.99")

   nBASEIS := BASE->B_inssms + BASE->B_inssdt
   nBASEIR := BASE->B_irrfms + BASE->B_irrfdt
   nBASEFG := BASE->B_fgtsms + BASE->B_fgtsdt

   @ 41,15 say "  BASE INSS: " + transform(nBASEIS,"@E 999,999.99") + space(11) + ;
               "  BASE IRRF: " + transform(nBASEIR,"@E 999,999.99") + space(11) + ;
               "  BASE FGTS: " + transform(nBASEFG,"@E 999,999.99")



   @ 44,05 say dtoc(dDT_HOMO)
   @ 44,26 say XRAZAO

   if ! Empty(SITUA->Codsaqfgts)
      @ 54,0 say XRAZAO
      @ 56,0 say left(FUN->Nome,60)
   endif

   @ 72,0 say ""      // somente para saltar para o inicio do proximo recibo

return

/////////////////////////////////////////////////////////////////////////////
// EMITE RECIBO TIPO 2 ______________________________________________________

static function i_recibo2
   local nCONT, zTMP, lINIC := .T., cSTRING
   local nTOTPROV := nTOTDESC := 0

   qmensa("Emitindo recibo para: "+FUN->Matricula+"/"+left(FUN->Nome,40))
   setprc(0,0)

   @ prow()+6,0      say XCOND1 + FILIAL->Razao + space(7) + CONFIG->Conta_fgts
   @ prow()  ,92     say XAEXPAN + transform(FILIAL->Cgccpf,"@R 99.999.999/9999-99") + XDEXPAN
   @ prow()+2,0      say FILIAL->Endereco + " " + str(FILIAL->Numero,5)
   @ prow()  ,92     say left(FILIAL->Razao,42) + iif(!empty(subs(FILIAL->Razao,43)),"-","")
   @ prow()+1,92     say alltrim(subs(FILIAL->Endereco,42)) + FILIAL->Bairro
   CGM->(dbseek(XCGM))
   @ prow()+1,0      say transform(FILIAL->Cep,"@R 99.999-999") + space(12) + FILIAL->Bairro + space(10) + left(CGM->Municipio,25) + space(6) + CGM->Estado
   @ prow()  ,92     say left(FILIAL->Endereco,32) + " " + str(FILIAL->Numero,5) + iif(!empty(subs(FILIAL->Endereco,43)),"-","")
   @ prow()+1,92     say subs(FILIAL->Endereco,43)
   BANCO->(dbseek(CONFIG->Banco_fgts))
   @ prow()+1,0      say BANCO->Codigo+"-"+left(BANCO->Descricao,20) + space(10)
   @ prow()  ,pcol() say BANCO->Agencia + space(36) + BANCO->Agencia
   @ prow()  ,92     say FILIAL->Cep + " - " + alltrim(CGM->Municipio) + " - " + CGM->Estado
   @ prow()+2,0      say left(FUN->Nome,60) + space(16) + FUN->Matricula + space(14)
   CGM->(dbseek(FUN->Cp_cgm))
   @ prow(),pcol()   say FUN->Cp_num + space(17) + FUN->Cp_serie + space(5) + CGM->Estado
   @ prow()+2,0      say FUN->Pis_num + space(27) + FUN->Fgts_num + space(17)
   @ prow(),pcol()   say dtoc(FUN->Data_nasc) + space(08) + dtoc(FUN->Data_adm) + space(09)
   @ prow(),pcol()   say dtoc(FUN->Fgts_dat) + space(08) + dtoc(SITUA->Af_ini)
   @ prow()+2,0      say transform(SITUA->Salario,"@E 999,999,999.99") + space(21)
   @ prow(),pcol()   say dtoc(SITUA->Inicio_av) + space(26) + AFAST->Descricao + space(17)
   @ prow(),pcol()   say iif(empty(SITUA->Codsaqfgts),"*****",SITUA->Codsaqfgts)
   @ prow()+2,0      say ""

   for nCONT := 1 to 2
       zTMP := iif(nCONT==1,"P","D")

       @ prow()+2,0 say "--- "+iif(zTMP=="P","PROVENTOS","DESCONTOS")+" ----------------------- REFERENCIA ------- VALOR -------------------------------------- REFERENCIA ------- VALOR"

       lINIC := .T.
       LANC->(dbseek(XANOMES+FUN->Matricula+"MS"))
       do while LANC->Matricula == FUN->Matricula .and. LANC->Ambiente == "MS"
          if EVENT->Finalidade == zTMP .and. LANC->Valor <> 0
             cSTRING := LANC->Evento + "-" + left(EVENT->Descricao,37) + " "
             cSTRING += transform(LANC->Fracao,"@E 999.99") + " "
             cSTRING += transform(LANC->Valor,"@E 99,999,999.99")
             iif(zTMP=="P",nTOTPROV+=LANC->Valor,)
             iif(zTMP=="D",nTOTDESC+=LANC->Valor,)
             if lINIC
                lINIC := .F.
                @ prow()+1,0 say cSTRING
             else
                lINIC := .T.
                @ prow(),pcol()+2 say cSTRING
             endif
          endif
          LANC->(dbskip())
       enddo
       @ prow()+1,90 say "Total de " + iif(zTMP=="P","Proventos... ","Descontos... ") + ;
         transform(iif(zTMP=="P",nTOTPROV,nTOTDESC),"@E 999,999,999.99")
   next

   @ prow()+2,90 say "LIQUIDO A RECEBER:    " + transform(nTOTPROV-nTOTDESC,"@E 999,999,999.99")

   nBASEIS := BASE->B_inssms + BASE->B_inssdt
   nBASEIR := BASE->B_irrfms + BASE->B_irrfdt
   nBASEFG := BASE->B_fgtsms + BASE->B_fgtsdt

   @ 38,15 say "  BASE INSS: " + transform(nBASEIS,"@E 999,999.99") + space(11) + ;
               "  BASE IRRF: " + transform(nBASEIR,"@E 999,999.99") + space(11) + ;
               "  BASE FGTS: " + transform(nBASEFG,"@E 999,999.99")


   @ 41,05 say dtoc(dDT_HOMO)
   @ 41,26 say XRAZAO

   if ! empty(SITUA->Codsaqfgts)
      @ 53,0 say XRAZAO
      @ 56,0 say left(FUN->Nome,60)
   endif

   @ 72,0 say ""      // somente para saltar para o inicio do proximo recibo

return

/////////////////////////////////////////////////////////////////////////////
// EMITE RECIBO TIPO 3 ______________________________________________________

static function i_recibo3
   local nCONT, zTMP, lINIC := .T., cSTRING
   local nTOTPROV := nTOTDESC := 0

   qmensa("Emitindo recibo para: "+FUN->Matricula+"/"+left(FUN->Nome,40))
   setprc(0,0)

   @ prow()+6,0      say XCOND1 + FILIAL->Razao + space(7) + CONFIG->Conta_fgts
   @ prow()  ,88     say XAEXPAN + transform(FILIAL->Cgccpf,"@R 99.999.999/9999-99") + XDEXPAN
   @ prow()+2,0      say FILIAL->Endereco + " " + str(FILIAL->Numero,5)
   @ prow()  ,88     say left(FILIAL->Razao,42) + iif(!empty(subs(FILIAL->Razao,43)),"-","")
   @ prow()+1,88     say subs(FILIAL->Razao,43)
   CGM->(dbseek(FILIAL->Cgm))
   @ prow()+1,0      say transform(FILIAL->Cep,"@R 99.999-999") + space(12) + FILIAL->Bairro + space(10) + left(CGM->Municipio,25) + space(3) + CGM->Estado
   @ prow()  ,88     say left(FILIAL->Endereco,42) + iif(!empty(subs(FILIAL->Endereco,43)),"-","") + " " + str(FILIAL->Numero,5)
   @ prow()+1,88     say alltrim(subs(FILIAL->Endereco,43) + space(5)) + FILIAL->Bairro
   BANCO->(dbseek(CONFIG->Banco_fgts))
   @ prow()+1,0      say BANCO->Codigo+"-"+left(BANCO->Descricao,20) + space(10)
   @ prow()  ,pcol() say BANCO->Agencia + space(33) + BANCO->Agencia
   @ prow()  ,88     say FILIAL->Cep + " - " + alltrim(CGM->Municipio) + " - " + CGM->Estado
   @ prow()+2,0      say left(FUN->Nome,60) + space(16) + FUN->Matricula + space(8)
   CGM->(dbseek(FUN->Cp_cgm))
   @ prow(),pcol()   say "Num. "+FUN->Cp_num+"   Serie: "+FUN->Cp_serie+"   UF: "+CGM->Estado
   @ prow()+2,0      say FUN->Pis_num + space(27) + FUN->Fgts_num + space(17)
   @ prow(),pcol()   say dtoc(FUN->Data_nasc) + space(10) + dtoc(FUN->Data_adm) + space(8)
   @ prow(),pcol()   say dtoc(FUN->Fgts_dat) + space(10) + dtoc(SITUA->Af_ini)
   @ prow()+2,0      say transform(SITUA->Salario,"@E 999,999,999.99") + space(20)
   @ prow(),pcol()   say dtoc(SITUA->Inicio_av) + space(26) + AFAST->Descricao + space(20)
   @ prow(),pcol()   say iif(empty(SITUA->Codsaqfgts),"*****",SITUA->Codsaqfgts)
   @ prow()+1,0      say ""

   for nCONT := 1 to 2
       zTMP := iif(nCONT==1,"P","D")

       @ prow()+2,0 say "--- "+iif(zTMP=="P","PROVENTOS","DESCONTOS")+" ----------------------- REFERENCIA ------- VALOR -------------------------------------- REFERENCIA ------- VALOR"

       lINIC := .T.
       LANC->(dbseek(XANOMES+FUN->Matricula+"MS"))
       do while LANC->Matricula == FUN->Matricula .and. LANC->Ambiente == "MS"
          if EVENT->Finalidade == zTMP .and. LANC->Valor <> 0
             cSTRING := LANC->Evento + "-" + left(EVENT->Descricao,37) + " "
             cSTRING += transform(LANC->Fracao,"@E 999.99") + " "
             cSTRING += transform(LANC->Valor,"@E 99,999,999.99")
             iif(zTMP=="P",nTOTPROV+=LANC->Valor,)
             iif(zTMP=="D",nTOTDESC+=LANC->Valor,)
             if lINIC
                lINIC := .F.
                @ prow()+1,0 say cSTRING
             else
                lINIC := .T.
                @ prow(),pcol()+2 say cSTRING
             endif
          endif
          LANC->(dbskip())
       enddo
       @ prow()+1,90 say "Total de " + iif(zTMP=="P","Proventos... ","Descontos... ") + ;
         transform(iif(zTMP=="P",nTOTPROV,nTOTDESC),"@E 999,999,999.99")
   next

   @ prow()+2,90 say "LIQUIDO A RECEBER:    " + transform(nTOTPROV-nTOTDESC,"@E 999,999,999.99")

   nBASEIS := BASE->B_inssms + BASE->B_inssdt
   nBASEIR := BASE->B_irrfms + BASE->B_irrfdt
   nBASEFG := BASE->B_fgtsms + BASE->B_fgtsdt

   @ 41,15 say "  BASE INSS: " + transform(nBASEIS,"@E 999,999.99") + space(11) + ;
               "  BASE IRRF: " + transform(nBASEIR,"@E 999,999.99") + space(11) + ;
               "  BASE FGTS: " + transform(nBASEFG,"@E 999,999.99")



   @ 44,05 say dtoc(dDT_HOMO)
   @ 44,26 say XRAZAO

   if ! empty(SITUA->Codsaqfgts)
      @ 54,0 say XRAZAO
      @ 56,0 say left(FUN->Nome,60)
   endif

   @ 72,0 say ""      // somente para saltar para o inicio do proximo recibo

return

/////////////////////////////////////////////////////////////////////////////
// EMITE RECIBO EM FORMULARIO CONTINUO ______________________________________

static function i_recibo4
   local nCONT, zTMP, lINIC := .T., cSTRING
   local nTOTPROV := nTOTDESC := 0
   local cLINHA1 := "|" + replicate("-",135) + "|"
   local cLINHA2 := "|" + space(135) + "|"
   local cLINHA3 := "|" + replicate("=",135) + "|"
     
   qmensa("Emitindo recibo para: "+FUN->Matricula+"/"+left(FUN->Nome,40))
   setprc(0,0)

   @ prow()+1,0      say XCOND1 + cLINHA3
   @ prow()+1,0      say "|" + XCOND0 + XAEXPAN + "RESCISAO-CONT. DE TRABALHO" + XDEXPAN + XCOND1 + " |"
   @ prow()  ,40     say XCOND1 + XAEXPAN + transform(FILIAL->Cgccpf,"@R 99.999.999/9999-99") + XDEXPAN + XCOND1 + space(7) + "|"
   @ prow()+1,0      say "|" + repl("=",90) + "|"
   @ prow()  ,93     say left(FILIAL->Razao,42) + iif(!empty(subs(FILIAL->Razao,43)),"-","")
   @ prow()  ,136    say "|"
   @ prow()+1,0      say "|" + XCOND0 + XAEXPAN + "IDENTIFICACAO" + XDEXPAN + XCOND1 + space(45) + "| " + right(FILIAL->Razao,7) + space(36) + "|"
   @ prow()+1,0      say "|" + repl("=",90) + "|"
   @ prow()  ,136    say "|"
   @ prow()+1,0      say "| " + "Empregador: " + left(FILIAL->Razao,51) + space(4) + "Codigo: " + CONFIG->Conta_fgts + " |"
   @ prow()  ,93     say left(FILIAL->Endereco,36) + " " + str(FILIAL->Numero,5) + iif(!empty(subs(FILIAL->Endereco,43)),"-","")
   @ prow()  ,136    say "|"
   @ prow()+1,0      say "| " + "Endereco: " + FILIAL->Endereco + " " + str(FILIAL->Numero,5) + space(33) + "|"
   @ prow()  ,93     say alltrim(subs(FILIAL->Endereco,43)) + FILIAL->Bairro
   @ prow()  ,136    say "|"
   CGM->(dbseek(FILIAL->Cgm))
   @ prow()+1,0      say "| " + "Cep: " + transform(FILIAL->Cep,"@R 99.999-999") + space(2) + "Bairro: " + FILIAL->Bairro + space(2) + "Municipio: " + left(CGM->Municipio,20) + space(2) + "UF: " + CGM->Estado + "   |"
   @ prow()  ,93     say FILIAL->Cep + " - " + alltrim(CGM->Municipio) + " - " + CGM->Estado
   @ prow()  ,136    say "|"
   BANCO->(dbseek(CONFIG->Banco_fgts))
   @ prow()+1,0      say "| " + "Banco: " + BANCO->Codigo + "-" + left(BANCO->Descricao,25) + space(5)
   @ prow()  ,pcol() say "Agencia: " + BANCO->Agencia + space(21) + " - " + BANCO->Agencia + "     *" + repl("-",44)
   @ prow()  ,136    say "|"
   @ prow()+1,0      say "| " + "Empregado: " + left(FUN->Nome,40) + space(13) + "Matricula: " + FUN->Matricula + space(4)
   CGM->(dbseek(FUN->Cp_cgm))
   @ prow(),pcol()   say "Cart. Trabalho: " + FUN->Cp_num + "    Serie: " + FUN->Cp_serie + "    UF: " + CGM->Estado
   @ prow()  ,136    say "|"
   @ prow()+1,0      say "| " + "Pis/Pasep: " + FUN->Pis_num + space(1) + "Cod. Empregado: " + FUN->Fgts_num + space(1)
   @ prow(),pcol()   say "Nascimento: " + dtoc(FUN->Data_nasc) + space(1) + "Admissao: " + dtoc(FUN->Data_adm) + space(1)
   @ prow(),pcol()   say "Opcao: " + dtoc(FUN->Fgts_dat) + space(1) + "Afastamento: " + dtoc(SITUA->Af_ini)
   @ prow()  ,136    say "|"
   @ prow()+1,0      say "| " + "Maior Remuneracao: " + transform(SITUA->Salario,"@E 999,999,999.99") + space(5)
   @ prow(),pcol()   say "Aviso Previo: " + dtoc(SITUA->Inicio_av) + space(5) + "Causa Afastamento: " + AFAST->Descricao + space(3)
   @ prow(),pcol()   say "Cod. Saque: " + iif(empty(SITUA->Codsaqfgts),"**",SITUA->Codsaqfgts)
   @ prow()  ,136    say "|"
   @ prow()+1,0      say "| Cargo: " + CARGO->Codigo + "-" + CARGO->Descricao + space(20) + " Pensao Alimenticia: " + transform(nPERC,"@R 99.99") + "%"
   @ prow()  ,136    say "|"
   @ prow()+1,0      say cLINHA3
   @ prow()+1,0      say "|" + XCOND0 + XAEXPAN + "DISCRIMINACAO/RECIBO VERBAS RESCISORIAS" + XDEXPAN + XCOND1 + " |"
   @ prow()+1,0      say cLINHA3

   for nCONT := 1 to 2
       zTMP := iif(nCONT==1,"P","D")

       @ prow()+1,0 say "| --- "+iif(zTMP=="P","PROVENTOS","DESCONTOS")+" ------------------------ REFERENCIA ------- VALOR      ------------------------------------- REFERENCIA ------- VALOR   |"

       lINIC := .T.
       LANC->(dbseek(XANOMES+FUN->Matricula+"MS"))
       do while LANC->Matricula == FUN->Matricula .and. LANC->Ambiente == "MS"
          if EVENT->Finalidade == zTMP .and. LANC->Valor <> 0
             cSTRING := LANC->Evento + "-" + left(EVENT->Descricao,37) + " "
             cSTRING += transform(LANC->Fracao,"@E 999.99") + " "
             cSTRING += transform(LANC->Valor,"@E 99,999,999.99")
             iif(zTMP=="P",nTOTPROV+=LANC->Valor,)
             iif(zTMP=="D",nTOTDESC+=LANC->Valor,)
             if lINIC
                lINIC := .F.
                @ prow()+1,0   say "|  " + cSTRING
                @ prow()  ,136 say "|"
             else
                lINIC := .T.
                @ prow(),68  say "|  " + cSTRING
                @ prow(),136 say "|"
             endif
          endif
          LANC->(dbskip())
       enddo
       @ prow()+1,0 say "|"
       @ prow()  ,97  say "Total de " + iif(zTMP=="P","Proventos... ","Descontos... ") + ;
                       transform(iif(zTMP=="P",nTOTPROV,nTOTDESC),"@E 999,999,999.99")
       @ prow()  ,136 say "|"
       @ prow()+1,0   say cLINHA2
   next
   @ prow()+1,0   say cLINHA2
   @ prow()+1,0   say "|"
   @ prow()  ,97  say "LIQUIDO A RECEBER:    " + transform(nTOTPROV-nTOTDESC,"@E 999,999,999.99")
   @ prow()  ,136 say "|"

   nBASEIS := BASE->B_inssms + BASE->B_inssdt
   nBASEIR := BASE->B_irrfms + BASE->B_irrfdt
   nBASEFG := BASE->B_fgtsms + BASE->B_fgtsdt

   @ prow()+1,0   say cLINHA2
   @ prow()+1,0   say "|"
   @ prow()  ,22  say "  BASE INSS: " + transform(nBASEIS,"@E 999,999.99") + space(11) + ;
                      "  BASE IRRF: " + transform(nBASEIR,"@E 999,999.99") + space(11) + ;
                      "  BASE FGTS: " + transform(nBASEFG,"@E 999,999.99")
   @ prow()  ,136 say "|"

   @ prow()+1,0   say cLINHA1
   @ prow()+1,0   say "| Data da Homologacao |"
   @ prow()  ,24  say "Carimbo e Assinatura do Empregador/Preposto"
   @ prow()  ,95 say "| Imp.Dig.Empregado"
   @ prow()  ,114 say "| Imp.Dig.Responsavel"
   @ prow()  ,136 say "|"
   @ prow()+1,0   say "|"
   @ prow()  ,22  say "|"
   @ prow()  ,95  say "|                  |"
   @ prow()  ,136 say "|"
   @ prow()+1,0   say "|"+iif( !empty(dDT_HOMO), space(5)+dtoc(dDT_HOMO), "       /     /       " )
   @ prow()  ,22  say "| " + cPREP
   @ prow()  ,95  say "|                  |"
   @ prow()  ,136 say "|"
   @ prow()+1,0   say "|" + repl("-",94) + "|"
   @ prow()  ,114 say "|"
   @ prow()  ,136 say "|"
   @ prow()+1,0   say "| Assinatura do Empregado:"
   @ prow()  ,95  say "|                  |"
   @ prow()  ,136 say "|"
   @ prow()+1,0   say "|" + repl("-",94) + "|"
   @ prow()  ,114 say "|"
   @ prow()  ,136 say "|"
   @ prow()+1,0   say "| Assinatura do Responsavel Legal:"
   @ prow()  ,95  say "|                  |"
   @ prow()  ,136 say "|"
   @ prow()+1,0   say cLINHA3
   @ prow()+1,0   say "|" + XCOND0 + XAEXPAN + "RECIBO DO FGTS" + XDEXPAN + XCOND1
   @ prow()  ,71  say "| Data de Recepcao Pelo Banco"
   @ prow()  ,112 say "|"
   @ prow()+1,0   say "|" + repl("=",94) + "|"
   @ prow()  ,136 say "|"
   @ prow()+1,0   say "| Carimbo e Assinatura Autorizada da Empresa"
   @ prow()  ,95  say "|"
   @ prow()  ,136 say "|"
   @ prow()+1,0   say "| "+ iif(SITUA->Af_cod != "21",cPREP," ")
   @ prow()  ,95  say "|"
   @ prow()  ,136 say "|"
   @ prow()+1,0   say cLINHA1
   @ prow()+1,0   say "| SACADOR - NOME: " + iif(SITUA->Af_cod != "21",left(FUN->Nome,60)," ")
   @ prow()  ,106 say "|     Carimbo da Agencia"
   @ prow()  ,136 say "|"
   @ prow()+1,0   say "|" + repl("-",105) + "|"
   @ prow()  ,136 say "|"
   @ prow()+1,0   say "| Valor do Saque - Depositos     | Juros e Correcao Monetaria     | Total do Saque"
   @ prow()  ,106 say "|"
   @ prow()  ,136 say "|"
   @ prow()+1,0   say "|                                |                                |"
   @ prow()  ,106 say "|"
   @ prow()  ,136 say "|"
   @ prow()+1,0   say "|                                |                                |"
   @ prow()  ,106 say "|"
   @ prow()  ,136 say "|"
   @ prow()+1,0   say "|" + repl("-",105) + "|"
   @ prow()  ,136 say "|"
   @ prow()+1,0   say "| Imp.Dig.Sacador | Imp.Dig.Responsavel | Ass. Sacador:"
   @ prow()  ,106 say "|"
   @ prow()  ,136 say "|"
   @ prow()+1,0   say "|                 |                     |" + repl("-",65) + "|"
   @ prow()  ,136 say "|"
   @ prow()+1,0   say "|                 |                     | Ass. Respons:"
   @ prow()  ,106 say "|"
   @ prow()  ,136 say "|"
   @ prow()+1,0   say "|                 |                     |" + repl("-",95)
   @ prow()  ,136 say "|"
   @ prow()+1,0   say "|                 |                     | Autenticacao:"
   @ prow()  ,136 say "|"
   @ prow()+1,0   say "|                 |                     |              "
   @ prow()  ,136 say "|"
   @ prow()+1,0   say "|                 |                     |              "
   @ prow()  ,136 say "|"
   @ prow()+1,0   say cLINHA3
   @ prow()+1,3   say "1. via - CEF                      2. via - BANCO                      3. via - EMPREGADO                      4. via - EMPREGADOR"
   @ prow()+1,3   say "A Assistencia na Rescisao Contratual e Gratuita"
   __eject()

return

/////////////////////////////////////////////////////////////////////////////
// EMITE RECIBO EM FORMULARIO CONTINUO ______________________________________

static function i_recibo5
   local nCONT, zTMP, lINIC := .T., cSTRING
   local nTOTPROV := nTOTDESC := 0
   local cLINHA1 := "*" + replicate("-",135) + "*"
   local cLINHA2 := "|" + space(135) + "|"
   local cLINHA3 := "|" + replicate("=",135) + "*"
   local nCAM_29 := nCAM_30 := nCAM_31 := nCAM_32 := nCAM_33 := nCAM_34 := nCAM_35 := nCAM_36 := nCAM_37 := nCAM_50 := 0
   local nCAM_38 := nCAM_39 := nCAM_40 := nCAM_41 := nCAM_46 := nCAM_47 := nCAM_48 := nCAM_49 := nCAM_54 := nCAM_55 := 0
   local nFRA31 := nFRA32 := nFRA34 := nFRA36 := nFRA40 := nZERO := nDED := nPROV := nLIQ := nCAM_51 := 0
     
   qmensa("Emitindo recibo para: "+FUN->Matricula+"/"+left(FUN->Nome,40))
   setprc(0,0)

   @ prow()+1,0      say XCOND1 + cLINHA1
   @ prow()+1,0      say "|" + XCOND0 +  "                   TERMO DE RESCISAO DO CONTRATO DE TRABALHO" + XCOND1+ "                                |"
   @ prow()+1,0      say XCOND1 + cLINHA1
   CGM->(dbseek(FILIAL->Cgm))
   @ prow()+1,0      say "| " +"Identificacao"  + " | " + "01 CNPJ/CEI.: "+transform(FILIAL->Cgccpf,"@R 99.999.999/9999-99") + " | "+ "02 Razao Social/Nome: "+left(FILIAL->Razao,42)+ "                   |"
   @ prow()+1,0      say "| " +"     do      "  + " | " + "03 Endereco.: "+left(FILIAL->Endereco,36)+ " " + str(FILIAL->Numero,5) + left(FILIAL->Compl,15) + " | " + "04 Bairro.: " +FILIAL->Bairro + "            |"
   @ prow()+1,0      say "| " +" Empregador  "  + " | " + "05 Municipio: "+ CGM->Municipio + " | " + "06 UF.: " + CGM->Estado + " | " + "07 CEP.: " + transform(FILIAL->Cep,"@R 99.999-999") + " | " + "08 CNAE.: " +CONFIG->Cnae  + "                 |"
   @ prow()+1,0      say "| " +"             "  + " | " + "09 CNPJ (Tomador obra):" + space(94)+ " |"
   @ prow()+1,0      say XCOND1 + cLINHA1
   CGM->(dbseek(FUN->Resid_cgm))
   @ prow()+1,0      say "| " +"Identificacao"  + " | " + "10 PIS/PASEP.: " +FUN->Pis_num + " | " + "11 Nome.: " + left(FUN->Nome,70) + "         |"
   @ prow()+1,0      say "| " +"     do      "  + " | " + "12 Endereco.: " + FUN->Endereco + " | " + "13 Bairro.: " + FUN->Bairro + "                        |"
   CGM->(dbseek(FUN->CP_cgm))
   @ prow()+1,0      say "| " +" Trabalhador "  + " | " + "14 Municip.: " + left(CGM->Municipio,26) + " |" + "15 UF.: " + CGM->Estado + " | " + "16 CEP.: " +transform(FUN->Cep,"@R 99.999-999") + " |" + "17 Cart.Trab.: "+ FUN->Cp_num + " Serie: " + FUN->cp_serie + " UF: " + CGM->Estado + " |"
   @ prow()+1,0      say "| " +"             "  + " | " + "18 CPF.: " + FUN->Cpf_num + " | " + "19 Data de Nascimento.: " + dtoc(FUN->Data_nasc) + " | " + "20 Nome da Mae.: " + Left(FUN->Nome_mae,40) + "|"
   @ prow()+1,0      say XCOND1 + cLINHA1

   @ prow()+1,0      say "| " +"   Dados     "  + " | " + "21 Remuneracao p/ fins rescisorios.: " + transf(SITUA->Salario,"@E 99,999.99") + " | " + "22 Data Admissao.: "+ dtoc(FUN->Data_adm)+ " |" + "23 Data do Aviso Previo.: "+ dtoc(SITUA->Inicio_av)+ "  |"
   @ prow()+1,0      say "| " +"     do      "  + " | " + "24 Data do afastamento.:" + dtoc(SITUA->Af_ini)+ " |" + "25 Causa do Afastamento.: " + AFAST->Descricao + " |" +  "26 Cod. Afastamento: " + SITUA->Codsaqfgts + " |"
   @ prow()+1,0      say "| " +"  Contrato   "  + " | " + "27 Pensao alimenticia (%) .: " + transf(nPERC,"@E 99.99") + " | " + "28 Categoria do Trabalhador.: " + "01"+space(48)+ " |"
   @ prow()+1,0      say XCOND1 + cLINHA1
   @ prow()+1,0      say "|" + XCOND0 + XAEXPAN + "DISCRIMINACAO DAS VERBAS RESCISORIAS   " + XDEXPAN + XCOND1 + " |"
   @ prow()+1,0      say cLINHA3

   if LANC->(dbseek(XANOMES+FUN->Matricula+"MS150"))
      nCAM_29 := LANC->Valor
   endif

   if LANC->(dbseek(XANOMES+FUN->Matricula+"MS102"))
      nCAM_30 := LANC->Valor
      nFRA30  := LANC->Fracao
      nFRA36  := LANC->Fracao
   endif

   if LANC->(dbseek(XANOMES+FUN->Matricula+"MS814"))
      nCAM_31 := LANC->Valor
      nFRA31 := LANC->Fracao
   endif

   if LANC->(dbseek(XANOMES+FUN->Matricula+"MS813"))
      nCAM_32 := LANC->Valor
      nFRA32 := nFRA31
   endif

   if LANC->(dbseek(XANOMES+FUN->Matricula+"MS184"))
      nCAM_33 := LANC->Valor
   endif

   if LANC->(dbseek(XANOMES+FUN->Matricula+"MS182"))
      nCAM_34 := LANC->Valor
      nFRA34  := LANC->Fracao
   endif

   if LANC->(dbseek(XANOMES+FUN->Matricula+"MS183"))
      nCAM_35 += LANC->Valor
   endif

   if LANC->(dbseek(XANOMES+FUN->Matricula+"MS185"))
      nCAM_35 += LANC->Valor
   endif

   if LANC->(dbseek(XANOMES+FUN->Matricula+"MS901"))
      nCAM_36 := LANC->Valor
   endif

   if LANC->(dbseek(XANOMES+FUN->Matricula+"MS412"))
      nCAM_37 := LANC->Valor
   endif

   if LANC->(dbseek(XANOMES+FUN->Matricula+"MS108"))
      nCAM_38 := LANC->Valor
   endif

   if LANC->(dbseek(XANOMES+FUN->Matricula+"MS702"))
      nCAM_39 := LANC->Valor
   endif

   if LANC->(dbseek(XANOMES+FUN->Matricula+"MS311"))
      nCAM_40 += LANC->Valor
      nFRA40 += LANC->Fracao
   endif

   if LANC->(dbseek(XANOMES+FUN->Matricula+"MS308"))
      nCAM_40 += LANC->Valor
      nFRA40 += LANC->Fracao

   endif
   if LANC->(dbseek(XANOMES+FUN->Matricula+"MS314"))
      nCAM_40 += LANC->Valor
      nFRA40 += LANC->Fracao

   endif
   if LANC->(dbseek(XANOMES+FUN->Matricula+"MS315"))
      nCAM_40 += LANC->Valor
      nFRA40 += LANC->Fracao

   endif
   if LANC->(dbseek(XANOMES+FUN->Matricula+"MS319"))
      nCAM_40 += LANC->Valor
      nFRA40 += LANC->Fracao

   endif
   if LANC->(dbseek(XANOMES+FUN->Matricula+"MS312"))
      nCAM_40 += LANC->Valor
      nFRA40 += LANC->Fracao

   endif
   if LANC->(dbseek(XANOMES+FUN->Matricula+"MS318"))
      nCAM_40 += LANC->Valor
      nFRA40 += LANC->Fracao

   endif
   if LANC->(dbseek(XANOMES+FUN->Matricula+"MS316"))
      nCAM_40 += LANC->Valor
      nFRA40 += LANC->Fracao

   endif
   if LANC->(dbseek(XANOMES+FUN->Matricula+"MS313"))
      nCAM_40 += LANC->Valor
      nFRA40 += LANC->Fracao

   endif
   if LANC->(dbseek(XANOMES+FUN->Matricula+"MS338"))
      nCAM_40 += LANC->Valor
      nFRA40 += LANC->Fracao

   endif
   if LANC->(dbseek(XANOMES+FUN->Matricula+"MS320"))
      nCAM_40 += LANC->Valor
      nFRA40 += LANC->Fracao

   endif
   if LANC->(dbseek(XANOMES+FUN->Matricula+"MS329"))
      nFRA40 += LANC->Fracao
      nCAM_40 += LANC->Valor
   endif
   if LANC->(dbseek(XANOMES+FUN->Matricula+"MS330"))
      nFRA40 += LANC->Fracao
      nCAM_40 += LANC->Valor
   endif
   if LANC->(dbseek(XANOMES+FUN->Matricula+"MS327"))
      nFRA40 += LANC->Fracao
      nCAM_40 += LANC->Valor
   endif
   if LANC->(dbseek(XANOMES+FUN->Matricula+"MS328"))
      nFRA40 += LANC->Fracao
      nCAM_40 += LANC->Valor
   endif
   if LANC->(dbseek(XANOMES+FUN->Matricula+"MS335"))
      nFRA40 += LANC->Fracao
      nCAM_40 += LANC->Valor
   endif
   if LANC->(dbseek(XANOMES+FUN->Matricula+"MS910"))
      nCAM_47 := LANC->Valor
   endif
   if LANC->(dbseek(XANOMES+FUN->Matricula+"MS914"))
      nCAM_48 += LANC->Valor
   endif
   if LANC->(dbseek(XANOMES+FUN->Matricula+"MS701"))
      nCAM_49 += LANC->Valor
   endif
   if LANC->(dbseek(XANOMES+FUN->Matricula+"MS920"))
      nCAM_50 += LANC->Valor
   endif
   if LANC->(dbseek(XANOMES+FUN->Matricula+"MS922"))
      nCAM_50 += LANC->Valor
   endif

   if LANC->(dbseek(XANOMES+FUN->Matricula+"MS207"))
      nCAM_51 += LANC->Valor
   endif

   nZERO := 0
   nPROV := nCAM_29 + nCAM_30 + nCAM_31 + nCAM_32 + nCAM_33 + nCAM_34 + nCAM_35 + nCAM_36 +nCAM_37 + nCAM_38 + nCAM_39 + nCAM_40 + nCAM_41
   nDED  := nCAM_47 + nCAM_48 + nCAM_49 + nCAM_50 + nCAM_51
   nLIQ := nPROV - nDED
   @ prow()+1,0      say "| " + "                           | " + "Valor         |" + "                              | "  + "Valor       |" + "                " + "   DEDUCOES                " + "  |"
   @ prow()+1,0      say "| " + "29 Aviso Previo Indenizado | " + "    "+transf(nCAM_29,"@E 9,999.99")+ "  |" + " 38 Comissoes                 |" + "    "+transf(nCAM_38,"@E 9,999.99") + " |" + " 47 Previdencia             |" + "      " +transf(nCAM_47,"@E 9,999.99") + "  |"
   @ prow()+1,0      say XCOND1 + cLINHA1
   @ prow()+1,0      say "| " + "30 Saldo de Salario "+transf(nFRA30,"@R 99") +" Dias| " + "    "+transf(nCAM_30,"@E 9,999.99")+ "  |" + " 39 Gratificacoes             |" + "    "+transf(nCAM_39,"@E 9,999.99") + " |" + " 48 Previdencia 13o Salario |" + "      " +transf(nCAM_48,"@E 9,999.99") + "  |"
   @ prow()+1,0      say XCOND1 + cLINHA1
   @ prow()+1,0      say "| " + "31 13o Salario "+transf(nFRA31,"@R 99") +"/12 Avos  | " + "    "+transf(nCAM_31,"@E 9,999.99")+ "  |" + " 40 Horas extras "+transf(nFRA40,"@R 999")+" horas    |" + "    "+transf(nCAM_40,"@E 9,999.99") + " |" + " 49 Adiantamentos           |" + "      " +transf(nCAM_49,"@E 9,999.99") + "  |"
   @ prow()+1,0      say XCOND1 + cLINHA1
   @ prow()+1,0      say "| " + "32 13 Sal.inden. "+transf(nFRA32,"@R 99") +"/12 Avos| " + "    "+transf(nCAM_32,"@E 9,999.99")+ "  |" + " 41 Adic insalub/periculosid. |" + "    "+transf(nCAM_41,"@E 9,999.99") + " |" + " 50 I.R.R.F.                |" + "      " +transf(nCAM_50,"@E 9,999.99") + "  |"
   @ prow()+1,0      say XCOND1 + cLINHA1
   @ prow()+1,0      say "| " + "33 Ferias vencidas         | " + "    "+transf(nCAM_33,"@E 9,999.99")+ "  |" + " 42                           |" + "    "+transf(nZERO,"@E 9,999.99")   + " |" + " 51 Vale Transporte         |" + "      " +transf(nCAM_51,"@E 9,999.99") + "  |"
   @ prow()+1,0      say XCOND1 + cLINHA1
   @ prow()+1,0      say "| " + "34 Ferias prop. "+transf(nFRA34,"@R 99") +"/12 Avos | " + "    "+transf(nCAM_34,"@E 9,999.99")+ "  |" + " 43                           |" + "    "+transf(nZERO,"@E 9,999.99")   + " |" + " 52                         |" + "      " +transf(nZERO,"@E 9,999.99") + "  |"
   @ prow()+1,0      say XCOND1 + cLINHA1
   @ prow()+1,0      say "| " + "35 1/3 Salario s/ferias    | " + "    "+transf(nCAM_35,"@E 9,999.99")+ "  |" + " 44                           |" + "    "+transf(nZERO,"@E 9,999.99")   + " |" + " 53                         |" + "      " +transf(nZERO,"@E 9,999.99") + "  |"
   @ prow()+1,0      say XCOND1 + cLINHA1
   @ prow()+1,0      say "| " + "36 Salario familia "+transf(nFRA36,"@R 99")+" dias | " + "    "+transf(nCAM_36,"@E 9,999.99")+ "  |" + " 45                           |" + "    "+transf(nZERO,"@E 9,999.99")   + " |" + " 54 TOTAL DAS DEDUCOES      |" + "      " +transf(nDED,"@E 9,999.99") + "  |"
   @ prow()+1,0      say XCOND1 + cLINHA1
   @ prow()+1,0      say "| " + "37 Adicional Noturno       | " + "    "+transf(nCAM_37,"@E 9,999.99")+ "  |" + " 46   TOTAL BRUTO             |" + "    "+transf(nPROV,"@E 9,999.99")   + " |" + " 55 LIQUIDO A RECEBER       |" + "      " +transf(nLIQ,"@E 9,999.99") + "  |"
   @ prow()+1,0      say XCOND1 + cLINHA1
   CGM->(dbgotop())
   CGM->(dbseek(FILIAL->Cgm))

   @ prow()+1,0      say "|" + XCOND0 + XAEXPAN + "      FORMALIZACAO DA RESCISAO   " + XDEXPAN + XCOND1 + "                      |"
   @ prow()+1,0      say XCOND1 + cLINHA1
   @ prow()+1,0      say "| 56 Local e data do recebimento                                     |"+"| 57 Carimbo de Assinatura do Empregador Preposto                 |"
   @ prow()+1,0      say "| "+CGM->Municipio +","+dtoc(dPGTO) + "                          |"+"| "+cPREP+space(23)+" |"
   @ prow()+1,0      say XCOND1 + cLINHA1
   @ prow()+1,0      say "| 58 Assinatura do trabalhador                                       |"+"| 59 Assinatura do responsavel legal do trabalhador               |"
   @ prow()+1,0      say "|                                                                    |"+"|                                                                 |"
   @ prow()+1,0      say XCOND1 + cLINHA1
   @ prow()+1,0      say "| 60 HOMOLOGACAO                                                     |"+" 61 Digital do trabalhador      | 62 Digital do responsavel       |"
   @ prow()+1,0      say "| Foi prestada gratuitamente assistencia ao trabalhador nos termos do|"+"                                |                                 |"
   @ prow()+1,0      say "| art 477    1o. da Consolidacao das Leis do Trabalho - CLT, sendo   |"+"                                |                                 |"
   @ prow()+1,0      say "| comprovado, neste ato, o efetivo pagamento das verbas rescisorias  |"+"                                |                                 |"
   @ prow()+1,0      say "| acima especificadas.                                               |"+"                                |                                 |"
   @ prow()+1,0      say "|                                                                    |"+"                                |                                 |"
   @ prow()+1,0      say "| ____________________________________________________               |"+"                                |                                 |"
   @ prow()+1,0      say "| Local e data                                                       |"+"                                |                                 |"
   @ prow()+1,0      say "|                                                                    |"+"                                |                                 |"
   @ prow()+1,0      say "| ____________________________________________________               |"+"                                |                                 |"
   @ prow()+1,0      say "| Carimbo e assinatura do assistente                                 |"+"------------------------------------------------------------------|"
   @ prow()+1,0      say "|--------------------------------------------------------------------|"+" 64 Recepcao pelo banco(data e carimbo)                           |"
   @ prow()+1,0      say "| 63 Identificacao do orgao homologador                              |"+"                                                                  |"
   @ prow()+1,0      say "|                                                                    |"+"                                                                  |"
   @ prow()+1,0      say "|                                                                    |"+"                                                                  |"
   @ prow()+1,0      say XCOND1 + cLINHA1




   __eject()

return

/////////////////////////////////////////////////////////////////////////////
// EMITE RECIBO EM FORMULARIO CONTINUO ______________________________________

static function i_recibo6
   local nCONT, zTMP, lINIC := .T., cSTRING
   local nTOTPROV := nTOTDESC := 0
   local cLINHA1 := "*" + replicate("-",135) + "*"
   local cLINHA2 := "|" + space(135) + "|"
   local cLINHA3 := "|" + replicate("=",135) + "*"
   local nCAM_29 := nCAM_30 := nCAM_31 := nCAM_32 := nCAM_33 := nCAM_34 := nCAM_35 := nCAM_36 := nCAM_37 := nCAM_50 := 0
   local nCAM_38 := nCAM_39 := nCAM_40 := nCAM_41 := nCAM_46 := nCAM_47 := nCAM_48 := nCAM_49 := nCAM_54 := nCAM_55 := 0
   local nFRA31 := nFRA32 := nFRA34 := nFRA36 := nFRA40 := nZERO := nDED := nPROV := nLIQ := nCAM_51 := 0
   local cUPCP := space(2)
   cUPCP := space(2)

   qmensa("Emitindo recibo para: "+FUN->Matricula+"/"+left(FUN->Nome,40))
   setprc(0,0)
   cUPCP := space(2)
   @ prow()+1,0      say XCOND1 + cLINHA1
   @ prow()+1,0      say "|" + XCOND0 +  "                   TERMO DE RESCISAO DO CONTRATO DE TRABALHO" + XCOND1+ "                                |"
   @ prow()+1,0      say XCOND1 + cLINHA1
   CGM->(dbseek(FILIAL->Cgm))
   @ prow()+1,0      say "| " +"Identificacao"  + " | " + "01 CNPJ/CEI.: "+transform(FILIAL->Cgccpf,"@R 99.999.999/9999-99") + " | "+ "02 Razao Social/Nome: "+left(FILIAL->Razao,42)+ "                   |"
   @ prow()+1,0      say "| " +"     do      "  + " | " + "03 Endereco.: "+left(FILIAL->Endereco,36)+ " " + str(FILIAL->Numero,5) + left(FILIAL->Compl,15) + " | " + "04 Bairro.: " +FILIAL->Bairro + "            |"
   @ prow()+1,0      say "| " +" Empregador  "  + " | " + "05 Municipio: "+ CGM->Municipio + " | " + "06 UF.: " + CGM->Estado + " | " + "07 CEP.: " + transform(FILIAL->Cep,"@R 99.999-999") + " | " + "08 CNAE.: " +CONFIG->Cnae  + "                 |"
   @ prow()+1,0      say "| " +"             "  + " | " + "09 CNPJ (Tomador obra):" + space(94)+ " |"
   @ prow()+1,0      say XCOND1 + cLINHA1
   CGM->(dbseek(FUN->Resid_cgm))

   @ prow()+1,0      say "| " +"Identificacao"  + " | " + "10 PIS/PASEP.: " +FUN->Pis_num + " | " + "11 Nome.: " + left(FUN->Nome,70) + "         |"
   @ prow()+1,0      say "| " +"     do      "  + " | " + "12 Endereco.: " + FUN->Endereco + " | " + "13 Bairro.: " + FUN->Bairro + "                        |"
   @ prow()+1,0      say "| " +" Trabalhador "  + " | " + "14 Municip.: " + left(CGM->Municipio,26) + " |" + "15 UF.: " + CGM->Estado + " | " + "16 CEP.: " +transform(FUN->Cep,"@R 99.999-999") + " |" + "17 Cart.Trab.: "+ FUN->Cp_num + " Serie: " + FUN->cp_serie + " UF: "
   CGM->(dbseek(FUN->Cp_cgm))
   @ prow(),pcol()   say CGM->Estado + " |"
   @ prow()+1,0      say "| " +"             "  + " | " + "18 CPF.: " + FUN->Cpf_num + " | " + "19 Nascimento: " + dtoc(FUN->Data_nasc) + " | " + "20 Nome da Mae: " + FUN->Nome_mae + " |"
   @ prow()+1,0      say XCOND1 + cLINHA1

   @ prow()+1,0      say "| " +"   Dados     "  + " | " + "21 Remuneracao p/ fins rescisorios.: " + transf(SITUA->Salario,"@E 99,999.99") + " | " + "22 Data Admissao.: "+ dtoc(FUN->Data_adm)+ " |" + "23 Data do Aviso Previo.: "+ dtoc(SITUA->Inicio_av)+ "  |"
   @ prow()+1,0      say "| " +"     do      "  + " | " + "24 Data do afastamento.:" + dtoc(SITUA->Af_ini)+ " |" + "25 Causa do Afastamento.: " + AFAST->Descricao + " |" +  "26 Cod. Afastamento: " + SITUA->Codsaqfgts + " |"
   @ prow()+1,0      say "| " +"  Contrato   "  + " | " + "27 Pensao alimenticia (%) .: " + transf(nPERC,"@E 99.99") + " | " + "28 Categoria do Trabalhador.: " + "01"+space(48)+ " |"
   @ prow()+1,0      say XCOND1 + cLINHA1
   @ prow()+1,0      say "|" + XCOND0 + XAEXPAN + "DISCRIMINACAO DAS VERBAS RESCISORIAS   " + XDEXPAN + XCOND1 + " |"
   @ prow()+1,0      say cLINHA3

   for nCONT := 1 to 2
       zTMP := iif(nCONT==1,"P","D")

       @ prow()+1,0 say "| --- "+iif(zTMP=="P","PROVENTOS","DESCONTOS")+" ------------------------ REFERENCIA ------- VALOR      ------------------------------------- REFERENCIA ------- VALOR   |"

       lINIC := .T.
       LANC->(dbseek(XANOMES+FUN->Matricula+"MS"))
       do while LANC->Matricula == FUN->Matricula .and. LANC->Ambiente == "MS"
          if EVENT->Finalidade == zTMP .and. LANC->Valor <> 0
             cSTRING := LANC->Evento + "-" + left(EVENT->Descricao,37) + " "
             cSTRING += transform(LANC->Fracao,"@E 999.99") + " "
             cSTRING += transform(LANC->Valor,"@E 99,999,999.99")
             iif(zTMP=="P",nTOTPROV+=LANC->Valor,)
             iif(zTMP=="D",nTOTDESC+=LANC->Valor,)
             if lINIC
                lINIC := .F.
                @ prow()+1,0   say "|  " + cSTRING
                @ prow()  ,136 say "|"
             else
                lINIC := .T.
                @ prow(),68  say "|  " + cSTRING
                @ prow(),136 say "|"
             endif
          endif
          LANC->(dbskip())
       enddo
       @ prow()+1,0 say "|"
       @ prow()  ,97  say "Total de " + iif(zTMP=="P","Proventos... ","Descontos... ") + ;
                       transform(iif(zTMP=="P",nTOTPROV,nTOTDESC),"@E 999,999,999.99")
       @ prow()  ,136 say "|"
       @ prow()+1,0   say cLINHA2
   next
   @ prow()+1,0   say cLINHA2
   @ prow()+1,0   say "|"
   @ prow()  ,97  say "LIQUIDO A RECEBER:    " + transform(nTOTPROV-nTOTDESC,"@E 999,999,999.99")
   @ prow()  ,136 say "|"

   nBASEIS := BASE->B_inssms + BASE->B_inssdt
   nBASEIR := BASE->B_irrfms + BASE->B_irrfdt
   nBASEFG := BASE->B_fgtsms + BASE->B_fgtsdt
   CGM->(dbgotop())
   CGM->(dbseek(FILIAL->Cgm))


   nZERO := 0
   @ prow()+1,0      say XCOND1 + cLINHA1
   @ prow()+1,0      say "|" + XCOND0 + XAEXPAN + "      FORMALIZACAO DA RESCISAO   " + XDEXPAN + XCOND1 + "                      |"
   @ prow()+1,0      say XCOND1 + cLINHA1
   @ prow()+1,0      say "| 56 Local e data do recebimento                                     |"+"| 57 Carimbo de Assinatura do Empregador Preposto                 |"
   @ prow()+1,0      say "| "+CGM->Municipio +","+dtoc(dPGTO) + "                          |"+"| "+cPREP+space(23)+" |"
   @ prow()+1,0      say XCOND1 + cLINHA1
   @ prow()+1,0      say "| 58 Assinatura do trabalhador                                       |"+"| 59 Assinatura do responsavel legal do trabalhador               |"
   @ prow()+1,0      say "|                                                                    |"+"|                                                                 |"
   @ prow()+1,0      say XCOND1 + cLINHA1
   @ prow()+1,0      say "| 60 HOMOLOGACAO                                                     |"+" 61 Digital do trabalhador      | 62 Digital do responsavel       |"
   @ prow()+1,0      say "| Foi prestada gratuitamente assistencia ao trabalhador nos termos do|"+"                                |                                 |"
   @ prow()+1,0      say "| art 477    1o. da Consolidacao das Leis do Trabalho - CLT, sendo   |"+"                                |                                 |"
   @ prow()+1,0      say "| comprovado, neste ato, o efetivo pagamento das verbas rescisorias  |"+"                                |                                 |"
   @ prow()+1,0      say "| acima especificadas.                                               |"+"                                |                                 |"
   @ prow()+1,0      say "|                                                                    |"+"                                |                                 |"
   @ prow()+1,0      say "| ____________________________________________________               |"+"                                |                                 |"
   @ prow()+1,0      say "| Local e data                                                       |"+"                                |                                 |"
   @ prow()+1,0      say "|                                                                    |"+"                                |                                 |"
   @ prow()+1,0      say "| ____________________________________________________               |"+"                                |                                 |"
   @ prow()+1,0      say "| Carimbo e assinatura do assistente                                 |"+"------------------------------------------------------------------|"
   @ prow()+1,0      say "|--------------------------------------------------------------------|"+" 64 Recepcao pelo banco(data e carimbo)                           |"
   @ prow()+1,0      say "| 63 Identificacao do orgao homologador                              |"+"                                                                  |"
   @ prow()+1,0      say "|                                                                    |"+"                                                                  |"
   @ prow()+1,0      say "|                                                                    |"+"                                                                  |"
   @ prow()+1,0      say XCOND1 + cLINHA1


   __eject()

return

static function i_recibo7
   local nCONT, zTMP, lINIC := .T., cSTRING
   local nTOTPROV := nTOTDESC := 0
   local cLINHA1 := "*" + replicate("-",135) + "*"
   local cLINHA2 := "|" + space(135) + "|"
   local cLINHA3 := "|" + replicate("=",135) + "*"
   local nCAM_29 := nCAM_30 := nCAM_31 := nCAM_32 := nCAM_33 := nCAM_34 := nCAM_35 := nCAM_36 := nCAM_37 := nCAM_50 := 0
   local nCAM_38 := nCAM_39 := nCAM_40 := nCAM_41 := nCAM_46 := nCAM_47 := nCAM_48 := nCAM_49 := nCAM_54 := nCAM_55 := 0
   local nFRA31 := nFRA32 := nFRA34 := nFRA36 := nFRA40 := nZERO := nDED := nPROV := nLIQ := nCAM_51 := 0
   local cUPCP := space(2)
   cUPCP := space(2)

   qmensa("Emitindo recibo para: "+FUN->Matricula+"/"+left(FUN->Nome,40))
   setprc(0,0)
   cUPCP := space(2)
   @ prow()+1,0      say  XCOND1
   @ prow()+1,0      say  cLINHA1
   @ prow()+1,0      say "|"+  padc("TERMO DE RESCISAO DO CONTRATO DE TRABALHO",135) + "|"
   @ prow()+1,0      say  cLINHA1
   @ prow()+1,0      say "|"+  padc("Identificacao do Empregador",135) + "|"
   @ prow()+1,0      say  cLINHA1

   CGM->(dbseek(FILIAL->Cgm))


   @ prow()+1,0      say "| "  + "01 CNPJ/CEI.: "+transform(FILIAL->Cgccpf,"@R 99.999.999/9999-99") + " |       "+ "02 Razao Social/Nome: "+left(FILIAL->Razao,42)+ "                             |"
   @ prow()+1,0      say "| "  + "03 Endereco.: "+left(FILIAL->Endereco,46)+ " " + str(FILIAL->Numero,5) + left(FILIAL->Compl,15) + " | " + "04 Bairro.: " +FILIAL->Bairro + "                  |"
   @ prow()+1,0      say "| "  + "05 Municipio: "+ CGM->Municipio + " | " + "06 UF.: " + CGM->Estado + " | " + "07 CEP.: " + transform(FILIAL->Cep,"@R 99.999-999") + " | " + "08 CNAE.: " +CONFIG->Cnae + "|" + "09 CNPJ (Tomador obra):" + space(7)+ " |"
   @ prow()+1,0      say cLINHA1
   CGM->(dbseek(FUN->Resid_cgm))

   @ prow()+1,0      say "|"+  padc("Identificacao do Trabalhador",135) + "|"
   @ prow()+1,0      say cLINHA1



   @ prow()+1,0      say "| " +"10 PIS/PASEP.: " +FUN->Pis_num + "           | " + "11 Nome.: " + left(FUN->Nome,70) + "               |"
   @ prow()+1,0      say "| " + "12 Endereco.: " + FUN->Endereco + "          | " + "13 Bairro.: " + FUN->Bairro + "                              |"
   @ prow()+1,0      say "| " + "14 Municip.: " + left(CGM->Municipio,26) + " |" + "15 UF.: " + CGM->Estado + " | " + "16 CEP.: " +transform(FUN->Cep,"@R 99.999-999") + " |" + "17 Cart.Trab.: "+ FUN->Cp_num + " Serie: " + FUN->cp_serie + " UF: "
   CGM->(dbseek(FUN->Cp_cgm))
   @ prow(),pcol()   say CGM->Estado + " |"
   @ prow()+1,0      say "| " + "18 CPF.: " + FUN->Cpf_num + "      | " + "19 Nascimento: " + dtoc(FUN->Data_nasc) + "      | " + "20 Nome da Mae: " + FUN->Nome_mae + "     |"
   @ prow()+1,0      say cLINHA1
   @ prow()+1,0      say "|"+  padc("Dados do Contrato",135) + "|"
   @ prow()+1,0      say cLINHA1


   @ prow()+1,0      say "| " + "21 Tipo de Contrato.: " + space(35)+"|"+"22 Causa do Afastamento"+AFAST->Descricao+"|"
   @ prow()+1,0      say "| " + "23 Remuneracao.: " + transf(SITUA->Salario,"@E 999,999.99")+space(2)+"|"+"24 Data Admissao.: "+ dtoc(FUN->Data_adm)+ " |"+"25 Data do Aviso Previo.: "+dtoc(SITUA->Inicio_av)+"26 Data do Afastamento.: "+dtoc(SITUA->Af_ini)+"|"
   @ prow()+1,0      say "| " + "27 Cod. Afastamento.:" + SITUA->Codsaqfgts + " |" + "28 Pensao alimenticia (%) .: " + transf(nPERC,"@E 99.99") + " | " + "28 Categoria do Trabalhador.: " + "01"+space(48)+ " |"
   @ prow()+1,0      say cLINHA1
   @ prow()+1,0      say "|" + padc("DISCRIMINACAO DAS VERBAS RESCISORIAS",135) + "|"
   @ prow()+1,0      say cLINHA3

   for nCONT := 1 to 2
       zTMP := iif(nCONT==1,"P","D")

       @ prow()+1,0 say "| --- "+iif(zTMP=="P","PROVENTOS","DESCONTOS")+" ------------------------ REFERENCIA ------- VALOR      ------------------------------------- REFERENCIA ------- VALOR   |"

       lINIC := .T.
       LANC->(dbseek(XANOMES+FUN->Matricula+"MS"))
       do while LANC->Matricula == FUN->Matricula .and. LANC->Ambiente == "MS"
          if EVENT->Finalidade == zTMP .and. LANC->Valor <> 0
             cSTRING := LANC->Evento + "-" + left(EVENT->Descricao,37) + " "
             cSTRING += transform(LANC->Fracao,"@E 999.99") + " "
             cSTRING += transform(LANC->Valor,"@E 99,999,999.99")
             iif(zTMP=="P",nTOTPROV+=LANC->Valor,)
             iif(zTMP=="D",nTOTDESC+=LANC->Valor,)
             if lINIC
                lINIC := .F.
                @ prow()+1,0   say "|  " + cSTRING
                @ prow()  ,136 say "|"
             else
                lINIC := .T.
                @ prow(),68  say "|  " + cSTRING
                @ prow(),136 say "|"
             endif
          endif
          LANC->(dbskip())
       enddo
       @ prow()+1,0 say "|"
       @ prow()  ,97  say "Total de " + iif(zTMP=="P","Proventos... ","Descontos... ") + ;
                       transform(iif(zTMP=="P",nTOTPROV,nTOTDESC),"@E 999,999,999.99")
       @ prow()  ,136 say "|"
       @ prow()+1,0   say cLINHA2
   next
   @ prow()+1,0   say cLINHA2
   @ prow()+1,0   say "|"
   @ prow()  ,97  say "LIQUIDO A RECEBER:    " + transform(nTOTPROV-nTOTDESC,"@E 999,999,999.99")
   @ prow()  ,136 say "|"

   nBASEIS := BASE->B_inssms + BASE->B_inssdt
   nBASEIR := BASE->B_irrfms + BASE->B_irrfdt
   nBASEFG := BASE->B_fgtsms + BASE->B_fgtsdt
   CGM->(dbgotop())
   CGM->(dbseek(FILIAL->Cgm))


   nZERO := 0
   @ prow()+1,0      say XCOND1 + cLINHA1
   @ prow()+1,0      say "|" + XCOND0 + XAEXPAN + "      FORMALIZACAO DA RESCISAO   " + XDEXPAN + XCOND1 + "                      |"
   @ prow()+1,0      say XCOND1 + cLINHA1
   @ prow()+1,0      say "| 56 Local e data do recebimento                                     |"+"| 57 Carimbo de Assinatura do Empregador Preposto                 |"
   @ prow()+1,0      say "| "+CGM->Municipio +","+dtoc(dPGTO) + "                          |"+"| "+cPREP+space(23)+" |"
   @ prow()+1,0      say XCOND1 + cLINHA1
   @ prow()+1,0      say "| 58 Assinatura do trabalhador                                       |"+"| 59 Assinatura do responsavel legal do trabalhador               |"
   @ prow()+1,0      say "|                                                                    |"+"|                                                                 |"
   @ prow()+1,0      say XCOND1 + cLINHA1
   @ prow()+1,0      say "| 60 HOMOLOGACAO                                                     |"+" 61 Digital do trabalhador      | 62 Digital do responsavel       |"
   @ prow()+1,0      say "| Foi prestada gratuitamente assistencia ao trabalhador nos termos do|"+"                                |                                 |"
   @ prow()+1,0      say "| art 477    1o. da Consolidacao das Leis do Trabalho - CLT, sendo   |"+"                                |                                 |"
   @ prow()+1,0      say "| comprovado, neste ato, o efetivo pagamento das verbas rescisorias  |"+"                                |                                 |"
   @ prow()+1,0      say "| acima especificadas.                                               |"+"                                |                                 |"
   @ prow()+1,0      say "|                                                                    |"+"                                |                                 |"
   @ prow()+1,0      say "| ____________________________________________________               |"+"                                |                                 |"
   @ prow()+1,0      say "| Local e data                                                       |"+"                                |                                 |"
   @ prow()+1,0      say "|                                                                    |"+"                                |                                 |"
   @ prow()+1,0      say "| ____________________________________________________               |"+"                                |                                 |"
   @ prow()+1,0      say "| Carimbo e assinatura do assistente                                 |"+"------------------------------------------------------------------|"
   @ prow()+1,0      say "|--------------------------------------------------------------------|"+" 64 Recepcao pelo banco(data e carimbo)                           |"
   @ prow()+1,0      say "| 63 Identificacao do orgao homologador                              |"+"                                                                  |"
   @ prow()+1,0      say "|                                                                    |"+"                                                                  |"
   @ prow()+1,0      say "|                                                                    |"+"                                                                  |"
   @ prow()+1,0      say XCOND1 + cLINHA1


   __eject()

return


/////////////////////////////////////////////////////////////////////////////
// EMITE RECIBO EM FORMULARIO CONTINUO ______________________________________

static function i_rec6_hp
   local nCONT, zTMP, lINIC := .T., cSTRING
   local nTOTPROV := nTOTDESC := 0
   local cLINHA1 := "|" + replicate("-",135) + "|"
   local cLINHA2 := "|" + space(135) + "|"
   local cLINHA3 := "|" + replicate("=",135) + "|"
   local nCAM_29 := nCAM_30 := nCAM_31 := nCAM_32 := nCAM_33 := nCAM_34 := nCAM_35 := nCAM_36 := nCAM_37 := nCAM_50 := 0
   local nCAM_38 := nCAM_39 := nCAM_40 := nCAM_41 := nCAM_46 := nCAM_47 := nCAM_48 := nCAM_49 := nCAM_54 := nCAM_55 := 0
   local nFRA31 := nFRA32 := nFRA34 := nFRA36 := nFRA40 := nZERO := nDED := nPROV := nLIQ := nCAM_51 := 0
   local cUPCP := space(2)
   cUPCP := space(2)

   qmensa("Emitindo recibo para: "+FUN->Matricula+"/"+left(FUN->Nome,40))
   setprc(0,0)
   cUPCP := space(2)
   @ prow()+1,5      say XCOND1 + cLINHA1
   @ prow()+1,10      say "|" + XCOND0 +  "                   TERMO DE RESCISAO DO CONTRATO DE TRABALHO" + XCOND1+ "                                   |"
   @ prow()+1,10      say XCOND1 + cLINHA1
   CGM->(dbseek(FILIAL->Cgm))
   @ prow()+1,10      say "| " +"Identificacao"  + " | " + "01 CNPJ/CEI.: "+transform(FILIAL->Cgccpf,"@R 99.999.999/9999-99") + " | "+ "02 Razao Social/Nome: "+left(FILIAL->Razao,42)+ "                   |"
   @ prow()+1,10      say "| " +"     do      "  + " | " + "03 Endereco.: "+left(FILIAL->Endereco,36)+ " " + str(FILIAL->Numero,5) + left(FILIAL->Compl,15) + " | " + "04 Bairro.: " +FILIAL->Bairro + "            |"
   @ prow()+1,10      say "| " +" Empregador  "  + " | " + "05 Municipio: "+ CGM->Municipio + " | " + "06 UF.: " + CGM->Estado + " | " + "07 CEP.: " + transform(FILIAL->Cep,"@R 99.999-999") + " | " + "08 CNAE.: " +CONFIG->Cnae  + "                 |"
   @ prow()+1,10      say "| " +"             "  + " | " + "09 CNPJ (Tomador obra):" + space(94)+ " |"
   @ prow()+1,10      say XCOND1 + cLINHA1
   CGM->(dbseek(FUN->Resid_cgm))

   @ prow()+1,10      say "| " +"Identificacao"  + " | " + "10 PIS/PASEP.: " +FUN->Pis_num + " | " + "11 Nome.: " + left(FUN->Nome,70) + "         |"
   @ prow()+1,10      say "| " +"     do      "  + " | " + "12 Endereco.: " + FUN->Endereco + " | " + "13 Bairro.: " + FUN->Bairro + "                        |"
   @ prow()+1,10      say "| " +" Trabalhador "  + " | " + "14 Municip.: " + left(CGM->Municipio,26) + " |" + "15 UF.: " + CGM->Estado + " | " + "16 CEP.: " +transform(FUN->Cep,"@R 99.999-999") + " |" + "17 Cart.Trab.: "+ FUN->Cp_num + " Serie: " + FUN->cp_serie + " UF: "
   CGM->(dbseek(FUN->Cp_cgm))
   @ prow(),pcol()   say CGM->Estado + " |"
   @ prow()+1,10      say "| " +"             "  + " | " + "18 CPF.: " + FUN->Cpf_num + " | " + "19 Nascimento: " + dtoc(FUN->Data_nasc) + " | " + "20 Nome da Mae: " + FUN->Nome_mae + " |"
   @ prow()+1,10      say XCOND1 + cLINHA1

   @ prow()+1,10      say "| " +"   Dados     "  + " | " + "21 Remuneracao p/ fins rescisorios.: " + transf(SITUA->Salario,"@E 99,999.99") + " | " + "22 Data Admissao.: "+ dtoc(FUN->Data_adm)+ " |" + "23 Data do Aviso Previo.: "+ dtoc(SITUA->Inicio_av)+ "  |"
   @ prow()+1,10      say "| " +"     do      "  + " | " + "24 Data do afastamento.:" + dtoc(SITUA->Af_ini)+ " |" + "25 Causa do Afastamento.: " + AFAST->Descricao + " |" +  "26 Cod. Afastamento: " + SITUA->Codsaqfgts + " |"
   @ prow()+1,10      say "| " +"  Contrato   "  + " | " + "27 Pensao alimenticia (%) .: " + transf(nPERC,"@E 99.99") + " | " + "28 Categoria do Trabalhador.: " + "01"+space(48)+ " |"
   @ prow()+1,10      say XCOND1 + cLINHA1
   @ prow()+1,10      say "|" + XCOND0 + XAEXPAN + "DISCRIMINACAO DAS VERBAS RESCISORIAS   " + XDEXPAN + XCOND1 + "     |"
   @ prow()+1,10      say cLINHA3

   for nCONT := 1 to 2
       zTMP := iif(nCONT==1,"P","D")

       @ prow()+1,10 say "| --- "+iif(zTMP=="P","PROVENTOS","DESCONTOS")+" ------------------------ REFERENCIA ------- VALOR      ------------------------------------- REFERENCIA ------- VALOR   |"

       lINIC := .T.
       LANC->(dbseek(XANOMES+FUN->Matricula+"MS"))
       do while LANC->Matricula == FUN->Matricula .and. LANC->Ambiente == "MS"
          if EVENT->Finalidade == zTMP .and. LANC->Valor <> 0
             cSTRING := LANC->Evento + "-" + left(EVENT->Descricao,37) + " "
             cSTRING += transform(LANC->Fracao,"@E 999.99") + " "
             cSTRING += transform(LANC->Valor,"@E 99,999,999.99")
             iif(zTMP=="P",nTOTPROV+=LANC->Valor,)
             iif(zTMP=="D",nTOTDESC+=LANC->Valor,)
             if lINIC
                lINIC := .F.
                @ prow()+1,10   say "|  " + cSTRING
                @ prow()  ,146 say "|"
             else
                lINIC := .T.
                @ prow(),78  say "|  " + cSTRING
                @ prow(),146 say "|"
             endif
          endif
          LANC->(dbskip())
       enddo
       @ prow()+1,10 say "|"
       @ prow()  ,107  say "Total de " + iif(zTMP=="P","Proventos... ","Descontos... ") + ;
                       transform(iif(zTMP=="P",nTOTPROV,nTOTDESC),"@E 999,999,999.99")
       @ prow()  ,146 say "|"
       @ prow()+1,10   say cLINHA2
   next
   @ prow()+1,10   say cLINHA2
   @ prow()+1,10   say "|"
   @ prow()  ,107  say "LIQUIDO A RECEBER:    " + transform(nTOTPROV-nTOTDESC,"@E 999,999,999.99")
   @ prow()  ,146 say "|"

   nBASEIS := BASE->B_inssms + BASE->B_inssdt
   nBASEIR := BASE->B_irrfms + BASE->B_irrfdt
   nBASEFG := BASE->B_fgtsms + BASE->B_fgtsdt
   CGM->(dbgotop())
   CGM->(dbseek(FILIAL->Cgm))


   nZERO := 0
   @ prow()+1,10      say XCOND1 + cLINHA1
   @ prow()+1,10      say "|" + XCOND0 + XAEXPAN + "      FORMALIZACAO DA RESCISAO   " + XDEXPAN + XCOND1 + "                         |"
   @ prow()+1,10      say XCOND1 + cLINHA1
   @ prow()+1,10      say "| 56 Local e data do recebimento                                     |"+"| 57 Carimbo de Assinatura do Empregador Preposto                 |"
   @ prow()+1,10      say "| "+CGM->Municipio +","+dtoc(dPGTO) + "                          |"+"| "+cPREP+space(23)+" |"
   @ prow()+1,10      say XCOND1 + cLINHA1
   @ prow()+1,10      say "| 58 Assinatura do trabalhador                                       |"+"| 59 Assinatura do responsavel legal do trabalhador               |"
   @ prow()+1,10      say "|                                                                    |"+"|                                                                 |"
   @ prow()+1,10      say XCOND1 + cLINHA1
   @ prow()+1,10      say "| 60 HOMOLOGACAO                                                     |"+" 61 Digital do trabalhador      | 62 Digital do responsavel       |"
   @ prow()+1,10      say "| Foi prestada gratuitamente assistencia ao trabalhador nos termos do|"+"                                |                                 |"
   @ prow()+1,10      say "| art 477    1o. da Consolidacao das Leis do Trabalho - CLT, sendo   |"+"                                |                                 |"
   @ prow()+1,10      say "| comprovado, neste ato, o efetivo pagamento das verbas rescisorias  |"+"                                |                                 |"
   @ prow()+1,10      say "| acima especificadas.                                               |"+"                                |                                 |"
   @ prow()+1,10      say "|                                                                    |"+"                                |                                 |"
   @ prow()+1,10      say "| ____________________________________________________               |"+"                                |                                 |"
   @ prow()+1,10      say "| Local e data                                                       |"+"                                |                                 |"
   @ prow()+1,10      say "|                                                                    |"+"                                |                                 |"
   @ prow()+1,10      say "| ____________________________________________________               |"+"                                |                                 |"
   @ prow()+1,10      say "| Carimbo e assinatura do assistente                                 |"+"------------------------------------------------------------------|"
   @ prow()+1,10      say "|--------------------------------------------------------------------|"+" 64 Recepcao pelo banco(data e carimbo)                           |"
   @ prow()+1,10      say "| 63 Identificacao do orgao homologador                              |"+"                                                                  |"
   @ prow()+1,10      say "|                                                                    |"+"                                                                  |"
   @ prow()+1,10      say "|                                                                    |"+"                                                                  |"
   @ prow()+1,10      say XCOND1 + cLINHA1



return

static function i_spool
   local nCONT, zTMP, lINIC := .T., cSTRING
   local nTOTPROV := nTOTDESC := 0
   local cLINHA1 := "|" + replicate("-",135) + "|"
   local cLINHA2 := "|" + space(135) + "|"
   local cLINHA3 := "|" + replicate("=",135) + "|"
   local nCAM_29 := nCAM_30 := nCAM_31 := nCAM_32 := nCAM_33 := nCAM_34 := nCAM_35 := nCAM_36 := nCAM_37 := nCAM_50 := 0
   local nCAM_38 := nCAM_39 := nCAM_40 := nCAM_41 := nCAM_46 := nCAM_47 := nCAM_48 := nCAM_49 := nCAM_54 := nCAM_55 := 0
   local nFRA31 := nFRA32 := nFRA34 := nFRA36 := nFRA40 := nZERO := nDED := nPROV := nLIQ := nCAM_51 := 0
   local cUPCP := space(2)
   cUPCP := space(2)

   qmensa("Emitindo recibo para: "+FUN->Matricula+"/"+left(FUN->Nome,40))
   setprc(0,0)
   cUPCP := space(2)
   @ prow()+1,10      say  cLINHA1
   @ prow()+1,10      say "|" + padc("TERMO DE RESCISAO DO CONTRATO DE TRABALHO",135) +  "|"
   @ prow()+1,10      say  cLINHA1
   CGM->(dbseek(FILIAL->Cgm))
   @ prow()+1,10      say "| " +"Identificacao"  + " | " + "01 CNPJ/CEI.: "+transform(FILIAL->Cgccpf,"@R 99.999.999/9999-99") + " | "+ "02 Razao Social/Nome: "+left(FILIAL->Razao,42)+ "                   |"
   @ prow()+1,10      say "| " +"     do      "  + " | " + "03 Endereco.: "+left(FILIAL->Endereco,36)+ " " + str(FILIAL->Numero,5) + left(FILIAL->Compl,15) + " | " + "04 Bairro.: " +FILIAL->Bairro + "            |"
   @ prow()+1,10      say "| " +" Empregador  "  + " | " + "05 Municipio: "+ CGM->Municipio + " | " + "06 UF.: " + CGM->Estado + " | " + "07 CEP.: " + transform(FILIAL->Cep,"@R 99.999-999") + " | " + "08 CNAE.: " +CONFIG->Cnae  + "                 |"
   @ prow()+1,10      say "| " +"             "  + " | " + "09 CNPJ (Tomador obra):" + space(94)+ " |"
   @ prow()+1,10      say  cLINHA1
   CGM->(dbseek(FUN->Resid_cgm))

   @ prow()+1,10      say "| " +"Identificacao"  + " | " + "10 PIS/PASEP.: " +FUN->Pis_num + " | " + "11 Nome.: " + left(FUN->Nome,70) + "         |"
   @ prow()+1,10      say "| " +"     do      "  + " | " + "12 Endereco.: " + FUN->Endereco + " | " + "13 Bairro.: " + FUN->Bairro + "                        |"
   @ prow()+1,10      say "| " +" Trabalhador "  + " | " + "14 Municip.: " + left(CGM->Municipio,26) + " |" + "15 UF.: " + CGM->Estado + " | " + "16 CEP.: " +transform(FUN->Cep,"@R 99.999-999") + " |" + "17 Cart.Trab.: "+ FUN->Cp_num + " Serie: " + FUN->cp_serie + " UF: "
   CGM->(dbseek(FUN->Cp_cgm))
   @ prow(),pcol()   say CGM->Estado + " |"
   @ prow()+1,10      say "| " +"             "  + " | " + "18 CPF.: " + FUN->Cpf_num + " | " + "19 Nascimento: " + dtoc(FUN->Data_nasc) + " | " + "20 Nome da Mae: " + FUN->Nome_mae + " |"
   @ prow()+1,10      say  cLINHA1

   @ prow()+1,10      say "| " +"   Dados     "  + " | " + "21 Remuneracao p/ fins rescisorios.: " + transf(SITUA->Salario,"@E 99,999.99") + " | " + "22 Data Admissao.: "+ dtoc(FUN->Data_adm)+ " |" + "23 Data do Aviso Previo.: "+ dtoc(SITUA->Inicio_av)+ "  |"
   @ prow()+1,10      say "| " +"     do      "  + " | " + "24 Data do afastamento.:" + dtoc(SITUA->Af_ini)+ " |" + "25 Causa do Afastamento.: " + AFAST->Descricao + " |" +  "26 Cod. Afastamento: " + SITUA->Codsaqfgts + " |"
   @ prow()+1,10      say "| " +"  Contrato   "  + " | " + "27 Pensao alimenticia (%) .: " + transf(nPERC,"@E 99.99") + " | " + "28 Categoria do Trabalhador.: " + "01"+space(48)+ " |"
   @ prow()+1,10      say  cLINHA1
   @ prow()+1,10      say "|" + padc( "DISCRIMINACAO DAS VERBAS RESCISORIAS",135) +  "|"
   @ prow()+1,10      say cLINHA3

   for nCONT := 1 to 2
       zTMP := iif(nCONT==1,"P","D")

       @ prow()+1,10 say "| --- "+iif(zTMP=="P","PROVENTOS","DESCONTOS")+" ------------------------ REFERENCIA ------- VALOR      ------------------------------------- REFERENCIA ------- VALOR   |"

       lINIC := .T.
       LANC->(dbseek(XANOMES+FUN->Matricula+"MS"))
       do while LANC->Matricula == FUN->Matricula .and. LANC->Ambiente == "MS"
          if EVENT->Finalidade == zTMP .and. LANC->Valor <> 0
             cSTRING := LANC->Evento + "-" + left(EVENT->Descricao,37) + " "
             cSTRING += transform(LANC->Fracao,"@E 999.99") + " "
             cSTRING += transform(LANC->Valor,"@E 99,999,999.99")
             iif(zTMP=="P",nTOTPROV+=LANC->Valor,)
             iif(zTMP=="D",nTOTDESC+=LANC->Valor,)
             if lINIC
                lINIC := .F.
                @ prow()+1,10   say "|  " + cSTRING
                //@ prow()  ,146 say "|"
             else
                lINIC := .T.
                @ prow(),78  say "|  " + cSTRING
                @ prow(),146 say "|"
             endif
          endif
          LANC->(dbskip())
       enddo
       @ prow()+1,10 say "|"
       @ prow()  ,107  say "Total de " + iif(zTMP=="P","Proventos... ","Descontos... ") + ;
                       transform(iif(zTMP=="P",nTOTPROV,nTOTDESC),"@E 999,999,999.99")
       @ prow()  ,146 say "|"
       @ prow()+1,10   say cLINHA2
   next
   @ prow()+1,10   say cLINHA2
   @ prow()+1,10   say "|"
   @ prow()  ,107  say "LIQUIDO A RECEBER:    " + transform(nTOTPROV-nTOTDESC,"@E 999,999,999.99")
   @ prow()  ,146 say "|"

   nBASEIS := BASE->B_inssms + BASE->B_inssdt
   nBASEIR := BASE->B_irrfms + BASE->B_irrfdt
   nBASEFG := BASE->B_fgtsms + BASE->B_fgtsdt
   CGM->(dbgotop())
   CGM->(dbseek(FILIAL->Cgm))


   nZERO := 0
   @ prow()+1,10      say  cLINHA1
   @ prow()+1,10      say "|" +padc("FORMALIZACAO DA RESCISAO",135) +  "|"
   @ prow()+1,10      say  cLINHA1
   @ prow()+1,10      say "| 56 Local e data do recebimento                                     |"+"| 57 Carimbo de Assinatura do Empregador Preposto                 |"
   @ prow()+1,10      say "| "+CGM->Municipio +","+dtoc(dPGTO) + "                          |"+"| "+cPREP+space(23)+" |"
   @ prow()+1,10      say  cLINHA1
   @ prow()+1,10      say "| 58 Assinatura do trabalhador                                       |"+"| 59 Assinatura do responsavel legal do trabalhador               |"
   @ prow()+1,10      say "|                                                                    |"+"|                                                                 |"
   @ prow()+1,10      say  cLINHA1
   @ prow()+1,10      say "| 60 HOMOLOGACAO                                                     |"+" 61 Digital do trabalhador      | 62 Digital do responsavel       |"
   @ prow()+1,10      say "| Foi prestada gratuitamente assistencia ao trabalhador nos termos do|"+"                                |                                 |"
   @ prow()+1,10      say "| art 477    1o. da Consolidacao das Leis do Trabalho - CLT, sendo   |"+"                                |                                 |"
   @ prow()+1,10      say "| comprovado, neste ato, o efetivo pagamento das verbas rescisorias  |"+"                                |                                 |"
   @ prow()+1,10      say "| acima especificadas.                                               |"+"                                |                                 |"
   @ prow()+1,10      say "|                                                                    |"+"                                |                                 |"
   @ prow()+1,10      say "| ____________________________________________________               |"+"                                |                                 |"
   @ prow()+1,10      say "| Local e data                                                       |"+"                                |                                 |"
   @ prow()+1,10      say "|                                                                    |"+"                                |                                 |"
   @ prow()+1,10      say "| ____________________________________________________               |"+"                                |                                 |"
   @ prow()+1,10      say "| Carimbo e assinatura do assistente                                 |"+"------------------------------------------------------------------|"
   @ prow()+1,10      say "|--------------------------------------------------------------------|"+" 64 Recepcao pelo banco(data e carimbo)                           |"
   @ prow()+1,10      say "| 63 Identificacao do orgao homologador                              |"+"                                                                  |"
   @ prow()+1,10      say "|                                                                    |"+"                                                                  |"
   @ prow()+1,10      say "|                                                                    |"+"                                                                  |"
   @ prow()+1,10      say  cLINHA1



return

function i_reciboXml
local nFile := fcreate("c:\Qsystxt\Resc"+XEMPRESA+".xml",0)
local nSALANT := SITUA->Salario
local nDias := 0
local nSaldo    := 0
local nComiss   := 0
local nGratif   := 0
local nInsal    := 0
local nPeric    := 0
local nAdNotVal := 0
local nAdNotFra := 0
local nAdNotPerc := 0
local nDsr      := 0
local nReflexo  := 0
local nMulta477 := 0
local nMulta479 := 0
local nSalFam   := 0
local nFilhos   := 0
local nDTVal    := 0
local nDTAvos   := 0
local nHE50Val  := 0
local nHE50Fra  := 0
local nGorjetas := 0
local nValeAlim := 0
local nFrPropFra := 0
local nFrPropVal := 0
local nFrVencFra := 0
local nFrVencVal := 0
local nFrTerco   := 0
local nAviso       := 0
local nDtAviso     := 0
local nFrAviso     := 0
local nPensao := 0
local nAdiant := 0
local nAdDT   := 0
local nDescAviso   := 0
local nMulta480    := 0
local nEmpConsig   := 0
local nINSSMS := 0
local nINSSDT := 0
local nIRRFMS := 0
local nIRRFDT := 0
local nDescontos := 0
local nProventos := 0
local nLiquido   := 0


local dAq_ini := ctod("")
local dAq_fim := ctod("")


    LANC->(dbseek(XANOMES+FUN->Matricula+"MS"))
    do while LANC->Matricula == FUN->Matricula .and. LANC->Ambiente == "MS"
       if EVENT->Finalidade == "P".and. LANC->Valor <> 0
          if LANC->Evento == "102"
             nSaldo     := LANC->valor
             nProventos += LANC->valor

             nDias  := LANC->Fracao
          endif

          if LANC->Evento == "108"
             nComiss := LANC->valor
             nProventos += LANC->valor

          endif

          if LANC->Evento == "112"
             nGratif := LANC->valor
             nProventos += LANC->valor

          endif

          if LANC->Evento == "420"
             nInsal := LANC->valor
             nProventos += LANC->valor

          endif

          if LANC->Evento == "410"
             nPeric := LANC->valor
             nProventos += LANC->valor

          endif

          if LANC->Evento == "412"
             nAdNotVal  := LANC->valor
             nProventos += LANC->valor

             nAdNotFra := LANC->Fracao
             EVCFG->(dbseek("412"))
             do case
                case EVCFG->Tipo == "A"
                     nAdNotPerc := 20

                case EVCFG->Tipo == "B"
                     nAdNotPerc := 25

                case EVCFG->Tipo == "C"
                     nAdNotPerc := 30

             endcase


          endif

          if LANC->Evento == "171"
             nDsr := LANC->valor
             nProventos += LANC->valor

          endif

          if LANC->Evento $ "149-170-176-246-371-172-177-239-251-302-203-598-173-278"
             nDsr += LANC->valor
             nProventos += LANC->valor

          endif

          if LANC->Evento == "182"
             nFrPropVal := LANC->Valor
             nFrPropFra := LANC->Fracao
             nProventos += LANC->valor
          endif


          if LANC->Evento == "183"
             nFrTerco   += LANC->Valor
             nProventos += LANC->valor

          endif

          if LANC->Evento == "184"
             nFrVencVal := LANC->Valor
             nFrVencFra := LANC->Fracao
             nProventos += LANC->valor
          endif

          if LANC->Evento == "185"
             nFrTerco   += LANC->Valor
             nProventos += LANC->valor
          endif

          if LANC->Evento == "814"
             nDtVal   := LANC->Valor
             nDtAvos  := LANC->Fracao
             nProventos += LANC->valor
          endif

          if LANC->Evento == "813"
             nAviso     := LANC->Valor
             nProventos += LANC->valor
          endif

       endif
       LANC->(dbskip())
    enddo


    LANC->(dbseek(XANOMES+FUN->Matricula+"MS"))
    do while LANC->Matricula == FUN->Matricula .and. LANC->Ambiente == "MS"
       if EVENT->Finalidade == "D".and. LANC->Valor <> 0

          if LANC->Evento == "201"
             nADiant    := LANC->Valor
             nDescontos += LANC->valor
          endif

          if LANC->Evento == "819"
             nAdDt      := LANC->Valor
             nDescontos += LANC->valor
          endif

          if LANC->Evento == "151"
             nDescAviso   := LANC->Valor
             nDescontos += LANC->valor
          endif

          if LANC->Evento == "910"
             nINSSMS    := LANC->Valor
             nDescontos += LANC->valor
          endif

          if LANC->Evento == "914"
             nINSSDT    := LANC->Valor
             nDescontos += LANC->valor
          endif

          if LANC->Evento == "920"
             nIRRFMS    := LANC->Valor
             nDescontos += LANC->valor
          endif

          if LANC->Evento == "924"
             nIRRFDT    := LANC->Valor
             nDescontos += LANC->valor
          endif

       endif
       LANC->(dbskip())
    enddo


    nLiquido := nProventos - nDescontos




     xmlAbre(nFile)
       xmlNomeStyle(nFile)
       xmlConteudoStyle(nFile)
       xmlS21Style(nFile)
       xmlSubTituloStyle(nFile)
       xmlTituloStyle(nFile)
       xmlOutroStyle(nFile)
     xmlFechaStyles(nFile)
     xmlabrePasta(nFile,left(FILIAL->Razao,30))

        xmlabreLinha(nFile,"0","30")
           xmlCell(nFile,"String","TERMO DE RESCISAO DO CONTRATO DE TRABALHO","Titulo","8")
        xmlfechaLinha(nfile)

        xmlabreLinha(nFile,"0","15")
           xmlCell(nFile,"String","IDENTIFICACAO DO EMPREGADOR","SubTitulo","8")
        xmlfechaLinha(nfile)

        xmlabreLinha(nFile,"0","12")
           xmlCell(nFile,"String","01 CNPJ/CEI","Nome","1")
           xmlCell(nFile,"String","02 Razao social/Nome","Nome","6")
        xmlFechaLinha(nFile)

        xmlabreLinha(nFile,"0","15")
           xmlCell(nFile,"String",transf(FILIAL->cgccpf,"@R 99.999.999/9999-99"),"Conteudo","1")
           xmlCell(nFile,"String",rtrim(FILIAL->Razao),"Conteudo","6")
        xmlFechaLinha(nFile)

        xmlabreLinha(nFile,"0","12")
           xmlCell(nFile,"String","03 Endereco (Logradouro, No, Andar, Apartamento)","Nome","5")
           xmlCell(nFile,"String","04 Bairro","Nome","2")
        xmlFechaLinha(nFile)

        xmlabreLinha(nFile,"0","15")
           xmlCell(nFile,"String",rtrim(FILIAL->Endereco)+", "+alltrim(str(FILIAL->Numero))+rtrim(FILIAL->compl),"Conteudo","5")
           xmlCell(nFile,"String",rtrim(FILIAL->Bairro),"Conteudo","2")
        xmlFechaLinha(nFile)

        xmlabreLinha(nFile,"0","12")
           xmlCell(nFile,"String","05 Municipio","Nome","1")
           xmlCell(nFile,"String","06 UF","Nome")
           xmlCell(nFile,"String","07 Cep","Nome","1")
           xmlCell(nFile,"String","08 CNAE","Nome")
           xmlCell(nFile,"String","09 CNPJ/CEI Tomador/Obra","Nome","2")
        xmlFechaLinha(nFile)

        CGM->(dbseek(FILIAL->Cgm))

        xmlabreLinha(nFile,"0","15")
           xmlCell(nFile,"String",rtrim(CGM->Municipio),"Conteudo","1")
           xmlCell(nFile,"String",CGM->Estado,"Conteudo")
           xmlCell(nFile,"String",transf(FILIAL->Cep,"@R 99.999-999"),"Conteudo","1")
           xmlCell(nFile,"String",CONFIG->Cnae,"Conteudo")
           xmlCell(nFile,"String","-","Conteudo","2")
        xmlFechaLinha(nFile)

        xmlabreLinha(nFile,"0","15")
           xmlCell(nFile,"String","IDENTIFICACAO DO TRABALHADOR","SubTitulo","8")
        xmlfechaLinha(nfile)

        xmlabreLinha(nFile,"0","12")
           xmlCell(nFile,"String","10 PIS","Nome","1")
           xmlCell(nFile,"String","11 Nome","Nome","6")
        xmlFechaLinha(nFile)

        xmlabreLinha(nFile,"0","15")
           xmlCell(nFile,"String",transf(FUN->Pis_num,"@R 999.99999.99-9"),"Conteudo","1")
           xmlCell(nFile,"String",rtrim(FUN->Nome),"Conteudo","6")
        xmlFechaLinha(nFile)

        xmlabreLinha(nFile,"0","12")
           xmlCell(nFile,"String","12 Endereco (Logradouro, No, Andar, Apartamento)","Nome","5")
           xmlCell(nFile,"String","13 Bairro","Nome","2")
        xmlFechaLinha(nFile)

        xmlabreLinha(nFile,"0","15")
           xmlCell(nFile,"String",rtrim(FUN->Endereco)+", "+alltrim(str(FILIAL->Numero))+rtrim(FILIAL->compl),"Conteudo","5")
           xmlCell(nFile,"String",rtrim(FUN->Bairro),"Conteudo","2")
        xmlFechaLinha(nFile)

        xmlabreLinha(nFile,"0","12")
           xmlCell(nFile,"String","14 Municipio","Nome","1")
           xmlCell(nFile,"String","15 UF","Nome")
           xmlCell(nFile,"String","16 Cep","Nome","1")
           xmlCell(nFile,"String","17 Carteira de Trabalho (No, Serie e UF)","Nome","3")
        xmlFechaLinha(nFile)

        CGM->(dbseek(FUN->Resid_Cgm))

        xmlabreLinha(nFile,"0","15")
           xmlCell(nFile,"String",rtrim(CGM->Municipio),"Conteudo","1")
           xmlCell(nFile,"String",CGM->Estado,"Conteudo")
           xmlCell(nFile,"String",transf(FUN->Cep,"@R 99.999-999"),"Conteudo","1")

           CGM->(dbseek(FUN->Cp_Cgm))
           xmlCell(nFile,"String",FUN->cp_Num+" / "+FUN->Cp_serie+" - "+CGM->Estado,"Conteudo","3")
        xmlFechaLinha(nFile)

        xmlabreLinha(nFile,"0","12")
           xmlCell(nFile,"String","18 CPF","Nome","1")
           xmlCell(nFile,"String","19 Data de Nascimento","Nome","1")
           xmlCell(nFile,"String","20 Nome da Mae","Nome","4")
        xmlFechaLinha(nFile)

        xmlabreLinha(nFile,"0","15")
           xmlCell(nFile,"String",transf(FUN->Cpf_num,"@R 999.999.999-99"),"Conteudo","1")
           xmlCell(nFile,"String",dtoc(FUN->Data_nasc),"Conteudo","1")
           xmlCell(nFile,"String",rtrim(FUN->Nome_mae),"Conteudo","4")
        xmlFechaLinha(nFile)

        xmlabreLinha(nFile,"0","15")
           xmlCell(nFile,"String","DADOS DO CONTRATO","SubTitulo","8")
        xmlfechaLinha(nfile)

        xmlabreLinha(nFile,"0","12")
           xmlCell(nFile,"String","21 Tipo do Contrato","Nome","4")
           xmlCell(nFile,"String","22 Causa do Afastamento","Nome","3")
        xmlFechaLinha(nFile)

        xmlabreLinha(nFile,"0","15")
           xmlCell(nFile,"String","Contrato de trabalho por prazo indeterminado.","Conteudo","4")
           xmlCell(nFile,"String",AFAST->Descricao,"Conteudo","3")
        xmlFechaLinha(nFile)

        xmlabreLinha(nFile,"0","12")
           xmlCell(nFile,"String","23 Remuneracao mes anterior a rescisao","Nome","1")
           xmlCell(nFile,"String","24 Data de Admissao","Nome","2")
           xmlCell(nFile,"String","25 Data do Aviso Previo","Nome","1")
           xmlCell(nFile,"String","26 Data de afastamento","Nome","1")
        xmlFechaLinha(nFile)


        xmlabreLinha(nFile,"0","15")
           xmlCell(nFile,"String",Transf(nSalAnt,"@E 999,999.99"),"Conteudo","1")
           xmlCell(nFile,"String",dtoc(FUN->Data_adm),"Conteudo","2")
           xmlCell(nFile,"String",dtoc(SITUA->Inicio_av),"Conteudo","1")
           xmlCell(nFile,"String",dtoc(SITUA->Af_ini),"Conteudo","1")
        xmlFechaLinha(nFile)

        xmlabreLinha(nFile,"0","12")
           xmlCell(nFile,"String","27 Cod. afastamento","Nome","1")
           xmlCell(nFile,"String","28 Pensao Alimenticia(%) TRCT","Nome","2")
           xmlCell(nFile,"String","29 Pensao alim.(%)(Saque FGTS)","Nome","1")
           xmlCell(nFile,"String","30 Categoria do Trabalhador","Nome","1")
        xmlFechaLinha(nFile)

        xmlabreLinha(nFile,"0","15")
           xmlCell(nFile,"String",SITUA->CodSaqFgts,"Conteudo","1")
           xmlCell(nFile,"String"," ","Conteudo","2")
           xmlCell(nFile,"String"," ","Conteudo","1")
           xmlCell(nFile,"String","01","Conteudo","1")
        xmlFechaLinha(nFile)

        xmlabreLinha(nFile,"0","12")
           xmlCell(nFile,"String","31 Codigo Sindical","Nome","2")
           xmlCell(nFile,"String","32 CNPJ e Nome da entidade sindical laboral:","Nome","2")
           xmlCell(nFile,"String",SIND->Cnpj,"Conteudo2","2")
        xmlFechaLinha(nFile)

        xmlabreLinha(nFile,"0","15")
           xmlCell(nFile,"String",SIND->Cod_entid,"Conteudo","2")
           xmlCell(nFile,"String",SIND->Descricao,"Conteudo","5")
        xmlFechaLinha(nFile)

        xmlabreLinha(nFile,"0","15")
           xmlCell(nFile,"String","DISCRIMINACAO DAS VERBAS RESCISORIAS","SubTitulo","8")
        xmlfechaLinha(nfile)

        xmlabreLinha(nFile,"0","15")
           xmlCell(nFile,"String","VERBAS RESCISORIAS","Verbas","8")
        xmlfechaLinha(nfile)

        xmlabreLinha(nFile,"0","15")
           xmlCell(nFile,"String","Rubrica","Rubrica","1")
           xmlCell(nFile,"String","Valor","Rubrica")
           xmlCell(nFile,"String","Rubrica","Rubrica","1")
           xmlCell(nFile,"String","Valor","Rubrica")
           xmlCell(nFile,"String","Rubrica","Rubrica","1")
           xmlCell(nFile,"String","Valor","Rubrica")
        xmlfechaLinha(nfile)

        xmlabreLinha(nFile,"0","30")
           xmlCell(nFile,"String","50 Saldo de "+alltrim(str(nDias,2))+" dias de salario","Nome","1")
           xmlCell(nFile,"String",alltrim(transf(nSaldo,"@E 999,999.99")),"Valor")
           xmlCell(nFile,"String","51 Comissoes","Nome","1")
           xmlCell(nFile,"String",iif(nComiss>0,alltrim(transf(nComiss,"@E 999,999.99")),"   ") ,"Valor")
           xmlCell(nFile,"String","52 Gratificacoes","Nome","1")
           xmlCell(nFile,"String",iif(nGratif>0,alltrim(transf(nGratif,"@E 999,999.99")),"   "),"Valor")
        xmlfechaLinha(nfile)

        xmlabreLinha(nFile,"0","30")
           xmlCell(nFile,"String","53 Adicional de Insalubridade","Nome","1")
           xmlCell(nFile,"String",iif(nInsal>0,alltrim(transf(nInsal,"@E 999,999.99")),"   "),"Valor")
           xmlCell(nFile,"String","54 Adicional de Periculosidade","Nome","1")
           xmlCell(nFile,"String",iif(nPeric>0,alltrim(transf(nPeric,"@E 999,999.99")),"   "),"Valor")
           xmlCell(nFile,"String","55 Adicional Noturno "+iif(nAdNotFra>0,alltrim(str(nAdNotFra,3)),"--")+" Horas "+iif(nAdNotPerc>0,strzero(nAdNotPerc,2),"--")+"%","Nome","1")
           xmlCell(nFile,"String",iif(nAdNotVal>0,alltrim(transf(nADNotVal,"@E 999,999.99")),"   "),"Valor")
        xmlfechaLinha(nfile)

        xmlabreLinha(nFile,"0","30")
           xmlCell(nFile,"String","56 Horas Extras","Nome","1")
           xmlCell(nFile,"String",iif(nHE50Val>0,alltrim(transf(nHE50Val,"@E 999,999.99")),"   "),"Valor")
           xmlCell(nFile,"String","   ","Nome","1")
           xmlCell(nFile,"String","   ","Valor")
           xmlCell(nFile,"String","    ","Nome","1")
           xmlCell(nFile,"String","    ","Valor")
        xmlfechaLinha(nfile)

        xmlabreLinha(nFile,"0","30")
           xmlCell(nFile,"String","57 Gorjetas","Nome","1")
           xmlCell(nFile,"String",iif(nGorjetas>0,alltrim(transf(nGorjetas,"@E 999,999.99")),"   "),"Valor")
           xmlCell(nFile,"String","58 Descanso semanal remunerado(DSR)","Nome","1")
           xmlCell(nFile,"String",iif(nDSR>0,alltrim(transf(nDsr,"@E 999,999.99")),"  "),"Valor")
           xmlCell(nFile,"String","59 Reflexo do DSR sobre salario variavel","Nome","1")
           xmlCell(nFile,"String",iif(nReflexo>0,alltrim(transf(nReflexo,"@E 999,999.99")),"  "),"Valor")
        xmlfechaLinha(nfile)

        xmlabreLinha(nFile,"0","30")
           xmlCell(nFile,"String","60 Multa Art. 477","Nome","1")
           xmlCell(nFile,"String",iif(nMulta477>0,alltrim(transf(nMulta477,"@E 999,999.99")),"  "),"Valor")
           xmlCell(nFile,"String","61 Multa Art. 479/CLT","Nome","1")
           xmlCell(nFile,"String",iif(nMulta479>0,alltrim(transf(nMulta479,"@E 999,999.99")),"  "),"Valor")
           xmlCell(nFile,"String","62 Salario Familia ("+iif(nFilhos>0,strzero(nFilhos,2),"--")+")","Nome","1")
           xmlCell(nFile,"String",iif(nSalFam>0,alltrim(transf(nSalFam,"@E 999,999.99")),"  "),"Valor")
        xmlfechaLinha(nfile)

        xmlabreLinha(nFile,"0","30")
           xmlCell(nFile,"String","63 13o Salario Proporcional "+iif(nDtAvos>0,strzero(ndtavos,2),"--")+"/12 avos","Nome","1")
           xmlCell(nFile,"String",iif(nDtVal>0,alltrim(transf(nDtVal,"@E 999,999.99")),"  "),"Valor")
           xmlCell(nFile,"String","64 13 salario exercicio AAAA","Nome","1")
           xmlCell(nFile,"String","  ","Valor")
           xmlCell(nFile,"String","Vale alimentacao ref a","Nome","1")
           xmlCell(nFile,"String",if(nValeAlim>0,alltrim(transf(nValeAlim,"@E 999,999.99")),"  "),"Valor")
        xmlfechaLinha(nfile)

        xmlabreLinha(nFile,"0","30")
           xmlCell(nFile,"String","65 Ferias proporcionais "+iif(nFrPropFra>0,strzero(nFrPropFra,2),"--")+"/12 avos","Nome","1")
           xmlCell(nFile,"String",iif(nFrPropVal>0,alltrim(transf(nFrPropVal,"@E 999,999.99")),"  "),"Valor")
           xmlCell(nFile,"String","66 Ferias vencidas per. aquisitivo "+iif(!empty(dAq_ini),dtoc(dAq_Ini),"    ")+ " a "+iif(!empty(dAq_fim),dtoc(dAq_fim),"    ")+ " "+ strzero(nFrVencFra,2)+"/12 avos","Nome","1")
           xmlCell(nFile,"String",iif(nFrVencVal>0,alltrim(transf(nFrVencVal,"@E 999,999.99")),"  "),"Valor")
           xmlCell(nFile,"String","Ferias sobrando","Nome","1")
           xmlCell(nFile,"String","   ","Valor")
        xmlfechaLinha(nfile)

        xmlabreLinha(nFile,"0","30")
           xmlCell(nFile,"String","68 Terco constitucional de ferias","Nome","1")
           xmlCell(nFile,"String",iif(nFRTerco>0,alltrim(transf(nFrTerco,"@E 999,999.99")),"   "),"Valor")
           xmlCell(nFile,"String","69 aviso-Previo Indenizado","Nome","1")
           xmlCell(nFile,"String",iif(nAviso>0,alltrim(transf(nAviso,"@E 999,999.99")),"  "),"Valor")
           xmlCell(nFile,"String","70 13o Aviso-Previo Indenizado","Nome","1")
           xmlCell(nFile,"String",iif(nDTAviso>0,alltrim(transf(nDTAviso,"@E 999,999.99")),"  "),"Valor")
        xmlfechaLinha(nfile)

        xmlabreLinha(nFile,"0","30")
           xmlCell(nFile,"String","71 Ferias Aviso-Previo Indenizado","Nome","1")
           xmlCell(nFile,"String",iif(nFrAviso>0,alltrim(transf(nFrAviso,"@E 999,999.99")),"  "),"Valor")
           xmlCell(nFile,"String","   ","Nome","1")
           xmlCell(nFile,"String","   ","Valor")
           xmlCell(nFile,"String","   ","Nome","1")
           xmlCell(nFile,"String","   ","Valor")
        xmlfechaLinha(nfile)

        xmlabreLinha(nFile,"0","30")
           xmlCell(nFile,"String","   ","Nome","1")
           xmlCell(nFile,"String","   ","Valor")
           xmlCell(nFile,"String","   ","Nome","1")
           xmlCell(nFile,"String","   ","Valor")
           xmlCell(nFile,"String","TOTAL RESCISORIO BRUTO","Totais","1")
           xmlCell(nFile,"String",alltrim(transf(nProventos,"@E 999,999.99")),"SubTitulo")
        xmlfechaLinha(nfile)

        xmlabreLinha(nFile,"0","15")
           xmlCell(nFile,"String","IDENTIFICACAO DO EMPREGADOR","SubTitulo","8")
        xmlfechaLinha(nfile)

        xmlabreLinha(nFile,"0","12")
           xmlCell(nFile,"String","01 CNPJ/CEI","Nome","1")
           xmlCell(nFile,"String","02 Razao social/Nome","Nome","6")
        xmlFechaLinha(nFile)

        xmlabreLinha(nFile,"0","15")
           xmlCell(nFile,"String",transf(FILIAL->cgccpf,"@R 99.999.999/9999-99"),"Conteudo","1")
           xmlCell(nFile,"String",rtrim(FILIAL->Razao),"Conteudo","6")
        xmlFechaLinha(nFile)


        xmlabreLinha(nFile,"0","15")
           xmlCell(nFile,"String","DEDUCOES","Verbas","8")
        xmlfechaLinha(nfile)

        xmlabreLinha(nFile,"0","15")
           xmlCell(nFile,"String","Descontos","Rubrica","1")
           xmlCell(nFile,"String","Valor","Rubrica")
           xmlCell(nFile,"String","Descontos","Rubrica","1")
           xmlCell(nFile,"String","Valor","Rubrica")
           xmlCell(nFile,"String","Descontos","Rubrica","1")
           xmlCell(nFile,"String","Valor","Rubrica")
        xmlfechaLinha(nfile)

        xmlabreLinha(nFile,"0","30")
           xmlCell(nFile,"String","100 Pensao Alimenticia","Nome","1")
           xmlCell(nFile,"String",alltrim(transf(nPensao,"@E 999,999.99")),"Valor")
           xmlCell(nFile,"String","101 Adiantamento salarial","Nome","1")
           xmlCell(nFile,"String",alltrim(transf(nAdiant,"@E 999,999.99")),"Valor")
           xmlCell(nFile,"String","102 Adiantamento de 13 Salario","Nome","1")
           xmlCell(nFile,"String",alltrim(transf(nAdDT,"@E 999,999.99")),"Valor")
        xmlfechaLinha(nfile)

        xmlabreLinha(nFile,"0","30")
           xmlCell(nFile,"String","103 Aviso-Previo indenizado","Nome","1")
           xmlCell(nFile,"String",alltrim(transf(nDescAviso,"@E 999,999.99")),"Valor")
           xmlCell(nFile,"String","104 Multa Art. 480/CLT","Nome","1")
           xmlCell(nFile,"String",alltrim(transf(nMulta480,"@E 999,999.99")),"Valor")
           xmlCell(nFile,"String","105 Emprestimo em consignacao","Nome","1")
           xmlCell(nFile,"String",alltrim(transf(nEmpConsig,"@E 999,999.99")),"Valor")
        xmlfechaLinha(nfile)

        xmlabreLinha(nFile,"0","30")
           xmlCell(nFile,"String","112.1  Previdencia Social","Nome","1")
           xmlCell(nFile,"String",alltrim(transf(nINSSMS,"@E 999,999.99")),"Valor")
           xmlCell(nFile,"String","112.2  13o Previdencia Social","Nome","1")
           xmlCell(nFile,"String",alltrim(transf(nINSSDT,"@E 999,999.99")),"Valor")
           xmlCell(nFile,"String","113.1 IRRF","Nome","1")
           xmlCell(nFile,"String",alltrim(transf(nIRRFMS,"@E 999,999.99")),"Valor")
        xmlfechaLinha(nfile)

        xmlabreLinha(nFile,"0","30")
           xmlCell(nFile,"String","113.2  IRRF s/ 13o salario","Nome","1")
           xmlCell(nFile,"String",alltrim(transf(nIRRFDT,"@E 999,999.99")),"Valor")
           xmlCell(nFile,"String","    ","Nome","1")
           xmlCell(nFile,"String","   ","Valor")
           xmlCell(nFile,"String","   ","Nome","1")
           xmlCell(nFile,"String","   ","Valor")
        xmlfechaLinha(nfile)

        xmlabreLinha(nFile,"0","30")
           xmlCell(nFile,"String","   ","Nome","1")
           xmlCell(nFile,"String","   ","Valor")
           xmlCell(nFile,"String","   ","Nome","1")
           xmlCell(nFile,"String","   ","Valor")
           xmlCell(nFile,"String","TOTAL DEDUCOES","Totais","1")
           xmlCell(nFile,"String",alltrim(transf(nDescontos,"@E 999,999.99")),"SubTitulo")
        xmlfechaLinha(nfile)

        xmlabreLinha(nFile,"0","30")
           xmlCell(nFile,"String","   ","Nome","1")
           xmlCell(nFile,"String","   ","Valor")
           xmlCell(nFile,"String","   ","Nome","1")
           xmlCell(nFile,"String","   ","Valor")
           xmlCell(nFile,"String","LIQUIDO A PAGAR","Totais","1")
           xmlCell(nFile,"String",alltrim(transf(nLiquido,"@E 999,999.99")),"SubTitulo")
        xmlfechaLinha(nfile)

        xmlabreLinha(nFile,"0","15")
           xmlCell(nFile,"String","FORMALIZACAo DA RESCISAO","SubTitulo","8")
        xmlfechaLinha(nfile)

        xmlabreLinha(nFile,"0","15")
           xmlCell(nFile,"String","150 Local e Data do recolhimento","Nome","3")
           xmlCell(nFile,"String","151 Carimbo e assinatura do empregador ou preposto","Nome","4")
        xmlfechaLinha(nfile)

        xmlabreLinha(nFile,"0","15")
           xmlCell(nFile,"String","     ","Conteudo","3")
           xmlCell(nFile,"String","     ","Conteudo","4")
        xmlfechaLinha(nfile)

        xmlabreLinha(nFile,"0","39")
           xmlCell(nFile,"String","152 Assinatura do trabalhador","Nome","3")
           xmlCell(nFile,"String","153 Assinatura do responsavel legal do trabalhador","Nome","4")
        xmlfechaLinha(nfile)


        xmlabreLinha(nFile,"0","15")
           xmlCell(nFile,"String","154 HOMOLOGACAO","Nome","3")
           xmlCell(nFile,"String","155 Digital do trabalhador","Nome","1")
           xmlCell(nFile,"String","156 Digital responsavel legal","Nome","2")
        xmlfechaLinha(nfile)

        xmlabreLinha(nFile,"0","9")
           xmlCell(nFile,"String","Foi prestada, gratuitamente, assistencia ao trabalhador, nos termos","Branco","3")
           xmlCell(nFile,"String","   ","Branco","1")
           xmlCell(nFile,"String","   ","Branco","2")
        xmlfechaLinha(nfile)

        xmlabreLinha(nFile,"0","9")
           xmlCell(nFile,"String","do Art. 477, Paragrafo 1o., da CLT, sendo","Branco","3")
           xmlCell(nFile,"String","   ","Branco","1")
           xmlCell(nFile,"String","   ","Branco","2")
        xmlfechaLinha(nfile)

        xmlabreLinha(nFile,"0","9")
           xmlCell(nFile,"String","comprovado, neste ato, o efetivo pagamento das verbas rescisorias","Branco","3")
           xmlCell(nFile,"String","   ","Branco","1")
           xmlCell(nFile,"String","   ","Branco","2")
        xmlfechaLinha(nfile)

        xmlabreLinha(nFile,"0","9")
           xmlCell(nFile,"String","acima especificadas.","Branco","3")
           xmlCell(nFile,"String","   ","Branco","1")
           xmlCell(nFile,"String","   ","Branco","2")
        xmlfechaLinha(nfile)

        xmlabreLinha(nFile,"0","18")
           xmlCell(nFile,"String","   ","Branco","3")
           xmlCell(nFile,"String","   ","Branco","1")
           xmlCell(nFile,"String","   ","Branco","2")
        xmlfechaLinha(nfile)

        xmlabreLinha(nFile,"0","21")
           xmlCell(nFile,"String"," _________________________________________    ","NomeBot","3")
           xmlCell(nFile,"String","   ","Branco","1")
           xmlCell(nFile,"String","   ","Branco","2")
        xmlfechaLinha(nfile)

        xmlabreLinha(nFile,"0","28.75")
           xmlCell(nFile,"String"," Local e Data  ","Branco","3")
           xmlCell(nFile,"String","   ","NomeBotLin","1")
           xmlCell(nFile,"String","   ","NomeBotLin","2")
        xmlfechaLinha(nfile)

        xmlabreLinha(nFile,"0","12")
           xmlCell(nFile,"String","   ","Branco","3")
           xmlCell(nFile,"String","158 Recepcao pelo banco(data e carimbo)   ","Nome","4")
        xmlfechaLinha(nfile)

        xmlabreLinha(nFile,"0","12")
           xmlCell(nFile,"String","   ","Branco","3")
           xmlCell(nFile,"String","   ","Branco","4")
        xmlfechaLinha(nfile)

        xmlabreLinha(nFile,"0","12")
           xmlCell(nFile,"String"," ________________________________________   ","Branco","3")
           xmlCell(nFile,"String","   ","Branco","4")
        xmlfechaLinha(nfile)

        xmlabreLinha(nFile,"0","12")
           xmlCell(nFile,"String"," Carimbo e assinatura do assistente ","Branco","3")
           xmlCell(nFile,"String","   ","Branco","4")
        xmlfechaLinha(nfile)

        xmlabreLinha(nFile,"0","57")
           xmlCell(nFile,"String","157 Identificacao do orgao homologador ","Nome","3")
           xmlCell(nFile,"String","   ","Branco","4")
        xmlfechaLinha(nfile)

        xmlabreLinha(nFile,"0","17")
           xmlCell(nFile,"String","A ASSISTENCIA NO ATO DE RESCISAO CONTRATUAL E GRATUITA.","FinalTop","8")
        xmlfechaLinha(nfile)

        xmlabreLinha(nFile,"0","17")
           xmlCell(nFile,"String","Pode o trabalhador iniciar acao judicial quanto aos creditos resultantes das relacoes de trabalho ate o limite de dois anos","FinalMid","8")
        xmlfechaLinha(nfile)

        xmlabreLinha(nFile,"0","17")
           xmlCell(nFile,"String","apos a extincao do contrato de trabalho(Inc. XXIX do Art. 7o. da constituicao Federal/1988).","FinalBot","8")
        xmlfechaLinha(nfile)

     xmlFechaPasta(nFile)
     xmlFecha(nFile)
return


static function xmlAbre(nfile)
local cXml := ""

	cXml := '<?xml version="1.0"?>'+chr(13)+chr(10)
	cXml += '<?mso-application progid="Excel.Sheet"?>'+chr(13)+chr(10)
	cXml += '<Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet"'+chr(13)+chr(10)
	cXml += 'xmlns:o="urn:schemas-microsoft-com:office:office"'+chr(13)+chr(10)
	cXml += 'xmlns:x="urn:schemas-microsoft-com:office:excel"'+chr(13)+chr(10)
	cXml += 'xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"'+chr(13)+chr(10)
	cXml += 'xmlns:html="http://www.w3.org/TR/REC-html40">'+chr(13)+chr(10)
   fWrite(nFile,cXml,len(cXml))
   cXml := ""
   cXml := '<DocumentProperties xmlns="urn:schemas-microsoft-com:office:office">'+chr(13)+chr(10)
   cXml += '<Author>Rescisao de Contrato de Trabalho</Author>'+chr(13)+chr(10)
   cXml += '<LastAuthor>Rescisao de Contrato de Trabalho</LastAuthor>'+chr(13)+chr(10)
   cXml += '<Created>'+ strzero(year(date()),4)+'-'+strzero(month(date()),2)+'-'+strzero(day(date()),2)+'T01:29:55Z</Created>'+chr(13)+chr(10)
   cXml += '<Company>EPB Informatica Ltda</Company>'+chr(13)+chr(10)
   cXml += '<Version>11.9999</Version>'+chr(13)+chr(10)
   cXml += '</DocumentProperties>'+chr(13)+chr(10)
   fWrite(nFile,cXml,len(cXml))
   cXml := ""
   cXml := '<ExcelWorkbook xmlns="urn:schemas-microsoft-com:office:excel">'+chr(13)+chr(10)
   cXml += '<WindowHeight>9240</WindowHeight>'+chr(13)+chr(10)
   cXml += '<WindowWidth>18195</WindowWidth>'+chr(13)+chr(10)
   cXml += '<WindowTopX>480</WindowTopX>'+chr(13)+chr(10)
   cXml += '<WindowTopY>120</WindowTopY>'+chr(13)+chr(10)
   cXml += '<ProtectStructure>False</ProtectStructure>'  +chr(13)+chr(10)
   cXml += '<ProtectWindows>False</ProtectWindows>'+chr(13)+chr(10)
   cXml += '</ExcelWorkbook>'+chr(13)+chr(10)
   cXml += '<Styles>'+chr(13)+chr(10)
   cXml += '<Style ss:ID="Default" ss:Name="Normal">'+chr(13)+chr(10)
   cXml += '<Alignment ss:Vertical="Bottom"/>'+chr(13)+chr(10)
   cXml += '<Borders/>'+chr(13)+chr(10)
   cXml += '<Font/>'+chr(13)+chr(10)
   cXml += '<Interior/>'+chr(13)+chr(10)
   cXml += '<NumberFormat/>'+chr(13)+chr(10)
   cXml += '<Protection/>'+chr(13)+chr(10)
   cXml += '</Style>'+chr(13)+chr(10)
   fWrite(nFile,cXml,len(cXml))

return

static function xmlAbrePasta(nFile,cNome)
local cXml := ""

    cXml := '<Worksheet ss:Name="'+cNome+'">'+chr(13)+chr(10)
    cXml += '<Table ss:ExpandedColumnCount="10" ss:ExpandedRowCount="300" x:FullColumns="1" x:FullRows="1" ss:DefaultRowHeight="9">'+chr(13)+chr(10)
    cXml += '<Column ss:StyleID="s21" ss:AutoFitWidth="0" ss:Width="61.5"/>'+chr(13)+chr(10)
    cXml += '<Column ss:StyleID="s21" ss:AutoFitWidth="0" ss:Width="58.5"/>'+chr(13)+chr(10)
    cXml += '<Column ss:StyleID="s21" ss:AutoFitWidth="0" ss:Width="57"/>'+chr(13)+chr(10)
    cXml += '<Column ss:StyleID="s21" ss:AutoFitWidth="0" ss:Width="51"/>'+chr(13)+chr(10)
    cXml += '<Column ss:Index="6" ss:StyleID="s21" ss:AutoFitWidth="0" ss:Width="57"/>'+chr(13)+chr(10)
    cXml += '<Column ss:StyleID="s21" ss:AutoFitWidth="0" ss:Width="55.5"/>'+chr(13)+chr(10)
    cXml += '<Column ss:Index="9" ss:StyleID="s21" ss:AutoFitWidth="0" ss:Width="57"/>'+chr(13)+chr(10)

    

    fwrite(nFile,cXml,len(cXml))

return

static function xmlFechaPasta(nFile)
local cXml := ""

    cXml := '</Table>'+chr(13)+chr(10)  
    cXml += '<WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">'+chr(13)+chr(10)
    cXml += '<PageSetup>'+chr(13)+chr(10)
    cXml += '<Header x:Margin="1.1811023622047245"/>'+chr(13)+chr(10)
    cXml += '<Footer x:Margin="0.78740157480314965"/>'+chr(13)+chr(10)
    cXml += '<PageMargins x:Bottom="0.78740157480314965" x:Left="0.39370078740157483" x:Top="0.98425196850393704" x:Right="0.39370078740157483"/>'+chr(13)+chr(10)
    cXml += '</PageSetup>'+chr(13)+chr(10)
    cXml += '<Unsynced/>'+chr(13)+chr(10)
    cXml += '<Print>'+chr(13)+chr(10)
    cXml += '<ValidPrinterInfo/>'+chr(13)+chr(10)
    cXml += '<Scale>95</Scale>'+chr(13)+chr(10)
    cXml += '<HorizontalResolution>600</HorizontalResolution>'+chr(13)+chr(10)
    cXml += '<VerticalResolution>600</VerticalResolution>'+chr(13)+chr(10)
    cXml += '</Print>'+chr(13)+chr(10)
   // cXml += '<ShowPageBreakZoom/>'+chr(13)+chr(10)
    cXml += '<Selected/>'+chr(13)+chr(10)
    cXml += '<Panes>'+chr(13)+chr(10)
    cXml += '<Pane>'+chr(13)+chr(10)
    cXml += '<Number>3</Number>'+chr(13)+chr(10)
    cXml += '<RangeSelection>R1C1:R1C9</RangeSelection>'+chr(13)+chr(10)
    cXml += '</Pane>'+chr(13)+chr(10)
    cXml += '</Panes>'+chr(13)+chr(10)
    cXml += '<ProtectObjects>False</ProtectObjects>'+chr(13)+chr(10)
    cXml += '<ProtectScenarios>False</ProtectScenarios>'+chr(13)+chr(10)
    cXml += '</WorksheetOptions>'+chr(13)+chr(10)
    cXml += '<PageBreaks xmlns="urn:schemas-microsoft-com:office:excel">'+chr(13)+chr(10)
    cXml += '<RowBreaks>'+chr(13)+chr(10)
    cXml += '<RowBreak>'+chr(13)+chr(10)
    cXml += '<Row>39</Row>'+chr(13)+chr(10)
    cXml += '</RowBreak>'+chr(13)+chr(10)
    cXml += '</RowBreaks>'+chr(13)+chr(10)
    cXml += '</PageBreaks>'+chr(13)+chr(10)
    cXml += '</Worksheet>'+chr(13)+chr(10)
    fwrite(nFile,cXml,len(cXml))

return

static function xmlFecha(nFile)
local cXml := ""

    cXml := '</Workbook>'+chr(13)+chr(10)
    fwrite(nFile,cXml,len(cXml))
    fClose(nFile)
    
return

static function xmlAbreLinha(nFile,cAutoFit,cHeight)
local cXml := ""

         if cAutoFit == NIL
            cAutofit := "0"
         endif

         if cHeight == NIL
            cXml := '<Row ss:AutoFitHeight="'+cAutofit+'">'+chr(13)+chr(10)
         else
            cXml := '<Row ss:AutoFitHeight="'+cAutofit+'" ss:Height="'+cHeight+'">'+chr(13)+chr(10)
         endif
	 fwrite(nFile,cXml,len(cXml))
return

static function xmlFechaLinha(nFile)
local cXml := ""

	 cXml := '</Row>' +chr(13)+chr(10)
	 fwrite(nFile,cXml,len(cXml))
return

static function xmlFechaStyles(nFile)
local cXml := ""

	 cXml := '</Styles>' +chr(13)+chr(10)
	 fwrite(nFile,cXml,len(cXml))
return

static function xmlCell(nFile,cTipo,cValor,cStyleID,cMerge)
local cXml := ""

         if cMerge == NIL
            cMerge := "0"
         endif

	 if cStyleID == NIL
            cXml := '<Cell ss:MergeAcross="'+cMerge+'"><Data ss:Type="'+cTipo+'">'+cValor+'</Data></Cell>'+chr(13)+chr(10)
	 else
            cXml := '<Cell ss:MergeAcross="'+cMerge+'" ss:StyleID="'+cStyleID+'"><Data ss:Type="'+cTipo+'">'+cValor+'</Data></Cell>'+chr(13)+chr(10)
	 endif   
	 fwrite(nFile,cXml,len(cXml))
return


static function xmlTituloStyle(nFile)
local cXml := ""
         cXml := '<Style ss:ID="Titulo">'+chr(13)+chr(10)
	 cXml += '<Alignment ss:Horizontal="Center" ss:Vertical="Center"/>'+chr(13)+chr(10)
	 cXml += '<Borders>'+chr(13)+chr(10)
	 cXml += '<Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
         cXml += '<Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
         cXml += '<Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
         cXml += '<Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
	 cXml += '</Borders>'+chr(13)+chr(10)
         cXml += '<Font x:Family="Swiss" ss:Size="12" ss:Bold="1"/>'+chr(13)+chr(10)
         cXml += '<Interior ss:Color="#969696" ss:Pattern="Solid"/>'+chr(13)+chr(10)
	 cXMl += '</Style>'+chr(13)+chr(10)
	 fwrite(nFile,cXml,len(cXml))
return

static function xmlS21Style(nFile)
local cXml := ""
         cXml := '<Style ss:ID="s21">'+chr(13)+chr(10)
         cXml += '<Font x:Family="Swiss" ss:Size="7"/>'+chr(13)+chr(10)
         cXml += '<Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>'+chr(13)+chr(10)
	 cXMl += '</Style>'+chr(13)+chr(10)
	 fwrite(nFile,cXml,len(cXml))
return

static function xmlSubTituloStyle(nFile)
local cXml := ""
         cXml := '<Style ss:ID="SubTitulo">'+chr(13)+chr(10)
	 cXml += '<Alignment ss:Horizontal="Center" ss:Vertical="Center"/>'+chr(13)+chr(10)
	 cXml += '<Borders>'+chr(13)+chr(10)
         cXml += '<Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
         cXml += '<Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
         cXml += '<Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
	 cXml += '</Borders>'+chr(13)+chr(10)
         cXml += '<Font x:Family="Swiss" ss:Size="8" ss:Bold="1"/>'+chr(13)+chr(10)
         cXml += '<Interior ss:Color="#969696" ss:Pattern="Solid"/>'+chr(13)+chr(10)
	 cXMl += '</Style>'+chr(13)+chr(10)
	 fwrite(nFile,cXml,len(cXml))
return

static function xmlNomeStyle(nFile)
local cXml := ""
   
   cXml := '<Style ss:ID="Nome">'+chr(13)+chr(10)
   cXml += '<Alignment ss:Horizontal="Left" ss:Vertical="Top"/>'+chr(13)+chr(10)
   cXml += '<Borders>'+chr(13)+chr(10)
   cXml += ' <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
   cXml += ' <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
   cXml += ' <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
   cXml += '</Borders>'+chr(13)+chr(10)
   cXml += '<Font x:Family="Swiss" ss:Size="7"/>'+chr(13)+chr(10)
   cXml += '<Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>'+chr(13)+chr(10)
   cXml += '</Style>'+chr(13)+chr(10)
   fwrite(nFile,cXml,len(cXml))

   cXml := '<Style ss:ID="Conteudo2">'+chr(13)+chr(10)
   cXml += '<Alignment ss:Horizontal="Left" ss:Vertical="Top"/>'+chr(13)+chr(10)
   cXml += '<Borders>'+chr(13)+chr(10)
   cXml += ' <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
   cXml += ' <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
   cXml += ' <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
   cXml += '</Borders>'+chr(13)+chr(10)
   cXml += '<Font x:Family="Swiss" ss:Size="10"/>'+chr(13)+chr(10)
   cXml += '<Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>'+chr(13)+chr(10)
   cXml += '</Style>'+chr(13)+chr(10)
   fwrite(nFile,cXml,len(cXml))

return

static function xmlConteudoStyle(nFile)
local cXml := ""
   
   cXml := '<Style ss:ID="Conteudo">'+chr(13)+chr(10)
   cXml += '<Alignment ss:Horizontal="Left" ss:Vertical="Top"/>'+chr(13)+chr(10)
   cXml += '<Borders>'+chr(13)+chr(10)
   cXml += ' <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
   cXml += ' <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
   cXml += '</Borders>'+chr(13)+chr(10)
   cXml += '<Font x:Family="Swiss" ss:Size="10"/>'+chr(13)+chr(10)
   cXml += '<Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>'+chr(13)+chr(10)
   cXml += '</Style>'+chr(13)+chr(10)
   fwrite(nFile,cXml,len(cXml))
return

static function xmlOutroStyle(nFile)
local cXml := ""
   
   cXml := '<Style ss:ID="Verbas">'+chr(13)+chr(10)
   cXml += '<Alignment ss:Horizontal="Center" ss:Vertical="Center"/>'+chr(13)+chr(10)
   cXml += '<Borders>'+chr(13)+chr(10)
   cXml += ' <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
   cXml += ' <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
   cXml += ' <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
   cXml += '</Borders>'+chr(13)+chr(10)
   cXml += '<Font x:Family="Swiss" ss:Size="8" ss:Bold="1"/>'+chr(13)+chr(10)
   cXml += '<Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>'+chr(13)+chr(10)
   cXml += '</Style>'+chr(13)+chr(10)
   fwrite(nFile,cXml,len(cXml))

   cXml := '<Style ss:ID="Rubrica">'+chr(13)+chr(10)
   cXml += '<Alignment ss:Horizontal="Left" ss:Vertical="Center"/>'+chr(13)+chr(10)
   cXml += '<Borders>'+chr(13)+chr(10)
   cXml += ' <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
   cXml += ' <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
   cXml += ' <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
   cXml += ' <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
   cXml += '</Borders>'+chr(13)+chr(10)
   cXml += '<Font x:Family="Swiss" ss:Size="8" ss:Bold="1"/>'+chr(13)+chr(10)
   cXml += '<Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>'+chr(13)+chr(10)
   cXml += '</Style>'+chr(13)+chr(10)
   fwrite(nFile,cXml,len(cXml))

   cXml := '<Style ss:ID="Valor">'+chr(13)+chr(10)
   cXml += '<Alignment ss:Horizontal="Right" ss:Vertical="Center"/>'+chr(13)+chr(10)
   cXml += '<Borders>'+chr(13)+chr(10)
   cXml += ' <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
   cXml += ' <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
   cXml += ' <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
   cXml += ' <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
   cXml += '</Borders>'+chr(13)+chr(10)
   cXml += '<Font x:Family="Swiss" ss:Size="10"/>'+chr(13)+chr(10)
   cXml += '<Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>'+chr(13)+chr(10)
   cXml += '</Style>'+chr(13)+chr(10)
   fwrite(nFile,cXml,len(cXml))

   cXml := '<Style ss:ID="Totais">'+chr(13)+chr(10)
   cXml += '<Alignment ss:Horizontal="Right" ss:Vertical="Center"/>'+chr(13)+chr(10)
   cXml += '<Borders>'+chr(13)+chr(10)
   cXml += '<Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
   cXml += '<Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
   cXml += '<Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
   cXml += '</Borders>'+chr(13)+chr(10)
   cXml += '<Font x:Family="Swiss" ss:Size="8"/>'+chr(13)+chr(10)
   cXml += '<Interior ss:Color="#969696" ss:Pattern="Solid"/>'+chr(13)+chr(10)
   cXMl += '</Style>'+chr(13)+chr(10)
   fwrite(nFile,cXml,len(cXml))

   cXml := '<Style ss:ID="Branco">'+chr(13)+chr(10)
   cXml += '<Alignment ss:Horizontal="Left" ss:Vertical="Top"/>'+chr(13)+chr(10)
   cXml += '<Borders>'+chr(13)+chr(10)
   cXml += ' <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
   cXml += ' <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
   cXml += '</Borders>'+chr(13)+chr(10)
   cXml += '<Font x:Family="Swiss" ss:Size="7"/>'+chr(13)+chr(10)
   cXml += '<Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>'+chr(13)+chr(10)
   cXml += '</Style>'+chr(13)+chr(10)
   fwrite(nFile,cXml,len(cXml))

   cXml := '<Style ss:ID="NomeBot">'+chr(13)+chr(10)
   cXml += '<Alignment ss:Horizontal="Left" ss:Vertical="Bottom"/>'+chr(13)+chr(10)
   cXml += '<Borders>'+chr(13)+chr(10)
   cXml += ' <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
   cXml += ' <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
   cXml += '</Borders>'+chr(13)+chr(10)
   cXml += '<Font x:Family="Swiss" ss:Size="7"/>'+chr(13)+chr(10)
   cXml += '<Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>'+chr(13)+chr(10)
   cXml += '</Style>'+chr(13)+chr(10)
   fwrite(nFile,cXml,len(cXml))

   cXml := '<Style ss:ID="NomeBotLin">'+chr(13)+chr(10)
   cXml += '<Alignment ss:Horizontal="Left" ss:Vertical="Bottom"/>'+chr(13)+chr(10)
   cXml += '<Borders>'+chr(13)+chr(10)
   cXml += ' <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
   cXml += ' <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
   cXml += ' <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)

   cXml += '</Borders>'+chr(13)+chr(10)
   cXml += '<Font x:Family="Swiss" ss:Size="7"/>'+chr(13)+chr(10)
   cXml += '<Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>'+chr(13)+chr(10)
   cXml += '</Style>'+chr(13)+chr(10)
   fwrite(nFile,cXml,len(cXml))

   cXml := '<Style ss:ID="FinalTop">'+chr(13)+chr(10)
   cXml += '<Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>'+chr(13)+chr(10)
   cXml += '<Borders>'+chr(13)+chr(10)
   cXml += '<Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
   cXml += '<Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
   cXml += '<Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
   cXml += '</Borders>'+chr(13)+chr(10)
   cXml += '<Font x:Family="Swiss" ss:Size="8"/>'+chr(13)+chr(10)
   cXml += '<Interior ss:Color="#969696" ss:Pattern="Solid"/>'+chr(13)+chr(10)
   cXMl += '</Style>'+chr(13)+chr(10)
   fwrite(nFile,cXml,len(cXml))

   cXml := '<Style ss:ID="FinalMid">'+chr(13)+chr(10)
   cXml += '<Alignment ss:Horizontal="Center" ss:Vertical="Center"/>'+chr(13)+chr(10)
   cXml += '<Borders>'+chr(13)+chr(10)
   cXml += '<Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
   cXml += '<Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
   cXml += '</Borders>'+chr(13)+chr(10)
   cXml += '<Font x:Family="Swiss" ss:Color="#FFFFFF" ss:Size="8"/>'+chr(13)+chr(10)
   cXml += '<Interior ss:Color="#969696" ss:Pattern="Solid"/>'+chr(13)+chr(10)
   cXMl += '</Style>'+chr(13)+chr(10)
   fwrite(nFile,cXml,len(cXml))

   cXml := '<Style ss:ID="FinalBot">'+chr(13)+chr(10)
   cXml += '<Alignment ss:Horizontal="Center" ss:Vertical="Top"/>'+chr(13)+chr(10)
   cXml += '<Borders>'+chr(13)+chr(10)
   cXml += '<Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
   cXml += '<Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
   cXml += '<Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>'+chr(13)+chr(10)
   cXml += '</Borders>'+chr(13)+chr(10)
   cXml += '<Font x:Family="Swiss" ss:Size="8"/>'+chr(13)+chr(10)
   cXml += '<Interior ss:Color="#969696" ss:Pattern="Solid"/>'+chr(13)+chr(10)
   cXMl += '</Style>'+chr(13)+chr(10)
   fwrite(nFile,cXml,len(cXml))


return






