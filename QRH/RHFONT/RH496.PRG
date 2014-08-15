/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE FOLHA DE PAGAMENTO
// OBJETIVO...: IMPORTAR DADOS DO RELOGIO PONTO
// ANALISTA...: ANDRE SANTOS
// PROGRAMADOR: O MESMO
// INICIO.....: FEVEREIRO DE 2000
// OBS........:
// ALTERACOES.:

// DECLARACAO E INICIALIZACAO DE VARIAVEIS __________________________________

  qlbloc(06,00,"B496A","QBLOC.GLO")
  zCOLOR = setcolor()
  setcolor('15/3')
  cPK = memoread('c:\relogio\exporta\pk.txt')
  declare aLINHA[round(len(cPK)/27,0)]

  setcolor(',w/bc')

  declare aMAT[len(aLINHA)]
  declare aANO[len(aLINHA)]
  declare aMES[len(aLINHA)]
  declare aDIA[len(aLINHA)]
  declare aHORA[len(aLINHA)]
  declare aMINU[len(aLINHA)]
  declare aHORASAI[len(aLINHA)]
  declare aMINUSAI[len(aLINHA)]

//////////////////////////////////////////////////////////////////////////////
/// ATRIBUI VALORES A MATRIZ DE ACORDO COM CADA LINHA DE C:\RELOGIO\EXPORTA\PK.TXT

  @ 13,44 say str(len(aLINHA),4)
  for nCONT = 1 to len(aLINHA)
      @ 13,34 say str(nCONT,4)
      aLINHA[nCONT]   = memoline(cPK,26,nCONT)
  next

  dPERI = substr(aLINHA[1],14,2) + '/' + substr(aLINHA[1],12,2) + '/' + substr(aLINHA[1],10,2) 

  setcolor('1*/7')
  @ 13,50 say 'OK'
  setcolor('15/3')

  @ 12,58 say dPERI
  @ 15,44 say str(len(aLINHA),4)
//////////////////////////////////////////////////////////////////////////////
/// DISTRIBUI ALINHA{} PARA OUTRAS MATRIZES PARA REPLACE POSTERIOR

  for nCONT = 1 to len(aLINHA)
      @ 15,34 say str(nCONT,4)
      aMAT[nCONT]     =       substr(aLINHA[nCONT],4,5)
      aANO[nCONT]     = '20'+ substr(aLINHA[nCONT],10,2) 
      aMES[nCONT]     =       substr(aLINHA[nCONT],12,2)
      aDIA[nCONT]     =       substr(aLINHA[nCONT],14,2)
      aHORA[nCONT]    =       substr(aLINHA[nCONT],17,2)
      aMINU[nCONT]    =       substr(aLINHA[nCONT],20,2)
  next

//////////////////////////////////////////////////////////////////////////////
/// CRIA ARQUIVO TEMPORARIO PARA REPLACE FINAL (TMP=PONTOTMP) (CADPONTO=FINAL)

  CADPONTO->(dbgotop())
  PONTOTMP->(dbgotop())
  PONTOTMP->(qrlock())
  @ 17,63 say str(len(aLINHA),4)
  for nCONT = 1 to len(aLINHA)
      @ 17,50 say str(nCONT,4)
      if ! empty(aMAT[nCONT]) .and. aANO[nCONT] <> '20      '
         PONTOTMP->(dbappend())
         replace PONTOTMP->Matricula with strzero(val(aMAT[nCONT]),6)
         replace PONTOTMP->Data      with aANO[nCONT] + aMES[nCONT] + aDIA[nCONT]
         replace PONTOTMP->Hora      with aHORA[nCONT] + ':' + aMINU[nCONT]
         PONTOTMP->(qunlock())
      endif
  next
  PONTOTMP->(qunlock())

  PONTOTMP->(dbgotop())
  CADPONTO->(qrlock())
  setcolor('1*/7')
  @ 15,50 say 'OK'
  setcolor('15/3')
  @ 17,63 say str(len(aLINHA),4)
  do while ! PONTOTMP->(eof())
     @ 17,50 say str(nCONT,4)
     CADPONTO->(dbappend())
     replace CADPONTO->Matricula with PONTOTMP->Matricula
     replace CADPONTO->Data      with PONTOTMP->Data
     replace CADPONTO->Horaent   with PONTOTMP->Hora
     PONTOTMP->(dbskip())
     if CADPONTO->Matricula == PONTOTMP->Matricula .and. CADPONTO->Data == PONTOTMP->Data
        replace CADPONTO->horasai with PONTOTMP->Hora
        PONTOTMP->(dbskip())
     endif
  enddo

  CADPONTO->(qunlock())

  CADPONTO->(dbgoto(lastrec()-1))

  dPERF = CADPONTO->(substr(Data,7,2)) + '/' + CADPONTO->(substr(Data,5,2)) + '/' + CADPONTO->(substr(Data,3,2))

  @ 14,58 say dPERF

  @ 19,28 say ' Aguarde Encerrando Processamento'

   PONTOTMP->(dbclosearea())
   quse(XDRV_RH,'PONTOTMP',{'PNT_TMP'},'E')
   PONTOTMP->(__dbzap())

  setcolor('1/7')
  @ 17,69 say 'OK'
  @ 19,28 say ' Arquivo Recuperado com Sucesso  '

  setcolor(zCOLOR)

  inkey(0)
