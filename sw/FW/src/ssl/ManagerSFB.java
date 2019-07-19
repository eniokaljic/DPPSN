package ssl;

import fsm.FSM;
import fsm.IFSM;
import fsm.IMessage;

/**
 * @author Enio Kaljic, PhD
 * 
 */
public class ManagerSFB extends FSM implements IFSM {
	public static final int IDLE = 0;
	public static final int DROP = 1;
	public static final int TAKEDOWN = 2;
	public static final int REDIRECT = 3;
	
	private long p0, p1, p2, c0, c1, c2, t, r0, r1, r2;
	
	@Override
	public String getDescription() {
		return "ManagerSFB";
	}
	
	public ManagerSFB(int id) {
		super(id);
		p0 = 0;
		p1 = 0;
		p2 = 0;
		c0 = 0;
		c1 = 0;
		c2 = 0;
		t = System.currentTimeMillis();
	}
	
	@Override
	public void init() {
		setState(IDLE);
		addTransition(IDLE, new Message(Message.FFI_RECEIVE), "onReceiveInIdle");
		addTransition(DROP, new Message(Message.FFI_RECEIVE), "onReceiveInDrop");
		addTransition(TAKEDOWN, new Message(Message.FFI_RECEIVE), "onReceiveInTakedown");
		addTransition(REDIRECT, new Message(Message.FFI_RECEIVE), "onReceiveInRedirect");
	}
	
	private void onReceiveInIdle(IMessage message) {
		Message rcv = (Message)message;
		if (rcv.getParameterName().equals("MATCH_ACTION_TABLE.R0.COUNTER")) {
			p0 = c0;
			c0 = rcv.getParameterValue();
		} else if (rcv.getParameterName().equals("MATCH_ACTION_TABLE.R1.COUNTER")) {
			p1 = c1;
			c1 = rcv.getParameterValue();
		} else if (rcv.getParameterName().equals("MATCH_ACTION_TABLE.R2.COUNTER")) {
			p2 = c2;
			c2 = rcv.getParameterValue();
		}
		
		if (rcv.getParameterName().equals("MATCH_ACTION_TABLE.R2.COUNTER")) {
			//r0 = 1000 * (c0 - p0) / (System.currentTimeMillis() - t);
			//r1 = 1000 * (c1 - p1) / (System.currentTimeMillis() - t);
			r2 = 1000 * (c2 - p2) / (System.currentTimeMillis() - t);
			t = System.currentTimeMillis();
			
			if (r2 > 1000 && p2 != 0) {
				/*setState(TAKEDOWN);
				System.out.println("R2 (packet/s) = " + r2);
				System.out.println("Operation status: TAKEDOWN");
				setInterfaceDown(2);*/
				
				/*setState(DROP);
				System.out.println("R2 (packet/s) = " + r2);
				System.out.println("Operation status: DROP");
				installDropRule();*/
				
				setState(REDIRECT);
				System.out.println("R2 (packet/s) = " + r2);
				System.out.println("Operation status: REDIRECT");
				installRedirectRule();
			}
		}
	}
	
	private void onReceiveInTakedown(IMessage message) {
		Message rcv = (Message)message;
		if (rcv.getParameterName().equals("MATCH_ACTION_TABLE.R0.COUNTER")) {
			p0 = c0;
			c0 = rcv.getParameterValue();
		} else if (rcv.getParameterName().equals("MATCH_ACTION_TABLE.R1.COUNTER")) {
			p1 = c1;
			c1 = rcv.getParameterValue();
		} else if (rcv.getParameterName().equals("MATCH_ACTION_TABLE.R2.COUNTER")) {
			p2 = c2;
			c2 = rcv.getParameterValue();
		}
		
		if (rcv.getParameterName().equals("MATCH_ACTION_TABLE.R2.COUNTER")) {
			//r0 = 1000 * (c0 - p0) / (System.currentTimeMillis() - t);
			//r1 = 1000 * (c1 - p1) / (System.currentTimeMillis() - t);
			r2 = 1000 * (c2 - p2) / (System.currentTimeMillis() - t);
			t = System.currentTimeMillis();
			
			if (r2 > 0) {
				System.out.println("R2 (packet/s) = " + r2);
			}
			
			/*if (r2 < 100000) {
				System.out.println("R2 (packet/s) = " + r2);
				System.out.println("Operation status: NORMAL");
				setInterfaceUp(2);
				setState(IDLE);
			}*/
		}
	}
	
