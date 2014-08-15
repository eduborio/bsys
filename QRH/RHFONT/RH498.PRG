/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: FOLHA DE PAGAMENTO
// OBJETIVO...: CONVERSAO DE SISTEMAS - MASTERMARQ P/ QSYS
// ANALISTA...: IN SUNG CHANG
// PROGRAMADOR: O MESMO
// INICIO.....: ABRIL DE 1997
// OBS........:
// ALTERACOES.:

#include "rh.ch"

if ! qconf("Confirma Convers„o de Sistemas ?")
   return
endif

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

private cPATH1   // caminho da empresa E001 do QRH
private cPATH2   // caminho para empresa dAa MATERMAQ
private cPATH3   // caminho para empresa do QRH (destino)

qgirabarra()

// CRIA PATH'S ORIGEM E DESTINO PARA SISTEMA QRH _____________________

cPATH1 := "\QSYS_G\QRH\E001\"
cPATH2 := "\QCONVERT\"
cPATH3 := "\QSYS_G\QRH\E" + XEMPRESA + "\"

qsay(13,16,XEMPRESA)

// VERIFICA EXISTENCIA DO DIRETORIO NO QRH, SENAO CRIA _______________

// if XEMPRESA != "001"
//    if ! qmdir("E" + XEMPRESA)
//       qmensa("N„o foi poss¡vel criar diret¢rio E" + XEMPRESA + " !! Verifique.","B")
//       return
//    endif
// endif

if quse(XDRV_RH,"CARGO",{"CA_CODIG","CA_DESCR"},"E")
   CARGO->(__dbzap())
   quse(cPATH2,"FCOES"+XEMPRESA,NIL,"E","FCOES")
   FCOES->(dbCreateIndex( (cPATH2 + "FCOES"), "FUNCAO", {|| Funcao}, if( .F., .T., NIL )))
   do while ! FCOES->(eof())
      qgirabarra()
      CARGO->(qappend())
      replace CARGO->Codigo    with FCOES->Funcao
      replace CARGO->Descricao with FCOES->Nome
      qmensa("Cargo: " + CARGO->Codigo)
      FCOES->(dbskip())
   enddo
endif

if quse(XDRV_CT,"CCUSTO",{"CC_CODIG","CC_DESCR","CC_SUPER","CC_CODRD"},"E")
   CCUSTO->(__dbzap())
   quse(cPATH2,"DEPTO",NIL,"E")
   DEPTO->(dbCreateIndex( (cPATH2 + "DEPTO"), "DEPTO", {|| Depto}, if( .F., .T., NIL )))
   do while ! DEPTO->(eof())
      qgirabarra()
      CCUSTO->(qappend())
      replace CCUSTO->Codigo    with "0101" + strzero(val(DEPTO->Depto),4)
      replace CCUSTO->Descricao with DEPTO->Nome
      qmensa("Centro de Custo: " + CCUSTO->Codigo)
      DEPTO->(dbskip())
   enddo
endif

if quse(XDRV_RHX,"SIND",{"SI_CODIG","SI_DESCR"},"E")
   SIND->(__dbzap())
   quse(cPATH2,"SINDI",NIL,"E")
   do while ! SINDI->(eof())
      qgirabarra()
      SIND->(qappend())
      replace SIND->Codigo    with SINDI->Sindicato
      replace SIND->Descricao with SINDI->Nome
      replace SIND->Endereco  with SINDI->Endereco
      replace SIND->Bairro    with SINDI->Bairro
      CGM->(dbsetorder(2))
      CGM->(dbgotop())
      CGM->(dbseek(alltrim(SINDI->Cidade)))
      if ! empty(SINDI->Cidade)
         replace SIND->Cgm       with CGM->Codigo
      endif
      replace SIND->Telefone  with SINDI->Telefone
      replace SIND->Data_base with SINDI->Data_base
      qmensa("Sindicato: " + SIND->Codigo)
      SINDI->(dbskip())
   enddo
endif

