import java.util.ArrayList;
import java.util.Calendar;
import java.util.List;


public class AberturaMesCorrente extends Filtro{
	
	public AberturaMesCorrente(Filtro outroFiltro){
		super(outroFiltro);
	}
	
	public AberturaMesCorrente(){}

	@Override
	public List<Conta> filtra(List<Conta> contas) {
		List<Conta> contasFiltradas = new ArrayList<Conta>();
		for(Conta conta : contas){
			if(ContaAbertaNoMeCorrente(conta))
				contasFiltradas.add(conta);
				
		}
		contasFiltradas.addAll(aplicaOutrofiltro(contas));
		return contasFiltradas;
	}

	private boolean ContaAbertaNoMeCorrente(Conta conta) {
		
		Calendar c = Calendar.getInstance();
		int mesCorrente = c.get(Calendar.MONTH);
		int anoCorrente = c.get(Calendar.YEAR);
		
		c.setTime(conta.getDataAbertura());
		
		int mesAbertura = c.get(Calendar.MONTH);
		int anoAbertura = c.get(Calendar.YEAR);
		
		System.out.println(mesCorrente ==  mesAbertura);				
				
		
		return anoCorrente + mesCorrente == anoAbertura + mesAbertura ;
	}
}
