///////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FATURAMENTO COMERCIO
// OBJETIVO...: LANCAMENTO DE PEDIDO DE VENDA
// ANALISTA...:
// PROGRAMADOR: EDUARDO BORIO
// INICIO.....: MARCO DE 1998
// OBS........:

function cl201

#include "inkey.ch"

#define K_MAX_LIN 56

private fDIA1 := fDIA2 := fDIA3 := fDIA4 := fDIA5 := fDIA6 := fDIA7 := nDES := 0
private fVALOR1 := fVALOR2 := fVALOR3 := fVALOR4 := fVALOR5 := fVALOR6 := fVALOR7 := 0
private fTOTAL  := 0
private fSERVICO := 0
private fPEDIDO := 0
private fIPI_VLR := 0
private fST_VLR  := 0
private nITENS := 0
private fPARC  := 0
private nCOMISSAO := 0
private lALT   := .F.
private sBLOC1  := qlbloc("B201D","QBLOC.GLO")
private sBLOC2  := qlbloc("B201ES","QBLOC.GLO")
private sBLOC3  := qlbloc("B201FR","QBLOC.GLO")
private sBLOC4  := qlbloc("B201DP","QBLOC.GLO")
private cDATA := date()
PRIVATE Lconf := .F.

CCUSTO->(Dbsetorder(4))

/////////////////////////////////////////////////////////////////////////////
// MANUTENCAO DE PEDIDO DE VENDA ___________________________________________
FAT->(dbsetfilter({|| FAT->Es $ "SC" .and. ! FAT->No_nf }))
//ITEN_FAT->(dbsetfilter({|| Devolucao == space(1)},"Devolucao == space(1)"))
if CONFIG->Modelo_fat == "5"
FAT->(qview({{"Codigo/Pedido"             ,1},;
             {"i_201can()/Status"         ,0},;
             {"Dt_emissao/Emissao"        ,2},;
             {"left(Cliente,25)/Cliente"  ,7},;
             {"Num_fatura/No. NF ",11}},"P",;
             {NIL,"i_201c",NIL,NIL},;
              NIL,q_msg_acesso_usr()+"/im<P>rime /<F>echar"))
return

elseIF CONFIG->Modelo_fat == "2"



   FAT->(qview({{"Codigo/Pedido"             ,1},;
                {"Dt_emissao/Emissao"        ,2},;
                {"i_201obs()/Obs"            ,0},;
                {"left(Cliente,36)/Cliente"  ,7},;
                {"Num_fatura/No. NF ",11}},"P",;
                {NIL,"i_201c",NIL,NIL},;
                 NIL,q_msg_acesso_usr()+"/im<P>rime /Cancela<R>"))
   return
ELSE
    if CONFIG->Modelo_NF == "01"
       FAT->(qview({{"Codigo/Pedido"             ,11},;
                    {"Dt_emissao/Emissao"        ,2},;
                    {"i_201obs()/Obs"            ,0},;
                    {"left(Cliente,25)/Cliente"  ,7},;
                    {"i_201fora()/Estoque Fora"  ,0},;
                    {"Num_fatura/No. NF ",11}},"P",;
                    {NIL,"i_201c",NIL,NIL},;
                     NIL,q_msg_acesso_usr()+"/im<P>rime /<F>echar/Cancela<R>/<D>escancelar"))

       return
    else
       FAT->(qview({{"Codigo/Pedido"             ,1},;
                    {"Dt_emissao/Emissao"        ,2},;
                    {"i_201obs()/Obs"            ,0},;
                    {"left(Cliente,35)/Cliente"  ,7},;
                    {"Modelo/Modelo"             ,0},;
                    {"Num_fatura/No. NF ",11}},"P",;
                    {NIL,"i_201c",NIL,NIL},;
                     NIL,q_msg_acesso_usr()+"/im<P>rime /<F>echar"))


       return
    endif
endif

//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAGEM DO CLIENTE ______________________________________________

function i_desccli

    CLI1->(dbseek(FAT->Cod_cli))

return " sql "+left(CLI1->razao,25)

function i_201can
  local cRET := "         "

  if FAT->Cancelado == .T.
     cRET    := "CANCELADO"
  endif

return cRET

function i_201Fora
local cRET := space(3)

    if FAT->Estoq_fora == "S"
       cRET := "Sim"
    endif

return cRet

function i_201a
   CLI1->(dbseek(FAT->Cod_cli))
return left(CLI1->Razao,25)


function i_201obs
    OBSERVAC->(dbseek(FAT->Codigo))
return iif(!empty(OBSERVAC->Obs1),"Sim","   ")


//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA MOSTRAGEM DO CENTRO DE CUSTO  _____________________________________

function i_201b
   CCUSTO->(dbseek(FAT->C_custo))
return left(CCUSTO->Descricao,18)

//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO _____________________________________

function i_201c

   local nCURSOR := setcursor(1)
   local sbloc1  := qlbloc("B201OP","QBLOC.GLO")
   local cOrdem  := "1"
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))

     if cOPCAO == "A" .and. FAT->Cancelado
        qmensa("Pedido Cancelado, Alteracao Negada !","B")
        return .F.
     endif

     //iif(cOPCAO == "Z", i_descancela(),)
     //iif(cOPCAO == "O", i_Observacao(),)
     
	 
	 if cOPCAO == "P"
	    qesco(15,15,@cOrdem,sbloc1)
		i_imprime(cOrdem)
	 endif	

     if CONFIG->Modelo_fat == "1"
        iif(cOPCAO == "F", i_Fecha(),)
		iif(cOPCAO == "L", i_aliquotaIcms(),)
        //iif(cOPCAO == "D", i_gera_entTransf(),)
        // iif(cOPCAO == "M", i_mudanomecli(),)
        // iif(cOPCAO == "L", i_dup_fat(FAT->Codigo),)
     else
       if CONFIG->Modelo_2 == "7"
          iif(cOPCAO == "F", i_aVista(),)
       endif
     endif

   if cOPCAO $ XUSRA .and. empty(CONFIG->Qsysoff)

      if cOPCAO == "A" .and. CONFIG->Modelo_fat == "1" .and. ! empty(FAT->Num_fatura) .and. ! empty(FAT->NFe)
         if ! i_admin()
            qmensa("Senha invalida!!!","BL")
            return .F.
         endif
      endif

      iif(cOPCAO == "A", lALT := .T.,)

      if CONFIG->Modelo_2 $ "9"
        qlbloc(5,0,"B201AK","QBLOC.GLO",1)
      elseif CONFIG->Modelo_fat == "8"
        qlbloc(5,0,"B201M","QBLOC.GLO",1)
      elseif CONFIG->Modelo_2 == "2"
        qlbloc(5,0,"B201R","QBLOC.GLO",1)
      elseif CONFIG->Modelo_2 == "7"
        qlbloc(5,0,"B201AC","QBLOC.GLO",1) //Clari Agua Mineral
      elseif CONFIG->Modelo_fat == "1"
        qlbloc(5,0,"B201AM","QBLOC.GLO",1) //Mantraco
      elseif CONFIG->Modelo_fat == "2"
        qlbloc(5,0,"B201P","QBLOC.GLO",1) //perfilizia
      else

        qlbloc(5,0,"B201A","QBLOC.GLO",1)
      endif

      qmensa(qabrev(cOPCAO,"IA",{"Inclus„o... <ESC - Cancelar>","Altera‡„o... <ESC - Cancelar>"}))
      i_edicao()

   endif

   setcursor(nCURSOR)

return ""

function i_kdla

local bTemDuplicata := {|| CONFIG->Modelo_Fat == "1" .and. left(FAT->Cod_cfop,3) $ "510-610-611-511-512-612" .and. !DUP_FAT->(dbseek(FAT->Codigo+"01")) }

   if eval(bTemDuplicata)
      qmensa(Fat->cod_cfop+"  "+Fat->Codigo,"BL")
   else
      qmensa("Deixa passar sair!","BL")
   endif


return


//////////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA _________________________________________

static function i_edicao

   local bESCAPE := {||empty(fDT_EMISSAO).or.(XNIVEL==2.and.!XFLAG).or.;
                       (XNIVEL==2 .and. lastkey()==27)}

   fDIA1 := fDIA2 := fDIA3 := fDIA4 := fDIA5 := fDIA6 := fDIA7 :=  0
   fVALOR1 := fVALOR2 := fVALOR3 := fVALOR4 := fVALOR5 := fVALOR6 := fVALOR7 := 0
   fTOTAL := 0
   nCOMISSAO:= 0
   fPARC  := 0
   aEdicao := {}

// MONTA DADOS NA TELA ___________________________________________________________

   if cOPCAO <> "I"

      XNIVEL := 1

      if CONFIG->Modelo_fat == "2"
         SAYPerfil()
      else
         sayaLL()
      endif

      if cOPCAO == "C"
        i_atu_lanc()
        keyboard chr(27)
      endif

   endif

   // CONSULTA OU EXCLUSAO _______________________________________________________

   //if cOPCAO == "C" ; i_consulta() ; return ; endif
   if cOPCAO == "E" ; i_exclusao() ; return ; endif

   // PREENCHE O VETOR DE EDICAO _________________________________________________

   if CONFIG->Modelo_fat == "2"
      getPerfil(aEdicao)
   else
      getALL(aEdicao)
   endif



   // INICIALIZACAO DA EDICAO ____________________________________________________

   do while .T.
      qgirabarra()

      FAT->(qpublicfields())

      iif(cOPCAO=="I", FAT->(qinitfields()), FAT->(qcopyfields()))

      if CONFIG->modelo_2 == "7" .and. cOPCAO == "I"
         fDT_EMISSAO := date()
         fDT_SAIDA   := date()
      else
         if cOPCAO == "I"
            fDATA_LANC   := date()
         endif
         if CONFIG->Modelo_2 != "7"
            fFILIAL := "0001"
         endif

      endif


      XNIVEL := 2
      XFLAG := .T.

      // LOOP PARA ENTRADA DOS CAMPOS ____________________________________________

      do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
         eval ( aEDICAO [XNIVEL,1] )
         if eval ( bESCAPE );FAT->(qreleasefields());return;endif
         if ! i_critica( aEDICAO[XNIVEL,2] ) ; loop ; endif
         iif ( XFLAG , XNIVEL++ , XNIVEL-- )
         qmensa("")
      enddo

      if ! lCONF ; return ; endif

      if NUM_PEDI->(qrlock())

         // AQUI INCREMENTA CODIGO DO PEDIDO DE VENDA ____________

         if cOPCAO == "I"
            replace NUM_PEDI->Pedido with NUM_PEDI->Pedido + 1
            qsay(6,17,fCODIGO := strzero(NUM_PEDI->Pedido,5) )
            qmensa("C¢digo Gerado: "+fCODIGO,"B")
         endif

      else
         iif(cOPCAO=="I",qm1(),qm2())
      endif

      if FAT->(iif(cOPCAO=="I",qappend(),qrlock()))

         // AGORA GRAVA E DESTRAVA ARQUIVO _____________________________________

         fFATURAR := .F.
         FAT->(qreplacefields())
         replace FAT->Cliente with fCLIENTE
      endif

      dbunlockall()

      i_proc_lanc()
      keyboard chr(27)

   enddo



return

/////////////////////////////////////////////////////////////////////////////////
// CRITICAS NA DESCIDA __________________________________________________________

