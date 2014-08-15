/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: ESCRITA FISCAL
// OBJETIVO...: CONSULTA DAS NOTAS DE SAIDA
// ANALISTA...:
// PROGRAMADOR: LUCINEIDE VILAR POSSEBOM
// INICIO.....: SETEMBRO DE 1998
// OBS........:
// ALTERACOES.:
function ef304

#include "inkey.ch"
#include "ef.ch"

private nVALOR := 0     // Variavel temporario para guardar outras aliquotas

// CONFIGURACOES ____________________________________________________________

if ! quse("","QCONFIG") ; return ; endif
private cVERIFICA := QCONFIG->Verifica
QCONFIG->(dbclosearea())

/////////////////////////////////////////////////////////////////////////////
// TIRA NOTAS DE BASE AJUSTADA QDO MAQ.REG. (@@ + ANO + MES) ________________

if XTIPOEMP $ "38"
   select SAI
   set filter to left(SAI->Num_Nf,2) <> "@@"
endif

/////////////////////////////////////////////////////////////////////////////
// MANUTENCAO DAS NOTAS DE SAIDA ____________________________________________

SAI->(dbseek(XANOMES))

SAI->(qview({{"Data_Lanc/Data Lan‡.",2},;
             {"Num_Nf/Nota Fiscal"  ,1},;
             {"Serie/S‚rie"         ,0},;
             {"transform(Vlr_Cont,'@E 999,999,999.99')/Valor Cont.",0},;
             {"transform(Icm_Vlr,'@E 999,999.99')/Valor ICM"       ,0},;
             {"Filial/Filial"     ,0}},"P",;
             {NIL,"i_304a",NIL,NIL},;
             NIL,"<ESC>-Sai/<C>onsulta"))
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function i_304a

   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO == "C"
      do case

         // COMERCIO, PRESTACAO E MAQUINA C/ 3 DEPTOS _______________________

         case XTIPOEMP $ "12689"

              // SE USA VENDEDOR ____________________________________________

              if XUSA_VEND == "1"
                 qlbloc(5,2,"B304AV" ,"QBLOC.GLO",1)
              else
                 qlbloc(6,2,"B304A","QBLOC.GLO",1)
              endif

         // MAQUINA REGISTRADORA   __________________________________________

         case XTIPOEMP $ "3"
              qlbloc(5,2,"B304B" ,"QBLOC.GLO",1)

         // INDUSTRIAS ______________________________________________________

         case XTIPOEMP $ "4570"

              // SE USA VENDEDOR ____________________________________________

              if XUSA_VEND == "1"
                 qlbloc(4,2,"B304CV","QBLOC.GLO",1)
              else
                 qlbloc(4,2,"B304C","QBLOC.GLO",1)
              endif

      endcase

      qmensa(qabrev(cOPCAO,"IA",{"Inclus„o...","Altera‡„o..."}))

      i_edicao()

   endif
   setcursor(nCURSOR)
return ""


/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA ____________________________________

