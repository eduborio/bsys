/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: FOLHA DE PAGAMENTO
// OBJETIVO...: MANUTENCAO DE SITUACAO DE FUNCIONARIO
// ANALISTA...: CARLOS EDUARDO RABELLO NUNES
// PROGRAMADOR: O MESMO
// INICIO.....: 1994
// OBS........:
// ALTERACOES.:

// FAZ RELACIONAMENTO E ENTRA EM BROWSE _____________________________________

SITUA->(dbSetFilter({|| Anomes <= XANOMES},"Anomes <= XANOMES"))

SITUA->(dbsetrelation("AFAST",{||SITUA->Af_cod},"SITUA->Af_cod"))

FUN->(qview({{"Matricula/Matric"                   ,1},;
             {"left(Nome,30)/Nome"                 ,2},;
             {"c415a(Situacao)/Sit"                ,0},;
             {"c415b()/Cod"                        ,0},;
             {"left(AFAST->Descricao,25)/Descri‡„o",0}},"P",;
             {NIL,"c415c",NIL,NIL},NIL,;
             "ALT-P / ALT-O / <A>ltera / <C>onsulta / <ESC>"))
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXPANDIR A SITUACAO DO FUNCIONARIO ___________________________

function c415a (cSITUACAO)
return qabrev(cSITUACAO," TFADH",{"      ","Trab. ","F‚rias","Afast.","Demit.","Homol."})

/////////////////////////////////////////////////////////////////////////////
// FUNCAO RETORNAR CODIGO NOME DO FUNCIONARIO ______________________________________

function c415b
   SITUA->(qseekn(FUN->Matricula))
return(SITUA->Af_cod)

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ALTERAR A SITUACAO E O TIPO DE AFASTAMENTO ___________________

function c415c
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))
   if cOPCAO $ XUSRA
      qlbloc(10,9,"B415A","QBLOC.GLO",1)
      qmensa(qabrev(cOPCAO,"CA",{"Consulta... <ESC - Cancela>","Altera‡„o... <ESC - Cancela>"}))
      SITUA->(qseekn(FUN->Matricula))
      i_edicao()
   endif
   setcursor(nCURSOR)
return ""

/////////////////////////////////////////////////////////////////////////////
// EDICAO DA ALTERACAO ______________________________________________________

