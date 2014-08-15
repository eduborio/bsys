import java.text.NumberFormat;

public class RelatorioDeDivida {
	
	private Divida divida;

	public RelatorioDeDivida(Divida divida){
	    this.divida = divida;
	}
	
	public void gerarRelatorio(NumberFormat formatador){
		System.out.println("Cnpj  : "+ divida.getCnpjCredor());
		System.out.println("Credor: "+divida.getCredor());
		System.out.println("valor da Divida: "+formatador.format(divida.getTotal()));
		System.out.println("total Pago : "+ formatador.format(divida.getValorPago()));
		
		
	}

}
