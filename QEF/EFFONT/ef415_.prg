/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO COMERCIO
// OBJETIVO...: Exportar arquivo p/ Software Dominio - (Clari Agua Mineral)
// ANALISTA...: EDUARDO AUGUSTO BORIO
// PROGRAMADOR: EDUARDO AUGUSTO BORIO
// INICIO.....: NOVEMBRO DE  2006
// OBS........:
// ALTERACOES.:
function ef415

#define K_MAX_LIN 57

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG) .or. empty(dINI) .or. lastkey() == 27 }

private cTITULO                   // titulo do relatorio
private dINI
private dFIM
private cICMS   := space(7)
private cIPI    := space(7)
private cEMP    := space(7)
private cTIPO   := space(2)
private cSISTEMA:= space(2)
private sBLOC1  := qlbloc("B415B","QBLOC.GLO")
private sBLOC2  := qlbloc("B415C","QBLOC.GLO")

private aEDICAO := {}             // vetor para os campos de entrada de dados

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qgetx(-1,0,@dINI)            } , "INI"    })
aadd(aEDICAO,{{ || qgetx(-1,0,@dFIM)            } , "FIM"    })
aadd(aEDICAO,{{ || qgetx(-1,0,@cEMP)            } , "EMP" })
aadd(aEDICAO,{{ || qgetx(-1,0,@cICMS)           } , "ICMS" })
aadd(aEDICAO,{{ || qesco(-1,0,@cTIPO,sBLOC1)    } , "TIPO" })
aadd(aEDICAO,{{ || qesco(-1,0,@cSISTEMA,sBLOC2) } , "SISTEMA" })

aadd(aEDICAO,{{ || lCONF := qconf("Confirma Exporta‡Æo de Arquivo (Dominio) ?") },NIL})



do while .T.

   qlbloc(5,0,"B415A","QBLOC.GLO")
   XNIVEL := 1
   XFLAG  := .T.
   dINI := qinimes(date())
   dFIM := qfimmes(dINI)
   cICMS   := space(7)
   cIPI    := space(7)
   cEMP    := space(7)
   cTIPO   := space(2)
   cSISTEMA:= space(2)

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

      case cCAMPO == "EMP"
           if empty(cEMP)
              qmensa("Campo Obrigatorio... Por Favor Preencher.","B")
              qmensa("")
              return .F.
           endif
           qrsay(XNIVEL,cEMP := strzero(val(cEMP),7))

      case cCAMPO == "ICMS"
           if empty(cICMS)
              qmensa("Campo Obrigatorio... Por Favor Preencher.","B")
              qmensa("")
              return .F.
           endif
           qrsay(XNIVEL,cICMS := strzero(val(cICMS),7))

      case cCAMPO == "TIPO"

           if empty(cTIPO) ;  return .F. ; Endif
           qrsay(XNIVEL,qabrev(cTIPO,"2345",{"2 - Entrada","3 - Saida","4 - Fornecedores","5 - Clientes"}))

      case cCAMPO == "SISTEMA"

           if empty(cSISTEMA) ;  return .F. ; Endif
           qrsay(XNIVEL,qabrev(cSISTEMA,"120",{"1 - Contabilidade","2 - Caixa","0 - Outro"}))




   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // CRIA TITULO DO RELATORIO ______________________________________________


   cTITULO := ""

   qmensa("")

   // ESTABELECE RELACOES ENTRE ARQUIVOS ____________________________________

   ENT->(Dbsetfilter({||ENT->Data_Lanc >= dINI .and. ENT->Data_Lanc },'ENT->Data_lanc >= dINI .and. ENT->Data_lanc <= dFIM'))
   SAI->(Dbsetfilter({||SAI->Data_Lanc >= dINI .and. SAI->Data_Lanc },'SAI->Data_lanc >= dINI .and. SAI->Data_lanc <= dFIM'))
   ENT->(dbsetorder(2))
   SAI->(dbsetorder(2))
return .T.


static function i_gravacao



local   cDOMINIO :=  ""

if ! qinitprn() ; return .f. ; endif


if ! quse(XDRV_EF,"DOMINIO",NIL,"E")
   qmensa("N„o foi poss¡vel abrir arquivo DOMINIO.DBF !! Tente novamente.")
   return
endif

cDIMINIO := ""
DOMINIO->(__dbzap())

