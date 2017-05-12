/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE Contabilidade
// OBJETIVO...: Exportar arquivo p/ SPED Contabil
// ANALISTA...: EDUARDO AUGUSTO BORIO
// PROGRAMADOR: EDUARDO AUGUSTO BORIO
// INICIO.....: JULHO 2010
// OBS........:
// ALTERACOES.:

function ct430

#define K_MAX_LIN 57
#include "fileio.ch"

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG) .or. lastkey() == 27 }

private cTITULO                   // titulo do relatorio
private dINI
private dFIM
private cICMS   := space(7)
private cIPI    := space(7)
private cEMP    := space(7)
private cTIPO   := space(2)
private cDRIVE  := space(2)
private cSISTEMA:= space(2)
private cDEB    := "DB01"
private cCRE    := "CR01"
private nTOT_LIN := 0
private nTOT_BLOCOI := 0
private nTOT_BLOCOJ := 0
private nTOT_BLOCO9 := 0

private nTOT_I050 := 0
private nTOT_I150 := 0
private nTOT_I155 := 0
private nTOT_I200 := 0
private nTOT_I250 := 0
private nTOT_I350 := 0
private nTOT_I355 := 0
private nTOT_J005 := 0
private nTOT_J100 := 0
private nTOT_J150 := 0

private sBLOC1  := qlbloc("B430B","QBLOC.GLO")
private nFile   := 0
private cLivro  := space(5)
private cBuffer := ""
private aAbertura := {}
private aDatas    := {}
private aValores  := {}


private aEDICAO := {}             // vetor para os campos de entrada de dados

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qgetx(-1,0,@dINI)            } , "INI"    })
aadd(aEDICAO,{{ || qgetx(-1,0,@dFIM)            } , "FIM"    })
aadd(aEDICAO,{{ || qesco(-1,0,@cTIPO,sBLOC1)    } , "TIPO"   })
aadd(aEDICAO,{{ || qgetx(-1,0,@cLIVRO,"99999")  } , "LIVRO"  })

aadd(aEDICAO,{{ || lCONF := qconf("Confirma Exportacao de Arquivo SPED Contabil ?") },NIL})

do while .T.

   qlbloc(5,0,"B430A","QBLOC.GLO")
   XNIVEL := 1
   XFLAG  := .T.
   dINI    := ctod("")
   dFIM    := ctod("")
   cICMS   := space(7)
   cIPI    := space(7)
   cEMP    := space(7)
   cTIPO   := space(2)
   cSISTEMA:= space(2)
   cSLIVRO := space(5)
   cDRIVE := ""

   // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; dbcloseall() ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   if ( i_inicializacao() , i_gravacao() , NIL )

   qmensa("")

enddo

/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA _____________________________________________

static function i_critica ( cCAMPO )

   do case

      case cCAMPO == "INI"
           dFIM := qfimmes(dINI)
           qrsay(XNIVEL+1,dtoc(dFIM))

      case cCAMPO == "FIM"
           if dFIM < dINI
             qmensa("Data Final nÆo pode ser Inferior a Data Inicial !","B")
             return .F.
             qmensa("")
           endif

      case cCAMPO == "TIPO"
           if empty(cTIPO) ;  return .F. ; Endif
           qrsay(XNIVEL,qabrev(cTIPO,"12",{"1 - Diario Geral",""}))

   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // CRIA TITULO DO RELATORIO ______________________________________________


   cTITULO := ""

   qmensa("")

return .T.


static function i_gravacao
   local   cSINCO :=  ""

   cSINCO := ""

   do case
      case cDRIVE == "A"
           cDRIVE := "A:"

      case cDRIVE == "C"
           cDRIVE := "C:\"

      case cDRIVE == "D"
           cDRIVE := "D:\"

      case cDRIVE == "E"
           cDRIVE := "E:\"

      case cDRIVE == "F"
           cDRIVE := "F:\"

      case cDRIVE == "G"
           cDRIVE := "C:\Windows\Desktop\"

      case cDRIVE == "H"
           cDRIVE := "C:\Docume~1\AllUse~1\Desktop\"

      case cDRIVE == "I"
           cDRIVE := "C:\users\AllUse~1\Desktop\"

   endcase

   if ! quse(XDRV_CT,"ITN_LANC",{"ITN_LANC"},"E")
      qmensa("N„o foi poss¡vel abrir arquivo SPED.DBF !! Tente novamente.")
      return
   endif

   ITN_LANC->(__dbzap())

   if ! quse(XDRV_CT,"SPED",{},"E")
      qmensa("N„o foi poss¡vel abrir arquivo SPED.DBF !! Tente novamente.")
      return
   endif

   SPED->(__dbzap())



   do case
      case cTIPO == "1"
           MultiPartida()
           i_Diario_Geral()

   endcase

   ITN_LANC->(dbclosearea())

   qmensa("Operacao Concluida!","BL")

return



static function i_Diario_Geral

    nTOT_LIN := 0
    nTOT_BLOCOI := 0
    nTOT_BLOCOJ := 0

    nTOT_I050 := 0
    nTOT_I051 := 0
    nTOT_I052 := 0
    nTOT_I150 := 0
    nTOT_I155 := 0
    nTOT_I200 := 0
    nTOT_I250 := 0
    nTOT_I350 := 0
    nTOT_I355 := 0
    nTOT_J100 := 0
    nTOT_J150 := 0
    aAbertura := {}
    setSaldoAbertura("S") //Gera Saldo_ant no PLAN

    nFile := 0

    registro_0000()
    Bloco_0()
    Bloco_I()
    Bloco_J()
    Bloco_9()
	
	setSaldoAbertura("E") // Volta os valores ao Normal QSys Like
    delRegFantasma()

    geraTxt()

return


static function registro_0000
local cSPED := ""

      cSPED := "|0000|LECD"
      cSPED += "|"+data_sped(dINI)
      cSPED += "|"+data_sped(dFIM)
      cSPED += "|"+rtrim(FILIAL->Razao)
      cSPED += "|"+FILIAL->Cgccpf
      CGM->(dbseek(FILIAL->Cgm))
      cSPED += "|"+CGM->Estado
      cSPED += "|"+alltrim(qtiraponto(FILIAL->Insc_estad))
      cSPED += "|"+CGM->Cod_rais //IBGE codigo
      cSPED += "|"              //Insc Municipal
      cSPED += "|"              //Indcador Situacao Especial
      cSPED += "|0"              //Indicador de perdido 0 - Inicio do Ano
      cSPED += "|0"              //Indcador Se Tem a escrituracao tem NIRE
      cSPED += "|0"              //Finalidade - 0 Original
      cSPED += "|"               //HasCode
      cSPED += "|"              //Nire da escrit sendo sbstituida
      cSPED += "|0"              //Indicador grande porte
      cSPED += "|0"              //Empresa nao part de SCP como socio ostensivo
      cSPED += "|"              //Indicacao da SCP
	  cSPED += "|N"              //Fim
	  cSPED += "|"              //Fim

      nTOT_LIN++

      write(nFile,cSPED,len(cSPED))

      cSPED := ""

return

static function Bloco_0
local cSPED := ""

      nTOT_LIN++
      cSPED := "|0001|0|"  //Abre Bloco 0
      write(nFile,cSPED,len(cSPED))
      cSPED := ""

      nTOT_LIN++
      cSPED := "|0007|00||" //Outras Insc
      write(nFile,cSPED,len(cSPED))
      cSPED := ""

      nTOT_LIN++
      cSPED := "|0990|"+alltrim(str(nTOT_LIN))+"|" // Fecha Bloco 0
      write(nFile,cSPED,len(cSPED))
      cSPED := ""
return

static function Bloco_I
local cSPED := ""

      nTOT_BLOCOI++
      nTOT_LIN++
      cSPED := "|I001|0|"  //Abre Bloco I

      write(nFile,cSPED,len(cSPED))
      cSPED := ""


      nTOT_BLOCOI++
      nTOT_LIN++
      cSPED := "|I010|G|4.00|" //Tipo de Arquivo G = Diario Geral

      write(nFile,cSPED,len(cSPED))
      cSPED := ""
	  
	  cNIRE := strtran(alltrim(CONFIG->Num_junta),".","")
	  
      nTOT_BLOCOI++
      nTOT_LIN++
      cSPED := "|I030|TERMO DE ABERTURA|"+alltrim(str(val(cLIVRO)))+"|DIARIO GERAL" //Termo de Abertura
      cSPED += "|1"
      cSPED += "|"+rtrim(FILIAL->Razao)
      //cSPED += "|"+cNIRE
      cSPED += "|"
      cSPED += "|"+FILIAL->Cgccpf
      cSPED += "|"+data_sped(CONFIG->Data_junta)
      cSPED += "|"
      CGM->(Dbseek(FIlial->Cgm))
      cSPED += "|"+ rtrim(CGM->Municipio)
      cSPED += "|"+data_sped(dFIM)
      cSPED += "|"

      write(nFile,cSPED,len(cSPED))
      cSPED := ""

      rI050() //Plano de Contas

      rI150() //Periodos - Balancetes

      rI200() //Lancamentos e Partidas
	  
	  rI350()  // Saldos das contas de resultado antes do encerramento


      nTOT_BLOCOI++
      nTOT_LIN++
      cSPED := "|I990|"+alltrim(str(nTOT_BLOCOI))+"|"
      write(nFile,cSPED,len(cSPED))
      cSPED := ""

return


