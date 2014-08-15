
public class Cnpj {
	
	private String valor;
	
	public boolean ehValido(){
		return primeiroDigitoVerificador() == primeiroDigitoVerificadorCorreto()
				&& segundoDigitoVerificador() == segundoDigitoVerificadorCorreto();
	}

	private int primeiroDigitoVerificadorCorreto() {
		return 1;
	}

	private int primeiroDigitoVerificador() {
		return 1;
	}
	
	private int segundoDigitoVerificadorCorreto() {
		return 2;
	}

	private int segundoDigitoVerificador() {
		return 2;
	}

	public String getValor() {
		return valor;
	}

	public void setValor(String valor) {
		this.valor = valor;
	}

}
