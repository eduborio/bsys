//////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO DO COMERCIO
// OBJETIVO...: IMPRESSAO DE DUPLICATAS
// ANALISTA...: EDUARDO BORIO
// PROGRAMADOR: O MESMO
// INICIO.....: OUTUBRO DE 1999
// OBS........:
// ALTERACOES.:
function cl516
#define K_MAX_LIN 60

private cPEDIDOS  := ""
private cDOCTO    := space(10)
private cVALOR    := 0
private cJUROS    := 0
private cCAMPO1 := Space(45)
private cCAMPO2 := Space(45)
private cCAMPO3 := Space(45)


if CONFIG->Modelo_2 != "5"
  FAT->(dbSetFilter({|| ! CANCELADO.and.!empty(FAT->Num_fatura) .and. !left(FAT->Cod_cfop,4)$ "5912-6912-5910-6910-5911-6911-5917-6917-5915-6915"},"Todos"))
endif

//FAT->(dbsetfilter({|| FAT->Dt_emissao > ctod("24/09/2010") }))


/////////////////////////////////////////////////////////////////////////////
// MANUTENCAO DAS FATURAS __________________________________________________

FAT->(qview({{"Codigo/Pedido"         ,1},;
             {"Dt_emissao/Emissao"    ,2},;
             {"i_516a()/Cliente"      ,7},;
             {"i_516b()/Impresso"     ,0},;
             {"Num_fatura/Fatura"     ,11}},"P",;
             {NIL,"i_516c",NIL,NIL},;
              NIL,"<E>mitir Duplicata/Emitir<B>loqueto/<F>iltrar"))
return

//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAGEM DO CLIENTE ______________________________________________

function i_516a
   CLI1->(dbseek(FAT->Cod_cli))
return left(CLI1->Razao,30)

function i_516b
local cSIMNAO :=  space(3)
   if FAT->Imp
      cSIMNAO := "SIM"
   else
      cSIMNAO := "   "
   endif
return cSIMNAO


//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO _____________________________________

function i_516c

   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO == "E"
      if CONFIG->Modelo_fat == "1"
         zTMP_PRN := XCOD_PRN
         XCOD_PRN := "11"
         if ! qinitprn() ; return ; endif
         XCOD_PRN := zTMP_PRN

         i_imp_mantraco()
         XCOD_PRN := zTMP_PRN




      elseif CONFIG->Modelo_fat == "B"
         if ! qinitprn() ; return ; endif
         i_imp3_dup()
      elseif CONFIG->Modelo_2 == "7"
         if ! qinitprn() ; return ; endif
         i_imp4_dup()
      elseif CONFIG->Modelo_2 == "1"
         if ! qinitprn() ; return ; endif
         i_imp1_dup()             //SIM Estearina
      elseif CONFIG->Modelo_2 $ "8*5"
         if ! qinitprn() ; return ; endif
         i_imp5_dup()             //JVM
      else
         if ! qinitprn() ; return ; endif
         i_imp_dup()
      endif
        if FAT->(Qrlock())
           replace FAT->Imp with  .T.
        endif

   endif

   if cOPCAO == "B"
      if CONFIG->Modelo_fat =="4"
          qlbloc(13,3,"B516A","QBLOC.GLO",1)
          i_edicao()
          if ! qinitprn() ; return ; endif
          i_imp2_blo()
          qstopprn(.F.)
      elseif CONFIG->Modelo_fat =="1"  //BANCO DO BRASIL- CHAMATA
          qlbloc(13,3,"B516A","QBLOC.GLO",1)
          i_edicao()
          if ! qinitprn() ; return ; endif
          i_imp4_blo()
          qstopprn(.F.)

      elseif CONFIG->Modelo_fat =="3" //BANCO BRADESCO - CHAMATA
          qlbloc(13,3,"B516A","QBLOC.GLO",1)
          i_edicao()
          if ! qinitprn() ; return ; endif
          i_imp3_blo()
          qstopprn(.F.)

      elseif CONFIG->Modelo_fat =="8" //TOALHEIRO INDUSTRIAL CURITIBANO
          qlbloc(13,3,"B516A","QBLOC.GLO",1)
          i_edicao()
          if ! qinitprn() ; return ; endif
          i_imp8_blo()
          qstopprn(.F.)
      elseif CONFIG->Modelo_2 =="2" //REMOPLAST
          qlbloc(13,3,"B516A","QBLOC.GLO",1)
          i_edicao()
          if ! qinitprn() ; return ; endif
          i_impC2_blo()
          qstopprn(.F.)
      elseif CONFIG->Modelo_2 =="0" //ETIQUERAMA
          qlbloc(13,3,"B516A","QBLOC.GLO",1)
          i_edicao()
          if ! qinitprn() ; return ; endif
          i_etiquerama()
          qstopprn(.F.)
      elseif CONFIG->Modelo_2 =="C" //REZEN
          qlbloc(13,3,"B516A","QBLOC.GLO",1)
          i_edicao()
          if ! qinitprn() ; return ; endif
          i_Rezen()
          qstopprn(.F.)


      else
          qlbloc(13,3,"B516A","QBLOC.GLO",1)
          i_edicao()
          if ! qinitprn() ; return ; endif
          i_imp_blo()
          qstopprn(.F.)

      endif
   endif

   if cOPCAO == "F"
      i_filtro()
   endif


   setcursor(nCURSOR)

return ""

//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA _________________________________________

static function i_edicao


   local lCONF
   local aEDICAO := {}
   local bESCAPE := {||empty(cDOCTO).or.(XNIVEL==1.and.!XFLAG).or.;
                       (XNIVEL==1.and.lastkey()==27)}

   // CRIACAO DO VETOR DE BLOCOS _______________________________________________

   aadd(aEDICAO,{{ || qgetx(-1,0,@cDOCTO)}                 , "DOCTO" })
