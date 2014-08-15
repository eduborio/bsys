import java.util.ArrayList;
import java.util.List;

public class MenosQueCem extends Filtro {
	
	public MenosQueCem(Filtro outroFiltro) {
		super(outroFiltro);
	}
	
	public MenosQueCem(){}

	@Override
	public List<Conta> filtra(List<Conta> contas) {
		List<Conta> contasFiltradas = new ArrayList<Conta>();
		for(Conta conta : contas){
			if(conta.getSaldo()< 100)
				contasFiltradas.add(conta);
				
		}
		contasFiltradas.addAll(aplicaOutrofiltro(contas));
		return contasFiltradas;
	}

}