static function rI050
local cSPED := ""
local cNATUREZA := ""
local cINDICADOR := ""
local cNIVEL := ""

   PLAN->(dbsetorder(1))
   PLAN->(dbgotop())

   do while ! PLAN->(eof())

      if empty(PLAN->Codigo)
         PLAN->(dbskip())
         loop
      endif

      do case
         case left(PLAN->Nat_cont,2) == "AT"
              cNATUREZA := "01"

         case left(PLAN->Nat_cont,2) == "PS"
              cNATUREZA := "02"

         case left(PLAN->Nat_cont,2) == "DP"
              cNATUREZA := "04"

         case left(PLAN->Nat_cont,2) == "RC"
              cNATUREZA := "04"

      endcase

      if empty(PLAN->Reduzido)
         cIndicador := "S"
      else
         cIndicador := "A"
      endif

      cNIVEL := getNivel(PLAN->Codigo)
	  cSuperior := alltrim(maskCod(searchSuperior(PLAN->Codigo),cNIVEL))

      cSPED := "|I050|"+data_sped(dINI)
      cSPED += "|"+cNATUREZA
      cSPED += "|"+cIndicador //Analit. ou Sintetica
      cSPED += "|"+cNivel
      cSPED += "|"+alltrim(maskCod(PLAN->Codigo,cNIVEL))
      cSPED += "|"+cSuperior
      cSPED += "|"+rtrim(PLAN->Descricao)
      cSPED += "|" //Finaliza Reg

      write(nFile,cSPED,len(cSPED))
	  
	  if(cIndicador == "A")
		  rI052(+alltrim(maskCod(PLAN->Codigo,cNIVEL)))
	  endif	  

      cSPED := ""

      nTOT_I050++
      nTOT_BLOCOI++
      nTOT_LIN++

      PLAN->(dbskip())

   enddo

return

static function rI052(cSuperior)
local cSPED := ""
local cNATUREZA := ""
local cINDICADOR := ""
local cNIVEL := ""

      cSPED := "|I052"
      cSPED += "| "//Cod Ccusto nao obrigatorio
      cSPED += "|"+cSuperior
      cSPED += "|" //Finaliza Reg

      write(nFile,cSPED,len(cSPED))
	  
      cSPED := ""

      nTOT_I052++
      nTOT_BLOCOI++
      nTOT_LIN++
return


static function rI150
local cSPED := ""
local nCONT := 0
local dData := ctod("")
local nSaldo_ant := 0
local nSaldo_atu := 0
local nDebitos   := 0
local nCreditos  := 0
local cDEB,cCRE  := ""


     for ncONT := 1 to 12
         dData := ctod("01/"+strzero(nCONT)+"/"+CONFIG->Exercicio)
         cSPED := "|I150|"+data_sped(dData)+"|"+data_sped(qfimmes(dData))+"|"
         write(nFile,cSPED,len(cSPED))
         cSPED := ""

         nTOT_I150++
         nTOT_BLOCOI++
         nTOT_LIN++


         PLAN->(dbgotop())
         do while ! PLAN->(eof())

            if empty(PLAN->Reduzido) //Somente Contas Analiticas
               PLAN->(dbskip())
               loop
            endif

            if ! i_temMovimentoMes(nCONT) //Somente as Com movimentacao ou saldo
               PLAN->(dbskip())
               loop
            endif

            nSaldo_ant := i_puxasaldo(nCONT)

            cDEB := "DB"+strzero(nCONT,2)
            cCRE := "CR"+strzero(nCONT,2)


            cSPED := "|I155"
            cSPED += "|"+alltrim(maskCod(PLAN->Codigo))
            cSPED += "|"

            if nSALDO_ANT < 0
               cSPED += "|"+i_valida(nSALDO_ANT*(-1),19)
               cSPED += "|C"
            else
               cSPED += "|"+i_valida(nSALDO_ANT,19)
               cSPED += "|D"
            endif

            nDebitos  := 0
            nCreditos := 0

            //if nCONT == 1
            //   if left(PLAN->Nat_cont,2) == "AT"
            //      nDebitos  += getSaldoAbertura(PLAN->Reduzido)*-1
            //   endif

            //   if left(PLAN->Nat_cont,2) == "PS"
            //      nCreditos += getSaldoAbertura(PLAN->Reduzido)*-1
            //   endif
            //endif

            nDebitos  += PLAN->&cDEB
            nCreditos += PLAN->&cCRE

            cSPED += "|"+i_valida(nDebitos,19)
            cSPED += "|"+i_valida((nCreditos)*(-1),19)
            nSALDO_ATU := nSALDO_ANT + nDebitos + nCreditos

            if nSALDO_ATU < 0
               cSPED += "|"+i_valida(nSALDO_ATU*(-1),19)
               cSPED += "|C"
            else
               cSPED += "|"+i_valida(nSALDO_ATU,19)
               cSPED += "|D"
            endif

            cSPED += "|"

            write(nFile,cSPED,len(cSPED))

            nTOT_I155++
            nTOT_BLOCOI++
            nTOT_LIN++


            cSPED := ""
            nSaldo_ant := 0
            nSaldo_atu := 0
            nDebitos   := 0
            nCreditos  := 0

            PLAN->(dbskip())
         enddo

     next

return

static function rI200
local cSPED     := ""
local cHIST     := ""
local nNUM_LANC := 0

    PLAN->(dbsetorder(3))

    LANC->(dbsetorder(1)) //Dtos(data_lanc)
    LANC->(dbgotop())

    do While ! LANC->(eof())


       if LANC->Hp1 == "108"
          LANC->(dbskip())
          loop
       endif

       if empty(LANC->cont_db) .or. empty(LANC->(cont_cr))
          LANC->(dbskip())
          loop
       endif

	   /*
       if LANC->num_lote == "*FECHA    "
          LANC->(dbskip())
          loop
       endif
	   */

       nNUM_LANC++
       cSPED := "|I200|"+strzero(nNUM_LANC,5)+"|"+data_sped(LANC->Data_lanc)+"|"+i_valida(LANC->Valor,19)+"|"
       cSPED += iif(left(LANC->num_lote,6) == "*FECHA","E","N")
       cSPED += "|"
       write(nFile,cSPED,len(cSPED))
       cSPED := ""
       nTOT_I200++
       nTOT_BLOCOI++
       nTOT_LIN++

       if empty(LANC->Cod_lanc)

          HIST->(dbseek(LANC->Hp1)) ; cHIST := alltrim(HIST->Descricao) + " "
          HIST->(dbseek(LANC->Hp2)) ; cHIST += alltrim(HIST->Descricao) + " "
          HIST->(dbseek(LANC->Hp3)) ; cHIST += alltrim(HIST->Descricao) + " "

          cHIST += LANC->Hist_comp

          cHIST := ltrim(cHIST)
          cHIST := rtrim(cHIST)
		  
		  if empty(cHIST)
			 cHist := "LANCAMENTO" 
		  endif

          if ! empty(LANC->Cont_cr)
             cSPED := "|I250"
             PLAN->(dbseek(LANC->Cont_cr))
             cSPED += "|"+alltrim(maskCod(PLAN->Codigo))
             cSPED += "||"+i_valida(LANC->Valor,19)
             cSPED += "|C|||"+cHIST+"||"
             write(nFile,cSPED,len(cSPED))
             cSPED := ""
             nTOT_I250++
             nTOT_BLOCOI++
             nTOT_LIN++
          endif

          if ! empty(LANC->Cont_db)
             cSPED := "|I250"
             PLAN->(dbseek(LANC->Cont_db))
             cSPED += "|"+alltrim(maskCod(PLAN->Codigo))
             cSPED += "||"+i_valida(LANC->Valor,19)
             cSPED += "|D|||"+cHIST+"||"
             write(nFile,cSPED,len(cSPED))
             cSPED := ""
             nTOT_I250++
             nTOT_BLOCOI++
             nTOT_LIN++

          endif
       else
          ITN_LANC->(dbseek(LANC->cod_lanc))
          do while ! ITN_LANC->(eof()) .and. ITN_LANC->Cod_lanc == LANC->cod_lanc
             HIST->(dbseek(ITN_LANC->Hp1)) ; cHIST := alltrim(HIST->Descricao) + " "
             HIST->(dbseek(ITN_LANC->Hp2)) ; cHIST += alltrim(HIST->Descricao) + " "
             HIST->(dbseek(ITN_LANC->Hp3)) ; cHIST += alltrim(HIST->Descricao) + " "

             cHIST += ITN_LANC->Hist_comp

             cHIST := ltrim(cHIST)
             cHIST := rtrim(cHIST)
			 
			 if empty(cHIST)
				cHist := "LANCAMENTO" 
		     endif

             if ! empty(ITN_LANC->Cont_cr)
                cSPED := "|I250"
                PLAN->(dbseek(ITN_LANC->Cont_cr))
                cSPED += "|"+alltrim(maskCod(PLAN->Codigo))
                cSPED += "||"+i_valida(ITN_LANC->Valor,19)
                cSPED += "|C|||"+cHIST+"||"
                write(nFile,cSPED,len(cSPED))
                cSPED := ""
                nTOT_I250++
                nTOT_BLOCOI++
                nTOT_LIN++
             endif

             if ! empty(ITN_LANC->Cont_db)
                cSPED := "|I250"
                PLAN->(dbseek(ITN_LANC->Cont_db))
                cSPED += "|"+alltrim(maskCod(PLAN->Codigo))
                cSPED += "||"+i_valida(ITN_LANC->Valor,19)
                cSPED += "|D|||"+cHIST+"||"
                write(nFile,cSPED,len(cSPED))
                cSPED := ""
                nTOT_I250++
                nTOT_BLOCOI++
                nTOT_LIN++
             endif

             ITN_LANC->(dbskip())
          enddo

       endif

       LANC->(dbskip())
    enddo

return

