/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: FOLHA DE PAGAMENTO
// OBJETIVO...: MANUTENCAO DE DEPENDENTES
// ANALISTA...: CARLOS EDUARDO RABELLO NUNES
// PROGRAMADOR: O MESMO
// INICIO.....: SETEMBRO DE 1996
// OBS........:
// ALTERACOES.:

// CARREGA BLOCO PARA VIEW DE FUNCIONARIOS

SITUA->(dbSetFilter({|| Anomes == XANOMES},"Anomes == XANOMES"))

FUN->(dbsetrelation("SITUA",{||FUN->Matricula},"FUN->Matricula"))

qlbloc(5,0,"B131C","QBLOC.GLO")

FUN->(qview({{"Matricula"             ,1},;
             {"left(Nome,30)/Nome"    ,2},;
             {"Mat_Ass/Mat.Assoc."    ,3},;
             {"SITUA->Dep_ir/Dep.Ir." ,0},;
             {"SITUA->Dep_fam/Dep.Sf.",0}},"05001579",;
             {"f131a",NIL,NIL,NIL},;
             NIL,"<ESC> / ALT-P / ALT-O / <ENTER> PARA DEPENDENTES"))

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO DEPENTENTE ________________________________________

function f131a
   DEPE->(qview({{"Nome/Nome do Dependente",1},;
                 {"Data_nasc/Data Nasc.",0}},"15002379",;
                 {NIL,"f131b",NIL,NIL},;
                 {"DEPE->Matricula==FUN->Matricula",{||top131()},{||bot131()}},;
                 q_msg_acesso_usr()+"/<R>eajusta"))
return

function top131
   DEPE->(dbseek(FUN->Matricula))
return

function bot131
   DEPE->(qseekn(FUN->Matricula))
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function f131b
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))
   if cOPCAO == "R"
      i_atua_situa()
   endif
   if cOPCAO == "I" .or. (cOPCAO $ "ACE" .and. DEPE->Matricula == FUN->Matricula)
      if cOPCAO $ XUSRA
         qlbloc(5,0,"B131A","QBLOC.GLO")
         qmensa(qabrev(cOPCAO,"IA",{"Inclus„o...","Altera‡„o..."}))
         i_edicao()
      endif
      if DEPE->Matricula <> FUN->Matricula
         DEPE->(dbseek(FUN->Matricula))
      endif
   endif
   setcursor(nCURSOR)
return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA ____________________________________

