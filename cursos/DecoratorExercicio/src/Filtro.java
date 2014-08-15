import java.util.ArrayList;
import java.util.List;

public abstract class Filtro {
	
	private final Filtro outroFiltro;

	public Filtro(Filtro outroFiltro){
		this.outroFiltro = outroFiltro;
	}
	
	public Filtro(){
		outroFiltro = null;
	}
	
	public abstract List<Conta> filtra(List<Conta> contas);
	
	protected List<Conta> aplicaOutrofiltro(List<Conta> contas){
		if(outroFiltro==null)return new ArrayList<Conta>();
		return outroFiltro.filtra(contas);
	}

}
