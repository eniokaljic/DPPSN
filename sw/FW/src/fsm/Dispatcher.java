package fsm;

import java.awt.Frame;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.Queue;

import fsm.pa.SequenceChart;

/**
 * @author Enio Kaljic, PhD
 * 
 */
public class Dispatcher extends Frame implements Runnable {
	private ArrayList<IFSM> fsmList = new ArrayList<IFSM>();
	private Queue<IMessage> messageQueue = new LinkedList<IMessage>();
	private boolean running;
	private SequenceChart chart;
	private boolean debugEnabled;
	private boolean chartEnabled;

	public Dispatcher(boolean debugEnabled, boolean chartEnabled) {
		this.debugEnabled = debugEnabled;
		this.chartEnabled = chartEnabled;
		if (this.chartEnabled) {
			chart = new SequenceChart();
			add("Center", chart);
			pack();
			setTitle("FSM Library Protocol Analyzer - Sequence Chart");
			setSize(800, 600);
			setVisible(true);
		}
	}

	public void start() {
		if (!running) {
			running = true;
			Iterator<IFSM> it = fsmList.iterator();
			while (it.hasNext()) {
				IFSM fsm = it.next();
				fsm.start();
			}
			Thread runningThread = new Thread(this);
			runningThread.start();
		}
	}

	public void stop() {
		if (running) {
			running = false;
			Iterator<IFSM> it = fsmList.iterator();
			while (it.hasNext()) {
				IFSM fsm = it.next();
				fsm.stop();
			}
		}
	}

	public void addFSM(IFSM fsm) {
		fsm.setDispatcher(this);
		fsmList.add(fsm);
		if (chartEnabled) {
			chart.addFSM(fsm);
		}
	}

	public IFSM getFSM(int id) {
		Iterator<IFSM> it = fsmList.iterator();
		while (it.hasNext()) {
			IFSM fsm = it.next();
			if (fsm.getId() == id) {
				return fsm;
			}
		}
		return null;
	}

	public void addMessage(IMessage message) {
		message.setTimestamp(System.currentTimeMillis());
		messageQueue.add(message);
		if (debugEnabled) {
			System.out.println("[Dispatcher] " + message.getMessageDescription() + " " + message.getTimestamp());
		}
		if (chartEnabled) {
			chart.addMessage(message);
		}
	}

	@Override
	public void run() {
		while (running) {
			IMessage message = messageQueue.poll();
			if (message != null) {				
				IFSM fsm = getFSM(message.getToId());
				if (fsm != null) {
					fsm.addMessage(message);
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