//   aadd(aEDICAO,{{ || qgetx(-1,0,@cVALOR,"@E 999,999.99")} , "VALOR" })
//   aadd(aEDICAO,{{ || qgetx(-1,0,@cJUROS,"@E 999,999.99")} , "JUROS" })
// if CONFIG->Modelo_fat=="1" .or. CONFIG->Modelo_fat=="3" .or. CONFIG->Modelo_2 == "2"
//   aadd(aEDICAO,{{ || qgetx(-1,0,@cCAMPO1, "@!"          )} , "CAMPO1" })
//   aadd(aEDICAO,{{ || qgetx(-1,0,@cCAMPO2, "@!"          )} , "CAMPO2" })
//   aadd(aEDICAO,{{ || qgetx(-1,0,@cCAMPO3, "@!"          )} , "CAMPO3" })
//
// endif
   aadd(aEDICAO,{{ || lCONF := qconf("Confirma Impress„o do Bloqueto ?") },NIL})

   XNIVEL := 1

   do while .T.

      cDOCTO   := space(10)
      cVALOR   := 0

      // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

      do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
         eval ( aEDICAO [XNIVEL,1] )
         if eval ( bESCAPE ) ; return ; endif
         if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
         iif ( XFLAG , XNIVEL++ , XNIVEL-- )
      enddo

      if ! lCONF ; return ; endif

      exit

   enddo

return

/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA _____________________________________________

static function i_critica ( cCAMPO )
   do case
      case cCAMPO == "DOCTO"
        if empty(cDOCTO) ; return .F. ; endif
   endcase
return .T.

/////////////////////////////////////////////////////////////////////////////
// IMPRESSAO DA DUPLICATA ___________________________________________________

static function i_imp_dup

   local cMACRO, cEXTENSO, nCONT, nLINHA , nCONTA
   local nVAL_UNI:= nTOT_PROD:= nICMS:= nVALOR:= nVAL:= nDESC := nICM_SUBS:= 0

   DUP_FAT->(Dbsetorder(1))
   DUP_FAT->(Dbgotop())

   nVEZ := 0

   if DUP_FAT->(Dbseek(FAT->Codigo+"01"))

      i_calc()

      do while ! DUP_FAT->(eof()) .and. left(DUP_FAT->Num_fat,5) == FAT->Codigo
         nVEZ++
         DUP_FAT->(Dbskip())
      enddo

      DUP_FAT->(Dbsetorder(1))
      DUP_FAT->(Dbgotop())
      DUP_FAT->(Dbseek(FAT->Codigo+"01"))

      cVALOR := cVALOR / nVEZ

      for nDUPL := 1 to nVEZ
          if cOPCAO == "E"
             qlbloc(13,17,"B516B","QBLOC.GLO",1)
             cVALOR := nVAL
             qgetx(14,42,@cVALOR,"999,999.99",NIL)
             cVALOR := cVALOR / nVEZ
          if ! qinitprn() ; return ; endif
             i_imp()
           //  qstopprn(.F.)
          else
             if ! qinitprn() ; return ; endif
             i_imp_blo()
          // qstopprn(.F.)
          endif
      next

      qstopprn(.F.)
     endif

return

/////////////////////////////////////////////////////////////////////////////
// IMPRESSAO DA DUPLICATA 7 (Modelo de Oficina dos Importados)_______________

static function i_imp4_dup

   local cMACRO, cEXTENSO, nCONT, nLINHA , nCONTA
   local nVAL_UNI:= nTOT_PROD:= nICMS:= nVALOR:= nVAL:= nDESC := nICM_SUBS:= 0

   DUP_FAT->(Dbsetorder(1))
   DUP_FAT->(Dbgotop())

   nVEZ := 0

   if DUP_FAT->(Dbseek(FAT->Codigo+"01"))

      i_calc()

      do while ! DUP_FAT->(eof()) .and. left(DUP_FAT->Num_fat,5) == FAT->Codigo

         CLI1->(dbseek(FAT->Cod_cli))

         @ prow()  ,00 say XCOND1

         @ prow()+11,21 say transform(nVAL, "@E 999,999,999.99")
         @ prow()   ,45 say FAT->Num_fatura

         @ prow()  ,62 say transform(DUP_FAT->Valor, "@E 999,999,999.99")
         @ prow()  ,82 say transform(FAT->Num_fatura,"@R 999999") + "/" + right(DUP_FAT->Num_fat,2)
         @ prow()  ,100 say ImpDataVenc()

         @ prow()+5,36 say left(CLI1->Razao,55)
         @ prow()+1,36 say CLI1->End_cob
         CGM->(Dbseek(CLI1->Cgm_cob))
         @ prow()+1,36 say CGM->Municipio + space(47) + CLI1->Cep_cob + space(13)+ CGM->Estado
         @ prow()+1,36 say CGM->Municipio

         @ prow()+2,36 say fu_conv_cgccpf(CLI1->Cgccpf)
         @ prow()  ,112 say CLI1->Inscricao

         cEXTENSO := qextenso(DUP_FAT->Valor)

         @ prow()+3,37 say left(cEXTENSO,90)
         @ prow()+1,37 say substr(cEXTENSO,91,90)


         for nCONT := 1 to 11 // pula ate a proxima fatura
           @ prow()+1,00 say ""
         next

         DUP_FAT->(Dbskip())
      enddo


      qstopprn(.F.)
     endif

return

/////////////////////////////////////////////////////////////////////////////
// IMPRESSAO DA DUPLICATA 1 (Modelo de Sim Estearina)_______________

static function i_imp1_dup

   local cMACRO, cEXTENSO, nCONT, nLINHA , nCONTA
   local nVAL_UNI:= nTOT_PROD:= nICMS:= nVALOR:= nVAL:= nDESC := nICM_SUBS:= 0

   DUP_FAT->(Dbsetorder(1))
   DUP_FAT->(Dbgotop())

   nVEZ := 0

   if DUP_FAT->(Dbseek(FAT->Codigo+"01"))

      i_calc()

      do while ! DUP_FAT->(eof()) .and. left(DUP_FAT->Num_fat,5) == FAT->Codigo

         CLI1->(dbseek(FAT->Cod_cli))

         @ prow()  ,00 say XCOND1

         @ prow()+2,92 say dtoc(FAT->Dt_emissao)
         @ prow()+4,10 say transform(DUP_FAT->Valor, "@E 999,999,999.99")
         @ prow()  ,35 say FAT->Num_fatura

         @ prow()  ,55 say transform(DUP_FAT->Valor, "@E 999,999,999.99")
         @ prow()  ,79 say transform(FAT->Num_fatura,"@R 999999") + "/" + right(DUP_FAT->Num_fat,2)
         @ prow()  ,100 say ImpDataVenc()

         @ prow()+8,46 say left(CLI1->Razao,55)
         @ prow()+2,46 say CLI1->End_cob +CLI1->Bairro_cob + space(7)+ CLI1->Cep_cob
         CGM->(Dbseek(CLI1->Cgm_cob))
         @ prow()+1,46 say CGM->Municipio + space(47) + CGM->Estado
         @ prow()+1,46 say CGM->Municipio

         @ prow()+1,46 say fu_conv_cgccpf(CLI1->Cgccpf)
         @ prow()  ,112 say CLI1->Inscricao

         cEXTENSO := qextenso(DUP_FAT->Valor)

         @ prow()+3,46 say left(cEXTENSO,90)
         @ prow()+1,46 say substr(cEXTENSO,91,90)


         for nCONT := 1 to 13 // pula ate a proxima fatura
           @ prow()+1,00 say ""
         next

         DUP_FAT->(Dbskip())
      enddo


      qstopprn(.F.)
     endif

