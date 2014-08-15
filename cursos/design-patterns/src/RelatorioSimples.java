
public class RelatorioSimples extends TemplateDeRelatorios {

	@Override
	protected void cabecalho(Banco banco) {
		System.out.println(banco.getNome());
	}

	@Override
	protected void dados(Conta conta) {
		System.out.println(conta.getNomeTitular() + " " + conta.getSaldo());
	}

	@Override
	protected void rodape(Banco banco) {
		System.out.println(banco.getTelefone());
	}
}
