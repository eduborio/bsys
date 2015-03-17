
/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE CONTABILIDADE
// OBJETIVO...: MANUTENCAO DE NATUREZA DE CONTAS
// ANALISTA...: EDUARDO
// PROGRAMADOR: O MESMO
// INICIO.....: MARCO 2015
// OBS........:
// ALTERACOES.:

function ct531

DFC->(qview({{"Codigo/C¢digo"             ,1},;
                  {"Descricao/Descricao"       ,2}},"P",;
                  {NIL,"c531a",NIL,NIL            },;
                   NIL,q_msg_acesso_usr() + " Im<P>rime"))

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function c531a

   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO $ XUSRA
      qlbloc(08,00,"B531A","QBLOC.GLO",1)
      qmensa(qabrev(cOPCAO,"IA",{"Inclus„o... <ESC - Cancela>","Altera‡„o... <ESC - Cancela>"}))
      i_edicao()
   endif
   
   if cOPCAO == "P"
	  qlbloc(09,20,"B530B","QBLOC.GLO",1)
	  i_pagina()
   endif	  

   setcursor(nCURSOR)

return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA ____________________________________

static function i_edicao

   local lCONF   := .F.
   local aEDICAO := {}
   local bESCAPE := {||empty(fTIPO).or.(XNIVEL==2.and.!XFLAG).or. (!empty(fTIPO) .and. XNIVEL==2 .and. !XFLAG .or. !empty(fTIPO) .and. XNIVEL==2 .and. Lastkey()==27) .or.;
                       (XNIVEL==2.and.cOPCAO=="A".and.!XFLAG)}
   local nREC

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"
      XNIVEL := 1
      qrsay ( XNIVEL++ , DFC->Codigo     )
      qrsay ( XNIVEL++ , DFC->Tipo      )
      qrsay ( XNIVEL++ , DFC->Descricao  )
      qrsay ( XNIVEL++ , transform(DFC->Ano_ant,"@E 999,999,999.99")  )
      qrsay ( XNIVEL++ , transform(DFC->Ano_Atual,"@E 999,999,999.99") )
   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || NIL                               },"CODIGO"    })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fTIPO,"@!")          },"TIPO"     })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDESCRICAO,"@!")      },"DESCRICAO" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fANO_ANT,"@E 999,999,999.99")      },"ANO_ANT" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fANO_ATUAL,"@E 999,999,999.99")      },"ANO_ATUAL" })

   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   DFC->(qpublicfields())
   iif(cOPCAO=="I",DFC->(qinitfields()),DFC->(qcopyfields()))

   XNIVEL := 2
   XFLAG  := .T.

   if cOPCAO == "I"
      fFATOR := 1
   endif

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; DFC->(qreleasefields()) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif

     // AGORA INCREMENTA CODIGO DO COMPRADOR ________________________________

   if CONFIG->(qrlock()) .and. DFC->(iif(cOPCAO=="I",qappend(),qrlock()))

      if cOPCAO == "I"
         replace CONFIG->Cod_DFC with CONFIG->Cod_DFC + 1
         qrsay ( 1 , fCODIGO := strzero(CONFIG->Cod_DFC,5) )
         qmensa("C¢digo Gerado: "+fCODIGO,"B")
      endif

      // AGORA GRAVA E DESTRAVA ARQUIVO _____________________________________

      DFC->(qreplacefields())
      DFC->(dbgotop())

   endif

   dbunlockall()

   if cOPCAO == "I" ; keyboard "I" ; endif

return

/////////////////////////////////////////////////////////////////////////////
// CRITICA DE EDICAO ________________________________________________________

static function i_critica ( cCAMPO )

   local nREC

   if ! XFLAG ; return .T. ; endif

   qmensa()

   do case

      case cCAMPO == "TIPO"
           if empty(fTIPO) ; return .F. ; endif

      case cCAMPO == "DESCRICAO"
           if empty(fDESCRICAO) ; return .F. ; endif

   endcase

return .T.

static function i_pagina

   local lCONF   := .F.
   local aEDICAO := {}
   local bESCAPE := {|| Lastkey()==27}
   local nREC
   local nPag := 0

   aadd(aEDICAO,{{ || qgetx(-1,0,@nPag,"9999")          },"PAG"     })
   aadd(aEDICAO,{{ || lCONF := qconf("Confirma Impressao ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   //DFC->(qpublicfields())
   //iif(cOPCAO=="I",DFC->(qinitfields()),DFC->(qcopyfields()))

   XNIVEL := 1
   XFLAG  := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; DFC->(qreleasefields()) ; return ; endif
      //if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif
   
   i_imprime(nPag)

   //if cOPCAO == "I" ; keyboard "I" ; endif

return



/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXCLUIR NATUREZA _____________________________________________

static function i_exclusao
   if qconf("Confirma exclus„o deste Natureza ?")
      if DFC->(qrlock())
         DFC->(dbdelete())
         DFC->(qunlock())
      else
         qm3()
      endif
   endif
return

static function i_imprime(nPag)
    local cTITULO1 := "DEMONSTRACAO DOS FLUXOS DE CAIXA DE 01/01/"+CONFIG->Exercicio + " A 31/12/"+CONFIG->Exercicio
	local cTITULO2 := "C.N.P.J. " + XCGCCPF
	
	if nPag == NIL
	   nPag := 0
	endif
	
	

	if ! qinitprn() ; return ; endif

    if XPAGINA == 0 .or. prow() > 56
	
		if XPAGINA == 0
			 if nPAG <= 0
				XPAGINA := 1
			 else
				XPAGINA := --nPAG
			 endif
		endif
		qpageprn()
		qcabecprn(cTITULO1,134,.F.,cTITULO2)
		@ prow()+1,003 say "DESCRICAO"
        @ prow()  ,094 say CONFIG->Exercicio
        @ prow()  ,128 say strzero(val(CONFIG->Exercicio)-1,4)
		@ prow()+1,0 say replicate("-",132)
	endif
	
	do while ! DFC->(eof())
		@ prow()+1,003 say DFC->Descricao
        @ prow()  ,084 say transform(DFC->ANO_ATUAL,"@E 999,999,999.99")
        @ prow()  ,118 say transform(DFC->ANO_ANT,"@E 999,999,999.99")
	
		DFC->(dbskip())
	enddo
	
	CGM->(dbseek(XCGM))

   @ prow()+2,011 say alltrim(CGM->Municipio) + ", 31 de Dezembro de "+CONFIG->Exercicio

   @ prow()+3,011 say "___________________________________                                     ____________________________________"
   @ prow()+1,015 say FILIAL->Contador
   @ prow()  ,090 say CONFIG->Diretor
   @ prow()+1,015 say FILIAL->Crc
   @ prow()  ,090 say CONFIG->Cpf_Direto
	
	qstopprn()

return