if quse(cPATH3,"FUN",{"FU_MATRI","FU_NOME","FU_FDMAT","FU_FDNOM","FU_FILMA","FU_FILNO","FU_CENMA","FU_CENNO","FU_MTASS","FU_GRPS"},"E")
   quse(cPATH3,"SITUA",{"SI_MATRI"},"E")
   FUN->(__dbzap())
   SITUA->(__dbzap())
   quse(cPATH2,"FUNCS"+XEMPRESA,NIL,"E","FUNCS")
   quse(cPATH2,"SALAR"+XEMPRESA,NIL,"E","SALAR")
   quse(cPATH2,"AFAST"+XEMPRESA,NIL,"E","AFAST")
   quse(cPATH2,"RESC1"+XEMPRESA,NIL,"E","RESC1")
   quse(cPATH2,"FERI1"+XEMPRESA,NIL,"E","FERI1")
   FUNCS->(dbCreateIndex( (cPATH2 + "MATRIC3"), "FUNCC", {|| Funcc}, if( .F., .T., NIL )))
   SALAR->(dbCreateIndex( (cPATH2 + "MATRIC"), "FUNCC+dtos(DATA)", {|| Funcc+dtos(Data)}, if( .F., .T., NIL )))
   AFAST->(dbCreateIndex( (cPATH2 + "MATRIC1"), "FUNCC", {|| Funcc}, if( .F., .T., NIL )))
   FERI1->(dbCreateIndex( (cPATH2 + "MATRIC4"), "FUNCC", {|| Funcc}, if( .F., .T., NIL )))
   RESC1->(dbCreateIndex( (cPATH2 + "MATRIC2"), "FUNCC", {|| Funcc}, if( .F., .T., NIL )))
   do while ! FUNCS->(eof())
      cMACRO := iif(empty(FUNCS->Rescisao),"dDATA <= XDATASYS", "dDATA <= FUNCS->Rescisao" )
      dDATA  := FUNCS->Admissao
      if empty(dDATA)
         dDATA := ctod("")
         qgetx(14,16,@dDATA)
      endif
      FUN->(qappend())
      do while &cMACRO
         qgirabarra()
         SITUA->(qappend())
         replace SITUA->Anomes    with qanomes(dDATA)
         replace FUN->Matricula   with FUNCS->Funcc
         replace SITUA->Matricula with FUN->Matricula
         replace FUN->Nome        with FUNCS->Nome
         replace FUN->Filial      with iif(FUNCS->Filial<>"00",strzero(val(FUNCS->Filial),4),"0001")
         replace FUN->Centro      with "0101" + strzero(val(FUNCS->Depto),4)
         replace FUN->Prim_adm    with iif(FUNCS->Tipo_adm=="1","S","N")
         replace FUN->Data_adm    with FUNCS->Admissao
         replace FUN->Grps        with "0001"
         replace FUN->Nome_mae    with FUNCS->Mae
         replace FUN->Cpf_num     with qtiraponto(FUNCS->Cpf)
         replace FUN->Idt_num     with FUNCS->Ci
         replace FUN->Cp_num      with FUNCS->Carteira
         replace FUN->Cp_serie    with FUNCS->Serie
   //    CGM->(dbsetorder(3))
   //    CGM->(dbgotop())
   //    if CGM->(dbseek(FUNCS->Uf_cp))
   //       replace FUN->Cp_cgm with CGM->Codigo
   //    endif
         replace FUN->Fgts_dat  with FUNCS->Data_op
         replace FUN->Fgts_ban  with FUNCS->Bco_fgts
         replace FUN->Fgts_num  with FUNCS->Cta_fgts
         replace FUN->Csal_ban  with FUNCS->Banco
         replace FUN->Csal_num  with FUNCS->Conta
         replace FUN->Modal_pag with "1"
         replace FUN->Pis_num   with FUNCS->Pis
         replace FUN->Endereco  with FUNCS->Endereco
         replace FUN->Bairro    with FUNCS->Bairro
         CGM->(dbsetorder(2))
         CGM->(dbgotop())
         CGM->(dbseek(alltrim(FUNCS->Cidade)))
         if ! empty(FUNCS->Cidade)
            replace FUN->Resid_cgm with CGM->Codigo
         endif
         replace FUN->Cep      with FUNCS->Cep
         replace FUN->Telefone with right(FUNCS->Telefone,7)

         do case
            case FUNCS->Nacional == "10"
                 cNACIONAL := "A"
            case FUNCS->Nacional == "20"
                 cNACIONAL := "B"
            case FUNCS->Nacional == "21"
                 cNACIONAL := "C"
            case FUNCS->Nacional == "22"
                 cNACIONAL := "D"
            case FUNCS->Nacional == "23"
                 cNACIONAL := "E"
            case FUNCS->Nacional == "24"
                 cNACIONAL := "F"
            case FUNCS->Nacional == "25"
                 cNACIONAL := "G"
            case FUNCS->Nacional == "30"
                 cNACIONAL := "H"
            case FUNCS->Nacional == "31"
                 cNACIONAL := "I"
            case FUNCS->Nacional == "32"
                 cNACIONAL := "J"
            case FUNCS->Nacional == "34"
                 cNACIONAL := "K"
            case FUNCS->Nacional == "35"
                 cNACIONAL := "L"
            case FUNCS->Nacional == "36"
                 cNACIONAL := "M"
            case FUNCS->Nacional == "37"
                 cNACIONAL := "N"
            case FUNCS->Nacional == "38"
                 cNACIONAL := "O"
            case FUNCS->Nacional == "39"
                 cNACIONAL := "P"
            case FUNCS->Nacional == "41"
                 cNACIONAL := "Q"
            case FUNCS->Nacional == "42"
                 cNACIONAL := "R"
            case FUNCS->Nacional == "43"
                 cNACIONAL := "S"
            case FUNCS->Nacional == "45"
                 cNACIONAL := "T"
            case FUNCS->Nacional == "48"
                 cNACIONAL := "U"
            case FUNCS->Nacional == "49"
                 cNACIONAL := "V"
            case FUNCS->Nacional == "50"
                 cNACIONAL := "X"
         endcase
         replace FUN->Nacional  with cNACIONAL

         replace FUN->Sexo      with iif(FUNCS->Sexo=="1","M","F")

         do case
            case FUNCS->Est_civil == "1"
                 cEST_CIVIL := "2"
            case FUNCS->Est_civil == "2"
                 cEST_CIVIL := "1"
            case FUNCS->Est_civil == "3"
                 cEST_CIVIL := "5"
            case FUNCS->Est_civil == "4"
                 cEST_CIVIL := "3"
            case FUNCS->Est_civil == "5"
                 cEST_CIVIL := "4"
         endcase
         replace FUN->Est_civil with cEST_CIVIL

         do case
            case FUNCS->Instrucao == "10"
                 cINSTRUCAO := "1"
            case FUNCS->Instrucao == "20"
                 cINSTRUCAO := "2"
            case FUNCS->Instrucao == "25"
                 cINSTRUCAO := "3"
            case FUNCS->Instrucao == "30"
                 cINSTRUCAO := "4"
            case FUNCS->Instrucao == "35"
                 cINSTRUCAO := "5"
            case FUNCS->Instrucao == "40"
                 cINSTRUCAO := "6"
            case FUNCS->Instrucao == "45"
                 cINSTRUCAO := "7"
            case FUNCS->Instrucao == "50"
                 cINSTRUCAO := "8"
            case FUNCS->Instrucao == "55"
                 cINSTRUCAO := "9"
         endcase
         replace FUN->Instrucao  with cINSTRUCAO
         replace FUN->Data_nasc  with FUNCS->Nascimento
         replace FUN->Sind_cod   with FUNCS->Sindicato
         replace FUN->Hor_trab   with FUNCS->Horas_mes
         replace FUN->Hor_sema   with FUNCS->Horas_sem
         replace FUN->Aposentado with FUNCS->Aposentado

         qgirabarra()
         SALAR->(dbgotop())
