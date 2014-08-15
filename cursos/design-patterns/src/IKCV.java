
public class IKCV extends TemplateDeImpostoCodicional{

	private boolean TemItemMaiorQueCemReaisNo(Orcamento o) {
		for(Item item : o.getItens()){
			if(item.getValor() > 100)
				return true;
		}
			
		return false;
	}

	@Override
	public double minimaTaxacao(Orcamento orcamento) {
		return orcamento.getValor() * 0.06;
	}

	@Override
	public double maximaTaxacao(Orcamento orcamento) {
		return orcamento.getValor() * 0.10;
	}

	@Override
	public boolean deveUsarMaximaTaxacao(Orcamento orcamento) {
		return orcamento.getValor() > 500 && TemItemMaiorQueCemReaisNo(orcamento);
	}

}
