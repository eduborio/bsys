// ROTINA DE INDEXACAO ______________________________________________________
//
// LUIS ANTONIO ORLANDO PEREIRA - Q-SYS - CURITIBA
// ULTIMA ATUALIZACAO EM MARCO DE 1994
// A ATUALIZACAO DO QPATHS ESTAVA AQUI E FOI RETIRADA EM JUNHO DE 1995

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

function q901
#include "inkey.ch"

local   lRESP, cTIME, C_USR, C_COR, nCONT, nCHAVE, cARQDBF, nQUANT := nQUANTX := 0
private cNTX, cCAMINHO, M_MACRO, cFILENAME, lFLAGUNIQ, lFLAGPACK, nEMPR
private c255, cDESCR, cSETA := "ÀÄÄ" +chr(26), lALL := .F., aEMP := {}
private cMARCA1 := cMARCA2 := " ", cRAZAO_INICIAL := XRAZAO
private RDD := "DBFCDX"

XHELP := "901"
set deleted ON

// PARAMETRO OPCIONAL PARA INDEXACAO COM PACK _______________________________

parameters lEXECPACK, cCONTROLE, cSAIR

if pcount() == 0            // LEXEPACK E' UTILIZADO NA OPCAO 902 PARA
   lEXECPACK := .F.         // REALIZAR PACK ANTES DE INDEXAR
endif

if empty(cCONTROLE)         // CONTROLE PARA PASSAR NOME DO SISTEMA E E'
   cCONTROLE := ""          // UTILIZADO EM QSELEMP QUANDO CRIA NOVA
endif                       // EMPRESA C/ INDEXACAO AUTOMATICA

// ABRE ARQUIVO QINDEX PARA CONSULTAR PATH/DBF/KEY/NTX ______________________

if ! quse("","QINDEX") ; return ; endif

// CRIA E ATUALIZA VETOR COM A BASE DE DADOS DO SISTEMA _____________________

private aSELECAO := {}

do while ! eof()
   c255     := " "
   cCAMINHO := QINDEX->Caminho
   cCAMINHO := alltrim(&cCAMINHO)
   if XEMPRESA == left(right(cCAMINHO,4),3) .and. alltrim(Caminho) == "XDRV_" + left(XSIGLA,2)
      c255 := chr(255)  // INFORMACAO PARA O SHIFT-TAB...
   endif
   if file ( alltrim(&(Caminho)) + alltrim(Arquivo) + ".DBF" )
      aadd(aSELECAO,Arquivo + " - " + Descricao + c255 + "   ")
   endif
   skip
enddo
asort(aSELECAO)