	private void onReceiveInDrop(IMessage message) {
		Message rcv = (Message)message;
		if (rcv.getParameterName().equals("MATCH_ACTION_TABLE.R0.COUNTER")) {
			p0 = c0;
			c0 = rcv.getParameterValue();
		} else if (rcv.getParameterName().equals("MATCH_ACTION_TABLE.R1.COUNTER")) {
			p1 = c1;
			c1 = rcv.getParameterValue();
		} else if (rcv.getParameterName().equals("MATCH_ACTION_TABLE.R2.COUNTER")) {
			p2 = c2;
			c2 = rcv.getParameterValue();
		}
		
		if (rcv.getParameterName().equals("MATCH_ACTION_TABLE.R2.COUNTER")) {
			r2 = 1000 * (c2 - p2) / (System.currentTimeMillis() - t);
			t = System.currentTimeMillis();
			
			if (r2 > 0) {
				System.out.println("R2 (packet/s) = " + r2);
			}
			
			/*if (r2 < 100000) {
				System.out.println("R2 (packet/s) = " + r2);
				System.out.println("Operation status: NORMAL");
				setInterfaceUp(2);
				setState(IDLE);
			}*/
		}
	}
	
	private void onReceiveInRedirect(IMessage message) {
		Message rcv = (Message)message;
		if (rcv.getParameterName().equals("MATCH_ACTION_TABLE.R0.COUNTER")) {
			p0 = c0;
			c0 = rcv.getParameterValue();
		} else if (rcv.getParameterName().equals("MATCH_ACTION_TABLE.R1.COUNTER")) {
			p1 = c1;
			c1 = rcv.getParameterValue();
		} else if (rcv.getParameterName().equals("MATCH_ACTION_TABLE.R2.COUNTER")) {
			p2 = c2;
			c2 = rcv.getParameterValue();
		}
		
		if (rcv.getParameterName().equals("MATCH_ACTION_TABLE.R2.COUNTER")) {
			r2 = 1000 * (c2 - p2) / (System.currentTimeMillis() - t);
			t = System.currentTimeMillis();
			
			if (r2 > 0) {
				System.out.println("R2 (packet/s) = " + r2);
			}
			
			/*if (r2 < 100000) {
				System.out.println("R2 (packet/s) = " + r2);
				System.out.println("Operation status: NORMAL");
				setInterfaceUp(2);
				setState(IDLE);
			}*/
		}
	}
		
