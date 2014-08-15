
public class TesteInvestimentos {
	public static void main(String[] args) {
		ContaBancaria c1 = new ContaBancaria(1000);
		ContaBancaria c2 = new ContaBancaria(1000);
		ContaBancaria c3 = new ContaBancaria(1000);
		
		Investimento conservador = new Conservador();
		Investimento moderado = new Moderado();
		Investimento arrojado = new Arrojado();
		
		RealizadorDeInvestimentos r = new RealizadorDeInvestimentos();
		
		r.realizaInvestimento(c1, conservador);
		r.realizaInvestimento(c2, moderado);
		r.realizaInvestimento(c3, arrojado);
	}

}