static function i_critica ( cCAMPO )

   qmensa("")

   iif ( cCAMPO == NIL , cCAMPO := "" , NIL )
   if ! XFLAG ; return .T. ; endif

   do case

      case cCAMPO == "DT_EMISSAO"

           if empty(fDT_EMISSAO) ; return .F. ; endif

           if cOPCAO == "I"
              fUSER     := XUSRIDT
              fUSER_ALT := XUSRIDT
           endif

           if cOPCAO != "I"
              fUSER_ALT := XUSRIDT
           endif


           if CONFIG->Modelo_fat == "1"
              //qsay(08,08,left(fUSER,10))
              //qsay(08,29,left(fUSER_ALT,10))

              if cOPCAO == "I"
                 fC_CUSTO := "0005"
                 fFILIAL := "0001"
                 //fCOD_VENDED := "00001"
                 fDESC_SN := "N"
              endif
           endif

           if CONFIG->Modelo_fat == "2"
              if cOPCAO == "I"
                 fC_CUSTO := "0001"
                 fFILIAL := "0001"
                 //fCOD_VENDED := "00001"
                 fDESC_SN := "N"
                 fES := "S"
                 ftiposub := "010001"
              endif
           endif


           if CONFIG->Modelo_2 == "7"
              if cOPCAO == "I"
                 fC_CUSTO := "0004"
                 if ! empty(CONFIG->Filial)
                    fFILIAL := CONFIG->Filial
                 endif
                 fTIPOSUB := "010002"
                 fDESC_SN := "N"
              endif
           endif

           fES := "S"


      case cCAMPO == "COD_CLI"

           if empty(fCOD_CLI) ; return .F. ; endif

           qsay(7,24,fCOD_CLI:=strzero(val(fCOD_CLI),5))

           if ! CLI1->(dbseek(fCOD_CLI))
              qmensa("Cliente n„o encontrado !","B")
              return .F.
           endif

           if RESTRI->(dbseek(fCOD_CLI))
              qmensa("Cliente com Restricao, inclusao negada!","B")
              return .F.
           endif


           qsay(7,32,left(CLI1->Razao,40))

           //if cOPCAO == "I" ; fCOD_VENDED := CLI1->Cod_vend   ; endif
           if cOPCAO == "I" ; fCOD_REPRES := CLI1->Cod_repres ; endif
           if cOPCAO == "I" ; fCOD_TERRIT := CLI1->Cod_TERRIT ; endif
           fCLIENTE := CLI1->Razao
           if CONFIG->Modelo_2 == "1"
              fC_CUSTO := "0010"
              fFILIAL := "0001"
              fTIPOSUB := "010002"
              sDESC_SN := "N"
           endif

           if CONFIG->Modelo_fat == "1"
	          
			  if empty(CLI1->Cod_resp)
			     qmensa("nao existe Responsavel cadastrado para este Cliente","BL")
                 return .F.		
              endif
               
              fCOD_RESP := CLI1->Cod_resp 			   
		   
              if XFLAG
                 if ! empty(CLI1->Obs1)
                    alert(rtrim(CLI1->Obs1)+";"+rtrim(CLI1->Obs2)+";"+rtrim(CLI1->Obs3)+";"+rtrim(CLI1->Obs4)+";"+rtrim(CLI1->Obs5),{"OK"},"N/BG")
                 endif
              endif
           endif


      case cCAMPO == "COD_REPRES"
           if empty(fCOD_REPRES) ; return .F. ; endif
           qsay(8,51,fCOD_REPRES:=strzero(val(fCOD_REPRES),5))
           if ! REPRES->(dbseek(fCOD_REPRES))
              qmensa("Representante n„o encontrado !","B")
              return .F.
           endif
           qsay(8,57,left(REPRES->Razao,21))

      case cCAMPO == "COD_VENDED"
           if empty(fCOD_VENDED) ; return .F. ; endif

           if CONFIG->Modelo_fat != "8"
              qsay(8,17,fCOD_VENDED:=strzero(val(fCOD_VENDED),5))
           else
              qsay(8,24,fCOD_VENDED:=strzero(val(fCOD_VENDED),5))
           endif

           if ! VEND->(dbseek(fCOD_VENDED))
              qmensa("Vendedor n„o encontrado !","B")
              return .F.
           endif
           nCOMISSAO := VEND->Comis

           if CONFIG->Modelo_fat == "8"
              qsay(8,32,left(VEND->Nome,25))
           else
              qsay(8,25,left(VEND->Nome,16))
           endif
                
      case cCAMPO == "COD_DI"
           if empty(fCOD_DI) ; return .F. ; endif
           qsay(10,61,fCOD_DI)
           PROD->(dbsetorder(1))
           if ! PROD->(dbseek(fCOD_DI))
              qmensa("D/I n„o encontrada !","B")
              return .F.
           endif
           qsay(10,66,left(PROD->Descricao,12))

      case cCAMPO == "COD_IF"
           if empty(fCOD_IF) ; return .F. ; endif
           qsay(14,17,fCOD_IF:=strzero(val(fCOD_IF),4))
           if ! IDENT->(dbseek(fCOD_IF))
              qmensa("Identificacao Fiscal n„o encontrada !","B")
              return .F.
           endif
           qsay(14,17,left(IDENT->Nome,30))

      case cCAMPO == "FILIAL"
           if empty(fFILIAL) ; return .F. ; endif
           qsay(9,24,fFILIAL)
           if ! FILIAL->(dbseek(fFILIAL))
              qmensa("Filial n„o encontrado !","B")
              return .F.
           endif
           qsay(9,31,left(FILIAL->Razao,40))

      case cCAMPO == "C_CUSTO"
           if empty(fC_CUSTO) ; return .F. ; endif
           qsay(10,24,fC_CUSTO)
           CCUSTO->(dbsetorder(4))
           if ! CCUSTO->(dbseek(fC_CUSTO))
              qmensa("Centro de Custo n„o encontrado !","B")
              return .F.
           endif
           qsay(10,31,left(CCUSTO->Descricao,15))

      case cCAMPO == "COD_TRANSP"
           qsay(11,24,fCOD_TRANSP:=strzero(val(fCOD_TRANSP),5))
           if ! TRANSP->(dbseek(fCOD_TRANSP))
              qmensa("Transportadora n„o encontrada !")

           endif
           if fCOD_TRANSP == "00000"
              fCOD_TRANSP := "     "
           endif
           qsay(11,32,left(TRANSP->Razao,20))

           if CONFIG->Modelo_2 == "7"
              if cOPCAO == "I"
                 fTIPO_DOC := CLI1->Tipo_doc
                 qsay(11,61,fTIPO_DOC)
              end
           endif

      case cCAMPO == "TRANSP_PER"

           if ! empty(fCOD_TRANSP)
              qsay(09,24,fCOD_TRANSP:=strzero(val(fCOD_TRANSP),5))
              if ! TRANSP->(dbseek(fCOD_TRANSP))
                 qmensa("Transportadora n„o encontrada !")

              endif
              qsay(09,32,left(TRANSP->Razao,20))
           endif



      case cCAMPO == "TIPO_DOC"

           qsay(11,61,fTIPO_DOC:=strzero(val(fTIPO_DOC),2))
           if ! TIPO_DOC->(dbseek(fTIPO_DOC))
              qmensa("Tipo de Documento n„o encontrado !")
              return .F.
           endif
           qsay(11,66,left(TIPO_DOC->Descricao,11))
           
           if cOPCAO == "I"
              //fOBS := TIPO_DOC->Descricao
           endif

      case cCAMPO == "COD_CFOP"
           if empty(fCOD_CFOP) ; return .F. ; endif

           if left(fCOD_CFOP,1) $ "1-2-3"
              qmensa("Nao ‚ permitido Cfop de entrada!!","B")
              return .F.
           endif

           CGM->(Dbseek(CLI1->Cgm_ent))
           if CGM->Estado == "PR"
              if left(fCOD_CFOP,1) $ "6-7"
                 qmensa("Cliente Dentro do Estado. Verifique !","B")
                 return .F.
              endif
           else
              if left(fCOD_CFOP,1) == "5"
                 qmensa("Cliente Fora do Estado. Verifique !","B")
                 return .F.
              endif
           endif

           qsay(12,24,transform(fCOD_CFOP,"@R 9.999"))
           if ! CFOP->(dbseek(fCOD_CFOP))
              qmensa("Natureza de Opera‡„o n„o encontrada !","B")
              return .F.
           endif

           qsay(12,32,left(CFOP->Nat_Desc,40))
           if ! empty(CFOP->Tipo_cont) .and. TIPOCONT->(dbseek(CFOP->Tipo_cont))
              fTIPOSUB := TIPOCONT->Codigo
              qsay(13,21,fTIPOSUB)
              qsay(13,30,alltrim(TIPOCONT->Descricao))
           endif


      case cCAMPO == "CFOP1"
           if empty(fCOD_CFOP) ; return .F. ; endif

           if left(fCOD_CFOP,1) $ "1-2-3"
              qmensa("Nao ‚ permitido Cfop de entrada!!","B")
              return .F.
           endif

           CGM->(Dbseek(CLI1->Cgm_ent))
           if CGM->Estado == "PR"
              if left(fCOD_CFOP,1) $ "6-7"
                 qmensa("Cliente Dentro do Estado. Verifique !","B")
                 return .F.
              endif
           else
              if left(fCOD_CFOP,1) == "5"
                 qmensa("Cliente Fora do Estado. Verifique !","B")
                 return .F.
              endif
           endif

           qsay(12,10,transform(fCOD_CFOP,"@R 9.999"))
           if ! CFOP->(dbseek(fCOD_CFOP))
              qmensa("Natureza de Opera‡„o n„o encontrada !","B")
              return .F.
           endif

           qsay(12,18,left(CFOP->Nat_Desc,22))
           if ! empty(CFOP->Tipo_cont) .and. TIPOCONT->(dbseek(CFOP->Tipo_cont))
              fTIPOSUB := TIPOCONT->Codigo
              qsay(13,21,fTIPOSUB)
              qsay(13,30,alltrim(TIPOCONT->Descricao))
           endif



      case cCAMPO == "CFOP2"

           if left(fCFOP2,1) $ "1-2-3"
              qmensa("Nao ‚ permitido Cfop de entrada!!","B")
              return .F.
           endif

           CGM->(Dbseek(CLI1->Cgm_ent))
           if CGM->Estado == "PR"
              if left(fCFOP2,1) $ "6-7"
                 qmensa("Cliente Dentro do Estado. Verifique !","B")
                 return .F.
              endif
           else
              if left(fCFOP2,1) == "5"
                 qmensa("Cliente Fora do Estado. Verifique !","B")
                 return .F.
              endif
           endif

           if ! empty(fCFOP2)
              qsay(12,50,transform(fCFOP2,"@R 9.999"))
              if ! CFOP->(dbseek(fCFOP2))
                 qmensa("Natureza de Opera‡„o n„o encontrada !","B")
                 return .F.
              endif

              qsay(12,58,left(CFOP->Nat_Desc,20))
           endif


      case cCAMPO == "CFOP1_PER"
           if empty(fCOD_CFOP) ; return .F. ; endif

           if left(fCOD_CFOP,1) $ "1-2-3"
              qmensa("Nao ‚ permitido Cfop de entrada!!","B")
              return .F.
           endif

           CGM->(Dbseek(CLI1->Cgm_ent))
           if CGM->Estado == "PR"
              if left(fCOD_CFOP,1) $ "6-7"
                 qmensa("Cliente Dentro do Estado. Verifique !","B")
                 return .F.
              endif
           else
              if left(fCOD_CFOP,1) == "5"
                 qmensa("Cliente Fora do Estado. Verifique !","B")
                 return .F.
              endif
           endif

           qsay(10,24,transform(fCOD_CFOP,"@R 9.999"))
           if ! CFOP->(dbseek(fCOD_CFOP))
              qmensa("Natureza de Opera‡„o n„o encontrada !","B")
              return .F.
           endif

           qsay(10,32,left(CFOP->Nat_Desc,40))

      case cCAMPO == "CFOP2_PER"
           if empty(fCFOP2) ; return .F. ; endif

           if left(fCFOP2,1) $ "1-2-3"
              qmensa("Nao ‚ permitido Cfop de entrada!!","B")
              return .F.
           endif

           CGM->(Dbseek(CLI1->Cgm_ent))
           if CGM->Estado == "PR"
              if left(fCFOP2,1) $ "6-7"
                 qmensa("Cliente Dentro do Estado. Verifique !","B")
                 return .F.
              endif
           else
              if left(fCFOP2,1) == "5"
                 qmensa("Cliente Fora do Estado. Verifique !","B")
                 return .F.
              endif
           endif

           qsay(11,24,transform(fCFOP2,"@R 9.999"))
           if ! CFOP->(dbseek(fCFOP2))
              qmensa("Natureza de Opera‡„o n„o encontrada !","B")
              return .F.
           endif

           qsay(11,32,left(CFOP->Nat_Desc,40))


      case cCAMPO == "CONDIC"
           if empty(fCONDIC) ; return .F. ; endif
           qsay(13,24,fCONDIC)
           if ! COND->(dbseek(fCONDIC))
              qmensa("Condicao de Pagamento n„o encontrada !","B")
              return .F.
           endif
           qsay(13,29,COND->Descricao)

      case cCAMPO == "CFOP2"
           qsay(13,24,transform(fCFOP2,"@R 9.999"))
           if ! CFOP->(dbseek(fCFOP2))
              qmensa("Natureza de Opera‡„o n„o encontrada !","B")
              return .T.
              qmensa()
           endif
           qsay(13,32,left(CFOP->Nat_Desc,40))

      case cCAMPO == "TIPOSUB"
           if empty(fTIPOSUB) ; return .F. ; endif
           qsay(13,21,fTIPOSUB:=strzero(val(fTIPOSUB),6))
           if ! TIPOCONT->(dbseek(fTIPOSUB))
              qmensa("Tipo Contabil n„o encontrado !","B")
              return .F.
           endif

           if empty(fESTOQ_FORA)
              fESTOQ_FORA := "N"
           endif

          // if left(fCOD_CFOP,1) $ "1-2-3"
          //    fES := "E"
          // else
              fES := "S"
          // endif
           qsay(13,30,alltrim(TIPOCONT->Descricao))

      case cCAMPO == "DESC_SN"
           if empty(fDESC_SN) ; return .F. ; endif
           qsay(14,27,qabrev(fDESC_SN,"SN",{"Sim","N„o"}))

      case cCAMPO == "ES"
           if empty(fES) ; return .F. ; endif
           qsay(14,50,qabrev(fES,"SC",{"Saida","C.Icms"}))
      case cCAMPO == "FRETE"
           if empty(fFRETE) ; return .F. ; endif
           qsay(15,70,qabrev(fFRETE,"12", {"1 - Cif","2 - Fob"}))

      case cCAMPO == "FRETE_PER"
           if empty(fFRETE) ; return .F. ; endif
           qsay(12,70,qabrev(fFRETE,"12", {"1 - Cif","2 - Fob"}))


      case cCAMPO == "BOLETO"
           if empty(fBOLETO) ; return .F. ; endif
           qsay ( 09,24,  qabrev(fBoleto,"123456789", {"Boleto","Pgto a Vista - Boleto","Pgto a Vista - Deposito","Antecipado","Nulo","Plano Mkt","Abater Credito","Segurar Duplicata","a Prazo - Deposito"}))


      case cCAMPO == "CODIGO"
           if lALT
              fDATA_LANC := date()
           endif

      case cCAMPO == "ESTOQ_FORA"
           qsay ( 13,73,  qabrev(fEstoq_fora,"SN ", {"Sim","Nao","Nao"}))


   endcase

return .T.

//////////////////////////////////////////////////////////////////////////////////
// FUN€AO PARA EXCLUIR PEDIDO DE VENDA __________________________________________

static function i_exclusao

   if ! empty(FAT->NFe) .or. ! empty(FAT->Num_fatura)
      Qmensa("Pedido Faturado ! ExclusÆo Negada!!","B")
      return .f.
   endif

   if qconf("Confirma exclus„o deste Pedido de Venda ?")


      INVENT->(Dbclearfilter())
      /// rotina para voltar o estoque dos produtos digitados no Pedido Deletado !

      ITEN_FAT->(Dbgotop())
      ITEN_FAT->(Dbseek(FAT->Codigo))

      do while ! ITEN_FAT->(eof()) .and. ITEN_FAT->Num_fat == FAT->Codigo

         if CONFIG->Modelo_fat == "1"
            if ITEN_FAT->Marcado $ "P- "
               ITEN_FAT->(Dbskip())
               loop
            endif
         endif


         INVENT->(dbsetorder(1))

         i_entra_mantra(ITEN_FAT->Quantidade,ITEN_FAT->Local,ITEN_FAT->Terceiros)


         ITEN_FAT->(Dbskip())

      enddo

      if ITEN_FAT->(qflock()) .and. FAT->(qrlock())

         ITEN_FAT->(dbseek(FAT->Codigo))

         do while ! ITEN_FAT->(eof()) .and. ITEN_FAT->Num_fat == FAT->Codigo // itens do pedido (produtos)
            ITEN_FAT->(dbdelete())
            ITEN_FAT->(dbskip())
         enddo

         DUP_FAT->(dbseek(FAT->Codigo+"01"))

         do while ! DUP_FAT->(eof()) .and. DUP_FAT->(qrlock()) .and. left(DUP_FAT->Num_fat,5) == FAT->Codigo // 
            DUP_FAT->(dbdelete())
            DUP_FAT->(dbskip())
         enddo

         FAT->(dbdelete())
         FAT->(qunlock())
         ITEN_FAT->(qunlock())
         DUP_FAT->(qunlock())


      else
         qm3()
      endif
   endif

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DOS PRODUTOS _______________________________

function i_proc_lanc

// LOOP PRINCIPAL ___________________________________________________________

setcolor("W/B")

if cOPCAO == "A"
   fTOTAL := 0
   lALT := .T.
endif

PROD->(Dbsetorder(4))

if CONFIG->Modelo_fat == "1"
   ITEN_FAT->(qview({{"f201m1()/Cod."                                        ,0},;
                     {"f201mar()/Faturar"                                      ,0},;
                     {"f201a()/Descri‡„o"                                    ,0},;
                     {"f201m()/ref"                                          ,0},;
                     {"transform(Vl_unitar, '@E 999,999.99')/Vl.Unit."    ,0},;
                     {"transform(Quantidade,'@E 99999')/Quant."           ,0},;
                     {"f201b()/Un."                                          ,0},;
                     {"f201c()/Val. Total"                                   ,0}},;
                     "16002179S",;
                     {NIL,"f201d",NIL,NIL},;
                     {"ITEN_FAT->Num_fat == FAT->Codigo",{||f201top()},{||f201bot()}},;
                     "<I>nc./<A>lt./<C>on./<E>xc./<D>uplicatas/<R>everter P/ Pendencia",,{|| CONFIG->Modelo_Fat == "1" .and. left(FAT->Cod_cfop,3) $ "510-610-611-511-512-612-540-640-650-550" .and. ! DUP_FAT->(dbseek(FAT->Codigo+"01"))},"Pedido sem Duplicatas, Verifique!"))
elseIF CONFIG->Modelo_fat == "2"
   ITEN_FAT->(qview({{"Cod_prod/Cod."                                        ,2},;
                     {"f201a()/Descri‡„o"                                    ,0},;
                     {"transform(Vl_unitar, '@E 999,999.99')/Vl.Unit."    ,0},;
                     {"transform(Quantidade,'@E 99999.99')/Quant."           ,0},;
                     {"f201b()/Un."                                          ,0},;
                     {"transform(Vl_unitar, '@E 999,999.99')/Val. Total"                                   ,0}},;
                     "13002179S",;
                     {NIL,"f201d",NIL,NIL},;
                     {"ITEN_FAT->Num_fat == FAT->Codigo",{||f201top()},{||f201bot()}},;
                     "<I>nc./<A>lt./<C>on./<E>xc./<D>uplicatas/<O>bservacoes"))


ELSE
   ITEN_FAT->(qview({{"Cod_prod/Cod."                                        ,2},;
                     {"f201a()/Descri‡„o"                                    ,0},;
                     {"transform(Vl_unitar, '@E 999,999.9999')/Vl.Unit."     ,0},;
                     {"transform(Quantidade,'@E 999999.999')/Quant."           ,0},;
                     {"f201b()/Un."                                          ,0},;
                     {"f201c()/Val. Total"                                   ,0}},;
                     "16002179S",;
                     {NIL,"f201d",NIL,NIL},;
                     {"ITEN_FAT->Num_fat == FAT->Codigo",{||f201top()},{||f201bot()}},;
                     "<I>nc./<A>lt./<C>on./<E>xc./<D>uplicatas/<O>bservacoes"))
endif


verificarDuplicatas() //Se nao for venda, deleta duplicatas

return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IR PARA O INICIO DOS DADOS FILTRADOS _________________________

function f201top
   ITEN_FAT->(dbsetorder(1))
   ITEN_FAT->(dbseek(FAT->Codigo))
   i_totaliza_pedido()
   qsay(22,16,transform(fTOTAL,"@E 99,999,999.99"))
   qsay(22,45,transform(fPedido,"@E 99,999,999.99"))
   qsay(22,66,transform(fIpi_vlr,"@E 99,999,999.99"))

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IR PARA O FINAL DOS DADOS FILTRADOS __________________________

function f201bot
   ITEN_FAT->(dbsetorder(1))
   ITEN_FAT->(qseekn(FAT->Codigo))
   i_totaliza_pedido()
   qsay(22,16,transform(fTOTAL,"@E 99,999,999.99"))
   qsay(22,45,transform(fPedido,"@E 99,999,999.99"))
   qsay(22,66,transform(fIpi_vlr,"@E 99,999,999.99"))
return

/////////////////////////////////////////////////////////////////////////////
// RETORNA A DESCRICAO DO PRODUTO __________________________________________

function f201a

   local cDESCRICAO := space(30)
   PROD->(Dbsetorder(4))
   if ! empty(ITEN_FAT->Cod_prod)
      PROD->(dbseek(left(ITEN_FAT->Cod_prod,5)))
      cDESCRICAO := left(PROD->Descricao,30)
   endif
   i_totaliza_pedido()
   qsay(22,16,transform(fTOTAL,"@E 99,999,999.99"))
   qsay(22,45,transform(fPedido,"@E 99,999,999.99"))
   qsay(22,66,transform(fIpi_vlr,"@E 99,999,999.99"))

return cDESCRICAO


function f201mar
local cMAR := ""
local cDESCRICAO := ""

cMAR := ITEN_FAT->Marcado
   if cMAR == "*"
      cDESCRICAO := "BAIXADO"
   elseif cMAR $ "P"
      cDESCRICAO := "PENDENTE"
   elseif cMAR $ "Q"
      cDESCRICAO := "PARCIAL"
   elseif cMAR $ " "
      cDESCRICAO := "ABERTO"
   endif
return cDESCRICAO


function f201m
   local cFABR := space(4)

   PROD->(Dbsetorder(4))
   if ! empty(ITEN_FAT->Cod_prod)
      PROD->(dbseek(left(ITEN_FAT->Cod_prod,5)))
      cFABR := left(PROD->Cod_fabr,4)
   endif
   i_totaliza_pedido()
   qsay(22,16,transform(fTOTAL,"@E 99,999,999.99"))
   qsay(22,45,transform(fPedido,"@E 99,999,999.99"))
   qsay(22,66,transform(fIpi_vlr,"@E 99,999,999.99"))
   rtrim(cFABR)

return cFABR

function f201m1
   local cASS := space(7)

   PROD->(Dbsetorder(4))
   if ! empty(ITEN_FAT->Cod_prod)
      PROD->(dbseek(left(ITEN_FAT->Cod_prod,5)))
      cASS := left(PROD->Cod_ass,7)
   endif
   i_totaliza_pedido()
   qsay(22,16,transform(fTOTAL,"@E 99,999,999.99"))
   qsay(22,45,transform(fPedido,"@E 99,999,999.99"))
   qsay(22,66,transform(fIpi_vlr,"@E 99,999,999.99"))
   rtrim(cASS)

return cASS


/////////////////////////////////////////////////////////////////////////////
// RETORNA A UNIDADE DO PRODUTO _____________________________________________

function f201b
   PROD->(dbseek(left(ITEN_FAT->Cod_prod,5)))
   UNIDADE->(dbseek(PROD->Unidade))
   i_totaliza_pedido()
   qsay(22,16,transform(fTOTAL,"@E 99,999,999.99"))
   qsay(22,45,transform(fPedido,"@E 99,999,999.99"))
   qsay(22,66,transform(fIpi_vlr,"@E 99,999,999.99"))
return UNIDADE->Sigla

/////////////////////////////////////////////////////////////////////////////
// RETORNA O VALOR TOTAL DO PRODUTO _________________________________________

function f201c
local nRET
   i_totaliza_pedido()
   if CONFIG->Modelo_fat == "5"

      if ITEN_FAT->Tot_ped > 0
         nRET := transform(ITEN_FAT->Tot_ped,"@E 999,999.99")
      else
         nRET := transform(ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade,"@E 999,999.99")
      endif
   else
      nRET :=  transform(ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade,"@E 999,999.99")
   endif

   qsay(22,16,transform(fTOTAL,"@E 99,999,999.99"))
return nRET

function f201cl
   //INVENT->(DbSeek(FAT->Filial+right(PROD->Codigo,5)+"0000000000" ))

return INVENT->Quant_Atu


/////////////////////////////////////////////////////////////////////////////
// FUNCAO DE CONTROLE PRINCIPAL ANTES DE PROCESSAR A TECLA ACIONADA _________

function f201d

   local nCURSOR := setcursor(1)
   parameters cOPCAO

   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO $ XUSRA
      if CONFIG->Modelo_fat == "B"
         qlbloc(08,08,"B201BG","QBLOC.GLO",1)
     elseif CONFIG->Modelo_2 $ "9"
         qlbloc(08,08,"B201BK","QBLOC.GLO",1)
     elseif CONFIG->Modelo_fat == "1"
         qlbloc(05,05,"B201B1","QBLOC.GLO",1)
     else
         qlbloc(08,08,"B201B","QBLOC.GLO",1)
     endif


     //if cOPCAO == "A" .and. (! empty(FAT->NFe) .or. ! empty(FAT->Num_fatura))
     //   qmensa("Pedido Faturado, Proibida a Alteracao !","B")
     //   return .F.
     //endif

     if cOPCAO == "I" .and. (! empty(FAT->NFe) .or. ! empty(FAT->Num_fatura))
        qmensa("Pedido Faturado, Proibida a Inclusao !","B")
        return .F.
     endif



      i_processa_acao()
   endif

   if cOPCAO == "D"

      i_totaliza_pedido()

      if left(FAT->Cod_cfop,4) $ "5910-6910-5911-6911-5912-6912-5915-6915-5917-6917"
         qmensa("CFOP Invalido, Proibida a geracao de Faturas !","B")
         return .F.
      endif


      i_duplicata()

   endif

   if cOPCAO == "O"

      i_Observacao()

   endif


   if cOPCAO == "R" 

      if empty(FAT->NFe) .or. empty(FAT->Num_fatura)

         i_totaliza_pedido()

         i_Reversao()
      else
         qmensa("Pedido Faturado, Proibida a Reversao !","B")
         return .F.
      endif

   endif


   setcursor(nCURSOR)

