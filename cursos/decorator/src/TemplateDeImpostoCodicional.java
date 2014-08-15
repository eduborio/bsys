
public abstract class TemplateDeImpostoCodicional extends Imposto{

	public TemplateDeImpostoCodicional(Imposto outroImposto) {
		super(outroImposto);
	}
	
	public TemplateDeImpostoCodicional(){
	}

	@Override
	public double calcula(Orcamento orcamento) {
		if(deveUsarMaximaTaxacao(orcamento)){
			return maximaTaxacao(orcamento);
		}else{
			return minimaTaxacao(orcamento);
		}
	}

	public abstract double minimaTaxacao(Orcamento orcamento);

	public abstract double maximaTaxacao(Orcamento orcamento);

	public abstract boolean deveUsarMaximaTaxacao(Orcamento orcamento);

}
