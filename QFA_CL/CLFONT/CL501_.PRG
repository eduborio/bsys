/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO DA USIMIX
// OBJETIVO...: LISTAGEM DE CLIENTES
// ANALISTA...: LUIS ANTONIO ORLANDO PEREIRA
// PROGRAMADOR: PAULO FOGACA
// INICIO.....: OUTUBRO DE 1995
// OBS........:
// ALTERACOES.: LUIS - 01/11/95 - INCLUSAO DE FILTRO POR FILIAL

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________
function cl501

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG .or. lastkey()==27)}

private sBLOC1  := qlbloc("B101B","QBLOC.GLO") // Relatorio morto ou clientes ativos
private sBLOC2  := qlbloc("B501B","QBLOC.GLO") // Ordem Codigo ou Razao
private sBLOC3  := qlbloc("B501C","QBLOC.GLO") // Modelo para impressao

private cTITULO          // titulo do relatorio
private cTITULO2          // titulo do relatorio
private cTIPO            // Relatorio morto ou clientes ativos
private cORDEM           // Ordem do Relatorio
private cMODELO          // Modelo de impressao
private aEDICAO := {}    // vetor para os campos de entrada de dados
private cALIAS           // alias para os arquivos
private cFILIAL          // filial
private cCOMPAC          // define tipo de compatacao
private cVEND            // define vendedor do cliente
private cAREA            // define Area de Venda do cliente
private cDOC             // define Area de Venda do cliente
private cREPRES          // define Area de Venda do cliente
private cCLIENTE1        // DEFINE CLIENTE INICIAL DO RELATORIO
private cCLIENTE2        // DEFINE CLIENTE FINAL DO RELATORIO
private cTime1
private cTime2
private cSQL :=""

//fu_abre_ccusto()

// CRIACAO DO VETOR DE BLOCOS _______________________________________________


//quse("","QINDEX")

//cSQL := "select Codigo,Razao,cgccpf,cod_repres,cod_vend,cod_area,tipo_doc,fone1,contato_c from CLI1"

//quse("","CLI1",{""},"","CLI1","QRDD",cSQL)

//QINDEX->(dbclosearea())

aadd(aEDICAO,{{ || view_cli3(-1,0,@cCLIENTE1 )  } , "CLIENTE1"})
aadd(aEDICAO,{{ || view_cli3(-1,0,@cCLIENTE2 )  } , "CLIENTE2"})
aadd(aEDICAO,{{ || qesco(-1,0,@cTIPO  ,sBLOC1)  } , "TIPO"    })
aadd(aEDICAO,{{ || qesco(-1,0,@cORDEM ,sBLOC2)  } , "ORDEM"   })
aadd(aEDICAO,{{ || NIL                           }, "AREA"    })
aadd(aEDICAO,{{ || NIL                           },  NIL      }) // descricao da Area de Venda
aadd(aEDICAO,{{ || NIL                           },"VEND"  })
aadd(aEDICAO,{{ || NIL                           },NIL        }) // descricao do Vendedor
aadd(aEDICAO,{{ || view_repres(-1,0,@cREPRES ,"@e 99999")},"REPRES"  })
aadd(aEDICAO,{{ || NIL                           },NIL        }) // descricao do Vendedor

aadd(aEDICAO,{{ || NIL                           },"DOC"  })
aadd(aEDICAO,{{ || NIL                           },NIL        }) // descricao do Vendedor


aadd(aEDICAO,{{ || qesco(-1,0,@cMODELO,sBLOC3)  } , "MODELO" })
aadd(aEDICAO,{{ || NIL                          } , "FILIAL" })
aadd(aEDICAO,{{ || NIL },NIL})           // descricao da filial

do while .T.

   qlbloc(5,0,"B501A","QBLOC.GLO",1)

   XNIVEL  := 1
   XFLAG   := .T.
   cORDEM  := " "
   cTIPO   := " "
   cFILIAL := "    "
   cVEND   := space(5)
   cREPRES := space(5)
   cAREA   := space(2)
   cDOC    := space(2)
   cCLIENTE1   := space(5)
   cCLIENTE2   := space(5)

   // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; dbcloseall() ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ); loop   ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo


   cTime1 := Time()
   if ( i_inicializacao() , i_impressao() , NIL )

   qmensa("")

