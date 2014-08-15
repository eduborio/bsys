
//////////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE ESCRITA FISCAL
// OBJETIVO...: ZERAR OS ARQUIVOS POR PERIODO
// ANALISTA...: LUIS ANTONIO ORLANDO PEREIRA
// PROGRAMADOR: IN SUNG CHANG
// INICIO.....: JANEIRO DE 1996
// OBS........:
// ALTERACOES.:
function ef804

// DECLARACAO E INICIALIZACAO DE VARIAVEIS _______________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG .or. lastkey() = 27)}

private sBLOC1 := qlbloc("B804A","QBLOC.GLO") // Periodo da delecao
private dDATA_INI                             // Inicio do periodo da delecao
private dDATA_FIM                             // Fim do periodo da delecao
private aEDICAO    := {}                      // vetor para os campos de entrada de dados

private bENT_FILTRO                           // code block de filtro entradas
private bSAI_FILTRO                           // code block de filtro saidas
private bISS_FILTRO                           // code block de filtro servicos prestados
private bBASE_FILTRO                          // code block de filtro base
private bDARF_FILTRO                          // code block de filtro darf
private bIMP_FILTRO                           // code block de filtro impposto
private bOUTENT_FILTRO                        // code block de filtro outras entradas

// CRIACAO DO VETOR DE BLOCOS ____________________________________________________

   qlbloc(5,0,"B804A","QBLOC.GLO",1)

   aadd(aEDICAO,{{ || qgetx(-1,0,@dDATA_INI   ,"@!"     ,NIL,NIL) } ,"DATA_INI"})
   aadd(aEDICAO,{{ || qgetx(-1,0,@dDATA_FIM   ,"@!"     ,NIL,NIL) } ,"DATA_FIM"})

do while .T.

   qlbloc(5,0,"B804A","QBLOC.GLO")
   XNIVEL      := 1
   dDATA_INI   := ctod("01/01/" + left(XANOMES,4))
   dDATA_FIM   := ctod("31/12/" + left(XANOMES,4))

   // SEGUNDO LOOP PARA ENTRADA DOS DADOS ________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; dbcloseall() ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo
   if qconf("Confirma a Dele‡„o de arquivos ?","B")
      if alert("Antes de DELETAR os arquivos,; favor verificar se foi feito o BACKUP; Deseja DELETAR ?",{"NAO","SIM"}) == 2
         if qmensa("Senha para processar dele‡„o...:"),qgetsenha(24,44,9) == "BORBOLETA"
            if (i_inicia() , i_delecao() , NIL)
         endif
      endif
   endif
enddo

return

//////////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA __________________________________________________

static function i_critica ( cCAMPO )
   do case
      case cCAMPO == "DATA_INI"
           if empty(dDATA_INI) ; return .F. ; endif
           qrsay(XNIVEL+1,dDATA_FIM)

      case cCAMPO == "DATA_FIM"
           if empty(dDATA_FIM) ; return .F. ; endif
           if dDATA_INI > dDATA_FIM
              qmensa("Data Inicial n„o pode ser maior que a Data Final !","B")
              return .F.
           endif
   endcase
return .T.

//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA DELECAO DE ARQUIVOS _______________________________________________

static function i_delecao

       do while ! ENT->(eof())
          qmensa("Excluindo o arquivo ENT ! * AGUARDE *")
          if ENT->(qrlock()) .and. eval(bENT_FILTRO)
             qgirabarra()
             ENT->(dbdelete())
             ENT->(qunlock())
          endif
          ENT->(dbskip())
       enddo

       do while ! SAI->(eof())
          qmensa("Excluindo o arquivo SAI ! * AGUARDE *")
          if SAI->(qrlock()) .and. eval(bSAI_FILTRO)
             qgirabarra()
             SAI->(dbdelete())
             SAI->(qunlock())
          endif
          SAI->(dbskip())
       enddo

       do while ! ISS->(eof())
          qmensa("Excluindo o arquivo ISS ! * AGUARDE *")
          if ISS->(qrlock()) .and. eval(bISS_FILTRO)
             qgirabarra()
             ISS->(dbdelete())
             ISS->(qunlock())
          endif
          ISS->(dbskip())
       enddo

       do while ! BASE->(eof())
          qmensa("Excluindo o arquivo BASE ! * AGUARDE *")
          if BASE->(qrlock()) .and. eval(bBASE_FILTRO)
             qgirabarra()
             BASE->(dbdelete())
             BASE->(qunlock())
          endif
          BASE->(dbskip())
       enddo

       do while ! DARF->(eof())
          qmensa("Excluindo o arquivo DARF ! * AGUARDE *")
          if DARF->(qrlock()) .and. eval(bDARF_FILTRO)
             qgirabarra()
             DARF->(dbdelete())
             DARF->(qunlock())
          endif
          DARF->(dbskip())
       enddo

       do while ! IMP->(eof())
          qmensa("Excluindo o arquivo IMP ! * AGUARDE *")
          if IMP->(qrlock()) .and. eval(bIMP_FILTRO)
             qgirabarra()
             IMP->(dbdelete())
             IMP->(qunlock())
          endif
          IMP->(dbskip())
       enddo

       do while ! OUTENT->(eof())
          qmensa("Excluindo o arquivo OUTENT ! * AGUARDE *")
          if OUTENT->(qrlock()) .and. eval(bOUTENT_FILTRO)
             qgirabarra()
             OUTENT->(dbdelete())
             OUTENT->(qunlock())
          endif
          OUTENT->(dbskip())
       enddo

return .T.
/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicia

   qmensa("")

   // CRIA MACRO DE FILTRO __________________________________________________

   bENT_FILTRO     := { || ENT->DATA_LANC    >= dDATA_INI .and. ENT->DATA_LANC    <= dDATA_FIM }
   bSAI_FILTRO     := { || SAI->DATA_LANC    >= dDATA_INI .and. SAI->DATA_LANC    <= dDATA_FIM }
   bISS_FILTRO     := { || ISS->DATA_LANC    >= dDATA_INI .and. ISS->DATA_LANC    <= dDATA_FIM }
   bBASE_FILTRO    := { || BASE->DATA_INI    >= dDATA_INI .and. BASE->DATA_FIM    <= dDATA_FIM }
   bDARF_FILTRO    := { || DARF->DATA_INI    >= dDATA_INI .and. DARF->DATA_FIM    <= dDATA_FIM }
   bIMP_FILTRO     := { || IMP->DATA_INI     >= dDATA_INI .and. IMP->DATA_FIM     <= dDATA_FIM }
   bOUTENT_FILTRO  := { || OUTENT->DATA_LANC >= dDATA_INI .and. OUTENT->DATA_LANC <= dDATA_FIM }

   // ESTABELECE RELACOES ENTRE ARQUIVOS ____________________________________

   select SAI                          // Saidas
   SAI->(dbsetorder(2))
   SAI->(dbgotop())

   select ENT                          // Entradas
   ENT->(dbsetorder(2))
   ENT->(dbgotop())

   select ISS                          // Servicos Prestados
   ISS->(dbsetorder(2))
   ISS->(dbgotop())

   select BASE                         // Base do lucro presumido
   BASE->(dbsetorder(1))
   BASE->(dbgotop())

   select DARF
   DARF->(dbsetorder(1))               // Darf
   DARF->(dbgotop())

   select IMP
   IMP->(dbsetorder(1))                // Imposto
   IMP->(dbgotop())

   select OUTENT
   OUTENT->(dbsetorder(1))             // Outras entrada
   OUTENT->(dbgotop())

return .T.


