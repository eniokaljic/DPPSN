package fsm;

/**
 * @author Enio Kaljic, mr.el.-dipl.ing.el.
 * 
 */
public interface IFSM {
	public void setId(int id);
	public int getId();
	public String getDescription();
	public void start();
	public void stop();
	public void setDispatcher(Dispatcher dispatcher);
	public Dispatcher getDispatcher();
	public void addMessage(IMessage message);
}
