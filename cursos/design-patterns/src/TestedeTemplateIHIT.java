
public class TestedeTemplateIHIT {
	public static void main(String[] args) {
		Item i1 = new Item("Calculadora",200.0);
		Item i2 = new Item("Caneta",200.0);
		Item i3 = new Item("Caneta",100.0);
		Item i4 = new Item("Caneta",100.0);
		
		Imposto ihit =  new IHIT();
		
		Orcamento o1 = new Orcamento(600.0);
		o1.adicionaItem(i1);
		o1.adicionaItem(i2);
		o1.adicionaItem(i3);
		
		CalculadorDeImposto calculadora = new CalculadorDeImposto();
		
		calculadora.realizaCalculo(o1, ihit);
		o1.adicionaItem(i4);
		calculadora.realizaCalculo(o1, ihit);
	}

}