enddo

/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA _____________________________________________

static function i_critica ( cCAMPO )

   do case
      case cCAMPO == "TIPO"
           if empty(cTIPO) ; return .F. ; endif
           qrsay(XNIVEL,qabrev(cTIPO,"12",{"Clientes Ativos","Arquivo Morto"}))
           cALIAS := "CLI" + cTIPO
      case cCAMPO == "ORDEM"
           if empty(cORDEM) ; return .F. ; endif
           qrsay(XNIVEL,qabrev(cORDEM,"123",{"Codigo","Razao","Fantasia"}))
      case cCAMPO == "MODELO"
           if empty(cMODELO) ; return .F. ; endif
           qrsay(XNIVEL,qabrev(cMODELO,"123",{"Resumido ( 80 Col.)","Completo (132 Col.)","Cadastral"}))

      case cCAMPO == "REPRES"
           if empty(cREPRES)
              qrsay( XNIVEL+1, "Todos os Representantes......")
           else
              if ! REPRES->(dbseek(cREPRES:=strzero(val(cREPRES),5)))
                 qmensa("Representante nao cadastrado ! ")
                 return .F.
              endif
              qrsay( XNIVEL , cREPRES              )
              qrsay( XNIVEL+1,left(REPRES->Razao,25))
           endif


   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // DEFINE VARIAVEL DE COMPACTACAO ________________________________________

   iif(cMODELO=="2",cCOMPAC:="XCOND2",cCOMPAC:="XCOND1")

   // CRIA TITULO DO RELATORIO ______________________________________________

   cTITULO  := "LISTAGEM GERAL DE CLIENTES - AREA: " + iif(empty(cAREA),"TODAS",AREA->Codigo+" "+AREA->Descricao)
   if ! empty(cREPRES)
      cTITULO2 := "Representante "+REPRES->Razao
   else
      CTitulo2 := "Todos os Representantes"
   endif

   // SELECIONA ORDEM DO ARQUIVO CLIENTE ____________________________________

   if cORDEM == "1"
     (cALIAS)->(dbsetorder(val(cORDEM)))
   elseif cORDEM == "2"
     (cALIAS)->(dbsetorder(2))
   else
     (cALIAS)->(dbsetorder(6))
   endif
   qmensa("")

   // ESTABELECE RELACOES ENTRE ARQUIVOS ____________________________________

   (cALIAS)->(dbgotop())
   if cORDEM == "1"
      if empty(cCLIENTE2)
         (cALIAS)->(Dbgobottom())
         cCLIENTE2 := (cALIAS)->Codigo
      endif

      (cALIAS)->(dbgotop())
      if empty(cCLIENTE1)
        (cALIAS)->(Dbgotop())
        cCLIENTE1 := (cALIAS)->Codigo
      else
        (cALIAS)->(dbseek(cCLIENTE1))
      endif


   endif
return .T.

static function i_impressao
   if ! qinitprn() ; return  ; endif

   if XLOCALIMP == "X"
      i_impre_xls()
   else
      i_impre_prn()
   endif


