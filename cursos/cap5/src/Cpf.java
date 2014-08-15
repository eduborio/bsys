
public class Cpf implements Documento {
	
	@Override
	public boolean equals(Object obj) {
		if (this == obj)
			return true;
		if (obj == null)
			return false;
		if (getClass() != obj.getClass())
			return false;
		Cpf other = (Cpf) obj;
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
	
	public Cpf(String valor){
		this.valor = valor;
	}
	
	public boolean ehValido() {
        return primeiroDigitoVerificador() == primeiroDigitoCorreto()
                && segundoDigitoVerificador() == segundoDigitoCorreto();
    }
    private int primeiroDigitoCorreto() {
        return 1;
    }
    private int primeiroDigitoVerificador() {
        return 1;
    }
    
    private int segundoDigitoCorreto() {
        return 2;
    }
    private int segundoDigitoVerificador() {
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
