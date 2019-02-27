package fsm;

/**
 * @author Enio Kaljic, mr.el.-dipl.ing.el.
 * 
 */
public interface IMessage extends Cloneable {
	public int getMessageId();
	public void setMessageId(int messageId);
	public String getMessageDescription();
	
	public long getTimestamp();
	public void setTimestamp(long timestamp);
	
	public int getToId();
	public void setToId(int toId);
	public int getFromId();
	public void setFromId(int fromId);
	
	public String getToAddress();
	public void setToAddress(String toAddress);
	public String getFromAddress();
	public void setFromAddress(String fromAddress);
	public boolean getHasReturnMessage();
	public void setHasReturnMessage(boolean hasReturnMessage);
	
	public void parseTransportMessage(byte[] messageData, int length);
	public byte[] buildTransportMessage();
	
	public boolean equals(IMessage message);
	public Object clone() throws CloneNotSupportedException;
}
