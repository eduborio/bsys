

public class Divida {
	
	private double total;
    private String credor;
    private Cnpj cnpjCredor;
    
    private Pagamentos pagamentos = new Pagamentos();
    
    public String getCredor() {
        return this.credor;
    }
    public double getTotal() {
        return this.total;
    }
       
    public void setCredor(String credor) {
        this.credor = credor;
    }
    public void setTotal(double total) {
        this.total = total;
    }
        
    public Cnpj getCnpjCredor(){
    	return this.cnpjCredor;
    }
	public void setCnpjCredor(Cnpj cnpj) {
		this.cnpjCredor = cnpj;
		
	}
	public void registra(Pagamento pagamento) {
		this.pagamentos.registra(pagamento);
	}
	public double getValorPago() {
		return pagamentos.getValorPago();
		
	}
	
	
	
	
	

}