	public void installDefaultRules() {
		// Port 0 -> Port 1
		Message msg = new Message(Message.FFI_SEND);
		msg.setFromId(this.getId());
		msg.setToId(SSL.PROXYSFB);
		msg.setParameterName("MATCH_ACTION_TABLE.R0.DATA3");
		msg.setParameterValue(0x0);
		sendMessage(msg);
		
		msg = new Message(Message.FFI_SEND);
		msg.setFromId(this.getId());
		msg.setToId(SSL.PROXYSFB);
		msg.setParameterName("MATCH_ACTION_TABLE.R0.DATA2");
		msg.setParameterValue(0x0);
		sendMessage(msg);
		
		msg = new Message(Message.FFI_SEND);
		msg.setFromId(this.getId());
		msg.setToId(SSL.PROXYSFB);
		msg.setParameterName("MATCH_ACTION_TABLE.R0.DATA1");
		msg.setParameterValue(0x0);
		sendMessage(msg);
		
		msg = new Message(Message.FFI_SEND);
		msg.setFromId(this.getId());
		msg.setToId(SSL.PROXYSFB);
		msg.setParameterName("MATCH_ACTION_TABLE.R0.DATA0");
		msg.setParameterValue(0x00000008);
		sendMessage(msg);
		
		msg = new Message(Message.FFI_SEND);
		msg.setFromId(this.getId());
		msg.setToId(SSL.PROXYSFB);
		msg.setParameterName("MATCH_ACTION_TABLE.R0.MASK3");
		msg.setParameterValue(0x0);
		sendMessage(msg);
		
		msg = new Message(Message.FFI_SEND);
		msg.setFromId(this.getId());
		msg.setToId(SSL.PROXYSFB);
		msg.setParameterName("MATCH_ACTION_TABLE.R0.MASK2");
		msg.setParameterValue(0x0);
		sendMessage(msg);
		
		msg = new Message(Message.FFI_SEND);
		msg.setFromId(this.getId());
		msg.setToId(SSL.PROXYSFB);
		msg.setParameterName("MATCH_ACTION_TABLE.R0.MASK1");
		msg.setParameterValue(0x0);
		sendMessage(msg);
		
		msg = new Message(Message.FFI_SEND);
		msg.setFromId(this.getId());
		msg.setToId(SSL.PROXYSFB);
		msg.setParameterName("MATCH_ACTION_TABLE.R0.MASK0");
		msg.setParameterValue(0x0000000F);
		sendMessage(msg);
		
		msg = new Message(Message.FFI_SEND);
		msg.setFromId(this.getId());
		msg.setToId(SSL.PROXYSFB);
		msg.setParameterName("MATCH_ACTION_TABLE.R0.ACTION");
		msg.setParameterValue(0x00000004);
		sendMessage(msg);
		
		// Port 1 -> Port 0, Port 2
		msg = new Message(Message.FFI_SEND);
		msg.setFromId(this.getId());
		msg.setToId(SSL.PROXYSFB);
		msg.setParameterName("MATCH_ACTION_TABLE.R1.DATA3");
		msg.setParameterValue(0x0);
		sendMessage(msg);
		
		msg = new Message(Message.FFI_SEND);
		msg.setFromId(this.getId());
		msg.setToId(SSL.PROXYSFB);
		msg.setParameterName("MATCH_ACTION_TABLE.R1.DATA2");
		msg.setParameterValue(0x0);
		sendMessage(msg);
		
		msg = new Message(Message.FFI_SEND);
		msg.setFromId(this.getId());
		msg.setToId(SSL.PROXYSFB);
		msg.setParameterName("MATCH_ACTION_TABLE.R1.DATA1");
		msg.setParameterValue(0x0);
		sendMessage(msg);
		
		msg = new Message(Message.FFI_SEND);
		msg.setFromId(this.getId());
		msg.setToId(SSL.PROXYSFB);
		msg.setParameterName("MATCH_ACTION_TABLE.R1.DATA0");
		msg.setParameterValue(0x00000004);
		sendMessage(msg);
		
		msg = new Message(Message.FFI_SEND);
		msg.setFromId(this.getId());
		msg.setToId(SSL.PROXYSFB);
		msg.setParameterName("MATCH_ACTION_TABLE.R1.MASK3");
		msg.setParameterValue(0x0);
		sendMessage(msg);
		
		msg = new Message(Message.FFI_SEND);
		msg.setFromId(this.getId());
		msg.setToId(SSL.PROXYSFB);
		msg.setParameterName("MATCH_ACTION_TABLE.R1.MASK2");
		msg.setParameterValue(0x0);
		sendMessage(msg);
		
		msg = new Message(Message.FFI_SEND);
		msg.setFromId(this.getId());
		msg.setToId(SSL.PROXYSFB);
		msg.setParameterName("MATCH_ACTION_TABLE.R1.MASK1");
		msg.setParameterValue(0x0);
		sendMessage(msg);
		
		msg = new Message(Message.FFI_SEND);
		msg.setFromId(this.getId());
		msg.setToId(SSL.PROXYSFB);
		msg.setParameterName("MATCH_ACTION_TABLE.R1.MASK0");
		msg.setParameterValue(0x0000000F);
		sendMessage(msg);
		
		msg = new Message(Message.FFI_SEND);
		msg.setFromId(this.getId());
		msg.setToId(SSL.PROXYSFB);
		msg.setParameterName("MATCH_ACTION_TABLE.R1.ACTION");
		msg.setParameterValue(0x0000000A);
		sendMessage(msg);
		
		// Port 2 -> Port 1
		msg = new Message(Message.FFI_SEND);
		msg.setFromId(this.getId());
		msg.setToId(SSL.PROXYSFB);
		msg.setParameterName("MATCH_ACTION_TABLE.R2.DATA3");
		msg.setParameterValue(0x0);
		sendMessage(msg);
		
		msg = new Message(Message.FFI_SEND);
		msg.setFromId(this.getId());
		msg.setToId(SSL.PROXYSFB);
		msg.setParameterName("MATCH_ACTION_TABLE.R2.DATA2");
		msg.setParameterValue(0x0);
		sendMessage(msg);
		
		msg = new Message(Message.FFI_SEND);
		msg.setFromId(this.getId());
		msg.setToId(SSL.PROXYSFB);
		msg.setParameterName("MATCH_ACTION_TABLE.R2.DATA1");
		msg.setParameterValue(0x0);
		sendMessage(msg);
		
		msg = new Message(Message.FFI_SEND);
		msg.setFromId(this.getId());
		msg.setToId(SSL.PROXYSFB);
		msg.setParameterName("MATCH_ACTION_TABLE.R2.DATA0");
		msg.setParameterValue(0x00000002);
		sendMessage(msg);
		
		msg = new Message(Message.FFI_SEND);
		msg.setFromId(this.getId());
		msg.setToId(SSL.PROXYSFB);
		msg.setParameterName("MATCH_ACTION_TABLE.R2.MASK3");
		msg.setParameterValue(0x0);
		sendMessage(msg);
		
		msg = new Message(Message.FFI_SEND);
		msg.setFromId(this.getId());
		msg.setToId(SSL.PROXYSFB);
		msg.setParameterName("MATCH_ACTION_TABLE.R2.MASK2");
		msg.setParameterValue(0x0);
		sendMessage(msg);
		
		msg = new Message(Message.FFI_SEND);
		msg.setFromId(this.getId());
		msg.setToId(SSL.PROXYSFB);
		msg.setParameterName("MATCH_ACTION_TABLE.R2.MASK1");
		msg.setParameterValue(0x0);
		sendMessage(msg);
		
		msg = new Message(Message.FFI_SEND);
		msg.setFromId(this.getId());
		msg.setToId(SSL.PROXYSFB);
		msg.setParameterName("MATCH_ACTION_TABLE.R2.MASK0");
		msg.setParameterValue(0x0000000F);
		sendMessage(msg);
		
		msg = new Message(Message.FFI_SEND);
		msg.setFromId(this.getId());
		msg.setToId(SSL.PROXYSFB);
		msg.setParameterName("MATCH_ACTION_TABLE.R2.ACTION");
		msg.setParameterValue(0x00000004);
		sendMessage(msg);
	}
	
