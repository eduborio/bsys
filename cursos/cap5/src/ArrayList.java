
public class ArrayList implements Iteravel{

	@Override
	public Iterador percorrerColecao() {
		// TODO Auto-generated method stub
		return new SequenciaDeElementosArrayList(this);
	}
	
	

}