//       ("SALAR"+XEMPRESA)->(dbCreateIndex( (cPATH2 + "MATRIC"), "FUNCC", {|| Funcc}, if( .F., .T., NIL )))
         SALAR->(dbSetFilter({|| Funcc == SITUA->Matricula}, 'Funcc == SITUA->Matricula'))
         SALAR->(dbgobottom())
//       if &("SALAR"+XEMPRESA)->(dbseek(SITUA->Matricula))
            replace SITUA->Categoria with SALAR->Tipo_sal
//       endif

         AFAST->(dbgotop())
//       ("AFAST"+XEMPRESA)->(dbCreateIndex( (cPATH2 + "MATRIC1"), "FUNCC", {|| Funcc}, if( .F., .T., NIL )))
         if AFAST->(dbseek(SITUA->Matricula)) .and.  qanomes(AFAST->Inicioaf) == qanomes(dDATA)
            do case
               case AFAST->Motivo == "1"
                    cAF_COD := "05"
               case AFAST->Motivo == "2"
                    cAF_COD := "06"
               case AFAST->Motivo == "3"
                    cAF_COD := "03"
               case AFAST->Motivo == "5"
                    cAF_COD := "04"
            endcase
            replace SITUA->Af_cod   with cAF_COD
            replace SITUA->Situacao with "A"
            replace FUN->Situacao with "A"
            replace SITUA->Af_ini   with AFAST->Inicioaf
            replace SITUA->Af_ret   with AFAST->Finalaf
         endif

         FERI1->(dbgotop())