if cTIPO $ "2-3"
///////////////////////////////////////////////////////////////////////
// REGISTRO TIPO 01 - CABECALHO DO ARQUIVO_____________________________
//                                                               Pos.    Tam. Tipo.
   cDOMINIO := "01"  //Fixo Cabecalho do Arquivo              -  01-02   02   Alfa
   cDOMINIO += cEMP  //Codigo da Empresa no Sistema Dominio   -  03-09   07   Numerico
   cDOMINIO += alltrim(FILIAL->Cgccpf) //CNPJ da Emp          -  10-23   14   Alfa
   cDOMINIO += dtoc(dINI) //Data Inicial                      -  24-33   10   Data
   cDOMINIO += dtoc(dFIM) //Data Final                        -  34-43   10   Data
   cDOMINIO += "N"        //Valor Fixo                        -  44-44   01   Alfa
   cDOMINIO += "0"+cTIPO  //Tipo(2-Entradas/2-Saidas)         -  45-46   02   Numerico
   cDOMINIO += "00000"    //Constante                         -  47-51   05   Numerico
   cDOMINIO += cSISTEMA   //(1-Contab/2-Caixa/0-Outro)        -  52-52   01   Numerico
   cDOMINIO += "13"        //Constante                        -  53-54   01   Numerico

   @ prow()+1,00 say left(cDOMINIO,54)


   DOMINIO->(qappend())
   DOMINIO->Linha := cDOMINIO
   cDOMINIO := ""


   if cTIPO == "2"
      i_entradas()
      cNOMARQ := "A:Entradas.TxT"
   else
      i_saidas()
      cNOMARQ := "A:Saidas.TxT"
   endif

///////////////////////////////////////////////////////////////////////
// REGISTRO FINALIZADOR DO ARQUIVO_____________________________

   cDOMINIO := replicate("9",100)  //   001-100    100   Preencher com "9"
   @ prow()+1,00 say left(cDOMINIO,100)

   DOMINIO->(qappend())
   DOMINIO->Linha := cDOMINIO
   cDOMINIO := ""


   DOMINIO->(dbgotop())

   //DOMINIO->(__dbSDF( .T., cNOMARQ , { },,,,, .F. ) )

   if DOMINIO->(qflock())
     DOMINIO->(__dbzap())
   endif

   qstopprn(.F.)
else
   if cTIPO == "4"
      i_Forn()

   else
      i_cli()

   endif
Endif

return