return ""






/////////////////////////////////////////////////////////////////////////////
// FUNCAO DE BROWSE _________________________________________________________

static function i_processa_acao

   local lCONF
   local aEDICAO := {}
   local bESCAPE := {||empty(fCOD_PROD).or.(XNIVEL==1.and.!XFLAG).or.;
                       (XNIVEL==1.and.lastkey()==27).or.;
                       (XNIVEL==2.and.cOPCAO=="A".and.!XFLAG)}

   if lALT  // se alteracao - zera o totalizador e refaz a soma das parcelas
      fPARC := 0
   endif

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"

      XNIVEL := 1
      qrsay ( XNIVEL++ , ITEN_FAT->Cod_prod            , "@R 99999"                    ) ; PROD->(dbseek(left(ITEN_FAT->Cod_prod,5)))
      qrsay ( XNIVEL++ , left(PROD->Descricao,40)                                      )
      qrsay ( XNIVEL++ , ITEN_FAT->Num_lote                                            )
      qrsay ( XNIVEL++ , qabrev(ITEN_FAT->Prod_ser,"12", {"N„o","Sim"})                )

      qrsay ( XNIVEL++ , ITEN_FAT->Preco_vend, "@E 999,999.9999"                     )
      qrsay ( XNIVEL++ , ITEN_FAT->Desc_prod, "@E 99.99"     )
      qrsay ( XNIVEL++ , ITEN_FAT->Vlr_Desc , "@E 9999,999.99"                       )
      qrsay ( XNIVEL++ , ITEN_FAT->Ordem_comp , "@!"                                 )

      qrsay ( XNIVEL++ , ITEN_FAT->Vl_unitar, "@E 999,999.9999"                    )

      if CONFIG->Modelo_fat == "1"
         qrsay ( XNIVEL++ , ITEN_FAT->Quant_Ped                                       )
      endif

      qrsay ( XNIVEL++ , ITEN_FAT->Quantidade                                          )

      if CONFIG->Modelo_fat == "1"
         qrsay ( XNIVEL++ , ITEN_FAT->Quant_pen                                        )
      endif
      qrsay ( XNIVEL++ , transform(ITEN_FAT->Icms,"@E 99.99")                          )
      qrsay ( XNIVEL++ , transform(ITEN_FAT->Ipi, "@E 99.99")                              )

      if CONFIG->Modelo_Fat == "5"
         qrsay ( XNIVEL++ , ITEN_FAT->Tot_ped, "@E 9,999,999.99" )
      else
         qrsay ( XNIVEL++ , ITEN_FAT->Vl_unitar * ITEN_FAT->Quantidade, "@E 9,999,999.99" )
      endif

      qrsay ( XNIVEL++ , transform(ITEN_FAT->Comissao, "@E 99.99" )                    )

      if CONFIG->Modelo_fat == "1"
         qrsay ( XNIVEL++ , transform(ITEN_FAT->Comi_repre, "@E 99.99" )                    )
      endif

      if CONFIG->Modelo_fat != "B"
         qrsay ( XNIVEL++ , ITEN_FAT->Cod_sit          ,"@R 999"   );SIT_TRIB->(dbseek(ITEN_FAT->Cod_sit))
         qrsay ( XNIVEL++ , left(SIT_TRIB->Descricao,30)                                  )
         qrsay ( XNIVEL++ , ITEN_FAT->Classif                  )

         if CONFIG->Modelo_2 == "3"
            qrsay ( XNIVEL++ , ITEN_FAT->Num_nf                )
         endif
      endif

      if CONFIG->Modelo_fat == "1"
         if left(FAT->Cod_cfop,4) $ "5949-6949"
            qrsay ( XNIVEL++ , ITEN_FAT->Cod_motbai       ,"@R 99"   );MOTBAI->(dbseek(ITEN_FAT->Cod_motbai))
            qrsay ( XNIVEL++ , left(MOTBAI->Descricao,30)                                  )
         endif

      endif


   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "C" ; qwait()      ; return ; endif
   if cOPCAO == "E" ; i_exc_itens_fat() ; return ; endif

   // PREENCHE O VETOR DE EDICAO ____________________________________________

   aadd(aEDICAO,{{ || view_prod(-1,0,@fCOD_PROD                    ) } ,"COD_PROD"  })
   aadd(aEDICAO,{{ || NIL                                            } ,NIL         })
   aadd(aEDICAO,{{ || view_lote(-1,0,@fNUM_LOTE, "@r 9999999999"   ) } ,"NUM_LOTE"  })
   aadd(aEDICAO,{{ || NIL                                            } ,NIL         })
   aadd(aEDICAO,{{ || NIL                                            } ,"PRECO_VEND"})
   //aadd(aEDICAO,{{ || qgetx(-1,0,@fPRECO_VEND, "@e 999,999.9999")      } ,"PRECO_VEND" })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDESC_PROD , "99.99"          ) } ,"DESC_PROD" })

   if CONFIG->Modelo_fat == "1"
      aadd(aEDICAO,{{ || NIL                                          } ,"QUANT_PEN"})
      aadd(aEDICAO,{{ || qgetx(-1,0,@fORDEM_COMP, "@!")               } ,"ORDEM_COMP" })
   else
      aadd(aEDICAO,{{ || qgetx(-1,0,@fVLR_DESC, "@e 9999,999.99")      } ,"VLR_DESC" })
   endif

   aadd(aEDICAO,{{ || qgetx(-1,0,@fVL_UNITAR , "@e 999,999.9999") } ,"VL_UNITAR" })

   if CONFIG->Modelo_fat == "1"
      aadd(aEDICAO,{{ || qgetx(-1,0,@fQUANT_PED , "@E 999999.999"      ) } ,"QUANT_PED"})
   endif

   aadd(aEDICAO,{{ || qgetx(-1,0,@fQUANTIDADE , "@E 999999.999"      ) } ,"QUANTIDADE"})

   if CONFIG->Modelo_fat == "1"
      aadd(aEDICAO,{{ || NIL                                            } ,"QUANT_PEN"})
   endif

   aadd(aEDICAO,{{ || qgetx(-1,0,@fICMS, "99.99"                   ) } ,"ICMS"      })
   aadd(aEDICAO,{{ || NIL                                            } ,"IPI"       })

   if CONFIG->Modelo_fat == "5"
      aadd(aEDICAO,{{ || qgetx(-1,0,@fTOT_PED, "@E 9,999,999.99"     ) } ,"TOTPED"      })
   else
      aadd(aEDICAO,{{ || NIL                                            } ,"TOTAL"     })
   endif


   aadd(aEDICAO,{{ || qgetx(-1,0,@fCOMISSAO, "99.99"               ) } ,"COMISSAO"  })

   if CONFIG->Modelo_fat =="1"
      aadd(aEDICAO,{{ || qgetx(-1,0,@fCOMI_REPRE, "99.99"             ) } ,"COI_REPRE" })
   endif

   if CONFIG->Modelo_fat != "B"
      aadd(aEDICAO,{{ || view_sit(-1,0,@fCOD_SIT                      ) } ,"COD_SIT"  })
      aadd(aEDICAO,{{ || NIL                                            } ,NIL         })
      aadd(aEDICAO,{{ || qgetx(-1,0,@fCLASSIF, "@!"                   ) } ,"CLASSIF"  })
      if CONFIG->Modelo_2 == "3"
         aadd(aEDICAO,{{ || qgetx(-1,0,@fNUM_NF, "@999999"            ) } ,"NUM_NF"  })
      endif
   endif

   if CONFIG->Modelo_fat =="1"

      if left(FAT->Cod_cfop,4) $ "5949-6949"
         aadd(aEDICAO,{{ || view_motbai(-1,0,@fCOD_MOTBAI             ) } ,"COD_MOTBAI"  })
         aadd(aEDICAO,{{ || NIL                                            } ,NIL         })
      endif

   endif



   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO _______________________________________________

   ITEN_FAT->(qpublicfields())

   iif(cOPCAO=="I",ITEN_FAT->(qinitfields()),ITEN_FAT->(qcopyfields()))

   if cOPCAO == "A"
      XNIVEL := 3
   else
      XNIVEL := 1
   endif

   XFLAG  := .T.

   // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

   do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
      eval ( aEDICAO [XNIVEL,1] )
      if eval ( bESCAPE ) ; ITEN_FAT->(qreleasefields()) ; return ; endif
      if ! i_crit2( aEDICAO[XNIVEL,2] ) ; loop ; endif
      iif ( XFLAG , XNIVEL++ , XNIVEL-- )
   enddo

   if ! lCONF ; return ; endif

   // GRAVACAO ______________________________________________________________

   if FAT->(qrlock()) .and. ITEN_FAT->(iif(cOPCAO=="I",qappend(),qrlock()))

      if cOPCAO == "I"
         fNUM_FAT := fCODIGO
         fDATA    := fDT_EMISSAO
      endif

      fDATA    := fDT_EMISSAO
      INVENT->(Dbsetorder(1))

      if cOPCAO == "A" // volta o estoque anterior a alteracao, para baixar corretamente a quantidade
         i_entra_mantra(ITEN_FAT->Quantidade,ITEN_FAT->Local,ITEN_FAT->Terceiros)
      endif



      fTOTAL := fTOTAL + (ITEN_FAT->Vl_unitar*fQUANTIDADE)

      // rotina que baixa o produto do Estoque quando e' confirmado no pedido

      ITEN_FAT->(qreplacefields())
      ITEN_FAT->(qunlock())


      if ITEN_FAT->Marcado $ "*-Q" .or. (CONFIG->Modelo_fat != "1" .and. CONFIG->Estoque == "S")
         i_baixa_mantra(ITEN_FAT->Quantidade)
      endif

   else

      iif(cOPCAO=="I",qm1(),qm2())

   endif

return

/////////////////////////////////////////////////////////////////////////////
// CRITICAS NA DESCIDA ______________________________________________________

static function i_crit2 ( cCAMPO )
local nORDEM   := 0
local nREG     := 0
local cQUANT   := 0
local nVAL_UNI := 0
local fCOD_ASS  := ""

   qmensa("")

   iif ( cCAMPO == NIL , cCAMPO := "" , NIL )
   if ! XFLAG; return .t.; endif
   do case

      case cCAMPO == "COD_PROD"

           if CONFIG->Modelo_fat == "1"

              PROD->(dbsetorder(5))
              if PROD->(dbseek(fCOD_PROD))
                 fCOD_PROD := right(PROD->Codigo,5)
              else
                 PROD->(dbsetorder(3))
                 if PROD->(dbseek(fCOD_PROD))
                    fCOD_PROD := right(PROD->Codigo,5)
                 else
                    //qmensa("Produto nao encontrado","BL")
                    //return .F.
                 endif
              endif

              PROD->(dbsetorder(4))
              //if PROD->Preco_cust == 0
              //   qmensa("Produto sem Preco de Custo. Verifique!","BL")
              //   return .F.
              //endif

           endif


           INVENT->(dbClearFilter())
           qrsay(XNIVEL,fCOD_PROD:=strzero(val(fCOD_PROD),5))

           if CONFIG->Modelo_2 != "7" //Clari
              nORDEM := ITEN_FAT->(Indexord())
              nREG   := ITEN_FAT->(recno())

              if ITEN_FAT->(dbseek(FAT->Codigo+fCOD_PROD))
                 qmensa("Produto ja cadastrado, InclusÆo negada !","B")
                 return .F.
              endif

              ITEN_FAT->(Dbsetorder(nORDEM))
              ITEN_FAT->(Dbgoto(nREG))
              nREG := 0
              nORDEm := 0
           endif

           PROD->(Dbsetorder(4))

           if ! PROD->(dbseek(fCOD_PROD))
              qmensa("Produto n„o encontrado !","B")
              return .F.
           endif

           INVENT->(DbSetFilter({|| INVENT->Cod_prod == fCOD_PROD },'Cod_prod == fCOD_PROD '))

           if CONFIG->Modelo_fat == "1"
              qrsay ( XNIVEL+1 , left(PROD->Descricao,20)+"/"+PROD->Cod_ass+" - "+left(PROD->Cod_fabr,6) )
              fCOD_ASS :=  PROD->Cod_ass
           else
              qrsay ( XNIVEL+1 , left(PROD->Descricao,38) )
           endif
		   
		   
		   lExisteArea  := existeArea(CLI1->Cgm_ent)
		   lTemVinculo := iif(empty(CLI1->Cod_exc),.F.,.T.)
		 		
		   if lExisteArea .and. lTemVinculo
		         EXCLUSIV->(dbsetorder(4))
                 if EXCLUSIV->(dbseek(CLI1->Cgm_ent + CLI1->Cod_exc + fCOD_PROD))
				    if FAT->Cod_cli != EXCLUSIV->Cod_cli

				       AREA_EXC->(dbseek(CLI1->Cod_exc))
				       alert(alltrim(fCOD_ASS) +"; exclusivo de ;"+rtrim(EXCLUSIV->Cliente)+"; em "+rtrim(EXCLUSIV->Desc_cid)+"/"+EXCLUSIV->Uf+";"+left(AREA_EXC->Descricao,20))
					   if ! alltrim(fUSER_ALT) $ "DANIELA-BASSO"
				          qrsay(XNIVEL,fCOD_PROD := "")
				         return .F.
				       endif
		    	    endif 	 
				 endif	
		
		  else

              EXCLUSIV->(dbsetorder(3))

              if EXCLUSIV->(dbseek(CLI1->CGM_ENT + fCOD_PROD))
                 if FAT->Cod_cli != EXCLUSIV->Cod_cli
                    Alert(alltrim(fCOD_ASS) +"; exclusivo de ;"+rtrim(EXCLUSIV->Cliente)+"; em "+rtrim(EXCLUSIV->Desc_cid)+"/"+EXCLUSIV->Uf,{"OK"},"N/BG")
                    if ! alltrim(fUSER_ALT) $ "DANIELA-BASSO"
				       qrsay(XNIVEL,fCOD_PROD := "")
				       return .F.
				    endif	
                 endif
              endif
		   endif  
		   
		   qrsay ( XNIVEL+3 , qabrev(PROD->Prod_iss,"SN", {"Sim","N„o"}))

           fPROD_SER:=qabrev(PROD->Prod_iss,"SN", {"2","1"})

           if CONFIG->Modelo_fat == "9"
              fVL_UNITAR := PROD->Preco_unit
              fPRECO_VEND := PROD->Preco_unit

           else
              if left(FAT->Cod_cfop,3) $ "510-610-511-611-512-612-710-711-712-220-221-540-640-550-650"
                 if CONFIG->Modelo_2 $ "8*5"
                   fVL_UNITAR := PROD->Preco_cons - (PROD->Preco_Cons * (CLI1->Comis_repr/100 ))
                 else
                   fVL_UNITAR  := PROD->Preco_cons
                   fPRECO_VEND := PROD->Preco_cons
                   fDESC_PROD  := FAT->Aliq_desc
                 endif
              endif

              if left(FAT->Cod_Cfop,4) $ "5910-5911-5912-5917-6910-6911-6912-6917-5905-6905-5949-6949"
                 fPRECO_VEND:= PROD->Preco_cust
              endif

              fPRECO_CUST := PROD->Preco_cust
              qrsay(XNIVEL+4,fPRECO_VEND,"@E 999,999.9999")

           endif


           //////////////////////////////////////////////////////////////////////////
           // TABELA DE PRECOS POR CLIENTE __________________________________________

           if CONFIG->Modelo_2 == "7"

              CLI1->(dbseek(FAT->Cod_cli))
              CGM->(dbseek(CLI1->Cgm_ent))

              if IT_PROD->(dbseek(fCOD_PROD+CGM->Estado))
                 fBC_SUBST := IT_PROD->Pauta
              else
                 fBC_SUBST := 0
              endif

              CLI_PR->(dbsetorder(2))
              if CLI_PR->(dbseek(FAT->Cod_cli))

                 ITEN_GP->(Dbsetorder(2))
                 if ITEN_GP->(DbSeek(CLI_PR->Cod_grupo+right(PROD->Codigo,5)))
                    fPRECO_VEND := ITEN_GP->Valor
                 else
                    fPRECO_VEND := PROD->Preco_cons
                 endif
              else
                 fPRECO_VEND := PROD->Preco_cons
              endif
           endif


           fPONTOS := PROD->Pontos

           Return .T.

      case cCAMPO == "DESC_PROD"
           if FAT->Aliq_desc <> 0 .and. fDESC_PROD <> FAT->Aliq_desc
              Qmensa("Desconto no Produto diferente da Aliquota do Pedido!!!","B")
              return .F.
           endif
           if fDESC_PROD <> 0
              fVLR_DESC := round(fPRECO_VEND * (fDESC_PROD/100),2)
           endif
           fVL_UNITAR := round(fPRECO_VEND - fVLR_DESC,2)
           qrsay(XNIVEL+1,fVLR_DESC,"@E 9999,999.99")
           qrsay(XNIVEL+3,fVL_UNITAR,"@E 9,999,999.999")

      case cCAMPO == "VLR_DESC"
           fVL_UNITAR := round(fPRECO_VEND - fVLR_DESC,2)
           qrsay(XNIVEL+2,fVL_UNITAR,"@E 9,999,999.999")


      case cCAMPO == "QUANT_PED"

           if CONFIG->Modelo_2 != "7"
              if empty(fQUANT_PED) ; return .F. ; endif
           endif

           if CONFIG->Estoque == "S"

               INVENT->(dbsetorder(1))
               if ! INVENT->(dbseek(fFILIAL+fCOD_PROD+fNUM_LOTE))
                  if CONFIG->Modelo_fat == "1"
                     fMARCADO := "P"
                     fQUANT_PEN := fQUANT_PED
                     fQUANTIDADE := 0
                  else
                     qmensa("N„o Existe este Produto em Estoque - Verifique o Inventario ! ","B")
                     return .F.
                  endif
               endif

               qmensa("No estoque tem "+ transform(INVENT->Quant_atu+(INVENT->Quant_ter-INVENT->Quant_res),"@R 999999") + " Unidades. Pecas avariadas.: "+transform(INVENT->Quant_defe,"@R 999999"),"B")

               if (INVENT->Quant_atu+(INVENT->Quant_ter-INVENT->Quant_res)) == 0
                  if CONFIG->Modelo_fat == "1"
                     fMARCADO := "P"
                     fQUANT_PEN := fQUANT_PED
                     fQUANTIDADE := 0
                  else
                     qmensa("Estoque Insufuciente!","B")
                     return .F.
                  endif
               else
                  if ! left(FAT->Cod_Cfop,4) $ "5905-6905-6906-5906"
                     if (INVENT->Quant_atu+(INVENT->Quant_ter-INVENT->quant_res)) < fQUANT_PED
                        if CONFIG->Modelo_fat == "1"
                           fMARCADO := "Q"
                        else
                           qmensa("Estoque Insufuciente!","B")
                           return .F.
                        endif
                     else
                        if CONFIG->Modelo_fat == "1"
                           fMARCADO := "*"
                           fQUANTIDADE := fQUANT_PED
                        endif
                     endif
                 else
                     if (INVENT->Quant_atu) < fQUANT_PED
                        if CONFIG->Modelo_fat == "1"
                           fMARCADO := "Q"
                        else
                           qmensa("Estoque Insufuciente!","B")
                           return .F.
                        endif
                     else
                        if CONFIG->Modelo_fat == "1"
                           fMARCADO := "*"
                           fQUANTIDADE := fQUANT_PED
                        endif
                     endif
                 endif
               endif


               Return .T.
           endif

      case cCAMPO == "QUANTIDADE"

           //if CONFIG->Modelo_fat == "1" .and. FAT->Cod_cli $ "00616-00139"
              //fCOD_SIT   := "060"
           //else
              fCOD_SIT   := "100"
          // endif


           if CONFIG->Modelo_Fat != "1"
              if empty(fQUANTIDADE) ; return .F. ; endif
           endif


           IF CONFIG->Modelo_fat == "2"
              fTOT_PED :=  fVL_UNITAR
           ELSE
              fTOT_PED := fQUANTIDADE * fVL_UNITAR
           ENDIF
      
           if CONFIG->Estoque == "S"
              if CONFIG->Modelo_fat != "1"
                 INVENT->(dbsetorder(1))
                 if ! INVENT->(dbseek(fFILIAL+fCOD_PROD+fNUM_LOTE))
                    qmensa("N„o Existe este Produto em Estoque - Verifique o Inventario ! ","B")
                    return .F.
                 endif

                 if (INVENT->Quant_atu+INVENT->Quant_ter) <= 0
                    qmensa("Estoque Insufuciente!","B")
                    return .F.
                 else
                    if (INVENT->Quant_atu+INVENT->Quant_ter) < fQUANTIDADE
                       qmensa("Estoque Insufuciente!","B")
                       return .F.
                    endif
                 endif

                 qmensa("No estoque tem "+ transform(INVENT->Quant_atu+INVENT->Quant_ter,"@E 999,999.99") + " Unidades. Pecas avariadas.: "+transform(INVENT->Quant_defe,"@R 999999"),"B")

              else
                 INVENT->(dbsetorder(1))
                 if ! INVENT->(dbseek(fFILIAL+fCOD_PROD+fNUM_LOTE))
                    if fQUANTIDADE > 0
                       qmensa("Produto sem Inventario, Quantidade a Faturar deve ser ZERO !","B")
                       return .F.
                    endif
                 else
                    if (INVENT->Quant_atu+(INVENT->Quant_ter-INVENT->Quant_res)) <= 0
                       if fQUANTIDADE > 0
                          qmensa("Estoque Esgotado, Quantidade a Faturar deve ser ZERO !")
                          return .F.
                       endif
                    else
                       if left(FAT->cod_cfop,4) $ "5905-6905-6906-5906"
                          cQUANT := (INVENT->Quant_atu)
                       else
                          cQUANT := (INVENT->Quant_atu+(INVENT->Quant_ter-INVENT->Quant_res))
                       endif

                       if cQUANT < fQUANTIDADE
                          qmensa("Quantidade Insuficiente, Voce pode faturar ate "+transf(cQUANT,"@R 999999")+ " Unidades")
                          return .F.
                       else
                          if fQUANTIDADE > fQUANT_PED
                             return .F.
                          endif

                          qmensa("No estoque tem "+ transform(cQUANT,"@R 999999") + " Unidades","B")
                          fQUANT_PEN := fQUANT_PED - fQUANTIDADE
                          qrsay(XNIVEL+1,fQUANT_PEN,"@R 999999.999")

                          if fQUANTIDADE == 0
                             fMARCADO := "P"
                          Endif

                          if fQUANTIDADE > 0 .and. fQUANTIDADE < fQUANT_PED
                             fMARCADO := "Q"
                          endif

                          if fQUANTIDADE > 0 .and. fQUANTIDADE == fQUANT_PED
                             MARCADO  := "*"
                          endif
                       endif
                    endif
                 endif
                 qrsay(XNIVEL+1,fQUANT_PEN,"@R 999999.999")

              endif
               cQUANT := 0
               Return .T.
           endif


      case cCAMPO == "PRECO_VEND"

           //   CLI_PR->(dbsetorder(2))
           //   if CLI_PR->(dbseek(FAT->Cod_cli))
           //
           //      ITEN_GP->(Dbsetorder(2))
           //      if ITEN_GP->(DbSeek(CLI_PR->Cod_grupo+right(PROD->Codigo,5)))
           //         nVAL_UNI := ITEN_GP->Valor
           //      else
           //         nVAL_UNI := PROD->Preco_cons
           //      endif
           //   else
           //      nVAL_UNI := PROD->Preco_cons
           //  endif

           //   if fPRECO_VEND < nVAL_UNI
           //      qmensa("Valor abaixo do preco de Tabela. Verifique!","B")
           //      return .F.
           //   endif



      case cCAMPO == "VL_UNITAR"

           if CONFIG->Modelo_fat == "1"
              if empty(fVL_UNITAR) ; return .F. ; endif
           endif



           CGM->(Dbseek(CLI1->Cgm_ent))
           ESTADO->(Dbseek(CGM->Estado))
           fICMS := ESTADO->Aliq_dest
		   if cOPCAO == "I"
		      fIPI := PROD->Ipi
		   endif

           if ! empty(CLI1->Inscricao) .and. left(upper(CLI1->Inscricao),5) != "ISENT" .and. CONFIG->Modelo_fat == "1"
		       if left(FAT->Cod_cfop ,1) == "6"
			      fIcms := 4.00
		       endif
		   endif

           if CLi1->Isento == "N" //.and. CONFIG->Modelo_fat == "1"
              fICMS := 18
           endif

           fCOMISSAO := nCOMISSAO
           if CONFIG->Modelo_2 == "1"
              fCOMISSAO := 7
           endif
           fCALC_DESC := "N"
           fICMS_SUBST := "N"


           if cOPCAO == "I" .and. CONFIG->Modelo_fat == "1"
              fCOMI_REPRE := CLI1->Comis_repr
           endif


           Return .t.

      case cCAMPO == "IPI"
           if fICMS <> 0
			 qrsay ( XNIVEL , transform(fIPI, "@E 99.99") )
           endif

           IF CONFIG->MODELO_fat == "2"
              qrsay ( XNIVEL+1, transform(fVL_UNITAR,"@E 9,999,999.99"))
           ELSE
              qrsay ( XNIVEL+1, transform(fVL_UNITAR*fQUANTIDADE,"@E 9,999,999.99"))
           ENDIF
           Return .t.

      case cCAMPO == "CALC_DESC"
           qrsay(XNIVEL,qabrev(fCALC_DESC,"SN",{"Sim","N„o"}))
           Return .t.

      case cCAMPO == "ICMS_SUBST"
           qrsay(XNIVEL,qabrev(fICMS_SUBST,"SN",{"Sim","N„o"}))
           Return .t.

      case cCAMPO == "NUM_LOTE"
           if CONFIG->Estoque == "S"

              if empty(fNUM_LOTE)
                 fNUM_LOTE := "0000000000"
                 qrsay(XNIVEL,fNUM_LOTE)
              else
                 fNUM_LOTE := strzero(val(fNUM_LOTE),10)
                 qrsay(XNIVEL,fNUM_LOTE)
              endif

              INVENT->(Dbsetorder(1))
              if CONFIG->Modelo_fat != "1"
                 if ! INVENT->(dbseek(fFILIAL+fCOD_PROD+fNUM_LOTE))
                    qmensa("N£mero de Lote deste Produto nÆo encontrado...","B")
                    fLOTE := "          "
                    return .F.
                 endif
              endif