static function i_edicao
   local lCONF
   local aEDICAO := {}
   local bESCAPE := {||XNIVEL==3.and.(empty(fNOME).or.!XFLAG)}
   local sBLOCO1 := qlbloc("B101Q","QBLOC.GLO") // sexo
   local sBLOCO2 := qlbloc("B131B","QBLOC.GLO") // parentesco
   local sBLOCO3 := qlbloc("B101J","QBLOC.GLO") // grau de instrucao

   // MONTA DADOS NA TELA ___________________________________________________

   XNIVEL := 1
   qrsay ( XNIVEL++ , FUN->Matricula  )
   qrsay ( XNIVEL++ , left(FUN->Nome,30))
   if cOPCAO <> "I"
      qrsay ( XNIVEL++ , DEPE->Nome      )
      qrsay ( XNIVEL++ , DEPE->Data_Nasc  )
      qrsay ( XNIVEL++ , qabrev(DEPE->Sexo,"MF",{"Masculino","Feminino "}) )
      qrsay ( XNIVEL++ , f131c(DEPE->Parentesco) )
      qrsay ( XNIVEL++ , qabrev(DEPE->Instrucao,"123456789",{"Analfabeto    ","Pri.Incompleto","Primario      ","Gin.Incompleto","Ginasio       ","2§G.Incompleto","2§ Grau       ","Sup.Incompleto","Superior      "}) )
      qrsay ( XNIVEL++ , DEPE->Nasc_Cgm   ) ; CGM->(dbseek(DEPE->Nasc_Cgm))
      qrsay ( XNIVEL++ , CGM->Municipio+"/"+CGM->Estado )
      qrsay ( XNIVEL++ , DEPE->Cpf        )
      qrsay ( XNIVEL++ , DEPE->Rn_Num     )
      qrsay ( XNIVEL++ , DEPE->Rn_Liv     )
      qrsay ( XNIVEL++ , DEPE->Rn_Fol     )
      qrsay ( XNIVEL++ , DEPE->Rn_Dat     )
      qrsay ( XNIVEL++ , DEPE->Rn_Cgm     ) ; CGM->(dbseek(DEPE->Rn_Cgm))
      qrsay ( XNIVEL++ , CGM->Municipio+"/"+CGM->Estado )
      qrsay ( XNIVEL++ , DEPE->Rn_Ent     )
      qrsay ( XNIVEL++ , DEPE->Inicio_Dep )
      qrsay ( XNIVEL++ , DEPE->Sf_datsusp )
      qrsay ( XNIVEL++ , DEPE->Sf_datrest )
      qrsay ( XNIVEL++ , qabrev(DEPE->Bolsa    ,"SN",{"Sim","N„o"}) )
      qrsay ( XNIVEL++ , qabrev(DEPE->Irrf     ,"SN",{"Sim","N„o"}) )
      qrsay ( XNIVEL++ , qabrev(DEPE->Sal_Fam  ,"SN",{"Sim","N„o"}) )
      qrsay ( XNIVEL++ , qabrev(DEPE->Seg_Saude,"SN",{"Sim","N„o"}) )
      qrsay ( XNIVEL++ , qabrev(DEPE->Seg_Vida ,"SN",{"Sim","N„o"}) )
   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || NIL },NIL}) // matricula do funcionario
   aadd(aEDICAO,{{ || NIL },NIL}) // nome      do funcionario
   aadd(aEDICAO,{{ || qgetx(-1,0,@fNOME     ,"@!",NIL,.T.)  }                ,"NOME"      })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDATA_NASC ,NIL,NIL,.T.)  }                ,"DATA_NASC" })
   aadd(aEDICAO,{{ || qesco(-1,0,@fSEXO      ,sBLOCO1)      }                ,"SEXO"      })
   aadd(aEDICAO,{{ || qesco(0,55,@fPARENTESCO,sBLOCO2)      }                ,"PARENTESCO"})
   aadd(aEDICAO,{{ || qesco(10,59,@fINSTRUCAO,sBLOCO3)      }                ,"INSTRUCAO" })
   aadd(aEDICAO,{{ || view_cgm(-1,0,@fNASC_CGM) }                            ,"NASC_CGM"  })
   aadd(aEDICAO,{{ || NIL },NIL}) // descricao da municipio do nascimento
   aadd(aEDICAO,{{ || qgetx(-1,0,@fCPF       ,NIL ,NIL,.T.) }                ,"CPF"       })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fRN_NUM    ,NIL ,NIL,.T.) }                ,"RN_NUM"    })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fRN_LIV    ,NIL ,NIL,.T.) }                ,"RN_LIV"    })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fRN_FOL    ,NIL ,NIL,.T.) }                ,"RN_FOL"    })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fRN_DAT    ,NIL ,NIL,.T.) }                ,"RN_DAT"    })
   aadd(aEDICAO,{{ || view_cgm(-1,0,@fRN_CGM) }                              ,"RN_CGM"    })
   aadd(aEDICAO,{{ || NIL },NIL}) // descricao da municipio do registro de nascimento
   aadd(aEDICAO,{{ || qgetx(-1,0,@fRN_ENT    ,NIL ,NIL,.T.) }                ,"RN_ENT"    })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fINICIO_DEP,NIL ,NIL,.T.) }                ,"INICIO_DEP"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@fSF_DATSUSP,NIL ,NIL,.T.) }                ,"SF_DATSUSP"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@fSF_DATREST,NIL ,NIL,.T.) }                ,"SF_DATREST"})
   aadd(aEDICAO,{{ || qesco(-1,0,@fBOLSA          ,XSN) }                    ,"BOLSA"     })
   aadd(aEDICAO,{{ || qesco(-1,0,@fIRRF           ,XSN) }                    ,"IRRF"      })
   aadd(aEDICAO,{{ || qesco(-1,0,@fSAL_FAM        ,XSN) }                    ,"SAL_FAM"   })
   aadd(aEDICAO,{{ || qesco(-1,0,@fSEG_SAUDE      ,XSN) }                    ,"SEG_SAUDE" })
   aadd(aEDICAO,{{ || qesco(-1,0,@fSEG_VIDA       ,XSN) }                    ,"SEG_VIDA"  })
   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   DEPE->(qpublicfields())
   iif(cOPCAO=="I",DEPE->(qinitfields()),DEPE->(qcopyfields()))
   XNIVEL := 1
   XFLAG := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; DEPE->(qreleasefields()) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif

   if DEPE->(iif(cOPCAO=="I",qappend(),qrlock()))
      fMATRICULA := FUN->Matricula
      DEPE->(qreplacefields())
      DEPE->(qunlock())
   else
      iif(cOPCAO=="I",qm1(),qm2())
   endif

