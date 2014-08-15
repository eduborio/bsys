/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE TESOURARIA
// OBJETIVO...: CONFIGURACAO GERAL DO SISTEMA
// ANALISTA...:
// PROGRAMADOR:
// INICIO.....: FEVEREIRO  DE 1997
// OBS........:
// ALTERACOES.:

// DECLARACAO DE VARIAVEIS __________________________________________________
function ts801

local aEDICAO   := {}
local lCONF     := .F.

private bESCAPE     := { || XNIVEL == 1 .and. !XFLAG .or. XNIVEL==1 .and. Lastkey()==27}
private nCOD_CHEQ   := CONFIG->Cod_cheq
private nCOD_BANCO  := CONFIG->Cod_banco
private nTIPO_FAT   := CONFIG->Tipo_fat
private cSABADO     := CONFIG->Sabado
private cDOMINGO    := CONFIG->Domingo
private cCAIXA      := CONFIG->Caixa

private sBLOC1  := qlbloc("B801B","QBLOC.GLO")
private sBLOC2  := qlbloc("B801C","QBLOC.GLO")
private sBLOC3  := qlbloc("B801C","QBLOC.GLO")

BANCO->(Dbsetorder(3)) // codigo do banco

qmensa("<Pressione ESC para Cancelar>")

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qgetx(-1,0,@nCOD_CHEQ                ) },"COD_CHEQ"  })
aadd(aEDICAO,{{ || qgetx(-1,0,@nCOD_BANCO               ) },"COD_BANCO" })
aadd(aEDICAO,{{ || qesco(-1,0,@nTIPO_FAT ,sBLOC1        ) } ,"TIPO_FAT" })
aadd(aEDICAO,{{ || qesco(-1,0,@cSABADO   ,sBLOC2        ) } ,"SABADO"   })
aadd(aEDICAO,{{ || qesco(-1,0,@cDOMINGO  ,sBLOC3        ) } ,"DOMINGO"  })
aadd(aEDICAO,{{ || view_banco(-1,0,@cCAIXA)               },"CAIXA"     })
aadd(aEDICAO,{{ || NIL                                    },NIL         })

aadd(aEDICAO,{{ || lCONF := qconf("Confirma altera‡„o ?") },"CONF"      })

// INICIALIZACAO DE CAMPOS E TELA ___________________________________________

qlbloc(05,00,"B801A","QBLOC.GLO",1)

XNIVEL := 1
XFLAG  := .T.

qrsay(XNIVEL++,strzero(CONFIG->Cod_cheq,5))
qrsay(XNIVEL++,strzero(CONFIG->Cod_banco,5))
qrsay(XNIVEL++,qabrev(CONFIG->Tipo_fat,"123456789A", {"Comercial","Industrial","Servi‡os","Tele-Vendas","Transportes","Concretagem","Loja","Acessoria","Fabrica","Embalagens"}))
qrsay(XNIVEL++,qabrev(CONFIG->Sabado,"12", {"1 - Sim","2 - N„o"}))
qrsay(XNIVEL++,qabrev(CONFIG->Domingo,"12", {"1 - Sim","2 - N„o"}))
qrsay(XNIVEL++,CONFIG->Caixa ) ; BANCO->(dbseek(CONFIG->Caixa))
qrsay(XNIVEL++,left(BANCO->Descricao,20))

XNIVEL := 1

// LOOP PARA ENTRADA DOS DADOS ______________________________________________

do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
   eval ( aEDICAO [XNIVEL,1] )
   if eval ( bESCAPE ) ; return ; endif
   if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
   iif ( XFLAG , XNIVEL++ , XNIVEL-- )
enddo

// GRAVACAO _________________________________________________________________

if lCONF
   if CONFIG->(qrlock())
      CONFIG->Cod_cheq   := nCOD_CHEQ
      CONFIG->Cod_banco  := nCOD_BANCO
      CONFIG->Tipo_fat   := nTIPO_FAT
      CONFIG->Sabado     := cSABADO
      CONFIG->Domingo    := cDOMINGO
      CONFIG->Caixa      := cCAIXA
      CONFIG->(qunlock())
   else
      qmensa("Nao foi possivel alterar a configura‡„o, tente novamente","B")
   endif
endif
return

/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA _____________________________________________

static function i_critica ( cCAMPO )
   do case
      case cCAMPO == "COD_CHEQ"
           if nCOD_CHEQ < 0  ; return .F. ; endif
           qrsay(XNIVEL,strzero(nCOD_CHEQ,5))
      case cCAMPO == "COD_BANCO"
           if nCOD_BANCO < 0  ; return .F. ; endif
           qrsay(XNIVEL,strzero(nCOD_BANCO,5))
      case cCAMPO == "TIPO_FAT"
           if empty(nTIPO_FAT) ; return .F. ; endif
           qrsay(XNIVEL,qabrev(nTIPO_FAT,"123456789A", {"Comercial","Industrial","Servi‡os","Tele-Vendas","Transportes","Concretagem","Loja","Acessoria","Fabrica","Embalagens"}))
      case cCAMPO == "SABADO"
           if empty(cSABADO) ; return .F. ; endif
           qrsay(XNIVEL,qabrev(cSABADO,"12", {"1 - Sim","2 - N„o"}))
      case cCAMPO == "DOMINGO"
           if empty(cDOMINGO) ; return .F. ; endif
           qrsay(XNIVEL,qabrev(cDOMINGO,"12", {"1 - Sim","2 - N„o"}))
      case cCAMPO == "CAIXA"
           if ! empty(cCAIXA)
              if ! BANCO->(dbseek(cCAIXA:=strzero(val(cCAIXA),5)))
                  qmensa("Cadastro Conta Caixa n„o Cadastrada !","B")
                  return .F.
              endif
              qrsay(XNIVEL+1,left(BANCO->Descricao,20))
           endif
   endcase

return .T.
