
public class IKCV extends TemplateDeImpostoCodicional{
	
	public IKCV(Imposto outroImposto){
		super(outroImposto);
	}
	
	public IKCV(){}

	private boolean TemItemMaiorQueCemReaisNo(Orcamento o) {
		for(Item item : o.getItens()){
			if(item.getValor() > 100)
				return true;
		}
			
		return false;
	}

	@Override
	public double minimaTaxacao(Orcamento orcamento) {
		return orcamento.getValor() * 0.06 + calculaOutroImposto(orcamento);
	}

	@Override
	public double maximaTaxacao(Orcamento orcamento) {
		return orcamento.getValor() * 0.10 + calculaOutroImposto(orcamento);
	}

	@Override
	public boolean deveUsarMaximaTaxacao(Orcamento orcamento) {
		return orcamento.getValor() > 500 && TemItemMaiorQueCemReaisNo(orcamento);
	}

}
