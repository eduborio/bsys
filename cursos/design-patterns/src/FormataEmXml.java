
public class FormataEmXml extends TemplateDeRespostaDeResquisicao{
	
	public FormataEmXml(Resposta proximo) {
		super(proximo);
	}

	@Override
	protected String formataDadosDeAcorcoComARequisicao(Conta conta) {
		return "<Conta>\n   <titular>"+conta.getNomeTitular()+"</titular>\n   <saldo>"+conta.getSaldo()+"</saldo>\n</Conta>";
	}

	@Override
	protected boolean requisicaoTemFormatoEsperado(Requisicao requisicao) {
		return requisicao.getFormato().equals(Formato.XML);
	}
}