do while .T.

   // CARREGA BLOCO INICIAL DO DIRETORIO PUBLICO ____________________________

   qlbloc(5,0,"B901",XDRV_SH+"QSBLOC.GLO")

   // UTILIZA ACHOICE PARA SELECAO DOS ARQUIVOS A SEREM INDEXADOS ___________

   C_COR := setcolor(atcsc_sl(09,17))

   qmensa("ESPA€O: Item/ TAB: Total /LETRA: Busca /ENTER: Inicia /ESC: sair")

   if achoice(09,17,21,62,aSELECAO,.T.,"ctrl_selecao",0,0) == 0
      setcolor(C_COR)
      dbcloseall()
      return
   endif

   poscu_sl(25,00)
   setcolor(C_COR)

   // CONTA A QUANTIDADE DE ARQUIVOS SELECIONADOS ___________________________

   aeval ( aSELECAO , { |x| iif(right(x,1)!=" ",nQUANT++,nil) } )
   nQUANTX := nQUANT

   // VERIFICA SE HOUVE SELECAO DE ARQUIVOS OU RETORNA ______________________

   if nQUANT == 0
      qmensa("N„o houve sele‡„o de arquivos...","B")
      loop
   endif

   cTIME := time()
   qsay(6,26,"Ä")
   qsay(8,13,"³")
   qsay(8,66,"³")

   // SE FOR O CASO REALIZA INDEXACAO DE TODAS AS EMPRESAS __________________

   for nEMPR := 1 to iif ( empty(aEMP) , 1 , len(aEMP) )

       nQUANT := nQUANTX  // REINICIALIZA QUANT P/ VARIAS EMPRESAS...

       // FAZ A INDEXACAO DOS ARQUIVOS SELECIONADOS _________________________

       if lALL
          (alias())->(qseldirect(aEMP[nEMPR]))
          qmensa("Indexando: "+aEMP[nEMPR]+" ("+strzero(len(aEMP)-nEMPR+1,3)+")")
       else
          qmensa("Indexando os arquivos selecionados, aguarde...")
       endif
       setcleara("B/BG")
       clear_sl(07,14,21,65)   // limpa area central
       for nCONT := 1 to len(aSELECAO)

           // VERIFICA SE <ESC> PRESSIONADO _____________________________________

           if cSAIR != "S"
              if qinkey() == K_ESC .and. ;
                 alert("<ESC> Pressionado !;Confirma interromper a indexa‡„o ?",{"SIM","NŽO"}) == 1
                 exit
              endif
           endif

           // SOMENTE INDEXA OS ARQUIVOS MARCADOS _______________________________

           if ! empty(right(aSELECAO[nCONT],1))
              locate for Arquivo $ left(aSELECAO[nCONT],10)
              cCAMINHO  := Caminho
              cCAMINHO  := &cCAMINHO
              cFILENAME := alltrim(Arquivo)
              lFLAGPACK := iif ( type("Flag_pack")=="L" , Flag_pack , .F. )
              cARQDBF  := cCAMINHO + cFILENAME
              qsay(21,15,strzero(nQUANT,2)+" - "+right(cARQDBF,39)+".DBF")

              if RDD == "SIXCDX" .or. RDD == "DBFCDX"
                 if file(cARQDBF+".CDX")
                    ferase(cARQDBF+".CDX")
                 endif
              endif

              if RDD == "SIXNSX"
                 if file(cARQDBF+".NSX")
                    ferase(cARQDBF+".NSX")
                 endif
              endif


              scrol_sl(07,14,21,65,2,"B/BG")
              qsay(20,18,cSETA)

              // CHAMA ROTINA DE PACK SE NECESSARIO _____________________________

              if ! iif(lEXECPACK.and.lFLAGPACK,0->(do_pack(cCAMINHO,cFILENAME)),.T.)
                 loop
              endif

              // LOOP PARA TODOS OS INDEXADORES DO ARQUIVO SELECIONADO __________

              for nCHAVE := 1 to 15
                 cNTX := "NTX_" + strzero( nCHAVE , 2 )
                 if "U" $ type("&cNTX.") .or. empty(&cNTX.) ; exit ; endif
                 cNTX := &cNTX.

                 qsay(21,18,cSETA)
                 cDESCR := &("DES_"+strzero(nCHAVE,2))
                 qsay(21,23,lower(left(cDESCR,28)))

                 M_KEY := &("KEY_" + strzero( nCHAVE , 2 ))

                 if "UNIQUE" $ M_KEY
                    lFLAGUNIQ := .T.
                    M_KEY := strtran(M_KEY,"UNIQUE","")
                 else
                    lFLAGUNIQ := .F.
                 endif

                 // CHAMA A ROTINA DE INDEXACAO

                 if ! 0->(do_index(cCAMINHO,cFILENAME))
                    qsay(21,21,"( arquivo em uso ! )")
                    exit
                 endif

                 scrol_sl(07,14,21,65,1,"B/BG")
              next

              nQUANT--
              scrol_sl(07,14,21,65,1,"B/BG")
           endif
       next
   next

   scrol_sl(07,14,21,65,1,"B/BG")
   cTIME := right(qdifhora(cTIME,time()),7)
   qsay(21,16,"Tempo total para reindexa‡„o: " + cTIME)

   // TODOS OS ARQUIVOS INDEXADOS, FECHA TUDO E RETORNA _____________________

   if ! empty(cCONTROLE)
      keyboard (chr(K_ESC)+chr(K_ESC))  // PARA SAIR DO QINKEY E DO WHILE...
   endif

   qmensa("Reindexa‡„o completa ! Qualquer tecla para continuar")
   qbeep()
   qinkey(0)

   if lALL ; (alias())->(qseldirect(cRAZAO_INICIAL)) ; endif

