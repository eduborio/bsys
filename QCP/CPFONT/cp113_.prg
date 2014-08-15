/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE COMPRAS
// OBJETIVO...: MANUTENCAO DE REPRESENTANTE COMERCIAL
// ANALISTA...:
// PROGRAMADOR:
// INICIO.....: NOVEMBRO DE 1996
// OBS........:
// ALTERACOES.:

function cp113

PAVILHAO->(qview({{"Codigo/C¢digo"              ,1},;
              {"left(Descricao,47)/Pavilhao"         ,2}},"P",;
              {NIL,"c113a",NIL,NIL},;
               NIL,q_msg_acesso_usr()))

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function c113a
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))
   if cOPCAO $ XUSRA
      qlbloc(5,0,"B113A","QBLOC.GLO",1)
      qmensa(qabrev(cOPCAO,"IA",{"Inclus„o... <ESC - Cancela>","Altera‡„o... <ESC - Cancela>"}))
      i_edicao()
   endif
   setcursor(nCURSOR)
return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA ____________________________________

static function i_edicao
   local lCONF   := .F.
   local aEDICAO := {}
   local bESCAPE := {||empty(fDESCRICAO).or.(XNIVEL==2.and.!XFLAG).or.!empty(fDESCRICAO).and.Lastkey()==27.or.;
                       (XNIVEL==2.and.cOPCAO=="A".and.!XFLAG)}

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"
      XNIVEL := 1
      qrsay ( XNIVEL++ , PAVILHAO->Codigo    )
      qrsay ( XNIVEL++ , PAVILHAO->Descricao )
      qrsay ( XNIVEL++ , PAVILHAO->Endereco )
      qrsay ( XNIVEL++ , PAVILHAO->Compl   )
      qrsay ( XNIVEL++ , PAVILHAO->Cgm ) ; CGM->(dbseek(PAVILHAO->Cgm))
      qrsay ( XNIVEL++ , CGM->Municipio )
      qrsay ( XNIVEL++ , CGM->Estado    )
      qrsay ( XNIVEL++ , PAVILHAO->Bairro   )
      qrsay ( XNIVEL++ , PAVILHAO->Cep , "@R 99.999-999" )
   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || NIL                                                 },"CODIGO"    })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDESCRICAO    ,"@!"   ,"!empty(@)",.T.)  },"NOME"      })

   aadd(aEDICAO,{{ || qgetx(-1,0,@fENDERECO     ,"@!")                    },"ENDERECO"   })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fCOMPL        ,"@!")                    },"COMPL"      })
   aadd(aEDICAO,{{ || view_cgm(-1,0,@fCGM)                            },"CGM"    })
   aadd(aEDICAO,{{ || NIL                                                 },NIL         })
   aadd(aEDICAO,{{ || NIL                                                 },NIL         })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fBAIRRO       ,"@!")                    },"BAIRRO"   })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fCEP          ,"@R 99.999-999")         },"CEP"   })

   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   PAVILHAO->(qpublicfields())
   iif(cOPCAO=="I",PAVILHAO->(qinitfields()),PAVILHAO->(qcopyfields()))

   XNIVEL  := 2
   XFLAG   := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; PAVILHAO->(qreleasefields()) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif

   if CONFIG->(qrlock()) .and. PAVILHAO->(iif(cOPCAO=="I",qappend(),qrlock()))

      // AQUI INCREMENTA CODIGO DO REPRESENTANTE _____________________________

      if cOPCAO == "I"
         replace CONFIG->Cod_pav with CONFIG->Cod_pav + 1
         qrsay ( 1 , fCODIGO := strzero(CONFIG->Cod_pav,5) )
         qmensa("C¢digo Gerado: "+fCODIGO,"B")
      endif

      // AGORA GRAVA E DESTRAVA ARQUIVO _____________________________________

      PAVILHAO->(qreplacefields())

   endif

   dbunlockall()

   if cOPCAO == "I" ; keyboard "I" ; endif

return


// CRITICA DE EDICAO ________________________________________________________

static function i_critica ( cCAMPO )

   local zTMP

   if ! XFLAG ; return .T. ; endif

   do case

      case cCAMPO == "CODIGO" .and. cOPCAO == "I"

           if PAVILHAO->(dbseek(fCODIGO))
              qmensa("Pavilhao j  cadastrado !","B")
              return .F.
           endif

      case cCAMPO == "CGM"

           if ! CGM->(dbseek(fCGM))
              qmensa("Cgm n„o encontrado !","B")
              return .F.
           endif

           qrsay(XNIVEL+1,CGM->Municipio)
           qrsay(XNIVEL+2,CGM->Estado)


   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXCLUIR PAVILHAO_ _ _______________________________________

static function i_exclusao
   if qconf("Confirma exclus„o deste Pavilhao ?")
      if PAVILHAO->(qrlock())
         PAVILHAO->(dbdelete())
         PAVILHAO->(qunlock())
      else
         qm3()
      endif
   endif
return