static function rI350
local cSPED     := ""
local cHIST     := ""
local nNUM_LANC := 0

    PLAN->(dbsetorder(3))

    LANC->(dbsetorder(1)) //Dtos(data_lanc)
    LANC->(dbgotop())
	
	cSPED := ""
    nTOT_I350++
    nTOT_BLOCOI++
    nTOT_LIN++
	cSPED := "|I350|3112"+CONFIG->Exercicio+"|"
	write(nFile,cSPED,len(cSPED))

    do While ! LANC->(eof())

       if LANC->num_lote == "*FECHA    "
	   
			if ! empty(LANC->Cont_cr)
                
                if PLAN->(dbseek(LANC->Cont_cr))
				
				    if val(left(PLAN->Codigo,1)) > 2
						cSPED := "|I355"
						cSPED += "|"+alltrim(maskCod(PLAN->Codigo))
						cSPED += "||"+i_valida(LANC->Valor,19)
						cSPED += "|D|"
						write(nFile,cSPED,len(cSPED))
						cSPED := ""
						nTOT_I355++
						nTOT_BLOCOI++
						nTOT_LIN++
					endif	
				endif
             endif
			 
			 if ! empty(LANC->Cont_db)
                
                if PLAN->(dbseek(LANC->Cont_db))
				
				    if val(left(PLAN->Codigo,1)) > 2
						cSPED := "|I355"
						cSPED += "|"+alltrim(maskCod(PLAN->Codigo))
						cSPED += "||"+i_valida(LANC->Valor,19)
						cSPED += "|C|"
						write(nFile,cSPED,len(cSPED))
						cSPED := ""
						nTOT_I355++
						nTOT_BLOCOI++
						nTOT_LIN++
					endif	
				endif
             endif
	   
       endif
	   LANC->(dbskip())
			
	enddo	   
	   
	   
return	   

static function Bloco_J
local cSPED := ""

   nTOT_LIN++
   nTOT_BLOCOJ++
   cSPED := "|J001|0|"
   write(nFile,cSPED,len(cSPED))
   cSPED := ""


      nTOT_LIN++
	  nTOT_J005++
      nTOT_BLOCOJ++
      cSPED := "|J005"
      cSPED += "|"+data_sped(dINI)
      cSPED += "|"+data_sped(dFIM)
      cSPED += "|1"
      cSPED += "| |"
      write(nFile,cSPED,len(cSPED))
      cSPED := ""

      balanco()
	  
	  if CONFIG->Mantra == "S"
	      dre_mantra()
	  else
		  dre_romero()	
	  endif


   nTOT_LIN++
   nTOT_BLOCOJ++
   cSPED := "|J900|TERMO DE ENCERRAMENTO|"+alltrim(str(val(cLIVRO)))+"|DIARIO GERAL"
   cSPED += "|"+rtrim(FILIAL->Razao)
   cSPED += "|1"//+alltrim(str(nTOT_BLOCOJ+)) 
   cSPED += "|"+data_sped(dINI)
   cSPED += "|"+data_sped(dFIM)
   cSPED += "|"
   write(nFile,cSPED,len(cSPED))
   cSPED := ""
   
   nTOT_LIN++
   nTOT_BLOCOJ++
   cSPED := "|J930"
   cSPED += "|"+"Mantraco do Brasil"
   cSPED += "|"+"07069809000119"
   cSPED += "|Signatario da ECD com e-CNPJ ou e-PJ"
   cSPED += "|001"
   cSPED += "|||||||S|"
   write(nFile,cSPED,len(cSPED))
   cSPED := ""

   nTOT_LIN++
   nTOT_BLOCOJ++
   cSPED := "|J930"
   cSPED += "|"+rtrim(CONFIG->Diretor)
   cSPED += "|"+alltrim(qtiraponto(CONFIG->Cpf_direto))
   cSPED += "|Diretor"
   cSPED += "|203"
   cSPED += "|||||||N|"
   write(nFile,cSPED,len(cSPED))
   cSPED := ""

   nTOT_LIN++
   nTOT_BLOCOJ++
   cSPED := "|J930"
   cSPED += "|"+rtrim(FILIAL->Contador)
   cSPED += "|"+FILIAL->Cpf_contad
   cSPED += "|Contabilista"
   cSPED += "|900"
   cSPED += "|"+rtrim(FILIAL->Crc)
   cSPED += "|contabil@contab.com.br|33333333|PR|||N|"
   write(nFile,cSPED,len(cSPED))
   cSPED := ""

   nTOT_LIN++
   nTOT_BLOCOJ++
   cSPED := "|J990"
   cSPED += "|"+alltrim(str(nTOT_BLOCOJ))
   cSPED += "|"
   write(nFile,cSPED,len(cSPED))
   cSPED := ""


return

static function Bloco_9
local cSPED := ""

   nTOT_LIN++
   nTOT_BLOCO9++
   cSPED := "|9001|0|"
   write(nFile,cSPED,len(cSPED))
   cSPED := ""

   ///////////////////////////////////////////////////
   //Totais por Tipo de Registro_____________________

   nTOT_LIN++
   nTOT_BLOCO9++
   cSPED := "|9900|0000|1|"
   write(nFile,cSPED,len(cSPED))
   cSPED := ""


   nTOT_LIN++
   nTOT_BLOCO9++
   cSPED := "|9900|0001|1|"
   write(nFile,cSPED,len(cSPED))
   cSPED := ""

   nTOT_LIN++
   nTOT_BLOCO9++
   cSPED := "|9900|0007|1|"
   write(nFile,cSPED,len(cSPED))
   cSPED := ""

   nTOT_LIN++
   nTOT_BLOCO9++
   cSPED := "|9900|0990|1|"
   write(nFile,cSPED,len(cSPED))
   cSPED := ""


   ////////////////////////////////////////////
   //BLOCO I - TOTAIS_________________________

   nTOT_LIN++
   nTOT_BLOCO9++
   cSPED := "|9900|I001|1|"
   write(nFile,cSPED,len(cSPED))
   cSPED := ""

   nTOT_LIN++
   nTOT_BLOCO9++
   cSPED := "|9900|I010|1|"
   write(nFile,cSPED,len(cSPED))
   cSPED := ""

   nTOT_LIN++
   nTOT_BLOCO9++
   cSPED := "|9900|I030|1|"
   write(nFile,cSPED,len(cSPED))
   cSPED := ""

   nTOT_LIN++
   nTOT_BLOCO9++
   cSPED := "|9900|I050|"+alltrim(str(nTOT_I050)) +"|"
   write(nFile,cSPED,len(cSPED))
   cSPED := ""
   
   nTOT_LIN++
   nTOT_BLOCO9++
   cSPED := "|9900|I052|"+alltrim(str(nTOT_I052)) +"|"
   write(nFile,cSPED,len(cSPED))
   cSPED := ""

   nTOT_LIN++
   nTOT_BLOCO9++
   cSPED := "|9900|I150|"+alltrim(str(nTOT_I150)) +"|"
   write(nFile,cSPED,len(cSPED))
   cSPED := ""

   nTOT_LIN++
   nTOT_BLOCO9++
   cSPED := "|9900|I155|"+alltrim(str(nTOT_I155)) +"|"
   write(nFile,cSPED,len(cSPED))
   cSPED := ""

   nTOT_LIN++
   nTOT_BLOCO9++
   cSPED := "|9900|I200|"+alltrim(str(nTOT_I200)) +"|"
   write(nFile,cSPED,len(cSPED))
   cSPED := ""

   nTOT_LIN++
   nTOT_BLOCO9++
   cSPED := "|9900|I250|"+alltrim(str(nTOT_I250)) +"|"
   write(nFile,cSPED,len(cSPED))
   cSPED := ""
   
   nTOT_LIN++
   nTOT_BLOCO9++
   cSPED := "|9900|I350|"+alltrim(str(nTOT_I350)) +"|"
   write(nFile,cSPED,len(cSPED))
   cSPED := ""
   
   nTOT_LIN++
   nTOT_BLOCO9++
   cSPED := "|9900|I355|"+alltrim(str(nTOT_I355)) +"|"
   write(nFile,cSPED,len(cSPED))
   cSPED := ""

   nTOT_LIN++
   nTOT_BLOCO9++
   cSPED := "|9900|I990|"+alltrim(str(1)) +"|"
   write(nFile,cSPED,len(cSPED))
   cSPED := ""

   nTOT_LIN++
   nTOT_BLOCO9++
   cSPED := "|9900|J001|"+alltrim(str(1)) +"|"
   write(nFile,cSPED,len(cSPED))
   cSPED := ""

   nTOT_LIN++
   nTOT_BLOCO9++
   cSPED := "|9900|J005|"+alltrim(str(nTOT_J005)) +"|"
   write(nFile,cSPED,len(cSPED))
   cSPED := ""

   nTOT_LIN++
   nTOT_BLOCO9++
   cSPED := "|9900|J100|"+alltrim(str(nTOT_J100)) +"|"
   write(nFile,cSPED,len(cSPED))
   cSPED := ""
   
   nTOT_LIN++
   nTOT_BLOCO9++
   cSPED := "|9900|J150|"+alltrim(str(nTOT_J150)) +"|"
   write(nFile,cSPED,len(cSPED))
   cSPED := ""


   nTOT_LIN++
   nTOT_BLOCO9++
   cSPED := "|9900|J900|"+alltrim(str(1)) +"|"
   write(nFile,cSPED,len(cSPED))
   cSPED := ""

   nTOT_LIN++
   nTOT_BLOCO9++
   cSPED := "|9900|J930|"+alltrim(str(3)) +"|"
   write(nFile,cSPED,len(cSPED))
   cSPED := ""

   nTOT_LIN++
   nTOT_BLOCO9++
   cSPED := "|9900|J990|"+alltrim(str(1)) +"|"
   write(nFile,cSPED,len(cSPED))
   cSPED := ""

   nTOT_LIN++
   nTOT_BLOCO9++
   cSPED := "|9900|9001|"+alltrim(str(1)) +"|"
   write(nFile,cSPED,len(cSPED))
   cSPED := ""

   nTOT_LIN++
   nTOT_BLOCO9++
   cSPED := "|9900|9900|"+alltrim(str(27)) +"|"
   write(nFile,cSPED,len(cSPED))
   cSPED := ""

   nTOT_LIN++
   nTOT_BLOCO9++
   cSPED := "|9900|9990|"+alltrim(str(1)) +"|"
   write(nFile,cSPED,len(cSPED))
   cSPED := ""

   nTOT_LIN++
   nTOT_BLOCO9++
   cSPED := "|9900|9999|"+alltrim(str(1)) +"|"
   write(nFile,cSPED,len(cSPED))
   cSPED := ""


   nTOT_LIN++
   nTOT_BLOCO9++
   cSPED := "|9990"
   cSPED += "|"+alltrim(str(nTOT_BLOCO9+1))
   cSPED += "|"
   write(nFile,cSPED,len(cSPED))
   cSPED := ""

   nTOT_LIN++
   nTOT_BLOCO9++
   cSPED := "|9999"
   cSPED += "|"+alltrim(str(nTOT_LIN))
   cSPED += "|"
   write(nFile,cSPED,len(cSPED))
   cSPED := ""

