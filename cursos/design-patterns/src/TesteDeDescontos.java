
public class TesteDeDescontos {
	public static void main(String[] args) {
		Orcamento o =  new Orcamento(400);
		CalculadorDeDesconto calc = new CalculadorDeDesconto();
		
		o.adicionaItem(new Item("CANETA",200.0));
		o.adicionaItem(new Item("LAPIS",200.0));
		
		double descontoFinal = calc.calcula(o);
		
		System.out.println(descontoFinal);
	}

}