//              if INVENT->Quant_atu <= 0 .or. INVENT->Quant_atu < fQUANTIDADE
//                 qmensa("Estoque Insufisciente !","B")
//                 fLOTE := "          "
//                 return .F.
//              endif

           endif

      case cCAMPO == "PREP_COD"

           qrsay(XNIVEL,fPREP_COD:=strzero(val(fPREP_COD),5))

           if ! PREP->(dbseek(fPREP_COD))
              qmensa("Preposto n„o encontrado !","B")
              return .F.
           endif
           qrsay ( XNIVEL+1 , left(PREP->Descricao,40) )

      case cCAMPO == "COD_SIT"

           qrsay(XNIVEL,fCOD_SIT:=strzero(val(fCOD_SIT),3))

           if ! SIT_TRIB->(dbseek(fCOD_SIT))
              qmensa("Situacao Tributaria n„o encontrada !","B")
              return .F.
           endif
           qrsay ( XNIVEL+1 , left(SIT_TRIB->Descricao,30) )

     //      if CONFIG->Modelo_fat == "1" .and. FAT->Cod_cli $ "00616-00139"
     //         fCOD_SIT   := "060"
     //      else
     //         fCOD_SIT   := "000"
     //      endif
	 //dd



      case cCAMPO == "COD_MOTBAI"

           if empty(fCOD_MOTBAI)
              qmensa("Campo Obrigatorio pra CFOP 5.949 e 6.949!","BL")
              return .F.
           endif

           qrsay(XNIVEL,fCOD_MOTBAI:=strzero(val(fCOD_MOTBAI),2))

           if ! MOTBAI->(dbseek(fCOD_MOTBAI))
              qmensa("Motivo nao encontrado !","B")
              return .F.
           endif
           qrsay ( XNIVEL+1 , left(MOTBAI->Descricao,30) )


      case cCAMPO == "ICMS"

          // if CONFIG->Modelo_fat == "1"
          // if CLI1->Isento == "N"
          //    if fICMS <> 0 .and. fICMS <> 18
          //       qmensa("Aliquota de Icms Invalida!","B")
          //       return .f.

          //    endif

          // else
          //    CGM->(Dbseek(CLI1->Cgm_ent))
          //    ESTADO->(Dbseek(CGM->Estado))

          //    if fICMS <> 0 .and. fICMS <> ESTADO->Aliq_dest
          //       qmensa("Aliquota de Icms Invalida!","B")
          //       return .f.

          //    endif

          // endif
          // endif


   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXCLUIR ITENS DO PEDIDO  _____________________________________

static function i_exc_itens_fat
   if FAT->Cancelado
      Qmensa("Nota Fiscal Cancelada! ExclusÆo Negada!!","B")
      return .f.
   endif

   if ! empty(FAT->NFe) .or. ! empty(FAT->Num_fatura)
      Qmensa("Pedido Faturado! ExclusÆo Negada!!","B")
      return .f.
   endif


   if qconf("Confirma exclus„o do Produto ?")
      INVENT->(dbclearFilter())
      INVENT->(Dbsetorder(1))
      // rotina que volta a quantidade em estoque pois foi baixa no pedido

      i_entra_mantra(ITEN_FAT->Quantidade,ITEN_FAT->Local,ITEN_FAT->Terceiros)

      if ITEN_FAT->(qrlock())
         ITEN_FAT->(dbdelete())
         ITEN_FAT->(qunlock())
      else
         qm3()
      endif
   endif

return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA DEVOLUCAO de ITENS DO PEDIDO  _____________________________________


////////////////////////////////////////////////////////////////////////////////////
static function i_atu_lanc
if CONFIG->Modelo_fat == "1"
   ITEN_FAT->(qview({{"f201m1()/Cod."                                       ,0},;
                     {"f201mar()/Faturar"                                      ,0},;
                     {"f201a()/Descri‡„o"                                    ,0},;
                     {"f201m()/Ref."                                         ,0},;
                     {"transform(Vl_unitar, '@E 999,999.99')/Vl.Unit."    ,0},;
                     {"transform(Quantidade,'@E 99999.99')/Quant."           ,0},;
                     {"f201b()/Un."                                          ,0},;
                     {"f201c()/Val. Total"                                   ,0}},;
                     "16002179S",;
                     {NIL,NIL,NIL,NIL},;
                     {"ITEN_FAT->Num_fat == FAT->Codigo",{||f201top()},{||f201bot()}},;
                    "<ESC> para sair" ))
elseIF CONFIG->Modelo_fat ==  "2"
   ITEN_FAT->(qview({{"Cod_prod/Cod."                                       ,2},;
                     {"f201a()/Descri‡„o"                                    ,0},;
                     {"transform(Vl_unitar, '@E 999,999.99')/Vl.Unit."    ,0},;
                     {"transform(Quantidade,'@E 99999.99')/Quant."           ,0},;
                     {"f201b()/Un."                                          ,0},;
                     {"transform(Vl_unitar, '@E 999,999.99')/Val. Total"                                   ,0}},;
                     "13002179S",;
                     {NIL,NIL,NIL,NIL},;
                     {"ITEN_FAT->Num_fat == FAT->Codigo",{||f201top()},{||f201bot()}},;
                    "<ESC> para sair" ))

ELSE

   ITEN_FAT->(qview({{"Cod_prod/Cod."                                       ,2},;
                     {"f201a()/Descri‡„o"                                    ,0},;
                     {"transform(Vl_unitar, '@E 999,999.9999')/Vl.Unit."    ,0},;
                     {"transform(Quantidade,'@E 9999999')/Quant."           ,0},;
                     {"f201b()/Un."                                          ,0},;
                     {"f201c()/Val. Total"                                   ,0}},;
                     "16002179S",;
                     {NIL,NIL,NIL,NIL},;
                     {"ITEN_FAT->Num_fat == FAT->Codigo",{||f201top()},{||f201bot()}},;
                    "<ESC> para sair" ))

endif

return ""

////////////////////////////////////////////////////////////////////////////////////
static function i_duplicata

    local bESCAPE := {||lastkey()==27}
    local aEDICAO := {}
    local lCONF := .F.
    local nDIA   := ""
    local nVALOR := ""
    local nUMAPARC  :=  0
    local lAltdup   := .F.

    DUP_FAT->(Dbgotop())
    if DUP_FAT->(Dbseek(FAT->Codigo+"01"))
       lAltDup := .T.
    else
       lAltDup := .F.
    endif


    XFLAG  := .T.

    if lALTDup
       i_parcela()
    endif

    XNIVEL := 1


    qlbloc(8,2,"B201C","QBLOC.GLO",1)

    if lALTDup
       i_mostra_dupli()
    endif

    i_totaliza_pedido()

    if CONFIG->MODELO_FAT == "2"
       qsay(19,25,transform(fSERVICO,"@E 9,999,999.99"))
    ELSE
       qsay(19,25,transform(fTOTAL,"@E 9,999,999.99"))
    ENDIF

    aadd(aEDICAO,{{ || qgetx(-1,0,@fVEZES,"9"                      )} ,"VEZES"   })

    aadd(aEDICAO,{{ || qgetx(-1,0,@fDIA1,"999"                    )} ,"DIA1"   })
    aadd(aEDICAO,{{ || NIL },NIL }) // descricao
    aadd(aEDICAO,{{ || qgetx(-1,0,@fVALOR1,"@E 99,999,999.99"            )} ,"VALOR1"   })
    aadd(aEDICAO,{{ || qgetx(-1,0,@fDIA2,"999"                    )} ,"DIA2"   })
    aadd(aEDICAO,{{ || NIL },NIL }) // descricao
    aadd(aEDICAO,{{ || qgetx(-1,0,@fVALOR2,"@E 99,999,999.99"            )} ,"VALOR2"   })
    aadd(aEDICAO,{{ || qgetx(-1,0,@fDIA3,"999"                    )} ,"DIA3"   })
    aadd(aEDICAO,{{ || NIL },NIL }) // descricao
    aadd(aEDICAO,{{ || qgetx(-1,0,@fVALOR3,"@E 99,999,999.99"            )} ,"VALOR3"   })
    aadd(aEDICAO,{{ || qgetx(-1,0,@fDIA4,"999"                    )} ,"DIA4"   })
    aadd(aEDICAO,{{ || NIL },NIL }) // descricao
    aadd(aEDICAO,{{ || qgetx(-1,0,@fVALOR4,"@E 99,999,999.99"            )} ,"VALOR4"   })
    aadd(aEDICAO,{{ || qgetx(-1,0,@fDIA5,"999"                    )} ,"DIA5"   })
    aadd(aEDICAO,{{ || NIL },NIL }) // descricao
    aadd(aEDICAO,{{ || qgetx(-1,0,@fVALOR5,"99,999,999.99"            )} ,"VALOR5"   })
    aadd(aEDICAO,{{ || qgetx(-1,0,@fDIA6,"999"                    )} ,"DIA6"   })
    aadd(aEDICAO,{{ || NIL },NIL }) // descricao
    aadd(aEDICAO,{{ || qgetx(-1,0,@fVALOR6,"99,999,999.99"            )} ,"VALOR6"   })
    aadd(aEDICAO,{{ || qgetx(-1,0,@fDIA7,"999"                    )} ,"DIA7"   })
    aadd(aEDICAO,{{ || NIL },NIL }) // descricao
    aadd(aEDICAO,{{ || qgetx(-1,0,@fVALOR7,"99,999,999.99"            )} ,"VALOR7"   })



    aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

    // LOOP PARA ENTRADA DOS CAMPOS ____________________________________________

    do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
       eval ( aEDICAO [XNIVEL,1] )
       if eval ( bESCAPE );return;endif
       if ! i_crit_3( aEDICAO[XNIVEL,2] ) ; loop ; endif
       iif ( XFLAG , XNIVEL++ , XNIVEL-- )
       qmensa("")
    enddo

    if ! lCONF ; return ; endif

    if DUP_FAT->(qrlock())

       if lALTDup
          DUP_FAT->(Dbgotop())
          DUP_FAT->(Dbseek(FAT->Codigo+"01"))

          do while ! DUP_FAT->(eof()) .and. left(DUP_FAT->Num_fat,5) == FAT->Codigo .and. DUP_FAT->(qrlock())
             DUP_FAT->(Dbdelete())
             DUP_FAT->(Dbskip())
          enddo

       endif

       if empty(fDIA1) .and. DUP_FAT->(qappend())   // venda a vista

          replace DUP_FAT->Num_fat   with fCODIGO+"01"
          replace DUP_FAT->Data_venc with fDT_EMISSAO
          replace DUP_FAT->Valor     with fVALOR1
          replace DUP_FAT->Dias      with fDia1

           if FAT->(qrlock())
              replace FAT->Vezes with fVEZES
              FAT->(qunlock())
           endif

       else

          if FAT->(qrlock())
             replace FAT->Vezes with fVEZES
             FAT->(qunlock())
          endif


          for nCONT := 1 to 7

              nDIA   := "fDIA"+str(nCONT,1)
              nVALOR := "fVALOR"+str(nCONT,1)

              if ! empty(&nDIA) .and. DUP_FAT->(qappend())
                 replace DUP_FAT->Num_fat   with fCODIGO+strzero(nCONT,2)
                 replace DUP_FAT->Data_venc with (fDT_EMISSAO + &nDIA )
                 replace DUP_FAT->Valor     with &nVALOR
                 replace DUP_FAT->Dias      with &nDIA
              endif

          next

       endif

       DUP_FAT->(qunlock())
       fVALOR1 := fVALOR2 := fVALOR3 := fVALOR4 := fVALOR5 := fVALOR6 := fVALOR7 := fPARC := 0
       nVALOR1 := nVALOR2 := nVALOR3 := nVALOR4 := nVALOR5 := nVALOR6 := nVALOR7:= 0


    else
       qm1()
    endif

