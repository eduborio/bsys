import java.util.HashMap;


public class BalancoEmpresa {
	private HashMap<String,Divida> dividas = new HashMap<String,Divida>();	
	

	public void registraDivida(String credor, String cnpj, double valor){
		Divida divida = new Divida();
		divida.setCredor(credor);
		divida.getCnpjCredor().setValor(cnpj);
		divida.setTotal(valor);
		dividas.put(cnpj,divida);
		
	}
	
	
	public void pagaDivida(String cnpjCredor,double valor,String nomePagador, String cnpjPagador){
		Divida divida = dividas.get(cnpjCredor);
		
		if(divida!= null){
			Pagamento pagamento = new Pagamento();
			pagamento.setNomePagador(nomePagador);
			pagamento.setCnpjPagador(cnpjPagador);
			pagamento.setValorPagamento(valor);
					
			divida.registra(pagamento);
			
			
		}
		
			
		
	}

}
