
public class Iss extends Imposto {
	
	public Iss(){}
	
	public Iss(Imposto outroImposto){
		super(outroImposto);
	}
	
	public double calcula(Orcamento o){
		return o.getValor() * 0.06 + calculaOutroImposto(o);
	}

}