/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impre_prn

   local cMUN_ENT , cMUN_COB , cEST_ENT , cEST_COB

   local nMAXLIN := iif(cMODELO=="3",53,60)

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   //if ! qinitprn() ; return ; endif

   @ prow(),pcol() say &cCOMPAC

   do while ! (cALIAS)->(eof()) // condicao principal de loop

      //if ! qlineprn() ; exit ; endif

      if ! empty(cVEND) .and. (cALIAS)->(Cod_vend) <> cVEND
         (cALIAS)->(dbskip())
         loop
      endif

      if ! empty(cAREA) .and. (cALIAS)->(Cod_area) <> cAREA
         (cALIAS)->(dbskip())
         loop
      endif

      if ! empty(cDOC) .and. (cALIAS)->(Tipo_doc) <> cDOC
         (cALIAS)->(dbskip())
         loop
      endif


      if ! empty(cREPRES) .and. (cALIAS)->(Cod_repres) <> cREPRES
         (cALIAS)->(dbskip())
         loop
      endif


      if XPAGINA == 0 .or. prow() > nMAXLIN
         qpageprn()

         do case
            case cMODELO == "1"
                 @ prow()+1,0 say XCOND1
                 qcabecprn(cTITULO,135,,cTITULO2)
                 @ prow()+1,0 say "CODIGO RAZAO                                                             CGC/CPF        FONE           CONTATO               VEND  AREA"
                 @ prow()+1,0 say replicate("-",135)
            case cMODELO == "2"
                 qcabecprn(cTITULO,252,,cTITULO2)
                 @ prow()+1,0 say "CODIGO RAZAO                            CGC/CPF       INSCRICAO    ENDERECO DE ENTREGA            " +;
                                  "MUNICIPIO       UF CEP ENT. ENDERECO DE COBRANCA           MUNICICIPIO     UF CEP COB.   TELEFONE-1   RAMAL " +;
                                  "TELEFONE-FAX  CONT.COMERC   CONT.FIN.   FILIAL" + " COD   VENDEDOR" + SPACE(43)+"COD AREA DE VENDA"
                                  @ prow()+1,0 say replicate("-",252)
            case cMODELO == "3"
                 @ prow()+1,0 say XCOND1

                 qcabecprn(cTITULO,135,,cTITULO2)
         endcase
      endif
   
      do case
         case cMODELO == "1"
              if empty(cFILIAL) .or. cFILIAL == (cALIAS)->Filial
                 @ prow()+1,0 say (cALIAS)->Codigo + space(2) + left((cALIAS)->Razao,61) + space(1) + fu_conv_cgccpf((cALIAS)->CgcCpf) +;
                                                     space(1) + (cALIAS)->Fone1          + space(1) + (cALIAS)->Contato_C +;
                                                     space(2) + (cALIAS)->Cod_vend       + space(1) + (cALIAS)->Cod_Area
              endif

         case cMODELO == "2"
              if empty(cFILIAL) .or. cFILIAL == (cALIAS)->Filial

                 CGM->(dbseek((cALIAS)->Cgm_ent))
                 cMUN_ENT := left(CGM->Municipio,15) + " " + CGM->Estado
                 CGM->(dbseek((cALIAS)->Cgm_cob))
                 cMUN_COB := left(CGM->Municipio,15) + " " + CGM->Estado
                 VEND->(dbseek(CLI1->Cod_vend))
                 AREA->(dbseek(CLI1->Cod_area))

                 qmensa("Imprimindo Cliente...: "  + (cALIAS)->Codigo+" / RazÑo: "+(cALIAS)->Razao)

                 @ prow()+1,0 say (cALIAS)->Codigo + space(2) + left((cALIAS)->Razao,29)         + space(1) + (cALIAS)->Cgccpf +;
                                                     space(1) + (cALIAS)->Inscricao + space(1)   + left((cALIAS)->End_ent,30)  +;
                                                     space(1) + cMUN_ENT            + space(1)   + (cALIAS)->Cep_ent           +;
                                                     space(1) + left((cALIAS)->End_cob,30)       + space(1) + cMUN_COB         +;
                                                     space(1) + (cALIAS)->Cep_cob   + space(1)   + (cALIAS)->Fone1             +;
                                                     space(1) + (cALIAS)->Ramal1    + space(1)   + (cALIAS)->Fax               +;
                                                     space(1) + left((cALIAS)->Contato_c,12)     + space(1)                    +;
                                                     left((cALIAS)->Contato_f,12)   + space(2)   + (cALIAS)->Filial            +;
                                                     space(2) + CLI1->Cod_vend + space(1) + (VEND->Nome) + space(1) + CLI1->Cod_area + space(2) + AREA->Descricao
               @ prow()+1,0 say ""
              endif

         case cMODELO == "3"
              if empty(cFILIAL) .or. cFILIAL == (cALIAS)->Filial

                 CGM->(dbseek((cALIAS)->Cgm_ent))
                 cMUN_ENT := CGM->Municipio
                 cEST_ENT := CGM->Estado
                 CGM->(dbseek((cALIAS)->Cgm_cob))
                 FILIAL->(dbseek((cALIAS)->Filial))
                 VEND->(dbseek(CLI1->Cod_vend))
                 AREA->(dbseek(CLI1->Cod_area))

                 qmensa("Imprimindo Cliente...: "+(cALIAS)->Codigo+" / RazÑo: "+(cALIAS)->Razao)

                 @ prow()+1,0 say "CODIGO: "  +  (cALIAS)->Codigo  + space(5)      + "RAZAO: " + left((cALIAS)->Razao,50) +;
                                   space (3) +  "FANTASIA: "      + (cALIAS)->Fantasia
                 @ prow()+1,0 say "CGC/CPF: " +  fu_conv_cgccpf((cALIAS)->Cgccpf)   + space(9)  + "INSCRICAO: "   + (cALIAS)->Inscricao +;
                                   space(9)   +  "ENDERECO ENT.: " + (cALIAS)->End_ent
                 @ prow()+1,0 say "MUNICIPIO ENT.: " + left(cMUN_ENT,24) + space(2) + "UF: "    + cEST_ENT +;
                                   space(2)   +  "CEP ENT.: " + transform((cALIAS)->Cep_ent,"@R 99999-999")+;
                                   space(1)   +  "BAIRRO.: " +(cALIAS)->Bairro_ent

                 @ prow()+1,0 say "TELEF.-1: " + (cALIAS)->Fone1 + space(2) + "RAMAL: " + (cALIAS)->Ramal1 +;
                                   space(4)   +  "TELEF.-2: " + (cALIAS)->Fone2
                 @ prow()+1,0 say  "FAX: "  + (cALIAS)->Fax +;
                                   space(2)   +  "CONT. COMER.: "  + (cALIAS)->Contato_c   + space(2)  + "CONT. FINAN.: " + (cALIAS)->Contato_f

                 @ prow()+1,0 say  "COD.: "  + (cALIAS)->Cod_vend + " VENDEDOR.: "+ VEND->Nome +;
                                   space(5) + "COD: " + CLI1->Cod_area +space(2)+ "AREA DE VENDA.: " + left(AREA->Descricao,25)


                 @ prow()+1,0 say "FILIA.........: " + (cALIAS)->Filial + "-"  + left(FILIAL->Razao,40)
                 @ prow()+1,000 say ""
              endif
      endcase
      if cORDEM == "1"
         if (cALIAS)->Codigo == cCLIENTE2
            exit
         endif
      endif
      (cALIAS)->(dbskip())
   enddo

   cTime2 := Time()

   alert(qdifhora(cTime1,cTime2))


   qstopprn()

