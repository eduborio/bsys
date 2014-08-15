import java.util.HashMap;


public class BalancoEmpresa {
	 private HashMap<Cnpj, Divida> dividas = new HashMap<Cnpj, Divida>();
	 
	    public void registraDivida(Divida divida) {
	        dividas.put(divida.getCnpjCredor(), divida);
	    }
	 
	    public void pagaDivida(Cnpj cnpjCredor, Pagamento pagamento) {
	        Divida divida = dividas.get(cnpjCredor);
	        if (divida != null) {
	           divida.registra(pagamento);
	        }
	    }

}
