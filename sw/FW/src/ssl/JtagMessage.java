package ssl;

import java.io.ByteArrayOutputStream;

import fsm.IMessage;

/**
 * @author Enio Kaljic, PhD
 * 
 */
public class JtagMessage implements IMessage, Cloneable {
	private int messageId;
	private long timestamp;
	private int toId;
	private int fromId;
	private String toAddress;
	private String fromAddress;
	private boolean hasReturnMessage;
	
	private int jtagBaseAddress;
	private int jtagSubBaseAddress;
	private int jtagOffset;
	private boolean jtagIsData64;
	private long jtagData;
	
	public static final int FSI_JTAG_WRITE = 3;
	public static final int FSI_JTAG_READ = 4;
	public static final int DATA = 5;
	
	public JtagMessage() {
		
	}
	
	public JtagMessage(int messageId) {
		this.messageId = messageId;
	}
	
	@Override
	public int getMessageId() {
		return messageId;
	}

	@Override
	public void setMessageId(int messageId) {
		this.messageId = messageId;
	}

	@Override
	public String getMessageDescription() {
		switch(messageId) {
		case 3:
			return "FSI_JTAG_WRITE";
		case 4:
			return "FSI_JTAG_READ";
		case 5:
			return "DATA";
		default:
			return "MESSAGE";
		}
	}
	
	@Override
	public long getTimestamp() {
		return timestamp;
	}

	@Override
	public void setTimestamp(long timestamp) {
		this.timestamp = timestamp;
	}
	
	@Override
	public int getToId() {
		return toId;
	}

	@Override
	public void setToId(int toId) {
		this.toId = toId;	
	}

	@Override
	public int getFromId() {
		return fromId;
	}

	@Override
	public void setFromId(int fromId) {
		this.fromId = fromId;
	}

	@Override
	public String getToAddress() {
		return toAddress;
	}

	@Override
	public void setToAddress(String toAddress) {
		this.toAddress = toAddress;
	}

	@Override
	public String getFromAddress() {
		return fromAddress;
	}

	@Override
	public void setFromAddress(String fromAddress) {
		this.fromAddress = fromAddress;
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

	public long getJtagData() {
		return jtagData;
	}
	
	public void setJtagData(long jtagData) {
		this.jtagData = jtagData;
	}

	@Override
	public void parseTransportMessage(byte[] messageData, int length) {
		jtagData = Long.decode(new String(messageData, 0, length-2));
		messageId = DATA;
	}

	@Override
	public byte[] buildTransportMessage() {
		ByteArrayOutputStream output = new ByteArrayOutputStream();
		try {
			if (messageId == JtagMessage.FSI_JTAG_READ) {
				if (jtagIsData64) {
					output.write(("rd64 0x" + Long.toHexString(jtagBaseAddress) + " 0x" + Long.toHexString(jtagSubBaseAddress) + " 0x" + Long.toHexString(jtagOffset) + "\r").getBytes());
				} else {
					output.write(("rd32 0x" + Long.toHexString(jtagBaseAddress) + " 0x" + Long.toHexString(jtagSubBaseAddress) + " 0x" + Long.toHexString(jtagOffset) + "\r").getBytes());
				}
			} else if (messageId == JtagMessage.FSI_JTAG_WRITE) {
				if (jtagIsData64) {
					output.write(("wr64 0x" + Long.toHexString(jtagBaseAddress) + " 0x" + Long.toHexString(jtagSubBaseAddress) + " 0x" + Long.toHexString(jtagOffset) + " 0x" + Long.toHexString(jtagData) + "\r").getBytes());
				} else {
					output.write(("wr32 0x" + Long.toHexString(jtagBaseAddress) + " 0x" + Long.toHexString(jtagSubBaseAddress) + " 0x" + Long.toHexString(jtagOffset) + " 0x" + Long.toHexString(jtagData) + "\r").getBytes());
				}
			} else if (messageId == JtagMessage.DATA) {
				output.write(("0x" + Long.toHexString(jtagData)).getBytes());
			} else {
				output.write("null".getBytes());
			}
		} catch (Exception e) {
			e.printStackTrace();
		}

		return output.toByteArray();
	}

	@Override
	public boolean equals(IMessage message) {
		return (this.messageId == message.getMessageId());
	}

	public Object clone() throws CloneNotSupportedException {
		JtagMessage clone = (JtagMessage) super.clone();
		return clone;
	}

	@Override
	public boolean getHasReturnMessage() {
		return hasReturnMessage;
	}

	@Override
	public void setHasReturnMessage(boolean hasReturnMessage) {
		this.hasReturnMessage = hasReturnMessage;
	}
}
