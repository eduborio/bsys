  /////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE CONTAS A RECEBER
// OBJETIVO...: MANUTENCAO DE LAY-OUT DOS BANCOS
// ANALISTA...:
// PROGRAMADOR: LUCINEIDE
// INICIO.....: ABRIL DE 1997
// OBS........:
// ALTERACOES.:
function rb103

BANCO->(qview({{"Codigo/C¢digo"                          ,0},;
               {"Banco/Banco"                            ,1},;
               {"left(Descricao,30)/Nome"                ,2},;
               {"c103b()/Nr. Conta"                      ,0},;
               {"Agencia/Agˆncia"                        ,0},;
               {"Telefone/Telefone"                      ,0},;
               {"Gerente/Gerente"                        ,0}},"P",;
               {NIL,"c103a",NIL,NIL},;
                NIL,"<C>onsulta/<L>ay-out"))

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function c103a
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))
   if cOPCAO $ "C"
      qlbloc(9,4,"B103A","QBLOC.GLO",1)
      i_consulta()
   endif
   if cOPCAO $ "L"
      if ! BANCO->Banco $ "0038-0422-0353-0291-0033"
         qmensa("Banco sem acesso para Lay-out !","B")
         return
      endif
      do case
         case BANCO->Banco == "0038"
              fCOD_BANCO := BANCO->Banco
              l_0038()
         case BANCO->Banco == "0422"
              l_0422()
         case BANCO->Banco == "0353"
              l_0353()
         case BANCO->Banco == "0291"
              l_0291()
         case BANCO->Banco == "0033"
              l_0033()
      endcase
   endif

   setcursor(nCURSOR)
return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA RETRNAR A MASCARA DA CONTA ___________________________________

function c103b
return transform(BANCO->Conta,"@R 999999-9")

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A CONSULTA NA TELA __________________________________

static function i_consulta

   // MONTA DADOS NA TELA ___________________________________________________

      XNIVEL := 1
      qrsay ( XNIVEL++ , BANCO->Codigo     )
      qrsay ( XNIVEL++ , BANCO->Descricao  )
      qrsay ( XNIVEL++ , BANCO->Banco      )
      qrsay ( XNIVEL++ , BANCO->Agencia    )
      qrsay ( XNIVEL++ , transform(BANCO->Conta,"@R 999999-9"))
      qrsay ( XNIVEL++ , BANCO->End_agenc  )
      qrsay ( XNIVEL++ , BANCO->Cod_cgm    ) ; CGM->(Dbseek(BANCO->Cod_cgm))
      qrsay ( XNIVEL++ , left(CGM->Municipio,48))
      qrsay ( XNIVEL++ , BANCO->CEP        )
      qrsay ( XNIVEL++ , BANCO->Telefone   )
      qrsay ( XNIVEL++ , BANCO->Filial     ) ; FILIAL->(Dbseek(BANCO->Filial))
      qrsay ( XNIVEL++ , left(FILIAL->Razao,36))
      qrsay ( XNIVEL++ , BANCO->Gerente    )

      qwait()

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA DEFINIR LAY-OUT PARA BANCO ___________________________________