static function i_entradas
local nCONT := 1
   ENT->(Dbgotop())

   do While ! ENT->(Eof())

      FORN->(Dbseek(ENT->Cod_forn))
      CGM->(Dbseek(FORN->Cgm_ent))
      FAT->(Dbsetorder(11))
      FAT->(Dbseek(ENT->Num_nf))
      ///////////////////////////////////////////////////////////////////////////////
      // TIPO 02 - ENTRADAS__________________________________________________________

      cDOMINIO := "02" // Fixo Entradas                         001-002  02  Numerico
      cDOMINIO += strzero(nCONT,7) //Sequencial                 003-009  07  Numerico
      cDOMINIO += cEMP //Codigo da Empresa                      010-016  07  Numerico
      cDOMINIO += alltrim(FORN->CgcCpf) //Cnpj Forn             017-030  14  Numerico
      cDOMINIO += "0000001" //Codigo da Especie                 031-037  07  Numerico
      cDOMINIO += "00"      //Codigo Exclusao da Dief           038-039  02  Numerico
      cDOMINIO += "0000000" //Codigo Acumulador                 040-046  07  Numerico
      cDOMINIO += strzero(val(ENT->Cfop),7) //Codigo Natureza   047-053  07  Numerico
      cDOMINIO += "00" //Codigo do Seguimento                   054-055  07  Numerico
      cDOMINIO += "0"+ENT->Num_nf //N.F.                        056-062  07  Numerico
      cDOMINIO += strzero(Val(ENT->Serie),7) //Serie da Nota    063-069  07  Numerico
      cDOMINIO += "0000000" //Doc Final ????                    070-076  07  Numerico
      cDOMINIO += dtoc(ENT->Data_lanc) //                       077-086  10  Data
      cDOMINIO += dtoc(ENT->Data_Emis) //                       087-096  10  Data
      cDOMINIO += i_Valida(ENT->Vlr_cont,13)//                097-109  13  Decimal(2)
      cDOMINIO += "0000000000000" //Vlr Exclusao Dief           110-122  13  Decimal(2)
      cDOMINIO += Left(ENT->Obs,30) //Observacao                123-152  30  AlfaNumerico
      cDOMINIO += CGM->Estado       //Estado do Forn            153-154  02  AlfaNumerico
      cDOMINIO += "F" //Frete Fob                               155-155  01  Numerico
      cDOMINIO += "P" //Proprio  ou Terceiros                   156-156  01  Numerico
      cDOMINIO += "E" //Fato Gerador da CRF(Emissao/Pagamento)  157-157  01  Numerico
      cDOMINIO += "E" //Fato Gerador IRRF  (Emissao/Pagamento)  158-158  01  Numerico
      cDOMINIO += "E" //codigo municipio             agamento)  159-165  06  Numerico
      cDOMINIO += space(47) //Brancos                           159-205  47  AlfaNumerico
      nCONT++

      DOMINIO->(qappend())
      DOMINIO->Linha := cDOMINIO
      @ prow()+1,00 say left(cDOMINIO,205)

      cDOMINIO := ""

      //////////////////////////////////////////////////////////////////////////////////////
      // TIPO 03 - IMPOSTOS P/ ENTRADAS_____________________________________________________
      cDOMINIO := "03" // Fixo Entradas                         001-002  02  Numerico
      cDOMINIO += strzero(nCONT,7) //Sequencial                 003-009  07  Numerico
      cDOMINIO += cICMS //Codigo do Imposto                     010-016  07  Numerico
      cDOMINIO += "00000" //Reducao de Base de Icms             017-021  05  Decimal(2)
      cDOMINIO += i_valida(ENT->Icm_base,13) //Base de Icms     022-034  13  Decimal(2)
      cDOMINIO += i_valida(ENT->Icm_aliq,5)  //Base de Icms     035-039  13  Decimal(2)
      cDOMINIO += i_valida(ENT->Icm_vlr,13)  //Vlr de Icms      040-052  13  Decimal(2)
      cDOMINIO += i_valida(ENT->Icm_isen,13) //Vlr de Isentas   053-065  13  Decimal(2)
      cDOMINIO += i_valida(ENT->Icm_out,13)  //Vlr de Outras    066-078  13  Decimal(2)
      cDOMINIO += i_valida(ENT->Ipi_vlr,13)  //Vlr de Ipi       079-091  13  Decimal(2)
      cDOMINIO += "0000000000000" //Substituicao Tributaria     092-104  13  Decimal(2)
      cDOMINIO += space(24)       //Brancos                     105-128  24  Decimal(2)
      nCONT++

      DOMINIO->(qappend())
      DOMINIO->Linha := cDOMINIO
      @ prow()+1,00 say left(cDOMINIO,128)

      cDOMINIO := ""


      ENT->(dbskip())
   enddo

return