//       ("FERI1"+XEMPRESA)->(dbCreateIndex( (cPATH2 + "MATRIC4"), "FUNCC", {|| Funcc}, if( .F., .T., NIL )))
         if FERI1->(dbseek(SITUA->Matricula))
            if qanomes(FERI1->Gozo) == qanomes(dDATA)
               replace SITUA->Situacao with "F"
               replace FUN->Situacao with "F"
            endif
            replace SITUA->Di_ferias with FERI1->Aquisitivo
            replace SITUA->Df_ferias with FERI1->Aquisitivo + 364
            replace SITUA->Pi_ferias with FERI1->Gozo
            replace SITUA->Pf_ferias with FERI1->Gozo + FERI1->Diasferias - 1
         else
            replace SITUA->Di_ferias with FUN->Data_adm
            replace SITUA->Df_ferias with FUN->Data_adm + 364
         endif

         RESC1->(dbgotop())
//       ("RESC1"+XEMPRESA)->(dbCreateIndex( (cPATH2 + "MATRIC2"), "FUNCC", {|| Funcc}, if( .F., .T., NIL )))
         if RESC1->(dbseek(SITUA->Matricula))
            replace SITUA->Inicio_av  with RESC1->Aviso
            replace SITUA->Af_ini     with RESC1->Afast
            replace SITUA->Codsaqfgts with RESC1->Cod_saque
            replace SITUA->Readmissao with "S"
            cAF_COD := "  "
            do case
               case RESC1->Mot_cged == "31"
                    cAF_COD := "22"
               case RESC1->Mot_cged == "32"
                    cAF_COD := "25"
               case RESC1->Mot_cged == "80"
                    cAF_COD := "40"
               case RESC1->Mot_cged == "40"
                    cAF_COD := "21"
               case RESC1->Mot_cged == "50"
                    cAF_COD := "27"
               case RESC1->Mot_cged == "60"
                    cAF_COD := "26"
            endcase
            if qanomes(SITUA->Af_ini) == qanomes(dDATA)
               replace SITUA->Af_cod   with cAF_COD
            endif
         endif

         if FUNCS->(dbseek(SITUA->Matricula))
//          if FUNCS->Rescisao <= XDATASYS-35 .and. ! empty(FUNCS->Rescisao)
//             replace SITUA->Situacao with "H"
//             replace FUN->Situacao   with "H"
//          endif
            if qanomes(FUNCS->Rescisao) == qanomes(dDATA) .and. ! empty(FUNCS->Rescisao)
               replace SITUA->Situacao with "D"
               replace FUN->Situacao with "D"
            endif
            if empty(SITUA->Situacao)
               replace SITUA->Situacao with "T"
               replace FUN->Situacao with "T"
            endif
            cVINCULO := "10"
            do case
               case FUNCS->Vinculo == "10"
                    cVINCULO := "A"
               case FUNCS->Vinculo == "15"
                    cVINCULO := "B"
               case FUNCS->Vinculo == "20"
                    cVINCULO := "C"
               case FUNCS->Vinculo == "25"
                    cVINCULO := "D"
               case FUNCS->Vinculo == "30"
                    cVINCULO := "E"
               case FUNCS->Vinculo == "35"
                    cVINCULO := "F"
               case FUNCS->Vinculo == "40"
                    cVINCULO := "G"
               case FUNCS->Vinculo == "50"
                    cVINCULO := "H"
               case FUNCS->Vinculo == "60"
                    cVINCULO := "I"
               case FUNCS->Vinculo == "70"
                    cVINCULO := "L"
               case FUNCS->Vinculo == "80"
                    cVINCULO := "N"
            endcase
            replace SITUA->Vinculo    with cVINCULO
            replace SITUA->Cargo      with FUNCS->Funcao
            FCOES->(dbseek(alltrim(SITUA->Cargo)))
            replace SITUA->Cbo        with transform(FCOES->Cbo,"@R 9.99.99")
            replace SITUA->Tipo_pgto  with "C"
            replace SITUA->Hentrada   with "08:00"
            replace SITUA->Hintervalo with "12:00-14:00"
            replace SITUA->Hsaida     with "18:00"
            replace SITUA->Hsabado    with "08:00-12:00"
            replace SITUA->Descanso   with "DOMINGO"
            replace SITUA->Salario    with val(transform(SALAR->Valor,"@E 999999.99"))
            replace SITUA->Dep_ir     with FUNCS->Depend
            replace SITUA->Dep_fam    with FUNCS->Filhos
         endif

         if strzero(month(dDATA)+1,2) =="13"
            dDATA := ctod(strzero(day(dDATA),2)+"/01/"+right(strzero(year(dDATA)+1,4),2))
         else
            dDATA := ctod(strzero(day(dDATA),2)+"/"+strzero(month(dDATA)+1,2)+"/"+right(strzero(year(dDATA),4),2))
         endif

         qmensa("Funcion rio: " + SITUA->Matricula + "/" + SITUA->Anomes)

      enddo

      FUNCS->(dbskip())

   enddo
