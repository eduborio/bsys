
public class TesteDeTemplateDeRelatorio {
	public static void main(String[] args) {
		Banco banco = new Banco("Bradesco SA","Rua Xv de novembro","3333-3333","bradesco@bradesco.bank.br");
		banco.adicionarConta(new Conta("Joaquim","0001","45454545",100.0));
		banco.adicionarConta(new Conta("Jose","0002","9001230005",1000.0));
		banco.adicionarConta(new Conta("Silva","0002","90012310005",10100.0));
		banco.adicionarConta(new Conta("Xavier","0001","900123120005",1100.0));
		banco.adicionarConta(new Conta("Joao","0004","123",101.0));
		
		TemplateDeRelatorios complexo = new RelatorioComplexo();
		TemplateDeRelatorios simples =  new RelatorioSimples();
		complexo.imprime(banco);
		simples.imprime(banco);
	}

}
