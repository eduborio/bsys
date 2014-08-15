
public class IHIT extends TemplateDeImpostoCodicional {

	@Override
	public double minimaTaxacao(Orcamento orcamento) {
		return (orcamento.getValor() * orcamento.getItens().size() ) / 100;
	}

	@Override
	public double maximaTaxacao(Orcamento orcamento) {
		return ( orcamento.getValor() * 0.13 ) + 100.00;
	}

	@Override
	public boolean deveUsarMaximaTaxacao(Orcamento orcamento) {
		return existemDoisItensComOMesmoNome(orcamento);
	}

	private boolean existemDoisItensComOMesmoNome(Orcamento orcamento) {
		for(Item item: orcamento.getItens()){
			if( calculaQuantasOcorrenciasDoItemPeloNome(item.getNome(),orcamento) == 2)
				return true;
		}
		
		return false;
	}

	private int calculaQuantasOcorrenciasDoItemPeloNome(String nome,Orcamento orcamento) {
		int ocorrencias = 0;
		for(Item item : orcamento.getItens()){
			if(item.getNome().equals(nome))
				ocorrencias ++;
		}
		return ocorrencias;
	}
}
