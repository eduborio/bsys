import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;


public class TesteDeFiltrosDeContas {
	public static void main(String[] args) throws ParseException {
		
		Filtro filtroMenorQueCem = new MenosQueCem(new MaisQueQuinhentosMil(new AberturaMesCorrente()));
				
		List<Conta> contas = new ArrayList<Conta>();
		
		SimpleDateFormat formatador = new SimpleDateFormat("dd/MM/yyyy");  
		
		contas.add(new Conta(90, formatador.parse("15/03/2012")));
		contas.add(new Conta(150, formatador.parse("15/02/2012")));
		contas.add(new Conta(250, formatador.parse("15/01/2012")));
		contas.add(new Conta(350, formatador.parse("15/04/2012")));
		contas.add(new Conta(85, formatador.parse("15/03/2012")));
		contas.add(new Conta(450, new Date()));
		contas.add(new Conta(550, formatador.parse("15/03/2012")));
		contas.add(new Conta(650, formatador.parse("15/04/2012")));
		contas.add(new Conta(500001, formatador.parse("15/01/2012")));
		contas.add(new Conta(750, formatador.parse("15/02/2012")));
		contas.add(new Conta(95, formatador.parse("15/03/2012")));
		contas.add(new Conta(850, new Date()));
		
		for(Conta conta : filtroMenorQueCem.filtra(contas)){
			System.out.println("saldo: " +conta.getSaldo()+" data Abertura: "+formatador.format(conta.getDataAbertura()));
		}
		
		
	}

}
