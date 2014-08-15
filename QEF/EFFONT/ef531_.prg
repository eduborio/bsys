
/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE ESCRITA FISCAL
// OBJETIVO...: RETIFICACAO DA GUIA DE INFORMACAO
// ANALISTA...: LUIS ANTONIO ORLANDO PEREIRA
// PROGRAMADOR: IN SUNG CHANG
// INICIO.....: FEVEREIRO DE 1996
// OBS........:
// ALTERACOES.:
function ef531

// DADOS DO CONTADOR _______________________________________________________

if ! quse("","QCONFIG") ; return ; endif

private cCONT_NOME := QCONFIG->Cont_Nome        // Nome do contador
private cCONT_TEL  := QCONFIG->Cont_Fone        // Telefone do contador
private cCONT_RG   := QCONFIG->Cont_Rg          // R.G. do contador

QCONFIG->(dbclosearea())

// POSICIONA NO MUNICIPIO E ESTADO DA EMPRESA ______________________________

CGM->(dbseek(XCGM))

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

private bESCAPE := {||(XNIVEL==1 .and. !XFLAG .or. lastkey() = 27) }
private aEDICAO := {}                           // Vetor para os campos de entrada de dados
private dDATA_REL                               // Data do relatorio
private cQUADROS                                // Numero de quadros na GIA/ICMS
private cCAMPOS1                                // Numero de campos na GIA/ICMS
private cCAMPOS2                                // Numero de campos na GIA/ICMS
private cJUSTIF                                 // Justificativo para retificacao
private cDT_RET                                 // Data de retificacao

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

   qlbloc(5,0,"B531A","QBLOC.GLO",1)

   aadd(aEDICAO,{{ || qgetx(-1,0,@dDATA_REL ,"@!"     ,NIL,NIL ) } ,"DATA_REL"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@cQUADROS  ,"@!"              ) } ,"QUADROS" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@cCAMPOS1  ,"@!"              ) } ,"CAMPOS1" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@cCAMPOS2  ,"@!"              ) } ,"CAMPOS2" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@cJUSTIF   ,"@!"              ) } ,"JUSTIF"  })
   aadd(aEDICAO,{{ || qgetx(-1,0,@cDT_RET   ,"99/9999"         ) } ,"DT_RET"  })

do while .T.

   XNIVEL := 1
   XFLAG  := .T.

   dDATA_REL := date()                     // Data de retificacao
   cQUADROS  := space(14)                  // O numero de quadros na GIA/ICMS
   cCAMPOS1  := space(33)                  // O numero de campos na GIA/ICMS
   cCAMPOS2  := space(55)                  // O numero de campos na GIA/ICMS
   cJUSTIF   := space(33)                  // Justificativo para retificacao
   cDT_RET   := space(7)                   // Data de retificacao

   // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; dbcloseall() ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   i_impressao()

enddo

/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA _____________________________________________

static function i_critica ( cCAMPO )
   do case
      case cCAMPO == "DATA_REL"
           if empty(dDATA_REL); return .F.; endif
      case cCAMPO == "DT_RET"
           if empty(cDT_RET); return .F.; endif
   endcase
