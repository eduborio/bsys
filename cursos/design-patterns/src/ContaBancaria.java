
public class ContaBancaria {
	
	private double saldo;
	
	public double getSaldo() {
		return saldo;
	}

	public ContaBancaria(double saldo){
		this.saldo = saldo;
	}

	public void atualizaSaldo(double valor) {
		this.saldo += valor;
	}
}
