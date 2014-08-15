/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: ESCRITA FISCAL
// OBJETIVO...: CONSULTA DE NOTAS DE ENTRADA
// ANALISTA...:
// PROGRAMADOR: LUCINEIDE VILAR POSSEBOM
// INICIO.....: SETEMBRO DE 1998
// OBS........:
// ALTERACOES.:
function ef303

#include "inkey.ch"
#include "ef.ch"

private nVALOR := 0     // Variavel temporario para guardar outras aliquotas
private cCOD_FORN       // Codigo do fornecedor temporario

// CONFIGURACOES _________________________________________________________

private cFILIAL

PLAN->(dbsetorder(3)) // codigo reduzido

if ! quse("","QCONFIG") ; return ; endif
private cVERIFICA := QCONFIG->Verifica
QCONFIG->(dbclosearea())

/////////////////////////////////////////////////////////////////////////////
// MANUTENCAO DAS NOTAS DE ENTRADA __________________________________________

ENT->(dbseek(XANOMES))

ENT->(qview({{"Data_Lanc/Data Lan‡.",2},;
             {"Num_Nf/Nota Fiscal"  ,1},;
             {"Serie/S‚rie"         ,0},;
             {"transform(Vlr_Cont,'@E 999,999,999.99')/Valor Cont.",0},;
             {"transform(Icm_Vlr, '@E 999,999.99'    )/Valor ICM"  ,0},;
             {"Filial/Filial"     ,0}},"P",;
             {NIL,"i_303a",NIL,NIL},;
             NIL,"<ESC>-Sai/<C>onsulta"))

return

//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO _____________________________________

function i_303a

   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO == "C"
      do case
         // COMERCIO, PRESTACAO E MAQUINA REGISTRADORA ___________________________
         case XTIPOEMP $ "1269"
              qlbloc(6,2,"B303A","QBLOC.GLO",1)
         case XTIPOEMP $ "38"
              qlbloc(5,2,"B303B","QBLOC.GLO",1)
         case XTIPOEMP $ "4570"
              qlbloc(5,2,"B303C","QBLOC.GLO",1)
      endcase
      i_edicao()
   endif

   setcursor(nCURSOR)

return ""


//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA _________________________________________

static function i_edicao

   local lCONF
   local aEDICAO := {}
   local bESCAPE := {||empty(fDATA_LANC).or.(XNIVEL==1.and.!XFLAG) .or. (XNIVEL==1.and.lastkey()==27)}
   local sBLOC1 := qlbloc("B303D","QBLOC.GLO") // Especie
   local sBLOC2 := qlbloc("B303E","QBLOC.GLO") // Isentos ICMS para 1995
   local sBLOC3 := qlbloc("B303F","QBLOC.GLO") // Outras ICMS para 1995
   local sBLOC4 := qlbloc("B303J","QBLOC.GLO") // Isentos ICMS para 1996
   local sBLOC5 := qlbloc("B303K","QBLOC.GLO") // Outras ICMS para 1996

   // ESTADO DO CADASTRO DA EMPRESA ______________________________________________

   private fESTADO

   // ESTADO DO CADASTRO DO FORNECEDOR ___________________________________________

   private cESTADO
   // DATA TEMPORARIAS PARA MUDANCA DE NOTA FISCAL NA INCLUSAO ___________________
   private dTEMP_LANC

   // INICIA VARIAVEIS DE OUTRAS ALIQUOTAS _______________________________________

   private nBASE_1 := 0
   private nBASE_2 := 0
   private nBASE_3 := 0
   private nALIQ_1 := 0
   private nALIQ_2 := 0
   private nALIQ_3 := 0
   private nICM_1  := 0
   private nICM_2  := 0
   private nICM_3  := 0
   private nNOTAS  := 0   // PARA VERIFICAR SE JA FOI LANCADA UMA NOTA ___________

   // CODIGOS PARA MAQUINA REGISTRADORA __________________________________________

   if XTIPOEMP $ "38"
      private cCOD_1 := ""
      private cCOD_2 := ""
      private cCOD_3 := ""
   endif

   if XTIPOEMP $ "38"
      private aOUTALIQ := {{0,0,0,"  "},{0,0,0,"  "},{0,0,0,"  "}}
   else
      private aOUTALIQ := {{0,0,0},{0,0,0},{0,0,0}}
   endif