function l_0038

   //////////////////////////////////////////////////////////////////////////
   // DECLARACAO E INICIALIZACAO DE VARIAVEIS E RELACAO DE ARQUIVOS _________

   local lCONF   := .F.
   local aEDICAO := {}
   local bESCAPE   := {||(XNIVEL==1 .and. !XFLAG) .or. lastkey()==27}

   private cN_NUMERO := space(1)
   private cCARTEIRA := space(1)
   private cREMESSA  := space(1)
   private cESPECIE  := space(1)
   private cTITULOS  := space(1)
   private cAG_BANES := space(6)

   private sBLOCO1 := qlbloc("B103C","QBLOC.GLO")
   private sBLOCO2 := qlbloc("B103D","QBLOC.GLO")
   private sBLOCO3 := qlbloc("B103E","QBLOC.GLO")
   private sBLOCO4 := qlbloc("B103F","QBLOC.GLO")
   private sBLOCO5 := qlbloc("B103G","QBLOC.GLO")

   if LAY_OUT->(Dbseek(fCOD_BANCO))

      cN_NUMERO := LAY_OUT->N_numero
      cCARTEIRA := LAY_OUT->Carteira
      cREMESSA := LAY_OUT->Remessa
      cESPECIE := LAY_OUT->Especie
      cTITULOS := LAY_OUT->Titulos
      cAG_BANES:= LAY_OUT->Ag_banes

   endif

   // CRIACAO DO VETOR DE BLOCOS _______________________________________________

   aadd(aEDICAO,{{ || qesco(-1,0,@cN_NUMERO  ,SBLOCO1       )}, "N_NUMERO"    })
   aadd(aEDICAO,{{ || qesco(-1,0,@cCARTEIRA  ,SBLOCO2       )}, "CARTEIRA"    })
   aadd(aEDICAO,{{ || qesco(-1,0,@cREMESSA   ,SBLOCO3       )}, "REMESSA"     })
   aadd(aEDICAO,{{ || qesco(-1,0,@cESPECIE   ,SBLOCO4       )}, "ESPECIE"     })
   aadd(aEDICAO,{{ || qesco(-1,0,@cTITULOS   ,SBLOCO5       )}, "TITULOS"     })
   aadd(aEDICAO,{{ || qgetx(-1,0,@cAG_BANES  ,"999999"     ) } ,"AG_BANES"    })
   aadd(aEDICAO,{{ || lCONF := qconf("Confirma Lay-Out ?")}, NIL       })

   do while .T.

      qlbloc(9,8,"B103B","QBLOC.GLO")
      qmensa()

      XNIVEL  := 1

      // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

      do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
         eval ( aEDICAO [XNIVEL,1] )
         if eval ( bESCAPE ) ; return ; endif
         if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
         iif ( XFLAG , XNIVEL++ , XNIVEL-- )
      enddo

      if ! lCONF ; return ; endif

      if LAY_OUT->(dbseek(fCOD_BANCO))
         if LAY_OUT->(qrlock())
            replace LAY_OUT->N_numero with cN_NUMERO
            replace LAY_OUT->Carteira with cCARTEIRA
            replace LAY_OUT->Remessa  with cREMESSA
            replace LAY_OUT->Especie  with cESPECIE
            replace LAY_OUT->Titulos  with cTITULOS
            replace LAY_OUT->Ag_banes with cAG_BANES
         endif
      else
         if LAY_OUT->(qrlock()) .and. LAY_OUT->(qappend())
            replace LAY_OUT->Codigo   with fCOD_BANCO
            replace LAY_OUT->N_numero with cN_NUMERO
            replace LAY_OUT->Carteira with cCARTEIRA
            replace LAY_OUT->Remessa  with cREMESSA
            replace LAY_OUT->Especie  with cESPECIE
            replace LAY_OUT->Titulos  with cTITULOS
            replace LAY_OUT->Ag_banes with cAG_BANES
         endif
      endif

      LAY_OUT->(qunlock())

   enddo
return

return .T.

///////////////////////////////////////////////////////////////
static function i_critica ( cCAMPO )
do case
      case cCAMPO == "N_NUMERO"
           qrsay(XNIVEL,qabrev(cN_NUMERO,"12",{"Emissao Bloqueto P/Banco","Emissao Bloqueto P/empresa"}))

       case cCAMPO == "CARTEIRA"
            qrsay(XNIVEL,qabrev(cCARTEIRA,"1234",{"Cobranca Simples","Cobranca Escritural","Cobranca Caucinada P/Banco","Cobranca Caucionada P/Empresa"}))

       case cCAMPO == "REMESSA"
            qrsay(XNIVEL,qabrev(cREMESSA,"123456789",{"Remessa","Pedido de Baixa","Solicitacao de Abatimento","Solicitacao de Canc. de Abatimento","Alteracao no Vencimento","Alteracao s/Numero","Protestar","Nao Protestar","Sustar Protesto apos Tit. Cartorio"}))

       case cCAMPO == "ESPECIE"
            qrsay(XNIVEL,qabrev(cESPECIE,"123",{"Dpl. Prest de Servico","Recibo","Dpl. Mercantil","Outros"}))

       case cCAMPO == "TITULOS"
            qrsay(XNIVEL,qabrev(cTITULOS,"12",{"Aceito","N„o Aceito"}))
endcase
return .T.


