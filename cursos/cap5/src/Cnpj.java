
public class Cnpj implements Documento{
	
	@Override
	public boolean equals(Object obj) {
		if (this == obj)
			return true;
		if (obj == null)
			return false;
		if (getClass() != obj.getClass())
			return false;
		Cnpj other = (Cnpj) obj;
		if (valor == null) {
			if (other.valor != null)
				return false;
		} else if (!valor.equals(other.valor))
			return false;
		return true;
	}
	
	@Override
	public int hashCode() {
		return valor.hashCode();
	}
	
	private String valor;
	
	public Cnpj(String valor){
		this.valor = valor;
	}
	
	public boolean ehValido() {
        return primeiroDigitoVerificador() == primeiroDigitoCorreto()
                && segundoDigitoVerificador() == segundoDigitoCorreto();
    }
    private int primeiroDigitoCorreto() {
        // Calcula o primeiro dígito verificador correto para
        // o CNPJ armazenado no atributo valor
        return 1;
    }
    private int primeiroDigitoVerificador() {
        // Extrai o primeiro dígito verificador do CNPJ armazenado
        // no atributo valor
        return 1;
    }
    
    private int segundoDigitoCorreto() {
        // Calcula o segundo dígito verificador correto para
        // o CNPJ armazenado no atributo valor
        return 2;
    }
    private int segundoDigitoVerificador() {
        // Extrai o segundo dígito verificador do CNPJ armazenado
        // no atributo valor
        return 2;
    }
    public String getValor() {
        return this.valor;
    }
    public void setValor(String valor) {
        this.valor = valor;
    }
    
    @Override
    public String toString() {
    	return this.valor;
    	
    }

}
