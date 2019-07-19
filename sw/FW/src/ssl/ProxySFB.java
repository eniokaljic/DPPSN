package ssl;

import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;

import fsm.FSM;
import fsm.IFSM;
import fsm.IMessage;
import fsm.Timer;
import fsm.Transition;

/**
 * @author Enio Kaljic, PhD
 * 
 */
public class ProxySFB extends FSM implements IFSM {
	public static final int IDLE = 0;
	public static final int WAITING = 1;
	
	private String remoteAddress;
	private Parameter currentParameter;
	private List<Parameter> parameters;
	private Iterator<Parameter> itParameter;
	private Timer t1;
	
	@Override
	public String getDescription() {
		return "ProxySFB";
	}
	
	public ProxySFB(int id) {
		super(id);
	}
	
	public void setRemoteAddress(String remoteAddress) {
		this.remoteAddress = remoteAddress;
	}

	public String getRemoteAddress() {
		return remoteAddress;
	}

	@Override
	public void init() {
		setState(IDLE);
		
		addTransition(IDLE, new Message(Message.TIMER_EXPIRED), "onTimerExpiredInIdle");
		addTransition(IDLE, new Message(Message.FFI_SEND), "onSendInIdle");
		addTransition(WAITING, new JtagMessage(JtagMessage.DATA), "onDataInWaiting");
		addTransition(WAITING, new Message(Message.FFI_SEND), "onSendInIdle");
		addUnexpectedTransition(WAITING, "unexpectedInWaiting");
		
		parameters = new LinkedList<Parameter>();
		parameters.add(new Parameter("MAC1.TX_STATISTICS.FRAMESOK", Parameter.MAC1_BASE_ADDR, Parameter.TX_STATISTICS_BASE_ADDR, Parameter.STAT_FRAMESOK, true, false));
		parameters.add(new Parameter("MAC1.TX_STATISTICS.OCTETSOK", Parameter.MAC1_BASE_ADDR, Parameter.TX_STATISTICS_BASE_ADDR, Parameter.STAT_OCTETSOK, true, false));
		parameters.add(new Parameter("MAC0.RX_BACKPRESSURE_BASE_ADDR", Parameter.MAC0_BASE_ADDR, Parameter.RX_BACKPRESSURE_BASE_ADDR, 0, false, false));
		parameters.add(new Parameter("MAC1.RX_BACKPRESSURE_BASE_ADDR", Parameter.MAC1_BASE_ADDR, Parameter.RX_BACKPRESSURE_BASE_ADDR, 0, false, false));
		parameters.add(new Parameter("MAC2.RX_BACKPRESSURE_BASE_ADDR", Parameter.MAC2_BASE_ADDR, Parameter.RX_BACKPRESSURE_BASE_ADDR, 0, false, false));
		parameters.add(new Parameter("MAC3.RX_BACKPRESSURE_BASE_ADDR", Parameter.MAC3_BASE_ADDR, Parameter.RX_BACKPRESSURE_BASE_ADDR, 0, false, false));
		
		parameters.add(new Parameter("SCHEDULER_SELECTOR", Parameter.SCHEDULER_BASE_ADDR, 0, 0, false, false));
		parameters.add(new Parameter("HEADER_PARSER_SELECTOR", Parameter.HEADER_PARSER_BASE_ADDR, 0, 0, false, false));
		
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R0.DATA3", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x000, 0x00, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R0.DATA2", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x000, 0x04, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R0.DATA1", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x000, 0x08, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R0.DATA0", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x000, 0x0C, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R0.MASK3", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x000, 0x10, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R0.MASK2", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x000, 0x14, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R0.MASK1", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x000, 0x18, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R0.MASK0", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x000, 0x1C, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R0.ACTION", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x000, 0x20, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R0.COUNTER", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x000, 0x24, false, false));
		
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R1.DATA3", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x040, 0x00, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R1.DATA2", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x040, 0x04, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R1.DATA1", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x040, 0x08, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R1.DATA0", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x040, 0x0C, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R1.MASK3", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x040, 0x10, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R1.MASK2", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x040, 0x14, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R1.MASK1", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x040, 0x18, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R1.MASK0", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x040, 0x1C, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R1.ACTION", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x040, 0x20, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R1.COUNTER", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x040, 0x24, false, false));
		
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R2.DATA3", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x080, 0x00, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R2.DATA2", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x080, 0x04, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R2.DATA1", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x080, 0x08, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R2.DATA0", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x080, 0x0C, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R2.MASK3", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x080, 0x10, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R2.MASK2", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x080, 0x14, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R2.MASK1", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x080, 0x18, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R2.MASK0", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x080, 0x1C, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R2.ACTION", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x080, 0x20, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R2.COUNTER", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x080, 0x24, false, true));
		
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R3.DATA3", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x0C0, 0x00, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R3.DATA2", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x0C0, 0x04, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R3.DATA1", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x0C0, 0x08, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R3.DATA0", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x0C0, 0x0C, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R3.MASK3", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x0C0, 0x10, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R3.MASK2", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x0C0, 0x14, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R3.MASK1", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x0C0, 0x18, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R3.MASK0", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x0C0, 0x1C, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R3.ACTION", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x0C0, 0x20, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R3.COUNTER", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x0C0, 0x24, false, false));
		
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R4.DATA3", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x100, 0x00, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R4.DATA2", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x100, 0x04, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R4.DATA1", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x100, 0x08, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R4.DATA0", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x100, 0x0C, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R4.MASK3", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x100, 0x10, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R4.MASK2", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x100, 0x14, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R4.MASK1", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x100, 0x18, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R4.MASK0", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x100, 0x1C, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R4.ACTION", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x100, 0x20, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R4.COUNTER", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x100, 0x24, false, false));
		
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R5.DATA3", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x140, 0x00, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R5.DATA2", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x140, 0x04, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R5.DATA1", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x140, 0x08, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R5.DATA0", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x140, 0x0C, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R5.MASK3", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x140, 0x10, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R5.MASK2", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x140, 0x14, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R5.MASK1", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x140, 0x18, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R5.MASK0", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x140, 0x1C, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R5.ACTION", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x140, 0x20, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R5.COUNTER", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x140, 0x24, false, false));
		
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R6.DATA3", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x180, 0x00, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R6.DATA2", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x180, 0x04, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R6.DATA1", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x180, 0x08, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R6.DATA0", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x180, 0x0C, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R6.MASK3", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x180, 0x10, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R6.MASK2", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x180, 0x14, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R6.MASK1", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x180, 0x18, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R6.MASK0", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x180, 0x1C, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R6.ACTION", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x180, 0x20, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R6.COUNTER", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x180, 0x24, false, false));
		
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R7.DATA3", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x1C0, 0x00, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R7.DATA2", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x1C0, 0x04, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R7.DATA1", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x1C0, 0x08, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R7.DATA0", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x1C0, 0x0C, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R7.MASK3", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x1C0, 0x10, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R7.MASK2", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x1C0, 0x14, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R7.MASK1", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x1C0, 0x18, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R7.MASK0", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x1C0, 0x1C, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R7.ACTION", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x1C0, 0x20, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R7.COUNTER", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x1C0, 0x24, false, false));
		
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R8.DATA3", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x200, 0x00, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R8.DATA2", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x200, 0x04, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R8.DATA1", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x200, 0x08, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R8.DATA0", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x200, 0x0C, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R8.MASK3", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x200, 0x10, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R8.MASK2", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x200, 0x14, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R8.MASK1", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x200, 0x18, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R8.MASK0", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x200, 0x1C, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R8.ACTION", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x200, 0x20, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R8.COUNTER", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x200, 0x24, false, false));
		
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R9.DATA3", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x240, 0x00, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R9.DATA2", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x240, 0x04, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R9.DATA1", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x240, 0x08, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R9.DATA0", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x240, 0x0C, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R9.MASK3", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x240, 0x10, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R9.MASK2", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x240, 0x14, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R9.MASK1", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x240, 0x18, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R9.MASK0", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x240, 0x1C, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R9.ACTION", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x240, 0x20, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R9.COUNTER", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x240, 0x24, false, false));
		
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R10.DATA3", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x280, 0x00, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R10.DATA2", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x280, 0x04, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R10.DATA1", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x280, 0x08, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R10.DATA0", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x280, 0x0C, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R10.MASK3", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x280, 0x10, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R10.MASK2", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x280, 0x14, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R10.MASK1", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x280, 0x18, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R10.MASK0", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x280, 0x1C, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R10.ACTION", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x280, 0x20, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R10.COUNTER", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x280, 0x24, false, false));
		
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R11.DATA3", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x2C0, 0x00, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R11.DATA2", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x2C0, 0x04, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R11.DATA1", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x2C0, 0x08, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R11.DATA0", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x2C0, 0x0C, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R11.MASK3", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x2C0, 0x10, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R11.MASK2", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x2C0, 0x14, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R11.MASK1", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x2C0, 0x18, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R11.MASK0", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x2C0, 0x1C, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R11.ACTION", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x2C0, 0x20, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R11.COUNTER", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x2C0, 0x24, false, false));
		
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R12.DATA3", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x300, 0x00, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R12.DATA2", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x300, 0x04, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R12.DATA1", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x300, 0x08, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R12.DATA0", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x300, 0x0C, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R12.MASK3", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x300, 0x10, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R12.MASK2", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x300, 0x14, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R12.MASK1", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x300, 0x18, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R12.MASK0", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x300, 0x1C, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R12.ACTION", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x300, 0x20, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R12.COUNTER", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x300, 0x24, false, false));
		
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R13.DATA3", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x340, 0x00, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R13.DATA2", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x340, 0x04, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R13.DATA1", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x340, 0x08, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R13.DATA0", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x340, 0x0C, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R13.MASK3", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x340, 0x10, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R13.MASK2", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x340, 0x14, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R13.MASK1", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x340, 0x18, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R13.MASK0", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x340, 0x1C, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R13.ACTION", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x340, 0x20, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R13.COUNTER", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x340, 0x24, false, false));
		
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R14.DATA3", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x380, 0x00, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R14.DATA2", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x380, 0x04, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R14.DATA1", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x380, 0x08, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R14.DATA0", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x380, 0x0C, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R14.MASK3", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x380, 0x10, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R14.MASK2", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x380, 0x14, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R14.MASK1", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x380, 0x18, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R14.MASK0", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x380, 0x1C, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R14.ACTION", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x380, 0x20, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R14.COUNTER", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x380, 0x24, false, false));
		
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R15.DATA3", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x3C0, 0x00, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R15.DATA2", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x3C0, 0x04, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R15.DATA1", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x3C0, 0x08, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R15.DATA0", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x3C0, 0x0C, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R15.MASK3", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x3C0, 0x10, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R15.MASK2", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x3C0, 0x14, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R15.MASK1", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x3C0, 0x18, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R15.MASK0", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x3C0, 0x1C, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R15.ACTION", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x3C0, 0x20, false, false));
		parameters.add(new Parameter("MATCH_ACTION_TABLE.R15.COUNTER", Parameter.MATCH_ACTION_TABLE_BASE_ADDR, 0x3C0, 0x24, false, false));
		
		itParameter = parameters.iterator();
		
		t1 = new Timer(SSL.PROXYSFB, this, 2, new Message(Message.TIMER_EXPIRED));
	}
	
	public void startTimer() {
		t1.start();		
	}
	
	public void stopTimer() {
		t1.stop();
	}
	
	private void onTimerExpiredInIdle(IMessage message) {
		setState(WAITING);
		do {
			if (itParameter.hasNext()) {
				currentParameter = itParameter.next();
			} else {
				itParameter = parameters.iterator();
				currentParameter = itParameter.next();
			}
		} while (!currentParameter.getPoll());
		
		if (currentParameter.getPoll()) {			
			JtagMessage snd = new JtagMessage(JtagMessage.FSI_JTAG_READ);
			snd.setFromId(this.getId());
			snd.setToId(SSL.JTAGCLIENT);
			snd.setFromAddress(null);
			snd.setToAddress(remoteAddress);
			snd.setHasReturnMessage(true);
			snd.setJtagBaseAddress(currentParameter.getJtagBaseAddress());
			snd.setJtagSubBaseAddress(currentParameter.getJtagSubBaseAddress());
			snd.setJtagOffset(currentParameter.getJtagOffset());
			snd.setJtagIsData64(currentParameter.getJtagIsData64());
			sendMessage(snd);
		} else {
			setState(IDLE);
			addMessage(message);
		}
	}
	
	private void onSendInIdle(IMessage message) {
		Message rcv = (Message)message;
		
		int jtagBaseAddress = 0;
		int jtagSubBaseAddress = 0;
		int jtagOffset = 0;
		boolean jtagIsData64 = false;
		Iterator<Parameter> it = parameters.iterator();
		while (it.hasNext()) {
			Parameter param = it.next();
			if (param.getParameterName().equals(rcv.getParameterName())) {
				System.out.println(param.getParameterName() + " <= " + rcv.getParameterValue());
				jtagBaseAddress = param.getJtagBaseAddress();
				jtagSubBaseAddress = param.getJtagSubBaseAddress();
				jtagOffset = param.getJtagOffset();
				jtagIsData64 = param.getJtagIsData64();
			}
		}
		
		JtagMessage snd = new JtagMessage(JtagMessage.FSI_JTAG_WRITE);
		snd.setFromId(this.getId());
		snd.setToId(SSL.JTAGCLIENT);
		snd.setFromAddress(null);
		snd.setToAddress(remoteAddress);
		snd.setHasReturnMessage(false);
		snd.setJtagBaseAddress(jtagBaseAddress);
		snd.setJtagSubBaseAddress(jtagSubBaseAddress);
		snd.setJtagOffset(jtagOffset);
		snd.setJtagIsData64(jtagIsData64);
		snd.setJtagData(rcv.getParameterValue());
		sendMessage(snd);
	}
	
	private void onDataInWaiting(IMessage message) {
		setState(IDLE);
		
		JtagMessage rcv = (JtagMessage)message;
		Message snd = new Message(Message.FFI_RECEIVE);
		snd.setFromId(this.getId());
		snd.setToId(SSL.MANAGERSFB);
		snd.setParameterName(currentParameter.getParameterName());
		snd.setParameterValue(rcv.getJtagData());
		sendMessage(snd);
		
		t1.restart();
	}
	
	private void unexpectedInWaiting(IMessage message) {
		// NOP
	}
}
