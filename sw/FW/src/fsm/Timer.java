package fsm;

import java.util.Date;

/**
 * @author Enio Kaljic, PhD
 * 
 */
public class Timer {
	private int id;
	private IFSM fsm;
	private long time;
	private long timeLeft;
	private IMessage expireMessage;
	private boolean running = false;
	private boolean paused = false;
	private java.util.Timer timer = new java.util.Timer();
	private TimerTask timerTask;

	public Timer(int id, IFSM fsm, long time, IMessage expireMessage) {
		this.setId(id);
		this.setFsm(fsm);
		this.setTime(time);
		this.setExpireMessage(expireMessage);
	}

	public void setId(int id) {
		this.id = id;
	}

	public int getId() {
		return id;
	}

	public void setFsm(IFSM fsm) {
		this.fsm = fsm;
	}

	public IFSM getFsm() {
		return fsm;
	}

	public void setTime(long time) {
		this.time = time;
	}

	public long getTime() {
		return time;
	}

	public void setExpireMessage(IMessage expireMessage) {
		this.expireMessage = expireMessage;
	}

	public IMessage getExpireMessage() {
		return expireMessage;
	}

	public void start() {
		if (!running) {
			timerTask = new TimerTask();
			timer.schedule(timerTask, time);
			running = true;
			paused = false;
		}
	}

	public void pause() {
		if (running && !paused) {
			timeLeft = timerTask.scheduledExecutionTime() - new Date().getTime();
			timerTask.cancel();
			timer.purge();
			paused = true;
		}
	}

	public void unpause() {
		if (running && paused) {
			timerTask = new TimerTask();
			timer.schedule(timerTask, timeLeft);
			paused = false;
		}
	}

	public void stop() {
		if (running) {
			timerTask.cancel();
			timer.purge();
			running = false;
			paused = false;
		}
	}
	
	public void restart() {
		stop();
		start();
	}

	public boolean isRunning() {
		return running;
	}

	public boolean isPaused() {
		return paused;
	}

	class TimerTask extends java.util.TimerTask {
		@Override
		public void run() {
			expireMessage.setFromId(id);
			expireMessage.setToId(fsm.getId());
			fsm.getDispatcher().addMessage(expireMessage);
			
			timer.purge();
			running = false;
			paused = false;
		}
	}
}
