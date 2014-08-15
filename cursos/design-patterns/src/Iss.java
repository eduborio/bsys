
public class Iss implements Imposto {
	public double calcula(Orcamento o){
		return o.getValor() * 0.06;
	}

}
