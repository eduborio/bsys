
public class HashSet implements Iteravel{

	@Override
	public Iterador percorrerColecao() {
		// TODO Auto-generated method stub
		return new SequenciaDeElementosDoHashSet(this);
	}
	
	
	
	
}
