import java.util.Random;


public class Moderado implements Investimento{

	@Override
	public double calculaRendimentos(ContaBancaria conta) {
		double percentual = new Random().nextDouble();

		if(percentual > 0.50){
			return conta.getSaldo() * 0.025;
		}else{
			return conta.getSaldo() * 0.007;
		}
			
	}

}
