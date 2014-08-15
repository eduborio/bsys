
public class TesteDeImpostoIccc {
	public static void main(String[] args) {
		Imposto iccc = new Iccc();
				
		Orcamento o1 = new Orcamento(990.0);
		Orcamento o2 = new Orcamento(1000.0);
		Orcamento o3 = new Orcamento(9000.0);
		
		CalculadorDeImposto calculadora = new CalculadorDeImposto();
		calculadora.realizaCalculo(o1, iccc);
		calculadora.realizaCalculo(o2, iccc);
		calculadora.realizaCalculo(o3, iccc);
	}

}
