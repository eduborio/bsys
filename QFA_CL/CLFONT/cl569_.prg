//////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO COMERCIO
// OBJETIVO...: LISTAGEM DE FATURANTP P DIA
// ANALISTA...: EDUARDO AUGUSTO BORIO
// PROGRAMADOR: EDUARDO AUGUSTO BORIO
// INICIO.....: SETEMBRO DE 2008
// OBS........:
// ALTERACOES.:

function cl569
#define K_MAX_LIN 57

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG) .or. empty(dINI) }

private cTITULO                   // titulo do relatorio
private dINI
private dFIM
private cSETOR := space(5)
private aEDICAO := {}             // vetor para os campos de entrada de dados

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qgetx(-1,0,@dINI)            } , "INI"    })

do while .T.

   qlbloc(5,0,"B569A","QBLOC.GLO")
   XNIVEL := 1
   XFLAG  := .T.
   dINI := dFIM := ctod("")

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
      case cCAMPO == "FIM"
           if dFIM < dINI
             return .F.
           endif

      case cCAMPO == "SETOR"

           qrsay(XNIVEL,cSETOR)

           if empty(cSETOR)
              qrsay(XNIVEL++, "Todos os Setores.......")
           else
              if ! SETOR->(Dbseek(cSETOR:=strzero(val(cSETOR),5)))
                 qmensa("Setor n„o Cadastrado","B")
                 return .F.
              else
                 qrsay(XNIVEL++,left(SETOR->Descricao,30))
              endif
           endif

   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // CRIA TITULO DO RELATORIO ______________________________________________


   cTITULO := "REL. DE VENCIMENTOS POR DATA DE EMISSAO" +" de " + qnomemes(dINI)

   qmensa("")

   // ESTABELECE RELACOES ENTRE ARQUIVOS ____________________________________

   FAT->(dbsetorder(2)) // data de emissao
   FAT->(dbseek(dtos(dINI),.T.))
   ITEN_FAT->(dbsetorder(2))
return .T.


static function i_impressao

   if ! qinitprn() ; return ; endif

   if XLOCALIMP == "X"
      i_impre_xls()
   else
      i_impre_prn()
   endif



return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impre_prn
    local lTEM := .F.
    local dEMIS := ctod("")
    local dVENC := ctod("")
    local aFAT := {}
    local asFAT := {}
    local nCONT := 0
    local nTT_EMIS := 0
    local nTT_GER  := 0
    local nTT_VENC := 0


    lTEM := .F.

   do while ! FAT->(eof())  .and. FAT->Dt_emissao >= dINI .and. FAT->Dt_emissao <= qfimmes(dINI)  // condicao principal de loop

      if FAT->Cancelado
         FAT->(dbskip())
         loop
      endif

      if empty(FAT->Num_fatura).and. FAT->Es == "S"
         FAT->(dbskip())
         loop
      endif

      if ! left(FAT->Cod_cfop,3) $ "510-610"
         FAT->(dbskip())
         loop
      endif
      qgirabarra()

      qmensa("Aguarde... Processando ...")

         DUP_FAT->(Dbseek(FAT->Codigo+"01"))
         Do While ! DUP_FAT->(Eof()) .and. left(DUP_FAT->Num_fat,5) == FAT->Codigo

             aadd(aFAT,{dtos(FAT->Dt_emissao),dtos(DataVenc()),DUP_FAT->Valor})
             lTEM := .T.
             DUP_FAT->(dbskip())
         enddo
         FAT->(dbskip())
   enddo
   //classifica a matriz por descricao do produto
   asFAT := asort(aFAT,,,{|x,y| x[1] + x[2] < y[1] + y[2] })
   if lTEM
       dEMIS := asFAT[1,1]
       dVENC := asFAT[1,2]
       cTITULO2 := rtrim("Faturamento do dia.:"+  dtoc(stod(dEMIS)))

       nCONT := 1
       do while  nCONT <= len(asFAT)

           if ! qlineprn() ; exit ; endif
           if XPAGINA == 0 .or. prow() > K_MAX_LIN
              qpageprn()
              qcabecprn(cTITULO,110,,cTITULO2)
              //@ prow()+1,0 say XCOND1 + "Produto                                                     Entrada       Saida                   Valor "
              //@ prow()+1,0 say replicate("-",110)
           endif

           nTT_EMIS += asFAT[nCONT,3]
           nTT_VENC += asFAT[nCONT,3]
           nTT_GER  += asFAT[nCONT,3]

           //@ prow()+1,00 say dtoc(stod(asFAT[nCONT,1]))
           //@ prow()  ,20 say dtoc(stod(asFAT[nCONT,2]))


           nCONT++
           if nCONT > len(asFAT)
              nCONT := len(asFAT)
              exit
           endif

           if asFAT[nCONT,2] != dVENC
              if stod(dVENC)-stod(dEMIS) > 0
                 @ prow()+1,00 say dtoc(stod(dVENC))+" "+transform(stod(dVENC)-stod(dEMIS),"@R 999")+" Dia(s) "+ transform(nTT_VENC,"@E 99,999,999.99")
              else

              endif
              dVENC := asFAT[nCONT,2]
              nTT_VENC := 0
           endif

           if asFAT[nCONT,1] != dEMIS
              @ prow()+2,00 say "Total do Dia "+dtoc(stod(dEMIS))+".: "+transform(nTT_EMIS,"@E 99,999,999.99")
              nTT_VENC := 0
              nTT_EMIS := 0
              dEMIS := asFAT[nCONT,1]
              dVENC := asFAT[nCONT,2]
              cTITULO2 := rtrim("Faturamento do dia.:"+  dtoc(stod(dEMIS)))
              eject
              qpageprn()
              qcabecprn(cTITULO,110,NIL,cTITULO2)

           endif
       enddo
   endif

   qstopprn()

