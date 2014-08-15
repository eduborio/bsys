
#include "inkey.ch"

/////////////////////////////////////////////////////////////////////////////
// SELECIONA EMPRESA CADASTRADA _____________________________________________

function qmanutemp

   local nCONT, cMACRO, nSKIP := 0

   qkeyoff()

   // INICIALIZACAO SOMENTE EM WAIT, ABRE ARQUIVO DE INSTALACAO _____________

   if ! XWAIT ; return .F. ; endif

   quse(XDRV_SH,"QINST",{"QINST1","QINST2"})

   if ! QINST->(dbseek("000"))
      alert("FAVOR COMUNICAR A Q-SYS A OCORRENCIA;DE IRREGULARIDADES NA BASE DE;DADOS PARA INSTALA€ŽO DE NOVAS EMPRESAS !",{"OK"})
   endif

   set filter to Empresa <> "000"

   // VIEW DE ESCOLHA _________________________________________________

   QINST->(dbsetorder(2))

   QINST->(dbseek(XRAZAO))

   QINST->(qview({{"Razao/Raz„o Social",2},;
                  {"Empresa/Cod."      ,1},;
                  {"Seq/Seq."          ,0},;
                  {"i_ativa()/Ativa?"  ,0}},"PF",;
                  {"EXIT","i_tec_emp",NIL,NIL},;
                  {"!deleted()",{||dbgotop()},{||dbgobottom()}},;
                  "<ESC>, ALT-O, ALT-P, <I>nc, <A>lt, <C>on, <L>ist, <X>-Ativa"))

   // FINALIZA, FECHA ARQUIVO, E RETORNA ____________________________________

   qkeyon()

   QINST->(dbclosearea())

return

function i_ativa
   if left(XSIGLA,2)+"." $ QINST->Sistemas
      return "SIM"
   endif
return "   "

/////////////////////////////////////////////////////////////////////////////
// MANUTENCAO DE EMPRESAS ___________________________________________________

function i_tec_emp
   local nCURSOR := setcursor(1)
   local nORDER  := QINST->(indexord())
   parameters cOPCAO

   cOPCAO := upper(chr(cOPCAO))

   iif(cOPCAO=="X",i_marca(),)

   if cOPCAO=="L"
      if ! quse(XDRV_SH,"CGM",{"CGM_COD","CGM_MUN"}) ; return "" ; endif
      i_lista()
      CGM->(dbclosearea())
      select QINST
   endif

   if cOPCAO $ "IAC"
      qlbloc(5,0,"BLOCEMP1",XDRV_SH+"QSBLOC.GLO")
      qmensa(qabrev(cOPCAO,"IA",{"Inclus„o de Empresa Nova !","Altera‡„o de dados da Empresa !"}))
      if ! quse(XDRV_SH,"CGM",{"CGM_COD","CGM_MUN"}) ; return "" ; endif
      i_edicao()
      CGM->(dbclosearea())
      select QINST
   endif

   QINST->(dbsetorder(nORDER))
   setcursor(nCURSOR)

return ""

////////////////////////////////////////////////////////////////////////////
// MARCA/DESMARCA ATIVACAO DO SISTEMA NA EMPRESA SELECIONADA _______________

static function i_marca
   local cSIGLA := left(XSIGLA,2) + "."

   if QINST->(qrlock())
      if cSIGLA $ QINST->Sistemas
         replace QINST->Sistemas with strtran(QINST->Sistemas,cSIGLA,"")
      else
         replace QINST->Sistemas with alltrim(QINST->Sistemas)+cSIGLA
      endif
      QINST->(qunlock())
   endif

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA ____________________________________