return
/////////////////////////////////////////////////////////////////////
// Modelo da Mantraco_______________________________________________

static function i_imp_mantraco

   local cMACRO, cEXTENSO, nCONT, nLINHA , nCONTA, cLETRA
   local nVAL_UNI:= nTOT_PROD:= nICMS:= nVALOR:= nVAL:= nDESC := nICM_SUBS:= 0

   DUP_FAT->(Dbsetorder(1))
   DUP_FAT->(Dbgotop())
   nVEZ := 0
   cLETRA := Space(1)
   if DUP_FAT->(Dbseek(FAT->Codigo+"01"))

      do while ! DUP_FAT->(eof()) .and. left(DUP_FAT->Num_fat,5) == FAT->Codigo

         CLI1->(dbseek(FAT->Cod_cli))

         @ prow()  ,00 say XCOND1

         @ prow()+4,105 say strzero(day(FAT->Dt_emissao),2)
         @ prow()  ,111 say strzero(month(FAT->Dt_emissao),2)
         @ prow()  ,118 say right(dtoc(FAT->Dt_emissao),4)

         @ prow()+4,06 say FAT->Num_fatura

         do case
            case right(DUP_FAT->Num_fat,2) == "07"
                 cLETRA := "G"
            case right(DUP_FAT->Num_fat,2) == "06"
                 cLETRA := "F"
            case right(DUP_FAT->Num_fat,2) == "05"
                 cLETRA := "E"
            case right(DUP_FAT->Num_fat,2) == "04"
                 cLETRA := "D"
            case right(DUP_FAT->Num_fat,2) == "03"
                 cLETRA := "C"
            case right(DUP_FAT->Num_fat,2) == "02"
                 cLETRA := "B"
            case right(DUP_FAT->Num_fat,2) == "01"
                 cLETRA := "A"
         endcase

         @ prow()  ,36 say transform(DUP_FAT->Valor, "@E 999,999,999.99")
         if left(FAT->Num_fatura,3) == "   "
            @ prow()  ,62 say transform(FAT->Num_fatura,"@R 999999") + "/" + cLETRA
         else
            @ prow()  ,62 say transform(FAT->Num_fatura,"@R 999999") + "/" + right(DUP_FAT->Num_fat,2)
         endif
         @ prow()  ,87 say ImpDataVenc()

         @ prow()+3,38 say qabrev(FAT->Boleto,"123456789", {"Boleto","Pgto a Vista - Boleto","Pgto a Vista - Deposito","Antecipado","","Plano Mkt","Abater Credito","Segurar Duplicata","A Prazo - Deposito"})
         @ prow()+3,38 say left(CLI1->Razao,55)
         @ prow()+1,38 say CLI1->End_cob +CLI1->Bairro_cob
         CGM->(Dbseek(CLI1->Cgm_cob))
         @ prow()+1,38 say CGM->Municipio + space(30) + CGM->Estado+space(19)+CLI1->Cep_cob
         @ prow()+1,38 say CGM->Municipio

         @ prow()+2,38 say fu_conv_cgccpf(CLI1->Cgccpf)
         @ prow()  ,112 say CLI1->Inscricao

         cEXTENSO := qextenso(DUP_FAT->Valor)

         @ prow()+3,38 say left(cEXTENSO,90)
         @ prow()+1,38 say substr(cEXTENSO,91,90)


         for nCONT := 1 to 13 // pula ate a proxima fatura
           @ prow()+1,00 say ""
         next

         DUP_FAT->(Dbskip())
      enddo


      qstopprn(.F.)
     endif

return


static function i_imp5_dup

   local cMACRO, nCONT, nLINHA , nCONTA
   local nVAL_UNI:= nTOT_PROD:= nICMS:= nVALOR:= nVAL:= nDESC := nICM_SUBS:= 0
   local cEXTENSO := ""

   DUP_FAT->(Dbsetorder(1))
   DUP_FAT->(Dbgotop())

   nVEZ := 0
   FILIAL->(dbseek(FAT->Filial))
   if DUP_FAT->(Dbseek(FAT->Codigo+"01"))

      i_calc()

      do while ! DUP_FAT->(eof()) .and. left(DUP_FAT->Num_fat,5) == FAT->Codigo

         CLI1->(dbseek(FAT->Cod_cli))

         @ prow()  ,00 say XCOND1
         @ prow()+1,20 say FILIAL->Razao
         @ prow()+1,20 say rtrim(FILIAL->Endereco)+ ", " + str(FILIAL->Numero) + " " + FILIAL->Compl
         @ prow()+1,20 say FILIAL->Bairro
         @ prow()+1,20 say FILIAL->Telefone
         @ prow()+1,20 say FILIAL->Cep


         @ prow()+1,92 say dtoc(FAT->Dt_emissao)
         @ prow()+2,10 say transform(DUP_FAT->Valor, "@E 999,999,999.99")
         @ prow()  ,35 say FAT->Num_fatura

         @ prow()  ,55 say transform(DUP_FAT->Valor, "@E 999,999,999.99")
         @ prow()  ,79 say transform(FAT->Num_fatura,"@R 999999") + "/" + right(DUP_FAT->Num_fat,2)
         @ prow()  ,100 say ImpDataVenc()

         @ prow()+2,20 say left(CLI1->Razao,55)
         @ prow()+1,20 say CLI1->End_cob +CLI1->Bairro_cob + space(7)+ CLI1->Cep_cob
         CGM->(Dbseek(CLI1->Cgm_cob))
         @ prow()+1,20 say CGM->Municipio + space(47) + CGM->Estado
         @ prow()+1,20 say fu_conv_cgccpf(CLI1->Cgccpf)
         @ prow()  ,92 say CLI1->Inscricao

         cEXTENSO := qextenso(DUP_FAT->Valor)

         @ prow()+3,20 say cEXTENSO
         @ prow()+1,20 say substr(cEXTENSO,55,75)


         for nCONT := 1 to 13 // pula ate a proxima fatura
           @ prow()+1,00 say ""
         next

         DUP_FAT->(Dbskip())
      enddo


      qstopprn(.F.)
     endif

