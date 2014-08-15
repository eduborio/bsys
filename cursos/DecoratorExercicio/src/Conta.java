import java.util.Date;

public class Conta {
	private double saldo;
	private Date dataAbertura;
	
	public double getSaldo() {
		return saldo;
	}

	public Date getDataAbertura() {
		return dataAbertura;
	}

	public Conta(double saldo,Date dataAbertura){
		this.saldo = saldo;
		this.dataAbertura = dataAbertura;
	}

}
