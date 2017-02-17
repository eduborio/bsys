/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE CONTABILIDADE
// OBJETIVO...: EMISSAO DO TERMO DE ABERTURA E ENCERRAMENTO
// ANALISTA...: LUIS ANTONIO ORLANDO PEREIRA
// PROGRAMADOR: CARLOS EDUARDO RABELLO NUNES
// INICIO.....: JUNHO DE 1995
// OBS........:
// ALTERACOES.:
function ct526

#define K_MAX_LIN 57

// ABERTURA DE ARQUIVO QCONFIG, DECLARACAO E INICIALIZACAO DE VARIAVEIS _____

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG) .or. lastkey() = 27}

private sBLOCO1 := qlbloc("B526B","QBLOC.GLO") // bloco basico
private sBLOCO2 := qlbloc("B526C","QBLOC.GLO") // bloco junta/cartorio

if ! quse("\QSYS_G\QCT\","QCONFIG",NIL,"E")
   qmensa("N„o foi poss¡vel abrir arquivo QCONFIG.DBF !! Tente novamente.")
   return
endif

private nCONT         // contador de vezes de impressao
private aEDICAO := {} // vetor para os campos de entrada de dados
private cTIPO         // tipo de relatorio (diario ou razao)
private nDIARIO       // numero do diario
private cJUNCAR       // junta ou cartorio
private nJUNTA        // numero na junta
private dDT_JUNTA     // data da junta
private cNOME_DIR     // nome do diretor
private cCPF_DIRETO   // CPF do diretor
private cNOME_CONT    // nome do contador
private cCRC          // CRC do contador
private dDT_EMISAB    // data da emissao da abertura
private dDT_EMISFX    // data da emissao da fechamento
private nPAGFIM       // pagina final de impressao

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qesco(-1,0,@cTIPO,sBLOCO1   )} ,"TIPO"      })
aadd(aEDICAO,{{ || qgetx(-1,0,@nDIARIO,"9999"  )} ,"DIARIO"    })
aadd(aEDICAO,{{ || qesco(-1,0,@cJUNCAR,sBLOCO2 )} ,"JUNCAR"    })
aadd(aEDICAO,{{ || qgetx(-1,0,@nJUNTA ,"@X"    )} ,"JUNTA"     })
aadd(aEDICAO,{{ || qgetx(-1,0,@dDT_JUNTA       )} ,"DT_JUNTA"  })
aadd(aEDICAO,{{ || qgetx(-1,0,@cNOME_DIR ,"@X" )} ,"NOME_DIR"  })
aadd(aEDICAO,{{ || qgetx(-1,0,@cCPF_DIRETO ,"999.999.999-99" )} ,"CPF_DIRETO"  })
aadd(aEDICAO,{{ || qgetx(-1,0,@cNOME_CONT,"@X" )} ,"MOME_CONT" })
aadd(aEDICAO,{{ || qgetx(-1,0,@cCRC,"@X"       )} ,"CRC"       })
aadd(aEDICAO,{{ || qgetx(-1,0,@dDT_EMISAB      )} ,"DT_EMISAB" })
aadd(aEDICAO,{{ || qgetx(-1,0,@dDT_EMISFX      )} ,"DT_EMISFX" })
aadd(aEDICAO,{{ || qgetx(-1,0,@nPAGFIM,"9999"  )} ,"PAGFIM"    })

do while .T.

   qlbloc(5,0,"B526A","QBLOC.GLO")
   qmensa()
   nDIARIO     := 0
   nJUNTA      := CONFIG->Num_junta
   dDT_JUNTA   := CONFIG->Data_junta
   cNOME_DIR   := CONFIG->Diretor
   cCPF_DIRETO := CONFIG->Cpf_direto
   cNOME_CONT  := QCONFIG->Contador
   cCRC        := QCONFIG->Crc
   nPAGFIM     := 0
   dDT_EMISAB  := ctod("")
   dDT_EMISFX  := ctod("")
   XNIVEL      := 1
   XFLAG       := .T.

   // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; dbcloseall() ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   if ( i_inicializacao() , i_impressao() , NIL )

   if QCONFIG->(qflock())
      replace QCONFIG->Contador with cNOME_CONT
      replace QCONFIG->Crc      with cCRC
      QCONFIG->(qunlock())
   endif

   if CONFIG->(qflock())
      replace CONFIG->Num_junta  with nJUNTA
      replace CONFIG->Data_junta with dDT_JUNTA
      replace CONFIG->Diretor    with cNOME_DIR
      replace CONFIG->Cpf_direto with cCPF_DIRETO
      CONFIG->(qunlock())
   endif

enddo

/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA _____________________________________________

static function i_critica ( cCAMPO )
   do case
      case cCAMPO == "TIPO"
           qrsay(XNIVEL,qabrev(cTIPO,"DR",{"Di rio","Raz„o"}))
      case cCAMPO == "JUNCAR"
           qrsay(XNIVEL,qabrev(cJUNCAR,"JC",{"Junta","Cart¢rio"}))
      case cCAMPO == "DIARIO"
           qrsay(XNIVEL,strzero(nDIARIO,4))
      case cCAMPO == "PAGFIM"
           qrsay(XNIVEL,strzero(nPAGFIM,4))
   endcase