return ""

/////////////////////////////////////////////////////////////////////////////
// CRITICAS NA DESCIDA ______________________________________________________

static function i_crit_3 ( cCAMPO )
local nVLR_PARC := nCONT := 0
local cPARC := space(7)
local nDIA := 0
local nVALOR := 0
local nRESTO := 0
   qmensa("")

   do case
      case cCAMPO == "VEZES"

          for nCONT := 1 to 7
              nVALOR := "fVALOR"+str(nCONT,1)
              //nDIA   := "fDIA"+str(nCONT,1)
              &nVALOR := 0
          next

          i_totaliza_pedido()

          if CONFIG->Modelo_2 == "7"
             iif(CLI1->Dias > 0,fDIA1 := CLI1->Dias,)
             //fVEZES := 1
          endif
          IF CONFIG->MODELO_FAT == "2"
             nVLR_PARC := round(fSERVICO / fVEZES,2)
             nRESTO := fSERVICO - (nVLR_PARC*fVEZES)
             fTOTAL := Fservico
          ELSE
             nVLR_PARC := round(fTOTAL / fVEZES,2)
             nRESTO := fTOTAL - (nVLR_PARC*fVEZES)
          ENDIF

          for nCONT := 1 to fVEZES
              if  nCONT == 1
                  cPARC  := "fVALOR"+str(nCONT,1)
                  &cPARC := nVLR_PARC + nRESTO
              else
                  cPARC  := "fVALOR"+str(nCONT,1)
                  &cPARC := nVLR_PARC
              endif
          next


      case cCAMPO == "DIA1"
           if ! empty(fDIA1)
             qrsay(XNIVEL+1,dtoc(fDT_EMISSAO+fDIA1))
           else
             qrsay(XNIVEL+1,dtoc(fDT_EMISSAO))
           endif

      case cCAMPO == "DIA2"
           if ! empty(fDIA2)
             qrsay(XNIVEL+1,dtoc(fDT_EMISSAO+fDIA2))
           endif

      case cCAMPO == "DIA3"
           if ! empty(fDIA3)
             qrsay(XNIVEL+1,dtoc(fDT_EMISSAO+fDIA3))
           endif

      case cCAMPO == "DIA4"
           if ! empty(fDIA4)
             qrsay(XNIVEL+1,dtoc(fDT_EMISSAO+fDIA4))
           endif

      case cCAMPO == "DIA5"
           if ! empty(fDIA5)
             qrsay(XNIVEL+1,dtoc(fDT_EMISSAO+fDIA5))
           endif

      case cCAMPO == "DIA6"
           if ! empty(fDIA6)
             qrsay(XNIVEL+1,dtoc(fDT_EMISSAO+fDIA6))
           endif

      case cCAMPO == "DIA7"
           if ! empty(fDIA7)
             qrsay(XNIVEL+1,dtoc(fDT_EMISSAO+fDIA7))
           endif



      case cCAMPO == "VALOR1"
           if fVALOR1 == 0
              fVALOR1 := fTOTAL
           endif
           qrsay(XNIVEL,fVALOR1,"@E 99,999,999.99")
           fPARC :=  fVALOR1
           if fPARC < fTOTAL .and. fVALOR2 == 0
              fVALOR2 := fTOTAL - fPARC
           endif
           qsay(19,62,transform(fPARC,"@E 9,999,999.99"))

      case cCAMPO == "VALOR2"
           fPARC := fPARC + fVALOR2
           if fPARC < fTOTAL .and. fVALOR3 == 0
              fVALOR3 := fTOTAL - fPARC
           endif

           qsay(19,62,transform(fPARC,"@E 9,999,999.99"))
      case cCAMPO == "VALOR3"
           fPARC := fPARC + fVALOR3
           if fPARC < fTOTAL.and. fVALOR4 == 0
              fVALOR4 := fTOTAL - fPARC
           endif

           qsay(19,62,transform(fPARC,"@E 9,999,999.99"))
      case cCAMPO == "VALOR4"
           fPARC := fPARC + fVALOR4
           if fPARC < fTOTAL .and. fVALOR5 == 0
              fVALOR5 := fTOTAL - fPARC
           endif

           qsay(19,62,transform(fPARC,"@E 9,999,999.99"))

      case cCAMPO == "VALOR5"
           fPARC := fPARC + fVALOR5
           if fPARC < fTOTAL .and. fVALOR6 == 0
              fVALOR6 := fTOTAL - fPARC
           endif

           qsay(19,62,transform(fPARC,"@E 9,999,999.99"))

      case cCAMPO == "VALOR6"
           fPARC := fPARC + fVALOR6
           if fPARC < fTOTAL .and. fVALOR7 == 0
              fVALOR7 := fTOTAL - fPARC
           endif

           qsay(19,62,transform(fPARC,"@E 9,999,999.99"))


      case cCAMPO == "VALOR7"
           fPARC := fPARC + fVALOR7
           if fPARC <> fTOTAL
             qmensa("Valor nao esta batendo!!")
           endif

           qsay(19,62,transform(fPARC,"@E 9,999,999.99"))
         //  if fPARC - 0.01  > fTOTAL
         //     qmensa("Valor das Parcelas Superou o Valor dos Produtos!!","B")
         //     fPARC  := 0
         //     XNIVEL := 0
         //     return .T.
         //  endif

   endcase

return .T.

//////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ATUALIZAR AS PARCELAS DO PEDIDO _______________________________

function i_parcela

   if ! DUP_FAT->(Dbseek(FAT->Codigo+"01"))
       qmensa("Pedido n„o Possui Duplicatas !!","B")
       return .F.
   endif

   for nCONT := 1 to 7

       if ! DUP_FAT->(eof()) .and. left(DUP_FAT->Num_fat,5) == FAT->Codigo

          nDIA   := "fDIA"+str(nCONT,1)
          nVALOR := "fVALOR"+str(nCONT,1)

          if DUP_FAT->Dias == 0
             &nDIA   := DUP_FAT->Data_venc - FAT->DT_EMISSAO
          else
             &nDIA   := DUP_FAT->Dias
          endif

          &nVALOR := DUP_FAT->Valor
          DUP_FAT->(Dbskip())

       endif

   next

return

static function i_mostra_dupli
   local zNIVEL := XNIVEL

   Qrsay(zNIVEL++,FAT->Vezes)


   for nCONT := 1 to 7

       nDIA   := "fDIA"+str(nCONT,1)
       nVALOR := "fVALOR"+str(nCONT,1)

       if (&nDIA) > 0
          Qrsay(zNIVEL++,&nDIA,"999")
          Qrsay(zNIVEL++,iif(&nDIA > 0,dtoc(FAT->Dt_emissao + (&nDIA)),"") )
          Qrsay(zNIVEL++,&nValor,"@E 99,999,999.99")
       else
          Qrsay(zNIVEL++,&nDIA,"999")
          Qrsay(zNIVEL++,iif(&nValor > 0,dtoc(FAT->Dt_emissao + (&nDIA)),"") )
          Qrsay(zNIVEL++,&nValor,"@E 99,999,999.99")
       endif



   next

return


//////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA CANCELAR PEDIDO ______________________________________________

function i_cancela

    if FAT->Cancelado
       qmensa("Esta Nota Fiscal ja esta Cancelada!!!","B")
       return .F.
    endif

    if empty(FAT->Num_fatura)
       qmensa("Pedido Nao Faturado, impossivel Cancelar!!!","B")
       return .F.
    endif

    if qconf("Cofirma cancelamento de Nota Fiscal?")

       /// rotina para voltar o estoque dos produtos digitados no Pedido Cancelado!




       ITEN_FAT->(Dbgotop())
       ITEN_FAT->(Dbseek(FAT->Codigo))

       do while ! ITEN_FAT->(eof()) .and. ITEN_FAT->Num_fat == FAT->Codigo

          if CONFIG->Modelo_fat == "1"
             if ITEN_FAT->Marcado $ "P- "
                ITEN_FAT->(Dbskip())
                loop
             endif
          endif

          INVENT->(dbclearfilter())
          INVENT->(dbsetorder(1))

          i_entra_mantra(ITEN_FAT->Quantidade,ITEN_FAT->Local,ITEN_FAT->Terceiros)

          //if ! left(FAT->Cod_cfop,4) $ "5905-6905-6906-5906"
          //   i_menos_pontos(FAT->Cod_Repres,ITEN_FAT->Cod_prod,ITEN_FAT->Quantidade,ITEN_FAT->Vl_unitar)
          //endif

          ITEN_FAT->(Dbskip())

       enddo

       FAT->(qrlock())
       replace FAT->Cancelado with .T.
       replace FAT->Obs With "### NOTA FISCAL CANCELADA ###"
       FAT->(qunlock())

       if FAT->Contabil
          i_abre_lanc()
          LANC->(dbsetorder(12))
          if  LANC->(dbseek(FAT->Codigo))
              while ! LANC->(Eof()) .and. LANC->Cod_fat == FAT->Codigo

                 LANC->(qrlock())
                 LANC->(dbdelete())
                 LANC->(Qunlock())
                 LANC->(dbskip())
              enddo
          endif

          LANC->(dbclosearea())

          SELECT FAT
       endif

       if FAT->Fiscal
          i_abre_sai()
          SAI->(dbsetorder(11))
          if  SAI->(dbseek(FAT->Num_fatura))
              while ! SAI->(Eof()) .and. SAI->Num_nf == FAT->Num_fatura

                 if SAI->(qrlock())
                    replace SAI->Vlr_cont with 0
                    replace SAI->Icm_base with 0
                    replace SAI->Icm_aliq with 0
                    replace SAI->Icm_vlr  with 0
                    replace SAI->Icm_out  with 0
                    replace SAI->Icm_isen with 0
                    replace SAI->Icm_red  with 0
                    replace SAI->Ipi_base with 0
                    replace SAI->Ipi_vlr  with 0
                    replace SAI->Ipi_out  with 0
                    replace SAI->Ipi_isen with 0
                    replace SAI->Ipi_desc with 0
                    replace SAI->Obs      with "### NOTA FISCAL CANCELADA ###"

                    SAI->(Qunlock())
                 endif
                 SAI->(dbskip())
              enddo
          endif

          SAI->(dbclosearea())

          SELECT FAT
       endif

       if FAT->Interface
          i_abre_receber()
          RECEBER->(dbsetorder(11))
          if  RECEBER->(dbseek(FAT->Num_fatura))
              while ! RECEBER->(Eof()) .and. left(RECEBER->Fatura,6) == FAT->Num_fatura

                 if RECEBER->(qrlock())
                    RECEBER->(Dbdelete())
                    RECEBER->(Qunlock())
                 endif
                 RECEBER->(dbskip())
              enddo
          endif

          RECEBER->(dbclosearea())

          SELECT FAT
       endif





    endif
return

//////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IMPRIMIR PEDIDO ________________________________________________

static function i_imprime( cOrdem )

   local cTITULO
   local nTOT_PROD := nLIN := nTOT_BRU := nPROD := nICMS_SUBS := 0
   local nALIQ_ICMS := 0
   local nIPI := 0
   local nICMS := 0
   local nST   := 0
   local aItens := {}
   local nCOnt  := 1
   cTITULO := "LISTAGEM DO PEDIDO No."+CODIGO+"   Data Emissao: "+dtoc(FAT->Dt_emissao)

   PROD->(Dbsetorder(4))

   // INICIALIZA PROCESSO DE IMPRESSAO ______________________________________

   if ! qinitprn() ; return ; endif

   i_totaliza_pedido()

   if XPAGINA == 0 .or. prow() > 56
      qpageprn()
      @ prow()+1,00 say XCOND1
	  @ prow()+1,00 say ""
      qcabecprn(cTITULO,132)
      CLI1->(Dbseek(FAT->Cod_cli))
      REPRES->(Dbseek(FAT->Cod_repres))
      CGM->(Dbseek(CLI1->Cgm_ent))
      @ prow()+1,0 say "Cliente : "+CLI1->Codigo + " - " + left(CLI1->Razao,50) + "  Telefone: "+ CLI1->Fone1
      @ prow()+1,0 say "Fantasia: "+CLI1->Fantasia + " " + "Inscricao Estadual.: " + CLI1->Inscricao
      @ prow()+1,0 say "CNPJ....: "+fu_conv_cgccpf(CLI1->Cgccpf)
      @ prow()+1,0 say "Endereco: "+padr(rtrim(CLI1->End_ent)+iif(!empty(CLI1->Numero),", "+CLI1->Numero," ")+rtrim(CLI1->Compl),45) + " - " + left(CGM->Municipio,15) + " UF: "+CGM->Estado
      @ prow()+1,0 say "Bairro  : " + CLI1->Bairro_ent      +"                               CEP.: "+padr(transform(CLI1->Cep_ent,"@R 99.999-999"),11)
      @ prow()+1,0 say "Representante: "+ REPRES->Razao
      CFOP->(Dbseek(FAT->Cod_cfop))
      @ prow()+1,0 say "Nat. de Operacao: " + FAT->Cod_cfop + " - " + left(CFOP->Nat_desc,30)
	  TRANSP->(dbseek(FAT->Cod_transp))
      @ prow()+1,0 say "Frete...: " + iif(FAT->Frete == "0","Sem frete",iif(FAT->Frete == "1","Cif","Fob")) + "Transportadora.: " + rtrim(TRANSP->Razao) + " Tel.: "+TRANSP->fone1
      ROTA->(dbseek(CLI1->Cod_rota))
      if CONFIG->Modelo_2 == "7"
         @ prow()  ,45 say "Rota.: " + left(ROTA->Descricao,26)
      endif

      @ prow()+1,0 say "Incluiu...: "+FAT->User +"   Ultima Alteracao.: "+FAT->User_alt+ "  Voltagem.: "+CLI1->Voltagem
      @ prow()+1,0 say "Observacao: "+left(FAT->Obs,70)
      if FAT->Frete == "1" .and. fTotal < 1000
         @ prow()+1,0 say " *** Pedido inferior a R$ 1000,00. Consultar a possibilidade de aumento do pedido com o cliente."
      endif

      @ prow()+1,0 say replicate("-",132)
   endif

   @ prow()+1,0 say "Codigo                    Qtde         Produto                       Unitario             Total      Local.  Local.2    Obs.   "

   //@ prow()+1,0 say "Codigo             Qtde   Produto               Unitario       Total  Local.   Local.2"
   @ prow()+1,0 say ""

   ITEN_FAT->(Dbseek(FAT->Codigo))

   do while ! ITEN_FAT->(eof()) .and. ITEN_FAT->Num_fat == FAT->Codigo

      PROD->(dbsetorder(4))
      PROD->(dbseek(ITEN_FAT->Cod_prod))

      aadd(aItens,{ITEN_FAT->Cod_prod,ITEN_FAT->Num_fat,PROD->Corredor + PROD->Estante + PROD->Prateleira,PROD->Corredor2 + PROD->Estante2 + PROD->Prateleir2,PROD->cod_fabr})

      ITEN_FAT->(Dbskip())

   enddo
   
   
   if cOrdem == "1"
      aItens := asort(aItens,,,{|x,y| x[3] < y[3]})
   else
      aItens := asort(aItens,,,{|x,y| x[5] < y[5]})
   endif   

   for nCONT:= 1 to len(aItens) //do while ! ITEN_FAT->(eof()) .and. ITEN_FAT->Num_fat == FAT->Codigo

      PROD->(Dbseek(aItens[nCont,1]))
      ITEN_FAT->(dbgotop())
      ITEN_FAT->(dbseek(aItens[nCONT,2]+aItens[nCONT,1]))
      if XPAGINA == 0 .or. prow() > 56
         qpageprn()
         qcabecprn(cTITULO,132)
         CLI1->(Dbseek(FAT->Cod_cli))
         REPRES->(Dbseek(FAT->Cod_repres))
         CGM->(Dbseek(CLI1->Cgm_ent))
         @ prow()+1,0 say "Cliente : "+CLI1->Codigo + " - " + left(CLI1->Razao,50) + "  Telefone: "+ CLI1->Fone1
         @ prow()+1,0 say "Fantasia: "+CLI1->Fantasia + " " + "Inscricao Estadual.: " + CLI1->Inscricao
         @ prow()+1,0 say "CNPJ....: "+fu_conv_cgccpf(CLI1->Cgccpf)
         @ prow()+1,0 say "Endereco: "+left(CLI1->End_ent,32) + " - " + left(CGM->Municipio,15) + " UF: "+CGM->Estado
         @ prow()+1,0 say "Bairro  : " + CLI1->Bairro_ent      +"                               CEP.: "+padr(transform(CLI1->Cep_ent,"@R 99.999-999"),11)
         @ prow()+1,0 say "Representante: "+ REPRES->Razao
         CFOP->(Dbseek(FAT->Cod_cfop))
         @ prow()+1,0 say "Nat. de Operacao: " + FAT->Cod_cfop + " - " + left(CFOP->Nat_desc,30)
         @ prow()+1,0 say "Frete...: " + iif(FAT->Frete == "0","Sem frete",iif(FAT->Frete == "1","Cif","Fob"))
         ROTA->(dbseek(CLI1->Cod_rota))
         if CONFIG->Modelo_2 == "7"
            @ prow()  ,45 say "Rota.: " + left(ROTA->Descricao,26)
         endif

         @ prow()+1,0 say "Incluiu...: "+FAT->User +"   Ultima Alteracao.: "+FAT->User_alt+ "  Voltagem.: "+CLI1->Voltagem
         @ prow()+1,0 say "Observacao: "+left(FAT->Obs,70)
         @ prow()+1,0 say replicate("-",132)
         @ prow()+1,0 say "Codigo                    Qtde         Produto                       Unitario             Total      Local.  Local.2    Obs.   "
         @ prow()+1,0 say ""

      endif


      @ prow()+1,0  say left(PROD->Cod_fabr,6)+iif(left(PROD->Cod_fabr,7)==PROD->Cod_ass,"","/"+PROD->Cod_ass)

      @ prow()  ,21  say transform(ITEN_FAT->Quantidade, "@E 999999.99")
      @ prow()  ,39  say left(PROD->Descricao,18)

      if ! empty(PROD->Desconto) .and. ITEN_FAT->Calc_desc == "S"
         nDESC := PROD->Desconto/100
      else
         nDESC := 1
      endif

      @ prow()  ,67 say transform(round(ITEN_FAT->Vl_unitar,2), "@E 999,999.9999")
      @ prow()  ,85 say transform(ITEN_FAT->Quantidade * round(ITEN_FAT->Vl_unitar,2), "@E 999,999.99")
      @ prow()  ,100 say " "+PROD->Corredor +" "+ PROD->Estante +" "+ PROD->Prateleira
      @ prow()  ,110 say " "+PROD->Corredor2 +" "+ PROD->Estante2 +" "+ PROD->Prateleir2
      @ prow()  ,120 say iif(PROD->Inspecao == "S","Inspecionar"," ")


      nTOT_PROD  := nTOT_PROD +  (ITEN_FAT->Quantidade * round(ITEN_FAT->Vl_unitar,2))
      nALIQ_ICMS := ITEN_FAT->Icms

      nIPI  +=  ( ( ITEN_FAT->Quantidade * ITEN_FAT->Vl_unitar ) * ( ITEN_FAT->Ipi / 100 ) )
      nICMS += ( ( ITEN_FAT->Quantidade * ITEN_FAT->Vl_unitar  ) * (ITEN_FAT->Icms/100) )


      if ITEN_FAT->ICMS_SUBST == "S" // soma somente os produtos com icms subst. tributaria nos itens do pedido
         nICMS_SUBS := nICMS_SUBS +  (ITEN_FAT->Quantidade * round(ITEN_FAT->Vl_unitar * nDESC,2))
      endif

      nLIN++
      //ITEN_FAT->(Dbskip())

   next

   DUP_FAT->(Dbsetorder(1))
   DUP_FAT->(Dbgotop())
   
   nST := calculaTotalSubst()

   @ prow()+1,0 say replicate("-",132)

   if DUP_FAT->(Dbseek(FAT->Codigo+"01"))
      do while ! DUP_FAT->(eof()) .and. left(DUP_FAT->Num_fat,5) == FAT->Codigo
         if DUP_FAT->Valor = 0
            exit
         endif
         @ prow()+1,00 say "Fatura No.: " + left(DUP_FAT->Num_fat,5)+"/"+Right(DUP_FAT->Num_fat,2)
         if DUP_FAT->Dias == 0
            @ prow()  ,22 say "Vencimento: " + dtoc(DUP_FAT->Data_venc)
         else
            @ prow()  ,22 say "Vencimento: " + dtoc(FAT->Dt_emissao+DUP_FAT->Dias)
         endif

         @ prow()  ,62 say "Valor : "+ alltrim(transform(DUP_FAT->Valor , "@E 999,999,999.99"))
         DUP_FAT->(Dbskip())
      enddo
   endif
  
   @ prow()+1,0 say replicate("-",132)

   @ prow()+1,92 say " Valor dos Produtos      >"+transform(nTOT_PROD, "@E 99,999,999.99")
   @ prow()+1,92 say " Valor do  IPI           >"+transform(nIPI,  "@E 99,999,999.99")
   @ prow()+1,92 say " Valor do  ICMS          >"+transform(nICMS, "@E 99,999,999.99")
   @ prow()+1,92 say " Valor da  Subst. Trib.  >"+transform(nST, "@E 99,999,999.99")

   @ prow()+1,92 say " Valor do Pedido         >"+transform( nTOT_PROD+nIPI+nST , "@E 99,999,999.99")
   @ prow()+1,0 say replicate("-",132)

   if CONFIG->Modelo_fat == "1"

      nResto := prow()
      for nCONT = 53 to nResto step -1
          @prow()+1,0 say ""
      next

      @ prow()+1,00 say "Coleta...: Inicio ___:___  Fim ___:___  Responsavel __________________________"
      @ prow()+2,00 say "Expedicao: Inicio ___:___  Fim ___:___  Responsavel __________________________"

   endif


   select FAT
   
   qstopprn(.F.)

