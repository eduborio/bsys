
public class PagadorDeFuncionario {
  public void pagaColaborador(Colaborador colaborador){
	  colaborador.paga(colaborador.getValorBase() + colaborador.getExtras());
	  
  }
}