// SITUA->(qseekn(FUN->Matricula))

   i_atua_situa()

return

/////////////////////////////////////////////////////////////////////////////
// CRITICAS NA DESCIDA ______________________________________________________

static function i_critica ( cCAMPO )
   iif ( cCAMPO == NIL , cCAMPO := "" , NIL )
   do case
      case cCAMPO == "NOME" .and. cOPCAO == "I"
           if DEPE->(dbseek(fNOME))
              qmensa("Cargo j  cadastrado !","B")
              return .F.
           endif
      case cCAMPO == "SEXO"
           if empty(fSEXO) ; return .F. ; endif
           qrsay ( XNIVEL , qabrev(fSEXO,"MF",{"Masculino","Feminino "}) )
      case cCAMPO == "PARENTESCO"
           if empty(fPARENTESCO) ; return .F. ; endif
           qrsay ( XNIVEL , f131c(fPARENTESCO) )
      case cCAMPO == "INSTRUCAO"
           if empty(fINSTRUCAO) ; return .F. ; endif
           qrsay ( XNIVEL , qabrev(fINSTRUCAO,"123456789",{"Analfabeto    ","Pri.Incompleto","Primario      ","Gin.Incompleto","Ginasio       ","2§G.Incompleto","2§ Grau       ","Sup.Incompleto","Superior      "}) )
      case cCAMPO == "NASC_CGM"
           if CGM->(dbseek(fNASC_CGM))
              qrsay ( XNIVEL+1 , CGM->Municipio+"/"+CGM->Estado )
           endif
      case cCAMPO == "RN_CGM"
           if CGM->(dbseek(fRN_CGM))
              qrsay ( XNIVEL+1 , CGM->Municipio+"/"+CGM->Estado )
           endif
      case cCAMPO == "BOLSA"
           if empty(fBOLSA) ; return .F. ; endif
           qrsay ( XNIVEL , qabrev(fBOLSA,"SN",{"Sim","N„o"}) )
      case cCAMPO == "IRRF"
           if empty(fIRRF) ; return .F. ; endif
           qrsay ( XNIVEL , qabrev(fIRRF,"SN",{"Sim","N„o"}) )
      case cCAMPO == "SAL_FAM"
           if empty(fSAL_FAM) ; return .F. ; endif
           qrsay ( XNIVEL , qabrev(fSAL_FAM,"SN",{"Sim","N„o"}) )
      case cCAMPO == "SEG_SAUDE"
           if empty(fSEG_SAUDE) ; return .F. ; endif
           qrsay ( XNIVEL , qabrev(fSEG_SAUDE,"SN",{"Sim","N„o"}) )
      case cCAMPO == "SEG_VIDA"
           if empty(fSEG_VIDA) ; return .F. ; endif
           qrsay ( XNIVEL , qabrev(fSEG_VIDA,"SN",{"Sim","N„o"}) )
   endcase
return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXCLUIR DEPENDENTE ___________________________________________

static function i_exclusao
   if qconf("Confirma exclus„o deste Dependente ?")
      if DEPE->(qrlock())
         DEPE->(dbdelete())
         DEPE->(qunlock())
      else
         qm3()
      endif
   endif