return

/////////////////////////////////////////////////////////////////////////////
// IMPRESSAO DA DUPLICATA B (Modelo de Richetti e Gobbo)_____________________

static function i_imp3_dup

   local cMACRO, cEXTENSO, nCONT, nLINHA , nCONTA
   local nVAL_UNI:= nTOT_PROD:= nICMS:= nVALOR:= nVAL:= nDESC := nICM_SUBS:= 0

   DUP_FAT->(Dbsetorder(1))
   DUP_FAT->(Dbgotop())

   nVEZ := 0

   if DUP_FAT->(Dbseek(FAT->Codigo+"01"))

      i_calc()

      do while ! DUP_FAT->(eof()) .and. left(DUP_FAT->Num_fat,5) == FAT->Codigo

         CLI1->(dbseek(FAT->Cod_cli))

         @ prow()  ,00 say XCOND1

         @ prow()+6,43 say dtoc(FAT->Dt_emissao)

         @ prow()+4,03 say transform(nVAL, "@E 999,999,999.99")
         @ prow()  ,33 say FAT->Num_fatura

         @ prow()  ,48 say transform(DUP_FAT->Valor, "@E 999,999,999.99")
         @ prow()  ,73 say transform(FAT->Num_fatura,"@R 999999") + "/" + right(DUP_FAT->Num_fat,2)
         @ prow()  ,88 say ImpDataVenc()

         @ prow()+5,33 say left(CLI1->Razao,55)
         @ prow()+1,33 say CLI1->End_cob
         CGM->(Dbseek(CLI1->Cgm_cob))
         @ prow()+1,33 say CGM->Municipio + space(40) + CGM->Estado
         @ prow()+1,33 say CGM->Municipio
         @ prow()  ,120 say CLI1->Cep_cob

         @ prow()+1,33 say fu_conv_cgccpf(CLI1->Cgccpf)
         @ prow()  ,112 say CLI1->Inscricao

         cEXTENSO := qextenso(DUP_FAT->Valor)

         @ prow()+3,31 say cEXTENSO


         for nCONT := 1 to 11 // pula ate a proxima fatura
           @ prow()+1,00 say ""
         next

         DUP_FAT->(Dbskip())
      enddo


      qstopprn(.F.)
     endif

return

//////////////////////////////////////////////////////////////////////////////
// IMPRESSAO DE DUPLICATA - (MODELO A) ///// RN COMERCIAL LTDA)________________
static function i_imp_dup2

   local cMACRO, cEXTENSO, nCONT, nLINHA , nCONTA
   local nVAL_UNI:= nTOT_PROD:= nICMS:= nVALOR:= nVAL:= nDESC := nICM_SUBS:= 0

   DUP_FAT->(Dbsetorder(1))
   DUP_FAT->(Dbgotop())

   nVEZ := 0

   if DUP_FAT->(Dbseek(FAT->Codigo+"01"))

      i_calc()

      do while ! DUP_FAT->(eof()) .and. left(DUP_FAT->Num_fat,5) == FAT->Codigo
         nVEZ++
         DUP_FAT->(Dbskip())
      enddo

      DUP_FAT->(Dbsetorder(1))
      DUP_FAT->(Dbgotop())
      DUP_FAT->(Dbseek(FAT->Codigo+"01"))

      cVALOR := cVALOR / nVEZ

      for nDUPL := 1 to nVEZ
          if cOPCAO == "E"
             qlbloc(13,17,"B516B","QBLOC.GLO",1)
             cVALOR := nVAL
             qgetx(14,42,@cVALOR,"999,999.99",NIL)
             cVALOR := cVALOR / nVEZ
          if ! qinitprn() ; return ; endif
             i_imp()
           //  qstopprn(.F.)
          else
             if ! qinitprn() ; return ; endif
             i_imp_blo()
          // qstopprn(.F.)
          endif
      next

      qstopprn(.F.)
     endif

return

///////////////////////////////////////////////////////////////////////////////
function i_imp()

   nCONTA := 1

   qmensa("Emitindo Duplicata: " + transform(FAT->Num_fatura,"@R 999999") + "-" + str(nCONTA,1))

   CLI1->(dbseek(FAT->Cod_cli))

   @ prow()  ,00 say XCOND0

   @ prow()+5,60 say dtoc(FAT->Dt_emissao)
   @ prow()+3,03 say FAT->Num_fatura

   @ prow()  ,16 say transform(cVALOR, "@E 999,999,999.99")
   @ prow()  ,40 say transform(FAT->Num_fatura,"@R 999999") + "-" + str(nCONTA,1)
   @ prow()  ,58 say ImpDataVenc()

   @ prow()+2,13 say XCOND1 + " " + XCOND0
   @ prow()  ,65 say " "

   @ prow()+4,27 say left(CLI1->Razao,55)
   @ prow()+2,27 say CLI1->End_cob
   CGM->(Dbseek(CLI1->Cgm_cob))
   @ prow()+2,27 say CGM->Municipio + space(12) + CGM->Estado
   @ prow()+2,00 say ""
   @ prow()+2,27 say fu_conv_cgccpf(CLI1->Cgccpf)
   @ prow()  ,62 say CLI1->Inscricao

   cEXTENSO := pad(alltrim(qextenso(cVALOR)) + " ",55,"*")

   @ prow()+2,28 say cEXTENSO

   nCONTA++

   DUP_FAT->(Dbskip())

   for nCONT := 1 to 12  // pula ate a proxima fatura
     @ prow()+1,00 say ""
   next

return

/////////////////////////////////////////////////////////////////////////////
// IMPRESSAO DE BLOQUETO BANCARIO ___________________________________________

