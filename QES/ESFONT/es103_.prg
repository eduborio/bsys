/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE ESTOQUE
// OBJETIVO...: MANUTENCAO DE ORDEM DE SERVICO
// ANALISTA...: LUCIANO DA SILVA GORSKI
// PROGRAMADOR: LUCIANO DA SILVA GORSKI
// INICIO.....: MARCO DE 1999
// OBS........:
// ALTERACOES.:
function es103

private cMES    := right(CONFIG->Anomes,2)
private cANO    := left(CONFIG->Anomes,4)

OS->(dbSetFilter({|| Dat_entra >= ctod('01/'+cMES+'/'+cANO) },"Dat_entra >= ctod('01/'+cMES+'/'+cANO)"))


OS->(qview({{"Codigo/C¢digo"               ,1},;
           {"left(Descricao,16)/Descri‡„o" ,2},;
           {"Placa/Placa"                  ,0},;
           {"left(Modelo,16)/Modelo"       ,0},;
           {"Ano/Ano"                      ,0},;
           {"Dat_entra/Entrada"            ,0},;
           {"Dat_saida/Saida"              ,0}},"P",;
           {NIL,"c103a",NIL,NIL},;
            NIL,q_msg_acesso_usr()))

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function c103a
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))
   if cOPCAO $ XUSRA
      qlbloc(10,1,"B103A","QBLOC.GLO",1)
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
   local bESCAPE := {||empty(fCODIGO).or.(XNIVEL==1.and.!XFLAG).or.!empty(fCODIGO).and.Lastkey()==27.or.;
                       (XNIVEL==2.and.cOPCAO=="A".and.!XFLAG)}

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"
      XNIVEL := 1
      qrsay ( XNIVEL++ , OS->Codigo , "@R 99999"           )
      qrsay ( XNIVEL++ , OS->Descricao, "@X!"              )
      qrsay ( XNIVEL++ , OS->Placa                         )
      qrsay ( XNIVEL++ , OS->Cores , "@X!"                 )
      qrsay ( XNIVEL++ , OS->Modelo , "@X!"                )
      qrsay ( XNIVEL++ , OS->Ano , "@R 9999"               )
      qrsay ( XNIVEL++ , OS->Chassis, "@X!"                )
//    qrsay ( XNIVEL++ , OS->Segurado, "@X!"               )
      qrsay ( XNIVEL++ , OS->Dat_entra, "@D"               )
      qrsay ( XNIVEL++ , OS->Dat_Saida, "@D"               )
//    qrsay ( XNIVEL++ , OS->Franquia , "@R 999,999,999.99")
   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   if cOPCAO == "I"
      aadd(aEDICAO,{{ || qgetx(-1,0,@fCODIGO         ,"@r 99999")      },"CODIGO"     })
   else
      aadd(aEDICAO,{{ || NIL                                           },"CODIGO"     })
   Endif
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDESCRICAO            ,"@!")      },"DESCRICAO"  })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fPLACA          ,"!!!-9999")      },"PLACA"      })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fCORES                ,"@!")      },"CORES"      })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fMODELO               ,"@!")      },"MODELO"     })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fANO                ,"9999")      },"ANO"        })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fCHASSIS              ,"@!")      },"CHASSIS"    })
// aadd(aEDICAO,{{ || qgetx(-1,0,@fSEGURADO             ,"@!")      },"SEGURADO"   })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDAT_ENTRA            ,"@D")      },"DAT_ENTRA"  })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDAT_SAIDA            ,"@D")      },"DAT_SAIDA"  })
// aadd(aEDICAO,{{ || qgetx(-1,0,@fFRANQUIA ,"999,999,999.99")      },"FRANQUIA"   })

   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   OS->(qpublicfields())
   iif(cOPCAO=="I",OS->(qinitfields()),OS->(qcopyfields()))

   if cOPCAO == "I"
      XNIVEL  := 1
   else
      XNIVEL  := 2
   endif
   XFLAG   := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; OS->(qreleasefields()) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif

// if CONFIG->(qrlock()) .and. OS->(iif(cOPCAO=="I",qappend(),qrlock()))
   if OS->(iif(cOPCAO=="I",qappend(),qrlock()))

      // AQUI INCREMENTA CODIGO DO VEICULO __________________________________

//      if cOPCAO == "I"
//         replace CONFIG->Cod_os with CONFIG->Cod_os + 1
//         qrsay ( 1 , fCODIGO := strzero(CONFIG->Cod_os,5) )
//         qmensa("C¢digo Gerado: "+fCODIGO,"B")
//      endif

      // AGORA GRAVA E DESTRAVA ARQUIVO _____________________________________

      OS->(qreplacefields())

   else

      if empty(OS->Codigo) .and. empty(OS->Descricao)
         OS->(dbdelete())
      endif

      iif(cOPCAO=="I",qm1(),qm2())

   endif

   dbunlockall()

   if cOPCAO == "I" ; keyboard "I" ; endif

return

/////////////////////////////////////////////////////////////////////////////
// CRITICA DE EDICAO ________________________________________________________

static function i_critica ( cCAMPO )

   local zTMP

   if ! XFLAG ; return .T. ; endif

   do case
      case cCAMPO == "CODIGO"
          if empty(fCODIGO) ; return .F. ; endif
             fCODIGO := StrZero(val(fCODIGO),5)
          if OS->(dbseek(fCODIGO))
             qmensa("Codigo da OS j  cadastrado, Verifique...","B")
             fCODIGO:="     "
             qrsay(XNIVEL,fCODIGO)
             Return .F.
          Else
             qrsay(XNIVEL,fCODIGO)
          Endif

      case cCAMPO == "DESCRICAO"
          if empty(fDESCRICAO) ; return .F. ; endif

      case cCAMPO == "PLACA"
          if empty(fPLACA) ; return .F. ; endif

      case cCAMPO == "CORES"
          if empty(fCORES) ; return .F. ; endif

      case cCAMPO == "MODELO"
          if empty(fMODELO) ; return .F. ; endif

      case cCAMPO == "ANO"
          if empty(fANO) ; return .F. ; endif

      case cCAMPO == "DAT_ENTRA"
          if empty(fDAT_ENTRA) ; return .F. ; endif

//      case cCAMPO == "DAT_SAIDA"
//          if empty(fDAT_SAIDA) ; return .F. ; endif
//          if fDAT_SAIDA < fDAT_ENTRA
//             qmensa("Data de Saida do Veiculo deve ser maior que Data de Entrada!","B")
//             Return .F.
//          Endif
   endcase

return .T.


/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXCLUIR VEICULO ______________________________________________

static function i_exclusao
   if qconf("Confirma exclus„o deste Ve¡culo ?")
      if OS->(qrlock())
         OS->(dbdelete())
         OS->(qunlock())
      else
         qm3()
      endif
   endif
return

