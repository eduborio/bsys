/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO COMERCIO
// OBJETIVO...: LISTAGEM DE CLIENTES POR REPRESENTANTE
// ANALISTA...: EDUARDO AUGUSTO BORIO
// PROGRAMADOR: EDUARDO AUGUSTO BORIO
// INICIO.....: MARCO DE 2006
// OBS........:
// ALTERACOES.:

function cl561
#define K_MAX_LIN 57

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG).or. LastKey()==27  }

private cTITULO                   // titulo do relatorio
private dINI
private dFIM

private aEDICAO := {}             // vetor para os campos de entrada de dados

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || qgetx(-1,0,@dINI)            } , "INI"    })
aadd(aEDICAO,{{ || qgetx(-1,0,@dFIM)            } , "FIM"    })

do while .T.

   qlbloc(5,0,"B561A","QBLOC.GLO")

   dINI := ctod("")
   dFIM := ctod("")
   XNIVEL := 1
   XFLAG  := .T.

   // SEGUNDO LOOP PARA ENTRADA DOS DADOS ___________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; dbcloseall() ; return ; endif
      if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   if ( i_inicializacao() , i_impressao() , NIL )

   qmensa("")

enddo

/////////////////////////////////////////////////////////////////////////////
// CRITICA ADICIONAL NA DESCIDA _____________________________________________

static function i_critica ( cCAMPO )

   do case
      case cCAMPO == "FIM"
          if dFIM < dINI
             qmensa("Data Final Invalida !","B")
             return .F.
          endif



   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // CRIA TITULO DO RELATORIO ______________________________________________


   cTITULO := "Relacao de Clientes/Contatos Aniversariantes "

   qmensa("")

   // ESTABELECE RELACOES ENTRE ARQUIVOS ____________________________________

   CLI1->(dbgotop())
return .T.


static function i_impressao

   if ! qinitprn() ; return ; endif

   if XLOCALIMP == "X"
      i_impre_xls()
   else
      i_impre_prn()
   endif



return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO __________________________

static function i_impre_prn
    local cREP       := space(5)
    local aCLI       := {}
    local asCLI      := {}
    local lTEM := .F.
    local zPROD := space(50)
    local nMD_INI := 0
    local nMD_FIM := 0
    local nMD_CLI := 0
   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________
    lTEM := .F.
    aCLI := {}
    nMD_INI := val(strzero(month(dINI),2)+strzero(day(dINI),2))
    nMD_FIM := val(strzero(month(dFIM),2)+strzero(day(dFIM),2))


   do while ! CLI1->(eof())

      nMD_CLI := val(right(CLI1->Dt_aniver,2)+left(CLI1->dt_aniver,2))

      if nMD_CLI < nMD_INI .or. nMD_CLI > nMD_FIM
         CLI1->(dbskip())
         loop
      endif


      CGM->(dbseek(CLI1->Cgm_ent))
      aadd(aCLI,{CLI1->Dt_aniver,"",left(CLI1->Razao,40),left(CLI1->Fantasia,20),left(CLI1->Contato_c,15),CLI1->Fone1,left(CGM->Municipio,18),CGM->Estado,left(CLI1->email,25)})
      lTEM := .T.
      CLI1->(dbskip())
      qmensa("Aguarde... Processando ...")

   enddo
   //classifica a matriz por descricao do produto
   asCLI := asort(aCLI,,,{|x,y| x[1] + x[3] < y[1] + y[3] })
   if lTEM
       nCONT := 1
       do while  nCONT <= len(asCLI)

           if ! qlineprn() ; exit ; endif
           if XPAGINA == 0 .or. prow() > K_MAX_LIN
              @prow()+1,0 say XCOND2
              qpageprn()
              qcabecprn(cTITULO,136)
              @ prow()+1,0 say XCOND2 + "Data    Razao Social/Nome                         Fantasia              Contato Com.     Telefone        Cidade              UF   E-Mail"
              @ prow()+1,0 say replicate("-",134)
           endif

           @ prow()+1,00 say asCLI[nCONT,1]   //Aniversario
           @ prow()  ,08 say asCLI[nCONT,3]   //Razao
           @ prow()  ,50 say asCLI[nCONT,4]   //Fantasia
           @ prow()  ,72 say asCLI[nCONT,5]   //Contato
           @ prow()  ,89 say asCLI[nCONT,6]   //Telefone
           @ prow()  ,105 say asCLI[nCONT,7]   //Municipio
           @ prow()  ,125 say asCLI[nCONT,8]   //Estado
           @ prow()  ,130 say asCLI[nCONT,9]  //E-Mail


           nCONT++
           if nCONT > len(asCLI)
              nCONT := len(asCLI)
              exit
           endif

       enddo

   endif

   qstopprn()

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INICIALIZAR O PROCESSO DE IMPRESSAO EM EXCEL__________________

static function i_impre_xls
    local cREP       := space(5)
    local aCLI       := {}
    local asCLI      := {}
    local lTEM := .F.
    local zPROD := space(50)
    local nMD_INI := 0
    local nMD_FIM := 0
    local nMD_CLI := 0

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________
    lTEM := .F.
    aCLI := {}

    nMD_INI := val(strzero(month(dINI),2)+strzero(day(dINI),2))
    nMD_FIM := val(strzero(month(dFIM),2)+strzero(day(dFIM),2))


   do while ! CLI1->(eof())

      nMD_CLI := val(right(CLI1->Dt_aniver,2)+left(CLI1->dt_aniver,2))

      if nMD_CLI < nMD_INI .or. nMD_CLI > nMD_FIM
         CLI1->(dbskip())
         loop
      endif

      CGM->(dbseek(CLI1->Cgm_ent))

      aadd(aCLI,{CLI1->Cod_repres,CLI1->Codigo,CLI1->Razao,CLI1->Fantasia,CLI1->Contato_c,CLI1->Fone1,CGM->Municipio,CGM->Estado,CLI1->email})
      lTEM := .T.
      CLI1->(dbskip())
      qmensa("Aguarde... Processando ...")

   enddo
   //classifica a matriz por descricao do produto
   asCLI := asort(aCLI,,,{|x,y| x[1] + x[3] < y[1] + y[3] })
   if lTEM

       nCONT := 1
       do while  nCONT <= len(asCLI)

           if ! qlineprn() ; exit ; endif
           if XPAGINA == 0
              qpageprn()
              @ prow()+1,0 say cTITULO
              @ prow()+1,0 say "Data"+chr(9)+"Razao Social/Nome"+chr(9)+ "Fantasia"+chr(9)+  "Contato Com."+chr(9)+  "Telefone"+chr(9)+  "Cidade" +chr(9)+ "UF" +chr(9)+  "E-Mail"
           endif

           @ prow()+1,00 say asCLI[nCONT,1]+chr(9)   //Razao
           @ prow()  ,pcol() say asCLI[nCONT,3]+chr(9)   //Razao
           @ prow()  ,pcol() say asCLI[nCONT,4]+chr(9)   //Fantasia
           @ prow()  ,pcol() say asCLI[nCONT,5]+chr(9)   //Contato
           @ prow()  ,pcol() say asCLI[nCONT,6]+chr(9)   //Telefone
           @ prow()  ,pcol() say asCLI[nCONT,7]+chr(9)   //Municipio
           @ prow()  ,pcol() say asCLI[nCONT,8]+chr(9)   //Estado
           @ prow()  ,pcol() say asCLI[nCONT,9]          //E-Mail


           nCONT++
           if nCONT > len(asCLI)
              nCONT := len(asCLI)
              exit
           endif

       enddo

   endif

   qstopprn()


return



