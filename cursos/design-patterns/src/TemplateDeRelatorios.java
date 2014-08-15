
public abstract class TemplateDeRelatorios {
	
	public void imprime(Banco banco){
		cabecalho(banco);
		imprimeLinha();
		
		for(Conta conta: banco.getContas()){
			dados(conta);
		}
		
		imprimeLinha();
		rodape(banco);
	}
	
	protected abstract void cabecalho(Banco banco);
	
	protected abstract void dados(Conta conta);
	
	protected abstract void rodape(Banco banco);
	
	private  void imprimeLinha(){
		System.out.println("-----------------------------------------------------------");
	}
	
}
