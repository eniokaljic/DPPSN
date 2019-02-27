package ssl;

import fsm.Dispatcher;
import fsm.TcpTransport;

/**
 * @author Enio Kaljic, mr.el.-dipl.ing.el.
 * 
 */
public class SSL {
	public static final int APPLICATION = -1;
	public static final int MANAGERSFB = 0;
	public static final int PROXYSFB = 1;
	public static final int JTAGCLIENT = 2;
	public static final int TIMER = 3;

	public static void main(String[] args) {
		ManagerSFB msfb = new ManagerSFB(MANAGERSFB);
		ProxySFB psfb = new ProxySFB(PROXYSFB);
		psfb.setRemoteAddress("127.0.0.1:7000");
		
		TcpTransport jc = new TcpTransport(JTAGCLIENT, new JtagMessage(), true);
		jc.setDescription("JTAGClient");
		jc.setPort(7001);
		jc.setReceiver(psfb);
		
		Dispatcher dispatcher = new Dispatcher(false, true);
		dispatcher.addFSM(msfb);
		dispatcher.addFSM(psfb);
		dispatcher.addFSM(jc);
		dispatcher.start();
		
		try {
			Thread.sleep(1000);
		} catch (InterruptedException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		psfb.startTimer();
		
		//msfb.installLoopbackRule();
		//msfb.installForwardingRules();
	}
}