static function i_edicao
   local cSITUACAO  := SITUA->Situacao
   local cAF_COD    := SITUA->Af_cod
   local dAF_INI    := SITUA->Af_ini
   local dAF_RET    := SITUA->Af_ret
   local dAV_INI    := SITUA->Inicio_av
   local dAV_FIM    := SITUA->Final_av
   local cCODSAQ    := SITUA->Codsaqfgts
   local dBI_FERIAS := SITUA->Bi_ferias
   local dBF_FERIAS := SITUA->Bf_ferias
   local sBLOC      := qlbloc("B415B","QBLOC.GLO")

   XNIVEL := 1

   qrsay(XNIVEL++,FUN->Matricula)
   qrsay(XNIVEL++,left(FUN->Nome,30))
   qrsay(XNIVEL++,c415a(SITUA->Situacao))
   qrsay(XNIVEL++,SITUA->Codsaqfgts)
   qrsay(XNIVEL++,SITUA->Af_cod)
   qrsay(XNIVEL++,AFAST->Descricao)

   if SITUA->Situacao = "F"
      qrsay(XNIVEL++,SITUA->Pi_ferias)
      qrsay(XNIVEL++,SITUA->Pf_ferias)
   else
      qrsay(XNIVEL++,SITUA->Af_ini)
      qrsay(XNIVEL++,SITUA->Af_ret)
   endif

   if SITUA->Situacao = "F"
      qrsay(XNIVEL++,SITUA->Bi_ferias)
      qrsay(XNIVEL++,SITUA->Bf_ferias)
   else
      qrsay(XNIVEL++,SITUA->Inicio_av)
      qrsay(XNIVEL++,SITUA->Final_av)
   endif

   if cOPCAO == "C" ; qwait() ; return ; endif

   XNIVEL := 3
   qesco(-1,0,@cSITUACAO,sBLOC)
   if empty(cSITUACAO) ; return ; endif
   qrsay(XNIVEL,c415a(cSITUACAO))

   if cSITUACAO == "T"
      cCODSAQ    := space(2)
      cAF_COD    := space(2)
      dAF_INI    := ctod("")
      dAF_RET    := ctod("")
      dAV_INI    := ctod("")
      dAV_FIM    := ctod("")
      dBI_FERIAS := ctod("")
      dBF_FERIAS := ctod("")
      qsay(13,64,cCODSAQ)
      qsay(15,22,cAF_COD)
      qsay(15,39,space(30))
      qsay(17,28,dAF_INI)
      qsay(17,58,dAF_RET)
      qsay(19,28,dAV_INI)
      qsay(19,58,DAV_FIM)
   else
      if cSITUACAO != "F"
         XNIVEL++
         qgetx(-1,0,@cCODSAQ,"@!")
      else
         XNIVEL++
         cAF_COD := "FR"
      endif

      XNIVEL++
      view_afast(-1,0,@cAF_COD,)
      AFAST->(dbseek(cAF_COD))
      qrsay(XNIVEL+1,AFAST->Descricao)

      if cAF_COD == "FR"
         cCODSAQ := space(2)
         dAV_INI := SITUA->Bi_ferias
         dAV_FIM := SITUA->Bf_ferias
         qsay(13,64,cCODSAQ)
         qsay(19,28,dAV_INI)
         qsay(19,58,dAV_FIM)
      endif

      XNIVEL += 2

      qgetx(-1,0,@dAF_INI)

      XNIVEL++

      if AFAST->Retorno == "S"
         qgetx(-1,0,@dAF_RET)
         if dAF_RET < dAF_INI
            qmensa("Data anterior ao inicio das ferias !","B")
            return .F.
         endif
      endif

      if cAF_COD == "FR"
         XNIVEL++
         qgetx(-1,0,@dAV_INI)
         XNIVEL++
         qgetx(-1,0,@dAV_FIM)
         if dAV_FIM < dAV_INI
            qmensa("Data anterior ao inicio do abono !","B")
         endif
      else
         XNIVEL++
         qgetx(-1,0,@dAV_INI)
         XNIVEL++
         qgetx(-1,0,@dAV_FIM)
      endif
   endif

   if qconf("Confirma alterar situa‡„o ?")

      BASE->(dbseek(FUN->Matricula+XANOMES))

      if FUN->(qrlock()) .and. SITUA->(qrlock()) .and. BASE->(qrlock())

         if SITUA->Situacao $ "DF" .and. cSITUACAO == "T"
            BASE->(dbdelete())
            BASE->(qunlock())
          endif

         replace FUN->Situacao     with cSITUACAO
         replace SITUA->Situacao   with cSITUACAO
         replace SITUA->Af_cod     with cAF_COD
         replace SITUA->Af_ini     with dAF_INI
         replace SITUA->Af_ret     with dAF_RET
         replace SITUA->Inicio_av  with iif(cAF_COD!="FR",dAV_INI,ctod(""))
         replace SITUA->Final_av   with iif(cAF_COD!="FR",dAV_FIM,ctod(""))
         replace SITUA->Codsaqfgts with cCODSAQ
         replace SITUA->PI_ferias  with dAF_INI
         replace SITUA->Pf_ferias  with dAF_RET
         replace SITUA->BI_ferias  with iif(cAF_COD=="FR",dAV_INI,ctod(""))
         replace SITUA->Bf_ferias  with iif(cAF_COD=="FR",dAV_FIM,ctod(""))
         replace FUN->Dt_Afast  with dAF_ini
         FUN->(qunlock())

      else
         qm2()
      endif

   endif

return

