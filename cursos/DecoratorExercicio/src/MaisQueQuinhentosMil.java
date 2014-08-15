import java.util.ArrayList;
import java.util.List;

public class MaisQueQuinhentosMil extends Filtro{
	
	public MaisQueQuinhentosMil(Filtro outroFiltro){
		super(outroFiltro);
	}
	
	public MaisQueQuinhentosMil(){}

	@Override
	public List<Conta> filtra(List<Conta> contas) {
		List<Conta> contasFiltradas = new ArrayList<Conta>();
		for(Conta conta : contas){
			if(conta.getSaldo()> 500000.0)
				contasFiltradas.add(conta);
				
		}
		contasFiltradas.addAll(aplicaOutrofiltro(contas));
		return contasFiltradas;
	}

}