return

static function i_impre_xls
nFile := 0
cSql := ""
cEnd := chr(13) + chr(10)

   do while ! CLI1->(eof()) // condicao principal de loop

      //if ! qlineprn() ; exit ; endif

      if ! empty(cVEND) .and. CLI1->Cod_vend <> cVEND
         CLI1->(dbskip())
         loop
      endif
	  
	  if ! empty(cREPRES) .and. CLI1->Cod_repres <> cREPRES
         CLI1->(dbskip())
         loop
      endif
	  
	  

      if XPAGINA == 0 // .or. prow() > 55
         qpageprn()
         @ prow()+1,0 say chr(9)+cTITULO
         @ prow()+1,0 say "Cod."+chr(9)+"Razao"+Chr(9)+"C.N.P.J."+chr(9)+"Endereco"+chr(9)+"Bairro"+chr(9)+"Cep"+chr(9)+"Telefone"+chr(9)+"Contato"+chr(9)+"Municipio"+chr(9)+"Estado"+chr(9)+"Aniversario do Contato"+chr(9)+"Email"+chr(9)+"Transportadora"+chr(9)+"Corrente Eletrica"
		 @ prow()+1,0 say chr(9)+cTITULO2
      endif

      @ prow()+1,0 say CLI1->Codigo + chr(9) + left(CLI1->Razao,61) + chr(9) + fu_conv_cgccpf(CLI1->CgcCpf)
      @ prow()  ,pcol() say chr(9) + rtrim(CLI1->End_ent) +", "+ CLI1->Numero + " " + CLI1->Compl + chr(9)+CLI1->Bairro_Ent+chr(9)+CLI1->Cep_ent +chr(9)+ CLI1->Fone1
      CGM->(Dbseek(CLI1->Cgm_ent))
      TRANSP->(Dbseek(CLI1->Cod_Transp))
      @ prow()  ,pcol() say chr(9) + CLI1->Contato_C + chr(9)+CGM->Municipio+chr(9)+CGM->Estado
      @ prow()  ,pcol() say chr(9) + CLI1->Dt_aniver + chr(9)+ CLI1->Email +chr(9)+TRANSP->Razao+chr(9)+CLI1->Voltagem
	  
	  //if CLI1->Isento == "N"
	  //   alert("Cliente esta como ISento do Icms" +" "+CLI1->Razao+" "+CGM->Estado)
	  //endif	 

      if cORDEM == "1"
         if CLI1->Codigo == cCLIENTE2
            exit
         endif
      endif
      CLI1->(dbskip())
   enddo

   cTime2 := Time()

   alert(qdifhora(cTime1,cTime2))


   qstopprn()
   
