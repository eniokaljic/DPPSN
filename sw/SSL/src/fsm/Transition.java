package fsm;

/**
 * @author Enio Kaljic, mr.el.-dipl.ing.el.
 * 
 */
public class Transition {
	private int state;
	private IMessage message;
	private String methodName;
	
	public Transition() {
		
	}

	public Transition(int state, IMessage message, String methodName) {
		this.state = state;
		this.message = message;
		this.methodName = methodName;
	}
	
	public void setState(int state) {
		this.state = state;
	}

	public int getState() {
		return state;
	}

	public void setMessage(IMessage message) {
		this.message = message;
	}

	public IMessage getMessage() {
		return message;
	}

	public void setMethodName(String methodName) {
		this.methodName = methodName;
	}

	public String getMethodName() {
		return methodName;
	}
}