///////////////////////////////////////////////////////////////
static function l_0353

   //////////////////////////////////////////////////////////////////////////
   // DECLARACAO E INICIALIZACAO DE VARIAVEIS E RELACAO DE ARQUIVOS _________

   local bESCAPE   := {||(XNIVEL==1 .and. !XFLAG) .or. lastkey()==27}

   private sBLOCO1 := qlbloc("B103O","QBLOC.GLO")
   private sBLOCO2 := qlbloc("B103P","QBLOC.GLO")
   private sBLOCO3 := qlbloc("B103Q","QBLOC.GLO")
   private sBLOCO4 := qlbloc("B103R","QBLOC.GLO")
   private sBLOCO5 := qlbloc("B103S","QBLOC.GLO")
   
   private aEDICAO := {}
   private cCARTEIRA
   private cOCORRENCIA
   private cESPECIE
   private cINSTRUCAO
   private cINSC_BANCO := space(10)
   private nNUMARQ     := 0
   private cDIAS_MULTA := space(2)
   private cIOF    := 0
   private cAGEN_CEDEN := space(5)
   private lCONF
   private lACHOU  := .F.

   if LAY_OUT->(Dbseek(BANCO->Banco))

      cCARTEIRA   := LAY_OUT->Carteira
      cOCORRENCIA := LAY_OUT->Ocorrencia
      cESPECIE    := LAY_OUT->Especie
      cINSTRUCAO  := LAY_OUT->Instrucao
      nNUMARQ     := LAY_OUT->Num_arq
      cINSC_BANCO := LAY_OUT->Insc_banco
      cIOF        := LAY_OUT->Iof
      cDIAS_MULTA := LAY_OUT->Dias_multa
      cAGEN_CEDEN := LAY_OUT->Agen_ceden

   endif

   // CRIACAO DO VETOR DE BLOCOS _______________________________________________

   aadd(aEDICAO,{{ || qesco(-1,0,@cCARTEIRA ,SBLOCO1           )}, "CARTEIRA"     })
   aadd(aEDICAO,{{ || qesco(-1,0,@cOCORRENCIA ,SBLOCO2         )}, "OCORRENCIA"   })
   aadd(aEDICAO,{{ || qesco(-1,0,@cESPECIE   ,SBLOCO3          )}, "ESPECIE"      })
   aadd(aEDICAO,{{ || qesco(-1,0,@cINSTRUCAO ,SBLOCO4          )}, "INSTRUCAO"    })
   aadd(aEDICAO,{{ || qgetx(-1,0,@nNUMARQ  ,"99"               )}, "NUMARQ"       })
   aadd(aEDICAO,{{ || qgetx(-1,0,@cINSC_BANCO ,"@!"            )}, "INSC_BANCO"   })
   aadd(aEDICAO,{{ || qgetx(-1,0,@cIOF     ,"99999999.99"      )}, "IOF"          })
   aadd(aEDICAO,{{ || qgetx(-1,0,@cDIAS_MULTA  ,"99"           )}, "DIAS_MULTA"   })
   aadd(aEDICAO,{{ || view_agenc(-1,0,@cAGEN_CEDEN            ) } ,"AGEN_CEDEN"   })
   aadd(aEDICAO,{{ || NIL                                         } ,NIL         })
   aadd(aEDICAO,{{ || lCONF := qconf("Confirma Grava‡„o ?")}, NIL       })

   do while .T.

      qlbloc(7,3,"B103N","QBLOC.GLO")
      qmensa()
      XNIVEL  := 1

      // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

      do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
         eval ( aEDICAO [XNIVEL,1] )
         if eval ( bESCAPE ) ; return ; endif
         if ! i_crit1( aEDICAO[XNIVEL,2] ) ; loop ; endif
         iif ( XFLAG , XNIVEL++ , XNIVEL-- )
      enddo

      if ! lCONF ; return ; endif

      if LAY_OUT->(dbseek(BANCO->Banco))
         if LAY_OUT->(qrlock())

            replace LAY_OUT->Carteira   with cCARTEIRA
            replace LAY_OUT->Ocorrencia with cOCORRENCIA
            replace LAY_OUT->Especie    with cESPECIE
            replace LAY_OUT->Instrucao  with cINSTRUCAO
            replace LAY_OUT->Num_arq    with nNUMARQ
            replace LAY_OUT->Insc_banco with cINSC_BANCO
            replace LAY_OUT->Iof        with cIOF
            replace LAY_OUT->Dias_multa with cDIAS_MULTA
            replace LAY_OUT->Agen_ceden with cAGEN_CEDEN

         endif

      else

         if LAY_OUT->(qrlock()) .and. LAY_OUT->(qappend())

            replace LAY_OUT->Codigo     with BANCO->Banco
            replace LAY_OUT->Carteira   with cCARTEIRA
            replace LAY_OUT->Ocorrencia with cOCORRENCIA
            replace LAY_OUT->Especie    with cESPECIE
            replace LAY_OUT->Instrucao  with cINSTRUCAO
            replace LAY_OUT->Num_arq    with nNUMARQ
            replace LAY_OUT->Insc_banco with cINSC_BANCO
            replace LAY_OUT->Iof        with cIOF
            replace LAY_OUT->Dias_multa with cDIAS_MULTA
            replace LAY_OUT->Agen_ceden with cAGEN_CEDEN

         endif
      endif

      LAY_OUT->(qunlock())

   enddo

   /////////////////////////////////////////////////////////////////////////////
   // CRITICA ADICIONAL NA DESCIDA _____________________________________________

   static function i_crit1 ( cCAMPO )

       do case
          case cCAMPO == "CARTEIRA"
               if empty(cCARTEIRA) ; return .F. ; endif
               qrsay ( XNIVEL , qabrev(cCARTEIRA,"235",{"2 - Cobran‡a Escritural - Simples","3 - Cobran‡a Caucionada","5 - Cobran‡a Direta - bloquete"}) )

          case cCAMPO == "OCORRENCIA"
               if empty(cOCORRENCIA) ; return .F. ; endif
               qrsay ( XNIVEL , qabrev(cOCORRENCIA,"124567890",{"1 - Entrada de T¡tulo","2 - Baixa de T¡tulo","4 - Concessao de abatimento",;
                     "5 - Cancelamento abatimento","6 - Altera‡„o de Vencimento","7 - Alt.Numero Cont.Cedente","8 - Altera‡„o do Seu Numero",;
                     "9 - Protestar              ","0 - Sustar Protesto        "}) )

          case cCAMPO == "ESPECIE"
               if empty(cESPECIE) ; return .F. ; endif
               qrsay ( XNIVEL , qabrev(cESPECIE,"12356",{"1 - Duplicata","2 - Nota Promiss¢ria","3 - Ap¢lice/Nota de Seguro","5 - Recibo","6 - DS - Duplicata de Servi‡os"}) )

          case cCAMPO == "INSTRUCAO"
               if empty(cINSTRUCAO) ; return .F. ; endif
               qrsay ( XNIVEL , qabrev(cINSTRUCAO,"0234678",{"0 - N„o h  Instru‡oes","2 - Baixar ap¢s 15 dias do Vcto","3 - Baixar ap¢s 30 dias do Vcto",;
                     "4 - N„o Baixar","6 - Protestar","7 - N„o Protestar","8 - N„o Cobrar Juros Mora"}) )

         case cCAMPO == "AGEN_CEDEN"
              if empty(cAGEN_CEDEN) ; return .F. ; endif
              if ! AGE_CED->(Dbseek(cAGEN_CEDEN))
                 qmensa("Agˆncia Cedente n„o Encontrada !", "B")
                 return .F.
              endif
              qrsay(XNIVEL+1, AGE_CED->Descricao)

       endcase

   return .T.