enddo

dbcloseall()
return

/////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////
// FUNCOES UTILIZADAS NESTE PRG _____________________________________________

/////////////////////////////////////////////////////////////////////////////
// FUNCAO DE ESCOLHA DOS ARQUIVOS A SEREM INDEXADOS (ACHOICE) _______________

function ctrl_selecao ( nMODO, nITEM, nLINHA )
    local nCONT, nPOINTER, cMARCA

    do case

       // ESC ABORTA A INDEXACAO ____________________________________________

       case lastkey() == K_ESC
            return 0

       // ENTER SAI DO ACHOICE E INICIA A INDEXACAO _________________________

       case lastkey() == K_ENTER
            return 1

       // HOME VAI PARA O INICIO DA LISTA ___________________________________

       case lastkey() == 1
            keyboard chr(31) // ctrl+pgup
            return 2

       // END VAI PARA O FIM DA LISTA _______________________________________

       case lastkey() == 6
            keyboard chr(30) // ctrl+pgdw
            return 2

       // ESPACO MARCA/DESMARCA O ARQUIVO A SER INDEXADO ____________________

       case lastkey() == K_SPACE
            cMARCA := if(right(aSELECAO[nITEM],1)=="þ"," ","þ")
            aSELECAO[nITEM] := stuff(aSELECAO[nITEM],46,1,cMARCA)
            qsay(nLINHA+9,62,cMARCA)
            keyboard chr(24)
            return 2

       // TAB MARCA/DESMARCA TODOS OS ARQUIVOS ______________________________

       case lastkey() == K_TAB
            cMARCA1 := if(cMARCA1=="þ"," ","þ")
            for nCONT := 1 to len(aSELECAO)
                aSELECAO[nCONT] := stuff(aSELECAO[nCONT],46,1,cMARCA1)
            next
            nPOINTER := nITEM - nLINHA
            for nCONT := 9 to 21
                qsay ( nCONT , 62 , right(aSELECAO[nPOINTER++],1) )
                if nPOINTER > len(aSELECAO) ; exit ; endif
            next
            return 2

       // SHIFT-TAB MARCA/DESMARCA TODOS OS ARQUIVOS DO DIRETORIO ___________

       case lastkey() == K_CTRL_K
            cMARCA2 := if(cMARCA2==chr(4)," ",chr(4))
            for nCONT := 1 to len(aSELECAO)
                if chr(255) $ aSELECAO[nCONT]
                   aSELECAO[nCONT] := stuff(aSELECAO[nCONT],46,1,cMARCA2)
                endif
            next
            nPOINTER := nITEM - nLINHA
            for nCONT := 9 to 21
                qsay ( nCONT , 62 , right(aSELECAO[nPOINTER++],1) )
                if nPOINTER > len(aSELECAO) ; exit ; endif
            next
            return 2

       // INDEXAR TODAS AS EMPRESAS _________________________________________

       case lastkey() == K_ALT_A
            if qconf("Confirma indexar todas as empresas ?") ; (alias())->(i_all()) ; endif

       // PROCURA PROXIMO ARQUIVO INICIANDO COM A LETRA PRESSIONADA _________

       case upper(chr(lastkey())) >= "A" .and. upper(chr(lastkey())) <= "Z"
            keyboard chr(255)  // grande misterio !!!???!!!???
            return 3

    endcase

return 2

/////////////////////////////////////////////////////////////////////////////
// INDEXACAO DE TODAS AS EMPRESAS (CRIA VETOR) ______________________________

static function i_all
   if ! quse(XDRV_SH,"QINST") ; return .F. ; endif
   QINST->(dbskip())
   do while ! QINST->(eof())
      if left(XSIGLA,2)+"." $ QINST->Sistemas
         aadd(aEMP,QINST->Razao)
      endif
      QINST->(dbskip())
   enddo
   QINST->(dbclosearea())
   lALL := .T.