// MONTA DADOS NA TELA ___________________________________________________________

   if cOPCAO == "C"
      XNIVEL := 1
      qrsay ( XNIVEL++ , ENT->Filial                  ) ; FILIAL->(dbseek(ENT->Filial))
      qrsay ( XNIVEL++ , left(FILIAL->Razao,40)       )
      qrsay ( XNIVEL++ , ENT->Data_Lanc  , "@D"       )
      qrsay ( XNIVEL++ , ENT->Num_Nf     , "@R 999999")
      qrsay ( XNIVEL++ , ENT->Serie                   ) ; SERIE->(dbseek(ENT->Serie  ))
      qrsay ( XNIVEL++ , ENT->Especie                 ) ; ESPECIE->(dbseek(ENT->Especie))
      qrsay ( XNIVEL++ , left(ESPECIE->Descricao,15)  )
      qrsay ( XNIVEL++ , ENT->Data_Emis  , "@D"       )

      // MAQUINA REGISTRADORA ____________________________________________________

      if XTIPOEMP $ "38"  // MAQUINA REGISTRADORA
         qrsay ( XNIVEL++ , ENT->Cod_Maq , "@R 99"              ) ;MAQ->(dbseek(ENT->Cod_Maq))
         qrsay ( XNIVEL++ , MAQ->Maq_Desc                       )
      endif
      qrsay ( XNIVEL++ , ENT->Cod_Forn  , "@R 99999"            ) ;FORN->(dbseek(ENT->Cod_Forn ))
      qrsay ( XNIVEL++ , left(FORN->Razao,40)                   )
      qrsay ( XNIVEL++ , ENT->Cod_Fisc   , "@R 9.99"            ) ;NATOP->(dbseek(ENT->Cod_Fisc))
      qrsay ( XNIVEL++ , NATOP->Nat_Desc                        )
      qrsay ( XNIVEL++ , ENT->Tipo_cont                         ) ;TIPOCONT->(dbseek(ENT->Tipo_cont))
      qrsay ( XNIVEL++ , left(TIPOCONT->Descricao,30)           )
      qrsay ( XNIVEL++ , ENT->Cod_Cont                          ) ;CONTA->(dbseek(ENT->Cod_Cont))
      qrsay ( XNIVEL++ , CONTA->Descricao                       )
      qrsay ( XNIVEL++ , ENT->Vlr_Cont   ,  "@E 999,999,999.99" )
      qrsay ( XNIVEL++ , ENT->Icm_Base   ,  "@E 999,999,999.99" )
      qrsay ( XNIVEL++ , ENT->Icm_Red    ,  "@E 99.999"         )
      qrsay ( XNIVEL++ , ENT->Icm_Aliq   ,  "@E 99.99"          )
      qrsay ( XNIVEL++ , ENT->Icm_Vlr    ,  "@E 999,999,999.99" )
      qrsay ( XNIVEL++ , ENT->Icm_Isen   ,  "@E 999,999,999.99" )
      qrsay ( XNIVEL++ , ENT->Icm_Out    ,  "@E 999,999,999.99" )
      qrsay ( XNIVEL++ , ENT->Icm_bc_s   ,  "@E 999,999,999.99" )    // Foi incluido p/ resumo no final do livro

      qrsay ( XNIVEL++ , ENT->Icm_Subst  ,  "@E 999,999,999.99" )    // Foi incluido p/ resumo no final do livro

      // INDUTRIA GERAL , INDUSTRIA COM SUBSTITUICAO TRIBUTARIA __________________

      if XTIPOEMP $ "4570" // INDUSTRIA
         qrsay ( XNIVEL++ , ENT->Ipi_Base , "@E 999,999,999.99" )
         qrsay ( XNIVEL++ , ENT->Ipi_Vlr  , "@E 999,999,999.99" )
         qrsay ( XNIVEL++ , ENT->Ipi_Isen , "@E 999,999,999.99" )
         qrsay ( XNIVEL++ , ENT->Ipi_Out  , "@E 999,999,999.99" )
         qrsay ( XNIVEL++ , ENT->Ipi_Desc , "@E 999,999,999.99" )
      endif

      if val(left(CONFIG->Anomes,4)) = 1995
         qrsay ( XNIVEL++ , qabrev(ENT->Icm_Cod,"123457",{"Normal","Isentas","Outras","Diferidas","Outras Subst.Trib.","Cigarros"}) )
      else
         if ENT->Vlr_cont <> 0
            qrsay ( XNIVEL++ , qabrev(ENT->Icm_Cod,"012345679",{"Trib. Integ.","Trib. c/ Cobr. do ICMS por Sub. Trib.",;
                                                   "Com Red. de Base de Calc.","Isenta/N„o Trib. e c/Cob. do ICMS por S.T.",;
                                                   "Isenta ou N„o Tributada","Com Susp. ou Diferimento","ICMS Cobrado Anter. por S.T",;
                                                   "Com Red.de Base de Calc.e Cob.do ICMS por S.T","Outras"}) )
         else
            XNIVEL ++
         endif
      endif
      qrsay ( XNIVEL++ , ENT->Obs , "@!" )

      i_consulta()

   endif