return


/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA TOTALIZAR VARIAVEIS DO PEDIDO ________________________________

static function i_totaliza_pedido

   local nREC   := ITEN_FAT->(recno())
   local nINDEX := ITEN_FAT->(indexord())
   nITENS := 0
   nICMS_PROPRIO  := 0
   nICMS_ST       := 0
   nICMS          := 0
   nTOT_PED := 0
   fTOTAL   := 0
   fSERVICO := 0
   fPEDIDO := 0
   fIPI_VLR := 0
   fST_VLR := 0
   nTOT_PROD := 0
   nTOT_IPI  := 0
   nDESC := 0
   nTOT_DESC := 0
   
   ITEN_FAT->(dbsetorder(2))
   ITEN_FAT->(dbgotop())
   ITEN_FAT->(dbseek(FAT->Codigo))

   do while ! ITEN_FAT->(eof()) .and. ITEN_FAT->Num_fat == FAT->Codigo
      PROD->(dbsetorder(4))
      PROD->(dbseek(ITEN_FAT->Cod_prod))

         if ITEN_FAT->Marcado $ "*-Q"
            if ITEN_FAT->Icms <> 0
               nTOT_IPI := nTOT_IPI + ( ( (ITEN_FAT->Quantidade*ITEN_FAT->Vl_unitar) * ITEN_FAT->Ipi) / 100)
            endif
            fTOTAL    := fTOTAL + (ITEN_FAT->Quantidade*ITEN_FAT->Vl_unitar)
            fPEDIDO   := fPEDIDO + (ITEN_FAT->Quantidade*ITEN_FAT->Vl_unitar)

         endif
      
      nITENS++
      ITEN_FAT->(Dbskip())


   enddo
   
   fTOTAL := fTOTAL + nTOT_IPI

   fTOTAL  := round(fTOTAL,2)
   fPEDIDO := round(fPEDIDO,2)
   fIPI_VLR    := round(nTOT_IPI,2)
   //fST_VLR     := round(calculaTotalSubst(),2)

   ITEN_FAT->(dbsetorder(nINDEX))
   ITEN_FAT->(dbgoto(nREC))

return

///////////////////////////////////////////////////////////////////////
// FUNCAO PARA INCLUIR DADOS ADICIONAIS PARA SOMAR NA NOTA FISCAL _____
function i_adicionais
   setcolor("B/W")

   ADICIONA->(qview({{"Codigo/Codigo"                            ,0},;
                     {"Descricao/Descricao"                     , 0}},;
                     "12012377S",;
                     {NIL,"f201i",NIL,NIL},;
                     {"ADICIONA->Cod_fat == FAT->Codigo",{||f2011top()},{||f2011bot()}},;
                     "<I>nc./<A>lt./<C>on./<E>xc/<ESC> para sair"))
   return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IR PARA O INICIO DOS DADOS FILTRADOS _________________________
function f2011top
   ADICIONA->(dbsetorder(1))
   ADICIONA->(dbseek(FAT->Codigo))
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA IR PARA O FINAL DOS DADOS FILTRADOS __________________________
function f2011bot
   ADICIONA->(dbsetorder(1))
   ADICIONA->(qseekn(FAT->Codigo))
return

/////////////////////////////////////////////////////////////////////////////
// FUNCAO DE CONTROLE PRINCIPAL ANTES DE PROCESSAR A TECLA ACIONADA _________

function f201i

   local nCURSOR := setcursor(1)
   parameters cOPCAO

   cOPCAO := upper(chr(cOPCAO))

   if cOPCAO $ XUSRA
      qlbloc(10,10,"B201G","QBLOC.GLO",1)
      i_proc_acao()
   endif

   setcursor(nCURSOR)

return ""

///////////////////////////////////////////////////////////////////////////////
// lancamento dos adicionais _________________________________________________

function i_proc_acao

   local lCONF
   local aEDICAO := {}
   local bESCAPE := {|| lastkey()==27 }

// MONTA DADOS NA TELA ___________________________________________________________

   if cOPCAO <> "I"

      XNIVEL := 1

      qrsay ( XNIVEL++ , ADICIONA->Codigo                                  )
      qrsay ( XNIVEL++ , ADICIONA->Descricao                               )

   endif

   // CONSULTA OU EXCLUSAO _______________________________________________________

   if cOPCAO == "C" ; qwait() ; return ; endif
   if cOPCAO == "E" ; i_exc_adic() ; return ; endif

   // PREENCHE O VETOR DE EDICAO _________________________________________________

   aadd(aEDICAO,{{ || qgetx(-1,0,@fCODIGO,"99999"                     )} ,"CODIGO"         })
   aadd(aEDICAO,{{ || qgetx(-1,0,@fDESCRICAO, "@!"                    )} ,"DESCRICAO"     })
   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

   // INICIALIZACAO DA EDICAO ____________________________________________________

   do while .T.

      qgirabarra()

      ADICIONA->(qpublicfields())

      iif(cOPCAO=="I", ADICIONA->(qinitfields()), ADICIONA->(qcopyfields()))

      XNIVEL := 1
      XFLAG := .T.

      // LOOP PARA ENTRADA DOS CAMPOS __________________________________________

      do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
         eval ( aEDICAO [XNIVEL,1] )
         if eval ( bESCAPE );ADICIONA->(qreleasefields());return;endif
         if ! i_crit( aEDICAO[XNIVEL,2] ) ; loop ; endif
         iif ( XFLAG , XNIVEL++ , XNIVEL-- )
         qmensa("")
      enddo

      if ! lCONF ; return ; endif

      fCOD_FAT := FAT->Codigo

      if ADICIONA->(iif(cOPCAO=="I",qappend(),qrlock()))

         // AGORA GRAVA E DESTRAVA ARQUIVO _____________________________________

         ADICIONA->(qreplacefields())

      endif

      dbunlockall()

      keyboard chr(27)

   enddo

return

/////////////////////////////////////////////////////////////////////////////////
// CRITICAS NA DESCIDA __________________________________________________________

static function i_crit ( cCAMPO )

   qmensa("")

   iif ( cCAMPO == NIL , cCAMPO := "" , NIL )
   if ! XFLAG ; return .T. ; endif

   do case
   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA EXCLUIR ADICINAIS ____________________________________________

static function i_exc_adic

   if qconf("Confirma exclus„o do lan‡amento ?")

      if ADICIONA->(qrlock())
         ADICIONA->(dbdelete())
         ADICIONA->(qunlock())
      else
         qm3()
      endif
   endif

return

static function i_dup_fat(cCODFAT)

  if ! qconf("Confirma Duplicacao deste Pedido ?")

     return
  endif
  FAT->(qrlock())
  FAT->(qpublicfields())
  FAT->(qcopyfields())

  if ! FAT->(qappend())
    qmensa("N„o foi possivel duplicar, tente novamente...","B")
  else

    if NUM_PEDI->(qrlock())
       replace NUM_PEDI->Pedido with NUM_PEDI->Pedido + 1
       NUM_PEDI->(qunlock())
    endif

    fCODIGO := strzero(NUM_PEDI->Pedido,5)
    qmensa("C¢digo Gerado: "+fCODIGO,"B")

    fNUM_FATURA := "      "
    fNUM_REF    := "      "
    fES := "S"
    fCONSERTO  := .F.
    fCANCELADO := .F.
    fFECHADO   := .F.


    FAT->(qreplacefields())
    FAT->(qreleasefields())


    if ITEN_FAT->(dbseek(cCODFAT))
       do while ! ITEN_FAT->(eof()) .and. ITEN_FAT->Num_fat == cCODFAT
          ITEN_FAT->(qrlock())
          ITEN_FAT->(qpublicfields())
          ITEN_FAT->(qcopyfields())
          nREC := ITEN_FAT->(recno())
          ITEN_FAT->(qappend())
          fNUM_FAT := strzero(NUM_PEDI->pedido,5)
          fMARCADO := " "

          ITEN_FAT->(qreplacefields())
          ITEN_FAT->(dbgoto(nREC))
          ITEN_FAT->(dbskip())
          ITEN_FAT->(qreleasefields())
          ITEN_FAT->(qunlock())
       enddo
    endif
  endif


  FAT->(qunlock())

return

return .F.

Static function i_marcar
   if ITEN_FAT->(Qrlock())
      if ITEN_FAT->Marcado == "*"
         replace ITEN_FAT->Marcado with " "
      else
         INVENT->(dbsetorder(4))
         if INVENT->(Dbseek(ITEN_FAT->Cod_prod))
            if INVENT->Quant_atu >= ITEN_FAT->Quantidade
               replace ITEN_FAT->Marcado with "*"
            else
               qmensa("Nao ‚ poss¡vel marcar este produto, Estoque insufuciente!","B")
            endif

         endif
      endif
      ITEN_FAT->(Qunlock())

   endif
 return

static function i_gera_pendencias
local cCODIGO := space(5)
   PEND->(QPublicFields())
   PEND->(QinitFields())

   FAT->(QPublicFields())
   FAT->(QcopyFields())
   //fPEDIDO := fCODIGO

   if CONFIG->(Qrlock())
      replace CONFIG->Cod_pend with CONFIG->Cod_pend + 1
      fCODIGO := strzero(CONFIG->Cod_pend,5)
      cCODIGO := fCODIGO
      CONFIG->(Qunlock())
   endif

   PEND->(Qappend())
   PEND->(qreplaceFields())
   PEND->(QreleaseFields())
   FAT->(QreleaseFields())

   ITEN_FAT->(Dbgotop())
   if ITEN_FAT->(Dbseek(FAT->Codigo))
      Do While ! ITEN_FAT->(Eof()) .and. ITEN_FAT->Num_fat ==  FAT->Codigo

         if ITEN_FAT->Marcado == "*"
            ITEN_FAT->(DbSkip())
            Loop
         endif

         ITEM_PEN->(QPublicFields())
         ITEM_PEN->(QcopyFields())

         fCOD_PEND := cCODIGO

         ITEN_FAT->(QPublicFields())
         ITEN_FAT->(QCopyFields())

         fQUANTIDADE := fQUANT_PEN
         fQUANT_PED  := fQUANT_PEN
         fQUANT_PEN  := 0
         fFECHADO    := .F.


         if ITEM_PEN->(Qappend())
            ITEM_PEN->(QreplaceFields())
            ITEN_FAT->(QreleaseFields())
         endif

         ITEN_FAT->(dbskip())
      enddo
   endif

   ITEN_FAT->(Dbgotop())
   if ITEN_FAT->(Dbseek(FAT->Codigo))
      Do While ! ITEN_FAT->(Eof()) .and. ITEN_FAT->Num_fat ==  FAT->Codigo

         if ITEN_FAT->Marcado == "P"
            if ITEN_FAT->(Qrlock())
               ITEN_FAT->(DbDelete())
            endif
            ITEN_FAT->(Qunlock())
         endif

         ITEN_FAT->(dbskip())
      enddo
   endif

return

static function i_verifica_Pen
local lTem := .F.
   ITEN_FAT->(Dbsetorder(1))
   ITEN_FAT->(Dbgotop())
   if ITEN_FAT->(Dbseek(FAT->Codigo))
      Do While ! ITEN_FAT->(Eof()) .and. ITEN_FAT->Num_fat ==  FAT->Codigo

         if ITEN_FAT->Marcado $ "P-Q"
            lTEM := .T.
         endif

         ITEN_FAT->(dbskip())
      enddo
   endif
return lTEM

static function i_baixa_estoque

   ITEN_FAT->(Dbgotop())
   if ITEN_FAT->(Dbseek(FAT->Codigo))
      Do While ! ITEN_FAT->(Eof()) .and. ITEN_FAT->Num_fat ==  FAT->Codigo
         if ITEN_FAT->Marcado == " "
            INVENT->(dbsetorder(1))
            if ! INVENT->(dbseek(FAT->FILIAL+ITEN_FAT->COD_PROD+ITEN_FAT->NUM_LOTE))
               if fQUANTIDADE > 0
                  if ITEN_FAT->(Qrlock())
                     replace ITEN_FAT->Marcado with "P"
                     ITEN_FAT->(Qunlock())
                  endif
               endif
            else
               if INVENT->Quant_atu <= 0
                  if ITEN_FAT->(Qrlock())
                     replace ITEN_FAT->Marcado with "P"
                     ITEN_FAT->(Qunlock())
                  endif
               else
                  if INVENT->Quant_atu < ITEN_FAT->Quantidade
                     if ITEN_FAT->(Qrlock())
                        replace ITEN_FAT->Marcado    with "P"
                        replace ITEN_FAT->Quant_pen  with ITEN_FAT->Quant_ped
                        ITEN_FAT->(Qunlock())
                     endif
                  else
                     if ITEN_FAT->(Qrlock())
                        replace ITEN_FAT->Marcado    with "*"
                        replace ITEN_FAT->Quant_Pen  with  0
                        ITEN_FAT->(Qunlock())
                     endif

                     if INVENT->(Qrlock())
                        if left(FAT->Cod_cfop,4) $ "5905-6905-6906-5906"
                           replace INVENT->Quant_ter with (INVENT->Quant_ter + ITEN_FAT->Quantidade)
                        else
                           replace INVENT->Quant_atu with (INVENT->Quant_atu - ITEN_FAT->Quantidade)
                        endif

                        //i_mais_pontos(FAT->Cod_Repres,ITEN_FAT->Cod_prod,ITEN_FAT->Quantidade,ITEN_FAT->Vl_unitar)
                        INVENT->(qunlock())
                     endif
                  endif
               endif
            endif
         endif

         ITEN_FAT->(dbskip())
      enddo
   endif
return

static function i_Fecha
 if QConf("Confirma Fechamento deste Pedido?")

    if FAT->Fechado
       qmensa("Pedido Ja foi Fechado !","BL")
       return .F.
    endif

    i_totaliza_pedido()
    if fPEDIDO >= 1000

       CLI1->(dbseek(FAT->Cod_Cli))
       if FAT->Cod_transp != CLI1->Cod_transp .and. !empty(FAT->Cod_transp) .and. FAT->Cod_transp != "00000" .and. !empty(CLI1->Cod_transp)
          qmensa("Transportadora Invalida !","BL")
          if qconf("Deseja Corrigir automaticamente?")
             i_Transp()
          else
             return .F.
          endif
       endif

       if FAT->Frete != "1"
          qmensa("Frete Invalido! Acima de R$ 1000,00 somente Frete CIF!","BL")
          if qconf("Deseja Corrigir automaticamente?")
             i_Frete()
          else
             return .F.
          endif
       endif

    endif

    //if i_ver_estoque_ter() == .F.
    //   qmensa("Ha Produtos com Estoque em Terceiros, Verifique!","B")
    //   return .F.
    //endif


    if FAT->(qrlock())
       if i_verifica_pen()
          i_gera_pendencias()
       endif
       replace FAT->Fechado with .T.
       FAT->(Qunlock())
    endif

    //i_bx_est_ter()

  endif
return


