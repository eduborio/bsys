
public class CorrenteDeRespostasDeRequisicao {
	
	public String formata(Requisicao requisicao,Conta conta){
	   
	   Resposta porcento =  new FormataEmPorCento(null);
	   Resposta csv = new FormataEmCsv(porcento);	
	   Resposta xml = new FormataEmXml(csv);
	   
	   return xml.formata(requisicao, conta);
	}

}