static function i_imp_blo

    nCONTA := 1
    nVALOR := 0
    qmensa("Emitindo Bloqueto: " + transform(FAT->Num_fatura,"@R 999999") + "-" + str(nCONTA,1))

    CLI1->(dbseek(FAT->Cod_cli))

    @ prow()  ,00 say XCOND1

  //  @ prow()  ,05 say "Pagavel em qualquer agencia bancaria ate o vencimento"
    @ prow()  ,00 say XCOND0

    DUP_FAT->(dbsetorder(2))
    DUP_FAT->(dbgotop())
    DUP_FAT->(dbseek(FAT->Codigo))

    @ prow()  ,53 say ImpDataVenc()
    @ prow()  ,00 say XCOND1
    @ prow()+3,05 say dtoc(FAT->Dt_emissao)
    @ prow()  ,17 say cDOCTO

   ITEN_FAT->(dbseek(FAT->Codigo))
   do while ITEN_FAT->Num_Fat == FAT->Codigo

      nVALOR += ITEN_FAT->Quantidade * ITEN_FAT->Vl_unitar

      ITEN_FAT->(Dbskip())

   enddo
    @ prow()  ,00 say XCOND0
    @ prow()+1,55 say transform(nVALOR, "@E 999,999.99")
    @ prow()  ,00 say XCOND1

    nMORA := ( cVALOR * 0.004 )
    nVALOR := 0
    @ prow()+3,05 say "Juros ao dia R$ " + transform(cJUROS, "@E 99.99")
    @ prow()+1,05 say "A ficha autenticada quita documento original"
    @ prow()+2,05 say "Ref. a NF " + FAT->Num_fatura + XCOND0

//  @ prow()+3,55 say transform(cVALOR, "@E 999,999.99")

    @ prow()+4,05 say left(CLI1->Razao,55)
    @ prow()+1,05 say CLI1->End_cob
    CGM->(Dbseek(CLI1->Cgm_cob))
    @ prow()+1,05 say left(CGM->Municipio,15) + space(1) + CGM->Estado + " " + transform(CLI1->Cep_cob, "@R 99999-999") + "    " + fu_conv_cgccpf(CLI1->Cgccpf)
    @ prow()  ,00 say XCOND0

    nCONTA++

    DUP_FAT->(Dbskip())

    for nCONT := 1 to 7  // pula ate a proxima fatura
      @ prow()+1,00 say ""
    next

return .T.

/////////////////////////////////////////////////////////////////////////////
// IMPRESSAO DE BLOQUETO BANCARIO ___________________________________________
// TOALHEIRO
static function i_imp8_blo
    nCONTA := 1
    nVALOR := 0
    qmensa("Emitindo Bloqueto: " + transform(FAT->Num_fatura,"@R 999999") + "-" + str(nCONTA,1))

    CLI1->(dbseek(FAT->Cod_cli))

    @ prow()  ,00 say XCOND1

    @ prow()  ,00 say XCOND0

    DUP_FAT->(dbsetorder(2))
    DUP_FAT->(dbgotop())
    DUP_FAT->(dbseek(FAT->Codigo))

    @ prow()+1,65 say XCOND1 + ImpDataVenc()
    @ prow()+2,08 say dtoc(FAT->Dt_emissao)
    @ prow()  ,29 say cDOCTO
    @ prow()  ,53 say "NF"

   ITEN_FAT->(dbseek(FAT->Codigo))
   do while ITEN_FAT->Num_Fat == FAT->Codigo

      nVALOR += ITEN_FAT->Quantidade * ITEN_FAT->Vl_unitar

      ITEN_FAT->(Dbskip())

   enddo
    @ prow()+1,105 say transform(nVALOR, "@E 999,999.99")

    nMORA := ( cVALOR * 0.004 )
    @ prow()+2,08 say "Juros ao dia R$ " + transform(cJUROS, "@E 99.99")
    @ prow()+1,08 say "Ate o vencimento pagavel em qualquer Banco"
    @ prow()+1,08 say "Sujeito a Protesto apos 02 dias"

    @ prow()+5,08 say CLI1->Codigo
    @ prow()  ,15 say left(CLI1->Razao,55)
    @ prow()+1,15 say CLI1->End_cob
    CGM->(Dbseek(CLI1->Cgm_cob))
    @ prow()+1,15 say left(CGM->Municipio,15) + space(1) + CGM->Estado + " " + transform(CLI1->Cep_cob, "@R 99999-999") + "    " + fu_conv_cgccpf(CLI1->Cgccpf)
    nCONTA ++
    @ prow()  ,00 say XCOND0
    @ prow()  ,00 say XCOND1


//// PARTE 2
    @ prow()+8,00 say ""
    @ prow()+1,100 say ImpDataVenc()
    @ prow()+1,08 say dtoc(FAT->Dt_emissao)
    @ prow()  ,29 say cDOCTO
    @ prow()  ,53 say "NF"
    @ prow()+1,105 say transform(nVALOR, "@E 999,999.99")

    @ prow()+2,08 say "Juros ao dia R$ " + transform(cJUROS, "@E 99.99")
    @ prow()+1,08 say "Ate o vencimento pagavel em qualquer Banco"
    @ prow()+1,08 say "Sujeito a Protesto apos 02 dias"

    @ prow()+5,08 say CLI1->Codigo
    @ prow()  ,15 say left(CLI1->Razao,55)
    @ prow()+1,15 say CLI1->End_cob
    CGM->(Dbseek(CLI1->Cgm_cob))
    @ prow()+1,15 say left(CGM->Municipio,15) + space(1) + CGM->Estado + " " + transform(CLI1->Cep_cob, "@R 99999-999") + "    " + fu_conv_cgccpf(CLI1->Cgccpf)
    @ prow()  ,00 say XCOND0
    @ prow()  ,00 say XCOND1


///// PARTE 3
    @ prow()+8,00 say ""
    @ prow()+1,100 say ImpDataVenc()
    @ prow()+3,08 say dtoc(FAT->Dt_emissao)
    @ prow()  ,29 say cDOCTO
    @ prow()  ,53 say "NF"
    @ prow()+1,105 say transform(nVALOR, "@E 999,999.99")

    @ prow()+2,08 say "Juros ao dia R$ " + transform(cJUROS, "@E 99.99")
    @ prow()+1,08 say "Ate o vencimento pagavel em qualquer Banco"
    @ prow()+1,08 say "Sujeito a Protesto apos 02 dias"

    @ prow()+4,01 say CLI1->Codigo
    @ prow()  ,08 say CLI1->Razao + fu_conv_cgccpf(CLI1->Cgccpf)
    @ prow()+1,08 say CLI1->End_cob +left(CGM->Municipio,15)+" " + CGM->Estado + " " + transform(CLI1->Cep_cob, "@R 99999-999")


return .T.

/////////////////////////////////////////////////////////////////////////////
// IMPRESSAO DE BLOQUETO BANCARIO ___________________________________________