static function i_edicao

   Local lCONF
   local aEDICAO := {}
   local bESCAPE := {||empty(fDATA_LANC).or.(XNIVEL==1.and.!XFLAG).or.;
                       (XNIVEL==1.and.lastkey()==27)}

   local sBLOC1 := qlbloc("B304D","QBLOC.GLO") // especie
   local sBLOC2 := qlbloc("B304E","QBLOC.GLO") // isentos ICMS
   local sBLOC3 := qlbloc("B304F","QBLOC.GLO") // outras ICMS

   local sBLOC4 := qlbloc("B304J","QBLOC.GLO") // isentos ICMS
   local sBLOC5 := qlbloc("B304K","QBLOC.GLO") // outras ICMS

   local sBLOC6 := qlbloc("B304L","QBLOC.GLO") // tabela para identificacao de cigarro para 1996

   // DATA TEMPORARIAS PARA MUDANCA DE NOTA FISCAL NA INCLUSAO ______________

   private dTEMP_LANC
   private dTEMP_EMIS

   // INICIA VARIAVEIS DE OUTRAS ALIQUOTAS __________________________________

   private cTEMP_SERI := "  "
   private cTEMP_EST  := "  "
   private cTEMP_C_FI := "   "
   private cTEMP_C_VD := "   "
   private cTEMP_ICM  := " "
   private cTEMP_CONT := "      "
   private nBASE_1    := 0
   private nBASE_2    := 0
   private nBASE_3    := 0
   private nALIQ_1    := 0
   private nALIQ_2    := 0
   private nALIQ_3    := 0
   private nICM_1     := 0
   private nICM_2     := 0
   private nICM_3     := 0

   private nNOTAS     := 0   // PARA VERIFICAR SE JA FOI LANCADA UMA NOTA ___

   private aOUTALIQ   := {{0,0,0},{0,0,0},{0,0,0}}
   
   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO == "C"

      XNIVEL := 1

      qrsay ( XNIVEL++ , SAI->Filial                  ) ; FILIAL->(dbseek(SAI->Filial))
      qrsay ( XNIVEL++ , left(FILIAL->Razao,40)       )

      qrsay ( XNIVEL++ , SAI->Data_lanc , "@D"        )
      qrsay ( XNIVEL++ , SAI->Num_nf    , "@R 999999" )
      qrsay ( XNIVEL++ , SAI->Serie                   ) ;SERIE->(dbseek(SAI->Serie))
      if XTIPOEMP $ "3"
        qrsay ( XNIVEL++ , SERIE->Descricao, "@!"       )
      endif
      // SE NAO FOR MAQUINA REGISTRADORA ____________________________________

      qrsay ( XNIVEL++ , SAI->Especie                 ) ; ESPECIE->(dbseek(SAI->Especie))
      qrsay ( XNIVEL++ , left(ESPECIE->Descricao,15)  )
      qrsay ( XNIVEL++ , SAI->Data_Emis  , "@D"        )
      qrsay ( XNIVEL++ , SAI->Num_Ult_Nf , "@R 999999" )

      // SE NAO FOR MAQUINA REGISTRADORA ____________________________________

      if XTIPOEMP $ "124567890"
         qrsay ( XNIVEL++ , SAI->Estado                 ) ;ESTADO->(dbseek(SAI->Estado ))
         qrsay ( XNIVEL++ , ESTADO->Est_Desc            )
         qrsay ( XNIVEL++ , SAI->Cod_fisc   , "@R 9.99" ) ;NATOP->(dbseek(SAI->Cod_fisc))
         qrsay ( XNIVEL++ , NATOP->Nat_Desc             )

         qrsay ( XNIVEL++ , SAI->Tipo_cont               ) ;TIPOCONT->(dbseek(SAI->Tipo_cont))
         qrsay ( XNIVEL++ , left(TIPOCONT->Descricao,30) )

         qrsay ( XNIVEL++ , SAI->Cod_Cont               ) ;CONTA->(dbseek(SAI->Cod_cont))
         qrsay ( XNIVEL++ , CONTA->Descricao            )

         // SE USA VENDEDOR _________________________________________________

         if XUSA_VEND == "1"
            qrsay ( XNIVEL++ , SAI->Cod_Vend            ) ;VEND->(dbseek(SAI->Cod_Vend))
            qrsay ( XNIVEL++ , VEND->Nome               )
         else
            if XTIPOEMP $ "4570"
               XNIVEL ++
               XNIVEL ++
            endif
         endif
      endif
      qrsay ( XNIVEL++ , SAI->Vlr_Cont , "@E 999,999,999.99" )

      // SE NAO FOR MAQUINA REGISTRADORA ____________________________________

      if XTIPOEMP $ "124567890"
         qrsay ( XNIVEL++ , SAI->Icm_Base  , "@E 999,999,999.99" )
         qrsay ( XNIVEL++ , SAI->Icm_Red   , "@E 99.999"         )
         qrsay ( XNIVEL++ , SAI->Icm_Aliq  , "@E 99.99"          )
         qrsay ( XNIVEL++ , SAI->Icm_Vlr   , "@E 999,999,999.99" )
         qrsay ( XNIVEL++ , SAI->Icm_Isen  , "@E 999,999,999.99" )
         qrsay ( XNIVEL++ , SAI->Icm_Out   , "@E 999,999,999.99" )
         qrsay ( XNIVEL++ , SAI->Icm_bc_s  , "@E 999,999,999.99" )    // Incluido para resumo no livro
         qrsay ( XNIVEL++ , SAI->Icm_Subst , "@E 999,999,999.99" )    // Incluido para resumo no livro

         // INDUSTRIAS ______________________________________________________

         if XTIPOEMP $ "4570"
            qrsay ( XNIVEL++ , SAI->Ipi_Base , "@E 999,999,999.99" )
            qrsay ( XNIVEL++ , SAI->Ipi_Vlr  , "@E 999,999,999.99" )
            qrsay ( XNIVEL++ , SAI->Ipi_Isen , "@E 999,999,999.99" )
            qrsay ( XNIVEL++ , SAI->Ipi_Out  , "@E 999,999,999.99" )
            qrsay ( XNIVEL++ , SAI->Ipi_Desc , "@E 999,999,999.99" )
         endif

         if val(left(CONFIG->Anomes,4)) = 1995
            qrsay ( XNIVEL++ , qabrev(SAI->Icm_Cod,"123457",{"Normal","Isentas","Outras","Diferidas","Outras Subst.Trib.","Cigarros"}) )
         else
            if SAI->Vlr_cont <> 0
               qrsay ( XNIVEL++ ,qabrev(SAI->Icm_Cod,"012345679",{"Trib. Integ.","Trib. c/ Cobr. do ICMS por Sub. Trib.",;
                                                      "Com Red. de Base de Calc.","Isenta/N„o Trib. e c/ Cob. do ICMS por S.T",;
                                                      "Isenta ou N„o Tributada","Com Susp. ou Diferimento","ICMS Cobrado Anter. por S.T",;
                                                     "Com Red.de Base de Calc.e Cob.do ICMS por S.T","Outras"}) )
            else
               XNIVEL ++
            Endif
         endif

         qrsay ( XNIVEL++ , SAI->Obs         , "@!"                )

         i_consulta()

      endif
   endif

