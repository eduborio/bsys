import java.util.ArrayList;
import java.util.List;

public class Banco {

	private final String nome;
	private final String endereco;
	private final String telefone;
	private final String email;
	private List<Conta> contas;

	public Banco(String nome,String endereco, String telefone,String email) {
		this.nome = nome;
		this.endereco = endereco;
		this.telefone = telefone;
		this.email = email;
		this.contas = new ArrayList<Conta>();
	}

	public String getNome() {
		return nome;
	}

	public String getEndereco() {
		return endereco;
	}

	public String getTelefone() {
		return telefone;
	}
	
	public String getEmail() {
		return email;
	}

	public List<Conta> getContas() {
		return contas;
	}
	
	public void adicionarConta(Conta conta){
		contas.add(conta);
	}
}