return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA FAZER PACK DO ARQUIVO ________________________________________

static function do_pack ( cCAMINHO, cDBF )
   local cTIME
   if ! quse(cCAMINHO,cDBF) ; return .F. ; endif
   qsay(20,34,"( "+ltrim(transform(reccount(),"@E 9,999,999"))+" registros )")
   qsay(21,18,cSETA+" packing...")
   cTIME := time()
   qsay(21,53,"  0%")
   copy all to (cCAMINHO+"PACKING") for f_condicao_pack()
   use

   delete file (cCAMINHO+cDBF+".DBF")
   rename (cCAMINHO+"PACKING.DBF") to (cCAMINHO+cDBF+".DBF")

   if file (cCAMINHO+cDBF+".DBT")
      delete file (cCAMINHO+cDBF+".DBT")
      rename (cCAMINHO+"PACKING.DBT") to (cCAMINHO+cDBF+".DBT")
   endif

   qsay(21,53,"100%")
   qsay(21,58,right(qdifhora(cTIME,time()),7))
   scrol_sl(07,14,21,65,2,"B/BG")
   qsay(20,18,cSETA)
return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO DE CONDICAO PARA COPIA COM PACK E CHAMADA DO TRACE ________________

function f_condicao_pack
   trace_pack()
return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA INDEXAR UM INDICE SELECIONADO ________________________________
 
static function do_index ( cCAMINHO, cDBF )
local RDD := "DBFCDX"

   // obs: o "cDBF" sera utilizado para abrir o arquivo e tambem para
   // referenciar o nome do indice que mudara apenas a extensao

   local cTIME
   static  S_CTRL := ""
   private nRECS := 0
   private nSTEP := int ( lastrec() / 1000 )

   iif ( nSTEP == 0 , nSTEP := 1 , NIL )

   if ! quse(cCAMINHO,cDBF,{},"E") ; return .F. ; endif

   if S_CTRL <> cDBF
      qsay(20,23,ltrim(transform(reccount(),"@E 9,999,999"))+" Registros...")
      S_CTRL := cDBF
   endif

   cTIME := time()
   qsay(21,53,"  0%")

   if RDD == "SDF" .or. RDD == "DBFNTX" .or. RDD == "SIXNTX"
      if lFLAGUNIQ
         qsay(21,32,"")
         index on &M_KEY. to (cNTX) eval ;
         { || q_meter() } every nSTEP unique
      else
         index on &M_KEY. to (cNTX) eval ;
         { || q_meter() } every nSTEP
      endif
   endif

   if RDD == "SIXCDX" .or. RDD == "DBFCDX" .or. RDD == "SIXNSX"

      if lFLAGUNIQ
         qsay(21,32,"")
         index on &M_KEY. tag (cNTX) for !deleted() eval ;
         { || q_meter() } every nSTEP unique
      else
         index on &M_KEY. tag (cNTX) for !Deleted() eval ;
         { || q_meter() } every nSTEP
      endif
   endif


   qsay(21,53,"100%")
   qsay(21,58,right(qdifhora(cTIME,time()),7))
   use

return .T.

/////////////////////////////////////////////////////////////////////////////
// "METER" PARA ACOMPANHAR A EXECUCAO DA INDEXACAO __________________________

function q_meter()
   nRECS += nSTEP
   iif(nRECS>lastrec(),nRECS:=lastrec(),NIL)
   qsay(21,53,str(((nRECS/lastrec())*100),3))
return .T.

/////////////////////////////////////////////////////////////////////////////
// FUNCAO "TRACE_INDEX" PARA ACOMPANHAR O PACK ______________________________

function trace_pack
    if mod( recno() , 50 ) == 0
       qsay(21,53,str(100/reccount()*recno(),3))
    endif
return ("")

/////////////////////////////////////////////////////////////////////////////
// FUNCAO 902 PARA CHAMAR 901 COM OPCAO DE PACK _____________________________

function q902
   q901(.T.)
return