static function i_edicao
   local lCONF
   local aEDICAO := {}
   local bESCAPE := {||val(fEMPRESA)==0.or.(XNIVEL==1.and.!XFLAG).or.;
                       (XNIVEL==2.and.cOPCAO=="A".and.!XFLAG)}

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"
      XNIVEL := 1
      qrsay(XNIVEL++,QINST->Empresa)
      qrsay(XNIVEL++,QINST->Razao)
      qrsay(XNIVEL++,QINST->Seq)
      qrsay(XNIVEL++,QINST->Contato)
      qrsay(XNIVEL++,QINST->Telefone)
      qrsay(XNIVEL++,QINST->CGCCPF)
      qrsay(XNIVEL++,QINST->Inscr_est)
      qrsay(XNIVEL++,QINST->Inscr_mun)
      qrsay(XNIVEL++,QINST->Endereco)
      qrsay(XNIVEL++,QINST->Numero)
      qrsay(XNIVEL++,QINST->Compl)
      qrsay(XNIVEL++,QINST->Bairro)
      qrsay(XNIVEL++,QINST->Cep)
      qrsay(XNIVEL++,QINST->Cgm) ; CGM->(dbseek(QINST->Cgm))
      qrsay(XNIVEL++,CGM->Municipio)
      qrsay(XNIVEL++,CGM->Estado)
      qrsay(XNIVEL++,QINST->Tipo_ativ)
      qrsay(XNIVEL++,QINST->Obs)
   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{||qgetx(-1,0,@fEMPRESA      ,"@!",NIL,cOPCAO=="I") },"EMPRESA"   })
   aadd(aEDICAO,{{||qgetx(-1,0,@fRAZAO        ,"@!")                 },"RAZAO"     })
   aadd(aEDICAO,{{||qgetx(-1,0,@fSEQ          ,"@!")                 },"SEQ"       })
   aadd(aEDICAO,{{||qgetx(-1,0,@fCONTATO      ,"@!")                 },"CONTATO"   })
   aadd(aEDICAO,{{||qgetx(-1,0,@fTELEFONE     ,"@!")                 },"TELEFONE"  })
   aadd(aEDICAO,{{||qgetx(-1,0,@fCGCCPF       ,"@!")                 },"CGCCPF"    })
   aadd(aEDICAO,{{||qgetx(-1,0,@fINSCR_EST    ,"@!")                 },"INSCR_EST" })
   aadd(aEDICAO,{{||qgetx(-1,0,@fINSCR_MUN    ,"@!")                 },"INSCR_MUN" })
   aadd(aEDICAO,{{||qgetx(-1,0,@fENDERECO     ,"@!")                 },"ENDERECO"  })
   aadd(aEDICAO,{{||qgetx(-1,0,@fNUMERO       ,"99999")              },"NUMERO"    })
   aadd(aEDICAO,{{||qgetx(-1,0,@fCOMPL        ,"@!")                 },"COMPL"     })
   aadd(aEDICAO,{{||qgetx(-1,0,@fBAIRRO       ,"@!")                 },"BAIRRO"    })
   aadd(aEDICAO,{{||qgetx(-1,0,@fCEP          ,"@!")                 },"CEP"       })
   aadd(aEDICAO,{{||view__cgm(-1,0,@fCGM)                            },"CGM"       })
   aadd(aEDICAO,{{||NIL},NIL}) // municipio
   aadd(aEDICAO,{{||NIL},NIL}) // estado
   aadd(aEDICAO,{{||qgetx(-1,0,@fTIPO_ATIV    ,"@!")                 },"TIPO_ATIV" })
   aadd(aEDICAO,{{||qgetx(-1,0,@fOBS          ,"@!")                 },"OBS  "     })
   aadd(aEDICAO,{{||lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   QINST->(qpublicfields())
   iif(cOPCAO=="I",QINST->(qinitfields()),QINST->(qcopyfields()))
   XNIVEL := 1
   XFLAG  := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; QINST->(qreleasefields()) ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   // GRAVACAO ______________________________________________________________

   if ! lCONF ; return ; endif

   if QINST->(i_ajust_fields()) .and. QINST->(iif(cOPCAO=="I",qappend(),qrlock()))

      QINST->(qreplacefields())
      QINST->(qunlock())

      // APOS GRAVAR REATUALIZA VARIAVEIS PUBLICAS __________________________

      if XEMPRESA   == QINST->Empresa
         XEMPRESA   := QINST->Empresa
         XRAZAO     := QINST->Razao
         XSEQ       := QINST->Seq
         XCONTATO   := QINST->Contato
         XTELEFONE  := QINST->Telefone
         XCGCCPF    := QINST->CGCCPF
         XINSCR_EST := QINST->Inscr_est
         XINSCR_MUN := QINST->Inscr_mun
         XENDERECO  := QINST->Endereco
         XNUMERO    := QINST->Numero
         XCOMPL     := QINST->Compl
         XBAIRRO    := QINST->Bairro
         XCEP       := QINST->Cep
         XCGM       := QINST->Cgm
         XTIPO_ATIV := QINST->Tipo_ativ
         XOBS       := QINST->Obs
      endif

   else
      iif(cOPCAO=="I",qm1(),qm2())
   endif

return

/////////////////////////////////////////////////////////////////////////////
// CRITICAS _________________________________________________________________

static function i_critica ( cCAMPO )
   local nORD := QINST->(indexord())
   do case
      case cCAMPO == "EMPRESA" .and. cOPCAO == "I"
           qrsay(XNIVEL,fEMPRESA:=strzero(val(fEMPRESA),3))
           QINST->(dbsetorder(1))
           if QINST->(dbseek(fEMPRESA))
              qmensa("C¢digo de Empresa j  cadastrado !","B")
              QINST->(dbsetorder(nORD))
              return .F.
           endif
           QINST->(dbsetorder(nORD))
      case cCAMPO == "CGM"
           CGM->(dbseek(fCGM))
           qrsay(XNIVEL+1,CGM->Municipio)
           qrsay(XNIVEL+2,CGM->Estado)
   endcase
return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA AJUSTAR OS CAMPOS DE PATHS ___________________________________

static function i_ajust_fields
   local nREC := recno()                 // JA SELECIONADO EM QINST...
   local aFIELDS := dbstruct()
   local nCONT, cMACRO

   if cOPCAO <> "I" ; return .T. ; endif  // somente ajusta na inclusao...

   set filter to
   dbgoto(1)      // REGISTRO ESPECIAL DEVE SER SEMPRE O PRIMEIRO !

   for nCONT := 1 to len(aFIELDS)
       if "DRV_" $ aFIELDS[nCONT,1]
          cMACRO := "f" + aFIELDS[nCONT,1]
          &cMACRO. := strtran(&(aFIELDS[nCONT,1]),"000",fEMPRESA)
       endif
   next

   set filter to Empresa <> "000"

   QINST->(dbgoto(nREC))
return .T.

/////////////////////////////////////////////////////////////////////////////
// VIEW PADRAO PARA CGM _____________________________________________________

function view__cgm (XX,YY,ZZ)
   CGM->(qview(XX,YY,@ZZ,"@!",NIL,.T.,NIL,{{"Municipio",2},{"Codigo/C¢digo",1},{"Estado",0}},"C",{"keyb(Codigo)",NIL,NIL,NIL}))
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO DE KEYBOARD PARA O QVIEW, INCLUI <ENTER> __________________________

function keyb ( C_STRING )
   keyboard C_STRING + chr(K_ENTER)
return "EXIT"

/////////////////////////////////////////////////////////////////////////////
// LISTAGEM DAS EMPRESAS INSTALADAS _________________________________________

static function i_lista

   // DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

   local bESCAPE := {||(XNIVEL==1 .and. !XFLAG) .or. lastkey() == 27}
   local aEDICAO := {}

   private sBLOCO1 := qlbloc("BLOCEMP3",XDRV_SH+"QSBLOC.GLO") // tipo de relatorio
   private sBLOCO2 := qlbloc("BLOCEMP4",XDRV_SH+"QSBLOC.GLO") // ativas ou todas as empresas

   private cTIPO  // tipo de relatorio
   private cMODO  // empresas ativas ou todas
   private cTITULO1, cTITULO2

   // CRIACAO DO VETOR DE BLOCOS _______________________________________________

   aadd(aEDICAO,{{ || qesco(-1,0,@cTIPO,sBLOCO1) },"TIPO" })
   aadd(aEDICAO,{{ || qesco(-1,0,@cMODO,sBLOCO2) },"MODO" })

   do while .T.

      qlbloc(11,23,"BLOCEMP2",XDRV_SH+"QSBLOC.GLO",1)
      XNIVEL := 1
      XFLAG  := .T.
      cTIPO  := "O"
      cMODO  := "A"

      // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

      do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
         eval ( aEDICAO [XNIVEL,1] )
         if eval ( bESCAPE ) ; return ; endif
         if ! i_critica1( aEDICAO[XNIVEL,2] ) ; loop ; endif
         iif ( XFLAG , XNIVEL++ , XNIVEL-- )
      enddo

      if ( i_inicializacao() , i_impressao() , NIL )

   enddo

return

/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA _____________________________________________

static function i_critica1 ( cCAMPO )

   do case
      case cCAMPO == "TIPO"
           qrsay(XNIVEL,qabrev(cTIPO,"CO",{"Cadastral","Operacional"}))
      case cCAMPO == "MODO"
           qrsay(XNIVEL,qabrev(cMODO,"AT",{"Ativas","Todas"}))
   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // CRIA TITULO DO RELATORIO ______________________________________________

   if cTIPO == "C"
      cTITULO1 := "LISTAGEM CADASTRAL"
   else
      cTITULO1 := "LISTAGEM OPERACIONAL"
   endif

   if cMODO == "A"
      cTITULO2 := "SOMENTE EMPRESAS ATIVAS"
   else
      cTITULO2 := "TODAS AS EMPRESAS"
   endif

   QINST->(dbgotop())

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impressao
   local  XNIVEL, cLINHA := ":" + replicate("-",130) + ":"
   local cSIGLA  := left(XSIGLA,2) + "."

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif

   @ prow(),pcol() say XCOND1

   do while ! QINST->(eof()) .and. qcontprn()

      qmensa("Processando Empresa: " + QINST->Empresa + "-" + QINST->Razao)

      if ! qlineprn() ; return ; endif

      if cTIPO == "C"

         if XPAGINA == 0 .or. prow() > 55
            @ prow(),pcol() say XCOND1
            qpageprn()
            qcabecprn(cTITULO1,132,.T.,cTITULO2)
            @ prow()+1,000 say ""
            @ prow(),pcol() say XCOND2
         endif

         if cMODO == "A" .and. ! cSIGLA $ QINST->Sistemas
            QINST->(dbskip())
            loop
         endif

         @ prow()+1,000 say "CODIGO: "    + QINST->Empresa
         @ prow()  ,016 say "RAZAO: "     + QINST->Razao
         @ prow()  ,080 say "SEQ.: "      + QINST->Seq
         @ prow()  ,097 say "CONTATO: "   + QINST->Contato
         @ prow()  ,137 say "TEL.: "      + QINST->Telefone
         @ prow()+1,000 say "CGC/CEI/CPF: " + QINST->CGCCPF
         @ prow()  ,055 say "INSCRICAO ESTADUAL: "  + QINST->Inscr_est
         @ prow()  ,118 say "INSCRICAO MUNICIPAL: " + QINST->Inscr_mun
         @ prow()+1,000 say "ENDERECO: "  + QINST->Endereco
         @ prow()  ,070 say "BAIRRO: "    + QINST->Bairro
         @ prow()  ,110 say "CEP: "       + QINST->Cep
         @ prow()  ,143 say "CGM: "       + QINST->Cgm

         CGM->(dbseek(QINST->Cgm))
         
         @ prow()+1,000 say "MUNICIPIO: " + CGM->Municipio
         @ prow()  ,036 say "UF: "        + CGM->Estado
         @ prow()  ,047 say "ATIVIDADE: " + QINST->Tipo_ativ
         @ prow()  ,109 say "OBS: "       + QINST->Obs
         @ prow()+1,000 say ""

      else

         if XPAGINA == 0 .or. prow() > 55
            qpageprn()
            qcabecprn(cTITULO1,132,.T.,cTITULO2)
            @ prow()+1,000    say "| COD | RAZAO                                              | "
            @ prow()  ,pcol() say "JAN | FEV | MAR | ABR | MAI | JUN | JUL | AGO | SET | OUT | NOV | DEZ |"
            @ prow()+1,000    say "|" + repl("-",130) + "|"
         endif

         @ prow()+1,000    say "| " + QINST->Empresa + " | "
         @ prow()  ,pcol() say QINST->Razao + " | "
         @ prow()  ,pcol() say "    |     |     |     |     |     |     |     |     |     |     |     |"
         @ prow()+1,000    say "|" + repl("-",130) + "|"
      endif

      QINST->(dbskip())

   enddo

   qstopprn()

   qmensa()

return