return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impressao

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   // DECLARACAO DE RETIFICACAO PAGINA 1 ____________________________________

   if ! qinitprn() ; return ; endif

   for nCONT = 1 TO 2

       @ prow(),pcol() say XCOND0
       @ prow()+4,00 say padc(XAENFAT + "D E C L A R A C A O" + XDENFAT,80)
       @ prow()+3,10 say XAENFAT + padr(alltrim(XRAZAO),50,"*") + "*********" + XDENFAT + ","
       @ prow()+2,05 say "pessoa juridica de direito privado, inscrita  no CAD/ICMS sob No."
       @ prow()+2,05 say XAENFAT + padr(alltrim(XINSCR_EST),14,"*") + XDENFAT + " representada  por  " + XAENFAT + padr(alltrim(cCONT_NOME),30,"*") + XDENFAT + ","
       @ prow()+2,05 say "portador  da  cedula  de  identidade R.G. No. " + XAENFAT + padr(alltrim(cCONT_RG),18,"*") + XDENFAT + ","
       @ prow()+2,05 say "declara para a " + XAENFAT + "INSPETORIA  GERAL  DE ARRECADACAO - IGA/SEFA" + XDENFAT + ", para"
       @ prow()+2,05 say "fins de " + XAENFAT + "RETIFICACAO" + XDENFAT + "  da  Guia  de  Informacao referente ao mes de"
       @ prow()+2,05 say alltrim(qnomemes(substr(cDT_RET,1,2))) + "/" + substr(cDT_RET,2,6) + " que as informacoes prestadas constituem " +;
                         " expressao"
       @ prow()+2,05 say "da verdade, fundamentada em documentacao idonea em seu poder, das"
       @ prow()+2,05 say "quais anexas copias."
       @ prow()+2,10 say "Por  ser  verdade, firma  a  presente declaracao em 02(Duas)"
       @ prow()+2,05 say "vias de igual teor, para que surta efeitos legais."
       @ prow()+6,11 say "Curitiba, " + str(day(dDATA_REL),2) + " de " + alltrim(qnomemes(dDATA_REL)) +;
                         " de " + str(year(dDATA_REL),4) + "."
       @ prow()+4,11 say Replicate("_",55)
       @ prow()+1,25 say cCONT_NOME
       @ prow()+1,25 say "R.G.: " + cCONT_RG
       @ prow()+1,25 say "Tel.: " + cCONT_TEL
       i_carimbo()

       // DECLARACAO DE RETIFICACAO PAGINA 2 ____________________________________

       @ prow(),pcol() say XCOND0
       @ prow()+6,00 say padc(XAENFAT + "A INSPETORIA GERAL DE ARRECADACAO DA SEFA" + XDENFAT,80)
       @ prow()+2,00 say padc(XAENFAT + "SETOR DE CONTA CORRENTE FISCAL" + XDENFAT,80)
       @ prow()+3,10 say XAENFAT + padr(alltrim(XRAZAO),50,"*") + "*********" + XDENFAT + ","
       @ prow()+2,05 say "inscrita no CAD/ICMS sob No. " + XAENFAT + padr(alltrim(XINSCR_EST),14,"*") + XDENFAT + ", vem requerer a " + XAENFAT +;
                         "Vossa"
       @ prow()+2,05 say "Senhoria " + XDENFAT + "que se digne a mandar " + XAENFAT + "RETIFICAR" + XDENFAT +;
                         " a GIA/ICMS  referente ao"
       @ prow()+2,05 say "mes de " + alltrim(qnomemes(substr(cDT_RET,1,2))) + "/" + substr(cDT_RET,2,6) +;
                         " por apresentar erro de fechamento no(s) :"
       @ prow()+2,05 say "quadro(s) :" + XAENFAT + cQUADROS + XDENFAT
       @ prow()+2,05 say "campo(s) :"  + XAENFAT + cCAMPOS1 + cCAMPOS2 + XDENFAT
       @ prow()+2,05 say "motivados por: (Justifique) " + XAENFAT + cJUSTIF + XDENFAT
       @ prow()+4,11 say "Neste termos."
       @ prow()+2,11 say "Pede deferimentos."
       @ prow()+4,11 say "Curitiba, " + str(day(dDATA_REL),2) + " de " + alltrim(qnomemes(dDATA_REL)) + " de " +;
                         str(year(dDATA_REL),4) + "."
       @ prow()+4,11 say Replicate("_",55)
       @ prow()+1,25 say cCONT_NOME
       @ prow()+1,25 say "R.G.: " + cCONT_RG
       @ prow()+1,25 say "Tel.: " + cCONT_TEL
       i_carimbo()

   next

   qstopprn()

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IMPRIMIR O CARIMBO DE CGC E INSC. EST. _______________________

static function i_carimbo

   @ prow(),pcol() say XCOND1
   @ prow()+02,027 say "+-" + space(41) + "-+"
   @ prow()   ,076 say "+-" + space(41) + "-+"
   @ prow()+01,027 say "|"
   @ prow()   ,035 say XAEXPAN + XCGCCPF + XDEXPAN
   @ prow()   ,063 say "|"
   @ prow()   ,068 say "|"
   @ prow()   ,073 say XAEXPAN + XINSCR_EST + XDEXPAN
   @ prow()   ,100 say "|"
   @ prow()+02,029 say Substr(XRAZAO,1,38)
   @ prow()   ,078 say Substr(XRAZAO,1,38)
   @ prow()+01,029 say Substr(XRAZAO,39,50)
   @ prow()   ,078 say Substr(XRAZAO,39,50)
   @ prow()+01,029 say XENDERECO
   @ prow()   ,078 say XENDERECO
   @ prow()+01,029 say XCEP + " - " + Alltrim(CGM->MUNICIPIO) + " - " + alltrim(CGM->ESTADO)
   @ prow()   ,078 say XCEP + " - " + Alltrim(CGM->MUNICIPIO) + " - " + alltrim(CGM->ESTADO)
   @ prow()+01,027 say "|"  + space(43) + "|"
   @ prow()   ,076 say "|"  + space(43) + "|"
   @ prow()+01,027 say "+-" + space(41) + "-+"
   @ prow()   ,076 say "+-" + space(41) + "-+"
   @ prow()+15,000 say ""

return
