/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO COMERCIO
// OBJETIVO...: LISTAGEM DE CLIENTES POR REPRESENTANTE
// ANALISTA...: EDUARDO AUGUSTO BORIO
// PROGRAMADOR: EDUARDO AUGUSTO BORIO
// INICIO.....: MARCO DE 2006
// OBS........:
// ALTERACOES.:

function cl547
#define K_MAX_LIN 57

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

local   bESCAPE := {||(XNIVEL==1 .and. !XFLAG).or. LastKey()==27  }

private cTITULO                   // titulo do relatorio
private cREPRES := space(5)
private cRAZAO := space(40)
private aEDICAO := {}             // vetor para os campos de entrada de dados

// CRIACAO DO VETOR DE BLOCOS _______________________________________________

aadd(aEDICAO,{{ || view_repres(-1,0,@cREPRES)         } , "REPRES"  })
aadd(aEDICAO,{{ || NIL                          } , NIL  })

do while .T.

   qlbloc(5,0,"B547A","QBLOC.GLO")
   XNIVEL := 1
   XFLAG  := .T.
   cREPRES := space(5)
   cRAZAO := space(40)

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
      case cCAMPO == "REPRES"

           qrsay(XNIVEL,cREPRES)

           if empty(cREPRES)
              qrsay(XNIVEL++, "Todos os Representantes.......")
              cRAZAO := "Todos os Representantes"
           else
              if ! REPRES->(Dbseek(cREPRES:=strzero(val(cREPRES),5)))
                 qmensa("Represntante n„o Cadastrado","B")
                 return .F.
              else
                 qrsay(XNIVEL++,left(REPRES->Razao,40))
                 cRAZAO := left(REPRES->Razao,40)
              endif
           endif

   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER A INICIALIZACAO DO RELATORIO ___________________________

static function i_inicializacao

   // CRIA TITULO DO RELATORIO ______________________________________________


   cTITULO := "Relacao de Clientes por Representante"

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
   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________
    lTEM := .F.
    aCLI := {}

   do while ! CLI1->(eof())


      if ! empty(cREPRES)
         if CLI1->Cod_repres != cREPRES
            CLI1->(Dbskip())
            loop
         endif
      endif
      CGM->(dbseek(CLI1->Cgm_ent))

      aadd(aCLI,{CLI1->Cod_repres,CLI1->Codigo,left(CLI1->Razao,40),left(CLI1->Fantasia,20),left(CLI1->Contato_c,15),CLI1->Fone1,left(CGM->Municipio,18),CGM->Estado,left(CLI1->email,25)})
      lTEM := .T.
      CLI1->(dbskip())
      qmensa("Aguarde... Processando ...")

   enddo
   //classifica a matriz por descricao do produto
   asCLI := asort(aCLI,,,{|x,y| x[1] + x[3] < y[1] + y[3] })
   if lTEM
       cREP     := asCLI[1,1]
       REPRES->(dbseek(cREP))
       cRAZ_REPRES := left(REPRES->Razao,35)

       nCONT := 1
       do while  nCONT <= len(asCLI)

           if ! qlineprn() ; exit ; endif
           if XPAGINA == 0 .or. prow() > K_MAX_LIN
              @prow()+1,0 say XCOND2
              qpageprn()
              qcabecprn(cTITULO,136)
              @ prow()+1,0 say XCOND2 + "Razao Social/Nome                         Fantasia              Contato Com.     Telefone        Cidade              UF   E-Mail"
              @ prow()+1,0 say replicate("-",134)
           endif

           @ prow()+1,00 say asCLI[nCONT,3]   //Razao
           @ prow()  ,42 say asCLI[nCONT,4]   //Fantasia
           @ prow()  ,64 say asCLI[nCONT,5]   //Contato
           @ prow()  ,81 say asCLI[nCONT,6]   //Telefone
           @ prow()  ,97 say asCLI[nCONT,7]   //Municipio
           @ prow()  ,117 say asCLI[nCONT,8]   //Estado
           @ prow()  ,122 say asCLI[nCONT,9]  //E-Mail


           nCONT++
           if nCONT > len(asCLI)
              nCONT := len(asCLI)
              exit
           endif

           if asCLI[nCONT,1] != cREP
              @ prow()+1,00 say "Representante.: "+left(cRAZ_REPRES,35)
              cREP := asCLI[nCONT,1]
              REPRES->(dbseek(cREP))
              cRAZ_REPRES := REPRES->Razao
              @ prow()+1,00 say ""

           endif
       enddo

       REPRES->(dbseek(cREP))
       cRAZ_REPRES := REPRES->Razao

       @ prow()+1,00 say "Representante.: "+left(cRAZ_REPRES,35)
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
   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________
    lTEM := .F.
    aCLI := {}

   do while ! CLI1->(eof())


      if ! empty(cREPRES)
         if CLI1->Cod_repres != cREPRES
            CLI1->(Dbskip())
            loop
         endif
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
       cREP     := asCLI[1,1]
       REPRES->(dbseek(cREP))
       cRAZ_REPRES := left(REPRES->Razao,35)

       nCONT := 1
       do while  nCONT <= len(asCLI)

           if ! qlineprn() ; exit ; endif
           if XPAGINA == 0
              qpageprn()
              @ prow()+1,0 say cTITULO
              @ prow()+1,0 say "Razao Social/Nome"+chr(9)+ "Fantasia"+chr(9)+  "Contato Com."+chr(9)+  "Telefone"+chr(9)+  "Cidade" +chr(9)+ "UF" +chr(9)+  "E-Mail"
           endif

           @ prow()+1,00 say asCLI[nCONT,3]+chr(9)   //Razao
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

           if asCLI[nCONT,1] != cREP
              @ prow()+1,00 say "Representante.: "+left(cRAZ_REPRES,35)
              cREP := asCLI[nCONT,1]
              REPRES->(dbseek(cREP))
              cRAZ_REPRES := REPRES->Razao
              @ prow()+1,00 say ""

           endif
       enddo

       REPRES->(dbseek(cREP))
       cRAZ_REPRES := REPRES->Razao

       @ prow()+1,00 say "Representante.: "+left(cRAZ_REPRES,35)
   endif

   qstopprn()


return



