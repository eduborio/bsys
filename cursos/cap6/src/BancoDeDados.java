import java.util.HashMap;
import java.util.Map;


public class BancoDeDados implements ArmazenadorDeDividas{
	private final Map<Documento,Divida> dividasNobanco =  new HashMap<Documento, Divida>();
	
	public BancoDeDados(String endereco, String usuario, String senha){
		System.out.println("conectado");
	}
	
	public void salva(Divida divida){
		dividasNobanco.put(divida.getDocumentoCredor(), divida);
	}
	
   
   public void desconecta(){
	   System.out.println("Desconectado");
   }

  public Divida carrega(Documento documentoCredor) {
	return dividasNobanco.get(documentoCredor);
  }

}