static function i_imp2_blo

    nCONTA := 1
    nVALOR := 0
    qmensa("Emitindo Bloqueto: " + transform(FAT->Num_fatura,"@R 999999") + "-" + str(nCONTA,1))

    CLI1->(dbseek(FAT->Cod_cli))

    @ prow()  ,00 say XCOND1
    @ prow()+2,00 say ""

    @ prow()  ,05 say "Pagavel em qualquer agencia bancaria ate o vencimento"
    @ prow()  ,00 say XCOND0

    DUP_FAT->(dbsetorder(2))
    DUP_FAT->(dbgotop())
    DUP_FAT->(dbseek(FAT->Codigo))

    @ prow()  ,53 say ImpDataVenc()
    @ prow()  ,00 say XCOND1
    @ prow()+3,05 say dtoc(FAT->Dt_emissao)
    @ prow()  ,15 say cDOCTO

   ITEN_FAT->(dbseek(FAT->Codigo))
   do while ITEN_FAT->Num_Fat == FAT->Codigo

      nVALOR += ITEN_FAT->Quantidade * ITEN_FAT->Vl_unitar

      ITEN_FAT->(Dbskip())

   enddo
    @ prow()  ,00 say XCOND0
    @ prow()+1,55 say transform(nVALOR, "@E 999,999.99")
    @ prow()  ,00 say XCOND1

    nMORA := ( cVALOR * 0.004 )
    nVALOR := 0
    @ prow()+3,05 say "Juros ao dia R$ " + transform(cJUROS, "@E 99.99")
    @ prow()+1,05 say "A ficha autenticada quita documento original"
    @ prow()+2,05 say "Ref. a NF " + FAT->Num_fatura + XCOND0

//  @ prow()+3,55 say transform(cVALOR, "@E 999,999.99")

    @ prow()+3,05 say left(CLI1->Razao,55)
    @ prow()+1,05 say CLI1->End_cob
    CGM->(Dbseek(CLI1->Cgm_cob))
    @ prow()+1,05 say left(CGM->Municipio,15) + space(1) + CGM->Estado + " " + transform(CLI1->Cep_cob, "@R 99999-999") + "    " + fu_conv_cgccpf(CLI1->Cgccpf)
    @ prow()  ,00 say XCOND0

    nCONTA++

    DUP_FAT->(Dbskip())

    for nCONT := 1 to 9  // pula ate a proxima fatura
      @ prow()+1,00 say ""
    next

return .T.
///////////////////////////////////////////////////////
// IMPRESSAO DE BLOQUETO BANCARIO______________________
static function i_imp3_blo

    nCONTA := 1
    nVALOR := 0
    qmensa("Emitindo Bloqueto: " + transform(FAT->Num_fatura,"@R 999999") + "-" + str(nCONTA,1))

    CLI1->(dbseek(FAT->Cod_cli))

    @ prow()  ,00 say XCOND1

   // @ prow()  ,05 say "Pagavel em qualquer agencia bancaria ate o vencimento"
    @ prow()+1  ,00 say XCOND0

    DUP_FAT->(dbsetorder(2))
    DUP_FAT->(dbgotop())
    DUP_FAT->(dbseek(FAT->Codigo))

    @ prow()  ,53 say ImpDataVenc()
    @ prow()  ,00 say XCOND1
    @ prow()+3,02 say dtoc(FAT->Dt_emissao)
    @ prow()  ,25 say cDOCTO

   ITEN_FAT->(dbseek(FAT->Codigo))
   do while ITEN_FAT->Num_Fat == FAT->Codigo

      nVALOR += ITEN_FAT->Quantidade * ITEN_FAT->Vl_unitar

      ITEN_FAT->(Dbskip())

   enddo
    @ prow()  ,00 say XCOND0
    @ prow()+2,50 say transform(nVALOR, "@E 999,999.99")
    @ prow()  ,00 say XCOND1

    nMORA := ( cVALOR * 0.004 )
    nVALOR := 0
    @ prow()+4,05 say cCAMPO1
    @ prow()+1,05 say cCAMPO2
    @ prow()+1,05 say cCAMPO3

//  @ prow()+3,55 say transform(cVALOR, "@E 999,999.99")

    @ prow()+3,05 say left(CLI1->Razao,55)
    @ prow()+1,05 say CLI1->End_cob
    CGM->(Dbseek(CLI1->Cgm_cob))
    @ prow()+1,05 say left(CGM->Municipio,15) + space(1) + CGM->Estado + " " + transform(CLI1->Cep_cob, "@R 99999-999") + "    " + fu_conv_cgccpf(CLI1->Cgccpf)
    @ prow()  ,00 say XCOND0

    nCONTA++

    DUP_FAT->(Dbskip())

    for nCONT := 1 to 7  // pula ate a proxima fatura
      @ prow()+1,00 say ""
    next

return .T.

/////////////////////////////////////////////////////////////////////////////
// IMPRESSAO DE BLOQUETO BANCARIO ___________________________________________

static function i_imp4_blo

    nCONTA := 1
    nVALOR := 0
    qmensa("Emitindo Bloqueto: " + transform(FAT->Num_fatura,"@R 999999") + "-" + str(nCONTA,1))

    CLI1->(dbseek(FAT->Cod_cli))

    @ prow()  ,00 say XCOND1

//    @ prow()+1  ,05 say "Pagavel em qualquer agencia bancaria ate o vencimento"
    @ prow()  ,00 say XCOND0

    DUP_FAT->(dbsetorder(2))
    DUP_FAT->(dbgotop())
    DUP_FAT->(dbseek(FAT->Codigo))

    @ prow()  ,53 say ImpDataVenc()
    @ prow()  ,00 say XCOND1
    @ prow()+2,00 say dtoc(FAT->Dt_emissao)
    @ prow()  ,30 say cDOCTO
    @ prow()  ,49 say "NF"
    @ prow()  ,61 say "S"
    @ prow()  ,69 say dtoc(date())
    @ prow()+1,34 say "R$"

   ITEN_FAT->(dbseek(FAT->Codigo))
   do while ITEN_FAT->Num_Fat == FAT->Codigo

      nVALOR += ITEN_FAT->Quantidade * ITEN_FAT->Vl_unitar

      ITEN_FAT->(Dbskip())

   enddo
    @ prow()  ,00 say XCOND0
    @ prow()  ,58 say transform(nVALOR, "@E 999,999.99")
    @ prow()  ,00 say XCOND1

   //nMORA := ( cVALOR * 0.004 )
    nVALOR := 0

    @ prow()+2,05 say "Apos o Vencimento Juros de 5% ao mes"
    @ prow()+1,05 say "Protestar apos o 10. Dia util apos o vencimento"
    @ prow()+1,05 say cCAMPO1
    @ prow()+1,05 say cCAMPO2
    @ prow()+1,05 say cCAMPO3

