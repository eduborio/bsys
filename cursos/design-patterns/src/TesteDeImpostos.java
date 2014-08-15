
public class TesteDeImpostos {
	public static void main(String[] args) {
		Imposto iss = new Iss();
		Imposto icms =  new Icms();
		
		Orcamento orcamento = new Orcamento(500.0);
		
		CalculadorDeImposto calculadora = new CalculadorDeImposto();
		calculadora.realizaCalculo(orcamento, iss);
		calculadora.realizaCalculo(orcamento, icms);
		
	}

}
