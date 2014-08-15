
public class TesteDeImpostosComplexos {
	public static void main(String[] args) {
		Imposto iss = new Iss( new ICPP(new IKCV(new Icms())));
		
		Orcamento orcamento = new Orcamento(500);
		
		double valor = iss.calcula(orcamento);
		System.out.println(valor);
	}
}