return



static function searchSuperior(cCONTA)
  local cRESULT := ""
  local nREG := PLAN->(recno())

  do case
     case len(alltrim(cCONTA)) == 12
           PLAN->(dbseek(left(cCONTA,7)))
           cRESULT := PLAN->Codigo
           PLAN->(dbgoto(nREG))

     case len(alltrim(cCONTA)) == 7
           PLAN->(dbseek(left(cCONTA,5)))
           cRESULT := PLAN->Codigo
           PLAN->(dbgoto(nREG))

     case len(alltrim(cCONTA)) == 5
           PLAN->(dbseek(left(cCONTA,3)))
           cRESULT := PLAN->Codigo
           PLAN->(dbgoto(nREG))

     case len(alltrim(cCONTA)) == 3
           PLAN->(dbseek(left(cCONTA,1)))
           cRESULT := PLAN->Codigo
           PLAN->(dbgoto(nREG))

     case len(alltrim(cCONTA)) == 1
           cRESULT := ""
           PLAN->(dbgoto(nREG))

  endcase

return cRESULT


static function i_puxasaldo(nMES)
local nSaldant  := 0
local nDebitos  := 0
local nCreditos := 0
local nCONT     := 0

       nSALDANT := PLAN->Saldo_ant  //getSaldoAbertura(PLAN->Reduzido)

       for nCONT = 1 to nMES

           nDebitos  := 0
           nCreditos := 0

           //if nCONT == 1
           //   if left(PLAN->Nat_cont,2) == "AT"
           //      nDebitos  += getSaldoAbertura(PLAN->Reduzido)*-1
           //   endif

           //   if left(PLAN->Nat_cont,2) == "PS"
           //      nCreditos += getSaldoAbertura(PLAN->Reduzido)*-1
           //   endif
           //endif

           cDEB := "DB"+strzero(nCONT,2)
           cCRE := "CR"+strzero(nCONT,2)

           nDebitos  += PLAN->&cDEB
           nCreditos += PLAN->&cCRE

           if nCONT != nMES
              nSALDANT := nSALDANT + nDebitos + nCreditos
           endif
       next

return round(nSAldAnt,2)


static function setSaldoAbertura(cOPT)
local nSaldant := 0
local nIndexOf := 0
local nValor   := 0

  LANC->(dbsetfilter({|| hp1 == "108"}))
  LANC->(dbgotop())

  do While ! LANC->(eof())

     if cOPT == "S"
        i_propagacao("E")
     else
        i_propagacao("I")
     endif

     LANC->(dbskip())
  enddo

  LANC->(dbclearfilter())
  LANC->(dbgotop())


return



static function i_temMovimentoMes(nMES)
local cRESULT  := .F.
local nTotDeb  := 0
local nTotCred := 0
local nSAldant:= 0

       nSALDANT := PLAN->Saldo_ant //getSaldoAbertura(PLAN->Reduzido)

       for nCONT = 1 to nMES

           nDebitos  := 0
           nCreditos := 0

           //if nCONT == 1
           //   if left(PLAN->Nat_cont,2) == "AT"
           //      nDebitos  += getSaldoAbertura(PLAN->Reduzido)*-1
           //   endif
           //
           //   if left(PLAN->Nat_cont,2) == "PS"
           //      nCreditos += getSaldoAbertura(PLAN->Reduzido)*-1
           //   endif
           //endif

           cDEB := "DB"+strzero(nCONT,2)
           cCRE := "CR"+strzero(nCONT,2)

           nDebitos  += PLAN->&cDEB
           nCreditos += PLAN->&cCRE

           if nCONT != nMES
              nSALDANT := nSALDANT + nDebitos + nCreditos
           endif
       next


       cDEB := "DB"+strzero(nMES,2)
       cCRE := "CR"+strzero(nMES,2)

       nTotDeb  += PLAN->&cDEB
       nTotCred += PLAN->&cCRE

       if round(nTotDeb,2) <> 0.00 .or. round(nTotCred,2) <> 0.00 .or. round(nSaldant,2) <> 0.00
          cRESULT := .T.
       endif

return cRESULT


static function data_sped(dDATA)
 local cDATA, cANO,cMES,cDIA := ""
 cANO := strzero(year(dDATA),4)
 cMES := strzero(month(dDATA),2)
 cDIA := strzero(day(dDATA),2)
 cDATA:= cDIA + cMES + cANO
return  cDATA


static function getNivel(cCONTA)
  local nNivel := ""

  do case
     case len(alltrim(cCONTA)) == 12
          nNivel := "5"

     case len(alltrim(cCONTA)) == 7
          nNivel := "4"

     case len(alltrim(cCONTA)) == 5
          nNivel := "3"

     case len(alltrim(cCONTA)) == 3
          nNivel := "2"

     case len(alltrim(cCONTA)) == 1
          nNivel := "1"

  endcase

return nNivel

static function maskCod(cCONTA,cNIVEL)
  local cResult := ""

  do case
     case len(alltrim(cCONTA)) == 12
          cResult := transf(cCONTA,"@R 9.99.99.99.9999-9")

     case len(alltrim(cCONTA)) == 7
          cResult := transf(cCONTA,"@R 9.99.99.99")

     case len(alltrim(cCONTA)) == 5
          cResult := transf(cCONTA,"@R 9.99.99")

     case len(alltrim(cCONTA)) == 3
          cResult := transf(cCONTA,"@R 9.99")

     case len(alltrim(cCONTA)) == 1
          cResult := transf(cCONTA,"@R 9")

  endcase

return cResult


static Function i_valida(nVALOR,nNUM)
local cValor   := ""
local cInteiro := ""
local cDecimal := ""
   cDecimal := right(strzero(val(qtiraponto(str(nVALOR,nNUM,2))),nNUM),2)
   cInteiro := strzero(int(nValor),16)
   cValor := cInteiro +"," + cDecimal

return cVALOR

static function grava_saldo ( cCONTA , nVALOR , cMACRO )
   local nREC := PLAN->(recno())
   local nORD := PLAN->(indexord())
   local nNEG

   PLAN->(dbsetorder(1))

   cCONTA := alltrim(cCONTA)

   iif(len(cCONTA)==6,cCONTA:=ct_conv_re(cCONTA),)

   if empty(cMACRO)
      nNEG := 1
   else
      nNEG := iif("CR"$cMACRO,-1,1)
   endif

   if empty(cMACRO) .or. "SALDO" $ cMACRO
      cMACRO := "SALDO_ANT"
   endif

   if cMACRO <> "SALDO_ANT" .or. (len(cCONTA) <> 12 .and. cMACRO == "SALDO_ANT")
      if PLAN->(dbseek(padr(cCONTA,12," ")))
         if PLAN->(qrlock(recno()))
            PLAN->&(cMACRO) := PLAN->&(cMACRO) + nVALOR * nNEG
            PLAN->Saldo_ant := PLAN->Saldo_ant - nVALOR * nNEG


            PLAN->(dbrunlock(recno()))

         endif
      endif
   endif

   if "SALDO" $ cMACRO
      cMACRO := cMACRO + iif(nNEG<0,"_CR","_DB")
   endif

   PLAN->(dbsetorder(nORD))
   PLAN->(dbgoto(nREC))
return

static function i_propagacao ( cOPT )

   do case

      // ATUALIZA SALDOS NA INCLUSAO E DUPLICACAO ___________________________

      case cOPT $ "ID"
           if ! empty(LANC->cont_db)
              grava_saldo(LANC->cont_db,LANC->Valor,"DB"+strzero(month(LANC->Data_lanc),2))
           endif

           if ! empty(LANC->cont_cr)

              grava_saldo(LANC->cont_cr,LANC->Valor,"CR"+strzero(month(LANC->Data_lanc),2))
           endif

      // ATUALIZA SALDOS NA EXCLUSAO ________________________________________

      case cOPT == "E"
           if ! empty(LANC->Cont_db)
              grava_saldo(LANC->Cont_db,LANC->Valor*-1,"DB"+strzero(month(LANC->Data_lanc),2))
           endif
           if ! empty(LANC->Cont_cr)
              grava_saldo(LANC->Cont_cr,LANC->Valor*-1,"CR"+strzero(month(LANC->Data_lanc),2))
           endif

   endcase

return

