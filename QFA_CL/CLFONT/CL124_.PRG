/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO COMERCIAL
// OBJETIVO...: MANUTENCAO DE SITUACAO TRIBUTARIA
// ANALISTA...: EDUARDO AUGUSTO BORIO
// PROGRAMADOR: EDUARDO AUGUSTO BORIO
// INICIO.....: OUTUBRO DE 2002
// OBS........:
// ALTERACOES.:

function cl124
RESTRI->(qview({{"Cod_cli/Cod. "           ,1},;
              {"left(Cliente,45)/Razao"  ,2}},"P",;
              {NIL,"c124a",NIL,NIL},;
              NIL,q_msg_acesso_usr()+" Im<P>rimir"))

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function c124a

   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO $ XUSRA
      qlbloc(7,0,"B124A","QBLOC.GLO",1)
      qmensa(qabrev(cOPCAO,"IA",{"Inclus„o... <ESC - Cancela>","Altera‡„o... <ESC - Cancela>"}))
      i_edicao()
   endif

   if cOPCAO == "P"
      i_imprime()
   endif

   setcursor(nCURSOR)

return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA ____________________________________

static function i_edicao
   local lCONF   := .F.
   local aEDICAO := {}
   local bESCAPE := {||(XNIVEL==1.and.!XFLAG).or. Lastkey()==27}

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"

      XNIVEL := 1

      qrsay ( XNIVEL++ , RESTRI->Cod_cli                  )
      qrsay ( XNIVEL++ , left(RESTRI->Cliente,35)         )
      qrsay ( XNIVEL++ , RESTRI->Obs                      )
      qrsay ( XNIVEL++ , RESTRI->Obs2                      )
      qrsay ( XNIVEL++ , RESTRI->Obs3                      )
      qrsay ( XNIVEL++ , RESTRI->Obs4                      )
      qrsay ( XNIVEL++ , RESTRI->Obs5                      )

   endif
   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || view_cli(-1,0,@fCOD_CLI,"99999")        },"COD_CLI"  })
   aadd(aEDICAO,{{ || NIL                                     }, NIL       })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fOBS,"@!")                  },"OBS"      })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fOBS2,"@!")                  },"OBS"      })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fOBS3,"@!")                  },"OBS"      })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fOBS4,"@!")                  },"OBS"      })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fOBS5,"@!")                  },"OBS"      })


   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   RESTRI->(qpublicfields())
   iif(cOPCAO=="I",RESTRI->(qinitfields()),RESTRI->(qcopyfields()))

   XNIVEL := 1
   XFLAG  := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; RESTRI->(qreleasefields()) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif

   if RESTRI->(iif(cOPCAO=="I",qappend(),qrlock()))

      RESTRI->(qreplacefields())
      RESTRI->(dbgotop())

   else
      iif(cOPCAO=="I",qm1(),qm2())
   endif

   dbunlockall()

   if cOPCAO == "I" ; keyboard "I" ; endif

return

/////////////////////////////////////////////////////////////////////////////
// CRITICA DE EDICAO ________________________________________________________

static function i_critica ( cCAMPO )

   if ! XFLAG ; return .T. ; endif

   do case
      case cCAMPO == "COD_CLI"

           if empty(fCOD_CLI) ; return .F. ; endif

           qrsay(XNIVEL,fCOD_CLI:=strzero(val(fCOD_CLI),5))
           if ! CLI1->(dbseek(fCOD_CLI))
              qmensa("Cliente n„o encontrado !","B")
              return .F.
           endif

           if cOPCAO == "I"
              if RESTRI->(dbseek(fCOD_CLI))
                 qmensa("Ja foram registradas Restricoes para este Cliente!","B")
                 return .F.
              endif
           endif

           qrsay(XNIVEL+1,left(CLI1->Razao,35))
           fCLIENTE := CLI1->Razao


   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXCLUIR TRANSPORTADORA _______________________________________

static function i_exclusao
   if qconf("Confirma exclus„o desta Restricao ?")
      if RESTRI->(qrlock())
         RESTRI->(dbdelete())
         RESTRI->(qunlock())
      else
         qm3()
      endif
   endif
return

static function i_imprime
local nFile := 0
local cFilename := ""
local cBuffer := ""

   cFileName := "Rel 124 - "+strzero(year(date()),4)+ " "+strzero(month(date()),2)+" "+strzero(day(date()),2)+ " - " + left(time(),2)+" "+substr(time(),4,2)+".xls"


   nfile := fcreate("c:\Qsystxt\"+cFilename,0)
   cBuffer := chr(9)+"Listagem de Clientes com Restricao - 124"+chr(13)+chr(10)
   cBuffer += "Codigo"+chr(9)+"Razao"+chr(9)+"Observacao"+chr(13)+chr(10)

   RESTRI->(dbgotop())

   do while ! RESTRI->(eof())
      CLI1->(dbseek(RESTRI->Cod_cli))
      cBuffer += RESTRI->Cod_cli +chr(9)+CLI1->Razao+chr(9)+RESTRI->Obs+chr(13)+chr(10)

      RESTRI->(dbskip())

   enddo

   fWrite(nFile,cBuffer,len(cBuffer))
   fclose(nFile)
   RESTRI->(dbgotop())

   alert("Arquivo gerado na pasta C:\Qsystxt !")





return