static function i_saidas
local nCONT := 1
   SAI->(Dbgotop())


   do While ! SAI->(Eof())
      ///////////////////////////////////////////////////////////////////////////////
      // TIPO 02 - SAIDAS__________________________________________________________

      CLI1->(Dbseek(SAI->Cod_cli))
      CGM->(Dbseek(CLI1->Cgm_ent))
      FAT->(Dbsetorder(11))
      FAT->(Dbseek(SAI->Num_nf))

      cDOMINIO := "02" // Fixo Saidas                           001-002  02  Numerico
      cDOMINIO += strzero(nCONT,7) //Sequencial                 003-009  07  Numerico
      cDOMINIO += cEMP //Codigo da Empresa                      010-016  07  Numerico
      cDOMINIO += alltrim(CLI1->CgcCpf) //Cnpj Forn             017-030  14  Numerico
      cDOMINIO += "0000001" //Codigo da Especie                 031-037  07  Numerico
      cDOMINIO += "00"      //Codigo Exclusao da Dief           038-039  02  Numerico
      cDOMINIO += "0000000" //Codigo Acumulador                 040-046  07  Numerico
      cDOMINIO += strzero(val(SAI->Cfop),7) //Codigo Natureza   047-053  07  Numerico
      cDOMINIO += CGM->Estado       //Estado do Cliente         054-055  02  AlfaNumerico
      cDOMINIO += "00" //Codigo do Seguimento                   056-057  07  Numerico
      cDOMINIO += "0"+SAI->Num_nf //N.F.                        058-064  07  Numerico
      cDOMINIO += strzero(Val(SAI->Serie),7) //Serie da Nota    065-071  07  Numerico
      cDOMINIO += "0000000" //Doc Final ????                    072-078  07  Numerico
      cDOMINIO += dtoc(SAI->Data_lanc) //                       079-088  10  Data
      cDOMINIO += dtoc(SAI->Data_Emis) //                       089-098  10  Data
      cDOMINIO += i_Valida(SAI->Vlr_cont,13)//                  099-111  13  Decimal(2)
      cDOMINIO += "0000000000000" //Vlr Exclusao Dief           112-124  13  Decimal(2)
      cDOMINIO += Left(SAI->Obs,30) //Observacao                125-154  30  AlfaNumerico
      cDOMINIO += iif(FAT->Frete=="1","C","F")  //              155-155  01  Numerico
      cDOMINIO += "0"+CLI1->Cgm_ent //Municipio                 156-162  07  Numerico
      cDOMINIO += "E" //Fato Gerador da CRF(Emissao/Pagamento)  163-163  01  Numerico
      cDOMINIO += "1" //1 - Receita Propria/ 2- de Terceiros    164-164  01  Numerico
      cDOMINIO += space(41) //Brancos                           165-205  41  AlfaNumerico
      nCONT++

      DOMINIO->(qappend())
      DOMINIO->Linha := cDOMINIO
      @ prow()+1,00 say left(cDOMINIO,205)

      cDOMINIO := ""

      //////////////////////////////////////////////////////////////////////////////////////
      // TIPO 03 - IMPOSTOS P/ SAIDAS_____________________________________________________
      cDOMINIO := "03" // Fixo Impostos s/Saidas                001-002  02  Numerico
      cDOMINIO += strzero(nCONT,7) //Sequencial                 003-009  07  Numerico
      cDOMINIO += cICMS //Codigo do Imposto                     010-016  07  Numerico
      cDOMINIO += i_valida(SAI->Icm_red,5) //Red. Bc de Icms    017-021  05  Decimal(2)
      cDOMINIO += i_valida(SAI->Icm_base,13) //Base de Icms     022-034  13  Decimal(2)
      cDOMINIO += i_valida(SAI->Icm_aliq,5)  //Base de Icms     035-039  13  Decimal(2)
      cDOMINIO += i_valida(SAI->Icm_vlr,13)  //Vlr de Icms      040-052  13  Decimal(2)
      cDOMINIO += i_valida(SAI->Icm_isen,13) //Vlr de Isentas   053-065  13  Decimal(2)
      cDOMINIO += i_valida(SAI->Icm_out,13)  //Vlr de Outras    066-078  13  Decimal(2)
      cDOMINIO += space(50)       //Brancos                     079-128  50  AlfaNumerico
      nCONT++

      DOMINIO->(qappend())
      DOMINIO->Linha := cDOMINIO
      @ prow()+1,00 say left(cDOMINIO,128)

      cDOMINIO := ""



      SAI->(dbskip())
   enddo

return

static Function i_valida(nVALOR,nNUM)
local cValor := ""
   cVALOR := strzero(val(qtiraponto(str(nVALOR,nNUM,2))),nNUM)

return cVALOR

static function i_forn
local   cDOMINIO :=  ""
local   fICMS := 0

  cDIMINIO := ""
  DOMINIO->(__dbzap())

  Do While ! FORN->(Eof())
     cDOMINIO := "22"                         // 001 - 002     002       Fixo Clientes
     cDOMINIO += cEMP                         // 003 - 009     007       Codigo da Empresa
     CGM->(Dbseek(FORN->Cgm_ent))
     cDOMINIO += CGM->Estado                  // 010 - 011     002       Sigla do Estado
     cDOMINIO += "       "                    // 012 - 018     007       Codigo da Conta
     cDOMINIO += "       "                    // 019 - 025     007       Codigo do Municipio
     cDOMINIO += left(FORN->Fantasia,10)      // 026 - 035     010       Nome Reduzido
     cDOMINIO += left(FORN->Razao,40)         // 036 - 075     040       Nome do Cliente
     cDOMINIO += left(FORN->End_ent,40)       // 076 - 115     040       Endereco
     cDOMINIO += "       "                    // 116 - 122     007       Numero do Endereco
     cDOMINIO += space(30)                    // 123 - 152     030       Brancos
     cDOMINIO += FORN->Cep_ent                // 153 - 160     008       Cep
     cDOMINIO += FORN->Cgccpf                 // 161 - 174     014       CNPJ
     cDOMINIO += FORN->Inscricao+"     "      // 175 - 194     020       Inscricao Estadual
     cDOMINIO += left(FORN->Fone1,14)         // 195 - 208     014       Telefone
     cDOMINIO += left(FORN->Fax,14)           // 209 - 222     014       Fax
     cDOMINIO += "N"                          // 223 - 223     001       Agropecuario(S/N)
     cDOMINIO += FORN->Isento                 // 224 - 224     001       ICMS    (S/N)
     cDOMINIO += iif(right(FORN->Cgccpf,3) == "   ","2","1")                // 225 - 225     001       TIPO 1-Cnpj 2-Cpf 3-Cei 4-Outros
     cDOMINIO += space(20)                    // 226 - 245     020       Insc Municipal
     cDOMINIO += left(FORN->Bairro_ent,20)    // 246 - 265     020       Bairro
     cDOMINIO += space(4)                     // 266 - 269     004       DDD
     ESTADO->(Dbseek(CGM->Estado))
     fICMS := ESTADO->Aliq_dest
     //cDOMINIO += i_valida(fICMS,5)            // 270 - 274     005       aliq ICMS
     cDOMINIO += space(7)                     // 270 - 276     007       Codigo do Pais
     cDOMINIO += space(9)                     // 277 - 285     009       Inscricao na Suframa
     cDOMINIO += space(100)                   // 286 - 385     100       Brancos

      DOMINIO->(qappend())
      DOMINIO->Linha := cDOMINIO
      @ prow()+1 ,00 say left(cDOMINIO,385)

      cDOMINIO := ""


    FORN->(Dbskip())
  Enddo

  DOMINIO->(dbgotop())

  //DOMINIO->(__dbSDF( .T., "A:Clientes.TXT" , { },,,,, .T. ) )

  if DOMINIO->(qflock())
    DOMINIO->(__dbzap())
  endif