static function MultiPartida
local nIndexOf   := 0
local nDeb       := 0
local nCre       := 0
local dData      := ctod("")
local nReg := 0
local nCONT := 0

   aDatas   := {}
   aValores := {}

   LANC->(dbsetfilter({|| LANC->hp1 != "108" .and. (empty(LANC->Cont_db)  .or. empty(LANC->cont_cr) ) }))
   LANC->(dbsetorder(1))
   LANC->(dbgotop())

   dDATA :=  LANC->Data_lanc
   nDeb := nCre := 0

   do while ! LANC->(eof())

      if !empty(LANC->Cont_db)
         nDeb     += LANC->Valor
      endif

      if !empty(LANC->Cont_cr)
         nCre     += LANC->Valor
      endif

      LANC->(dbskip())

      if LANC->Data_lanc != dData

         if Round(nDeb,2) == Round(nCre,2)
            aadd(aDatas,dData)
            aadd(aValores,{dData,round(nDeb,2),strzero(len(aDatas),5)})
         else
            qmensa("Data: "+dtoc(dDATA)+" D..: "+transf(nCre,"@E 999,999.9999")+" C.: "+transf(nDeb,"@E 999,999.9999") )
            qinkey(0)
         endif

         nCre := 0
         nDeb := 0
         dData := LANC->Data_lanc
      endif

   enddo

   if nCre <> 0 .or. nDeb <> 0
      if round(nCre,2) == round(nDeb,2)
         aadd(aDatas,dData)
         aadd(aValores,{dData,round(nDeb,2),strzero(len(aDatas),5)})
      endif
   endif

   nCre := 0
   nDeb := 0


   LANC->(dbgotop())
   do while ! LANC->(eof())

      nIndexOf := aScan(aDatas,LANC->Data_lanc)
      if nIndexOf > 0
         if LANC->Data_lanc == aDatas[nIndexOf]
            if LANC->(qrlock())
               replace LANC->No_partida with strzero(nIndexOf,5)
               LANC->(qunlock())
            endif

            LANC->(qpublicFields())
            LANC->(qcopyFields())
            fCod_Lanc := strzero(nIndexOf,5)
            if ITN_LANC->(qappend())
               ITN_LANC->(qreplacefields())
            endif
            LANC->(qreleaseFields())
         endif
      endif

      LANC->(dbskip())
   enddo

   LANC->(dbclearfilter())
   LANC->(dbgotop())

   if len(aValores) > 0

      for nCONT := 1 to len(aValores)
          if LANC->(qappend())
             replace LANC->Data_lanc with aValores[nCONT,1]
             replace LANC->Cont_db   with "FANTOM"
             replace LANC->Cont_cr   with "FANTOM"
             replace LANC->Valor     with aValores[nCONT,2]
             replace LANC->Hist_comp with "Lancamento pra Atualizar Multiplas partidas"
             replace LANC->Cod_lanc  with aValores[nCONT,3]
          endif
      next

   endif
   LANC->(dbgotop())

return

static function delRegFantasma

    LANC->(dbclearfilter())
    LANC->(dbsetfilter({|| ! empty(Cod_lanc)}))
    LANC->(dbgotop())

    if LANC->(qflock())

       do while ! LANC->(eof())
          LANC->(dbdelete())
          LANC->(dbskip())
       enddo

       LANC->(qunlock())
    endif

    LANC->(dbclearfilter())
    LANC->(dbgotop())



return

static function i_abre
local lresult := .F.
local cChr   := ""
local cLinha := ""
local nLen := fseek(nFile,0,FS_END)
local nLineLen := 0
local nPos := 0
local cWrite := 0
local nBytestoRead := 0
local cProxLine := 0
local lSair := .T.

      fseek(nFile,0,FS_SET)
      do while lsair

         cChr := freadstr(nfile,1)
         nPos := fPos(nFile)
         nLineLen++
         if cChr == chr(10)
            fseek(nFile,nLineLen*-1,FS_RELATIVE)            //Achou eol, volta ao inicio do registro
            cLinha := freadstr(nFile,nLineLen)              // Le a linha toda - ptr esta posicionado no ultimo chr da linha
			

            if left(cLinha,5) == "|I030"
               nBytesToRead := len(alltrim(str(nTOT_LIN)))     //encontra qntos chrs estao sendo sobrepostos com o novo valor
               cProxLine := freadstr(nFile,nBytesToRead)//le os caracteres que seriam sobrepostos
               fseek(nFile,nBytesToRead*-1,FS_RELATIVE)        //voltao ptr pra onde estava

               cWrite := "|I030|TERMO DE ABERTURA|"+alltrim(str(val(cLIVRO)))+"|DIARIO GERAL" //Termo de Abertura
               cWrite += "|"+alltrim(str(nTOT_LIN))
               cWrite += "|"+rtrim(FILIAL->Razao)
               //cWrite += "|"+strtran(alltrim(CONFIG->Num_junta),".","")
               cWrite += "|"
               cWrite += "|"+FILIAL->Cgccpf
               cWrite += "|"+data_sped(CONFIG->Data_junta)
               cWrite += "|"
               CGM->(Dbseek(FIlial->Cgm))
               cWrite += "|"+ rtrim(CGM->Municipio)
               cWrite += "|"+data_sped(dFIM)
               cWrite += "|"
               cWrite += chr(13)+chr(10)+cProxLine
               fseek(nFile,(nLineLen)*-1,FS_RELATIVE)
               fwrite(nFile,cWrite,len(cWrite))
               lSair := .F.
            endif
            nLineLen := 0
         endif

      enddo

return

static function i_encerra
local lresult := .F.
local cChr   := ""
local cLinha := ""
local nLen := fseek(nFile,0,FS_END)
local nLineLen := 0
local nPos := 0
local cWrite := 0
local nBytestoRead := 0
local cProxLine := 0
local lSair := .T.

      fseek(nFile,-1500,FS_END)
      do while lsair

         cChr := freadstr(nfile,1)
         nPos := fPos(nFile)
         nLineLen++
         if cChr == chr(10)
            fseek(nFile,nLineLen*-1,FS_RELATIVE)            //Achou eol, volta ao inicio do registro
            cLinha := freadstr(nFile,nLineLen)              // Le a linha toda - ptr esta posicionado no ultimo chr da linha

            if left(cLinha,5) == "|J900"
               cWRITE := "|J900|TERMO DE ENCERRAMENTO|"+alltrim(str(val(cLIVRO)))+"|DIARIO GERAL"
               cWRITE += "|"+rtrim(FILIAL->Razao)
               cWRITE += "|"+alltrim(str(nTOT_LIN))
               cWRITE += "|"+data_sped(dINI)
               cWRITE += "|"+data_sped(dFIM)
               cWRITE += "|"+chr(13)+chr(10)
               fseek(nFile,(nLineLen+nBytesToRead)*-1,FS_RELATIVE)
               fwrite(nFile,cWrite,len(cWrite))
               lSair := .F.
            endif
            nLineLen := 0
         endif

      enddo

return


static function fPos(nHnd)
return fseek(nHnd,0,FS_RELATIVE)

static function Write(nFile,cSped,nBytes)

   if SPED->(QAppend())
      SPED->Linha := cSPED
      cSPED := ""
   endif

return

static function geraTxt
local cWrite := ""
local nHnd := 0

   SPED->(dbgotop())

   SPED->(dbgoto(7))
   if left(SPED->Linha,5) == "|I030"
      if SPED->(qrlock())
         cWrite := "|I030|TERMO DE ABERTURA|"+alltrim(str(val(cLIVRO)))+"|DIARIO GERAL" //Termo de Abertura
         cWrite += "|"+alltrim(str(nTOT_LIN))
         cWrite += "|"+rtrim(FILIAL->Razao)
         //cWrite += "|"+strtran(alltrim(CONFIG->Num_junta),".","")
         cWrite += "|"
         cWrite += "|"+FILIAL->Cgccpf
         cWrite += "|"+data_sped(CONFIG->Data_junta)
         cWrite += "|"
         CGM->(Dbseek(FIlial->Cgm))
         cWrite += "|"+ rtrim(CGM->Municipio)
         cWrite += "|"+data_sped(dFIM)
         cWrite += "|"

         replace SPED->Linha with cWrite
         SPED->(Qunlock())
      endif
   endif
   
   
   voltaLinhas := 34 
   voltaLinhas := voltaLinhas *(-1)
   


   SPED->(dbgobottom())
   SPED->(dbskip(voltaLinhas))
   alert(SPED->Linha)
   
   if left(SPED->Linha,5) == "|J900"
      if SPED->(qrlock())
         cWRITE := "|J900|TERMO DE ENCERRAMENTO|"+alltrim(str(val(cLIVRO)))+"|DIARIO GERAL"
         cWRITE += "|"+rtrim(FILIAL->Razao)
         cWRITE += "|"+alltrim(str(nTOT_LIN))
         cWRITE += "|"+data_sped(dINI)
         cWRITE += "|"+data_sped(dFIM)
         cWRITE += "|"
         replace SPED->Linha with cWrite
         SPED->(Qunlock())
      endif
   endif

   nHnd := fcreate("C:\qsystxt\ecd_qsys.txt",FC_NORMAL)

   SPED->(dbgotop())
   do while ! SPED->(eof())
      fwrite(nHnd,rtrim(SPED->Linha)+chr(13)+chr(10),len(rtrim(SPED->Linha))+2)
      SPED->(dbskip())
   enddo

   fclose(nHnd)




return


static function balanco
local cSPED    := ""
local cNIVEL := ""

   PLAN->(dbsetfilter({|| left(Codigo,1)  $ "12"}))
   PLAN->(dbsetorder(1))
   PLAN->(dbgotop())


   do while ! PLAN->(eof())

       cNIVEL := getNivel(PLAN->Codigo)       
	   nValor := i_puxaatps()
	   nSaldo_ant := i_puxasaldo(1)
	   
	   //if ! empty(PLAN->Reduzido)
		//	PLAN->(dbskip())
		//	loop
	   //endif
	     

	   if nValor <> 0
			cSPED := "|J100"
			cSPED += "|"+maskCod(alltrim(PLAN->Codigo))
			cSPED += "|"+cNIVEL
			cSPED += "|"+left(PLAN->Codigo,1)
			cSPED += "|"+ rtrim(PLAN->Descricao)
       
			cSPED += "|"+i_valida(iif(nValor < 0,nValor*(-1),nValor),19)
			if nValor < 0
				cSIT := "C"
		    else
				cSIT := "D"
			endif
			cSPED += "|"+cSIT
			cSPED += "|"+i_valida(iif(nSaldo_ant < 0,nSaldo_ant*(-1),nSaldo_ant),19)
			
			if nSaldo_ant < 0
				cSIT := "C"
		    else
				cSIT := "D"
			endif
			cSPED += "|"+cSIT+"|"
			write(nFILE,cSPED,len(cSPED))
	 
			nTOT_LIN++
			nTOT_BLOCOJ++
			nTOT_J100++
		endif	

      PLAN->(dbskip())

   enddo

return


