import java.util.Date;

public class RelatorioComplexo extends TemplateDeRelatorios{

	@Override
	protected void cabecalho(Banco banco) {
		System.out.println(banco.getNome());
		System.out.println(banco.getEndereco());
		System.out.println(banco.getTelefone());
	}

	@Override
	protected void dados(Conta conta) {
		System.out.println(conta.getNomeTitular() + " " + conta.getAgencia() + " " + conta.getConta() + " " + conta.getSaldo());
	}

	@Override
	protected void rodape(Banco banco) {
		System.out.println(banco.getEmail());
		System.out.println(new Date());
		
	}

}