// SITUA->(qseekn(FUN->Matricula))
   i_atua_situa()
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A ATUALIZACAO DO CADASTRO DE SITUACAO __________________

static function i_atua_situa
   local nQUANT_BO, nQUANT_IR, nQUANT_SF, nQUANT_SS, nQUANT_SV
   local nRECNO := DEPE->(recno())
   local nREGS := SITUA->(recno())
   if SITUA->(qrlock())
      DEPE->(dbseek(FUN->Matricula))
      nQUANT_BO := nQUANT_IR := nQUANT_SF := nQUANT_SS := nQUANT_SV := 0
      do while DEPE->Matricula==FUN->Matricula
         iif(DEPE->Bolsa=="S"    ,nQUANT_BO++,NIL)
         iif(DEPE->Irrf=="S"     ,nQUANT_IR++,NIL)
         iif(DEPE->Sal_fam=="S"  ,nQUANT_SF++,NIL)
         iif(DEPE->Seg_saude=="S",nQUANT_SS++,NIL)
         iif(DEPE->Seg_vida=="S" ,nQUANT_SV++,NIL)
         DEPE->(dbskip())
      enddo
      SITUA->Dep_bolsa := nQUANT_BO
      SITUA->Dep_ir    := nQUANT_IR
      SITUA->Dep_fam   := nQUANT_SF
      SITUA->Dep_saude := nQUANT_SS
      SITUA->Dep_vida  := nQUANT_SV

      if CONFIG->Datasys < CONFIG->Data_atual

         SITUA->(Dbclearfil())
         SITUA->(dbsetorder(4))
         SITUA->(dbseek(FUN->Matricula+qanomes(CONFIG->Data_atual)))
         if SITUA->(qrlock())
            SITUA->Dep_bolsa := nQUANT_BO
            SITUA->Dep_ir    := nQUANT_IR
            SITUA->Dep_fam   := nQUANT_SF
            SITUA->Dep_saude := nQUANT_SS
            SITUA->Dep_vida  := nQUANT_SV
            SITUA->(dbsetorder(1))
            SITUA->(dbSetFilter({|| Anomes == XANOMES},"Anomes == XANOMES"))
            SITUA->(dbgoto(nREGS))
         endif
         SITUA->(qunlock())
      endif
      SITUA->(dbunlock())
      SITUA->(qunlock())
   else
      qmensa("N„o foi possivel atualizar Cadastro de Funcion rios !","B")
   endif

   DEPE->(dbgoto(nRECNO))
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA TRADUZIR O TIPO DE PARENTESCO ________________________________

function f131c ( cCOD )
   do case
      case cCOD == "A" ; return "Filho(a)         "
      case cCOD == "B" ; return "Conjuge          "
      case cCOD == "C" ; return "Pai/M„e          "
      case cCOD == "D" ; return "Companheiro(a)   "
      case cCOD == "E" ; return "Filho(a) Adotivo "
      case cCOD == "F" ; return "Padrasto/Madrasta"
      case cCOD == "G" ; return "Irmao(a)         "
      case cCOD == "H" ; return "Avo(a)           "
      case cCOD == "I" ; return "Neto(a)          "
      case cCOD == "J" ; return "Bisavo(a)        "
      case cCOD == "K" ; return "Bisneto(a)       "
      case cCOD == "L" ; return "Sobrinho(a)      "
      case cCOD == "M" ; return "Primo(a)         "
      case cCOD == "N" ; return "Tio(a)           "
      case cCOD == "O" ; return "Cunhado(a)       "
      case cCOD == "P" ; return "Genro/Nora       "
      case cCOD == "Q" ; return "Enteado(a)       "
      case cCOD == "R" ; return "Sogro(a)         "
      case cCOD == "S" ; return "Menor s/ Guarda  "
      case cCOD == "T" ; return "Menor s/ Tutela  "
      case cCOD == "U" ; return "Pessoa Designada "
      case cCOD == "V" ; return "Outro(a)         "
   endcase
return "                 "