return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // POSICIONA ARQUIVO CGM _________________________________________________

   CGM->(dbseek(XCGM))

   qmensa()

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impressao
   local dAUX
   local cCPFCONT := FILIAL->Cpf_contad

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif
   qmensa("imprimindo...")

   For nCONT = 1 To 2

       if nCONT = 1
          @ 05,00  say space(47)+"T E R M O   D E   A B E R T U R A"
          @ 05,119 say "Fls.: 0001"
          dAUX := dDT_EMISAB
       else
          @ 05,00  say space(41)+"T E R M O   D E   E N C E R R A M E N T O"
          @ 05,119 say "Fls.: " + strzero(nPAGFIM,4)
          dAUX := dDT_EMISFX
       endif

       @ 07,00  say replicate("=",129)
       @ 08,00  say "="
       @ 08,128 say "="
       @ 09,00  say "="+"                         Contem este livro " + iif(cTIPO = "D","DIARIO","RAZAO ") + " N. " + ;
                 strzero(nDIARIO,4) + " folhas numeradas de 0001 a " + strzero(nPAGFIM,4) + " ,"
       @ 09,128 say "="
       @ 10,00  say "="
       @ 10,128 say "="
       @ 11,00  say "="+"                         de " + XRAZAO
       @ 11,128 say "="
       @ 12,00  say "="
       @ 12,128 say "="
       @ 13,00  say "="+"                         com sede em " + alltrim(CGM->Municipio) + " - " + CGM->Estado
       @ 13,128 say "="
       @ 14,00  say "="
       @ 14,128 say "="
       @ 15,00  say "="+"                         na " + rtrim(XENDERECO) +  ", " + XNUMERO + " - " + XBAIRRO + " CEP: "+transf(XCEP,"@R 99.999-999")
       @ 15,128 say "="
       @ 16,00  say "="
       @ 16,128 say "="
       @ 17,00  say "="+"                         registrada n" + iif(cJUNCAR=="J","a JUNTA COMERCIAL DO PARANA","o CARTORIO DE TITULOS E DOCUMENTOS")
       @ 17,128 say "="
       @ 18,00  say "="+"                         sob N. " + nJUNTA + " , por despacho em sessao de " + Dtoc(dDT_JUNTA)
       @ 18,128 say "="
       @ 19,00  say "="
       @ 19,128 say "="
       @ 20,00  say "="+"                         C.N.P.J " + XCGCCPF + "- Inscr. Est. " + XINSCR_EST +" - Inscr. Mun. " + XINSCR_MUN
       @ 20,128 say "="
       @ 21,00  say "="
       @ 21,128 say "="
       @ 22,00  say "="
       @ 22,128 say "="
       @ 23,00  say "="
       @ 23,128 say "="
       @ 24,00  say "="
       @ 24,128 say "="
       @ 25,00  say "="
       @ 25,128 say "="
       @ 26,00  say "="
       @ 26,128 say "="
       @ 27,00  say "="
       @ 27,128 say "="
       @ 28,00  say "="
       @ 28,128 say "="
       @ 29,00  say "="
       @ 29,128 say "="
       @ 30,00  say "="
       @ 30,128 say "="
       @ 31,00  say "="
       @ 31,128 say "="
       @ 32,00  say "="
       @ 32,128 say "="
       @ 33,00  say "="
       @ 33,128 say "="
       @ 34,00  say "=" +"                    "+ padl(alltrim(CGM->Municipio),25) + ", " + strzero(day(dAUX),2) + " de " + ;
                         qnomemes(dAUX) + " de " + strzero(year(dAUX),4)

       @ 34,128 say "="
       @ 35,00  say "="
       @ 35,128 say "="
       @ 36,00  say "="
       @ 36,128 say "="
       @ 37,00  say "="
       @ 37,128 say "="
       @ 38,00  say "=                         -----------------------------------------------------------  "
       @ 38,128 say "="

       @ 39,00  say "=                         Diretor :  " + cNOME_DIR
       @ 39,128 say "="
       @ 40,00  say "=                         C.P.F.  :  " + cCPF_DIRETO
       @ 40,128 say "="
       @ 41,00  say "="
       @ 41,128 say "="
       @ 42,00  say "="
       @ 42,128 say "="
       @ 43,00  say "="
       @ 43,128 say "="

       @ 44,00  say "="
       @ 44,128 say "="

       @ 45,00  say "=                         -----------------------------------------------------------  "
       @ 45,128 say "="

       @ 46,00  say "=                         Contador : " + cNOME_CONT
       @ 46,128 say "="
       @ 47,00  say "=                         C.R.C    : " + cCRC
       @ 47,128 say "="
       @ 48,00  say "=                         C.P.F    : " + transf(cCPFCONT,"@R 999.999.999-99")
       @ 48,128 say "="

       @ 49,00  say "="
       @ 49,128 say "="

       @ 50,00  say "="
       @ 50,128 say "="

       @ 51,00  say replicate("=",129)


       __eject()

   next

   qstopprn()

return

