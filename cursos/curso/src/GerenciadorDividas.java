
public class GerenciadorDividas {
	
	public void efetuaPagamento(Divida divida,double valor,String nomePagador, String cnpjPagador){
		Pagamento pagamento = new Pagamento();
		pagamento.setNomePagador(nomePagador);
		pagamento.setCnpjPagador(cnpjPagador);
		pagamento.setValorPagamento(valor);
			
		divida.registra(pagamento);
		
	}

}