	public void installDropRule() {
		// Port 2 -> DROP
		Message msg = new Message(Message.FFI_SEND);
		msg.setFromId(this.getId());
		msg.setToId(SSL.PROXYSFB);
		msg.setParameterName("MATCH_ACTION_TABLE.R2.ACTION");
		msg.setParameterValue(0x00000000);
		sendMessage(msg);
	}
	
	public void installRedirectRule() {
		// Port 1 -> Port 0
		Message msg = new Message(Message.FFI_SEND);
		msg.setFromId(this.getId());
		msg.setToId(SSL.PROXYSFB);
		msg.setParameterName("MATCH_ACTION_TABLE.R1.ACTION");
		msg.setParameterValue(0x00000008);
		sendMessage(msg);	
		
		// Port 2 -> Port 3
		msg = new Message(Message.FFI_SEND);
		msg.setFromId(this.getId());
		msg.setToId(SSL.PROXYSFB);
		msg.setParameterName("MATCH_ACTION_TABLE.R2.ACTION");
		msg.setParameterValue(0x00000001);
		sendMessage(msg);

		// Port 3 -> Port 2
		msg = new Message(Message.FFI_SEND);
		msg.setFromId(this.getId());
		msg.setToId(SSL.PROXYSFB);
		msg.setParameterName("MATCH_ACTION_TABLE.R3.DATA0");
		msg.setParameterValue(0x00000001);
		sendMessage(msg);
	}
	
	public void setInterfaceDown(int n) {
		Message msg = new Message(Message.FFI_SEND);
		msg.setFromId(this.getId());
		msg.setToId(SSL.PROXYSFB);
		switch(n) {
		case 0:
			msg.setParameterName("MAC0.RX_BACKPRESSURE_BASE_ADDR");
			break;
		case 1:
			msg.setParameterName("MAC1.RX_BACKPRESSURE_BASE_ADDR");
			break;
		case 2:
			msg.setParameterName("MAC2.RX_BACKPRESSURE_BASE_ADDR");
			break;
		case 3:
			msg.setParameterName("MAC3.RX_BACKPRESSURE_BASE_ADDR");
			break;
		default:
			msg.setParameterName("MAC0.RX_BACKPRESSURE_BASE_ADDR");
		}
		msg.setParameterValue(0x1);
		sendMessage(msg);
	}
	
	public void setInterfaceUp(int n) {
		Message msg = new Message(Message.FFI_SEND);
		msg.setFromId(this.getId());
		msg.setToId(SSL.PROXYSFB);
		switch(n) {
		case 0:
			msg.setParameterName("MAC0.RX_BACKPRESSURE_BASE_ADDR");
			break;
		case 1:
			msg.setParameterName("MAC1.RX_BACKPRESSURE_BASE_ADDR");
			break;
		case 2:
			msg.setParameterName("MAC2.RX_BACKPRESSURE_BASE_ADDR");
			break;
		case 3:
			msg.setParameterName("MAC3.RX_BACKPRESSURE_BASE_ADDR");
			break;
		default:
			msg.setParameterName("MAC0.RX_BACKPRESSURE_BASE_ADDR");
		}
		msg.setParameterValue(0x0);
		sendMessage(msg);
	}
}
