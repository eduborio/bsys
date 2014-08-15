
public class Conservador implements Investimento {

	@Override
	public double calculaRendimentos(ContaBancaria conta) {
		return conta.getSaldo() * 0.008;
	}

}
