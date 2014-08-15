
public class CalculadorDeImposto {
	public void realizaCalculo(Orcamento orcamento, Imposto imposto){
			double valorDoImposto = imposto.calcula(orcamento);
			System.out.println(valorDoImposto);
	}

}
