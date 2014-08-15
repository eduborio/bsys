
public class TesteDeRequisicao {
	public static void main(String[] args) {
		Conta conta = new Conta("Eduardo","0410","21545487",500);
		Requisicao r1 = new Requisicao(Formato.XML);
		Requisicao r2 = new Requisicao(Formato.CSV);
		Requisicao r3 = new Requisicao(Formato.PORCENTO);
		CorrenteDeRespostasDeRequisicao chain = new CorrenteDeRespostasDeRequisicao();
		System.out.println(chain.formata(r1, conta));
		System.out.println(chain.formata(r2, conta));
		System.out.println(chain.formata(r3, conta));
	}
}
