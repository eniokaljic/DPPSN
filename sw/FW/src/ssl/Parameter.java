package ssl;

/**
 * @author Enio Kaljic, PhD
 * 
 */
public class Parameter {
	public static final int MAC0_BASE_ADDR = 0x00000000;
	public static final int MAC1_BASE_ADDR = 0x00008000;
	public static final int MAC2_BASE_ADDR = 0x00010000;
	public static final int MAC3_BASE_ADDR = 0x00018000;
	public static final int SCHEDULER_BASE_ADDR = 0x00020000;
	public static final int HEADER_PARSER_BASE_ADDR = 0x00030000;
	public static final int MATCH_ACTION_TABLE_BASE_ADDR = 0x00040000;
	public static final int DEMUX_BASE_ADDR = 0x00050000;
	
	public static final int RX_BACKPRESSURE_BASE_ADDR = 0x00000000;
	public static final int CRC_PAD_REMOVER_BASE_ADDR = 0x00000100;
	public static final int CRC_CHECKER_BASE_ADDR =	0x00000200; 
	public static final int RX_FRAME_DECODER_BASE_ADDR = 0x00002000;
	public static final int OVERFLOW_CTRL_BASE_ADDR = 0x00000300;
	public static final int RX_STATISTICS_BASE_ADDR = 0x00003000;
	
	public static final int TX_BACKPRESSURE_BASE_ADDR = 0x00004000;
	public static final int CRC_INSERTER_BASE_ADDR = 0x00004200;
	public static final int PAD_INSERTER_BASE_ADDR = 0x00004100;
	public static final int PAUSE_GEN_CTRL_BASE_ADDR = 0x00004500;
	public static final int ADDRESS_INSERTER_BASE_ADDR = 0x00004800;
	public static final int TX_FRAME_DECODER_BASE_ADDR = 0x00006000;
	public static final int UNDERFLOW_CTRL_BASE_ADDR = 0x00006300;
	public static final int TX_STATISTICS_BASE_ADDR = 0x00007000;
	
	public static final int STAT_CLR = 0x00;
	public static final int STAT_FRAMESOK = 0x08;
	public static final int STAT_FRAMESERR = 0x10;
	public static final int STAT_FRAMESCRCERR = 0x18;
	public static final int STAT_OCTETSOK = 0x20;
	public static final int STAT_PAUSEMACCTRLFRAMES = 0x28;
	public static final int STAT_IFERRORS = 0x30;
	public static final int STAT_UNICASTFRAMESOK = 0x38;
	public static final int STAT_UNICASTFRAMESERR = 0x40;
	public static final int STAT_MULTICASTFRAMESOK = 0x48;
	public static final int STAT_MULTICASTFRAMESERR = 0x50;
	public static final int STAT_BROADCASTFRAMESOK = 0x58;
	public static final int STAT_BROADCASTFRAMESERR = 0x60;
	public static final int STAT_ETHERSTATSOCTETS = 0x68;
	public static final int STAT_ETHERSTATSPKTS = 0x70;
	public static final int STAT_ETHERSTATSUNDERSIZEPKTS = 0x78;
	public static final int STAT_ETHERSTATSOVERSIZEPKTS = 0x80;
	public static final int STAT_ETHERSTATSPKTS64OCTETS = 0x88;
	public static final int STAT_ETHERSTATSPKTS65TO127OCTETS = 0x90;
	public static final int STAT_ETHERSTATSPKTS128TO255OCTETS = 0x98;
	public static final int STAT_ETHERSTATSPKTS256TO511OCTET = 0xA0;
	public static final int STAT_ETHERSTATSPKTS512TO1023OCTETS = 0xA8;
	public static final int STAT_ETHERSTATSPKTS1024TO1518OCTETS = 0xB0;
	public static final int STAT_ETHERSTATSPKTS1518TOXOCTETS = 0xB8;
	public static final int STAT_ETHERSTATSFRAGMENTS = 0xC0;
	public static final int STAT_ETHERSTATSJABBERS = 0xC8;
	public static final int STAT_ETHERSTATSCRCERR = 0xD0;
	public static final int STAT_UNICASTMACCTRLFRAMES = 0xD8;
	public static final int STAT_MULTICASTMACCTRLFRAMES = 0xE0;
	public static final int STAT_BROADCASTMACCTRLFRAMES = 0xE8;
	
	private String parameterName;
	private int jtagBaseAddress;
	private int jtagSubBaseAddress;
	private int jtagOffset;
	private boolean jtagIsData64;
	
	private boolean poll;
	
	public Parameter() {
		
	}
	
	public Parameter(String parameterName, int jtagBaseAddress, int jtagSubBaseAddress, int jtagOffset, boolean jtagIsData64, boolean poll) {
		this.parameterName = parameterName;
		this.jtagBaseAddress = jtagBaseAddress;
		this.jtagSubBaseAddress = jtagSubBaseAddress;
		this.jtagOffset = jtagOffset;
		this.jtagIsData64 = jtagIsData64;
		this.poll = poll;
	}
	
	public String getParameterName() {
		return parameterName;
	}
	
	public void setParameterName(String parameterName) {
		this.parameterName = parameterName;
	}
	
	public int getJtagBaseAddress() {
		return jtagBaseAddress;
	}
	
	public void setJtagBaseAddress(int jtagBaseAddress) {
		this.jtagBaseAddress = jtagBaseAddress;
	}
	
	public int getJtagSubBaseAddress() {
		return jtagSubBaseAddress;
	}
	
	public void setJtagSubBaseAddress(int jtagSubBaseAddress) {
		this.jtagSubBaseAddress = jtagSubBaseAddress;
	}
	
	public int getJtagOffset() {
		return jtagOffset;
	}
	
	public void setJtagOffset(int jtagOffset) {
		this.jtagOffset = jtagOffset;
	}
	
	public boolean getJtagIsData64() {
		return jtagIsData64;
	}
	
	public void setJtagIsData64(boolean jtagIsData64) {
		this.jtagIsData64 = jtagIsData64;
	}

	public boolean getPoll() {
		return poll;
	}

	public void setPoll(boolean poll) {
		this.poll = poll;
	}
}