///////////////////////////////////////////////////////////////
static function l_0422

   //////////////////////////////////////////////////////////////////////////
   // DECLARACAO E INICIALIZACAO DE VARIAVEIS E RELACAO DE ARQUIVOS _________

   local bESCAPE   := {||(XNIVEL==1 .and. !XFLAG) .or. lastkey()==27}

   private sBLOCO1 := qlbloc("B103O","QBLOC.GLO")
   private sBLOCO2 := qlbloc("B103P","QBLOC.GLO")
   private sBLOCO3 := qlbloc("B103Q","QBLOC.GLO")
   private sBLOCO4 := qlbloc("B103R","QBLOC.GLO")
   private sBLOCO5 := qlbloc("B103S","QBLOC.GLO")
   
   private aEDICAO := {}
   private cCARTEIRA
   private cOCORRENCIA
   private cESPECIE
   private cINSTRUCAO
   private cACEITO
   private cIOF := 0
   private lCONF
   private lACHOU  := .F.

   if LAY_OUT->(Dbseek(BANCO->Banco))

      cCARTEIRA   := LAY_OUT->Carteira
      cOCORRENCIA := LAY_OUT->Ocorrencia
      cESPECIE    := LAY_OUT->Especie
      cINSTRUCAO  := LAY_OUT->Instrucao
      cACEITO     := LAY_OUT->Aceito
      cIOF        := LAY_OUT->Iof

   endif

   // CRIACAO DO VETOR DE BLOCOS _______________________________________________

   aadd(aEDICAO,{{ || qesco(-1,0,@cCARTEIRA   ,SBLOCO1          )}, "CARTEIRA"    })
   aadd(aEDICAO,{{ || qesco(-1,0,@cOCORRENCIA ,SBLOCO2          )},"OCORRENCIA"   })
   aadd(aEDICAO,{{ || qesco(-1,0,@cESPECIE    ,SBLOCO3          )}, "ESPECIE"     })
   aadd(aEDICAO,{{ || qesco(-1,0,@cINSTRUCAO  ,SBLOCO4          )}, "INSTRUCAO"   })
   aadd(aEDICAO,{{ || qesco(-1,0,@cACEITO     ,SBLOCO5          )}, "ACEITO"      })
   aadd(aEDICAO,{{ || qgetx(-1,0,@cIOF  ,"@E 9,999,999.99"      )} ,"IOF"         })
   aadd(aEDICAO,{{ || lCONF := qconf("Confirma Grava‡„o ?")}, NIL       })

   do while .T.

      qlbloc(10,5,"B103N","QBLOC.GLO")
      qmensa()
      XNIVEL  := 1

      // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

      do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
         eval ( aEDICAO [XNIVEL,1] )
         if eval ( bESCAPE ) ; return ; endif
         if ! i_crit2( aEDICAO[XNIVEL,2] ) ; loop ; endif
         iif ( XFLAG , XNIVEL++ , XNIVEL-- )
      enddo

      if ! lCONF ; return ; endif

      if LAY_OUT->(dbseek(BANCO->Banco))
         if LAY_OUT->(qrlock())

            replace LAY_OUT->Carteira   with cCARTEIRA
            replace LAY_OUT->Ocorrencia with cOCORRENCIA
            replace LAY_OUT->Especie    with cESPECIE
            replace LAY_OUT->Instrucao  with cINSTRUCAO
            replace LAY_OUT->Aceito     with cACEITO
            replace LAY_OUT->Iof        with cIOF
         endif

      else

         if LAY_OUT->(qrlock()) .and. LAY_OUT->(qappend())

            replace LAY_OUT->Codigo     with BANCO->Banco
            replace LAY_OUT->Carteira   with cCARTEIRA
            replace LAY_OUT->Ocorrencia with cOCORRENCIA
            replace LAY_OUT->Especie    with cESPECIE
            replace LAY_OUT->Instrucao  with cINSTRUCAO
            replace LAY_OUT->Aceito     with cACEITO
            replace LAY_OUT->Iof        with cIOF

         endif
      endif

      LAY_OUT->(qunlock())

   enddo

   /////////////////////////////////////////////////////////////////////////////
   // CRITICA ADICIONAL NA DESCIDA _____________________________________________

   static function i_crit2 ( cCAMPO )

       do case
          case cCAMPO == "CARTEIRA"
               if empty(cCARTEIRA) ; return .F. ; endif
               qrsay ( XNIVEL , qabrev(cCARTEIRA,"12346",{"1 - Cobran‡a  Simples","2 - Cobran‡a Vinculada","3 - Cobran‡a Seriada","4 - Cobranca de Seguros","6 - Cobranca Especial"}) )

          case cCAMPO == "OCORRENCIA"
               if empty(cOCORRENCIA) ; return .F. ; endif
               qrsay ( XNIVEL , qabrev(cOCORRENCIA,"ABCDEFGHIJKLM",{"A - Remessao de T¡tulos","B - Pedido de Baixa","C -            ",;
                     "D - Concess„o de Abatimento","E - Cancelamento de Abatimeno","F - Alteracao de Vencimento","G - Altera‡„o - uso exclusivo",;
                     "H - Alteracao do Seu Numero","I - Pedido de Protesto       ","J - Nao Protestar          ","K - Nao cobrar Juros de Mora ",;
                     "L - Pedido de Entrega Pgto ","M - Cobrar juros de mora"}) )

          case cCAMPO == "ESPECIE"
               if empty(cESPECIE) ; return .F. ; endif
               qrsay ( XNIVEL , qabrev(cESPECIE,"123459",{"1 - Duplicata",;
                                                          "2 - Nota Promiss¢ria",;
                                                          "3 - Nota de Seguro",;
                                                          "4 - Cobranca Seriada",;
                                                          "5 - Recibo",;
                                                          "9 - Duplicata de Servico"}) )

          case cCAMPO == "INSTRUCAO"
               if empty(cINSTRUCAO) ; return .F. ; endif
               qrsay ( XNIVEL , qabrev(cINSTRUCAO,"1234678",{"1 - N„o receber Princ. s/juros mora",;
                                                             "2 - Devolver ate 15 dias apos o Vcto",;
                                                             "3 - Devolver ate 30 dias apos o Vcto",;
                                                             "4 - Devolver a Pedido",;
                                                             "6 - Protestar",;
                                                             "7 - N„o Protestar",;
                                                             "8 - N„o Cobrar Juros Mora"}) )

          case cCAMPO == "ACEITO"
               if empty(cACEITO) ; return .F. ; endif
               qrsay ( XNIVEL , qabrev(cACEITO,"AN",{"A - Aceito","N - N„o Aceito"}) )

       endcase

   return .T.