return


//////////////////////////////////////////////////////////////////////////////////
// PARA CONSULTAR SE POSSUI OUTRAS ALIQUOTAS _____________________________________

static function i_consulta

   local nTECLA, nCONT

   setpos(24,79)

   qmensa("<ESC> p/ voltar ou <O>utras Aliquotas")

   do while .T.

      nTECLA := qinkey()

      if nTECLA == K_ESC ; exit ; endif

      if upper(chr(nTECLA)) == "O"
         i_init_out_aliq()
         XNIVEL := 1

         if XTIPOEMP $ "38"
            qlbloc(5,0,"B303H","QBLOC.GLO")
         else
            qlbloc(5,0,"B303O","QBLOC.GLO")
         endif

         for nCONT := 1 to 3
             qrsay(XNIVEL++,aOUTALIQ[nCONT,1],"@E 999,999,999.99")
             qrsay(XNIVEL++,aOUTALIQ[nCONT,2],"@E 99.99")
             qrsay(XNIVEL++,aOUTALIQ[nCONT,3],"@E 999,999,999.99")
             if XTIPOEMP $ "38"
                qrsay(XNIVEL++,aOUTALIQ[nCONT,4],"99")
             endif
         next

         qwait()

         exit

      endif

   enddo

return

//////////////////////////////////////////////////////////////////////////////////
// PARA INICIAR VALORES DE OUTRAS ALIQUOTAS ______________________________________

static function i_init_out_aliq

   if OUTENT->(dbseek(dtos(ENT->Data_lanc)+ ENT->NUM_NF + ENT->SERIE + ENT->FILIAL))
      for nCONT := 1 to 3
           aOUTALIQ[nCONT,1] := OUTENT->Icm_Base
           aOUTALIQ[nCONT,2] := OUTENT->Icm_Aliq
           aOUTALIQ[nCONT,3] := OUTENT->Icm_Vlr
           if XTIPOEMP $ "38"
              aOUTALIQ[nCONT,4] := OUTENT->Cod_Maq
           endif
           OUTENT->(dbskip())
           if ENT->Num_nf + ENT->Serie + ENT->Filial <> OUTENT->Num_nf + OUTENT->Serie + OUTENT->Filial
              exit
           endif
      next
   else
      return
   endif

   // INICIA VARIAVEIS PARA EDICAO _______________________________________________

   nBASE_1 := aOUTALIQ[1,1]
   nBASE_2 := aOUTALIQ[2,1]
   nBASE_3 := aOUTALIQ[3,1]
   nALIQ_1 := aOUTALIQ[1,2]
   nALIQ_2 := aOUTALIQ[2,2]
   nALIQ_3 := aOUTALIQ[3,2]
   nICM_1  := aOUTALIQ[1,3]
   nICM_2  := aOUTALIQ[2,3]
   nICM_3  := aOUTALIQ[3,3]

   if XTIPOEMP $ "38"
      cCOD_1 := aOUTALIQ[1,4]
      cCOD_2 := aOUTALIQ[2,4]
      cCOD_3 := aOUTALIQ[3,4]
   endif

return
