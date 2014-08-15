
public class RealizadorDeInvestimentos {
	public void realizaInvestimento(ContaBancaria conta,Investimento investimento){
		conta.atualizaSaldo(investimento.calculaRendimentos(conta) * 0.75);
		System.out.println(conta.getSaldo());
	}
}