///////////////////////////////////////////////////////////////
static function l_0291

   //////////////////////////////////////////////////////////////////////////
   // DECLARACAO E INICIALIZACAO DE VARIAVEIS E RELACAO DE ARQUIVOS _________

   local bESCAPE   := {||(XNIVEL==1 .and. !XFLAG) .or. lastkey()==27}

   private sBLOCO1 := qlbloc("B103U","QBLOC.GLO")
   private sBLOCO2 := qlbloc("B103V","QBLOC.GLO")
   private sBLOCO3 := qlbloc("B103X","QBLOC.GLO")
   private sBLOCO4 := qlbloc("B103S","QBLOC.GLO")
   
   private aEDICAO := {}
   private cNOSS_NUM
   private cCARTEIRA
   private cOCORRENCIA
   private cESPECIE
   private cACEITO
   private cIOF    := 0
   private lCONF
   private lACHOU  := .F.

   if LAY_OUT->(Dbseek(BANCO->Banco))

      cCARTEIRA   := LAY_OUT->Carteira
      cOCORRENCIA := LAY_OUT->Ocorrencia
      cESPECIE    := LAY_OUT->Especie
      cIOF        := LAY_OUT->Iof
      cACEITO     := LAY_OUT->Aceito
      cNOSS_NUM   := LAY_OUT->Noss_num
   endif

   // CRIACAO DO VETOR DE BLOCOS _______________________________________________

   aadd(aEDICAO,{{ || qesco(-1,0,@cCARTEIRA   ,SBLOCO1         )}, "CARTEIRA"     })
   aadd(aEDICAO,{{ || qesco(-1,0,@cOCORRENCIA ,SBLOCO2         )}, "OCORRENCIA"   })
   aadd(aEDICAO,{{ || qesco(-1,0,@cESPECIE    ,SBLOCO3         )}, "ESPECIE"      })
   aadd(aEDICAO,{{ || qesco(-1,0,@cACEITO     ,SBLOCO4         )}, "ACEITO"       })
   aadd(aEDICAO,{{ || qgetx(-1,0,@cNOSS_NUM   ,"9999999"       )}, "NOSS_NUM"     })
   aadd(aEDICAO,{{ || qgetx(-1,0,@cIOF     ,"99999999.99"      )}, "IOF"          })
   aadd(aEDICAO,{{ || lCONF := qconf("Confirma Grava‡„o ?")}, NIL       })

   do while .T.

      qlbloc(11,3,"B103T","QBLOC.GLO")
      qmensa()
      XNIVEL  := 1

      // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

      do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
         eval ( aEDICAO [XNIVEL,1] )
         if eval ( bESCAPE ) ; return ; endif
         if ! i_crit3( aEDICAO[XNIVEL,2] ) ; loop ; endif
         iif ( XFLAG , XNIVEL++ , XNIVEL-- )
      enddo

      if ! lCONF ; return ; endif

      if LAY_OUT->(dbseek(BANCO->Banco))

         if LAY_OUT->(qrlock())

            replace LAY_OUT->Carteira   with cCARTEIRA
            replace LAY_OUT->Ocorrencia with cOCORRENCIA
            replace LAY_OUT->Especie    with cESPECIE
            replace LAY_OUT->Aceito     with cACEITO
            replace LAY_OUT->Iof        with cIOF
            replace LAY_OUT->Noss_num   with cNOSS_NUM

         endif

      else

         if LAY_OUT->(qrlock()) .and. LAY_OUT->(qappend())

            replace LAY_OUT->Codigo     with BANCO->Banco
            replace LAY_OUT->Carteira   with cCARTEIRA
            replace LAY_OUT->Ocorrencia with cOCORRENCIA
            replace LAY_OUT->Especie    with cESPECIE
            replace LAY_OUT->Aceito     with cACEITO
            replace LAY_OUT->Iof        with cIOF
            replace LAY_OUT->Noss_num   with cNOSS_NUM

         endif
      endif

      LAY_OUT->(qunlock())

   enddo

   /////////////////////////////////////////////////////////////////////////////
   // CRITICA ADICIONAL NA DESCIDA _____________________________________________

   static function i_crit3 ( cCAMPO )

       do case
          case cCAMPO == "CARTEIRA"
               if empty(cCARTEIRA) ; return .F. ; endif
               qrsay ( XNIVEL , qabrev(cCARTEIRA,"12",{"1-Cob.Simples",;
                                                       "2-Cob.Caucionada"}) )

          case cCAMPO == "OCORRENCIA"
               if empty(cOCORRENCIA) ; return .F. ; endif
               qrsay ( XNIVEL , qabrev(cOCORRENCIA,"1234567",{"1 - Remessa",;
                                                              "2 - Pedido de Baixa",;
                                                              "3 - Concessao de Abat",;
                                                              "4 - Canc. abatimento",;
                                                              "5 - Alter. Vencimento",;
                                                              "6 - Protestar",;
                                                              "7 - Sust. Protesto"}))

          case cCAMPO == "ESPECIE"
               if empty(cESPECIE) ; return .F. ; endif
               qrsay ( XNIVEL , qabrev(cESPECIE,"12345",{"1 - Duplicata",;
                                                         "2 - Nota Promiss¢ria",;
                                                         "3 - Nota de Seguro",;
                                                         "4 - Recibo",;
                                                         "5 - Outros Casos"}) )

          case cCAMPO == "ACEITO"
               if empty(cACEITO) ; return .F. ; endif
               qrsay ( XNIVEL , qabrev(cACEITO,"AN",{"A - Aceito","N - N„o Aceito"}) )

       endcase

   return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA DEFINIR LAY-OUT PARA BANCO ___________________________________

