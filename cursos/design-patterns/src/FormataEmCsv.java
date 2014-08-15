
public class FormataEmCsv extends TemplateDeRespostaDeResquisicao{

	public FormataEmCsv(Resposta proximo) {
		super(proximo);
	}

	@Override
	protected String formataDadosDeAcorcoComARequisicao(Conta conta) {
		return conta.getNomeTitular()+" , "+conta.getSaldo();
	}

	@Override
	protected boolean requisicaoTemFormatoEsperado(Requisicao requisicao) {
		return requisicao.getFormato().equals(Formato.CSV);
	}

}