/*static function i_mais_pontos(cCOD_REPRES,cCOD_PROD,nQUANT,nPRECO)
local nREG   := 0
local nINDEX := 0
local nPONTOS := 0

nREG   := PROD->(Recno())
nINDEX := PROD->(IndexOrd())

MILHAS->(Dbsetorder(2))

PROD->(Dbsetorder(4))

if PROD->(dbseek(cCOD_PROD))
   nPONTOS := PROD->Pontos
else
   nPONTOS := 0
endif

if left(FAT->Cod_cfop,3) $ "510-610-511-611-540-640-550-650"
   if MILHAS->(Dbseek(cCOD_REPRES))
      if MILHAS->(Qrlock()) .and. FAT->Dt_emissao >= MILHAS->Data_ini
         replace MILHAS->Pontos with MILHAS->Pontos + ( (nPRECO * nQUANT) * nPONTOS )
      endif
   endif
endif

PROD->(dbgoto(nREG))
PROD->(dbsetorder(nINDEX))

return

static function i_menos_pontos(cCOD_REPRES,cCOD_PROD,nQUANT,nPRECO)
local nREG   := 0
local nINDEX := 0
local nPONTOS := 0

nREG   := PROD->(Recno())
nINDEX := PROD->(IndexOrd())

MILHAS->(Dbsetorder(2))

PROD->(Dbsetorder(4))

if PROD->(dbseek(cCOD_PROD))
   nPONTOS := PROD->Pontos
else
   nPONTOS := 0
endif


if left(FAT->Cod_cfop,3) $ "510-610-511-611-540-640-550-650"
   if MILHAS->(Dbseek(cCOD_REPRES))
      if MILHAS->(Qrlock()) .and. FAT->Dt_emissao >= MILHAS->Data_ini
         replace MILHAS->Pontos with MILHAS->Pontos - ( (nPRECO * nQUANT) * nPONTOS )
      endif
   endif
endif

PROD->(dbgoto(nREG))
PROD->(dbsetorder(nINDEX))

return
*/


static procedure i_avista
   if qconf("Confirma Geracao de Duplicatas ? ")
      i_Totaliza_pedido()

      if ! DUP_FAT->(dbseek(FAT->Codigo+"01"))
         if DUP_FAT->(Qappend())
            replace DUP_FAT->Num_fat   with FAT->Codigo+"01"
            CLI1->(dbseek(FAT->Cod_cli))
            replace DUP_FAT->Data_venc with FAT->Dt_emissao + CLI1->Dias
            replace DUP_FAT->Valor     with fTOTAL

            if FAT->(qrlock())
               replace FAT->Vezes with 1
               FAT->(qunlock())
            endif
            DUP_FAT->(dbcommit())
         endif
      else
         if DUP_FAT->(qrlock())
            replace DUP_FAT->Num_fat   with FAT->Codigo+"01"
            CLI1->(dbseek(FAT->Cod_cli))

            replace DUP_FAT->Data_venc with FAT->Dt_emissao + CLI1->Dias
            replace DUP_FAT->Valor     with fTOTAL

            if FAT->(qrlock())
               replace FAT->Vezes with 1
               FAT->(qunlock())
            endif

            DUP_FAT->(qunlock())
         endif
      endif
    endif
return

static function i_reversao

   if ! QCONF("Confirma Reversao do Item p/ Pendencia?","B")
      return .F.
   endif


   if FAT->Cancelado
      Qmensa("Nota Fiscal Cancelada! ExclusÆo Negada!!","B")
      return .f.
   endif

   if ! empty(FAT->NFe) .or. ! empty(FAT->Num_fatura)
      Qmensa("Pedido Faturado! Reversao Negada!!","B")
      return .f.
   endif

      INVENT->(dbclearFilter())
      INVENT->(Dbsetorder(1))
      // rotina que volta a quantidade em estoque pois foi baixada no pedido

      i_entra_mantra(ITEN_FAT->Quantidade,ITEN_FAT->Local,ITEN_FAT->Terceiros)

      if ! PEND->(dbseek(ITEN_FAT->Pend_cod))
         FAT->(qpublicFields())
         FAT->(QCopyFields())
         if CONFIG->(qrlock())
            replace CONFIG->Cod_pend with CONFIG->Cod_Pend + 1
            CONFIG->(Qunlock())
         endif
         fCODIGO := strzero(CONFIG->Cod_pend,5)
         cCOD_PEND := fCODIGO
         fOBS := ""

         if PEND->(QAppend()) .and. PEND->(Qrlock())
            PEND->(qreplaceFields())
            PEND->(QreleaseFields())
            PEND->(Qunlock())
         else
            PEND->(QreleaseFields())
         endif

      else
         cCOD_PEND := ITEN_FAT->Pend_cod
      endif

      if ITEM_PEN->(dbseek(cCOD_PEND+ITEN_FAT->Cod_prod))
         if ITEM_PEN->(qrlock())
            replace ITEM_PEN->Quantidade with (ITEM_PEN->Quantidade + ITEN_FAT->Quantidade)
            ITEM_PEN->(qunlock())
         endif
      else
         if ITEM_PEN->(Qappend()) .and. ITEM_PEN->(qrlock())
            ITEN_FAT->(qpublicFields())
            ITEN_FAT->(qcopyFields())
            fCOD_PEND := cCOD_PEND
            fLOCAL := 0
            fTErceiros := 0
            ITEM_PEN->(qreplaceFields())
            ITEN_FAT->(qreleaseFields())
            ITEM_PEN->(qunlock())
         endif
      endif


      if ITEN_FAT->(qrlock())
         ITEN_FAT->(dbdelete())
         ITEN_FAT->(qunlock())
      else
         qm3()
      endif


return

static function i_abre_lanc()
local labriu := .F.

   if ! quse(XDRV_CT,"LANC",{"LA_DATA","LA_DBDAT","LA_CRDAT","LA_NLANC","LA_LOLAN","LA_CEDBD","LA_CECRD","LA_DTFIL","LA_FICTD","LA_FICTC","LA_DTNUM","LANC_FAT","LANC_DOC"})
      Qmensa("Nao foi possivel abrir arquivo LANC.DBF !","B")
      lAbriu := .F.
   else
      lAbriu := .T.
   endif
return lAbriu


static function i_abre_sai()
local labriu := .F.

   if ! quse(XDRV_EF,"SAI",{"SAI_NUM","SAI_LANC","SAI_FISC","SAI_VEND","SAI_FIS2","SAI_CONT","SAI_NFFI","SAI_CFOP","SAI_CFP2","SAI_EMISS","NUMNFTX"})
      Qmensa("Nao foi possivel abrir arquivo SAI.DBF !","B")
      lAbriu := .F.
   else
      lAbriu := .T.
   endif
return lAbriu


static function i_abre_receber()
local labriu := .F.

   if ! quse(XDRV_RB,"RECEBER",{"REC_COD","REC_VENC","REC_DUP","REC_DTEM","REC_CLIE","REC_LOTE","REC_BANC","REC_CLRZ","REC_CDCL","RB_DTVCL","REC_FATU","RECCLIVC"})
      Qmensa("Nao foi possivel abrir arquivo RECEBER.DBF !","B")
      lAbriu := .F.
   else
      lAbriu := .T.
   endif
return lAbriu

static function i_bx_est_ter
      ITEN_FAT->(dbsetorder(1))
      ITEN_FAT->(dbgotop())
      ITEN_FAT->(dbseek(FAT->Codigo))

      While ! ITEN_FAT->(eof()) .and. ITEN_FAT->Num_fat == FAT->Codigo
        if INVENT->(dbseek(FAT->Filial+ITEN_FAT->Cod_prod+ITEN_FAT->Num_lote))
           if ITEN_FAT->Terceiros > 0

              if ITEN_FAT->Terceiros <= INVENT->Quant_atu
                 if INVENT->(qrlock())
                    replace INVENT->quant_atu with INVENT->Quant_atu - ITEN_FAT->Terceiros
                    replace INVENT->quant_res with INVENT->Quant_res - ITEN_FAT->Terceiros
                    INVENT->(qunlock())
                 endif

                 if ITEN_FAT->(Qrlock())
                    replace ITEN_FAT->Local     with ITEN_FAT->Local + ITEN_FAT->Terceiros
                    replace ITEN_FAT->Terceiros with 0
                    ITEN_FAT->(qunlock())
                 endif

              endif
           endif
        endif

        ITEN_FAT->(Dbskip())
      enddo

return

static function i_ver_estoque_ter
local lBool := .T.
   INVENT->(dbsetorder(1))

   ITEN_FAT->(dbsetorder(1))
   ITEN_FAT->(dbgotop())
   ITEN_FAT->(dbseek(FAT->Codigo))

   While ! ITEN_FAT->(eof()) .and. ITEN_FAT->Num_fat == FAT->Codigo

     if INVENT->(dbseek(FAT->Filial+ITEN_FAT->Cod_prod+ITEN_FAT->Num_lote))
        if ITEN_FAT->Terceiros > 0

           if ITEN_FAT->Terceiros > INVENT->Quant_atu
              lBool := .F.
           endif
        endif
     endif

     ITEN_FAT->(Dbskip())
   enddo


return lBool




static function i_imp_resumo
local nQUANT_TER,nQUANT_ATU,nQTD_TT := 0
if empty(FAT->Num_fatura)

   @ prow()+1,00 Say "Resumo de Itens.:"
   @ prow()  ,58 Say "Mantra"
   @ prow()  ,70 Say "Terceiros"
   ITEN_FAT->(dbseek(FAT->Codigo))
   While ! ITEN_FAT->(Eof()) .and. ITEN_FAT->Num_fat == FAT->Codigo

      PROD->(Dbseek(ITEN_FAT->Cod_prod))
      if ITEN_FAT->Terceiros > 0
         @ prow()+1,0  say left(PROD->Cod_fabr,6)
         @ prow()  ,16 say left(PROD->Descricao,18)
         @ prow()  ,36 say PROD->cOD_aSS
         @ prow()  ,46 say left(PROD->Marca,10)

         @ prow()  ,58 say transform(ITEN_FAT->Local,"@R 99999")
         @ prow()  ,70 say transform(ITEN_FAT->Terceiros,"@R 99999")
      endif

      nQUANT_ATU := 0
      nQUANT_TER := 0

      ITEN_FAT->(dbskip())
   enddo
endif
return

static function i_baixa_mantra(nQTY) //Executa estoques...
local nMANTRA := 0
local nIGI    := 0
local nTT     := 0


       if INVENT->(dbseek(FAT->Filial+ITEN_FAT->Cod_prod+ITEN_FAT->Num_lote))
          if nQTY <= INVENT->Quant_atu
             if INVENT->(qrlock())
                replace INVENT->Quant_atu with INVENT->Quant_atu - nQTY
                INVENT->(Qunlock())
                nMANTRA := nQTY
                if ITEN_FAT->(Qrlock())
                   replace ITEN_FAT->Local with nMANTRA
                   ITEN_FAT->(Qunlock())
                endif
             endif
          else
             if nQTY <= (INVENT->Quant_atu+(INVENT->Quant_ter-INVENT->Quant_res))
                nMANTRA := iif(INVENT->Quant_atu < 0,0,INVENT->Quant_atu)
                nIGI    := (nQTY - nMANTRA)
                if (nIGI + nMANTRA) == nQTY
                   if INVENT->(qrlock())
                      replace INVENT->Quant_atu with INVENT->Quant_atu - nMANTRA
                      //replace INVENT->Quant_ter with INVENT->Quant_ter - nIGI
                      replace INVENT->Quant_res with INVENT->Quant_res + nIGI
                      INVENT->(Qunlock())
                   endif
                endif

                if ITEN_FAT->(Qrlock())
                   replace ITEN_FAT->Local     with nMANTRA
                   replace ITEN_FAT->Terceiros with nIGI
                   ITEN_FAT->(Qunlock())
                endif
              else
                qmensa("Saldo Insuficiente! ","B")
             endif
          endif

        else
           qmensa("Lote nao encontrado nesta Filial !","B")
           return .F.
       endif

return

static function i_entra_mantra(nQTY,nLOCAL,nTERCEIROS) //Executa estoques...
local nMANTRA := 0
local nIGI    := 0
local nTT     := 0

      if INVENT->(dbseek(FAT->Filial+ITEN_FAT->Cod_prod+ITEN_FAT->Num_lote))

         if INVENT->(Qrlock())

            replace INVENT->Quant_atu with INVENT->Quant_atu + nQTY
            INVENT->(Qunlock())
         endif

       else
          qmensa("Lote nao encontrado nesta Filial !","B")
          return .F.
      endif

return

static function i_Descancela
    if ! FAT->Cancelado
       qmensa("Esta Nota Fiscal nao esta Cancelada!!!","B")
       return .F.
    endif

    if empty(FAT->Num_fatura)
       qmensa("Pedido Nao Faturado, impossivel DesCancelar!!!","B")
       return .F.
    endif

    if qconf("Cofirma reversao de cancelamento de Nota Fiscal?")

       /// rotina para voltar o estoque dos produtos digitados no Pedido Cancelado!




       ITEN_FAT->(Dbgotop())
       ITEN_FAT->(Dbseek(FAT->Codigo))

       do while ! ITEN_FAT->(eof()) .and. ITEN_FAT->Num_fat == FAT->Codigo

          if CONFIG->Modelo_fat == "1"
             if ITEN_FAT->Marcado $ "P- "
                ITEN_FAT->(Dbskip())
                loop
             endif
          endif

          INVENT->(dbclearfilter())
          INVENT->(dbsetorder(1))

          i_baixa_mantra(ITEN_FAT->Quantidade)

          //i_mais_pontos(FAT->Cod_Repres,ITEN_FAT->Cod_prod,ITEN_FAT->Quantidade,ITEN_FAT->Vl_unitar)

          ITEN_FAT->(Dbskip())

       enddo

       FAT->(qrlock())
       replace FAT->Cancelado with .F.
       replace FAT->Obs With " "
       FAT->(qunlock())


    endif
return


static function i_Observacao

    local bESCAPE := {||lastkey()==27}
    local aEDICAO := {}
    local lCONF := .F.

    qlbloc(8,2,"B201O","QBLOC.GLO",1)


    XNIVEL := 1
    XFLAG  := .T.


    if OBSERVAC->(dbseek(FAT->Codigo))
       OBSERVAC->(qpublicfields())
       OBSERVAC->(qinitfields())
       OBSERVAC->(qcopyfields())

       qrsay(XNIVEL  ,OBSERVAC->Obs1)
       qrsay(XNIVEL+1,fObs2)
       qrsay(XNIVEL+2,fObs3)
       qrsay(XNIVEL+3,fObs4)
       qrsay(XNIVEL+4,fObs5)
    else
       OBSERVAC->(qpublicfields())
       OBSERVAC->(qinitfields())
    endif


    aadd(aEDICAO,{{ || qgetx(-1,0,@fOBS1,"@!"                      )} ,"OBS1"   })
    aadd(aEDICAO,{{ || qgetx(-1,0,@fOBS2,"@!"                      )} ,"OBS2"   })
    aadd(aEDICAO,{{ || qgetx(-1,0,@fOBS3,"@!"                      )} ,"OBS3"   })
    aadd(aEDICAO,{{ || qgetx(-1,0,@fOBS4,"@!"                      )} ,"OBS4"   })
    aadd(aEDICAO,{{ || qgetx(-1,0,@fOBS5,"@!"                      )} ,"OBS5"   })

    aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})

    // LOOP PARA ENTRADA DOS CAMPOS ____________________________________________

    do while XNIVEL >= 1 .and. XNIVEL <= len(aEDICAO)
       eval ( aEDICAO [XNIVEL,1] )
       if eval ( bESCAPE );return;endif
       if ! i_crit_obs( aEDICAO[XNIVEL,2] ) ; loop ; endif
       iif ( XFLAG , XNIVEL++ , XNIVEL-- )
       qmensa("")
    enddo

    if ! lCONF ; return ; endif

    if OBSERVAC->(dbseek(FAT->codigo))
       OBSERVAC->(qrlock())
       OBSERVAC->(qreplacefields())
       OBSERVAC->(qunlock())
    else
       OBSERVAC->(qappend())
       OBSERVAC->(qreplacefields())
       OBSERVAC->(dbcommit())
    endif



return ""

/////////////////////////////////////////////////////////////////////////////
// CRITICAS NA DESCIDA ______________________________________________________

static function i_crit_obs ( cCAMPO )
   qmensa("")

   do case
      case cCAMPO == "OBS1"
           fCOD_FAT := FAT->codigo


   endcase

return .T.

/////////////////////////////////////////////////////////////////////////////
// PARA CONSULTAR SE POSSUI OUTRAS ALIQUOTAS ________________________________

static function i_consObs

   local nTECLA, nCONT

   setpos(24,79)

   do while .T.
      nTECLA := qinkey()
      if nTECLA == K_ESC ; exit ; endif

      qlbloc(8,2,"B201O","QBLOC.GLO",1)

      XNIVEL := 1

      if OBSERVAC->(dbseek(FAT->Codigo))
         qrsay(XNIVEL  ,OBSERVAC->Obs1)
         qrsay(XNIVEL+1,OBSERVAC->Obs2)
         qrsay(XNIVEL+2,OBSERVAC->Obs3)
         qrsay(XNIVEL+3,OBSERVAC->Obs4)
         qrsay(XNIVEL+4,OBSERVAC->Obs5)
      endif
      qwait()
      exit
   enddo



return

static function i_Transp

     if FAT->(qrlock())
        replace FAT->Cod_transp with CLI1->Cod_transp
        FAT->(qunlock())
     endif

return

static function i_Frete

     if FAT->(qrlock())
        replace FAT->Frete with "1"
        FAT->(qunlock())
     endif

return

static function sayAll

      qsay ( 06,17 , FAT->Codigo           )
      qsay ( 06,42 , dtoc(FAT->Dt_Emissao) )
      qsay ( 06,68 , dtoc(FAT->Data_ped  ) )
      qsay ( 07,24 , FAT->Cod_Cli          ) ; CLI1->(dbseek(FAT->Cod_cli))
      qsay ( 07,32 , left(CLI1->Razao,30)  )


      if CONFIG->Modelo_fat != "8"
         if  CONFIG->Modelo_fat == "1"