function l_0033

   //////////////////////////////////////////////////////////////////////////
   // DECLARACAO E INICIALIZACAO DE VARIAVEIS E RELACAO DE ARQUIVOS _________

   local lCONF   := .F.
   local aEDICAO := {}
   local bESCAPE   := {||(XNIVEL==1 .and. !XFLAG) .or. lastkey()==27}

   private cOCORRENCIA := space(1)
   private cTITULOS    := space(1)
   private cINSTRUCAO  := space(1)
   private cACEITO     := space(1)

   private sBLOCO1 := qlbloc("B1032","QBLOC.GLO")
   private sBLOCO2 := qlbloc("B1033","QBLOC.GLO")
   private sBLOCO3 := qlbloc("B1034","QBLOC.GLO")
   private sBLOCO4 := qlbloc("B1035","QBLOC.GLO")

   if LAY_OUT->(Dbseek(BANCO->Codigo))

      cOCORRENCIA := LAY_OUT->Ocorrencia
      cTITULOS    := LAY_OUT->Titulos
      cINSTRUCAO  := LAY_OUT->Instrucao
      cACEITO     := LAY_OUT->Aceito

   endif

   // CRIACAO DO VETOR DE BLOCOS _______________________________________________

   aadd(aEDICAO,{{ || qesco(-1,0,@cOCORRENCIA  ,SBLOCO1       )}, "OCORRENCIA"    })
   aadd(aEDICAO,{{ || qesco(-1,0,@cTITULOS  ,SBLOCO2          )}, "TITULOS"       })
   aadd(aEDICAO,{{ || qesco(-1,0,@cINSTRUCAO,SBLOCO3          )}, "INSTRUCAO"     })
   aadd(aEDICAO,{{ || qesco(-1,0,@cACEITO,SBLOCO4             )}, "ACEITO"        })
   aadd(aEDICAO,{{ || lCONF := qconf("Confirma Lay-Out ?")}, NIL                  })

   do while .T.

      qlbloc(6,6,"B1031","QBLOC.GLO")
      qmensa()

      XNIVEL  := 1

      // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

      do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
         eval ( aEDICAO [XNIVEL,1] )
         if eval ( bESCAPE ) ; return ; endif
         if ! i_crit_5( aEDICAO[XNIVEL,2] ) ; loop ; endif
         iif ( XFLAG , XNIVEL++ , XNIVEL-- )
      enddo

      if ! lCONF ; return ; endif

      if LAY_OUT->(dbseek(BANCO->Codigo))
         if LAY_OUT->(qrlock())
            replace LAY_OUT->Ocorrencia with cOCORRENCIA
            replace LAY_OUT->Titulos    with cTITULOS
            replace LAY_OUT->Instrucao  with cINSTRUCAO
            replace LAY_OUT->Aceito     with cACEITO
         endif
      else
         if LAY_OUT->(qrlock()) .and. LAY_OUT->(qappend())
            replace LAY_OUT->Codigo     with BANCO->Banco
            replace LAY_OUT->Ocorrencia with cOCORRENCIA
            replace LAY_OUT->Titulos    with cTITULOS
            replace LAY_OUT->Aceito     with cACEITO
         endif
      endif

      LAY_OUT->(qunlock())

   enddo
