
public class Aplicacao {
	
	public static void main(String[] args) {
		BancoDeDados banco = new BancoDeDados("localhost", "User", "9080700");
		BalancoEmpresa balanco = new BalancoEmpresa(banco);
		registraDividas(balanco);
		realizaPagamentos(balanco);
		
	}

	private static void registraDividas(BalancoEmpresa balanco) {
		Divida divida1 =  new Divida();
		divida1.setCredor("Banco Do Brasil SA");
		divida1.setTotal(1000); 
		divida1.setDocumentoCredor(new Cnpj("00.000.000/0001-01"));
		
		Divida divida2 =  new Divida();
		divida2.setCredor("Empresa B");
		divida2.setTotal(2000); 
		divida2.setDocumentoCredor(new Cnpj("02.002.002/0002-02"));
		balanco.registraDivida(divida2);
		
	}
	
	 private static void realizaPagamentos(BalancoEmpresa balanco) {
		    Pagamento p1 = new Pagamento();
		    Pagamento p2 = new Pagamento();
		    Cnpj credor = new Cnpj("00.000.000/0001-01");
		    p1.setPagador("Banco do Brasil");
		    p1.setDocumentoPagador(credor);
		    p1.setValor(100);
		    
		    p2.setPagador("Empresa B");
		    p2.setDocumentoPagador(new Cnpj("02.002.002/0002-02"));
		    p2.setValor(900);
		   
		    balanco.pagaDivida(p1.getDocumentoPagador(), p1);
		    balanco.pagaDivida(p2.getDocumentoPagador(), p2);
		  }

}