//  @ prow()+3,55 say transform(cVALOR, "@E 999,999.99")

    @ prow()+3,05 say left(CLI1->Razao,55)
    @ prow()+1,05 say CLI1->End_cob
    CGM->(Dbseek(CLI1->Cgm_cob))
    @ prow()+1,05 say left(CGM->Municipio,15) + space(1) + CGM->Estado + " " + transform(CLI1->Cep_cob, "@R 99999-999") + "    " + fu_conv_cgccpf(CLI1->Cgccpf)
    @ prow()  ,00 say XCOND0

    nCONTA++

    DUP_FAT->(Dbskip())

    for nCONT := 1 to 8  // pula ate a proxima fatura
      @ prow()+1,00 say ""
    next

return .T.

/////////////////////////////////////////////////////////////////////////////
// IMPRESSAO DE BLOQUETO BANCARIO (Remoplast)________________________________

static function i_impC2_blo

    nCONTA := 1
    nVALOR := 0
    nBLOQ  := 0
    qmensa("Emitindo Bloqueto: " + transform(FAT->Num_fatura,"@R 999999") + "-" + str(nCONTA,1))

    CLI1->(dbseek(FAT->Cod_cli))
    if FAT->Imp == .F.
       if FAT->(qrlock())
          replace FAT->Bloqueto with strzero(CONFIG->N_BLOQ+1,14)
          FAT->(qunlock())
       endif
    endif

    nBLOQ := -1
    @ prow()  ,00 say XCOND1

 //   @ prow()+1  ,05 say "Pagavel em qualquer agencia bancaria ate o vencimento"
    @ prow()  ,00 say XCOND0

    DUP_FAT->(dbsetorder(2))
    DUP_FAT->(dbgotop())
    if DUP_FAT->(dbseek(FAT->Codigo+"01"))
       do while ! DUP_FAT->(eof()) .and. left(DUP_FAT->Num_fat,5) == FAT->Codigo

          @ prow()+1,53 say ImpDataVenc()
          @ prow()  ,00 say XCOND1
          @ prow()+3,00 say dtoc(FAT->Dt_emissao)
          @ prow()  ,30 say FAT->Num_fatura+"/"+right(DUP_FAT->Num_fat,2)
          @ prow()  ,49 say "NF"
          @ prow()  ,61 say "S"
          @ prow()  ,69 say dtoc(date())

          @ prow()+1,94 say transform(DUP_FAT->Valor, "@E 999,999.99")

          @ prow()+2,05 say "Apos o vencimento cobrar multa de 2%"
          @ prow()+1,05 say "Apos 5 dias do vencimento Protestar"
          @ prow()+1,05 say "Apos o vencimento cobrar Mora Diaria de R$ " + transf( (DUP_FAT->Valor*0.10) / 30,"@E 999,999.99") + " ao dia"

          @ prow()+5,05 say left(CLI1->Razao,55)
          @ prow()+1,05 say CLI1->End_cob + "No. do Bloqueto.: " + FAT->Bloqueto
          CGM->(Dbseek(CLI1->Cgm_cob))
          @ prow()+1,05 say left(CGM->Municipio,15) + space(1) + CGM->Estado + " " + transform(CLI1->Cep_cob, "@R 99999-999") + "    " + fu_conv_cgccpf(CLI1->Cgccpf)
          @ prow()  ,00 say XCOND0

          nCONTA++
          nBLOQ++
          DUP_FAT->(Dbskip())

          for nCONT := 1 to 8  // pula ate a proxima fatura
            @ prow()+1,00 say ""
          next
       enddo

       if FAT->Imp == .F.
           CONFIG->(qrlock())
           replace CONFIG->N_bloq with val(FAT->Bloqueto)+nBLOQ
           CONFIG->(qunlock())
           FAT->(qrlock())
           replace FAT->Imp with .T.
           FAT->(qunlock())
       endif

    endif

return .T.

////////////////////////////////////////////////////////////////////////////
function i_calc

      ITEN_FAT->(Dbgotop())
      ITEN_FAT->(dbseek(FAT->Codigo))

      nTOT_SUBS := 0

      do while ITEN_FAT->Num_Fat == FAT->Codigo

         PROD->(dbsetorder(4))

         PROD->(dbseek(ITEN_FAT->Cod_Prod))

         if ! empty(PROD->Desconto) .and. ITEN_FAT->Calc_desc == "S"
            nDESC := (PROD->Desconto/100)
         else
            nDESC := 1
         endif

         nVAL_UNI := (ITEN_FAT->Vl_unitar) * nDESC

         nTOT_PROD := nTOT_PROD + (ITEN_FAT->Quantidade * round(nVAL_UNI,2))

         if ITEN_FAT->Icms_subst == "S"

            nTOT_SUBS := nTOT_SUBS + (ITEN_FAT->Quantidade * round(nVAL_UNI,2))

         else

           nICMS := nICMS + ( ( ITEN_FAT->Quantidade * round(nVAL_UNI,2)) * (ITEN_FAT->Icms   / 100) )

         endif

         nALIQ_ICMS := ITEN_FAT->Icms

         ITEN_FAT->(Dbskip())

         nVAL_UNI := 0

      enddo

      CLI1->(dbseek(FAT->Cod_cli)) // procura a aliquota do lucro no cliente da nota
      CGM->(dbseek(CLI1->Cgm_cob))
      LUCRO->(dbseek(CGM->Estado))

      if ! empty(FAT->Aliq_desc)
         if CONFIG->Modelo_2 == "2"
            nDES := nTOT_PROD - FAT->Aliq_desc
         else
            nDES := (nTOT_PROD * FAT->Aliq_desc) / 100
         endif
      else
         nDES := 0
      endif

      nICM_SUBS := ( nTOT_SUBS * LUCRO->Margem * (nALIQ_ICMS/100) ) - (nTOT_SUBS * (nALIQ_ICMS/100) )

      nVAL := nTOT_PROD - nDES + nICM_SUBS  // valor total da fatura

return