return

static function i_Cli
local   cDOMINIO :=  ""
local   fICMS := 0

  cDIMINIO := ""
  DOMINIO->(__dbzap())

  Do While ! CLI1->(Eof())
     cDOMINIO := "22"                         // 001 - 002     002       Fixo Clientes
     cDOMINIO += cEMP                         // 003 - 009     007       Codigo da Empresa
     CGM->(Dbseek(CLI1->Cgm_ent))
     cDOMINIO += CGM->Estado                  // 010 - 011     002       Sigla do Estado
     cDOMINIO += "       "                    // 012 - 018     007       Codigo da Conta
     cDOMINIO += "       "                    // 019 - 025     007       Codigo do Municipio
     cDOMINIO += left(CLI1->Fantasia,10)      // 026 - 035     010       Nome Reduzido
     cDOMINIO += left(CLI1->Razao,40)         // 036 - 075     040       Nome do Cliente
     cDOMINIO += left(CLI1->End_ent,40)       // 076 - 115     040       Endereco
     cDOMINIO += "       "                    // 116 - 122     007       Numero do Endereco
     cDOMINIO += space(30)                    // 123 - 152     030       Brancos
     cDOMINIO += CLI1->Cep_ent                // 153 - 160     008       Cep
     cDOMINIO += CLI1->Cgccpf                 // 161 - 174     014       CNPJ
     cDOMINIO += CLI1->Inscricao+"     "      // 175 - 194     020       Inscricao Estadual
     cDOMINIO += left(CLI1->Fone1,14)         // 195 - 208     014       Telefone
     cDOMINIO += left(CLI1->Fax,14)           // 209 - 222     014       Fax
     cDOMINIO += "N"                          // 223 - 223     001       Agropecuario(S/N)
     cDOMINIO += CLI1->Isento                 // 224 - 224     001       ICMS    (S/N)
     cDOMINIO += iif(right(CLI1->Cgccpf,3) == "   ","2","1")                // 225 - 225     001       TIPO 1-Cnpj 2-Cpf 3-Cei 4-Outros
     cDOMINIO += space(20)                    // 226 - 245     020       Insc Municipal
     cDOMINIO += left(CLI1->Bairro_ent,20)    // 246 - 265     020       Bairro
     cDOMINIO += space(4)                     // 266 - 269     004       DDD
     ESTADO->(Dbseek(CGM->Estado))
     fICMS := ESTADO->Aliq_dest
     cDOMINIO += i_valida(fICMS,5)            // 270 - 274     005       aliq ICMS
     cDOMINIO += space(7)                     // 275 - 281     007       Codigo do Pais
     cDOMINIO += space(9)                     // 282 - 290     009       Inscricao na Suframa
     cDOMINIO += space(100)                   // 291 - 390     100       Brancos

      DOMINIO->(qappend())
      DOMINIO->Linha := cDOMINIO
      @ prow()+1 ,00 say left(cDOMINIO,390)

      cDOMINIO := ""


    CLI1->(Dbskip())
  Enddo

  DOMINIO->(dbgotop())

  //DOMINIO->(__dbSDF( .T., "A:Clientes.TXT" , { },,,,, .T. ) )

  if DOMINIO->(qflock())
    DOMINIO->(__dbzap())
  endif


return




