import java.text.NumberFormat;
import java.util.Locale;


public class TesteDeRelatorio {
	
	public static void main(String[] args) {
		Divida divida = new Divida();
		divida.setCredor("Mantra Trading Co");
		divida.setCnpjCredor(new Cnpj("00.000.000/0001-01"));
		
		divida.setTotal(100);
		
		Pagamento pagamento =  new Pagamento();
		pagamento.setCnpjPagador("00.000.000/0002-02");
		pagamento.setPagador("Coca-Cola");
		pagamento.setValor(20);
		
		divida.registra(pagamento);
		
		RelatorioDeDivida rel = new RelatorioDeDivida(divida);
		NumberFormat formatBR = NumberFormat.getCurrencyInstance(new Locale("pt","BR"));
		rel.gerarRelatorio(formatBR);
		NumberFormat formatUS = NumberFormat.getCurrencyInstance(new Locale("en","US"));
		rel.gerarRelatorio(formatUS);
	}
}