endif

if quse(cPATH3,"LANC",{"LA_MATRI","LA_EVENT","LA_MAEVE"},"E")
   LANC->(__dbzap())
   quse(cPATH2,"PAY2_"+XEMPRESA,NIL,"E","PAY2_")
   PAY2_->(dbCreateIndex( (cPATH2 + "EVENT"), "EVENTO", {|| Evento}, if( .F., .T., NIL )))
   quse(cPATH2,"TEMP",NIL,"E")
   TEMP->(dbCreateIndex( (cPATH2 + "TEMP"), "EV_MAST", {|| Ev_mast}, if( .F., .T., NIL )))
   TEMP->(dbgotop())
   if ! TEMP->(dbseek(PAY2_->Evento))
      cEV_MAST := PAY2_->Evento
      cEV_QSYS  := "   "
      cAMBIENTE := "  "
      qsay(13,34,cEV_MAST)
      qgetx(13,54,@cEV_QSYS)
      qgetx(13,70,@cAMBIENTE)
      TEMP->(qappend())
      replace TEMP->Ev_mast  with cEV_MAST
      replace TEMP->Ev_qsys  with cEV_QSYS
      replace TEMP->Ambiente with cAMBIENTE
   else
      cEV_MAST  := TEMP->Ev_mast
      cEV_QSYS  := TEMP->Ev_qsys
      cAMBIENTE := TEMP->Ambiente
      qsay(13,34,cEV_MAST)
      qsay(13,54,@cEV_QSYS)
      qsay(13,70,@cAMBIENTE)
   endif
   do while ! PAY2_->(eof())
      qgirabarra()
      if cEV_MAST == PAY2_->Evento
         LANC->(qappend())
         replace LANC->Anomes    with qtiraponto(PAY2_->Movimento)
         replace LANC->Matricula with PAY2_->Funcc
         replace LANC->Ambiente  with cAMBIENTE
         replace LANC->Evento    with cEV_QSYS
         replace LANC->Valor     with PAY2_->Vencs + PAY2_->Descs
         replace LANC->Fracao    with PAY2_->Referencia
         if LANC->Evento == "207"
            replace LANC->Fixa   with .T.
         endif
      else
         TEMP->(dbgotop())
         if ! TEMP->(dbseek(PAY2_->Evento))
            cEV_MAST  := PAY2_->Evento
            cEV_QSYS  := "   "
            cAMBIENTE := "  "
            qsay(13,34,cEV_MAST)
            qgetx(13,54,@cEV_QSYS)
            qgetx(13,70,@cAMBIENTE)
            TEMP->(qappend())
            replace TEMP->Ev_mast  with cEV_MAST
            replace TEMP->Ev_qsys  with cEV_QSYS
            replace TEMP->Ambiente with cAMBIENTE
            loop
         else
            cEV_MAST  := TEMP->Ev_mast
            cEV_QSYS  := TEMP->Ev_qsys
            cAMBIENTE := TEMP->Ambiente
            qsay(13,34,cEV_MAST)
            qsay(13,54,@cEV_QSYS)
            qsay(13,70,@cAMBIENTE)
            loop
         endif
      endif
      PAY2_->(dbskip())
   enddo
endif

return
