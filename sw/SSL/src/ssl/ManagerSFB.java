package ssl;

import fsm.FSM;
import fsm.IFSM;
import fsm.IMessage;

/**
 * @author Enio Kaljic, mr.el.-dipl.ing.el.
 * 
 */
public class ManagerSFB extends FSM implements IFSM {
	public static final int IDLE = 0;
	
	@Override
	public String getDescription() {
		return "ManagerSFB";
	}
	
	public ManagerSFB(int id) {
		super(id);
	}
	
	@Override
	public void init() {
		setState(IDLE);
		addTransition(IDLE, new Message(Message.FFI_RECEIVE), "onReceiveInIdle");
	}
	
	private void onReceiveInIdle(IMessage message) {
		Message rcv = (Message)message;
		System.out.println(rcv.getParameterName() + " = " + rcv.getParameterValue());
	}
	
	public void installLoopbackRule() {
		// Port 0 -> Port 0
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
		msg.setParameterValue(0x00000008);
		sendMessage(msg);
	}
	
	public void installForwardingRules() {
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
		
		// Port 1 -> Port 0
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
		msg.setParameterValue(0x00000008);
		sendMessage(msg);
		
		// Port 2 -> Port 3
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
		msg.setParameterValue(0x00000001);
		sendMessage(msg);
		
		// Port 3 -> Port 2
		msg = new Message(Message.FFI_SEND);
		msg.setFromId(this.getId());
		msg.setToId(SSL.PROXYSFB);
		msg.setParameterName("MATCH_ACTION_TABLE.R3.DATA3");
		msg.setParameterValue(0x0);
		sendMessage(msg);
		
		msg = new Message(Message.FFI_SEND);
		msg.setFromId(this.getId());
		msg.setToId(SSL.PROXYSFB);
		msg.setParameterName("MATCH_ACTION_TABLE.R3.DATA2");
		msg.setParameterValue(0x0);
		sendMessage(msg);
		
		msg = new Message(Message.FFI_SEND);
		msg.setFromId(this.getId());
		msg.setToId(SSL.PROXYSFB);
		msg.setParameterName("MATCH_ACTION_TABLE.R3.DATA1");
		msg.setParameterValue(0x0);
		sendMessage(msg);
		
		msg = new Message(Message.FFI_SEND);
		msg.setFromId(this.getId());
		msg.setToId(SSL.PROXYSFB);
		msg.setParameterName("MATCH_ACTION_TABLE.R3.DATA0");
		msg.setParameterValue(0x00000001);
		sendMessage(msg);
		
		msg = new Message(Message.FFI_SEND);
		msg.setFromId(this.getId());
		msg.setToId(SSL.PROXYSFB);
		msg.setParameterName("MATCH_ACTION_TABLE.R3.MASK3");
		msg.setParameterValue(0x0);
		sendMessage(msg);
		
		msg = new Message(Message.FFI_SEND);
		msg.setFromId(this.getId());
		msg.setToId(SSL.PROXYSFB);
		msg.setParameterName("MATCH_ACTION_TABLE.R3.MASK2");
		msg.setParameterValue(0x0);
		sendMessage(msg);
		
		msg = new Message(Message.FFI_SEND);
		msg.setFromId(this.getId());
		msg.setToId(SSL.PROXYSFB);
		msg.setParameterName("MATCH_ACTION_TABLE.R3.MASK1");
		msg.setParameterValue(0x0);
		sendMessage(msg);
		
		msg = new Message(Message.FFI_SEND);
		msg.setFromId(this.getId());
		msg.setToId(SSL.PROXYSFB);
		msg.setParameterName("MATCH_ACTION_TABLE.R3.MASK0");
		msg.setParameterValue(0x0000000F);
		sendMessage(msg);
		
		msg = new Message(Message.FFI_SEND);
		msg.setFromId(this.getId());
		msg.setToId(SSL.PROXYSFB);
		msg.setParameterName("MATCH_ACTION_TABLE.R3.ACTION");
		msg.setParameterValue(0x00000002);
		sendMessage(msg);
	}
}