static function getAglutinacao(cCONTA)
  local nNivel := ""

  do case
     case len(alltrim(cCONTA)) == 12
          nNivel := "5"

     case len(alltrim(cCONTA)) == 7
          nNivel := "4"

     case len(alltrim(cCONTA)) == 5
          nNivel := "3"

     case len(alltrim(cCONTA)) == 3
          nNivel := "2"

     case len(alltrim(cCONTA)) == 1
          nNivel := "1"

  endcase


return

static function i_puxaatps
   local nCONT :=1
   local nSaldo := 0

   nSALDO := PLAN->Saldo_ant
   for nCONT = 1 to 12
       cDEB := "DB"+strzero(nCONT,2)
       cCRE := "CR"+strzero(nCONT,2)
      // if nCONT != 12
          nSALDO += PLAN->&cDEB
          nSALDO += PLAN->&cCRE
      // endif
   next
return nSALDO



static function dre_romero
   local nREC_LIQ := nREC_OPER := nDEDUCOES := 0
   local nLUC_BRUTO := nCUST_OPER := 0
   local nLUC_LIQ  := nLUC_BRUTO := nDESP_PESS := nDESP_ADM := nDESP_GER := nDESP_FIN := 0
   local nRESULTADO := nLUC_LIQ := nREC_DESP := 0
   local nLUCRO := nRESULTADO := nPROV_DIV := 0
   local nDespesas := 0
   local cSPED    := ""
   local cCOMBINA := ""

   cCOMBINA := ""
   
   PLAN->(dbclearfilter())
   PLAN->(dbsetorder(3))
   PLAN->(dbgotop())
   
   RESULTAD->(dbsetorder(1))
   RESULTAD->(dbgotop())
   
   do while ! RESULTAD->(eof())

      qgirabarra()
      if left(RESULTAD->Codigo,1) == "1" .and. right(RESULTAD->Codigo,2) != "  "
         cCOMBINA += alltrim(RESULTAD->Combina2)
         nREC_OPER := nREC_OPER + i_maismenos(cCOMBINA)
      endif

      if left(RESULTAD->Codigo,1) == "2" .and. right(RESULTAD->Codigo,2) != "  "
         cCOMBINA += alltrim(RESULTAD->Combina2)
         nDEDUCOES += i_maismenos(cCOMBINA)
      endif

      if left(RESULTAD->Codigo,1) == "3" .and. right(RESULTAD->Codigo,2) != "  "
         cCOMBINA += alltrim(RESULTAD->Combina2)
         nCUST_OPER += i_maismenos(cCOMBINA)
      endif

      if left(RESULTAD->Codigo,1) == "4" .and. right(RESULTAD->Codigo,2) != "  "
         cCOMBINA += alltrim(RESULTAD->Combina2)
         nDESP_PESS += i_maismenos(cCOMBINA)
      endif

      if left(RESULTAD->Codigo,1) == "5" .and. right(RESULTAD->Codigo,2) != "  "
         cCOMBINA += alltrim(RESULTAD->Combina2)
         nDESP_ADM += i_maismenos(cCOMBINA)
      endif

      if left(RESULTAD->Codigo,1) == "6" .and. right(RESULTAD->Codigo,2) != "  "
         cCOMBINA += alltrim(RESULTAD->Combina2)
         nDESP_GER += i_maismenos(cCOMBINA)
      endif

      if left(RESULTAD->Codigo,1) == "7" .and. right(RESULTAD->Codigo,2) != "  "
         cCOMBINA += alltrim(RESULTAD->Combina2)
         nDESP_FIN += i_maismenos(cCOMBINA)
      endif

      if left(RESULTAD->Codigo,1) == "8" .and. right(RESULTAD->Codigo,2) != "  "
         cCOMBINA += alltrim(RESULTAD->Combina2)
         nREC_DESP += i_maismenos(cCOMBINA)
      endif

      if left(RESULTAD->Codigo,1) == "9" .and. right(RESULTAD->Codigo,2) != "  "
         cCOMBINA += alltrim(RESULTAD->Combina2)
         nPROV_DIV += i_maismenos(cCOMBINA)
      endif

      RESULTAD->(dbskip())
      cCOMBINA := ""

   enddo
   
   nREC_LIQ := nREC_OPER + nDEDUCOES
   nLUC_BRUTO := nREC_LIQ + nCUST_OPER
   nDespesas := (nDESP_PESS + nDESP_ADM + nDESP_GER + nDESP_FIN)
   nLUC_LIQ  := nLUC_BRUTO + (nDESP_PESS + nDESP_ADM + nDESP_GER + nDESP_FIN)
   nRESULTADO := nLUC_LIQ + nREC_DESP
   nLUCRO := nRESULTADO + nPROV_DIV
   
   
   
   RESULTAD->(dbsetorder(1))
   RESULTAD->(dbgotop())
   do while ! RESULTAD->(eof())
	  
	  
	  /*if RESULTAD->Codigo == "1  "
	     cSPED := "|J150"	
	     cSPED += "|3.01.01"	
		 cSPED += "|3"
         cSPED += "|RECEITAS"
		 cSPED += "|"+i_valida(nREC_OPER,19)
		 cSPED += "|"+"P"
		 cSPED += "|"
		
		 write(nFILE,cSPED,len(cSPED))
	     cSPED := ""
		 nTOT_LIN++
	     nTOT_BLOCOJ++
		 nTOT_J150++
      endif*/


      if RESULTAD->Tipo == "1"

         if RESULTAD->Codigo == "1  "
            //@ prow()+1,nCOL1 say RESULTAD->Titulo
            //@ prow()  ,nCOL4 say transform(abs(nREC_OPER),"@E 9,999,999,999.99")
			
			cSPED := "|J150"	
			cSPED += "|3.01.01.01"
			cSPED += "|0"			
			cSPED += "|"+rtrim(RESULTAD->Titulo)
			cSPED += "|"+i_valida(abs(nREC_OPER),19)
			cSPED += "|"+"P"
			cSPED += "|"
			write(nFILE,cSPED,len(cSPED))
			cSPED := ""
			nTOT_LIN++
			nTOT_BLOCOJ++
			nTOT_J150++

         elseif RESULTAD->Codigo == "2  "
            //@ prow()+1,nCOL1 say RESULTAD->Titulo
            //@ prow()  ,nCOL4 say transform(abs(nDEDUCOES),"@E 9,999,999,999.99")
			cSPED := "|J150"	
			cSPED += "|3.01.01.02"	
			cSPED += "|0"
			cSPED += "|"+rtrim(RESULTAD->Titulo)
			cSPED += "|"+i_valida(abs(nDEDUCOES),19)
			cSPED += "|"+"P"
			cSPED += "|"
			
			write(nFILE,cSPED,len(cSPED))
			cSPED := ""
			nTOT_LIN++
			nTOT_BLOCOJ++
			nTOT_J150++

         elseif RESULTAD->Codigo == "3  "
            //@ prow()+1,03 say "(=)RECEITA LIQUIDA.................................................................."
            //@ prow()  ,nCOL4 say transform(nREC_LIQ ,"@E@) 9,999,999,999.99")
			cSPED := "|J150"	
			cSPED += "|"	
			cSPED += "|0"
			cSPED += "|"+"(=)RECEITA LIQUIDA"
			cSPED += "|"+i_valida(abs(nREC_LIQ),19)
			cSPED += "|"+"P"
			cSPED += "|"
			write(nFILE,cSPED,len(cSPED))
			cSPED := ""
			nTOT_LIN++
			nTOT_BLOCOJ++
			nTOT_J150++
			
            //@ prow()+1,03 say "(-)CUSTOS"

			cSPED := "|J150"	
			cSPED += "|3.01.02"	
			cSPED += "|0"
			cSPED += "|"+"(-)CUSTOS"
			cSPED += "|"+i_valida(0,19)
			cSPED += "|"+"N"
			cSPED += "|"
			write(nFILE,cSPED,len(cSPED))
			cSPED := ""
			nTOT_LIN++
			nTOT_BLOCOJ++
			nTOT_J150++
			
			//@ prow()+1,nCOL1 say RESULTAD->Titulo
			
			cSPED := "|J150"	
			cSPED += "|3.01.02.01"	
			cSPED += "|0"
			cSPED += "|"+rtrim(RESULTAD->Titulo)
			cSPED += "|"+i_valida(abs(nCUST_OPER),19)
			cSPED += "|"+"P"
			cSPED += "|"
			write(nFILE,cSPED,len(cSPED))
			cSPED := ""
			nTOT_LIN++
			nTOT_BLOCOJ++
			nTOT_J150++

            //@ prow()  ,nCOL4 say transform(abs(nCUST_OPER),"@E 9,999,999,999.99")

         elseif RESULTAD->Codigo == "4  "
            //@ prow()+1,03 say "(=)LUCRO BRUTO......................................................................"
            //@ prow()  ,nCOL4 say transform(nLUC_BRUTO     ,"@E@) 9,999,999,999.99")
			cSPED := "|J150"	
			cSPED += "|"	
			cSPED += "|0"
			cSPED += "|"+"(=)LUCRO BRUTO"
			cSPED += "|"+i_valida(abs(nLUC_BRUTO),19)
			cSPED += "|"+"P"
			cSPED += "|"
			write(nFILE,cSPED,len(cSPED))
			cSPED := ""
			nTOT_LIN++
			nTOT_BLOCOJ++
			nTOT_J150++
			
			/*
            //@ prow()+1,03 say "DESPESAS"
			cSPED := "|J150"	
			cSPED += "|3.01.03"	
			cSPED += "|3"
			cSPED += "|"+"DESPESAS"
			
			cSPED += "|"+i_valida(abs(nDespesas),19)
			cSPED += "|"+"N"
			cSPED += "|"
			write(nFILE,cSPED,len(cSPED))
			cSPED := ""
			nTOT_LIN++
			nTOT_BLOCOJ++
			nTOT_J150++*/
            
			
			//@ prow()+1,nCOL1 say RESULTAD->Titulo
			
			cSPED := "|J150"	
			cSPED += "|3.01.03.01"
			cSPED += "|0"			
			cSPED += "|"+rtrim(RESULTAD->Titulo)
			
			cSPED += "|"+i_valida(abs(nDESP_PESS),19)
			cSPED += "|"+"P"
			cSPED += "|"
			write(nFILE,cSPED,len(cSPED))
			cSPED := ""
			nTOT_LIN++
			nTOT_BLOCOJ++
			nTOT_J150++

            //@ prow()  ,nCOL4 say transform(abs(nDESP_PESS),"@E 9,999,999,999.99")

         elseif RESULTAD->Codigo == "5  "
            //@ prow()+1,nCOL1 say RESULTAD->Titulo
            //@ prow()  ,nCOL4 say transform(abs(nDESP_ADM),"@E 9,999,999,999.99")
			
			cSPED := "|J150"	
			cSPED += "|3.01.03.02"	
			cSPED += "|0"
			cSPED += "|"+rtrim(RESULTAD->Titulo)
			
			cSPED += "|"+i_valida(abs(nDESP_ADM),19)
			cSPED += "|"+"P"
			cSPED += "|"
			write(nFILE,cSPED,len(cSPED))
			cSPED := ""
			nTOT_LIN++
			nTOT_BLOCOJ++
			nTOT_J150++

         elseif RESULTAD->Codigo == "6  "
            //@ prow()+1,nCOL1 say RESULTAD->Titulo
            //@ prow()  ,nCOL4 say transform(abs(nDESP_GER),"@E 9,999,999,999.99")
			cSPED := "|J150"	
			cSPED += "|3.01.03.03"	
			cSPED += "|0"
			cSPED += "|"+rtrim(RESULTAD->Titulo)
			
			cSPED += "|"+i_valida(abs(nDESP_GER),19)
			cSPED += "|"+"P"
			cSPED += "|"
			write(nFILE,cSPED,len(cSPED))
			cSPED := ""
			nTOT_LIN++
			nTOT_BLOCOJ++
			nTOT_J150++

         elseif RESULTAD->Codigo == "7  "
            //@ prow()+1,nCOL1 say RESULTAD->Titulo
            //@ prow()  ,nCOL4 say transform(abs(nDESP_FIN),"@E 9,999,999,999.99")
			cSPED := "|J150"	
			cSPED += "|3.01.03.04"	
			cSPED += "|0"
			cSPED += "|"+rtrim(RESULTAD->Titulo)
			
			cSPED += "|"+i_valida(abs(nDESP_FIN),19)
			cSPED += "|"+"P"
			cSPED += "|"
			write(nFILE,cSPED,len(cSPED))
			cSPED := ""
			nTOT_LIN++
			nTOT_BLOCOJ++
			nTOT_J150++

         elseif RESULTAD->Codigo == "8  "
            //@ prow()+1,03 say "(=)LUCRO LIQUIDO....................................................................."
            //@ prow(),nCOL4 say transform(nLUC_LIQ ,"@E@) 9,999,999,999.99")
			cSPED := "|J150"	
			cSPED += "|"	
			cSPED += "|0"
			cSPED += "|"+"(=)LUCRO LIQUIDO"
			
			cSPED += "|"+i_valida(abs(nLUC_LIQ),19)
			cSPED += "|"+"N"
			cSPED += "|"
			write(nFILE,cSPED,len(cSPED))
			cSPED := ""
			nTOT_LIN++
			nTOT_BLOCOJ++
			nTOT_J150++

            //@ prow()+1,nCOL1 say RESULTAD->Titulo
            //@ prow()  ,nCOL4 say transform(abs(nREC_DESP),"@E 9,999,999,999.99")
			cSPED := "|J150"	
			cSPED += "|3.01.03.05"	
			cSPED += "|0"
			cSPED += "|"+rtrim(RESULTAD->Titulo)
			
			cSPED += "|"+i_valida(abs(nREC_DESP),19)
			cSPED += "|"+"P"
			cSPED += "|"
			write(nFILE,cSPED,len(cSPED))
			cSPED := ""
			nTOT_LIN++
			nTOT_BLOCOJ++
			nTOT_J150++

         elseif RESULTAD->Codigo == "9  "
            //@ prow()+1,03 say "(=)RESULTADO ANTES DAS PROVISOES/DIVIDENDOS............................................"
            //@ prow(),nCOL4 say transform(nRESULTADO ,"@E@) 9,999,999,999.99")
			cSPED := "|J150"	
			cSPED += "|"	
			cSPED += "|0"
			cSPED += "|"+"(=)RESULTADO ANTES DAS PROVISOES/DIVIDENDOS"
			
			cSPED += "|"+i_valida(abs(nRESULTADO),19)
			cSPED += "|"+"N"
			cSPED += "|"
			write(nFILE,cSPED,len(cSPED))
			cSPED := ""
			nTOT_LIN++
			nTOT_BLOCOJ++
			nTOT_J150++
            
			//@ prow()+1,nCOL1 say RESULTAD->Titulo
            //@ prow()  ,nCOL4 say transform(abs(nPROV_DIV),"@E 9,999,999,999.99")
			
			cSPED := "|J150"	
			cSPED += "|3.01.03.06"	
			cSPED += "|0"
			cSPED += "|"+rtrim(RESULTAD->Titulo)
			
			cSPED += "|"+i_valida(abs(nPROV_DIV),19)
			cSPED += "|"+"N"
			cSPED += "|"
			write(nFILE,cSPED,len(cSPED))
			cSPED := ""
			nTOT_LIN++
			nTOT_BLOCOJ++
			nTOT_J150++
         endif

      else
         i_compact()
      endif
	 
	 
   
  	  RESULTAD->(dbskip())
      cCOMBINA := ""
   enddo
   
   //@ prow()+1,03 say "(=) LUCRO /PREJUIZO DO EXERCICIO........................................................."
   //@ prow()  ,nCOL4 say transform(nLUCRO ,"@E@) 9,999,999,999.99")
   cSPED := "|J150"	
   cSPED += "|"	
   cSPED += "|0"
   cSPED += "|"+"(=) LUCRO /PREJUIZO DO EXERCICIO"
	
	cSPED += "|"+i_valida(abs(nLUCRO),19)
	cSPED += "|"+"N"
	cSPED += "|"
	write(nFILE,cSPED,len(cSPED))
	cSPED := ""
	nTOT_LIN++
	nTOT_BLOCOJ++
	nTOT_J150++
   
