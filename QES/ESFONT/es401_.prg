/////////////////////////////////////////////////////////////////////////////
// SISTEMA....: SISTEMA DE ESTOQUE
// OBJETIVO...: MANUTENCAO DE BLOQUEIO EM ORDEM DE SERVICO
// ANALISTA...: LUCINEIDE VILAR POSSEBOM
// PROGRAMADOR: A MESMA
// INICIO.....: JULHO DE 1999
// OBS........:
// ALTERACOES.:
function es401

private cMES    := right(CONFIG->Anomes,2)
private cANO    := left(CONFIG->Anomes,4)

OS->(dbSetFilter({|| Dat_entra >= ctod('01/'+cMES+'/'+cANO) },"Dat_entra >= ctod('01/'+cMES+'/'+cANO)"))


OS->(qview({{"Codigo/C¢d."                 ,1},;
           {"left(Descricao,15)/Descri‡„o" ,2},;
           {"Placa/Placa"                  ,0},;
           {"left(Modelo,15)/Modelo"       ,0},;
           {"Ano/Ano"                      ,0},;
           {"Dat_entra/Entrada"            ,0},;
           {"Dat_saida/Saida"              ,0},;
           {"Bloq/SN"                      ,0}},"P",;
           {NIL,"c401a",NIL,NIL},;
            NIL,"<ESC>-Sai/<C>onsulta/<B>loqueia/desbloqueia Ordem de Servi‡o"))

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA ESCOLHA DO TIPO DE MANUTENCAO ________________________________

function c401a
   local nCURSOR := setcursor(1)
   parameters cOPCAO
   cOPCAO := upper(chr(cOPCAO))
   if cOPCAO $ "CB"
      qlbloc(10,1,"B103A","QBLOC.GLO",1)
      i_edicao()
   endif
   setcursor(nCURSOR)
return ""

/////////////////////////////////////////////////////////////////////////////
// FUNCAO PARA REALIZAR A EDICAO DA TELA ____________________________________

static function i_edicao

   // MONTA DADOS NA TELA ___________________________________________________

   if cOPCAO <> "I"
      XNIVEL := 1
      qrsay ( XNIVEL++ , OS->Codigo , "@R 99999"           )
      qrsay ( XNIVEL++ , OS->Descricao, "@X!"              )
      qrsay ( XNIVEL++ , OS->Placa                         )
      qrsay ( XNIVEL++ , OS->Cores , "@X!"                 )
      qrsay ( XNIVEL++ , OS->Modelo , "@X!"                )
      qrsay ( XNIVEL++ , OS->Ano , "@R 9999"               )
      qrsay ( XNIVEL++ , OS->Chassis, "@X!"                )
      qrsay ( XNIVEL++ , OS->Dat_entra, "@D"               )
      qrsay ( XNIVEL++ , OS->Dat_Saida, "@D"               )
   endif

   // CONSULTA OU EXCLUSAO __________________________________________________

   if cOPCAO == "B" ; i_bloq() ; return ; endif

return

////////////////////////////////////////////////////////////////////
// FUNCAO PARA BLOQUIAR/DESBLOQUIAR ORDEM DE SERVICO ______________

static function i_bloq

    if qconf("Confirma Bloqueio/Desbloqueio desta Ordem de servi‡o ? ")
       if OS->(qrlock())
          if OS->Bloq == "S"
             replace OS->Bloq with "N"
          elseif OS->Bloq == "N"
             replace OS->Bloq with "S"
          else
             replace OS->Bloq with "S"
          endif
       endif
       OS->(qunlock())
    endif

return