return


static function i_impre_xls
    local lTEM := .F.
    local dEMIS := ctod("")
    local dVENC := ctod("")
    local aFAT := {}
    local asFAT := {}
    local nCONT := 0
    local nTT_EMIS := 0
    local nTT_GER  := 0
    local nTT_VENC := 0


    lTEM := .F.

   do while ! FAT->(eof())  .and. FAT->Dt_emissao >= dINI .and. FAT->Dt_emissao <= qfimmes(dINI)  // condicao principal de loop

      if FAT->Cancelado
         FAT->(dbskip())
         loop
      endif

      if empty(FAT->Num_fatura).and. FAT->Es == "S"
         FAT->(dbskip())
         loop
      endif

      if ! left(FAT->Cod_cfop,3) $ "510-610"
         FAT->(dbskip())
         loop
      endif
      qgirabarra()

      qmensa("Aguarde... Processando ...")

         DUP_FAT->(Dbseek(FAT->Codigo+"01"))
         Do While ! DUP_FAT->(Eof()) .and. left(DUP_FAT->Num_fat,5) == FAT->Codigo

             aadd(aFAT,{dtos(FAT->Dt_emissao),dtos(DataVenc()),DUP_FAT->Valor})
             DUP_FAT->(dbskip())
             lTEM := .T.
         enddo
         FAT->(dbskip())
   enddo

   //classifica a matriz por descricao do produto
   asFAT := asort(aFAT,,,{|x,y| x[1] + x[2] < y[1] + y[2] })
   if lTEM
       dEMIS := asFAT[1,1]
       dVENC := asFAT[1,2]

       nCONT := 1
       do while  nCONT <= len(asFAT)

           if ! qlineprn() ; exit ; endif
           if XPAGINA == 0 //.or. prow() > K_MAX_LIN
              qpageprn()
              @ prow()+1,00 say cTitulo
              @ prow()+1,00 say "Emissao"+chr(9)+"Vencimento"+chr(9)+"Dias"+chr(9)+"Valor"
           endif

           nTT_EMIS += asFAT[nCONT,3]
           nTT_VENC += asFAT[nCONT,3]
           nTT_GER  += asFAT[nCONT,3]

           nCONT++
           if nCONT > len(asFAT)
              nCONT := len(asFAT)
              exit
           endif

           if asFAT[nCONT,2] != dVENC
              //if stod(dVENC)-stod(dEMIS) > 0
                 @ prow()+1,00 say dtoc(stod(dEMIS))+chr(9)+dtoc(stod(dVENC))+chr(9)+transform(stod(dVENC)-stod(dEMIS),"@R 999")+" "+"Dia(s)"+chr(9)+ transform(nTT_VENC,"@E 99,999,999.99")
              //endif
              dVENC := asFAT[nCONT,2]
              nTT_VENC := 0
           endif

           if asFAT[nCONT,1] != dEMIS
              @ prow()+2,00 say "Total do Dia "+dtoc(stod(dEMIS))+".: "+transform(nTT_EMIS,"@E 99,999,999.99")
              nTT_VENC := 0
              nTT_EMIS := 0
              dEMIS := asFAT[nCONT,1]
              dVENC := asFAT[nCONT,2]
              @ prow()+3,00 say ""
           endif
       enddo

       @ prow()+1,00 say dtoc(stod(dEMIS))+chr(9)+dtoc(stod(dVENC))+chr(9)+transform(stod(dVENC)-stod(dEMIS),"@R 999")+" "+"Dia(s)"+chr(9)+ transform(nTT_VENC,"@E 99,999,999.99")
       dVENC := asFAT[nCONT,2]
       nTT_VENC := 0

       @ prow()+2,00 say "Total do Dia "+dtoc(stod(dEMIS))+".: "+transform(nTT_EMIS,"@E 99,999,999.99")
       nTT_VENC := 0
       nTT_EMIS := 0
       dEMIS := asFAT[nCONT,1]
       dVENC := asFAT[nCONT,2]
       @ prow()+3,00 say ""

       nTT_VENC := 0
       nTT_EMIS := 0

   endif

   qstopprn(.F.)

return