//            qsay ( 08,08 , left(FAT->User,10)       )
//            qsay ( 08,29 , left(FAT->User_alt,10)   )
//         else
            qsay ( 08,17 , FAT->Cod_vended       ) ; VEND->(dbseek(FAT->Cod_vended))
            qsay ( 08,25 , left(VEND->Nome,16)   )
         endif
      else
         qsay ( 08,24 , FAT->Cod_vended       ) ; VEND->(dbseek(FAT->Cod_vended))
         qsay ( 08,32 , left(VEND->Nome,25)   )
      endif

      if CONFIG->Modelo_fat != "8"
         qsay ( 08,51 , FAT->Cod_repres       ) ; REPRES->(dbseek(FAT->Cod_repres))
         qsay ( 08,57 , left(REPRES->Razao,21)   )
      endif

      if CONFIG->Modelo_fat == "1"
         qsay ( 09,24,  qabrev(FAT->Boleto,"123456789", {"Boleto","Pgto a Vista - Boleto","Pgto a Vista - Deposito","Antecipado","Nulo","Plano Mkt","Abater Credito","Segurar Duplicata","A Prazo - Deposito"}))
      else
         qsay ( 09,24 , FAT->Filial           ) ; FILIAL->(dbseek(FAT->Filial))
         qsay ( 09,31 , left(FILIAL->Razao,30))
      endif


      qsay ( 10,24 , FAT->C_custo          ) ; CCUSTO->(dbseek(FAT->C_custo))
      qsay ( 10,31 , left(CCUSTO->Descricao,15))

      if CONFIG->Modelo_2 $ "9"
         PROD->(dbsetorder(1))
         qsay ( 10,61 , FAT->Cod_di            ) ; PROD->(dbseek(FAT->Cod_Di))
         qsay ( 10,66 , left(PROD->Descricao,12) )
      else
         qsay ( 10,71 , FAT->Pedido )
      endif

      qsay ( 11,24 , FAT->Cod_transp       ) ; TRANSP->(dbseek(FAT->Cod_transp))
      qsay ( 11,32 , left(TRANSP->Razao,20))

      if CONFIG->Modelo_2 == "7"
         qsay ( 11,61 , FAT->Tipo_doc         ) ; TIPO_DOC->(dbseek(FAT->Tipo_doc))
         qsay ( 11,66 , left(TIPO_DOC->Descricao,11))
         qsay ( 12,10 , transform(FAT->Cod_cfop,"@R 9.999")) ; CFOP->(dbseek(FAT->Cod_cfop))
         qsay ( 12,18 , left(CFOP->Nat_desc,22))
         qsay ( 12,50 , transform(FAT->Cfop2,"@R 9.999")) ; CFOP->(dbseek(FAT->Cfop2))
         qsay ( 12,58 , left(CFOP->Nat_desc,20))

      else
         qsay ( 12,24 , transform(FAT->Cod_cfop,"@R 9.999")) ; CFOP->(dbseek(FAT->Cod_cfop))
         qsay ( 12,32 , left(CFOP->Nat_desc,38))
      endif


      if  CONFIG->Modelo_fat == "8"
        qsay ( 13,24 , transform(FAT->cfop2,"@R 9.999")) ; CFOP->(dbseek(FAT->cfop2))
        qsay ( 13,32 , left(CFOP->Nat_desc,38))
      else
        if CONFIG->Modelo_2 == "2"
           qsay( 13,24,FAT->Condic) ; COND->(dbseek(FAT->Condic))
           qsay( 13,29,COND->Descricao )
        else
           qsay ( 13,21 , FAT->Tiposub          ) ; TIPOCONT->(dbseek(FAT->Tiposub))
           qsay ( 13,30,  left(TIPOCONT->Descricao,27))

        endif
      endif

      if CONFIG->Modelo_2 == "7"
         qsay ( 13,73,  qabrev(FAT->Estoq_fora,"SN ", {"Sim","Nao","Nao"}))
      endif


      qsay ( 14,27,  qabrev(FAT->Desc_sn,"SN", {"Sim","N„o"}))
      qsay ( 14,50,  qabrev(FAT->Es     ,"SC", {"Saida","C.Icms"}))

      if CONFIG->Modelo_2 == "2"
         qsay ( 14,71, transform(FAT->Aliq_desc,"@E 9999.99")    )
      else
         qsay ( 14,73, transform(FAT->Aliq_desc,"@E 99.99")    )
      endif
      qsay ( 15,14 , Left(FAT->Obs,43)             )
      qsay ( 15,70,  qabrev(FAT->Frete    ,"12", {"1 - Cif","2 - Fob"}))

return

static function sayPerfil

      qsay ( 06,17 , FAT->Codigo           )
      qsay ( 06,42 , dtoc(FAT->Dt_Emissao) )
      qsay ( 06,68 , dtoc(FAT->Data_lanc  ) )
      qsay ( 07,24 , FAT->Cod_Cli          ) ; CLI1->(dbseek(FAT->Cod_cli))
      qsay ( 07,32 , left(CLI1->Razao,30)  )

      qsay ( 08,17 , FAT->Cod_vended       ) ; VEND->(dbseek(FAT->Cod_vended))
      qsay ( 08,25 , left(VEND->Nome,16)   )

      qsay ( 09,24 , FAT->Cod_transp       ) ; TRANSP->(dbseek(FAT->Cod_transp))
      qsay ( 09,32 , left(TRANSP->Razao,20))

      qsay ( 10,24 , transform(FAT->Cod_cfop,"@R 9.999")) ; CFOP->(dbseek(FAT->Cod_cfop))
      qsay ( 10,32 , left(CFOP->Nat_desc,38))

      qsay ( 11,24 , transform(FAT->CFOP2,"@R 9.999")) ; CFOP->(dbseek(FAT->CFOP2))
      qsay ( 11,32 , left(CFOP->Nat_desc,38))

      qsay ( 12,14 , Left(FAT->Obs,43)             )
      qsay ( 12,70,  qabrev(FAT->Frete    ,"12", {"1 - Cif","2 - Fob"}))


retuRN


static function getall(aEdicao)
   aadd(aEDICAO,{{ || NIL                                               } ,"CODIGO"       })
   //aadd(aEDICAO,{{ || NIL                                               } ,"SEILA"       })
   aadd(aEDICAO,{{ || qgetx(6,42,@fDT_EMISSAO,"@D",                    )} ,"DT_EMISSAO"   })
   if lALT
      aadd(aEDICAO,{{ || NIL                                               } ,NIL       })
   else
      aadd(aEDICAO,{{ || qgetx(6,68,@fDATA_PED  ,"@D",                    )} ,"DATA_PED"     })
   endif
   //aadd(aEDICAO,{{ || NIL                         ,                     } ,"DATA_PED"     })
   if CONFIG->Modelo_NF == "01"
      aadd(aEDICAO,{{ || view_cli4(7,24,@fCOD_CLI                          )} ,"COD_CLI"      })
   else
      aadd(aEDICAO,{{ || view_cli2(7,24,@fCOD_CLI                          )} ,"COD_CLI"      })
   endif

   aadd(aEDICAO,{{ || NIL },NIL }) // razao do cliente

   if CONFIG->Modelo_fat == "8"
      aadd(aEDICAO,{{ || view_vend(8,24,@fCOD_VENDED                      )} ,"COD_VENDED"   })
      aadd(aEDICAO,{{ || NIL },NIL }) // nome do vendedor
   else
      if CONFIG->Modelo_fat == "1"
         aadd(aEDICAO,{{ || NIL },NIL }) // razao do cliente
//         aadd(aEDICAO,{{ || NIL },NIL }) // razao do cliente
         aadd(aEDICAO,{{ || view_vend(8,17,@fCOD_VENDED                      )} ,"COD_VENDED"   })
         aadd(aEDICAO,{{ || NIL },NIL }) // nome do vendedor
      endif

   endif

   if CONFIG->Modelo_fat != "8"
      aadd(aEDICAO,{{ || view_repres(8,51,@fCOD_REPRES                      )} ,"COD_REPRES"   })
      aadd(aEDICAO,{{ || NIL },NIL }) // nome do representante
   endif

   if CONFIG->Modelo_fat == "1"
      aadd(aEDICAO,{{ || qesco(9,24,@fBOLETO      ,sBLOC4                    )}   ,"BOLETO"  })
   else
      aadd(aEDICAO,{{ || view_filial(9,24,@fFILIAL                        )} ,"FILIAL"       })
      aadd(aEDICAO,{{ || NIL },NIL }) // descricao da filial
   endif

   aadd(aEDICAO,{{ || view_ccusto(10,24,@fC_CUSTO                       )} ,"C_CUSTO"      })
   aadd(aEDICAO,{{ || NIL },NIL }) // descricao do centro

   if CONFIG->Modelo_2 $ "9"
      aadd(aEDICAO,{{ || view_familia(10,61,@fCOD_DI                     )} ,"COD_DI"      })
      aadd(aEDICAO,{{ || NIL },NIL }) // descricao da DI
   else
      aadd(aEDICAO,{{ || qgetx(10,71,@fPEDIDO ,"",                    )} ,"PEDIDO"  })
   endif

   aadd(aEDICAO,{{ || view_transp(11,24,@fCOD_TRANSP                    )} ,"COD_TRANSP"      })
   aadd(aEDICAO,{{ || NIL },NIL }) // descricao da Transportadora

   if CONFIG->Modelo_2 == "7"
      aadd(aEDICAO,{{ || view_doc(11,61,@fTIPO_DOC                    )} ,"TIPO_DOC"      })
      aadd(aEDICAO,{{ || NIL },NIL }) // descricao do Tipo do Documento

      aadd(aEDICAO,{{ || view_cfop(12,10,@fCOD_CFOP                       )} ,"CFOP1"     })
      aadd(aEDICAO,{{ || NIL },NIL }) // descricao da natureza de operacao
      aadd(aEDICAO,{{ || view_cfop(12,50,@fCFOP2                          )} ,"CFOP2"     })
      aadd(aEDICAO,{{ || NIL },NIL }) // descricao da natureza de operacao
   else
      if CONFIG->Modelo_fat == "1"
         //if cOPCAO == "I" //.or. left(XUSRIDT,5) == "BASSO"
            aadd(aEDICAO,{{ || view_cfop(12,24,@fCOD_CFOP                       )} ,"COD_CFOP"     })
            aadd(aEDICAO,{{ || NIL },NIL }) // descricao da natureza de operacao
         //endif
      else
         aadd(aEDICAO,{{ || view_cfop(12,24,@fCOD_CFOP                       )} ,"COD_CFOP"     })
         aadd(aEDICAO,{{ || NIL },NIL }) // descricao da natureza de operacao

      endif

   Endif


   if CONFIG->Modelo_fat == "8"
      aadd(aEDICAO,{{ || view_cfop(13,24,@fCFOP2                      )} ,"CFOP2"     })
      aadd(aEDICAO,{{ || NIL },NIL }) // descricao da natureza de operacao
    else
      if CONFIG->Modelo_2 == "2"
        aadd(aEDICAO,{{ || view_cond(13,24,@fCONDIC                    )}  ,"CONDIC"      })
        aadd(aEDICAO,{{ || NIL },NIL }) // descricao do tipo
      else
        aadd(aEDICAO,{{ || view_tipocont(13,21,@fTIPOSUB                    )}  ,"TIPOSUB"      })
        aadd(aEDICAO,{{ || NIL },NIL }) // descricao do tipo
      endif
   endif

   if CONFIG->Modelo_2 == "7"
      aadd(aEDICAO,{{ || qesco(13,73,@fESTOQ_FORA      ,XSN                )}   ,"ESTOQ_FORA"})
   endif

   aadd(aEDICAO,{{ || qesco(14,27,@fDESC_SN ,sBLOC1                    )}   ,"DESC_SN"    })
   aadd(aEDICAO,{{ || qesco(14,50,@fES      ,sBLOC2                    )}   ,"ES"         })

   if CONFIG->Modelo_2 == "2"
      aadd(aEDICAO,{{ || qgetx(14,71,@fALIQ_DESC,"9999.99",NIL              )}   ,"ALIQ_DESC"  })
   else
      aadd(aEDICAO,{{ || qgetx(14,73,@fALIQ_DESC,"99.99",NIL              )}   ,"ALIQ_DESC"  })
   endif

   aadd(aEDICAO,{{ || qgetx(15,14,@fOBS,"@!S43",NIL                    )}   ,"OBS"        })
   aadd(aEDICAO,{{ || qesco(15,70,@fFRETE      ,sBLOC3                    )}   ,"FRETE"         })


   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})



return


static function getPerfil(aEdicao)
   aadd(aEDICAO,{{ || NIL                                               } ,"CODIGO"       })
   //aadd(aEDICAO,{{ || NIL                                               } ,"SEILA"       })
   aadd(aEDICAO,{{ || qgetx(6,42,@fDT_EMISSAO,"@D",                    )} ,"DT_EMISSAO"   })
   aadd(aEDICAO,{{ || qgetx(6,68,@fDATA_LANC  ,"@D",                    )} ,"DATA_LANC"     })

   aadd(aEDICAO,{{ || view_cli2(7,24,@fCOD_CLI                          )} ,"COD_CLI"      })
   aadd(aEDICAO,{{ || NIL },NIL }) // razao do cliente

   aadd(aEDICAO,{{ || view_vend(8,17,@fCOD_VENDED                      )} ,"COD_VENDED"   })
   aadd(aEDICAO,{{ || NIL },NIL }) // nome do vendedor

   aadd(aEDICAO,{{ || view_transp(9,24,@fCOD_TRANSP                    )} ,"TRANSP_PER"      })
   aadd(aEDICAO,{{ || NIL },NIL }) // descricao da Transportadora


   aadd(aEDICAO,{{ || view_cfop(10,24,@fCOD_CFOP                       )} ,"CFOP1_PER"     })
   aadd(aEDICAO,{{ || NIL },NIL }) // descricao da natureza de operacao

   aadd(aEDICAO,{{ || view_cfop(11,24,@fCFOP2                      )} ,"CFOP2_PER"     })
   aadd(aEDICAO,{{ || NIL },NIL }) // descricao da natureza de operacao


   aadd(aEDICAO,{{ || qgetx(12,14,@fOBS,"@!S43",NIL                    )}   ,"OBS"        })
   aadd(aEDICAO,{{ || qesco(12,70,@fFRETE      ,sBLOC3                    )}   ,"FRETE_PER"         })


   aadd(aEDICAO,{{ || lCONF := qconf("Confirma "+iif(cOPCAO=="I","inclus„o","altera‡„o")+" ?") },NIL})


return

static function i_admin
local cSENHA := space(10)
local cORI   := space(10)
local lOK := .F.

    qlbloc(13,32,"B201ADM","QBLOC.GLO",1)
    XNIVEL := 1

    cSENHA := qgetsenha(15,36,10)

    if upper(cSENHA) == qdecri(XADMIN)
       lOK := .T.
    endif

return lOK

static function i_mudanomecli

  CLI1->(dbseek(FAT->cod_cli))
  if FAT->(qrlock())
     replace Cliente with CLI1->Razao
     FAT->(qunlock())
  endif
  // teste
return


static function i_gera_entTransf
local cOldCodigo := cCODIGO := space(5)
local nREG := 0
local nFAT := 0


   if ! qconf("Confirma geracao de Nf de Entrada p/ Transferencia?","B")
      return .F.
   endif


   FAT->(QPublicFields())
   FAT->(QcopyFields())
   cOldCodigo := FAT->Codigo
   nFAT := FAT->(recno())

   if NUM_PEDI->(Qrlock())
      replace NUM_PEDI->Pedido with NUM_PEDI->Pedido + 1
      fCODIGO := strzero(NUM_PEDI->Pedido,5)
      cCODIGO := fCODIGO
      NUM_PEDI->(Qunlock())
   endif

   fES         := "E"
   fNFE        := space(44)
   fContabil   := .F.
   fFiscal     := .F.
   fInterface  := .F.
   fOBS        := ""
   fDT_EMISSAO := date()
   fDT_SAIDA   := date()
   fDATA_LANC    := date()
   fCOD_CFOP   := "1152"
   fNUM_FATURA := ""
   fCCUSTO := "0004"

   FAT->(Qappend())
   FAT->(qreplaceFields())
   FAT->(QreleaseFields())

   ITEN_FAT->(Dbgotop())
   if ITEN_FAT->(Dbseek(cOldCodigo))
      Do While ! ITEN_FAT->(Eof()) .and. ITEN_FAT->Num_fat ==  cOLdCodigo

         nREG := ITEN_FAT->(REcno())

         INVENT->(dbseek(ITEN_FAT->Cod_prod))
         if INVENT->(qrlock())
            replace INVENT->Quant_atu with INVENT->Quant_atu + ITEN_FAT->Quantidade
            INVENT->(qunlock())
         endif

         ITEN_FAT->(Qinitfields())
         ITEN_FAT->(QPublicFields())
         ITEN_FAT->(QcopyFields())

         fNUM_FAT := cCODIGO

         if ITEN_FAT->(Qappend())
            ITEN_FAT->(QreplaceFields())
            ITEN_FAT->(QreleaseFields())
         endif

         ITEN_FAT->(dbgoto(nREG))

         ITEN_FAT->(dbskip())
      enddo

      FAT->(dbgoto(nFAT))
      qmensa("Codigo de entrada gerado.: "+cCodigo,"BL")
      qinkey(0.5)

   endif

return

static function verificarDuplicatas()

 if ! left(FAT->Cod_cfop,3) $ "510-610-611-511-512-612-540-640-550-650"
    
	if DUP_FAT->(dbseek(FAT->Codigo+"01"))
	
	   do while ! DUP_FAT->(eof()) .and. DUP_FAT->(qrlock()) .and. left(DUP_FAT->Num_fat,5) == FAT->Codigo
	      DUP_FAT->(dbdelete())
	      DUP_FAT->(dbskip())
       enddo
	   alert("Este pedido nao e referenta a uma venda, as duplicatas foram excluidas")
    endif
	
 endif
 
 select FAT
 
return

static function existeArea(fCidade)
local nReg := 0
local nIndex := 0
local lExisteArea := .F.

        nREG   := AREA_EXC->(recno())
        nINDEX := AREA_EXC->(IndexOrd())
		
		AREA_EXC->(dbsetorder(3))

        if AREA_EXC->(dbseek(fCIDADE))
		   lExisteArea := .T.
		endif
		
		AREA_EXC->(dbgoto(nREG))
        AREA_EXC->(dbsetorder(nINDEX))


return lExisteArea


static function i_aliquotaIcms

   if ! qconf("Confirma atualizacao de aliquotas de icms e ipi?")
      return .F.
   endif	  

   if ! empty(FAT->NFe)
      qmensa("Pedido ja foi faturado, atualizacao de aliquotas nao permitda!!","BL")
      return .F.   
   endif
   
   if left(FAT->cod_cfop,4) $ "5949-6949-5916-6916-5915-6915"
      return .F.
   endif	  
   
   PROD->(dbsetorder(4))

   ITEN_FAT->(dbseek(FAT->Codigo))
   do while ! FAT->(eof()) .and. ITEN_FAT->num_fat == FAT->Codigo
   
      if ITEN_FAT->(qrlock())
		 if ! empty(CLI1->Inscricao) .and. left(upper(CLI1->Inscricao),5) != "ISENT" .and. CONFIG->Modelo_fat == "1"
		    if left(FAT->Cod_cfop ,1) == "6"
			   replace ITEN_FAT->Icms with 4.00
			endif
		 endif

		 if CLI1->Isento == "N" //.and. CONFIG->Modelo_fat == "1"
            replace ITEN_FAT->Icms with 18.00
		 endif
		 
		 PROD->(dbseek(ITEN_FAT->Cod_prod))
		 replace ITEN_FAT->Ipi with PROD->Ipi
         
	     ITEN_FAT->(qunlock())
	  endif

      ITEN_FAT->(dbskip())
   enddo

return


