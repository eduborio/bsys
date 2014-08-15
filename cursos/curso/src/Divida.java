import java.util.ArrayList;


public class Divida {
	private double total;
	private double valorPago;
	private String credor;
	private Cnpj cnpjCredor = new Cnpj();
	private ArrayList<Pagamento> pagamentos = new ArrayList<Pagamento>();
	
	public double getTotal() {
		return total;
	}
	
	public void setTotal(double total) {
		this.total = total;
	}
	
	public double getValorPago() {
		return valorPago;
	}

	public String getCredor() {
		return credor;
	}
	
	public void setCredor(String credor) {
		this.credor = credor;
	}
	
	public Cnpj getCnpjCredor() {
		return cnpjCredor;
	}
	
	private void paga(double valor){
		if(valor < 0)
			throw new IllegalArgumentException("Valor invalido para um pagamento!");
		
		if(valor > 100)
			valor = valor -8;
		
		this.valorPago += valor;
	}

	public ArrayList<Pagamento> getPagamentos() {
		return pagamentos;
	}
	
	public void registra(Pagamento pagamento){
		this.pagamentos.add(pagamento);
		this.paga(pagamento.getValorPagamento());
		
	}

}
