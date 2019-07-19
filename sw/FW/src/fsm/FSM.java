package fsm;

import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.Queue;

/**
 * @author Enio Kaljic, PhD
 * 
 */
public abstract class FSM implements Runnable, IFSM {
	private int id;
	private int state;
	private ArrayList<Transition> transitionList = new ArrayList<Transition>();
	private Queue<IMessage> messageQueue = new LinkedList<IMessage>();
	private boolean running = false;
	private Dispatcher dispatcher;

	public FSM(int id) {
		setId(id);
		init();
	}

	public abstract void init();

	public void setId(int id) {
		this.id = id;
	}

	public int getId() {
		return id;
	}

	public void setDispatcher(Dispatcher dispatcher) {
		this.dispatcher = dispatcher;
	}

	public Dispatcher getDispatcher() {
		return dispatcher;
	}

	public void start() {
		if (!running) {
			running = true;
			Thread runningThread = new Thread(this);
			runningThread.start();
		}
	}

	public void stop() {
		if (running) {
			running = false;
		}
	}

	protected void sendMessage(IMessage message) {
		dispatcher.addMessage(message);
	}

	public void addMessage(IMessage message) {
		messageQueue.add(message);
	}

	protected int getState() {
		return state;
	}

	protected void setState(int state) {
		this.state = state;
	}

	protected Transition getTransition(IMessage message) {
		Transition unexpectedTransition = null;
		Iterator<Transition> it = transitionList.iterator();
		while (it.hasNext()) {
			Transition transition = it.next();
			if (transition.getState() == state) {
				if (transition.getMessage() == null || message == null) {
					unexpectedTransition = transition;
				} else {
					if (message.equals(transition.getMessage())) {
						return transition;
					}
				}
			}
		}
		return unexpectedTransition;
	}

	protected void addTransition(int state, IMessage message, String methodName) {
		transitionList.add(new Transition(state, message, methodName));
	}

	protected void addUnexpectedTransition(int state, String methodName) {
		transitionList.add(new Transition(state, null, methodName));
	}
	
	protected TcpTransport getTcpTransport(int id) {
		return (TcpTransport) getDispatcher().getFSM(id);
	}

	@Override
	public void run() {
		while (running) {
			if (messageQueue.size() != 0) {
				IMessage message = messageQueue.poll();
				Transition transition = getTransition(message);
				if (transition != null) {
					//messageQueue.poll();
					try {
						Method m = this.getClass().getDeclaredMethod(transition.getMethodName(), new Class[] { IMessage.class });
						m.setAccessible(true);
						m.invoke(this, new Object[] { message });
					} catch (Exception e) {
						e.printStackTrace();
					}
				}
			}
			try {
				Thread.sleep(0,1);
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
	}
}
