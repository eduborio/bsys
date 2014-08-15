import java.util.Random;


public class Arrojado implements Investimento{

	@Override
	public double calculaRendimentos(ContaBancaria conta) {
		double percentual = new Random().nextDouble();

		if(percentual <= 0.20){
			return conta.getSaldo() * 0.05;
		}else if(percentual > 0.20 && percentual <= 0.50){
			return conta.getSaldo() * 0.03;
		}else{
			return conta.getSaldo() * 0.006;
		}
	}

}