return

static function i_compact

     local nSaldo := 0
	 local cSinal := ""
	 local nCTA   := space(6)
     
	 cSINAL := subs(RESULTAD->Combina2,1,1)
     nCTA   := subs(RESULTAD->Combina2,2,6)

	 PLAN->(dbclearfilter())
     
	 if PLAN->(dbseek(nCTA))
	 
	     
         nSaldo := PLAN->Saldo_dre
		 
         if nSaldo <> 0  		 
			 cSPED := "|J150"	
			 cSPED += "|"+maskCod(alltrim(PLAN->Codigo))	
			 cSPED += "|0"
			 cSPED += "|"+rtrim(PLAN->Descricao)
			 
			 cSPED += "|"+i_valida(abs(nSaldo),19)
			 
			 cSPED += "|"+iif(nSaldo > 0,"D","R")
			 cSPED += "|"
			 write(nFILE,cSPED,len(cSPED))
			 cSPED := ""
			 nTOT_LIN++
			 nTOT_BLOCOJ++
			 nTOT_J150++
		 endif	 
	 endif


return

static function i_maismenos(cCOMBINA)
   local zTMP := 0

   for nCONTA = 1 to len(cCOMBINA) step 7
       cSINAL := subs(cCOMBINA,nCONTA,1)
       nCTA   := subs(cCOMBINA,nCONTA+1,6)
	   
       if PLAN->(dbseek(nCTA))
          nSALDATU := PLAN->Saldo_dre
          iif( cSINAL == "+" , zTMP += nSALDATU * -1 , zTMP -= nSALDATU * -1 )
       endif
      // if prow() > K_MAX_LIN
      //    qpageprn()
      //    qcabecprn(cTITULO1,132,.F.,cTITULO2)
      //    @ prow()+1,00 say ""
      // endif
   next

return zTMP