return

/////////////////////////////////////////////////////////////////////////////
// PARA CONSULTAR SE POSSUI OUTRAS ALIQUOTAS ________________________________

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
         qlbloc(5,0,"B304O","QBLOC.GLO")

         for nCONT := 1 to 3
             qrsay(XNIVEL++,aOUTALIQ[nCONT,1],"@E 999,999,999.99")
             qrsay(XNIVEL++,aOUTALIQ[nCONT,2],"@E 99.99")
             qrsay(XNIVEL++,aOUTALIQ[nCONT,3],"@E 999,999,999.99")
         next

         qwait()
         exit

      endif
   enddo

return

/////////////////////////////////////////////////////////////////////////////
// PARA INICIAR VALORES DE OUTRAS ALIQUOTAS _________________________________

static function i_init_out_aliq

   if OUTSAI->(dbseek(dtos(SAI->DATA_LANC) + SAI->NUM_NF+ SAI->SERIE + SAI->FILIAL))
      for nCONT := 1 to 3
           aOUTALIQ[nCONT,1] := OUTSAI->Icm_Base
           aOUTALIQ[nCONT,2] := OUTSAI->Icm_Aliq
           aOUTALIQ[nCONT,3] := OUTSAI->Icm_Vlr
           OUTSAI->(dbskip())

           if dtos(SAI->Data_lanc) + SAI->Num_nf + SAI->Serie + SAI->Filial <> dtos(OUTSAI->Data_lanc) + OUTSAI->Num_nf + OUTSAI->Serie + OUTSAI->Filial
              exit
           endif
      next
   else
      return
   endif

   // INICIA VARIAVEIS PARA EDICAO __________________________________________

   nBASE_1 := aOUTALIQ[1,1]
   nBASE_2 := aOUTALIQ[2,1]
   nBASE_3 := aOUTALIQ[3,1]
   nALIQ_1 := aOUTALIQ[1,2]
   nALIQ_2 := aOUTALIQ[2,2]
   nALIQ_3 := aOUTALIQ[3,2]
   nICM_1  := aOUTALIQ[1,3]
   nICM_2  := aOUTALIQ[2,3]
   nICM_3  := aOUTALIQ[3,3]

return

