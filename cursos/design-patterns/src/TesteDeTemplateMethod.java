
public class TesteDeTemplateMethod {
	public static void main(String[] args) {
		Item i1 = new Item("Calculadora",120.0);
		Item i2 = new Item("Caneta",90.0);
		
		Imposto icpp = new ICPP();
		Imposto ikcv =  new IKCV();
		
		Orcamento o1 = new Orcamento(600.0);
		Orcamento o2 = new Orcamento(400.0);
		Orcamento o3 = new Orcamento(600.0);
		Orcamento o4 = new Orcamento(400.0);
		
		o3.adicionaItem(i1);
		o4.adicionaItem(i2);
		
		CalculadorDeImposto calculadora = new CalculadorDeImposto();
		calculadora.realizaCalculo(o1, icpp);
		calculadora.realizaCalculo(o2, icpp);
		calculadora.realizaCalculo(o3, ikcv);
		calculadora.realizaCalculo(o4, ikcv);
		
	}

}