static function dre_mantra
	local cSPED    := ""
	local nREC_LIQ := 0
	local nLUCRO_BRUTO := 0
	
     PLAN->(dbclearfilter())
     PLAN->(dbsetorder(1))
     PLAN->(dbgotop())
	 
	 if PLAN->(dbseek("3010101"))
		//alert("OK")
		cSPED := "|J150"	
		cSPED += "|3.01.01.01"
		cSPED += "|0"			
		cSPED += "|"+"RECEITAS OPERACIONAIS"
		cSPED += "|"+i_valida(abs(PLAN->Saldo_dre),19)
		cSPED += "|"+"P"
		cSPED += "|"+i_valida(abs(0),19)
		cSPED += "|"+"P"
		cSPED += "|"
		write(nFILE,cSPED,len(cSPED))
		cSPED := ""
		nTOT_LIN++
		nTOT_BLOCOJ++
		nTOT_J150++
		imprimeSubContas("3010101")
	endif	
	
	if PLAN->(dbseek("3010102"))
		cSPED := "|J150"	
		cSPED += "|3.01.01.02"
		cSPED += "|0"			
		cSPED += "|"+"DEDUCOES"
		cSPED += "|"+i_valida(abs(PLAN->Saldo_dre),19)
		cSPED += "|"+"P"
		cSPED += "|"+i_valida(abs(0),19)
		cSPED += "|"+"P"
		cSPED += "|"
		write(nFILE,cSPED,len(cSPED))
		cSPED := ""
		nTOT_LIN++
		nTOT_BLOCOJ++
		nTOT_J150++
		imprimeSubContas("3010102")
	endif
	if PLAN->(dbseek("3010201"))
		cSPED := "|J150"	
		cSPED += "|3.01.02.01"
		cSPED += "|0"			
		cSPED += "|"+"IMPOSTOS"
		cSPED += "|"+i_valida(abs(PLAN->Saldo_dre),19)
		cSPED += "|"+"P"
		cSPED += "|"+i_valida(abs(0),19)
		cSPED += "|"+"P"
		cSPED += "|"
		write(nFILE,cSPED,len(cSPED))
		cSPED := ""
		nTOT_LIN++
		nTOT_BLOCOJ++
		nTOT_J150++
		imprimeSubContas("3010201")
	endif
	
	if PLAN->(dbseek("301"))
		cSPED := "|J150"	
		cSPED += "|"
		cSPED += "|0"			
		cSPED += "|"+"(=)RECEITA OPERACIONAL LIQUIDA"
		cSPED += "|"+i_valida(abs(PLAN->Saldo_dre),19)
		cSPED += "|"+"P"
		cSPED += "|"+i_valida(abs(0),19)
		cSPED += "|"+"P"
		cSPED += "|"
		write(nFILE,cSPED,len(cSPED))
		cSPED := ""
		nTOT_LIN++
		nTOT_BLOCOJ++
		nTOT_J150++
		nREC_LIQ := abs(PLAN->Saldo_dre)
	endif	
	
	if PLAN->(dbseek("3020201"))
		cSPED := "|J150"	
		cSPED += "|3.02.02.01"
		cSPED += "|0"			
		cSPED += "|"+"CUSTOS DOS ESTOQUES"
		cSPED += "|"+i_valida(abs(PLAN->Saldo_dre),19)
		cSPED += "|"+"P"
		cSPED += "|"+i_valida(abs(0),19)
		cSPED += "|"+"P"
		cSPED += "|"
		write(nFILE,cSPED,len(cSPED))
		cSPED := ""
		nTOT_LIN++
		nTOT_BLOCOJ++
		nTOT_J150++
		imprimeSubContas("3020201")
	endif
	
	if PLAN->(dbseek("3020401"))
		cSPED := "|J150"	
		cSPED += "|"		
		cSPED += "|0"	
		cSPED += "|"+"CUSTOS ESTOQUES/EXPEDICAO"
		cSPED += "|"+i_valida(abs(PLAN->Saldo_dre),19)
		cSPED += "|"+"P"
		cSPED += "|"+i_valida(abs(0),19)
		cSPED += "|"+"P"
		cSPED += "|"
		write(nFILE,cSPED,len(cSPED))
		cSPED := ""
		nTOT_LIN++
		nTOT_BLOCOJ++
		nTOT_J150++
		imprimeSubContas("3020401")
	endif
	
	if PLAN->(dbseek("3020403"))
		cSPED := "|J150"	
		cSPED += "|"		
		cSPED += "|0"	
		cSPED += "|"+"OUTROS CUSTOS"
		cSPED += "|"+i_valida(abs(PLAN->Saldo_dre),19)
		cSPED += "|"+"P"
		cSPED += "|"+i_valida(abs(0),19)
		cSPED += "|"+"P"
		cSPED += "|"
		write(nFILE,cSPED,len(cSPED))
		cSPED := ""
		nTOT_LIN++
		nTOT_BLOCOJ++
		nTOT_J150++
		imprimeSubContas("3020403")
	endif
	
	if PLAN->(dbseek("302")) // TOTAL DE CUSTOS
		cSPED := "|J150"	
		cSPED += "|"
		cSPED += "|0"			
		cSPED += "|"+"(=)LUCRO BRUTO"
		cSPED += "|"+i_valida(nREC_LIQ - abs(PLAN->Saldo_dre),19)
		cSPED += "|"+"N"
		cSPED += "|"+i_valida(0,19)
		cSPED += "|"+"N"
		cSPED += "|"
		write(nFILE,cSPED,len(cSPED))
		cSPED := ""
		nTOT_LIN++
		nTOT_BLOCOJ++
		nTOT_J150++
	endif	
	
	if PLAN->(dbseek("30301"))
		cSPED := "|J150"	
		cSPED += "|"		
		cSPED += "|0"	
		cSPED += "|"+"DESPESAS COM PESSOAL"
		cSPED += "|"+i_valida(abs(PLAN->Saldo_dre),19)
		cSPED += "|"+"P"
		cSPED += "|"+i_valida(abs(0),19)
		cSPED += "|"+"P"
		cSPED += "|"
		write(nFILE,cSPED,len(cSPED))
		cSPED := ""
		nTOT_LIN++
		nTOT_BLOCOJ++
		nTOT_J150++
		imprimeSubContas("30301")
		nDespPessoal := abs(PLAN->Saldo_dre)
	endif
	
	if PLAN->(dbseek("30302"))
		cSPED := "|J150"	
		cSPED += "|"		
		cSPED += "|0"	
		cSPED += "|"+"DESPESAS GERAIS"
		cSPED += "|"+i_valida(abs(PLAN->Saldo_dre),19)
		cSPED += "|"+"P"
		cSPED += "|"+i_valida(abs(0),19)
		cSPED += "|"+"P"
		cSPED += "|"
		write(nFILE,cSPED,len(cSPED))
		cSPED := ""
		nTOT_LIN++
		nTOT_BLOCOJ++
		nTOT_J150++
		imprimeSubContas("30302")
		nDespGer := abs(PLAN->Saldo_dre)
	endif
	
	if PLAN->(dbseek("30303"))
		cSPED := "|J150"	
		cSPED += "|"		
		cSPED += "|0"	
		cSPED += "|"+"DESPESAS COM VENDAS"
		cSPED += "|"+i_valida(abs(PLAN->Saldo_dre),19)
		cSPED += "|"+"P"
		cSPED += "|"+i_valida(abs(0),19)
		cSPED += "|"+"P"
		cSPED += "|"
		write(nFILE,cSPED,len(cSPED))
		cSPED := ""
		nTOT_LIN++
		nTOT_BLOCOJ++
		nTOT_J150++
		imprimeSubContas("30303")
		nDespVendas := abs(PLAN->Saldo_dre)
	endif
	
	if PLAN->(dbseek("304"))
		cSPED := "|J150"	
		cSPED += "|"		
		cSPED += "|0"	
		cSPED += "|"+"ENCARGOS FINANCEIROS LIQUIDOS"
		cSPED += "|"+i_valida(abs(PLAN->Saldo_dre),19)
		cSPED += "|"+"P"
		cSPED += "|"+i_valida(abs(0),19)
		cSPED += "|"+"P"
		cSPED += "|"
		write(nFILE,cSPED,len(cSPED))
		cSPED := ""
		nTOT_LIN++
		nTOT_BLOCOJ++
		nTOT_J150++
		imprimeSubContas("304")
		nEncFinan := abs(PLAN->Saldo_dre)
	endif
	
	if PLAN->(dbseek("305"))
		cSPED := "|J150"	
		cSPED += "|"		
		cSPED += "|0"	
		cSPED += "|"+"DESPESAS TRIBUTARIAS"
		cSPED += "|"+i_valida(abs(PLAN->Saldo_dre),19)
		cSPED += "|"+"P"
		cSPED += "|"+i_valida(abs(0),19)
		cSPED += "|"+"P"
		cSPED += "|"
		write(nFILE,cSPED,len(cSPED))
		cSPED := ""
		nTOT_LIN++
		nTOT_BLOCOJ++
		nTOT_J150++
		imprimeSubContas("305")
		nDespTrib := abs(PLAN->Saldo_dre)
	endif
	
	if PLAN->(dbseek("307"))
		cSPED := "|J150"	
		cSPED += "|"		
		cSPED += "|0"	
		cSPED += "|"+"PROVISOES PARA ENCERRAMENTO DO EXERCICIO"
		cSPED += "|"+i_valida(abs(PLAN->Saldo_dre),19)
		cSPED += "|"+"P"
		cSPED += "|"+i_valida(abs(0),19)
		cSPED += "|"+"P"
		cSPED += "|"
		write(nFILE,cSPED,len(cSPED))
		cSPED := ""
		nTOT_LIN++
		nTOT_BLOCOJ++
		nTOT_J150++
		imprimeSubContas("307")
		nProvs := abs(PLAN->Saldo_dre)
	endif
	
	if PLAN->(dbseek("3")) // LUCRO
		cSPED := "|J150"	
		cSPED += "|"
		cSPED += "|0"			
		cSPED += "|"+"(=)LUCRO DO EXERCICIO"
		cSPED += "|"+i_valida(abs(PLAN->Saldo_dre),19)
		cSPED += "|"+"N"
		cSPED += "|"+i_valida(abs(0),19)
		cSPED += "|"+"N"
		cSPED += "|"
		write(nFILE,cSPED,len(cSPED))
		cSPED := ""
		nTOT_LIN++
		nTOT_BLOCOJ++
		nTOT_J150++
	endif	

return

static function imprimeSubContas(contaPai)
	local cSPED    := ""
	local size := len(contaPai)
	
	if PLAN->(dbseek(contaPai))
	
		do while ! PLAN->(eof()) .and. left(PLAN->Codigo,size) == contaPai
		
			if empty(PLAN->Reduzido)
			   PLAN->(dbskip())
				loop
			endif	
			
			if PLAN->Saldo_dre == 0
			    PLAN->(dbskip())
				loop
			endif	
			
			 cSPED := "|J150"	
			 cSPED += "|"+maskCod(alltrim(PLAN->Codigo))	
			 cSPED += "|0"
			 cSPED += "|"+rtrim(PLAN->Descricao)
			 
			 cSPED += "|"+i_valida(abs(PLAN->Saldo_dre),19)
			 
			 cSPED += "|"+iif(PLAN->Saldo_dre > 0,"D","R")
			 cSPED += "|"+i_valida(abs(0),19)
			 cSPED += "|"+iif(PLAN->Saldo_dre > 0,"D","R")
			 cSPED += "|"
			 write(nFILE,cSPED,len(cSPED))
			 cSPED := ""
			 nTOT_LIN++
			 nTOT_BLOCOJ++
			 nTOT_J150++
			
			PLAN->(dbskip())
		enddo
	endif	



return
