
public abstract class TemplateDeRespostaDeResquisicao implements Resposta {
		private final Resposta proximo;
		
		public TemplateDeRespostaDeResquisicao(Resposta proximo) {
			this.proximo = proximo;
		}	
		
		public String formata(Requisicao requisicao, Conta conta){
			if(requisicaoTemFormatoEsperado(requisicao)){
				return formataDadosDeAcorcoComARequisicao(conta);
			}else{
				return proximo.formata(requisicao,conta);
			}
		}

		protected abstract String formataDadosDeAcorcoComARequisicao(Conta conta);

		protected abstract boolean requisicaoTemFormatoEsperado(Requisicao requisicao);
		

}