return


static function i_trocachr(cTROCADO)

   cTROCADO := strtran(cTROCADO,"'","\'")
   cTROCADO := strtran(cTROCADO,"Ä","C")
   cTROCADO := strtran(cTROCADO,"á","C")
   cTROCADO := strtran(cTROCADO,"ß",".")
   cTROCADO := strtran(cTROCADO,"¶","A")
   cTROCADO := strtran(cTROCADO,"Ç","A")
   cTROCADO := strtran(cTROCADO,"É","A")
   cTROCADO := strtran(cTROCADO,"Ñ","A")
   cTROCADO := strtran(cTROCADO,"Ö","A")
   cTROCADO := strtran(cTROCADO,"Ü","A")
   cTROCADO := strtran(cTROCADO,"à","E")
   cTROCADO := strtran(cTROCADO,"â","E")
   cTROCADO := strtran(cTROCADO,"ä","E")
   cTROCADO := strtran(cTROCADO,"ã","I")
   cTROCADO := strtran(cTROCADO,"å","I")
   cTROCADO := strtran(cTROCADO,"ç","I")
   cTROCADO := strtran(cTROCADO,"ì","O")
   cTROCADO := strtran(cTROCADO,"é","A")
   cTROCADO := strtran(cTROCADO,"è","A")
   cTROCADO := strtran(cTROCADO,"ê","E")
   cTROCADO := strtran(cTROCADO,"ì","O")
   cTROCADO := strtran(cTROCADO,"î","O")
   cTROCADO := strtran(cTROCADO,"ï","O")
   cTROCADO := strtran(cTROCADO,"ñ","O")
   cTROCADO := strtran(cTROCADO,"ó","O")
   cTROCADO := strtran(cTROCADO,"ô","O")
   cTROCADO := strtran(cTROCADO,"ö","U")
   cTROCADO := strtran(cTROCADO,"†","A")
   cTROCADO := strtran(cTROCADO,"°","I")
   cTROCADO := strtran(cTROCADO,"¢","O")
   cTROCADO := strtran(cTROCADO,"£","U")
   cTROCADO := strtran(cTROCADO,"§","N")
   cTROCADO := strtran(cTROCADO,"&","E")
   cTROCADO := strtran(cTROCADO,"¯",".")

return(cTROCADO)