static function i_etiquerama
    nCONTA := 1
    nVALOR := 0
    qmensa("Emitindo Bloqueto: " + transform(FAT->Num_fatura,"@R 999999") + "-" + str(nCONTA,1))

    CLI1->(dbseek(FAT->Cod_cli))
    LAY_BOL->(Dbsetorder(1))
    LAY_BOL->(Dbseek("01"))
    @ prow(),0 say XCOND1 + CHR(27)+"0"
    DUP_FAT->(dbsetorder(2))
    DUP_FAT->(dbgotop())
    if DUP_FAT->(dbseek(FAT->Codigo+"01"))
       do while ! DUP_FAT->(eof()) .and. left(DUP_FAT->Num_fat,5) == FAT->Codigo

          @ prow()+LAY_BOL->Ag_lin,LAY_BOL->Ag_col say "Pagavel em qualquer agencia ate o vencimento"
          @ prow()  ,LAY_BOL->Venc_col say ImpDataVenc()
          @ prow()+LAY_BOL->Emi_lin,LAY_BOL->Emi_col say dtoc(FAT->Dt_emissao)
          @ prow()  ,LAY_BOL->Num_fat say FAT->Num_fatura + "/"+right(DUP_FAT->Num_fat,2)
          @ prow()  ,LAY_BOL->Dm_col say "DM"
          @ prow()  ,LAY_BOL->N_col say "N"
          @ prow()  ,LAY_BOL->Data_proc say dtoc(date())

          @ prow()+LAY_BOL->Val_lin,LAY_BOL->Val_col say transform(DUP_FAT->Valor, "@E 999,999.99")
          @ prow()+LAY_BOL->Desc1_lin,LAY_BOL->Desc1 say "      0,00"
          @ prow()  ,LAY_BOL->Desc2 say "0,00"
          @ prow()  ,LAY_BOL->Desc3 say "0,75"

          @ prow()+LAY_BOL->Linha1_lin,LAY_BOL->Linha1_col say "Nao dispensar encargos moratorios"
          @ prow()+1,LAY_BOL->Linha2_col say "Protestar 5 dias apos o vencimento"

          @ prow()+LAY_BOL->Cli_lin,LAY_BOL->Cli_col say CLI1->Codigo
          @ prow() ,LAY_BOL->Razao_col say left(CLI1->Razao,55) + " - " +FAT->Codigo
          @ prow()+1,LAY_BOL->Ender_col say CLI1->End_cob
          CGM->(Dbseek(CLI1->Cgm_cob))
          @ prow()+1,LAY_BOL->Munic_col say left(CGM->Municipio,15) + space(1) + CGM->Estado + " " + transform(CLI1->Cep_cob, "@R 99999-999") + "    " + fu_conv_cgccpf(CLI1->Cgccpf)
          @ prow()+LAY_BOL->Salto_col,00 say "" //pula p proxima
          @ prow() ,00 say XCOND1
          DUP_FAT->(dbskip())
      enddo

    endif
    @ prow(),00  say chr(27)+ "@"

return .T.

static function i_Rezen
    nCONTA := 1
    nVALOR := 0
    qmensa("Emitindo Bloqueto: " + transform(FAT->Num_fatura,"@R 999999") + "-" + str(nCONTA,1))

    CLI1->(dbseek(FAT->Cod_cli))
    LAY_BOL->(Dbsetorder(1))
    LAY_BOL->(Dbseek("02"))
    @ prow(),0 say XCOND1 + CHR(27)+"0"
    DUP_FAT->(dbsetorder(2))
    DUP_FAT->(dbgotop())
    if DUP_FAT->(dbseek(FAT->Codigo+"01"))
       do while ! DUP_FAT->(eof()) .and. left(DUP_FAT->Num_fat,5) == FAT->Codigo

          @ prow()+LAY_BOL->Ag_lin,LAY_BOL->Ag_col say "Pagavel em qualquer agencia ate o vencimento"
          @ prow()  ,LAY_BOL->Venc_col say ImpDataVenc()
          @ prow()+LAY_BOL->Emi_lin,LAY_BOL->Emi_col say dtoc(FAT->Dt_emissao)
          @ prow()  ,LAY_BOL->Num_fat say FAT->Num_fatura + "/"+right(DUP_FAT->Num_fat,2)
    //      @ prow()  ,LAY_BOL->Dm_col say "DM"
          @ prow()  ,LAY_BOL->N_col say "N"
          @ prow()  ,LAY_BOL->Data_proc say dtoc(date())

          @ prow()+LAY_BOL->Val_lin,LAY_BOL->Val_col say transform(DUP_FAT->Valor, "@E 999,999.99")
          @ prow()+LAY_BOL->Desc1_lin,LAY_BOL->Desc1 say "      0,00"
   //       @ prow()  ,LAY_BOL->Desc2 say "0,00"
   //       @ prow()  ,LAY_BOL->Desc3 say "0,75"

          @ prow()+LAY_BOL->Linha1_lin,LAY_BOL->Linha1_col say "Nao dispensar encargos moratorios"
          @ prow()+1,LAY_BOL->Linha2_col say "Protestar 5 dias apos o vencimento"

          @ prow()+LAY_BOL->Cli_lin,LAY_BOL->Cli_col say CLI1->Codigo
          @ prow() ,LAY_BOL->Razao_col say left(CLI1->Razao,55) + " - " +FAT->Codigo
          @ prow()+1,LAY_BOL->Ender_col say CLI1->End_cob
          CGM->(Dbseek(CLI1->Cgm_cob))
          @ prow()+1,LAY_BOL->Munic_col say left(CGM->Municipio,15) + space(1) + CGM->Estado + " " + transform(CLI1->Cep_cob, "@R 99999-999") + "    " + fu_conv_cgccpf(CLI1->Cgccpf)
          @ prow()+LAY_BOL->Salto_col,00 say "" //pula p proxima
          @ prow() ,00 say XCOND1
          DUP_FAT->(dbskip())
      enddo

    endif
    @ prow(),00  say chr(27)+ "@"

return .T.

static function i_filtro()
local cFIL := ""

   cFIL := FAT->(dbfilter())
   FAT->(DbClearFilter())
   if cFIL == "Todos" //Se esta todos
      FAT->(dbSetFilter({|| ! CANCELADO.and.!empty(FAT->Num_fatura) .and. !left(FAT->Cod_cfop,4)$ "5912-6912-5910-6910-5911-6911-5917-6917-5915-6915" .and. FAT->Vezes > 0 .and. !FAT->Imp},"Vazio"))
   else
      FAT->(dbSetFilter({|| ! CANCELADO.and.!empty(FAT->Num_fatura) .and. !left(FAT->Cod_cfop,4)$ "5912-6912-5910-6910-5911-6911-5917-6917-5915-6915" .and. FAT->Vezes > 0 },"Todos"))
   endif

return



