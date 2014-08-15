
public class Icms implements Imposto {
	public double calcula(Orcamento o){
		return (o.getValor() * 0.05) + 50.0;
	}

}
