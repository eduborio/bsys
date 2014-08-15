
public class Conta {
	private String nomeTitular;
	private String agencia;
	private String conta;
	private double saldo;
	
	public Conta(String nomeTitular,String agencia,String conta, double saldo) {
		this.nomeTitular = nomeTitular;
		this.saldo = saldo;
		this.agencia = agencia;
		this.conta = conta;
	}

	public String getNomeTitular() {
		return nomeTitular;
	}

	public void setNomeTitular(String nomeTitular) {
		this.nomeTitular = nomeTitular;
	}

	public String getAgencia() {
		return agencia;
	}

	public void setAgencia(String agencia) {
		this.agencia = agencia;
	}

	public String getConta() {
		return conta;
	}

	public void setConta(String conta) {
		this.conta = conta;
	}

	public double getSaldo() {
		return saldo;
	}

	public void setSaldo(double saldo) {
		this.saldo = saldo;
	}
}
