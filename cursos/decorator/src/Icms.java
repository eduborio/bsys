
public class Icms extends Imposto {
	
	public Icms(Imposto outroImposto){
		super(outroImposto);
	}
	
	public Icms(){
	}
	
	public double calcula(Orcamento o){
		return (o.getValor() * 0.05) + 50.0 + calculaOutroImposto(o);
	}

}
