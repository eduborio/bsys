
public class BalancoEmpresa {
	 private ArmazenadorDeDividas armazenador;
	 
	 public BalancoEmpresa(ArmazenadorDeDividas armazenador){
		 this.armazenador = armazenador;
	 }
	 
     public void registraDivida(Divida divida) { 
    	 armazenador.salva(divida);
	    }
	
     public void pagaDivida(Documento documentoCredor, Pagamento pagamento) {
    	 Divida divida = armazenador.carrega(documentoCredor);
    	 if (divida != null) {
    		 divida.registra(pagamento);
    	 }
    	 armazenador.salva(divida);
     }

}