return

return .T.

///////////////////////////////////////////////////////////////
static function i_crit_5 ( cCAMPO )

do case
      case cCAMPO == "OCORRENCIA"
           qrsay(XNIVEL,qabrev(cOCORRENCIA,"ABCDEFGHI",{"A - Remessa",;
                                                        "B - Pedido de Baixa",;
                                                        "C - Concessao de abatimento",;
                                                        "D - Cancelamento abatimento",;
                                                        "E - Alteracao de vencimento",;
                                                        "F - Alteracao do campo -Ident.do tit. da emp.",;
                                                        "G - Alteracao do Numero do documento",;
                                                        "H - Protestar",;
                                                        "I - N„o Protestar"}))
       case cCAMPO == "TITULOS"
           qrsay(XNIVEL,qabrev(cTITULOS,"ABCDEFGHIJKLMN",{"A - Duplicata Mercantil",;
                                                          "B - Nota Promissoria",;
                                                          "C - Nota de Seguro",;
                                                          "D - Recibo",;
                                                          "E - Nota de Debito",;
                                                          "F - Warrant",;
                                                          "G - Nota Promissoria em IGPM",;
                                                          "H - Letras de Cambio",;
                                                          "I - Duplicata de servico",;
                                                          "J - Duplicata Mercantil em IGPM",;
                                                          "K - Nota Promissoria em UFIR",;
                                                          "L - Nota de Seguro em IDTR",;
                                                          "M - Fatura"}))
       case cCAMPO == "INSTRUCAO"
           qrsay(XNIVEL,qabrev(cINSTRUCAO,"ABCDEFGHIJKLMN",{"A - N„o receber o princ s/ juros de mora",;
                                                            "B - Protestar",;
                                                            "C - N„o Protestar",;
                                                            "D - N„o cobrar juros de mora",;
                                                            "E - Tolerancia de 10 d p/ cob. de juros",;
                                                            "F - Tolerancia de 15 d p/ cob. de juros",;
                                                            "G - Instr. especial do manual do banco",;
                                                            "H - vencido cobrar juro cfe tx prat. BCO",;
                                                            "I - vencido, cobrar 10% mais juros acima",;
                                                            "J - vencido, cobrar 15% mais juros acima",;
                                                            "K - vencido, cobrar 20% mais juros acima",;
                                                            "L - N„o receber antes do vencimento",;
                                                            "M - Pagto. cartorio n„o isenta cob.de mora",;
                                                            "N - Vencido variacao UFIR pagto/vcto"}))
       case cCAMPO == "ACEITO"
           qrsay(XNIVEL,qabrev(cACEITO,"AN",{"A - Aceito",;
                                             "N - N„o Aceito"}))


endcase
return .T.

