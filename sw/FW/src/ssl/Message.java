package ssl;

import java.io.ByteArrayOutputStream;
import fsm.IMessage;

/**
 * @author Enio Kaljic, PhD
 * 
 */
public class Message implements IMessage, Cloneable {
	private int messageId;
	private long timestamp;
	private int toId;
	private int fromId;
	private String toAddress;
	private String fromAddress;
	
	private String parameterName;
	private long parameterValue;
	
	public static final int FFI_SEND = 0;
	public static final int FFI_RECEIVE = 1;
	public static final int TIMER_EXPIRED = 2;
	
	public Message() {
		
	}
	
	public Message(int messageId) {
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
		case 0:
			return "FFI_SEND";
		case 1:
			return "FFI_RECEIVE";
		case 2:
			return "TIMER_EXPIRED";
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

	public String getParameterName() {
		return parameterName;
	}

	public void setParameterName(String parameterName) {
		this.parameterName = parameterName;
	}

	public long getParameterValue() {
		return parameterValue;
	}

	public void setParameterValue(long parameterValue) {
		this.parameterValue = parameterValue;
	}

	@Override
	public void parseTransportMessage(byte[] messageData, int length) {
		
	}

	@Override
	public byte[] buildTransportMessage() {
		ByteArrayOutputStream output = new ByteArrayOutputStream();
		try {
			output.write("null".getBytes());
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
		Message clone = (Message) super.clone();
		return clone;
	}

	@Override
	public boolean getHasReturnMessage() {
		return false;
	}

	@Override
	public void setHasReturnMessage(boolean hasReturnMessage) {
		
	}
}
